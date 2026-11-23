--!strict
-- Greenwood's map sheet: where the designer put the routes, buildings, people and patches of long
-- grass. Studs from the centre of Thistledown; north is -z, east is +x. Facings are degrees
-- clockwise from north. Data only: the routes and the levels they climb are from
-- docs/plans/12_MAP_STRUCTURE.md section 5 (the town is docs/plans/08_GREENWOOD_MAP.md section 3).
--
-- Places the sheet leaves out (each stretch's middle, a route's entry, the gate, the sealed road,
-- the lair and its stall) are still worked out by Layout from the fitted lines, so every distance
-- along a route in the biome data keeps its meaning.
--
-- Long on purpose: every tier, link and room is a line of data that the tests (ground.test,
-- walk.test, layout.test) check against the lanes and places.

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

local Greenwood: WorldTypes.MapSheet = {
	routes = {
		-- Clover Lane: out of the west neck, a bend round Pip, into the clover meadow, up the
		-- stairs to the terrace, back east beside the brook to the old fence. An S that climbs.
		greenwood_route_a = {
			points = {
				p(-150, 0),
				p(-200, -5),
				p(-235, 25),
				p(-270, 55),
				p(-340, 60),
				p(-370, 30),
				p(-360, -15),
				p(-290, -25),
				p(-275, -52),
			},
		},
		-- River Road: east along the river bank, a ramp up the switchback, a second to the ridge,
		-- through the old wood, down the steps and a ramp to the hamlet and the gate.
		greenwood_route_b = {
			points = {
				p(150, 0),
				p(205, 13.94),
				p(260, 18),
				p(295, 0),
				p(290, -29),
				p(330, -62),
				p(385, -72),
				p(420, -95),
				p(468, -108),
				p(515, -98),
				p(556, -84),
				p(600, -80),
				p(684, -80),
			},
		},
	},

	-- The widest half-width of each stretch: how far the hedges or tree lines may stand from the
	-- middle of the lane. The lanes themselves are narrower and vary: see `widths`.
	corridor = {
		mossy_glade = 14,
		clover_meadow = 18,
		brook_bend = 18,
		sandy_bank = 22,
		birch_rise = 21,
		old_wood = 21,
		gatehouse_approach = 20,
		greenwood_lair = 10,
	},

	-- The spur to Hollowbough's Hollow leaves River Road at 330 along, runs along the ridge's
	-- tier and goes down steps into the Hollow's bowl.
	spurs = {
		greenwood_lair = { p(420, -95), p(405, -150), p(368, -188), p(338, -230), p(277, -293) },
	},

	-- Half the lane's width, by distance along (the plan's section 5 tables).
	widths = {
		greenwood_route_a = {
			key(0, 9),
			key(36, 9),
			key(50, 14),
			key(120, 14),
			key(135, 18),
			key(250, 18),
			key(256, 6),
			key(294, 6),
			key(306, 16),
			key(322, 16),
			key(328, 8),
			key(334, 8),
			key(340, 16),
			key(372, 16),
			key(400, 10),
		},
		greenwood_route_b = {
			key(0, 9),
			key(36, 9),
			key(44, 22),
			key(122, 22),
			key(128, 7),
			key(152, 7),
			key(156, 14),
			key(204, 14),
			key(208, 7),
			key(236, 7),
			key(242, 21),
			key(320, 21),
			key(332, 12),
			key(466, 12),
			key(470, 6),
			key(494, 6),
			key(497, 14),
			key(499, 14),
			key(501, 7),
			key(521, 7),
			key(526, 20),
			key(600, 20),
		},
		greenwood_lair = {
			key(0, 10),
			key(250, 10),
		},
	},

	buildings = {
		mentor_cottage = { at = p(0, -82), faces = 180, door = p(0, -64), model = "Cottage" },
		shop = { at = p(-26, 46), faces = 0, door = p(-26, 32), model = "Shop" },
		healer = { at = p(-64, 46), faces = 0, door = p(-64, 31), model = "Healer" },
		waystation = { at = p(-80, -62), faces = 135, door = p(-68.7, -50.7), model = "Waystation" },
		breeder = { at = p(82, -64), faces = 225, door = p(69.3, -51.3), model = "Cottage" },
		notice_oak = { at = p(-50, -14), faces = 90, door = p(-36, -14), model = "Tree" },
		ring = { at = p(78, 58), faces = 315, door = p(62, 42) },
	},

	-- Levels: tiers 10 studs apart (taller than a jump), later tiers winning where they overlap.
	tiers = {
		-- Route A: the terrace the meadow stairs climb to, and the spring plateau above it.
		{ id = "clover_terrace", height = 10, shape = box(-395, -75, -258, 8) },
		{ id = "spring_plateau", height = 20, shape = box(-395, -170, -230, -75) },
		-- Route B: the switchback, its nook, the ridge and the old wood, the spur, the shelf, the
		-- landing below the steps, and the Hollow's bowl last so that it wins where it overlaps.
		{ id = "birch_switchback_a", height = 10, shape = strip(296, -2, 290, -29, 16) },
		{ id = "birch_switchback_b", height = 10, shape = strip(290, -29, 318, -50, 22) },
		{ id = "birch_nook", height = 10, shape = disc(262, -22, 30) },
		{ id = "ridge_brink", height = 20, shape = box(326, -95, 396, -43) },
		{ id = "ridge_a", height = 20, shape = strip(385, -72, 420, -95, 20) },
		{ id = "wood_a", height = 20, shape = strip(420, -95, 468, -108, 20) },
		{ id = "wood_b", height = 20, shape = strip(468, -108, 515, -98, 20) },
		{ id = "wood_c", height = 20, shape = strip(515, -98, 538, -91.5, 20) },
		{ id = "wood_head", height = 20, shape = box(536, -106, 558, -66) },
		{ id = "wood_glade", height = 20, shape = disc(500, -76, 30) },
		{ id = "burl_clearing", height = 20, shape = disc(489, -126, 24) },
		{ id = "spur_a", height = 20, shape = strip(420, -95, 405, -150, 14) },
		{ id = "spur_b", height = 20, shape = strip(405, -150, 368, -188, 14) },
		{ id = "spur_c", height = 20, shape = strip(368, -188, 338, -230, 14) },
		{ id = "spur_d", height = 20, shape = strip(338, -230, 336, -232, 16) },
		{ id = "birch_shelf", height = 10, shape = box(344, -43, 420, -20) },
		{ id = "steps_landing", height = 10, shape = box(558, -100, 592, -62) },
		{ id = "hollow_bowl", height = 10, shape = disc(277, -293, 76) },
	},

	-- Stairs and ramps run from their low end to their high end (heights come from the tiers under
	-- the ends); a ledge is a stretch of lip, high ground on the left as you walk from `from`.
	links = {
		link("meadow_stairs", "Stairs", p(-369.3, 27), p(-364.9, 7.5), 12),
		link("terrace_ledge", "Ledge", p(-322, 8), p(-272, 8), 8),
		link("birch_ramp_1", "Ramp", p(276.3, 9.6), p(294.2, 0.4), 14),
		link("birch_ramp_2", "Ramp", p(312.8, -47.8), p(328.1, -60.4), 14),
		link("ridge_ledge", "Ledge", p(346, -43), p(394, -43), 8),
		link("shelf_ledge", "Ledge", p(350, -20), p(414, -20), 8),
		link("wood_steps", "Stairs", p(577, -82), p(557, -83.8), 12),
		link("hamlet_ramp", "Ramp", p(604.7, -80), p(584.5, -81.5), 14),
		link("hollow_steps", "Stairs", p(321.3, -247.2), p(335.2, -232.9), 12),
	},

	-- Walkable space beside the lanes: pockets, fields, clearings and the dead ends.
	rooms = {
		-- Route A.
		{ id = "glade_pocket", shape = disc(-188, 32, 26) },
		{ id = "ledge_lane", shape = box(-340, 9, -236, 20) },
		{ id = "clover_south", shape = strip(-345, 86, -318, 92, 25) },
		{ id = "picnic_connector", shape = box(-295, 70, -285, 100) },
		{ id = "picnic_hollow", shape = disc(-290, 112, 14) },
		-- The apple nook (plan 14): a small hollow behind the meadow's south-west wall, reached by a
		-- narrow hidden gap with nothing pointing to it.
		{ id = "apple_gap", shape = strip(-371.6, 42.6, -388.5, 59.5, 3) },
		{ id = "apple_nook", shape = disc(-395.6, 66.6, 16) },
		{ id = "terrace_brink", shape = box(-322, -12, -272, 7) },
		{ id = "brook_glade", shape = disc(-358, -48, 22) },
		{ id = "reed_nook", shape = disc(-300, -42, 14) },
		-- Route B.
		{ id = "bank_north", shape = disc(200, -12, 26) },
		{ id = "heron_inlet", shape = disc(231, 40, 14) },
		{ id = "bank_link", shape = strip(262, 32, 335, 32, 8) },
		{ id = "bank_east", shape = box(330, -19, 426, 36) },
		{ id = "birch_nook_room", shape = disc(262, -22, 26) },
		{ id = "ridge_brink_room", shape = box(340, -60, 392, -43) },
		{ id = "shelf_room", shape = box(346, -42, 418, -21) },
		{ id = "burl_room", shape = disc(489, -126, 16) },
		{ id = "wood_glade_room", shape = disc(500, -76, 26) },
		{ id = "hamlet_pocket", shape = disc(619, -106, 26) },
	},

	-- Patches of long grass besides each stretch's own (the place `{stretch}_grass`).
	grass = {
		sandy_bank = { { at = p(226, 24), r = 10 } },
		clover_meadow = { { at = p(-318, 92), r = 14 } },
		birch_rise = { { at = p(380, 8), r = 14 } },
	},

	places = {
		-- Long grass: in the pockets and rooms beside the lane, never on a tamer.
		mossy_glade_grass = p(-190, 38),
		clover_meadow_grass = p(-342, 84),
		brook_bend_grass = p(-358, -46),
		sandy_bank_grass = p(200, -12),
		birch_rise_grass = p(262, -22),
		old_wood_grass = p(500, -76),
		gatehouse_approach_grass = p(619, -106),
		-- Rustle spots.
		reed_bed = p(-300, -42),
		heron_pool = p(231, 43),
		burl_thicket = p(489, -128),
		-- Tamers, at bends and narrow points, facing the way players arrive.
		gw_pip = p(-228, 33),
		gw_wren = p(-329, -19),
		gw_odette = p(262, 26),
		gw_basil = p(346, -71),
		gw_corwin = p(541, -91.5),
	},

	-- The rival stands in the plaza for the first battle and in the mouth of the gatehouse arch
	-- for the second. Each is within the server's slack (8) of its place, so wherever his prompt
	-- shows, the server accepts the request.
	stands = {
		rival_first = p(0, -6),
		rival_gate = p(678, -80),
	},

	faces = {
		gw_pip = 60,
		gw_wren = 270,
		gw_odette = 250,
		gw_basil = 225,
		gw_corwin = 250,
		rival_first = 180,
		rival_gate = 270,
	},

	-- Arrive in the square facing north: the rival, the mentor's door and the ancient tree ahead.
	spawn = { at = p(0, 14), faces = 0 },
}

return Greenwood
