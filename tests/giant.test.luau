--!strict
-- Checks and measurements for giant fights. Run from the project folder:  lune run tests/giant.test

local Battle = require("../src/shared/Battle")
local Breeding = require("../src/shared/Breeding")
local BattleConfig = require("../src/config/BattleConfig")
local GiantBattle = require("../src/shared/GiantBattle")
local GiantConfig = require("../src/config/GiantConfig")
local Giants = require("../src/content/Giants")
local Moves = require("../src/content/Moves")
local Rng = require("../src/shared/Rng")
local Stats = require("../src/shared/Stats")
local TypeChart = require("../src/shared/TypeChart")
local Types = require("../src/shared/Types")
local Placeholders = require("./fixtures/Placeholders")

Placeholders.install()

type Fighter = Battle.Fighter
type State = GiantBattle.State
type Action = GiantBattle.Action
type GiantDef = GiantBattle.GiantDef

local passed, failed = 0, 0
local function check(name: string, condition: boolean, detail: string?)
	if condition then
		passed += 1
	else
		failed += 1
	end
	print(
		`  {if condition then "PASS" else "FAIL"}  {name}{if detail
			then "  (" .. detail .. ")"
			else ""}`
	)
end

local GREENWOOD: GiantDef = Giants.greenwood_hollowbough

local POTION: GiantBattle.ItemEffect = { kind = "Heal", share = 0.4 }
local REVIVE: GiantBattle.ItemEffect = { kind = "Revive", share = 0.5 }

------------------------------------------------------------------------------------------------
-- Teams and helpers

local function creature(species: string, level: number, quality: number): Types.Creature
	local function part(): Types.Part
		return { species = species, quality = quality }
	end
	return {
		id = species,
		bodyPlan = "Quad",
		parts = { Head = part(), Torso = part(), FrontLimbs = part(), Legs = part(), Tail = part() },
		size = 1,
		colour = { shown = "Moss", carried = "Moss" },
		rarity = "Common",
		level = level,
		xp = 0,
		generation = 0,
		parents = nil,
		breedCount = 0,
		breedReadyAt = 0,
		originBiome = 1,
		isGiant = false,
		bound = false,
	}
end

-- "Weak": each creature's best four moves, Sand moves included (the giant is weak to Sand and Fire).
-- "Plain": the same creatures with every move of a type the giant is weak to taken away.
-- A seed other than 0 gives each creature a part quality between 2 and 8, so a hundred players
-- bring a hundred slightly different teams (the fight itself has no dice to spread results).
local function makeTeam(
	level: number,
	plain: boolean,
	element: Types.Element,
	teamSeed: number?
): { Fighter }
	local weak = GiantBattle.weakTypes(element)
	local team: { Fighter } = {}
	local rng = Rng.new(teamSeed or 1)
	for _, name in Placeholders.NAMES do
		local c = creature(name, level, if teamSeed then Rng.int(rng, 2, 8) else 5)
		local moves: { string }? = nil
		if plain then
			local pool = {}
			for _, candidate in Stats.movePool(c, level) do
				if not table.find(weak, Moves[candidate].element) then
					table.insert(pool, candidate)
				end
			end
			moves = pool
		end
		table.insert(team, Battle.fighter(c, moves, level))
	end
	return team
end

local function teamHp(team: { Fighter }): number
	local sum = 0
	for _, fighter in team do
		sum += fighter.stats.Hp
	end
	return sum
end

-- A copy of a giant that a test can change without touching the real data.
local function variant(def: GiantDef, edit: (GiantDef) -> ()): GiantDef
	local attacks: { [string]: GiantBattle.GiantAttack } = {}
	for id, attack in def.attacks do
		attacks[id] = table.clone(attack)
	end
	local phases: { GiantBattle.Phase } = {}
	for _, phase in def.phases do
		local copy = table.clone(phase)
		copy.pattern = table.clone(phase.pattern)
		table.insert(phases, copy)
	end
	local copy = table.clone(def)
	copy.stats = table.clone(def.stats)
	copy.attacks = attacks
	copy.phases = phases
	edit(copy)
	return copy
end

local function sturdy(team: { Fighter }): { Fighter }
	for _, fighter in team do
		fighter.stats.Hp = 1000000
		fighter.hp = 1000000
	end
	return team
end

local function move(name: string): Action
	return { kind = "Move", move = name }
end

