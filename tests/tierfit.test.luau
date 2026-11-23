--!strict
-- Parts lying across a tier's edge (docs/plans/12_MAP_STRUCTURE.md section 4c). Elevate lifts each
-- built part by the ground height under its middle; a long part across an edge needs more than that
-- (shared/TierFit.luau). First the rules on a small made-up ground, then, for every biome, the same
-- parts the builders make read out of the data as flat rectangles: lanes and streets, their joint
-- discs, the sealed road, the fill past the edges, the water barriers and the edge cores. Each
-- biome prints how many lie across an edge before (the old test: a long part whose ends differ in
-- height) and how many still float after TierFit.fit, and fails if any floats.
-- The sizes of the fill and barrier parts follow Fill.luau and Barriers.luau (the painted models
-- assumed loaded; anything standing up is left out, as Elevate leaves it). Grass patches, which
-- break a lane into runs, are left out, so a count is close to what Studio names, not equal to it.
-- Run from the project folder:  lune run tests/tierfit

-- The Mire is written ahead of launch (its map and art are built), so this test opens it first.
require("../src/config/ReleaseConfig").OPEN_BIOMES = 4

local Biomes = require("../src/content/Biomes")
local EdgeTrace = require("../src/shared/EdgeTrace")
local Enclosure = require("../src/shared/Enclosure")
local Ground = require("../src/shared/Ground")
local Layout = require("../src/shared/Layout")
local Tamers = require("../src/content/Tamers")
local TierFit = require("../src/shared/TierFit")
local WorldConfig = require("../src/config/WorldConfig")
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

-- A made-up ground: a flat-topped box tier 10 high from x = 0 to 100, so x < 0 is low ground.
local function tiered(): Ground.Ground
	return Ground.new(
		{
			tiers = {
				{
					id = "top",
					height = 10,
					shape = { kind = "Box", at = { x = 50, z = 0 }, size = { 100, 100 } },
				},
			},
			links = {},
		} :: any,
		{ x = 0, z = 0 }
	)
end

local function rect(
	x: number,
	z: number,
	ux: number,
	uz: number,
	half: number,
	side: number
): TierFit.Rect
	return { x = x, z = z, ux = ux, uz = uz, half = half, side = side }
end

