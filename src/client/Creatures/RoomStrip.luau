--!strict
-- Shown at the top of the stable list only while the stable is full (plan 16 placement): the ways
-- to get more room, in this order. Coins first (an expansion at a shop, named with its price),
-- then the Bigger Stable pass, then the Starter Pack (which carries room). Each pass or pack
-- button opens Roblox's own prompt through the server. It is part of the screen the player opened,
-- never a pop-up, and never shows in battle. The Robux buttons need the shop's Robux switch on and
-- real ids; the coin line stays. Real prices are read from Roblox (Prices); until they arrive a
-- button shows just its name.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Kit = require(script.Parent.Parent.UI.Kit)
local Net = require(ReplicatedStorage.net.generated.Client)
local Prices = require(script.Parent.Parent.Shop.Prices)
local PurchaseConfig = require(ReplicatedStorage.config.PurchaseConfig)
local ShopOffers = require(ReplicatedStorage.shared.ShopOffers)
local Snapshot = require(ReplicatedStorage.shared.Snapshot)
local StoreFlags = require(script.Parent.Parent.Shop.StoreFlags)

local RoomStrip = {}

export type Strip = { update: (state: Snapshot.State) -> () }

function RoomStrip.new(
	parent: Instance,
	order: number,
	playerGui: Instance,
	refresh: () -> ()
): Strip
	local made = Kit.panel(parent, UDim2.new(1, 0, 0, 84), UDim2.new(), Kit.COLOURS.panelLight)
	made.LayoutOrder = order
	made.Name = "RoomStrip"
	made.Visible = false
	local heading =
		Kit.title(made, "Stable full", UDim2.new(1, -20, 0, 24), UDim2.fromOffset(10, 4), 20)
	heading.TextColor3 = Kit.COLOURS.textDim
	local cells = Instance.new("Frame")
	cells.Size = UDim2.new(1, -20, 0, 46)
	cells.Position = UDim2.fromOffset(10, 32)
	cells.BackgroundTransparency = 1
	cells.Parent = made
	local across = Instance.new("UIListLayout")
	across.FillDirection = Enum.FillDirection.Horizontal
	across.Padding = UDim.new(0, 6)
	across.SortOrder = Enum.SortOrder.LayoutOrder
	across.Parent = cells

	local lastKey = ""

	local function buyText(kind: "Pass" | "Product", id: number, name: string): string
		Prices.request(kind, id, refresh)
		local price = Prices.text(id)
		return if price == "" then name else `{name} {price}`
	end

	local function update(state: Snapshot.State)
		local offers: { ShopOffers.RoomOffer } = {}
		if not StoreFlags.inBattle(playerGui) then
			offers = ShopOffers.stableFull(
				#state.Creatures,
				state.StableCapacity,
				ShopOffers.coinExpansions(state.StableCapacity, state.StableBonus),
				StoreFlags.get(),
				state.Passes,
				state.Perks
			)
		end
		-- The texts are part of the key, so a price arriving redraws the buttons.
		local texts: { string } = {}
		for _, offer in offers do
			if offer.kind == "CoinRoom" then
				table.insert(texts, `Room: {offer.coins} coins at a shop`)
			elseif offer.kind == "Pass" then
				local def = PurchaseConfig.PASSES.BiggerStable
				table.insert(texts, buyText("Pass", def.id, `{def.name} +{def.stableRoom}`))
			else
				local def = PurchaseConfig.PRODUCTS.StarterPack
				table.insert(texts, buyText("Product", def.id, "Starter Pack"))
			end
		end
		local key = table.concat(texts, "|")
		made.Visible = #offers > 0
		if key == lastKey then
			return
		end
		lastKey = key
		for _, child in cells:GetChildren() do
			if child:IsA("GuiObject") then
				child:Destroy()
			end
		end
		local width = UDim2.new(1 / math.max(1, #offers), -6, 1, 0)
		for index, offer in offers do
			local text = texts[index]
			if offer.kind == "CoinRoom" then
				-- Coins are bought at a shop, so this is a line, not a button.
				local cell = Kit.panel(cells, width, UDim2.new(), Kit.COLOURS.panel)
				cell.LayoutOrder = index
				local label =
					Kit.label(cell, text, UDim2.new(1, -12, 1, -6), UDim2.fromOffset(6, 3), 16)
				label.TextWrapped = true
				label.TextXAlignment = Enum.TextXAlignment.Center
			else
				local button = Kit.button(cells, text, Kit.COLOURS.good, function()
					Net.PromptPurchase.Fire({ Id = offer.key :: string })
				end)
				button.Size = width
				button.LayoutOrder = index
			end
		end
	end

	return { update = update }
end

return RoomStrip