local function hasWeakMove(fighter: Fighter): boolean
	for _, name in fighter.moves do
		if TypeChart.isStrong(Moves[name].element, GREENWOOD.element) then
			return true
		end
	end
	return false
end

-- A move on the active creature that is (or is not) a weak-point hit on the giant.
local function pickMove(state: State, weak: boolean): Action
	for _, name in state.team[state.active].moves do
		if TypeChart.isStrong(Moves[name].element, state.giant.element) == weak then
			return move(name)
		end
	end
	error("no such move")
end

-- A simple, sensible player: best move; switch out a creature that is about to faint when a
-- healthier one exists; heal when low while items remain; revive when two or fewer stand.
local function policy(state: State): Action
	local me = state.team[state.active]
	if GiantBattle.itemsLeft(state) > 0 then
		if me.hp / me.stats.Hp < 0.35 then
			return { kind = "Item", name = "Potion", effect = POTION, target = state.active }
		end
		local standing, fainted = 0, nil
		for index, fighter in state.team do
			if fighter.hp > 0 then
				standing += 1
			elseif not fainted then
				fainted = index
			end
		end
		if fainted and standing <= 2 and me.hp / me.stats.Hp > 0.5 then
			return { kind = "Item", name = "Revive herb", effect = REVIVE, target = fainted }
		end
	end
	local intent = state.intent
	if intent.kind ~= "WindUp" then
		local incoming = GiantBattle.previewAttack(state, intent.attack, me)
		if incoming >= me.hp then
			-- switch to the healthiest creature that would survive the hit
			local bestIndex, bestShare = nil, 0
			for index, fighter in state.team do
				local share = fighter.hp / fighter.stats.Hp
				local survives = GiantBattle.previewAttack(state, intent.attack, fighter)
					< fighter.hp
				if index ~= state.active and survives and share > bestShare then
					bestIndex, bestShare = index, share
				end
			end
			if bestIndex then
				return { kind = "Switch", to = bestIndex }
			end
		end
	end
	return GiantBattle.bestMove(state)
end

local function play(def: GiantDef, team: { Fighter }, seed: number): State
	local state = GiantBattle.new(def, team, seed)
	while not state.winner do
		GiantBattle.step(state, policy(state))
	end
	return state
end

local function logText(state: State): string
	local lines = {}
	for _, event in state.log do
		table.insert(lines, `{event.turn}:{event.text}`)
	end
	return table.concat(lines, "|")
end

