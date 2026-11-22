--!strict
-- Small building blocks for the screens, in the "toy arcade" look (docs/research/games): chunky
-- rounded panels with a dark outline, buttons with a darker lip that sinks when pressed, big
-- outlined type, and bars that leave a pale trail as they drop. Every screen is built from
-- these so the look changes in one place. All of it is made in code: no images.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Sfx = require(script.Parent.Parent.Audio.Sfx)
local Types = require(ReplicatedStorage.shared.Types)

local Kit = {}

Kit.COLOURS = {
	panel = Color3.fromRGB(36, 48, 66),
	panelLight = Color3.fromRGB(54, 72, 98),
	outline = Color3.fromRGB(14, 20, 30),
	text = Color3.fromRGB(255, 255, 255),
	textDim = Color3.fromRGB(196, 210, 226),
	good = Color3.fromRGB(88, 196, 96),
	warn = Color3.fromRGB(255, 205, 44),
	bad = Color3.fromRGB(240, 84, 80),
	accent = Color3.fromRGB(58, 160, 250),
	lasso = Color3.fromRGB(255, 160, 40),
	tempo = Color3.fromRGB(176, 92, 226),
	gold = Color3.fromRGB(255, 214, 64),
}

-- One colour per type, used wherever a type is shown (move buttons, chips), so players learn
-- the types by colour.
local ELEMENT_COLOURS: Types.ByElement<Color3> = {
	Leaf = Color3.fromRGB(76, 176, 80),
	Sand = Color3.fromRGB(206, 160, 84),
	Water = Color3.fromRGB(58, 150, 240),
	Toxic = Color3.fromRGB(156, 88, 204),
	Frost = Color3.fromRGB(86, 196, 214),
	Crystal = Color3.fromRGB(236, 96, 150),
	Fire = Color3.fromRGB(240, 104, 56),
	Storm = Color3.fromRGB(226, 176, 24),
	Arcane = Color3.fromRGB(112, 124, 214),
	Cosmic = Color3.fromRGB(84, 70, 170),
}
Kit.ELEMENT_COLOURS = ELEMENT_COLOURS

Kit.FONT = Enum.Font.FredokaOne

local BIG_TEXT = 24 -- text this size or larger gets a dark outline

local function round(instance: Instance, radius: number)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = instance
end

local function outline(instance: Instance, thickness: number)
	local stroke = Instance.new("UIStroke")
	stroke.Color = Kit.COLOURS.outline
	stroke.Thickness = thickness
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = instance
end

local function grey(value: number): Color3
	return Color3.new(value, value, value)
end

local LIP_PIXELS = 7 -- how tall the darker band under a button is, whatever the button's size

-- The share of a button's height that the lip takes.
local function lipShare(button: GuiObject): number
	return math.clamp(LIP_PIXELS / math.max(1, button.AbsoluteSize.Y), 0.03, 0.3)
end

-- Top to bottom shading: lighter at the top, a little darker at the bottom.
local function shade(instance: Instance): UIGradient
	local gradient = Instance.new("UIGradient")
	gradient.Rotation = 90
	gradient.Color = ColorSequence.new(grey(1), grey(0.86))
	gradient.Parent = instance
	return gradient
end

-- A button's shading has a darker band along the bottom, the lip, that makes it look raised.
-- The band is part of the gradient, so it follows the rounded corners; it is kept the same
-- height in pixels by redrawing the gradient when the button changes size.
local function shadeWithLip(button: GuiObject): UIGradient
	local gradient = shade(button)
	local function draw()
		local edge = 1 - lipShare(button)
		gradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, grey(1)),
			ColorSequenceKeypoint.new(edge - 0.01, grey(0.9)),
			ColorSequenceKeypoint.new(edge, grey(0.62)),
			ColorSequenceKeypoint.new(1, grey(0.62)),
		})
	end
	button:GetPropertyChangedSignal("AbsoluteSize"):Connect(draw)
	draw()
	return gradient
end

function Kit.screen(parent: Instance, name: string, order: number): ScreenGui
	local gui = Instance.new("ScreenGui")
	gui.Name = name
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = order
	gui.Enabled = false
	gui.Parent = parent
	return gui
end

function Kit.panel(parent: Instance, size: UDim2, position: UDim2, colour: Color3?): Frame
	local frame = Instance.new("Frame")
	frame.Size = size
	frame.Position = position
	frame.BackgroundColor3 = colour or Kit.COLOURS.panel
	frame.BorderSizePixel = 0
	frame.Parent = parent
	round(frame, 14)
	outline(frame, 3)
	shade(frame)
	return frame
end

function Kit.label(
	parent: Instance,
	text: string,
	size: UDim2,
	position: UDim2,
	maxTextSize: number?
): TextLabel
	local label = Instance.new("TextLabel")
	label.Size = size
	label.Position = position
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Kit.COLOURS.text
	label.Font = Kit.FONT
	label.TextScaled = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	local limit = Instance.new("UITextSizeConstraint")
	limit.MaxTextSize = maxTextSize or 22
	limit.MinTextSize = 8
	limit.Parent = label
	if (maxTextSize or 22) >= BIG_TEXT then
		local stroke = Instance.new("UIStroke")
		stroke.Color = Kit.COLOURS.outline
		stroke.Thickness = 2
		stroke.Parent = label -- on a label the stroke outlines the letters
	end
	return label
