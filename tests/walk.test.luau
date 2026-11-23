--!strict
-- Checks on where a character can walk (src/shared/Walk) and on how Greenwood's levels join up
-- (docs/plans/12_MAP_STRUCTURE.md section 8, with Ayrton's change of 23 November 2026: patches of
-- grass you can always walk round, never a field you must cross):
--   * every place is reachable from the town, and the town from every cell (no ledge traps a player);
--   * ledges are one-way, down;
--   * every place can be reached and left without stepping into any patch of long grass;
--   * lanes are narrow with wider rooms, with pinch points, branches and tamers at the pinches.
-- Run from the project folder:  lune run tests/walk.test

local Biomes = require("../src/content/Biomes")
local Ground = require("../src/shared/Ground")
local GreenwoodDressing = require("../src/content/map_data/GreenwoodDressing")
local Layout = require("../src/shared/Layout")
local Tamers = require("../src/content/Tamers")
local Walk = require("../src/shared/Walk")
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

local function p(x: number, z: number): WorldTypes.SheetPoint
	return { x = x, z = z }
end
local function box(x: number, z: number, across: number, deep: number): WorldTypes.Shape
	return { kind = "Box", at = p(x, z), size = { across, deep } }
end
local function strip(x0: number, z0: number, x1: number, z1: number, r: number): WorldTypes.Shape
	return { kind = "Strip", from = p(x0, z0), to = p(x1, z1), r = r }
end

print("A small map: a lane, stairs up, a ledge down")
do
	-- A town box, a tier-10 shelf to its east reached by stairs, and a ledge off the shelf's
	-- south side into a lane that runs back west to the town.
	local biome: any = {
		id = "toy",
		hub = { id = "toy_hub", size = 40 },
		routes = {},
		lair = { id = "toy_lair", arenaSize = 20 },
		gate = { id = "toy_gate", sealedPath = "toy_sealed" },
	}
	local map: any = {
		hub = { x = 0, z = 0, size = 40 },
		routes = {},
		places = {},
		buildings = {},
		lairSpur = {},
	}
	local sheet: any = {
		routes = {},
		buildings = {},
		places = {},
		tiers = {
			{
				id = "shelf",
				height = 10,
				shape = box(80, 0, 60, 40),
			},
		},
		links = {
			{ id = "up", kind = "Stairs", from = p(30, 0), to = p(52, 0), width = 10 },
			{ id = "hop", kind = "Ledge", from = p(60, 20), to = p(100, 20), width = 8 },
		},
		rooms = {
			{ id = "top", shape = box(80, 0, 56, 36) },
			{ id = "under", shape = box(80, 32, 56, 20) },
			{ id = "way", shape = strip(10, 10, 10, 32, 6) },
			{ id = "way2", shape = strip(10, 32, 70, 32, 6) },
			{ id = "ascent", shape = box(42, 0, 20, 10) },
			{ id = "approach", shape = strip(0, 0, 34, 0, 6) },
		},
	}
	biome.map = sheet
	local space = Walk.space(biome, map, nil)
	local g = Ground.new(sheet, { x = 0, z = 0 })
	local grid = Walk.grid(space, g, { x0 = -30, z0 = -40, x1 = 140, z1 = 60 }, 4)
	local out = Walk.reach(grid, 0, 0)
	local back = Walk.reach(grid, 0, 0, { forward = false })
	check("the shelf is reached up the stairs", Walk.reached(grid, out, 80, 0))
	check("the lane under the shelf is reached by the ledge", Walk.reached(grid, out, 80, 32))
	check(
		"every cell reached can get back to the start",
		out.count == back.count and out.count > 100
	)
	local noLedges = Walk.reach(grid, 0, 0, { ledges = false })
	check(
		"without the ledge the lane is still reached the long way",
		Walk.reached(grid, noLedges, 80, 32)
	)
	-- From the lane under the shelf with no stairs: the ledge cannot be climbed.
	local stuck = Walk.reach(grid, 80, 32, { ledges = true })
	check(
		"from under a ledge you can walk home but not onto the shelf by the ledge",
		Walk.reached(grid, stuck, 0, 0)
	)
	-- Block the way round (the stairs) by taking the town out: the lane cannot reach the shelf.
	local lane = Walk.reach(grid, 80, 32, {
		avoid = function(x: number, z: number): boolean
			return x < 45 and z < 20 and math.abs(z) < 8
		end,
	})
	check(
		"with the stairs cut, the shelf cannot be climbed from below",
		not Walk.reached(grid, lane, 80, 0)
	)
	local grass = Walk.reach(grid, 0, 0, {
		avoid = function(x: number, z: number): boolean
			return x > 24 and x < 36 and math.abs(z) < 12
		end,
	})
	check(
		"grass the lane runs through blocks a grass-free walk",
		not Walk.reached(grid, grass, 80, 0)
	)
