--!strict
-- Where everything in a biome is, as flat map positions (x, z in studs; the hub's centre is 0, 0),
-- from the biome's data and, where the biome has one, its map sheet. The server uses it to check
-- that a player is really standing where they say they are, and the test map is built from it.
--
-- A biome with a map sheet (WorldTypes.MapSheet) uses the designer's waypoints, buildings and
-- set spots; each route's waypoints are fitted to the route's length in the data, so a distance
-- along the path still has an exact position. A biome without one keeps the generated layout:
-- Route A runs west from the hub and Route B east, each a chain of equal straight runs that bend
-- left and right, and buildings stand in a ring.
--
-- Longer than ~400 lines on purpose: it is the one source of truth for every position the server
-- checks, and the sheet and generated layouts share their helpers (fit, pointAt, the gate and
-- the sealed road), so splitting it would give the server two places to read positions from.

local WorldConfig = require("../config/WorldConfig")
local Regions = require("./Regions")
local WorldTypes = require("./WorldTypes")

export type Point = { x: number, z: number }
export type RouteLine = {
	id: string,
	points: { Point },
	length: number,
	side: number,
	-- How far the route's edges stand from the middle of the lane, by area id. Only a biome with
	-- a map sheet has them.
	halfWidth: { [string]: number }?,
	-- The half-width at distances along the route, when the sheet gives them (narrow lanes).
	widths: { WorldTypes.WidthKey }?,
}
-- A patch of long grass: a circle on the flat map.
export type GrassCircle = { x: number, z: number, r: number }
export type Spawn = { at: Point, faces: number }
export type Map = {
	hub: { x: number, z: number, size: number },
	routes: { [string]: RouteLine },
	-- Every named place: buildings, characters, routes (their entry), areas (their middle),
	-- rustle spots, tamers, the lair, the gate and the sealed path.
	places: { [string]: Point },
	buildings: { [string]: Point }, -- each building's middle, for the map builder
	lairSpur: { Point }, -- the whole spur, from where it leaves its route to the arena
	lairHalfWidth: number?, -- how wide the spur's corridor is, from the map sheet
	lairWidths: { WorldTypes.WidthKey }?, -- the spur's half-width along it, when the sheet gives it
	-- Every patch of long grass by stretch id: the stretch's own place first, then the sheet's
	-- extra patches (the server checks all of them).
	grass: { [string]: { GrassCircle } },
	faces: { [string]: number }, -- degrees clockwise from north, by building, tamer or battle id
	stands: { [string]: Point }, -- where a story battle's opponent stands, by battle id
	models: { [string]: string }, -- the painted model a building wears, by building id
	spawn: Spawn?, -- where players arrive and which way they face
}

local Layout = {}

function Layout.distance(a: Point, b: Point): number
	return math.sqrt((a.x - b.x) ^ 2 + (a.z - b.z) ^ 2)
end

-- The flat direction a facing points in: degrees clockwise from north, where north is -z.
function Layout.facing(degrees: number): Point
	local angle = math.rad(degrees)
	return { x = math.sin(angle), z = -math.cos(angle) }
end

-- A copy of a line of points made exactly `length` long: cut inside the leg where the length runs
-- out, or with the last leg stretched if the points fall short.
function Layout.fit(points: { Point }, length: number): { Point }
	if #points < 2 then
		return table.clone(points)
	end
	local fitted: { Point } = { points[1] }
	local covered = 0
	for index = 1, #points - 1 do
		local a, b = points[index], points[index + 1]
		local leg = Layout.distance(a, b)
		local last = index == #points - 1
		if leg > 1e-9 and (covered + leg >= length or last) then
			local t = (length - covered) / leg
			table.insert(fitted, { x = a.x + (b.x - a.x) * t, z = a.z + (b.z - a.z) * t })
			return fitted
		end
		if leg > 1e-9 then
			table.insert(fitted, b)
			covered += leg
		end
	end
	return fitted
end

-- The half-width of a route's lane `along` studs down it: eased between the sheet's keys, else
-- the stretch's corridor width, else `fallback`.
function Layout.halfWidthAt(
	widths: { WorldTypes.WidthKey }?,
	along: number,
	fallback: number
): number
	if widths == nil or #widths == 0 then
		return fallback
	end
	local first, last = widths[1], widths[#widths]
	if along <= first.at then
		return first.half
	end
	if along >= last.at then
		return last.half
	end
	for index = 1, #widths - 1 do
		local a, b = widths[index], widths[index + 1]
		if along <= b.at then
			local span = b.at - a.at
			local t = if span > 1e-9 then (along - a.at) / span else 1
			return a.half + (b.half - a.half) * t
		end
	end
	return last.half
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

-- A sheet point moved from the hub's frame into the world.
local function shifted(origin: Point, point: WorldTypes.SheetPoint): Point
	return { x = origin.x + point.x, z = origin.z + point.z }
end

-- A route drawn on the map sheet: its waypoints in the world, fitted to the route's data length.
local function sheetLine(
	route: WorldTypes.Route,
	sheet: WorldTypes.MapSheet,
	origin: Point,
	side: number
): RouteLine?
	local drawn = sheet.routes[route.id]
	if drawn == nil or #drawn.points < 2 then
		return nil
	end
	local points: { Point } = {}
	for _, point in drawn.points do
		table.insert(points, shifted(origin, point))
	end
	local halfWidth: { [string]: number } = {}
	local corridor = sheet.corridor
	if corridor then
		for _, area in route.areas do
			local width = corridor[area.id]
			if width then
				halfWidth[area.id] = width
			end
		end
	end
	return {
		id = route.id,
		points = Layout.fit(points, route.length),
		length = route.length,
		side = side,
		halfWidth = halfWidth,
		widths = if sheet.widths then sheet.widths[route.id] else nil,
	}
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
	local sheet = biome.map
	local map: Map = {
		hub = { x = origin.x, z = origin.z, size = biome.hub.size },
		routes = {},
		places = {},
		buildings = {},
		lairSpur = {},
		faces = {},
		stands = {},
		models = {},
		grass = {},
	}

	-- A building's place is its door, where its keeper stands; a named character's place is the
	-- same spot. Without a sheet, buildings stand in a ring inside the square, doors to the middle.
	local count = #biome.hub.buildings
	for index, building in biome.hub.buildings do
		local drawn = if sheet then sheet.buildings[building.id] else nil
		local door: Point
		if drawn then
			local middle = shifted(origin, drawn.at)
			map.buildings[building.id] = middle
			if drawn.door then
				door = shifted(origin, drawn.door)
			else
				local ahead = Layout.facing(drawn.faces)
				door = {
					x = middle.x + ahead.x * WorldConfig.DOOR_DISTANCE,
					z = middle.z + ahead.z * WorldConfig.DOOR_DISTANCE,
				}
			end
			map.faces[building.id] = drawn.faces
			if building.npc then
				map.faces[building.npc] = drawn.faces
			end
			if drawn.model then
				map.models[building.id] = drawn.model
			end
		else
			local angle = (index - 1) / math.max(count, 1) * math.pi * 2 + math.pi / 2
			local ring = half * 0.6
			map.buildings[building.id] =
				{ x = origin.x + math.cos(angle) * ring, z = origin.z + math.sin(angle) * ring }
			door = {
				x = origin.x + math.cos(angle) * (ring - WorldConfig.DOOR_DISTANCE),
				z = origin.z + math.sin(angle) * (ring - WorldConfig.DOOR_DISTANCE),
			}
		end
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
		local line = (if sheet then sheetLine(route, sheet, origin, side) else nil)
			or routeLine(route, start, heading, side)
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

	-- The lair's spur leaves its route and ends at the arena: square to the path, or along the
	-- sheet's waypoints fitted to the spur's length in the data.
	local lairLine = map.routes[biome.lair.joinsRoute]
	local drawnSpur = if sheet and sheet.spurs then sheet.spurs[biome.lair.id] else nil
	if lairLine and drawnSpur and #drawnSpur > 0 then
		local join = Layout.pointAt(lairLine, biome.lair.joinsAt)
		local points: { Point } = { join }
		for _, point in drawnSpur do
			local placed = shifted(origin, point)
			-- The sheet usually starts at the join itself; a leg of no length helps nobody.
			if Layout.distance(placed, points[#points]) > 1 then
				table.insert(points, placed)
			end
		end
		local spur = Layout.fit(points, biome.lair.spurLength)
		map.lairSpur = spur
		map.places[biome.lair.id] = spur[#spur]
		local spurLine: RouteLine =
			{ id = biome.lair.id, points = spur, length = biome.lair.spurLength, side = 0 }
		map.places[Layout.stallId(biome)] = Layout.pointAt(spurLine, WorldConfig.STALL_DISTANCE)
		map.lairHalfWidth = if sheet and sheet.corridor then sheet.corridor[biome.lair.id] else nil
		map.lairWidths = if sheet and sheet.widths then sheet.widths[biome.lair.id] else nil
	elseif lairLine then
		local join = Layout.pointAt(lairLine, biome.lair.joinsAt)
		local arena =
			Layout.pointAt(lairLine, biome.lair.joinsAt, biome.lair.spurLength * lairLine.side)
		map.lairSpur = { join, arena }
		map.places[biome.lair.id] = arena
		-- The supply stall stands a little way up the spur.
		map.places[Layout.stallId(biome)] =
			Layout.pointAt(lairLine, biome.lair.joinsAt, WorldConfig.STALL_DISTANCE * lairLine.side)
	end

	-- Last of all, the sheet's set spots. Only ids the layout already knows are moved; an unknown
	-- id is left out here and caught by tests/layout.test.
	if sheet then
		for id, point in sheet.places do
			if map.places[id] then
				map.places[id] = shifted(origin, point)
			end
		end
		local stands: { [string]: WorldTypes.SheetPoint } = sheet.stands or {}
		for id, point in stands do
			map.stands[id] = shifted(origin, point)
		end
		local faces: { [string]: number } = sheet.faces or {}
		for id, degrees in faces do
			map.faces[id] = degrees
		end
		local spawn = sheet.spawn
		if spawn then
			map.spawn = { at = shifted(origin, spawn.at), faces = spawn.faces }
		end
	end
	-- Every stretch's patches of long grass: its own place first, then the sheet's extras.
	for _, route in biome.routes do
		for _, area in route.areas do
			local own = map.places[Layout.grassId(area.id)]
			if own then
				local list: { GrassCircle } =
					{ { x = own.x, z = own.z, r = WorldConfig.GRASS_RADIUS } }
				local more = if sheet and sheet.grass then sheet.grass[area.id] else nil
				if more then
					for _, patch in more do
						local at = shifted(origin, patch.at)
						table.insert(list, { x = at.x, z = at.z, r = patch.r })
					end
				end
				map.grass[area.id] = list
			end
		end
	end
	return map
end

-- Every biome laid out in one world, in order: each later biome's hub lies beyond the sealed
-- road of the one before it.
export type World = {
	map: Map, -- every biome's places, routes and buildings together (ids are unique across biomes)
	maps: { [number]: Map }, -- each biome's own map, by biome number
	biomeOfPlace: { [string]: number }, -- which biome a place belongs to
	regions: { { biome: number, shape: WorldTypes.Shape } }, -- each biome's region, when it has one
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
		faces = {},
		stands = {},
		models = {},
		grass = {},
	}
	local maps: { [number]: Map } = {}
	local biomeOfPlace: { [string]: number } = {}
	local siting: Siting? = nil
	local regions: { { biome: number, shape: WorldTypes.Shape } } = {}
	for index, biome in ordered do
		-- A biome with its own `site` stands there; otherwise it goes straight on (docs/plans/13 11b).
		local site = biome.site
		if site then
			siting = { origin = { x = site.hub.x, z = site.hub.z }, headings = LATER_HEADINGS }
		end
		local map = Layout.build(biome, tamers, siting)
		if biome.region then
			table.insert(regions, { biome = biome.number, shape = biome.region })
		end
		maps[biome.number] = map
		if index == 1 then
			merged.hub, merged.lairSpur = map.hub, map.lairSpur
			merged.lairHalfWidth, merged.spawn = map.lairHalfWidth, map.spawn
			merged.lairWidths = map.lairWidths
		end
		for id, degrees in map.faces do
			merged.faces[id] = degrees
		end
		for id, point in map.stands do
			merged.stands[id] = point
		end
		for id, model in map.models do
			merged.models[id] = model
		end
		for id, list in map.grass do
			merged.grass[id] = list
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
	return { map = merged, maps = maps, biomeOfPlace = biomeOfPlace, regions = regions }
end

-- The biome a point is in: the one whose region holds it (the lowest number where two meet), else
-- the one that owns the nearest named place. Nil with no places at all.
function Layout.biomeAt(world: World, at: Point): number?
	for _, entry in world.regions do
		if Regions.contains(entry.shape, at) then
			return entry.biome
		end
	end
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
