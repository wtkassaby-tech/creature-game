--!strict
-- The Mire's quest line, "Sedgeholm Errands": four quests in order, ending in a guaranteed creature,
-- plus one optional quest for the giant. The main line never needs the giant or an uncommon
-- species. Coins and Prism Candy for finishing the line come from EconomyConfig (one-time
-- multiplier for biome 4; Prism Candy by biome, where a biome past the end of QUEST_LINE_CANDY
-- uses its last entry, as Economy does), so tuning the economy tunes the quests.
--
-- The line teaches the biome's idea, poison: step 2 asks for a Fenwhisk, a Toxic creature that can
-- never be poisoned, and the line ends in a Bulbroth, a sturdy Toxic creature otherwise met only at
-- rustle spots, never on the open routes. Both come before the gate, whose keeper fights with poison. Step 2 also pays a Tide Bait, which works
-- at the Mire's rustle spots, where its two uncommon species live. The Mire has no material of its
-- own yet (EconomyConfig.MATERIAL_BY_BIOME stops at Tide Flats, so Mire wins drop Brine Shells);
-- the middle steps pay Brine Shells for that reason.
-- Each giver stands at a hub building: `giver.place` is that building's name.

local EconomyConfig = require("../../config/EconomyConfig")
local WorldTypes = require("../../shared/WorldTypes")

local LINE = "mire_errands"
local BIOME = 4
local FINAL_COINS = math.floor(EconomyConfig.QUEST_LINE_COINS * EconomyConfig.ONE_TIME_MULT[BIOME])
local FINAL_CANDY = EconomyConfig.QUEST_LINE_CANDY[math.min(BIOME, #EconomyConfig.QUEST_LINE_CANDY)]

local quests: { WorldTypes.Quest } = {
	{
		id = "mr_first_wade",
		name = "First Wade",
		line = LINE,
		step = 1,
		optional = false,
		giver = { name = "Vesper Quill", place = "Quill's Sundries" },
		requires = {},
		requiresFlags = { "mire_poison" },
		objective = { kind = "WinWild", count = 4, route = "mire_route_a" },
		goal = "Win 4 wild battles on Route A",
		offer = "Walk the duckboards and win a few. I like to know who I am selling to.",
		done = "Muddy, but standing. Here, tonics for the bites you will get.",
		rewards = { { kind = "Item", item = "Tonic", count = 4 } },
	},
	{
		id = "mr_immune_friend",
		name = "A Friend Who Never Sickens",
		line = LINE,
		step = 2,
		optional = false,
		giver = { name = "Ottilie Dunmore", place = "The Clearwater Spring" },
		requires = { "mr_first_wade" },
		requiresFlags = {},
		objective = { kind = "TameSpecies", species = "Fenwhisk" },
		goal = "Tame a Fenwhisk",
		offer = "Bring me a Fenwhisk from the reeds. Toxic creatures never catch poison.",
		done = "There! Poison slides right off it. Keep it on your team. And take this bait.",
		rewards = {
			{ kind = "Item", item = "Braided", count = 2 },
			{ kind = "Item", item = "Bait", count = 1 },
		},
	},
	{
		id = "mr_light_count",
		name = "Counting the Lights",
		line = LINE,
		step = 3,
		optional = false,
		giver = { name = "Jory Pike", place = "The Punt Landing" },
		requires = { "mr_immune_friend" },
		requiresFlags = {},
		objective = { kind = "BeatTamer", tamer = "mr_ysolde" },
		goal = "Beat Ysolde Greaves on Route B",
		offer = "Ysolde says the marsh lights are multiplying. Go and settle her nerves.",
		done = "She says you were calm as still water. Take these, and some shells.",
		rewards = {
			{ kind = "Item", item = "GreatTonic", count = 2 },
			{ kind = "Material", material = "BrineShell", count = 4 },
		},
	},
	{
		id = "mr_sluice_pass",
		name = "The Sluice Pass",
		line = LINE,
		step = 4,
		optional = false,
		giver = { name = "Ezra Dunlin", place = "The Mooring Post" },
		requires = { "mr_light_count" },
		requiresFlags = {},
		objective = { kind = "BeatTamer", tamer = "mr_cuthbert" },
		goal = "Beat Cuthbert Mott near the Sluice Gate",
		offer = "Cuthbert keeps the key to the sluice path. Win his pass before you see Vell.",
		done = "Pass granted! Here is a sturdy friend who never catches poison.",
		rewards = {
			{ kind = "Coins", amount = FINAL_COINS },
			{ kind = "PrismCandy", amount = FINAL_CANDY },
			{
				kind = "Creature",
				species = "Bulbroth",
				level = 36,
				rarity = "Uncommon",
				colour = "Bark",
			},
		},
	},
	{
		id = "mr_sloughback",
		name = "The Grove That Breathes",
		line = LINE,
		step = 5,
		optional = true,
		giver = { name = "Ezra Dunlin", place = "The Mooring Post" },
		requires = { "mr_first_wade" },
		requiresFlags = { "grove_sighting" },
		objective = { kind = "BeatGiant", giant = "mire_sloughback" },
		goal = "Beat Sloughback in the Sunken Grove",
		offer = "Sloughback is awake and fuming in its grove. Calm it if you can. Bring a Giant Horn.",
		done = "You calmed Sloughback! The fog lifted over the whole village.",
		rewards = {
			{ kind = "Item", item = "Revive", count = 1 },
			{ kind = "Material", material = "BrineShell", count = 5 },
		},
	},
}

return quests
