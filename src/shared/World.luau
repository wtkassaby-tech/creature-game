--!strict
-- Pure helpers over the world's data: pick a wild creature for a route, list the quests a player
-- can take, and find the next story beat. No Roblox calls; randomness comes from a seed.

local BreedConfig = require("../config/BreedConfig")
local Breeding = require("./Breeding")
local Rng = require("./Rng")
local Species = require("../content/Species")
local Types = require("./Types")
local WorldTypes = require("./WorldTypes")

-- `area` limits the draw to one stretch of the route; `spot` draws from a rustle spot instead of
-- the open table. With neither, the whole open table of the route is used.
export type PickOptions = { area: string?, spot: string? }
export type WildPick = {
	creature: Types.Creature,
	entry: WorldTypes.SpawnEntry,
	rareColour: boolean,
}
export type Flags = { [string]: boolean }

local World = {}

local REWARD_KINDS: { WorldTypes.RewardKind } = {
	"Coins",
	"Candy",
	"Item",
	"Material",
	"Creature",
	"Egg",
	"Pen",
	"Starter",
	"Badge",
}
World.REWARD_KINDS = REWARD_KINDS

-- The rows a draw can use: a rustle spot's rows when `spot` is set, otherwise the open rows
-- (those with no spot), narrowed to `area` when given.
function World.candidates(route: WorldTypes.Route, options: PickOptions?): { WorldTypes.SpawnEntry }
	local area = if options then options.area else nil
	local spot = if options then options.spot else nil
	local rows: { WorldTypes.SpawnEntry } = {}
	for _, entry in route.spawns do
		local include: boolean
		if spot ~= nil then
			include = entry.spot == spot
		else
			include = entry.spot == nil and (area == nil or entry.area == area)
		end
		if include then
			table.insert(rows, entry)
		end
	end
	return rows
end

-- Choose a wild creature: a row by weight, a level in its range, a colour (a rare one with the
-- row's small chance), then build it with Breeding.wild. The same seed gives the same creature.
function World.pickWild(
	route: WorldTypes.Route,
	seed: number,
	options: PickOptions?,
	id: string?
): WildPick
	local rows = World.candidates(route, options)
	assert(#rows > 0, `no spawn rows on {route.id} for these options`)
	local rng = Rng.new(seed)
	local total = 0
	for _, entry in rows do
		total += entry.weight
	end
	local roll = Rng.next(rng) * total
	local chosen = rows[#rows]
	for _, entry in rows do
		if roll < entry.weight then
			chosen = entry
			break
		end
		roll -= entry.weight
	end
	local level = Rng.int(rng, chosen.minLevel, chosen.maxLevel)
	local rare = Rng.chance(rng, chosen.rareColourChance)
	local colour: string
	if rare then
		colour = Rng.pick(rng, BreedConfig.MUTATION_COLOURS)
	else
		colour = Rng.pick(rng, chosen.colours)
	end
	local creature = Breeding.wild(
		chosen.species,
		id or `wild_{seed}`,
		level,
		Species[chosen.species].baseRarity,
		colour,
		rng
	)
	return { creature = creature, entry = chosen, rareColour = rare }
end

-- The quests a player can take now: not done, every required quest done, every required story flag set.
function World.availableQuests(
	quests: { WorldTypes.Quest },
	done: { [string]: boolean },
	flags: Flags
): { WorldTypes.Quest }
	local list: { WorldTypes.Quest } = {}
	for _, quest in quests do
		local open = not done[quest.id]
		for _, id in quest.requires do
			if not done[id] then
				open = false
			end
		end
		for _, flag in quest.requiresFlags do
			if not flags[flag] then
				open = false
			end
		end
		if open then
			table.insert(list, quest)
		end
	end
	return list
end

-- The first unfinished beat, in order, whose trigger flags are all set; nil when none is ready.
function World.nextBeat(chapter: WorldTypes.Chapter, flags: Flags): WorldTypes.Beat?
	for _, beat in chapter.beats do
		if not flags[beat.id] then
			local ready = true
			for _, flag in beat.trigger.requires do
				if not flags[flag] then
					ready = false
				end
			end
			if ready then
				return beat
			end
		end
	end
	return nil
end

return World
