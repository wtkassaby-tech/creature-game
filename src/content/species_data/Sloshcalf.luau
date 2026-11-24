--!strict
-- Sloshcalf: a gentle, round calf that carries a little pond in a clear bubble hump on its back
-- Greenwood, four-legged, Water, Common. Role: fast all-rounder (quick, even Attack and Defence).
-- Starter: the Water starter. Also found wild along the Greenwood stream.
--
-- Look (chunky low-poly, flat colours, every joint ends in a rounded ball that sits in its socket):
--   Head: a broad round calf head with floppy ears shaped like lily pads, a soft blunt nose, and two tiny nub horns of smooth river stone.
--   Torso: a plump blue-grey body with a clear, glassy dome on its back holding water and one floating leaf (a single solid transparent part, no physics).
--   Front legs: two short, sturdy front legs with rounded, webbed hoof-paddles.
--   Hind legs: two sturdy hind legs, a little longer than the front, with the same webbed paddles.
--   Tail: a short tail ending in a fan like a tuft of reeds, with one droplet hanging from the tip.
--
-- Weight, lengths and radii are planning values until the art exists; then they are replaced
-- by measured ones. Part stats follow docs/content/GREENWOOD_ROSTER.md.

local Types = require("../../shared/Types")

local Sloshcalf: Types.SpeciesDef = {
	name = "Sloshcalf",
	bodyPlan = "Quad",
	biome = 1,
	baseRarity = "Common",
	lassoDifficulty = 1.0,
	element = "Water",
	weight = 61,
	torsoLength = 4.1,
	socketRadius = {
		Torso = 0,
		Head = 0.76,
		FrontLimbs = 0.56,
		Legs = 0.64,
		Tail = 0.38,
	},
	parts = {
		Head = {
			stats = { Hp = 15, Attack = 25, Defence = 3, Speed = 3 },
			moves = { { name = "Dew Splash", level = 1 }, { name = "Ripple Ram", level = 10 } },
			plugRadius = 0.76,
			length = 1.8,
		},
		Torso = {
			stats = { Hp = 90, Attack = 3, Defence = 23, Speed = 3 },
			moves = { { name = "Brook Rush", level = 1 }, { name = "Mud Slap", level = 7 } },
			plugRadius = 0,
			length = 4.1,
		},
		FrontLimbs = {
			stats = { Hp = 5, Attack = 12, Defence = 1, Speed = 15 },
			moves = { { name = "Dew Splash", level = 1 } },
			plugRadius = 0.56,
			length = 1.9,
		},
		Legs = {
			stats = { Hp = 5, Speed = 31 },
			moves = { { name = "Puddle Stomp", level = 1 } },
			plugRadius = 0.64,
			length = 1.9,
		},
		Tail = {
			stats = { Hp = 10, Defence = 6 },
			moves = { { name = "Spore Puff", level = 1 } },
			plugRadius = 0.38,
			length = 1.4,
		},
	},
}

return Sloshcalf
