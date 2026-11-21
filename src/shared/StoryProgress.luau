--!strict
-- Finishing a story beat and paying its gifts, as pure functions (approval pack 2: one-time
-- gifts). The server calls `complete` once it has checked the beat's trigger itself (the place
-- was reached, the battle won, the character talked to); the device only says which starter it
-- picked.
--
-- A beat finishes once: its flag is set in the same step that pays its gifts, with no pause, so
-- nothing can be paid twice. Creatures go through Grants.giveOnce, so with a full stable they
-- wait in the saved Pending list and arrive when there is room (`rebuild` makes them again).

local Biomes = require("../content/Biomes")
local Breeding = require("./Breeding")
local BreedConfig = require("../config/BreedConfig")
local Grants = require("./Grants")
local Profile = require("./Profile")
local ProfileConfig = require("../config/ProfileConfig")
local Rng = require("./Rng")
local Species = require("../content/Species")
local Types = require("./Types")
local World = require("./World")
local WorldTypes = require("./WorldTypes")

export type CompleteInput = {
	beatId: unknown, -- from the device or the world service; checked against the chapter
	choice: unknown, -- the starter picked, for a Starter gift
	triggerMet: boolean, -- the server's own check of the beat's trigger
	newId: () -> string, -- fresh unique creature ids, from the server
	seed: number,
	unixTime: number,
}

export type Gift = { kind: WorldTypes.RewardKind, detail: string?, waiting: boolean? }
export type Completed = { beat: WorldTypes.Beat, gifts: { Gift }, unlocks: { string } }

local StoryProgress = {}

-- The colour a gifted creature of this species wears: its first colour in any spawn table of its
-- home biome, or Moss.
function StoryProgress.giftColour(species: string): string
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
	beatId: string,
	index: number,
	species: string,
	level: number,
	rarity: string,
	colour: string
): string
	return `{beatId}|{index}|{species}|{level}|{rarity}|{colour}`
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
function StoryProgress.rebuild(ref: string, id: string, seed: number): Types.Creature?
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
	if
		profile.Creatures[id]
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
	local a = Breeding.wild(parentA, "gift_a", 5, "Common", StoryProgress.giftColour(parentA), rng)
	local b = Breeding.wild(parentB, "gift_b", 5, "Common", StoryProgress.giftColour(parentB), rng)
	if not Breeding.canBreed(a, b, unixTime) then
		return nil
	end
	local rollSeed = Rng.int(rng, 1, 2147483646)
	local bred = Breeding.breed(a, b, Rng.new(rollSeed), { childId = newId(), now = unixTime })
	return { child = bred.child, hatchAt = unixTime + BreedConfig.GIFT_EGG_SECONDS, seed = rollSeed }
end

local function eggRef(beatId: string, parentA: string, parentB: string): string
	return `{beatId}|{parentA}|{parentB}`
end

-- Puts waiting gift eggs into free pens. Returns how many were placed.
function StoryProgress.claimEggs(
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

-- Finishes the next beat of the chapter and pays its gifts. Returns nil and a reason, changing
-- nothing, if the beat is not next, its trigger was not met, a starter choice is bad, or a gift
-- cannot be made. Every gift is built before anything changes, so a beat is paid whole or not at all.
function StoryProgress.complete(
	profile: Profile.Profile,
	chapter: WorldTypes.Chapter,
	input: CompleteInput
): (Completed?, string?)
	local beat = World.nextBeat(chapter, profile.Story.flags)
	if beat == nil or beat.id ~= input.beatId then
		return nil, "That part of the story is not next"
	end
	if not input.triggerMet then
		return nil, "Not yet"
	end

	-- 1. Build and check everything, changing nothing.
	local refs: { [number]: string } = {}
	local eggs: { [number]: Profile.Egg } = {}
	local rng = Rng.new(input.seed)
	for index, reward in beat.grants do
		if reward.kind == "Starter" then
			if typeof(input.choice) ~= "string" or not table.find(reward.choices, input.choice) then
				return nil, "Pick one of the three"
			end
			local choice = input.choice :: string
			refs[index] = giftRef(
				beat.id,
				index,
				choice,
				reward.level,
				"Common",
				StoryProgress.giftColour(choice)
			)
		elseif reward.kind == "Creature" then
			refs[index] =
				giftRef(beat.id, index, reward.species, reward.level, reward.rarity, reward.colour)
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
		if ref and StoryProgress.rebuild(ref, "check", 1) == nil then
			return nil, "That gift cannot be made"
		end
	end

	-- 2. Pay it all, with no pause. Pens first, so a gift egg finds its pen.
	profile.Story.flags[beat.id] = true
	local gifts: { Gift } = {}
	for _, reward in beat.grants do
		if reward.kind == "Pen" then
			profile.Pens = math.min(profile.Pens + 1, ProfileConfig.MAX_PENS)
			table.insert(gifts, { kind = "Pen" })
		end
	end
	for index, reward in beat.grants do
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
				profile.Story.starter = input.choice :: string
			end
			local ref = refs[index]
			local id = input.newId()
			local source: Grants.Source = if reward.kind == "Starter" then "Starter" else "Token"
			local grant = Grants.giveOnce(profile, source, ref, function()
				return assert(StoryProgress.rebuild(ref, id, input.seed), "checked above")
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
			if #profile.Eggs < profile.Pens then
				table.insert(profile.Eggs, eggs[index])
				table.insert(gifts, { kind = "Egg", detail = eggs[index].child.id })
			else
				-- No free pen: the egg waits in the saved list and is placed when a pen frees up.
				table.insert(
					profile.Pending,
					{ source = "MentorEgg", ref = eggRef(beat.id, reward.parentA, reward.parentB) }
				)
				table.insert(gifts, { kind = "Egg", waiting = true })
			end
		end
	end
	return { beat = beat, gifts = gifts, unlocks = beat.unlocks }, nil
end

return StoryProgress
