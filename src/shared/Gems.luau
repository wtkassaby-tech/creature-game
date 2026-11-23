--!strict
-- The Gem ledger and what Gems buy, as pure rules (plan 16). Every change to a player's Gems goes
-- through `Gems.change`, which validates it, applies it and returns a log line, so a balance can
-- never go negative, past the limit, or change without a record. Nothing here uses Roblox
-- services; the server logs the returned lines.
--
-- Gems buy time, capacity and consumables only. Breeding Candy, Giant Horns and Bond Charms are
-- never sold for Gems (EconomyConfig.GEM_ITEM_IDS lists the whole sold set).

local Capture = require("./Capture")
local Economy = require("./Economy")
local EconomyConfig = require("../config/EconomyConfig")
local Grants = require("./Grants")
local Profile = require("./Profile")
local PurchaseConfig = require("../config/PurchaseConfig")
local Shop = require("./Shop")

export type Line = {
	reason: string,
	delta: number,
	before: number,
	after: number,
}
export type Bought = { item: EconomyConfig.ItemId, count: number, gems: number, line: Line }
export type Finished = { gems: number, secondsLeft: number, line: Line }

local Gems = {}

local function isWhole(value: unknown): boolean
	return typeof(value) == "number" and value == value and value % 1 == 0
end

-- Adds (positive) or takes (negative) Gems. Refuses a change that is not a whole number, is zero,
-- is larger than PurchaseConfig.MAX_GEM_CHANGE, would leave less than nothing, or would go past
-- PurchaseConfig.MAX_GEMS. Nothing changes when it refuses.
function Gems.change(profile: Profile.Profile, delta: unknown, reason: unknown): (Line?, string?)
	if typeof(reason) ~= "string" or #reason < 1 or #reason > 40 then
		return nil, "A Gem change needs a reason"
	end
	if not isWhole(delta) then
		return nil, "Bad Gem amount"
	end
	local amount = delta :: number
	if amount == 0 or math.abs(amount) > PurchaseConfig.MAX_GEM_CHANGE then
		return nil, "Bad Gem amount"
	end
	local before = profile.Gems
	if not isWhole(before) or before < 0 then
		return nil, "Your Gems cannot be used right now"
	end
	local after = before + amount
	if after < 0 then
		return nil, "You do not have enough Gems"
	end
	if after > PurchaseConfig.MAX_GEMS then
		return nil, "You cannot hold any more Gems"
	end
	profile.Gems = after
	return { reason = reason, delta = amount, before = before, after = after }, nil
end

-- Turns a name from the device into an item that Gems buy, or nil.
function Gems.parseItem(item: unknown): EconomyConfig.ItemId?
	for _, each: EconomyConfig.ItemId in EconomyConfig.GEM_ITEM_IDS do
		if each == item then
			return each
		end
	end
	return nil
end

-- What an item costs in Gems, or nil if Gems do not buy it.
function Gems.itemPrice(item: unknown): number?
	local id = Gems.parseItem(item)
	return if id then EconomyConfig.GEM_PRICES[id] else nil
end

-- Buys `count` of a consumable with Gems. `item` and `count` come from the device; `atShop` is
-- the server's own check, as for coins. The price is the config's, never the device's.
function Gems.buyItem(
	profile: Profile.Profile,
	item: unknown,
	count: unknown,
	atShop: boolean,
	paidRandomRestricted: boolean? -- PolicyService's answer; anything but exactly false refuses a lasso
): (Bought?, string?)
	local id: EconomyConfig.ItemId? = Gems.parseItem(item)
	local price = if id then EconomyConfig.GEM_PRICES[id] else nil
	if id == nil or price == nil then
		return nil, "Gems do not buy that"
	end
	if
		typeof(count) ~= "number"
		or count % 1 ~= 0
		or count < 1
		or count > Shop.MAX_PER_PURCHASE
	then
		return nil, "Bad amount"
	end
	local amount = count :: number
	if not atShop then
		return nil, "You are too far away"
	end
	if not Economy.itemAvailable(id, profile.Story.biomeReached) then
		return nil, "The shop does not sell that yet"
	end
	-- A lasso is a random catch bought with Gems (a currency Robux buys): never sold unless
	-- PolicyService says, exactly, that paid random items are not restricted for this player. It is
	-- kept under its own item key so what it catches can be marked.
	local isLasso = table.find(EconomyConfig.LASSO_TIERS, id :: any) ~= nil
	if isLasso and paidRandomRestricted ~= false then
		return nil, "That is not available to you"
	end
	local key: string = if isLasso then id .. Capture.GEM_LASSO_SUFFIX else id
	local held = profile.Items[key] or 0
	if held + amount > Shop.MAX_HELD then
		return nil, "You cannot carry any more of those"
	end
	local total = price * amount
	-- Checked and taken in this one step: no pause between looking at the balance and taking it.
	local line, problem = Gems.change(profile, -total, `buy:{id}`)
	if not line then
		return nil, problem
	end
	profile.Items[key] = held + amount
	return { item = id, count = amount, gems = total, line = line }, nil
end

-- The Gems to finish an egg that has `secondsLeft` to go: one for each
-- EGG_FINISH_SECONDS_PER_GEM, at least EGG_FINISH_MIN_GEMS.
function Gems.eggFinishCost(secondsLeft: number): number
	return math.max(
		EconomyConfig.EGG_FINISH_MIN_GEMS,
		math.ceil(math.max(0, secondsLeft) / EconomyConfig.EGG_FINISH_SECONDS_PER_GEM)
	)
end

-- Finishes the egg whose hatch time is `hatchAt` (the device names it by that time, so a list that
-- shifted a moment ago can never charge for the wrong egg). The egg then hatches on the server's
-- next hatch check. Never changes the child.
function Gems.finishEgg(
	profile: Profile.Profile,
	hatchAt: unknown,
	now: number
): (Finished?, string?)
	if not isWhole(hatchAt) then
		return nil, "Bad request"
	end
	-- A finished egg needs room to hatch into; do not charge for one that would sit in its pen.
	-- Eggs already finished but not yet hatched will take the room first.
	local waiting = 0
	for _, egg in profile.Eggs do
		if egg.hatchAt <= now then
			waiting += 1
		end
	end
	if Grants.room(profile) - waiting < 1 then
		return nil, "Your stable is full: make room first"
	end
	local target: Profile.Egg? = nil
	for _, egg in profile.Eggs do
		if egg.hatchAt == hatchAt and egg.hatchAt > now then
			target = egg
			break
		end
	end
	if not target then
		return nil, "That egg has already hatched"
	end
	local secondsLeft = target.hatchAt - now
	local cost = Gems.eggFinishCost(secondsLeft)
	local line, problem = Gems.change(profile, -cost, "finishEgg")
	if not line then
		return nil, problem
	end
	target.hatchAt = now
	return { gems = cost, secondsLeft = secondsLeft, line = line }, nil
end

return Gems
