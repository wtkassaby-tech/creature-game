--!strict
-- Checks for the live switches.
-- Run from the project folder:  lune run tests/switches.test

local LiveConfig = require("../src/config/LiveConfig")
local Switches = require("../src/shared/Switches")

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

local defaults = Switches.defaults()
check(
	"with nothing live to go on, everything built is open and nothing unbuilt is",
	defaults.shop_open
		and defaults.breeding_open
		and defaults.giants_open
		and defaults.daily_rewards_open
		and defaults.release_open
		and not defaults.purchases_open
		and not defaults.trading_open
		and not defaults.pvp_open
)
defaults.shop_open = false
check("the defaults handed out are a copy", LiveConfig.DEFAULTS.shop_open == true)

local nothing = Switches.read(function(_key: LiveConfig.Key): unknown
	return nil
end)
check("missing keys count as their defaults", #Switches.changes(Switches.defaults(), nothing) == 0)

local off = Switches.read(function(key: LiveConfig.Key): unknown
	return if key == "breeding_open" then false else nil
end)
check(
	"one switch can be turned off without touching the others",
	not off.breeding_open and off.shop_open and off.giants_open and off.daily_rewards_open
)
local changes = Switches.changes(Switches.defaults(), off)
check(
	"the change is reported once, by name",
	#changes == 1 and changes[1].key == "breeding_open" and changes[1].on == false
)

local junk = Switches.read(function(key: LiveConfig.Key): unknown
	if key == "shop_open" then
		return "false"
	elseif key == "giants_open" then
		return 0
	elseif key == "breeding_open" then
		return {}
	end
	return nil
end)
check(
	"a value that is not a real true or false is ignored",
	junk.shop_open and junk.giants_open and junk.breeding_open
)

local eager = Switches.read(function(_key: LiveConfig.Key): unknown
	return true
end)
check(
	"a feature that is not built cannot be switched on from outside",
	not eager.purchases_open and not eager.trading_open and not eager.pvp_open,
	"purchases, trading and PvP stay off until their code ships"
)

local everyKeyHasADefault = true
for _, key: LiveConfig.Key in LiveConfig.KEYS do
	if typeof(LiveConfig.DEFAULTS[key]) ~= "boolean" then
		everyKeyHasADefault = false
	end
end
check("every switch has a default", everyKeyHasADefault and #LiveConfig.KEYS == 8)
check(
	"the wait before trying Roblox again never reaches zero",
	#LiveConfig.RETRY_SECONDS > 0 and math.min(table.unpack(LiveConfig.RETRY_SECONDS)) >= 1
)
check("players are told something when a thing is closed", #LiveConfig.CLOSED_TEXT > 10)

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("switch checks failed")
end
