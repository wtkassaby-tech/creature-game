--!strict
-- Every way a creature enters or leaves a player's record (approval pack 2), as pure functions
-- on the saved profile. The server services call these and nothing else to add or remove a
-- creature, so the rules live in one tested place:
--   * Only the server creates creatures; these functions take a finished creature from it.
--   * Each change is made in one step with no pause: the creature, its one-time flag, its candy
--     and its log entry go in together or not at all.
--   * One-time gifts are never lost: with no room they wait in the saved Pending list.
--   * A giant is captured in two steps around the wait for its serial number (pack 2 section 5).

local BreedConfig = require("../config/BreedConfig")
local Economy = require("./Economy")
local Profile = require("./Profile")
local Species = require("../content/Species")
local Types = require("./Types")

type Profile = Profile.Profile
type Creature = Types.Creature

export type Source = "Starter" | "MentorEgg" | "Quest" | "Token" | "Giant" | "Wild" | "Gem"
export type Outcome = "Granted" | "Waiting" | "AlreadyGranted" | "NoRoom" | "Refused"
export type Grant = { outcome: Outcome, reason: string?, candy: number?, element: Types.Element? }

local Grants = {}

local SECONDS_PER_DAY = 86400

local function count(profile: Profile): number
	local n = 0
	for _ in profile.Creatures do
		n += 1
	end
	return n
end

-- Free stable places right now.
function Grants.room(profile: Profile): number
	return profile.StableCapacity - count(profile)
end

-- The element of a creature: its torso sets it.
function Grants.element(creature: Creature): Types.Element
	local element: Types.Element = Species[creature.parts.Torso.species].element
	return element
end

local function flagKey(source: Source, ref: string): string
	return `grant:{source}:{ref}`
end

function Grants.alreadyGranted(profile: Profile, source: Source, ref: string): boolean
	return profile.Story.flags[flagKey(source, ref)] == true
end

local function isWaiting(profile: Profile, source: Source, ref: string): boolean
	for _, pending in profile.Pending do
		if pending.source == source and pending.ref == ref then
			return true
		end
	end
	return false
end

-- Set by src/shared/DailyProgress: called just before a day's counters are cleared.
Grants.beforeRoll = nil :: ((profile: Profile) -> ())?

-- Starts a new day's counters if the server's date has moved on. Only the server's clock is
-- ever used, so changing a device's clock cannot reset anything.
function Grants.rollDay(profile: Profile, unixTime: number)
	local day = math.floor(unixTime / SECONDS_PER_DAY)
	if day > profile.Daily.day and Grants.beforeRoll then
		-- Last chance to settle the old day (finished daily tasks are paid, not lost).
		Grants.beforeRoll(profile)
	end
	-- Only forwards: servers whose clocks disagree near midnight cannot reset a day twice.
	if day > profile.Daily.day then
		profile.Daily.day = day
		profile.Daily.wildWins = {}
		profile.Daily.tasksDone = {}
		profile.Daily.claimed = {}
		profile.Daily.catches = Economy.zeroByElement()
		profile.Daily.releases = Economy.zeroByElement()
	end
end

