--!strict
-- The lanes of a designed biome's routes and lair spur (docs/plans/08_GREENWOOD_MAP.md section
-- 4, step 10): 14 studs wide with a disc of the same width at every joint to hide the seams,
-- coloured by stretch (dirt, or stone through the gatehouse hamlet), and left out where a lane
-- runs through a patch of long grass, which grows over it. Looks and footing only. A stretch of
-- lane, or a town lane, can be a deck instead: planks on posts, raised a stud, with a ramp at each
-- end (docs/plans/09_DUST_CANYON_MAP.md section 4c; Tide Flats' quay and boardwalk).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Layout = require(ReplicatedStorage.shared.Layout)
local WorldConfig = require(ReplicatedStorage.config.WorldConfig)
local WorldTypes = require(ReplicatedStorage.shared.WorldTypes)

local Markers = require(script.Parent.Markers)
local Props = require(script.Parent.Props)

local ROUTE_TOP = 0.37 -- route lanes; town streets are 0.4
local Lanes = {}

local DECK_TOP = 1 -- a deck's top, against 0.42 for a lane on the ground
local PLANK = 1.2 -- studs along the deck for each plank, with a gap of 0.3
local PLANK_PITCH = 1.5
local POST_STEP = 8
local RAMP = 5

local function flat(point: Layout.Point): Vector3
	return Vector3.new(point.x, 0, point.z)
end

local function shade(colour: Color3, by: number): Color3
	return Color3.fromRGB(
		math.clamp(math.floor(colour.R * 255 + 0.5) + by, 0, 255),
		math.clamp(math.floor(colour.G * 255 + 0.5) + by, 0, 255),
		math.clamp(math.floor(colour.B * 255 + 0.5) + by, 0, 255)
	)
end

local function ground(piece: BasePart, name: string)
	piece.Name = name
	piece.CanCollide = true
	Markers.addGround(piece)
end

-- A deck along a line of points on the ground, `width` across: an unseen walking surface at
-- DECK_TOP, planks across it in the colour alternating lighter and darker, posts under both
-- edges every 8 studs, and a ramp down to the ground at each end. People stand on it.
function Lanes.deck(parent: Instance, points: { Vector3 }, width: number, colour: Color3)
	local folder = Instance.new("Folder")
	folder.Name = "Deck"
	folder.Parent = parent
	local total = 0
	for index = 1, #points - 1 do
		total += (points[index + 1] - points[index]).Magnitude
	end
	local ramps = total > RAMP * 2 + 2
	local covered = 0
	for index = 1, #points - 1 do
		local a, b = points[index], points[index + 1]
		local run = Vector3.new(b.X - a.X, 0, b.Z - a.Z)
		local length = run.Magnitude
		if length < 0.2 then
			continue
		end
		local unit = run.Unit
		-- The flat part of this leg, leaving room for the ramps at the line's two ends.
		local from = if ramps then math.max(0, RAMP - covered) else 0
		local to = if ramps then math.min(length, total - RAMP - covered) else length
		if to - from > 0.1 then
			local start, finish = a + unit * from, a + unit * to
			local middle = (start + finish) / 2 + Vector3.yAxis * (DECK_TOP - 0.2)
			local surface = Props.part(
				folder,
				Vector3.new(width, 0.4, to - from),
				CFrame.lookAt(middle, middle + unit),
				colour
			)
			surface.Transparency = 1
			ground(surface, "Deck")
			for k = 0, math.floor((to - from) / PLANK_PITCH) - 1 do
				local at = start
					+ unit * (k * PLANK_PITCH + PLANK / 2)
					+ Vector3.yAxis * (DECK_TOP - 0.15)
				local plank = Props.part(
					folder,
					Vector3.new(width, 0.3, PLANK),
					CFrame.lookAt(at, at + unit),
					shade(colour, if k % 2 == 0 then 10 else -10)
				)
				plank.CanQuery = false
			end
			local across = Vector3.new(-unit.Z, 0, unit.X) * (width / 2 - 0.4)
			for _, at in Props.resample({ start, finish }, POST_STEP) do
				for _, side in { -1, 1 } do
					Props.part(
						folder,
						Vector3.new(0.8, 2, 0.8),
						CFrame.new(at + across * side),
						shade(colour, -30)
					)
				end
			end
		end
		-- A ramp down to the ground where the line starts or ends inside this leg.
		local ends: { { at: number, rise: number } } =
			{ { at = RAMP - covered, rise = 1 }, { at = total - RAMP - covered, rise = -1 } }
		for _, ending in ends do
			if ramps and ending.at >= 0 and ending.at <= length then
				local low = a + unit * (ending.at - RAMP * ending.rise)
				local high = a + unit * ending.at
				local centre = (low + high) / 2 + Vector3.yAxis * DECK_TOP / 2
				local ramp = Instance.new("WedgePart")
				ramp.Anchored = true
				ramp.Size = Vector3.new(width, DECK_TOP, RAMP)
				-- A wedge's tall face is its back (+Z), so its front looks away from the deck.
				ramp.CFrame = CFrame.lookAt(centre, centre - (high - low).Unit)
				ramp.Color = colour
				ramp.Material = Enum.Material.SmoothPlastic
				ramp.Parent = folder
				ground(ramp, "DeckRamp")
			end
		end
		if index < #points - 1 then
			ground(Props.disc(folder, b, width, 0.4, DECK_TOP, colour), "Deck")
		end
		covered += length
	end
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
	local function surfaceAt(routeId: string, along: number): (Color3, boolean)
		for _, surface in dressing.laneSurfaces do
			if surface.route == routeId and along >= surface.from and along <= surface.to then
				return Props.colour(surface.colour), surface.deck == true
			end
		end
		return Props.colour(dressing.laneColour), false
	end
	local function lay(folder: Instance, line: Layout.RouteLine, routeId: string)
		-- Pieces of lane of one surface with no grass over them, as lists of distances along.
		local index = 0
		local runStart: number? = nil
		local runColour, runDeck = surfaceAt(routeId, 0)
		local function finish(from: number, to: number, colour: Color3, deck: boolean)
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
			if deck then
				Lanes.deck(folder, points, width, colour)
				return
			end
			for k, at in points do
				-- A hair below the town's streets (0.4), so where a route's first joint
				-- overlaps a street the street shows, not a flickering pinwheel of both.
				local disc = Props.disc(folder, at, width, 0.4, ROUTE_TOP, colour)
				disc.CanCollide = true
				local after = points[k + 1]
				if after then
					index += 1
					local slab = Props.strip(folder, at, after, width, 0.4, ROUTE_TOP, colour)
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
			local colour, deck = surfaceAt(routeId, along)
			if covered or colour ~= runColour or deck ~= runDeck then
				if runStart then
					finish(runStart, along, runColour, runDeck)
				end
				runStart = if covered then nil else along
				runColour, runDeck = colour, deck
			elseif runStart == nil then
				runStart = along
			end
			if along >= line.length then
				break
			end
			along = math.min(along + step, line.length)
		end
		if runStart then
			finish(runStart, line.length, runColour, runDeck)
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
