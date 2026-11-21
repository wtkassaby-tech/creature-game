--!strict
-- Checks for the device's view of the saved state.
-- Run from the project folder:  lune run tests/snapshot.test

local Breeding = require("../src/shared/Breeding")
local Profile = require("../src/shared/Profile")
local Rng = require("../src/shared/Rng")
local Snapshot = require("../src/shared/Snapshot")

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

local profile = Profile.template()
local a = Breeding.wild("Mossmitt", "b", 7, "Common", "Moss", Rng.new(1))
local b = Breeding.wild("Spadesnout", "a", 3, "Common", "Sand", Rng.new(2))
profile.Creatures.a, profile.Creatures.b = b, a
profile.Team = { "b" }
profile.Coins = 0 / 0
profile.Items.Basic = 3
profile.Items.Empty = 0
profile.Candy.typed.Sand = 2.5
profile.Story.flags.starter_choice = true
profile.Story.flags["grant:Starter:x"] = true
profile.Eggs = { { child = a, hatchAt = 1234, seed = 9 } }

local state = Snapshot.build(profile)
check(
	"creatures are listed in a stable order",
	#state.Creatures == 2 and state.Creatures[1].Id == "a"
)
check("an odd saved number is shown as 0, not sent broken", state.Coins == 0)
check("empty items are left out", state.Items.Basic == 3 and state.Items.Empty == nil)
check("typed candy keeps its fractions", state.Candy.Sand == 2.5)
check(
	"story flags are shown, internal gift flags are not",
	#state.Flags == 1 and state.Flags[1] == "starter_choice"
)
local egg = state.Eggs[1] :: any
check(
	"an egg shows only when it hatches, not its child",
	egg.HatchAt == 1234 and egg.child == nil and egg.Id == nil
)
check("the team is listed", state.Team[1] == "b")

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("snapshot checks failed")
end
