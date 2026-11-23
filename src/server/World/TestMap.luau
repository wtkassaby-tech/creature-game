--!strict
-- Builds a walkable world from the layout, so the game can be played and tested before the
-- real map exists. A biome with a map sheet and a dressing sheet (Greenwood, Dust Canyon) is
-- built as designed: streets, lanes in corridors edged with hedges, cliffs or boulders, water,
-- fences, signs and painted models where the sheet puts them (docs/plans/08_GREENWOOD_MAP.md,
-- 09_DUST_CANYON_MAP.md). A biome without one gets flat ground, slabs for paths and a random
-- scatter of greenery. Each biome's ground slab stops where the next one's starts, 30 studs
-- past its gate. Nothing here is final art.
-- TODO(art): replaced by the real map; its markers will carry the same attributes.
--
-- Everything a player can use carries a ProximityPrompt with two attributes the device reads:
-- PromptKind ("Talk", "Tamer", "Rival", "Rustle", "Bait", "Giant", "Shop") and PromptId. The
-- prompt is only a button: the server checks the player's position itself when the request
-- arrives.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DustCanyonDressing = require(ReplicatedStorage.content.map_data.DustCanyonDressing)
local GreenwoodDressing = require(ReplicatedStorage.content.map_data.GreenwoodDressing)
local TideFlatsDressing = require(ReplicatedStorage.content.map_data.TideFlatsDressing)
local Enclosure = require(ReplicatedStorage.shared.Enclosure)
local Layout = require(ReplicatedStorage.shared.Layout)
local Tamers = require(ReplicatedStorage.content.Tamers)
local WorldConfig = require(ReplicatedStorage.config.WorldConfig)
local WorldTypes = require(ReplicatedStorage.shared.WorldTypes)

local Ambience = require(script.Parent.Ambience)
local Barriers = require(script.Parent.Barriers)
local CorridorGround = require(script.Parent.CorridorGround)
local Corridors = require(script.Parent.Corridors)
local Dressing = require(script.Parent.Dressing)
local Fill = require(script.Parent.Fill)
local Grass = require(script.Parent.Grass)
local Lair = require(script.Parent.Lair)
local Landmarks = require(script.Parent.Landmarks)
local Lanes = require(script.Parent.Lanes)
local Markers = require(script.Parent.Markers)
local Props = require(script.Parent.Props)
local Scatter = require(script.Parent.Scatter)
local Scenery = require(script.Parent.Scenery)

local TestMap = {}

-- The dressing sheet of each biome that has one, by biome id.
local DRESSINGS: { [string]: WorldTypes.DressingSheet } = {
	greenwood = GreenwoodDressing,
	dust_canyon = DustCanyonDressing,
	tide_flats = TideFlatsDressing,
}

-- Where one biome's ground slab ends and the next one's begins: this far past the earlier
-- biome's gate, across its sealed road (docs/plans/09_DUST_CANYON_MAP.md section 4d). Gates face
-- east, so the line runs north to south.
local SLAB_CLIP_PAST_GATE = 30

-- The east-west limits of a biome's ground slab, as world x: nil where it is not clipped.
type Clip = { west: number?, east: number? }

local GROUND = Color3.fromRGB(116, 178, 92)
local PATH = Color3.fromRGB(196, 178, 128)
local STONE = Color3.fromRGB(150, 150, 150)
local STONE_LANE = Color3.fromRGB(186, 180, 168)
local WOOD = Color3.fromRGB(140, 105, 70)
local REEDS = Color3.fromRGB(70, 110, 60)
local MUD = Color3.fromRGB(120, 104, 70)

local block, label, prompt = Markers.block, Markers.label, Markers.prompt
local at, slab, person = Markers.at, Markers.slab, Markers.person

-- Builds one biome under `parent`.
-- A sheet's flats (the sea, a mudflat) are drawn generously; trim each to its biome's ground so
-- none hangs past the slab's edge or into the next biome (Tide Flats' open sea did, seen from
-- the air on 23 November 2026). A flat wholly off the ground is removed.
local function clipFlats(world: Instance, ground: BasePart)
	local half = ground.Size / 2
	local low, high = ground.Position - half, ground.Position + half
	for _, part in world:GetDescendants() do
		if not (part:IsA("BasePart") and (part.Name == "WaterFlat" or part.Name == "Flat")) then
			continue
		end
		local size = part.Size / 2
		local x0 = math.max(part.Position.X - size.X, low.X)
		local x1 = math.min(part.Position.X + size.X, high.X)
		local z0 = math.max(part.Position.Z - size.Z, low.Z)
		local z1 = math.min(part.Position.Z + size.Z, high.Z)
		if x1 - x0 < 1 or z1 - z0 < 1 then
			part:Destroy()
		else
			part.Size = Vector3.new(x1 - x0, part.Size.Y, z1 - z0)
			part.CFrame = CFrame.new((x0 + x1) / 2, part.Position.Y, (z0 + z1) / 2)
		end
	end
end

