--!strict
-- Checks for buying at a shop and using items in a battle.
-- Run from the project folder:  lune run tests/shop.test

local BattleSession = require("../src/shared/BattleSession")
local Breeding = require("../src/shared/Breeding")
local Economy = require("../src/shared/Economy")
local EconomyConfig = require("../src/config/EconomyConfig")
local Profile = require("../src/shared/Profile")
local Rng = require("../src/shared/Rng")
local Shop = require("../src/shared/Shop")

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

print("\n== Buying ==")
do
	local profile = Profile.template()
	profile.Coins = 200
	check(
		"a made-up item is refused",
		Shop.buy(profile, "GoldBar", 1, true, 1) == nil and Shop.buy(profile, 7, 1, true, 1) == nil
	)
	check(
		"a bad amount is refused",
		Shop.buy(profile, "Basic", 0, true, 1) == nil
			and Shop.buy(profile, "Basic", -3, true, 1) == nil
			and Shop.buy(profile, "Basic", 1.5, true, 1) == nil
			and Shop.buy(profile, "Basic", 0 / 0, true, 1) == nil
			and Shop.buy(profile, "Basic", "2", true, 1) == nil
	)
	check("buying needs the player at the shop", Shop.buy(profile, "Basic", 1, false, 1) == nil)
	check(
		"an item sold only in later biomes is refused",
		Shop.buy(profile, "Bait", 1, true, 1) == nil
	)
	check(
		"nothing changed after the refusals",
		profile.Coins == 200 and (profile.Items.Basic or 0) == 0
	)
	local price = Economy.itemPrice("Basic", 1)
	local bought = Shop.buy(profile, "Basic", 4, true, 1)
	check(
		"a purchase takes the price and gives the items",
		bought ~= nil and profile.Coins == 200 - 4 * price and profile.Items.Basic == 4
	)
	check(
		"too few coins is refused, and nothing changes",
		Shop.buy(profile, "Gilded", 1, true, 1) == nil and profile.Coins == 200 - 4 * price
	)
	profile.Coins = 1000000
	profile.Items.Basic = 950
	check(
		"a player cannot carry more than the limit",
		Shop.buy(profile, "Basic", 60, true, 1) == nil
			and Shop.buy(profile, "Basic", 49, true, 1) ~= nil
	)
	check(
		"the record is sound",
		#Profile.validate(profile) == 0,
		table.concat(Profile.validate(profile), "; ")
	)
end

print("\n== Prices follow the player, not the shop ==")
do
	local far = Profile.template()
	far.Coins = 100000
	far.Story.biomeReached = 3
	local bought = assert(Shop.buy(far, "GiantCall", 1, true, 1), "horn is bought")
	check(
		"the horn is kept at the grade it was priced at",
		far.Items[Economy.hornKey(3)] == 1 and (far.Items.GiantCall or 0) == 0
	)
	check(
		"a player who has reached a later biome pays its price in the first town",
		bought.coins == Economy.itemPrice("GiantCall", 3)
			and bought.coins > Economy.itemPrice("GiantCall", 1)
	)
	local charm = assert(Shop.buy(far, "BondCharm", 2, true, 1), "charms are bought")
	check("the same for Bond Charms", charm.coins == 2 * Economy.itemPrice("BondCharm", 3))
	local whole = true
	for biome = 1, 11 do
		for _, item: EconomyConfig.ItemId in EconomyConfig.ITEM_IDS do
			local price = Economy.itemPrice(item, biome)
			whole = whole and price == math.floor(price) and price > 0
		end
	end
	check("every price in every biome is a whole number of coins", whole)
end

print("\n== Stable room ==")
do
	local profile = Profile.template()
	local start = profile.StableCapacity
	profile.Coins = EconomyConfig.STABLE_EXPANSION_COINS[1] - 1
	check(
		"too few coins buys nothing",
		Shop.expandStable(profile, true) == nil and profile.StableCapacity == start
	)
	profile.Coins = 10000000
	check("it must be bought at the shop", Shop.expandStable(profile, false) == nil)
	local paid = Shop.expandStable(profile, true)
	check(
		"the first expansion costs its listed price and adds room",
		paid == EconomyConfig.STABLE_EXPANSION_COINS[1]
			and profile.StableCapacity == start + EconomyConfig.STABLE_EXPANSION_SLOTS
	)
	local rising = true
	local last = paid or 0
	for _ = 2, #EconomyConfig.STABLE_EXPANSION_COINS do
		local price = Shop.expandStable(profile, true)
		rising = rising and price ~= nil and price > last
		last = price or last
	end
	check("each expansion costs more than the one before", rising)
	check(
		"when every expansion is bought there are no more",
		Shop.expandStable(profile, true) == nil and Shop.nextStablePrice(profile) == nil
	)
	check(
		"the stable ends at its full size",
		profile.StableCapacity
			== start
				+ #EconomyConfig.STABLE_EXPANSION_COINS * EconomyConfig.STABLE_EXPANSION_SLOTS
	)
	check(
		"the record is sound",
		#Profile.validate(profile) == 0,
		table.concat(Profile.validate(profile), "; ")
	)
end

