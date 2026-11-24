--!strict
-- Handling a developer-product receipt, as pure rules (plan 05 section 4, plan 16). The server
-- module src/server/Purchases/PurchaseService supplies Roblox's receipt and decides what to tell
-- Roblox; everything that changes the saved record is decided here.
--
-- The rule that matters: the grant and the receipt id are written in ONE step with no pause, so
-- a PurchaseId can never be granted twice, and a grant can never exist without its id. Anything
-- that is not exactly right is refused before the record is touched.

local Gems = require("./Gems")
local Profile = require("./Profile")
local PurchaseConfig = require("../config/PurchaseConfig")

export type Receipt = { PurchaseId: unknown, ProductId: unknown }
-- Granted: the product was granted just now. AlreadyGranted: this PurchaseId was granted before,
-- nothing changed. Refused: nothing changed and the receipt must stay unprocessed.
export type Decision = "Granted" | "AlreadyGranted" | "Refused"
export type Outcome = {
	decision: Decision,
	product: PurchaseConfig.ProductId?,
	note: string, -- why it was refused, or a note for the log
	lines: { Gems.Line }, -- every Gem change made, for the log
	repeatStarter: boolean, -- a Starter Pack bought a second time: only its Gems were granted
}

local Purchases = {}

-- Which product a Roblox developer product id is, or nil. An id of 0 (not created yet) never matches.
function Purchases.productByRobloxId(productId: unknown): PurchaseConfig.ProductId?
	if typeof(productId) ~= "number" or productId ~= productId or productId < 1 then
		return nil
	end
	local found: PurchaseConfig.ProductId? = nil
	for _, key: PurchaseConfig.ProductId in PurchaseConfig.PRODUCT_IDS do
		if PurchaseConfig.PRODUCTS[key].id == productId then
			found = key
		end
	end
	return found
end

-- Which pass a Roblox game pass id is, or nil. An id of 0 never matches.
function Purchases.passByRobloxId(passId: unknown): PurchaseConfig.PassId?
	if typeof(passId) ~= "number" or passId ~= passId or passId < 1 then
		return nil
	end
	local found: PurchaseConfig.PassId? = nil
	for _, key: PurchaseConfig.PassId in PurchaseConfig.PASS_IDS do
		if PurchaseConfig.PASSES[key].id == passId then
			found = key
		end
	end
	return found
end

-- Turns a name from the device into a product key, or nil.
function Purchases.parseProduct(value: unknown): PurchaseConfig.ProductId?
	local found: PurchaseConfig.ProductId? = nil
	for _, key: PurchaseConfig.ProductId in PurchaseConfig.PRODUCT_IDS do
		if key == value then
			found = key
		end
	end
	return found
end

function Purchases.starterBought(profile: Profile.Profile): boolean
	return profile.Purchases.once[PurchaseConfig.STARTER_PACK.onceKey] == true
end

local function refused(note: string): Outcome
	return { decision = "Refused", note = note, lines = {}, repeatStarter = false }
end

-- Grants a developer product for one receipt. Mutates the profile only when it returns Granted,
-- and then does everything together: the Gems, any room or cosmetic, and the PurchaseId.
function Purchases.process(profile: Profile.Profile, receipt: Receipt): Outcome
	local purchaseId = receipt.PurchaseId
	if
		typeof(purchaseId) ~= "string"
		or #purchaseId < 1
		or #purchaseId > PurchaseConfig.MAX_PURCHASE_ID_LENGTH
	then
		return refused("bad purchase id")
	end
	if table.find(profile.Purchases.receiptIds, purchaseId) then
		return { decision = "AlreadyGranted", note = "seen", lines = {}, repeatStarter = false }
	end
	local key: PurchaseConfig.ProductId? = Purchases.productByRobloxId(receipt.ProductId)
	if key == nil then
		return refused("unknown product")
	end
	local def = PurchaseConfig.PRODUCTS[key]
	local lines: { Gems.Line } = {}

	-- A Starter Pack bought a second time (two servers, or a stale prompt): Roblox has the money, so
	-- it pays out as the plain Gem bundle of the same price (never the pack's bonus Gems, which
	-- would make it a cheaper-Gems loop), and the once-only parts are not granted again.
	local starter = PurchaseConfig.STARTER_PACK
	local repeatStarter = def.kind == "Starter" and profile.Purchases.once[starter.onceKey] == true
	local gems = if repeatStarter then PurchaseConfig.PRODUCTS.Gems99.gems else def.gems

	-- Look before touching anything: the Gems must fit.
	if profile.Gems + gems > PurchaseConfig.MAX_GEMS then
		return refused("gems would go past the limit")
	end

	-- The Gem change is the only step that can fail, so it goes first: if it does, nothing has
	-- been touched.
	local line = Gems.change(profile, gems, `product:{key}`)
	if not line then
		return refused("gems could not be added")
	end
	table.insert(lines, line)

	if def.kind == "Starter" and not repeatStarter then
		profile.Purchases.once[starter.onceKey] = true
		profile.Purchases.perks[starter.cosmeticPerk] = true
		profile.StableCapacity = math.min(profile.StableCapacity + starter.stableRoom, 65535)
	end

	Profile.rememberReceipt(profile, purchaseId)
	return {
		decision = "Granted",
		product = key,
		note = if repeatStarter then "starter pack repeat" else "ok",
		lines = lines,
		repeatStarter = repeatStarter,
	}
end

-- What PolicyService told us, read safely. Anything that is not exactly `false` for
-- ArePaidRandomItemsRestricted counts as restricted; trading is allowed only on an exact `true`.
function Purchases.readPolicy(info: unknown): { restricted: boolean, tradingAllowed: boolean }
	if typeof(info) ~= "table" then
		return { restricted = true, tradingAllowed = false }
	end
	local fields = info :: { [string]: unknown }
	return {
		restricted = fields.ArePaidRandomItemsRestricted ~= false,
		tradingAllowed = fields.IsPaidItemTradingAllowed == true,
	}
end

return Purchases
