--!strict
-- One player's fight against a giant, as the server runs it: start it (a Giant Horn is used up,
-- win or lose), take the player's one choice each turn, and say what happened in the form the
-- screen needs. The fight's own rules are in src/shared/GiantBattle.
--
-- Pure, so it is tested under Lune. Nothing from the device is trusted: a choice is checked
-- against the fight's own state and refused if it does not fit, never guessed at.

local Battle = require("./Battle")
local BattleConfig = require("../config/BattleConfig")
local BattleSession = require("./BattleSession")
local Economy = require("./Economy")
local GiantBattle = require("./GiantBattle")
local Profile = require("./Profile")
local Types = require("./Types")
local Xp = require("./Xp")

export type StartInput = {
	battleId: number,
	giant: GiantBattle.GiantDef,
	biome: number, -- the giant's biome: the horn used must be of this grade or a later one
	yours: { Types.Creature }, -- the player's team, in order
	levelCap: number,
	seed: number,
}

export type Session = {
	battleId: number,
	state: GiantBattle.State,
	shown: number, -- how many log lines the device has been sent
}

export type IntentView = {
	text: string,
	kind: string, -- "Attack", "WindUp" or "Release"
	hitsTeam: boolean,
	enraged: boolean,
	weakTypes: { Types.Element },
}

export type View = {
	battleId: number,
	turn: number,
	lines: { string }, -- what happened since the last view
	bossHp: number,
	bossMaxHp: number,
	teamHp: { number },
	active: number,
	intent: IntentView, -- what the giant will do next turn
	phase: string,
	itemsLeft: number,
	previews: { number }, -- damage each of the active creature's moves would do now
	finished: boolean,
	won: boolean,
}

local GiantSession = {}

-- What the device should show now. Each log line is sent once.
function GiantSession.view(session: Session): View
	local state = session.state
	local lines: { string } = {}
	for index = session.shown + 1, #state.log do
		table.insert(lines, state.log[index].text)
	end
	session.shown = #state.log
	local teamHp: { number } = {}
	for _, fighter in state.team do
		table.insert(teamHp, fighter.hp)
	end
	local previews: { number } = {}
	local me = state.team[state.active]
	if state.winner == nil then
		for _, move in me.moves do
			table.insert(previews, Battle.previewDamage(me, state.boss, move))
		end
	end
	local intent = state.intent
	return {
		battleId = session.battleId,
		turn = state.turn,
		lines = lines,
		bossHp = state.boss.hp,
		bossMaxHp = state.boss.stats.Hp,
		teamHp = teamHp,
		active = state.active,
		intent = {
			text = intent.text,
			kind = intent.kind,
			hitsTeam = intent.hitsTeam,
			enraged = intent.enraged,
			weakTypes = table.clone(intent.weakTypes),
		},
		phase = state.giant.phases[state.phase].name,
		itemsLeft = GiantBattle.itemsLeft(state),
		previews = previews,
		finished = state.winner ~= nil,
		won = state.winner == "Player",
	}
end

-- Starts a fight and uses up one Giant Horn. Returns nil and a reason, changing nothing, if
-- the player has no horn or no team.
function GiantSession.begin(profile: Profile.Profile, input: StartInput): (Session?, string?)
	if #input.yours < 1 or #input.yours > 6 then
		return nil, "You need between one and six creatures on your team"
	end
	local horn = Economy.hornFor(profile.Items, input.biome)
	if not horn then
		return nil, "You need a Giant Horn to wake the giant"
	end
	local team: { Battle.Fighter } = {}
	for _, creature in input.yours do
		table.insert(
			team,
			Battle.fighter(creature, nil, Xp.battleLevel(creature.level, input.levelCap))
		)
	end
	local state = GiantBattle.new(input.giant, team, input.seed)
	-- The horn goes the moment the fight starts: leaving part way does not bring it back.
	profile.Items[horn] -= 1
	return { battleId = input.battleId, state = state, shown = 0 }, nil
end

-- Takes the player's choice for a turn. `kind` is "Move", "Switch" or "Item"; `index` is a move
-- number, a team position, or the team position an item is used on; `item` names the item.
-- An item is taken from the profile only if it was really used. Returns nil and a reason if
-- the choice does not fit.
function GiantSession.act(
	profile: Profile.Profile,
	session: Session,
	turn: unknown,
	kind: unknown,
	index: unknown,
	item: unknown
): (View?, string?)
	local state = session.state
	if state.winner ~= nil then
		return nil, "The fight is over"
	end
	if typeof(turn) ~= "number" or turn ~= state.turn + 1 then
		return nil, "That turn has already been played"
	end
	if typeof(index) ~= "number" or index % 1 ~= 0 then
		return nil, "Bad choice"
	end
	local me = state.team[state.active]
	if kind == "Move" then
		local move = me.moves[index]
		if not move then
			return nil, "That creature does not know that move"
		end
		GiantBattle.step(state, { kind = "Move", move = move })
	elseif kind == "Switch" then
		local target = state.team[index]
		if not target or target.hp <= 0 or index == state.active then
			return nil, "You cannot switch to that creature"
		end
		GiantBattle.step(state, { kind = "Switch", to = index })
	elseif kind == "Item" then
		local id: BattleSession.FieldItem? = BattleSession.parseFieldItem(item)
		local target = state.team[index]
		if not id or not target then
			return nil, "Bad choice"
		end
		local key: string = id
		if (profile.Items[key] or 0) < 1 then
			return nil, "You have none of those"
		end
		if GiantBattle.itemsLeft(state) < 1 then
			return nil, "No more items can be used in this fight"
		end
		local effect = BattleConfig.FIELD_ITEMS[id]
		if effect.kind == "Heal" then
			if target.hp <= 0 then
				return nil, "That creature has fainted"
			elseif target.hp >= target.stats.Hp then
				return nil, "That creature is not hurt"
			end
		elseif target.hp > 0 then
			return nil, "That creature has not fainted"
		end
		local used: GiantBattle.ItemEffect = if effect.kind == "Heal"
			then { kind = "Heal", share = effect.share }
			else { kind = "Revive", share = effect.share }
		GiantBattle.step(state, { kind = "Item", name = key, effect = used, target = index })
		profile.Items[key] -= 1
	else
		return nil, "Bad choice"
	end
	return GiantSession.view(session), nil
end

return GiantSession
