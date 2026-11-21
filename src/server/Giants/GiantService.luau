--!strict
-- Giant fights on the server. The rules are in src/shared/GiantSession and GiantBattle; this
-- file checks who is asking and where they stand, runs one fight per player, and pays a win.
-- A fight is not saved: leaving ends it, and the Giant Horn it used stays used.
-- Capturing a beaten giant is not built yet (what a giant is as a team member is undecided).
-- Not yet run in Studio.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GiantSession = require(ReplicatedStorage.shared.GiantSession)
local Giants = require(ReplicatedStorage.content.Giants)
local Layout = require(ReplicatedStorage.shared.Layout)
local Net = require(ReplicatedStorage.net.generated.Server)
local Profile = require(ReplicatedStorage.shared.Profile)
local Rewards = require(ReplicatedStorage.shared.Rewards)
local Types = require(ReplicatedStorage.shared.Types)
local WorldTypes = require(ReplicatedStorage.shared.WorldTypes)
local Xp = require(ReplicatedStorage.shared.Xp)

local MIN_SECONDS_BETWEEN_STARTS = 1
local MIN_SECONDS_BETWEEN_ACTIONS = 0.25
local FIRST_BATTLE_ID = 3000000000 -- kept apart from ordinary battle ids

export type Hooks = {
	getData: (player: Player) -> Profile.Profile?,
	team: (player: Player) -> ({ Types.Creature }?, number?), -- the team and the level cap
	inOtherBattle: (player: Player) -> boolean,
	biome: () -> WorldTypes.Biome,
	map: () -> Layout.Map,
	position: (player: Player) -> Layout.Point?,
	refuse: (player: Player, reason: string) -> (),
	changed: (player: Player) -> (),
	onWon: (player: Player, battleId: number, giantId: string, paid: Rewards.GiantPaid) -> (),
	log: (event: string, fields: { [string]: any }) -> (),
}

local GiantService = {}

local sessions: { [Player]: GiantSession.Session } = {}
local lastStart: { [Player]: number } = {}
local lastAction: { [Player]: number } = {}
local nextBattleId = FIRST_BATTLE_ID

-- True while the player is in a giant fight.
function GiantService.active(player: Player): boolean
	return sessions[player] ~= nil
end

-- True while the creature is in this player's giant fight; a lock for breeding and releasing.
function GiantService.isInBattle(player: Player, creatureId: string): boolean
	local session = sessions[player]
	if not session then
		return false
	end
	for _, fighter in session.state.team do
		if fighter.creature.id == creatureId then
			return true
		end
	end
	return false
end

local function wire(view: GiantSession.View): any
	local lines: { string } = {}
	for index, line in view.lines do
		if index > 24 then
			break
		end
		table.insert(lines, string.sub(line, 1, 160))
	end
	local previews: { number } = {}
	for index, damage in view.previews do
		if index <= 4 then
			table.insert(previews, math.clamp(damage, 0, 65535))
		end
	end
	return {
		BattleId = view.battleId,
		Turn = view.turn,
		Lines = lines,
		BossHp = math.max(0, view.bossHp),
		BossMaxHp = view.bossMaxHp,
		TeamHp = view.teamHp,
		Active = view.active,
		Intent = {
			Text = string.sub(view.intent.text, 1, 160),
			Kind = view.intent.kind,
			HitsTeam = view.intent.hitsTeam,
			Enraged = view.intent.enraged,
			WeakTypes = view.intent.weakTypes,
		},
		Phase = string.sub(view.phase, 1, 40),
		ItemsLeft = math.max(0, view.itemsLeft),
		Previews = previews,
		Finished = view.finished,
		Won = view.won,
	}
end

