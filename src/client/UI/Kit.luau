--!strict
-- Small building blocks for the screens. The look is that of an old handheld creature game
-- (Ayrton, 23 November 2026: "a great nostalgic feel, a homely feel"): warm cream boxes with a
-- thick dark border, dark ink text, a pixel typeface for names, titles, numbers and buttons, a
-- warm rounded face for sentences, and plain chunky bars. Every screen is built from these, so
-- the look changes in one place. All of it is made in code: no images.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Icons = require(script.Parent.Icons)
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
	neutral = Color3.fromRGB(222, 212, 184), -- Close, Back and other quiet buttons
	muted = Color3.fromRGB(204, 198, 182), -- the face of a disabled button
	mutedInk = Color3.fromRGB(140, 134, 140), -- its letters
}

-- One set of corner radii, border widths and gaps for every screen.
Kit.RADIUS = { small = 4, normal = 6, large = 8 }
Kit.STROKE = { thin = 2, normal = 3, heavy = 4 }
Kit.SPACE = { tight = 4, normal = 8, wide = 12, roomy = 16 }
Kit.LIP = 4 -- the darker strip along the bottom of a button
Kit.CLOSE_SIZE = UDim2.fromOffset(96, 44) -- Close and Back: finger-sized on a phone

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

-- Fonts are chosen by role, never by size. Sentences (dialogue, blurbs, battle messages,
-- descriptions) are Nunito, a warm rounded family that ships with Roblox
-- (rbxasset://fonts/families/Nunito.json). Titles, names, numbers and buttons are the pixel face.
Kit.BODY_FACE = Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.Bold)
Kit.FONT = Enum.Font.Nunito -- the same family as an enum, for code that sets `.Font`
Kit.FONT_PIXEL = Enum.Font.Arcade

local PIXEL_SHRINK = 0.85 -- the pixel face is wide: a title is set smaller to fill the same space

function Kit.round(instance: Instance, radius: number)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = instance
end

function Kit.border(instance: Instance, thickness: number, colour: Color3?): UIStroke
	local stroke = Instance.new("UIStroke")
	stroke.Color = colour or Kit.COLOURS.outline
	stroke.Thickness = thickness
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = instance
	return stroke
end

-- Text that sits straight on the world, not in a box, is white with a dark edge.
function Kit.overWorld(label: TextLabel)
	label.TextColor3 = Kit.COLOURS.white
	label.TextStrokeColor3 = Kit.COLOURS.outline
	label.TextStrokeTransparency = 0
end

-- `safe` keeps everything clear of Roblox's top-bar buttons and a phone's notch: use it for the
-- HUD, the tracker, the battle and every screen with buttons. Full-bleed (the default) is for
-- shades and transitions that cover the whole display.
function Kit.screen(parent: Instance, name: string, order: number, safe: boolean?): ScreenGui
	local gui = Instance.new("ScreenGui")
	gui.Name = name
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	if safe then
		gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
	end
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
	Kit.round(frame, Kit.RADIUS.large)
	Kit.border(frame, Kit.STROKE.normal)
	return frame
end

-- A text label in the body face (sentences). Names, titles and numbers: `Kit.title`/`Kit.pixel`.
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
	label.FontFace = Kit.BODY_FACE
	label.TextScaled = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	local limit = Instance.new("UITextSizeConstraint")
	limit.MaxTextSize = maxTextSize or 22
	limit.MinTextSize = 8
	limit.Parent = label
	return label
end

-- Sets the largest size a label or button's text may grow to.
function Kit.textSize(target: GuiObject, size: number)
	local limit = target:FindFirstChildOfClass("UITextSizeConstraint")
	if limit then
		limit.MaxTextSize = size
	end
end

-- Sets a label in the pixel face at an exact size (a name, a number).
function Kit.pixel(label: TextLabel, size: number)
	label.Font = Kit.FONT_PIXEL
	Kit.textSize(label, size)
end

