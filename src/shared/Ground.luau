--!strict
-- The height of the ground (docs/plans/12_MAP_STRUCTURE.md sections 3 and 4a), pure and flat: no
-- Roblox services, so the builders, the reachability tests and the client read the same answer.
--   * Tiers are flat tops (a disc, a box or a strip) at a height, 10 studs apart: 0, 10, 20 ...
--     where no tier lies the ground is 0, and a later tier wins where two overlap.
--   * Stairs and ramps join a lower height to a higher one, both ways: along their line the height
--     eases from the tier under their `from` end to the tier under their `to` end.
--   * A ledge is a stretch of a tier's lip with no wall on it: you hop down, the face below is too
--     tall to climb back. It changes no height.
-- The server's own checks stay flat (x, z): heights are for the builders and the tests.

local Layout = require("./Layout")
local WorldTypes = require("./WorldTypes")

-- A world shape. A Disc is a Strip of no length; a Box runs from (ax, az) to (bx, bz).
export type Shape = {
	kind: "Disc" | "Box" | "Strip",
	ax: number,
	az: number,
	bx: number,
	bz: number,
	r: number,
}
export type Tier = { id: string, height: number, shape: Shape }
-- A link in the world. `ux, uz` is the unit direction from `from` to `to`; `h0` and `h1` are the
-- tier heights under the two ends (stairs and ramps ease between them).
export type Link = {
	id: string,
	kind: "Stairs" | "Ramp" | "Ledge",
	ax: number,
	az: number,
	bx: number,
	bz: number,
	width: number,
	length: number,
	ux: number,
	uz: number,
	h0: number,
	h1: number,
}
-- A point on a shape's outline with the unit normal pointing out of the shape.
export type Sample = { x: number, z: number, nx: number, nz: number }
-- A stretch of a tier's outline where the ground drops: a wall, or a ledge you can hop down.
export type EdgeRun = {
	kind: "Wall" | "Ledge",
	tier: string,
	points: { Layout.Point },
	normals: { Layout.Point }, -- out of the high ground, towards the low
	high: number,
	low: number,
}
export type Ground = {
	tiers: { Tier },
	links: { Link },
	faces: { { x: number, z: number, high: number } }?, -- wall and ledge samples, found on first use
}

local Ground = {}

-- A drop at least this big is a wall (or a ledge); stairs and ramps change height more gently.
local DROP = 2.0
local FACE_STEP = 3 -- studs between samples on a tier's outline

-- A shape drawn on the sheet, moved into the world.
function Ground.shape(shape: WorldTypes.Shape, origin: Layout.Point): Shape
	if shape.kind == "Disc" then
		local x, z = origin.x + shape.at.x, origin.z + shape.at.z
		return { kind = "Disc", ax = x, az = z, bx = x, bz = z, r = shape.r }
	elseif shape.kind == "Box" then
		local x, z = origin.x + shape.at.x, origin.z + shape.at.z
		local halfX, halfZ = shape.size[1] / 2, shape.size[2] / 2
		return {
			kind = "Box",
			ax = x - halfX,
			az = z - halfZ,
			bx = x + halfX,
			bz = z + halfZ,
			r = 0,
		}
	end
	return {
		kind = "Strip",
		ax = origin.x + shape.from.x,
		az = origin.z + shape.from.z,
		bx = origin.x + shape.to.x,
		bz = origin.z + shape.to.z,
		r = shape.r,
	}
end

-- How far a point is outside a shape: negative inside it.
function Ground.distance(shape: Shape, x: number, z: number): number
	if shape.kind == "Box" then
		local dx = math.max(shape.ax - x, 0, x - shape.bx)
		local dz = math.max(shape.az - z, 0, z - shape.bz)
		if dx > 0 or dz > 0 then
			return math.sqrt(dx * dx + dz * dz)
		end
		return -math.min(x - shape.ax, shape.bx - x, z - shape.az, shape.bz - z)
	end
	local rx, rz = shape.bx - shape.ax, shape.bz - shape.az
	local length2 = rx * rx + rz * rz
	local t = 0
	if length2 > 1e-9 then
		t = math.clamp(((x - shape.ax) * rx + (z - shape.az) * rz) / length2, 0, 1)
	end
	local px, pz = shape.ax + rx * t - x, shape.az + rz * t - z
	return math.sqrt(px * px + pz * pz) - shape.r
end

