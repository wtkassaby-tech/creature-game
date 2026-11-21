--!strict
-- Runnelfin: a quick, lanky shore dancer that sprints along the runnels the tide leaves behind, its fin crest flicking water as it goes
-- Tide Flats, two-legged, Water, Common. Role: sprinter (the fastest on two legs in Tide Flats, the thinnest Defence).
-- Gem-tier ("Amber") individuals are rare wild spawns of this same species, not a separate one.
--
-- Look (chunky low-poly, flat colours, every joint ends in a rounded ball that sits in its socket):
--   Head: a narrow, fish-like head with a tall, sail-like fin crest running from brow to nape, and wide-set round eyes.
--   Torso: a slim, upright, streamlined body in bright turquoise with silver scale bands.
--   Arms: short, thin arms ending in small fin-shaped hands.
--   Legs: lean, quick legs with narrow, pointed fin-feet like arrowheads that cut through shallow water.
--   Tail: a long, forked fish tail held straight out behind for balance.
--
-- Weight, lengths and radii are planning values until the art exists; then they are replaced
-- by measured ones. Part stats follow docs/content/TIDE_FLATS_ROSTER.md.

local Types = require("../../shared/Types")

local Runnelfin: Types.SpeciesDef = {
	name = "Runnelfin",
	bodyPlan = "Biped",
	biome = 3,
	baseRarity = "Common",
	lassoDifficulty = 1.45,
	element = "Water",
	weight = 38,
	torsoLength = 2.6,
	socketRadius = {
		Torso = 0,
		Head = 0.6,
		FrontLimbs = 0.46,
		Legs = 0.6,
		Tail = 0.31,
	},
	parts = {
		Head = {
			stats = { Hp = 5, Attack = 26, Defence = 2, Speed = 6 },
			moves = { { name = "Spray Jet", level = 1 }, { name = "Undertow", level = 26 } },
			plugRadius = 0.6,
			length = 1.2,
		},
		Torso = {
			stats = { Hp = 102, Attack = 2, Defence = 15, Speed = 3 },
			moves = { { name = "Skim Dash", level = 1 } },
			plugRadius = 0,
			length = 2.6,
		},
		FrontLimbs = {
			stats = { Hp = 11, Attack = 14, Defence = 5, Speed = 7 },
			moves = { { name = "Foam Flick", level = 1 } },
			plugRadius = 0.46,
			length = 1.4,
		},
		Legs = {
			stats = { Hp = 7, Speed = 34 },
			moves = { { name = "Skim Dash", level = 1 } },
			plugRadius = 0.6,
			length = 1.9,
		},
		Tail = {
			stats = { Hp = 7, Attack = 1, Defence = 4, Speed = 2 },
			moves = { { name = "Foam Flick", level = 1 } },
			plugRadius = 0.31,
			length = 1.8,
		},
	},
}

return Runnelfin
