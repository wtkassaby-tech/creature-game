--!strict
-- A creature's cry: a few soft notes at the species' own pitch (content/SpeciesQuirks `cry`),
-- played on the jingle instrument at the low volume in AudioConfig.CRY. One Sound per note, made
-- once per species and reused, like Audio/Jingle. Sounds only.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local AudioConfig = require(ReplicatedStorage.config.AudioConfig)
local Pitch = require(ReplicatedStorage.shared.Pitch)
local SpeciesQuirks = require(ReplicatedStorage.content.SpeciesQuirks)

local Cry = {}

type Built = { sounds: { Sound }, starts: { number } }

local built: { [string]: Built } = {}

local function build(species: string): Built?
	local ready = built[species]
	if ready then
		return ready
	end
	local quirk = SpeciesQuirks[species]
	if not quirk then
		return nil
	end
	local notes = Pitch.cry(quirk.cry.pitch, quirk.cry.notes, quirk.cry.gap, AudioConfig.CRY.rise)
	local sounds: { Sound } = {}
	local starts: { number } = {}
	for index, note in notes do
		local sound = Instance.new("Sound")
		sound.Name = `Cry_{species}_{index}`
		sound.SoundId = AudioConfig.CRY.id
		sound.PlaybackSpeed = note.speed
		sound.Volume = AudioConfig.CRY.volume
		sound.Parent = SoundService
		table.insert(sounds, sound)
		table.insert(starts, note.start)
	end
	local made: Built = { sounds = sounds, starts = starts }
	built[species] = made
	return made
end

-- Plays the species' cry after `delay` seconds (default 0). A species with no quirk is silent.
function Cry.play(species: string, delay: number?)
	local made = build(species)
	if not made then
		return
	end
	local wait = delay or 0
	for index, sound in made.sounds do
		local at = wait + made.starts[index]
		if at <= 0 then
			sound:Play()
		else
			task.delay(at, function()
				sound:Play()
			end)
		end
	end
end

return Cry
