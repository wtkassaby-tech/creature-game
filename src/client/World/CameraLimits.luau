--!strict
-- Keeps the world camera close: the player cannot zoom out far enough to see over the walls of
-- trees and rock that close in each route (docs/plans/12_MAP_STRUCTURE.md section 4d). The limits
-- are properties of the local Player, which Roblox's default camera reads and obeys.

local Players = game:GetService("Players")

local CameraConfig = require(game:GetService("ReplicatedStorage").config.CameraConfig)

local CameraLimits = {}

function CameraLimits.start()
	local player = Players.LocalPlayer
	player.CameraMaxZoomDistance = CameraConfig.MAX_ZOOM
	player.CameraMinZoomDistance = CameraConfig.MIN_ZOOM
end

return CameraLimits
