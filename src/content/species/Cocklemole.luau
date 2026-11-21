--!strict
-- Cocklemole: a beach burrower that wears a ribbed cockle shell as a helmet and digs faster than the tide can fill its holes
-- Tide Flats, four-legged, Sand, Common. Role: all-rounder, the lone Sand species on four legs, with a Toxic move on its torso to answer the Water majority.
-- Gem-tier ("Amber") individuals are rare wild spawns of this same species, not a separate one.
--
-- Look (chunky low-poly, flat colours, every joint ends in a rounded ball that sits in its socket):
--   Head: a blunt, whiskered head under a big ribbed, fan-shaped cockle shell worn like a helmet, with a pink star-shaped nose.
--   Torso: a round, compact body of packed damp sand with a band of broken shell pieces around the middle.
--   Front legs: short, wide forelegs with huge flat scoop claws.
--   Hind legs: short, stout hind legs with flat paddle feet that kick sand out behind.
--   Tail: a short, stiff tail tipped with a little coiled cast of sand.
--
-- Weight, lengths and radii are planning values until the art exists; then they are replaced
-- by measured ones. Part stats follow docs/content/TIDE_FLATS_ROSTER.md.

local Types = require("../../shared/Types")

local Cocklemole: Types.SpeciesDef = {
	name = "Cocklemole",
	bodyPlan = "Quad",
	biome = 3,
	baseRarity = "Common",
	lassoDifficulty = 1.4,
	element = "Sand",
	weight = 60,
	torsoLength = 3.6,
	socketRadius = {
		Torso = 0,
		Head = 0.76,
		FrontLimbs = 0.56,
		Legs = 0.64,
		Tail = 0.38,
	},
	parts = {
		Head = {
			stats = { Hp = 5, Attack = 26, Defence = 3, Speed = 5 },
			moves = { { name = "Cockle Crack", level = 1 }, { name = "Shell Grind", level = 28 } },
			plugRadius = 0.76,
			length = 1.5,
		},
		Torso = {
			stats = { Hp = 99, Attack = 2, Defence = 20, Speed = 2 },
			moves = { { name = "Burrow Burst", level = 1 }, { name = "Red Tide", level = 24 } },
			plugRadius = 0,
			length = 3.6,
		},
		FrontLimbs = {
			stats = { Hp = 10, Attack = 14, Defence = 7, Speed = 6 },
			moves = { { name = "Sand Scoop", level = 1 } },
			plugRadius = 0.56,
			length = 1.4,
		},
		Legs = {
			stats = { Hp = 7, Speed = 30 },
			moves = { { name = "Shoal Stomp", level = 1 } },
			plugRadius = 0.64,
			length = 1.3,
		},
		Tail = {
			stats = { Hp = 7, Attack = 1, Defence = 6, Speed = 1 },
			moves = { { name = "Sand Scoop", level = 1 } },
			plugRadius = 0.38,
			length = 0.9,
		},
	},
}

return Cocklemole
