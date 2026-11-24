--!strict
-- Checks for the tracker lines, the "Day one" card, the Creatures nudge and the starter confirm.
-- Run from the project folder:  lune run tests/tracker.test

local Tracker = require("../src/shared/Tracker")

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

print("\n== The tracker lines ==")
do
	check("the clock reads m:ss", Tracker.clock(130) == "2:10" and Tracker.clock(-5) == "0:00")
	local quiet = Tracker.lines({ hint = nil, quests = {}, eggs = {}, now = 100, friends = 2 })
	check(
		"with nothing going on only the friends line shows",
		#quiet == 1 and quiet[1] == "Greenwood friends 2 of 8"
	)
	local full = Tracker.lines({
		hint = "Next: look at the tree",
		quests = {
			{ goal = "win 3 fights", progress = 1, needed = 3, giver = "Marlow" },
			{ goal = "catch one", progress = 1, needed = 1, giver = "Pip" },
		},
		eggs = { 230 },
		now = 100,
		friends = 4,
	})
	check("never more than four lines", #full == 4)
	check("the story hint comes first", full[1] == "Next: look at the tree")
	check("the egg comes second, counting down", full[2] == "Egg hatches in 2:10", full[2])
	check(
		"quests follow, sorted, and a finished one says who to go back to",
		full[3] == "Quest done: go back to Pip" and full[4] == "Quest: win 3 fights (1/3)"
	)
	local hatched =
		Tracker.lines({ hint = "Next: x", quests = {}, eggs = { 90, 500 }, now = 100, friends = 4 })
	check("a hatched egg says to open Creatures", hatched[2] == "Your egg hatched! Open Creatures.")
	check("the friends line closes a short list", hatched[3] == "Greenwood friends 4 of 8")
end

print("\n== The Day one card ==")
do
	local lines = Tracker.dayOneLines(3, { 400 }, 100, "win 3 fights")
	check(
		"friends, egg, quest, then the closing line",
		#lines == 4
			and lines[1] == "Friends so far: 3"
			and lines[2] == "Your egg hatches in 5:00."
			and lines[3] == "A new job: win 3 fights"
			and lines[4] == "Something stirs in the old tree."
	)
	local bare = Tracker.dayOneLines(1, {}, 100, nil)
	check(
		"missing parts are left out",
		#bare == 2 and bare[2] == "Something stirs in the old tree."
	)
	local done = Tracker.dayOneLines(1, { 50 }, 100, nil)
	check("a hatched egg is said as hatched", done[2] == "Your egg has hatched.")
end

print("\n== Greenwood friends ==")
do
	check("eight species", #Tracker.GREENWOOD == 8)
	check("none owned", Tracker.countFriends({}) == 0)
	check(
		"repeats and other biomes do not count twice",
		Tracker.countFriends({ "Mossmitt", "Mossmitt", "Gorsling", "Dustpaw" }) == 2
	)
	check("all of them", Tracker.countFriends(Tracker.GREENWOOD) == 8)
end

print("\n== Something waiting in Creatures ==")
do
	local waiting = Tracker.waiting({}, 100, 1, 1)
	check("one creature on a team of one: nothing waiting", not waiting)
	local spare, key = Tracker.waiting({}, 100, 3, 2)
	check("a creature off the team with room: waiting", spare and key == "0/1")
	check("a full team of six: no spare", not (Tracker.waiting({}, 100, 9, 6)))
	local egg, eggKey = Tracker.waiting({ 90 }, 100, 1, 1)
	check("a hatched egg: waiting", egg and eggKey == "1/0")
	check("an egg still warm: not waiting", not (Tracker.waiting({ 200 }, 100, 1, 1)))
end

print("\n== The starter confirm ==")
do
	local choices = { "Mossmitt", "Spadesnout", "Sloshcalf" }
	check("nothing selected: no send", not Tracker.pickAllowed(nil, choices))
	check("a choice that is offered: send", Tracker.pickAllowed("Sloshcalf", choices))
	check("a name that was never offered: no send", not Tracker.pickAllowed("Burlhorn", choices))
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("tracker checks failed")
end
