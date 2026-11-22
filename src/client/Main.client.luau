--!strict
-- Starts the device side: answers the server's round-trip pings, keeps the latest saved state
-- for the screens, draws the player's wild creatures and handles the world's prompts, and in
-- Studio opens the test panel.
-- Not yet run in Studio.

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Ambience = require(script.Parent.Audio.Ambience)
local BattleView = require(script.Parent.BattleView.BattleView)
local ClientState = require(script.Parent.State.ClientState)
local CreaturesView = require(script.Parent.Creatures.CreaturesView)
local GiantView = require(script.Parent.GiantView.GiantView)
local ShopView = require(script.Parent.Shop.ShopView)
local StoryView = require(script.Parent.Story.StoryView)
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
local shop = ShopView.start(playerGui)
WorldView.start(shop.open)
BattleView.start(playerGui)
GiantView.start(playerGui)
CreaturesView.start(playerGui)
StoryView.start(playerGui)
Ambience.start(playerGui)

-- The world's prompts hide while a screen is open. A prompt is drawn on the screen and can be
-- tapped: standing beside the rival, the "Battle" prompt sat right over the battle's Continue
-- button (seen in the phone-sized Studio run), and E could start something behind a screen.
local COVERING_SCREENS: { string } =
	{ "Battle", "Giant", "Shop", "Creatures", "Dialogue", "StarterPick" }
local function refreshPrompts()
	local covered = false
	for _, name in COVERING_SCREENS do
		local screen = playerGui:FindFirstChild(name)
		if screen and screen:IsA("ScreenGui") and screen.Enabled then
			covered = true
		end
	end
	ProximityPromptService.Enabled = not covered
end
for _, name in COVERING_SCREENS do
	local screen = playerGui:FindFirstChild(name)
	if screen and screen:IsA("ScreenGui") then
		screen:GetPropertyChangedSignal("Enabled"):Connect(refreshPrompts)
	end
end
refreshPrompts()

if RunService:IsStudio() then
	local TestPanel = require(script.Parent.Debug.TestPanel)
	TestPanel.start(playerGui)
end
