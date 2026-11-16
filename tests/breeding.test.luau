--!strict
-- Worked examples and simulation tests for the breeding prototype.
-- Run from the prototype folder:  lune run tests/breeding.test

local AssemblyMath = require("../src/shared/AssemblyMath")
local BreedConfig = require("../src/config/BreedConfig")
local Breeding = require("../src/shared/Breeding")
local Rng = require("../src/shared/Rng")
local Species = require("../src/content/Species")
local Stats = require("../src/shared/Stats")
local Types = require("../src/shared/Types")
local Placeholders = require("./fixtures/Placeholders")

Placeholders.install()

type Creature = Types.Creature

local passed, failed = 0, 0
local function check(name: string, condition: boolean, detail: string?)
	if condition then
		passed += 1
		print(`  PASS  {name}{if detail then "  (" .. detail .. ")" else ""}`)
	else
		failed += 1
		print(`  FAIL  {name}{if detail then "  (" .. detail .. ")" else ""}`)
	end
end

local function describe(c: Creature): string
	local bits = {}
	for _, slot: Types.Slot in BreedConfig.SLOTS do
		table.insert(bits, `{slot}={c.parts[slot].species}:{c.parts[slot].quality}`)
	end
	return table.concat(bits, " ")
end

local function statLine(s: Stats.StatBlock): string
	return `HP {s.Hp}  Atk {s.Attack}  Def {s.Defence}  Spd {s.Speed}`
end

local nextId = 0
local function newId(): string
	nextId += 1
	return `c{nextId}`
end

------------------------------------------------------------------------------------------------
print("\n== Example 1: the brief's case, a small fast mother and a big father ==")
do
	local rng = Rng.new(2026)
	local mother = Breeding.wild("Dartlet", "mother", 50, "Common", "Moss", rng)
	local father = Breeding.wild("Mossback", "father", 45, "Common", "Bark", rng)
	for _, slot: Types.Slot in BreedConfig.SLOTS do
		mother.parts[slot].quality, father.parts[slot].quality = 5, 5
	end
	print("  mother  " .. statLine(Stats.compute(mother)) .. `   fit {Stats.fit(mother)}`)
	print("  father  " .. statLine(Stats.compute(father)) .. `   fit {Stats.fit(father)}`)

	-- The child from the brief: father's torso, mother's legs.
	local child = table.clone(father)
	child.parts = table.clone(father.parts)
	child.parts.Legs = mother.parts.Legs
	child.level = 1
	local fit = Stats.fit(child)
	local legSpeed = Species.Dartlet.parts.Legs.stats.Speed :: number
	print(
		`  child with father's torso and mother's legs: fit {string.format("%.2f", fit)}, leg Speed {legSpeed} x {string.format(
			"%.2f",
			fit
		)} = {legSpeed * fit}`
	)
	check(
		"small legs on a heavy body are slowed to the fit floor",
		math.abs(fit - BreedConfig.FIT_MIN) < 1e-9
	)
	check("leg Speed 80 becomes 48 on the heavy body", math.abs(legSpeed * fit - 48) < 1e-9)
	local scale = AssemblyMath.partScale("Mossback", "Legs", "Dartlet")
	print(
		`  the legs are drawn {string.format("%.2f", scale)}x bigger to fill the socket; ride height {string.format(
			"%.2f",
			AssemblyMath.rideHeight(child)
		)} studs`
	)
	check(
		"donor legs are scaled up, within the clamp",
		scale > 1 and scale <= AssemblyMath.SCALE_MAX
	)

	local preview = Breeding.preview(mother, father)
	print(`  preview: child level {preview.level}, cost {preview.cost} coins`)
	print("    lowest   " .. statLine(preview.statRange.low))
	print("    highest  " .. statLine(preview.statRange.high))
	check("offspring level is 40% of the parents' average (50 and 45 give 19)", preview.level == 19)
end

