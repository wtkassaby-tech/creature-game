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
	local name = Kit.label(button, "", UDim2.fromScale(1, 0.54), UDim2.new(), 22)
	name.TextXAlignment = Enum.TextXAlignment.Center
	name.TextStrokeColor3 = Kit.COLOURS.outline
	name.TextStrokeTransparency = 0.4
	-- The small print sits on a darker band set into the button: a cream chip naming the
	-- type, the damage, and STRONG or WEAK.
	local band = Kit.inset(button, UDim2.fromScale(1, 0.42), UDim2.fromScale(0, 0.58))
	local chip = Kit.label(band, "", UDim2.new(0.3, 0, 1, -6), UDim2.fromOffset(4, 3), 14)
	chip.TextXAlignment = Enum.TextXAlignment.Center
	chip.BackgroundTransparency = 0
	chip.BackgroundColor3 = Kit.COLOURS.panel
	local chipCorner = Instance.new("UICorner")
	chipCorner.CornerRadius = UDim.new(0.5, 0)
	chipCorner.Parent = chip
	local info = Kit.label(band, "", UDim2.new(0.34, -8, 1, -4), UDim2.new(0.3, 12, 0, 2), 16)
	local hint = Kit.label(band, "", UDim2.new(0.36, -8, 1, -4), UDim2.new(0.64, 0, 0, 2), 16)
	hint.TextXAlignment = Enum.TextXAlignment.Right
	-- On a coloured button the words are white; the hint is set in the pixel face.
	name.TextColor3, info.TextColor3 = Kit.COLOURS.white, Kit.COLOURS.white
	Kit.pixel(name, 18)
	Kit.pixel(hint, 13)

	return {
		button = button,
		show = function(move: string?, preview: number?, foe: Types.Element?, open: boolean)
			button.Visible = move ~= nil
			button.Active = open
			local faded = if open then 0 else 0.5
			button.BackgroundTransparency = faded
			name.TextTransparency, info.TextTransparency, hint.TextTransparency =
				faded, faded, faded
			chip.TextTransparency, chip.BackgroundTransparency = faded, faded
			if not move then
				return
			end
			local def = Moves[move]
			name.Text = move
			button.BackgroundColor3 = if def
				then Kit.ELEMENT_COLOURS[def.element]
				else Kit.COLOURS.accent
			local damage = if preview then `{preview} dmg` else ""
			chip.Text = if def then def.element else ""
			chip.Visible = def ~= nil
			info.Text = damage
			local factor = if def and foe then TypeChart.multiplier(def.element, foe) else 1
			if factor > 1 then
				hint.Text, hint.TextColor3 = "STRONG", Color3.fromRGB(255, 240, 150)
			elseif factor < 1 then
				hint.Text, hint.TextColor3 = "WEAK", Color3.fromRGB(226, 226, 232)
			else
				hint.Text = ""
			end
		end,
	}
end

return MoveButton
