--!strict
-- The Mire's map sheet: Sedgeholm on its duckboards, the Duckboard Trail (Route A), the Cypress
-- Road (Route B), the spur to the Sunken Grove and the Heron Causeway in from Tide Flats. Studs
-- from the centre of Sedgeholm, which Biome.site puts at world (3100, -550); north is -z, east is
-- +x. Facings are degrees clockwise from north. Data only: the design is
-- docs/plans/15_MIRE_MAP.md, built the way Tide Flats' sheet is (docs/plans/10_TIDE_FLATS_MAP.md).
--
-- Places the sheet leaves out (each stretch's middle, a route's entry, the gate, the sealed road,
-- the lair and its stall) are worked out by Layout from the fitted lines, so every distance along
-- a route in the biome data keeps its meaning. Route B's last leg runs due north and ends at
-- (150, -602): the Rimewater Gorge goes on from there (docs/plans/13_WORLD_DESIGN.md section 4).
--
-- Heights are whole tiers of 10. Long on purpose: every tier, link and room is a line of data
-- that the tests (ground.test, walk.test, layout.test) check.

local WorldTypes = require("../../shared/WorldTypes")

local function p(x: number, z: number): WorldTypes.SheetPoint
	return { x = x, z = z }
end

-- A box from one corner to the other, as the sheet's Box shape.
local function box(x0: number, z0: number, x1: number, z1: number): WorldTypes.Shape
	return { kind = "Box", at = p((x0 + x1) / 2, (z0 + z1) / 2), size = { x1 - x0, z1 - z0 } }
end

local function disc(x: number, z: number, r: number): WorldTypes.Shape
	return { kind = "Disc", at = p(x, z), r = r }
end

local function strip(x0: number, z0: number, x1: number, z1: number, r: number): WorldTypes.Shape
	return { kind = "Strip", from = p(x0, z0), to = p(x1, z1), r = r }
end

local function key(at: number, half: number): WorldTypes.WidthKey
	return { at = at, half = half }
end

local function link(
	id: string,
	kind: "Stairs" | "Ramp" | "Ledge",
	from: WorldTypes.SheetPoint,
	to: WorldTypes.SheetPoint,
	width: number
): WorldTypes.Link
	return { id = id, kind = kind, from = from, to = to, width = width }
end

-- Route A: east out of Sedgeholm along the reedfringe, south-east through the lily channels and
-- the mangrove roots, to the rope ferry.
local A: { WorldTypes.SheetPoint } = {
	p(150, 30),
	p(205, 18),
	p(262, 44),
	p(322, 34),
	p(368, 80),
	p(350, 142),
	p(396, 186),
	p(452, 176),
	p(500, 208),
	p(511, 212),
}

-- Route B: north out of Sedgeholm, in a long S through the peat cuttings, the stilt hamlet and
-- the fogwater, then east and due north up the sluice rise to the gate.
local B: { WorldTypes.SheetPoint } = {
	p(20, -150),
	p(60, -205),
	p(30, -262),
	p(80, -310),
	p(60, -375),
	p(110, -420),
	p(60, -470),
	p(-10, -505),
	p(35, -548),
	p(95, -528),
	p(150, -555),
	p(150, -602),
}

