--!strict
-- Checks on the far scenery list (src/content/world_data/FarScenery.luau): it stays inside the
-- part budgets in FarSceneryConfig, every piece is well formed, and nothing far-off stands over
-- any biome's walkable space or its fill band. Run from the project folder:
--   lune run tests/farscenery.test

local Biomes = require("../src/content/Biomes")
local FarSceneryConfig = require("../src/config/FarSceneryConfig")
local Layout = require("../src/shared/Layout")
local PropModels = require("../src/content/PropModels")
local Tamers = require("../src/content/Tamers")
local World = require("../src/content/World")
local WorldTypes = require("../src/shared/WorldTypes")

local passed, failed = 0, 0
local function check(name: string, condition: boolean, detail: string?)
	if condition then
		passed += 1
	else
		failed += 1
	end
	print(
		`  {if condition then "PASS" else "FAIL"}  {name}{if detail
			then "  (" .. detail .. ")"
			else ""}`
	)
end

local pieces = World.farScenery
local config = FarSceneryConfig

-- Budgets -------------------------------------------------------------------------------------
local byLayer: { [string]: number } = {}
local seen: { [string]: boolean } = {}
local duplicate: string? = nil
for _, piece in pieces do
	byLayer[piece.layer] = (byLayer[piece.layer] or 0) + 1
	if seen[piece.id] then
		duplicate = piece.id
	end
	seen[piece.id] = true
end
check("piece ids are unique", duplicate == nil, duplicate)
check(
	"total within the world budget",
	#pieces <= config.TOTAL_BUDGET,
	`{#pieces}/{config.TOTAL_BUDGET}`
)
local layerBudgets = 0
for name, layer in config.LAYERS do
	local used = byLayer[name] or 0
	check(`layer {name} within its budget`, used <= layer.budget, `{used}/{layer.budget}`)
	check(`layer {name} is not empty`, used > 0)
	layerBudgets += layer.budget
end
check("layer budgets add up to no more than the total", layerBudgets <= config.TOTAL_BUDGET)
for name in byLayer do
	check(`layer {name} is configured`, config.LAYERS[name] ~= nil)
end

-- Each piece ----------------------------------------------------------------------------------
local malformed: { string } = {}
local tooBig: { string } = {}
for _, piece in pieces do
	local ok = #piece.size == 3 and #piece.colour == 3 and piece.scale > 0
	for _, v in piece.colour do
		ok = ok and v >= 0 and v <= 255
	end
	for _, v in piece.size do
		ok = ok and v > 0
	end
	local isForm = piece.model == "Lump" or piece.model == "Puff"
	ok = ok and (isForm or PropModels[piece.model] ~= nil)
	if not ok then
		table.insert(malformed, piece.id)
		continue
	end
	-- A dome is built as a whole oval twice its height, half of it sunk below the foot.
	local height = piece.size[2] * (if piece.model == "Puff" then 1 else 2) * piece.scale
	for _, extent in { piece.size[1] * piece.scale, height, piece.size[3] * piece.scale } do
		if extent > config.MAX_PART_STUDS then
			table.insert(tooBig, piece.id)
			break
		end
	end
