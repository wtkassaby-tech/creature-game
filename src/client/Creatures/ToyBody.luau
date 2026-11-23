--!strict
-- A creature you can see: a small toy-like body put together from rounded shapes, with a face,
-- and alive while it stands there (it breathes, sways and blinks). Each species has its own
-- sketch (ToySketches) drawn from the "Look" written in its species file; a species with a
-- painted model wears that instead once it has loaded.
-- Motion is a channel: `act` plays a curve (shared/Motion) of offset, tilt and scale on top of the
-- idle, evaluated in one RenderStepped step, so nothing moves in jumps.
-- Everything here is on the player's own device and is looks only.

local AssetService = game:GetService("AssetService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Aura = require(script.Parent.Aura)
local CreatureModels = require(ReplicatedStorage.content.CreatureModels)
local Gestures = require(ReplicatedStorage.shared.Gestures)
local Motion = require(ReplicatedStorage.shared.Motion)
local SpeciesQuirks = require(ReplicatedStorage.content.SpeciesQuirks)
local ToySketches = require(script.Parent.ToySketches)
local Types = require(ReplicatedStorage.shared.Types)

local ToyBody = {}

-- A motion played on top of the idle: `curve` takes progress 0..1 and gives the pose (an offset
-- in the creature's own frame, a tilt about its feet, a height scale and a fade).
export type Curve = (t: number) -> Motion.Pose

export type Toy = {
	model: Model,
	place: (home: CFrame) -> (), -- where it stands: feet on this point, facing its look direction
	nudge: (offset: Vector3) -> (), -- pushed off its spot for a moment (a shake)
	-- Plays a motion over `seconds`; a new one replaces the one before. With `keep` it stays in
	-- the last pose for good (a faint, a creature that has fled) and the idle stops.
	act: (curve: Curve, seconds: number, keep: boolean?) -> (),
	-- Eases the whole body to `scale` times its size over `seconds` (held in a loop, squeezed).
	hold: (scale: number, seconds: number) -> (),
	flash: () -> (), -- white for an instant, as when hit
	sink: () -> (), -- fades down into the ground, as when it faints
	gone: () -> (), -- true once it has fainted or fled, and stays so
	rate: (hz: number?) -> (), -- redraw at most this often (a small list card); nil: automatic
	-- Stops (true) or allows (false) its species' idle gesture; a silhouette stays still.
	still: (on: boolean) -> (),
	destroy: () -> (),
}

type Act = { curve: Curve, seconds: number, began: number, keep: boolean }

type Live = {
	model: Model,
	home: CFrame,
	offset: Vector3,
	phase: number,
	size: number, -- the species' size, which slows the breath of a big one
	blinkAt: number,
	closed: boolean,
	eyes: { BasePart },
	lids: { BasePart },
	natural: { [BasePart]: number }, -- each sketch part's own transparency
	sunk: boolean,
	ending: boolean, -- a `keep` motion has begun: nothing else moves it now
	inWorld: boolean, -- false for one shown inside a screen, which is always near enough
	body: MeshPart?, -- the painted model, once it has loaded
	aura: Aura.Handle?, -- a mythic's or giant's glow and hover, once its model has loaded
	baseSize: Vector3,
	turn: number,
	act: Act?,
	frozen: Motion.Pose?, -- the pose it stays in once a `keep` act has ended
	held: number,
	heldFrom: number,
	heldTo: number,
	heldBegan: number,
	heldSeconds: number,
	waiting: boolean, -- sketch hidden while its model loads
	waitUntil: number,
	fade: number, -- the fade last painted
	sketchScale: number,
	-- A creature inside a screen only moves while that screen can be seen, checked twice a second.
	gui: GuiObject?,
	onScreen: boolean,
	nextCheck: number,
	gap: number, -- seconds between redraws; 0 is every frame
	nextAt: number,
	hz: number?, -- asked for by the screen; otherwise a scrolling list is drawn at LIST_HZ
	-- The idle gesture of its species (content/SpeciesQuirks), played now and then on the animation
	-- clock. `still` stops it; a species with no quirk has none.
	gesture: ((t: number) -> Motion.Pose)?,
	gestureSeconds: number,
	gestureEvery: number,
	gestureAt: number,
	still: boolean,
}

local live: { [Model]: Live } = {}
local timing = Random.new() -- when each one blinks; looks only

-- One loaded model per species, copied for every creature shown. A species whose model could
-- not be loaded is remembered too, so its sketch stays and nothing asks again.
local templates: { [string]: MeshPart } = {}
local failed: { [string]: boolean } = {}
local loading: { [string]: boolean } = {}

local function loadTemplate(species: string, def: CreatureModels.ModelDef): MeshPart?
	while loading[species] do
		task.wait(0.05)
	end
	if templates[species] or failed[species] then
		return templates[species]
	end
	loading[species] = true
	local ok, made = pcall(function(): MeshPart
		-- Box collision: a creature is only drawn, never collided with, so the cheapest hull will do.
		return AssetService:CreateMeshPartAsync(Content.fromUri(def.mesh), {
			CollisionFidelity = Enum.CollisionFidelity.Box,
		})
	end)
	if ok then
		made.TextureID = def.texture
		made.Size = Vector3.new(def.size[1], def.size[2], def.size[3])
		made.Anchored = true
		made.CanCollide = false
		made.CanQuery = false
		made.CanTouch = false
		made.Material = Enum.Material.SmoothPlastic
		templates[species] = made
	else
		warn(`[ToyBody] {species}: model did not load ({made})`)
		failed[species] = true
	end
	loading[species] = nil
	return templates[species]
end

local ANIMATE_WITHIN = 220 -- studs from the camera; further off they stand still
local LIST_HZ = 10 -- creatures in a scrolling list
local SCREEN_CHECK_SECONDS = 0.5
local SKETCH_SCALE_STEP = 0.003
local REST = Motion.rest()

-- Time that the animation runs on. A hit freezes it for a moment (hit-stop), so the squash is
-- seen before anything moves on.
local animClock = 0
local lastStep = os.clock()
local frozenUntil = 0

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

-- Whether a creature inside a screen can be seen: the screen is on and every frame above it shows.
local function onScreenNow(frame: GuiObject): boolean
	local node: Instance? = frame
	while node do
		if node:IsA("GuiObject") and not node.Visible then
			return false
		end
		if node:IsA("LayerCollector") and not node.Enabled then
			return false
		end
		node = node.Parent
	end
	return frame:IsDescendantOf(game)
end

-- Writes how see-through each piece is: its own, or the fade, whichever hides more.
local function paint(toy: Live)
	local fade = if toy.waiting then 1 else toy.fade
	local body = toy.body
	if body then
		body.Transparency = fade
		return
	end
	for part, natural in toy.natural do
		part.Transparency = math.max(natural, fade)
	end
end

local function setFade(toy: Live, fade: number)
	if math.abs(fade - toy.fade) > 0.004 or (fade == 0) ~= (toy.fade == 0) then
		toy.fade = fade
		paint(toy)
	end
end

-- Puts the body where the idle, the motion and any hold say. Feet stay planted: the painted
-- model is resized about its own feet, a sketch is scaled about the model's pivot (its feet).
local function render(toy: Live, anim: number)
	local pose = REST
	local idle = true
	local frozen = toy.frozen
	-- A motion waits for the model to load, so that the entrance is seen on the model.
	local waiting = toy.act
	if toy.waiting and waiting then
		waiting.began = anim
	end
	if frozen then
		pose, idle = frozen, false
	else
		local act = toy.act
		if act then
			local t = (anim - act.began) / act.seconds
			if t >= 1 then
				pose = act.curve(1)
				toy.act = nil
				if act.keep then
					toy.frozen = pose
					toy.sunk = true
					idle = false
				end
			else
				pose = act.curve(t)
			end
		end
	end

	local held = toy.held
	if toy.heldSeconds > 0 then
		local alpha = math.clamp((anim - toy.heldBegan) / toy.heldSeconds, 0, 1)
		held = toy.heldFrom + (toy.heldTo - toy.heldFrom) * (alpha * alpha * (3 - 2 * alpha))
		toy.held = held
		if alpha >= 1 then
			toy.heldSeconds = 0
		end
	end

	-- Breathing is a change of scale, not a lift off the pad.
	local breathY, breathX, sway = 1, 1, 0
	if idle then
		breathY, breathX = Motion.breath(anim, toy.phase, toy.size)
		sway = math.rad(math.sin(anim * 1.1 + toy.phase * 2) * 4)
	end
	local squash = math.max(0.02, pose.sy)
	local tall = squash * breathY * held
	-- The volume stays the same unless the motion sets its own width (a puff, a swell).
	local wide = breathX * (pose.wide or 1 / math.sqrt(squash)) * held

	local aura = toy.aura
	local pivot = toy.home
			* CFrame.new(pose.side, pose.up, -pose.fwd)
			* CFrame.new(0, if aura then aura.lift else 0, 0)
			* CFrame.Angles(0, pose.yaw + sway + (if aura then aura.yaw else 0), 0)
			* CFrame.Angles(pose.pitch, 0, 0)
			* CFrame.Angles(0, 0, pose.roll)
		+ toy.offset

	local body = toy.body
	if body then
		local size = toy.baseSize * Vector3.new(wide, tall, wide)
		body.Size = size
		body.CFrame = pivot * CFrame.new(0, size.Y / 2, 0) * CFrame.Angles(0, math.rad(toy.turn), 0)
	else
		toy.model:PivotTo(pivot)
		-- A sketch cannot be stretched on one axis, so it takes the height scale evenly.
		local uniform = math.max(0.05, tall)
		if math.abs(uniform - toy.sketchScale) > SKETCH_SCALE_STEP then
			toy.sketchScale = uniform
			toy.model:ScaleTo(uniform)
		end
	end
	setFade(toy, pose.fade)
end

local function step()
	local now = os.clock()
	local elapsed = math.min(now - lastStep, 0.1)
	lastStep = now
	if now >= frozenUntil then
		animClock += elapsed
	end
	local camera = Workspace.CurrentCamera
	local eye = if camera then camera.CFrame.Position else Vector3.zero
	for _, toy in live do
		if toy.sunk then
			continue
		end
		if toy.inWorld then
			if (toy.home.Position - eye).Magnitude > ANIMATE_WITHIN then
				continue
			end
		else
			local gui = toy.gui
			if gui then
				if now >= toy.nextCheck then
					toy.nextCheck = now + SCREEN_CHECK_SECONDS
					toy.onScreen = onScreenNow(gui)
					local rate = toy.hz
					if not rate and gui:FindFirstAncestorWhichIsA("ScrollingFrame") then
						rate = LIST_HZ
					end
					toy.gap = if rate then 1 / rate else 0
				end
				if not toy.onScreen or now < toy.nextAt then
					continue
				end
				toy.nextAt = now + toy.gap
			end
		end
		if toy.waiting and now >= toy.waitUntil then
			toy.waiting = false
			paint(toy)
		end
		render(toy, animClock)
		-- An idle gesture, when nothing else is moving it (render has just cleared a finished act).
		local gesture = toy.gesture
		if
			gesture
			and not toy.still
			and not toy.act
			and not toy.frozen
			and not toy.ending
			and not toy.waiting
			and animClock >= toy.gestureAt
		then
			toy.act = {
				curve = gesture,
				seconds = toy.gestureSeconds,
				began = animClock,
				keep = false,
			}
			toy.gestureAt = animClock
				+ toy.gestureSeconds
				+ Gestures.nextIn(toy.gestureEvery, timing:NextNumber())
		end
		-- Blinking: the eyes are only written when they change.
		local closed = now >= toy.blinkAt
		if closed and now >= toy.blinkAt + 0.13 then
			toy.blinkAt = now + timing:NextNumber(2, 5.5)
			closed = false
		end
		if closed ~= toy.closed and not toy.sunk then
			toy.closed = closed
			for _, part in toy.eyes do
				toy.natural[part] = if closed then 1 else 0
			end
			for _, part in toy.lids do
				toy.natural[part] = if closed then 0 else 1
			end
			if not toy.body then
				paint(toy)
			end
		end
	end
end

local running = false
local function ensureRunning()
	if running then
		return
	end
	running = true
	RunService.RenderStepped:Connect(step)
end

-- Everything on the screen holds still for a moment, as when a blow lands. Looks only.
function ToyBody.hitStop(seconds: number)
	frozenUntil = math.max(frozenUntil, os.clock() + seconds)
end

-- Asks for a species' model ahead of time, so that it is ready when the creature is shown.
function ToyBody.preload(species: string)
	local wanted = CreatureModels[species]
	if wanted and not templates[species] and not failed[species] and not loading[species] then
		task.spawn(function()
			loadTemplate(species, wanted)
		end)
	end
end

-- `patience`: seconds to keep the sketch hidden while the species' model loads, so that a
-- creature does not appear as a sketch and then pop into its model.
function ToyBody.new(
	parent: Instance,
	species: string,
	element: Types.Element,
	size: number,
	patience: number?
): Toy
	local scale = math.clamp(size, 0.6, 1.8)
	local model = Instance.new("Model")
	model.Name = `Toy_{species}`
	local pieces = ToySketches.sketch(species, element)
	local eyes: { BasePart } = {}
	local lids: { BasePart } = {}
	local colours: { [BasePart]: Color3 } = {}
	local materials: { [BasePart]: Enum.Material } = {}
	local natural: { [BasePart]: number } = {}
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
		natural[part] = part.Transparency
	end
	-- The pieces were laid out around the world's origin, so that is the point between its
	-- feet: with it as the pivot, `place` can stand the creature on the ground.
	model.WorldPivot = CFrame.new()
	model.Parent = parent

	local wanted = CreatureModels[species]
	local now = os.clock()
	local patient = patience or 0
	local toy: Live = {
		model = model,
		home = CFrame.new(),
		offset = Vector3.zero,
		phase = timing:NextNumber(0, 6),
		size = scale,
		blinkAt = now + timing:NextNumber(1, 4),
		closed = false,
		eyes = eyes,
		lids = lids,
		natural = natural,
		sunk = false,
		ending = false,
		inWorld = parent:IsDescendantOf(Workspace),
		body = nil,
		aura = nil,
		baseSize = Vector3.one,
		turn = 0,
		act = nil,
		frozen = nil,
		held = 1,
		heldFrom = 1,
		heldTo = 1,
		heldBegan = 0,
		heldSeconds = 0,
		waiting = wanted ~= nil and patient > 0 and not templates[species] and not failed[species],
		waitUntil = now + patient,
		fade = 0,
		sketchScale = 1,
		gui = if parent:IsA("ViewportFrame") then parent else nil,
		onScreen = true,
		nextCheck = 0,
		gap = 0,
		nextAt = 0,
		hz = nil,
		gesture = nil,
		gestureSeconds = 1,
		gestureEvery = 8,
		gestureAt = math.huge,
		still = false,
	}
	local quirk = SpeciesQuirks[species]
	local shape = if quirk then Gestures.curve(quirk.gesture) else nil
	if quirk and shape then
		toy.gesture = Gestures.motionCurve(shape)
		toy.gestureSeconds = shape.seconds
		toy.gestureEvery = quirk.gestureEvery
		toy.gestureAt = animClock + Gestures.firstIn(quirk.gestureEvery, timing:NextNumber())
	end
	live[model] = toy
	model.Destroying:Once(function()
		live[model] = nil
	end)
	if toy.waiting then
		paint(toy)
	end
	ensureRunning()

	-- A species with a real model swaps its sketch for it as soon as the model has loaded.
	if wanted then
		task.spawn(function()
			local template = loadTemplate(species, wanted)
			toy.waiting = false
			if not template or model.Parent == nil then
				paint(toy)
				return
			end
			for part in colours do
				part:Destroy()
			end
			table.clear(colours)
			table.clear(materials)
			table.clear(natural)
			table.clear(eyes)
			table.clear(lids)
			local made = template:Clone()
			made.Size = template.Size * scale
			made.Parent = model
			colours[made], materials[made] = made.Color, made.Material
			toy.body = made
			toy.baseSize = made.Size
			toy.turn = wanted.turn or 0
			-- A mythic or giant wears its aura (in the world only: a viewport draws no particles).
			local preset = Aura.presetFor(species)
			if preset and toy.inWorld then
				toy.aura = Aura.apply(made, preset, element)
			end
			render(toy, animClock)
			paint(toy)
		end)
	end

	return {
		model = model,
		place = function(home: CFrame)
			toy.home = home
			render(toy, animClock)
		end,
		nudge = function(offset: Vector3)
			toy.offset = offset
		end,
		act = function(curve: Curve, seconds: number, keep: boolean?)
			if toy.ending then
				return
			end
			toy.ending = keep == true
			toy.act = {
				curve = curve,
				seconds = math.max(0.01, seconds),
				began = animClock,
				keep = keep == true,
			}
		end,
		hold = function(scaleTo: number, seconds: number)
			toy.heldFrom = toy.held
			toy.heldTo = scaleTo
			toy.heldBegan = animClock
			toy.heldSeconds = math.max(0.001, seconds)
		end,
		flash = function()
			local whole = toy.body
			if whole then
				-- A textured model keeps its paint; a white glow over it does the flash.
				local glow = Instance.new("Highlight")
				glow.FillColor = Color3.new(1, 1, 1)
				glow.FillTransparency = 0.1
				glow.OutlineTransparency = 1
				glow.Parent = whole
				task.delay(0.1, function()
					glow:Destroy()
				end)
				return
			end
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
			if toy.ending then
				return
			end
			toy.ending = true
			toy.act = {
				curve = Motion.curve(Motion.sink()),
				seconds = Motion.FAINT_SINK,
				began = animClock,
				keep = true,
			}
		end,
		gone = function(): boolean
			return toy.ending
		end,
		rate = function(hz: number?)
			toy.hz = hz
			toy.nextCheck = 0
		end,
		still = function(on: boolean)
			toy.still = on
		end,
		destroy = function()
			model:Destroy()
		end,
	}
end

return ToyBody
