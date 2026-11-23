--!strict
-- Checks for the tamers' words before and after a battle, and the story camera's easing.
-- Run from the project folder:  lune run tests/tamerlines.test

local LookEase = require("../src/shared/LookEase")
local TamerLines = require("../src/shared/TamerLines")
local Tamers = require("../src/content/Tamers")

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

print("\n== A tamer's words ==")
do
	local before = TamerLines.before("gw_pip")
	check("Pip speaks before", before ~= nil and before.speaker == "Pip")
	check("as 'Pip: line'", before ~= nil and string.sub(TamerLines.words(before), 1, 5) == "Pip: ")
	local after = TamerLines.after("gw_pip")
	check("Pip speaks after losing", after ~= nil and after.line == Tamers.locals.gw_pip.after)
	check(
		"Pip's first line promises no block",
		before ~= nil and not string.find(before.line, "walk on", 1, true)
	)
	local first = TamerLines.before("rival_first")
	check(
		"the rival's first meeting uses his first line",
		first ~= nil
			and first.speaker == "Rival"
			and string.find(first.line, "coolest", 1, true) ~= nil
	)
	local gate = TamerLines.before("rival_gate")
	check(
		"and the gate battle his other line",
		gate ~= nil
			and string.find(gate.line, "types", 1, true) ~= nil
			and first ~= nil
			and gate.line ~= first.line
	)
	check(
		"a wild creature has none",
		TamerLines.before(nil) == nil and TamerLines.after(nil) == nil
	)
	check("an unknown id has none", TamerLines.before("nobody") == nil)
	local everyone = true
	for id in Tamers.locals do
		local said = TamerLines.before(id)
		local parting = TamerLines.after(id)
		if not (said and said.line ~= "" and parting and parting.line ~= "") then
			everyone = false
		end
	end
	for id in Tamers.story do
		local said = TamerLines.before(id)
		local parting = TamerLines.after(id)
		if not (said and said.line ~= "" and parting and parting.line ~= "") then
			everyone = false
		end
	end
	check("every tamer and story battle has both lines", everyone)
end

print("\n== The camera look's easing ==")
do
	local alpha = 0
	for _ = 1, 12 do
		alpha = LookEase.advance(alpha, 0.1, true, 1.2)
	end
	check("it reaches the landmark in about 1.2 seconds", alpha >= 0.99, tostring(alpha))
	check("and never overshoots", LookEase.advance(1, 1, true, 1.2) == 1)
	check("it eases back to the ordinary camera", LookEase.advance(0.05, 1, false, 1.2) == 0)
	check("a zero time is instant", LookEase.advance(0, 0.016, true, 0) == 1)
	check(
		"smooth runs 0, half, 1",
		LookEase.smooth(0) == 0 and LookEase.smooth(0.5) == 0.5 and LookEase.smooth(1) == 1
	)
	check("smooth stays inside 0 to 1", LookEase.smooth(-3) == 0 and LookEase.smooth(7) == 1)
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("tamer lines checks failed")
end
