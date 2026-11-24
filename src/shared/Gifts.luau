--!strict
-- Paying a list of gifts (a story beat's, a quest's) into a player's profile, as pure functions
-- (approval pack 2: one-time gifts). Two steps, so a gift list is paid whole or not at all:
-- `prepare` builds and checks everything and changes nothing; `pay` then cannot fail.
--
-- Creatures go through Grants.giveOnce: with a full stable they wait in the saved Pending list
-- and arrive when there is room (`rebuild` makes them again from the saved ref). A gift egg with
-- no free pen waits the same way (`claimEggs`). The caller sets its own "done" flag in the same
-- step as `pay`, with no pause, so nothing can be paid twice.

local Biomes = require("../content/Biomes")
local Breeding = require("./Breeding")
local BreedConfig = require("../config/BreedConfig")
local Grants = require("./Grants")
local Profile = require("./Profile")
local ProfileConfig = require("../config/ProfileConfig")
local Rng = require("./Rng")
local Species = require("../content/Species")
local Team = require("./Team")
local Types = require("./Types")
local WorldTypes = require("./WorldTypes")

export type Input = {
	choice: unknown, -- the starter picked, for a Starter gift
	newId: () -> string, -- fresh unique creature ids, from the server
	seed: number,
	unixTime: number,
}

export type Gift = { kind: WorldTypes.RewardKind, detail: string?, waiting: boolean? }

-- Everything `pay` needs, built and checked by `prepare`.
export type Prepared = {
	key: string, -- what is being paid for (a beat id, a quest id); part of every saved ref
	rewards: { WorldTypes.Reward },
	refs: { [number]: string },
	eggs: { [number]: Profile.Egg },
	choice: string?,
	input: Input,
}

local Gifts = {}

-- The colour a gifted creature of this species wears: its first colour in any spawn table of its
-- home biome, or Moss.
function Gifts.giftColour(species: string): string
	for _, biome in Biomes do
		for _, route in biome.routes do
			for _, row in route.spawns do
				if row.species == species and #row.colours > 0 then
					return row.colours[1]
				end
			end
		end
	end
	return "Moss"
end

-- Encodes a gifted creature into a Pending ref and back, so a waiting gift is rebuilt exactly.
local function giftRef(
	key: string,
	index: number,
	species: string,
	level: number,
	rarity: string,
	colour: string
): string
	return `{key}|{index}|{species}|{level}|{rarity}|{colour}`
end

local RARITIES: { Types.Rarity } = { "Common", "Uncommon", "Gem", "Ruby", "Diamond", "Cosmic" }

local function parseRarity(text: string): Types.Rarity?
	for _, rarity: Types.Rarity in RARITIES do
		if rarity == text then
			return rarity
		end
	end
	return nil
end

-- Rebuilds a waiting gift from its Pending entry (for Grants.claimPending). Nil if the species no
-- longer exists, so the entry is kept rather than lost.
function Gifts.rebuild(ref: string, id: string, seed: number): Types.Creature?
	local parts = string.split(ref, "|")
	if #parts ~= 6 then
		return nil
	end
	local species = parts[3]
	local level = tonumber(parts[4])
	local rarity: Types.Rarity? = parseRarity(parts[5])
	if Species[species] == nil or level == nil or rarity == nil then
		return nil
	end
	return Breeding.wild(species, id, level, rarity, parts[6], Rng.new(seed))
end

local function addToTeam(profile: Profile.Profile, id: string)
	local creature = profile.Creatures[id]
	if
		creature
		and Team.mayBattle(profile, creature)
		and not table.find(profile.Team, id)
		and #profile.Team < Profile.teamSize(profile.Story.badges)
	then
		table.insert(profile.Team, id)
	end
end

-- The mentor's egg: two wild parents are made for the roll only and never kept. The child is
-- decided now, like every egg. Nil if the two cannot breed (a content mistake).
local function giftEgg(
	parentA: string,
	parentB: string,
	newId: () -> string,
	unixTime: number,
	seed: number
): Profile.Egg?
	if Species[parentA] == nil or Species[parentB] == nil then
		return nil
	end
	local rng = Rng.new(seed)
	local a = Breeding.wild(parentA, "gift_a", 5, "Common", Gifts.giftColour(parentA), rng)
	local b = Breeding.wild(parentB, "gift_b", 5, "Common", Gifts.giftColour(parentB), rng)
	if not Breeding.canBreed(a, b, unixTime) then
		return nil
	end
	local rollSeed = Rng.int(rng, 1, 2147483646)
	local bred = Breeding.breed(a, b, Rng.new(rollSeed), { childId = newId(), now = unixTime })
	return { child = bred.child, hatchAt = unixTime + BreedConfig.GIFT_EGG_SECONDS, seed = rollSeed }
end

local function eggRef(key: string, parentA: string, parentB: string): string
	return `{key}|{parentA}|{parentB}`
end

