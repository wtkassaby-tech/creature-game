--!strict
-- Dust Canyon's quest line, "Kilnrest Errands": four quests in order, ending in a guaranteed
-- creature, plus one optional quest for the giant. The main line never needs the giant or an
-- uncommon species. Coins and Prism Candy for finishing the line come from EconomyConfig (one-time
-- multiplier and QUEST_LINE_CANDY for biome 2), so tuning the economy tunes the quests. The
-- middle steps pay in items and canyon grit, so a player is stocked for the Mesa Road.
-- Each giver stands at a hub building: `giver.place` is that building's name.

local EconomyConfig = require("../../config/EconomyConfig")
local WorldTypes = require("../../shared/WorldTypes")

local LINE = "dust_canyon_errands"
local FINAL_COINS = math.floor(EconomyConfig.QUEST_LINE_COINS * EconomyConfig.ONE_TIME_MULT[2])
local FINAL_CANDY = EconomyConfig.QUEST_LINE_CANDY[2]

local quests: { WorldTypes.Quest } = {
	{
		id = "dc_dry_run",
		name = "Dry Run",
		line = LINE,
		step = 1,
		optional = false,
		giver = { name = "Tamsin Rook", place = "Rook's Trading Post" },
		requires = {},
		requiresFlags = { "canyon_trader" },
		objective = { kind = "WinWild", count = 4, route = "dust_canyon_route_a" },
		goal = "Win 4 wild battles on Route A",
		offer = "Prove you can handle the Dry Wash and I will stock you up for the road.",
		done = "You kept up with the quick ones. Here, tonics on the house.",
		rewards = { { kind = "Item", item = "Tonic", count = 4 } },
	},
	{
		id = "dc_seep_friend",
		name = "A Friend for the Seep",
		line = LINE,
		step = 2,
		optional = false,
		giver = { name = "Calla Seep", place = "The Seep House" },
		requires = { "dc_dry_run" },
		requiresFlags = {},
		objective = { kind = "TameSpecies", species = "Wadibuck" },
		goal = "Tame a Wadibuck",
		offer = "The seep is too quiet. Could you bring me a Wadibuck from the arroyo?",
		done = "Hear its hooves on the stone! Take these ropes and some grit for your travels.",
		rewards = {
			{ kind = "Item", item = "Braided", count = 2 },
			{ kind = "Material", material = "CanyonGrit", count = 6 },
		},
	},
	{
		id = "dc_survey_trouble",
		name = "Survey Trouble",
		line = LINE,
		step = 3,
		optional = false,
		giver = { name = "Fenwick Dray", place = "The Sundial Waystation" },
		requires = { "dc_seep_friend" },
		requiresFlags = { "mentors_letter" },
		objective = { kind = "BeatTamer", tamer = "dc_hesper" },
		goal = "Beat Hesper Dunnock on Route B",
		offer = "A surveyor on the Mesa Road keeps moving my markers. Beat her and I will say thanks.",
		done = "My markers stay put at last. Take these, you will need them on the Rim.",
		rewards = { { kind = "Item", item = "GreatTonic", count = 2 } },
	},
	{
		id = "dc_wardens_word",
		name = "Tavish's Rope",
		line = LINE,
		step = 4,
		optional = false,
		giver = { name = "Ottoline Marsh", place = "The Notice Wall" },
		requires = { "dc_survey_trouble" },
		requiresFlags = {},
		objective = { kind = "BeatTamer", tamer = "dc_tavish" },
		goal = "Beat Tavish Orrel near the Stair Gate",
		offer = "Tavish guards the road to the gate. Win his respect and I have a gift for you.",
		done = "He sent word himself. Here is a friend who hits like a falling rock.",
		rewards = {
			{ kind = "Coins", amount = FINAL_COINS },
			{ kind = "PrismCandy", amount = FINAL_CANDY },
			{
				kind = "Creature",
				species = "Flintknap",
				level = 16,
				rarity = "Common",
				colour = "Sand",
			},
		},
	},
	{
		id = "dc_mesalith",
		name = "The Mesa That Walks",
		line = LINE,
		step = 5,
		optional = true,
		giver = { name = "Ottoline Marsh", place = "The Notice Wall" },
		requires = { "dc_dry_run" },
		requiresFlags = { "mesa_sighting" },
		objective = { kind = "BeatGiant", giant = "dust_canyon_mesalith" },
		goal = "Beat Mesalith on its shelf",
		offer = "The red mesa walks when it wakes. Beat it if you dare, and bring a Giant Horn.",
		done = "You stood up to Mesalith! All of Kilnrest saw the dust.",
		rewards = {
			{ kind = "Item", item = "Revive", count = 1 },
			{ kind = "Material", material = "CanyonGrit", count = 5 },
		},
	},
}

return quests
