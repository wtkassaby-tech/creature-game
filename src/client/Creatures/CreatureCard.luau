--!strict
-- One creature as a card on the Creatures screen. Two sizes: a large "team" card (portrait, name,
-- level, type tag, health bar, position in the team) and a small "box" card for the stable (portrait,
-- name, level, health bar). Each card builds its live portrait once; `refresh` only touches the
-- text and bar, and does nothing at all when what the card shows has not changed.
-- Looks only: tapping a card tells the screen which creature was picked.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Kit = require(script.Parent.Parent.UI.Kit)
local Portrait = require(script.Parent.Portrait)
local Snapshot = require(ReplicatedStorage.shared.Snapshot)
local Species = require(ReplicatedStorage.content.Species)
local Types = require(ReplicatedStorage.shared.Types)

local CreatureCard = {}

export type Kind = "team" | "box"

export type Card = {
	id: string,
	kind: Kind,
	frame: TextButton,
	refresh: (view: Snapshot.CreatureView, position: number?, isParent: boolean) -> (),
	setSelected: (on: boolean) -> (),
	destroy: () -> (),
}

CreatureCard.SELECTED = Color3.fromRGB(255, 217, 102) -- #FFD966, as on the starter pick
CreatureCard.BOX_SIZE = Vector2.new(124, 76) -- the stable grid's cell, in pixels

local PARENT_TINT = Color3.fromRGB(206, 232, 192) -- a creature picked for breeding
local FAINT_TINT = Color3.fromRGB(240, 205, 196)

-- Rarity by name colour. Darker than the over-world colours, so they read on cream.
local RARITY_COLOURS: { [string]: Color3 } = {
	Common = Kit.COLOURS.text,
	Uncommon = Color3.fromRGB(40, 132, 56),
	Gem = Color3.fromRGB(36, 100, 200),
	Ruby = Color3.fromRGB(196, 36, 56),
	Diamond = Color3.fromRGB(20, 146, 168),
	Cosmic = Color3.fromRGB(128, 56, 196),
}

function CreatureCard.rarityColour(rarity: string): Color3
	return RARITY_COLOURS[rarity] or Kit.COLOURS.text
end

function CreatureCard.healthShare(view: Snapshot.CreatureView): number
	return math.clamp(1 - view.Hurt, 0, 1)
end

function CreatureCard.healthText(view: Snapshot.CreatureView): string
	if view.Hurt >= 1 then
		return "fainted"
	end
	return `{math.floor((1 - view.Hurt) * 100 + 0.5)}% health`
end

function CreatureCard.rounded(parent: Instance, radius: number)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = parent
end

function CreatureCard.stroke(parent: Instance, colour: Color3, thickness: number): UIStroke
	local line = Instance.new("UIStroke")
	line.Color = colour
	line.Thickness = thickness
	line.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	line.Parent = parent
	return line
end

-- The type as a little coloured tag, the same colour as everywhere else a type is shown.
function CreatureCard.typeTag(
	parent: Instance,
	element: Types.Element,
	size: UDim2,
	position: UDim2
): Frame
	return Kit.typeChip(parent, element, size, position, 14)
end

-- A stripe of the type's colour behind a portrait, so the types are learned by colour.
function CreatureCard.band(
	parent: Instance,
	element: Types.Element,
	size: UDim2,
	position: UDim2
): Frame
	local band = Instance.new("Frame")
	band.Size = size
	band.Position = position
	band.BackgroundColor3 = Kit.ELEMENT_COLOURS[element]
	band.BackgroundTransparency = 0.2
	band.BorderSizePixel = 0
	band.Parent = parent
	CreatureCard.rounded(band, 6)
	CreatureCard.stroke(band, Kit.COLOURS.outline, 2)
	return band
end

