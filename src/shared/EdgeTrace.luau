--!strict
-- Where the edges of a designed biome (hedges, cliffs, boulder banks...) are traced, as pure
-- numbers: down both sides of every corridor at the map sheet's half-widths, and round every room.
-- Each sample says whether an edge stands there. The server's builder (World/Corridors.luau) joins
-- the kept samples into runs and builds them; tests/layout.test.luau reads the same samples to
-- check that no edge stands on a tamer, a person or a prompt. No Roblox services.

local Ground = require("./Ground")
local Layout = require("./Layout")
local Walk = require("./Walk")
local WorldConfig = require("../config/WorldConfig")
local WorldTypes = require("./WorldTypes")

local EdgeTrace = {}

-- One corridor: a lane's centre line and how wide its corridor is at a distance along it.
export type Corridor = {
	id: string,
	line: Layout.RouteLine,
	points: { Layout.Point },
	widthAt: (along: number) -> number,
	areaAt: (along: number) -> string?,
}
export type Disc = { x: number, z: number, radius: number }
export type Trace = {
	map: Layout.Map,
	ground: Ground.Ground,
	space: Walk.Space,
	corridors: { Corridor },
	rings: { Disc }, -- clearings with an edge of their own
	bulges: { Disc }, -- clearings the corridor edges go round
	spots: { Layout.Point }, -- every tamer, person and prompt an edge must stay clear of
}
-- A point on a corridor's side: the outward normal there, and whether an edge stands.
export type Sample = {
	along: number,
	x: number,
	z: number,
	nx: number,
	nz: number,
	keep: boolean,
}
export type RoomSample = { x: number, z: number, keep: boolean }

local EDGE_STEP = 3 -- studs between the points an edge is traced through
local INSIDE_MARGIN = 1.5 -- an edge point this far inside another corridor gives way
EdgeTrace.STEP = EDGE_STEP
EdgeTrace.INSIDE_MARGIN = INSIDE_MARGIN

-- Distance along a line of points to the nearest spot on it, and how far off it that spot is.
function EdgeTrace.nearest(points: { Layout.Point }, x: number, z: number): (number, number)
	local bestAlong, bestOff = 0, math.huge
	if #points > 0 then
		local first = points[1]
		bestOff = math.sqrt((first.x - x) ^ 2 + (first.z - z) ^ 2)
	end
	local covered = 0
	for index = 1, #points - 1 do
		local a, b = points[index], points[index + 1]
		local lx, lz = b.x - a.x, b.z - a.z
		local length = math.sqrt(lx * lx + lz * lz)
		if length > 1e-6 then
			local ux, uz = lx / length, lz / length
			local t = math.clamp((x - a.x) * ux + (z - a.z) * uz, 0, length)
			local off = math.sqrt((a.x + ux * t - x) ^ 2 + (a.z + uz * t - z) ^ 2)
			if off < bestOff then
				bestAlong, bestOff = covered + t, off
			end
		end
		covered += length
	end
	return bestAlong, bestOff
end

-- Every corridor of a biome with a map sheet: its routes, and its lair spur.
local function corridorsOf(biome: WorldTypes.Biome, map: Layout.Map): { Corridor }
	local list: { Corridor } = {}
	for _, route in biome.routes do
		local line = map.routes[route.id]
		local widths = line and line.halfWidth
		if line and widths then
			local function areaAt(along: number): string?
				for _, area in route.areas do
					if along >= area.from and along <= area.to then
						return area.id
					end
				end
				return nil
			end
			table.insert(list, {
				id = route.id,
				line = line,
				points = line.points,
				widthAt = function(along: number): number
					local area = areaAt(along)
					return Layout.halfWidthAt(
						line.widths,
						along,
						(if area then widths[area] else nil) or 50
					)
				end,
				areaAt = areaAt,
			})
		end
	end
	local spurWidth = map.lairHalfWidth
	if spurWidth and #map.lairSpur >= 2 then
		local length = 0
		for index = 1, #map.lairSpur - 1 do
			length += Layout.distance(map.lairSpur[index], map.lairSpur[index + 1])
		end
		table.insert(list, {
			id = biome.lair.id,
			line = { id = biome.lair.id, points = map.lairSpur, length = length, side = 0 },
			points = map.lairSpur,
			widthAt = function(along: number): number
				return Layout.halfWidthAt(map.lairWidths, along, spurWidth)
			end,
			areaAt = function(): string?
				return nil
			end,
		})
	end
	return list
end

-- Every place a player or a story character stands or presses a prompt: the hub's buildings,
-- every tamer and rustle spot, the stall, the story stands, and the sheet's villagers.
local function spotsOf(
	biome: WorldTypes.Biome,
	map: Layout.Map,
	dressing: WorldTypes.DressingSheet
): { Layout.Point }
	local spots: { Layout.Point } = {}
	local function add(point: Layout.Point?)
		if point then
			table.insert(spots, point)
		end
	end
	for _, building in biome.hub.buildings do
		add(map.places[building.id])
	end
	for _, route in biome.routes do
		for _, tamerId in route.tamers do
			add(map.places[tamerId])
		end
		for _, spot in route.rustleSpots do
			add(map.places[spot.id])
		end
	end
	add(map.places[Layout.stallId(biome)])
	for _, point in map.stands do
		add(point)
	end
	for _, person in dressing.people do
		add({ x = map.hub.x + person.at.x, z = map.hub.z + person.at.z })
	end
	return spots
end

