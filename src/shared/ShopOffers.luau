--!strict
-- What the shop and the other screens may offer, as pure rules (plan 16 section 2 Placement and
-- section 6). The screens only draw what these functions return; the server decides again on every
-- request, so none of this is a gate, only what is worth showing.
--
-- Rules kept here:
--   * Nothing sold for Robux shows while the live switch is off (flags.Open false) or its Roblox id
--     is 0 (not created yet). A hidden-by-id count is returned so Studio can say why.
--   * The Lasso Pass and Gem lassos show only where paid random items are NOT restricted. Until the
--     flags arrive (nil) they stay hidden, as the server treats an unknown answer as restricted.
--   * An owned pass shows as owned (never offered again). The Starter Pack shows once.
--   * The stable-full offer lists the coin expansion first, then the pass, then the Starter Pack.
--   * An egg's "Finish now" is disabled, with the reason, when the stable has no room for it.

local Capture = require("./Capture")
local Economy = require("./Economy")
local EconomyConfig = require("../config/EconomyConfig")
local Gems = require("./Gems")
local PurchaseConfig = require("../config/PurchaseConfig")

local ShopOffers = {}

export type Flags = {
	Open: boolean,
	PaidRandomRestricted: boolean,
	TradingAllowed: boolean,
	LassoBoost: boolean,
}

export type PassOffer = {
	key: PurchaseConfig.PassId,
	name: string,
	line: string, -- what it does, in one line
	owned: boolean,
}
export type ProductOffer = {
	key: PurchaseConfig.ProductId,
	name: string,
	line: string,
	gems: number,
}
export type GemItemOffer = { item: EconomyConfig.ItemId, price: number, isLasso: boolean }
export type EggOffer = {
	hatchAt: number,
	secondsLeft: number,
	cost: number,
	canFinish: boolean,
	reason: string?, -- why it cannot be finished now
	needsGems: boolean, -- affordable only after buying Gems
}
export type RoomOffer = { kind: "CoinRoom" | "Pass" | "Product", key: string?, coins: number? }

local function has(list: { string }, key: string): boolean
	return table.find(list, key) ~= nil
end

-- Robux things appear only while the switch is on.
local function robuxOpen(flags: Flags?): boolean
	return flags ~= nil and flags.Open
end

-- One line saying what a pass does, worked out from its numbers so the text and the effect cannot
-- drift apart.
function ShopOffers.passLine(key: PurchaseConfig.PassId): string
	local def = PurchaseConfig.PASSES[key]
	local parts: { string } = {}
	if def.stableRoom > 0 then
		table.insert(parts, `+{def.stableRoom} stable room`)
	end
	if def.pens > 0 then
		table.insert(parts, `+{def.pens} egg pen`)
	end
	if def.hatchFactor < 1 then
		local times = math.floor(10 / def.hatchFactor + 0.5) / 10
		table.insert(parts, `eggs hatch {times}x faster`)
	end
	if def.stableAnywhere then
		table.insert(parts, "open the stable anywhere")
	end
	if def.lassoBoost then
		local percent = math.floor(PurchaseConfig.LASSO_PASS_BONUS * 100 + 0.5)
		table.insert(parts, `+{percent}% catch chance on common and uncommon wild creatures`)
	end
	if def.title then
		table.insert(parts, `a "{def.title}" title`)
	end
	local text = table.concat(parts, ", ")
	return string.upper(string.sub(text, 1, 1)) .. string.sub(text, 2)
end

-- True when a pass may be shown as something to buy (not counting whether it is already owned).
local function passForSale(key: PurchaseConfig.PassId, flags: Flags?): boolean
	local def = PurchaseConfig.PASSES[key]
	if not robuxOpen(flags) or def.id < 1 then
		return false
	end
	-- Hidden unless PolicyService has answered "not restricted" (nil flags: not answered).
	if def.lassoBoost and (flags :: Flags).PaidRandomRestricted ~= false then
		return false
	end
	return true
end

-- The passes to list, in order: each owned one as owned (unless it is the Lasso Pass and paid
-- random items are restricted: it does nothing there, so it is not shown at all), and each unowned
-- one that can be bought. `hiddenForId` counts passes hidden only because their id is 0.
function ShopOffers.passes(flags: Flags?, owned: { string }): ({ PassOffer }, number)
	local list: { PassOffer } = {}
	local hiddenForId = 0
	for _, key: PurchaseConfig.PassId in PurchaseConfig.PASS_IDS do
		local def = PurchaseConfig.PASSES[key]
		local isOwned = has(owned, key)
		local restrictedLasso = def.lassoBoost
			and (flags == nil or flags.PaidRandomRestricted ~= false)
		local show = false
		if isOwned then
			show = not restrictedLasso
		elseif passForSale(key, flags) then
			show = true
		elseif robuxOpen(flags) and def.id < 1 and not restrictedLasso then
			hiddenForId += 1
		end
		if show then
			table.insert(list, {
				key = key,
				name = def.name,
				line = ShopOffers.passLine(key),
				owned = isOwned,
			})
		end
	end
	return list, hiddenForId
end

-- Gem bundles that may be bought (kind "Gems"), smallest first.
function ShopOffers.bundles(flags: Flags?): ({ ProductOffer }, number)
	local list: { ProductOffer } = {}
	local hiddenForId = 0
	for _, key: PurchaseConfig.ProductId in PurchaseConfig.PRODUCT_IDS do
		local def = PurchaseConfig.PRODUCTS[key]
		if def.kind == "Gems" and robuxOpen(flags) then
			if def.id < 1 then
				hiddenForId += 1
			else
				table.insert(list, {
					key = key,
					name = `{def.gems} Gems`,
					line = "Gems buy time and room: faster eggs and Gem shop items",
					gems = def.gems,
				})
			end
		end
	end
	return list, hiddenForId
