--!strict
-- Greenwood's map sheet: where the designer put the routes, buildings, people and patches of long
-- grass. Studs from the centre of Thistledown; north is -z, east is +x. Facings are degrees
-- clockwise from north. Data only, straight from docs/plans/08_GREENWOOD_MAP.md section 3.
--
-- Places the sheet leaves out (each stretch's middle, a route's entry, the gate, the sealed road,
-- the lair and its stall) are still worked out by Layout from the fitted lines, so every distance
-- along a route in the biome data keeps its meaning.

local WorldTypes = require("../../shared/WorldTypes")

local function p(x: number, z: number): WorldTypes.SheetPoint
	return { x = x, z = z }
end

local Greenwood: WorldTypes.MapSheet = {
	routes = {
		-- Clover Lane: west over the footbridge, round the mossy knoll into the meadow, then a
		-- hook north and north-east up the brook to the old fence.
		greenwood_route_a = {
			points = {
				p(-150, 0),
				p(-200, 10),
				p(-250, 40),
				p(-290, 40),
				p(-330, 10),
				p(-350, -40),
				p(-340, -100),
				p(-300, -140),
				p(-279, -161),
			},
		},
		-- River Road: east along the river, up the birch rise, through the old wood and the
		-- gatehouse hamlet to the gate.
		greenwood_route_b = {
			points = {
				p(150, 0),
				p(200, 15),
				p(260, 30),
				p(310, 20),
				p(350, -20),
				p(380, -70),
				p(420, -100),
				p(480, -110),
				p(530, -90),
				p(580, -80),
				p(640, -80),
				p(684, -80),
			},
		},
	},

	-- How far the hedges or tree lines stand from the middle of the lane, by stretch.
	corridor = {
		mossy_glade = 50,
		clover_meadow = 70,
		brook_bend = 50,
		sandy_bank = 55,
		birch_rise = 45,
		old_wood = 50,
		gatehouse_approach = 70,
		greenwood_lair = 30,
	},

	-- The spur to Hollowbough's Hollow leaves River Road at 330 along and climbs north-west.
	spurs = {
		greenwood_lair = { p(420, -100), p(380, -170), p(330, -230), p(270, -300) },
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

	places = {
		-- Long grass: beside the lane or across it, never on a tamer.
		mossy_glade_grass = p(-208, 43),
		clover_meadow_grass = p(-311, 25),
		brook_bend_grass = p(-368, -90),
		sandy_bank_grass = p(214, -8),
		birch_rise_grass = p(365, -44),
		old_wood_grass = p(507, -127),
		gatehouse_approach_grass = p(604, -104),
		-- Rustle spots.
		reed_bed = p(-283, -122),
		heron_pool = p(231, 48),
		burl_thicket = p(480, -84),
		-- Tamers, at bends and narrow points, facing the way players arrive.
		gw_pip = p(-247, 27),
		gw_wren = p(-322, -105),
		gw_odette = p(258, 20),
		gw_basil = p(342, -25),
		gw_corwin = p(529, -100),
	},

	-- The rival stands in the plaza for the first battle and in the mouth of the gatehouse arch
	-- for the second. Each is within the server's slack (8) of its place, so wherever his prompt
	-- shows, the server accepts the request. The plan's (676, -80) is 8.4 from the fitted gate at
	-- (684.4, -80), just past the slack, so he stands at 678.
	stands = {
		rival_first = p(0, -6),
		rival_gate = p(678, -80),
	},

	faces = {
		gw_pip = 60,
		gw_wren = 225,
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
