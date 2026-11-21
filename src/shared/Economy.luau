--!strict
-- Pure economy rules over src/config/EconomyConfig: battle rewards, prices, release payouts,
-- typed and Prism candy, how a breed's candy is paid, and a small ledger. No Roblox services, so it is tested under Lune
-- (tests/economy.test.luau). The model behind the numbers is docs/ECONOMY_MODEL.md.

local EconomyConfig = require("../config/EconomyConfig")
local TypeChart = require("./TypeChart")
local Types = require("./Types")

export type BattleKind = EconomyConfig.BattleKind
export type ItemId = EconomyConfig.ItemId
export type CandySource = EconomyConfig.CandySource
export type Currency = EconomyConfig.Currency
export type MaterialId = EconomyConfig.MaterialId

export type CandyWallet = Types.CandyWallet
export type CandyNeed = Types.CandyNeed
-- How a breed's candy is paid: what comes out of each typed balance, and the Prism that covers
-- the rest. Worked out by Economy.candyPayment, applied by Economy.payCandy.
export type CandyPayment = { typed: { CandyNeed }, prism: number }

export type Balances = { coins: number, candy: CandyWallet }
export type LedgerRecord = {
	flow: string,
	currency: Currency,
	element: Types.Element?, -- typed candy only
	direction: "In" | "Out",
	amount: number,
	before: number, -- the balance this flow moved: coins, Prism, or (typed) that type's candy
	after: number,
	prismUsed: number, -- typed candy spends only: the Prism that covered a shortfall
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
		local oneTime = clampIndex(EconomyConfig.ONE_TIME_MULT, biome)
			* Economy.levelFactor(biome, level)
		return math.floor(rule.firstClear * oneTime)
	elseif priorWinsToday < rule.rematchesPaidPerDay then
		local coins = math.floor(rule.rematch * scale)
		if kind == "Giant" then
			-- A rematch must cost more than it pays, in every biome and at every level: it is a
			-- coin sink that earns candy. (Greenwood's cheaper horn would otherwise turn a profit.)
			local horn = Economy.itemPrice("GiantCall", biome)
			coins = math.min(coins, math.floor(horn * EconomyConfig.GIANT_REMATCH_MAX_HORN_SHARE))
		end
		return coins
	end
	return 0
end

-- Coin price of an item. Biome is the hub's biome (only some items scale with it).
function Economy.itemPrice(item: ItemId, biome: number): number
	local def = EconomyConfig.ITEMS[item]
	if biome <= 1 and def.firstBiomePrice then
		return def.firstBiomePrice
	elseif def.scalesWithBiome then
		return def.price * Economy.biomeMult(biome)
	end
	return def.price
end

-- Giant Horns are graded by the biome they were priced for: a horn wakes the giant of its own
-- biome or an earlier one, never a later one. Without this, cheap horns bought early could be
-- saved up and used on later giants, whose rematches pay more than those horns cost.
-- Grade 1 is plain "GiantCall"; later grades are "GiantCall_2", "GiantCall_3", and so on.
function Economy.hornKey(grade: number): string
	local whole = math.max(1, math.floor(grade))
	return if whole == 1 then "GiantCall" else `GiantCall_{whole}`
end

-- Where a giant's own candy is kept among the player's items, by the species name of the
-- giant's creature form ("GiantCandy_Hollowbough").
function Economy.giantCandyKey(species: string): string
	return `GiantCandy_{species}`
end

-- The cheapest horn the player holds that can wake a giant of this biome, or nil.
function Economy.hornFor(items: { [string]: number }, biome: number): string?
	for grade = math.max(1, math.floor(biome)), #EconomyConfig.BIOME_MULT do
		local key = Economy.hornKey(grade)
		if (items[key] or 0) >= 1 then
			return key
		end
	end
	return nil
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
	for _, item: ItemId in fieldItems do
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
	local materialIndex = math.clamp(math.floor(originBiome), 1, #EconomyConfig.MATERIAL_BY_BIOME)
	local material: MaterialId = EconomyConfig.MATERIAL_BY_BIOME[materialIndex]
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

------------------------------------------------------------------------------------------------
-- Typed candy
------------------------------------------------------------------------------------------------

function Economy.zeroByElement(): Types.ByElement<number>
	return {
		Leaf = 0,
		Sand = 0,
		Water = 0,
		Toxic = 0,
		Frost = 0,
		Crystal = 0,
		Fire = 0,
		Storm = 0,
		Arcane = 0,
		Cosmic = 0,
	}
end

function Economy.emptyWallet(): CandyWallet
	return { typed = Economy.zeroByElement(), prism = 0 }
end

function Economy.copyWallet(wallet: CandyWallet): CandyWallet
	return { typed = table.clone(wallet.typed), prism = wallet.prism }
end

-- Every typed balance plus Prism.
function Economy.walletTotal(wallet: CandyWallet): number
	local total = wallet.prism
	for _, element: Types.Element in TypeChart.ELEMENTS do
		total += wallet.typed[element]
	end
	return total
end

-- Share of full pay for a typed claim, given claims of that type already paid today.
function Economy.candyFalloff(rule: EconomyConfig.CandyFalloff, priorToday: number): number
	if priorToday < rule.full then
		return 1
	elseif priorToday >= rule.stop then
		return 0
	end
	return math.max(rule.floor, rule.rate ^ (priorToday - rule.full + 1))
end

-- Whole candies for the next claim. The day's claims of a type add up as fractions and each
-- claim pays the whole candies its share completes, so a falloff of 0.25 pays one candy every
-- fourth claim instead of rounding to nothing. The same counts always give the same answer.
local function fallingCandy(
	base: number,
	rule: EconomyConfig.CandyFalloff,
	priorToday: number
): number
	if base <= 0 or priorToday < 0 or priorToday ~= math.floor(priorToday) then
		return 0
	end
	local before = 0
	for index = 0, math.min(priorToday, rule.stop) - 1 do
		before += Economy.candyFalloff(rule, index)
	end
	local after = before + Economy.candyFalloff(rule, priorToday)
	-- A small allowance stops 0.1 + 0.2 style float sums from losing a candy.
	return math.floor(base * after + 1e-9) - math.floor(base * before + 1e-9)
end

-- Typed candy for catching a creature of this rarity. priorToday: catches of that creature's
-- type already paid today (the count goes up by one with every catch, paid or not).
function Economy.catchCandy(rarity: Types.Rarity, priorToday: number): number
	return fallingCandy(EconomyConfig.CATCH_CANDY[rarity], EconomyConfig.CATCH_FALLOFF, priorToday)
end

-- Typed candy for releasing a creature of this rarity. priorToday: releases of that type today.
function Economy.releaseCandy(rarity: Types.Rarity, priorToday: number): number
	return fallingCandy(
		EconomyConfig.RELEASE_CANDY[rarity],
		EconomyConfig.RELEASE_FALLOFF,
		priorToday
	)
end

-- How a wallet pays a breed's candy: typed candy of each type first, then Prism for every
-- shortfall. Returns nil if the wallet cannot pay all of it, or if a need is not a positive whole
-- number. Never changes the wallet.
function Economy.candyPayment(wallet: CandyWallet, needs: { CandyNeed }): CandyPayment?
	local typed: { CandyNeed } = {}
	local prism = 0
	local seen: { Types.Element } = {}
	for _, need in needs do
		local amount = need.amount
		if
			amount ~= amount
			or amount <= 0
			or amount ~= math.floor(amount)
			or amount == math.huge
		then
			return nil
		end
		if table.find(seen, need.element) then
			return nil -- one entry per type, as Breeding.candyCost builds it
		end
		table.insert(seen, need.element)
		local fromTyped = math.min(wallet.typed[need.element], amount)
		if fromTyped > 0 then
			table.insert(typed, { element = need.element, amount = fromTyped })
		end
		prism += amount - fromTyped
	end
	if prism > wallet.prism then
		return nil
	end
	return { typed = typed, prism = prism }
end

-- The wallet after a payment from Economy.candyPayment (a new table; the old one is unchanged).
-- Returns nil if the payment does not fit the wallet.
function Economy.payCandy(wallet: CandyWallet, payment: CandyPayment): CandyWallet?
	local nextWallet = Economy.copyWallet(wallet)
	for _, part in payment.typed do
		nextWallet.typed[part.element] -= part.amount
		if nextWallet.typed[part.element] < 0 then
			return nil
		end
	end
	nextWallet.prism -= payment.prism
	if nextWallet.prism < 0 then
		return nil
	end
	return nextWallet
end

------------------------------------------------------------------------------------------------
-- Prism Candy and the other capped sources
------------------------------------------------------------------------------------------------

-- Prism Candy the next claim from a source grants.
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
	return EconomyConfig.QUEST_LINE_COINS * clampIndex(EconomyConfig.ONE_TIME_MULT, biome)
end

-- Daily tasks (and their candy) open once the player holds enough badges.
function Economy.dailyTasksOpen(badges: number): boolean
	return badges >= EconomyConfig.DAILY_TASKS_UNLOCK_BADGES
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
	matchmade: boolean,
	furthestBiome: number
): number
	if
		repeatOpponent
		or not matchmade
		or paidWinsToday >= EconomyConfig.CASUAL_PVP_PAID_WINS_PER_DAY
	then
		return 0
	end
	return EconomyConfig.CASUAL_PVP_WIN_COINS * Economy.biomeMult(furthestBiome)
end

-- Price of the next coin-bought stable expansion, or nil when none are left.
function Economy.stableExpansionPrice(alreadyBought: number): number?
	return EconomyConfig.STABLE_EXPANSION_COINS[alreadyBought + 1]
end

-- Price of the next stable decoration, or nil when the player owns them all.
function Economy.decorPrice(alreadyOwned: number): number?
	return EconomyConfig.DECOR_COINS[alreadyOwned + 1]
end

function Economy.stableSlots(coinExpansions: number, gemExpansions: number): number
	return EconomyConfig.STABLE_FREE_SLOTS
		+ (coinExpansions + gemExpansions) * EconomyConfig.STABLE_EXPANSION_SLOTS
end

-- Apply one named flow to the balances. Sources add, sinks subtract. Typed candy flows need the
-- element; a typed candy sink ("BreedCandy") takes that type's candy first and Prism for the rest.
-- Refuses an unknown flow, a missing element, an amount that is not a positive whole number, or a
-- sink that would take a balance below zero. Never changes the table passed in.
function Economy.apply(
	balances: Balances,
	flowName: string,
	amount: number,
	element: Types.Element?
): LedgerResult
	local flow = EconomyConfig.FLOWS[flowName]
	if flow == nil then
		return { ok = false, balances = balances, reason = `unknown flow {flowName}` }
	end
	if amount ~= amount or amount <= 0 or amount ~= math.floor(amount) or amount == math.huge then
		return { ok = false, balances = balances, reason = "amount must be a positive whole number" }
	end
	local isSink = flow.limit == "Sink"
	local candy = Economy.copyWallet(balances.candy)
	local coins = balances.coins
	local before, after, prismUsed = 0, 0, 0
	if flow.currency == "Coins" then
		before = coins
		after = if isSink then before - amount else before + amount
		coins = after
	elseif flow.currency == "Prism" then
		before = candy.prism
		after = if isSink then before - amount else before + amount
		candy.prism = after
	else
		if element == nil or candy.typed[element] == nil then
			return { ok = false, balances = balances, reason = "typed candy needs an element" }
		end
		before = candy.typed[element]
		if isSink then
			local fromTyped = math.min(before, amount)
			prismUsed = amount - fromTyped
			after = before - fromTyped
			candy.prism -= prismUsed
			if candy.prism < 0 then
				return { ok = false, balances = balances, reason = `not enough {element} candy` }
			end
		else
			after = before + amount
		end
		candy.typed[element] = after
	end
	if after < 0 then
		return { ok = false, balances = balances, reason = `not enough {flow.currency}` }
	end
	local record: LedgerRecord = {
		flow = flowName,
		currency = flow.currency,
		element = if flow.currency == "Candy" then element else nil,
		direction = if isSink then "Out" else "In",
		amount = amount,
		before = before,
		after = after,
		prismUsed = prismUsed,
	}
	return { ok = true, balances = { coins = coins, candy = candy }, record = record }
end

return Economy
