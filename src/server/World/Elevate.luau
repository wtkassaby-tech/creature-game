--!strict
-- Lifts a built biome onto its tiers (docs/plans/12_MAP_STRUCTURE.md section 4c, "heights
-- everywhere"). Every builder lays its parts on the flat ground at 0; once they are all down this
-- raises each one by the height of the ground under it, from the pure Ground module the tests
-- read too. So lanes, grass, people, prompts, signs, fences, water and the fill all stand on the
-- raised ground without each builder knowing about heights. Parts the tier and link builders
-- make stand at their own true heights and must be built after this runs.
-- A part that spans two heights (a long piece lying across a tier's edge) would be wrong if it
-- were only lifted, so it is fitted instead (the pure rules are in shared/TierFit.luau):
--   * a thin strip (a lane, a street, the sealed road) is cut where it crosses the edge;
--   * a thin disc (a lane joint, a patch of ground) is trimmed until it fits one height;
--   * an unseen wall (a core, a water barrier) sits on the low ground and is stretched to reach
--     its full top on the high;
--   * looks-only filler (the woods, dunes and cliff blocks past the edges) is slid onto one height
--     or sunk, so it never floats and its high end is buried in the tier.
-- Ambience nodes (pollen and smoke emitters) are invisible markers with nothing to float: they are
-- left to the height at their middle. Anything the rules cannot fit is named so the server warns.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Ground = require(ReplicatedStorage.shared.Ground)
local TierFit = require(ReplicatedStorage.shared.TierFit)

local Elevate = {}

local MOST_NAMES = 20 -- how many parts left lying across two heights are named
local THIN = 1.5 -- studs: a part this thin (or less) lies on the ground

-- How many parts were fitted each way.
export type Fixes = {
	cut: number, -- strips cut at an edge
	trimmed: number, -- discs made smaller
	stretched: number, -- walls sat low and made taller
	slid: number, -- filler moved onto one height
	sunk: number, -- filler sunk so it does not float
	left: number, -- parts of invisible emitters and the like, lifted whole
}

-- How a part is read: the flat rectangle it covers, what kind of part it is, and which of its
-- sizes is its height.
type Reading = { rect: TierFit.Rect, kind: TierFit.Kind, tall: "X" | "Y" | nil, longX: boolean }

-- Reads a part into its footprint and kind; nil for a part with nothing to fit.
local function read(thing: BasePart): Reading?
	local frame = thing.CFrame
	local size = thing.Size
	local position = frame.Position
	if
		math.abs(frame.RightVector.Y) > 0.9
		and thing:IsA("Part")
		and thing.Shape == Enum.PartType.Cylinder
	then
		-- A cylinder standing on its end (a disc, a pool's barrier): its axis is the part's X.
		local radius = math.max(size.Y, size.Z) / 2
		local kind: TierFit.Kind = if size.X <= THIN
			then "Disc"
			elseif thing.CanCollide then "Wall"
			else "Filler"
		return {
			rect = { x = position.X, z = position.Z, ux = 1, uz = 0, half = radius, side = radius },
			kind = kind,
			tall = "X",
			longX = true,
		}
	end
	if math.abs(frame.UpVector.Y) > 0.9 then
		local longX = size.X >= size.Z
		local axis = if longX then frame.RightVector else -frame.LookVector
		local flatLength = math.sqrt(axis.X * axis.X + axis.Z * axis.Z)
		if flatLength < 0.5 then
			return nil
		end
		local kind: TierFit.Kind = if size.Y <= THIN
			then "Strip"
			elseif thing.CanCollide then "Wall"
			else "Filler"
		return {
			rect = {
				x = position.X,
				z = position.Z,
				ux = axis.X / flatLength,
				uz = axis.Z / flatLength,
				half = math.max(size.X, size.Z) / 2,
				side = math.min(size.X, size.Z) / 2,
			},
			kind = kind,
			tall = "Y",
			longX = longX,
		}
	end
	-- Tilted: only its footprint on the ground is known, so it is slid or sunk like filler.
	local r, u, l = frame.RightVector, frame.UpVector, frame.LookVector
	local ex = (math.abs(r.X) * size.X + math.abs(u.X) * size.Y + math.abs(l.X) * size.Z) / 2
	local ez = (math.abs(r.Z) * size.X + math.abs(u.Z) * size.Y + math.abs(l.Z) * size.Z) / 2
	return {
		rect = { x = position.X, z = position.Z, ux = 1, uz = 0, half = ex, side = ez },
		kind = "Filler",
		tall = nil,
		longX = true,
	}
end

-- True when a long part lies across two heights (the ends of either of its axes differ).
local function spans(ground: Ground.Ground, thing: BasePart, rect: TierFit.Rect): boolean
	-- Something standing up (a tree, a bush, a house) stands on the height under its middle;
	-- only a piece lying along the ground (a lane, a rail, a hedge run) can lie across an edge.
	-- Big tree crowns hanging over a terrace's lip were all named here before (Studio, 23 Nov).
	if thing.Size.Y > math.max(thing.Size.X, thing.Size.Z) * 0.6 and thing.Size.Y > 4 then
		return false
	end
	return TierFit.lies(ground, rect)
end

-- Applies a fit to a part, cutting a strip into clones. Returns how many parts it ended as.
local function apply(
	thing: BasePart,
	reading: Reading,
	fit: TierFit.Fit,
	height: number,
	fixes: Fixes
): number
	local frame = thing.CFrame
	local size = thing.Size
	local pieces = fit.pieces
	if pieces and thing:IsA("Part") then
		local parent = thing.Parent
		for index, piece in pieces do
			local made: BasePart = if index == 1 then thing else thing:Clone()
			local length = piece.to - piece.from + 0.02
			local centre = (piece.from + piece.to) / 2
			local across = (piece.left + piece.right) / 2
			local width = piece.right - piece.left
			if reading.longX then
				-- The strip's own side direction (rect's perpendicular) is the part's +Z here.
				made.Size = Vector3.new(length, size.Y, math.min(width, size.Z))
				made.CFrame = frame * CFrame.new(centre, 0, across) + Vector3.yAxis * piece.height
			else
				-- ... and the part's -X here.
				made.Size = Vector3.new(math.min(width, size.X), size.Y, length)
				made.CFrame = frame * CFrame.new(-across, 0, centre) + Vector3.yAxis * piece.height
			end
			made.Parent = parent
		end
		fixes.cut += 1
		return #pieces
	end
	local lift = Vector3.new(fit.dx, fit.lift, fit.dz)
	local radius = fit.radius
	if radius and radius * 2 < math.max(size.Y, size.Z) then
		thing.Size = Vector3.new(size.X, radius * 2, radius * 2)
		fixes.trimmed += 1
	elseif fit.stretch > 0 then
		-- Taller from the low ground up, so its top still stands at the high ground's height.
		if reading.tall == "X" then
			thing.Size = Vector3.new(size.X + fit.stretch, size.Y, size.Z)
		else
			thing.Size = Vector3.new(size.X, size.Y + fit.stretch, size.Z)
		end
		lift += Vector3.yAxis * fit.stretch / 2
		fixes.stretched += 1
	elseif fit.dx ~= 0 or fit.dz ~= 0 then
		fixes.slid += 1
	elseif fit.lift < height - 0.001 then
		fixes.sunk += 1
	end
	thing.CFrame = frame + lift
	return 1
end

-- Raises every part under `parent` (leaving out those under `skip`) by the ground's height, and
-- returns how many parts were raised, the names of those left lying across two heights, and how
-- the rest that did were fitted.
function Elevate.apply(
	parent: Instance,
	ground: Ground.Ground,
	skip: { Instance }
): (number, { string }, Fixes)
	local lifted = 0
	local across: { string } = {}
	local fixes: Fixes = { cut = 0, trimmed = 0, stretched = 0, slid = 0, sunk = 0, left = 0 }
	if Ground.isFlat(ground) then
		return 0, across, fixes
	end
	for _, thing in parent:GetDescendants() do
		-- The ground, and the sheet's flats (the sea, a sandbar, a mudflat), lie at the foot of
		-- every tier: lifted by the height at their middle they stuck out over a terrace's
		-- edge (Tide Flats, Studio, 23 November 2026). Left low, any part under a tier is
		-- simply hidden inside its block.
		if
			not thing:IsA("BasePart")
			or thing.Name == "Ground"
			or thing.Name == "Flat"
			or thing.Name == "WaterFlat"
		then
			continue
		end
		local inSkipped = false
		for _, folder in skip do
			if thing:IsDescendantOf(folder) then
				inSkipped = true
				break
			end
		end
		if inSkipped then
			continue
		end
		local position = thing.Position
		local height = Ground.heightAt(ground, position.X, position.Z)
		local reading = read(thing)
		if reading and spans(ground, thing, reading.rect) then
			if thing:FindFirstAncestor("Ambience") then
				-- An invisible emitter node: nothing of it can float.
				fixes.left += 1
			else
				local fit = TierFit.fit(ground, reading.rect, reading.kind)
				if TierFit.floats(ground, reading.rect, reading.kind, fit) then
					-- Not fitted: named, and lifted by its middle as before.
					if #across < MOST_NAMES then
						table.insert(across, thing.Name)
					end
				else
					lifted += apply(thing, reading, fit, height, fixes)
					continue
				end
			end
		end
		if math.abs(height) >= 0.001 then
			thing.CFrame = thing.CFrame + Vector3.yAxis * height
			lifted += 1
		end
	end
	return lifted, across, fixes
end

return Elevate
