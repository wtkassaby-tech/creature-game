--!strict
-- How designed Dust Canyon looks: cliff walls and boulder banks, the gorge floor, lanes, fences,
-- signs, lamps, scrub, the houses of Kilnrest and the Redstack on the skyline. Studs from the
-- centre of Kilnrest; north is -z; facings are degrees clockwise from north. Data only, from
-- docs/plans/09_DUST_CANYON_MAP.md section 3d. The server's position checks never read this file:
-- it only dresses the test map (src/server/World).

local WorldTypes = require("../../shared/WorldTypes")

local function p(x: number, z: number): WorldTypes.SheetPoint
	return { x = x, z = z }
end

-- Colours (plan section 3d).
local PATH: WorldTypes.Colour = { 226, 200, 160 } -- side paths
local TERRACOTTA: WorldTypes.Colour = { 206, 128, 96 } -- the main streets
local DRY_GRASS_GROUND: WorldTypes.Colour = { 164, 140, 84 } -- under the long grass

local function lane(
	points: { WorldTypes.SheetPoint },
	width: number,
	colour: WorldTypes.Colour
): WorldTypes.DressLane
	return { points = points, width = width, colour = colour }
end

local function tree(x: number, z: number, model: string?, scale: number?): WorldTypes.DressTree
	return { at = p(x, z), model = model or "ScrubBush", scale = scale }
end

local function edge(left: WorldTypes.EdgeStyle, right: WorldTypes.EdgeStyle): WorldTypes.DressEdge
	return { left = left, right = right }
end

local function dry(): WorldTypes.GrassLook
	return { model = "DryTuft", under = DRY_GRASS_GROUND }
end

local function wall(
	points: { WorldTypes.SheetPoint },
	style: WorldTypes.EdgeStyle,
	tall: number
): WorldTypes.DressWall
	return { points = points, style = style, tall = tall }
end

local function house(
	x: number,
	z: number,
	faces: number,
	model: string,
	width: number,
	depth: number,
	tall: number
): WorldTypes.DressHouse
	return { at = p(x, z), faces = faces, model = model, width = width, depth = depth, tall = tall }
end

