--!strict
-- Clapshell: a hulking beach brawler whose hands are two great scallop shells that clap shut like a trap
-- Tide Flats, two-legged, Water, Common. Role: bruiser (the most Attack in Tide Flats, thin Defence, slow).
-- Gem-tier ("Amber") individuals are rare wild spawns of this same species, not a separate one.
--
-- Look (chunky low-poly, flat colours, every joint ends in a rounded ball that sits in its socket):
--   Head: a small, blunt head sunk between hunched shoulders, two eyes on short stalks and a jutting lower jaw.
--   Torso: a broad, top-heavy chest covered in overlapping orange and cream scallop plates, narrow at the waist.
--   Arms: thick arms that end in two huge ribbed scallop shells instead of hands, which open and snap shut.
--   Legs: short, bowed legs with wide three-toed feet.
--   Tail: a stubby, segmented tail like a shrimp's, curled under.
--
-- Weight, lengths and radii are planning values until the art exists; then they are replaced
-- by measured ones. Part stats follow docs/content/TIDE_FLATS_ROSTER.md.

local Types = require("../../shared/Types")

local Clapshell: Types.SpeciesDef = {
	name = "Clapshell",
	bodyPlan = "Biped",
	biome = 3,
	baseRarity = "Common",
	lassoDifficulty = 1.4,
	element = "Water",
	weight = 55,
	torsoLength = 3.2,
	socketRadius = {
		Torso = 0,
		Head = 0.68,
		FrontLimbs = 0.52,
		Legs = 0.68,
		Tail = 0.35,
	},
	parts = {
		Head = {
			stats = { Hp = 5, Attack = 32, Defence = 2, Speed = 4 },
			moves = { { name = "Brine Jab", level = 1 }, { name = "Breaker Charge", level = 28 } },
			plugRadius = 0.68,
			length = 1.3,
		},
		Torso = {
			stats = { Hp = 106, Attack = 2, Defence = 18, Speed = 2 },
			moves = { { name = "Clamp Crush", level = 1 } },
			plugRadius = 0,
			length = 3.2,
		},
		FrontLimbs = {
			stats = { Hp = 11, Attack = 16, Defence = 6, Speed = 5 },
			moves = { { name = "Mussel Smack", level = 1 } },
			plugRadius = 0.52,
			length = 2,
		},
		Legs = {
			stats = { Hp = 7, Speed = 24 },
			moves = { { name = "Shoal Stomp", level = 1 } },
			plugRadius = 0.68,
			length = 1.4,
		},
		Tail = {
			stats = { Hp = 7, Attack = 1, Defence = 5, Speed = 1 },
			moves = { { name = "Foam Flick", level = 1 } },
			plugRadius = 0.35,
			length = 0.9,
		},
	},
}

return Clapshell
