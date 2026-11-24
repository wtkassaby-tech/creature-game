--!strict
-- Pure answers to "where in the world is this point": how far it is from a shape, whether a biome's
-- region holds it, and how much of each climate zone it is in (docs/plans/13_WORLD_DESIGN.md
-- sections 5, 9b and 11b). No Roblox calls: the server uses `contains` for which biome a position
-- is in, the client uses `weights` for the light and sound blend, and tests walk the whole map.

local WorldTypes = require("./WorldTypes")

export type Point = WorldTypes.WorldPoint
export type Weights = { [string]: number }

local Regions = {}

local function segmentDistance(p: Point, a: Point, b: Point): number
	local dx, dz = b.x - a.x, b.z - a.z
	local lengthSquared = dx * dx + dz * dz
	local t = 0
	if lengthSquared > 0 then
		t = math.clamp(((p.x - a.x) * dx + (p.z - a.z) * dz) / lengthSquared, 0, 1)
	end
	local nx, nz = a.x + dx * t - p.x, a.z + dz * t - p.z
	return math.sqrt(nx * nx + nz * nz)
end

-- Studs from `p` to the edge of `shape`; 0 anywhere inside it.
function Regions.distance(shape: WorldTypes.Shape, p: Point): number
	if shape.kind == "Disc" then
		local dx, dz = p.x - shape.at.x, p.z - shape.at.z
		return math.max(math.sqrt(dx * dx + dz * dz) - shape.r, 0)
	elseif shape.kind == "Box" then
		local ox = math.max(math.abs(p.x - shape.at.x) - shape.size[1] / 2, 0)
		local oz = math.max(math.abs(p.z - shape.at.z) - shape.size[2] / 2, 0)
		return math.sqrt(ox * ox + oz * oz)
	else
		return math.max(segmentDistance(p, shape.from, shape.to) - shape.r, 0)
	end
end

function Regions.contains(shape: WorldTypes.Shape, p: Point): boolean
	return Regions.distance(shape, p) <= 0
end

-- 0 to 1 and flat at both ends.
function Regions.smoothstep(t: number): number
	local x = math.clamp(t, 0, 1)
	return x * x * (3 - 2 * x)
end

-- One zone's own weight at `p`: 1 inside its shape, easing to 0 over `band` studs outside it.
function Regions.zoneWeight(zone: WorldTypes.ClimateZone, p: Point): number
	local d = Regions.distance(zone.shape, p)
	if d <= 0 then
		return 1
	end
	if zone.band <= 0 then
		return 0
	end
	return 1 - Regions.smoothstep(d / zone.band)
end

-- Every zone's weight at `p`, by zone id, summing to 1. A zone of higher priority scales every
-- lower one down by (1 - its weight). Where no zone reaches `p`, the nearest zone takes it all.
function Regions.weights(zones: { WorldTypes.ClimateZone }, p: Point): Weights
	local raw: { number } = {}
	for index, zone in zones do
		raw[index] = Regions.zoneWeight(zone, p)
	end
	local scaled: { number } = {}
	local total = 0
	for index, zone in zones do
		local w = raw[index]
		local priority = zone.priority or 0
		for other, higher in zones do
			if (higher.priority or 0) > priority then
				w *= 1 - raw[other]
			end
		end
		scaled[index] = w
		total += w
	end
	local result: Weights = {}
	if total <= 1e-9 then
		local best, bestDistance = nil, math.huge
		for _, zone in zones do
			local d = Regions.distance(zone.shape, p)
			if d < bestDistance then
				best, bestDistance = zone, d
			end
		end
		if best then
			result[best.id] = 1
		end
		return result
	end
	for index, zone in zones do
		if scaled[index] > 0 then
			result[zone.id] = scaled[index] / total
		end
	end
	return result
end

-- The same weights summed by preset id (two zones may share a preset).
function Regions.presetWeights(zones: { WorldTypes.ClimateZone }, p: Point): Weights
	local byZone = Regions.weights(zones, p)
	local presetOf: { [string]: string } = {}
	for _, zone in zones do
		presetOf[zone.id] = zone.preset
	end
	local result: Weights = {}
	for id, w in byZone do
		local preset = presetOf[id]
		result[preset] = (result[preset] or 0) + w
	end
	return result
end

-- The id with the largest weight (ties go to the first id alphabetically, so it is stable).
function Regions.dominant(weights: Weights): string?
	local best: string? = nil
	local bestWeight = -1
	for id, w in weights do
		local current = best
		if w > bestWeight or (w == bestWeight and current ~= nil and id < current) then
			best, bestWeight = id, w
		end
	end
	return best
end

-- The point `along` studs from the start of a passage's walk (clamped to its ends).
function Regions.pointAlong(points: { Point }, along: number): Point
	local remaining = math.max(along, 0)
	for index = 1, #points - 1 do
		local a, b = points[index], points[index + 1]
		local length = math.sqrt((b.x - a.x) ^ 2 + (b.z - a.z) ^ 2)
		if remaining <= length and length > 0 then
			local t = remaining / length
			return { x = a.x + (b.x - a.x) * t, z = a.z + (b.z - a.z) * t }
		end
		remaining -= length
	end
	return points[#points]
end

-- The passage whose sky-swap point lies within its radius of `p`, or nil. Sky and music change only
-- while this is set, so the cut is hidden.
function Regions.swapNear(passages: { WorldTypes.Passage }, p: Point): WorldTypes.Passage?
	for _, passage in passages do
		local at = Regions.pointAlong(passage.points, passage.swapAt)
		local dx, dz = p.x - at.x, p.z - at.z
		if dx * dx + dz * dz <= passage.swapRadius * passage.swapRadius then
			return passage
		end
	end
	return nil
end

return Regions
