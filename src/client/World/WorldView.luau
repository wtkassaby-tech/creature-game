--!strict
-- Draws the player's own wild creatures in the world and turns the world's prompts into
-- requests. The server decides everything: a prompt is only a button, and the server checks the
-- player's position itself when the request arrives.
--
-- Wild creatures are drawn as plain coloured balls with a name tag for now.
-- TODO(art): draw them with the creature assembler once the part meshes exist.
-- Not yet run in Studio.

local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Chapter1 = require(ReplicatedStorage.content.story.Chapter1)
local ClientState = require(script.Parent.Parent.State.ClientState)
local Net = require(ReplicatedStorage.net.generated.Client)
local World = require(ReplicatedStorage.shared.World)
local WorldConfig = require(ReplicatedStorage.config.WorldConfig)

export type Wild = {
	Id: number,
	X: number,
	Z: number,
	Torso: string,
	Colour: string,
	Size: number,
	Rarity: string,
	Level: number,
}

local WorldView = {}

local RARITY_COLOURS: { [string]: Color3 } = {
	Common = Color3.fromRGB(235, 235, 235),
	Uncommon = Color3.fromRGB(120, 200, 120),
	Gem = Color3.fromRGB(110, 170, 255),
	Ruby = Color3.fromRGB(230, 80, 90),
	Diamond = Color3.fromRGB(170, 240, 255),
	Cosmic = Color3.fromRGB(190, 120, 255),
}

local folder: Folder? = nil
local shown: { [number]: BasePart } = {}
local latest: { [number]: Wild } = {}

-- The player's wild creatures as last sent, for other screens (the test panel).
function WorldView.spawns(): { [number]: Wild }
	return latest
end

local function groundHeight(x: number, z: number): number
	local hit = workspace:Raycast(Vector3.new(x, 500, z), Vector3.new(0, -1000, 0))
	return if hit then hit.Position.Y else 0
end

local function draw(parent: Instance, wild: Wild): BasePart
	local ball = Instance.new("Part")
	ball.Name = `Wild{wild.Id}`
	ball.Shape = Enum.PartType.Ball
	ball.Anchored = true
	ball.CanCollide = false
	local size = 4 * wild.Size
	ball.Size = Vector3.new(size, size, size)
	ball.Position = Vector3.new(wild.X, groundHeight(wild.X, wild.Z) + size / 2, wild.Z)
	ball.Color = RARITY_COLOURS[wild.Rarity] or RARITY_COLOURS.Common
	ball.Material = Enum.Material.SmoothPlastic

	local board = Instance.new("BillboardGui")
	board.Size = UDim2.fromOffset(180, 34)
	board.StudsOffsetWorldSpace = Vector3.new(0, size / 2 + 2, 0)
	board.MaxDistance = 120
	board.Parent = ball
	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.Text = `Lv {wild.Level} {wild.Torso}`
	text.TextColor3 = Color3.new(1, 1, 1)
	text.TextStrokeTransparency = 0.3
	text.Font = Enum.Font.GothamBold
	text.TextScaled = true
	text.Parent = board

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Battle"
	prompt.ObjectText = wild.Torso
	prompt.MaxActivationDistance = WorldConfig.ENGAGE_RADIUS
	prompt.RequiresLineOfSight = false
	prompt:SetAttribute("PromptKind", "Wild")
	prompt:SetAttribute("SpawnId", wild.Id)
	prompt.Parent = ball

	ball.Parent = parent
	return ball
end

local function nextBeatId(): string?
	local state = ClientState.get()
	local flags: { [string]: boolean } = {}
	local seen: { string } = if state then state.Flags else {}
	for _, flag in seen do
		flags[flag] = true
	end
	local beat = World.nextBeat(Chapter1, flags)
	return if beat then beat.id else nil
end

function WorldView.start()
	local made = Instance.new("Folder")
	made.Name = "WildCreatures"
	made.Parent = workspace
	folder = made

	Net.WildSpawns.On(function(value)
		local keep: { [number]: boolean } = {}
		latest = {}
		for _, sent in value.Spawns do
			local wild: Wild = {
				Id = sent.Id,
				X = sent.X,
				Z = sent.Z,
				Torso = sent.Torso,
				Colour = sent.Colour,
				Size = sent.Size,
				Rarity = sent.Rarity,
				Level = sent.Level,
			}
			keep[wild.Id] = true
			latest[wild.Id] = wild
			if not shown[wild.Id] then
				shown[wild.Id] = draw(made, wild)
			end
		end
		for id, part in shown do
			if not keep[id] then
				part:Destroy()
				shown[id] = nil
			end
		end
	end)

	ProximityPromptService.PromptTriggered:Connect(function(prompt)
		local kind = prompt:GetAttribute("PromptKind")
		if kind == "Wild" then
			local id = prompt:GetAttribute("SpawnId")
			if typeof(id) == "number" then
				Net.StartBattle.Fire({ Kind = "Wild", TargetId = id, TargetName = nil })
			end
			return
		end
		local id = prompt:GetAttribute("PromptId")
		if typeof(id) ~= "string" then
			return
		end
		if kind == "Tamer" then
			Net.StartBattle.Fire({ Kind = "Tamer", TargetId = 0, TargetName = id })
		elseif kind == "Rival" then
			Net.StartBattle.Fire({ Kind = "Rival", TargetId = 0, TargetName = id })
		elseif kind == "Rustle" then
			Net.Rustle.Fire({ SpotId = id })
		elseif kind == "Talk" then
			-- Talking moves the story on only if the story is waiting for this character;
			-- the server checks that, and that the player is standing beside them.
			local beat = nextBeatId()
			if beat then
				Net.CompleteBeat.Fire({ BeatId = beat, Choice = nil })
			end
		end
	end)
end

return WorldView