------------------------------------------------------------------------------------------------
print("\n== Example 2: one real breed, step by step ==")
do
	local rng = Rng.new(8)
	local a = Breeding.wild("Brindle", "A", 20, "Uncommon", "Moss", rng)
	local b = Breeding.wild("Dartlet", "B", 18, "Common", "Sand", rng)
	b.colour.carried = "Ember" -- B carries a rare colour without showing it
	print("  A  " .. describe(a))
	print("  B  " .. describe(b))
	local result = Breeding.breed(
		a,
		b,
		rng,
		{ childId = "child", now = 1000, charm = { slot = "Legs", favour = "B" } }
	)
	local child = result.child
	print("  child  " .. describe(child))
	print(
		`  child  level {child.level}, {child.rarity}, size {child.size}, colour {child.colour.shown} (carries {child.colour.carried}), generation {child.generation}`
	)
	print("  child  " .. statLine(Stats.compute(child)))
	print(`  moves to choose from: {table.concat(Stats.movePool(child), ", ")}`)
	print(
		`  cost {result.cost} coins; hatches in {(result.hatchAt - 1000) / 60} min; A rests {(result.parentA.breedReadyAt - 1000) / 60} min`
	)
	check(
		"every child part comes from one of the two parents",
		(function()
			for _, slot: Types.Slot in BreedConfig.SLOTS do
				local s = child.parts[slot].species
				if s ~= a.parts[slot].species and s ~= b.parts[slot].species then
					return false
				end
			end
			return true
		end)()
	)
	local again = Breeding.breed(a, b, Rng.new(99), { childId = "x", now = 1000 })
	local replay = Breeding.breed(a, b, Rng.new(99), { childId = "x", now = 1000 })
	check(
		"the same seed gives the same child (replayable from the breed log)",
		describe(again.child) == describe(replay.child)
	)
end

------------------------------------------------------------------------------------------------
print("\n== Rules ==")
do
	local rng = Rng.new(11)
	local a = Breeding.wild("Brindle", newId(), 10, "Common", "Moss", rng)
	local b = Breeding.wild("Dartlet", newId(), 10, "Common", "Moss", rng)
	local child = Breeding.breed(a, b, rng, { childId = newId(), now = 0 }).child
	local okKin = Breeding.canBreed(a, child, 10 ^ 9)
	check("parent and child cannot breed", not okKin)
	local sibling = Breeding.breed(a, b, rng, { childId = newId(), now = 0 }).child
	check("full siblings cannot breed", not Breeding.canBreed(child, sibling, 10 ^ 9))
	local veteran = table.clone(a)
	veteran.breedCount = 40
	check(
		"there is no breed limit: a creature can breed any number of times",
		(Breeding.canBreed(veteran, b, 10 ^ 9))
	)
	check(
		"later breeds cost more coins, up to a cap",
		Breeding.cost(veteran, b) > Breeding.cost(a, b)
	)
	local ruby = table.clone(a)
	ruby.rarity = "Ruby"
	check(
		"candy follows the rarer parent",
		Breeding.candyCost(a, b) == BreedConfig.CANDY_COST.Common
			and Breeding.candyCost(ruby, b) == BreedConfig.CANDY_COST.Ruby,
		`common pair {Breeding.candyCost(a, b)}, with a Ruby parent {Breeding.candyCost(ruby, b)}`
	)
	local resting = table.clone(a)
	resting.breedReadyAt = 500
	check("a resting creature cannot breed", not Breeding.canBreed(resting, b, 499))
	local lateParent = table.clone(a)
	lateParent.originBiome = 7
	local lateChild = Breeding.breed(lateParent, b, rng, { childId = newId(), now = 0 }).child
	check("the child takes the later parent's biome", lateChild.originBiome == 7)
	check(
		"a late-biome parent makes the breed 7x the price",
		Breeding.cost(lateParent, b) == 7 * Breeding.cost(a, b)
	)
end

