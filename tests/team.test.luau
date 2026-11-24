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
-- The "biome reached" rule.
do
	local far = Breeding.wild("Mossmitt", "far", 5, "Common", "Moss", Rng.new(99))
	far.originBiome = 2
	profile.Creatures[far.id] = far
	local before = table.clone(profile.Team)
	local ok, problem = Team.set(profile, { "far" }, free)
	check(
		"a creature from a biome the player has not reached cannot join the team",
		not ok and not Team.mayBattle(profile, far) and #profile.Team == #before,
		problem
	)
	profile.Story.biomeReached = 2
	check(
		"once the player has reached its biome it can",
		Team.mayBattle(profile, far) and (Team.set(profile, { "far", "c1" }, free))
	)
	check(
		"a creature from an earlier biome always can",
		Team.mayBattle(profile, profile.Creatures.c1)
	)
	-- Put things back for the checks below.
	profile.Team = before
	profile.Creatures[far.id] = nil
	profile.Story.biomeReached = 1
end

-- No biome hands out a creature the player could not then use: every wild species on a
-- biome's routes belongs to that biome or an earlier one.
do
	local Biomes = require("../src/content/Biomes")
	local Species = require("../src/content/Species")
	local early: { string } = {}
	for _, biome in Biomes do
		for _, route in biome.routes do
			for _, entry in route.spawns do
				if Species[entry.species].biome > biome.number then
					table.insert(early, `{entry.species} in biome {biome.number}`)
				end
			end
		end
	end
	check(
		"no route holds a wild species from a later biome",
		#early == 0,
		table.concat(early, ", ")
	)
end

check(
	"the record is sound",
	#Profile.validate(profile) == 0,
	table.concat(Profile.validate(profile), "; ")
)

profile.Creatures.c1.hurt, profile.Creatures.c2.hurt = 1, 1
check(
	"a team with nobody able to fight is refused while a healthy creature is owned",
	not Team.set(profile, { "c1", "c2" }, free)
)
check("a team with one standing creature is taken", (Team.set(profile, { "c1", "c3" }, free)))
for index = 1, 8 do
	profile.Creatures[`c{index}`].hurt = 1
end
check(
	"if every creature has fainted, any team is taken (the healer is the way out)",
	(Team.set(profile, { "c4" }, free))
)

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("team checks failed")
end
