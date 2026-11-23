--!strict
-- The numbers behind an aura: the ethereal presence of a mythic or giant creature (the Firstling
-- pass, 23 November 2026). Data only; looks only, nothing here decides anything in play.
-- Every value is a [Default] to tune by eye. Colours are { r, g, b } in 0..255.
--
-- A preset has a light, a hover/sway/pulse motion and a few particle emitters. Emitters use the
-- engine's own particle textures only. A preset must stay inside PARTICLE_BUDGET live particles
-- (rate x longest lifetime, summed over its emitters; tests/aura.test checks it) so phones stay smooth.

local AuraConfig = {}

export type Rgb = { number }

export type Light = {
	colour: Rgb,
	range: number, -- studs
	brightness: number, -- the resting brightness
}

export type Emitter = {
	name: string,
	texture: string,
	-- Born anywhere inside the model's box. One colour, or a list spread along the particle's life. `elements` cycles the ten element
	-- colours instead (rare sparks), and `tint` takes the creature's own element colour.
	colours: { Rgb }?,
	elements: boolean?,
	tint: boolean?,
	size: { number }, -- { birth, peak, end } in studs
	rate: number, -- particles per second
	lifetime: { number }, -- seconds { min, max }
	speed: { number }, -- studs per second { min, max }
	spread: number, -- degrees either side of straight up (180: every way)
	accel: { number }?, -- studs per second squared { x, y, z }
	drag: number?,
	lightEmission: number,
	opaque: number, -- transparency while visible; lower is stronger
	spin: number?, -- RotSpeed, degrees per second either way
}

export type Preset = {
	light: Light,
	hover: { amplitude: number, period: number }, -- studs, seconds
	sway: { degrees: number, period: number }, -- gentle yaw
	pulse: { depth: number, period: number }, -- share of the light's brightness
	emitters: { Emitter },
}

AuraConfig.PARTICLE_BUDGET = 30 -- live particles from one aura, at most
AuraConfig.FAR = 140 -- studs from the camera past which an aura is switched off
AuraConfig.CHECK_SECONDS = 0.25 -- seconds between checks of distance and visibility

local SPARKLE = "rbxasset://textures/particles/sparkles_main.dds"
local SMOKE = "rbxasset://textures/particles/smoke_main.dds"

-- The ten elements' colours, for the Firstling's cycling sparks and a giant's own glow.
AuraConfig.ELEMENT_COLOURS = {
	Leaf = { 120, 200, 90 },
	Sand = { 232, 196, 110 },
	Water = { 80, 160, 235 },
	Toxic = { 160, 90, 200 },
	Frost = { 170, 225, 245 },
	Crystal = { 150, 230, 220 },
	Fire = { 240, 120, 50 },
	Storm = { 250, 225, 80 },
	Arcane = { 190, 110, 240 },
	Cosmic = { 120, 110, 255 },
} :: { [string]: Rgb }
AuraConfig.ELEMENT_ORDER = {
	"Leaf",
	"Sand",
	"Water",
	"Toxic",
	"Frost",
	"Crystal",
	"Fire",
	"Storm",
	"Arcane",
	"Cosmic",
}
AuraConfig.FALLBACK_TINT = { 255, 236, 190 }

AuraConfig.PRESETS = {
	Firstling = {
		light = { colour = { 255, 205, 110 }, range = 26, brightness = 1.6 },
		hover = { amplitude = 0.45, period = 5.5 },
		sway = { degrees = 3, period = 9 },
		pulse = { depth = 0.35, period = 4 },
		emitters = {
			{
				name = "Motes",
				texture = SPARKLE,
				colours = { { 255, 236, 170 }, { 255, 200, 90 } },
				size = { 0.2, 0.5, 0 },
				rate = 4,
				lifetime = { 3.5, 5 },
				speed = { 1, 2.2 },
				spread = 40,
				accel = { 0, 0.6, 0 },
				drag = 0.4,
				lightEmission = 1,
				opaque = 0.2,
			},
			{
				name = "ElementSparks",
				texture = SPARKLE,
				elements = true,
				size = { 0.3, 0.8, 0 },
				rate = 0.6,
				lifetime = { 3, 4 },
				speed = { 1.5, 3 },
				spread = 180,
				drag = 0.5,
				lightEmission = 1,
				opaque = 0.05,
				spin = 90,
			},
			{
				name = "ThreadWisps",
				texture = SMOKE,
				colours = { { 255, 214, 120 }, { 255, 190, 80 } },
				size = { 0.6, 1.8, 2.4 },
				rate = 0.9,
				lifetime = { 5, 7 },
				speed = { 0.5, 1.1 },
				spread = 180,
				accel = { 0.4, 0.2, 0 },
				drag = 0.6,
				lightEmission = 0.8,
				opaque = 0.55,
				spin = 20,
			},
		},
	},
	Halcyre = {
		light = { colour = { 130, 100, 240 }, range = 22, brightness = 1.3 },
		hover = { amplitude = 0.35, period = 6 },
		sway = { degrees = 2.5, period = 10 },
		pulse = { depth = 0.3, period = 5 },
		emitters = {
			{
				name = "Constellation",
				texture = SPARKLE,
				colours = { { 235, 235, 255 }, { 150, 130, 255 } },
				size = { 0.15, 0.45, 0 },
				rate = 3,
				lifetime = { 1.5, 3 },
				speed = { 0.2, 0.8 },
				spread = 180,
				drag = 1,
				lightEmission = 1,
				opaque = 0.1,
				spin = 40,
			},
			{
				name = "Nebula",
				texture = SMOKE,
				colours = { { 90, 70, 200 }, { 170, 90, 220 } },
				size = { 1, 2.4, 3.2 },
				rate = 1.1,
				lifetime = { 5, 7 },
				speed = { 0.3, 0.8 },
				spread = 180,
				drag = 0.7,
				lightEmission = 0.7,
				opaque = 0.6,
				spin = 12,
			},
		},
	},
	-- A giant: a subtle glow in its own element's colour, and a little dust. It stays on the ground.
	Giant = {
		light = { colour = { 255, 236, 190 }, range = 16, brightness = 0.7 },
		hover = { amplitude = 0, period = 6 },
		sway = { degrees = 0, period = 10 },
		pulse = { depth = 0.2, period = 5 },
		emitters = {
			{
				name = "Glow",
				texture = SPARKLE,
				tint = true,
				size = { 0.2, 0.5, 0 },
				rate = 2,
				lifetime = { 2.5, 3.5 },
				speed = { 0.6, 1.4 },
				spread = 50,
				accel = { 0, 0.4, 0 },
				drag = 0.5,
				lightEmission = 1,
				opaque = 0.25,
			},
			{
				name = "Dust",
				texture = SMOKE,
				colours = { { 200, 190, 170 } },
				size = { 0.6, 1.6, 2 },
				rate = 1.2,
				lifetime = { 3.5, 5 },
				speed = { 0.4, 1 },
				spread = 70,
				accel = { 0.3, 0.15, 0 },
				drag = 0.8,
				lightEmission = 0.05,
				opaque = 0.7,
			},
		},
	},
} :: { [string]: Preset }

-- Which species wears which aura: the mythics, and every giant's own form.
AuraConfig.SPECIES = {
	Firstling = "Firstling",
	Halcyre = "Halcyre",
	Hollowbough = "Giant",
	Mesalith = "Giant",
	Carrackon = "Giant",
	Sloughback = "Giant",
} :: { [string]: string }

return AuraConfig
