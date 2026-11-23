--!strict
-- DRAFT, not wired into the game (docs/content/story/). Copy to src/content/story_data/ and add to
-- src/content/Story.luau only after Ayrton approves it and the biome's map, the finale battle, the
-- Firstling and the cosmic wrap exist.
--
-- Chapter 11 of 11: the Hollow (camp placeholder Old Hearth). Beats in order, with timing targets that
-- pick up where chapter 10 ends (minute 1550; all [Defaults] to tune in playtests). Finishing a beat
-- sets a flag equal to its id. The first beat needs "abyss_road_on", the last beat of chapter 10.
--
-- The arc (docs/content/story/ARC.md, chapter 11): the entity and the ending.
--  - The Ringwalker is alive. For eight years her fire has kept the Unraveller's threads off the
--    sleeping Firstling (thread burns). Sorrel's need is met at the first beat.
--  - The finale teaches its own rule once, on a patrol of unravelled creatures: a lost part loses its
--    moves, and a Crystal hit stitches it back (scaffold F, a battle rule for Ayrton).
--  - The sleeping Firstling is missing one pane from its brow, the same colour as the Frayling's
--    chip: the "fallen star" was never a star.
--  - The Unraveller comes down for the sleeper's last thread; the 6v6; the player destroys it
--    ([Locked] arc item 7). The Frayling gives its chip back unasked; the Firstling wakes, stitches
--    the sky shut and hands the player the end of the thread, the cosmic wrap ([Locked] item 9).
--  - Only then does the rival confess the thread he swallowed after the Mire ([Locked] item 8).
--  - Home: the Ringwalker and the mentor on the porch, the player named Ringwalker, and the cost:
--    the rival leaves to walk the ring alone with the thread asleep in him (brief section 14,
--    stage 3). The gifted creature's stitch flickers black: the sequel seed ([Default]).
-- Dialogue: at most three lines of 90 characters a beat. Place, people and battle ids are
-- placeholders for data not yet written.

local WorldTypes = require("../../shared/WorldTypes")

local FIRSTLING_LEVEL = 100

local wakes: { WorldTypes.Reward } = {
	-- NEEDS a reward kind for the cosmic wrap ([Locked]: "the ability to cosmic wrap one creature");
	-- WorldTypes.Reward has none yet, so it is not listed here.
	-- The Firstling joining the player is a proposal (roster plan section 5; OPEN_QUESTIONS.md). A
	-- mythic is a species flag, not a rarity; "Common" stands in until that flag exists.
	{
		kind = "Creature",
		species = "Firstling",
		level = FIRSTLING_LEVEL,
		rarity = "Common",
		colour = "Sand",
	},
}

