--!strict
-- Checks on every designed map: each biome's map sheet (src/content/map_data/<Biome>.luau), how
-- Layout reads it, and its dressing sheet. The server judges talk, battle, entry and grass ambushes
-- from these points, so they must be sane: every id real, prompts apart, grass where its stretch
-- is, tamers by the lane. Every biome with a sheet gets the same checks (docs/plans/09 section 3f).
-- Run from the project folder:  lune run tests/layout.test
--
-- Over 400 lines on purpose: it is one checklist per sheet, and the map and dressing checks share
-- the same prompt and lane lists.

-- The Mire is written ahead of launch (its map and art are built), so this test opens it first.
require("../src/config/ReleaseConfig").OPEN_BIOMES = 4

local Biomes = require("../src/content/Biomes")
local Chapter1 = require("../src/content/story_data/Chapter1")
local Chapter2 = require("../src/content/story_data/Chapter2")
local Chapter3 = require("../src/content/story_data/Chapter3")
local Chapter4 = require("../src/content/story_data/Chapter4")
local DustCanyonDressing = require("../src/content/map_data/DustCanyonDressing")
local GreenwoodDressing = require("../src/content/map_data/GreenwoodDressing")
local Layout = require("../src/shared/Layout")
local MireDressing = require("../src/content/map_data/MireDressing")
local ReleaseConfig = require("../src/config/ReleaseConfig")
local Walk = require("../src/shared/Walk")
local Tamers = require("../src/content/Tamers")
local TideFlatsDressing = require("../src/content/map_data/TideFlatsDressing")
local WorldConfig = require("../src/config/WorldConfig")
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

-- The story chapter set in each biome, and each biome's dressing sheet (TestMap.DRESSINGS).
local CHAPTERS: { [string]: WorldTypes.Chapter } =
	{ greenwood = Chapter1, dust_canyon = Chapter2, tide_flats = Chapter3, mire = Chapter4 }
local DRESSINGS: { [string]: WorldTypes.DressingSheet } = {
	greenwood = GreenwoodDressing,
	dust_canyon = DustCanyonDressing,
	tide_flats = TideFlatsDressing,
	mire = MireDressing,
}
-- A painted model each designed hub must wear, as a spot check that the sheet is read.
local MODELS: { [string]: { id: string, model: string } } = {
	greenwood = { id = "waystation", model = "Waystation" },
	dust_canyon = { id = "kiln_trading_post", model = "TradingPost" },
	tide_flats = { id = "lamp_tower", model = "LampTower" },
	mire = { id = "bell_loft", model = "LampTower" },
}

-- Every open biome laid out in one world, as the server does.
local ordered: { WorldTypes.Biome } = {}
for _, biome in Biomes do
	table.insert(ordered, biome)
end
table.sort(ordered, function(a, b)
	return a.number < b.number
end)
local world = Layout.world(ordered, Tamers.locals)

local function sumLegs(points: { Layout.Point }): number
	local total = 0
	for index = 1, #points - 1 do
		total += Layout.distance(points[index], points[index + 1])
	end
	return total
end

-- The nearest point of a route's line to `at`: how far along the line it is, and how far off.
local function project(line: Layout.RouteLine, at: Layout.Point): (number, number)
	local bestAlong, bestOff = 0, math.huge
	local covered = 0
	for index = 1, #line.points - 1 do
		local a, b = line.points[index], line.points[index + 1]
		local leg = Layout.distance(a, b)
		if leg > 1e-9 then
			local dx, dz = (b.x - a.x) / leg, (b.z - a.z) / leg
			local t = math.clamp((at.x - a.x) * dx + (at.z - a.z) * dz, 0, leg)
			local off = Layout.distance({ x = a.x + dx * t, z = a.z + dz * t }, at)
			if off < bestOff then
				bestAlong, bestOff = covered + t, off
			end
		end
		covered += leg
	end
	return bestAlong, bestOff
end

local function areaAt(route: WorldTypes.Route, along: number): WorldTypes.Area?
	for _, area in route.areas do
		if along >= area.from and along <= area.to then
			return area
		end
	end
	return nil
end

local function join(list: { string }): string?
	return if #list == 0 then nil else table.concat(list, ", ")
end

