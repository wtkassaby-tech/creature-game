--!strict
-- Spurlet: a low, flat succulent creature that sits rooted in the sun by day and scuttles between shadows by night
-- Dust Canyon, four-legged, Leaf, Common. Role: striker (the most Attack on four legs here).
-- Gem-tier ("Amber") individuals are rare wild spawns of this same species, not a separate one.
--
-- Look (chunky low-poly, flat colours, every joint ends in a rounded ball that sits in its socket):
--   Head: a small flattened head with a crown of short, thick, pointed leaves fanning backward, each ending in one dark spine, and a blunt beak-like mouth.
--   Torso: a flat, wide body shaped like a pressed rosette: fleshy leaves overlapping outward from the spine, sage green with pale edges.
--   Front legs: short, bowed forelegs set wide at the sides, each ending in three stubby leaf-tip toes.
--   Hind legs: short, bowed hind legs, also set wide, with knotted root-like heels.
--   Tail: a stiff tail that rises into a single tall flower spike topped with a yellow bud.
--
-- Weight, lengths and radii are planning values until the art exists; then they are replaced
-- by measured ones. Part stats follow docs/content/DUST_CANYON_ROSTER.md.

local Types = require("../../shared/Types")

local Spurlet: Types.SpeciesDef = {
	name = "Spurlet",
	bodyPlan = "Quad",
	biome = 2,
	baseRarity = "Common",
	lassoDifficulty = 1.2,
	element = "Leaf",
	weight = 46,
	torsoLength = 3.4,
	socketRadius = {
		Torso = 0,
		Head = 0.7,
		FrontLimbs = 0.51,
		Legs = 0.58,
		Tail = 0.35,
	},
	parts = {
		Head = {
			stats = { Hp = 5, Attack = 30, Defence = 3, Speed = 5 },
			moves = { { name = "Spine Jab", level = 1 }, { name = "Agave Lance", level = 18 } },
			plugRadius = 0.7,
			length = 1.2,
		},
		Torso = {
			stats = { Hp = 101, Attack = 2, Defence = 13, Speed = 2 },
			moves = { { name = "Needle Fan", level = 1 }, { name = "Dust Squall", level = 14 } },
			plugRadius = 0,
			length = 3.4,
		},
		FrontLimbs = {
			stats = { Hp = 10, Attack = 15, Defence = 8, Speed = 6 },
			moves = { { name = "Spine Jab", level = 1 } },
			plugRadius = 0.51,
			length = 1.2,
		},
		Legs = {
			stats = { Hp = 7, Speed = 29 },
			moves = { { name = "Hoof Scuff", level = 1 } },
			plugRadius = 0.58,
			length = 1.3,
		},
		Tail = {
			stats = { Hp = 7, Attack = 1, Defence = 6, Speed = 2 },
			moves = { { name = "Needle Fan", level = 1 } },
			plugRadius = 0.35,
			length = 1.8,
		},
	},
}

return Spurlet
