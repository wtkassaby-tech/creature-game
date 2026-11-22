--!strict
-- Turn-based battle core as pure functions: one active creature per side, both sides choose,
-- switches happen first, then moves in Speed order. No Roblox services, so the server and the
-- Lune tests run the same code, and a battle can be replayed from its seed and the chosen actions.

local BattleConfig = require("../config/BattleConfig")
local Moves = require("../content/Moves")
local Rng = require("./Rng")
local Species = require("../content/Species")
local Stats = require("./Stats")
local TypeChart = require("./TypeChart")
local Types = require("./Types")

export type Fighter = {
	creature: Types.Creature,
	element: Types.Element,
	level: number, -- the level the stats were worked out at; damage scales with it
	stats: Stats.StatBlock,
	hp: number,
	tempo: number, -- 0..1, fills while this creature is the faster one
	moves: { string },
	poison: number?, -- turns of poison left; nil or 0 when not poisoned
}
export type Side = { team: { Fighter }, active: number }
-- "Pass" spends the turn doing nothing in the battle itself: a lasso throw or an item uses it.
export type Action =
	{ kind: "Move", move: string }
	| { kind: "Switch", to: number }
	| { kind: "Pass" }
export type EventKind =
	"Move"
	| "FollowUp"
	| "Switch"
	| "Faint"
	| "Item"
	| "Endure"
	| "Poisoned" -- a creature has just been poisoned
	| "Poison" -- poison hurt it at the end of the turn
	| "Cured" -- the poison wore off
-- One thing that happened in a turn. `text` is for logs; the other fields are what the
-- player's screen needs to replay it. `side` is who acted (for a faint, whose creature fell).
export type Event = {
	turn: number,
	side: number,
	text: string,
	kind: EventKind,
	move: string?, -- Move and FollowUp; for Item, the item's id
	damage: number?, -- Move and FollowUp
	targetHp: number?, -- the struck creature's health afterwards
	-- Switch: the position now active; Faint: the one that fell; Item: the one treated;
	-- Endure: the one that held on with 1 health in a battle that cannot be lost;
	-- Poisoned, Poison and Cured: the creature it happened to (and `side` is its side).
	slot: number?,
}
export type State = {
	sides: { Side },
	turn: number,
	ranked: boolean,
	rng: Rng.Rng,
	log: { Event },
	winner: number?, -- 1 or 2 once the battle is over; 0 for a draw
}

local Battle = {}

function Battle.fighter(creature: Types.Creature, moves: { string }?, level: number?): Fighter
	local stats = Stats.compute(creature, level)
	local chosen = moves or Battle.bestMoves(creature, level)
	return {
		creature = creature,
		element = Species[creature.parts.Torso.species].element,
		level = level or creature.level,
		stats = stats,
		hp = stats.Hp,
		tempo = 0,
		moves = chosen,
	}
end

