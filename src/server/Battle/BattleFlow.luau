--!strict
-- What happens around a battle: who the player may fight (a wild creature of their own, a tamer,
-- the rival when the story calls for it), what a win pays, what the story, quests and daily
-- tasks hear about it, and waking at the healer when the whole team has fainted.
-- The battle itself is run by BattleService; the rules are in src/shared.
-- Not yet run in Studio.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BattleSession = require(ReplicatedStorage.shared.BattleSession)
local Encounters = require(ReplicatedStorage.shared.Encounters)
local Health = require(ReplicatedStorage.shared.Health)
local Net = require(ReplicatedStorage.net.generated.Server)
local Profile = require(ReplicatedStorage.shared.Profile)
local Rewards = require(ReplicatedStorage.shared.Rewards)
local Trainers = require(ReplicatedStorage.shared.Trainers)
local Types = require(ReplicatedStorage.shared.Types)
local WorldConfig = require(ReplicatedStorage.config.WorldConfig)
local Xp = require(ReplicatedStorage.shared.Xp)

local BattleService = require(script.Parent.BattleService)
local CaptureService = require(script.Parent.Parent.Capture.CaptureService)
local DailyService = require(script.Parent.Parent.Daily.DailyService)
local DataService = require(script.Parent.Parent.Data.DataService)
local GiantService = require(script.Parent.Parent.Giants.GiantService)
local QuestService = require(script.Parent.Parent.Quests.QuestService)
local StateSync = require(script.Parent.Parent.State.StateSync)
local StoryService = require(script.Parent.Parent.Story.StoryService)
local WorldService = require(script.Parent.Parent.World.WorldService)

-- What a battle was against, kept by the battle service and handed back when it ends.
type WildRef = { kind: "Wild", spawnId: number, ambush: boolean? }
type TrainedRef = { kind: "Trained", opponent: Trainers.Opponent, foes: { Types.Creature } }

local BattleFlow = {}

local random = Random.new()
local log: (event: string, fields: { [string]: any }) -> () = function() end

local function seed(): number
	return random:NextInteger(1, 2147483646)
end

-- A creature jumped out of long grass: the battle starts by itself.
function BattleFlow.ambush(player: Player, spawn: Encounters.Spawn)
	local ref: WildRef = { kind = "Wild", spawnId = spawn.id, ambush = true }
	BattleService.begin(
		player,
		"Wild",
		{ creatures = { spawn.creature }, moves = nil, tier = "Wild", ref = ref }
	)
end

function BattleFlow.team(player: Player): ({ Types.Creature }?, number?)
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
	if GiantService.active(player) then
		return nil, "You are already in a battle"
	end
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

function BattleFlow.sendRewards(player: Player, battleId: number, paid: Rewards.Paid)
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

-- A player whose whole team has fainted wakes up at the healer in town with everyone mended.
-- Losing costs the walk back and whatever was used in the battle.
function BattleFlow.wakeAtHealerIfBeaten(player: Player, profile: Profile.Profile)
	local team: { Types.Creature } = {}
	for _, id in profile.Team do
		local creature = profile.Creatures[id]
		if creature then
			table.insert(team, creature)
		end
	end
	if #team == 0 or Health.anyStanding(team) then
		return
	end
	Health.healTeam(profile) -- only the team that fought; the stable stays as it was
	StateSync.changed(player)
	-- When more biomes exist this must be the healer of the player's own town.
	for _, building in WorldService.biome().hub.buildings do
		if building.role == "Healer" then
			WorldService.sendTo(player, building.id)
		end
	end
	Net.Notice.Fire(player, { Text = "Your team fainted. You wake at the healer, rested." })
	log("WokeAtHealer", { player = player.UserId })
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
	if not profile then
		return
	end
	StateSync.changed(player) -- health changed, whatever the result
	BattleFlow.wakeAtHealerIfBeaten(player, profile)
	if outcome ~= 1 then
		return
	end
	local team = {}
	for _, fighter in session.state.sides[1].team do
		table.insert(team, { id = fighter.creature.id, fainted = fighter.hp <= 0 })
	end
	local cap = Xp.levelCap(profile.Story.badges)
	if ref and ref.kind == "Wild" then
		BattleFlow.sendRewards(
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
		DailyService.record(player, "WinBattle")
		DailyService.record(player, "WinWild")
		if ending == "Caught" then
			DailyService.record(player, "Tame")
		end
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
		local paid = Rewards.trainedWin(profile, {
			opponentId = trained.opponent.id,
			xpKind = trained.opponent.xpKind,
			coinKind = if trained.opponent.paysCoins then "Tamer" else nil,
			biome = WorldService.biome().number,
			foes = trained.foes,
			team = team,
			cap = cap,
			unixTime = os.time(),
		})
		BattleFlow.sendRewards(player, session.battleId, paid)
		DailyService.record(player, "WinBattle")
		if trained.opponent.kind == "Tamer" and not paid.firstClear then
			DailyService.record(player, "TamerRematch")
		end
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

function BattleFlow.start(logger: (event: string, fields: { [string]: any }) -> ())
	log = logger
	BattleService.start(
		resolveTarget,
		BattleFlow.team,
		battleFinished,
		battleStarted,
		function(player, ref)
			if ref and ref.kind == "Wild" then
				local wild = ref :: WildRef
				if wild.ambush then
					WorldService.remove(player, wild.spawnId) -- it never really appeared
				else
					WorldService.finish(player, wild.spawnId, nil, 0)
				end
			end
		end
	)
	-- A battle cannot open while the player is in a giant fight, whoever asks for it.
	BattleService.setElsewhereCheck(GiantService.active)
end

return BattleFlow
