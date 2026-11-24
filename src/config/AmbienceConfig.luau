--!strict
-- The numbers behind the world's ambient particles and lights (docs/plans/11_STUDIO_POLISH.md,
-- package 2): what each kind of effect looks like, and how much one biome may ask of a phone.
-- Looks only: nothing here decides anything in play. Every value is a [Default] to tune by eye.
--
-- The rules for a glowing kind (Ayrton's particle video): LightEmission 1; Size is a curve that
-- starts small, peaks early (`peakAt`) and shrinks to nothing (`final` 0); Transparency starts at 1,
-- fades in by `fadeIn`, holds at `opaque`, fades out from `fadeOut` and ends at 1, so nothing pops.
-- A kind marked `soft` (smoke, dust, mist, spray, seed fluff) is the exception: low LightEmission,
-- slow and soft, free to end large. tests/ambience.test checks all of this.

local AmbienceConfig = {}

export type Look = {
	texture: string, -- the engine's own particle textures only
	colour: { number }, -- { r, g, b } at birth
	colour2: { number }, -- at the end of life
	lightEmission: number, -- 1 glows; soft kinds stay low
	soft: boolean, -- smoke, dust, mist, spray, fluff: the exception to the glow rules
	lifetime: { number }, -- seconds, { min, max }
	speed: { number }, -- studs per second, { min, max }
	spread: number, -- degrees either side of straight up (180: every way)
	accel: { number }, -- studs per second squared { x, y, z }: wind and buoyancy
	drag: number,
	size: { birth: number, peak: number, peakAt: number, final: number }, -- studs
	opaque: number, -- transparency while visible: lower is stronger
	fadeIn: number, -- fraction of life by which the particle has faded in
	fadeOut: number, -- fraction of life at which it starts to fade out
	rate: number, -- particles per second from one emitter, unless a source says otherwise
	lit: number, -- LightInfluence: how much the world's lighting tints it
	spin: number, -- RotSpeed, degrees per second either way
}

local SPARKLE = "rbxasset://textures/particles/sparkles_main.dds"
local SMOKE = "rbxasset://textures/particles/smoke_main.dds"

AmbienceConfig.KINDS = {
	-- Chimney smoke: slow, soft, grey, drifting on the wind.
	Smoke = {
		texture = SMOKE,
		-- A warm grey, a shade darker than the clouds, so it reads against a bright sky.
		colour = { 196, 192, 188 },
		colour2 = { 150, 148, 152 },
		lightEmission = 0.05,
		soft = true,
		lifetime = { 6, 8.5 },
		speed = { 2.2, 3.2 },
		spread = 8,
		accel = { 1.3, 0.6, 0.4 },
		drag = 0.25,
		size = { birth = 1, peak = 4.6, peakAt = 0.9, final = 5.4 },
		opaque = 0.38,
		fadeIn = 0.18,
		fadeOut = 0.5,
		rate = 1.4,
		lit = 0.7,
		spin = 12,
	},
	-- Embers rising from the kiln.
	Embers = {
		texture = SPARKLE,
		colour = { 255, 176, 72 },
		colour2 = { 255, 84, 30 },
		lightEmission = 1,
		soft = false,
		lifetime = { 2.2, 3.6 },
		speed = { 4, 7 },
		spread = 18,
		accel = { 0.8, 3.2, 0.4 },
		drag = 0.6,
		size = { birth = 0.12, peak = 0.5, peakAt = 0.2, final = 0 },
		opaque = 0,
		fadeIn = 0.12,
		fadeOut = 0.55,
		rate = 7,
		lit = 0,
		spin = 90,
	},
	-- The faint halo round a lantern: one big slow glow, barely there.
	Halo = {
		texture = SPARKLE,
		colour = { 255, 208, 132 },
		colour2 = { 255, 190, 110 },
		lightEmission = 1,
		soft = false,
		lifetime = { 3.6, 4.4 },
		speed = { 0, 0 },
		spread = 180,
		accel = { 0, 0, 0 },
		drag = 0,
		size = { birth = 1, peak = 5.5, peakAt = 0.3, final = 0 },
		opaque = 0.8,
		fadeIn = 0.3,
		fadeOut = 0.6,
		rate = 0.55,
		lit = 0,
		spin = 0,
	},
	-- Pollen over a meadow: tiny warm specks drifting on the breeze.
	Pollen = {
		texture = SPARKLE,
		colour = { 255, 232, 140 },
		colour2 = { 255, 214, 110 },
		lightEmission = 1,
		soft = false,
		lifetime = { 6, 9 },
		speed = { 0.4, 1 },
		spread = 180,
		accel = { 0.8, 0.15, 0.3 },
		drag = 0.2,
		size = { birth = 0.05, peak = 0.24, peakAt = 0.25, final = 0 },
		opaque = 0.25,
		fadeIn = 0.2,
		fadeOut = 0.6,
		rate = 3,
		lit = 0,
		spin = 40,
	},
	-- Seed fluff: soft white puffs, slower and bigger than pollen.
	Fluff = {
		texture = SPARKLE,
		colour = { 255, 255, 248 },
		colour2 = { 244, 246, 236 },
		lightEmission = 0.6,
		soft = true,
		lifetime = { 8, 11 },
		speed = { 0.8, 1.6 },
		spread = 180,
		accel = { 1.4, 0.1, 0.6 },
		drag = 0.3,
		size = { birth = 0.1, peak = 0.46, peakAt = 0.3, final = 0.08 },
		opaque = 0.2,
		fadeIn = 0.2,
		fadeOut = 0.65,
		rate = 2,
		lit = 0.4,
		spin = 30,
	},
	-- Dust motes in the canyon's light.
	Dust = {
		texture = SMOKE,
		colour = { 236, 204, 154 },
		colour2 = { 214, 176, 128 },
		lightEmission = 0.15,
		soft = true,
		lifetime = { 8, 12 },
		speed = { 0.5, 1.2 },
		spread = 180,
		accel = { 1.8, 0.1, 0.4 },
		drag = 0.3,
		size = { birth = 0.3, peak = 1, peakAt = 0.4, final = 0.6 },
		opaque = 0.78,
		fadeIn = 0.25,
		fadeOut = 0.6,
		rate = 2.5,
		lit = 0.6,
		spin = 20,
	},
	-- Sea spray thrown up where the water meets the shore.
	Spray = {
		texture = SPARKLE,
		colour = { 244, 252, 255 },
		colour2 = { 200, 228, 242 },
		lightEmission = 0.4,
		soft = true,
		lifetime = { 2, 3.5 },
		speed = { 3, 6 },
		spread = 30,
		accel = { 2, -3, 1 },
		drag = 0.4,
		size = { birth = 0.15, peak = 0.6, peakAt = 0.3, final = 0.2 },
		opaque = 0.35,
		fadeIn = 0.15,
		fadeOut = 0.5,
		rate = 4,
		lit = 0.3,
		spin = 60,
	},
	-- Sea mist lying low over the water: huge, faint, nearly still.
	Mist = {
		texture = SMOKE,
		colour = { 228, 240, 246 },
		colour2 = { 214, 230, 240 },
		lightEmission = 0.05,
		soft = true,
		lifetime = { 10, 14 },
		speed = { 0.4, 0.9 },
		spread = 180,
		accel = { 1, 0, 0.3 },
		drag = 0.3,
		size = { birth = 8, peak = 18, peakAt = 0.5, final = 22 },
		opaque = 0.88,
		fadeIn = 0.3,
		fadeOut = 0.55,
		rate = 0.5,
		lit = 0.8,
		spin = 4,
	},
	-- A slow glint on water: a tiny star that opens and closes.
	Glint = {
		texture = SPARKLE,
		colour = { 255, 255, 255 },
		colour2 = { 200, 236, 255 },
		lightEmission = 1,
		soft = false,
		lifetime = { 1.6, 2.6 },
		speed = { 0, 0 },
		spread = 180,
		accel = { 0, 0, 0 },
		drag = 0,
		size = { birth = 0.1, peak = 0.9, peakAt = 0.35, final = 0 },
		opaque = 0.15,
		fadeIn = 0.3,
		fadeOut = 0.6,
		rate = 1.5,
		lit = 0,
		spin = 0,
	},
} :: { [string]: Look }

-- A biome's budget, so phones stay smooth. Counted from its dressing sheet by shared/AmbiencePlan:
-- emitters (ParticleEmitters), rate (their combined particles per second), live (the particles
-- alive at once: rate times mean lifetime) and lights (PointLights). A biome over any of these
-- fails tests/ambience.test.
AmbienceConfig.BUDGET = {
	MAX_EMITTERS = 64,
	MAX_RATE = 110,
	MAX_LIVE = 520,
	MAX_LIGHTS = 40,
}

-- A PointLight's range cannot pass 60 studs; one lamp's glow is warm and small.
AmbienceConfig.MAX_LIGHT_RANGE = 60
AmbienceConfig.DEFAULT_LIGHT_COLOUR = { 255, 200, 130 }
AmbienceConfig.LAMP_HEIGHT = 11.2 -- studs above the foot of a lamp post: the lantern
AmbienceConfig.CHIMNEY_SMOKE_HEIGHT_GAP = 0.6 -- studs above the chimney pot the smoke starts

-- Glints on water: a flat's glint zone is at most this big, near the hub; the rate follows its
-- area, one glint per second for each GLINT_AREA studs squared, between the limits.
AmbienceConfig.GLINT_MAX_ZONE = 160
AmbienceConfig.GLINT_AREA = 4000
AmbienceConfig.GLINT_MIN_RATE = 0.6
AmbienceConfig.GLINT_MAX_RATE = 3
AmbienceConfig.GLINT_HEIGHT = 0.7 -- studs above the water
AmbienceConfig.GLINT_POOL_RATE = 0.8

-- How much a lit emitter's rate and lifetime vary between emitters, so no two breathe together.
AmbienceConfig.RATE_JITTER = 0.15

return AmbienceConfig
