--!strict
-- The designed routes as places with edges (docs/plans/08_GREENWOOD_MAP.md sections 3 and 5):
-- the coloured ground of each stretch, and an edge down each side of every route and the lair
-- spur at the map sheet's half-widths, with trees just outside. Each side of each stretch is
-- built in the dressing sheet's edge style (a hedge, a cliff, a boulder bank: Edges.luau and
-- docs/plans/09_DUST_CANYON_MAP.md section 4c). Where two corridors meet, or a corridor meets the
-- town, the edges give way, so the union of all of them is one walkable space. This replaces the
-- random scatter for a biome that has a map sheet. The lanes themselves are in Lanes.luau.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Ground = require(ReplicatedStorage.shared.Ground)
local Layout = require(ReplicatedStorage.shared.Layout)
local Walk = require(ReplicatedStorage.shared.Walk)
local WorldTypes = require(ReplicatedStorage.shared.WorldTypes)

local Edges = require(script.Parent.Edges)
local Fences = require(script.Parent.Fences)
local Props = require(script.Parent.Props)
local Shapes = require(script.Parent.Shapes)

local Corridors = {}

-- One corridor: a lane's centre line and how wide its corridor is at a distance along it.
type Corridor = {
	id: string,
	line: Layout.RouteLine,
	points: { Vector3 },
	widthAt: (along: number) -> number,
	areaAt: (along: number) -> string?,
}

