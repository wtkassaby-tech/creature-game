--!strict
-- The panel beside the lists on the Creatures screen: the tapped creature large, with its name,
-- level, type, rarity, health, one line of character and the things to do with it. With nothing
-- tapped it says "Tap a creature." The portrait is built once per creature shown; the action
-- buttons are rebuilt only when the set of them changes. Looks only: every button just calls
-- back to the screen, and the server decides.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CreatureCard = require(script.Parent.CreatureCard)
local Kit = require(script.Parent.Parent.UI.Kit)
local Portrait = require(script.Parent.Portrait)
local Snapshot = require(ReplicatedStorage.shared.Snapshot)
local Species = require(ReplicatedStorage.content.Species)
local SpeciesBlurbs = require(ReplicatedStorage.content.SpeciesBlurbs)

local DetailPanel = {}

export type Treat = "Tonic" | "GreatTonic" | "Revive"

-- What the panel needs to know about the creature it shows.
export type Info = {
	view: Snapshot.CreatureView,
	teamPosition: number?,
	treat: Treat?, -- the item that fits, when it is hurt and one is held
	chosen: boolean, -- picked as a parent for breeding
	armed: boolean, -- Release has been tapped once and wants a second tap
}

export type Handlers = {
	toggleTeam: () -> (),
	treat: (item: Treat) -> (),
	toggleParent: () -> (),
	release: () -> (),
}

export type Detail = {
	frame: Frame,
	show: (info: Info?) -> (),
	setPortraitHeight: (pixels: number) -> (),
}

local TREAT_LABELS: { [string]: string } =
	{ Tonic = "Tonic", GreatTonic = "Great Tonic", Revive = "Rally Root" }

