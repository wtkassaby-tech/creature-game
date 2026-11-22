--!strict
-- Small building blocks for the screens. The look is that of an old handheld creature game
-- (Ayrton, 23 November 2026: "a great nostalgic feel, a homely feel"): warm cream boxes with a
-- thick dark border, dark ink text, a pixel typeface for names, titles and buttons, and plain
-- chunky bars. Every screen is built from these, so the look changes in one place. All of it is
-- made in code: no images.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Sfx = require(script.Parent.Parent.Audio.Sfx)
local Types = require(ReplicatedStorage.shared.Types)

local Kit = {}

Kit.COLOURS = {
	panel = Color3.fromRGB(250, 243, 222), -- warm cream paper
	panelLight = Color3.fromRGB(236, 226, 196),
	outline = Color3.fromRGB(46, 44, 62), -- ink
	text = Color3.fromRGB(46, 44, 62),
	textDim = Color3.fromRGB(124, 118, 132),
	good = Color3.fromRGB(72, 184, 88),
	warn = Color3.fromRGB(240, 184, 40),
	bad = Color3.fromRGB(216, 72, 60),
	accent = Color3.fromRGB(70, 122, 208),
	lasso = Color3.fromRGB(224, 136, 44),
	tempo = Color3.fromRGB(150, 96, 200),
	gold = Color3.fromRGB(204, 140, 16), -- dark enough to read on cream
	white = Color3.fromRGB(255, 255, 255),
}

-- One colour per type, used wherever a type is shown (move buttons, chips), so players learn
-- the types by colour.
local ELEMENT_COLOURS: Types.ByElement<Color3> = {
	Leaf = Color3.fromRGB(88, 168, 80),
	Sand = Color3.fromRGB(196, 150, 84),
	Water = Color3.fromRGB(72, 136, 216),
	Toxic = Color3.fromRGB(150, 92, 190),
	Frost = Color3.fromRGB(84, 176, 196),
	Crystal = Color3.fromRGB(214, 96, 142),
	Fire = Color3.fromRGB(220, 104, 60),
	Storm = Color3.fromRGB(200, 156, 28),
	Arcane = Color3.fromRGB(108, 116, 196),
	Cosmic = Color3.fromRGB(88, 74, 160),
}
Kit.ELEMENT_COLOURS = ELEMENT_COLOURS

Kit.FONT = Enum.Font.SourceSansBold -- sentences: easy to read at small sizes
Kit.FONT_PIXEL = Enum.Font.Arcade -- names, titles, buttons, numbers

local BIG_TEXT = 24 -- text this size or larger is a title and is set in the pixel face
local PIXEL_SHRINK = 0.85 -- the pixel face is wide: it is set smaller to fill the same space

local function round(instance: Instance, radius: number)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = instance
end

local function border(instance: Instance, thickness: number)
	local stroke = Instance.new("UIStroke")
	stroke.Color = Kit.COLOURS.outline
	stroke.Thickness = thickness
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = instance
end

-- Text that sits straight on the world, not in a box, is white with a dark edge.
function Kit.overWorld(label: TextLabel)
	label.TextColor3 = Kit.COLOURS.white
	label.TextStrokeColor3 = Kit.COLOURS.outline
	label.TextStrokeTransparency = 0
end

function Kit.screen(parent: Instance, name: string, order: number): ScreenGui
	local gui = Instance.new("ScreenGui")
	gui.Name = name
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	-- Children draw over their parent and are ordered among their siblings: a picture set
	-- behind a box's text stays inside the box.
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
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
	round(frame, 8)
	border(frame, 3)
	return frame
end

function Kit.label(
	parent: Instance,
	text: string,
	size: UDim2,
	position: UDim2,
	maxTextSize: number?
): TextLabel
	local wanted = maxTextSize or 22
	local big = wanted >= BIG_TEXT
	local label = Instance.new("TextLabel")
	label.Size = size
	label.Position = position
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Kit.COLOURS.text
	label.Font = if big then Kit.FONT_PIXEL else Kit.FONT
	label.TextScaled = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	local limit = Instance.new("UITextSizeConstraint")
	limit.MaxTextSize = if big then math.floor(wanted * PIXEL_SHRINK) else wanted
	limit.MinTextSize = 8
	limit.Parent = label
	return label