-- A run of edge in one style, with the outward normal and the distance along at each point.
type Run = {
	points: { Vector3 },
	normals: { Vector3 },
	alongs: { number },
	style: WorldTypes.EdgeStyle,
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
			points = flatAll(map.lairSpur),
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

-- The edges down both sides of every corridor, the edge across a route's far end, the edge round
-- a ring clearing (the lair), and trees just outside them all (none outside a cliff: the cliff is
-- the edge). Each side of each stretch takes its style from the sheet's `edges`; left out, a
-- hedge, as in Greenwood.
function Corridors.edges(
	parent: Instance,
	biome: WorldTypes.Biome,
	map: Layout.Map,
	dressing: WorldTypes.DressingSheet,
	waters: { Fences.Water },
	pick: Random,
	ground: Ground.Ground
)
	local folder = Instance.new("Folder")
	folder.Name = "Edges"
	folder.Parent = parent
	local list = corridors(biome, map)
	local space = Walk.space(biome, map, dressing)
	-- True where a hedge must not stand: stairs and ramps are open at their ends (their sides have
	-- cheeks), a ledge is open on purpose, and a tier's wall at its foot is wall enough.
	local function openByDesign(x: number, z: number): boolean
		return Ground.linkAt(ground, x, z, 3) ~= nil
			or Ground.ledgeAt(ground, x, z, 1.5) ~= nil
			or Ground.atFoot(ground, x, z, 3)
	end
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
	-- Water flats (the sea, a harbour) take no trees.
	local seas: { { min: Vector3, max: Vector3 } } = {}
	local flats: { WorldTypes.DressFlat } = dressing.flats or {}
	for _, patch in flats do
		if patch.water then
			local a = origin + Vector3.new(patch.from.x, 0, patch.from.z)
			local b = origin + Vector3.new(patch.to.x, 0, patch.to.z)
			table.insert(seas, { min = a:Min(b), max = a:Max(b) })
		end
	end
	local function atSea(at: Vector3): boolean
		for _, sea in seas do
			if
				at.X >= sea.min.X
				and at.X <= sea.max.X
				and at.Z >= sea.min.Z
				and at.Z <= sea.max.Z
			then
				return true
			end
		end
		return false
	end

	-- A tree outside an edge, if the spot is clear of lanes, water, town and clearings.
	local function plant(at: Vector3, model: string, scale: number)
		-- A biome with a fill has solid woods past its edges (Fill.luau): no single trees.
		if dressing.fill then
			return
		end
		if
			insideAny(list, at, -2)
			or inTown(map, at, 4)
			or wet(waters, at, 3)
			or inRing(at, 2)
			or atSea(at)
		then
			return
		end
		Shapes.plant(folder, at, model, scale, pick)
	end
	-- The stretch (or, on the spur, the lair) a distance along a corridor belongs to.
	local function keyAt(corridor: Corridor, along: number): string
		return corridor.areaAt(along) or corridor.id
	end
	local function treeFor(corridor: Corridor, along: number): (string, number)
		local special = dressing.corridorTrees[keyAt(corridor, along)]
		if special then
			return special.model, special.scale
		end
		return if pick:NextNumber() < 0.6 then "Tree" else "Pine", 1
	end
	local styles = dressing.edges
	local function styleOf(key: string, side: number): WorldTypes.EdgeStyle
		local edge = if styles then styles[key] else nil
		if edge == nil then
			return "Hedge"
		end
		local chosen: WorldTypes.EdgeStyle = if side < 0 then edge.left else edge.right
		return chosen
	end

	for _, corridor in list do
		for _, side in { -1, 1 } do
			local runs: { Run } = {}
			local current: Run? = nil
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
					and Walk.depth(space, point.X, point.Z, false, nil) < INSIDE_MARGIN
					and not inRing(point, 1)
					and not openByDesign(point.X, point.Z)
				local style: WorldTypes.EdgeStyle = styleOf(keyAt(corridor, along), side)
				if keep then
					local into: Run
					local open = current
					if open and open.style == style then
						into = open
					elseif open then
						-- The style changes here: the next run starts where this one ends.
						table.insert(runs, open)
						local last = #open.points
						into = {
							points = { open.points[last] },
							normals = { open.normals[last] },
							alongs = { open.alongs[last] },
							style = style,
						}
					else
						into = { points = {}, normals = {}, alongs = {}, style = style }
					end
					current = into
					table.insert(into.points, point)
					table.insert(into.normals, normal)
					table.insert(into.alongs, along)
				elseif current then
					table.insert(runs, current)
					current = nil
				end
				if along >= corridor.line.length then
					break
				end
				along = math.min(along + EDGE_STEP, corridor.line.length)
			end
			if current then
				table.insert(runs, current)
			end
			for _, piece in runs do
				-- An edge that starts at the town is joined to the town's own edge.
				local run = piece.points
				local first = run[1]
				local half = map.hub.size / 2
				local dx, dz = first.X - origin.X, first.Z - origin.Z
				if math.abs(dz) < half and math.abs(dx) > half and math.abs(dx) - half < 25 then
					table.insert(run, 1, Vector3.new(origin.X + math.sign(dx) * half, 0, first.Z))
				elseif math.abs(dx) < half and math.abs(dz) > half and math.abs(dz) - half < 25 then
					table.insert(run, 1, Vector3.new(first.X, 0, origin.Z + math.sign(dz) * half))
				end
				Edges.run(folder, run, piece.style, waters, pick, { outward = side })
				if piece.style ~= "Cliff" and piece.style ~= "SeaCliff" then
					local normals = piece.normals
					local nextTree = pick:NextNumber(0, 8)
					local walked = 0
					for k = 2, #normals do
						local point = run[k + (#run - #normals)]
						local before = run[k - 1 + (#run - #normals)]
						walked += (point - before).Magnitude
						if walked >= nextTree then
							nextTree = walked + pick:NextNumber(12, 16)
							local model, scale = treeFor(corridor, piece.alongs[k])
							plant(point + normals[k] * pick:NextNumber(4, 10), model, scale)
						end
					end
				end
			end
		end

		-- The edge across a route's far end, in the style of the last stretch's left side, with a
		-- gap in the middle that something else fills (the old fence, the gatehouse).
		local gap = dressing.caps[corridor.id]
		if gap then
			local length = corridor.line.length
			local centre = flat(Layout.pointAt(corridor.line, length))
			local run = heading(corridor.line, length)
			local across = Vector3.new(-run.Z, 0, run.X)
			local width = corridor.widthAt(length)
			local style: WorldTypes.EdgeStyle = styleOf(keyAt(corridor, length), -1)
			for _, side in { -1, 1 } do
				Edges.run(
					folder,
					{ centre + across * side * gap, centre + across * side * width },
					style,
					waters,
					pick,
					{ outward = -side } -- its outside is beyond the route's end
				)
			end
		end
	end

	-- An edge round each room of the map sheet (a pocket, a field, a dead end), open where a lane
	-- or another room is, at a link or a ledge, and at a tier's foot.
	for _, room in space.sheetRooms do
		local runs: { { Vector3 } } = {}
		local run: { Vector3 } = {}
		local samples = Ground.outline(room, EDGE_STEP)
		local allKept = true
		for _, sample in samples do
			local point = Vector3.new(sample.x, 0, sample.z)
			local keep = not inTown(map, point, 2)
				and Walk.depth(space, sample.x, sample.z, false, room) < INSIDE_MARGIN
				and not inRing(point, 1)
				and not openByDesign(sample.x, sample.z)
			if keep then
				table.insert(run, point)
			else
				allKept = false
				if #run > 1 then
					table.insert(runs, run)
				end
				run = {}
			end
		end
		if allKept and #run > 1 then
			table.insert(run, run[1]) -- a pocket with no way in closes on itself
		end
		if #run > 1 then
			-- The loop starts mid-edge: join the last run to the first when both touch the seam.
			local first = samples[1]
			local last = samples[#samples]
			local seam = #runs > 0
				and Walk.depth(space, first.x, first.z, false, room) < INSIDE_MARGIN
				and Walk.depth(space, last.x, last.z, false, room) < INSIDE_MARGIN
			if seam and not openByDesign(first.x, first.z) and not openByDesign(last.x, last.z) then
				for _, point in runs[1] do
					table.insert(run, point)
				end
				runs[1] = run
			else
				table.insert(runs, run)
			end
		end
		for _, piece in runs do
			Edges.run(folder, piece, "Hedge", waters, pick, { outward = 1 })
		end
	end

	-- An edge round each ring clearing, open where a corridor comes in, with trees behind it.
	local ringStyle: WorldTypes.EdgeStyle = styleOf(biome.lair.id, -1)
	local ringTrees = dressing.corridorTrees[biome.lair.id]
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
			-- Walking round with the angle, the outside is on the right.
			Edges.run(folder, piece, ringStyle, waters, pick, { outward = -1 })
		end
		if ringStyle ~= "Cliff" and ringStyle ~= "SeaCliff" then
			for k = 0, 39 do
				local angle = k / 40 * math.pi * 2 + pick:NextNumber(-0.04, 0.04)
				local out = Vector3.new(math.cos(angle), 0, math.sin(angle))
				plant(
					ring.at + out * (ring.radius + pick:NextNumber(6, 12)),
					if ringTrees then ringTrees.model elseif k % 3 == 0 then "Pine" else "Tree",
					if ringTrees then ringTrees.scale else 1.2
				)
			end
		end
	end
end

return Corridors
