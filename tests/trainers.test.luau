--!strict
-- Checks for battles against people and for story triggers the server confirms itself.
-- Run from the project folder:  lune run tests/trainers.test

local Biomes = require("../src/content/Biomes")
local Chapter1 = require("../src/content/story_data/Chapter1")
local Layout = require("../src/shared/Layout")
local Profile = require("../src/shared/Profile")
local StoryProgress = require("../src/shared/StoryProgress")
local StoryTriggers = require("../src/shared/StoryTriggers")
local Tamers = require("../src/content/Tamers")
local Trainers = require("../src/shared/Trainers")
local World = require("../src/shared/World")

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

local greenwood = Biomes.greenwood
local map = Layout.build(greenwood, Tamers.locals)

local nextId = 0
local function newId(): string
	nextId += 1
	return `g{nextId}`
end

-- Finishes beats in order up to (not including) `stopAt`, as the server would after checking.
local function advance(profile: Profile.Profile, stopAt: string)
	while true do
		local beat = World.nextBeat(Chapter1, profile.Story.flags)
		if beat == nil or beat.id == stopAt then
			return
		end
		assert(
			StoryProgress.complete(profile, Chapter1, {
				beatId = beat.id,
				choice = if beat.id == "starter_choice" then "Mossmitt" else nil,
				triggerMet = true,
				newId = newId,
				seed = 3,
				unixTime = 86400 * 300,
			}),
			`beat {beat.id} finishes`
		)
	end
end

print("\n== Who can be battled ==")
do
	local profile = Profile.template()
	check(
		"a made-up opponent is refused",
		Trainers.resolve("gw_nobody", profile, Chapter1) == nil
			and Trainers.resolve(12, profile, Chapter1) == nil
	)
	local pip = Trainers.resolve("gw_pip", profile, Chapter1)
	check(
		"a local tamer can be battled, standing by them",
		pip ~= nil and pip.place == "gw_pip" and pip.paysCoins
	)
	check(
		"the rival's battle is refused before the story reaches it",
		Trainers.resolve("rival_first", profile, Chapter1) == nil
	)

	advance(profile, "rival_parting")
	local first = Trainers.resolve("rival_first", profile, Chapter1)
	check(
		"it opens when it is the story's next step",
		first ~= nil and first.kind == "Rival" and not first.paysCoins
	)
	check(
		"the rival brings the counter to the player's starter",
		first ~= nil and first.team.members[1].species == "Spadesnout"
	)
	check("the first battle cannot be lost", first ~= nil and first.cannotLose)
	local unlosable: { string } = {}
	for id, battle in Tamers.story do
		if battle.cannotLose then
			table.insert(unlosable, id)
		end
	end
	check(
		"it is the only battle in the whole story that cannot be lost",
		#unlosable == 1 and unlosable[1] == "rival_first",
		table.concat(unlosable, ", ")
	)
	profile.Story.flags["won:rival_first"] = true
	check(
		"once won it cannot be replayed, even before its beat finishes",
		Trainers.resolve("rival_first", profile, Chapter1) == nil
	)
	profile.Story.flags["won:rival_first"] = nil
	check(
		"the gate battle is not open yet",
		Trainers.resolve("rival_gate", profile, Chapter1) == nil
	)

	advance(profile, "lasso_lesson")
	check(
		"once won, the first battle cannot be replayed",
		Trainers.resolve("rival_first", profile, Chapter1) == nil
	)
	advance(profile, "badge_and_token")
	local gate = Trainers.resolve("rival_gate", profile, Chapter1)
	check(
		"the gate battle opens at the gate",
		gate ~= nil and gate.place == "greenwood_gate" and gate.xpKind == "Gate"
	)
end

print("\n== Their teams ==")
do
	local profile = Profile.template()
	local wren = assert(Trainers.resolve("gw_wren", profile, Chapter1), "Wren exists")
	local creatures, moves = Trainers.build(wren)
	check(
		"a tamer brings their listed team at its levels",
		#creatures == 2
			and creatures[1].parts.Torso.species == "Sloshcalf"
			and creatures[2].level == 5
	)
	check("with their chosen moves", moves[2][2] == "Brook Rush")
	local again = Trainers.build(wren)
	check(
		"the same tamer always brings the same creatures",
		again[1].parts.Head.quality == creatures[1].parts.Head.quality
			and again[1].id == creatures[1].id
	)
	moves[1][1] = "Changed"
	check(
		"the tamer's data cannot be changed through a battle",
		Tamers.locals.gw_wren.team.members[1].moves[1] ~= "Changed"
	)
end