------------------------------------------------------------------------------------------------
print("\n== The giant as data ==")
do
	local problems = GiantBattle.validate(GREENWOOD)
	check("Greenwood validates", #problems == 0, table.concat(problems, "; "))
	check("it is in the registry by id", Giants[GREENWOOD.id] == GREENWOOD)
	local thresholds = {}
	for _, phase in GREENWOOD.phases do
		table.insert(thresholds, phase.enterAt)
	end
	check(
		"three phases at 100%, 60% and 25%",
		#thresholds == 3 and thresholds[1] == 1 and thresholds[2] == 0.6 and thresholds[3] == 0.25
	)
	check(
		"the thresholds match the config",
		table.concat(thresholds, ",") == table.concat(GiantConfig.PHASE_THRESHOLDS, ",")
	)
	local windUps, interruptible = 0, true
	for _, attack in GREENWOOD.attacks do
		if attack.windUp then
			windUps += 1
			interruptible = interruptible and attack.whenInterrupted ~= nil
		end
	end
	check("it has wind-up attacks that something can interrupt", windUps >= 1 and interruptible)
	local weak = GiantBattle.weakTypes(GREENWOOD.element)
	check(
		"the giant is weak to Sand and Fire",
		#weak == 2 and table.find(weak, "Sand") ~= nil and table.find(weak, "Fire") ~= nil
	)
	local ratio = GREENWOOD.stats.Hp / teamHp(makeTeam(15, false, "Leaf"))
	check(
		"health is about 2.5 times an on-level team's",
		math.abs(ratio - GiantConfig.HEALTH_TEAM_MULTIPLIER) < 0.3,
		`{string.format("%.2f", ratio)}x`
	)
	local broken = variant(GREENWOOD, function(def)
		def.phases[2].pattern = { "nonsense" }
		def.attacks.slam.whenInterrupted = nil
		def.phases[3].enterAt = 0.7
	end)
	check("the validator catches bad data", #GiantBattle.validate(broken) == 3)
end

------------------------------------------------------------------------------------------------
print("\n== Replay ==")
do
	local a = play(GREENWOOD, makeTeam(15, false, "Leaf"), 42)
	local b = GiantBattle.replay(GREENWOOD, function()
		return makeTeam(15, false, "Leaf")
	end, 42, a.history)
	check(
		"the same seed and actions replay the same fight",
		logText(a) == logText(b) and a.winner == b.winner
	)
	check(
		"the same state at the end",
		a.boss.hp == b.boss.hp and a.turn == b.turn and a.itemsUsed == b.itemsUsed
	)
	local c = play(GREENWOOD, makeTeam(15, false, "Leaf"), 43)
	check("a different seed changes the small variance", logText(a) ~= logText(c))
	local d = play(GREENWOOD, makeTeam(15, false, "Leaf"), 42)
	check("running it twice is identical", logText(a) == logText(d))
end

------------------------------------------------------------------------------------------------
print("\n== The intent shown is what the giant does ==")
do
	-- Plain moves only, so nothing interrupts a wind-up and every strike lands in full.
	local state = GiantBattle.new(
		variant(GREENWOOD, function(def)
			def.stats.Hp = 10000000
		end),
		sturdy(makeTeam(15, true, "Leaf")),
		7
	)
	local kinds: { [string]: boolean } = {}
	local allMatch, allText, sawRelease = true, true, false
	for _ = 1, 40 do
		local intent = state.intent
		local attack = state.giant.attacks[intent.attack]
		allText = allText and #intent.text > 0
		kinds[intent.kind] = true
		local before = {}
		for index, fighter in state.team do
			before[index] = fighter.hp
		end
		local active = state.active
		local previews = {}
		for index, fighter in state.team do
			previews[index] = GiantBattle.previewAttack(state, intent.attack, fighter)
		end
		GiantBattle.step(state, pickMove(state, false))
		if intent.kind == "WindUp" then
			-- nothing lands on a wind-up turn
			for index, fighter in state.team do
				allMatch = allMatch and fighter.hp == before[index]
			end
			allMatch = allMatch and state.charged ~= nil and state.charged.attack == intent.attack
		else
			sawRelease = sawRelease or intent.kind == "Release"
			for index, fighter in state.team do
				local lost = before[index] - fighter.hp
				local hitsThis = if attack.target == "Team" then true else index == active
				if hitsThis then
					local high = previews[index]
					local low = math.max(1, math.floor(high * BattleConfig.PVE_VARIANCE_MIN))
					allMatch = allMatch and lost >= low - 1 and lost <= high
				else
					allMatch = allMatch and lost == 0
				end
			end
			allMatch = allMatch and intent.hitsTeam == (attack.target == "Team")
		end
		allMatch = allMatch and (state.charged == nil) == (intent.kind ~= "WindUp")
	end
	check("every turn the damage and the targets match the announced intent", allMatch)
	check(
		"intents covered attacks, wind-ups and releases",
		kinds.Attack and kinds.WindUp and kinds.Release and sawRelease
	)
	check("every intent carries a line of text", allText)
	-- a wind-up is always followed by its own release
	local fresh = GiantBattle.new(GREENWOOD, sturdy(makeTeam(15, true, "Leaf")), 1)
	local pairsOk = true
	for _ = 1, 30 do
		local before = fresh.intent
		GiantBattle.step(fresh, pickMove(fresh, false))
		if before.kind == "WindUp" then
			pairsOk = pairsOk
				and fresh.intent.kind == "Release"
				and fresh.intent.attack == before.attack
		end
	end
	check("a wind-up is followed by its own strike", pairsOk)
	check(
		"the first intent is announced before any turn",
		GiantBattle.new(GREENWOOD, makeTeam(15, true, "Leaf"), 1).intent.text ~= ""
	)
end

------------------------------------------------------------------------------------------------
print("\n== Phases ==")
do
	local function fresh(): State
		return GiantBattle.new(
			variant(GREENWOOD, function(def)
				def.stats.Hp = 100000
			end),
			sturdy(makeTeam(15, true, "Leaf")),
			3
		)
	end
	local state = fresh()
	check("a fight starts in phase 1", state.phase == 1)
	-- Just above 60%: even the biggest hit cannot take it down to the threshold.
	local maxHit = Battle.previewDamage(state.team[1], state.boss, state.team[1].moves[1])
	state.boss.hp = 60000 + maxHit + 5
	GiantBattle.step(state, pickMove(state, false))
	check(
		"just above 60% stays in phase 1",
		state.phase == 1,
		`hp share {string.format("%.4f", state.boss.hp / 100000)}`
	)
	state.boss.hp = 60010 -- any hit takes it to 60% or lower
	GiantBattle.step(state, pickMove(state, false))
	check("at or below 60% enters phase 2", state.phase == 2)
	local inPhase2 = true
	for _ = 1, 8 do
		local id = state.intent.attack
		inPhase2 = inPhase2 and table.find(GREENWOOD.phases[2].pattern, id) ~= nil
		GiantBattle.step(state, pickMove(state, false))
	end
	check("phase 2 uses phase 2's pattern", inPhase2 and state.phase == 2)
	check(
		"the phase beat is logged",
		string.find(logText(state), GREENWOOD.phases[2].enterText, 1, true) ~= nil
	)
	state.boss.hp = 25000 + maxHit + 200
	GiantBattle.step(state, pickMove(state, false))
	check("just above 25% stays in phase 2", state.phase == 2)
	state.boss.hp = 25010
	for _ = 1, 3 do
		GiantBattle.step(state, pickMove(state, false))
		if state.phase == 3 then
			break
		end
	end
	check("at or below 25% enters phase 3", state.phase == 3)
	local noWindUps = true
	for _ = 1, 9 do
		noWindUps = noWindUps and state.intent.kind == "Attack"
		state.boss.hp = math.max(2, state.boss.hp)
		GiantBattle.step(state, pickMove(state, false))
	end
	check("phase 3 is a race: no wind-ups", noWindUps and state.phase == 3)
	local jump = fresh()
	jump.boss.hp = 20000
	GiantBattle.step(jump, pickMove(jump, false))
	check("a big drop skips straight to the right phase", jump.phase == 3)
	check(
		"phase 3 hits harder than the same attack in phase 1",
		GiantBattle.previewAttack(state, "lash", state.team[1])
			> GiantBattle.previewAttack(fresh(), "lash", state.team[1])
	)
	-- a wind-up under way when a phase changes still lands, then the new pattern starts
	local mid = GiantBattle.new(
		variant(GREENWOOD, function(def)
			def.stats.Hp = 100000
			def.phases[1].pattern = { "slam" }
		end),
		sturdy(makeTeam(15, true, "Leaf")),
		3
	)
	mid.boss.hp = 60010
	GiantBattle.step(mid, pickMove(mid, false)) -- wind-up turn; phase changes at its end
	check(
		"a wind-up that is under way is kept when the phase changes",
		mid.phase == 2 and mid.intent.kind == "Release" and mid.intent.attack == "slam"
	)
	GiantBattle.step(mid, pickMove(mid, false))
	check(
		"then the new pattern starts from its first step",
		mid.intent.attack == GREENWOOD.phases[2].pattern[1]
	)
end

------------------------------------------------------------------------------------------------
print("\n== Weak point ==")
do
	local function toRelease(def: GiantDef, id: string): State
		local state = GiantBattle.new(
			variant(def, function(d)
				d.stats.Hp = 10000000
				d.phases[1].pattern = { id }
			end),
			sturdy(makeTeam(15, false, "Leaf")),
			5
		)
		GiantBattle.step(state, pickMove(state, false)) -- the wind-up turn
		return state
	end
	local function lost(state: State): number
		local before = 0
		for _, f in state.team do
			before += f.hp
		end
		return before
	end

	-- Cancel: Heartwood Slam
	local cancelled = toRelease(GREENWOOD, "slam")
	check("at the release turn the slam is announced", cancelled.intent.kind == "Release")
	local hpBefore = lost(cancelled)
	GiantBattle.step(cancelled, pickMove(cancelled, true))
	check(
		"a weak-type hit during the wind-up cancels the slam",
		lost(cancelled) == hpBefore
			and string.find(logText(cancelled), "is stopped", 1, true) ~= nil
	)

	local landed = toRelease(GREENWOOD, "slam")
	local landedBefore = lost(landed)
	GiantBattle.step(landed, pickMove(landed, false))
	local slamLoss = landedBefore - lost(landed)
	check("without it the slam lands", slamLoss > 0, `{slamLoss} damage`)

	-- a weak hit on the wind-up turn itself is too early
	local early = GiantBattle.new(
		variant(GREENWOOD, function(d)
			d.stats.Hp = 10000000
			d.phases[1].pattern = { "slam" }
		end),
		sturdy(makeTeam(15, false, "Leaf")),
		5
	)
	GiantBattle.step(early, pickMove(early, true))
	local earlyBefore = lost(early)
	GiantBattle.step(early, pickMove(early, false))
	check(
		"a weak hit before the charge is complete does not stop it",
		earlyBefore - lost(early) > 0
	)

	-- Halve: Gale Sweep (team attack)
	local halved = toRelease(GREENWOOD, "sweep")
	local halvedBefore = lost(halved)
	local raw = 0
	for _, f in halved.team do
		raw += GiantBattle.previewAttack(halved, "sweep", f)
	end
	GiantBattle.step(halved, pickMove(halved, true))
	local halvedLoss = halvedBefore - lost(halved)
	local full = toRelease(GREENWOOD, "sweep")
	local fullBefore = lost(full)
	GiantBattle.step(full, pickMove(full, false))
	local fullLoss = fullBefore - lost(full)
	check(
		"a weak-type hit halves Gale Sweep",
		halvedLoss > 0
			and halvedLoss <= raw * GiantConfig.HALVE_SHARE
			and halvedLoss >= raw * GiantConfig.HALVE_SHARE * 0.9 - 3,
		`{halvedLoss} against {fullLoss}`
	)
	check(
		"the halved sweep did about half the damage of the full one",
		halvedLoss < fullLoss * 0.6 and halvedLoss > fullLoss * 0.4
	)

	-- a type the giant is not weak to does nothing special
	local sweepRaw = 0
	local teamNow = toRelease(GREENWOOD, "sweep")
	for _, f in teamNow.team do
		sweepRaw += GiantBattle.previewAttack(teamNow, "sweep", f)
	end
	check("only a type the giant is weak to counts", fullLoss > sweepRaw * 0.9 - 3)
	check(
		"every Greenwood team member can bring a weak move or the team lacks one",
		hasWeakMove(makeTeam(15, false, "Leaf")[3])
	)
end

------------------------------------------------------------------------------------------------
print("\n== Items ==")
do
	local state = GiantBattle.new(
		variant(GREENWOOD, function(def)
			def.stats.Hp = 10000000
			def.stats.Attack = 1
		end),
		makeTeam(15, true, "Leaf"),
		9
	)
	local target = state.team[1]
	local maxHp = target.stats.Hp
	target.hp = 10
	GiantBattle.step(state, { kind = "Item", name = "Potion", effect = POTION, target = 1 })
	check(
		"a heal restores a share of the creature's health",
		target.hp >= 10 + math.floor(maxHp * 0.4) - 5 and state.itemsUsed == 1,
		`hp {target.hp}/{maxHp}`
	)
	target.hp = maxHp
	GiantBattle.step(state, { kind = "Item", name = "Potion", effect = POTION, target = 1 })
	check(
		"a heal on a full-health creature is refused and not counted",
		state.itemsUsed == 1 and state.history[#state.history].kind == "Move"
	)
	state.team[2].hp = 0
	GiantBattle.step(state, { kind = "Item", name = "Herb", effect = POTION, target = 2 })
	check("a heal cannot revive", state.team[2].hp == 0 and state.itemsUsed == 1)
	GiantBattle.step(state, { kind = "Item", name = "Revive herb", effect = REVIVE, target = 2 })
	check(
		"a revive brings a fainted creature back at a share of health",
		state.team[2].hp >= math.floor(state.team[2].stats.Hp * 0.5) - 2 and state.itemsUsed == 2
	)
	GiantBattle.step(state, { kind = "Item", name = "Revive herb", effect = REVIVE, target = 1 })
	check("a revive on a standing creature is refused", state.itemsUsed == 2)
	GiantBattle.step(
		state,
		{ kind = "Item", name = "Potion", effect = { kind = "Heal", share = 0 / 0 }, target = 1 }
	)
	GiantBattle.step(
		state,
		{ kind = "Item", name = "Potion", effect = { kind = "Heal", share = 9 }, target = 1 }
	)
	GiantBattle.step(state, { kind = "Item", name = "Potion", effect = POTION, target = 99 })
	check("odd item effects and targets are refused", state.itemsUsed == 2)
	for _ = 1, 10 do
		target.hp = 5
		GiantBattle.step(state, { kind = "Item", name = "Potion", effect = POTION, target = 1 })
	end
	check(
		"at most five items in one fight",
		state.itemsUsed == GiantConfig.MAX_ITEMS and GiantBattle.itemsLeft(state) == 0,
		`used {state.itemsUsed}`
	)
	check(
		"an item over the cap is replaced by a move",
		state.history[#state.history].kind == "Move"
	)
end

------------------------------------------------------------------------------------------------
print("\n== Other actions ==")
do
	local state = GiantBattle.new(GREENWOOD, sturdy(makeTeam(15, false, "Leaf")), 4)
	GiantBattle.step(state, move("Not A Move"))
	check(
		"a move the creature does not have is replaced",
		state.history[1].kind == "Move"
			and table.find(state.team[1].moves, (state.history[1] :: any).move) ~= nil
	)
	GiantBattle.step(state, { kind = "Switch", to = 1 })
	check("switching to the creature already out is replaced", state.history[2].kind == "Move")
	GiantBattle.step(state, { kind = "Switch", to = 2 })
	check(
		"a switch changes the active creature",
		state.active == 2 and state.history[3].kind == "Switch"
	)
	state.team[3].hp = 0
	GiantBattle.step(state, { kind = "Switch", to = 3 })
	check("switching to a fainted creature is replaced", state.active == 2)
end

------------------------------------------------------------------------------------------------
print("\n== Enrage ==")
do
	local state = GiantBattle.new(GREENWOOD, makeTeam(15, false, "Leaf"), 4)
	local front = state.team[1]
	state.turn = 27
	local before = GiantBattle.previewAttack(state, "lash", front) -- turn 28
	state.turn = 28
	local at29 = GiantBattle.previewAttack(state, "lash", front)
	state.turn = 29
	local at30 = GiantBattle.previewAttack(state, "lash", front)
	state.turn = 33
	local at34 = GiantBattle.previewAttack(state, "lash", front)
	state.turn = 100
	local late = GiantBattle.previewAttack(state, "lash", front)
	check("no enrage before turn 30", before == at29)
	check("damage rises from turn 30", at30 > at29, `{at29} then {at30}`)
	check("and keeps rising each turn", at34 > at30)
	check(
		"until the cap",
		late == GiantBattle.previewAttack(state, "lash", front)
			and late <= math.floor(at29 * GiantConfig.ENRAGE_MAX) + 1
	)
	check(
		"the multiplier follows the config numbers",
		math.abs(
			GiantBattle.enrageMultiplier(GREENWOOD, 30)
				- (1 + (GREENWOOD.enrage :: GiantBattle.Enrage).step)
		)
				< 1e-9
			and GiantBattle.enrageMultiplier(GREENWOOD, 29) == 1
	)
	local note = GiantBattle.new(GREENWOOD, makeTeam(15, false, "Leaf"), 4)
	note.turn = 29
	GiantBattle.step(note, pickMove(note, false))
	check(
		"the intent says when the giant is enraged",
		note.intent.enraged and string.find(note.intent.text, "enraged", 1, true) ~= nil
	)
	-- in a real fight, the same attack hurts more late than early
	local long = GiantBattle.new(
		variant(GREENWOOD, function(def)
			def.stats.Hp = 10000000
			def.phases[1].pattern = { "lash" }
		end),
		sturdy(makeTeam(15, true, "Leaf")),
		2
	)
	local damageAt: { [number]: number } = {}
	for turn = 1, 40 do
		local hp = long.team[1].hp
		GiantBattle.step(long, pickMove(long, false))
		damageAt[turn] = hp - long.team[1].hp
	end
	check(
		"in play the same lash does more damage at turn 40 than at turn 5",
		damageAt[40] > damageAt[5] * 1.5,
		`{damageAt[5]} then {damageAt[40]}`
	)
end

------------------------------------------------------------------------------------------------
print("\n== The fight always ends ==")
do
	-- A giant that cannot be hurt and barely hurts: the fight still stops at the turn limit.
	local wall = variant(GREENWOOD, function(def)
		def.stats.Hp = 1000000000
		def.stats.Attack = 1
		def.stats.Defence = 1000000
	end)
	local state = GiantBattle.new(wall, makeTeam(18, false, "Leaf"), 1)
	local guard = 0
	while not state.winner and guard < 500 do
		GiantBattle.step(state, GiantBattle.bestMove(state))
		guard += 1
	end
	check(
		"an unwinnable stalemate ends at the turn limit with the giant ahead",
		state.winner == "Giant" and state.turn == GiantConfig.MAX_TURNS,
		`turn {state.turn}`
	)
	local weakling = variant(GREENWOOD, function(def)
		def.stats.Hp = 1
	end)
	local quick = GiantBattle.new(weakling, makeTeam(15, false, "Leaf"), 1)
	GiantBattle.step(quick, GiantBattle.bestMove(quick))
	check(
		"the player wins the moment the giant falls",
		quick.winner == "Player" and quick.boss.hp == 0
	)
	local doomed = GiantBattle.new(
		variant(GREENWOOD, function(def)
			def.stats.Attack = 100000
			def.stats.Hp = 100000000
		end),
		makeTeam(9, false, "Leaf"),
		1
	)
	while not doomed.winner do
		GiantBattle.step(doomed, GiantBattle.bestMove(doomed))
	end
	check("the giant wins when the whole team has fainted", doomed.winner == "Giant")
	local allDown = true
	for _, f in doomed.team do
		allDown = allDown and f.hp == 0
	end
	check("and every creature is down", allDown)
	local afterEnd = doomed.turn
	GiantBattle.step(doomed, move("Bite"))
	check("a finished fight accepts no more turns", doomed.turn == afterEnd)
	local bounded = true
	for seed = 1, 60 do
		local s = play(GREENWOOD, makeTeam(9 + seed % 10, seed % 2 == 0, "Leaf"), seed)
		bounded = bounded and s.winner ~= nil and s.turn <= GiantConfig.MAX_TURNS
	end
	check("sixty varied fights all end", bounded)
end

------------------------------------------------------------------------------------------------
print("\n== Balance: Hollowbough against teams of three from the real Greenwood roster ==")
local ROSTER = {
	"Burlhorn",
	"Gorsling",
	"Mossmitt",
	"Sloshcalf",
	"Spadesnout",
	"Splashjack",
	"Stiltbark",
	"Stumpwarden",
}

-- A random team of three from the eight species, each with wild part qualities, so a team may hold
-- the Sand starter (Spadesnout, the strongest Sand attacker) or a Water creature whose torso brings
-- Mud Slap or Silt Surge. "Sand": a team whose best four moves include a move of a type the giant is
-- weak to (drawn again until one does). "Plain": any random team with every such move taken away.
-- The creatures are not placed to suit the fight: the first one drawn leads.
local function realTeam(level: number, sand: boolean, seed: number): { Fighter }
	local rng = Rng.new(seed)
	local weak = GiantBattle.weakTypes(GREENWOOD.element)
	while true do
		local team: { Fighter } = {}
		local brings = false
		for index = 1, 3 do
			local name = Rng.pick(rng, ROSTER)
			local c = Breeding.wild(name, `{name}{index}`, level, "Common", "Moss", rng)
			local moves: { string }? = nil
			if not sand then
				local pool = {}
				for _, candidate in Stats.movePool(c, level) do
					if not table.find(weak, Moves[candidate].element) then
						table.insert(pool, candidate)
					end
				end
				moves = pool
			end
			local fighter = Battle.fighter(c, moves, level)
			brings = brings or hasWeakMove(fighter)
			table.insert(team, fighter)
		end
		if brings == sand then
			return team
		end
	end
end

local SEEDS = 300
local rates: { [string]: number } = {}
local meanWinTurns: { [string]: number } = {}
for _, sand in { true, false } do
	print(
		`  Team {if sand
			then "with the Sand starter and its Sand moves"
			else "without a Sand or Fire move"}  (policy: best move, switch when about to faint, heal when low, five items; {SEEDS} seeded teams per row)`
	)
	for _, level in { 9, 12, 15, 18 } do
		local wins, turnsWon, turnsAll, items = 0, 0, 0, 0
		for seed = 1, SEEDS do
			local state = play(GREENWOOD, realTeam(level, sand, seed), seed * 7919)
			turnsAll += state.turn
			items += state.itemsUsed
			if state.winner == "Player" then
				wins += 1
				turnsWon += state.turn
			end
		end
		local key = `{if sand then "sand" else "plain"}{level}`
		rates[key] = wins / SEEDS
		meanWinTurns[key] = if wins > 0 then turnsWon / wins else 0
		print(
			`    level {level}: wins {string.format("%3.0f", 100 * wins / SEEDS)}%   turns {string.format(
				"%.1f",
				turnsAll / SEEDS
			)} (wins {string.format("%.1f", meanWinTurns[key])})   items used {string.format(
				"%.1f",
				items / SEEDS
			)}`
		)
	end
end
local function pct(x: number): string
	return string.format("%.0f%%", x * 100)
end
check(
	"an on-level team (15) with a Sand attacker wins 70 to 90%",
	rates.sand15 >= 0.70 and rates.sand15 <= 0.90,
	pct(rates.sand15)
)
check(
	"in roughly 15 to 25 turns",
	meanWinTurns.sand15 >= 15 and meanWinTurns.sand15 <= 25,
	string.format("%.1f", meanWinTurns.sand15)
)
check(
	"an on-level team (15) with no Sand or Fire move wins 25 to 50%",
	rates.plain15 >= 0.25 and rates.plain15 <= 0.50,
	pct(rates.plain15)
)
check(
	"a level 9 team nearly always loses, with or without Sand",
	rates.sand9 <= 0.05 and rates.plain9 <= 0.05,
	`{pct(rates.sand9)} and {pct(rates.plain9)}`
)
check(
	"a level 18 team wins most of the time either way",
	rates.sand18 >= 0.75 and rates.plain18 >= 0.6,
	`{pct(rates.sand18)} and {pct(rates.plain18)}`
)
check(
	"a higher level does better than a lower one",
	rates.sand18 >= rates.sand15
		and rates.sand15 >= rates.sand12
		and rates.sand12 >= rates.sand9
		and rates.plain18 >= rates.plain15
		and rates.plain15 >= rates.plain12
		and rates.plain12 >= rates.plain9
)
check(
	"bringing Sand helps clearly at level 15",
	rates.sand15 - rates.plain15 >= 0.25,
	`{pct(rates.sand15)} against {pct(rates.plain15)}`
)

-- The template's guideline: a neutral creature survives two of the giant's big hits, and a
-- high-Defence creature survives more. The biggest single-target hit of the fight is a phase 3
-- Thorn Gale at full strength (before any enrage); Heartwood Slam is the biggest hit that a Sand or
-- Fire move can cancel. Level 15 creatures at full health, every part quality 5.
print("  Hits of the giant a level 15 creature survives from full health (quality 5):")
do
	local state = GiantBattle.new(GREENWOOD, realTeam(15, true, 1), 1)
	state.phase = #GREENWOOD.phases
	local rng = Rng.new(5)
	local parts: { string } = {}
	local worst, best, bestName = math.huge, 0, ""
	local neutral, tank = 0, 0
	for _, name in ROSTER do
		local c = Breeding.wild(name, name, 15, "Common", "Moss", rng)
		for _, slot in { "Head", "Torso", "FrontLimbs", "Legs", "Tail" } do
			c.parts[slot :: Types.Slot].quality = 5
		end
		local fighter = Battle.fighter(c, nil, 15)
		local big, slam = 0, GiantBattle.previewAttack(state, "slam", fighter)
		for id, attack in GREENWOOD.attacks do
			if attack.target == "Front" then
				big = math.max(big, GiantBattle.previewAttack(state, id, fighter))
			end
		end
		local hits, slamHits = fighter.stats.Hp / big, fighter.stats.Hp / slam
		worst = math.min(worst, hits)
		if hits > best then
			best, bestName = hits, name
		end
		if fighter.element == "Water" and name == "Sloshcalf" then
			neutral = hits
		end
		if name == "Burlhorn" then
			tank = hits
		end
		table.insert(
			parts,
			`{name} ({fighter.element}, Def {fighter.stats.Defence}) {string.format("%.1f", hits)} big, {string.format(
				"%.1f",
				slamHits
			)} slam`
		)
	end
	print(`    {table.concat(parts, "; ")}`)
	check("every creature survives at least two big hits", worst >= 2, string.format("%.1f", worst))
	check(
		"the sturdiest survives clearly more than two",
		best >= 3,
		`{bestName} {string.format("%.1f", best)}`
	)
	check(
		"a high-Defence Leaf creature (Burlhorn) survives more big hits than a neutral one (Sloshcalf)",
		tank > neutral,
		`{string.format("%.1f", tank)} against {string.format("%.1f", neutral)}`
	)
end

------------------------------------------------------------------------------------------------
print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error(`{failed} giant checks failed`)
end
