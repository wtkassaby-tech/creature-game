--!strict
-- Daily tasks on the server: counts what other services saw, and pays a finished task when the
-- player claims it. The rules are in src/shared/DailyProgress.
-- Not yet run in Studio.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DailyProgress = require(ReplicatedStorage.shared.DailyProgress)
local DailyTasks = require(ReplicatedStorage.content.DailyTasks)
local Net = require(ReplicatedStorage.net.generated.Server)
local Profile = require(ReplicatedStorage.shared.Profile)
local LiveConfigService = require(script.Parent.Parent.LiveConfig.LiveConfigService)

local MIN_SECONDS_BETWEEN_CLAIMS = 0.3

export type Hooks = {
	getData: (player: Player) -> Profile.Profile?,
	changed: (player: Player) -> (),
	notify: (player: Player, text: string) -> (),
	log: (event: string, fields: { [string]: any }) -> (),
}

local DailyService = {}

local hooks: Hooks
local lastClaim: { [Player]: number } = {}

-- Counts something the server saw toward today's tasks. Never stops what comes after it.
function DailyService.record(player: Player, counts: DailyTasks.Counts)
	local profile = hooks.getData(player)
	if not profile then
		return
	end
	local ok, ready = pcall(DailyProgress.record, profile, counts, os.time())
	if not ok then
		hooks.log("DailyRecordFailed", { player = player.UserId, problem = tostring(ready) })
		return
	end
	hooks.changed(player)
	for _, task in ready :: { DailyTasks.Task } do
		hooks.notify(player, `Daily task done: {task.goal}. Claim your reward!`)
	end
end

function DailyService.start(given: Hooks): () -> ()
	hooks = given
	local stopClaim = Net.ClaimDailyTask.On(function(player, value)
		local now = os.clock()
		if now - (lastClaim[player] or -math.huge) < MIN_SECONDS_BETWEEN_CLAIMS then
			return
		end
		lastClaim[player] = now
		local profile = hooks.getData(player)
		if not profile then
			return
		end
		if not LiveConfigService.isOn("daily_rewards_open") then
			return hooks.notify(player, LiveConfigService.closedText())
		end
		local claimed, problem = DailyProgress.claim(profile, value.TaskId, os.time())
		if not claimed then
			return hooks.notify(player, problem or "That cannot be claimed")
		end
		hooks.changed(player)
		hooks.notify(
			player,
			`{claimed.task.goal}: +{claimed.coins} coins, +{claimed.prism} Prism Candy`
		)
		hooks.log("DailyClaimed", {
			player = player.UserId,
			task = claimed.task.id,
			coins = claimed.coins,
			prism = claimed.prism,
		})
	end)
	local leaving = Players.PlayerRemoving:Connect(function(player)
		lastClaim[player] = nil
	end)
	return function()
		stopClaim()
		leaving:Disconnect()
	end
end

return DailyService
