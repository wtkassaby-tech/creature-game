--!strict
-- The building blocks every piece of map dressing uses: plain parts in flat colours, rounded
-- lumps, and the painted models from src/content/PropModels.luau, each loaded once and copied
-- wherever it is needed. A model that is missing or will not load returns nil, and the caller
-- builds its plain-shape fallback, so the map is never left bare.

local AssetService = game:GetService("AssetService")

local PropModels = require(game:GetService("ReplicatedStorage").content.PropModels)

local Props = {}

function Props.rgb(r: number, g: number, b: number): Color3
	return Color3.fromRGB(r, g, b)
end

-- A colour from data ({ r, g, b }).
function Props.colour(values: { number }): Color3
	return Color3.fromRGB(values[1], values[2], values[3])
end

-- A flat direction from a facing in degrees clockwise from north (north is -z).
function Props.facing(degrees: number): Vector3
	local angle = math.rad(degrees)
	return Vector3.new(math.sin(angle), 0, -math.cos(angle))
end

-- An anchored, non-collidable block: scenery never blocks a path unless the caller says so.
function Props.part(parent: Instance, size: Vector3, cframe: CFrame, colour: Color3): Part
	local made = Instance.new("Part")
	made.Anchored = true
	made.Size = size
	made.CFrame = cframe
	made.Color = colour
	made.Material = Enum.Material.SmoothPlastic
	made.TopSurface = Enum.SurfaceType.Smooth
	made.BottomSurface = Enum.SurfaceType.Smooth
	made.CanCollide = false
	made.Parent = parent
	return made
end

-- A rounded lump: a sphere mesh on a block stretches with the block.
function Props.lump(parent: Instance, size: Vector3, at: Vector3, colour: Color3): Part
	local made = Props.part(parent, size, CFrame.new(at), colour)
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = made
	return made
end

-- A flat round disc lying on the ground, its top at `top`.
function Props.disc(
	parent: Instance,
	centre: Vector3,
	diameter: number,
	thick: number,
	top: number,
	colour: Color3
): Part
	local made = Props.part(
		parent,
		Vector3.new(thick, diameter, diameter),
		CFrame.new(centre.X, top - thick / 2, centre.Z) * CFrame.Angles(0, 0, math.rad(90)),
		colour
	)
	made.Shape = Enum.PartType.Cylinder
	return made
end

-- A flat strip on the ground from `a` to `b`, `width` wide, its top at `top`.
function Props.strip(
	parent: Instance,
	a: Vector3,
	b: Vector3,
	width: number,
	thick: number,
	top: number,
	colour: Color3
): Part?
	local from, to = Vector3.new(a.X, top - thick / 2, a.Z), Vector3.new(b.X, top - thick / 2, b.Z)
	local length = (to - from).Magnitude
	if length < 0.05 then
		return nil
	end
	return Props.part(
		parent,
		Vector3.new(width, thick, length),
		CFrame.lookAt((from + to) / 2, to),
		colour
	)
end

-- The nearest point of a line of points to `at` (flat, ignoring height): how far along the
-- line it is and how far off.
function Props.nearest(points: { Vector3 }, at: Vector3): (number, number)
	local bestAlong, bestOff = 0, math.huge
	if #points > 0 then
		-- A line of one point (or of legs with no length) is that point: a pond, a pool.
		local first = points[1]
		bestOff = Vector3.new(first.X - at.X, 0, first.Z - at.Z).Magnitude
	end
	local covered = 0
	for index = 1, #points - 1 do
		local a, b = points[index], points[index + 1]
		local leg = Vector3.new(b.X - a.X, 0, b.Z - a.Z)
		local length = leg.Magnitude
		if length > 1e-6 then
			local run = leg / length
			local t = math.clamp((at.X - a.X) * run.X + (at.Z - a.Z) * run.Z, 0, length)
			local off = Vector3.new(a.X + run.X * t - at.X, 0, a.Z + run.Z * t - at.Z).Magnitude
			if off < bestOff then
				bestAlong, bestOff = covered + t, off
			end
		end
		covered += length
	end
	return bestAlong, bestOff
