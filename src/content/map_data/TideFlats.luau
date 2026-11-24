--!strict
-- Tide Flats' map sheet: where the designer put Saltwick, the Strandline Path, the Breakwater Road
-- and the spur to Carrackon's Wreck, and the levels they climb. Studs from the centre of Saltwick;
-- north is -z, east is +x. Facings are degrees clockwise from north. Data only: the routes, the
-- tiers and the links are from docs/plans/12_MAP_STRUCTURE.md section 6 (the town is
-- docs/plans/10_TIDE_FLATS_MAP.md section 3a), built the way Greenwood's are.
--
-- Places the sheet leaves out (each stretch's middle, a route's entry, the gate, the sealed road,
-- the lair and its stall) are worked out by Layout from the fitted lines, so every distance along
-- a route in the biome data keeps its meaning. Route B's last leg runs due east and ends at
-- (743, 110): the Mire will be sited from it, so it must not change on its own.
--
-- Heights are whole tiers of 10 (the plan's 6, 12 and 4 are rounded to match Greenwood and Dust
-- Canyon, so every drop is a clear wall and every ledge one tier). Long on purpose: every tier,
-- link and room is a line of data that the tests (ground.test, walk.test, layout.test) check.

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

-- Route A: south down the wrack beach, up a ramp onto the rock shelf, down steps into the kelp
-- shallows and east to the broken plank bridge.
local A: { WorldTypes.SheetPoint } = {
	p(-110, 150),
	p(-128, 190),
	p(-118, 232),
	p(-92, 262),
	p(-96, 300),
	p(-76, 336),
	p(-40, 350),
	p(-6, 372),
	p(30, 380),
	p(70, 372),
	p(104, 386),
	p(140, 378),
	p(166, 364),
	p(201.7, 349),
}

-- Route B: the sandbar causeway, the mud boardwalk, round the bay of the wreck, and the steps up
-- the breakwater to the gate.
local B: { WorldTypes.SheetPoint } = {
	p(150, 20),
	p(190, 60),
	p(220, 110),
	p(250, 170),
	p(290, 192),
	p(334, 182),
	p(376, 198),
	p(420, 178),
	p(480, 184),
	p(538, 196),
	p(592, 186.5),
	p(636, 150),
	p(680, 110),
	p(743, 110),
}

