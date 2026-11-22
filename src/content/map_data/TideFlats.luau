--!strict
-- Tide Flats' map sheet: where the designer put Saltwick, the Strandline Path, the Breakwater Road
-- and the spur to Carrackon's Wreck. Studs from the centre of Saltwick; north is -z, east is +x.
-- Facings are degrees clockwise from north. Data only, straight from
-- docs/plans/10_TIDE_FLATS_MAP.md section 3a.
--
-- Places the sheet leaves out (each stretch's middle, a route's entry, the gate, the sealed road,
-- the lair and its stall) are worked out by Layout from the fitted lines. Route B's last leg runs
-- due east: the Mire will be sited from it, so it must not change on its own.

local WorldTypes = require("../../shared/WorldTypes")

local function p(x: number, z: number): WorldTypes.SheetPoint
	return { x = x, z = z }
end

local TideFlats: WorldTypes.MapSheet = {
	routes = {
		-- Strandline Path: south down the wrack beach from the end of Stilt Row, south-east on to the
		-- rock shelf, then east through the kelp shallows to the broken plank bridge.
		tide_flats_route_a = {
			points = {
				p(-110, 150),
				p(-125, 200),
				p(-120, 250),
				p(-100, 300),
				p(-60, 340),
				p(-10, 360),
				p(40, 390),
				p(100, 400),
				p(150, 380),
				p(200, 350),
			},
		},
		-- Breakwater Road: along the sandbar causeway, over the mudflat boardwalk, round the bay of
		-- the shipwreck and up the breakwater steps to the Breakwater Gate.
		tide_flats_route_b = {
			points = {
				p(150, 20),
				p(190, 60),
				p(220, 110),
				p(250, 170),
				p(310, 190),
				p(370, 190),
				p(420, 170),
				p(480, 180),
				p(540, 200),
				p(600, 190),
				p(640, 150),
				p(680, 110),
				p(743, 110),
			},
		},
	},

	-- How far the rope rails, dunes, rocks, cliffs and sea walls stand from the middle of the lane,
	-- by stretch.
	corridor = {
		wrack_beach = 55,
		rockpool_shelf = 55,
		kelp_shallows = 60,
		sandbar_causeway = 35,
		mudflat_boardwalk = 50,
		shipwreck_reach = 65,
		tideward_steps = 48,
		tide_flats_lair = 30,
	},

	-- The spur to Carrackon's Wreck forks south-east at 440 along the Breakwater Road. Its first
	-- point is the computed join, which Layout drops as a leg of no length.
	spurs = {
		tide_flats_lair = {
			p(499.1, 186.4),
			p(540, 240),
			p(590, 300),
			p(650, 350),
			p(694, 386),
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

	places = {
		-- Long grass: marram on sand, weed in the pools, kelp in the shallows, reeds on the mud.
		wrack_beach_grass = p(-152, 210),
		rockpool_shelf_grass = p(-92, 352),
		kelp_shallows_grass = p(74, 369),
		sandbar_causeway_grass = p(192, 63),
		mudflat_boardwalk_grass = p(393, 209),
		shipwreck_reach_grass = p(445, 146),
		tideward_steps_grass = p(600, 154),
		-- Rustle spots.
		anemone_pools = p(-24, 378),
		kelp_bed = p(150, 405),
		tide_cave = p(535, 173),
		-- Tamers, facing the way players arrive.
		tf_nell = p(-104, 270),
		tf_merrin = p(110, 386),
		tf_orrin = p(226, 100),
		tf_isaura = p(461, 186),
		tf_ludo = p(660, 142),
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

	-- Where players arrive from Dust Canyon, over the Dune Road, facing the Chandlery. Only the
	-- first biome's spawn is built; this one is a record for the tests and the Studio check.
	spawn = { at = p(-128, 0), faces = 90 },
}

return TideFlats