end

-- Greenwood.
local biome = Biomes.greenwood
local sheet = assert(biome.map, "Greenwood has a map sheet")
local roomsOf: { WorldTypes.Room } = if sheet.rooms then sheet.rooms else {}
local widthsOf: { [string]: { WorldTypes.WidthKey } } = if sheet.widths then sheet.widths else {}
local ordered: { WorldTypes.Biome } = {}
for _, b in Biomes do
	table.insert(ordered, b)
end
table.sort(ordered, function(a, b)
	return a.number < b.number
end)
local world = Layout.world(ordered, Tamers.locals)
local map = world.maps[biome.number]
local g = Ground.new(sheet, { x = map.hub.x, z = map.hub.z })
local space = Walk.space(biome, map, GreenwoodDressing)
local grid = Walk.grid(space, g, { x0 = -450, z0 = -420, x1 = 760, z1 = 160 }, 4)
local start = map.spawn and map.spawn.at or map.places[biome.hub.id]
local out = Walk.reach(grid, start.x, start.z)
local back = Walk.reach(grid, start.x, start.z, { forward = false })

-- Inside a patch of long grass, with a margin of a cell (cells are tested by their middles).
local function inGrass(x: number, z: number): boolean
	for _, patches in map.grass do
		for _, patch in patches do
			if (x - patch.x) ^ 2 + (z - patch.z) ^ 2 <= (patch.r + 2) ^ 2 then
				return true
			end
		end
	end
	return false
end
local clear = Walk.reach(grid, start.x, start.z, { avoid = inGrass })
local clearBack = Walk.reach(grid, start.x, start.z, { avoid = inGrass, forward = false })