local Mire: WorldTypes.MapSheet = {
	routes = {
		-- Duckboard Trail: reedfringe duckboards, lily channels, mangrove roots, a rope ferry.
		mire_route_a = { points = A },
		-- Cypress Road: peat cuttings, an empty stilt hamlet, the fogwater, the sluice rise.
		mire_route_b = { points = B },
	},

	-- The widest half-width of each stretch (see `widths` for the lanes themselves).
	corridor = {
		reedfringe = 14,
		lily_lanes = 17,
		mangrove_tangle = 21,
		peat_cuttings = 14,
		stilt_hamlet = 19,
		fogwater_reach = 22,
		sluice_rise = 20,
		mire_lair = 10,
	},

	-- The spur to the Sunken Grove forks west at 440 along the Cypress Road. Its first point is
	-- the computed join, which Layout drops as a leg of no length.
	spurs = {
		mire_lair = {
			p(31.1, -484.4),
			p(-20, -452),
			p(-90, -442),
			p(-150, -410),
			p(-210, -418),
			p(-229, -426),
		},
	},

	widths = {
		mire_route_a = {
			key(0, 9),
			key(36, 9),
			key(48, 13),
			key(100, 13),
			key(108, 9),
			key(136, 9),
			key(150, 13),
			key(166, 17),
			key(210, 17),
			key(222, 12),
			key(250, 12),
			key(262, 16),
			key(300, 16),
			key(320, 12),
			key(336, 13),
			key(392, 13),
			key(398, 9),
			key(412, 9),
			key(420, 13),
			key(470, 13),
			key(486, 16),
			key(500, 21),
		},
		mire_route_b = {
			key(0, 9),
			key(36, 9),
			key(46, 12),
			key(90, 12),
			key(98, 9),
			key(124, 9),
			key(134, 14),
			key(190, 14),
			key(204, 19),
			key(238, 19),
			key(250, 12),
			key(292, 12),
			key(304, 17),
			key(348, 17),
			key(362, 22),
			key(390, 22),
			key(398, 12),
			key(430, 12),
			key(446, 18),
			key(526, 20),
			key(540, 12),
			key(600, 12),
			key(606, 10),
			key(634, 10),
			key(642, 13),
			key(700, 13),
			key(720, 20),
		},
		mire_lair = {
			key(0, 9),
			key(120, 9),
			key(130, 7),
			key(200, 7),
			key(214, 10),
			key(280, 10),
		},
	},

	buildings = {
		-- The village square is the Bell Cypress; its shops and doors stand round it on the
		-- duckboards, the Bell Loft up on its own deck to the north-west.
		quill_sundries = { at = p(56, -30), faces = 270, door = p(40, -30), model = "Chandlery" },
		clearwater_spring = { at = p(-70, -26), faces = 90, door = p(-54, -26), model = "Healer" },
		reed_nursery = { at = p(-88, 30), faces = 90, door = p(-72, 30), model = "ReedHut" },
		mooring_post = { at = p(-14, -70), faces = 180, door = p(-14, -54), model = "NoticeBoard" },
		punt_landing = { at = p(-76, 84), faces = 90, door = p(-60, 84), model = "Waystation" },
		-- A round of boards and a rope rail round the cypress knees; no painted model.
		cypress_ring = { at = p(92, -90), faces = 225, door = p(80.7, -78.7) },
		bell_loft = { at = p(-84, -96), faces = 180, door = p(-84, -80), model = "LampTower" },
	},

	-- Levels, tiers 10 studs apart (taller than a jump), later tiers winning where they overlap.
	tiers = {
		-- Sedgeholm: the Bell Loft's deck, the one raised platform in the village.
		{ id = "bell_deck", height = 10, shape = box(-120, -126, -48, -66) },
		-- Route A: a mangrove root shelf above the lily channels, and the boardwalk level over the
		-- roots at the end of the trail.
		{ id = "lily_shelf", height = 10, shape = box(292, 84, 338, 124) },
		{ id = "tangle_deck", height = 10, shape = box(480, 176, 545, 246) },
		-- Route B: the raised boardwalk of the old stilt hamlet, and the peat bank under the gate.
		{ id = "hamlet_deck", height = 10, shape = box(30, -440, 140, -340) },
		{ id = "sluice_bank", height = 10, shape = box(100, -700, 200, -580) },
	},

	-- Stairs and ramps run from their low end to their high end (heights come from the tiers under
	-- the ends); a ledge is a stretch of lip, high ground on the left as you walk from `from`.
	links = {
		link("bell_stairs", "Stairs", p(-56, -46), p(-56, -72), 10),
		link("bell_ledge", "Ledge", p(-48, -100), p(-48, -116), 8),
		link("shelf_stairs", "Stairs", p(352, 104), p(328, 104), 10),
		link("shelf_ledge", "Ledge", p(292, 98), p(292, 114), 8),
		link("tangle_ramp", "Ramp", p(459, 181), p(482, 196.4), 14),
		link("tangle_ledge", "Ledge", p(530, 176), p(514, 176), 8),
		link("hamlet_ramp", "Ramp", p(73.8, -331), p(68.3, -350), 14),
		link("hamlet_stairs", "Stairs", p(83, -447), p(97, -433), 12),
		link("hamlet_ledge", "Ledge", p(140, -380), p(140, -396), 8),
		link("sluice_stairs", "Stairs", p(150, -566), p(150, -590), 12),
		link("sluice_ledge", "Ledge", p(100, -640), p(100, -624), 8),
	},

	-- Walkable space beside the lanes: pockets, dead ends and the Heron Causeway.
	rooms = {
		-- The Heron Causeway: in from Tide Flats' sealed road (world (2866, -70), here (-234, 480))
		-- to Sedgeholm's south arch, a stilted boardwalk with water both sides.
		{ id = "causeway_1", shape = strip(-234, 480, -150, 440, 9) },
		{ id = "causeway_2", shape = strip(-150, 440, -110, 340, 9) },
		{ id = "causeway_3", shape = strip(-110, 340, -60, 250, 9) },
		{ id = "causeway_4", shape = strip(-60, 250, -20, 190, 9) },
		{ id = "causeway_5", shape = strip(-20, 190, 0, 150, 9) },
		-- Route A.
		{ id = "reed_pocket", shape = disc(244, -10, 32) },
		{ id = "reed_blind", shape = disc(204, 70, 14) },
		{ id = "reed_blind_way", shape = strip(204, 28, 204, 62, 7) },
		{ id = "lily_pocket", shape = disc(377, 29, 32) },
		{ id = "shelf_top", shape = box(292, 88, 338, 120) },
		{ id = "shelf_step", shape = box(334, 98, 350, 110) },
		{ id = "shelf_drop", shape = box(268, 94, 292, 122) },
		{ id = "shelf_way_a", shape = strip(276, 98, 300, 58, 7) },
		{ id = "shelf_way_b", shape = strip(300, 58, 318, 50, 7) },
		{ id = "pool_pocket", shape = disc(388, 104, 16) },
		{ id = "mangrove_pocket", shape = disc(350, 200, 32) },
		{ id = "bell_way", shape = strip(400, 196, 404, 250, 7) },
		{ id = "bell_landing", shape = disc(406, 262, 16) },
		{ id = "hummock_pocket", shape = disc(466, 154, 16) },
		{ id = "deck_path", shape = strip(500, 158, 470, 156, 7) },
		{ id = "deck_drop", shape = box(496, 152, 532, 176) },
		{ id = "deck_brink", shape = box(496, 176, 536, 200) },
		-- Route B.
		{ id = "peat_pocket", shape = disc(87, -244, 32) },
		{ id = "cutting_way", shape = strip(46, -218, -8, -220, 7) },
		{ id = "cutting_room", shape = box(-44, -236, -8, -204) },
		{ id = "hamlet_pocket", shape = disc(-5, -372, 32) },
		{ id = "hamlet_way_a", shape = strip(72, -318, 30, -338, 7) },
		{ id = "hamlet_way_b", shape = strip(30, -338, 2, -352, 7) },
		{ id = "hamlet_balcony", shape = box(112, -402, 140, -374) },
		{ id = "hamlet_shore", shape = box(140, -402, 176, -374) },
		{ id = "shore_way_a", shape = strip(165, -380, 160, -334, 7) },
		{ id = "shore_way_b", shape = strip(160, -334, 90, -320, 7) },
		{ id = "fog_pocket", shape = disc(-29, -545, 32) },
		{ id = "sinkhole_pocket", shape = disc(16, -521, 16) },
		{ id = "sluice_pocket", shape = disc(69, -581, 32) },
		{ id = "sluice_shore", shape = box(62, -646, 100, -612) },
		{ id = "sluice_brink", shape = box(100, -646, 142, -612) },
		-- The spur.
		{ id = "grove_nook", shape = disc(-122, -462, 14) },
		{ id = "grove_nook_way", shape = strip(-118, -432, -122, -456, 7) },
	},

	-- Patches of long grass besides each stretch's own (the place `{stretch}_grass`).
	grass = {
		reedfringe = { { at = p(204, 70), r = 8 } },
		peat_cuttings = { { at = p(-26, -220), r = 8 } },
	},

	places = {
		-- Long grass, each in a pocket beside the lane (the stretch's own patch is its centre).
		reedfringe_grass = p(244, -10),
		lily_lanes_grass = p(377, 29),
		mangrove_tangle_grass = p(350, 200),
		peat_cuttings_grass = p(87, -244),
		stilt_hamlet_grass = p(-5, -372),
		fogwater_reach_grass = p(-29, -545),
		sluice_rise_grass = p(69, -581),
		-- Rustle spots.
		bubbling_pool = p(388, 104),
		steaming_hummock = p(466, 154),
		sinkhole = p(16, -521),
		-- Tamers, facing the way players arrive (the pinch points of each route).
		mr_wren = p(262, 36),
		mr_marisol = p(421, 173),
		mr_barnaby = p(33, -238),
		mr_ysolde = p(60, -459),
		mr_cuthbert = p(99, -539),
	},

	-- The rival stands on the hamlet's deck; the sluice keeper stands before her gate.
	stands = {
		rival_mire = p(62, -372),
		champion_vell = p(150, -596),
	},

	faces = {
		mr_wren = 283,
		mr_marisol = 264,
		mr_barnaby = 141,
		mr_ysolde = 124,
		mr_cuthbert = 268,
		rival_mire = 163,
		champion_vell = 180,
	},

	-- Where players arrive from Tide Flats, up the Heron Walk from the south arch, facing the
	-- Bell Cypress. Only the first biome's spawn is built; this one is a record for the tests.
	spawn = { at = p(0, 128), faces = 0 },
}

return Mire
