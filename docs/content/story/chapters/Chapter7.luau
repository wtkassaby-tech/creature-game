--!strict
-- DRAFT, not wired into the game (docs/content/story/). Copy to src/content/story_data/ and add to
-- src/content/Story.luau only after Ayrton approves it and the biome's map, tamers and giant exist.
--
-- Chapter 7 of 11: Emberfall. Beats in order, with timing targets that pick up where chapter 6
-- ends (minute 520; all [Defaults] to tune in playtests). Finishing a beat sets a flag equal to its
-- id. The first beat needs "deep_road_on", the last beat of chapter 6.
--
-- The arc (docs/content/story/ARC.md, chapter 7): the rival's lowest point.
--  - He has stitched the volcano's giant to a leash with dark thread ("giants taken by force", brief
--    [Default]). It walks the rim and the town's three-hundred-year beacon gutters. He holds the gate
--    with the stitched stag leading his five (tint 1, tamer data). When he loses, the stitches snap
--    and the giant bolts for its lair, so every player can still fight and catch it as normal.
--  - His first crack: "It doesn't hurt to lose anymore. That's the part that scares me."
--  - Sorrel's own thread: a glassblower teaches her to fill cracks with gold so the mend shows. It is
--    the theme said once, and the skill she uses on the Frayling in chapter 9.
--  - The mentor's lie turns protective and frightened: "Come home. The giants will settle. Truly."
--    and the first true crack in him: "I cannot lose anyone else."
-- Burn (the biome's new idea) is taught by the healer; the Winged body plan by the first tamer; the
-- fifth team slot (opened by badge 6) is named on arrival. The giant is optional. Dialogue: at most
-- three lines of 90 characters a beat. Place, people and battle ids are placeholders.

local EconomyConfig = require("../../config/EconomyConfig")
local WorldTypes = require("../../shared/WorldTypes")

local BIOME = 7
local TOKEN_LEVEL = 72 -- the clear token: three under the cap of 75

local letter: { WorldTypes.Reward } = {
	{ kind = "Item", item = "GreatTonic", count = 3 },
}

local badge: { WorldTypes.Reward } = {
	{ kind = "Badge", id = "emberfall_badge", name = "Cinder Badge" },
	{
		kind = "Coins",
		amount = math.floor(
			EconomyConfig.TRAINED.Gate.firstClear * EconomyConfig.ONE_TIME_MULT[BIOME]
		),
	},
	{ kind = "PrismCandy", amount = EconomyConfig.CANDY.GateFirstClear.perClaim },
	{
		kind = "Creature",
		species = "Glassgaffer", -- carries a Crystal move on its head: Crystal beats Storm, next
		level = TOKEN_LEVEL,
		rarity = "Common",
		colour = "Bark",
	},
}

local beats: { WorldTypes.Beat } = {
	{
		id = "ember_arrival",
		name = "Cinderwick",
		minuteFrom = 520,
		minuteTo = 525,
		trigger = { kind = "Enter", target = "emberfall_hub", requires = { "deep_road_on" } },
		unlocks = { "ember_hub" },
		grants = {},
		lines = {
			{
				speaker = "Sign",
				text = "Cinderwick. Our beacon has burned three hundred years. Please do not blow on it.",
			},
			{
				speaker = "Jem",
				text = "In out of the ash! It's five a side down here. Everything's bigger near a volcano.",
			},
		},
	},
	{
		id = "ember_burn",
		name = "The Cooling House",
		minuteFrom = 523,
		minuteTo = 529,
		trigger = { kind = "Talk", target = "elspeth_tinder", requires = { "ember_arrival" } },
		unlocks = { "burn", "ember_quest_line", "ember_routes" },
		grants = {},
		lines = {
			{
				speaker = "Elspeth",
				text = "A burn keeps stinging after the hit. A little every turn, then it fades.",
			},
			{
				speaker = "Elspeth",
				text = "Fire creatures never burn. Keep one in your five and you've a friend who won't flinch.",
			},
			{
				speaker = "Elspeth",
				text = "What a burn takes stays taken till you see me. Free, mind. Always free.",
			},
		},
	},
	{
		id = "first_ember_tamer",
		name = "A local tamer",
		minuteFrom = 527,
		minuteTo = 540,
		trigger = { kind = "Win", target = "ef_tilda", requires = { "ember_burn" } },
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Tilda",
				text = "My Ashflit flew rings round you! Wings are new round here. Breed two and keep the wings.",
			},
		},
	},
	{
		id = "ember_catch",
		name = "A catch from the ash",
		minuteFrom = 536,
		minuteTo = 550,
		trigger = { kind = "Tame", requires = { "first_ember_tamer" } },
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Sorrel",
				text = "That's warm. Like holding a pie. Five on your team now. I'm counting them, for safety.",
			},
		},
	},
	{
		id = "the_glassworks",
		name = "The Glassworks",
		minuteFrom = 548,
		minuteTo = 562,
		trigger = { kind = "Talk", target = "osric_glaze", requires = { "ember_catch" } },
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Osric",
				text = "Cracked glass? Don't hide the crack. Fill it with gold, so the mend shows. Stronger there.",
			},
			{
				speaker = "Sorrel",
				text = "So the mend shows... Can you teach me? I'm good with my hands. Mostly.",
			},
			{
				speaker = "Osric",
				text = "You've the hands for it. Come back after supper. Bring that frown. It helps.",
			},
		},
	},
	{
		id = "mentors_letter_ember",
		name = "A singed letter",
		minuteFrom = 565,
		minuteTo = 580,
		trigger = { kind = "Talk", target = "pell_ashby", requires = { "the_glassworks" } },
		unlocks = {},
		grants = letter,
		lines = {
			{
				speaker = "Pell",
				text = "Letter from Thistledown. Stamp's singed. Everything here gets singed.",
			},
			{
				speaker = "Mentor",
				text = "You have done enough. Come home. The giants will settle by themselves. Truly.",
			},
			{
				speaker = "Mentor",
				text = "And bring Sorrel. I... cannot lose anyone else. Please.",
			},
		},
	},
	{
		id = "cinderhart_bound",
		name = "The stag on a leash",
		minuteFrom = 590,
		minuteTo = 605,
		trigger = { kind = "Sight", target = "ash_rim", requires = { "mentors_letter_ember" } },
		lookAt = "emberfall_lair",
		unlocks = { "ember_giant_marker" },
		grants = {},
		lines = {
			{
				speaker = "Jem",
				text = "Cinderhart's walking the rim, and the beacon's guttering! Look at its antlers!",
			},
			{
				speaker = "You",
				text = "Black stitches, all down its neck and antlers. Someone has sewn it to a leash.",
			},
			{
				speaker = "Sorrel",
				text = "I know those stitches. They've been on his creatures since the gorge.",
			},
		},
	},
	{
		id = "ember_gate_challenge",
		name = "The Rim Gate",
		minuteFrom = 650,
		minuteTo = 665,
		trigger = { kind = "Enter", target = "emberfall_gate", requires = { "cinderhart_bound" } },
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Rival",
				text = "Look what kneels for me now. The biggest thing on the mountain.",
			},
			{ speaker = "Sorrel", text = "It's crying ash. Let it go." },
			{
				speaker = "Rival",
				text = "Can't. Won't. Five each. Make me.",
			},
		},
	},
	{
		id = "ember_badge",
		name = "The seventh badge",
		minuteFrom = 655,
		minuteTo = 670,
		trigger = {
			kind = "Win",
			target = "rival_cinder",
			requires = { "ember_gate_challenge" },
		},
		unlocks = { "badge_7", "level_cap_85" },
		grants = badge,
		lines = {
			{
				speaker = "You",
				text = "The stitches on Cinderhart snap. It bolts for its lair, shaking its antlers free.",
			},
			{
				speaker = "Rival",
				text = "It doesn't hurt to lose anymore. That's the part that scares me.",
			},
			{
				speaker = "Rival",
				text = "Don't follow me up the mountain. Please.",
			},
		},
	},
	{
		id = "ember_road_on",
		name = "The road on",
		minuteFrom = 665,
		minuteTo = 690,
		trigger = {
			kind = "Enter",
			target = "emberfall_sealed_path",
			requires = { "ember_badge" },
		},
		unlocks = { "biome_8", "chapter_8_teaser" },
		grants = {},
		lines = {
			{
				speaker = "Sign",
				text = "The Updraught Lift to Stormreach. Badge holders only. Keep arms inside the basket.",
			},
			{
				speaker = "Jem",
				text = "The beacon's burning bright again. Cinderwick won't forget you. Mind the clouds.",
			},
			{
				speaker = "Sorrel",
				text = "I learned the gold mend. First try I glued my thumb to a vase. Second try, it held.",
			},
		},
	},
}

local Chapter7: WorldTypes.Chapter = {
	id = "chapter_7",
	number = 7,
	name = "Emberfall",
	beats = beats,
}

return Chapter7
