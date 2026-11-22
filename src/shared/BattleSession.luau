--!strict
-- One player's battle against the game, as the server runs it: start it, take the player's one
-- choice each turn, and say what happened in the form the screen needs.
--
-- This is pure (no Roblox services), so the same code is tested under Lune and wrapped by the
-- battle service on the server. Nothing from the player's device is trusted: a choice is checked
-- against the battle's own state, and anything that does not fit is refused, never guessed at.

local Battle = require("./Battle")
local BattleAi = require("./BattleAi")
local BattleConfig = require("../config/BattleConfig")
local Rng = require("./Rng")
local Stats = require("./Stats")
local Types = require("./Types")
local Xp = require("./Xp")

export type Kind = "Wild" | "Tamer" | "Rival" | "Friendly"
export type ActionKind = "Move" | "Switch" | "Run"

export type StartInput = {
	battleId: number,
	kind: Kind,
	yours: { Types.Creature }, -- the player's team, in order
	theirs: { Types.Creature },
	theirMoves: { { string } }?, -- chosen moves for each opposing creature (tamers); nil = default
	tier: BattleAi.Tier,
	seed: number,
	levelCap: number, -- the player's cap: their creatures above it fight at the cap
	-- A battle the story does not let the player lose (the rival's first): whenever their last
	-- creature would fall it holds on with 1 health, and the battle goes on until they win.
	cannotLose: boolean?,
}

export type CreatureView = {
	id: string,
	bodyPlan: Types.BodyPlan,
	parts: Types.BySlot<string>, -- species of each part, for drawing
	colour: string,
	size: number,
	rarity: Types.Rarity,
	element: Types.Element,
	level: number,
	maxHp: number,
	hp: number,
	moves: { string }, -- empty for the opponent's creatures
}

export type Started = {
	battleId: number,
	kind: Kind,
	yours: { CreatureView },
	theirs: { CreatureView },
	previews: { number }, -- damage each of the active creature's moves would do now
}

export type TurnResult = {
	battleId: number,
	turn: number,
	events: { Battle.Event },
	yourActive: number,
	theirActive: number,
	yourTempo: number, -- 0..100
	theirTempo: number,
	previews: { number },
	finished: boolean,
	outcome: number, -- 0 ongoing or a draw, 1 the player won, 2 the player lost or ran
	ran: boolean,
}

-- How a battle ended, for the world and the rewards: a caught or fled creature is gone, one the
-- player ran from or lost to is still there.
export type Ending = "Won" | "Lost" | "Draw" | "Ran" | "Caught" | "Fled"

export type Session = {
	battleId: number,
	kind: Kind,
	state: Battle.State,
	chooser: BattleAi.Chooser,
	ran: boolean,
	caught: boolean?, -- set by endCaught
	fled: boolean?, -- set by endFled
	cannotLose: boolean?,
}

local BattleSession = {}

local PLAYER, FOE = 1, 2

local function view(fighter: Battle.Fighter, showMoves: boolean): CreatureView
	local creature = fighter.creature
	return {
		id = creature.id,
		bodyPlan = creature.bodyPlan,
		parts = {
			Head = creature.parts.Head.species,
			Torso = creature.parts.Torso.species,
			FrontLimbs = creature.parts.FrontLimbs.species,
			Legs = creature.parts.Legs.species,
			Tail = creature.parts.Tail.species,
		},
		colour = creature.colour.shown,
		size = creature.size,
		rarity = creature.rarity,
		element = fighter.element,
		level = fighter.level,
		maxHp = fighter.stats.Hp,
		hp = fighter.hp,
		moves = if showMoves then table.clone(fighter.moves) else {},
	}
end

local function previews(state: Battle.State): { number }
	local me = state.sides[PLAYER].team[state.sides[PLAYER].active]
	local foe = state.sides[FOE].team[state.sides[FOE].active]
	local list = {}
	for _, move in me.moves do
		table.insert(list, Battle.previewDamage(me, foe, move))
	end
	return list
end

-- Health carried in from the creature's record: a hurt creature starts hurt, a fainted one
-- starts down. A creature with any health left starts with at least 1.
local function carryIn(fighter: Battle.Fighter)
	local hurt = fighter.creature.hurt
	if hurt == nil or hurt ~= hurt or hurt <= 0 then
		return
	end
	local full = fighter.stats.Hp
	fighter.hp = if hurt >= 1 then 0 else math.clamp(math.floor(full * (1 - hurt) + 0.5), 1, full)
end
BattleSession.carryIn = carryIn

-- Health written back to the creature's record, so damage lasts after the battle.
local function carryOut(fighter: Battle.Fighter)
	local full = math.max(1, fighter.stats.Hp)
	if fighter.hp >= full then
		fighter.creature.hurt = nil
	elseif fighter.hp <= 0 then
		fighter.creature.hurt = 1
	else
		fighter.creature.hurt = 1 - fighter.hp / full
	end
end
BattleSession.carryOut = carryOut

local function firstStanding(team: { Battle.Fighter }): number?
	for index, fighter in team do
		if fighter.hp > 0 then
			return index
		end
	end
	return nil
end

-- Starts a battle. Returns nil and a reason if the teams cannot fight.
function BattleSession.start(input: StartInput): (Session?, string?)
	if #input.yours < 1 or #input.yours > 6 then
		return nil, "You need between one and six creatures on your team"
	end
	if #input.theirs < 1 or #input.theirs > 6 then
		return nil, "Bad opponent"
	end
	local yours: { Battle.Fighter } = {}
	for _, creature in input.yours do
		local level = Xp.battleLevel(creature.level, input.levelCap)
		table.insert(yours, Battle.fighter(creature, nil, level))
	end
	local theirs: { Battle.Fighter } = {}
	for index, creature in input.theirs do
		local moves: { string }? = if input.theirMoves then input.theirMoves[index] else nil
		if not moves and input.tier == "Wild" then
			-- A wild creature keeps its natural move order, so "mostly the first move" is a
			-- plain attack and not its calculated best.
			local natural = Stats.movePool(creature)
			while #natural > 4 do
				table.remove(natural)
			end
			moves = natural
		end
		table.insert(theirs, Battle.fighter(creature, moves, creature.level))
	end
	-- Damage lasts between battles (never in friendly battles, which start everyone fresh).
	local state = Battle.new(yours, theirs, input.seed, false)
	if input.kind ~= "Friendly" then
		for _, fighter in yours do
			carryIn(fighter)
		end
		for _, fighter in theirs do
			carryIn(fighter)
		end
	end
	local mine, foe = firstStanding(yours), firstStanding(theirs)
	if not mine then
		return nil, "Your creatures need healing first"
	elseif not foe then
		return nil, "Bad opponent"
	end
	state.sides[PLAYER].active, state.sides[FOE].active = mine, foe
	return {
		battleId = input.battleId,
		kind = input.kind,
		state = state,
		chooser = BattleAi.forTier(input.tier, Rng.new(input.seed + 1)),
		ran = false,
		cannotLose = input.cannotLose,
	},
		nil
end

-- What the player's screen is told when the battle begins.
function BattleSession.started(session: Session): Started
	local yours, theirs = {}, {}
	for _, fighter in session.state.sides[PLAYER].team do
		table.insert(yours, view(fighter, true))
	end
	for _, fighter in session.state.sides[FOE].team do
		table.insert(theirs, view(fighter, false))
	end
	return {
		battleId = session.battleId,
		kind = session.kind,
		yours = yours,
		theirs = theirs,
		previews = previews(session.state),
	}
end

-- In a battle that cannot be lost: if the turn just played would have beaten the player (or
-- ended in a draw), their last creature holds on with 1 health and the battle goes on. If the
-- battle has run to its turn limit, the opponent gives up.
local function holdOn(session: Session)
	local state = session.state
	if not session.cannotLose or state.winner == nil or state.winner == PLAYER then
		return
	end
	-- Both sides fell on the same turn, or the turn limit was reached: the opponent has nothing
	-- left to fight with (or gives up), so the player wins outright.
	if state.winner == 0 or state.turn >= BattleConfig.MAX_TURNS then
		state.winner = PLAYER
		return
	end
	local side = state.sides[PLAYER]
	local fighter = side.team[side.active]
	fighter.hp = 1
	state.winner = nil
	local event: Battle.Event = {
		turn = state.turn,
		side = PLAYER,
		text = `{fighter.creature.id} holds on`,
		kind = "Endure",
		damage = 0,
		targetHp = 1,
		slot = side.active,
	}
	table.insert(state.log, event)
end

local function result(session: Session, fromLog: number): TurnResult
	holdOn(session)
	local state = session.state
	-- After every turn: leaving a battle part way never undoes the damage taken in it.
	if session.kind ~= "Friendly" then
		for _, side in state.sides do
			for _, fighter in side.team do
				carryOut(fighter)
			end
		end
	end
	local events: { Battle.Event } = {}
	for index = fromLog, #state.log do
		table.insert(events, state.log[index])
	end
	local mine, foe = state.sides[PLAYER], state.sides[FOE]
	local lost = session.ran or state.winner == FOE
	local outcome = if lost then 2 elseif state.winner == PLAYER then 1 else 0
	local finished = session.ran or state.winner ~= nil
	return {
		battleId = session.battleId,
		turn = state.turn,
		events = events,
		yourActive = mine.active,
		theirActive = foe.active,
		yourTempo = math.clamp(math.floor(mine.team[mine.active].tempo * 100), 0, 100),
		theirTempo = math.clamp(math.floor(foe.team[foe.active].tempo * 100), 0, 100),
		previews = if finished then {} else previews(state),
		finished = finished,
		outcome = outcome,
		ran = session.ran,
	}
end

-- Takes the player's choice for a turn. `turn` is the turn the player thinks it is (the last
-- finished turn plus one); a stale or repeated message is refused, so a choice can never be
-- applied twice. `index` is a move number (1..4) or a team position (1..6).
-- Returns the turn's result, or nil and a reason.
function BattleSession.act(
	session: Session,
	turn: unknown,
	kind: unknown,
	index: unknown
): (TurnResult?, string?)
	local state = session.state
	if session.ran or state.winner ~= nil then
		return nil, "The battle is over"
	end
	if typeof(turn) ~= "number" or turn ~= state.turn + 1 then
		return nil, "That turn has already been played"
	end
	if typeof(index) ~= "number" or index % 1 ~= 0 then
		return nil, "Bad choice"
	end
	local mine = state.sides[PLAYER]
	local logStart = #state.log + 1

	if kind == "Run" then
		if session.kind ~= "Wild" then
			return nil, "You cannot run from this battle"
		end
		session.ran = true
		return result(session, logStart), nil
	end

	local action: Battle.Action
	if kind == "Move" then
		local move = mine.team[mine.active].moves[index]
		if not move then
			return nil, "That creature does not know that move"
		end
		action = { kind = "Move", move = move }
	elseif kind == "Switch" then
		local target = mine.team[index]
		if not target or target.hp <= 0 or index == mine.active then
			return nil, "You cannot switch to that creature"
		end
		action = { kind = "Switch", to = index }
	else
		return nil, "Bad choice"
	end

	Battle.step(state, action, session.chooser(state, FOE))
	return result(session, logStart), nil
