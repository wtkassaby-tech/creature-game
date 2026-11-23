--!strict
-- How the designed Mire looks: Sedgeholm, a reed-thatched village on stilts and duckboards over a
-- swamp, round the Bell Cypress; the Duckboard Trail's reeds, lily channels and mangrove roots;
-- the Cypress Road's peat cuttings, stilt hamlet, fogwater and sluice rise; the Sunken Grove; the
-- Heron Causeway in from Tide Flats; and the drowned bell tower at the end of a branch. Studs
-- from the centre of Sedgeholm; north is -z; facings are degrees clockwise from north. Data only,
-- from docs/plans/15_MIRE_MAP.md section 3. The server's position checks never read this file: it
-- only dresses the test map (src/server/World).
--
-- Painted models still to come (docs/plans/15_MIRE_MAP.md section 5) stand in with the nearest
-- model that exists: the Tide Flats stilt houses, net lofts and lamp tower for the reed huts, the
-- reed nursery and the bell tower, a Tree for mangrove and cypress, Kelp for lily pads.

local WorldTypes = require("../../shared/WorldTypes")

local function p(x: number, z: number): WorldTypes.SheetPoint
	return { x = x, z = z }
end

-- Colours (plan section 3d).
local STREET: WorldTypes.Colour = { 160, 138, 98 } -- the main streets, damp boards
local PATH: WorldTypes.Colour = { 146, 130, 96 } -- side paths
local PLANKS: WorldTypes.Colour = { 150, 120, 84 } -- decks, boardwalks and jetties
local REED_GROUND: WorldTypes.Colour = { 92, 108, 70 } -- under the reeds

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

-- The Heron Causeway's line, from Tide Flats' sealed road to Sedgeholm's south arch.
local CAUSEWAY: { WorldTypes.SheetPoint } =
	{ p(-234, 480), p(-150, 440), p(-110, 340), p(-60, 250), p(-20, 190), p(0, 150) }

