--!strict
-- Carrackon: Tide Flats' giant, the hermit of the bay, in the form a player owns after capturing it.
-- Four-legged, Water. A tank that hits hard: a huge pile of Hp and Defence in the torso, claws that
-- carry a real punch, slow to turn.
--
-- This is a giant's creature form (giantForm): it is never met in the wild. Its parts are costed
-- at the same budget as every other species (200), so breeding from it cannot break the stat
-- cap; a captured Carrackon is strong because it is gem-tier and carries two moves nothing else
-- has: Rolling Breaker (its head) and Silt Cloud, a Sand move (its tail) that lets a Water creature
-- answer the Leaf and Toxic creatures that beat it, echoing the attacks of the fight in its wreck.
--
-- Look (chunky low-poly, flat colours, every joint ends in a rounded ball that sits in its socket):
--   Head: a flat, wide crab face of rust-red shell, two eyes on thick stalks, a pair of whisker-feelers like frayed rope, a mast stub on top with a scrap of sail.
--   Torso: a long, round-bellied body wearing the splintered, barnacled hull of a wrecked ship like a shell, a porthole glowing a faint amber, kelp trailing from the rails.
--   Front legs: two heavy arms ending in great ridged claws, one much bigger than the other, a rusted anchor chain looped around the big one.
--   Hind legs: two short, jointed, spiky legs with broad flat feet that splay on the wet sand.
--   Tail: a curled, soft tail tucked under the hull and wrapped in old fishing net, tipped with a small cluster of shells.
--
-- Weight, lengths and radii are planning values until the art exists.

local Types = require("../../shared/Types")

local Carrackon: Types.SpeciesDef = {
	name = "Carrackon",
	bodyPlan = "Quad",
	biome = 3,
	baseRarity = "Uncommon",
	lassoDifficulty = 2.5,
	element = "Water",
	weight = 88,
	torsoLength = 6.4,
	giantForm = true,
	socketRadius = {
		Torso = 0,
		Head = 0.9,
		FrontLimbs = 0.66,
		Legs = 0.76,
		Tail = 0.45,
	},
	parts = {
		Head = {
			stats = { Hp = 6, Attack = 25, Defence = 5, Speed = 2 },
			moves = {
				{ name = "Maw Snap", level = 1 },
				{ name = "Rolling Breaker", level = 28 },
			},
			plugRadius = 0.9,
			length = 2.4,
		},
		Torso = {
			stats = { Hp = 100, Attack = 2, Defence = 27, Speed = 2 },
			moves = { { name = "Riptide Rush", level = 1 } },
			plugRadius = 0,
			length = 6.4,
		},
		FrontLimbs = {
			stats = { Hp = 10, Attack = 13, Defence = 10, Speed = 3 },
			moves = { { name = "Mussel Smack", level = 1 } },
			plugRadius = 0.66,
			length = 2.6,
		},
		Legs = {
			stats = { Hp = 6, Speed = 20 },
			moves = { { name = "Shoal Stomp", level = 1 } },
			plugRadius = 0.76,
			length = 2.2,
		},
		Tail = {
			stats = { Hp = 8, Attack = 2, Defence = 8, Speed = 3 },
			moves = { { name = "Foam Flick", level = 1 }, { name = "Silt Cloud", level = 30 } },
			plugRadius = 0.45,
			length = 1.6,
		},
	},
}

return Carrackon
