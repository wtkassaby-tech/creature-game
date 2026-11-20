--!strict
-- Greenwood's quest line, "Thistledown Favours": four quests in order, ending in a guaranteed
-- creature, plus one optional quest for the giant. The main line never needs the giant or an
-- uncommon species. Coins and Prism Candy for finishing the line come from EconomyConfig (one-time
-- multiplier and QUEST_LINE_CANDY for biome 1), so tuning the economy tunes the quests.
-- Early steps pay in items, so a new player is stocked for the road.

local EconomyConfig = require("../../config/EconomyConfig")
local WorldTypes = require("../../shared/WorldTypes")

local LINE = "greenwood_favours"
local FINAL_COINS = math.floor(EconomyConfig.QUEST_LINE_COINS * EconomyConfig.ONE_TIME_MULT[1])
local FINAL_CANDY = EconomyConfig.QUEST_LINE_CANDY[1]

local quests: { WorldTypes.Quest } = {
	{
		id = "gw_fresh_tracks",
		name = "Fresh Tracks",
		line = LINE,
		step = 1,
		optional = false,
		giver = { name = "Marlow Tuppence", place = "Tuppence's Shop" },
		requires = {},
		requiresFlags = { "third_creature" },
		objective = { kind = "WinWild", count = 4, route = "greenwood_route_a" },
		goal = "Win 4 wild battles on Route A",
		offer = "New in town? Win a few scraps on Clover Lane, and I will stock you up.",
		done = "Not bad for a beginner. Here, a few tonics on the house.",
		rewards = { { kind = "Item", item = "Tonic", count = 3 } },
	},
	{
		id = "gw_pond_friend",
		name = "A Friend for the Pond",
		line = LINE,
		step = 2,
		optional = false,
		giver = { name = "Hazel Brightwater", place = "Brightwater House" },
		requires = { "gw_fresh_tracks" },
		requiresFlags = {},
		objective = { kind = "TameSpecies", species = "Splashjack" },
		goal = "Tame a Splashjack",
		offer = "My pond is too quiet. Could you bring me a Splashjack from the brook?",
		done = "Listen to it splash! Take this: a stronger rope for your travels.",
		rewards = {
			{ kind = "Item", item = "Braided", count = 1 },
			{ kind = "Material", material = "Fernfluff", count = 6 },
		},
	},
	{
		id = "gw_heron_watch",
		name = "Heron Watch",
		line = LINE,
		step = 3,
		optional = false,
		giver = { name = "Ilsa Corbin", place = "The Waystation" },
		requires = { "gw_pond_friend" },
		requiresFlags = {},
		objective = { kind = "BeatTamer", tamer = "gw_odette" },
		goal = "Beat Odette Fenn on Route B",
		offer = "A birdwatcher on River Road needs a lesson. Prove you can handle the road.",
		done = "Word travels fast. You are ready for the old wood.",
		rewards = { { kind = "Item", item = "GreatTonic", count = 2 } },
	},
	{
		id = "gw_woodcutters_word",
		name = "The Woodcutter's Word",
		line = LINE,
		step = 4,
		optional = false,
		giver = { name = "Juniper Vale", place = "The Notice Oak" },
		requires = { "gw_heron_watch" },
		requiresFlags = {},
		objective = { kind = "BeatTamer", tamer = "gw_corwin" },
		goal = "Beat Corwin Ashby in the Old Wood",
		offer = "Old Corwin guards the road to the gate. Win his respect, and I have a gift.",
		done = "He sent word himself. Here is a friend who can stand in front of a team.",
		rewards = {
			{ kind = "Coins", amount = FINAL_COINS },
			{ kind = "PrismCandy", amount = FINAL_CANDY },
			{
				kind = "Creature",
				species = "Stumpwarden",
				level = 8,
				rarity = "Common",
				colour = "Bark",
			},
		},
	},
	{
		id = "gw_hollowbough",
		name = "The Sleeper in the Hollow",
		line = LINE,
		step = 5,
		optional = true,
		giver = { name = "Juniper Vale", place = "The Notice Oak" },
		requires = { "gw_fresh_tracks" },
		requiresFlags = { "giant_glimpse" },
		objective = { kind = "BeatGiant", giant = "greenwood_hollowbough" },
		goal = "Beat Hollowbough in its hollow",
		offer = "The old tree walks when it wakes. Beat it, if you dare. Bring a Giant Horn.",
		done = "You stood up to Hollowbough! The whole town will hear of this.",
		rewards = {
			{ kind = "Item", item = "Revive", count = 1 },
			{ kind = "Material", material = "Fernfluff", count = 5 },
		},
	},
}

return quests
