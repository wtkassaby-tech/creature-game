--!strict
-- Checks where each story battle stands for a player (who is standing in the world, and the
-- reason a battle that is not open is refused), and that each biome's giant wakes only at its
-- own chapter's sighting. Run from the project folder:  lune run tests/storystand.test

local Biomes = require("../src/content/Biomes")
local Profile = require("../src/shared/Profile")
local Storyline = require("../src/content/Storyline")
local StoryStand = require("../src/shared/StoryStand")
local Tamers = require("../src/content/Tamers")
local Trainers = require("../src/shared/Trainers")
local World = require("../src/shared/World")
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

-- The flags a player has once every beat up to and including `last` is done.
local function through(last: string?): { [string]: boolean }
	local flags: { [string]: boolean } = {}
	if last == nil then
		return flags
	end
	for _, beat in Storyline.beats do
		flags[beat.id] = true
		if beat.id == last then
			return flags
		end
	end
	error(`no beat {last}`)
end

local function battle(id: string): WorldTypes.StoryBattle
	return assert(Tamers.story[id], `no story battle {id}`)
end

print("\n== The rival stands only where the story needs him ==")
do
	local rival = battle("rival_canyon")
	local early = StoryStand.status(Storyline, through("canyon_trader"), rival)
	check("before his beat he is not here yet", early == "Later")
	check("and is not standing on the rim", not StoryStand.visible(early, rival))
	local now = StoryStand.status(Storyline, through("mentors_letter"), rival)
	check("when his beat is next he is Now", now == "Now")
	check("and stands on the rim", StoryStand.visible(now, rival))
	local past = StoryStand.status(Storyline, through("canyon_rival"), rival)
	check("once beaten he is Past", past == "Past")
	check("and has left the rim", not StoryStand.visible(past, rival))
	check("a rival is named by his role", StoryStand.isRival(rival))
	local gate = battle("rival_breakwater")
	local walking = StoryStand.status(Storyline, through("wreck_sighting"), gate)
	check("he is at the gate while the story walks the player up to it", walking == "Soon")
	check("and is seen there, speaking", StoryStand.visible(walking, gate))
	check(
		"but not three beats earlier",
		StoryStand.status(Storyline, through("mentors_note"), gate) == "Later"
	)
	check(
		"and gone again after",
		not StoryStand.visible(StoryStand.status(Storyline, through("tide_badge"), gate), gate)
	)
end

print("\n== A champion holds their post ==")
do
	for _, id in { "champion_karrow", "champion_marr" } do
		local champion = battle(id)
		check(`{id} is not the rival`, not StoryStand.isRival(champion))
		local all = true
		for _, last in { "canyon_arrival", "canyon_road_on", "tide_road_on" } do
			local status = StoryStand.status(Storyline, through(last), champion)
			all = all and StoryStand.visible(status, champion)
		end
		check(`{id} stands there before, during and after`, all)
	end
	check(
		"a battle the story has no beat for is not shown",
		not StoryStand.visible("None", battle("champion_karrow"))
	)
end

print("\n== The reason a battle is refused ==")
do
	local function profileAt(last: string?): Profile.Profile
		local profile = Profile.template()
		profile.Story.starter = "Mossmitt"
		for flag in through(last) do
			profile.Story.flags[flag] = true
		end
		return profile
	end
	local rival, why = Trainers.resolve("rival_canyon", profileAt("canyon_trader"), Storyline)
	check(
		"the rival early on: not here yet, and what to do",
		rival == nil and why ~= nil and string.find(why, "not here yet", 1, true) ~= nil,
		tostring(why)
	)
	check("it is not the old 'not available'", why ~= "That battle is not available")
	local opened = Trainers.resolve("rival_canyon", profileAt("mentors_letter"), Storyline)
	check("he can be fought when his beat is next", opened ~= nil and opened.kind == "Rival")
	local profile = profileAt("mentors_letter")
	profile.Story.flags["won:rival_canyon"] = true
	local _, again = Trainers.resolve("rival_canyon", profile, Storyline)
	check(
		"once won he cannot be fought again, and says why",
		again ~= nil and string.find(again, "already beaten", 1, true) ~= nil,
		tostring(again)
	)
	local _, karrow = Trainers.resolve("champion_karrow", profileAt("canyon_trader"), Storyline)
	check(
		"Isolde Karrow early on names her, and what to do",
		karrow ~= nil
			and string.find(karrow, "Isolde Karrow", 1, true) ~= nil
			and string.find(karrow, "to-do list", 1, true) ~= nil,
		tostring(karrow)
	)
	local _, done = Trainers.resolve("champion_marr", profileAt("tide_champion"), Storyline)
	check(
		"Hepzibah Marr after her battle: already beaten",
		done ~= nil and string.find(done, "already beaten", 1, true) ~= nil,
		tostring(done)
	)
	local nobody, unknown = Trainers.resolve("nobody_here", profileAt(nil), Storyline)
	check("an unknown id is still just unavailable", nobody == nil and unknown ~= nil)
end

print("\n== Each giant wakes at its own chapter's sighting ==")
do
	local ordered: { WorldTypes.Biome } = {}
	for _, biome in Biomes do
		table.insert(ordered, biome)
	end
	table.sort(ordered, function(a, b)
		return a.number < b.number
	end)
	local chapters: { WorldTypes.Chapter } = { Storyline }
	local owners: { [string]: number } = {}
	for _, biome in ordered do
		local marker = biome.lair.giantMarker
		check(`{biome.id}: names a giant marker`, marker ~= "")
		check(`{biome.id}: the marker {marker} is its own`, owners[marker] == nil)
		owners[marker] = biome.number
		-- Exactly one beat opens it.
		local openers = 0
		for _, beat in Storyline.beats do
			if table.find(beat.unlocks, marker) then
				openers += 1
			end
		end
		check(`{biome.id}: exactly one beat wakes its giant`, openers == 1)
	end
	local dust, tide, greenwood =
		ordered[2].lair.giantMarker, ordered[3].lair.giantMarker, ordered[1].lair.giantMarker
	-- A player who has just arrived in Dust Canyon has seen Chapter 1's giant, not Mesalith.
	local arrived = through("canyon_arrival")
	check(
		"on arrival in Dust Canyon, Greenwood's giant is open and Mesalith is not",
		World.isUnlocked(chapters, arrived, greenwood)
			and not World.isUnlocked(chapters, arrived, dust)
	)
	check(
		"Mesalith wakes at the sighting",
		World.isUnlocked(chapters, through("mesa_sighting"), dust)
	)
	local reached = through("tide_arrival")
	check(
		"on arrival in Tide Flats, Carrackon is still asleep",
		not World.isUnlocked(chapters, reached, tide) and World.isUnlocked(chapters, reached, dust)
	)
	check(
		"Carrackon wakes at the wreck sighting",
		World.isUnlocked(chapters, through("wreck_sighting"), tide)
	)
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("story stand checks failed")
end
