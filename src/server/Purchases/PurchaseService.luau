--!strict
-- Everything bought with Robux, on the server (plan 05, plan 16). The rules are in
-- src/shared/Purchases, PassEffects and Gems; this file talks to Roblox:
--
--   * MarketplaceService.ProcessReceipt: grants a Gem bundle or the Starter Pack once per
--     PurchaseId. The grant and the PurchaseId are written in the same step (Purchases.process),
--     and PurchaseGranted is returned only after ProfileStore has saved that record. Anything
--     else (data not loaded, switch off, unknown product, a failed save) returns NotProcessedYet,
--     so Roblox asks again and the PurchaseId stops a second grant.
--   * Game passes: checked with UserOwnsGamePassAsync when the player's data loads and when
--     PromptGamePassPurchaseFinished fires (never trusting the event alone), then applied once.
--   * PolicyService: fetched when the data loads, in a pcall; paid random items count as
--     restricted until it answers. The Lasso Pass is only active while it says "not restricted".
--   * The prompts, opened by the server for a key the device names (PromptPurchase).
--   * Finishing an egg with Gems (FinishEgg).
--
-- APIs used (checked against the Roblox docs on 23 November 2026): MarketplaceService
-- .ProcessReceipt (receiptInfo.PurchaseId, PlayerId, ProductId; ProductPurchaseDecision),
-- :UserOwnsGamePassAsync(userId, gamePassId), :PromptGamePassPurchase(player, id),
-- :PromptProductPurchase(player, id), .PromptGamePassPurchaseFinished(player, id, wasPurchased)
-- and PolicyService:GetPolicyInfoForPlayerAsync(player). Prices are read by the device with
-- MarketplaceService:GetProductInfoAsync, never here. Not yet run in Studio or a published game.

