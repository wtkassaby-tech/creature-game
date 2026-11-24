--!strict
-- Everything on a dressing sheet that is not a route corridor: the town's streets and side
-- paths, the plaza's lamps and flower beds, water, the footbridge, arches and signposts, tree
-- clumps and belts, fences and the town hedge, the hamlet, the gatehouse and the sealed-road
-- bar, the lair's ancient tree and the shut shortcut (docs/plans/08_GREENWOOD_MAP.md sections 3
-- and 5). Looks only: no point the server checks is read or moved here.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Layout = require(ReplicatedStorage.shared.Layout)
local WorldTypes = require(ReplicatedStorage.shared.WorldTypes)

local Edges = require(script.Parent.Edges)
local Fences = require(script.Parent.Fences)
local Lanes = require(script.Parent.Lanes)
local Props = require(script.Parent.Props)
local Shapes = require(script.Parent.Shapes)
local Signs = require(script.Parent.Signs)
local Water = require(script.Parent.Water)
local Yards = require(script.Parent.Yards)

local Scenery = {}

local BLOOMS: { Color3 } = {
	Props.rgb(250, 220, 90),
	Props.rgb(240, 130, 150),
	Props.rgb(250, 250, 250),
	Props.rgb(170, 140, 240),
}
local EARTH = Props.rgb(110, 84, 60)
local TIMBER = Props.rgb(120, 84, 56)

-- A sheet point in the world, on the ground.
local function placed(map: Layout.Map, point: WorldTypes.SheetPoint): Vector3
	return Vector3.new(map.hub.x + point.x, 0, map.hub.z + point.z)
end

local function placedAll(map: Layout.Map, points: { WorldTypes.SheetPoint }): { Vector3 }
	local out: { Vector3 } = {}
	for _, point in points do
		table.insert(out, placed(map, point))
	end
	return out
end

local function folderIn(parent: Instance, name: string): Folder
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent
	return folder
end

-- The water a hedge or fence must stop short of: the streams, and the pond as a short line.
function Scenery.waters(map: Layout.Map, dressing: WorldTypes.DressingSheet): { Fences.Water }
	local list: { Fences.Water } = {}
	for _, stream in dressing.water do
		table.insert(list, { points = placedAll(map, stream.points), half = stream.width / 2 })
	end
	if dressing.pond then
		local pond = placed(map, dressing.pond.at)
		table.insert(list, { points = { pond, pond }, half = dressing.pond.radius })
	end
	for _, pool in dressing.pools do
		local at = placed(map, pool.at)
		table.insert(list, { points = { at, at }, half = pool.radius })
	end
	return list
end

-- A town street, side path or the shortcut: a flat strip with a disc at each joint.
local function lane(
	parent: Instance,
	points: { Vector3 },
	width: number,
	colour: Color3,
	top: number
)
	for index, at in points do
		local disc = Props.disc(parent, at, width, 0.4, top, colour)
		disc.CanCollide = true
		local after = points[index + 1]
		if after then
			local slab = Props.strip(parent, at, after, width, 0.4, top, colour)
			if slab then
				slab.Name = "Street"
				slab.CanCollide = true
			end
		end
	end
end