-- A title, a name or a number: the pixel face, shrunk a little so it fills the same space.
function Kit.title(
	parent: Instance,
	text: string,
	size: UDim2,
	position: UDim2,
	maxTextSize: number?
): TextLabel
	local label = Kit.label(parent, text, size, position, maxTextSize)
	Kit.pixel(label, math.floor((maxTextSize or 22) * PIXEL_SHRINK))
	return label
end

-- Diagonal candy stripes across a coloured surface, a shade lighter and darker than its own
-- colour, so it is not one flat block. For ribbons and headers only, never for a button. One
-- gradient with hard steps: it follows the rounded corners and costs nothing to draw.
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

local function isDark(colour: Color3): boolean
	return colour.R * 0.299 + colour.G * 0.587 + colour.B * 0.114 < 0.72
end

local PRESS_SCALE = 0.96 -- a pressed button squashes to this
local HOVER_SCALE = 1.04 -- on a desktop a hovered button lifts to this
local PRESS_IN = TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local PRESS_OUT = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local HOVER_TWEEN = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Press squash and hover lift for a button, and the lip coming off while it is held. Looks
-- only: it only listens, so the click itself (Activated) is never delayed or swallowed. One
-- tween at a time, so quick taps never stack.
local function addPressMotion(button: TextButton, lip: UIGradient)
	local scale = Instance.new("UIScale")
	scale.Name = "PressScale"
	scale.Parent = button
	local active: Tween? = nil
	local hovering = false
	local function go(goal: number, info: TweenInfo)
		if active then
			active:Cancel()
		end
		local made = TweenService:Create(scale, info, { Scale = goal })
		active = made
		made:Play()
	end
	local function resting(): number
		return if hovering then HOVER_SCALE else 1
	end
	local function isPress(input: InputObject): boolean
		return input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
	end
	button.InputBegan:Connect(function(input: InputObject)
		if isPress(input) then
			lip.Enabled = false -- the press pushes the face down over its lip
			go(PRESS_SCALE, PRESS_IN)
		end
	end)
	button.InputEnded:Connect(function(input: InputObject)
		if isPress(input) then
			lip.Enabled = true
			go(resting(), PRESS_OUT)
		end
	end)
	if not UserInputService.TouchEnabled then
		button.MouseEnter:Connect(function()
			hovering = true
			go(HOVER_SCALE, HOVER_TWEEN)
		end)
		button.MouseLeave:Connect(function()
			hovering = false
			go(1, HOVER_TWEEN)
		end)
	end
	-- A button hidden mid-press must not come back squashed.
	button:GetPropertyChangedSignal("Visible"):Connect(function()
		if not button.Visible then
			if active then
				active:Cancel()
			end
			hovering = false
			scale.Scale = 1
			lip.Enabled = true
		end
	end)
end

-- A flat face with a darker strip along its bottom edge, drawn as one hard-stepped gradient so
-- it follows the corners and any later change of the button's colour.
local function addLip(button: TextButton): UIGradient
	local gradient = Instance.new("UIGradient")
	gradient.Name = "Lip"
	gradient.Rotation = 90 -- top to bottom
	gradient.Parent = button
	local function fit()
		local share = math.clamp(Kit.LIP / math.max(button.AbsoluteSize.Y, 1), 0.02, 0.4)
		local face, edge = Color3.new(1, 1, 1), Color3.new(0.7, 0.7, 0.7)
		gradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, face),
			ColorSequenceKeypoint.new(1 - share - 0.001, face),
			ColorSequenceKeypoint.new(1 - share, edge),
			ColorSequenceKeypoint.new(1, edge),
		})
	end
	fit()
	button:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
	return gradient
end