-- Points round a shape's outline about every `step` studs, each with its outward normal.
function Ground.outline(shape: Shape, step: number): { Sample }
	local out: { Sample } = {}
	local function arc(cx: number, cz: number, r: number, from: number, to: number)
		local count = math.max(2, math.ceil(math.abs(to - from) * r / step))
		for k = 0, count - 1 do
			local angle = from + (to - from) * k / count
			local nx, nz = math.cos(angle), math.sin(angle)
			table.insert(out, { x = cx + nx * r, z = cz + nz * r, nx = nx, nz = nz })
		end
	end
	local function side(x0: number, z0: number, x1: number, z1: number, nx: number, nz: number)
		local length = math.sqrt((x1 - x0) ^ 2 + (z1 - z0) ^ 2)
		local count = math.max(1, math.ceil(length / step))
		for k = 0, count - 1 do
			local t = k / count
			table.insert(out, { x = x0 + (x1 - x0) * t, z = z0 + (z1 - z0) * t, nx = nx, nz = nz })
		end
	end
	if shape.kind == "Box" then
		side(shape.ax, shape.az, shape.bx, shape.az, 0, -1)
		side(shape.bx, shape.az, shape.bx, shape.bz, 1, 0)
		side(shape.bx, shape.bz, shape.ax, shape.bz, 0, 1)
		side(shape.ax, shape.bz, shape.ax, shape.az, -1, 0)
	elseif shape.kind == "Disc" or (shape.ax == shape.bx and shape.az == shape.bz) then
		arc(shape.ax, shape.az, shape.r, 0, math.pi * 2)
	else
		local rx, rz = shape.bx - shape.ax, shape.bz - shape.az
		local length = math.sqrt(rx * rx + rz * rz)
		local ux, uz = rx / length, rz / length
		local base = math.atan2(uz, ux)
		-- Round the far end, back along the +n side, round the near end, and out along the -n side.
		local nx, nz = -uz, ux
		local r = shape.r
		arc(shape.bx, shape.bz, r, base - math.pi / 2, base + math.pi / 2)
		side(shape.bx + nx * r, shape.bz + nz * r, shape.ax + nx * r, shape.az + nz * r, nx, nz)
		arc(shape.ax, shape.az, r, base + math.pi / 2, base + math.pi * 3 / 2)
		side(shape.ax - nx * r, shape.az - nz * r, shape.bx - nx * r, shape.bz - nz * r, -nx, -nz)
	end
	return out
end

local function link(sheet: WorldTypes.Link, tiers: { Tier }, origin: Layout.Point): Link
	local ax, az = origin.x + sheet.from.x, origin.z + sheet.from.z
	local bx, bz = origin.x + sheet.to.x, origin.z + sheet.to.z
	local length = math.max(math.sqrt((bx - ax) ^ 2 + (bz - az) ^ 2), 1e-6)
	local function under(x: number, z: number): number
		for index = #tiers, 1, -1 do
			if Ground.distance(tiers[index].shape, x, z) < 0 then
				return tiers[index].height
			end
		end
		return 0
	end
	return {
		id = sheet.id,
		kind = sheet.kind,
		ax = ax,
		az = az,
		bx = bx,
		bz = bz,
		width = sheet.width,
		length = length,
		ux = (bx - ax) / length,
		uz = (bz - az) / length,
		h0 = under(ax, az),
		h1 = under(bx, bz),
	}
end

-- The ground of a biome: its tiers and links drawn on the sheet, in the world. A sheet with none
-- (or no sheet) is flat at 0.
function Ground.new(sheet: WorldTypes.MapSheet?, origin: Layout.Point): Ground
	local tiers: { Tier } = {}
	local links: { Link } = {}
	if sheet then
		local drawnTiers: { WorldTypes.Tier } = if sheet.tiers then sheet.tiers else {}
		for _, drawn in drawnTiers do
			table.insert(
				tiers,
				{ id = drawn.id, height = drawn.height, shape = Ground.shape(drawn.shape, origin) }
			)
		end
		local drawnLinks: { WorldTypes.Link } = if sheet.links then sheet.links else {}
		for _, drawn in drawnLinks do
			table.insert(links, link(drawn, tiers, origin))
		end
	end
	return { tiers = tiers, links = links }
end

-- Where a point is along a link and how far to its side.
local function along(l: Link, x: number, z: number): (number, number)
	local dx, dz = x - l.ax, z - l.az
	return dx * l.ux + dz * l.uz, dx * l.uz - dz * l.ux
end

-- The height of the tier under a flat point, not counting stairs and ramps.
function Ground.tierHeight(g: Ground, x: number, z: number): number
	for index = #g.tiers, 1, -1 do
		if Ground.distance(g.tiers[index].shape, x, z) < 0 then
			return g.tiers[index].height
		end
	end
	return 0
