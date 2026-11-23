--!strict
-- Water that blocks the way (docs/plans/12_MAP_STRUCTURE.md section 3, principle 11, and section
-- 10 step 1). Enclosure.water decides where: streams, pools, the pond and the open sea are solid
-- up to WATER_BARRIER_TALL, a wall nothing is drawn on, except where a lane, stones or a bridge
-- crosses them. This makes the unseen parts. Never queried, so the camera and the battle scene
-- ignore them; a character is stopped by them exactly as by any other wall.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enclosure = require(ReplicatedStorage.shared.Enclosure)
local WorldConfig = require(ReplicatedStorage.config.WorldConfig)

local Fences = require(script.Parent.Fences)
local Props = require(script.Parent.Props)
local Shapes = require(script.Parent.Shapes)

local Barriers = {}

local UNSEEN = Props.rgb(86, 150, 200)

-- How many parts a build made.
export type Counts = { runs: number, discs: number, tiles: number }

local function hide(part: BasePart)
	part.Name = "WaterBarrier"
	part.Transparency = 1
	part.CanCollide = true
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
end

function Barriers.build(parent: Instance, plan: Enclosure.WaterPlan): Counts
	local folder = Instance.new("Folder")
	folder.Name = "Barriers"
	folder.Parent = parent
	local tall = WorldConfig.WATER_BARRIER_TALL
	local counts: Counts = { runs = 0, discs = 0, tiles = 0 }
	for _, run in plan.runs do
		local points: { Vector3 } = {}
		for _, point in run.points do
			table.insert(points, Vector3.new(point.x, 0, point.z))
		end
		for _, piece in Fences.pieces(Props.resample(points, 1)) do
			local made = Fences.block(folder, piece[1], piece[2], run.thick, tall)
			if made then
				hide(made)
				counts.runs += 1
			end
		end
	end
	for _, pool in plan.discs do
		local made =
			Shapes.cylinder(folder, Vector3.new(pool.x, 0, pool.z), pool.r * 2, tall, UNSEEN)
		hide(made)
		counts.discs += 1
	end
	for _, tile in plan.tiles do
		local made = Props.part(
			folder,
			Vector3.new(tile.x1 - tile.x0, tall, tile.z1 - tile.z0),
			CFrame.new((tile.x0 + tile.x1) / 2, tall / 2, (tile.z0 + tile.z1) / 2),
			UNSEEN
		)
		hide(made)
		counts.tiles += 1
	end
	return counts
end

return Barriers
