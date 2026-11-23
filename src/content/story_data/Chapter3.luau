--!strict
-- Chapter 3 of 11: Tide Flats. Beats in order, with timing targets that pick up where chapter 2
-- ends (minute 140; all [Defaults] to tune in playtests). Finishing a beat sets a flag equal to its id.
-- The first beat needs "canyon_road_on", the last beat of chapter 2, so the storyline reads straight on.
--
-- The arc (brief section 9), one more step on from chapter 2:
--  - The rival holds this gate himself. His team's tint is 0.75 and he carries two shards now, so some
--    of his creatures are gem-touched. He no longer hides that the glint talks to him, and he says the
--    mentor knows what the sky's flicker is. After the battle he goes ahead into the Mire alone.
--  - The mentor's third evasion is the closest he has come to the truth: a note says the flicker over
--    the sea was "weather", but also that he "should have told you more, long ago", and the promise
--    to explain now has a place on it: the Mire. (Ch1: "do not ask what you must be strong for"; ch2:
--    "only minerals", "when you are older".)
-- Bait (the biome's new idea, master plan 4.5) is taught by the shop keeper at the second beat, and the
-- mentor's parcel pays two baits so the player can try it before the lair. The giant is optional; the
-- sighting beat only points at its wreck. Dialogue is short and skippable: at most three lines of
-- 90 characters a beat.
--
-- Coins, candy and items come from EconomyConfig, so tuning the economy tunes the story's gifts.

local EconomyConfig = require("../../config/EconomyConfig")
local WorldTypes = require("../../shared/WorldTypes")

local TOKEN_LEVEL = 32 -- the clear token, a friend for the road ahead: three under the cap of 35

local parcel: { WorldTypes.Reward } = {
	{ kind = "Item", item = "Bait", count = 2 },
}

local badge: { WorldTypes.Reward } = {
	{ kind = "Badge", id = "tide_flats_badge", name = "Breaker Badge" },
	{
		kind = "Coins",
		amount = math.floor(EconomyConfig.TRAINED.Gate.firstClear * EconomyConfig.ONE_TIME_MULT[3]),
	},
	{ kind = "PrismCandy", amount = EconomyConfig.CANDY.GateFirstClear.perClaim },
	{
		kind = "Creature",
		species = "Moatkeep",
		level = TOKEN_LEVEL,
		rarity = "Common",
		colour = "Sand",
	},
}

local beats: { WorldTypes.Beat } = {
	{
		id = "tide_arrival",
		name = "Saltwick",
		minuteFrom = 140,
		minuteTo = 144,
		trigger = { kind = "Enter", target = "tide_flats_hub", requires = { "canyon_road_on" } },
		unlocks = { "tide_hub" },
		grants = {},
		lines = {
			{
				speaker = "Sign",
				text = "Saltwick. Tide tables at the quay. The causeway floods at dusk.",
			},
			{
				speaker = "Odalys",
				text = "A Cairn Badge! Welcome to Saltwick. Mind the tide, it is faster than it looks.",
			},
		},
	},
	{
		id = "tide_bait",
		name = "Tarn's Chandlery",
		minuteFrom = 142,
		minuteTo = 147,
		trigger = { kind = "Talk", target = "odalys_tarn", requires = { "tide_arrival" } },
		unlocks = { "bait", "tide_quest_line", "tide_routes" },
		grants = {},
		lines = {
			{
				speaker = "Odalys",
				text = "Rock pools hide what the open beach never shows. Tide Bait brings it out.",
			},
			{
				speaker = "Odalys",
				text = "Craft it from Brine Shells, then use it at a rustle spot: a pool, kelp or a cave.",
			},
			{
				speaker = "Odalys",
				text = "Something always steps out, so pick your spot well. The tide counts your baits.",
			},
		},
	},
	{
		id = "first_tide_tamer",
		name = "A local tamer",
		minuteFrom = 144,
		minuteTo = 154,
		trigger = { kind = "Win", target = "tf_nell", requires = { "tide_bait" } },
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Nell",
				text = "Quick feet! Glissots slip away over wet sand, so land your hits early.",
			},
		},
	},
	{
		id = "bait_catch",
		name = "A catch from the shallows",
		minuteFrom = 148,
		minuteTo = 158,
		trigger = { kind = "Tame", requires = { "first_tide_tamer" } },
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Odalys",
				text = "A fine catch! If one ever glints amber, it is gem-tier. Keep it safe.",
			},
		},
	},
	{
		id = "mentors_note",
		name = "A note from Thistledown",
		minuteFrom = 154,
		minuteTo = 162,
		trigger = { kind = "Talk", target = "bastian_wake", requires = { "bait_catch" } },
		unlocks = {},
		grants = parcel,
		lines = {
			{
				speaker = "Bastian",
				text = "Ferry post! A parcel for you, off the morning boat from Thistledown.",
			},
			{
				speaker = "Mentor",
				text = "The sky flickered over the sea last night. Weather. Truly. Do not look for it.",
			},
			{
				speaker = "Mentor",
				text = "Two baits enclosed. I owe you the truth. I will bring it to the Mire myself.",
			},
		},
	},
	{
		id = "tide_champion",
		name = "Captain Marr",
		minuteFrom = 160,
		minuteTo = 172,
		trigger = { kind = "Win", target = "champion_marr", requires = { "mentors_note" } },
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Marr",
				text = "A good strike, and a fair one. Folk say the old wreck stood up and walked.",
			},
			{
				speaker = "Marr",
				text = "I thought I had dreamt it. Then the creatures in the pools started to glint amber.",
			},
		},
	},
	{
		id = "wreck_sighting",
		name = "The wreck that walks",
		minuteFrom = 170,
		minuteTo = 180,
		trigger = { kind = "Sight", target = "shipwreck_reach", requires = { "tide_champion" } },
		unlocks = { "tide_giant_marker" },
		grants = {},
		lines = {
			{
				speaker = "Sorrel",
				text = "That wreck is moving! Carrackon, the hermit of the bay, is wearing its ship.",
			},
			{
				speaker = "Sorrel",
				text = "Its lair is off the Breakwater Road. Its big waves fear Leaf and Toxic types.",
			},
		},
	},
	{
		id = "tide_gate_challenge",
		name = "The Breakwater Gate",
		minuteFrom = 190,
		minuteTo = 205,
		trigger = { kind = "Enter", target = "tide_flats_gate", requires = { "wreck_sighting" } },
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Rival",
				text = "You again. You do not even look tired. I have not slept in days.",
			},
			{
				speaker = "Rival",
				text = "The glint hums even in my sleep. Sometimes it sounds like it is asking me something.",
			},
			{
				speaker = "Rival",
				text = "Your mentor knows what that flicker is. Ask him. Then fight me.",
			},
		},
	},
	{
		id = "tide_badge",
		name = "The third badge",
		minuteFrom = 195,
		minuteTo = 210,
		trigger = {
			kind = "Win",
			target = "rival_breakwater",
			requires = { "tide_gate_challenge" },
		},
		unlocks = { "badge_3", "level_cap_45" },
		grants = badge,
		lines = {
			{
				speaker = "Rival",
				text = "Fine. The badge is yours. I am going on into the Mire, and the glint comes along.",
			},
			{
				speaker = "Odalys",
				text = "Gone like the tide. Here, a friend from Saltwick to see you on your way.",
			},
		},
	},
	{
		id = "tide_road_on",
		name = "The road on",
		minuteFrom = 200,
		minuteTo = 215,
		trigger = {
			kind = "Enter",
			target = "tide_flats_sealed_path",
			requires = { "tide_badge" },
		},
		unlocks = { "biome_4", "chapter_4_teaser" },
		grants = {},
		lines = {
			{ speaker = "Sign", text = "The Mire road. Shut to all but badge holders." },
			{
				speaker = "Bastian",
				text = "Go slow. Thick air, slow water and lights that are not lanterns.",
			},
		},
	},
}

local Chapter3: WorldTypes.Chapter = {
	id = "chapter_3",
	number = 3,
	name = "Tide Flats",
	beats = beats,
}

return Chapter3