end

-- The tier under a flat point (the one drawn last where two overlap), if any.
function Ground.tierAt(g: Ground, x: number, z: number): Tier?
	for index = #g.tiers, 1, -1 do
		if Ground.distance(g.tiers[index].shape, x, z) < 0 then
			return g.tiers[index]
		end
	end
	return nil
end

-- The stairs or ramp a flat point is on (within `pad` studs of it), if any.
function Ground.linkAt(g: Ground, x: number, z: number, pad: number?): Link?
	local extra = pad or 0
	for _, l in g.links do
		if l.kind ~= "Ledge" then
			local t, side = along(l, x, z)
			if t >= -extra and t <= l.length + extra and math.abs(side) <= l.width / 2 + extra then
				return l
			end
		end
	end
	return nil
end

-- The ledge a flat point is on (within `pad` studs of its stretch of lip), if any.
function Ground.ledgeAt(g: Ground, x: number, z: number, pad: number?): Link?
	local extra = pad or 0
	for _, l in g.links do
		if l.kind == "Ledge" then
			local t, side = along(l, x, z)
			if t >= -extra and t <= l.length + extra and math.abs(side) <= l.width / 2 + extra then
				return l
			end
		end
	end
	return nil
end

-- The height of the ground at a flat point: stairs and ramps ease between their two tiers, else
-- the tier under the point, else 0.
function Ground.heightAt(g: Ground, x: number, z: number): number
	for _, l in g.links do
		if l.kind ~= "Ledge" then
			local t, side = along(l, x, z)
			if t >= 0 and t <= l.length and math.abs(side) <= l.width / 2 then
				return l.h0 + (l.h1 - l.h0) * t / l.length
			end
		end
	end
	return Ground.tierHeight(g, x, z)
end

-- True when the ground of a tier is higher than 0 anywhere (the biome has levels).
function Ground.isFlat(g: Ground): boolean
	return #g.tiers == 0
end

-- Every stretch of tier outline where the ground drops, as runs of points, each a wall or a
-- ledge. Stairs and ramps are not edges: their notch is smooth. Sampled every `step` studs.
function Ground.edges(g: Ground, step: number?): { EdgeRun }
	local spacing = step or FACE_STEP
	local runs: { EdgeRun } = {}
	for _, tier in g.tiers do
		local current: EdgeRun? = nil
		for _, s in Ground.outline(tier.shape, spacing) do
			local inside = Ground.heightAt(g, s.x - s.nx * 0.75, s.z - s.nz * 0.75)
			local outside = Ground.heightAt(g, s.x + s.nx * 0.75, s.z + s.nz * 0.75)
			local kind: ("Wall" | "Ledge")? = nil
			if inside - outside > DROP then
				kind = if Ground.ledgeAt(g, s.x, s.z, 0.5) then "Ledge" else "Wall"
			end
			if kind == nil then
				current = nil
			else
				local open = current
				if open == nil or open.kind ~= kind then
					open = {
						kind = kind,
						tier = tier.id,
						points = {},
						normals = {},
						high = inside,
						low = outside,
					}
					table.insert(runs, open :: EdgeRun)
				end
				local run = open :: EdgeRun
				table.insert(run.points, { x = s.x, z = s.z })
				table.insert(run.normals, { x = s.nx, z = s.nz })
				run.high = math.max(run.high, inside)
				run.low = math.min(run.low, outside)
				current = run
			end
		end
	end
	return runs
end

-- True when a flat point stands on low ground right at the foot of a tier's wall or ledge (within
-- `pad` studs of its lip): the face itself is that edge's wall, so nothing else needs to be built
-- there.
function Ground.atFoot(g: Ground, x: number, z: number, pad: number): boolean
	local faces = g.faces
	if faces == nil then
		faces = {}
		for _, run in Ground.edges(g, 2) do
			for _, point in run.points do
				table.insert(faces :: any, { x = point.x, z = point.z, high = run.high })
			end
		end
		g.faces = faces
	end
	local here = Ground.heightAt(g, x, z)
	for _, face in faces :: { { x: number, z: number, high: number } } do
		if
			here < face.high - DROP
			and math.abs(face.x - x) <= pad
			and math.abs(face.z - z) <= pad
		then
			if (face.x - x) ^ 2 + (face.z - z) ^ 2 <= pad * pad then
				return true
			end
		end
	end
	return false
end

return Ground
