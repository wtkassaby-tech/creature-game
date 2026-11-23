--!strict
-- The shop screen, in three tabs. "Shop" is the coin shop (always first and the one it opens on).
-- "Gems" sells consumables for Gems (Gem lassos only where paid random items are allowed, with a
-- note that they mark the catch). "Passes" lists the passes, Gem bundles and the Starter Pack,
-- each opened through Roblox's own prompt. What shows comes from ShopOffers (pure rules); the
-- real Robux prices are read at runtime (Prices). The price shown for coins and Gems is worked out
-- the way the server does it, but the server's price is the one that counts.
-- TODO(art): first cut, not yet seen in Studio.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local BadgeOffer = require(script.Parent.BadgeOffer)
local Bus = require(script.Parent.Parent.Net.Bus)
local ClientState = require(script.Parent.Parent.State.ClientState)
local Economy = require(ReplicatedStorage.shared.Economy)
local EconomyConfig = require(ReplicatedStorage.config.EconomyConfig)
local Kit = require(script.Parent.Parent.UI.Kit)
local Net = require(ReplicatedStorage.net.generated.Client)
local Prices = require(script.Parent.Prices)
local PurchaseConfig = require(ReplicatedStorage.config.PurchaseConfig)
local ShopOffers = require(ReplicatedStorage.shared.ShopOffers)
local Snapshot = require(ReplicatedStorage.shared.Snapshot)
local StoreFlags = require(script.Parent.StoreFlags)

local ShopView = {}

export type Tab = "Shop" | "Gems" | "Passes"
export type View = { open: (tab: Tab?) -> () }

local TABS: { Tab } = { "Shop", "Gems", "Passes" }
local TAB_NAMES: { [Tab]: string } = { Shop = "Shop", Gems = "Gems", Passes = "Passes and bundles" }
local ROW_HEIGHT = 58

