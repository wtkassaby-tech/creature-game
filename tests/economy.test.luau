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
local Types = require("../src/shared/Types")
local Placeholders = require("./fixtures/Placeholders")

Placeholders.install()

local RUN_LONG_EXPLORATION = false

type Creature = Types.Creature
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
		and Economy.casualPvpCoins(0, false, true) > 0
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
	check(
		"every faucet in the ledger is capped, once-only, diminishing or below cost",
		capped,
		uncapped
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
		Economy.casualPvpCoins(EconomyConfig.CASUAL_PVP_PAID_WINS_PER_DAY, false, true) == 0
			and Economy.casualPvpCoins(0, true, true) == 0
			and Economy.casualPvpCoins(0, false, false) == 0
	)
	check(
		"a giant rematch pays less than its Giant Horn costs (rematches are a coin sink)",
		Economy.battleCoins("Giant", 3, 32, 0, false) < Economy.itemPrice("GiantCall", 3)
	)

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

	-- Ledger refusals.
	local start: Economy.Balances = { coins = 100, candy = 2 }
	local overdraw = Economy.apply(start, "Breed", 101)
	local candyOver = Economy.apply(start, "BreedCandy", 3)
	local unknown = Economy.apply(start, "FreeMoney", 10)
	local fraction = Economy.apply(start, "WildWin", 2.5)
	local negative = Economy.apply(start, "WildWin", -5)
	local nan = Economy.apply(start, "WildWin", 0 / 0)
	local good = Economy.apply(start, "Shop", 100)
	check(
		"the ledger refuses overdrafts, unknown flows and bad amounts, and leaves balances alone",
		not overdraw.ok
			and not candyOver.ok
			and not unknown.ok
			and not fraction.ok
			and not negative.ok
			and not nan.ok
			and overdraw.balances.coins == 100
			and start.coins == 100
			and start.candy == 2
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
	local flows = { "WildWin", "Shop", "Breed", "Release", "BreedCandy", "CandyDaily", "Craft" }
	local bal: Economy.Balances = { coins = 0, candy = 0 }
	local negativeSeen = false
	for _ = 1, 20000 do
		local result = Economy.apply(bal, Rng.pick(rng, flows), Rng.int(rng, 1, 400))
		bal = result.balances
		if bal.coins < 0 or bal.candy < 0 then
			negativeSeen = true
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
	GEM_SPAWN = 0.006, -- chance a wild encounter in biome 2 or later is a gem creature
	BAIT_GEM = 0.35, -- chance a bait spawn is a gem creature
	GATE_WIN = 0.85,
	REMATCH_WIN = 0.8,
	GIANT_LEARN = 0.15, -- added to the win chance per earlier failed attempt
	GIANT_ITEM_BONUS = 0.03, -- per field item brought
	CHILD_REPLACES = 0.3, -- chance a hatched child replaces its more-bred parent in the pair
	MENTOR_MINUTE = 10,
	SURPLUS_DAYS = 3, -- players with more than this many days of income spend on optional sinks
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
	optionalSpend: boolean, -- buys stable expansions and charms when rich
}

local PROFILES: { Profile } = {
	{
		name = "casual",
		minutes = 20,
		lassoStory = 0.3,
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
		optionalSpend = false,
	},
	{
		name = "regular",
		minutes = 45,
		lassoStory = 0.3,
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
		optionalSpend = true,
	},
	{
		name = "heavy",
		minutes = 120,
		lassoStory = 0.3,
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
		optionalSpend = true,
	},
}

type Pair = { a: Creature, b: Creature }
type Egg = { readyAt: number, rarity: Types.Rarity, biome: number, fromGem: boolean } -- minutes
type DayLog = {
	created: number,
	removed: number,
	minutes: number,
	breeds: number,
	candyIn: number,
	candyOut: number,
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
}

local function newCreature(sim: Sim, rarity: Types.Rarity, biome: number): Creature
	sim.nextId += 1
	local c = Breeding.wild("Mossback", `s{sim.nextId}`, 5, rarity, "Moss", sim.rng)
	c.originBiome = biome
	return c
end

local function newPair(sim: Sim, biome: number): Pair
	return { a = newCreature(sim, "Common", biome), b = newCreature(sim, "Common", biome) }
end

local function newDay(biome: number): DayLog
	return {
		created = 0,
		removed = 0,
		minutes = 0,
		breeds = 0,
		candyIn = 0,
		candyOut = 0,
		balance = 0,
		biome = biome,
	}
end

local function furthest(sim: Sim): number
	return math.min(sim.biome, 3)
end

local function flow(sim: Sim, name: string, amount: number)
	amount = math.floor(amount)
	if amount <= 0 then
		return
	end
	local result = Economy.apply(sim.bal, name, amount)
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
			sim.biomeCreated[b] += amount
		end
	else
		if def.limit == "Sink" then
			sim.today.candyOut += amount
		else
			sim.today.candyIn += amount
			sim.candySources[name] = (sim.candySources[name] or 0) + amount
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
	end
