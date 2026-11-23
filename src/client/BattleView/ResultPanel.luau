--!strict
-- The end of a battle: a big title, then what was earned, each line arriving in turn with the
-- numbers counting up, and one button to carry on. The rewards may arrive from the server before
-- or after the last turn has been shown, so `show` can be called twice; each part plays once.

-- After a catch the panel also carries a "New friend" card above the rewards: the creature's
-- picture, name, level, type, a line about it, and where it went. Looks only.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Portrait = require(script.Parent.Parent.Creatures.Portrait)
local Kit = require(script.Parent.Parent.UI.Kit)
local Sfx = require(script.Parent.Parent.Audio.Sfx)
local SpeciesBlurbs = require(ReplicatedStorage.content.SpeciesBlurbs)
local Types = require(ReplicatedStorage.shared.Types)

local ResultPanel = {}

export type LevelUp = { name: string, level: number }
export type Rewards = { coins: number, xp: number, material: string, levels: { LevelUp } }
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
	local title = Kit.label(ribbon, "", UDim2.new(1, -24, 1, -8), UDim2.fromOffset(12, 4), 40)
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
	local friendName = Kit.label(friend, "", UDim2.new(), UDim2.new(), 24)
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
		set(friendName, 0, 28, 22)
		set(friendChip, 32, 20, 14)
		friendChip.Size = UDim2.fromOffset(math.floor(78 * k), math.floor(20 * k))
		set(friendBlurb, 56, 26, 17)
		set(friendPlace, 84, 34, 16)
		friend.Size = UDim2.new(1, -24, 0, cardTall)
	end

	-- A catch needs room for the card; every other result keeps the small panel.
	local function layout(withCard: boolean)
		if withCard then
			panel.Size = UDim2.fromScale(0.52, 0.92)
			panel.Position = UDim2.fromScale(0.24, 0.04)
			sizeCard()
			local top = RIBBON + 10 + cardTall + 4
			rows.Position = UDim2.fromOffset(12, top)
			rows.Size = UDim2.new(1, -24, 1, -(top + BUTTON_ROOM))
		else
			panel.Size = UDim2.fromScale(0.4, 0.46)
			panel.Position = UDim2.fromScale(0.3, 0.14)
			rows.Position = UDim2.fromOffset(12, RIBBON + 10)
			rows.Size = UDim2.new(1, -24, 1, -(RIBBON + 12 + BUTTON_ROOM))
		end
		friend.Visible = withCard
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
		friendPlace.Text = caught.placement
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
		local label = Kit.label(rows, "", UDim2.new(1, 0, 0.25, -2), UDim2.new(), 30)
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
				layout(kind == "Caught" and caught ~= nil)
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
				task.spawn(pay, rewards, run)
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
			layout(false)
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