function EdgeTrace.new(
	biome: WorldTypes.Biome,
	map: Layout.Map,
	dressing: WorldTypes.DressingSheet,
	ground: Ground.Ground
): Trace
	local rings: { Disc } = {}
	local bulges: { Disc } = {}
	for _, clearing in dressing.clearings do
		local disc: Disc = {
			x = map.hub.x + clearing.at.x,
			z = map.hub.z + clearing.at.z,
			radius = clearing.radius,
		}
		table.insert(if clearing.ring then rings else bulges, disc)
	end
	return {
		map = map,
		ground = ground,
		space = Walk.space(biome, map, dressing),
		corridors = corridorsOf(biome, map),
		rings = rings,
		bulges = bulges,
		spots = spotsOf(biome, map, dressing),
	}
end

-- True when a point is well inside any corridor (`margin` studs or more within its edge).
function EdgeTrace.insideAny(trace: Trace, x: number, z: number, margin: number): boolean
	for _, corridor in trace.corridors do
		local along, off = EdgeTrace.nearest(corridor.points, x, z)
		if off < corridor.widthAt(along) - margin then
			return true
		end
	end
	return false
end

function EdgeTrace.inTown(map: Layout.Map, x: number, z: number, pad: number): boolean
	local half = map.hub.size / 2 + pad
	return math.abs(x - map.hub.x) < half and math.abs(z - map.hub.z) < half
end

function EdgeTrace.inRing(trace: Trace, x: number, z: number, pad: number): boolean
	for _, ring in trace.rings do
		if math.sqrt((x - ring.x) ^ 2 + (z - ring.z) ^ 2) < ring.radius + pad then
			return true
		end
	end
	return false
end

-- True where a tamer, a person or a prompt stands within WorldConfig.EDGE_CLEAR_STUDS.
function EdgeTrace.nearSpot(trace: Trace, x: number, z: number): boolean
	for _, spot in trace.spots do
		if math.sqrt((x - spot.x) ^ 2 + (z - spot.z) ^ 2) < WorldConfig.EDGE_CLEAR_STUDS then
			return true
		end
	end
	return false
end

-- True where a hedge must not stand: stairs and ramps are open at their ends (their sides have
-- cheeks), a ledge is open on purpose, and a tier's wall at its foot is wall enough.
function EdgeTrace.openByDesign(trace: Trace, x: number, z: number): boolean
	local ground = trace.ground
	return Ground.linkAt(ground, x, z, 3) ~= nil
		or Ground.ledgeAt(ground, x, z, 1.5) ~= nil
		or Ground.atFoot(ground, x, z, 3)
end

-- The direction of a line at a distance along it, smoothed over a few studs so edges round the
-- bends instead of jumping.
function EdgeTrace.heading(line: Layout.RouteLine, along: number): (number, number)
	local a = Layout.pointAt(line, math.max(along - 4, 0))
	local b = Layout.pointAt(line, math.min(along + 4, line.length))
	local dx, dz = b.x - a.x, b.z - a.z
	local length = math.sqrt(dx * dx + dz * dz)
	if length > 1e-3 then
		return dx / length, dz / length
	end
	return 1, 0
end

-- The samples down one side (-1 left, 1 right, walking away from town) of a corridor, every
-- EDGE_STEP studs from its start to its end.
function EdgeTrace.side(trace: Trace, corridor: Corridor, side: number): { Sample }
	local out: { Sample } = {}
	local map = trace.map
	local along = 0
	while true do
		local centre = Layout.pointAt(corridor.line, along)
		local rx, rz = EdgeTrace.heading(corridor.line, along)
		local nx, nz = -rz * side, rx * side
		local width = corridor.widthAt(along)
		local x, z = centre.x + nx * width, centre.z + nz * width
		for _, bulge in trace.bulges do
			local ox, oz = x - bulge.x, z - bulge.z
			local length = math.sqrt(ox * ox + oz * oz)
			if length < bulge.radius + 2 and length > 1e-3 then
				x = bulge.x + ox / length * (bulge.radius + 2)
				z = bulge.z + oz / length * (bulge.radius + 2)
			end
		end
		local keep = not EdgeTrace.inTown(map, x, z, 2)
			and Walk.depth(trace.space, x, z, false, nil) < INSIDE_MARGIN
			and not EdgeTrace.inRing(trace, x, z, 1)
			and not EdgeTrace.openByDesign(trace, x, z)
			and not EdgeTrace.nearSpot(trace, x, z)
		table.insert(out, { along = along, x = x, z = z, nx = nx, nz = nz, keep = keep })
		if along >= corridor.line.length then
			break
		end
		along = math.min(along + EDGE_STEP, corridor.line.length)
	end
	return out
end

-- The samples round one room of the map sheet, open where a lane or another room is, at a link
-- or a ledge, and at a tier's foot.
function EdgeTrace.room(trace: Trace, room: Ground.Shape): { RoomSample }
	local out: { RoomSample } = {}
	for _, sample in Ground.outline(room, EDGE_STEP) do
		local keep = not EdgeTrace.inTown(trace.map, sample.x, sample.z, 2)
			and Walk.depth(trace.space, sample.x, sample.z, false, room) < INSIDE_MARGIN
			and not EdgeTrace.inRing(trace, sample.x, sample.z, 1)
			and not EdgeTrace.openByDesign(trace, sample.x, sample.z)
			and not EdgeTrace.nearSpot(trace, sample.x, sample.z)
		table.insert(out, { x = sample.x, z = sample.z, keep = keep })
	end
	return out
end

return EdgeTrace