check(
	"the stable's starting size is the same in both configs that name it",
	Profile.template().StableCapacity == EconomyConfig.STABLE_FREE_SLOTS
)

print("\n== Crafting ==")
do
	local profile = Profile.template()
	local recipe = EconomyConfig.RECIPES.Tonic
	check(
		"something with no recipe cannot be made",
		Shop.craft(profile, "Gilded") == nil and Shop.craft(profile, 5) == nil
	)
	check("without the material nothing is made", Shop.craft(profile, "Tonic") == nil)
	profile.Items.Fernfluff = recipe.count * 2 + 1
	local coins = profile.Coins
	check(
		"with the material, one is made and the material is used up",
		Shop.craft(profile, "Tonic") == "Tonic"
			and profile.Items.Tonic == 1
			and profile.Items.Fernfluff == recipe.count + 1
			and profile.Coins == coins - recipe.coins
	)
	profile.Items.BrineShell = 100
	profile.Coins = 10000
	check(
		"bait cannot be made before Tide Flats",
		Shop.craft(profile, "Bait") == nil and profile.Items.BrineShell == 100
	)
	profile.Story.biomeReached = 3
	local before = profile.Coins
	check(
		"from Tide Flats on it can, for its shells and coins",
		Shop.craft(profile, "Bait") == "Bait"
			and profile.Items.BrineShell == 100 - EconomyConfig.RECIPES.Bait.count
			and profile.Coins == before - EconomyConfig.RECIPES.Bait.coins
	)
	profile.Coins = 0
	check(
		"a recipe that costs coins needs them",
		Shop.craft(profile, "Bait") == nil and profile.Items.Bait == 1
	)
	check(
		"making an item is cheaper than buying it, but never free of materials",
		EconomyConfig.RECIPES.Bait.coins < Economy.itemPrice("Bait", 3)
			and EconomyConfig.RECIPES.Bait.count > 0
	)
	check(
		"the record is sound",
		#Profile.validate(profile) == 0,
		table.concat(Profile.validate(profile), "; ")
	)
end

print("\n== Items in a battle ==")
do
	local function setup(): (Profile.Profile, BattleSession.Session)
		local profile = Profile.template()
		local rng = Rng.new(3)
		local a = Breeding.wild("Mossmitt", "a", 10, "Common", "Moss", rng)
		local b = Breeding.wild("Gorsling", "b", 10, "Common", "Moss", rng)
		profile.Creatures.a, profile.Creatures.b = a, b
		profile.Team = { "a", "b" }
		profile.Items.Tonic, profile.Items.Revive = 2, 1
		local wild = Breeding.wild("Spadesnout", "wild", 3, "Common", "Sand", rng)
		local session = assert(
			BattleSession.start({
				battleId = 1,
				kind = "Wild",
				yours = { a, b },
				theirs = { wild },
				theirMoves = nil,
				tier = "Wild",
				seed = 5,
				levelCap = 15,
			}),
			"battle starts"
		)
		return profile, session
	end

	local profile, session = setup()
	local team = session.state.sides[1].team
	check(
		"a tonic on an unhurt creature is refused and kept",
		Shop.useInBattle(profile, session, 1, "Tonic", 1) == nil and profile.Items.Tonic == 2
	)
	check("a lasso is not a battle item", Shop.useInBattle(profile, session, 1, "Basic", 1) == nil)
	check(
		"a Rally Root on a standing creature is refused",
		Shop.useInBattle(profile, session, 1, "Revive", 1) == nil and profile.Items.Revive == 1
	)
	team[1].hp = 5
	check("the wrong turn is refused", Shop.useInBattle(profile, session, 4, "Tonic", 1) == nil)
	check(
		"a team position that does not exist is refused",
		Shop.useInBattle(profile, session, 1, "Tonic", 5) == nil
			and Shop.useInBattle(profile, session, 1, "Tonic", "1") == nil
	)
	local turn = assert(Shop.useInBattle(profile, session, 1, "Tonic", 1), "tonic is used")
	check("a tonic is used up", profile.Items.Tonic == 1)
	local event = turn.events[1]
	check(
		"it heals 40% of full health",
		event.kind == "Item" and event.targetHp == 5 + math.floor(team[1].stats.Hp * 0.4)
	)
	check(
		"it spends the turn: the wild creature acts",
		session.state.turn == 1 and #turn.events >= 2
	)
	check(
		"the same turn cannot be used twice",
		Shop.useInBattle(profile, session, 1, "Tonic", 1) == nil
	)

	team[2].hp = 0
	local revived = assert(Shop.useInBattle(profile, session, 2, "Revive", 2), "root is used")
	check(
		"a Rally Root brings a fallen creature back at half health",
		revived.events[1].targetHp == math.floor(team[2].stats.Hp * 0.5)
			and profile.Items.Revive == 0
	)
	check("with none left it is refused", Shop.useInBattle(profile, session, 3, "Revive", 2) == nil)

	local empty, other = setup()
	empty.Items.Tonic = 0
	other.state.sides[1].team[1].hp = 5
	check(
		"an item the player does not have is refused",
		Shop.useInBattle(empty, other, 1, "Tonic", 1) == nil and other.state.turn == 0
	)
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("shop checks failed")
end
