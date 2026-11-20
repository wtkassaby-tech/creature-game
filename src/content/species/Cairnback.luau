--!strict
-- Cairnback: a sure-footed mesa climber built like a walking pile of trail-marker stones
-- Dust Canyon, four-legged, Sand, Uncommon. Role: bruiser (the most Defence in Dust Canyon, and the slowest).
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
	weight = 64,
	torsoLength = 4.6,
	socketRadius = {
		Torso = 0,
		Head = 0.78,
		FrontLimbs = 0.57,
		Legs = 0.65,
		Tail = 0.39,
	},
	parts = {
		Head = {
			stats = { Hp = 5, Attack = 29, Defence = 4, Speed = 4 },
			moves = {
				{ name = "Capstone Crash", level = 1 },
				{ name = "Talus Tumble", level = 20 },
			},
			plugRadius = 0.78,
			length = 1.9,
		},
		Torso = {
			stats = { Hp = 101, Attack = 2, Defence = 18, Speed = 2 },
			moves = { { name = "Mesa Slam", level = 1 }, { name = "Tumbleweed Toss", level = 16 } },
			plugRadius = 0,
			length = 4.6,
		},
		FrontLimbs = {
			stats = { Hp = 10, Attack = 15, Defence = 10, Speed = 5 },
			moves = { { name = "Pebble Pelt", level = 1 } },
			plugRadius = 0.57,
			length = 1.8,
		},
		Legs = {
			stats = { Hp = 7, Speed = 24 },
			moves = { { name = "Hoof Scuff", level = 1 } },
			plugRadius = 0.65,
			length = 1.8,
		},
		Tail = {
			stats = { Hp = 7, Attack = 1, Defence = 8, Speed = 1 },
			moves = { { name = "Pebble Pelt", level = 1 } },
			plugRadius = 0.39,
			length = 1.2,
		},
	},
}

return Cairnback
