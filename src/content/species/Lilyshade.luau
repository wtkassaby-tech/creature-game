--!strict
-- Lilyshade: a slender pond keeper that wears a broad lily pad like a sun hat and trails a cold mist wherever it walks
-- Mire, two-legged, Water, Common. Role: sturdy all-rounder, the lone Water species on two legs, with a Frost move on its torso to answer the Toxic majority.
-- Gem-tier individuals are rare wild spawns of this same species, not a separate one.
--
-- Look (chunky low-poly, flat colours, every joint ends in a rounded ball that sits in its socket):
--   Head: a small, smooth oval face under a broad lily pad worn like a wide-brimmed hat, a single white water lily on the brim.
--   Torso: a tall, slender body like a bound bundle of reeds, pond green with a pale frosty sheen at the shoulders.
--   Arms: long, thin arms that end in fronds of trailing water roots.
--   Legs: short legs half hidden under a skirt of hanging roots, ending in rounded root feet.
--   Tail: a long, trailing train of water roots and duckweed.
--
-- Weight, lengths and radii are planning values until the art exists; then they are replaced
-- by measured ones. Part stats follow docs/content/MIRE_ROSTER.md.

local Types = require("../../shared/Types")

local Lilyshade: Types.SpeciesDef = {
	name = "Lilyshade",
	bodyPlan = "Biped",
	biome = 4,
	baseRarity = "Common",
	lassoDifficulty = 1.5,
	element = "Water",
	weight = 60,
	torsoLength = 3.4,
	socketRadius = {
		Torso = 0,
		Head = 0.7,
		FrontLimbs = 0.53,
		Legs = 0.7,
		Tail = 0.36,
	},
	parts = {
		Head = {
			stats = { Hp = 6, Attack = 26, Defence = 3, Speed = 4 },
			moves = { { name = "Mist Snap", level = 1 }, { name = "Fen Plunge", level = 36 } },
			plugRadius = 0.7,
			length = 1.5,
		},
		Torso = {
			stats = { Hp = 101, Attack = 2, Defence = 16, Speed = 2 },
			moves = { { name = "Still Water", level = 1 }, { name = "Hoarmist", level = 34 } },
			plugRadius = 0,
			length = 3.4,
		},
		FrontLimbs = {
			stats = { Hp = 12, Attack = 13, Defence = 10, Speed = 5 },
			moves = { { name = "Reed Paddle", level = 1 } },
			plugRadius = 0.53,
			length = 1.8,
		},
		Legs = {
			stats = { Hp = 7, Speed = 23 },
			moves = { { name = "Bog Wade", level = 1 } },
			plugRadius = 0.7,
			length = 1.3,
		},
		Tail = {
			stats = { Hp = 19, Attack = 1, Defence = 7, Speed = 1 },
			moves = { { name = "Reed Paddle", level = 1 } },
			plugRadius = 0.36,
			length = 1.6,
		},
	},
}

return Lilyshade
