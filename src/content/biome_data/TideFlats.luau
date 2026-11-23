--!strict
-- Tide Flats (biome 3): one hub town, two routes, a giant's lair on a spur and the gate. It follows
-- Dust Canyon's layout (docs/content/DUST_CANYON_WORLD.md). Sizes in studs. Route A is the first
-- outing (levels 22 to 27) and Route B climbs to the gate (levels 27 to 32). Distances along a route
-- are measured from the hub, so levels rise with distance. Wild levels stay inside the biome's level
-- band (EconomyConfig.LEVEL_BANDS, 22 to 32) and the cap after two badges (Xp.levelCap(2), 35).
--
-- Where each species lives (every one appears; the two uncommon ones only at rustle spots):
--   Glissot, Cocklemole, Runnelfin: the wrack beach, the shelf and the kelp shallows. Gulpmaw: the shelf onward.
--   Clapshell, Moatkeep: the causeway, the boardwalk and the steps. Gulpmaw, Runnelfin: the whole of Route B.
--   Hullock (uncommon): the Anemone Pools (rock pools) and the Tide Cave.
--   Lanternell (uncommon): the Kelp Bed and the Tide Cave, where a lantern head is at home in the dark.
--   Duneskit and Wadibuck (Dust Canyon) stray down at the top of the wrack beach, rarely.
-- Bait (the biome's new idea) is used at a rustle spot, so each of the three is a place you would
-- fish: a rock pool, a kelp bed, a sea cave. The weights are [Defaults] to tune from playtests. The
-- rare-colour chance reuses the breeding rule's rare mutation chance, so one number keeps the two in step.
--
-- Gem tier ("Amber"): as in Dust Canyon, every open row of a Tide Flats species has a gem-tier twin
-- at the bottom of its route's table, weighted so that EconomyConfig.GEM_WILD_SHARE of open
-- encounters in each stretch are gem-tier. Rustle spots give no gem-tier creatures from the table:
-- their uncommon species are the prize there (a bait's own gem-tier chance is the economy's).

local BreedConfig = require("../../config/BreedConfig")
local EconomyConfig = require("../../config/EconomyConfig")
local Species = require("../Species")
local WorldTypes = require("../../shared/WorldTypes")

local RARE = BreedConfig.RARE_MUTATION_CHANCE

-- A Dust Canyon species keeps the colour list its Dust Canyon rows use, so a gifted one wears the same colour.
local SAND_COLOURS: { string } = { "Sand", "Bark" }
local WATER_COLOURS: { string } = { "Sand", "Moss" }
-- Tide Flats' own creatures.
local SHELL_COLOURS: { string } = { "Sand", "Bark" }
local TIDE_COLOURS: { string } = { "Moss", "Sand" }
local WEED_COLOURS: { string } = { "Moss", "Bark" }

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
	id = "tide_flats_hub",
	name = "Saltwick",
	size = 300,
	landmark = "The old white lighthouse on the headland, seen from the quay",
	buildings = {
		{
			id = "tarn_chandlery",
			name = "Tarn's Chandlery",
			role = "Shop",
			npc = "odalys_tarn",
		},
		{ id = "warm_pool", name = "The Warm Pool", role = "Healer" },
		{ id = "brood_shallows", name = "The Brood Shallows", role = "Breeder" },
		{ id = "tally_board", name = "The Tally Board", role = "Quests" },
		{
			id = "ferry_steps",
			name = "The Ferry Steps",
			role = "Teleport",
			npc = "bastian_wake",
		},
		{ id = "breaker_ring", name = "The Breaker Ring", role = "Circuit" },
		{ id = "lamp_tower", name = "The Lamp Tower", role = "Lookout" },
	},
}