------------------------------------------------------------------------------------------------
print("\n== Simulation 1: stats cannot ratchet (always keep the best of 8, 50 generations) ==")
do
	-- Ignores breed limits and the kin rule on purpose: this is the worst case for runaway stats.
	local function total(c: Creature): number
		local s = Stats.compute(c, 50)
		return s.Hp + s.Attack + s.Defence + s.Speed
	end
	-- The ceiling: best species part in every slot, quality 10, best fit, at level 50.
	local ceiling = 0
	for _, slot: Types.Slot in BreedConfig.SLOTS do
		local best = 0
		for _, def in Species do
			local sum = 0
			for stat, base in def.parts[slot].stats do
				sum += base * (if slot == "Legs" and stat == "Speed" then BreedConfig.FIT_MAX else 1)
			end
			best = math.max(best, sum)
		end
		ceiling += best * Stats.qualityMultiplier(BreedConfig.QUALITY_MAX)
	end
	ceiling *= Stats.levelScale(50)

	local worst, lineages = 0, 300
	local startSum, endSum = 0, 0
	for lineage = 1, lineages do
		local rng = Rng.new(1000 + lineage)
		local names = { "Mossback", "Dartlet", "Brindle" }
		local a = Breeding.wild(Rng.pick(rng, names), newId(), 50, "Common", "Moss", rng)
		local b = Breeding.wild(Rng.pick(rng, names), newId(), 50, "Common", "Moss", rng)
		startSum += math.max(total(a), total(b))
		for _ = 1, 50 do
			local kids = {}
			for _ = 1, 8 do
				local pa, pb = table.clone(a), table.clone(b)
				pa.breedCount, pb.breedCount, pa.parents, pb.parents = 0, 0, nil, nil
				table.insert(
					kids,
					Breeding.breed(pa, pb, rng, { childId = newId(), now = 0 }).child
				)
			end
			table.sort(kids, function(x, y)
				return total(x) > total(y)
			end)
			a, b = kids[1], kids[2]
			a.level, b.level = 50, 50
		end
		endSum += total(a)
		worst = math.max(worst, total(a))
	end
	print(
		`  average best starting total {math.floor(startSum / lineages)}; after 50 generations {math.floor(
			endSum / lineages
		)}; highest ever {worst}; ceiling {math.floor(ceiling)}`
	)
	check("no lineage ever passes the computed ceiling", worst <= ceiling)
	check("selection still improves creatures (continuous improvement)", endSum > startSum)
end

------------------------------------------------------------------------------------------------
print("\n== Simulation 2: same parts, different breeding paths, same stats ==")
do
	local rng = Rng.new(5)
	local base = Breeding.wild("Mossback", "p", 30, "Common", "Moss", rng)
	base.parts.Legs = { species = "Dartlet", quality = 6 }
	local reference = statLine(Stats.compute(base))
	local same = true
	for generation = 1, 200 do
		local copy = table.clone(base)
		copy.generation = generation
		copy.parents = { "x" .. generation, "y" .. generation }
		copy.breedCount = generation % 3
		same = same and statLine(Stats.compute(copy)) == reference
	end
	check("stats depend only on parts, size, level and rarity, never on history", same, reference)
end

------------------------------------------------------------------------------------------------
print("\n== Simulation 3: with random mating, quality stays centred ==")
do
	local rng = Rng.new(42)
	local population: { Creature } = {}
	for _ = 1, 200 do
		table.insert(population, Breeding.wild("Brindle", newId(), 10, "Common", "Moss", rng))
	end
	for _ = 1, 100 do
		local nextGen: { Creature } = {}
		for _ = 1, #population do
			local a, b =
				table.clone(Rng.pick(rng, population)), table.clone(Rng.pick(rng, population))
			if a.id == b.id then
				b.id = newId()
			end
			a.breedCount, b.breedCount, a.parents, b.parents = 0, 0, nil, nil
			table.insert(nextGen, Breeding.breed(a, b, rng, { childId = newId(), now = 0 }).child)
		end
		population = nextGen
	end
	local sum, count, lowest, highest = 0, 0, 10, 0
	for _, c in population do
		for _, slot: Types.Slot in BreedConfig.SLOTS do
			local q = c.parts[slot].quality
			sum, count = sum + q, count + 1
			lowest, highest = math.min(lowest, q), math.max(highest, q)
		end
	end
	local mean = sum / count
	check(
		"mean quality stays between 4.5 and 5.5 after 100 generations",
		mean > 4.5 and mean < 5.5,
		string.format("mean %.2f", mean)
	)
	check("quality never leaves 0..10", lowest >= 0 and highest <= 10, `range {lowest}..{highest}`)
end

