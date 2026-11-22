--!strict
-- Everything on a dressing sheet that is not a route corridor: the town's streets and side
-- paths, the plaza's lamps and flower beds, water, the footbridge, arches and signposts, tree
-- clumps and belts, fences and the town hedge, the hamlet, the gatehouse and the sealed-road
-- bar, the lair's ancient tree and the shut shortcut (docs/plans/08_GREENWOOD_MAP.md sections 3
-- and 5). Looks only: no point the server checks is read or moved here.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Layout = require(ReplicatedStorage.shared.Layout)
local WorldTypes = require(ReplicatedStorage.shared.WorldTypes)

local Fences = require(script.Parent.Fences)
local Props = require(script.Parent.Props)
local Signs = require(script.Parent.Signs)
local Water = require(script.Parent.Water)

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
	local pond = placed(map, dressing.pond.at)
	table.insert(list, { points = { pond, pond }, half = dressing.pond.radius })
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
	for _, street in dressing.lanes do
		local points = placedAll(map, street.points)
		table.insert(streets, points)
		lane(town, points, street.width, Props.colour(street.colour), 0.42)
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
		Props.lamp(town, foot, towardStreet(foot, streets))
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
	Water.pond(
		town,
		placed(map, pond.at),
		pond.radius,
		Props.colour(pond.colour),
		placedAll(map, pond.jetty),
		pick
	)
	if #dressing.pools > 0 then
		Water.waterfall(
			town,
			placed(map, dressing.waterfall),
			placed(map, dressing.pools[1].at),
			Props.colour(dressing.water[1].colour)
		)
	end
	local bridge = dressing.footbridge
	Water.footbridge(
		town,
		placed(map, bridge.at),
		Props.facing(bridge.faces),
		bridge.length,
		bridge.width
	)

	-- Arches and signposts.
	for _, arch in dressing.arches do
		Signs.arch(town, placed(map, arch.at), arch.faces, arch.outside, arch.inside)
	end
	for _, sign in dressing.signs do
		Signs.signpost(town, placed(map, sign.at), sign.faces, sign.lines)
	end

	-- Trees: clumps one by one, belts in rows.
	local trees = folderIn(town, "Trees")
	for _, tree in dressing.trees do
		Props.tree(trees, placed(map, tree.at), tree.model, tree.scale or 1, pick)
	end
	for _, row in dressing.rows do
		local from, to = placed(map, row.from), placed(map, row.to)
		local length = (to - from).Magnitude
		local count = math.floor(length / row.step + 1e-6)
		for k = 0, count do
			local at = if length > 0 then from + (to - from).Unit * (k * row.step) else from
			Props.tree(trees, at, row.model, 1, pick)
		end
	end

	-- Fences, walls and the town hedge.
	for _, fence in dressing.fences do
		local points = placedAll(map, fence.points)
		Fences.fence(town, points, fence.style, waters)
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

	-- The breeder's yard: a hen coop and straw nests with eggs.
	local coop = placed(map, dressing.coop)
	local house = Props.part(
		town,
		Vector3.new(8, 5, 6),
		CFrame.new(coop + Vector3.yAxis * 2.5),
		Props.rgb(200, 150, 90)
	)
	house.CanCollide = true
	Props.part(
		town,
		Vector3.new(9, 1, 7),
		CFrame.new(coop + Vector3.yAxis * 5.5),
		Props.rgb(206, 88, 72)
	)
	for k = 1, 4 do
		local nest = coop + Vector3.new(-12 + k * 4, 0, 9)
		Props.lump(
			town,
			Vector3.new(3, 0.8, 3),
			nest + Vector3.yAxis * 0.3,
			Props.rgb(222, 196, 120)
		)
		Props.lump(
			town,
			Vector3.new(0.9, 1.2, 0.9),
			nest + Vector3.yAxis * 0.9,
			Props.rgb(250, 244, 230)
		)
	end
	-- The mentor's vegetable rows.
	local patchFrom, patchTo = placed(map, dressing.patch.from), placed(map, dressing.patch.to)
	for x = patchFrom.X, patchTo.X, 3.5 do
		local a, b = Vector3.new(x, 0, patchFrom.Z), Vector3.new(x, 0, patchTo.Z)
		Props.strip(town, a, b, 2, 0.6, 0.5, EARTH)
		for _, at in Props.resample({ a, b }, 2.2) do
			Props.lump(
				town,
				Vector3.new(1.2, 1, 1.2),
				at + Vector3.yAxis * 0.9,
				Props.rgb(96, 170, 80)
			)
		end
	end

	-- The Ring: an oval rail open at the front, with benches either side.
	local ringAt = map.buildings.ring
	local ringFaces = map.faces.ring
	if ringAt and ringFaces then
		local centre = Vector3.new(ringAt.x, 0, ringAt.z)
		local ahead = Props.facing(ringFaces)
		local across = Vector3.new(-ahead.Z, 0, ahead.X)
		local halfAcross, halfAhead = dressing.ring.width / 2 + 1, dressing.ring.depth / 2 + 1
		local rail: { Vector3 } = {}
		local count = 40
		for k = 0, count do
			local angle = k / count * math.pi * 2
			local at = centre
				+ across * math.sin(angle) * halfAcross
				+ ahead * math.cos(angle) * halfAhead
			-- The opening faces the keeper at the front.
			local front = (at - centre):Dot(ahead)
			local sideways = math.abs((at - centre):Dot(across))
			if front > 0 and sideways < dressing.ring.gap / 2 + 1 then
				if #rail > 1 then
					Fences.fence(town, rail, "Rustic", waters)
				end
				rail = {}
			else
				table.insert(rail, at)
			end
		end
		if #rail > 1 then
			Fences.fence(town, rail, "Rustic", waters)
		end
		for _, side in { -1, 1 } do
			local foot = centre + across * side * (halfAcross + 4)
			Props.bench(town, foot, -across * side)
		end
	end
end

return Scenery
