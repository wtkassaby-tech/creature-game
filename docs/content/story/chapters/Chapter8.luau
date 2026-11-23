--!strict
-- DRAFT, not wired into the game (docs/content/story/). Copy to src/content/story_data/ and add to
-- src/content/Story.luau only after Ayrton approves it and the biome's map, tamers and giant exist.
--
-- Chapter 8 of 11: Stormreach. Beats in order, with timing targets that pick up where chapter 7
-- ends (minute 690; all [Defaults] to tune in playtests). Finishing a beat sets a flag equal to its
-- id. The first beat needs "ember_road_on", the last beat of chapter 7.
--
-- The arc (docs/content/story/ARC.md, chapter 8): first sight of the tear (brief section 8), and the
-- rival's turn.
--  - From Cloud Isle the player sees the tear over the Crown for the first time (plan 13: the tear is
--    shown by story flag from here on), and that the halo is not cloud but fleece: Nimbram, holding
--    the tear small, and tired.
--  - The Unraveller speaks for the first time, to the rival: cut the ram's fleece and never come
--    second again. The tear spills tear-touched creatures onto the isle; the player fights them
--    (story battle `tear_swarm`) while the rival holds the bridge: the brief's team-up. His first
--    creature leaps from Sorrel's arms to shield him; he picks it up and says no.
--  - He lets every giant he stitched go. His tint stops rising (tamer data, chapter 10: about 0.5).
--  - The mentor goes silent: no letter at all once the tear can be seen. Sorrel notices.
-- Static (the biome's new idea, a drain on Tempo) is taught by the wind-gauge keeper. The gate is
-- held by a local champion. The giant is optional. Dialogue: at most three lines of 90 characters a
-- beat. Place, people and battle ids are placeholders for data not yet written.

local EconomyConfig = require("../../config/EconomyConfig")
local WorldTypes = require("../../shared/WorldTypes")

local BIOME = 8
local TOKEN_LEVEL = 82 -- the clear token: three under the cap of 85

local thanks: { WorldTypes.Reward } = {
	{ kind = "Item", item = "Revive", count = 2 },
	{ kind = "Item", item = "GreatTonic", count = 2 },
}

local badge: { WorldTypes.Reward } = {
	{ kind = "Badge", id = "stormreach_badge", name = "Vane Badge" },
	{
		kind = "Coins",
		amount = math.floor(
			EconomyConfig.TRAINED.Gate.firstClear * EconomyConfig.ONE_TIME_MULT[BIOME]
		),
	},
	{ kind = "PrismCandy", amount = EconomyConfig.CANDY.GateFirstClear.perClaim },
	{
		kind = "Creature",
		species = "Loomoth", -- Cosmic beats Arcane, the next biome; wild ones stay rare
		level = TOKEN_LEVEL,
		rarity = "Common",
		colour = "Sand",
	},
}

local beats: { WorldTypes.Beat } = {
	{
		id = "storm_arrival",
		name = "Highwhistle",
		minuteFrom = 690,
		minuteTo = 696,
		trigger = { kind = "Enter", target = "stormreach_hub", requires = { "ember_road_on" } },
		unlocks = { "storm_hub" },
		grants = {},
		lines = {
			{
				speaker = "Sign",
				text = "Highwhistle. Hold onto your hat. We keep a drawer of other people's.",
			},
			{
				speaker = "Fitch",
				text = "Off the lift and only a bit green? Good going. Everyone's green the first time.",
			},
		},
	},
	{
		id = "storm_static",
		name = "The Gauge House",
		minuteFrom = 694,
		minuteTo = 700,
		trigger = { kind = "Talk", target = "ansel_weir", requires = { "storm_arrival" } },
		unlocks = { "static", "storm_quest_line", "storm_routes" },
		grants = {},
		lines = {
			{
				speaker = "Ansel",
				text = "Storm creatures crackle. A Static hit drains Tempo, so a quick one loses its extra strike.",
			},
			{
				speaker = "Ansel",
				text = "Storm creatures never hold a charge. Sand ones ground it. Bring a Sand friend up.",
			},
			{
				speaker = "Ansel",
				text = "And mind the wind. Some days it blows from places that aren't on any map.",
			},
		},
	},
	{
		id = "first_storm_tamer",
		name = "A local tamer",
		minuteFrom = 698,
		minuteTo = 712,
		trigger = { kind = "Win", target = "sr_lark", requires = { "storm_static" } },
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Lark",
				text = "Six in ten creatures up here fly. Wings first, questions after. Good bout!",
			},
		},
	},
	{
		id = "storm_catch",
		name = "A catch on the wind",
		minuteFrom = 708,
		minuteTo = 722,
		trigger = { kind = "Tame", requires = { "first_storm_tamer" } },
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Sorrel",
				text = "Its feathers are humming. Is that normal? Tell me that's normal.",
			},
		},
	},
	{
		id = "the_moths",
		name = "Pale moths",
		minuteFrom = 725,
		minuteTo = 740,
		trigger = { kind = "Talk", target = "corra_wick", requires = { "storm_catch" } },
		unlocks = { "cloud_isle" },
		grants = {},
		lines = {
			{
				speaker = "Corra",
				text = "See the pale moths? Loomoths. Nobody saw one before the night the sky tore.",
			},
			{
				speaker = "Corra",
				text = "Their wings show stars. Not our stars. Count them some time. You'll get a chill.",
			},
			{
				speaker = "Corra",
				text = "Every evening they fly out to Cloud Isle, off the west road. Like they're going home.",
			},
		},
	},
	{
		id = "cloud_isle",
		name = "First sight",
		minuteFrom = 750,
		minuteTo = 765,
		trigger = { kind = "Sight", target = "cloud_isle", requires = { "the_moths" } },
		lookAt = "the_tear",
		unlocks = { "tear_visible" },
		grants = {},
		lines = {
			{
				speaker = "You",
				text = "There, over the Crown. A rip in the sky, violet at the edges, like torn cloth.",
			},
			{
				speaker = "You",
				text = "The halo isn't cloud. It's fleece. Something huge is curled round the tear, holding it.",
			},
			{
				speaker = "Sorrel",
				text = "It's breathing. Whatever it is, it's so tired. You can tell from here.",
			},
		},
	},
	{
		id = "the_voice",
		name = "A voice from the tear",
		minuteFrom = 751,
		minuteTo = 766,
		trigger = { kind = "Follow", requires = { "cloud_isle" } },
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Rival",
				text = "You followed me up here. Course you did. Always one step ahead of me.",
			},
			{
				speaker = "Unraveller",
				text = "Shh. Cut the old ram's fleece, little one, and you will never come second again.",
			},
			{
				speaker = "Rival",
				text = "It wants me to cut the halo. I said I'd think about it. ...I'm thinking.",
			},
		},
	},
	{
		id = "back_to_back",
		name = "Back to back",
		minuteFrom = 760,
		minuteTo = 775,
		trigger = { kind = "Win", target = "tear_swarm", requires = { "the_voice" } },
		unlocks = {},
		grants = thanks,
		lines = {
			{
				speaker = "Rival",
				text = "Back to back. Like we were ever on the same side. ...We were, weren't we?",
			},
			{
				speaker = "You",
				text = "Mid-fight, his first friend jumped from Sorrel's arms and stood in front of him.",
			},
			{
				speaker = "Rival",
				text = "I'm not cutting anything. You hear me, voice? No.",
			},
		},
	},
	{
		id = "rival_lets_go",
		name = "Letting go",
		minuteFrom = 761,
		minuteTo = 776,
		trigger = { kind = "Follow", requires = { "back_to_back" } },
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Rival",
				text = "I'm letting the giants go. Every one I stitched. It's going to hurt. Good.",
			},
			{ speaker = "Sorrel", text = "Come home with us." },
			{
				speaker = "Rival",
				text = "Not yet. I've a question for the old man first. And this one's coming with me.",
			},
		},
	},
	{
		id = "squall_sighting",
		name = "The herald",
		minuteFrom = 785,
		minuteTo = 800,
		trigger = { kind = "Sight", target = "anvil_ledge", requires = { "rival_lets_go" } },
		lookAt = "stormreach_lair",
		unlocks = { "storm_giant_marker" },
		grants = {},
		lines = {
			{
				speaker = "Fitch",
				text = "Squallray's spooked. Circles the Crown every dusk, guarding the old ram, they say.",
			},
			{
				speaker = "Fitch",
				text = "Its lair's in the Anvil's cloud. When its wing tips tilt, hit it with Crystal or Arcane.",
			},
		},
	},
	{
		id = "storm_gate_challenge",
		name = "The Anvil Gate",
		minuteFrom = 870,
		minuteTo = 885,
		trigger = { kind = "Enter", target = "stormreach_gate", requires = { "squall_sighting" } },
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Wyn",
				text = "Wyn Halyard, keeper of the Anvil Gate. Five of mine ride the wind. Hold on tight.",
			},
			{
				speaker = "Wyn",
				text = "Your friend went down the Cloud Stair this morning, a creature in his arms. Smiling.",
			},
		},
	},
	{
		id = "storm_badge",
		name = "The eighth badge",
		minuteFrom = 875,
		minuteTo = 890,
		trigger = {
			kind = "Win",
			target = "champion_halyard",
			requires = { "storm_gate_challenge" },
		},
		unlocks = { "badge_8", "level_cap_95" },
		grants = badge,
		lines = {
			{
				speaker = "Wyn",
				text = "The Vane Badge. It points at storms, and you're walking into one.",
			},
			{
				speaker = "Wyn",
				text = "A Loomoth, too. It keeps flying toward the tear. Let it show you the way.",
			},
		},
	},
	{
		id = "storm_road_on",
		name = "The road on",
		minuteFrom = 885,
		minuteTo = 910,
		trigger = {
			kind = "Enter",
			target = "stormreach_sealed_path",
			requires = { "storm_badge" },
		},
		unlocks = { "biome_9", "chapter_9_teaser" },
		grants = {},
		lines = {
			{
				speaker = "Sign",
				text = "The Cloud Stair. A long way down. Lanternmoor at the bottom. Badge holders only.",
			},
			{
				speaker = "Sorrel",
				text = "That purple light down there, blinking? You can see it from our roof. It always blinks.",
			},
			{
				speaker = "Sorrel",
				text = "And Mentor hasn't written since the tear showed. Not one truly. That's worse, somehow.",
			},
		},
	},
}

local Chapter8: WorldTypes.Chapter = {
	id = "chapter_8",
	number = 8,
	name = "Stormreach",
	beats = beats,
}

return Chapter8
