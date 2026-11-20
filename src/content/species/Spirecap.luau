--!strict
-- Spirecap: a slow-swaying sentinel shaped like the canyon's rock spires, with a flat capstone balanced on its head
-- Dust Canyon, two-legged, Sand, Uncommon. Role: tank (the most Hp and Defence on two legs here, slow).
-- Gem-tier ("Amber") individuals are rare wild spawns of this same species, not a separate one.
--
-- Look (chunky low-poly, flat colours, every joint ends in a rounded ball that sits in its socket):
--   Head: a small head under a wide, flat, overhanging capstone slab, two glowing yellow eyes in its shade.
--   Torso: a tall, tapering column of banded rock in rust, cream and red stripes, thickest at the base.
--   Arms: short, thick stone arms with round knuckled fists.
--   Legs: very short, wide legs like the foot of a pillar, with flat round feet.
--   Tail: a stubby wedge of rock that props it up when it stands still.
--
-- Weight, lengths and radii are planning values until the art exists; then they are replaced
-- by measured ones. Part stats follow docs/content/DUST_CANYON_ROSTER.md.

local Types = require("../../shared/Types")

local Spirecap: Types.SpeciesDef = {
	name = "Spirecap",
	bodyPlan = "Biped",
	biome = 2,
	baseRarity = "Uncommon",
	lassoDifficulty = 1.8,
	element = "Sand",
	weight = 60,
	torsoLength = 3.6,
	socketRadius = {
		Torso = 0,
		Head = 0.7,
		FrontLimbs = 0.53,
		Legs = 0.7,
		Tail = 0.36,
	},
	parts = {
		Head = {
			stats = { Hp = 10, Attack = 26, Defence = 6 },
			moves = { { name = "Capstone Crash", level = 1 }, { name = "Spire Topple", level = 22 } },
			plugRadius = 0.7,
			length = 1.4,
		},
		Torso = {
			stats = { Hp = 115, Defence = 14 },
			moves = { { name = "Mesa Slam", level = 1 } },
			plugRadius = 0,
			length = 3.6,
		},
		FrontLimbs = {
			stats = { Hp = 10, Attack = 13, Defence = 12 },
			moves = { { name = "Pebble Pelt", level = 1 } },
			plugRadius = 0.53,
			length = 1.5,
		},
		Legs = {
			stats = { Defence = 4, Speed = 31 },
			moves = { { name = "Hoof Scuff", level = 1 } },
			plugRadius = 0.7,
			length = 1.0,
		},
		Tail = {
			stats = { Hp = 10, Defence = 6 },
			moves = { { name = "Pebble Pelt", level = 1 } },
			plugRadius = 0.36,
			length = 1.0,
		},
	},
}

return Spirecap
