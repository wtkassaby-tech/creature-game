--!strict
-- Builds the small ground detail of a designed biome from DetailPlan (src/shared): the scatter of
-- flowers, pebbles, shells and tufts on the lawns and verges, and the paving pattern on each
-- plaza. Everything is low and flat and costs next to nothing: no collision, no queries, no
-- shadows, a few dozen studs of clay at most. Runs before Elevate, so it lifts with the rest.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DetailConfig = require(ReplicatedStorage.config.DetailConfig)
local DetailPlan = require(ReplicatedStorage.shared.DetailPlan)
local Ground = require(ReplicatedStorage.shared.Ground)
local Layout = require(ReplicatedStorage.shared.Layout)
local WorldTypes = require(ReplicatedStorage.shared.WorldTypes)

local Props = require(script.Parent.Props)

local Detail = {}

local function colourOf(values: { number }): Color3
	return Props.rgb(values[1], values[2], values[3])
end

-- Makes a part of the detail inert: it is only to be looked at.
local function inert(part: BasePart)
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
end

local function folderIn(parent: Instance, name: string): Folder
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent
	return folder
end

-- One scatter item: a small painted model, or a cluster of clay lumps.
local function stand(folder: Folder, item: DetailPlan.Item)
	local foot = Vector3.new(item.x, DetailConfig.FOOT, item.z)
	local colour = colourOf(item.colour)
	local pick = Random.new(item.seed)
	if item.shape == "Model" then
		local model = if item.model then Props.model(item.model) else nil
		if model then
			local facing = Vector3.new(math.sin(item.yaw), 0, -math.cos(item.yaw))
			inert(Props.stand(folder, model, foot, item.size, facing))
		else
			-- A stand-in lump when the painted model will not load.
			inert(
				Props.lump(
					folder,
					Vector3.new(item.size, item.size * 0.7, item.size),
					foot + Vector3.yAxis * item.size * 0.35,
					colour
				)
			)
		end
		return
	end
	for _ = 1, item.count do
		local spread = if item.count > 1 then 1.3 else 0
		local around = foot
			+ Vector3.new(pick:NextNumber(-spread, spread), 0, pick:NextNumber(-spread, spread))
		local size = item.size * pick:NextNumber(0.8, 1.2)
		local lump: Part
		if item.shape == "Blooms" then
			lump = Props.lump(
				folder,
				Vector3.one * size,
				around + Vector3.yAxis * (size * 0.5 + 0.3),
				colour
			)
		elseif item.shape == "Pebbles" then
			lump = Props.lump(
				folder,
				Vector3.new(size, size * 0.55, size * pick:NextNumber(0.7, 1)),
				around + Vector3.yAxis * size * 0.2,
				colour
			)
			lump.CFrame = CFrame.new(lump.Position)
				* CFrame.Angles(0, pick:NextNumber(0, math.pi * 2), 0)
		else
			lump = Props.lump(
				folder,
				Vector3.new(size, size * 0.3, size * 0.8),
				around + Vector3.yAxis * size * 0.1,
				colour
			)
			lump.CFrame = CFrame.new(lump.Position)
				* CFrame.Angles(0, pick:NextNumber(0, math.pi * 2), 0)
		end
		inert(lump)
	end
end

-- Scatters a biome's lawns and verges. Returns how many parts it made.
function Detail.scatter(
	parent: Instance,
	biome: WorldTypes.Biome,
	map: Layout.Map,
	dressing: WorldTypes.DressingSheet,
	ground: Ground.Ground
): number
	local plan = DetailPlan.scatter(biome, map, dressing, ground)
	local folder = folderIn(parent, "Scatter")
	for _, item in plan.items do
		stand(folder, item)
	end
	return plan.parts
end

-- Lays the plaza's paving pattern, flower beds and centre motif on its flat top.
function Detail.plaza(
	parent: Instance,
	biome: WorldTypes.Biome,
	map: Layout.Map,
	dressing: WorldTypes.DressingSheet,
	ground: Ground.Ground
): number
	local folder = folderIn(parent, "PlazaDetail")
	local top = DetailConfig.PLAZA_TOP
	local discs = 0
	local pieces = DetailPlan.plaza(biome, map, dressing, ground)
	for _, piece in pieces do
		local colour = colourOf(piece.colour)
		if piece.kind == "Disc" then
			discs += 1
			local disc = Props.disc(
				folder,
				Vector3.new(piece.x, 0, piece.z),
				piece.w,
				0.1,
				top + 0.02 * discs,
				colour
			)
			inert(disc)
		elseif piece.kind == "Stone" then
			local stone = Props.part(
				folder,
				Vector3.new(piece.w, DetailConfig.STONE_THICK, piece.d),
				CFrame.new(piece.x, top + 0.07, piece.z) * CFrame.Angles(0, piece.yaw, 0),
				colour
			)
			inert(stone)
		elseif piece.kind == "Bed" then
			inert(
				Props.lump(
					folder,
					Vector3.new(piece.w, 1.2, piece.w),
					Vector3.new(piece.x, top + 0.45, piece.z),
					colour
				)
			)
		else
			inert(
				Props.lump(
					folder,
					Vector3.one * piece.w,
					Vector3.new(piece.x, top + 0.95, piece.z),
					colour
				)
			)
		end
	end
	return #pieces
end

return Detail