end
check("every piece is well formed", #malformed == 0, table.concat(malformed, ", "))
check("no piece exceeds the part size limit", #tooBig == 0, table.concat(tooBig, ", "))

-- The Crown -----------------------------------------------------------------------------------
local CROWN_CENTRE = { x = 1350, z = -1700 }
local lumps, puffs = 0, 0
local offRing: { string } = {}
local halo: { string } = {}
for _, piece in pieces do
	if piece.id:match("^crown_%d") then
		lumps += 1
		local d = math.sqrt((piece.at.x - CROWN_CENTRE.x) ^ 2 + (piece.at.z - CROWN_CENTRE.z) ^ 2)
		if d < 700 or d > 950 then
			table.insert(offRing, piece.id)
		end
	elseif piece.id:match("^halo_") then
		puffs += 1
		-- The halo lies at y 450 to 520.
		if piece.base < 450 or piece.base + piece.size[2] > 520 then
			table.insert(halo, piece.id)
		end
	end
end
check(
	"the Crown is a ring of mountains with a halo",
	lumps >= 8 and puffs >= 4,
	`{lumps} / {puffs}`
)
check(
	"Crown mountains stand on the ring (radius 700 to 950)",
	#offRing == 0,
	table.concat(offRing, ", ")
)
check("the halo sits at y 450 to 520", #halo == 0, table.concat(halo, ", "))

-- Keep out of walkable space -------------------------------------------------------------------
-- Each biome's walkable bounds: every place and route point of its map, and the passages' points.
local ordered: { WorldTypes.Biome } = {}
for _, biome in Biomes do
	table.insert(ordered, biome)
end
table.sort(ordered, function(a, b)
	return a.number < b.number
end)
local world = Layout.world(ordered, Tamers.locals)

type Box = { x0: number, z0: number, x1: number, z1: number }
local boxes: { Box } = {}
for _, map in world.maps do
	local box: Box = { x0 = math.huge, z0 = math.huge, x1 = -math.huge, z1 = -math.huge }
	local function take(p: { x: number, z: number })
		box.x0, box.x1 = math.min(box.x0, p.x), math.max(box.x1, p.x)
		box.z0, box.z1 = math.min(box.z0, p.z), math.max(box.z1, p.z)
	end
	for _, p in map.places do
		take(p)
	end
	for _, route in map.routes do
		for _, p in route.points do
			take(p)
		end
	end
	table.insert(boxes, box)
end
for _, passage in World.passages do
	local box: Box = { x0 = math.huge, z0 = math.huge, x1 = -math.huge, z1 = -math.huge }
	for _, p in passage.points do
		box.x0, box.x1 = math.min(box.x0, p.x), math.max(box.x1, p.x)
		box.z0, box.z1 = math.min(box.z0, p.z), math.max(box.z1, p.z)
	end
	table.insert(boxes, box)
end
check("there are walkable bounds to test against", #boxes >= 5)

local function boxDistance(box: Box, x: number, z: number): number
	local dx = math.max(box.x0 - x, 0, x - box.x1)
	local dz = math.max(box.z0 - z, 0, z - box.z1)
	return math.sqrt(dx * dx + dz * dz)
end

-- The least distance from a piece's whole footprint (a rotated rectangle, sampled on a grid, which
-- is a little bigger than the oval it holds) to any walkable box.
local STEPS = 24
local function clearance(piece: WorldTypes.FarScenery): number
	local half = { piece.size[1] * piece.scale / 2, piece.size[3] * piece.scale / 2 }
	local turn = math.rad(piece.faces)
	-- The width axis is (cos, sin) and the depth axis (sin, -cos): see FarScenery in WorldTypes.
	local ax, az = math.cos(turn), math.sin(turn)
	local bx, bz = math.sin(turn), -math.cos(turn)
	local least = math.huge
	for i = 0, STEPS do
		for j = 0, STEPS do
			local u = (i / STEPS * 2 - 1) * half[1]
			local v = (j / STEPS * 2 - 1) * half[2]
			local x = piece.at.x + ax * u + bx * v
			local z = piece.at.z + az * u + bz * v
			for _, box in boxes do
				least = math.min(least, boxDistance(box, x, z))
			end
		end
	end
	return least
end

local tooClose: { string } = {}
local closest = math.huge
for _, piece in pieces do
	local gap = clearance(piece)
	closest = math.min(closest, gap)
	if gap < config.KEEP_OUT_MARGIN then
		table.insert(tooClose, `{piece.id} ({math.floor(gap)})`)
	end
end
check(
	`nothing far-off stands within {config.KEEP_OUT_MARGIN} studs of walkable space`,
	#tooClose == 0,
	if #tooClose > 0 then table.concat(tooClose, ", ") else `closest {math.floor(closest)}`
)

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("far scenery checks failed")
end
