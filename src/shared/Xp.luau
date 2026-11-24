--!strict
-- Experience, levels and level caps. Pure rules: nothing here touches the Roblox engine.
-- Numbers come from ProgressionConfig. A creature's `xp` is progress toward its next level; it
-- keeps growing while the level cap holds the level still, and is spent when the cap rises.

local BattleConfig = require("../config/BattleConfig")
local ProgressionConfig = require("../config/ProgressionConfig")
local Stats = require("./Stats")
local Types = require("./Types")

export type OpponentKind = "Wild" | "Tamer" | "Rival" | "Gate" | "Giant"
export type Defeated = { level: number, rarity: Types.Rarity, kind: OpponentKind }
export type TeamMember = { level: number, fainted: boolean }
export type Applied = { level: number, xp: number, levelsGained: number }

local Xp = {}

-- Ranked play scales everyone to this level; it lives in BattleConfig and is re-exported here.
Xp.RANKED_LEVEL = BattleConfig.RANKED_LEVEL

-- XP to go from `level` to `level + 1`.
function Xp.xpToNext(level: number): number
	local l = math.max(1, math.floor(level))
	return math.floor(ProgressionConfig.CURVE_BASE * l ^ ProgressionConfig.CURVE_EXPONENT)
end

-- Total XP from level 1 to reach `level` (level 1 needs none).
function Xp.totalXpForLevel(level: number): number
	local total = 0
	for l = 1, math.floor(level) - 1 do
		total += Xp.xpToNext(l)
	end
	return total
end

-- The highest level a creature can fight at, set by the number of badges held.
function Xp.levelCap(badges: number): number
	local count = math.max(0, math.floor(badges))
	return math.min(
		ProgressionConfig.MAX_LEVEL,
		ProgressionConfig.CAP_BASE + ProgressionConfig.CAP_STEP * count
	)
end

-- How much of the full reward a receiver gets, given how far above or below the defeated creature it is.
function Xp.gapFactor(receiverLevel: number, defeatedLevel: number): number
	local gap = receiverLevel - defeatedLevel
	if gap > ProgressionConfig.GAP_FREE then
		local factor = 1 - (gap - ProgressionConfig.GAP_FREE) * ProgressionConfig.GAP_PENALTY_STEP
		return math.max(ProgressionConfig.GAP_MIN_FACTOR, factor)
	end
	if gap < 0 then
		return math.min(
			ProgressionConfig.GAP_MAX_FACTOR,
			1 - gap * ProgressionConfig.GAP_BONUS_STEP
		)
	end
	return 1
end

-- The full reward for one defeated creature, before the gap rule and the fainted share.
function Xp.baseReward(defeated: Defeated): number
	local raw = ProgressionConfig.REWARD_FLAT + ProgressionConfig.REWARD_PER_LEVEL * defeated.level
	return raw
		* ProgressionConfig.KIND_MULTIPLIER[defeated.kind]
		* ProgressionConfig.RARITY_MULTIPLIER[defeated.rarity]
end

-- XP one creature earns from one defeated creature. Whole numbers, at least 1.
function Xp.rewardFor(defeated: Defeated, receiver: TeamMember): number
	local amount = Xp.baseReward(defeated) * Xp.gapFactor(receiver.level, defeated.level)
	if receiver.fainted then
		amount *= ProgressionConfig.FAINTED_SHARE
	end
	return math.max(1, math.floor(amount + 0.5))
end

-- One entry per team member, in team order: the whole team shares the win.
function Xp.teamShares(defeated: Defeated, team: { TeamMember }): { number }
	local shares: { number } = {}
	for _, member in team do
		table.insert(shares, Xp.rewardFor(defeated, member))
	end
	return shares
end

-- Adds XP to a creature. Levels rise while XP covers the next step and the level is under the cap.
-- At the cap the XP keeps building, up to BANK_MAX_LEVELS levels' worth above the cap; XP beyond
-- that is dropped. Pass the new cap later to spend the bank.
function Xp.applyXp(level: number, xp: number, gained: number, cap: number): Applied
	local current = math.floor(level)
	local pool = xp + math.max(0, gained)
	local limit = math.min(cap, ProgressionConfig.MAX_LEVEL)
	local startLevel = current
	while current < limit do
		local need = Xp.xpToNext(current)
		if pool < need then
			break
		end
		pool -= need
		current += 1
	end
	if current >= limit then
		local bankMax = 0
		for i = 0, ProgressionConfig.BANK_MAX_LEVELS - 1 do
			bankMax += Xp.xpToNext(current + i)
		end
		pool = math.min(pool, bankMax)
	end
	return { level = current, xp = pool, levelsGained = current - startLevel }
end

-- The level a creature fights at: its own level, held down to the cap.
function Xp.battleLevel(level: number, cap: number): number
	return math.min(level, cap)
end

-- The level of a newborn: the computed level, kept between 1 and the player's cap.
function Xp.birthLevel(computed: number, cap: number): number
	return math.max(1, math.min(math.floor(computed), math.max(1, cap)))
end

-- Moves that unlocked after `oldLevel` up to and including `newLevel`, in pool order.
function Xp.newMoves(creature: Types.Creature, oldLevel: number, newLevel: number): { string }
	local before = Stats.movePool(creature, oldLevel)
	local fresh: { string } = {}
	for _, name in Stats.movePool(creature, newLevel) do
		if not table.find(before, name) then
			table.insert(fresh, name)
		end
	end
	return fresh
end

return Xp