-- A one-time gift (starter, mentor's egg, quest reward, clear token). `make` builds the creature
-- only when there is room, so a waiting gift is made fresh when it is finally handed over.
-- The flag is set in the same step either way, so the gift can never be earned twice.
function Grants.giveOnce(profile: Profile, source: Source, ref: string, make: () -> Creature): Grant
	if source == "Wild" or source == "Giant" then
		return { outcome = "Refused", reason = "Wild creatures and giants have their own steps" }
	end
	if Grants.alreadyGranted(profile, source, ref) then
		return { outcome = "AlreadyGranted" }
	end
	profile.Story.flags[flagKey(source, ref)] = true
	if Grants.room(profile) < 1 then
		local entry: Profile.PendingGrant = { source = source :: string, ref = ref }
		table.insert(profile.Pending, entry)
		return {
			outcome = "Waiting",
			reason = "Your stable is full: it will arrive when there is room",
		}
	end
	local creature = make()
	profile.Creatures[creature.id] = creature
	Grants.recordOwned(profile, creature)
	return { outcome = "Granted" }
end

-- Records a creature that has just joined the stable: in the Index, and on the team if the team
-- is empty (a starter that had to wait must not leave the player with nobody to battle with).
function Grants.recordOwned(profile: Profile, creature: Creature)
	local key = creature.parts.Torso.species
	profile.Index.owned[key] = true
	profile.Index.seen[key] = true
	if #profile.Team == 0 then
		table.insert(profile.Team, creature.id)
	end
end

-- Hands over waiting gifts while there is room. `make` rebuilds a gift from its source and ref
-- (nil if the content no longer exists, in which case the entry is kept and reported).
-- Giants waiting for a serial number are left alone here.
function Grants.claimPending(
	profile: Profile,
	make: (source: string, ref: string) -> Creature?
): number
	local handed = 0
	local index = 1
	while index <= #profile.Pending and Grants.room(profile) > 0 do
		local pending = profile.Pending[index]
		local creature = if pending.source == "Giant"
			then nil
			else make(pending.source, pending.ref)
		if creature then
			table.remove(profile.Pending, index)
			profile.Creatures[creature.id] = creature
			Grants.recordOwned(profile, creature)
			handed += 1
		else
			index += 1
		end
	end
	return handed
end

-- A wild capture after a lasso hit. The stable was checked before the throw; this checks again,
-- adds the creature and pays typed candy for its type, all in one step.
local function deepCopy<T>(value: T): T
	if type(value) ~= "table" then
		return value
	end
	local copy = {}
	for key, child in value :: any do
		copy[key] = deepCopy(child)
	end
	return copy :: any
end

function Grants.capture(profile: Profile, creature: Creature): Grant
	if Grants.room(profile) < 1 then
		return { outcome = "NoRoom", reason = "Your stable is full" }
	end
	if profile.Creatures[creature.id] then
		return { outcome = "Refused", reason = "That creature is already yours" }
	end
	if isWaiting(profile, "Gem", creature.id) then
		return { outcome = "Refused", reason = "That creature is already yours" }
	end
	local element: Types.Element = Grants.element(creature)
	local prior = profile.Daily.catches[element]
	local candy = Economy.catchCandy(creature.rarity, prior)
	profile.Daily.catches[element] = prior + 1
	profile.Candy.typed[element] += candy
	-- A copy, so the battle's (or a spawner's) table can never be shared with the saved record.
	local caught = deepCopy(creature)
	if Grants.needsSerial(caught) then
		-- A gem-tier find gets a serial number, which takes a moment to fetch. Until then the
		-- catch waits in the saved list, creature and all; it joins the stable with its number
		-- (Grants.finishGem). The candy is paid now: the catch has happened.
		table.insert(profile.Pending, { source = "Gem", ref = caught.id, creature = caught })
		local waiting: Grant = { outcome = "Waiting", candy = candy, element = element }
		return waiting
	end
	profile.Creatures[caught.id] = caught
	Grants.recordOwned(profile, caught)
	local granted: Grant = { outcome = "Granted", candy = candy, element = element }
	return granted
end

-- True for a wild catch that must carry a serial number: a gem tier, not a giant, with none yet.
function Grants.needsSerial(creature: Creature): boolean
	return BreedConfig.SERIAL_RARITIES[creature.rarity]
		and not creature.isGiant
		and creature.serial == nil
end

-- The kind a serial number counts within: each giant, and each tier of each species.
function Grants.serialKind(source: string, ref: string, creature: Creature?): string
	if source == "Gem" and creature then
		return `Gem:{creature.rarity}:{creature.parts.Torso.species}`
	end
	return `{source}:{ref}`
end

-- Waiting catches and captures (gem finds, giants) that have no serial number yet.
function Grants.awaitingSerial(profile: Profile): { Profile.PendingGrant }
	local list: { Profile.PendingGrant } = {}
	for _, pending in profile.Pending do
		if (pending.source == "Gem" or pending.source == "Giant") and pending.serial == nil then
			table.insert(list, pending)
		end
	end
	return list
end

-- Writes a fetched serial number onto a waiting entry (saved with the profile), once. Returns
-- false, changing nothing, if nothing of that kind is waiting or it already has a number.
function Grants.keepSerial(profile: Profile, source: string, ref: string, serial: number): boolean
	if typeof(serial) ~= "number" or serial % 1 ~= 0 or serial < 1 then
		return false
	end
	for _, pending in profile.Pending do
		if pending.source == source and pending.ref == ref then
			if pending.serial ~= nil then
				return false
			end
			pending.serial = serial
			return true
		end
	end
	return false
end

