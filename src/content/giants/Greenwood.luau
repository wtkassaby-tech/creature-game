--!strict
-- The Greenwood giant: Hollowbough, a colossal old tree that walks. Leaf biome; its lair lies under
-- the great old tree. Written for a team at about level 13 to 15. All numbers are Defaults, tuned
-- against teams of three from the real Greenwood roster (tests/giant.test prints the win-rate table).
--
-- Why most of its attacks are Storm, not Leaf: the Sand starter resists Leaf and Toxic, so a
-- Leaf-and-Toxic giant could not hurt the very creature that is strong against it, and any team
-- that led with it won at every level. Storm is the one type that beats Sand and does not beat
-- Leaf or Water, so the right type still helps a lot, but only the Heartwood Slam (Leaf, the one
-- wind-up a Sand or Fire hit cancels completely) is something a Sand lead shrugs off.
--
-- The fight teaches in three steps:
--  1. Pattern and wind-up: two root lashes, then Heartwood Slam. The slam is announced a turn early
--     and a Sand or Fire hit on the charged turn stops it completely.
--  2. One new idea: hits on the whole team (Spore Gale, and Gale Sweep, which a weak-type hit halves).
--  3. A damage race: no more wind-ups, harder hits, fast pattern.

local GiantBattle = require("../../shared/GiantBattle")

local Hollowbough: GiantBattle.GiantDef = {
	id = "greenwood_hollowbough",
	name = "Hollowbough",
	element = "Leaf",
	level = 16,
	stats = { Hp = 1150, Attack = 100, Defence = 80 }, -- bark a Sand hit cuts well; hits hard enough to punish a slow team
	attacks = {
		lash = {
			name = "Gale Lash",
			element = "Storm",
			power = 55,
			target = "Front",
			windUp = false,
			text = "Lashing a gale-whipped root at your front creature",
		},
		slam = {
			name = "Heartwood Slam",
			element = "Leaf",
			power = 45,
			target = "Front",
			windUp = true,
			whenInterrupted = "Cancel",
			text = "Heartwood Slam on your front creature",
			windUpText = "Winding up: Heartwood Slam, a heavy hit on your front creature next turn",
			releaseText = "Heartwood Slam lands now! A Sand or Fire hit stops it",
		},
		spores = {
			name = "Spore Gale",
			element = "Storm",
			power = 38,
			target = "Team",
			windUp = false,
			text = "Spore Gale blows over your whole team",
		},
		sweep = {
			name = "Gale Sweep",
			element = "Storm",
			power = 65,
			target = "Team",
			windUp = true,
			whenInterrupted = "Halve",
			text = "Gale Sweep across your whole team",
			windUpText = "Winding up: Gale Sweep, hits your whole team next turn",
			releaseText = "Gale Sweep lands on the whole team! A Sand or Fire hit halves it",
		},
		frenzy = {
			name = "Thorn Gale",
			element = "Storm",
			power = 68,
			target = "Front",
			windUp = false,
			text = "Thorn Gale on your front creature",
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
	enrage = { startTurn = 30, step = 0.3 },
}

return Hollowbough
