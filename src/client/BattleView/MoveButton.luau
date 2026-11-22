--!strict
-- One move on the battle screen: a button in the colour of the move's type, with the damage it
-- would do now and a word when it is strong or weak against the creature facing you. Players
-- learn the type chart from these buttons. Display only: the damage is the server's own figure.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Kit = require(script.Parent.Parent.UI.Kit)
local Moves = require(ReplicatedStorage.content.Moves)
local TypeChart = require(ReplicatedStorage.shared.TypeChart)
local Types = require(ReplicatedStorage.shared.Types)

local MoveButton = {}

export type View = {
	button: TextButton,
	show: (move: string?, preview: number?, foe: Types.Element?, open: boolean) -> (),
}

function MoveButton.new(parent: Instance, onPick: () -> ()): View
	local button = Kit.button(parent, "", Kit.COLOURS.accent, onPick)
	local name = Kit.label(button, "", UDim2.fromScale(1, 0.56), UDim2.new(), 22)
	name.TextXAlignment = Enum.TextXAlignment.Center
	name.TextStrokeColor3 = Kit.COLOURS.outline
	name.TextStrokeTransparency = 0.35
	local info = Kit.label(button, "", UDim2.fromScale(0.6, 0.4), UDim2.fromScale(0, 0.6), 16)
	info.TextStrokeColor3 = Kit.COLOURS.outline
	info.TextStrokeTransparency = 0.5
	local hint = Kit.label(button, "", UDim2.fromScale(0.4, 0.4), UDim2.fromScale(0.6, 0.6), 16)
	hint.TextXAlignment = Enum.TextXAlignment.Right
	hint.TextStrokeColor3 = Kit.COLOURS.outline
	hint.TextStrokeTransparency = 0.2

	return {
		button = button,
		show = function(move: string?, preview: number?, foe: Types.Element?, open: boolean)
			button.Visible = move ~= nil
			button.Active = open
			local faded = if open then 0 else 0.5
			button.BackgroundTransparency = faded
			name.TextTransparency, info.TextTransparency, hint.TextTransparency =
				faded, faded, faded
			if not move then
				return
			end
			local def = Moves[move]
			name.Text = move
			button.BackgroundColor3 = if def
				then Kit.ELEMENT_COLOURS[def.element]
				else Kit.COLOURS.accent
			local damage = if preview then `{preview} dmg` else ""
			info.Text = if def then `{def.element}  {damage}` else damage
			local factor = if def and foe then TypeChart.multiplier(def.element, foe) else 1
			if factor > 1 then
				hint.Text, hint.TextColor3 = "STRONG", Kit.COLOURS.gold
			elseif factor < 1 then
				hint.Text, hint.TextColor3 = "WEAK", Kit.COLOURS.textDim
			else
				hint.Text = ""
			end
		end,
	}
end

return MoveButton
