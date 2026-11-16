--!strict
-- Checks and measurements for the battle core. Run from the prototype folder:  lune run tests/battle.test

local Battle = require("../src/shared/Battle")
local BattleConfig = require("../src/config/BattleConfig")
local BreedConfig = require("../src/config/BreedConfig")
local Breeding = require("../src/shared/Breeding")
local Rng = require("../src/shared/Rng")
local TypeChart = require("../src/shared/TypeChart")
local Types = require("../src/shared/Types")
local Placeholders = require("./fixtures/Placeholders")

Placeholders.install()

type Creature = Types.Creature

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

local NAMES = { "Mossback", "Dartlet", "Brindle" }
local LEVEL = BattleConfig.RANKED_LEVEL

local function build(id: string, choice: { string }, quality: number?): Creature
	local function part(index: number): Types.Part
		return { species = choice[index], quality = quality or 5 }
	end
	local parts: Types.Parts =
		{ Head = part(1), Torso = part(2), FrontLimbs = part(3), Legs = part(4), Tail = part(5) }
	return {
		id = id,
		bodyPlan = "Quad",
		parts = parts,
		size = 1,
		colour = { shown = "Moss", carried = "Moss" },
		rarity = "Common",
		level = LEVEL,
		generation = 0,
		parents = nil,
		breedCount = 0,
		breedReadyAt = 0,
		originBiome = 1,
		isGiant = false,
		bound = false,
	}
end

local function pure(name: string, id: string?): Creature
	return build(id or name, { name, name, name, name, name })
end

-- 1v1 between two creatures; returns the winner (1 or 2) and the number of turns.
local function duel(a: Creature, b: Creature): (number, number)
	local state = Battle.new({ Battle.fighter(a) }, { Battle.fighter(b) }, 1, true)
	Battle.autoPlay(state)
	return state.winner :: number, state.turn
end

------------------------------------------------------------------------------------------------
print("\n== Type chart ==")
do
	local ok, mutual = true, false
	local weakCount: { [string]: number } = {}
	for _, element: Types.Element in TypeChart.ELEMENTS do
		ok = ok and #TypeChart.STRONG[element] == 2
		for _, target: Types.Element in TypeChart.STRONG[element] do
			weakCount[target] = (weakCount[target] or 0) + 1
			mutual = mutual or TypeChart.isStrong(target, element)
		end
	end
	for _, element in TypeChart.ELEMENTS do
		ok = ok and weakCount[element] == 2
	end
	check("every type is strong against two and weak against two", ok)
	check("no two types are strong against each other", not mutual)
	check(
		"the launch types form a triangle: Leaf beats Water, Water beats Sand, Sand beats Leaf",
		TypeChart.isStrong("Leaf", "Water")
			and TypeChart.isStrong("Water", "Sand")
			and TypeChart.isStrong("Sand", "Leaf")
	)
end