print("\n== Fitting a line ==")
do
	local square: { Layout.Point } = { { x = 0, z = 0 }, { x = 10, z = 0 }, { x = 10, z = 10 } }
	local cut = Layout.fit(square, 15)
	check(
		"a line too long is cut inside the leg where the length runs out",
		#cut == 3 and math.abs(cut[3].x - 10) < 1e-9 and math.abs(cut[3].z - 5) < 1e-9
	)
	local early = Layout.fit(square, 4)
	check("a cut can fall in the first leg", #early == 2 and math.abs(early[2].x - 4) < 1e-9)
	local stretched = Layout.fit(square, 26)
	check(
		"a line too short has its last leg stretched",
		#stretched == 3 and math.abs(stretched[3].z - 16) < 1e-9 and stretched[3].x == 10
	)
	local north, east = Layout.facing(0), Layout.facing(90)
	check(
		"a facing of 0 points north (-z) and 90 points east (+x)",
		math.abs(north.z + 1) < 1e-9
			and math.abs(north.x) < 1e-9
			and math.abs(east.x - 1) < 1e-9
			and math.abs(east.z) < 1e-9
	)
end

-- Every point a player presses a prompt at in one biome.
type Prompt = { id: string, at: Layout.Point }
local function promptsOf(biome: WorldTypes.Biome, map: Layout.Map): { Prompt }
	local prompts: { Prompt } = {}
	for _, building in biome.hub.buildings do
		table.insert(prompts, { id = building.id, at = map.places[building.id] })
	end
	for _, route in biome.routes do
		for _, tamerId in route.tamers do
			table.insert(prompts, { id = tamerId, at = map.places[tamerId] })
		end
		for _, spot in route.rustleSpots do
			table.insert(prompts, { id = spot.id, at = map.places[spot.id] })
		end
	end
	table.insert(prompts, { id = "stall", at = map.places[Layout.stallId(biome)] })
	for id, point in map.stands do
		table.insert(prompts, { id = id, at = point })
	end
	return prompts
end

-- The map checks for one biome with a sheet, laid out where the world puts it.
local function checkMap(biome: WorldTypes.Biome, map: Layout.Map)
	local sheet: WorldTypes.MapSheet = assert(biome.map, `{biome.id} has a map sheet`)
	local chapter = CHAPTERS[biome.id]
	local origin: Layout.Point = { x = map.hub.x, z = map.hub.z }
	local function at(point: WorldTypes.SheetPoint): Layout.Point
		return { x = origin.x + point.x, z = origin.z + point.z }
	end
	-- The same biome with no sheet: the ids the generated layout knows.
	local plain: any = table.clone(biome)
	plain.map = nil
	local generated = Layout.build(plain, Tamers.locals)
	-- The sheet's optional tables, empty when left out.
	local sheetStands: { [string]: WorldTypes.SheetPoint } = sheet.stands or {}
	local sheetSpurs: { [string]: { WorldTypes.SheetPoint } } = sheet.spurs or {}
	local sheetCorridor: { [string]: number } = sheet.corridor or {}
	local sheetFaces: { [string]: number } = sheet.faces or {}
	local function routeOf(id: string): WorldTypes.Route?
		for _, route in biome.routes do
			if route.id == id then
				return route
			end
		end
		return nil
	end
	local gateRoute = assert(routeOf(biome.gate.route), "the gate's route")
	local space = Walk.space(biome, map, DRESSINGS[biome.id])
	local function patchesOf(areaId: string): { Layout.GrassCircle }
		local listed = map.grass[areaId]
		return if listed then listed else {}
	end

	print(`\n== {biome.name}: the sheet names only real things ==`)
	do
		local unknown: { string } = {}
		for id in sheet.routes do
			if routeOf(id) == nil then
				table.insert(unknown, `route {id}`)
			end
		end
		local buildingIds: { [string]: boolean } = {}
		for _, building in biome.hub.buildings do
			buildingIds[building.id] = true
		end
		for id in sheet.buildings do
			if not buildingIds[id] then
				table.insert(unknown, `building {id}`)
			end
		end
		for id, point in sheet.places do
			local placed = map.places[id]
			local wanted = at(point)
			if generated.places[id] == nil or placed == nil then
				table.insert(unknown, `place {id}`)
			elseif Layout.distance(placed, wanted) > 1e-6 then
				table.insert(unknown, `place {id} (not applied)`)
			end
		end
		for id in sheetStands do
			local battle = Tamers.story[id]
			if battle == nil or map.places[battle.place] == nil then
				table.insert(unknown, `stand {id}`)
			end
		end
		for id in sheetSpurs do
			if id ~= biome.lair.id then
				table.insert(unknown, `spur {id}`)
			end
		end
		local areaIds: { [string]: boolean } = { [biome.lair.id] = true }
		for _, route in biome.routes do
			for _, area in route.areas do
				areaIds[area.id] = true
			end
		end
		for id in sheetCorridor do
			if not areaIds[id] then
				table.insert(unknown, `corridor {id}`)
			end
		end
		for id in sheetFaces do
			if Tamers.locals[id] == nil and Tamers.story[id] == nil then
				table.insert(unknown, `faces {id}`)
			end
		end
		check(
			"every id on the sheet is a real id, and every set spot is used",
			#unknown == 0,
			join(unknown)
		)
		local lost: { string } = {}
		for id in generated.places do
			if map.places[id] == nil then
				table.insert(lost, id)
			end
		end
		check("every place the generated layout made still exists", #lost == 0, join(lost))
		local noWidth: { string } = {}
		for id in areaIds do
			if sheetCorridor[id] == nil then
				table.insert(noWidth, id)
			end
		end
		check("every stretch and the spur has a corridor width", #noWidth == 0, join(noWidth))
	end

	print(`\n== {biome.name}: lines ==`)
	do
		local off: { string } = {}
		for id, drawn in sheet.routes do
			local route = assert(routeOf(id), id)
			local total = sumLegs(drawn.points)
			if math.abs(total - route.length) > 5 then
				table.insert(off, `{id} {total}`)
			end
		end
		for _, points in sheetSpurs do
			local spur = sumLegs(points)
			if math.abs(spur - biome.lair.spurLength) > 5 then
				table.insert(off, `spur {spur}`)
			end
		end
		check("each drawn line is within 5 studs of its length in the data", #off == 0, join(off))
		local exact = true
		for _, route in biome.routes do
			exact = exact and math.abs(sumLegs(map.routes[route.id].points) - route.length) < 0.001
		end
		exact = exact and math.abs(sumLegs(map.lairSpur) - biome.lair.spurLength) < 0.001
		check("each fitted line is exactly its length in the data", exact)
		local b = map.routes[gateRoute.id]
		local gate, sealed = map.places[biome.gate.id], map.places[biome.gate.sealedPath]
		-- The sealed road runs on 60 studs in the route's last direction: due east for the first
		-- three biomes, due north for the Mire (the Rimewater Gorge goes north).
		local last, before = b.points[#b.points], b.points[#b.points - 1]
		local run = math.max(Layout.distance(before, last), 1e-6)
		check(
			"the gate ends its route and the sealed road runs on 60 along its last leg",
			Layout.distance(gate, last) < 0.001
				and math.abs(sealed.x - gate.x - (last.x - before.x) / run * 60) < 0.01
				and math.abs(sealed.z - gate.z - (last.z - before.z) / run * 60) < 0.01
				and (biome.site ~= nil or math.abs(sealed.x - gate.x - 60) < 0.01)
		)
		local lairRoute = map.routes[biome.lair.joinsRoute]
		check(
			"the spur starts on its route where the data says it joins",
			Layout.distance(map.lairSpur[1], Layout.pointAt(lairRoute, biome.lair.joinsAt)) < 0.001
		)
	end

	print(`\n== {biome.name}: everything the story and the tamers need has a place ==`)
	do
		local missing: { string } = {}
		if chapter == nil then
			table.insert(missing, "no story chapter for this biome")
		end
		local beats: { WorldTypes.Beat } = if chapter then chapter.beats else {}
		for _, beat in beats do
			local target = beat.trigger.target
			if target then
				local battle = Tamers.story[target]
				local id = if battle then battle.place else target
				if map.places[id] == nil then
					table.insert(missing, `{beat.id}: {target}`)
				end
			end
		end
		for _, route in biome.routes do
			for _, tamerId in route.tamers do
				if map.places[tamerId] == nil or sheetFaces[tamerId] == nil then
					table.insert(missing, tamerId)
				end
			end
		end
		for id, battle in Tamers.story do
			if map.places[battle.place] and generated.places[battle.place] then
				if battle.place == biome.hub.id or battle.place == biome.gate.id then
					if map.stands[id] == nil then
						table.insert(missing, `stand for {id}`)
					end
				end
			end
		end
		check(
			"every story target, local tamer and story battle has a place (and a stand)",
			#missing == 0,
			join(missing)
		)
	end

	local prompts = promptsOf(biome, map)
	print(`\n== {biome.name}: prompts ==`)
	do
		local close: { string } = {}
		for index = 1, #prompts do
			for other = index + 1, #prompts do
				local a, b = prompts[index], prompts[other]
				local gap = Layout.distance(a.at, b.at)
				if gap < 32 then
					table.insert(close, `{a.id}/{b.id} {math.floor(gap * 10) / 10}`)
				end
			end
		end
		check("no two prompts are within 32 studs of each other", #close == 0, join(close))
		local far: { string } = {}
		for id, point in map.stands do
			local battle = Tamers.story[id]
			local place = map.places[battle.place]
			if Layout.distance(point, place) > WorldConfig.POSITION_SLACK then
				table.insert(far, id)
			end
		end
		check(
			"each story battler stands within the server's slack of its place",
			#far == 0,
			join(far)
		)
	end

	print(`\n== {biome.name}: long grass ==`)
	do
		local wrong: { string } = {}
		local patches: { { id: string, at: Layout.Point } } = {}
		for _, route in biome.routes do
			local line = map.routes[route.id]
			for _, area in route.areas do
				local id = Layout.grassId(area.id)
				local patch = map.places[id]
				local along = project(line, patch)
				if along < area.from or along > area.to then
					table.insert(wrong, `{id} at {math.floor(along)}`)
				end
				table.insert(patches, { id = id, at = patch })
			end
		end
		check("each grass patch lies inside its own stretch", #wrong == 0, join(wrong))
		local overlaps: { string } = {}
		for index = 1, #patches do
			for other = index + 1, #patches do
				if
					Layout.distance(patches[index].at, patches[other].at)
					< WorldConfig.GRASS_RADIUS * 2
				then
					table.insert(overlaps, `{patches[index].id}/{patches[other].id}`)
				end
			end
			local spot = patches[index].at
			local edge = biome.hub.size / 2 + WorldConfig.GRASS_RADIUS
			if math.abs(spot.x - map.hub.x) < edge and math.abs(spot.z - map.hub.z) < edge then
				table.insert(overlaps, `{patches[index].id}/town`)
			end
			for _, route in biome.routes do
				for _, tamerId in route.tamers do
					if Layout.distance(map.places[tamerId], spot) <= WorldConfig.GRASS_RADIUS then
						table.insert(overlaps, `{patches[index].id}/{tamerId}`)
					end
				end
			end
		end
		check(
			"no patch overlaps another patch, the town or a tamer",
			#overlaps == 0,
			join(overlaps)
		)
		-- A grass ambush never starts while a player is pressing a prompt beside it.
		local crowded: { string } = {}
		for _, patch in patches do
			for _, prompt in prompts do
				if Layout.distance(patch.at, prompt.at) < 26 then
					table.insert(crowded, `{patch.id}/{prompt.id}`)
				end
			end
		end
		check("no patch comes within 26 studs of a prompt", #crowded == 0, join(crowded))
	end

	print(`\n== {biome.name}: tamers, rustle spots and corridors ==`)
	do
		local astray: { string } = {}
		for _, route in biome.routes do
			local line = map.routes[route.id]
			for _, tamerId in route.tamers do
				local tamer = Tamers.locals[tamerId]
				local spot = map.places[tamerId]
				local _, off = project(line, spot)
				local fromAt = Layout.distance(spot, Layout.pointAt(line, tamer.at))
				if off > 12 or fromAt > 40 then
					table.insert(
						astray,
						`{tamerId} off {math.floor(off)} from at {math.floor(fromAt)}`
					)
				end
			end
			for _, rustle in route.rustleSpots do
				local _, off = project(line, map.places[rustle.id])
				if off > 30 then
					table.insert(astray, `{rustle.id} off {math.floor(off)}`)
				end
			end
		end
		check(
			"each tamer is by its lane near its distance, each rustle spot near its lane",
			#astray == 0,
			join(astray)
		)

		local outside: { string } = {}
		for _, route in biome.routes do
			local line = map.routes[route.id]
			local widths = line.halfWidth or {}
			local narrow = line.widths ~= nil
			local function inside(id: string, spot: Layout.Point, reach: number)
				if narrow then
					-- Narrow lanes and rooms: the spot, and a circle of `reach` round it, lie wholly
					-- in walkable space (the lane at its half-width there, a room, or the town).
					local worst = Walk.depth(space, spot.x, spot.z, true, nil)
					for k = 0, 11 do
						local angle = k / 12 * math.pi * 2
						worst = math.min(
							worst,
							Walk.depth(
								space,
								spot.x + math.cos(angle) * reach,
								spot.z + math.sin(angle) * reach,
								true,
								nil
							)
						)
					end
					if worst < -0.5 then
						table.insert(outside, id)
					end
					return
				end
				local along, off = project(line, spot)
				local area = areaAt(route, along)
				local width = if area then widths[area.id] else nil
				if width == nil or off + reach > width then
					table.insert(outside, id)
				end
			end
			for _, area in route.areas do
				inside(area.id, map.places[area.id], 0)
				for number, patch in patchesOf(area.id) do
					inside(`{Layout.grassId(area.id)} {number}`, patch, patch.r)
				end
			end
			for _, rustle in route.rustleSpots do
				inside(rustle.id, map.places[rustle.id], 0)
			end
			for _, tamerId in route.tamers do
				inside(tamerId, map.places[tamerId], 0)
			end
			-- Wild creatures stand up to this far either side of the lane (those that hide in
			-- long grass are inside its patch, checked above).
			if not narrow then
				inside(
					`{route.id} creatures`,
					Layout.pointAt(line, 1),
					WorldConfig.SPAWN_SIDE_OFFSET
				)
			end
		end
		check(
			"every route place, grass edge included, is inside its corridor or room",
			#outside == 0,
			join(outside)
		)
		local spurWidth = map.lairHalfWidth
		check(
			"the spur has its corridor width, and the stall stands on it",
			spurWidth ~= nil
				and Layout.distance(
						map.places[Layout.stallId(biome)],
						Layout.pointAt({
							id = "spur",
							points = map.lairSpur,
							length = biome.lair.spurLength,
							side = 0,
						}, WorldConfig.STALL_DISTANCE)
					)
					< 0.001
		)
	end

	print(`\n== {biome.name}: town ==`)
	do
		local problems: { string } = {}
		local ids: { string } = {}
		for _, building in biome.hub.buildings do
			table.insert(ids, building.id)
			local middle = map.buildings[building.id]
			local reach = biome.hub.size / 2 - 14
			if math.abs(middle.x - map.hub.x) > reach or math.abs(middle.z - map.hub.z) > reach then
				table.insert(problems, `{building.id} outside the town`)
			end
		end
		for index = 1, #ids do
			for other = index + 1, #ids do
				local gap = Layout.distance(map.buildings[ids[index]], map.buildings[ids[other]])
				if gap < 28 then
					table.insert(problems, `{ids[index]}/{ids[other]} {math.floor(gap)}`)
				end
			end
		end
		check(
			"buildings stand inside the town and apart from each other",
			#problems == 0,
			join(problems)
		)
		local firstRoute = biome.routes[1]
		local entry = map.places[firstRoute.id]
		local near: { string } = {}
		for _, building in biome.hub.buildings do
			if Layout.distance(entry, map.places[building.id]) <= 48 then
				table.insert(near, building.id)
			end
		end
		check(
			"entering the first route is more than 48 studs from every town door",
			#near == 0,
			join(near)
		)
		local spawn = sheet.spawn
		if biome.number == 1 then
			local arrive = map.spawn
			check(
				"players arrive in the square facing north",
				arrive ~= nil
					and arrive.faces == 0
					and Layout.distance(arrive.at, map.places[biome.hub.id]) < 20
			)
			check(
				"the keepers' facings come from the sheet",
				map.faces.mentor == 180 and map.faces.shop == 0
			)
		elseif biome.site == nil then
			-- A later biome is entered from the west: the arrival is just inside the town's west
			-- edge, facing within 45 degrees of the hub's centre.
			local half = biome.hub.size / 2
			local ok = false
			if spawn then
				local toHub = math.deg(math.atan2(-spawn.at.x, spawn.at.z)) % 360
				local turn = math.abs((spawn.faces - toHub + 180) % 360 - 180)
				ok = spawn.at.x >= -half
					and spawn.at.x <= -half + 30
					and math.abs(spawn.at.z) <= 30
					and turn <= 45
			end
			check("players arrive just inside the west edge, facing the town", ok)
		else
			-- A sited biome (the Mire) is entered by its own causeway: the arrival is just inside
			-- the town's edge on that side (the south arch), facing within 45 degrees of the
			-- hub's centre.
			local half = biome.hub.size / 2
			local ok = false
			if spawn then
				local toHub = math.deg(math.atan2(-spawn.at.x, spawn.at.z)) % 360
				local turn = math.abs((spawn.faces - toHub + 180) % 360 - 180)
				local inset = half - math.max(math.abs(spawn.at.x), math.abs(spawn.at.z))
				ok = inset >= 0 and inset <= 30 and turn <= 45
			end
			check("players arrive just inside the town's edge, facing the town", ok)
		end
		local wanted = MODELS[biome.id]
		check(
			"each hub building wears the painted model the sheet names",
			wanted ~= nil and map.models[wanted.id] == wanted.model
		)
	end
end

-- The dressing checks for one biome: nothing built on a prompt or across a lane, and, for a
-- biome after Greenwood, every stretch has its edges, planting and grass look.
local function checkDressing(
	biome: WorldTypes.Biome,
	map: Layout.Map,
	dressing: WorldTypes.DressingSheet
)
	print(`\n== {biome.name}: dressing keeps clear of prompts and lanes ==`)
	local origin: Layout.Point = { x = map.hub.x, z = map.hub.z }
	local function at(point: WorldTypes.SheetPoint): Layout.Point
		return { x = origin.x + point.x, z = origin.z + point.z }
	end
	local prompts = promptsOf(biome, map)

	-- Every lane a fence must not cross: the routes, the spur and the town's streets.
	type Lane = { name: string, points: { Layout.Point }, half: number }
	local lanes: { Lane } = {}
	for _, route in biome.routes do
		table.insert(lanes, {
			name = route.id,
			points = map.routes[route.id].points,
			half = dressing.laneWidth / 2,
		})
	end
	table.insert(lanes, { name = "spur", points = map.lairSpur, half = dressing.laneWidth / 2 })
	for index, lane in dressing.lanes do
		local points: { Layout.Point } = {}
		for _, point in lane.points do
			table.insert(points, at(point))
		end
		table.insert(lanes, { name = `lane {index}`, points = points, half = lane.width / 2 })
	end
	local function offLane(lane: Lane, point: Layout.Point): number
		local line: Layout.RouteLine =
			{ id = lane.name, points = lane.points, length = sumLegs(lane.points), side = 0 }
		local _, off = project(line, point)
		return off
	end

	-- A run sampled every stud.
	local function samples(points: { Layout.Point }): { Layout.Point }
		local out: { Layout.Point } = {}
		for index = 1, #points - 1 do
			local a, b = points[index], points[index + 1]
			local steps = math.max(1, math.ceil(Layout.distance(a, b)))
			for step = 0, steps do
				local t = step / steps
				table.insert(out, { x = a.x + (b.x - a.x) * t, z = a.z + (b.z - a.z) * t })
			end
		end
		return out
	end

	local tooNear: { string } = {}
	local crossing: { string } = {}
	local function checkRun(name: string, points: { WorldTypes.SheetPoint }, across: boolean)
		local placed: { Layout.Point } = {}
		for _, point in points do
			table.insert(placed, at(point))
		end
		local nearSeen: { [string]: boolean } = {}
		local laneSeen: { [string]: boolean } = {}
		for _, point in samples(placed) do
			for _, prompt in prompts do
				if not nearSeen[prompt.id] and Layout.distance(point, prompt.at) < 6 then
					nearSeen[prompt.id] = true
					table.insert(tooNear, `{name}/{prompt.id}`)
				end
			end
			if not across then
				for _, lane in lanes do
					if not laneSeen[lane.name] and offLane(lane, point) < lane.half then
						laneSeen[lane.name] = true
						table.insert(crossing, `{name}/{lane.name}`)
					end
				end
			end
		end
	end
	for index, fence in dressing.fences do
		checkRun(`fence {index} ({fence.style})`, fence.points, fence.across == true)
	end
	for index, hedge in dressing.hedges do
		checkRun(`hedge {index}`, hedge, false)
	end
	local walls: { WorldTypes.DressWall } = dressing.walls or {}
	for index, wall in walls do
		checkRun(`wall {index} ({wall.style})`, wall.points, false)
	end

	-- Buildings with no keeper, and the gatehouse's towers, as boxes.
	type Box = { name: string, at: Layout.Point, faces: number, width: number, depth: number }
	local boxes: { Box } = {}
	for index, house in dressing.houses do
		table.insert(boxes, {
			name = `house {index}`,
			at = at(house.at),
			faces = house.faces,
			width = house.width,
			depth = house.depth,
		})
	end
	-- Carts, barrels and boulders that block the way count too, as squares.
	for index, thing in dressing.props do
		if thing.solid then
			table.insert(boxes, {
				name = `{thing.model} {index}`,
				at = at(thing.at),
				faces = thing.faces,
				width = thing.tall * 0.8,
				depth = thing.tall * 0.8,
			})
		end
	end
	local standing = #boxes -- houses and props: these must also keep off the town's lanes
	local gate = dressing.gatehouse
	local across = Layout.facing(gate.faces + 90)
	for _, side in { -1, 1 } do
		local middle = at(gate.at)
		table.insert(boxes, {
			name = `gatehouse tower {side}`,
			at = { x = middle.x + across.x * 13 * side, z = middle.z + across.z * 13 * side },
			faces = gate.faces,
			width = 12,
			depth = 12,
		})
	end
	local function boxGap(box: Box, point: Layout.Point): number
		local ahead = Layout.facing(box.faces)
		local dx, dz = point.x - box.at.x, point.z - box.at.z
		local depth = math.abs(dx * ahead.x + dz * ahead.z) - box.depth / 2
		local width = math.abs(dx * -ahead.z + dz * ahead.x) - box.width / 2
		return math.sqrt(math.max(depth, 0) ^ 2 + math.max(width, 0) ^ 2)
	end
	for _, box in boxes do
		for _, prompt in prompts do
			if boxGap(box, prompt.at) < 6 then
				table.insert(tooNear, `{box.name}/{prompt.id}`)
			end
		end
	end
	-- Nothing is built on a street or a path: every two studs along each town lane is clear of
	-- every house and solid prop by half the lane's width.
	local onLane: { string } = {}
	for laneIndex, lane in dressing.lanes do
		for index = 1, #lane.points - 1 do
			local from, to = at(lane.points[index]), at(lane.points[index + 1])
			local length = Layout.distance(from, to)
			for step = 0, math.floor(length / 2) do
				local t = math.min(step * 2 / math.max(length, 1), 1)
				local point = { x = from.x + (to.x - from.x) * t, z = from.z + (to.z - from.z) * t }
				for number = 1, standing do
					local box = boxes[number]
					local label = `{box.name}/lane {laneIndex}`
					if boxGap(box, point) < lane.width / 2 and not table.find(onLane, label) then
						table.insert(onLane, label)
					end
				end
			end
		end
	end
	check("no house or solid prop stands on a town lane", #onLane == 0, join(onLane))
	check(
		"no fence, hedge, wall or building comes within 6 studs of a prompt",
		#tooNear == 0,
		join(tooNear)
	)
	check(
		"no fence, hedge or wall crosses a lane except where it closes one on purpose",
		#crossing == 0,
		join(crossing)
	)
	local patches: { Layout.Point } = {}
	for _, route in biome.routes do
		for _, area in route.areas do
			table.insert(patches, map.places[Layout.grassId(area.id)])
		end
	end
	local grassClear = true
	for _, patch in patches do
		for _, lamp in dressing.lamps do
			grassClear = grassClear and Layout.distance(at(lamp), patch) > WorldConfig.GRASS_RADIUS
		end
	end
	check("no lamp stands in long grass", grassClear)

	-- Lamps, signposts and planters stand beside the lanes, not on them, and clear of prompts.
	local inTheWay: { string } = {}
	local function clearSpot(name: string, point: WorldTypes.SheetPoint)
		local spot = at(point)
		for _, lane in lanes do
			if offLane(lane, spot) < lane.half then
				table.insert(inTheWay, `{name}/{lane.name}`)
			end
		end
		for _, prompt in prompts do
			if Layout.distance(spot, prompt.at) < 6 then
				table.insert(inTheWay, `{name}/{prompt.id}`)
			end
		end
	end
	for index, lamp in dressing.lamps do
		clearSpot(`lamp {index}`, lamp)
	end
	for index, sign in dressing.signs do
		clearSpot(`sign {index}`, sign.at)
	end
	for index, bed in dressing.beds do
		clearSpot(`bed {index}`, bed)
	end
	-- (Plan 09's rule. Greenwood's sheet has a lamp at (120, -11) on the short path to its east
	-- cottage, and Greenwood is not to change here, so the rule starts with the next biome.)
	if biome.number > 1 then
		check(
			"lamps, signposts and planters stand off every lane and clear of prompts",
			#inTheWay == 0,
			join(inTheWay)
		)
	end

	-- Houses and solid props do not overlap each other or the hub's buildings.
	local solids: { Box } = table.move(boxes, 1, standing, 1, {})
	for id, size in dressing.buildings do
		local middle, faces = map.buildings[id], map.faces[id]
		if middle and faces then
			table.insert(solids, {
				name = id,
				at = middle,
				faces = faces,
				width = size.width,
				depth = size.depth,
			})
		end
	end
	-- The corners, the middles of the sides and the centre of a box.
	local function outline(box: Box): { Layout.Point }
		local ahead = Layout.facing(box.faces)
		local side: Layout.Point = { x = -ahead.z, z = ahead.x }
		local out: { Layout.Point } = {}
		for _, u in { -1, 0, 1 } do
			for _, v in { -1, 0, 1 } do
				local d, w = u * box.depth / 2, v * box.width / 2
				table.insert(out, {
					x = box.at.x + ahead.x * d + side.x * w,
					z = box.at.z + ahead.z * d + side.z * w,
				})
			end
		end
		return out
	end
	local overlapping: { string } = {}
	for index = 1, #solids do
		for other = index + 1, #solids do
			local a, b = solids[index], solids[other]
			local hit = false
			for _, point in outline(a) do
				hit = hit or boxGap(b, point) <= 0
			end
			for _, point in outline(b) do
				hit = hit or boxGap(a, point) <= 0
			end
			if hit then
				table.insert(overlapping, `{a.name}/{b.name}`)
			end
		end
	end
	check(
		"houses and solid props overlap neither each other nor the hub's buildings",
		#overlapping == 0,
		join(overlapping)
	)

	if biome.number == 1 then
		return
	end
	-- A biome after Greenwood has no hedges or green trees by default: every corridor names its
	-- edges and planting, every stretch its grass, and the sheet has a landmark.
	local missing: { string } = {}
	local edges: { [string]: WorldTypes.DressEdge } = dressing.edges or {}
	local looks: { [string]: WorldTypes.GrassLook } = dressing.grassLooks or {}
	local keys: { string } = { biome.lair.id }
	for _, route in biome.routes do
		for _, area in route.areas do
			table.insert(keys, area.id)
			if looks[area.id] == nil then
				table.insert(missing, `grass look {area.id}`)
			end
		end
	end
	for _, key in keys do
		if edges[key] == nil then
			table.insert(missing, `edges {key}`)
		end
		if dressing.corridorTrees[key] == nil then
			table.insert(missing, `planting {key}`)
		end
	end
	if dressing.landmark == nil then
		table.insert(missing, "landmark")
	end
	check(
		"every stretch and the spur has edges and planting, every stretch a grass look, and a landmark",
		#missing == 0,
		join(missing)
	)
	-- Nobody presses a prompt or walks into long grass out at sea.
	local wet: { string } = {}
	local spots: { Prompt } = table.clone(prompts)
	for _, route in biome.routes do
		for _, area in route.areas do
			local id = Layout.grassId(area.id)
			table.insert(spots, { id = id, at = map.places[id] })
		end
	end
	local flats: { WorldTypes.DressFlat } = dressing.flats or {}
	for _, flat in flats do
		if flat.water then
			local a, b = at(flat.from), at(flat.to)
			for _, spot in spots do
				if
					spot.at.x >= math.min(a.x, b.x)
					and spot.at.x <= math.max(a.x, b.x)
					and spot.at.z >= math.min(a.z, b.z)
					and spot.at.z <= math.max(a.z, b.z)
				then
					table.insert(wet, spot.id)
				end
			end
		end
	end
	check("no prompt or grass centre lies inside a water flat", #wet == 0, join(wet))
end

-- Every biome with a map sheet.
for _, biome in ordered do
	local map = world.maps[biome.number]
	if biome.map and map then
		checkMap(biome, map)
		local dressing = DRESSINGS[biome.id]
		check(`{biome.name} has a dressing sheet`, dressing ~= nil)
		if dressing then
			checkDressing(biome, map, dressing)
		end
	end
end

print("\n== The world ==")
do
	-- Every open biome is designed: a map sheet and a dressing sheet each (plan 10 section 8).
	local unsheeted: { string } = {}
	for _, biome in ordered do
		if biome.map == nil or DRESSINGS[biome.id] == nil then
			table.insert(unsheeted, biome.id)
		end
	end
	check(
		"every open biome has a map sheet and a dressing sheet",
		#ordered == ReleaseConfig.OPEN_BIOMES and #unsheeted == 0,
		join(unsheeted)
	)
	-- The designed biomes come first: no biome without a sheet sits between two with one. (With
	-- every open biome sheeted this guards the day a later biome opens without one.)
	local gap = false
	local unsheetedSeen = false
	for _, biome in ordered do
		if biome.map == nil then
			unsheetedSeen = true
		elseif unsheetedSeen then
			gap = true
		end
	end
	check("the biomes with a map sheet are the first ones in order", not gap)
	local close: { string } = {}
	for index = 1, #ordered - 1 do
		local a, b = ordered[index], ordered[index + 1]
		for id, place in world.maps[a.number].places do
			for otherId, other in world.maps[b.number].places do
				if Layout.distance(place, other) <= 100 then
					table.insert(close, `{id}/{otherId}`)
				end
			end
		end
	end
	check(
		"every place of each biome is more than 100 studs from every place of the next",
		#close == 0,
		join(close)
	)
	check(
		"the world keeps Greenwood's facings, stands and spawn",
		world.map.faces.gw_pip == 60
			and world.map.stands.rival_first ~= nil
			and world.map.spawn ~= nil
	)
	local canyon = world.maps[2]
	check(
		"Dust Canyon's hub sits where its plan says, 240 past Greenwood's sealed road",
		canyon ~= nil and math.abs(canyon.hub.x - 984.4) < 0.1 and math.abs(canyon.hub.z + 80) < 0.1
	)
	local flats = world.maps[3]
	check(
		"Tide Flats' hub sits where its plan says, 240 past Dust Canyon's sealed road",
		flats ~= nil and math.abs(flats.hub.x - 2063.4) < 0.1 and math.abs(flats.hub.z + 180) < 0.1
	)
	local mire = world.maps[4]
	check(
		"the Mire's hub sits at its site, (3100, -550), and is not sited straight on",
		mire ~= nil and math.abs(mire.hub.x - 3100) < 0.1 and math.abs(mire.hub.z + 550) < 0.1
	)
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("layout checks failed")
end
