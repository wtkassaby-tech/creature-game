--!strict
-- Economy invariants and a fast simulation of three player types over 30 days.
-- Run: lune run tests/economy.test
-- The model and the full tables are in docs/ECONOMY_MODEL.md. Set RUN_LONG_EXPLORATION to true
-- for more seeds and the per-day log (slower; not part of the gate).
--
-- Longer than ~400 lines on purpose: the simulation is one piece and reads best in one file.
--
-- Everything under ASSUME and PROFILES is a guess about how people play (battle lengths,
-- miss rates, how often they breed), not a balance number, so it lives here and not in src/config.

local BreedConfig = require("../src/config/BreedConfig")
local Breeding = require("../src/shared/Breeding")
local Economy = require("../src/shared/Economy")
local EconomyConfig = require("../src/config/EconomyConfig")
local Rng = require("../src/shared/Rng")
local Species = require("../src/content/Species")
local TypeChart = require("../src/shared/TypeChart")
local Types = require("../src/shared/Types")
local Placeholders = require("./fixtures/Placeholders")

Placeholders.install()

-- One test-only species per type, so simulated creatures carry real types (the torso's element
-- decides which candy a parent needs). Copies of the placeholder Mossback with the element changed.
for _, element: Types.Element in TypeChart.ELEMENTS do
	local def = table.clone(Species.Mossback)
	def.name = `Sim{element}`
	def.element = element
	Species[def.name] = def
end

local RUN_LONG_EXPLORATION = false

type Creature = Types.Creature
type Element = Types.Element
type ItemId = EconomyConfig.ItemId
type LassoTier = EconomyConfig.LassoTier

local passed, failed = 0, 0
local function check(name: string, condition: boolean, detail: string?)
	if condition then
		passed += 1
		print(`  PASS  {name}{if detail then "  (" .. detail .. ")" else ""}`)
	else
		failed += 1
		print(`  FAIL  {name}{if detail then "  (" .. detail .. ")" else ""}`)
	end
end

local RARITIES: { Types.Rarity } = { "Common", "Uncommon", "Gem", "Ruby", "Diamond", "Cosmic" }
local KINDS: { EconomyConfig.BattleKind } = { "Wild", "Tamer", "Gate", "Giant" }

