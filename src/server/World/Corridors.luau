--!strict
-- The designed routes as places with edges (docs/plans/08_GREENWOOD_MAP.md sections 3 and 5):
-- the coloured ground of each stretch, and a hedge down each side of every route and the lair
-- spur at the map sheet's half-widths, with trees just outside. Where two corridors meet, or a
-- corridor meets the town, the hedges give way, so the union of all of them is one walkable
-- space. This replaces the random scatter for a biome that has a map sheet. The lanes
-- themselves are in Lanes.luau.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Layout = require(ReplicatedStorage.shared.Layout)
local WorldTypes = require(ReplicatedStorage.shared.WorldTypes)

local Fences = require(script.Parent.Fences)
local Props = require(script.Parent.Props)

local Corridors = {}

-- One corridor: a lane's centre line and how wide its corridor is at a distance along it.
type Corridor = {
	id: string,
	line: Layout.RouteLine,
	points: { Vector3 },
	widthAt: (along: number) -> number,
	areaAt: (along: number) -> string?,
}

local EDGE_STEP = 3 -- studs between the points an edge is traced through
local INSIDE_MARGIN = 1.5 -- an edge point this far inside another corridor gives way

local function flat(point: Layout.Point): Vector3
	return Vector3.new(point.x, 0, point.z)
end

local function flatAll(points: { Layout.Point }): { Vector3 }
	local out: { Vector3 } = {}
	for _, point in points do
		table.insert(out, flat(point))
	end
	return out
end

-- Every corridor of a biome with a map sheet: its routes, and its lair spur.
local function corridors(biome: WorldTypes.Biome, map: Layout.Map): { Corridor }
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
				points = flatAll(line.points),
				widthAt = function(along: number): number
					local area = areaAt(along)
					return (if area then widths[area] else nil) or 50
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
			points = flatAll(map.lairSpur),
			widthAt = function(): number
				return spurWidth
			end,
			areaAt = function(): string?
				return nil
			end,
		})
	end
	return list
end

-- True when `at` is well inside any corridor (`margin` studs or more within its edge).
local function insideAny(list: { Corridor }, at: Vector3, margin: number): boolean
	for _, corridor in list do
		local along, off = Props.nearest(corridor.points, at)
		if off < corridor.widthAt(along) - margin then
			return true
		end
	end
	return false
end

local function inTown(map: Layout.Map, at: Vector3, pad: number): boolean
	local half = map.hub.size / 2 + pad
	return math.abs(at.X - map.hub.x) < half and math.abs(at.Z - map.hub.z) < half
end

local function wet(waters: { Fences.Water }, at: Vector3, pad: number): boolean
	for _, water in waters do
		local _, off = Props.nearest(water.points, at)
		if off < water.half + pad then
			return true
		end
	end
	return false
end

-- The direction of a line at a distance along it, smoothed over a few studs so edges round the
-- bends instead of jumping.
local function heading(line: Layout.RouteLine, along: number): Vector3
	local a = Layout.pointAt(line, math.max(along - 4, 0))
	local b = Layout.pointAt(line, math.min(along + 4, line.length))
	local run = Vector3.new(b.x - a.x, 0, b.z - a.z)
	return if run.Magnitude > 1e-3 then run.Unit else Vector3.xAxis
end

