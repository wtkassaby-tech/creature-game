--!strict
-- Wild creatures are never drawn standing in the open. They hide in the long grass: where one
-- hides there is only a clump of blades that sways now and then (and sparkles if it is rare).
-- Walking up to it starts the encounter: a "!" and a burst of leaves, then the request. The
-- server decides everything: the request only names the spawn, and the server checks the
-- player's position itself when it arrives. Nothing here shows a species or a level.
-- Also turns the world's prompts into requests. Not yet run in Studio.

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Storyline = require(ReplicatedStorage.content.Storyline)
local ClientState = require(script.Parent.Parent.State.ClientState)
local Kit = require(script.Parent.Parent.UI.Kit)
local Particles = require(script.Parent.Parent.Fx.Particles)
local Transition = require(script.Parent.Parent.UI.Transition)
local Bus = require(script.Parent.Parent.Net.Bus)
local Net = require(ReplicatedStorage.net.generated.Client)
local QuestProgress = require(ReplicatedStorage.shared.QuestProgress)
local Quests = require(ReplicatedStorage.content.Quests)
local World = require(ReplicatedStorage.shared.World)
local WorldConfig = require(ReplicatedStorage.config.WorldConfig)
local WorldTypes = require(ReplicatedStorage.shared.WorldTypes)

