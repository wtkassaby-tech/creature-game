--!strict
-- Dust Canyon's finds (docs/plans/14_FINDS_AND_REWARDS.md section 3b). Data only. Positions are in
-- studs from the centre of Kilnrest, each in a room of the rebuilt map sheet: the arroyo shelf,
-- the cairn nook, the arroyo's end, the Spire Garden's bare way round (`garden_bypass`) and the
-- gorge-floor path. tests/finds.test.luau checks them against the sheet, so a room that moves is
-- caught there; moving a find is a change of position only, never of id. The Windward Overlook's
-- cairn waits for that tier (`pending`).
--
-- Find ids are permanent (rule 8): never rename, reuse or remove one once shipped.

local WorldTypes = require("../../shared/WorldTypes")

local function at(x: number, z: number): WorldTypes.SheetPoint
	return { x = x, z = z }
end

local potsherd: WorldTypes.Keepsake = { id = "potsherd", name = "Potsherd" }
local kilnTile: WorldTypes.Keepsake = { id = "kiln_tile", name = "Kiln tile" }

local finds: { WorldTypes.Find } = {
	{
		id = "dc_gather_arroyo",
		biome = 2,
		kind = "Gather",
		name = "Grit seam",
		at = at(40, -400),
		rewards = { { kind = "Material", material = "CanyonGrit", count = 2 } },
	},
	{
		id = "dc_cache_cairn",
		biome = 2,
		kind = "Cache",
		name = "Under the leaning cairn",
		at = at(76, -495),
		hidden = true,
		rewards = { { kind = "Item", item = "Gilded", count = 1 } },
	},
	{
		id = "dc_note_bridge",
		biome = 2,
		kind = "Note",
		name = "A page at the broken bridge",
		at = at(135, -540),
		rewards = {},
		text = {
			"The bridge was already cut when I got here. Across the gap, something glints violet.",
			"I made camp, burned my hands on my own fire, and turned back.",
		},
	},
	{
		id = "dc_cache_potter",
		biome = 2,
		kind = "Cache",
		name = "A potter's cache",
		at = at(522, -146),
		rewards = {
			{ kind = "Item", item = "GreatTonic", count = 1 },
			{ kind = "Material", material = "CanyonGrit", count = 3 },
		},
	},
	{
		id = "dc_note_spire",
		biome = 2,
		kind = "Note",
		name = "A page among the spires",
		at = at(568, -142),
		rewards = {},
		text = {
			"A potter left her wares in the spires, each cup stamped with a small sun.",
			"I took one, and left a coin. It felt right.",
		},
	},
	{
		id = "dc_gather_gorge",
		biome = 2,
		kind = "Gather",
		name = "Gorge seam",
		at = at(317, 44),
		rewards = { { kind = "Material", material = "CanyonGrit", count = 2 } },
	},
	{
		id = "dc_note_gorge",
		biome = 2,
		kind = "Note",
		name = "A page on the rim",
		at = at(215, 57),
		rewards = {},
		text = {
			"From the rim the gorge floor is all shadow, and the wind speaks in it.",
			"If you hear your own name down there, keep walking.",
		},
	},
	{
		id = "dc_cairn_overlook",
		biome = 2,
		kind = "Cairn",
		name = "The Windward cairn",
		rewards = { { kind = "Material", material = "CanyonGrit", count = 3 } },
		keepsake = potsherd,
		pending = "Waits for the Windward Overlook's tier in the Dust Canyon rebuild",
	},
	{
		id = "dc_sighting_echo",
		biome = 2,
		kind = "Sighting",
		name = "The Echo Notch",
		spot = "echo_notch",
		rewards = {},
	},
}

local sets: { WorldTypes.JournalSet } = {
	{
		id = "dc_journal",
		biome = 2,
		name = "The Dust Canyon pages",
		notes = { "dc_note_bridge", "dc_note_spire", "dc_note_gorge" },
		keepsake = kilnTile,
	},
}

return { finds = finds, sets = sets }
