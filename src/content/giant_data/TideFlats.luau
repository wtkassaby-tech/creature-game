--!strict
-- The Tide Flats giant: Carrackon, a hermit crab as big as a hill that wears a wrecked ship for a
-- shell. Water biome; its lair is a spur off the Breakwater Road. Written for a team at about level
-- 32 to 35. All numbers are Defaults, tuned against teams of three from the real Greenwood, Dust
-- Canyon and Tide Flats rosters (tests/tideflats.test prints the win-rate table).
--
-- The fight idea, "the tide table": Carrackon is Water, so Leaf and Toxic are the types that stop its
-- waves (a Leaf or Toxic hit on the charged turn cancels Rolling Breaker and halves Flood Surge).
-- Hollowbough's fight is about a Sand lead shrugging off one slam and Mesalith's is about swapping the
-- stopper in and out. This one is about a rhythm and about the whole type cycle. Every phase has a
-- wave that is announced a turn early, on a fixed table: the fight opens on the tell with no free
-- turn, and even the last phase keeps its waves, so there is never a damage race where you can stop
-- watching. And it carries one attack for each type of the creatures the bay's roster is made of:
-- Water (Pincer Snap, Rolling Breaker, Flood Surge) hurts Sand creatures, Sand (Silt Cloud) hurts the
-- Leaf creatures that stop its waves, and Toxic (Brine Bloom, a teaser for the Mire) hurts Water
-- creatures, the type that answers nothing else. So every stopper has an attack aimed at it and
-- every team has a creature in the line of fire: a team wants a Leaf or Toxic creature for each
-- wave, a front creature that can take the next hit, and a swap on the charged turn. A team with no
-- Leaf or Toxic move at all cannot win (the measured rate is 0%).
--
-- The fight is three tides, like the bay it comes from:
--  1. Ebb tide: Rolling Breaker first, with no free turn, then silt and a bloom. The big wave is a
--     front wind-up that Leaf or Toxic cancels completely. Teaches the tell.
--  2. Flood tide: Flood Surge is a team-wide wind-up that Leaf or Toxic halves, between silt, bloom
--     and the claw. The stoppers are worn down between waves.
--  3. Spring tide: both waves come back on a short table, a wave every third turn, and
--     the hits are 1.4 times as big. A rhythm that rewards a team that kept a stopper healthy.

local GiantBattle = require("../../shared/GiantBattle")

local Carrackon: GiantBattle.GiantDef = {
	id = "tide_flats_carrackon",
	name = "Carrackon",
	element = "Water",
	level = 36,
	stats = { Hp = 2200, Attack = 300, Defence = 72 },
	attacks = {
		claw = {
			name = "Pincer Snap",
			element = "Water",
			power = 104,
			target = "Front",
			windUp = false,
			text = "Snapping its big claw at your front creature",
		},
		silt = {
			name = "Silt Cloud",
			element = "Sand",
			power = 112,
			target = "Front",
			windUp = false,
			text = "Silt Cloud smothers your front creature",
		},
		breaker = {
			name = "Rolling Breaker",
			element = "Water",
			power = 116,
			target = "Front",
			windUp = true,
			whenInterrupted = "Cancel",
			text = "Rolling Breaker on your front creature",
			windUpText = "Winding up: Rolling Breaker, a huge wave on your front creature next turn",
			releaseText = "Rolling Breaker crashes down now! A Leaf or Toxic hit stops it",
		},
		bloom = {
			name = "Brine Bloom",
			element = "Toxic",
			power = 108,
			target = "Front",
			windUp = false,
			text = "A Brine Bloom of red water engulfs your front creature",
		},
		flood = {
			name = "Flood Surge",
			element = "Water",
			power = 94,
			target = "Team",
			windUp = true,
			whenInterrupted = "Halve",
			text = "Flood Surge sweeps your whole team",
			windUpText = "Winding up: Flood Surge, hits your whole team next turn",
			releaseText = "Flood Surge sweeps the whole team! A Leaf or Toxic hit halves it",
		},
	},
	phases = {
		{
			name = "Ebb tide",
			enterAt = 1,
			enterText = "Carrackon heaves its ship-shell out of the shallows",
			idea = "Teaches the tell with no free turn: the fight opens on Rolling Breaker, a wave that Leaf or Toxic cancels",
			pattern = { "breaker", "silt", "bloom" },
			damageMultiplier = 1,
		},
		{
			name = "Flood tide",
			enterAt = 0.6,
			enterText = "The water rises. Flood Surge is coming for your whole team",
			idea = "Adds hits on the whole team, and a team-wide wave that Leaf or Toxic halves; the silt wears the stoppers down",
			pattern = { "silt", "flood", "bloom", "claw" },
			damageMultiplier = 1.2,
		},
		{
			name = "Spring tide",
			enterAt = 0.25,
			enterText = "A great swell lifts the wreck. The waves come faster now",
			idea = "A rhythm, not a race: both waves return on a short table, so a stopper has to be ready for each one",
			pattern = { "breaker", "silt", "flood", "bloom" },
			damageMultiplier = 1.4,
		},
	},
	enrage = { startTurn = 30, step = 0.3 },
	-- Captured, it is a gem-tier Carrackon (src/content/species_data/Carrackon.luau) at the giant's own
	-- level, a third bigger than other creatures to look at.
	form = { species = "Carrackon", rarity = "Gem", level = 36, colour = "Moss", size = 1.3 },
}

return Carrackon