-- A waiting gem catch whose number has arrived joins the stable, carrying it. With a full
-- stable it keeps waiting, number and all ("NoRoom").
function Grants.finishGem(profile: Profile, creatureId: string): Grant
	for index, pending in profile.Pending do
		if pending.source == "Gem" and pending.ref == creatureId then
			local creature = pending.creature
			if not creature or pending.serial == nil then
				return { outcome = "Refused", reason = "That catch has no number yet" }
			end
			if Grants.room(profile) < 1 then
				return {
					outcome = "NoRoom",
					reason = "Your stable is full: it waits until there is room",
				}
			end
			creature.serial = pending.serial
			table.remove(profile.Pending, index)
			profile.Creatures[creature.id] = creature
			Grants.recordOwned(profile, creature)
			return { outcome = "Granted" }
		end
	end
	return { outcome = "Refused", reason = "No such catch is waiting" }
end

-- Giant step 1, on the winning lasso hit and with no pause: the capture is written into the
-- waiting list. Refused if this giant was ever captured or is already waiting.
function Grants.startGiant(profile: Profile, giantId: string): Grant
	if profile.Story.giantsCaptured[giantId] then
		return { outcome = "AlreadyGranted" }
	end
	if isWaiting(profile, "Giant", giantId) then
		return { outcome = "Refused", reason = "That capture is already being finished" }
	end
	table.insert(profile.Pending, { source = "Giant", ref = giantId })
	return { outcome = "Waiting" }
end

-- Giant step 3, after the serial number arrives: checks the capture is still waiting, then adds
-- the giant (already carrying its serial and bound), marks it captured and clears the waiting
-- entry, in one step. With a full stable it stays waiting (NoRoom) and is finished later. The caller checks
-- Grants.room before fetching a serial, or keeps the fetched serial on the waiting entry, so a
-- full stable never uses up serial numbers.
function Grants.finishGiant(profile: Profile, giantId: string, giant: Creature): Grant
	if profile.Story.giantsCaptured[giantId] then
		return { outcome = "AlreadyGranted" }
	end
	if not giant.isGiant or not giant.bound or giant.serial == nil then
		return { outcome = "Refused", reason = "A giant must be bound and carry its serial number" }
	end
	local at: number? = nil
	for index, pending in profile.Pending do
		if pending.source == "Giant" and pending.ref == giantId then
			at = index
			break
		end
	end
	if at == nil then
		return { outcome = "Refused", reason = "No capture of that giant is waiting" }
	end
	if Grants.room(profile) < 1 then
		return {
			outcome = "NoRoom",
			reason = "Your stable is full: the giant waits until there is room",
		}
	end
	table.remove(profile.Pending, at)
	profile.Story.giantsCaptured[giantId] = true
	profile.Creatures[giant.id] = giant
	return { outcome = "Granted" }
end

-- Releasing a creature: it leaves the game for good, paying coins, a material and typed candy.
-- Refused for a creature that is locked (in a battle or a trade) or is the last one on the team.
function Grants.release(profile: Profile, creatureId: string, isLocked: boolean): Grant
	local creature = profile.Creatures[creatureId]
	if not creature then
		return { outcome = "Refused", reason = "You do not own that creature" }
	end
	if isLocked then
		return { outcome = "Refused", reason = "That creature is busy in a battle or a trade" }
	end
	if creature.isGiant then
		-- A giant can be caught once per player, ever; releasing it would lose it for good.
		return { outcome = "Refused", reason = "A giant cannot be released" }
	end
	local onTeam = table.find(profile.Team, creatureId)
	if onTeam and #profile.Team == 1 then
		return { outcome = "Refused", reason = "You need at least one creature on your team" }
	end
	local element: Types.Element = Grants.element(creature)
	local prior = profile.Daily.releases[element]
	local candy = Economy.releaseCandy(creature.rarity, prior)
	local payout = Economy.releasePayout(creature.rarity, creature.originBiome)

	profile.Daily.releases[element] = prior + 1
	profile.Candy.typed[element] += candy
	profile.Coins += payout.coins
	if payout.material and payout.materials > 0 then
		profile.Items[payout.material] = (profile.Items[payout.material] or 0) + payout.materials
	end
	if onTeam then
		table.remove(profile.Team, onTeam)
	end
	profile.Creatures[creatureId] = nil
	local granted: Grant = { outcome = "Granted", candy = candy, element = element }
	return granted
end

return Grants