-- The coloured ground of each stretch (its whole corridor) and of bands beside a route (the
-- sand strip), as slabs with a disc at each step, each layer a hair above the last.
function Corridors.ground(
	parent: Instance,
	biome: WorldTypes.Biome,
	map: Layout.Map,
	dressing: WorldTypes.DressingSheet
)
	local folder = Instance.new("Folder")
	folder.Name = "GroundPatches"
	folder.Parent = parent
	for layer, patch in dressing.ground do
		local line: Layout.RouteLine? = nil
		local from, to, near, far = patch.from or 0, patch.to or 0, patch.near or 0, patch.far or 0
		for _, route in biome.routes do
			for _, area in route.areas do
				if area.id == patch.area then
					local routeLine = map.routes[route.id]
					local width = if routeLine and routeLine.halfWidth
						then routeLine.halfWidth[area.id]
						else nil
					line = routeLine
					from, to = area.from, area.to
					near, far = -(width or 40), width or 40
				end
			end
			if patch.route == route.id then
				line = map.routes[route.id]
			end
		end
		if line == nil then
			continue
		end
		local band = far - near
		local middle = (near + far) / 2
		local top = 0.03 + layer * 0.012
		local colour = Props.colour(patch.colour)
		local previous: Vector3? = nil
		local along = from
		while along <= to do
			local at = flat(Layout.pointAt(line, along, middle))
			-- Stay out of the town: its own green is its ground.
			local half = map.hub.size / 2
			local dx = math.max(math.abs(at.X - map.hub.x) - half, 0)
			local dz = math.max(math.abs(at.Z - map.hub.z) - half, 0)
			if math.sqrt(dx * dx + dz * dz) >= band / 2 then
				Props.disc(folder, at, band, 0.1, top, colour)
				if previous then
					Props.strip(folder, previous, at, band, 0.1, top, colour)
				end
				previous = at
			else
				previous = nil
			end
			if along >= to then
				break
			end
			along = math.min(along + 10, to)
		end
	end
end

