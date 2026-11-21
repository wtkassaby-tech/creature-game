--!strict
-- What a player does with what they own, outside breeding: using an item in a battle, buying
-- at the shop, and releasing a creature. The rules are in src/shared/Shop and src/shared/Grants;
-- this file checks who is asking and where they stand, and tells the device the result.
-- Not yet run in Studio.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Grants = require(ReplicatedStorage.shared.Grants)
local Net = require(ReplicatedStorage.net.generated.Server)
local Profile = require(ReplicatedStorage.shared.Profile)
local Shop = require(ReplicatedStorage.shared.Shop)
local WorldConfig = require(ReplicatedStorage.config.WorldConfig)

local BattleService = require(script.Parent.Parent.Battle.BattleService)
local WorldService = require(script.Parent.Parent.World.WorldService)

export type Hooks = {
	getData: (player: Player) -> Profile.Profile?,
	changed: (player: Player) -> (),
	claimWaiting: (player: Player, profile: Profile.Profile) -> (), -- hand over gifts that waited for room
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
		local biome = WorldService.biome()
		local atShop = false
		for _, building in biome.hub.buildings do
			if
				building.role == "Shop"
				and WorldService.isNear(player, building.id, WorldConfig.TALK_RADIUS)
			then
				atShop = true
			end
		end
		local bought, problem = Shop.buy(profile, value.Item, value.Count, atShop, biome.number)
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
		Grants.rollDay(profile, os.time()) -- the release falloff counts by the server's date
		local before = profile.Coins
		local grant = Grants.release(profile, value.Id, BattleService.isInBattle(player, value.Id))
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

	Players.PlayerRemoving:Connect(function(player)
		lastItem[player] = nil
		lastBuy[player] = nil
		lastRelease[player] = nil
	end)
end

return InventoryService
