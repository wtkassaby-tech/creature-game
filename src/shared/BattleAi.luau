--!strict
-- Who chooses what for the side the game controls, as pure functions of the battle state.
-- Three tiers: Wild (simple), Tamer (medium), Rival (one step ahead). Deterministic given the state
-- and any Rng passed in, so a battle replays. These only build Actions; the rules are in Battle.luau.

local AiConfig = require("../config/AiConfig")
local Battle = require("./Battle")
local BattleConfig = require("../config/BattleConfig")
local Rng = require("./Rng")

export type Tier = "Wild" | "Tamer" | "Rival"
export type Chooser = (state: Battle.State, side: number) -> Battle.Action

local BattleAi = {}

local function activeOf(state: Battle.State, side: number): Battle.Fighter
	local s = state.sides[side]
	return s.team[s.active]
end

local function moveAction(name: string): Battle.Action
	return { kind = "Move", move = name }
end

-- Wild --------------------------------------------------------------------------------------

-- Wild creatures never switch and never calculate. With an Rng: mostly the first move, sometimes
-- another. Without: a fixed rotation read from the turn number.
function BattleAi.wild(state: Battle.State, side: number, rng: Rng.Rng?): Battle.Action
	local moves = activeOf(state, side).moves
	local count = #moves
	if rng then
		if count == 1 or Rng.chance(rng, AiConfig.WILD_FIRST_MOVE_CHANCE) then
			return moveAction(moves[1])
		end
		return moveAction(moves[Rng.int(rng, 2, count)])
	end
	local rotation = AiConfig.WILD_ROTATION
	local position = rotation[state.turn % #rotation + 1]
	return moveAction(moves[(position - 1) % count + 1])
end

-- Shared helpers ----------------------------------------------------------------------------

-- Best move of `me` against `foe` (its damage now plus what its poison would do); ties go to
-- the earlier move.
local function bestMove(me: Battle.Fighter, foe: Battle.Fighter): (string, number)
	local best, bestDamage = me.moves[1], -1
	for _, name in me.moves do
		local damage = Battle.moveValue(me, foe, name)
		if damage > bestDamage then
			best, bestDamage = name, damage
		end
	end
	return best, bestDamage
end

-- Match-up score from `me`'s side, using current health: -1 hopeless to 1 winning.
local function matchup(me: Battle.Fighter, foe: Battle.Fighter): number
	local _, mine = bestMove(me, foe)
	local _, theirs = bestMove(foe, me)
	return math.min(1, mine / foe.hp) - math.min(1, theirs / me.hp)
end

-- True when this side switched within the cooldown, read from the battle log so the rule needs no
-- stored state. Forced replacements after a faint are not logged and do not count.
local function switchedRecently(state: Battle.State, side: number, window: number): boolean
	local upcoming = state.turn + 1
	for index = #state.log, 1, -1 do
		local event = state.log[index]
		if event.turn <= upcoming - window then
			break
		end
		if event.side == side and string.sub(event.text, 1, 12) == "switches to " then
			return true
		end
	end
	return false
end

local function livingBench(state: Battle.State, side: number): { number }
	local s = state.sides[side]
	local list = {}
	for index, fighter in s.team do
		if index ~= s.active and fighter.hp > 0 then
			table.insert(list, index)
		end
	end
	return list
end

-- The tamer's switch rule: a clear disadvantage and a clearly better team-mate, outside the cooldown.
local function matchupSwitch(state: Battle.State, side: number): number?
	if switchedRecently(state, side, AiConfig.SWITCH_COOLDOWN_TURNS) then
		return nil
	end
	local me, foe = activeOf(state, side), activeOf(state, 3 - side)
	local current = matchup(me, foe)
	if current >= -AiConfig.SWITCH_DISADVANTAGE then
		return nil
	end
	local bestIndex, bestScore = nil, current + AiConfig.SWITCH_MARGIN - 1e-9
	for _, index in livingBench(state, side) do
		local score = matchup(state.sides[side].team[index], foe)
		if score > bestScore then
			bestIndex, bestScore = index, score
		end
	end
	return bestIndex
end

-- Tamer -------------------------------------------------------------------------------------

function BattleAi.tamer(state: Battle.State, side: number): Battle.Action
	local to = matchupSwitch(state, side)
	if to then
		return { kind = "Switch", to = to }
	end
	return Battle.chooseAction(state, side)
end

-- Rival -------------------------------------------------------------------------------------

-- 1 when `me` moves first, 2 when `foe` does, 0 when both land together (the Speed band).
local function moveOrder(meSpeed: number, foeSpeed: number): number
	local high, low = math.max(meSpeed, foeSpeed), math.min(meSpeed, foeSpeed)
	if high <= low * (1 + BattleConfig.SPEED_BAND) then
		return 0
	end
	return if meSpeed > foeSpeed then 1 else 2
end

-- Damage of a move as the battle will deal it. `variance` is the roll we plan for: the lowest for
-- our own strikes (a knock-out must hold up), the highest for the foe's (be ready for the worst).
local function strikeDamage(
	state: Battle.State,
	attacker: Battle.Fighter,
	defender: Battle.Fighter,
	move: string,
	power: number,
	variance: number
): number
	local damage = math.max(1, math.floor(Battle.previewDamage(attacker, defender, move) * power))
	if not state.ranked then
		damage = math.max(1, math.floor(damage * variance))
	end
	return damage
end

local function bestStrike(
	state: Battle.State,
	attacker: Battle.Fighter,
	defender: Battle.Fighter,
	power: number,
	variance: number
): number
	local best = 0
	for _, name in attacker.moves do
		best = math.max(best, strikeDamage(state, attacker, defender, name, power, variance))
	end
	return best
end

-- Does the Tempo meter of `attacker` fill this turn (it must be strictly the faster creature)?
local function tempoFills(attacker: Battle.Fighter, defender: Battle.Fighter): boolean
	if attacker.stats.Speed <= defender.stats.Speed then
		return false
	end
	local gain = (attacker.stats.Speed / defender.stats.Speed - 1) * BattleConfig.TEMPO_GAIN
	return attacker.tempo + gain >= 1
end

type Outcome = { score: number, dealt: number, knockOut: boolean, acts: boolean, doomed: boolean }

-- One turn ahead against a foe that uses its best move. `me` is the creature that will be in play.
local function foresee(
	state: Battle.State,
	me: Battle.Fighter,
	foe: Battle.Fighter,
	move: string?
): Outcome
	local foeHit = bestStrike(state, foe, me, 1, 1)
	local dealt, taken, acts = 0, 0, false
	if move == nil then
		-- Switching in: we do not strike, and the foe hits whatever comes in.
		taken = math.min(foeHit, me.hp)
		if taken < me.hp and tempoFills(foe, me) then
			taken = math.min(me.hp, taken + bestStrike(state, foe, me, BattleConfig.TEMPO_POWER, 1))
		end
	else
		local order = moveOrder(me.stats.Speed, foe.stats.Speed)
		local myHit = strikeDamage(state, me, foe, move, 1, BattleConfig.PVE_VARIANCE_MIN)
		acts = not (order == 2 and foeHit >= me.hp)
		if acts then
			dealt = math.min(myHit, foe.hp)
		end
		local foeActs = not (order == 1 and dealt >= foe.hp)
		if foeActs then
			taken = math.min(foeHit, me.hp)
		end
		if me.hp - taken > 0 and foe.hp - dealt > 0 then
			if acts and tempoFills(me, foe) then
				local extra = strikeDamage(
					state,
					me,
					foe,
					move,
					BattleConfig.TEMPO_POWER,
					BattleConfig.PVE_VARIANCE_MIN
				)
				dealt = math.min(foe.hp, dealt + extra)
			end
			if foeActs and tempoFills(foe, me) then
				taken =
					math.min(me.hp, taken + bestStrike(state, foe, me, BattleConfig.TEMPO_POWER, 1))
			end
		end
	end
	local knockOut = dealt >= foe.hp
	local doomed = taken >= me.hp
	local score = dealt / foe.stats.Hp - taken / me.stats.Hp
	if knockOut then
		score += AiConfig.KNOCKOUT_BONUS
	end
	if doomed then
		score -= AiConfig.FAINT_PENALTY
	end
	return { score = score, dealt = dealt, knockOut = knockOut, acts = acts, doomed = doomed }
end

function BattleAi.rival(state: Battle.State, side: number): Battle.Action
	local me, foe = activeOf(state, side), activeOf(state, 3 - side)

	-- Score every move one turn ahead; the best score wins, then raw damage, then list order.
	local bestName, bestScore, bestDamage = me.moves[1], -math.huge, -1
	local knockOutName: string? = nil
	local knockOutScore = -math.huge
	local stayActs = false
	for _, name in me.moves do
		local outcome = foresee(state, me, foe, name)
		local damage = Battle.previewDamage(me, foe, name)
		if
			outcome.score > bestScore + 1e-9
			or (math.abs(outcome.score - bestScore) <= 1e-9 and damage > bestDamage)
		then
			bestName, bestScore, bestDamage = name, outcome.score, damage
		end
		stayActs = stayActs or outcome.acts
		if outcome.knockOut and outcome.acts and outcome.score > knockOutScore then
			knockOutName, knockOutScore = name, outcome.score
		end
	end

	-- 1. Take a knock-out when one is available.
	if knockOutName then
		return moveAction(knockOutName)
	end

	-- 2. Switch, but only when it beats staying. A switch is allowed by either rule: a rescue (staying
	-- means being knocked out before we can act, and the creature is worth saving) or the tamer's
	-- match-up rule (a clear disadvantage and a clearly better team-mate). Either way the switch-in
	-- must survive the turn and score better than our best move, with a little credit for the better
	-- match-up it leaves us in. The tamer's cooldown applies, so there is no ping-pong.
	if not switchedRecently(state, side, AiConfig.SWITCH_COOLDOWN_TURNS) then
		local rescue = not stayActs and me.hp >= me.stats.Hp * AiConfig.RESCUE_MIN_HEALTH_SHARE
		local current = matchup(me, foe)
		local disadvantaged = current < -AiConfig.SWITCH_DISADVANTAGE
		local saveIndex, saveValue = nil, bestScore + AiConfig.RIVAL_SWITCH_EDGE
		for _, index in livingBench(state, side) do
			local candidate = state.sides[side].team[index]
			local outcome = foresee(state, candidate, foe, nil)
			local better = matchup(candidate, foe) - current
			local allowed = rescue or (disadvantaged and better >= AiConfig.SWITCH_MARGIN)
			local value = outcome.score + AiConfig.RIVAL_MATCHUP_WEIGHT * better
			if allowed and not outcome.doomed and value > saveValue then
				saveIndex, saveValue = index, value
			end
		end
		if saveIndex then
			return { kind = "Switch", to = saveIndex }
		end
	end

	-- 4. Otherwise the best move one turn ahead.
	return moveAction(bestName)
end

-- Lookup ------------------------------------------------------------------------------------

-- The chooser for a tier name. `rng` is optional and only Wild uses it.
function BattleAi.forTier(tier: Tier, rng: Rng.Rng?): Chooser
	if tier == "Wild" then
		return function(state: Battle.State, side: number): Battle.Action
			return BattleAi.wild(state, side, rng)
		end
	elseif tier == "Tamer" then
		return BattleAi.tamer
	end
	return BattleAi.rival
end

return BattleAi
