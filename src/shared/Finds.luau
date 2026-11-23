--!strict
-- Finds in side areas and dead ends (approval pack 7, docs/plans/14_FINDS_AND_REWARDS.md), as pure
-- rules on the saved profile. The finds service calls these and nothing else to claim a find, so
-- every rule lives in one tested place:
--   * A one-time find is checked and flagged in one step with no pause, and the items arrive in
--     the same step. A claim that does not fit under the carry limit is refused whole, with the
--     flag unset, so the player can come back.
--   * Renewable finds (gathering, sightings) count their use in Daily.finds, cleared by
--     Grants.rollDay with the server's date only.
--   * Nothing here pays coins, creatures or Gems. Prism Candy is paid only by a finished journal
--     set, through the economy's ledger (flow CandyJournal).
--   * Where the player must stand is judged from readings the server took itself (see FindTrail);
--     `Finds.reachProblem` turns them into a refusal.
-- No Roblox services are used.

local Economy = require("./Economy")
local FindIds = require("./FindIds")
local FindsConfig = require("../config/FindsConfig")
local Grants = require("./Grants")
local Layout = require("./Layout")
local Profile = require("./Profile")
local Registry = require("../content/Finds")
local WorldConfig = require("../config/WorldConfig")
local WorldTypes = require("./WorldTypes")

type Find = WorldTypes.Find
type JournalSet = WorldTypes.JournalSet