local function buildBiome(
	parent: Folder,
	biome: WorldTypes.Biome,
	map: Layout.Map,
	first: boolean,
	clip: Clip,
	links: { Enclosure.Shape }
)
	local world = Instance.new("Folder")
	world.Name = biome.id
	world.Parent = parent
	local dressing = if biome.map then DRESSINGS[biome.id] else nil
	local pick = Random.new(biome.number * 7919) -- the same map every time

	-- A slab of ground under everything in this biome, with room to spare, cut off where the
	-- next biome's begins so two colours of field never overlap.
	local minX, maxX, minZ, maxZ = math.huge, -math.huge, math.huge, -math.huge
	for _, place in map.places do
		minX, maxX = math.min(minX, place.x), math.max(maxX, place.x)
		minZ, maxZ = math.min(minZ, place.z), math.max(maxZ, place.z)
	end
	local margin = 220
	local middleX, middleZ = (minX + maxX) / 2, (minZ + maxZ) / 2
	local width = math.min(2048, maxX - minX + margin * 2)
	local west, east = middleX - width / 2, middleX + width / 2
	west = if clip.west then math.max(west, clip.west) else west
	east = if clip.east then math.min(east, clip.east) else east
	-- Past the edges the open ground is the fill's own floor (dark under trees), so a glimpse
	-- through a gap reads as wood or rock and not as lawn.
	local fill = if dressing then dressing.fill else nil
	local fieldColour = if fill
		then Props.colour(fill.floor)
		elseif dressing and dressing.fieldGround then Props.colour(dressing.fieldGround)
		else GROUND
	local depth = math.min(2048, maxZ - minZ + margin * 2)
	local ground = block(
		world,
		"Ground",
		Vector3.new(east - west, 4, depth),
		CFrame.new((west + east) / 2, -2, middleZ),
		fieldColour
	)
	Markers.addGround(ground)

	local waters = if dressing then Scenery.waters(map, dressing) else {}
	if dressing then
		-- Everything past the walkable space closes in: water blocks, and trees, rock or dunes
		-- stand solid out to the fill's band (docs/plans/12_MAP_STRUCTURE.md section 10, step 1).
		local shapes = Enclosure.walkable(biome, map, dressing, links)
		local limits: Enclosure.Bounds =
			{ x0 = west, z0 = middleZ - depth / 2, x1 = east, z1 = middleZ + depth / 2 }
		Barriers.build(world, Enclosure.water(biome, map, dressing, shapes, limits))
		if fill then
			Fill.build(
				world,
				fill.style,
				Enclosure.fill(
					shapes,
					limits,
					fill.style,
					fill.band,
					biome.number * 101,
					Enclosure.seas(map, dressing)
				)
			)
		end
		CorridorGround.build(world, biome, map, dressing)
		Corridors.edges(world, biome, map, dressing, waters, pick)
		Scenery.build(world, biome, map, dressing, waters, pick)
		Landmarks.build(world, map, dressing)
		clipFlats(world, ground)
		Ambience.build(world, map, dressing)
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
		local well = dressing.well
		Dressing.square(
			hub,
			Vector3.new(map.hub.x + plaza.at.x, 0, map.hub.z + plaza.at.z),
			map.hub.size,
			{
				plaza = plaza.size,
				rim = plaza.rim,
				well = if well then Vector3.new(map.hub.x + well.x, 0, map.hub.z + well.z) else nil,
				green = Props.colour(dressing.townGround),
				colour = if plaza.colour then Props.colour(plaza.colour) else nil,
				rimColour = if plaza.rimColour then Props.colour(plaza.rimColour) else nil,
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
				local looks = dressing.grassLooks
				Grass.patch(
					folder,
					Layout.grassId(area.id),
					Vector3.new(grass.x, 0, grass.z),
					pick,
					if looks then looks[area.id] else nil
				)
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
				local looks = dressing.grassLooks
				Grass.rustle(
					folder,
					patch,
					spot.area,
					pick,
					if looks then looks[spot.area] else nil
				)
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
	Lair.build(world, biome, map, dressing)
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
	-- Each biome's gate, as world x, by biome number: where its ground slab meets the next one's.
	local gateX: { [number]: number } = {}
	for _, biome in biomes do
		local map = world.maps[biome.number]
		local gate = if map then map.places[biome.gate.id] else nil
		if gate then
			gateX[biome.number] = gate.x + SLAB_CLIP_PAST_GATE
		end
	end
	for index, biome in biomes do
		local map = world.maps[biome.number]
		if map then
			-- The last biome's slab runs on past its gate, under its sealed road.
			local clip: Clip = {
				west = gateX[biome.number - 1],
				east = if world.maps[biome.number + 1] then gateX[biome.number] else nil,
			}
			-- The walk from the biome before: its gate to this town's west edge, kept open.
			local links: { Enclosure.Shape } = {}
			local before = biomes[index - 1]
			local beforeMap = if before then world.maps[before.number] else nil
			local gate = if before and beforeMap then beforeMap.places[before.gate.id] else nil
			if gate then
				table.insert(
					links,
					Enclosure.link(gate, { x = map.hub.x - map.hub.size / 2, z = map.hub.z }, 40)
				)
			end
			buildBiome(folder, biome, map, index == 1, clip, links)
		end
	end
end

return TestMap
