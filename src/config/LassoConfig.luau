--!strict
-- Lasso mini-game numbers (research/market/07_BATTLE_AND_PVP.md section 6; every value is a
-- [Default] to tune in playtests). Widths are fractions of the 0..1 arc; speeds are arc lengths per
-- second (a speed of 1 sweeps from one end to the other in one second); times are milliseconds.
-- Tier ids match the shop's ids; prices live elsewhere, not here.

local LassoConfig = {}

-- Zone width = BASE_WIDTH[rarity] / difficulty x healthFactor x TIER_WIDTH x (giant? GIANT_WIDTH).
LassoConfig.BASE_WIDTH = {
	Common = 0.30,
	Uncommon = 0.26,
	Gem = 0.21,
	Ruby = 0.17,
	Diamond = 0.14,
	Cosmic = 0.11,
}

-- Health factor = FULL + (EMPTY - FULL) x (1 - health)^EXPONENT.
-- At full health the zone is 5% of its base: for a common creature and a basic lasso that is 0.015
-- of the arc, a pass of about 17 ms, which is not worth trying. At 20% health the factor is about 0.73.
LassoConfig.HEALTH_FACTOR_FULL = 0.05
LassoConfig.HEALTH_FACTOR_EMPTY = 1.0
LassoConfig.HEALTH_FACTOR_EXPONENT = 1.5

LassoConfig.MIN_WIDTH = 0.01 -- no zone is ever thinner than this
LassoConfig.MAX_WIDTH = 0.6 -- or wider than this
LassoConfig.MIN_DIFFICULTY = 0.5 -- guards the division

-- Better lassos widen the zone and slow the marker (the same game made easier, never a hidden chance).
LassoConfig.TIER_WIDTH = { Basic = 1.0, Braided = 1.25, Gilded = 1.5 }
LassoConfig.TIER_SPEED = { Basic = 1.0, Braided = 0.85, Gilded = 0.7 }

-- Sweep speed.
LassoConfig.BASE_SPEED = 0.9
LassoConfig.SPEED_JITTER = 0.10 -- each zone's speed varies by up to this share, from the seed
LassoConfig.SLOW_MODE_SPEED = 0.70 -- accessibility: marker 30% slower, zone unchanged

-- Zone count: the larger of the rarity's count and the difficulty's count. Giants always have 3.
LassoConfig.ZONES_BY_RARITY =
	{ Common = 1, Uncommon = 1, Gem = 2, Ruby = 2, Diamond = 3, Cosmic = 3 }
LassoConfig.TWO_ZONE_DIFFICULTY = 1.6
LassoConfig.THREE_ZONE_DIFFICULTY = 2.5
LassoConfig.GIANT_ZONES = 3
LassoConfig.GIANT_WIDTH = 0.7 -- giant zones are narrower
LassoConfig.GIANT_SPEED_STEPS = { 1.0, 1.45, 0.8 } -- speed change between a giant's zones

-- Layout in time and on the arc.
LassoConfig.ZONE_GAP_MS = 3000 -- zone n starts this long after zone n-1
LassoConfig.MAX_ATTEMPT_MS = 14000 -- a claim later than this is invalid (no waiting for a lucky pass)
LassoConfig.CENTRE_MARGIN = 0.08 -- a zone's edge stays at least this far from either end of the arc

-- Lag window: serverElapsed - min(roundTrip, cap) <= claimed <= serverElapsed + margin.
LassoConfig.ROUND_TRIP_CAP_MS = 400
LassoConfig.CLAIM_MARGIN_MS = 60
-- Above the cap the sweep slows by cap / roundTrip (never below this floor) and the screen shows
-- a "connection assist" note.
LassoConfig.ASSIST_MIN_SPEED = 0.4
-- Slow mode and the connection assist together never slow the marker below this share of normal.
LassoConfig.MIN_TOTAL_SPEED = 0.4
-- The server measures each player's round trip itself, several times during a battle, and trusts
-- the smallest reading: a player can delay a reply but cannot make one arrive early.
-- With fewer readings than this the allowance is the default below.
LassoConfig.ROUND_TRIP_MIN_SAMPLES = 3
LassoConfig.ROUND_TRIP_DEFAULT_MS = 120

-- Timing audit: flag an account when this share of its last SAMPLES throws landed within TINY_MS
-- of the zone centre. A human with a 60 ms spread lands about 13% of throws that close.
LassoConfig.SCRIPTED_MIN_SAMPLES = 30
LassoConfig.SCRIPTED_TINY_MS = 10
LassoConfig.SCRIPTED_TINY_SHARE = 0.8

-- Misses a wild creature allows before it flees. 0 means it never flees.
LassoConfig.FLEE_AFTER_MISSES =
	{ Common = 0, Uncommon = 0, Gem = 4, Ruby = 3, Diamond = 2, Cosmic = 2 }

return LassoConfig
