--!strict
-- Light, sky and sound presets for the world, and the numbers the client blender uses
-- (docs/plans/13_WORLD_DESIGN.md section 9). Looks only: nothing here decides anything in play.
-- Every value is a [Default] to tune by screenshot. Colours are { r, g, b } in 0 to 255.
-- A preset's id is its biome's id (so a biome's zone needs no extra mapping); side areas add ids.
-- Greenwood is exactly what the server sets at start (src/server/World/Dressing.mood), so the
-- first frame has no jump.

local ClimateConfig = {}

export type Colour = { number }
export type Preset = {
	clockTime: number, -- hours, 0 to 24
	brightness: number,
	exposure: number, -- Lighting.ExposureCompensation
	ambient: Colour,
	outdoorAmbient: Colour,
	shiftTop: Colour, -- ColorShift_Top
	shiftBottom: Colour, -- ColorShift_Bottom
	air: {
		density: number,
		offset: number,
		haze: number,
		glare: number,
		color: Colour,
		decay: Colour,
	},
	grade: { tint: Colour, saturation: number, contrast: number },
	bloom: { intensity: number, size: number, threshold: number },
	rays: { intensity: number, spread: number },
	clouds: { cover: number, density: number, color: Colour },
	-- A Sky to show here: its six faces' asset ids, or nil to keep whatever is already up (the
	-- launch three share one sky until the sky assets are made; docs/ASSETS.md).
	sky: { [string]: string }?,
	-- The ambient bed: a looping sound that fades in with this preset's weight. An empty id is a
	-- bed still to be chosen (a sound has to be listened to first), and is skipped.
	bed: { soundId: string, volume: number },
}

local PRESETS: { [string]: Preset } = {
	greenwood = {
		clockTime = 16.6,
		brightness = 2.6,
		exposure = -0.1,
		ambient = { 122, 108, 100 },
		outdoorAmbient = { 150, 138, 124 },
		shiftTop = { 255, 214, 160 },
		shiftBottom = { 110, 96, 140 },
		air = {
			density = 0.3,
			offset = 0.2,
			haze = 0.8,
			glare = 0.2,
			color = { 255, 228, 196 },
			decay = { 176, 144, 150 },
		},
		grade = { tint = { 255, 242, 222 }, saturation = 0.08, contrast = 0.1 },
		bloom = { intensity = 0.3, size = 24, threshold = 1.2 },
		rays = { intensity = 0.06, spread = 0.6 },
		clouds = { cover = 0.55, density = 0.6, color = { 255, 255, 255 } },
		bed = { soundId = "rbxassetid://9116969794", volume = 0.35 }, -- "Morning Birds 5 (SFX)"
	},
	-- Afternoon gold gives way to bright, hot white: higher sun, harder haze, thinner cloud.
	dust_canyon = {
		clockTime = 15.8,
		brightness = 3.0,
		exposure = -0.05,
		ambient = { 138, 112, 88 },
		outdoorAmbient = { 170, 140, 110 },
		shiftTop = { 255, 200, 140 },
		shiftBottom = { 120, 90, 100 },
		air = {
			density = 0.28,
			offset = 0.15,
			haze = 1.2,
			glare = 0.4,
			color = { 255, 214, 170 },
			decay = { 200, 140, 110 },
		},
		grade = { tint = { 255, 236, 210 }, saturation = 0.1, contrast = 0.1 },
		bloom = { intensity = 0.35, size = 24, threshold = 1.2 },
		rays = { intensity = 0.08, spread = 0.6 },
		clouds = { cover = 0.2, density = 0.5, color = { 255, 248, 240 } },
		bed = { soundId = "", volume = 0.35 }, -- wind and cicadas: still to be chosen
	},
	-- Bright sea light, a bluer air and a wider sky.
	tide_flats = {
		clockTime = 16.2,
		brightness = 2.8,
		exposure = -0.1,
		ambient = { 122, 124, 128 },
		outdoorAmbient = { 150, 150, 150 },
		shiftTop = { 255, 226, 190 },
		shiftBottom = { 100, 110, 140 },
		air = {
			density = 0.32,
			offset = 0.25,
			haze = 1.0,
			glare = 0.3,
			color = { 230, 240, 250 },
			decay = { 150, 170, 200 },
		},
		grade = { tint = { 245, 248, 255 }, saturation = 0.06, contrast = 0.1 },
		bloom = { intensity = 0.3, size = 24, threshold = 1.2 },
		rays = { intensity = 0.06, spread = 0.6 },
		clouds = { cover = 0.5, density = 0.6, color = { 255, 255, 255 } },
		bed = { soundId = "", volume = 0.35 }, -- surf and gulls: still to be chosen
	},
	-- Starfall Crater (a side area of Dust Canyon): the same hot light with a violet decay.
	starfall = {
		clockTime = 15.8,
		brightness = 2.8,
		exposure = -0.05,
		ambient = { 130, 108, 100 },
		outdoorAmbient = { 160, 134, 120 },
		shiftTop = { 255, 200, 160 },
		shiftBottom = { 120, 90, 130 },
		air = {
			density = 0.3,
			offset = 0.15,
			haze = 1.2,
			glare = 0.4,
			color = { 255, 214, 190 },
			decay = { 170, 120, 150 },
		},
		grade = { tint = { 255, 232, 225 }, saturation = 0.1, contrast = 0.1 },
		bloom = { intensity = 0.4, size = 24, threshold = 1.1 },
		rays = { intensity = 0.08, spread = 0.6 },
		clouds = { cover = 0.2, density = 0.5, color = { 255, 240, 245 } },
		bed = { soundId = "", volume = 0.3 },
	},
}
ClimateConfig.PRESETS = PRESETS

-- The blender (Climate on the client) ----------------------------------------------------------

ClimateConfig.WEIGHT_INTERVAL = 0.2 -- seconds between reading the player's position
ClimateConfig.LOOK_TIME_CONSTANT = 1.5 -- seconds: a look closes 63% of the gap to its target
ClimateConfig.SOUND_TIME_CONSTANT = 1.0 -- seconds, for each bed's volume
ClimateConfig.BATTLE_QUIET = 0.34 -- the beds' volume factor while a battle is on screen
ClimateConfig.BATTLE_QUIET_TIME_CONSTANT = 0.4

-- A property is only written once it has moved this far from what was last written.
ClimateConfig.STEP = {
	clock = 0.005, -- hours
	brightness = 0.01,
	exposure = 0.005,
	colour = 0.5, -- of 255
	atmosphere = 0.003,
	grade = 0.003,
	bloom = 0.01,
	clouds = 0.005,
}

-- Hiding a sky swap (docs/plans/13 section 9b item 5): the Atmosphere gets thicker round the swap.
ClimateConfig.SWAP_DENSITY_BUMP = 0.15
ClimateConfig.SWAP_BUMP_SECONDS = 2

-- Where a preset may not change faster than this many studs (a test walks every zone to check
-- it), except in a zone marked hidden.
ClimateConfig.MIN_BLEND_STUDS = 150

return ClimateConfig
