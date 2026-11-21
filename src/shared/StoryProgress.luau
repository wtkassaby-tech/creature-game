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
	if profile.Creatures[id] and #profile.Team < Profile.teamSize(profile.Story.badges) then
		table.insert(profile.Team, id)
	end
end

local function giveCreature(
	profile: Profile.Profile,
	source: Grants.Source,
	ref: string,
	input: CompleteInput,
	gifts: { Gift },
	kind: WorldTypes.RewardKind
)
	local id = input.newId()
	local grant = Grants.giveOnce(profile, source, ref, function()
		return assert(StoryProgress.rebuild(ref, id, input.seed), "gift species exists")
	end)
	if grant.outcome == "Granted" then
		addToTeam(profile, id)
	end
	table.insert(gifts, { kind = kind, detail = id, waiting = grant.outcome == "Waiting" })
end

-- Finishes the next beat of the chapter and pays its gifts. Returns nil and a reason, changing
-- nothing, if the beat is not the next one, its trigger was not met, or a starter choice is bad.
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

	-- Check every gift before changing anything.
	for _, reward in beat.grants do
		if reward.kind == "Starter" then
			if typeof(input.choice) ~= "string" or not table.find(reward.choices, input.choice) then
				return nil, "Pick one of the three"
			end
		elseif reward.kind == "Creature" and Species[reward.species] == nil then
			return nil, "That gift does not exist"
		elseif
			reward.kind == "Egg"
			and (Species[reward.parentA] == nil or Species[reward.parentB] == nil)
		then
			return nil, "That gift does not exist"
		end
	end

	profile.Story.flags[beat.id] = true
	local gifts: { Gift } = {}
	local rng = Rng.new(input.seed)
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
		elseif reward.kind == "Pen" then
			profile.Pens = math.min(profile.Pens + 1, ProfileConfig.MAX_PENS)
			table.insert(gifts, { kind = "Pen" })
		elseif reward.kind == "Badge" then
			profile.Story.flags[reward.id] = true
			profile.Story.badges += 1
			table.insert(gifts, { kind = "Badge", detail = reward.name })
		elseif reward.kind == "Starter" then
			local choice = input.choice :: string
			profile.Story.starter = choice
			local ref = giftRef(
				beat.id,
				index,
				choice,
				reward.level,
				"Common",
				StoryProgress.giftColour(choice)
			)
			giveCreature(profile, "Starter", ref, input, gifts, "Starter")
		elseif reward.kind == "Creature" then
			local ref =
				giftRef(beat.id, index, reward.species, reward.level, reward.rarity, reward.colour)
			giveCreature(profile, "Token", ref, input, gifts, "Creature")
		elseif reward.kind == "Egg" then
			-- The mentor's egg: two wild parents are made for the roll only and never kept. The
			-- child is decided now, like every egg, and waits in a pen.
			local level = 5
			local a = Breeding.wild(
				reward.parentA,
				"gift_a",
				level,
				"Common",
				StoryProgress.giftColour(reward.parentA),
				rng
			)
			local b = Breeding.wild(
				reward.parentB,
				"gift_b",
				level,
				"Common",
				StoryProgress.giftColour(reward.parentB),
				rng
			)
			local seed = Rng.int(rng, 1, 2147483646)
			local bred = Breeding.breed(
				a,
				b,
				Rng.new(seed),
				{ childId = input.newId(), now = input.unixTime }
			)
			table.insert(profile.Eggs, {
				child = bred.child,
				hatchAt = input.unixTime + BreedConfig.GIFT_EGG_SECONDS,
				seed = seed,
			})
			table.insert(gifts, { kind = "Egg", detail = bred.child.id })
		end
	end
	return { beat = beat, gifts = gifts, unlocks = beat.unlocks }, nil
end

return StoryProgress
