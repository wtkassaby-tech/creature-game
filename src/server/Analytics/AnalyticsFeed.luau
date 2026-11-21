--!strict
-- Reports to Roblox's analytics. Every line the server logs comes through here; the pure rules
-- in src/shared/AnalyticsMap decide what, if anything, to report for it. A failed or refused
-- report never stops the game: analytics is something to read later, not something to rely on.
-- Roblox takes these reports only from the server of a published game, so nothing is sent in
-- Studio. The calls are the ones in the AnalyticsService reference (LogOnboardingFunnelStepEvent,
-- LogEconomyEvent, LogCustomEvent), checked on 21 November 2026.
-- Not yet run in a published game.

local AnalyticsService = game:GetService("AnalyticsService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local AnalyticsMap = require(ReplicatedStorage.shared.AnalyticsMap)

-- The player's balance of a currency after the change, which an economy report must carry.
export type Balance = (player: Player, currency: AnalyticsMap.Currency) -> number?

local AnalyticsFeed = {}

local balanceOf: Balance? = nil
local inStudio = RunService:IsStudio()
local windowStart = os.clock()
local sentThisMinute = 0
local dropped = 0

-- Keeps this server under its own request budget, which is well under Roblox's.
local function mayPost(): boolean
	local now = os.clock()
	if now - windowStart >= 60 then
		if dropped > 0 then
			warn(`[AnalyticsFeed] {dropped} reports were dropped in the last minute`)
		end
		windowStart, sentThisMinute, dropped = now, 0, 0
	end
	if sentThisMinute >= AnalyticsMap.budget(#Players:GetPlayers()) then
		dropped += 1
		return false
	end
	sentThisMinute += 1
	return true
end

local function post(player: Player, call: AnalyticsMap.Call)
	if call.kind == "Onboarding" then
		AnalyticsService:LogOnboardingFunnelStepEvent(player, call.step or 1, call.name)
	elseif call.kind == "Custom" then
		AnalyticsService:LogCustomEvent(player, call.name, call.value or 1)
	elseif call.kind == "Economy" then
		local currency: AnalyticsMap.Currency? = call.currency
		local amount = call.amount
		if not currency or not amount or not balanceOf then
			return
		end
		local balance = balanceOf(player, currency)
		if balance == nil then
			return
		end
		local flow = if call.flow == "Sink"
			then Enum.AnalyticsEconomyFlowType.Sink
			else Enum.AnalyticsEconomyFlowType.Source
		AnalyticsService:LogEconomyEvent(
			player,
			flow,
			currency,
			amount,
			math.max(0, balance),
			call.transaction or "Gameplay",
			call.name
		)
	end
end

function AnalyticsFeed.start(balance: Balance)
	balanceOf = balance
end

local function report(event: string, fields: { [string]: any })
	local userId = fields.player
	if typeof(userId) ~= "number" then
		return
	end
	local calls = AnalyticsMap.translate(event, fields)
	if #calls == 0 then
		return
	end
	local player = Players:GetPlayerByUserId(userId)
	if not player then
		return
	end
	for _, call in calls do
		if mayPost() then
			post(player, call)
		end
	end
end

-- Called for every server log line. `fields.player` is the player's user id when the line is
-- about a player; lines about nobody in particular report nothing. Nothing in here can throw
-- into the game logic that logged the line.
function AnalyticsFeed.record(event: string, fields: { [string]: any })
	if inStudio then
		return
	end
	local ok, problem = pcall(function(): string?
		report(event, fields)
		return nil
	end)
	if not ok then
		warn(`[AnalyticsFeed] {event}: {problem}`)
	end
end

return AnalyticsFeed
