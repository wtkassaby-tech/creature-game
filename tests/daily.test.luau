--!strict
-- Checks for daily tasks.
-- Run from the project folder:  lune run tests/daily.test

local DailyProgress = require("../src/shared/DailyProgress")
local DailyTasks = require("../src/content/DailyTasks")
local EconomyConfig = require("../src/config/EconomyConfig")
local Profile = require("../src/shared/Profile")

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

local DAY = 86400 * 300

print("\n== Before the first badge ==")
do
	local profile = Profile.template()
	DailyProgress.record(profile, "WinBattle", DAY)
	check("nothing is counted", next(profile.Daily.tasksDone) == nil)
	check("no tasks are shown", #DailyProgress.view(profile, DAY) == 0)
	check("nothing can be claimed", DailyProgress.claim(profile, "win_three", DAY) == nil)
end

print("\n== Counting and claiming ==")
do
	local profile = Profile.template()
	profile.Story.badges = 1
	check(
		"three easy and three harder tasks are shown",
		(function()
			local easy, hard = 0, 0
			for _, task in DailyProgress.view(profile, DAY) do
				if task.hard then
					hard += 1
				else
					easy += 1
				end
			end
			return easy == 3 and hard == 3
		end)()
	)
	check(
		"a made-up task is refused",
		DailyProgress.claim(profile, "free_coins", DAY) == nil
			and DailyProgress.claim(profile, 7, DAY) == nil
	)
	check(
		"an unfinished task cannot be claimed",
		DailyProgress.claim(profile, "win_three", DAY) == nil
	)
	DailyProgress.record(profile, "WinBattle", DAY)
	DailyProgress.record(profile, "Tame", DAY)
	DailyProgress.record(profile, "WinBattle", DAY)
	local ready = DailyProgress.record(profile, "WinBattle", DAY)
	check("the third win makes the task ready", #ready == 1 and ready[1].id == "win_three")
	for _ = 1, 10 do
		DailyProgress.record(profile, "WinBattle", DAY)
	end
	check("progress stops at what is needed", profile.Daily.tasksDone["task:win_three"] == 3)

	local coins, prism = profile.Coins, profile.Candy.prism
	local claimed = assert(DailyProgress.claim(profile, "win_three", DAY), "claim pays")
	check(
		"claiming pays coins and Prism Candy",
		claimed.coins == EconomyConfig.DAILY_TASK_COINS
			and claimed.prism == EconomyConfig.CANDY.DailyTask.perClaim
			and profile.Coins == coins + claimed.coins
			and profile.Candy.prism == prism + claimed.prism
	)
	check(
		"a task cannot be claimed twice",
		DailyProgress.claim(profile, "win_three", DAY) == nil
			and profile.Coins == coins + claimed.coins
	)
	check(
		"the screen shows it as claimed",
		(function()
			for _, task in DailyProgress.view(profile, DAY) do
				if task.id == "win_three" then
					return task.claimed and task.progress == 3
				end
			end
			return false
		end)()
	)

	DailyProgress.record(profile, "GiantRematch", DAY)
	local hard = assert(DailyProgress.claim(profile, "giant_again", DAY), "hard claim pays")
	check(
		"a harder task pays more coins",
		hard.coins == EconomyConfig.DAILY_HARD_TASK_COINS and hard.coins > claimed.coins
	)

	local total = 0
	for _, task in DailyTasks do
		for _ = 1, task.count do
			DailyProgress.record(profile, task.counts, DAY)
		end
		local paid = DailyProgress.claim(profile, task.id, DAY)
		total += if paid then paid.prism else 0
	end
	local cap = EconomyConfig.CANDY.DailyTask.cap * EconomyConfig.CANDY.DailyTask.perClaim
		+ EconomyConfig.CANDY.DailyHardTask.cap * EconomyConfig.CANDY.DailyHardTask.perClaim
	check(
		"a whole day of tasks pays no more Prism than the economy's daily cap",
		total + claimed.prism + hard.prism == cap,
		`{total + claimed.prism + hard.prism} of {cap}`
	)

	local tomorrow = DAY + 86400
	check(
		"the next day by the server's clock starts again",
		(function()
			for _, task in DailyProgress.view(profile, tomorrow) do
				if task.progress ~= 0 or task.claimed then
					return false
				end
			end
			return true
		end)()
	)
	check(
		"yesterday's finished task cannot be claimed today",
		DailyProgress.claim(profile, "tame_one", tomorrow) == nil
	)
	check(
		"the record is sound",
		#Profile.validate(profile) == 0,
		table.concat(Profile.validate(profile), "; ")
	)
end

print("\n== Review fixes ==")
do
	local profile = Profile.template()
	profile.Story.badges = 1
	DailyProgress.record(profile, "Tame", DAY)
	local coins, prism = profile.Coins, profile.Candy.prism
	local day = profile.Daily.day
	DailyProgress.view(profile, DAY + 86400)
	check(
		"looking at tomorrow's tasks changes nothing saved",
		profile.Daily.day == day and profile.Daily.tasksDone["task:tame_one"] == 1
	)
	check(
		"tomorrow's view shows fresh tasks",
		(function()
			for _, task in DailyProgress.view(profile, DAY + 86400) do
				if task.progress ~= 0 or task.claimed then
					return false
				end
			end
			return true
		end)()
	)
	DailyProgress.record(profile, "WinBattle", DAY + 86400)
	check(
		"a task finished but not claimed is paid when the day ends, not lost",
		profile.Coins == coins + EconomyConfig.DAILY_TASK_COINS and profile.Candy.prism == prism + 1
	)
	check(
		"and the new day starts counting from nothing",
		profile.Daily.tasksDone["task:win_three"] == 1
			and profile.Daily.tasksDone["task:tame_one"] == nil
	)

	local unfinished = Profile.template()
	unfinished.Story.badges = 1
	DailyProgress.record(unfinished, "WinBattle", DAY)
	local before = unfinished.Coins
	DailyProgress.record(unfinished, "WinBattle", DAY + 86400)
	check("an unfinished task pays nothing at the day's end", unfinished.Coins == before)

	local back = Profile.template()
	back.Story.badges = 1
	DailyProgress.record(back, "Tame", DAY + 86400)
	DailyProgress.record(back, "WinBattle", DAY) -- a server whose clock is a day behind
	check(
		"a clock that is behind neither pays early nor clears the day",
		back.Daily.tasksDone["task:tame_one"] == 1 and back.Coins == Profile.template().Coins
	)
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("daily task checks failed")
end
