--!strict
-- The end of a battle: a big title, then what was earned, each line arriving in turn with the
-- numbers counting up, and one button to carry on. The rewards may arrive from the server before
-- or after the last turn has been shown, so `show` can be called twice; each part plays once.

-- After a catch the panel also carries a "New friend" card above the rewards: the creature's
-- picture, name, level, type, a line about it, and where it went. Looks only.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local AudioConfig = require(ReplicatedStorage.config.AudioConfig)
local Cry = require(script.Parent.Parent.Audio.Cry)
local Portrait = require(script.Parent.Parent.Creatures.Portrait)
local Kit = require(script.Parent.Parent.UI.Kit)
local Sfx = require(script.Parent.Parent.Audio.Sfx)
local SpeciesBlurbs = require(ReplicatedStorage.content.SpeciesBlurbs)
local SpeciesQuirks = require(ReplicatedStorage.content.SpeciesQuirks)
local Types = require(ReplicatedStorage.shared.Types)
local XpBar = require(ReplicatedStorage.shared.XpBar)

local ResultPanel = {}

export type LevelUp = { name: string, level: number }
-- One creature on the Won card: the bar runs from (levelBefore, xpBefore) to (levelAfter, xpAfter).
export type MemberCard = {
	name: string,
	element: Types.Element,
	gained: number,
	levelBefore: number,
	levelAfter: number,
	xpBefore: number,
	xpAfter: number,
}
export type Rewards = {
	coins: number,
	xp: number,
	material: string,
	levels: { LevelUp },
	members: { MemberCard },
}
export type Kind = "Won" | "Caught" | "Lost" | "Draw"
-- The creature just caught, for the "New friend" card. `placement` is the line saying where it
-- went ("Joined your team!"), worked out by the caller.
export type Caught = { name: string, element: Types.Element, level: number, placement: string }
export type View = {
	show: (kind: Kind, rewards: Rewards?, caught: Caught?) -> (),
	hide: () -> (),
}

local TITLES: { [Kind]: string } =
	{ Won = "VICTORY!", Caught = "CAUGHT!", Lost = "DEFEATED", Draw = "A DRAW" }

local COUNT_SECONDS = 0.6
local ROW_GAP_SECONDS = 0.25
local BAR_SECONDS = 0.8 -- an XP bar filling, level-ups included
local CHIP_HEIGHT = 34 -- the coins chip on a win
local CARD_HEIGHT = 118 -- the "New friend" card on a phone; its picture is 110 square
local CARD_SHARE = 0.34 -- on a bigger screen the card takes this much of the panel's height
local RIBBON = 52 -- the title band
local BUTTON_ROOM = 64 -- the Continue button (50 tall) and its margins, kept clear below the rows

