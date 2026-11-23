--!strict
-- Checks that the tracker names its target for every story beat, and that a beat's `lookAt`
-- names a real place. Run from the project folder:  lune run tests/beathint.test

local BeatHint = require("../src/shared/BeatHint")
local Biomes = require("../src/content/Biomes")
local Chapter1 = require("../src/content/story_data/Chapter1")
local Chapter2 = require("../src/content/story_data/Chapter2")
local Chapter3 = require("../src/content/story_data/Chapter3")
local Layout = require("../src/shared/Layout")
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

local chapters: { WorldTypes.Chapter } = { Chapter1, Chapter2, Chapter3 }
local biomeList: { WorldTypes.Biome } = {}
for _, biome in Biomes do
	table.insert(biomeList, biome)
end
local world = Layout.world(biomeList, Tamers.locals)

print("\n== Every beat's hint names its target ==")
for _, chapter in chapters do
	for _, beat in chapter.beats do
		local text, target = BeatHint.resolve(beat)
		local kind = beat.trigger.kind
		check(`{beat.id}: has a hint`, text ~= "", text)
		if beat.trigger.target and not beat.hint then
			check(
				`{beat.id}: the hint names its {kind} target`,
				target ~= nil and string.find(text, target, 1, true) ~= nil,
				text
			)
		end
		check(
			`{beat.id}: never gives the result away`,
			not string.find(text, "sore loser", 1, true)
		)
	end
end

print("\n== The beats the audit named ==")
do
	local function beatOf(id: string): WorldTypes.Beat
		for _, beat in Chapter1.beats do
			if beat.id == id then
				return beat
			end
		end
		error(`no beat {id}`)
	end
	check("the rival", BeatHint.text(beatOf("rival_parting")):find("your rival") ~= nil)
	check("Pip, and where", BeatHint.text(beatOf("first_tamer")) == "Beat Pip Alder on Clover Lane")
	check("a place to walk to", BeatHint.text(beatOf("giant_glimpse")) == "Walk into Clover Meadow")
	check(
		"Marlow, and where",
		BeatHint.text(beatOf("first_quest")) == "Talk to Marlow Tuppence at Tuppence's Shop"
	)
	check("the giant glimpse looks at the lair", beatOf("giant_glimpse").lookAt == "greenwood_lair")
end

print("\n== A beat's lookAt is a real place ==")
for _, chapter in chapters do
	for _, beat in chapter.beats do
		if beat.lookAt then
			check(`{beat.id}: {beat.lookAt} is on the map`, world.map.places[beat.lookAt] ~= nil)
		end
	end
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("beat hint checks failed")
end
