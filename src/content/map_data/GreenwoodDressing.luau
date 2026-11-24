--!strict
-- How designed Greenwood looks: water, lanes, fences, signs, lamps, trees, the gatehouse hamlet
-- and the lair. Studs from the centre of Thistledown; north is -z; facings are degrees clockwise
-- from north. Data only, from docs/plans/08_GREENWOOD_MAP.md sections 3 and 5. The server's
-- position checks never read this file: it only dresses the test map (src/server/World).

local WorldTypes = require("../../shared/WorldTypes")

local function p(x: number, z: number): WorldTypes.SheetPoint
	return { x = x, z = z }
end

-- Ground colours (plan section 3).
local MEADOW: WorldTypes.Colour = { 150, 204, 110 }
local MOSS: WorldTypes.Colour = { 118, 176, 92 }
local SAND: WorldTypes.Colour = { 232, 214, 160 }
local BIRCH: WorldTypes.Colour = { 140, 190, 100 }
local OLD_WOOD: WorldTypes.Colour = { 88, 132, 70 }
local RIDGE: WorldTypes.Colour = { 108, 160, 84 }
local DIRT: WorldTypes.Colour = { 204, 180, 128 }
local COBBLE: WorldTypes.Colour = { 222, 204, 168 }
local STONE: WorldTypes.Colour = { 186, 180, 168 }
local PLANKS: WorldTypes.Colour = { 170, 130, 90 }

-- A row of trees every `step` studs from one point to another.
local function row(
	fromX: number,
	fromZ: number,
	toX: number,
	toZ: number,
	model: string
): WorldTypes.DressRow
	return { from = p(fromX, fromZ), to = p(toX, toZ), step = 14, model = model }
end

local function tree(x: number, z: number, model: string?, scale: number?): WorldTypes.DressTree
	return { at = p(x, z), model = model or "Tree", scale = scale }
end