end

-- The player spends this turn on something outside the battle (a lasso throw that missed, an
-- item); the opponent still acts. Same turn check as `act`.
function BattleSession.pass(session: Session, turn: unknown): (TurnResult?, string?)
	local state = session.state
	if session.ran or state.winner ~= nil then
		return nil, "The battle is over"
	end
	if typeof(turn) ~= "number" or turn ~= state.turn + 1 then
		return nil, "That turn has already been played"
	end
	local logStart = #state.log + 1
	Battle.step(state, { kind = "Pass" }, session.chooser(state, FOE))
	return result(session, logStart), nil
end

export type FieldItem = "Tonic" | "GreatTonic" | "Revive"
local FIELD_ITEMS: { FieldItem } = { "Tonic", "GreatTonic", "Revive" }

function BattleSession.parseFieldItem(value: unknown): FieldItem?
	for _, item: FieldItem in FIELD_ITEMS do
		if item == value then
			return item
		end
	end
	return nil
end

-- What can be used in a battle against the game: the field items, plus Clearwater Drops, which
-- cures poison. Giants never poison, so a giant fight and healing outside battle take only field
-- items (parseFieldItem).
export type BattleItem = FieldItem | "Cure"

function BattleSession.parseBattleItem(value: unknown): BattleItem?
	if value == "Cure" then
		return "Cure"
	end
	return BattleSession.parseFieldItem(value)
