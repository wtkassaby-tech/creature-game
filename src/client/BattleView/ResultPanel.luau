--!strict
-- The end of a battle: a big title, then what was earned, each line arriving in turn with the
-- numbers counting up, and one button to carry on. The rewards may arrive from the server before
-- or after the last turn has been shown, so `show` can be called twice; each part plays once.

local TweenService = game:GetService("TweenService")

local Kit = require(script.Parent.Parent.UI.Kit)
local Sfx = require(script.Parent.Parent.Audio.Sfx)

local ResultPanel = {}

export type Rewards = { coins: number, xp: number, material: string, levels: { number } }
export type Kind = "Won" | "Caught" | "Lost" | "Draw"
export type View = {
	show: (kind: Kind, rewards: Rewards?) -> (),
	hide: () -> (),
}

local TITLES: { [Kind]: string } =
	{ Won = "VICTORY!", Caught = "CAUGHT!", Lost = "DEFEATED", Draw = "A DRAW" }

local COUNT_SECONDS = 0.6
local ROW_GAP_SECONDS = 0.25

function ResultPanel.new(gui: ScreenGui, onContinue: () -> ()): View
	local panel = Kit.panel(
		gui,
		UDim2.fromScale(0.5, 0.56),
		UDim2.fromScale(0.25, 0.1),
		Kit.COLOURS.panelLight
	)
	panel.Visible = false
	panel.ZIndex = 8
	local title = Kit.label(panel, "", UDim2.new(1, -24, 0, 46), UDim2.fromOffset(12, 8), 40)
	title.TextXAlignment = Enum.TextXAlignment.Center
	title.ZIndex = 9
	local rows = Instance.new("Frame")
	rows.Size = UDim2.new(1, -24, 1, -126)
	rows.Position = UDim2.fromOffset(12, 58)
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

	local shownKind: Kind? = nil
	local paid = false
	local run = 0 -- goes up each time the panel is hidden, so an old count-up stops

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
		for _, level in rewards.levels do
			if mine ~= run or order >= 4 then
				break -- four lines fit; any further level-up is seen on the Creatures screen
			end
			local line = nextRow(Kit.COLOURS.good)
			line.Text = `Level {level}!`
			Kit.pop(line)
			Sfx.play("confirm")
			task.wait(ROW_GAP_SECONDS)
		end
	end

	return {
		show = function(kind: Kind, rewards: Rewards?)
			if shownKind ~= kind then
				shownKind = kind
				title.Text = TITLES[kind]
				title.TextColor3 = if kind == "Won" or kind == "Caught"
					then Kit.COLOURS.gold
					else Kit.COLOURS.textDim
				panel.Visible = true
				Kit.pop(panel)
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
			panel.Visible = false
			for _, child in rows:GetChildren() do
				if child:IsA("TextLabel") then
					child:Destroy()
				end
			end
		end,
	}
end

return ResultPanel
