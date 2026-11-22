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

local Giants = require(ReplicatedStorage.content.Giants)
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
local function buildBiome(parent: Folder, biome: WorldTypes.Biome, map: Layout.Map, first: boolean)
	local world = Instance.new("Folder")
	world.Name = biome.id
	world.Parent = parent

	-- A slab of ground under everything in this biome, with room to spare.
	local minX, maxX, minZ, maxZ = math.huge, -math.huge, math.huge, -math.huge
	for _, place in map.places do
		minX, maxX = math.min(minX, place.x), math.max(maxX, place.x)
		minZ, maxZ = math.min(minZ, place.z), math.max(maxZ, place.z)
	end
	local margin = 220
	block(
		world,
		"Ground",
		Vector3.new(
			math.min(2048, maxX - minX + margin * 2),
			4,
			math.min(2048, maxZ - minZ + margin * 2)
		),
		CFrame.new((minX + maxX) / 2, -2, (minZ + maxZ) / 2),
		GROUND
	)

	-- The hub.
	local hub = Instance.new("Folder")
	hub.Name = "Hub"
	hub.Parent = world
	block(
		hub,
		"Square",
		Vector3.new(map.hub.size, 0.4, map.hub.size),
		CFrame.new(map.hub.x, 0.2, map.hub.z),
		PATH
	)
	local sign = block(
		hub,
		biome.hub.id,
		Vector3.new(1, 10, 1),
		CFrame.new(map.hub.x, 5.4, map.hub.z + 12),
		WOOD
	)
	label(sign, `{biome.hub.name} ({biome.name})`)
	if first then
		-- Everyone arrives in the first biome's square.
		local spawn = Instance.new("SpawnLocation")
		spawn.Name = "Spawn"
		spawn.Anchored = true
		spawn.Size = Vector3.new(12, 1, 12)
		spawn.CFrame = CFrame.new(map.hub.x, 0.9, map.hub.z)
		spawn.Color = STONE
		spawn.Parent = hub
	end
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
		talk:SetAttribute("Role", building.role)
		talk:SetAttribute("Biome", biome.number)
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
		for _, area in route.areas do
			local grass = map.places[Layout.grassId(area.id)]
			if grass then
				local size = WorldConfig.GRASS_RADIUS * 2
				local patch = block(
					folder,
					Layout.grassId(area.id),
					Vector3.new(size, 1.6, size),
					at(grass, 0.8),
					REEDS
				)
				patch.CanCollide = false
				patch.Transparency = 0.25
				label(patch, "Long grass")
			end
		end
		for _, spot in route.rustleSpots do
			local patch =
				block(folder, spot.id, Vector3.new(20, 1.2, 20), at(map.places[spot.id], 1), REEDS)
			label(patch, spot.name)
			prompt(patch, "Rustle", spot.id, "Search", spot.name, WorldConfig.RUSTLE_RADIUS)
			-- A second prompt for bait, on its own key and drawn beside the first.
			local bait =
				prompt(patch, "Bait", spot.id, "Use bait", spot.name, WorldConfig.RUSTLE_RADIUS)
			bait.KeyboardKeyCode = Enum.KeyCode.F
			bait.UIOffset = Vector2.new(0, 70)
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

	-- The people the story sends the player to battle (the rival, a gate's champion) stand a
	-- few steps from their place.
	for _, battle in Tamers.story do
		local place = map.places[battle.place]
		if place then
			local body =
				person(world, `{battle.name} ({battle.id})`, { x = place.x + 14, z = place.z - 14 })
			prompt(body, "Rival", battle.id, "Battle", battle.name, WorldConfig.ENGAGE_RADIUS)
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
			local roadSign =
				block(world, biome.gate.sealedPath, Vector3.new(1, 8, 1), at(sealed, 4.4), WOOD)
			label(roadSign, "The road on")
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
		local giant = Giants[biome.lair.giant]
		if giant then
			-- The giant sleeps in the middle of its arena; a Giant Horn wakes it.
			local sleeper =
				block(world, giant.id, Vector3.new(20, 40, 20), at(map.lairSpur[2], 20.6), WOOD)
			label(sleeper, `{giant.name} (Lv {giant.level})`)
			prompt(sleeper, "Giant", giant.id, "Blow the Giant Horn", giant.name, 40)
		end
		local stall = map.places[Layout.stallId(biome)]
		if stall then
			local keeper = person(world, "Hollow Stall", stall)
			prompt(
				keeper,
				"Shop",
				Layout.stallId(biome),
				"Shop",
				"Hollow Stall",
				WorldConfig.TALK_RADIUS
			)
		end
	end
end

-- Builds every biome under workspace.World, laid out as the world layout says. Does nothing if
-- a World folder already exists (the real map, or an earlier build).
function TestMap.build(biomes: { WorldTypes.Biome }, world: Layout.World)
	if workspace:FindFirstChild("World") then
		return
	end
	local folder = Instance.new("Folder")
	folder.Name = "World"
	folder:SetAttribute("Generated", true)
	for index, biome in biomes do
		local map = world.maps[biome.number]
		if map then
			buildBiome(folder, biome, map, index == 1)
		end
	end
	folder.Parent = workspace
end

return TestMap
