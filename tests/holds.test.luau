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

-- Dust Canyon's Mesa Road and Tide Flats' Breakwater Road wait for the second letter and note
-- (`mentors_letter` and `mentors_note` open them), and the roads on past each gate wait for the
-- badge, so a new arrival is not met by creatures ten levels above them.
print("The second and third biomes' roads")
do
	local Chapter2 = require("../src/content/story_data/Chapter2")
	local Chapter3 = require("../src/content/story_data/Chapter3")
	local DustMap = require("../src/content/map_data/DustCanyon")
	local TideMap = require("../src/content/map_data/TideFlats")
	local Quests = require("../src/content/Quests")
	local story: { WorldTypes.Chapter } = { Chapter1, Chapter2, Chapter3 }
	local function flagsAfter(last: string): { [string]: boolean }
		local flags: { [string]: boolean } = {}
		for _, chapter in story do
			for _, beat in chapter.beats do
				flags[beat.id] = true
				if beat.id == last then
					return flags
				end
			end
		end
		error(`no beat {last}`)
	end
	local function openAfter(last: string): (string) -> boolean
		local flags = flagsAfter(last)
		return function(feature: string): boolean
			return World.isUnlocked(story, flags, feature)
		end
	end
	local function holdIn(sheet: WorldTypes.MapSheet, id: string): WorldTypes.Hold?
		local list: { WorldTypes.Hold } = sheet.holds or {}
		for _, each in list do
			if each.id == id then
				return each
			end
		end
		return nil
	end
	local function heldAt(
		sheet: WorldTypes.MapSheet,
		open: (string) -> boolean,
		x: number,
		z: number
	): string?
		local found = World.holdAt(sheet.holds, hub, open, { x = x, z = z })
		return if found then found.id else nil
	end
	local function questFlags(id: string): { string }
		for _, quest in Quests do
			if quest.id == id then
				return quest.requiresFlags
			end
		end
		error(`no quest {id}`)
	end

	-- Dust Canyon
	check("Dust Canyon has a Mesa Road hold", holdIn(DustMap, "mesa_road") ~= nil)
	check("and a hold past the Stair Gate", holdIn(DustMap, "sealed_road") ~= nil)
	local arrived = openAfter("canyon_arrival")
	check("on arrival the Sunbaked Rim is held", heldAt(DustMap, arrived, 370, -68) == "mesa_road")
	check("and the Spire Garden", heldAt(DustMap, arrived, 560, -100) == "mesa_road")
	check("and the Stair Gate's approach", heldAt(DustMap, arrived, 745, -100) == "mesa_road")
	check("and Mesalith's Shelf", heldAt(DustMap, arrived, 576, -319) == "mesa_road")
	check("the Dry Wash is free", heldAt(DustMap, arrived, 44, -212) == nil)
	check("and the Tumbleweed Flats and the arroyo", heldAt(DustMap, arrived, 67, -486) == nil)
	check("and the town", heldAt(DustMap, arrived, 50, -6) == nil)
	check(
		"still held after the first tamer, before the letter",
		heldAt(DustMap, openAfter("first_canyon_tamer"), 370, -68) == "mesa_road"
	)
	check(
		"open once the mentor's letter has come",
		heldAt(DustMap, openAfter("mentors_letter"), 370, -68) == nil
	)
	check(
		"the rim, the garden and the gate are open for the rival and the sighting",
		heldAt(DustMap, openAfter("mentors_letter"), 560, -100) == nil
			and heldAt(DustMap, openAfter("canyon_rival"), 575, -100) == nil
			and heldAt(DustMap, openAfter("mesa_sighting"), 779, -100) == nil
	)
	check(
		"the road past the gate is held until the Cairn Badge",
		heldAt(DustMap, openAfter("canyon_gate_challenge"), 800, -100) == "sealed_road"
			and heldAt(DustMap, openAfter("canyon_badge"), 800, -100) == nil
	)
	check(
		"Fenwick's quest about the Mesa Road waits for the letter",
		table.find(questFlags("dc_survey_trouble"), "mentors_letter") ~= nil
	)

	-- Tide Flats
	check("Tide Flats has a Breakwater Road hold", holdIn(TideMap, "breakwater_road") ~= nil)
	check("a hold past the Breakwater Gate", holdIn(TideMap, "sealed_road") ~= nil)
	check("and one on the Dune Road in from Dust Canyon", holdIn(TideMap, "dune_road") ~= nil)
	local landed = openAfter("tide_arrival")
	check(
		"on arrival the boardwalk is held",
		heldAt(TideMap, landed, 335, 183) == "breakwater_road"
	)
	check("and the wreck", heldAt(TideMap, landed, 500, 190) == "breakwater_road")
	check("and the gate's approach", heldAt(TideMap, landed, 700, 110) == "breakwater_road")
	check("but the causeway is free", heldAt(TideMap, landed, 228, 104) == nil)
	check(
		"and Strandline Path, down to the kelp",
		heldAt(TideMap, landed, -122, 177) == nil and heldAt(TideMap, landed, 150, 402) == nil
	)
	check("and the town", heldAt(TideMap, landed, 48, -14) == nil)
	check(
		"still held before the mentor's note",
		heldAt(TideMap, openAfter("bait_catch"), 335, 183) == "breakwater_road"
	)
	check(
		"open once the note has come",
		heldAt(TideMap, openAfter("mentors_note"), 335, 183) == nil
	)
	check(
		"the road past the gate waits for the Breaker Badge",
		heldAt(TideMap, openAfter("tide_gate_challenge"), 800, 110) == "sealed_road"
			and heldAt(TideMap, openAfter("tide_badge"), 800, 110) == nil
	)
	check(
		"the Dune Road waits for the Cairn Badge, for someone who skipped the bar",
		heldAt(TideMap, openAfter("canyon_gate_challenge"), -200, 0) == "dune_road"
			and heldAt(TideMap, openAfter("canyon_badge"), -200, 0) == nil
	)
	check(
		"Isaura's quest about Breakwater Road waits for the note",
		table.find(questFlags("tf_lamp_trouble"), "mentors_note") ~= nil
	)
