--!strict
-- Furrowfoot: a stocky field-tiller of Clover Lane that cuts a furrow behind it wherever it walks
-- Greenwood, four-legged, Sand, Common. Role: guard (the most Defence in Greenwood; average Speed, lighter Hp).
-- Greenwood's ninth species, added so a player who picks the Leaf or Water starter meets a Sand
-- creature early, in Route A's clover meadow (docs/DECISIONS.md, 22 Nov 2026). Four-legged rather
-- than two-legged: see docs/content/GREENWOOD_ROSTER.md, "The ninth species".
--
-- Look (chunky low-poly, flat colours, every joint ends in a rounded ball that sits in its socket):
--   Head: a broad, blunt head like a smooth sand boulder, small round eyes under a heavy brow and two short forward horns shaped like plough tips; sandy ochre with a darker band across the eyes.
--   Torso: a low, barrel-shaped body of packed sandy earth with raised ridges across the back like freshly ploughed rows, and a pale, smooth belly.
--   Front legs: thick front legs with wide, flat, blade-shaped hooves that slice into the soil.
--   Hind legs: short, heavy hind legs with broad flat feet for pushing, caked in dried mud.
--   Tail: a short, flat tail that drags behind like a harrow, with a row of blunt pebble teeth along its edge.
--
-- Weight, lengths and radii are planning values until the art exists; then they are replaced
-- by measured ones. Part stats follow docs/content/GREENWOOD_ROSTER.md.

local Types = require("../../shared/Types")

local Furrowfoot: Types.SpeciesDef = {
	name = "Furrowfoot",
	bodyPlan = "Quad",
	biome = 1,
	baseRarity = "Common",
	lassoDifficulty = 1.0,
	element = "Sand",
	weight = 63,
	torsoLength = 4.2,
	socketRadius = {
		Torso = 0,
		Head = 0.78,
		FrontLimbs = 0.57,
		Legs = 0.65,
		Tail = 0.39,
	},
	parts = {
		Head = {
			stats = { Hp = 10, Attack = 30, Defence = 8 },
			moves = { { name = "Clod Hurl", level = 1 } },
			plugRadius = 0.78,
			length = 1.7,
		},
		Torso = {
			stats = { Hp = 90, Defence = 21, Speed = 3 },
			moves = { { name = "Grit Spray", level = 1 }, { name = "Root Lash", level = 8 } },
			plugRadius = 0,
			length = 4.2,
		},
		FrontLimbs = {
			stats = { Hp = 10, Attack = 11, Defence = 12, Speed = 3 },
			moves = { { name = "Dust Kick", level = 1 } },
			plugRadius = 0.57,
			length = 1.7,
		},
		Legs = {
			stats = { Hp = 5, Speed = 31 },
			moves = { { name = "Puddle Stomp", level = 1 } },
			plugRadius = 0.65,
			length = 1.6,
		},
		Tail = {
			stats = { Hp = 5, Defence = 8 },
			moves = { { name = "Fern Whip", level = 1 } },
			plugRadius = 0.39,
			length = 1.5,
		},
	},
}

return Furrowfoot
