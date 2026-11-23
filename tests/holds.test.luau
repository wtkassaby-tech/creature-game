--!strict
-- Checks that River Road stays closed to a new player until Marlow's first quest opens it, and
-- that wild battles wait for the lasso lesson. Run from the project folder:  lune run tests/holds.test

local Chapter1 = require("../src/content/story_data/Chapter1")
local GreenwoodMap = require("../src/content/map_data/Greenwood")
local World = require("../src/shared/World")
local WorldTypes = require("../src/shared/WorldTypes")

local passed, failed = 0, 0
local function check(name: string, condition: boolean)
	if condition then
		passed += 1
	else
		failed += 1
	end
	print(`  {if condition then "PASS" else "FAIL"}  {name}`)
end

local chapters: { WorldTypes.Chapter } = { Chapter1 }
local hub = { x = 0, z = 0 }

-- The flags a player has once every beat up to and including `last` is done.
local function flagsThrough(last: string): { [string]: boolean }
	local flags: { [string]: boolean } = {}
	for _, beat in Chapter1.beats do
		flags[beat.id] = true
		if beat.id == last then
			break
		end
	end
	return flags
end

local function openFor(flags: { [string]: boolean }): (string) -> boolean
	return function(feature: string): boolean
		return World.isUnlocked(chapters, flags, feature)
	end
end

local holds = GreenwoodMap.holds
check("Greenwood has a River Road hold", holds ~= nil and #holds > 0)

local fresh = openFor({})
check(
	"a new player on River Road is held",
	World.holdAt(holds, hub, fresh, { x = 300, z = -10 }) ~= nil
)
check(
	"the town side of the arch is free",
	World.holdAt(holds, hub, fresh, { x = 100, z = 0 }) == nil
)
local hold = World.holdAt(holds, hub, fresh, { x = 300, z = -10 })
if hold then
	check("the way back is outside the hold", World.holdAt(holds, hub, fresh, hold.back) == nil)
end

local beforeQuest = openFor(flagsThrough("third_creature"))
check(
	"still held just before Marlow's quest",
	World.holdAt(holds, hub, beforeQuest, { x = 300, z = -10 }) ~= nil
)
local afterQuest = openFor(flagsThrough("first_quest"))
check(
	"open once Marlow's quest begins",
	World.holdAt(holds, hub, afterQuest, { x = 300, z = -10 }) == nil
)

check(
	"no wild battles before the lasso lesson",
	not World.isUnlocked(chapters, flagsThrough("rival_parting"), "wild_battles")
)
check(
	"wild battles after the lasso lesson",
	World.isUnlocked(chapters, flagsThrough("lasso_lesson"), "wild_battles")
)

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("hold checks failed")
end
