--!strict
-- The story on screen: the starter pick at the very start, a dialogue box that plays each
-- finished beat's lines and names its gifts, and a small tracker that says what to do next
-- (the next story step and any quests in hand). The server decides everything; this screen
-- only shows it, and sends the starter the player picked.
-- TODO(art): first cut, not yet seen in Studio. Portraits and creature pictures come later.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Bus = require(script.Parent.Parent.Net.Bus)
local ClientState = require(script.Parent.Parent.State.ClientState)
local Portrait = require(script.Parent.Parent.Creatures.Portrait)
local Sfx = require(script.Parent.Parent.Audio.Sfx)
local Kit = require(script.Parent.Parent.UI.Kit)
local Net = require(ReplicatedStorage.net.generated.Client)
local QuestProgress = require(ReplicatedStorage.shared.QuestProgress)
local Quests = require(ReplicatedStorage.content.Quests)
local Snapshot = require(ReplicatedStorage.shared.Snapshot)
local Species = require(ReplicatedStorage.content.Species)
local Storyline = require(ReplicatedStorage.content.Storyline)
local World = require(ReplicatedStorage.shared.World)
local WorldTypes = require(ReplicatedStorage.shared.WorldTypes)

local StoryView = {}

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

function StoryView.start(playerGui: Instance)
	-- The tracker: always on, top-left.
	local hud = Kit.screen(playerGui, "Tracker", 3)
	hud.Enabled = true
	local tracker = Kit.panel(hud, UDim2.fromOffset(300, 86), UDim2.fromOffset(10, 10))
	tracker.BackgroundTransparency = 0.2
	local trackerText = Kit.label(tracker, "", UDim2.new(1, -16, 1, -8), UDim2.fromOffset(8, 4), 16)
	trackerText.TextWrapped = true
	trackerText.TextYAlignment = Enum.TextYAlignment.Top

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

	-- The starter pick: shown until the player has a first creature.
	local pick = Kit.screen(playerGui, "StarterPick", 30)
	local pickBox = Kit.panel(pick, UDim2.fromScale(0.8, 0.5), UDim2.fromScale(0.1, 0.25))
	local pickTitle =
		Kit.label(pickBox, "Pick a friend", UDim2.new(1, -28, 0, 36), UDim2.fromOffset(14, 10), 28)
	pickTitle.TextXAlignment = Enum.TextXAlignment.Center
	local choices = Instance.new("Frame")
	choices.Size = UDim2.new(1, -28, 1, -96)
	choices.Position = UDim2.fromOffset(14, 82)
	choices.BackgroundTransparency = 1
	choices.Parent = pickBox
	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.new(0.333, -8, 1, 0)
	grid.CellPadding = UDim2.fromOffset(12, 0)
	grid.Parent = choices
	local startBeat = Storyline.beats[1]
	local startGifts: { WorldTypes.Reward } = if startBeat then startBeat.grants else {}
	-- The first beat's line is said on the pick screen itself. As a dialogue line it only arrived
	-- once the beat was done, so "Pick the one that feels right" showed after the pick.
	local startLine = if startBeat then startBeat.lines[1] else nil
	local pickSaid = Kit.label(
		pickBox,
		if startLine then `{startLine.speaker}: {startLine.text}` else "",
		UDim2.new(1, -28, 0, 30),
		UDim2.fromOffset(14, 46),
		18
	)
	pickSaid.TextXAlignment = Enum.TextXAlignment.Center
	pickSaid.TextColor3 = Kit.COLOURS.textDim
	pickSaid.TextScaled = true
	local pickSaidLimit = Instance.new("UITextSizeConstraint")
	pickSaidLimit.MaxTextSize = 18
	pickSaidLimit.MinTextSize = 10
	pickSaidLimit.Parent = pickSaid
	for _, reward in startGifts do
		if reward.kind == "Starter" then
			for _, species in reward.choices do
				local def = Species[species]
				local label = if def then `{species}\n{def.element} type` else species
				local colour = if def then Kit.ELEMENT_COLOURS[def.element] else Kit.COLOURS.accent
				local button = Kit.button(choices, label, colour, function()
					Net.CompleteBeat.Fire({ BeatId = startBeat.id, Choice = species })
				end)
				button.TextWrapped = true
				-- The creature itself stands on its card; its name sits underneath.
				button.TextYAlignment = Enum.TextYAlignment.Bottom
				if def then
					Portrait.new(button, species, def.element, UDim2.fromScale(1, 0.8), UDim2.new())
				end
			end
		end
	end

	local function refresh(state: Snapshot.State)
		pick.Enabled = state.Starter == ""
		local flags: { [string]: boolean } = {}
		for _, flag in state.Flags do
			flags[flag] = true
		end
		local lines: { string } = {}
		local beat = World.nextBeat(Storyline, flags)
		if beat then
			table.insert(lines, hint(beat))
		end
		for id, progress in state.QuestsActive do
			local quest = Quests[id]
			if quest then
				local needed = QuestProgress.needed(quest)
				table.insert(
					lines,
					if progress >= needed
						then `Quest done: go back to {quest.giver.name}`
						else `Quest: {quest.goal} ({progress}/{needed})`
				)
			end
		end
		trackerText.Text = table.concat(lines, "\n")
		tracker.Visible = #lines > 0
	end
	ClientState.onChanged(refresh)

	Bus.listen(Net.BeatCompleted, function(value)
		for _, beat in Storyline.beats do
			-- The first beat's line was already said on the pick screen.
			if beat.id == value.BeatId and beat ~= startBeat then
				for _, said in beat.lines do
					table.insert(queue, { speaker = said.speaker, text = said.text })
				end
			end
		end
		local got: { string } = {}
		for _, gift in value.Gifts do
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
