--!strict
-- The creatures screen, laid out like the party and box of an old handheld creature game: the
-- team as large cards along the top (empty slots dashed), the stable below as a scrolling grid
-- of small cards, and a detail panel beside them for the creature tapped (to team / off team,
-- tonic, breed, release). Header chips show the egg pens and candy. Also a small bar that is
-- always on screen (coins, Prism Candy, and the button that opens this screen). The server
-- checks and decides every request; this file only shows and asks.
-- TODO(art): not yet seen in Studio; sized for a phone held sideways (874 by 402 points).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BreedStrip = require(script.Parent.BreedStrip)
local Bus = require(script.Parent.Parent.Net.Bus)
local CardSet = require(script.Parent.CardSet)
local ClientState = require(script.Parent.Parent.State.ClientState)
local CreatureCard = require(script.Parent.CreatureCard)
local DailyRows = require(script.Parent.DailyRows)
local DetailPanel = require(script.Parent.DetailPanel)
local FriendsStrip = require(script.Parent.FriendsStrip)
local HeaderChips = require(script.Parent.HeaderChips)
local HudStrip = require(script.Parent.Parent.UI.HudStrip)
local Icons = require(script.Parent.Parent.UI.Icons)
local Kit = require(script.Parent.Parent.UI.Kit)
local Net = require(ReplicatedStorage.net.generated.Client)
local Sfx = require(script.Parent.Parent.Audio.Sfx)
local Snapshot = require(ReplicatedStorage.shared.Snapshot)
local Tracker = require(ReplicatedStorage.shared.Tracker)
local TweenService = game:GetService("TweenService")

local CreaturesView = {}

local MAX_TEAM = CardSet.MAX_TEAM
local TOP = 52 -- the header takes this much of the panel
local GAP = CardSet.GAP

