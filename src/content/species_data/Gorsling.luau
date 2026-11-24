--!strict
-- Gorsling: a twitchy, whip-thin hedge runner that bolts through the meadow shedding yellow blossom
-- Greenwood, four-legged, Leaf, Common. Role: sprinter (fast, thin Defence).
--
-- Look (chunky low-poly, flat colours, every joint ends in a rounded ball that sits in its socket):
--   Head: long, narrow snout like a greyhound's with two swept-back ears that are sprigs of spiky gorse, a yellow flower tuft at each ear tip, and big round dark eyes.
--   Torso: slim, deep-chested body that tucks up at the waist, light green with a pale belly and a ridge of short blunt spines along the back.
--   Front legs: two long, thin front legs with knobbly knees and small pointed feet.
--   Hind legs: two long, springy hind legs with a high back-bent ankle, made for leaping; darker green with yellow speckles.
--   Tail: a long thin tail ending in a round puff of yellow gorse flowers.
--
-- Weight, lengths and radii are planning values until the art exists; then they are replaced
-- by measured ones. Part stats follow docs/content/GREENWOOD_ROSTER.md.

local Types = require("../../shared/Types")

local Gorsling: Types.SpeciesDef = {
	name = "Gorsling",
	bodyPlan = "Quad",
	biome = 1,
	baseRarity = "Common",
	lassoDifficulty = 1.1,
	element = "Leaf",
	weight = 50,
	torsoLength = 4.4,
	socketRadius = {
		Torso = 0,
		Head = 0.72,
		FrontLimbs = 0.52,
		Legs = 0.6,
		Tail = 0.36,
	},
	parts = {
		Head = {
			stats = { Attack = 27, Defence = 6, Speed = 7 },
			moves = { { name = "Seed Shot", level = 1 }, { name = "Thorn Volley", level = 10 } },
			plugRadius = 0.72,
			length = 1.5,
		},
		Torso = {
			stats = { Hp = 95, Attack = 3, Defence = 14 },
			moves = { { name = "Leaf Gust", level = 1 } },
			plugRadius = 0,
			length = 4.4,
		},
		FrontLimbs = {
			stats = { Hp = 17, Attack = 10, Defence = 6, Speed = 8 },
			moves = { { name = "Twig Snap", level = 1 }, { name = "Bramble Rake", level = 12 } },
			plugRadius = 0.52,
			length = 2.3,
		},
		Legs = {
			stats = { Hp = 5, Speed = 34 },
			moves = { { name = "Gale Hop", level = 1 } },
			plugRadius = 0.6,
			length = 2.6,
		},
		Tail = {
			stats = { Hp = 15, Defence = 3, Speed = 3 },
			moves = { { name = "Pollen Burst", level = 1 } },
			plugRadius = 0.36,
			length = 2.2,
		},
	},
}

return Gorsling
