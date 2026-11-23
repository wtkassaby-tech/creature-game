--!strict
-- Checks on the height of the ground (src/shared/Ground) and on Greenwood's levels
-- (docs/plans/12_MAP_STRUCTURE.md sections 3, 4a and 8): tiers, stairs, ramps and ledges are as
-- the plan says, every link joins two heights, ledges drop exactly one tier, and nothing the server
-- checks straddles two levels.
-- Run from the project folder:  lune run tests/ground.test

local Biomes = require("../src/content/Biomes")
local Ground = require("../src/shared/Ground")
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

local function p(x: number, z: number): WorldTypes.SheetPoint
	return { x = x, z = z }
end
local function box(x: number, z: number, across: number, deep: number): WorldTypes.Shape
	return { kind = "Box", at = p(x, z), size = { across, deep } }
end
local function disc(x: number, z: number, r: number): WorldTypes.Shape
	return { kind = "Disc", at = p(x, z), r = r }
end
local function strip(x0: number, z0: number, x1: number, z1: number, r: number): WorldTypes.Shape
	return { kind = "Strip", from = p(x0, z0), to = p(x1, z1), r = r }
end
local function near(a: number, b: number, tolerance: number?): boolean
	return math.abs(a - b) <= (tolerance or 1e-6)
end

print("Shapes")
do
	local origin: Layout.Point = { x = 100, z = -50 }
	local round = Ground.shape(disc(0, 0, 10), origin)
	local square = Ground.shape(box(0, 0, 20, 10), origin)
	local bar = Ground.shape(strip(0, 0, 30, 0, 5), origin)
	check("a disc is moved to the origin", near(Ground.distance(round, 100, -50), -10))
	check(
		"a point outside a disc is that far from its edge",
		near(Ground.distance(round, 115, -50), 5)
	)
	check("a box is its size across and deep", near(Ground.distance(square, 108, -50), -2))
	check("outside a box is the distance to it", near(Ground.distance(square, 120, -50), 10))
	check(
		"a strip has round ends and straight sides",
		near(Ground.distance(bar, 130, -50), -5)
			and near(Ground.distance(bar, 115, -42), 3)
			and near(Ground.distance(bar, 140, -50), 5)
	)
	-- Every point on an outline is on the shape's edge, and its normal points out.
	local shapes: { [string]: Ground.Shape } = { disc = round, box = square, strip = bar }
	for name, shape in shapes do
		local onEdge, out = true, true
		for _, s in Ground.outline(shape, 2) do
			onEdge = onEdge and math.abs(Ground.distance(shape, s.x, s.z)) < 0.01
			out = out and Ground.distance(shape, s.x + s.nx * 0.5, s.z + s.nz * 0.5) > 0
		end
		check(`the {name}'s outline lies on its edge with its normals out`, onEdge and out)
	end
end

