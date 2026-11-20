--!strict
-- Cairnback: a sure-footed mesa climber built like a walking pile of trail-marker stones
-- Dust Canyon, four-legged, Sand, Uncommon. Role: bruiser (the most Hp and Defence on four legs here, and the slowest).
-- Gem-tier ("Amber") individuals are rare wild spawns of this same species, not a separate one.
--
-- Look (chunky low-poly, flat colours, every joint ends in a rounded ball that sits in its socket):
--   Head: a heavy round boulder of a head with a flat slate brow, two stubby rounded horns of stacked pebbles and a lower jaw like a stone slab.
--   Torso: a deep body of three big rounded stones stacked front to back, the middle one tallest, speckled with lichen-orange spots.
--   Front legs: short, thick forelegs of two stacked stone drums each, ending in squared-off hooves.
--   Hind legs: short, sturdy hind legs with split, goat-like hooves for gripping ledges.
--   Tail: a short stub of three shrinking pebbles in a row.
--
-- Weight, lengths and radii are planning values until the art exists; then they are replaced
-- by measured ones. Part stats follow docs/content/DUST_CANYON_ROSTER.md.

local Types = require("../../shared/Types")

local Cairnback: Types.SpeciesDef = {
	name = "Cairnback",
	bodyPlan = "Quad",
	biome = 2,
	baseRarity = "Uncommon",
	lassoDifficulty = 1.7,
	element = "Sand",
	weight = 58,
	torsoLength = 4.6,
	socketRadius = {
		Torso = 0,
		Head = 0.76,
		FrontLimbs = 0.55,
		Legs = 0.63,
		Tail = 0.38,
	},
	parts = {
		Head = {
			stats = { Hp = 10, Attack = 28, Defence = 6 },
			moves = { { name = "Capstone Crash", level = 1 }, { name = "Talus Tumble", level = 20 } },
			plugRadius = 0.76,
			length = 1.9,
		},
		Torso = {
			stats = { Hp = 100, Defence = 17, Speed = 3 },
			moves = { { name = "Mesa Slam", level = 1 }, { name = "Tumbleweed Toss", level = 16 } },
			plugRadius = 0,
			length = 4.6,
		},
		FrontLimbs = {
			stats = { Attack = 13, Defence = 18, Speed = 2 },
			moves = { { name = "Pebble Pelt", level = 1 } },
			plugRadius = 0.55,
			length = 1.8,
		},
		Legs = {
			stats = { Hp = 5, Speed = 29 },
			moves = { { name = "Hoof Scuff", level = 1 } },
			plugRadius = 0.63,
			length = 1.8,
		},
		Tail = {
			stats = { Hp = 5, Attack = 4, Defence = 8 },
			moves = { { name = "Pebble Pelt", level = 1 } },
			plugRadius = 0.38,
			length = 1.2,
		},
	},
}

return Cairnback
