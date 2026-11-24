--!strict
-- The tracker's words for the next story beat, worked out from the beat's own trigger and the
-- names in the world's data, so every hint names who to beat, who to talk to or where to walk
-- ("Beat Pip Alder on Clover Lane", "Walk into Clover Meadow", "Talk to Marlow Tuppence at
-- Tuppence's Shop"). A beat may carry its own `hint` when the derived one reads badly. Pure: no
-- Roblox services.

local Biomes = require("../content/Biomes")
local DustCanyon = require("../content/biome_data/DustCanyon")
local Greenwood = require("../content/biome_data/Greenwood")
local Mire = require("../content/biome_data/Mire")
local TideFlats = require("../content/biome_data/TideFlats")
local ReleaseConfig = require("../config/ReleaseConfig")
local StoryStand = require("./StoryStand")
local Tamers = require("../content/Tamers")
local WorldTypes = require("./WorldTypes")

local BeatHint = {}

type PlaceKind = "Hub" | "Route" | "Area" | "Gate" | "Sealed" | "Lair"
type Place = { name: string, kind: PlaceKind }

-- "Route A: Clover Lane" -> "Clover Lane"
local function shortRoute(name: string): string
	local short = string.match(name, "^Route %w+: (.+)$")
	return short or name
end

-- A stretch is named with its road, because a player looking at the map and the signs finds "the
-- Mesa Road's Sunbaked Rim", not "Sunbaked Rim" alone. A stretch that already starts with its
-- road's first word ("Clover Meadow" on Clover Lane) is left as it is.
local function areaName(routeName: string, name: string): string
	local route = shortRoute(routeName)
	local first = string.match(route, "^(%S+)")
	if first and string.sub(name, 1, #first) == first then
		return name
	end
	-- "the Mesa Road's ...", but "Clover Lane's ...".
	local article = if string.match(route, "Lane$") then "" else "the "
	return `{article}{route}'s {name}`
end

local function places(): { [string]: Place }
	local found: { [string]: Place } = {}
	for _, biome in Biomes do
		found[biome.hub.id] = { name = biome.hub.name, kind = "Hub" }
		for _, route in biome.routes do
			found[route.id] = { name = shortRoute(route.name), kind = "Route" }
			for _, area in route.areas do
				found[area.id] = { name = areaName(route.name, area.name), kind = "Area" }
			end
		end
		found[biome.lair.id] = { name = biome.lair.name, kind = "Lair" }
		found[biome.gate.id] = { name = biome.gate.name, kind = "Gate" }
		-- "The Stair Gate" -> "the road beyond the Stair Gate".
		local gateName = string.gsub(biome.gate.name, "^The ", "the ")
		found[biome.gate.sealedPath] = {
			name = `the road beyond {gateName}`,
			kind = "Sealed",
		}
	end
	return found
end

-- The places never change while the game runs: worked out once, on first use.
local knownPlaces: { [string]: Place }? = nil
local function placesOnce(): { [string]: Place }
	local cached = knownPlaces
	if cached then
		return cached
	end
	local found = places()
	knownPlaces = found
	return found
end

-- Where a building stands, by the character who keeps it: "marlow_tuppence" -> Tuppence's Shop.
local function buildingOf(npc: string): string?
	for _, biome in Biomes do
		for _, building in biome.hub.buildings do
			if building.npc == npc then
				return building.name
			end
		end
	end
	return nil
end

-- "marlow_tuppence" -> "Marlow Tuppence"; a bare role such as "mentor" -> "your mentor".
local function personName(id: string): string
	if not string.find(id, "_", 1, true) then
		return `your {id}`
	end
	local words: { string } = {}
	for word in string.gmatch(id, "[^_]+") do
		table.insert(words, string.upper(string.sub(word, 1, 1)) .. string.sub(word, 2))
	end
	return table.concat(words, " ")
end

local function routeOfTamer(tamerId: string): string?
	for _, biome in Biomes do
		for _, route in biome.routes do
			if table.find(route.tamers, tamerId) then
				return shortRoute(route.name)
			end
		end
	end
	return nil
end

local function placeName(id: string, known: { [string]: Place }): string?
	local place = known[id]
	if place then
		return place.name
	end
	local building = buildingOf(id)
	if building then
		return building
	end
	return nil
end

-- The hint for a beat, and the name of its target when the words were derived from one (nil for a
-- beat with no target, or one that wrote its own hint).
function BeatHint.resolve(beat: WorldTypes.Beat): (string, string?)
	local trigger = beat.trigger
	local target = trigger.target
	local known = placesOnce()
	if beat.hint and beat.hint ~= "" then
		return beat.hint, nil
	end
	if trigger.kind == "Win" and target then
		local tamer = Tamers.locals[target]
		if tamer then
			local route = routeOfTamer(tamer.id)
			return if route then `Beat {tamer.name} on {route}` else `Beat {tamer.name}`, tamer.name
		end
		local battle = Tamers.story[target]
		if battle then
			local where = placeName(battle.place, known)
			local who = if StoryStand.isRival(battle) then "your rival" else battle.name
			-- "in Thistledown", "on the Mesa Road's Sunbaked Rim", but "at The Greenwood Gatehouse".
			local place = known[battle.place]
			local word = if place and place.kind == "Hub"
				then "in"
				elseif place and place.kind == "Area" then "on"
				else "at"
			local words = if where then `Beat {who} {word} {where}` else `Beat {who}`
			return words, who
		end
	elseif (trigger.kind == "Enter" or trigger.kind == "Sight") and target then
		local place = known[target]
		if place then
			if place.kind == "Route" then
				return `Walk out onto {place.name}`, place.name
			elseif place.kind == "Gate" then
				return `Walk up to {place.name}`, place.name
			elseif place.kind == "Sealed" then
				return `Walk onto {place.name}`, place.name
			end
			return `Walk into {place.name}`, place.name
		end
	elseif trigger.kind == "Talk" and target then
		local who = personName(target)
		local at = buildingOf(target)
		return if at then `Talk to {who} at {at}` else `Talk to {who}`, who
	elseif trigger.kind == "Tame" then
		return "Tame a creature with your lasso", nil
	end
	return beat.name, nil
end

-- What the tracker says when the open story has run out, so it never goes blank: the next
-- biome by name while one is written but not yet open, else a plain "more soon".
local LATER_BIOMES: { WorldTypes.Biome } = { Greenwood, DustCanyon, TideFlats, Mire }

function BeatHint.closing(): string
	local following = LATER_BIOMES[ReleaseConfig.OPEN_BIOMES + 1]
	if not following then
		return "That is all the story for now. More soon."
	end
	local name = if string.match(following.name, "^The ")
		then following.name
		else `The {following.name}`
	return `{name} is not open yet. More soon.`
end

function BeatHint.text(beat: WorldTypes.Beat): string
	local text = BeatHint.resolve(beat)
	return text
end

return BeatHint
