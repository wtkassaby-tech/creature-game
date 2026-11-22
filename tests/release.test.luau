--!strict
-- Checks that biomes written ahead of time stay closed: the world registries list only the biomes
-- src/config/ReleaseConfig.luau opens, so a later biome's content cannot leak into the live game.
-- Run from the project folder:  lune run tests/release.test

local Biomes = require("../src/content/Biomes")
local Chapter1 = require("../src/content/story_data/Chapter1")
local Chapter2 = require("../src/content/story_data/Chapter2")
local Chapter3 = require("../src/content/story_data/Chapter3")
local Giants = require("../src/content/Giants")
local Quests = require("../src/content/Quests")
local ReleaseConfig = require("../src/config/ReleaseConfig")
local Species = require("../src/content/Species")
local Story = require("../src/content/Story")
local Storyline = require("../src/content/Storyline")
local Tamers = require("../src/content/Tamers")
local WorldTypes = require("../src/shared/WorldTypes")

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

local OPEN = ReleaseConfig.OPEN_BIOMES

print("\n== Launch release ==")
check("three biomes are open at launch", OPEN == 3, `{OPEN}`)

do
	local numbers: { [number]: boolean } = {}
	local count = 0
	for _, biome in Biomes do
		count += 1
		numbers[biome.number] = true
	end
	local all = true
	for number = 1, OPEN do
		all = all and numbers[number] == true
	end
	check("every open biome is listed, and nothing more", count == OPEN and all, `{count} listed`)
end

do
	local count, highest = 0, 0
	for _, chapter in Story do
		count += 1
		highest = math.max(highest, chapter.number)
	end
	check("only the open biomes' chapters are listed", count == OPEN and highest == OPEN, `{count}`)
end

do
	local lastChapter = ({ Chapter1, Chapter2, Chapter3 })[OPEN]
	local expected = lastChapter.beats[#lastChapter.beats].id
	local last = Storyline.beats[#Storyline.beats].id
	check(
		"the story line ends with the last open chapter",
		last == expected,
		`{last} vs {expected}`
	)
end

do
	local count = 0
	for _ in Giants do
		count += 1
	end
	check("one giant for each open biome", count == OPEN, `{count}`)
end

-- No open place offers a creature from a closed biome.
do
	local leaks: { string } = {}
	local function seen(where: string, species: string)
		local def = Species[species]
		if def ~= nil and def.biome > OPEN then
			table.insert(leaks, `{where}: {species}`)
		end
	end
	for _, biome in Biomes do
		for _, route in biome.routes do
			for _, entry in route.spawns do
				seen(`{biome.id} {route.id}`, entry.species)
			end
		end
	end
	for id, quest in Quests do
		for _, reward in quest.rewards do
			if reward.kind == "Creature" then
				seen(`quest {id}`, reward.species)
			end
		end
	end
	for id, tamer in Tamers.locals do
		for _, member in tamer.team.members do
			seen(`tamer {id}`, member.species)
		end
	end
	for id, battle in Tamers.story do
		local teams: { WorldTypes.TamerTeam } = {}
		if battle.team then
			table.insert(teams, battle.team)
		end
		local byStarter = battle.teams
		if byStarter then
			table.insert(teams, byStarter.Mossmitt)
			table.insert(teams, byStarter.Spadesnout)
			table.insert(teams, byStarter.Sloshcalf)
		end
		for _, team in teams do
			for _, member in team.members do
				seen(`story battle {id}`, member.species)
			end
		end
	end
	check(
		"no open place offers a creature from a closed biome",
		#leaks == 0,
		table.concat(leaks, "; ")
	)
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error(`{failed} release check(s) failed`)
end
