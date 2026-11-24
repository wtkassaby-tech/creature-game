--!strict
-- Dust Canyon's map sheet: where the designer put Kilnrest, the Dry Wash Trail, the Mesa Road and
-- the spur to Mesalith's Shelf, and the levels they climb. Studs from the centre of Kilnrest;
-- north is -z, east is +x. Facings are degrees clockwise from north. Data only: the routes, the
-- tiers and the links are from docs/plans/12_MAP_STRUCTURE.md section 6 (the town is
-- docs/plans/09_DUST_CANYON_MAP.md section 3a), built the way Greenwood's are.
--
-- Places the sheet leaves out (each stretch's middle, a route's entry, the gate, the sealed road,
-- the lair and its stall) are worked out by Layout from the fitted lines, so every distance along
-- a route in the biome data keeps its meaning. Route B's last leg runs due east and ends at
-- (779, -100): Tide Flats is sited from it (plan 10), so it must not change on its own.
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

-- The point `t` of the way from one point to another.
local function lerp(
	a: WorldTypes.SheetPoint,
	b: WorldTypes.SheetPoint,
	t: number
): WorldTypes.SheetPoint
	return p(
		math.floor((a.x + (b.x - a.x) * t) * 10 + 0.5) / 10,
		math.floor((a.z + (b.z - a.z) * t) * 10 + 0.5) / 10
	)
end

-- Route A: the wash north from the town's arch, the ramp up to the flats, and the arroyo above.
local A: { WorldTypes.SheetPoint } = {
	p(20, -150),
	p(10, -196),
	p(-12, -230),
	p(-14, -270),
	p(6, -304),
	p(34, -330),
	p(50, -368),
	p(42, -408),
	p(66, -436),
	p(66, -484),
	p(120.2, -545.4),
}

-- Route B: east out of the town, the Redstone Steps, the rim, the garden and the stair road.
local B: { WorldTypes.SheetPoint } = {
	p(150, 40),
	p(190, 40),
	p(224, 18),
	p(262, -10),
	p(300, -32),
	p(332, -60),
	p(380, -74),
	p(420, -64),
	p(456, -84),
	p(500, -98),
	p(540, -90),
	p(580, -102),
	p(620, -92),
	p(660, -108.2),
	p(700, -98),
	p(730, -100),
	p(779, -100),
}

