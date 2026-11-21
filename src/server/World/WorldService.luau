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
local Biomes = require(ReplicatedStorage.content.Biomes)
local Encounters = require(ReplicatedStorage.shared.Encounters)
local Layout = require(ReplicatedStorage.shared.Layout)
local Net = require(ReplicatedStorage.net.generated.Server)
local Tamers = require(ReplicatedStorage.content.Tamers)
local WorldConfig = require(ReplicatedStorage.config.WorldConfig)
local WorldTypes = require(ReplicatedStorage.shared.WorldTypes)

local TestMap = require(script.Parent.TestMap)

local TICK_SECONDS = 1
local MIN_SECONDS_BETWEEN_RUSTLES = 0.5
local MIN_SECONDS_BETWEEN_TRAVELS = 2

export type Hooks = {
	isReady: (player: Player) -> boolean, -- data loaded and not in a battle
	refuse: (player: Player, reason: string) -> (),
	onAt: (player: Player, at: Layout.Point) -> (), -- the regular look at where a player is
	onAmbush: (player: Player, spawn: Encounters.Spawn) -> (), -- a creature jumped out of long grass
	mayEnter: (player: Player, biomeNumber: number) -> boolean, -- has the player earned this biome?
	hasReached: (player: Player, biomeNumber: number) -> boolean, -- have they stood in it before?
	canBeAmbushed: (player: Player) -> boolean, -- wild battles are open and someone can fight
}

local WorldService = {}

local biomes: { WorldTypes.Biome } = {} -- every biome, in order
local world: Layout.World
local map: Layout.Map -- every biome's places together
local books: { [Player]: Encounters.Book } = {}
-- Rest timers of players who left, by user id, kept for a while (see `book`).
type Timers = { rustledAt: { [string]: number }, freeAt: { [string]: number }, leftAt: number }
local timers: { [number]: Timers } = {}
local KEEP_TIMERS_SECONDS = 600
local lastRustle: { [Player]: number } = {}
local lastTravel: { [Player]: number } = {}
local engageAllowed: (player: Player, biomeNumber: number) -> boolean = function()
	return true
end
local lastAt: { [Player]: Layout.Point } = {}
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

function WorldService.biomes(): { WorldTypes.Biome }
	return biomes
end

local function biomeNumbered(number: number?): WorldTypes.Biome
	for _, biome in biomes do
		if biome.number == number then
			return biome
		end
	end
	return biomes[1]
end

-- The biome a place belongs to (the first biome if the place is unknown).
function WorldService.biomeOfPlace(placeId: string): WorldTypes.Biome
	return biomeNumbered(world.biomeOfPlace[placeId])
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

-- The biome the player's character is standing in (the first biome if they have no character).
function WorldService.biomeOf(player: Player): WorldTypes.Biome
	local at = WorldService.position(player)
	return biomeNumbered(if at then Layout.biomeAt(world, at) else nil)
end

-- The hub building with this role (a shop, a healer) that the player is standing at, in
-- whichever biome it is, or nil.
function WorldService.buildingAt(
	player: Player,
	role: string,
	radius: number
): (WorldTypes.Biome?, WorldTypes.Building?)
	for _, biome in biomes do
		for _, building in biome.hub.buildings do
			if building.role == role and WorldService.isNear(player, building.id, radius) then
				return biome, building
			end
		end
	end
	return nil, nil
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

-- Moves the player's character to a named place (waking up at the healer after a lost battle).
function WorldService.sendTo(player: Player, placeId: string)
	local character = player.Character
	local place = map.places[placeId]
	if character and place then
		character:PivotTo(CFrame.new(place.x, 6, place.z))
		lastAt[player] = nil -- do not count the jump as walking
	end
end

