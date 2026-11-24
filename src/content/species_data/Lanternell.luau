--!strict
-- Lanternell: a tall, slow-swaying rock-pool keeper whose lantern head glows at night to guide lost creatures back to the water
-- Tide Flats, two-legged, Water, Uncommon. Role: sturdy all-rounder (the most Defence on two legs, deep Hp, steady Speed).
-- Gem-tier ("Amber") individuals are rare wild spawns of this same species, not a separate one.
--
-- Look (chunky low-poly, flat colours, every joint ends in a rounded ball that sits in its socket):
--   Head: a round, clear, jelly-like dome with a soft glowing core (one solid translucent part, no physics) and a short fringe of frilly tendrils around its rim.
--   Torso: a tall barrel body of stacked pale shell rings like a lighthouse, banded white and sea-green.
--   Arms: long, slender arms ending in soft, anemone-like fans of short rounded fingers.
--   Legs: short, stumpy legs with round suction-cup feet.
--   Tail: a long, trailing ribbon of frilled tendrils.
--
-- Weight, lengths and radii are planning values until the art exists; then they are replaced
-- by measured ones. Part stats follow docs/content/TIDE_FLATS_ROSTER.md.

local Types = require("../../shared/Types")

local Lanternell: Types.SpeciesDef = {
	name = "Lanternell",
	bodyPlan = "Biped",
	biome = 3,
	baseRarity = "Uncommon",
	lassoDifficulty = 2,
	element = "Water",
	weight = 66,
	torsoLength = 3.8,
	socketRadius = {
		Torso = 0,
		Head = 0.72,
		FrontLimbs = 0.55,
		Legs = 0.72,
		Tail = 0.37,
	},
	parts = {
		Head = {
			stats = { Hp = 6, Attack = 21, Defence = 3, Speed = 5 },
			moves = {
				{ name = "Lantern Pulse", level = 1 },
				{ name = "Breaker Charge", level = 30 },
			},
			plugRadius = 0.72,
			length = 1.6,
		},
		Torso = {
			stats = { Hp = 107, Attack = 2, Defence = 24, Speed = 2 },
			moves = { { name = "Tidepool Surge", level = 1 } },
			plugRadius = 0,
			length = 3.8,
		},
		FrontLimbs = {
			stats = { Hp = 11, Attack = 11, Defence = 8, Speed = 5 },
			moves = { { name = "Brine Jab", level = 1 } },
			plugRadius = 0.55,
			length = 1.7,
		},
		Legs = {
			stats = { Hp = 7, Speed = 27 },
			moves = { { name = "Shoal Stomp", level = 1 } },
			plugRadius = 0.72,
			length = 1.4,
		},
		Tail = {
			stats = { Hp = 7, Attack = 1, Defence = 7, Speed = 1 },
			moves = { { name = "Foam Flick", level = 1 } },
			plugRadius = 0.37,
			length = 1.6,
		},
	},
}

return Lanternell