function ResultPanel.new(gui: ScreenGui, onContinue: () -> ()): View
	local panel = Kit.panel(
		gui,
		UDim2.fromScale(0.4, 0.46),
		UDim2.fromScale(0.3, 0.14),
		Kit.COLOURS.panelLight
	)
	panel.Visible = false
	panel.ZIndex = 8
	-- The title sits on a striped ribbon across the top: gold for a win, grey for a loss.
	local ribbon = Instance.new("Frame")
	ribbon.Size = UDim2.new(1, -8, 0, RIBBON)
	ribbon.Position = UDim2.fromOffset(4, 4)
	ribbon.BackgroundColor3 = Kit.COLOURS.gold
	ribbon.BorderSizePixel = 0
	ribbon.ZIndex = 8
	ribbon.Parent = panel
	local ribbonCorner = Instance.new("UICorner")
	ribbonCorner.CornerRadius = UDim.new(0, 6)
	ribbonCorner.Parent = ribbon
	Kit.stripes(ribbon)
	-- A pale band of light that sweeps across the ribbon once the panel has landed. It is a
	-- frame with its own gradient (the ribbon's gradient is already the stripes).
	ribbon.ClipsDescendants = true
	local shine = Instance.new("Frame")
	shine.Size = UDim2.fromScale(1, 1)
	shine.BackgroundColor3 = Kit.COLOURS.white
	shine.BorderSizePixel = 0
	shine.ZIndex = 8
	shine.Parent = ribbon
	local shineCorner = Instance.new("UICorner")
	shineCorner.CornerRadius = UDim.new(0, 6)
	shineCorner.Parent = shine
	local shineGradient = Instance.new("UIGradient")
	shineGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.4, 1),
		NumberSequenceKeypoint.new(0.5, 0.45),
		NumberSequenceKeypoint.new(0.6, 1),
		NumberSequenceKeypoint.new(1, 1),
	})
	shineGradient.Rotation = 20
	shineGradient.Offset = Vector2.new(-1, 0)
	shineGradient.Parent = shine
	local title = Kit.title(ribbon, "", UDim2.new(1, -24, 1, -8), UDim2.fromOffset(12, 4), 40)
	title.TextXAlignment = Enum.TextXAlignment.Center
	title.ZIndex = 9
	Kit.overWorld(title)
	local rows = Instance.new("Frame")
	rows.Size = UDim2.new(1, -24, 1, -(RIBBON + 12 + BUTTON_ROOM))
	rows.Position = UDim2.fromOffset(12, RIBBON + 10)
	rows.BackgroundTransparency = 1
	rows.ZIndex = 9
	rows.Parent = panel
	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 2)
	list.HorizontalAlignment = Enum.HorizontalAlignment.Center
	list.VerticalAlignment = Enum.VerticalAlignment.Center
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = rows
	local button = Kit.button(panel, "Continue", Kit.COLOURS.accent, onContinue)
	button.Size = UDim2.new(0.5, 0, 0, 50)
	button.Position = UDim2.new(0.25, 0, 1, -60)
	button.ZIndex = 9

	-- The "New friend" card. Made once, filled and shown only after a catch.
	local friend = Instance.new("Frame")
	friend.Size = UDim2.new(1, -24, 0, CARD_HEIGHT)
	friend.Position = UDim2.fromOffset(12, RIBBON + 10)
	friend.BackgroundTransparency = 1
	friend.Visible = false
	friend.ZIndex = 9
	friend.Parent = panel
	-- Sizes and places are set by `sizeCard`, from the height the card has on this screen.
	local friendName = Kit.title(friend, "", UDim2.new(), UDim2.new(), 24)
	friendName.ZIndex = 9
	local friendChip = Kit.label(friend, "", UDim2.new(), UDim2.new(), 14)
	friendChip.TextXAlignment = Enum.TextXAlignment.Center
	friendChip.TextColor3 = Kit.COLOURS.white
	friendChip.BackgroundTransparency = 0
	friendChip.ZIndex = 9
	local chipCorner = Instance.new("UICorner")
	chipCorner.CornerRadius = UDim.new(0.5, 0)
	chipCorner.Parent = friendChip
	local friendBlurb = Kit.label(friend, "", UDim2.new(), UDim2.new(), 17)
	friendBlurb.TextWrapped = true
	friendBlurb.TextYAlignment = Enum.TextYAlignment.Top
	friendBlurb.TextColor3 = Kit.COLOURS.textDim
	friendBlurb.ZIndex = 9
	-- One journal fact about the species, in the body face under the blurb.
	local friendFact = Kit.label(friend, "", UDim2.new(), UDim2.new(), 14)
	friendFact.TextWrapped = true
	friendFact.TextYAlignment = Enum.TextYAlignment.Top
	friendFact.TextColor3 = Kit.COLOURS.text
	friendFact.ZIndex = 9
	local friendPlace = Kit.label(friend, "", UDim2.new(), UDim2.new(), 18)
	friendPlace.TextColor3 = Kit.COLOURS.good
	friendPlace.TextWrapped = true
	friendPlace.TextYAlignment = Enum.TextYAlignment.Top
	friendPlace.ZIndex = 9
	local picture: ViewportFrame? = nil
	local cardTall = CARD_HEIGHT

	-- The card's height on this screen, and everything in it laid out to that height: the
	-- picture is a square the height of the card, the words a column beside it.
	local function sizeCard()
		local panelTall = gui.AbsoluteSize.Y * 0.92
		cardTall = math.max(CARD_HEIGHT, math.floor(panelTall * CARD_SHARE))
		local k = cardTall / CARD_HEIGHT
		local left = cardTall + 4
		local function set(label: TextLabel, top: number, tall: number, text: number)
			label.Position = UDim2.fromOffset(left, math.floor(top * k))
			label.Size = UDim2.new(1, -left, 0, math.floor(tall * k))
			local limit = label:FindFirstChildOfClass("UITextSizeConstraint")
			if limit then
				limit.MaxTextSize = math.floor(text * k)
			end
		end
		set(friendName, 0, 26, 22)
		set(friendChip, 28, 18, 14)
		friendChip.Size = UDim2.fromOffset(math.floor(78 * k), math.floor(18 * k))
		set(friendBlurb, 48, 20, 15)
		set(friendFact, 69, 30, 14)
		set(friendPlace, 100, 18, 15)
		friend.Size = UDim2.new(1, -24, 0, cardTall)
	end

	-- The Won card's body: the coins chip, one card per creature, a line for a find. Built when
	-- the rewards arrive, so it is empty until then.
	local body = Instance.new("Frame")
	body.Size = UDim2.new(1, -24, 1, -(RIBBON + 12 + BUTTON_ROOM))
	body.Position = UDim2.fromOffset(12, RIBBON + 10)
	body.BackgroundTransparency = 1
	body.Visible = false
	body.ZIndex = 9
	body.Parent = panel

	-- A catch needs room for the card and a win for its creature cards; every other result keeps
	-- the small panel.
	local function layout(mode: "small" | "card" | "won")
		if mode == "card" then
			panel.Size = UDim2.fromScale(0.52, 0.92)
			panel.Position = UDim2.fromScale(0.24, 0.04)
			sizeCard()
			local top = RIBBON + 10 + cardTall + 4
			rows.Position = UDim2.fromOffset(12, top)
			rows.Size = UDim2.new(1, -24, 1, -(top + BUTTON_ROOM))
		elseif mode == "won" then
			panel.Size = UDim2.fromScale(0.62, 0.92)
			panel.Position = UDim2.fromScale(0.19, 0.04)
		else
			panel.Size = UDim2.fromScale(0.4, 0.46)
			panel.Position = UDim2.fromScale(0.3, 0.14)
			rows.Position = UDim2.fromOffset(12, RIBBON + 10)
			rows.Size = UDim2.new(1, -24, 1, -(RIBBON + 12 + BUTTON_ROOM))
		end
		friend.Visible = mode == "card"
		body.Visible = mode == "won"
		rows.Visible = mode ~= "won"
	end

	local function fillCard(caught: Caught)
		if picture then
			picture:Destroy()
		end
		local made = Portrait.new(
			friend,
			caught.name,
			caught.element,
			UDim2.fromOffset(cardTall - 8, cardTall - 8),
			UDim2.fromOffset(0, 4)
		)
		made.ZIndex = 9
		picture = made
		friendName.Text = `{caught.name}  Lv {caught.level}`
		friendChip.Text = caught.element
		friendChip.BackgroundColor3 = Kit.ELEMENT_COLOURS[caught.element]
		-- A species with no blurb simply has no line.
		friendBlurb.Text = SpeciesBlurbs[caught.name] or ""
		local quirk = SpeciesQuirks[caught.name]
		friendFact.Text = if quirk then quirk.facts[1] or "" else ""
		friendPlace.Text = caught.placement
		Cry.play(caught.name, AudioConfig.CRY.caughtDelay)
		Kit.pop(friend)
	end

	local shownKind: Kind? = nil
	local paid = false
	local run = 0 -- goes up each time the panel is hidden, so an old count-up stops
	local dropTween: Tween? = nil
	local shineTween: Tween? = nil

	-- The panel drops in from above with a small bounce, then the ribbon shines once. Earlier
	-- tweens are cancelled first so repeated shows never stack. Input is never held back.
	local function dropIn()
		if dropTween then
			dropTween:Cancel()
		end
		if shineTween then
			shineTween:Cancel()
		end
		local goal = panel.Position
		panel.Position = goal - UDim2.fromOffset(0, 70)
		local drop = TweenService:Create(
			panel,
			TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Position = goal }
		)
		dropTween = drop
		drop:Play()
		shineGradient.Offset = Vector2.new(-1, 0)
		local sweep = TweenService:Create(
			shineGradient,
			TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0.25),
			{ Offset = Vector2.new(1, 0) }
		)
		shineTween = sweep
		sweep:Play()
	end

	local function row(order: number, colour: Color3): TextLabel
		-- Up to four rows share the space, so a long list shrinks instead of spilling.
		local label = Kit.title(rows, "", UDim2.new(1, 0, 0.25, -2), UDim2.new(), 30)
		label.TextXAlignment = Enum.TextXAlignment.Center
		label.TextColor3 = colour
		label.LayoutOrder = order
		label.ZIndex = 9
		return label
	end

	local function countUp(label: TextLabel, word: string, amount: number, mine: number)
		local value = Instance.new("NumberValue")
		local last = -1
		local changed = value.Changed:Connect(function(now: number)
			local whole = math.floor(now + 0.5)
			if whole ~= last and mine == run then
				last = whole
				label.Text = `{word} +{whole}`
				Sfx.play("count")
			end
		end)
		local tween = TweenService:Create(
			value,
			TweenInfo.new(COUNT_SECONDS, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Value = amount }
		)
		tween:Play()
		tween.Completed:Wait()
		changed:Disconnect()
		value:Destroy()
		if mine == run then
			label.Text = `{word} +{amount}`
		end
	end

	-- One creature's card: its picture, name and level, "+N XP", and a bar that fills from where
	-- it stood to where it stands, running over into the next level when it levels up.
	local function memberCard(
		grid: Frame,
		card: MemberCard,
		high: number,
		delay: number,
		mine: number
	)
		local cell = Instance.new("Frame")
		cell.BackgroundColor3 = Kit.COLOURS.panel
		cell.BorderSizePixel = 0
		cell.ZIndex = 9
		cell.Parent = grid
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 6)
		corner.Parent = cell
		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 2
		stroke.Color = Kit.COLOURS.outline
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Parent = cell
		local face = Portrait.new(
			cell,
			card.name,
			card.element,
			UDim2.fromOffset(high - 8, high - 8),
			UDim2.fromOffset(4, 4)
		)
		face.ZIndex = 10
		local info = Instance.new("Frame")
		info.Size = UDim2.new(1, -(high + 6), 1, 0)
		info.Position = UDim2.fromOffset(high, 0)
		info.BackgroundTransparency = 1
		info.ZIndex = 10
		info.Parent = cell
		local nameHigh = math.floor(high * 0.4)
		local barHigh = math.clamp(math.floor(high * 0.28), 10, 20)
		local top = math.floor((high - nameHigh - barHigh - 4) / 2)
		local nameLabel =
			Kit.label(info, "", UDim2.new(0.6, 0, 0, nameHigh), UDim2.fromOffset(0, top), 20)
		nameLabel.ZIndex = 10
		local gainLabel = Kit.label(
			info,
			`+{card.gained} XP`,
			UDim2.new(0.4, 0, 0, nameHigh),
			UDim2.new(0.6, 0, 0, top),
			16
		)
		gainLabel.TextXAlignment = Enum.TextXAlignment.Right
		gainLabel.TextColor3 = Kit.COLOURS.accent
		gainLabel.ZIndex = 10
		local back = Instance.new("Frame")
		back.Size = UDim2.new(1, 0, 0, barHigh)
		back.Position = UDim2.fromOffset(0, top + nameHigh + 4)
		back.BackgroundColor3 = Color3.fromRGB(70, 68, 84)
		back.BorderSizePixel = 0
		back.ZIndex = 10
		back.Parent = info
		local backCorner = Instance.new("UICorner")
		backCorner.CornerRadius = UDim.new(0, 3)
		backCorner.Parent = back
		local backStroke = Instance.new("UIStroke")
		backStroke.Thickness = 2
		backStroke.Color = Kit.COLOURS.outline
		backStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		backStroke.Parent = back
		local fill = Instance.new("Frame")
		fill.BackgroundColor3 = Kit.COLOURS.accent
		fill.BorderSizePixel = 0
		fill.ZIndex = 11
		fill.Parent = back
		local fillCorner = Instance.new("UICorner")
		fillCorner.CornerRadius = UDim.new(0, 3)
		fillCorner.Parent = fill

		local segments =
			XpBar.segments(card.levelBefore, card.xpBefore, card.levelAfter, card.xpAfter)
		local shownLevel = card.levelBefore
		local function set(progress: number)
			local spot = XpBar.at(segments, progress)
			fill.Size = UDim2.fromScale(spot.fill, 1)
			nameLabel.Text = `{card.name}  Lv {spot.level}`
			if spot.level ~= shownLevel then
				shownLevel = spot.level
				gainLabel.Text = "LEVEL UP!"
				gainLabel.TextColor3 = Kit.COLOURS.good
				Kit.pop(gainLabel)
				Sfx.play("confirm")
			end
		end
		set(0)
		Kit.pop(cell)
		if #segments == 1 and segments[1].to <= segments[1].from then
			return -- nothing to fill (a bar held at the cap)
		end
		task.spawn(function()
			task.wait(delay)
			if mine ~= run then
				return
			end
			local value = Instance.new("NumberValue")
			local changed = value.Changed:Connect(function(now: number)
				if mine == run then
					set(now)
				end
			end)
			local tween = TweenService:Create(
				value,
				TweenInfo.new(BAR_SECONDS, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Value = 1 }
			)
			tween:Play()
			tween.Completed:Wait()
			changed:Disconnect()
			value:Destroy()
			if mine == run then
				set(1)
			end
		end)
	end

	local function payWon(rewards: Rewards, mine: number)
		for _, child in body:GetChildren() do
			child:Destroy()
		end
		local count = #rewards.members
		local bodyHigh = gui.AbsoluteSize.Y * 0.92 - (RIBBON + 12 + BUTTON_ROOM)
		local chipHigh = if rewards.coins > 0 then CHIP_HEIGHT else 0
		local findHigh = if rewards.material ~= "" then 20 else 0
		local gap = if chipHigh > 0 then 6 else 0
		local across = if count <= 2 then 1 else 2
		local lines = math.max(1, math.ceil(count / across))
		local room = bodyHigh - chipHigh - gap - findHigh - 4
		local high = math.clamp(math.floor((room - (lines - 1) * 6) / lines), 38, 72)
		local chip: Frame? = nil
		local coinLabel: TextLabel? = nil
		if chipHigh > 0 then
			local made = Instance.new("Frame")
			made.Size = UDim2.fromOffset(210, chipHigh)
			made.Position = UDim2.new(0.5, -105, 0, 0)
			made.BackgroundColor3 = Kit.COLOURS.panelLight
			made.BorderSizePixel = 0
			made.ZIndex = 9
			made.Parent = body
			local madeCorner = Instance.new("UICorner")
			madeCorner.CornerRadius = UDim.new(0.5, 0)
			madeCorner.Parent = made
			local madeStroke = Instance.new("UIStroke")
			madeStroke.Thickness = 2
			madeStroke.Color = Kit.COLOURS.outline
			madeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			madeStroke.Parent = made
			local coin = Instance.new("Frame")
			coin.Size = UDim2.fromOffset(chipHigh - 10, chipHigh - 10)
			coin.Position = UDim2.fromOffset(6, 5)
			coin.BackgroundColor3 = Kit.COLOURS.warn
			coin.BorderSizePixel = 0
			coin.ZIndex = 10
			coin.Parent = made
			local coinCorner = Instance.new("UICorner")
			coinCorner.CornerRadius = UDim.new(0.5, 0)
			coinCorner.Parent = coin
			local coinStroke = Instance.new("UIStroke")
			coinStroke.Thickness = 2
			coinStroke.Color = Kit.COLOURS.gold
			coinStroke.Parent = coin
			local text = Kit.label(
				made,
				"Coins +0",
				UDim2.new(1, -(chipHigh + 14), 1, -6),
				UDim2.fromOffset(chipHigh + 6, 3),
				22
			)
			text.TextColor3 = Kit.COLOURS.gold
			text.ZIndex = 10
			chip, coinLabel = made, text
			Kit.pop(made)
		end
		if count > 0 then
			local grid = Instance.new("Frame")
			grid.Size = UDim2.new(1, 0, 0, lines * high + (lines - 1) * 6)
			grid.Position = UDim2.fromOffset(0, chipHigh + gap)
			grid.BackgroundTransparency = 1
			grid.ZIndex = 9
			grid.Parent = body
			local layoutGrid = Instance.new("UIGridLayout")
			layoutGrid.CellSize = if across == 1
				then UDim2.new(1, -4, 0, high)
				else UDim2.new(0.5, -4, 0, high)
			layoutGrid.CellPadding = UDim2.fromOffset(8, 6)
			layoutGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
			layoutGrid.SortOrder = Enum.SortOrder.LayoutOrder
			layoutGrid.Parent = grid
			for index, card in rewards.members do
				memberCard(grid, card, high, 0.15 + 0.1 * (index - 1), mine)
			end
		end
		if chip and coinLabel and mine == run then
			countUp(coinLabel, "Coins", rewards.coins, mine)
		end
		if rewards.material ~= "" and mine == run then
			task.wait(ROW_GAP_SECONDS)
			local found = string.gsub(rewards.material, "(%l)(%u)", "%1 %2")
			local line = Kit.label(
				body,
				`Found: {found}`,
				UDim2.new(1, 0, 0, findHigh),
				UDim2.new(0, 0, 1, -findHigh),
				16
			)
			line.TextXAlignment = Enum.TextXAlignment.Center
			line.TextColor3 = Kit.COLOURS.textDim
			line.ZIndex = 9
			Kit.pop(line)
			Sfx.play("confirm")
		end
	end

	local function pay(rewards: Rewards, mine: number)
		local order = 0
		local function nextRow(colour: Color3): TextLabel
			order += 1
			return row(order, colour)
		end
		if rewards.coins > 0 and mine == run then
			countUp(nextRow(Kit.COLOURS.gold), "Coins", rewards.coins, mine)
			task.wait(ROW_GAP_SECONDS)
		end
		if rewards.xp > 0 and mine == run then
			countUp(nextRow(Kit.COLOURS.text), "XP", rewards.xp, mine)
			task.wait(ROW_GAP_SECONDS)
		end
		if rewards.material ~= "" and mine == run then
			local found = string.gsub(rewards.material, "(%l)(%u)", "%1 %2")
			nextRow(Kit.COLOURS.textDim).Text = `Found: {found}`
			Sfx.play("confirm")
			task.wait(ROW_GAP_SECONDS)
		end
		for _, up in rewards.levels do
			if mine ~= run or order >= 4 then
				break -- four lines fit; any further level-up is seen on the Creatures screen
			end
			local line = nextRow(Kit.COLOURS.good)
			line.Text = `{up.name} reached level {up.level}!`
			Kit.pop(line)
			Sfx.play("confirm")
			task.wait(ROW_GAP_SECONDS)
		end
	end

	return {
		show = function(kind: Kind, rewards: Rewards?, caught: Caught?)
			if shownKind ~= kind then
				shownKind = kind
				layout(
					if kind == "Caught" and caught ~= nil
						then "card"
						elseif kind == "Won" then "won"
						else "small"
				)
				if kind == "Lost" then
					row(100, Kit.COLOURS.textDim).Text = "Your team rests at the healer."
				elseif kind == "Draw" then
					row(100, Kit.COLOURS.textDim).Text = "Nobody gave in. Try again!"
				end
				if kind == "Caught" and caught then
					fillCard(caught)
				end
				title.Text = TITLES[kind]
				ribbon.BackgroundColor3 = if kind == "Won" or kind == "Caught"
					then Kit.COLOURS.gold
					else Kit.COLOURS.textDim
				panel.Visible = true
				dropIn()
				Sfx.play(if kind == "Lost" then "lose" else "win")
			end
			if rewards and not paid then
				paid = true
				task.spawn(if shownKind == "Won" then payWon else pay, rewards, run)
			end
		end,
		hide = function()
			run += 1
			shownKind, paid = nil, false
			if dropTween then
				dropTween:Cancel()
			end
			if shineTween then
				shineTween:Cancel()
			end
			panel.Visible = false
			for _, child in body:GetChildren() do
				child:Destroy()
			end
			layout("small")
			if picture then
				picture:Destroy()
				picture = nil
			end
			for _, child in rows:GetChildren() do
				if child:IsA("TextLabel") then
					child:Destroy()
				end
			end
		end,
	}
end

return ResultPanel
