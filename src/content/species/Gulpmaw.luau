--!strict
-- Gulpmaw: a rock-pool ambusher that waits half buried in the weed with its enormous mouth wide open
-- Tide Flats, four-legged, Water, Common. Role: striker (the most Attack on four legs in Tide Flats).
-- Gem-tier ("Amber") individuals are rare wild spawns of this same species, not a separate one.
--
-- Look (chunky low-poly, flat colours, every joint ends in a rounded ball that sits in its socket):
--   Head: a huge, wide, flat head that is mostly mouth, its jaw lined with a row of blunt pebble teeth, two small eyes on short stalks on top.
--   Torso: a squat, toad-like body mottled rust and olive like rock-pool weed, with a frill of ragged skin along each side.
--   Front legs: short, splayed forelegs with knobbly elbows and round sucker-tipped toes for gripping wet rock.
--   Hind legs: thick, crouched hind legs folded like springs for a sudden lunge.
--   Tail: a short, broad paddle tail with a ragged, weed-like edge.
--
-- Weight, lengths and radii are planning values until the art exists; then they are replaced
-- by measured ones. Part stats follow docs/content/TIDE_FLATS_ROSTER.md.

local Types = require("../../shared/Types")

local Gulpmaw: Types.SpeciesDef = {
	name = "Gulpmaw",
	bodyPlan = "Quad",
	biome = 3,
	baseRarity = "Common",
	lassoDifficulty = 1.4,
	element = "Water",
	weight = 64,
	torsoLength = 3.9,
	socketRadius = {
		Torso = 0,
		Head = 0.78,
		FrontLimbs = 0.57,
		Legs = 0.65,
		Tail = 0.39,
	},
	parts = {
		Head = {
			stats = { Hp = 5, Attack = 30, Defence = 3, Speed = 5 },
			moves = { { name = "Maw Snap", level = 1 }, { name = "Undertow", level = 28 } },
			plugRadius = 0.78,
			length = 1.7,
		},
		Torso = {
			stats = { Hp = 96, Attack = 2, Defence = 19, Speed = 2 },
			moves = { { name = "Rockpool Lunge", level = 1 } },
			plugRadius = 0,
			length = 3.9,
		},
		FrontLimbs = {
			stats = { Hp = 10, Attack = 15, Defence = 7, Speed = 5 },
			moves = { { name = "Brine Jab", level = 1 } },
			plugRadius = 0.57,
			length = 1.6,
		},
		Legs = {
			stats = { Hp = 7, Speed = 29 },
			moves = { { name = "Shoal Stomp", level = 1 } },
			plugRadius = 0.65,
			length = 1.5,
		},
		Tail = {
			stats = { Hp = 7, Attack = 1, Defence = 6, Speed = 1 },
			moves = { { name = "Foam Flick", level = 1 } },
			plugRadius = 0.39,
			length = 1.6,
		},
	},
}

return Gulpmaw