-- Default move choice: the strongest four from the creature's parts, own-type bonus included.
function Battle.bestMoves(creature: Types.Creature, level: number?): { string }
	local element = Species[creature.parts.Torso.species].element
	local pool = Stats.movePool(creature, level)
	local function value(name: string): number
		local move = Moves[name]
		return move.power * (if move.element == element then TypeChart.OWN_TYPE_MULTIPLIER else 1)
	end
	table.sort(pool, function(a, b)
		local va, vb = value(a), value(b)
		return if va == vb then a < b else va > vb
	end)
	local chosen = {}
	for index = 1, math.min(BattleConfig.MAX_MOVES, #pool) do
		chosen[index] = pool[index]
	end
	-- A poisoning move hits softer than the plain moves beside it, so power alone would drop it.
	-- The default four keep the best poisoning move the creature knows, in place of its weakest
	-- plain move, so breeding for poison is a real choice. Players can still pick their own four.
	local hasPoison = false
	for _, name in chosen do
		hasPoison = hasPoison or Moves[name].effect == "Poison"
	end
	if not hasPoison and #chosen == BattleConfig.MAX_MOVES then
		for index = #chosen + 1, #pool do
			if Moves[pool[index]].effect == "Poison" then
				chosen[#chosen] = pool[index]
				break
			end
		end
	end
	return chosen
end

function Battle.new(teamA: { Fighter }, teamB: { Fighter }, seed: number, ranked: boolean): State
	return {
		sides = { { team = teamA, active = 1 }, { team = teamB, active = 1 } },
		turn = 0,
		ranked = ranked,
		rng = Rng.new(seed),
		log = {},
		winner = nil,
	}
end

local function active(state: State, side: number): Fighter
	local s = state.sides[side]
	return s.team[s.active]
end

-- Damage before variance: what the move button shows the player.
function Battle.previewDamage(attacker: Fighter, defender: Fighter, moveName: string): number
	local move = Moves[moveName]
	local ratio = attacker.stats.Attack / (attacker.stats.Attack + defender.stats.Defence)
	local own = if move.element == attacker.element then TypeChart.OWN_TYPE_MULTIPLIER else 1
	local matchup = TypeChart.multiplier(move.element, defender.element)
	return math.max(
		1,
		math.floor(
			BattleConfig.DAMAGE_SCALE
				* Stats.levelScale(attacker.level)
				* move.power
				* ratio
				* own
				* matchup
		)
	)
end

-- Would this move poison `defender` if it hit now?
function Battle.wouldPoison(defender: Fighter, moveName: string): boolean
	return Moves[moveName].effect == "Poison"
		and (defender.poison or 0) == 0
		and defender.element ~= BattleConfig.POISON_IMMUNE_ELEMENT
end

-- What one tick of poison takes from a creature.
function Battle.poisonDamage(fighter: Fighter): number
	return math.max(1, math.floor(fighter.stats.Hp * BattleConfig.POISON_SHARE))
end

-- What a move is worth to a simple opponent: its damage now, plus the damage its poison would
-- go on to do (never more than the health the hit leaves). A move with no effect is worth
-- exactly its damage, so opponents choose as they always have where nothing poisons.
function Battle.moveValue(attacker: Fighter, defender: Fighter, moveName: string): number
	local value = Battle.previewDamage(attacker, defender, moveName)
	if Battle.wouldPoison(defender, moveName) then
		local later = Battle.poisonDamage(defender) * BattleConfig.POISON_TURNS
		value += math.min(later, math.max(0, defender.hp - value))
	end
	return value
end

-- A simple opponent: use the move that is worth the most right now.
function Battle.chooseAction(state: State, side: number): Action
	local me, foe = active(state, side), active(state, 3 - side)
	local best, bestDamage = me.moves[1], -1
	for _, name in me.moves do
		local damage = Battle.moveValue(me, foe, name)
		if damage > bestDamage then
			best, bestDamage = name, damage
		end
	end
	return { kind = "Move", move = best }
end

local function firstAlive(side: Side): number?
	for index, fighter in side.team do
		if fighter.hp > 0 then
			return index
		end
	end
	return nil
end

-- Which side moves first this turn, or 0 when the Speeds are close enough that both land together.
function Battle.firstMover(state: State): number
	local a, b = active(state, 1).stats.Speed, active(state, 2).stats.Speed
	local high, low = math.max(a, b), math.min(a, b)
	if high <= low * (1 + BattleConfig.SPEED_BAND) then
		return 0
	end
	return if a > b then 1 else 2
end

local function note(
	state: State,
	side: number,
	kind: EventKind,
	text: string,
	move: string?,
	damage: number?,
	targetHp: number?,
	slot: number?
)
	table.insert(state.log, {
		turn = state.turn,
		side = side,
		text = text,
		kind = kind,
		move = move,
		damage = damage,
		targetHp = targetHp,
		slot = slot,
	})
end

local function validate(state: State, side: number, action: Action): Action
	local s = state.sides[side]
	if action.kind == "Pass" then
		return action
	elseif action.kind == "Switch" then
		local target = s.team[action.to]
		if target and target.hp > 0 and action.to ~= s.active then
			return action
		end
	elseif table.find(s.team[s.active].moves, action.move) then
		return action
	end
	return Battle.chooseAction(state, side) -- an invalid choice is replaced, never trusted
end

-- Resolves one turn from both sides' chosen actions.
function Battle.step(state: State, actionA: Action, actionB: Action)
	if state.winner then
		return
	end
	state.turn += 1
	local actions = { validate(state, 1, actionA), validate(state, 2, actionB) }

	for side = 1, 2 do
		local action = actions[side]
		if action.kind == "Switch" then
			state.sides[side].active = action.to
			note(
				state,
				side,
				"Switch",
				`switches to {active(state, side).creature.id}`,
				nil,
				nil,
				nil,
				action.to
			)
		end
	end

	local function strike(side: number, moveName: string, power: number, label: string)
		local me, foe = active(state, side), active(state, 3 - side)
		local damage = math.max(1, math.floor(Battle.previewDamage(me, foe, moveName) * power))
		if not state.ranked then
			local variance = BattleConfig.PVE_VARIANCE_MIN
				+ Rng.next(state.rng) * (1 - BattleConfig.PVE_VARIANCE_MIN)
			damage = math.max(1, math.floor(damage * variance))
		end
		foe.hp = math.max(0, foe.hp - damage)
		local kind: EventKind = if power < 1 then "FollowUp" else "Move"
		note(
			state,
			side,
			kind,
			`{me.creature.id} {label} {moveName} for {damage}`,
			moveName,
			damage,
			foe.hp
		)
		if foe.hp > 0 and Battle.wouldPoison(foe, moveName) then
			foe.poison = BattleConfig.POISON_TURNS
			note(
				state,
				3 - side,
				"Poisoned",
				`{foe.creature.id} is poisoned`,
				moveName,
				nil,
				foe.hp,
				state.sides[3 - side].active
			)
		end
	end

	local first = Battle.firstMover(state)
	local order: { number } = if first == 0 then { 1, 2 } else { first, 3 - first }
	-- Within the Speed band both moves land together: a creature that faints this turn still strikes.
	local aliveAtStart = { active(state, 1).hp > 0, active(state, 2).hp > 0 }
	for _, side in order do
		local action = actions[side]
		local canAct = if first == 0 then aliveAtStart[side] else active(state, side).hp > 0
		if action.kind == "Move" and canAct and (first == 0 or active(state, 3 - side).hp > 0) then
			strike(side, action.move, 1, "uses")
		end
	end

	-- Tempo: the faster creature builds toward an extra strike. Switching in resets the meter.
	for side = 1, 2 do
		local me, foe = active(state, side), active(state, 3 - side)
		local action = actions[side]
		if action.kind == "Switch" then
			me.tempo = 0
		elseif
			action.kind == "Move"
			and me.hp > 0
			and foe.hp > 0
			and me.stats.Speed > foe.stats.Speed
		then
			me.tempo += (me.stats.Speed / foe.stats.Speed - 1) * BattleConfig.TEMPO_GAIN
			if me.tempo >= 1 then
				me.tempo -= 1
				strike(side, action.move, BattleConfig.TEMPO_POWER, "follows up with")
			end
		end
	end

	-- Poison: each active creature that is poisoned and still standing loses a share of its
	-- full health, and the poison runs down by a turn.
	for side = 1, 2 do
		local fighter = active(state, side)
		local left = fighter.poison or 0
		if fighter.hp > 0 and left > 0 then
			local damage = Battle.poisonDamage(fighter)
			fighter.hp = math.max(0, fighter.hp - damage)
			fighter.poison = left - 1
			local slot = state.sides[side].active
			note(
				state,
				side,
				"Poison",
				`{fighter.creature.id} is hurt by poison for {damage}`,
				nil,
				damage,
				fighter.hp,
				slot
			)
			if left == 1 and fighter.hp > 0 then
				note(
					state,
					side,
					"Cured",
					`{fighter.creature.id} shakes off the poison`,
					nil,
					nil,
					fighter.hp,
					slot
				)
			end
		end
	end

	for side = 1, 2 do
		if active(state, side).hp == 0 then
			-- Fainting ends the poison: a creature brought back with an item, or one that holds
			-- on in a battle that cannot be lost, starts clean.
			active(state, side).poison = nil
			note(
				state,
				side,
				"Faint",
				`{active(state, side).creature.id} faints`,
				nil,
				nil,
				nil,
				state.sides[side].active
			)
		end
	end

	local out = { false, false }
	for side = 1, 2 do
		if active(state, side).hp == 0 then
			local nextIndex = firstAlive(state.sides[side])
			if nextIndex then
				state.sides[side].active = nextIndex
			else
				out[side] = true
			end
		end
	end
	if out[1] and out[2] then
		state.winner = 0 -- both last creatures fell together: a draw
	elseif out[1] or out[2] then
		state.winner = if out[1] then 2 else 1
	end

	if not state.winner and state.turn >= BattleConfig.MAX_TURNS then
		local function share(side: Side): number
			local hp, max = 0, 0
			for _, fighter in side.team do
				hp += fighter.hp
				max += fighter.stats.Hp
			end
			return hp / max
		end
		state.winner = if share(state.sides[1]) >= share(state.sides[2]) then 1 else 2
	end
end

-- Plays a whole battle with the simple opponent on both sides.
function Battle.autoPlay(state: State): State
	while not state.winner do
		Battle.step(state, Battle.chooseAction(state, 1), Battle.chooseAction(state, 2))
	end
	return state
end

return Battle
