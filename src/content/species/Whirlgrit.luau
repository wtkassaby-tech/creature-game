--!strict
-- Whirlgrit: a spinning little desert dancer that whirls on the spot until the sand around it lifts into a ring
-- Dust Canyon, two-legged, Sand, Common. Role: sprinter (the fastest in Dust Canyon, the least Defence).
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
	weight = 38,
	torsoLength = 2.4,
	socketRadius = {
		Torso = 0,
		Head = 0.6,
		FrontLimbs = 0.46,
		Legs = 0.6,
		Tail = 0.31,
	},
	parts = {
		Head = {
			stats = { Attack = 28, Speed = 10 },
			moves = { { name = "Sand Flick", level = 1 }, { name = "Grit Whirl", level = 17 } },
			plugRadius = 0.6,
			length = 1.1,
		},
		Torso = {
			stats = { Hp = 105, Defence = 16, Speed = 3 },
			moves = { { name = "Dune Dash", level = 1 } },
			plugRadius = 0,
			length = 2.4,
		},
		FrontLimbs = {
			stats = { Hp = 13, Attack = 14, Defence = 4, Speed = 6 },
			moves = { { name = "Pebble Pelt", level = 1 } },
			plugRadius = 0.46,
			length = 1.4,
		},
		Legs = {
			stats = { Hp = 5, Speed = 37 },
			moves = { { name = "Dune Dash", level = 1 } },
			plugRadius = 0.6,
			length = 1.6,
		},
		Tail = {
			stats = { Hp = 5, Defence = 5 },
			moves = { { name = "Sand Flick", level = 1 } },
			plugRadius = 0.31,
			length = 1.0,
		},
	},
}

return Whirlgrit
