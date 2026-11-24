--!strict
-- Checks for capturing a giant, the captured giant as a creature, Giant Candy and breeding from it.
-- Run from the project folder:  lune run tests/giantcapture.test

local Battle = require("../src/shared/Battle")
local BreedConfig = require("../src/config/BreedConfig")
local Breeding = require("../src/shared/Breeding")
local Economy = require("../src/shared/Economy")
local EconomyConfig = require("../src/config/EconomyConfig")
local GiantCapture = require("../src/shared/GiantCapture")
local Giants = require("../src/content/Giants")
local Lasso = require("../src/shared/Lasso")
local LassoConfig = require("../src/config/LassoConfig")
local Moves = require("../src/content/Moves")
local Profile = require("../src/shared/Profile")
local Rewards = require("../src/shared/Rewards")
local Rng = require("../src/shared/Rng")
local Species = require("../src/content/Species")
local Types = require("../src/shared/Types")

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

local giant = Giants.greenwood_hollowbough
local form = assert(giant.form, "Hollowbough has a creature form")
local DAY = 86400 * 300

local function perfect(throw: GiantCapture.Throw): { number }
	local taps = {}
	for index, zone in throw.pattern.zones do
		table.insert(taps, Lasso.nextCentreTimeMs(throw.pattern, index, zone.startMs))
	end
	return taps
end

local function fresh(): Profile.Profile
	local profile = Profile.template()
	profile.Items.Basic, profile.Items.Braided = 3, 3
	return profile
end

print("\n== The giant's creature form ==")
do
	local def = Species[form.species]
	check(
		"it is marked as a giant's form, so it is never a wild species",
		def ~= nil and def.giantForm == true
	)
	local budget = 0
	local slots: { Types.Slot } = BreedConfig.SLOTS
	for _, slot: Types.Slot in slots do
		for stat, value in def.parts[slot].stats :: { [string]: number } do
			budget += value * (if stat == "Hp" then BreedConfig.BUDGET_HP_WEIGHT else 1)
		end
	end
	check(
		"its parts cost the same budget as any species",
		math.abs(budget - BreedConfig.PLAN_BUDGET[def.bodyPlan]) < 0.01,
		`{budget}`
	)
	local movesOk = true
	for _, slot: Types.Slot in slots do
		for _, unlock in def.parts[slot].moves do
			movesOk = movesOk and Moves[unlock.name] ~= nil
		end
	end
	check("every move it knows exists", movesOk)
	local signature = true
	for name, other in Species do
		if name ~= form.species then
			for _, slot: Types.Slot in slots do
				for _, unlock in other.parts[slot].moves do
					signature = signature
						and unlock.name ~= "Heartwood Slam"
						and unlock.name ~= "Thorn Gale"
				end
			end
		end
	end
	check("its two signature moves belong to nothing else", signature)
end

