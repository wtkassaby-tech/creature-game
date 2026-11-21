--!strict
-- The Dust Canyon giant: Mesalith, a colossal mesa that walks. Sand biome; its lair is a spur off
-- the Mesa Road. Written for a team at about level 22 to 25. All numbers are Defaults, tuned
-- against teams of three from the real Greenwood and Dust Canyon rosters (tests/dustcanyon.test
-- prints the win-rate table).
--
-- The fight idea, "hit and swap": Mesalith is Sand, so Water and Storm are the types that stop its
-- wind-ups (a Water or Storm hit on the charged turn cancels Strata Crush and halves Strata Quake).
-- But the creatures that carry those types are the ones its attacks are built to hurt: its Leaf
-- barrage hits Water creatures hard, and its Sand attacks hit the Leaf creatures that carry the
-- Storm move Dust Squall. A creature that stays in to stop every wind-up is knocked out, so the
-- answer is to swap the stopper in on the wind-up turn (nothing lands on it), hit on the release
-- turn, and swap out again. Fast, fragile creatures suit that, which is the biome's idea.
--
-- The fight is three layers, like the strata of the mesa it is:
--  1. Cap rock: gravel and tumbleweeds on your front creature, then Strata Crush, a heavy
--     wind-up that Water or Storm cancels completely. Teaches the tell and the swap.
--  2. Red bed: sand on the whole team (Redbed Slide) and Strata Quake, a team-wide wind-up that
--     Water or Storm halves. Every creature is in danger, so there is no safe place to hide.
--  3. Heartstone: no wind-ups, harder hits, a damage race against a fast pattern.

local GiantBattle = require("../../shared/GiantBattle")

local Mesalith: GiantBattle.GiantDef = {
	id = "dust_canyon_mesalith",
	name = "Mesalith",
	element = "Sand",
	level = 26,
	stats = { Hp = 1500, Attack = 160, Defence = 75 }, -- hits hard and falls in about 20 turns; a Water or Storm hit does well
	attacks = {
		pelt = {
			name = "Gravel Pelt",
			element = "Sand",
			power = 60,
			target = "Front",
			windUp = false,
			text = "Flinging gravel at your front creature",
		},
		tumble = {
			name = "Tumble Barrage",
			element = "Leaf",
			power = 66,
			target = "Front",
			windUp = false,
			text = "Rolling a tumbleweed barrage at your front creature",
		},
		crush = {
			name = "Strata Crush",
			element = "Sand",
			power = 88,
			target = "Front",
			windUp = true,
			whenInterrupted = "Cancel",
			text = "Strata Crush on your front creature",
			windUpText = "Winding up: Strata Crush, a heavy hit on your front creature next turn",
			releaseText = "Strata Crush lands now! A Water or Storm hit stops it",
		},
		slide = {
			name = "Redbed Slide",
			element = "Sand",
			power = 46,
			target = "Team",
			windUp = false,
			text = "Redbed Slide buries your whole team in sand",
		},
		quake = {
			name = "Strata Quake",
			element = "Sand",
			power = 72,
			target = "Team",
			windUp = true,
			whenInterrupted = "Halve",
			text = "Strata Quake shakes your whole team",
			windUpText = "Winding up: Strata Quake, hits your whole team next turn",
			releaseText = "Strata Quake lands on the whole team! A Water or Storm hit halves it",
		},
		rampage = {
			name = "Heartstone Rampage",
			element = "Sand",
			power = 84,
			target = "Front",
			windUp = false,
			text = "Heartstone Rampage on your front creature",
		},
	},
	phases = {
		{
			name = "Cap rock",
			enterAt = 1,
			enterText = "Mesalith drags itself up out of the canyon wall",
			idea = "Teaches the tell and the swap: gravel, tumbleweeds, then a Strata Crush that Water or Storm cancels",
			pattern = { "pelt", "tumble", "crush" },
			damageMultiplier = 1,
		},
		{
			name = "Red bed",
			enterAt = 0.6,
			enterText = "The cap rock splits. Red sand pours over your whole team",
			idea = "Adds hits on the whole team, and a team-wide wind-up that Water or Storm halves",
			pattern = { "tumble", "slide", "quake", "slide" },
			damageMultiplier = 1,
		},
		{
			name = "Heartstone",
			enterAt = 0.25,
			enterText = "An amber light blazes in the cracks. Mesalith stops holding back",
			idea = "A damage race: no wind-ups, harder hits, finish it before it finishes you",
			pattern = { "rampage", "slide", "tumble", "rampage" },
			damageMultiplier = 1.2,
		},
	},
	enrage = { startTurn = 30, step = 0.3 },
	-- Captured, it is a gem-tier Mesalith (src/content/species/Mesalith.luau) at the giant's own
	-- level, a third bigger than other creatures to look at.
	form = { species = "Mesalith", rarity = "Gem", level = 26, colour = "Sand", size = 1.3 },
}

return Mesalith
