--!strict
-- Dust Canyon's tamers: five locals met along the routes, the rival's mid-biome battle and the
-- gate's champion. Names are original. Every move is one the creature can know at that level
-- (tests/dustcanyon.test checks this). Levels rise with the routes (13 to 22) and stay under the
-- gate's 22 to 25, so a player who has fought the tamers on the way arrives ready for the gate.
--
-- Where Greenwood's gate was held by the rival, Dust Canyon's is held by a local champion (master
-- plan 4.5), so the rival appears once, mid-biome, on the Sunbaked Rim. His arc moves one step:
-- his team's tint has doubled (0.5 against Greenwood's 0.25), he carries a glinting shard, and he
-- has begun to hint that the mentor is hiding something. He still leads with the starter that
-- counters the player's, as in Greenwood: Sand beats Leaf, Water beats Sand, Leaf beats Water.
-- The champion's team is Sand with one Leaf creature to answer Water.

local WorldTypes = require("../../shared/WorldTypes")

type Member = WorldTypes.TamerMember

local function member(species: string, level: number, moves: { string }): Member
	return { species = species, level = level, moves = moves }
end

local locals: { WorldTypes.Tamer } = {
	{
		id = "dc_ines",
		name = "Ines Parchwell",
		look = "A rockhound with goggles pushed up on her forehead and a hammer on her belt",
		tier = "Tamer",
		route = "dust_canyon_route_a",
		at = 110,
		team = {
			members = {
				member("Duneskit", 13, { "Sand Flick", "Dune Dash", "Pebble Pelt" }),
				member("Spurlet", 13, { "Spine Jab", "Needle Fan", "Hoof Scuff" }),
			},
			tint = 0,
		},
		before = "Rocks, rocks, rocks! Beat me and I will show you the good ones.",
		after = "Ha! Quick hands. Keep that pace and the canyon will treat you well.",
	},
	{
		id = "dc_rafe",
		name = "Rafe Gullick",
		look = "A wash guide in a wide hat, a dripping canteen swinging at his hip",
		tier = "Tamer",
		route = "dust_canyon_route_a",
		at = 340,
		team = {
			members = {
				member("Wadibuck", 14, { "Oasis Spout", "Wadi Rush", "Fog Drip", "Hoof Scuff" }),
				member("Thatchling", 15, { "Spine Jab", "Needle Fan", "Dust Squall", "Grit Step" }),
			},
			tint = 0,
		},
		before = "Water is gold out here, and I know every drop. Care to test me?",
		after = "Dry as a bone, and you still won. Drink something, friend.",
	},
	{
		id = "dc_perrin",
		name = "Perrin Skelt",
		look = "A kiln hand with a soot-black apron and flint-grey fingers",
		tier = "Tamer",
		route = "dust_canyon_route_b",
		at = 100,
		team = {
			members = {
				member(
					"Flintknap",
					17,
					{ "Knap Edge", "Flint Cleave", "Dune Dash", "Pebble Pelt" }
				),
				member("Whirlgrit", 17, { "Sand Flick", "Dune Dash", "Pebble Pelt", "Grit Whirl" }),
			},
			tint = 0,
		},
		before = "I bake bricks all day. A battle is a nice break. Come on!",
		after = "Well fired! You have the heat for the Mesa Road.",
	},
	{
		id = "dc_hesper",
		name = "Hesper Dunnock",
		look = "A surveyor with a brass sighting scope and a notebook of crooked maps",
		tier = "Tamer",
		route = "dust_canyon_route_b",
		at = 440,
		team = {
			members = {
				member(
					"Spirecap",
					19,
					{ "Capstone Crash", "Mesa Slam", "Pebble Pelt", "Grit Step" }
				),
				member(
					"Duneskit",
					19,
					{ "Grit Whirl", "Dune Dash", "Tumbleweed Toss", "Sand Flick" }
				),
				member("Wadibuck", 20, { "Flash Flood", "Wadi Rush", "Oasis Spout", "Fog Drip" }),
			},
			tint = 0,
		},
		before = "My maps say you stand exactly where I want you. Let us see your team.",
		after = "Hm. I will have to redraw that part of the map. Nicely done.",
	},
	{
		id = "dc_tavish",
		name = "Tavish Orrel",
		look = "A lanky mesa guide in a red headscarf, forever coiling a climbing rope",
		tier = "Tamer",
		route = "dust_canyon_route_b",
		at = 600,
		team = {
			members = {
				member(
					"Cairnback",
					21,
					{ "Mesa Slam", "Capstone Crash", "Talus Tumble", "Tumbleweed Toss" }
				),
				member("Flintknap", 21, { "Grit Whirl", "Dune Dash", "Flint Cleave", "Knap Edge" }),
				member(
					"Thatchling",
					22,
					{ "Agave Lance", "Needle Fan", "Dust Squall", "Spine Jab" }
				),
			},
			tint = 0,
		},
		before = "Nobody reaches the Stair Gate without passing me. Three of mine, then.",
		after = "You climb well. The warden is waiting, and she is no pushover.",
	},
}

