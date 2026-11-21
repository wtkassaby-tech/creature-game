--!strict
-- Bogbellow: a hulking bog boar whose back is a mound of steaming peat, with gas vents that puff green fumes when it bellows
-- Mire, four-legged, Toxic, Uncommon. Role: bruiser, the most Hp in the Mire and the slowest on four legs, with a poisoning belch on its torso.
-- Gem-tier individuals are rare wild spawns of this same species, not a separate one.
--
-- Look (chunky low-poly, flat colours, every joint ends in a rounded ball that sits in its socket):
--   Head: a broad, low head with a flat, shovel-like snout for rooting in peat, two short curled tusks the colour of old bone, and small heavy-lidded eyes.
--   Torso: a huge barrel body whose back is a lumpy mound of dark peat with three short chimney-like vents (the green puffs are a particle effect, not a part).
--   Front legs: thick, short forelegs caked in mud up to the knees, with wide split trotters.
--   Hind legs: stocky hind legs with heavy, mud-caked trotters.
--   Tail: a fat, bulging tail like a sack of swamp water, swollen and sagging.
--
-- Weight, lengths and radii are planning values until the art exists; then they are replaced
-- by measured ones. Part stats follow docs/content/MIRE_ROSTER.md.

local Types = require("../../shared/Types")

local Bogbellow: Types.SpeciesDef = {
	name = "Bogbellow",
	bodyPlan = "Quad",
	biome = 4,
	baseRarity = "Uncommon",
	lassoDifficulty = 2.1,
	element = "Toxic",
	weight = 68,
	torsoLength = 5,
	socketRadius = {
		Torso = 0,
		Head = 0.8,
		FrontLimbs = 0.58,
		Legs = 0.67,
		Tail = 0.4,
	},
	parts = {
		Head = {
			stats = { Hp = 6, Attack = 26, Defence = 3, Speed = 3 },
			moves = { { name = "Peat Butt", level = 1 }, { name = "Mire Crush", level = 38 } },
			plugRadius = 0.8,
			length = 1.9,
		},
		Torso = {
			stats = { Hp = 101, Attack = 2, Defence = 19, Speed = 1 },
			moves = { { name = "Fume Belch", level = 1 } },
			plugRadius = 0,
			length = 5,
		},
		FrontLimbs = {
			stats = { Hp = 12, Attack = 13, Defence = 11, Speed = 4 },
			moves = { { name = "Muck Stamp", level = 1 } },
			plugRadius = 0.58,
			length = 1.7,
		},
		Legs = {
			stats = { Hp = 7, Speed = 19 },
			moves = { { name = "Bog Wade", level = 1 } },
			plugRadius = 0.67,
			length = 1.6,
		},
		Tail = {
			stats = { Hp = 19, Attack = 1, Defence = 9, Speed = 2 },
			moves = { { name = "Sludge Slap", level = 1 } },
			plugRadius = 0.4,
			length = 1.3,
		},
	},
}

return Bogbellow
