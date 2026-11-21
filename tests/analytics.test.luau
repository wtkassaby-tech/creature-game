--!strict
-- Checks for what the game reports to Roblox's analytics.
-- Run from the project folder:  lune run tests/analytics.test

local AnalyticsConfig = require("../src/config/AnalyticsConfig")
local AnalyticsMap = require("../src/shared/AnalyticsMap")
local Profile = require("../src/shared/Profile")
local Story = require("../src/content/Story")

local passed, failed = 0, 0
local function check(name: string, condition: boolean, detail: string?)
	if condition then
		passed += 1
	else
		failed += 1
	end
	print(
		`  {if condition then "PASS" else "FAIL"}  {name}{if detail
			then "  (" .. detail .. ")"
			else ""}`
	)
end

print("\n== The first-session funnel ==")
do
	local steps = AnalyticsMap.onboardingSteps()
	local chapter1 = Story.chapter_1
	check(
		"joining is step 1 and every beat of chapter 1 follows, in order",
		#steps == #chapter1.beats + 1 and steps[1] == AnalyticsConfig.FIRST_STEP_NAME,
		`{#steps} steps`
	)
	check("the funnel fits Roblox's limit of 100 steps", #steps <= 100)
	local joined = AnalyticsMap.translate("DataLoaded", { player = 1, sessions = 1, problems = 0 })
	check(
		"a first join reports step 1",
		#joined == 1 and joined[1].kind == "Onboarding" and joined[1].step == 1
	)
	check(
		"a later join reports nothing",
		#AnalyticsMap.translate("DataLoaded", { player = 1, sessions = 2, problems = 0 }) == 0
	)
	local inOrder, seen = true, {}
	for index, beat in chapter1.beats do
		local calls = AnalyticsMap.translate("StoryBeat", { player = 1, beat = beat.id })
		local step: AnalyticsMap.Call? = nil
		for _, call in calls do
			if call.kind == "Onboarding" then
				step = call
			end
		end
		if not step or step.step ~= index + 1 or step.name ~= beat.name or seen[step.name] then
			inOrder = false
		end
		if step then
			seen[step.name] = true
		end
	end
	check("each beat of chapter 1 is its own step, numbered in story order", inOrder)
	local last = chapter1.beats[#chapter1.beats]
	local finished = AnalyticsMap.translate("StoryBeat", { player = 1, beat = last.id })
	local chapterDone = false
	for _, call in finished do
		chapterDone = chapterDone or (call.kind == "Custom" and call.name == "Chapter1Done")
	end
	check("the last beat of a chapter also counts the chapter as done", chapterDone)
	local later =
		AnalyticsMap.translate("StoryBeat", { player = 1, beat = Story.chapter_2.beats[1].id })
	check("beats of later chapters are not funnel steps", #later == 0)
	check(
		"a beat that does not exist reports nothing",
		#AnalyticsMap.translate("StoryBeat", { player = 1, beat = "nope" }) == 0
			and #AnalyticsMap.translate("StoryBeat", { player = 1, beat = 7 }) == 0
	)
end

print("\n== Coins and candy ==")
do
	local bought =
		AnalyticsMap.translate("Bought", { player = 1, item = "Tonic", count = 2, coins = 80 })
	check(
		"buying is coins leaving through the shop, named by the item",
		#bought == 1
			and bought[1].kind == "Economy"
			and bought[1].flow == "Sink"
			and bought[1].currency == "Coins"
			and bought[1].amount == 80
			and bought[1].transaction == "Shop"
			and bought[1].name == "Tonic"
	)
	local breed = AnalyticsMap.translate("Breed", {
		player = 1,
		cost = 400,
		candyTyped = { { element = "Leaf", amount = 3 }, { element = "Sand", amount = 2 } },
		candyPrism = 1,
	})
	local coins, candy, prism = 0, 0, 0
	for _, call in breed do
		if call.currency == "Coins" then
			coins = call.amount or 0
		elseif call.currency == "Candy" then
			candy = call.amount or 0
		elseif call.currency == "Prism" then
			prism = call.amount or 0
		end
	end
	check(
		"a breed reports its coins, its typed candy as one total, and its Prism Candy",
		coins == 400 and candy == 5 and prism == 1,
		`{coins} coins, {candy} candy, {prism} prism`
	)
	local reward = AnalyticsMap.translate("BattleRewards", { player = 1, coins = 25 })
	check(
		"a battle reward is coins coming in",
		#reward == 1 and reward[1].flow == "Source" and reward[1].amount == 25
	)
	check(
		"nothing is reported for a zero, negative or broken amount",
		#AnalyticsMap.translate("BattleRewards", { player = 1, coins = 0 }) == 0
			and #AnalyticsMap.translate("BattleRewards", { player = 1, coins = -5 }) == 0
			and #AnalyticsMap.translate("BattleRewards", { player = 1, coins = 0 / 0 }) == 0
			and #AnalyticsMap.translate("BattleRewards", { player = 1, coins = "25" }) == 0
			and #AnalyticsMap.translate("BattleRewards", { player = 1 }) == 0
	)
	local daily =
		AnalyticsMap.translate("DailyClaimed", { player = 1, task = "t", coins = 100, prism = 1 })
	check(
		"a daily task is a timed reward of coins and Prism Candy",
		#daily == 2 and daily[1].transaction == "TimedReward" and daily[2].currency == "Prism"
	)

	local profile = Profile.template()
	profile.Coins = 321
	profile.Candy.prism = 4
	profile.Candy.typed.Leaf = 2
	profile.Candy.typed.Water = 5
	check(
		"balances: coins, Prism Candy, and typed candy added together",
		AnalyticsMap.balance(profile, "Coins") == 321
			and AnalyticsMap.balance(profile, "Prism") == 4
			and AnalyticsMap.balance(profile, "Candy") == 7
	)
end

print("\n== Counts, and staying inside Roblox's limits ==")
do
	check(
		"a catch counts once",
		(function(): boolean
			local calls = AnalyticsMap.translate("Capture", { player = 1, candy = 0 })
			return #calls == 1 and calls[1].kind == "Custom" and calls[1].name == "Capture"
		end)()
	)
	check(
		"only lost battles are counted, not every battle",
		#AnalyticsMap.translate(
					"BattleFinished",
					{ player = 1, kind = "Wild", ending = "Won" }
				)
				== 0
			and #AnalyticsMap.translate(
					"BattleFinished",
					{ player = 1, kind = "Wild", ending = "Lost" }
				)
				== 1
	)
	check(
		"log lines that are not about play report nothing",
		#AnalyticsMap.translate("SerialAlarm", { kind = "Gem" }) == 0
			and #AnalyticsMap.translate("LassoInvalid", { player = 1, reason = "x" }) == 0
			and #AnalyticsMap.translate("Anything", {}) == 0
	)
	-- Every name the game can ever report, to hold it under Roblox's limits.
	local events: { [string]: boolean } = {}
	local items: { [string]: boolean } = {}
	local currencies: { [string]: boolean } = {}
	local function gather(calls: { AnalyticsMap.Call })
		for _, call in calls do
			if call.kind == "Custom" then
				events[call.name] = true
			elseif call.kind == "Economy" then
				items[call.name] = true
				currencies[call.currency or "?"] = true
			end
		end
	end
	for _, chapter in Story do
		for _, beat in chapter.beats do
			gather(AnalyticsMap.translate("StoryBeat", { player = 1, beat = beat.id }))
		end
	end
	for biome = 1, 11 do
		gather(AnalyticsMap.translate("BiomeReached", { player = 1, biome = biome }))
	end
	for _, item in require("../src/config/EconomyConfig").ITEM_IDS do
		gather(AnalyticsMap.translate("Bought", { player = 1, item = item, coins = 1 }))
	end
	gather(AnalyticsMap.translate("StableExpanded", { player = 1, coins = 1 }))
	gather(
		AnalyticsMap.translate("Breed", { player = 1, cost = 1, candyTyped = 1, candyPrism = 1 })
	)
	gather(AnalyticsMap.translate("BattleRewards", { player = 1, coins = 1 }))
	gather(AnalyticsMap.translate("DailyClaimed", { player = 1, coins = 1, prism = 1 }))
	gather(AnalyticsMap.translate("Release", { player = 1, coins = 1 }))
	gather(AnalyticsMap.translate("GiantWon", { player = 1, first = true, prism = 1 }))
	gather(AnalyticsMap.translate("GiantWon", { player = 1, first = false, prism = 1 }))
	gather(AnalyticsMap.translate("Capture", { player = 1, candy = 1 }))
	gather(AnalyticsMap.translate("Hatch", { player = 1 }))
	gather(AnalyticsMap.translate("QuestDone", { player = 1 }))
	gather(AnalyticsMap.translate("WokeAtHealer", { player = 1 }))
	gather(AnalyticsMap.translate("BattleFinished", { player = 1, kind = "Wild", ending = "Lost" }))
	local function size(set: { [string]: boolean }): number
		local n = 0
		for _ in set do
			n += 1
		end
		return n
	end
	check(
		"at most 100 custom event names, with room for all eleven biomes",
		size(events) <= 60,
		`{size(events)}`
	)
	check("at most 100 item names", size(items) <= 60, `{size(items)}`)
	check("at most 10 currencies", size(currencies) <= 5, `{size(currencies)}`)
	check(
		"a biome number that makes no sense is not turned into an event name",
		#AnalyticsMap.translate("BiomeReached", { player = 1, biome = 2.5 }) == 0
			and #AnalyticsMap.translate("BiomeReached", { player = 1, biome = 999 }) == 0
	)
	check(
		"the request budget grows with the players in the server and stays under Roblox's",
		AnalyticsMap.budget(0) <= 120
			and AnalyticsMap.budget(30) < 120 + 20 * 30
			and AnalyticsMap.budget(30) > AnalyticsMap.budget(1)
	)
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("analytics checks failed")
end
