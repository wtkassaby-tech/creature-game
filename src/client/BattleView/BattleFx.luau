--!strict
-- The loud part of a battle: a white flash and a shake on the card that was hit, a damage
-- number that floats up, and a big word across the screen for the moments that matter. Display
-- only: every number shown here came from the server.

local TweenService = game:GetService("TweenService")

local Kit = require(script.Parent.Parent.UI.Kit)

local BattleFx = {}

local scatter = Random.new() -- where a floating number starts; looks only, never rules

export type Fx = {
	callout: (text: string, colour: Color3) -> (),
	strike: (card: Frame, damage: number, colour: Color3, big: boolean) -> (),
	rise: (card: Frame, text: string, colour: Color3) -> (),
}

local function outlined(label: TextLabel, thickness: number)
	local stroke = Instance.new("UIStroke")
	stroke.Color = Kit.COLOURS.outline
	stroke.Thickness = thickness
	stroke.Parent = label
end

function BattleFx.new(gui: ScreenGui): Fx
	-- One callout at a time, across the middle of the screen.
	local word = Instance.new("TextLabel")
	word.Size = UDim2.new(0.9, 0, 0, 64)
	word.AnchorPoint = Vector2.new(0.5, 0.5)
	word.Position = UDim2.fromScale(0.5, 0.3)
	word.BackgroundTransparency = 1
	word.Font = Kit.FONT
	word.TextScaled = true
	word.Text = ""
	word.Visible = false
	word.ZIndex = 20
	word.Parent = gui
	outlined(word, 4)
	local wordScale = Instance.new("UIScale")
	wordScale.Parent = word
	local wordTurn = 0

	local function callout(text: string, colour: Color3)
		wordTurn += 1
		local mine = wordTurn
		word.Text = text
		word.TextColor3 = colour
		word.TextTransparency = 0
		word.Rotation = -4
		word.Visible = true
		wordScale.Scale = 0.4
		local punch = TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		TweenService:Create(wordScale, punch, { Scale = 1 }):Play()
		task.delay(0.75, function()
			if mine ~= wordTurn then
				return
			end
			local fade = TweenInfo.new(0.2, Enum.EasingStyle.Quad)
			TweenService:Create(word, fade, { TextTransparency = 1 }):Play()
			task.wait(0.2)
			if mine == wordTurn then
				word.Visible = false
			end
		end)
	end

	-- Text that floats up from a card and fades.
	local function rise(card: Frame, text: string, colour: Color3, size: number?)
		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromOffset(220, size or 38)
		label.AnchorPoint = Vector2.new(0.5, 0.5)
		-- Measured from the screen's own corner: our screens ignore the top inset, and a raw
		-- AbsolutePosition does not, which put the number a bar's height too high.
		local centre = card.AbsolutePosition - gui.AbsolutePosition + card.AbsoluteSize / 2
		local start = UDim2.fromOffset(centre.X + scatter:NextInteger(-30, 30), centre.Y)
		label.Position = start
		label.BackgroundTransparency = 1
		label.Font = Kit.FONT
		label.TextScaled = true
		label.Text = text
		label.TextColor3 = colour
		label.ZIndex = 18
		label.Parent = gui
		outlined(label, 3)
		local up = TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local goal = { Position = start - UDim2.fromOffset(0, 56), TextTransparency = 1 }
		local tween = TweenService:Create(label, up, goal)
		tween.Completed:Once(function()
			label:Destroy()
		end)
		tween:Play()
	end

	-- A hit: the card flashes white, shakes, and the damage floats up from it.
	local function strike(card: Frame, damage: number, colour: Color3, big: boolean)
		local flash = Instance.new("Frame")
		flash.Size = UDim2.fromScale(1, 1)
		flash.BackgroundColor3 = Color3.new(1, 1, 1)
		flash.BackgroundTransparency = 0.15
		flash.BorderSizePixel = 0
		flash.ZIndex = 10
		flash.Parent = card
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 14)
		corner.Parent = flash
		local fade = TweenInfo.new(0.22, Enum.EasingStyle.Quad)
		local out = TweenService:Create(flash, fade, { BackgroundTransparency = 1 })
		out.Completed:Once(function()
			flash:Destroy()
		end)
		out:Play()

		local home = card.Position
		local reach = if big then 12 else 6
		task.spawn(function()
			for step = 1, 5 do
				local push = reach * (1 - step / 6)
				local way = if step % 2 == 0 then 1 else -1
				card.Position = home + UDim2.fromOffset(way * push, way * push * 0.4)
				task.wait(0.03)
			end
			card.Position = home
		end)
		rise(card, `-{damage}`, colour, if big then 52 else 38)
	end

	return {
		callout = callout,
		strike = strike,
		rise = function(card: Frame, text: string, colour: Color3)
			rise(card, text, colour, 32)
		end,
	}
end

return BattleFx
