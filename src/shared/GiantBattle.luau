--!strict
-- (Over 400 lines because the data types and the validator sit beside the rules they describe.)
-- Giant fights as pure functions: the player's whole team against one huge creature with scripted
-- phases. Each turn the player picks one action for the active creature (a move, a switch or an
-- item), then the giant does exactly what its shown intent said. No dice in the giant's choices:
-- its patterns are fixed lists, so a second attempt is a better plan and not a re-roll.
-- Damage uses the game's formula and type chart (Battle.previewDamage, TypeChart) with the small
-- PvE variance from the seed, so a fight replays from its seed and the player's action list.
-- Everything about a giant is data (see src/content/giants); this file has no giant-specific code.

local Battle = require("./Battle")
local BattleConfig = require("../config/BattleConfig")
local GiantConfig = require("../config/GiantConfig")
local Moves = require("../content/Moves")
local Rng = require("./Rng")
local TypeChart = require("./TypeChart")
local Types = require("./Types")

type Fighter = Battle.Fighter

-- What happens to a big attack when the giant is hit by a type it is weak to while it is charged.
export type Interrupt = "Cancel" | "Halve"

export type GiantAttack = {
	name: string,
	element: Types.Element,
	power: number, -- per target; a team attack usually has a lower power than a single-target one
	target: "Front" | "Team", -- Front hits the active creature; Team hits every creature still standing
	windUp: boolean, -- a big attack: one announced turn of charging, then the strike
	whenInterrupted: Interrupt?, -- required when windUp is true
	text: string, -- the intent line when it strikes at once (or, for a wind-up attack, the fallback)
	windUpText: string?, -- shown while it charges: "Winding up: ..."
	releaseText: string?, -- shown on the turn it lands
}

export type Phase = {
	name: string,
	enterAt: number, -- entered when the giant's health share falls to this (1.0, 0.6, 0.25)
	enterText: string, -- the scripted beat shown when the phase begins
	idea: string, -- what this phase adds, for designers and the guide (not shown in the fight)
	pattern: { string }, -- attack ids, repeated in order
	damageMultiplier: number,
}

export type Enrage = { startTurn: number, step: number }

export type GiantDef = {
	id: string,
	name: string,
	element: Types.Element,
	level: number,
	stats: { Hp: number, Attack: number, Defence: number },
	attacks: { [string]: GiantAttack },
	phases: { Phase },
	enrage: Enrage?, -- falls back to GiantConfig when missing
}

-- An item is a named effect the caller passes in; the item list and prices live elsewhere.
export type ItemEffect = { kind: "Heal", share: number } | { kind: "Revive", share: number }
export type Action =
	{ kind: "Move", move: string }
	| { kind: "Switch", to: number }
	| { kind: "Item", name: string, effect: ItemEffect, target: number }

export type Intent = {
	attack: string, -- attack id
	kind: "Attack" | "WindUp" | "Release",
	text: string, -- the short line for the screen
	hitsTeam: boolean,
	enraged: boolean,
	weakTypes: { Types.Element }, -- for WindUp and Release: types that stop or halve it (empty otherwise)
}

export type Event = { turn: number, text: string }

export type State = {
	giant: GiantDef,
	boss: Fighter, -- the giant as a Fighter, so Battle.previewDamage can aim at it
	team: { Fighter },
	active: number,
	turn: number,
	phase: number,
	patternIndex: number,
	intent: Intent, -- what the giant will do next turn
	charged: { attack: string, interrupted: boolean }?, -- a wind-up attack waiting to land
	itemsUsed: number,
	rng: Rng.Rng,
	history: { Action },
	log: { Event },
	winner: ("Player" | "Giant")?,
}

local GiantBattle = {}

