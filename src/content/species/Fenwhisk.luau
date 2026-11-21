--!strict
-- Fenwhisk: a slinky marsh weasel that darts through the reeds with its bulrush tail held up like a flag
-- Mire, four-legged, Toxic, Common. Role: sprinter, the fastest on four legs, with a poisoning bite on its head.
-- Gem-tier individuals are rare wild spawns of this same species, not a separate one.
--
-- Look (chunky low-poly, flat colours, every joint ends in a rounded ball that sits in its socket):
--   Head: a small, narrow head with a pointed nose, a ruff of stiff reed-like whiskers and sulphur-yellow warning stripes above the eyes.
--   Torso: a very long, low, slinky body in olive green with a sulphur-yellow stripe down the spine.
--   Front legs: short, quick forelegs with small grasping paws.
--   Hind legs: longer, springy hind legs with narrow feet for darting.
--   Tail: a long, thin tail ending in a fat brown bulrush head, held upright.
--
-- Weight, lengths and radii are planning values until the art exists; then they are replaced
-- by measured ones. Part stats follow docs/content/MIRE_ROSTER.md.

local Types = require("../../shared/Types")

local Fenwhisk: Types.SpeciesDef = {
	name = "Fenwhisk",
	bodyPlan = "Quad",
	biome = 4,
	baseRarity = "Common",
	lassoDifficulty = 1.55,
	element = "Toxic",
	weight = 46,
	torsoLength = 4.2,
	socketRadius = {
		Torso = 0,
		Head = 0.7,
		FrontLimbs = 0.51,
		Legs = 0.58,
		Tail = 0.35,
	},
	parts = {
		Head = {
			stats = { Hp = 5, Attack = 24, Defence = 3, Speed = 5 },
			moves = { { name = "Venom Nip", level = 1 }, { name = "Fen Lash", level = 34 } },
			plugRadius = 0.7,
			length = 1.4,
		},
		Torso = {
			stats = { Hp = 93, Attack = 2, Defence = 15, Speed = 2 },
			moves = { { name = "Slick Dash", level = 1 } },
			plugRadius = 0,
			length = 4.2,
		},
		FrontLimbs = {
			stats = { Hp = 11, Attack = 13, Defence = 9, Speed = 6 },
			moves = { { name = "Sludge Slap", level = 1 } },
			plugRadius = 0.51,
			length = 1.6,
		},
		Legs = {
			stats = { Hp = 7, Speed = 31 },
			moves = { { name = "Slick Dash", level = 1 } },
			plugRadius = 0.58,
			length = 2.2,
		},
		Tail = {
			stats = { Hp = 17, Attack = 1, Defence = 7, Speed = 2 },
			moves = { { name = "Sludge Slap", level = 1 } },
			plugRadius = 0.35,
			length = 2.4,
		},
	},
}

return Fenwhisk
