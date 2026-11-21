--!strict
-- Starts the server and connects its services: saving, the world, battles, catching, breeding
-- and the story all share the one loaded profile per player from the data service.
--
-- Still to come: giants, quests, shops and the real screens. In Studio only, a new player is
-- given Mossmitt through the real story path until the starter screen exists.
-- Not yet run in Studio.

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local BattleSession = require(ReplicatedStorage.shared.BattleSession)
local Encounters = require(ReplicatedStorage.shared.Encounters)
local Grants = require(ReplicatedStorage.shared.Grants)
local Net = require(ReplicatedStorage.net.generated.Server)
local Profile = require(ReplicatedStorage.shared.Profile)
local Rewards = require(ReplicatedStorage.shared.Rewards)
local StoryProgress = require(ReplicatedStorage.shared.StoryProgress)
local Trainers = require(ReplicatedStorage.shared.Trainers)
local Types = require(ReplicatedStorage.shared.Types)
local WorldConfig = require(ReplicatedStorage.config.WorldConfig)
local Xp = require(ReplicatedStorage.shared.Xp)

local BattleService = require(script.Parent.Battle.BattleService)
local BreedingService = require(script.Parent.Breeding.BreedingService)
local CaptureService = require(script.Parent.Capture.CaptureService)
local DataService = require(script.Parent.Data.DataService)
local QuestService = require(script.Parent.Quests.QuestService)
local StateSync = require(script.Parent.State.StateSync)
local StoryService = require(script.Parent.Story.StoryService)
local WorldService = require(script.Parent.World.WorldService)

local HATCH_CHECK_SECONDS = 5
local IS_STUDIO = RunService:IsStudio()

-- What a battle was against, kept by the battle service and handed back when it ends.
type WildRef = { kind: "Wild", spawnId: number }
type TrainedRef = { kind: "Trained", opponent: Trainers.Opponent, foes: { Types.Creature } }

-- One line per event in the server log, ready for the analytics service later.
local function log(event: string, fields: { [string]: any })
	local ok, text = pcall(HttpService.JSONEncode, HttpService, fields)
	print(`[{event}] {if ok then text else "(fields could not be written)"}`)
end

local random = Random.new()

local function seed(): number
	return random:NextInteger(1, 2147483646)
end

local function newId(): string
	return HttpService:GenerateGUID(false)
end

-- Gifts waiting for room ---------------------------------------------------------------------

local function rebuildGift(source: string, ref: string): Types.Creature?
	if source == "Starter" or source == "Token" or source == "Quest" then
		return StoryProgress.rebuild(ref, newId(), seed())
	end
	return nil
end

-- Hands over any gifts that were waiting for stable room or a free pen.
local function claimWaiting(player: Player, profile: Profile.Profile)
	local handed = Grants.claimPending(profile, rebuildGift)
	local eggs = StoryProgress.claimEggs(profile, newId, os.time(), seed())
	if handed + eggs > 0 then
		StateSync.changed(player)
		log("PendingClaimed", { player = player.UserId, creatures = handed, eggs = eggs })
	end
end

-- The world and the story --------------------------------------------------------------------

WorldService.start({
	isReady = function(player)
		return DataService.get(player) ~= nil and BattleService.session(player) == nil
	end,
	refuse = BattleService.refuse,
	onAt = function(player, at)
		-- Places the story is waiting for the player to reach.
		StoryService.event(player, { kind = "At", at = at }, nil, true)
	end,
})

StoryService.start({
	getData = DataService.get,
	map = WorldService.map,
	position = WorldService.position,
	refuse = BattleService.refuse,
	changed = StateSync.changed,
	log = log,
})

QuestService.start({
	getData = DataService.get,
	biome = WorldService.biome,
	isNear = WorldService.isNear,
	refuse = BattleService.refuse,
	changed = StateSync.changed,
	log = log,
})

-- Saving (started after the world and the story, which a loading player needs) ---------------

DataService.start(log, function(player: Player)
	local profile = DataService.get(player)
	if not profile then
		return
	end
	StateSync.changed(player)
	Grants.rollDay(profile, os.time())
	claimWaiting(player, profile)
	if IS_STUDIO and profile.Story.starter == nil then
		-- Studio only, until the starter screen exists: pick Mossmitt through the real story path.
		StoryService.event(player, { kind = "Ask", at = nil }, "Mossmitt", true)
	end
end)