-- How a search went (the message's FindOutcome in src/net/Net.blink).
export type Outcome =
	"Found"
	| "Gathered"
	| "Read"
	| "Built"
	| "AlreadyFound"
	| "Resting"
	| "TooFar"
	| "Shut"
	| "Full"
export type Gain = { item: string, count: number }
export type Claim = {
	outcome: Outcome,
	find: Find,
	gains: { Gain },
	prism: number,
	setDone: boolean,
	set: JournalSet?,
	reason: string?,
}
-- What the server measured about the player for one search.
export type Reach = {
	distance: number, -- flat studs from the character to the find
	heightGap: number, -- how far the character's ground is from the find's ground
	lingered: number, -- seconds inside the search radius (FindTrail.lingered)
	fastest: number, -- the fastest step in the trail, studs a second (FindTrail.fastest)
}

local Finds = {}

local SUCCESS: { [string]: Outcome } = {
	Cache = "Found",
	Gather = "Gathered",
	Note = "Read",
	Cairn = "Built",
}

-- The find with this id in an open biome, or nil. `id` comes from the device, so anything that is
-- not a known string is simply not found.
function Finds.lookup(id: unknown): Find?
	if typeof(id) ~= "string" then
		return nil
	end
	return Registry.byId[id]
end

-- The journal set a note belongs to, or nil.
function Finds.setOf(find: Find): JournalSet?
	if find.kind ~= "Note" then
		return nil
	end
	for _, set in Registry.sets do
		if table.find(set.notes, find.id) then
			return set
		end
	end
	return nil
end

-- Where a find is on the map (world coordinates), or nil for a find with no place (a sighting is
-- its rustle spot's place, and a pending find is not built yet).
function Finds.point(map: Layout.Map, find: Find): Layout.Point?
	if find.pending then
		return nil
	end
	local sheet = find.at
	if sheet then
		return { x = map.hub.x + sheet.x, z = map.hub.z + sheet.z }
	end
	local routeId, along = find.route, find.along
	if routeId and along then
		local line = map.routes[routeId]
		if line then
			return Layout.pointAt(line, along, find.side)
		end
		return nil
	end
	local spot = find.spot
	if spot then
		return map.places[spot]
	end
	return nil
end

-- Whether the badges held open this find. Gathering opens with the first badge.
function Finds.opensWith(find: Find, badges: number): boolean
	if find.kind == "Gather" then
		return badges >= FindsConfig.GATHER_OPENS_BADGES
	end
	return true
end

-- True when the find can be reached at all: its place is built, and (for a note) so is every
-- other note of its set, which does not matter to reading it.
function Finds.isLive(find: Find): boolean
	return find.pending == nil
end

-- A journal set can be finished only when every one of its notes can be read.
function Finds.setIsLive(set: JournalSet): boolean
	for _, id in set.notes do
		local note = Registry.byId[id]
		if not note or note.pending then
			return false
		end
	end
	return true
end

-- Why a search is refused for where the player stands, or nil if the readings pass. The reason is
-- a short word for the log. Every check uses numbers the server measured itself.
function Finds.reachProblem(reach: Reach): string?
	if reach.distance ~= reach.distance or reach.heightGap ~= reach.heightGap then
		return "far"
	end
	if reach.distance > FindsConfig.SEARCH_RADIUS + WorldConfig.POSITION_SLACK then
		return "far"
	end
	if math.abs(reach.heightGap) > FindsConfig.HEIGHT_TOLERANCE then
		return "height"
	end
	if reach.lingered < FindsConfig.LINGER_SECONDS then
		return "linger"
	end
	if reach.fastest > FindsConfig.JUMP_SPEED_FACTOR * FindsConfig.WALK_SPEED then
		return "jump"
	end
	return nil
end

local function wholeDay(unixTime: number): number
	return math.floor(unixTime / 86400)
end

-- Today's use of a daily key (a gathering spot, a sighting spot, the gathered total).
local function usedToday(profile: Profile.Profile, key: string): number
	return profile.Daily.finds[key] or 0
end

local function isWholeCount(value: number): boolean
	return value == value and value >= 1 and value % 1 == 0
end

-- The items a find gives, with repeated items added together. Item and Material rewards only;
-- anything else in a find's data is ignored here (tests/finds.test refuses it in the data).
function Finds.gainsOf(find: Find): { Gain }
	local order: { string } = {}
	local totals: { [string]: number } = {}
	for _, reward in find.rewards do
		local key: string? = nil
		local count = 0
		if reward.kind == "Item" then
			key, count = reward.item, reward.count
		elseif reward.kind == "Material" then
			key, count = reward.material, reward.count
		end
		if key and isWholeCount(count) then
			if totals[key] == nil then
				table.insert(order, key)
				totals[key] = 0
			end
			totals[key] += count
		end
	end
	local gains: { Gain } = {}
	for _, key in order do
		table.insert(gains, { item = key, count = totals[key] })
	end
	return gains
end

local function refuse(find: Find, outcome: Outcome, reason: string): Claim
	return {
		outcome = outcome,
		find = find,
		gains = {},
		prism = 0,
		setDone = false,
		reason = reason,
	}
end

-- Claims a find on the profile, in one step with no pause. `unixTime` is the server's clock.
-- Everything is checked first and nothing is changed until every check has passed, so a refused
-- claim leaves the profile as it was (but for the day's counters rolling forward, which only the
-- server's date can do). The caller has already checked where the player stands.
function Finds.claim(profile: Profile.Profile, find: Find, unixTime: number): Claim
	if Registry.byId[find.id] ~= find then
		return refuse(find, "Shut", "not an open find")
	end
	if find.pending then
		return refuse(find, "Shut", "not built yet")
	end
	if find.kind == "Sighting" then
		return refuse(find, "Shut", "a sighting is stirred at its rustle spot")
	end
	if not Finds.opensWith(find, profile.Story.badges) then
		return refuse(find, "Shut", "opens with the first badge")
	end
	Grants.rollDay(profile, unixTime)

	local gains = Finds.gainsOf(find)
	local daily = find.kind == "Gather"
	local gathered = 0
	if daily then
		if profile.Daily.day ~= wholeDay(unixTime) then
			-- A clock that moved backwards: nothing renewable is paid on a day the record is past.
			return refuse(find, "Resting", "the day is behind the record")
		end
		if usedToday(profile, find.id) >= FindsConfig.GATHER_PER_SPOT_PER_DAY then
			return refuse(find, "Resting", "used today")
		end
		for _, gain in gains do
			gathered += gain.count
		end
		if
			usedToday(profile, FindsConfig.GATHERED_KEY) + gathered > FindsConfig.GATHER_DAILY_CAP
		then
			return refuse(find, "Resting", "gathered enough today")
		end
	elseif profile.Finds.once[find.id] then
		return refuse(find, "AlreadyFound", "claimed")
	end

	-- A note can finish its biome's journal set; the set pays once, with the note that completes it.
	local set = Finds.setOf(find)
	local setDone = false
	if set and not profile.Finds.once[set.id] then
		setDone = true
		for _, noteId in set.notes do
			if noteId ~= find.id and not profile.Finds.once[noteId] then
				setDone = false
			end
		end
	end
	local prism = if setDone then Economy.candyFor("JournalSet", 0) else 0

	-- Room: every item must fit under the carry limit, or the whole claim is refused.
	for _, gain in gains do
		if (profile.Items[gain.item] or 0) + gain.count > FindsConfig.MAX_HELD then
			return refuse(find, "Full", "no room to carry it")
		end
	end

	-- The journal's Prism is worked out before anything changes: if it cannot be paid, the whole
	-- claim is refused, so a set is never marked done without its Prism (review, 23 Nov 2026).
	local paidPrism: number? = nil
	if setDone and set and prism > 0 then
		local paid =
			Economy.apply({ coins = profile.Coins, candy = profile.Candy }, "CandyJournal", prism)
		if not paid.ok then
			return refuse(find, "Shut", "the journal's Prism could not be paid")
		end
		paidPrism = paid.balances.candy.prism
	end

	-- One step: flag or count, items, Prism.
	if daily then
		profile.Daily.finds[find.id] = usedToday(profile, find.id) + 1
		profile.Daily.finds[FindsConfig.GATHERED_KEY] = usedToday(profile, FindsConfig.GATHERED_KEY)
			+ gathered
	else
		profile.Finds.once[find.id] = true
	end
	for _, gain in gains do
		profile.Items[gain.item] = (profile.Items[gain.item] or 0) + gain.count
	end
	if setDone and set then
		profile.Finds.once[set.id] = true
		if paidPrism ~= nil then
			profile.Candy.prism = paidPrism
		end
	end
	return {
		outcome = SUCCESS[find.kind],
		find = find,
		gains = gains,
		prism = prism,
		setDone = setDone,
		set = if setDone then set else nil,
		reason = nil,
	}
end

-- True if a sighting spot's stir may bring out a rare creature now: the spot's use today is below
-- the limit. Rolls the day on the server's clock. Never changes anything else.
function Finds.sightingFree(profile: Profile.Profile, find: Find, unixTime: number): boolean
	if find.kind ~= "Sighting" or find.pending then
		return false
	end
	Grants.rollDay(profile, unixTime)
	return profile.Daily.day == wholeDay(unixTime)
		and usedToday(profile, find.id) < FindsConfig.SIGHTINGS_PER_SPOT_PER_DAY
end

-- Counts a sighting's use, in the same step that the creature steps out. Returns false, changing
-- nothing, if it was not free.
function Finds.markSighting(profile: Profile.Profile, find: Find, unixTime: number): boolean
	if not Finds.sightingFree(profile, find, unixTime) then
		return false
	end
	profile.Daily.finds[find.id] = usedToday(profile, find.id) + 1
	return true
end

-- The sighting find for a rustle spot, or nil if the spot is not a sighting spot.
function Finds.sightingAt(spotId: unknown): Find?
	if typeof(spotId) ~= "string" then
		return nil
	end
	for _, find in Registry.list do
		if find.kind == "Sighting" and find.spot == spotId and not find.pending then
			return find
		end
	end
	return nil
end

-- Keepsakes owned, from the claimed one-time ids (the saved record's, or the list the device is
-- sent): a cairn's once it is built, a set's once it is finished.
function Finds.keepsakesOf(claimed: { [string]: boolean }): { WorldTypes.Keepsake }
	local owned: { WorldTypes.Keepsake } = {}
	for _, find in Registry.list do
		if find.keepsake and claimed[find.id] then
			table.insert(owned, find.keepsake)
		end
	end
	for _, set in Registry.sets do
		if claimed[set.id] then
			table.insert(owned, set.keepsake)
		end
	end
	return owned
end

function Finds.keepsakes(profile: Profile.Profile): { WorldTypes.Keepsake }
	return Finds.keepsakesOf(profile.Finds.once)
end

-- The journal's count for one biome: one-time finds (caches, notes, the cairn) and the set, only
-- counting what can be reached now. Returns how many are claimed and how many there are.
function Finds.progressOf(claimed: { [string]: boolean }, biome: number): (number, number)
	local found, total = 0, 0
	for _, find in Registry.list do
		if find.biome == biome and FindIds.isOnceId(find.id) and not find.pending then
			total += 1
			if claimed[find.id] then
				found += 1
			end
		end
	end
	for _, set in Registry.sets do
		if set.biome == biome and Finds.setIsLive(set) then
			total += 1
			if claimed[set.id] then
				found += 1
			end
		end
	end
	return found, total
end

function Finds.progress(profile: Profile.Profile, biome: number): (number, number)
	return Finds.progressOf(profile.Finds.once, biome)
end

return Finds
