--!strict
-- Where everything in a biome is, as flat map positions (x, z in studs; the hub's centre is 0, 0),
-- generated from the biome's data. The server uses it to check that a player is really standing
-- where they say they are, and the test map is built from it. When the real map is built, its
-- markers replace these positions and nothing else changes.
--
-- Route A runs west from the hub and Route B east, each a chain of equal straight runs that bend
-- left and right, so a distance along the path (as the data gives it) has an exact position.

local WorldConfig = require("../config/WorldConfig")
local WorldTypes = require("./WorldTypes")

export type Point = { x: number, z: number }
export type RouteLine = { id: string, points: { Point }, length: number, side: number }
export type Map = {
	hub: { x: number, z: number, size: number },
	routes: { [string]: RouteLine },
	-- Every named place: buildings, characters, routes (their entry), areas (their middle),
	-- rustle spots, tamers, the lair, the gate and the sealed path.
	places: { [string]: Point },
	buildings: { [string]: Point }, -- each building's middle, for the map builder
	lairSpur: { Point },
}

local Layout = {}

function Layout.distance(a: Point, b: Point): number
	return math.sqrt((a.x - b.x) ^ 2 + (a.z - b.z) ^ 2)
end

-- The point `along` studs down a route's path, pushed `side` studs to its left (negative: right).
function Layout.pointAt(line: RouteLine, along: number, side: number?): Point
	local points = line.points
	local remaining = math.clamp(along, 0, line.length)
	for index = 1, #points - 1 do
		local a, b = points[index], points[index + 1]
		local length = Layout.distance(a, b)
		if remaining <= length or index == #points - 1 then
			local t = if length > 0 then math.min(remaining / length, 1) else 0
			local dx, dz =
				(b.x - a.x) / math.max(length, 1e-6), (b.z - a.z) / math.max(length, 1e-6)
			local offset = side or 0
			return {
				x = a.x + (b.x - a.x) * t - dz * offset,
				z = a.z + (b.z - a.z) * t + dx * offset,
			}
		end
		remaining -= length
	end
	return points[#points]
end

local function routeLine(
	route: WorldTypes.Route,
	start: Point,
	heading: number,
	side: number
): RouteLine
	local points: { Point } = { start }
	local step = WorldConfig.SEGMENT_LENGTH
	local bend = math.rad(WorldConfig.BEND_DEGREES)
	local covered = 0
	local index = 0
	while covered < route.length - 1e-6 do
		local length = math.min(step, route.length - covered)
		local angle = heading + (if index % 2 == 0 then bend else -bend)
		local last = points[#points]
		table.insert(
			points,
			{ x = last.x + math.cos(angle) * length, z = last.z + math.sin(angle) * length }
		)
		covered += length
		index += 1
	end
	return { id = route.id, points = points, length = route.length, side = side }
end

-- The place id of the long-grass patch in a stretch of route.
function Layout.grassId(areaId: string): string
	return `{areaId}_grass`
end

-- The place id of the supply stall on the way to a biome's lair.
function Layout.stallId(biome: WorldTypes.Biome): string
	return `{biome.lair.id}_stall`
end

-- Where a biome sits in the world: its hub's centre, and the directions its routes leave in.
export type Siting = { origin: Point, headings: { number } }

-- The first biome: the first route runs west, the second east, any more north and south.
local FIRST_SITING: Siting =
	{ origin = { x = 0, z = 0 }, headings = { math.pi, 0, math.pi / 2, -math.pi / 2 } }
-- Later biomes are entered from the west, so their first route runs north and their second
-- carries on east to the next gate.
local LATER_HEADINGS: { number } = { math.pi / 2, 0, -math.pi / 2 }

-- Builds the map for a biome. `tamers` are the local tamers by id (each names its route and
-- distance); ones on other biomes' routes are skipped. `siting` places the biome in the world
-- (the first biome's place when left out).
function Layout.build(
	biome: WorldTypes.Biome,
	tamers: { [string]: WorldTypes.Tamer },
	siting: Siting?
): Map
	local half = biome.hub.size / 2
	local sited = siting or FIRST_SITING
	local origin = sited.origin
	local map: Map = {
		hub = { x = origin.x, z = origin.z, size = biome.hub.size },
		routes = {},
		places = {},
		buildings = {},
		lairSpur = {},
	}

	-- Buildings stand in a ring inside the square. A building's place is its door, on the side
	-- facing the square, where its keeper stands; a named character's place is the same spot.
	local count = #biome.hub.buildings
	for index, building in biome.hub.buildings do
		local angle = (index - 1) / math.max(count, 1) * math.pi * 2 + math.pi / 2
		local ring = half * 0.6
		map.buildings[building.id] =
			{ x = origin.x + math.cos(angle) * ring, z = origin.z + math.sin(angle) * ring }
		local door: Point = {
			x = origin.x + math.cos(angle) * (ring - WorldConfig.DOOR_DISTANCE),
			z = origin.z + math.sin(angle) * (ring - WorldConfig.DOOR_DISTANCE),
		}
		map.places[building.id] = door
		if building.npc then
			map.places[building.npc] = door
		end
	end
	map.places[biome.hub.id] = { x = origin.x, z = origin.z }

	local headings = sited.headings
	for index, route in biome.routes do
		local heading = headings[(index - 1) % #headings + 1]
		local start: Point =
			{ x = origin.x + math.cos(heading) * half, z = origin.z + math.sin(heading) * half }
		local side = if index % 2 == 0 then 1 else -1
		local line = routeLine(route, start, heading, side)
		map.routes[route.id] = line
		map.places[route.id] =
			Layout.pointAt(line, math.min(WorldConfig.ROUTE_ENTRY_DEPTH, route.length))
		for _, area in route.areas do
			local middle = (area.from + area.to) / 2
			map.places[area.id] = Layout.pointAt(line, middle)
			-- The stretch's long grass lies to one side of the path (rustle spots are on the other).
			map.places[Layout.grassId(area.id)] =
				Layout.pointAt(line, middle, -WorldConfig.GRASS_SIDE_OFFSET * side)
		end
		for _, spot in route.rustleSpots do
			map.places[spot.id] =
				Layout.pointAt(line, spot.at, WorldConfig.RUSTLE_SIDE_OFFSET * side)
		end
	end

	for _, tamer in tamers do
		local line = map.routes[tamer.route]
		if line then
			map.places[tamer.id] =
				Layout.pointAt(line, tamer.at, -WorldConfig.TAMER_SIDE_OFFSET * line.side)
		end
	end

	local gateLine = map.routes[biome.gate.route]
	if gateLine then
		local gate = Layout.pointAt(gateLine, biome.gate.at)
		map.places[biome.gate.id] = gate
		-- The sealed road carries on past the gate in the route's last direction.
		local before = Layout.pointAt(gateLine, biome.gate.at - 10)
		map.places[biome.gate.sealedPath] = {
			x = gate.x + (gate.x - before.x) * 6,
			z = gate.z + (gate.z - before.z) * 6,
		}
	end

	-- The lair's spur leaves its route square to the path and ends at the arena.
	local lairLine = map.routes[biome.lair.joinsRoute]
	if lairLine then
		local join = Layout.pointAt(lairLine, biome.lair.joinsAt)
		local arena =
			Layout.pointAt(lairLine, biome.lair.joinsAt, biome.lair.spurLength * lairLine.side)
		map.lairSpur = { join, arena }
		map.places[biome.lair.id] = arena
		-- The supply stall stands a little way up the spur.
		map.places[Layout.stallId(biome)] =
			Layout.pointAt(lairLine, biome.lair.joinsAt, WorldConfig.STALL_DISTANCE * lairLine.side)
	end
	return map
end

-- Every biome laid out in one world, in order: each later biome's hub lies beyond the sealed
-- road of the one before it.
export type World = {
	map: Map, -- every biome's places, routes and buildings together (ids are unique across biomes)
	maps: { [number]: Map }, -- each biome's own map, by biome number
	biomeOfPlace: { [string]: number }, -- which biome a place belongs to
}

function Layout.world(biomes: { WorldTypes.Biome }, tamers: { [string]: WorldTypes.Tamer }): World
	local ordered = table.clone(biomes)
	table.sort(ordered, function(a, b)
		return a.number < b.number
	end)
	local merged: Map = {
		hub = { x = 0, z = 0, size = 0 },
		routes = {},
		places = {},
		buildings = {},
		lairSpur = {},
	}
	local maps: { [number]: Map } = {}
	local biomeOfPlace: { [string]: number } = {}
	local siting: Siting? = nil
	for index, biome in ordered do
		local map = Layout.build(biome, tamers, siting)
		maps[biome.number] = map
		if index == 1 then
			merged.hub, merged.lairSpur = map.hub, map.lairSpur
		end
		for id, line in map.routes do
			merged.routes[id] = line
		end
		for id, point in map.places do
			merged.places[id] = point
			biomeOfPlace[id] = biome.number
		end
		for id, point in map.buildings do
			merged.buildings[id] = point
		end
		-- The next biome's hub: straight on past this biome's sealed road.
		local gate, sealed = map.places[biome.gate.id], map.places[biome.gate.sealedPath]
		if gate and sealed then
			local length = math.max(Layout.distance(gate, sealed), 1e-6)
			local dx, dz = (sealed.x - gate.x) / length, (sealed.z - gate.z) / length
			local reach = WorldConfig.BIOME_GAP + WorldConfig.NEXT_HUB_ALLOWANCE
			siting = {
				origin = { x = sealed.x + dx * reach, z = sealed.z + dz * reach },
				headings = LATER_HEADINGS,
			}
		end
	end
	return { map = merged, maps = maps, biomeOfPlace = biomeOfPlace }
end

-- The biome a point is in: the one that owns the nearest named place. Nil with no places at all.
function Layout.biomeAt(world: World, at: Point): number?
	local best: number? = nil
	local bestDistance = math.huge
	for id, place in world.map.places do
		local distance = Layout.distance(place, at)
		if distance < bestDistance then
			best, bestDistance = world.biomeOfPlace[id], distance
		end
	end
	return best
end

-- True if `at` is within `radius` (plus the lag allowance) of the named place.
function Layout.isNear(map: Map, placeId: string, at: Point, radius: number): boolean
	local place = map.places[placeId]
	if place == nil or at.x ~= at.x or at.z ~= at.z then
		return false
	end
	return Layout.distance(place, at) <= radius + WorldConfig.POSITION_SLACK
end

return Layout