local DustCanyonDressing: WorldTypes.DressingSheet = {
	roomEdge = "Boulders", -- pockets and dead ends are ringed with boulders, not hedges
	fieldGround = { 214, 172, 124 },
	ground = {
		{ area = "pebble_wash", colour = { 214, 204, 182 } },
		{ area = "tumbleweed_flats", colour = { 226, 196, 140 } },
		{ area = "hollow_arroyo", colour = { 196, 140, 100 } },
		{ area = "redstone_steps", colour = { 190, 110, 84 } },
		{ area = "sunbaked_rim", colour = { 214, 150, 104 } },
		{ area = "spire_garden", colour = { 206, 160, 120 } },
		{ area = "stair_approach", colour = { 200, 184, 160 } },
	},
	townGround = { 232, 196, 150 },
	laneColour = { 232, 206, 160 },
	laneSurfaces = {
		-- The Redstone Steps in red flagstone, and the stair road in stone.
		{ route = "dust_canyon_route_b", from = 0, to = 170, colour = { 184, 96, 72 } },
		{ route = "dust_canyon_route_b", from = 520, to = 680, colour = { 196, 186, 170 } },
	},
	laneWidth = 14,

	lanes = {
		lane({ p(-150, 0), p(-28, 0) }, 16, TERRACOTTA), -- Kiln Street
		lane({ p(10, -27), p(20, -150) }, 10, PATH), -- Wash Lane
		lane({ p(24, 16), p(80, 32), p(150, 40) }, 14, TERRACOTTA), -- East Road
		lane({ p(28, -4), p(50, -6) }, 8, PATH), -- the Trading Post
		lane({ p(-64, 8), p(-64, 28) }, 8, PATH), -- the Seep House
		lane({ p(-50, -8), p(-68.7, -34.7) }, 8, PATH), -- the Waystation
		lane({ p(-18, -22), p(-24, -40) }, 8, PATH), -- the Notice Wall
		lane({ p(52, 24), p(60.7, 60.7) }, 8, PATH), -- the Cradle Kiln
		lane({ p(0, 28), p(0, 74) }, 8, PATH), -- the Dust Ring
		lane({ p(16.7, -110), p(88.7, -84.7) }, 8, PATH), -- the Overlook
		lane({ p(-110, -8), p(-110, -98) }, 8, PATH), -- Cave Row lane
		lane({ p(-136, -98), p(-50, -98) }, 8, PATH), -- Cave Row
		-- The Westcut road, joining Greenwood's sealed road, which already reaches -180.
		lane({ p(-180, 0), p(-150, 0) }, 14, { 186, 180, 168 }),
		-- The shut winch track from the shelf to the gate by the Overlook, rusty and half buried.
		-- Last, as the shortcut always is.
		lane({
			p(497, -318),
			p(420, -280),
			p(330, -222),
			p(180, -168),
			p(130, -170),
			p(130, -150),
			p(112, -118),
		}, 8, { 150, 120, 96 }),
	},
	footpaths = {},
	stones = {},
	-- Sundial Square: terracotta flagstones with a darker kerb, the well at its heart.
	plaza = {
		at = p(0, 0),
		size = 56,
		rim = 60,
		colour = { 200, 112, 82 },
		rimColour = { 150, 84, 60 },
	},
	well = p(0, 0),

	water = {},
	pools = {
		{ at = p(-92, 30), radius = 6, colour = { 110, 182, 214 } }, -- the Seep
	},
	flats = {
		-- The gorge floor in shadow, beyond the rim's lip.
		{ from = p(250, -14), to = p(560, 80), colour = { 152, 96, 74 }, water = false },
		-- The dry fall beyond Route A's end.
		{ from = p(96, -604), to = p(190, -552), colour = { 110, 72, 58 }, water = false },
	},

	arches = {
		{
			at = p(-142, 0),
			faces = 270,
			outside = "Kilnrest",
			inside = "Westcut · to Greenwood",
			model = "CanyonArch",
		},
		{
			at = p(20, -142),
			faces = 5,
			outside = "Kilnrest",
			inside = "Route A · Dry Wash Trail",
			model = "CanyonArch",
		},
		{
			at = p(142, 40),
			faces = 84,
			outside = "Kilnrest",
			inside = "Mesa Road · Stair Gate",
			model = "CanyonArch",
		},
	},
	-- Each signpost's arrow board points along its facing.
	signs = {
		{ at = p(-128, -14), faces = 90, lines = { "Sundial Square · Rook's Trading Post →" } },
		{
			at = p(-6, -36),
			faces = 0,
			lines = { "↑ Route A · Dry Wash Trail", "↑ Windward Overlook" },
		},
		{
			at = p(40, 8),
			faces = 84,
			lines = { "Mesa Road · Stair Gate →", "↓ Cradle Kiln · Dust Ring" },
		},
		{ at = p(118, -140), faces = 0, lines = { "Mesa winch track. Shut." } },
		{ at = p(0, -192), faces = 64, lines = { "Dry grass:", "wild creatures hide here" } },
		{ at = p(464, -77), faces = 13, lines = { "Mesalith's Shelf · Shelf Stall" } },
		{ at = p(666, -115), faces = 90, lines = { "The Stair Gate", "badge challenge" } },
		{ at = p(128, -538), faces = 29, lines = { "Rope bridge down.", "No way across." } },
		-- In the Westcut, seen coming from Greenwood.
		{ at = p(-200, -14), faces = 90, lines = { "Kilnrest →" } },
	},
	-- Lantern posts: Kiln Street, the square, East Road, Wash Lane, the arches and the stair road.
	lamps = {
		p(-120, -11),
		p(-90, 11),
		p(-40, -11),
		p(-28, -16),
		p(22, -24),
		p(-22, 22),
		p(-12, 32),
		p(60, 16),
		p(112, 47),
		p(4, -60),
		p(25, -100),
		p(-142, -11),
		p(-142, 11),
		p(9, -142),
		p(31, -142),
		p(142, 29),
		p(142, 51),
		p(728, -108),
		p(760, -92),
	},
	-- Clay planters by the doors and round the square.
	beds = {
		p(44, -16),
		p(44, 4),
		p(-72, 26),
		p(-56, 26),
		p(-11.6, -32),
		p(-11.6, 32),
		p(11.6, 32),
		p(70, 52),
		p(55, 66.4),
	},

	trees = {
		-- Scrub at the west cliff foot.
		tree(-140, -60),
		tree(-136, -50),
		tree(-142, -42),
		-- The north cliff foot.
		tree(40, -141),
		tree(44, -133),
		tree(36, -134),
		-- Behind the Overlook.
		tree(140, -110),
		tree(134, -100),
		tree(142, -92),
		-- South-west.
		tree(-140, 86),
		tree(-134, 94),
		tree(-142, 100),
		-- South.
		tree(30, 140),
		tree(38, 133),
		tree(46, 140),
		-- East.
		tree(140, 64),
		tree(134, 72),
		tree(142, 80),
		-- Reeds round the Seep.
		tree(-99, 35, "Reeds"),
		tree(-85, 36, "Reeds"),
		tree(-92, 39, "Reeds"),
	},
	rows = {
		{ from = p(-140, 141), to = p(-76, 141), step = 16, model = "ScrubBush" },
		{ from = p(60, 141), to = p(140, 141), step = 16, model = "ScrubBush" },
	},

	fences = {
		-- The shut winch gate in the north cliff.
		{ points = { p(124, -150), p(136, -150) }, style = "Gate", across = true },
		-- The broken rope bridge across the end of Route A.
		{ points = { p(102.6, -555), p(137.8, -535.8) }, style = "Rope", across = true },
		-- The rockfall across the winch track.
		{ points = { p(444, -283), p(456, -306) }, style = "Rockfall", across = true },
		-- A low stone wall each side of the stair road.
		{ points = { p(739, -90), p(768, -90) }, style = "Stone" },
		{ points = { p(739, -110), p(768, -110) }, style = "Stone" },
	},
	-- The town's edge is its cliff walls.
	hedges = {},
	walls = {
		wall({ p(-150, -20), p(-150, -150), p(11, -150) }, "Cliff", 30), -- north cliff, west
		wall({ p(29, -150), p(124, -150) }, "Cliff", 30), -- north cliff, middle
		wall({ p(136, -150), p(150, -150), p(150, 31) }, "Cliff", 30), -- north cliff, east
		wall({ p(150, 49), p(150, 150), p(-150, 150), p(-150, 20) }, "Cliff", 30), -- south cliff
		wall({ p(-236, -20), p(-150, -20) }, "Cliff", 34), -- the Westcut, north
		wall({ p(-236, 20), p(-150, 20) }, "Cliff", 34), -- the Westcut, south
		wall({ p(250, 80), p(420, 92), p(560, 74) }, "Cliff", 34), -- the gorge's far wall
		wall({ p(96, -604), p(190, -568) }, "Cliff", 26), -- the dry fall's far side
		-- The two lips of the Echo Notch, standing out from the rim's north cliff.
		wall({ p(352, -84), p(350, -108) }, "Cliff", 24),
		wall({ p(392, -84), p(394, -108) }, "Cliff", 24),
		-- The buttresses that pinch the stair road at Tavish.
		wall({ p(690, -150), p(690, -122), p(710, -122), p(710, -150) }, "Boulders", 10),
		wall({ p(690, -50), p(690, -78), p(710, -78), p(710, -50) }, "Boulders", 10),
	},
	edges = {
		pebble_wash = edge("Boulders", "Boulders"),
		tumbleweed_flats = edge("Boulders", "Boulders"),
		hollow_arroyo = edge("Cliff", "Cliff"),
		redstone_steps = edge("Cliff", "Boulders"),
		sunbaked_rim = edge("Cliff", "Boulders"),
		spire_garden = edge("Boulders", "Boulders"),
		stair_approach = edge("Cliff", "Boulders"),
		dust_canyon_lair = edge("Cliff", "Cliff"),
	},

	buildings = {
		kiln_trading_post = { width = 24, depth = 20, tall = 28 },
		seep_house = { width = 18, depth = 19, tall = 26 },
		cradle_kiln = { width = 26, depth = 26, tall = 40 },
		notice_wall = { width = 24, depth = 4, tall = 10 },
		sundial_waystation = { width = 20, depth = 20, tall = 40 },
		dust_ring = { width = 40, depth = 30, tall = 0.4 },
		windward_overlook = { width = 16, depth = 16, tall = 44 },
	},
	houses = {
		-- Cave Row, against the north cliff.
		house(-126, -114, 180, "AdobeHouse", 20, 18, 18),
		house(-96, -118, 180, "KilnCottage", 18, 18, 22),
		house(-64, -116, 180, "AdobeHouse", 20, 18, 18),
		-- Round the south and east of town.
		house(-120, 62, 90, "AdobeHouse", 20, 18, 18),
		house(-110, 108, 45, "KilnCottage", 18, 18, 22),
		house(-56, 120, 0, "AdobeHouse", 20, 18, 18),
		house(120, 98, 270, "KilnCottage", 18, 18, 22),
		house(120, -40, 270, "AdobeHouse", 20, 18, 18),
	},
	props = {
		{ model = "Barrels", at = p(38, -22), faces = 0, tall = 6.5, solid = true },
		{ model = "Barrels", at = p(96, 14), faces = 200, tall = 6, solid = true },
		{ model = "WashingLine", at = p(-80, -108), faces = 0, tall = 8 },
		{ model = "WashingLine", at = p(100, 116), faces = 90, tall = 8 },
		{ model = "Boulders", at = p(-136, 128), faces = 30, tall = 8, solid = true },
		{ model = "Boulders", at = p(136, 128), faces = 300, tall = 9, solid = true },
		{ model = "Boulders", at = p(-30, -132), faces = 160, tall = 7, solid = true },
		{ model = "RockSpire", at = p(60, -128), faces = 0, tall = 26, solid = true },
		-- The spires that split the Spire Garden: a bare way round on the far side.
		{ model = "RockSpire", at = p(532, -122), faces = 0, tall = 26, solid = true },
		{ model = "RockSpire", at = p(560, -122), faces = 90, tall = 24, solid = true },
		{ model = "Bench", at = p(-36, 10), faces = 0, tall = 3.8 },
		{ model = "Bench", at = p(36, -14), faces = 270, tall = 3.8 },
	},
	people = {
		{ name = "Potter", at = p(-44, 20), faces = 45, model = "Tamer" },
		{ name = "Kiln hand", at = p(90, 64), faces = 315, model = "Tamer" },
		{ name = "Child", at = p(-24, -70), faces = 180, model = "GirlTamer" },
		{ name = "Grandmother", at = p(-90, -106), faces = 180, model = "Grandmother" },
	},

	clearings = {
		{ at = p(576, -319), radius = 85, ring = true }, -- the shelf round the arena
	},
	caps = {
		dust_canyon_route_a = 21, -- the rope bridge fills the middle
		dust_canyon_route_b = 20, -- the gate fills it
	},
	-- Every stretch is listed, so no green Tree or Pine appears in the biome.
	corridorTrees = {
		pebble_wash = { model = "ScrubBush", scale = 1 },
		tumbleweed_flats = { model = "ScrubBush", scale = 1.2 },
		hollow_arroyo = { model = "ScrubBush", scale = 1 },
		redstone_steps = { model = "ScrubBush", scale = 1 },
		sunbaked_rim = { model = "ScrubBush", scale = 1 },
		spire_garden = { model = "RockSpire", scale = 1 },
		stair_approach = { model = "ScrubBush", scale = 1 },
		dust_canyon_lair = { model = "RockSpire", scale = 0.8 },
	},
	grassLooks = {
		pebble_wash = dry(),
		tumbleweed_flats = dry(),
		hollow_arroyo = dry(),
		redstone_steps = dry(),
		sunbaked_rim = dry(),
		spire_garden = dry(),
		stair_approach = dry(),
	},
	gatehouse = { at = p(779, -100), faces = 270, model = "StairGate", banner = "Cairn Badge" },
	-- Where the sealed road's story beat fires: 13 past the gate, 47 short of its place.
	bar = { at = p(792, -100), width = 20 },
	-- The Redstack, its face turned towards Kilnrest.
	landmark = { at = p(650, -480), model = "RedMesa", tall = 190, faces = 234 },
	stall = { side = 1 }, -- the counter stands west of the spur, away from Hesper
	ring = { width = 40, depth = 30, gap = 12 },
	brambles = {}, -- the rockfall does that job
	-- Egg nests warming in the lee of the kiln, and Calla's spring-watered garden rows.
	coop = p(100, 50),
	patch = { from = p(-108, 12), to = p(-96, 22) },

	-- How each tier looks: red rock under every level, one top colour for the tiers that touch at
	-- a height, so no seam shows.
	tierLooks = {
		flats_mesa = { top = { 226, 196, 140 }, face = "Cliff" },
		arroyo_shelf = { top = { 226, 196, 140 }, face = "Cliff" },
		arroyo_rise = { top = { 196, 140, 100 }, face = "Cliff" },
		arroyo_end = { top = { 196, 140, 100 }, face = "Cliff" },
		arroyo_hollow = { top = { 196, 140, 100 }, face = "Cliff" },
		cairn_tier = { top = { 196, 140, 100 }, face = "Cliff" },
		steps_a = { top = { 190, 110, 84 }, face = "Cliff" },
		steps_b = { top = { 196, 120, 90 }, face = "Cliff" },
		rim_mesa = { top = { 214, 150, 104 }, face = "Cliff" },
		spur_mesa = { top = { 214, 150, 104 }, face = "Cliff" },
		garden_tier = { top = { 214, 150, 104 }, face = "Cliff" },
		gate_terrace = { top = { 200, 184, 160 }, face = "Cliff" },
		rim_shelf_a = { top = { 206, 140, 100 }, face = "Cliff" },
		rim_shelf_b = { top = { 198, 128, 92 }, face = "Cliff" },
		lair_shelf = { top = { 206, 160, 120 }, face = "Cliff" },
	},

	-- Spires and mesas close in everything past the edges (docs/plans/12_MAP_STRUCTURE.md, step 1).
	fill = { style = "Rock", band = 80, floor = { 170, 118, 84 } },

	-- Smoke from the kiln cottages, warm lamps, the Cradle Kiln's glow and embers, dust motes over
	-- the wash and the town, a glint on the Seep. The chimney offsets and the kiln's mouth are
	-- guesses to check by eye.
	ambience = {
		chimneys = {
			KilnCottage = { 0, 0.97, 0 }, -- the glowing vent on top of the dome (measured in Studio)
		},
		lamps = { range = 24, brightness = 1.2, colour = { 255, 190, 110 } },
		glints = true,
		sources = {
			-- The Cradle Kiln (at p(72, 72), facing 315, 26 across and 40 high): a fire glowing in
			-- its mouth and embers climbing out of its chimney.
			{
				kind = "Halo",
				at = p(63.5, 63.5),
				height = 4,
				scale = 2,
				rate = 0.7,
				light = { range = 34, brightness = 2.4, colour = { 255, 150, 70 } },
			},
			{
				kind = "Embers",
				at = p(72, 72),
				height = 39,
				area = { 3, 3, 1 },
				light = { range = 26, brightness = 1.3, colour = { 255, 140, 60 } },
			},
			-- Dust motes in the light: over the wash, the flats, the steps and the town.
			{ kind = "Dust", at = p(44, -212), height = 5, area = { 100, 80, 8 } },
			{ kind = "Dust", at = p(-6, -352), height = 5, area = { 100, 80, 8 } },
			{ kind = "Dust", at = p(188, 84), height = 5, area = { 90, 80, 8 } },
			{ kind = "Dust", at = p(-20, 30), height = 5, area = { 110, 90, 8 } },
		},
	},
}

return DustCanyonDressing
