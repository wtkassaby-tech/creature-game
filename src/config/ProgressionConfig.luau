--!strict
-- Every experience and level number in one place (rule: no hard-coded balance numbers).
-- All values are [Default]s from the pacing targets in docs/DECISIONS.md and
-- research/market/02_STRUCTURE_AND_COMPETITORS.md section 6. Tune them from playtest data.

local Types = require("../shared/Types")

export type KindMultipliers = {
	Wild: number,
	Tamer: number,
	Rival: number,
	Gate: number,
	Giant: number,
}

local ProgressionConfig = {}

-- Level curve: XP to go from level L to L + 1 is floor(CURVE_BASE x L ^ CURVE_EXPONENT).
-- A low base keeps the first levels quick (a new player sees a level-up within two or three
-- fights); an exponent above 1 steepens the curve smoothly, with no jumps.
ProgressionConfig.CURVE_BASE = 14
ProgressionConfig.CURVE_EXPONENT = 1.6
ProgressionConfig.MAX_LEVEL = 100

-- Level cap: CAP_BASE with no badge, then CAP_STEP more for each badge held.
ProgressionConfig.CAP_BASE = 15
ProgressionConfig.CAP_STEP = 10

-- XP paid for one defeated creature, before the share and gap rules below:
--   (REWARD_FLAT + REWARD_PER_LEVEL x defeatedLevel) x kind x rarity
ProgressionConfig.REWARD_FLAT = 8
ProgressionConfig.REWARD_PER_LEVEL = 6

-- A tamer's team pays per creature, so a tamer is a multiple of this per creature. The gate and
-- rival are tuned slightly above a tamer; a giant is one creature that pays like a long fight.
local KIND_MULTIPLIER: KindMultipliers = {
	Wild = 1,
	Tamer = 1.25,
	Rival = 1.5,
	Gate = 1.5,
	Giant = 8,
}
ProgressionConfig.KIND_MULTIPLIER = KIND_MULTIPLIER

local RARITY_MULTIPLIER: Types.ByRarity<number> = {
	Common = 1,
	Uncommon = 1.2,
	Gem = 1.5,
	Ruby = 2,
	Diamond = 3,
	Cosmic = 5,
}
ProgressionConfig.RARITY_MULTIPLIER = RARITY_MULTIPLIER

-- Fainted team members still get this share of the full amount.
ProgressionConfig.FAINTED_SHARE = 0.5

-- Level gap rule, worked out per receiving creature: gap = receiver's level - defeated level.
--  - Up to GAP_FREE levels above the opponent pays in full.
--  - Each level beyond that takes GAP_PENALTY_STEP off, down to a floor of GAP_MIN_FACTOR.
--  - An opponent above the receiver adds GAP_BONUS_STEP per level, up to GAP_MAX_FACTOR.
ProgressionConfig.GAP_FREE = 2
ProgressionConfig.GAP_PENALTY_STEP = 0.12
ProgressionConfig.GAP_MIN_FACTOR = 0.05
ProgressionConfig.GAP_BONUS_STEP = 0.05
ProgressionConfig.GAP_MAX_FACTOR = 1.3

return ProgressionConfig