-- Puts waiting gift eggs into free pens. Returns how many were placed.
function Gifts.claimEggs(
	profile: Profile.Profile,
	newId: () -> string,
	unixTime: number,
	seed: number
): number
	local placed = 0
	local index = 1
	while index <= #profile.Pending and #profile.Eggs < profile.Pens do
		local pending = profile.Pending[index]
		local parts = string.split(pending.ref, "|")
		local egg = if pending.source == "MentorEgg" and #parts == 3
			then giftEgg(parts[2], parts[3], newId, unixTime, seed + index)
			else nil
		if egg then
			table.remove(profile.Pending, index)
			table.insert(profile.Eggs, egg)
			placed += 1
		else
			index += 1
		end
	end
	return placed
end

-- Builds and checks every gift, changing nothing. Returns nil and a reason if a starter choice
-- is bad or a gift cannot be made (a content mistake).
function Gifts.prepare(
	key: string,
	rewards: { WorldTypes.Reward },
	input: Input
): (Prepared?, string?)
	local refs: { [number]: string } = {}
	local eggs: { [number]: Profile.Egg } = {}
	local choice: string? = nil
	local rng = Rng.new(input.seed)
	for index, reward in rewards do
		if reward.kind == "Starter" then
			if typeof(input.choice) ~= "string" or not table.find(reward.choices, input.choice) then
				return nil, "Pick one of the three"
			end
			local picked = input.choice :: string
			choice = picked
			refs[index] =
				giftRef(key, index, picked, reward.level, "Common", Gifts.giftColour(picked))
		elseif reward.kind == "Creature" then
			refs[index] =
				giftRef(key, index, reward.species, reward.level, reward.rarity, reward.colour)
		elseif reward.kind == "Egg" then
			local egg = giftEgg(
				reward.parentA,
				reward.parentB,
				input.newId,
				input.unixTime,
				Rng.int(rng, 1, 2147483646)
			)
			if not egg then
				return nil, "That gift cannot be made"
			end
			eggs[index] = egg
		end
		local ref = refs[index]
		if ref and Gifts.rebuild(ref, "check", 1) == nil then
			return nil, "That gift cannot be made"
		end
	end
	return { key = key, rewards = rewards, refs = refs, eggs = eggs, choice = choice, input = input },
		nil
end

-- Pays prepared gifts, with no pause. Pens first, so a gift egg finds its pen. `source` is how
-- a gifted creature (not a starter) is recorded: "Token" for the story, "Quest" for quests.
function Gifts.pay(profile: Profile.Profile, prepared: Prepared, source: Grants.Source): { Gift }
	local input = prepared.input
	local gifts: { Gift } = {}
	for _, reward in prepared.rewards do
		if reward.kind == "Pen" then
			profile.Pens = math.min(profile.Pens + 1, ProfileConfig.MAX_PENS)
			table.insert(gifts, { kind = "Pen" })
		end
	end
	for index, reward in prepared.rewards do
		if reward.kind == "Coins" then
			profile.Coins += reward.amount
			table.insert(gifts, { kind = "Coins", detail = tostring(reward.amount) })
		elseif reward.kind == "PrismCandy" then
			profile.Candy.prism += reward.amount
			table.insert(gifts, { kind = "PrismCandy", detail = tostring(reward.amount) })
		elseif reward.kind == "Item" then
			profile.Items[reward.item] = (profile.Items[reward.item] or 0) + reward.count
			table.insert(gifts, { kind = "Item", detail = reward.item :: string })
		elseif reward.kind == "Material" then
			profile.Items[reward.material] = (profile.Items[reward.material] or 0) + reward.count
			table.insert(gifts, { kind = "Material", detail = reward.material :: string })
		elseif reward.kind == "Badge" then
			profile.Story.flags[reward.id] = true
			profile.Story.badges += 1
			table.insert(gifts, { kind = "Badge", detail = reward.name })
		elseif reward.kind == "Starter" or reward.kind == "Creature" then
			if reward.kind == "Starter" then
				profile.Story.starter = prepared.choice
			end
			local ref = prepared.refs[index]
			local id = input.newId()
			local from: Grants.Source = if reward.kind == "Starter" then "Starter" else source
			local grant = Grants.giveOnce(profile, from, ref, function()
				return assert(Gifts.rebuild(ref, id, input.seed), "checked by prepare")
			end)
			local granted = grant.outcome == "Granted"
			if granted then
				addToTeam(profile, id)
			end
			table.insert(gifts, {
				kind = reward.kind,
				detail = if granted then id else nil,
				waiting = grant.outcome == "Waiting",
			})
		elseif reward.kind == "Egg" then
			local egg = prepared.eggs[index]
			if #profile.Eggs < profile.Pens then
				table.insert(profile.Eggs, egg)
				table.insert(gifts, { kind = "Egg", detail = egg.child.id })
			else
				-- No free pen: the egg waits in the saved list and is placed when a pen frees up.
				table.insert(profile.Pending, {
					source = "MentorEgg",
					ref = eggRef(prepared.key, reward.parentA, reward.parentB),
				})
				table.insert(gifts, { kind = "Egg", waiting = true })
			end
		end
	end
	return gifts
end

return Gifts
