--!strict
-- Wadibuck: a skittish antelope of dry riverbeds whose hollow horns fill with water whenever a flash flood comes through
-- Dust Canyon, four-legged, Water, Common. Role: fast striker (quick and hard-hitting, the thinnest Defence on four legs).
-- Gem-tier ("Amber") individuals are rare wild spawns of this same species, not a separate one.
--
-- Look (chunky low-poly, flat colours, every joint ends in a rounded ball that sits in its socket):
--   Head: a slim, long-muzzled head with two tall ringed horns that curl back in an open spiral, each a clear blue tube with water inside (one solid transparent part, no physics), and wide-set dark eyes.
--   Torso: a slender, deep-chested body in sand-buff with a wavy blue stripe along each flank like a tide line.
--   Front legs: very thin, straight forelegs with dark cloven hooves.
--   Hind legs: long, springy hind legs with high hocks.
--   Tail: a short upright tail like a paintbrush, its blue tip holding a single hanging drop.
--
-- Weight, lengths and radii are planning values until the art exists; then they are replaced
-- by measured ones. Part stats follow docs/content/DUST_CANYON_ROSTER.md.

local Types = require("../../shared/Types")

local Wadibuck: Types.SpeciesDef = {
	name = "Wadibuck",
	bodyPlan = "Quad",
	biome = 2,
	baseRarity = "Common",
	lassoDifficulty = 1.2,
	element = "Water",
	weight = 44,
	torsoLength = 3.9,
	socketRadius = {
		Torso = 0,
		Head = 0.69,
		FrontLimbs = 0.5,
		Legs = 0.58,
		Tail = 0.35,
	},
	parts = {
		Head = {
			stats = { Hp = 5, Attack = 28, Defence = 2, Speed = 7 },
			moves = { { name = "Oasis Spout", level = 1 }, { name = "Flash Flood", level = 20 } },
			plugRadius = 0.69,
			length = 1.9,
		},
		Torso = {
			stats = { Hp = 101, Attack = 2, Defence = 10, Speed = 3 },
			moves = { { name = "Wadi Rush", level = 1 } },
			plugRadius = 0,
			length = 3.9,
		},
		FrontLimbs = {
			stats = { Hp = 10, Attack = 14, Defence = 5, Speed = 7 },
			moves = { { name = "Fog Drip", level = 1 } },
			plugRadius = 0.5,
			length = 2.3,
		},
		Legs = {
			stats = { Hp = 7, Speed = 37 },
			moves = { { name = "Hoof Scuff", level = 1 } },
			plugRadius = 0.58,
			length = 2.6,
		},
		Tail = {
			stats = { Hp = 7, Attack = 1, Defence = 4, Speed = 2 },
			moves = { { name = "Fog Drip", level = 1 } },
			plugRadius = 0.35,
			length = 0.9,
		},
	},
}

return Wadibuck
