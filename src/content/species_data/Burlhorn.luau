--!strict
-- Burlhorn: a slow, stubborn grazer whose back has grown into a knotted burl of living wood
-- Greenwood, four-legged, Leaf, Uncommon. Role: bruiser (hits hard and soaks hits, but slow).
--
-- Look (chunky low-poly, flat colours, every joint ends in a rounded ball that sits in its socket):
--   Head: broad, blunt wooden muzzle with one short, forward-curving horn shaped like a gnarled knot; small amber eyes deep under a mossy brow; ball end at the back of the skull.
--   Torso: wide barrel body of overlapping bark plates, with a big rounded burl hump over the shoulders carrying moss tufts and two tiny mushrooms; dark brown with green moss.
--   Front legs: two thick pillar legs ringed with bark bands, ending in flat, pale wooden pads with three blunt toes.
--   Hind legs: two short, stump-like hind legs with root toes that splay out where they meet the ground.
--   Tail: a short, stiff tail ending in a bundle of twigs like a small broom.
--
-- Weight, lengths and radii are planning values until the art exists; then they are replaced
-- by measured ones. Part stats follow docs/content/GREENWOOD_ROSTER.md.

local Types = require("../../shared/Types")

local Burlhorn: Types.SpeciesDef = {
	name = "Burlhorn",
	bodyPlan = "Quad",
	biome = 1,
	baseRarity = "Uncommon",
	lassoDifficulty = 1.4,
	element = "Leaf",
	weight = 77,
	torsoLength = 5.5,
	socketRadius = {
		Torso = 0,
		Head = 0.84,
		FrontLimbs = 0.6,
		Legs = 0.7,
		Tail = 0.42,
	},
	parts = {
		Head = {
			stats = { Attack = 27, Defence = 16 },
			moves = { { name = "Moss Slam", level = 1 }, { name = "Burl Charge", level = 9 } },
			plugRadius = 0.84,
			length = 2.2,
		},
		Torso = {
			stats = { Hp = 110, Attack = 6, Defence = 5, Speed = 3 },
			moves = { { name = "Root Lash", level = 1 } },
			plugRadius = 0,
			length = 5.5,
		},
		FrontLimbs = {
			stats = { Hp = 8, Attack = 11, Defence = 15, Speed = 3 },
			moves = { { name = "Twig Snap", level = 1 } },
			plugRadius = 0.6,
			length = 2.3,
		},
		Legs = {
			stats = { Hp = 5, Speed = 28 },
			moves = { { name = "Puddle Stomp", level = 1 } },
			plugRadius = 0.7,
			length = 2.2,
		},
		Tail = {
			stats = { Hp = 5, Attack = 3, Defence = 3, Speed = 3 },
			moves = { { name = "Fern Whip", level = 1 } },
			plugRadius = 0.42,
			length = 1.5,
		},
	},
}

return Burlhorn