end

local function timeLeft(sim: Sim): number
	return sim.sessionEnd - sim.clock
end

local function release(sim: Sim, rarity: Types.Rarity, biome: number)
	local pay = Economy.releasePayout(rarity, biome)
	flow(sim, "Release", pay.coins)
	local material = pay.material
	if material then
		sim.mats[material] += pay.materials
	end
	sim.creatures -= 1
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
				release(sim, "Common", furthest(sim))
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

local function makeGemPair(sim: Sim, biome: number)
	if sim.gemPair == nil then
		sim.gemPair = { a = newCreature(sim, "Gem", biome), b = newCreature(sim, "Common", biome) }
	end
end

local function wildBattle(sim: Sim, biome: number, level: number, lassoShare: number)
	advance(sim, ASSUME.WILD_MIN)
	local kind = Rng.int(sim.rng, 1, ASSUME.KINDS_PER_BIOME)
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
			sim.catchesToday += 1
			addCreature(sim)
			makeGemPair(sim, biome)
		end
	elseif Rng.chance(sim.rng, lassoShare) then
		if throwLasso(sim, "Basic") then
			sim.catchesToday += 1
			addCreature(sim)
		end
	end
	if Rng.chance(sim.rng, sim.p.tonicChance) then
		useTonic(sim)
	elseif Rng.chance(sim.rng, 0.2) then
		advance(sim, ASSUME.HEAL_WALK_MIN)
	end
end

