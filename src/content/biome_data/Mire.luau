--!strict
-- The Mire (biome 4): one hub town, two routes, a giant's lair on a spur and the gate. It follows
-- Tide Flats' layout (docs/content/TIDE_FLATS_WORLD.md). Sizes in studs. Route A is the first
-- outing (levels 32 to 37) and Route B climbs to the gate (levels 37 to 42). Distances along a route
-- are measured from the hub, so levels rise with distance. Wild levels stay inside the biome's level
-- band (EconomyConfig.LEVEL_BANDS, 32 to 42) and the cap after three badges (Xp.levelCap(3), 45).
-- Written ahead of launch: src/config/ReleaseConfig.luau keeps it closed until its map and art exist.
--
-- Where each species lives (every one appears; the two uncommon ones only at rustle spots):
--   Fenwhisk, Skipslick: from the first stretch, so a Toxic creature (immune to poison) can be
--     caught within a minute of town. Mistrel, Lilyshade (the Water pair): Reedfringe and Lily Lanes on.
--   Snaggar, Keelsnap (the strikers): the Lily Lanes and the Mangrove Tangle onward.
--   Bulbroth (uncommon): the Bubbling Pool and the Sinkhole, where a cauldron belly is at home.
--   Bogbellow (uncommon): the Steaming Hummock (a peat mound) and the Sinkhole.
--   Glissot and Cocklemole (Tide Flats) stray in at the Reedfringe, rarely. Cocklemole is Sand, which
--   beats Toxic: a lucky early catch, not a plan.
-- Bait (Tide Flats' idea) still works at every rustle spot. The weights are [Defaults] to tune from
-- playtests. The rare-colour chance reuses the breeding rule's rare mutation chance.
--
-- Gem tier ("Amber"): as in Tide Flats, every open row of a Mire species has a gem-tier twin at the
-- bottom of its route's table, weighted so that EconomyConfig.GEM_WILD_SHARE of open encounters in
-- each stretch are gem-tier. Rustle spots give no gem-tier creatures from the table.

local BreedConfig = require("../../config/BreedConfig")
local EconomyConfig = require("../../config/EconomyConfig")
local Species = require("../Species")
local WorldTypes = require("../../shared/WorldTypes")

local RARE = BreedConfig.RARE_MUTATION_CHANCE

-- A Tide Flats species keeps the colour list its Tide Flats rows use, so a gifted one wears the same colour.
local TIDE_COLOURS: { string } = { "Moss", "Sand" }
local SHELL_COLOURS: { string } = { "Sand", "Bark" }
-- The Mire's own creatures.
local REED_COLOURS: { string } = { "Moss", "Bark" }
local MUD_COLOURS: { string } = { "Bark", "Moss" }
local FROG_COLOURS: { string } = { "Sand", "Bark" }
local POND_COLOURS: { string } = { "Moss", "Sand" }

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
	id = "mire_hub",
	name = "Sedgeholm",
	size = 300,
	landmark = "The Bell Cypress, a huge old tree in the middle of the village with a bronze fog bell in its branches",
	buildings = {
		{
			id = "quill_sundries",
			name = "Quill's Sundries",
			role = "Shop",
			npc = "vesper_quill",
		},
		{
			id = "clearwater_spring",
			name = "The Clearwater Spring",
			role = "Healer",
			npc = "ottilie_dunmore",
		},
		{ id = "reed_nursery", name = "The Reed Nursery", role = "Breeder" },
		{ id = "mooring_post", name = "The Mooring Post", role = "Quests" },
		{
			id = "punt_landing",
			name = "The Punt Landing",
			role = "Teleport",
			npc = "jory_pike",
		},
		{ id = "cypress_ring", name = "The Cypress Ring", role = "Circuit" },
		{ id = "bell_loft", name = "The Bell Loft", role = "Lookout" },
	},
}

