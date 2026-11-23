--!strict
-- Life for the test map: warm light and soft clouds, houses with roofs, doors and windows,
-- people with heads, and trees, bushes, rocks and flowers along the routes. The test map is
-- still a stand-in for the real one, but a bare grey-box world made every screen feel dead
-- (Ayrton, 23 November 2026: "really blocky and soulless, we need soul here").
-- Painted models come from src/content/PropModels.luau through Props; plain rounded parts in flat
-- colours stand in for any that are missing. A biome with a map sheet is dressed on purpose by
-- Corridors, Scenery and Landmarks; a biome without one gets Scatter.luau.
-- TODO(art): replaced, with the test map, by the real Greenwood.

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local PersonModel = require(game:GetService("ReplicatedStorage").shared.PersonModel)
local Props = require(script.Parent.Props)
local Shapes = require(script.Parent.Shapes)

local Dressing = {}

local rgb = Props.rgb
local part = Props.part
local lump = Props.lump
local prop = Props.model
local stand = Props.stand

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

-- The one effect of a class under Lighting: the first one found (the client's Climate drives the
-- first), a new one from `make` if there is none, and every extra destroyed. The saved place
-- already carries some, and Dressing.mood used to add more at every start, so play had three of
-- each.
local function onlyOne(class: string, make: () -> Instance): Instance
	local found: Instance? = nil
	for _, child in Lighting:GetChildren() do
		if child.ClassName == class then
			if found == nil then
				found = child
			else
				child:Destroy()
			end
		end
	end
	local one = found or make()
	one.Parent = Lighting
	return one
end

-- Golden late-afternoon light, a little warm haze and drifting clouds (the art direction in
-- docs/research/games/07_APPEAL.md, section 4).
function Dressing.mood()
	Lighting.ClockTime = 16.6
	Lighting.GeographicLatitude = 35
	Lighting.Brightness = 2.6
	Lighting.Ambient = rgb(122, 108, 100)
	Lighting.OutdoorAmbient = rgb(150, 138, 124)
	Lighting.ColorShift_Top = rgb(255, 214, 160)
	Lighting.ColorShift_Bottom = rgb(110, 96, 140)
	Lighting.ExposureCompensation = -0.1
	Lighting.ShadowSoftness = 0.45
	Lighting.EnvironmentDiffuseScale = 0.6
	Lighting.EnvironmentSpecularScale = 0.06 -- matte clay: low shine (Studio, 23 Nov)

	local air = onlyOne("Atmosphere", function()
		return Instance.new("Atmosphere")
	end) :: Atmosphere
	air.Density = 0.3
	air.Offset = 0.2
	air.Color = rgb(255, 228, 196)
	air.Decay = rgb(176, 144, 150)
	air.Glare = 0.2
	air.Haze = 0.8

	local grade = onlyOne("ColorCorrectionEffect", function()
		return Instance.new("ColorCorrectionEffect")
	end) :: ColorCorrectionEffect
	grade.Saturation = 0.08 -- the painted models are already rich
	grade.Contrast = 0.1
	grade.TintColor = rgb(255, 242, 222)

	local glow = onlyOne("BloomEffect", function()
		return Instance.new("BloomEffect")
	end) :: BloomEffect
	glow.Intensity = 0.3
	glow.Size = 24
	glow.Threshold = 1.2

	local rays = onlyOne("SunRaysEffect", function()
		return Instance.new("SunRaysEffect")
	end) :: SunRaysEffect
	rays.Intensity = 0.06
	rays.Spread = 0.6

	local terrain = Workspace:FindFirstChildOfClass("Terrain")
	if terrain and not terrain:FindFirstChildOfClass("Clouds") then
		local clouds = Instance.new("Clouds")
		clouds.Cover = 0.55
		clouds.Density = 0.6
		clouds.Color = rgb(255, 255, 255)
		clouds.Parent = terrain
	end
end

