--!strict
-- The far scenery that frames the launch three (docs/plans/13_WORLD_DESIGN.md sections 3c, 6a and
-- 10): the Crown and its cloud halo, the Western Highlands, the Northern Range and the South Sea's
-- islands and far coast. Few, large, never reached: each stands outside every biome's walkable
-- space and past its fill, to be seen over the walls. Piece budgets are in FarSceneryConfig; a test
-- keeps this list inside them. Data only, apart from the Crown's ring, which is laid out by angle.
--
-- Colours are the piece's own; the builder fades them toward the haze by layer. See WorldTypes
-- (FarScenery) for the fields.

local WorldTypes = require("../../shared/WorldTypes")

local list: { WorldTypes.FarScenery } = {}

local function add(piece: WorldTypes.FarScenery)
	table.insert(list, piece)
end

-- The Crown ----------------------------------------------------------------------------------
-- A ring of nine rounded mountains round (1350, -1700) at radius 850 (the plan's 700 to 950 band,
-- centre line 825, pushed out a little to clear Dust Canyon), crests 250 to 320 high, and a cloud
-- halo of six flat puffs above them at y 450 to 520. A piece's front faces outward, so its width
-- runs along the ring: yaw = angle + 90.
local CROWN = { x = 1350, z = -1700 }
local CROWN_RADIUS = 850
local CROWN_ROCK = { 150, 138, 172 } -- soft violet-grey
local CROWN_HEIGHTS: { number } = { 290, 320, 300, 260, 310, 250, 300, 280, 270 }

local function onRing(degrees: number, radius: number): WorldTypes.WorldPoint
	local turn = math.rad(degrees)
	return { x = CROWN.x + math.cos(turn) * radius, z = CROWN.z + math.sin(turn) * radius }
end

for index = 1, 9 do
	local degrees = 10 + 40 * (index - 1) -- 90 is due south of the centre, the near side
	local tall = CROWN_HEIGHTS[index]
	add({
		id = `crown_{index}`,
		layer = "crown",
		model = "SnowPeak",
		at = onRing(degrees, CROWN_RADIUS),
		base = 0,
		scale = 1,
		faces = degrees + 90,
		-- Lower than their crest numbers: from Saltwick the nearest peak is only about 940 studs
		-- off, and at full height the range loomed like a hill next door (Studio, 23 Nov).
		size = { 420, tall * 0.68, 190 },
		colour = CROWN_ROCK,
	})
	-- (The painted SnowPeak carries its own snow: no separate caps.)
end

