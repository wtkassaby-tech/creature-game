--!strict
-- Tests for the small pure checks behind sound throttles. Run:  lune run tests/cadence.test

local Cadence = require("../src/shared/Cadence")

local passed, failed = 0, 0
local function check(name: string, condition: boolean)
	if condition then
		passed += 1
	else
		failed += 1
	end
	print(`  {if condition then "PASS" else "FAIL"}  {name}`)
end

print("Throttle")
check("the first call passes", Cadence.ready(-math.huge, 0, 0.045))
check("a call inside the gap waits", not Cadence.ready(1, 1.03, 0.045))
check("a call a gap later passes", Cadence.ready(1, 1.05, 0.045))
check("a call after the gap passes", Cadence.ready(1, 2, 0.045))

print("Discs")
check("the centre is inside", Cadence.inDisc(5, 5, 5, 5, 3))
check("a point on the edge is inside", Cadence.inDisc(8, 5, 5, 5, 3))
check("a point past the edge is outside", not Cadence.inDisc(8.1, 5, 5, 5, 3))
check("the diagonal counts as a circle, not a square", not Cadence.inDisc(7.5, 7.5, 5, 5, 3))

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error(`{failed} test(s) failed`)
end
