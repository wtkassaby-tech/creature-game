--!strict
-- Spadesnout: a stocky riverbank digger that shovels with its flat snout and hits like a falling stone
-- Greenwood, four-legged, Sand, Common. Role: striker (the most Attack in Greenwood; average Speed and Defence).
-- Starter: the Sand starter. Also found wild in the sandy bank by the Greenwood river.
--
-- Look (chunky low-poly, flat colours, every joint ends in a rounded ball that sits in its socket):
--   Head: a wide, flat spade-shaped snout plated like a garden trowel, small squinting eyes and round ears tucked back; sandy ochre with two darker stripes.
--   Torso: a compact, low, muscled body with a ridge of flat sandstone-coloured plates down the back and a lighter belly.
--   Front legs: short, thick front legs with three big curved digging claws like chunky blades.
--   Hind legs: short, strong hind legs with wide flat feet for bracing while it digs.
--   Tail: a short, thick wedge of a tail tipped with a round pebble knob.
--
-- Weight, lengths and radii are planning values until the art exists; then they are replaced
-- by measured ones. Part stats follow docs/content/GREENWOOD_ROSTER.md.

local Types = require("../../shared/Types")

local Spadesnout: Types.SpeciesDef = {
	name = "Spadesnout",
	bodyPlan = "Quad",
	biome = 1,
	baseRarity = "Common",
	lassoDifficulty = 1.0,
	element = "Sand",
	weight = 67,
	torsoLength = 4.0,
	socketRadius = {
		Torso = 0,
		Head = 0.8,
		FrontLimbs = 0.58,
		Legs = 0.66,
		Tail = 0.4,
	},
	parts = {
		Head = {
			stats = { Hp = 8, Attack = 38 },
			moves = { { name = "Grit Spray", level = 1 }, { name = "Dig Strike", level = 9 } },
			plugRadius = 0.8,
			length = 2.1,
		},
		Torso = {
			stats = { Hp = 90, Defence = 17 },
			moves = { { name = "Dust Kick", level = 1 }, { name = "Root Lash", level = 8 } },
			plugRadius = 0,
			length = 4.0,
		},
		FrontLimbs = {
			stats = { Hp = 22, Attack = 14, Defence = 6, Speed = 1 },
			moves = { { name = "Scree Kick", level = 1 } },
			plugRadius = 0.58,
			length = 1.8,
		},
		Legs = {
			stats = { Defence = 3, Speed = 34 },
			moves = { { name = "Dust Kick", level = 1 } },
			plugRadius = 0.66,
			length = 1.8,
		},
		Tail = {
			stats = { Attack = 3, Defence = 12 },
			moves = { { name = "Grit Spray", level = 1 } },
			plugRadius = 0.4,
			length = 1.3,
		},
	},
}

return Spadesnout