end

-- The place a held player is put back at must be real, walkable ground that can be reached from
-- the town, outside the hold, at the height the server will use (heightAt + 6). A way back can
-- be on the neighbouring biome's ground (the Dune Road sends a player back to the Stair Gate), so
-- it is checked against the ground of whichever biome the point is in.
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
	local dressings: { WorldTypes.DressingSheet } = {
		GreenwoodDressing,
		require("../src/content/map_data/DustCanyonDressing"),
		require("../src/content/map_data/TideFlatsDressing"),
	}
	local bounds = {
		{ x0 = -450, z0 = -420, x1 = 760, z1 = 160 },
		{ x0 = -240.7, z0 = -800.7, x1 = 900, z1 = 150 },
		{ x0 = -300.7, z0 = -170.7, x1 = 880, z1 = 520 },
	}
	type Built = {
		space: Walk.Space,
		ground: Ground.Ground,
		grid: Walk.Grid,
		out: Walk.Reach,
	}
	-- Each biome's walkable ground, made once.
	local built: { [number]: Built } = {}
	local function groundOf(number: number): Built
		local known = built[number]
		if known then
			return known
		end
		local biome = ordered[number]
		local map = world.maps[number]
		local sheet = biome.map
		assert(sheet, `{biome.id} has a sheet`)
		local space = Walk.space(biome, map, dressings[number])
		local ground = Ground.new(sheet, { x = map.hub.x, z = map.hub.z })
		local box = bounds[number]
		local grid = Walk.grid(space, ground, {
			x0 = map.hub.x + box.x0,
			z0 = map.hub.z + box.z0,
			x1 = map.hub.x + box.x1,
			z1 = map.hub.z + box.z1,
		}, 4)
		local start = if map.spawn then map.spawn.at else map.places[biome.hub.id]
		local made: Built = {
			space = space,
			ground = ground,
			grid = grid,
			out = Walk.reach(grid, start.x, start.z),
		}
		built[number] = made
		return made
	end
	for number = 1, 3 do
		local biome = ordered[number]
		local map = world.maps[number]
		local sheet = biome.map
		if sheet and sheet.holds then
			for _, each in sheet.holds do
				local x, z = map.hub.x + each.back.x, map.hub.z + each.back.z
				local there = Layout.biomeAt(world, { x = x, z = z }) or number
				local own = groundOf(there)
				local name = `{biome.id} {each.id}`
				check(`{name}: the way back is open ground`, Walk.open(own.space, x, z))
				check(
					`{name}: the way back can be walked to from town`,
					Walk.reached(own.grid, own.out, x, z)
				)
				local height = Ground.heightAt(own.ground, x, z)
				check(`{name}: the way back has a finite height`, height == height and height > -50)
				check(
					`{name}: the way back is outside its own hold`,
					World.holdAt({ each }, { x = map.hub.x, z = map.hub.z }, function()
						return false
					end, { x = x, z = z }) == nil
				)
			end
		end
	end
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("hold checks failed")
end
