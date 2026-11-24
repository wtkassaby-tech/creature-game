--!strict
-- Keelsnap: a hunched snapping-turtle brawler with a hooked beak and a shell crusted with dried swamp mud
-- Mire, two-legged, Toxic, Common. Role: bruiser, the most Attack on two legs, with a poisoning sting on its tail.
-- Gem-tier individuals are rare wild spawns of this same species, not a separate one.
--
-- Look (chunky low-poly, flat colours, every joint ends in a rounded ball that sits in its socket):
--   Head: a blocky head with a sharp hooked beak, a craggy brow and small red eyes.
--   Torso: a hunched body under a high shell ridged with three rows of jagged keels, caked with cracked dry mud.
--   Arms: long, thick arms with heavy scaled forearms and three hooked claws.
--   Legs: short, thick, pillar-like legs with blunt claws.
--   Tail: a long, thick tail with a saw-toothed ridge, ending in a barbed spike.
--
-- Weight, lengths and radii are planning values until the art exists; then they are replaced
-- by measured ones. Part stats follow docs/content/MIRE_ROSTER.md.

local Types = require("../../shared/Types")

local Keelsnap: Types.SpeciesDef = {
	name = "Keelsnap",
	bodyPlan = "Biped",
	biome = 4,
	baseRarity = "Common",
	lassoDifficulty = 1.5,
	element = "Toxic",
	weight = 54,
	torsoLength = 3.3,
	socketRadius = {
		Torso = 0,
		Head = 0.68,
		FrontLimbs = 0.51,
		Legs = 0.68,
		Tail = 0.35,
	},
	parts = {
		Head = {
			stats = { Hp = 5, Attack = 31, Defence = 3, Speed = 5 },
			moves = { { name = "Hook Beak", level = 1 }, { name = "Gar Rend", level = 36 } },
			plugRadius = 0.68,
			length = 1.5,
		},
		Torso = {
			stats = { Hp = 88, Attack = 2, Defence = 14, Speed = 2 },
			moves = { { name = "Shell Bash", level = 1 } },
			plugRadius = 0,
			length = 3.3,
		},
		FrontLimbs = {
			stats = { Hp = 10, Attack = 16, Defence = 9, Speed = 6 },
			moves = { { name = "Muck Stamp", level = 1 } },
			plugRadius = 0.51,
			length = 2,
		},
		Legs = {
			stats = { Hp = 6, Speed = 28 },
			moves = { { name = "Bog Wade", level = 1 } },
			plugRadius = 0.68,
			length = 1.3,
		},
		Tail = {
			stats = { Hp = 16, Attack = 1, Defence = 6, Speed = 2 },
			moves = { { name = "Barb Sting", level = 1 } },
			plugRadius = 0.35,
			length = 1.1,
		},
	},
}

return Keelsnap