------------------------------------------------------------------------------------------------
print("\n== Worked example: a 3v3 battle, turn by turn ==")
do
	local teamA = {
		Battle.fighter(pure("Dartlet", "A-Dartlet")),
		Battle.fighter(pure("Mossback", "A-Mossback")),
		Battle.fighter(pure("Brindle", "A-Brindle")),
	}
	local teamB = {
		Battle.fighter(pure("Brindle", "B-Brindle")),
		Battle.fighter(pure("Dartlet", "B-Dartlet")),
		Battle.fighter(pure("Mossback", "B-Mossback")),
	}
	for _, f in teamA do
		print(
			`  {f.creature.id}: {f.element}  HP {f.stats.Hp} Atk {f.stats.Attack} Def {f.stats.Defence} Spd {f.stats.Speed}  moves: {table.concat(
				f.moves,
				", "
			)}`
		)
	end
	local state = Battle.new(teamA, teamB, 2026, false)
	Battle.autoPlay(state)
	local lastTurn = 0
	for _, event in state.log do
		if event.turn <= 4 or event.turn >= state.turn - 1 then
			if event.turn ~= lastTurn then
				print(`  turn {event.turn}`)
				lastTurn = event.turn
			end
			print(`    side {event.side}: {event.text}`)
		elseif event.turn == 5 and lastTurn ~= 5 then
			print("    ...")
			lastTurn = 5
		end
	end
	print(`  side {state.winner} wins in {state.turn} turns`)
	check("a battle always ends", state.winner ~= nil)
	local replay = Battle.autoPlay(Battle.new({
		Battle.fighter(pure("Dartlet", "A-Dartlet")),
		Battle.fighter(pure("Mossback", "A-Mossback")),
		Battle.fighter(pure("Brindle", "A-Brindle")),
	}, {
		Battle.fighter(pure("Brindle", "B-Brindle")),
		Battle.fighter(pure("Dartlet", "B-Dartlet")),
		Battle.fighter(pure("Mossback", "B-Mossback")),
	}, 2026, false))
	check(
		"the same seed and choices replay the same battle",
		replay.turn == state.turn and replay.winner == state.winner and #replay.log == #state.log
	)
end

------------------------------------------------------------------------------------------------
print("\n== Pacing: how long do battles last? ==")
do
	local rng = Rng.new(31)
	local function randomTeam(prefix: string): { Battle.Fighter }
		local team = {}
		for index = 1, 3 do
			local c =
				Breeding.wild(Rng.pick(rng, NAMES), `{prefix}{index}`, LEVEL, "Common", "Moss", rng)
			table.insert(team, Battle.fighter(c))
		end
		return team
	end
	local turns, battles, longest, shortest = 0, 500, 0, math.huge
	for seed = 1, battles do
		local state = Battle.autoPlay(Battle.new(randomTeam("a"), randomTeam("b"), seed, false))
		turns += state.turn
		longest, shortest = math.max(longest, state.turn), math.min(shortest, state.turn)
	end
	local mean = turns / battles
	print(
		`  3v3 between random teams: {string.format("%.1f", mean)} turns on average (shortest {shortest}, longest {longest})`
	)
	check(
		"a 3v3 lasts 8 to 14 turns on average (target from the research)",
		mean >= 8 and mean <= 14
	)
	local oneTurns = 0
	for _, a in NAMES do
		for _, b in NAMES do
			local _, t = duel(pure(a, "x"), pure(b, "y"))
			oneTurns += t
		end
	end
	print(`  1v1 between pure species: {string.format("%.1f", oneTurns / 9)} turns on average`)
end

------------------------------------------------------------------------------------------------
print("\n== Does a 1% Speed edge decide a mirror match? ==")
do
	-- Two identical creatures, except one has legs one quality pip higher (+1% Speed only).
	local function outcome(band: number, tempo: number): (number, number)
		local savedBand, savedTempo = BattleConfig.SPEED_BAND, BattleConfig.TEMPO_GAIN
		BattleConfig.SPEED_BAND, BattleConfig.TEMPO_GAIN = band, tempo
		local wins, draws, total = 0, 0, 0
		for _, name in NAMES do
			for _, q in { 3, 5, 7 } do
				local fast = build("fast", { name, name, name, name, name }, q)
				fast.parts.Legs = { species = name, quality = q + 1 }
				local slow = build("slow", { name, name, name, name, name }, q)
				type Pair = { a: Creature, b: Creature, fastSide: number }
				local pairs: { Pair } =
					{ { a = fast, b = slow, fastSide = 1 }, { a = slow, b = fast, fastSide = 2 } }
				for _, pair in pairs do
					local winner = duel(pair.a, pair.b)
					if winner == pair.fastSide then
						wins += 1
					elseif winner == 0 then
						draws += 1
					end
					total += 1
				end
			end
		end
		BattleConfig.SPEED_BAND, BattleConfig.TEMPO_GAIN = savedBand, savedTempo
		return wins / total, draws / total
	end
	local strictWins = outcome(0, 0)
	local wins, draws = outcome(BattleConfig.SPEED_BAND, BattleConfig.TEMPO_GAIN)
	print(
		`  strict Speed order: the 1% faster creature wins {math.floor(strictWins * 100)}% of mirrors`
	)
	print(
		`  Speed band and Tempo: it wins {math.floor(wins * 100)}%, and {math.floor(draws * 100)}% are draws`
	)
	check("with strict order a 1% Speed edge wins every mirror (the problem)", strictWins >= 0.9)
	check("with the band and Tempo a 1% Speed edge no longer decides the fight", wins <= 0.2)
