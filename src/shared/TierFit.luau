--!strict
-- How a built part is raised onto its tiers (docs/plans/12_MAP_STRUCTURE.md section 4c), as pure
-- numbers. Every builder lays its parts on the flat ground at 0 and Elevate lifts each by the
-- height under its middle. That is right for a part that stands on one height and wrong for a long
-- one lying across a tier's edge: half of it floats over the lower ground or sinks into the
-- cliff. This says what to do with such a part, by what it is:
--   * Strip  (a lane, a street, a road: thin, lying flat): cut where it crosses an edge, each
--     piece lifted to its own height.
--   * Disc   (a joint disc, a patch of ground: thin, round): trimmed until it fits one height.
--   * Wall   (an unseen core or barrier that blocks the way): sat on the lowest ground under it and
--     stretched up to still reach its full top on the highest.
--   * Filler (trees, dunes, cliff blocks past the edges: looks only): slid the shortest way onto
--     ground of one height, or sunk so it never floats and its high end is buried in the tier.
-- The Roblox side (Elevate.luau) reads each part into a Rect, asks for the Fit and applies it.
-- tests/tierfit.test.luau checks the fits and counts the parts of every biome that lie across an
-- edge before and after. No Roblox services.

local Ground = require("./Ground")
local WorldConfig = require("../config/WorldConfig")

local TierFit = {}

-- A flat rectangle: its centre, the unit direction of its long axis (`ux, uz`), and its half
-- sizes along that axis and across it. A disc is a square of half its radius.
export type Rect = {
	x: number,
	z: number,
	ux: number,
	uz: number,
	half: number,
	side: number,
}
export type Kind = "Strip" | "Disc" | "Wall" | "Filler"
-- One piece of a cut strip: offsets from the strip's centre along its long axis, its height, and
-- how far it reaches to each side of its middle (less than the strip's own half width where the
-- ground beside it is at another height).
export type Piece = { from: number, to: number, height: number, left: number, right: number }
-- What to do with a part: lift it by `lift` after sliding it by (dx, dz), make a wall `stretch` taller,
-- trim a disc to `radius`, or replace a strip by `pieces`.
export type Fit = {
	lift: number,
	dx: number,
	dz: number,
	stretch: number,
	radius: number?,
	pieces: { Piece }?,
}

-- The ground height at (a, b): `a` along the rectangle's axis from its centre, `b` across it.
local function heightAt(ground: Ground.Ground, rect: Rect, a: number, b: number): number
	return Ground.heightAt(
		ground,
		rect.x + rect.ux * a - rect.uz * b,
		rect.z + rect.uz * a + rect.ux * b
	)
end

local function moved(rect: Rect, dx: number, dz: number): Rect
	return {
		x = rect.x + dx,
		z = rect.z + dz,
		ux = rect.ux,
		uz = rect.uz,
		half = rect.half,
		side = rect.side,
	}
end

-- The height under a rectangle's centre.
function TierFit.middle(ground: Ground.Ground, rect: Rect): number
	return heightAt(ground, rect, 0, 0)
end

-- True when a long rectangle's two ends (along its long axis) stand at different heights.
function TierFit.spans(ground: Ground.Ground, rect: Rect): boolean
	if rect.half * 2 <= WorldConfig.TIER_FIT_LONG then
		return false
	end
	local a = heightAt(ground, rect, rect.half, 0)
	local b = heightAt(ground, rect, -rect.half, 0)
	return math.abs(a - b) > WorldConfig.TIER_FIT_SPAN
end

-- True when a long rectangle lies across two heights along either of its two axes: the test that
-- named the parts lying across an edge.
function TierFit.lies(ground: Ground.Ground, rect: Rect): boolean
	local across: Rect =
		{ x = rect.x, z = rect.z, ux = -rect.uz, uz = rect.ux, half = rect.side, side = rect.half }
	return TierFit.spans(ground, rect) or TierFit.spans(ground, across)
end

