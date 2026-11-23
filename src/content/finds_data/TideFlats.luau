--!strict
-- Tide Flats' finds, with Gull Cove's (docs/plans/14_FINDS_AND_REWARDS.md section 3c). Data only.
-- This biome's map is being rebuilt, so positions are points down a route (`route`, `along`,
-- `side`), which stay put when the rooms around them change.
--
-- Gull Cove is not in the map yet (plan 13, side area b): its finds are defined here so their ids
-- are permanent, and are `pending` (the server treats them as shut) until the cove is built. Its
-- sighting spot, `cove_pool`, is a rustle spot the cove's build adds, with the cove's own table.
--
-- Find ids are permanent (rule 8): never rename, reuse or remove one once shipped.

local WorldTypes = require("../../shared/WorldTypes")

local gullFeather: WorldTypes.Keepsake = { id = "gull_feather", name = "Gull feather" }
local seaGlass: WorldTypes.Keepsake = { id = "sea_glass", name = "Sea glass" }

local COVE = "Gull Cove is not built yet (plan 13, side area b)"

local finds: { WorldTypes.Find } = {
	{
		id = "tf_gather_rockpool",
		biome = 3,
		kind = "Gather",
		name = "Shell pools",
		route = "tide_flats_route_a",
		along = 200,
		side = 0,
		rewards = { { kind = "Material", material = "BrineShell", count = 2 } },
	},
	{
		id = "tf_cache_plank",
		biome = 3,
		kind = "Cache",
		name = "A driftwood crate",
		route = "tide_flats_route_a",
		along = 488,
		side = 0,
		rewards = {
			{ kind = "Material", material = "BrineShell", count = 4 },
			{ kind = "Item", item = "Revive", count = 1 },
		},
	},
	{
		id = "tf_cache_ship",
		biome = 3,
		kind = "Cache",
		name = "The ship's locker",
		route = "tide_flats_route_b",
		along = 365,
		side = 0,
		rewards = { { kind = "Item", item = "GreatTonic", count = 2 } },
	},
	{
		id = "tf_note_ship",
		biome = 3,
		kind = "Note",
		name = "A page in the ship's ribs",
		route = "tide_flats_route_b",
		along = 440,
		side = 0,
		rewards = {},
		text = {
			"The ship's lamp failed the night the old light went out. Nobody agrees why.",
			"The ribs still hold the cold of that night.",
		},
	},
	{
		id = "tf_note_outcrop",
		biome = 3,
		kind = "Note",
		name = "A page by the cave outcrop",
		route = "tide_flats_route_b",
		along = 520,
		side = 0,
		rewards = {},
		text = {
			"A faint green glow inside the cave, steady as a held breath.",
			"I did not go in. Some doors want a better reason than curiosity.",
		},
	},
	{
		id = "tf_note_cove",
		biome = 3,
		kind = "Note",
		name = "A page on the cove bench",
		rewards = {},
		text = {
			"Gulls have the cove now. They watch me write and offer no opinions.",
			"One more island each way, and the ring is closed. Not yet.",
		},
		pending = COVE,
	},
	{
		id = "tf_gather_midden",
		biome = 3,
		kind = "Gather",
		name = "Shell midden",
		rewards = { { kind = "Material", material = "BrineShell", count = 2 } },
		pending = COVE,
	},
	{
		id = "tf_cache_crevice",
		biome = 3,
		kind = "Cache",
		name = "A crevice in a sea stack",
		hidden = true,
		rewards = { { kind = "Item", item = "Bait", count = 1 } },
		pending = COVE,
	},
	{
		id = "tf_cairn_cove",
		biome = 3,
		kind = "Cairn",
		name = "The cove point cairn",
		rewards = { { kind = "Material", material = "BrineShell", count = 4 } },
		keepsake = gullFeather,
		pending = COVE,
	},
	{
		id = "tf_sighting_cove",
		biome = 3,
		kind = "Sighting",
		name = "The cove's rock pool",
		spot = "cove_pool",
		rewards = {},
		pending = COVE,
	},
}

local sets: { WorldTypes.JournalSet } = {
	{
		id = "tf_journal",
		biome = 3,
		name = "The Tide Flats pages",
		notes = { "tf_note_ship", "tf_note_outcrop", "tf_note_cove" },
		keepsake = seaGlass,
	},
}

return { finds = finds, sets = sets }