export type Wild = {
	Id: number,
	X: number,
	Z: number,
	Rarity: string,
	Spot: boolean,
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

-- A clump of taller blades marks where a creature hides: it is the only thing drawn (no model,
-- no name, no level), and it sways now and then. A rarer creature also lets motes drift up from
-- it in its rarity's colour. Nothing here shows what is hiding.
type Hidden = {
	wild: Wild,
	root: Part,
	ground: Vector3,
	blades: { { part: BasePart, foot: Vector3, height: number, turn: number } },
	alive: boolean,
	fresh: boolean, -- brought out by a rustle spot or bait: steps out as soon as it is seen
}

local shown: { [number]: Hidden } = {}
local calmUntil: { [number]: number } = {} -- spawn id -> when it may start another encounter
local pausedUntil = 0 -- no new encounter before this time (one is already under way)

local BLADE_LIGHT = Color3.fromRGB(112, 190, 78)
local BLADE_DARK = Color3.fromRGB(80, 156, 64)

local function bladeCFrame(
	blade: { part: BasePart, foot: Vector3, height: number, turn: number },
	lean: Vector3
): CFrame
	return CFrame.new(blade.foot)
		* CFrame.Angles(0, blade.turn, 0)
		* CFrame.Angles(lean.X, 0, lean.Z)
		* CFrame.new(0, blade.height / 2, 0)
end

local function leafColour(): Color3
	return BLADE_LIGHT
end

local function draw(parent: Instance, wild: Wild): Hidden
	local ground = Vector3.new(wild.X, groundHeight(wild.X, wild.Z), wild.Z)
	local root = Instance.new("Part")
	root.Name = `Hidden{wild.Id}`
	root.Anchored = true
	root.CanCollide = false
	root.CanQuery = false
	root.CanTouch = false
	root.CastShadow = false
	root.Transparency = 1
	root.Size = Vector3.new(4, 0.2, 4)
	root.Position = ground + Vector3.new(0, 0.2, 0)
	local hidden: Hidden =
		{ wild = wild, root = root, ground = ground, blades = {}, alive = true, fresh = wild.Spot }
	local count = if wild.Spot then 0 else 7
	for index = 1, count do
		local around = (index / count) * math.pi * 2 + wild.Id
		local reach = if index == 1 then 0 else 1.3 + (index % 3) * 0.35
		local height = 3.6 + (index % 3) * 0.5
		local blade = Instance.new("WedgePart")
		blade.Anchored = true
		blade.CanCollide = false
		blade.CanQuery = false
		blade.CanTouch = false
		blade.CastShadow = false
		blade.Material = Enum.Material.SmoothPlastic
		blade.Color = if index % 2 == 0 then BLADE_LIGHT else BLADE_DARK
		blade.Size = Vector3.new(0.45, height, 1.2)
		local record = {
			part = blade :: BasePart,
			foot = ground + Vector3.new(math.cos(around) * reach, 0.1, math.sin(around) * reach),
			height = height,
			turn = around * 2,
		}
		blade.CFrame = bladeCFrame(record, Vector3.zero)
		blade.Parent = root
		table.insert(hidden.blades, record)
	end
	local rate = WorldConfig.TELL_RATE[wild.Rarity] or 0
	local colour = RARITY_COLOURS[wild.Rarity]
	if rate > 0 and colour then
		local motes = Particles.emitter(root, "motes", colour, 1.3)
		motes.Rate = rate
		motes.Enabled = true
	end
	root.Parent = parent

	-- Every few seconds the clump leans over and back, and sometimes a leaf or two lifts off.
	task.spawn(function()
		local pick = Random.new(wild.Id * 7919)
		task.wait(pick:NextNumber(0, WorldConfig.RUSTLE_EVERY_MAX))
		while hidden.alive do
			local camera = workspace.CurrentCamera
			local near = camera ~= nil
				and (camera.CFrame.Position - ground).Magnitude
					<= WorldConfig.RUSTLE_SEE_DISTANCE
			if near and #hidden.blades > 0 then
				local side = pick:NextNumber(-1, 1)
				for _, blade in hidden.blades do
					local lean =
						Vector3.new(math.rad(12) * side, 0, math.rad(14) * pick:NextNumber(0.4, 1))
					TweenService
						:Create(
							blade.part,
							TweenInfo.new(
								0.2,
								Enum.EasingStyle.Sine,
								Enum.EasingDirection.Out,
								0,
								true
							),
							{ CFrame = bladeCFrame(blade, lean) }
						)
						:Play()
				end
				if pick:NextNumber() < 0.5 then
					Particles.burst(
						parent,
						ground + Vector3.new(0, 2.5, 0),
						"leafFlutter",
						leafColour(),
						2,
						0.7,
						2
					)
				end
			end
			task.wait(pick:NextNumber(WorldConfig.RUSTLE_EVERY_MIN, WorldConfig.RUSTLE_EVERY_MAX))
		end
	end)
	return hidden
end

-- The "!" beat: a mark pops over the player's head, the grass bursts into leaves where the
-- creature was, and then the request goes out (the battle wipe is BattleView's, when the server
-- answers). The player stands still for the beat.
local function startEncounter(parent: Instance, hidden: Hidden)
	local player = Players.LocalPlayer
	local character = player.Character
	local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
	local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
	local speed = if humanoid then humanoid.WalkSpeed else 16
	if humanoid then
		humanoid.WalkSpeed = 0
	end
	if root and root:IsA("BasePart") then
		local board = Instance.new("BillboardGui")
		board.Size = UDim2.fromScale(2.2, 2.2)
		board.StudsOffsetWorldSpace = Vector3.new(0, 4.6, 0)
		board.AlwaysOnTop = true
		board.LightInfluence = 0
		board.Adornee = root
		local mark = Instance.new("TextLabel")
		mark.Size = UDim2.fromScale(0, 0)
		mark.AnchorPoint = Vector2.new(0.5, 0.5)
		mark.Position = UDim2.fromScale(0.5, 0.5)
		mark.BackgroundTransparency = 1
		mark.Text = "!"
		mark.Font = Kit.FONT
		mark.TextScaled = true
		mark.TextColor3 = Color3.fromRGB(255, 214, 80)
		mark.TextStrokeColor3 = Kit.COLOURS.outline
		mark.TextStrokeTransparency = 0
		mark.Parent = board
		board.Parent = root
		TweenService:Create(
			mark,
			TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Size = UDim2.fromScale(1, 1) }
		):Play()
		Debris:AddItem(board, 0.8)
	end
	local at = hidden.ground + Vector3.new(0, 1.5, 0)
	Particles.burst(parent, at, "leafFlutter", leafColour(), 16, 1.4, 6)
	Particles.burst(parent, at, "dustKick", Color3.fromRGB(150, 190, 110), 6, 1, 4)
	local tint = RARITY_COLOURS[hidden.wild.Rarity]
	if tint and hidden.wild.Rarity ~= "Common" then
		Particles.burst(parent, at, "sparkle", tint, 10, 1, 4)
	end
	task.delay(WorldConfig.ENCOUNTER_BEAT_SECONDS, function()
		if humanoid and humanoid.Parent then
			humanoid.WalkSpeed = speed
		end
		Net.StartBattle.Fire({ Kind = "Wild", TargetId = hidden.wild.Id, TargetName = nil })
	end)
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
				Rarity = sent.Rarity,
				Spot = sent.Spot,
			}
			keep[wild.Id] = true
			latest[wild.Id] = wild
			if not shown[wild.Id] then
				shown[wild.Id] = draw(made, wild)
			end
		end
		for id, hidden in shown do
			if not keep[id] then
				hidden.alive = false
				hidden.root:Destroy()
				shown[id] = nil
				calmUntil[id] = nil
			end
		end
	end)

	-- Walking up to a hidden creature (or having one step out of a rustle spot) starts the
	-- encounter. The device only asks; the server checks the spawn is the player's own, free,
	-- and within a few studs of where it sees the player.
	local sinceLook = 0
	RunService.Heartbeat:Connect(function(step)
		sinceLook += step
		if sinceLook < 0.1 then
			return
		end
		sinceLook = 0
		local character = Players.LocalPlayer.Character
		local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
		local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
		if not (root and root:IsA("BasePart")) or not humanoid or humanoid.Health <= 0 then
			return
		end
		local now = os.clock()
		if now < pausedUntil then
			return
		end
		-- Never while a battle (or another screen) is open: standing on a clump during a battle
		-- kept asking for a new one, and "You are already in a battle" flashed on screen
		-- (Studio, 23 November 2026). The world's prompts are off exactly then.
		if not ProximityPromptService.Enabled then
			return
		end
		for id, hidden in shown do
			if now >= (calmUntil[id] or 0) then
				local flat =
					Vector3.new(hidden.wild.X - root.Position.X, 0, hidden.wild.Z - root.Position.Z)
				local reach = if hidden.fresh
					then WorldConfig.RUSTLE_RADIUS
					else WorldConfig.GRASS_TRIGGER_RADIUS
				if flat.Magnitude <= reach then
					hidden.fresh = false
					calmUntil[id] = now + WorldConfig.WILD_CALM_SECONDS + 2
					pausedUntil = now + WorldConfig.ENCOUNTER_BEAT_SECONDS + 1
					startEncounter(made, hidden)
					return
				end
			end
		end
	end)

	ProximityPromptService.PromptTriggered:Connect(function(prompt)
		local kind = prompt:GetAttribute("PromptKind")
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
					-- The screen fades over the jump, so the world does not snap from town to town.
					Transition.fade(function()
						Net.Travel.Fire({ BiomeNumber = here % reached + 1 })
					end)
				end
			elseif role == "Healer" then
				-- A short fade while the team rests; free, and the server checks the player is here.
				Transition.fade(function()
					Net.HealAtHealer.Fire(true)
				end)
			end
		end
	end)
end

return WorldView
