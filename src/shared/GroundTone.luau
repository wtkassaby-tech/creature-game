--!strict
-- The tone of the open ground, as plain numbers (no Roblox services): large soft patches of
-- off-colour on a biome's lawns and verges, so a field is not one flat colour, and the band of
-- graded ground colour where two biomes' slabs meet, so the seam is not a hard straight line.
-- The patches' look and the seam's width are in src/config/DetailConfig; which colours, how big and
-- how many are in each dressing sheet's `blotches`. The server's builder (World/Detail.luau)
-- stands the parts; tests/groundtone.test.luau checks them. Same inputs, same plan.

local DetailConfig = require("../config/DetailConfig")
local EdgeTrace = require("./EdgeTrace")
local Ground = require("./Ground")
local Layout = require("./Layout")
local Rng = require("./Rng")
local WorldTypes = require("./WorldTypes")

local GroundTone = {}

-- One soft patch: an ellipse `w` by `d` (its long axis along `yaw`), centred on (x, z).
export type Blotch = {
	x: number,
	z: number,
	w: number,
	d: number,
	yaw: number,
	colour: { number },
}
-- One band of the seam: a box `w` along x and `d` along z, centred on (x, z).
export type Band = { x: number, z: number, w: number, d: number, colour: { number } }

local function dist(ax: number, az: number, bx: number, bz: number): number
	return math.sqrt((ax - bx) ^ 2 + (az - bz) ^ 2)
end

-- The colour of a biome's open ground: its fill's floor (dark under trees), else its field ground,
-- else the plain green.
function GroundTone.fieldColour(dressing: WorldTypes.DressingSheet): WorldTypes.Colour
	local fill = dressing.fill
	if fill then
		return fill.floor
	end
	return dressing.fieldGround or DetailConfig.DEFAULT_FIELD
end

-- Where in z a biome's ground slab lies (TestMap's slab: its places and rooms, with a margin).
function GroundTone.slabSpan(biome: WorldTypes.Biome, map: Layout.Map): (number, number)
	local minZ, maxZ = math.huge, -math.huge
	for _, place in map.places do
		minZ, maxZ = math.min(minZ, place.z), math.max(maxZ, place.z)
	end
	local rooms: { WorldTypes.Room } = if biome.map and biome.map.rooms then biome.map.rooms else {}
	for _, room in rooms do
		local shape = room.shape
		local ends: { WorldTypes.SheetPoint } = if shape.kind == "Strip"
			then { shape.from, shape.to }
			else { shape.at }
		for _, point in ends do
			minZ, maxZ = math.min(minZ, map.hub.z + point.z), math.max(maxZ, map.hub.z + point.z)
		end
	end
	local margin = DetailConfig.SEAM_MARGIN
	local depth = math.min(DetailConfig.SEAM_MAX_DEPTH, maxZ - minZ + margin * 2)
	local middle = (minZ + maxZ) / 2
	return middle - depth / 2, middle + depth / 2
end

-- A colour between two, as whole channels.
local function mix(a: WorldTypes.Colour, b: WorldTypes.Colour, t: number): { number }
	local out: { number } = {}
	for index = 1, 3 do
		table.insert(
			out,
			math.clamp(math.floor(a[index] + (b[index] - a[index]) * t + 0.5), 0, 255)
		)
	end
	return out
end

-- The bands of a seam centred on x = `x`, graded from `west` to `east` over SEAM_WIDTH studs and
-- running from `z0` to `z1`.
function GroundTone.seam(
	west: WorldTypes.Colour,
	east: WorldTypes.Colour,
	x: number,
	z0: number,
	z1: number
): { Band }
	local steps = DetailConfig.SEAM_STEPS
	local width = DetailConfig.SEAM_WIDTH
	local each = width / steps
	local bands: { Band } = {}
	for k = 1, steps do
		table.insert(bands, {
			x = x - width / 2 + (k - 0.5) * each,
			z = (z0 + z1) / 2,
			w = each + 0.2, -- a hair of overlap: no crack between two bands
			d = z1 - z0,
			colour = mix(west, east, (k - 0.5) / steps),
		})
	end
	return bands
end

type Wet = { points: { Layout.Point }, half: number }
type Rect = { x0: number, z0: number, x1: number, z1: number }

-- Everything a patch keeps off: water of every kind.
local function wetThings(map: Layout.Map, dressing: WorldTypes.DressingSheet): ({ Wet }, { Rect })
	local ox, oz = map.hub.x, map.hub.z
	local pad = DetailConfig.WATER_PAD + 1
	local wet: { Wet } = {}
	local function place(point: WorldTypes.SheetPoint): Layout.Point
		return { x = ox + point.x, z = oz + point.z }
	end
	for _, stream in dressing.water do
		local points: { Layout.Point } = {}
		for _, point in stream.points do
			table.insert(points, place(point))
		end
		table.insert(wet, { points = points, half = stream.width / 2 + pad })
	end
	local function round(at: Layout.Point, radius: number)
		table.insert(wet, { points = { at, at }, half = radius + pad })
	end
	for _, pool in dressing.pools do
		round(place(pool.at), pool.radius)
	end
	local pond = dressing.pond
	if pond then
		round(place(pond.at), pond.radius + 2)
	end
	local rects: { Rect } = {}
	local flats: { WorldTypes.DressFlat } = dressing.flats or {}
	for _, flat in flats do
		if flat.water then
			local a, b = place(flat.from), place(flat.to)
			table.insert(rects, {
				x0 = math.min(a.x, b.x) - pad,
				z0 = math.min(a.z, b.z) - pad,
				x1 = math.max(a.x, b.x) + pad,
				z1 = math.max(a.z, b.z) + pad,
			})
		end
	end
	return wet, rects