print("Greenwood: everything can be reached, and left")
do
	check("the town's spawn is open ground", Walk.open(space, start.x, start.z))
	local lost: { string } = {}
	local trapped: { string } = {}
	local gated: { string } = {}
	local count = 0
	for id, place in map.places do
		if string.find(id, "_grass", 1, true) == nil then
			count += 1
			if not Walk.reachedNear(grid, out, place.x, place.z, 8) then
				table.insert(lost, id)
			end
			if not Walk.reachedNear(grid, back, place.x, place.z, 8) then
				table.insert(trapped, id)
			end
			if
				not (
					Walk.reachedNear(grid, clear, place.x, place.z, 8)
					and Walk.reachedNear(grid, clearBack, place.x, place.z, 8)
				)
			then
				table.insert(gated, id)
			end
		end
	end
	for id, stand in map.stands do
		if not Walk.reachedNear(grid, out, stand.x, stand.z, 8) then
			table.insert(lost, id)
		end
	end
	check("there are places to reach", count > 25, `{count}`)
	check("every place is reachable from the town", #lost == 0, table.concat(lost, ", "))
	check("the town is reachable from every place", #trapped == 0, table.concat(trapped, ", "))
	check(
		"every place can be reached and left without stepping into long grass",
		#gated == 0,
		table.concat(gated, ", ")
	)
	local spurEnd = map.lairSpur[#map.lairSpur]
	check(
		"the lair, the gate and the sealed road can be reached",
		Walk.reachedNear(grid, out, spurEnd.x, spurEnd.z, 8)
			and Walk.reachedNear(
				grid,
				out,
				map.places[biome.gate.id].x,
				map.places[biome.gate.id].z,
				8
			)
			and Walk.reachedNear(
				grid,
				out,
				map.places[biome.gate.sealedPath].x,
				map.places[biome.gate.sealedPath].z,
				8
			)
	)
	-- No ledge traps a player: every cell reachable from the town can walk back to it.
	local stuck = 0
	for key = 1, grid.columns * grid.rows do
		if out.seen[key] and not back.seen[key] then
			stuck += 1
		end
	end
	check("no cell reached from the town leaves its player stuck", stuck == 0, `{stuck} cells`)
	-- Long grass is reachable (it is walkable), but the grass-free walk never needs it.
	local patches = 0
	for _, list in map.grass do
		patches += #list
	end
	check("there are patches of grass to walk round", patches >= 10, `{patches}`)
	local reachable = 0
	for key = 1, grid.columns * grid.rows do
		if out.seen[key] then
			reachable += 1
		end
	end
	check(
		"the grass-free walk leaves most of the map open",
		clear.count > reachable * 0.8,
		`{clear.count} of {reachable}`
	)
end

print("Greenwood: ledges are one-way, and face home")
do
	local down, upBlocked, ids: { [string]: number }, upAllowed = 0, 0, {}, 0
	for key = 1, grid.columns * grid.rows do
		if grid.open[key] then
			local index = key - 1
			local cx, cz = index % grid.columns, math.floor(index / grid.columns)
			for _, step in { { 1, 0 }, { 0, 1 } } do
				local nx, nz = cx + step[1], cz + step[2]
				if nx < grid.columns and nz < grid.rows then
					local other = nz * grid.columns + nx + 1
					if
						grid.open[other]
						and math.abs(grid.height[key] - grid.height[other]) >= 4
					then
						local high, low = key, other
						if grid.height[other] > grid.height[key] then
							high, low = other, key
						end
						local hx = grid.x0 + ((high - 1) % grid.columns + 0.5) * grid.cell
						local hz = grid.z0
							+ (math.floor((high - 1) / grid.columns) + 0.5) * grid.cell
						local lx = grid.x0 + ((low - 1) % grid.columns + 0.5) * grid.cell
						local lz = grid.z0
							+ (math.floor((low - 1) / grid.columns) + 0.5) * grid.cell
						local ledge = Ground.ledgeAt(g, (hx + lx) / 2, (hz + lz) / 2, 1)
						if ledge then
							ids[ledge.id] = (ids[ledge.id] or 0) + 1
							if Walk.canStep(grid, high, low, true) then
								down += 1
							end
							if Walk.canStep(grid, low, high, true) then
								upAllowed += 1
							else
								upBlocked += 1
							end
						else
							-- A drop with no ledge is a wall: it joins nothing either way.
							if
								Walk.canStep(grid, high, low, true)
								or Walk.canStep(grid, low, high, true)
							then
								upAllowed += 1000
							end
						end
					end
				end
			end
		end
	end
	local missing: { string } = {}
	for _, link in g.links do
		if link.kind == "Ledge" and (ids[link.id] or 0) < 3 then
			table.insert(missing, link.id)
		end
	end
	check("every ledge has open ground on both sides", #missing == 0, table.concat(missing, ", "))
	check("a hop down is allowed at every ledge", down >= 12, `{down}`)
	check(
		"a climb back up is never allowed, and walls join nothing",
		upAllowed == 0 and upBlocked >= 12,
		`{upBlocked} up, {upAllowed} wrong`
	)
	-- Ledges face home: the ground below a ledge reaches the town on foot without climbing.
	local homeward = true
	for _, link in g.links do
		if link.kind == "Ledge" then
			local left = { x = link.uz, z = -link.ux }
			local mid = {
				x = (link.ax + link.bx) / 2 - map.hub.x,
				z = (link.az + link.bz) / 2,
			}
			local lowAt = { x = map.hub.x + mid.x - left.x * 6, z = map.hub.z + mid.z - left.z * 6 }
			if not Walk.reachedNear(grid, back, lowAt.x, lowAt.z, 6) then
				homeward = false
			end
		end
	end
	check("the way home from the foot of every ledge never needs a climb", homeward)
end

print("Greenwood: narrow lanes, wide rooms")
do
	local tooWide: { string } = {}
	local pinches: { [string]: number } = {}
	for routeId, keys in widthsOf do
		local narrowRuns = 0
		local inRun = false
		for index, widthKey in keys do
			if widthKey.half > 22 then
				table.insert(tooWide, `{routeId} {widthKey.at}`)
			end
			if widthKey.half <= 16 and not inRun then
				narrowRuns += 1
				inRun = true
			elseif widthKey.half > 16 then
				inRun = false
			end
			if index > 1 and widthKey.at <= keys[index - 1].at then
				table.insert(tooWide, `{routeId} keys out of order at {widthKey.at}`)
			end
		end
		pinches[routeId] = narrowRuns
	end
	check(
		"every lane is at most 22 studs either side of its middle",
		#tooWide == 0,
		table.concat(tooWide, ", ")
	)
	local fewPinches: { string } = {}
	for _, route in biome.routes do
		local routeId, runs = route.id, pinches[route.id]
		if runs < 2 then
			table.insert(fewPinches, routeId)
		end
	end
	check(
		"every route has at least two pinch points (16 or less)",
		#fewPinches == 0,
		table.concat(fewPinches, ", ")
	)
	-- The neck between each route and the town is 18 wide (half 9).
	local neck = true
	for _, route in biome.routes do
		local keys = assert(sheet.widths, "widths")[route.id]
		neck = neck and keys[1].half == 9 and Layout.halfWidthAt(keys, 30, 0) == 9
	end
	check("each route leaves the town through an 18-wide neck", neck)
	-- Each route has at least two side branches: rooms off the lane (dead ends, pockets).
	local lacking: { string } = {}
	for _, route in biome.routes do
		local line = map.routes[route.id]
		local rooms = 0
		for _, room in roomsOf do
			local at = if room.shape.kind == "Strip" then room.shape.from else room.shape.at
			local x, z = map.hub.x + at.x, map.hub.z + at.z
			local best = math.huge
			for along = 0, line.length, 10 do
				best =
					math.min(best, Layout.distance(Layout.pointAt(line, along), { x = x, z = z }))
			end
			if best < 80 and (x < map.hub.x) == (line.points[#line.points].x < map.hub.x) then
				rooms += 1
			end
		end
		if rooms < 4 then
			table.insert(lacking, `{route.id} {rooms}`)
		end
	end
	check(
		"every route has rooms and branches off its lane (four or more)",
		#lacking == 0,
		table.concat(lacking, ", ")
	)
	-- Tamers at pinch points: at least two stand where their lane is at most 12 either side.
	local pinched = 0
	local detail: { string } = {}
	for _, route in biome.routes do
		local line = map.routes[route.id]
		for _, tamerId in route.tamers do
			local place = map.places[tamerId]
			local bestAlong, bestOff = 0, math.huge
			for along = 0, line.length, 2 do
				local d = Layout.distance(Layout.pointAt(line, along), place)
				if d < bestOff then
					bestAlong, bestOff = along, d
				end
			end
			local half = Layout.halfWidthAt(line.widths, bestAlong, 99)
			if half <= 12 then
				pinched += 1
			end
			table.insert(detail, `{tamerId}:{math.floor(half)}`)
		end
	end
	check("at least two tamers stand at a pinch point", pinched >= 2, table.concat(detail, " "))
	local gate = map.places[biome.gate.id]
	check("the gate stays at (684.4, -80)", Layout.distance(gate, { x = 684.4, z = -80 }) < 0.5)
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("walk tests failed")
end
