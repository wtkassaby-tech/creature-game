--!strict
-- DRAFT, not wired into the game (docs/content/story/). Copy to src/content/story_data/ and add to
-- src/content/Story.luau only after Ayrton approves it, his style references for biome 9 are in, and
-- the biome's map, the Old Lane, Mirror Mere and Starfall Crater exist (plan 13).
--
-- Chapter 9 of 11: the Arcane biome (name [Open]; town placeholder Lanternmoor). Beats in order, with
-- timing targets that pick up where chapter 8 ends (minute 910; all [Defaults] to tune in playtests).
-- Finishing a beat sets a flag equal to its id. The first beat needs "storm_road_on".
--
-- The arc (docs/content/story/ARC.md, chapter 9): the truth about the mentor (brief section 8;
-- [Locked] arc item 4: he is found out to be the one who accidentally caused the tear).
--  - The purple light players have seen blinking since minute one is a lamp lit for the Ringwalker
--    the night she went into the Starwell. It blinks the old walkers' code for "come home".
--  - The Old Lane opens (plan 13, shortcut S2). At her Mirror Mere cottage the rival has found her
--    last page. It names the mentor's mistake and forgives him: he is found out, not self-confessed.
--  - The lane leads home. The mentor waits at the old fence and tells all of it at the cottage, with
--    the kettle on: "No 'truly' this time." He tore the sky breeding with a fallen star.
--  - Starfall Crater opens (DECISIONS, 23 November). The Frayling hides in the scorched camp. Sorrel
--    mends it with the gold seams she learned in chapter 7; the mentor asks the player to take it.
--  - The rival breaks the Starwell seal to fetch his gran. The mentor holds the gate himself, to stop
--    the player following her too, and loses: "Perfect lost to patched."
-- Hex (the biome's new idea) is taught by the healer, with the proposal that Arcane tails bring two
-- moves. The giant is optional. Dialogue: at most three lines of 90 characters a beat. Place, people
-- and battle ids are placeholders for data not yet written.

local EconomyConfig = require("../../config/EconomyConfig")
local WorldTypes = require("../../shared/WorldTypes")

local BIOME = 9
local TOKEN_LEVEL = 92 -- the clear token: three under the cap of 95

local frayling: { WorldTypes.Reward } = {
	-- A mythic: a species flag, not a rarity (roster plan section 5). One per player, bound to the
	-- account, never wild and never sold. "Common" stands in until the mythic flag exists.
	{ kind = "Creature", species = "Frayling", level = 90, rarity = "Common", colour = "Sand" },
}

local badge: { WorldTypes.Reward } = {
	{ kind = "Badge", id = "arcane_badge", name = "Lantern Badge" },
	{
		kind = "Coins",
		amount = math.floor(
			EconomyConfig.TRAINED.Gate.firstClear * EconomyConfig.ONE_TIME_MULT[BIOME]
		),
	},
	{ kind = "PrismCandy", amount = EconomyConfig.CANDY.GateFirstClear.perClaim },
	{
		kind = "Creature",
		species = "Sparkowl", -- Storm beats Cosmic, the next biome (roster plan)
		level = TOKEN_LEVEL,
		rarity = "Common",
		colour = "Bark",
	},
}

local beats: { WorldTypes.Beat } = {
	{
		id = "arcane_arrival",
		name = "Lanternmoor",
		minuteFrom = 910,
		minuteTo = 916,
		trigger = { kind = "Enter", target = "arcane_hub", requires = { "storm_road_on" } },
		unlocks = { "arcane_hub" },
		grants = {},
		lines = {
			{
				speaker = "Sign",
				text = "Lanternmoor. Lamps lit at dusk. Toadstools are not chairs.",
			},
			{
				speaker = "Dorcas",
				text = "Down the whole Cloud Stair? Sit, sit. Have a toadstool. No, not on it.",
			},
		},
	},
	{
		id = "arcane_hex",
		name = "The Hedge House",
		minuteFrom = 914,
		minuteTo = 921,
		trigger = { kind = "Talk", target = "selwyn_hask", requires = { "arcane_arrival" } },
		unlocks = { "hex", "arcane_quest_line", "arcane_routes" },
		grants = {},
		lines = {
			{
				speaker = "Selwyn",
				text = "Arcane creatures Hex. A Hexed creature can't use its last move again for two turns.",
			},
			{
				speaker = "Selwyn",
				text = "Arcane ones shrug it off. The trick is simple: never lean on one move. Mix it up.",
			},
			{
				speaker = "Selwyn",
				text = "And our tails carry two moves, not one. Breed one onto a friend and see.",
			},
		},
	},
	{
		id = "first_arcane_tamer",
		name = "A local tamer",
		minuteFrom = 918,
		minuteTo = 934,
		trigger = { kind = "Win", target = "ar_bryn", requires = { "arcane_hex" } },
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Bryn",
				text = "My Capgnome locked your best move! You should have brought a second best.",
			},
		},
	},
	{
		id = "arcane_catch",
		name = "A catch in the twilight",
		minuteFrom = 930,
		minuteTo = 946,
		trigger = { kind = "Tame", requires = { "first_arcane_tamer" } },
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Sorrel",
				text = "It's older than it looks. Everything is, here. Even the moss has a beard.",
			},
		},
	},
	{
		id = "the_spire_lamp",
		name = "The lamp that blinks",
		minuteFrom = 950,
		minuteTo = 965,
		trigger = { kind = "Talk", target = "cressida_lamb", requires = { "arcane_catch" } },
		lookAt = "lantern_spire",
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Cressida",
				text = "That light? Three long, one short. The old walkers' code for 'come home'.",
			},
			{
				speaker = "Cressida",
				text = "We lit it for the Ringwalker eight years ago. She went into the Starwell. Never came back.",
			},
			{ speaker = "Sorrel", text = "...Gran." },
		},
	},
	{
		id = "old_lane",
		name = "The Old Lane",
		minuteFrom = 951,
		minuteTo = 966,
		trigger = { kind = "Follow", requires = { "the_spire_lamp" } },
		unlocks = { "old_lane" },
		grants = {},
		lines = {
			{
				speaker = "Cressida",
				text = "Her cottage is by Mirror Mere, up the Old Lane. Nobody's touched it since.",
			},
			{
				speaker = "Sorrel",
				text = "Then we will. Come on. Before I lose my nerve.",
			},
		},
	},
	{
		id = "mirror_mere",
		name = "The cottage by the mere",
		minuteFrom = 975,
		minuteTo = 990,
		trigger = { kind = "Enter", target = "mirror_mere", requires = { "old_lane" } },
		hint = "Follow the Old Lane to the cottage at Mirror Mere",
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Rival",
				text = "Took you long enough. This was hers. Her last page was on the table.",
			},
			{ speaker = "Sorrel", text = "Read it. Out loud. Please." },
		},
	},
	{
		id = "last_page",
		name = "The last page",
		minuteFrom = 976,
		minuteTo = 991,
		trigger = { kind = "Follow", requires = { "mirror_mere" } },
		unlocks = { "journal_last_page" },
		grants = {},
		lines = {
			{
				speaker = "Ringwalker",
				text = "I can see our roofs from here. I won't go down. Not till the sky is mended.",
			},
			{
				speaker = "Ringwalker",
				text = "He tore it, breeding with a star. It was his mistake. That is not the same as his fault.",
			},
			{
				speaker = "Ringwalker",
				text = "Tell him I forgave him long ago. Tell my two I walked the whole ring.",
			},
		},
	},
	{
		id = "old_fence",
		name = "Home, the long way",
		minuteFrom = 995,
		minuteTo = 1010,
		trigger = { kind = "Enter", target = "greenwood_old_fence", requires = { "last_page" } },
		hint = "Follow the Old Lane down to Greenwood's old fence",
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Rival",
				text = "You knew. Eight years, and you knew exactly where she went.",
			},
			{
				speaker = "Mentor",
				text = "I knew. ...Come to the cottage. The kettle is on. I will tell you all of it.",
			},
			{ speaker = "Mentor", text = "No 'truly' this time. Just true." },
		},
	},
	{
		id = "the_truth",
		name = "The truth",
		minuteFrom = 1010,
		minuteTo = 1020,
		trigger = { kind = "Talk", target = "mentor", requires = { "old_fence" } },
		hint = "Talk to the mentor at his cottage",
		unlocks = { "starfall_bridge" },
		grants = {},
		lines = {
			{
				speaker = "Mentor",
				text = "I wanted a perfect bloodline, so I bred with a fallen star. I never meant to tear the sky.",
			},
			{
				speaker = "Mentor",
				text = "Your gran went to mend it. I lied so none of you would follow her. Or hate me.",
			},
			{
				speaker = "Mentor",
				text = "Something hatched from that egg. I hid it at Starfall Crater. It is time you met.",
			},
		},
	},
	{
		id = "starfall_crater",
		name = "Starfall Crater",
		minuteFrom = 1025,
		minuteTo = 1040,
		trigger = { kind = "Enter", target = "starfall_crater", requires = { "the_truth" } },
		hint = "Cross Dust Canyon's mended bridge to Starfall Crater",
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "You",
				text = "Violet glass sand. A burnt-out old camp. And something small, hiding behind a rock.",
			},
			{
				speaker = "Mentor",
				text = "It is all right. They are friends. ...It is frightened of the open sky. Always has been.",
			},
			{
				speaker = "You",
				text = "Two of its patches are missing. Stars show through. A star-chip sits in its brow.",
			},
		},
	},
	{
		id = "the_mend",
		name = "Gold seams",
		minuteFrom = 1035,
		minuteTo = 1050,
		trigger = { kind = "Talk", target = "sorrel", requires = { "starfall_crater" } },
		hint = "Talk to Sorrel at Starfall Crater",
		unlocks = {},
		grants = frayling,
		lines = {
			{
				speaker = "Sorrel",
				text = "Gold seams, like Osric taught me. Hold still... There. The mend shows. That's the point.",
			},
			{
				speaker = "Mentor",
				text = "It has never seen the world. Take it with you. Show it everything I was afraid of.",
			},
			{
				speaker = "You",
				text = "The Frayling looks at its new gold seams, then climbs onto your shoulder.",
			},
		},
	},
	{
		id = "rival_gone",
		name = "The broken seal",
		minuteFrom = 1036,
		minuteTo = 1051,
		trigger = { kind = "Follow", requires = { "the_mend" } },
		unlocks = {},
		grants = {},
		lines = {
			{ speaker = "Sorrel", text = "Where's my brother? He was right behind us." },
			{
				speaker = "Mentor",
				text = "The Starwell. I sealed it when she did not come back. He means to break it.",
			},
			{
				speaker = "Mentor",
				text = "Go back to Lanternmoor. I will meet you at the seal. I have one more lesson to give.",
			},
		},
	},
	{
		id = "bridge_sighting",
		name = "The bridge that grumbles",
		minuteFrom = 1060,
		minuteTo = 1075,
		trigger = { kind = "Sight", target = "toadstool_dell", requires = { "rival_gone" } },
		lookAt = "arcane_lair",
		unlocks = { "arcane_giant_marker" },
		grants = {},
		lines = {
			{
				speaker = "Dorcas",
				text = "Bridgegrum's up and grumbling. It carried your gran over the Dell once. Him too.",
			},
			{
				speaker = "Dorcas",
				text = "Never forgave your mentor for the muddy boots. Sixty years, and it still sulks.",
			},
			{
				speaker = "Dorcas",
				text = "A rune lights before it Hexes. Watch the lantern on its back. That's the clock.",
			},
		},
	},
	{
		id = "arcane_gate_challenge",
		name = "The Starwell seal",
		minuteFrom = 1150,
		minuteTo = 1165,
		trigger = { kind = "Enter", target = "arcane_gate", requires = { "bridge_sighting" } },
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Mentor",
				text = "He broke the seal. He is down there now, with her. Or with whatever is left of her.",
			},
			{
				speaker = "Mentor",
				text = "I lost her to this tunnel. I will not lose you too. If you want past, beat me.",
			},
			{
				speaker = "Mentor",
				text = "Every creature on my team, I bred to be perfect. Show me what friends can do.",
			},
		},
	},
	{
		id = "arcane_badge",
		name = "The ninth badge",
		minuteFrom = 1160,
		minuteTo = 1175,
		trigger = {
			kind = "Win",
			target = "mentor_starwell",
			requires = { "arcane_gate_challenge" },
		},
		unlocks = { "badge_9", "level_cap_100" },
		grants = badge,
		lines = {
			{
				speaker = "Mentor",
				text = "Perfect lost to patched. I should have learned that a long time ago.",
			},
			{
				speaker = "Mentor",
				text = "The Lantern Badge, and a Sparkowl. Its sparks sting cosmic things.",
			},
			{
				speaker = "Mentor",
				text = "Bring them home. All of them.",
			},
		},
	},
	{
		id = "arcane_road_on",
		name = "The road on",
		minuteFrom = 1170,
		minuteTo = 1190,
		trigger = {
			kind = "Enter",
			target = "arcane_sealed_path",
			requires = { "arcane_badge" },
		},
		unlocks = { "biome_10", "chapter_10_teaser" },
		grants = {},
		lines = {
			{
				speaker = "Sign",
				text = "The Starwell Tunnel. Sealed by order of Thistledown. (The seal is in pieces.)",
			},
			{
				speaker = "Sorrel",
				text = "Last time someone went through here, they lit a lamp for her. Let's not need another.",
			},
		},
	},
}

local Chapter9: WorldTypes.Chapter = {
	id = "chapter_9",
	number = 9,
	name = "Arcane",
	beats = beats,
}

return Chapter9
