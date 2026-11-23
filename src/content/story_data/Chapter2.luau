--!strict
-- Chapter 2 of 11: Dust Canyon. Beats in order, with timing targets that pick up where chapter 1
-- ends (minute 60; all [Defaults] to tune in playtests). Finishing a beat sets a flag equal to its id.
-- The first beat needs "sealed_path", the last beat of chapter 1, so the storyline reads straight on.
--
-- The arc (brief section 9), one step on from chapter 1:
--  - The rival has found more of the glinting thing. His team's tint has doubled, he carries a shard
--    that hums when he fights, and he hints that the mentor never answers questions. He has also
--    pushed past the gate's warden without a battle: he is getting ahead by dark means.
--  - The mentor keeps lying to protect the player: a letter says the glowing stones are "only
--    minerals" and that they will talk "when you are older". It is the second small evasion since
--    "do not ask what you must be strong for", and it ends the way the first did, with a promise.
-- The gate is held by a local champion, not the rival (master plan 4.5), so the rival's own battle
-- is mid-biome. Dialogue is short and skippable: at most three lines of 90 characters a beat.
--
-- Coins, candy and items come from EconomyConfig, so tuning the economy tunes the story's gifts.

local EconomyConfig = require("../../config/EconomyConfig")
local WorldTypes = require("../../shared/WorldTypes")

local TOKEN_LEVEL = 22 -- the clear token, a friend for the road ahead: three under the cap of 25

local letter: { WorldTypes.Reward } = {
	{ kind = "Item", item = "Braided", count = 2 },
}

local badge: { WorldTypes.Reward } = {
	{ kind = "Badge", id = "dust_canyon_badge", name = "Cairn Badge" },
	{
		kind = "Coins",
		amount = math.floor(EconomyConfig.TRAINED.Gate.firstClear * EconomyConfig.ONE_TIME_MULT[2]),
	},
	{ kind = "PrismCandy", amount = EconomyConfig.CANDY.GateFirstClear.perClaim },
	{
		kind = "Creature",
		species = "Duneskit",
		level = TOKEN_LEVEL,
		rarity = "Common",
		colour = "Sand",
	},
}

