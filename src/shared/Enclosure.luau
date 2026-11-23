--!strict
-- Pure planning for the first step of docs/plans/12_MAP_STRUCTURE.md (section 10): close the map
-- in. Given a biome's sheets it works out the walkable space (corridors, town, clearings, places,
-- lanes), then
--   * where solid fill goes beyond the edges, so nothing past a route is open field, and
--   * where water must block the way, so a stream, pool, pond or sea cannot be waded across.
-- Everything here is flat (x, z in world studs) and has no Roblox service calls: the builders in
-- src/server/World (Fill, Barriers) turn the plans into parts, and tests/enclosure.test checks that
-- no place can be cut off. The server's own checks do not read any of it.
--
-- Over 400 lines on purpose: the walkable set, the fill and the water plan share one distance
-- test and one spatial index, and the plan's tests read them together.

local Layout = require("./Layout")
local Rng = require("./Rng")
local WorldConfig = require("../config/WorldConfig")
local WorldTypes = require("./WorldTypes")

-- A capsule (a segment `a` to `b` widened by `r`; a disc when a is b), or an axis-aligned box from
-- `a` to `b` widened by `r`. `hub` marks the town's own box: sea inside the town is judged by the
-- lanes and buildings in it, not by the whole square.
export type Shape = {
	ax: number,
	az: number,
	bx: number,
	bz: number,
	r: number,
	box: boolean,
	hub: boolean,
}
export type Bounds = { x0: number, z0: number, x1: number, z1: number }
-- A tree, spire or mass in the fill: where, how tall, and a random number in [0, 1) the builder
-- uses to choose a model and a colour.
export type Spot = { x: number, z: number, tall: number, pick: number }
export type FillPlan = { rows: { Spot }, masses: { Spot }, blocks: { Spot } }
-- A wall `thick` wide along a line of points, and a solid round pool.
export type Run = { points: { Layout.Point }, thick: number }
export type Disc = { x: number, z: number, r: number }
export type Tile = { x0: number, z0: number, x1: number, z1: number }
export type WaterPlan = { runs: { Run }, discs: { Disc }, tiles: { Tile } }
export type Index = { reach: number, buckets: { [number]: { Shape } } }

local Enclosure = {}

local INDEX_CELL = 64 -- studs: the spatial index's bucket size
local PLACE_RADIUS = 12 -- studs of walkable space kept round every named place
local LANE_PAD = 3 -- studs of walkable space kept beside a street or path

local function capsule(ax: number, az: number, bx: number, bz: number, r: number): Shape
	return { ax = ax, az = az, bx = bx, bz = bz, r = r, box = false, hub = false }
end

local function disc(x: number, z: number, r: number): Shape
	return capsule(x, z, x, z, r)
end
Enclosure.disc = disc

-- A strip from one world point to another, `r` either side: the walk between two biomes.
function Enclosure.link(a: Layout.Point, b: Layout.Point, r: number): Shape
	return capsule(a.x, a.z, b.x, b.z, r)
end

-- How far a point is outside a shape (negative inside a capsule or a padded box).
local function shapeDistance(s: Shape, x: number, z: number): number
	if s.box then
		local dx = math.max(s.ax - x, 0, x - s.bx)
		local dz = math.max(s.az - z, 0, z - s.bz)
		return math.sqrt(dx * dx + dz * dz) - s.r
	end
	local rx, rz = s.bx - s.ax, s.bz - s.az
	local length2 = rx * rx + rz * rz
	local t = 0
	if length2 > 1e-9 then
		t = math.clamp(((x - s.ax) * rx + (z - s.az) * rz) / length2, 0, 1)
	end
	local px, pz = s.ax + rx * t - x, s.az + rz * t - z
	return math.sqrt(px * px + pz * pz) - s.r
end