local TideFlats: WorldTypes.MapSheet = {
	routes = {
		-- Strandline Path: south down the wrack beach from the end of Stilt Row, up onto the rock
		-- shelf, down into the kelp shallows and east to the broken plank bridge.
		tide_flats_route_a = { points = A },
		-- Breakwater Road: along the sandbar causeway, over the mudflat boardwalk, round the bay of
		-- the shipwreck and up the breakwater steps to the Breakwater Gate.
		tide_flats_route_b = { points = B },
	},

	-- The widest half-width of each stretch: how far the rope rails, dunes, rocks, cliffs and sea
	-- walls may stand from the middle of the lane. The lanes themselves vary: see `widths`.
	corridor = {
		wrack_beach = 14,
		rockpool_shelf = 14,
		kelp_shallows = 14,
		sandbar_causeway = 10,
		mudflat_boardwalk = 9,
		shipwreck_reach = 18,
		tideward_steps = 12,
		tide_flats_lair = 10,
	},

	-- The spur to Carrackon's Wreck forks south-east at 440 along the Breakwater Road. Its first
	-- point is the computed join, which Layout drops as a leg of no length.
	spurs = {
		tide_flats_lair = {
			p(493.41, 186.77),
			p(538, 236),
			p(584, 292),
			p(640, 340),
			p(691.84, 383),
		},
	},

	-- Half the lane's width, by distance along (the plan's section 6).
	widths = {
		tide_flats_route_a = {
			key(0, 9),
			key(36, 9),
			key(48, 14),
			key(100, 14),
			key(108, 9),
			key(136, 9),
			key(150, 12),
			key(166, 17),
			key(198, 17),
			key(208, 12),
			key(330, 12),
			key(342, 14),
			key(392, 14),
			key(398, 9),
			key(412, 9),
			key(420, 14),
			key(480, 14),
			key(500, 21),
		},
		tide_flats_route_b = {
			key(0, 9),
			key(36, 9),
			key(46, 10),
			key(182, 10),
			key(190, 9),
			key(350, 9),
			key(364, 18),
			key(430, 18),
			key(446, 12),
			key(590, 12),
			key(640, 12),
			key(720, 20),
		},
		tide_flats_lair = {
			key(0, 9),
			key(120, 9),
			key(130, 7),
			key(200, 7),
			key(214, 10),
			key(280, 10),
		},
	},

	buildings = {
		tarn_chandlery = { at = p(64, -14), faces = 270, door = p(48, -14), model = "Chandlery" },
		warm_pool = { at = p(-64, -46), faces = 180, door = p(-64, -30), model = "Healer" },
		brood_shallows = { at = p(30, -80), faces = 180, door = p(30, -64), model = "NetLoft" },
		tally_board = { at = p(-20, -58), faces = 180, door = p(-20, -42), model = "NoticeBoard" },
		ferry_steps = { at = p(-58, 62), faces = 45, door = p(-46.7, 50.7), model = "Waystation" },
		-- A sand oval with a rope rail; no painted model.
		breaker_ring = { at = p(96, -70), faces = 225, door = p(84.7, -58.7) },
		lamp_tower = { at = p(124, 70), faces = 300, door = p(110.1, 62), model = "LampTower" },
	},

	-- Levels: tiers 10 studs apart (taller than a jump), later tiers winning where they overlap.
	tiers = {
		-- Route A: the rock shelf above the beach, with its high terrace of pools.
		{ id = "rock_shelf_w", height = 10, shape = box(-150, 290, -60, 330) },
		{ id = "rock_shelf", height = 10, shape = box(-150, 330, 50, 410) },
		{ id = "rock_terrace", height = 20, shape = box(-80, 366, -20, 414) },
		-- Route B: the dune terrace above the reach, and the breakwater with the gate on it.
		{ id = "wreck_dune", height = 10, shape = box(440, 130, 500, 158) },
		{ id = "breakwater", height = 10, shape = box(662, 84, 880, 140) },
	},

	-- Stairs and ramps run from their low end to their high end (heights come from the tiers under
	-- the ends); a ledge is a stretch of lip, high ground on the left as you walk from `from`.
	links = {
		link("shelf_ramp", "Ramp", lerp(A[4], A[5], 0.1), lerp(A[4], A[5], 0.83), 14),
		link("shelf_ledge", "Ledge", p(-104, 290), p(-124, 290), 8),
		link("terrace_stairs", "Stairs", p(-52, 352), p(-52, 374), 10),
		link("terrace_ledge", "Ledge", p(-26, 366), p(-46, 366), 8),
		link("shelf_stairs", "Stairs", lerp(A[9], A[10], 0.84), lerp(A[9], A[10], 0.15), 12),
		link("dune_ramp", "Ramp", p(462, 172), p(462, 150), 12),
		link("dune_ledge", "Ledge", p(478, 158), p(496, 158), 8),
		link("breakwater_stairs", "Stairs", lerp(B[12], B[13], 0.25), lerp(B[12], B[13], 0.72), 12),
		link("breakwater_ledge", "Ledge", p(700, 140), p(740, 140), 8),
	},

	-- Walkable space beside the lanes: pockets, fields, clearings and the dead ends.
	rooms = {
		-- Route A.
		{ id = "beach_pocket", shape = disc(-162, 212, 30) },
		{ id = "beach_cove", shape = disc(-156, 262, 16) },
		{ id = "beach_cove_way", shape = strip(-100, 256, -144, 260, 7) },
		{ id = "shelf_drop", shape = box(-130, 268, -100, 290) },
		{ id = "shelf_brink", shape = box(-130, 290, -100, 312) },
		{ id = "shelf_pool", shape = disc(-118, 358, 30) },
		{ id = "terrace_skirt", shape = box(-48, 352, -22, 366) },
		{ id = "terrace_way", shape = box(-58, 352, -46, 374) },
		{ id = "terrace_room", shape = box(-80, 366, -20, 414) },
		{ id = "kelp_pocket", shape = disc(84, 418, 32) },
		{ id = "kelp_nook", shape = disc(150, 398, 16) },
		-- Gull Cove (plan 13, side area b): a sea arch in the beach pocket's west rim, a winding
		-- walk down the cliff foot (about 290 studs from the lane), and a cove open to the sea. It
		-- keeps 24 studs or more from the rock shelf and 100 from the lane's pockets, and has no
		-- long grass. The world's plan put it at (1700, 300); that lies in Dust Canyon's region, so
		-- it sits 130 studs east, on Tide Flats' side of the border.
		{ id = "cove_arch", shape = strip(-186, 214, -212, 222, 7) },
		{ id = "cove_walk_a", shape = strip(-212, 222, -224, 262, 7) },
		{ id = "cove_walk_b", shape = strip(-224, 262, -204, 300, 7) },
		{ id = "cove_walk_c", shape = strip(-204, 300, -226, 338, 7) },
		{ id = "cove_walk_d", shape = strip(-226, 338, -212, 374, 7) },
		{ id = "cove_room", shape = disc(-212, 412, 38) },
		-- Route B.
		{ id = "sandbar_pocket", shape = disc(176, 112, 32) },
		{ id = "boardwalk_pocket", shape = disc(352, 226, 32) },
		{ id = "reach_pocket", shape = disc(440, 224, 32) },
		{ id = "dune_room", shape = box(440, 130, 500, 158) },
		{ id = "dune_way", shape = box(454, 156, 470, 168) },
		{ id = "dune_skirt", shape = box(474, 158, 500, 166) },
		{ id = "cave_mouth", shape = disc(536, 182, 15) },
		{ id = "steps_pocket", shape = disc(594, 138, 32) },
		{ id = "breakwater_brink", shape = box(690, 120, 750, 140) },
		{ id = "shore_head", shape = box(690, 140, 750, 158) },
		{ id = "shore_path_a", shape = strip(704, 154, 650, 172, 7) },
		{ id = "shore_path_b", shape = strip(650, 172, 612, 172, 7) },
	},

	-- Patches of long grass besides each stretch's own (the place `{stretch}_grass`).
	grass = {
		wrack_beach = { { at = p(-156, 262), r = 7 } },
		rockpool_shelf = { { at = p(-126, 370), r = 10 } },
	},

	places = {
		-- Long grass: marram on sand, weed in the pools, kelp in the shallows, reeds on the mud,
		-- each in a pocket beside the lane.
		wrack_beach_grass = p(-162, 212),
		rockpool_shelf_grass = p(-118, 358),
		kelp_shallows_grass = p(84, 418),
		sandbar_causeway_grass = p(176, 112),
		mudflat_boardwalk_grass = p(352, 226),
		shipwreck_reach_grass = p(440, 224),
		tideward_steps_grass = p(594, 138),
		-- Rustle spots.
		anemone_pools = p(-34, 378),
		kelp_bed = p(150, 402),
		tide_cave = p(535, 173),
		-- Tamers, facing the way players arrive.
		tf_nell = p(-112, 244),
		tf_merrin = p(110, 392),
		tf_orrin = p(228, 104),
		tf_isaura = p(461, 191),
		tf_ludo = p(632, 160),
		-- The stretch middle the champion's stand belongs to.
		mudflat_boardwalk = p(335, 183),
		-- The stretch middle is where "The wreck that walks" is sighted, 25 studs east of Isaura (the
		-- signal-lamp keeper who points it out): the line fires as the player comes up to her.
		shipwreck_reach = p(486, 190),
		tideward_steps = p(606, 178),
	},

	-- Captain Marr stands on the boardwalk with the mud on both sides; the rival stands in the gate.
	stands = {
		champion_marr = p(335, 184),
		rival_breakwater = p(736, 110),
	},

	faces = {
		tf_nell = 320,
		tf_merrin = 230,
		tf_orrin = 318,
		tf_isaura = 290,
		tf_ludo = 250,
		champion_marr = 270,
		rival_breakwater = 270,
	},

	-- Stretches closed until the story opens them (World.holdAt; Greenwood's River Road is the
	-- model). The Breakwater Road waits for the mentor's note (the `mentors_note` beat opens
	-- `tide_routes`), so a new arrival meets Strandline Path's creatures first, not the boardwalk's
	-- and the wreck's. It is closed from the end of the causeway on (Orrin and the causeway stay
	-- open), and covers the lair spur and the gate's approach. Two bars are held until a badge:
	-- the road on past this gate (`badge_3`), and the Dune Road from Dust Canyon (`badge_2`), whose
	-- way back is on Dust Canyon's side, at the foot of the Stair Gate's approach.
	holds = {
		{
			id = "breakwater_road",
			feature = "tide_routes",
			from = p(262, -60),
			to = p(755, 560),
			back = p(190, 60),
			line = "The Breakwater Road is not for you yet. Finish your first tasks around Saltwick and it will open.",
		},
		{
			id = "sealed_road",
			feature = "badge_3",
			from = p(760, -200),
			to = p(900, 300),
			back = p(700, 110),
			line = "The road on is shut to all but badge holders. Win the Breaker Badge at the gate first.",
		},
		{
			id = "dune_road",
			feature = "badge_2",
			from = p(-290, -300),
			to = p(-150, 120),
			back = p(-334, 0),
			line = "You need the Cairn Badge before you can go on to Saltwick. Win it at the Stair Gate.",
		},
	},

	-- Where players arrive from Dust Canyon, over the Dune Road, facing the Chandlery. Only the
	-- first biome's spawn is built; this one is a record for the tests and the Studio check.
	spawn = { at = p(-128, 0), faces = 90 },
}

return TideFlats
