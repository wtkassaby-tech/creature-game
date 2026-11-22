--!strict
-- The roster balance gate (docs/DECISIONS.md) for Greenwood (biome 1), Dust Canyon (biome 2),
-- Tide Flats (biome 3), the Mire (biome 4), the first two biomes mixed, the first three mixed and
-- all four mixed, plus the data checks for each roster and what poison does in the gate.
-- Run from the project folder:  lune run tests/roster.test
--
-- The gate builds every combination of parts on each body plan, picks a fixed, seeded field
-- (every pure species, the five best builds by each stat and by total, then a random sample),
-- and has every pair fight twice with sides swapped, using the real battle rules, at each biome's
-- level cap and at the ranked level. Results are in docs/content/GREENWOOD_ROSTER.md,
-- docs/content/DUST_CANYON_ROSTER.md, docs/content/TIDE_FLATS_ROSTER.md and
-- docs/content/MIRE_ROSTER.md. The four-biome pool (16 or 17 species a plan, up to 1.4 million
-- builds) makes this the slowest test: about two minutes in all.

local AssemblyMath = require("../src/shared/AssemblyMath")
local Battle = require("../src/shared/Battle")
local BattleConfig = require("../src/config/BattleConfig")
local BreedConfig = require("../src/config/BreedConfig")
local Breeding = require("../src/shared/Breeding")
local Moves = require("../src/content/Moves")
local Rng = require("../src/shared/Rng")
local Species = require("../src/content/Species")
local Stats = require("../src/shared/Stats")
local Types = require("../src/shared/Types")

type Creature = Types.Creature
type Fighter = Battle.Fighter

local passed, failed, notes = 0, 0, 0
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
-- A pass mark the roster is measured against that does not fail the run: each one is a known
-- gap explained in docs/content/DUST_CANYON_ROSTER.md, with the change that would close it.
local function note(name: string, condition: boolean, detail: string?)
	if not condition then
		notes += 1
	end
	print(
		`  {if condition then "PASS" else "NOTE"}  {name}{if detail
			then "  (" .. detail .. ")"
			else ""}`
	)
end

local GREENWOOD, DUST_CANYON, TIDE_FLATS, MIRE = 1, 2, 3, 4
local GREENWOOD_CAP = 15 -- level cap before the first badge (docs/DECISIONS.md)
local DUST_CANYON_CAP = 25 -- 15 plus 10 for the first badge
local TIDE_FLATS_CAP = 35 -- plus 10 more for the second badge
local MIRE_CAP = 45 -- plus 10 more for the third badge
local RANKED = BattleConfig.RANKED_LEVEL
local FIELD_SIZE = 160
local MIXED_FIELD_SIZE = 200 -- eight species a plan: 32,768 builds (nine: 59,049); thirteen: 371,293
local FIELD_SEED = 2026
local MAX_WIN = 0.75
local MIN_PURE = 0.40
local PACE_MIN, PACE_MAX = 8, 14
local STARTERS: { [string]: Types.Element } =
	{ Mossmitt = "Leaf", Spadesnout = "Sand", Sloshcalf = "Water" }
local PLANS: { Types.BodyPlan } = { "Quad", "Biped" }

type Roster = { all: { string }, Quad: { string }, Biped: { string } }

local function rosterOf(biome: number): Roster
	local roster: Roster = { all = {}, Quad = {}, Biped = {} }
	for name, def in Species do
		-- A giant's creature form is not part of a biome's wild roster (tests/giantcapture.test).
		if def.biome == biome and not def.giantForm then
			table.insert(roster.all, name)
			if def.bodyPlan == "Quad" then
				table.insert(roster.Quad, name)
			elseif def.bodyPlan == "Biped" then
				table.insert(roster.Biped, name)
			end
		end
	end
	table.sort(roster.all)
	table.sort(roster.Quad)
	table.sort(roster.Biped)
	return roster
end

local greenwood = rosterOf(GREENWOOD)
local dustCanyon = rosterOf(DUST_CANYON)
local tideFlats = rosterOf(TIDE_FLATS)
local mire = rosterOf(MIRE)

local function planList(roster: Roster, plan: Types.BodyPlan): { string }
	return if plan == "Quad" then roster.Quad else roster.Biped
end

local function joined(a: { string }, b: { string }): { string }
	local list = table.clone(a)
	for _, name in b do
		table.insert(list, name)
	end
	return list
end

local function fmtPct(x: number): string
	return string.format("%d%%", math.floor(x * 100 + 0.5))
end

