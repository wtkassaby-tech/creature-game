--!strict
-- The Greenwood roster: data checks and the roster balance gate (docs/DECISIONS.md).
-- Run from the project folder:  lune run tests/roster.test
--
-- The gate builds every combination of parts on each body plan, picks a fixed, seeded field
-- (every pure species, the five best builds by each stat and by total, then a random sample),
-- and has every pair fight twice with sides swapped, using the real battle rules, at the
-- Greenwood level cap and at the ranked level. Results are in docs/content/GREENWOOD_ROSTER.md.

local AssemblyMath = require("../src/shared/AssemblyMath")
local Battle = require("../src/shared/Battle")
local BattleConfig = require("../src/config/BattleConfig")
local BreedConfig = require("../src/config/BreedConfig")
local Breeding = require("../src/shared/Breeding")
local Moves = require("../src/content/Moves")
local Rng = require("../src/shared/Rng")
local Species = require("../src/content/Species")
local Types = require("../src/shared/Types")

type Creature = Types.Creature
type Fighter = Battle.Fighter

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

local BIOME = 1
local GREENWOOD_CAP = 15 -- level cap before the first badge (docs/DECISIONS.md)
local RANKED = BattleConfig.RANKED_LEVEL
local FIELD_SIZE = 160
local FIELD_SEED = 2026
local MAX_WIN = 0.75
local MIN_PURE = 0.40
local PACE_MIN, PACE_MAX = 8, 14
local STARTERS: { [string]: Types.Element } =
	{ Mossmitt = "Leaf", Spadesnout = "Sand", Sloshcalf = "Water" }
local PLANS: { Types.BodyPlan } = { "Quad", "Biped" }

local roster: { string } = {}
local byPlan: { [string]: { string } } = { Quad = {}, Biped = {} }
for name, def in Species do
	if def.biome == BIOME then
		table.insert(roster, name)
		local list = byPlan[def.bodyPlan]
		if list then
			table.insert(list, name)
		end
	end
end
table.sort(roster)
table.sort(byPlan.Quad)
table.sort(byPlan.Biped)

local function fmtPct(x: number): string
	return string.format("%d%%", math.floor(x * 100 + 0.5))
end

