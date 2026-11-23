--!strict
-- Checks that River Road stays closed to a new player until Marlow's first quest opens it, and
-- that wild battles wait for the lasso lesson. Run from the project folder:  lune run tests/holds.test

local Biomes = require("../src/content/Biomes")
local Chapter1 = require("../src/content/story_data/Chapter1")
local GreenwoodMap = require("../src/content/map_data/Greenwood")
local Ground = require("../src/shared/Ground")
local GreenwoodDressing = require("../src/content/map_data/GreenwoodDressing")
local Layout = require("../src/shared/Layout")
local Tamers = require("../src/content/Tamers")
local Walk = require("../src/shared/Walk")
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

-- The place a held player is put back at must be real, walkable ground that can be reached from
-- the town, outside the hold, at the height the server will use (heightAt + 6).
print("The way back is reachable ground")
do
	local ordered: { WorldTypes.Biome } = {}
	for _, biome in Biomes do
		table.insert(ordered, biome)
	end
	table.sort(ordered, function(a, b)
		return a.number < b.number
	end)
	local world = Layout.world(ordered, Tamers.locals)
	local greenwood = ordered[1]
	local map = world.maps[greenwood.number]
	local sheet = greenwood.map
	if sheet and sheet.holds then
		local space = Walk.space(greenwood, map, GreenwoodDressing)
		local ground = Ground.new(sheet, { x = map.hub.x, z = map.hub.z })
		local grid = Walk.grid(space, ground, {
			x0 = map.hub.x - 200,
			z0 = map.hub.z - 300,
			x1 = map.hub.x + 600,
			z1 = map.hub.z + 300,
		}, 4)
		local start = if map.spawn then map.spawn.at else map.places[greenwood.hub.id]
		local out = Walk.reach(grid, start.x, start.z)
		for _, each in sheet.holds do
			local x, z = map.hub.x + each.back.x, map.hub.z + each.back.z
			check(`{each.id}: the way back is open ground`, Walk.open(space, x, z))
			check(
				`{each.id}: the way back can be walked to from town`,
				Walk.reached(grid, out, x, z)
			)
			local height = Ground.heightAt(ground, x, z)
			check(`{each.id}: the way back has a finite height`, height == height and height > -50)
			check(
				`{each.id}: the way back is outside its own hold`,
				World.holdAt(sheet.holds, { x = map.hub.x, z = map.hub.z }, function()
					return false
				end, { x = x, z = z }) == nil
			)
		end
	end
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("hold checks failed")
end