-- Battles ------------------------------------------------------------------------------------

local function playerTeam(player: Player): ({ Types.Creature }?, number?)
	local profile = DataService.get(player)
	if not profile then
		return nil, nil
	end
	local team: { Types.Creature } = {}
	for _, id in profile.Team do
		local creature = profile.Creatures[id]
		if creature then
			table.insert(team, creature)
		end
	end
	if #team == 0 then
		return nil, nil
	end
	return team, Xp.levelCap(profile.Story.badges)
end

-- Finds what the player asked to battle. The kind decides where to look, so a tamer can never
-- be battled as a wild creature (which could be run from or lassoed).
local function resolveTarget(
	player: Player,
	kind: BattleSession.Kind,
	targetId: number,
	targetName: string?
): (BattleService.Opponent?, string?)
	if kind == "Wild" then
		local spawn, why = WorldService.engage(player, targetId)
		if not spawn then
			return nil, why
		end
		local ref: WildRef = { kind = "Wild", spawnId = spawn.id }
		return { creatures = { spawn.creature }, moves = nil, tier = "Wild", ref = ref }, nil
	elseif kind == "Tamer" or kind == "Rival" then
		local profile = DataService.get(player)
		if not profile then
			return nil, "Your data is not loaded"
		end
		local opponent, why =
			Trainers.resolve(targetName, profile, StoryService.chapter(), WorldService.biome())
		if not opponent or opponent.kind ~= kind then
			return nil, why or "That battle is not available"
		end
		if not WorldService.isNear(player, opponent.place, WorldConfig.ENGAGE_RADIUS) then
			return nil, "You are too far away"
		end
		local creatures, moves = Trainers.build(opponent)
		local ref: TrainedRef = { kind = "Trained", opponent = opponent, foes = creatures }
		return {
			creatures = creatures,
			moves = moves,
			tier = if kind == "Rival" then "Rival" else "Tamer",
			ref = ref,
		},
			nil
	end
	return nil, "That battle is not available"
end

local function sendRewards(player: Player, battleId: number, paid: Rewards.Paid)
	local members = {}
	for _, member in paid.members do
		table.insert(members, {
			Id = member.id,
			Gained = member.gained,
			Level = member.level,
			LevelsGained = member.levelsGained,
			NewMoves = member.newMoves,
		})
	end
	StateSync.changed(player)
	Net.BattleRewards.Fire(player, {
		BattleId = battleId,
		Coins = paid.coins,
		Material = paid.material or "",
		Members = members,
	})
	log(
		"BattleRewards",
		{ player = player.UserId, battle = battleId, coins = paid.coins, material = paid.material }
	)
end

local function battleStarted(player: Player, session: BattleSession.Session, ref: any?)
	if ref and ref.kind == "Wild" then
		-- A creature battled before keeps the throws it has already dodged.
		local spawn: Encounters.Spawn? = WorldService.spawn(player, (ref :: WildRef).spawnId)
		CaptureService.setMisses(player, session.battleId, if spawn then spawn.misses else 0)
	end
end

