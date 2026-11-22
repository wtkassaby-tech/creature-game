--!strict
-- The things on the test map that players use, and the helpers for placing them: plain blocks
-- with floating names, ProximityPrompts with the attributes the device reads (PromptKind,
-- PromptId, and for keepers Place, Role and Biome), people standing on the ground and turned
-- the way the map sheet says, and the hub's buildings with their keepers. Split from TestMap,
-- which lays out the biomes.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Layout = require(ReplicatedStorage.shared.Layout)
local WorldConfig = require(ReplicatedStorage.config.WorldConfig)
local WorldTypes = require(ReplicatedStorage.shared.WorldTypes)

local Dressing = require(script.Parent.Dressing)
local Props = require(script.Parent.Props)

local Markers = {}

local WOOD = Color3.fromRGB(140, 105, 70)
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

-- The ground's height at a flat spot: a ray straight down onto the biome's ground pieces only,
-- so people stand on it even where it is raised. Flat ground (0) if nothing is hit.
local groundPieces: { Instance } = {}
local function groundAt(point: Layout.Point): number
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = groundPieces
	local hit =
		Workspace:Raycast(Vector3.new(point.x, 200, point.z), Vector3.new(0, -400, 0), params)
	return if hit then hit.Position.Y else 0
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

-- A person standing at `point`. `toward` is a spot they look at; `faces` (degrees clockwise from
-- north) turns them instead when given. `model` names their painted villager.
local function person(
	parent: Instance,
	name: string,
	point: Layout.Point,
	toward: Vector3?,
	faces: number?,
	model: string?
): Part
	local body = block(parent, name, Vector3.new(3, 6, 2), at(point, groundAt(point) + 3.4), PERSON)
	-- People with a real name wear it; a keeper known only by an id ("healer_keeper") does not,
	-- since the building already says what it is. The rival's battle id is left off.
	local shown = string.gsub(name, "%s*%b()", "")
	if string.find(shown, "%u") and not string.find(shown, "_", 1, true) and model == nil then
		label(body, shown)
	end
	local look = toward
	if faces then
		look = Vector3.new(point.x, 0, point.z) + Props.facing(faces) * 10
	end
	-- The same name always dresses the same way.
	local pick = Random.new(#name * 131 + string.byte(name, 1) + string.byte(name, #name))
	Dressing.person(body, pick, name, look, model)
	return body
end

-- The hub's buildings and their keepers, each with a Talk prompt.
local function buildings(
	hub: Folder,
	biome: WorldTypes.Biome,
	map: Layout.Map,
	dressing: WorldTypes.DressingSheet?
)
	local square = Vector3.new(map.hub.x, 0, map.hub.z)
	for _, building in biome.hub.buildings do
		local middle = map.buildings[building.id]
		local faces = map.faces[building.id]
		local facing = if faces then Props.facing(faces) else nil
		local footprint = if dressing then dressing.buildings[building.id] else nil
		local house: Part
		if building.id == "ring" and footprint and facing then
			-- The Ring is an open sand floor inside a rail, not a house.
			house = block(
				hub,
				building.id,
				Vector3.new(footprint.width, 0.4, footprint.depth),
				at(middle, 0.3),
				Color3.fromRGB(226, 204, 150)
			)
			-- Facing along `facing` puts the oval's width (its X) across it, as the sheet says.
			house.CFrame = CFrame.lookAt(house.Position, house.Position + facing)
			local mesh = Instance.new("SpecialMesh")
			mesh.MeshType = Enum.MeshType.Sphere
			mesh.Parent = house
			label(house, building.name)
		elseif map.models[building.id] == "Tree" and footprint and facing then
			house = block(
				hub,
				building.id,
				Vector3.new(footprint.width, 18, footprint.depth),
				at(middle, 9.4),
				WOOD
			)
			label(house, building.name)
			Dressing.noticeOak(house, facing, Random.new(#building.id * 977))
		else
			local width = if footprint then footprint.width else 24
			local depth = if footprint then footprint.depth else 24
			house = block(hub, building.id, Vector3.new(width, 18, depth), at(middle, 9.4), WOOD)
			label(house, building.name)
			Dressing.house(
				house,
				building.role,
				square,
				map.models[building.id],
				facing,
				if footprint then footprint.tall else nil
			)
		end
		-- Every building's keeper stands at its door. Talking to one moves the story on if the
		-- story is waiting for them, and offers or takes in that place's quests.
		local keeper = building.npc or `{building.id}_keeper`
		local body =
			person(hub, keeper, map.places[building.id], square, map.faces[keeper] or faces)
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
end

-- Counts a part as ground that people stand on (see groundAt).
function Markers.addGround(piece: BasePart)
	table.insert(groundPieces, piece)
end

Markers.block = block
Markers.label = label
Markers.prompt = prompt
Markers.at = at
Markers.slab = slab
Markers.person = person
Markers.buildings = buildings

return Markers
