--!strict
-- Greenery for a biome still on the generated layout (no map sheet): trees, bushes, rocks and
-- flowers dropped at random along both sides of every route and around the town, kept clear of
-- the paths. The same biome always gets the same scatter. A designed biome gets hedged
-- corridors instead (Corridors.luau). Split from Dressing.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Layout = require(ReplicatedStorage.shared.Layout)
local WorldTypes = require(ReplicatedStorage.shared.WorldTypes)

local Props = require(script.Parent.Props)

local Scatter = {}

local rgb = Props.rgb
local lump = Props.lump
local prop = Props.model
local stand = Props.stand

local BLOOMS: { Color3 } =
	{ rgb(250, 220, 90), rgb(240, 130, 150), rgb(250, 250, 250), rgb(170, 140, 240) }

local function tree(parent: Instance, at: Vector3, pick: Random)
	Props.tree(parent, at, if pick:NextNumber() < 0.7 then "Tree" else "Pine", 1, pick)
end

local function bush(parent: Instance, at: Vector3, pick: Random, leaf: Color3)
	local painted = prop("Bush")
	if painted then
		local turn = pick:NextNumber(0, math.pi * 2)
		local facing = Vector3.new(math.cos(turn), 0, math.sin(turn))
		stand(parent, painted, at, pick:NextNumber(3, 5.5), facing)
		return
	end
	local width = pick:NextNumber(3, 6)
	lump(parent, Vector3.new(width, width * 0.7, width), at + Vector3.yAxis * width * 0.3, leaf)
	if pick:NextNumber() < 0.5 then
		lump(
			parent,
			Vector3.one * 0.9,
			at + Vector3.new(0, width * 0.62, 0),
			BLOOMS[pick:NextInteger(1, #BLOOMS)]
		)
	end
end

local function rock(parent: Instance, at: Vector3, pick: Random, stone: Color3)
	local width = pick:NextNumber(2, 6)
	lump(
		parent,
		Vector3.new(width, width * 0.6, width * 0.8),
		at + Vector3.yAxis * width * 0.2,
		stone
	)
end

local function flowers(parent: Instance, at: Vector3, pick: Random)
	local colour = BLOOMS[pick:NextInteger(1, #BLOOMS)]
	for _ = 1, pick:NextInteger(3, 6) do
		local spot = at + Vector3.new(pick:NextNumber(-2.5, 2.5), 0.5, pick:NextNumber(-2.5, 2.5))
		lump(parent, Vector3.one * 0.8, spot, colour)
	end
end

-- What grows in a biome, by its type: the leaf colour and how much of the scatter is rock.
local function growth(biome: WorldTypes.Biome): (Color3, Color3, number)
	if biome.element == "Sand" then
		return rgb(150, 160, 90), rgb(196, 150, 110), 0.6
	elseif biome.element == "Water" then
		return rgb(90, 170, 130), rgb(150, 160, 170), 0.4
	elseif biome.element == "Toxic" then
		return rgb(100, 130, 90), rgb(110, 110, 120), 0.3
	end
	return rgb(84, 160, 78), rgb(150, 150, 150), 0.12
end

-- Trees, bushes, rocks and flowers along both sides of every route and around the town, kept
-- clear of the paths. The same biome always gets the same scatter. Only for a biome with no
-- map sheet: a designed biome gets corridors instead (Corridors.edges).
function Scatter.build(parent: Folder, biome: WorldTypes.Biome, map: Layout.Map, pathWidth: number)
	local pick = Random.new(biome.number * 7919)
	local leaf, stone, rocky = growth(biome)
	local folder = Instance.new("Folder")
	folder.Name = "Dressing"
	folder.Parent = parent

	local function grow(at: Vector3)
		local roll = pick:NextNumber()
		if roll < rocky then
			rock(folder, at, pick, stone)
		elseif roll < rocky + (1 - rocky) * 0.5 then
			tree(folder, at, pick)
		elseif roll < rocky + (1 - rocky) * 0.8 then
			bush(folder, at, pick, leaf)
		else
			flowers(folder, at, pick)
		end
	end

	for _, route in biome.routes do
		local line = map.routes[route.id]
		if line then
			local along = 70 -- start clear of the town
			while along < route.length do
				for _, side in { -1, 1 } do
					local out = pathWidth / 2 + pick:NextNumber(10, 70)
					local point = Layout.pointAt(line, along, side * out)
					grow(Vector3.new(point.x, 0, point.z))
				end
				along += pick:NextNumber(16, 30)
			end
		end
	end
	-- A ring of growth round the town, outside its buildings.
	local reach = map.hub.size / 2 + 60
	for index = 1, 28 do
		local angle = index / 28 * math.pi * 2 + pick:NextNumber(-0.05, 0.05)
		local out = reach + pick:NextNumber(0, 60)
		grow(Vector3.new(map.hub.x + math.cos(angle) * out, 0, map.hub.z + math.sin(angle) * out))
	end
	-- Flowers dotted through the town itself.
	for _ = 1, 24 do
		local angle = pick:NextNumber(0, math.pi * 2)
		local out = pick:NextNumber(map.hub.size / 2 + 4, reach - 14)
		flowers(
			folder,
			Vector3.new(map.hub.x + math.cos(angle) * out, 0, map.hub.z + math.sin(angle) * out),
			pick
		)
	end
end

return Scatter
