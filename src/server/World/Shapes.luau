--!strict
-- The painted models a canyon or seaside biome adds (docs/plans/09_DUST_CANYON_MAP.md section 5
-- and 10_TIDE_FLATS_MAP.md section 5), each with a plain-shape stand-in in a fitting colour for
-- when the model is missing or will not load: scrub, rock spires, boulders, adobe houses, kiln
-- cottages, the trading post, the bottle kiln and the wind tower (the far landmarks' stand-ins
-- are in Skyline.luau). Greenwood's own names (Tree, Pine, Birch) go straight to Props.tree,
-- unchanged.

local Props = require(script.Parent.Props)
local Water = require(script.Parent.Water)

local Shapes = {}

local rgb = Props.rgb

-- How tall each planted model stands (a range, before the sheet's scale).
local PLANT_TALL: { [string]: { number } } = {
	ScrubBush = { 3.5, 5 },
	RockSpire = { 20, 30 },
	Boulders = { 6, 8 },
	SeaRocks = { 5, 7 },
	Kelp = { 4, 6 },
	MarramTuft = { 2.5, 3.5 },
	DryTuft = { 2.2, 2.8 },
}

local SAND_STONE: { Color3 } = { rgb(206, 150, 100), rgb(186, 112, 80), rgb(220, 170, 120) }
local SEA_STONE: { Color3 } = { rgb(84, 84, 92), rgb(104, 104, 112), rgb(70, 72, 80) }
local SPIRE_BANDS: { Color3 } =
	{ rgb(196, 98, 70), rgb(236, 200, 150), rgb(176, 84, 60), rgb(222, 150, 100) }
local ADOBE = rgb(226, 186, 140)
local ADOBE_ROOF = rgb(196, 150, 104)
local KILN_CLAY = rgb(184, 104, 76)
local TIMBER = rgb(120, 84, 56)

-- A whole number from a spot, so the same spot always gets the same small variation.
local function hash(at: Vector3): number
	return math.floor(math.abs(at.X * 7.31 + at.Z * 3.17)) % 97
end

local function cylinder(
	parent: Instance,
	foot: Vector3,
	across: number,
	tall: number,
	colour: Color3
): Part
	local made = Props.part(
		parent,
		Vector3.new(tall, across, across),
		CFrame.new(foot + Vector3.yAxis * tall / 2) * CFrame.Angles(0, 0, math.rad(90)),
		colour
	)
	made.Shape = Enum.PartType.Cylinder
	return made
end
-- An upright cylinder standing on `foot`, `across` wide and `tall` high.
Shapes.cylinder = cylinder

-- A plain stand-in for a named model standing at `foot`, `tall` high, front along `facing`. The
-- pieces it made, so the caller can make them block the way; empty for a name it does not know.
function Shapes.fallback(
	parent: Instance,
	name: string,
	foot: Vector3,
	tall: number,
	facing: Vector3
): { BasePart }
	local made: { BasePart } = {}
	local vary = hash(foot)
	local across = Vector3.new(-facing.Z, 0, facing.X)
	if name == "ScrubBush" then
		table.insert(
			made,
			Props.lump(
				parent,
				Vector3.new(tall * 1.5, tall, tall * 1.4),
				foot + Vector3.yAxis * tall * 0.45,
				rgb(128, 150, 96)
			)
		)
		table.insert(
			made,
			Props.lump(
				parent,
				Vector3.new(tall * 0.9, tall * 0.7, tall * 0.9),
				foot + across * tall * 0.4 + Vector3.yAxis * tall * 0.7,
				rgb(150, 164, 104)
			)
		)
	elseif name == "Boulders" or name == "SeaRocks" then
		local colours = if name == "Boulders" then SAND_STONE else SEA_STONE
		table.insert(
			made,
			Props.lump(
				parent,
				Vector3.new(tall * 1.2, tall * 1.1, tall),
				foot + Vector3.yAxis * tall * 0.4,
				colours[1 + vary % 3]
			)
		)
		for _, side in { -1, 1 } do
			table.insert(
				made,
				Props.lump(
					parent,
					Vector3.new(tall * 0.6, tall * 0.55, tall * 0.55),
					foot
						+ across * side * tall * 0.75
						+ facing * tall * 0.2
						+ Vector3.yAxis * tall * 0.2,
					colours[1 + (vary + side + 3) % 3]
				)
			)
		end
	elseif name == "RockSpire" then
		-- Bulging striped drums, narrowing upwards, under a flat dark cap.
		local width = tall * 0.36
		local height = 0
		for band = 1, 4 do
			local piece = tall * 0.23
			local wide = width * (1.1 - band * 0.1)
			table.insert(
				made,
				Props.lump(
					parent,
					Vector3.new(wide, piece * 1.3, wide),
					foot + Vector3.yAxis * (height + piece / 2),
					SPIRE_BANDS[(band + vary) % #SPIRE_BANDS + 1]
				)
			)
			height += piece
		end
		table.insert(
			made,
			cylinder(
				parent,
				foot + Vector3.yAxis * height,
				width * 1.1,
				tall * 0.08,
				rgb(140, 90, 70)
			)
		)
	elseif name == "DryTuft" or name == "MarramTuft" or name == "Kelp" then
		local colour = if name == "DryTuft"
			then rgb(206, 180, 104)
			elseif name == "MarramTuft" then rgb(170, 180, 120)
			else rgb(110, 110, 60)
		table.insert(
			made,
			Props.lump(
				parent,
				Vector3.new(tall * 0.6, tall, tall * 0.6),
				foot + Vector3.yAxis * tall * 0.45,
				colour
			)
		)
	end
	return made
end

-- A planted thing outside a corridor edge or in a clump: the named model at its natural height
-- times `scale`, turned at random, or its plain stand-in. Tree, Pine, Birch and any other name
-- go to Props.tree exactly as before. Never collidable.
function Shapes.plant(parent: Instance, foot: Vector3, name: string, scale: number, pick: Random)
	if name == "Reeds" then
		Water.reeds(parent, foot, pick)
		return
	end
	local range = PLANT_TALL[name]
	if range == nil then
		Props.tree(parent, foot, name, scale, pick)
		return
	end
	local turn = pick:NextNumber(0, math.pi * 2)
	local facing = Vector3.new(math.cos(turn), 0, math.sin(turn))
	local tall = pick:NextNumber(range[1], range[2]) * scale
	local painted = Props.model(name)
	if painted then
		Props.stand(parent, painted, foot, tall, facing)
	else
		Shapes.fallback(parent, name, foot, tall, facing)
	end
end

-- A painted thing standing for its own sake (a boulder heap, a spire): the model, or its plain
-- stand-in. Nil when there is neither, as for a missing cart or washing line.
function Shapes.prop(
	parent: Instance,
	name: string,
	foot: Vector3,
	tall: number,
	facing: Vector3
): { BasePart }?
	local painted = Props.model(name)
	if painted then
		local stood: BasePart = Props.stand(parent, painted, foot, tall, facing)
		return { stood }
	end
	local made = Shapes.fallback(parent, name, foot, tall, facing)
	return if #made > 0 then made else nil
end

-- A flat-roofed adobe box: walls, a roof slab, a door and two little windows.
local function adobe(
	parent: Instance,
	base: CFrame,
	width: number,
	depth: number,
	tall: number,
	wall: Color3,
	door: Color3
)
	local high = tall * 0.8
	Props.part(parent, Vector3.new(width, high, depth), base * CFrame.new(0, high / 2, 0), wall)
	Props.part(
		parent,
		Vector3.new(width + 1.6, 1.2, depth + 1.6),
		base * CFrame.new(0, high + 0.6, 0),
		ADOBE_ROOF
	)
	local front = -depth / 2 - 0.15
	Props.part(parent, Vector3.new(4, 7, 0.4), base * CFrame.new(0, 3.5, front), door)
	for _, side in { -1, 1 } do
		Props.part(
			parent,
			Vector3.new(2.6, 2.6, 0.4),
			base * CFrame.new(side * width * 0.3, high * 0.6, front),
			rgb(70, 110, 170)
		)
	end
	for k = -2, 2 do -- roof beams poking out under the roof edge
		Props.part(
			parent,
			Vector3.new(0.8, 0.8, 2),
			base * CFrame.new(k * width / 5, high - 0.8, front - 0.6),
			TIMBER
		)
	end
end

-- A building's plain stand-in, on the ground under `base` (its front faces base's look vector).
-- False when the name is not one of these, so the caller keeps its own cottage.
function Shapes.building(
	parent: Instance,
	name: string,
	base: CFrame,
	width: number,
	depth: number,
	tall: number
): boolean
	if name == "AdobeHouse" then
		adobe(parent, base, width, depth, tall, ADOBE, rgb(64, 160, 170))
	elseif name == "TradingPost" then
		adobe(parent, base, width, depth, tall, rgb(236, 214, 176), TIMBER)
		-- The red-and-cream striped awning over the door.
		for k = 0, 5 do
			Props.part(
				parent,
				Vector3.new(width / 6, 0.4, 5),
				base
					* CFrame.new((k - 2.5) * width / 6, 9, -depth / 2 - 2.4)
					* CFrame.Angles(math.rad(-15), 0, 0),
				if k % 2 == 0 then rgb(206, 72, 64) else rgb(244, 232, 208)
			)
		end
	elseif name == "KilnCottage" then
		local foot = base.Position
		Props.lump(
			parent,
			Vector3.new(width, tall * 1.7, depth),
			foot + Vector3.yAxis * tall * 0.1,
			KILN_CLAY
		)
		Props.part(
			parent,
			Vector3.new(2.6, 5, 2.6),
			base * CFrame.new(width * 0.2, tall * 0.85, depth * 0.1),
			rgb(150, 84, 60)
		)
		Props.part(
			parent,
			Vector3.new(4, 7, 0.6),
			base * CFrame.new(0, 3.5, -depth / 2 + 0.6),
			TIMBER
		)
	elseif name == "BottleKiln" then
		local foot = base.Position
		cylinder(parent, foot, width * 0.95, tall * 0.4, rgb(214, 120, 70))
		local height, across = tall * 0.4, width * 0.95
		for _ = 1, 3 do -- the bottle's shoulders and its tapering chimney
			across *= 0.68
			cylinder(parent, foot + Vector3.yAxis * height, across, tall * 0.2, rgb(200, 108, 64))
			height += tall * 0.2
		end
		local glow = Props.part(
			parent,
			Vector3.new(6, 7, 0.4),
			base * CFrame.new(0, 3.5, -width * 0.48),
			rgb(255, 170, 80)
		)
		glow.Material = Enum.Material.Neon
	elseif name == "WindTower" then
		local deck = tall * 0.7
		for _, x in { -1, 1 } do
			for _, z in { -1, 1 } do
				Props.part(
					parent,
					Vector3.new(1.2, deck, 1.2),
					base * CFrame.new(x * width * 0.35, deck / 2, z * depth * 0.35),
					TIMBER
				)
			end
		end
		Props.part(
			parent,
			Vector3.new(width * 0.9, 1, depth * 0.9),
			base * CFrame.new(0, deck, 0),
			rgb(150, 108, 70)
		)
		for _, side in { -1, 1 } do -- a pointed tin roof
			local roof = Instance.new("WedgePart")
			roof.Anchored, roof.CanCollide = true, false
			roof.Size = Vector3.new(width, tall * 0.15, depth / 2)
			roof.Color = rgb(150, 160, 170)
			roof.Material = Enum.Material.SmoothPlastic
			roof.CFrame = base
				* CFrame.new(0, deck + 6 + tall * 0.075, side * depth / 4)
				* CFrame.Angles(0, if side == -1 then 0 else math.rad(180), 0)
			roof.Parent = parent
		end
		for _, z in { -1, 1 } do -- the posts holding the roof
			Props.part(
				parent,
				Vector3.new(0.6, 6, 0.6),
				base * CFrame.new(width * 0.35, deck + 3, z * depth * 0.35),
				TIMBER
			)
			Props.part(
				parent,
				Vector3.new(0.6, 6, 0.6),
				base * CFrame.new(-width * 0.35, deck + 3, z * depth * 0.35),
				TIMBER
			)
		end
	else
		return false
	end
	return true
end

return Shapes
