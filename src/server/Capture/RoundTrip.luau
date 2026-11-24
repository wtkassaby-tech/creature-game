--!strict
-- The server's own round-trip readings for each player, for the lasso's lag allowance
-- (approval pack 2 section 3). The server sends a ping with a random nonce and times the reply.
-- A reply cannot arrive before its ping, so a reading can be made worse but never better than
-- the real connection; the lasso trusts the smallest of the recent readings.
--
-- Pings are only sent while a player is in a wild battle, every few seconds.
-- Not yet run in Studio.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Lasso = require(ReplicatedStorage.shared.Lasso)
local Net = require(ReplicatedStorage.net.generated.Server)

local KEEP_READINGS = 8
local PING_EVERY_SECONDS = 2
local GIVE_UP_AFTER_SECONDS = 5 -- an unanswered ping is dropped, not counted

type Waiting = { nonce: number, sentAt: number }

local RoundTrip = {}

local readings: { [Player]: { number } } = {}
local waiting: { [Player]: Waiting } = {}
local MIN_SECONDS_BETWEEN_PONGS = 0.2
local lastPong: { [Player]: number } = {}

local function record(player: Player, ms: number)
	local list = readings[player]
	if not list then
		list = {}
		readings[player] = list
	end
	table.insert(list, ms)
	while #list > KEEP_READINGS do
		table.remove(list, 1)
	end
end

-- The round trip to trust for this player now, in milliseconds.
function RoundTrip.trustedMs(player: Player): number
	-- The engine's own ping figure (seconds) caps the readings the client could have delayed.
	local ok, seconds = pcall(function()
		return player:GetNetworkPing()
	end)
	local engineMs: number? = if ok and typeof(seconds) == "number" then seconds * 1000 else nil
	return Lasso.trustedRoundTripMs(readings[player] or {}, engineMs)
end

-- Starts pinging every player for whom `shouldPing` is true. Returns a function that stops it.
function RoundTrip.start(shouldPing: (player: Player) -> boolean): () -> ()
	local random = Random.new()
	local running = true

	local stopPong = Net.Pong.On(function(player, value)
		-- Rate limit (CLAUDE.md rule 5): only one reply is ever expected per ping.
		local nowClock = os.clock()
		if nowClock - (lastPong[player] or -math.huge) < MIN_SECONDS_BETWEEN_PONGS then
			return
		end
		lastPong[player] = nowClock
		local pending = waiting[player]
		if not pending or pending.nonce ~= value.Nonce then
			return -- an old, repeated or made-up reply
		end
		waiting[player] = nil
		record(player, (os.clock() - pending.sentAt) * 1000)
	end)

	task.spawn(function()
		while running do
			local now = os.clock()
			for _, player in Players:GetPlayers() do
				local pending = waiting[player]
				local stale = pending ~= nil and now - pending.sentAt > GIVE_UP_AFTER_SECONDS
				if stale then
					waiting[player] = nil
				end
				if (pending == nil or stale) and shouldPing(player) then
					local nonce = random:NextInteger(1, 4294967295)
					waiting[player] = { nonce = nonce, sentAt = os.clock() }
					Net.Ping.Fire(player, { Nonce = nonce })
				end
			end
			task.wait(PING_EVERY_SECONDS)
		end
	end)

	local leaving = Players.PlayerRemoving:Connect(function(player)
		readings[player] = nil
		waiting[player] = nil
		lastPong[player] = nil
	end)

	return function()
		running = false
		stopPong()
		leaving:Disconnect()
	end
end

return RoundTrip