local routeA: WorldTypes.Route = {
	id = "tide_flats_route_a",
	name = "Route A: Strandline Path",
	length = 500,
	width = "40 to 60, opening to 120 on the kelp shallows",
	note = "Short and open. A strand of dark wrack and shells, then a shelf of rock pools, then shallow water over kelp; the white lighthouse stays on the skyline",
	areas = {
		{
			id = "wrack_beach",
			name = "Wrack Beach",
			from = 0,
			to = 160,
			minLevel = 22,
			maxLevel = 23,
			note = "A wide beach just outside Saltwick, strewn with dark wrack, driftwood and crushed shells",
		},
		{
			id = "rockpool_shelf",
			name = "Rockpool Shelf",
			from = 160,
			to = 330,
			minLevel = 23,
			maxLevel = 25,
			note = "A flat shelf of black rock pitted with pools, each a small world of weed and anemones",
		},
		{
			id = "kelp_shallows",
			name = "Kelp Shallows",
			from = 330,
			to = 500,
			minLevel = 25,
			maxLevel = 27,
			note = "Knee-deep clear water over sand, with long ribbons of kelp swaying; the trail ends at a plank bridge to the sandbar",
		},
	},
	spawns = {
		row("Glissot", 45, 22, 23, "wrack_beach", TIDE_COLOURS),
		row("Cocklemole", 45, 22, 23, "wrack_beach", SHELL_COLOURS),
		row("Runnelfin", 30, 22, 23, "wrack_beach", TIDE_COLOURS),
		-- Strays from Dust Canyon, near the entrance only.
		row("Duneskit", 8, 22, 23, "wrack_beach", SAND_COLOURS),
		row("Wadibuck", 8, 22, 23, "wrack_beach", WATER_COLOURS),
		row("Gulpmaw", 45, 23, 25, "rockpool_shelf", WEED_COLOURS),
		row("Cocklemole", 35, 23, 25, "rockpool_shelf", SHELL_COLOURS),
		row("Glissot", 30, 23, 25, "rockpool_shelf", TIDE_COLOURS),
		row("Clapshell", 25, 23, 25, "rockpool_shelf", SHELL_COLOURS),
		row("Runnelfin", 40, 25, 27, "kelp_shallows", TIDE_COLOURS),
		row("Gulpmaw", 35, 25, 27, "kelp_shallows", WEED_COLOURS),
		row("Glissot", 30, 25, 27, "kelp_shallows", TIDE_COLOURS),
		row("Moatkeep", 30, 25, 27, "kelp_shallows", SHELL_COLOURS),
		-- Rustle spot: the anemone pools.
		row("Hullock", 45, 24, 25, "rockpool_shelf", WEED_COLOURS, "anemone_pools"),
		row("Gulpmaw", 30, 24, 25, "rockpool_shelf", WEED_COLOURS, "anemone_pools"),
		row("Cocklemole", 25, 24, 25, "rockpool_shelf", SHELL_COLOURS, "anemone_pools"),
		-- Rustle spot: the kelp bed.
		row("Lanternell", 45, 26, 27, "kelp_shallows", TIDE_COLOURS, "kelp_bed"),
		row("Glissot", 30, 26, 27, "kelp_shallows", TIDE_COLOURS, "kelp_bed"),
		row("Runnelfin", 25, 26, 27, "kelp_shallows", TIDE_COLOURS, "kelp_bed"),
	},
	rustleSpots = {
		{
			id = "anemone_pools",
			name = "The Anemone Pools",
			area = "rockpool_shelf",
			at = 260,
			note = "A cluster of deep pools ringed with anemones that snap shut and ripple when something heavy wades through",
		},
		{
			id = "kelp_bed",
			name = "The Kelp Bed",
			area = "kelp_shallows",
			at = 430,
			note = "A thick stand of kelp that thrashes and glows faintly green when something large slides between the stalks",
		},
	},
	tamers = { "tf_nell", "tf_merrin" },
}

