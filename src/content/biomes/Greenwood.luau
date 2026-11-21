--!strict
-- Greenwood (biome 1): one hub town, two routes, a giant's lair on a side path and the gate.
-- Layout from docs/research/market/03_MAP_AND_WORLD.md section 7. Sizes in studs. Written for a
-- first-time player: Route A teaches (levels 2 to 6), Route B builds to the gate (6 to 12).
-- Distances along a route are measured from the hub, so levels rise with distance.
--
-- Where each species lives (every one appears; the two uncommon ones only at rustle spots):
--   Mossmitt, Gorsling: the glade and meadow. Sloshcalf, Splashjack: the brook and the river.
--   Spadesnout: the sandy river bank and the old wood. Stumpwarden: meadow, birch rise, old wood.
--   Stiltbark (uncommon): reed beds, at two rustle spots. Burlhorn (uncommon): the burl thicket.
-- The weights are [Default]s to tune from playtests. The rare-colour chance reuses the breeding
-- rule's rare mutation chance, so one number keeps the two in step.

local BreedConfig = require("../../config/BreedConfig")
local WorldTypes = require("../../shared/WorldTypes")

local RARE = BreedConfig.RARE_MUTATION_CHANCE

local LEAF_COLOURS: { string } = { "Moss", "Bark" }
local SAND_COLOURS: { string } = { "Sand", "Bark" }
local WATER_COLOURS: { string } = { "Moss", "Sand" }

local function row(
	species: string,
	weight: number,
	minLevel: number,
	maxLevel: number,
	area: string,
	colours: { string },
	spot: string?
): WorldTypes.SpawnEntry
	return {
		species = species,
		weight = weight,
		minLevel = minLevel,
		maxLevel = maxLevel,
		area = area,
		spot = spot,
		colours = colours,
		rareColourChance = RARE,
	}
end

local hub: WorldTypes.Hub = {
	id = "greenwood_hub",
	name = "Thistledown",
	size = 300,
	landmark = "The giant old tree over the lair, seen from the square",
	buildings = {
		{ id = "mentor_cottage", name = "The Mentor's Cottage", role = "Mentor", npc = "mentor" },
		{ id = "shop", name = "Tuppence's Shop", role = "Shop", npc = "marlow_tuppence" },
		{ id = "healer", name = "Brightwater House", role = "Healer" },
		{ id = "breeder", name = "The Nesting House", role = "Breeder" },
		{ id = "notice_oak", name = "The Notice Oak", role = "Quests" },
		{ id = "waystation", name = "The Waystation", role = "Teleport" },
		{ id = "ring", name = "The Ring", role = "Circuit" },
	},
}

local routeA: WorldTypes.Route = {
	id = "greenwood_route_a",
	name = "Route A: Clover Lane",
	length = 400,
	width = "40 to 60, opening to 120 at the clover meadow",
	note = "Short and gentle. Teaches wild battles, the lasso, a first tamer; the giant shows on the skyline",
	areas = {
		{
			id = "mossy_glade",
			name = "Mossy Glade",
			from = 0,
			to = 130,
			minLevel = 2,
			maxLevel = 3,
			note = "Soft green clearing just outside the hub; moss mounds and clover tufts",
		},
		{
			id = "clover_meadow",
			name = "Clover Meadow",
			from = 130,
			to = 270,
			minLevel = 3,
			maxLevel = 5,
			note = "Wide meadow with white and yellow flowers; the giant tree stands in the haze",
		},
		{
			id = "brook_bend",
			name = "Brook Bend",
			from = 270,
			to = 400,
			minLevel = 4,
			maxLevel = 6,
			note = "A stream curls round flat stones and a reed bed; the lane ends at the old fence",
		},
	},
	spawns = {
		row("Mossmitt", 50, 2, 3, "mossy_glade", LEAF_COLOURS),
		row("Gorsling", 50, 2, 3, "mossy_glade", LEAF_COLOURS),
		row("Gorsling", 45, 3, 5, "clover_meadow", LEAF_COLOURS),
		row("Mossmitt", 30, 3, 4, "clover_meadow", LEAF_COLOURS),
		row("Stumpwarden", 25, 4, 5, "clover_meadow", LEAF_COLOURS),
		row("Sloshcalf", 45, 4, 6, "brook_bend", WATER_COLOURS),
		row("Splashjack", 40, 4, 6, "brook_bend", WATER_COLOURS),
		row("Gorsling", 15, 4, 5, "brook_bend", LEAF_COLOURS),
		-- Rustle spot: the reed bed.
		row("Stiltbark", 45, 5, 6, "brook_bend", LEAF_COLOURS, "reed_bed"),
		row("Splashjack", 35, 5, 6, "brook_bend", WATER_COLOURS, "reed_bed"),
		row("Sloshcalf", 20, 5, 6, "brook_bend", WATER_COLOURS, "reed_bed"),
	},
	rustleSpots = {
		{
			id = "reed_bed",
			name = "The Reed Bed",
			area = "brook_bend",
			at = 340,
			note = "A thick stand of reeds by the stream that shakes when something tall is inside",
		},
	},
	tamers = { "gw_pip", "gw_wren" },
}

