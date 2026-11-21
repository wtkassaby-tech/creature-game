--!strict
-- Hullock: a slow, broad shore ox whose back has crusted over like the hull of an old boat, barnacles and all
-- Tide Flats, four-legged, Water, Uncommon. Role: bruiser (the most Defence on four legs in Tide Flats, and the slowest).
-- Gem-tier ("Amber") individuals are rare wild spawns of this same species, not a separate one.
--
-- Look (chunky low-poly, flat colours, every joint ends in a rounded ball that sits in its socket):
--   Head: a wide, low head with a blunt, rounded snout like a boat's prow, two short horns ridged like whelk shells curving forward, and small deep-set eyes.
--   Torso: a long, heavy, keel-shaped body; its back is a crust of grey barnacle cones and flat limpet plates over weathered blue-green hide.
--   Front legs: thick, stubby forelegs ringed with mussel-blue bands, ending in wide round hooves like mooring posts.
--   Hind legs: short, heavy hind legs with broad flat feet for wet sand.
--   Tail: a short, thick tail ending in a flat, upright fin shaped like a boat's rudder.
--
-- Weight, lengths and radii are planning values until the art exists; then they are replaced
-- by measured ones. Part stats follow docs/content/TIDE_FLATS_ROSTER.md.

local Types = require("../../shared/Types")

local Hullock: Types.SpeciesDef = {
	name = "Hullock",
	bodyPlan = "Quad",
	biome = 3,
	baseRarity = "Uncommon",
	lassoDifficulty = 1.9,
	element = "Water",
	weight = 66,
	torsoLength = 4.8,
	socketRadius = {
		Torso = 0,
		Head = 0.79,
		FrontLimbs = 0.57,
		Legs = 0.66,
		Tail = 0.4,
	},
	parts = {
		Head = {
			stats = { Hp = 5, Attack = 26, Defence = 4, Speed = 4 },
			moves = {
				{ name = "Barnacle Butt", level = 1 },
				{ name = "Breaker Charge", level = 28 },
			},
			plugRadius = 0.79,
			length = 2,
		},
		Torso = {
			stats = { Hp = 98, Attack = 2, Defence = 25, Speed = 2 },
			moves = { { name = "Riptide Rush", level = 1 } },
			plugRadius = 0,
			length = 4.8,
		},
		FrontLimbs = {
			stats = { Hp = 10, Attack = 13, Defence = 9, Speed = 5 },
			moves = { { name = "Brine Jab", level = 1 } },
			plugRadius = 0.57,
			length = 1.8,
		},
		Legs = {
			stats = { Hp = 7, Speed = 24 },
			moves = { { name = "Shoal Stomp", level = 1 } },
			plugRadius = 0.66,
			length = 1.7,
		},
		Tail = {
			stats = { Hp = 7, Attack = 1, Defence = 8, Speed = 1 },
			moves = { { name = "Foam Flick", level = 1 } },
			plugRadius = 0.4,
			length = 1.2,
		},
	},
}

return Hullock
