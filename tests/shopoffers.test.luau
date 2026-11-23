--!strict
-- Checks for what the shop may offer (plan 16 placement rules): Robux things hide while the switch
-- is off or an id is 0, the Lasso Pass and Gem lassos need an unrestricted policy, owned passes
-- show as owned, the stable-full order, and the egg "Finish now" rules.
-- Run from the project folder:  lune run tests/shopoffers.test

local EconomyConfig = require("../src/config/EconomyConfig")
local Gems = require("../src/shared/Gems")
local PurchaseConfig = require("../src/config/PurchaseConfig")
local ShopOffers = require("../src/shared/ShopOffers")

local passed, failed = 0, 0
local function check(name: string, condition: boolean, detail: string?)
	if condition then
		passed += 1
	else
		failed += 1
		print(`FAIL: {name}{if detail then " (" .. detail .. ")" else ""}`)
	end
end

local function flags(open: boolean, restricted: boolean): ShopOffers.Flags
	return {
		Open = open,
		PaidRandomRestricted = restricted,
		TradingAllowed = false,
		LassoBoost = false,
	}
end

local function passKeys(list: { ShopOffers.PassOffer }): string
	local out: { string } = {}
	for _, each in list do
		table.insert(out, each.key)
	end
	return table.concat(out, ",")
end

-- Give every product an id, as after publishing; the shipped ids are put back at the end.
local savedPass: { [string]: number } = {}
local savedProduct: { [string]: number } = {}
local function setIds(on: boolean)
	for index, key: PurchaseConfig.PassId in PurchaseConfig.PASS_IDS do
		if savedPass[key] == nil then
			savedPass[key] = PurchaseConfig.PASSES[key].id
		end
		PurchaseConfig.PASSES[key].id = if on then 100 + index else 0
	end
	for index, key: PurchaseConfig.ProductId in PurchaseConfig.PRODUCT_IDS do
		if savedProduct[key] == nil then
			savedProduct[key] = PurchaseConfig.PRODUCTS[key].id
		end
		PurchaseConfig.PRODUCTS[key].id = if on then 200 + index else 0
	end
end

