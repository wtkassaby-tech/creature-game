--!strict
-- Test fixtures: three four-legged placeholder species used by the breeding and battle tests.
-- They are NOT game content. Real species live in src/content/Species.
-- Numbers are placeholders chosen to show the system: a heavy tank, a light sprinter, an all-rounder.

local Types = require("../../src/shared/Types")

local Species: { [string]: Types.SpeciesDef } = {}

Species.Mossback = {
	name = "Mossback",
	bodyPlan = "Quad",
	biome = 1,
	baseRarity = "Common",
	lassoDifficulty = 1,
	element = "Leaf",
	weight = 90,
	torsoLength = 6.0,
	socketRadius = { Torso = 0, Head = 1.1, FrontLimbs = 0.8, Legs = 0.9, Tail = 0.6 },
	parts = {
		Head = {
			stats = { Attack = 22 },
			moves = { { name = "Headbutt", level = 1 }, { name = "Moss Spit", level = 8 } },
			plugRadius = 1.1,
			length = 2.4,
		},
		Torso = {
			stats = { Hp = 120, Defence = 48 },
			moves = { { name = "Root Guard", level = 1 } },
			plugRadius = 0,
			length = 6.0,
		},
		FrontLimbs = {
			stats = { Attack = 20 },
			moves = { { name = "Stomp", level = 1 } },
			plugRadius = 0.8,
			length = 2.6,
		},
		Legs = {
			stats = { Speed = 34 },
			moves = { { name = "Brace", level = 1 } },
			plugRadius = 0.9,
			length = 2.8,
		},
		Tail = {
			stats = { Defence = 6 },
			moves = { { name = "Tail Sweep", level = 1 } },
			plugRadius = 0.6,
			length = 2.0,
		},
	},
}

Species.Dartlet = {
	name = "Dartlet",
	bodyPlan = "Quad",
	biome = 1,
	baseRarity = "Common",
	lassoDifficulty = 1,
	element = "Leaf",
	weight = 20,
	torsoLength = 2.6,
	socketRadius = { Torso = 0, Head = 0.5, FrontLimbs = 0.3, Legs = 0.35, Tail = 0.25 },
	parts = {
		Head = {
			stats = { Attack = 18 },
			moves = { { name = "Nip", level = 1 }, { name = "Leaf Dart", level = 8 } },
			plugRadius = 0.5,
			length = 1.1,
		},
		Torso = {
			stats = { Hp = 70, Defence = 24 },
			moves = { { name = "Sidestep", level = 1 } },
			plugRadius = 0,
			length = 2.6,
		},
		FrontLimbs = {
			stats = { Attack = 16 },
			moves = { { name = "Quick Jab", level = 1 } },
			plugRadius = 0.3,
			length = 1.2,
		},
		Legs = {
			stats = { Speed = 80 },
			moves = { { name = "Dash", level = 1 } },
			plugRadius = 0.35,
			length = 1.5,
		},
		Tail = {
			stats = { Speed = 6 },
			moves = { { name = "Feint", level = 1 } },
			plugRadius = 0.25,
			length = 1.4,
		},
	},
}

Species.Brindle = {
	name = "Brindle",
	bodyPlan = "Quad",
	biome = 1,
	baseRarity = "Common",
	lassoDifficulty = 1,
	element = "Sand",
	weight = 45,
	torsoLength = 4.0,
	socketRadius = { Torso = 0, Head = 0.8, FrontLimbs = 0.5, Legs = 0.6, Tail = 0.4 },
	parts = {
		Head = {
			stats = { Attack = 26 },
			moves = { { name = "Bite", level = 1 }, { name = "Howl", level = 8 } },
			plugRadius = 0.8,
			length = 1.8,
		},
		Torso = {
			stats = { Hp = 95, Defence = 34 },
			moves = { { name = "Shake Off", level = 1 } },
			plugRadius = 0,
			length = 4.0,
		},
		FrontLimbs = {
			stats = { Attack = 24 },
			moves = { { name = "Claw", level = 1 } },
			plugRadius = 0.5,
			length = 2.0,
		},
		Legs = {
			stats = { Speed = 58 },
			moves = { { name = "Pounce", level = 1 } },
			plugRadius = 0.6,
			length = 2.2,
		},
		Tail = {
			stats = { Attack = 5 },
			moves = { { name = "Lash", level = 1 } },
			plugRadius = 0.4,
			length = 1.8,
		},
	},
}

return Species
