--!strict
-- Flintknap: a wiry flint-chipper whose forearms end in knapped stone blades it keeps sharpening on the canyon walls
-- Dust Canyon, two-legged, Sand, Common. Role: striker (the most Attack in Dust Canyon).
-- Gem-tier ("Amber") individuals are rare wild spawns of this same species, not a separate one.
--
-- Look (chunky low-poly, flat colours, every joint ends in a rounded ball that sits in its socket):
--   Head: a long, angular head with a jutting jaw and a ridge of chipped flint flakes in place of a crest; narrow amber eyes.
--   Torso: a lean, wedge-shaped chest, broad at the shoulders and narrow at the hips, flint grey with tan patches.
--   Arms: long forearms, each ending in a broad, leaf-shaped blade of faceted black flint instead of a hand (the low-poly facets show the knapping).
--   Legs: lean, bent legs with three splayed toes.
--   Tail: a short, flat tail shaped like a chipped arrowhead.
--
-- Weight, lengths and radii are planning values until the art exists; then they are replaced
-- by measured ones. Part stats follow docs/content/DUST_CANYON_ROSTER.md.

local Types = require("../../shared/Types")

local Flintknap: Types.SpeciesDef = {
	name = "Flintknap",
	bodyPlan = "Biped",
	biome = 2,
	baseRarity = "Common",
	lassoDifficulty = 1.2,
	element = "Sand",
	weight = 46,
	torsoLength = 2.9,
	socketRadius = {
		Torso = 0,
		Head = 0.64,
		FrontLimbs = 0.49,
		Legs = 0.64,
		Tail = 0.33,
	},
	parts = {
		Head = {
			stats = { Attack = 34, Speed = 4 },
			moves = { { name = "Knap Edge", level = 1 }, { name = "Grit Whirl", level = 18 } },
			plugRadius = 0.64,
			length = 1.5,
		},
		Torso = {
			stats = { Hp = 100, Attack = 3, Defence = 16, Speed = 3 },
			moves = { { name = "Flint Cleave", level = 1 } },
			plugRadius = 0,
			length = 2.9,
		},
		FrontLimbs = {
			stats = { Hp = 12, Attack = 17, Defence = 6, Speed = 3 },
			moves = { { name = "Knap Edge", level = 1 } },
			plugRadius = 0.49,
			length = 1.9,
		},
		Legs = {
			stats = { Hp = 5, Speed = 34 },
			moves = { { name = "Dune Dash", level = 1 } },
			plugRadius = 0.64,
			length = 1.9,
		},
		Tail = {
			stats = { Hp = 5, Defence = 6 },
			moves = { { name = "Pebble Pelt", level = 1 } },
			plugRadius = 0.33,
			length = 1.0,
		},
	},
}

return Flintknap
