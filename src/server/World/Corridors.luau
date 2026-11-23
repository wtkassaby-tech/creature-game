--!strict
-- The designed routes as places with edges (docs/plans/08_GREENWOOD_MAP.md sections 3 and 5):
-- the coloured ground of each stretch, and an edge down each side of every route and the lair
-- spur at the map sheet's half-widths, with trees just outside. Each side of each stretch is
-- built in the dressing sheet's edge style (a hedge, a cliff, a boulder bank: Edges.luau and
-- docs/plans/09_DUST_CANYON_MAP.md section 4c). Where two corridors meet, or a corridor meets the
-- town, the edges give way, so the union of all of them is one walkable space. This replaces the
-- random scatter for a biome that has a map sheet. The lanes themselves are in Lanes.luau.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EdgeTrace = require(ReplicatedStorage.shared.EdgeTrace)
local Ground = require(ReplicatedStorage.shared.Ground)
local Layout = require(ReplicatedStorage.shared.Layout)
local PropModels = require(ReplicatedStorage.content.PropModels)
local WorldTypes = require(ReplicatedStorage.shared.WorldTypes)

local Edges = require(script.Parent.Edges)
local Fences = require(script.Parent.Fences)
local Props = require(script.Parent.Props)
local Shapes = require(script.Parent.Shapes)

local Corridors = {}

type Corridor = EdgeTrace.Corridor

local TREE_SIZE_VARY = 0.06 -- each tree, hedge bush and fill piece is up to this much bigger or smaller
local BUSH_TREE_SCALE = 0.32 -- the painted Bush stands 15 to 24 studs at scale 1: this makes a 5 to 8 stud shrub

-- A run of edge in one style, with the outward normal and the distance along at each point.
type Run = {
	points: { Vector3 },
	normals: { Vector3 },
	alongs: { number },
	style: WorldTypes.EdgeStyle,
}

local function flat(point: Layout.Point): Vector3
	return Vector3.new(point.x, 0, point.z)
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
	-- Where each edge stands is worked out as plain numbers (EdgeTrace), so the tests can check it:
	-- it leaves a gap round every tamer, person and prompt.
	local trace = EdgeTrace.new(biome, map, dressing, ground)
	local list = trace.corridors
	local space = trace.space
	local origin = Vector3.new(map.hub.x, 0, map.hub.z)
	local rings: { { at: Vector3, radius: number } } = {}
	for _, clearing in dressing.clearings do
		local entry =
			{ at = origin + Vector3.new(clearing.at.x, 0, clearing.at.z), radius = clearing.radius }
		if clearing.ring then
			table.insert(rings, entry)
		end
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
			EdgeTrace.insideAny(trace, at.X, at.Z, -2)
			or EdgeTrace.inTown(map, at.X, at.Z, 4)
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
	-- The default woodland mix where a stretch names no tree: oak-like Trees and Pines, with Birch
	-- and low Bush clumps where those painted models exist, so a route does not repeat one tree.
	-- Each tree is a touch bigger or smaller (about 6%) from the seeded `pick`, never math.random.
	local function treeFor(corridor: Corridor, along: number): (string, number)
		local special = dressing.corridorTrees[keyAt(corridor, along)]
		local jitter = pick:NextNumber(1 - TREE_SIZE_VARY, 1 + TREE_SIZE_VARY)
		if special then
			return special.model, special.scale * jitter
		end
		local roll = pick:NextNumber()
		if roll < 0.4 then
			return "Tree", jitter
		elseif roll < 0.62 then
			return "Pine", jitter
		elseif roll < 0.82 and PropModels.Birch then
			return "Birch", jitter
		elseif PropModels.Bush then
			return "Bush", BUSH_TREE_SCALE * jitter -- a clump of shrub, not a 20-stud tree
		end
		return "Tree", jitter
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
			for _, sample in EdgeTrace.side(trace, corridor, side) do
				local along = sample.along
				local point = Vector3.new(sample.x, 0, sample.z)
				local normal = Vector3.new(sample.nx, 0, sample.nz)
				local keep = sample.keep
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
			local runX, runZ = EdgeTrace.heading(corridor.line, length)
			local across = Vector3.new(-runZ, 0, runX)
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
		local samples = EdgeTrace.room(trace, room)
		local allKept = true
		for _, sample in samples do
			local point = Vector3.new(sample.x, 0, sample.z)
			if sample.keep then
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
			if #runs > 0 and first.keep and last.keep then
				for _, point in runs[1] do
					table.insert(run, point)
				end
				runs[1] = run
			else
				table.insert(runs, run)
			end
		end
		for _, piece in runs do
			-- The biome's own room edge: hedges in Greenwood, boulders in the canyon, rocks
			-- by the sea (rooms in the desert were ringed with green hedges before).
			Edges.run(folder, piece, dressing.roomEdge or "Hedge", waters, pick, { outward = 1 })
		end
	end

	-- An edge round each ring clearing, open where a corridor comes in, with trees behind it.
	local ringStyle: WorldTypes.EdgeStyle = styleOf(biome.lair.id, -1)
	local ringTrees = dressing.corridorTrees[biome.lair.id]
	for _, ring in rings do
		-- Where the circle goes is worked out as plain numbers too (EdgeTrace.ring).
		local samples =
			EdgeTrace.ring(trace, { x = ring.at.X, z = ring.at.Z, radius = ring.radius })
		local run: { Vector3 } = {}
		local runs: { { Vector3 } } = {}
		for _, sample in samples do
			if not sample.keep then
				if #run > 1 then
					table.insert(runs, run)
				end
				run = {}
			else
				table.insert(run, Vector3.new(sample.x, 0, sample.z))
			end
		end
		if #run > 1 then
			-- The circle closes: join the last run to the first when both touch the seam.
			if #runs > 0 and samples[1].keep then
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
					(if ringTrees then ringTrees.scale else 1.2)
						* pick:NextNumber(1 - TREE_SIZE_VARY, 1 + TREE_SIZE_VARY)
				)
			end
		end
	end
end

return Corridors
