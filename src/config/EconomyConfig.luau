--!strict
-- Every coin and Breeding Candy number in one place (rule 9: no hard-coded balance numbers).
-- The model, the simulation that tuned these values and what to measure in the first playtest
-- are in docs/ECONOMY_MODEL.md. Every value here is a [Default] to tune from playtest data.
--
-- Three currencies:
--   Coins: earned only, never sold, never traded. Pay for lassos, consumables, bait, breeding.
--   Breeding Candy: earned only, never sold, never traded. Typed (one balance per element): each
--     parent in a breed uses BreedConfig.CANDY_COST of its own type. Catching and releasing pay
--     typed candy; milestone and daily rewards pay Prism Candy (working name), which counts as any type.
--   Gems: bought with Robux; buy time and capacity only. Not modelled here.
--
-- Anchor: a common biome-1 breed costs BreedConfig.COST_BASE (400) coins, which should be about
-- four minutes of biome-1 income (the simulation measures 4.5 to 4.9 minutes of all Greenwood play).
-- Repeatable income (BIOME_MULT) rises faster across biomes than breed costs (biome 1, 2, 3),
-- because the costs that grow with play (count multipliers, gem tiers, rematch horns) need it.

local Types = require("../shared/Types")

-- "Candy" is typed candy (one balance per element); "Prism" is Prism Candy, which counts as any type.
export type Currency = "Coins" | "Candy" | "Prism"
export type BattleKind = "Wild" | "Tamer" | "Gate" | "Giant"
export type ItemId =
	"Basic"
	| "Braided"
	| "Gilded"
	| "Tonic"
	| "GreatTonic"
	| "Revive"
	| "GiantCall"
	| "Bait"
	| "BondCharm"
export type LassoTier = "Basic" | "Braided" | "Gilded"
export type MaterialId = "Fernfluff" | "CanyonGrit" | "BrineShell"
export type CandySource =
	"MentorLesson"
	| "DailyTask"
	| "DailyHardTask"
	| "GiantRematch"
	| "WeeklyChallenge"
	| "GiantFirstClear"
	| "GateFirstClear"
	| "QuestLine"
	| "RankedSeason"
-- How a flow is limited. Every source of coins or candy must have one of the first five.
--   Diminishing: pays less each repeat within a day, then nothing.
--   Daily / Weekly: a fixed number of paid claims per day or week.
--   Once: once per key (per giant, per biome, per quest line, per account).
--   BelowCost: pays less than it costs to produce (releases).
--   Sink: removes currency; needs no limit.
export type Limit = "Diminishing" | "Daily" | "Weekly" | "Once" | "BelowCost" | "Sink"
export type Flow = { currency: Currency, limit: Limit, note: string }

export type ItemDef = {
	name: string, -- display name (original)
	price: number, -- coins
	scalesWithBiome: boolean, -- price x BIOME_MULT[biome] when true
	firstBiomePrice: number?, -- replaces the price in biome 1 when set
	fieldItem: boolean, -- counts toward the giant fight's field-item cap
	note: string,
}
export type Recipe = { material: MaterialId, count: number, coins: number }
export type CandyDef = {
	perClaim: number, -- Prism Candy per claim (QuestLine uses QUEST_LINE_CANDY by biome instead)
	cap: number, -- paid claims per window (day, week, or ever for Once)
	limit: Limit,
}
-- A daily falloff on typed candy, counted per type: the first `full` claims of a type each day pay
-- in full, each later claim is worth `rate` times the one before, never below `floor` of full,
-- and from `stop` claims onwards that type pays nothing until the next day.
export type CandyFalloff = { full: number, rate: number, floor: number, stop: number }
export type FirstAndRematch = {
	firstClear: number, -- coins at biome 1, level floor
	rematch: number, -- coins per paid rematch at biome 1, level floor
	rematchesPaidPerDay: number, -- rematch wins per opponent per day that pay; later wins pay 0
}
export type LevelBand = { min: number, max: number }

