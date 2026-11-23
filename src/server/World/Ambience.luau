--!strict
-- Ambient particles and lights for a designed biome: chimney smoke, the kiln's embers and glow,
-- a warm light and faint halo on every lamp, motes drifting over meadows, wash and shore, and a
-- slow glint on water (docs/plans/11_STUDIO_POLISH.md, package 2). What goes where is data: the
-- biome's dressing sheet (`ambience`), worked out by shared/AmbiencePlan; how each kind looks is
-- in config/AmbienceConfig. Built on the server, so every player sees it; looks only, it decides
-- nothing. Each effect is an invisible anchored part carrying a ParticleEmitter and/or PointLight.
--
-- Particle rules (the owner's video): glowing kinds use LightEmission 1; Size is a curve that
-- starts small, peaks early and shrinks to nothing; Transparency fades in and out so nothing
-- pops. Smoke, dust, mist, spray and fluff keep LightEmission low and stay soft.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AmbienceConfig = require(ReplicatedStorage.config.AmbienceConfig)
local AmbiencePlan = require(ReplicatedStorage.shared.AmbiencePlan)
local Layout = require(ReplicatedStorage.shared.Layout)
local WorldTypes = require(ReplicatedStorage.shared.WorldTypes)

local Ambience = {}

local function colour(values: { number }): Color3
	return Color3.fromRGB(values[1], values[2], values[3])
end

-- Size: small at birth, biggest at `peakAt`, then down to `final` (nothing, for a glowing kind).
local function sizeCurve(look: AmbienceConfig.Look, scale: number): NumberSequence
	local size = look.size
	local peakAt = math.clamp(size.peakAt, 0.05, 0.95)
	return NumberSequence.new({
		NumberSequenceKeypoint.new(0, size.birth * scale),
		NumberSequenceKeypoint.new(peakAt, size.peak * scale),
		NumberSequenceKeypoint.new(1, size.final * scale),
	})
end

-- Transparency: fully clear at birth, fades in, holds, fades out to clear again.
local function fadeCurve(look: AmbienceConfig.Look): NumberSequence
	local fadeIn = math.clamp(look.fadeIn, 0.01, 0.45)
	local fadeOut = math.clamp(look.fadeOut, fadeIn + 0.05, 0.99)
	return NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(fadeIn, look.opaque),
		NumberSequenceKeypoint.new(fadeOut, look.opaque),
		NumberSequenceKeypoint.new(1, 1),
	})
end

local function emitter(
	node: BasePart,
	spec: AmbiencePlan.Spec,
	look: AmbienceConfig.Look,
	pick: Random
)
	local made = Instance.new("ParticleEmitter")
	made.Name = spec.kind
	made.Texture = look.texture
	made.Color = ColorSequence.new(colour(look.colour), colour(look.colour2))
	made.LightEmission = look.lightEmission
	made.LightInfluence = look.lit
	made.Size = sizeCurve(look, spec.scale)
	made.Transparency = fadeCurve(look)
	-- Emitters differ a little, so no two chimneys or lamps breathe in step.
	local jitter = AmbienceConfig.RATE_JITTER
	made.Rate = spec.rate * (1 + pick:NextNumber(-jitter, jitter))
	made.Lifetime =
		NumberRange.new(look.lifetime[1] * (1 + pick:NextNumber(-jitter, jitter)), look.lifetime[2])
	made.Speed = NumberRange.new(look.speed[1], look.speed[2])
	made.SpreadAngle = Vector2.new(look.spread, look.spread)
	made.Acceleration = Vector3.new(look.accel[1], look.accel[2], look.accel[3])
	made.Drag = look.drag
	made.Rotation = NumberRange.new(0, 360)
	made.RotSpeed = NumberRange.new(-look.spin, look.spin)
	made.EmissionDirection = Enum.NormalId.Top
	made.Shape = Enum.ParticleEmitterShape.Box
	made.LockedToPart = false
	made.Enabled = true
	made.Parent = node
end

local function light(node: BasePart, setting: WorldTypes.AmbienceLight)
	local made = Instance.new("PointLight")
	made.Range = math.min(setting.range, AmbienceConfig.MAX_LIGHT_RANGE)
	made.Brightness = setting.brightness
	made.Color = colour(setting.colour or AmbienceConfig.DEFAULT_LIGHT_COLOUR)
	made.Shadows = false
	made.Parent = node
end

-- Builds a biome's ambience under `parent`, in a folder called "Ambience". Does nothing for a
-- biome whose sheet declares none.
function Ambience.build(parent: Instance, map: Layout.Map, dressing: WorldTypes.DressingSheet)
	local specs = AmbiencePlan.plan(dressing)
	if #specs == 0 then
		return
	end
	local folder = Instance.new("Folder")
	folder.Name = "Ambience"
	folder.Parent = parent
	local pick = Random.new(math.floor(map.hub.x) * 31 + math.floor(map.hub.z) * 17 + 5)
	for _, spec in specs do
		local look = AmbienceConfig.KINDS[spec.kind]
		if not look then
			warn(`[Ambience] unknown kind {spec.kind}`)
			continue
		end
		local node = Instance.new("Part")
		node.Name = spec.label
		node.Anchored = true
		node.Transparency = 1
		node.CanCollide = false
		node.CanQuery = false
		node.CanTouch = false
		node.CastShadow = false
		node.Size = Vector3.new(
			math.max(spec.width, 0.2),
			math.max(spec.thick, 0.2),
			math.max(spec.depth, 0.2)
		)
		node.CFrame = CFrame.new(map.hub.x + spec.x, spec.y, map.hub.z + spec.z)
		node.Parent = folder
		if spec.rate > 0 then
			emitter(node, spec, look, pick)
		end
		if spec.light then
			light(node, spec.light)
		end
	end
end

return Ambience
