--!strict
-- Checks for choosing the team.
-- Run from the project folder:  lune run tests/team.test

local Breeding = require("../src/shared/Breeding")
local Profile = require("../src/shared/Profile")
local Rng = require("../src/shared/Rng")
local Team = require("../src/shared/Team")

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

local function free(_id: string): boolean
	return false
end

local profile = Profile.template()
for index = 1, 8 do
	local creature = Breeding.wild("Mossmitt", `c{index}`, 5, "Common", "Moss", Rng.new(index))
	profile.Creatures[creature.id] = creature
end
profile.Team = { "c1" }
local size = Profile.teamSize(profile.Story.badges)

check(
	"a team that is not a list is refused",
	not Team.set(profile, "c1", free) and not Team.set(profile, nil, free)
)
check("an empty team is refused", not Team.set(profile, {}, free))
check(
	"a creature the player does not own is refused",
	not Team.set(profile, { "c1", "nobody" }, free)
)
check("the same creature twice is refused", not Team.set(profile, { "c2", "c2" }, free))
local mixed: { any } = { "c1", 7 }
check("ids that are not text are refused", not Team.set(profile, mixed, free))
check(
	"a list with named keys or gaps is refused",
	not Team.set(profile, { a = "c1" }, free)
		and not Team.set(profile, { [1] = "c1", [3] = "c2" }, free)
)
local tooMany = {}
for index = 1, size + 1 do
	table.insert(tooMany, `c{index}`)
end
check(
	"more creatures than the badges allow is refused",
	not Team.set(profile, tooMany, free),
	`team size {size}`
)
check("nothing changed after the refusals", #profile.Team == 1 and profile.Team[1] == "c1")

local full = {}
for index = size, 1, -1 do
	table.insert(full, `c{index}`)
end
check(
	"a full team in a new order is taken",
	Team.set(profile, full, free) and profile.Team[1] == `c{size}` and #profile.Team == size
)
check(
	"the team cannot change while a member is in a battle",
	not Team.set(profile, { "c8" }, function(id)
		return id == full[1]
	end)
)
check("or while a creature being added is in a battle", not Team.set(profile, { "c8" }, function(id)
	return id == "c8"
end))
check(
	"the record is sound",
	#Profile.validate(profile) == 0,
	table.concat(Profile.validate(profile), "; ")
)

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("team checks failed")
end
