--!strict
-- One move on the battle screen: a button in the colour of the move's type, with the damage it
-- would do now and a word when it is strong or weak against the creature facing you. Players
-- learn the type chart from these buttons. Display only: the damage is the server's own figure.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Icons = require(script.Parent.Parent.UI.Icons)
local Kit = require(script.Parent.Parent.UI.Kit)
local Moves = require(ReplicatedStorage.content.Moves)
local TypeChart = require(ReplicatedStorage.shared.TypeChart)
local Types = require(ReplicatedStorage.shared.Types)

local MoveButton = {}

export type View = {
	button: TextButton,
	show: (move: string?, preview: number?, foe: Types.Element?, open: boolean) -> (),
}

local ICON = 16

function MoveButton.new(parent: Instance, onPick: () -> ()): View
	local button = Kit.button(parent, "", Kit.COLOURS.accent, onPick)
	local name = Kit.label(button, "", UDim2.fromScale(1, 0.5), UDim2.new(), 22)
	name.TextXAlignment = Enum.TextXAlignment.Center
	name.TextStrokeColor3 = Kit.COLOURS.outline
	name.TextStrokeTransparency = 0.4
	-- The small print sits on a darker band set into the button: the type's icon, the damage,
	-- and STRONG or WEAK.
	local band = Kit.inset(button, UDim2.new(1, 0, 0.42, -Kit.LIP), UDim2.fromScale(0, 0.5))
	local iconHolder = Instance.new("Frame")
	iconHolder.Size = UDim2.fromOffset(ICON, ICON)
	iconHolder.Position = UDim2.new(0, 5, 0.5, -ICON / 2)
	iconHolder.BackgroundTransparency = 1
	iconHolder.Parent = band
	local info = Kit.label(band, "", UDim2.new(0.4, 0, 1, -4), UDim2.fromOffset(ICON + 10, 2), 16)
	local hint = Kit.label(band, "", UDim2.new(0.4, -8, 1, -4), UDim2.new(0.6, 0, 0, 2), 16)
	hint.TextXAlignment = Enum.TextXAlignment.Right
	-- On a coloured button the words are white; the name, damage and hint are in the pixel face.
	name.TextColor3, info.TextColor3 = Kit.COLOURS.white, Kit.COLOURS.white
	Kit.pixel(name, 18)
	Kit.pixel(info, 13)
	Kit.pixel(hint, 12)
	local shownElement: Types.Element? = nil

	return {
		button = button,
		show = function(move: string?, preview: number?, foe: Types.Element?, open: boolean)
			button.Visible = move ~= nil
			if not move then
				return
			end
			local def = Moves[move]
			name.Text = move
			button.BackgroundColor3 = if def
				then Kit.ELEMENT_COLOURS[def.element]
				else Kit.COLOURS.accent
			if def and def.element ~= shownElement then
				shownElement = def.element
				iconHolder:ClearAllChildren()
				Icons.type(iconHolder, def.element, Kit.ELEMENT_COLOURS[def.element], ICON)
			end
			iconHolder.Visible = def ~= nil
			info.Text = if preview then `{preview} dmg` else ""
			local factor = if def and foe then TypeChart.multiplier(def.element, foe) else 1
			if factor > 1 then
				hint.Text, hint.TextColor3 = "STRONG", Color3.fromRGB(255, 240, 150)
			elseif factor < 1 then
				hint.Text, hint.TextColor3 = "WEAK", Color3.fromRGB(226, 226, 232)
			else
				hint.Text = ""
			end
			-- Not your turn: a solid muted face and dimmed ink, not a see-through button.
			Kit.setEnabled(button, open)
			local ink = if open then Kit.COLOURS.white else Kit.COLOURS.mutedInk
			name.TextColor3, info.TextColor3 = ink, ink
			name.TextStrokeTransparency = if open then 0.4 else 1
			if not open then
				hint.TextColor3 = Kit.COLOURS.mutedInk
			end
			band.BackgroundTransparency = if open then 0.55 else 0.8
			iconHolder.Visible = def ~= nil and open
		end,
	}
end

return MoveButton
