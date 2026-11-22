--!strict
-- How designed Tide Flats looks: dunes, rope rails, sea rocks and sea walls, the harbour, the bay
-- and the open sea, boardwalks and decks, signs, lamps, marram and kelp, the houses of Saltwick and
-- the Old Light on its headland. Studs from the centre of Saltwick; north is -z; facings are
-- degrees clockwise from north. Data only, from docs/plans/10_TIDE_FLATS_MAP.md section 3d. The
-- server's position checks never read this file: it only dresses the test map (src/server/World).

local WorldTypes = require("../../shared/WorldTypes")

local function p(x: number, z: number): WorldTypes.SheetPoint
	return { x = x, z = z }
end

-- Colours (plan section 3d).
local STREET: WorldTypes.Colour = { 240, 230, 206 } -- the main streets and the Dune Road
local PATH: WorldTypes.Colour = { 232, 220, 186 } -- side paths
local PLANKS: WorldTypes.Colour = { 170, 130, 90 } -- decks, boardwalks and jetties
local MARRAM_GROUND: WorldTypes.Colour = { 176, 170, 118 } -- under the marram

local function lane(
	points: { WorldTypes.SheetPoint },
	width: number,
	colour: WorldTypes.Colour,
	deck: boolean?
): WorldTypes.DressLane
	return { points = points, width = width, colour = colour, deck = deck }
end

local function tree(x: number, z: number, model: string, scale: number?): WorldTypes.DressTree
	return { at = p(x, z), model = model, scale = scale }
end

local function edge(left: WorldTypes.EdgeStyle, right: WorldTypes.EdgeStyle): WorldTypes.DressEdge
	return { left = left, right = right }
end

local function look(model: string, under: WorldTypes.Colour): WorldTypes.GrassLook
	return { model = model, under = under }
end

local function wall(
	points: { WorldTypes.SheetPoint },
	style: WorldTypes.EdgeStyle,
	tall: number
): WorldTypes.DressWall
	return { points = points, style = style, tall = tall }
end

local function flat(
	from: WorldTypes.SheetPoint,
	to: WorldTypes.SheetPoint,
	colour: WorldTypes.Colour,
	water: boolean
): WorldTypes.DressFlat
	return { from = from, to = to, colour = colour, water = water }
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

