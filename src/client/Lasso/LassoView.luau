--!strict
-- The lasso throw on screen: a bar with the target zone, a marker sweeping across it, and one
-- big button to tap. Each tap is sent the moment it happens; the server judges the throw.
-- TODO(art): the brief's lasso is a swinging rope over the creature; this bar is the first cut.
-- Not yet seen in Studio.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Kit = require(script.Parent.Parent.UI.Kit)
local Lasso = require(ReplicatedStorage.shared.Lasso)
local LassoPlayer = require(script.Parent.LassoPlayer)
local Net = require(ReplicatedStorage.net.generated.Client)

local LassoView = {}

export type View = { begin: (wire: LassoPlayer.Wire) -> (), finish: () -> () }

function LassoView.new(parent: Instance): View
	local root = Kit.panel(parent, UDim2.new(0.8, 0, 0, 150), UDim2.new(0.1, 0, 0.32, 0))
	root.Visible = false
	local title = Kit.label(root, "", UDim2.new(1, -24, 0, 30), UDim2.new(0, 12, 0, 8))
	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(1, -24, 0, 30)
	bar.Position = UDim2.new(0, 12, 0, 44)
	bar.BackgroundColor3 = Color3.fromRGB(20, 26, 30)
	bar.BorderSizePixel = 0
	bar.Parent = root
	local zoneBox = Instance.new("Frame")
	zoneBox.BackgroundColor3 = Kit.COLOURS.good
	zoneBox.BorderSizePixel = 0
	zoneBox.Parent = bar
	local marker = Instance.new("Frame")
	marker.Size = UDim2.new(0, 6, 1, 8)
	marker.BackgroundColor3 = Kit.COLOURS.text
	marker.BorderSizePixel = 0
	marker.Parent = bar

	local playing: LassoPlayer.Playing? = nil
	local function tap()
		local current = playing
		if not current then
			return
		end
		local message = LassoPlayer.tap(current)
		if message then
			Net.LassoTap.Fire(message)
		end
	end
	local button = Kit.button(root, "THROW!", Kit.COLOURS.lasso, tap)
	button.Size = UDim2.new(1, -24, 0, 54)
	button.Position = UDim2.new(0, 12, 0, 86)

	RunService.RenderStepped:Connect(function()
		local current = playing
		if not current then
			return
		end
		local position, zone = LassoPlayer.marker(current)
		if position == nil or zone == nil then
			title.Text = "Thrown..."
			zoneBox.Visible, marker.Visible = false, false
			return
		end
		local count = #current.pattern.zones
		local sweeping = LassoPlayer.elapsedMs(current) >= zone.startMs
		title.Text = if count > 1
			then `Loop {current.zone} of {count}: tap in the green`
			else "Tap when the marker is in the green"
		zoneBox.Visible, marker.Visible = true, sweeping
		zoneBox.Position = UDim2.fromScale(zone.centre - zone.width / 2, 0)
		zoneBox.Size = UDim2.fromScale(zone.width, 1)
		marker.Position = UDim2.new(position, -3, 0, -4)
		marker.BackgroundColor3 = if Lasso.isInZone(zone, position)
			then Kit.COLOURS.warn
			else Kit.COLOURS.text
	end)

	return {
		begin = function(wire: LassoPlayer.Wire)
			playing = LassoPlayer.begin(wire)
			root.Visible = true
		end,
		finish = function()
			playing = nil
			root.Visible = false
		end,
	}
end

return LassoView