local function battleFinished(
	player: Player,
	session: BattleSession.Session,
	outcome: number,
	ref: any?
)
	local ending: BattleSession.Ending? = BattleSession.ending(session)
	log(
		"BattleFinished",
		{ player = player.UserId, battle = session.battleId, kind = session.kind, ending = ending }
	)
	local wildRoute: string? = nil
	if ref and ref.kind == "Wild" then
		local spawnId = (ref :: WildRef).spawnId
		local spawn = WorldService.spawn(player, spawnId)
		wildRoute = if spawn then spawn.route else nil
		WorldService.finish(
			player,
			spawnId,
			ending,
			CaptureService.missesFor(player, session.battleId)
		)
	end
	local profile = DataService.get(player)
	if not profile or outcome ~= 1 then
		return
	end
	local team = {}
	for _, fighter in session.state.sides[1].team do
		table.insert(team, { id = fighter.creature.id, fainted = fighter.hp <= 0 })
	end
	local cap = Xp.levelCap(profile.Story.badges)
	if ref and ref.kind == "Wild" then
		sendRewards(
			player,
			session.battleId,
			Rewards.wildWin(profile, {
				foe = BattleSession.foe(session),
				team = team,
				cap = cap,
				unixTime = os.time(),
				seed = seed(),
				biome = WorldService.biome().number,
			})
		)
		if wildRoute then
			QuestService.record(player, { kind = "WinWild", route = wildRoute })
		end
		if ending == "Caught" then
			local caught = BattleSession.foe(session)
			QuestService.record(player, { kind = "Tame", species = caught.parts.Torso.species })
			StoryService.event(player, { kind = "Tame" }, nil, true)
		end
	elseif ref and ref.kind == "Trained" then
		local trained = ref :: TrainedRef
		sendRewards(
			player,
			session.battleId,
			Rewards.trainedWin(profile, {
				opponentId = trained.opponent.id,
				xpKind = trained.opponent.xpKind,
				paysCoins = trained.opponent.paysCoins,
				biome = WorldService.biome().number,
				foes = trained.foes,
				team = team,
				cap = cap,
				unixTime = os.time(),
			})
		)
		if trained.opponent.kind == "Tamer" then
			QuestService.record(player, { kind = "BeatTamer", tamer = trained.opponent.id })
		end
		local moved =
			StoryService.event(player, { kind = "Win", battle = trained.opponent.id }, nil, true)
		if trained.opponent.kind == "Rival" and not moved then
			-- The win is on record, so the battle cannot be replayed and the story will catch
			-- up; but a story battle whose beat did not finish means something is wrong.
			log("StoryWinNotFinished", { player = player.UserId, battle = trained.opponent.id })
		end
	end
end

BattleService.start(resolveTarget, playerTeam, battleFinished, battleStarted, function(player, ref)
	if ref and ref.kind == "Wild" then
		WorldService.finish(player, (ref :: WildRef).spawnId, nil, 0)
	end
end)

CaptureService.start(DataService.get, log, StateSync.changed)
StateSync.start(DataService.get)

-- Breeding and hatching ----------------------------------------------------------------------

local breeding = BreedingService.new(DataService.get, BattleService.isInBattle, log)

Net.RequestBreed.On(function(player, value)
	local ok, detail = breeding:requestBreed(
		player,
		value.ParentA,
		value.ParentB,
		value.CharmSlot,
		value.CharmFavour
	)
	StateSync.changed(player)
	Net.BreedResult.Fire(player, {
		Ok = ok,
		Reason = if ok then "" else string.sub(tostring(detail), 1, 80),
		HatchAt = if ok and type(detail) == "number" then detail else 0,
	})
end)

task.spawn(function()
	while true do
		task.wait(HATCH_CHECK_SECONDS)
		for _, player in Players:GetPlayers() do
			-- One player's damaged save must never stop hatching for everyone else.
			local ok, problem = pcall(function()
				local hatched = breeding:collectHatched(player)
				local profile = DataService.get(player)
				if profile then
					claimWaiting(player, profile) -- a freed pen may take a waiting gift egg
				end
				if #hatched > 0 then
					local ids = {}
					for index, creature in hatched do
						if index > 8 then
							break -- the rest are in the stable already and show in the state
						end
						table.insert(ids, creature.id)
					end
					StateSync.changed(player)
					Net.Hatched.Fire(player, { Ids = ids })
				end
			end)
			if not ok then
				log("HatchFailed", { player = player.UserId, problem = tostring(problem) })
			end
		end
	end
end)

-- Releasing ----------------------------------------------------------------------------------

local lastRelease: { [Player]: number } = {}
Net.ReleaseCreature.On(function(player, value)
	local now = os.clock()
	if now - (lastRelease[player] or -math.huge) < 0.3 then
		return
	end
	lastRelease[player] = now
	local profile = DataService.get(player)
	if not profile then
		return
	end
	Grants.rollDay(profile, os.time()) -- the release falloff counts by the server's date
	local before = profile.Coins
	local grant = Grants.release(profile, value.Id, BattleService.isInBattle(player, value.Id))
	local ok = grant.outcome == "Granted"
	Net.ReleaseResult.Fire(player, {
		Id = value.Id,
		Ok = ok,
		Reason = string.sub(grant.reason or "", 1, 80),
		Coins = math.max(0, profile.Coins - before),
		Candy = grant.candy or 0,
		Element = grant.element,
	})
	if ok then
		StateSync.changed(player)
		claimWaiting(player, profile)
		log(
			"Release",
			{ player = player.UserId, creature = value.Id, coins = profile.Coins - before }
		)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	breeding:playerRemoving(player)
	lastRelease[player] = nil
end)
