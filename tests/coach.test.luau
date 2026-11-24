--!strict
-- Tests for the battle coach's decisions. Run: lune run tests/coach.test

local Coach = require("../src/shared/Coach")

local passed, failed = 0, 0
local function check(name: string, condition: boolean, detail: string?)
	if condition then
		passed += 1
		print(`  PASS  {name}{if detail then "  (" .. detail .. ")" else ""}`)
	else
		failed += 1
		print(`  FAIL  {name}{if detail then "  (" .. detail .. ")" else ""}`)
	end
end

-- Leaf is strong against Water and Crystal, not against Fire.
local LEAF_MOVE = "Moss Slam"
local LEAF_ONLY = { "Moss Slam" }

print("first-battle coach")
check("quiet outside the rival", Coach.firstBattleLine({}, "Wild", { LEAF_MOVE }, "Water") == nil)
check(
	"quiet once the rival has parted",
	Coach.firstBattleLine({ "rival_parting" }, "Rival", { LEAF_MOVE }, "Water") == nil
)
check(
	"says STRONG when a move is strong",
	Coach.firstBattleLine({}, "Rival", { LEAF_MOVE }, "Water") == Coach.LINES.pickStrong
)
check(
	"does not promise STRONG when none is",
	Coach.firstBattleLine({}, "Rival", LEAF_ONLY, "Fire") == Coach.LINES.pickMove
)
check(
	"no moves means no promise",
	Coach.firstBattleLine({}, "Rival", {}, "Water") == Coach.LINES.pickMove
)
check("unknown move is ignored", not Coach.hasStrongMove({ "No Such Move" }, "Water"))
check(
	"strong hit line only in the first battle",
	Coach.strongHitLine({}, "Rival") == Coach.LINES.strongHit
		and Coach.strongHitLine({ "rival_parting" }, "Rival") == nil
		and Coach.strongHitLine({}, "Tamer") == nil
)
check(
	"no line is over 90 characters",
	(function(): boolean
		for _, line in Coach.LINES do
			if #line > 90 then
				return false
			end
		end
		return true
	end)()
)

print("lasso coach")
local lesson = { "rival_parting", "lasso_lesson" }
check("quiet before the lesson", Coach.lassoLine({}, true, 50, 50) == nil)
check(
	"quiet after the first catch",
	Coach.lassoLine({ "lasso_lesson", "third_creature" }, true, 50, 50) == nil
)
check("quiet against a tamer", Coach.lassoLine(lesson, false, 10, 50) == nil)
check(
	"says weaken first at full health",
	Coach.lassoLine(lesson, true, 50, 50) == Coach.LINES.weakenFirst
)
check(
	"still weaken first just above 40 percent",
	Coach.lassoLine(lesson, true, 21, 50) == Coach.LINES.weakenFirst
)
check("tired at exactly 40 percent", Coach.lassoLine(lesson, true, 20, 50) == Coach.LINES.tired)
check("no nudge when healthy", not Coach.lassoNudge(lesson, true, 40, 50))
check("nudge when tired", Coach.lassoNudge(lesson, true, 10, 50))
check("no nudge for a fainted foe", not Coach.lassoNudge(lesson, true, 0, 50))
check("no nudge outside the lesson", not Coach.lassoNudge({}, true, 10, 50))

print("missed throws")
check("common gets the reassurance", Coach.missLine("Common") == Coach.LINES.missedCommon)
check("uncommon keeps the old line", Coach.missLine("Uncommon") == nil)
check("gem keeps the old line", Coach.missLine("Gem") == nil)

print("where a catch went")
check("joins an empty team", Coach.placementLine(0, 3) == Coach.LINES.joined)
check("joins a team with a free place", Coach.placementLine(2, 3) == Coach.LINES.joined)
check("goes to the stable when the team is full", Coach.placementLine(3, 3) == Coach.LINES.stable)
check("unknown gives the safe words", Coach.placementLine(nil, 3) == Coach.LINES.friend)
check("an unknown limit gives the safe words", Coach.placementLine(1, nil) == Coach.LINES.friend)
check(
	"a numbered catch, which joins later, gets the safe words",
	Coach.placementLine(0, 3, true) == Coach.LINES.friend
)

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("coach tests failed")
end