end

-- The Starter Pack, while it can be bought and has not been (perks lists "StarterPack" once
-- bought: the server writes the mark with the grant). Second value: hidden only for its id.
function ShopOffers.starter(flags: Flags?, boughtMarks: { string }): (ProductOffer?, number)
	local key: PurchaseConfig.ProductId = "StarterPack"
	local def = PurchaseConfig.PRODUCTS[key]
	if not robuxOpen(flags) or has(boughtMarks, PurchaseConfig.STARTER_PACK.onceKey) then
		return nil, 0
	end
	if def.id < 1 then
		return nil, 1
	end
	local room = PurchaseConfig.STARTER_PACK.stableRoom
	return {
		key = key,
		name = "Starter Pack",
		line = `{def.gems} Gems, +{room} stable room and a cosmetic. Once only`,
		gems = def.gems,
	},
		0
end

-- Consumables Gems buy, in shop order. Lassos only where paid random items are not restricted.
-- Nothing while the switch is off (the server refuses Gem buys then too).
function ShopOffers.gemItems(flags: Flags?, biomeReached: number): { GemItemOffer }
	local list: { GemItemOffer } = {}
	if not robuxOpen(flags) then
		return list
	end
	local lassoOk = (flags :: Flags).PaidRandomRestricted == false
	for _, item: EconomyConfig.ItemId in EconomyConfig.GEM_ITEM_IDS do
		local isLasso = table.find(EconomyConfig.LASSO_TIERS, item :: any) ~= nil
		local price = Gems.itemPrice(item)
		if price and Economy.itemAvailable(item, biomeReached) and (lassoOk or not isLasso) then
			table.insert(list, { item = item, price = price, isLasso = isLasso })
		end
	end
	return list
end

-- The key a Gem lasso is held under (a Gem lasso marks the catch).
function ShopOffers.gemLassoKey(item: EconomyConfig.ItemId): string
	return (item :: string) .. Capture.GEM_LASSO_SUFFIX
end

-- The egg cards: for each egg still to hatch, its price to finish and whether that can be done.
-- `room` mirrors the server (Grants.room): capacity minus creatures minus eggs that are ready
-- and waiting for a place. Eggs already ready get no offer. `eggs` are hatch times (seconds).
function ShopOffers.eggs(
	eggHatchTimes: { number },
	creatureCount: number,
	capacity: number,
	gems: number,
	now: number,
	flags: Flags?,
	inBattle: boolean
): { EggOffer }
	local list: { EggOffer } = {}
	if inBattle or not robuxOpen(flags) then
		return list
	end
	local waiting = 0
	for _, hatchAt in eggHatchTimes do
		if hatchAt <= now then
			waiting += 1
		end
	end
	local full = capacity - creatureCount - waiting < 1
	for _, hatchAt in eggHatchTimes do
		if hatchAt > now then
			local left = hatchAt - now
			local cost = Gems.eggFinishCost(left)
			table.insert(list, {
				hatchAt = hatchAt,
				secondsLeft = left,
				cost = cost,
				canFinish = not full,
				reason = if full then "Stable full: make room first" else nil,
				needsGems = gems < cost,
			})
		end
	end
	return list
end

-- The offers for a full stable, in the order they are shown: the coin expansion (while one is
-- left), then the Bigger Stable pass, then the Starter Pack (which carries room). Nothing when
-- the stable has a free place. `coinExpansionsBought` is how many coin expansions are held.
function ShopOffers.stableFull(
	creatureCount: number,
	capacity: number,
	coinExpansionsBought: number,
	flags: Flags?,
	ownedPasses: { string },
	boughtMarks: { string }
): { RoomOffer }
	local list: { RoomOffer } = {}
	if creatureCount < capacity then
		return list
	end
	local price = Economy.stableExpansionPrice(coinExpansionsBought)
	if price then
		table.insert(list, { kind = "CoinRoom", coins = price })
	end
	if not has(ownedPasses, "BiggerStable") and passForSale("BiggerStable", flags) then
		table.insert(list, { kind = "Pass", key = "BiggerStable" })
	end
	local starter = ShopOffers.starter(flags, boughtMarks)
	if starter then
		table.insert(list, { kind = "Product", key = starter.key :: string })
	end
	return list
end

-- The line on the first badge card. Gems earned are named only when the player holds some.
function ShopOffers.badgeLine(gems: number): string
	if gems > 0 then
		return "You earned Gems. See what they buy"
	end
	return "Gems buy time and room. See what they buy"
end

-- True when the first badge has just been earned: the badge count went from 0 to 1 between two
-- states of the same session. The first state of a session (previous nil) never counts.
function ShopOffers.firstBadgeJustEarned(previousBadges: number?, badges: number): boolean
	return previousBadges == 0 and badges == 1
end

-- The coin-expansion count from the saved numbers (the same sum the shop shows).
function ShopOffers.coinExpansions(capacity: number, stableBonus: number): number
	return math.max(
		0,
		(capacity - EconomyConfig.STABLE_FREE_SLOTS - stableBonus)
			// EconomyConfig.STABLE_EXPANSION_SLOTS
	)
end

return ShopOffers