-- Giants are not creatures, but the damage formula wants a Fighter to aim at: build a stand-in.
local function bossFighter(def: GiantDef): Fighter
	local part: Types.Part = { species = def.id, quality = 5 }
	local stand: Types.Creature = {
		id = def.id,
		bodyPlan = "Quad",
		parts = { Head = part, Torso = part, FrontLimbs = part, Legs = part, Tail = part },
		size = 1,
		colour = { shown = "", carried = "" },
		rarity = "Common",
		level = def.level,
		xp = 0,
		generation = 0,
		parents = nil,
		breedCount = 0,
		breedReadyAt = 0,
		originBiome = 1,
		isGiant = true,
		bound = true,
	}
	return {
		creature = stand,
		element = def.element,
		stats = {
			Hp = def.stats.Hp,
			Attack = def.stats.Attack,
			Defence = def.stats.Defence,
			Speed = 0,
		},
		hp = def.stats.Hp,
		tempo = 0,
		moves = {},
	}
end

-- Giant health to aim for: about HEALTH_TEAM_MULTIPLIER x the combined health of an on-level team.
function GiantBattle.suggestedHealth(teamHp: number): number
	return math.floor(teamHp * GiantConfig.HEALTH_TEAM_MULTIPLIER)
end

-- Types that are strong against `element`: hitting the giant with one of these is a weak-point hit.
function GiantBattle.weakTypes(element: Types.Element): { Types.Element }
	local list: { Types.Element } = {}
	for _, attacker: Types.Element in TypeChart.ELEMENTS do
		if TypeChart.isStrong(attacker, element) then
			table.insert(list, attacker)
		end
	end
	return list
end

-- Checks a giant's data and returns a list of problems (empty when it is sound).
function GiantBattle.validate(def: GiantDef): { string }
	local problems: { string } = {}
	local function bad(text: string)
		table.insert(problems, `{def.id}: {text}`)
	end
	if def.stats.Hp <= 0 or def.stats.Attack <= 0 or def.stats.Defence <= 0 then
		bad("stats must be positive")
	end
	if #def.phases == 0 then
		bad("needs at least one phase")
	elseif def.phases[1].enterAt ~= 1 then
		bad("the first phase must begin at 1.0")
	end
	local last = 2
	for index, phase in def.phases do
		if phase.enterAt >= last then
			bad(`phase {index} must begin below the one before`)
		end
		last = phase.enterAt
		if phase.enterAt <= 0 or phase.damageMultiplier <= 0 then
			bad(`phase {index} has a bad threshold or multiplier`)
		end
		if #phase.pattern == 0 then
			bad(`phase {index} has an empty pattern`)
		end
		for _, id in phase.pattern do
			if not def.attacks[id] then
				bad(`phase {index} uses unknown attack {id}`)
			end
		end
	end
	for id, attack in def.attacks do
		if attack.power <= 0 then
			bad(`attack {id} needs positive power`)
		end
		if attack.windUp and attack.whenInterrupted == nil then
			bad(`wind-up attack {id} needs whenInterrupted`)
		end
	end
	return problems
end

local function enrageOf(def: GiantDef): Enrage
	return def.enrage or { startTurn = GiantConfig.ENRAGE_TURN, step = GiantConfig.ENRAGE_STEP }
end

-- The enrage multiplier on the giant's damage in a given turn: 1 until it starts.
function GiantBattle.enrageMultiplier(def: GiantDef, turn: number): number
	local enrage = enrageOf(def)
	if turn < enrage.startTurn then
		return 1
	end
	return math.min(GiantConfig.ENRAGE_MAX, 1 + enrage.step * (turn - enrage.startTurn + 1))
end

local function makeIntent(
	state: State,
	id: string,
	kind: "Attack" | "WindUp" | "Release",
	turn: number
): Intent
	local attack = state.giant.attacks[id]
	local text = attack.text
	if kind == "WindUp" then
		text = attack.windUpText or `Winding up: {attack.name}`
	elseif kind == "Release" then
		text = attack.releaseText or attack.text
	end
	local enraged = turn >= enrageOf(state.giant).startTurn
	if enraged then
		text ..= " (enraged)"
	end
	return {
		attack = id,
		kind = kind,
		text = text,
		hitsTeam = attack.target == "Team",
		enraged = enraged,
		weakTypes = if kind == "Attack" then {} else GiantBattle.weakTypes(state.giant.element),
	}
end

