--!strict
-- The Mire giant: Sloughback, a newt as big as a barn whose back is a little island of mangroves,
-- with soft green marsh lights hanging from the roots like lures. Toxic biome; its lair is a spur
-- off the Cypress Road. Written for a team of four at about level 42 to 45. All numbers are
-- Defaults, tuned against teams of four from the real Greenwood, Dust Canyon, Tide Flats and Mire
-- rosters (tests/mire.test prints the win-rate table). Written ahead of launch: it stays closed
-- until src/config/ReleaseConfig.luau opens the Mire.
--
-- The fight idea, "the long fog": the first fight against a team of four, and the first where most
-- of the giant's damage lands on the whole team. Hollowbough's fight is one slam a Sand lead shrugs
-- off, Mesalith's is swapping a stopper in and out, Carrackon's is a rhythm of waves. Sloughback's
-- is endurance: Fume Drift seeps over every creature standing, again and again, so swapping never
-- dodges it and the bench wears down with the front. A team wins by ending the fight before its
-- four are worn out: bulk (the Mire's breeding stat is Hp), tonics, and stopping the big waves.
-- Sloughback is Toxic, so Sand and Frost are the types that stop them (a Sand or Frost hit on the
-- charged turn cancels Sinking Pull and halves Marsh Gas).
--
-- The giant never poisons and cannot be poisoned (src/shared/GiantBattle has no status effects,
-- by design): the fog is its poison, told as damage. The lesson matches the biome's. Its Toxic
-- fumes hit Water creatures hardest and Sand creatures least, and Toxic creatures take them at the
-- plain rate, so a Toxic or Sand creature is safe ground, as poison taught on the routes. And every
-- stopper has an attack aimed at it: Sinking Pull (Water) and Marshlight Flare (Storm) both hit
-- Sand creatures hard, and the Frost stoppers (the Water-bodied Mistrel and Lilyshade, which carry
-- Hoarmist) take the Toxic fumes at 1.5 times.
--
-- The fight is three stages of the fog:
--  1. Low mist: a seep of fumes, then Sinking Pull, a front wind-up that Sand or Frost cancels
--     completely, then a slam. Teaches the tell with one free turn to set up.
--  2. Rising fog: Marsh Gas, a team-wide wind-up that Sand or Frost halves, between the seep, the
--     flare aimed at stoppers and the slam. Hits 1.2 times as hard.
--  3. Deep fog: the seep comes twice a cycle, with both waves, 1.3 times as hard. An endurance
--     race that a team which kept its bench healthy wins.

local GiantBattle = require("../../shared/GiantBattle")

local Sloughback: GiantBattle.GiantDef = {
	id = "mire_sloughback",
	name = "Sloughback",
	element = "Toxic",
	level = 46,
	stats = { Hp = 2300, Attack = 400, Defence = 90 },
	attacks = {
		slam = {
			name = "Slough Slam",
			element = "Toxic",
			power = 145,
			target = "Front",
			windUp = false,
			text = "Slapping its great muddy tail down on your front creature",
		},
		flare = {
			name = "Marshlight Flare",
			element = "Storm",
			power = 145,
			target = "Front",
			windUp = false,
			text = "Its marsh lights flare and crackle at your front creature",
		},
		drift = {
			name = "Fume Drift",
			element = "Toxic",
			power = 45,
			target = "Team",
			windUp = false,
			text = "Green fumes seep over your whole team",
		},
		pull = {
			name = "Sinking Pull",
			element = "Water",
			power = 165,
			target = "Front",
			windUp = true,
			whenInterrupted = "Cancel",
			text = "Sinking Pull drags your front creature under",
			windUpText = "Winding up: Sinking Pull, it will drag your front creature under next turn",
			releaseText = "Sinking Pull drags down now! A Sand or Frost hit stops it",
		},
		gas = {
			name = "Marsh Gas",
			element = "Toxic",
			power = 120,
			target = "Team",
			windUp = true,
			whenInterrupted = "Halve",
			text = "Marsh Gas rolls over your whole team",
			windUpText = "Winding up: Marsh Gas, it will roll over your whole team next turn",
			releaseText = "Marsh Gas rolls over the whole team! A Sand or Frost hit halves it",
		},
	},
	phases = {
		{
			name = "Low mist",
			enterAt = 1,
			enterText = "Sloughback lifts its mangrove back out of the black water",
			idea = "Teaches the tell with one free turn: a seep of fumes, then Sinking Pull, a front wave that Sand or Frost cancels",
			pattern = { "drift", "pull", "slam" },
			damageMultiplier = 1,
		},
		{
			name = "Rising fog",
			enterAt = 0.6,
			enterText = "The fog thickens. Marsh Gas is coming for your whole team",
			idea = "Adds a team-wide wave that Sand or Frost halves, and a flare aimed at the Sand stoppers",
			pattern = { "drift", "gas", "flare", "slam" },
			damageMultiplier = 1.2,
		},
		{
			name = "Deep fog",
			enterAt = 0.25,
			enterText = "The grove sinks into the fog. The fumes come twice as often now",
			idea = "Endurance, not a race: the seep comes twice a cycle with both waves, so a healthy bench wins",
			pattern = { "drift", "pull", "drift", "gas" },
			damageMultiplier = 1.3,
		},
	},
	enrage = { startTurn = 30, step = 0.3 },
	-- Captured, it is a gem-tier Sloughback (src/content/species_data/Sloughback.luau) at the giant's own
	-- level, a third bigger than other creatures to look at.
	form = { species = "Sloughback", rarity = "Gem", level = 46, colour = "Moss", size = 1.3 },
}

return Sloughback
