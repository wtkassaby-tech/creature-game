--!strict
-- The breeding rules as pure functions: who can breed, what it costs, what the preview shows,
-- and the roll itself. No Roblox services, so the server and the Lune tests run the same code.

local BreedConfig = require("../config/BreedConfig")
local Rng = require("./Rng")
local Species = require("../content/Species")
local Stats = require("./Stats")
local Types = require("./Types")

type Creature = Types.Creature
type Slot = Types.Slot
type Rarity = Types.Rarity

export type Charm = { slot: Slot, favour: "A" | "B" }
export type BreedOptions = { childId: string, now: number, charm: Charm? }
export type BreedResult = {
	child: Creature,
	hatchAt: number,
	cost: number,
	candy: { Types.CandyNeed }, -- what Breeding.candyCost asked for, by type
	parentA: { breedCount: number, breedReadyAt: number },
	parentB: { breedCount: number, breedReadyAt: number },
}

-- Chance of each rarity for a child. Rarities that cannot happen are left out.
export type RarityOdds = {
	Common: number?,
	Uncommon: number?,
	Gem: number?,
	Ruby: number?,
	Diamond: number?,
	Cosmic: number?,
}

local Breeding = {}

-- Builds the five parts in slot order (the order matters: it fixes the order of random rolls).
local function buildParts(make: (slot: Slot) -> Types.Part): Types.Parts
	return {
		Head = make("Head"),
		Torso = make("Torso"),
		FrontLimbs = make("FrontLimbs"),
		Legs = make("Legs"),
		Tail = make("Tail"),
	}
end

local function rarityIndex(rarity: Rarity): number
	return table.find(BreedConfig.RARITY_ORDER, rarity) or 0
end

local function isKin(a: Creature, b: Creature): boolean
	if a.parents and table.find(a.parents, b.id) then
		return true -- b is a's parent
	end
	if b.parents and table.find(b.parents, a.id) then
		return true
	end
	if a.parents and b.parents then
		-- Full siblings share both parents.
		return table.find(b.parents, a.parents[1]) ~= nil
			and table.find(b.parents, a.parents[2]) ~= nil
	end
	return false
end

-- Returns true, or false with a reason the UI can show.
function Breeding.canBreed(a: Creature, b: Creature, now: number): (boolean, string?)
	if a.id == b.id then
		return false, "Pick two different creatures"
	end
	if a.bodyPlan ~= b.bodyPlan then
		return false, "Parents must share a body plan"
	end
	if a.rarity == "Cosmic" or b.rarity == "Cosmic" then
		return false, "Cosmic creatures cannot breed"
	end
	if isKin(a, b) then
		return false, "Close relatives cannot breed"
	end
	for _, parent in { a, b } do
		if now < parent.breedReadyAt then
			return false, "A parent is still resting"
		end
	end
	return true, nil
end

local function rarerOf(a: Creature, b: Creature): Rarity
	return if rarityIndex(a.rarity) >= rarityIndex(b.rarity) then a.rarity else b.rarity
end

