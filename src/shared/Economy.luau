--!strict
-- Pure economy rules over src/config/EconomyConfig: battle rewards, prices, release payouts,
-- candy claims and a small ledger. No Roblox services, so it is tested under Lune
-- (tests/economy.test.luau). The model behind the numbers is docs/ECONOMY_MODEL.md.

local EconomyConfig = require("../config/EconomyConfig")
local Types = require("./Types")

export type BattleKind = EconomyConfig.BattleKind
export type ItemId = EconomyConfig.ItemId
export type CandySource = EconomyConfig.CandySource
export type Currency = EconomyConfig.Currency
export type MaterialId = EconomyConfig.MaterialId

export type Balances = { coins: number, candy: number }
export type LedgerRecord = {
	flow: string,
	currency: Currency,
	direction: "In" | "Out",
	amount: number,
	before: number,
	after: number,
}
export type LedgerResult = {
	ok: boolean,
	balances: Balances, -- the new balances, or the old ones unchanged when refused
	record: LedgerRecord?,
	reason: string?,
}
export type ReleasePayout = { coins: number, material: MaterialId?, materials: number }

local Economy = {}

local function clampIndex<T>(list: { T }, index: number): T
	return list[math.clamp(math.floor(index), 1, #list)]
end

-- Coin multiplier for a biome (equal to Breeding.cost's biome tier).
function Economy.biomeMult(biome: number): number
	return clampIndex(EconomyConfig.BIOME_MULT, biome)
end

-- 1 at the biome's level floor, rising by LEVEL_STEP per level, clamped to the biome's band.
function Economy.levelFactor(biome: number, level: number): number
	local band = clampIndex(EconomyConfig.LEVEL_BANDS, biome)
	local over = math.clamp(level, band.min, band.max) - band.min
	return 1 + EconomyConfig.LEVEL_STEP * over
end

-- Share of the full wild reward paid for a win, given wins already taken against that kind today.
function Economy.diminishFactor(priorWinsToday: number): number
	if priorWinsToday < EconomyConfig.DIMINISH_FULL then
		return 1
	elseif priorWinsToday >= EconomyConfig.DIMINISH_STOP then
		return 0
	end
	local steps = priorWinsToday - EconomyConfig.DIMINISH_FULL + 1
	return math.max(EconomyConfig.DIMINISH_FLOOR, EconomyConfig.DIMINISH_RATE ^ steps)
end

-- Coins for a won battle.
-- priorWinsToday: for "Wild", wins already taken today against that kind of creature (a catch
-- counts); for the others, paid rematch wins already taken today against that opponent.
-- firstClear: the first ever win against that tamer, gate or giant (ignored for "Wild").
function Economy.battleCoins(
	kind: BattleKind,
	biome: number,
	level: number,
	priorWinsToday: number,
	firstClear: boolean
): number
	local scale = Economy.biomeMult(biome) * Economy.levelFactor(biome, level)
	if kind == "Wild" then
		return math.floor(EconomyConfig.WILD_BASE * scale * Economy.diminishFactor(priorWinsToday))
	end
	local rule = EconomyConfig.TRAINED[kind]
	if firstClear then
		return math.floor(rule.firstClear * scale)
	elseif priorWinsToday < rule.rematchesPaidPerDay then
		return math.floor(rule.rematch * scale)
	end
	return 0
end

-- Coin price of an item. Biome is the hub's biome (only some items scale with it).
function Economy.itemPrice(item: ItemId, biome: number): number
	local def = EconomyConfig.ITEMS[item]
	if def.scalesWithBiome then
		return def.price * Economy.biomeMult(biome)
	end
	return def.price
end

-- Whether a shop sells the item to a player whose furthest biome is this one.
function Economy.itemAvailable(item: ItemId, furthestBiome: number): boolean
	if item == "Bait" then
		return furthestBiome >= EconomyConfig.BAIT_MIN_BIOME
	end
	return true
end

-- Coins needed to prepare a giant attempt: one GiantCall plus the field items brought.
-- Returns nil if the field items break the cap or include a non-field item.
function Economy.giantPrepCost(biome: number, fieldItems: { ItemId }): number?
	if #fieldItems > EconomyConfig.GIANT_FIELD_ITEM_CAP then
		return nil
	end
	local total = Economy.itemPrice("GiantCall", biome)
	for _, item in fieldItems do
		if not EconomyConfig.ITEMS[item].fieldItem then
			return nil
		end
		total += Economy.itemPrice(item, biome)
	end
	return total
end

-- The coin value of one material: what it saves when crafted instead of buying the item.
-- A material no recipe uses is worth 0.
function Economy.materialValue(material: MaterialId): number
	local best = 0
	local recipes = EconomyConfig.RECIPES
	local function consider(item: ItemId, recipe: EconomyConfig.Recipe)
		if recipe.material == material then
			local saved = (Economy.itemPrice(item, 1) - recipe.coins) / recipe.count
			best = math.max(best, saved)
		end
	end
	consider("Tonic", recipes.Tonic)
	consider("GreatTonic", recipes.GreatTonic)
	consider("Bait", recipes.Bait)
	return best
end

-- The cheapest coin cost of catching a creature of this rarity: one throw of the minimum lasso.
function Economy.minCatchCost(rarity: Types.Rarity): number
	return Economy.itemPrice(EconomyConfig.LASSO_MIN_TIER[rarity], 1)
end

-- What releasing a creature pays. Coins plus materials (valued at their crafting value) never
-- reach RELEASE_MAX_SHARE of the cheapest way to obtain the creature; materials are dropped first
-- if they alone would break the cap.
function Economy.releasePayout(rarity: Types.Rarity, originBiome: number): ReleasePayout
	local ceiling = EconomyConfig.RELEASE_MAX_SHARE * Economy.minCatchCost(rarity)
	local material: MaterialId = clampIndex(EconomyConfig.MATERIAL_BY_BIOME, originBiome)
	local materials = EconomyConfig.RELEASE_MATERIALS[rarity]
	local materialWorth = materials * Economy.materialValue(material)
	if materialWorth + EconomyConfig.RELEASE_MIN_COINS > ceiling then
		materials, materialWorth = 0, 0
	end
	local raw = EconomyConfig.RELEASE_COINS[rarity] * Economy.biomeMult(originBiome)
	local coins = math.max(
		EconomyConfig.RELEASE_MIN_COINS,
		math.min(raw, math.floor(ceiling - materialWorth))
	)
	return {
		coins = coins,
		material = if materials > 0 then material else nil,
		materials = materials,
	}
end

-- Candy the next claim from a source grants.
-- claimed: claims already paid in this source's window (today for Daily, this week for Weekly,
-- ever for this key for Once: this giant, this biome's gate, this quest line).
-- biome: used by QuestLine only.
function Economy.candyFor(source: CandySource, claimed: number, biome: number?): number
	local def = EconomyConfig.CANDY[source]
	if claimed >= def.cap then
		return 0
	end
	if source == "QuestLine" then
		return clampIndex(EconomyConfig.QUEST_LINE_CANDY, biome or 1)
	end
	return def.perClaim
end

-- Coins for a completed quest line in a biome (once per line).
function Economy.questLineCoins(biome: number): number
	return EconomyConfig.QUEST_LINE_COINS * Economy.biomeMult(biome)
end

-- Coins for the next daily task, given how many of that kind were already paid today.
function Economy.dailyTaskCoins(hard: boolean, furthestBiome: number, claimedToday: number): number
	local source: CandySource = if hard then "DailyHardTask" else "DailyTask"
	if claimedToday >= EconomyConfig.CANDY[source].cap then
		return 0
	end
	local base = if hard
		then EconomyConfig.DAILY_HARD_TASK_COINS
		else EconomyConfig.DAILY_TASK_COINS
	return base * Economy.biomeMult(furthestBiome)
end

function Economy.weeklyChallengeCoins(furthestBiome: number, claimedThisWeek: number): number
	if claimedThisWeek >= EconomyConfig.CANDY.WeeklyChallenge.cap then
		return 0
	end
	return EconomyConfig.WEEKLY_CHALLENGE_COINS * Economy.biomeMult(furthestBiome)
end

-- Coins for a casual PvP win: only the first few matchmade wins a day, never a repeat opponent.
function Economy.casualPvpCoins(
	paidWinsToday: number,
	repeatOpponent: boolean,
	matchmade: boolean
): number
	if
		repeatOpponent
		or not matchmade
		or paidWinsToday >= EconomyConfig.CASUAL_PVP_PAID_WINS_PER_DAY
	then
		return 0
	end
	return EconomyConfig.CASUAL_PVP_WIN_COINS
end

-- Price of the next coin-bought stable expansion, or nil when none are left.
function Economy.stableExpansionPrice(alreadyBought: number): number?
	return EconomyConfig.STABLE_EXPANSION_COINS[alreadyBought + 1]
end

function Economy.stableSlots(coinExpansions: number, gemExpansions: number): number
	return EconomyConfig.STABLE_FREE_SLOTS
		+ (coinExpansions + gemExpansions) * EconomyConfig.STABLE_EXPANSION_SLOTS
end

-- Apply one named flow to the balances. Sources add, sinks subtract. Refuses an unknown flow,
-- an amount that is not a positive whole number, or a sink that would take a balance below zero.
-- Never changes the table passed in.
function Economy.apply(balances: Balances, flowName: string, amount: number): LedgerResult
	local flow = EconomyConfig.FLOWS[flowName]
	if flow == nil then
		return { ok = false, balances = balances, reason = `unknown flow {flowName}` }
	end
	if amount ~= amount or amount <= 0 or amount ~= math.floor(amount) or amount == math.huge then
		return { ok = false, balances = balances, reason = "amount must be a positive whole number" }
	end
	local isCoins = flow.currency == "Coins"
	local before = if isCoins then balances.coins else balances.candy
	local isSink = flow.limit == "Sink"
	local after = if isSink then before - amount else before + amount
	if after < 0 then
		return { ok = false, balances = balances, reason = `not enough {flow.currency}` }
	end
	local nextBalances: Balances = {
		coins = if isCoins then after else balances.coins,
		candy = if isCoins then balances.candy else after,
	}
	local record: LedgerRecord = {
		flow = flowName,
		currency = flow.currency,
		direction = if isSink then "Out" else "In",
		amount = amount,
		before = before,
		after = after,
	}
	return { ok = true, balances = nextBalances, record = record }
end

return Economy