end

local PRESS = TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local RELEASE = TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local function isPress(input: InputObject): boolean
	return input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
end

function Kit.button(parent: Instance, text: string, colour: Color3, onClick: () -> ()): TextButton
	local button = Instance.new("TextButton")
	button.Text = text
	button.TextColor3 = Kit.COLOURS.text
	button.TextStrokeColor3 = Kit.COLOURS.outline
	button.TextStrokeTransparency = 0.35
	button.Font = Kit.FONT
	button.TextScaled = true
	button.AutoButtonColor = false -- the lip sinking is the press feedback
	button.BackgroundColor3 = colour
	button.BorderSizePixel = 0
	button.Parent = parent
	round(button, 12)
	outline(button, 2.5)
	local gradient = shadeWithLip(button)
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft, pad.PaddingRight = UDim.new(0, 8), UDim.new(0, 8)
	pad.PaddingTop, pad.PaddingBottom = UDim.new(0, 5), UDim.new(0, 9) -- the lip is not for text
	pad.Parent = button
	local limit = Instance.new("UITextSizeConstraint")
	limit.MaxTextSize = 22
	limit.MinTextSize = 8
	limit.Parent = button

	-- Pressing slides the shading down so the lip disappears: the button looks pushed in. It
	-- springs back on release. Nothing moves or resizes, so lists and grids are not disturbed.
	local function sink(down: boolean)
		local goal = { Offset = if down then Vector2.new(0, lipShare(button)) else Vector2.zero }
		TweenService:Create(gradient, if down then PRESS else RELEASE, goal):Play()
	end
	button.InputBegan:Connect(function(input)
		if isPress(input) then
			sink(true)
		end
	end)
	button.InputEnded:Connect(function(input)
		if isPress(input) then
			sink(false)
		end
	end)
	button.Activated:Connect(function()
		Sfx.play("press")
		onClick()
	end)
	return button
end

-- A scrolling list cuts off whatever pokes past its edge, which would shave the outlines of
-- the rows inside it. A few pixels of padding keeps them whole.
function Kit.roomForOutlines(list: Instance)
	local pad = Instance.new("UIPadding")
	pad.PaddingTop, pad.PaddingBottom = UDim.new(0, 3), UDim.new(0, 3)
	pad.PaddingLeft, pad.PaddingRight = UDim.new(0, 3), UDim.new(0, 3)
	pad.Parent = list
end

-- A panel that has just appeared grows the last few per cent with a little bounce.
function Kit.pop(target: GuiObject)
	local scale = target:FindFirstChildOfClass("UIScale")
	if not scale then
		local made = Instance.new("UIScale")
		made.Parent = target
		scale = made
	end
	if scale then
		scale.Scale = 0.9
		TweenService:Create(scale, RELEASE, { Scale = 1 }):Play()
	end
end

export type Bar = { set: (share: number, colour: Color3?) -> (), frame: Frame }

-- A bar that fills from the left. `set` takes a share from 0 to 1. When the bar drops, a pale
-- trail stays for a moment and then follows, so the size of a hit can be read at a glance.
function Kit.bar(parent: Instance, size: UDim2, position: UDim2, colour: Color3): Bar
	local back = Instance.new("Frame")
	back.Size = size
	back.Position = position
	back.BackgroundColor3 = Color3.fromRGB(12, 16, 24)
	back.BorderSizePixel = 0
	back.Parent = parent
	round(back, 6)
	outline(back, 2)
	local trail = Instance.new("Frame")
	trail.Size = UDim2.fromScale(1, 1)
	trail.BackgroundColor3 = Color3.fromRGB(255, 244, 214)
	trail.BorderSizePixel = 0
	trail.Parent = back
	round(trail, 6)
	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(1, 1)
	fill.BackgroundColor3 = colour
	fill.BorderSizePixel = 0
	fill.ZIndex = 2
	fill.Parent = back
	round(fill, 6)
	shade(fill)
	local shown = 1
	local latest = 0
	return {
		frame = back,
		set = function(share: number, newColour: Color3?)
			local clamped = if share ~= share then 0 else math.clamp(share, 0, 1)
			if newColour then
				fill.BackgroundColor3 = newColour
			end
			if clamped == shown then
				return
			end
			local dropped = clamped < shown
			shown = clamped
			latest += 1
			local mine = latest
			local goal = { Size = UDim2.fromScale(clamped, 1) }
			TweenService:Create(fill, TweenInfo.new(0.18, Enum.EasingStyle.Quad), goal):Play()
			if dropped then
				task.delay(0.35, function()
					if mine == latest then
						local slow = TweenInfo.new(0.4, Enum.EasingStyle.Quad)
						TweenService:Create(trail, slow, goal):Play()
					end
				end)
			else
				trail.Size = goal.Size -- a bar that rises has no trail
			end
		end,
	}
end

-- Green when healthy, yellow when hurt, red when nearly out.
function Kit.healthColour(share: number): Color3
	if share > 0.5 then
		return Kit.COLOURS.good
	elseif share > 0.2 then
		return Kit.COLOURS.warn
	end
	return Kit.COLOURS.bad
end

return Kit