local MireDressing: WorldTypes.DressingSheet = {
	roomEdge = "Rope", -- every pocket, dead end and the causeway itself is ringed with a rope rail
	fieldGround = { 92, 110, 82 },
	ground = {
		{ area = "reedfringe", colour = { 112, 126, 88 } },
		{ area = "lily_lanes", colour = { 70, 112, 104 } }, -- still dark water under the pads
		{ area = "mangrove_tangle", colour = { 104, 98, 72 } }, -- root mud
		{ area = "peat_cuttings", colour = { 70, 60, 52 } }, -- black peat
		{ area = "stilt_hamlet", colour = { 104, 96, 78 } },
		{ area = "fogwater_reach", colour = { 112, 134, 128 } }, -- grey-green fogwater
		{ area = "sluice_rise", colour = { 128, 110, 82 } }, -- packed peat
	},
	townGround = { 118, 128, 92 },
	laneColour = { 138, 118, 86 }, -- damp boards and packed mud
	laneSurfaces = {
		-- The reedfringe duckboards and the boardwalk of the old hamlet (on stilts).
		{ route = "mire_route_a", from = 0, to = 160, colour = PLANKS },
		{ route = "mire_route_b", from = 180, to = 360, colour = PLANKS, deck = true },
		-- The sluice rise in packed peat.
		{ route = "mire_route_b", from = 540, to = 720, colour = { 136, 116, 86 } },
	},
	laneWidth = 14,

	lanes = {
		lane({ p(0, 150), p(0, 28) }, 16, STREET), -- the Heron Walk
		lane(CAUSEWAY, 16, PLANKS, true), -- the Heron Causeway
		lane({ p(0, -26), p(8, -90), p(20, -150) }, 14, STREET), -- the Cypress Walk
		lane({ p(26, 2), p(80, 10), p(150, 30) }, 14, STREET), -- the Reed Lane
		lane({ p(2, -26), p(40, -30) }, 8, PATH), -- Quill's Sundries
		lane({ p(-24, -10), p(-54, -26) }, 8, PATH), -- the Clearwater Spring
		lane({ p(-26, 10), p(-72, 30) }, 8, PATH), -- the Reed Nursery
		lane({ p(4, -52), p(-14, -54) }, 8, PATH), -- the Mooring Post
		lane({ p(-14, -54), p(-30, -46), p(-56, -46) }, 8, PATH), -- to the Bell Loft's stairs
		lane({ p(-56, -72), p(-84, -80) }, 8, PATH), -- along the Bell Loft's deck
		lane({ p(10, -82), p(46, -80), p(80.7, -78.7) }, 8, PATH), -- the Cypress Ring
		lane({ p(0, 70), p(-60, 84) }, 8, PATH), -- the Punt Landing
		lane({ p(-60, 84), p(-104, 98) }, 4, PLANKS, true), -- the punt jetty
	},
	footpaths = {},
	-- From the Clearwater Spring's door to its pool.
	stones = { { from = p(-82, -26), to = p(-90, -26) } },
	-- Bell Square: round boards with a darker kerb; the Bell Cypress stands in the middle.
	plaza = {
		at = p(0, 0),
		size = 50,
		rim = 54,
		colour = { 150, 118, 84 },
		rimColour = { 104, 80, 58 },
	},

	water = {},
	pools = {
		{ at = p(-96, -26), radius = 7, colour = { 150, 214, 206 } }, -- the Clearwater Spring
		{ at = p(-122, 106), radius = 22, colour = { 84, 120, 116 } }, -- the punt pond
		{ at = p(42, 72), radius = 10, colour = { 70, 104, 100 } },
	},
	-- Drawn in this order; corridor ground paints over them.
	flats = {
		flat(p(-420, 160), p(60, 620), { 82, 118, 112 }, true), -- the estuary shallows (the causeway)
		flat(p(60, 260), p(330, 420), { 70, 108, 102 }, true), -- the black water under Route A
		flat(p(330, 276), p(620, 520), { 62, 100, 98 }, true), -- the drowned village (the Sunken Bell)
		flat(p(200, -520), p(340, -260), { 78, 116, 112 }, true), -- the lake east of the hamlet
		flat(p(-200, -330), p(-60, -200), { 88, 76, 60 }, false), -- the old peat bog
	},

	arches = {
		{
			at = p(0, 142),
			faces = 180,
			outside = "Sedgeholm",
			inside = "The Heron Causeway · to Saltwick",
			model = "VillageArch",
		},
		{
			at = p(142, 29),
			faces = 78,
			outside = "Sedgeholm",
			inside = "Route A · Duckboard Trail",
			model = "VillageArch",
		},
		{
			at = p(21, -142),
			faces = 36,
			outside = "Sedgeholm",
			inside = "Route B · Cypress Road",
			model = "VillageArch",
		},
	},
	-- Each signpost's arrow board points along its facing.
	signs = {
		{ at = p(18, 130), faces = 180, lines = { "↓ The Heron Causeway", "to Saltwick" } },
		{ at = p(100, -6), faces = 80, lines = { "Route A · Duckboard Trail →" } },
		{
			at = p(-16, -118),
			faces = 0,
			lines = { "↑ Route B · Cypress Road", "to the Sluice Gate" },
		},
		{ at = p(388, 276), faces = 180, lines = { "The Sunken Bell", "The boards end here." } },
		{ at = p(520, 176), faces = 200, lines = { "Rope ferry:", "not running" } },
		{ at = p(46, -452), faces = 215, lines = { "Grove Stall · The Sunken Grove" } },
		{ at = p(120, -574), faces = 0, lines = { "The Sluice Gate", "badge challenge" } },
		{ at = p(-64, 108), faces = 90, lines = { "The Punt Landing" } },
	},
	-- Green lantern posts: the Heron Walk, the square, the streets, the arches and the gate.
	lamps = {
		p(-16, 130),
		p(16, 130),
		p(-16, 100),
		p(16, 60),
		p(-30, 30),
		p(-30, -30),
		p(30, -22),
		p(30, 24),
		p(-24, -100),
		p(34, -110),
		p(80, -16),
		p(120, 14),
		p(-16, 142),
		p(139, 14),
		p(34, -134),
		p(112, -584),
		p(188, -606),
	},
	-- Pots of marsh marigolds by the doors and the square.
	beds = {
		p(46, -42),
		p(-60, -14),
		p(-30, 18),
		p(-18, -42),
		p(34, -14),
		p(-66, 42),
	},

	trees = {
		-- Reeds round the Clearwater Spring.
		tree(-102, -17, "Reeds"),
		tree(-96, -36, "Reeds"),
		tree(-88, -18, "Reeds"),
		-- Lily pads on the punt pond and the village pool.
		tree(-128, 100, "Kelp", 0.8),
		tree(-116, 114, "Kelp", 0.8),
		tree(-134, 114, "Kelp", 0.8),
		tree(36, 66, "Kelp", 0.8),
		tree(46, 76, "Kelp", 0.8),
	},
	-- Reeds along the inside of the reed fence.
	rows = {
		{ from = p(-144, -142), to = p(-20, -142), step = 12, model = "Reeds" },
		{ from = p(44, -142), to = p(140, -142), step = 12, model = "Reeds" },
		{ from = p(-146, -126), to = p(-146, 130), step = 16, model = "Reeds" },
	},

	fences = {
		-- The rope ferry at the end of the trail: the ferry is not running.
		{ points = { p(525.5, 194.3), p(510.5, 235.7) }, style = "Rope", across = true },
		-- The Sunken Bell's boards end in black water.
		{ points = { p(388, 274), p(424, 274) }, style = "Rope", across = true },
	},
	-- The village's edge is a reed fence, open at the three arches.
	hedges = {
		{ p(6, -150), p(-150, -150), p(-150, 150), p(-14, 150) },
		{ p(14, 150), p(150, 150), p(150, 48) },
		{ p(34, -150), p(150, -150), p(150, 12) },
	},
	walls = {},
	edges = {
		reedfringe = edge("Hedge", "Hedge"),
		lily_lanes = edge("Rope", "Rope"),
		mangrove_tangle = edge("Hedge", "Rocks"),
		peat_cuttings = edge("Rocks", "Hedge"),
		stilt_hamlet = edge("Rope", "Rope"),
		fogwater_reach = edge("Hedge", "Rope"),
		sluice_rise = edge("Rocks", "SeaWall"),
		mire_lair = edge("Hedge", "Hedge"),
	},

	buildings = {
		quill_sundries = { width = 24, depth = 18, tall = 24 },
		clearwater_spring = { width = 18, depth = 19, tall = 26 },
		reed_nursery = { width = 20, depth = 16, tall = 20 },
		mooring_post = { width = 20, depth = 4, tall = 10 },
		punt_landing = { width = 20, depth = 20, tall = 40 },
		cypress_ring = { width = 40, depth = 30, tall = 0.4 },
		bell_loft = { width = 16, depth = 16, tall = 36 },
	},
	houses = {
		house(-124, -40, 90, "StiltHouse", 18, 18, 24),
		house(-134, -100, 90, "NetLoft", 20, 16, 20),
		house(-124, 70, 90, "StiltHouse", 18, 18, 24),
		house(-30, 112, 0, "StiltHouse", 18, 18, 24),
		house(60, 100, 270, "StiltHouse", 18, 18, 24),
		house(112, -44, 270, "StiltHouse", 18, 18, 24),
		house(116, 70, 300, "NetLoft", 20, 16, 20),
		house(60, -130, 180, "NetLoft", 20, 16, 20),
		house(122, -124, 225, "StiltHouse", 18, 18, 24),
	},
	props = {
		-- Punts tied up on the pond and at the jetty's end.
		{ model = "Rowboat", at = p(-116, 100), faces = 30, tall = 5 },
		{ model = "Rowboat", at = p(-132, 110), faces = 300, tall = 5 },
		{ model = "Rowboat", at = p(-108, 94), faces = 90, tall = 5 },
		{ model = "Barrels", at = p(62, -12), faces = 0, tall = 6.5, solid = true },
		-- Reeds hung up to dry.
		{ model = "WashingLine", at = p(-110, 14), faces = 0, tall = 8 },
		{ model = "WashingLine", at = p(80, -58), faces = 90, tall = 8 },
		{ model = "Bench", at = p(-24, 112), faces = 90, tall = 3.8 },
	},
	people = {
		{ name = "Reed-cutter", at = p(-110, 40), faces = 90, model = "Grandmother" },
		{ name = "Poler", at = p(-50, 96), faces = 270, model = "Tamer" },
		{ name = "Child", at = p(30, 50), faces = 180, model = "GirlTamer" },
		{ name = "Bell-ringer", at = p(-70, -112), faces = 180, model = "Carer" },
	},

	-- The cove round the Sunken Grove's arena (the spur's end).
	clearings = {
		{ at = p(-228.7, -425.9), radius = 90, ring = true },
	},
	caps = {
		mire_route_a = 21, -- the rope ferry fills the middle
		mire_route_b = 20, -- the gate fills it
	},
	-- Every stretch is listed, so no plain Tree or Pine appears in the biome by default.
	corridorTrees = {
		reedfringe = { model = "Reeds", scale = 1.4 },
		lily_lanes = { model = "Kelp", scale = 1.2 },
		mangrove_tangle = { model = "Tree", scale = 0.9 },
		peat_cuttings = { model = "Reeds", scale = 1 },
		stilt_hamlet = { model = "Tree", scale = 0.8 },
		fogwater_reach = { model = "Tree", scale = 1.1 },
		sluice_rise = { model = "Reeds", scale = 1 },
		mire_lair = { model = "Tree", scale = 1.2 },
	},
	-- Reeds in every patch, in the colour of each stretch's mud.
	grassLooks = {
		reedfringe = look("Reeds", REED_GROUND),
		lily_lanes = look("Kelp", { 54, 96, 90 }),
		mangrove_tangle = look("Reeds", { 84, 86, 60 }),
		peat_cuttings = look("Reeds", { 66, 58, 46 }),
		stilt_hamlet = look("Reeds", { 90, 88, 64 }),
		fogwater_reach = look("Reeds", { 96, 120, 110 }),
		sluice_rise = look("Reeds", { 104, 98, 70 }),
	},
	gatehouse = {
		at = p(150, -602),
		faces = 0,
		model = "SluiceGate",
		banner = "Bulrush Badge",
	},
	-- Where the sealed road's story beat fires: 13 past the gate, 47 short of its place.
	bar = { at = p(150, -615), width = 20 },
	-- The drowned bell tower of the Sunken Bell, standing in the water at the end of the branch.
	landmark = { at = p(424, 330), model = "LampTower", tall = 44, faces = 0 },
	stall = { side = -1 }, -- the counter stands on the south side of the spur
	ring = { width = 40, depth = 30, gap = 12, style = "Rope" }, -- the Cypress Ring
	brambles = {}, -- no shut path: the spur's way home is a sign by the Grove Stall
	-- Egg nests in reeds behind the Reed Nursery.
	coop = p(-108, 48),
	-- The Bell Cypress, huge and old, with the bronze fog bell hung in its branches.
	ancientTree = { at = p(0, -2), tall = 52 },

	-- How each tier looks: boarded tops over earth banks, one top colour per tier.
	tierLooks = {
		bell_deck = { top = { 150, 118, 84 }, face = "Earth" },
		lily_shelf = { top = { 96, 112, 80 }, face = "Earth" },
		tangle_deck = { top = { 146, 116, 80 }, face = "Earth" },
		hamlet_deck = { top = { 146, 116, 80 }, face = "Earth" },
		sluice_bank = { top = { 128, 110, 84 }, face = "Earth" },
	},

	-- Walls of tall trees close in the swamp past the edges; the water is walled by Barriers.
	fill = { style = "Forest", band = 70, floor = { 62, 84, 66 } },

	-- Smoke from the stilt houses, green lantern light, fireflies over the square and the hamlet,
	-- a glow in the Bell Loft and in the drowned bell, mist on every sheet of water (thickest on
	-- the fogwater and halfway along the causeway) and a slow glint on every pool.
	ambience = {
		chimneys = {
			StiltHouse = { -0.21, 0.95, 0.14 }, -- the pot at the back left of the roof
		},
		lamps = { range = 22, brightness = 1, colour = { 200, 232, 170 } },
		glints = true,
		sources = {
			{
				kind = "Halo",
				at = p(-84, -96),
				height = 33,
				scale = 3,
				rate = 0.5,
				light = { range = 50, brightness = 2.2, colour = { 210, 236, 170 } },
			},
			{
				kind = "Halo",
				at = p(424, 330),
				height = 40,
				scale = 3,
				rate = 0.4,
				light = { range = 56, brightness = 2.4, colour = { 170, 220, 200 } },
			},
			-- Fireflies.
			{ kind = "Pollen", at = p(0, 0), height = 4, area = { 110, 110, 6 } },
			{ kind = "Pollen", at = p(60, -390), height = 4, area = { 90, 80, 6 } },
			-- Mist lying low.
			{ kind = "Mist", at = p(-120, 360), height = 3, area = { 200, 150, 4 } },
			{ kind = "Mist", at = p(-30, 60), height = 3, area = { 120, 100, 4 } },
			{ kind = "Mist", at = p(340, 110), height = 3, area = { 150, 120, 4 } },
			{ kind = "Mist", at = p(60, -250), height = 3, area = { 140, 120, 4 } },
			{ kind = "Mist", at = p(10, -470), height = 3, area = { 170, 150, 4 } },
		},
	},
}

return MireDressing