-- The rival, mid-biome. One team for each starter the player picked.
local rivalTeams: WorldTypes.ByStarter<WorldTypes.TamerTeam> = {
	-- The player picked Mossmitt (Leaf): Sand leads, with a Water creature and a sprinter behind it.
	Mossmitt = {
		members = {
			member("Spadesnout", 19, { "Dig Strike", "Grit Spray", "Dust Kick", "Scree Kick" }),
			member("Wadibuck", 18, { "Oasis Spout", "Wadi Rush", "Fog Drip", "Hoof Scuff" }),
			member("Whirlgrit", 18, { "Grit Whirl", "Dune Dash", "Pebble Pelt", "Sand Flick" }),
		},
		tint = 0.5,
	},
	-- The player picked Spadesnout (Sand): Water leads, with two Leaf creatures that carry Storm.
	Spadesnout = {
		members = {
			member("Sloshcalf", 19, { "Ripple Ram", "Mud Slap", "Brook Rush", "Dew Splash" }),
			member("Thatchling", 18, { "Agave Lance", "Needle Fan", "Dust Squall", "Spine Jab" }),
			member("Spurlet", 18, { "Agave Lance", "Needle Fan", "Dust Squall", "Spine Jab" }),
		},
		tint = 0.5,
	},
	-- The player picked Sloshcalf (Water): Leaf leads, with a Leaf sprinter and a stone tank.
	Sloshcalf = {
		members = {
			member("Mossmitt", 19, { "Bramble Rake", "Thorn Volley", "Leaf Gust", "Moss Slam" }),
			member("Spurlet", 18, { "Agave Lance", "Needle Fan", "Dust Squall", "Spine Jab" }),
			member(
				"Cairnback",
				18,
				{ "Mesa Slam", "Capstone Crash", "Tumbleweed Toss", "Pebble Pelt" }
			),
		},
		tint = 0.5,
	},
}

local storyBattles: { WorldTypes.StoryBattle } = {
	{
		id = "rival_canyon",
		name = "Rival",
		look = "A sharp-eyed youth in a green jacket, an amber shard glinting at his belt",
		tier = "Rival",
		place = "sunbaked_rim",
		xpKind = "Rival",
		teams = rivalTeams,
		before = "You keep up, I will give you that. But I have help now. Watch this.",
		after = "It hums louder when I lose. I do not like that. Not one bit.",
		mayRetryAtOnce = false, -- he can be lost to here; only the very first battle cannot
	},
	{
		id = "champion_karrow",
		name = "Isolde Karrow",
		look = "A tall warden in a sun-bleached cloak, a brass whistle on a cord at her neck",
		tier = "Rival",
		place = "dust_canyon_gate",
		xpKind = "Gate",
		team = {
			members = {
				member("Whirlgrit", 22, { "Grit Whirl", "Dune Dash", "Pebble Pelt", "Sand Flick" }),
				member(
					"Cairnback",
					23,
					{ "Mesa Slam", "Capstone Crash", "Talus Tumble", "Tumbleweed Toss" }
				),
				member(
					"Thatchling",
					24,
					{ "Agave Lance", "Needle Fan", "Dust Squall", "Spine Jab" }
				),
			},
			tint = 0,
		},
		before = "The Stair is not climbed, it is earned. Show me a team worth a badge.",
		after = "Fast, and calm with it. The Cairn Badge is yours. Go well.",
		mayRetryAtOnce = false,
	},
}

local pack: WorldTypes.BiomeTamers = { locals = locals, storyBattles = storyBattles }

return pack
