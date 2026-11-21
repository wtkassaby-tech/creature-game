--!strict
-- Starts the device side: answers the server's round-trip pings, keeps the latest saved state
-- for the screens, draws the player's wild creatures and handles the world's prompts, and in
-- Studio opens the test panel.
-- Not yet run in Studio.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local BattleView = require(script.Parent.BattleView.BattleView)
local ClientState = require(script.Parent.State.ClientState)
local WorldView = require(script.Parent.World.WorldView)
local Bus = require(script.Parent.Net.Bus)
local Net = require(ReplicatedStorage.net.generated.Client)

-- Answer at once: the server times the reply to judge lasso taps fairly.
Bus.listen(Net.Ping, function(value)
	Net.Pong.Fire({ Nonce = value.Nonce })
end)

Bus.listen(Net.PlayerState, function(value)
	ClientState.set(value)
end)

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
WorldView.start()
BattleView.start(playerGui)

if RunService:IsStudio() then
	local TestPanel = require(script.Parent.Debug.TestPanel)
	TestPanel.start(playerGui)
end