end

------------------------------------------------------------------------------------------------
local function tournament(title: string, strict: boolean)
	print("\n== " .. title .. " ==")
	local builds: { { creature: Creature, label: string, pure: boolean } } = {}
	local choice = {}
	local function enumerate(index: number)
		if index > #BreedConfig.SLOTS then
			local label = table.concat(choice, "/")
			local isPure = choice[1] == choice[2]
				and choice[2] == choice[3]
				and choice[3] == choice[4]
				and choice[4] == choice[5]
			table.insert(
				builds,
				{ creature = build(label, table.clone(choice)), label = label, pure = isPure }
			)
			return
		end
		for _, name in NAMES do
			choice[index] = name
			enumerate(index + 1)
		end
	end
	enumerate(1)

	local wins = table.create(#builds, 0)
	for i = 1, #builds do
		for j = i + 1, #builds do
			-- Each pair fights twice, swapping sides, so side order cannot favour anyone.
			for _, order in { { i, j }, { j, i } } do
				local winner = duel(builds[order[1]].creature, builds[order[2]].creature)
				if winner == 0 then
					wins[order[1]] += 0.5
					wins[order[2]] += 0.5
				else
					wins[order[winner]] += 1
				end
			end
		end
	end
	local games = (#builds - 1) * 2
	local ranked = {}
	for index, entry in builds do
		table.insert(ranked, { label = entry.label, pure = entry.pure, rate = wins[index] / games })
	end
	table.sort(ranked, function(a, b)
		return a.rate > b.rate
	end)
	print("  top five builds (head/torso/front limbs/legs/tail):")
	for index = 1, 5 do
		print(`    {string.format("%3d%%", ranked[index].rate * 100)}  {ranked[index].label}`)
	end
	local bestPure = 0
	for _, entry in ranked do
		if entry.pure then
			print(`    pure {entry.label:split("/")[1]}: {string.format("%d%%", entry.rate * 100)}`)
			bestPure = math.max(bestPure, entry.rate)
		end
	end
	local torsos: { [string]: boolean } = {}
	for index = 1, 10 do
		torsos[ranked[index].label:split("/")[2]] = true
	end
	local distinct = 0
	for _ in torsos do
		distinct += 1
	end
	if not strict then
		return
	end
	check(
		"the best pure species wins at least half its fights",
		bestPure >= 0.5,
		string.format("%d%%", bestPure * 100)
	)
	check("the top ten builds use more than one torso", distinct > 1, `{distinct} torsos`)
end

tournament("Which builds win? All 243 part combinations, everyone fights everyone", true)

-- The same tournament with type match-ups switched off, to separate "this species has good parts"
-- from "this species has a type advantage over the other two example species".
do
	local strong, weak = TypeChart.STRONG_MULTIPLIER, TypeChart.WEAK_MULTIPLIER
	TypeChart.STRONG_MULTIPLIER, TypeChart.WEAK_MULTIPLIER = 1, 1
	tournament("The same tournament with type match-ups switched off", false)
	TypeChart.STRONG_MULTIPLIER, TypeChart.WEAK_MULTIPLIER = strong, weak
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("battle checks failed")
end