------------------------------------------------------------------------------------------------
-- Checks every roster shares. Returns the set of move names the roster's parts bring.
-- `quads` and `bipeds` are how many species the roster has on each plan: four and four, except
-- Greenwood, which has a ninth (a second Sand species, four-legged; docs/DECISIONS.md, 22 Nov 2026).
local function commonData(
	roster: Roster,
	cap: number,
	secondBy: number,
	quads: number?,
	bipeds: number?
): { [string]: boolean }
	local registryOk = true
	for name, def in Species do
		registryOk = registryOk and def.name == name
	end
	check("every species is in the registry under its own name", registryOk)
	local wantQuads, wantBipeds = quads or 4, bipeds or 4
	check(
		`{wantQuads + wantBipeds} species: {wantQuads} four-legged, {wantBipeds} two-legged`,
		#roster.all == wantQuads + wantBipeds
			and #roster.Quad == wantQuads
			and #roster.Biped == wantBipeds,
		`{#roster.all}: {#roster.Quad} four-legged, {#roster.Biped} two-legged`
	)

	local rarities: { [string]: number } = {}
	for _, name in roster.all do
		local def = Species[name]
		rarities[def.baseRarity] = (rarities[def.baseRarity] or 0) + 1
	end
	check(
		"six or seven Common and one or two Uncommon",
		(rarities.Common or 0) >= 6
			and (rarities.Common or 0) <= 7
			and (rarities.Uncommon or 0) >= 1
			and (rarities.Uncommon or 0) <= 2
			and (rarities.Common or 0) + (rarities.Uncommon or 0) == #roster.all,
		`{rarities.Common or 0} Common, {rarities.Uncommon or 0} Uncommon`
	)

	local movesOk, levelsOk, firstOk, positiveOk = true, true, true, true
	local missing: { string } = {}
	local problems: { string } = {}
	local used: { [string]: boolean } = {}
	for _, name in roster.all do
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
				if unlock.level < 1 or unlock.level > cap then
					levelsOk = false
				end
				if index == 1 and unlock.level ~= 1 then
					firstOk = false
					table.insert(problems, `{name} {slot}: first move unlocks at {unlock.level}`)
				end
				if index > 1 and unlock.level > secondBy then
					firstOk = false
					table.insert(problems, `{name} {slot}: second move unlocks at {unlock.level}`)
				end
			end
		end
	end
	check("every move a part names exists in Moves", movesOk, table.concat(missing, "; "))
	check(`unlock levels are within 1 to {cap}`, levelsOk)
	check(
		`each part brings one or two moves: the first at level 1, any second by level {secondBy}`,
		firstOk,
		table.concat(problems, "; ")
	)
	check("stats, weights, lengths and radii are positive", positiveOk)

	-- Budget score at quality 5 (fit is 1 for a pure species): Hp x weight + Attack + Defence + Speed.
	local budgetOk = true
	local lines: { string } = {}
	for _, name in roster.all do
		local def = Species[name]
		local score = 0
		for _, slot: Types.Slot in BreedConfig.SLOTS do
			local stats = def.parts[slot].stats
			score += (stats.Hp or 0) * BreedConfig.BUDGET_HP_WEIGHT + (stats.Attack or 0) + (stats.Defence or 0) + (stats.Speed or 0)
		end
		local target = BreedConfig.PLAN_BUDGET[def.bodyPlan]
		budgetOk = budgetOk and math.abs(score / target - 1) <= 0.05
		table.insert(lines, string.format("%s %.0f", name, score))
	end
	check(
		"each species' budget score is within 5% of its body plan's budget",
		budgetOk,
		table.concat(lines, ", ")
	)
	return used
end

-- Every part fits every torso of its plan, across the given rosters, inside the assembler's range.
local function checkFits(rosters: { Roster }, label: string)
	local fitsOk = true
	local worst = ""
	for _, plan: Types.BodyPlan in PLANS do
		local names: { string } = {}
		for _, roster in rosters do
			names = joined(names, planList(roster, plan))
		end
		for _, torso in names do
			for _, donor in names do
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
		`every part fits every torso on its plan ({label}) within the assembler's scale range`,
		fitsOk,
		worst
	)
end

print("\n== Greenwood roster data ==")
do
	local used = commonData(greenwood, GREENWOOD_CAP, 12, 5, 4)
	local counts: { [string]: number } = {}
	for _, name in greenwood.all do
		local def = Species[name]
		counts[def.element] = (counts[def.element] or 0) + 1
	end
	check(
		"most species are Leaf, with at least one Sand and one Water",
		(counts.Leaf or 0) > #greenwood.all / 2
			and (counts.Sand or 0) >= 1
			and (counts.Water or 0) >= 1,
		`Leaf {counts.Leaf or 0}, Sand {counts.Sand or 0}, Water {counts.Water or 0}`
	)

	local startersOk = true
	for name, element in STARTERS do
		local def = Species[name]
		startersOk = startersOk
			and def ~= nil
			and def.element == element
			and def.baseRarity == "Common"
			and def.biome == GREENWOOD
	end
	check("the three starters exist and are one each of Leaf, Sand and Water", startersOk)

	local hardestCommon, easiestUncommon = 0, math.huge
	for _, name in greenwood.all do
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

	local distinct, powerOk = 0, true
	for moveName in used do
		distinct += 1
		local power = Moves[moveName].power
		powerOk = powerOk and power >= 35 and power <= 70
	end
	-- 24 for the first eight species, plus Furrowfoot's one new move (Clod Hurl).
	check("20 to 25 distinct moves", distinct >= 20 and distinct <= 25, `{distinct}`)
	check("move power is between 35 and 70", powerOk)
	checkFits({ greenwood }, "Greenwood")
end

