--!strict
-- Bulbroth: a pot-bellied swamp cook whose round belly bubbles like a cauldron of green broth
-- Mire, two-legged, Toxic, Uncommon. Role: sturdy all-rounder, the most Hp in the Mire and the slowest on two legs, with a poisoning spit on its head.
-- Gem-tier individuals are rare wild spawns of this same species, not a separate one.
--
-- Look (chunky low-poly, flat colours, every joint ends in a rounded ball that sits in its socket):
--   Head: a wide, flat, frog-like head with a broad lip, heavy-lidded eyes and a lily pad worn flat on top like a cap.
--   Torso: a big, round pot belly of translucent green rimmed at the top like a cauldron (one solid translucent part; the bubbles are a particle effect).
--   Arms: short, thick arms ending in broad, ladle-shaped hands.
--   Legs: short, bowed legs with small round-toed feet.
--   Tail: a heavy, rounded tail like a sagging water bag that drags behind it.
--
-- Weight, lengths and radii are planning values until the art exists; then they are replaced
-- by measured ones. Part stats follow docs/content/MIRE_ROSTER.md.

local Types = require("../../shared/Types")

local Bulbroth: Types.SpeciesDef = {
	name = "Bulbroth",
	bodyPlan = "Biped",
	biome = 4,
	baseRarity = "Uncommon",
	lassoDifficulty = 2.2,
	element = "Toxic",
	weight = 70,
	torsoLength = 3.7,
	socketRadius = {
		Torso = 0,
		Head = 0.74,
		FrontLimbs = 0.56,
		Legs = 0.74,
		Tail = 0.38,
	},
	parts = {
		Head = {
			stats = { Hp = 6, Attack = 26, Defence = 3, Speed = 4 },
			moves = { { name = "Broth Spit", level = 1 }, { name = "Mire Crush", level = 38 } },
			plugRadius = 0.74,
			length = 1.4,
		},
		Torso = {
			stats = { Hp = 105, Attack = 2, Defence = 15, Speed = 1 },
			moves = { { name = "Simmer Slam", level = 1 } },
			plugRadius = 0,
			length = 3.7,
		},
		FrontLimbs = {
			stats = { Hp = 12, Attack = 13, Defence = 9, Speed = 5 },
			moves = { { name = "Muck Stamp", level = 1 } },
			plugRadius = 0.56,
			length = 1.7,
		},
		Legs = {
			stats = { Hp = 7, Speed = 23 },
			moves = { { name = "Bog Wade", level = 1 } },
			plugRadius = 0.74,
			length = 1.2,
		},
		Tail = {
			stats = { Hp = 20, Attack = 1, Defence = 7, Speed = 1 },
			moves = { { name = "Sludge Slap", level = 1 } },
			plugRadius = 0.38,
			length = 1.2,
		},
	},
}

return Bulbroth
