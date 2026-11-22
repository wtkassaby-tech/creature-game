--!strict
-- Small building blocks for the screens. The look is the plain, flat one of the classic Roblox
-- creature games (Ayrton, 22 November 2026: the outlined, shaded first try "looks really AI
-- generated"): dark see-through plates, flat buttons, one bold typeface, and as little on the
-- screen as possible, so the world and the creatures are what the player looks at. Every screen
-- is built from these, so the look changes in one place. All of it is made in code: no images.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Sfx = require(script.Parent.Parent.Audio.Sfx)
local Types = require(ReplicatedStorage.shared.Types)

local Kit = {}

Kit.COLOURS = {
	panel = Color3.fromRGB(20, 24, 32),
	panelLight = Color3.fromRGB(44, 52, 66),
	outline = Color3.fromRGB(10, 12, 18),
	text = Color3.fromRGB(255, 255, 255),
	textDim = Color3.fromRGB(190, 198, 210),
	good = Color3.fromRGB(64, 200, 96),
	warn = Color3.fromRGB(250, 200, 50),
	bad = Color3.fromRGB(232, 72, 72),
	accent = Color3.fromRGB(48, 132, 232),
	lasso = Color3.fromRGB(240, 148, 40),
	tempo = Color3.fromRGB(170, 96, 220),
	gold = Color3.fromRGB(255, 210, 60),
}

-- How see-through a panel is: enough to feel light, not so much that text over grass is lost.
Kit.PANEL_TRANSPARENCY = 0.05

-- One colour per type, used wherever a type is shown (move buttons, chips), so players learn
-- the types by colour.
local ELEMENT_COLOURS: Types.ByElement<Color3> = {
	Leaf = Color3.fromRGB(70, 168, 76),
	Sand = Color3.fromRGB(196, 150, 78),
	Water = Color3.fromRGB(52, 140, 228),
	Toxic = Color3.fromRGB(148, 84, 196),
	Frost = Color3.fromRGB(72, 184, 204),
	Crystal = Color3.fromRGB(224, 88, 142),
	Fire = Color3.fromRGB(228, 96, 52),
	Storm = Color3.fromRGB(212, 164, 20),
	Arcane = Color3.fromRGB(104, 116, 204),
	Cosmic = Color3.fromRGB(80, 66, 162),
}
Kit.ELEMENT_COLOURS = ELEMENT_COLOURS

Kit.FONT = Enum.Font.GothamBold
Kit.FONT_HEAVY = Enum.Font.GothamBlack -- names and titles

local BIG_TEXT = 24 -- text this size or larger is a title: heavier, with a thin dark edge

local function round(instance: Instance, radius: number)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = instance
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
	frame.BackgroundTransparency = Kit.PANEL_TRANSPARENCY
	frame.BorderSizePixel = 0
	frame.Parent = parent
	round(frame, 8)
	return frame
end

function Kit.label(
	parent: Instance,
	text: string,
	size: UDim2,
	position: UDim2,
	maxTextSize: number?
): TextLabel
	local big = (maxTextSize or 22) >= BIG_TEXT
	local label = Instance.new("TextLabel")
	label.Size = size
	label.Position = position
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Kit.COLOURS.text
	label.Font = if big then Kit.FONT_HEAVY else Kit.FONT
	label.TextScaled = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	local limit = Instance.new("UITextSizeConstraint")
	limit.MaxTextSize = maxTextSize or 22
	limit.MinTextSize = 8
	limit.Parent = label
	if big then
		label.TextStrokeColor3 = Kit.COLOURS.outline
		label.TextStrokeTransparency = 0.5
	end
	return label
end

function Kit.button(parent: Instance, text: string, colour: Color3, onClick: () -> ()): TextButton
	local button = Instance.new("TextButton")
	button.Text = text
	button.TextColor3 = Kit.COLOURS.text
	button.Font = Kit.FONT
	button.TextScaled = true
	button.AutoButtonColor = true -- Roblox's own darkening on hover and press
	button.BackgroundColor3 = colour
	button.BorderSizePixel = 0
	button.Parent = parent
	round(button, 8)
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft, pad.PaddingRight = UDim.new(0, 8), UDim.new(0, 8)
	pad.PaddingTop, pad.PaddingBottom = UDim.new(0, 6), UDim.new(0, 6)
	pad.Parent = button
	local limit = Instance.new("UITextSizeConstraint")
	limit.MaxTextSize = 20
	limit.MinTextSize = 8
	limit.Parent = button
	button.Activated:Connect(function()
		Sfx.play("press")
		onClick()
	end)
	return button
end

-- A scrolling list cuts off whatever pokes past its edge. A few pixels of padding keeps the
-- rows inside it whole.
function Kit.roomForOutlines(list: Instance)
	local pad = Instance.new("UIPadding")
	pad.PaddingTop, pad.PaddingBottom = UDim.new(0, 3), UDim.new(0, 3)
	pad.PaddingLeft, pad.PaddingRight = UDim.new(0, 3), UDim.new(0, 3)
	pad.Parent = list
end

-- A panel that has just appeared grows the last few per cent.
function Kit.pop(target: GuiObject)
	local scale = target:FindFirstChildOfClass("UIScale")
	if not scale then
		local made = Instance.new("UIScale")
		made.Parent = target
		scale = made
	end
	if scale then
		scale.Scale = 0.94
		local settle = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(scale, settle, { Scale = 1 }):Play()
	end
end

export type Bar = { set: (share: number, colour: Color3?) -> (), frame: Frame }

-- A bar that fills from the left. `set` takes a share from 0 to 1. When the bar drops, a pale
-- trail stays for a moment and then follows, so the size of a hit can be read at a glance.
function Kit.bar(parent: Instance, size: UDim2, position: UDim2, colour: Color3): Bar
	local back = Instance.new("Frame")
	back.Size = size
	back.Position = position
	back.BackgroundColor3 = Color3.fromRGB(8, 10, 14)
	back.BorderSizePixel = 0
	back.Parent = parent
	local backCorner = Instance.new("UICorner")
	backCorner.CornerRadius = UDim.new(0.5, 0)
	backCorner.Parent = back
	local function strip(stripColour: Color3, order: number): Frame
		local made = Instance.new("Frame")
		made.Size = UDim2.fromScale(1, 1)
		made.BackgroundColor3 = stripColour
		made.BorderSizePixel = 0
		made.ZIndex = order
		made.Parent = back
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0.5, 0)
		corner.Parent = made
		return made
	end
	local trail = strip(Color3.fromRGB(255, 244, 214), 1)
	local fill = strip(colour, 2)
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
