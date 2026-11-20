--!strict
-- Thatchling: a shaggy desert sentinel wrapped in a skirt of its own dead leaves, whose crooked arms end in spiky green pompoms
-- Dust Canyon, two-legged, Leaf, Common. Role: all-rounder (the Leaf answer to the canyon's Sand, with a Storm move on its torso).
-- Gem-tier ("Amber") individuals are rare wild spawns of this same species, not a separate one.
--
-- Look (chunky low-poly, flat colours, every joint ends in a rounded ball that sits in its socket):
--   Head: a small round head crowned with a tight rosette of stiff green blades, two dark eyes peering out from the thatch.
--   Torso: a stout, upright trunk wrapped in a shaggy skirt of dry, downward-hanging straw-coloured leaves (stacked low-poly fringe layers).
--   Arms: two crooked, branching arms, each ending in a round pompom of stiff, spiky green leaves.
--   Legs: short, sturdy legs of fibrous bark ending in splayed root toes.
--   Tail: a short tuft of dry leaves that drags in the sand.
--
-- Weight, lengths and radii are planning values until the art exists; then they are replaced
-- by measured ones. Part stats follow docs/content/DUST_CANYON_ROSTER.md.

local Types = require("../../shared/Types")

local Thatchling: Types.SpeciesDef = {
	name = "Thatchling",
	bodyPlan = "Biped",
	biome = 2,
	baseRarity = "Common",
	lassoDifficulty = 1.2,
	element = "Leaf",
	weight = 46,
	torsoLength = 3.0,
	socketRadius = {
		Torso = 0,
		Head = 0.64,
		FrontLimbs = 0.49,
		Legs = 0.64,
		Tail = 0.33,
	},
	parts = {
		Head = {
			stats = { Hp = 5, Attack = 25, Defence = 4, Speed = 5 },
			moves = { { name = "Spine Jab", level = 1 }, { name = "Agave Lance", level = 18 } },
			plugRadius = 0.64,
			length = 1.2,
		},
		Torso = {
			stats = { Hp = 105, Attack = 2, Defence = 16, Speed = 2 },
			moves = { { name = "Needle Fan", level = 1 }, { name = "Dust Squall", level = 14 } },
			plugRadius = 0,
			length = 3.0,
		},
		FrontLimbs = {
			stats = { Hp = 11, Attack = 13, Defence = 9, Speed = 5 },
			moves = { { name = "Spine Jab", level = 1 } },
			plugRadius = 0.49,
			length = 1.8,
		},
		Legs = {
			stats = { Hp = 7, Speed = 28 },
			moves = { { name = "Grit Step", level = 1 } },
			plugRadius = 0.64,
			length = 1.3,
		},
		Tail = {
			stats = { Hp = 7, Attack = 1, Defence = 7, Speed = 2 },
			moves = { { name = "Needle Fan", level = 1 } },
			plugRadius = 0.33,
			length = 0.9,
		},
	},
}

return Thatchling
