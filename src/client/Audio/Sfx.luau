--!strict
-- Short sounds for presses and battle moments. Which file, volume and pitch each uses is data in
-- src/config/AudioConfig (Roblox's licensed libraries; docs/ASSETS.md). A sound defined with a
-- jingle plays that tune (Audio/Jingle) instead of a file.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local AudioConfig = require(ReplicatedStorage.config.AudioConfig)
local Jingle = require(script.Parent.Jingle)

local Sfx = {}

export type Name =
	"press"
	| "confirm"
	| "hit"
	| "strongHit"
	| "weakHit"
	| "faint"
	| "swap"
	| "win"
	| "lose"
	| "count"
	| "throw"
	| "cinch"
	| "tug"
	| "slip"
	| "caught"
	| "battleStart"
	| "giantStart"
	| "levelUp"
	| "hatch"
	| "questDone"
	| "badge"
	| "buy"
	| "find"
	| "travel"
	| "tick"
	| "heal"
	| "journal"
	| "spotted"
	| "grass"

local made: { [string]: Sound } = {}

function Sfx.play(name: Name)
	-- PlayLocalSound lets the same sound overlap itself (a fast count-up, two quick hits).
	local def = AudioConfig.SFX[name]
	if def and def.jingle then
		Jingle.play(def.jingle, def.volume)
		return
	end
	local ready: Sound? = made[name]
	if ready then
		SoundService:PlayLocalSound(ready)
		return
	end
	if not def then
		return
	end
	local sound = Instance.new("Sound")
	sound.Name = `Sfx_{name}`
	sound.SoundId = def.id
	sound.Volume = def.volume
	sound.PlaybackSpeed = def.speed
	sound.Parent = SoundService
	made[name] = sound
	SoundService:PlayLocalSound(sound)
end

return Sfx