-- The lowest and highest ground under a rectangle, read on a grid.
function TierFit.range(ground: Ground.Ground, rect: Rect, step: number?): (number, number)
	local gap = step or WorldConfig.TIER_FIT_STEP
	local along = math.clamp(math.ceil(rect.half * 2 / gap), 1, 40)
	local across = math.clamp(math.ceil(rect.side * 2 / gap), 1, 40)
	local low, high = math.huge, -math.huge
	for i = 0, along do
		local a = -rect.half + rect.half * 2 * i / along
		for j = 0, across do
			local b = -rect.side + rect.side * 2 * j / across
			local height = heightAt(ground, rect, a, b)
			low, high = math.min(low, height), math.max(high, height)
		end
	end
	return low, high
end

-- A strip cut where the ground along its middle changes height by more than the tolerance, as
-- pieces from offset to offset each at its own height. Nil when it would take more than
-- TIER_FIT_MAX_PIECES (a strip lying up a slope is left whole).
function TierFit.cut(ground: Ground.Ground, rect: Rect): { Piece }?
	local count = math.max(1, math.ceil(rect.half * 2 / WorldConfig.TIER_FIT_CUT_STEP))
	local gap = rect.half * 2 / count
	local pieces: { Piece } = {}
	local startHeight = heightAt(ground, rect, -rect.half, 0)
	local from = -rect.half
	for i = 1, count do
		local a = -rect.half + gap * i
		local height = heightAt(ground, rect, a, 0)
		if math.abs(height - startHeight) > WorldConfig.TIER_FIT_TOLERANCE then
			-- The change is somewhere between the last sample and this one: found by halving.
			local near, far = a - gap, a
			for _ = 1, 8 do
				local middle = (near + far) / 2
				if
					math.abs(heightAt(ground, rect, middle, 0) - startHeight)
					> WorldConfig.TIER_FIT_TOLERANCE
				then
					far = middle
				else
					near = middle
				end
			end
			local cut = (near + far) / 2
			table.insert(pieces, {
				from = from,
				to = cut,
				height = startHeight,
				left = -rect.side,
				right = rect.side,
			})
			from, startHeight = cut, height
		end
	end
	table.insert(pieces, {
		from = from,
		to = rect.half,
		height = startHeight,
		left = -rect.side,
		right = rect.side,
	})
	if #pieces > WorldConfig.TIER_FIT_MAX_PIECES then
		return nil
	end
	return pieces
end

-- The rectangle one piece of a cut strip covers.
function TierFit.pieceRect(rect: Rect, piece: Piece): Rect
	local along = (piece.from + piece.to) / 2
	local across = (piece.left + piece.right) / 2
	return {
		x = rect.x + rect.ux * along - rect.uz * across,
		z = rect.z + rect.uz * along + rect.ux * across,
		ux = rect.ux,
		uz = rect.uz,
		half = (piece.to - piece.from) / 2,
		side = (piece.right - piece.left) / 2,
	}
end

-- Narrows a piece of strip to the ground beside its middle that is at its own height, so a street
-- along a tier's lip does not hang over it. Read every couple of studs along the piece.
local function trim(ground: Ground.Ground, rect: Rect, piece: Piece)
	local tol = WorldConfig.TIER_FIT_TOLERANCE
	local count = math.max(1, math.ceil((piece.to - piece.from) / 2))
	local left, right = -rect.side, rect.side
	for i = 0, count do
		local a = piece.from + (piece.to - piece.from) * i / count
		local reach = 0
		while
			reach < right
			and math.abs(heightAt(ground, rect, a, reach + 0.5) - piece.height) <= tol
		do
			reach += 0.5
		end
		right = math.min(right, reach)
		reach = 0
		while
			reach < -left
			and math.abs(heightAt(ground, rect, a, -reach - 0.5) - piece.height) <= tol
		do
			reach += 0.5
		end
		left = math.max(left, -reach)
	end
	if right - left < 1 then
		left, right = -0.5, 0.5
	end
	piece.left, piece.right = left, right
end