------------------------------------------------------------------------------------------------
print("\n== Simulation 4: rarity odds match the config, and rares are paid for in candy ==")
do
	local rng = Rng.new(77)
	local function measure(ra: Types.Rarity, rb: Types.Rarity, tier: Types.Rarity): number
		local hits, trials = 0, 40000
		local a = Breeding.wild("Brindle", "ra", 10, ra, "Moss", rng)
		local b = Breeding.wild("Dartlet", "rb", 10, rb, "Moss", rng)
		for _ = 1, trials do
			if Breeding.breed(a, b, rng, { childId = "k", now = 0 }).child.rarity == tier then
				hits += 1
			end
		end
		return hits / trials
	end
	type Case = { a: Types.Rarity, b: Types.Rarity, tier: Types.Rarity, expected: number }
	local inherit = BreedConfig.RARITY_INHERIT
	local cases: { Case } = {
		{ a = "Gem", b = "Gem", tier = "Gem", expected = inherit.Gem.both },
		{ a = "Gem", b = "Common", tier = "Gem", expected = inherit.Gem.one },
		{ a = "Ruby", b = "Ruby", tier = "Ruby", expected = inherit.Ruby.both },
		{ a = "Ruby", b = "Uncommon", tier = "Ruby", expected = inherit.Ruby.one },
		{ a = "Diamond", b = "Diamond", tier = "Diamond", expected = inherit.Diamond.both },
	}
	for _, case in cases do
		local got = measure(case.a, case.b, case.tier)
		check(
			`{case.a} x {case.b} gives {case.tier}`,
			math.abs(got - case.expected) < 0.01,
			string.format("%.3f, expected %.2f", got, case.expected)
		)
	end
	local odds = Breeding.rarityOdds(
		Breeding.wild("Brindle", "d", 1, "Diamond", "Moss", rng),
		Breeding.wild("Brindle", "g", 1, "Gem", "Moss", rng)
	)
	local sum = 0
	for _, rarity: Types.Rarity in BreedConfig.RARITY_ORDER do
		sum += odds[rarity] or 0
	end
	check("rarity odds always sum to 100%", math.abs(sum - 1) < 1e-9)
	-- Supply is capped by candy income, not by a breed limit: candies needed per rare child from a pure pair.
	local gemTiers: { Types.Rarity } = { "Gem", "Ruby", "Diamond" }
	for _, tier: Types.Rarity in gemTiers do
		local rule = assert(BreedConfig.RARITY_INHERIT[tier], "gem tiers have inheritance odds")
		local perChild = BreedConfig.CANDY_COST[tier] / rule.both
		check(
			`{tier}: a rare child costs many candies on average`,
			perChild >= 10,
			string.format("%.0f candies per %s child", perChild, tier)
		)
	end
end

------------------------------------------------------------------------------------------------
print("\n== Simulation 5: no hybrid build dominates ==")
do
	local names = { "Mossback", "Dartlet", "Brindle" }
	local function make(choice: { string }): Creature
		local function part(index: number): Types.Part
			return { species = choice[index], quality = 5 }
		end
		local parts: Types.Parts = {
			Head = part(1),
			Torso = part(2),
			FrontLimbs = part(3),
			Legs = part(4),
			Tail = part(5),
		}
		return {
			id = "h",
			bodyPlan = "Quad",
			parts = parts,
			size = 1,
			colour = { shown = "Moss", carried = "Moss" },
			rarity = "Common",
			level = 50,
			generation = 0,
			parents = nil,
			breedCount = 0,
			breedReadyAt = 0,
			originBiome = 1,
			isGiant = false,
			bound = false,
		}
	end
	-- Compare builds by a simple power score so a tank and a sprinter are judged on the same scale.
	local function power(c: Creature): number
		local s = Stats.compute(c)
		return s.Hp / 4 + s.Attack + s.Defence + s.Speed
	end
	local bestPure, bestPureName = 0, ""
	for _, name in names do
		local p = power(make({ name, name, name, name, name }))
		if p > bestPure then
			bestPure, bestPureName = p, name
		end
	end
	local bestHybrid, bestChoice = 0, {}
	local choice = {}
	local function search(index: number)
		if index > #BreedConfig.SLOTS then
			local p = power(make(choice))
			if p > bestHybrid then
				bestHybrid, bestChoice = p, table.clone(choice)
			end
			return
		end
		for _, name in names do
			choice[index] = name
			search(index + 1)
		end
	end
	search(1)
	local lead = bestHybrid / bestPure - 1
	print(
		`  best pure species: {bestPureName} ({math.floor(bestPure)}); best of all 243 builds: {table.concat(
			bestChoice,
			"/"
		)} ({math.floor(bestHybrid)})`
	)
	check(
		"the best hybrid beats the best pure species by no more than the budget cap allows",
		lead <= BreedConfig.BUDGET_CAP - 1 + 0.01,
		string.format("+%.1f%%", lead * 100)
	)
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("tests failed")
end
