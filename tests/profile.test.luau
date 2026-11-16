--!strict
-- Checks for the saved-data shape, migrations and safety checks.
-- Run from the project folder:  lune run tests/profile.test

local Breeding = require("../src/shared/Breeding")
local Profile = require("../src/shared/Profile")
local ProfileConfig = require("../src/config/ProfileConfig")
local Rng = require("../src/shared/Rng")
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

local function has(problems: { string }, fragment: string): boolean
	for _, problem in problems do
		if string.find(problem, fragment, 1, true) then
			return true
		end
	end
	return false
end

-- A sound profile with two creatures, a team and an egg, used as the starting point for each case.
local function sample(): Profile.Profile
	local rng = Rng.new(3)
	local profile = Profile.template()
	local a = Breeding.wild("Brindle", "a", 10, "Common", "Moss", rng)
	local b = Breeding.wild("Dartlet", "b", 9, "Common", "Sand", rng)
	profile.Creatures[a.id] = a
	profile.Creatures[b.id] = b
	profile.Team = { "a", "b" }
	profile.Coins = 2000
	profile.Candy = 4
	profile.Items.BasicLasso = 3
	local bred = Breeding.breed(a, b, rng, { childId = "egg1", now = 1000 })
	table.insert(profile.Eggs, { child = bred.child, hatchAt = bred.hatchAt, seed = 42 })
	return profile
end

