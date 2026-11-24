--!strict
-- Tide Flats' quest line, "Saltwick Tallies": four quests in order, ending in a guaranteed creature,
-- plus one optional quest for the giant. The main line never needs the giant or an uncommon
-- species. Coins and Prism Candy for finishing the line come from EconomyConfig (one-time
-- multiplier and QUEST_LINE_CANDY for biome 3), so tuning the economy tunes the quests. The
-- middle steps pay in items and Brine Shells (Tide Flats' material, which the Tide Bait recipe
-- uses), so a player who finishes step 3 can craft a first bait before the lair.
-- Each giver stands at a hub building: `giver.place` is that building's name.

local EconomyConfig = require("../../config/EconomyConfig")
local WorldTypes = require("../../shared/WorldTypes")

local LINE = "tide_flats_tallies"
local FINAL_COINS = math.floor(EconomyConfig.QUEST_LINE_COINS * EconomyConfig.ONE_TIME_MULT[3])
local FINAL_CANDY = EconomyConfig.QUEST_LINE_CANDY[3]

local quests: { WorldTypes.Quest } = {
	{
		id = "tf_first_haul",
		name = "First Haul",
		line = LINE,
		step = 1,
		optional = false,
		giver = { name = "Odalys Tarn", place = "Tarn's Chandlery" },
		requires = {},
		requiresFlags = { "tide_bait" },
		objective = { kind = "WinWild", count = 4, route = "tide_flats_route_a" },
		goal = "Win 4 wild battles on Route A",
		offer = "Walk the Strandline and show me you can handle the wet. Then we talk stock.",
		done = "Not a dry boot among them. Here, tonics, with my thanks.",
		rewards = { { kind = "Item", item = "Tonic", count = 4 } },
	},
	{
		id = "tf_pool_friend",
		name = "A Friend for the Pool",
		line = LINE,
		step = 2,
		optional = false,
		giver = { name = "Perdita Lugg", place = "The Warm Pool" },
		requires = { "tf_first_haul" },
		requiresFlags = {},
		objective = { kind = "TameSpecies", species = "Glissot" },
		goal = "Tame a Glissot",
		offer = "The pool is too still. Bring me a Glissot from the beach to stir it up?",
		done = "Look at it skim! Take these ropes, and some shells for your bait.",
		rewards = {
			{ kind = "Item", item = "Braided", count = 2 },
			{ kind = "Material", material = "BrineShell", count = 6 },
		},
	},
	{
		id = "tf_lamp_trouble",
		name = "Lamp Trouble",
		line = LINE,
		step = 3,
		optional = false,
		giver = { name = "Bastian Wake", place = "The Ferry Steps" },
		requires = { "tf_pool_friend" },
		requiresFlags = { "mentors_note" },
		objective = { kind = "BeatTamer", tamer = "tf_isaura" },
		goal = "Beat Isaura Penhallow on Route B",
		offer = "Isaura swears the lamp flickers by night. Steady her nerves, and mine.",
		done = "She says you were steady. Take these, and a few more shells.",
		rewards = {
			{ kind = "Item", item = "GreatTonic", count = 2 },
			{ kind = "Material", material = "BrineShell", count = 4 },
		},
	},
	{
		id = "tf_gate_tally",
		name = "The Gate Tally",
		line = LINE,
		step = 4,
		optional = false,
		giver = { name = "Hobb Pellow", place = "The Tally Board" },
		requires = { "tf_lamp_trouble" },
		requiresFlags = {},
		objective = { kind = "BeatTamer", tamer = "tf_ludo" },
		goal = "Beat Ludo Brackwater near the Breakwater Gate",
		offer = "Ludo mends the nets by the gate and counts all who pass. Win his tally.",
		done = "He has marked you down himself. Here is a friend that clamps hard.",
		rewards = {
			{ kind = "Coins", amount = FINAL_COINS },
			{ kind = "PrismCandy", amount = FINAL_CANDY },
			{
				kind = "Creature",
				species = "Clapshell",
				level = 26,
				rarity = "Common",
				colour = "Sand",
			},
		},
	},
	{
		id = "tf_carrackon",
		name = "The Wreck That Walks",
		line = LINE,
		step = 5,
		optional = true,
		giver = { name = "Hobb Pellow", place = "The Tally Board" },
		requires = { "tf_first_haul" },
		requiresFlags = { "wreck_sighting" },
		objective = { kind = "BeatGiant", giant = "tide_flats_carrackon" },
		goal = "Beat Carrackon in its wreck",
		offer = "The old wreck got up and walked. Beat it if you dare, and bring a Giant Horn.",
		done = "You beat Carrackon! The whole quay saw the spray from here.",
		rewards = {
			{ kind = "Item", item = "Revive", count = 1 },
			{ kind = "Material", material = "BrineShell", count = 5 },
		},
	},
}

return quests