local routeA: WorldTypes.Route = {
	id = "mire_route_a",
	name = "Route A: Duckboard Trail",
	length = 500,
	width = "30 to 50 on the duckboards, opening to 110 in the lily lanes",
	note = "Short and wet. Plank walks over soft mud through tall reeds, then channels of lily pads, then a tangle of mangrove roots; the Bell Cypress stays on the skyline",
	areas = {
		{
			id = "reedfringe",
			name = "Reedfringe",
			from = 0,
			to = 160,
			minLevel = 32,
			maxLevel = 33,
			note = "Where the salt marsh turns fresh: tall reeds taller than a player, duckboards, the first small mangroves",
		},
		{
			id = "lily_lanes",
			name = "Lily Lanes",
			from = 160,
			to = 330,
			minLevel = 33,
			maxLevel = 35,
			note = "Channels of still dark water carpeted with lily pads and white flowers, crossed on stepping logs",
		},
		{
			id = "mangrove_tangle",
			name = "Mangrove Tangle",
			from = 330,
			to = 500,
			minLevel = 35,
			maxLevel = 37,
			note = "Arching mangrove roots with a low mist at knee height; the trail ends at a rope ferry across a channel",
		},
	},
	spawns = {
		row("Fenwhisk", 45, 32, 33, "reedfringe", REED_COLOURS),
		row("Skipslick", 45, 32, 33, "reedfringe", FROG_COLOURS),
		row("Mistrel", 30, 32, 33, "reedfringe", POND_COLOURS),
		-- Strays from Tide Flats, near the entrance only.
		row("Glissot", 8, 32, 33, "reedfringe", TIDE_COLOURS),
		row("Cocklemole", 8, 32, 33, "reedfringe", SHELL_COLOURS),
		row("Lilyshade", 45, 33, 35, "lily_lanes", POND_COLOURS),
		row("Skipslick", 35, 33, 35, "lily_lanes", FROG_COLOURS),
		row("Fenwhisk", 30, 33, 35, "lily_lanes", REED_COLOURS),
		row("Keelsnap", 25, 33, 35, "lily_lanes", MUD_COLOURS),
		row("Snaggar", 40, 35, 37, "mangrove_tangle", REED_COLOURS),
		row("Keelsnap", 35, 35, 37, "mangrove_tangle", MUD_COLOURS),
		row("Mistrel", 30, 35, 37, "mangrove_tangle", POND_COLOURS),
		row("Lilyshade", 30, 35, 37, "mangrove_tangle", POND_COLOURS),
		-- Rustle spot: the bubbling pool.
		row("Bulbroth", 45, 34, 35, "lily_lanes", MUD_COLOURS, "bubbling_pool"),
		row("Lilyshade", 30, 34, 35, "lily_lanes", POND_COLOURS, "bubbling_pool"),
		row("Skipslick", 25, 34, 35, "lily_lanes", FROG_COLOURS, "bubbling_pool"),
		-- Rustle spot: the steaming hummock.
		row("Bogbellow", 45, 36, 37, "mangrove_tangle", REED_COLOURS, "steaming_hummock"),
		row("Snaggar", 30, 36, 37, "mangrove_tangle", REED_COLOURS, "steaming_hummock"),
		row("Mistrel", 25, 36, 37, "mangrove_tangle", POND_COLOURS, "steaming_hummock"),
	},
	rustleSpots = {
		{
			id = "bubbling_pool",
			name = "The Bubbling Pool",
			area = "lily_lanes",
			at = 260,
			note = "A round pool between the lily pads where big green bubbles rise and pop, as if something below is cooking",
		},
		{
			id = "steaming_hummock",
			name = "The Steaming Hummock",
			area = "mangrove_tangle",
			at = 430,
			note = "A low mound of dark peat among the roots, with little puffs of green steam that snort when something heavy shifts inside",
		},
	},
	tamers = { "mr_wren", "mr_marisol" },
}

