--!strict
-- Short sounds for presses and battle moments. Every sound here ships inside Roblox itself
-- (rbxasset://sounds/...), so nothing is uploaded or bought; each was checked to load in Studio
-- on 22 November 2026 (docs/ASSETS.md). They are stand-ins until the game has its own sounds.

local SoundService = game:GetService("SoundService")

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

type Def = { id: string, volume: number, speed: number }

local SOUNDS: { [Name]: Def } = {
	press = { id = "rbxasset://sounds/clickfast.wav", volume = 0.5, speed = 1 },
	confirm = { id = "rbxasset://sounds/electronicpingshort.wav", volume = 0.4, speed = 1.2 },
	hit = { id = "rbxasset://sounds/snap.mp3", volume = 0.7, speed = 1 },
	strongHit = { id = "rbxasset://sounds/swordslash.wav", volume = 0.8, speed = 0.9 },
	weakHit = { id = "rbxasset://sounds/kerplunk.wav", volume = 0.5, speed = 1.1 },
	faint = { id = "rbxasset://sounds/bass.wav", volume = 0.6, speed = 0.8 },
	swap = { id = "rbxasset://sounds/switch.wav", volume = 0.6, speed = 1 },
	win = { id = "rbxasset://sounds/victory.wav", volume = 0.6, speed = 1 },
	lose = { id = "rbxasset://sounds/bass.wav", volume = 0.5, speed = 0.6 },
	count = { id = "rbxasset://sounds/switch.wav", volume = 0.25, speed = 1.6 },
}

local made: { [Name]: Sound } = {}

function Sfx.play(name: Name)
	-- PlayLocalSound lets the same sound overlap itself (a fast count-up, two quick hits).
	local ready: Sound? = made[name]
	if ready then
		SoundService:PlayLocalSound(ready)
		return
	end
	local def = SOUNDS[name]
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