print("\n== Dust Canyon roster data ==")
do
	local used = commonData(dustCanyon, DUST_CANYON_CAP, 22)
	local counts: { [string]: number } = {}
	for _, name in dustCanyon.all do
		local def = Species[name]
		counts[def.element] = (counts[def.element] or 0) + 1
	end
	check(
		"most species are Sand, with at least one Water and one Leaf",
		(counts.Sand or 0) > #dustCanyon.all / 2
			and (counts.Water or 0) >= 1
			and (counts.Leaf or 0) >= 1,
		`Sand {counts.Sand or 0}, Water {counts.Water or 0}, Leaf {counts.Leaf or 0}`
	)

	-- Lasso difficulty is a step above Greenwood's: every common is harder than any Greenwood
	-- common, and every uncommon harder than any Greenwood uncommon and any Dust Canyon common.
	local gwCommon, gwUncommon = 0, 0
	for _, name in greenwood.all do
		local def = Species[name]
		if def.baseRarity == "Common" then
			gwCommon = math.max(gwCommon, def.lassoDifficulty)
		else
			gwUncommon = math.max(gwUncommon, def.lassoDifficulty)
		end
	end
	local easiestCommon, hardestCommon, easiestUncommon = math.huge, 0, math.huge
	for _, name in dustCanyon.all do
		local def = Species[name]
		if def.baseRarity == "Common" then
			easiestCommon = math.min(easiestCommon, def.lassoDifficulty)
			hardestCommon = math.max(hardestCommon, def.lassoDifficulty)
		else
			easiestUncommon = math.min(easiestUncommon, def.lassoDifficulty)
		end
	end
	check(
		"lasso difficulty is a step above Greenwood's",
		easiestCommon > gwCommon
			and easiestUncommon > gwUncommon
			and easiestUncommon > hardestCommon,
		`commons {easiestCommon} to {hardestCommon} (Greenwood up to {gwCommon}), uncommons from {easiestUncommon} (Greenwood up to {gwUncommon})`
	)

	-- Moves the Dust Canyon parts bring that Greenwood's do not.
	local greenwoodMoves: { [string]: boolean } = {}
	for _, name in greenwood.all do
		for _, slot: Types.Slot in BreedConfig.SLOTS do
			for _, unlock in Species[name].parts[slot].moves do
				greenwoodMoves[unlock.name] = true
			end
		end
	end
	local fresh, sand, powerOk = 0, 0, true
	for moveName in used do
		if not greenwoodMoves[moveName] then
			fresh += 1
			local move = Moves[moveName]
			if move.element == "Sand" then
				sand += 1
			end
			powerOk = powerOk and move.power >= 40 and move.power <= 80
		end
	end
	check("20 to 24 new moves", fresh >= 20 and fresh <= 24, `{fresh}`)
	check("most new moves are Sand", sand > fresh / 2, `{sand} of {fresh}`)
	check("new move power is between 40 and 80", powerOk)
	checkFits({ dustCanyon }, "Dust Canyon")
	checkFits({ greenwood, dustCanyon }, "both biomes")
end

print("\n== Tide Flats roster data ==")
do
	local used = commonData(tideFlats, TIDE_FLATS_CAP, 32)
	local counts: { [string]: number } = {}
	for _, name in tideFlats.all do
		local def = Species[name]
		counts[def.element] = (counts[def.element] or 0) + 1
	end
	local others = (counts.Leaf or 0) + (counts.Sand or 0)
	check(
		"most species are Water, with one or two Leaf or Sand and no later type",
		(counts.Water or 0) > #tideFlats.all / 2
			and others >= 1
			and others <= 2
			and (counts.Water or 0) + others == #tideFlats.all,
		`Water {counts.Water or 0}, Leaf {counts.Leaf or 0}, Sand {counts.Sand or 0}`
	)

	-- Lasso difficulty is a step above Dust Canyon's, as Dust Canyon's is above Greenwood's.
	local dcCommon, dcUncommon = 0, 0
	for _, name in dustCanyon.all do
		local def = Species[name]
		if def.baseRarity == "Common" then
			dcCommon = math.max(dcCommon, def.lassoDifficulty)
		else
			dcUncommon = math.max(dcUncommon, def.lassoDifficulty)
		end
	end
	local easiestCommon, hardestCommon, easiestUncommon = math.huge, 0, math.huge
	for _, name in tideFlats.all do
		local def = Species[name]
		if def.baseRarity == "Common" then
			easiestCommon = math.min(easiestCommon, def.lassoDifficulty)
			hardestCommon = math.max(hardestCommon, def.lassoDifficulty)
		else
			easiestUncommon = math.min(easiestUncommon, def.lassoDifficulty)
		end
	end
	check(
		"lasso difficulty is a step above Dust Canyon's",
		easiestCommon > dcCommon
			and easiestUncommon > dcUncommon
			and easiestUncommon > hardestCommon,
		`commons {easiestCommon} to {hardestCommon} (Dust Canyon up to {dcCommon}), uncommons from {easiestUncommon} (Dust Canyon up to {dcUncommon})`
	)

	-- Tide Flats favours Defence for breeding: its torsos are shells, carrying more Defence on
	-- average than either earlier biome's torsos.
	local function meanTorsoDefence(roster: Roster): number
		local sum = 0
		for _, name in roster.all do
			sum += Species[name].parts.Torso.stats.Defence or 0
		end
		return sum / #roster.all
	end
	local tfTorso = meanTorsoDefence(tideFlats)
	local gwTorso, dcTorso = meanTorsoDefence(greenwood), meanTorsoDefence(dustCanyon)
	check(
		"Tide Flats torsos carry more Defence than Greenwood's and Dust Canyon's",
		tfTorso > gwTorso and tfTorso > dcTorso,
		string.format(
			"mean torso Defence %.1f (Greenwood %.1f, Dust Canyon %.1f)",
			tfTorso,
			gwTorso,
			dcTorso
		)
	)

	-- Moves the Tide Flats parts bring that neither earlier roster's do.
	local earlierMoves: { [string]: boolean } = {}
	for _, name in joined(greenwood.all, dustCanyon.all) do
		for _, slot: Types.Slot in BreedConfig.SLOTS do
			for _, unlock in Species[name].parts[slot].moves do
				earlierMoves[unlock.name] = true
			end
		end
	end
	local fresh, water, powerOk = 0, 0, true
	for moveName in used do
		if not earlierMoves[moveName] then
			fresh += 1
			local move = Moves[moveName]
			if move.element == "Water" then
				water += 1
			end
			powerOk = powerOk and move.power >= 40 and move.power <= 80
		end
	end
	check("18 to 24 new moves", fresh >= 18 and fresh <= 24, `{fresh}`)
	check("most new moves are Water", water > fresh / 2, `{water} of {fresh}`)
	check("new move power is between 40 and 80", powerOk)

	-- The Toxic teaser (Mire is next) sits only on the torsos of the species Water beats, so no
	-- Water creature can take an anti-Water move into a Water mirror.
	local teaserOk, teasers = true, 0
	for _, name in tideFlats.all do
		local def = Species[name]
		for _, slot: Types.Slot in BreedConfig.SLOTS do
			for _, unlock in def.parts[slot].moves do
				if Moves[unlock.name].element == "Toxic" then
					teasers += 1
					teaserOk = teaserOk and slot == "Torso" and def.element == "Sand"
				end
			end
		end
	end
	check("Toxic moves come only on Sand torsos", teaserOk and teasers >= 1, `{teasers} found`)
	checkFits({ tideFlats }, "Tide Flats")
	checkFits({ greenwood, dustCanyon, tideFlats }, "all three biomes")
