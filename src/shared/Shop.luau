--!strict
-- Buying from a hub shop and using items in battle, as pure rules. Prices come from the economy
-- (src/shared/Economy); everything is paid in coins the player earned.

local BattleSession = require("./BattleSession")
local Economy = require("./Economy")
local EconomyConfig = require("../config/EconomyConfig")
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
	local held = profile.Items[id] or 0
	if held + count > Shop.MAX_HELD then
		return nil, "You cannot carry any more of those"
	end
	local coins = Economy.itemPrice(id, biome) * count
	if coins ~= coins or coins < 0 or profile.Coins < coins then
		return nil, "You do not have enough coins"
	end
	profile.Coins -= coins
	profile.Items[id] = held + count
	return { item = id, count = count, coins = coins }, nil
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
