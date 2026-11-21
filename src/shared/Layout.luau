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

-- Builds the map for a biome. `tamers` are the local tamers by id (each names its route and
-- distance); ones on other biomes' routes are skipped.
function Layout.build(biome: WorldTypes.Biome, tamers: { [string]: WorldTypes.Tamer }): Map
	local half = biome.hub.size / 2
	local map: Map = {
		hub = { x = 0, z = 0, size = biome.hub.size },
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
		map.buildings[building.id] = { x = math.cos(angle) * ring, z = math.sin(angle) * ring }
		local door: Point = {
			x = math.cos(angle) * (ring - WorldConfig.DOOR_DISTANCE),
			z = math.sin(angle) * (ring - WorldConfig.DOOR_DISTANCE),
		}
		map.places[building.id] = door
		if building.npc then
			map.places[building.npc] = door
		end
	end
	map.places[biome.hub.id] = { x = 0, z = 0 }

	-- The first route runs west, the second east, any more alternate north and south.
	local headings: { number } = { math.pi, 0, math.pi / 2, -math.pi / 2 }
	for index, route in biome.routes do
		local heading = headings[(index - 1) % #headings + 1]
		local start: Point = { x = math.cos(heading) * half, z = math.sin(heading) * half }
		local side = if index % 2 == 0 then 1 else -1
		local line = routeLine(route, start, heading, side)
		map.routes[route.id] = line
		map.places[route.id] =
			Layout.pointAt(line, math.min(WorldConfig.ROUTE_ENTRY_DEPTH, route.length))
		for _, area in route.areas do
			map.places[area.id] = Layout.pointAt(line, (area.from + area.to) / 2)
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
	end
	return map
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
