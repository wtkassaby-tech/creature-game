--!strict
-- Where a character can walk on a designed map, and how they can get from one place to another
-- (docs/plans/12_MAP_STRUCTURE.md section 4a). Pure and flat, with no Roblox services:
--   * `Walk.space` collects a biome's walkable ground from its map sheet: the town square, each
--     lane at its half-width along the route, rooms, the lair's arena, the road past the gate,
--     less buildings and the fences that close a lane on purpose.
--   * `Walk.grid` cuts that into 4-stud cells with the ground's height in each, and `Walk.reach`
--     floods it: cells join when they are level, when stairs or a ramp ease between them, or when
--     a ledge lets you hop down (never up). Walls (a tier's face) join nothing.
-- The builders use `Walk.depth` to decide where an edge stands, and the tests use the grid to
-- prove every place can be reached, nothing traps a player, and grass can be walked round. The
-- server's own checks do not read any of it.

local Ground = require("./Ground")
local Layout = require("./Layout")
local WorldTypes = require("./WorldTypes")

-- One lane: a line with its half-width at each distance along it.
type Lane = {
	points: { Layout.Point },
	widths: { WorldTypes.WidthKey }?,
	stretches: { { from: number, to: number, half: number } }, -- the fallback, by stretch
	fallback: number,
}

export type Space = {
	hub: { x0: number, z0: number, x1: number, z1: number },
	lanes: { Lane },
	rooms: { Ground.Shape },
	sheetRooms: { Ground.Shape }, -- the sheet's own rooms (also in `rooms`), for the builders
	blocks: { Ground.Shape }, -- buildings and closed fences: never open
}

export type Grid = {
	space: Space,
	ground: Ground.Ground,
	cell: number,
	x0: number,
	z0: number,
	columns: number,
	rows: number,
	open: { boolean },
	height: { number },
}

export type Reach = { seen: { boolean }, count: number }
export type Options = {
	ledges: boolean?, -- false: a ledge cannot be hopped (default true)
	avoid: ((x: number, z: number) -> boolean)?, -- cells where this is true are walls
	forward: boolean?, -- false: flood backwards, to find every cell that can reach the start
}

local Walk = {}

local STEP = 2.6 -- the most a 4-stud cell may rise or fall and still be walked: stairs and ramps ease at 0.5 a stud
local HOP = 4 -- the least drop a ledge hop has to be

-- How far inside a lane a point is: the half-width there less the distance to the line, at the
-- nearest leg. Negative outside.
local function laneDepth(lane: Lane, x: number, z: number): number
	local best = -math.huge
	local covered = 0
	for index = 1, #lane.points - 1 do
		local a, b = lane.points[index], lane.points[index + 1]
		local rx, rz = b.x - a.x, b.z - a.z
		local length = math.sqrt(rx * rx + rz * rz)
		if length > 1e-9 then
			local t = math.clamp(((x - a.x) * rx + (z - a.z) * rz) / (length * length), 0, 1)
			local px, pz = a.x + rx * t - x, a.z + rz * t - z
			local off = math.sqrt(px * px + pz * pz)
			local at = covered + length * t
			local half = lane.fallback
			if lane.widths then
				half = Layout.halfWidthAt(lane.widths, at, lane.fallback)
			else
				for _, stretch in lane.stretches do
					if at >= stretch.from and at <= stretch.to then
						half = stretch.half
					end
				end
			end
			if half - off > best then
				best = half - off
			end
		end
		covered += length
	end
	return best
end

local function disc(x: number, z: number, r: number): Ground.Shape
	return { kind = "Disc", ax = x, az = z, bx = x, bz = z, r = r }
end

local function strip(a: Layout.Point, b: Layout.Point, r: number): Ground.Shape
	return { kind = "Strip", ax = a.x, az = a.z, bx = b.x, bz = b.z, r = r }
end

-- The walkable ground of a biome in the world. `dressing` is optional: with it, the lair's arena
-- takes its ring clearing's radius, buildings take their footprints and closed fences block.
function Walk.space(
	biome: WorldTypes.Biome,
	map: Layout.Map,
	dressing: WorldTypes.DressingSheet?
): Space
	local half = map.hub.size / 2
	local space: Space = {
		hub = {
			x0 = map.hub.x - half,
			z0 = map.hub.z - half,
			x1 = map.hub.x + half,
			z1 = map.hub.z + half,
		},
		lanes = {},
		rooms = {},
		sheetRooms = {},
		blocks = {},
	}
	local origin: Layout.Point = { x = map.hub.x, z = map.hub.z }
	for _, route in biome.routes do
		local line = map.routes[route.id]
		if line then
			local stretches: { { from: number, to: number, half: number } } = {}
			for _, area in route.areas do
				local width = if line.halfWidth then line.halfWidth[area.id] else nil
				if width then
					table.insert(stretches, { from = area.from, to = area.to, half = width })
				end
			end
			table.insert(space.lanes, {
				points = line.points,
				widths = line.widths,
				stretches = stretches,
				fallback = 50,
			})
		end
	end
	if #map.lairSpur >= 2 then
		table.insert(space.lanes, {
			points = map.lairSpur,
			widths = map.lairWidths,
			stretches = {},
			fallback = map.lairHalfWidth or 30,
		})
		local arena = map.lairSpur[#map.lairSpur]
		local radius = biome.lair.arenaSize / 2
		if dressing then
			for _, clearing in dressing.clearings do
				if clearing.ring then
					radius = clearing.radius
				end
			end
		end
		table.insert(space.rooms, disc(arena.x, arena.z, radius))
	end
	local sheet = biome.map
	if sheet and sheet.rooms then
		for _, room in sheet.rooms do
			local shape = Ground.shape(room.shape, origin)
			table.insert(space.rooms, shape)
			table.insert(space.sheetRooms, shape)
		end
	end
	-- The gate, and the road on past it.
	local gate = map.places[biome.gate.id]
	local sealed = map.places[biome.gate.sealedPath]
	if gate and sealed then
		table.insert(space.rooms, strip(gate, sealed, 12))
	end
	if dressing then
		for id, point in map.buildings do
			local size = dressing.buildings[id]
			if size and size.tall > 1 then
				table.insert(
					space.blocks,
					disc(point.x, point.z, math.max(math.min(size.width, size.depth) / 2 - 1, 1))
				)
			end
		end
		for _, fence in dressing.fences do
			if fence.across then
				for index = 1, #fence.points - 1 do
					local a, b = fence.points[index], fence.points[index + 1]
					table.insert(
						space.blocks,
						strip(
							{ x = origin.x + a.x, z = origin.z + a.z },
							{ x = origin.x + b.x, z = origin.z + b.z },
							0.8
						)
					)
				end
			end
		end
	end
	return space
end

-- How far inside walkable ground a point is (negative outside it): the best of the town square
-- (if `hub`), every lane and every room but `skip`, and negative anywhere a building or closed fence stands.
function Walk.depth(space: Space, x: number, z: number, hub: boolean, skip: Ground.Shape?): number
	for _, block in space.blocks do
		if Ground.distance(block, x, z) < 0 then
			return -1
		end
	end
	local best = -math.huge
	if hub then
		local box = space.hub
		local d = math.min(x - box.x0, box.x1 - x, z - box.z0, box.z1 - z)
		if d > best then
			best = d
		end
	end
	for _, lane in space.lanes do
		local d = laneDepth(lane, x, z)
		if d > best then
			best = d
		end
	end
	for _, room in space.rooms do
		if room ~= skip then
			local d = -Ground.distance(room, x, z)
			if d > best then
				best = d
			end
		end
	end
	return best
end

-- True when a character can stand at a flat point.
function Walk.open(space: Space, x: number, z: number): boolean
	return Walk.depth(space, x, z, true, nil) >= 0
end

-- A grid of `cell`-stud cells over the box `bounds`, with each cell's openness and height.
function Walk.grid(
	space: Space,
	ground: Ground.Ground,
	bounds: { x0: number, z0: number, x1: number, z1: number },
	cell: number
): Grid
	local columns = math.ceil((bounds.x1 - bounds.x0) / cell)
	local rows = math.ceil((bounds.z1 - bounds.z0) / cell)
	local open: { boolean } = {}
	local height: { number } = {}
	for cz = 0, rows - 1 do
		for cx = 0, columns - 1 do
			local x, z = bounds.x0 + (cx + 0.5) * cell, bounds.z0 + (cz + 0.5) * cell
			local key = cz * columns + cx + 1
			open[key] = Walk.open(space, x, z)
			height[key] = if open[key] then Ground.heightAt(ground, x, z) else 0
		end
	end
	return {
		space = space,
		ground = ground,
		cell = cell,
		x0 = bounds.x0,
		z0 = bounds.z0,
		columns = columns,
		rows = rows,
		open = open,
		height = height,
	}
end

function Walk.key(grid: Grid, x: number, z: number): number?
	local cx = math.floor((x - grid.x0) / grid.cell)
	local cz = math.floor((z - grid.z0) / grid.cell)
	if cx < 0 or cz < 0 or cx >= grid.columns or cz >= grid.rows then
		return nil
	end
	return cz * grid.columns + cx + 1
end

local function centre(grid: Grid, key: number): (number, number)
	local index = key - 1
	local cx, cz = index % grid.columns, math.floor(index / grid.columns)
	return grid.x0 + (cx + 0.5) * grid.cell, grid.z0 + (cz + 0.5) * grid.cell
end

-- True when a character on cell `from` can step to the neighbouring cell `to`.
function Walk.canStep(grid: Grid, from: number, to: number, ledges: boolean): boolean
	if not (grid.open[from] and grid.open[to]) then
		return false
	end
	local drop = grid.height[from] - grid.height[to]
	if math.abs(drop) <= STEP then
		return true
	end
	if ledges and drop >= HOP then
		local ax, az = centre(grid, from)
		local bx, bz = centre(grid, to)
		return Ground.ledgeAt(grid.ground, (ax + bx) / 2, (az + bz) / 2, 1) ~= nil
	end
	return false
end

-- Every cell that can be reached from a flat point (or, backwards, every cell that can reach it).
function Walk.reach(grid: Grid, x: number, z: number, options: Options?): Reach
	local opts: Options = options or {}
	local ledges = opts.ledges ~= false
	local forward = opts.forward ~= false
	local avoid = opts.avoid
	local blocked: { boolean } = {}
	if avoid then
		for key = 1, grid.columns * grid.rows do
			if grid.open[key] then
				local cx, cz = centre(grid, key)
				blocked[key] = avoid(cx, cz)
			end
		end
	end
	local seen: { boolean } = {}
	local start = Walk.key(grid, x, z)
	local count = 0
	if start == nil or not grid.open[start] or blocked[start] then
		return { seen = seen, count = 0 }
	end
	seen[start] = true
	local queue: { number } = { start }
	local head = 1
	local columns = grid.columns
	while head <= #queue do
		local key = queue[head]
		head += 1
		count += 1
		local index = key - 1
		local cx, cz = index % columns, math.floor(index / columns)
		for _, step in { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
			local nx, nz = cx + step[1], cz + step[2]
			if nx >= 0 and nz >= 0 and nx < columns and nz < grid.rows then
				local other = nz * columns + nx + 1
				if not seen[other] and not blocked[other] then
					local ok = if forward
						then Walk.canStep(grid, key, other, ledges)
						else Walk.canStep(grid, other, key, ledges)
					if ok then
						seen[other] = true
						table.insert(queue, other)
					end
				end
			end
		end
	end
	return { seen = seen, count = count }
end

-- True when the cell under a flat point was reached.
function Walk.reached(grid: Grid, reach: Reach, x: number, z: number): boolean
	local key = Walk.key(grid, x, z)
	return key ~= nil and reach.seen[key] == true
end

-- True when a point, or any point on a ring `radius` studs round it, was reached: a prompt works
-- from a few studs off.
function Walk.reachedNear(grid: Grid, reach: Reach, x: number, z: number, radius: number): boolean
	if Walk.reached(grid, reach, x, z) then
		return true
	end
	for k = 0, 7 do
		local angle = k / 8 * math.pi * 2
		if
			Walk.reached(grid, reach, x + math.cos(angle) * radius, z + math.sin(angle) * radius)
		then
			return true
		end
	end
	return false
end

return Walk
