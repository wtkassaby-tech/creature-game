--!strict
-- Battle numbers (research/market/07_BATTLE_AND_PVP.md; all Defaults to tune in playtests).

local BattleConfig = {}

BattleConfig.MAX_MOVES = 4

-- damage = DAMAGE_SCALE x levelScale(attacker level) x power x Attack / (Attack + Defence) x type x own-type x variance
-- Bounded: a huge Attack can at most double the damage of an even match-up.
BattleConfig.DAMAGE_SCALE = 0.95

-- Fights against the game have a little variance; ranked has none. No misses, no critical hits.
BattleConfig.PVE_VARIANCE_MIN = 0.96

-- Turn order and what Speed is worth.
-- Strict "faster always goes first" makes a 1% Speed edge decide a mirror match, and makes Speed
-- worthless beyond that first strike (research/market/09). Two rules replace it:
--  1. Speed band: when the two Speeds are within this share of each other, both moves land
--     together, so a hair's-breadth edge gives nothing. Outside the band the faster side goes first.
--  2. Tempo: each turn the faster creature fills a Tempo meter by (its Speed / the other's - 1) x TEMPO_GAIN.
--     When the meter is full it strikes again at TEMPO_POWER. Twice as fast means an extra strike
--     about every other turn; 1% faster means one after a hundred turns. No dice involved.
BattleConfig.SPEED_BAND = 0.35
BattleConfig.TEMPO_GAIN = 1.0
BattleConfig.TEMPO_POWER = 0.5

BattleConfig.MAX_TURNS = 60 -- safety stop; the side with more health left wins
BattleConfig.RANKED_LEVEL = 50

return BattleConfig
