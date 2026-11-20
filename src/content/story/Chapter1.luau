--!strict
-- Chapter 1 of 11: Greenwood. Beats in order, with the first-session timing targets from
-- docs/research/market/02_STRUCTURE_AND_COMPETITORS.md section 6 (minutes from the start; all
-- [Default]s to tune in playtests). Finishing a beat sets a flag equal to its id.
--
-- The arc (brief section 9): the rival loses the first battle and begins to turn, seen in a glint he
-- notices and in the tint on his gate team; the mentor is kind and is hiding something, seen in
-- three small evasions (the glint, the giant, "what is coming"). Names are roles until chosen.
-- Dialogue is short and skippable: at most three lines of 90 characters a beat.
--
-- Coins, candy, items and the second pen come from EconomyConfig, so tuning the economy tunes
-- the story's gifts.

local EconomyConfig = require("../../config/EconomyConfig")
local WorldTypes = require("../../shared/WorldTypes")

local STARTER_LEVEL = 5 -- the first creature; the rival's first team is level 4
local TOKEN_LEVEL = 12 -- the clear token, a friend for the road ahead

local lasso: { WorldTypes.Reward } = {
	{ kind = "Coins", amount = EconomyConfig.STARTING_COINS },
	{ kind = "Item", item = "Basic", count = EconomyConfig.STARTER_ITEMS.Basic },
	{ kind = "Item", item = "Tonic", count = EconomyConfig.STARTER_ITEMS.Tonic },
	{ kind = "Creature", species = "Gorsling", level = 2, rarity = "Common", colour = "Moss" },
}

local egg: { WorldTypes.Reward } = {
	{ kind = "Egg", parentA = "Stumpwarden", parentB = "Splashjack" },
	{ kind = "Pen" },
	{ kind = "Candy", amount = EconomyConfig.CANDY.MentorLesson.perClaim },
}

local badge: { WorldTypes.Reward } = {
	{ kind = "Badge", id = "greenwood_badge", name = "Acorn Badge" },
	{
		kind = "Coins",
		amount = math.floor(EconomyConfig.TRAINED.Gate.firstClear * EconomyConfig.ONE_TIME_MULT[1]),
	},
	{ kind = "Candy", amount = EconomyConfig.CANDY.GateFirstClear.perClaim },
	{
		kind = "Creature",
		species = "Gorsling",
		level = TOKEN_LEVEL,
		rarity = "Common",
		colour = "Bark",
	},
}

