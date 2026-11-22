--!strict
-- Spirecap: a swaying sentinel shaped like the canyon's rock spires, with a flat capstone balanced on its head
-- Dust Canyon, two-legged, Sand, Uncommon. Role: all-rounder (sturdy and steady, with a fair turn of speed).
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
	weight = 64,
	torsoLength = 3.6,
	socketRadius = {
		Torso = 0,
		Head = 0.71,
		FrontLimbs = 0.54,
		Legs = 0.71,
		Tail = 0.37,
	},
	parts = {
		Head = {
			stats = { Hp = 6, Attack = 22, Defence = 3, Speed = 5 },
			moves = {
				{ name = "Capstone Crash", level = 1 },
				{ name = "Spire Topple", level = 22 },
			},
			plugRadius = 0.71,
			length = 1.4,
		},
		Torso = {
			stats = { Hp = 109, Attack = 2, Defence = 15, Speed = 2 },
			moves = { { name = "Mesa Slam", level = 1 } },
			plugRadius = 0,
			length = 3.6,
		},
		FrontLimbs = {
			stats = { Hp = 11, Attack = 12, Defence = 9, Speed = 6 },
			moves = { { name = "Pebble Pelt", level = 1 } },
			plugRadius = 0.54,
			length = 1.5,
		},
		Legs = {
			stats = { Hp = 7, Speed = 30 },
			moves = { { name = "Grit Step", level = 1 } },
			plugRadius = 0.71,
			length = 1.0,
		},
		Tail = {
			stats = { Hp = 7, Attack = 1, Defence = 7, Speed = 2 },
			moves = { { name = "Pebble Pelt", level = 1 } },
			plugRadius = 0.37,
			length = 1.0,
		},
	},
}

return Spirecap
