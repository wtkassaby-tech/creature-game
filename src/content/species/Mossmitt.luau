--!strict
-- Mossmitt: a cheerful little brawler whose fists are two huge balls of moss
-- Greenwood, two-legged, Leaf, Common. Role: all-rounder (even stats).
-- Starter: the Leaf starter. Also found wild in the mossy glade near the hub town.
--
-- Look (chunky low-poly, flat colours, every joint ends in a rounded ball that sits in its socket):
--   Head: a round, pebble-grey head with big eyes, a wide grin and a clover tuft on top.
--   Torso: a pear-shaped body with a soft moss patch on the belly and a bark-brown back.
--   Arms: two short arms ending in oversized round mitts of moss, like boxing gloves.
--   Legs: two short stubby legs with flat round feet.
--   Tail: a curled fern frond, rolled into a spiral at the tip.
--
-- Weight, lengths and radii are planning values until the art exists; then they are replaced
-- by measured ones. Part stats follow docs/content/GREENWOOD_ROSTER.md.

local Types = require("../../shared/Types")

local Mossmitt: Types.SpeciesDef = {
	name = "Mossmitt",
	bodyPlan = "Biped",
	biome = 1,
	baseRarity = "Common",
	lassoDifficulty = 1.0,
	element = "Leaf",
	weight = 50,
	torsoLength = 3.2,
	socketRadius = {
		Torso = 0,
		Head = 0.66,
		FrontLimbs = 0.5,
		Legs = 0.66,
		Tail = 0.34,
	},
	parts = {
		Head = {
			stats = { Hp = 10, Attack = 22, Defence = 6, Speed = 6 },
			moves = { { name = "Seed Shot", level = 1 }, { name = "Thorn Volley", level = 10 } },
			plugRadius = 0.66,
			length = 1.3,
		},
		Torso = {
			stats = { Hp = 110, Attack = 3, Defence = 11, Speed = 3 },
			moves = { { name = "Moss Slam", level = 1 }, { name = "Brook Rush", level = 8 } },
			plugRadius = 0,
			length = 3.2,
		},
		FrontLimbs = {
			stats = { Hp = 10, Attack = 15, Defence = 10 },
			moves = { { name = "Twig Snap", level = 1 }, { name = "Bramble Rake", level = 10 } },
			plugRadius = 0.5,
			length = 1.6,
		},
		Legs = {
			stats = { Defence = 3, Speed = 31 },
			moves = { { name = "Leaf Gust", level = 1 } },
			plugRadius = 0.66,
			length = 1.2,
		},
		Tail = {
			stats = { Hp = 5, Defence = 9 },
			moves = { { name = "Spore Puff", level = 1 } },
			plugRadius = 0.34,
			length = 1.0,
		},
	},
}

return Mossmitt
