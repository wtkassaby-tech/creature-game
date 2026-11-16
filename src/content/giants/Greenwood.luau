--!strict
-- The Greenwood giant: Hollowbough, a colossal old tree that walks. Leaf biome; its lair lies under
-- the great old tree. Written for a team at about level 13 to 15. All numbers are Defaults and were
-- tuned against the placeholder test species; retune against the real Greenwood roster.
--
-- The fight teaches in three steps:
--  1. Pattern and wind-up: two root lashes, then Heartwood Slam. The slam is announced a turn early
--     and a Sand or Fire hit on the charged turn stops it completely.
--  2. One new idea: hits on the whole team (Spore Cloud, and Bough Sweep, which a weak-type hit halves).
--  3. A damage race: no more wind-ups, harder hits, fast pattern.

local GiantBattle = require("../../shared/GiantBattle")

local Hollowbough: GiantBattle.GiantDef = {
	id = "greenwood_hollowbough",
	name = "Hollowbough",
	element = "Leaf",
	level = 16,
	stats = { Hp = 1210, Attack = 48, Defence = 110 }, -- heavy bark: slow to chip, hits modestly
	attacks = {
		lash = {
			name = "Root Lash",
			element = "Leaf",
			power = 40,
			target = "Front",
			windUp = false,
			text = "Lashing a root at your front creature",
		},
		slam = {
			name = "Heartwood Slam",
			element = "Leaf",
			power = 85,
			target = "Front",
			windUp = true,
			whenInterrupted = "Cancel",
			text = "Heartwood Slam on your front creature",
			windUpText = "Winding up: Heartwood Slam, a huge hit on your front creature next turn",
			releaseText = "Heartwood Slam lands now! A Sand or Fire hit stops it",
		},
		spores = {
			name = "Spore Cloud",
			element = "Toxic",
			power = 24,
			target = "Team",
			windUp = false,
			text = "Spore Cloud drifts over your whole team",
		},
		sweep = {
			name = "Bough Sweep",
			element = "Leaf",
			power = 36,
			target = "Team",
			windUp = true,
			whenInterrupted = "Halve",
			text = "Bough Sweep across your whole team",
			windUpText = "Winding up: Bough Sweep, hits your whole team next turn",
			releaseText = "Bough Sweep lands on the whole team! A Sand or Fire hit halves it",
		},
		frenzy = {
			name = "Thorn Frenzy",
			element = "Leaf",
			power = 50,
			target = "Front",
			windUp = false,
			text = "Thorn Frenzy on your front creature",
		},
	},
	phases = {
		{
			name = "Sleeper",
			enterAt = 1,
			enterText = "Hollowbough heaves its roots out of the earth",
			idea = "Teaches the pattern and the wind-up: two lashes, then a slam that the right type cancels",
			pattern = { "lash", "lash", "slam" },
			damageMultiplier = 1,
		},
		{
			name = "Spore bloom",
			enterAt = 0.6,
			enterText = "Hollowbough sheds a cloud of spores. Now it hits your whole team",
			idea = "Adds hits on the whole team, and a team-wide wind-up that a weak-type hit halves",
			pattern = { "lash", "spores", "sweep", "spores" },
			damageMultiplier = 1,
		},
		{
			name = "Heartwood rage",
			enterAt = 0.25,
			enterText = "The heartwood glows red. Hollowbough stops holding back",
			idea = "A damage race: no wind-ups, harder hits, finish it before it finishes you",
			pattern = { "frenzy", "spores", "frenzy" },
			damageMultiplier = 1.2,
		},
	},
	enrage = { startTurn = 30, step = 0.15 },
}

return Hollowbough
