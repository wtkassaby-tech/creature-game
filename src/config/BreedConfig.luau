--!strict
-- Every breeding number in one place (brief rule: no hard-coded balance numbers).
-- Starting values from research/market/04_BREEDING_DESIGN.md.

local Types = require("../shared/Types")

export type InheritOdds = { both: number, one: number }

local BreedConfig = {}

local SLOTS: { Types.Slot } = { "Head", "Torso", "FrontLimbs", "Legs", "Tail" }
local STATS: { Types.Stat } = { "Hp", "Attack", "Defence", "Speed" }
BreedConfig.SLOTS = SLOTS
BreedConfig.STATS = STATS

-- Quality gene: 0..10 pips, each pip above or below 5 is worth 1%.
BreedConfig.QUALITY_MIN = 0
BreedConfig.QUALITY_MAX = 10
BreedConfig.QUALITY_MID = 5
BreedConfig.QUALITY_STEP = 0.01
BreedConfig.QUALITY_DRIFT = 0.15 -- chance scale for moving one pip (stress test: 0.20 never finishes, no pull finishes too fast)
BreedConfig.WILD_QUALITY_MIN = 3
BreedConfig.WILD_QUALITY_MAX = 7

-- Rare mutation: a two-pip jump on one part, or a new colour.
BreedConfig.RARE_MUTATION_CHANCE = 0.02
BreedConfig.RARE_MUTATION_PIPS = 2

-- Fit factor clamp (stress test, research/market/09): a low floor so light legs on a heavy body
-- really are slow, and a modest ceiling. Safe because fit is worked out fresh and never saved.
BreedConfig.FIT_MIN = 0.60
BreedConfig.FIT_MAX = 1.00

-- Shared stat budget: no mix of parts may exceed this multiple of its body plan's budget.
-- Without it, "the best part from every species" beats every pure species by 40% or more.
-- The budget score is Hp x BUDGET_HP_WEIGHT + Attack + Defence + Speed at quality 5, before level and rarity.
BreedConfig.BUDGET_CAP = 1.15
BreedConfig.PLAN_BUDGET =
	{ Quad = 200, Biped = 200, Winged = 200, Serpent = 200 } :: Types.ByPlan<number>
BreedConfig.BUDGET_HP_WEIGHT = 0.6

-- Size gene. A bigger body is heavier (slower legs) but its torso gives more Hp and Defence,
-- so size is a trade and not free Speed.
BreedConfig.SIZE_MIN = 0.9
BreedConfig.SIZE_MAX = 1.1
BreedConfig.SIZE_JITTER = 0.03

-- Part choice per slot, and the Bond Charm tilt.
BreedConfig.PART_CHANCE = 0.5
BreedConfig.CHARM_CHANCE = 0.8

-- Offspring level = this share of the parents' average (brief: 50 and 45 give about 20).
BreedConfig.LEVEL_SHARE = 0.4

-- Stat scaling.
BreedConfig.LEVEL_SCALE_PER_LEVEL = 0.05
BreedConfig.RARITY_BOOST = {
	Common = 1.00,
	Uncommon = 1.00,
	Gem = 1.05,
	Ruby = 1.10,
	Diamond = 1.15,
	Cosmic = 1.15,
} :: Types.ByRarity<number>

-- Rarity order, lowest to highest. Cosmic is never bred.
local RARITY_ORDER: { Types.Rarity } = { "Common", "Uncommon", "Gem", "Ruby", "Diamond" }
BreedConfig.RARITY_ORDER = RARITY_ORDER
-- Chance the child gets a gem tier: both parents have it (or better) / only one does.
BreedConfig.RARITY_INHERIT = {
	Gem = { both = 0.40, one = 0.10 },
	Ruby = { both = 0.40, one = 0.08 },
	Diamond = { both = 0.30, one = 0.05 },
} :: {
	Gem: InheritOdds,
	Ruby: InheritOdds,
	Diamond: InheritOdds,
	Common: InheritOdds?,
	Uncommon: InheritOdds?,
	Cosmic: InheritOdds?,
}

-- Breeding Candy (working name): every breed uses up candies, earned only through play.
-- Never sold for Robux or Gems. There is no limit on how many times a creature can breed
-- (Ayrton, 16 November 2026): candy income is what caps supply.
-- Candy is typed (Ayrton, 20 November 2026): each parent uses CANDY_COST[its own rarity] of its
-- own type (its torso's element), so a breed of two different types needs two kinds of candy.
-- Typed candy comes from catching and releasing; Prism Candy covers any shortfall
-- (EconomyConfig, Economy.candyPayment). Tuned by tests/economy.test.luau (docs/ECONOMY_MODEL.md).
BreedConfig.CANDY_COST =
	{ Common = 1, Uncommon = 2, Gem = 5, Ruby = 12, Diamond = 30, Cosmic = 0 } :: Types.ByRarity<number>

-- Cooldown (seconds) after each breed. Breeds beyond the list use the last entry.
local MIN, HOUR = 60, 3600
BreedConfig.COOLDOWN = {
	Common = { 30 * MIN, 1 * HOUR, 2 * HOUR, 4 * HOUR, 8 * HOUR },
	Uncommon = { 30 * MIN, 1 * HOUR, 2 * HOUR, 4 * HOUR, 8 * HOUR },
	Gem = { 12 * HOUR, 24 * HOUR },
	Ruby = { 24 * HOUR, 48 * HOUR },
	Diamond = { 48 * HOUR, 72 * HOUR },
	Cosmic = {},
} :: Types.ByRarity<{ number }>
BreedConfig.HATCH_SECONDS = {
	Common = 30 * MIN,
	Uncommon = 45 * MIN,
	Gem = 4 * HOUR,
	Ruby = 8 * HOUR,
	Diamond = 12 * HOUR,
	Cosmic = 0,
} :: Types.ByRarity<number>

-- Cost = BASE x biome tier x rarity multiplier x average count multiplier.
BreedConfig.COST_BASE = 400 -- about 4 minutes of biome-1 coin income
BreedConfig.COST_RARITY = {
	Common = 1,
	Uncommon = 1.5,
	Gem = 4,
	Ruby = 10,
	Diamond = 25,
	Cosmic = 0,
} :: Types.ByRarity<number>
BreedConfig.COST_COUNT = { 1, 1.25, 1.5, 2, 2.5 } -- indexed by breeds already done + 1; later breeds use the last entry

-- Colours. Recessive colours only show when both copies match.
BreedConfig.COLOURS = {
	Moss = { recessive = false },
	Bark = { recessive = false },
	Sand = { recessive = false },
	Ember = { recessive = true },
	Frostbite = { recessive = true },
	Starlight = { recessive = true },
} :: { [string]: { recessive: boolean } }
BreedConfig.MUTATION_COLOURS = { "Ember", "Frostbite", "Starlight" }

return BreedConfig
