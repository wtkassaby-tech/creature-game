--!strict
-- Builds a plain grey-box Greenwood from the layout, so the game can be walked and tested before
-- the real map exists. Flat ground, slabs for paths, blocks for buildings and people, each with
-- its name floating above it. Nothing here is final art.
-- TODO(art): replaced by the real Greenwood map; its markers will carry the same attributes.
--
-- Everything a player can use carries a ProximityPrompt with two attributes the device reads:
-- PromptKind ("Talk", "Tamer", "Rival", "Rustle") and PromptId. The prompt is only a button: the
-- server checks the player's position itself when the request arrives.
-- Not yet run in Studio.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Layout = require(ReplicatedStorage.shared.Layout)
local Tamers = require(ReplicatedStorage.content.Tamers)
local WorldConfig = require(ReplicatedStorage.config.WorldConfig)
local WorldTypes = require(ReplicatedStorage.shared.WorldTypes)

local TestMap = {}

local GROUND = Color3.fromRGB(106, 153, 85)
local PATH = Color3.fromRGB(196, 178, 128)
local STONE = Color3.fromRGB(150, 150, 150)
local WOOD = Color3.fromRGB(140, 105, 70)
local REEDS = Color3.fromRGB(70, 110, 60)
local PERSON = Color3.fromRGB(230, 200, 120)

local function block(
	parent: Instance,
	name: string,
	size: Vector3,
	cframe: CFrame,
	colour: Color3
): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.Size = size
	part.CFrame = cframe
	part.Color = colour
	part.Material = Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function label(part: BasePart, text: string)
	local board = Instance.new("BillboardGui")
	board.Size = UDim2.fromOffset(220, 40)
	board.StudsOffsetWorldSpace = Vector3.new(0, part.Size.Y / 2 + 3, 0)
	board.AlwaysOnTop = false
	board.MaxDistance = 220
	board.Parent = part
	local text_ = Instance.new("TextLabel")
	text_.Size = UDim2.fromScale(1, 1)
	text_.BackgroundTransparency = 1
	text_.Text = text
	text_.TextColor3 = Color3.new(1, 1, 1)
	text_.TextStrokeTransparency = 0.3
	text_.Font = Enum.Font.GothamBold
	text_.TextScaled = true
	text_.Parent = board
end

local function prompt(
	part: BasePart,
	kind: string,
	id: string,
	action: string,
	object: string,
	reach: number
): ProximityPrompt
	local p = Instance.new("ProximityPrompt")
	p.ActionText = action
	p.ObjectText = object
	p.MaxActivationDistance = reach
	p.RequiresLineOfSight = false
	p.HoldDuration = 0
	p:SetAttribute("PromptKind", kind)
	p:SetAttribute("PromptId", id)
	p.Parent = part
	return p
end

local function at(point: Layout.Point, height: number): CFrame
	return CFrame.new(point.x, height, point.z)
end

local function slab(
	parent: Instance,
	name: string,
	a: Layout.Point,
	b: Layout.Point,
	width: number,
	colour: Color3
)
	local from, to = Vector3.new(a.x, 0.2, a.z), Vector3.new(b.x, 0.2, b.z)
	local length = (to - from).Magnitude
	if length < 0.01 then
		return
	end
	block(
		parent,
		name,
		Vector3.new(width, 0.4, length + width * 0.2),
		CFrame.lookAt((from + to) / 2, to),
		colour
	)
end

local function person(parent: Instance, name: string, point: Layout.Point): Part
	local body = block(parent, name, Vector3.new(3, 6, 2), at(point, 3.4), PERSON)
	label(body, name)
	return body
end

