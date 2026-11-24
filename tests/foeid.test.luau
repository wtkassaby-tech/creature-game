--!strict
-- The battle-start message carries the foe's id in a Blink `string(1..40)` (src/net/Net.blink), and
-- the device throws on a longer or empty one, so every tamer and story battle id must fit.
-- Run from the project folder:  lune run tests/foeid.test

-- Check every biome that is written, open or not.
require("../src/config/ReleaseConfig").OPEN_BIOMES = 4

local Tamers = require("../src/content/Tamers")

local MAX = 40

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

local function fits(id: string): boolean
	return #id >= 1 and #id <= MAX
end

print("A foe's id fits the net message")
do
	local count = 0
	for id, tamer in Tamers.locals do
		count += 1
		check(`tamer {id} fits in {MAX} characters`, fits(id) and fits(tamer.id))
	end
	for id, battle in Tamers.story do
		count += 1
		check(`story battle {id} fits in {MAX} characters`, fits(id) and fits(battle.id))
	end
	check("some ids were checked", count > 0)
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("foe id checks failed")
end
