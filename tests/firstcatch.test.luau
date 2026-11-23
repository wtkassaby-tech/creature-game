--!strict
-- Checks the help for a player's first catch and that a catch made before the story asks for
-- one still counts (Ayrton, 23 November 2026). Run from the project folder:
--   lune run tests/firstcatch.test

local Chapter1 = require("../src/content/story_data/Chapter1")
local Chapter2 = require("../src/content/story_data/Chapter2")
local Capture = require("../src/shared/Capture")
local Lasso = require("../src/shared/Lasso")
local LassoConfig = require("../src/config/LassoConfig")
local Layout = require("../src/shared/Layout")
local Profile = require("../src/shared/Profile")
local StoryTriggers = require("../src/shared/StoryTriggers")
local Types = require("../src/shared/Types")
local WorldTypes = require("../src/shared/WorldTypes")

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

local function width(rarity: Types.Rarity, health: number, first: boolean?, giant: boolean?): number
	local pattern = Lasso.createAttempt({
		seed = 7,
		lassoDifficulty = 1,
		rarity = rarity,
		healthFraction = health,
		tier = "Basic",
		isGiant = giant == true,
		slowMode = false,
		roundTripMs = 80,
		firstCatch = first,
	})
	return pattern.zones[1].width
end

print("The first catch")
local plain = width("Common", 1)
local helped = width("Common", 1, true)
check(
	"a first catch at full health is far wider",
	helped >= LassoConfig.FIRST_CATCH_MIN_WIDTH,
	`{plain} -> {helped}`
)
check("a later catch is unchanged", width("Common", 1, false) == plain)
check(
	"an Uncommon first catch is helped too",
	width("Uncommon", 0.5, true) > width("Uncommon", 0.5)
)
check("a Gem creature never gets the help", width("Gem", 0.3, true) == width("Gem", 0.3))
check(
	"a giant never gets the help",
	width("Common", 0.3, true, true) == width("Common", 0.3, false, true)
)
check(
	"never wider than the most any zone may be",
	width("Common", 0, true) <= LassoConfig.MAX_WIDTH
)

local profile = Profile.template()
check("a new player has not caught", not Capture.hasCaught(profile))

print("A catch before the story asks")
local storyline: WorldTypes.Chapter = {
	id = "test",
	number = 0,
	name = "Chapters 1 and 2",
	beats = table.move(
		Chapter2.beats,
		1,
		#Chapter2.beats,
		#Chapter1.beats + 1,
		table.clone(Chapter1.beats)
	),
}
local map = Layout.world({}, {}).map

local function doneThrough(p: Profile.Profile, last: string)
	for _, beat in storyline.beats do
		p.Story.flags[beat.id] = true
		if beat.id == last then
			break
		end
	end
end

local early = Profile.template()
doneThrough(early, "lasso_lesson")
local credited = StoryTriggers.creditTame(storyline, early, 1)
check(
	"a catch after the lasso lesson is kept for Chapter 1's tame beat",
	credited == "third_creature",
	tostring(credited)
)
-- The story moves on to the egg; then the tame beat is next and is already met.
doneThrough(early, "mentor_egg")
local ready = StoryTriggers.ready(storyline, early, map, { kind = "At", at = { x = 0, z = 0 } })
check(
	"the tame beat completes once the story reaches it",
	ready ~= nil and ready.id == "third_creature"
)

local fresh = Profile.template()
doneThrough(fresh, "mentor_egg")
local notYet = StoryTriggers.ready(storyline, fresh, map, { kind = "At", at = { x = 0, z = 0 } })
check("without a catch the tame beat waits", notYet == nil)

-- A catch late in Chapter 1 must not complete Chapter 2's tame beat.
local late = Profile.template()
doneThrough(late, "third_creature")
local creditLate = StoryTriggers.creditTame(storyline, late, 1)
local chapter2Tame: string? = nil
for _, beat in Chapter2.beats do
	if beat.trigger.kind == "Tame" then
		chapter2Tame = beat.id
		break
	end
end
check(
	"a Chapter 1 catch never counts toward Chapter 2",
	creditLate == nil or creditLate ~= chapter2Tame,
	tostring(creditLate)
)

-- The real boundary: Chapter 1 is finished, so the next beat is in Chapter 2. A Greenwood catch on
-- the way back must not complete the canyon's tame beat; a canyon catch does.
local boundary = Profile.template()
doneThrough(boundary, "sealed_path")
check(
	"a Greenwood catch after Chapter 1 does not count for the canyon",
	StoryTriggers.creditTame(storyline, boundary, 1) == nil
)
check(
	"a canyon catch then counts for the canyon's tame beat",
	chapter2Tame ~= nil and StoryTriggers.creditTame(storyline, boundary, 2) == chapter2Tame
)

print("Older saves")
local older = Profile.template()
older.Story.flags.third_creature = true
check(
	"a save that finished the team-of-three beat counts as having caught",
	Capture.hasCaught(older)
)

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("first catch checks failed")
end
