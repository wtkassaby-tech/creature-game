--!strict
-- The client's light and sound blender (docs/plans/13_WORLD_DESIGN.md section 9b). The server sets
-- Greenwood's look at start (Dressing.mood) and creates the Atmosphere, ColorCorrection, Bloom,
-- SunRays and Clouds; this takes over from the first frame, on this device only. Visual and audio
-- only: nothing here is ever sent to the server or decides anything in play.
--
-- Every 0.2 s it reads where the character stands, asks Regions how much of each preset's zone
-- that is, and mixes the presets into one target look. Every frame the shown look eases towards
-- that target (exponential smoothing, time constant ClimateConfig.LOOK_TIME_CONSTANT) and only the
-- properties that moved by a step are written. The Sky cannot blend, so it swaps only near a
-- passage's swap point (inside a gatehouse, tunnel or cloud) with a short density bump to hide the
-- cut. Sound beds are eased the same way in Audio/Ambience.
--
-- Battles: nothing in the battle scenes or the screen transition touches Lighting, so they do not
-- fight this. The player stands still while one is on, so the look stays put; only the beds go
-- quieter (Ambience watches the Battle screen).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Ambience = require(script.Parent.Parent.Audio.Ambience)
local ClimateBlend = require(ReplicatedStorage.shared.ClimateBlend)
local ClimateConfig = require(ReplicatedStorage.config.ClimateConfig)
local Lighting = game:GetService("Lighting")
local Regions = require(ReplicatedStorage.shared.Regions)
local World = require(ReplicatedStorage.content.World)

local Climate = {}

local STEP = ClimateConfig.STEP

local current: ClimateBlend.Look? = nil
local target: ClimateBlend.Look? = nil
local written: { [string]: any } = {} -- the last value written for each property
local skyShown: string? = nil
local skies: { [string]: Sky } = {}
local bumpLeft = 0
local sinceRead = math.huge

local function rootPosition(): Regions.Point?
	local character = Players.LocalPlayer.Character
	local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
	if root and root:IsA("BasePart") then
		return { x = root.Position.X, z = root.Position.Z }
	end
	return nil
end

local function colour(c: { number }): Color3
	return Color3.fromRGB(math.round(c[1]), math.round(c[2]), math.round(c[3]))
end

-- Write a number property only once it has moved a step from what was last written.
local function setNumber(inst: Instance, property: string, key: string, value: number, step: number)
	local last = written[key]
	if last == nil or math.abs(last - value) >= step then
		written[key] = value;
		(inst :: any)[property] = value
	end
end

local function setColour(inst: Instance, property: string, key: string, value: { number })
	local last: { number }? = written[key]
	if
		last == nil
		or math.abs(last[1] - value[1]) >= STEP.colour
		or math.abs(last[2] - value[2]) >= STEP.colour
		or math.abs(last[3] - value[3]) >= STEP.colour
	then
		written[key] = { value[1], value[2], value[3] }
		(inst :: any)[property] = colour(value)
	end
end

local function skyFor(presetId: string): Sky?
	local preset = ClimateConfig.PRESETS[presetId]
	if not preset or not preset.sky then
		return nil
	end
	local sky = skies[presetId]
	if not sky then
		local faces = preset.sky
		local made = Instance.new("Sky")
		made.Name = `Sky_{presetId}`
		made.SkyboxBk = faces.Bk or ""
		made.SkyboxDn = faces.Dn or ""
		made.SkyboxFt = faces.Ft or ""
		made.SkyboxLf = faces.Lf or ""
		made.SkyboxRt = faces.Rt or ""
		made.SkyboxUp = faces.Up or ""
		skies[presetId] = made
		return made
	end
	return sky
end

-- Show this preset's Sky in Lighting (a preset with no Sky of its own keeps the one up now).
local function swapSky(presetId: string)
	local next = skyFor(presetId)
	if next then
		for _, child in Lighting:GetChildren() do
			if child:IsA("Sky") and child ~= next then
				child.Parent = nil
			end
		end
		next.Parent = Lighting
	end
	skyShown = presetId
	bumpLeft = ClimateConfig.SWAP_BUMP_SECONDS
end

-- Atmosphere density is raised round a sky swap, in and out like a hill, to hide the cut.
local function bumpDensity(dt: number): number
	if bumpLeft <= 0 then
		return 0
	end
	bumpLeft = math.max(bumpLeft - dt, 0)
	local t = bumpLeft / ClimateConfig.SWAP_BUMP_SECONDS
	return ClimateConfig.SWAP_DENSITY_BUMP * math.sin(t * math.pi)
