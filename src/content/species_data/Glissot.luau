--!strict
-- Glissot: a sleek tide-line runner that skims across the wet sand faster than the waves can follow
-- Tide Flats, four-legged, Water, Common. Role: sprinter (the fastest on four legs in Tide Flats, light Defence).
-- Gem-tier ("Amber") individuals are rare wild spawns of this same species, not a separate one.
--
-- Look (chunky low-poly, flat colours, every joint ends in a rounded ball that sits in its socket):
--   Head: a small, smooth, bullet-shaped head with a pointed snout, long whiskers of thin foam-white rods and two big glossy eyes set far back.
--   Torso: a long, slim, low-slung body tapered at both ends, silver-blue above and pale below, with a thin dark wet-line along each side.
--   Front legs: short, slim forelegs with wide webbed toes.
--   Hind legs: long, bent hind legs with broad webbed feet that slap the water flat.
--   Tail: a long, flat tail that widens into a two-lobed fluke.
--
-- Weight, lengths and radii are planning values until the art exists; then they are replaced
-- by measured ones. Part stats follow docs/content/TIDE_FLATS_ROSTER.md.

local Types = require("../../shared/Types")

local Glissot: Types.SpeciesDef = {
	name = "Glissot",
	bodyPlan = "Quad",
	biome = 3,
	baseRarity = "Common",
	lassoDifficulty = 1.45,
	element = "Water",
	weight = 45,
	torsoLength = 3.8,
	socketRadius = {
		Torso = 0,
		Head = 0.69,
		FrontLimbs = 0.51,
		Legs = 0.58,
		Tail = 0.35,
	},
	parts = {
		Head = {
			stats = { Hp = 5, Attack = 25, Defence = 3, Speed = 6 },
			moves = { { name = "Spray Jet", level = 1 }, { name = "Undertow", level = 26 } },
			plugRadius = 0.69,
			length = 1.6,
		},
		Torso = {
			stats = { Hp = 94, Attack = 2, Defence = 18, Speed = 3 },
			moves = { { name = "Skim Dash", level = 1 } },
			plugRadius = 0,
			length = 3.8,
		},
		FrontLimbs = {
			stats = { Hp = 10, Attack = 13, Defence = 6, Speed = 7 },
			moves = { { name = "Foam Flick", level = 1 } },
			plugRadius = 0.51,
			length = 2,
		},
		Legs = {
			stats = { Hp = 6, Speed = 36 },
			moves = { { name = "Skim Dash", level = 1 } },
			plugRadius = 0.58,
			length = 2.4,
		},
		Tail = {
			stats = { Hp = 6, Attack = 1, Defence = 5, Speed = 2 },
			moves = { { name = "Foam Flick", level = 1 } },
			plugRadius = 0.35,
			length = 2.2,
		},
	},
}

return Glissot
