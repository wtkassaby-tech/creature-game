--!strict
-- A creature you can see: a small toy-like body put together from rounded shapes, with a face,
-- and alive while it stands there (it breathes, sways and blinks). Each species has its own
-- sketch (ToySketches) drawn from the "Look" written in its species file.
-- TODO(art): these bodies stand in until the part meshes exist; Assembler.build then replaces
-- them, and the breathing and blinking move to the real rig.
-- Everything here is on the player's own device and is looks only.

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local ToySketches = require(script.Parent.ToySketches)
local Types = require(game:GetService("ReplicatedStorage").shared.Types)

local ToyBody = {}

export type Toy = {
	model: Model,
	place: (home: CFrame) -> (), -- where it stands: feet on this point, facing its look direction
	nudge: (offset: Vector3) -> (), -- pushed off its spot for a moment (a lunge, a shake)
	flash: () -> (), -- white for an instant, as when hit
	sink: () -> (), -- fades down into the ground, as when it faints
	destroy: () -> (),
}

type Live = {
	model: Model,
	home: CFrame,
	offset: Vector3,
	phase: number,
	blinkAt: number,
	eyes: { BasePart },
	lids: { BasePart },
	sunk: boolean,
}

local live: { [Model]: Live } = {}
local timing = Random.new() -- when each one blinks; looks only

local ANIMATE_WITHIN = 220 -- studs from the camera; further off they stand still

local function make(piece: ToySketches.Piece, parent: Instance, scale: number): BasePart
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = piece.role == nil
	part.Material = piece.material or Enum.Material.SmoothPlastic
	part.Color = piece.colour
	part.Transparency = piece.transparency or 0
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Size = piece.size * scale
	if piece.shape == "ball" then
		-- A sphere mesh on a block stretches with the block, which gives egg and bean shapes.
		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.Sphere
		mesh.Parent = part
	elseif piece.shape == "cylinder" then
		part.Shape = Enum.PartType.Cylinder
	elseif piece.shape == "wedge" then
		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.Wedge
		mesh.Parent = part
	end
	part.Parent = parent
	return part
end

local function step(now: number)
	local camera = Workspace.CurrentCamera
	local eye = if camera then camera.CFrame.Position else Vector3.zero
	for model, toy in live do
		if toy.sunk or (toy.home.Position - eye).Magnitude > ANIMATE_WITHIN then
			continue
		end
		-- Breathing: a slow rise and fall with a slight lean, each one out of step with the rest.
		local breath = math.sin(now * 2.2 + toy.phase)
		local sway = math.sin(now * 1.1 + toy.phase * 2)
		model:PivotTo(
			toy.home
					* CFrame.new(0, 0.12 + breath * 0.12, 0)
					* CFrame.Angles(math.rad(breath * 1.5), math.rad(sway * 4), 0)
				+ toy.offset
		)
		local closed = now >= toy.blinkAt
		if closed and now >= toy.blinkAt + 0.13 then
			toy.blinkAt = now + timing:NextNumber(2, 5.5)
			closed = false
		end
		for _, part in toy.eyes do
			part.Transparency = if closed then 1 else 0
		end
		for _, part in toy.lids do
			part.Transparency = if closed then 0 else 1
		end
	end
end

local running = false
local function ensureRunning()
	if running then
		return
	end
	running = true
	RunService.RenderStepped:Connect(function()
		step(os.clock())
	end)
end

function ToyBody.new(parent: Instance, species: string, element: Types.Element, size: number): Toy
	local scale = math.clamp(size, 0.6, 1.8)
	local model = Instance.new("Model")
	model.Name = `Toy_{species}`
	local pieces = ToySketches.sketch(species, element)
	local eyes: { BasePart } = {}
	local lids: { BasePart } = {}
	local colours: { [BasePart]: Color3 } = {}
	local materials: { [BasePart]: Enum.Material } = {}
	for _, piece in pieces do
		local part = make(piece, model, scale)
		part.CFrame = CFrame.new(piece.at.Position * scale) * piece.at.Rotation
		if piece.role == "eye" then
			table.insert(eyes, part)
		elseif piece.role == "lid" then
			part.Transparency = 1
			table.insert(lids, part)
		end
		colours[part], materials[part] = part.Color, part.Material
	end
	-- The pieces were laid out around the world's origin, so that is the point between its
	-- feet: with it as the pivot, `place` can stand the creature on the ground.
	model.WorldPivot = CFrame.new()
	model.Parent = parent

	local toy: Live = {
		model = model,
		home = CFrame.new(),
		offset = Vector3.zero,
		phase = timing:NextNumber(0, 6),
		blinkAt = os.clock() + timing:NextNumber(1, 4),
		eyes = eyes,
		lids = lids,
		sunk = false,
	}
	live[model] = toy
	model.Destroying:Once(function()
		live[model] = nil
	end)
	ensureRunning()

	return {
		model = model,
		place = function(home: CFrame)
			toy.home = home
			model:PivotTo(home)
		end,
		nudge = function(offset: Vector3)
			toy.offset = offset
		end,
		flash = function()
			for part in colours do
				if part.Transparency < 1 then
					part.Color = Color3.new(1, 1, 1)
					part.Material = Enum.Material.Neon
				end
			end
			task.delay(0.1, function()
				for part, colour in colours do
					part.Color = colour
					part.Material = materials[part]
				end
			end)
		end,
		sink = function()
			toy.sunk = true
			task.spawn(function()
				for count = 1, 12 do
					if model.Parent == nil then
						return
					end
					model:PivotTo(model:GetPivot() - Vector3.yAxis * 0.25)
					for part in colours do
						part.Transparency = math.max(part.Transparency, count / 12)
					end
					task.wait(0.03)
				end
			end)
		end,
		destroy = function()
			model:Destroy()
		end,
	}
end

return ToyBody
