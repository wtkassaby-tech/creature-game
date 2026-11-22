--!strict
-- Moatkeep: a squat little sandcastle come to life, which rebuilds its walls every time the tide knocks them down
-- Tide Flats, two-legged, Sand, Common. Role: sturdy all-rounder, the lone Sand species on two legs (the most Hp in Tide Flats, the slowest), with a Toxic move on its torso to answer the Water majority.
-- Gem-tier ("Amber") individuals are rare wild spawns of this same species, not a separate one.
--
-- Look (chunky low-poly, flat colours, every joint ends in a rounded ball that sits in its socket):
--   Head: a square head shaped like a castle turret, crenellated along the top, with two dark window-slit eyes and a small shell stuck on top like a flag.
--   Torso: a blocky body of packed wet sand with bucket-mould ridges and a ring of darker wet sand around its middle like a moat (one solid part).
--   Arms: short, thick, square arms of packed sand ending in flat, paddle-like hands for patting walls smooth.
--   Legs: short, heavy, round legs like little castle towers.
--   Tail: a short, flat slab of sand like a lowered drawbridge.
--
-- Weight, lengths and radii are planning values until the art exists; then they are replaced
-- by measured ones. Part stats follow docs/content/TIDE_FLATS_ROSTER.md.

local Types = require("../../shared/Types")

local Moatkeep: Types.SpeciesDef = {
	name = "Moatkeep",
	bodyPlan = "Biped",
	biome = 3,
	baseRarity = "Common",
	lassoDifficulty = 1.4,
	element = "Sand",
	weight = 60,
	torsoLength = 3.3,
	socketRadius = {
		Torso = 0,
		Head = 0.7,
		FrontLimbs = 0.53,
		Legs = 0.7,
		Tail = 0.36,
	},
	parts = {
		Head = {
			stats = { Hp = 6, Attack = 29, Defence = 3, Speed = 4 },
			moves = { { name = "Cockle Crack", level = 1 }, { name = "Shell Grind", level = 28 } },
			plugRadius = 0.7,
			length = 1.3,
		},
		Torso = {
			stats = { Hp = 109, Attack = 2, Defence = 20, Speed = 2 },
			moves = { { name = "Rampart Slam", level = 1 }, { name = "Red Tide", level = 24 } },
			plugRadius = 0,
			length = 3.3,
		},
		FrontLimbs = {
			stats = { Hp = 11, Attack = 15, Defence = 7, Speed = 4 },
			moves = { { name = "Sand Scoop", level = 1 } },
			plugRadius = 0.53,
			length = 1.6,
		},
		Legs = {
			stats = { Hp = 7, Speed = 22 },
			moves = { { name = "Shoal Stomp", level = 1 } },
			plugRadius = 0.7,
			length = 1.2,
		},
		Tail = {
			stats = { Hp = 7, Attack = 1, Defence = 6, Speed = 1 },
			moves = { { name = "Sand Scoop", level = 1 } },
			plugRadius = 0.36,
			length = 0.9,
		},
	},
}

return Moatkeep
