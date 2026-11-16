--!strict
-- Stumpwarden: a squat, patient guardian that plants itself in the path like a living tree stump
-- Greenwood, two-legged, Leaf, Common. Role: tank (the most Hp in Greenwood; slow).
--
-- Look (chunky low-poly, flat colours, every joint ends in a rounded ball that sits in its socket):
--   Head: a low, wide head sunk into the shoulders, with a shelf of bracket fungus as a visor over two glowing green eyes and a crown of new shoots.
--   Torso: a broad, barrel-shaped stump with growth rings on its chest, rough bark on the sides and a collar of moss.
--   Arms: two thick, club-like arms of gnarled root ending in three blunt knuckles.
--   Legs: two very short, wide legs that end in splayed root toes.
--   Tail: a stubby root tail that rests on the ground like a prop.
--
-- Weight, lengths and radii are planning values until the art exists; then they are replaced
-- by measured ones. Part stats follow docs/content/GREENWOOD_ROSTER.md.

local Types = require("../../shared/Types")

local Stumpwarden: Types.SpeciesDef = {
	name = "Stumpwarden",
	bodyPlan = "Biped",
	biome = 1,
	baseRarity = "Common",
	lassoDifficulty = 1.0,
	element = "Leaf",
	weight = 67,
	torsoLength = 3.9,
	socketRadius = {
		Torso = 0,
		Head = 0.72,
		FrontLimbs = 0.56,
		Legs = 0.72,
		Tail = 0.38,
	},
	parts = {
		Head = {
			stats = { Hp = 10, Attack = 27, Defence = 4 },
			moves = { { name = "Seed Shot", level = 1 }, { name = "Sap Hammer", level = 9 } },
			plugRadius = 0.72,
			length = 1.3,
		},
		Torso = {
			stats = { Hp = 115, Attack = 3, Defence = 8, Speed = 3 },
			moves = { { name = "Root Lash", level = 1 } },
			plugRadius = 0,
			length = 3.9,
		},
		FrontLimbs = {
			stats = { Hp = 13, Attack = 11, Defence = 15, Speed = 3 },
			moves = { { name = "Moss Slam", level = 1 } },
			plugRadius = 0.56,
			length = 2.2,
		},
		Legs = {
			stats = { Defence = 3, Speed = 31 },
			moves = { { name = "Twig Snap", level = 1 } },
			plugRadius = 0.72,
			length = 1.5,
		},
		Tail = {
			stats = { Hp = 5, Defence = 6 },
			moves = { { name = "Fern Whip", level = 1 } },
			plugRadius = 0.38,
			length = 1.1,
		},
	},
}

return Stumpwarden
