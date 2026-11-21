--!strict
-- Buying from a hub shop and using items in battle, as pure rules. Prices come from the economy
-- (src/shared/Economy); everything is paid in coins the player earned.

local BattleSession = require("./BattleSession")
local Economy = require("./Economy")
local EconomyConfig = require("../config/EconomyConfig")
local Grants = require("./Grants")
local Profile = require("./Profile")

export type Bought = { item: EconomyConfig.ItemId, count: number, coins: number }

local Shop = {}

Shop.MAX_PER_PURCHASE = 99
Shop.MAX_HELD = 999 -- of one item; keeps counts sane and inside what the device is sent

local function parseItem(value: unknown): EconomyConfig.ItemId?
	for _, item: EconomyConfig.ItemId in EconomyConfig.ITEM_IDS do
		if item == value then
			return item
		end
	end
	return nil
end

-- Buys `count` of an item. `item` and `count` come from the device; `atShop` is the server's
-- own check that the player is standing at a shop; `biome` is that shop's biome.
function Shop.buy(
	profile: Profile.Profile,
	item: unknown,
	count: unknown,
	atShop: boolean,
	biome: number
): (Bought?, string?)
	local id: EconomyConfig.ItemId? = parseItem(item)
	if not id then
		return nil, "The shop does not sell that"
	end
	if
		typeof(count) ~= "number"
		or count % 1 ~= 0
		or count < 1
		or count > Shop.MAX_PER_PURCHASE
	then
		return nil, "Bad amount"
	end
	if not atShop then
		return nil, "You are too far away"
	end
	if not Economy.itemAvailable(id, profile.Story.biomeReached) then
		return nil, "The shop does not sell that yet"
	end
	-- Items that cost more in later biomes are priced by how far the player has got, wherever
	-- they shop, so walking back to the first town is never a discount.
	local priceBiome = math.max(biome, profile.Story.biomeReached)
	local coins = math.floor(Economy.itemPrice(id, priceBiome)) * count
	-- A Giant Horn is kept by the grade it was priced at (Economy.hornKey).
	local key: string = if id == "GiantCall" then Economy.hornKey(priceBiome) else id
	local held = profile.Items[key] or 0
	if held + count > Shop.MAX_HELD then
		return nil, "You cannot carry any more of those"
	end
	if coins ~= coins or coins < 0 or profile.Coins < coins then
		return nil, "You do not have enough coins"
	end
	profile.Coins -= coins
	profile.Items[key] = held + count
	return { item = id, count = count, coins = coins }, nil
end

export type Craftable = "Tonic" | "GreatTonic" | "Bait"
local CRAFTABLE: { Craftable } = { "Tonic", "GreatTonic", "Bait" }

-- Makes one item from a biome's material and a few coins (EconomyConfig.RECIPES). `item` comes
-- from the device. It can be done anywhere: the materials are the cost.
function Shop.craft(profile: Profile.Profile, item: unknown): (Craftable?, string?)
	local id: Craftable? = nil
	for _, each: Craftable in CRAFTABLE do
		if each == item then
			id = each
		end
	end
	if not id then
		return nil, "That cannot be made"
	end
	if not Economy.itemAvailable(id, profile.Story.biomeReached) then
		return nil, "You do not know how to make that yet"
	end
	local recipe = EconomyConfig.RECIPES[id]
	local material: string = recipe.material
	local key: string = id
	if (profile.Items[material] or 0) < recipe.count then
		return nil, `You need {recipe.count} {material}`
	end
	if profile.Coins < recipe.coins then
		return nil, "You do not have enough coins"
	end
	if (profile.Items[key] or 0) + 1 > Shop.MAX_HELD then
		return nil, "You cannot carry any more of those"
	end
	profile.Items[material] -= recipe.count
	profile.Coins -= recipe.coins
	profile.Items[key] = (profile.Items[key] or 0) + 1
	return id, nil
end

local BAIT_DAY_KEY = "bait"

-- Why the player cannot use a bait right now, or nil if they can: they must hold one and have
-- uses left today (EconomyConfig.BAIT_USES_PER_DAY, counted by the server's date).
function Shop.baitProblem(profile: Profile.Profile, unixTime: number): string?
	Grants.rollDay(profile, unixTime)
	if (profile.Items.Bait or 0) < 1 then
		return "You have no bait"
	end
	if (profile.Daily.tasksDone[BAIT_DAY_KEY] or 0) >= EconomyConfig.BAIT_USES_PER_DAY then
		return "The creatures are wary of bait today. Try again tomorrow"
	end
	return nil
end

-- Takes one bait and counts the use. Call only after `baitProblem` returned nil and a creature
-- has really come out, with no pause in between.
function Shop.spendBait(profile: Profile.Profile, unixTime: number): boolean
	if Shop.baitProblem(profile, unixTime) ~= nil then
		return false
	end
	profile.Items.Bait -= 1
	profile.Daily.tasksDone[BAIT_DAY_KEY] = (profile.Daily.tasksDone[BAIT_DAY_KEY] or 0) + 1
	return true
end

-- How many coin-bought stable expansions the player has, from their stable's size. (Stable
-- room bought any other way will need its own count before it exists.)
function Shop.stableExpansions(profile: Profile.Profile): number
	local extra = profile.StableCapacity - EconomyConfig.STABLE_FREE_SLOTS
	return math.max(0, math.floor(extra / EconomyConfig.STABLE_EXPANSION_SLOTS))
end

-- The price of the next stable expansion, or nil when every one has been bought.
function Shop.nextStablePrice(profile: Profile.Profile): number?
	return Economy.stableExpansionPrice(Shop.stableExpansions(profile))
end

-- Buys the next stable expansion with coins: more room, for good. A long-term coin sink.
function Shop.expandStable(profile: Profile.Profile, atShop: boolean): (number?, string?)
	if not atShop then
		return nil, "You are too far away"
	end
	local price = Shop.nextStablePrice(profile)
	if not price then
		return nil, "Your stable cannot grow any more"
	end
	if profile.Coins < price then
		return nil, "You do not have enough coins"
	end
	profile.Coins -= price
	profile.StableCapacity += EconomyConfig.STABLE_EXPANSION_SLOTS
	return price, nil
end

-- Uses a tonic or a Rally Root in a battle. The item is taken only if it was really used.
function Shop.useInBattle(
	profile: Profile.Profile,
	session: BattleSession.Session,
	turn: unknown,
	item: unknown,
	target: unknown
): (BattleSession.TurnResult?, string?)
	local id: BattleSession.FieldItem? = BattleSession.parseFieldItem(item)
	if not id then
		return nil, "That cannot be used in a battle"
	end
	local key: string = id
	if (profile.Items[key] or 0) < 1 then
		return nil, "You have none of those"
	end
	local result, problem = BattleSession.useItem(session, turn, id, target)
	if not result then
		return nil, problem
	end
	profile.Items[key] -= 1
	return result, nil
end

return Shop
