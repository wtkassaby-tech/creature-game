--!strict
-- DRAFT, not wired into the game (docs/content/story/). Copy to src/content/story_data/ and add to
-- src/content/Story.luau only after Ayrton approves it and the biome's map, tamers and giant exist.
--
-- Chapter 6 of 11: Crystal Deep. Beats in order, with timing targets that pick up where chapter 5
-- ends (minute 390; all [Defaults] to tune in playtests). Finishing a beat sets a flag equal to its
-- id. The first beat needs "frost_road_on", the last beat of chapter 5.
--
-- The arc (docs/content/story/ARC.md, chapter 6):
--  - Place and history carry the story: the Heartstone holds an old picture of the first creature,
--    stitched from coloured glass, and of a one-eyed thing unpicking the sky. The legend and the
--    villain get a picture and a name, and Sorrel remembers her brother's eyes flashing red.
--  - The first unravelled creature: a wild Glowthread coming apart at the seams.
--  - The mentor's letter carries two lies ("fairy tales", "Gran is fine"), each with "Truly", and
--    Sorrel counts them. That is the push to go and look.
--  - The rival is not met; the champion says he tried to take her Ruby and a voice told him he
--    deserved it. The gate is held by a local champion, as the brief's varied gates ask.
-- Ruby (the biome's new idea, brief section 4) is taught by the gemcutter at the second beat; the
-- Serpent body plan by the first tamer. The fifth team slot opens with this badge (5v5 from
-- Emberfall). The giant is optional. Dialogue: at most three lines of 90 characters a beat.
-- Place, people and battle ids are placeholders for data not yet written.

local EconomyConfig = require("../../config/EconomyConfig")
local WorldTypes = require("../../shared/WorldTypes")

local BIOME = 6
local TOKEN_LEVEL = 62 -- the clear token: three under the cap of 65

local parcel: { WorldTypes.Reward } = {
	{ kind = "Item", item = "Revive", count = 2 },
}

local badge: { WorldTypes.Reward } = {
	{ kind = "Badge", id = "crystal_deep_badge", name = "Geode Badge" },
	{
		kind = "Coins",
		amount = math.floor(
			EconomyConfig.TRAINED.Gate.firstClear * EconomyConfig.ONE_TIME_MULT[BIOME]
		),
	},
	{ kind = "PrismCandy", amount = EconomyConfig.CANDY.GateFirstClear.perClaim },
	{
		kind = "Creature",
		species = "Grotteel", -- carries a Water move on its head: Water beats Fire, the next biome
		level = TOKEN_LEVEL,
		rarity = "Common",
		colour = "Sand",
	},
}

local beats: { WorldTypes.Beat } = {
	{
		id = "deep_arrival",
		name = "Glimmerholt",
		minuteFrom = 390,
		minuteTo = 395,
		trigger = { kind = "Enter", target = "crystal_deep_hub", requires = { "frost_road_on" } },
		unlocks = { "deep_hub" },
		grants = {},
		lines = {
			{
				speaker = "Sign",
				text = "Glimmerholt. Lamps by the lift. Please do not lick the walls. We mean it.",
			},
			{
				speaker = "Corwin",
				text = "Topside folk! Mind your heads. The ceilings are lower than my prices. Just.",
			},
		},
	},
	{
		id = "deep_ruby",
		name = "Bale's Gemworks",
		minuteFrom = 393,
		minuteTo = 399,
		trigger = { kind = "Talk", target = "corwin_bale", requires = { "deep_arrival" } },
		unlocks = { "ruby_hunting", "deep_quest_line", "deep_routes" },
		grants = {},
		lines = {
			{
				speaker = "Corwin",
				text = "Amber's pretty. Ruby's rarer: a red glint, found down here and deeper on.",
			},
			{
				speaker = "Corwin",
				text = "The nearer the Crown, the more the sky's leak gets into things. Red as jam.",
			},
			{
				speaker = "Corwin",
				text = "A Ruby hits harder than an Amber, and it gets a number. Find one, I'll buy you lunch.",
			},
		},
	},
	{
		id = "first_deep_tamer",
		name = "A local tamer",
		minuteFrom = 396,
		minuteTo = 408,
		trigger = { kind = "Win", target = "cd_hob", requires = { "deep_ruby" } },
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Hob",
				text = "Never fought a Serpent before? Long body, long reach. Breed two and see what you get.",
			},
		},
	},
	{
		id = "deep_catch",
		name = "A catch in the dark",
		minuteFrom = 404,
		minuteTo = 416,
		trigger = { kind = "Tame", requires = { "first_deep_tamer" } },
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Sorrel",
				text = "It glows on its own! If one ever glints red, that's a Ruby. Don't tell Corwin. He'll cry.",
			},
		},
	},
	{
		id = "mentors_parcel",
		name = "A parcel down the lift",
		minuteFrom = 414,
		minuteTo = 424,
		trigger = { kind = "Talk", target = "ada_hollins", requires = { "deep_catch" } },
		unlocks = {},
		grants = parcel,
		lines = {
			{
				speaker = "Ada",
				text = "Parcel came down the lift for you. From Thistledown. Smells of tea.",
			},
			{
				speaker = "Mentor",
				text = "The old pictures in the Heartstone are fairy tales. Do not go looking. Truly.",
			},
			{
				speaker = "Mentor",
				text = "Two revives enclosed. Is Sorrel with you? Tell her Gran is fine. Truly.",
			},
		},
	},
	{
		id = "two_trulys",
		name = "Two trulys",
		minuteFrom = 415,
		minuteTo = 425,
		trigger = { kind = "Follow", requires = { "mentors_parcel" } },
		unlocks = { "heartstone" },
		grants = {},
		lines = {
			{ speaker = "Sorrel", text = "Two trulys in one letter. That's a record." },
			{
				speaker = "Sorrel",
				text = "Right. We're going to look at the fairy tales. Which way's the Heartstone?",
			},
		},
	},
	{
		id = "unravelled_sighting",
		name = "Coming loose",
		minuteFrom = 425,
		minuteTo = 440,
		trigger = { kind = "Sight", target = "glowthread_grotto", requires = { "two_trulys" } },
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "You",
				text = "That Glowthread's threads are coming loose, one by one, as if something is pulling.",
			},
			{
				speaker = "Sorrel",
				text = "I can mend a crack. I can't mend that. Not yet.",
			},
		},
	},
	{
		id = "the_heartstone",
		name = "The picture in the stone",
		minuteFrom = 440,
		minuteTo = 455,
		trigger = {
			kind = "Enter",
			target = "heartstone_cavern",
			requires = { "unravelled_sighting" },
		},
		lookAt = "heartstone",
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Morwen",
				text = "The first creature, stitched from coloured glass. Every creature since wears its patches.",
			},
			{
				speaker = "Morwen",
				text = "And that one-eyed thing, unpicking the sky. The old songs call it the Unraveller.",
			},
			{
				speaker = "Sorrel",
				text = "One red eye. ...My brother's eyes did that, at the Frozen Fall. Just for a blink.",
			},
		},
	},
	{
		id = "druse_sighting",
		name = "The rolling hill",
		minuteFrom = 455,
		minuteTo = 465,
		trigger = { kind = "Sight", target = "geode_gallery", requires = { "the_heartstone" } },
		lookAt = "crystal_deep_lair",
		unlocks = { "deep_giant_marker" },
		grants = {},
		lines = {
			{
				speaker = "Pim",
				text = "Druseback's rolling the tunnels again. Rolled clean off the Heartstone, it did.",
			},
			{
				speaker = "Pim",
				text = "Rolled up, nothing dents it. Hit it with Leaf or Frost just as it unrolls.",
			},
		},
	},
	{
		id = "deep_gate_challenge",
		name = "The Geode Gate",
		minuteFrom = 490,
		minuteTo = 505,
		trigger = { kind = "Enter", target = "crystal_deep_gate", requires = { "druse_sighting" } },
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Maren",
				text = "Maren Quarrie, keeper of the Geode Gate. Four of yours, four of mine. Shine or crack.",
			},
			{
				speaker = "Maren",
				text = "Your friend in the torn jacket wanted my Ruby Prismquill. She bit him. Good girl.",
			},
			{
				speaker = "Maren",
				text = "He said a voice told him he deserved it. He sounded like he believed it.",
			},
		},
	},
	{
		id = "deep_badge",
		name = "The sixth badge",
		minuteFrom = 495,
		minuteTo = 510,
		trigger = {
			kind = "Win",
			target = "champion_quarrie",
			requires = { "deep_gate_challenge" },
		},
		unlocks = { "badge_6", "level_cap_75", "team_of_five" },
		grants = badge,
		lines = {
			{
				speaker = "Maren",
				text = "The Geode Badge. From here on it's five a side. Pick your fifth with care.",
			},
			{
				speaker = "Maren",
				text = "A Grotteel from our cave lake, for the heat ahead. It spits water. Fire hates that.",
			},
		},
	},
	{
		id = "deep_road_on",
		name = "The road on",
		minuteFrom = 505,
		minuteTo = 520,
		trigger = {
			kind = "Enter",
			target = "crystal_deep_sealed_path",
			requires = { "deep_badge" },
		},
		unlocks = { "biome_7", "chapter_7_teaser" },
		grants = {},
		lines = {
			{
				speaker = "Sign",
				text = "The Emberfall road, up the Lava Tube. Shut to all but badge holders.",
			},
			{
				speaker = "Sorrel",
				text = "Getting warm. Gran always said Cinderwick makes the best glass in the world.",
			},
		},
	},
}

local Chapter6: WorldTypes.Chapter = {
	id = "chapter_6",
	number = 6,
	name = "Crystal Deep",
	beats = beats,
}

return Chapter6