local routeB: WorldTypes.Route = {
	id = "tide_flats_route_b",
	name = "Route B: Breakwater Road",
	length = 720,
	width = "40 to 60, opening to 120 at the wreck",
	note = "Longer and wetter. A sandbar causeway, a mudflat boardwalk, a stranded wreck and a stair of tide-worn steps to the Breakwater Gate; the lair spur leaves it at the wreck",
	areas = {
		{
			id = "sandbar_causeway",
			name = "Sandbar Causeway",
			from = 0,
			to = 180,
			minLevel = 27,
			maxLevel = 28,
			note = "A raised spit of pale sand between two stretches of shining water, with a rope rail on one side",
		},
		{
			id = "mudflat_boardwalk",
			name = "Mudflat Boardwalk",
			from = 180,
			to = 360,
			minLevel = 28,
			maxLevel = 30,
			note = "A weathered plank walk on stilts across a mirror of grey mud, gulls everywhere, crab holes beneath",
		},
		{
			id = "shipwreck_reach",
			name = "Shipwreck Reach",
			from = 360,
			to = 540,
			minLevel = 29,
			maxLevel = 31,
			note = "A broad bay where the ribs of a huge old ship stand out of the sand; the lair spur forks off near its middle, and a sea cave opens in the cliff",
		},
		{
			id = "tideward_steps",
			name = "Tideward Steps",
			from = 540,
			to = 720,
			minLevel = 30,
			maxLevel = 32,
			note = "Broad, green-slick stone steps climbing the breakwater to the Breakwater Gate and its teal-and-white banner",
		},
	},
	spawns = {
		row("Moatkeep", 40, 27, 28, "sandbar_causeway", SHELL_COLOURS),
		row("Glissot", 35, 27, 28, "sandbar_causeway", TIDE_COLOURS),
		row("Clapshell", 30, 27, 28, "sandbar_causeway", SHELL_COLOURS),
		row("Cocklemole", 30, 27, 28, "sandbar_causeway", SHELL_COLOURS),
		row("Gulpmaw", 35, 28, 30, "mudflat_boardwalk", WEED_COLOURS),
		row("Runnelfin", 35, 28, 30, "mudflat_boardwalk", TIDE_COLOURS),
		row("Moatkeep", 30, 28, 30, "mudflat_boardwalk", SHELL_COLOURS),
		row("Clapshell", 30, 28, 30, "mudflat_boardwalk", SHELL_COLOURS),
		row("Cocklemole", 25, 28, 30, "mudflat_boardwalk", SHELL_COLOURS),
		row("Clapshell", 35, 29, 31, "shipwreck_reach", SHELL_COLOURS),
		row("Gulpmaw", 30, 29, 31, "shipwreck_reach", WEED_COLOURS),
		row("Glissot", 30, 29, 31, "shipwreck_reach", TIDE_COLOURS),
		row("Moatkeep", 25, 29, 31, "shipwreck_reach", SHELL_COLOURS),
		row("Runnelfin", 25, 29, 31, "shipwreck_reach", TIDE_COLOURS),
		row("Moatkeep", 30, 30, 32, "tideward_steps", SHELL_COLOURS),
		row("Clapshell", 30, 30, 32, "tideward_steps", SHELL_COLOURS),
		row("Cocklemole", 30, 30, 32, "tideward_steps", SHELL_COLOURS),
		row("Glissot", 25, 30, 32, "tideward_steps", TIDE_COLOURS),
		row("Runnelfin", 25, 30, 32, "tideward_steps", TIDE_COLOURS),
		row("Gulpmaw", 25, 30, 32, "tideward_steps", WEED_COLOURS),
		-- Rustle spot: the tide cave.
		row("Lanternell", 35, 30, 31, "shipwreck_reach", TIDE_COLOURS, "tide_cave"),
		row("Hullock", 30, 30, 31, "shipwreck_reach", WEED_COLOURS, "tide_cave"),
		row("Moatkeep", 20, 30, 31, "shipwreck_reach", SHELL_COLOURS, "tide_cave"),
		row("Clapshell", 15, 30, 31, "shipwreck_reach", SHELL_COLOURS, "tide_cave"),
	},
	rustleSpots = {
		{
			id = "tide_cave",
			name = "The Tide Cave",
			area = "shipwreck_reach",
			at = 470,
			note = "A sea cave in the cliff, dark and dripping, where a green glow drifts at the back and the echo of something big shifting comes out",
		},
	},
	tamers = { "tf_orrin", "tf_isaura", "tf_ludo" },
}

local lair: WorldTypes.Lair = {
	id = "tide_flats_lair",
	name = "Carrackon's Wreck",
	joinsRoute = "tide_flats_route_b",
	joinsAt = 440,
	spurLength = 280,
	arenaSize = 170,
	giant = "tide_flats_carrackon",
	supplyStall = "Wreck Stall, at the start of the spur: tonics and Giant Horns",
	shortcutToHub = true,
}

local gate: WorldTypes.Gate = {
	id = "tide_flats_gate",
	name = "The Breakwater Gate",
	route = "tide_flats_route_b",
	at = 720,
	battle = "rival_breakwater",
	badge = { id = "tide_flats_badge", name = "Breaker Badge" },
	sealedPath = "tide_flats_sealed_path",
	nextBiome = 4,
	recommendedMin = 32,
	recommendedMax = 35,
}

-- Adds the gem-tier twins to a route's open rows (see the note at the top).
local function withGems(route: WorldTypes.Route)
	local share = EconomyConfig.GEM_WILD_SHARE
	local twins: { WorldTypes.SpawnEntry } = {}
	for _, entry in route.spawns do
		if entry.spot == nil and Species[entry.species].biome == 3 then
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

local TideFlats: WorldTypes.Biome = {
	id = "tide_flats",
	number = 3,
	name = "Tide Flats",
	element = "Water",
	hub = hub,
	routes = { routeA, routeB },
	lair = lair,
	gate = gate,
	levelMin = 22,
	levelMax = 32,
	map = require("../map_data/TideFlats"),
	-- From the Stair Gate swap (x 1793) east to the edge of the known world (x 4500).
	region = { kind = "Box", at = { x = 3146.5, z = 0 }, size = { 2707, 8000 } },
}

return TideFlats