local routeB: WorldTypes.Route = {
	id = "mire_route_b",
	name = "Route B: Cypress Road",
	length = 720,
	width = "30 to 50, opening to 120 on the fogwater",
	note = "Longer and stiller. Old peat cuttings, an empty stilt hamlet, a wide misty water of cypress knees and a peat rise to the Sluice Gate; the lair spur leaves it on the fogwater",
	areas = {
		{
			id = "peat_cuttings",
			name = "Peat Cuttings",
			from = 0,
			to = 180,
			minLevel = 37,
			maxLevel = 38,
			note = "Old peat diggings: square black pools in neat rows, stacks of drying turf, a forgotten wheelbarrow",
		},
		{
			id = "stilt_hamlet",
			name = "Old Stilt Hamlet",
			from = 180,
			to = 360,
			minLevel = 38,
			maxLevel = 40,
			note = "A cluster of empty stilt huts leaning over the water, left when the water rose; frogs sing on every porch",
		},
		{
			id = "fogwater_reach",
			name = "Fogwater Reach",
			from = 360,
			to = 540,
			minLevel = 39,
			maxLevel = 41,
			note = "A wide stretch of still, misty water and cypress knees with soft green lights drifting at the edges; the lair spur forks off near its middle",
		},
		{
			id = "sluice_rise",
			name = "Sluice Rise",
			from = 540,
			to = 720,
			minLevel = 40,
			maxLevel = 42,
			note = "A raised path of packed peat climbing to the Sluice Gate, a huge old wooden lock gate under a green-and-violet banner",
		},
	},
	spawns = {
		row("Snaggar", 40, 37, 38, "peat_cuttings", REED_COLOURS),
		row("Fenwhisk", 35, 37, 38, "peat_cuttings", REED_COLOURS),
		row("Keelsnap", 30, 37, 38, "peat_cuttings", MUD_COLOURS),
		row("Mistrel", 30, 37, 38, "peat_cuttings", POND_COLOURS),
		row("Skipslick", 35, 38, 40, "stilt_hamlet", FROG_COLOURS),
		row("Lilyshade", 35, 38, 40, "stilt_hamlet", POND_COLOURS),
		row("Keelsnap", 30, 38, 40, "stilt_hamlet", MUD_COLOURS),
		row("Snaggar", 30, 38, 40, "stilt_hamlet", REED_COLOURS),
		row("Fenwhisk", 25, 38, 40, "stilt_hamlet", REED_COLOURS),
		row("Mistrel", 35, 39, 41, "fogwater_reach", POND_COLOURS),
		row("Lilyshade", 30, 39, 41, "fogwater_reach", POND_COLOURS),
		row("Snaggar", 30, 39, 41, "fogwater_reach", REED_COLOURS),
		row("Skipslick", 25, 39, 41, "fogwater_reach", FROG_COLOURS),
		row("Keelsnap", 25, 39, 41, "fogwater_reach", MUD_COLOURS),
		row("Keelsnap", 30, 40, 42, "sluice_rise", MUD_COLOURS),
		row("Snaggar", 30, 40, 42, "sluice_rise", REED_COLOURS),
		row("Fenwhisk", 30, 40, 42, "sluice_rise", REED_COLOURS),
		row("Mistrel", 25, 40, 42, "sluice_rise", POND_COLOURS),
		row("Lilyshade", 25, 40, 42, "sluice_rise", POND_COLOURS),
		row("Skipslick", 25, 40, 42, "sluice_rise", FROG_COLOURS),
		-- Rustle spot: the sinkhole.
		row("Bogbellow", 35, 40, 41, "fogwater_reach", REED_COLOURS, "sinkhole"),
		row("Bulbroth", 30, 40, 41, "fogwater_reach", MUD_COLOURS, "sinkhole"),
		row("Mistrel", 20, 40, 41, "fogwater_reach", POND_COLOURS, "sinkhole"),
		row("Snaggar", 15, 40, 41, "fogwater_reach", REED_COLOURS, "sinkhole"),
	},
	rustleSpots = {
		{
			id = "sinkhole",
			name = "The Sinkhole",
			area = "fogwater_reach",
			at = 470,
			note = "A ring of reeds around a deep, round hole in the water that bubbles slowly, as if something big is turning over in the mud",
		},
	},
	tamers = { "mr_barnaby", "mr_ysolde", "mr_cuthbert" },
}

local lair: WorldTypes.Lair = {
	id = "mire_lair",
	name = "The Sunken Grove",
	joinsRoute = "mire_route_b",
	joinsAt = 440,
	spurLength = 280,
	arenaSize = 170,
	giant = "mire_sloughback",
	supplyStall = "Grove Stall, at the start of the spur: tonics and Giant Horns",
	shortcutToHub = true,
}

local gate: WorldTypes.Gate = {
	id = "mire_gate",
	name = "The Sluice Gate",
	route = "mire_route_b",
	at = 720,
	battle = "champion_vell",
	badge = { id = "mire_badge", name = "Bulrush Badge" },
	sealedPath = "mire_sealed_path",
	nextBiome = 5,
	recommendedMin = 42,
	recommendedMax = 45,
}

-- Adds the gem-tier twins to a route's open rows (see the note at the top).
local function withGems(route: WorldTypes.Route)
	local share = EconomyConfig.GEM_WILD_SHARE
	local twins: { WorldTypes.SpawnEntry } = {}
	for _, entry in route.spawns do
		if entry.spot == nil and Species[entry.species].biome == 4 then
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

local Mire: WorldTypes.Biome = {
	-- From the Heron Causeway's start (x 2836) east to the world's edge.
	region = { kind = "Box", at = { x = 3668, z = 0 }, size = { 1664, 8000 } },
	id = "mire",
	number = 4,
	name = "Mire",
	element = "Toxic",
	hub = hub,
	routes = { routeA, routeB },
	lair = lair,
	gate = gate,
	levelMin = 32,
	levelMax = 42,
	map = require("../map_data/Mire"),
	-- Plan 13 section 3a: Sedgeholm stands north-east of Saltwick, reached by the Heron Causeway.
	site = { hub = { x = 3100, z = -550 }, base = 0 },
}

return Mire
