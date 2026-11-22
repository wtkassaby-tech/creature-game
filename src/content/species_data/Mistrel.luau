--!strict
-- Mistrel: a stocky swamp tapir draped in hanging moss, which blows a cold mist from its trunk to hide in at dawn
-- Mire, four-legged, Water, Common. Role: all-rounder, the lone Water species on four legs, with a Frost move on its torso to answer the Toxic majority.
-- Gem-tier individuals are rare wild spawns of this same species, not a separate one.
--
-- Look (chunky low-poly, flat colours, every joint ends in a rounded ball that sits in its socket):
--   Head: a heavy, rounded head with a short, bendy trunk-like snout, small round ears and a frosty white blaze.
--   Torso: a rounded, barrel-shaped body in slate blue, with a shawl of hanging grey swamp moss over the shoulders, its tips white with frost.
--   Front legs: sturdy, straight forelegs with three blunt toes.
--   Hind legs: sturdy hind legs with four blunt toes.
--   Tail: a short, stubby tail with a frosted tuft.
--
-- Weight, lengths and radii are planning values until the art exists; then they are replaced
-- by measured ones. Part stats follow docs/content/MIRE_ROSTER.md.

local Types = require("../../shared/Types")

local Mistrel: Types.SpeciesDef = {
	name = "Mistrel",
	bodyPlan = "Quad",
	biome = 4,
	baseRarity = "Common",
	lassoDifficulty = 1.5,
	element = "Water",
	weight = 74,
	torsoLength = 4.3,
	socketRadius = {
		Torso = 0,
		Head = 0.82,
		FrontLimbs = 0.6,
		Legs = 0.68,
		Tail = 0.41,
	},
	parts = {
		Head = {
			stats = { Hp = 5, Attack = 28, Defence = 3, Speed = 4 },
			moves = { { name = "Mist Snap", level = 1 }, { name = "Fen Plunge", level = 36 } },
			plugRadius = 0.82,
			length = 1.6,
		},
		Torso = {
			stats = { Hp = 94, Attack = 2, Defence = 18, Speed = 1 },
			moves = { { name = "Murk Dive", level = 1 }, { name = "Hoarmist", level = 34 } },
			plugRadius = 0,
			length = 4.3,
		},
		FrontLimbs = {
			stats = { Hp = 11, Attack = 15, Defence = 11, Speed = 4 },
			moves = { { name = "Reed Paddle", level = 1 } },
			plugRadius = 0.6,
			length = 1.5,
		},
		Legs = {
			stats = { Hp = 7, Speed = 22 },
			moves = { { name = "Bog Wade", level = 1 } },
			plugRadius = 0.68,
			length = 1.6,
		},
		Tail = {
			stats = { Hp = 18, Attack = 1, Defence = 8, Speed = 2 },
			moves = { { name = "Reed Paddle", level = 1 } },
			plugRadius = 0.41,
			length = 2.1,
		},
	},
}

return Mistrel
