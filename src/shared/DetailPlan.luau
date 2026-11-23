--!strict
-- Small ground detail for a designed biome, as plain numbers (docs: src/config/DetailConfig and
-- each dressing sheet's `scatter`): a sparse scatter of flowers, pebbles, shells and tufts on the
-- town's lawn and along every route's verges, and the paving pattern of the plaza. The server's
-- builder (World/Detail.luau) stands one thing for each item and piece; tests/detail.test.luau
-- checks the counts and that nothing lands on a lane, a prompt, a patch of grass or a tier's edge.
-- Same inputs, same plan: every roll comes from Rng with a seed from the biome's number.
-- No Roblox services.

local DetailConfig = require("../config/DetailConfig")
local EdgeTrace = require("./EdgeTrace")
local Ground = require("./Ground")
local Layout = require("./Layout")
local Rng = require("./Rng")
local WorldTypes = require("./WorldTypes")

local DetailPlan = {}

export type Item = {
	kind: string,
	shape: WorldTypes.ScatterShape,
	zone: WorldTypes.ScatterZone,
	model: string?,
	x: number,
	z: number,
	size: number, -- a model's height, or a bloom's, pebble's or shell's width
	yaw: number,
	colour: { number },
	count: number, -- parts to a cluster (1 for a model)
	seed: number, -- the builder's own rolls inside a cluster
}
-- One flat piece of the plaza's pattern: a paving stone (a box, `w` along its tangent), a disc
-- (`w` across), a flower bed's earth or one of its blooms (a lump, `w` across).
export type Piece = {
	kind: "Stone" | "Disc" | "Bed" | "Bloom",
	x: number,
	z: number,
	w: number,
	d: number,
	yaw: number,
	colour: { number },
}
export type Plan = { items: { Item }, parts: number }

type Circle = { x: number, z: number, r: number }
-- `half` is a strip's half-width; `soft` is a margin beyond it that only the lawn and verge scatter keep
-- (the fringe along a lane may stand inside it).
type Line = { points: { Layout.Point }, half: number, soft: number }
type Rect = { x0: number, z0: number, x1: number, z1: number }
type Box = { x: number, z: number, faces: number, width: number, depth: number }
type Blocks = {
	circles: { Circle },
	lines: { Line },
	rects: { Rect },
	boxes: { Box },
}

local function dist(ax: number, az: number, bx: number, bz: number): number
	return math.sqrt((ax - bx) ^ 2 + (az - bz) ^ 2)
end

-- How far a point is outside a line's strip (negative inside): distance to the nearest leg less
-- the half-width.
local function offLine(line: Line, x: number, z: number): number
	local _, off = EdgeTrace.nearest(line.points, x, z)
	return off - line.half
end

local function boxGap(box: Box, x: number, z: number): number
	local face = Layout.facing(box.faces)
	local dx, dz = x - box.x, z - box.z
	local deep = math.abs(dx * face.x + dz * face.z) - box.depth / 2
	local wide = math.abs(dx * -face.z + dz * face.x) - box.width / 2
	return math.sqrt(math.max(deep, 0) ^ 2 + math.max(wide, 0) ^ 2)
end

-- Everything scatter keeps off, gathered once as circles, strips, rectangles and boxes, each
-- already padded by its own margin (so `blocked` is one distance test per thing).
local function gather(
	biome: WorldTypes.Biome,
	map: Layout.Map,
	dressing: WorldTypes.DressingSheet,
	trace: EdgeTrace.Trace
): Blocks
	local blocks: Blocks = { circles = {}, lines = {}, rects = {}, boxes = {} }
	local ox, oz = map.hub.x, map.hub.z
	local function place(point: WorldTypes.SheetPoint): Layout.Point
		return { x = ox + point.x, z = oz + point.z }
	end
	local function circle(point: Layout.Point, radius: number)
		table.insert(blocks.circles, { x = point.x, z = point.z, r = radius })
	end
	local function line(points: { WorldTypes.SheetPoint }, half: number, soft: number?)
		local placed: { Layout.Point } = {}
		for _, point in points do
			table.insert(placed, place(point))
		end
		table.insert(blocks.lines, { points = placed, half = half, soft = soft or 0 })
	end

	for _, spot in trace.spots do
		circle(spot, DetailConfig.SPOT_CLEAR)
	end
	for _, route in biome.routes do
		for _, spot in route.rustleSpots do
			local point = map.places[spot.id]
			if point then
				circle(point, DetailConfig.RUSTLE_CLEAR)
			end
		end
	end
	for _, patches in map.grass do
		for _, patch in patches do
			circle(patch, patch.r + DetailConfig.GRASS_PAD)
		end
	end
	-- Every lane: the routes and the spur, and the town's streets and paths.
	for _, corridor in trace.corridors do
		table.insert(blocks.lines, {
			points = corridor.points,
			half = dressing.laneWidth / 2,
			soft = DetailConfig.LANE_PAD,
		})
	end
	for _, lane in dressing.lanes do
		line(lane.points, lane.width / 2, DetailConfig.TOWN_LANE_PAD)
	end
	for _, path in dressing.footpaths do
		line(path.points, path.width / 2, DetailConfig.TOWN_LANE_PAD)
	end
	for _, stones in dressing.stones do
		line({ stones.from, stones.to }, DetailConfig.THING_PAD)
	end
	-- Water, with its banks.
	for _, stream in dressing.water do
		line(stream.points, stream.width / 2 + DetailConfig.WATER_PAD)
	end
	for _, pool in dressing.pools do
		circle(place(pool.at), pool.radius + DetailConfig.WATER_PAD)
	end
	local pond = dressing.pond
	if pond then
		circle(place(pond.at), pond.radius + DetailConfig.WATER_PAD)
		line(pond.jetty, 4)
	end
	local flats: { WorldTypes.DressFlat } = dressing.flats or {}
	for _, flat in flats do
		if flat.water then
			local a, b = place(flat.from), place(flat.to)
			table.insert(blocks.rects, {
				x0 = math.min(a.x, b.x) - DetailConfig.WATER_PAD,
				z0 = math.min(a.z, b.z) - DetailConfig.WATER_PAD,
				x1 = math.max(a.x, b.x) + DetailConfig.WATER_PAD,
				z1 = math.max(a.z, b.z) + DetailConfig.WATER_PAD,
			})
		end
	end
	-- Fences, hedges, walls and rows of trees.
	for _, fence in dressing.fences do
		line(fence.points, DetailConfig.THING_PAD)
	end
	for _, hedge in dressing.hedges do
		line(hedge, DetailConfig.THING_PAD)
	end
	local walls: { WorldTypes.DressWall } = dressing.walls or {}
	for _, wall in walls do
		line(wall.points, DetailConfig.THING_PAD + 2)
	end
	for _, row in dressing.rows do
		line({ row.from, row.to }, DetailConfig.THING_PAD)
	end
	-- Buildings and houses, as boxes; a building the sheet gives no size is a circle.
	for id, centre in map.buildings do
		local size = dressing.buildings[id]
		local faces = map.faces[id]
		if size and faces then
			table.insert(blocks.boxes, {
				x = centre.x,
				z = centre.z,
				faces = faces,
				width = size.width + DetailConfig.THING_PAD * 2,
				depth = size.depth + DetailConfig.THING_PAD * 2,
			})
		else
			circle(centre, 16)
		end
	end
	for _, house in dressing.houses do
		local centre = place(house.at)
		table.insert(blocks.boxes, {
			x = centre.x,
			z = centre.z,
			faces = house.faces,
			width = house.width + DetailConfig.THING_PAD * 2,
			depth = house.depth + DetailConfig.THING_PAD * 2,
		})
	end
	for _, thing in dressing.props do
		circle(place(thing.at), thing.tall * 0.5 + 2)
	end
	for _, tree in dressing.trees do
		circle(place(tree.at), 5)
	end
	for _, bramble in dressing.brambles do
		circle(place(bramble), 5)
	end
	for _, arch in dressing.arches do
		circle(place(arch.at), 10)
	end
	for _, sign in dressing.signs do
		circle(place(sign.at), 3)
	end
	for _, lamp in dressing.lamps do
		circle(place(lamp), 3)
	end
	for _, bed in dressing.beds do
		circle(place(bed), 5)
	end
	local well = dressing.well
	if well then
		circle(place(well), 8)
	end
	local coop = dressing.coop
	if coop then
		circle(place(coop), 8)
	end
	local knoll = dressing.knoll
	if knoll then
		circle(place(knoll.at), math.max(knoll.size[1], knoll.size[2] or knoll.size[1]) / 2 + 3)
	end
	local picnic = dressing.picnic
	if picnic then
		circle(place(picnic.at), picnic.radius + 3)
	end
	local pocket = dressing.pocket
	if pocket then
		circle(place(pocket.at), pocket.radius + 3)
	end
	local bridge = dressing.footbridge
	if bridge then
		circle(place(bridge.at), bridge.length / 2 + 4)
	end
	local gate = dressing.gatehouse
	circle(place(gate.at), 24)
	circle(place(dressing.bar.at), dressing.bar.width / 2 + 3)
	local ancient = dressing.ancientTree
	if ancient then
		circle(place(ancient.at), ancient.tall * 0.4 + 3)
	end
	-- The plaza has its own pattern; the clearings (the lair's arena) are left alone.
	local plaza = dressing.plaza
	circle(place(plaza.at), plaza.rim / 2 + 3)
	for _, ring in trace.rings do
		circle(ring, ring.radius + 4)
	end
	for _, bulge in trace.bulges do
		circle(bulge, bulge.radius + 3)
	end
	return blocks
end

-- True when something is in the way at a point.
local function blocked(blocks: Blocks, x: number, z: number, fringe: boolean): boolean
	for _, c in blocks.circles do
		if dist(x, z, c.x, c.z) < c.r then
			return true
		end
	end
	for _, rect in blocks.rects do
		if x >= rect.x0 and x <= rect.x1 and z >= rect.z0 and z <= rect.z1 then
			return true
		end
	end
	for _, box in blocks.boxes do
		if boxGap(box, x, z) < 0.5 then
			return true
		end
	end
	for _, l in blocks.lines do
		if
			offLine(l, x, z)
			< (if l.soft == 0 then 0 elseif fringe then DetailConfig.EDGING_NEAR - 0.2 else l.soft)
		then
			return true
		end
	end
	return false
end

-- True where the ground is one height round a point and no tier wall, stair, ramp or ledge is
-- near: a clay flower on a cliff's lip would hang in the air.
local function levelGround(ground: Ground.Ground, x: number, z: number): boolean
	if
		Ground.atFoot(ground, x, z, DetailConfig.TIER_FOOT_PAD)
		or Ground.linkAt(ground, x, z, DetailConfig.LINK_PAD) ~= nil
		or Ground.ledgeAt(ground, x, z, DetailConfig.TIER_FOOT_PAD) ~= nil
	then
		return false
	end
	local here = Ground.heightAt(ground, x, z)
	local r = DetailConfig.FLAT_RADIUS
	for _, step in { { r, 0 }, { -r, 0 }, { 0, r }, { 0, -r } } do
		if math.abs(Ground.heightAt(ground, x + step[1], z + step[2]) - here) > 0.05 then
			return false
		end
	end
	return true
end

local function vary(rng: Rng.Rng, colour: { number }): { number }
	local out: { number } = {}
	for index = 1, 3 do
		local jitter = DetailConfig.COLOUR_JITTER
		table.insert(
			out,
			math.clamp(math.floor(colour[index] + (Rng.next(rng) * 2 - 1) * jitter + 0.5), 0, 255)
		)
	end
	return out
end

-- Rolls the items of every kind in the sheet at one density scale. Returns them and their parts.
local function roll(
	biome: WorldTypes.Biome,
	map: Layout.Map,
	dressing: WorldTypes.DressingSheet,
	sheet: WorldTypes.ScatterSheet,
	trace: EdgeTrace.Trace,
	blocks: Blocks,
	scale: number
): Plan
	local items: { Item } = {}
	local parts = 0
	local ground = trace.ground
	local ox, oz = map.hub.x, map.hub.z
	local half = map.hub.size / 2 - DetailConfig.TOWN_MARGIN
	local laneHalf = dressing.laneWidth / 2

	for index, kind in sheet.kinds do
		local rng = Rng.new(DetailConfig.SEED + biome.number * 101 + index * 7919)
		local function add(x: number, z: number)
			if blocked(blocks, x, z, kind.zone == "Edging") or not levelGround(ground, x, z) then
				return
			end
			-- Out on a verge, well inside a corridor: its edge stands further out.
			if
				kind.zone ~= "Town" and not EdgeTrace.insideAny(trace, x, z, DetailConfig.EDGE_PAD)
			then
				return
			end
			local count = 1
			if kind.shape ~= "Model" then
				local range = kind.count or { 1, 1 }
				count = Rng.int(rng, range[1], range[2])
			end
			local low, high = kind.tall[1], kind.tall[2]
			table.insert(items, {
				kind = kind.id,
				shape = kind.shape,
				zone = kind.zone,
				model = kind.model,
				x = x,
				z = z,
				size = low + (high - low) * Rng.next(rng),
				yaw = Rng.next(rng) * math.pi * 2,
				colour = vary(rng, Rng.pick(rng, kind.colours)),
				count = count,
				seed = Rng.int(rng, 1, 2147483000),
			})
			parts += count
		end
		-- A roll of `expected` items: the whole number, and the fraction as a chance.
		local function rolls(expected: number): number
			local whole = math.floor(expected)
			return whole + (if Rng.next(rng) < expected - whole then 1 else 0)
		end
		local per = kind.density * scale / 10000
		if kind.zone == "Town" then
			local cell = DetailConfig.CELL
			local x = -half
			while x < half do
				local z = -half
				while z < half do
					for _ = 1, rolls(per * cell * cell) do
						add(ox + x + Rng.next(rng) * cell, oz + z + Rng.next(rng) * cell)
					end
					z += cell
				end
				x += cell
			end
		elseif kind.zone == "Verge" or kind.zone == "Edging" then
			local step = DetailConfig.STEP
			for _, corridor in trace.corridors do
				local along = 0
				while along <= corridor.line.length do
					local centre = Layout.pointAt(corridor.line, along)
					local rx, rz = EdgeTrace.heading(corridor.line, along)
					local near, far
					if kind.zone == "Verge" then
						near = laneHalf + DetailConfig.LANE_PAD
						far = corridor.widthAt(along) - DetailConfig.EDGE_PAD
					else
						near = laneHalf + DetailConfig.EDGING_NEAR
						far = math.min(
							laneHalf + DetailConfig.EDGING_FAR,
							corridor.widthAt(along) - DetailConfig.EDGE_PAD
						)
					end
					if far > near then
						for _, side in { -1, 1 } do
							for _ = 1, rolls(per * step * (far - near)) do
								local off = near + (far - near) * Rng.next(rng)
								local slide = (Rng.next(rng) - 0.5) * step
								add(
									centre.x + (-rz * side) * off + rx * slide,
									centre.z + (rx * side) * off + rz * slide
								)
							end
						end
					end
					along += step
				end
			end
			-- Town streets are fringed too.
			if kind.zone == "Edging" then
				for _, lane in dressing.lanes do
					local width = lane.width / 2
					for leg = 1, #lane.points - 1 do
						local a = lane.points[leg]
						local b = lane.points[leg + 1]
						local length = dist(a.x, a.z, b.x, b.z)
						if length > 1e-3 then
							local ux, uz = (b.x - a.x) / length, (b.z - a.z) / length
							local reach = 0
							while reach < length do
								for _, side in { -1, 1 } do
									for _ = 1, rolls(per * step * DetailConfig.EDGING_FAR) do
										local off = width
											+ DetailConfig.EDGING_NEAR
											+ Rng.next(rng) * DetailConfig.EDGING_FAR
										add(
											ox
												+ a.x
												+ ux * (reach + Rng.next(rng) * step)
												- uz * side * off,
											oz
												+ a.z
												+ uz * (reach + Rng.next(rng) * step)
												+ ux * side * off
										)
									end
								end
								reach += step
							end
						end
					end
				end
			end
		end
	end
	return { items = items, parts = parts }
end

-- Every scatter item of a biome, thinned evenly (all densities scaled down together) until its
-- parts fit the sheet's budget. A sheet with no `scatter` has none.
function DetailPlan.scatter(
	biome: WorldTypes.Biome,
	map: Layout.Map,
	dressing: WorldTypes.DressingSheet,
	ground: Ground.Ground
): Plan
	local sheet = dressing.scatter
	if sheet == nil then
		return { items = {}, parts = 0 }
	end
	local trace = EdgeTrace.new(biome, map, dressing, ground)
	local blocks = gather(biome, map, dressing, trace)
	local scale = 1
	local plan = roll(biome, map, dressing, sheet, trace, blocks, scale)
	for _ = 1, 6 do
		if plan.parts <= sheet.budget then
			break
		end
		scale *= sheet.budget / plan.parts * 0.96
		plan = roll(biome, map, dressing, sheet, trace, blocks, scale)
	end
	return plan
end

local function shade(colour: { number }, by: number): { number }
	return {
		math.clamp(math.floor(colour[1] * by + 0.5), 0, 255),
		math.clamp(math.floor(colour[2] * by + 0.5), 0, 255),
		math.clamp(math.floor(colour[3] * by + 0.5), 0, 255),
	}
end

local BLOOMS: { { number } } =
	{ { 250, 220, 90 }, { 240, 130, 150 }, { 250, 250, 250 }, { 170, 140, 240 } }

-- The plaza's pattern: a ring of paving stones just inside its rim (left out where a street or
-- a fitting comes in), a centre motif of shaded rings and rays, and flower beds between.
function DetailPlan.plaza(
	biome: WorldTypes.Biome,
	map: Layout.Map,
	dressing: WorldTypes.DressingSheet,
	ground: Ground.Ground
): { Piece }
	local trace = EdgeTrace.new(biome, map, dressing, ground)
	local blocks = gather(biome, map, dressing, trace)
	local plaza = dressing.plaza
	local cx, cz = map.hub.x + plaza.at.x, map.hub.z + plaza.at.z
	local base = plaza.colour or { 222, 204, 168 }
	local pieces: { Piece } = {}
	-- What a stone or a bed must keep off: prompts, doors, fittings and the mouths of streets.
	local function crowded(x: number, z: number, clear: number): boolean
		for _, spot in trace.spots do
			if dist(x, z, spot.x, spot.z) < clear then
				return true
			end
		end
		for _, lane in dressing.lanes do
			local points: { Layout.Point } = {}
			for _, point in lane.points do
				table.insert(points, { x = map.hub.x + point.x, z = map.hub.z + point.z })
			end
			local _, off = EdgeTrace.nearest(points, x, z)
			if off < lane.width / 2 + 1 then
				return true
			end
		end
		for _, c in blocks.circles do
			-- Only the small fittings (a well, a lamp, a bed, a sign, a prompt's room).
			if c.r <= 8 and dist(x, z, c.x, c.z) < c.r + 1 then
				return true
			end
		end
		return false
	end

	-- The ring of stones.
	local radius = plaza.size / 2 - DetailConfig.STONE_INSET
	local count =
		math.floor(2 * math.pi * radius / (DetailConfig.STONE_LENGTH + DetailConfig.STONE_GAP))
	for k = 0, count - 1 do
		local angle = k / count * math.pi * 2
		local x, z = cx + math.cos(angle) * radius, cz + math.sin(angle) * radius
		if not crowded(x, z, DetailConfig.STONE_CLEAR) then
			table.insert(pieces, {
				kind = "Stone",
				x = x,
				z = z,
				w = DetailConfig.STONE_LENGTH,
				d = DetailConfig.STONE_DEPTH,
				yaw = -angle + math.pi / 2,
				colour = shade(base, DetailConfig.STONE_DARK[k % 2 + 1]),
			})
		end
	end
	-- The centre motif: rings, then rays between the two outer ones.
	for _, ring in DetailConfig.MOTIF_RINGS do
		table.insert(pieces, {
			kind = "Disc",
			x = cx,
			z = cz,
			w = plaza.size * ring[1],
			d = plaza.size * ring[1],
			yaw = 0,
			colour = shade(base, ring[2]),
		})
	end
	local rays = DetailConfig.MOTIF_RAYS
	local inner = plaza.size * DetailConfig.MOTIF_RINGS[2][1] / 2
	local outer = plaza.size * DetailConfig.MOTIF_RINGS[1][1] / 2
	for k = 0, rays - 1 do
		local angle = k / rays * math.pi * 2 + math.pi / rays
		local mid = (inner + outer) / 2
		table.insert(pieces, {
			kind = "Stone",
			x = cx + math.cos(angle) * mid,
			z = cz + math.sin(angle) * mid,
			w = outer - inner - 0.6,
			d = 1.2,
			yaw = -angle,
			colour = shade(base, 0.8),
		})
	end
	-- The flower beds, between the motif and the ring.
	local rng = Rng.new(DetailConfig.SEED + biome.number)
	for k = 0, DetailConfig.BEDS - 1 do
		local angle = (k + 0.5) / DetailConfig.BEDS * math.pi * 2
		local x = cx + math.cos(angle) * plaza.size * DetailConfig.BED_RADIUS
		local z = cz + math.sin(angle) * plaza.size * DetailConfig.BED_RADIUS
		if not crowded(x, z, DetailConfig.BED_CLEAR) then
			table.insert(pieces, {
				kind = "Bed",
				x = x,
				z = z,
				w = DetailConfig.BED_SIZE,
				d = DetailConfig.BED_SIZE,
				yaw = 0,
				colour = { 110, 84, 60 },
			})
			for bloom = 1, DetailConfig.BED_BLOOMS do
				local turn = bloom / DetailConfig.BED_BLOOMS * math.pi * 2
				table.insert(pieces, {
					kind = "Bloom",
					x = x + math.cos(turn) * DetailConfig.BED_SIZE * 0.28,
					z = z + math.sin(turn) * DetailConfig.BED_SIZE * 0.28,
					w = 1.3,
					d = 1.3,
					yaw = 0,
					colour = BLOOMS[Rng.int(rng, 1, #BLOOMS)],
				})
			end
		end
	end
	return pieces
end

return DetailPlan