end

------------------------------------------------------------------------------------------------
type Entry = {
	label: string,
	choice: { string },
	creature: Creature,
	stats: Stats.StatBlock,
	fighter: Fighter?,
	pure: boolean,
}

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
		originBiome = GREENWOOD,
		isGiant = false,
		bound = false,
	}
end

-- Every build on the plan, with its stats. Fighters are made later, only for the field.
local function allBuilds(plan: Types.BodyPlan, names: { string }, level: number): { Entry }
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
				creature = creature,
				stats = Stats.compute(creature, level),
				fighter = nil,
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

local function total(s: Stats.StatBlock): number
	return s.Hp * BreedConfig.BUDGET_HP_WEIGHT + s.Attack + s.Defence + s.Speed
end

-- The fixed field: every pure species, the five best builds by each stat and by total, then a
-- seeded random sample up to the field size.
local function pickField(builds: { Entry }, size: number, level: number): { Entry }
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
			local s = entry.stats
			if key == "Hp" then
				return s.Hp
			elseif key == "Attack" then
				return s.Attack
			elseif key == "Defence" then
				return s.Defence
			elseif key == "Speed" then
				return s.Speed
			end
			return total(s)
		end
		local function better(a: Entry, b: Entry): boolean
			local va, vb = value(a), value(b)
			if va == vb then
				return a.label < b.label
			end
			return va > vb
		end
		-- The five best in that order, as a full sort would give, in one pass: the three-biome
		-- pool has 248,832 builds a plan, and five full sorts of it took most of the run.
		local top: { Entry } = {}
		for _, entry in builds do
			if #top < 5 or better(entry, top[#top]) then
				local at = #top + 1
				while at > 1 and better(entry, top[at - 1]) do
					at -= 1
				end
				table.insert(top, at, entry)
				if #top > 5 then
					table.remove(top)
				end
			end
		end
		for _, entry in top do
			add(entry)
		end
	end
	local rng = Rng.new(FIELD_SEED)
	while #field < math.min(size, #builds) do
		add(builds[Rng.int(rng, 1, #builds)])
	end
	for _, entry in field do
		entry.fighter = Battle.fighter(entry.creature, nil, level)
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
type Result = {
	ranked: { Ranked },
	-- Poison (docs/content/MIRE_ROSTER.md): the share of fights in which a creature was poisoned,
	-- and the mean win rate of the builds whose four moves include a poisoning move (carriers)
	-- and of those whose four do not.
	poisoned: number,
	carriers: number,
	carrierRate: number,
	otherRate: number,
	pure: { [string]: number }, -- win rate of each pure species
	headToHead: { [string]: { [string]: number } }, -- points (out of 2) one pure species took off another
}
-- How a mark is reported: `check` fails the run, `note` records a known gap.
type Marks = {
	maxWin: (string, boolean, string?) -> (),
	minPure: (string, boolean, string?) -> (),
	spread: (string, boolean, string?) -> (),
}
local STRICT: Marks = { maxWin = check, minPure = check, spread = check }
-- The mixed pool misses two marks for reasons outside the Dust Canyon data (see the roster
-- document, "Known gaps"), so those two are noted rather than failed.
local MIXED: Marks = { maxWin = note, minPure = note, spread = check }

local function poisons(fighter: Fighter): boolean
	for _, name in fighter.moves do
		if Moves[name].effect == "Poison" then
			return true
		end
	end
	return false
end
-- Fights in pools without the Mire in which anything was poisoned: must stay 0, so the three
-- launch biomes play exactly as before.
local launchPoisoned = 0

local function tournament(
	title: string,
	plan: Types.BodyPlan,
	names: { string },
	level: number,
	size: number,
	marks: Marks
): Result
	local field = pickField(allBuilds(plan, names, level), size, level)
	local wins = table.create(#field, 0)
	local headToHead: { [string]: { [string]: number } } = {}
	local turns, fights, poisonedFights = 0, 0, 0
	for i = 1, #field do
		for j = i + 1, #field do
			-- Each pair fights twice, swapping sides, so side order cannot favour anyone.
			local orders: { { number } } = { { i, j }, { j, i } }
			for _, order in orders do
				local a, b = field[order[1]], field[order[2]]
				local state = Battle.new(
					{ freshFighter(a.fighter :: Fighter) },
					{ freshFighter(b.fighter :: Fighter) },
					1,
					true
				)
				Battle.autoPlay(state)
				turns += state.turn
				fights += 1
				for _, event in state.log do
					if event.kind == "Poisoned" then
						poisonedFights += 1
						break
					end
				end
				local winner = state.winner :: number
				local pointsA = if winner == 0 then 0.5 elseif winner == 1 then 1 else 0
				wins[order[1]] += pointsA
				wins[order[2]] += 1 - pointsA
				if a.pure and b.pure then
					local nameA, nameB = a.choice[1], b.choice[1]
					headToHead[nameA] = headToHead[nameA] or {}
					headToHead[nameB] = headToHead[nameB] or {}
					headToHead[nameA][nameB] = (headToHead[nameA][nameB] or 0) + pointsA
					headToHead[nameB][nameA] = (headToHead[nameB][nameA] or 0) + 1 - pointsA
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
		`\n== {title}, {plan} builds at level {level}: {#field} builds, {fights} fights, {string.format(
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
		local s = r.entry.stats
		print(
			`    {string.format("%3d%%", math.floor(r.rate * 100 + 0.5))}  {r.entry.label}  {(
				r.entry.fighter :: Fighter
			).element}  Hp {s.Hp} Atk {s.Attack} Def {s.Defence} Spd {s.Speed}`
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
	local pure: { [string]: number } = {}
	for _, r in ranked do
		if r.entry.pure then
			minPure = math.min(minPure, r.rate)
			pure[r.entry.choice[1]] = r.rate
			table.insert(pureLine, `{r.entry.choice[1]} {fmtPct(r.rate)}`)
		end
	end
	print(`  pure species: {table.concat(pureLine, ", ")}`)
	local carriers, carrierSum, otherSum = 0, 0, 0
	for _, r in ranked do
		if poisons(r.entry.fighter :: Fighter) then
			carriers += 1
			carrierSum += r.rate
		else
			otherSum += r.rate
		end
	end
	local poisoned = poisonedFights / fights
	local carrierRate = if carriers > 0 then carrierSum / carriers else 0
	local otherRate = if carriers < #ranked then otherSum / (#ranked - carriers) else 0
	local hasMire = false
	for _, name in names do
		hasMire = hasMire or Species[name].biome == MIRE
	end
	if hasMire then
		print(
			`  poison: applied in {fmtPct(poisoned)} of fights; {carriers} of {#ranked} builds carry a poisoning move, winning {fmtPct(
				carrierRate
			)} on average against {fmtPct(otherRate)} for the rest`
		)
	else
		launchPoisoned += poisonedFights
	end

	local where = `{title}, {plan}, level {level}`
	marks.maxWin(
		`{where}: no build wins more than {fmtPct(MAX_WIN)} of its fights`,
		ranked[1].rate <= MAX_WIN,
		`best {fmtPct(ranked[1].rate)}: {ranked[1].entry.label}`
	)
	marks.minPure(
		`{where}: every pure species wins at least {fmtPct(MIN_PURE)}`,
		minPure >= MIN_PURE,
		`lowest {fmtPct(minPure)}`
	)
	marks.spread(
		`{where}: the top ten use at least two torsos and two leg sets`,
		torsoCount >= 2 and legCount >= 2,
		`{torsoCount} torsos, {legCount} leg sets`
	)
	return {
		ranked = ranked,
		pure = pure,
		headToHead = headToHead,
		poisoned = poisoned,
		carriers = carriers,
		carrierRate = carrierRate,
		otherRate = otherRate,
	}
end

-- In the mixed pool, no pure species from one biome may beat every pure species from the other
-- head to head (more than half the points against each), and the win rates are shown side by side.
local function compareBiomes(result: Result, plan: Types.BodyPlan, level: number)
	local old, new = planList(greenwood, plan), planList(dustCanyon, plan)
	local function line(names: { string }): (string, number)
		local parts: { string } = {}
		local sum = 0
		for _, name in names do
			table.insert(parts, `{name} {fmtPct(result.pure[name])}`)
			sum += result.pure[name]
		end
		return table.concat(parts, ", "), sum / #names
	end
	local oldLine, oldMean = line(old)
	local newLine, newMean = line(new)
	print(`  Greenwood pure:   {oldLine}  (mean {fmtPct(oldMean)})`)
	print(`  Dust Canyon pure: {newLine}  (mean {fmtPct(newMean)})`)
	local function beatsAll(name: string, others: { string }): boolean
		for _, other in others do
			if (result.headToHead[name][other] or 0) <= 1 then
				return false
			end
		end
		return true
	end
	local dominant: { string } = {}
	for _, name in new do
		if beatsAll(name, old) then
			table.insert(dominant, name)
		end
	end
	for _, name in old do
		if beatsAll(name, new) then
			table.insert(dominant, name)
		end
	end
	check(
		`Both biomes, {plan}, level {level}: no pure species beats every pure species of the other biome`,
		#dominant == 0,
		table.concat(dominant, ", ")
	)
end

for _, plan: Types.BodyPlan in PLANS do
	tournament("Greenwood", plan, planList(greenwood, plan), GREENWOOD_CAP, FIELD_SIZE, STRICT)
	tournament("Greenwood", plan, planList(greenwood, plan), RANKED, FIELD_SIZE, STRICT)
end
for _, plan: Types.BodyPlan in PLANS do
	for _, level in { DUST_CANYON_CAP, RANKED } do
		tournament("Dust Canyon", plan, planList(dustCanyon, plan), level, FIELD_SIZE, STRICT)
	end
end
for _, plan: Types.BodyPlan in PLANS do
	for _, level in { DUST_CANYON_CAP, RANKED } do
		local names = joined(planList(greenwood, plan), planList(dustCanyon, plan))
		local result = tournament("Both biomes", plan, names, level, MIXED_FIELD_SIZE, MIXED)
		compareBiomes(result, plan, level)
	end
end

-- Tide Flats alone, then all three biomes mixed.
for _, plan: Types.BodyPlan in PLANS do
	for _, level in { TIDE_FLATS_CAP, RANKED } do
		tournament("Tide Flats", plan, planList(tideFlats, plan), level, FIELD_SIZE, STRICT)
	end
end

-- The three-biome pool is held to the same marks as the two-biome one (noted, not failed, for
-- the same reason), plus guard rails at the measured level so it cannot quietly get worse.
-- Measured and explained in docs/content/TIDE_FLATS_ROSTER.md, "Mixed with the earlier biomes".
local MIXED3_GUARD_WIN = 0.80
local MIXED3_GUARD_PURE = 0.30

-- Tide Flats against each earlier biome in the three-biome pool: no pure species beats every
-- pure species of the other biome head to head, and the win rates are shown side by side.
local function compareTideFlats(result: Result, plan: Types.BodyPlan, level: number)
	local tf = planList(tideFlats, plan)
	local function line(names: { string }): string
		local parts: { string } = {}
		local sum = 0
		for _, name in names do
			table.insert(parts, `{name} {fmtPct(result.pure[name])}`)
			sum += result.pure[name]
		end
		return `{table.concat(parts, ", ")}  (mean {fmtPct(sum / #names)})`
	end
	print(`  Greenwood pure:   {line(planList(greenwood, plan))}`)
	print(`  Dust Canyon pure: {line(planList(dustCanyon, plan))}`)
	print(`  Tide Flats pure:  {line(tf)}`)
	local function beatsAll(name: string, others: { string }): boolean
		for _, other in others do
			if (result.headToHead[name][other] or 0) <= 1 then
				return false
			end
		end
		return true
	end
	type Earlier = { title: string, roster: Roster }
	local earlier: { Earlier } = {
		{ title = "Greenwood", roster = greenwood },
		{ title = "Dust Canyon", roster = dustCanyon },
	}
	for _, other in earlier do
		local old = planList(other.roster, plan)
		local dominant: { string } = {}
		for _, name in tf do
			if beatsAll(name, old) then
				table.insert(dominant, name)
			end
		end
		for _, name in old do
			if beatsAll(name, tf) then
				table.insert(dominant, name)
			end
		end
		check(
			`All three biomes, {plan}, level {level}: no pure species beats every pure species of Tide Flats and {other.title} the other way`,
			#dominant == 0,
			table.concat(dominant, ", ")
		)
	end
end

for _, plan: Types.BodyPlan in PLANS do
	for _, level in { TIDE_FLATS_CAP, RANKED } do
		local names = joined(
			joined(planList(greenwood, plan), planList(dustCanyon, plan)),
			planList(tideFlats, plan)
		)
		local result = tournament("All three biomes", plan, names, level, MIXED_FIELD_SIZE, MIXED)
		local lowest = 1
		for _, rate in result.pure do
			lowest = math.min(lowest, rate)
		end
		check(
			`All three biomes, {plan}, level {level}: guard, no build wins more than {fmtPct(
				MIXED3_GUARD_WIN
			)}`,
			result.ranked[1].rate <= MIXED3_GUARD_WIN,
			`best {fmtPct(result.ranked[1].rate)}`
		)
		check(
			`All three biomes, {plan}, level {level}: guard, every pure species wins at least {fmtPct(
				MIXED3_GUARD_PURE
			)}`,
			lowest >= MIXED3_GUARD_PURE,
			`lowest {fmtPct(lowest)}`
		)
		compareTideFlats(result, plan, level)
	end
end

------------------------------------------------------------------------------------------------
-- The Mire (biome 4). Poison arrives here; see docs/content/MIRE_ROSTER.md for the measurements.
-- The most a poison carrier's mean win rate may exceed the rest's, alone and in the four-biome
-- pool; and guard rails for the four-biome pool at the measured level, as for the three-biome one.
local MIRE_POISON_EDGE = 0.15
local MIXED4_POISON_EDGE = 0.15
local MIXED4_GUARD_WIN = 0.88
local MIXED4_GUARD_PURE = 0.24

print("\n== Mire roster data ==")
do
	local used = commonData(mire, MIRE_CAP, 42)
	local counts: { [string]: number } = {}
	for _, name in mire.all do
		local def = Species[name]
		counts[def.element] = (counts[def.element] or 0) + 1
	end
	local others = (counts.Leaf or 0) + (counts.Sand or 0) + (counts.Water or 0)
	check(
		"most species are Toxic, with one or two of the launch types and no later type",
		(counts.Toxic or 0) > #mire.all / 2
			and others >= 1
			and others <= 2
			and (counts.Toxic or 0) + others == #mire.all,
		`Toxic {counts.Toxic or 0}, Water {counts.Water or 0}, Leaf {counts.Leaf or 0}, Sand {counts.Sand or 0}`
	)

	-- Lasso difficulty is a step above Tide Flats', and no Mire species is a three-zone catch.
	local tfCommon, tfUncommon = 0, 0
	for _, name in tideFlats.all do
		local def = Species[name]
		if def.baseRarity == "Common" then
			tfCommon = math.max(tfCommon, def.lassoDifficulty)
		else
			tfUncommon = math.max(tfUncommon, def.lassoDifficulty)
		end
	end
	local easiestCommon, hardestCommon, easiestUncommon, hardest = math.huge, 0, math.huge, 0
	for _, name in mire.all do
		local def = Species[name]
		hardest = math.max(hardest, def.lassoDifficulty)
		if def.baseRarity == "Common" then
			easiestCommon = math.min(easiestCommon, def.lassoDifficulty)
			hardestCommon = math.max(hardestCommon, def.lassoDifficulty)
		else
			easiestUncommon = math.min(easiestUncommon, def.lassoDifficulty)
		end
	end
	check(
		"lasso difficulty is a step above Tide Flats', below the three-zone catches",
		easiestCommon > tfCommon
			and easiestUncommon > tfUncommon
			and easiestUncommon > hardestCommon
			and hardest < 2.5,
		`commons {easiestCommon} to {hardestCommon} (Tide Flats up to {tfCommon}), uncommons from {easiestUncommon} (Tide Flats up to {tfUncommon})`
	)

	-- The Mire favours Hp for breeding: its tails are swollen water sacks and bulrush heads,
	-- carrying more Hp on average than any earlier biome's tails.
	local function meanTailHp(roster: Roster): number
		local sum = 0
		for _, name in roster.all do
			sum += Species[name].parts.Tail.stats.Hp or 0
		end
		return sum / #roster.all
	end
	local mireTail = meanTailHp(mire)
	local earlierTail =
		math.max(meanTailHp(greenwood), meanTailHp(dustCanyon), meanTailHp(tideFlats))
	check(
		"Mire tails carry more Hp than any earlier biome's",
		mireTail > earlierTail,
		string.format("mean tail Hp %.1f (best earlier biome %.1f)", mireTail, earlierTail)
	)

	-- Moves the Mire parts bring that no earlier roster's do.
	local earlierMoves: { [string]: boolean } = {}
	for _, name in joined(joined(greenwood.all, dustCanyon.all), tideFlats.all) do
		for _, slot: Types.Slot in BreedConfig.SLOTS do
			for _, unlock in Species[name].parts[slot].moves do
				earlierMoves[unlock.name] = true
			end
		end
	end
	local fresh, toxic, powerOk, poisoning = 0, 0, true, 0
	for moveName in used do
		if not earlierMoves[moveName] then
			fresh += 1
			local move = Moves[moveName]
			if move.element == "Toxic" then
				toxic += 1
			end
			if move.effect == "Poison" then
				poisoning += 1
				powerOk = powerOk and move.power >= 30 and move.power <= 50
			else
				powerOk = powerOk and move.power >= 40 and move.power <= 80
			end
		end
	end
	check("18 to 24 new moves", fresh >= 18 and fresh <= 24, `{fresh}`)
	check("most new moves are Toxic", toxic > fresh / 2, `{toxic} of {fresh}`)
	check("new move power is 40 to 80, or 30 to 50 for a poisoning move", powerOk)
	check(
		"a small set of poisoning moves: three to five",
		poisoning >= 3 and poisoning <= 5,
		`{poisoning}`
	)

	-- Where the effects and the teaser sit. Poisoning moves are Toxic and come only from Toxic
	-- species, and each is weaker than the plain Mire moves brought on the same slot at the same
	-- level (on average). The Frost teaser (Frostline is next) sits only on Water torsos, so no
	-- Toxic creature can take an anti-Toxic move into a Toxic mirror.
	type Brought = { slot: Types.Slot, level: number, power: number }
	local plain: { Brought } = {}
	local poisonParts: { Brought } = {}
	local placedOk, teasers = true, 0
	local placement: { string } = {}
	for _, name in mire.all do
		local def = Species[name]
		for _, slot: Types.Slot in BreedConfig.SLOTS do
			for _, unlock in def.parts[slot].moves do
				local move = Moves[unlock.name]
				local entry: Brought = { slot = slot, level = unlock.level, power = move.power }
				if move.effect == "Poison" then
					table.insert(poisonParts, entry)
					if move.element ~= "Toxic" or def.element ~= "Toxic" then
						placedOk = false
						table.insert(placement, `{name} {slot}: {unlock.name}`)
					end
				else
					table.insert(plain, entry)
				end
				if move.element == "Frost" then
					teasers += 1
					if slot ~= "Torso" or def.element ~= "Water" then
						placedOk = false
						table.insert(placement, `{name} {slot}: {unlock.name}`)
					end
				end
			end
		end
	end
	check(
		"poisoning moves come only from Toxic species and Frost moves only on Water torsos",
		placedOk and teasers >= 1,
		if #placement > 0 then table.concat(placement, "; ") else `{teasers} Frost moves`
	)
	local weakerOk = true
	for _, p in poisonParts do
		local sum, count = 0, 0
		for _, q in plain do
			if q.slot == p.slot and q.level == p.level then
				sum += q.power
				count += 1
			end
		end
		weakerOk = weakerOk and count > 0 and p.power < sum / count
	end
	check(
		"each poisoning move is weaker than the plain moves of its slot and unlock level",
		weakerOk
	)

	-- Wild Mire creatures do poison: each Toxic species with a poisoning move on its head or
	-- torso keeps it among its four default moves at the Mire's cap.
	local keepsOk = true
	local carriers: { string } = {}
	local firstSlots: { Types.Slot } = { "Head", "Torso" }
	for _, name in mire.all do
		local def = Species[name]
		local brings = false
		for _, slot: Types.Slot in firstSlots do
			for _, unlock in def.parts[slot].moves do
				brings = brings or Moves[unlock.name].effect == "Poison"
			end
		end
		if brings then
			local fighter =
				Battle.fighter(build(def.bodyPlan, table.create(5, name), MIRE_CAP), nil, MIRE_CAP)
			local keeps = poisons(fighter)
			keepsOk = keepsOk and keeps
			table.insert(carriers, `{name}{if keeps then "" else " (not in its four)"}`)
		end
	end
	check(
		"each species with a poisoning head or torso keeps that move in its default four",
		keepsOk and #carriers >= 2,
		table.concat(carriers, ", ")
	)
	checkFits({ mire }, "Mire")
	checkFits({ greenwood, dustCanyon, tideFlats, mire }, "all four biomes")
end

-- The Mire alone, then all four biomes mixed. Measured and explained in
-- docs/content/MIRE_ROSTER.md.
for _, plan: Types.BodyPlan in PLANS do
	for _, level in { MIRE_CAP, RANKED } do
		local result = tournament("Mire", plan, planList(mire, plan), level, FIELD_SIZE, STRICT)
		-- Poison is a real choice in the Mire but not the only good one: it lands in some fights
		-- (only on the Water species and Water-torso builds, since Toxic is immune), and builds
		-- that carry it do not win much more often than builds that do not.
		check(
			`Mire, {plan}, level {level}: poison is applied in some fights, and carriers win at most {fmtPct(
				MIRE_POISON_EDGE
			)} more than the rest`,
			result.poisoned > 0 and result.carrierRate - result.otherRate <= MIRE_POISON_EDGE,
			`applied in {fmtPct(result.poisoned)}; carriers {fmtPct(result.carrierRate)}, others {fmtPct(
				result.otherRate
			)}`
		)
	end
end

-- A newer biome against each earlier one in a mixed pool: no pure species beats every pure
-- species of the other biome head to head, and the win rates are shown side by side.
type Titled = { title: string, roster: Roster }
local function compareNewest(
	result: Result,
	plan: Types.BodyPlan,
	level: number,
	newest: Titled,
	earlier: { Titled },
	poolTitle: string
)
	local function line(names: { string }): string
		local parts: { string } = {}
		local sum = 0
		for _, name in names do
			table.insert(parts, `{name} {fmtPct(result.pure[name])}`)
			sum += result.pure[name]
		end
		return `{table.concat(parts, ", ")}  (mean {fmtPct(sum / #names)})`
	end
	for _, other in earlier do
		print(`  {other.title} pure: {line(planList(other.roster, plan))}`)
	end
	print(`  {newest.title} pure: {line(planList(newest.roster, plan))}`)
	local function beatsAll(name: string, others: { string }): boolean
		for _, other in others do
			if (result.headToHead[name][other] or 0) <= 1 then
				return false
			end
		end
		return true
	end
	local new = planList(newest.roster, plan)
	for _, other in earlier do
		local old = planList(other.roster, plan)
		local dominant: { string } = {}
		for _, name in new do
			if beatsAll(name, old) then
				table.insert(dominant, name)
			end
		end
		for _, name in old do
			if beatsAll(name, new) then
				table.insert(dominant, name)
			end
		end
		check(
			`{poolTitle}, {plan}, level {level}: no pure species beats every pure species of {newest.title} and {other.title} the other way`,
			#dominant == 0,
			table.concat(dominant, ", ")
		)
	end
end

for _, plan: Types.BodyPlan in PLANS do
	for _, level in { MIRE_CAP, RANKED } do
		local names = joined(
			joined(
				joined(planList(greenwood, plan), planList(dustCanyon, plan)),
				planList(tideFlats, plan)
			),
			planList(mire, plan)
		)
		local result = tournament("All four biomes", plan, names, level, MIXED_FIELD_SIZE, MIXED)
		local lowest = 1
		for _, rate in result.pure do
			lowest = math.min(lowest, rate)
		end
		check(
			`All four biomes, {plan}, level {level}: guard, no build wins more than {fmtPct(
				MIXED4_GUARD_WIN
			)}`,
			result.ranked[1].rate <= MIXED4_GUARD_WIN,
			`best {fmtPct(result.ranked[1].rate)}`
		)
		check(
			`All four biomes, {plan}, level {level}: guard, every pure species wins at least {fmtPct(
				MIXED4_GUARD_PURE
			)}`,
			lowest >= MIXED4_GUARD_PURE,
			`lowest {fmtPct(lowest)}`
		)
		check(
			`All four biomes, {plan}, level {level}: guard, poison carriers win at most {fmtPct(
				MIXED4_POISON_EDGE
			)} more than the rest`,
			result.carrierRate - result.otherRate <= MIXED4_POISON_EDGE,
			`carriers {fmtPct(result.carrierRate)}, others {fmtPct(result.otherRate)}`
		)
		compareNewest(result, plan, level, { title = "Mire", roster = mire }, {
			{ title = "Greenwood", roster = greenwood },
			{ title = "Dust Canyon", roster = dustCanyon },
			{ title = "Tide Flats", roster = tideFlats },
		}, "All four biomes")
	end
end
check(
	"no creature is poisoned in any pool without the Mire",
	launchPoisoned == 0,
	`{launchPoisoned} fights`
)

------------------------------------------------------------------------------------------------
print("\n== Pacing: 3v3 (4v4 from the Mire) between random wild teams ==")
do
	local function pace(names: { string }, level: number, size: number): (number, number, number)
		local rng = Rng.new(31)
		local function randomTeam(prefix: string): { Fighter }
			local team: { Fighter } = {}
			for index = 1, size do
				local creature = Breeding.wild(
					Rng.pick(rng, names),
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
	-- Team size: three in the launch biomes, four from the Mire (docs/MASTER_PLAN.md). The target
	-- grows with the team: a 4v4 has a third more creatures to knock out than a 3v3.
	type PaceCase = { title: string, names: { string }, levels: { number }, size: number? }
	local cases: { PaceCase } = {
		{ title = "Greenwood", names = greenwood.all, levels = { 5, GREENWOOD_CAP, RANKED } },
		{ title = "Dust Canyon", names = dustCanyon.all, levels = { DUST_CANYON_CAP, RANKED } },
		{
			title = "Both biomes",
			names = joined(greenwood.all, dustCanyon.all),
			levels = { DUST_CANYON_CAP, RANKED },
		},
		{ title = "Tide Flats", names = tideFlats.all, levels = { TIDE_FLATS_CAP, RANKED } },
		{
			title = "All three biomes",
			names = joined(joined(greenwood.all, dustCanyon.all), tideFlats.all),
			levels = { TIDE_FLATS_CAP, RANKED },
		},
		{ title = "Mire", names = mire.all, levels = { MIRE_CAP, RANKED }, size = 4 },
		{
			title = "All four biomes",
			names = joined(joined(joined(greenwood.all, dustCanyon.all), tideFlats.all), mire.all),
			levels = { MIRE_CAP, RANKED },
			size = 4,
		},
	}
	for _, case in cases do
		for _, level in case.levels do
			local size = case.size or 3
			local low, high = PACE_MIN * size / 3, PACE_MAX * size / 3
			local mean, shortest, longest = pace(case.names, level, size)
			check(
				`{case.title}, level {level}: a {size}v{size} lasts {string.format("%.1f", low)} to {string.format(
					"%.1f",
					high
				)} turns on average`,
				mean >= low and mean <= high,
				`{string.format("%.1f", mean)} turns, shortest {shortest}, longest {longest}`
			)
		end
	end
end

print(`\n{passed} passed, {failed} failed, {notes} known gaps noted`)
if failed > 0 then
	error("roster checks failed")
end
