--!strict
-- Builds a walkable world from the layout, so the game can be played and tested before the
-- real map exists. A biome with a map sheet (Greenwood) is built as designed: streets, lanes in
-- hedged corridors, water, fences, signs and painted models where the sheet puts them
-- (docs/plans/08_GREENWOOD_MAP.md). A biome without one gets flat ground, slabs for paths and a
-- random scatter of greenery. Nothing here is final art.
-- TODO(art): replaced by the real map; its markers will carry the same attributes.
--
-- Everything a player can use carries a ProximityPrompt with two attributes the device reads:
-- PromptKind ("Talk", "Tamer", "Rival", "Rustle", "Bait", "Giant", "Shop") and PromptId. The
-- prompt is only a button: the server checks the player's position itself when the request
-- arrives.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Giants = require(ReplicatedStorage.content.Giants)
local GreenwoodDressing = require(ReplicatedStorage.content.map_data.GreenwoodDressing)
local Layout = require(ReplicatedStorage.shared.Layout)
local Tamers = require(ReplicatedStorage.content.Tamers)
local WorldConfig = require(ReplicatedStorage.config.WorldConfig)
local WorldTypes = require(ReplicatedStorage.shared.WorldTypes)

local Corridors = require(script.Parent.Corridors)
local Dressing = require(script.Parent.Dressing)
local Grass = require(script.Parent.Grass)
local Landmarks = require(script.Parent.Landmarks)
local Lanes = require(script.Parent.Lanes)
local Markers = require(script.Parent.Markers)
local Props = require(script.Parent.Props)
local Scatter = require(script.Parent.Scatter)
local Scenery = require(script.Parent.Scenery)
local Water = require(script.Parent.Water)

local TestMap = {}

-- The dressing sheet of each biome that has one, by biome id.
local DRESSINGS: { [string]: WorldTypes.DressingSheet } = {
	greenwood = GreenwoodDressing,
}

local GROUND = Color3.fromRGB(116, 178, 92)
local PATH = Color3.fromRGB(196, 178, 128)
local STONE = Color3.fromRGB(150, 150, 150)
local STONE_LANE = Color3.fromRGB(186, 180, 168)
local ARENA = Color3.fromRGB(120, 96, 66)
local WOOD = Color3.fromRGB(140, 105, 70)
local REEDS = Color3.fromRGB(70, 110, 60)
local MUD = Color3.fromRGB(120, 104, 70)

local block, label, prompt = Markers.block, Markers.label, Markers.prompt
local at, slab, person = Markers.at, Markers.slab, Markers.person

