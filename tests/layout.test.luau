--!strict
-- Checks on a designed map: Greenwood's map sheet (src/content/map_data/Greenwood.luau) and how
-- Layout reads it. The server judges talk, battle, entry and grass ambushes from these points, so
-- they must be sane: every id real, prompts apart, grass where its stretch is, tamers by the lane.
-- Run from the project folder:  lune run tests/layout.test

local Biomes = require("../src/content/Biomes")
local Chapter1 = require("../src/content/story_data/Chapter1")
local Layout = require("../src/shared/Layout")
local Tamers = require("../src/content/Tamers")
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

local greenwood = Biomes.greenwood
local sheet: WorldTypes.MapSheet = assert(greenwood.map, "Greenwood has a map sheet")
local map = Layout.build(greenwood, Tamers.locals)
-- The same biome with no sheet: the ids the generated layout knows.
local plain: any = table.clone(greenwood)
plain.map = nil
local generated = Layout.build(plain, Tamers.locals)
-- The sheet's optional tables, empty when left out.
local sheetStands: { [string]: WorldTypes.SheetPoint } = sheet.stands or {}
local sheetSpurs: { [string]: { WorldTypes.SheetPoint } } = sheet.spurs or {}
local sheetCorridor: { [string]: number } = sheet.corridor or {}
local sheetFaces: { [string]: number } = sheet.faces or {}

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

local function routeOf(id: string): WorldTypes.Route?
	for _, route in greenwood.routes do
		if route.id == id then
			return route
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

print("\n== The sheet names only real things ==")
do
	local unknown: { string } = {}
	for id in sheet.routes do
		if routeOf(id) == nil then
			table.insert(unknown, `route {id}`)
		end
	end
	local buildingIds: { [string]: boolean } = {}
	for _, building in greenwood.hub.buildings do
		buildingIds[building.id] = true
	end
	for id in sheet.buildings do
		if not buildingIds[id] then
			table.insert(unknown, `building {id}`)
		end
	end
	for id, point in sheet.places do
		local placed = map.places[id]
		if generated.places[id] == nil or placed == nil then
			table.insert(unknown, `place {id}`)
		elseif placed.x ~= point.x or placed.z ~= point.z then
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
		if id ~= greenwood.lair.id then
			table.insert(unknown, `spur {id}`)
		end
	end
	local areaIds: { [string]: boolean } = { [greenwood.lair.id] = true }
	for _, route in greenwood.routes do
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