function GiantBattle.new(def: GiantDef, team: { Fighter }, seed: number): State
	local state: State = {
		giant = def,
		boss = bossFighter(def),
		team = team,
		active = 1,
		turn = 0,
		phase = 1,
		patternIndex = 1,
		intent = nil :: any,
		charged = nil,
		itemsUsed = 0,
		rng = Rng.new(seed),
		history = {},
		log = {},
		winner = nil,
	}
	local id = def.phases[1].pattern[1]
	state.intent = makeIntent(state, id, if def.attacks[id].windUp then "WindUp" else "Attack", 1)
	return state
end

local function note(state: State, text: string)
	table.insert(state.log, { turn = state.turn, text = text })
end

local function firstAlive(team: { Fighter }): number?
	for index, fighter in team do
		if fighter.hp > 0 then
			return index
		end
	end
	return nil
end

function GiantBattle.itemsLeft(state: State): number
	return GiantConfig.MAX_ITEMS - state.itemsUsed
end

local function attackDamage(state: State, attackId: string, defender: Fighter, turn: number): number
	local giant = state.giant
	local attack = giant.attacks[attackId]
	local ratio = giant.stats.Attack / (giant.stats.Attack + defender.stats.Defence)
	local own = if attack.element == giant.element then TypeChart.OWN_TYPE_MULTIPLIER else 1
	local matchup = TypeChart.multiplier(attack.element, defender.element)
	local scale = giant.phases[state.phase].damageMultiplier
		* GiantBattle.enrageMultiplier(giant, turn)
	return math.max(
		1,
		math.floor(BattleConfig.DAMAGE_SCALE * attack.power * ratio * own * matchup * scale)
	)
end

-- Damage one giant attack would do to one creature next turn, before variance.
function GiantBattle.previewAttack(state: State, attackId: string, defender: Fighter): number
	return attackDamage(state, attackId, defender, state.turn + 1)
end

-- A simple fallback and policy helper: the move that does the most damage to the giant right now.
function GiantBattle.bestMove(state: State): Action
	local me = state.team[state.active]
	local best, bestDamage = me.moves[1], -1
	for _, name in me.moves do
		local damage = Battle.previewDamage(me, state.boss, name)
		if damage > bestDamage then
			best, bestDamage = name, damage
		end
	end
	return { kind = "Move", move = best }
end

-- An invalid choice is replaced by the best move, never trusted (same stance as Battle.step).
local function validAction(state: State, action: Action): Action
	if action.kind == "Switch" then
		local target = state.team[action.to]
		if target and target.hp > 0 and action.to ~= state.active then
			return action
		end
	elseif action.kind == "Move" then
		if table.find(state.team[state.active].moves, action.move) then
			return action
		end
	elseif state.itemsUsed < GiantConfig.MAX_ITEMS then
		local target = state.team[action.target]
		local effect = action.effect
		if target and effect.share > 0 and effect.share <= 1 then
			if effect.kind == "Heal" and target.hp > 0 and target.hp < target.stats.Hp then
				return action
			elseif effect.kind == "Revive" and target.hp == 0 then
				return action
			end
		end
	end
	return GiantBattle.bestMove(state)
end

local function variance(state: State): number
	return BattleConfig.PVE_VARIANCE_MIN + Rng.next(state.rng) * (1 - BattleConfig.PVE_VARIANCE_MIN)
end

local function playerActs(state: State, action: Action)
	local me = state.team[state.active]
	if action.kind == "Switch" then
		state.active = action.to
		note(state, `{state.team[action.to].creature.id} takes the front`)
	elseif action.kind == "Item" then
		local target = state.team[action.target]
		state.itemsUsed += 1
		if action.effect.kind == "Heal" then
			local gain = math.floor(target.stats.Hp * action.effect.share)
			target.hp = math.min(target.stats.Hp, target.hp + gain)
		else
			target.hp = math.max(1, math.floor(target.stats.Hp * action.effect.share))
		end
		note(state, `{action.name} on {target.creature.id}`)
	else
		local damage = math.max(
			1,
			math.floor(Battle.previewDamage(me, state.boss, action.move) * variance(state))
		)
		state.boss.hp = math.max(0, state.boss.hp - damage)
		note(state, `{me.creature.id} uses {action.move} for {damage}`)
		-- A weak-point hit while the big attack is charged interrupts it.
		local charged = state.charged
		local element: Types.Element = Moves[action.move].element
		if charged and TypeChart.isStrong(element, state.giant.element) then
			charged.interrupted = true
			note(
				state,
				`The {action.move} hits the weak point of {state.giant.attacks[charged.attack].name}`
			)
		end
	end
