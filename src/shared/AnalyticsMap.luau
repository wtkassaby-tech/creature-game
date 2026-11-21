--!strict
-- Turns the server's own log lines into what Roblox's analytics should be told. Pure: it only
-- decides what to report. The server module that makes the real calls is
-- src/server/Analytics/AnalyticsFeed.
--
-- Three kinds of report:
--  - Onboarding: a step of the first-session funnel (joining, then each beat of chapter 1), so
--    the dashboard shows where new players drop out.
--  - Economy: coins, candy or Prism Candy entering (Source) or leaving (Sink) a player's hands.
--  - Custom: a count of something worth watching (catches, hatches, lost battles, badges).

local AnalyticsConfig = require("../config/AnalyticsConfig")
local Profile = require("./Profile")
local Story = require("../content/Story")
local WorldTypes = require("./WorldTypes")

export type Flow = "Source" | "Sink"
export type Currency = "Coins" | "Candy" | "Prism"
-- Roblox's own transaction names (Enum.AnalyticsEconomyTransactionType).
export type Transaction = "Shop" | "Gameplay" | "TimedReward" | "Onboarding"
export type Call = {
	kind: "Onboarding" | "Economy" | "Custom",
	name: string, -- the step's name, the item or source the currency moved for, or the event's name
	step: number?, -- Onboarding
	flow: Flow?, -- Economy
	currency: Currency?, -- Economy
	amount: number?, -- Economy: always above zero
	transaction: Transaction?, -- Economy
	value: number?, -- Custom
}
export type Fields = { [string]: any }

local AnalyticsMap = {}

local function chapters(): { WorldTypes.Chapter }
	local list: { WorldTypes.Chapter } = {}
	for _, chapter in Story do
		table.insert(list, chapter)
	end
	table.sort(list, function(a, b)
		return a.number < b.number
	end)
	return list
end

-- The first-session funnel's steps, in order: joining, then each beat of chapter 1.
function AnalyticsMap.onboardingSteps(): { string }
	local steps: { string } = { AnalyticsConfig.FIRST_STEP_NAME }
	for _, chapter in chapters() do
		if chapter.number == AnalyticsConfig.ONBOARDING_CHAPTER then
			for _, beat in chapter.beats do
				table.insert(steps, beat.name)
			end
		end
	end
	return steps
end

local function amountOf(value: any): number?
	if typeof(value) ~= "number" or value ~= value or value <= 0 or value == math.huge then
		return nil
	end
	return value
end

-- Typed candy paid for a breed is logged as a list of parts, one per type.
local function sumOfParts(value: any): number
	if typeof(value) == "number" then
		return value
	end
	local total = 0
	if typeof(value) == "table" then
		for _, part in value :: { any } do
			if typeof(part) == "table" then
				total += amountOf((part :: any).amount) or 0
			end
		end
	end
	return total
end

local function money(
	calls: { Call },
	flow: Flow,
	currency: Currency,
	value: any,
	transaction: Transaction,
	name: string
)
	local amount = amountOf(value)
	if amount then
		table.insert(calls, {
			kind = "Economy",
			name = name,
			flow = flow,
			currency = currency,
			amount = amount,
			transaction = transaction,
		})
	end
end

local function count(calls: { Call }, name: string, value: number?)
	table.insert(calls, { kind = "Custom", name = name, value = value or 1 })
end

local function storyBeat(calls: { Call }, beatId: any)
	if typeof(beatId) ~= "string" then
		return
	end
	for _, chapter in chapters() do
		for index, beat in chapter.beats do
			if beat.id == beatId then
				if chapter.number == AnalyticsConfig.ONBOARDING_CHAPTER then
					table.insert(calls, { kind = "Onboarding", name = beat.name, step = index + 1 })
				end
				if index == #chapter.beats then
					count(calls, `Chapter{chapter.number}Done`)
				end
				return
			end
		end
	end
end

-- What to report for one log line. Most log lines report nothing.
function AnalyticsMap.translate(event: string, fields: Fields): { Call }
	local calls: { Call } = {}
	if event == "DataLoaded" then
		if fields.sessions == 1 then
			table.insert(
				calls,
				{ kind = "Onboarding", name = AnalyticsConfig.FIRST_STEP_NAME, step = 1 }
			)
		end
	elseif event == "StoryBeat" then
		storyBeat(calls, fields.beat)
	elseif event == "Bought" then
		local item: string = if typeof(fields.item) == "string" then fields.item else "Item"
		money(calls, "Sink", "Coins", fields.coins, "Shop", item)
	elseif event == "StableExpanded" then
		money(calls, "Sink", "Coins", fields.coins, "Shop", "StableRoom")
	elseif event == "Breed" then
		money(calls, "Sink", "Coins", fields.cost, "Gameplay", "Breed")
		money(calls, "Sink", "Candy", sumOfParts(fields.candyTyped), "Gameplay", "Breed")
		money(calls, "Sink", "Prism", fields.candyPrism, "Gameplay", "Breed")
	elseif event == "BattleRewards" then
		money(calls, "Source", "Coins", fields.coins, "Gameplay", "Battle")
	elseif event == "DailyClaimed" then
		money(calls, "Source", "Coins", fields.coins, "TimedReward", "DailyTask")
		money(calls, "Source", "Prism", fields.prism, "TimedReward", "DailyTask")
	elseif event == "Release" then
		money(calls, "Source", "Coins", fields.coins, "Gameplay", "Release")
	elseif event == "GiantWon" then
		money(calls, "Source", "Prism", fields.prism, "Gameplay", "Giant")
		count(calls, if fields.first == true then "GiantFirstWin" else "GiantRematchWin")
	elseif event == "Capture" then
		money(calls, "Source", "Candy", fields.candy, "Gameplay", "Capture")
		count(calls, "Capture")
	elseif event == "Hatch" then
		count(calls, "Hatch")
	elseif event == "QuestDone" then
		count(calls, "QuestDone")
	elseif event == "WokeAtHealer" then
		count(calls, "TeamFainted")
	elseif event == "BiomeReached" then
		local biome = amountOf(fields.biome)
		if biome and biome % 1 == 0 and biome <= 20 then
			count(calls, `Biome{biome}Reached`)
		end
	elseif event == "BattleFinished" then
		if fields.ending == "Lost" and typeof(fields.kind) == "string" then
			count(calls, "BattleLost")
		end
	end
	return calls
end

-- A player's balance of one currency, for the economy report that follows a change. Typed
-- candy is reported as one currency, all types together.
function AnalyticsMap.balance(profile: Profile.Profile, currency: Currency): number
	if currency == "Coins" then
		return profile.Coins
	elseif currency == "Prism" then
		return profile.Candy.prism
	end
	local total = 0
	for _, amount in profile.Candy.typed :: { [string]: number } do
		total += amount
	end
	return total
end

-- How many requests this server may send in a minute with `players` players in it.
function AnalyticsMap.budget(players: number): number
	return AnalyticsConfig.REQUESTS_A_MINUTE
		+ AnalyticsConfig.REQUESTS_A_MINUTE_PER_PLAYER * math.max(0, players)
end

return AnalyticsMap