print("\n== Lines ==")
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
		if math.abs(spur - greenwood.lair.spurLength) > 5 then
			table.insert(off, `spur {spur}`)
		end
	end
	check("each drawn line is within 5 studs of its length in the data", #off == 0, join(off))
	local exact = true
	for _, route in greenwood.routes do
		exact = exact and math.abs(sumLegs(map.routes[route.id].points) - route.length) < 0.001
	end
	exact = exact and math.abs(sumLegs(map.lairSpur) - greenwood.lair.spurLength) < 0.001
	check("each fitted line is exactly its length in the data", exact)
	local b = map.routes.greenwood_route_b
	check(
		"the gate is the end of River Road and the sealed road runs on 60 due east",
		Layout.distance(map.places.greenwood_gate, b.points[#b.points]) < 0.001
			and math.abs(map.places.greenwood_sealed_path.x - map.places.greenwood_gate.x - 60) < 0.01
			and math.abs(map.places.greenwood_sealed_path.z - map.places.greenwood_gate.z)
				< 0.01
	)
	check(
		"the spur starts on River Road where the data says it joins",
		Layout.distance(map.lairSpur[1], Layout.pointAt(b, greenwood.lair.joinsAt)) < 0.001
	)
end

print("\n== Everything the story and the tamers need has a place ==")
do
	local missing: { string } = {}
	for _, beat in Chapter1.beats do
		local target = beat.trigger.target
		if target then
			local battle = Tamers.story[target]
			local id = if battle then battle.place else target
			if map.places[id] == nil then
				table.insert(missing, `{beat.id}: {target}`)
			end
		end
	end
	for _, route in greenwood.routes do
		for _, tamerId in route.tamers do
			if map.places[tamerId] == nil or sheetFaces[tamerId] == nil then
				table.insert(missing, tamerId)
			end
		end
	end
	for id, battle in Tamers.story do
		if map.places[battle.place] and generated.places[battle.place] then
			if battle.place == greenwood.hub.id or battle.place == greenwood.gate.id then
				if map.stands[id] == nil then
					table.insert(missing, `stand for {id}`)
				end
			end
		end
	end
	check(
		"every Chapter 1 target, local tamer and story battle has a place (and a stand)",
		#missing == 0,
		join(missing)
	)
end

print("\n== Prompts ==")
do
	type Prompt = { id: string, at: Layout.Point }
	local prompts: { Prompt } = {}
	for _, building in greenwood.hub.buildings do
		table.insert(prompts, { id = building.id, at = map.places[building.id] })
	end
	for _, route in greenwood.routes do
		for _, tamerId in route.tamers do
			table.insert(prompts, { id = tamerId, at = map.places[tamerId] })
		end
		for _, spot in route.rustleSpots do
			table.insert(prompts, { id = spot.id, at = map.places[spot.id] })
		end
	end
	table.insert(prompts, { id = "stall", at = map.places[Layout.stallId(greenwood)] })
	for id, point in map.stands do
		table.insert(prompts, { id = id, at = point })
	end
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
	check("each story battler stands within the server's slack of its place", #far == 0, join(far))
end

print("\n== Long grass ==")
do
	local wrong: { string } = {}
	local patches: { { id: string, at: Layout.Point } } = {}
	for _, route in greenwood.routes do
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
		local at = patches[index].at
		local edge = greenwood.hub.size / 2 + WorldConfig.GRASS_RADIUS
		if math.abs(at.x - map.hub.x) < edge and math.abs(at.z - map.hub.z) < edge then
			table.insert(overlaps, `{patches[index].id}/town`)
		end
		for _, route in greenwood.routes do
			for _, tamerId in route.tamers do
				if Layout.distance(map.places[tamerId], at) <= WorldConfig.GRASS_RADIUS then
					table.insert(overlaps, `{patches[index].id}/{tamerId}`)
				end
			end
		end
	end
	check("no patch overlaps another patch, the town or a tamer", #overlaps == 0, join(overlaps))
end

print("\n== Tamers, rustle spots and corridors ==")
do
	local astray: { string } = {}
	for _, route in greenwood.routes do
		local line = map.routes[route.id]
		for _, tamerId in route.tamers do
			local tamer = Tamers.locals[tamerId]
			local at = map.places[tamerId]
			local _, off = project(line, at)
			local fromAt = Layout.distance(at, Layout.pointAt(line, tamer.at))
			if off > 12 or fromAt > 40 then
				table.insert(astray, `{tamerId} off {math.floor(off)} from at {math.floor(fromAt)}`)
			end
		end
		for _, spot in route.rustleSpots do
			local _, off = project(line, map.places[spot.id])
			if off > 30 then
				table.insert(astray, `{spot.id} off {math.floor(off)}`)
			end
		end
	end
	check(
		"each tamer is by its lane near its distance, each rustle spot near its lane",
		#astray == 0,
		join(astray)
	)

	local outside: { string } = {}
	for _, route in greenwood.routes do
		local line = map.routes[route.id]
		local widths = line.halfWidth or {}
		local function inside(id: string, at: Layout.Point, reach: number)
			local along, off = project(line, at)
			local area = areaAt(route, along)
			local width = if area then widths[area.id] else nil
			if width == nil or off + reach > width then
				table.insert(outside, id)
			end
		end
		for _, area in route.areas do
			inside(area.id, map.places[area.id], 0)
			inside(
				Layout.grassId(area.id),
				map.places[Layout.grassId(area.id)],
				WorldConfig.GRASS_RADIUS
			)
		end
		for _, spot in route.rustleSpots do
			inside(spot.id, map.places[spot.id], 0)
		end
		for _, tamerId in route.tamers do
			inside(tamerId, map.places[tamerId], 0)
		end
		-- Wild creatures stand up to this far either side of the lane.
		inside(`{route.id} creatures`, Layout.pointAt(line, 1), WorldConfig.SPAWN_SIDE_OFFSET)
	end
	check(
		"every route place, grass edge included, is inside its corridor",
		#outside == 0,
		join(outside)
	)
	local spurWidth = map.lairHalfWidth
	check(
		"the spur has its corridor width, and the stall stands on it",
		spurWidth ~= nil
			and Layout.distance(
					map.places[Layout.stallId(greenwood)],
					Layout.pointAt({
						id = "spur",
						points = map.lairSpur,
						length = greenwood.lair.spurLength,
						side = 0,
					}, WorldConfig.STALL_DISTANCE)
				)
				< 0.001
	)
end

print("\n== Town ==")
do
	local problems: { string } = {}
	local ids: { string } = {}
	for _, building in greenwood.hub.buildings do
		table.insert(ids, building.id)
		local middle = map.buildings[building.id]
		local reach = greenwood.hub.size / 2 - 14
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
	local entry = map.places.greenwood_route_a
	local near: { string } = {}
	for _, building in greenwood.hub.buildings do
		if Layout.distance(entry, map.places[building.id]) <= 48 then
			table.insert(near, building.id)
		end
	end
	check("entering Route A is more than 48 studs from every town door", #near == 0, join(near))
	local spawn = map.spawn
	check(
		"players arrive in the square facing north",
		spawn ~= nil
			and spawn.faces == 0
			and Layout.distance(spawn.at, map.places.greenwood_hub) < 20
	)
	check(
		"the keepers' facings come from the sheet",
		map.faces.mentor == 180 and map.faces.shop == 0 and map.models.waystation == "Waystation"
	)
end

print("\n== Other biomes ==")
do
	local list: { WorldTypes.Biome } = {}
	for _, biome in Biomes do
		table.insert(list, biome)
	end
	local world = Layout.world(list, Tamers.locals)
	local canyon = Biomes.dust_canyon
	local close: { string } = {}
	if canyon then
		for id, place in world.maps[1].places do
			for otherId, other in world.maps[canyon.number].places do
				if Layout.distance(place, other) <= 100 then
					table.insert(close, `{id}/{otherId}`)
				end
			end
		end
	end
	check("Dust Canyon is in the world", canyon ~= nil)
	check(
		"every Greenwood place is more than 100 studs from every Dust Canyon place",
		#close == 0,
		join(close)
	)
	local unsheeted = true
	for _, biome in list do
		if biome.number ~= 1 and biome.map ~= nil then
			unsheeted = false
		end
	end
	check("biomes after Greenwood keep the generated layout", unsheeted)
	check(
		"the world keeps Greenwood's facings, stands and spawn",
		world.map.faces.gw_pip == 60
			and world.map.stands.rival_first ~= nil
			and world.map.spawn ~= nil
	)
end

print("\n== Dressing keeps clear of prompts and lanes ==")
do
	local Dressing = require("../src/content/map_data/GreenwoodDressing")
	local origin: Layout.Point = { x = map.hub.x, z = map.hub.z }
	local function at(point: WorldTypes.SheetPoint): Layout.Point
		return { x = origin.x + point.x, z = origin.z + point.z }
	end

	-- Every point a player presses a prompt at.
	local prompts: { { id: string, at: Layout.Point } } = {}
	for _, building in greenwood.hub.buildings do
		table.insert(prompts, { id = building.id, at = map.places[building.id] })
	end
	for _, route in greenwood.routes do
		for _, tamerId in route.tamers do
			table.insert(prompts, { id = tamerId, at = map.places[tamerId] })
		end
		for _, spot in route.rustleSpots do
			table.insert(prompts, { id = spot.id, at = map.places[spot.id] })
		end
	end
	table.insert(prompts, { id = "stall", at = map.places[Layout.stallId(greenwood)] })
	for id, point in map.stands do
		table.insert(prompts, { id = id, at = point })
	end

	-- Every lane a fence must not cross: the routes, the spur and the town's streets.
	type Lane = { name: string, points: { Layout.Point }, half: number }
	local lanes: { Lane } = {}
	for _, route in greenwood.routes do
		table.insert(lanes, {
			name = route.id,
			points = map.routes[route.id].points,
			half = Dressing.laneWidth / 2,
		})
	end
	table.insert(lanes, { name = "spur", points = map.lairSpur, half = Dressing.laneWidth / 2 })
	for index, lane in Dressing.lanes do
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
		local world: { Layout.Point } = {}
		for _, point in points do
			table.insert(world, at(point))
		end
		local nearSeen: { [string]: boolean } = {}
		local laneSeen: { [string]: boolean } = {}
		for _, point in samples(world) do
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
	for index, fence in Dressing.fences do
		checkRun(`fence {index} ({fence.style})`, fence.points, fence.across == true)
	end
	for index, hedge in Dressing.hedges do
		checkRun(`hedge {index}`, hedge, false)
	end

	-- Buildings with no keeper, and the gatehouse's towers, as boxes.
	type Box = { name: string, at: Layout.Point, faces: number, width: number, depth: number }
	local boxes: { Box } = {}
	for index, house in Dressing.houses do
		table.insert(boxes, {
			name = `house {index}`,
			at = at(house.at),
			faces = house.faces,
			width = house.width,
			depth = house.depth,
		})
	end
	-- Carts, barrels and apple trees that block the way count too, as squares.
	for index, thing in Dressing.props do
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
	local gate = Dressing.gatehouse
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
	for laneIndex, lane in Dressing.lanes do
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
	local grassClear = true
	for _, route in greenwood.routes do
		for _, area in route.areas do
			local patch = map.places[Layout.grassId(area.id)]
			for _, lamp in Dressing.lamps do
				grassClear = grassClear
					and Layout.distance(at(lamp), patch) > WorldConfig.GRASS_RADIUS
			end
		end
	end
	check("no lamp stands in long grass", grassClear)
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("layout checks failed")
end
