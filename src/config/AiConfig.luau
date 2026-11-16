--!strict
-- Numbers for the computer opponents' decisions (src/shared/BattleAi.luau). All Defaults to tune in playtests.

local AiConfig = {}

-- Wild: simple. A fixed rotation of move positions (1 = its first move), used when no Rng is passed.
-- Mostly the first move, now and then another. A position past the end of the move list wraps round.
AiConfig.WILD_ROTATION = { 1, 1, 1, 2, 1, 1, 3, 1, 1, 4 }
-- Wild with a seeded Rng: the chance it uses its first move; otherwise it picks one of the others.
AiConfig.WILD_FIRST_MOVE_CHANCE = 0.7

-- Tamer: switching. A match-up score runs from -1 (hopeless) to 1 (winning): the share of the foe's
-- health our best move takes, minus the share of ours its best move takes (both capped at 1).
-- The tamer switches only when the active creature scores below -SWITCH_DISADVANTAGE and a team-mate
-- scores at least SWITCH_MARGIN better.
AiConfig.SWITCH_DISADVANTAGE = 0.3
AiConfig.SWITCH_MARGIN = 0.65
-- After a switch, no further switch for this many turns, so at most one switch in any three turns.
AiConfig.SWITCH_COOLDOWN_TURNS = 3

-- Rival: scoring one turn ahead. Damage shares are fractions of a creature's full health.
AiConfig.KNOCKOUT_BONUS = 0.6 -- added when the move knocks the foe out
AiConfig.FAINT_PENALTY = 0.6 -- taken off when our creature would be knocked out
-- A rescue costs a turn, so it is only worth it for a creature with at least this share of its health.
AiConfig.RESCUE_MIN_HEALTH_SHARE = 0.5
-- A switch must beat the best move by this much (scores are shares of full health), counting
-- RIVAL_MATCHUP_WEIGHT times the match-up improvement it brings.
AiConfig.RIVAL_SWITCH_EDGE = 0.6
AiConfig.RIVAL_MATCHUP_WEIGHT = 0.3

return AiConfig
