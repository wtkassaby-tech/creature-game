--!strict
-- Plays a short tune from src/config/JingleConfig: one instrument sample, one Sound per note,
-- each set to its own PlaybackSpeed and started on a timer. Nothing runs per frame; a jingle is
-- a handful of task.delay calls. Sounds are made once per jingle and reused.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local JingleConfig = require(ReplicatedStorage.config.JingleConfig)
local Pitch = require(ReplicatedStorage.shared.Pitch)

local Jingle = {}

type Built = { sounds: { Sound }, events: { Pitch.Event } }

local built: { [string]: Built } = {}

local function build(name: string): Built?
	local ready = built[name]
	if ready then
		return ready
	end
	local def = JingleConfig.JINGLES[name]
	if not def then
		return nil
	end
	local events = Pitch.timeline(def.notes, def.bpm)
	local sounds: { Sound } = {}
	for index, event in events do
		local sound = Instance.new("Sound")
		sound.Name = `Jingle_{name}_{index}`
		sound.SoundId = JingleConfig.INSTRUMENT_ID
		sound.PlaybackSpeed = event.speed
		sound.Parent = SoundService
		table.insert(sounds, sound)
	end
	local made: Built = { sounds = sounds, events = events }
	built[name] = made
	return made
end

-- Starts the jingle; `scale` (default 1) multiplies its volume. Returns its length in seconds
-- (0 for an unknown name) so a caller can wait for it.
function Jingle.play(name: string, scale: number?): number
	local made = build(name)
	local def = JingleConfig.JINGLES[name]
	if not made or not def then
		return 0
	end
	local volume = math.clamp(JingleConfig.INSTRUMENT_VOLUME * def.volume * (scale or 1), 0, 1)
	for index, sound in made.sounds do
		sound.Volume = volume
		local start = made.events[index].start
		if start <= 0 then
			sound:Play()
		else
			task.delay(start, function()
				sound:Play()
			end)
		end
	end
	return Pitch.length(def.notes, def.bpm)
end

return Jingle
