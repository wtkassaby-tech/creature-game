--!strict
-- The maths of the light and sound blend, with no Roblox calls (docs/plans/13_WORLD_DESIGN.md
-- section 9b): turn presets into a flat "look", mix looks by weight (colours in linear light, the
-- clock the short way round), and ease one look towards another by exponential smoothing so a
-- player who stops or turns back never sees a snap. The client's Climate applies the result.

local ClimateConfig = require("../config/ClimateConfig")

export type Look = { numbers: { [string]: number }, colours: { [string]: { number } } }
export type Preset = ClimateConfig.Preset
export type Weights = { [string]: number }

local ClimateBlend = {}

-- Which keys make a look, in a fixed order so every machine mixes the same way.
local NUMBER_KEYS: { string } = {
	"clock",
	"brightness",
	"exposure",
	"density",
	"offset",
	"haze",
	"glare",
	"saturation",
	"contrast",
	"bloomIntensity",
	"bloomSize",
	"bloomThreshold",
	"raysIntensity",
	"raysSpread",
	"cloudCover",
	"cloudDensity",
}
local COLOUR_KEYS: { string } = {
	"ambient",
	"outdoorAmbient",
	"shiftTop",
	"shiftBottom",
	"airColor",
	"airDecay",
	"tint",
	"cloudColor",
}
ClimateBlend.NUMBER_KEYS = NUMBER_KEYS
ClimateBlend.COLOUR_KEYS = COLOUR_KEYS

local GAMMA = 2.2

local function toLinear(c: number): number
	return (math.clamp(c, 0, 255) / 255) ^ GAMMA
end

local function fromLinear(c: number): number
	return math.clamp(c, 0, 1) ^ (1 / GAMMA) * 255
end

function ClimateBlend.lookOf(preset: Preset): Look
	return {
		numbers = {
			clock = preset.clockTime,
			brightness = preset.brightness,
			exposure = preset.exposure,
			density = preset.air.density,
			offset = preset.air.offset,
			haze = preset.air.haze,
			glare = preset.air.glare,
			saturation = preset.grade.saturation,
			contrast = preset.grade.contrast,
			bloomIntensity = preset.bloom.intensity,
			bloomSize = preset.bloom.size,
			bloomThreshold = preset.bloom.threshold,
			raysIntensity = preset.rays.intensity,
			raysSpread = preset.rays.spread,
			cloudCover = preset.clouds.cover,
			cloudDensity = preset.clouds.density,
		},
		colours = {
			ambient = preset.ambient,
			outdoorAmbient = preset.outdoorAmbient,
			shiftTop = preset.shiftTop,
			shiftBottom = preset.shiftBottom,
			airColor = preset.air.color,
			airDecay = preset.air.decay,
			tint = preset.grade.tint,
			cloudColor = preset.clouds.color,
		},
	}
end

function ClimateBlend.copy(look: Look): Look
	local colours: { [string]: { number } } = {}
	for key, c in look.colours do
		colours[key] = table.clone(c)
	end
	return { numbers = table.clone(look.numbers), colours = colours }
end

-- Hours, the short way round the clock: mixing 23 with 1 gives 0, not 12.
function ClimateBlend.mixClock(values: { number }, weights: { number }): number
	local x, y = 0, 0
	for index, hours in values do
		local angle = hours / 24 * 2 * math.pi
		x += math.cos(angle) * weights[index]
		y += math.sin(angle) * weights[index]
	end
	if x * x + y * y < 1e-9 then
		return values[1] or 0
	end
	return (math.atan2(y, x) / (2 * math.pi) * 24) % 24
end

-- The weighted mix of presets, `weights` by preset id (they need not sum to 1: they are scaled).
-- Nil when no listed preset has weight.
function ClimateBlend.mix(presets: { [string]: Preset }, weights: Weights): Look?
	local ids: { string } = {}
	local total = 0
	for id, w in weights do
		if w > 0 and presets[id] then
			table.insert(ids, id)
			total += w
		end
	end
	if total <= 0 then
		return nil
	end
	table.sort(ids) -- the same order on every machine
	local looks: { Look } = {}
	local ws: { number } = {}
	for index, id in ids do
		looks[index] = ClimateBlend.lookOf(presets[id])
		ws[index] = weights[id] / total
	end
	local result: Look = { numbers = {}, colours = {} }
	for _, key in NUMBER_KEYS do
		if key == "clock" then
			local clocks: { number } = {}
			for index, look in looks do
				clocks[index] = look.numbers.clock
			end
			result.numbers.clock = ClimateBlend.mixClock(clocks, ws)
		else
			local sum = 0
			for index, look in looks do
				sum += look.numbers[key] * ws[index]
			end
			result.numbers[key] = sum
		end
	end
	for _, key in COLOUR_KEYS do
		local channels = { 0, 0, 0 }
		for index, look in looks do
			local c = look.colours[key]
			for i = 1, 3 do
				channels[i] += toLinear(c[i]) * ws[index]
			end
		end
		result.colours[key] =
			{ fromLinear(channels[1]), fromLinear(channels[2]), fromLinear(channels[3]) }
	end
	return result
end

-- The share of the gap to close this frame for a time constant (seconds): 1 - e^(-dt/tau).
function ClimateBlend.alpha(dt: number, timeConstant: number): number
	if timeConstant <= 0 then
		return 1
	end
	return 1 - math.exp(-math.max(dt, 0) / timeConstant)
end

-- Move `current` towards `target` in place by `alpha`; the clock goes the short way round.
function ClimateBlend.ease(current: Look, target: Look, alpha: number)
	for _, key in NUMBER_KEYS do
		local from, to = current.numbers[key], target.numbers[key]
		if key == "clock" then
			local gap = ((to - from + 12) % 24) - 12
			current.numbers[key] = (from + gap * alpha) % 24
		else
			current.numbers[key] = from + (to - from) * alpha
		end
	end
	for _, key in COLOUR_KEYS do
		local from, to = current.colours[key], target.colours[key]
		for i = 1, 3 do
			from[i] += (to[i] - from[i]) * alpha
		end
	end
end

-- The distance in hours between two clock times, the short way round.
function ClimateBlend.clockGap(a: number, b: number): number
	return math.abs(((b - a + 12) % 24) - 12)
end

return ClimateBlend