local DustCanyon: WorldTypes.MapSheet = {
	routes = {
		-- Dry Wash Trail: north up the pebble wash, up a ramp onto the tumbleweed flats, then up
		-- again into the arroyo, a slot canyon that ends at the broken rope bridge.
		dust_canyon_route_a = { points = A },
		-- Mesa Road: up the Redstone Steps, along the Sunbaked Rim, through the Spire Garden and
		-- up the stair road to the Stair Gate.
		dust_canyon_route_b = { points = B },
	},

	-- The widest half-width of each stretch: how far the cliffs or boulder banks may stand from
	-- the middle of the lane. The lanes themselves are narrower and vary: see `widths`.
	corridor = {
		pebble_wash = 16,
		tumbleweed_flats = 18,
		hollow_arroyo = 16,
		redstone_steps = 14,
		sunbaked_rim = 12,
		spire_garden = 12,
		stair_approach = 20,
		dust_canyon_lair = 10,
	},

	-- The spur to Mesalith's Shelf forks north at 360 along the Mesa Road, climbs up the cliff
	-- stair and comes out on the shelf round the arena. Its first point is the computed join,
	-- which Layout drops as a leg of no length.
	spurs = {
		dust_canyon_lair = {
			p(468.8, -88.1),
			p(490, -136),
			p(514, -176),
			p(534, -222),
			p(572, -268),
			p(576, -319),
		},
	},

	-- Half the lane's width, by distance along (the plan's section 6).
	widths = {
		dust_canyon_route_a = {
			key(0, 9),
			key(36, 9),
			key(50, 16),
			key(98, 16),
			key(106, 8),
			key(118, 8),
			key(126, 16),
			key(166, 16),
			key(172, 18),
			key(286, 18),
			key(298, 14),
			key(324, 10),
			key(332, 10),
			key(372, 10),
			key(380, 12),
			key(420, 12),
			key(448, 21),
		},
		dust_canyon_route_b = {
			key(0, 9),
			key(36, 9),
			key(44, 13),
			key(80, 13),
			key(88, 14),
			key(120, 14),
			key(128, 12),
			key(240, 12),
			key(256, 18),
			key(330, 18),
			key(342, 12),
			key(430, 12),
			key(436, 10),
			key(448, 10),
			key(454, 12),
			key(560, 12),
			key(574, 9),
			key(606, 9),
			key(620, 14),
			key(640, 20),
			key(680, 20),
		},
		dust_canyon_lair = {
			key(0, 9),
			key(100, 9),
			key(140, 6),
			key(190, 6),
			key(200, 10),
			key(260, 10),
		},
	},

	buildings = {
		kiln_trading_post = { at = p(66, -6), faces = 270, door = p(50, -6), model = "TradingPost" },
		seep_house = { at = p(-64, 44), faces = 0, door = p(-64, 28), model = "Healer" },
		cradle_kiln = { at = p(72, 72), faces = 315, door = p(60.7, 60.7), model = "BottleKiln" },
		notice_wall = { at = p(-30, -50), faces = 150, door = p(-24, -40), model = "NoticeBoard" },
		sundial_waystation = {
			at = p(-80, -46),
			faces = 135,
			door = p(-68.7, -34.7),
			model = "Waystation",
		},
		dust_ring = { at = p(0, 96), faces = 0, door = p(0, 74) },
		windward_overlook = {
			at = p(100, -96),
			faces = 225,
			door = p(88.7, -84.7),
			model = "WindTower",
		},
	},

	-- Levels: tiers 10 studs apart (taller than a jump), later tiers winning where they overlap.
	tiers = {
		-- Route A: the flats' mesa above the wash, the arroyo above that, and the shelf between.
		{ id = "flats_mesa", height = 10, shape = box(-60, -424, 120, -290) },
		{ id = "arroyo_shelf", height = 10, shape = box(22, -490, 44, -420) },
		{ id = "arroyo_rise", height = 20, shape = box(44, -500, 88, -426) },
		{ id = "arroyo_end", height = 20, shape = strip(74, -500, 120, -545, 26) },
		{ id = "arroyo_hollow", height = 20, shape = disc(132, -500, 36) },
		{ id = "cairn_tier", height = 20, shape = disc(78, -514, 20) },
		-- Route B: the Redstone Steps' two landings, the rim and everything on it, the gate's
		-- terrace, the ledge shelves down to the gorge, and Mesalith's Shelf.
		{ id = "steps_a", height = 10, shape = strip(218, 22, 266, -12, 24) },
		{ id = "steps_b", height = 20, shape = strip(292, -25, 334, -60, 14) },
		{ id = "rim_mesa", height = 30, shape = box(350, -160, 656, -44) },
		{ id = "spur_mesa", height = 30, shape = box(452, -232, 556, -84) },
		{ id = "garden_tier", height = 30, shape = disc(520, -60, 34) },
		{ id = "gate_terrace", height = 40, shape = box(650, -134, 880, -34) },
		{ id = "rim_shelf_a", height = 20, shape = box(358, -44, 410, -24) },
		{ id = "rim_shelf_b", height = 10, shape = box(366, -24, 406, -4) },
		{ id = "lair_shelf", height = 40, shape = disc(576, -319, 86) },
	},

	-- Stairs and ramps run from their low end to their high end (heights come from the tiers under
	-- the ends); a ledge is a stretch of lip, high ground on the left as you walk from `from`.
	links = {
		link("wash_ramp", "Ramp", lerp(A[4], A[5], 0.1), lerp(A[4], A[5], 0.81), 14),
		link("arroyo_ramp", "Ramp", lerp(A[8], A[9], 0.08), lerp(A[8], A[9], 0.84), 14),
		link("arroyo_ledge_1", "Ledge", p(44, -486), p(44, -472), 8),
		link("arroyo_ledge_2", "Ledge", p(44, -468), p(44, -452), 8),
		link("steps_1", "Stairs", lerp(B[2], B[3], 0.12), lerp(B[2], B[3], 0.81), 12),
		link("steps_2", "Stairs", lerp(B[4], B[5], 0.1), lerp(B[4], B[5], 0.74), 12),
		link("steps_3", "Stairs", B[6], lerp(B[6], B[7], 0.46), 12),
		link("rim_ledge_1", "Ledge", p(364, -44), p(404, -44), 8),
		link("rim_ledge_2", "Ledge", p(372, -24), p(400, -24), 8),
		link("rim_ledge_3", "Ledge", p(374, -4), p(398, -4), 8),
		link("gate_stairs", "Stairs", lerp(B[13], B[14], 0.12), lerp(B[13], B[14], 0.79), 12),
		link("shelf_stairs", "Stairs", p(534, -222), p(551.7, -243.4), 10),
	},

	-- Walkable space beside the lanes: pockets, fields, clearings and the dead ends.
	rooms = {
		-- Route A.
		{ id = "wash_pocket", shape = disc(44, -212, 30) },
		{ id = "wash_alcove", shape = disc(-50, -208, 16) },
		{ id = "wash_alcove_way", shape = strip(-12, -210, -40, -208, 7) },
		{ id = "flats_bay", shape = disc(-6, -352, 34) },
		{ id = "flats_dune", shape = disc(86, -352, 26) },
		{ id = "arroyo_shelf_room", shape = box(22, -490, 46, -420) },
		{ id = "arroyo_brink", shape = box(44, -490, 56, -446) },
		{ id = "arroyo_hollow_room", shape = disc(132, -500, 30) },
		{ id = "cairn_nook", shape = disc(78, -514, 14) },
		-- Route B.
		{ id = "steps_pocket", shape = disc(188, 84, 34) },
		{ id = "rim_notch", shape = disc(372, -96, 16) },
		{ id = "rim_pocket", shape = disc(420, -112, 28) },
		{ id = "rim_brink", shape = box(358, -60, 410, -44) },
		{ id = "rim_shelf_a_room", shape = box(358, -44, 410, -24) },
		{ id = "rim_shelf_b_room", shape = box(366, -24, 406, -4) },
		{ id = "gorge_head", shape = box(366, -4, 406, 16) },
		{ id = "gorge_path_a", shape = strip(376, 12, 340, 34, 7) },
		{ id = "gorge_path_b", shape = strip(340, 34, 290, 52, 7) },
		{ id = "gorge_path_c", shape = strip(290, 52, 244, 60, 7) },
		{ id = "gorge_path_d", shape = strip(244, 60, 196, 52, 7) },
		{ id = "garden_pocket", shape = disc(520, -60, 28) },
		{ id = "garden_bypass_a", shape = strip(504, -108, 522, -146, 8) },
		{ id = "garden_bypass_b", shape = strip(522, -146, 572, -142, 8) },
		{ id = "garden_bypass_c", shape = strip(572, -142, 600, -116, 10) },
		{ id = "stair_pocket", shape = disc(684, -68, 28) },
	},

	-- Patches of long grass besides each stretch's own (the place `{stretch}_grass`).
	grass = {
		tumbleweed_flats = { { at = p(86, -352), r = 12 } },
		redstone_steps = { { at = p(206, 98), r = 8 } },
	},

	places = {
		-- Long grass: in the pockets and rooms beside the lane, never on a tamer.
		pebble_wash_grass = p(44, -212),
		tumbleweed_flats_grass = p(-6, -352),
		hollow_arroyo_grass = p(132, -500),
		redstone_steps_grass = p(188, 84),
		sunbaked_rim_grass = p(420, -112),
		spire_garden_grass = p(520, -60),
		stair_approach_grass = p(684, -66),
		-- Rustle spots.
		cairn_field = p(104, -520),
		echo_notch = p(378, -100),
		capstone_garden = p(596, -122),
		-- Tamers, at bends and narrow points, facing the way players arrive.
		dc_ines = p(-5, -248),
		dc_rafe = p(62, -452),
		dc_perrin = p(244, -4),
		dc_hesper = p(550, -101),
		dc_tavish = p(699, -106.5),
		-- The stretch middle the rival's stand belongs to.
		sunbaked_rim = p(370, -68),
		-- The stretch middle is where "The mesa that walks" is sighted. It sits 25 studs east of
		-- Hesper (the surveyor with the brass scope who points it out), so the line fires as the
		-- player comes up to her, never on top of her.
		spire_garden = p(575, -100),
	},

	-- The rival stands on the rim with the gorge behind him; Isolde Karrow stands in the gate.
	stands = {
		rival_canyon = p(370, -66),
		champion_karrow = p(772, -100),
	},

	faces = {
		dc_ines = 160,
		dc_rafe = 210,
		dc_perrin = 225,
		dc_hesper = 235,
		dc_tavish = 270,
		rival_canyon = 270,
		champion_karrow = 270,
	},

	-- Stretches closed until the story opens them (World.holdAt; Greenwood's River Road is the
	-- model). The Mesa Road waits for the mentor's letter (the `mentors_letter` beat opens
	-- `canyon_routes`), so a new arrival meets the Dry Wash's level 13 to 16 creatures first, not
	-- the rim's and the garden's level 17 to 21 ones. The closed area starts past the town's arch
	-- and covers the road, the lair spur and the Stair Gate's approach. The bar past the gate is
	-- held until the Cairn Badge (`badge_2`), so the road on cannot be walked without it.
	holds = {
		{
			id = "mesa_road",
			feature = "canyon_routes",
			from = p(165, -450),
			to = p(780, 200),
			back = p(120, 30),
			line = "The Mesa Road is too steep for now. Finish your first tasks around Kilnrest and it will open.",
		},
		{
			id = "sealed_road",
			feature = "badge_2",
			from = p(790, -450),
			to = p(900, 200),
			back = p(745, -100),
			line = "The road on is shut to all but badge holders. Win the Cairn Badge at the Stair Gate first.",
		},
	},

	-- Where players arrive from Greenwood, through the Westcut, facing the Trading Post. Only the
	-- first biome's spawn is built; this one is a record for the tests and the Studio check.
	spawn = { at = p(-128, 0), faces = 90 },
}

return DustCanyon
