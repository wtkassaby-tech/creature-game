--!strict
-- No wall piece lies across a tier's edge (docs/plans/12_MAP_STRUCTURE.md section 4c). The
-- builders lift every part to the ground height under its middle (Elevate), so a hedge, cliff or
-- boulder piece covering ground at two heights would float over the lower tier or sink into the
-- cliff face. This reads the same traced edges the builder joins into pieces (EdgeTrace) and
-- fails if the footprint of any piece covers two heights or a stair or ramp.
-- Run from the project folder:  lune run tests/walltiers

-- The Mire is written ahead of launch (its map and art are built), so this test opens it first.
require("../src/config/ReleaseConfig").OPEN_BIOMES = 4

local Biomes = require("../src/content/Biomes")
local EdgeTrace = require("../src/shared/EdgeTrace")
local Ground = require("../src/shared/Ground")
local Layout = require("../src/shared/Layout")
local Tamers = require("../src/content/Tamers")
local WorldTypes = require("../src/shared/WorldTypes")

local DressingSheets: { [string]: WorldTypes.DressingSheet } = {
	greenwood = require("../src/content/map_data/GreenwoodDressing"),
	dust_canyon = require("../src/content/map_data/DustCanyonDressing"),
	tide_flats = require("../src/content/map_data/TideFlatsDressing"),
	mire = require("../src/content/map_data/MireDressing"),
}

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

local HALF = 2.5 -- studs: how far each side of its line a piece (hedge, bushes, cliff foot) reaches
local TOLERANCE = 0.5 -- studs of height difference that still counts as one height

-- Where the piece between two points covers ground at two heights, or a stair or ramp.
local function straddle(ground: Ground.Ground, a: Layout.Point, b: Layout.Point): string?
	local dx, dz = b.x - a.x, b.z - a.z
	local length = math.sqrt(dx * dx + dz * dz)
	if length < 1e-6 then
		return nil
	end
	local ux, uz = dx / length, dz / length
	local low, high = math.huge, -math.huge
	for step = 0, math.ceil(length) do
		local t = math.min(step, length)
		for _, side in { -HALF, 0, HALF } do
			local x, z = a.x + ux * t - uz * side, a.z + uz * t + ux * side
			local height = Ground.heightAt(ground, x, z)
			low, high = math.min(low, height), math.max(high, height)
			if Ground.linkAt(ground, x, z, 0) then
				return `on a stair or ramp near ({math.floor(x)}, {math.floor(z)})`
			end
		end
	end
	if high - low > TOLERANCE then
		return `heights {low} to {high} near ({math.floor(a.x)}, {math.floor(a.z)})`
	end
	return nil
end

local ordered: { WorldTypes.Biome } = {}
for _, biome in Biomes do
	table.insert(ordered, biome)
end
table.sort(ordered, function(a, b)
	return a.number < b.number
end)
local world = Layout.world(ordered, Tamers.locals)

for _, biome in ordered do
	local map = world.maps[biome.number]
	local dressing = DressingSheets[biome.id]
	if biome.map == nil or map == nil or dressing == nil then
		continue
	end
	print(`\n== {biome.name}: no wall piece lies across a tier edge ==`)
	local origin: Layout.Point = { x = map.hub.x, z = map.hub.z }
	local ground = Ground.new(biome.map, origin)
	local trace = EdgeTrace.new(biome, map, dressing, ground)
	local bad: { string } = {}
	local pieces, count = 0, 0
	local function inspect(label: string, run: { Layout.Point })
		for index = 2, #run do
			pieces += 1
			local why = straddle(ground, run[index - 1], run[index])
			if why then
				count += 1
			end
			if why and #bad < 12 then
				table.insert(bad, `{label} {why}`)
			end
		end
	end
	local function walk(label: string, samples: { any })
		local run: { Layout.Point } = {}
		for _, sample in samples do
			if sample.keep then
				table.insert(run, { x = sample.x, z = sample.z })
			else
				inspect(label, run)
				run = {}
			end
		end
		inspect(label, run)
	end
	for _, corridor in trace.corridors do
		for _, side in { -1, 1 } do
			walk(`{corridor.id} edge {side}`, EdgeTrace.side(trace, corridor, side))
		end
	end
	for index, room in trace.space.sheetRooms do
		walk(`room {index}`, EdgeTrace.room(trace, room))
	end
	-- The edge across the far end of a route, each side of its gap.
	for _, corridor in trace.corridors do
		local gap = dressing.caps[corridor.id]
		if gap then
			local length = corridor.line.length
			local centre = Layout.pointAt(corridor.line, length)
			local runX, runZ = EdgeTrace.heading(corridor.line, length)
			local width = corridor.widthAt(length)
			for _, side in { -1, 1 } do
				inspect(`{corridor.id} cap {side}`, {
					{ x = centre.x - runZ * side * gap, z = centre.z + runX * side * gap },
					{ x = centre.x - runZ * side * width, z = centre.z + runX * side * width },
				})
			end
		end
	end
	for index, ring in trace.rings do
		walk(`ring {index}`, EdgeTrace.ring(trace, ring))
	end
	check(
		`{biome.name}: every wall piece stands wholly on one height ({pieces} pieces)`,
		count == 0,
		`{count} across: ` .. table.concat(bad, "; ")
	)
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("wall and tier checks failed")
end