print("Heights")
do
	local sheet: any = {
		routes = {},
		buildings = {},
		places = {},
		tiers = {
			{
				id = "low",
				height = 10,
				shape = box(0, 0, 100, 100),
			},
			{ id = "high", height = 20, shape = disc(0, 0, 20) },
			{ id = "pit", height = 0, shape = disc(35, 0, 5) },
		},
		links = {
			{ id = "up", kind = "Ramp", from = p(-70, 0), to = p(-48, 0), width = 10 },
			{ id = "lip", kind = "Ledge", from = p(0, 50), to = p(40, 50), width = 8 },
		},
	}
	local g = Ground.new(sheet, { x = 0, z = 0 })
	check("the ground is 0 where no tier lies", near(Ground.heightAt(g, 200, 200), 0))
	check("a tier's top is its height", near(Ground.heightAt(g, 40, 0), 10))
	check("a later tier wins where tiers overlap", near(Ground.heightAt(g, 0, 0), 20))
	check("a later tier can be lower", near(Ground.heightAt(g, 35, 0), 0))
	check(
		"a ramp starts on the ground under its low end",
		near(Ground.heightAt(g, -69, 0), 10 / 22)
	)
	check("a ramp is halfway up halfway along", near(Ground.heightAt(g, -59, 0), 5))
	check(
		"a ramp ends on the tier under its high end",
		near(Ground.heightAt(g, -48.5, 0), 10 * 21.5 / 22)
	)
	check("beside a ramp is the ground, not the ramp", near(Ground.heightAt(g, -60, 8), 0))
	check("a ledge changes no height", near(Ground.heightAt(g, 20, 50), 0))
	check(
		"a ramp is a link, a ledge is not",
		Ground.linkAt(g, -60, 0) ~= nil and Ground.linkAt(g, 20, 50) == nil
	)
	check(
		"a ledge is found on its lip, and not off its ends",
		Ground.ledgeAt(g, 20, 50) ~= nil and Ground.ledgeAt(g, 60, 50) == nil
	)
	check(
		"flat means no tiers",
		not Ground.isFlat(g) and Ground.isFlat(Ground.new(nil, { x = 0, z = 0 }))
	)

	local edges = Ground.edges(g, 2)
	local walls, ledges = 0, 0
	for _, run in edges do
		if run.kind == "Wall" then
			walls += #run.points
		else
			ledges += #run.points
		end
	end
	check("a tier's drop is a wall", walls > 40)
	check(
		"a ledge's stretch of lip is a ledge, not a wall",
		ledges >= 15 and ledges <= 25,
		`{ledges}`
	)
	local steep = true
	for _, run in edges do
		steep = steep and run.high - run.low > 2
	end
	check("every edge is a real drop", steep)
	-- The ramp's mouth is not an edge: its ends are on the same level as the tier it meets.
	local mouth = false
	for _, run in edges do
		for _, point in run.points do
			if math.abs(point.z) < 4 and point.x < -49 and point.x > -71 then
				mouth = true
			end
		end
	end
	check("the notch a ramp makes in a tier's side is not a wall", not mouth)
	check(
		"the foot of a wall is found, the top is not",
		Ground.atFoot(g, 52, 0, 3) and not Ground.atFoot(g, 45, 0, 3)
	)
end

-- Greenwood.
local biome = Biomes.greenwood
local sheet = assert(biome.map, "Greenwood has a map sheet")
local tiersOf: { WorldTypes.Tier } = if sheet.tiers then sheet.tiers else {}
local linksOf: { WorldTypes.Link } = if sheet.links then sheet.links else {}
local roomsOf: { WorldTypes.Room } = if sheet.rooms then sheet.rooms else {}
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

