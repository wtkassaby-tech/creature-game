--!strict
-- The sound of the place itself: morning birdsong, looping quietly under everything, and
-- quieter still while a battle is on screen. It is an ambience track from Roblox's licensed
-- sound library (docs/ASSETS.md). Music is still to be chosen: it has to be listened to first.

local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Ambience = {}

local BIRDSONG = "rbxassetid://9116969794" -- "Morning Birds 5 (SFX)", Pro Sound Effects
local VOLUME = 0.35
local QUIET = 0.12

function Ambience.start(playerGui: Instance)
	local sound = Instance.new("Sound")
	sound.Name = "Ambience"
	sound.SoundId = BIRDSONG
	sound.Looped = true
	sound.Volume = VOLUME
	sound.Parent = SoundService
	sound:Play()

	task.spawn(function()
		local battle = playerGui:WaitForChild("Battle", 20)
		if not battle or not battle:IsA("ScreenGui") then
			return
		end
		battle:GetPropertyChangedSignal("Enabled"):Connect(function()
			local goal = { Volume = if battle.Enabled then QUIET else VOLUME }
			TweenService:Create(sound, TweenInfo.new(0.6), goal):Play()
		end)
	end)
end

return Ambience