function GiantService.start(hooks: Hooks): () -> ()
	local random = Random.new()

	local stopStart = Net.StartGiant.On(function(player, value)
		local now = os.clock()
		if now - (lastStart[player] or -math.huge) < MIN_SECONDS_BETWEEN_STARTS then
			return
		end
		lastStart[player] = now
		if sessions[player] or hooks.inOtherBattle(player) then
			return hooks.refuse(player, "You are already in a battle")
		end
		local profile = hooks.getData(player)
		local creatures, cap = hooks.team(player)
		if not profile or not creatures or not cap then
			return hooks.refuse(player, "Your data is not loaded")
		end
		-- The only giant that can be fought is the one whose lair the player is standing in.
		local lair = hooks.biome().lair
		local giant = Giants[lair.giant]
		local at = hooks.position(player)
		if not giant or value.GiantId ~= giant.id then
			return hooks.refuse(player, "There is no giant here")
		end
		if not at or not Layout.isNear(hooks.map(), lair.id, at, lair.arenaSize / 2) then
			return hooks.refuse(player, "You are too far away")
		end
		nextBattleId += 1
		local session, problem = GiantSession.begin(profile, {
			battleId = nextBattleId,
			giant = giant,
			yours = creatures,
			levelCap = cap,
			seed = random:NextInteger(1, 2147483646),
		})
		if not session then
			return hooks.refuse(player, problem or "The giant does not stir")
		end
		sessions[player] = session
		hooks.changed(player) -- the horn is spent
		hooks.log(
			"GiantStarted",
			{ player = player.UserId, giant = giant.id, battle = session.battleId }
		)

		local yours = {}
		for _, fighter in session.state.team do
			local c = fighter.creature
			table.insert(yours, {
				Id = c.id,
				BodyPlan = c.bodyPlan,
				Head = c.parts.Head.species,
				Torso = c.parts.Torso.species,
				FrontLimbs = c.parts.FrontLimbs.species,
				Legs = c.parts.Legs.species,
				Tail = c.parts.Tail.species,
				Colour = c.colour.shown,
				Size = c.size,
				Rarity = c.rarity,
				Element = fighter.element,
				Level = fighter.level,
				MaxHp = fighter.stats.Hp,
				Hp = fighter.hp,
				Moves = fighter.moves,
			})
		end
		Net.GiantStarted.Fire(player, {
			Name = giant.name,
			Level = giant.level,
			Element = giant.element,
			Yours = yours,
			View = wire(GiantSession.view(session)),
		})
	end)

	local stopAction = Net.GiantAction.On(function(player, value)
		local now = os.clock()
		if now - (lastAction[player] or -math.huge) < MIN_SECONDS_BETWEEN_ACTIONS then
			return
		end
		lastAction[player] = now
		local session = sessions[player]
		local profile = hooks.getData(player)
		if not session or not profile or session.battleId ~= value.BattleId then
			return hooks.refuse(player, "That fight is over")
		end
		local view, problem =
			GiantSession.act(profile, session, value.Turn, value.Kind, value.Index, value.Item)
		if not view then
			return hooks.refuse(player, problem or "That choice is not allowed")
		end
		if value.Kind == "Item" then
			hooks.changed(player)
		end
		Net.GiantTurn.Fire(player, wire(view))
		if not view.finished then
			return
		end
		sessions[player] = nil
		local giant = session.state.giant
		hooks.log(
			"GiantFinished",
			{ player = player.UserId, giant = giant.id, won = view.won, turns = view.turn }
		)
		if not view.won then
			return
		end
		local team = {}
		for _, fighter in session.state.team do
			table.insert(team, { id = fighter.creature.id, fainted = fighter.hp <= 0 })
		end
		local paid = Rewards.giantWin(profile, giant, session.state.boss.creature, {
			biome = hooks.biome().number,
			team = team,
			cap = Xp.levelCap(profile.Story.badges),
			unixTime = os.time(),
		})
		hooks.changed(player)
		hooks.onWon(player, session.battleId, giant.id, paid)
	end)

	local leaving = Players.PlayerRemoving:Connect(function(player)
		sessions[player] = nil
		lastStart[player] = nil
		lastAction[player] = nil
	end)

	return function()
		stopStart()
		stopAction()
		leaving:Disconnect()
	end
end

return GiantService
