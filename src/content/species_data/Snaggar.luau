--!strict
-- Snaggar: a long-snouted swamp lurker that lies still among the mangrove roots until something passes within reach of its needle-toothed jaws
-- Mire, four-legged, Toxic, Common. Role: striker, the most Attack on four legs, with a poisoning sting on its tail.
-- Gem-tier individuals are rare wild spawns of this same species, not a separate one.
--
-- Look (chunky low-poly, flat colours, every joint ends in a rounded ball that sits in its socket):
--   Head: a very long, narrow snout like a gar fish's, lined with needle teeth that show even when it is shut, the eyes on two bumps on top.
--   Torso: a long, low body of diamond-shaped scales in murky green and bronze, with a ridge of broken, snag-like twigs along the spine.
--   Front legs: short, sprawling forelegs with hooked claws.
--   Hind legs: sprawling, bent hind legs with hooked, half-webbed feet.
--   Tail: a thick, tapering tail tipped with a cluster of barbed thorns.
--
-- Weight, lengths and radii are planning values until the art exists; then they are replaced
-- by measured ones. Part stats follow docs/content/MIRE_ROSTER.md.

local Types = require("../../shared/Types")

local Snaggar: Types.SpeciesDef = {
	name = "Snaggar",
	bodyPlan = "Quad",
	biome = 4,
	baseRarity = "Common",
	lassoDifficulty = 1.5,
	element = "Toxic",
	weight = 70,
	torsoLength = 4.6,
	socketRadius = {
		Torso = 0,
		Head = 0.8,
		FrontLimbs = 0.59,
		Legs = 0.67,
		Tail = 0.4,
	},
	parts = {
		Head = {
			stats = { Hp = 6, Attack = 29, Defence = 3, Speed = 4 },
			moves = { { name = "Gar Rend", level = 1 }, { name = "Snag Bite", level = 36 } },
			plugRadius = 0.8,
			length = 2.3,
		},
		Torso = {
			stats = { Hp = 98, Attack = 2, Defence = 15, Speed = 1 },
			moves = { { name = "Murk Lunge", level = 1 } },
			plugRadius = 0,
			length = 4.6,
		},
		FrontLimbs = {
			stats = { Hp = 11, Attack = 15, Defence = 9, Speed = 5 },
			moves = { { name = "Muck Stamp", level = 1 } },
			plugRadius = 0.59,
			length = 1.5,
		},
		Legs = {
			stats = { Hp = 7, Speed = 23 },
			moves = { { name = "Bog Wade", level = 1 } },
			plugRadius = 0.67,
			length = 1.5,
		},
		Tail = {
			stats = { Hp = 18, Attack = 2, Defence = 7, Speed = 1 },
			moves = { { name = "Barb Sting", level = 1 } },
			plugRadius = 0.4,
			length = 2,
		},
	},
}

return Snaggar