------------------------------------------------------------------------------------------------
print("\n== Roster data ==")
do
	check("Greenwood has eight species", #roster == 8, `{#roster}`)
	check(
		"each body plan has at least three species (four each is the aim)",
		#byPlan.Quad >= 3 and #byPlan.Biped >= 3,
		`{#byPlan.Quad} four-legged, {#byPlan.Biped} two-legged`
	)

	local registryOk = true
	for name, def in Species do
		registryOk = registryOk and def.name == name
	end
	check("every species is in the registry under its own name", registryOk)

	local counts: { [string]: number } = {}
	local rarities: { [string]: number } = {}
	for _, name in roster do
		local def = Species[name]
		counts[def.element] = (counts[def.element] or 0) + 1
		rarities[def.baseRarity] = (rarities[def.baseRarity] or 0) + 1
	end
	check(
		"most species are Leaf, with at least one Sand and one Water",
		(counts.Leaf or 0) > #roster / 2 and (counts.Sand or 0) >= 1 and (counts.Water or 0) >= 1,
		`Leaf {counts.Leaf or 0}, Sand {counts.Sand or 0}, Water {counts.Water or 0}`
	)
	check(
		"six or seven Common and one or two Uncommon",
		(rarities.Common or 0) >= 6
			and (rarities.Common or 0) <= 7
			and (rarities.Uncommon or 0) >= 1
			and (rarities.Uncommon or 0) <= 2
			and (rarities.Common or 0) + (rarities.Uncommon or 0) == #roster,
		`{rarities.Common or 0} Common, {rarities.Uncommon or 0} Uncommon`
	)

	local startersOk = true
	for name, element in STARTERS do
		local def = Species[name]
		startersOk = startersOk
			and def ~= nil
			and def.element == element
			and def.baseRarity == "Common"
	end
	check("the three starters exist and are one each of Leaf, Sand and Water", startersOk)

	local hardestCommon, easiestUncommon = 0, math.huge
	for _, name in roster do
		local def = Species[name]
		if def.baseRarity == "Common" then
			hardestCommon = math.max(hardestCommon, def.lassoDifficulty)
		else
			easiestUncommon = math.min(easiestUncommon, def.lassoDifficulty)
		end
	end
	check(
		"commons are easy to lasso and uncommons harder",
		hardestCommon <= 1.1 and easiestUncommon > hardestCommon,
		`commons up to {hardestCommon}, uncommons from {easiestUncommon}`
	)

	local movesOk, levelsOk, firstOk, positiveOk = true, true, true, true
	local missing: { string } = {}
	local problems: { string } = {}
	local used: { [string]: boolean } = {}
	for _, name in roster do
		local def = Species[name]
		positiveOk = positiveOk
			and def.weight > 0
			and def.torsoLength > 0
			and def.lassoDifficulty >= 1
		for _, slot: Types.Slot in BreedConfig.SLOTS do
			local part = def.parts[slot]
			local hasStat = false
			for _, value in part.stats do
				hasStat = true
				positiveOk = positiveOk and value > 0
			end
			positiveOk = positiveOk and hasStat and part.length > 0
			if slot == "Torso" then
				positiveOk = positiveOk and part.plugRadius == 0 and def.socketRadius.Torso == 0
			else
				positiveOk = positiveOk and part.plugRadius > 0 and def.socketRadius[slot] > 0
			end
			if #part.moves < 1 or #part.moves > 2 then
				firstOk = false
				table.insert(problems, `{name} {slot} has {#part.moves} moves`)
			end
			for index, unlock in part.moves do
				used[unlock.name] = true
				if Moves[unlock.name] == nil then
					movesOk = false
					table.insert(missing, `{name} {slot}: no move called {unlock.name}`)
				end
				if unlock.level < 1 or unlock.level > GREENWOOD_CAP then
					levelsOk = false
				end
				if index == 1 and unlock.level ~= 1 then
					firstOk = false
					table.insert(problems, `{name} {slot}: first move unlocks at {unlock.level}`)
				end
				if index > 1 and unlock.level > 12 then
					firstOk = false
					table.insert(problems, `{name} {slot}: second move unlocks at {unlock.level}`)
				end
			end
		end
	end
	check("every move a part names exists in Moves", movesOk, table.concat(missing, "; "))
	check("unlock levels are within 1 to 15", levelsOk)
	check(
		"each part brings one or two moves: the first at level 1, any second by level 12",
		firstOk,
		table.concat(problems, "; ")
	)
	check("stats, weights, lengths and radii are positive", positiveOk)

	local distinct, powerOk = 0, true
	for moveName in used do
		distinct += 1
		local power = Moves[moveName].power
		powerOk = powerOk and power >= 35 and power <= 70
	end
	check("20 to 24 distinct moves", distinct >= 20 and distinct <= 24, `{distinct}`)
	check("move power is between 35 and 70", powerOk)

	-- Budget score at quality 5 (fit is 1 for a pure species): Hp x weight + Attack + Defence + Speed.
	local budgetOk = true
	local lines: { string } = {}
	for _, name in roster do
		local def = Species[name]
		local score = 0
		for _, slot: Types.Slot in BreedConfig.SLOTS do
			local stats = def.parts[slot].stats
			score += (stats.Hp or 0) * BreedConfig.BUDGET_HP_WEIGHT + (stats.Attack or 0) + (stats.Defence or 0) + (stats.Speed or 0)
		end
		local target = BreedConfig.PLAN_BUDGET[def.bodyPlan]
		local off = score / target - 1
		budgetOk = budgetOk and math.abs(off) <= 0.05
		table.insert(lines, string.format("%s %.0f", name, score))
	end
	check(
		"each species' budget score is within 5% of its body plan's budget",
		budgetOk,
		table.concat(lines, ", ")
	)

	-- Every part fits every torso of its plan without hitting the assembler's scale limits.
	local fitsOk = true
	local worst = ""
	for _, plan in PLANS do
		for _, torso in byPlan[plan] do
			for _, donor in byPlan[plan] do
				for _, slot: Types.Slot in BreedConfig.SLOTS do
					if slot ~= "Torso" then
						local raw = Species[torso].socketRadius[slot]
							/ Species[donor].parts[slot].plugRadius
						if raw < AssemblyMath.SCALE_MIN or raw > AssemblyMath.SCALE_MAX then
							fitsOk = false
							worst = `{donor} {slot} on {torso}: x{string.format("%.2f", raw)}`
						end
					end
				end
			end
		end
	end
	check(
		"every part fits every torso on its plan within the assembler's scale range",
		fitsOk,
		worst
	)
end

------------------------------------------------------------------------------------------------
type Entry = { label: string, choice: { string }, fighter: Fighter, pure: boolean }

local function build(plan: Types.BodyPlan, choice: { string }, level: number): Creature
	local function part(index: number): Types.Part
		return { species = choice[index], quality = 5 }
	end
	local parts: Types.Parts =
		{ Head = part(1), Torso = part(2), FrontLimbs = part(3), Legs = part(4), Tail = part(5) }
	return {
		id = table.concat(choice, "/"),
		bodyPlan = plan,
		parts = parts,
		size = 1,
		colour = { shown = "Moss", carried = "Moss" },
		rarity = "Common",
		level = level,
		xp = 0,
		generation = 0,
		parents = nil,
		breedCount = 0,
		breedReadyAt = 0,
		originBiome = BIOME,
		isGiant = false,
		bound = false,
	}
end

local function allBuilds(plan: Types.BodyPlan, level: number): { Entry }
	local names = byPlan[plan]
	local list: { Entry } = {}
	local choice: { string } = {}
	local function enumerate(index: number)
		if index > #BreedConfig.SLOTS then
			local picked = table.clone(choice)
			local isPure = true
			for _, name in picked do
				isPure = isPure and name == picked[1]
			end
			local creature = build(plan, picked, level)
			table.insert(list, {
				label = creature.id,
				choice = picked,
				fighter = Battle.fighter(creature, nil, level),
				pure = isPure,
			})
			return
		end
		for _, name in names do
			choice[index] = name
			enumerate(index + 1)
		end
	end
	enumerate(1)
	return list
end

local function total(entry: Entry): number
	local s = entry.fighter.stats
	return s.Hp * BreedConfig.BUDGET_HP_WEIGHT + s.Attack + s.Defence + s.Speed
end

-- The fixed field: every pure species, the five best builds by each stat and by total, then a
-- seeded random sample up to FIELD_SIZE.
local function pickField(builds: { Entry }): { Entry }
	local field: { Entry } = {}
	local seen: { [string]: boolean } = {}
	local function add(entry: Entry)
		if not seen[entry.label] then
			seen[entry.label] = true
			table.insert(field, entry)
		end
	end
	for _, entry in builds do
		if entry.pure then
			add(entry)
		end
	end
	local keys: { string } = { "Hp", "Attack", "Defence", "Speed", "Total" }
	for _, key in keys do
		local function value(entry: Entry): number
			local s = entry.fighter.stats
			if key == "Hp" then
				return s.Hp
			elseif key == "Attack" then
				return s.Attack
			elseif key == "Defence" then
				return s.Defence
			elseif key == "Speed" then
				return s.Speed
			end
			return total(entry)
		end
		local sorted = table.clone(builds)
		table.sort(sorted, function(a: Entry, b: Entry): boolean
			local va, vb = value(a), value(b)
			if va == vb then
				return a.label < b.label
			end
			return va > vb
		end)
		for index = 1, 5 do
			add(sorted[index])
		end
	end
	local rng = Rng.new(FIELD_SEED)
	while #field < math.min(FIELD_SIZE, #builds) do
		add(builds[Rng.int(rng, 1, #builds)])
	end
	return field
end

local function freshFighter(f: Fighter): Fighter
	return {
		creature = f.creature,
		element = f.element,
		level = f.level,
		stats = f.stats,
		hp = f.stats.Hp,
		tempo = 0,
		moves = f.moves,
	}
end

type Ranked = { entry: Entry, rate: number }

local function tournament(plan: Types.BodyPlan, level: number)
	local field = pickField(allBuilds(plan, level))
	local wins = table.create(#field, 0)
	local turns, fights = 0, 0
	for i = 1, #field do
		for j = i + 1, #field do
			-- Each pair fights twice, swapping sides, so side order cannot favour anyone.
			local orders: { { number } } = { { i, j }, { j, i } }
			for _, order in orders do
				local state = Battle.new(
					{ freshFighter(field[order[1]].fighter) },
					{ freshFighter(field[order[2]].fighter) },
					1,
					true
				)
				Battle.autoPlay(state)
				turns += state.turn
				fights += 1
				local winner = state.winner :: number
				if winner == 0 then
					wins[order[1]] += 0.5
					wins[order[2]] += 0.5
				else
					wins[order[winner]] += 1
				end
			end
		end
	end
	local games = (#field - 1) * 2
	local ranked: { Ranked } = {}
	for index, entry in field do
		table.insert(ranked, { entry = entry, rate = wins[index] / games })
	end
	table.sort(ranked, function(a: Ranked, b: Ranked): boolean
		if a.rate == b.rate then
			return a.entry.label < b.entry.label
		end
		return a.rate > b.rate
	end)

	print(
		`\n== {plan} builds at level {level}: {#field} builds, {fights} fights, {string.format(
			"%.1f",
			turns / fights
		)} turns per 1v1 ==`
	)
	print("  top ten (head/torso/front limbs/legs/tail):")
	local torsos: { [string]: boolean } = {}
	local legs: { [string]: boolean } = {}
	local torsoCount, legCount = 0, 0
	for index = 1, 10 do
		local r = ranked[index]
		local s = r.entry.fighter.stats
		print(
			`    {string.format("%3d%%", math.floor(r.rate * 100 + 0.5))}  {r.entry.label}  {r.entry.fighter.element}  Hp {s.Hp} Atk {s.Attack} Def {s.Defence} Spd {s.Speed}`
		)
		local torso, leg = r.entry.choice[2], r.entry.choice[4]
		if not torsos[torso] then
			torsos[torso] = true
			torsoCount += 1
		end
		if not legs[leg] then
			legs[leg] = true
			legCount += 1
		end
	end
	local minPure, pureLine = 1, {}
	for _, r in ranked do
		if r.entry.pure then
			minPure = math.min(minPure, r.rate)
			table.insert(pureLine, `{r.entry.choice[1]} {fmtPct(r.rate)}`)
		end
	end
	print(`  pure species: {table.concat(pureLine, ", ")}`)

	local where = `{plan}, level {level}`
	check(
		`{where}: no build wins more than {fmtPct(MAX_WIN)} of its fights`,
		ranked[1].rate <= MAX_WIN,
		`best {fmtPct(ranked[1].rate)}: {ranked[1].entry.label}`
	)
	check(
		`{where}: every pure species wins at least {fmtPct(MIN_PURE)}`,
		minPure >= MIN_PURE,
		`lowest {fmtPct(minPure)}`
	)
	check(
		`{where}: the top ten use at least two torsos and two leg sets`,
		torsoCount >= 2 and legCount >= 2,
		`{torsoCount} torsos, {legCount} leg sets`
	)
end

for _, plan: Types.BodyPlan in PLANS do
	tournament(plan, GREENWOOD_CAP)
	tournament(plan, RANKED)
end

------------------------------------------------------------------------------------------------
print("\n== Pacing: 3v3 between random wild teams from the roster ==")
do
	local function pace(level: number): (number, number, number)
		local rng = Rng.new(31)
		local function randomTeam(prefix: string): { Fighter }
			local team: { Fighter } = {}
			for index = 1, 3 do
				local creature = Breeding.wild(
					Rng.pick(rng, roster),
					`{prefix}{index}`,
					level,
					"Common",
					"Moss",
					rng
				)
				table.insert(team, Battle.fighter(creature))
			end
			return team
		end
		local turns, battles, shortest, longest = 0, 400, math.huge, 0
		for seed = 1, battles do
			local state = Battle.autoPlay(Battle.new(randomTeam("a"), randomTeam("b"), seed, false))
			turns += state.turn
			shortest, longest = math.min(shortest, state.turn), math.max(longest, state.turn)
		end
		return turns / battles, shortest, longest
	end
	for _, level in { 5, GREENWOOD_CAP, RANKED } do
		local mean, shortest, longest = pace(level)
		check(
			`level {level}: a 3v3 lasts {PACE_MIN} to {PACE_MAX} turns on average`,
			mean >= PACE_MIN and mean <= PACE_MAX,
			`{string.format("%.1f", mean)} turns, shortest {shortest}, longest {longest}`
		)
	end
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("roster checks failed")
end
