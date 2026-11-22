--!strict
-- Life for the test map: warm light and soft clouds, houses with roofs, doors and windows,
-- people with heads, and trees, bushes, rocks and flowers along the routes. The test map is
-- still a stand-in for the real one, but a bare grey-box world made every screen feel dead
-- (Ayrton, 23 November 2026: "really blocky and soulless, we need soul here").
-- Everything is built from plain rounded parts in flat colours: nothing bought, nothing uploaded.
-- TODO(art): replaced, with the test map, by the real Greenwood.

local AssetService = game:GetService("AssetService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local PropModels = require(game:GetService("ReplicatedStorage").content.PropModels)
local Layout = require(game:GetService("ReplicatedStorage").shared.Layout)
local WorldTypes = require(game:GetService("ReplicatedStorage").shared.WorldTypes)

local Dressing = {}

local function rgb(r: number, g: number, b: number): Color3
	return Color3.fromRGB(r, g, b)
end

local WALL = rgb(244, 232, 208)
local TIMBER = rgb(120, 84, 56)
local GLASS = rgb(170, 220, 240)
local SKIN: { Color3 } =
	{ rgb(246, 214, 180), rgb(214, 164, 120), rgb(150, 104, 72), rgb(110, 76, 54) }
local SHIRTS: { Color3 } = {
	rgb(220, 96, 84),
	rgb(84, 150, 220),
	rgb(240, 190, 70),
	rgb(120, 190, 110),
	rgb(170, 120, 210),
}
local HAIR: { Color3 } = { rgb(60, 44, 36), rgb(150, 100, 50), rgb(230, 200, 120), rgb(40, 40, 48) }
local ROOFS: { [string]: Color3 } = {
	Mentor = rgb(96, 150, 84),
	Shop = rgb(206, 88, 72),
	Healer = rgb(86, 170, 190),
	Breeder = rgb(232, 150, 70),
	Quests = rgb(150, 110, 70),
	Teleport = rgb(140, 110, 200),
	Circuit = rgb(120, 126, 140),
}
local BLOOMS: { Color3 } =
	{ rgb(250, 220, 90), rgb(240, 130, 150), rgb(250, 250, 250), rgb(170, 140, 240) }

local function part(parent: Instance, size: Vector3, cframe: CFrame, colour: Color3): Part
	local made = Instance.new("Part")
	made.Anchored = true
	made.Size = size
	made.CFrame = cframe
	made.Color = colour
	made.Material = Enum.Material.SmoothPlastic
	made.TopSurface = Enum.SurfaceType.Smooth
	made.BottomSurface = Enum.SurfaceType.Smooth
	made.CanCollide = false
	made.Parent = parent
	return made
end

-- A rounded lump: a sphere mesh on a block stretches with the block.
local function lump(parent: Instance, size: Vector3, at: Vector3, colour: Color3): Part
	local made = part(parent, size, CFrame.new(at), colour)
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = made
	return made
end

-- A painted model for a piece of the town (a cottage, a tree, a villager), loaded once by its
-- asset id and copied wherever it is needed. Nil if there is none or it would not load: the
-- plain shapes below are then used instead, so the map is never left bare.
local loaded: { [string]: MeshPart } = {}
local missing: { [string]: boolean } = {}
local function prop(name: string): MeshPart?
	if loaded[name] or missing[name] then
		return loaded[name]
	end
	local def = PropModels[name]
	if not def then
		missing[name] = true
		return nil
	end
	local ok, made = pcall(function(): MeshPart
		return AssetService:CreateMeshPartAsync(Content.fromUri(def.mesh), {
			CollisionFidelity = Enum.CollisionFidelity.Box,
			RenderFidelity = Enum.RenderFidelity.Automatic,
		})
	end)
	if ok then
		made.Name = name -- `stand` looks the model up again by this name
		made.TextureID = def.texture
		made.Size = Vector3.new(def.size[1], def.size[2], def.size[3])
		made.Anchored = true
		made.CanCollide = false
		made.CanQuery = true -- so a battle can tell that something stands where it wants to be
		made.CanTouch = false
		made.Material = Enum.Material.SmoothPlastic
		loaded[name] = made
	else
		warn(`[Dressing] {name}: model did not load ({made})`)
		missing[name] = true
	end
	return loaded[name]
end

-- Stands a copy of a model on the ground at `foot`, `tall` studs high, facing along `facing`.
local function stand(
	parent: Instance,
	model: MeshPart,
	foot: Vector3,
	tall: number,
	facing: Vector3
): MeshPart
	local copy = model:Clone()
	copy.Size = model.Size * (tall / model.Size.Y)
	local turn = PropModels[model.Name]
	local base = CFrame.lookAt(foot, foot + facing)
	copy.CFrame = base
		* CFrame.new(0, copy.Size.Y / 2, 0)
		* CFrame.Angles(0, math.rad(if turn and turn.turn then turn.turn else 0), 0)
	copy.Parent = parent
	return copy
end

-- Warm afternoon light, a soft haze toward the horizon and drifting clouds.
function Dressing.mood()
	Lighting.ClockTime = 15.3
	Lighting.GeographicLatitude = 35
	Lighting.Brightness = 2.3
	Lighting.Ambient = rgb(112, 112, 128)
	Lighting.OutdoorAmbient = rgb(144, 146, 156)
	Lighting.ColorShift_Top = rgb(255, 236, 204)
	Lighting.ExposureCompensation = -0.25
	Lighting.ShadowSoftness = 0.45
	Lighting.EnvironmentDiffuseScale = 0.6
	Lighting.EnvironmentSpecularScale = 0.3

	local air = Instance.new("Atmosphere")
	air.Density = 0.27
	air.Offset = 0.2
	air.Color = rgb(214, 228, 240)
	air.Decay = rgb(126, 156, 196)
	air.Glare = 0.2
	air.Haze = 1.5
	air.Parent = Lighting

	local grade = Instance.new("ColorCorrectionEffect")
	grade.Saturation = 0.25
	grade.Contrast = 0.1
	grade.TintColor = rgb(255, 248, 236)
	grade.Parent = Lighting

	local glow = Instance.new("BloomEffect")
	glow.Intensity = 0.45
	glow.Size = 24
	glow.Threshold = 1.2
	glow.Parent = Lighting

	local rays = Instance.new("SunRaysEffect")
	rays.Intensity = 0.06
	rays.Spread = 0.6
	rays.Parent = Lighting

	local terrain = Workspace:FindFirstChildOfClass("Terrain")
	if terrain and not terrain:FindFirstChildOfClass("Clouds") then
		local clouds = Instance.new("Clouds")
		clouds.Cover = 0.55
		clouds.Density = 0.6
		clouds.Color = rgb(255, 255, 255)
		clouds.Parent = terrain
	end
end

-- Turns a plain block into a cottage: plaster walls, a pitched roof in the colour of what the
-- building is for, a door and two windows on the side that faces the town square, a chimney.
function Dressing.house(house: Part, role: string, square: Vector3)
	local centre = house.Position
	local toSquare = Vector3.new(square.X - centre.X, 0, square.Z - centre.Z)
	if toSquare.Magnitude > 1 then
		house.CFrame = CFrame.lookAt(centre, centre + toSquare.Unit) -- front (-Z) faces the square
	end
	local kind = if role == "Shop" then "Shop" elseif role == "Healer" then "Healer" else "Cottage"
	local painted = prop(kind)
	if painted then
		-- The plain block stays as the thing you bump into; the painted cottage is what you see.
		house.Transparency = 1
		local sign = house:FindFirstChildOfClass("BillboardGui")
		if sign then
			sign.StudsOffsetWorldSpace = Vector3.new(0, 20, 0)
		end
		local foot = house.Position - Vector3.yAxis * house.Size.Y / 2
		local copy = stand(house, painted, foot, 26, house.CFrame.LookVector)
		copy.Name = kind
		return
	end
	house.Color = WALL
	-- The name over the door rides above the new roof.
	local sign = house:FindFirstChildOfClass("BillboardGui")
	if sign then
		sign.StudsOffsetWorldSpace = Vector3.new(0, house.Size.Y / 2 + 13, 0)
	end
	local roofColour = ROOFS[role] or ROOFS.Quests
	local size = house.Size
	local base = house.CFrame
	local top = size.Y / 2
	-- Two wedges, back to back, make the pitched roof; their tall edges meet along the ridge.
	for _, side in { -1, 1 } do
		local roof = Instance.new("WedgePart")
		roof.Anchored = true
		roof.Size = Vector3.new(size.X + 4, 9, size.Z / 2 + 2)
		roof.Color = roofColour
		roof.Material = Enum.Material.SmoothPlastic
		roof.CFrame = base
			* CFrame.new(0, top + 4.5, side * (size.Z / 4 + 1))
			* CFrame.Angles(0, if side == -1 then 0 else math.rad(180), 0)
		roof.Parent = house
	end
	part(house, Vector3.new(3, 7, 3), base * CFrame.new(size.X / 4, top + 6, 2), TIMBER) -- chimney
	local front = -size.Z / 2 - 0.15
	part(house, Vector3.new(5, 9, 0.5), base * CFrame.new(0, -top + 4.5, front), TIMBER) -- door
	lump(
		house,
		Vector3.new(0.7, 0.7, 0.5),
		(base * CFrame.new(1.6, -top + 4.5, front - 0.3)).Position,
		rgb(240, 200, 80)
	)
	for _, side in { -1, 1 } do
		part(house, Vector3.new(5, 5, 0.4), base * CFrame.new(side * 7.5, 1, front), TIMBER)
		part(house, Vector3.new(4, 4, 0.5), base * CFrame.new(side * 7.5, 1, front - 0.05), GLASS)
		part(
			house,
			Vector3.new(6, 1, 1.2),
			base * CFrame.new(side * 7.5, -1.9, front - 0.4),
			roofColour
		)
		for bloom = -1, 1 do -- a window box of flowers
			local at = base * CFrame.new(side * 7.5 + bloom * 1.6, -1.1, front - 0.5)
			lump(house, Vector3.new(1, 1, 1), at.Position, BLOOMS[(bloom + side + 3) % #BLOOMS + 1])
		end
	end
end

-- Which villager model a person wears, from their name. Tamers out on the routes are one of
-- two, chosen by `pick`, so the same tamer always looks the same.
local function villager(name: string, pick: Random): string
	local lower = string.lower(name)
	if string.find(lower, "mentor", 1, true) then
		return "Mentor"
	elseif string.find(lower, "rival", 1, true) then
		return "Rival"
	elseif string.find(lower, "healer", 1, true) then
		return "Carer"
	elseif string.find(lower, "breeder", 1, true) then
		return "Grandmother"
	elseif string.find(lower, "tuppence", 1, true) or string.find(lower, "_keeper", 1, true) then
		return "Shopkeeper"
	end
	return if pick:NextNumber() < 0.5 then "Tamer" else "GirlTamer"
end

-- Gives a plain block of a person a body: a painted villager if there is one for them, turned
-- to face `toward`; otherwise a head, hair and a coloured shirt. `pick` chooses the colours, so
-- the same person looks the same every time.
function Dressing.person(body: Part, pick: Random, name: string, toward: Vector3?)
	local painted = prop(villager(name, pick)) or prop("Tamer")
	if painted then
		body.Transparency = 1
		local foot = body.Position - Vector3.yAxis * body.Size.Y / 2
		local facing = Vector3.zAxis
		if toward then
			local flat = Vector3.new(toward.X - foot.X, 0, toward.Z - foot.Z)
			if flat.Magnitude > 1 then
				facing = flat.Unit
			end
		end
		stand(body, painted, foot, 6.6, facing)
		return
	end
	body.Color = SHIRTS[pick:NextInteger(1, #SHIRTS)]
	body.Size = Vector3.new(3, 4.4, 2)
	local feet = body.Position.Y - 3
	body.Position = Vector3.new(body.Position.X, feet + 2.2 + 1.2, body.Position.Z)
	local at = body.Position
	local skin = SKIN[pick:NextInteger(1, #SKIN)]
	local hair = HAIR[pick:NextInteger(1, #HAIR)]
	lump(body, Vector3.new(2.8, 2.8, 2.8), at + Vector3.new(0, 3.5, 0), skin) -- head
	lump(body, Vector3.new(3, 1.8, 3), at + Vector3.new(0, 4.4, 0.2), hair)
	for _, side in { -1, 1 } do
		part(
			body,
			Vector3.new(1.2, 1.4, 1.6),
			CFrame.new(at + Vector3.new(side * 0.8, -2.8, 0)),
			rgb(70, 76, 96)
		)
		lump(body, Vector3.new(1.1, 3, 1.1), at + Vector3.new(side * 2, 0.3, 0), body.Color) -- arm
		lump(
			body,
			Vector3.new(0.35, 0.45, 0.2),
			at + Vector3.new(side * 0.6, 3.7, 0),
			rgb(30, 28, 36)
		)
	end
end

-- A town square is more than paving: lamp posts at its corners and flower beds along its edges.
function Dressing.square(parent: Instance, centre: Vector3, size: number)
	local half = size / 2 - 5
	-- The square is a village green with a round cobbled plaza in the middle, not a slab of
	-- paving from edge to edge.
	local slab = parent:FindFirstChild("Square")
	if slab and slab:IsA("BasePart") then
		slab.Color = rgb(138, 196, 104)
	end
	local plaza = Instance.new("Part")
	plaza.Name = "Plaza"
	plaza.Shape = Enum.PartType.Cylinder
	plaza.Anchored = true
	plaza.Size = Vector3.new(0.3, size * 0.62, size * 0.62)
	plaza.CFrame = CFrame.new(centre + Vector3.yAxis * 0.45) * CFrame.Angles(0, 0, math.rad(90))
	plaza.Color = rgb(222, 204, 168)
	plaza.Material = Enum.Material.SmoothPlastic
	plaza.Parent = parent
	local rim = plaza:Clone()
	rim.Name = "PlazaRim"
	rim.Size = Vector3.new(0.24, size * 0.66, size * 0.66)
	rim.Color = rgb(170, 150, 120)
	rim.Parent = parent
	local well = prop("Well")
	if well then
		stand(parent, well, centre + Vector3.new(18, 0.4, -12), 10, Vector3.zAxis)
	end
	local lampModel = prop("Lamp")
	for _, x in { -1, 1 } do
		for _, z in { -1, 1 } do
			local foot = centre + Vector3.new(x * half, 0, z * half)
			if lampModel then
				stand(parent, lampModel, foot, 13, Vector3.new(-x, 0, -z).Unit)
				continue
			end
			local post = Instance.new("Part")
			post.Shape = Enum.PartType.Cylinder
			post.Anchored = true
			post.Size = Vector3.new(11, 0.8, 0.8)
			post.CFrame = CFrame.new(foot + Vector3.yAxis * 5.5) * CFrame.Angles(0, 0, math.rad(90))
			post.Color = rgb(60, 62, 72)
			post.Material = Enum.Material.SmoothPlastic
			post.Parent = parent
			local lamp = lump(
				parent,
				Vector3.new(2.4, 2.4, 2.4),
				foot + Vector3.yAxis * 11.6,
				rgb(255, 236, 170)
			)
			lamp.Material = Enum.Material.Neon
			lump(parent, Vector3.new(3.2, 1, 3.2), foot + Vector3.yAxis * 13, rgb(60, 62, 72))
		end
	end
	for index = 0, 7 do
		local angle = index / 8 * math.pi * 2 + math.pi / 8
		local bed = centre + Vector3.new(math.cos(angle), 0, math.sin(angle)) * (size / 2 - 9)
		lump(parent, Vector3.new(7, 1.6, 7), bed + Vector3.yAxis * 0.5, rgb(110, 84, 60)) -- earth
		for bloom = 1, 5 do
			local turn = bloom / 5 * math.pi * 2
			local at = bed + Vector3.new(math.cos(turn) * 1.8, 1.5, math.sin(turn) * 1.8)
			lump(parent, Vector3.one * 1.3, at, BLOOMS[(bloom + index) % #BLOOMS + 1])
		end
		lump(parent, Vector3.one * 1.6, bed + Vector3.yAxis * 1.9, rgb(84, 160, 78))
	end
end

local function tree(parent: Instance, at: Vector3, pick: Random, leaf: Color3)
	local painted = prop(if pick:NextNumber() < 0.7 then "Tree" else "Pine")
	if painted then
		local turn = pick:NextNumber(0, math.pi * 2)
		local facing = Vector3.new(math.cos(turn), 0, math.sin(turn))
		stand(parent, painted, at, pick:NextNumber(15, 24), facing)
		return
	end
	local height = pick:NextNumber(7, 12)
	local trunk = Instance.new("Part")
	trunk.Shape = Enum.PartType.Cylinder
	trunk.Anchored = true
	trunk.Size = Vector3.new(height, 2, 2)
	trunk.CFrame = CFrame.new(at + Vector3.yAxis * height / 2) * CFrame.Angles(0, 0, math.rad(90))
	trunk.Color = TIMBER
	trunk.Material = Enum.Material.SmoothPlastic
	trunk.CanCollide = false -- scenery never blocks a path, a tamer or a patch of long grass
	trunk.Parent = parent
	local crown = pick:NextNumber(9, 14)
	local shade = leaf:Lerp(Color3.new(0, 0, 0), pick:NextNumber(0, 0.18))
	lump(
		parent,
		Vector3.new(crown, crown * 0.8, crown),
		at + Vector3.yAxis * (height + crown * 0.2),
		shade
	)
	lump(
		parent,
		Vector3.new(crown * 0.7, crown * 0.6, crown * 0.7),
		at + Vector3.new(pick:NextNumber(-3, 3), height + crown * 0.55, pick:NextNumber(-3, 3)),
		shade:Lerp(Color3.new(1, 1, 1), 0.12)
	)
end

local function bush(parent: Instance, at: Vector3, pick: Random, leaf: Color3)
	local painted = prop("Bush")
	if painted then
		local turn = pick:NextNumber(0, math.pi * 2)
		local facing = Vector3.new(math.cos(turn), 0, math.sin(turn))
		stand(parent, painted, at, pick:NextNumber(3, 5.5), facing)
		return
	end
	local width = pick:NextNumber(3, 6)
	lump(parent, Vector3.new(width, width * 0.7, width), at + Vector3.yAxis * width * 0.3, leaf)
	if pick:NextNumber() < 0.5 then
		lump(
			parent,
			Vector3.one * 0.9,
			at + Vector3.new(0, width * 0.62, 0),
			BLOOMS[pick:NextInteger(1, #BLOOMS)]
		)
	end
end

local function rock(parent: Instance, at: Vector3, pick: Random, stone: Color3)
	local width = pick:NextNumber(2, 6)
	lump(
		parent,
		Vector3.new(width, width * 0.6, width * 0.8),
		at + Vector3.yAxis * width * 0.2,
		stone
	)
end

local function flowers(parent: Instance, at: Vector3, pick: Random)
	local colour = BLOOMS[pick:NextInteger(1, #BLOOMS)]
	for _ = 1, pick:NextInteger(3, 6) do
		local spot = at + Vector3.new(pick:NextNumber(-2.5, 2.5), 0.5, pick:NextNumber(-2.5, 2.5))
		lump(parent, Vector3.one * 0.8, spot, colour)
	end
end

-- What grows in a biome, by its type: the leaf colour and how much of the scatter is rock.
local function growth(biome: WorldTypes.Biome): (Color3, Color3, number)
	if biome.element == "Sand" then
		return rgb(150, 160, 90), rgb(196, 150, 110), 0.6
	elseif biome.element == "Water" then
		return rgb(90, 170, 130), rgb(150, 160, 170), 0.4
	elseif biome.element == "Toxic" then
		return rgb(100, 130, 90), rgb(110, 110, 120), 0.3
	end
	return rgb(84, 160, 78), rgb(150, 150, 150), 0.12
end

-- Trees, bushes, rocks and flowers along both sides of every route and around the town, kept
-- clear of the paths. The same biome always gets the same scatter.
function Dressing.scatter(
	parent: Folder,
	biome: WorldTypes.Biome,
	map: Layout.Map,
	pathWidth: number
)
	local pick = Random.new(biome.number * 7919)
	local leaf, stone, rocky = growth(biome)
	local folder = Instance.new("Folder")
	folder.Name = "Dressing"
	folder.Parent = parent

	local function grow(at: Vector3)
		local roll = pick:NextNumber()
		if roll < rocky then
			rock(folder, at, pick, stone)
		elseif roll < rocky + (1 - rocky) * 0.5 then
			tree(folder, at, pick, leaf)
		elseif roll < rocky + (1 - rocky) * 0.8 then
			bush(folder, at, pick, leaf)
		else
			flowers(folder, at, pick)
		end
	end

	for _, route in biome.routes do
		local line = map.routes[route.id]
		if line then
			local along = 70 -- start clear of the town
			while along < route.length do
				for _, side in { -1, 1 } do
					local out = pathWidth / 2 + pick:NextNumber(10, 70)
					local point = Layout.pointAt(line, along, side * out)
					grow(Vector3.new(point.x, 0, point.z))
				end
				along += pick:NextNumber(16, 30)
			end
		end
	end
	-- A ring of growth round the town, outside its buildings.
	local reach = map.hub.size / 2 + 60
	for index = 1, 28 do
		local angle = index / 28 * math.pi * 2 + pick:NextNumber(-0.05, 0.05)
		local out = reach + pick:NextNumber(0, 60)
		grow(Vector3.new(map.hub.x + math.cos(angle) * out, 0, map.hub.z + math.sin(angle) * out))
	end
	-- Flowers dotted through the town itself.
	for _ = 1, 24 do
		local angle = pick:NextNumber(0, math.pi * 2)
		local out = pick:NextNumber(map.hub.size / 2 + 4, reach - 14)
		flowers(
			folder,
			Vector3.new(map.hub.x + math.cos(angle) * out, 0, map.hub.z + math.sin(angle) * out),
			pick
		)
	end
end

return Dressing
