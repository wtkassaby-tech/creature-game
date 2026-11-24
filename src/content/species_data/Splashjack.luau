--!strict
-- Splashjack: a lanky reed-bed hopper with huge paddle feet that slaps the water to soak whatever it is fighting
-- Greenwood, two-legged, Water, Common. Role: all-rounder (even Attack, Defence and Speed).
--
-- Look (chunky low-poly, flat colours, every joint ends in a rounded ball that sits in its socket):
--   Head: a narrow head with a long, flat, ladle-shaped bill, two round eyes on top like a periscope and a short crest of reed blades.
--   Torso: an upright, bean-shaped body with smooth, wet-looking teal skin, a pale belly and a row of dark river-pebble spots.
--   Arms: two thin arms with three long, webbed fingers.
--   Legs: two huge hopping legs with long, flat, paddle-shaped webbed feet.
--   Tail: a long, flat tail like a beaver's paddle, used to slap the water.
--
-- Weight, lengths and radii are planning values until the art exists; then they are replaced
-- by measured ones. Part stats follow docs/content/GREENWOOD_ROSTER.md.

local Types = require("../../shared/Types")

local Splashjack: Types.SpeciesDef = {
	name = "Splashjack",
	bodyPlan = "Biped",
	biome = 1,
	baseRarity = "Common",
	lassoDifficulty = 1.0,
	element = "Water",
	weight = 52,
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
			stats = { Hp = 3, Attack = 32, Defence = 3, Speed = 3 },
			moves = { { name = "Dew Splash", level = 1 }, { name = "Ripple Ram", level = 9 } },
			plugRadius = 0.66,
			length = 1.3,
		},
		Torso = {
			stats = { Hp = 100, Defence = 17, Speed = 3 },
			moves = { { name = "Brook Rush", level = 1 }, { name = "Silt Surge", level = 7 } },
			plugRadius = 0,
			length = 3.2,
		},
		FrontLimbs = {
			stats = { Hp = 17, Attack = 11, Defence = 12, Speed = 1 },
			moves = { { name = "Puddle Stomp", level = 1 } },
			plugRadius = 0.5,
			length = 1.4,
		},
		Legs = {
			stats = { Speed = 34 },
			moves = { { name = "Dew Splash", level = 1 } },
			plugRadius = 0.66,
			length = 2.1,
		},
		Tail = {
			stats = { Hp = 5, Defence = 9 },
			moves = { { name = "Spore Puff", level = 1 } },
			plugRadius = 0.34,
			length = 1.9,
		},
	},
}

return Splashjack
