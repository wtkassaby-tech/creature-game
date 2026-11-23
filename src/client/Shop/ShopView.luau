--!strict
-- The shop screen: everything the shop sells to this player, with its price, and a Buy button.
-- The price shown is worked out the same way the server does it, but the server's price is the
-- one that counts.
-- TODO(art): first cut, not yet seen in Studio.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Bus = require(script.Parent.Parent.Net.Bus)
local ClientState = require(script.Parent.Parent.State.ClientState)
local Economy = require(ReplicatedStorage.shared.Economy)
local EconomyConfig = require(ReplicatedStorage.config.EconomyConfig)
local Kit = require(script.Parent.Parent.UI.Kit)
local Net = require(ReplicatedStorage.net.generated.Client)

local ShopView = {}

export type View = { open: () -> () }

function ShopView.start(playerGui: Instance): View
	local gui = Kit.screen(playerGui, "Shop", 12, true)
	local root = Kit.panel(gui, UDim2.fromScale(0.8, 0.8), UDim2.fromScale(0.1, 0.1))
	local title = Kit.title(root, "Shop", UDim2.new(0.6, 0, 0, 34), UDim2.fromOffset(14, 8), 28)
	local note = Kit.label(root, "", UDim2.new(1, -28, 0, 22), UDim2.new(0, 14, 1, -30), 16)
	note.TextColor3 = Kit.COLOURS.textDim
	local close = Kit.button(root, "Close", Kit.COLOURS.neutral, function()
		gui.Enabled = false
	end)
	close.Size = Kit.CLOSE_SIZE
	close.Position = UDim2.new(1, -108, 0, 4)

	local list = Instance.new("ScrollingFrame")
	list.Size = UDim2.new(1, -28, 1, -90)
	list.Position = UDim2.fromOffset(14, 52)
	list.BackgroundTransparency = 1
	list.BorderSizePixel = 0
	list.ScrollBarThickness = 6
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.CanvasSize = UDim2.new()
	list.Parent = root
	Kit.roomForOutlines(list)
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 6)
	layout.Parent = list

	local function rebuild()
		local state = ClientState.get()
		if not state then
			return
		end
		title.Text = `Shop   {state.Coins} coins`
		for _, child in list:GetChildren() do
			if child:IsA("Frame") then
				child:Destroy()
			end
		end
		-- More stable room, while there is any left to buy (the server knows the real price).
		local bought = math.max(
			0,
			(state.StableCapacity - EconomyConfig.STABLE_FREE_SLOTS - state.StableBonus)
				// EconomyConfig.STABLE_EXPANSION_SLOTS
		)
		local roomPrice = Economy.stableExpansionPrice(bought)
		if roomPrice then
			local row =
				Kit.panel(list, UDim2.new(1, -8, 0, 58), UDim2.new(), Kit.COLOURS.panelLight)
			Kit.label(
				row,
				`Stable room +{EconomyConfig.STABLE_EXPANSION_SLOTS}  (now {state.StableCapacity})`,
				UDim2.new(0.62, 0, 0, 26),
				UDim2.fromOffset(10, 4)
			)
			local about = Kit.label(
				row,
				"Room for more creatures, for good",
				UDim2.new(0.62, 0, 0, 20),
				UDim2.fromOffset(10, 32),
				14
			)
			about.TextColor3 = Kit.COLOURS.textDim
			local buy = Kit.button(
				row,
				`{roomPrice} coins`,
				if state.Coins >= roomPrice then Kit.COLOURS.good else Kit.COLOURS.panel,
				function()
					Net.ExpandStable.Fire(true)
				end
			)
			buy.Size = UDim2.new(0.32, 0, 0, 42)
			buy.Position = UDim2.new(0.66, 0, 0, 8)
		end
		local reached = math.max(1, state.BiomeReached)
		for _, item: EconomyConfig.ItemId in EconomyConfig.ITEM_IDS do
			if Economy.itemAvailable(item, reached) then
				local def = EconomyConfig.ITEMS[item]
				local price = math.floor(Economy.itemPrice(item, reached))
				-- Giant Horns are kept by the grade they were bought at.
				local key: string = if item == "GiantCall" then Economy.hornKey(reached) else item
				local row =
					Kit.panel(list, UDim2.new(1, -8, 0, 58), UDim2.new(), Kit.COLOURS.panelLight)
				Kit.label(
					row,
					`{def.name}  (you have {state.Items[key] or 0})`,
					UDim2.new(0.62, 0, 0, 26),
					UDim2.fromOffset(10, 4)
				)
				local about = Kit.label(
					row,
					def.note,
					UDim2.new(0.62, 0, 0, 20),
					UDim2.fromOffset(10, 32),
					14
				)
				about.TextColor3 = Kit.COLOURS.textDim
				local buy = Kit.button(
					row,
					`{price} coins`,
					if state.Coins >= price then Kit.COLOURS.good else Kit.COLOURS.panel,
					function()
						Net.BuyItem.Fire({ Item = item :: string, Count = 1 })
					end
				)
				buy.Size = UDim2.new(0.32, 0, 0, 42)
				buy.Position = UDim2.new(0.66, 0, 0, 8)
				-- Some items can also be made from a biome's material.
				local recipe: EconomyConfig.Recipe? = nil
				if item == "Tonic" then
					recipe = EconomyConfig.RECIPES.Tonic
				elseif item == "GreatTonic" then
					recipe = EconomyConfig.RECIPES.GreatTonic
				elseif item == "Bait" then
					recipe = EconomyConfig.RECIPES.Bait
				elseif item == "Cure" then
					recipe = EconomyConfig.RECIPES.Cure
				end
				if recipe then
					local have = state.Items[recipe.material :: string] or 0
					-- Material ids have no spaces ("CanyonGrit"); players read "Canyon Grit".
					local material = string.gsub(recipe.material :: string, "(%l)(%u)", "%1 %2")
					about.Text =
						`{def.note}. Or make one: {recipe.count} {material} (you have {have})`
					if have >= recipe.count and state.Coins >= recipe.coins then
						buy.Size = UDim2.new(0.16, -2, 0, 42)
						local make = Kit.button(row, "Make", Kit.COLOURS.accent, function()
							Net.CraftItem.Fire({ Item = item :: string })
						end)
						make.Size = UDim2.new(0.16, -2, 0, 42)
						make.Position = UDim2.new(0.82, 2, 0, 8)
					end
				end
			end
		end
	end

	ClientState.onChanged(function()
		if gui.Enabled then
			rebuild()
		end
	end)
	Bus.listen(Net.BuyResult, function(value)
		note.Text = if value.Ok
			then `Bought {value.Count} for {value.Coins} coins`
			else value.Reason
	end)

	-- Talking to the shopkeeper can also start her story lines. The shop waits behind them
	-- (the two panels overlapped in the longer Studio run) and shows when the last line is read.
	task.spawn(function()
		local dialogue = playerGui:WaitForChild("Dialogue")
		if not dialogue:IsA("ScreenGui") then
			return
		end
		local function fit()
			root.Visible = not dialogue.Enabled
		end
		dialogue:GetPropertyChangedSignal("Enabled"):Connect(fit)
		fit()
	end)
	-- The shop sits above the battle screens, and a player can walk off with it open: a fight
	-- that starts (long grass, a giant) must not begin hidden underneath it.
	Bus.listen(Net.BattleStarted, function()
		gui.Enabled = false
	end)
	Bus.listen(Net.GiantStarted, function()
		gui.Enabled = false
	end)

	return {
		open = function()
			note.Text = ""
			gui.Enabled = true
			rebuild()
		end,
	}
end

return ShopView