-- Entry for the nth breed; breeds past the end of the list use the last entry.
local function nth(list: { number }, index: number): number
	return list[math.min(index, #list)]
end

-- Turns the two charm values sent by a player's device into a Charm, or nil if they are not
-- a real slot and side. Nothing from the device is trusted beyond this.
function Breeding.parseCharm(slot: unknown, favour: unknown): Charm?
	local side: "A" | "B"
	if favour == "A" then
		side = "A"
	elseif favour == "B" then
		side = "B"
	else
		return nil
	end
	for _, name: Slot in BreedConfig.SLOTS do
		if name == slot then
			return { slot = name, favour = side }
		end
	end
	return nil
end

-- Coins for this breed.
function Breeding.cost(a: Creature, b: Creature): number
	local biomeTier = math.max(a.originBiome, b.originBiome)
	local countMult = (
		nth(BreedConfig.COST_COUNT, a.breedCount + 1)
		+ nth(BreedConfig.COST_COUNT, b.breedCount + 1)
	) / 2
	return math.floor(
		BreedConfig.COST_BASE * biomeTier * BreedConfig.COST_RARITY[rarerOf(a, b)] * countMult
	)
end

-- A creature's type: the element of its torso's species (the torso sets the type).
function Breeding.element(creature: Creature): Types.Element
	return Species[creature.parts.Torso.species].element
end

-- Breeding Candy for this breed, by type: each parent needs CANDY_COST[its own rarity] of its
-- own type. A same-type pair is one entry with both amounts added; otherwise parent A's type
-- comes first. Entries with nothing to pay are left out. How the balance pays it (typed candy
-- first, then Prism) is Economy.candyPayment.
function Breeding.candyCost(a: Creature, b: Creature): { Types.CandyNeed }
	local needs: { Types.CandyNeed } = {}
	for _, parent in { a, b } do
		-- A captured giant pays in its own Giant Candy instead (Breeding.giantCandyCost).
		local amount: number = if parent.isGiant then 0 else BreedConfig.CANDY_COST[parent.rarity]
		local element: Types.Element = Breeding.element(parent)
		local merged = false
		for _, need in needs do
			if need.element == element then
				need.amount += amount
				merged = true
			end
		end
		if not merged and amount > 0 then
			local need: Types.CandyNeed = { element = element, amount = amount }
			table.insert(needs, need)
		end
	end
	return needs
end

export type GiantCandyNeed = { species: string, amount: number }

-- Giant Candy for this breed: each captured-giant parent needs GIANT_CANDY_COST of its own
-- kind (two of the same giant need twice as much). Empty for a breed with no giant in it.
function Breeding.giantCandyCost(a: Creature, b: Creature): { GiantCandyNeed }
	local needs: { GiantCandyNeed } = {}
	for _, parent in { a, b } do
		if parent.isGiant then
			local species = parent.parts.Torso.species
			local merged = false
			for _, need in needs do
				if need.species == species then
					need.amount += BreedConfig.GIANT_CANDY_COST
					merged = true
				end
			end
			if not merged then
				table.insert(needs, { species = species, amount = BreedConfig.GIANT_CANDY_COST })
			end
		end
	end
	return needs
end

-- True if the player's items hold every Giant Candy this breed needs. `keyFor` gives the item
-- key for a giant's species (Economy.giantCandyKey).
function Breeding.hasGiantCandy(
	items: { [string]: number },
	needs: { GiantCandyNeed },
	keyFor: (species: string) -> string
): boolean
	for _, need in needs do
		if (items[keyFor(need.species)] or 0) < need.amount then
			return false
		end
	end
	return true
end

-- Total candy of every type a breed needs (for summaries; paying uses the list).
function Breeding.candyTotal(needs: { Types.CandyNeed }): number
	local total = 0
	for _, need in needs do
		total += need.amount
	end
	return total
end

-- Chance of each rarity for the child. The values sum to 1.
function Breeding.rarityOdds(a: Creature, b: Creature): RarityOdds
	local odds: RarityOdds = {}
	local remaining = 1
	-- Roll each gem tier a parent actually has, highest first.
	for index = #BreedConfig.RARITY_ORDER, 1, -1 do
		local tier: Types.Rarity = BreedConfig.RARITY_ORDER[index]
		local rule = BreedConfig.RARITY_INHERIT[tier]
		if rule and (a.rarity == tier or b.rarity == tier) then
			local both = rarityIndex(a.rarity) >= index and rarityIndex(b.rarity) >= index
			local chance = if both then rule.both else rule.one
			odds[tier] = remaining * chance
			remaining *= 1 - chance
		end
	end
	-- Otherwise the child is Common or Uncommon, following a random parent (gem parents count as Uncommon).
	local function base(rarity: Rarity): Rarity
		return if rarity == "Common" then "Common" else "Uncommon"
	end
	odds[base(a.rarity)] = (odds[base(a.rarity)] or 0) + remaining / 2
	odds[base(b.rarity)] = (odds[base(b.rarity)] or 0) + remaining / 2
	return odds
end

local function rollRarity(a: Creature, b: Creature, rng: Rng.Rng): Rarity
	local odds = Breeding.rarityOdds(a, b)
	local roll = Rng.next(rng)
	local running = 0
	local last: Rarity = "Common"
	for index = #BreedConfig.RARITY_ORDER, 1, -1 do
		local tier: Types.Rarity = BreedConfig.RARITY_ORDER[index]
		local chance = odds[tier]
		if chance then
			running += chance
			last = tier
			if roll < running then
				return tier
			end
		end
	end
	return last
end

-- One pip up or down, pulled toward the middle: at 10 it cannot rise, at 0 it cannot fall.
local function driftQuality(quality: number, rng: Rng.Rng): number
	local span = BreedConfig.QUALITY_MAX - BreedConfig.QUALITY_MIN
	local up = BreedConfig.QUALITY_DRIFT * (BreedConfig.QUALITY_MAX - quality) / span
	local down = BreedConfig.QUALITY_DRIFT * (quality - BreedConfig.QUALITY_MIN) / span
	local roll = Rng.next(rng)
	if roll < up then
		return quality + 1
	elseif roll < up + down then
		return quality - 1
	end
	return quality
end

-- The child takes one colour copy from each parent. A recessive colour shows only if both copies match.
local function inheritColour(a: Creature, b: Creature, rng: Rng.Rng): Types.Colour
	local fromA = if Rng.chance(rng, 0.5) then a.colour.shown else a.colour.carried
	local fromB = if Rng.chance(rng, 0.5) then b.colour.shown else b.colour.carried
	if fromA == fromB then
		return { shown = fromA, carried = fromB }
	end
	local aRecessive = BreedConfig.COLOURS[fromA].recessive
	local bRecessive = BreedConfig.COLOURS[fromB].recessive
	if aRecessive ~= bRecessive then
		return if aRecessive
			then { shown = fromB, carried = fromA }
			else { shown = fromA, carried = fromB }
	end
	return if Rng.chance(rng, 0.5)
		then { shown = fromA, carried = fromB }
		else { shown = fromB, carried = fromA }
end

local function partChanceFromA(slot: Slot, charm: Charm?): number
	if charm and charm.slot == slot then
		return if charm.favour == "A"
			then BreedConfig.CHARM_CHANCE
			else 1 - BreedConfig.CHARM_CHANCE
	end
	return BreedConfig.PART_CHANCE
end

-- The roll. Does not change the parents: it returns the child and the parents' new counters,
-- so the server can save everything together or not at all.
function Breeding.breed(a: Creature, b: Creature, rng: Rng.Rng, options: BreedOptions): BreedResult
	local ok, reason = Breeding.canBreed(a, b, options.now)
	assert(ok, reason)

	local parts = buildParts(function(slot: Slot): Types.Part
		local donor = if Rng.chance(rng, partChanceFromA(slot, options.charm)) then a else b
		local inherited = donor.parts[slot]
		return { species = inherited.species, quality = driftQuality(inherited.quality, rng) }
	end)

	local colour = inheritColour(a, b, rng)
	if Rng.chance(rng, BreedConfig.RARE_MUTATION_CHANCE) then
		if Rng.chance(rng, 0.5) then
			local mutated = Rng.pick(rng, BreedConfig.MUTATION_COLOURS)
			colour = { shown = mutated, carried = mutated } -- a mutated colour shows at once
		else
			local slot: Types.Slot = BreedConfig.SLOTS[Rng.int(rng, 1, #BreedConfig.SLOTS)]
			local jump = if Rng.chance(rng, 0.5)
				then BreedConfig.RARE_MUTATION_PIPS
				else -BreedConfig.RARE_MUTATION_PIPS
			parts[slot].quality = math.clamp(
				parts[slot].quality + jump,
				BreedConfig.QUALITY_MIN,
				BreedConfig.QUALITY_MAX
			)
		end
	end

	local jitter = (Rng.next(rng) * 2 - 1) * BreedConfig.SIZE_JITTER
	local size =
		math.clamp((a.size + b.size) / 2 + jitter, BreedConfig.SIZE_MIN, BreedConfig.SIZE_MAX)
	local rarity: Types.Rarity = rollRarity(a, b, rng)

	local child: Creature = {
		id = options.childId,
		bodyPlan = a.bodyPlan,
		parts = parts,
		size = math.floor(size * 100 + 0.5) / 100,
		colour = colour,
		rarity = rarity,
		level = math.max(1, math.floor((a.level + b.level) / 2 * BreedConfig.LEVEL_SHARE)),
		xp = 0,
		generation = math.max(a.generation, b.generation) + 1,
		parents = { a.id, b.id },
		breedCount = 0,
		breedReadyAt = 0,
		originBiome = math.max(a.originBiome, b.originBiome), -- closes the "biome reached" loophole
		isGiant = false,
		-- A child of a creature that can never be traded can never be traded either,
		-- so breeding cannot be used to move a bound creature's value into a tradable one.
		bound = a.bound or b.bound,
	}

	local function after(parent: Creature)
		local count = parent.breedCount + 1
		return {
			breedCount = count,
			breedReadyAt = options.now + nth(BreedConfig.COOLDOWN[parent.rarity], count),
		}
	end

	return {
		child = child,
		hatchAt = options.now + BreedConfig.HATCH_SECONDS[rarity],
		cost = Breeding.cost(a, b),
		candy = Breeding.candyCost(a, b),
		parentA = after(a),
		parentB = after(b),
	}
end

export type SlotPreview = {
	slot: Slot,
	fromA: { species: string, quality: number, chance: number },
	fromB: { species: string, quality: number, chance: number },
}
export type Preview = {
	slots: { SlotPreview },
	statRange: { low: Stats.StatBlock, high: Stats.StatBlock },
	rarityOdds: RarityOdds,
	level: number,
	cost: number,
	candy: { Types.CandyNeed }, -- candy by type, as Breeding.candyCost
}

-- What the breeder screen shows before the player pays. Enumerates all 32 part combinations
-- (2 choices for each of 5 slots) to give the true lowest and highest stats, ignoring mutation.
function Breeding.preview(a: Creature, b: Creature, charm: Charm?): Preview
	local slots: { SlotPreview } = {}
	for _, slot: Types.Slot in BreedConfig.SLOTS do
		local chanceA = partChanceFromA(slot, charm)
		table.insert(slots, {
			slot = slot,
			fromA = {
				species = a.parts[slot].species,
				quality = a.parts[slot].quality,
				chance = chanceA,
			},
			fromB = {
				species = b.parts[slot].species,
				quality = b.parts[slot].quality,
				chance = 1 - chanceA,
			},
		})
	end

	local level = math.max(1, math.floor((a.level + b.level) / 2 * BreedConfig.LEVEL_SHARE))
	local low: Stats.StatBlock =
		{ Hp = math.huge, Attack = math.huge, Defence = math.huge, Speed = math.huge }
	local high: Stats.StatBlock = { Hp = 0, Attack = 0, Defence = 0, Speed = 0 }
	for mask = 0, 2 ^ #BreedConfig.SLOTS - 1 do
		local index = 0
		local parts = buildParts(function(slot: Slot): Types.Part
			index += 1
			local fromA = bit32.band(mask, bit32.lshift(1, index - 1)) ~= 0
			return if fromA then a.parts[slot] else b.parts[slot]
		end)
		local candidate = table.clone(a)
		candidate.parts = parts
		candidate.size = (a.size + b.size) / 2
		candidate.level = level
		candidate.rarity = "Common"
		local stats = Stats.compute(candidate)
		for _, stat: Types.Stat in BreedConfig.STATS do
			low[stat] = math.min(low[stat], stats[stat])
			high[stat] = math.max(high[stat], stats[stat])
		end
	end

	return {
		slots = slots,
		statRange = { low = low, high = high },
		rarityOdds = Breeding.rarityOdds(a, b),
		level = level,
		cost = Breeding.cost(a, b),
		candy = Breeding.candyCost(a, b),
	}
end

-- A wild-caught creature of one species, for spawns and tests.
function Breeding.wild(
	speciesName: string,
	id: string,
	level: number,
	rarity: Rarity,
	colour: string,
	rng: Rng.Rng
): Creature
	local def = Species[speciesName]
	local parts = buildParts(function(_slot: Slot): Types.Part
		return {
			species = speciesName,
			quality = Rng.int(rng, BreedConfig.WILD_QUALITY_MIN, BreedConfig.WILD_QUALITY_MAX),
		}
	end)
	return {
		id = id,
		bodyPlan = def.bodyPlan,
		parts = parts,
		size = 1,
		colour = { shown = colour, carried = colour },
		rarity = rarity,
		level = level,
		xp = 0,
		generation = 0,
		parents = nil,
		breedCount = 0,
		breedReadyAt = 0,
		originBiome = def.biome,
		isGiant = false,
		bound = false,
	}
end

return Breeding
