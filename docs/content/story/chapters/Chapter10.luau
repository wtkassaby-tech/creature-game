--!strict
-- DRAFT, not wired into the game (docs/content/story/). Copy to src/content/story_data/ and add to
-- src/content/Story.luau only after Ayrton approves it and the biome's map, tamers and giant exist.
--
-- Chapter 10 of 11: the Abyss. Beats in order, with timing targets that pick up where chapter 9
-- ends (minute 1190; all [Defaults] to tune in playtests). Finishing a beat sets a flag equal to its
-- id. The first beat needs "arcane_road_on", the last beat of chapter 9.
--
-- The arc (docs/content/story/ARC.md, chapter 10): the last rival battle ([Locked], brief section 8)
-- and his gift ([Locked] arc items 5 and 6).
--  - The rival could not cross the broken Last Bridge; something in the Rift kept saying his name.
--  - The Unraveller whispers to the player for the first time, at the Rift's edge: put down
--    everything you were handed. The Frayling presses closer.
--  - The rival holds the gate, honestly this time (tint about 0.5, no stitched giants; tamer data):
--    "I need to know you can beat me." Beaten, he warns the player what is ahead (unravelled creatures
--    lose a part and its moves; Crystal stitches; "don't listen when it's kind") and gives them his
--    first creature, the one from his gran's egg, with supplies.
--  - The Frayling mends the Last Bridge with gold thread from its seams. Old Hearth's carved stone
--    says "keep the fire fed", which is what Gran always said.
-- Drift (the biome's new idea) is taught by the healer; Diamond (brief section 4) on the first catch.
-- The quest giver's Halcyre sleepwalks toward the Hollow (scaffold F). The giant is optional.
-- Dialogue: at most three lines of 90 characters a beat. Place, people and battle ids are
-- placeholders for data not yet written.

local EconomyConfig = require("../../config/EconomyConfig")
local WorldTypes = require("../../shared/WorldTypes")

local BIOME = 10
local TOKEN_LEVEL = 97 -- the clear token: three under the cap of 100 (MAX_LEVEL)
local GIFT_LEVEL = 97

local badge: { WorldTypes.Reward } = {
	{ kind = "Badge", id = "abyss_badge", name = "Comet Badge" },
	{
		kind = "Coins",
		amount = math.floor(
			EconomyConfig.TRAINED.Gate.firstClear * EconomyConfig.ONE_TIME_MULT[BIOME]
		),
	},
	{ kind = "PrismCandy", amount = EconomyConfig.CANDY.GateFirstClear.perClaim },
	{
		kind = "Creature",
		species = "Spyglint", -- the roster plan's token
		level = TOKEN_LEVEL,
		rarity = "Common",
		colour = "Sand",
	},
}

-- The rival's gift ([Locked]: a powerful creature and supplies). The creature is his first: the
-- starter that LOSES to the player's (Leaf beats Water, Water beats Sand, Sand beats Leaf), so it
-- depends on the player's pick. NEEDS a per-starter reward in WorldTypes (a ByStarter species, as
-- the rival's teams already are). Written here for a player who picked Mossmitt.
local gift: { WorldTypes.Reward } = {
	{
		kind = "Creature",
		species = "Sloshcalf",
		level = GIFT_LEVEL,
		rarity = "Common",
		colour = "Moss",
	},
	{ kind = "Item", item = "Revive", count = 3 },
	{ kind = "Item", item = "GreatTonic", count = 5 },
	{ kind = "Item", item = "Gilded", count = 2 },
}

local beats: { WorldTypes.Beat } = {
	{
		id = "abyss_arrival",
		name = "Starfold",
		minuteFrom = 1190,
		minuteTo = 1197,
		trigger = { kind = "Enter", target = "abyss_hub", requires = { "arcane_road_on" } },
		unlocks = { "abyss_hub" },
		grants = {},
		lines = {
			{
				speaker = "Sign",
				text = "Starfold. The only town where it's always night. Breakfast is served anyway.",
			},
			{
				speaker = "Nyssa",
				text = "Walked right through the Crown? Look up. Every star you see is on a chart in my shop.",
			},
		},
	},
	{
		id = "abyss_drift",
		name = "The Night Infirmary",
		minuteFrom = 1195,
		minuteTo = 1203,
		trigger = { kind = "Talk", target = "ione_fairweather", requires = { "abyss_arrival" } },
		unlocks = { "drift", "abyss_quest_line", "abyss_routes" },
		grants = {},
		lines = {
			{
				speaker = "Ione",
				text = "Cosmic creatures Drift you. A Drifting creature can't switch out for two turns.",
			},
			{
				speaker = "Ione",
				text = "Cosmic ones float free of it. Pick your lead like you mean it.",
			},
			{
				speaker = "Ione",
				text = "I mend Drift and everything else, free. Even out here. Especially out here.",
			},
		},
	},
	{
		id = "first_abyss_tamer",
		name = "A local tamer",
		minuteFrom = 1200,
		minuteTo = 1220,
		trigger = { kind = "Win", target = "ab_halloran", requires = { "abyss_drift" } },
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Halloran",
				text = "Drifted, eh? Nowhere to run. That's the Abyss. Pick right the first time.",
			},
		},
	},
	{
		id = "abyss_catch",
		name = "A catch under the stars",
		minuteFrom = 1215,
		minuteTo = 1235,
		trigger = { kind = "Tame", requires = { "first_abyss_tamer" } },
		unlocks = { "diamond_hunting" },
		grants = {},
		lines = {
			{
				speaker = "Sorrel",
				text = "If one ever sparkles white, that's a Diamond. Rarest there is. Gran had one, once.",
			},
		},
	},
	{
		id = "sleepwalker",
		name = "The sleepwalker",
		minuteFrom = 1240,
		minuteTo = 1255,
		trigger = { kind = "Talk", target = "nyssa_dawe", requires = { "abyss_catch" } },
		unlocks = { "halcyre_quest" },
		grants = {},
		lines = {
			{
				speaker = "Nyssa",
				text = "My Halcyre sleepwalks east every night, toward the Rift. It dreams of something there.",
			},
			{
				speaker = "Nyssa",
				text = "Follow it some night, if you like. It knows the way better than any chart of mine.",
			},
		},
	},
	{
		id = "rival_at_bridge",
		name = "The Last Bridge",
		minuteFrom = 1270,
		minuteTo = 1290,
		trigger = { kind = "Sight", target = "last_bridge", requires = { "sleepwalker" } },
		lookAt = "the_tear",
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "You",
				text = "The Last Bridge, broken in the middle. The tear hangs right above it, humming.",
			},
			{
				speaker = "Rival",
				text = "Couldn't cross. Tried twice. Something in the Rift kept saying my name. Nicely.",
			},
			{ speaker = "Sorrel", text = "You came back, though. That's new." },
		},
	},
	{
		id = "starfathom_sighting",
		name = "The well that rises",
		minuteFrom = 1330,
		minuteTo = 1350,
		trigger = { kind = "Sight", target = "starwell_ring", requires = { "rival_at_bridge" } },
		lookAt = "abyss_lair",
		unlocks = { "abyss_giant_marker" },
		grants = {},
		lines = {
			{
				speaker = "Nyssa",
				text = "The Starwell's churning. Starfathom's rising. Gentlest thing in the sky, till lately.",
			},
			{
				speaker = "Nyssa",
				text = "Its crest brightens before it charges. Hit it then with Crystal or Storm.",
			},
		},
	},
	{
		id = "the_whisper",
		name = "A kind voice",
		minuteFrom = 1420,
		minuteTo = 1440,
		trigger = { kind = "Sight", target = "rift_edge", requires = { "starfathom_sighting" } },
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Unraveller",
				text = "You carry so much. Other people's eggs. Other people's mistakes. Put them down.",
			},
			{
				speaker = "Unraveller",
				text = "Hold nothing, and nothing can be taken from you. That is all I have ever offered.",
			},
			{
				speaker = "You",
				text = "The Frayling presses closer. Its gold seams are warm.",
			},
		},
	},
	{
		id = "abyss_gate_challenge",
		name = "The last bout",
		minuteFrom = 1500,
		minuteTo = 1515,
		trigger = { kind = "Enter", target = "abyss_gate", requires = { "the_whisper" } },
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Rival",
				text = "Last time, I promise. Not for a badge. I need to know you can beat me. Properly.",
			},
			{
				speaker = "Rival",
				text = "Because what's past this bridge is worse than me. A lot worse.",
			},
			{ speaker = "Rival", text = "Five each. No stitches, no tricks. Just me." },
		},
	},
	{
		id = "abyss_badge",
		name = "The tenth badge",
		minuteFrom = 1505,
		minuteTo = 1520,
		trigger = {
			kind = "Win",
			target = "rival_last_bridge",
			requires = { "abyss_gate_challenge" },
		},
		unlocks = { "badge_10", "team_of_six" },
		grants = badge,
		lines = {
			{
				speaker = "Rival",
				text = "Good. Now listen. It unpicks your team, part by part, and a lost part loses its moves.",
			},
			{
				speaker = "Rival",
				text = "Crystal stitches things back. Bring Crystal. And don't listen when it's kind.",
			},
			{ speaker = "Rival", text = "It's never kind. Not once." },
		},
	},
	{
		id = "the_gift",
		name = "His first",
		minuteFrom = 1506,
		minuteTo = 1521,
		trigger = { kind = "Follow", requires = { "abyss_badge" } },
		unlocks = {},
		grants = gift,
		lines = {
			{
				speaker = "Rival",
				text = "Here. My first. Gran's egg. It never quit on me, even when I quit on it.",
			},
			{
				speaker = "Rival",
				text = "It was always going to be someone's. Better yours. Take the tonics too, you'll need them.",
			},
			{ speaker = "Sorrel", text = "...You never even let me hold it." },
		},
	},
	{
		id = "bridge_mended",
		name = "Mended things",
		minuteFrom = 1520,
		minuteTo = 1535,
		trigger = { kind = "Talk", target = "sorrel", requires = { "the_gift" } },
		hint = "Talk to Sorrel at the Last Bridge",
		unlocks = { "last_bridge" },
		grants = {},
		lines = {
			{
				speaker = "You",
				text = "The Frayling hops onto the broken stones and hums. Gold thread spills from its seams.",
			},
			{
				speaker = "Sorrel",
				text = "It's mending the bridge. Mended things mend things. I'm writing that down.",
			},
			{
				speaker = "Rival",
				text = "...She's over there. I can feel it. Let's go and get her.",
			},
		},
	},
	{
		id = "abyss_road_on",
		name = "Across the Rift",
		minuteFrom = 1530,
		minuteTo = 1550,
		trigger = {
			kind = "Enter",
			target = "abyss_sealed_path",
			requires = { "bridge_mended" },
		},
		unlocks = { "biome_11", "chapter_11_teaser" },
		grants = {},
		lines = {
			{
				speaker = "Sign",
				text = "Carved in the stone: 'Old Hearth. Travellers welcome. Keep the fire fed.'",
			},
			{
				speaker = "Sorrel",
				text = "Keep the fire fed. Gran said that every single night. Every single night.",
			},
		},
	},
}

local Chapter10: WorldTypes.Chapter = {
	id = "chapter_10",
	number = 10,
	name = "Abyss",
	beats = beats,
}

return Chapter10