local beats: { WorldTypes.Beat } = {
	{
		id = "starter_choice",
		name = "Pick a friend",
		minuteFrom = 0,
		minuteTo = 0.5,
		trigger = { kind = "Start", requires = {} },
		unlocks = { "team_screen" },
		grants = {
			{
				kind = "Starter",
				choices = { "Mossmitt", "Spadesnout", "Sloshcalf" },
				level = STARTER_LEVEL,
			},
		},
		lines = {
			{
				speaker = "Mentor",
				text = "Welcome! Three friends are waiting. Pick the one that feels right.",
			},
		},
	},
	{
		id = "rival_challenge",
		name = "A challenge",
		minuteFrom = 0.5,
		minuteTo = 2,
		trigger = { kind = "Follow", requires = { "starter_choice" } },
		unlocks = { "battle" },
		grants = {},
		lines = {
			{ speaker = "Rival", text = "Hey, new kid! I took the one that beats yours. Ready?" },
			{ speaker = "Mentor", text = "Go on. It is only a friendly bout." },
		},
	},
	{
		id = "rival_parting",
		name = "A sore loser",
		minuteFrom = 1.5,
		minuteTo = 2.5,
		trigger = { kind = "Win", target = "rival_first", requires = { "rival_challenge" } },
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Rival",
				text = "I lost to a beginner. I need more than luck... What is that glint?",
			},
			{ speaker = "Mentor", text = "Only a pebble. Come away. Let me show you the lasso." },
		},
	},
	{
		id = "lasso_lesson",
		name = "The lasso lesson",
		minuteFrom = 2,
		minuteTo = 4,
		trigger = { kind = "Follow", requires = { "rival_parting" } },
		unlocks = { "lasso", "wild_battles" },
		grants = lasso,
		lines = {
			{
				speaker = "Mentor",
				text = "Weaken it first, then throw when the ring sits on the target.",
			},
			{
				speaker = "Mentor",
				text = "That one will not slip away. Take these ropes and tonics, on me.",
			},
		},
	},
	{
		id = "route_one",
		name = "Out on Route A",
		minuteFrom = 4,
		minuteTo = 6,
		trigger = { kind = "Enter", target = "greenwood_route_a", requires = { "lasso_lesson" } },
		unlocks = { "route_a", "shop", "healer" },
		grants = {},
		lines = {
			{
				speaker = "Mentor",
				text = "Battle what you find. Spend your coins at Tuppence's shop.",
			},
		},
	},
	{
		id = "first_tamer",
		name = "A local tamer",
		minuteFrom = 5,
		minuteTo = 8,
		trigger = { kind = "Win", target = "gw_pip", requires = { "route_one" } },
		unlocks = { "tamer_rematch_hint" },
		grants = {},
		lines = {
			{ speaker = "Pip", text = "You beat me! Tip: weaken them first, then throw the rope." },
		},
	},
	{
		id = "giant_glimpse",
		name = "The tree that walks",
		minuteFrom = 6,
		minuteTo = 8,
		trigger = { kind = "Sight", target = "clover_meadow", requires = { "first_tamer" } },
		unlocks = { "giant_marker" },
		grants = {},
		lines = {
			{
				speaker = "Mentor",
				text = "See that huge tree in the haze? Stay clear of it for now.",
			},
			{ speaker = "Mentor", text = "Promise me. Some things are best left asleep." },
		},
	},
	{
		id = "mentor_egg",
		name = "The mentor's egg",
		minuteFrom = 8,
		minuteTo = 12,
		trigger = { kind = "Talk", target = "mentor", requires = { "giant_glimpse" } },
		unlocks = { "breeding", "second_pen" },
		grants = egg,
		lines = {
			{
				speaker = "Mentor",
				text = "Watch how two of mine mix their parts. This egg is for you.",
			},
			{
				speaker = "Mentor",
				text = "Breeding is how you grow strong. Come back when it hatches.",
			},
			{ speaker = "Mentor", text = "Do not ask what you must be strong for. Just be ready." },
		},
	},
	{
		id = "third_creature",
		name = "A team of three",
		minuteFrom = 12,
		minuteTo = 15,
		trigger = { kind = "Tame", requires = { "mentor_egg" } },
		unlocks = { "team_of_three" },
		grants = {},
		lines = {
			{ speaker = "Mentor", text = "Three on your team. Now that is a proper tamer." },
		},
	},
	{
		id = "first_quest",
		name = "Thistledown favours",
		minuteFrom = 12,
		minuteTo = 15,
		trigger = { kind = "Talk", target = "marlow_tuppence", requires = { "third_creature" } },
		unlocks = { "quest_line", "world_map", "route_b" },
		grants = {},
		lines = {
			{
				speaker = "Marlow",
				text = "Got a minute? Win a few scraps on Clover Lane and I will pay you.",
			},
			{ speaker = "Marlow", text = "River Road is open now, if you feel brave." },
		},
	},
	{
		id = "gate_challenge",
		name = "The gatehouse",
		minuteFrom = 40,
		minuteTo = 55,
		trigger = { kind = "Enter", target = "greenwood_gate", requires = { "first_quest" } },
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Rival",
				text = "I have trained every day since. My team is not what it was.",
			},
			{ speaker = "Rival", text = "I do not play around any more. Come on." },
		},
	},
	{
		id = "badge_and_token",
		name = "The first badge",
		minuteFrom = 45,
		minuteTo = 58,
		trigger = { kind = "Win", target = "rival_gate", requires = { "gate_challenge" } },
		unlocks = { "badge_1", "daily_tasks", "level_cap_25" },
		grants = badge,
		lines = {
			{
				speaker = "Rival",
				text = "Again... Fine. Keep your badge. I will find a way to win.",
			},
			{
				speaker = "Mentor",
				text = "Your first badge! Take this friend from all of Thistledown.",
			},
		},
	},
	{
		id = "sealed_path",
		name = "The road on",
		minuteFrom = 50,
		minuteTo = 60,
		trigger = {
			kind = "Enter",
			target = "greenwood_sealed_path",
			requires = { "badge_and_token" },
		},
		unlocks = { "biome_2", "chapter_2_teaser" },
		grants = {},
		lines = {
			{ speaker = "Sign", text = "The Dust Canyon road. Shut to all but badge holders." },
			{
				speaker = "Mentor",
				text = "It opens for you. Go on. I will stay and mend a few things.",
			},
		},
	},
}

local Chapter1: WorldTypes.Chapter = {
	id = "chapter_1",
	number = 1,
	name = "Greenwood",
	beats = beats,
}

return Chapter1
