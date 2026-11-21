--!strict
-- Server side of breeding. The player's device only ever sends "breed these two" (through a
-- Blink event once networking exists); everything else is checked and decided here.
--
-- A player's coins, candy, items, creatures and eggs live in one saved profile, so a breed
-- changes them together in memory, with no pause in between, and they are saved together:
-- all of it or none of it.
--
-- Not yet run in Studio. It needs the data service (approval pack 1) and approval pack 3
-- before it is wired up.

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Breeding = require(ReplicatedStorage.shared.Breeding)
local Economy = require(ReplicatedStorage.shared.Economy)
local Grants = require(ReplicatedStorage.shared.Grants)
local Profile = require(ReplicatedStorage.shared.Profile)
local Rng = require(ReplicatedStorage.shared.Rng)
local Types = require(ReplicatedStorage.shared.Types)
local LiveConfigService = require(script.Parent.Parent.LiveConfig.LiveConfigService)

-- Supplied by the data service: the loaded profile, or nil if it is not loaded on this server
-- right now (never a stale copy: once a session ends this must return nil at once).
export type GetData = (player: Player) -> Profile.Profile?
-- Supplied by the battle and trade services: true while a creature is in a battle or a trade.
-- Locks live only in server memory, never in the saved record, so a crash cannot leave a
-- creature locked for good.
export type IsLocked = (player: Player, creatureId: string) -> boolean
export type Log = (event: string, fields: { [string]: any }) -> ()
-- Supplied by the story: true once the player has reached the beat that opens breeding.
export type IsOpen = (data: Profile.Profile) -> boolean

local MIN_SECONDS_BETWEEN_REQUESTS = 1
local CHARM_ITEM = "BondCharm"

local BreedingService = {}
BreedingService.__index = BreedingService

export type BreedingService = typeof(setmetatable(
	{} :: {
		getData: GetData,
		isLocked: IsLocked,
		isOpen: IsOpen,
		log: Log,
		lastRequest: { [Player]: number },
		random: Random,
	},
	BreedingService
))

function BreedingService.new(
	getData: GetData,
	isLocked: IsLocked,
	isOpen: IsOpen,
	log: Log
): BreedingService
	return setmetatable({
		getData = getData,
		isLocked = isLocked,
		isOpen = isOpen,
		log = log,
		lastRequest = {},
		random = Random.new(),
	}, BreedingService)
end

local function countCreatures(data: Profile.Profile): number
	local count = 0
	for _ in data.Creatures do
		count += 1
	end
	return count
end

-- Handles a breed request. Returns true and the egg's hatch time, or false and a reason for
-- the screen. Nothing in this function pauses, so no other request can run in the middle of it.
function BreedingService.requestBreed(
	self: BreedingService,
	player: Player,
	idA: unknown,
	idB: unknown,
	charmSlot: unknown,
	charmFavour: unknown
): (boolean, string | number)
	-- 1. Rate limit and check the type of everything the device sent.
	local now = os.clock()
	if now - (self.lastRequest[player] or -math.huge) < MIN_SECONDS_BETWEEN_REQUESTS then
		return false, "Too fast"
	end
	self.lastRequest[player] = now
	if typeof(idA) ~= "string" or typeof(idB) ~= "string" then
		return false, "Bad request"
	end
	local charm = Breeding.parseCharm(charmSlot, charmFavour)
	if (charmSlot ~= nil or charmFavour ~= nil) and not charm then
		return false, "Bad request"
	end

	-- 2. Everything else comes from the server's own copy of the player's data.
	local data = self.getData(player)
	if not data then
		return false, "Data not loaded"
	end
	if not LiveConfigService.isOn("breeding_open") then
		return false, LiveConfigService.closedText()
	end
	if not self.isOpen(data) then
		return false, "Breeding is not open to you yet"
	end
	local a, b = data.Creatures[idA], data.Creatures[idB]
	if not a or not b then
		return false, "You do not own those creatures"
	end
	if self.isLocked(player, idA) or self.isLocked(player, idB) then
		return false, "A parent is busy in a trade or battle"
	end
	if #data.Eggs >= data.Pens then
		return false, "No free pen"
	end
	local time = os.time()
	local ok, reason = Breeding.canBreed(a, b, time)
	if not ok then
		return false, reason or "Those two cannot breed"
	end
	local cost = Breeding.cost(a, b)
	if data.Coins < cost then
		return false, "Not enough coins"
	end
	-- Each parent needs candy of its own type; typed candy is used first, then Prism.
	local payment = Economy.candyPayment(data.Candy, Breeding.candyCost(a, b))
	if not payment then
		return false, "Not enough Breeding Candy"
	end
	local candyAfter = Economy.payCandy(data.Candy, payment)
	if not candyAfter then
		return false, "Not enough Breeding Candy"
	end
	-- A captured giant needs its own Giant Candy, which nothing else can stand in for.
	local giantNeeds = Breeding.giantCandyCost(a, b)
	if not Breeding.hasGiantCandy(data.Items, giantNeeds, Economy.giantCandyKey) then
		return false, "Not enough Giant Candy: beat the giant again to earn more"
	end
	-- A charm only counts if the player owns one; it is used up below with everything else.
	if charm and (data.Items[CHARM_ITEM] or 0) < 1 then
		return false, "No Bond Charm"
	end

	-- 3. Decide the child now, from a logged seed. Gems can later shorten the timer but never
	-- change the child.
	local seed = self.random:NextInteger(1, 2147483646)
	local result = Breeding.breed(a, b, Rng.new(seed), {
		childId = HttpService:GenerateGUID(false),
		now = time,
		charm = charm,
	})

	-- 4. Apply every change together. Nothing above this line has changed the player's data.
	data.Coins -= result.cost
	data.Candy = candyAfter -- worked out above from this same balance, with no pause since
	for _, need in giantNeeds do
		data.Items[Economy.giantCandyKey(need.species)] -= need.amount
	end
	if charm then
		data.Items[CHARM_ITEM] -= 1
	end
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
		candyTyped = payment.typed,
		candyPrism = payment.prism,
		giantCandy = giantNeeds,
		charm = charm ~= nil,
	})
	return true, result.hatchAt
end

-- Moves finished eggs into the stable while there is room. An egg whose time is up but which
-- has nowhere to go stays in its pen: nothing is lost, and the stable never goes over capacity.
function BreedingService.collectHatched(self: BreedingService, player: Player): { Types.Creature }
	local data = self.getData(player)
	local hatched: { Types.Creature } = {}
	if not data then
		return hatched
	end
	local now = os.time()
	local room = data.StableCapacity - countCreatures(data)
	local index = 1
	while index <= #data.Eggs and room > 0 do
		local egg = data.Eggs[index]
		if now >= egg.hatchAt then
			table.remove(data.Eggs, index)
			data.Creatures[egg.child.id] = egg.child
			Grants.recordOwned(data, egg.child)
			table.insert(hatched, egg.child)
			room -= 1
			self.log("Hatch", { player = player.UserId, child = egg.child.id })
		else
			index += 1
		end
	end
	return hatched
end

function BreedingService.playerRemoving(self: BreedingService, player: Player)
	self.lastRequest[player] = nil
end

return BreedingService
