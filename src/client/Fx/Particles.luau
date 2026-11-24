--!strict
-- Particle presets, built to three rules so effects look finished:
--   1. Glowing effects use LightEmission 1 (additive blend), so they shine even in shade. Smoke
--      and dust keep it near 0 so they stay soft.
--   2. Size is a curve: small at birth, biggest early, shrinking to nothing.
--   3. Transparency fades in at the start and out at the end, so a particle never pops on or off.
-- Only the engine's own particle textures are used (rbxasset://textures/particles/...).
-- Looks only: nothing here decides anything. Bursts sit on a short-lived part and clean up after
-- themselves, so a battle's effects are gone when its folder is.

local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local Particles = {}

export type Kind =
	"sparkle"
	| "glowPuff"
	| "smokePuff"
	| "dustKick"
	| "droplets"
	| "leafFlutter"
	| "ember"
	| "flame"
	| "toxicBubble"
	| "starBurst"
	| "motes"

type Spec = {
	texture: string,
	glow: number, -- LightEmission: 1 shines, near 0 stays soft
	peak: number, -- biggest size, in studs
	life: NumberRange,
	speed: NumberRange,
	spread: number, -- degrees around the emission direction (up)
	accel: Vector3,
	drag: number,
	spin: number, -- most it turns in a second, either way
	disc: boolean?, -- born across a flat disc as wide as the part, not at one point
}

local SPARKLES = "rbxasset://textures/particles/sparkles_main.dds"
local SMOKE = "rbxasset://textures/particles/smoke_main.dds"
local FIRE = "rbxasset://textures/particles/fire_main.dds"

local SPECS: { [string]: Spec } = {
	sparkle = {
		texture = SPARKLES,
		glow = 1,
		peak = 0.9,
		life = NumberRange.new(0.45, 0.8),
		speed = NumberRange.new(5, 11),
		spread = 180,
		accel = Vector3.new(0, -4, 0),
		drag = 2,
		spin = 90,
	},
	glowPuff = {
		texture = SMOKE,
		glow = 1,
		peak = 3.4,
		life = NumberRange.new(0.4, 0.65),
		speed = NumberRange.new(1, 3),
		spread = 180,
		accel = Vector3.zero,
		drag = 2,
		spin = 40,
	},
	smokePuff = {
		texture = SMOKE,
		glow = 0,
		peak = 3,
		life = NumberRange.new(0.8, 1.2),
		speed = NumberRange.new(1, 3),
		spread = 60,
		accel = Vector3.new(0, 1.5, 0),
		drag = 2,
		spin = 30,
	},
	dustKick = {
		texture = SMOKE,
		glow = 0.05,
		peak = 2.6,
		life = NumberRange.new(0.6, 1),
		speed = NumberRange.new(5, 9),
		spread = 80,
		accel = Vector3.new(0, -2, 0),
		drag = 3,
		spin = 30,
	},
	droplets = {
		texture = SPARKLES,
		glow = 0.7,
		peak = 0.65,
		life = NumberRange.new(0.5, 0.8),
		speed = NumberRange.new(10, 18),
		spread = 55,
		accel = Vector3.new(0, -45, 0),
		drag = 0,
		spin = 0,
	},
	leafFlutter = {
		texture = SPARKLES,
		glow = 0.3,
		peak = 1,
		life = NumberRange.new(0.9, 1.4),
		speed = NumberRange.new(4, 9),
		spread = 180,
		accel = Vector3.new(0, -3, 0),
		drag = 1.5,
		spin = 360,
	},
	ember = {
		texture = SMOKE,
		glow = 1,
		peak = 0.6,
		life = NumberRange.new(0.9, 1.5),
		speed = NumberRange.new(2, 5),
		spread = 35,
		accel = Vector3.new(0, 5, 0),
		drag = 1,
		spin = 0,
	},
	flame = {
		texture = FIRE,
		glow = 1,
		peak = 2.4,
		life = NumberRange.new(0.35, 0.6),
		speed = NumberRange.new(1, 4),
		spread = 40,
		accel = Vector3.new(0, 4, 0),
		drag = 2,
		spin = 60,
	},
	toxicBubble = {
		texture = SMOKE,
		glow = 0.4,
		peak = 1.3,
		life = NumberRange.new(0.8, 1.3),
		speed = NumberRange.new(2, 5),
		spread = 45,
		accel = Vector3.new(0, 3, 0),
		drag = 1.5,
		spin = 20,
	},
	starBurst = {
		texture = SPARKLES,
		glow = 1,
		peak = 1.7,
		life = NumberRange.new(0.5, 0.9),
		speed = NumberRange.new(14, 24),
		spread = 180,
		accel = Vector3.zero,
		drag = 4,
		spin = 120,
	},
	motes = {
		texture = SPARKLES,
		glow = 1,
		peak = 0.55,
		life = NumberRange.new(1.2, 1.9),
		speed = NumberRange.new(2, 5),
		spread = 12,
		accel = Vector3.new(0, 2, 0),
		drag = 0.5,
		spin = 60,
		disc = true,
	},
}

local WHITE = Color3.new(1, 1, 1)
local BLACK = Color3.new(0, 0, 0)

local function colourCurve(colour: Color3, soft: boolean): ColorSequence
	if soft then
		return ColorSequence.new(colour)
	end
	-- Bright at birth, true colour in the middle, dimmer as it goes (additive: dimmer is fainter).
	return ColorSequence.new({
		ColorSequenceKeypoint.new(0, colour:Lerp(WHITE, 0.55)),
		ColorSequenceKeypoint.new(0.4, colour),
		ColorSequenceKeypoint.new(1, colour:Lerp(BLACK, 0.35)),
	})