-- The hedges down both sides of every corridor, the hedge across a route's far end, the hedge
-- round a ring clearing (the lair), and trees just outside them all.
function Corridors.edges(
	parent: Instance,
	biome: WorldTypes.Biome,
	map: Layout.Map,
	dressing: WorldTypes.DressingSheet,
	waters: { Fences.Water },
	pick: Random
)
	local folder = Instance.new("Folder")
	folder.Name = "Edges"
	folder.Parent = parent
	local list = corridors(biome, map)
	local origin = Vector3.new(map.hub.x, 0, map.hub.z)
	local rings: { { at: Vector3, radius: number } } = {}
	local bulges: { { at: Vector3, radius: number } } = {}
	for _, clearing in dressing.clearings do
		local entry =
			{ at = origin + Vector3.new(clearing.at.x, 0, clearing.at.z), radius = clearing.radius }
		table.insert(if clearing.ring then rings else bulges, entry)
	end
	local function inRing(at: Vector3, pad: number): boolean
		for _, ring in rings do
			if (at - ring.at).Magnitude < ring.radius + pad then
				return true
			end
		end
		return false
	end

	-- A tree outside an edge, if the spot is clear of lanes, water, town and clearings.
	local function plant(at: Vector3, model: string, scale: number)
		if insideAny(list, at, -2) or inTown(map, at, 4) or wet(waters, at, 3) or inRing(at, 2) then
			return
		end
		Props.tree(folder, at, model, scale, pick)
	end
	local function treeFor(corridor: Corridor, along: number): (string, number)
		local area = corridor.areaAt(along)
		local special = if area then dressing.corridorTrees[area] else nil
		if special then
			return special.model, special.scale
		end
		return if pick:NextNumber() < 0.6 then "Tree" else "Pine", 1
	end

	for _, corridor in list do
		for _, side in { -1, 1 } do
			local runs: { { Vector3 } } = {}
			local normals: { { Vector3 } } = {}
			local alongs: { { number } } = {}
			local current: { Vector3 }, currentNormals: { Vector3 }, currentAlongs: { number } =
				{}, {}, {}
			local along = 0
			while true do
				local centre = flat(Layout.pointAt(corridor.line, along))
				local run = heading(corridor.line, along)
				local normal = Vector3.new(-run.Z, 0, run.X) * side
				local point = centre + normal * corridor.widthAt(along)
				for _, bulge in bulges do
					local out = point - bulge.at
					if out.Magnitude < bulge.radius + 2 and out.Magnitude > 1e-3 then
						point = bulge.at + out.Unit * (bulge.radius + 2)
					end
				end
				local keep = not inTown(map, point, 2)
					and not insideAny(list, point, INSIDE_MARGIN)
					and not inRing(point, 1)
				if keep then
					table.insert(current, point)
					table.insert(currentNormals, normal)
					table.insert(currentAlongs, along)
				elseif #current > 0 then
					table.insert(runs, current)
					table.insert(normals, currentNormals)
					table.insert(alongs, currentAlongs)
					current, currentNormals, currentAlongs = {}, {}, {}
				end
				if along >= corridor.line.length then
					break
				end
				along = math.min(along + EDGE_STEP, corridor.line.length)
			end
			if #current > 0 then
				table.insert(runs, current)
				table.insert(normals, currentNormals)
				table.insert(alongs, currentAlongs)
			end
			for index, run in runs do
				-- An edge that starts at the town is joined to the town's own hedge.
				local first = run[1]
				local half = map.hub.size / 2
				local dx, dz = first.X - origin.X, first.Z - origin.Z
				if math.abs(dz) < half and math.abs(dx) > half and math.abs(dx) - half < 25 then
					table.insert(run, 1, Vector3.new(origin.X + math.sign(dx) * half, 0, first.Z))
				elseif math.abs(dx) < half and math.abs(dz) > half and math.abs(dz) - half < 25 then
					table.insert(run, 1, Vector3.new(first.X, 0, origin.Z + math.sign(dz) * half))
				end
				Fences.hedge(folder, run, waters)
				local nextTree = pick:NextNumber(0, 8)
				local walked = 0
				for k = 2, #normals[index] do
					local point = run[k + (#run - #normals[index])]
					local before = run[k - 1 + (#run - #normals[index])]
					walked += (point - before).Magnitude
					if walked >= nextTree then
						nextTree = walked + pick:NextNumber(12, 16)
						local model, scale = treeFor(corridor, alongs[index][k])
						plant(point + normals[index][k] * pick:NextNumber(4, 10), model, scale)
					end
				end
			end
		end

		-- The hedge across a route's far end, with a gap in the middle that something else
		-- fills (the old fence, the gatehouse).
		local gap = dressing.caps[corridor.id]
		if gap then
			local length = corridor.line.length
			local centre = flat(Layout.pointAt(corridor.line, length))
			local run = heading(corridor.line, length)
			local across = Vector3.new(-run.Z, 0, run.X)
			local width = corridor.widthAt(length)
			for _, side in { -1, 1 } do
				Fences.hedge(
					folder,
					{ centre + across * side * gap, centre + across * side * width },
					waters
				)
			end
		end
	end

	-- A hedge round each ring clearing, open where a corridor comes in, with trees behind it.
	for _, ring in rings do
		local points: { Vector3 } = {}
		local count = 64
		for k = 0, count do
			local angle = k / count * math.pi * 2
			table.insert(
				points,
				ring.at + Vector3.new(math.cos(angle), 0, math.sin(angle)) * ring.radius
			)
		end
		local run: { Vector3 } = {}
		local runs: { { Vector3 } } = {}
		for _, point in points do
			if insideAny(list, point, INSIDE_MARGIN) then
				if #run > 1 then
					table.insert(runs, run)
				end
				run = {}
			else
				table.insert(run, point)
			end
		end
		if #run > 1 then
			-- The circle closes: join the last run to the first when both touch the seam.
			if #runs > 0 and not insideAny(list, points[1], INSIDE_MARGIN) then
				for _, point in runs[1] do
					table.insert(run, point)
				end
				runs[1] = run
			else
				table.insert(runs, run)
			end
		end
		for _, piece in runs do
			Fences.hedge(folder, piece, waters)
		end
		for k = 0, 39 do
			local angle = k / 40 * math.pi * 2 + pick:NextNumber(-0.04, 0.04)
			local out = Vector3.new(math.cos(angle), 0, math.sin(angle))
			plant(
				ring.at + out * (ring.radius + pick:NextNumber(6, 12)),
				if k % 3 == 0 then "Pine" else "Tree",
				1.2
			)
		end
	end
end

return Corridors