end

local function read()
	local at = rootPosition()
	if not at then
		return
	end
	local weights = Regions.presetWeights(World.zones, at)
	local mixed = ClimateBlend.mix(ClimateConfig.PRESETS, weights)
	if not mixed then
		return
	end
	target = mixed
	if not current then
		-- The first read: start exactly there, with no easing in from nowhere.
		current = ClimateBlend.copy(mixed)
	end
	Ambience.setWeights(weights)

	local dominant = Regions.dominant(weights)
	if dominant and dominant ~= skyShown then
		-- At the very first read, or once deep inside a zone (a teleport), or while at a passage's
		-- swap point: never in the open between, where the cut would show.
		local deep = (weights[dominant] or 0) > 0.95
		if skyShown == nil or deep or Regions.swapNear(World.passages, at) then
			swapSky(dominant)
		end
	end
end

local function apply(look: ClimateBlend.Look, density: number)
	local n, c = look.numbers, look.colours
	setNumber(Lighting, "ClockTime", "clock", n.clock, STEP.clock)
	setNumber(Lighting, "Brightness", "brightness", n.brightness, STEP.brightness)
	setNumber(Lighting, "ExposureCompensation", "exposure", n.exposure, STEP.exposure)
	setColour(Lighting, "Ambient", "ambient", c.ambient)
	setColour(Lighting, "OutdoorAmbient", "outdoorAmbient", c.outdoorAmbient)
	setColour(Lighting, "ColorShift_Top", "shiftTop", c.shiftTop)
	setColour(Lighting, "ColorShift_Bottom", "shiftBottom", c.shiftBottom)

	local air = Lighting:FindFirstChildOfClass("Atmosphere")
	if air then
		setNumber(air, "Density", "density", n.density + density, STEP.atmosphere)
		setNumber(air, "Offset", "offset", n.offset, STEP.atmosphere)
		setNumber(air, "Haze", "haze", n.haze, STEP.atmosphere)
		setNumber(air, "Glare", "glare", n.glare, STEP.atmosphere)
		setColour(air, "Color", "airColor", c.airColor)
		setColour(air, "Decay", "airDecay", c.airDecay)
	end
	local grade = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
	if grade then
		setNumber(grade, "Saturation", "saturation", n.saturation, STEP.grade)
		setNumber(grade, "Contrast", "contrast", n.contrast, STEP.grade)
		setColour(grade, "TintColor", "tint", c.tint)
	end
	local bloom = Lighting:FindFirstChildOfClass("BloomEffect")
	if bloom then
		setNumber(bloom, "Intensity", "bloomIntensity", n.bloomIntensity, STEP.bloom)
		setNumber(bloom, "Size", "bloomSize", n.bloomSize, STEP.bloom * 10)
		setNumber(bloom, "Threshold", "bloomThreshold", n.bloomThreshold, STEP.bloom)
	end
	local rays = Lighting:FindFirstChildOfClass("SunRaysEffect")
	if rays then
		setNumber(rays, "Intensity", "raysIntensity", n.raysIntensity, STEP.bloom)
		setNumber(rays, "Spread", "raysSpread", n.raysSpread, STEP.bloom)
	end
	local terrain = Workspace:FindFirstChildOfClass("Terrain")
	local clouds = if terrain then terrain:FindFirstChildOfClass("Clouds") else nil
	if clouds then
		setNumber(clouds, "Cover", "cloudCover", n.cloudCover, STEP.clouds)
		setNumber(clouds, "Density", "cloudDensity", n.cloudDensity, STEP.clouds)
		setColour(clouds, "Color", "cloudColor", c.cloudColor)
	end
end

local function onFrame(dt: number)
	sinceRead += dt
	if sinceRead >= ClimateConfig.WEIGHT_INTERVAL then
		sinceRead = 0
		read()
	end
	local now, goal = current, target
	if now and goal then
		ClimateBlend.ease(now, goal, ClimateBlend.alpha(dt, ClimateConfig.LOOK_TIME_CONSTANT))
		apply(now, bumpDensity(dt))
	end
	Ambience.step(dt)
end

function Climate.start()
	RunService.Heartbeat:Connect(onFrame)
end

return Climate