local function claimTasks(sim: Sim)
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
	for _, item in sim.p.giantItems do
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
local function reserve(sim: Sim): number
	local base = Economy.itemPrice("Basic", 1) * 3 + Economy.itemPrice("Tonic", 1)
	if sim.biome <= 3 and sim.tamersDone >= ASSUME.TAMERS[sim.biome] and not sim.giantWon then
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
					gp.b = newCreature(sim, "Gem", egg.biome)
				end
			elseif not egg.fromGem and Rng.chance(sim.rng, ASSUME.CHILD_REPLACES) then
				local pair = sim.pairs[Rng.int(sim.rng, 1, #sim.pairs)]
				if pair.a.breedCount >= pair.b.breedCount then
					pair.a = newCreature(sim, "Common", egg.biome)
				else
					pair.b = newCreature(sim, "Common", egg.biome)
				end
			elseif Rng.chance(sim.rng, sim.p.releaseShare) then
				release(sim, egg.rarity, egg.biome)
			end
		else
			i += 1
		end
	end
end

local function tryBreed(sim: Sim)
	if sim.played < ASSUME.MENTOR_MINUTE then
		return
	end
	if (sim.candySources.CandyMentor or 0) == 0 then
		-- The mentor's lesson: his gifted egg and the candy for the player's first breed.
		flow(sim, "CandyMentor", Economy.candyFor("MentorLesson", 0))
		sim.creatures += 1
	end
	collectEggs(sim)
	while #sim.eggs < sim.pens do
		local nowSeconds = sim.clock * 60
		local choice: Pair? = nil
		local gp = sim.gemPair
		if
			gp
			and sim.bal.candy >= Breeding.candyCost(gp.a, gp.b)
			and Breeding.canBreed(gp.a, gp.b, nowSeconds)
		then
			choice = gp
		else
			local best = math.huge
			for _, pair in sim.pairs do
				if Breeding.canBreed(pair.a, pair.b, nowSeconds) then
					local cost = Breeding.cost(pair.a, pair.b)
					if cost < best then
						best, choice = cost, pair
					end
				end
			end
		end
		if choice == nil then
			return
		end
		local pair: Pair = choice
		local coins = Breeding.cost(pair.a, pair.b)
		local candy = Breeding.candyCost(pair.a, pair.b)
		local charm = sim.p.charmShare > 0
			and Rng.chance(sim.rng, sim.p.charmShare)
			and sim.bal.coins >= coins + Economy.itemPrice("BondCharm", 1) + reserve(sim)
		local total = coins + (if charm then Economy.itemPrice("BondCharm", 1) else 0)
		if sim.bal.candy < candy or sim.bal.coins < total + reserve(sim) then
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
		if candy >= BreedConfig.CANDY_COST.Gem then
			sim.gemBreeds += 1
		end
		if charm then
			spend(sim, "Shop", Economy.itemPrice("BondCharm", 1), false)
		end
		flow(sim, "BreedCandy", candy)
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
	for _, item in sim.p.giantItems do
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
				if b == 1 and sim.questsDone == 2 then
					sim.pens += EconomyConfig.PENS_FROM_QUEST
				end
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
			if Rng.chance(sim.rng, ASSUME.BAIT_GEM) then
				if throwLasso(sim, sim.p.gemLasso) then
					sim.gems += 1
					addCreature(sim)
					makeGemPair(sim, 3)
				end
			elseif throwLasso(sim, "Basic") then
				addCreature(sim)
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
		bal = { coins = 0, candy = 0 },
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
	}
	for i = 1, 3 * ASSUME.KINDS_PER_BIOME do
		sim.kindWins[i] = 0
	end
	for i = 1, 10 do
		sim.tamerPaid[i] = 0
	end
	sim.pairs = { newPair(sim, 1), newPair(sim, 1) }
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
	v.candyEnd = sim.bal.candy
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

	print("\n  C. Candy")
	print("  player   | per day wk1 | per day after story | unspent at end | first breed (minute)")
	for _, profile in PROFILES do
		local r = results[profile.name]
		print(
			string.format(
				"  %-8s |    %4.1f     |        %4.1f         |      %4.0f      |   %4.0f",
				profile.name,
				mean(r, "candyWeek1"),
				mean(r, "candySteady"),
				mean(r, "candyEnd"),
				mean(r, "firstBreedPlayed")
			)
		)
	end

	print("\n  D. Coins on hand")
	print(
		"  player   | end wk1  end wk2  end wk3  end wk4 | income/day after story | days held d7, d30 | first gem child"
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
				"  %-8s | %7.0f  %7.0f  %7.0f  %7.0f |        %7.0f         |    %4.1f, %4.1f     | %s",
				profile.name,
				mean(r, "week1Balance"),
				mean(r, "week2Balance"),
				mean(r, "week3Balance"),
				mean(r, "week4Balance"),
				mean(r, "steadyIncome"),
				mean(r, "daysOnHand7"),
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
	local sinkNames = { "Breed", "Shop", "Craft", "StableExpansion" }
	local candyNames = {
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
	while hours < 24 * 400 do
		hours += 1
		candy += candyPerDay / 24
		if hours >= readyAt and candy >= Breeding.candyCost(a, b) then
			candy -= Breeding.candyCost(a, b)
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

local function printChildTable(results: { [string]: { Summary } })
	print(
		"\n  G. Days from owning a pure biome-3 pair to a child of the same tier, all candy spent on it"
	)
	print(
		"     (median and 90th percentile days; median coins, and those coins in days of that player's income)"
	)
	print("  tier    | candy | chance | casual                 | regular                | heavy")
	local tiers: { Types.Rarity } = { "Gem", "Ruby", "Diamond" }
	for _, tier in tiers do
		local cells = {}
		for _, profile in PROFILES do
			local rate = mean(results[profile.name], "candySteady")
			local income = mean(results[profile.name], "steadyIncome")
			local daysList, coinList = {}, {}
			for seed = 1, 301 do
				local d, c = daysToChild(tier, rate, seed)
				table.insert(daysList, d)
				table.insert(coinList, c)
			end
			table.sort(daysList)
			table.sort(coinList)
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
				BreedConfig.CANDY_COST[tier],
				pct(if rule then rule.both else 0),
				cells[1],
				cells[2],
				cells[3]
			)
		)
	end
end

------------------------------------------------------------------------------------------------
print("\n== Simulation: three player types, 30 days, fixed seeds ==")
------------------------------------------------------------------------------------------------

local DAYS = 30
local function simulate(seeds: number): { [string]: { Summary } }
	local results: { [string]: { Summary } } = {}
	for _, profile in PROFILES do
		results[profile.name] = runProfile(profile, seeds, DAYS)
	end
	printTables(results, DAYS)
	printChildTable(results)
	return results
end

-- The longer exploration: many more seeds. Off in the gate; flip RUN_LONG_EXPLORATION to run it.
local function longExploration()
	print("\n== Long exploration: 200 seeds per player type ==")
	simulate(200)
end

local results = simulate(12)
if RUN_LONG_EXPLORATION then
	longExploration()
end

print("\n== Target bands (shortened simulation, fixed seeds) ==")
for _, profile in PROFILES do
	local name = profile.name
	local r = results[name]
	local two = mean(r, "twoHourRatio")
	check(
		`{name}: coins removed are 60-70% of created in the first two hours`,
		two >= 0.6 and two <= 0.7,
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
	local grind = math.max(maxOf(r, "grind1"), maxOf(r, "grind2"), maxOf(r, "grind3"))
	check(
		`{name}: nobody grinds more than 15 minutes before a giant attempt`,
		grind <= 15,
		string.format("%.1f min", grind)
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
local regularCandy, heavyCandy =
	mean(results.regular, "candySteady"), mean(results.heavy, "candySteady")
check(
	"a regular player earns about 5 candy a day after the story (4.5 to 6)",
	regularCandy >= 4.5 and regularCandy <= 6,
	string.format("%.1f", regularCandy)
)
check(
	"a heavy player earns about 8 candy a day after the story (7 to 9)",
	heavyCandy >= 7 and heavyCandy <= 9,
	string.format("%.1f", heavyCandy)
)
check(
	"one-time candy gives a visible early burst (week 1 above the steady rate)",
	mean(results.regular, "candyWeek1") > regularCandy
)
local held = mean(results.regular, "daysOnHand7")
check(
	"a regular player holds 2 to 7 days of income after the first week",
	held >= 2 and held <= 7,
	string.format("%.1f days", held)
)

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("tests failed")
end
