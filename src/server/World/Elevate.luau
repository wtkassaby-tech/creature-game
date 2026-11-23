--!strict
-- Lifts a built biome onto its tiers (docs/plans/12_MAP_STRUCTURE.md section 4c, "heights
-- everywhere"). Every builder lays its parts on the flat ground at 0; once they are all down this
-- raises each one by the height of the ground under it, from the pure Ground module the tests
-- read too. So lanes, grass, people, prompts, signs, fences, water and the fill all stand on the
-- raised ground without each builder knowing about heights. Parts the tier and link builders
-- make stand at their own true heights and must be built after this runs.
-- A part that spans two heights (a long piece lying across a tier's edge) would be wrong; the
-- names of those are returned so the server can warn. The data keeps every lane, fence and patch
-- of grass clear of a tier's edge, so the list should be empty.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Ground = require(ReplicatedStorage.shared.Ground)

local Elevate = {}

local LONG = 10 -- studs: a part longer than this is checked at its two ends
local SPAN = 1.0 -- studs: ends that differ by more than this are a part spanning two heights
local MOST_NAMES = 20 -- how many spanning parts are named

-- True when a long part lies across two heights.
local function spans(ground: Ground.Ground, thing: BasePart, axis: Vector3, length: number): boolean
	-- Something standing up (a tree, a bush, a house) stands on the height under its middle;
	-- only a piece lying along the ground (a lane, a rail, a hedge run) can lie across an edge.
	-- Big tree crowns hanging over a terrace's lip were all named here before (Studio, 23 Nov).
	if thing.Size.Y > math.max(thing.Size.X, thing.Size.Z) * 0.6 and thing.Size.Y > 4 then
		return false
	end
	if length <= LONG or math.abs(axis.Y) >= 0.5 then
		return false
	end
	local position = thing.Position
	local a = position + axis * length / 2
	local b = position - axis * length / 2
	return math.abs(Ground.heightAt(ground, a.X, a.Z) - Ground.heightAt(ground, b.X, b.Z)) > SPAN
end

-- Raises every part under `parent` (leaving out those under `skip`) by the ground's height, and
-- returns how many parts were raised and the names of those that span two heights.
function Elevate.apply(
	parent: Instance,
	ground: Ground.Ground,
	skip: { Instance }
): (number, { string })
	local lifted = 0
	local across: { string } = {}
	if Ground.isFlat(ground) then
		return 0, across
	end
	for _, thing in parent:GetDescendants() do
		if not thing:IsA("BasePart") or thing.Name == "Ground" then
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
		local frame = thing.CFrame
		if
			#across < MOST_NAMES
			and (
				spans(ground, thing, frame.RightVector, thing.Size.X)
				or spans(ground, thing, frame.LookVector, thing.Size.Z)
			)
		then
			table.insert(across, thing.Name)
		end
		local height = Ground.heightAt(ground, position.X, position.Z)
		if math.abs(height) >= 0.001 then
			thing.CFrame = frame + Vector3.yAxis * height
			lifted += 1
		end
	end
	return lifted, across
end

return Elevate
