--!strict
-- Hollowbough: Greenwood's giant, the colossal old tree that walks, in the form a player owns
-- after capturing it. Four-legged, Leaf. A bruiser: hits hard, takes hits, slow to turn.
--
-- This is a giant's creature form (giantForm): it is never met in the wild. Its parts are costed
-- at the same budget as every other species (200), so breeding from it cannot break the stat
-- cap; a captured Hollowbough is strong because it is gem-tier and carries two moves nothing
-- else has: Heartwood Slam (its head) and Thorn Gale, a Storm move (its tail), echoing the
-- attacks of the fight in its lair.
--
-- Look (chunky low-poly, flat colours, every joint ends in a rounded ball that sits in its socket):
--   Head: a hollow knot of a face in old bark, two ember-green lights deep inside, a crown of bare antler-like boughs.
--   Torso: a long, split trunk with a hollow you can see through, moss along its back and a few stubborn leaves.
--   Front legs: two heavy root-columns with knuckled knees.
--   Legs: two shorter, wider root-columns, toes splayed like a stump's base.
--   Tail: a trailing bough tipped with a cluster of thorns.
--
-- Weight, lengths and radii are planning values until the art exists.

local Types = require("../../shared/Types")

local Hollowbough: Types.SpeciesDef = {
	name = "Hollowbough",
	bodyPlan = "Quad",
	biome = 1,
	baseRarity = "Uncommon",
	lassoDifficulty = 2.5,
	element = "Leaf",
	weight = 84,
	torsoLength = 6.2,
	giantForm = true,
	socketRadius = {
		Torso = 0,
		Head = 0.9,
		FrontLimbs = 0.66,
		Legs = 0.74,
		Tail = 0.46,
	},
	parts = {
		Head = {
			stats = { Attack = 30, Defence = 10 },
			moves = { { name = "Moss Slam", level = 1 }, { name = "Heartwood Slam", level = 12 } },
			plugRadius = 0.9,
			length = 2.6,
		},
		Torso = {
			stats = { Hp = 120, Attack = 4, Defence = 6 },
			moves = { { name = "Root Lash", level = 1 } },
			plugRadius = 0,
			length = 6.2,
		},
		FrontLimbs = {
			stats = { Hp = 10, Attack = 12, Defence = 14, Speed = 2 },
			moves = { { name = "Twig Snap", level = 1 } },
			plugRadius = 0.66,
			length = 2.6,
		},
		Legs = {
			stats = { Hp = 5, Speed = 28 },
			moves = { { name = "Seed Shot", level = 1 } },
			plugRadius = 0.74,
			length = 2.4,
		},
		Tail = {
			stats = { Hp = 5, Attack = 4, Defence = 4, Speed = 2 },
			moves = { { name = "Fern Whip", level = 1 }, { name = "Thorn Gale", level = 14 } },
			plugRadius = 0.46,
			length = 2.0,
		},
	},
}

return Hollowbough
