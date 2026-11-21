--!strict
-- The walkable world on the server: where everything is, where each player's character is (by
-- the server's own reading, never the device's word), and each player's own wild creatures.
--
-- Wild creatures are per player. The server keeps a book for each player (src/shared/Encounters),
-- fills the stretches of route near them about once a second, and tells their device what to
-- draw. A battle request names a creature by its id in that book; it must exist there and the
-- player's character must be standing next to it.
-- Not yet run in Studio.

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BattleSession = require(ReplicatedStorage.shared.BattleSession)
local Encounters = require(ReplicatedStorage.shared.Encounters)
local Layout = require(ReplicatedStorage.shared.Layout)
local Net = require(ReplicatedStorage.net.generated.Server)
local Tamers = require(ReplicatedStorage.content.Tamers)
local WorldTypes = require(ReplicatedStorage.shared.WorldTypes)

local TestMap = require(script.Parent.TestMap)

local TICK_SECONDS = 1
local MIN_SECONDS_BETWEEN_RUSTLES = 0.5

export type Hooks = {
	isReady: (player: Player) -> boolean, -- data loaded and not in a battle
	refuse: (player: Player, reason: string) -> (),
	onAt: (player: Player, at: Layout.Point) -> (), -- the regular look at where a player is
}

local WorldService = {}

local biome: WorldTypes.Biome
local map: Layout.Map
local books: { [Player]: Encounters.Book } = {}
-- Rest timers of players who left, by user id, kept for a while (see `book`).
type Timers = { rustledAt: { [string]: number }, freeAt: { [string]: number }, leftAt: number }
local timers: { [number]: Timers } = {}
local KEEP_TIMERS_SECONDS = 600
local lastRustle: { [Player]: number } = {}
local random = Random.new()

local function newId(): string
	return HttpService:GenerateGUID(false)
end

local function seed(): number
	return random:NextInteger(1, 2147483646)
end

function WorldService.map(): Layout.Map
	return map
end

function WorldService.biome(): WorldTypes.Biome
	return biome
end

-- Where the player's character is on the map, or nil if they have no character right now.
function WorldService.position(player: Player): Layout.Point?
	local character = player.Character
	local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
	local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
	-- A fallen character is nowhere: it cannot start a battle or reach a place.
	if root and root:IsA("BasePart") and humanoid and humanoid.Health > 0 then
		return { x = root.Position.X, z = root.Position.Z }
	end
	return nil
end

function WorldService.isNear(player: Player, placeId: string, radius: number): boolean
	local at = WorldService.position(player)
	return at ~= nil and Layout.isNear(map, placeId, at, radius)
end

-- A player's book, made when first needed. Its rest timers (rustle spots, stretches waiting to
-- refill) are carried over from their last visit to this server, so leaving and rejoining is
-- not a way round them.
local function book(player: Player): Encounters.Book
	local found = books[player]
	if found then
		return found
	end
	local made = Encounters.new()
	local kept = timers[player.UserId]
	if kept then
		made.rustledAt, made.freeAt = kept.rustledAt, kept.freeAt
		timers[player.UserId] = nil
	end
	books[player] = made
	return made
end

local function send(player: Player)
	local list = {}
	for _, spawn in book(player).spawns do
		local c = spawn.creature
		if not spawn.busy and #list < 32 then
			table.insert(list, {
				Id = spawn.id,
				X = spawn.at.x,
				Z = spawn.at.z,
				BodyPlan = c.bodyPlan,
				Head = c.parts.Head.species,
				Torso = c.parts.Torso.species,
				FrontLimbs = c.parts.FrontLimbs.species,
				Legs = c.parts.Legs.species,
				Tail = c.parts.Tail.species,
				Colour = c.colour.shown,
				Size = c.size,
				Rarity = c.rarity,
				Level = math.clamp(c.level, 0, 255),
			})
		end
	end
	Net.WildSpawns.Fire(player, { Spawns = list })
end

-- One of the player's wild creatures by id, or nil.
function WorldService.spawn(player: Player, spawnId: number): Encounters.Spawn?
	local found = books[player]
	return if found then found.spawns[spawnId] else nil
end

-- Starts a battle with one of the player's wild creatures, or returns nil and a reason.
function WorldService.engage(player: Player, spawnId: unknown): (Encounters.Spawn?, string?)
	local at = WorldService.position(player)
	if not at then
		return nil, "You are too far away"
	end
	local spawn, why = Encounters.engage(book(player), spawnId, at)
	if spawn then
		send(player)
	end
	return spawn, why
end

-- Ends a battle with a wild creature: gone if it was beaten, caught or fled; otherwise it
-- stays, with its missed throws remembered.
function WorldService.finish(
	player: Player,
	spawnId: number,
	ending: BattleSession.Ending?,
	misses: number
)
	local found = books[player]
	if not found then
		return -- the player has left; their book is gone
	end
	Encounters.finish(found, spawnId, ending, misses, os.clock())
	send(player)
end

function WorldService.start(hooks: Hooks): () -> ()
	biome = require(ReplicatedStorage.content.Biomes).greenwood
	map = Layout.build(biome, Tamers.locals)
	TestMap.build(biome, map)

	local running = true
	task.spawn(function()
		while running do
			for _, player in Players:GetPlayers() do
				-- One player's trouble must never stop the world for everyone else.
				local ok, problem = pcall(function()
					local at = WorldService.position(player)
					if at and hooks.isReady(player) then
						if
							Encounters.tick(book(player), biome, map, at, os.clock(), seed(), newId)
						then
							send(player)
						end
						hooks.onAt(player, at)
					end
				end)
				if not ok then
					warn(`[WorldTick] {player.UserId}: {problem}`)
				end
			end
			task.wait(TICK_SECONDS)
		end
	end)

	local stopRustle = Net.Rustle.On(function(player, value)
		local now = os.clock()
		if now - (lastRustle[player] or -math.huge) < MIN_SECONDS_BETWEEN_RUSTLES then
			return
		end
		lastRustle[player] = now
		local at = WorldService.position(player)
		if not at or not hooks.isReady(player) then
			return
		end
		local spawn, why =
			Encounters.rustle(book(player), biome, map, value.SpotId, at, now, seed(), newId)
		if spawn then
			send(player)
		else
			hooks.refuse(player, why or "Nothing stirs")
		end
	end)

	local leaving = Players.PlayerRemoving:Connect(function(player)
		local left = books[player]
		if left then
			timers[player.UserId] =
				{ rustledAt = left.rustledAt, freeAt = left.freeAt, leftAt = os.clock() }
		end
		books[player] = nil
		lastRustle[player] = nil
		for userId, kept in timers do
			if os.clock() - kept.leftAt > KEEP_TIMERS_SECONDS then
				timers[userId] = nil
			end
		end
	end)

	return function()
		running = false
		stopRustle()
		leaving:Disconnect()
	end
end

return WorldService
