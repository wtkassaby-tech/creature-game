--!strict
-- Mesalith: Dust Canyon's giant, the walking mesa, in the form a player owns after capturing it.
-- Two-legged, Sand. A bruiser: the most Hp of any species, hits hard, slow to turn.
--
-- This is a giant's creature form (giantForm): it is never met in the wild. Its parts are costed
-- at the same budget as every other species (200), so breeding from it cannot break the stat
-- cap; a captured Mesalith is strong because it is gem-tier and carries two moves nothing else
-- has: Strata Crush (its head) and Tumble Barrage, a Leaf move (its tail) that lets a Sand
-- creature answer Water, echoing the attacks of the fight in its lair.
--
-- Look (chunky low-poly, flat colours, every joint ends in a rounded ball that sits in its socket):
--   Head: a flat-topped block of banded red rock like a small mesa, two deep-set amber lights for eyes, a ledge for a brow.
--   Torso: a broad, layered body of rust, cream and ochre strata with cracks that glow a faint amber, one tuft of dry grass on top.
--   Arms: two heavy stone columns that hang low, ending in rounded boulder fists with talus scree stuck in the cracks.
--   Legs: two thick pillars with flat, wide feet like paving slabs.
--   Tail: a dragging spill of loose rubble held together by a rope of dry vines, tipped with a rolled tumbleweed.
--
-- Weight, lengths and radii are planning values until the art exists.

local Types = require("../../shared/Types")

local Mesalith: Types.SpeciesDef = {
	name = "Mesalith",
	bodyPlan = "Biped",
	biome = 2,
	baseRarity = "Uncommon",
	lassoDifficulty = 2.5,
	element = "Sand",
	weight = 90,
	torsoLength = 3.8,
	giantForm = true,
	socketRadius = {
		Torso = 0,
		Head = 0.8,
		FrontLimbs = 0.61,
		Legs = 0.8,
		Tail = 0.41,
	},
	parts = {
		Head = {
			stats = { Hp = 8, Attack = 28, Defence = 4, Speed = 2 },
			moves = {
				{ name = "Capstone Crash", level = 1 },
				{ name = "Strata Crush", level = 14 },
			},
			plugRadius = 0.8,
			length = 1.9,
		},
		Torso = {
			stats = { Hp = 118, Attack = 3, Defence = 12, Speed = 2 },
			moves = { { name = "Mesa Slam", level = 1 } },
			plugRadius = 0,
			length = 3.8,
		},
		FrontLimbs = {
			stats = { Hp = 12, Attack = 12, Defence = 8, Speed = 2 },
			moves = { { name = "Pebble Pelt", level = 1 } },
			plugRadius = 0.61,
			length = 2.4,
		},
		Legs = {
			stats = { Hp = 7, Speed = 20 },
			moves = { { name = "Grit Step", level = 1 } },
			plugRadius = 0.8,
			length = 2.4,
		},
		Tail = {
			stats = { Hp = 5, Attack = 3, Defence = 10, Speed = 4 },
			moves = { { name = "Sand Flick", level = 1 }, { name = "Tumble Barrage", level = 18 } },
			plugRadius = 0.41,
			length = 1.4,
		},
	},
}

return Mesalith
