--!strict
-- Starts the device side: answers the server's round-trip pings, keeps the latest saved state
-- for the screens, and in Studio opens the test panel.
-- Not yet run in Studio.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ClientState = require(script.Parent.State.ClientState)
local Net = require(ReplicatedStorage.net.generated.Client)

-- Answer at once: the server times the reply to judge lasso taps fairly.
Net.Ping.On(function(value)
	Net.Pong.Fire({ Nonce = value.Nonce })
end)

Net.PlayerState.On(function(value)
	ClientState.set(value)
end)

if RunService:IsStudio() then
	local TestPanel = require(script.Parent.Debug.TestPanel)
	TestPanel.start(Players.LocalPlayer:WaitForChild("PlayerGui"))
end