print("== Nothing shows before the ids exist ==")
do
	setIds(false)
	local passes, hidden = ShopOffers.passes(flags(true, false), {})
	check("no passes with id 0", #passes == 0)
	check("hidden count names them", hidden == #PurchaseConfig.PASS_IDS, tostring(hidden))
	local bundles, hiddenBundles = ShopOffers.bundles(flags(true, false))
	check("no bundles with id 0", #bundles == 0 and hiddenBundles == 6)
	local starter, hiddenStarter = ShopOffers.starter(flags(true, false), {})
	check("no starter with id 0", starter == nil and hiddenStarter == 1)
end

print("== The switch and the policy ==")
do
	setIds(true)
	local on = ShopOffers.passes(flags(true, false), {})
	check("every pass shows with ids, open and unrestricted", #on == #PurchaseConfig.PASS_IDS)
	check("switch off hides every pass", #ShopOffers.passes(flags(false, false), {}) == 0)
	check("no flags yet hides every pass", #ShopOffers.passes(nil, {}) == 0)
	local restricted = ShopOffers.passes(flags(true, true), {})
	check(
		"restricted hides the Lasso Pass only",
		#restricted == #PurchaseConfig.PASS_IDS - 1
			and not string.find(passKeys(restricted), "Lasso")
	)
	local ownedRestricted = ShopOffers.passes(flags(true, true), { "LassoPass" })
	check(
		"an owned Lasso Pass is hidden when restricted",
		not string.find(passKeys(ownedRestricted), "Lasso")
	)
	check("bundles hide with the switch", #ShopOffers.bundles(flags(false, false)) == 0)
	check("six bundles when open", #ShopOffers.bundles(flags(true, true)) == 6)
end

print("== Owned passes and the starter pack ==")
do
	setIds(true)
	local list = ShopOffers.passes(flags(true, false), { "BiggerStable" })
	local bigger: ShopOffers.PassOffer? = nil
	local second: ShopOffers.PassOffer? = nil
	for _, each in list do
		if each.key == "BiggerStable" then
			bigger = each
		elseif each.key == "SecondNest" then
			second = each
		end
	end
	check("owned pass shows as owned", bigger ~= nil and (bigger :: ShopOffers.PassOffer).owned)
	check(
		"an unowned pass is not owned",
		second ~= nil and not (second :: ShopOffers.PassOffer).owned
	)
	check("starter shows once", ShopOffers.starter(flags(true, false), {}) ~= nil)
	check(
		"starter gone after buying",
		ShopOffers.starter(flags(true, false), { "StarterPack" }) == nil
	)
	check("starter hidden when closed", ShopOffers.starter(flags(false, false), {}) == nil)
end

print("== One line each ==")
do
	for _, key: PurchaseConfig.PassId in PurchaseConfig.PASS_IDS do
		local line = ShopOffers.passLine(key)
		check(`{key} has a line`, #line > 8 and not string.find(line, "\n"), line)
	end
	check("quick hatch says 2x", string.find(ShopOffers.passLine("QuickHatch"), "2x") ~= nil)
	check("room pass says 30", string.find(ShopOffers.passLine("BiggerStable"), "30") ~= nil)
	check(
		"lasso pass names its percent",
		string.find(ShopOffers.passLine("LassoPass"), "15%%") ~= nil
	)
end

print("== Gem items ==")
do
	local open = ShopOffers.gemItems(flags(true, false), 4)
	local lassos, others = 0, 0
	for _, each in open do
		if each.isLasso then
			lassos += 1
		else
			others += 1
		end
		check(`{each.item} price is the server's`, each.price == Gems.itemPrice(each.item))
	end
	check("lassos shown when unrestricted", lassos == 3 and others >= 3, `{lassos} {others}`)
	local restricted = ShopOffers.gemItems(flags(true, true), 4)
	local anyLasso = false
	for _, each in restricted do
		anyLasso = anyLasso or each.isLasso
	end
	check("no Gem lasso when restricted", not anyLasso and #restricted == others)
	check("nothing while closed", #ShopOffers.gemItems(flags(false, false), 4) == 0)
	check("nothing before flags", #ShopOffers.gemItems(nil, 4) == 0)
	local neverGems = true
	for _, each in open do
		neverGems = neverGems and each.item ~= "GiantCall" and each.item ~= "BondCharm"
	end
	check("no horns or charms for Gems", neverGems)
	check("lasso key marks the catch", ShopOffers.gemLassoKey("Basic") == "Basic_g")
end

print("== Egg finish ==")
do
	local now = 1000
	local open = flags(true, false)
	local roomy = ShopOffers.eggs({ now + 900, now + 60 }, 5, 30, 100, now, open, false)
	check("two eggs", #roomy == 2)
	check(
		"cost matches the server",
		roomy[1].cost == Gems.eggFinishCost(900) and roomy[2].cost == 5
	)
	check("can finish with room", roomy[1].canFinish and roomy[1].reason == nil)
	check("affordable", not roomy[1].needsGems)
	local poor = ShopOffers.eggs({ now + 900 }, 5, 30, 2, now, open, false)
	check("short of Gems is flagged, not disabled", poor[1].needsGems and poor[1].canFinish)
	local full = ShopOffers.eggs({ now + 900 }, 30, 30, 100, now, open, false)
	check("stable full disables with a reason", not full[1].canFinish and full[1].reason ~= nil)
	local waiting = ShopOffers.eggs({ now - 5, now + 900 }, 29, 30, 100, now, open, false)
	check("a ready egg takes the last place first", #waiting == 1 and not waiting[1].canFinish)
	check("none in battle", #ShopOffers.eggs({ now + 900 }, 5, 30, 100, now, open, true) == 0)
	check(
		"none when closed",
		#ShopOffers.eggs({ now + 900 }, 5, 30, 100, now, flags(false, false), false) == 0
	)
	check("none before flags", #ShopOffers.eggs({ now + 900 }, 5, 30, 100, now, nil, false) == 0)
end

print("== Stable full ==")
do
	setIds(true)
	local open = flags(true, false)
	check("nothing while there is room", #ShopOffers.stableFull(29, 30, 0, open, {}, {}) == 0)
	local offers = ShopOffers.stableFull(30, 30, 0, open, {}, {})
	check("three offers", #offers == 3)
	check(
		"coins first, then pass, then starter",
		offers[1].kind == "CoinRoom"
			and offers[2].kind == "Pass"
			and offers[2].key == "BiggerStable"
			and offers[3].kind == "Product"
			and offers[3].key == "StarterPack"
	)
	check("coin price shown", offers[1].coins == EconomyConfig.STABLE_EXPANSION_COINS[1])
	local owned = ShopOffers.stableFull(40, 40, 1, open, { "BiggerStable" }, { "StarterPack" })
	check(
		"owned pass and starter are not offered again",
		#owned == 1 and owned[1].kind == "CoinRoom"
	)
	local maxed = ShopOffers.stableFull(
		80,
		80,
		#EconomyConfig.STABLE_EXPANSION_COINS,
		flags(false, false),
		{},
		{}
	)
	check("nothing left to offer", #maxed == 0)
	setIds(false)
	local noIds = ShopOffers.stableFull(30, 30, 0, open, {}, {})
	check("coins only while ids are 0", #noIds == 1 and noIds[1].kind == "CoinRoom")
	check("coin expansions counted", ShopOffers.coinExpansions(50, 10) == 1)
	check("never negative", ShopOffers.coinExpansions(30, 40) == 0)
end

print("== First badge ==")
do
	check("0 to 1 counts", ShopOffers.firstBadgeJustEarned(0, 1))
	check("first state of a session does not", not ShopOffers.firstBadgeJustEarned(nil, 1))
	check("second badge does not", not ShopOffers.firstBadgeJustEarned(1, 2))
	check("no change does not", not ShopOffers.firstBadgeJustEarned(1, 1))
	check(
		"line names Gems earned only with Gems",
		ShopOffers.badgeLine(20) == "You earned Gems. See what they buy"
	)
	check("line is honest with none", not string.find(ShopOffers.badgeLine(0), "earned"))
end

-- Put the shipped ids back.
for _, key: PurchaseConfig.PassId in PurchaseConfig.PASS_IDS do
	PurchaseConfig.PASSES[key].id = savedPass[key] or 0
end
for _, key: PurchaseConfig.ProductId in PurchaseConfig.PRODUCT_IDS do
	PurchaseConfig.PRODUCTS[key].id = savedProduct[key] or 0
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("shop offer checks failed")
end
