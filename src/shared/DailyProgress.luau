--!strict
-- Daily tasks, as pure rules (approval pack 3): count what the server saw today, and pay a
-- finished task once. The counts and the "paid" marks live in the profile's Daily record,
-- which the server's date resets, so leaving or changing a device's clock resets nothing.
-- Tasks open with the first badge.

local DailyTasks = require("../content/DailyTasks")
local Economy = require("./Economy")
local Grants = require("./Grants")
local Profile = require("./Profile")

export type Claimed = { task: DailyTasks.Task, coins: number, prism: number }
export type View = {
	id: string,
	hard: boolean,
	goal: string,
	progress: number,
	count: number,
	claimed: boolean,
}

local DailyProgress = {}

local function progressKey(id: string): string
	return `task:{id}`
end

local function find(taskId: unknown): DailyTasks.Task?
	for _, task in DailyTasks do
		if task.id == taskId then
			return task
		end
	end
	return nil
end

function DailyProgress.isOpen(profile: Profile.Profile): boolean
	return Economy.dailyTasksOpen(profile.Story.badges)
end

-- Counts something the server saw toward every task that counts it. Returns the tasks that
-- have just become ready to claim.
function DailyProgress.record(
	profile: Profile.Profile,
	counts: DailyTasks.Counts,
	unixTime: number
): { DailyTasks.Task }
	local ready: { DailyTasks.Task } = {}
	if not DailyProgress.isOpen(profile) then
		return ready
	end
	Grants.rollDay(profile, unixTime)
	for _, task in DailyTasks do
		if task.counts == counts then
			local key = progressKey(task.id)
			local before = profile.Daily.tasksDone[key] or 0
			if before < task.count then
				profile.Daily.tasksDone[key] = before + 1
				if before + 1 >= task.count then
					table.insert(ready, task)
				end
			end
		end
	end
	return ready
end

-- Today's tasks as the screen shows them. Read-only: it never changes the profile. If the saved
-- counters belong to an earlier day, the tasks show as fresh (the counters themselves roll over
-- the next time something is counted, claimed or loaded).
function DailyProgress.view(profile: Profile.Profile, unixTime: number): { View }
	local list: { View } = {}
	if not DailyProgress.isOpen(profile) then
		return list
	end
	local today = profile.Daily.day >= math.floor(unixTime / 86400)
	for _, task in DailyTasks do
		local key = progressKey(task.id)
		table.insert(list, {
			id = task.id,
			hard = task.hard,
			goal = task.goal,
			progress = if today then math.min(task.count, profile.Daily.tasksDone[key] or 0) else 0,
			count = task.count,
			claimed = today and profile.Daily.claimed[key] == true,
		})
	end
	return list
end

-- Pays one finished, unpaid task from the counters as they stand.
local function pay(profile: Profile.Profile, task: DailyTasks.Task): Claimed
	-- How many of this kind (easy or hard) have been paid today decides what this one pays;
	-- the economy's caps apply even if more tasks are ever added.
	local paidToday = 0
	for _, other in DailyTasks do
		if other.hard == task.hard and profile.Daily.claimed[progressKey(other.id)] then
			paidToday += 1
		end
	end
	local coins = Economy.dailyTaskCoins(task.hard, profile.Story.biomeReached, paidToday)
	local prism = Economy.candyFor(if task.hard then "DailyHardTask" else "DailyTask", paidToday)
	profile.Daily.claimed[progressKey(task.id)] = true
	profile.Coins += coins
	profile.Candy.prism += prism
	return { task = task, coins = coins, prism = prism }
end

-- When the day ends, tasks that were finished but not claimed are paid, not lost. This runs
-- just before the day's counters are cleared, wherever that happens (Grants.rollDay).
Grants.beforeRoll = function(profile: Profile.Profile)
	if not DailyProgress.isOpen(profile) then
		return
	end
	for _, task in DailyTasks do
		local key = progressKey(task.id)
		if not profile.Daily.claimed[key] and (profile.Daily.tasksDone[key] or 0) >= task.count then
			pay(profile, task)
		end
	end
end

-- Pays a finished task, once. `taskId` comes from the device.
function DailyProgress.claim(
	profile: Profile.Profile,
	taskId: unknown,
	unixTime: number
): (Claimed?, string?)
	local task = find(taskId)
	if not task then
		return nil, "There is no such task"
	end
	if not DailyProgress.isOpen(profile) then
		return nil, "Daily tasks open with your first badge"
	end
	Grants.rollDay(profile, unixTime)
	local key = progressKey(task.id)
	if profile.Daily.claimed[key] then
		return nil, "You have already claimed that today"
	end
	if (profile.Daily.tasksDone[key] or 0) < task.count then
		return nil, "That task is not finished yet"
	end
	return pay(profile, task), nil
end

return DailyProgress
