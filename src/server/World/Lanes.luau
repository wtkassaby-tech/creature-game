--!strict
-- The lanes of a designed biome's routes and lair spur (docs/plans/08_GREENWOOD_MAP.md section
-- 4, step 10): 14 studs wide with a disc of the same width at every joint to hide the seams,
-- coloured by stretch (dirt, or stone through the gatehouse hamlet), and left out where a lane
-- runs through a patch of long grass, which grows over it. Looks and footing only.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Layout = require(ReplicatedStorage.shared.Layout)
local WorldConfig = require(ReplicatedStorage.config.WorldConfig)
local WorldTypes = require(ReplicatedStorage.shared.WorldTypes)

local Props = require(script.Parent.Props)

local Lanes = {}

local function flat(point: Layout.Point): Vector3
	return Vector3.new(point.x, 0, point.z)
end

-- The lane of every route and the spur: 14 wide, a disc at every joint, coloured by stretch,
-- and left out where the lane runs through a patch of long grass (the grass grows over it).
function Lanes.build(
	parent: Instance,
	biome: WorldTypes.Biome,
	map: Layout.Map,
	dressing: WorldTypes.DressingSheet
)
	local width = dressing.laneWidth
	local grass: { Vector3 } = {}
	for _, route in biome.routes do
		for _, area in route.areas do
			local patch = map.places[Layout.grassId(area.id)]
			if patch then
				table.insert(grass, flat(patch))
			end
		end
	end
	local function colourAt(routeId: string, along: number): Color3
		for _, surface in dressing.laneSurfaces do
			if surface.route == routeId and along >= surface.from and along <= surface.to then
				return Props.colour(surface.colour)
			end
		end
		return Props.colour(dressing.laneColour)
	end
	local function lay(folder: Instance, line: Layout.RouteLine, routeId: string)
		-- Pieces of lane of one colour with no grass over them, as lists of distances along.
		local index = 0
		local runStart: number? = nil
		local runColour = colourAt(routeId, 0)
		local function finish(from: number, to: number, colour: Color3)
			if to - from < 0.5 then
				return
			end
			local points: { Vector3 } = { flat(Layout.pointAt(line, from)) }
			local covered = 0
			for k = 1, #line.points - 1 do
				covered += Layout.distance(line.points[k], line.points[k + 1])
				if covered > from and covered < to then
					table.insert(points, flat(line.points[k + 1]))
				end
			end
			table.insert(points, flat(Layout.pointAt(line, to)))
			for k, at in points do
				local disc = Props.disc(folder, at, width, 0.4, 0.4, colour)
				disc.CanCollide = true
				local after = points[k + 1]
				if after then
					index += 1
					local slab = Props.strip(folder, at, after, width, 0.4, 0.4, colour)
					if slab then
						slab.Name = `Path{index}`
						slab.CanCollide = true
					end
				end
			end
		end
		local step = 2
		local along = 0
		while along <= line.length do
			local at = flat(Layout.pointAt(line, along))
			local covered = false
			for _, centre in grass do
				if (at - centre).Magnitude < WorldConfig.GRASS_RADIUS then
					covered = true
				end
			end
			local colour = colourAt(routeId, along)
			if covered or colour ~= runColour then
				if runStart then
					finish(runStart, along, runColour)
				end
				runStart = if covered then nil else along
				runColour = colour
			elseif runStart == nil then
				runStart = along
			end
			if along >= line.length then
				break
			end
			along = math.min(along + step, line.length)
		end
		if runStart then
			finish(runStart, line.length, runColour)
		end
	end
	for _, route in biome.routes do
		local line = map.routes[route.id]
		if line then
			local folder = parent:FindFirstChild(route.id) or parent
			lay(folder, line, route.id)
		end
	end
	if #map.lairSpur >= 2 then
		local length = 0
		for k = 1, #map.lairSpur - 1 do
			length += Layout.distance(map.lairSpur[k], map.lairSpur[k + 1])
		end
		local folder = Instance.new("Folder")
		folder.Name = "LairSpur"
		folder.Parent = parent
		lay(
			folder,
			{ id = biome.lair.id, points = map.lairSpur, length = length, side = 0 },
			biome.lair.id
		)
	end
end

return Lanes
