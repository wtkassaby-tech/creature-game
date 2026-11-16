--!strict
-- Checks for the computer opponents. Run:  lune run tests/battleai.test

local Battle = require("../src/shared/Battle")
local BattleAi = require("../src/shared/BattleAi")
local BattleConfig = require("../src/config/BattleConfig")
local Breeding = require("../src/shared/Breeding")
local Rng = require("../src/shared/Rng")
local Stats = require("../src/shared/Stats")
local Placeholders = require("./fixtures/Placeholders")

Placeholders.install()

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

local NAMES = Placeholders.NAMES
local LEVEL = BattleConfig.RANKED_LEVEL
local TIERS: { BattleAi.Tier } = { "Wild", "Tamer", "Rival" }

local function randomTeam(rng: Rng.Rng, size: number, prefix: string): { Battle.Fighter }
	local team = {}
	for index = 1, size do
		local creature =
			Breeding.wild(Rng.pick(rng, NAMES), `{prefix}{index}`, LEVEL, "Common", "Moss", rng)
		table.insert(team, Battle.fighter(creature))
	end
	return team
end

-- Wild creatures fight with their natural moves in the order their parts teach them (basic first),
-- not the strongest four that Battle.bestMoves picks for a trained team.
local function asWild(team: { Battle.Fighter }): { Battle.Fighter }
	for _, fighter in team do
		local pool = Stats.movePool(fighter.creature)
		fighter.moves = table.move(pool, 1, math.min(#pool, BattleConfig.MAX_MOVES), 1, {})
	end
	return team
end

local function bestFoeHit(foe: Battle.Fighter, target: Battle.Fighter): number
	local hit = 0
	for _, name in foe.moves do
		hit = math.max(hit, Battle.previewDamage(foe, target, name))
	end
	return hit
end

local function isLegal(state: Battle.State, side: number, action: Battle.Action): boolean
	local s = state.sides[side]
	if action.kind == "Switch" then
		local target = s.team[action.to]
		return target ~= nil and target.hp > 0 and action.to ~= s.active
	end
	return table.find(s.team[s.active].moves, action.move) ~= nil
end

------------------------------------------------------------------------------------------------
print("\n== Legal actions across random states ==")
do
	local rng = Rng.new(7)
	local illegal, decisions = 0, 0
	for seed = 1, 300 do
		local state = Battle.new(
			randomTeam(rng, Rng.int(rng, 1, 3), "a"),
			randomTeam(rng, Rng.int(rng, 1, 3), "b"),
			seed,
			Rng.chance(rng, 0.3)
		)
		-- Wear the teams down with a random walk of turns, scrambling health and Tempo.
		for _ = 1, Rng.int(rng, 0, 12) do
			if state.winner then
				break
			end
			for side = 1, 2 do
				for _, fighter in state.sides[side].team do
					if fighter.hp > 0 and Rng.chance(rng, 0.3) then
						fighter.hp = math.max(1, math.floor(fighter.hp * Rng.next(rng)))
					end
					fighter.tempo = Rng.next(rng) * 0.99
				end
			end
			local tierA: BattleAi.Tier = Rng.pick(rng, TIERS)
			local tierB: BattleAi.Tier = Rng.pick(rng, TIERS)
			local chooserA = BattleAi.forTier(tierA, Rng.new(seed))
			local chooserB = BattleAi.forTier(tierB, Rng.new(seed + 1))
			Battle.step(state, chooserA(state, 1), chooserB(state, 2))
		end
		if not state.winner then
			for _, tier: BattleAi.Tier in TIERS do
				for _, withRng in { false, true } do
					local chooser = BattleAi.forTier(tier, if withRng then Rng.new(seed) else nil)
					for side = 1, 2 do
						decisions += 1
						if not isLegal(state, side, chooser(state, side)) then
							illegal += 1
						end
					end
				end
			end
		end
	end
	check(
		"every tier returns a legal action",
		illegal == 0,
		`{decisions} decisions, {illegal} illegal`
	)
end

------------------------------------------------------------------------------------------------
-- Plays one battle; returns the state and, for each side, the turns on which it switched.
local function play(
	teamA: { Battle.Fighter },
	teamB: { Battle.Fighter },
	tierA: BattleAi.Tier,
	tierB: BattleAi.Tier,
	seed: number
): (Battle.State, { { number } })
	if tierA == "Wild" then
		asWild(teamA)
	end
	if tierB == "Wild" then
		asWild(teamB)
	end
	local state = Battle.new(teamA, teamB, seed, false)
	local choosers =
		{ BattleAi.forTier(tierA, Rng.new(seed)), BattleAi.forTier(tierB, Rng.new(seed + 77)) }
	local switches: { { number } } = { {}, {} }
	while not state.winner do
		local actions = { choosers[1](state, 1), choosers[2](state, 2) }
		for side = 1, 2 do
			if actions[side].kind == "Switch" then
				table.insert(switches[side], state.turn + 1)
			end
		end
		Battle.step(state, actions[1], actions[2])
	end
	return state, switches
end

------------------------------------------------------------------------------------------------
print("\n== The tamer does not thrash ==")
do
	local rng = Rng.new(99)
	local worst, total, battles = 0, 0, 0
	for seed = 1, 200 do
		local a, b = randomTeam(rng, 3, "a"), randomTeam(rng, 3, "b")
		local _, switches = play(a, b, "Tamer", "Rival", seed)
		local list = switches[1]
		total += #list
		battles += 1
		for index, turn in list do
			local inWindow = 1
			for later = index + 1, #list do
				if list[later] <= turn + 2 then
					inWindow += 1
				end
			end
			worst = math.max(worst, inWindow)
		end
	end
	print(`  {total} tamer switches over {battles} battles`)
	check("at most one switch in any three turns", worst <= 1, `worst window {worst}`)
	check("the tamer does switch sometimes", total > 0)
end

------------------------------------------------------------------------------------------------
print("\n== The rival's one-turn look-ahead ==")
do
	local rng = Rng.new(5)
	local tried, taken = 0, 0
	for seed = 1, 300 do
		local state = Battle.new(randomTeam(rng, 3, "a"), randomTeam(rng, 3, "b"), seed, false)
		local me, foe = state.sides[1].team[1], state.sides[2].team[1]
		foe.hp = 1
		-- Only count states where we get to act: not slower than the foe's reach to knock us out.
		if not (Battle.firstMover(state) == 2 and bestFoeHit(foe, me) >= me.hp) then
			tried += 1
			local action = BattleAi.rival(state, 1)
			Battle.step(state, action, Battle.chooseAction(state, 2))
			if state.sides[2].team[1].hp == 0 then
				taken += 1
			end
		end
	end
	check(
		"the rival takes an available knock-out",
		tried > 100 and taken == tried,
		`{taken}/{tried}`
	)

	-- Rescue: the foe is clearly faster and hits hard enough to knock out our healthy creature
	-- first, and a team-mate would survive the hit.
	local rescued, doomedStates = 0, 0
	for seed = 1, 300 do
		local state = Battle.new(randomTeam(rng, 3, "a"), randomTeam(rng, 3, "b"), seed, false)
		local me, foe = state.sides[1].team[1], state.sides[2].team[1]
		-- A frail creature at full health, with exactly as much health as the foe's best hit does.
		me.stats.Defence = 1
		me.stats.Hp = bestFoeHit(foe, me)
		me.hp = me.stats.Hp
		if Battle.firstMover(state) == 2 and bestFoeHit(foe, me) >= me.hp then
			local safe = false
			for index = 2, 3 do
				local mate = state.sides[1].team[index]
				safe = safe or bestFoeHit(foe, mate) < mate.hp
			end
			if safe then
				doomedStates += 1
				if BattleAi.rival(state, 1).kind == "Switch" then
					rescued += 1
				end
			end
		end
	end
	check(
		"the rival switches out a creature that would fall before it acts",
		doomedStates > 10 and rescued == doomedStates,
		`{rescued}/{doomedStates}`
	)
end

------------------------------------------------------------------------------------------------
print("\n== Mirrored 3v3 tournaments ==")
local function tournament(tierX: BattleAi.Tier, tierY: BattleAi.Tier, pairs: number): number
	local rng = Rng.new(2026)
	local wins = 0.0
	for seed = 1, pairs do
		local ids = { Rng.int(rng, 1, 1e9), Rng.int(rng, 1, 1e9) }
		local function teams(): ({ Battle.Fighter }, { Battle.Fighter })
			return randomTeam(Rng.new(ids[1]), 3, "a"), randomTeam(Rng.new(ids[2]), 3, "b")
		end
		-- Game one: X plays team A on side 1. Game two: the teams swap, so X plays team B.
		local a, b = teams()
		local one = play(a, b, tierX, tierY, seed)
		local c, d = teams()
		local two = play(d, c, tierX, tierY, seed)
		for _, state in { one, two } do
			wins += if state.winner == 1 then 1 elseif state.winner == 0 then 0.5 else 0
		end
	end
	return wins / (pairs * 2)
end

do
	local rivalVsTamer = tournament("Rival", "Tamer", 600)
	local tamerVsWild = tournament("Tamer", "Wild", 600)
	local rivalVsWild = tournament("Rival", "Wild", 600)
	print(`  Rival beats Tamer in {string.format("%.1f", rivalVsTamer * 100)}% of battles`)
	print(`  Tamer beats Wild in {string.format("%.1f", tamerVsWild * 100)}% of battles`)
	print(`  Rival beats Wild in {string.format("%.1f", rivalVsWild * 100)}% of battles`)
	check("Rival beats Tamer more often than not", rivalVsTamer > 0.5)
	check("Tamer beats Wild clearly", tamerVsWild >= 0.58)
end

------------------------------------------------------------------------------------------------
print("\n== Replay ==")
do
	local function run(tier: BattleAi.Tier): Battle.State
		local rng = Rng.new(1234)
		local state = play(randomTeam(rng, 3, "a"), randomTeam(rng, 3, "b"), tier, "Wild", 4242)
		return state
	end
	for _, tier: BattleAi.Tier in TIERS do
		local one, two = run(tier), run(tier)
		local same = one.turn == two.turn and one.winner == two.winner and #one.log == #two.log
		for index, event in one.log do
			same = same and event.text == two.log[index].text
		end
		check(`the same seed gives the same battle ({tier} against Wild)`, same)
	end
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("battle AI checks failed")
end
