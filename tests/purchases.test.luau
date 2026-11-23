--!strict
-- Checks for purchases (plan 05, plan 16): receipts are granted once, every pass does what it says,
-- the Lasso Pass needs the pass AND an unrestricted policy and never touches giants, Gems cannot go
-- wrong, and the Starter Pack is once per account.
-- Run from the project folder:  lune run tests/purchases.test

local Breeding = require("../src/shared/Breeding")
local BattleSession = require("../src/shared/BattleSession")
local Capture = require("../src/shared/Capture")
local EconomyConfig = require("../src/config/EconomyConfig")
local Gems = require("../src/shared/Gems")
local Grants = require("../src/shared/Grants")
local PassEffects = require("../src/shared/PassEffects")
local Profile = require("../src/shared/Profile")
local ProfileConfig = require("../src/config/ProfileConfig")
local PurchaseConfig = require("../src/config/PurchaseConfig")
local Purchases = require("../src/shared/Purchases")
local Rng = require("../src/shared/Rng")
local Shop = require("../src/shared/Shop")
local Snapshot = require("../src/shared/Snapshot")
local Types = require("../src/shared/Types")
local Placeholders = require("./fixtures/Placeholders")

Placeholders.install()

local passed, failed = 0, 0
local function check(name: string, condition: boolean, detail: string?)
	if condition then
		passed += 1
	else
		failed += 1
	end
	print(
		`  {if condition then "PASS" else "FAIL"}  {name}{if detail
			then "  (" .. detail .. ")"
			else ""}`
	)
end

-- The tests set product and pass ids to real-looking numbers (the shipped config has 0 = unset)
-- and put them back at the end.
local savedIds: { [string]: number } = {}
local function setIds()
	local nextId = 1000
	for _, key: PurchaseConfig.ProductId in PurchaseConfig.PRODUCT_IDS do
		savedIds[key] = PurchaseConfig.PRODUCTS[key].id
		nextId += 1
		PurchaseConfig.PRODUCTS[key].id = nextId
	end
	for _, key: PurchaseConfig.PassId in PurchaseConfig.PASS_IDS do
		savedIds[key] = PurchaseConfig.PASSES[key].id
		nextId += 1
		PurchaseConfig.PASSES[key].id = nextId
	end
end
local function restoreIds()
	for _, key: PurchaseConfig.ProductId in PurchaseConfig.PRODUCT_IDS do
		PurchaseConfig.PRODUCTS[key].id = savedIds[key]
	end
	for _, key: PurchaseConfig.PassId in PurchaseConfig.PASS_IDS do
		PurchaseConfig.PASSES[key].id = savedIds[key]
	end
end

------------------------------------------------------------------------------------------------
print("\n== The shipped config is safe ==")
do
	local zeroed = true
	for _, key: PurchaseConfig.ProductId in PurchaseConfig.PRODUCT_IDS do
		zeroed = zeroed and PurchaseConfig.PRODUCTS[key].id == 0
	end
	for _, key: PurchaseConfig.PassId in PurchaseConfig.PASS_IDS do
		zeroed = zeroed and PurchaseConfig.PASSES[key].id == 0
	end
	check("every id is 0 until the place is published", zeroed)
	check("a receipt for product 0 matches nothing", Purchases.productByRobloxId(0) == nil)
	check("a pass id of 0 matches nothing", Purchases.passByRobloxId(0) == nil)
	local bundles =
		{ Gems49 = 45, Gems99 = 100, Gems249 = 275, Gems499 = 575, Gems999 = 1200, Gems1999 = 2500 }
	local right = true
	for key, gems in bundles do
		right = right and PurchaseConfig.PRODUCTS[key :: any].gems == gems
	end
	check("the bundles are the plan's", right)
	check(
		"the Lasso Pass defaults",
		PurchaseConfig.LASSO_PASS_BONUS == 0.15 and PurchaseConfig.LASSO_PASS_CAP == 0.97
	)
end

setIds()

