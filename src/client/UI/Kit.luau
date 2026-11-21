--!strict
-- Small building blocks for the screens: chunky rounded panels, big buttons that suit a phone,
-- labels and bars, all in flat colours (brief section 12). Every screen is built from these so
-- the look can change in one place.
-- TODO(art): colours, font and corner sizes are first guesses, not yet seen in Studio.

local TweenService = game:GetService("TweenService")

local Kit = {}

Kit.COLOURS = {
	panel = Color3.fromRGB(38, 50, 56),
	panelLight = Color3.fromRGB(55, 71, 79),
	text = Color3.fromRGB(255, 255, 255),
	textDim = Color3.fromRGB(190, 205, 210),
	good = Color3.fromRGB(102, 187, 106),
	warn = Color3.fromRGB(255, 202, 40),
	bad = Color3.fromRGB(239, 83, 80),
	accent = Color3.fromRGB(66, 165, 245),
	lasso = Color3.fromRGB(255, 167, 38),
	tempo = Color3.fromRGB(171, 71, 188),
}

Kit.FONT = Enum.Font.FredokaOne

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
	frame.BorderSizePixel = 0
	frame.Parent = parent
	round(frame, 14)
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
	return label
end

function Kit.button(parent: Instance, text: string, colour: Color3, onClick: () -> ()): TextButton
	local button = Instance.new("TextButton")
	button.Text = text
	button.TextColor3 = Kit.COLOURS.text
	button.Font = Kit.FONT
	button.TextScaled = true
	button.AutoButtonColor = true
	button.BackgroundColor3 = colour
	button.BorderSizePixel = 0
	button.Parent = parent
	round(button, 12)
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft, pad.PaddingRight = UDim.new(0, 8), UDim.new(0, 8)
	pad.PaddingTop, pad.PaddingBottom = UDim.new(0, 6), UDim.new(0, 6)
	pad.Parent = button
	local limit = Instance.new("UITextSizeConstraint")
	limit.MaxTextSize = 22
	limit.MinTextSize = 8
	limit.Parent = button
	button.Activated:Connect(onClick)
	return button
end

export type Bar = { set: (share: number, colour: Color3?) -> (), frame: Frame }

-- A bar that fills from the left. `set` takes a share from 0 to 1.
function Kit.bar(parent: Instance, size: UDim2, position: UDim2, colour: Color3): Bar
	local back = Instance.new("Frame")
	back.Size = size
	back.Position = position
	back.BackgroundColor3 = Color3.fromRGB(20, 26, 30)
	back.BorderSizePixel = 0
	back.Parent = parent
	round(back, 6)
	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(1, 1)
	fill.BackgroundColor3 = colour
	fill.BorderSizePixel = 0
	fill.Parent = back
	round(fill, 6)
	return {
		frame = back,
		set = function(share: number, newColour: Color3?)
			local clamped = if share ~= share then 0 else math.clamp(share, 0, 1)
			TweenService:Create(
				fill,
				TweenInfo.new(0.25, Enum.EasingStyle.Quad),
				{ Size = UDim2.fromScale(clamped, 1) }
			):Play()
			if newColour then
				fill.BackgroundColor3 = newColour
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
