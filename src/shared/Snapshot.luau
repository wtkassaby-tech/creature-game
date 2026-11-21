--!strict
-- The player's saved state as the device sees it (the PlayerState message in src/net/Net.blink).
-- Display only. Numbers are clamped to the message's ranges so an odd saved value can never stop
-- the message being sent, and an egg's child stays secret until it hatches.

local Profile = require("./Profile")
local Types = require("./Types")

export type PartView = { Species: string, Quality: number }
export type CreatureView = {
	Id: string,
	BodyPlan: Types.BodyPlan,
	Head: PartView,
	Torso: PartView,
	FrontLimbs: PartView,
	Legs: PartView,
	Tail: PartView,
	Colour: string,
	CarriedColour: string,
	Size: number,
	Rarity: Types.Rarity,
	Level: number,
	Xp: number,
	Generation: number,
	BreedCount: number,
	BreedReadyAt: number,
	OriginBiome: number,
	IsGiant: boolean,
	Bound: boolean,
	Serial: number?,
}
export type CandyView = {
	Leaf: number,
	Sand: number,
	Water: number,
	Toxic: number,
	Frost: number,
	Crystal: number,
	Fire: number,
	Storm: number,
	Arcane: number,
	Cosmic: number,
	Prism: number,
}
export type State = {
	Coins: number,
	Gems: number,
	Candy: CandyView,
	Items: { [string]: number },
	Creatures: { CreatureView },
	Team: { string },
	Eggs: { { HatchAt: number } },
	Pens: number,
	StableCapacity: number,
	Badges: number,
	Starter: string,
	Flags: { string },
	QuestsActive: { [string]: number },
	QuestsDone: { string },
	Waiting: number,
}

local MAX_CREATURES = 400
local MAX_FLAGS = 200
local GRANT_FLAG_PREFIX = "grant:"

local Snapshot = {}

local function whole(value: number, high: number): number
	if value ~= value then
		return 0
	end
	return math.clamp(math.floor(value), 0, high)
end

local function part(p: Types.Part): PartView
	return { Species = p.species, Quality = whole(p.quality, 255) }
end

function Snapshot.creature(c: Types.Creature): CreatureView
	return {
		Id = c.id,
		BodyPlan = c.bodyPlan,
		Head = part(c.parts.Head),
		Torso = part(c.parts.Torso),
		FrontLimbs = part(c.parts.FrontLimbs),
		Legs = part(c.parts.Legs),
		Tail = part(c.parts.Tail),
		Colour = c.colour.shown,
		CarriedColour = c.colour.carried,
		Size = c.size,
		Rarity = c.rarity,
		Level = whole(c.level, 255),
		Xp = whole(c.xp, 4294967295),
		Generation = whole(c.generation, 65535),
		BreedCount = whole(c.breedCount, 65535),
		BreedReadyAt = c.breedReadyAt,
		OriginBiome = whole(c.originBiome, 255),
		IsGiant = c.isGiant,
		Bound = c.bound,
		Serial = if c.serial then whole(c.serial, 4294967295) else nil,
	}
end

function Snapshot.build(profile: Profile.Profile): State
	local creatures: { CreatureView } = {}
	for _, c in profile.Creatures do
		if #creatures >= MAX_CREATURES then
			break
		end
		table.insert(creatures, Snapshot.creature(c))
	end
	-- A stable order, so the screen does not reshuffle on every update.
	table.sort(creatures, function(a, b)
		return a.Id < b.Id
	end)

	local items: { [string]: number } = {}
	for key, count in profile.Items do
		if #key >= 1 and #key <= 24 and count > 0 then
			items[key] = whole(count, 65535)
		end
	end

	local flags: { string } = {}
	for flag, set in profile.Story.flags do
		if
			set
			and #flags < MAX_FLAGS
			and #flag <= 40
			and string.sub(flag, 1, #GRANT_FLAG_PREFIX) ~= GRANT_FLAG_PREFIX
		then
			table.insert(flags, flag)
		end
	end
	table.sort(flags)

	local questsActive: { [string]: number } = {}
	for id, progress in profile.Quests.active do
		if #id >= 1 and #id <= 40 then
			questsActive[id] = whole(progress, 65535)
		end
	end
	local questsDone: { string } = {}
	for id, done in profile.Quests.done do
		if done and #questsDone < MAX_FLAGS and #id >= 1 and #id <= 40 then
			table.insert(questsDone, id)
		end
	end
	table.sort(questsDone)

	local eggs: { { HatchAt: number } } = {}
	for index, egg in profile.Eggs do
		if index > 4 then
			break
		end
		table.insert(eggs, { HatchAt = egg.hatchAt })
	end

	local team: { string } = {}
	for index, id in profile.Team do
		if index > 6 then
			break
		end
		table.insert(team, id)
	end

	local typed = profile.Candy.typed
	return {
		Coins = whole(profile.Coins, 4294967295),
		Gems = whole(profile.Gems, 4294967295),
		Candy = {
			Leaf = typed.Leaf,
			Sand = typed.Sand,
			Water = typed.Water,
			Toxic = typed.Toxic,
			Frost = typed.Frost,
			Crystal = typed.Crystal,
			Fire = typed.Fire,
			Storm = typed.Storm,
			Arcane = typed.Arcane,
			Cosmic = typed.Cosmic,
			Prism = profile.Candy.prism,
		},
		Items = items,
		Creatures = creatures,
		Team = team,
		Eggs = eggs,
		Pens = whole(profile.Pens, 255),
		StableCapacity = whole(profile.StableCapacity, 65535),
		Badges = whole(profile.Story.badges, 255),
		Starter = profile.Story.starter or "",
		Flags = flags,
		QuestsActive = questsActive,
		QuestsDone = questsDone,
		Waiting = whole(#profile.Pending, 255),
	}
end

return Snapshot
