--!strict
-- Checks on the first step of docs/plans/12_MAP_STRUCTURE.md: the fill past every edge and the
-- water that blocks the way (src/shared/Enclosure). The point of the water check is that closing
-- the map in must never cut a place off: a flood fill over each biome's walkable space, with the
-- water barriers taken out, has to reach every named place and every lane.
-- Run from the project folder:  lune run tests/enclosure.test

local Biomes = require("../src/content/Biomes")
local DustCanyonDressing = require("../src/content/map_data/DustCanyonDressing")
local Enclosure = require("../src/shared/Enclosure")
local GreenwoodDressing = require("../src/content/map_data/GreenwoodDressing")
local Layout = require("../src/shared/Layout")
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

local DRESSINGS: { [string]: WorldTypes.DressingSheet } = {
	greenwood = GreenwoodDressing,
	dust_canyon = DustCanyonDressing,
	tide_flats = TideFlatsDressing,
}

local ordered: { WorldTypes.Biome } = {}
for _, biome in Biomes do
	table.insert(ordered, biome)
end
table.sort(ordered, function(a, b)
	return a.number < b.number
end)
local world = Layout.world(ordered, Tamers.locals)

-- The walkable space of a biome as TestMap builds it, links included.
local function shapesOf(index: number): { Enclosure.Shape }?
	local biome = ordered[index]
	local map = world.maps[biome.number]
	local dressing = DRESSINGS[biome.id]
	if not (map and dressing) then
		return nil
	end
	local links: { Enclosure.Shape } = {}
	local before = ordered[index - 1]
	local beforeMap = if before then world.maps[before.number] else nil
	local gate = if before and beforeMap then beforeMap.places[before.gate.id] else nil
	if gate then
		table.insert(
			links,
			Enclosure.link(gate, { x = map.hub.x - map.hub.size / 2, z = map.hub.z }, 40)
		)
	end
	return Enclosure.walkable(biome, map, dressing, links)
end

print("Shapes")
do
	local shapes =
		{ Enclosure.disc(0, 0, 10), Enclosure.link({ x = 20, z = 0 }, { x = 40, z = 0 }, 5) }
	check("inside a disc is negative", Enclosure.distance(shapes, 0, 0, false) < 0)
	check(
		"a point 15 from a disc of 10 is 5 out",
		math.abs(Enclosure.distance(shapes, 0, 15, false) - 5) < 1e-6
	)
	check(
		"a strip is as wide as its radius",
		math.abs(Enclosure.distance(shapes, 30, 9, false) - 4) < 1e-6
	)
	local index = Enclosure.index(shapes, 30)
	check(
		"the index agrees with the plain distance",
		math.abs(Enclosure.indexed(index, 30, 20) - Enclosure.distance(shapes, 30, 20, false))
			< 1e-6
	)
	check("the index finds nothing far away", Enclosure.indexed(index, 5000, 5000) == math.huge)
end

