--!strict
-- The story on screen: the starter pick at the very start, a dialogue box that plays each
-- finished beat's lines and names its gifts, and a small tracker that says what to do next
-- (the next story step and any quests in hand). The server decides everything; this screen
-- only shows it, and sends the starter the player picked.
-- TODO(art): first cut, not yet seen in Studio. Portraits and creature pictures come later.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Bus = require(script.Parent.Parent.Net.Bus)
local ClientState = require(script.Parent.Parent.State.ClientState)
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
	local tracker = Kit.panel(hud, UDim2.new(0, 300, 0, 86), UDim2.new(0, 10, 0, 10))
	tracker.BackgroundTransparency = 0.2
	local trackerText = Kit.label(tracker, "", UDim2.new(1, -16, 1, -8), UDim2.new(0, 8, 0, 4), 16)
	trackerText.TextWrapped = true
	trackerText.TextYAlignment = Enum.TextYAlignment.Top

	-- The dialogue box: bottom of the screen, one line at a time.
	local gui = Kit.screen(playerGui, "Dialogue", 20)
	local box = Kit.panel(gui, UDim2.new(0.8, 0, 0, 130), UDim2.new(0.1, 0, 1, -150))
	local speaker = Kit.label(box, "", UDim2.new(1, -140, 0, 26), UDim2.new(0, 14, 0, 8), 22)
	speaker.TextColor3 = Kit.COLOURS.warn
	local line = Kit.label(box, "", UDim2.new(1, -28, 0, 64), UDim2.new(0, 14, 0, 38), 22)
	line.TextWrapped = true
	line.TextYAlignment = Enum.TextYAlignment.Top
	local queue: { { speaker: string, text: string } } = {}
	local function showNext()
		local nextLine = table.remove(queue, 1)
		if not nextLine then
			gui.Enabled = false
			return
		end
		speaker.Text = nextLine.speaker
		line.Text = nextLine.text
		gui.Enabled = true
	end
	local nextButton = Kit.button(box, "Next", Kit.COLOURS.accent, showNext)
	nextButton.Size = UDim2.new(0, 110, 0, 34)
	nextButton.Position = UDim2.new(1, -124, 0, 6)

	-- The starter pick: shown until the player has a first creature.
	local pick = Kit.screen(playerGui, "StarterPick", 30)
	local pickBox = Kit.panel(pick, UDim2.new(0.8, 0, 0.5, 0), UDim2.new(0.1, 0, 0.25, 0))
	local pickTitle =
		Kit.label(pickBox, "Pick a friend", UDim2.new(1, -28, 0, 36), UDim2.new(0, 14, 0, 10), 28)
	pickTitle.TextXAlignment = Enum.TextXAlignment.Center
	local choices = Instance.new("Frame")
	choices.Size = UDim2.new(1, -28, 1, -70)
	choices.Position = UDim2.new(0, 14, 0, 56)
	choices.BackgroundTransparency = 1
	choices.Parent = pickBox
	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.new(0.333, -8, 1, 0)
	grid.CellPadding = UDim2.fromOffset(12, 0)
	grid.Parent = choices
	local startBeat = Storyline.beats[1]
	local startGifts: { WorldTypes.Reward } = if startBeat then startBeat.grants else {}
	for _, reward in startGifts do
		if reward.kind == "Starter" then
			for _, species in reward.choices do
				local def = Species[species]
				local label = if def then `{species}\n{def.element} type` else species
				local button = Kit.button(choices, label, Kit.COLOURS.accent, function()
					Net.CompleteBeat.Fire({ BeatId = startBeat.id, Choice = species })
				end)
				button.TextWrapped = true
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
			if beat.id == value.BeatId then
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
		if not gui.Enabled then
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
		if not gui.Enabled then
			showNext()
		end
	end)
end

return StoryView
