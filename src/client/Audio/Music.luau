--!strict
-- The game's music: one calm track in towns, one on the roads, a lively loop in a battle and a
-- bigger one against a giant. Only one is meant to be heard at a time; this eases each track's
-- volume towards its target every frame (exponential smoothing, like the ambient beds in
-- Audio/Ambience), so the tracks crossfade and a player who turns back never hears a jump. A
-- track that has faded to nothing is paused, and a battle track starts from its beginning each
-- time. Town or route comes from where the player stands against each biome's hub (MusicZone);
-- a battle or giant is whichever of the Battle and Giant screens is showing.
-- Music is local only: nothing here is sent to the server or decides anything in play.
-- Volume: Music.setVolume changes the whole Music group (0 mutes); there is no settings screen
-- to call it from yet.

local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local AudioConfig = require(ReplicatedStorage.config.AudioConfig)
local Biomes = require(ReplicatedStorage.content.Biomes)
local ClimateBlend = require(ReplicatedStorage.shared.ClimateBlend)
local Layout = require(ReplicatedStorage.shared.Layout)
local MusicZone = require(ReplicatedStorage.shared.MusicZone)
local Tamers = require(ReplicatedStorage.content.Tamers)
local WorldTypes = require(ReplicatedStorage.shared.WorldTypes)

local Music = {}

type Voice = { sound: Sound, volume: number, current: number }

local voices: { [string]: Voice } = {}
local group: SoundGroup? = nil
local mood = "town" -- the track that should be heard now
local battleOn = false
local giantOn = false
local townNow = true
local duckUntil = 0
local duckFactor = 1

local function choose()
	if giantOn then
		mood = "giant"
	elseif battleOn then
		mood = "battle"
	else
		mood = if townNow then "town" else "route"
	end
end

-- Lowers the music for a few seconds, for a jingle that should be heard over it.
function Music.duck(seconds: number?)
	duckUntil = os.clock() + (seconds or AudioConfig.DUCK_SECONDS)
end

-- The whole Music group, 0 to 1 (0 mutes).
function Music.setVolume(volume: number)
	if group then
		group.Volume = math.clamp(volume, 0, 1)
	end
end

local function step(dt: number)
	local ducked = os.clock() < duckUntil
	duckFactor += ((if ducked then AudioConfig.DUCK_FACTOR else 1) - duckFactor) * ClimateBlend.alpha(
		dt,
		0.4
	)
	local inBattle = battleOn or giantOn
	local fade = if inBattle then AudioConfig.BATTLE_FADE_TIME else AudioConfig.MUSIC_FADE_TIME
	local alpha = ClimateBlend.alpha(dt, fade)
	for id, voice in voices do
		local target = if id == mood then voice.volume else 0
		voice.current += (target - voice.current) * alpha
		local heard = voice.current * (if id == mood then duckFactor else 1)
		if target == 0 and voice.current < 0.002 then
			-- Silent: stop paying for it. A battle track starts over next time.
			if voice.sound.IsPlaying then
				voice.sound:Pause()
			end
			if voice.sound.Volume ~= 0 then
				voice.sound.Volume = 0
			end
			if id == "battle" or id == "giant" then
				voice.sound.TimePosition = 0
			end
		else
			if not voice.sound.IsPlaying then
				voice.sound:Resume()
				if not voice.sound.IsPlaying then
					voice.sound:Play()
				end
			end
			-- Writing a property costs a call across the engine boundary: skip a change nobody hears.
			if math.abs(voice.sound.Volume - heard) > 0.002 then
				voice.sound.Volume = heard
			end
		end
	end
end

local function watch(playerGui: Instance, name: string, apply: (boolean) -> ())
	task.spawn(function()
		local screen = playerGui:WaitForChild(name, 30)
		if not screen or not screen:IsA("ScreenGui") then
			return
		end
		apply(screen.Enabled)
		screen:GetPropertyChangedSignal("Enabled"):Connect(function()
			apply(screen.Enabled)
		end)
	end)
end

function Music.start(playerGui: Instance)
	local made = Instance.new("SoundGroup")
	made.Name = "Music"
	made.Volume = AudioConfig.MASTER_MUSIC
	made.Parent = SoundService
	group = made

	local sounds: { Instance } = {}
	for id, track in AudioConfig.MUSIC do
		local sound = Instance.new("Sound")
		sound.Name = `Music_{id}`
		sound.SoundId = track.soundId
		sound.Looped = true
		sound.Volume = 0
		sound.SoundGroup = made
		sound.Parent = made
		voices[id] = { sound = sound, volume = track.volume, current = 0 }
		table.insert(sounds, sound)
	end
	-- Load them now so the first crossfade is not a silence.
	task.spawn(function()
		ContentProvider:PreloadAsync(sounds)
	end)

	watch(playerGui, "Battle", function(on)
		battleOn = on
		choose()
	end)
	watch(playerGui, "Giant", function(on)
		giantOn = on
		choose()
	end)

	-- Which ground the player stands on, a couple of times a second.
	local list: { WorldTypes.Biome } = {}
	for _, biome in Biomes do
		table.insert(list, biome)
	end
	local hubs: { MusicZone.Hub } = {}
	for _, map in Layout.world(list, Tamers.locals).maps do
		table.insert(hubs, map.hub)
	end
	task.spawn(function()
		while true do
			local character = Players.LocalPlayer.Character
			local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
			if root and root:IsA("BasePart") then
				townNow = MusicZone.kindAt(
					hubs,
					root.Position.X,
					root.Position.Z,
					townNow,
					AudioConfig.TOWN_ENTER_MARGIN,
					AudioConfig.TOWN_LEAVE_MARGIN
				) == "town"
				choose()
			end
			task.wait(AudioConfig.ZONE_INTERVAL)
		end
	end)

	RunService.Heartbeat:Connect(step)
end

return Music
