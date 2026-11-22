--!strict
-- The starter pick: three cards, each with the creature, its name, its type and one line of
-- character. Tapping a card only selects it (yellow border, the others dim, a short cry); the
-- choice is sent when the player confirms with "Pick this one?". The server decides the rest.
-- Sized for a phone held sideways (874 by 402 points): every button is at least 44 px tall.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Portrait = require(script.Parent.Parent.Creatures.Portrait)
local Sfx = require(script.Parent.Parent.Audio.Sfx)
local Kit = require(script.Parent.Parent.UI.Kit)
local Net = require(ReplicatedStorage.net.generated.Client)
local Species = require(ReplicatedStorage.content.Species)
local SpeciesBlurbs = require(ReplicatedStorage.content.SpeciesBlurbs)
local Tracker = require(ReplicatedStorage.shared.Tracker)
local WorldTypes = require(ReplicatedStorage.shared.WorldTypes)

local StarterPick = {}

local SELECTED = Color3.fromRGB(255, 217, 102) -- #FFD966
local RESEND_AFTER = 3 -- seconds before a second confirm is allowed, in case the server said no

export type Pick = { show: () -> (), hide: () -> (), chosen: () -> string? }

local function stroke(parent: Instance, colour: Color3, thickness: number): UIStroke
	local line = Instance.new("UIStroke")
	line.Color = colour
	line.Thickness = thickness
	line.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	line.Parent = parent
	return line
end

local function rounded(parent: Instance, radius: number)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = parent
end