function ShopView.start(playerGui: Instance): View
	StoreFlags.start()
	local gui = Kit.screen(playerGui, "Shop", 12, true)
	local root = Kit.panel(gui, UDim2.fromScale(0.84, 0.92), UDim2.fromScale(0.08, 0.04))
	local title = Kit.title(root, "Shop", UDim2.new(0.68, 0, 0, 34), UDim2.fromOffset(14, 8), 28)
	local note = Kit.label(root, "", UDim2.new(1, -28, 0, 22), UDim2.new(0, 14, 1, -30), 16)
	note.TextColor3 = Kit.COLOURS.textDim
	local close = Kit.button(root, "Close", Kit.COLOURS.neutral, function()
		gui.Enabled = false
	end)
	close.Size = Kit.CLOSE_SIZE
	close.Position = UDim2.new(1, -108, 0, 4)

	local tabRow = Instance.new("Frame")
	tabRow.Size = UDim2.new(1, -28, 0, 36)
	tabRow.Position = UDim2.fromOffset(14, 46)
	tabRow.BackgroundTransparency = 1
	tabRow.Parent = root
	local tabLayout = Instance.new("UIListLayout")
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.Padding = UDim.new(0, 6)
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.Parent = tabRow

	local list = Instance.new("ScrollingFrame")
	list.Size = UDim2.new(1, -28, 1, -126)
	list.Position = UDim2.fromOffset(14, 88)
	list.BackgroundTransparency = 1
	list.BorderSizePixel = 0
	list.ScrollBarThickness = 6
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.CanvasSize = UDim2.new()
	list.Parent = root
	Kit.roomForOutlines(list)
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 6)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = list

	local activeTab: Tab = "Shop"
	local rebuild: () -> ()

	-- A row with a name on the first line and a dim line under it. Returns the row and the dim
	-- line (a caller may change it).
	local function addRow(name: string, about: string): (Frame, TextLabel)
		local row =
			Kit.panel(list, UDim2.new(1, -8, 0, ROW_HEIGHT), UDim2.new(), Kit.COLOURS.panelLight)
		Kit.label(row, name, UDim2.new(0.62, 0, 0, 26), UDim2.fromOffset(10, 4))
		local line = Kit.label(row, about, UDim2.new(0.62, 0, 0, 20), UDim2.fromOffset(10, 32), 14)
		line.TextColor3 = Kit.COLOURS.textDim
		return row, line
	end
	local function addButton(
		row: Frame,
		text: string,
		colour: Color3,
		onClick: () -> ()
	): TextButton
		local button = Kit.button(row, text, colour, onClick)
		button.Size = UDim2.new(0.32, 0, 0, 42)
		button.Position = UDim2.new(0.66, 0, 0, 8)
		return button
	end
	local function addHeading(text: string)
		local heading = Kit.title(list, text, UDim2.new(1, -8, 0, 24), UDim2.new(), 20)
		heading.TextColor3 = Kit.COLOURS.textDim
	end
	local function addNote(text: string)
		local line = Kit.label(list, text, UDim2.new(1, -8, 0, 22), UDim2.new(), 14)
		line.TextColor3 = Kit.COLOURS.textDim
		line.TextWrapped = true
	end

	-- The coin shop: more stable room, then every item the shop sells for coins.
	local function buildCoinShop(state: Snapshot.State)
		-- More stable room, while there is any left to buy (the server knows the real price).
		local bought = ShopOffers.coinExpansions(state.StableCapacity, state.StableBonus)
		local roomPrice = Economy.stableExpansionPrice(bought)
		if roomPrice then
			local row = addRow(
				`Stable room +{EconomyConfig.STABLE_EXPANSION_SLOTS}  (now {state.StableCapacity})`,
				"Room for more creatures, for good"
			)
			addButton(
				row,
				`{roomPrice} coins`,
				if state.Coins >= roomPrice then Kit.COLOURS.good else Kit.COLOURS.panel,
				function()
					Net.ExpandStable.Fire(true)
				end
			)
		end
		local reached = math.max(1, state.BiomeReached)
		for _, item: EconomyConfig.ItemId in EconomyConfig.ITEM_IDS do
			if Economy.itemAvailable(item, reached) then
				local def = EconomyConfig.ITEMS[item]
				local price = math.floor(Economy.itemPrice(item, reached))
				-- Giant Horns are kept by the grade they were bought at.
				local key: string = if item == "GiantCall" then Economy.hornKey(reached) else item
				local row, about =
					addRow(`{def.name}  (you have {state.Items[key] or 0})`, def.note)
				local buy = addButton(
					row,
					`{price} coins`,
					if state.Coins >= price then Kit.COLOURS.good else Kit.COLOURS.panel,
					function()
						Net.BuyItem.Fire({ Item = item :: string, Count = 1 })
					end
				)
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

	-- A "Studio only" line about things hidden because their Roblox id is still 0.
	local function addStudioNote(hidden: number)
		if hidden > 0 and RunService:IsStudio() then
			addNote(
				`Studio only: {hidden} Robux item{if hidden == 1 then "" else "s"} hidden until their Roblox ids are set in PurchaseConfig.`
			)
		end
	end

	-- Consumables for Gems. The coin price is named in each line, so the coin option is always seen.
	local function buildGems(state: Snapshot.State)
		local flags = StoreFlags.get()
		local offers = ShopOffers.gemItems(flags, math.max(1, state.BiomeReached))
		local anyLasso = false
		for _, offer in offers do
			anyLasso = anyLasso or offer.isLasso
		end
		if anyLasso then
			addNote("A creature caught with a Gem lasso is marked as a Gem catch.")
		end
		if #offers == 0 then
			addNote("Nothing is on sale for Gems right now.")
		end
		local reached = math.max(1, state.BiomeReached)
		for _, offer in offers do
			local def = EconomyConfig.ITEMS[offer.item]
			local heldKey: string = if offer.isLasso
				then ShopOffers.gemLassoKey(offer.item)
				else offer.item :: string
			local coinPrice = math.floor(Economy.itemPrice(offer.item, reached))
			local row = addRow(
				`{def.name}{if offer.isLasso then " (Gem)" else ""}  (you have {state.Items[heldKey] or 0})`,
				`{def.note}. Coins: {coinPrice} in the Shop tab`
			)
			addButton(
				row,
				`{offer.price} Gems`,
				if state.Gems >= offer.price then Kit.COLOURS.good else Kit.COLOURS.panel,
				function()
					Net.BuyGemItem.Fire({ Item = offer.item :: string, Count = 1 })
				end
			)
		end
		-- Where to get more Gems.
		local bundles, hidden = ShopOffers.bundles(flags)
		local starter, starterHidden = ShopOffers.starter(flags, state.Perks)
		if #bundles > 0 or starter then
			local row, line = addRow(`You have {state.Gems} Gems`, "Need more?")
			addButton(row, "Get Gems", Kit.COLOURS.accent, function()
				activeTab = "Passes"
				rebuild()
			end)
			line.Text = "Need more? Bundles are in Passes and bundles"
		end
		addStudioNote(hidden + starterHidden)
	end

	-- The price text for a button: "Buy" until Roblox has told us the price.
	local function buyText(kind: "Pass" | "Product", id: number): string
		Prices.request(kind, id, function()
			if gui.Enabled and activeTab == "Passes" then
				rebuild()
			end
		end)
		local text = Prices.text(id)
		return if text == "" then "Buy" else text
	end
	local function promptFor(key: string): () -> ()
		return function()
			Net.PromptPurchase.Fire({ Id = key })
		end
	end

	local function buildPasses(state: Snapshot.State)
		local flags = StoreFlags.get()
		local passes, hiddenPasses = ShopOffers.passes(flags, state.Passes)
		local starter, hiddenStarter = ShopOffers.starter(flags, state.Perks)
		local bundles, hiddenBundles = ShopOffers.bundles(flags)
		if #passes > 0 then
			addHeading("Passes")
		end
		for _, pass in passes do
			local row = addRow(pass.name, pass.line)
			if pass.owned then
				local owned = addButton(row, "Owned", Kit.COLOURS.neutral, function() end)
				Kit.setEnabled(owned, false)
			else
				local id = PurchaseConfig.PASSES[pass.key].id
				addButton(row, buyText("Pass", id), Kit.COLOURS.good, promptFor(pass.key))
			end
		end
		if starter then
			addHeading("Starter Pack")
			local row = addRow(starter.name, starter.line)
			local id = PurchaseConfig.PRODUCTS[starter.key].id
			addButton(row, buyText("Product", id), Kit.COLOURS.good, promptFor(starter.key))
		end
		if #bundles > 0 then
			addHeading("Gem bundles")
		end
		for _, bundle in bundles do
			local row = addRow(bundle.name, bundle.line)
			local id = PurchaseConfig.PRODUCTS[bundle.key].id
			addButton(row, buyText("Product", id), Kit.COLOURS.good, promptFor(bundle.key))
		end
		if #passes == 0 and not starter and #bundles == 0 then
			addNote("Nothing is on sale here right now.")
		end
		addStudioNote(hiddenPasses + hiddenStarter + hiddenBundles)
	end

	local function buildTabs(open: boolean)
		for _, child in tabRow:GetChildren() do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
		tabRow.Visible = open
		list.Position = if open then UDim2.fromOffset(14, 88) else UDim2.fromOffset(14, 52)
		list.Size = if open then UDim2.new(1, -28, 1, -126) else UDim2.new(1, -28, 1, -90)
		if not open then
			return
		end
		for index, tab: Tab in TABS do
			local button = Kit.button(
				tabRow,
				TAB_NAMES[tab],
				if tab == activeTab then Kit.COLOURS.accent else Kit.COLOURS.neutral,
				function()
					activeTab = tab
					rebuild()
				end
			)
			button.Size = UDim2.new(if tab == "Passes" then 0.4 else 0.26, -4, 1, 0)
			button.LayoutOrder = index
		end
	end

	rebuild = function()
		local state = ClientState.get()
		if not state then
			return
		end
		local flags = StoreFlags.get()
		-- The Gems and Passes tabs exist only while the shop's Robux switch is on.
		local robux = flags ~= nil and flags.Open
		if not robux then
			activeTab = "Shop"
		end
		title.Text = `Shop   {state.Coins} coins   {state.Gems} Gems`
		for _, child in list:GetChildren() do
			if child:IsA("Frame") or child:IsA("TextLabel") then
				child:Destroy()
			end
		end
		buildTabs(robux)
		if activeTab == "Gems" then
			buildGems(state)
		elseif activeTab == "Passes" then
			buildPasses(state)
		else
			buildCoinShop(state)
		end
	end

	ClientState.onChanged(function()
		if gui.Enabled then
			rebuild()
		end
	end)
	StoreFlags.onChanged(function()
		if gui.Enabled then
			rebuild()
		end
	end)
	Bus.listen(Net.BuyResult, function(value)
		note.Text = if value.Ok
			then `Bought {value.Count} for {value.Coins} coins`
			else value.Reason
	end)
	Bus.listen(Net.GemBuyResult, function(value)
		note.Text = if value.Ok
			then `Bought {value.Count} for Gems. {value.Gems} Gems left`
			else value.Reason
	end)
	-- A finished purchase arrives as a notice ("Your purchase arrived"); the counts above refresh
	-- from the new state.
	Bus.listen(Net.Notice, function(value)
		if gui.Enabled then
			note.Text = value.Text
		end
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

	local view: View = {
		open = function(tab: Tab?)
			note.Text = ""
			activeTab = tab or "Shop"
			gui.Enabled = true
			rebuild()
		end,
	}
	BadgeOffer.start(playerGui, function()
		view.open("Gems")
	end)
	return view
end

return ShopView
