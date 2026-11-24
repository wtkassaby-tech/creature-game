--!strict
-- What a player does with what they own, outside breeding: using an item in a battle, buying
-- at the shop, and releasing a creature. The rules are in src/shared/Shop and src/shared/Grants;
-- this file checks who is asking and where they stand, and tells the device the result.
-- Not yet run in Studio.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Gems = require(ReplicatedStorage.shared.Gems)
local Grants = require(ReplicatedStorage.shared.Grants)
local Health = require(ReplicatedStorage.shared.Health)
local Layout = require(ReplicatedStorage.shared.Layout)
local Net = require(ReplicatedStorage.net.generated.Server)
local Profile = require(ReplicatedStorage.shared.Profile)
local PurchaseConfig = require(ReplicatedStorage.config.PurchaseConfig)
local Shop = require(ReplicatedStorage.shared.Shop)
local Team = require(ReplicatedStorage.shared.Team)
local WorldConfig = require(ReplicatedStorage.config.WorldConfig)

local BattleService = require(script.Parent.Parent.Battle.BattleService)
local LiveConfigService = require(script.Parent.Parent.LiveConfig.LiveConfigService)
local WorldService = require(script.Parent.Parent.World.WorldService)

export type Hooks = {
	getData: (player: Player) -> Profile.Profile?,
	changed: (player: Player) -> (),
	save: (player: Player) -> (), -- ask for a save soon
	-- PolicyService's answer for the player (true until it has answered): Gem lassos are refused
	-- unless this is false.
	paidRandomRestricted: (player: Player) -> boolean,
	claimWaiting: (player: Player, profile: Profile.Profile) -> (), -- hand over gifts that waited for room
	isLocked: (player: Player, creatureId: string) -> boolean, -- in a battle or a giant fight
	isUnlocked: (profile: Profile.Profile, feature: string) -> boolean, -- opened by the story yet?
	notify: (player: Player, text: string) -> (),
	log: (event: string, fields: { [string]: any }) -> (),
}

local InventoryService = {}

