--!strict
-- Greenwood's tamers: five locals met along the routes, and the rival's two teams. Names are
-- original. Every move is one the creature can know at that level (tests/world.test checks this).
-- Levels rise with the routes (3 to 11) and stay under the gate's 12 to 15, so a player who has
-- fought the tamers on the way arrives at the gate ready. The rival is called "Rival" until his
-- real name is chosen.
--
-- The rival's story is in his teams: ordinary Greenwood creatures in the first battle (tint 0),
-- and a faint dark tint on the gate team (0.25) that grows each time he appears later.
-- On the green he has the starter that LOSES to the player's (he picked for looks, not types);
-- by the gate he leads with the one that beats theirs: Sand beats Leaf, Water beats Sand, Leaf
-- beats Water.

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
		before = "My hat is lucky! Show me what you and your friend can do!",
		after = "Whoa! My lucky hat let me down!",
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
		after = "Fair and square. I will tell the fish it was a big one.",
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
	-- The first bout teaches the first lesson: types. The rival is a brash boy who picked the
	-- creature that LOSES to the player's (Leaf beats Water, Water beats Sand, Sand beats Leaf),
	-- so the player's own moves show STRONG from the first turn and the win is clear, in three
	-- or four turns with health to spare (tests/firstminutes.test.luau). He has learned by the
	-- gate, where he leads with the type that beats theirs. (Until 23 November he brought the
	-- winning type here too: two starters only "won" because this fight cannot be lost, and
	-- even a level 1 opponent left the Leaf starter on its last scrap of health.)
	first = {
		Mossmitt = {
			members = { member("Sloshcalf", 5, { "Dew Splash", "Brook Rush" }) },
			tint = 0,
		},
		Spadesnout = {
			members = { member("Mossmitt", 5, { "Seed Shot", "Moss Slam" }) },
			tint = 0,
		},
		Sloshcalf = {
			members = { member("Spadesnout", 5, { "Grit Spray", "Dust Kick" }) },
			tint = 0,
		},
	},
	gate = {
		-- At the gate he has learned: a creature that beats the player's leads, and the one he
		-- lost with on the green is still with him, behind it.
		-- The player picked Mossmitt (Leaf): Sand leads, and his Sloshcalf is ready behind it.
		Mossmitt = {
			members = {
				member("Spadesnout", 13, { "Dig Strike", "Grit Spray", "Dust Kick", "Scree Kick" }),
				member("Sloshcalf", 12, { "Ripple Ram", "Mud Slap", "Brook Rush", "Spore Puff" }),
				member("Gorsling", 12, { "Thorn Volley", "Bramble Rake", "Leaf Gust", "Gale Hop" }),
			},
			tint = 0.25,
		},
		-- The player picked Spadesnout (Sand): Water leads, with his Mossmitt and a tank behind.
		Spadesnout = {
			members = {
				member("Sloshcalf", 13, { "Ripple Ram", "Mud Slap", "Brook Rush", "Spore Puff" }),
				member(
					"Mossmitt",
					12,
					{ "Thorn Volley", "Bramble Rake", "Moss Slam", "Brook Rush" }
				),
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
	firstBefore = "I picked the coolest one. Types? Who needs them. Watch this!",
	firstAfter = "Gah! Beginner's luck!",
	gateBefore = "I know my types now. This one beats yours. No more playing around.",
	gateAfter = "Tch. Not again.",
}

local pack: WorldTypes.BiomeTamers = { locals = locals, rival = rival }

return pack
