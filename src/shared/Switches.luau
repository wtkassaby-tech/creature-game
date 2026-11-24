--!strict
-- The live switches (src/config/LiveConfig) as pure rules: turning whatever the live service
-- holds into a full, trustworthy set of on/off values. The server module that talks to Roblox
-- is src/server/LiveConfig/LiveConfigService.

local LiveConfig = require("../config/LiveConfig")

export type Change = { key: LiveConfig.Key, on: boolean }

local Switches = {}

-- The values with nothing live to go on: what the game does until Roblox answers.
function Switches.defaults(): LiveConfig.Values
	return table.clone(LiveConfig.DEFAULTS)
end

-- Reads every switch through `get`, which returns the live value for a key or nil. Only a real
-- boolean is believed; anything else falls back to the default. A feature that is not built
-- stays off whatever the live value says.
function Switches.read(get: (key: LiveConfig.Key) -> unknown): LiveConfig.Values
	local values = Switches.defaults()
	for _, key: LiveConfig.Key in LiveConfig.KEYS do
		local live = get(key)
		if typeof(live) == "boolean" then
			values[key] = live
		end
		if table.find(LiveConfig.NOT_BUILT, key) then
			values[key] = false
		end
	end
	return values
end

-- What changed between two sets of values, for the server log.
function Switches.changes(before: LiveConfig.Values, after: LiveConfig.Values): { Change }
	local list: { Change } = {}
	for _, key: LiveConfig.Key in LiveConfig.KEYS do
		if before[key] ~= after[key] then
			table.insert(list, { key = key, on = after[key] })
		end
	end
	return list
end

return Switches
