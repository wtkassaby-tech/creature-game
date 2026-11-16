--!strict
-- Server side of breeding. The client only ever sends "breed these two" (through a Blink event in the real game);
-- everything else is checked and decided here.
--
-- A player's coins, creatures and eggs live in one saved profile (ProfileStore, session-locked),
-- so a breed changes them together in memory and they are saved together: all of it or none of it.

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BreedConfig = require(ReplicatedStorage.config.BreedConfig)
local Breeding = require(ReplicatedStorage.shared.Breeding)
local Rng = require(ReplicatedStorage.shared.Rng)
local Types = require(ReplicatedStorage.shared.Types)

export type Egg = { child: Types.Creature, hatchAt: number, seed: number }
export type PlayerData = {
	Coins: number,
	Candy: number, -- Breeding Candy, earned through play only
	Creatures: { [string]: Types.Creature },
	Eggs: { Egg },
	Pens: number, -- how many eggs can incubate at once
	Locked: { [string]: boolean }, -- creature ids held by a trade or a battle
}

-- Supplied by the data service: returns the loaded profile's data, or nil if it is not loaded.
export type GetData = (player: Player) -> PlayerData?
export type Log = (event: string, fields: { [string]: any }) -> ()

local MIN_SECONDS_BETWEEN_REQUESTS = 1

local BreedingService = {}
BreedingService.__index = BreedingService

export type BreedingService = typeof(setmetatable(
	{} :: { getData: GetData, log: Log, lastRequest: { [Player]: number }, random: Random },
	BreedingService
))

function BreedingService.new(getData: GetData, log: Log): BreedingService
	return setmetatable(
		{ getData = getData, log = log, lastRequest = {}, random = Random.new() },
		BreedingService
	)
end

local function isSlot(value: any): boolean
	return typeof(value) == "string" and table.find(BreedConfig.SLOTS, value :: any) ~= nil
end

-- Handles a breed request. Returns true and the egg's hatch time, or false and a reason for the UI.
function BreedingService.requestBreed(
	self: BreedingService,
	player: Player,
	idA: unknown,
	idB: unknown,
	charmSlot: unknown,
	charmFavour: unknown
): (boolean, string | number)
	-- 1. Rate limit and validate the types of everything the client sent.
	local now = os.time()
	if now - (self.lastRequest[player] or 0) < MIN_SECONDS_BETWEEN_REQUESTS then
		return false, "Too fast"
	end
	self.lastRequest[player] = now
	if typeof(idA) ~= "string" or typeof(idB) ~= "string" then
		return false, "Bad request"
	end
	local charm: Breeding.Charm? = nil
	if charmSlot ~= nil then
		if not isSlot(charmSlot) or (charmFavour ~= "A" and charmFavour ~= "B") then
			return false, "Bad request"
		end
		charm = { slot = charmSlot :: any, favour = charmFavour :: any }
	end

	-- 2. Everything else comes from the server's own copy of the player's data.
	local data = self.getData(player)
	if not data then
		return false, "Data not loaded"
	end
	local a, b = data.Creatures[idA], data.Creatures[idB]
	if not a or not b then
		return false, "You do not own those creatures"
	end
	if data.Locked[idA] or data.Locked[idB] then
		return false, "A parent is busy in a trade or battle"
	end
	if #data.Eggs >= data.Pens then
		return false, "No free pen"
	end
	local ok, reason = Breeding.canBreed(a, b, now)
	if not ok then
		return false, reason :: string
	end
	local cost = Breeding.cost(a, b)
	if data.Coins < cost then
		return false, "Not enough coins"
	end
	local candy = Breeding.candyCost(a, b)
	if data.Candy < candy then
		return false, "Not enough Breeding Candy"
	end
	-- A Bond Charm would be checked and taken from the inventory here.

	-- 3. Decide the child now, from a logged seed. Gems can later shorten the timer but never change the child.
	local seed = self.random:NextInteger(1, 2147483646)
	local result = Breeding.breed(a, b, Rng.new(seed), {
		childId = HttpService:GenerateGUID(false),
		now = now,
		charm = charm,
	})

	-- 4. Apply every change together. Nothing above this line has changed the player's data.
	data.Coins -= result.cost
	data.Candy -= result.candy
	a.breedCount, a.breedReadyAt = result.parentA.breedCount, result.parentA.breedReadyAt
	b.breedCount, b.breedReadyAt = result.parentB.breedCount, result.parentB.breedReadyAt
	table.insert(data.Eggs, { child = result.child, hatchAt = result.hatchAt, seed = seed })

	-- 5. Log it so any creature can be traced and any breed replayed.
	self.log("Breed", {
		player = player.UserId,
		a = idA,
		b = idB,
		child = result.child.id,
		seed = seed,
		cost = result.cost,
		candy = result.candy,
	})
	return true, result.hatchAt
end

-- Moves every finished egg into the stable. Called when the player opens the pens, or on a timer.
function BreedingService.collectHatched(self: BreedingService, player: Player): { Types.Creature }
	local data = self.getData(player)
	local hatched: { Types.Creature } = {}
	if not data then
		return hatched
	end
	local now = os.time()
	for index = #data.Eggs, 1, -1 do
		local egg = data.Eggs[index]
		if now >= egg.hatchAt then
			table.remove(data.Eggs, index)
			data.Creatures[egg.child.id] = egg.child
			table.insert(hatched, egg.child)
			self.log("Hatch", { player = player.UserId, child = egg.child.id })
		end
	end
	return hatched
end

function BreedingService.playerRemoving(self: BreedingService, player: Player)
	self.lastRequest[player] = nil
end

return BreedingService