end

-- Logs an item used on the player's creature at team position `target`, then lets the opponent
-- act: using an item spends the turn. `cured` adds the "Cured" event the screen shows.
local function finishItem(
	session: Session,
	item: string,
	fighter: Battle.Fighter,
	target: number,
	cured: boolean
): TurnResult
	local state = session.state
	local logStart = #state.log + 1
	local event: Battle.Event = {
		turn = state.turn + 1,
		side = PLAYER,
		text = `{item} on {fighter.creature.id}`,
		kind = "Item",
		move = item,
		damage = 0,
		targetHp = fighter.hp,
		slot = target,
	}
	table.insert(state.log, event)
	if cured then
		table.insert(state.log, {
			turn = state.turn + 1,
			side = PLAYER,
			text = `{fighter.creature.id} is cured`,
			kind = "Cured",
			move = item,
			damage = 0,
			targetHp = fighter.hp,
			slot = target,
		})
	end
	Battle.step(state, { kind = "Pass" }, session.chooser(state, FOE))
	return result(session, logStart)
end

-- Uses a tonic, a Rally Root or Clearwater Drops on one of the player's creatures. It spends the turn: the
-- opponent still acts. A tonic needs a standing creature that is hurt; a Rally Root needs a
-- fallen one. `target` is a team position. Returns the turn's result, or nil and a reason.
function BattleSession.useItem(
	session: Session,
	turn: unknown,
	item: BattleItem,
	target: unknown
): (TurnResult?, string?)
	local state = session.state
	if session.ran or state.winner ~= nil then
		return nil, "The battle is over"
	end
	if typeof(turn) ~= "number" or turn ~= state.turn + 1 then
		return nil, "That turn has already been played"
	end
	if session.kind == "Friendly" then
		return nil, "Items cannot be used in this battle"
	end
	if typeof(target) ~= "number" or target % 1 ~= 0 then
		return nil, "Bad choice"
	end
	local fighter = state.sides[PLAYER].team[target]
	if not fighter then
		return nil, "Bad choice"
	end
	local full = fighter.stats.Hp
	local field = BattleSession.parseFieldItem(item)
	if not field then
		-- Clearwater Drops: a standing, poisoned creature is cured at once.
		if fighter.hp <= 0 then
			return nil, "That creature has fainted"
		elseif (fighter.poison or 0) <= 0 then
			return nil, "That creature is not poisoned"
		end
		fighter.poison = nil
		return finishItem(session, item, fighter, target, true)
	end
	local effect = BattleConfig.FIELD_ITEMS[field]
	if effect.kind == "Heal" then
		if fighter.hp <= 0 then
			return nil, "That creature has fainted"
		elseif fighter.hp >= full then
			return nil, "That creature is not hurt"
		end
		fighter.hp = math.min(full, fighter.hp + math.max(1, math.floor(full * effect.share)))
	else
		if fighter.hp > 0 then
			return nil, "That creature has not fainted"
		end
		fighter.hp = math.max(1, math.floor(full * effect.share))
	end
	return finishItem(session, item, fighter, target, false)
end

-- The opponent's active creature, for the lasso: its creature record and share of health left.
function BattleSession.foe(session: Session): (Types.Creature, number)
	local side = session.state.sides[FOE]
	local fighter = side.team[side.active]
	return fighter.creature, fighter.hp / math.max(1, fighter.stats.Hp)
end

-- Ends a wild battle because its creature was caught. Counts as a win for the turn result.
function BattleSession.endCaught(session: Session): TurnResult
	local state = session.state
	state.winner = PLAYER
	session.caught = true
	return result(session, #state.log + 1)
end

-- Marks a wild battle as over because its creature fled after too many missed throws.
function BattleSession.endFled(session: Session)
	session.ran = true
	session.fled = true
end

-- How the battle ended, or nil while it is still going.
function BattleSession.ending(session: Session): Ending?
	local winner = session.state.winner
	local ending: Ending? = nil
	if session.fled then
		ending = "Fled"
	elseif session.ran then
		ending = "Ran"
	elseif session.caught then
		ending = "Caught"
	elseif winner == PLAYER then
		ending = "Won"
	elseif winner == FOE then
		ending = "Lost"
	elseif winner ~= nil then
		ending = "Draw"
	end
	return ending
end

return BattleSession