local function clock(seconds: number): string
	local left = math.max(0, math.floor(seconds))
	return string.format("%d:%02d", left // 60, left % 60)
end

function CreaturesView.start(playerGui: Instance)
	-- The strip along the top right is shared with the Journal button (FindsView).
	local strip = HudStrip.get(playerGui).strip
	local coinsLabel = HudStrip.currency(strip, Icons.coin, 1)
	local prismLabel = HudStrip.currency(strip, Icons.prism, 2)
	-- Notices sit on their own layer above every screen: on the Hud's layer the Creatures panel
	-- covered them ("Not enough coins" was half hidden in the longer Studio run).
	local notices = Kit.screen(playerGui, "Notices", 50, true)
	notices.Enabled = true
	local notice = Kit.label(notices, "", UDim2.new(0.6, 0, 0, 28), UDim2.new(0.2, 0, 0, 68), 20)
	notice.TextXAlignment = Enum.TextXAlignment.Center
	Kit.overWorld(notice)
	notice.TextStrokeTransparency = 0.3

	local gui = Kit.screen(playerGui, "Creatures", 6, true)
	-- What the button does is set further down, once the screen can be rebuilt.
	local open = HudStrip.button(
		strip,
		"Creatures",
		Kit.COLOURS.accent,
		function(parent, size, position)
			return Icons.creatures(parent, size, Kit.COLOURS.white, position)
		end,
		4,
		function() end
	)

	-- Nearly the whole screen: at 874 by 402 this is 839 by 378 points.
	local root = Kit.panel(gui, UDim2.fromScale(0.96, 0.94), UDim2.fromScale(0.02, 0.03))
	local header = HeaderChips.new(root)
	-- The screen slides up when opened and back down when closed. A new open or close cancels
	-- the tween before it, and nothing waits on it: the screen takes taps at once.
	local SHOWN = root.Position
	local HIDDEN = UDim2.fromScale(SHOWN.X.Scale, 1)
	local slideTween: Tween? = nil
	local closing = false
	local function slideTo(goal: UDim2, info: TweenInfo, done: (() -> ())?)
		if slideTween then
			slideTween:Cancel()
		end
		local made = TweenService:Create(root, info, { Position = goal })
		slideTween = made
		made.Completed:Connect(function(state: Enum.PlaybackState)
			if state == Enum.PlaybackState.Completed and done then
				done()
			end
		end)
		made:Play()
	end
	local function openScreen()
		closing = false
		if not gui.Enabled then
			root.Position = HIDDEN
		end
		gui.Enabled = true
		slideTo(SHOWN, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), nil)
	end
	local function closeScreen()
		if closing or not gui.Enabled then
			return
		end
		closing = true
		slideTo(
			HIDDEN,
			TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			function()
				if closing then
					closing = false
					gui.Enabled = false
				end
			end
		)
	end
	local close = Kit.button(root, "Close", Kit.COLOURS.neutral, closeScreen)
	close.Size = Kit.CLOSE_SIZE
	close.Position = UDim2.new(1, -108, 0, 4)

	-- Left: the team row, the stable, and (while parents are picked) the breeding strip.
	local left = Instance.new("Frame")
	left.Size = UDim2.new(0.66, -24, 1, -(TOP + 12))
	left.Position = UDim2.fromOffset(14, TOP)
	left.BackgroundTransparency = 1
	left.Parent = root
	local teamRow = Instance.new("Frame")
	teamRow.Size = UDim2.new(1, 0, 0, 104)
	teamRow.BackgroundTransparency = 1
	teamRow.Parent = left
	local across = Instance.new("UIListLayout")
	across.FillDirection = Enum.FillDirection.Horizontal
	across.Padding = UDim.new(0, GAP)
	across.SortOrder = Enum.SortOrder.LayoutOrder
	across.Parent = teamRow

	local list = Instance.new("ScrollingFrame")
	list.BackgroundTransparency = 1
	list.BorderSizePixel = 0
	list.ScrollBarThickness = 6
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.CanvasSize = UDim2.new()
	list.Parent = left
	local listPad = Instance.new("UIPadding")
	listPad.PaddingTop, listPad.PaddingBottom = UDim.new(0, 6), UDim.new(0, 6)
	listPad.PaddingLeft, listPad.PaddingRight = UDim.new(0, 6), UDim.new(0, 6)
	listPad.Parent = list
	local stack = Instance.new("UIListLayout")
	stack.Padding = UDim.new(0, 6)
	stack.SortOrder = Enum.SortOrder.LayoutOrder
	stack.Parent = list
	local friends = FriendsStrip.new(list, 0)
	local daily = DailyRows.new(list, 1)
	local gridHolder = Instance.new("Frame")
	gridHolder.Size = UDim2.fromScale(1, 0)
	gridHolder.AutomaticSize = Enum.AutomaticSize.Y
	gridHolder.BackgroundTransparency = 1
	gridHolder.LayoutOrder = 2
	gridHolder.Parent = list
	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.fromOffset(CreatureCard.BOX_SIZE.X, CreatureCard.BOX_SIZE.Y)
	grid.CellPadding = UDim2.fromOffset(6, 6)
	grid.SortOrder = Enum.SortOrder.LayoutOrder
	grid.Parent = gridHolder

	-- Screen state.
	local selected: string? = nil
	local confirmRelease: string? = nil
	local breedShown = false
	local rebuild: () -> ()
	local selectCreature: (id: string) -> ()
	local cardSet = CardSet.new(teamRow, gridHolder, function(id: string)
		selectCreature(id)
	end)

	local function say(text: string)
		notice.Text = text
		task.delay(4, function()
			if notice.Text == text then
				notice.Text = ""
			end
		end)
	end

	local breed = BreedStrip.new(left, function()
		rebuild()
	end)

	-- Splits the left column between the team row, the stable and the breeding strip, from the
	-- screen's real size (called when the screen opens and when the screen changes size).
	local detail: DetailPanel.Detail
	local function layout()
		local screenHeight = if gui.AbsoluteSize.Y > 0 then gui.AbsoluteSize.Y else 402
		local columnHeight = screenHeight * 0.94 - (TOP + 12)
		local teamHeight = math.clamp(math.floor(columnHeight * 0.34), 104, 230)
		teamRow.Size = UDim2.new(1, 0, 0, teamHeight)
		list.Position = UDim2.fromOffset(0, teamHeight + GAP)
		local below = teamHeight + GAP + (if breedShown then BreedStrip.HEIGHT + GAP else 0)
		list.Size = UDim2.new(1, 0, 1, -below)
		-- On a phone the picture is kept short, so all the actions show without scrolling
		-- (seen in Studio at 874 by 402: Release was cut off under a 94-pixel picture).
		local picture = if columnHeight < 400 then 64 else math.floor(columnHeight * 0.3)
		detail.setPortraitHeight(math.clamp(picture, 64, 220))
	end

	selectCreature = function(id: string)
		if selected == id then
			return
		end
		selected = id
		confirmRelease = nil
		Sfx.play("confirm")
		cardSet.select(id)
		local frame = cardSet.frameOf(id)
		if frame then
			Kit.pop(frame)
		end
		rebuild()
	end

	-- Everything the panel's buttons ask for. They read the live state when tapped, since the
	-- buttons are not rebuilt on every update.
	local handlers: DetailPanel.Handlers = {
		toggleTeam = function()
			local state = ClientState.get()
			local id = selected
			if not state or not id then
				return
			end
			local ids = table.clone(state.Team)
			local at = table.find(ids, id)
			if at then
				table.remove(ids, at)
			else
				table.insert(ids, id)
			end
			if #ids >= 1 and #ids <= MAX_TEAM then
				Net.SetTeam.Fire({ Ids = ids })
			elseif #ids == 0 then
				say("Keep at least one creature on your team")
			end
		end,
		treat = function(item: DetailPanel.Treat)
			local id = selected
			if id then
				Net.TreatCreature.Fire({ Item = item, CreatureId = id })
			end
		end,
		toggleParent = function()
			local id = selected
			if id then
				breed.toggle(id)
			end
		end,
		-- Releasing asks twice: the first tap arms the button, the second releases.
		release = function()
			local id = selected
			if not id then
				return
			end
			if confirmRelease == id then
				confirmRelease = nil
				Net.ReleaseCreature.Fire({ Id = id })
			else
				confirmRelease = id
				rebuild()
			end
		end,
	}
	detail = DetailPanel.new(
		root,
		UDim2.new(0.34, -14, 1, -(TOP + 12)),
		UDim2.new(0.66, 0, 0, TOP),
		handlers
	)

	-- The Creatures button breathes while something is waiting (an egg that has hatched, or a
	-- creature that could join a team with room). Opening the screen counts as seeing it: it
	-- pulses again only when something new is waiting.
	local pulse: Tween? = nil
	local seenKey: string? = nil
	local lastKey = ""
	local openColour = open.BackgroundColor3
	local function updatePulse()
		local state = ClientState.get()
		if not state then
			return
		end
		local hatchTimes: { number } = {}
		for _, egg in state.Eggs do
			table.insert(hatchTimes, egg.HatchAt)
		end
		local waiting, key = Tracker.waiting(hatchTimes, os.time(), #state.Creatures, #state.Team)
		lastKey = key
		local wanted = waiting and not gui.Enabled and key ~= seenKey
		if wanted and not pulse then
			local slow =
				TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
			local made = TweenService:Create(
				open,
				slow,
				{ BackgroundColor3 = Color3.fromRGB(150, 188, 250) }
			)
			made:Play()
			pulse = made
		elseif not wanted and pulse then
			pulse:Cancel()
			pulse = nil
			open.BackgroundColor3 = openColour
		end
	end

	-- The treatment that fits a hurt creature: a Rally Root if it has fainted, otherwise a tonic.
	local function treatFor(view: Snapshot.CreatureView, state: Snapshot.State): DetailPanel.Treat?
		if view.Hurt <= 0 then
			return nil
		end
		if view.Hurt >= 1 then
			return if (state.Items.Revive or 0) > 0 then "Revive" else nil
		elseif (state.Items.Tonic or 0) > 0 then
			return "Tonic"
		elseif (state.Items.GreatTonic or 0) > 0 then
			return "GreatTonic"
		end
		return nil
	end

	rebuild = function()
		local state = ClientState.get()
		if not state then
			return
		end
		coinsLabel.Text = tostring(state.Coins)
		prismLabel.Text = tostring(math.floor(state.Candy.Prism))
		updatePulse()
		if not gui.Enabled then
			return
		end
		header.update(state)
		friends.update(state)
		daily.update(state.Daily)
		cardSet.sync(state, breed.has)

		local chosenView: Snapshot.CreatureView? = nil
		for _, view in state.Creatures do
			if view.Id == selected then
				chosenView = view
			end
		end
		if not chosenView then
			selected = nil
			confirmRelease = nil
		end
		cardSet.select(selected)
		if chosenView then
			detail.show({
				view = chosenView,
				teamPosition = table.find(state.Team, chosenView.Id),
				treat = treatFor(chosenView, state),
				chosen = breed.has(chosenView.Id),
				armed = confirmRelease == chosenView.Id,
			})
		else
			detail.show(nil)
		end

		local shown = breed.update(state)
		if shown ~= breedShown then
			breedShown = shown
			layout()
		end
	end

	-- Open and fill in one step: as two separate handlers the list was filled before the screen
	-- opened, so it came up empty (first Studio run).
	open.Activated:Connect(function()
		confirmRelease = nil
		seenKey = lastKey -- looked at: the button settles until something new is waiting
		if gui.Enabled and not closing then
			closeScreen()
			updatePulse()
			return
		end
		layout()
		openScreen()
		updatePulse()
		rebuild()
	end)
	gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
	layout()

	ClientState.onChanged(function()
		rebuild()
	end)
	Bus.listen(Net.BreedResult, function(value)
		if value.Ok then
			breed.clear()
			say(`An egg! It hatches in {clock(value.HatchAt - os.time())}`)
		else
			say(value.Reason)
		end
		rebuild()
	end)
	Bus.listen(Net.ReleaseResult, function(value)
		say(
			if value.Ok
				then `Released: +{value.Coins} coins, +{value.Candy} {value.Element or ""} candy`
				else value.Reason
		)
	end)
	Bus.listen(Net.Hatched, function(value)
		say(`{#value.Ids} egg{if #value.Ids > 1 then "s" else ""} hatched!`)
	end)
	Bus.listen(Net.Notice, function(value)
		say(value.Text)
	end)
	Bus.listen(Net.BattleRefused, function(value)
		say(value.Reason)
	end)

	-- Egg timers tick while the screen is open.
	task.spawn(function()
		while true do
			task.wait(1)
			updatePulse() -- an egg can pass its hatch time with no new state from the server
			if gui.Enabled then
				local state = ClientState.get()
				if state and #state.Eggs > 0 then
					header.update(state)
				end
			end
		end
	end)
end

return CreaturesView
