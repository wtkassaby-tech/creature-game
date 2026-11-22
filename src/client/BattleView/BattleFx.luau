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
}

function BattleFx.new(gui: ScreenGui): Fx
	-- One callout at a time, across the upper middle of the screen.
	local word = Instance.new("TextLabel")
	word.Size = UDim2.new(0.8, 0, 0, 48)
	word.AnchorPoint = Vector2.new(0.5, 0.5)
	word.Position = UDim2.fromScale(0.5, 0.26)
	word.BackgroundTransparency = 1
	word.Font = Kit.FONT_HEAVY
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
		label.Size = UDim2.fromOffset(220, if big then 46 else 34)
		label.AnchorPoint = Vector2.new(0.5, 0.5)
		local start = UDim2.fromOffset(at.X + scatter:NextInteger(-24, 24), at.Y)
		label.Position = start
		label.BackgroundTransparency = 1
		label.Font = Kit.FONT_HEAVY
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

	return { callout = callout, rise = rise }
end

return BattleFx
