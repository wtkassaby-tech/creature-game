--!strict
-- Greenwood's finds (docs/plans/14_FINDS_AND_REWARDS.md section 3a). Data only. Positions are in
-- studs from the centre of Thistledown, each checked by tests/finds.test.luau against the map
-- sheet: on open ground, on one tier, 32 studs from every other prompt and 26 from long grass, and
-- reachable without crossing long grass (the apple nook only through its hidden gap).
--
-- Find ids are permanent (rule 8): never rename, reuse or remove one once shipped.

local WorldTypes = require("../../shared/WorldTypes")

local function at(x: number, z: number): WorldTypes.SheetPoint
	return { x = x, z = z }
end

local springStone: WorldTypes.Keepsake = { id = "spring_stone", name = "Spring-stone" }
local oldAcorn: WorldTypes.Keepsake = { id = "old_acorn", name = "Old acorn" }

local finds: { WorldTypes.Find } = {
	{
		id = "gw_gather_fern",
		biome = 1,
		kind = "Gather",
		name = "Fern clump",
		at = at(-207, 2),
		rewards = { { kind = "Material", material = "Fernfluff", count = 2 } },
	},
	{
		id = "gw_note_bench",
		biome = 1,
		kind = "Note",
		name = "A page on the bench",
		at = at(-333, 13),
		rewards = {},
		text = {
			"The bench under the spray. I wrote my first page here, before I knew how far the road went.",
			"Whoever finds this: the road is long, and kinder than it looks.",
		},
	},
	{
		id = "gw_cache_basket",
		biome = 1,
		kind = "Cache",
		name = "A forgotten picnic basket",
		at = at(-290, 111),
		rewards = { { kind = "Item", item = "Revive", count = 1 } },
	},
	{
		id = "gw_cache_apple",
		biome = 1,
		kind = "Cache",
		name = "The hollow under the apple tree",
		at = at(-396, 67),
		hidden = true,
		rewards = {
			{ kind = "Item", item = "Braided", count = 1 },
			{ kind = "Material", material = "Fernfluff", count = 3 },
		},
	},
	{
		id = "gw_gather_river",
		biome = 1,
		kind = "Gather",
		name = "River fluff",
		at = at(354, 9),
		rewards = { { kind = "Material", material = "Fernfluff", count = 2 } },
	},
	{
		id = "gw_note_heron",
		biome = 1,
		kind = "Note",
		name = "A page by the heron pool",
		at = at(410, 26),
		rewards = {},
		text = {
			"A heron stood in the pool all morning, patient as a stone.",
			"I learned more from it than from any book. Wait, and the world comes to you.",
		},
	},
	{
		id = "gw_note_wood",
		biome = 1,
		kind = "Note",
		name = "A page in the old wood",
		at = at(510, -101),
		rewards = {},
		text = {
			"The old wood hums to itself and remembers every tamer who walked it.",
			"Its giant is not cruel, only large. Be larger in patience.",
		},
	},
	{
		id = "gw_cairn",
		biome = 1,
		kind = "Cairn",
		name = "The old cairn",
		at = at(-296, -4),
		rewards = { { kind = "Material", material = "Fernfluff", count = 3 } },
		keepsake = springStone,
	},
	{
		id = "gw_sighting_burl",
		biome = 1,
		kind = "Sighting",
		name = "The Burl Thicket",
		spot = "burl_thicket",
		rewards = {},
	},
}

local sets: { WorldTypes.JournalSet } = {
	{
		id = "gw_journal",
		biome = 1,
		name = "The Greenwood pages",
		notes = { "gw_note_bench", "gw_note_heron", "gw_note_wood" },
		keepsake = oldAcorn,
	},
}

return { finds = finds, sets = sets }