------------------------------------------------------------------------------------------------
print("\n== Invariants ==")
------------------------------------------------------------------------------------------------
do
	-- Every price and reward is positive.
	local allPositive, bad = true, ""
	for _, item: ItemId in EconomyConfig.ITEM_IDS do
		for biome = 1, 11 do
			if not (Economy.itemPrice(item, biome) > 0) then
				allPositive, bad = false, `price {item} biome {biome}`
			end
		end
	end
	for _, kind: EconomyConfig.BattleKind in KINDS do
		for biome = 1, 11 do
			local band = EconomyConfig.LEVEL_BANDS[biome]
			for _, level in { 1, band.min, band.max, 100 } do
				if not (Economy.battleCoins(kind, biome, level, 0, true) > 0) then
					allPositive, bad = false, `first clear {kind} {biome}`
				end
				if not (Economy.battleCoins(kind, biome, level, 0, false) > 0) then
					allPositive, bad = false, `rematch {kind} {biome}`
				end
			end
		end
	end
	for _, rarity: Types.Rarity in RARITIES do
		for biome = 1, 11 do
			if not (Economy.releasePayout(rarity, biome).coins > 0) then
				allPositive, bad = false, `release {rarity} {biome}`
			end
		end
	end
	for _, source: EconomyConfig.CandySource in EconomyConfig.CANDY_SOURCES do
		if not (Economy.candyFor(source, 0, 1) > 0) then
			allPositive, bad = false, `candy {source}`
		end
	end
	for _, rarity: Types.Rarity in RARITIES do
		if not (Economy.catchCandy(rarity, 0) > 0) then
			allPositive, bad = false, `catch candy {rarity}`
		end
	end
	for index, price in EconomyConfig.STABLE_EXPANSION_COINS do
		if
			not (price > 0)
			or index > 1 and price <= EconomyConfig.STABLE_EXPANSION_COINS[index - 1]
		then
			allPositive, bad = false, "stable expansion prices must be positive and rising"
		end
	end
	allPositive = allPositive
		and Economy.questLineCoins(1) > 0
		and Economy.dailyTaskCoins(false, 1, 0) > 0
		and Economy.dailyTaskCoins(true, 1, 0) > 0
		and Economy.weeklyChallengeCoins(1, 0) > 0
		and Economy.casualPvpCoins(0, false, true, 1) > 0
		and EconomyConfig.STARTING_COINS > 0
	check("every price and reward is positive", allPositive, bad)

	-- Every source of coins or candy has a cap or a diminishing rule.
	local capped, uncapped = true, ""
	for name, flow in EconomyConfig.FLOWS do
		if flow.limit ~= "Sink" then
			local ok = flow.limit == "Diminishing"
				or flow.limit == "Daily"
				or flow.limit == "Weekly"
				or flow.limit == "Once"
				or flow.limit == "BelowCost"
			if not ok then
				capped, uncapped = false, name
			end
		end
	end
	for _, source: EconomyConfig.CandySource in EconomyConfig.CANDY_SOURCES do
		local def = EconomyConfig.CANDY[source]
		if not (def.cap > 0 and def.cap < math.huge) or def.limit == "Sink" then
			capped, uncapped = false, source
		end
		if Economy.candyFor(source, def.cap, 1) ~= 0 then
			capped, uncapped = false, `{source} pays past its cap`
		end
	end
	-- Typed candy: never rising within a day, nothing from the stop onwards, whole candies only.
	local catchTotal, releaseTotal = 0, 0
	for _, rarity: Types.Rarity in RARITIES do
		for _, which in { "catch", "release" } do
			local rule = if which == "catch"
				then EconomyConfig.CATCH_FALLOFF
				else EconomyConfig.RELEASE_FALLOFF
			local total = 0
			for prior = 0, rule.stop + 10 do
				local pay = if which == "catch"
					then Economy.catchCandy(rarity, prior)
					else Economy.releaseCandy(rarity, prior)
				if pay < 0 or pay ~= math.floor(pay) or (prior >= rule.stop and pay ~= 0) then
					capped, uncapped = false, `{which} candy {rarity} at {prior}`
				end
				total += pay
				if
					prior > 0
					and Economy.candyFalloff(rule, prior)
						> Economy.candyFalloff(rule, prior - 1)
				then
					capped, uncapped = false, `{which} falloff rises at {prior}`
				end
			end
			if rarity == "Common" then
				if which == "catch" then
					catchTotal = total
				else
					releaseTotal = total
				end
			end
		end
	end
	check(
		"every faucet in the ledger is capped, once-only, diminishing or below cost",
		capped,
		uncapped
	)
	check(
		"typed candy per type per day is bounded: a whole day of common catches and releases of one type",
		catchTotal > 0 and catchTotal <= 20 and releaseTotal <= catchTotal,
		`catches pay at most {catchTotal}, releases at most {releaseTotal}`
	)

	-- The diminishing rule: never rising, reaches zero, and total wild coins per kind per day are bounded.
	local monotone, total = true, 0
	for prior = 0, EconomyConfig.DIMINISH_STOP + 10 do
		local now = Economy.battleCoins("Wild", 3, 30, prior, false)
		if prior > 0 and now > Economy.battleCoins("Wild", 3, 30, prior - 1, false) then
			monotone = false
		end
		total += now
	end
	local full = Economy.battleCoins("Wild", 3, 30, 0, false)
	check(
		"wild rewards per kind per day never rise and stop at DIMINISH_STOP",
		monotone and Economy.battleCoins("Wild", 3, 30, EconomyConfig.DIMINISH_STOP, false) == 0,
		string.format("a whole day on one kind pays %.1f full wins", total / full)
	)
	check(
		"rematch rewards stop after the daily paid rematches",
		Economy.battleCoins("Giant", 1, 5, EconomyConfig.TRAINED.Giant.rematchesPaidPerDay, false)
				== 0
			and Economy.battleCoins(
					"Tamer",
					1,
					5,
					EconomyConfig.TRAINED.Tamer.rematchesPaidPerDay,
					false
				)
				== 0
	)
	check(
		"casual PvP pays nothing past the daily cap, for a repeat opponent or outside matchmaking",
		Economy.casualPvpCoins(EconomyConfig.CASUAL_PVP_PAID_WINS_PER_DAY, false, true, 3) == 0
			and Economy.casualPvpCoins(0, true, true, 3) == 0
			and Economy.casualPvpCoins(0, false, false, 3) == 0
	)
	check(
		"a giant rematch pays less than its Giant Horn costs (rematches are a coin sink)",
		Economy.battleCoins("Giant", 3, 32, 0, false) < Economy.itemPrice("GiantCall", 3)
	)
	local sinkEverywhere = true
	for biome = 1, 11 do
		for level = 1, 120 do
			if
				Economy.battleCoins("Giant", biome, level, 0, false)
				>= Economy.itemPrice("GiantCall", biome)
			then
				sinkEverywhere = false
			end
		end
	end
	check("and that holds in every biome at every level", sinkEverywhere)

	-- Releasing always pays less than catching or breeding the creature costs.
	local below, worst, worstShare = true, "", 0
	for _, rarity: Types.Rarity in RARITIES do
		for biome = 1, 11 do
			local pay = Economy.releasePayout(rarity, biome)
			local value = pay.coins
			if pay.material then
				value += pay.materials * Economy.materialValue(pay.material)
			end
			local catchCost = Economy.minCatchCost(rarity)
			local share = value / catchCost
			if share > worstShare then
				worst, worstShare = `{rarity} biome {biome}`, share
			end
			if value >= catchCost then
				below = false
			end
			if rarity ~= "Cosmic" then
				local a = Breeding.wild("Mossback", "ra", 10, rarity, "Moss", Rng.new(biome))
				local b = Breeding.wild("Mossback", "rb", 10, rarity, "Moss", Rng.new(biome + 50))
				a.originBiome, b.originBiome = biome, biome
				if value >= Breeding.cost(a, b) then
					below = false
				end
			end
		end
	end
	check(
		"releasing pays less than the cheapest catch and less than a breed, for every rarity and biome",
		below,
		string.format("highest: %s at %.0f%% of its catch cost", worst, worstShare * 100)
	)
	-- And in candy: a release pays less than the catch, and less than the cheapest breed that can
	-- make a creature of that rarity (one parent of that rarity, one common; two commons for Common).
	local candyBelow, candyText = true, {}
	for _, rarity: Types.Rarity in RARITIES do
		if rarity ~= "Cosmic" then
			local a = Breeding.wild("SimSand", "ca", 10, rarity, "Moss", Rng.new(1))
			local b = Breeding.wild("SimLeaf", "cb", 10, "Common", "Moss", Rng.new(2))
			local breedCandy = Breeding.candyTotal(Breeding.candyCost(a, b))
			local release = EconomyConfig.RELEASE_CANDY[rarity]
			local catch = EconomyConfig.CATCH_CANDY[rarity]
			if not (release < catch and release < breedCandy) then
				candyBelow = false
			end
			table.insert(candyText, `{rarity} {release}/{catch}/{breedCandy}`)
			-- Over any number of claims in a day, releases never add up to more than catches.
			local releaseSum, catchSum = 0, 0
			for prior = 0, EconomyConfig.RELEASE_FALLOFF.stop + 5 do
				releaseSum += Economy.releaseCandy(rarity, prior)
				catchSum += Economy.catchCandy(rarity, prior)
				if releaseSum > catchSum then
					candyBelow = false
				end
			end
		end
	end
	check(
		"releasing pays less candy than catching and than the cheapest breed, for every rarity",
		candyBelow,
		`release/catch/breed: {table.concat(candyText, ", ")}`
	)

	-- Ledger refusals.
	local wallet = Economy.emptyWallet()
	wallet.typed.Leaf = 1
	wallet.prism = 1
	local start: Economy.Balances = { coins = 100, candy = wallet }
	local overdraw = Economy.apply(start, "Breed", 101)
	local candyOver = Economy.apply(start, "BreedCandy", 3, "Leaf")
	local noElement = Economy.apply(start, "CandyCatch", 2)
	local unknown = Economy.apply(start, "FreeMoney", 10)
	local fraction = Economy.apply(start, "WildWin", 2.5)
	local negative = Economy.apply(start, "WildWin", -5)
	local nan = Economy.apply(start, "WildWin", 0 / 0)
	local good = Economy.apply(start, "Shop", 100)
	check(
		"the ledger refuses overdrafts, unknown flows and bad amounts, and leaves balances alone",
		not overdraw.ok
			and not candyOver.ok
			and not noElement.ok
			and not unknown.ok
			and not fraction.ok
			and not negative.ok
			and not nan.ok
			and overdraw.balances.coins == 100
			and start.coins == 100
			and start.candy.typed.Leaf == 1
			and start.candy.prism == 1
	)
	local spent = Economy.apply(start, "BreedCandy", 2, "Leaf")
	local otherType = Economy.apply(start, "BreedCandy", 1, "Sand")
	local caught = Economy.apply(start, "CandyCatch", 3, "Water")
	local daily = Economy.apply(start, "CandyDaily", 2)
	check(
		"typed candy is spent first, then Prism; catches add to their own type; daily rewards add Prism",
		spent.ok
			and spent.balances.candy.typed.Leaf == 0
			and spent.balances.candy.prism == 0
			and (spent.record :: Economy.LedgerRecord).prismUsed == 1
			and otherType.ok
			and otherType.balances.candy.prism == 0
			and otherType.balances.candy.typed.Leaf == 1
			and caught.ok
			and caught.balances.candy.typed.Water == 3
			and caught.balances.candy.prism == 1
			and daily.ok
			and daily.balances.candy.prism == 3
			and start.candy.typed.Leaf == 1
	)

	-- Paying a breed: each type from its own balance, Prism for every shortfall, all or nothing.
	local purse = Economy.emptyWallet()
	purse.typed.Sand, purse.typed.Leaf, purse.prism = 3, 1, 2
	local mixed = Economy.candyPayment(purse, {
		{ element = "Sand", amount = 4 },
		{ element = "Leaf", amount = 1 },
	})
	local short = Economy.candyPayment(purse, {
		{ element = "Sand", amount = 4 },
		{ element = "Water", amount = 2 },
	})
	local paid = if mixed then Economy.payCandy(purse, mixed) else nil
	check(
		"a breed's candy is paid by type first and Prism covers the gaps, or not at all",
		mixed ~= nil
			and mixed.prism == 1
			and paid ~= nil
			and paid.typed.Sand == 0
			and paid.typed.Leaf == 0
			and paid.prism == 1
			and short == nil
			and purse.typed.Sand == 3
			and Economy.candyPayment(purse, { { element = "Sand", amount = 0 } }) == nil
			and Economy.candyPayment(purse, {
					{ element = "Sand", amount = 1 },
					{ element = "Sand", amount = 1 },
				})
				== nil
	)
	check(
		"the ledger applies a sink down to exactly zero and logs it",
		good.ok
			and good.balances.coins == 0
			and good.record ~= nil
			and (good.record :: Economy.LedgerRecord).before == 100
			and (good.record :: Economy.LedgerRecord).direction == "Out"
	)

	-- Random ledger walk: never below zero.
	local rng = Rng.new(77)
	local flows = {
		"WildWin",
		"Shop",
		"Breed",
		"Release",
		"BreedCandy",
		"CandyDaily",
		"CandyCatch",
		"CandyRelease",
		"Craft",
	}
	local bal: Economy.Balances = { coins = 0, candy = Economy.emptyWallet() }
	local negativeSeen = false
	for _ = 1, 20000 do
		local element: Element = TypeChart.ELEMENTS[Rng.int(rng, 1, #TypeChart.ELEMENTS)]
		local result = Economy.apply(bal, Rng.pick(rng, flows), Rng.int(rng, 1, 400), element)
		bal = result.balances
		if bal.coins < 0 or bal.candy.prism < 0 then
			negativeSeen = true
		end
		for _, e: Element in TypeChart.ELEMENTS do
			if bal.candy.typed[e] < 0 then
				negativeSeen = true
			end
		end
	end
	check("20,000 random ledger moves never take a balance below zero", not negativeSeen)

	-- The basics are always within reach.
	local basics = Economy.itemPrice("Basic", 1) + Economy.itemPrice("Tonic", 1)
	local twoWins = 2 * Economy.battleCoins("Wild", 1, 2, 0, false)
	check(
		"two fresh biome-1 wild wins buy a basic lasso and a healing item",
		twoWins >= basics,
		`{twoWins} coins against {basics}`
	)
	local prep =
		Economy.giantPrepCost(1, { "Tonic", "Tonic", "Tonic", "GreatTonic", "Revive", "Tonic" })
	check("the giant field-item cap is enforced", prep == nil)
end

------------------------------------------------------------------------------------------------
-- The simulation
------------------------------------------------------------------------------------------------

-- Guesses about play (see docs/ECONOMY_MODEL.md, "Inputs that are guesses").
local ASSUME = {
	WILD_MIN = 0.75, -- minutes per wild battle including finding it (battle itself 20 to 40 s)
	LASSO_MIN = 0.35, -- extra minutes for a lasso attempt
	THROW_MIN = 0.1, -- per throw
	TAMER_MIN = 2.5,
	GATE_MIN = 3.5,
	GIANT_MIN = 5,
	SHOP_MIN = 0.4,
	BREED_MIN = 0.5,
	HEAL_WALK_MIN = 0.4, -- walking back to the free healer instead of using a Tonic
	WEEKLY_MIN = 10,
	BAIT_MIN = 1.5,
	STORY_WILDS = { 22, 32, 42 }, -- wild battles a player fights on the way through each biome
	TAMERS = { 6, 8, 10 },
	QUEST_TRAVEL_MIN = { 4, 5, 6 }, -- per quest line, two lines per biome
	KINDS_PER_BIOME = 6,
	MISS = { Basic = 0.45, Braided = 0.30, Gilded = 0.15 },
	MAX_THROWS = 3, -- then the creature flees
	GEM_SPAWN = EconomyConfig.GEM_WILD_SHARE, -- chance a wild encounter in biome 2 or later is a gem creature
	BAIT_GEM = 0.35, -- chance a bait spawn is a gem creature
	GATE_WIN = 0.85,
	REMATCH_WIN = 0.8,
	GIANT_LEARN = 0.15, -- added to the win chance per earlier failed attempt
	GIANT_ITEM_BONUS = 0.03, -- per field item brought
	CHILD_REPLACES = 0.3, -- chance a hatched child replaces its more-bred parent in the pair
	MENTOR_MINUTE = 10,
	SURPLUS_DAYS = 3, -- players with more than this many days of income spend on optional sinks
	BREED_SKIP = 0, -- chance a player passes up a breed they could afford (sensitivity runs only)
	-- The type of each kind of wild creature, per biome (KINDS_PER_BIOME each). Greenwood follows
	-- its roster (five Leaf, two Water, one Sand species; about 64% of open encounters are Leaf,
	-- 23% Water, 14% Sand). Dust Canyon follows the roster being designed (mostly Sand). Tide Flats
	-- is a guess: a Water biome.
	KIND_ELEMENTS = {
		{ "Leaf", "Leaf", "Leaf", "Leaf", "Water", "Sand" },
		{ "Sand", "Sand", "Sand", "Sand", "Leaf", "Water" },
		{ "Water", "Water", "Water", "Water", "Toxic", "Sand" },
	} :: { { Element } },
	-- Greenwood's Sand species (the last kind) lives only on Route B, the second half of the story.
	GREENWOOD_ROUTE_A_SHARE = 0.5,
	-- The catch-and-release farming hour: every wild battle gets a lasso attempt, every catch is
	-- released at once.
	RELEASE_MIN = 0.1,
}

type Profile = {
	name: string,
	minutes: number,
	lassoStory: number, -- share of story wild battles with a lasso attempt
	lassoPost: number,
	tonicChance: number, -- chance per wild battle of using a Tonic rather than walking to the healer
	giantSkill: number, -- first attempt win chance on an on-level giant
	giantItems: { ItemId },
	rematches: number, -- giant rematches a day after the story
	tamerRematches: number,
	charmShare: number, -- share of breeds with a Bond Charm
	bait: number, -- bait uses a day after the story
	gemLasso: LassoTier,
	weeklyShare: number,
	releaseShare: number, -- share of hatched children released at once
	releaseCatchShare: number, -- share of caught commons released at once, after the story
	optionalSpend: boolean, -- buys stable expansions and charms when rich
	starter: Element, -- the starter's type; it is one parent of the first breeding pair
}

local PROFILES: { Profile } = {
	{
		name = "casual",
		minutes = 20,
		lassoStory = 0.4,
		lassoPost = 0.1,
		tonicChance = 0.25,
		giantSkill = 0.45,
		giantItems = { "Tonic", "Tonic", "Tonic", "GreatTonic" },
		rematches = 0,
		tamerRematches = 0,
		charmShare = 0,
		bait = 0,
		gemLasso = "Braided",
		weeklyShare = 0.5,
		releaseShare = 0.4,
		releaseCatchShare = 0.3,
		optionalSpend = true,
		starter = "Leaf",
	},
	{
		name = "regular",
		minutes = 45,
		lassoStory = 0.4,
		lassoPost = 0.12,
		tonicChance = 0.25,
		giantSkill = 0.55,
		giantItems = { "Tonic", "Tonic", "Tonic", "GreatTonic", "Revive" },
		rematches = 1,
		tamerRematches = 2,
		charmShare = 0.15,
		bait = 1,
		gemLasso = "Braided",
		weeklyShare = 1,
		releaseShare = 0.5,
		releaseCatchShare = 0.5,
		optionalSpend = true,
		starter = "Leaf",
	},
	{
		name = "heavy",
		minutes = 120,
		lassoStory = 0.4,
		lassoPost = 0.15,
		tonicChance = 0.2,
		giantSkill = 0.65,
		giantItems = { "Tonic", "Tonic", "GreatTonic", "GreatTonic", "Revive" },
		rematches = 2,
		tamerRematches = 5,
		charmShare = 0.4,
		bait = 3,
		gemLasso = "Gilded",
		weeklyShare = 1,
		releaseShare = 0.6,
		releaseCatchShare = 0.6,
		optionalSpend = true,
		starter = "Leaf",
	},
}

type Pair = { a: Creature, b: Creature }
type Egg = {
	readyAt: number, -- minutes
	rarity: Types.Rarity,
	biome: number,
	fromGem: boolean,
	element: Element,
}
type DayLog = {
	created: number,
	removed: number,
	minutes: number,
	breeds: number,
	candyIn: number, -- typed and Prism
	prismIn: number,
	typedIn: number,
	typedBy: Types.ByElement<number>,
	candyOut: number,
	catches: number,
	releases: number,
	balance: number,
	biome: number,
}
type Sim = {
	p: Profile,
	rng: Rng.Rng,
	bal: Economy.Balances,
	lassos: { Basic: number, Braided: number, Gilded: number },
	field: { Tonic: number, GreatTonic: number, Revive: number },
	mats: { Fernfluff: number, CanyonGrit: number, BrineShell: number },
	biome: number, -- story biome; 4 after Tide Flats
	wildsDone: number,
	tamersDone: number,
	questsDone: number,
	giantWon: boolean,
	giantFails: number,
	kindWins: { number },
	tamerPaid: { number },
	giantPaid: number,
	creatures: number,
	gems: number,
	catchesByType: Types.ByElement<number>, -- today, for the falloff
	releasesByType: Types.ByElement<number>,
	starterBreeds2d: number, -- breeds with a parent of the starter's type in days 1 and 2
	starterBlocked2d: number, -- times such a breed waited only for candy in days 1 and 2
	breeds2d: number,
	starterCandy2d: number, -- typed candy of the starter's type earned in days 1 and 2
	biomeCandy: { number }, -- candy earned (typed and Prism) while in each story biome
	expansions: number,
	pens: number,
	eggs: { Egg },
	pairs: { Pair },
	gemPair: Pair?,
	nextId: number,
	clock: number, -- absolute minutes
	sessionEnd: number,
	played: number,
	-- per day
	day: number,
	today: DayLog,
	wildWinsToday: number,
	catchesToday: number,
	breedsToday: number,
	giantRematchWinsToday: number,
	tamerRematchWinsToday: number,
	easyClaimed: { boolean },
	hardClaimed: { boolean },
	weeklyClaimedWeek: number,
	-- whole run
	log: { DayLog },
	totalCreated: number,
	totalRemoved: number,
	sinks: { [string]: number },
	candySources: { [string]: number },
	twoHour: { created: number, removed: number }?,
	ledgerRefusals: number,
	stuck: number, -- times a lasso or Tonic was needed and could not be afforded
	firstBreedPlayed: number?,
	firstBreedDay: number?,
	firstBreedOwnCandy: boolean,
	firstGemChildDay: number?,
	biomeClearDay: { number },
	biomeCreated: { number },
	biomeMinutes: { number },
	biomeRoutine: { number },
	giantFirstPrep: { number },
	giantAttempts: { number },
	giantGrind: { number }, -- longest grind (minutes) before any attempt in that biome
	grindNow: number,
	breedCoins: number,
	breedsTotal: number,
	gemBreeds: number,
	decor: number,
	sources: { [string]: number },
	twoHourSources: { [string]: number }?,
	twoHourSinks: { [string]: number }?,
}

local function newCreature(
	sim: Sim,
	rarity: Types.Rarity,
	biome: number,
	element: Element
): Creature
	sim.nextId += 1
	local c = Breeding.wild(`Sim{element}`, `s{sim.nextId}`, 5, rarity, "Moss", sim.rng)
	c.originBiome = biome
	return c
end

-- The type of a wild creature met in a biome. Greenwood's Sand kind is not on Route A.
local function wildKind(sim: Sim, biome: number): number
	local kinds = ASSUME.KINDS_PER_BIOME
	if
		biome == 1
		and sim.biome == 1
		and sim.wildsDone < ASSUME.STORY_WILDS[1] * ASSUME.GREENWOOD_ROUTE_A_SHARE
	then
		kinds -= 1
	end
	return Rng.int(sim.rng, 1, kinds)
end

local function randomElement(sim: Sim, biome: number): Element
	return ASSUME.KIND_ELEMENTS[math.min(biome, 3)][Rng.int(sim.rng, 1, ASSUME.KINDS_PER_BIOME)]
end

local function newPair(sim: Sim, biome: number): Pair
	return {
		a = newCreature(sim, "Common", biome, randomElement(sim, biome)),
		b = newCreature(sim, "Common", biome, randomElement(sim, biome)),
	}
end

local function newDay(biome: number): DayLog
	return {
		created = 0,
		removed = 0,
		minutes = 0,
		breeds = 0,
		candyIn = 0,
		prismIn = 0,
		typedIn = 0,
		typedBy = Economy.zeroByElement(),
		candyOut = 0,
		catches = 0,
		releases = 0,
		balance = 0,
		biome = biome,
	}
end

local function furthest(sim: Sim): number
	return math.min(sim.biome, 3)
end

local function flow(sim: Sim, name: string, amount: number, element: Element?)
	amount = math.floor(amount)
	if amount <= 0 then
		return
	end
	local result = Economy.apply(sim.bal, name, amount, element)
	if not result.ok then
		sim.ledgerRefusals += 1
		return
	end
	sim.bal = result.balances
	local def = EconomyConfig.FLOWS[name]
	local b = furthest(sim)
	if def.currency == "Coins" then
		if def.limit == "Sink" then
			sim.today.removed += amount
			sim.totalRemoved += amount
			sim.sinks[name] = (sim.sinks[name] or 0) + amount
		else
			sim.today.created += amount
			sim.totalCreated += amount
			sim.sources[name] = (sim.sources[name] or 0) + amount
			sim.biomeCreated[b] += amount
		end
	else
		if def.limit == "Sink" then
			sim.today.candyOut += amount
		else
			sim.today.candyIn += amount
			sim.candySources[name] = (sim.candySources[name] or 0) + amount
			if sim.biome <= 3 then
				sim.biomeCandy[sim.biome] += amount
			end
			if def.currency == "Prism" then
				sim.today.prismIn += amount
			elseif element then
				sim.today.typedIn += amount
				sim.today.typedBy[element] += amount
				if sim.day <= 2 and element == sim.p.starter then
					sim.starterCandy2d += amount
				end
			end
		end
	end
end

-- Spend coins if affordable. routine = everyday spending (lassos, healing, breeding), used for
-- the "spare coins per session" measure.
local function spend(sim: Sim, name: string, amount: number, routine: boolean): boolean
	if sim.bal.coins < amount then
		return false
	end
	flow(sim, name, amount)
	if routine then
		sim.biomeRoutine[furthest(sim)] += amount
	end
	return true
end

local function advance(sim: Sim, minutes: number)
	sim.clock += minutes
	sim.played += minutes
	sim.today.minutes += minutes
	sim.biomeMinutes[furthest(sim)] += minutes
	if sim.twoHour == nil and sim.played >= 120 then
		sim.twoHour = { created = sim.totalCreated, removed = sim.totalRemoved }
		sim.twoHourSources = table.clone(sim.sources)
		sim.twoHourSinks = table.clone(sim.sinks)
	end
end

local function timeLeft(sim: Sim): number
	return sim.sessionEnd - sim.clock
end

local function release(sim: Sim, rarity: Types.Rarity, biome: number, element: Element)
	local pay = Economy.releasePayout(rarity, biome)
	flow(sim, "Release", pay.coins)
	local material = pay.material
	if material then
		sim.mats[material] += pay.materials
	end
	local prior = sim.releasesByType[element]
	sim.releasesByType[element] = prior + 1
	flow(sim, "CandyRelease", Economy.releaseCandy(rarity, prior), element)
	sim.today.releases += 1
	sim.creatures -= 1
end

-- Typed candy for a catch (the creature itself is added by addCreature).
local function catchCandy(sim: Sim, rarity: Types.Rarity, element: Element)
	local prior = sim.catchesByType[element]
	sim.catchesByType[element] = prior + 1
	flow(sim, "CandyCatch", Economy.catchCandy(rarity, prior), element)
	sim.catchesToday += 1
	sim.today.catches += 1
end

local function addCreature(sim: Sim)
	sim.creatures += 1
	local slots = Economy.stableSlots(sim.expansions, 0)
	if sim.creatures > slots then
		local price = Economy.stableExpansionPrice(sim.expansions)
		if sim.p.optionalSpend and price and sim.bal.coins >= price * 2 then
			spend(sim, "StableExpansion", price, false)
			sim.expansions += 1
		else
			-- Release the five weakest commons to make room.
			for _ = 1, 5 do
				release(sim, "Common", furthest(sim), randomElement(sim, furthest(sim)))
			end
		end
	end
end

local function buyItem(sim: Sim, item: ItemId, routine: boolean): boolean
	local price = Economy.itemPrice(item, furthest(sim))
	return spend(sim, "Shop", price, routine)
end

local function useLasso(sim: Sim, tier: LassoTier): boolean
	if sim.lassos[tier] <= 0 then
		advance(sim, ASSUME.SHOP_MIN)
		local want = if tier == "Basic" then 5 else 1
		for _ = 1, want do
			if buyItem(sim, tier, true) then
				sim.lassos[tier] += 1
			end
		end
		if sim.lassos[tier] <= 0 then
			sim.stuck += 1
			return false
		end
	end
	sim.lassos[tier] -= 1
	return true
end

local function useTonic(sim: Sim)
	if sim.field.Tonic > 0 then
		sim.field.Tonic -= 1
	elseif sim.mats.Fernfluff >= EconomyConfig.RECIPES.Tonic.count then
		sim.mats.Fernfluff -= EconomyConfig.RECIPES.Tonic.count
	elseif not buyItem(sim, "Tonic", true) then
		sim.stuck += 1
		advance(sim, ASSUME.HEAL_WALK_MIN)
	end
end

-- Throws until caught or fled. Returns true if caught.
local function throwLasso(sim: Sim, tier: LassoTier): boolean
	advance(sim, ASSUME.LASSO_MIN)
	for _ = 1, ASSUME.MAX_THROWS do
		if not useLasso(sim, tier) then
			return false
		end
		advance(sim, ASSUME.THROW_MIN)
		if not Rng.chance(sim.rng, ASSUME.MISS[tier]) then
			return true
		end
	end
	return false
end

local function makeGemPair(sim: Sim, biome: number, element: Element)
	if sim.gemPair == nil then
		sim.gemPair = {
			a = newCreature(sim, "Gem", biome, element),
			b = newCreature(sim, "Common", biome, randomElement(sim, biome)),
		}
	end
end

-- A caught common joins the stable, or is released at once (the player keeps the candy).
-- A creature of the starter's type caught in Greenwood joins the second breeding pair.
local function keepOrRelease(sim: Sim, biome: number, element: Element)
	addCreature(sim)
	if
		biome == 1
		and element == sim.p.starter
		and sim.p.starter ~= "Leaf"
		and Breeding.element(sim.pairs[2].a) ~= element
	then
		sim.pairs[2].a = newCreature(sim, "Common", biome, element)
	elseif sim.biome > 3 and Rng.chance(sim.rng, sim.p.releaseCatchShare) then
		-- During the story every biome brings new creatures, so players keep their catches (a full
		-- stable still releases five, which pays candy too). After it, extra catches are released.
		release(sim, "Common", biome, element)
	end
end

local function wildBattle(sim: Sim, biome: number, level: number, lassoShare: number)
	advance(sim, ASSUME.WILD_MIN)
	local kind = wildKind(sim, biome)
	local element: Element = ASSUME.KIND_ELEMENTS[biome][kind]
	local index = (biome - 1) * ASSUME.KINDS_PER_BIOME + kind
	local prior = sim.kindWins[index]
	flow(sim, "WildWin", Economy.battleCoins("Wild", biome, level, prior, false))
	sim.kindWins[index] = prior + 1
	sim.wildWinsToday += 1
	if Rng.chance(sim.rng, EconomyConfig.MATERIAL_DROP_CHANCE * Economy.diminishFactor(prior)) then
		local material = EconomyConfig.MATERIAL_BY_BIOME[biome]
		sim.mats[material] += 1
	end
	if biome >= 2 and Rng.chance(sim.rng, ASSUME.GEM_SPAWN) then
		if throwLasso(sim, sim.p.gemLasso) then
			sim.gems += 1
			catchCandy(sim, "Gem", element)
			addCreature(sim)
			makeGemPair(sim, biome, element)
		end
	elseif Rng.chance(sim.rng, lassoShare) then
		if throwLasso(sim, "Basic") then
			catchCandy(sim, "Common", element)
			keepOrRelease(sim, biome, element)
		end
	end
	if Rng.chance(sim.rng, sim.p.tonicChance) then
		useTonic(sim)
	elseif Rng.chance(sim.rng, 0.2) then
		advance(sim, ASSUME.HEAL_WALK_MIN)
	end
end

local function claimTasks(sim: Sim)
	if not Economy.dailyTasksOpen(sim.biome - 1) then
		return
	end
	local b = furthest(sim)
	local easyDone = { sim.wildWinsToday >= 3, sim.catchesToday >= 1, sim.breedsToday >= 1 }
	local hardDone =
		{ sim.wildWinsToday >= 30, sim.giantRematchWinsToday >= 1, sim.tamerRematchWinsToday >= 5 }
	for i = 1, 3 do
		if easyDone[i] and not sim.easyClaimed[i] then
			local claimed = 0
			for j = 1, 3 do
				if sim.easyClaimed[j] then
					claimed += 1
				end
			end
			sim.easyClaimed[i] = true
			flow(sim, "DailyTask", Economy.dailyTaskCoins(false, b, claimed))
			flow(sim, "CandyDaily", Economy.candyFor("DailyTask", claimed))
		end
		if hardDone[i] and not sim.hardClaimed[i] then
			local claimed = 0
			for j = 1, 3 do
				if sim.hardClaimed[j] then
					claimed += 1
				end
			end
			sim.hardClaimed[i] = true
			flow(sim, "DailyTask", Economy.dailyTaskCoins(true, b, claimed))
			flow(sim, "CandyDaily", Economy.candyFor("DailyHardTask", claimed))
		end
	end
end

local function cooldownMinutes(c: Creature): number
	local list = BreedConfig.COOLDOWN[c.rarity]
	return list[math.min(c.breedCount, #list)] / 60
end

local function prepTopUpCost(sim: Sim, biome: number): number
	local need = { Tonic = 0, GreatTonic = 0, Revive = 0 }
	for _, item: ItemId in sim.p.giantItems do
		if item == "Tonic" then
			need.Tonic += 1
		elseif item == "GreatTonic" then
			need.GreatTonic += 1
		else
			need.Revive += 1
		end
	end
	local cost = Economy.itemPrice("GiantCall", biome)
	cost += math.max(0, need.Tonic - sim.field.Tonic) * Economy.itemPrice("Tonic", biome)
	cost += math.max(0, need.GreatTonic - sim.field.GreatTonic) * Economy.itemPrice(
		"GreatTonic",
		biome
	)
	cost += math.max(0, need.Revive - sim.field.Revive) * Economy.itemPrice("Revive", biome)
	return cost
end

-- Coins the player keeps back before breeding or optional spending.
-- Players start saving for the giant halfway through a biome's tamers.
local function reserve(sim: Sim): number
	local base = Economy.itemPrice("Basic", 1) * 3 + Economy.itemPrice("Tonic", 1)
	if
		sim.biome <= 3
		and sim.tamersDone >= math.floor(ASSUME.TAMERS[sim.biome] / 2)
		and not sim.giantWon
	then
		return base + prepTopUpCost(sim, sim.biome)
	elseif sim.biome > 3 and sim.giantRematchWinsToday < sim.p.rematches then
		return base + prepTopUpCost(sim, 3)
	end
	return base
end

local function averageIncome(sim: Sim): number
	local total, n = 0, 0
	for i = math.max(1, #sim.log - 6), #sim.log do
		total += sim.log[i].created
		n += 1
	end
	return if n > 0 then total / n else 1000
end

local function collectEggs(sim: Sim)
	local i = 1
	while i <= #sim.eggs do
		local egg = sim.eggs[i]
		if egg.readyAt <= sim.clock then
			table.remove(sim.eggs, i)
			addCreature(sim)
			if egg.rarity == "Gem" then
				sim.gems += 1
				if sim.firstGemChildDay == nil then
					sim.firstGemChildDay = sim.day
				end
				local gp = sim.gemPair
				if gp and gp.b.rarity ~= "Gem" then
					gp.b = newCreature(sim, "Gem", egg.biome, egg.element)
				end
			elseif not egg.fromGem and Rng.chance(sim.rng, ASSUME.CHILD_REPLACES) then
				local pair = sim.pairs[Rng.int(sim.rng, 1, #sim.pairs)]
				if pair.a.breedCount >= pair.b.breedCount then
					pair.a = newCreature(sim, "Common", egg.biome, egg.element)
				else
					pair.b = newCreature(sim, "Common", egg.biome, egg.element)
				end
			elseif Rng.chance(sim.rng, sim.p.releaseShare) then
				release(sim, egg.rarity, egg.biome, egg.element)
			end
		else
			i += 1
		end
	end
end

-- How this pair's candy would be paid now, or nil. While a gem pair exists the player holds back
-- its next breed's candy (its own types first, Prism for the rest); common pairs use what is left.
local function pairPayment(sim: Sim, pair: Pair, forGemPair: boolean): Economy.CandyPayment?
	local wallet = sim.bal.candy
	local gp = sim.gemPair
	if gp and not forGemPair then
		wallet = Economy.copyWallet(wallet)
		local short = 0
		for _, need in Breeding.candyCost(gp.a, gp.b) do
			local hold = math.min(wallet.typed[need.element], need.amount)
			wallet.typed[need.element] -= hold
			short += need.amount - hold
		end
		wallet.prism = math.max(0, wallet.prism - short)
	end
	return Economy.candyPayment(wallet, Breeding.candyCost(pair.a, pair.b))
end

local function hasStarterType(sim: Sim, pair: Pair): boolean
	return Breeding.element(pair.a) == sim.p.starter or Breeding.element(pair.b) == sim.p.starter
end

local function tryBreed(sim: Sim)
	if sim.played < ASSUME.MENTOR_MINUTE then
		return
	end
	if (sim.candySources.CandyMentor or 0) == 0 then
		-- The mentor's lesson: his gifted egg and the candy for the player's first breed.
		flow(sim, "CandyMentor", Economy.candyFor("MentorLesson", 0))
		sim.pens += EconomyConfig.PENS_FROM_QUEST
		sim.creatures += 1
	end
	collectEggs(sim)
	if ASSUME.BREED_SKIP > 0 and Rng.chance(sim.rng, ASSUME.BREED_SKIP) then
		return
	end
	while #sim.eggs < sim.pens do
		local nowSeconds = sim.clock * 60
		local choice: Pair? = nil
		local gp = sim.gemPair
		if gp and pairPayment(sim, gp, true) and Breeding.canBreed(gp.a, gp.b, nowSeconds) then
			choice = gp
		else
			-- The cheapest pair whose candy is in hand; a player whose starter is not Leaf puts
			-- pairs with a creature of the starter's type first.
			local best = math.huge
			for _, pair in sim.pairs do
				if Breeding.canBreed(pair.a, pair.b, nowSeconds) then
					local preferred = sim.p.starter ~= "Leaf" and hasStarterType(sim, pair)
					if pairPayment(sim, pair, false) then
						local cost = Breeding.cost(pair.a, pair.b) - (if preferred then 1e6 else 0)
						if cost < best then
							best, choice = cost, pair
						end
					elseif
						sim.day <= 2
						and hasStarterType(sim, pair)
						and sim.bal.coins >= Breeding.cost(pair.a, pair.b) + reserve(sim)
					then
						sim.starterBlocked2d += 1
					end
				end
			end
		end
		if choice == nil then
			return
		end
		local pair: Pair = choice
		local coins = Breeding.cost(pair.a, pair.b)
		local needs = Breeding.candyCost(pair.a, pair.b)
		local candy = Breeding.candyTotal(needs)
		local charm = sim.p.charmShare > 0
			and Rng.chance(sim.rng, sim.p.charmShare)
			and sim.bal.coins
				>= coins + Economy.itemPrice("BondCharm", furthest(sim)) + reserve(sim)
		local total = coins + (if charm then Economy.itemPrice("BondCharm", furthest(sim)) else 0)
		-- A player who owns a gem pair keeps its next breed's coins aside when breeding commons.
		local keepForGem = if gp and pair ~= gp then Breeding.cost(gp.a, gp.b) else 0
		if sim.bal.coins < total + reserve(sim) + keepForGem then
			return
		end
		if sim.firstBreedPlayed == nil then
			sim.firstBreedPlayed = sim.played
			sim.firstBreedDay = sim.day
			sim.firstBreedOwnCandy = (sim.candySources.CandyMentor or 0) < candy
		end
		advance(sim, ASSUME.BREED_MIN)
		spend(sim, "Breed", coins, false)
		sim.breedCoins += coins
		sim.breedsTotal += 1
		if pair.a.rarity == "Gem" or pair.b.rarity == "Gem" then
			sim.gemBreeds += 1
		end
		if sim.day <= 2 then
			sim.breeds2d += 1
			if hasStarterType(sim, pair) then
				sim.starterBreeds2d += 1
			end
		end
		if charm then
			spend(sim, "Shop", Economy.itemPrice("BondCharm", furthest(sim)), false)
		end
		for _, need in needs do
			flow(sim, "BreedCandy", need.amount, need.element)
		end
		local odds = Breeding.rarityOdds(pair.a, pair.b)
		local rarity: Types.Rarity = "Common"
		if odds.Gem and Rng.chance(sim.rng, odds.Gem) then
			rarity = "Gem"
		end
		local rarer: Types.Rarity = if pair.a.rarity == "Gem" or pair.b.rarity == "Gem"
			then "Gem"
			else "Common"
		for _, parent in { pair.a, pair.b } do
			parent.breedCount += 1
			parent.breedReadyAt = nowSeconds + cooldownMinutes(parent) * 60
		end
		table.insert(sim.eggs, {
			readyAt = sim.clock + BreedConfig.HATCH_SECONDS[rarer] / 60,
			rarity = rarity,
			biome = math.max(pair.a.originBiome, pair.b.originBiome),
			fromGem = rarer == "Gem",
			-- The child's torso, and so its type, comes from either parent.
			element = Breeding.element(if Rng.chance(sim.rng, 0.5) then pair.a else pair.b),
		})
		sim.breedsToday += 1
		sim.today.breeds += 1
		claimTasks(sim)
	end
end

-- Buy the profile's field items (topping up what is already held), then fight.
type FightResult = "Won" | "Lost" | "Poor"
local function giantFight(sim: Sim, biome: number, rematch: boolean): FightResult
	local cost = prepTopUpCost(sim, biome)
	if sim.bal.coins < cost + Economy.itemPrice("Basic", 1) * 3 + Economy.itemPrice("Tonic", 1) then
		return "Poor"
	end
	if not rematch and sim.giantAttempts[biome] == 0 then
		sim.giantFirstPrep[biome] = cost
	end
	advance(sim, ASSUME.SHOP_MIN)
	spend(sim, "Shop", Economy.itemPrice("GiantCall", biome), false)
	for _, item: ItemId in sim.p.giantItems do
		if item == "Tonic" then
			if sim.field.Tonic > 0 then
				sim.field.Tonic -= 1
			else
				buyItem(sim, item, false)
			end
		elseif item == "GreatTonic" then
			if sim.field.GreatTonic > 0 then
				sim.field.GreatTonic -= 1
			else
				buyItem(sim, item, false)
			end
		elseif sim.field.Revive > 0 then
			sim.field.Revive -= 1
		else
			buyItem(sim, item, false)
		end
	end
	advance(sim, ASSUME.GIANT_MIN)
	local chance = if rematch
		then ASSUME.REMATCH_WIN
		else math.min(
			0.95,
			sim.p.giantSkill
				+ ASSUME.GIANT_LEARN * sim.giantFails
				+ ASSUME.GIANT_ITEM_BONUS * #sim.p.giantItems
		)
	local won = Rng.chance(sim.rng, chance)
	if won then
		-- Unused items go back to the bag.
		local unused = Rng.int(sim.rng, 0, #sim.p.giantItems - 1)
		for k = 1, unused do
			local item = sim.p.giantItems[k]
			if item == "Tonic" then
				sim.field.Tonic += 1
			elseif item == "GreatTonic" then
				sim.field.GreatTonic += 1
			else
				sim.field.Revive += 1
			end
		end
	end
	return if won then "Won" else "Lost"
end

local function storyStep(sim: Sim)
	local b = sim.biome
	local band = EconomyConfig.LEVEL_BANDS[b]
	local tamers = ASSUME.TAMERS[b]
	local progress = (sim.wildsDone + sim.tamersDone * 3) / (ASSUME.STORY_WILDS[b] + tamers * 3)
	local level = band.min + math.floor(progress * (band.max - band.min))
	if sim.tamersDone < tamers then
		if sim.wildsDone < ASSUME.STORY_WILDS[b] * (sim.tamersDone + 1) / tamers then
			wildBattle(sim, b, level, sim.p.lassoStory)
			sim.wildsDone += 1
		else
			advance(sim, ASSUME.TAMER_MIN)
			flow(sim, "TamerWin", Economy.battleCoins("Tamer", b, level, 0, true))
			sim.tamersDone += 1
			if sim.tamersDone == math.floor(tamers / 2) or sim.tamersDone == tamers then
				advance(sim, ASSUME.QUEST_TRAVEL_MIN[b])
				sim.questsDone += 1
				flow(sim, "QuestLine", Economy.questLineCoins(b))
				flow(sim, "CandyQuest", Economy.candyFor("QuestLine", 0, b))
			end
		end
	elseif not sim.giantWon then
		local result = giantFight(sim, b, false)
		if result == "Won" then
			sim.giantAttempts[b] += 1
			sim.giantGrind[b] = math.max(sim.giantGrind[b], sim.grindNow)
			sim.grindNow = 0
			sim.giantWon = true
			flow(sim, "GiantWin", Economy.battleCoins("Giant", b, band.max, 0, true))
			flow(sim, "CandyFirstClear", Economy.candyFor("GiantFirstClear", 0))
		elseif result == "Lost" then
			sim.giantAttempts[b] += 1
			sim.giantGrind[b] = math.max(sim.giantGrind[b], sim.grindNow)
			sim.grindNow = 0
			sim.giantFails += 1
			advance(sim, ASSUME.HEAL_WALK_MIN)
		else
			-- Not enough coins: earn them on the route.
			local before = sim.clock
			wildBattle(sim, b, band.max, sim.p.lassoStory * 0.5)
			sim.grindNow += sim.clock - before
		end
	else
		advance(sim, ASSUME.GATE_MIN)
		if Rng.chance(sim.rng, ASSUME.GATE_WIN) then
			flow(sim, "GateWin", Economy.battleCoins("Gate", b, band.max, 0, true))
			flow(sim, "CandyFirstClear", Economy.candyFor("GateFirstClear", 0))
			sim.biomeClearDay[b] = sim.day
			sim.biome += 1
			sim.wildsDone, sim.tamersDone, sim.questsDone = 0, 0, 0
			sim.giantWon, sim.giantFails, sim.grindNow = false, 0, 0
			if sim.biome <= 3 then
				-- New biome: breeding moves to its creatures.
				for i = 1, #sim.pairs do
					sim.pairs[i] = newPair(sim, sim.biome)
				end
			end
		end
	end
end

local function bestPostBiome(sim: Sim): number
	local best, bestValue = 3, -1
	for b = 1, 3 do
		local total = 0
		for k = 1, ASSUME.KINDS_PER_BIOME do
			total += Economy.battleCoins(
				"Wild",
				b,
				99,
				sim.kindWins[(b - 1) * ASSUME.KINDS_PER_BIOME + k],
				false
			)
		end
		if total > bestValue then
			best, bestValue = b, total
		end
	end
	return best
end

local function postGameSession(sim: Sim)
	local week = math.floor((sim.day - 1) / 7)
	if
		sim.weeklyClaimedWeek < week
		and Rng.chance(sim.rng, sim.p.weeklyShare)
		and timeLeft(sim) > 15
	then
		advance(sim, ASSUME.WEEKLY_MIN)
		sim.weeklyClaimedWeek = week
		flow(sim, "WeeklyChallenge", Economy.weeklyChallengeCoins(3, 0))
		flow(sim, "CandyWeekly", Economy.candyFor("WeeklyChallenge", 0))
	end
	for _ = 1, sim.p.rematches do
		if timeLeft(sim) < ASSUME.GIANT_MIN + 2 then
			break
		end
		if giantFight(sim, 3, true) == "Won" then
			flow(sim, "GiantWin", Economy.battleCoins("Giant", 3, 32, sim.giantPaid, false))
			flow(sim, "CandyGiantRematch", Economy.candyFor("GiantRematch", sim.giantPaid))
			sim.giantPaid += 1
			sim.giantRematchWinsToday += 1
		end
		tryBreed(sim)
	end
	for t = 1, sim.p.tamerRematches do
		if timeLeft(sim) < ASSUME.TAMER_MIN then
			break
		end
		advance(sim, ASSUME.TAMER_MIN)
		flow(sim, "TamerWin", Economy.battleCoins("Tamer", 3, 32, sim.tamerPaid[t], false))
		sim.tamerPaid[t] += 1
		sim.tamerRematchWinsToday += 1
		claimTasks(sim)
	end
	for _ = 1, sim.p.bait do
		if timeLeft(sim) < ASSUME.BAIT_MIN + 1 then
			break
		end
		local recipe = EconomyConfig.RECIPES.Bait
		local ok = false
		if sim.mats.BrineShell >= recipe.count and spend(sim, "Craft", recipe.coins, false) then
			sim.mats.BrineShell -= recipe.count
			ok = true
		elseif sim.bal.coins >= Economy.itemPrice("Bait", 3) + reserve(sim) then
			ok = buyItem(sim, "Bait", false)
		end
		if ok then
			advance(sim, ASSUME.BAIT_MIN)
			flow(sim, "WildWin", Economy.battleCoins("Wild", 3, 32, 0, false))
			local element: Element = randomElement(sim, 3)
			if Rng.chance(sim.rng, ASSUME.BAIT_GEM) then
				if throwLasso(sim, sim.p.gemLasso) then
					sim.gems += 1
					catchCandy(sim, "Gem", element)
					addCreature(sim)
					makeGemPair(sim, 3, element)
				end
			elseif throwLasso(sim, "Basic") then
				catchCandy(sim, "Common", element)
				keepOrRelease(sim, 3, element)
			end
		end
		tryBreed(sim)
	end
	while timeLeft(sim) > 0 do
		wildBattle(sim, bestPostBiome(sim), 99, sim.p.lassoPost)
		claimTasks(sim)
		tryBreed(sim)
	end
end

local function newSim(profile: Profile, seed: number): Sim
	local sim: Sim = {
		p = profile,
		rng = Rng.new(seed),
		bal = { coins = 0, candy = Economy.emptyWallet() },
		lassos = { Basic = EconomyConfig.STARTER_ITEMS.Basic, Braided = 0, Gilded = 0 },
		field = { Tonic = EconomyConfig.STARTER_ITEMS.Tonic, GreatTonic = 0, Revive = 0 },
		mats = { Fernfluff = 0, CanyonGrit = 0, BrineShell = 0 },
		biome = 1,
		wildsDone = 0,
		tamersDone = 0,
		questsDone = 0,
		giantWon = false,
		giantFails = 0,
		kindWins = {},
		tamerPaid = {},
		giantPaid = 0,
		creatures = 2,
		gems = 0,
		catchesByType = Economy.zeroByElement(),
		releasesByType = Economy.zeroByElement(),
		starterBreeds2d = 0,
		starterBlocked2d = 0,
		breeds2d = 0,
		starterCandy2d = 0,
		biomeCandy = { 0, 0, 0 },
		expansions = 0,
		pens = EconomyConfig.PENS_FREE,
		eggs = {},
		pairs = {},
		gemPair = nil,
		nextId = 0,
		clock = 0,
		sessionEnd = 0,
		played = 0,
		day = 0,
		today = newDay(1),
		wildWinsToday = 0,
		catchesToday = 0,
		breedsToday = 0,
		giantRematchWinsToday = 0,
		tamerRematchWinsToday = 0,
		easyClaimed = { false, false, false },
		hardClaimed = { false, false, false },
		weeklyClaimedWeek = 0,
		log = {},
		totalCreated = 0,
		totalRemoved = 0,
		sinks = {},
		candySources = {},
		twoHour = nil,
		ledgerRefusals = 0,
		stuck = 0,
		firstBreedPlayed = nil,
		firstBreedDay = nil,
		firstBreedOwnCandy = false,
		firstGemChildDay = nil,
		biomeClearDay = { 0, 0, 0 },
		biomeCreated = { 0, 0, 0 },
		biomeMinutes = { 0, 0, 0 },
		biomeRoutine = { 0, 0, 0 },
		giantFirstPrep = { 0, 0, 0 },
		giantAttempts = { 0, 0, 0 },
		giantGrind = { 0, 0, 0 },
		grindNow = 0,
		breedCoins = 0,
		breedsTotal = 0,
		gemBreeds = 0,
		decor = 0,
		sources = {},
		twoHourSources = nil,
		twoHourSinks = nil,
	}
	for i = 1, 3 * ASSUME.KINDS_PER_BIOME do
		sim.kindWins[i] = 0
	end
	for i = 1, 10 do
		sim.tamerPaid[i] = 0
	end
	sim.pairs = { newPair(sim, 1), newPair(sim, 1), newPair(sim, 1), newPair(sim, 1) }
	-- The starter is one parent of the first pair, with a wild partner from Route A.
	sim.pairs[1].a = newCreature(sim, "Common", 1, profile.starter)
	flow(sim, "Starter", EconomyConfig.STARTING_COINS)
	return sim
end

local function runDay(sim: Sim, day: number)
	sim.day = day
	sim.today = newDay(furthest(sim))
	for i = 1, #sim.kindWins do
		sim.kindWins[i] = 0
	end
	for i = 1, #sim.tamerPaid do
		sim.tamerPaid[i] = 0
	end
	sim.giantPaid = 0
	sim.wildWinsToday, sim.catchesToday, sim.breedsToday = 0, 0, 0
	sim.catchesByType = Economy.zeroByElement()
	sim.releasesByType = Economy.zeroByElement()
	sim.giantRematchWinsToday, sim.tamerRematchWinsToday = 0, 0
	sim.easyClaimed = { false, false, false }
	sim.hardClaimed = { false, false, false }
	sim.clock = (day - 1) * 1440 + 18 * 60
	sim.sessionEnd = sim.clock + sim.p.minutes
	while timeLeft(sim) > 0 do
		if sim.biome <= 3 then
			storyStep(sim)
			claimTasks(sim)
			tryBreed(sim)
		else
			postGameSession(sim)
		end
	end
	-- Optional spending when rich: a coin-bought stable expansion.
	if sim.p.optionalSpend and #sim.log >= 3 then
		local price = Economy.stableExpansionPrice(sim.expansions)
		if price and sim.bal.coins - price > ASSUME.SURPLUS_DAYS * averageIncome(sim) then
			spend(sim, "StableExpansion", price, false)
			sim.expansions += 1
		end
		local decor = Economy.decorPrice(sim.decor)
		if decor and sim.bal.coins - decor > ASSUME.SURPLUS_DAYS * averageIncome(sim) then
			spend(sim, "Decor", decor, false)
			sim.decor += 1
		end
	end
	tryBreed(sim) -- start eggs that hatch overnight
	sim.today.balance = sim.bal.coins
	table.insert(sim.log, sim.today)
end

------------------------------------------------------------------------------------------------
-- Running and summarising. Each run is reduced to named numbers so tables stay short.
------------------------------------------------------------------------------------------------

type Summary = {
	v: { [string]: number },
	sinkShare: { [string]: number },
	candyShare: { [string]: number },
}

local function sumLog(
	log: { DayLog },
	first: number,
	last: number,
	field: (DayLog) -> number
): number
	local total = 0
	for d = math.max(1, first), math.min(last, #log) do
		total += field(log[d])
	end
	return total
end
local function created(d: DayLog): number
	return d.created
end
local function removed(d: DayLog): number
	return d.removed
end
local function ratioOf(log: { DayLog }, first: number, last: number): number
	local c = sumLog(log, first, last, created)
	return if c > 0 then sumLog(log, first, last, removed) / c else 0
end

local function summarise(sim: Sim, days: number): Summary
	local log = sim.log
	local v: { [string]: number } = {}
	local twoHour = sim.twoHour or { created = sim.totalCreated, removed = sim.totalRemoved }
	v.twoHourRatio = twoHour.removed / math.max(1, twoHour.created)
	local gwDay = if sim.biomeClearDay[1] > 0 then sim.biomeClearDay[1] else days
	v.postGreenwoodRatio = ratioOf(log, gwDay + 1, days)
	for w = 1, 4 do
		v[`week{w}Ratio`] = ratioOf(log, (w - 1) * 7 + 1, w * 7)
		v[`week{w}Balance`] = log[math.min(days, w * 7)].balance
	end
	local storyDone = if sim.biomeClearDay[3] > 0 then sim.biomeClearDay[3] + 1 else days
	local steadyFrom = math.max(storyDone, 8)
	local steadyDays = math.max(1, days - steadyFrom + 1)
	v.steadyIncome = sumLog(log, steadyFrom, days, created) / steadyDays
	v.steadyRatio = ratioOf(log, steadyFrom, days)
	v.daysOnHand7 = log[7].balance / math.max(1, sumLog(log, 1, 7, created) / 7)
	local heldTotal = 0
	for d = 8, days do
		heldTotal += log[d].balance / math.max(1, sumLog(log, d - 6, d, created) / 7)
	end
	v.daysOnHandAfterWeek1 = heldTotal / math.max(1, days - 7)
	v.daysOnHandEnd = log[days].balance / math.max(1, sumLog(log, days - 6, days, created) / 7)
	v.b1PerMinute = sim.biomeCreated[1] / math.max(1, sim.biomeMinutes[1])
	v.firstBreedMinutes = BreedConfig.COST_BASE / math.max(1, v.b1PerMinute)
	v.breedsWeek1 = sumLog(log, 1, 7, function(d)
		return d.breeds
	end) / 7
	v.breedsLater = sumLog(log, 8, days, function(d)
		return d.breeds
	end) / math.max(1, days - 7)
	v.candyWeek1 = sumLog(log, 1, 7, function(d)
		return d.candyIn
	end) / 7
	v.candySteady = sumLog(log, steadyFrom, days, function(d)
		return d.candyIn
	end) / steadyDays
	v.candyEnd = Economy.walletTotal(sim.bal.candy)
	v.prismWeek1 = sumLog(log, 1, 7, function(d)
		return d.prismIn
	end) / 7
	v.prismSteady = sumLog(log, steadyFrom, days, function(d)
		return d.prismIn
	end) / steadyDays
	v.typedSteady = sumLog(log, steadyFrom, days, function(d)
		return d.typedIn
	end) / steadyDays
	-- The type the player earns most of after the story: the one a gem pair would use.
	local bestType = 0
	for _, element: Element in TypeChart.ELEMENTS do
		bestType = math.max(bestType, sumLog(log, steadyFrom, days, function(d)
			return d.typedBy[element]
		end) / steadyDays)
	end
	v.bestTypeSteady = bestType
	v.usableSteady = v.prismSteady + bestType
	v.candyPerHourSteady = sumLog(log, steadyFrom, days, function(d)
		return d.candyIn
	end) / math.max(
		1,
		sumLog(log, steadyFrom, days, function(d)
			return d.minutes
		end)
	) * 60
	v.b1CandyPerHour = sim.biomeCandy[1] / math.max(1, sim.biomeMinutes[1]) * 60
	v.catchesWeek1 = sumLog(log, 1, 7, function(d)
		return d.catches
	end) / 7
	v.catchesSteady = sumLog(log, steadyFrom, days, function(d)
		return d.catches
	end) / steadyDays
	v.releasesSteady = sumLog(log, steadyFrom, days, function(d)
		return d.releases
	end) / steadyDays
	v.starterBreeds2d = sim.starterBreeds2d
	v.starterBlocked2d = sim.starterBlocked2d
	v.breeds2d = sim.breeds2d
	v.starterCandy2d = sim.starterCandy2d
	v.avgBreedCost = sim.breedCoins / math.max(1, sim.breedsTotal)
	v.gemBreedShare = sim.gemBreeds / math.max(1, sim.breedsTotal)
	v.firstBreedPlayed = sim.firstBreedPlayed or -1
	v.firstBreedOk = if sim.firstBreedDay == 1 and not sim.firstBreedOwnCandy then 1 else 0
	v.firstGemChildDay = sim.firstGemChildDay or 0
	v.stuckOrRefused = sim.stuck + sim.ledgerRefusals
	for b = 1, 3 do
		v[`clear{b}`] = sim.biomeClearDay[b]
		-- Spare coins per 20-minute session: income less lassos and healing.
		local spare = (sim.biomeCreated[b] - sim.biomeRoutine[b])
			/ math.max(1, sim.biomeMinutes[b])
			* 20
		v[`prepCost{b}`] = sim.giantFirstPrep[b]
		v[`prepSessions{b}`] = sim.giantFirstPrep[b] / math.max(1, spare)
		v[`attempts{b}`] = sim.giantAttempts[b]
		v[`grind{b}`] = sim.giantGrind[b]
	end
	local sinkShare: { [string]: number } = {}
	for name, amount in sim.sinks do
		sinkShare[name] = amount / math.max(1, sim.totalRemoved)
	end
	local totalCandy = 0
	for _, amount in sim.candySources do
		totalCandy += amount
	end
	local candyShare: { [string]: number } = {}
	for name, amount in sim.candySources do
		candyShare[name] = amount / math.max(1, totalCandy)
	end
	return { v = v, sinkShare = sinkShare, candyShare = candyShare }
end

local function runProfile(profile: Profile, seeds: number, days: number): { Summary }
	local out = {}
	for seed = 1, seeds do
		local sim = newSim(profile, seed * 7919 + #profile.name)
		for day = 1, days do
			runDay(sim, day)
		end
		table.insert(out, summarise(sim, days))
	end
	return out
end

local function mean(list: { Summary }, key: string): number
	local total = 0
	for _, s in list do
		total += s.v[key] or 0
	end
	return total / #list
end
local function maxOf(list: { Summary }, key: string): number
	local best = -math.huge
	for _, s in list do
		best = math.max(best, s.v[key] or 0)
	end
	return best
end
local function shareMean(list: { Summary }, candy: boolean, key: string): number
	local total = 0
	for _, s in list do
		total += (if candy then s.candyShare else s.sinkShare)[key] or 0
	end
	return total / #list
end

local function pct(x: number): string
	return string.format("%.0f%%", x * 100)
end

local function printTables(results: { [string]: { Summary } }, days: number)
	print(`\n  A. Coins removed as a share of coins created (mean over seeds, {days} days)`)
	print("  player   | first 2 h | after Greenwood | wk1  wk2  wk3  wk4 | after story | stuck")
	for _, profile in PROFILES do
		local r = results[profile.name]
		print(
			string.format(
				"  %-8s |   %4s    |      %4s       | %4s %4s %4s %4s |    %4s     | %d",
				profile.name,
				pct(mean(r, "twoHourRatio")),
				pct(mean(r, "postGreenwoodRatio")),
				pct(mean(r, "week1Ratio")),
				pct(mean(r, "week2Ratio")),
				pct(mean(r, "week3Ratio")),
				pct(mean(r, "week4Ratio")),
				pct(mean(r, "steadyRatio")),
				math.floor(mean(r, "stuckOrRefused"))
			)
		)
	end

	print("\n  B. Progress and breeding")
	print(
		"  player   | biome cleared on day | B1 coins/min | breed = min | breeds/day wk1, later | coins/breed | gem breeds"
	)
	for _, profile in PROFILES do
		local r = results[profile.name]
		print(
			string.format(
				"  %-8s |   %4.1f %4.1f %4.1f     |     %4.0f     |    %4.1f     |      %4.1f, %4.1f       |    %5.0f    |   %4s",
				profile.name,
				mean(r, "clear1"),
				mean(r, "clear2"),
				mean(r, "clear3"),
				mean(r, "b1PerMinute"),
				mean(r, "firstBreedMinutes"),
				mean(r, "breedsWeek1"),
				mean(r, "breedsLater"),
				mean(r, "avgBreedCost"),
				pct(mean(r, "gemBreedShare"))
			)
		)
	end

	print("\n  C. Candy (typed and Prism)")
	print(
		"  player   | per day wk1 (Prism) | after story: Prism + typed (best type) | per hour | catches/day wk1, later (released) | unspent | first breed (min)"
	)
	for _, profile in PROFILES do
		local r = results[profile.name]
		print(
			string.format(
				"  %-8s |   %4.1f (%4.1f)       |   %4.1f + %4.1f (%4.1f)                  |   %4.1f   |   %4.1f, %4.1f (%4.1f)                 |  %4.0f   |   %4.0f",
				profile.name,
				mean(r, "candyWeek1"),
				mean(r, "prismWeek1"),
				mean(r, "prismSteady"),
				mean(r, "typedSteady"),
				mean(r, "bestTypeSteady"),
				mean(r, "candyPerHourSteady"),
				mean(r, "catchesWeek1"),
				mean(r, "catchesSteady"),
				mean(r, "releasesSteady"),
				mean(r, "candyEnd"),
				mean(r, "firstBreedPlayed")
			)
		)
	end

	print("\n  D. Coins on hand")
	print(
		"  player   | end wk1  end wk2  end wk3  end wk4 | income/day after story | days held d7, d8-30, d30 | first gem child"
	)
	for _, profile in PROFILES do
		local r = results[profile.name]
		local got, dayTotal = 0, 0
		for _, s in r do
			if (s.v.firstGemChildDay or 0) > 0 then
				got += 1
				dayTotal += s.v.firstGemChildDay
			end
		end
		print(
			string.format(
				"  %-8s | %7.0f  %7.0f  %7.0f  %7.0f |        %7.0f         |   %4.1f, %4.1f, %4.1f     | %s",
				profile.name,
				mean(r, "week1Balance"),
				mean(r, "week2Balance"),
				mean(r, "week3Balance"),
				mean(r, "week4Balance"),
				mean(r, "steadyIncome"),
				mean(r, "daysOnHand7"),
				mean(r, "daysOnHandAfterWeek1"),
				mean(r, "daysOnHandEnd"),
				if got > 0
					then string.format("day %.1f in %s of runs", dayTotal / got, pct(got / #r))
					else "none"
			)
		)
	end

	print(
		"\n  E. Giants: first-attempt prep in coins and in 20-minute sessions of spare coins; attempts; longest grind"
	)
	for _, profile in PROFILES do
		local r = results[profile.name]
		local parts = {}
		for b = 1, 3 do
			table.insert(
				parts,
				string.format(
					"B%d %5.0f c, %3.1f ses, %3.1f att, %4.1f min",
					b,
					mean(r, `prepCost{b}`),
					mean(r, `prepSessions{b}`),
					mean(r, `attempts{b}`),
					maxOf(r, `grind{b}`)
				)
			)
		end
		print(string.format("  %-8s | %s", profile.name, table.concat(parts, " | ")))
	end

	print("\n  F. Where coins go (share removed) and where candy comes from (share earned)")
	local sinkNames = { "Breed", "Shop", "Craft", "StableExpansion", "Decor" }
	local candyNames = {
		"CandyCatch",
		"CandyRelease",
		"CandyDaily",
		"CandyGiantRematch",
		"CandyFirstClear",
		"CandyQuest",
		"CandyWeekly",
		"CandyMentor",
	}
	for _, profile in PROFILES do
		local r = results[profile.name]
		local bits, cbits = {}, {}
		for _, name in sinkNames do
			table.insert(bits, `{name} {pct(shareMean(r, false, name))}`)
		end
		for _, name in candyNames do
			table.insert(cbits, `{string.sub(name, 6)} {pct(shareMean(r, true, name))}`)
		end
		print(string.format("  %-8s | coins: %s", profile.name, table.concat(bits, ", ")))
		print(string.format("  %-8s | candy: %s", "", table.concat(cbits, ", ")))
	end
end

-- Days of play from owning a pure pair of a tier to its first child of that tier, spending all
-- candy on it. Candy income and cooldowns limit it; the coins it costs are reported alongside.
local function daysToChild(tier: Types.Rarity, candyPerDay: number, seed: number): (number, number)
	local rng = Rng.new(seed)
	local a = Breeding.wild("Mossback", "pa", 30, tier, "Moss", rng)
	local b = Breeding.wild("Mossback", "pb", 30, tier, "Moss", rng)
	a.originBiome, b.originBiome = 3, 3
	local chance = (Breeding.rarityOdds(a, b) :: { [string]: number })[tier] or 0
	local candy, coins, hours, readyAt = 0, 0, 0, 0
	local need = Breeding.candyTotal(Breeding.candyCost(a, b)) -- a pure pair: one type
	while hours < 24 * 400 do
		hours += 1
		candy += candyPerDay / 24
		if hours >= readyAt and candy >= need then
			candy -= need
			coins += Breeding.cost(a, b)
			a.breedCount += 1
			b.breedCount += 1
			readyAt = hours + cooldownMinutes(a) / 60
			if Rng.chance(rng, chance) then
				break
			end
		end
	end
	return hours / 24, coins
end

local function printChildTable(results: { [string]: { Summary } }): { [string]: { number } }
	local medians: { [string]: { number } } = {}
	print(
		"\n  G. Days from owning a pure biome-3 pair to a child of the same tier, all its type's candy and all Prism spent on it"
	)
	print(
		"     (median and 90th percentile days; median coins, and those coins in days of that player's income)"
	)
	print(
		"  tier    | candy a breed | chance | casual                 | regular                | heavy"
	)
	local tiers: { Types.Rarity } = { "Gem", "Ruby", "Diamond" }
	for _, tier: Types.Rarity in tiers do
		local cells = {}
		for _, profile in PROFILES do
			local rate = mean(results[profile.name], "usableSteady")
			local income = mean(results[profile.name], "steadyIncome")
			local daysList, coinList = {}, {}
			for seed = 1, 301 do
				local d, c = daysToChild(tier, rate, seed)
				table.insert(daysList, d)
				table.insert(coinList, c)
			end
			table.sort(daysList)
			table.sort(coinList)
			medians[profile.name] = medians[profile.name] or {}
			table.insert(medians[profile.name], daysList[151])
			table.insert(
				cells,
				string.format(
					"%4.1f, %5.1f d %3.0fk %4.1fd",
					daysList[151],
					daysList[271],
					coinList[151] / 1000,
					coinList[151] / income
				)
			)
		end
		local rule = BreedConfig.RARITY_INHERIT[tier]
		print(
			string.format(
				"  %-7s |  %3d  |  %4s  | %s | %s | %s",
				tier,
				2 * BreedConfig.CANDY_COST[tier],
				pct(if rule then rule.both else 0),
				cells[1],
				cells[2],
				cells[3]
			)
		)
	end
	return medians
end

-- One hour of catch-and-release farming from a fresh day: every wild battle gets a lasso attempt
-- and every catch is released at once. Counts every candy the hour earns, including the daily
-- tasks it completes (three wins, a catch, 30 wins). The farmer has finished the story and farms
-- Greenwood (farmBiome 1) or Tide Flats (3).
local function farmHour(farmBiome: number, seed: number): (number, number)
	local profile = table.clone(PROFILES[2])
	profile.releaseCatchShare = 1
	profile.tonicChance = 0
	local sim = newSim(profile, seed)
	sim.biome = 4
	sim.day = 10
	sim.today = newDay(farmBiome)
	flow(sim, "Starter", 1000000) -- enough coins for every lasso; not counted as candy
	sim.clock = 0
	sim.sessionEnd = 60
	sim.played = 1000 -- past the mentor's lesson
	local catches = 0
	while timeLeft(sim) > 0 do
		local before = sim.today.catches
		wildBattle(sim, farmBiome, 99, 1)
		catches += sim.today.catches - before
		claimTasks(sim)
	end
	local perHour = sim.today.candyIn * 60 / sim.today.minutes
	return perHour, catches * 60 / sim.today.minutes
end

-- The first two days of a player whose starter is not Leaf: how many breeds use a parent of
-- the starter's type, and how often such a breed waited only for candy.
local function starterRun(profile: Profile, seeds: number): { Summary }
	local out = {}
	for seed = 1, seeds do
		local sim = newSim(profile, seed * 104729 + #profile.name)
		for day = 1, 2 do
			runDay(sim, day)
		end
		local v: { [string]: number } = {
			starterBreeds2d = sim.starterBreeds2d,
			starterBlocked2d = sim.starterBlocked2d,
			breeds2d = sim.breeds2d,
			starterCandy2d = sim.starterCandy2d,
			prism2d = sim.log[1].prismIn + sim.log[2].prismIn,
		}
		table.insert(out, { v = v, sinkShare = {}, candyShare = {} })
	end
	return out
end

------------------------------------------------------------------------------------------------
print("\n== Simulation: three player types, 30 days, fixed seeds ==")
------------------------------------------------------------------------------------------------

local DAYS = 30
local function simulate(seeds: number): ({ [string]: { Summary } }, { [string]: { number } })
	local results: { [string]: { Summary } } = {}
	for _, profile in PROFILES do
		results[profile.name] = runProfile(profile, seeds, DAYS)
	end
	printTables(results, DAYS)
	local medians = printChildTable(results)
	return results, medians
end

-- The longer exploration: many more seeds. Off in the gate; flip RUN_LONG_EXPLORATION to run it.
local function longExploration()
	print("\n== Long exploration: 200 seeds per player type ==")
	simulate(200)

	print("\n== Sensitivity: one guess changed at a time, 40 seeds ==")
	print(
		"  variant                      | 2 h reg | after GW reg, heavy | reg days held | reg candy left | casual breeds/day"
	)
	type Variant = { name: string, apply: () -> (), undo: () -> () }
	local saved = table.clone(ASSUME)
	local function restore()
		for key, value in saved do
			(ASSUME :: any)[key] = value
		end
	end
	local variants: { Variant } = {
		{ name = "baseline", apply = function() end, undo = restore },
		{
			name = "battles 30% slower",
			apply = function()
				ASSUME.WILD_MIN *= 1.3
				ASSUME.TAMER_MIN *= 1.3
				ASSUME.GIANT_MIN *= 1.3
			end,
			undo = restore,
		},
		{
			name = "battles 30% faster",
			apply = function()
				ASSUME.WILD_MIN *= 0.7
				ASSUME.TAMER_MIN *= 0.7
				ASSUME.GIANT_MIN *= 0.7
			end,
			undo = restore,
		},
		{
			name = "lasso misses x1.5",
			apply = function()
				ASSUME.MISS = { Basic = 0.675, Braided = 0.45, Gilded = 0.225 }
			end,
			undo = restore,
		},
		{
			name = "half of breeds skipped",
			apply = function()
				ASSUME.BREED_SKIP = 0.5
			end,
			undo = restore,
		},
		{
			name = "gem spawns x3",
			apply = function()
				ASSUME.GEM_SPAWN *= 3
				ASSUME.BAIT_GEM = math.min(1, ASSUME.BAIT_GEM * 2)
			end,
			undo = restore,
		},
		{
			name = "giants 20% harder",
			apply = function()
				ASSUME.GIANT_LEARN *= 0.5
				ASSUME.REMATCH_WIN = 0.6
			end,
			undo = restore,
		},
	}
	for _, variant in variants do
		variant.apply()
		local r: { [string]: { Summary } } = {}
		for _, profile in PROFILES do
			r[profile.name] = runProfile(profile, 40, DAYS)
		end
		print(
			string.format(
				"  %-28s |  %4s   |     %4s, %4s     |     %4.1f      |      %4.0f      |      %4.1f",
				variant.name,
				pct(mean(r.regular, "twoHourRatio")),
				pct(mean(r.regular, "postGreenwoodRatio")),
				pct(mean(r.heavy, "postGreenwoodRatio")),
				mean(r.regular, "daysOnHandAfterWeek1"),
				mean(r.regular, "candyEnd"),
				mean(r.casual, "breedsWeek1")
			)
		)
		variant.undo()
	end
end

local results, childDays = simulate(30)
if RUN_LONG_EXPLORATION then
	longExploration()
end

print("\n  H. A player whose starter is Sand, first two days (30 seeds), against a Leaf starter")
print(
	"  player            | breeds | with a Sand (or Leaf) parent | waited for candy | starter-type candy | Prism"
)
local starterResults: { [string]: { Summary } } = {}
for _, base in { PROFILES[1], PROFILES[2] } do
	local starters: { Element } = { "Sand", "Leaf" }
	for _, element: Element in starters do
		local profile = table.clone(base)
		profile.starter = element
		local key = `{base.name} {element}`
		local r = starterRun(profile, 30)
		starterResults[key] = r
		print(
			string.format(
				"  %-17s |  %4.1f  |            %4.1f              |       %4.1f       |       %4.1f         | %4.1f",
				key,
				mean(r, "breeds2d"),
				mean(r, "starterBreeds2d"),
				mean(r, "starterBlocked2d"),
				mean(r, "starterCandy2d"),
				mean(r, "prism2d")
			)
		)
	end
end

print("\n  I. Catch-and-release farming for an hour against a normal hour (candy, 20 seeds)")
local farm: { [number]: number } = {}
for _, farmBiome in { 1, 3 } do
	local total, catchTotal = 0, 0
	for seed = 1, 20 do
		local perHour, catchesPerHour = farmHour(farmBiome, seed * 31)
		total += perHour
		catchTotal += catchesPerHour
	end
	farm[farmBiome] = total / 20
	print(
		string.format(
			"  farming in %-10s | %4.1f candy an hour from %4.1f catches",
			if farmBiome == 1 then "Greenwood" else "Tide Flats",
			farm[farmBiome],
			catchTotal / 20
		)
	)
end
for _, profile in PROFILES do
	local normal = mean(results[profile.name], "candyPerHourSteady")
	print(
		string.format(
			"  normal hour after the story, %-8s | %4.1f candy; farming is %.2f x (Greenwood) and %.2f x (Tide Flats)",
			profile.name,
			normal,
			farm[1] / normal,
			farm[3] / normal
		)
	)
end

print("\n== Target bands (shortened simulation, fixed seeds) ==")
for _, profile in PROFILES do
	local name = profile.name
	local r = results[name]
	local two = mean(r, "twoHourRatio")
	check(
		`{name}: coins removed are about 60-70% of created in the first two hours (57 to 73)`,
		two >= 0.57 and two <= 0.73,
		pct(two)
	)
	check(
		`{name}: never unable to afford a lasso or a Tonic; the ledger never refused`,
		mean(r, "stuckOrRefused") == 0
	)
	check(
		`{name}: first breed in the first session, paid with the mentor's candy`,
		mean(r, "firstBreedOk") == 1
	)
	local w3, w4 = mean(r, "week3Balance"), mean(r, "week4Balance")
	check(
		`{name}: coins on hand stop growing (week 4 at most 1.25 x week 3 + one day's income)`,
		w4 <= 1.25 * w3 + mean(r, "steadyIncome"),
		string.format("%.0f then %.0f", w3, w4)
	)
	local prepOk, prepText = true, {}
	for b = 1, 3 do
		local sessions = mean(r, `prepSessions{b}`)
		table.insert(prepText, string.format("%.2f", sessions))
		prepOk = prepOk and sessions >= 0.5 and sessions <= 1.5
	end
	check(
		`{name}: a first giant attempt costs about one 20-minute session's spare coins (0.5 to 1.5)`,
		prepOk,
		table.concat(prepText, ", ")
	)
	-- Grinding means wild battles fought only because the next giant attempt is not affordable yet.
	local grind = math.max(maxOf(r, "grind1"), maxOf(r, "grind2"), maxOf(r, "grind3"))
	local typical = (mean(r, "grind1") + mean(r, "grind2") + mean(r, "grind3")) / 3
	check(
		`{name}: no one waits more than 25 minutes of play for a giant attempt; the typical wait is under 10`,
		grind <= 25 and typical <= 10,
		string.format("worst %.1f min, mean %.1f min", grind, typical)
	)
end
for _, name in { "regular", "heavy" } do
	local post = mean(results[name], "postGreenwoodRatio")
	check(
		`{name}: after Greenwood, coins removed are 80-95% of created`,
		post >= 0.80 and post <= 0.95,
		pct(post)
	)
end
local breedMinutes = mean(results.casual, "firstBreedMinutes")
check(
	"a common biome-1 breed costs about four minutes of biome-1 income (3 to 5)",
	breedMinutes >= 3 and breedMinutes <= 5,
	string.format("%.1f min", breedMinutes)
)
local casualBreeds = mean(results.casual, "breedsWeek1")
check(
	"a casual player breeds about twice a day in week 1 (1.5 to 3)",
	casualBreeds >= 1.5 and casualBreeds <= 3,
	string.format("%.1f", casualBreeds)
)
local regularPrism, heavyPrism =
	mean(results.regular, "prismSteady"), mean(results.heavy, "prismSteady")
check(
	"a regular player earns about 5 to 6 Prism Candy a day after the story (4.5 to 6.5)",
	regularPrism >= 4.5 and regularPrism <= 6.5,
	string.format("%.1f", regularPrism)
)
check(
	"a heavy player earns about 8 Prism Candy a day after the story (7 to 9)",
	heavyPrism >= 7 and heavyPrism <= 9,
	string.format("%.1f", heavyPrism)
)
check(
	"one-time Prism gives a visible early burst (week 1 above the steady rate)",
	mean(results.regular, "prismWeek1") > regularPrism
)
-- Gem tiers stay scarce: the regular player's days to a gem-tier, Ruby and Diamond child stay
-- within two thirds and one and a half times the single-candy model (1.7, 4.1 and 10.2 days).
local before = { 1.7, 4.1, 10.2 }
local nowDays = childDays.regular
local scarce = true
for index = 1, 3 do
	local ratio = nowDays[index] / before[index]
	scarce = scarce and ratio >= 2 / 3 and ratio <= 1.5
end
check(
	"gem-tier supply stays scarce: regular days to a Gem, Ruby, Diamond child near 1.7, 4.1, 10.2",
	scarce,
	string.format("%.1f, %.1f, %.1f days", nowDays[1], nowDays[2], nowDays[3])
)
local casualSand, regularSand = starterResults["casual Sand"], starterResults["regular Sand"]
check(
	"a Sand starter is not stuck in Greenwood: Sand breeds in the first two days (casual 1.5+, regular 3+)",
	mean(casualSand, "starterBreeds2d") >= 1.5 and mean(regularSand, "starterBreeds2d") >= 3,
	string.format(
		"casual %.1f, regular %.1f",
		mean(casualSand, "starterBreeds2d"),
		mean(regularSand, "starterBreeds2d")
	)
)
local worstFarm, worstText = 0, ""
for _, profile in PROFILES do
	for _, farmBiome in { 1, 3 } do
		local ratio = farm[farmBiome] / mean(results[profile.name], "candyPerHourSteady")
		if ratio > worstFarm then
			worstFarm, worstText = ratio, `{profile.name}, biome {farmBiome}`
		end
	end
end
check(
	"an hour of catch-and-release farming earns at most 1.5 x the candy of a normal hour",
	worstFarm <= 1.5,
	string.format("worst %.2f x (%s)", worstFarm, worstText)
)
local held = mean(results.regular, "daysOnHandAfterWeek1")
check(
	"a regular player holds 2 to 7 days of income after the first week (mean of days 8 to 30)",
	held >= 2 and held <= 7,
	string.format("%.1f days", held)
)

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("tests failed")
end