function InventoryService.start(hooks: Hooks)
	-- Each kind of request has its own limit, so using an item never swallows a purchase.
	local lastItem: { [Player]: number } = {}
	local lastBuy: { [Player]: number } = {}
	local function tooFast(last: { [Player]: number }, player: Player): boolean
		local now = os.clock()
		if now - (last[player] or -math.huge) < 0.25 then
			return true
		end
		last[player] = now
		return false
	end

	Net.UseItem.On(function(player, value)
		if tooFast(lastItem, player) then
			return
		end
		local session = BattleService.session(player)
		local profile = hooks.getData(player)
		if not session or not profile or session.battleId ~= value.BattleId then
			return BattleService.refuse(player, "That battle is over")
		end
		if BattleService.isBusy(player) then
			return BattleService.refuse(player, "Finish your throw first")
		end
		local turn, problem =
			Shop.useInBattle(profile, session, value.Turn, value.Item, value.Target)
		if not turn then
			return BattleService.refuse(player, problem or "You cannot use that now")
		end
		hooks.changed(player)
		BattleService.publishTurn(player, session, turn)
	end)

	Net.BuyItem.On(function(player, value)
		local profile = hooks.getData(player)
		if not profile then
			return
		end
		if tooFast(lastBuy, player) then
			-- Always answer a purchase, so the screen never waits for a reply that was dropped.
			return Net.BuyResult.Fire(
				player,
				{ Item = value.Item, Ok = false, Reason = "Too fast", Count = 0, Coins = 0 }
			)
		end
		-- A shop in any town, or the supply stall on the way to any lair.
		local shopBiome = WorldService.buildingAt(player, "Shop", WorldConfig.TALK_RADIUS)
		for _, biome in WorldService.biomes() do
			if
				not shopBiome
				and WorldService.isNear(player, Layout.stallId(biome), WorldConfig.TALK_RADIUS)
			then
				shopBiome = biome
			end
		end
		local atShop = shopBiome ~= nil
		local shopNumber = if shopBiome then shopBiome.number else 1
		local bought: Shop.Bought?, problem: string? = nil, "The shop is not open to you yet"
		if not LiveConfigService.isOn("shop_open") then
			problem = LiveConfigService.closedText()
		elseif hooks.isUnlocked(profile, "shop") then
			bought, problem = Shop.buy(profile, value.Item, value.Count, atShop, shopNumber)
		end
		Net.BuyResult.Fire(player, {
			Item = value.Item,
			Ok = bought ~= nil,
			Reason = string.sub(problem or "", 1, 80),
			Count = if bought then bought.count else 0,
			Coins = if bought then bought.coins else 0,
		})
		if bought then
			hooks.changed(player)
			hooks.log("Bought", {
				player = player.UserId,
				item = bought.item,
				count = bought.count,
				coins = bought.coins,
			})
		end
	end)

	-- Consumables bought with Gems (plan 16; the owner allowed Gems for lassos, bait and tonics).
	-- Same rules as the coin shop: at a shop or stall, the shop unlocked by the story. The price is
	-- the server's (Gems.itemPrice); the device sends only an item and a count.
	local lastGemBuy: { [Player]: number } = {}
	Net.BuyGemItem.On(function(player, value)
		local profile = hooks.getData(player)
		if not profile then
			return
		end
		local function answer(ok: boolean, reason: string, count: number)
			Net.GemBuyResult.Fire(player, {
				Item = value.Item,
				Ok = ok,
				Reason = string.sub(reason, 1, 80),
				Count = count,
				Gems = math.clamp(profile.Gems, 0, 4294967295),
			})
		end
		local now = os.clock()
		if now - (lastGemBuy[player] or -math.huge) < PurchaseConfig.GEM_BUY_COOLDOWN then
			return answer(false, "Too fast", 0)
		end
		lastGemBuy[player] = now
		if
			not LiveConfigService.isOn("shop_open") or not LiveConfigService.isOn("purchases_open")
		then
			return answer(false, LiveConfigService.closedText(), 0)
		end
		if not hooks.isUnlocked(profile, "shop") then
			return answer(false, "The shop is not open to you yet", 0)
		end
		local atShop = WorldService.buildingAt(player, "Shop", WorldConfig.TALK_RADIUS) ~= nil
		for _, biome in WorldService.biomes() do
			atShop = atShop
				or WorldService.isNear(player, Layout.stallId(biome), WorldConfig.TALK_RADIUS)
		end
		local bought, problem = Gems.buyItem(
			profile,
			value.Item,
			value.Count,
			atShop,
			hooks.paidRandomRestricted(player)
		)
		if not bought then
			return answer(false, problem or "That cannot be bought", 0)
		end
		answer(true, "", bought.count)
		hooks.changed(player)
		hooks.save(player) -- a Gem spend is saved soon, like a purchase
		hooks.log("GemSpend", {
			player = player.UserId,
			item = bought.item,
			count = bought.count,
			gems = bought.gems,
			reason = bought.line.reason,
			before = bought.line.before,
			after = bought.line.after,
		})
	end)

	local lastRelease: { [Player]: number } = {}
	Net.ReleaseCreature.On(function(player, value)
		local now = os.clock()
		if now - (lastRelease[player] or -math.huge) < 0.3 then
			return
		end
		lastRelease[player] = now
		local profile = hooks.getData(player)
		if not profile then
			return
		end
		if not LiveConfigService.isOn("release_open") then
			return hooks.notify(player, LiveConfigService.closedText())
		end
		Grants.rollDay(profile, os.time()) -- the release falloff counts by the server's date
		local before = profile.Coins
		local grant = Grants.release(profile, value.Id, hooks.isLocked(player, value.Id))
		local ok = grant.outcome == "Granted"
		Net.ReleaseResult.Fire(player, {
			Id = value.Id,
			Ok = ok,
			Reason = string.sub(grant.reason or "", 1, 80),
			Coins = math.max(0, profile.Coins - before),
			Candy = grant.candy or 0,
			Element = grant.element,
		})
		if ok then
			hooks.changed(player)
			hooks.claimWaiting(player, profile)
			hooks.log(
				"Release",
				{ player = player.UserId, creature = value.Id, coins = profile.Coins - before }
			)
		end
	end)

	-- Making an item from materials: anywhere, since the materials are the cost.
	local lastCraft: { [Player]: number } = {}
	Net.CraftItem.On(function(player, value)
		local profile = hooks.getData(player)
		if not profile or tooFast(lastCraft, player) then
			return
		end
		if not LiveConfigService.isOn("shop_open") then
			return hooks.notify(player, LiveConfigService.closedText())
		end
		local made, problem = Shop.craft(profile, value.Item)
		if made then
			hooks.changed(player)
			hooks.notify(player, `Made 1 {made}`)
			hooks.log("Crafted", { player = player.UserId, item = made })
		else
			hooks.notify(player, problem or "That cannot be made")
		end
	end)

	-- More stable room, bought with coins at a shop or stall.
	local lastExpand: { [Player]: number } = {}
	Net.ExpandStable.On(function(player)
		local profile = hooks.getData(player)
		if not profile or tooFast(lastExpand, player) then
			return
		end
		local atShop = WorldService.buildingAt(player, "Shop", WorldConfig.TALK_RADIUS) ~= nil
		for _, biome in WorldService.biomes() do
			atShop = atShop
				or WorldService.isNear(player, Layout.stallId(biome), WorldConfig.TALK_RADIUS)
		end
		local price: number?, problem: string? = nil, "The shop is not open to you yet"
		if not LiveConfigService.isOn("shop_open") then
			problem = LiveConfigService.closedText()
		elseif hooks.isUnlocked(profile, "shop") then
			price, problem = Shop.expandStable(profile, atShop)
		end
		if price then
			hooks.changed(player)
			hooks.claimWaiting(player, profile) -- something may have been waiting for room
			hooks.notify(player, `Your stable now holds {profile.StableCapacity} creatures`)
			hooks.log(
				"StableExpanded",
				{ player = player.UserId, coins = price, capacity = profile.StableCapacity }
			)
		else
			hooks.notify(player, problem or "That cannot be bought")
		end
	end)

	-- The healer in town: free, and mends every creature the player owns.
	local lastHeal: { [Player]: number } = {}
	Net.HealAtHealer.On(function(player)
		local profile = hooks.getData(player)
		if not profile or tooFast(lastHeal, player) then
			return
		end
		local atHealer = WorldService.buildingAt(player, "Healer", WorldConfig.TALK_RADIUS) ~= nil
		if not atHealer then
			return hooks.notify(player, "You are too far from the healer")
		end
		for id in profile.Creatures do
			if hooks.isLocked(player, id) then
				return hooks.notify(player, "Finish your battle first")
			end
		end
		local mended = Health.healAll(profile)
		hooks.changed(player)
		hooks.notify(
			player,
			if mended > 0
				then "Your creatures are rested and well"
				else "Your creatures are already well"
		)
	end)

	-- A tonic or a Rally Root on one creature, anywhere outside a battle.
	local lastTreat: { [Player]: number } = {}
	Net.TreatCreature.On(function(player, value)
		local profile = hooks.getData(player)
		if not profile or tooFast(lastTreat, player) then
			return
		end
		local after, problem = Health.useItem(
			profile,
			value.Item,
			value.CreatureId,
			function(creatureId)
				return hooks.isLocked(player, creatureId)
			end
		)
		if after then
			hooks.changed(player)
		else
			hooks.notify(player, problem or "That did nothing")
		end
	end)

	local lastTeam: { [Player]: number } = {}
	Net.SetTeam.On(function(player, value)
		local profile = hooks.getData(player)
		if not profile or tooFast(lastTeam, player) then
			return
		end
		local ok, problem = Team.set(profile, value.Ids, function(creatureId)
			return hooks.isLocked(player, creatureId)
		end)
		if ok then
			hooks.changed(player)
		else
			hooks.notify(player, problem or "Your team could not be changed")
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		lastTeam[player] = nil
		lastHeal[player] = nil
		lastExpand[player] = nil
		lastCraft[player] = nil
		lastTreat[player] = nil
		lastItem[player] = nil
		lastBuy[player] = nil
		lastGemBuy[player] = nil
		lastRelease[player] = nil
	end)
end

return InventoryService
