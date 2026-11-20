--!strict
-- Duneskit: a lean dune sprinter that skims the sand on fringed feet, its tall shutter ears snapping flat when it runs
-- Dust Canyon, four-legged, Sand, Common. Role: sprinter (very fast, thin Defence).
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
	weight = 46,
	torsoLength = 3.6,
	socketRadius = {
		Torso = 0,
		Head = 0.7,
		FrontLimbs = 0.51,
		Legs = 0.58,
		Tail = 0.35,
	},
	parts = {
		Head = {
			stats = { Attack = 26, Defence = 8, Speed = 6 },
			moves = { { name = "Sand Flick", level = 1 }, { name = "Grit Whirl", level = 18 } },
			plugRadius = 0.7,
			length = 1.6,
		},
		Torso = {
			stats = { Hp = 100, Defence = 15, Speed = 4 },
			moves = { { name = "Dune Dash", level = 1 }, { name = "Tumbleweed Toss", level = 14 } },
			plugRadius = 0,
			length = 3.6,
		},
		FrontLimbs = {
			stats = { Hp = 5, Attack = 15, Defence = 8, Speed = 3 },
			moves = { { name = "Pebble Pelt", level = 1 } },
			plugRadius = 0.51,
			length = 1.7,
		},
		Legs = {
			stats = { Attack = 1, Defence = 3, Speed = 36 },
			moves = { { name = "Dune Dash", level = 1 } },
			plugRadius = 0.58,
			length = 2.4,
		},
		Tail = {
			stats = { Hp = 5, Attack = 3, Defence = 6 },
			moves = { { name = "Sand Flick", level = 1 } },
			plugRadius = 0.35,
			length = 2.4,
		},
	},
}

return Duneskit