print("\n== The capture attempt ==")
do
	local profile = fresh()
	check("a made-up lasso is refused", GiantCapture.begin(profile, giant, "Net", 1, 80) == nil)
	check(
		"a Basic lasso is too weak for a giant, and is kept",
		GiantCapture.begin(profile, giant, "Basic", 1, 80) == nil and profile.Items.Basic == 3
	)
	profile.Items.Braided = 0
	check(
		"a lasso the player does not have is refused",
		GiantCapture.begin(profile, giant, "Braided", 1, 80) == nil
	)
	profile.Items.Braided = 3
	local throw = assert(GiantCapture.begin(profile, giant, "Braided", 1, 80), "the attempt starts")
	check("starting the attempt spends the lasso", profile.Items.Braided == 2)
	check(
		"a giant's lasso has three loops and carries the server's round trip",
		#throw.pattern.zones == LassoConfig.GIANT_ZONES and throw.pattern.roundTripMs == 80
	)

	local missed, judgement = GiantCapture.finish(profile, throw, { 1 }, { 1 })
	check("a miss captures nothing", not missed and judgement ~= nil and #profile.Pending == 0)
	check(
		"the same attempt cannot be judged twice",
		(GiantCapture.finish(profile, throw, perfect(throw), perfect(throw))) == false
			and #profile.Pending == 0
	)

	local second =
		assert(GiantCapture.begin(profile, giant, "Braided", 2, 80), "another attempt starts")
	local taps = perfect(second)
	local impossible = GiantCapture.finish(
		profile,
		second,
		taps,
		{ taps[1] + 9000, taps[2] + 9000, taps[3] + 9000 }
	)
	check(
		"perfect taps the server's clock says were impossible count as a miss",
		not impossible and #profile.Pending == 0
	)

	local third =
		assert(GiantCapture.begin(profile, giant, "Braided", 3, 80), "another attempt starts")
	local hit = GiantCapture.finish(profile, third, perfect(third), perfect(third))
	check(
		"a hit writes the capture into the saved waiting list",
		hit and #profile.Pending == 1 and profile.Pending[1].source == "Giant"
	)
	check(
		"the giant is not owned until its serial number arrives",
		next(profile.Creatures) == nil and not profile.Story.giantsCaptured[giant.id]
	)
	check(
		"no second attempt while the capture is being finished",
		GiantCapture.begin(profile, giant, "Braided", 4, 80) == nil
			and #GiantCapture.waitingGiants(profile) == 1
	)
end

print("\n== The serial number arrives ==")
do
	local profile = fresh()
	local throw = assert(GiantCapture.begin(profile, giant, "Braided", 5, 80), "the attempt starts")
	GiantCapture.finish(profile, throw, perfect(throw), perfect(throw))

	check("a fresh capture needs its number fetched", GiantCapture.needsSerial(profile, giant))
	check(
		"without its number it cannot be finished",
		GiantCapture.complete(profile, giant, "g0", 11).outcome == "Refused"
			and #profile.Pending == 1
	)
	check(
		"a number that is not a whole number above zero is refused",
		not GiantCapture.keepSerial(profile, giant.id, 0)
			and not GiantCapture.keepSerial(profile, giant.id, 2.5)
	)
	check(
		"the fetched number is kept on the waiting capture",
		GiantCapture.keepSerial(profile, giant.id, 7) and profile.Pending[1].serial == 7
	)
	check(
		"it is asked for only once",
		not GiantCapture.needsSerial(profile, giant)
			and not GiantCapture.keepSerial(profile, giant.id, 8)
			and profile.Pending[1].serial == 7
	)

	profile.StableCapacity = 0
	local noRoom = GiantCapture.complete(profile, giant, "g1", 11)
	check(
		"with a full stable the capture keeps waiting, number and all",
		noRoom.outcome == "NoRoom" and #profile.Pending == 1 and profile.Pending[1].serial == 7
	)
	check(
		"the record is sound while it waits",
		#Profile.validate(profile) == 0,
		table.concat(Profile.validate(profile), "; ")
	)
	profile.StableCapacity = 30
	local grant, creature = GiantCapture.complete(profile, giant, "g1", 11)
	local owned = assert(creature, "the giant arrives")
	check(
		"with room, the giant arrives",
		grant.outcome == "Granted" and profile.Creatures.g1 == owned
	)
	check(
		"it carries its serial number and is bound to the account",
		owned.serial == 7 and owned.bound and owned.isGiant
	)
	check(
		"it is a gem-tier creature of the giant's species at the giant's level",
		owned.rarity == "Gem"
			and owned.parts.Torso.species == "Hollowbough"
			and owned.level == giant.level
	)
	check("it looks bigger than other creatures", owned.size == form.size)
	local ordinary = table.clone(owned)
	ordinary.size = BreedConfig.SIZE_MAX
	check(
		"but fights as the largest ordinary size, no stronger",
		Battle.fighter(owned).stats.Hp == Battle.fighter(ordinary).stats.Hp
	)
	check(
		"the waiting entry is cleared and the giant is marked captured",
		#profile.Pending == 0 and profile.Story.giantsCaptured[giant.id] == true
	)
	check(
		"it is in the Index and joins an empty team",
		profile.Index.owned.Hollowbough == true and profile.Team[1] == "g1"
	)
	check(
		"nothing more can be finished or numbered afterwards",
		GiantCapture.complete(profile, giant, "g2", 12).outcome == "Refused"
			and not GiantCapture.keepSerial(profile, giant.id, 8)
			and profile.Creatures.g2 == nil
	)
	check(
		"the same giant can never be captured again",
		not GiantCapture.canCapture(profile, giant)
			and GiantCapture.begin(profile, giant, "Braided", 6, 80) == nil
	)
	check(
		"a number with no waiting capture is refused",
		not GiantCapture.keepSerial(fresh(), giant.id, 9)
			and GiantCapture.complete(fresh(), giant, "g3", 13).outcome == "Refused"
	)
	check(
		"the record is sound",
		#Profile.validate(profile) == 0,
		table.concat(Profile.validate(profile), "; ")
	)

	table.insert(profile.Pending, { source = "Giant", ref = giant.id })
	check("a stale waiting entry for a captured giant is reported", #Profile.validate(profile) > 0)
	check("and never asks for a number", not GiantCapture.needsSerial(profile, giant))
	check("and is cleared", GiantCapture.tidy(profile) == 1 and #profile.Pending == 0)

	local fighter = Battle.fighter(owned)
	check(
		"it fights like any creature, with its signature moves in reach",
		fighter.stats.Hp > 0 and table.find(fighter.moves, "Heartwood Slam") ~= nil
	)
	local common = Breeding.wild("Burlhorn", "c", giant.level, "Uncommon", "Bark", Rng.new(3))
	check(
		"it is stronger than a common creature of the same level, but not a boss",
		fighter.stats.Hp > Battle.fighter(common).stats.Hp and fighter.stats.Hp < giant.stats.Hp / 3
	)
end

print("\n== Giant Candy and breeding from a giant ==")
do
	local profile = fresh()
	local hollow = assert(GiantCapture.build(giant, "g", 1, 4), "built")
	local mate = Breeding.wild("Burlhorn", "m", 10, "Uncommon", "Bark", Rng.new(6))
	profile.Creatures.g, profile.Creatures.m = hollow, mate
	profile.Team = { "m" }
	local key = Economy.giantCandyKey("Hollowbough")

	local members = { { id = "m", fainted = false } }
	local earned = 0
	for _ = 1, 5 do
		earned += Rewards.giantWin(
			profile,
			giant,
			hollow,
			{ biome = 1, team = members, cap = 15, unixTime = DAY }
		).giantCandy
	end
	check(
		"beating the giant earns its candy, up to the daily number",
		earned == EconomyConfig.GIANT_CANDY.perWin * EconomyConfig.GIANT_CANDY.capPerDay
			and profile.Items[key] == earned
	)
	check(
		"and again the next day",
		Rewards.giantWin(
			profile,
			giant,
			hollow,
			{ biome = 1, team = members, cap = 15, unixTime = DAY + 86400 }
		).giantCandy == EconomyConfig.GIANT_CANDY.perWin
	)

	check(
		"a captured giant can breed with a creature of its body plan",
		(Breeding.canBreed(hollow, mate, DAY))
	)
	local needs = Breeding.giantCandyCost(hollow, mate)
	check(
		"the breed needs the giant's own candy",
		#needs == 1
			and needs[1].species == "Hollowbough"
			and needs[1].amount == BreedConfig.GIANT_CANDY_COST
	)
	local typed = Breeding.candyCost(hollow, mate)
	check(
		"and ordinary candy only for the other parent",
		#typed == 1 and typed[1].amount == BreedConfig.CANDY_COST.Uncommon
	)
	check("a breed with no giant needs no Giant Candy", #Breeding.giantCandyCost(mate, mate) == 0)
	check(
		"too little Giant Candy is not enough",
		not Breeding.hasGiantCandy(profile.Items, needs, Economy.giantCandyKey)
	)
	profile.Items[key] = BreedConfig.GIANT_CANDY_COST
	check("enough is enough", Breeding.hasGiantCandy(profile.Items, needs, Economy.giantCandyKey))
	profile.Candy.prism = 999
	profile.Items[key] = 0
	check(
		"Prism Candy cannot stand in for it",
		not Breeding.hasGiantCandy(profile.Items, needs, Economy.giantCandyKey)
	)

	local giantParts, boundAll, sizesOk, giants = 0, true, true, 0
	for seed = 1, 200 do
		local bred = Breeding.breed(hollow, mate, Rng.new(seed), { childId = `k{seed}`, now = DAY })
		local child = bred.child
		boundAll = boundAll and child.bound
		sizesOk = sizesOk
			and child.size >= BreedConfig.SIZE_MIN
			and child.size <= BreedConfig.SIZE_MAX
		if child.isGiant then
			giants += 1
		end
		for _, slot: Types.Slot in BreedConfig.SLOTS do
			if child.parts[slot].species == "Hollowbough" then
				giantParts += 1
			end
		end
	end
	check("a child can inherit the giant's parts", giantParts > 0)
	check("a child is an ordinary creature, never a giant", giants == 0)
	check("a child of a giant is bound to the account like its parent", boundAll)
	check("a child's size is back in the ordinary range", sizesOk)
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("giant capture checks failed")
end