-- Builds one biome under `parent`.
local function buildBiome(parent: Folder, biome: WorldTypes.Biome, map: Layout.Map, first: boolean)
	local world = Instance.new("Folder")
	world.Name = biome.id
	world.Parent = parent
	local dressing = if biome.map then DRESSINGS[biome.id] else nil
	local pick = Random.new(biome.number * 7919) -- the same map every time

	-- A slab of ground under everything in this biome, with room to spare.
	local minX, maxX, minZ, maxZ = math.huge, -math.huge, math.huge, -math.huge
	for _, place in map.places do
		minX, maxX = math.min(minX, place.x), math.max(maxX, place.x)
		minZ, maxZ = math.min(minZ, place.z), math.max(maxZ, place.z)
	end
	local margin = 220
	local ground = block(
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
	Markers.addGround(ground)

	local waters = if dressing then Scenery.waters(map, dressing) else {}
	if dressing then
		Corridors.ground(world, biome, map, dressing)
		Corridors.edges(world, biome, map, dressing, waters, pick)
		Scenery.build(world, biome, map, dressing, waters, pick)
		Landmarks.build(world, map, dressing)
	else
		Scatter.build(world, biome, map, 44)
	end

	-- The hub.
	local hub = Instance.new("Folder")
	hub.Name = "Hub"
	hub.Parent = world
	local square = block(
		hub,
		"Square",
		Vector3.new(map.hub.size, 0.4, map.hub.size),
		CFrame.new(map.hub.x, if dressing then 0.025 else 0.2, map.hub.z),
		PATH
	)
	if dressing then
		-- The town's green lies flat under its streets, a hair above the field round it.
		square.Size = Vector3.new(map.hub.size, 0.05, map.hub.size)
		square.CanCollide = false
	end
	Markers.addGround(square)
	local sign = block(
		hub,
		biome.hub.id,
		Vector3.new(1, 10, 1),
		CFrame.new(map.hub.x, 5.4, map.hub.z + 12),
		WOOD
	)
	if dressing then
		-- The arches carry the town's name; the marker stays, out of sight, in the plaza.
		sign.CFrame = CFrame.new(map.hub.x, 5.4, map.hub.z)
		sign.Transparency = 1
		sign.CanCollide = false
	else
		label(sign, `{biome.hub.name} ({biome.name})`)
	end
	if dressing then
		local plaza = dressing.plaza
		Dressing.square(
			hub,
			Vector3.new(map.hub.x + plaza.at.x, 0, map.hub.z + plaza.at.z),
			map.hub.size,
			{
				plaza = plaza.size,
				rim = plaza.rim,
				well = Vector3.new(map.hub.x + dressing.well.x, 0, map.hub.z + dressing.well.z),
				green = Props.colour(dressing.townGround),
			}
		)
	else
		Dressing.square(hub, Vector3.new(map.hub.x, 0, map.hub.z), map.hub.size)
	end
	if first then
		-- Everyone arrives in the first biome's square, facing the way the sheet says.
		local spawn = Instance.new("SpawnLocation")
		spawn.Name = "Spawn"
		spawn.Anchored = true
		spawn.Size = Vector3.new(12, 1, 12)
		local arrive = map.spawn
		if arrive then
			local foot = Vector3.new(arrive.at.x, 0.9, arrive.at.z)
			spawn.CFrame = CFrame.lookAt(foot, foot + Props.facing(arrive.faces))
		else
			spawn.CFrame = CFrame.new(map.hub.x, 0.9, map.hub.z)
		end
		spawn.Color = STONE
		spawn.Transparency = 1 -- where players arrive, not something to look at
		spawn.CanCollide = false
		spawn.Parent = hub
	end
	Markers.buildings(hub, biome, map, dressing)
	if dressing then
		for _, villager in dressing.people do
			person(
				hub,
				villager.name,
				{ x = map.hub.x + villager.at.x, z = map.hub.z + villager.at.z },
				nil,
				villager.faces,
				villager.model
			)
		end
	end

	-- The routes, their stretches, long grass, rustle spots and tamers.
	for _, route in biome.routes do
		local line = map.routes[route.id]
		local folder = Instance.new("Folder")
		folder.Name = route.id
		folder.Parent = world
		if not dressing then
			for index = 1, #line.points - 1 do
				slab(folder, `Path{index}`, line.points[index], line.points[index + 1], 44, PATH)
			end
		end
		for _, area in route.areas do
			local post = block(
				folder,
				area.id,
				Vector3.new(1, 8, 1),
				at(
					Layout.pointAt(
						line,
						area.from + (if dressing then 12 else 0),
						(if dressing then -11 else 26) * line.side
					),
					4.4
				),
				WOOD
			)
			label(post, `{area.name} (Lv {area.minLevel}-{area.maxLevel})`)
		end
		for _, area in route.areas do
			local grass = map.places[Layout.grassId(area.id)]
			if grass and dressing then
				Grass.patch(folder, Layout.grassId(area.id), Vector3.new(grass.x, 0, grass.z), pick)
			elseif grass then
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
			if dressing then
				-- A muddy patch ringed with reeds, or in a wood a knot of small bent trees.
				patch.Size = Vector3.new(20, 0.3, 20)
				patch.CFrame = at(map.places[spot.id], 0.3)
				patch.Color = MUD
				patch.CanCollide = false
				local mesh = Instance.new("SpecialMesh")
				mesh.MeshType = Enum.MeshType.Sphere
				mesh.Parent = patch
				local centre = patch.Position
				local wooded = string.find(spot.area, "wood", 1, true) ~= nil
				for k = 0, if wooded then 4 else 7 do
					local turn = k / (if wooded then 5 else 8) * math.pi * 2
					local foot =
						Vector3.new(centre.X + math.cos(turn) * 9, 0, centre.Z + math.sin(turn) * 9)
					if wooded then
						Props.tree(folder, foot, "Tree", 0.6, pick)
					else
						Water.reeds(folder, foot, pick)
					end
				end
			end
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
				local body = person(folder, tamer.name, point, nil, map.faces[tamerId])
				prompt(body, "Tamer", tamer.id, "Battle", tamer.name, WorldConfig.ENGAGE_RADIUS)
			end
		end
	end
	if dressing then
		Lanes.build(world, biome, map, dressing)
	end

	-- The people the story sends the player to battle (the rival, a gate's champion) stand where
	-- the sheet puts them, or a few steps from their place.
	for _, battle in Tamers.story do
		local place = map.places[battle.place]
		if place then
			local stand = map.stands[battle.id] or { x = place.x + 14, z = place.z - 14 }
			local body =
				person(world, `{battle.name} ({battle.id})`, stand, nil, map.faces[battle.id])
			prompt(body, "Rival", battle.id, "Battle", battle.name, WorldConfig.ENGAGE_RADIUS)
		end
	end

	-- The gate and the sealed road beyond it.
	local gatePoint = map.places[biome.gate.id]
	if gatePoint then
		local arch = block(world, biome.gate.id, Vector3.new(6, 26, 60), at(gatePoint, 13.4), STONE)
		arch.CanCollide = false
		arch.Transparency = if dressing then 1 else 0.4 -- the gatehouse is the arch you see
		label(arch, biome.gate.name)
		local sealed = map.places[biome.gate.sealedPath]
		if sealed then
			if dressing then
				-- A stone road on past the bar, towards the next biome.
				local length = math.max(Layout.distance(gatePoint, sealed), 1e-6)
				local beyond = {
					x = sealed.x + (sealed.x - gatePoint.x) / length * 60,
					z = sealed.z + (sealed.z - gatePoint.z) / length * 60,
				}
				slab(world, "SealedRoad", gatePoint, beyond, dressing.laneWidth, STONE_LANE)
			else
				slab(world, "SealedRoad", gatePoint, sealed, 30, STONE)
			end
			local roadSign =
				block(world, biome.gate.sealedPath, Vector3.new(1, 8, 1), at(sealed, 4.4), WOOD)
			label(roadSign, "The road on")
		end
	end

	-- The lair's spur and arena.
	if #map.lairSpur >= 2 then
		local arenaAt = map.lairSpur[#map.lairSpur]
		if not dressing then
			for index = 1, #map.lairSpur - 1 do
				slab(world, "LairSpur", map.lairSpur[index], map.lairSpur[index + 1], 24, PATH)
			end
		end
		local arena = block(
			world,
			biome.lair.id,
			Vector3.new(biome.lair.arenaSize, 0.6, biome.lair.arenaSize),
			at(arenaAt, 0.3),
			STONE
		)
		if dressing then
			-- A round clearing of bare earth, the giant's arena.
			arena.Shape = Enum.PartType.Cylinder
			arena.Size = Vector3.new(0.3, biome.lair.arenaSize, biome.lair.arenaSize)
			arena.CFrame = at(arenaAt, 0.2) * CFrame.Angles(0, 0, math.rad(90))
			arena.Color = ARENA
		end
		label(arena, biome.lair.name)
		local giant = Giants[biome.lair.giant]
		if giant then
			-- The giant sleeps in the middle of its arena; a Giant Horn wakes it.
			local sleeper = block(world, giant.id, Vector3.new(20, 40, 20), at(arenaAt, 20.6), WOOD)
			label(sleeper, `{giant.name} (Lv {giant.level})`)
			prompt(sleeper, "Giant", giant.id, "Blow the Giant Horn", giant.name, 40)
		end
		local stall = map.places[Layout.stallId(biome)]
		if stall then
			local join = map.lairSpur[1]
			local toward = Vector3.new(join.x, 0, join.z)
			local keeper = person(world, "Hollow Stall", stall, toward)
			prompt(
				keeper,
				"Shop",
				Layout.stallId(biome),
				"Shop",
				"Hollow Stall",
				WorldConfig.TALK_RADIUS
			)
			if dressing then
				-- The stall's counter stands beside the keeper, off the lane.
				local down = Vector3.new(join.x - stall.x, 0, join.z - stall.z)
				local facing = if down.Magnitude > 1e-3 then down.Unit else Vector3.zAxis
				local side = Vector3.new(-facing.Z, 0, facing.X) * dressing.stall.side
				local foot = Vector3.new(stall.x, 0, stall.z) + side * 12
				local painted = Props.model("Stall")
				local counter = block(
					world,
					"StallCounter",
					Vector3.new(8, 4, 3),
					CFrame.lookAt(foot + Vector3.yAxis * 2, foot + Vector3.yAxis * 2 + facing),
					WOOD
				)
				if painted then
					counter.Transparency = 1
					Props.stand(world, painted, foot, 9, facing)
				else
					Props.part(
						world,
						Vector3.new(9, 0.6, 5),
						counter.CFrame * CFrame.new(0, 5, 0),
						Color3.fromRGB(96, 150, 84)
					)
				end
			end
		end
	end
end

-- Builds every biome under workspace.World, laid out as the world layout says. Does nothing if
-- a World folder already exists (the real map, or an earlier build).
function TestMap.build(biomes: { WorldTypes.Biome }, world: Layout.World)
	if workspace:FindFirstChild("World") then
		return
	end
	Dressing.mood()
	local folder = Instance.new("Folder")
	folder.Name = "World"
	folder:SetAttribute("Generated", true)
	-- In the workspace from the start, so people can find the ground beneath them by raycast.
	folder.Parent = workspace
	for index, biome in biomes do
		local map = world.maps[biome.number]
		if map then
			buildBiome(folder, biome, map, index == 1)
		end
	end
end

return TestMap
