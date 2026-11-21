--!strict
-- Sends each player's saved state to their device (PlayerState in src/net/Net.blink) after
-- something changes it. Services call `changed(player)`; the state is sent at most every
-- SEND_EVERY_SECONDS, so a burst of changes costs one message.
-- Not yet run in Studio.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.net.generated.Server)
local Profile = require(ReplicatedStorage.shared.Profile)
local Snapshot = require(ReplicatedStorage.shared.Snapshot)

local SEND_EVERY_SECONDS = 0.5

local StateSync = {}

local dirty: { [Player]: boolean } = {}

function StateSync.changed(player: Player)
	dirty[player] = true
end

function StateSync.start(getData: (player: Player) -> Profile.Profile?): () -> ()
	local running = true
	task.spawn(function()
		while running do
			task.wait(SEND_EVERY_SECONDS)
			for player in dirty do
				dirty[player] = nil
				local profile = getData(player)
				if profile and player.Parent == Players then
					Net.PlayerState.Fire(player, Snapshot.build(profile, os.time()))
				end
			end
		end
	end)
	local leaving = Players.PlayerRemoving:Connect(function(player)
		dirty[player] = nil
	end)
	return function()
		running = false
		leaving:Disconnect()
	end
end

return StateSync