function CreatureCard.new(
	parent: Instance,
	kind: Kind,
	view: Snapshot.CreatureView,
	onTap: (id: string) -> ()
): Card
	local id = view.Id
	local species = view.Torso.Species
	local def = Species[species]
	local isTeam = kind == "team"

	local frame = Instance.new("TextButton")
	frame.Text = ""
	frame.AutoButtonColor = false
	frame.BackgroundColor3 = Kit.COLOURS.panelLight
	frame.BorderSizePixel = 0
	frame.Parent = parent
	CreatureCard.rounded(frame, 8)
	local outline = CreatureCard.stroke(frame, Kit.COLOURS.outline, 3)

	local pictureSize = if isTeam then UDim2.new(1, -8, 0.48, 0) else UDim2.fromOffset(48, 48)
	local picturePos = if isTeam then UDim2.fromOffset(4, 4) else UDim2.fromOffset(6, 24)
	if def then
		CreatureCard.band(frame, def.element, pictureSize, picturePos)
		Portrait.new(frame, species, def.element, pictureSize, picturePos)
	end

	local name: TextLabel
	local level: TextLabel
	local bar: Kit.Bar
	local position: TextLabel? = nil
	if isTeam then
		name = Kit.title(frame, species, UDim2.new(1, -8, 0.17, 0), UDim2.new(0, 4, 0.52, 0), 40)
		name.TextXAlignment = Enum.TextXAlignment.Center
		level = Kit.label(frame, "", UDim2.fromScale(0.36, 0.16), UDim2.new(0, 6, 0.7, 0), 20)
		if def then
			CreatureCard.typeTag(
				frame,
				def.element,
				UDim2.fromScale(0.5, 0.15),
				UDim2.fromScale(0.46, 0.705)
			)
		end
		bar = Kit.bar(frame, UDim2.new(1, -16, 0.07, 0), UDim2.new(0, 8, 0.89, 0), Kit.COLOURS.good)
		-- Its place in the team, on a small ink disc in the corner of the picture.
		local disc = Instance.new("Frame")
		disc.Size = UDim2.fromOffset(22, 22)
		disc.Position = UDim2.fromOffset(8, 8)
		disc.BackgroundColor3 = Kit.COLOURS.outline
		disc.BorderSizePixel = 0
		disc.Parent = frame
		CreatureCard.rounded(disc, 11)
		local number = Kit.label(disc, "", UDim2.fromScale(1, 1), UDim2.new(), 16)
		number.TextXAlignment = Enum.TextXAlignment.Center
		number.TextColor3 = Kit.COLOURS.white
		Kit.pixel(number, 14)
		position = number
	else
		name = Kit.title(frame, species, UDim2.new(1, -12, 0, 19), UDim2.fromOffset(6, 3), 40)
		level = Kit.label(frame, "", UDim2.new(1, -68, 0, 18), UDim2.fromOffset(62, 28), 20)
		bar = Kit.bar(frame, UDim2.new(1, -70, 0, 9), UDim2.fromOffset(62, 54), Kit.COLOURS.good)
	end
	Kit.pixel(level, 14)

	local lastKey = ""
	local card: Card = {
		id = id,
		kind = kind,
		frame = frame,
		refresh = function(now: Snapshot.CreatureView, place: number?, isParent: boolean)
			local hurt = math.floor(now.Hurt * 100 + 0.5)
			local key = `{now.Level}|{now.Rarity}|{hurt}|{place or 0}|{isParent}`
			if key == lastKey then
				return
			end
			lastKey = key
			name.TextColor3 = CreatureCard.rarityColour(now.Rarity)
			level.Text = `Lv {now.Level}`
			local share = CreatureCard.healthShare(now)
			bar.set(share, Kit.healthColour(share))
			frame.BackgroundColor3 = if isParent
				then PARENT_TINT
				elseif now.Hurt >= 1 then FAINT_TINT
				else Kit.COLOURS.panelLight
			if position then
				position.Text = if place then tostring(place) else ""
			end
		end,
		setSelected = function(on: boolean)
			outline.Color = if on then CreatureCard.SELECTED else Kit.COLOURS.outline
			outline.Thickness = if on then 4 else 3
		end,
		destroy = function()
			frame:Destroy()
		end,
	}
	frame.Activated:Connect(function()
		onTap(id)
	end)
	return card
end

-- An empty team slot: a dashed outline and the word "empty".
function CreatureCard.empty(parent: Instance, slot: number): Frame
	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = Kit.COLOURS.panelLight
	frame.BackgroundTransparency = 0.5
	frame.BorderSizePixel = 0
	frame.Parent = parent
	CreatureCard.rounded(frame, 8)
	local function dash(size: UDim2, position: UDim2)
		local piece = Instance.new("Frame")
		piece.Size = size
		piece.Position = position
		piece.BackgroundColor3 = Kit.COLOURS.textDim
		piece.BorderSizePixel = 0
		piece.Parent = frame
	end
	for step = 0, 7 do
		local x = step / 8 + 0.02
		dash(UDim2.new(0.075, 0, 0, 3), UDim2.fromScale(x, 0))
		dash(UDim2.new(0.075, 0, 0, 3), UDim2.new(x, 0, 1, -3))
	end
	for step = 0, 5 do
		local y = step / 6 + 0.03
		dash(UDim2.new(0, 3, 0.08, 0), UDim2.fromScale(0, y))
		dash(UDim2.new(0, 3, 0.08, 0), UDim2.new(1, -3, y, 0))
	end
	local word = Kit.label(frame, "empty", UDim2.new(1, -8, 0.2, 0), UDim2.new(0, 4, 0.4, 0), 20)
	word.TextXAlignment = Enum.TextXAlignment.Center
	word.TextColor3 = Kit.COLOURS.textDim
	Kit.pixel(word, 14)
	local number =
		Kit.label(frame, tostring(slot), UDim2.fromOffset(24, 20), UDim2.fromOffset(8, 6), 16)
	number.TextColor3 = Kit.COLOURS.textDim
	Kit.pixel(number, 14)
	return frame
end

return CreatureCard
