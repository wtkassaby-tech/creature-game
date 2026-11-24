--!strict
-- Sloughback: the Mire's giant, the newt of the Sunken Grove, in the form a player owns after
-- capturing it. Four-legged, Toxic. A slow, deep-bodied tank: a big pile of Hp in the torso and,
-- like every Mire creature, in its heavy tail (the Mire's breeding stat), with solid Defence.
--
-- This is a giant's creature form (giantForm): it is never met in the wild. Its parts are costed
-- at the same budget as every other species (200), so breeding from it cannot break the stat
-- cap; a captured Sloughback is strong because it is gem-tier and carries two moves nothing else
-- has: Marsh Gas (its head) and Sinking Pull, a Water move (its tail) that lets a Toxic creature
-- answer the Sand creatures that beat it, echoing the fight in its grove. Neither poisons: in this
-- roster poisoning moves are kept weak, and a signature move should not be.
--
-- Look (chunky low-poly, flat colours, every joint ends in a rounded ball that sits in its socket):
--   Head: a broad, flat newt head with a wide smiling mouth, small gold eyes high on top, and frilly gill stalks like mangrove roots behind each cheek.
--   Torso: a long, deep body in dark olive with a sulphur-yellow belly, its back a low mound of mud and moss with three little mangrove trees growing on it.
--   Front legs: short, splayed forelegs with four round-tipped fingers, mud up to the elbows.
--   Hind legs: thick, splayed hind legs with five broad, webbed toes.
--   Tail: a long, tall, paddle-like tail hung with trailing roots, two soft green marsh lights dangling from them like lures.
--
-- Weight, lengths and radii are planning values until the art exists. The name is a placeholder.

local Types = require("../../shared/Types")

local Sloughback: Types.SpeciesDef = {
	name = "Sloughback",
	bodyPlan = "Quad",
	biome = 4,
	baseRarity = "Uncommon",
	lassoDifficulty = 2.5,
	element = "Toxic",
	weight = 86,
	torsoLength = 6.6,
	giantForm = true,
	socketRadius = {
		Torso = 0,
		Head = 0.88,
		FrontLimbs = 0.64,
		Legs = 0.76,
		Tail = 0.5,
	},
	parts = {
		Head = {
			stats = { Hp = 6, Attack = 25, Defence = 4, Speed = 2 },
			moves = {
				{ name = "Peat Butt", level = 1 },
				{ name = "Marsh Gas", level = 38 },
			},
			plugRadius = 0.88,
			length = 2.2,
		},
		Torso = {
			stats = { Hp = 103, Attack = 2, Defence = 23, Speed = 2 },
			moves = { { name = "Murk Lunge", level = 1 } },
			plugRadius = 0,
			length = 6.6,
		},
		FrontLimbs = {
			stats = { Hp = 10, Attack = 13, Defence = 9, Speed = 3 },
			moves = { { name = "Muck Stamp", level = 1 } },
			plugRadius = 0.64,
			length = 2.2,
		},
		Legs = {
			stats = { Hp = 6, Speed = 19 },
			moves = { { name = "Bog Wade", level = 1 } },
			plugRadius = 0.76,
			length = 2.0,
		},
		Tail = {
			stats = { Hp = 20, Attack = 2, Defence = 6, Speed = 3 },
			moves = { { name = "Sludge Slap", level = 1 }, { name = "Sinking Pull", level = 40 } },
			plugRadius = 0.5,
			length = 3.4,
		},
	},
}

return Sloughback