print("\n== Story triggers the server confirms ==")
do
	local profile = Profile.template()
	local far = map.places.greenwood_gate
	check(
		"the first beat only needs asking",
		StoryTriggers.ready(Chapter1, profile, map, { kind = "Ask", at = nil }) ~= nil
	)
	advance(profile, "rival_parting")
	check(
		"a win beat ignores asking",
		StoryTriggers.ready(Chapter1, profile, map, { kind = "Ask", at = far }) == nil
	)
	check(
		"and ignores a different battle",
		StoryTriggers.ready(Chapter1, profile, map, { kind = "Win", battle = "gw_pip" }) == nil
	)
	check(
		"and is met by the server's own win",
		StoryTriggers.ready(Chapter1, profile, map, { kind = "Win", battle = "rival_first" }) ~= nil
	)

	advance(profile, "route_one")
	check(
		"entering a place needs the character to be there",
		StoryTriggers.ready(Chapter1, profile, map, { kind = "At", at = far }) == nil
	)
	local entered = StoryTriggers.ready(
		Chapter1,
		profile,
		map,
		{ kind = "At", at = map.places.greenwood_route_a }
	)
	check("and is met when it is", entered ~= nil and entered.id == "route_one")

	local early = Profile.template()
	advance(early, "first_tamer")
	check(
		"a tamer not yet beaten does not finish their beat",
		StoryTriggers.ready(Chapter1, early, map, { kind = "At", at = far }) == nil
	)
	early.Story.flags["won:gw_pip"] = true
	check(
		"a tamer beaten before the story asked still counts",
		StoryTriggers.ready(Chapter1, early, map, { kind = "At", at = far }) ~= nil
	)

	advance(profile, "mentor_egg")
	check(
		"talking needs the player beside the character",
		StoryTriggers.ready(Chapter1, profile, map, { kind = "Ask", at = far }) == nil
			and StoryTriggers.ready(Chapter1, profile, map, { kind = "Ask", at = nil }) == nil
	)
	check(
		"and is met beside them",
		StoryTriggers.ready(Chapter1, profile, map, { kind = "Ask", at = map.places.mentor }) ~= nil
	)
	check(
		"walking past is not talking",
		StoryTriggers.ready(Chapter1, profile, map, { kind = "At", at = map.places.mentor }) == nil
	)

	advance(profile, "third_creature")
	check(
		"a tame beat ignores asking",
		StoryTriggers.ready(Chapter1, profile, map, { kind = "Ask", at = far }) == nil
	)
	check(
		"and is met by a catch the server judged",
		StoryTriggers.ready(Chapter1, profile, map, { kind = "Tame" }) ~= nil
	)
end

print("\n== Features the story opens ==")
do
	local profile = Profile.template()
	local chapters = { Chapter1 }
	check(
		"breeding is closed before the mentor's lesson",
		not World.isUnlocked(chapters, profile.Story.flags, "breeding")
	)
	check(
		"the shop is closed before the first route",
		not World.isUnlocked(chapters, profile.Story.flags, "shop")
	)
	advance(profile, "third_creature")
	check(
		"both open once their beats are done",
		World.isUnlocked(chapters, profile.Story.flags, "breeding")
			and World.isUnlocked(chapters, profile.Story.flags, "shop")
	)
	check(
		"a feature the story never mentions is not locked",
		World.isUnlocked(chapters, {}, "weather")
	)
end

print("\n== Ids never collide ==")
do
	local Giants = require("../src/content/Giants")
	local seen: { [string]: string } = {}
	local clashes: { string } = {}
	local function claim(id: string, what: string)
		if seen[id] then
			table.insert(clashes, `{id} ({seen[id]} and {what})`)
		end
		seen[id] = what
	end
	for id in Tamers.locals do
		claim(id, "tamer")
	end
	for id in Tamers.story do
		claim(id, "story battle")
	end
	for id in Giants do
		claim(id, "giant")
	end
	check(
		"no tamer, story battle or giant shares an id",
		#clashes == 0,
		table.concat(clashes, ", ")
	)

	local names: { [string]: boolean } = {}
	local shared: { string } = {}
	local list = {}
	for _, biome in Biomes do
		table.insert(list, biome)
		for _, building in biome.hub.buildings do
			if names[building.name] then
				table.insert(shared, building.name)
			end
			names[building.name] = true
		end
	end
	check(
		"no two buildings in the world share a name (quest givers are found by it)",
		#shared == 0,
		table.concat(shared, ", ")
	)

	local world = Layout.world(list, Tamers.locals)
	local count, total = 0, 0
	for _ in world.map.places do
		count += 1
	end
	for _, own in world.maps do
		for _ in own.places do
			total += 1
		end
	end
	check("no place id is used in two biomes", count == total, `{count} of {total}`)
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("trainer checks failed")
end