local GreenwoodDressing: WorldTypes.DressingSheet = {
	ground = {
		{ area = "mossy_glade", colour = MOSS },
		{ area = "clover_meadow", colour = MEADOW },
		{ area = "birch_rise", colour = BIRCH },
		{ area = "old_wood", colour = OLD_WOOD },
		-- The sand strip between River Road and the river (the river is on the lane's south,
		-- its left as it heads east).
		{ route = "greenwood_route_b", from = 0, to = 150, near = 8, far = 30, colour = SAND },
	},
	townGround = { 138, 196, 104 },
	-- Soft patches of lighter and darker lawn, so the green is not one flat colour (GroundTone).
	blotches = {
		colours = { { 152, 208, 110 }, { 124, 184, 92 }, { 164, 202, 104 }, { 130, 178, 100 } },
		size = { 18, 34 },
		town = 14,
		verge = 10,
		budget = 40,
	},
	laneColour = DIRT,
	laneSurfaces = {
		-- The wood opens on to a stone lane through the hamlet to the gate.
		{ route = "greenwood_route_b", from = 480, to = 600, colour = STONE },
	},
	laneWidth = 14,

	lanes = {
		{ points = { p(-150, 0), p(150, 0) }, width = 16, colour = COBBLE }, -- main street
		{ points = { p(0, -28), p(0, -64) }, width = 10, colour = COBBLE }, -- north lane
		{ points = { p(-64, 8), p(-64, 31) }, width = 8, colour = DIRT }, -- healer
		{ points = { p(-26, 8), p(-26, 32) }, width = 8, colour = DIRT }, -- shop
		{ points = { p(-56, -8), p(-68.7, -50.7) }, width = 8, colour = DIRT }, -- waystation
		{ points = { p(56, -8), p(69.3, -51.3) }, width = 8, colour = DIRT }, -- breeder
		{ points = { p(48, 8), p(62, 42) }, width = 8, colour = DIRT }, -- the Ring
		{ points = { p(-96, 62), p(-96, 76) }, width = 4, colour = PLANKS }, -- the jetty
		-- Orchard Row: where the townsfolk live, south of the plaza.
		{ points = { p(0, 28), p(0, 104) }, width = 8, colour = COBBLE },
		{ points = { p(-34, 104), p(44, 104) }, width = 8, colour = DIRT },
		{ points = { p(118, -8), p(118, -17) }, width = 6, colour = DIRT }, -- the east cottage
	},
	footpaths = {},
	stones = {
		{ from = p(-24, -8), to = p(-36, -14) }, -- plaza to the notice oak
		{ from = p(-70, 38), to = p(-90, 62) }, -- healer to the pond
	},
	plaza = { at = p(0, 0), size = 56, rim = 60 },
	well = p(18, 12),

	water = {
		-- The brook: it rises on the spring plateau, falls to the terrace pool, runs east along the
		-- terrace's north side, falls again off its east face, and winds through the wood to town.
		{
			points = { p(-300, -140), p(-300, -112), p(-300, -86) },
			width = 8,
			colour = { 110, 182, 214 },
		},
		{
			points = { p(-300, -62), p(-292, -66), p(-276, -67), p(-264, -64) },
			width = 8,
			colour = { 110, 182, 214 },
		},
		{
			points = {
				p(-250, -60),
				p(-240, -44),
				p(-222, -30),
				p(-196, -22),
				p(-168, -18),
				p(-150, -10),
				p(-128, 0),
				p(-118, 40),
				p(-104, 70),
			},
			width = 10,
			colour = { 110, 182, 214 },
		},
		-- The river beside River Road, crossing the town's south-east corner.
		{
			points = {
				p(440, 140),
				p(360, 75),
				p(300, 62),
				p(240, 60),
				p(190, 55),
				p(160, 72),
				p(140, 120),
				p(125, 220),
			},
			width = 24,
			colour = { 86, 160, 204 },
		},
	},
	pools = {
		{ at = p(-300, -118), radius = 8, colour = { 110, 182, 214 } }, -- the spring
		{ at = p(-300, -62), radius = 7, colour = { 110, 182, 214 } }, -- the terrace pool
		{ at = p(231, 50), radius = 9, colour = { 86, 160, 204 } }, -- the heron inlet
	},
	pond = {
		at = p(-96, 92),
		radius = 22,
		colour = { 100, 176, 210 },
		jetty = { p(-96, 62), p(-96, 76) },
	},
	waterfall = p(-300, -71), -- the foot of the plateau's face, over the terrace pool
	falls = { { at = p(-254, -62), towards = p(-266, -64) } },
	footbridge = { at = p(-128, 0), faces = 90, length = 20, width = 12 },

	arches = {
		{
			at = p(-142, 0),
			faces = 270,
			outside = "Thistledown",
			inside = "Route A · Clover Lane",
		},
		{ at = p(142, 0), faces = 90, outside = "Thistledown", inside = "River Road · Gatehouse" },
	},
	-- Each signpost's arrow board points along its facing.
	signs = {
		{ at = p(-136, -12), faces = 270, lines = { "← Route A · Clover Lane" } },
		{ at = p(136, -12), faces = 90, lines = { "River Road · Gatehouse →" } },
		{
			at = p(-10, -30),
			faces = 180,
			lines = { "↑ Mentor's Cottage", "↓ Brightwater House, Tuppence's Shop" },
		},
		-- The plan gives SP4 no facing; it points west along the shut wicket, read from town.
		{ at = p(104, -142), faces = 270, lines = { "The Hollow path. Shut." } },
		{ at = p(-196, 10), faces = 60, lines = { "Long grass:", "wild creatures hide here" } },
		{ at = p(426, -87), faces = 330, lines = { "Hollowbough's Hollow", "Hollow Stall" } },
		{ at = p(600, -66), faces = 270, lines = { "Greenwood Gatehouse", "badge challenge" } },
	},
	lamps = {
		-- The main street.
		p(-120, -11),
		p(-90, 11),
		p(-46, 11),
		p(46, -11),
		p(90, 11),
		p(120, -11),
		-- The plaza.
		p(-22, -22),
		p(22, -22),
		p(-22, 22),
		p(22, 22),
		-- The north lane.
		p(-7, -46),
		p(7, -46),
		-- Either side of each arch.
		p(-142, -11),
		p(-142, 11),
		p(142, -11),
		p(142, 11),
		-- Orchard Row.
		p(-7, 66),
		p(7, 98),
		p(-40, 98),
		-- The gatehouse hamlet.
		p(590, -66),
		p(640, -94),
		p(664, -66),
	},
	beds = {
		p(-72, 30),
		p(-56, 30),
		p(-34, 30),
		p(-18, 30),
		p(-11.6, -32),
		p(11.6, -32),
		p(-11.6, 32),
		p(11.6, 32),
		p(-7, -56),
		p(7, -56),
	},

	trees = {
		-- A wall of tall trees behind the gatehouse, either side of the sealed road, so the next
		-- land cannot be seen until the road is opened.
		tree(718, -172, "Pine", 2.2),
		tree(722, -150, "Tree", 2),
		tree(716, -128, "Pine", 2.4),
		tree(724, -108, "Tree", 2.1),
		tree(718, -52, "Tree", 2.1),
		tree(724, -32, "Pine", 2.4),
		tree(716, -10, "Tree", 2),
		tree(722, 12, "Pine", 2.2),
		tree(738, -162, "Tree", 2.3),
		tree(742, -138, "Pine", 2.5),
		tree(738, -112, "Tree", 2.2),
		tree(742, -48, "Pine", 2.5),
		tree(738, -22, "Tree", 2.3),
		tree(742, 4, "Pine", 2.2),
		-- The orchard behind the mentor's cottage.
		tree(-24, -112),
		tree(0, -118),
		tree(24, -112),
		tree(-12, -130),
		tree(12, -130),
		tree(36, -128),
		-- By the pond.
		tree(-130, 100),
		tree(-122, 124),
		tree(-70, 112),
		-- West of the plaza.
		tree(-100, -30),
		tree(-112, -48),
		-- The breeder's yard.
		tree(110, -100),
		tree(132, -104),
		-- By the Ring.
		tree(110, 90),
		tree(100, 120),
	},
	rows = {
		-- The north belt, with a gap for the wicket at x 104 to 116.
		row(-150, -140, -40, -140, "Pine"),
		row(-150, -125, -40, -125, "Pine"),
		row(40, -140, 96, -140, "Pine"),
		row(40, -125, 96, -125, "Pine"),
		row(124, -140, 150, -140, "Pine"),
		row(124, -125, 150, -125, "Pine"),
		-- The south belt, stopping short of the river.
		row(-60, 135, 110, 135, "Pine"),
		row(-60, 148, 110, 148, "Pine"),
	},

	fences = {
		-- The breeder's yard, its gate gap at x 112 to 120 on the south side.
		{
			points = { p(112, -40), p(98, -40), p(98, -90), p(138, -90), p(138, -40), p(120, -40) },
			style = "Picket",
		},
		-- The mentor's vegetable patch, its gap on the west side.
		{
			points = { p(18, -82), p(18, -74), p(40, -74), p(40, -100), p(18, -100), p(18, -92) },
			style = "Picket",
		},
		-- The shut wicket in the town hedge, on the lair shortcut.
		{ points = { p(104, -150), p(116, -150) }, style = "Gate", across = true },
		-- The old fence across the end of Route A, with a broken stile in the middle.
		{ points = { p(-283.5, -54.5), p(-270, -47) }, style = "Rustic", across = true },
		-- A low stone wall each side of the lane through the hamlet (along 560 to 600).
		{ points = { p(644.4, -70), p(684, -70) }, style = "Stone" },
		{ points = { p(644.4, -90), p(684, -90) }, style = "Stone" },
	},
	-- The town hedge at ±150, broken at the arches (z ±14) and the wicket (x 104 to 116). Where
	-- the brook or the river crosses it, the builder stops it short and lays a low rail.
	hedges = {
		{ p(-150, -9), p(-150, -150), p(104, -150) },
		{ p(116, -150), p(150, -150), p(150, -9) },
		{ p(150, 9), p(150, 150), p(-150, 150), p(-150, 9) },
	},

	buildings = {
		mentor_cottage = { width = 26, depth = 27, tall = 26 },
		shop = { width = 22, depth = 17, tall = 26 },
		healer = { width = 18, depth = 19, tall = 26 },
		waystation = { width = 20, depth = 20, tall = 40 },
		breeder = { width = 26, depth = 27, tall = 26 },
		notice_oak = { width = 5, depth = 5, tall = 34 }, -- the trunk; the crown is 30 across
		ring = { width = 40, depth = 30, tall = 0.4 },
	},
	houses = {
		{ at = p(645, -130), faces = 180, model = "Cottage", width = 26, depth = 27, tall = 26 },
		{ at = p(650, -36), faces = 0, model = "Cottage", width = 26, depth = 27, tall = 26 },
		-- Orchard Row, facing the plaza, and one cottage by the east arch.
		{ at = p(-34, 120), faces = 0, model = "CottageBlue", width = 24, depth = 18, tall = 22 },
		{ at = p(4, 126), faces = 0, model = "CottageMoss", width = 24, depth = 24, tall = 22 },
		{ at = p(44, 120), faces = 0, model = "Cottage", width = 22, depth = 23, tall = 22 },
		{ at = p(118, -32), faces = 180, model = "CottageBlue", width = 24, depth = 18, tall = 22 },
	},
	props = {
		{ model = "AppleCart", at = p(-45, 17), faces = 0, tall = 9, solid = true },
		{ model = "Barrels", at = p(-8, 50), faces = 0, tall = 6.5, solid = true },
		{ model = "WashingLine", at = p(24, 132), faces = 0, tall = 8 },
		{ model = "WashingLine", at = p(96, -34), faces = 180, tall = 8 },
		{ model = "Barrels", at = p(62, 116), faces = 300, tall = 6, solid = true },
		-- The orchard between Orchard Row and the Ring.
		{ model = "AppleTree", at = p(72, 100), faces = 20, tall = 17, solid = true },
		{ model = "AppleTree", at = p(92, 112), faces = 140, tall = 19, solid = true },
		{ model = "AppleTree", at = p(112, 98), faces = 250, tall = 16, solid = true },
		{ model = "AppleTree", at = p(100, 132), faces = 80, tall = 18, solid = true },
		{ model = "AppleTree", at = p(124, 124), faces = 200, tall = 17, solid = true },
		{ model = "AppleTree", at = p(-64, 116), faces = 320, tall = 18, solid = true },
	},
	people = {
		{ name = "Child", at = p(-80, 74), faces = 225, model = "GirlTamer" },
		{ name = "Gardener", at = p(28, -88), faces = 270, model = "Tamer" },
		{ name = "Neighbour", at = p(18, 112), faces = 315, model = "Carer" },
		{ name = "Picker", at = p(84, 104), faces = 90, model = "Grandmother" },
	},

	picnic = { at = p(-290, 112), radius = 14 },
	clearings = {
		{ at = p(277, -293), radius = 76, ring = true }, -- the Hollow, round its bowl
	},
	caps = {
		greenwood_route_a = 7, -- the old fence fills the middle
		greenwood_route_b = 20, -- the gatehouse fills the middle
	},
	corridorTrees = {
		birch_rise = { model = "Birch", scale = 1 },
		old_wood = { model = "Tree", scale = 1.3 },
	},
	gatehouse = { at = p(684, -80), faces = 270 },
	bar = { at = p(697, -80), width = 20 }, -- where the sealed road's story beat fires (48 from its place)
	ancientTree = { at = p(270, -362), tall = 160 },
	stall = { side = 1 },
	ring = { width = 40, depth = 30, gap = 12 },
	brambles = {},
	coop = p(126, -70),
	patch = { from = p(22, -96), to = p(36, -78) },

	-- How each tier looks: grassy banks for the gentle rises, painted cliff under the high ground.
	-- Tiers that touch at one height share a top colour, so no seam shows.
	tierLooks = {
		clover_terrace = { top = MEADOW, face = "Earth" },
		spring_plateau = { top = MOSS, face = "Earth" },
		birch_switchback_a = { top = BIRCH, face = "Earth" },
		birch_switchback_b = { top = BIRCH, face = "Earth" },
		birch_nook = { top = BIRCH, face = "Earth" },
		birch_shelf = { top = BIRCH, face = "Earth" },
		steps_landing = { top = BIRCH, face = "Earth" },
		ridge_brink = { top = RIDGE, face = "Earth" },
		ridge_a = { top = RIDGE, face = "Earth" },
		wood_a = { top = RIDGE, face = "Earth" },
		wood_b = { top = RIDGE, face = "Earth" },
		wood_c = { top = RIDGE, face = "Earth" },
		wood_head = { top = RIDGE, face = "Earth" },
		wood_glade = { top = RIDGE, face = "Earth" },
		burl_clearing = { top = RIDGE, face = "Earth" },
		spur_a = { top = RIDGE, face = "Earth" },
		spur_b = { top = RIDGE, face = "Earth" },
		spur_c = { top = RIDGE, face = "Earth" },
		spur_d = { top = RIDGE, face = "Earth" },
		hollow_bowl = { top = MOSS, face = "Earth" },
	},

	-- Solid woods close in everything past the edges (docs/plans/12_MAP_STRUCTURE.md, step 1).
	fill = { style = "Forest", band = 80, floor = { 70, 118, 58 } },

	-- Smoke from the cottages' chimneys, a warm glow on each lamp, pollen and seed fluff over the
	-- meadows, a glint on the pools and the pond. Chimney offsets measured from above in Studio
	-- (23 November 2026); the moss cottage has no chimney.
	ambience = {
		chimneys = {
			Cottage = { -0.27, 1.0, 0.03 }, -- the stone stack on its left side
			CottageBlue = { -0.22, 1.0, 0.01 }, -- the clay pot on its left side
		},
		-- The mentor's and the breeder's cottages stand in the hub.
		smokeHouses = {
			{ at = p(0, -82), faces = 180, model = "Cottage", width = 26, depth = 27, tall = 26 },
			{ at = p(82, -64), faces = 225, model = "Cottage", width = 26, depth = 27, tall = 26 },
		},
		lamps = { range = 22, brightness = 1.1, colour = { 255, 206, 140 } },
		glints = true,
		sources = {
			-- Pollen over the meadows beside the lane.
			{ kind = "Pollen", at = p(-190, 38), height = 4, area = { 50, 50, 6 } },
			{ kind = "Pollen", at = p(-330, 70), height = 4, area = { 70, 60, 6 } },
			{ kind = "Pollen", at = p(220, 6), height = 4, area = { 90, 60, 6 } },
			-- Seed fluff on the breeze: the birch rise, the orchard and the clover meadow.
			{ kind = "Fluff", at = p(262, -22), height = 15, area = { 50, 50, 8 } },
			{ kind = "Fluff", at = p(95, 112), height = 5, area = { 70, 50, 8 } },
			{ kind = "Fluff", at = p(-300, 62), height = 5, area = { 80, 50, 8 } },
		},
	},

	-- Small clay detail on the lawns and verges (src/shared/DetailPlan.luau): clover and
	-- meadow flowers, little tufts and a few bushes; pebbles fringe the lanes.
	scatter = {
		budget = 540,
		kinds = {
			{
				id = "lawn_blooms",
				shape = "Blooms",
				zone = "Town",
				density = 14,
				count = { 2, 3 },
				tall = { 0.8, 1.1 },
				colours = {
					{ 250, 226, 100 },
					{ 250, 250, 244 },
					{ 240, 140, 160 },
					{ 176, 148, 236 },
				},
			},
			{
				id = "lawn_tufts",
				shape = "Model",
				zone = "Town",
				density = 16,
				model = "GrassTuft",
				tall = { 1.3, 1.9 },
				colours = { { 255, 255, 255 } },
			},
			{
				id = "verge_blooms",
				shape = "Blooms",
				zone = "Verge",
				density = 64,
				count = { 2, 4 },
				tall = { 0.8, 1.1 },
				colours = {
					{ 250, 226, 100 },
					{ 250, 250, 244 },
					{ 240, 140, 160 },
					{ 176, 148, 236 },
				},
			},
			{
				id = "verge_tufts",
				shape = "Model",
				zone = "Verge",
				density = 48,
				model = "GrassTuft",
				tall = { 1.5, 2.3 },
				colours = { { 255, 255, 255 } },
			},
			{
				id = "verge_bushes",
				shape = "Model",
				zone = "Verge",
				density = 4.8,
				model = "Bush",
				tall = { 1.6, 2.4 },
				colours = { { 255, 255, 255 } },
			},
			{
				id = "lane_pebbles",
				shape = "Pebbles",
				zone = "Edging",
				density = 112,
				count = { 1, 3 },
				tall = { 0.5, 0.9 },
				colours = { { 170, 160, 140 }, { 150, 142, 128 }, { 190, 180, 160 } },
			},
		},
	},
}

return GreenwoodDressing