end

-- A line of points resampled about every `step` studs, keeping its corners.
function Props.resample(points: { Vector3 }, step: number): { Vector3 }
	local out: { Vector3 } = {}
	for index = 1, #points - 1 do
		local a, b = points[index], points[index + 1]
		local count = math.max(1, math.ceil((b - a).Magnitude / step))
		for k = 0, count - 1 do
			table.insert(out, a:Lerp(b, k / count))
		end
	end
	if #points > 0 then
		table.insert(out, points[#points])
	end
	return out
end

-- A painted model, loaded once by its asset id. Nil if there is none or it would not load.
local loaded: { [string]: MeshPart } = {}
local missing: { [string]: boolean } = {}
function Props.model(name: string): MeshPart?
	if loaded[name] or missing[name] then
		return loaded[name]
	end
	local def = PropModels[name]
	if not def then
		missing[name] = true
		return nil
	end
	local ok, made = pcall(function(): MeshPart
		return AssetService:CreateMeshPartAsync(Content.fromUri(def.mesh), {
			CollisionFidelity = Enum.CollisionFidelity.Box,
			RenderFidelity = Enum.RenderFidelity.Automatic,
		})
	end)
	if ok then
		made.Name = name -- `stand` looks the model up again by this name
		made.TextureID = def.texture
		made.Size = Vector3.new(def.size[1], def.size[2], def.size[3])
		made.Anchored = true
		made.CanCollide = false
		made.CanQuery = true -- so a battle can tell that something stands where it wants to be
		made.CanTouch = false
		made.Material = Enum.Material.SmoothPlastic
		loaded[name] = made
	else
		warn(`[Dressing] {name}: model did not load ({made})`)
		missing[name] = true
	end
	return loaded[name]
end

-- Stands a copy of a model on the ground at `foot`, `tall` studs high, its front facing along
-- `facing`.
function Props.stand(
	parent: Instance,
	model: MeshPart,
	foot: Vector3,
	tall: number,
	facing: Vector3
): MeshPart
	local copy = model:Clone()
	copy.Size = model.Size * (tall / model.Size.Y)
	local def = PropModels[model.Name]
	local flat = Vector3.new(facing.X, 0, facing.Z)
	local ahead = if flat.Magnitude > 1e-3 then flat.Unit else Vector3.zAxis
	copy.CFrame = CFrame.lookAt(foot, foot + ahead)
		* CFrame.new(0, copy.Size.Y / 2, 0)
		* CFrame.Angles(0, math.rad(if def and def.turn then def.turn else 0), 0)
	copy.Parent = parent
	return copy
end

-- Stands a copy of a model whose length runs along its own X axis (a fence section, a bridge)
-- so that it spans `length` studs from its middle at `foot` along `along`, `wide` deep and
-- `tall` high. The model is stretched to fit, not just scaled.
function Props.span(
	parent: Instance,
	model: MeshPart,
	foot: Vector3,
	along: Vector3,
	length: number,
	wide: number,
	tall: number
): MeshPart
	local copy = model:Clone()
	copy.Size = Vector3.new(length, tall, wide)
	local flat = Vector3.new(along.X, 0, along.Z)
	local run = if flat.Magnitude > 1e-3 then flat.Unit else Vector3.xAxis
	-- The model's front (-Z) faces square to the run, so its X axis lies along the run.
	local front = Vector3.new(run.Z, 0, -run.X)
	copy.CFrame = CFrame.lookAt(foot, foot + front) * CFrame.new(0, tall / 2, 0)
	copy.Parent = parent
	return copy
end

-- Text on a board, in the kit's pixel font: dark ink on cream.
function Props.text(board: BasePart, face: Enum.NormalId, text: string)
	local gui = Instance.new("SurfaceGui")
	gui.Face = face
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 40
	gui.LightInfluence = 0.4
	gui.Parent = board
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(0.92, 0.84)
	label.Position = UDim2.fromScale(0.04, 0.08)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Arcade
	label.TextColor3 = Color3.fromRGB(46, 36, 30)
	label.TextScaled = true
	label.Text = text
	label.Parent = gui
end

-- A lamp post facing `facing`: the painted Lamp if there is one, else a post and a glowing lump.
function Props.lamp(parent: Instance, foot: Vector3, facing: Vector3)
	local painted = Props.model("Lamp")
	if painted then
		Props.stand(parent, painted, foot, 13, facing)
		return
	end
	local post = Props.part(
		parent,
		Vector3.new(11, 0.8, 0.8),
		CFrame.new(foot + Vector3.yAxis * 5.5) * CFrame.Angles(0, 0, math.rad(90)),
		Props.rgb(60, 62, 72)
	)
	post.Shape = Enum.PartType.Cylinder
	post.CanCollide = true
	local glow = Props.lump(
		parent,
		Vector3.new(2.4, 2.4, 2.4),
		foot + Vector3.yAxis * 11.6,
		Props.rgb(255, 236, 170)
	)
	glow.Material = Enum.Material.Neon
	Props.lump(parent, Vector3.new(3.2, 1, 3.2), foot + Vector3.yAxis * 13, Props.rgb(60, 62, 72))
end

-- A tree of the named model ("Tree", "Pine" or "Birch") at its natural-looking height times
-- `scale`, turned at random; plain trunk and crown lumps when the model is missing. Trees are
-- scenery: never collidable.
function Props.tree(parent: Instance, foot: Vector3, name: string, scale: number, pick: Random)
	local turn = pick:NextNumber(0, math.pi * 2)
	local facing = Vector3.new(math.cos(turn), 0, math.sin(turn))
	local painted = Props.model(name) or (if name == "Birch" then nil else Props.model("Tree"))
	if painted then
		local tall = if name == "Birch" then pick:NextNumber(16, 22) else pick:NextNumber(15, 24)
		Props.stand(parent, painted, foot, tall * scale, facing)
		return
	end
	local birch = name == "Birch"
	local height = pick:NextNumber(7, 12) * scale
	local trunk = Props.part(
		parent,
		Vector3.new(height, 2 * scale, 2 * scale),
		CFrame.new(foot + Vector3.yAxis * height / 2) * CFrame.Angles(0, 0, math.rad(90)),
		if birch then Props.rgb(236, 232, 220) else Props.rgb(120, 84, 56)
	)
	trunk.Shape = Enum.PartType.Cylinder
	local leaf = if birch
		then Props.rgb(176, 204, 96)
		elseif name == "Pine" then Props.rgb(60, 120, 70)
		else Props.rgb(84, 160, 78)
	local crown = pick:NextNumber(9, 14) * scale
	local shade = leaf:Lerp(Color3.new(0, 0, 0), pick:NextNumber(0, 0.18))
	Props.lump(
		parent,
		Vector3.new(crown, crown * 0.8, crown),
		foot + Vector3.yAxis * (height + crown * 0.2),
		shade
	)
	Props.lump(
		parent,
		Vector3.new(crown * 0.7, crown * 0.6, crown * 0.7),
		foot + Vector3.new(pick:NextNumber(-3, 3), height + crown * 0.55, pick:NextNumber(-3, 3)),
		shade:Lerp(Color3.new(1, 1, 1), 0.12)
	)
end

-- A park bench facing `facing`: the painted Bench, else a plank seat and back on legs.
function Props.bench(parent: Instance, foot: Vector3, facing: Vector3)
	local painted = Props.model("Bench")
	if painted then
		Props.stand(parent, painted, foot, 3.6, facing)
		return
	end
	local wood = Props.rgb(150, 108, 70)
	local base = CFrame.lookAt(foot, foot + facing)
	Props.part(parent, Vector3.new(6, 0.4, 1.8), base * CFrame.new(0, 1.8, 0), wood)
	Props.part(parent, Vector3.new(6, 1.4, 0.3), base * CFrame.new(0, 2.8, 0.9), wood)
	for _, side in { -2.6, 2.6 } do
		Props.part(
			parent,
			Vector3.new(0.4, 1.8, 1.6),
			base * CFrame.new(side, 0.9, 0),
			Props.rgb(60, 62, 72)
		)
	end
end

return Props
