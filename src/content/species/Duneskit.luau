--!strict
-- Duneskit: a lean dune sprinter that skims the sand on fringed feet, its tall shutter ears snapping flat when it runs
-- Dust Canyon, four-legged, Sand, Common. Role: sprinter (fast, thin Attack).
-- Gem-tier ("Amber") individuals are rare wild spawns of this same species, not a separate one.
--
-- Look (chunky low-poly, flat colours, every joint ends in a rounded ball that sits in its socket):
--   Head: a narrow wedge-shaped head like a doorstop, two tall ears each made of three stacked sandstone slats like window shutters, small black bead eyes; pale ochre with a rust-red nose tip.
--   Torso: a short, light, arched body with a tucked-up belly and three faint rust bands across the back.
--   Front legs: thin forelegs with knobbly wrists and small curved scoop claws for flicking sand.
--   Hind legs: long, folded hind legs with oversized flat feet fringed with stiff comb-like scales for running on loose sand.
--   Tail: a long thin tail ending in a flat diamond-shaped vane it steers with.
--
-- Weight, lengths and radii are planning values until the art exists; then they are replaced
-- by measured ones. Part stats follow docs/content/DUST_CANYON_ROSTER.md.

local Types = require("../../shared/Types")

local Duneskit: Types.SpeciesDef = {
	name = "Duneskit",
	bodyPlan = "Quad",
	biome = 2,
	baseRarity = "Common",
	lassoDifficulty = 1.3,
	element = "Sand",
	weight = 40,
	torsoLength = 3.6,
	socketRadius = {
		Torso = 0,
		Head = 0.67,
		FrontLimbs = 0.48,
		Legs = 0.56,
		Tail = 0.34,
	},
	parts = {
		Head = {
			stats = { Hp = 5, Attack = 24, Defence = 3, Speed = 7 },
			moves = { { name = "Sand Flick", level = 1 }, { name = "Grit Whirl", level = 18 } },
			plugRadius = 0.67,
			length = 1.6,
		},
		Torso = {
			stats = { Hp = 93, Attack = 2, Defence = 14, Speed = 3 },
			moves = { { name = "Dune Dash", level = 1 }, { name = "Tumbleweed Toss", level = 14 } },
			plugRadius = 0,
			length = 3.6,
		},
		FrontLimbs = {
			stats = { Hp = 10, Attack = 12, Defence = 8, Speed = 8 },
			moves = { { name = "Pebble Pelt", level = 1 } },
			plugRadius = 0.48,
			length = 1.7,
		},
		Legs = {
			stats = { Hp = 6, Speed = 39 },
			moves = { { name = "Dune Dash", level = 1 } },
			plugRadius = 0.56,
			length = 2.4,
		},
		Tail = {
			stats = { Hp = 6, Attack = 1, Defence = 6, Speed = 2 },
			moves = { { name = "Sand Flick", level = 1 } },
			plugRadius = 0.34,
			length = 2.4,
		},
	},
}

return Duneskit
