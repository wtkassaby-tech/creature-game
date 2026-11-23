--!strict
-- The sound of the place itself: one looping bed per climate preset (docs/plans/13_WORLD_DESIGN.md
-- section 9b item 6), each as loud as its zone's weight, so walking from Greenwood into Dust
-- Canyon fades the birdsong out and the next bed in. Everything is quieter while a battle is on
-- screen. Climate sets the weights; this module eases each volume towards its target every frame
-- (exponential smoothing, no tweens, so a player who turns back never hears a jump).
-- A preset whose bed has no sound chosen yet (ClimateConfig) is silent. Beds are ambience tracks
-- from Roblox's licensed sound library (docs/ASSETS.md). Music is still to be chosen.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local ClimateBlend = require(ReplicatedStorage.shared.ClimateBlend)
local ClimateConfig = require(ReplicatedStorage.config.ClimateConfig)

local Ambience = {}

type Bed = { sound: Sound, volume: number, target: number, current: number }

local beds: { [string]: Bed } = {}
local quiet = 1 -- the battle factor now
local quietTarget = 1

-- The presets' target weights, by preset id: how loud each bed should be, 0 to 1.
function Ambience.setWeights(weights: { [string]: number })
	for id, bed in beds do
		bed.target = weights[id] or 0
	end
end

-- Ease every bed towards its target; call once a frame.
function Ambience.step(dt: number)
	quiet += (quietTarget - quiet) * ClimateBlend.alpha(
		dt,
		ClimateConfig.BATTLE_QUIET_TIME_CONSTANT
	)
	local alpha = ClimateBlend.alpha(dt, ClimateConfig.SOUND_TIME_CONSTANT)
	for _, bed in beds do
		bed.current += (bed.target - bed.current) * alpha
		local volume = bed.current * bed.volume * quiet
		-- Writing a property costs a call across the engine boundary: skip a change nobody hears.
		if math.abs(bed.sound.Volume - volume) > 0.002 then
			bed.sound.Volume = volume
		end
	end
end

function Ambience.start(playerGui: Instance)
	local group = Instance.new("SoundGroup")
	group.Name = "AmbientBeds"
	group.Parent = SoundService
	for id, preset in ClimateConfig.PRESETS do
		if preset.bed.soundId ~= "" then
			local sound = Instance.new("Sound")
			sound.Name = `Bed_{id}`
			sound.SoundId = preset.bed.soundId
			sound.Looped = true
			sound.Volume = 0
			sound.SoundGroup = group
			sound.Parent = group
			sound:Play()
			-- The first bed starts at full weight, so there is no silence before Climate's first read.
			beds[id] = {
				sound = sound,
				volume = preset.bed.volume,
				target = if id == "greenwood" then 1 else 0,
				current = if id == "greenwood" then 1 else 0,
			}
		end
	end

	task.spawn(function()
		local battle = playerGui:WaitForChild("Battle", 20)
		if not battle or not battle:IsA("ScreenGui") then
			return
		end
		battle:GetPropertyChangedSignal("Enabled"):Connect(function()
			quietTarget = if battle.Enabled then ClimateConfig.BATTLE_QUIET else 1
		end)
	end)
end

return Ambience
