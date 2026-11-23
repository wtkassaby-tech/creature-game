--!strict
-- An aura: the ethereal presence of a mythic or giant creature. A preset from config/AuraConfig is
-- turned into a light and a few particle emitters on the creature's body, and one Heartbeat for
-- all auras drives the slow hover, yaw sway and glow pulse. An aura far from the camera, or off
-- the screen, is switched off (checked a few times a second), so it costs nothing out of sight.
-- It goes when the model goes. Looks only, on the player's own device.
--
-- Two ways in: `apply` on a model or part (ToyBody uses it for a battle creature, and drives the
-- body's motion itself through `lift` and `yaw`), and any world model tagged "Aura" with an
-- "AuraPreset" attribute (and optionally "AuraElement"), which moves itself.

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local AuraConfig = require(ReplicatedStorage.config.AuraConfig)
local AuraMath = require(ReplicatedStorage.shared.AuraMath)

local Aura = {}

export type Handle = {
	lift: number, -- studs above rest right now
	yaw: number, -- radians of sway right now
	remove: () -> (),
}

type Live = {
	handle: Handle,
	target: PVInstance,
	body: BasePart,
	light: PointLight,
	emitters: { ParticleEmitter },
	preset: AuraConfig.Preset,
	phase: number,
	-- A model that moves itself (a tagged world model) keeps its rest pose here.
	home: CFrame?,
	active: boolean,
	nextCheck: number,
}

local TAG = "Aura"
local live: { [Live]: boolean } = {}
local connection: RBXScriptConnection? = nil
local seed = Random.new(7)

local function colourOf(rgb: { number }): Color3
	return Color3.fromRGB(rgb[1], rgb[2], rgb[3])
end

local function keypoints(list: { { number } }): ColorSequence
	local count = #list
	if count == 1 then
		return ColorSequence.new(colourOf(list[1]))
	end
	local points: { ColorSequenceKeypoint } = {}
	for index, rgb in list do
		table.insert(points, ColorSequenceKeypoint.new((index - 1) / (count - 1), colourOf(rgb)))
	end
	return ColorSequence.new(points)
end

local function colourFor(spec: AuraConfig.Emitter, element: string?): ColorSequence
	if spec.elements then
		local list: { { number } } = {}
		for _, name in AuraConfig.ELEMENT_ORDER do
			table.insert(list, AuraConfig.ELEMENT_COLOURS[name])
		end
		table.insert(list, AuraConfig.ELEMENT_COLOURS[AuraConfig.ELEMENT_ORDER[1]])
		return keypoints(list)
	elseif spec.tint then
		return keypoints({
			(element and AuraConfig.ELEMENT_COLOURS[element]) or AuraConfig.FALLBACK_TINT,
		})
	end
	return keypoints(spec.colours or { AuraConfig.FALLBACK_TINT })
end

local function emitterFor(spec: AuraConfig.Emitter, element: string?): ParticleEmitter
	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = `Aura_{spec.name}`
	emitter.Texture = spec.texture
	emitter.Color = colourFor(spec, element)
	emitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, spec.size[1]),
		NumberSequenceKeypoint.new(0.3, spec.size[2]),
		NumberSequenceKeypoint.new(1, spec.size[3]),
	})
	emitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.15, spec.opaque),
		NumberSequenceKeypoint.new(0.7, spec.opaque),
		NumberSequenceKeypoint.new(1, 1),
	})
	emitter.Rate = spec.rate
	emitter.Lifetime = NumberRange.new(spec.lifetime[1], spec.lifetime[2])
	emitter.Speed = NumberRange.new(spec.speed[1], spec.speed[2])
	emitter.SpreadAngle = Vector2.new(spec.spread, spec.spread)
	local accel = spec.accel
	emitter.Acceleration = if accel then Vector3.new(accel[1], accel[2], accel[3]) else Vector3.zero
	emitter.Drag = spec.drag or 0
	emitter.LightEmission = spec.lightEmission
	emitter.LightInfluence = 0
	emitter.Rotation = NumberRange.new(0, 360)
	local spin = spec.spin or 0
	emitter.RotSpeed = NumberRange.new(-spin, spin)
	-- Born anywhere inside the body's box, not from one point.
	emitter.Shape = Enum.ParticleEmitterShape.Box
	emitter.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
	emitter.Enabled = true
	return emitter
end

local function bodyOf(target: Instance): BasePart?
	if target:IsA("BasePart") then
		return target
	end
	if target:IsA("Model") and target.PrimaryPart then
		return target.PrimaryPart
	end
	for _, part in target:GetDescendants() do
		if part:IsA("MeshPart") then
			return part
		end
	end
	for _, part in target:GetDescendants() do
		if part:IsA("BasePart") then
			return part
		end
	end
	return nil
end

local function setActive(item: Live, on: boolean)
	if item.active == on then
		return
	end
	item.active = on
	item.light.Enabled = on
	for _, emitter in item.emitters do
		emitter.Enabled = on
	end
end

