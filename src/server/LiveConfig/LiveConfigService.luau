--!strict
-- The live switches on the server: asks Roblox's ConfigService for the values set on the
-- Creator Hub's Configs page and keeps them fresh. Until Roblox answers, and whenever it cannot
-- be reached, the defaults in src/config/LiveConfig apply, so a Roblox outage never closes the
-- game by itself. The calls are the ones in the ConfigService and ConfigSnapshot references
-- (GetConfigAsync, GetValue, Refresh, UpdateAvailable), checked on 21 November 2026.
-- Not yet run in Studio.

local ConfigService = game:GetService("ConfigService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LiveConfig = require(ReplicatedStorage.config.LiveConfig)
local Switches = require(ReplicatedStorage.shared.Switches)

export type Log = (event: string, fields: { [string]: any }) -> ()

local LiveConfigService = {}

local values: LiveConfig.Values = Switches.defaults()
local log: Log = function() end

local function apply(snapshot: ConfigSnapshot)
	local after = Switches.read(function(key: LiveConfig.Key): unknown
		local ok, value = pcall(function(): unknown
			return snapshot:GetValue(key)
		end)
		return if ok then value else nil
	end)
	for _, change in Switches.changes(values, after) do
		log("SwitchChanged", { key = change.key, on = change.on })
	end
	values = after
end

-- Is this part of the game switched on right now?
function LiveConfigService.isOn(key: LiveConfig.Key): boolean
	return values[key]
end

-- What to tell a player who asked for something that is switched off.
function LiveConfigService.closedText(): string
	return LiveConfig.CLOSED_TEXT
end

-- Asks Roblox for the live values, for as long as it takes.
local function fetch(): ConfigSnapshot
	local attempt = 0
	while true do
		local ok, result = pcall(function(): ConfigSnapshot
			return ConfigService:GetConfigAsync()
		end)
		if ok then
			return result
		end
		attempt += 1
		log("SwitchesUnreachable", { attempt = attempt, problem = tostring(result) })
		local waits = LiveConfig.RETRY_SECONDS
		task.wait(waits[math.min(attempt, #waits)])
	end
end

-- Starts fetching the live values. Returns at once; the game runs on the defaults until the
-- first answer arrives.
function LiveConfigService.start(logger: Log)
	log = logger
	task.spawn(function()
		local snapshot = fetch()
		apply(snapshot)
		snapshot.UpdateAvailable:Connect(function()
			local ok, problem = pcall(function(): string?
				snapshot:Refresh()
				return nil
			end)
			if ok then
				apply(snapshot)
			else
				log("SwitchesRefreshFailed", { problem = tostring(problem) })
			end
		end)
	end)
end

return LiveConfigService
