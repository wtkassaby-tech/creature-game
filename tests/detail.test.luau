--!strict
-- The small ground detail (src/shared/DetailPlan.luau) of the three launch biomes: how many
-- parts it adds (phones stay smooth), that the same biome always gets the same scatter, that it
-- uses only the low-detail models, and that nothing lands on a lane, a prompt, a person, a patch
-- of long grass, a tier's edge or a pool; and the plaza's paving pattern. Run from the project
-- folder:  lune run tests/detail.test

local Biomes = require("../src/content/Biomes")
local DetailConfig = require("../src/config/DetailConfig")
local DetailPlan = require("../src/shared/DetailPlan")
local DustCanyonDressing = require("../src/content/map_data/DustCanyonDressing")
local EdgeTrace = require("../src/shared/EdgeTrace")
local Ground = require("../src/shared/Ground")
local GreenwoodDressing = require("../src/content/map_data/GreenwoodDressing")
local Layout = require("../src/shared/Layout")
local MireDressing = require("../src/content/map_data/MireDressing")
local PropModels = require("../src/content/PropModels")
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

local PART_LIMIT = 600 -- parts a biome's scatter may add
local PLAZA_LIMIT = 120 -- pieces of a plaza's pattern
-- The only models scatter may stand: the small, low-detail ones.
local LOW_DETAIL: { [string]: boolean } = {
	GrassTuft = true,
	DryTuft = true,
	MarramTuft = true,
	Bush = true,
	ScrubBush = true,
	Boulders = true,
	SeaRocks = true,
	Reeds = true,
}

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

local function nearestLine(points: { Layout.Point }, at: Layout.Point): number
	local _, off = EdgeTrace.nearest(points, at.x, at.z)
	return off
end

for _, biome in ordered do
	local dressing = DRESSINGS[biome.id]
	local map = world.maps[biome.number]
	if dressing and map and biome.map then
		print(`\n== {biome.name}: ground detail ==`)
		local origin: Layout.Point = { x = map.hub.x, z = map.hub.z }
		local ground = Ground.new(biome.map, origin)
		local plan = DetailPlan.scatter(biome, map, dressing, ground)
		local again = DetailPlan.scatter(biome, map, dressing, ground)
		local sheet = dressing.scatter
		check("the dressing sheet has a scatter", sheet ~= nil)
		check(
			`it adds {plan.parts} parts, within its budget and {PART_LIMIT}`,
			sheet ~= nil
				and plan.parts <= sheet.budget
				and plan.parts <= PART_LIMIT
				and plan.parts >= 150
		)
		local same = #plan.items == #again.items and plan.parts == again.parts
		for index, item in plan.items do
			local other = again.items[index]
			same = same and other ~= nil and item.x == other.x and item.z == other.z
		end
		check("the same biome always gets the same scatter", same)

		local unlisted: { string } = {}
		if sheet then
			for _, kind in sheet.kinds do
				if kind.shape == "Model" then
					local model = kind.model
					if model == nil or not LOW_DETAIL[model] or PropModels[model] == nil then
						table.insert(unlisted, kind.id)
					end
				end
			end
		end
		check("scatter stands only low-detail models", #unlisted == 0, table.concat(unlisted, ", "))

		-- What an item must keep off.
		local trace = EdgeTrace.new(biome, map, dressing, ground)
		local at = function(point: WorldTypes.SheetPoint): Layout.Point
			return { x = origin.x + point.x, z = origin.z + point.z }
		end
		local bad: { string } = {}
		local function flag(item: DetailPlan.Item, why: string)
			local name = `{item.kind}@{math.floor(item.x)},{math.floor(item.z)} {why}`
			if #bad < 8 then
				table.insert(bad, name)
			end
		end
		local grassPatches: { Layout.GrassCircle } = {}
		for _, patches in map.grass do
			for _, patch in patches do
				table.insert(grassPatches, patch)
			end
		end
		local people: { Layout.Point } = {}
		for _, person in dressing.people do
			table.insert(people, at(person.at))
		end
		local plaza = dressing.plaza
		local plazaAt = at(plaza.at)
		for _, item in plan.items do
			local here: Layout.Point = { x = item.x, z = item.z }
			local fringe = item.zone == "Edging"
			-- Lanes: the routes and the spur, and the town's streets.
			for _, corridor in trace.corridors do
				if
					nearestLine(corridor.points, here)
					< dressing.laneWidth / 2 + (if fringe then 0.2 else 1.5)
				then
					flag(item, "on a route lane")
				end
			end
			if item.zone ~= "Town" and not EdgeTrace.insideAny(trace, item.x, item.z, 2) then
				flag(item, "at or past a corridor edge")
			end
			for index, lane in dressing.lanes do
				local points: { Layout.Point } = {}
				for _, point in lane.points do
					table.insert(points, at(point))
				end
				if nearestLine(points, here) < lane.width / 2 + (if fringe then 0.2 else 1.5) then
					flag(item, `on town lane {index}`)
				end
			end
			for id, spot in trace.spots do
				if Layout.distance(spot, here) < DetailConfig.SPOT_CLEAR - 0.01 then
					flag(item, `near a prompt {id}`)
				end
			end
			for _, person in people do
				if Layout.distance(person, here) < DetailConfig.SPOT_CLEAR - 0.01 then
					flag(item, "near a person")
				end
			end
			for _, patch in grassPatches do
				if Layout.distance(patch, here) < patch.r + 1 then
					flag(item, "in long grass")
				end
			end
			if Layout.distance(plazaAt, here) < plaza.rim / 2 then
				flag(item, "on the plaza")
			end
			if
				Ground.atFoot(ground, item.x, item.z, 3)
				or Ground.linkAt(ground, item.x, item.z, 3) ~= nil
			then
				flag(item, "at a tier's edge or a link")
			end
			if item.zone == "Town" and not EdgeTrace.inTown(map, item.x, item.z, 0) then
				flag(item, "out of town")
			end
			for _, water in dressing.water do
				local points: { Layout.Point } = {}
				for _, point in water.points do
					table.insert(points, at(point))
				end
				if nearestLine(points, here) < water.width / 2 then
					flag(item, "in water")
				end
			end
		end
		check(
			"scatter keeps off lanes, prompts, people, grass, tier edges, the plaza and water",
			#bad == 0,
			table.concat(bad, "; ")
		)

		-- The plaza's pattern.
		local pieces = DetailPlan.plaza(biome, map, dressing, ground)
		local stray: { string } = {}
		for index, piece in pieces do
			if Layout.distance(plazaAt, { x = piece.x, z = piece.z }) > plaza.size / 2 then
				table.insert(stray, `piece {index}`)
			end
			if piece.kind == "Stone" or piece.kind == "Bed" then
				for _, spot in trace.spots do
					if Layout.distance(spot, { x = piece.x, z = piece.z }) < 3 then
						table.insert(stray, `piece {index} on a prompt`)
					end
				end
			end
		end
		check(
			`the plaza's pattern ({#pieces} pieces) is small and on the plaza`,
			#pieces >= 30 and #pieces <= PLAZA_LIMIT and #stray == 0,
			table.concat(stray, ", ")
		)
	end
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("detail checks failed")
end
