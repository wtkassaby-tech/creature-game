--!strict
-- Tests for the result card's XP bar maths. Run:  lune run tests/xpbar.test

local Xp = require("../src/shared/Xp")
local XpBar = require("../src/shared/XpBar")

local passed, failed = 0, 0
local function check(name: string, condition: boolean)
	if condition then
		passed += 1
		print(`  PASS  {name}`)
	else
		failed += 1
		print(`  FAIL  {name}`)
	end
end
local function near(a: number, b: number): boolean
	return math.abs(a - b) < 1e-6
end

print("\n== XP bar ==")
do
	local need = Xp.xpToNext(3)
	local plain = XpBar.segments(3, 0, 3, need // 2)
	check("no level-up is one segment", #plain == 1)
	check(
		"it runs from before to after",
		near(plain[1].from, 0) and near(plain[1].to, (need // 2) / need)
	)
	check("start of the fill", near(XpBar.at(plain, 0).fill, 0))
	check("end of the fill", near(XpBar.at(plain, 1).fill, plain[1].to))

	local up = XpBar.segments(3, need - 1, 4, 5)
	check("a level-up is two segments", #up == 2 and up[1].level == 3 and up[2].level == 4)
	check("the first fills to the top", near(up[1].to, 1) and near(up[2].from, 0))
	local mid = XpBar.at(up, 0.5)
	check("the level shown follows the bar", mid.level == 3 or mid.level == 4)
	local done = XpBar.at(up, 1)
	check("it ends on the new level", done.level == 4 and near(done.fill, up[2].to))

	local many = XpBar.segments(2, 0, 5, 0)
	check("several levels give one segment each", #many == 4)
	check(
		"a bar that does not move stays put",
		near(XpBar.at(XpBar.segments(2, 7, 2, 7), 0.5).fill, 7 / Xp.xpToNext(2))
	)
	local capped = XpBar.segments(5, Xp.xpToNext(5) * 3, 5, Xp.xpToNext(5) * 4)
	check(
		"banked xp past the need is held at full",
		near(capped[1].from, 1) and near(capped[1].to, 1)
	)
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error(`{failed} test(s) failed`)
end