end

-- The patches of a biome's lawns and verges: large, soft and slightly off the ground's own colour.
-- They stay on level ground, inside the town square or inside a corridor's edges, off water, off
-- the plaza and clear of every tier's foot and every stair, ramp or ledge. A sheet with no
-- `blotches` has none.
function GroundTone.blotches(
	biome: WorldTypes.Biome,
	map: Layout.Map,
	dressing: WorldTypes.DressingSheet,
	ground: Ground.Ground
): { Blotch }
	local sheet = dressing.blotches
	if sheet == nil then
		return {}
	end
	local trace = EdgeTrace.new(biome, map, dressing, ground)
	local wet, rects = wetThings(map, dressing)
	local rng = Rng.new(DetailConfig.SEED + biome.number * 211 + 31)
	local plaza = dressing.plaza
	local plazaX, plazaZ = map.hub.x + plaza.at.x, map.hub.z + plaza.at.z
	local blotches: { Blotch } = {}

	-- True where one point can carry a patch's edge: dry, level and in the zone.
	local function good(x: number, z: number, inTown: boolean): boolean
		for _, thing in wet do
			local _, off = EdgeTrace.nearest(thing.points, x, z)
			if off < thing.half then
				return false
			end
		end
		for _, rect in rects do
			if x >= rect.x0 and x <= rect.x1 and z >= rect.z0 and z <= rect.z1 then
				return false
			end
		end
		if dist(x, z, plazaX, plazaZ) < plaza.rim / 2 + 2 then
			return false
		end
		if
			Ground.atFoot(ground, x, z, DetailConfig.TIER_FOOT_PAD)
			or Ground.linkAt(ground, x, z, DetailConfig.LINK_PAD) ~= nil
			or Ground.ledgeAt(ground, x, z, DetailConfig.TIER_FOOT_PAD) ~= nil
		then
			return false
		end
		if inTown then
			return EdgeTrace.inTown(map, x, z, -DetailConfig.BLOTCH_TOWN_EDGE)
		end
		return EdgeTrace.insideAny(trace, x, z, DetailConfig.BLOTCH_PAD)
	end

	-- A patch at a spot if its middle and the four ends of its axes all pass, on one level.
	local function try(x: number, z: number, inTown: boolean): boolean
		local long = sheet.size[1] + (sheet.size[2] - sheet.size[1]) * Rng.next(rng)
		local short = DetailConfig.BLOTCH_SHORT
		local across = long * (short[1] + (short[2] - short[1]) * Rng.next(rng))
		local yaw = Rng.next(rng) * math.pi
		local level = Ground.heightAt(ground, x, z)
		local ca, sa = math.cos(yaw), math.sin(yaw)
		local reachLong, reachShort = long / 2 * 0.9, across / 2 * 0.9
		local checks = {
			{ 0, 0 },
			{ reachLong * ca, reachLong * sa },
			{ -reachLong * ca, -reachLong * sa },
			{ -reachShort * sa, reachShort * ca },
			{ reachShort * sa, -reachShort * ca },
		}
		for _, offset in checks do
			local px, pz = x + offset[1], z + offset[2]
			if
				not good(px, pz, inTown)
				or math.abs(Ground.heightAt(ground, px, pz) - level) > 0.05
			then
				return false
			end
		end
		table.insert(blotches, {
			x = x,
			z = z,
			w = long,
			d = across,
			yaw = yaw,
			colour = Rng.pick(rng, sheet.colours),
		})
		return true
	end

	local half = map.hub.size / 2 - DetailConfig.BLOTCH_TOWN_EDGE
	for _ = 1, sheet.town do
		for _ = 1, DetailConfig.BLOTCH_TRIES do
			local x = map.hub.x + (Rng.next(rng) * 2 - 1) * half
			local z = map.hub.z + (Rng.next(rng) * 2 - 1) * half
			if #blotches < sheet.budget and try(x, z, true) then
				break
			end
		end
	end
	for _, corridor in trace.corridors do
		local count = math.floor(sheet.verge * corridor.line.length / 400 + 0.5)
		for _ = 1, count do
			for _ = 1, DetailConfig.BLOTCH_TRIES do
				local along = Rng.next(rng) * corridor.line.length
				local reach = corridor.widthAt(along) - DetailConfig.BLOTCH_PAD
				local point = Layout.pointAt(corridor.line, along, (Rng.next(rng) * 2 - 1) * reach)
				if #blotches < sheet.budget and try(point.x, point.z, false) then
					break
				end
			end
		end
	end
	return blotches
end

return GroundTone
