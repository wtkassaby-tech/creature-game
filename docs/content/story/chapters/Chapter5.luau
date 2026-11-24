--!strict
-- DRAFT, not wired into the game (docs/content/story/). Copy to src/content/story_data/ and add to
-- src/content/Story.luau only after Ayrton approves it and the biome's map, tamers and giant exist.
--
-- Chapter 5 of 11: Frostline. Beats in order, with timing targets that pick up where chapter 4
-- ends (minute 290; each biome about 1.3 times the last; all [Defaults] to tune in playtests).
-- Finishing a beat sets a flag equal to its id. The first beat needs "mire_road_on", the last beat of
-- chapter 4, so the storyline reads straight on.
--
-- The arc (docs/content/story/ARC.md, chapter 5):
--  - The companion arrives: Sorrel, the rival's little sister, walking up the gorge alone to fetch
--    him home. She carries his first creature, the one that hatched from their gran's egg, which he
--    sent home after Greenwood. She names the mentor's tell: he only says "truly" when he lies.
--  - The journal pages players have been finding are her gran's handwriting; her gran was the
--    Ringwalker, who rode the giant up the pass. The mystery gets a face.
--  - The rival holds the gate, tint 0.9. His shards are gone ("Don't need them now": he swallowed
--    the thread after the Mire, which the player learns only in chapter 11, brief arc item 8). He
--    says what the glint asked him in chapter 3, which is the villain's argument. His team fields
--    the Mire's giant, taken by force, with dark stitches (tamer data, not this file).
--  - No letter from the mentor: his lie this chapter is the one Sorrel quotes ("Gran's travelling").
-- Chill (the biome's new idea, a slow) is taught by the healer at the second beat; the first tamer
-- repeats it. Cross-biome breeding (front limbs carry Frostline's Defence) is taught by the breeder.
-- The giant is optional; the sighting beat names its counter. Dialogue: at most three lines of 90
-- characters a beat. Place, people and battle ids are placeholders for data not yet written.

local EconomyConfig = require("../../config/EconomyConfig")
local WorldTypes = require("../../shared/WorldTypes")

local BIOME = 5
local TOKEN_LEVEL = 52 -- the clear token: three under the cap of 55

local lesson: { WorldTypes.Reward } = {
	{ kind = "Item", item = "GreatTonic", count = 2 },
}

local badge: { WorldTypes.Reward } = {
	{ kind = "Badge", id = "frostline_badge", name = "Snowdrop Badge" },
	{
		kind = "Coins",
		amount = math.floor(
			EconomyConfig.TRAINED.Gate.firstClear * EconomyConfig.ONE_TIME_MULT[BIOME]
		),
	},
	{ kind = "PrismCandy", amount = EconomyConfig.CANDY.GateFirstClear.perClaim },
	{
		kind = "Creature",
		species = "Rimefern", -- Frost beats Crystal, the next biome (roster plan)
		level = TOKEN_LEVEL,
		rarity = "Common",
		colour = "Moss",
	},
}

local beats: { WorldTypes.Beat } = {
	{
		id = "frost_arrival",
		name = "Rimewick",
		minuteFrom = 290,
		minuteTo = 294,
		trigger = { kind = "Enter", target = "frostline_hub", requires = { "mire_road_on" } },
		unlocks = { "frost_hub" },
		grants = {},
		lines = {
			{
				speaker = "Sign",
				text = "Rimewick. Hot soup at the Thaw House. Mind the icicles. They mind nobody.",
			},
			{
				speaker = "Ingrid",
				text = "A Bulrush Badge, all the way up the gorge? Come in. Stamp your boots. Both of them.",
			},
		},
	},
	{
		id = "frost_chill",
		name = "The Thaw House",
		minuteFrom = 292,
		minuteTo = 297,
		trigger = { kind = "Talk", target = "hilde_varrow", requires = { "frost_arrival" } },
		unlocks = { "chill", "frost_quest_line", "frost_routes" },
		grants = {},
		lines = {
			{
				speaker = "Hilde",
				text = "Up here, frost bites slow. A Chilled creature loses its speed, however quick it was.",
			},
			{
				speaker = "Hilde",
				text = "It thaws in a few turns. Frost creatures never feel it. Slow is just their walk.",
			},
			{
				speaker = "Hilde",
				text = "Bring something warm, or bring patience. The soup's free. So is the healing.",
			},
		},
	},
	{
		id = "sorrel_arrives",
		name = "A girl at the door",
		minuteFrom = 295,
		minuteTo = 300,
		trigger = { kind = "Talk", target = "sorrel", requires = { "frost_chill" } },
		hint = "Talk to the girl at the Thaw House door",
		unlocks = { "companion" },
		grants = {},
		lines = {
			{
				speaker = "Sorrel",
				text = "You're the one who keeps beating my brother. I'm Sorrel. I've come to fetch him home.",
			},
			{
				speaker = "Sorrel",
				text = "He went up the pass two days ago. He didn't wave. He always waves.",
			},
			{
				speaker = "Sorrel",
				text = "I'll tag along till we find him. I'm small, I'm useful, and I mend things.",
			},
		},
	},
	{
		id = "first_frost_tamer",
		name = "A local tamer",
		minuteFrom = 297,
		minuteTo = 307,
		trigger = { kind = "Win", target = "fl_ebbe", requires = { "sorrel_arrives" } },
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Ebbe",
				text = "Chilled, your quick one moved like treacle. Up here, quick means nothing. Thick does.",
			},
		},
	},
	{
		id = "frost_catch",
		name = "A catch in the snow",
		minuteFrom = 303,
		minuteTo = 313,
		trigger = { kind = "Tame", requires = { "first_frost_tamer" } },
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Sorrel",
				text = "Look at its front legs. Like it's wearing two snowboots. Bet nothing knocks it over.",
			},
		},
	},
	{
		id = "frost_breeding",
		name = "The Snug Pens",
		minuteFrom = 310,
		minuteTo = 320,
		trigger = { kind = "Talk", target = "mags_tolley", requires = { "frost_catch" } },
		unlocks = {},
		grants = lesson,
		lines = {
			{
				speaker = "Mags",
				text = "A part keeps where it came from. Frostline front legs carry toughness, whoever wears them.",
			},
			{
				speaker = "Mags",
				text = "Breed them onto a canyon sprinter: a quick thing that won't fold. That's the trick.",
			},
			{
				speaker = "Sorrel",
				text = "The best bits of everywhere, in one. Gran used to say that about people.",
			},
		},
	},
	{
		id = "the_first_friend",
		name = "His first friend",
		minuteFrom = 318,
		minuteTo = 328,
		trigger = { kind = "Talk", target = "sorrel", requires = { "frost_breeding" } },
		hint = "Talk to Sorrel at the Snug Pens",
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Sorrel",
				text = "This is his first. It hatched from the egg Gran left him. He sent it home after Greenwood.",
			},
			{
				speaker = "Sorrel",
				text = "Said it only knew how to lose. It sat by our door for a week.",
			},
			{
				speaker = "Sorrel",
				text = "Mentor says Gran's travelling. 'Truly,' he says. He only says truly when he's fibbing.",
			},
		},
	},
	{
		id = "drift_sighting",
		name = "The hill with ears",
		minuteFrom = 330,
		minuteTo = 340,
		trigger = { kind = "Sight", target = "snowfield_reach", requires = { "the_first_friend" } },
		lookAt = "frostline_lair",
		unlocks = { "frost_giant_marker" },
		grants = {},
		lines = {
			{
				speaker = "Gudrun",
				text = "That hill just twitched its ears. Driftmother. Not right since the sky flickered.",
			},
			{
				speaker = "Gudrun",
				text = "The Ringwalker used to ride her up the pass. Hung a lantern on her back. Still there, see?",
			},
			{
				speaker = "Gudrun",
				text = "Her lair's off the Pine Road. She lifts her paws, then stamps. Hit her with Fire then.",
			},
		},
	},
	{
		id = "gran_was_here",
		name = "The Ringwalker",
		minuteFrom = 331,
		minuteTo = 341,
		trigger = { kind = "Follow", requires = { "drift_sighting" } },
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Sorrel",
				text = "Ringwalker. That's what they called Gran, back when she walked the whole ring.",
			},
			{
				speaker = "Sorrel",
				text = "Those old pages in your journal? That's her writing. I'd know those loopy g's anywhere.",
			},
			{
				speaker = "Sorrel",
				text = "Everyone up here remembers her. At home, nobody even says her name.",
			},
		},
	},
	{
		id = "frost_gate_challenge",
		name = "The Frozen Fall",
		minuteFrom = 360,
		minuteTo = 375,
		trigger = { kind = "Enter", target = "frostline_gate", requires = { "gran_was_here" } },
		unlocks = {},
		grants = {},
		lines = {
			{ speaker = "Rival", text = "Sorrel. Go home." },
			{
				speaker = "Sorrel",
				text = "Your first friend waited at the door a week. And where are your shards?",
			},
			{
				speaker = "Rival",
				text = "Don't need them now. It asked why I keep things I never chose. So I stopped. Four each.",
			},
		},
	},
	{
		id = "frost_badge",
		name = "The fifth badge",
		minuteFrom = 365,
		minuteTo = 380,
		trigger = {
			kind = "Win",
			target = "rival_frozen_fall",
			requires = { "frost_gate_challenge" },
		},
		unlocks = { "badge_5", "level_cap_65" },
		grants = badge,
		lines = {
			{
				speaker = "Rival",
				text = "Lost again. Funny. It doesn't even sting now. Keep your badge.",
			},
			{
				speaker = "Rival",
				text = "The Mire's giant kneels for me now, by the way. Everything kneels if you pull hard enough.",
			},
			{
				speaker = "Sorrel",
				text = "...I'm coming with you. Someone has to be there when he falls over.",
			},
		},
	},
	{
		id = "frost_road_on",
		name = "The road on",
		minuteFrom = 375,
		minuteTo = 390,
		trigger = {
			kind = "Enter",
			target = "frostline_sealed_path",
			requires = { "frost_badge" },
		},
		unlocks = { "biome_6", "chapter_6_teaser" },
		grants = {},
		lines = {
			{
				speaker = "Sign",
				text = "The Crystal Deep road, behind the Frozen Fall. Shut to all but badge holders.",
			},
			{
				speaker = "Sorrel",
				text = "It's dark in there. I'm not scared. I'm holding your sleeve for your sake.",
			},
		},
	},
}

local Chapter5: WorldTypes.Chapter = {
	id = "chapter_5",
	number = 5,
	name = "Frostline",
	beats = beats,
}

return Chapter5