-- A flower bed: a mound of earth with a ring of blooms and a green middle.
local function bed(parent: Instance, at: Vector3, pick: Random)
	Props.lump(parent, Vector3.new(6, 1.4, 4), at + Vector3.yAxis * 0.5, EARTH)
	local colour = BLOOMS[pick:NextInteger(1, #BLOOMS)]
	for bloom = 1, 6 do
		local turn = bloom / 6 * math.pi * 2
		Props.lump(
			parent,
			Vector3.one * 1.1,
			at + Vector3.new(math.cos(turn) * 2, 1.3, math.sin(turn) * 1.2),
			colour
		)
	end
	Props.lump(parent, Vector3.one * 1.4, at + Vector3.yAxis * 1.6, Props.rgb(84, 160, 78))
end

-- The direction from `at` to the nearest point of any town street, for turning a lamp to the
-- road it lights.
local function towardStreet(at: Vector3, streets: { { Vector3 } }): Vector3
	local best, bestOff = Vector3.zAxis, math.huge
	for _, points in streets do
		for index = 1, #points - 1 do
			local a, b = points[index], points[index + 1]
			local run = b - a
			local length = run.Magnitude
			if length > 1e-3 then
				local t = math.clamp((at - a):Dot(run.Unit), 0, length)
				local nearest = a + run.Unit * t
				local off = (nearest - at).Magnitude
				if off < bestOff and off > 0.5 then
					best, bestOff = (nearest - at).Unit, off
				end
			end
		end
	end
	return best
end

-- The point `along` studs down a line of points.
local function pointAlong(points: { Vector3 }, along: number): Vector3
	local remaining = along
	for index = 1, #points - 1 do
		local a, b = points[index], points[index + 1]
		local length = (b - a).Magnitude
		if remaining <= length and length > 1e-6 then
			return a:Lerp(b, remaining / length)
		end
		remaining -= length
	end
	return points[#points]
end

-- The direction square to a fence that points away from the nearest route, for a broken bridge
-- across a route's end: out over the drop.
local function awayFromRoutes(points: { Vector3 }, routes: { { Vector3 } }): Vector3?
	local run = points[#points] - points[1]
	if #points < 2 or run.Magnitude < 1e-3 then
		return nil
	end
	local middle = (points[1] + points[#points]) / 2
	local normal = Vector3.new(-run.Unit.Z, 0, run.Unit.X)
	local behind: Vector3? = nil
	local bestOff = math.huge
	for _, line in routes do
		local along, off = Props.nearest(line, middle)
		if off < bestOff then
			bestOff = off
			behind = pointAlong(line, math.max(along - 10, 0))
		end
	end
	if behind == nil then
		return nil
	end
	return if (middle - behind):Dot(normal) >= 0 then normal else -normal
end

-- Builds the dressing sheet's town and route scenery under `parent`.
function Scenery.build(
	parent: Instance,
	biome: WorldTypes.Biome,
	map: Layout.Map,
	dressing: WorldTypes.DressingSheet,
	waters: { Fences.Water },
	pick: Random
)
	local town = folderIn(parent, "Scenery")

	-- Streets, side paths, the jetty and the shut shortcut.
	local streets: { { Vector3 } } = {}
	for index, street in dressing.lanes do
		local points = placedAll(map, street.points)
		table.insert(streets, points)
		if street.deck then
			Lanes.deck(town, points, street.width, Props.colour(street.colour))
		else
			-- Each street a hundredth of a stud above the one before, so where two of different
			-- colours meet, one shows rather than both flickering (a pinwheel at the Westcut).
			-- The first is the main street: the side streets sit on it.
			local top = 0.42 + math.min(index - 1, 20) * 0.01
			lane(town, points, street.width, Props.colour(street.colour), top)
		end
	end
	-- The mown footpath round the meadow's grass, with rustic rails each side that stop short
	-- of the route lanes so they never fence one off.
	local routeLines: { { Vector3 } } = {}
	for _, route in biome.routes do
		local line = map.routes[route.id]
		if line then
			local points: { Vector3 } = {}
			for _, point in line.points do
				table.insert(points, Vector3.new(point.x, 0, point.z))
			end
			table.insert(routeLines, points)
		end
	end
	for _, path in dressing.footpaths do
		local points = placedAll(map, path.points)
		lane(town, points, path.width, Props.colour(path.colour), 0.38)
		local samples = Props.resample(points, 1)
		for _, side in { -1, 1 } do
			local rail: { Vector3 } = {}
			local function close()
				if #rail > 1 then
					Fences.fence(town, rail, "Rustic", waters)
				end
				rail = {}
			end
			for k = 1, #samples - 1 do
				local run = samples[k + 1] - samples[k]
				if run.Magnitude > 1e-3 then
					local post = samples[k]
						+ Vector3.new(-run.Unit.Z, 0, run.Unit.X)
							* (path.width / 2 + 1.5)
							* side
					local clear = true
					for _, routePoints in routeLines do
						local _, off = Props.nearest(routePoints, post)
						if off < dressing.laneWidth / 2 + 2 then
							clear = false
						end
					end
					if clear then
						table.insert(rail, post)
					else
						close()
					end
				end
			end
			close()
		end
	end
	for _, stones in dressing.stones do
		Water.stones(town, placed(map, stones.from), placed(map, stones.to), pick)
	end

	-- The plaza's flower beds, the street lamps and the flower beds by the doors.
	for _, at in dressing.lamps do
		local foot = placed(map, at)
		Props.lamp(town, foot, towardStreet(foot, streets), dressing.lampModel)
	end
	for _, at in dressing.beds do
		bed(town, placed(map, at), pick)
	end

	-- Water.
	for _, stream in dressing.water do
		Water.stream(
			town,
			placedAll(map, stream.points),
			stream.width,
			Props.colour(stream.colour),
			pick
		)
	end
	for _, pool in dressing.pools do
		Water.pool(town, placed(map, pool.at), pool.radius, Props.colour(pool.colour))
	end
	local pond = dressing.pond
	if pond then
		Water.pond(
			town,
			placed(map, pond.at),
			pond.radius,
			Props.colour(pond.colour),
			placedAll(map, pond.jetty),
			pick
		)
	end
	local fall, spring = dressing.waterfall, dressing.pools[1]
	if fall and spring then
		local stream = dressing.water[1]
		Water.waterfall(
			town,
			placed(map, fall),
			placed(map, spring.at),
			Props.colour(if stream then stream.colour else spring.colour)
		)
	end
	-- Falls where water drops off a tier (the brook off the terrace).
	local falls: { { at: WorldTypes.SheetPoint, towards: WorldTypes.SheetPoint } } = dressing.falls
		or {}
	for _, drop in falls do
		local stream = dressing.water[1]
		Water.waterfall(
			town,
			placed(map, drop.at),
			placed(map, drop.towards),
			Props.colour(if stream then stream.colour else { 110, 182, 214 })
		)
	end
	local bridge = dressing.footbridge
	if bridge then
		Water.footbridge(
			town,
			placed(map, bridge.at),
			Props.facing(bridge.faces),
			bridge.length,
			bridge.width
		)
	end
	-- Flat ground of another colour (a gorge floor, the sea), each a hair above the last and
	-- under the corridors' own ground. Nothing stands on them or bumps into them.
	local flats: { WorldTypes.DressFlat } = dressing.flats or {}
	for index, flat in flats do
		local a, b = placed(map, flat.from), placed(map, flat.to)
		local size = (a - b):Abs()
		local slab = Props.part(
			town,
			Vector3.new(size.X, 0.1, size.Z),
			CFrame.new((a.X + b.X) / 2, 0.06 + 0.002 * index - 0.05, (a.Z + b.Z) / 2),
			Props.colour(flat.colour)
		)
		slab.Name = if flat.water then "WaterFlat" else "Flat"
		slab.CanQuery = false
		slab.CanTouch = false
		if flat.water then
			slab.Reflectance = 0.1
		end
	end

	-- Arches and signposts.
	for _, arch in dressing.arches do
		Signs.arch(town, placed(map, arch.at), arch.faces, arch.outside, arch.inside, arch.model)
	end
	for _, sign in dressing.signs do
		Signs.signpost(town, placed(map, sign.at), sign.faces, sign.lines)
	end

	-- Trees: clumps one by one, belts in rows.
	local trees = folderIn(town, "Trees")
	for _, tree in dressing.trees do
		Shapes.plant(trees, placed(map, tree.at), tree.model, tree.scale or 1, pick)
	end
	for _, row in dressing.rows do
		local from, to = placed(map, row.from), placed(map, row.to)
		local length = (to - from).Magnitude
		local count = math.floor(length / row.step + 1e-6)
		for k = 0, count do
			local at = if length > 0 then from + (to - from).Unit * (k * row.step) else from
			Shapes.plant(trees, at, row.model, 1, pick)
		end
	end

	-- Fences, walls and the town hedge.
	for _, fence in dressing.fences do
		local points = placedAll(map, fence.points)
		local away = if fence.across and fence.style == "Rope"
			then awayFromRoutes(points, routeLines)
			else nil
		Edges.fence(town, points, fence.style, waters, pick, away)
		if fence.style == "Rustic" and fence.across and #points >= 2 then
			-- The broken stile in the middle of the old fence: two steps, one of them fallen.
			local middle = (points[1] + points[#points]) / 2
			local run = (points[#points] - points[1]).Unit
			local out = Vector3.new(-run.Z, 0, run.X)
			Props.part(
				town,
				Vector3.new(3, 1, 1.6),
				CFrame.lookAt(middle + out * 1.4 + Vector3.yAxis * 0.5, middle + out * 3),
				TIMBER
			)
			Props.part(
				town,
				Vector3.new(3, 1, 1.6),
				CFrame.lookAt(middle - out * 1.6 + Vector3.yAxis * 0.4, middle - out * 3)
					* CFrame.Angles(0, 0, math.rad(25)),
				TIMBER
			)
		end
	end
	local hedges = folderIn(town, "TownHedge")
	for _, run in dressing.hedges do
		Fences.hedge(hedges, placedAll(map, run), waters)
	end
	-- Cliffs, dunes and sea walls that are not corridor edges, centred on their lines with their
	-- faces to the town.
	local walls = dressing.walls
	if walls then
		local folder = folderIn(town, "Walls")
		local centre = Vector3.new(map.hub.x, 0, map.hub.z)
		for _, wall in walls do
			Edges.run(
				folder,
				placedAll(map, wall.points),
				wall.style,
				waters,
				pick,
				{ towards = centre, tall = wall.tall }
			)
		end
	end

	-- The breeder's coop, the garden rows and the Circuit's rail.
	Yards.build(town, biome, map, dressing, waters)
end

return Scenery