-- Turns a plain block into a building: the painted model it wears, or plaster walls, a pitched
-- roof in the colour of what the building is for, a door and two windows on its front, and a
-- chimney. `facing` turns its front that way (a designed map); left out, the front faces the
-- town square. `model` names the painted model (the map sheet's); left out, it follows the role.
-- `tall` is how high the painted model stands.
function Dressing.house(
	house: Part,
	role: string,
	square: Vector3,
	model: string?,
	facing: Vector3?,
	tall: number?
)
	local centre = house.Position
	local toSquare = Vector3.new(square.X - centre.X, 0, square.Z - centre.Z)
	if facing and facing.Magnitude > 1e-3 then
		house.CFrame = CFrame.lookAt(centre, centre + facing.Unit)
	elseif toSquare.Magnitude > 1 then
		house.CFrame = CFrame.lookAt(centre, centre + toSquare.Unit) -- front (-Z) faces the square
	end
	local kind = model
		or (if role == "Shop" then "Shop" elseif role == "Healer" then "Healer" else "Cottage")
	local painted = prop(kind)
	if painted then
		-- The plain block stays as the thing you bump into; the painted model is what you see.
		house.Transparency = 1
		local height = tall or 26
		local sign = house:FindFirstChildOfClass("BillboardGui")
		if sign then
			sign.StudsOffsetWorldSpace = Vector3.new(0, height - house.Size.Y / 2 + 2, 0)
		end
		local foot = house.Position - Vector3.yAxis * house.Size.Y / 2
		local copy = stand(house, painted, foot, height, house.CFrame.LookVector)
		copy.Name = kind
		return
	end
	-- A canyon or seaside building's own plain stand-in (an adobe trading post, a bottle kiln).
	local foot = house.Position - Vector3.yAxis * house.Size.Y / 2
	local ground = CFrame.lookAt(foot, foot + house.CFrame.LookVector)
	if model and Shapes.building(house, model, ground, house.Size.X, house.Size.Z, tall or 26) then
		house.Transparency = 1
		local sign = house:FindFirstChildOfClass("BillboardGui")
		if sign then
			sign.StudsOffsetWorldSpace = Vector3.new(0, (tall or 26) - house.Size.Y / 2 + 2, 0)
		end
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

-- The Notice Oak: a great tree over a plain trunk block, with the notice board on its front.
function Dressing.noticeOak(trunk: Part, facing: Vector3, pick: Random)
	trunk.CFrame = CFrame.lookAt(trunk.Position, trunk.Position + facing)
	trunk.Color = TIMBER
	local foot = trunk.Position - Vector3.yAxis * trunk.Size.Y / 2
	local sign = trunk:FindFirstChildOfClass("BillboardGui")
	if sign then
		sign.StudsOffsetWorldSpace = Vector3.new(0, 38 - trunk.Size.Y / 2, 0)
	end
	local tree = prop("Tree")
	if tree then
		trunk.Transparency = 1
		stand(trunk, tree, foot, 15.54 * 2.2, facing)
	else
		Props.tree(trunk, foot, "Tree", 2.2, pick)
	end
	local boardFoot = foot + facing * 3.6
	local board = prop("NoticeBoard")
	if board then
		stand(trunk, board, boardFoot, 7, facing)
	else
		local frame = CFrame.lookAt(boardFoot, boardFoot + facing)
		part(trunk, Vector3.new(0.6, 6, 0.6), frame * CFrame.new(-2.4, 3, 0), TIMBER)
		part(trunk, Vector3.new(0.6, 6, 0.6), frame * CFrame.new(2.4, 3, 0), TIMBER)
		part(trunk, Vector3.new(5.4, 3.4, 0.3), frame * CFrame.new(0, 4.4, 0), rgb(200, 160, 110))
		for k = -1, 1 do
			part(trunk, Vector3.new(1.2, 1.5, 0.1), frame * CFrame.new(k * 1.6, 4.4, -0.2), WALL)
		end
	end
end

-- Which villager model a person wears, from their name. Tamers out on the routes are one of
-- two, chosen by `pick`, so the same tamer always looks the same. The rule itself is
-- src/shared/PersonModel, shared with the dialogue faces so the two can never drift apart.
local function villager(name: string, pick: Random): string
	return PersonModel.villager(name, pick:NextNumber())
end

-- Gives a plain block of a person a body: a painted villager if there is one for them (or the
-- named `model`), turned to face `toward`; otherwise a head, hair and a coloured shirt. `pick`
-- chooses the colours, so the same person looks the same every time.
function Dressing.person(body: Part, pick: Random, name: string, toward: Vector3?, model: string?)
	local painted = (if model then prop(model) else nil)
		or prop(villager(name, pick))
		or prop("Tamer")
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

-- The town square: a village green with a round cobbled plaza in the middle. `designed` gives
-- the plaza's size and the well's spot from a dressing sheet, whose own lamps and flower beds
-- are built elsewhere; left out, the plaza scales with the square and lamps and beds ring it.
function Dressing.square(
	parent: Instance,
	centre: Vector3,
	size: number,
	designed: {
		plaza: number,
		rim: number,
		well: Vector3?,
		green: Color3,
		colour: Color3?,
		rimColour: Color3?,
	}?
)
	local half = size / 2 - 5
	local slab = parent:FindFirstChild("Square")
	if slab and slab:IsA("BasePart") then
		slab.Color = if designed then designed.green else rgb(138, 196, 104)
	end
	local across = if designed then designed.plaza else size * 0.62
	local rimAcross = if designed then designed.rim else size * 0.66
	local plaza = Instance.new("Part")
	plaza.Name = "Plaza"
	plaza.Shape = Enum.PartType.Cylinder
	plaza.Anchored = true
	plaza.Size = Vector3.new(0.3, across, across)
	plaza.CFrame = CFrame.new(centre + Vector3.yAxis * 0.45) * CFrame.Angles(0, 0, math.rad(90))
	plaza.Color = (if designed then designed.colour else nil) or rgb(222, 204, 168)
	plaza.Material = Enum.Material.SmoothPlastic
	plaza.Parent = parent
	local rim = plaza:Clone()
	rim.Name = "PlazaRim"
	rim.Size = Vector3.new(0.24, rimAcross, rimAcross)
	rim.Color = (if designed then designed.rimColour else nil) or rgb(170, 150, 120)
	rim.Parent = parent
	local well = prop("Well")
	local wellAt = if designed then designed.well else centre + Vector3.new(18, 0, -12)
	if well and wellAt then
		stand(parent, well, wellAt + Vector3.yAxis * 0.4, 10, Vector3.zAxis)
	end
	if designed then
		return
	end
	for _, x in { -1, 1 } do
		for _, z in { -1, 1 } do
			Props.lamp(
				parent,
				centre + Vector3.new(x * half, 0, z * half),
				Vector3.new(-x, 0, -z).Unit
			)
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

return Dressing
