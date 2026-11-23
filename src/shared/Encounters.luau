--!strict
-- One player's wild creatures in the world, as pure rules. Each player has their own: the server
-- keeps this book in memory, fills the stretches of route near the player, and checks every
-- request against it. Nothing here is saved; a creature only becomes the player's by a catch.
--
-- A creature that is beaten, caught or flees is gone, and its stretch refills after a wait.
-- One the player ran from or lost to stays where it was and keeps its missed-throw count, so
-- leaving a battle and coming back never resets how close it is to fleeing.

local BattleSession = require("./BattleSession")
local EconomyConfig = require("../config/EconomyConfig")
local Lasso = require("./Lasso")
local Layout = require("./Layout")
local Rng = require("./Rng")
local Types = require("./Types")
local World = require("./World")
local WorldConfig = require("../config/WorldConfig")
local WorldTypes = require("./WorldTypes")

export type Spawn = {
	id: number,
	biome: number, -- the biome it lives in (its rewards and its horn price follow this)
	route: string,
	area: string,
	spot: string?, -- the rustle spot it came from, if any
	creature: Types.Creature,
	at: Layout.Point,
	misses: number, -- missed lasso throws so far, across battles
	busy: boolean, -- in a battle now
	calmUntil: number, -- after a battle it stays, it cannot be engaged again before this time
}

export type Book = {
	nextId: number,
	spawns: { [number]: Spawn },
	rustledAt: { [string]: number }, -- spot id -> when it was last stirred
	freeAt: { [string]: number }, -- area id -> when it may refill
	grassAt: number, -- when long grass may next start a battle
}

local Encounters = {}

function Encounters.new(): Book
	return { nextId = 1, spawns = {}, rustledAt = {}, freeAt = {}, grassAt = 0 }
end

function Encounters.count(book: Book): number
	local total = 0
	for _ in book.spawns do
		total += 1
	end
	return total
end

local function add(
	book: Book,
	biome: number,
	route: WorldTypes.Route,
	area: string,
	spot: string?,
	at: Layout.Point,
	seed: number,
	newId: () -> string,
	rarity: Types.Rarity?
): Spawn
	local options: World.PickOptions = if spot
		then { spot = spot, rarity = rarity }
		else { area = area, rarity = rarity }
	local pick = World.pickWild(route, seed, options, newId())
	local spawn: Spawn = {
		id = book.nextId,
		biome = biome,
		route = route.id,
		area = area,
		spot = spot,
		creature = pick.creature,
		at = at,
		misses = 0,
		busy = false,
		calmUntil = 0,
	}
	book.spawns[spawn.id] = spawn
	book.nextId += 1
	return spawn
end

-- Where a roaming creature hides: inside its stretch's long grass, not too close to another one
-- hiding there (their triggers would overlap). A stretch with no patch falls back to the path.
-- `taken` is the points already used in this stretch.
function Encounters.hideAt(
	map: Layout.Map,
	line: Layout.RouteLine,
	area: WorldTypes.Area,
	taken: { Layout.Point },
	rng: Rng.Rng
): Layout.Point
	-- Two draws from the caller's stream, as the old open-ground placement took, so the creature
	-- picked after it is the same one as before; the tries use a stream of their own.
	local first, second = Rng.next(rng), Rng.next(rng)
	local own = Rng.new(1 + math.floor(first * 1000000) * 1000 + math.floor(second * 1000))
	local patch = map.places[Layout.grassId(area.id)]
	if patch == nil then
		local along = area.from + first * (area.to - area.from)
		return Layout.pointAt(line, along, (second * 2 - 1) * WorldConfig.SPAWN_SIDE_OFFSET)
	end
	local best: Layout.Point = patch
	local bestGap = -1.0
	for _ = 1, WorldConfig.GRASS_SPAWN_TRIES do
		local angle = Rng.next(own) * math.pi * 2
		local reach = math.sqrt(Rng.next(own)) * WorldConfig.GRASS_SPAWN_REACH
		local point =
			{ x = patch.x + math.cos(angle) * reach, z = patch.z + math.sin(angle) * reach }
		local gap = math.huge
		for _, other in taken do
			gap = math.min(gap, Layout.distance(point, other))
		end
		if gap >= WorldConfig.GRASS_SPAWN_GAP then
			return point
		end
		if gap > bestGap then
			best, bestGap = point, gap
		end
	end
	return best
end

