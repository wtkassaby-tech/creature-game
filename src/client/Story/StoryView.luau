--!strict
-- The story on screen: the opening (a title card, the mentor's words, then the starter pick), a
-- dialogue box that plays each finished beat's lines and names its gifts, a "Day one" card after
-- the first quest opens, and a small tracker that says what is waiting (the next story step, an
-- egg, quests in hand, Greenwood friends). The server decides everything; this screen only
-- shows it, and the pick itself is sent by StarterPick.
-- TODO(art): first cut, not yet seen in Studio.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Bus = require(script.Parent.Parent.Net.Bus)
local ClientState = require(script.Parent.Parent.State.ClientState)
local Kit = require(script.Parent.Parent.UI.Kit)
local Net = require(ReplicatedStorage.net.generated.Client)
local QuestProgress = require(ReplicatedStorage.shared.QuestProgress)
local Quests = require(ReplicatedStorage.content.Quests)
local Sfx = require(script.Parent.Parent.Audio.Sfx)
local Snapshot = require(ReplicatedStorage.shared.Snapshot)
local StarterPick = require(script.Parent.StarterPick)
local TitleCard = require(script.Parent.TitleCard)
local Storyline = require(ReplicatedStorage.content.Storyline)
local Tracker = require(ReplicatedStorage.shared.Tracker)
local World = require(ReplicatedStorage.shared.World)
local WorldTypes = require(ReplicatedStorage.shared.WorldTypes)

local StoryView = {}

local DAY_ONE_BEAT = "first_quest"

-- A short hint for what the story is waiting for, from the next beat's trigger.
local function hint(beat: WorldTypes.Beat): string
	local trigger = beat.trigger
	if trigger.kind == "Win" then
		return `Next: win the battle ({beat.name})`
	elseif trigger.kind == "Enter" or trigger.kind == "Sight" then
		return `Next: {beat.name} (go and look)`
	elseif trigger.kind == "Talk" then
		return `Next: {beat.name} (talk to them)`
	elseif trigger.kind == "Tame" then
		return `Next: {beat.name} (tame a creature)`
	end
	return `Next: {beat.name}`
end

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
		hint = if beat then hint(beat) else nil,
		quests = quests,
		eggs = eggs,
		now = now,
		friends = Tracker.countFriends(owned),
	}
end

function StoryView.start(playerGui: Instance)
	-- The tracker: always on, top-left, clear of the bar at the top right.
	local hud = Kit.screen(playerGui, "Tracker", 3)
	hud.Enabled = true
	local tracker = Kit.panel(hud, UDim2.fromOffset(330, 106), UDim2.fromOffset(10, 10))
	tracker.BackgroundTransparency = 0.2
	local trackerText = Kit.label(tracker, "", UDim2.new(1, -16, 1, -8), UDim2.fromOffset(8, 4), 16)
	trackerText.TextWrapped = true
	trackerText.TextYAlignment = Enum.TextYAlignment.Top
	local opening = false -- the title and the mentor's words keep the tracker hidden

	-- The dialogue box: bottom of the screen, one line at a time.
	local gui = Kit.screen(playerGui, "Dialogue", 20)
	local box = Kit.panel(gui, UDim2.new(0.8, 0, 0, 130), UDim2.new(0.1, 0, 1, -150))
	local speaker = Kit.label(box, "", UDim2.new(1, -150, 0, 26), UDim2.fromOffset(14, 8), 22)
	speaker.TextColor3 = Kit.COLOURS.bad
	Kit.pixel(speaker, 16)
	local line = Kit.label(box, "", UDim2.new(1, -28, 0, 68), UDim2.fromOffset(14, 54), 22)
	line.TextWrapped = true
	line.TextYAlignment = Enum.TextYAlignment.Top
	Kit.pixel(line, 20)
	local queue: { { speaker: string, text: string } } = {}
	-- Things to do once the queue has been read to its end (the pick screen, the Day one card).
	local afterQueue: { () -> () } = {}
	-- Lines are typed out a letter at a time with a soft tick, as in the old handheld games.
	-- Pressing Next while a line is still being typed shows the rest of it at once.
	local typing = 0
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
				if count % 3 == 0 then
					Sfx.play("count")
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
		speaker.Text = nextLine.speaker
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
	local nextButton = Kit.button(box, "NEXT", Kit.COLOURS.accent, function()
		if line.MaxVisibleGraphemes ~= -1 then
			typing += 1
			line.MaxVisibleGraphemes = -1
		else
			showNext()
		end
	end)
	nextButton.Size = UDim2.fromOffset(120, 44) -- finger-sized on a phone
	nextButton.Position = UDim2.new(1, -132, 0, 6)

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
		Kit.label(dayPanel, "Day one", UDim2.new(1, -28, 0, 40), UDim2.fromOffset(14, 10), 32)
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
				pick.show() -- the tracker stays hidden until a friend is chosen
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
					table.insert(queue, { speaker = said.speaker, text = said.text })
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
