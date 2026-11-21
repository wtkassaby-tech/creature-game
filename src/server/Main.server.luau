--!strict
-- Starts the server: saving first, then battles, catching and breeding, all sharing the one
-- loaded profile per player from the data service.
--
-- Still to come: the world service (real wild spawns, tamers, giants, and confirming story
-- triggers by place), tamer and giant rewards, quests and the economy screens. Until the world
-- service exists, Studio playtests pick Mossmitt as the starter through the real story path, get
-- a Greenwood wild creature for any wild battle request, and may finish any story beat in order;
-- none of that happens on a live server.
-- Not yet run in Studio.

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Biomes = require(ReplicatedStorage.content.Biomes)
local BattleSession = require(ReplicatedStorage.shared.BattleSession)
local Chapter1 = require(ReplicatedStorage.content.story.Chapter1)
local Profile = require(ReplicatedStorage.shared.Profile)
local Grants = require(ReplicatedStorage.shared.Grants)
local Net = require(ReplicatedStorage.net.generated.Server)
local Rewards = require(ReplicatedStorage.shared.Rewards)
local StoryProgress = require(ReplicatedStorage.shared.StoryProgress)
local Types = require(ReplicatedStorage.shared.Types)
local World = require(ReplicatedStorage.shared.World)
local Xp = require(ReplicatedStorage.shared.Xp)

local BattleService = require(script.Parent.Battle.BattleService)
local BreedingService = require(script.Parent.Breeding.BreedingService)
local CaptureService = require(script.Parent.Capture.CaptureService)
local DataService = require(script.Parent.Data.DataService)
local StateSync = require(script.Parent.State.StateSync)

local HATCH_CHECK_SECONDS = 5
local IS_STUDIO = RunService:IsStudio()

-- One line per event in the server log, ready for the analytics service later.
local function log(event: string, fields: { [string]: any })
	local ok, text = pcall(HttpService.JSONEncode, HttpService, fields)
	print(`[{event}] {if ok then text else "(fields could not be written)"}`)
end

local random = Random.new()

-- Rebuilds a gift that waited for room in the stable.
local function rebuildGift(source: string, ref: string): Types.Creature?
	if source == "Starter" or source == "Token" then
		return StoryProgress.rebuild(
			ref,
			HttpService:GenerateGUID(false),
			random:NextInteger(1, 2147483646)
		)
	end
	return nil
end

-- Story beats whose trigger the server can confirm today. Places, sightings, talks, wins and
-- tames are confirmed by the world service once it exists; Studio accepts them for testing.
local function triggerMet(profile: Profile.Profile, beatId: string): boolean
	local beat = World.nextBeat(Chapter1, profile.Story.flags)
	if beat == nil or beat.id ~= beatId then
		return false
	end
	return IS_STUDIO or beat.trigger.kind == "Start" or beat.trigger.kind == "Follow"
end

local function completeBeat(player: Player, beatId: string, choice: string?)
	local profile = DataService.get(player)
	if not profile then
		return
	end
	local done, problem = StoryProgress.complete(profile, Chapter1, {
		beatId = beatId,
		choice = choice,
		triggerMet = triggerMet(profile, beatId),
		newId = function()
			return HttpService:GenerateGUID(false)
		end,
		seed = random:NextInteger(1, 2147483646),
		unixTime = os.time(),
	})
	if not done then
		return BattleService.refuse(player, problem or "Not yet")
	end
	local gifts: { { Kind: string, Detail: string, Waiting: boolean } } = {}
	for _, gift in done.gifts do
		table.insert(gifts, {
			Kind = gift.kind :: string,
			Detail = string.sub(gift.detail or "", 1, 40),
			Waiting = gift.waiting == true,
		})
	end
	StateSync.changed(player)
	Net.BeatCompleted.Fire(player, { BeatId = done.beat.id, Gifts = gifts, Unlocks = done.unlocks })
	log("StoryBeat", { player = player.UserId, beat = done.beat.id, gifts = #done.gifts })
end

local function onLoaded(player: Player)
	local profile = DataService.get(player)
	if not profile then
		return
	end
	StateSync.changed(player)
	Grants.rollDay(profile, os.time())
	local handed = Grants.claimPending(profile, rebuildGift)
	if handed > 0 then
		log("PendingClaimed", { player = player.UserId, count = handed })
	end
	if IS_STUDIO and profile.Story.starter == nil then
		-- Studio only, until the starter screen exists: pick Mossmitt through the real story path.
		completeBeat(player, "starter_choice", "Mossmitt")
	end
end

local lastStoryRequest: { [Player]: number } = {}
Net.CompleteBeat.On(function(player, value)
	local now = os.clock()
	if now - (lastStoryRequest[player] or -math.huge) < 0.5 then
		return
	end
	lastStoryRequest[player] = now
	completeBeat(player, value.BeatId, value.Choice)
end)

DataService.start(log, onLoaded)

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

local function resolveTarget(
	_player: Player,
	kind: string,
	_targetId: number
): BattleService.Opponent?
	if not IS_STUDIO or kind ~= "Wild" then
		return nil -- the world service will look the target up; until then, nothing is available
	end
	local route = Biomes.greenwood.routes[1]
	local pick = World.pickWild(
		route,
		random:NextInteger(1, 2147483646),
		nil,
		HttpService:GenerateGUID(false)
	)
	return { creatures = { pick.creature }, moves = nil, tier = "Wild" }
end

local function payBattle(player: Player, session: BattleSession.Session, outcome: number)
	log("BattleFinished", {
		player = player.UserId,
		battle = session.battleId,
		kind = session.kind,
		outcome = outcome,
	})
	-- Only a won (or caught) wild battle pays for now; tamers, giants and gates come with the world.
	if outcome ~= 1 or session.kind ~= "Wild" then
		return
	end
	local profile = DataService.get(player)
	if not profile then
		return
	end
	local team = {}
	for _, fighter in session.state.sides[1].team do
		table.insert(team, { id = fighter.creature.id, fainted = fighter.hp <= 0 })
	end
	local paid = Rewards.wildWin(profile, {
		foe = BattleSession.foe(session),
		team = team,
		cap = Xp.levelCap(profile.Story.badges),
		unixTime = os.time(),
		seed = random:NextInteger(1, 2147483646),
	})
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
		BattleId = session.battleId,
		Coins = paid.coins,
		Material = paid.material or "",
		Members = members,
	})
	log("BattleRewards", {
		player = player.UserId,
		battle = session.battleId,
		coins = paid.coins,
		material = paid.material,
	})
end

BattleService.start(resolveTarget, playerTeam, payBattle)

CaptureService.start(DataService.get, log, StateSync.changed)
StateSync.start(DataService.get)

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
		log(
			"Release",
			{ player = player.UserId, creature = value.Id, coins = profile.Coins - before }
		)
	end
end)

task.spawn(function()
	while true do
		task.wait(HATCH_CHECK_SECONDS)
		for _, player in Players:GetPlayers() do
			local hatched = breeding:collectHatched(player)
			if #hatched > 0 then
				local ids = {}
				for index, creature in hatched do
					if index > 8 then
						break -- the rest are in the stable already and show on the next refresh
					end
					table.insert(ids, creature.id)
				end
				StateSync.changed(player)
				Net.Hatched.Fire(player, { Ids = ids })
			end
		end
	end
end)

Players.PlayerRemoving:Connect(function(player)
	breeding:playerRemoving(player)
	lastStoryRequest[player] = nil
	lastRelease[player] = nil
end)