------------------------------------------------------------------------------------------------
print("\n== A receipt is granted once ==")
do
	local profile = Profile.template()
	local product = PurchaseConfig.PRODUCTS.Gems99
	local receipt = { PurchaseId = "abc-1", ProductId = product.id }
	local first = Purchases.process(profile, receipt)
	check("the first receipt is granted", first.decision == "Granted" and profile.Gems == 100)
	check(
		"the id is in the record in the same step",
		table.find(profile.Purchases.receiptIds, "abc-1") ~= nil
	)
	check(
		"it logs one Gem line",
		#first.lines == 1 and first.lines[1].delta == 100 and first.lines[1].after == 100
	)
	local again = Purchases.process(profile, receipt)
	check(
		"the same PurchaseId again grants nothing",
		again.decision == "AlreadyGranted" and profile.Gems == 100
	)
	for _ = 1, 5 do
		Purchases.process(profile, receipt)
	end
	check("however often it is retried", profile.Gems == 100)

	local other = Purchases.process(profile, { PurchaseId = "abc-2", ProductId = product.id })
	check(
		"a different PurchaseId is a different purchase",
		other.decision == "Granted" and profile.Gems == 200
	)

	local before = profile.Gems
	local unknown = Purchases.process(profile, { PurchaseId = "abc-3", ProductId = 99 })
	check(
		"an unknown product is refused and changes nothing",
		unknown.decision == "Refused"
			and profile.Gems == before
			and table.find(profile.Purchases.receiptIds, "abc-3") == nil
	)
	local badIds: { any } = { "", 12, false, string.rep("x", 200) }
	for _, bad in badIds do
		local r = Purchases.process(profile, { PurchaseId = bad, ProductId = product.id })
		check(
			`a bad purchase id ({tostring(bad):sub(1, 5)}) is refused`,
			r.decision == "Refused" and profile.Gems == before
		)
	end
	local noProduct = Purchases.process(profile, { PurchaseId = "abc-4", ProductId = "Gems99" })
	check("a product id that is not a number is refused", noProduct.decision == "Refused")

	-- Gems at the limit: refused, nothing changes, the id is not recorded.
	local rich = Profile.template()
	rich.Gems = PurchaseConfig.MAX_GEMS - 10
	local over = Purchases.process(rich, { PurchaseId = "abc-5", ProductId = product.id })
	check(
		"a grant past the Gem limit is refused whole",
		over.decision == "Refused"
			and rich.Gems == PurchaseConfig.MAX_GEMS - 10
			and #rich.Purchases.receiptIds == 0
	)

	-- Many receipts: only the latest ids are kept, and the profile stays sound.
	local busy = Profile.template()
	for index = 1, ProfileConfig.RECEIPTS_REMEMBERED + 30 do
		Purchases.process(busy, { PurchaseId = `r{index}`, ProductId = product.id })
	end
	check(
		"the list is capped",
		#busy.Purchases.receiptIds == ProfileConfig.RECEIPTS_REMEMBERED
			and busy.Gems == 100 * (ProfileConfig.RECEIPTS_REMEMBERED + 30)
	)
	check(
		"a recent id is still caught",
		Purchases.process(
			busy,
			{ PurchaseId = `r{ProfileConfig.RECEIPTS_REMEMBERED + 30}`, ProductId = product.id }
		).decision == "AlreadyGranted"
	)
	check("the profile is sound after purchases", #Profile.validate(busy) == 0)
end

------------------------------------------------------------------------------------------------
print("\n== The Starter Pack is once per account ==")
do
	local profile = Profile.template()
	local product = PurchaseConfig.PRODUCTS.StarterPack
	local before = profile.StableCapacity
	local first = Purchases.process(profile, { PurchaseId = "s1", ProductId = product.id })
	check(
		"it gives 150 Gems, 10 room and the cosmetic flag",
		first.decision == "Granted"
			and profile.Gems == 150
			and profile.StableCapacity == before + 10
			and profile.Purchases.perks.StarterCosmetic == true
			and Purchases.starterBought(profile)
	)
	local second = Purchases.process(profile, { PurchaseId = "s2", ProductId = product.id })
	check(
		"a second purchase (a stale prompt) grants the plain 100-Gem bundle, no room, and says so",
		second.decision == "Granted"
			and second.repeatStarter
			and profile.Gems == 150 + PurchaseConfig.PRODUCTS.Gems99.gems
			and profile.StableCapacity == before + 10
	)
	check(
		"the same receipt twice still grants once",
		Purchases.process(profile, { PurchaseId = "s2", ProductId = product.id }).decision
				== "AlreadyGranted"
			and profile.Gems == 250
	)
	check("the saved record is sound", #Profile.validate(profile) == 0)
	check("the coin expansions do not count the Starter room", Shop.stableExpansions(profile) == 0)
end

------------------------------------------------------------------------------------------------
print("\n== Passes ==")
do
	local profile = Profile.template()
	check("a new player owns no pass", #PassEffects.list(profile) == 0)

	-- Bigger Stable
	local start = profile.StableCapacity
	check("Bigger Stable is new the first time", PassEffects.grant(profile, "BiggerStable"))
	check("it adds 30 room", profile.StableCapacity == start + 30)
	check(
		"applying it again changes nothing",
		not PassEffects.grant(profile, "BiggerStable") and profile.StableCapacity == start + 30
	)

	-- Supporter
	PassEffects.grant(profile, "Supporter")
	check(
		"Supporter adds 10 room and a title",
		profile.StableCapacity == start + 40 and PassEffects.title(profile) == "Supporter"
	)
	check(
		"the room from passes is not a coin expansion",
		Shop.stableExpansions(profile) == 0
			and Shop.nextStablePrice(profile) == EconomyConfig.STABLE_EXPANSION_COINS[1]
	)
	profile.StableCapacity += EconomyConfig.STABLE_EXPANSION_SLOTS
	check("a real coin expansion still counts", Shop.stableExpansions(profile) == 1)
	check("the saved record is sound", #Profile.validate(profile) == 0)

	-- Second Nest never goes above the cap
	local nest = Profile.template()
	PassEffects.grant(nest, "SecondNest")
	check("Second Nest adds a pen", nest.Pens == ProfileConfig.STARTING_PENS + 1)
	local full = Profile.template()
	full.Pens = ProfileConfig.MAX_PENS
	PassEffects.grant(full, "SecondNest")
	check("never above the pen cap", full.Pens == ProfileConfig.MAX_PENS)
	local three = Profile.template()
	three.Pens = ProfileConfig.MAX_PENS - 1
	PassEffects.grant(three, "SecondNest")
	check(
		"up to the cap exactly",
		three.Pens == ProfileConfig.MAX_PENS and #Profile.validate(three) == 0
	)

	-- Quick Hatch
	local hatch = Profile.template()
	check(
		"without the pass an egg takes its full time",
		PassEffects.hatchAt(hatch, 1000, 5000) == 5000
	)
	PassEffects.grant(hatch, "QuickHatch")
	check("Quick Hatch halves the time left", PassEffects.hatchAt(hatch, 1000, 5000) == 3000)
	check("an odd time rounds up, never to now", PassEffects.hatchAt(hatch, 1000, 1001) == 1001)
	check("a time already past is left alone", PassEffects.hatchAt(hatch, 1000, 900) == 900)

	-- The Field Satchel is not for sale (nothing needs a hub), but its code path is kept.
	local satchel = Profile.template()
	check(
		"the stable needs a hub, and no pass sells the Satchel",
		not PassEffects.mayUseStable(satchel, false)
			and PassEffects.mayUseStable(satchel, true)
			and PassEffects.parse("FieldSatchel") == nil
			and (PurchaseConfig.PASSES :: any)["FieldSatchel"] == nil
	)

	-- Unknown names and the snapshot
	check(
		"an unknown pass name is refused",
		PassEffects.parse("Free") == nil and PassEffects.parse(5) == nil
	)
	local snap = Snapshot.build(profile, 1000)
	check(
		"the device is told the passes and the stable bonus",
		#snap.Passes == 2 and snap.StableBonus == 40 and not snap.StableAnywhere
	)
end

------------------------------------------------------------------------------------------------
print("\n== The Lasso Pass ==")
do
	local profile = Profile.template()
	check("not owned: never active", not PassEffects.lassoBoostActive(profile, false))
	PassEffects.grant(profile, "LassoPass")
	check("owned and unrestricted: active", PassEffects.lassoBoostActive(profile, false))
	check("owned but restricted: not active", not PassEffects.lassoBoostActive(profile, true))
	check(
		"owned but policy not known yet: not active",
		not PassEffects.lassoBoostActive(profile, nil)
	)

	check("it adds the bonus", math.abs(PassEffects.boostChance(0.5, true, false) - 0.65) < 1e-9)
	check(
		"it stops at the cap",
		PassEffects.boostChance(0.9, true, false) == PurchaseConfig.LASSO_PASS_CAP
	)
	check(
		"it never lowers a chance already above the cap",
		PassEffects.boostChance(0.99, true, false) == 0.99
	)
	check("an impossible throw stays at zero", PassEffects.boostChance(0, true, false) == 0)
	check("never for a giant", PassEffects.boostChance(0.5, true, true) == 0.5)
	check("not active: unchanged", PassEffects.boostChance(0.5, false, false) == 0.5)

	-- Which creatures it applies to: only those that never flee (Common, Uncommon).
	check(
		"it applies to Common and Uncommon",
		PassEffects.lassoBoostApplies(profile, false, "Common", false)
			and PassEffects.lassoBoostApplies(profile, false, "Uncommon", false)
	)
	local never = true
	local fleeing: { string } = { "Gem", "Ruby", "Diamond", "Cosmic" }
	for _, rarity in fleeing do
		never = never and not PassEffects.lassoBoostApplies(profile, false, rarity, false)
	end
	check("never to Gem tier and above (those that flee and carry serial numbers)", never)
	check("never to a giant", not PassEffects.lassoBoostApplies(profile, false, "Common", true))
	check(
		"not when restricted or unknown",
		not PassEffects.lassoBoostApplies(profile, true, "Common", false)
			and not PassEffects.lassoBoostApplies(profile, nil, "Common", false)
	)

	-- Through the capture rules: the same throws, with and without the pass.
	local function setup(
		seed: number,
		rarity: Types.Rarity?
	): (Profile.Profile, BattleSession.Session)
		local p = Profile.template()
		local rng = Rng.new(seed)
		local mine = Breeding.wild("Mossmitt", "mine", 12, "Common", "Moss", rng)
		p.Creatures[mine.id] = mine
		p.Team = { mine.id }
		p.Items.Basic = 5
		p.Items.Braided = 5
		p.Items.Gilded = 5
		local wild = Breeding.wild("Spadesnout", "wild", 4, rarity or "Common", "Sand", rng)
		local session = assert(BattleSession.start({
			battleId = seed,
			kind = "Wild",
			yours = { mine },
			theirs = { wild },
			theirMoves = nil,
			tier = "Wild",
			seed = seed,
			levelCap = 15,
		}))
		return p, session
	end
	local function begin(
		p: Profile.Profile,
		s: BattleSession.Session,
		restricted: boolean?,
		tier: string?
	): (Capture.Throw?, string?)
		return Capture.begin({
			profile = p,
			session = s,
			turn = s.state.turn + 1,
			tier = tier or "Basic",
			seed = 5,
			roundTripMs = 40,
			nowMs = 0,
			misses = 0,
			paidRandomRestricted = restricted,
		})
	end
	local function throw(
		p: Profile.Profile,
		s: BattleSession.Session,
		restricted: boolean?,
		tier: string?
	): Capture.Throw
		return assert(begin(p, s, restricted, tier))
	end
	-- A tap far from every zone gives a small base chance, so the bonus shows.
	local function judgeFar(
		p: Profile.Profile,
		s: BattleSession.Session,
		t: Capture.Throw,
		seed: number?
	): Capture.Result
		local claims, arrivals = {}, {}
		for index, zone in t.pattern.zones do
			local at = zone.startMs + 5
			claims[index] = at
			arrivals[index] = at + 20
		end
		return assert(Capture.finish(p, s, t, claims, arrivals, 1, Rng.new(seed or 7)))
	end

	local ownerProfile, ownerSession = setup(11)
	PassEffects.grant(ownerProfile, "LassoPass")
	local plainProfile, plainSession = setup(11)
	local ownerThrow = throw(ownerProfile, ownerSession, false)
	local plainThrow = throw(plainProfile, plainSession, false)
	check(
		"the decision is made when the throw begins",
		ownerThrow.boostActive and not plainThrow.boostActive
	)
	local boosted = judgeFar(ownerProfile, ownerSession, ownerThrow)
	local plain = judgeFar(plainProfile, plainSession, plainThrow)
	check(
		"an owner's throw with an open policy is boosted",
		boosted.judgement.verdict ~= "Invalid" and boosted.boosted and boosted.chance > plain.chance
	)
	check(
		"the boost is the bonus (or up to the cap)",
		math.abs(
			boosted.chance
				- math.min(
					PurchaseConfig.LASSO_PASS_CAP,
					plain.chance + PurchaseConfig.LASSO_PASS_BONUS
				)
		) < 1e-9
	)
	check("a non-owner is never boosted", not plain.boosted)

	local restrictedProfile, restrictedSession = setup(11)
	PassEffects.grant(restrictedProfile, "LassoPass")
	local restrictedThrow = throw(restrictedProfile, restrictedSession, true)
	local blocked = judgeFar(restrictedProfile, restrictedSession, restrictedThrow)
	check(
		"an owner whose policy is restricted gets the plain chance",
		not blocked.boosted and blocked.chance == plain.chance
	)
	local unknownProfile, unknownSession = setup(11)
	PassEffects.grant(unknownProfile, "LassoPass")
	local unknownThrow = throw(unknownProfile, unknownSession, nil)
	local unknown = judgeFar(unknownProfile, unknownSession, unknownThrow)
	check(
		"an owner whose policy is not known yet gets the plain chance",
		not unknown.boosted and unknown.chance == plain.chance
	)

	-- The number shown before the throw is the number rolled: one decision, kept on the throw.
	local best, flag = Capture.previewChance(ownerThrow, "Common")
	local bestPlain, plainFlag = Capture.previewChance(plainThrow, "Common")
	check(
		"the shown chance includes the bonus",
		best > bestPlain and flag and not plainFlag and best <= PurchaseConfig.LASSO_PASS_CAP
	)
	check("and the roll used the same decision", boosted.boosted == flag)

	-- A fleeing, gem-tier creature is never boosted.
	local gemProfile, gemSession = setup(12, "Gem")
	PassEffects.grant(gemProfile, "LassoPass")
	local gemThrow = throw(gemProfile, gemSession, false, "Braided")
	local gemPlainProfile, gemPlainSession = setup(12, "Gem")
	local gemPlainThrow = throw(gemPlainProfile, gemPlainSession, false, "Braided")
	check("a Gem-tier throw is not boosted", not gemThrow.boostActive)
	check(
		"the pass leaves a Gem-tier creature's odds exactly as they were",
		Capture.previewChance(gemThrow, "Gem") == Capture.previewChance(gemPlainThrow, "Gem")
	)
	check("and its result is not boosted", not judgeFar(gemProfile, gemSession, gemThrow).boosted)

	-- Suspending a pass that Roblox says the player no longer owns.
	local lapsed = Profile.template()
	PassEffects.grant(lapsed, "LassoPass")
	PassEffects.grant(lapsed, "QuickHatch")
	PassEffects.grant(lapsed, "BiggerStable")
	local room = lapsed.StableCapacity
	PassEffects.suspend(lapsed, "LassoPass")
	PassEffects.suspend(lapsed, "QuickHatch")
	check(
		"a suspended Lasso Pass and Quick Hatch do nothing",
		not PassEffects.lassoBoostActive(lapsed, false)
			and PassEffects.hatchAt(lapsed, 1000, 5000) == 5000
	)
	check(
		"the room already given stays",
		lapsed.StableCapacity == room and PassEffects.owned(lapsed, "BiggerStable")
	)
	check("suspending is never saved", #Profile.validate(lapsed) == 0)
	PassEffects.resume(lapsed, "LassoPass")
	check("a resumed pass works again", PassEffects.lassoBoostActive(lapsed, false))

	-- Paid-assist marks on creatures caught with paid help.
	local function firstCatch(
		build: () -> (Profile.Profile, BattleSession.Session, Capture.Throw)
	): Types.Creature?
		for seed = 1, 400 do
			local p, s, t = build()
			local result = judgeFar(p, s, t, seed)
			if result.outcome == "Caught" then
				for id, creature in p.Creatures do
					if id ~= "mine" then
						return creature
					end
				end
				for _, pending in p.Pending do
					if pending.creature then
						return pending.creature
					end
				end
			end
		end
		return nil
	end
	local withPass = firstCatch(function()
		local p, s = setup(21)
		PassEffects.grant(p, "LassoPass")
		return p, s, throw(p, s, false)
	end)
	check(
		"a catch the Lasso Pass helped is marked",
		withPass ~= nil and withPass.paidAssist == "Pass"
	)
	local withGemLasso = firstCatch(function()
		local p, s = setup(21)
		p.Items.Basic = 0
		p.Items.Basic_g = 2
		return p, s, throw(p, s, false)
	end)
	check(
		"a catch with a Gem-bought lasso is marked",
		withGemLasso ~= nil and withGemLasso.paidAssist == "GemLasso"
	)
	local ordinary = firstCatch(function()
		local p, s = setup(21)
		return p, s, throw(p, s, false)
	end)
	check("an ordinary catch is not marked", ordinary ~= nil and ordinary.paidAssist == nil)
	local ownerRestricted = firstCatch(function()
		local p, s = setup(21)
		PassEffects.grant(p, "LassoPass")
		return p, s, throw(p, s, true)
	end)
	check(
		"a catch by a pass owner whose policy is restricted is not marked",
		ownerRestricted ~= nil and ownerRestricted.paidAssist == nil
	)

	-- Gem lassos are separate items, used after coin lassos, never for a restricted player.
	local both, bothSession = setup(21)
	both.Items.Basic_g = 2
	local usedFirst = throw(both, bothSession, false)
	check(
		"a coin lasso is used before a Gem lasso",
		both.Items.Basic == 4 and both.Items.Basic_g == 2 and not usedFirst.paidLasso
	)
	local onlyGem, onlyGemSession = setup(21)
	onlyGem.Items.Basic = 0
	onlyGem.Items.Basic_g = 1
	local gemT, gemWhy = begin(onlyGem, onlyGemSession, true)
	check(
		"a restricted player cannot throw a Gem lasso, and it is not spent",
		gemT == nil and onlyGem.Items.Basic_g == 1,
		gemWhy
	)
	local okGem = throw(onlyGem, onlyGemSession, false)
	check(
		"an unrestricted player can, and it counts as that tier",
		okGem.paidLasso and onlyGem.Items.Basic_g == 0 and okGem.tier == "Basic"
	)
end

------------------------------------------------------------------------------------------------
print("\n== Limits the device is told ==")
do
	local p = Profile.template()
	for index = 1, 17 do
		p.Purchases.perks[`perk{index}`] = true
	end
	check("more than 16 perks is reported", #Profile.validate(p) > 0)
	p = Profile.template()
	p.Purchases.perks[string.rep("x", 25)] = true
	check("a perk name over 24 characters is reported", #Profile.validate(p) > 0)
	p = Profile.template()
	p.Purchases.perks[""] = true
	check("an empty name is reported", #Profile.validate(p) > 0)
	p = Profile.template()
	p.Purchases.once.StarterPack = true
	p.Purchases.perks.StarterCosmetic = true
	check(
		"the real marks are fine and fit",
		#Profile.validate(p) == 0 and #Snapshot.build(p, 1).Perks == 2
	)
	local rng = Rng.new(2)
	local c = Breeding.wild("Brindle", "pa", 3, "Common", "Moss", rng)
	p = Profile.template()
	p.Creatures[c.id] = c
	c.paidAssist = "GemLasso"
	check("a paid-assist mark is allowed", #Profile.validate(p) == 0);
	(c :: any).paidAssist = "yes"
	check("a bad paid-assist mark is reported", #Profile.validate(p) > 0)
end

------------------------------------------------------------------------------------------------
print("\n== Paid help and release, breeding, the pass's rarities ==")
do
	local rng = Rng.new(4)
	local function owned(assist: string?): (Profile.Profile, Types.Creature)
		local p = Profile.template()
		local keep = Breeding.wild("Brindle", "keep", 3, "Common", "Moss", rng)
		local c = Breeding.wild("Dartlet", "c", 3, "Gem", "Sand", rng)
		c.paidAssist = assist :: any
		p.Creatures[keep.id] = keep
		p.Creatures[c.id] = c
		p.Team = { keep.id }
		return p, c
	end
	local p0, ordinary = owned(nil)
	local g0 = Grants.release(p0, ordinary.id, false)
	check("an ordinary creature releases for coins", g0.outcome == "Granted" and p0.Coins > 0)
	local p1, helped = owned("Pass")
	local g1 = Grants.release(p1, helped.id, false)
	check(
		"a pass-boosted catch releases normally",
		g1.outcome == "Granted" and p1.Coins == p0.Coins
	)
	local p2, gemmed = owned("GemLasso")
	local g2 = Grants.release(p2, gemmed.id, false)
	local anyMaterial = false
	for key, count in p2.Items do
		anyMaterial = anyMaterial or (key ~= "Basic" and count > 0)
	end
	check(
		"a Gem-lasso catch releases for no coins and no materials",
		g2.outcome == "Granted"
			and p2.Coins == 0
			and not anyMaterial
			and p2.Creatures[gemmed.id] == nil
	)

	-- Breeding keeps the mark; "GemLasso" outranks "Pass".
	local function child(a: string?, b: string?): string?
		local pa = Breeding.wild("Brindle", "ba", 10, "Common", "Moss", rng)
		local pb = Breeding.wild("Dartlet", "bb", 10, "Common", "Sand", rng)
		pa.paidAssist = a :: any
		pb.paidAssist = b :: any
		return Breeding.breed(pa, pb, Rng.new(3), { childId = "kid", now = 1000 }).child.paidAssist
	end
	check("a child of unmarked parents is unmarked", child(nil, nil) == nil)
	check("a child of a Pass parent is marked Pass", child("Pass", nil) == "Pass")
	check("a child of a Gem-lasso parent is marked GemLasso", child(nil, "GemLasso") == "GemLasso")
	check("GemLasso outranks Pass", child("Pass", "GemLasso") == "GemLasso")

	-- The pass's rarities are explicit, and none of them flee.
	local fleeAfter = require("../src/config/LassoConfig").FLEE_AFTER_MISSES :: { [string]: number }
	local consistent = true
	for rarity, listed in PurchaseConfig.LASSO_PASS_RARITIES do
		consistent = consistent and listed and fleeAfter[rarity] ~= nil and fleeAfter[rarity] <= 0
	end
	check("every rarity the pass lists never flees", consistent)
	local profile = Profile.template()
	PassEffects.grant(profile, "LassoPass")
	check(
		"only the listed rarities are boosted",
		PassEffects.lassoBoostApplies(profile, false, "Common", false)
			and PassEffects.lassoBoostApplies(profile, false, "Uncommon", false)
			and not PassEffects.lassoBoostApplies(profile, false, "Gem", false)
			and not PassEffects.lassoBoostApplies(profile, false, "Cosmic", false)
			and not PassEffects.lassoBoostApplies(profile, false, "Nonsense", false)
	)
	local LiveConfig = require("../src/config/LiveConfig")
	check(
		"the chance display switch exists and is on by default",
		LiveConfig.DEFAULTS.chance_display
	)
	check(
		"and it cannot be a built-off feature",
		table.find(LiveConfig.NOT_BUILT, "chance_display" :: any) == nil
	)

	-- An egg already finished but not hatched takes the last room first.
	local crowded = Profile.template()
	crowded.Pens = 2
	crowded.Gems = 100
	crowded.StableCapacity = 2
	local filler = Breeding.wild("Brindle", "fill", 3, "Common", "Moss", rng)
	local e1 = Breeding.wild("Brindle", "e1", 3, "Common", "Moss", rng)
	local e2 = Breeding.wild("Dartlet", "e2", 3, "Common", "Sand", rng)
	crowded.Creatures[filler.id] = filler
	table.insert(crowded.Eggs, { child = e1, hatchAt = 500, seed = 1 }) -- ready, waiting for room
	table.insert(crowded.Eggs, { child = e2, hatchAt = 20000, seed = 2 })
	check(
		"room is counted after the eggs already finished",
		Gems.finishEgg(crowded, 20000, 1000) == nil and crowded.Gems == 100
	)
	crowded.StableCapacity = 3
	crowded.Gems = 500
	check("with room for both it works", Gems.finishEgg(crowded, 20000, 1000) ~= nil)
end

------------------------------------------------------------------------------------------------
print("\n== The Gem ledger ==")
do
	local profile = Profile.template()
	local line = Gems.change(profile, 50, "test")
	check(
		"a credit is applied and logged",
		line ~= nil
			and profile.Gems == 50
			and line.before == 0
			and line.after == 50
			and line.delta == 50
	)
	local spent = Gems.change(profile, -20, "test")
	check(
		"a spend is applied and logged",
		spent ~= nil and profile.Gems == 30 and spent.after == 30
	)
	local over, why = Gems.change(profile, -31, "test")
	check("a spend past the balance is refused", over == nil and profile.Gems == 30, why)
	check(
		"exactly the balance is allowed",
		Gems.change(profile, -30, "test") ~= nil and profile.Gems == 0
	)
	local badAmounts: { any } =
		{ 0, 1.5, 0 / 0, math.huge, -math.huge, "5", PurchaseConfig.MAX_GEM_CHANGE + 1 }
	for _, bad in badAmounts do
		check(
			`a bad amount ({tostring(bad)}) is refused`,
			Gems.change(profile, bad, "test") == nil and profile.Gems == 0
		)
	end
	check(
		"a change with no reason is refused",
		Gems.change(profile, 5, "") == nil and Gems.change(profile, 5, nil) == nil
	)
	profile.Gems = PurchaseConfig.MAX_GEMS
	check("a credit past the limit is refused", Gems.change(profile, 1, "test") == nil)
end

------------------------------------------------------------------------------------------------
print("\n== Spending Gems on consumables ==")
do
	local profile = Profile.template()
	profile.Gems = 100
	profile.Story.biomeReached = 4

	check(
		"Breeding Candy is never sold",
		Gems.itemPrice("BreedingCandy") == nil
			and Gems.itemPrice("Candy") == nil
			and Gems.itemPrice("Prism") == nil
	)
	check("a Giant Horn is coin-only", Gems.itemPrice("GiantCall") == nil)
	check(
		"Tide Bait is not sold for Gems until its odds screen exists",
		Gems.itemPrice("Bait") == nil
	)
	check("a Bond Charm is coin-only", Gems.itemPrice("BondCharm") == nil)
	check(
		"an unknown item is not sold",
		Gems.itemPrice("Free") == nil and Gems.itemPrice(5) == nil and Gems.itemPrice(nil) == nil
	)
	for _, id in { "Basic", "Braided", "Gilded", "Tonic", "GreatTonic", "Revive", "Cure" } do
		check(`{id} has a Gem price`, (Gems.itemPrice(id) or 0) >= EconomyConfig.GEM_MIN_PRICE)
	end
	check(
		"a price is the coin price over the rate, rounded up",
		Gems.itemPrice("Gilded") == math.ceil(250 / EconomyConfig.COINS_PER_GEM)
	)

	local bought, why = Gems.buyItem(profile, "Tonic", 3, true)
	local price = Gems.itemPrice("Tonic") :: number
	check(
		"a purchase takes the Gems and gives the items",
		bought ~= nil and profile.Items.Tonic == 3 and profile.Gems == 100 - 3 * price,
		why
	)
	check(
		"and returns its log line",
		bought ~= nil and bought.line.delta == -3 * price and bought.gems == 3 * price
	)
	check("coins are untouched", profile.Coins == 0)

	local before = profile.Gems
	check(
		"not at a shop is refused",
		Gems.buyItem(profile, "Tonic", 1, false) == nil and profile.Gems == before
	)
	check(
		"a Giant Horn is refused",
		Gems.buyItem(profile, "GiantCall", 1, true) == nil and profile.Gems == before
	)
	check(
		"a Bond Charm is refused",
		Gems.buyItem(profile, "BondCharm", 1, true) == nil and profile.Gems == before
	)
	local badCounts: { any } = { 0, -1, 1.5, 100, "3", 0 / 0 }
	for _, count in badCounts do
		check(
			`a bad count ({tostring(count)}) is refused`,
			Gems.buyItem(profile, "Tonic", count, true) == nil and profile.Gems == before
		)
	end
	profile.Gems = 1
	local poor = Gems.buyItem(profile, "Cure", 1, true)
	check(
		"not enough Gems: refused, nothing taken or given",
		poor == nil and profile.Gems == 1 and (profile.Items.Cure or 0) == 0
	)
	profile.Gems = 100
	profile.Story.biomeReached = 1
	check(
		"an item the biome has not unlocked is refused",
		Gems.buyItem(profile, "Cure", 1, true) == nil and profile.Gems == 100
	)
	profile.Story.biomeReached = 4
	profile.Items.Tonic = Shop.MAX_HELD
	check(
		"over the carry limit is refused",
		Gems.buyItem(profile, "Tonic", 1, true) == nil and profile.Gems == 100
	)
	check("the saved record is sound", #Profile.validate(profile) == 0)

	-- Gem lassos: only where paid random items are not restricted, under their own key.
	local lassoer = Profile.template()
	lassoer.Gems = 200
	for _, tier in { "Basic", "Braided", "Gilded" } do
		local whenRestricted = Gems.buyItem(lassoer, tier, 1, true, true)
		local whenUnknown = Gems.buyItem(lassoer, tier, 1, true, nil)
		check(
			`a {tier} lasso is refused when the policy is restricted or not known yet`,
			whenRestricted == nil
				and whenUnknown == nil
				and lassoer.Gems == 200
				and next(lassoer.Items) == nil
		)
	end
	local open = Gems.buyItem(lassoer, "Braided", 2, true, false)
	check(
		"an unrestricted player gets a Gem lasso under its own key",
		open ~= nil
			and lassoer.Items.Braided_g == 2
			and lassoer.Items.Braided == nil
			and lassoer.Gems == 200 - 2 * (Gems.itemPrice("Braided") :: number)
	)
	check("the key is stable", Capture.GEM_LASSO_SUFFIX == "_g")
	local tonic = Gems.buyItem(lassoer, "Tonic", 1, true, true)
	check("a tonic is not a random item, so a restricted player may buy it", tonic ~= nil)
	check("the saved record is sound with Gem lassos", #Profile.validate(lassoer) == 0)
end

------------------------------------------------------------------------------------------------
print("\n== Finishing an egg ==")
do
	check(
		"the cost is 1 per 3 minutes, at least 5",
		Gems.eggFinishCost(60) == 5
			and Gems.eggFinishCost(15 * 60) == 5
			and Gems.eggFinishCost(16 * 60) == 6
			and Gems.eggFinishCost(60 * 60) == 20
	)
	check(
		"nothing left costs the minimum",
		Gems.eggFinishCost(-5) == EconomyConfig.EGG_FINISH_MIN_GEMS
	)

	local profile = Profile.template()
	profile.Pens = 2
	local rng = Rng.new(9)
	local a = Breeding.wild("Brindle", "a", 10, "Common", "Moss", rng)
	local b = Breeding.wild("Dartlet", "b", 9, "Common", "Sand", rng)
	table.insert(profile.Eggs, { child = a, hatchAt = 10000, seed = 1 })
	table.insert(profile.Eggs, { child = b, hatchAt = 20000, seed = 2 })
	profile.Gems = 100
	local now = 9000
	local done, why = Gems.finishEgg(profile, 10000, now)
	check(
		"finishing takes the Gems and makes it ready",
		done ~= nil
			and profile.Eggs[1].hatchAt == now
			and profile.Gems == 100 - Gems.eggFinishCost(1000),
		why
	)
	check("the other egg is untouched", profile.Eggs[2].hatchAt == 20000)
	-- A full stable: refused, and not charged.
	local crowded = Profile.template()
	crowded.Pens = 2
	crowded.Gems = 100
	crowded.StableCapacity = 1
	local filler = Breeding.wild("Brindle", "filler", 3, "Common", "Moss", rng)
	crowded.Creatures[filler.id] = filler
	table.insert(crowded.Eggs, { child = b, hatchAt = 20000, seed = 2 })
	check(
		"a full stable refuses the finish and does not charge",
		Gems.finishEgg(crowded, 20000, now) == nil
			and crowded.Gems == 100
			and crowded.Eggs[1].hatchAt == 20000
	)
	check("the child is untouched", profile.Eggs[1].child == a)
	local again = Gems.finishEgg(profile, 10000, now)
	check("an egg that is already ready is refused", again == nil)
	check("an egg that is not there is refused", Gems.finishEgg(profile, 12345, now) == nil)
	check(
		"a bad value is refused",
		Gems.finishEgg(profile, "20000", now) == nil
			and Gems.finishEgg(profile, 0 / 0, now) == nil
			and Gems.finishEgg(profile, nil, now) == nil
	)
	profile.Gems = 2
	check(
		"not enough Gems: refused and nothing changes",
		Gems.finishEgg(profile, 20000, now) == nil
			and profile.Gems == 2
			and profile.Eggs[2].hatchAt == 20000
	)
end

------------------------------------------------------------------------------------------------
print("\n== Policy is read safely ==")
do
	local function read(info: unknown)
		return Purchases.readPolicy(info)
	end
	check("nothing at all means restricted", read(nil).restricted and not read(nil).tradingAllowed)
	check("a missing field means restricted", read({}).restricted)
	check("a wrong type means restricted", read({ ArePaidRandomItemsRestricted = "no" }).restricted)
	check(
		"only an exact false opens it",
		not read({ ArePaidRandomItemsRestricted = false }).restricted
	)
	check("true is restricted", read({ ArePaidRandomItemsRestricted = true }).restricted)
	check(
		"trading is allowed only on an exact true",
		read({ IsPaidItemTradingAllowed = true }).tradingAllowed
			and not read({ IsPaidItemTradingAllowed = 1 }).tradingAllowed
			and not read({}).tradingAllowed
	)
	check(
		"keys from the device are parsed",
		Purchases.parseProduct("Gems99") == "Gems99"
			and PassEffects.parse("LassoPass") == "LassoPass"
			and Purchases.parseProduct("LassoPass") == nil
			and Purchases.parseProduct("../x") == nil
			and Purchases.parseProduct(7) == nil
	)
end

restoreIds()

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("purchase checks failed")
end