local MarketplaceService = game:GetService("MarketplaceService")
local PolicyService = game:GetService("PolicyService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Gems = require(ReplicatedStorage.shared.Gems)
local Net = require(ReplicatedStorage.net.generated.Server)
local PassEffects = require(ReplicatedStorage.shared.PassEffects)
local Profile = require(ReplicatedStorage.shared.Profile)
local PurchaseConfig = require(ReplicatedStorage.config.PurchaseConfig)
local Purchases = require(ReplicatedStorage.shared.Purchases)

local LiveConfigService = require(script.Parent.Parent.LiveConfig.LiveConfigService)

export type Hooks = {
	getData: (player: Player) -> Profile.Profile?,
	changed: (player: Player) -> (),
	save: (player: Player) -> (),
	-- Yields until the check is true of what was last saved; false if the session ended first.
	waitSaved: (player: Player, isSaved: (saved: any) -> boolean) -> boolean,
	notify: (player: Player, text: string) -> (),
	log: (event: string, fields: { [string]: any }) -> (),
}

type Policy = { restricted: boolean, tradingAllowed: boolean, known: boolean }

local PurchaseService = {}

local policies: { [Player]: Policy } = {}
local lastPrompt: { [Player]: number } = {}
local lastFinish: { [Player]: number } = {}
-- Receipts being handled right now, and ones granted on this server (kept while the server runs,
-- so a repeated call is answered without touching the record twice).
local inFlight: { [string]: boolean } = {}
local handled: { [string]: boolean } = {}
local handledCount = 0
local MAX_HANDLED = 2000

-- True until PolicyService has answered for this player.
function PurchaseService.paidRandomRestricted(player: Player): boolean
	local policy = policies[player]
	-- A paid chance is never offered while the live chance display is switched off.
	return policy == nil or policy.restricted or not LiveConfigService.isOn("chance_display")
end

function PurchaseService.tradingAllowed(player: Player): boolean
	local policy = policies[player]
	return policy ~= nil and policy.tradingAllowed
end

-- Turns a name from the device, or a Roblox game pass id, into a pass key. (Looked up here, from
-- this file's own view of the config, so the key's type is the config's own.)
local function passByName(value: unknown): PurchaseConfig.PassId?
	local found: PurchaseConfig.PassId? = nil
	for _, key: PurchaseConfig.PassId in PurchaseConfig.PASS_IDS do
		if key == value then
			found = key
		end
	end
	return found
end

local function passByRobloxId(gamePassId: unknown): PurchaseConfig.PassId?
	local found: PurchaseConfig.PassId? = nil
	if typeof(gamePassId) == "number" and gamePassId >= 1 then
		for _, key: PurchaseConfig.PassId in PurchaseConfig.PASS_IDS do
			if PurchaseConfig.PASSES[key].id == gamePassId then
				found = key
			end
		end
	end
	return found
end

local function productByName(value: unknown): PurchaseConfig.ProductId?
	local found: PurchaseConfig.ProductId? = nil
	for _, key: PurchaseConfig.ProductId in PurchaseConfig.PRODUCT_IDS do
		if key == value then
			found = key
		end
	end
	return found
end

local function isOpen(): boolean
	return LiveConfigService.isOn("purchases_open")
end

-- Tells the device what the shop may show.
local function sendFlags(player: Player, hooks: Hooks)
	local profile = hooks.getData(player)
	local restricted = PurchaseService.paidRandomRestricted(player)
	Net.PurchaseFlags.Fire(player, {
		Open = isOpen(),
		PaidRandomRestricted = restricted,
		TradingAllowed = PurchaseService.tradingAllowed(player),
		LassoBoost = profile ~= nil and PassEffects.lassoBoostActive(profile, restricted),
	})
end

-- Asks PolicyService, in a pcall, retrying with waits until it answers or the player leaves.
local function fetchPolicy(player: Player, hooks: Hooks)
	policies[player] = { restricted = true, tradingAllowed = false, known = false }
	local attempt = 0
	while player.Parent == Players do
		local ok, info = pcall(function(): unknown
			return PolicyService:GetPolicyInfoForPlayerAsync(player)
		end)
		if ok then
			if player.Parent ~= Players then
				return -- left while waiting: write nothing
			end
			local read = Purchases.readPolicy(info)
			policies[player] =
				{ restricted = read.restricted, tradingAllowed = read.tradingAllowed, known = true }
			hooks.log("PolicyRead", {
				player = player.UserId,
				restricted = read.restricted,
				tradingAllowed = read.tradingAllowed,
			})
			-- Lasso Pass owners the policy shuts out: log them, so support can explain why the pass
			-- does nothing for them.
			local profile = hooks.getData(player)
			if read.restricted and profile and PassEffects.owned(profile, "LassoPass") then
				hooks.log("LassoPassRestricted", { player = player.UserId })
			end
			sendFlags(player, hooks)
			return
		end
		attempt += 1
		hooks.log("PolicyFailed", { player = player.UserId, attempt = attempt })
		local waits = PurchaseConfig.POLICY_RETRY_SECONDS
		task.wait(waits[math.min(attempt, #waits)])
	end
end

-- Asks Roblox whether the player owns a pass, in a pcall. nil when it could not be told.
local function ownsPass(player: Player, id: PurchaseConfig.PassId): boolean?
	local gamePassId = PurchaseConfig.PASSES[id].id
	if gamePassId < 1 then
		return false -- not created yet
	end
	local ok, owns = pcall(function(): boolean
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamePassId)
	end)
	if not ok then
		return nil
	end
	return owns == true
end

-- Applies a pass the player owns, once, and saves. Returns true if it was new.
local function applyPass(player: Player, id: PurchaseConfig.PassId, hooks: Hooks): boolean
	local profile = hooks.getData(player)
	if not profile then
		return false
	end
	-- Roblox confirms ownership of a pass that was suspended: switch its effects back on.
	if PassEffects.isSuspended(profile, id) then
		PassEffects.resume(profile, id)
		sendFlags(player, hooks)
		hooks.log("PassResumed", { player = player.UserId, pass = id })
	end
	if not PassEffects.grant(profile, id) then
		return false
	end
	hooks.changed(player)
	hooks.save(player)
	sendFlags(player, hooks)
	hooks.log("PassGranted", {
		player = player.UserId,
		pass = id,
		capacity = profile.StableCapacity,
		pens = profile.Pens,
	})
	return true
end

-- Checks every pass with Roblox (used when the data loads, so a pass bought on the website or on
-- another server is there when the player arrives).
local function checkAllPasses(player: Player, hooks: Hooks)
	for _, id: PurchaseConfig.PassId in PurchaseConfig.PASS_IDS do
		if player.Parent ~= Players then
			return
		end
		local profile = hooks.getData(player)
		if profile == nil then
			return
		end
		local owns = ownsPass(player, id)
		if PassEffects.owned(profile, id) then
			-- Marked owned in the save. Only a clear "no" from Roblox (a refund or a revoked pass)
			-- switches its ongoing effects (catch bonus, faster hatching, title) off for this session;
			-- room and pens already given stay, so nothing is stranded. A failed call changes nothing.
			if owns == false and PurchaseConfig.PASSES[id].id >= 1 then
				if not PassEffects.isSuspended(profile, id) then
					PassEffects.suspend(profile, id)
					hooks.log("PassNotOwned", { player = player.UserId, pass = id })
					sendFlags(player, hooks)
				end
			elseif owns == true then
				PassEffects.resume(profile, id)
			end
		elseif owns == true then
			applyPass(player, id, hooks)
		end
	end
end

local function processReceipt(info: { [string]: any }, hooks: Hooks): Enum.ProductPurchaseDecision
	local notYet = Enum.ProductPurchaseDecision.NotProcessedYet
	local purchaseId = info.PurchaseId
	if typeof(purchaseId) ~= "string" or typeof(info.PlayerId) ~= "number" then
		hooks.log("ReceiptBad", { purchaseId = tostring(purchaseId) })
		return notYet
	end
	if not isOpen() then
		hooks.log("ReceiptWaiting", { purchaseId = purchaseId, why = "switch off" })
		return notYet
	end
	if handled[purchaseId] then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
	if inFlight[purchaseId] then
		return notYet -- Roblox asks again; the first call is still working
	end
	local player = Players:GetPlayerByUserId(info.PlayerId)
	if not player then
		return notYet -- granted when they next join
	end
	inFlight[purchaseId] = true
	local decision = notYet
	local ok, problem = pcall(function(): string?
		-- Wait for the player's data to load; give up if they leave.
		local profile = hooks.getData(player)
		while profile == nil and player.Parent == Players do
			task.wait(0.25)
			profile = hooks.getData(player)
		end
		if profile == nil then
			return nil
		end
		local outcome = Purchases.process(profile, info :: any)
		if outcome.decision == "Refused" then
			hooks.log("ReceiptRefused", {
				player = player.UserId,
				purchaseId = purchaseId,
				productId = info.ProductId,
				note = outcome.note,
			})
			return nil
		end
		if outcome.decision == "Granted" then
			hooks.changed(player)
			for _, line in outcome.lines do
				hooks.log("GemGrant", {
					player = player.UserId,
					reason = line.reason,
					delta = line.delta,
					before = line.before,
					after = line.after,
					purchaseId = purchaseId,
				})
			end
			hooks.log("PurchaseGranted", {
				player = player.UserId,
				product = outcome.product,
				purchaseId = purchaseId,
				robux = info.CurrencySpent,
				repeatStarter = outcome.repeatStarter,
			})
		end
		-- Granted now or granted before: answer Roblox only once the record holding the id is saved.
		local function isSaved(saved: any): boolean
			local purchases = if typeof(saved) == "table" then saved.Purchases else nil
			local ids = if typeof(purchases) == "table" then purchases.receiptIds else nil
			return typeof(ids) == "table" and table.find(ids, purchaseId) ~= nil
		end
		if hooks.waitSaved(player, isSaved) then
			decision = Enum.ProductPurchaseDecision.PurchaseGranted
			if handledCount >= MAX_HANDLED then
				table.clear(handled)
				handledCount = 0
			end
			handled[purchaseId] = true
			handledCount += 1
			hooks.notify(player, "Your purchase arrived. Thank you!")
		end
		return nil
	end)
	inFlight[purchaseId] = nil
	if not ok then
		hooks.log("ReceiptFailed", { purchaseId = purchaseId, problem = tostring(problem) })
		return notYet
	end
	return decision
end

local function tooFast(last: { [Player]: number }, player: Player, seconds: number): boolean
	local now = os.clock()
	if now - (last[player] or -math.huge) < seconds then
		return true
	end
	last[player] = now
	return false
end

function PurchaseService.start(hooks: Hooks)
	-- The one receipt handler (Roblox allows only one, set from one server script).
	MarketplaceService.ProcessReceipt = function(info)
		return processReceipt(info :: any, hooks)
	end

	-- A pass purchase finished in the prompt: ask Roblox, do not trust `wasPurchased` alone.
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(
		function(player, gamePassId, wasPurchased)
			local id = passByRobloxId(gamePassId)
			if not wasPurchased or id == nil then
				return
			end
			local who = player :: Player
			local pass = id :: any -- (the analyzer reads a pass key from another module as plain text)
			task.spawn(function()
				for attempt = 1, PurchaseConfig.PASS_CHECK_TRIES do
					if who.Parent ~= Players then
						return
					end
					if ownsPass(who, pass) == true then
						applyPass(who, pass, hooks)
						return
					end
					task.wait(PurchaseConfig.PASS_CHECK_WAIT * attempt)
				end
				hooks.log("PassNotConfirmed", { player = who.UserId, pass = pass })
			end)
		end
	)

	-- The device asks to see a prompt; the server decides whether to open it.
	Net.PromptPurchase.On(function(player, value)
		if tooFast(lastPrompt, player, PurchaseConfig.PROMPT_COOLDOWN) then
			return
		end
		local profile = hooks.getData(player)
		if not profile then
			return
		end
		if not isOpen() then
			return hooks.notify(player, LiveConfigService.closedText())
		end
		local passId = passByName(value.Id)
		local productId = productByName(value.Id)
		if passId == nil and productId == nil then
			return
		end
		if passId ~= nil then
			local id = passId :: any
			local def = PurchaseConfig.PASSES[id]
			if def.id < 1 then
				return hooks.notify(player, "That is not for sale yet")
			end
			if PassEffects.owned(profile, id) and not PassEffects.isSuspended(profile, id) then
				return hooks.notify(player, "You already have that")
			end
			-- Offered only where paid random items are allowed (and never while PolicyService has
			-- not answered).
			if def.lassoBoost and PurchaseService.paidRandomRestricted(player) then
				return hooks.notify(player, "That is not available to you")
			end
			pcall(function()
				MarketplaceService:PromptGamePassPurchase(player, def.id)
			end)
		elseif productId ~= nil then
			local def = PurchaseConfig.PRODUCTS[productId]
			if def.id < 1 then
				return hooks.notify(player, "That is not for sale yet")
			end
			if def.kind == "Starter" and Purchases.starterBought(profile) then
				return hooks.notify(player, "You already have that")
			end
			pcall(function()
				MarketplaceService:PromptProductPurchase(player, def.id)
			end)
		end
		hooks.log("PurchasePrompted", { player = player.UserId, id = value.Id })
	end)

	-- Finishing an egg with Gems.
	Net.FinishEgg.On(function(player, value)
		if tooFast(lastFinish, player, PurchaseConfig.FINISH_EGG_COOLDOWN) then
			return
		end
		local profile = hooks.getData(player)
		if not profile then
			return
		end
		if not (isOpen() and LiveConfigService.isOn("shop_open")) then
			return hooks.notify(player, LiveConfigService.closedText())
		end
		local done, problem = Gems.finishEgg(profile, value.HatchAt, os.time())
		if not done then
			return hooks.notify(player, problem or "That egg cannot be finished now")
		end
		hooks.changed(player)
		hooks.save(player)
		hooks.log("GemSpend", {
			player = player.UserId,
			item = "egg",
			gems = done.gems,
			secondsLeft = done.secondsLeft,
			reason = done.line.reason,
			before = done.line.before,
			after = done.line.after,
		})
	end)

	Players.PlayerRemoving:Connect(function(player)
		policies[player] = nil
		lastPrompt[player] = nil
		lastFinish[player] = nil
	end)
end

-- Called when a player's data is ready: reads their policy and checks their passes. Does not
-- yield (it starts its own threads).
function PurchaseService.onLoaded(player: Player, hooks: Hooks)
	sendFlags(player, hooks)
	task.spawn(fetchPolicy, player, hooks)
	task.spawn(checkAllPasses, player, hooks)
end

return PurchaseService