print("Greenwood's levels")
do
	local off: { string } = {}
	for _, tier in g.tiers do
		if tier.height % 10 ~= 0 then
			table.insert(off, tier.id)
		end
	end
	check("every tier stands a whole number of 10 studs high", #off == 0, table.concat(off, ", "))
	local ids: { [string]: boolean } = {}
	local duplicate: { string } = {}
	for _, tier in tiersOf do
		if ids[tier.id] then
			table.insert(duplicate, tier.id)
		end
		ids[tier.id] = true
	end
	for _, link in linksOf do
		if ids[link.id] then
			table.insert(duplicate, link.id)
		end
		ids[link.id] = true
	end
	for _, room in roomsOf do
		if ids[room.id] then
			table.insert(duplicate, room.id)
		end
		ids[room.id] = true
	end
	check("no tier, link or room shares an id", #duplicate == 0, table.concat(duplicate, ", "))

	local bad: { string } = {}
	for _, link in g.links do
		if link.kind ~= "Ledge" then
			-- Stairs and ramps join two heights, 10 apart, and their ends lie on them.
			if near(link.h0, link.h1) or math.abs(link.h1 - link.h0) ~= 10 then
				table.insert(bad, `{link.id}: {link.h0} to {link.h1}`)
			end
			local ratio = math.abs(link.h1 - link.h0) / link.length
			if ratio > 0.62 or ratio < 0.25 then
				table.insert(bad, `{link.id}: slope {ratio}`)
			end
			-- Two studs past either end is the ground it joins (the tier, not the link).
			local before = Ground.tierHeight(g, link.ax - link.ux * 0.5, link.az - link.uz * 0.5)
			local after = Ground.tierHeight(g, link.bx + link.ux * 0.5, link.bz + link.uz * 0.5)
			if not (near(before, link.h0) and near(after, link.h1)) then
				table.insert(bad, `{link.id}: ends {before} and {after}`)
			end
		end
	end
	check(
		"every stairs and ramp joins two heights 10 apart, on a gentle slope",
		#bad == 0,
		table.concat(bad, ", ")
	)

	local ledgeBad: { string } = {}
	local ledgeCount = 0
	for _, link in g.links do
		if link.kind == "Ledge" then
			ledgeCount += 1
			-- High ground is on the left as you walk from `from` to `to`; it drops exactly 10.
			local left = { x = link.uz, z = -link.ux }
			for _, t in { 0.1, 0.5, 0.9 } do
				local x, z =
					link.ax + link.ux * link.length * t, link.az + link.uz * link.length * t
				local high = Ground.heightAt(g, x + left.x * 3, z + left.z * 3)
				local low = Ground.heightAt(g, x - left.x * 3, z - left.z * 3)
				if not (near(high - low, 10)) then
					table.insert(ledgeBad, `{link.id} at {t}: {high} over {low}`)
				end
			end
		end
	end
	check("there are ledges", ledgeCount >= 3)
	check(
		"every ledge drops exactly one tier (10), the high ground on its left",
		#ledgeBad == 0,
		table.concat(ledgeBad, ", ")
	)
end

print("One level for everything the server checks")
do
	-- All the heights of a ring of points round a spot are one height.
	local function oneLevel(x: number, z: number, radius: number): boolean
		local centre = Ground.heightAt(g, x, z)
		for k = 0, 23 do
			local angle = k / 24 * math.pi * 2
			if
				math.abs(
					Ground.heightAt(g, x + math.cos(angle) * radius, z + math.sin(angle) * radius)
						- centre
				) > 0.01
			then
				return false
			end
		end
		return true
	end
	local straddle: { string } = {}
	for id, place in map.places do
		-- A route's entry or a stretch's middle is only a marker on the lane; prompts are what
		-- stand on ground (buildings, tamers, rustle spots, the stall, a story battler).
		local isGrass = string.find(id, "_grass", 1, true) ~= nil
		if not isGrass and not oneLevel(place.x, place.z, 6) then
			table.insert(straddle, id)
		end
	end
	for id, stand in map.stands do
		if not oneLevel(stand.x, stand.z, 6) then
			table.insert(straddle, id)
		end
	end
	check(
		"every place, prompt and story stand has 6 studs of one level round it",
		#straddle == 0,
		table.concat(straddle, ", ")
	)

	local tamerBad: { string } = {}
	for _, route in biome.routes do
		for _, tamerId in route.tamers do
			local at = map.places[tamerId]
			if not oneLevel(at.x, at.z, 16) then
				table.insert(tamerBad, tamerId)
			end
		end
	end
	check(
		"every tamer has 16 studs of one level round them",
		#tamerBad == 0,
		table.concat(tamerBad, ", ")
	)

	local grassBad: { string } = {}
	for areaId, patches in map.grass do
		for number, patch in patches do
			-- The patch itself, and 6 studs past its edge, are one level (and not on a link).
			if
				not (
					oneLevel(patch.x, patch.z, patch.r) and oneLevel(patch.x, patch.z, patch.r + 6)
				)
			then
				table.insert(grassBad, `{areaId} {number}`)
			end
			if Ground.linkAt(g, patch.x, patch.z, 0) then
				table.insert(grassBad, `{areaId} {number} on a link`)
			end
		end
	end
	check(
		"every patch of long grass lies on one level, 6 studs clear of any edge",
		#grassBad == 0,
		table.concat(grassBad, ", ")
	)

	-- Creatures hide inside their patch, so they are on its level too.
	local sameLevel = true
	for _, route in biome.routes do
		for _, area in route.areas do
			local patches = map.grass[area.id]
			if patches == nil or #patches == 0 then
				sameLevel = false
			end
		end
	end
	check("every stretch of a route has at least one patch of long grass", sameLevel)
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("ground tests failed")
end