-- (No cloud halo: six flat discs over the Crown read as flying saucers from the towns,
-- Studio, 23 November 2026. The sky's own clouds sit over the peaks instead.)

-- The Western Highlands ------------------------------------------------------------------------
-- Wooded hills behind Greenwood's plateau, taller and hazier further out, and the Lantern Spire
-- (docs section 6a): a crooked stone spire, which is a painted RockSpire stretched tall.
add({
	id = "highlands_near",
	layer = "west",
	model = "WoodedHill",
	at = { x = -950, z = 100 },
	base = -2,
	scale = 1,
	faces = 90,
	size = { 700, 150, 800 },
	colour = { 104, 148, 98 },
})
add({
	id = "highlands_mid",
	layer = "west",
	model = "WoodedHill",
	at = { x = -1000, z = -700 },
	base = -2,
	scale = 1,
	faces = 90,
	size = { 700, 230, 900 },
	colour = { 96, 138, 104 },
})
add({
	id = "highlands_far",
	layer = "west",
	model = "WoodedHill",
	at = { x = -1600, z = -1500 },
	base = -2,
	scale = 1,
	faces = 90,
	size = { 900, 330, 1100 },
	colour = { 112, 130, 120 },
})
add({
	id = "highlands_back",
	layer = "west",
	model = "WoodedHill",
	at = { x = -1500, z = -2500 },
	base = -2,
	scale = 1,
	faces = 90,
	size = { 900, 380, 1100 },
	colour = { 120, 124, 136 },
})
add({
	id = "lantern_spire",
	layer = "west",
	model = "RockSpire",
	at = { x = -500, z = -1900 },
	base = 0,
	scale = 1,
	faces = 0,
	size = { 70, 260, 70 },
	colour = { 150, 118, 180 },
})

-- The Northern Range ---------------------------------------------------------------------------
-- Whitefang (3800, -2150, 420 tall, a pale cap), Old Smoulder (1350, -3350: a broad cone, rim 220,
-- plume to 600) and the Anvil (100, -3300, 480, under a flat-topped storm cloud), with one far
-- ridge. They are far and hazy: from the launch biomes they show over the Crown's shoulders or
-- from high ground (the tiers, the Stair Gate).
add({
	id = "whitefang",
	layer = "north",
	model = "SnowPeak",
	at = { x = 3800, z = -2150 },
	base = 0,
	scale = 1,
	faces = 0,
	size = { 700, 330, 600 },
	colour = { 150, 164, 188 },
})
add({
	id = "old_smoulder",
	layer = "north",
	model = "Lump",
	at = { x = 1350, z = -3350 },
	base = 0,
	scale = 1,
	faces = 0,
	size = { 1100, 220, 900 },
	colour = { 150, 112, 104 },
})
add({
	id = "smoulder_plume_low",
	layer = "north",
	model = "Puff",
	at = { x = 1350, z = -3350 },
	base = 240,
	scale = 1,
	faces = 0,
	size = { 190, 260, 190 },
	colour = { 132, 126, 128 },
})
add({
	id = "smoulder_plume_high",
	layer = "north",
	model = "Puff",
	at = { x = 1380, z = -3350 },
	base = 480,
	scale = 1,
	faces = 0,
	size = { 280, 120, 250 },
	colour = { 148, 142, 144 },
})
add({
	id = "anvil",
	layer = "north",
	model = "SnowPeak",
	at = { x = 100, z = -3300 },
	base = 0,
	scale = 1,
	faces = 0,
	size = { 480, 420, 420 },
	colour = { 138, 130, 158 },
})
add({
	id = "anvil_storm",
	layer = "north",
	model = "Puff",
	at = { x = 100, z = -3300 },
	base = 420,
	scale = 1,
	faces = 0,
	size = { 700, 60, 540 },
	colour = { 96, 94, 116 },
})
add({
	id = "northern_ridge",
	layer = "north",
	model = "SnowPeak",
	at = { x = 2300, z = -3800 },
	base = 0,
	scale = 1,
	faces = 0,
	size = { 1400, 380, 500 },
	colour = { 150, 156, 178 },
})

-- The South Sea ---------------------------------------------------------------------------------
-- Seen from Tide Flats, looking south over the water: Brine Isle and Palm Key as low silhouettes
-- (their wading beaches are for a later step), the three Brine Stacks (painted SeaRocks) and the
-- far coastline on the horizon at z +3000.
add({
	id = "brine_isle",
	layer = "sea",
	model = "Lump",
	at = { x = 1300, z = 800 },
	base = -2,
	scale = 1,
	faces = 0,
	size = { 260, 40, 220 },
	colour = { 188, 176, 130 },
})
add({
	id = "brine_isle_hill",
	layer = "sea",
	model = "WoodedHill",
	at = { x = 1290, z = 795 },
	base = 30,
	scale = 1,
	faces = 0,
	size = { 120, 50, 100 },
	colour = { 96, 144, 96 },
})
add({
	id = "palm_key",
	layer = "sea",
	model = "Lump",
	at = { x = 2500, z = 820 },
	base = -2,
	scale = 1,
	faces = 0,
	size = { 220, 22, 190 },
	colour = { 228, 208, 152 },
})
add({
	id = "palm_key_grove",
	layer = "sea",
	model = "WoodedHill",
	at = { x = 2495, z = 820 },
	base = 18,
	scale = 1,
	faces = 0,
	size = { 80, 36, 70 },
	colour = { 88, 156, 96 },
})
add({
	id = "brine_stack_1",
	layer = "sea",
	model = "SeaRocks",
	at = { x = 1650, z = 650 },
	base = -2,
	scale = 1,
	faces = 20,
	size = { 62, 80, 62 },
	colour = { 255, 255, 255 },
})
add({
	id = "brine_stack_2",
	layer = "sea",
	model = "SeaRocks",
	at = { x = 1725, z = 690 },
	base = -2,
	scale = 1,
	faces = 150,
	size = { 46, 60, 46 },
	colour = { 255, 255, 255 },
})
add({
	id = "brine_stack_3",
	layer = "sea",
	model = "SeaRocks",
	at = { x = 1590, z = 705 },
	base = -2,
	scale = 1,
	faces = 260,
	size = { 40, 52, 40 },
	colour = { 255, 255, 255 },
})
add({
	id = "far_coast_west",
	layer = "sea",
	model = "Lump",
	at = { x = 700, z = 3000 },
	base = -2,
	scale = 1,
	faces = 0,
	size = { 2000, 70, 500 },
	colour = { 150, 172, 168 },
})
add({
	id = "far_coast_east",
	layer = "sea",
	model = "Lump",
	at = { x = 2700, z = 3050 },
	base = -2,
	scale = 1,
	faces = 0,
	size = { 2000, 110, 500 },
	colour = { 146, 166, 170 },
})

return list