end

local function hit(state: State, target: Fighter, attackId: string, share: number)
	local raw = attackDamage(state, attackId, target, state.turn)
	local damage = math.max(1, math.floor(raw * share * variance(state)))
	target.hp = math.max(0, target.hp - damage)
	note(
		state,
		`{state.giant.name}'s {state.giant.attacks[attackId].name} hits {target.creature.id} for {damage}`
	)
end

local function giantActs(state: State)
	local intent = state.intent
	local attack = state.giant.attacks[intent.attack]
	if intent.kind == "WindUp" then
		state.charged = { attack = intent.attack, interrupted = false }
		note(state, `{state.giant.name}: {intent.text}`)
		return
	end
	local share = 1
	local charged = state.charged
	if intent.kind == "Release" and charged and charged.interrupted then
		if attack.whenInterrupted == "Cancel" then
			state.charged = nil
			note(state, `{attack.name} is stopped`)
			return
		end
		share = GiantConfig.HALVE_SHARE
		note(state, `{attack.name} is weakened`)
	end
	if attack.target == "Team" then
		for _, fighter in state.team do
			if fighter.hp > 0 then
				hit(state, fighter, intent.attack, share)
			end
		end
	else
		hit(state, state.team[state.active], intent.attack, share)
	end
	state.charged = nil
end

local function advance(state: State)
	local giant = state.giant
	-- phase check, from the health left after this turn
	local share = state.boss.hp / giant.stats.Hp
	local changed = false
	for index = state.phase + 1, #giant.phases do
		if share <= giant.phases[index].enterAt then
			state.phase = index
			changed = true
			note(state, giant.phases[index].enterText)
		end
	end
	if changed then
		state.patternIndex = 0
	end
	local nextTurn = state.turn + 1
	if state.intent.kind == "WindUp" then
		state.intent = makeIntent(state, state.intent.attack, "Release", nextTurn)
		return
	end
	local pattern = giant.phases[state.phase].pattern
	state.patternIndex = state.patternIndex % #pattern + 1
	local id = pattern[state.patternIndex]
	state.intent =
		makeIntent(state, id, if giant.attacks[id].windUp then "WindUp" else "Attack", nextTurn)
end

-- Resolves one turn: the player's action, then the giant does what its intent said.
function GiantBattle.step(state: State, requested: Action)
	if state.winner then
		return
	end
	local action = validAction(state, requested)
	table.insert(state.history, action)
	state.turn += 1
	playerActs(state, action)
	if state.boss.hp == 0 then
		note(state, `{state.giant.name} falls`)
		state.winner = "Player"
		return
	end
	local standing: { boolean } = {}
	for index, fighter in state.team do
		standing[index] = fighter.hp > 0
	end
	giantActs(state)
	for index, fighter in state.team do
		if standing[index] and fighter.hp == 0 then
			note(state, `{fighter.creature.id} faints`)
		end
	end
	if state.team[state.active].hp == 0 then
		local nextIndex = firstAlive(state.team)
		if nextIndex then
			state.active = nextIndex
		else
			state.winner = "Giant"
			return
		end
	end
	if state.turn >= GiantConfig.MAX_TURNS then
		state.winner = "Giant"
		return
	end
	advance(state)
end

-- Plays a fight again from nothing: a fresh team, the seed and the player's chosen actions.
function GiantBattle.replay(
	def: GiantDef,
	makeTeam: () -> { Fighter },
	seed: number,
	actions: { Action }
): State
	local state = GiantBattle.new(def, makeTeam(), seed)
	for _, action in actions do
		GiantBattle.step(state, action)
	end
	return state
end

return GiantBattle