------------------------------------------------------------------------------------------------
print("\n== A new player's data ==")
do
	local first, second = Profile.template(), Profile.template()
	check("a new profile has no problems", #Profile.validate(first) == 0)
	first.Creatures.x = Breeding.wild("Brindle", "x", 1, "Common", "Moss", Rng.new(1))
	first.Story.flags.metMentor = true
	check(
		"two new profiles never share a table",
		next(second.Creatures) == nil and next(second.Story.flags) == nil
	)
	check("it starts at the current version", first.SchemaVersion == Profile.CURRENT_VERSION)
	local ok, why = Profile.isStorable(sample())
	check("a profile with creatures and an egg can be stored", ok, why)
end

------------------------------------------------------------------------------------------------
print("\n== Team size follows badges ==")
do
	check(
		"three creatures for the launch biomes",
		Profile.teamSize(0) == 3 and Profile.teamSize(2) == 3
	)
	check("four from the Mire", Profile.teamSize(3) == 4)
	check("five from Emberfall", Profile.teamSize(6) == 5)
	check("six for the Hollow", Profile.teamSize(10) == 6 and Profile.teamSize(99) == 6)
end

------------------------------------------------------------------------------------------------
print("\n== Migrations ==")
do
	local current = Profile.template()
	current.Coins = 123
	local loaded = Profile.migrate(current)
	check(
		"a save at the current version loads with its data intact",
		loaded ~= nil and loaded.Coins == 123
	)

	local future: any = Profile.template()
	future.SchemaVersion = Profile.CURRENT_VERSION + 1
	local fromFuture, whyFuture = Profile.migrate(future)
	check(
		"a save from a newer game version is refused, not overwritten",
		fromFuture == nil,
		whyFuture
	)

	local noVersion: any = { Coins = 5 }
	check("a save with no version is refused", Profile.migrate(noVersion) == nil)
	check("something that is not a table is refused", Profile.migrate("junk" :: any) == nil)

	-- The stepper itself, with made-up migrations from version 1 to 3.
	local order: { number } = {}
	local fake: { [number]: Profile.Migration } = {
		[1] = function(data: any)
			table.insert(order, 1)
			data.Renamed = data.Old
			data.Old = nil
		end,
		[2] = function(data: any)
			table.insert(order, 2)
			data.Added = 7
		end,
	}
	local old: any = { SchemaVersion = 1, Old = "kept", Nested = { value = 1 } }
	local migrated: any = Profile.migrateWith(old, fake, 3)
	check(
		"migrations run in order and each one bumps the version",
		migrated ~= nil and order[1] == 1 and order[2] == 2 and migrated.SchemaVersion == 3
	)
	check(
		"the result carries every step's change",
		migrated.Renamed == "kept" and migrated.Old == nil and migrated.Added == 7
	)
	check(
		"the original save is never changed",
		old.SchemaVersion == 1
			and old.Old == "kept"
			and old.Added == nil
			and migrated.Nested ~= old.Nested
	)

	local broken: { [number]: Profile.Migration } = {
		[1] = function(data: any)
			data.HalfDone = true
			error("boom")
		end,
	}
	local stuck: any = { SchemaVersion = 1 }
	local fromBroken, whyBroken = Profile.migrateWith(stuck, broken, 2)
	check(
		"a failing migration returns nothing and leaves the save untouched",
		fromBroken == nil and stuck.SchemaVersion == 1 and stuck.HalfDone == nil,
		whyBroken
	)
	local gap: any = { SchemaVersion = 1 }
	check("a missing migration step is refused", Profile.migrateWith(gap, {}, 2) == nil)
end

------------------------------------------------------------------------------------------------
print("\n== Purchases are granted once ==")
do
	local profile = Profile.template()
	check("a new receipt is accepted", Profile.rememberReceipt(profile, "p1"))
	check("the same receipt again is refused", not Profile.rememberReceipt(profile, "p1"))
	for index = 2, ProfileConfig.RECEIPTS_REMEMBERED + 20 do
		Profile.rememberReceipt(profile, `p{index}`)
	end
	check(
		"only the most recent receipts are kept",
		#profile.Purchases.receiptIds == ProfileConfig.RECEIPTS_REMEMBERED
	)
	check(
		"a recent receipt is still refused",
		not Profile.rememberReceipt(profile, `p{ProfileConfig.RECEIPTS_REMEMBERED + 20}`)
	)
end

------------------------------------------------------------------------------------------------
print("\n== A broken save is caught ==")
do
	check("the sample profile is sound", #Profile.validate(sample()) == 0)

	local p = sample()
	p.Coins = -5
	check("negative coins", has(Profile.validate(p), "Coins"))

	p = sample()
	p.Candy = 1.5
	check("a fractional candy balance", has(Profile.validate(p), "Candy"))

	p = sample()
	table.insert(p.Team, "ghost")
	check("a team member that is not owned", has(Profile.validate(p), "not owned"))

	p = sample()
	p.Team = { "a", "a" }
	check("the same creature on the team twice", has(Profile.validate(p), "twice"))

	p = sample()
	p.Creatures.c = Breeding.wild("Brindle", "c", 5, "Common", "Moss", Rng.new(9))
	p.Creatures.d = Breeding.wild("Brindle", "d", 5, "Common", "Moss", Rng.new(10))
	p.Team = { "a", "b", "c", "d" }
	check("a team bigger than the badges allow", has(Profile.validate(p), "larger than the badges"))

	p = sample()
	p.Creatures.egg1 = p.Eggs[1].child
	check(
		"a creature that is both in an egg and in the stable (a duplicate)",
		has(Profile.validate(p), "already in the stable")
	)

	p = sample()
	p.Creatures.wrong = p.Creatures.a
	check("a creature stored under the wrong id", has(Profile.validate(p), "wrong id"))

	p = sample()
	p.Creatures.a.parts.Legs.quality = 11
	check("a part quality outside 0-10", has(Profile.validate(p), "quality outside"))

	p = sample()
	table.insert(p.Eggs, p.Eggs[1])
	check("more eggs than pens", has(Profile.validate(p), "more eggs than pens"))

	p = sample()
	p.Items.BasicLasso = -1
	check("a negative item count", has(Profile.validate(p), "BasicLasso"))

	p = sample()
	p.StableCapacity = 1
	check("more creatures than the stable holds", has(Profile.validate(p), "stable holds"))

	p = sample()
	p.Creatures.a.size = 0 / 0
	check("a value that cannot be saved", has(Profile.validate(p), "cannot be saved"))
end

------------------------------------------------------------------------------------------------
print("\n== What can be stored ==")
do
	local gappy: any = { 1, 2, 3 }
	gappy[2] = nil
	check("a list with a gap is refused", not Profile.isStorable(gappy))
	local mixed: any = { 1, 2 }
	mixed.name = "x"
	check("a table mixing list entries and names is refused", not Profile.isStorable(mixed))
	check("infinity is refused", not Profile.isStorable({ value = math.huge }))
	check("a function is refused", not Profile.isStorable({ run = function() end } :: any))
	check(
		"nested plain data is accepted",
		(Profile.isStorable({ a = { 1, 2, 3 }, b = { c = true, d = "x" } }))
	)
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("profile checks failed")
end