local routeB: WorldTypes.Route = {
	id = "greenwood_route_b",
	name = "Route B: River Road",
	length = 600,
	width = "40 to 60, opening to 120 at the creature meadows",
	note = "Longer and steeper. Follows the river, climbs a birch rise, passes into the old wood and ends at the gate; the lair spur leaves it",
	areas = {
		{
			id = "sandy_bank",
			name = "Sandy Bank",
			from = 0,
			to = 150,
			minLevel = 6,
			maxLevel = 8,
			note = "The river runs beside a pale sandy bank with tall reeds in the shallows",
		},
		{
			id = "birch_rise",
			name = "Birch Rise",
			from = 150,
			to = 330,
			minLevel = 7,
			maxLevel = 9,
			note = "A gentle climb through white birch trunks; the side pocket for materials is here",
		},
		{
			id = "old_wood",
			name = "Old Wood",
			from = 330,
			to = 480,
			minLevel = 9,
			maxLevel = 11,
			note = "Deep green round trees and warm brown trunks; the lair spur forks off at its start",
		},
		{
			id = "gatehouse_approach",
			name = "Gatehouse Approach",
			from = 480,
			to = 600,
			minLevel = 10,
			maxLevel = 12,
			note = "The wood opens on to a stone lane leading up to the gatehouse and its banner",
		},
	},
	spawns = {
		row("Spadesnout", 40, 6, 8, "sandy_bank", SAND_COLOURS),
		row("Sloshcalf", 30, 6, 8, "sandy_bank", WATER_COLOURS),
		row("Splashjack", 30, 6, 8, "sandy_bank", WATER_COLOURS),
		row("Gorsling", 35, 7, 9, "birch_rise", LEAF_COLOURS),
		row("Stumpwarden", 35, 7, 9, "birch_rise", LEAF_COLOURS),
		row("Mossmitt", 30, 7, 9, "birch_rise", LEAF_COLOURS),
		row("Stumpwarden", 35, 9, 11, "old_wood", LEAF_COLOURS),
		row("Mossmitt", 25, 9, 11, "old_wood", LEAF_COLOURS),
		row("Spadesnout", 20, 9, 11, "old_wood", SAND_COLOURS),
		row("Gorsling", 20, 9, 11, "old_wood", LEAF_COLOURS),
		row("Gorsling", 25, 10, 12, "gatehouse_approach", LEAF_COLOURS),
		row("Spadesnout", 25, 10, 12, "gatehouse_approach", SAND_COLOURS),
		row("Splashjack", 25, 10, 12, "gatehouse_approach", WATER_COLOURS),
		row("Mossmitt", 25, 10, 12, "gatehouse_approach", LEAF_COLOURS),
		-- Rustle spot: the heron pool.
		row("Stiltbark", 50, 7, 8, "sandy_bank", LEAF_COLOURS, "heron_pool"),
		row("Splashjack", 50, 7, 8, "sandy_bank", WATER_COLOURS, "heron_pool"),
		-- Rustle spot: the burl thicket.
		row("Burlhorn", 55, 10, 11, "old_wood", LEAF_COLOURS, "burl_thicket"),
		row("Stumpwarden", 45, 9, 11, "old_wood", LEAF_COLOURS, "burl_thicket"),
	},
	rustleSpots = {
		{
			id = "heron_pool",
			name = "The Heron Pool",
			area = "sandy_bank",
			at = 90,
			note = "A shallow pool ringed with reeds just off the river path",
		},
		{
			id = "burl_thicket",
			name = "The Burl Thicket",
			area = "old_wood",
			at = 400,
			note = "A knot of bent trees and knobbly roots that shivers when a heavy creature stirs",
		},
	},
	tamers = { "gw_odette", "gw_basil", "gw_corwin" },
}

local lair: WorldTypes.Lair = {
	id = "greenwood_lair",
	name = "Hollowbough's Hollow",
	joinsRoute = "greenwood_route_b",
	joinsAt = 330,
	spurLength = 250,
	arenaSize = 150,
	giant = "greenwood_hollowbough",
	supplyStall = "Hollow Stall, at the start of the spur: tonics and Giant Horns",
	shortcutToHub = true,
}

local gate: WorldTypes.Gate = {
	id = "greenwood_gate",
	name = "The Greenwood Gatehouse",
	route = "greenwood_route_b",
	at = 600,
	battle = "rival_gate",
	badge = { id = "greenwood_badge", name = "Acorn Badge" },
	sealedPath = "greenwood_sealed_path",
	nextBiome = 2,
	recommendedMin = 12,
	recommendedMax = 15,
}

local Greenwood: WorldTypes.Biome = {
	id = "greenwood",
	number = 1,
	name = "Greenwood",
	element = "Leaf",
	hub = hub,
	routes = { routeA, routeB },
	lair = lair,
	gate = gate,
	levelMin = 2,
	levelMax = 12,
}

return Greenwood