function Kit.button(parent: Instance, text: string, colour: Color3, onClick: () -> ()): TextButton
	local button = Instance.new("TextButton")
	button.Text = text
	-- Ink letters on a pale face, white on a coloured one.
	button.TextColor3 = if isDark(colour) then Kit.COLOURS.white else Kit.COLOURS.text
	button.Font = Kit.FONT_PIXEL
	button.TextScaled = true
	button.AutoButtonColor = true -- Roblox's own darkening on hover and press
	button.BackgroundColor3 = colour
	button.BorderSizePixel = 0
	button.Parent = parent
	Kit.round(button, Kit.RADIUS.normal)
	Kit.border(button, Kit.STROKE.normal)
	local lip = addLip(button)
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft, pad.PaddingRight = UDim.new(0, 8), UDim.new(0, 8)
	pad.PaddingTop, pad.PaddingBottom = UDim.new(0, 4), UDim.new(0, 4 + Kit.LIP) -- letters clear the lip
	pad.Parent = button
	local limit = Instance.new("UITextSizeConstraint")
	limit.MaxTextSize = 20
	limit.MinTextSize = 7
	limit.Parent = button
	addPressMotion(button, lip)
	button.Activated:Connect(function()
		Sfx.play("press")
		onClick()
	end)
	return button
end

-- A button that cannot be used right now: a solid muted face and dimmed ink (never a see-through
-- one, which shows the world through it). Turning it back on restores its colours.
function Kit.setEnabled(button: TextButton, on: boolean)
	button.Active = on
	button.AutoButtonColor = on
	if on then
		local face = button:GetAttribute("FaceColour")
		local ink = button:GetAttribute("InkColour")
		-- Only if nothing has painted it since it was muted.
		if button.BackgroundColor3 == Kit.COLOURS.muted and typeof(face) == "Color3" then
			button.BackgroundColor3 = face
			if typeof(ink) == "Color3" then
				button.TextColor3 = ink
			end
		end
		button:SetAttribute("FaceColour", nil)
		button:SetAttribute("InkColour", nil)
	else
		if button.BackgroundColor3 ~= Kit.COLOURS.muted then
			button:SetAttribute("FaceColour", button.BackgroundColor3)
			button:SetAttribute("InkColour", button.TextColor3)
		end
		button.BackgroundColor3 = Kit.COLOURS.muted
		button.TextColor3 = Kit.COLOURS.mutedInk
	end
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
	Kit.round(band, Kit.RADIUS.small)
	return band
end

-- The type as a small coloured chip with its icon at the left and its name in the pixel face.
-- The one chip used everywhere a type is shown (battle plates, the starter pick, the cards).
function Kit.typeChip(
	parent: Instance,
	element: Types.Element,
	size: UDim2,
	position: UDim2,
	iconSize: number?
): Frame
	local icon = iconSize or 16
	local chip = Instance.new("Frame")
	chip.Name = "TypeChip"
	chip.Size = size
	chip.Position = position
	chip.BackgroundColor3 = ELEMENT_COLOURS[element]
	chip.BorderSizePixel = 0
	chip.Parent = parent
	Kit.round(chip, Kit.RADIUS.normal)
	Kit.border(chip, Kit.STROKE.thin)
	Icons.type(chip, element, ELEMENT_COLOURS[element], icon, UDim2.new(0, 3, 0.5, -icon / 2))
	local name = Kit.label(
		chip,
		string.upper(element),
		UDim2.new(1, -(icon + 10), 1, -4),
		UDim2.fromOffset(icon + 7, 2),
		14
	)
	name.TextXAlignment = Enum.TextXAlignment.Center
	name.TextColor3 = Kit.COLOURS.white
	Kit.pixel(name, 12)
	return chip
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
	local found = target:FindFirstChild("PopScale")
	local scale: UIScale
	if found and found:IsA("UIScale") then
		scale = found
	else
		scale = Instance.new("UIScale")
		scale.Name = "PopScale"
		scale.Parent = target
	end
	scale.Scale = 0.94
	local settle = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(scale, settle, { Scale = 1 }):Play()
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
	Kit.round(back, Kit.RADIUS.small)
	Kit.border(back, Kit.STROKE.thin)
	local function strip(stripColour: Color3, order: number): Frame
		local made = Instance.new("Frame")
		made.Size = UDim2.fromScale(1, 1)
		made.BackgroundColor3 = stripColour
		made.BorderSizePixel = 0
		made.ZIndex = order
		made.Parent = back
		Kit.round(made, Kit.RADIUS.small)
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
