--!strict
-- Whirlgrit: a spinning little desert dancer that whirls on the spot until the sand around it lifts into a ring
-- Dust Canyon, two-legged, Sand, Common. Role: sprinter (the fastest on two legs here, the least Defence).
-- Gem-tier ("Amber") individuals are rare wild spawns of this same species, not a separate one.
--
-- Look (chunky low-poly, flat colours, every joint ends in a rounded ball that sits in its socket):
--   Head: a round head under a wide, flat stone brim like a hat, two big goggle eyes behind a band of darker stripes.
--   Torso: a short body tapered like a spinning top, with a loose ring of packed sand floating just off its waist (one solid part).
--   Arms: thin arms ending in flat, fan-shaped hands of three fused fingers, held out for balance.
--   Legs: short, quick, bent legs with two-toed gripping feet.
--   Tail: a short corkscrew tail of twisted sandstone.
--
-- Weight, lengths and radii are planning values until the art exists; then they are replaced
-- by measured ones. Part stats follow docs/content/DUST_CANYON_ROSTER.md.

local Types = require("../../shared/Types")

local Whirlgrit: Types.SpeciesDef = {
	name = "Whirlgrit",
	bodyPlan = "Biped",
	biome = 2,
	baseRarity = "Common",
	lassoDifficulty = 1.3,
	element = "Sand",
	weight = 36,
	torsoLength = 2.4,
	socketRadius = {
		Torso = 0,
		Head = 0.59,
		FrontLimbs = 0.45,
		Legs = 0.59,
		Tail = 0.3,
	},
	parts = {
		Head = {
			stats = { Hp = 5, Attack = 26, Defence = 2, Speed = 7 },
			moves = { { name = "Sand Flick", level = 1 }, { name = "Grit Whirl", level = 17 } },
			plugRadius = 0.59,
			length = 1.1,
		},
		Torso = {
			stats = { Hp = 105, Attack = 2, Defence = 8, Speed = 3 },
			moves = { { name = "Dune Dash", level = 1 } },
			plugRadius = 0,
			length = 2.4,
		},
		FrontLimbs = {
			stats = { Hp = 11, Attack = 13, Defence = 5, Speed = 8 },
			moves = { { name = "Pebble Pelt", level = 1 } },
			plugRadius = 0.45,
			length = 1.4,
		},
		Legs = {
			stats = { Hp = 7, Speed = 38 },
			moves = { { name = "Dune Dash", level = 1 } },
			plugRadius = 0.59,
			length = 1.6,
		},
		Tail = {
			stats = { Hp = 7, Attack = 1, Defence = 4, Speed = 2 },
			moves = { { name = "Sand Flick", level = 1 } },
			plugRadius = 0.3,
			length = 1.0,
		},
	},
}

return Whirlgrit
