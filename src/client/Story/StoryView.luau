--!strict
-- The story on screen: the opening (a title card, the mentor's words, then the starter pick), a
-- dialogue box that plays each finished beat's lines and names its gifts, a "Day one" card after
-- the first quest opens, and a small tracker that says what is waiting (the next story step, an
-- egg, quests in hand, Greenwood friends). The server decides everything; this screen only
-- shows it, and the pick itself is sent by StarterPick.
-- TODO(art): first cut, not yet seen in Studio.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local AudioConfig = require(ReplicatedStorage.config.AudioConfig)
local BeatHint = require(ReplicatedStorage.shared.BeatHint)
local Bus = require(script.Parent.Parent.Net.Bus)
local ClientState = require(script.Parent.Parent.State.ClientState)
local Icons = require(script.Parent.Parent.UI.Icons)
local Kit = require(script.Parent.Parent.UI.Kit)
local LookAt = require(script.Parent.LookAt)
local Net = require(ReplicatedStorage.net.generated.Client)
local QuestProgress = require(ReplicatedStorage.shared.QuestProgress)
local Quests = require(ReplicatedStorage.content.Quests)
local Sfx = require(script.Parent.Parent.Audio.Sfx)
local Cadence = require(ReplicatedStorage.shared.Cadence)
local Snapshot = require(ReplicatedStorage.shared.Snapshot)
local SpeakerFace = require(script.Parent.SpeakerFace)
local StarterPick = require(script.Parent.StarterPick)
local TitleCard = require(script.Parent.TitleCard)
local Storyline = require(ReplicatedStorage.content.Storyline)
local Tracker = require(ReplicatedStorage.shared.Tracker)
local World = require(ReplicatedStorage.shared.World)

local StoryView = {}

local TRACKER_WIDE = 300

local DAY_ONE_BEAT = "first_quest"

local GIFT_TEXT: { [string]: string } = {
	Coins = "coins",
	PrismCandy = "Prism Candy",
	Pen = "A new breeding pen",
	Egg = "An egg",
	Badge = "Badge",
	Starter = "Your first creature",
	Creature = "A new creature",
}

-- Everything the tracker and the Day one card read from the player's state.
local function summarise(state: Snapshot.State, now: number): Tracker.Input
	local flags: { [string]: boolean } = {}
	for _, flag in state.Flags do
		flags[flag] = true
	end
	local beat = World.nextBeat(Storyline, flags)
	local quests: { Tracker.QuestLine } = {}
	for id, progress in state.QuestsActive do
		local quest = Quests[id]
		if quest then
			table.insert(quests, {
				goal = quest.goal,
				progress = progress,
				needed = QuestProgress.needed(quest),
				giver = quest.giver.name,
			})
		end
	end
	local eggs: { number } = {}
	for _, egg in state.Eggs do
		table.insert(eggs, egg.HatchAt)
	end
	local owned: { string } = {}
	for _, view in state.Creatures do
		table.insert(owned, view.Torso.Species)
	end
	return {
		hint = if beat then BeatHint.text(beat) else nil,
		quests = quests,
		eggs = eggs,
		now = now,
		friends = Tracker.countFriends(owned),
	}
end

function StoryView.start(playerGui: Instance)
	-- The tracker: always on, top-left, clear of the bar at the top right.
	local hud = Kit.screen(playerGui, "Tracker", 3, true)
	hud.Enabled = true
	-- A little notebook page: a striped "TO DO" strip across the top and a line for each thing,
	-- only as tall as its lines.
	local tracker = Kit.panel(hud, UDim2.fromOffset(TRACKER_WIDE, 0), UDim2.fromOffset(10, 10))
	tracker.AutomaticSize = Enum.AutomaticSize.Y
	local trackerFoot = Instance.new("UIPadding")
	trackerFoot.PaddingBottom = UDim.new(0, 8)
	trackerFoot.Parent = tracker
	local trackerHead = Instance.new("Frame")
	trackerHead.Size = UDim2.new(1, -8, 0, 22)
	trackerHead.Position = UDim2.fromOffset(4, 4)
	trackerHead.BackgroundColor3 = Kit.COLOURS.accent
	trackerHead.BorderSizePixel = 0
	trackerHead.Parent = tracker
	local headCorner = Instance.new("UICorner")
	headCorner.CornerRadius = UDim.new(0, 5)
	headCorner.Parent = trackerHead
	Kit.stripes(trackerHead)
	local headWords =
		Kit.label(trackerHead, "TO DO", UDim2.new(1, -16, 1, -4), UDim2.fromOffset(8, 2), 16)
	headWords.TextColor3 = Kit.COLOURS.white
	Kit.pixel(headWords, 14)
	local trackerText =
		Kit.label(tracker, "", UDim2.new(1, -20, 0, 0), UDim2.fromOffset(10, 30), 16)
	trackerText.AutomaticSize = Enum.AutomaticSize.Y
	trackerText.TextWrapped = true
	trackerText.TextYAlignment = Enum.TextYAlignment.Top
	trackerText.TextScaled = false -- a fixed size: the page grows to fit its lines instead
	trackerText.TextSize = 16
	local opening = false -- the title and the mentor's words keep the tracker hidden

	-- The dialogue box: bottom of the screen, one line at a time.
	local gui = Kit.screen(playerGui, "Dialogue", 20, true)
	-- The box and its name tab sit in one holder, so they slide up together when the box opens.
	local slide = Instance.new("Frame")
	slide.Size = UDim2.fromScale(1, 1)
	slide.BackgroundTransparency = 1
	slide.BorderSizePixel = 0
	slide.Parent = gui
	local box = Kit.panel(slide, UDim2.new(0.8, 0, 0, 110), UDim2.new(0.1, 0, 1, -128))
	-- Who is speaking: a name tab on the box's top edge and, for some, a face at its left.
	local face = SpeakerFace.new(slide, box)
	local slideTween: Tween? = nil
	gui:GetPropertyChangedSignal("Enabled"):Connect(function()
		if slideTween then
			slideTween:Cancel()
			slideTween = nil
		end
		if not gui.Enabled then
			slide.Position = UDim2.new()
			return
		end
		slide.Position = UDim2.fromOffset(0, 60)
		local rise = TweenService:Create(
			slide,
			TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{ Position = UDim2.new() }
		)
		slideTween = rise
		rise:Play()
	end)
	-- The words keep clear of the face at the left and the arrow at the bottom right.
	local line = Kit.label(box, "", UDim2.new(1, -56, 1, -24), UDim2.fromOffset(16, 12), 22)
	line.TextWrapped = true
	line.TextYAlignment = Enum.TextYAlignment.Top
	Kit.textSize(line, 22) -- the body face: a sentence, not a title
	-- `look` is a place the camera turns to while the line shows (a beat's `lookAt`).
	local queue: { { speaker: string, text: string, look: string? } } = {}
	-- Things to do once the queue has been read to its end (the pick screen, the Day one card).
	local afterQueue: { () -> () } = {}
	-- Lines are typed out a letter at a time with a soft tick, as in the old handheld games.
	-- Pressing Next while a line is still being typed shows the rest of it at once.
	local typing = 0
	local lastTick = -math.huge
	local function typeOut(text: string)
		typing += 1
		local mine = typing
		line.Text = text
		line.MaxVisibleGraphemes = 0
		task.spawn(function()
			for count = 1, #text do
				if typing ~= mine then
					return
				end
				line.MaxVisibleGraphemes = count
				-- A soft tick for each batch of letters, never more often than TICK_GAP.
				local now = os.clock()
				if Cadence.ready(lastTick, now, AudioConfig.TICK_GAP) then
					lastTick = now
					Sfx.play("tick")
				end
				task.wait(0.022)
			end
			if typing == mine then
				line.MaxVisibleGraphemes = -1
			end
		end)
	end
	-- The box waits while the battle screen is open: it sat on top of the moves and the
	-- "You won!" panel (first Studio run). The line on show comes back when the battle closes.
	local showing = false
	local battleOpen = false
	local function showNext()
		local nextLine = table.remove(queue, 1)
		if nextLine and nextLine.look then
			LookAt.start(nextLine.look)
		else
			LookAt.release()
		end
		if not nextLine then
			showing = false
			gui.Enabled = false
			local todo = afterQueue
			afterQueue = {}
			for _, action in todo do
				action()
			end
			return
		end
		local taken = face.show(nextLine.speaker)
		line.Position = UDim2.fromOffset(16 + taken, 12)
		line.Size = UDim2.new(1, -(56 + taken), 1, -24)
		typeOut(nextLine.text)
		showing = true
		gui.Enabled = not battleOpen
	end
	task.spawn(function()
		local battle = playerGui:WaitForChild("Battle")
		if not battle:IsA("ScreenGui") then
			return
		end
		local function battleChanged()
			battleOpen = battle.Enabled
			if battleOpen then
				LookAt.release()
			end
			hud.Enabled = not battleOpen -- the tracker sits under the foe's card
			if not showing and not battleOpen and #queue > 0 then
				showNext()
			else
				gui.Enabled = showing and not battleOpen
			end
		end
		battle:GetPropertyChangedSignal("Enabled"):Connect(battleChanged)
		battleChanged()
	end)
	-- Advancing: tap anywhere on the box, or press Enter, Space or the gamepad's A. A tap while
	-- a line is still being typed shows the rest of it.
	local function advance()
		if LookAt.turning() then
			LookAt.release() -- a tap while the camera is still turning skips the look
		end
		if line.MaxVisibleGraphemes ~= -1 then
			typing += 1
			line.MaxVisibleGraphemes = -1
		else
			showNext()
		end
	end
	local tapBox = Instance.new("TextButton")
	tapBox.Name = "TapToContinue"
	tapBox.Text = ""
	tapBox.AutoButtonColor = false
	tapBox.BackgroundTransparency = 1
	tapBox.Size = UDim2.fromScale(1, 1)
	tapBox.ZIndex = 5
	tapBox.Parent = box
	tapBox.Activated:Connect(function()
		Sfx.play("press")
		advance()
	end)
	UserInputService.InputBegan:Connect(function(input: InputObject, processed: boolean)
		if processed or not gui.Enabled then
			return
		end
		local key = input.KeyCode
		if
			key == Enum.KeyCode.Return
			or key == Enum.KeyCode.Space
			or key == Enum.KeyCode.ButtonA
		then
			advance()
		end
	end)
	-- A small arrow bobbing at the bottom right says there is more; it shows once the line is
	-- fully typed.
	local arrow = Icons.arrowDown(box, 20, Kit.COLOURS.accent)
	arrow.AnchorPoint = Vector2.new(1, 1)
	arrow.Position = UDim2.new(1, -16, 1, -14)
	arrow.ZIndex = 6
	for _, part in arrow:GetChildren() do
		if part:IsA("GuiObject") then
			part.ZIndex = 6
		end
	end
	TweenService:Create(
		arrow,
		TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{ Position = UDim2.new(1, -16, 1, -8) }
	):Play()
	local function showArrow()
		arrow.Visible = line.MaxVisibleGraphemes == -1
	end
	line:GetPropertyChangedSignal("MaxVisibleGraphemes"):Connect(showArrow)
	showArrow()

	-- The tracker text. The egg line counts down, so this also runs once a second; it sets this
	-- one label and nothing else.
	local function renderTracker()
		local state = ClientState.get()
		if not state then
			return
		end
		local lines = Tracker.lines(summarise(state, os.time()))
		trackerText.Text = table.concat(lines, "\n")
		tracker.Visible = #lines > 0 and not opening
	end
	task.spawn(function()
		while true do
			task.wait(1)
			renderTracker()
		end
	end)

	-- The "Day one" card, shown once when the first quest opens.
	local dayGui = Kit.screen(playerGui, "DayOne", 25)
	local dayPanel = Kit.panel(dayGui, UDim2.fromOffset(440, 250), UDim2.fromScale(0.5, 0.5))
	dayPanel.AnchorPoint = Vector2.new(0.5, 0.5)
	local dayTitle =
		Kit.title(dayPanel, "Day one", UDim2.new(1, -28, 0, 40), UDim2.fromOffset(14, 10), 32)
	dayTitle.TextXAlignment = Enum.TextXAlignment.Center
	local dayText =
		Kit.label(dayPanel, "", UDim2.new(1, -40, 1, -132), UDim2.fromOffset(20, 56), 20)
	dayText.TextWrapped = true
	dayText.TextYAlignment = Enum.TextYAlignment.Top
	local dayButton = Kit.button(dayPanel, "Keep going", Kit.COLOURS.good, function()
		dayGui.Enabled = false
	end)
	dayButton.Size = UDim2.fromOffset(200, 48)
	dayButton.Position = UDim2.new(0.5, -100, 1, -58)
	local dayShown = false
	local function showDayOne()
		local state = ClientState.get()
		if dayShown or not state then
			return
		end
		dayShown = true
		local summary = summarise(state, os.time())
		local goal: string? = nil
		for _, quest in summary.quests do
			goal = goal or quest.goal
		end
		local lines = Tracker.dayOneLines(summary.friends, summary.eggs, summary.now, goal)
		dayText.Text = table.concat(lines, "\n")
		dayGui.Enabled = true
		Kit.pop(dayPanel)
		Sfx.play("win")
	end

	-- The opening, for a player with no first creature: title, the mentor's words, then the pick.
	local startBeat = Storyline.beats[1]
	local pick = StarterPick.new(playerGui, startBeat)
	local openingStarted = false
	local function playOpening()
		opening = true
		tracker.Visible = false
		TitleCard.play(playerGui, function()
			local state = ClientState.get()
			if state and state.Starter ~= "" then
				opening = false
				return -- the first creature arrived while the title ran
			end
			table.insert(afterQueue, function()
				-- Only if there is still no first friend: the choice may have been made already.
				local latest = ClientState.get()
				if not (latest and latest.Starter ~= "") then
					pick.show() -- the tracker stays hidden until a friend is chosen
				end
			end)
			-- Every line of the first beat, read from the story data.
			if startBeat then
				for _, said in startBeat.lines do
					table.insert(queue, { speaker = said.speaker, text = said.text })
				end
			end
			if not showing then
				showNext()
			end
		end)
	end

	ClientState.onChanged(function(state: Snapshot.State)
		if state.Starter ~= "" then
			opening = false
			pick.hide()
		elseif not openingStarted then
			openingStarted = true
			playOpening()
		end
		renderTracker()
	end)

	Bus.listen(Net.BeatCompleted, function(value)
		for _, beat in Storyline.beats do
			-- The first beat's lines were already said before the pick.
			if beat.id == value.BeatId and beat ~= startBeat then
				for _, said in beat.lines do
					table.insert(
						queue,
						{ speaker = said.speaker, text = said.text, look = beat.lookAt }
					)
				end
			end
		end
		local got: { string } = {}
		for _, gift in value.Gifts do
			if gift.Kind == "Starter" then
				-- The first friend is a moment of its own, not an item on a list.
				local known = ClientState.get()
				local friend = pick.chosen()
					or (if known and known.Starter ~= "" then known.Starter else "Your new friend")
				table.insert(queue, {
					speaker = "A new friend",
					text = `{friend} bounces over and leans against your leg. You are a team now!`,
				})
				continue
			end
			local name = GIFT_TEXT[gift.Kind] or gift.Detail
			local text = if gift.Kind == "Coins" or gift.Kind == "PrismCandy"
				then `{gift.Detail} {name}`
				elseif
					gift.Kind == "Item"
					or gift.Kind == "Material"
					or gift.Kind == "Badge"
				then gift.Detail
				else name
			table.insert(got, if gift.Waiting then `{text} (waiting for room)` else text)
		end
		if #got > 0 then
			table.insert(queue, { speaker = "You received", text = table.concat(got, ", ") })
		end
		if value.BeatId == DAY_ONE_BEAT then
			table.insert(afterQueue, showDayOne)
		end
		if not showing then
			showNext()
		end
	end)

	Bus.listen(Net.QuestUpdate, function(value)
		local quest = Quests[value.QuestId]
		if not quest then
			return
		end
		if value.Change == "Taken" then
			table.insert(queue, { speaker = quest.giver.name, text = quest.offer })
		elseif value.Change == "Done" then
			table.insert(queue, { speaker = quest.giver.name, text = quest.done })
		else
			return
		end
		if not showing then
			showNext()
		end
	end)
end

return StoryView