local TideFlatsDressing: WorldTypes.DressingSheet = {
	fieldGround = { 238, 224, 184 },
	ground = {
		{ area = "wrack_beach", colour = { 226, 210, 168 } },
		{ area = "rockpool_shelf", colour = { 84, 84, 92 } }, -- black rock
		{ area = "kelp_shallows", colour = { 120, 196, 196 } }, -- knee-deep water over sand
		{ area = "sandbar_causeway", colour = { 240, 228, 190 } },
		{ area = "mudflat_boardwalk", colour = { 140, 132, 120 } }, -- grey mud
		{ area = "shipwreck_reach", colour = { 226, 210, 170 } },
		{ area = "tideward_steps", colour = { 150, 170, 150 } }, -- green-slick stone
		-- The wrack line along the beach, on the bay side (the walker's left: negative offsets).
		{
			route = "tide_flats_route_a",
			from = 0,
			to = 160,
			near = -38,
			far = -30,
			colour = { 110, 96, 70 },
		},
	},
	townGround = { 236, 226, 196 },
	laneColour = { 236, 224, 196 }, -- packed shell-sand
	laneSurfaces = {
		-- The sunken plank path through the shallows, and the boardwalk on stilts over the mud.
		{ route = "tide_flats_route_a", from = 330, to = 500, colour = PLANKS, deck = true },
		{ route = "tide_flats_route_b", from = 180, to = 360, colour = PLANKS, deck = true },
		-- The breakwater steps in stone.
		{ route = "tide_flats_route_b", from = 540, to = 720, colour = { 176, 186, 168 } },
	},
	laneWidth = 14,

	lanes = {
		lane({ p(-150, 0), p(-28, 0) }, 16, STREET), -- the Rope Walk
		lane({ p(28, 4), p(90, 14), p(150, 20) }, 14, STREET), -- East Street
		lane({ p(-40, 42), p(110, 42) }, 12, PLANKS, true), -- the Quay
		lane({ p(0, 26), p(0, 42) }, 10, PLANKS, true), -- the quay steps
		lane({ p(-64, -8), p(-64, -30) }, 8, PATH), -- the Warm Pool
		lane({ p(-14, -26), p(-20, -42) }, 8, PATH), -- the Tally Board
		lane({ p(28, -6), p(48, -14) }, 8, PATH), -- the Chandlery
		lane({ p(12, -26), p(30, -64) }, 8, PATH), -- the Brood Shallows
		lane({ p(96, 15), p(90, -30), p(84.7, -58.7) }, 8, PATH), -- the Breaker Ring
		lane({ p(-50, 8), p(-46.7, 50.7) }, 8, PATH), -- the Ferry Steps
		lane({ p(110, 42), p(110.1, 62) }, 10, { 170, 165, 150 }), -- the mole, in stone
		lane({ p(-90, 0), p(-110, 30), p(-110, 150) }, 10, PLANKS, true), -- Stilt Row
		-- The Dune Road, joining Dust Canyon's sealed road, which already reaches -180.
		lane({ p(-180, 0), p(-150, 0) }, 14, STREET),
		lane({ p(-40, 70), p(-14, 70) }, 4, PLANKS, true), -- the ferry jetty
		-- No shortcut lane: the lair's way back is a sign by the Wreck Stall (`brambles` is empty).
	},
	footpaths = {},
	-- From the Warm Pool path to the pool.
	stones = { { from = p(-70, -24), to = p(-84, -28) } },
	-- Net Square: bleached boards with a darker kerb. No well; an upturned Rowboat is its heart.
	plaza = {
		at = p(0, 0),
		size = 56,
		rim = 60,
		colour = { 196, 160, 116 },
		rimColour = { 150, 116, 84 },
	},

	water = {},
	pools = {
		{ at = p(-92, -30), radius = 7, colour = { 120, 200, 200 } }, -- the Warm Pool
		{ at = p(4, -84), radius = 5, colour = { 84, 170, 196 } }, -- the Brood Shallows' pens
		{ at = p(56, -84), radius = 5, colour = { 84, 170, 196 } },
	},
	-- Drawn in this order; corridor ground paints over them.
	flats = {
		flat(p(-30, 50), p(100, 150), { 64, 150, 186 }, true), -- the harbour
		flat(p(-70, 150), p(250, 330), { 84, 170, 196 }, true), -- Saltwick Bay
		flat(p(250, -80), p(440, 140), { 84, 170, 196 }, true), -- the outer water
		flat(p(250, 240), p(470, 330), { 150, 140, 124 }, false), -- the mudflat
		flat(p(236, 160), p(286, 330), { 240, 228, 190 }, false), -- the sandbar spit
		flat(p(-200, 470), p(900, 900), { 56, 130, 176 }, true), -- the open sea
		flat(p(820, 140), p(900, 470), { 56, 130, 176 }, true), -- the sea east of the headland
	},

	arches = {
		{
			at = p(-142, 0),
			faces = 270,
			outside = "Saltwick",
			inside = "Dune Road · to Kilnrest",
			model = "HarbourArch",
		},
		{
			at = p(-110, 142),
			faces = 180,
			outside = "Saltwick",
			inside = "Route A · Strandline Path",
			model = "HarbourArch",
		},
		{
			at = p(142, 19),
			faces = 84,
			outside = "Saltwick",
			inside = "Route B · Breakwater Road",
			model = "HarbourArch",
		},
	},
	-- Each signpost's arrow board points along its facing.
	signs = {
		{ at = p(-128, -14), faces = 90, lines = { "Net Square · Tarn's Chandlery →" } },
		{ at = p(-84, 22), faces = 214, lines = { "↓ Stilt Row", "Route A · Strandline Path" } },
		{
			at = p(36, 20),
			faces = 84,
			lines = { "Route B · Breakwater Road →", "↓ The Quay · Lamp Tower" },
		},
		{ at = p(-100, 196), faces = 285, lines = { "Dune grass:", "wild creatures hide here" } },
		{ at = p(486, 168), faces = 143, lines = { "Carrackon's Wreck · Wreck Stall" } },
		{
			at = p(548, 222),
			faces = 315,
			lines = { "Ferry to Saltwick:", "not while the wreck is awake" },
		},
		{ at = p(700, 124), faces = 90, lines = { "The Breakwater Gate", "badge challenge" } },
		{ at = p(184, 336), faces = 59, lines = { "Plank bridge out.", "The tide took it." } },
		-- On the Dune Road, seen coming from Dust Canyon.
		{ at = p(-200, -14), faces = 90, lines = { "Saltwick →" } },
	},
	-- Lantern posts: the Rope Walk, the square, the quay, East Street, the arches and the gate.
	lamps = {
		p(-120, -11),
		p(-80, -11),
		p(-40, 11),
		p(-22, -22),
		p(22, -22),
		p(-22, 22),
		p(18, 24),
		p(-20, 30),
		p(40, 30),
		p(80, 30),
		p(84, 2),
		p(120, 28),
		p(-142, -11),
		p(-142, 11),
		p(141, 8),
		p(139, 31),
		p(-121, 142),
		p(-99, 142),
		p(700, 98),
		p(724, 124),
	},
	-- Pots of sea-pinks by the doors, round the square, on the Rope Walk and the quay.
	beds = {
		p(50, -24),
		p(50, -4),
		p(-72, -28),
		p(-56, -28),
		p(-30, -14),
		p(30, -20),
		p(-46, -12),
		p(46, 26),
	},

	trees = {
		-- Reeds round the Warm Pool.
		tree(-101, -26, "Reeds"),
		tree(-92, -39, "Reeds"),
		tree(-83, -25, "Reeds"),
		-- Sea rocks on the mole.
		tree(140, 90, "SeaRocks"),
		tree(112, 140, "SeaRocks"),
		-- Kelp in the harbour.
		tree(40, 130, "Kelp", 0.8),
		tree(80, 96, "Kelp", 0.8),
		tree(-10, 120, "Kelp", 0.8),
	},
	-- Marram at the foot of the dunes.
	rows = {
		{ from = p(-140, -140), to = p(-60, -140), step = 8, model = "MarramTuft" },
		{ from = p(0, -140), to = p(140, -140), step = 8, model = "MarramTuft" },
		{ from = p(-140, -130), to = p(-140, -30), step = 10, model = "MarramTuft" },
	},

	fences = {
		-- The harbour's west rail, with a gap at z 64 to 76 for the ferry jetty.
		{ points = { p(-30, 150), p(-30, 76) }, style = "Rope" },
		{ points = { p(-30, 64), p(-30, 50), p(100, 50) }, style = "Rope" }, -- the quay rail
		{ points = { p(20, 150), p(70, 150) }, style = "Rope" }, -- the floating boom in the mouth
		-- The broken plank bridge across the end of Route A.
		{ points = { p(191.4, 331.9), p(212, 366.1) }, style = "Rope", across = true },
	},
	-- The town's edge is its dunes and sea walls.
	hedges = {},
	walls = {
		wall({ p(-150, -20), p(-150, -150), p(150, -150), p(150, 6) }, "Dunes", 8), -- north dunes
		wall({ p(-150, 20), p(-150, 150), p(-124, 150) }, "Dunes", 8), -- west dunes
		wall({ p(-96, 150), p(-30, 150) }, "Dunes", 8), -- south dunes
		wall({ p(-30, 150), p(20, 150) }, "SeaWall", 6), -- harbour wall, west
		wall({ p(70, 150), p(150, 150), p(150, 34) }, "SeaWall", 6), -- harbour wall, east
		wall({ p(100, 150), p(100, 80) }, "SeaWall", 6), -- the mole's wall
		wall({ p(-236, -20), p(-150, -20) }, "Dunes", 10), -- the Dune Road, north
		wall({ p(-236, 20), p(-150, 20) }, "Dunes", 10), -- the Dune Road, south
		-- The sea cave's outcrop, jutting from the reach's north cliff.
		wall({ p(533.9, 129.4), p(525.3, 155), p(553.8, 163.6), p(562.4, 138) }, "SeaCliff", 24),
	},
	edges = {
		wrack_beach = edge("Rope", "Dunes"),
		rockpool_shelf = edge("Rocks", "Rocks"),
		kelp_shallows = edge("Rope", "Rope"),
		sandbar_causeway = edge("Rope", "Rocks"),
		mudflat_boardwalk = edge("Rope", "Rope"),
		shipwreck_reach = edge("SeaCliff", "Rocks"),
		tideward_steps = edge("SeaWall", "SeaWall"),
		tide_flats_lair = edge("SeaCliff", "Rocks"),
	},

	buildings = {
		tarn_chandlery = { width = 24, depth = 20, tall = 28 },
		warm_pool = { width = 18, depth = 19, tall = 26 },
		brood_shallows = { width = 20, depth = 16, tall = 20 },
		tally_board = { width = 20, depth = 4, tall = 10 },
		ferry_steps = { width = 20, depth = 20, tall = 40 },
		breaker_ring = { width = 40, depth = 30, tall = 0.4 },
		lamp_tower = { width = 16, depth = 16, tall = 36 },
	},
	houses = {
		-- Stilt Row.
		house(-136, 60, 90, "StiltHouse", 18, 18, 24),
		house(-136, 100, 90, "StiltHouse", 18, 18, 24),
		house(-86, 104, 270, "NetLoft", 20, 16, 20),
		-- Round the north and east of town.
		house(-112, -64, 135, "NetLoft", 20, 16, 20),
		house(-96, -114, 180, "StiltHouse", 18, 18, 24),
		house(60, -118, 180, "NetLoft", 20, 16, 20),
		house(124, -28, 270, "StiltHouse", 18, 18, 24),
	},
	props = {
		-- The upturned boat at the heart of Net Square.
		{ model = "Rowboat", at = p(0, -3), faces = 90, tall = 5, solid = true },
		-- Afloat in the harbour, and the ferry at its jetty.
		{ model = "Rowboat", at = p(30, 100), faces = 30, tall = 5 },
		{ model = "Rowboat", at = p(70, 122), faces = 300, tall = 5 },
		{ model = "Rowboat", at = p(-10, 78), faces = 90, tall = 5 },
		{ model = "Barrels", at = p(60, 28), faces = 0, tall = 6.5, solid = true },
		{ model = "Barrels", at = p(-36, -14), faces = 90, tall = 6, solid = true },
		-- Drying nets.
		{ model = "WashingLine", at = p(-122, 80), faces = 0, tall = 8 },
		{ model = "WashingLine", at = p(-60, -96), faces = 90, tall = 8 },
		{ model = "SeaRocks", at = p(130, 120), faces = 0, tall = 8, solid = true },
		{ model = "ShipRibs", at = p(470, 270), faces = 100, tall = 30, solid = true },
		-- The Tide Cave's mouth: its face is 6.4 from the rustle spot's prompt.
		{ model = "SeaCave", at = p(540.1, 157.9), faces = 198, tall = 24, solid = true },
		{ model = "Bench", at = p(-36, 30), faces = 180, tall = 3.8 },
	},
	people = {
		{ name = "Net-mender", at = p(-122, 72), faces = 90, model = "Grandmother" },
		{ name = "Fisher", at = p(64, 38), faces = 180, model = "Tamer" },
		{ name = "Child", at = p(-36, 64), faces = 90, model = "GirlTamer" },
		{ name = "Gull-watcher", at = p(116, 100), faces = 135, model = "Carer" },
	},

	clearings = {
		{ at = p(693.6, 385.7), radius = 90, ring = true }, -- the cove round the arena
	},
	caps = {
		tide_flats_route_a = 21, -- the broken bridge fills the middle
		tide_flats_route_b = 20, -- the gate fills it
	},
	-- Every stretch is listed, so no green Tree or Pine appears in the biome.
	corridorTrees = {
		wrack_beach = { model = "MarramTuft", scale = 1.5 },
		rockpool_shelf = { model = "SeaRocks", scale = 0.7 },
		kelp_shallows = { model = "Kelp", scale = 1.2 },
		sandbar_causeway = { model = "SeaRocks", scale = 0.6 },
		mudflat_boardwalk = { model = "Reeds", scale = 1 },
		shipwreck_reach = { model = "SeaRocks", scale = 1 },
		tideward_steps = { model = "SeaRocks", scale = 0.8 },
		tide_flats_lair = { model = "SeaRocks", scale = 1 },
	},
	-- Marram on sand, kelp in the pools and shallows, reeds on the mud.
	grassLooks = {
		wrack_beach = look("MarramTuft", MARRAM_GROUND),
		rockpool_shelf = look("Kelp", { 70, 96, 84 }),
		kelp_shallows = look("Kelp", { 60, 120, 110 }),
		sandbar_causeway = look("MarramTuft", MARRAM_GROUND),
		mudflat_boardwalk = look("Reeds", { 110, 108, 82 }),
		shipwreck_reach = look("MarramTuft", MARRAM_GROUND),
		tideward_steps = look("MarramTuft", { 150, 160, 120 }),
	},
	gatehouse = {
		at = p(742.9, 110),
		faces = 270,
		model = "BreakwaterGate",
		banner = "Breaker Badge",
	},
	-- Where the sealed road's story beat fires: 13 past the gate, 47 short of its place.
	bar = { at = p(755.9, 110), width = 20 },
	-- The Old Light, its door turned towards Saltwick.
	landmark = { at = p(790, 470), model = "OldLighthouse", tall = 140, faces = 301 },
	stall = { side = -1 }, -- the counter stands south-west of the spur, away from the Tide Cave
	ring = { width = 40, depth = 30, gap = 12, style = "Rope" }, -- the Breaker Ring
	brambles = {}, -- no shut path: the ferry sign does that job
	-- Egg nests in seaweed behind the Brood Shallows.
	coop = p(-4, -104),
}

return TideFlatsDressing
