--!strict
-- Greenwood's tamers: five locals met along the routes, and the rival's two teams. Names are
-- original. Every move is one the creature can know at that level (tests/world.test checks this).
-- Levels rise with the routes (3 to 11) and stay under the gate's 12 to 15, so a player who has
-- fought the tamers on the way arrives at the gate ready. The rival is called "Rival" until his
-- real name is chosen.
--
-- The rival's story is in his teams: ordinary Greenwood creatures in the first battle (tint 0),
-- and a faint dark tint on the gate team (0.25) that grows each time he appears later.
-- The rival always picks the starter that counters the player's: Sand beats Leaf, Water beats
-- Sand, Leaf beats Water.

local WorldTypes = require("../../shared/WorldTypes")

type Member = WorldTypes.TamerMember

local function member(species: string, level: number, moves: { string }): Member
	return { species = species, level = level, moves = moves }
end

local locals: { WorldTypes.Tamer } = {
	{
		id = "gw_pip",
		name = "Pip Alder",
		look = "A freckled kid in an oversized straw hat, holding a butterfly net",
		tier = "Tamer",
		route = "greenwood_route_a",
		at = 100,
		team = { members = { member("Gorsling", 3, { "Seed Shot", "Leaf Gust" }) }, tint = 0 },
		before = "My hat is lucky! One battle, then you can walk on.",
		after = "Whoa, you are good. Weaken them first, then throw the rope.",
	},
	{
		id = "gw_wren",
		name = "Wren Tolliver",
		look = "A cheerful angler in rolled-up waders and a reed hat",
		tier = "Tamer",
		route = "greenwood_route_a",
		at = 330,
		team = {
			members = {
				member("Sloshcalf", 4, { "Dew Splash", "Puddle Stomp" }),
				member("Splashjack", 5, { "Dew Splash", "Brook Rush" }),
			},
			tint = 0,
		},
		before = "The brook is my patch. Show me you can handle it.",
		after = "Fair and square. The fish will be jealous of that win.",
	},
	{
		id = "gw_odette",
		name = "Odette Fenn",
		look = "A birdwatcher with big binoculars and a notebook full of sketches",
		tier = "Tamer",
		route = "greenwood_route_b",
		at = 110,
		team = {
			members = {
				member("Gorsling", 7, { "Seed Shot", "Leaf Gust", "Gale Hop" }),
				member("Stiltbark", 8, { "Seed Shot", "Leaf Gust", "Pollen Burst" }),
			},
			tint = 0,
		},
		before = "Shh! You scared off a heron. You can make it up with a battle.",
		after = "Lovely footwork. I will sketch that one for my notebook.",
	},
	{
		id = "gw_basil",
		name = "Basil Hedgeworth",
		look = "A stout gardener with a leather apron and shears on his belt",
		tier = "Tamer",
		route = "greenwood_route_b",
		at = 220,
		team = {
			members = {
				member("Mossmitt", 8, { "Seed Shot", "Moss Slam", "Brook Rush" }),
				member("Stumpwarden", 9, { "Sap Hammer", "Root Lash", "Moss Slam" }),
			},
			tint = 0,
		},
		before = "Every hedge in Greenwood is mine to keep. Let us see your team.",
		after = "Well pruned! That is a team with good roots.",
	},
	{
		id = "gw_corwin",
		name = "Corwin Ashby",
		look = "A broad woodcutter with a red scarf, always carrying a coil of rope",
		tier = "Tamer",
		route = "greenwood_route_b",
		at = 440,
		team = {
			members = {
				member("Mossmitt", 10, { "Thorn Volley", "Moss Slam", "Twig Snap" }),
				member("Burlhorn", 11, { "Burl Charge", "Root Lash", "Twig Snap" }),
				member("Stumpwarden", 11, { "Sap Hammer", "Root Lash", "Fern Whip" }),
			},
			tint = 0,
		},
		before = "I have felled bigger trees than you. Three of mine against your team.",
		after = "Hah! The road beyond is yours. Mind the gatehouse.",
	},
}

local rival: WorldTypes.RivalDef = {
	id = "rival_greenwood",
	name = "Rival",
	look = "A sharp-eyed youth in a green jacket with a loud, quick grin",
	tier = "Rival",
	firstBattle = "rival_first",
	firstPlace = "greenwood_hub",
	gateBattle = "rival_gate",
	gatePlace = "greenwood_gate",
	firstCannotBeLost = true,
	first = {
		Mossmitt = {
			members = { member("Spadesnout", 4, { "Grit Spray", "Dust Kick" }) },
			tint = 0,
		},
		Spadesnout = {
			members = { member("Sloshcalf", 4, { "Dew Splash", "Brook Rush" }) },
			tint = 0,
		},
		Sloshcalf = {
			members = { member("Mossmitt", 4, { "Seed Shot", "Moss Slam" }) },
			tint = 0,
		},
	},
	gate = {
		-- The player picked Mossmitt (Leaf): Sand leads, and Water is ready behind it.
		Mossmitt = {
			members = {
				member("Spadesnout", 13, { "Dig Strike", "Grit Spray", "Dust Kick", "Scree Kick" }),
				member(
					"Splashjack",
					12,
					{ "Ripple Ram", "Silt Surge", "Brook Rush", "Dew Splash" }
				),
				member("Gorsling", 12, { "Thorn Volley", "Bramble Rake", "Leaf Gust", "Gale Hop" }),
			},
			tint = 0.25,
		},
		-- The player picked Spadesnout (Sand): Water leads, with Storm and Leaf behind it.
		Spadesnout = {
			members = {
				member("Sloshcalf", 13, { "Ripple Ram", "Mud Slap", "Brook Rush", "Spore Puff" }),
				member("Gorsling", 12, { "Thorn Volley", "Bramble Rake", "Leaf Gust", "Gale Hop" }),
				member("Stumpwarden", 12, { "Sap Hammer", "Root Lash", "Moss Slam", "Twig Snap" }),
			},
			tint = 0.25,
		},
		-- The player picked Sloshcalf (Water): Leaf leads, with Sand and a tank behind it.
		Sloshcalf = {
			members = {
				member(
					"Mossmitt",
					13,
					{ "Bramble Rake", "Thorn Volley", "Leaf Gust", "Moss Slam" }
				),
				member("Spadesnout", 12, { "Dig Strike", "Grit Spray", "Dust Kick", "Scree Kick" }),
				member("Stumpwarden", 12, { "Sap Hammer", "Root Lash", "Moss Slam", "Twig Snap" }),
			},
			tint = 0.25,
		},
	},
	firstBefore = "I picked the one that beats yours. Do not take it personally!",
	firstAfter = "That was luck. Next time I will not lose to a beginner.",
	gateBefore = "I do not play around any more. Not after losing to you.",
	gateAfter = "Again... fine. I will get stronger, whatever it takes.",
}

local pack: WorldTypes.BiomeTamers = { locals = locals, rival = rival }

return pack