local EconomyConfig = {}

------------------------------------------------------------------------------------------------
-- Biomes and levels
------------------------------------------------------------------------------------------------

-- Coin multiplier per biome for repeatable income (wild wins, rematches, daily and weekly tasks)
-- and for the prices that scale (Giant Horn, Bond Charm). Breed costs use the biome number instead.
-- Biome 4 onwards are placeholders: re-run tests/economy.test.luau when the Mire is designed.
local BIOME_MULT: { number } = { 1, 2.5, 5, 7, 9, 11, 13, 15, 17, 19, 21 }
EconomyConfig.BIOME_MULT = BIOME_MULT
-- One-time rewards (first clears, quest lines) scale more gently than repeatable income. Bigger
-- windfalls in Dust Canyon made new players too flush in their first two hours (simulation table A).
local ONE_TIME_MULT: { number } = { 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6 }
EconomyConfig.ONE_TIME_MULT = ONE_TIME_MULT

-- Opponent level band per biome, used only to scale rewards. Ten levels per biome.
local LEVEL_BANDS: { LevelBand } = {}
for biome = 1, #BIOME_MULT do
	LEVEL_BANDS[biome] = { min = 2 + (biome - 1) * 10, max = 12 + (biome - 1) * 10 }
end
EconomyConfig.LEVEL_BANDS = LEVEL_BANDS
-- Each level above the band's floor adds this share; levels outside the band are clamped to it,
-- so over-levelled opponents in an early biome never pay like a later biome.
EconomyConfig.LEVEL_STEP = 0.03

------------------------------------------------------------------------------------------------
-- Battle rewards (coins at biome 1, level floor; repeat wins scale by BIOME_MULT, first clears by
-- ONE_TIME_MULT, both times the level factor)
------------------------------------------------------------------------------------------------

EconomyConfig.WILD_BASE = 60

-- Daily diminishing rule for wild wins against the same kind of creature (species):
-- the first DIMINISH_FULL wins of a kind each day pay in full, each later win pays
-- DIMINISH_RATE times the one before, never below DIMINISH_FLOOR of full, and from
-- DIMINISH_STOP wins onwards that kind pays nothing until the next day. A lasso catch counts as a win.
EconomyConfig.DIMINISH_FULL = 8
EconomyConfig.DIMINISH_RATE = 0.85
EconomyConfig.DIMINISH_FLOOR = 0.15
EconomyConfig.DIMINISH_STOP = 50

EconomyConfig.TRAINED = {
	Tamer = { firstClear = 160, rematch = 50, rematchesPaidPerDay = 1 },
	Gate = { firstClear = 500, rematch = 150, rematchesPaidPerDay = 1 },
	-- A giant rematch pays less than a GiantCall costs: rematches are a coin sink that earns candy.
	Giant = { firstClear = 800, rematch = 700, rematchesPaidPerDay = 2 },
} :: { Tamer: FirstAndRematch, Gate: FirstAndRematch, Giant: FirstAndRematch }

-- Giant fights: one GiantCall to enter, at most this many field items brought in.
EconomyConfig.GIANT_FIELD_ITEM_CAP = 5

------------------------------------------------------------------------------------------------
-- Quests, daily tasks, weekly challenge, PvP (coins)
------------------------------------------------------------------------------------------------

EconomyConfig.QUEST_LINE_COINS = 400 -- per completed quest line, x ONE_TIME_MULT; once per line
EconomyConfig.DAILY_TASK_COINS = 100 -- per easy daily task, x BIOME_MULT of the player's furthest biome
EconomyConfig.DAILY_HARD_TASK_COINS = 800 -- per hard daily task, same scaling
-- Daily tasks open with the first badge, so the first hours stay on the story.
EconomyConfig.DAILY_TASKS_UNLOCK_BADGES = 1
EconomyConfig.WEEKLY_CHALLENGE_COINS = 3000 -- once a week, same scaling

