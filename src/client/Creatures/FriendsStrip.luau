--!strict
-- The "Greenwood friends N of 8" strip: a small picture per Greenwood species, dark with a "?"
-- until the player owns that species, then in full colour. Each is built once and swapped once,
-- never rebuilt, so a state update costs nothing here but a string.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Kit = require(script.Parent.Parent.UI.Kit)
local Portrait = require(script.Parent.Portrait)
local Snapshot = require(ReplicatedStorage.shared.Snapshot)
local Species = require(ReplicatedStorage.content.Species)
local Tracker = require(ReplicatedStorage.shared.Tracker)

local FriendsStrip = {}

type FriendSlot = { cell: Frame, window: ViewportFrame?, mark: TextLabel, shown: boolean }

export type Strip = { frame: Frame, update: (state: Snapshot.State) -> () }

function FriendsStrip.new(parent: Instance, order: number): Strip
	local made = Kit.panel(parent, UDim2.new(1, 0, 0, 48), UDim2.new(), Kit.COLOURS.panelLight)
	made.LayoutOrder = order
	made.Name = "FriendsStrip"
	local text = Kit.label(made, "", UDim2.new(0, 160, 1, -8), UDim2.fromOffset(10, 4), 18)
	text.TextWrapped = true
	Kit.pixel(text, 16)
	local cells = Instance.new("Frame")
	cells.Size = UDim2.new(1, -184, 1, -8)
	cells.Position = UDim2.fromOffset(174, 4)
	cells.BackgroundTransparency = 1
	cells.Parent = made
	local across = Instance.new("UIListLayout")
	across.FillDirection = Enum.FillDirection.Horizontal
	across.VerticalAlignment = Enum.VerticalAlignment.Center
	across.Padding = UDim.new(0, 5)
	across.SortOrder = Enum.SortOrder.LayoutOrder
	across.Parent = cells

	local slots: { [string]: FriendSlot } = {}
	for index, species in Tracker.GREENWOOD do
		local def = Species[species]
		if not def then
			continue
		end
		local cell = Instance.new("Frame")
		cell.Size = UDim2.fromOffset(36, 36)
		cell.BackgroundTransparency = 1
		cell.LayoutOrder = index
		cell.Parent = cells
		local window =
			Portrait.new(cell, species, def.element, UDim2.fromScale(1, 1), UDim2.new(), true)
		local mark = Kit.label(cell, "?", UDim2.fromScale(1, 1), UDim2.new(), 24)
		mark.TextXAlignment = Enum.TextXAlignment.Center
		Kit.overWorld(mark)
		mark.ZIndex = 2
		slots[species] = { cell = cell, window = window, mark = mark, shown = false }
	end

	return {
		frame = made,
		update = function(state: Snapshot.State)
			local owned: { string } = {}
			for _, view in state.Creatures do
				table.insert(owned, view.Torso.Species)
			end
			text.Text = `Greenwood friends {Tracker.countFriends(owned)} of {#Tracker.GREENWOOD}`
			for _, species in owned do
				local slot = slots[species]
				local def = Species[species]
				if slot and def and not slot.shown then
					slot.shown = true
					if slot.window then
						slot.window:Destroy()
					end
					slot.window = Portrait.new(
						slot.cell,
						species,
						def.element,
						UDim2.fromScale(1, 1),
						UDim2.new()
					)
					slot.mark.Visible = false
				end
			end
		end,
	}
end

return FriendsStrip