end

local function sizeCurve(peak: number): NumberSequence
	return NumberSequence.new({
		NumberSequenceKeypoint.new(0, peak * 0.15),
		NumberSequenceKeypoint.new(0.22, peak),
		NumberSequenceKeypoint.new(1, 0),
	})
end

local function fadeCurve(soft: boolean): NumberSequence
	if soft then
		return NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.15, 0.45),
			NumberSequenceKeypoint.new(0.55, 0.65),
			NumberSequenceKeypoint.new(1, 1),
		})
	end
	return NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.12, 0.05),
		NumberSequenceKeypoint.new(0.55, 0.3),
		NumberSequenceKeypoint.new(1, 1),
	})
end

-- A small invisible part the effect sits on. Not queryable, so it never gets in the way.
local function anchorPart(parent: Instance, at: Vector3, width: number): Part
	local part = Instance.new("Part")
	part.Name = "Fx"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Transparency = 1
	part.Size = Vector3.new(width, 0.2, width)
	part.CFrame = CFrame.new(at)
	part.Parent = parent
	return part
end

-- A finished emitter, switched off with no rate: the caller emits from it or turns it on.
-- `scale` makes it bigger or smaller as a whole.
function Particles.emitter(
	parent: Instance,
	kind: Kind,
	colour: Color3,
	scale: number?
): ParticleEmitter
	local spec = SPECS[kind]
	local soft = spec.glow < 0.5
	local made = Instance.new("ParticleEmitter")
	made.Texture = spec.texture
	made.LightEmission = spec.glow
	made.LightInfluence = if soft then 0.7 else 0
	made.Color = colourCurve(colour, soft)
	made.Size = sizeCurve(spec.peak * (scale or 1))
	made.Transparency = fadeCurve(soft)
	made.Lifetime = spec.life
	made.Speed = spec.speed
	made.SpreadAngle = Vector2.new(spec.spread, spec.spread)
	made.Acceleration = spec.accel
	made.Drag = spec.drag
	made.Rotation = NumberRange.new(0, 360)
	made.RotSpeed = NumberRange.new(-spec.spin, spec.spin)
	if spec.disc then
		made.Shape = Enum.ParticleEmitterShape.Disc
		made.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
	end
	made.Rate = 0
	made.Enabled = false
	made.Parent = parent
	return made
end

-- One short burst of `count` particles at a point; the part is cleared away after the longest
-- particle has gone. `width` spreads the birth point across a disc for the kinds that use one.
function Particles.burst(
	parent: Instance,
	at: Vector3,
	kind: Kind,
	colour: Color3,
	count: number,
	scale: number?,
	width: number?
)
	local part = anchorPart(parent, at, width or 1)
	local made = Particles.emitter(part, kind, colour, scale)
	made:Emit(count)
	Debris:AddItem(part, SPECS[kind].life.Max + 0.4)
end

-- A moving source: a part that leaves a trail while the caller moves it, then `stop` ends it.
function Particles.stream(
	parent: Instance,
	at: Vector3,
	kind: Kind,
	colour: Color3,
	rate: number,
	scale: number?
): Part
	local part = anchorPart(parent, at, 1)
	local made = Particles.emitter(part, kind, colour, scale)
	made.Speed = NumberRange.new(0.4, 2.4) -- a trail, not a spray
	made.Rate = rate
	made.Enabled = true
	return part
end

function Particles.stop(part: Part, kind: Kind)
	for _, child in part:GetChildren() do
		if child:IsA("ParticleEmitter") then
			child.Enabled = false
		end
	end
	Debris:AddItem(part, SPECS[kind].life.Max + 0.4)
end

-- A flat ring on the ground that grows outward and fades: a shockwave. Made from a thin invisible
-- part with a circle outline drawn on its top face, so it needs no picture.
function Particles.ring(
	parent: Instance,
	at: Vector3,
	colour: Color3,
	radius: number,
	seconds: number
)
	local part = Instance.new("Part")
	part.Name = "FxRing"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Transparency = 1
	part.Size = Vector3.new(radius * 0.3, 0.05, radius * 0.3)
	part.CFrame = CFrame.new(at + Vector3.yAxis * 0.25)
	local face = Instance.new("SurfaceGui")
	face.Face = Enum.NormalId.Top
	face.CanvasSize = Vector2.new(256, 256)
	face.LightInfluence = 0
	face.Brightness = 3 -- additive-bright, so the ring glows
	face.Parent = part
	local circle = Instance.new("Frame")
	circle.Size = UDim2.fromScale(1, 1)
	circle.BackgroundTransparency = 1
	circle.Parent = face
	local round = Instance.new("UICorner")
	round.CornerRadius = UDim.new(0.5, 0)
	round.Parent = circle
	local line = Instance.new("UIStroke")
	line.Color = colour:Lerp(WHITE, 0.4)
	line.Thickness = 12
	line.Transparency = 1
	line.Parent = circle
	part.Parent = parent

	-- Fades in over the first fifth, then out, while it grows (rule 3 again).
	local grow = TweenInfo.new(seconds, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(part, grow, { Size = Vector3.new(radius * 2, 0.05, radius * 2) }):Play()
	local fadeIn = TweenInfo.new(seconds * 0.2, Enum.EasingStyle.Quad)
	local fadeOut = TweenInfo.new(seconds * 0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	local appear = TweenService:Create(line, fadeIn, { Transparency = 0.1 })
	appear.Completed:Once(function()
		if line.Parent then
			TweenService:Create(line, fadeOut, { Transparency = 1 }):Play()
		end
	end)
	appear:Play()
	Debris:AddItem(part, seconds + 0.2)
end

return Particles
