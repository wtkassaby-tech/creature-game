--!strict
-- Stiltbark: a tall, nervous wader on birch-twig stilts that can outrun anything in the reeds
-- Greenwood, two-legged, Leaf, Uncommon. Role: sprinter (the fastest in Greenwood; very thin Defence, deep Hp).
--
-- Look (chunky low-poly, flat colours, every joint ends in a rounded ball that sits in its socket):
--   Head: a small round head with a long, thin beak shaped like a seed pod and a crest of three curled leaves.
--   Torso: a small egg-shaped body of pale birch bark with dark horizontal marks.
--   Arms: two short folded arms ending in three leaf-blade fingers (no feathers).
--   Legs: two very long, thin, jointed stilt legs like birch twigs, with wide three-toed feet.
--   Tail: a short fan of stiff, narrow leaves.
--
-- Weight, lengths and radii are planning values until the art exists; then they are replaced
-- by measured ones. Part stats follow docs/content/GREENWOOD_ROSTER.md.

local Types = require("../../shared/Types")

local Stiltbark: Types.SpeciesDef = {
	name = "Stiltbark",
	bodyPlan = "Biped",
	biome = 1,
	baseRarity = "Uncommon",
	lassoDifficulty = 1.5,
	element = "Leaf",
	weight = 43,
	torsoLength = 2.7,
	socketRadius = {
		Torso = 0,
		Head = 0.62,
		FrontLimbs = 0.48,
		Legs = 0.62,
		Tail = 0.32,
	},
	parts = {
		Head = {
			stats = { Attack = 30, Speed = 10 },
			moves = { { name = "Seed Shot", level = 1 }, { name = "Thorn Volley", level = 10 } },
			plugRadius = 0.62,
			length = 1.4,
		},
		Torso = {
			stats = { Hp = 115, Defence = 11, Speed = 3 },
			moves = { { name = "Leaf Gust", level = 1 } },
			plugRadius = 0,
			length = 2.7,
		},
		FrontLimbs = {
			stats = { Hp = 22, Attack = 10, Defence = 3, Speed = 8 },
			moves = { { name = "Fern Whip", level = 1 }, { name = "Canopy Drop", level = 12 } },
			plugRadius = 0.48,
			length = 1.4,
		},
		Legs = {
			stats = { Speed = 34 },
			moves = { { name = "Gale Hop", level = 1 } },
			plugRadius = 0.62,
			length = 2.9,
		},
		Tail = {
			stats = { Hp = 5, Defence = 6 },
			moves = { { name = "Pollen Burst", level = 1 } },
			plugRadius = 0.32,
			length = 1.0,
		},
	},
}

return Stiltbark
