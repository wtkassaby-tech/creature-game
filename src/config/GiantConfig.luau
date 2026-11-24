--!strict
-- Giant fight numbers (research/market/07_BATTLE_AND_PVP.md recommendation 5; all Defaults).
-- A giant's own data (src/content/giant_data) may override the enrage numbers; these are the fallbacks.

local GiantConfig = {}

-- At most this many items in one fight, so stocking up matters but cannot replace a good team.
GiantConfig.MAX_ITEMS = 5

-- Enrage: from this turn on the giant's damage rises by ENRAGE_STEP every turn, up to ENRAGE_MAX.
-- multiplier = min(ENRAGE_MAX, 1 + ENRAGE_STEP x (turn - ENRAGE_TURN + 1))
GiantConfig.ENRAGE_TURN = 30
GiantConfig.ENRAGE_STEP = 0.15
GiantConfig.ENRAGE_MAX = 4

-- A wind-up attack that the right type "halves" does this share of its damage.
GiantConfig.HALVE_SHARE = 0.5

-- Guide for authors: giant health is about this many times the combined health of an on-level team.
GiantConfig.HEALTH_TEAM_MULTIPLIER = 2.5

-- Safety stop. Enrage always ends a fight long before this; at the cap the giant wins.
GiantConfig.MAX_TURNS = 80

-- Phases are entered when the giant's health share falls to the phase's `enterAt`.
-- Authors give 1.0, 0.6 and 0.25 (research recommendation 5); the validator only needs them in falling order.
GiantConfig.PHASE_THRESHOLDS = { 1, 0.6, 0.25 }

return GiantConfig
