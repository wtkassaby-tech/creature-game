--!strict
-- Skipslick: a lanky marsh frog in warning colours that sprints upright across lily pads faster than they can sink
-- Mire, two-legged, Toxic, Common. Role: sprinter, the fastest on two legs and the thinnest Defence, with a poisoning bite on its head.
-- Gem-tier individuals are rare wild spawns of this same species, not a separate one.
--
-- Look (chunky low-poly, flat colours, every joint ends in a rounded ball that sits in its socket):
--   Head: a small, round head with two huge bulging eyes on top and a wide grin, warning orange with black spots.
--   Torso: a slim, upright, shiny body striped black and warning orange.
--   Arms: thin arms with round, sticky-pad fingertips.
--   Legs: long, spring-like legs folded in a Z, with long splayed toes.
--   Tail: a tiny, rounded stub of a tail.
--
-- Weight, lengths and radii are planning values until the art exists; then they are replaced
-- by measured ones. Part stats follow docs/content/MIRE_ROSTER.md.

local Types = require("../../shared/Types")

local Skipslick: Types.SpeciesDef = {
	name = "Skipslick",
	bodyPlan = "Biped",
	biome = 4,
	baseRarity = "Common",
	lassoDifficulty = 1.55,
	element = "Toxic",
	weight = 36,
	torsoLength = 2.6,
	socketRadius = {
		Torso = 0,
		Head = 0.59,
		FrontLimbs = 0.45,
		Legs = 0.59,
		Tail = 0.3,
	},
	parts = {
		Head = {
			stats = { Hp = 6, Attack = 27, Defence = 2, Speed = 5 },
			moves = { { name = "Venom Nip", level = 1 }, { name = "Fen Lash", level = 34 } },
			plugRadius = 0.59,
			length = 1.2,
		},
		Torso = {
			stats = { Hp = 98, Attack = 2, Defence = 12, Speed = 2 },
			moves = { { name = "Slick Dash", level = 1 } },
			plugRadius = 0,
			length = 2.6,
		},
		FrontLimbs = {
			stats = { Hp = 11, Attack = 14, Defence = 7, Speed = 6 },
			moves = { { name = "Sludge Slap", level = 1 } },
			plugRadius = 0.45,
			length = 1.5,
		},
		Legs = {
			stats = { Hp = 7, Speed = 31 },
			moves = { { name = "Slick Dash", level = 1 } },
			plugRadius = 0.59,
			length = 2.2,
		},
		Tail = {
			stats = { Hp = 18, Attack = 1, Defence = 5, Speed = 2 },
			moves = { { name = "Sludge Slap", level = 1 } },
			plugRadius = 0.3,
			length = 0.8,
		},
	},
}

return Skipslick
