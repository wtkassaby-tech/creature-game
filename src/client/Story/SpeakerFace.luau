--!strict
-- Who is speaking, shown the way an old handheld game shows it: the speaker's name on a small
-- tab that sits on the top edge of the dialogue box, and, for the people who have a painted
-- model, their face in a frame at the left of the box. Looks only.

local AssetService = game:GetService("AssetService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")

local Kit = require(script.Parent.Parent.UI.Kit)
local Biomes = require(ReplicatedStorage.content.Biomes)
local PersonModel = require(ReplicatedStorage.shared.PersonModel)
local PropModels = require(ReplicatedStorage.content.PropModels)
local Tamers = require(ReplicatedStorage.content.Tamers)

local SpeakerFace = {}

export type View = {
	-- Shows who is speaking. Returns how many pixels of the box's left the face takes (0 for
	-- none), so the caller can start the words to the right of it.
	show: (speaker: string) -> number,
}

local FACE = 104 -- the picture frame, in pixels
local TAB_TALL = 30

-- Speakers with a face that is not a named person standing in the world. Everyone else is read
-- from the data below, so a new tamer or keeper gets their face with no change here. A speaker
-- with no person in the world has a name tab and no picture: better none than the wrong face.
local FACES: { [string]: string } = {
	Mentor = "Mentor",
	Rival = "Rival",
	Marlow = "Shopkeeper",
	["Marlow Tuppence"] = "Shopkeeper",
	Sign = "Signpost",
}

-- Every named person in the world, as the world dresses them: tamers on the routes (by name),
-- story opponents (their block is called "Name (battle_id)") and the keepers of hub buildings
-- that have a named character (by character id). A speaker is matched by first or last name;
-- one name shared by two people in different clothes gets no face. Built on first use.
local people: { [string]: string }? = nil
local function personFaces(): { [string]: string }
	if people then
		return people
	end
	local list: { PersonModel.Person } = {}
	for _, tamer in Tamers.locals do
		table.insert(list, { name = tamer.name, worldName = tamer.name })
	end
	for _, battle in Tamers.story do
		table.insert(list, { name = battle.name, worldName = `{battle.name} ({battle.id})` })
	end
	for _, biome in Biomes do
		for _, building in biome.hub.buildings do
			if building.npc then
				table.insert(list, { name = building.npc, worldName = building.npc })
			end
		end
	end
	local made = PersonModel.index(list, function(seed: number): number
		return Random.new(seed):NextNumber()
	end)
	people = made
	return made
end

local function faceFor(speaker: string): string?
	return FACES[speaker] or personFaces()[string.lower(speaker)]
end

local templates: { [string]: MeshPart } = {}
local failed: { [string]: boolean } = {}

local function template(name: string): MeshPart?
	if templates[name] or failed[name] then
		return templates[name]
	end
	local def = PropModels[name]
	if not def then
		failed[name] = true
		return nil
	end
	local ok, made = pcall(function(): MeshPart
		return AssetService:CreateMeshPartAsync(Content.fromUri(def.mesh))
	end)
	if ok then
		made.TextureID = def.texture
		made.Size = Vector3.new(def.size[1], def.size[2], def.size[3])
		made.Anchored = true
		made.Material = Enum.Material.SmoothPlastic
		templates[name] = made
	else
		warn(`[SpeakerFace] {name}: model did not load ({made})`)
		failed[name] = true
	end
	return templates[name]
end

function SpeakerFace.new(gui: Instance, box: GuiObject): View
	-- The name tab: on the box's top edge, a little in from its left.
	local tab = Kit.panel(gui, UDim2.fromOffset(120, TAB_TALL), UDim2.new())
	tab.AnchorPoint = Vector2.new(0, 1)
	tab.Position = box.Position + UDim2.fromOffset(18, 6)
	tab.ZIndex = 3
	local name = Kit.label(tab, "", UDim2.new(1, -16, 1, -8), UDim2.fromOffset(8, 3), 18)
	name.TextXAlignment = Enum.TextXAlignment.Center
	name.ZIndex = 4
	Kit.pixel(name, 16)

	-- The face: a framed window on to the speaker's model, head and shoulders.
	local frame = Instance.new("ViewportFrame")
	frame.Size = UDim2.fromOffset(FACE, FACE)
	frame.Position = UDim2.fromOffset(13, 13)
	frame.BackgroundColor3 = Kit.COLOURS.panelLight
	frame.BorderSizePixel = 0
	frame.Ambient = Color3.fromRGB(190, 184, 176)
	frame.LightColor = Color3.fromRGB(255, 244, 226)
	frame.LightDirection = Vector3.new(-0.4, -0.7, 0.6)
	frame.Visible = false
	frame.Parent = box
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = frame
	local edge = Instance.new("UIStroke")
	edge.Color = Kit.COLOURS.outline
	edge.Thickness = 3
	edge.Parent = frame
	local camera = Instance.new("Camera")
	camera.FieldOfView = 30
	camera.Parent = frame
	frame.CurrentCamera = camera

	local showing: string? = nil
	local standing: MeshPart? = nil
	local function setFace(modelName: string?)
		if modelName == showing then
			return
		end
		showing = modelName
		if standing then
			standing:Destroy()
			standing = nil
		end
		frame.Visible = false
		if not modelName then
			return
		end
		task.spawn(function()
			local made = template(modelName)
			if not made or showing ~= modelName then
				return
			end
			local copy = made:Clone()
			copy.CFrame = CFrame.new()
			copy.Parent = frame
			standing = copy
			-- The model's front is -Z. Frame the top of it: a face for a person, the boards
			-- for a signpost.
			local size = copy.Size
			local lookAt = Vector3.new(0, size.Y * 0.2, 0)
			local back = size.Y * 0.3 / math.tan(math.rad(15)) + size.Z / 2
			camera.CFrame =
				CFrame.lookAt(lookAt + Vector3.new(size.X * 0.25, size.Y * 0.04, -back), lookAt)
			frame.Visible = true
		end)
	end

	return {
		show = function(speaker: string): number
			name.Text = speaker
			local wide =
				TextService:GetTextSize(speaker, 16, Kit.FONT_PIXEL, Vector2.new(600, TAB_TALL)).X
			tab.Size = UDim2.fromOffset(math.clamp(wide + 34, 90, 320), TAB_TALL)
			tab.Visible = speaker ~= ""
			local modelName = faceFor(speaker)
			setFace(modelName)
			return if modelName and not failed[modelName] then FACE + 14 else 0
		end,
	}
end

return SpeakerFace
