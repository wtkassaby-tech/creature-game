--!strict
-- Chapter 4 of 11: the Mire. Beats in order, with timing targets that pick up where chapter 3
-- ends (minute 215; all [Defaults] to tune in playtests). Finishing a beat sets a flag equal to its id.
-- The first beat needs "tide_road_on", the last beat of chapter 3, so the storyline reads straight on.
-- Written ahead of launch: src/config/ReleaseConfig.luau keeps it out of the story until it opens.
--
-- The arc (brief section 9), one more step on from chapter 3:
--  - The mentor keeps his promise to explain "at the Mire", and comes in person. He tells part of the
--    truth: the flicker is a tear in the sky, and what leaks through wakes the giants and turns
--    creatures to gem. Then he lies about the rest: "how it opened, nobody knows". (Ch1: "do not ask
--    what you must be strong for"; ch2: "only minerals"; ch3: "weather".) The truth waits for biome 9.
--  - The rival is met mid-biome, muddy and shaken: the glint showed him how to make a giant obey, he
--    tried it on the Mire's giant, and it threw him off. His tint is 0.85. He says the tear opened
--    over Thistledown first, which points at the mentor without saying why.
--  - The gate is held by a local champion (the sluice keeper), as Dust Canyon's was.
-- Poison (the biome's new idea, master plan 4.5) is taught by the healer at the second beat: it
-- nips a little each turn and wears off, Toxic creatures never catch it, and the spring mends what
-- it took. The first tamer, the catch beat and the gate keeper's challenge repeat the hint, so a
-- player has three nudges to bring a Toxic creature before the gate. The giant is optional; the
-- sighting beat only points at its grove. Dialogue is short and skippable: at most three lines of
-- 90 characters a beat.
--
-- Coins, candy and items come from EconomyConfig, so tuning the economy tunes the story's gifts.

local EconomyConfig = require("../../config/EconomyConfig")
local WorldTypes = require("../../shared/WorldTypes")

local BIOME = 4
local TOKEN_LEVEL = 42 -- the clear token, a friend for the road ahead: three under the cap of 45

local visit: { WorldTypes.Reward } = {
	{ kind = "Item", item = "GreatTonic", count = 2 },
}

local badge: { WorldTypes.Reward } = {
	{ kind = "Badge", id = "mire_badge", name = "Bulrush Badge" },
	{
		kind = "Coins",
		amount = math.floor(
			EconomyConfig.TRAINED.Gate.firstClear * EconomyConfig.ONE_TIME_MULT[BIOME]
		),
	},
	{ kind = "PrismCandy", amount = EconomyConfig.CANDY.GateFirstClear.perClaim },
	{
		kind = "Creature",
		species = "Mistrel",
		level = TOKEN_LEVEL,
		rarity = "Common",
		colour = "Moss",
	},
}

local beats: { WorldTypes.Beat } = {
	{
		id = "mire_arrival",
		name = "Sedgeholm",
		minuteFrom = 215,
		minuteTo = 219,
		trigger = { kind = "Enter", target = "mire_hub", requires = { "tide_road_on" } },
		unlocks = { "mire_hub" },
		grants = {},
		lines = {
			{
				speaker = "Sign",
				text = "Sedgeholm. Keep to the boardwalks. Do not follow the lights.",
			},
			{
				speaker = "Vesper",
				text = "A Breaker Badge! Welcome. Wipe your boots, the whole village is damp.",
			},
		},
	},
	{
		id = "mire_poison",
		name = "The Clearwater Spring",
		minuteFrom = 217,
		minuteTo = 222,
		trigger = { kind = "Talk", target = "ottilie_dunmore", requires = { "mire_arrival" } },
		unlocks = { "poison", "mire_quest_line", "mire_routes" },
		grants = {},
		lines = {
			{
				speaker = "Ottilie",
				text = "Mire creatures bite with poison. It nips a bit each turn, then wears off.",
			},
			{
				speaker = "Ottilie",
				text = "Toxic creatures never catch it. Tame one or two and keep them close.",
			},
			{
				speaker = "Ottilie",
				text = "What poison takes stays taken. Come back to my spring and I mend it, free.",
			},
		},
	},
	{
		id = "first_mire_tamer",
		name = "A local tamer",
		minuteFrom = 219,
		minuteTo = 229,
		trigger = { kind = "Win", target = "mr_wren", requires = { "mire_poison" } },
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Tobin Reede",
				text = "Did you see? My Fenwhisk never got poisoned. Toxic ones just shrug it off.",
			},
		},
	},
	{
		id = "mire_catch",
		name = "A catch from the reeds",
		minuteFrom = 223,
		minuteTo = 233,
		trigger = { kind = "Tame", requires = { "first_mire_tamer" } },
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Vesper",
				text = "A Mire catch! If it is Toxic, poison will slide right off it.",
			},
		},
	},
	{
		id = "mentors_visit",
		name = "The mentor comes to the Mire",
		minuteFrom = 229,
		minuteTo = 237,
		trigger = { kind = "Talk", target = "jory_pike", requires = { "mire_catch" } },
		unlocks = {},
		grants = visit,
		lines = {
			{
				speaker = "Mentor",
				text = "I promised you answers here. The flicker is a tear in the sky. Things leak through.",
			},
			{
				speaker = "Mentor",
				text = "They wake giants and turn creatures to gem. ...That is why I pushed you to grow strong.",
			},
			{
				speaker = "Mentor",
				text = "How it opened? No one knows. Truly. Take these tonics. Do not go near the grove.",
			},
		},
	},
	{
		id = "mire_rival",
		name = "The rival in the fog",
		minuteFrom = 235,
		minuteTo = 247,
		trigger = { kind = "Win", target = "rival_mire", requires = { "mentors_visit" } },
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Rival",
				text = "The giant threw me off. The glint swore it would kneel. It... nearly knelt.",
			},
			{
				speaker = "Rival",
				text = "Your mentor came all this way? Ask him why the tear opened over Thistledown first.",
			},
		},
	},
	{
		id = "grove_sighting",
		name = "The grove that breathes",
		minuteFrom = 245,
		minuteTo = 255,
		trigger = { kind = "Sight", target = "fogwater_reach", requires = { "mire_rival" } },
		unlocks = { "mire_giant_marker" },
		grants = {},
		lines = {
			{
				speaker = "Dill",
				text = "The grove is moving! Sloughback is awake, and fuming. Someone tried to rope it.",
			},
			{
				speaker = "Dill",
				text = "Its lair is off Cypress Road. Sand and Frost types cut through its fog.",
			},
		},
	},
	{
		id = "mire_gate_challenge",
		name = "The Sluice Gate",
		minuteFrom = 265,
		minuteTo = 280,
		trigger = { kind = "Enter", target = "mire_gate", requires = { "grove_sighting" } },
		unlocks = {},
		grants = {},
		lines = {
			{
				speaker = "Honora",
				text = "My sluice stays shut to a weak team. Four of yours against four of mine.",
			},
			{
				speaker = "Honora",
				text = "Mine bite with poison. Bring some that cannot catch it, or bring tonics.",
			},
			{
				speaker = "Honora",
				text = "Your friend in the torn jacket stole a punt and went round my sluice. Poled it badly.",
			},
		},
	},
	{
		id = "mire_badge",
		name = "The fourth badge",
		minuteFrom = 270,
		minuteTo = 285,
		trigger = {
			kind = "Win",
			target = "champion_vell",
			requires = { "mire_gate_challenge" },
		},
		unlocks = { "badge_4", "level_cap_55" },
		grants = badge,
		lines = {
			{
				speaker = "Honora",
				text = "Poison-wise, and well played. The Bulrush Badge is yours. The sluice is open.",
			},
			{
				speaker = "Vesper",
				text = "A friend from Sedgeholm, for the cold ahead. It breathes a mist. You will need it.",
			},
		},
	},
	{
		id = "mire_road_on",
		name = "The road on",
		minuteFrom = 275,
		minuteTo = 290,
		trigger = {
			kind = "Enter",
			target = "mire_sealed_path",
			requires = { "mire_badge" },
		},
		unlocks = { "biome_5", "chapter_5_teaser" },
		grants = {},
		lines = {
			{ speaker = "Sign", text = "The Frostline road. Shut to all but badge holders." },
			{
				speaker = "Jory",
				text = "The air turns cold past the sluice. Wrap up, and mind the ice.",
			},
		},
	},
}

local Chapter4: WorldTypes.Chapter = {
	id = "chapter_4",
	number = 4,
	name = "Mire",
	beats = beats,
}

return Chapter4