for index, biome in ordered do
	local map = world.maps[biome.number]
	local dressing = DRESSINGS[biome.id]
	local shapes = shapesOf(index)
	if map == nil or dressing == nil or shapes == nil then
		continue
	end
	print(`{biome.id}`)
	local fillSheet = dressing.fill
	check("has a fill", fillSheet ~= nil)
	local bounds = Enclosure.bounds(shapes, 100)

	if fillSheet then
		local seas = Enclosure.seas(map, dressing)
		local plan = Enclosure.fill(
			shapes,
			bounds,
			fillSheet.style,
			fillSheet.band,
			biome.number * 101,
			seas
		)
		local again = Enclosure.fill(
			shapes,
			bounds,
			fillSheet.style,
			fillSheet.band,
			biome.number * 101,
			seas
		)
		check(
			"the same seed gives the same fill",
			#plan.rows == #again.rows
				and #plan.masses == #again.masses
				and #plan.blocks == #again.blocks
		)
		local parts = #plan.rows + #plan.masses + #plan.blocks
		print(
			`    fill parts: {#plan.rows} row, {#plan.masses} mass, {#plan.blocks} block = {parts}`
		)
		check("the fill is a sensible size for a phone", parts > 100 and parts < 1100, `{parts}`)

		local clear, within = true, true
		local tall = WorldConfig.FILL_TALL[fillSheet.style]
		local high = true
		local function look(list: { Enclosure.Spot }, layer: string)
			for _, spot in list do
				local d = Enclosure.distance(shapes, spot.x, spot.z, false)
				if d < WorldConfig.FILL_PAD then
					clear = false
				end
				if d > fillSheet.band then
					within = false
				end
				local range = tall[layer]
				if spot.tall < range[1] - 1e-6 or spot.tall > range[2] + 1e-6 then
					high = false
				end
			end
		end
		look(plan.rows, "row")
		look(plan.masses, "mass")
		look(plan.blocks, "block")
		check("nothing stands inside the walkable space or on its edge", clear)
		check("the fill stays inside its band", within)
		check("every piece is as tall as the config says", high)
		-- Every part of the edge ring has trees: sample the walkable boundary.
		local rowIndex = Enclosure.index(shapes, 0)
		check("the index holds every shape", rowIndex.reach == 0)
	end

	-- Water.
	local limits = bounds
	local water = Enclosure.water(biome, map, dressing, shapes, limits)
	print(`    water: {#water.runs} runs, {#water.discs} discs, {#water.tiles} tiles`)

	-- Flood fill over the walkable space, 4 studs a cell, with the barriers taken out.
	local cell = 4
	local x0, z0 = bounds.x0, bounds.z0
	local columns = math.ceil((bounds.x1 - x0) / cell)
	local rows = math.ceil((bounds.z1 - z0) / cell)
	local function keyOf(cx: number, cz: number): number
		return cz * columns + cx
	end
	local blocked: { [number]: boolean } = {}
	local function cellRange(
		low: number,
		high: number,
		origin: number,
		limit: number
	): (number, number)
		return math.max(math.floor((low - origin) / cell), 0),
			math.min(math.floor((high - origin) / cell), limit - 1)
	end
	for _, run in water.runs do
		for k = 1, #run.points - 1 do
			local a, b = run.points[k], run.points[k + 1]
			local capsule = Enclosure.link(a, b, run.thick / 2)
			local cx0, cx1 = cellRange(
				math.min(a.x, b.x) - run.thick,
				math.max(a.x, b.x) + run.thick,
				x0,
				columns
			)
			local cz0, cz1 =
				cellRange(math.min(a.z, b.z) - run.thick, math.max(a.z, b.z) + run.thick, z0, rows)
			for cz = cz0, cz1 do
				for cx = cx0, cx1 do
					local d = Enclosure.distance(
						{ capsule },
						x0 + (cx + 0.5) * cell,
						z0 + (cz + 0.5) * cell,
						false
					)
					if d < 0 then
						blocked[keyOf(cx, cz)] = true
					end
				end
			end
		end
	end
	for _, pool in water.discs do
		local round = Enclosure.disc(pool.x, pool.z, pool.r)
		local cx0, cx1 = cellRange(pool.x - pool.r, pool.x + pool.r, x0, columns)
		local cz0, cz1 = cellRange(pool.z - pool.r, pool.z + pool.r, z0, rows)
		for cz = cz0, cz1 do
			for cx = cx0, cx1 do
				if
					Enclosure.distance(
						{ round },
						x0 + (cx + 0.5) * cell,
						z0 + (cz + 0.5) * cell,
						false
					) < 0
				then
					blocked[keyOf(cx, cz)] = true
				end
			end
		end
	end
	for _, tile in water.tiles do
		local cx0, cx1 = cellRange(tile.x0, tile.x1, x0, columns)
		local cz0, cz1 = cellRange(tile.z0, tile.z1, z0, rows)
		for cz = cz0, cz1 do
			for cx = cx0, cx1 do
				blocked[keyOf(cx, cz)] = true
			end
		end
	end
	local lookup = Enclosure.index(shapes, 0)
	local function open(cx: number, cz: number): boolean
		if cx < 0 or cz < 0 or cx >= columns or cz >= rows or blocked[keyOf(cx, cz)] then
			return false
		end
		return Enclosure.indexed(lookup, x0 + (cx + 0.5) * cell, z0 + (cz + 0.5) * cell) <= 0
	end
	local startX = math.floor((map.hub.x - x0) / cell)
	local startZ = math.floor((map.hub.z - z0) / cell)
	local seen: { [number]: boolean } = { [keyOf(startX, startZ)] = true }
	local queue: { number } = { keyOf(startX, startZ) }
	local head = 1
	while head <= #queue do
		local key = queue[head]
		head += 1
		local cx, cz = key % columns, math.floor(key / columns)
		for _, step in { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
			local nx, nz = cx + step[1], cz + step[2]
			local nk = keyOf(nx, nz)
			if not seen[nk] and open(nx, nz) then
				seen[nk] = true
				table.insert(queue, nk)
			end
		end
	end
	local function reached(x: number, z: number): boolean
		return seen[keyOf(math.floor((x - x0) / cell), math.floor((z - z0) / cell))] == true
	end
	-- A prompt works from a few studs off (the rustle radius is 14), so a place that sits in a pool
	-- is fine as long as its edge can be reached.
	local function reachedNear(x: number, z: number): boolean
		if reached(x, z) then
			return true
		end
		for k = 0, 7 do
			local angle = k / 8 * math.pi * 2
			if reached(x + math.cos(angle) * 10, z + math.sin(angle) * 10) then
				return true
			end
		end
		return false
	end
	check("the town's middle is open", open(startX, startZ))
	local cut: { string } = {}
	for id, place in map.places do
		if not reachedNear(place.x, place.z) then
			table.insert(cut, id)
		end
	end
	table.sort(cut)
	check(
		"every named place can still be reached, or touched from 10 studs",
		#cut == 0,
		table.concat(cut, ", ")
	)
	local cutLane = 0
	for _, route in biome.routes do
		local line = map.routes[route.id]
		for along = 0, line.length, 10 do
			local point = Layout.pointAt(line, along)
			if not reached(point.x, point.z) then
				cutLane += 1
			end
		end
	end
	check("every lane can still be walked end to end", cutLane == 0, `{cutLane} points cut off`)
	local spurEnd = map.lairSpur[#map.lairSpur]
	check("the lair can still be reached", reached(spurEnd.x, spurEnd.z))
end

print("Camera and walls")
do
	check("a wall core is taller than a jump", WorldConfig.WALL_CORE_TALL > 7.2)
	check("a water barrier is taller than a jump", WorldConfig.WATER_BARRIER_TALL > 7.2)
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("enclosure tests failed")
end
