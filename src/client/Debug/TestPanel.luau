--!strict
-- Studio-only test panel, so battles, the lasso, the story and releasing can be played before the
-- real screens exist. Plain grey boxes on purpose: this is a tool, never shown on a live server.
-- TODO(art): replaced by the battle, lasso and team screens.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Storyline = require(ReplicatedStorage.content.Storyline)
local ClientState = require(script.Parent.Parent.State.ClientState)
local Lasso = require(ReplicatedStorage.shared.Lasso)
local LassoPlayer = require(script.Parent.Parent.Lasso.LassoPlayer)
local Bus = require(script.Parent.Parent.Net.Bus)
local Net = require(ReplicatedStorage.net.generated.Client)
local Quests = require(ReplicatedStorage.content.Quests)
local World = require(ReplicatedStorage.shared.World)
local WorldView = require(script.Parent.Parent.World.WorldView)

local TestPanel = {}

local MAX_LOG_LINES = 10

function TestPanel.start(parent: Instance)
	local gui = Instance.new("ScreenGui")
	gui.Name = "TestPanel"
	gui.ResetOnSpawn = false
	gui.Parent = parent

	local root = Instance.new("Frame")
	root.Size = UDim2.new(0, 360, 1, -20)
	root.Position = UDim2.fromOffset(10, 10)
	root.BackgroundTransparency = 0.3
	root.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	root.Parent = gui
	-- Closed until asked for: open, it covers the tracker and the foe's card (first Studio run).
	root.Visible = false
	local toggle = Instance.new("TextButton")
	toggle.Text = "Test"
	toggle.TextSize = 13
	toggle.Size = UDim2.fromOffset(48, 24)
	toggle.Position = UDim2.new(0, 10, 1, -34)
	toggle.ZIndex = 2
	toggle.Parent = gui
	toggle.Activated:Connect(function()
		root.Visible = not root.Visible
	end)
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 4)
	layout.Parent = root

	local function label(height: number): TextLabel
		local text = Instance.new("TextLabel")
		text.Size = UDim2.new(1, 0, 0, height)
		text.BackgroundTransparency = 1
		text.TextColor3 = Color3.new(1, 1, 1)
		text.TextXAlignment = Enum.TextXAlignment.Left
		text.TextYAlignment = Enum.TextYAlignment.Top
		text.TextWrapped = true
		text.Font = Enum.Font.Code
		text.TextSize = 13
		text.Text = ""
		text.Parent = root
		return text
	end

	local status = label(90)
	local logText = label(150)
	local lines: { string } = {}
	local function log(line: string)
		table.insert(lines, line)
		while #lines > MAX_LOG_LINES do
			table.remove(lines, 1)
		end
		logText.Text = table.concat(lines, "\n")
	end

	local buttons = Instance.new("Frame")
	buttons.Size = UDim2.new(1, 0, 0, 110)
	buttons.BackgroundTransparency = 1
	buttons.Parent = root
	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.fromOffset(84, 26)
	grid.Parent = buttons
	local function button(text: string, onClick: () -> ())
		local b = Instance.new("TextButton")
		b.Text = text
		b.TextSize = 13
		b.Parent = buttons
		b.Activated:Connect(onClick)
	end

	-- The lasso bar: the zone in green, the marker in white.
	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(1, 0, 0, 24)
	bar.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	bar.Parent = root
	local zoneBox = Instance.new("Frame")
	zoneBox.BackgroundColor3 = Color3.fromRGB(80, 180, 90)
	zoneBox.BorderSizePixel = 0
	zoneBox.Size = UDim2.fromScale(0, 1)
	zoneBox.Parent = bar
	local marker = Instance.new("Frame")
	marker.BackgroundColor3 = Color3.new(1, 1, 1)
	marker.BorderSizePixel = 0
	marker.Size = UDim2.new(0, 4, 1, 0)
	marker.Parent = bar

	local battleId: number? = nil
	local nextTurn = 1
	local active = 1 -- the team position of the creature that is out now
	local playing: LassoPlayer.Playing? = nil

	-- Battles start from the prompts in the world (walk up to a creature or a person).
	button("Nearest wild", function()
		local character = Players.LocalPlayer.Character
		local rootPart = if character then character:FindFirstChild("HumanoidRootPart") else nil
		if not (rootPart and rootPart:IsA("BasePart")) then
			return
		end
		local best: number? = nil
		local bestDistance = math.huge
		for id, wild in WorldView.spawns() do
			local distance = (Vector3.new(wild.X, rootPart.Position.Y, wild.Z) - rootPart.Position).Magnitude
			if distance < bestDistance then
				best, bestDistance = id, distance
			end
		end
		if best then
			log(`Nearest wild is {math.floor(bestDistance)} studs away`)
			Net.StartBattle.Fire({ Kind = "Wild", TargetId = best, TargetName = nil })
		end
	end)
	for index = 1, 4 do
		button(`Move {index}`, function()
			if battleId then
				Net.BattleAction.Fire({
					BattleId = battleId,
					Turn = nextTurn,
					Kind = "Move",
					Index = index,
				})
			end
		end)
	end
	button("Run", function()
		if battleId then
			Net.BattleAction.Fire({ BattleId = battleId, Turn = nextTurn, Kind = "Run", Index = 0 })
		end
	end)
	button("Throw Basic", function()
		if battleId then
			Net.ThrowLasso.Fire({ BattleId = battleId, Turn = nextTurn, Tier = "Basic" })
		end
	end)
	button("Tonic", function()
		if battleId then
			Net.UseItem.Fire({
				BattleId = battleId,
				Turn = nextTurn,
				Item = "Tonic",
				Target = active,
			})
		end
	end)
	button("Buy 5 lassos", function()
		Net.BuyItem.Fire({ Item = "Basic", Count = 5 })
	end)
	local function tap()
		local current = playing
		if not current then
			return
		end
		local message = LassoPlayer.tap(current)
		if message then
			Net.LassoTap.Fire(message)
		end
	end
	button("Tap (Space)", tap)
	-- Taps for you when the marker is in the zone, so a catch can be tested without the timing
	-- (the Studio MCP cannot tap to the millisecond). Off until pressed.
	local autoTap = false
	button("Auto tap", function()
		autoTap = not autoTap
		log(`Auto tap: {if autoTap then "on" else "off"}`)
	end)
	button("Next beat", function()
		local state = ClientState.get()
		local flags: { [string]: boolean } = {}
		local seen: { string } = if state then state.Flags else {}
		for _, flag in seen do
			flags[flag] = true
		end
		local beat = World.nextBeat(Storyline, flags)
		if beat then
			Net.CompleteBeat.Fire({ BeatId = beat.id, Choice = nil })
		end
	end)

	UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and input.KeyCode == Enum.KeyCode.Space then
			tap()
		end
	end)

	Bus.listen(Net.BattleStarted, function(value)
		battleId, nextTurn, active = value.BattleId, 1, 1
		for index, c in value.Yours do
			if c.Hp > 0 then
				active = index
				break
			end
		end
		local foe = value.Theirs[1]
		log(`Battle {value.BattleId}: a level {foe.Level} {foe.Rarity} {foe.Torso} ({foe.Hp} HP)`)
	end)
	Bus.listen(Net.BattleTurn, function(value)
		nextTurn = value.Turn + 1
		active = value.YourActive
		for _, event in value.Events do
			log(
				`  turn {value.Turn}: side {event.Side} {event.Kind} {event.Move or ""} -{event.Damage} -> {event.TargetHp}`
			)
		end
		if value.Finished then
			log(
				`Battle over: {({ [0] = "draw / ran", [1] = "you won", [2] = "you lost" })[value.Outcome]}`
			)
			battleId = nil
		end
	end)
	Bus.listen(Net.BattleRefused, function(value)
		log(`Refused: {value.Reason}`)
	end)
	Bus.listen(Net.BattleRewards, function(value)
		log(
			`Rewards: {value.Coins} coins{if value.Material ~= ""
				then ", 1 " .. value.Material
				else ""}`
		)
	end)
	Bus.listen(Net.LassoPattern, function(value)
		playing = LassoPlayer.begin(value)
		log(
			`Lasso: {#value.Zones} zone(s){if value.ConnectionAssist
				then " (connection assist)"
				else ""}`
		)
	end)
	Bus.listen(Net.LassoResult, function(value)
		playing = nil
		log(
			`Lasso: {value.Outcome}, {value.ZonesHit} zone(s) hit, {value.Candy} {value.Element or ""} candy`
		)
	end)
	Bus.listen(Net.BeatCompleted, function(value)
		log(`Story: {value.BeatId} ({#value.Gifts} gift(s))`)
		for _, beat in Storyline.beats do
			if beat.id == value.BeatId then
				for _, line in beat.lines do
					log(`  {line.speaker}: {line.text}`)
				end
			end
		end
	end)
	Bus.listen(Net.BuyResult, function(value)
		log(
			if value.Ok
				then `Bought {value.Count} {value.Item} for {value.Coins} coins`
				else `Shop: {value.Reason}`
		)
	end)
	Bus.listen(Net.QuestUpdate, function(value)
		local quest = Quests[value.QuestId]
		local name = if quest then quest.name else value.QuestId
		if value.Change == "Taken" and quest then
			log(`Quest taken: {name}. {quest.goal}`)
		elseif value.Change == "Done" then
			log(`Quest done: {name} ({#value.Gifts} reward(s))`)
		else
			log(
				`Quest {name}: {value.Progress}/{value.Needed}{if value.Change == "Ready"
					then " - go back to hand it in"
					else ""}`
			)
		end
	end)
	Bus.listen(Net.ReleaseResult, function(value)
		log(
			if value.Ok
				then `Released for {value.Coins} coins`
				else `Release refused: {value.Reason}`
		)
	end)
	Bus.listen(Net.Hatched, function(value)
		log(`Hatched: {#value.Ids}`)
	end)

	ClientState.onChanged(function(state)
		status.Text = `Coins {state.Coins}  Prism {state.Candy.Prism}  Badges {state.Badges}\n`
			.. `Lassos: Basic {state.Items.Basic or 0}, Braided {state.Items.Braided or 0}\n`
			.. `Creatures {#state.Creatures}/{state.StableCapacity}  Team {#state.Team}  Eggs {#state.Eggs}/{state.Pens}\n`
			.. `Starter {state.Starter}  Waiting gifts {state.Waiting}`
	end)

	RunService.RenderStepped:Connect(function()
		local current = playing
		if not current then
			zoneBox.Visible, marker.Visible = false, false
			return
		end
		local position, zone = LassoPlayer.marker(current)
		if position == nil or zone == nil then
			zoneBox.Visible, marker.Visible = false, false
			return
		end
		local inSweep = LassoPlayer.elapsedMs(current) >= zone.startMs
		zoneBox.Visible, marker.Visible = true, inSweep
		zoneBox.Position = UDim2.fromScale(zone.centre - zone.width / 2, 0)
		zoneBox.Size = UDim2.fromScale(zone.width, 1)
		marker.Position = UDim2.new(position, -2, 0, 0)
		marker.BackgroundColor3 = if Lasso.isInZone(zone, position)
			then Color3.fromRGB(255, 240, 120)
			else Color3.new(1, 1, 1)
		if autoTap and inSweep and math.abs(position - zone.centre) < zone.width * 0.3 then
			tap()
		end
	end)
end

return TestPanel
