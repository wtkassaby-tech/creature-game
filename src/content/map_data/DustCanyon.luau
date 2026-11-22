--!strict
-- Dust Canyon's map sheet: where the designer put Kilnrest, the Dry Wash Trail, the Mesa Road and
-- the spur to Mesalith's Shelf. Studs from the centre of Kilnrest; north is -z, east is +x.
-- Facings are degrees clockwise from north. Data only, straight from
-- docs/plans/09_DUST_CANYON_MAP.md section 3a.
--
-- Places the sheet leaves out (each stretch's middle, a route's entry, the gate, the sealed road,
-- the lair and its stall) are worked out by Layout from the fitted lines. Route B's last leg runs
-- due east: Tide Flats is sited from it (plan 10), so it must not change on its own.

local WorldTypes = require("../../shared/WorldTypes")

local function p(x: number, z: number): WorldTypes.SheetPoint
	return { x = x, z = z }
end

local DustCanyon: WorldTypes.MapSheet = {
	routes = {
		-- Dry Wash Trail: north up the pebble wash, north-west on to the tumbleweed flats, then
		-- north-east into the arroyo to the broken rope bridge.
		dust_canyon_route_a = {
			points = {
				p(20, -150),
				p(10, -200),
				p(20, -250),
				p(-10, -300),
				p(-10, -360),
				p(20, -410),
				p(60, -440),
				p(90, -490),
				p(120, -545),
			},
		},
		-- Mesa Road: up the Redstone Steps, along the Sunbaked Rim, through the Spire Garden and up
		-- the stair road to the Stair Gate.
		dust_canyon_route_b = {
			points = {
				p(150, 40),
				p(200, 30),
				p(240, 0),
				p(270, -40),
				p(320, -60),
				p(380, -60),
				p(440, -75),
				p(490, -80),
				p(540, -110),
				p(590, -110),
				p(630, -90),
				p(680, -100),
				p(730, -100),
				p(779, -100),
			},
		},
	},

	-- How far the cliffs and boulder banks stand from the middle of the lane, by stretch.
	corridor = {
		pebble_wash = 55,
		tumbleweed_flats = 65,
		hollow_arroyo = 46,
		redstone_steps = 50,
		sunbaked_rim = 48,
		spire_garden = 65,
		stair_approach = 50,
		dust_canyon_lair = 30,
	},

	-- The spur to Mesalith's Shelf forks north at 360 along the Mesa Road. Its first point is the
	-- computed join, which Layout drops as a leg of no length.
	spurs = {
		dust_canyon_lair = {
			p(473.1, -78.3),
			p(490, -150),
			p(530, -210),
			p(560, -280),
			p(576, -316),
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

	places = {
		-- Long grass: beside the lane or across it, never on a tamer.
		pebble_wash_grass = p(42, -212),
		tumbleweed_flats_grass = p(0, -377),
		hollow_arroyo_grass = p(87, -535),
		redstone_steps_grass = p(186, 62),
		sunbaked_rim_grass = p(408, -94),
		spire_garden_grass = p(524, -68),
		stair_approach_grass = p(665, -68),
		-- Rustle spots.
		cairn_field = p(110, -482),
		echo_notch = p(305, -84),
		capstone_garden = p(613, -123),
		-- Tamers, at bends and narrow points, facing the way players arrive.
		dc_ines = p(7, -250),
		dc_rafe = p(57, -455),
		dc_perrin = p(233, -6),
		dc_hesper = p(545, -121),
		dc_tavish = p(699, -109),
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

	-- Where players arrive from Greenwood, through the Westcut, facing the Trading Post. Only the
	-- first biome's spawn is built; this one is a record for the tests and the Studio check.
	spawn = { at = p(-128, 0), faces = 90 },
}

return DustCanyon