-- Casual PvP (built later; the cap belongs here). Created by the game, never taken from a player.
-- Paid only for matchmade wins, the first few a day, nothing for a repeat opponent within a day,
-- nothing in private servers.
EconomyConfig.CASUAL_PVP_WIN_COINS = 200 -- x BIOME_MULT of the player's furthest biome
EconomyConfig.CASUAL_PVP_PAID_WINS_PER_DAY = 5
EconomyConfig.CASUAL_PVP_REPEAT_OPPONENT_HOURS = 24

-- What a brand-new player starts with (the mentor's gift).
EconomyConfig.STARTING_COINS = 150
EconomyConfig.STARTER_ITEMS = { Basic = 5, Tonic = 3 } :: { Basic: number, Tonic: number }

------------------------------------------------------------------------------------------------
-- Items (coins). Every hub shop sells every item the player's furthest biome allows.
------------------------------------------------------------------------------------------------

EconomyConfig.ITEMS = {
	Basic = {
		name = "Rope Lasso",
		price = 15,
		scalesWithBiome = false,
		fieldItem = false,
		note = "Trivially cheap, so catching is never blocked",
	},
	Braided = {
		name = "Braided Lasso",
		price = 80,
		scalesWithBiome = false,
		fieldItem = false,
		note = "Wider zone, slower marker",
	},
	Gilded = {
		name = "Gilded Lasso",
		price = 250,
		scalesWithBiome = false,
		fieldItem = false,
		note = "Widest zone; the gem hunter's choice",
	},
	Tonic = {
		name = "Field Tonic",
		price = 30,
		scalesWithBiome = false,
		fieldItem = true,
		note = "Heals 40% of one creature's health",
	},
	GreatTonic = {
		name = "Deep Tonic",
		price = 90,
		scalesWithBiome = false,
		fieldItem = true,
		note = "Heals one creature fully",
	},
	Revive = {
		name = "Rally Root",
		price = 150,
		scalesWithBiome = false,
		fieldItem = true,
		note = "Brings back a knocked-out creature at half health",
	},
	GiantCall = {
		name = "Giant Horn",
		price = 1100,
		scalesWithBiome = true,
		-- Greenwood's horn is cheaper, so a new player's first giant is never far off.
		firstBiomePrice = 900,
		fieldItem = false,
		note = "Needed to start a giant fight; used up win or lose",
	},
	Bait = {
		name = "Tide Bait",
		price = 400,
		scalesWithBiome = false,
		fieldItem = false,
		note = "Summons a rare spawn; sold from Tide Flats (biome 3) on",
	},
	BondCharm = {
		name = "Bond Charm",
		price = 400,
		scalesWithBiome = true,
		fieldItem = false,
		note = "Tilts one breed's part choice toward the first parent (BreedConfig.CHARM_CHANCE); used up",
	},
} :: {
	Basic: ItemDef,
	Braided: ItemDef,
	Gilded: ItemDef,
	Tonic: ItemDef,
	GreatTonic: ItemDef,
	Revive: ItemDef,
	GiantCall: ItemDef,
	Bait: ItemDef,
	BondCharm: ItemDef,
}

local ITEM_IDS: { ItemId } = {
	"Basic",
	"Braided",
	"Gilded",
	"Tonic",
	"GreatTonic",
	"Revive",
	"GiantCall",
	"Bait",
	"BondCharm",
}
EconomyConfig.ITEM_IDS = ITEM_IDS
local LASSO_TIERS: { LassoTier } = { "Basic", "Braided", "Gilded" }
EconomyConfig.LASSO_TIERS = LASSO_TIERS
EconomyConfig.BAIT_MIN_BIOME = 3

-- The cheapest lasso that can catch each rarity (a gem creature's zone is too small for a rope).
-- Used for the release rule: a release always pays less than this lasso costs.
-- If capture design lets a Basic lasso catch everything, set every entry to "Basic"; the release
-- payout then lowers itself automatically.
EconomyConfig.LASSO_MIN_TIER = {
	Common = "Basic",
	Uncommon = "Basic",
	Gem = "Braided",
	Ruby = "Gilded",
	Diamond = "Gilded",
	Cosmic = "Gilded",
} :: Types.ByRarity<LassoTier>

------------------------------------------------------------------------------------------------
-- Materials and crafting. Materials drop from wild wins and come from releasing gem creatures.
-- Crafted items cannot be sold back, so materials never turn into coins.
------------------------------------------------------------------------------------------------

local MATERIAL_BY_BIOME: { MaterialId } = { "Fernfluff", "CanyonGrit", "BrineShell" }
EconomyConfig.MATERIAL_BY_BIOME = MATERIAL_BY_BIOME
EconomyConfig.MATERIAL_DROP_CHANCE = 0.35 -- per wild win, times that win's diminishing factor

EconomyConfig.RECIPES = {
	Tonic = { material = "Fernfluff", count = 3, coins = 0 },
	GreatTonic = { material = "CanyonGrit", count = 3, coins = 20 },
	Bait = { material = "BrineShell", count = 8, coins = 80 },
} :: { Tonic: Recipe, GreatTonic: Recipe, Bait: Recipe }

------------------------------------------------------------------------------------------------
-- Releasing a creature: a few coins, plus materials for gem tiers. Never more than
-- RELEASE_MAX_SHARE of the cheapest way to obtain the creature (the minimum lasso for its rarity),
-- counting the materials at their crafting value. Economy.releasePayout enforces the cap.
------------------------------------------------------------------------------------------------

EconomyConfig.RELEASE_COINS = {
	Common = 4,
	Uncommon = 6,
	Gem = 20,
	Ruby = 50,
	Diamond = 80,
	Cosmic = 80,
} :: Types.ByRarity<number> -- x BIOME_MULT of the creature's origin biome, before the cap
EconomyConfig.RELEASE_MATERIALS = {
	Common = 0,
	Uncommon = 0,
	Gem = 1,
	Ruby = 2,
	Diamond = 3,
	Cosmic = 3,
} :: Types.ByRarity<number>
EconomyConfig.RELEASE_MAX_SHARE = 0.75
EconomyConfig.RELEASE_MIN_COINS = 1

------------------------------------------------------------------------------------------------
-- Breeding Candy (BreedConfig.CANDY_COST sets what each parent uses, of its own type).
-- Candy is earned only: never sold for Robux or Gems, never traded or gifted.
--
-- Typed candy: catching a creature pays candy of its type (its torso's element); releasing one
-- pays less. Both fall off after a daily number per type, so catch-and-release cannot flood
-- supply. Economy.catchCandy and Economy.releaseCandy apply the falloff.
------------------------------------------------------------------------------------------------

-- Typed candy for a catch, by the creature's rarity, before the falloff. Fractions are paid as
-- they add up across the day's claims of that type (0.5 pays one candy every second claim).
EconomyConfig.CATCH_CANDY = {
	Common = 1,
	Uncommon = 2,
	Gem = 6,
	Ruby = 12,
	Diamond = 24,
	Cosmic = 24,
} :: Types.ByRarity<number>
-- Typed candy for a release. Always less than the catch pays and less than the cheapest breed
-- that can make a creature of that rarity (tested), so releasing never turns a profit in candy.
EconomyConfig.RELEASE_CANDY = {
	Common = 0.5,
	Uncommon = 0.5,
	Gem = 3,
	Ruby = 6,
	Diamond = 12,
	Cosmic = 12,
} :: Types.ByRarity<number>
-- Three catches and three releases of each type a day pay in full, which covers normal play
-- (a regular player catches about five creatures a day, across several types). Farming one type
-- runs into the falloff fast: a whole day of common catches of one type pays at most 7 candy.
EconomyConfig.CATCH_FALLOFF = { full = 3, rate = 0.5, floor = 0.1, stop = 40 } :: CandyFalloff
EconomyConfig.RELEASE_FALLOFF = { full = 3, rate = 0.4, floor = 0.1, stop = 40 } :: CandyFalloff

-- Prism Candy sources: milestones and daily rewards. Prism counts as any type, so a player is
-- never stuck for a type their biome lacks.
EconomyConfig.CANDY = {
	-- Once per account: the mentor's lesson pays for the first breed (and a second to try again).
	MentorLesson = { perClaim = 2, cap = 1, limit = "Once" },
	-- Three easy daily tasks (win 3 battles, tame a creature, breed once): the casual player's income.
	DailyTask = { perClaim = 1, cap = 3, limit = "Daily" },
	-- Three harder daily tasks (win 30 wild battles, beat a giant rematch, win 5 tamer rematches).
	DailyHardTask = { perClaim = 1, cap = 3, limit = "Daily" },
	-- Rewards preparing for and winning a giant rematch, as the consumables decision intends.
	GiantRematch = { perClaim = 1, cap = 2, limit = "Daily" },
	-- Post-game weekly tamer challenge.
	WeeklyChallenge = { perClaim = 3, cap = 1, limit = "Weekly" },
	-- Once per giant and once per biome's gate.
	GiantFirstClear = { perClaim = 5, cap = 1, limit = "Once" },
	GateFirstClear = { perClaim = 5, cap = 1, limit = "Once" },
	-- Once per quest line; the amount comes from QUEST_LINE_CANDY by biome.
	QuestLine = { perClaim = 0, cap = 1, limit = "Once" },
	-- Ranked season prizes by final league, once per season (PvP arrives later).
	RankedSeason = { perClaim = 10, cap = 1, limit = "Once" },
} :: {
	MentorLesson: CandyDef,
	DailyTask: CandyDef,
	DailyHardTask: CandyDef,
	GiantRematch: CandyDef,
	WeeklyChallenge: CandyDef,
	GiantFirstClear: CandyDef,
	GateFirstClear: CandyDef,
	QuestLine: CandyDef,
	RankedSeason: CandyDef,
}
local CANDY_SOURCES: { CandySource } = {
	"MentorLesson",
	"DailyTask",
	"DailyHardTask",
	"GiantRematch",
	"WeeklyChallenge",
	"GiantFirstClear",
	"GateFirstClear",
	"QuestLine",
	"RankedSeason",
}
EconomyConfig.CANDY_SOURCES = CANDY_SOURCES
-- Prism Candy per quest line by biome (later biomes use the last entry).
local QUEST_LINE_CANDY: { number } = { 2, 3, 4 }
EconomyConfig.QUEST_LINE_CANDY = QUEST_LINE_CANDY

------------------------------------------------------------------------------------------------
-- Stable and pens
------------------------------------------------------------------------------------------------

EconomyConfig.STABLE_FREE_SLOTS = 30
EconomyConfig.STABLE_EXPANSION_SLOTS = 10
-- Coin-bought stable expansions, in order; a long-term sink for players who collect.
-- Gem expansions (capacity, sold for Robux) stack on top and are priced elsewhere.
local STABLE_EXPANSION_COINS: { number } = { 3000, 6000, 12000, 24000, 48000 }
EconomyConfig.STABLE_EXPANSION_COINS = STABLE_EXPANSION_COINS

-- Stable decorations: the veterans' prestige sink (research/market/06 recommendation 11).
-- Cosmetic only, bought with coins, each once, in this order. A new set joins with each biome.
local DECOR_COINS: { number } =
	{ 5000, 8000, 12000, 18000, 25000, 35000, 50000, 70000, 100000, 140000, 200000, 280000 }
EconomyConfig.DECOR_COINS = DECOR_COINS

EconomyConfig.PENS_FREE = 1
-- The mentor's lesson (the first quest, at about minute 10) gives the second pen. Two eggs from the
-- start keep breeding, the main coin sink, from being capped by one pen in the first hours.
EconomyConfig.PENS_FROM_QUEST = 1
EconomyConfig.PENS_MAX = 4 -- hard cap, Gems included

------------------------------------------------------------------------------------------------
-- The ledger: every named source and sink, its currency and how it is limited.
------------------------------------------------------------------------------------------------

EconomyConfig.FLOWS = {
	-- Coin sources
	Starter = { currency = "Coins", limit = "Once", note = "STARTING_COINS, once per account" },
	WildWin = { currency = "Coins", limit = "Diminishing", note = "Per kind per day" },
	TamerWin = {
		currency = "Coins",
		limit = "Daily",
		note = "First clear once, one paid rematch a day",
	},
	GateWin = {
		currency = "Coins",
		limit = "Daily",
		note = "First clear once, one paid rematch a day",
	},
	GiantWin = {
		currency = "Coins",
		limit = "Daily",
		note = "First clear once, two paid rematches a day",
	},
	QuestLine = { currency = "Coins", limit = "Once", note = "Once per quest line" },
	DailyTask = { currency = "Coins", limit = "Daily", note = "Three easy and three hard tasks" },
	WeeklyChallenge = { currency = "Coins", limit = "Weekly", note = "Once a week" },
	CasualPvp = { currency = "Coins", limit = "Daily", note = "First five matchmade wins a day" },
	Release = {
		currency = "Coins",
		limit = "BelowCost",
		note = "Below the minimum lasso for the rarity",
	},
	-- Coin sinks
	Shop = { currency = "Coins", limit = "Sink", note = "Lassos, consumables, horns, bait, charms" },
	Craft = { currency = "Coins", limit = "Sink", note = "Coin part of a recipe" },
	Breed = { currency = "Coins", limit = "Sink", note = "Breeding.cost" },
	StableExpansion = { currency = "Coins", limit = "Sink", note = "STABLE_EXPANSION_COINS" },
	Decor = {
		currency = "Coins",
		limit = "Sink",
		note = "DECOR_COINS, cosmetic stable decorations",
	},
	TradeFee = { currency = "Coins", limit = "Sink", note = "Trading arrives later" },
	-- Typed candy sources (per type per day, CATCH_FALLOFF and RELEASE_FALLOFF)
	CandyCatch = { currency = "Candy", limit = "Diminishing", note = "CATCH_CANDY, per type" },
	CandyRelease = {
		currency = "Candy",
		limit = "Diminishing",
		note = "RELEASE_CANDY, per type; below the catch and the cheapest breed",
	},
	-- Prism Candy sources (each is limited per CANDY above)
	CandyMentor = { currency = "Prism", limit = "Once", note = "MentorLesson" },
	CandyDaily = { currency = "Prism", limit = "Daily", note = "DailyTask and DailyHardTask" },
	CandyGiantRematch = { currency = "Prism", limit = "Daily", note = "GiantRematch" },
	CandyWeekly = { currency = "Prism", limit = "Weekly", note = "WeeklyChallenge" },
	CandyFirstClear = {
		currency = "Prism",
		limit = "Once",
		note = "GiantFirstClear and GateFirstClear",
	},
	CandyQuest = { currency = "Prism", limit = "Once", note = "QuestLine" },
	CandyRanked = { currency = "Prism", limit = "Once", note = "RankedSeason, once per season" },
	-- Candy sink: one type at a time, typed candy first, then Prism for any shortfall
	BreedCandy = { currency = "Candy", limit = "Sink", note = "BreedConfig.CANDY_COST, per parent" },
} :: { [string]: Flow }

return EconomyConfig