print("\n== the rules on a made-up ground ==")
do
	local ground = tiered()
	-- A strip along x from -20 to 20 crosses the edge at x = 0.
	local strip = rect(0, 0, 1, 0, 20, 3)
	check("a strip across the edge lies across two heights", TierFit.lies(ground, strip))
	local cut = TierFit.fit(ground, strip, "Strip")
	local pieces = cut.pieces
	check("it is cut in two", pieces ~= nil and #pieces == 2)
	if pieces then
		check(
			"the low piece lies at 0, the high at 10",
			pieces[1].height == 0 and pieces[2].height == 10
		)
		check(
			"the cut falls on the edge",
			math.abs(pieces[1].to) <= WorldConfig.TIER_FIT_CUT_STEP
				and pieces[1].to == pieces[2].from
		)
	end
	check("a cut strip no longer floats", not TierFit.floats(ground, strip, "Strip", cut))

	-- A strip wholly on the terrace is only lifted.
	local top = TierFit.fit(ground, rect(50, 0, 1, 0, 20, 3), "Strip")
	check("a strip on one height is lifted whole", top.pieces == nil and top.lift == 10)

	-- A wall: on the low ground, stretched to reach its full top on the high.
	local wall = rect(0, 0, 1, 0, 20, 1)
	local stretched = TierFit.fit(ground, wall, "Wall")
	check("a wall sits on the low ground", stretched.lift == 0)
	check("a wall is stretched by the rise", stretched.stretch == 10)
	check("a stretched wall does not float", not TierFit.floats(ground, wall, "Wall", stretched))

	-- Filler centred on the terrace's lip overhangs it: slid onto one height or sunk.
	local filler = rect(12, 0, 1, 0, 15, 10)
	check("filler on the lip lies across", TierFit.lies(ground, filler))
	local slid = TierFit.fit(ground, filler, "Filler")
	check("filler is slid onto the terrace", slid.dx > 0 and slid.lift == 10)
	check("slid filler does not float", not TierFit.floats(ground, filler, "Filler", slid))
	local huge = rect(2, 0, 1, 0, 60, 60)
	local sunk = TierFit.fit(ground, huge, "Filler")
	check(
		"filler too big to fit anywhere is sunk to the low ground",
		sunk.lift == 0 and sunk.dx == 0
	)
	check("sunk filler does not float", not TierFit.floats(ground, huge, "Filler", sunk))
	-- Filler centred on the low ground only buries its far end: left where it is.
	local low = TierFit.fit(ground, rect(-6, 0, 1, 0, 15, 10), "Filler")
	check("filler centred low is left at the low ground", low.lift == 0 and low.dx == 0)

	-- A disc at the lip is trimmed until it fits one height.
	local disc = rect(3, 0, 1, 0, 14, 14)
	local trimmed = TierFit.fit(ground, disc, "Disc")
	local radius = trimmed.radius
	check("a disc on the lip is trimmed", radius ~= nil and radius < 14 and radius >= 1)
	check("a trimmed disc does not float", not TierFit.floats(ground, disc, "Disc", trimmed))
	-- The tier under a point, for colouring a stair's cheeks like the bank it climbs into.
	local under = Ground.tierAt(ground, 50, 0)
	check("tierAt finds the tier under a point", under ~= nil and under.id == "top")
	check("tierAt finds none on the low ground", Ground.tierAt(ground, -10, 0) == nil)
end

-- Every open biome laid out in one world, as the server does.
local ordered: { WorldTypes.Biome } = {}
for _, biome in Biomes do
	table.insert(ordered, biome)
end
table.sort(ordered, function(a, b)
	return a.number < b.number
end)
local world = Layout.world(ordered, Tamers.locals)

type Piece = { label: string, rect: TierFit.Rect, kind: TierFit.Kind }

-- The straight pieces a run of points is built in (Fences.pieces): points every stud, a piece
-- ends at a corner or after 36 studs.
local function resample(points: { Layout.Point }): { Layout.Point }
	local out: { Layout.Point } = {}
	for index = 1, #points - 1 do
		local a, b = points[index], points[index + 1]
		local count = math.max(1, math.ceil(Layout.distance(a, b)))
		for k = 0, count - 1 do
			table.insert(
				out,
				{ x = a.x + (b.x - a.x) * k / count, z = a.z + (b.z - a.z) * k / count }
			)
		end
	end
	if #points > 0 then
		table.insert(out, points[#points])
	end
	return out
end

local function straight(points: { Layout.Point }): { { Layout.Point } }
	local samples = resample(points)
	local out: { { Layout.Point } } = {}
	local start = 1
	while start < #samples do
		local finish = start + 1
		while finish < #samples and finish - start < 36 do
			local a, b, after = samples[start], samples[finish], samples[finish + 1]
			local rx, rz = after.x - a.x, after.z - a.z
			local length = math.sqrt(rx * rx + rz * rz)
			if length > 1e-3 then
				local ux, uz = rx / length, rz / length
				local dx, dz = b.x - a.x, b.z - a.z
				local along = dx * ux + dz * uz
				local ox, oz = dx - ux * along, dz - uz * along
				if math.sqrt(ox * ox + oz * oz) > 0.6 then
					break
				end
			end
			finish += 1
		end
		table.insert(out, { samples[start], samples[finish] })
		start = finish
	end
	return out
end

-- The rectangle of a block, strip or slab from a to b, `thick` across, `extra` longer than the run.
local function between(
	a: Layout.Point,
	b: Layout.Point,
	thick: number,
	extra: number
): TierFit.Rect?
	local length = Layout.distance(a, b)
	if length < 0.2 then
		return nil
	end
	return rect(
		(a.x + b.x) / 2,
		(a.z + b.z) / 2,
		(b.x - a.x) / length,
		(b.z - a.z) / length,
		(length + extra) / 2,
		thick / 2
	)
end

-- True for a part standing up, which Elevate leaves on the height under its middle.
local function standing(x: number, y: number, z: number): boolean
	return y > math.max(x, z) * 0.6 and y > 4
end

local function add(list: { Piece }, label: string, kind: TierFit.Kind, r: TierFit.Rect?)
	if r then
		table.insert(list, { label = label, rect = r, kind = kind })
	end
end

-- A lane, street or footpath along a line: a strip between each pair of points and a disc at
-- every point, like Lanes.build, Scenery.lane and CorridorGround.
local function laneAlong(list: { Piece }, label: string, points: { Layout.Point }, width: number)
	for index, point in points do
		add(list, `{label} disc`, "Disc", rect(point.x, point.z, 1, 0, width / 2, width / 2))
		local after = points[index + 1]
		if after then
			add(list, `{label} strip`, "Strip", between(point, after, width, 0))
		end
	end
end

-- Each lane run of a route: its points from where it starts to where a stair, a ramp (or the end)
-- stops it, as Lanes.build lays them.
local function routeRuns(ground: Ground.Ground, line: Layout.RouteLine): { { Layout.Point } }
	local runs: { { Layout.Point } } = {}
	local from: number? = nil
	local function finish(upTo: number)
		local start = from
		if start and upTo - start >= 0.5 then
			local points = { Layout.pointAt(line, start) }
			local covered = 0
			for k = 1, #line.points - 1 do
				covered += Layout.distance(line.points[k], line.points[k + 1])
				if covered > start and covered < upTo then
					table.insert(points, line.points[k + 1])
				end
			end
			table.insert(points, Layout.pointAt(line, upTo))
			table.insert(runs, points)
		end
		from = nil
	end
	local along = 0
	while true do
		local at = Layout.pointAt(line, along)
		if Ground.linkAt(ground, at.x, at.z, 1) then
			finish(along)
		elseif from == nil then
			from = along
		end
		if along >= line.length then
			break
		end
		along = math.min(along + 2, line.length)
	end
	finish(line.length)
	return runs
end

-- Where the fill's parts lie, from the plan Enclosure.fill makes: the sizes follow Fill.luau.
local function second(pick: number): number
	return (pick * 7.13) % 1
end

local function fillPieces(style: string, plan: Enclosure.FillPlan): { Piece }
	local list: { Piece } = {}
	local function mass(spot: Enclosure.Spot, across: number, tall: number, pick: number)
		local turn = second(pick) * math.pi * 2
		local ux, uz = math.cos(turn), math.sin(turn)
		if style == "Rock" then
			if not standing(across, tall, across * 0.7) then
				add(list, "fill", "Filler", rect(spot.x, spot.z, ux, uz, across / 2, across * 0.35))
			end
		elseif style == "Dune" then
			local low = math.min(tall, across * 0.45)
			if not standing(across * 1.3, low, across) then
				add(list, "fill", "Filler", rect(spot.x, spot.z, ux, uz, across * 0.65, across / 2))
			end
		elseif not standing(across, tall, across) then
			add(list, "fill", "Filler", rect(spot.x, spot.z, 1, 0, across / 2, across / 2))
		end
	end
	for _, spot in plan.rows do
		-- Trees and spires stand up; only the plain masses lie.
		if style == "Dune" then
			mass(spot, spot.tall * 1.6, spot.tall, second(spot.pick))
		elseif style == "Rock" and spot.pick >= 0.65 then
			mass(spot, spot.tall * 0.9, spot.tall, second(spot.pick))
		end
	end
	for _, spot in plan.masses do
		mass(spot, 24 + second(spot.pick) * 8, spot.tall, spot.pick)
	end
	for _, spot in plan.blocks do
		mass(spot, 36 + second(spot.pick) * 6, spot.tall, spot.pick)
	end
	return list
end

-- The edge cores: an unseen wall 2 thick along every kept stretch of every traced edge.
local function edgeCores(trace: EdgeTrace.Trace, dressing: WorldTypes.DressingSheet): { Piece }
	local list: { Piece } = {}
	local function cores(run: { Layout.Point })
		for _, piece in straight(run) do
			add(list, "edge core", "Wall", between(piece[1], piece[2], 2, 1))
		end
	end
	local function walk(samples: { any })
		local run: { Layout.Point } = {}
		for _, sample in samples do
			if sample.keep then
				table.insert(run, { x = sample.x, z = sample.z })
			else
				cores(run)
				run = {}
			end
		end
		cores(run)
	end
	for _, corridor in trace.corridors do
		for _, side in { -1, 1 } do
			walk(EdgeTrace.side(trace, corridor, side))
		end
		local gap = dressing.caps[corridor.id]
		if gap then
			local length = corridor.line.length
			local centre = Layout.pointAt(corridor.line, length)
			local runX, runZ = EdgeTrace.heading(corridor.line, length)
			local width = corridor.widthAt(length)
			for _, side in { -1, 1 } do
				cores({
					{ x = centre.x - runZ * side * gap, z = centre.z + runX * side * gap },
					{ x = centre.x - runZ * side * width, z = centre.z + runX * side * width },
				})
			end
		end
	end
	for _, room in trace.space.sheetRooms do
		walk(EdgeTrace.room(trace, room))
	end
	for _, ring in trace.rings do
		walk(EdgeTrace.ring(trace, ring))
	end
	return list
end

local KINDS = {
	"lane strip",
	"lane disc",
	"street strip",
	"street disc",
	"sealed road",
	"fill",
	"water barrier",
	"edge core",
}

for _, biome in ordered do
	local map = world.maps[biome.number]
	local dressing = DressingSheets[biome.id]
	if biome.map == nil or map == nil or dressing == nil then
		continue
	end
	print(`\n== {biome.name}: parts across a tier edge, before and after ==`)
	local origin: Layout.Point = { x = map.hub.x, z = map.hub.z }
	local ground = Ground.new(biome.map, origin)
	local trace = EdgeTrace.new(biome, map, dressing, ground)
	local list: { Piece } = {}
	local function placed(points: { WorldTypes.SheetPoint }): { Layout.Point }
		local out: { Layout.Point } = {}
		for _, point in points do
			table.insert(out, { x = map.hub.x + point.x, z = map.hub.z + point.z })
		end
		return out
	end

	-- Route lanes and the lair spur.
	local lines: { Layout.RouteLine } = {}
	for _, route in biome.routes do
		table.insert(lines, map.routes[route.id])
	end
	if #map.lairSpur >= 2 then
		local length = 0
		for k = 1, #map.lairSpur - 1 do
			length += Layout.distance(map.lairSpur[k], map.lairSpur[k + 1])
		end
		table.insert(
			lines,
			{ id = biome.lair.id, points = map.lairSpur, length = length, side = 0 }
		)
	end
	for _, line in lines do
		for _, run in routeRuns(ground, line) do
			laneAlong(list, "lane", run, dressing.laneWidth)
		end
	end
	-- Town streets and footpaths (decks are raised planks, not laid on the ground).
	for _, street in dressing.lanes do
		if not street.deck then
			laneAlong(list, "street", placed(street.points), street.width)
		end
	end
	for _, path in dressing.footpaths do
		laneAlong(list, "street", placed(path.points), path.width)
	end
	-- The stone road on past the gate.
	local gate, sealed = map.places[biome.gate.id], map.places[biome.gate.sealedPath]
	if gate and sealed then
		local length = math.max(Layout.distance(gate, sealed), 1e-6)
		local beyond = {
			x = sealed.x + (sealed.x - gate.x) / length * 60,
			z = sealed.z + (sealed.z - gate.z) / length * 60,
		}
		add(
			list,
			"sealed road",
			"Strip",
			between(gate, beyond, dressing.laneWidth, dressing.laneWidth * 0.2)
		)
	end
	-- Fill, barriers and cores.
	local shapes = Enclosure.walkable(biome, map, dressing, {})
	local limits = Enclosure.bounds(shapes, 220)
	local fill = dressing.fill
	if fill then
		local plan = Enclosure.fill(
			shapes,
			limits,
			fill.style,
			fill.band,
			biome.number * 101,
			Enclosure.seas(map, dressing)
		)
		for _, piece in fillPieces(fill.style, plan) do
			table.insert(list, piece)
		end
	end
	local water = Enclosure.water(biome, map, dressing, shapes, limits)
	for _, run in water.runs do
		for _, piece in straight(run.points) do
			add(
				list,
				"water barrier",
				"Wall",
				between(piece[1], piece[2], run.thick, run.thick / 2)
			)
		end
	end
	for _, tile in water.tiles do
		add(
			list,
			"water barrier",
			"Wall",
			rect(
				(tile.x0 + tile.x1) / 2,
				(tile.z0 + tile.z1) / 2,
				1,
				0,
				(tile.x1 - tile.x0) / 2,
				(tile.z1 - tile.z0) / 2
			)
		)
	end
	for _, piece in edgeCores(trace, dressing) do
		table.insert(list, piece)
	end

	local before: { [string]: number } = {}
	local after: { [string]: number } = {}
	local total: { [string]: number } = {}
	for _, kind in KINDS do
		before[kind], after[kind], total[kind] = 0, 0, 0
	end
	local lines_: { string } = {}
	local floating = 0
	for _, piece in list do
		total[piece.label] = (total[piece.label] or 0) + 1
		if TierFit.lies(ground, piece.rect) then
			before[piece.label] = (before[piece.label] or 0) + 1
			local fit = TierFit.fit(ground, piece.rect, piece.kind)
			if TierFit.floats(ground, piece.rect, piece.kind, fit) then
				after[piece.label] = (after[piece.label] or 0) + 1
				floating += 1
			end
		end
	end
	for _, kind in KINDS do
		table.insert(lines_, `{kind}: {before[kind]} -> {after[kind]} of {total[kind]}`)
	end
	local sumBefore = 0
	for _, kind in KINDS do
		sumBefore += before[kind]
	end
	print(`  across an edge before, floating after (of all made): {table.concat(lines_, "; ")}`)
	check(
		`{biome.name}: the parts read from the data reproduce the old warnings`,
		sumBefore > 0,
		`{sumBefore} lay across an edge`
	)
	check(
		`{biome.name}: no part left floating over an edge ({sumBefore} lay across one before)`,
		floating == 0,
		`{floating} still float`
	)
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("tier fit checks failed")
end