function StarterPick.new(playerGui: Instance, startBeat: WorldTypes.Beat?): Pick
	local gui = Kit.screen(playerGui, "StarterPick", 30)
	-- The world dims behind the choice, so nothing else on screen asks for attention.
	local shade = Instance.new("Frame")
	shade.Size = UDim2.fromScale(1, 1)
	shade.BackgroundColor3 = Kit.COLOURS.outline
	shade.BackgroundTransparency = 0.4
	shade.BorderSizePixel = 0
	shade.Active = true -- taps do not fall through to the buttons underneath
	shade.Parent = gui
	local box = Kit.panel(gui, UDim2.fromScale(0.92, 0.9), UDim2.fromScale(0.04, 0.05))
	local title =
		Kit.label(box, "Pick a friend", UDim2.new(1, -28, 0, 32), UDim2.fromOffset(14, 8), 28)
	title.TextXAlignment = Enum.TextXAlignment.Center

	-- The cards take everything between the title and the button row.
	local cards = Instance.new("Frame")
	cards.Size = UDim2.new(1, -28, 1, -112)
	cards.Position = UDim2.fromOffset(14, 46)
	cards.BackgroundTransparency = 1
	cards.Parent = box
	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.new(0.333, -8, 1, 0)
	grid.CellPadding = UDim2.fromOffset(12, 0)
	grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
	grid.Parent = cards

	local choices: { string } = {}
	if startBeat then
		for _, reward in startBeat.grants do
			if reward.kind == "Starter" then
				for _, species in reward.choices do
					table.insert(choices, species)
				end
			end
		end
	end

	local selected: string? = nil
	local lastSent = -RESEND_AFTER
	local refreshCards: () -> () = function() end

	-- The two buttons under the cards, shown only while a card is selected.
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -28, 0, 52)
	row.Position = UDim2.new(0, 14, 1, -60)
	row.BackgroundTransparency = 1
	row.Visible = false
	row.Parent = box
	-- Until a card is tapped, the same strip says what to do.
	local hint = Kit.label(
		box,
		"Tap a friend to meet them.",
		UDim2.new(1, -28, 0, 52),
		UDim2.new(0, 14, 1, -60),
		18
	)
	hint.TextXAlignment = Enum.TextXAlignment.Center
	hint.TextColor3 = Kit.COLOURS.textDim
	local rowLayout = Instance.new("UIListLayout")
	rowLayout.FillDirection = Enum.FillDirection.Horizontal
	rowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	rowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	rowLayout.Padding = UDim.new(0, 16)
	rowLayout.Parent = row
	local confirm = Kit.button(row, "Pick this one?", Kit.COLOURS.good, function()
		local now = os.clock()
		if now - lastSent < RESEND_AFTER then
			return
		end
		if startBeat and selected and Tracker.pickAllowed(selected, choices) then
			lastSent = now
			Net.CompleteBeat.Fire({ BeatId = startBeat.id, Choice = selected })
		end
	end)
	confirm.Size = UDim2.fromOffset(270, 52)
	local back = Kit.button(row, "Not yet", Kit.COLOURS.panel, function()
		selected = nil
		refreshCards()
	end)
	back.Size = UDim2.fromOffset(150, 52)

	local cardFor: { [string]: { card: TextButton, outline: UIStroke, dim: Frame } } = {}
	for _, species in choices do
		local def = Species[species]
		local card = Instance.new("TextButton")
		card.Text = ""
		card.AutoButtonColor = false
		card.BackgroundColor3 = Kit.COLOURS.panelLight
		card.BorderSizePixel = 0
		card.Parent = cards
		rounded(card, 8)
		local outline = stroke(card, Kit.COLOURS.outline, 3)

		if def then
			-- A stripe of the type's colour behind the creature, so the types are learned by colour.
			local band = Instance.new("Frame")
			band.Size = UDim2.fromScale(1, 0.58)
			band.BackgroundColor3 = Kit.ELEMENT_COLOURS[def.element]
			band.BackgroundTransparency = 0.2
			band.BorderSizePixel = 0
			band.Parent = card
			rounded(band, 8)
			Portrait.new(card, species, def.element, UDim2.fromScale(1, 0.58), UDim2.new())
		end
		local name =
			Kit.label(card, species, UDim2.new(1, -12, 0.12, 0), UDim2.new(0, 6, 0.6, 0), 40)
		name.TextXAlignment = Enum.TextXAlignment.Center
		if def then
			-- The type as a little coloured tag, the same colour as the band and the move buttons.
			local tag = Instance.new("Frame")
			tag.AnchorPoint = Vector2.new(0.5, 0)
			tag.Size = UDim2.fromScale(0.36, 0.07)
			tag.Position = UDim2.fromScale(0.5, 0.735)
			tag.BackgroundColor3 = Kit.ELEMENT_COLOURS[def.element]
			tag.BorderSizePixel = 0
			tag.Parent = card
			rounded(tag, 6)
			stroke(tag, Kit.COLOURS.outline, 2)
			local kind =
				Kit.label(tag, string.upper(def.element), UDim2.fromScale(1, 1), UDim2.new(), 20)
			kind.TextXAlignment = Enum.TextXAlignment.Center
			kind.TextColor3 = Color3.new(1, 1, 1)
		end
		local blurb = Kit.label(
			card,
			SpeciesBlurbs[species] or "",
			UDim2.new(1, -20, 0.15, 0),
			UDim2.new(0, 10, 0.84, 0),
			22
		)
		blurb.TextWrapped = true
		blurb.TextXAlignment = Enum.TextXAlignment.Center
		blurb.TextYAlignment = Enum.TextYAlignment.Top

		-- A soft ink film laid over the cards that were not chosen.
		local dim = Instance.new("Frame")
		dim.Size = UDim2.fromScale(1, 1)
		dim.BackgroundColor3 = Kit.COLOURS.outline
		dim.BackgroundTransparency = 0.78
		dim.BorderSizePixel = 0
		dim.Visible = false
		dim.ZIndex = 10
		dim.Active = false
		dim.Parent = card
		rounded(dim, 8)

		cardFor[species] = { card = card, outline = outline, dim = dim }
		card.Activated:Connect(function()
			if selected == species then
				return
			end
			selected = species
			Sfx.play("confirm") -- a short cry; the game has no creature sounds yet
			Kit.pop(card)
			refreshCards()
		end)
	end

	refreshCards = function()
		for species, parts in cardFor do
			local mine = selected == species
			parts.outline.Color = if mine then SELECTED else Kit.COLOURS.outline
			parts.outline.Thickness = if mine then 6 else 3
			parts.dim.Visible = selected ~= nil and not mine
		end
		row.Visible = selected ~= nil
		hint.Visible = selected == nil
	end

	return {
		show = function()
			gui.Enabled = true
		end,
		hide = function()
			gui.Enabled = false
		end,
		-- The friend the player confirmed, so the story can greet it by name.
		chosen = function(): string?
			return selected
		end,
	}
end

return StarterPick
