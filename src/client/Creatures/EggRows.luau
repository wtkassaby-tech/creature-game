--!strict
-- The egg cards at the top of the stable list: for each egg still to hatch, its time left and a
-- "Finish now: N Gems" button (plan 16). The price is worked out the same way the server does
-- (Gems.eggFinishCost), but the server's price is the one charged, and FinishEgg names the egg by
-- its hatch time. The button is disabled, with the reason written on the card, when the stable
-- has no room for the hatchling. With too few Gems the tap opens the Gem bundles instead. Nothing
-- shows in battle, while the shop's Robux switch is off, or before the server has said what the
-- shop may show. Rebuilt only when what the cards say changes; the clock text is set in place.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Kit = require(script.Parent.Parent.UI.Kit)
local Net = require(ReplicatedStorage.net.generated.Client)
local ShopOffers = require(ReplicatedStorage.shared.ShopOffers)
local Snapshot = require(ReplicatedStorage.shared.Snapshot)
local StoreFlags = require(script.Parent.Parent.Shop.StoreFlags)

local EggRows = {}

export type Rows = { update: (state: Snapshot.State) -> () }

local CARD_HEIGHT = 56

local function clock(seconds: number): string
	local left = math.max(0, math.floor(seconds))
	return string.format("%d:%02d", left // 60, left % 60)
end

function EggRows.new(
	parent: Instance,
	order: number,
	playerGui: Instance,
	openGemShop: () -> ()
): Rows
	local holder = Instance.new("Frame")
	holder.Name = "EggRows"
	holder.Size = UDim2.fromScale(1, 0)
	holder.AutomaticSize = Enum.AutomaticSize.Y
	holder.BackgroundTransparency = 1
	holder.LayoutOrder = order
	holder.Visible = false
	holder.Parent = parent
	local stack = Instance.new("UIListLayout")
	stack.Padding = UDim.new(0, 6)
	stack.SortOrder = Enum.SortOrder.LayoutOrder
	stack.Parent = holder

	local lastKey = ""
	local clocks: { [number]: TextLabel } = {} -- hatch time -> its clock text

	local function update(state: Snapshot.State)
		local now = os.time()
		local hatchTimes: { number } = {}
		for _, egg in state.Eggs do
			table.insert(hatchTimes, egg.HatchAt)
		end
		local offers = ShopOffers.eggs(
			hatchTimes,
			#state.Creatures,
			state.StableCapacity,
			state.Gems,
			now,
			StoreFlags.get(),
			StoreFlags.inBattle(playerGui)
		)
		local parts: { string } = {}
		for _, offer in offers do
			table.insert(parts, `{offer.hatchAt}:{offer.cost}:{offer.canFinish}:{offer.needsGems}`)
		end
		local key = table.concat(parts, "|")
		if key ~= lastKey then
			lastKey = key
			clocks = {}
			for _, child in holder:GetChildren() do
				if child:IsA("Frame") then
					child:Destroy()
				end
			end
			for index, offer in offers do
				local card = Kit.panel(
					holder,
					UDim2.new(1, 0, 0, CARD_HEIGHT),
					UDim2.new(),
					Kit.COLOURS.panelLight
				)
				card.LayoutOrder = index
				local clockLabel =
					Kit.label(card, "", UDim2.new(0.5, 0, 0, 26), UDim2.fromOffset(10, 4), 20)
				Kit.pixel(clockLabel, 18)
				clocks[offer.hatchAt] = clockLabel
				local why = "Skips the wait"
				if offer.reason then
					why = offer.reason
				elseif offer.needsGems then
					why = "Not enough Gems: tap to get some"
				end
				local line =
					Kit.label(card, why, UDim2.new(0.5, 0, 0, 20), UDim2.fromOffset(10, 32), 14)
				line.TextColor3 = Kit.COLOURS.textDim
				local button = Kit.button(
					card,
					`Finish now: {offer.cost} Gems`,
					if offer.needsGems then Kit.COLOURS.accent else Kit.COLOURS.good,
					function()
						if offer.needsGems then
							openGemShop()
						else
							Net.FinishEgg.Fire({ HatchAt = offer.hatchAt })
						end
					end
				)
				button.Size = UDim2.new(0.44, 0, 0, 42)
				button.Position = UDim2.new(0.54, 0, 0, 7)
				if not offer.canFinish then
					Kit.setEnabled(button, false)
				end
			end
		end
		holder.Visible = #offers > 0
		for hatchAt, label in clocks do
			label.Text = `Egg  {clock(hatchAt - now)}`
		end
	end

	return { update = update }
end

return EggRows