-- The shortest slide that puts a rectangle wholly on ground of the height under its centre, or
-- nil when nothing close by is flat enough.
function TierFit.settle(ground: Ground.Ground, rect: Rect): (number?, number?)
	local here = TierFit.middle(ground, rect)
	local reach = math.min(rect.half + rect.side, WorldConfig.TIER_FIT_MAX_SHIFT)
	for distance = 1, math.ceil(reach) do
		for k = 0, 15 do
			local angle = k / 16 * math.pi * 2
			local dx, dz = math.cos(angle) * distance, math.sin(angle) * distance
			local low, high = TierFit.range(ground, moved(rect, dx, dz), 3)
			local tol = WorldConfig.TIER_FIT_TOLERANCE
			if math.abs(low - here) <= tol and math.abs(high - here) <= tol then
				return dx, dz
			end
		end
	end
	return nil
end

-- The largest radius, at most `radius`, a disc at (x, z) can have and stand on one height.
function TierFit.fitRadius(ground: Ground.Ground, x: number, z: number, radius: number): number
	for r = math.floor(radius), WorldConfig.TIER_FIT_MIN_RADIUS + 1, -1 do
		local low, high =
			TierFit.range(ground, { x = x, z = z, ux = 1, uz = 0, half = r, side = r })
		if high - low <= WorldConfig.TIER_FIT_SPAN then
			return r
		end
	end
	return WorldConfig.TIER_FIT_MIN_RADIUS
end

-- What to do with a part of this kind standing here.
function TierFit.fit(ground: Ground.Ground, rect: Rect, kind: Kind): Fit
	local mid = TierFit.middle(ground, rect)
	local plain: Fit = { lift = mid, dx = 0, dz = 0, stretch = 0 }
	local low, high = TierFit.range(ground, rect)
	if high - low <= WorldConfig.TIER_FIT_SPAN then
		return plain
	end
	if kind == "Wall" then
		-- On the lowest ground, tall enough to reach the full height on the highest.
		return { lift = low, dx = 0, dz = 0, stretch = high - low }
	end
	if kind == "Strip" then
		local pieces = TierFit.cut(ground, rect)
		if pieces then
			for _, piece in pieces do
				local sub = TierFit.pieceRect(rect, piece)
				local pieceLow = TierFit.range(ground, sub)
				if piece.height - pieceLow > WorldConfig.TIER_FIT_SPAN then
					trim(ground, rect, piece)
				end
			end
			return { lift = mid, dx = 0, dz = 0, stretch = 0, pieces = pieces }
		end
		-- Up a slope, too many cuts: left whole, not floating.
		return {
			lift = if mid - low > WorldConfig.TIER_FIT_SPAN then low else mid,
			dx = 0,
			dz = 0,
			stretch = 0,
		}
	end
	-- A centre on the low ground only buries the part's high end in the tier: nothing floats.
	if mid - low <= WorldConfig.TIER_FIT_SPAN then
		return plain
	end
	if kind == "Disc" then
		local radius = TierFit.fitRadius(ground, rect.x, rect.z, rect.half)
		return { lift = mid, dx = 0, dz = 0, stretch = 0, radius = radius }
	end
	local dx, dz = TierFit.settle(ground, rect)
	if dx and dz then
		return {
			lift = TierFit.middle(ground, moved(rect, dx, dz)),
			dx = dx,
			dz = dz,
			stretch = 0,
		}
	end
	return { lift = low, dx = 0, dz = 0, stretch = 0 }
end

-- True when the part, fitted, still floats: some ground under it more than TIER_FIT_SPAN below its
-- underside. A part lying across an edge that is cut, trimmed, slid, sunk or stretched does not.
function TierFit.floats(ground: Ground.Ground, rect: Rect, kind: Kind, fit: Fit): boolean
	local limit = WorldConfig.TIER_FIT_SPAN
	local pieces = fit.pieces
	if pieces then
		for _, piece in pieces do
			-- A hair in from each end: the cut is found to a few hundredths of a stud.
			local inset = math.min(WorldConfig.TIER_FIT_CUT_STEP / 4, (piece.to - piece.from) / 4)
			local sub = TierFit.pieceRect(rect, piece)
			sub.half -= inset
			local low = TierFit.range(ground, sub)
			if piece.height - low > limit and kind ~= "Wall" then
				return true
			end
		end
		return false
	end
	local fitted = moved(rect, fit.dx, fit.dz)
	local radius = fit.radius
	if radius then
		fitted.half, fitted.side = radius, radius
	end
	local low = TierFit.range(ground, fitted)
	return fit.lift - low > limit
end

return TierFit
