--!strict
-- The lasso throw on screen: a length of rope with a green stretch on it, a loop sliding along
-- the rope, and one big button to tap. Each tap is sent the moment it happens; the server judges
-- the throw, and nothing drawn here changes that. It sits along the bottom of the screen, over
-- the battle's text box and menu, so both creatures stay in view while the player throws.
-- TODO(art): the brief's lasso is a swinging rope over the creature itself; this is the 2D cut.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Coach = require(ReplicatedStorage.shared.Coach)
local Kit = require(script.Parent.Parent.UI.Kit)
local Lasso = require(ReplicatedStorage.shared.Lasso)
local LassoPlayer = require(script.Parent.LassoPlayer)
local Net = require(ReplicatedStorage.net.generated.Client)
local Sfx = require(script.Parent.Parent.Audio.Sfx)

local LassoView = {}

export type View = { begin: (wire: LassoPlayer.Wire) -> (), finish: () -> () }

local ROPE = Color3.fromRGB(202, 158, 98)
local LOOP = 30 -- the sliding loop, in pixels across
local LOOP_OVER_GREEN = 38 -- it swells while a tap would land
local PANEL_TALL = 148

local function round(parent: Instance, radius: UDim)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = radius
	corner.Parent = parent
end

local function edge(parent: Instance, colour: Color3, thickness: number): UIStroke
	local line = Instance.new("UIStroke")
	line.Color = colour
	line.Thickness = thickness
	line.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	line.Parent = parent
	return line
end

function LassoView.new(parent: Instance): View
	local root = Kit.panel(
		parent,
		UDim2.new(0.94, 0, 0, PANEL_TALL),
		UDim2.new(0.03, 0, 1, -(PANEL_TALL + 8))
	)
	root.Visible = false
	root.ZIndex = 7
	local title = Kit.label(root, "", UDim2.new(0.7, -24, 0, 26), UDim2.fromOffset(12, 5))
	title.ZIndex = 8
	-- A hint that is true of every throw: weaker creatures leave more green.
	local note = Kit.label(
		root,
		Coach.LINES.wideGreen,
		UDim2.new(0.3, -12, 0, 26),
		UDim2.new(0.7, 0, 0, 5),
		15
	)
	note.TextColor3 = Kit.COLOURS.textDim
	note.TextXAlignment = Enum.TextXAlignment.Right
	note.ZIndex = 8

	-- The rope: a tan strip with a twist of lighter and darker bands and an ink edge.
	local rope = Instance.new("Frame")
	rope.Size = UDim2.new(1, -40, 0, 24)
	rope.Position = UDim2.fromOffset(20, 42)
	rope.BackgroundColor3 = ROPE
	rope.BorderSizePixel = 0
	rope.ZIndex = 8
	rope.Parent = root
	round(rope, UDim.new(0.5, 0))
	edge(rope, Kit.COLOURS.outline, 3)
	Kit.stripes(rope)
	-- The green stretch: where a tap lands.
	local zoneBox = Instance.new("Frame")
	zoneBox.BackgroundColor3 = Kit.COLOURS.good
	zoneBox.BorderSizePixel = 0
	zoneBox.ZIndex = 9
	zoneBox.Parent = rope
	round(zoneBox, UDim.new(0.5, 0))
	edge(zoneBox, Kit.COLOURS.white, 2)
	-- The loop: a ring that slides along the rope.
	local loop = Instance.new("Frame")
	loop.AnchorPoint = Vector2.new(0.5, 0.5)
	loop.Size = UDim2.fromOffset(LOOP, LOOP)
	loop.BackgroundColor3 = Kit.COLOURS.panel
	loop.BackgroundTransparency = 0.55
	loop.BorderSizePixel = 0
	loop.ZIndex = 11
	loop.Parent = rope
	round(loop, UDim.new(0.5, 0))
	local loopEdge = edge(loop, Kit.COLOURS.outline, 5)

	-- Where each tap fell stays marked on the rope until the next throw.
	local stamps: { Frame } = {}
	local function stamp(at: number, good: boolean)
		local mark = Instance.new("Frame")
		mark.AnchorPoint = Vector2.new(0.5, 0.5)
		mark.Size = UDim2.fromOffset(16, 16)
		mark.Position = UDim2.fromScale(at, 0.5)
		mark.BackgroundColor3 = if good then Kit.COLOURS.white else Kit.COLOURS.bad
		mark.BorderSizePixel = 0
		mark.ZIndex = 10
		mark.Parent = rope
		round(mark, UDim.new(0.5, 0))
		edge(mark, Kit.COLOURS.outline, 3)
		table.insert(stamps, mark)
	end
	local function clearStamps()
		for _, mark in stamps do
			mark:Destroy()
		end
		table.clear(stamps)
	end

	local playing: LassoPlayer.Playing? = nil
	local function tap()
		local current = playing
		if not current then
			return
		end
		-- Where the loop is now, before the tap moves on to the next stretch.
		local position, zone = LassoPlayer.marker(current)
		local message = LassoPlayer.tap(current)
		if message then
			Net.LassoTap.Fire(message)
			if position and zone then
				local good = Lasso.isInZone(zone, position)
				stamp(position, good)
				Sfx.play(if good then "confirm" else "weakHit")
			end
		end
	end
	local button = Kit.button(root, "THROW!", Kit.COLOURS.lasso, tap)
	button.Size = UDim2.new(1, -24, 0, 56)
	button.Position = UDim2.fromOffset(12, PANEL_TALL - 66)
	button.ZIndex = 8

	RunService.RenderStepped:Connect(function()
		local current = playing
		if not current then
			return
		end
		local position, zone = LassoPlayer.marker(current)
		if position == nil or zone == nil then
			title.Text = "Thrown..."
			zoneBox.Visible, loop.Visible = false, false
			return
		end
		local count = #current.pattern.zones
		local sweeping = LassoPlayer.elapsedMs(current) >= zone.startMs
		title.Text = if count > 1
			then `Loop {current.zone} of {count}: tap when it is over the green`
			else "Tap THROW when the loop is over the green"
		zoneBox.Visible, loop.Visible = true, sweeping
		zoneBox.Position = UDim2.fromScale(zone.centre - zone.width / 2, 0)
		zoneBox.Size = UDim2.fromScale(zone.width, 1)
		local over = Lasso.isInZone(zone, position)
		local across = if over then LOOP_OVER_GREEN else LOOP
		loop.Position = UDim2.fromScale(position, 0.5)
		loop.Size = UDim2.fromOffset(across, across)
		loopEdge.Color = if over then Kit.COLOURS.warn else Kit.COLOURS.outline
	end)

	return {
		begin = function(wire: LassoPlayer.Wire)
			clearStamps()
			playing = LassoPlayer.begin(wire)
			root.Visible = true
		end,
		finish = function()
			playing = nil
			root.Visible = false
			clearStamps()
		end,
	}
end

return LassoView