-- Takes one of the player's wild creatures out of the world at once (a grass battle that
-- could not start).
function WorldService.remove(player: Player, spawnId: number)
	local found = books[player]
	if found then
		Encounters.remove(found, spawnId)
		send(player)
	end
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
	-- A creature of a biome the player has not earned yet cannot be fought.
	local wanted = if typeof(spawnId) == "number" then book(player).spawns[spawnId] else nil
	if wanted and not engageAllowed(player, wanted.biome) then
		return nil, "You have not earned your way here yet"
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
	for _, biome in Biomes do
		table.insert(biomes, biome)
	end
	table.sort(biomes, function(a, b)
		return a.number < b.number
	end)
	world = Layout.world(biomes, Tamers.locals)
	map = world.map
	TestMap.build(biomes, world)
	engageAllowed = hooks.mayEnter

	local running = true
	task.spawn(function()
		while running do
			for _, player in Players:GetPlayers() do
				-- One player's trouble must never stop the world for everyone else.
				local ok, problem = pcall(function()
					local at = WorldService.position(player)
					if at and hooks.isReady(player) then
						-- Only biomes the player has earned are alive for them.
						local changed = false
						local jumped: Encounters.Spawn? = nil
						local before = lastAt[player]
						lastAt[player] = at
						local walking = before ~= nil
							and Layout.distance(before, at) >= WorldConfig.GRASS_MIN_MOVE
						local ambush = hooks.canBeAmbushed(player)
						for _, biome in biomes do
							if hooks.mayEnter(player, biome.number) then
								if
									Encounters.tick(
										book(player),
										biome,
										map,
										at,
										os.clock(),
										seed(),
										newId
									)
								then
									changed = true
								end
								-- Long grass: only the server's own reading of where the player
								-- is and whether they are walking decides this.
								if ambush and not jumped then
									jumped = Encounters.grass(
										book(player),
										biome,
										map,
										at,
										walking,
										os.clock(),
										seed(),
										newId
									)
								end
							end
						end
						if changed then
							send(player)
						end
						hooks.onAt(player, at)
						if jumped then
							hooks.onAmbush(player, jumped)
						end
					else
						-- Not walking the world (in a battle, loading): the next look starts
						-- fresh, so standing still after a battle never counts as walking.
						lastAt[player] = nil
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
		-- The spot may be in any biome the player has earned.
		local spawn: Encounters.Spawn? = nil
		local why: string? = "There is nothing there"
		for _, biome in biomes do
			if not spawn and world.biomeOfPlace[value.SpotId] == biome.number then
				if hooks.mayEnter(player, biome.number) then
					spawn, why = Encounters.rustle(
						book(player),
						biome,
						map,
						value.SpotId,
						at,
						now,
						seed(),
						newId
					)
				else
					why = "You have not earned your way here yet"
				end
			end
		end
		if spawn then
			send(player)
		else
			hooks.refuse(player, why or "Nothing stirs")
		end
	end)

	local stopTravel = Net.Travel.On(function(player, value)
		local now = os.clock()
		if now - (lastTravel[player] or -math.huge) < MIN_SECONDS_BETWEEN_TRAVELS then
			return
		end
		lastTravel[player] = now
		if not hooks.isReady(player) then
			return hooks.refuse(player, "Finish your battle first")
		end
		if WorldService.buildingAt(player, "Teleport", WorldConfig.TALK_RADIUS) == nil then
			return hooks.refuse(player, "You need to be at a Waystation to travel")
		end
		if not hooks.hasReached(player, value.BiomeNumber) then
			return hooks.refuse(player, "You have not been there yet")
		end
		for _, biome in biomes do
			if biome.number == value.BiomeNumber then
				for _, building in biome.hub.buildings do
					if building.role == "Teleport" then
						return WorldService.sendTo(player, building.id)
					end
				end
			end
		end
		hooks.refuse(player, "There is no Waystation there")
	end)

	local leaving = Players.PlayerRemoving:Connect(function(player)
		lastTravel[player] = nil
		local left = books[player]
		if left then
			timers[player.UserId] =
				{ rustledAt = left.rustledAt, freeAt = left.freeAt, leftAt = os.clock() }
		end
		books[player] = nil
		lastRustle[player] = nil
		lastAt[player] = nil
		for userId, kept in timers do
			if os.clock() - kept.leftAt > KEEP_TIMERS_SECONDS then
				timers[userId] = nil
			end
		end
	end)

	return function()
		running = false
		stopRustle()
		stopTravel()
		leaving:Disconnect()
	end
end

return WorldService
