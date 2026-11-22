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

local Storyline = require(ReplicatedStorage.content.Storyline)
local ClientState = require(script.Parent.Parent.State.ClientState)
local Bus = require(script.Parent.Parent.Net.Bus)
local Net = require(ReplicatedStorage.net.generated.Client)
local QuestProgress = require(ReplicatedStorage.shared.QuestProgress)
local Quests = require(ReplicatedStorage.content.Quests)
local World = require(ReplicatedStorage.shared.World)
local Species = require(ReplicatedStorage.content.Species)
local ToyBody = require(script.Parent.Parent.Creatures.ToyBody)
local WorldConfig = require(ReplicatedStorage.config.WorldConfig)
local WorldTypes = require(ReplicatedStorage.shared.WorldTypes)

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

local shown: { [number]: BasePart } = {}
local latest: { [number]: Wild } = {}

-- The player's wild creatures as last sent, for other screens (the test panel).
function WorldView.spawns(): { [number]: Wild }
	return latest
end

-- The height of the ground itself at a spot. Treetops, roofs, hedges and people are looked
-- through, so a creature never stands on a gatehouse or in a tree: ground is whatever is very
-- wide or very thin (the land, a lane, a plaza).
local function groundHeight(x: number, z: number): number
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local skipped: { Instance } = {}
	for _ = 1, 8 do
		params.FilterDescendantsInstances = skipped
		local hit = workspace:Raycast(Vector3.new(x, 500, z), Vector3.new(0, -1000, 0), params)
		if not hit then
			return 0
		end
		local size = hit.Instance.Size
		local thinnest = math.min(size.X, size.Y, size.Z)
		local widest = math.max(size.X, size.Y, size.Z)
		local middle = size.X + size.Y + size.Z - thinnest - widest
		-- Thin and broad both ways: a sign board or a fence rail is thin but narrow.
		if widest >= 100 or (thinnest <= 1.5 and middle >= 8) then
			return hit.Position.Y
		end
		table.insert(skipped, hit.Instance)
	end
	return 0
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
	-- The ball is only the thing the prompt and the name hang on; what the player sees is the
	-- creature's toy body standing there, breathing and blinking, turned its own way.
	ball.Transparency = 1
	local def = Species[wild.Torso]
	local toy = ToyBody.new(ball, wild.Torso, if def then def.element else "Leaf", wild.Size)
	local ground = Vector3.new(wild.X, groundHeight(wild.X, wild.Z), wild.Z)
	toy.place(CFrame.new(ground) * CFrame.Angles(0, math.rad((wild.Id * 73) % 360), 0))

	local board = Instance.new("BillboardGui")
	board.Size = UDim2.fromOffset(180, 34)
	board.StudsOffsetWorldSpace = Vector3.new(0, size / 2 + 2, 0)
	board.MaxDistance = 120
	board.Parent = ball
	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.Text = `Lv {wild.Level} {wild.Torso}`
	text.TextColor3 = RARITY_COLOURS[wild.Rarity] or RARITY_COLOURS.Common -- rarity, by colour
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

local function flagsSeen(): { [string]: boolean }
	local state = ClientState.get()
	local flags: { [string]: boolean } = {}
	local seen: { string } = if state then state.Flags else {}
	for _, flag in seen do
		flags[flag] = true
	end
	return flags
end

-- Talking to someone: move the story on if it is waiting for them, and take or hand in one of
-- the quests given at their place. The server checks every part of this again.
local function talk(who: string, place: string?)
	local flags = flagsSeen()
	local beat = World.nextBeat(Storyline, flags)
	if beat and beat.trigger.kind == "Talk" and beat.trigger.target == who then
		Net.CompleteBeat.Fire({ BeatId = beat.id, Choice = nil })
	end
	local state = ClientState.get()
	if not state or not place then
		return
	end
	local done: { [string]: boolean } = {}
	for _, id in state.QuestsDone do
		done[id] = true
	end
	local here: { WorldTypes.Quest } = {}
	for _, quest in Quests do
		if quest.giver.place == place then
			table.insert(here, quest)
		end
	end
	table.sort(here, function(a, b)
		return a.step < b.step
	end)
	-- Hand in a finished quest first; otherwise take the first one that is open.
	for _, quest in here do
		local progress = state.QuestsActive[quest.id]
		if progress ~= nil and progress >= QuestProgress.needed(quest) then
			Net.HandInQuest.Fire({ QuestId = quest.id })
			return
		end
	end
	for _, quest in World.availableQuests(here, done, flags) do
		if state.QuestsActive[quest.id] == nil then
			Net.AcceptQuest.Fire({ QuestId = quest.id })
			return
		end
	end
end

-- `openShop` shows the shop screen (the server still checks the player is at a shop).
function WorldView.start(openShop: () -> ())
	local made = Instance.new("Folder")
	made.Name = "WildCreatures"
	made.Parent = workspace

	Bus.listen(Net.WildSpawns, function(value)
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
		elseif kind == "Bait" then
			Net.UseBait.Fire({ SpotId = id })
		elseif kind == "Giant" then
			Net.StartGiant.Fire({ GiantId = id })
		elseif kind == "Shop" then
			openShop()
		elseif kind == "Talk" then
			local place = prompt:GetAttribute("Place")
			talk(id, if typeof(place) == "string" then place else nil)
			local role = prompt:GetAttribute("Role")
			if role == "Shop" then
				openShop()
			elseif role == "Teleport" then
				-- Travel to the next town the player has reached (round and round).
				local state = ClientState.get()
				local reached = if state then math.max(1, state.BiomeReached) else 1
				local here = prompt:GetAttribute("Biome")
				if reached > 1 and typeof(here) == "number" then
					Net.Travel.Fire({ BiomeNumber = here % reached + 1 })
				end
			elseif role == "Healer" then
				Net.HealAtHealer.Fire(true) -- free; the server checks the player is standing here
			end
		end
	end)
end

return WorldView