-- Near the camera and in front of it, with a margin for the size of the body.
local function shouldRun(item: Live, camera: Camera): boolean
	local position = item.body.Position
	local reach = item.body.Size.Magnitude * 0.5
	if (position - camera.CFrame.Position).Magnitude > AuraConfig.FAR + reach then
		return false
	end
	local _, onScreen = camera:WorldToViewportPoint(position)
	if onScreen then
		return true
	end
	-- Off the edge but big enough to reach in: keep it on while the camera is within its size.
	return (position - camera.CFrame.Position).Magnitude < reach * 1.5
end

local function frame()
	local now = os.clock()
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	for item in live do
		if now >= item.nextCheck then
			item.nextCheck = now + AuraConfig.CHECK_SECONDS + seed:NextNumber() * 0.05
			setActive(item, item.body.Parent ~= nil and shouldRun(item, camera))
		end
		if item.active then
			local preset = item.preset
			local handle = item.handle
			handle.lift =
				AuraMath.hoverOffset(now, item.phase, preset.hover.amplitude, preset.hover.period)
			handle.yaw = AuraMath.swayYaw(now, item.phase, preset.sway.degrees, preset.sway.period)
			item.light.Brightness = preset.light.brightness
				* AuraMath.pulse(now, item.phase, preset.pulse.depth, preset.pulse.period)
			local home = item.home
			if home then
				item.target:PivotTo(
					home * CFrame.new(0, handle.lift, 0) * CFrame.Angles(0, handle.yaw, 0)
				)
			end
		end
	end
end

local function ensureRunning()
	if not connection then
		connection = RunService.Heartbeat:Connect(frame)
	end
end

-- Puts a preset on `target` (a model or a part). `element` tints a preset that takes the
-- creature's own colour. With `selfMoving` the aura hovers and sways the target itself; otherwise
-- the owner reads `lift` and `yaw` from the handle and moves it (ToyBody does, each frame).
function Aura.apply(
	target: PVInstance,
	presetName: string,
	element: string?,
	selfMoving: boolean?
): Handle?
	local preset = AuraConfig.PRESETS[presetName]
	local body = bodyOf(target)
	if not preset or not body then
		warn(`[Aura] no preset or no body for {presetName} on {target:GetFullName()}`)
		return nil
	end
	local light = Instance.new("PointLight")
	light.Name = "AuraLight"
	light.Color = colourOf(preset.light.colour)
	light.Range = preset.light.range
	light.Brightness = preset.light.brightness
	light.Shadows = false
	light.Parent = body
	local emitters: { ParticleEmitter } = {}
	for _, spec in preset.emitters do
		local emitter = emitterFor(spec, element)
		emitter.Parent = body
		table.insert(emitters, emitter)
	end

	local item: Live
	local function remove()
		if not live[item] then
			return
		end
		live[item] = nil
		light:Destroy()
		for _, emitter in emitters do
			emitter:Destroy()
		end
		if item.home and target.Parent then
			item.target:PivotTo(item.home)
		end
		if next(live) == nil and connection then
			connection:Disconnect()
			connection = nil
		end
	end
	local handle: Handle = { lift = 0, yaw = 0, remove = remove }
	item = {
		handle = handle,
		target = target,
		body = body,
		light = light,
		emitters = emitters,
		preset = preset,
		phase = seed:NextNumber() * math.pi * 2,
		home = if selfMoving == true then target:GetPivot() else nil,
		active = true,
		nextCheck = 0,
	}
	live[item] = true
	target.Destroying:Once(remove)
	ensureRunning()
	return handle
end

-- The aura a species wears (a mythic, or a giant's form), or nil for an ordinary creature.
function Aura.presetFor(species: string): string?
	return AuraConfig.SPECIES[species]
end

-- World models tagged "Aura": their "AuraPreset" attribute names the preset.
local tagged: { [Instance]: Handle } = {}

local function onTagged(instance: Instance)
	if not instance:IsA("PVInstance") then
		return
	end
	local name = instance:GetAttribute("AuraPreset")
	if typeof(name) ~= "string" or tagged[instance] then
		return
	end
	local element = instance:GetAttribute("AuraElement")
	local handle =
		Aura.apply(instance, name, if typeof(element) == "string" then element else nil, true)
	if handle then
		tagged[instance] = handle
		instance.Destroying:Once(function()
			tagged[instance] = nil
		end)
	end
end

local function onUntagged(instance: Instance)
	local handle = tagged[instance]
	if handle then
		tagged[instance] = nil
		handle.remove()
	end
end

local watching = false

-- Starts watching for tagged world models. Safe to call twice; the module calls it itself.
function Aura.watchTagged()
	if watching then
		return
	end
	watching = true
	CollectionService:GetInstanceAddedSignal(TAG):Connect(onTagged)
	CollectionService:GetInstanceRemovedSignal(TAG):Connect(onUntagged)
	for _, instance in CollectionService:GetTagged(TAG) do
		task.defer(onTagged, instance)
	end
end

if RunService:IsClient() then
	Aura.watchTagged()
end

return Aura
