--!strict
-- Dust Canyon (biome 2): one hub town, two routes, a giant's lair on a spur and the gate. It follows
-- Greenwood's layout (docs/content/GREENWOOD_WORLD.md). Sizes in studs. Route A is the first outing
-- (levels 12 to 16) and Route B climbs to the gate (levels 16 to 22). Distances along a route are
-- measured from the hub, so levels rise with distance. Wild levels stay inside the biome's level
-- band (EconomyConfig.LEVEL_BANDS, 12 to 22) and the cap after one badge (Xp.levelCap(1), 25).
--
-- Where each species lives (every one appears; the two uncommon ones only at rustle spots):
--   Duneskit, Spurlet: the wash and the flats. Whirlgrit, Thatchling: the flats, the rim, the garden.
--   Wadibuck: the arroyo, where a flash flood once ran. Flintknap: the arroyo, the steps and the garden.
--   Cairnback (uncommon): the cairn field, and the capstone garden.
--   Spirecap (uncommon): the echo notch, and the capstone garden.
--   Gorsling and Spadesnout (Greenwood) stray in at the top of the wash, rarely.
-- The weights are [Defaults] to tune from playtests. The rare-colour chance reuses the breeding
-- rule's rare mutation chance, so one number keeps the two in step.
--
-- Gem tier ("Amber"): every open row of a Dust Canyon species has a gem-tier twin at the bottom of
-- its route's table, weighted so that EconomyConfig.GEM_WILD_SHARE of open encounters in each
-- stretch are gem-tier. A caught one gets a serial number. Rustle spots give no gem-tier
-- creatures: their uncommon species are the prize there.

local BreedConfig = require("../../config/BreedConfig")
local EconomyConfig = require("../../config/EconomyConfig")
local Species = require("../Species")
local WorldTypes = require("../../shared/WorldTypes")

local RARE = BreedConfig.RARE_MUTATION_CHANCE

-- A Greenwood species keeps the colour list its Greenwood rows use, so a gifted one wears the same colour.
local LEAF_COLOURS: { string } = { "Moss", "Bark" }
local SAND_COLOURS: { string } = { "Sand", "Bark" }
local WATER_COLOURS: { string } = { "Sand", "Moss" }

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
	id = "dust_canyon_hub",
	name = "Kilnrest",
	size = 300,
	landmark = "The tall red mesa over the lair, seen from the square",
	buildings = {
		{
			id = "kiln_trading_post",
			name = "Rook's Trading Post",
			role = "Shop",
			npc = "tamsin_rook",
		},
		{ id = "seep_house", name = "The Seep House", role = "Healer" },
		{ id = "cradle_kiln", name = "The Cradle Kiln", role = "Breeder" },
		{ id = "notice_wall", name = "The Notice Wall", role = "Quests" },
		{
			id = "sundial_waystation",
			name = "The Sundial Waystation",
			role = "Teleport",
			npc = "fenwick_dray",
		},
		{ id = "dust_ring", name = "The Dust Ring", role = "Circuit" },
		{ id = "windward_overlook", name = "The Windward Overlook", role = "Lookout" },
	},
}