-- Keeps the stretches near the player filled and clears the ones they have walked away from.
-- Returns true if the book changed (so the server knows to tell the device).
function Encounters.tick(
	book: Book,
	biome: WorldTypes.Biome,
	map: Layout.Map,
	player: Layout.Point,
	now: number,
	seed: number,
	newId: () -> string
): boolean
	local changed = false
	local rng = Rng.new(seed)
	local total = Encounters.count(book)
	for _, route in biome.routes do
		local line = map.routes[route.id]
		for _, area in route.areas do
			local centre = map.places[area.id]
			local active = line ~= nil
				and centre ~= nil
				and Layout.distance(centre, player) <= WorldConfig.ACTIVE_RANGE
			local roaming = 0
			local taken: { Layout.Point } = {}
			for id, spawn in book.spawns do
				if spawn.area == area.id then
					if not active and not spawn.busy then
						-- Walking away and back must not be a quick way to reroll a stretch for
						-- rare finds: a cleared stretch waits before it refills, like a beaten one.
						book.spawns[id] = nil
						book.freeAt[area.id] = now + WorldConfig.RESPAWN_SECONDS
						total -= 1
						changed = true
					elseif spawn.spot == nil then
						roaming += 1
						table.insert(taken, spawn.at)
					end
				end
			end
			if
				active
				and now >= (book.freeAt[area.id] or 0)
				and #World.candidates(route, { area = area.id }) > 0
			then
				while roaming < WorldConfig.SPAWNS_PER_AREA and total < WorldConfig.MAX_SPAWNS do
					local hidden = Encounters.hideAt(map, line, area, taken, rng)
					table.insert(taken, hidden)
					add(
						book,
						biome.number,
						route,
						area.id,
						nil,
						hidden,
						Rng.int(rng, 1, 2147483646),
						newId
					)
					roaming += 1
					total += 1
					changed = true
				end
			end
		end
	end
	return changed
end

-- Stirs a rustle spot: a creature from the spot's own table steps out. `spotId` comes from the
-- device; the player must be standing at the spot, and each spot rests between stirs.
function Encounters.rustle(
	book: Book,
	biome: WorldTypes.Biome,
	map: Layout.Map,
	spotId: unknown,
	player: Layout.Point,
	now: number,
	seed: number,
	newId: () -> string
): (Spawn?, string?)
	if typeof(spotId) ~= "string" then
		return nil, "Bad request"
	end
	for _, route in biome.routes do
		for _, spot in route.rustleSpots do
			if spot.id == spotId then
				if not Layout.isNear(map, spot.id, player, WorldConfig.RUSTLE_RADIUS) then
					return nil, "You are too far away"
				end
				local last = book.rustledAt[spot.id]
				if last ~= nil and now - last < WorldConfig.RUSTLE_COOLDOWN_SECONDS then
					return nil, "Nothing stirs yet"
				end
				if Encounters.count(book) >= WorldConfig.MAX_SPAWNS then
					return nil, "Nothing stirs yet"
				end
				book.rustledAt[spot.id] = now
				return add(
					book,
					biome.number,
					route,
					spot.area,
					spot.id,
					map.places[spot.id],
					seed,
					newId
				),
					nil
			end
		end
	end
	return nil, "There is nothing there"
end

-- Bait, used at a rustle spot from Tide Flats on: a creature from the spot's own table always
-- steps out, whatever the spot's rest, and it is gem-tier with the economy's bait chance.
-- `spotId` comes from the device; the caller has checked the player holds a bait and takes it
-- only if this returns a creature.
function Encounters.bait(
	book: Book,
	biome: WorldTypes.Biome,
	map: Layout.Map,
	spotId: unknown,
	player: Layout.Point,
	seed: number,
	newId: () -> string
): (Spawn?, string?)
	if typeof(spotId) ~= "string" then
		return nil, "Bad request"
	end
	if biome.number < EconomyConfig.BAIT_MIN_BIOME then
		return nil, "Bait only draws creatures out from Tide Flats on"
	end
	for _, route in biome.routes do
		for _, spot in route.rustleSpots do
			if spot.id == spotId then
				if not Layout.isNear(map, spot.id, player, WorldConfig.RUSTLE_RADIUS) then
					return nil, "You are too far away"
				end
				if Encounters.count(book) >= WorldConfig.MAX_SPAWNS then
					return nil, "Too many creatures are about: deal with some first"
				end
				local rng = Rng.new(seed)
				local rarity: Types.Rarity? = if Rng.chance(rng, EconomyConfig.BAIT_GEM_CHANCE)
					then "Gem"
					else nil
				return add(
					book,
					biome.number,
					route,
					spot.area,
					spot.id,
					map.places[spot.id],
					Rng.int(rng, 1, 2147483646),
					newId,
					rarity
				),
					nil
			end
		end
	end
	return nil, "There is nothing there"