end

-- Sets a label in the pixel face at a given size (a name, a number).
function Kit.pixel(label: TextLabel, size: number)
	label.Font = Kit.FONT_PIXEL
	local limit = label:FindFirstChildOfClass("UITextSizeConstraint")
	if limit then
		limit.MaxTextSize = size
	end
end

local function isDark(colour: Color3): boolean
	return colour.R * 0.299 + colour.G * 0.587 + colour.B * 0.114 < 0.72
end

function Kit.button(parent: Instance, text: string, colour: Color3, onClick: () -> ()): TextButton
	local button = Instance.new("TextButton")
	button.Text = text
	-- White letters on a coloured button, ink on a pale one.
	button.TextColor3 = if isDark(colour) then Kit.COLOURS.white else Kit.COLOURS.text
	button.Font = Kit.FONT_PIXEL
	button.TextScaled = true
	button.AutoButtonColor = true -- Roblox's own darkening on hover and press
	button.BackgroundColor3 = colour
	button.BorderSizePixel = 0
	button.Parent = parent
	round(button, 6)
	border(button, 3)
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft, pad.PaddingRight = UDim.new(0, 8), UDim.new(0, 8)
	pad.PaddingTop, pad.PaddingBottom = UDim.new(0, 6), UDim.new(0, 6)
	pad.Parent = button
	local limit = Instance.new("UITextSizeConstraint")
	limit.MaxTextSize = 20
	limit.MinTextSize = 7
	limit.Parent = button
	button.Activated:Connect(function()
		Sfx.play("press")
		onClick()
	end)
	return button
end

-- Diagonal candy stripes across a coloured surface, a shade lighter and darker than its own
-- colour, so it is not one flat block. One gradient with hard steps: it follows the rounded
-- corners and costs nothing to draw.
function Kit.stripes(target: GuiObject)
	local points: { ColorSequenceKeypoint } = {}
	local bands = 9
	for band = 0, bands - 1 do
		local from, to = band / bands, (band + 1) / bands
		local shade = if band % 2 == 0 then 1 else 0.88
		table.insert(points, ColorSequenceKeypoint.new(from, Color3.new(shade, shade, shade)))
		table.insert(
			points,
			ColorSequenceKeypoint.new(
				if band == bands - 1 then 1 else to - 0.001,
				Color3.new(shade, shade, shade)
			)
		)
	end
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new(points)
	gradient.Rotation = 35
	gradient.Parent = target
end

-- A darker strip set into a coloured button, for the small print along its bottom edge.
function Kit.inset(parent: Instance, size: UDim2, position: UDim2): Frame
	local band = Instance.new("Frame")
	band.Size = size
	band.Position = position
	band.BackgroundColor3 = Kit.COLOURS.outline
	band.BackgroundTransparency = 0.55
	band.BorderSizePixel = 0
	band.Parent = parent
	round(band, 4)
	return band
end

-- A scrolling list cuts off whatever pokes past its edge, which would shave the borders of the
-- rows inside it. A few pixels of padding keeps them whole.
function Kit.roomForOutlines(list: Instance)
	local pad = Instance.new("UIPadding")
	pad.PaddingTop, pad.PaddingBottom = UDim.new(0, 4), UDim.new(0, 4)
	pad.PaddingLeft, pad.PaddingRight = UDim.new(0, 4), UDim.new(0, 4)
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
	back.BackgroundColor3 = Color3.fromRGB(70, 68, 84)
	back.BorderSizePixel = 0
	back.Parent = parent
	round(back, 3)
	border(back, 2)
	local function strip(stripColour: Color3, order: number): Frame
		local made = Instance.new("Frame")
		made.Size = UDim2.fromScale(1, 1)
		made.BackgroundColor3 = stripColour
		made.BorderSizePixel = 0
		made.ZIndex = order
		made.Parent = back
		round(made, 3)
		return made
	end
	local trail = strip(Color3.fromRGB(255, 236, 190), 1)
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