function DetailPanel.new(parent: Instance, size: UDim2, position: UDim2, handlers: Handlers): Detail
	local panel = Kit.panel(parent, size, position, Kit.COLOURS.panelLight)
	local hint = Kit.label(
		panel,
		"Tap a creature.",
		UDim2.new(1, -20, 0, 40),
		UDim2.new(0, 10, 0.5, -20),
		24
	)
	hint.TextXAlignment = Enum.TextXAlignment.Center
	hint.TextColor3 = Kit.COLOURS.textDim

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -8, 1, -8)
	scroll.Position = UDim2.fromOffset(4, 4)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 5
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.CanvasSize = UDim2.new()
	scroll.Visible = false
	scroll.Parent = panel
	local pad = Instance.new("UIPadding")
	pad.PaddingTop, pad.PaddingBottom = UDim.new(0, 4), UDim.new(0, 4)
	pad.PaddingLeft, pad.PaddingRight = UDim.new(0, 6), UDim.new(0, 6)
	pad.Parent = scroll
	local stack = Instance.new("UIListLayout")
	stack.Padding = UDim.new(0, 4)
	stack.SortOrder = Enum.SortOrder.LayoutOrder
	stack.HorizontalAlignment = Enum.HorizontalAlignment.Center
	stack.Parent = scroll

	local function row(order: number, height: number): Frame
		local made = Instance.new("Frame")
		made.Size = UDim2.new(1, 0, 0, height)
		made.BackgroundTransparency = 1
		made.LayoutOrder = order
		made.Parent = scroll
		return made
	end

	local picture = row(1, 96)
	local nameLabel = Kit.label(scroll, "", UDim2.new(1, 0, 0, 26), UDim2.new(), 28)
	nameLabel.LayoutOrder = 2
	nameLabel.TextXAlignment = Enum.TextXAlignment.Center
	local facts = row(3, 24)
	local level = Kit.label(facts, "", UDim2.fromScale(0.28, 1), UDim2.new(), 20)
	Kit.pixel(level, 16)
	local rarity = Kit.label(facts, "", UDim2.fromScale(0.34, 1), UDim2.fromScale(0.66, 0), 20)
	rarity.TextXAlignment = Enum.TextXAlignment.Center
	Kit.pixel(rarity, 14)
	local healthRow = row(4, 18)
	local healthBar =
		Kit.bar(healthRow, UDim2.new(0.5, 0, 1, -4), UDim2.fromOffset(0, 2), Kit.COLOURS.good)
	local healthText =
		Kit.label(healthRow, "", UDim2.new(0.5, -8, 1, 0), UDim2.new(0.5, 8, 0, 0), 16)
	local blurb = Kit.label(scroll, "", UDim2.new(1, 0, 0, 34), UDim2.new(), 16)
	blurb.LayoutOrder = 5
	blurb.TextWrapped = true
	blurb.TextYAlignment = Enum.TextYAlignment.Top
	blurb.TextColor3 = Kit.COLOURS.textDim
	local actions = Instance.new("Frame")
	actions.Size = UDim2.fromScale(1, 0)
	actions.AutomaticSize = Enum.AutomaticSize.Y
	actions.BackgroundTransparency = 1
	actions.LayoutOrder = 6
	actions.Parent = scroll
	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.new(0.5, -3, 0, 44) -- finger-sized
	grid.CellPadding = UDim2.fromOffset(6, 6)
	grid.SortOrder = Enum.SortOrder.LayoutOrder
	grid.Parent = actions

	local shownId: string? = nil
	local portrait: ViewportFrame? = nil
	local band: Frame? = nil
	local tag: Frame? = nil
	local buttonKey = ""
	local portraitHeight = 96

	local function placePortrait()
		picture.Size = UDim2.new(1, 0, 0, portraitHeight)
		if portrait then
			portrait.Size = UDim2.new(0, portraitHeight, 1, 0)
		end
	end

	local function buildActions(info: Info)
		for _, child in actions:GetChildren() do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
		local order = 0
		local function add(text: string, colour: Color3, onClick: () -> ())
			order += 1
			local made = Kit.button(actions, text, colour, onClick)
			made.LayoutOrder = order
		end
		add(
			if info.teamPosition then "Off team" else "To team",
			Kit.COLOURS.accent,
			handlers.toggleTeam
		)
		local item: Treat? = info.treat
		if item then
			local fits: Treat = item
			add(TREAT_LABELS[fits], Kit.COLOURS.good, function()
				handlers.treat(fits)
			end)
		end
		add(
			if info.chosen then "Chosen" else "Breed",
			if info.chosen then Kit.COLOURS.good else Kit.COLOURS.panel,
			handlers.toggleParent
		)
		add(if info.armed then "Sure?" else "Release", Kit.COLOURS.bad, handlers.release)
	end

	return {
		frame = panel,
		setPortraitHeight = function(pixels: number)
			portraitHeight = pixels
			placePortrait()
		end,
		show = function(info: Info?)
			hint.Visible = info == nil
			scroll.Visible = info ~= nil
			if not info then
				shownId = nil
				return
			end
			local view = info.view
			local species = view.Torso.Species
			local def = Species[species]
			if shownId ~= view.Id then
				shownId = view.Id
				scroll.CanvasPosition = Vector2.zero
				if portrait then
					portrait:Destroy()
				end
				if band then
					band:Destroy()
				end
				if tag then
					tag:Destroy()
				end
				portrait, band, tag = nil, nil, nil
				if def then
					band =
						CreatureCard.band(picture, def.element, UDim2.fromScale(1, 1), UDim2.new())
					local made = Portrait.new(
						picture,
						species,
						def.element,
						UDim2.new(0, portraitHeight, 1, 0),
						UDim2.fromScale(0.5, 0)
					)
					made.AnchorPoint = Vector2.new(0.5, 0)
					portrait = made
					tag = CreatureCard.typeTag(
						facts,
						def.element,
						UDim2.new(0.34, 0, 1, -4),
						UDim2.new(0.3, 0, 0, 2)
					)
				end
				nameLabel.Text = species
				blurb.Text = SpeciesBlurbs[species] or ""
				blurb.Visible = blurb.Text ~= ""
			end
			nameLabel.TextColor3 = CreatureCard.rarityColour(view.Rarity)
			level.Text = `Lv {view.Level}`
			rarity.Text = view.Rarity
			rarity.TextColor3 = CreatureCard.rarityColour(view.Rarity)
			local share = CreatureCard.healthShare(view)
			healthBar.set(share, Kit.healthColour(share))
			healthText.Text = CreatureCard.healthText(view)
			healthText.TextColor3 = if view.Hurt > 0
				then Kit.healthColour(share)
				else Kit.COLOURS.text
			local key =
				`{view.Id}|{info.teamPosition or 0}|{info.treat or ""}|{info.chosen}|{info.armed}`
			if key ~= buttonKey then
				buttonKey = key
				buildActions(info)
			end
		end,
	}
end

return DetailPanel
