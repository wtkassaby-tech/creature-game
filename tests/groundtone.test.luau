--!strict
-- The soft ground patches and the seam band (src/shared/GroundTone.luau): few parts, the same plan
-- every time, kept to level dry ground inside the town or a corridor, off the plaza; and a seam
-- whose colour grades steadily from one biome's field colour to the next. Run from the project
-- folder:  lune run tests/groundtone.test

local Biomes = require("../src/content/Biomes")
local DetailConfig = require("../src/config/DetailConfig")
local DustCanyonDressing = require("../src/content/map_data/DustCanyonDressing")
local EdgeTrace = require("../src/shared/EdgeTrace")
local Ground = require("../src/shared/Ground")
local GreenwoodDressing = require("../src/content/map_data/GreenwoodDressing")
local GroundTone = require("../src/shared/GroundTone")
local Layout = require("../src/shared/Layout")
local MireDressing = require("../src/content/map_data/MireDressing")
local Tamers = require("../src/content/Tamers")
local TideFlatsDressing = require("../src/content/map_data/TideFlatsDressing")
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

local DRESSINGS: { [string]: WorldTypes.DressingSheet } = {
	greenwood = GreenwoodDressing,
	dust_canyon = DustCanyonDressing,
	tide_flats = TideFlatsDressing,
	mire = MireDressing,
}

local ordered: { WorldTypes.Biome } = {}
-- The Mire is built but not yet open (ReleaseConfig), so it is not in Biomes: add it here.
local mire: WorldTypes.Biome = require("../src/content/biome_data/Mire")
Biomes[mire.id] = Biomes[mire.id] or mire
for _, biome in Biomes do
	table.insert(ordered, biome)
end
table.sort(ordered, function(a, b)
	return a.number < b.number
end)
local world = Layout.world(ordered, Tamers.locals)

for _, biome in ordered do
	local dressing = DRESSINGS[biome.id]
	local map = world.maps[biome.number]
	if dressing and map and biome.map then
		print(`\n== {biome.name}: ground tone ==`)
		local origin: Layout.Point = { x = map.hub.x, z = map.hub.z }
		local ground = Ground.new(biome.map, origin)
		local sheet = dressing.blotches
		check("the dressing sheet has soft ground patches", sheet ~= nil)
		local list = GroundTone.blotches(biome, map, dressing, ground)
		local again = GroundTone.blotches(biome, map, dressing, ground)
		check(
			`{#list} patches: some, and within the sheet's budget`,
			sheet ~= nil and #list >= 6 and #list <= sheet.budget and #list * 2 <= 90
		)
		local same = #list == #again
		for index, blotch in list do
			local other = again[index]
			same = same and other ~= nil and other.x == blotch.x and other.z == blotch.z
		end
		check("the same biome always gets the same patches", same)

		local trace = EdgeTrace.new(biome, map, dressing, ground)
		local plaza = dressing.plaza
		local plazaAt: Layout.Point = { x = origin.x + plaza.at.x, z = origin.z + plaza.at.z }
		local bad: { string } = {}
		for index, blotch in list do
			local here: Layout.Point = { x = blotch.x, z = blotch.z }
			local inTown = EdgeTrace.inTown(map, blotch.x, blotch.z, 0)
			if not inTown and not EdgeTrace.insideAny(trace, blotch.x, blotch.z, 2) then
				table.insert(bad, `{index} outside town and corridors`)
			end
			if Layout.distance(plazaAt, here) < plaza.rim / 2 then
				table.insert(bad, `{index} on the plaza`)
			end
			if Ground.atFoot(ground, blotch.x, blotch.z, 3) then
				table.insert(bad, `{index} at a tier's foot`)
			end
			if sheet and (blotch.w < sheet.size[1] - 0.01 or blotch.w > sheet.size[2] + 0.01) then
				table.insert(bad, `{index} wrong size`)
			end
		end
		check(
			"patches keep to the lawn and verges, off the plaza",
			#bad == 0,
			table.concat(bad, "; ")
		)
	end
end

print("\n== the seam ==")
local west = { 70, 118, 58 }
local east = { 153, 106, 76 }
local bands = GroundTone.seam(west, east, 1000, -300, 500)
check(`the seam is a few wide parts ({#bands})`, #bands >= 3 and #bands <= 10)
local width = 0
local ordered_ok = true
local graded = true
for index, band in bands do
	width += band.w
	if index > 1 then
		ordered_ok = ordered_ok and band.x > bands[index - 1].x
		-- Red rises and green falls, west to east: a steady grade.
		graded = graded
			and band.colour[1] >= bands[index - 1].colour[1]
			and band.colour[2] <= bands[index - 1].colour[2]
	end
end
check(
	"the bands run west to east across the seam's width",
	ordered_ok and math.abs(width - DetailConfig.SEAM_WIDTH) < #bands * 0.3
)
check("the colour grades steadily from the west biome's to the east's", graded)
check(
	"the ends are near each biome's own colour",
	math.abs(bands[1].colour[1] - west[1]) < 30 and math.abs(bands[#bands].colour[1] - east[1]) < 30
)
local lowZ, highZ = GroundTone.slabSpan(ordered[1], world.maps[1])
check("a slab spans some depth", highZ - lowZ > 100 and highZ - lowZ <= DetailConfig.SEAM_MAX_DEPTH)

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("ground tone checks failed")
end