local beats: { WorldTypes.Beat } = {
	{
		id = "canyon_arrival",
		name = "Kilnrest",
		minuteFrom = 60,
		minuteTo = 64,
		trigger = { kind = "Enter", target = "dust_canyon_hub", requires = { "sealed_path" } },
		unlocks = { "canyon_hub" },
		grants = {},
		lines = {
			{
				speaker = "Sign",
				text = "Kilnrest. Fresh water at the Seep, shade at the Trading Post.",
			},
			{
				speaker = "Tamsin",
				text = "A Greenwood badge? Welcome to Kilnrest. The canyon is hard on the unready.",
			},
		},
	},
	{
		id = "canyon_trader",
		name = "Rook's Trading Post",
		minuteFrom = 62,
		minuteTo = 67,
		trigger = { kind = "Talk", target = "tamsin_rook", requires = { "canyon_arrival" } },
		unlocks = { "canyon_quest_line", "canyon_routes" },
		grants = {},
		lines = {
			{
				speaker = "Tamsin",
				text = "Some creatures here glint amber. Gem-touched, folk say, and each carries a number.",
			},
			{
				speaker = "Tamsin",
				text = "Win a few scraps on the Dry Wash and I will pay you. Mesa Road is open too.",
			},
		},
	},
	{
		id = "canyon_catch",
		name = "A catch in the canyon",
		minuteFrom = 64,
		minuteTo = 72,
		trigger = { kind = "Tame", requires = { "canyon_trader" } },
		unlocks = { "gem_hunting" },
		grants = {},
		lines = {
			{
				speaker = "Tamsin",
				text = "Your first catch out here! If one ever shines amber, you have found a gem-tier.",
			},
		},
	},
	{
		id = "first_canyon_tamer",
		name = "A local tamer",
		minuteFrom = 66,
		minuteTo = 76,
		trigger = { kind = "Win", target = "dc_ines", requires = { "canyon_catch" } },
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Ines",
				text = "Quick hands! Sand creatures dart about, so land your hits before they run.",
			},
		},
	},
	{
		id = "mentors_letter",
		name = "A letter from Thistledown",
		minuteFrom = 72,
		minuteTo = 80,
		trigger = { kind = "Talk", target = "fenwick_dray", requires = { "first_canyon_tamer" } },
		unlocks = {},
		grants = letter,
		lines = {
			{
				speaker = "Fenwick",
				text = "Courier here! A letter for you, all the way from Thistledown.",
			},
			{
				speaker = "Mentor",
				text = "Keep clear of any odd glowing stones. They are only minerals. Truly. Nothing more.",
			},
			{
				speaker = "Mentor",
				text = "I have put two ropes in the parcel. We will talk when you are older. I promise.",
			},
		},
	},
	{
		id = "canyon_rival",
		name = "The shard",
		minuteFrom = 85,
		minuteTo = 95,
		trigger = { kind = "Win", target = "rival_canyon", requires = { "mentors_letter" } },
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Rival",
				text = "I found more of that glint. It hums when I fight, and my team feels it too.",
			},
			{
				speaker = "Rival",
				text = "Ask your mentor what it is. He never answers me, either.",
			},
		},
	},
	{
		id = "mesa_sighting",
		name = "The mesa that walks",
		minuteFrom = 95,
		minuteTo = 105,
		trigger = { kind = "Sight", target = "spire_garden", requires = { "canyon_rival" } },
		unlocks = { "canyon_giant_marker" },
		grants = {},
		lines = {
			{
				speaker = "Scout",
				text = "That red mesa just stood up! Mesalith. Restless since the sky flickered over the Crown.",
			},
			{
				speaker = "Scout",
				text = "Its shelf is off the Mesa Road. Bring something that can wash out its slam.",
			},
		},
	},
	{
		id = "canyon_gate_challenge",
		name = "The Stair Gate",
		minuteFrom = 115,
		minuteTo = 130,
		trigger = { kind = "Enter", target = "dust_canyon_gate", requires = { "mesa_sighting" } },
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Isolde",
				text = "I am Isolde Karrow, warden of the Stair. A badge is earned here, not given.",
			},
			{
				speaker = "Isolde",
				text = "A boy in a green jacket shoved past me at dawn. His team had a strange amber shine.",
			},
		},
	},
	{
		id = "canyon_badge",
		name = "The second badge",
		minuteFrom = 120,
		minuteTo = 135,
		trigger = {
			kind = "Win",
			target = "champion_karrow",
			requires = { "canyon_gate_challenge" },
		},
		unlocks = { "badge_2", "level_cap_35" },
		grants = badge,
		lines = {
			{
				speaker = "Isolde",
				text = "A quick climb. The Cairn Badge is yours, and a friend from Kilnrest besides.",
			},
			{
				speaker = "Isolde",
				text = "Whatever that boy carries, it is not just strength. Mind him.",
			},
		},
	},
	{
		id = "canyon_road_on",
		name = "The road on",
		minuteFrom = 125,
		minuteTo = 140,
		trigger = {
			kind = "Enter",
			target = "dust_canyon_sealed_path",
			requires = { "canyon_badge" },
		},
		unlocks = { "biome_3", "chapter_3_teaser" },
		grants = {},
		lines = {
			{ speaker = "Sign", text = "The Tide Flats road. Shut to all but badge holders." },
			{
				speaker = "Isolde",
				text = "Off you go, then. The sea air bites, so pack a tonic or two.",
			},
		},
	},
}

local Chapter2: WorldTypes.Chapter = {
	id = "chapter_2",
	number = 2,
	name = "Dust Canyon",
	beats = beats,
}

return Chapter2
