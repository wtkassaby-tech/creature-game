--!strict
-- Words and numbers over a battle: the damage that floats up from the creature that was hit,
-- and a short word across the screen for the moments that matter. (The creatures' own flash,
-- shake and lunge are in BattleStage.) Display only: every number came from the server.

local TweenService = game:GetService("TweenService")

local Kit = require(script.Parent.Parent.UI.Kit)

local BattleFx = {}

local scatter = Random.new() -- where a floating number starts; looks only, never rules

export type Fx = {
	callout: (text: string, colour: Color3) -> (),
	rise: (at: Vector2, text: string, colour: Color3, big: boolean) -> (),
	flash: () -> (), -- a quick white glow around the screen's edge, for a strong hit
}

function BattleFx.new(gui: ScreenGui): Fx
	-- One callout at a time, across the upper middle of the screen.
	local word = Instance.new("TextLabel")
	word.Size = UDim2.new(0.8, 0, 0, 34)
	word.AnchorPoint = Vector2.new(0.5, 0.5)
	word.Position = UDim2.fromScale(0.5, 0.26)
	word.BackgroundTransparency = 1
	word.Font = Kit.FONT_PIXEL
	word.TextScaled = true
	word.TextStrokeColor3 = Kit.COLOURS.outline
	word.TextStrokeTransparency = 0.2
	word.Text = ""
	word.Visible = false
	word.ZIndex = 20
	word.Parent = gui
	local wordScale = Instance.new("UIScale")
	wordScale.Parent = word
	local wordTurn = 0

	local function callout(text: string, colour: Color3)
		wordTurn += 1
		local mine = wordTurn
		word.Text = text
		word.TextColor3 = colour
		word.TextTransparency = 0
		word.TextStrokeTransparency = 0.2
		word.Visible = true
		wordScale.Scale = 0.7
		local punch = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(wordScale, punch, { Scale = 1 }):Play()
		task.delay(0.7, function()
			if mine ~= wordTurn then
				return
			end
			local fade = TweenInfo.new(0.2, Enum.EasingStyle.Quad)
			local goal = { TextTransparency = 1, TextStrokeTransparency = 1 }
			TweenService:Create(word, fade, goal):Play()
			task.wait(0.2)
			if mine == wordTurn then
				word.Visible = false
			end
		end)
	end

	-- Text that floats up from a point on the screen and fades.
	local function rise(at: Vector2, text: string, colour: Color3, big: boolean)
		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromOffset(220, if big then 34 else 24)
		label.AnchorPoint = Vector2.new(0.5, 0.5)
		local start = UDim2.fromOffset(at.X + scatter:NextInteger(-24, 24), at.Y)
		label.Position = start
		label.BackgroundTransparency = 1
		label.Font = Kit.FONT_PIXEL
		label.TextScaled = true
		label.Text = text
		label.TextColor3 = colour
		label.TextStrokeColor3 = Kit.COLOURS.outline
		label.TextStrokeTransparency = 0
		label.ZIndex = 18
		label.Parent = gui
		local up = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local goal = {
			Position = start - UDim2.fromOffset(0, 60),
			TextTransparency = 1,
			TextStrokeTransparency = 1,
		}
		local tween = TweenService:Create(label, up, goal)
		tween.Completed:Once(function()
			label:Destroy()
		end)
		tween:Play()
	end

	-- A brief white glow around the screen's edge, for a strong hit. Four strips, each fading
	-- toward the middle, so the creatures stay clear.
	local edges: { Frame } = {}
	for _, turn in { 0, 180, 90, 270 } do -- left, right, top, bottom
		local strip = Instance.new("Frame")
		strip.AnchorPoint = Vector2.new(0.5, 0.5)
		if turn % 180 == 0 then
			strip.Size = UDim2.fromScale(0.22, 1)
			strip.Position = if turn == 0
				then UDim2.fromScale(0.11, 0.5)
				else UDim2.fromScale(0.89, 0.5)
		else
			strip.Size = UDim2.fromScale(1, 0.3)
			strip.Position = if turn == 90
				then UDim2.fromScale(0.5, 0.15)
				else UDim2.fromScale(0.5, 0.85)
		end
		strip.BackgroundColor3 = Color3.new(1, 1, 1)
		strip.BackgroundTransparency = 1
		strip.BorderSizePixel = 0
		strip.Visible = false
		strip.ZIndex = 17
		strip.Active = false
		local fade = Instance.new("UIGradient")
		fade.Transparency = NumberSequence.new(0, 1)
		fade.Rotation = turn
		fade.Parent = strip
		strip.Parent = gui
		table.insert(edges, strip)
	end
	local flashTurn = 0

	local function flash()
		flashTurn += 1
		local mine = flashTurn
		for _, strip in edges do
			strip.Visible = true
			strip.BackgroundTransparency = 1
			local snap = TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			TweenService:Create(strip, snap, { BackgroundTransparency = 0.25 }):Play()
		end
		task.delay(0.05, function()
			if mine ~= flashTurn then
				return
			end
			local fall = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			for _, strip in edges do
				TweenService:Create(strip, fall, { BackgroundTransparency = 1 }):Play()
			end
			task.wait(0.24)
			if mine == flashTurn then
				for _, strip in edges do
					strip.Visible = false
				end
			end
		end)
	end

	return { callout = callout, rise = rise, flash = flash }
end

return BattleFx
