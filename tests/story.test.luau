--!strict
-- Checks for finishing story beats and paying their gifts (approval pack 2: one-time gifts).
-- Run from the project folder:  lune run tests/story.test

local Chapter1 = require("../src/content/story_data/Chapter1")
local Grants = require("../src/shared/Grants")
local Profile = require("../src/shared/Profile")
local StoryProgress = require("../src/shared/StoryProgress")
local World = require("../src/shared/World")

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

local nextId = 0
local function newId(): string
	nextId += 1
	return `gift{nextId}`
end

local function input(beatId: string, choice: string?, met: boolean?): StoryProgress.CompleteInput
	return {
		beatId = beatId,
		choice = choice,
		triggerMet = if met == nil then true else met,
		newId = newId,
		seed = 11,
		unixTime = 86400 * 300,
	}
end

local function count(map: { [string]: any }): number
	local n = 0
	for _ in map do
		n += 1
	end
	return n
end

print("\n== The starter ==")
do
	local profile = Profile.template()
	local refused = StoryProgress.complete(profile, Chapter1, input("starter_choice", "Burlhorn"))
	check(
		"a starter that is not one of the three is refused",
		refused == nil and count(profile.Creatures) == 0
	)
	check(
		"and nothing changed",
		not profile.Story.flags.starter_choice and profile.Story.starter == nil
	)
	check(
		"a later beat cannot be done first",
		StoryProgress.complete(profile, Chapter1, input("lasso_lesson")) == nil
	)
	check(
		"a trigger the server did not see is refused",
		StoryProgress.complete(profile, Chapter1, input("starter_choice", "Mossmitt", false)) == nil
	)

	local done = StoryProgress.complete(profile, Chapter1, input("starter_choice", "Spadesnout"))
	check(
		"picking a starter finishes the beat",
		done ~= nil and profile.Story.flags.starter_choice == true
	)
	local id = profile.Team[1]
	check(
		"the starter is on the team",
		id ~= nil and profile.Creatures[id].parts.Torso.species == "Spadesnout"
	)
	check("at the beat's level", id ~= nil and profile.Creatures[id].level == 5)
	check("the choice is remembered", profile.Story.starter == "Spadesnout")
	check(
		"the starter cannot be picked again",
		StoryProgress.complete(profile, Chapter1, input("starter_choice", "Mossmitt")) == nil
			and count(profile.Creatures) == 1
	)
end

print("\n== The whole chapter ==")
do
	local profile = Profile.template()
	local finished = 0
	local choice: string? = "Mossmitt"
	while true do
		local beat = World.nextBeat(Chapter1, profile.Story.flags)
		if not beat then
			break
		end
		local done = StoryProgress.complete(profile, Chapter1, input(beat.id, choice))
		if not done then
			break
		end
		choice = nil
		finished += 1
	end
	check(
		"every beat finishes in order",
		finished == #Chapter1.beats,
		`{finished} of {#Chapter1.beats}`
	)
	check(
		"the lasso lesson paid lassos and a creature",
		(profile.Items.Basic or 0) > 0 and count(profile.Creatures) >= 3
	)
	check("the mentor's egg waits in a pen", #profile.Eggs == 1 and #profile.Eggs <= profile.Pens)
	check(
		"the egg hatches soon, not on a normal timer",
		profile.Eggs[1].hatchAt - 86400 * 300 <= 600
	)
	check("Prism Candy was paid", profile.Candy.prism > 0)
	check(
		"the badge was earned",
		profile.Story.badges == 1 and profile.Story.flags.greenwood_badge == true
	)
	check(
		"the record is sound",
		#Profile.validate(profile) == 0,
		table.concat(Profile.validate(profile), "; ")
	)
end

print("\n== A full stable ==")
do
	local profile = Profile.template()
	profile.StableCapacity = 0
	local done = StoryProgress.complete(profile, Chapter1, input("starter_choice", "Sloshcalf"))
	check("the beat still finishes", done ~= nil)
	check(
		"the starter waits in the saved list",
		#profile.Pending == 1 and count(profile.Creatures) == 0
	)
	profile.StableCapacity = 30
	local handed = Grants.claimPending(profile, function(_source, ref)
		return StoryProgress.rebuild(ref, newId(), 5)
	end)
	local only: string? = next(profile.Creatures)
	check(
		"it arrives, as the same species and level, once there is room",
		handed == 1
			and only ~= nil
			and profile.Creatures[only].parts.Torso.species == "Sloshcalf"
			and profile.Creatures[only].level == 5
	)
	check("a damaged waiting entry is kept, not lost", StoryProgress.rebuild("junk", "x", 1) == nil)
end

print("\n== Review fixes ==")
do
	-- A content mistake (egg parents that cannot breed) refuses the beat whole: nothing is paid.
	local badGrants: { any } = {
		{ kind = "Coins", amount = 50 },
		{ kind = "Egg", parentA = "Mossmitt", parentB = "Burlhorn" },
	}
	local broken: any = {
		id = "broken",
		number = 0,
		name = "Broken",
		beats = {
			{
				id = "bad_egg",
				name = "",
				minuteFrom = 0,
				minuteTo = 0,
				trigger = { kind = "Start", requires = {} },
				unlocks = {},
				grants = badGrants,
				lines = {},
			},
		},
	}
	local profile = Profile.template()
	local coins = profile.Coins
	local done, why = StoryProgress.complete(profile, broken, input("bad_egg"))
	check(
		"a beat with a gift that cannot be made is refused whole",
		done == nil and profile.Coins == coins and not profile.Story.flags.bad_egg,
		why
	)

	-- The mentor's egg with every pen already full waits, then takes the next free pen.
	local full = Profile.template()
	for _, beat in Chapter1.beats do
		if beat.id == "mentor_egg" then
			break
		end
		StoryProgress.complete(
			full,
			Chapter1,
			input(beat.id, if beat.id == "starter_choice" then "Mossmitt" else nil)
		)
	end
	full.Pens = 4
	local filler = full.Creatures[full.Team[1]]
	for _ = 1, 4 do
		table.insert(full.Eggs, { child = filler, hatchAt = 0, seed = 1 })
	end
	StoryProgress.complete(full, Chapter1, input("mentor_egg"))
	check(
		"with no free pen the gift egg waits",
		#full.Eggs == 4 and #full.Pending == 1 and full.Pending[1].source == "MentorEgg"
	)
	table.remove(full.Eggs, 1)
	local placed = StoryProgress.claimEggs(full, newId, 86400 * 300, 5)
	check("and takes the next free pen", placed == 1 and #full.Eggs == 4 and #full.Pending == 0)

	-- A starter that had to wait joins the empty team when it arrives.
	local waiting = Profile.template()
	waiting.StableCapacity = 0
	StoryProgress.complete(waiting, Chapter1, input("starter_choice", "Mossmitt"))
	waiting.StableCapacity = 30
	Grants.claimPending(waiting, function(_source, ref)
		return StoryProgress.rebuild(ref, newId(), 5)
	end)
	check("a starter that waited joins the empty team", #waiting.Team == 1)
	check("and is in the Index", waiting.Index.owned.Mossmitt == true)
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("story checks failed")
end
