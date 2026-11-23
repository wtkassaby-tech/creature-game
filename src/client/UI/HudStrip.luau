--!strict
-- The one strip along the top right of the world screen: an icon and a number for each
-- currency (coins, Prism), then the Creatures and Journal buttons, all the same height and
-- all inside the strip. Screens add to it through here, so there is one strip, not two bars.
-- The strip is hidden while the battle screen is open. It sits in the safe area, clear of
-- Roblox's own buttons. Looks only.

local Kit = require(script.Parent.Kit)

local HudStrip = {}

local BUTTON_SIZE = UDim2.fromOffset(112, 40) -- the same for every button in the strip
local ICON = 22

export type Strip = { gui: ScreenGui, strip: Frame }

local made: Strip? = nil

function HudStrip.get(playerGui: Instance): Strip
	if made then
		return made
	end
	local gui = Kit.screen(playerGui, "Hud", 2, true)
	gui.Enabled = true
	local strip = Kit.panel(gui, UDim2.fromOffset(0, 54), UDim2.new(1, -Kit.SPACE.wide, 0, 10))
	strip.AnchorPoint = Vector2.new(1, 0)
	strip.AutomaticSize = Enum.AutomaticSize.X
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, Kit.SPACE.normal)
	layout.Parent = strip
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft, pad.PaddingRight = UDim.new(0, 10), UDim.new(0, 8)
	pad.Parent = strip
	local built: Strip = { gui = gui, strip = strip }
	made = built
	-- Hidden while the battle screen is up (it has its own plates).
	task.spawn(function()
		local battle = playerGui:WaitForChild("Battle")
		if not battle:IsA("ScreenGui") then
			return
		end
		local function follow()
			gui.Enabled = not battle.Enabled
		end
		battle:GetPropertyChangedSignal("Enabled"):Connect(follow)
		follow()
	end)
	return built
end

-- An icon with a number beside it, in the pixel face. Returns the number's label.
function HudStrip.currency(
	strip: Frame,
	draw: (parent: Instance, size: number, position: UDim2?) -> Frame,
	order: number
): TextLabel
	local cell = Instance.new("Frame")
	cell.Size = UDim2.fromOffset(96, 40)
	cell.BackgroundTransparency = 1
	cell.LayoutOrder = order
	cell.Parent = strip
	draw(cell, ICON, UDim2.new(0, 0, 0.5, -ICON / 2))
	local value =
		Kit.label(cell, "0", UDim2.new(1, -(ICON + 6), 1, -4), UDim2.fromOffset(ICON + 6, 2), 16)
	Kit.pixel(value, 16)
	return value
end

-- A button for the strip with its own icon at the left.
function HudStrip.button(
	strip: Frame,
	text: string,
	colour: Color3,
	draw: (parent: Instance, size: number, position: UDim2?) -> Frame,
	order: number,
	onClick: () -> ()
): TextButton
	local button = Kit.button(strip, text, colour, onClick)
	button.Size = BUTTON_SIZE
	button.LayoutOrder = order
	-- The padding makes room for the icon at the left of the words, but a UIPadding also moves
	-- the button's other children, so the icon is placed back by the same amount (seen in Studio,
	-- 23 November 2026: the icon sat on top of the label).
	local pad: UIPadding = button:FindFirstChildOfClass("UIPadding") or Instance.new("UIPadding")
	pad.Parent = button
	pad.PaddingLeft = UDim.new(0, ICON + 10)
	pad.PaddingRight = UDim.new(0, 6)
	draw(button, ICON - 2, UDim2.new(0, 5 - (ICON + 10), 0.5, -(ICON - 2) / 2 - 2))
	return button
end

return HudStrip
