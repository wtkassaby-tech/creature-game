--!strict
-- The solid ground beyond a biome's edges (docs/plans/12_MAP_STRUCTURE.md section 10, step 1):
-- a row of tall trees (or rock spires, or sand banks) just outside every edge, a row of masses
-- behind it and big blocks out to the band, so past a route there is only more forest, rock or
-- dune and never open field. Enclosure.fill chooses where; this makes the parts. Plain stand-ins
-- for the painted pieces the plan lists (ForestWall, ForestBlock, MesaBlock) until those exist:
-- the painted Tree, Pine and RockSpire where they load, dark lumps and mesas otherwise.
-- Looks only: every part is anchored, uncollidable, never queried and casts no shadow, so
-- the filler costs the phone as little as it can. What stops a character is the edge's own core.

local Enclosure = require(game:GetService("ReplicatedStorage").shared.Enclosure)
local WorldTypes = require(game:GetService("ReplicatedStorage").shared.WorldTypes)

local Props = require(script.Parent.Props)
local Shapes = require(script.Parent.Shapes)

local Fill = {}

local rgb = Props.rgb
local FOREST: { Color3 } = { rgb(46, 98, 52), rgb(54, 112, 58), rgb(64, 124, 64) }
local ROCK: { Color3 } = { rgb(184, 100, 72), rgb(208, 140, 98), rgb(222, 164, 118) }
local DUNE: { Color3 } = { rgb(224, 204, 154), rgb(236, 218, 170), rgb(212, 190, 138) }
-- The swamp's dark mossy mounds: murky greens and brown-greens.
local SWAMP: { Color3 } = { rgb(54, 76, 52), rgb(64, 88, 56), rgb(74, 82, 54) }

-- How many parts a build made, by layer.
export type Counts = { rows: number, masses: number, blocks: number }

-- Filler is never collided with, queried (so battles and pads ignore it) or lit by shadow.
local function quiet(part: BasePart)
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
end

local function colourOf(palette: { Color3 }, pick: number): Color3
	return palette[math.min(#palette, math.floor(pick * #palette) + 1)]
end

-- The rest of a pick, so colour and model do not move together.
local function second(pick: number): number
	return (pick * 7.13) % 1
end

local function facingOf(pick: number): Vector3
	local turn = pick * math.pi * 2
	return Vector3.new(math.cos(turn), 0, math.sin(turn))
end

-- A mass: a lump (forest, dune) or a flat-topped mesa (rock) `across` wide and `tall` high.
local function mass(
	parent: Instance,
	style: WorldTypes.FillStyle,
	foot: Vector3,
	across: number,
	tall: number,
	pick: number,
	far: boolean?
)
	-- Painted where the model loads (a block of canyon cliff, a dune with marram), so the
	-- fill never reads as plain drums and domes from a terrace or the camera's height.
	local painted = if style == "Rock"
		then Props.model("CliffWall")
		elseif style == "Dune" then Props.model(if far then "SandDuneLow" else "SandDune")
		else nil
	if painted then
		local facing = facingOf(second(pick))
		if style == "Rock" then
			quiet(Props.span(parent, painted, foot, facing, across, across * 0.7, tall))
		else
			-- Dunes stay low and broad: they frame the sea, they do not wall it off.
			local low = math.min(tall, across * 0.45)
			quiet(Props.span(parent, painted, foot, facing, across * 1.3, across, low))
		end
		return
	end
	if style == "Rock" then
		local made = Shapes.cylinder(parent, foot, across, tall, colourOf(ROCK, pick))
		quiet(made)
	else
		local palette = if style == "Forest" then FOREST elseif style == "Swamp" then SWAMP else DUNE
		-- Centred a little low, so the bottom of the dome is buried and meets the ground wide.
		local made = Props.lump(
			parent,
			Vector3.new(across, tall, across),
			foot + Vector3.yAxis * tall * 0.4,
			colourOf(palette, pick)
		)
		quiet(made)
	end
end

-- One thing in the row at the edge: a painted tree or spire at full height, or a lump.
local function edge(
	parent: Instance,
	style: WorldTypes.FillStyle,
	foot: Vector3,
	tall: number,
	pick: number
)
	local facing = facingOf(second(pick))
	if style == "Forest" then
		local painted = Props.model(if pick < 0.62 then "Tree" else "Pine")
		if painted then
			quiet(Props.stand(parent, painted, foot, tall, facing))
			return
		end
	elseif style == "Swamp" then
		-- Mangrove and bald cypress in the edge rows, mossy mounds where the model is missing.
		local painted = Props.model(if pick < 0.55 then "Mangrove" else "Cypress")
		if painted then
			quiet(Props.stand(parent, painted, foot, tall, facing))
			return
		end
	elseif style == "Rock" and pick < 0.4 then
		-- Spires only now and then, mixed into blocks of cliff and boulders: a row of nothing
		-- but spires read as a line of traffic cones (Studio, 23 November 2026).
		local spireTall = tall * (0.75 + second(pick) * 0.45)
		local parts = Shapes.prop(parent, "RockSpire", foot, spireTall, facing)
		if parts then
			for _, part in parts do
				quiet(part)
			end
			return
		end
	elseif style == "Rock" and pick < 0.65 then
		local boulders = Props.model("Boulders")
		if boulders then
			quiet(Props.stand(parent, boulders, foot, tall * 0.55, facing))
			return
		end
	end
	mass(parent, style, foot, tall * (if style == "Dune" then 1.6 else 0.9), tall, second(pick))
end

-- Builds a fill plan under `parent` and says how many parts of each layer it made.
function Fill.build(parent: Instance, style: WorldTypes.FillStyle, plan: Enclosure.FillPlan): Counts
	local folder = Instance.new("Folder")
	folder.Name = "Fill"
	folder.Parent = parent
	for _, spot in plan.rows do
		edge(folder, style, Vector3.new(spot.x, 0, spot.z), spot.tall, spot.pick)
	end
	for _, spot in plan.masses do
		local across = 24 + second(spot.pick) * 8
		mass(folder, style, Vector3.new(spot.x, 0, spot.z), across, spot.tall, spot.pick)
	end
	for _, spot in plan.blocks do
		local across = 36 + second(spot.pick) * 6
		mass(folder, style, Vector3.new(spot.x, 0, spot.z), across, spot.tall, spot.pick, true)
	end
	return { rows = #plan.rows, masses = #plan.masses, blocks = #plan.blocks }
end

return Fill