local routeA: WorldTypes.Route = {
	id = "dust_canyon_route_a",
	name = "Route A: Dry Wash Trail",
	length = 450,
	width = "40 to 60, opening to 120 on the tumbleweed flats",
	note = "Short and open. A dry riverbed of rounded stones, then flats, then a narrowing arroyo; the red mesa shows on the skyline",
	areas = {
		{
			id = "pebble_wash",
			name = "Pebble Wash",
			from = 0,
			to = 150,
			minLevel = 12,
			maxLevel = 13,
			note = "A dry riverbed of round pale stones just outside Kilnrest, with a few stubborn green tufts",
		},
		{
			id = "tumbleweed_flats",
			name = "Tumbleweed Flats",
			from = 150,
			to = 300,
			minLevel = 13,
			maxLevel = 15,
			note = "Wide cracked flats with drifts of tumbleweed against low ochre rocks",
		},
		{
			id = "hollow_arroyo",
			name = "Hollow Arroyo",
			from = 300,
			to = 450,
			minLevel = 14,
			maxLevel = 16,
			note = "A narrowing gully with banded walls; the trail ends at a rope bridge over a dry fall",
		},
	},
	spawns = {
		row("Duneskit", 50, 12, 13, "pebble_wash", SAND_COLOURS),
		row("Spurlet", 45, 12, 13, "pebble_wash", LEAF_COLOURS),
		-- Strays from Greenwood, near the entrance only.
		row("Gorsling", 8, 12, 13, "pebble_wash", LEAF_COLOURS),
		row("Spadesnout", 8, 12, 13, "pebble_wash", SAND_COLOURS),
		row("Duneskit", 40, 13, 15, "tumbleweed_flats", SAND_COLOURS),
		row("Whirlgrit", 35, 13, 15, "tumbleweed_flats", SAND_COLOURS),
		row("Thatchling", 35, 13, 15, "tumbleweed_flats", LEAF_COLOURS),
		row("Spurlet", 25, 13, 15, "tumbleweed_flats", LEAF_COLOURS),
		row("Wadibuck", 45, 14, 16, "hollow_arroyo", WATER_COLOURS),
		row("Flintknap", 35, 14, 16, "hollow_arroyo", SAND_COLOURS),
		row("Whirlgrit", 25, 14, 16, "hollow_arroyo", SAND_COLOURS),
		row("Thatchling", 25, 14, 16, "hollow_arroyo", LEAF_COLOURS),
		-- Rustle spot: the cairn field.
		row("Cairnback", 50, 15, 16, "hollow_arroyo", SAND_COLOURS, "cairn_field"),
		row("Wadibuck", 30, 15, 16, "hollow_arroyo", WATER_COLOURS, "cairn_field"),
		row("Flintknap", 20, 15, 16, "hollow_arroyo", SAND_COLOURS, "cairn_field"),
	},
	rustleSpots = {
		{
			id = "cairn_field",
			name = "The Cairn Field",
			area = "hollow_arroyo",
			at = 390,
			note = "A scatter of stacked-stone trail markers that clatters when something heavy brushes past",
		},
	},
	tamers = { "dc_ines", "dc_rafe" },
}

local routeB: WorldTypes.Route = {
	id = "dust_canyon_route_b",
	name = "Route B: Mesa Road",
	length = 680,
	width = "40 to 60, opening to 120 in the spire garden",
	note = "Longer and steeper. Climbs red stone steps, runs along a sunbaked rim and through a garden of rock spires, and ends at the Stair Gate; the lair spur leaves it",
	areas = {
		{
			id = "redstone_steps",
			name = "Redstone Steps",
			from = 0,
			to = 170,
			minLevel = 16,
			maxLevel = 18,
			note = "Broad red stone ledges cut like stairs up the canyon side, with a kiln chimney in the distance",
		},
		{
			id = "sunbaked_rim",
			name = "Sunbaked Rim",
			from = 170,
			to = 340,
			minLevel = 17,
			maxLevel = 19,
			note = "A bare ledge along the canyon edge with a long drop on one side and wind-carved hollows on the other",
		},
		{
			id = "spire_garden",
			name = "Spire Garden",
			from = 340,
			to = 520,
			minLevel = 18,
			maxLevel = 21,
			note = "Rock spires in rust, cream and red stripes stand like a forest; the lair spur forks off near its start",
		},
		{
			id = "stair_approach",
			name = "Stair Approach",
			from = 520,
			to = 680,
			minLevel = 20,
			maxLevel = 22,
			note = "The spires thin out on to a stone road climbing to the Stair Gate and its brass-and-ochre banner",
		},
	},
	spawns = {
		row("Flintknap", 40, 16, 18, "redstone_steps", SAND_COLOURS),
		row("Duneskit", 35, 16, 18, "redstone_steps", SAND_COLOURS),
		row("Wadibuck", 30, 16, 18, "redstone_steps", WATER_COLOURS),
		row("Whirlgrit", 30, 16, 18, "redstone_steps", SAND_COLOURS),
		row("Whirlgrit", 35, 17, 19, "sunbaked_rim", SAND_COLOURS),
		row("Thatchling", 35, 17, 19, "sunbaked_rim", LEAF_COLOURS),
		row("Spurlet", 30, 17, 19, "sunbaked_rim", LEAF_COLOURS),
		row("Duneskit", 30, 17, 19, "sunbaked_rim", SAND_COLOURS),
		row("Flintknap", 25, 17, 19, "sunbaked_rim", SAND_COLOURS),
		row("Flintknap", 35, 18, 21, "spire_garden", SAND_COLOURS),
		row("Thatchling", 30, 18, 21, "spire_garden", LEAF_COLOURS),
		row("Whirlgrit", 30, 18, 21, "spire_garden", SAND_COLOURS),
		row("Wadibuck", 25, 18, 21, "spire_garden", WATER_COLOURS),
		row("Spurlet", 20, 18, 21, "spire_garden", LEAF_COLOURS),
		row("Duneskit", 30, 20, 22, "stair_approach", SAND_COLOURS),
		row("Whirlgrit", 30, 20, 22, "stair_approach", SAND_COLOURS),
		row("Flintknap", 30, 20, 22, "stair_approach", SAND_COLOURS),
		row("Thatchling", 25, 20, 22, "stair_approach", LEAF_COLOURS),
		row("Wadibuck", 25, 20, 22, "stair_approach", WATER_COLOURS),
		row("Spurlet", 25, 20, 22, "stair_approach", LEAF_COLOURS),
		-- Rustle spot: the echo notch.
		row("Spirecap", 45, 18, 19, "sunbaked_rim", SAND_COLOURS, "echo_notch"),
		row("Whirlgrit", 35, 18, 19, "sunbaked_rim", SAND_COLOURS, "echo_notch"),
		row("Duneskit", 20, 18, 19, "sunbaked_rim", SAND_COLOURS, "echo_notch"),
		-- Rustle spot: the capstone garden.
		row("Spirecap", 40, 20, 21, "spire_garden", SAND_COLOURS, "capstone_garden"),
		row("Cairnback", 35, 20, 21, "spire_garden", SAND_COLOURS, "capstone_garden"),
		row("Thatchling", 25, 20, 21, "spire_garden", LEAF_COLOURS, "capstone_garden"),
	},
	rustleSpots = {
		{
			id = "echo_notch",
			name = "The Echo Notch",
			area = "sunbaked_rim",
			at = 200,
			note = "A narrow cleft in the rim wall that hums and echoes when a tall creature shifts inside",
		},
		{
			id = "capstone_garden",
			name = "The Capstone Garden",
			area = "spire_garden",
			at = 500,
			note = "A cluster of spires each wearing a flat cap of rock, rattling when something sturdy leans on them",
		},
	},
	tamers = { "dc_perrin", "dc_hesper", "dc_tavish" },
}

