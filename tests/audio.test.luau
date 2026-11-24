--!strict
-- Checks on the sound config (every id set, every volume in range, the music moods all there) and
-- on the town/route choice for the music. Run from the project folder:  lune run tests/audio.test

local AudioConfig = require("../src/config/AudioConfig")
local Biomes = require("../src/content/Biomes")
local Layout = require("../src/shared/Layout")
local MusicZone = require("../src/shared/MusicZone")
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

print("Music")
for _, mood in { "town", "route", "battle", "giant" } do
	local track = AudioConfig.MUSIC[mood]
	check(
		`{mood} has a track`,
		track ~= nil and string.sub(track.soundId, 1, 13) == "rbxassetid://"
	)
	check(`{mood} volume is audible and not loud`, track.volume > 0 and track.volume <= 0.5)
end

print("Sound effects")
for name, def in AudioConfig.SFX do
	local known = string.sub(def.id, 1, 13) == "rbxassetid://"
		or string.sub(def.id, 1, 15) == "rbxasset://soun"
	check(`{name} has an id`, known)
	check(
		`{name} volume and speed in range`,
		def.volume > 0 and def.volume <= 1 and def.speed > 0.4 and def.speed < 2.5
	)
end

print("Town or route")
local list: { WorldTypes.Biome } = {}
for _, biome in Biomes do
	table.insert(list, biome)
end
local world = Layout.world(list, Tamers.locals)
local hubs: { MusicZone.Hub } = {}
for _, map in world.maps do
	table.insert(hubs, map.hub)
end
check("every biome has a hub", #hubs == #list and #hubs > 0)
local enter, leave = AudioConfig.TOWN_ENTER_MARGIN, AudioConfig.TOWN_LEAVE_MARGIN
for index, hub in hubs do
	check(
		`hub {index} centre is a town`,
		MusicZone.kindAt(hubs, hub.x, hub.z, false, enter, leave) == "town"
	)
	local edge = hub.x + hub.size / 2 + (enter + leave) / 2
	check(
		`hub {index}: between the margins it is route coming in, town going out`,
		MusicZone.kindAt({ hub }, edge, hub.z, false, enter, leave) == "route"
			and MusicZone.kindAt({ hub }, edge, hub.z, true, enter, leave) == "town"
	)
	check(
		`hub {index}: far out is route either way`,
		MusicZone.kindAt({ hub }, hub.x + hub.size + 500, hub.z, true, enter, leave) == "route"
	)
end
check("leaving margin is wider than entering", leave > enter)

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error(`{failed} test(s) failed`)
end