local beats: { WorldTypes.Beat } = {
	{
		id = "hollow_arrival",
		name = "Old Hearth",
		minuteFrom = 1550,
		minuteTo = 1556,
		trigger = { kind = "Enter", target = "hollow_hub", requires = { "abyss_road_on" } },
		unlocks = { "hollow_hub" },
		grants = {},
		lines = {
			{
				speaker = "You",
				text = "Ruins, petals falling, and in the middle a little camp. The fire is lit.",
			},
			{ speaker = "Ringwalker", text = "Well. You took your time." },
			{ speaker = "Sorrel", text = "GRAN!" },
		},
	},
	{
		id = "gran_talk",
		name = "The fire",
		minuteFrom = 1555,
		minuteTo = 1565,
		trigger = { kind = "Talk", target = "ringwalker", requires = { "hollow_arrival" } },
		hint = "Talk to the Ringwalker by the fire",
		unlocks = { "hollow_quest_line", "hollow_routes" },
		grants = {},
		lines = {
			{
				speaker = "Ringwalker",
				text = "Eight years I've kept this fire. Thread burns, see. Keeps its fingers off the sleeper.",
			},
			{
				speaker = "Ringwalker",
				text = "The first creature sleeps under these ruins, holding the seams. It's tired. So am I.",
			},
			{
				speaker = "Ringwalker",
				text = "It'll take six of yours to finish this. Six, and every one of them a friend.",
			},
		},
	},
	{
		id = "gran_and_rival",
		name = "Grandson",
		minuteFrom = 1556,
		minuteTo = 1566,
		trigger = { kind = "Follow", requires = { "gran_talk" } },
		unlocks = {},
		grants = {},
		lines = {
			{ speaker = "Rival", text = "Gran. I... did things. Bad things. I'm sorry." },
			{
				speaker = "Ringwalker",
				text = "I know, love. We'll talk when this is done. All of it.",
			},
			{
				speaker = "Sorrel",
				text = "He's been mostly good since the cloud. Mostly. I'm keeping a list.",
			},
		},
	},
	{
		id = "hollow_catch",
		name = "The oldest kin",
		minuteFrom = 1565,
		minuteTo = 1590,
		trigger = { kind = "Tame", requires = { "gran_and_rival" } },
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Ringwalker",
				text = "See the glass patch on it? Hollow creatures are the first one's oldest kin.",
			},
		},
	},
	{
		id = "unravelled_patrol",
		name = "Coming apart",
		minuteFrom = 1590,
		minuteTo = 1615,
		trigger = { kind = "Win", target = "unravelled_patrol", requires = { "hollow_catch" } },
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Ringwalker",
				text = "See how they come apart? Each one's lost a part, and that part's moves with it.",
			},
			{
				speaker = "Ringwalker",
				text = "A Crystal hit stitches the hole shut. The first one's glass is Crystal, see.",
			},
		},
	},
	{
		id = "the_tapestry",
		name = "The tapestry",
		minuteFrom = 1640,
		minuteTo = 1660,
		trigger = { kind = "Sight", target = "tapestry_hall", requires = { "unravelled_patrol" } },
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "You",
				text = "A living tapestry walks past. Woven on its belly: a glass dragon, stitching the world.",
			},
			{
				speaker = "Sorrel",
				text = "Same picture as the Heartstone. Only here, the dragon's smiling.",
			},
		},
	},
	{
		id = "hearth_sighting",
		name = "The old guard",
		minuteFrom = 1700,
		minuteTo = 1720,
		trigger = { kind = "Sight", target = "hearth_ruins", requires = { "the_tapestry" } },
		lookAt = "hollow_lair",
		unlocks = { "hollow_giant_marker" },
		grants = {},
		lines = {
			{
				speaker = "Ringwalker",
				text = "Hearthwarden. My old friend. He guarded this hearth before there were people to warm.",
			},
			{
				speaker = "Ringwalker",
				text = "The leak got into him this spring. He doesn't know me now. That's the worst of it.",
			},
			{
				speaker = "Ringwalker",
				text = "His glass lights up the type he'll be next. Read the window, then switch to beat it.",
			},
		},
	},
	{
		id = "the_sleeper",
		name = "The sleeper",
		minuteFrom = 1850,
		minuteTo = 1870,
		trigger = { kind = "Enter", target = "sleeper_hall", requires = { "hearth_sighting" } },
		hint = "Go down to the sleeper's hall under the ruins",
		lookAt = "firstling",
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "You",
				text = "A glass dragon, coiled asleep. Stitches loose all over. One pane missing from its brow.",
			},
			{
				speaker = "You",
				text = "The Frayling's chip glints. The same colour as the gap. Exactly the same.",
			},
			{
				speaker = "Sorrel",
				text = "That's where the star came from. It was never a star at all.",
			},
		},
	},
	{
		id = "the_unraveller_comes",
		name = "The Unraveller",
		minuteFrom = 1851,
		minuteTo = 1871,
		trigger = { kind = "Follow", requires = { "the_sleeper" } },
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Unraveller",
				text = "There you all are. The patched, the mended, the handed-down. How tidy.",
			},
			{
				speaker = "Unraveller",
				text = "Give me the sleeper's last thread, and I will give you a world with nothing left to lose.",
			},
			{ speaker = "Rival", text = "Don't listen. It's never kind. Not once." },
		},
	},
	{
		id = "the_last_battle",
		name = "The last thread",
		minuteFrom = 1870,
		minuteTo = 1900,
		trigger = { kind = "Win", target = "unraveller", requires = { "the_unraveller_comes" } },
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "You",
				text = "Its last thread catches fire. The Unraveller comes apart, stitch by stitch, and is gone.",
			},
			{
				speaker = "Ringwalker",
				text = "Gone. Truly gone. ...Ha. I've caught his habit. Only mine's true.",
			},
			{ speaker = "Sorrel", text = "The tear's still open. Look." },
		},
	},
	{
		id = "the_chip",
		name = "Given back",
		minuteFrom = 1901,
		minuteTo = 1910,
		trigger = { kind = "Follow", requires = { "the_last_battle" } },
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "You",
				text = "The Frayling climbs onto the sleeper's nose and presses its brow to the empty pane.",
			},
			{
				speaker = "You",
				text = "The chip slides home. The Frayling's brow is only a gold seam now. It looks lighter.",
			},
			{ speaker = "Sorrel", text = "It gave it back. Nobody asked it to." },
		},
	},
	{
		id = "firstling_wakes",
		name = "The first creature",
		minuteFrom = 1902,
		minuteTo = 1911,
		trigger = { kind = "Follow", requires = { "the_chip" } },
		unlocks = { "tear_sealed", "cosmic_wrap" },
		grants = wakes,
		lines = {
			{
				speaker = "You",
				text = "The glass dragon wakes, laughing like wind chimes, and sniffs every patch on your team.",
			},
			{
				speaker = "You",
				text = "It pulls a gold thread from its mane and stitches the sky shut. The tear is gone.",
			},
			{
				speaker = "You",
				text = "It hands you the thread's end: a cosmic wrap. Then it curls round you, as if you're home.",
			},
		},
	},
	{
		id = "the_stitch_in_him",
		name = "The thread he swallowed",
		minuteFrom = 1903,
		minuteTo = 1912,
		trigger = { kind = "Follow", requires = { "firstling_wakes" } },
		unlocks = {},
		grants = {},
		lines = {
			{ speaker = "Ringwalker", text = "The thread, love. Tell them. It's time." },
			{
				speaker = "Rival",
				text = "After the Mire I swallowed the glint. It said they'd all kneel. Some days it drove me.",
			},
			{
				speaker = "Rival",
				text = "It's gone quiet. It's not gone. I can feel it, like a knot under my ribs.",
			},
		},
	},
	{
		id = "the_ring_closed",
		name = "Home",
		minuteFrom = 1950,
		minuteTo = 1990,
		trigger = { kind = "Enter", target = "greenwood_hub", requires = { "the_stitch_in_him" } },
		hint = "Go home to Thistledown",
		unlocks = { "post_game" },
		grants = {},
		lines = {
			{
				speaker = "You",
				text = "Home. Far off, the Lantern Spire's light has stopped blinking. It just shines.",
			},
			{ speaker = "Ringwalker", text = "Hello, you old fool. Is the kettle on?" },
			{
				speaker = "Mentor",
				text = "It is always on. ...Welcome home. Both of you. All of you.",
			},
		},
	},
	{
		id = "ringwalker_title",
		name = "Ringwalker",
		minuteFrom = 1951,
		minuteTo = 1991,
		trigger = { kind = "Follow", requires = { "the_ring_closed" } },
		unlocks = { "title_ringwalker" },
		grants = {},
		lines = {
			{
				speaker = "Ringwalker",
				text = "You walked the whole ring, start to end. That makes you a Ringwalker. My old title.",
			},
			{
				speaker = "Ringwalker",
				text = "I'm retiring. My knees have walked enough ring for one life.",
			},
			{
				speaker = "Mentor",
				text = "Wear it well. And come for tea. Often. That one is not a request.",
			},
		},
	},
	{
		id = "the_road_again",
		name = "The road again",
		minuteFrom = 1990,
		minuteTo = 2020,
		trigger = { kind = "Follow", requires = { "ringwalker_title" } },
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Rival",
				text = "I'm walking the ring. Alone, for a while. Somewhere this knot can't hurt anyone.",
			},
			{
				speaker = "Sorrel",
				text = "You'd better write. Real letters. And no 'truly'.",
			},
			{
				speaker = "You",
				text = "His old friend, yours now, sneezes. For a blink, one of its stitches looks black.",
			},
		},
	},
}

local Chapter11: WorldTypes.Chapter = {
	id = "chapter_11",
	number = 11,
	name = "The Hollow",
	beats = beats,
}

return Chapter11