local lair: WorldTypes.Lair = {
	id = "dust_canyon_lair",
	name = "Mesalith's Shelf",
	joinsRoute = "dust_canyon_route_b",
	joinsAt = 360,
	spurLength = 260,
	arenaSize = 160,
	giant = "dust_canyon_mesalith",
	supplyStall = "Shelf Stall, at the start of the spur: tonics and Giant Horns",
	shortcutToHub = true,
}

local gate: WorldTypes.Gate = {
	id = "dust_canyon_gate",
	name = "The Stair Gate",
	route = "dust_canyon_route_b",
	at = 680,
	battle = "champion_karrow",
	badge = { id = "dust_canyon_badge", name = "Cairn Badge" },
	sealedPath = "dust_canyon_sealed_path",
	nextBiome = 3,
	recommendedMin = 22,
	recommendedMax = 25,
}

-- Adds the gem-tier twins to a route's open rows (see the note at the top).
local function withGems(route: WorldTypes.Route)
	local share = EconomyConfig.GEM_WILD_SHARE
	local twins: { WorldTypes.SpawnEntry } = {}
	for _, entry in route.spawns do
		if entry.spot == nil and Species[entry.species].biome == 2 then
			table.insert(twins, {
				species = entry.species,
				weight = entry.weight * share / (1 - share),
				minLevel = entry.minLevel,
				maxLevel = entry.maxLevel,
				area = entry.area,
				spot = nil,
				colours = entry.colours,
				rareColourChance = entry.rareColourChance,
				rarity = "Gem",
			})
		end
	end
	for _, twin in twins do
		table.insert(route.spawns, twin)
	end
end
withGems(routeA)
withGems(routeB)

local DustCanyon: WorldTypes.Biome = {
	id = "dust_canyon",
	number = 2,
	name = "Dust Canyon",
	element = "Sand",
	hub = hub,
	routes = { routeA, routeB },
	lair = lair,
	gate = gate,
	levelMin = 12,
	levelMax = 22,
	map = require("../map_data/DustCanyon"),
}

return DustCanyon