-- The distance from a point to the nearest shape (at most 0 inside any). `skipHub` ignores the
-- town's box.
function Enclosure.distance(shapes: { Shape }, x: number, z: number, skipHub: boolean): number
	local best = math.huge
	for _, s in shapes do
		if not (skipHub and s.hub) then
			local d = shapeDistance(s, x, z)
			if d < best then
				best = d
			end
		end
	end
	return best
end

-- A spatial index so a query only looks at shapes within `reach` studs.
function Enclosure.index(shapes: { Shape }, reach: number): Index
	local buckets: { [number]: { Shape } } = {}
	for _, s in shapes do
		local pad = s.r + reach
		local x0 = math.floor((math.min(s.ax, s.bx) - pad) / INDEX_CELL)
		local x1 = math.floor((math.max(s.ax, s.bx) + pad) / INDEX_CELL)
		local z0 = math.floor((math.min(s.az, s.bz) - pad) / INDEX_CELL)
		local z1 = math.floor((math.max(s.az, s.bz) + pad) / INDEX_CELL)
		for ix = x0, x1 do
			for iz = z0, z1 do
				local key = (ix + 1000) * 4000 + (iz + 1000)
				local list = buckets[key]
				if list == nil then
					list = {}
					buckets[key] = list
				end
				table.insert(list, s)
			end
		end
	end
	return { reach = reach, buckets = buckets }
end

-- The distance to the nearest shape, or math.huge when none lies within the index's reach.
function Enclosure.indexed(index: Index, x: number, z: number): number
	local list = index.buckets[(math.floor(x / INDEX_CELL) + 1000) * 4000 + (math.floor(
		z / INDEX_CELL
	) + 1000)]
	if list == nil then
		return math.huge
	end
	local best = math.huge
	for _, s in list do
		local d = shapeDistance(s, x, z)
		if d < best then
			best = d
		end
	end
	return best
end

-- The box that holds every shape, `margin` studs larger all round.
function Enclosure.bounds(shapes: { Shape }, margin: number): Bounds
	local out: Bounds = { x0 = math.huge, z0 = math.huge, x1 = -math.huge, z1 = -math.huge }
	for _, s in shapes do
		out.x0 = math.min(out.x0, math.min(s.ax, s.bx) - s.r - margin)
		out.z0 = math.min(out.z0, math.min(s.az, s.bz) - s.r - margin)
		out.x1 = math.max(out.x1, math.max(s.ax, s.bx) + s.r + margin)
		out.z1 = math.max(out.z1, math.max(s.az, s.bz) + s.r + margin)
	end
	return out
end

local function world(map: Layout.Map, point: WorldTypes.SheetPoint): Layout.Point
	return { x = map.hub.x + point.x, z = map.hub.z + point.z }
end

local function worldAll(map: Layout.Map, points: { WorldTypes.SheetPoint }): { Layout.Point }
	local out: { Layout.Point } = {}
	for _, point in points do
		table.insert(out, world(map, point))
	end
	return out
end

-- A line of points as capsules `r` either side.
local function polyline(into: { Shape }, points: { Layout.Point }, r: number)
	if #points == 1 then
		table.insert(into, disc(points[1].x, points[1].z, r))
	end
	for index = 1, #points - 1 do
		local a, b = points[index], points[index + 1]
		table.insert(into, capsule(a.x, a.z, b.x, b.z, r))
	end
end