end

-- Long grass: called about once a second with where the server sees the player and whether they
-- have been walking. If they are inside a stretch's grass, a creature from that stretch's table
-- may jump out. Returns it, already marked as in a battle, or nil. Nothing here comes from the
-- device, so the device cannot ask for a grass battle or avoid one.
function Encounters.grass(
	book: Book,
	biome: WorldTypes.Biome,
	map: Layout.Map,
	player: Layout.Point,
	walking: boolean,
	now: number,
	seed: number,
	newId: () -> string
): Spawn?
	if not walking or now < book.grassAt or Encounters.count(book) >= WorldConfig.MAX_SPAWNS then
		return nil
	end
	for _, route in biome.routes do
		for _, area in route.areas do
			local patch = map.places[Layout.grassId(area.id)]
			if patch and Layout.distance(patch, player) <= WorldConfig.GRASS_RADIUS then
				local rng = Rng.new(seed)
				if
					not Rng.chance(rng, WorldConfig.GRASS_CHANCE)
					or #World.candidates(route, { area = area.id }) == 0
				then
					return nil
				end
				book.grassAt = now + WorldConfig.GRASS_REST_SECONDS
				local spawn = add(
					book,
					biome.number,
					route,
					area.id,
					nil,
					{ x = player.x, z = player.z },
					Rng.int(rng, 1, 2147483646),
					newId
				)
				spawn.busy = true
				return spawn
			end
		end
	end
	return nil
end

-- Starts a battle with one of the player's wild creatures. `id` comes from the device; the
-- creature must exist in this player's book, be free, and be close to where the server sees
-- the player standing: a creature hiding in the grass must be walked right up to (the trigger
-- radius), one a rustle spot brought out is already at the player's feet.
function Encounters.engage(
	book: Book,
	id: unknown,
	player: Layout.Point,
	now: number?
): (Spawn?, string?)
	if typeof(id) ~= "number" then
		return nil, "Bad request"
	end
	local spawn = book.spawns[id]
	if spawn == nil then
		return nil, "That creature has gone"
	end
	if spawn.busy then
		return nil, "You are already battling it"
	end
	if now ~= nil and now < spawn.calmUntil then
		return nil, "It has slipped away for now"
	end
	if player.x ~= player.x or player.z ~= player.z then
		return nil, "You are too far away"
	end
	local reach = if spawn.spot ~= nil
		then WorldConfig.ENGAGE_RADIUS
		else WorldConfig.GRASS_TRIGGER_RADIUS
	if Layout.distance(spawn.at, player) > reach + WorldConfig.POSITION_SLACK then
		return nil, "You are too far away"
	end
	spawn.busy = true
	return spawn, nil
end

-- Takes a creature out of the world without any wait before its stretch refills (a grass
-- battle that could not start: the creature was never really there).
function Encounters.remove(book: Book, id: number)
	book.spawns[id] = nil
end

-- Ends a battle with a wild creature. `misses` is the creature's missed-throw count after it.
function Encounters.finish(
	book: Book,
	id: number,
	ending: BattleSession.Ending?,
	misses: number,
	now: number
)
	local spawn = book.spawns[id]
	if spawn == nil then
		return
	end
	-- A creature that has dodged its last allowed throw is gone however the battle ended (it may
	-- have ended as a loss on the same turn): it must not stay to be fought for rewards.
	local flee = Lasso.missesBeforeFlee(spawn.creature.rarity)
	local fled = flee ~= nil and math.max(spawn.misses, misses) >= flee
	-- So is one with no health left (a draw knocks out both sides): it cannot be fought again.
	local down = (spawn.creature.hurt or 0) >= 1
	if ending == "Won" or ending == "Caught" or ending == "Fled" or fled or down then
		book.spawns[id] = nil
		if spawn.spot == nil then
			book.freeAt[spawn.area] = now + WorldConfig.RESPAWN_SECONDS
		end
	else
		-- Ran, lost, a draw, or a battle dropped part way: it stays, and remembers its misses.
		spawn.busy = false
		spawn.misses = math.max(spawn.misses, misses)
		-- Leaving a fight must not drop the player straight back into it.
		spawn.calmUntil = now + WorldConfig.WILD_CALM_SECONDS
	end
end

return Encounters