-- Builds the map under workspace.World. Does nothing if a World folder already exists (the real
-- map, or an earlier build).
function TestMap.build(biome: WorldTypes.Biome, map: Layout.Map)
	if workspace:FindFirstChild("World") then
		return
	end
	local world = Instance.new("Folder")
	world.Name = "World"
	world:SetAttribute("Generated", true)

	block(world, "Ground", Vector3.new(2048, 4, 1024), CFrame.new(95, -2, 0), GROUND)

	-- The hub.
	local hub = Instance.new("Folder")
	hub.Name = "Hub"
	hub.Parent = world
	block(hub, "Square", Vector3.new(map.hub.size, 0.4, map.hub.size), CFrame.new(0, 0.2, 0), PATH)
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "Spawn"
	spawn.Anchored = true
	spawn.Size = Vector3.new(12, 1, 12)
	spawn.CFrame = CFrame.new(0, 0.9, 0)
	spawn.Color = STONE
	spawn.Parent = hub
	for _, building in biome.hub.buildings do
		local house = block(
			hub,
			building.id,
			Vector3.new(24, 18, 24),
			at(map.buildings[building.id], 9.4),
			WOOD
		)
		label(house, building.name)
		-- Every building's keeper stands at its door. Talking to one moves the story on if the
		-- story is waiting for them, and offers or takes in that place's quests.
		local body = person(hub, building.npc or `{building.id}_keeper`, map.places[building.id])
		local talk = prompt(
			body,
			"Talk",
			building.npc or building.id,
			"Talk",
			building.name,
			WorldConfig.TALK_RADIUS
		)
		talk:SetAttribute("Place", building.name)
	end

	-- The routes, their stretches, rustle spots and tamers.
	for _, route in biome.routes do
		local line = map.routes[route.id]
		local folder = Instance.new("Folder")
		folder.Name = route.id
		folder.Parent = world
		for index = 1, #line.points - 1 do
			slab(folder, `Path{index}`, line.points[index], line.points[index + 1], 44, PATH)
		end
		for _, area in route.areas do
			local post = block(
				folder,
				area.id,
				Vector3.new(1, 8, 1),
				at(Layout.pointAt(line, area.from, 26 * line.side), 4.4),
				WOOD
			)
			label(post, `{area.name} (Lv {area.minLevel}-{area.maxLevel})`)
		end
		for _, spot in route.rustleSpots do
			local patch =
				block(folder, spot.id, Vector3.new(20, 1.2, 20), at(map.places[spot.id], 1), REEDS)
			label(patch, spot.name)
			prompt(patch, "Rustle", spot.id, "Search", spot.name, WorldConfig.RUSTLE_RADIUS)
		end
		for _, tamerId in route.tamers do
			local tamer = Tamers.locals[tamerId]
			local point = map.places[tamerId]
			if tamer and point then
				local body = person(folder, tamer.name, point)
				prompt(body, "Tamer", tamer.id, "Battle", tamer.name, WorldConfig.ENGAGE_RADIUS)
			end
		end
	end

	-- The rival waits in the square for the first battle and at the gate for the last.
	for _, rival in Tamers.rivals do
		local first = person(hub, `{rival.name} (first battle)`, { x = 20, z = -20 })
		prompt(first, "Rival", rival.firstBattle, "Battle", rival.name, WorldConfig.ENGAGE_RADIUS)
		local gatePoint = map.places[biome.gate.id]
		if gatePoint then
			local last = person(
				world,
				`{rival.name} (gate battle)`,
				{ x = gatePoint.x - 10, z = gatePoint.z + 10 }
			)
			prompt(last, "Rival", rival.gateBattle, "Battle", rival.name, WorldConfig.ENGAGE_RADIUS)
		end
	end

	-- The gate and the sealed road beyond it.
	local gatePoint = map.places[biome.gate.id]
	if gatePoint then
		local arch = block(world, biome.gate.id, Vector3.new(6, 26, 60), at(gatePoint, 13.4), STONE)
		arch.CanCollide = false
		arch.Transparency = 0.4
		label(arch, biome.gate.name)
		local sealed = map.places[biome.gate.sealedPath]
		if sealed then
			slab(world, "SealedRoad", gatePoint, sealed, 30, STONE)
			local sign =
				block(world, biome.gate.sealedPath, Vector3.new(1, 8, 1), at(sealed, 4.4), WOOD)
			label(sign, "The road on")
		end
	end

	-- The lair's spur and arena.
	if #map.lairSpur == 2 then
		slab(world, "LairSpur", map.lairSpur[1], map.lairSpur[2], 24, PATH)
		local arena = block(
			world,
			biome.lair.id,
			Vector3.new(biome.lair.arenaSize, 0.6, biome.lair.arenaSize),
			at(map.lairSpur[2], 0.3),
			STONE
		)
		label(arena, biome.lair.name)
	end

	world.Parent = workspace
end

return TestMap