-- A line of points resampled every `step` studs, keeping its end.
local function sampled(points: { Layout.Point }, step: number): { Layout.Point }
	local out: { Layout.Point } = {}
	for index = 1, #points - 1 do
		local a, b = points[index], points[index + 1]
		local count = math.max(1, math.ceil(Layout.distance(a, b) / step))
		for k = 0, count - 1 do
			local t = k / count
			table.insert(out, { x = a.x + (b.x - a.x) * t, z = a.z + (b.z - a.z) * t })
		end
	end
	if #points > 0 then
		table.insert(out, points[#points])
	end
	return out
end

-- The lane of every route and the lair's spur, drawn as shapes `r` either side of the lane.
local function laneShapes(biome: WorldTypes.Biome, map: Layout.Map, r: number): { Shape }
	local out: { Shape } = {}
	for _, route in biome.routes do
		local line = map.routes[route.id]
		if line then
			polyline(out, line.points, r)
		end
	end
	polyline(out, map.lairSpur, r)
	return out
end

-- Every part of a biome that can be walked on: the town's square, each route's corridor at its
-- half-width, the lair's spur, clearings, every named place, the streets, paths, stones and bridges
-- of the dressing sheet, buildings, the gatehouse and the road on past the gate. `links` are
-- strips joining this biome to the one before it. The same set is used to place fill outside it.
function Enclosure.walkable(
	biome: WorldTypes.Biome,
	map: Layout.Map,
	dressing: WorldTypes.DressingSheet,
	links: { Shape }
): { Shape }
	local out: { Shape } = {}
	local half = map.hub.size / 2
	table.insert(out, {
		ax = map.hub.x - half,
		az = map.hub.z - half,
		bx = map.hub.x + half,
		bz = map.hub.z + half,
		r = 0,
		box = true,
		hub = true,
	})
	for _, link in links do
		table.insert(out, link)
	end
	for _, route in biome.routes do
		local line = map.routes[route.id]
		local widths = if line then line.halfWidth else nil
		if line and widths then
			local along = 0
			while along < line.length do
				local nextAlong = math.min(along + 16, line.length)
				local a, b = Layout.pointAt(line, along), Layout.pointAt(line, nextAlong)
				local middle = (along + nextAlong) / 2
				local r = 50
				for _, area in route.areas do
					if middle >= area.from and middle <= area.to then
						r = widths[area.id] or r
					end
				end
				table.insert(out, capsule(a.x, a.z, b.x, b.z, r))
				along = nextAlong
			end
		end
	end
	local spurWidth = map.lairHalfWidth or 30
	for index = 1, #map.lairSpur - 1 do
		local a, b = map.lairSpur[index], map.lairSpur[index + 1]
		table.insert(out, capsule(a.x, a.z, b.x, b.z, spurWidth))
	end
	for _, clearing in dressing.clearings do
		local at = world(map, clearing.at)
		table.insert(out, disc(at.x, at.z, clearing.radius + 2))
	end
	for _, place in map.places do
		table.insert(out, disc(place.x, place.z, PLACE_RADIUS))
	end
	for id, point in map.buildings do
		local size = dressing.buildings[id]
		local reach = if size then math.max(size.width, size.depth) / 2 + 6 else 20
		table.insert(out, disc(point.x, point.z, reach))
	end
	-- The gate and the road on past it.
	local gate = map.places[biome.gate.id]
	local sealed = map.places[biome.gate.sealedPath]
	if gate and sealed then
		local length = math.max(Layout.distance(gate, sealed), 1e-6)
		local beyond = {
			x = sealed.x + (sealed.x - gate.x) / length * 60,
			z = sealed.z + (sealed.z - gate.z) / length * 60,
		}
		table.insert(out, capsule(gate.x, gate.z, beyond.x, beyond.z, 30))
	end
	for _, street in dressing.lanes do
		polyline(out, worldAll(map, street.points), street.width / 2 + LANE_PAD)
	end
	for _, path in dressing.footpaths do
		polyline(out, worldAll(map, path.points), path.width / 2 + LANE_PAD)
	end
	for _, stones in dressing.stones do
		local a, b = world(map, stones.from), world(map, stones.to)
		table.insert(out, capsule(a.x, a.z, b.x, b.z, 5))
	end
	local bridge = dressing.footbridge
	if bridge then
		local at = world(map, bridge.at)
		table.insert(out, disc(at.x, at.z, bridge.length / 2 + 4))
	end
	-- Things placed for their own sake keep the fill off them.
	for _, arch in dressing.arches do
		local at = world(map, arch.at)
		table.insert(out, disc(at.x, at.z, 16))
	end
	for _, house in dressing.houses do
		local at = world(map, house.at)
		table.insert(out, disc(at.x, at.z, math.max(house.width, house.depth) / 2 + 6))
	end
	for _, prop in dressing.props do
		local at = world(map, prop.at)
		table.insert(out, disc(at.x, at.z, 8))
	end
	for _, person in dressing.people do
		local at = world(map, person.at)
		table.insert(out, disc(at.x, at.z, 6))
	end
	for _, sign in dressing.signs do
		local at = world(map, sign.at)
		table.insert(out, disc(at.x, at.z, 6))
	end
	local gatehouse = dressing.gatehouse
	local gatehouseAt = world(map, gatehouse.at)
	table.insert(out, disc(gatehouseAt.x, gatehouseAt.z, 30))
	local bar = world(map, dressing.bar.at)
	table.insert(out, disc(bar.x, bar.z, 30))
	local tree = dressing.ancientTree
	if tree then
		local at = world(map, tree.at)
		table.insert(out, disc(at.x, at.z, 45))
	end
	local landmark = dressing.landmark
	if landmark then
		local at = world(map, landmark.at)
		table.insert(out, disc(at.x, at.z, 45))
	end
	local knoll = dressing.knoll
	if knoll then
		local at = world(map, knoll.at)
		table.insert(out, disc(at.x, at.z, 20))
	end
	local picnic = dressing.picnic
	if picnic then
		local at = world(map, picnic.at)
		table.insert(out, disc(at.x, at.z, picnic.radius + 4))
	end
	local pocket = dressing.pocket
	if pocket then
		local at = world(map, pocket.at)
		table.insert(out, disc(at.x, at.z, pocket.radius + 4))
	end
	for _, bramble in dressing.brambles do
		local at = world(map, bramble)
		table.insert(out, disc(at.x, at.z, 10))
	end
	if dressing.coop then
		local at = world(map, dressing.coop)
		table.insert(out, disc(at.x, at.z, 10))
	end
	local patch = dressing.patch
	if patch then
		local a, b = world(map, patch.from), world(map, patch.to)
		table.insert(out, capsule(a.x, a.z, b.x, b.z, 10))
	end
	return out
end

-- The fill past the edges: a row of tall things at the edge, masses behind it and blocks out to
-- `band`, all on jittered grids, outside every shape and clear of `seas` (open water takes no
-- trees). The same seed gives the same fill.
function Enclosure.fill(
	shapes: { Shape },
	bounds: Bounds,
	style: string,
	band: number,
	seed: number,
	seas: { Tile }
): FillPlan
	local tall = WorldConfig.FILL_TALL[style] or WorldConfig.FILL_TALL.Forest
	local rowFrom = WorldConfig.FILL_PAD
	local massFrom = rowFrom + WorldConfig.FILL_ROW_WIDTH
	local blockFrom = massFrom + WorldConfig.FILL_MASS_WIDTH
	local index = Enclosure.index(shapes, band + 2)
	local rng = Rng.new(seed)
	local plan: FillPlan = { rows = {}, masses = {}, blocks = {} }
	local function inSea(x: number, z: number): boolean
		for _, sea in seas do
			if x >= sea.x0 and x <= sea.x1 and z >= sea.z0 and z <= sea.z1 then
				return true
			end
		end
		return false
	end
	local function layer(into: { Spot }, step: number, from: number, to: number, range: { number })
		local x = bounds.x0 + step / 2
		while x < bounds.x1 do
			local z = bounds.z0 + step / 2
			while z < bounds.z1 do
				-- Every number is drawn whether or not the spot is kept, so the grid stays stable.
				local jitterX = (Rng.next(rng) - 0.5) * step * 0.7
				local jitterZ = (Rng.next(rng) - 0.5) * step * 0.7
				local height = range[1] + Rng.next(rng) * (range[2] - range[1])
				local pick = Rng.next(rng)
				local px, pz = x + jitterX, z + jitterZ
				local d = Enclosure.indexed(index, px, pz)
				if d >= from and d < to and not inSea(px, pz) then
					table.insert(into, { x = px, z = pz, tall = height, pick = pick })
				end
				z += step
			end
			x += step
		end
	end
	layer(plan.rows, WorldConfig.FILL_ROW_STEP, rowFrom, massFrom, tall.row)
	layer(plan.masses, WorldConfig.FILL_MASS_STEP, massFrom, blockFrom, tall.mass)
	layer(plan.blocks, WorldConfig.FILL_BLOCK_STEP, blockFrom, band, tall.block)
	return plan
end

-- The rectangles of open water on a dressing sheet's flats, in the world.
function Enclosure.seas(map: Layout.Map, dressing: WorldTypes.DressingSheet): { Tile }
	local out: { Tile } = {}
	local flats: { WorldTypes.DressFlat } = dressing.flats or {}
	for _, flat in flats do
		if flat.water then
			local a, b = world(map, flat.from), world(map, flat.to)
			table.insert(out, {
				x0 = math.min(a.x, b.x),
				z0 = math.min(a.z, b.z),
				x1 = math.max(a.x, b.x),
				z1 = math.max(a.z, b.z),
			})
		end
	end
	return out
end

-- Water that blocks the way (docs/plans/12_MAP_STRUCTURE.md section 3, principle 11):
--   * each stream, as a wall as wide as the water, left open where a street, path, route lane,
--     stones or a bridge crosses it;
--   * each pool as a solid disc, and the pond as a ring with a rail round its jetty;
--   * open sea as tiles on a grid, in the band round the walkable space, except beside lanes.
-- `bounds` limits the tiles to the biome's ground.
function Enclosure.water(
	biome: WorldTypes.Biome,
	map: Layout.Map,
	dressing: WorldTypes.DressingSheet,
	shapes: { Shape },
	bounds: Bounds
): WaterPlan
	local plan: WaterPlan = { runs = {}, discs = {}, tiles = {} }

	-- Where a stream may not be blocked: it is crossed there.
	local crossings: { Shape } = laneShapes(biome, map, dressing.laneWidth / 2)
	for _, street in dressing.lanes do
		polyline(crossings, worldAll(map, street.points), street.width / 2)
	end
	for _, path in dressing.footpaths do
		polyline(crossings, worldAll(map, path.points), path.width / 2)
	end
	for _, stones in dressing.stones do
		local a, b = world(map, stones.from), world(map, stones.to)
		table.insert(crossings, capsule(a.x, a.z, b.x, b.z, 3))
	end
	local bridge = dressing.footbridge
	if bridge then
		local at = world(map, bridge.at)
		table.insert(crossings, disc(at.x, at.z, bridge.width / 2))
	end

	local margin = WorldConfig.WATER_CROSSING_MARGIN
	for _, stream in dressing.water do
		local thick = math.max(stream.width - 2, 2)
		local run: { Layout.Point } = {}
		local function flush()
			if #run >= 2 then
				table.insert(plan.runs, { points = run, thick = thick })
			end
			run = {}
		end
		for _, point in sampled(worldAll(map, stream.points), 2) do
			if Enclosure.distance(crossings, point.x, point.z, false) < margin + thick / 4 then
				flush()
			else
				table.insert(run, point)
			end
		end
		flush()
	end

	for _, pool in dressing.pools do
		local at = world(map, pool.at)
		table.insert(plan.discs, { x = at.x, z = at.z, r = math.max(pool.radius - 1, 1) })
	end

	local pond = dressing.pond
	if pond then
		local centre = world(map, pond.at)
		local r = pond.radius - 1
		local jetty = worldAll(map, pond.jetty)
		local a, b = jetty[1], jetty[#jetty]
		local gap = if a and b then capsule(a.x, a.z, b.x, b.z, 3.4) else nil
		local arc: { Layout.Point } = {}
		local function close()
			if #arc >= 2 then
				table.insert(plan.runs, { points = arc, thick = 2 })
			end
			arc = {}
		end
		local count = 28
		for k = 0, count do
			local angle = k / count * math.pi * 2
			local point = { x = centre.x + math.cos(angle) * r, z = centre.z + math.sin(angle) * r }
			if gap and shapeDistance(gap, point.x, point.z) < 0 then
				close()
			else
				table.insert(arc, point)
			end
		end
		close()
		-- A rail down each side of the jetty where it is over the water, and across its end.
		if a and b then
			local run = Layout.distance(a, b)
			local unit =
				{ x = (b.x - a.x) / math.max(run, 1e-6), z = (b.z - a.z) / math.max(run, 1e-6) }
			local side = { x = -unit.z, z = unit.x }
			local reach = r - Layout.distance(centre, b) + 3
			if reach > 0 then
				for _, s in { -2.5, 2.5 } do
					local from = {
						x = b.x - unit.x * reach + side.x * s,
						z = b.z - unit.z * reach + side.z * s,
					}
					local to =
						{ x = b.x + unit.x * 0.8 + side.x * s, z = b.z + unit.z * 0.8 + side.z * s }
					table.insert(plan.runs, { points = { from, to }, thick = 1 })
				end
				local tipA =
					{ x = b.x + unit.x * 0.8 - side.x * 2.5, z = b.z + unit.z * 0.8 - side.z * 2.5 }
				local tipB =
					{ x = b.x + unit.x * 0.8 + side.x * 2.5, z = b.z + unit.z * 0.8 + side.z * 2.5 }
				table.insert(plan.runs, { points = { tipA, tipB }, thick = 1 })
			end
		end
	end

	-- Open sea: solid in a band round the walkable space, except where a lane or the town's own
	-- streets and buildings run over it.
	local seas = Enclosure.seas(map, dressing)
	if #seas > 0 then
		local step = WorldConfig.WATER_TILE_STEP
		local band = WorldConfig.WATER_TILE_BAND
		local near = Enclosure.index(shapes, band + step)
		local keep: { Shape } = {}
		for _, s in shapes do
			if not s.hub then
				table.insert(keep, s)
			end
		end
		local kept = Enclosure.index(keep, band + step)
		local seen: { [number]: boolean } = {}
		for _, sea in seas do
			local z = math.floor(math.max(sea.z0, bounds.z0) / step) * step
			while z < math.min(sea.z1, bounds.z1) do
				local x = math.floor(math.max(sea.x0, bounds.x0) / step) * step
				local from: number? = nil
				local function flush(upTo: number)
					if from then
						table.insert(plan.tiles, { x0 = from, z0 = z, x1 = upTo, z1 = z + step })
						from = nil
					end
				end
				while x < math.min(sea.x1, bounds.x1) do
					local cx, cz = x + step / 2, z + step / 2
					local rowKey = math.floor(cx / step) * 100000 + math.floor(cz / step)
					local solid = not seen[rowKey]
						and cx >= sea.x0
						and cx <= sea.x1
						and cz >= sea.z0
						and cz <= sea.z1
						and Enclosure.indexed(near, cx, cz) <= band
						and Enclosure.indexed(kept, cx, cz) > WorldConfig.WATER_TILE_MARGIN
					if solid then
						seen[rowKey] = true
						if from == nil then
							from = x
						end
					else
						flush(x)
					end
					x += step
				end
				flush(x)
				z += step
			end
		end
		-- Rows that stack exactly (same x range, touching) become one tall tile.
		local merged: { Tile } = {}
		local open: { [string]: Tile } = {}
		for _, tile in plan.tiles do
			local key = `{tile.x0}:{tile.x1}`
			local above = open[key]
			if above and math.abs(above.z1 - tile.z0) < 1e-6 then
				above.z1 = tile.z1
			else
				table.insert(merged, tile)
				open[key] = tile
			end
		end
		plan.tiles = merged
	end
	return plan
end

return Enclosure
