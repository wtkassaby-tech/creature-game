--!strict
-- A player's saved data: its shape, the values a new player starts with, migrations between
-- versions, and checks that catch a broken save before it is used.
--
-- Everything that must change together (coins, candy, creatures, eggs, items) lives in this one
-- record, so a breed, a capture or a purchase is saved whole or not at all. No Roblox services
-- are used here: the data service on the server loads and saves this through ProfileStore.

local BreedConfig = require("../config/BreedConfig")
local ProfileConfig = require("../config/ProfileConfig")
local Types = require("./Types")

export type Egg = { child: Types.Creature, hatchAt: number, seed: number }

export type Story = {
	starter: string?, -- species name of the chosen starter; nil until chosen
	chapter: number, -- 1..11
	badges: number,
	biomeReached: number,
	flags: { [string]: boolean }, -- story moments seen
	giantsCaptured: { [string]: boolean }, -- giant id -> true; each can be captured once
}

export type Daily = {
	day: number, -- days since the epoch (UTC) these counters belong to
	wildWins: { [string]: number }, -- species name -> wins today, for the diminishing coin rule
	tasksDone: { [string]: number },
	claimed: { [string]: boolean },
}

export type Settings = {
	battleSpeed: number,
	lassoSlowMode: boolean,
	lassoHoldMode: boolean,
	reducedMotion: boolean,
}

export type Profile = {
	SchemaVersion: number,
	Coins: number,
	Gems: number,
	Candy: number,
	Creatures: { [string]: Types.Creature }, -- keyed by creature id
	Team: { string }, -- creature ids, in battle order
	Eggs: { Egg },
	Pens: number,
	StableCapacity: number,
	Items: { [string]: number }, -- item id -> count
	Story: Story,
	Quests: { active: { [string]: number }, done: { [string]: boolean } },
	Daily: Daily,
	Index: { seen: { [string]: boolean }, owned: { [string]: boolean } },
	Purchases: { passes: { [string]: boolean }, receiptIds: { string } },
	Settings: Settings,
	PlayStats: { firstJoin: number, playSeconds: number, sessions: number },
}

-- A migration upgrades saved data from version N to N + 1, in place.
export type Migration = (data: any) -> ()

local Profile = {}

Profile.CURRENT_VERSION = ProfileConfig.SCHEMA_VERSION

-- MIGRATIONS[n] upgrades a save from version n to n + 1. Version 1 is the first, so this is empty.
-- Every entry added here ships with a test in tests/profile.test.luau.
local MIGRATIONS: { [number]: Migration } = {}
Profile.MIGRATIONS = MIGRATIONS

-- A brand-new player's data. Returns a fresh table every call, so two players never share one.
function Profile.template(): Profile
	return {
		SchemaVersion = Profile.CURRENT_VERSION,
		Coins = ProfileConfig.STARTING_COINS,
		Gems = 0,
		Candy = 0,
		Creatures = {},
		Team = {},
		Eggs = {},
		Pens = ProfileConfig.STARTING_PENS,
		StableCapacity = ProfileConfig.STARTING_STABLE_CAPACITY,
		Items = {},
		Story = {
			starter = nil,
			chapter = 1,
			badges = 0,
			biomeReached = 1,
			flags = {},
			giantsCaptured = {},
		},
		Quests = { active = {}, done = {} },
		Daily = { day = 0, wildWins = {}, tasksDone = {}, claimed = {} },
		Index = { seen = {}, owned = {} },
		Purchases = { passes = {}, receiptIds = {} },
		Settings = {
			battleSpeed = ProfileConfig.DEFAULT_BATTLE_SPEED,
			lassoSlowMode = false,
			lassoHoldMode = false,
			reducedMotion = false,
		},
		PlayStats = { firstJoin = 0, playSeconds = 0, sessions = 0 },
	}
end

-- How many creatures the player may field, from the badges held.
function Profile.teamSize(badges: number): number
	local sizes = ProfileConfig.TEAM_SIZE_BY_BADGES
	return sizes[math.clamp(badges + 1, 1, #sizes)]
end

local function deepCopy(value: any): any
	if typeof(value) ~= "table" then
		return value
	end
	local copy = {}
	for key, child in value do
		copy[key] = deepCopy(child)
	end
	return copy
end

-- Brings saved data up to a target version by running each migration in turn, on a copy.
-- Returns the migrated copy, or nil and a reason. The data passed in is never changed, so a
-- failed or half-finished migration can never be saved by accident. On nil the data service
-- must not use or overwrite the save: this covers a save from a newer version of the game.
function Profile.migrateWith(
	data: any,
	migrations: { [number]: Migration },
	targetVersion: number
): (any?, string?)
	if typeof(data) ~= "table" then
		return nil, "save is not a table"
	end
	local version = data.SchemaVersion
	if typeof(version) ~= "number" or version < 1 or version % 1 ~= 0 then
		return nil, "save has no valid SchemaVersion"
	end
	if version > targetVersion then
		return nil,
			`save is version {version}, newer than this server ({targetVersion}); refusing to load it`
	end
	local migrated = deepCopy(data)
	while version < targetVersion do
		local migration = migrations[version]
		if not migration then
			return nil, `no migration from version {version}`
		end
		local ok, problem = pcall(function()
			migration(migrated)
		end)
		if not ok then
			return nil, `migration from version {version} failed: {tostring(problem)}`
		end
		version += 1
		migrated.SchemaVersion = version
	end
	return migrated, nil
end

function Profile.migrate(data: any): (Profile?, string?)
	local migrated, problem = Profile.migrateWith(data, MIGRATIONS, Profile.CURRENT_VERSION)
	return migrated :: Profile?, problem
end

-- Remembers a processed purchase id. Returns false if it was already processed, in which case
-- the purchase must not be granted again. Keeps only the most recent ids.
function Profile.rememberReceipt(profile: Profile, purchaseId: string): boolean
	local ids = profile.Purchases.receiptIds
	if table.find(ids, purchaseId) then
		return false
	end
	table.insert(ids, purchaseId)
	while #ids > ProfileConfig.RECEIPTS_REMEMBERED do
		table.remove(ids, 1)
	end
	return true
end

-- True if a value can be stored by Roblox data stores: tables are either lists or have only
-- string keys, numbers are finite, and nothing is a function or other unsaveable value.
function Profile.isStorable(value: any, path: string?): (boolean, string?)
	local where = path or "root"
	local kind = typeof(value)
	if kind == "nil" or kind == "string" or kind == "boolean" then
		return true, nil
	elseif kind == "number" then
		if value ~= value or value == math.huge or value == -math.huge then
			return false, `{where} is not a finite number`
		end
		return true, nil
	elseif kind ~= "table" then
		return false, `{where} is a {kind}, which cannot be saved`
	end
	local count, stringKeys = 0, 0
	for key, child in value do
		count += 1
		local keyKind = typeof(key)
		if keyKind == "string" then
			stringKeys += 1
		elseif keyKind ~= "number" then
			return false, `{where} has a {keyKind} key`
		end
		local ok, problem = Profile.isStorable(child, `{where}.{tostring(key)}`)
		if not ok then
			return false, problem
		end
	end
	if stringKeys > 0 and stringKeys < count then
		return false, `{where} mixes list entries and named keys`
	end
	if stringKeys == 0 and count ~= #value then
		return false, `{where} is a list with gaps`
	end
	return true, nil
end

local function isWholeNumber(value: any): boolean
	return typeof(value) == "number" and value == value and value % 1 == 0
end

local function checkCreature(id: string, creature: Types.Creature, problems: { string })
	if creature.id ~= id then
		table.insert(problems, `creature {id} is stored under the wrong id ({creature.id})`)
	end
	if not isWholeNumber(creature.level) or creature.level < 1 then
		table.insert(problems, `creature {id} has a bad level`)
	end
	if not isWholeNumber(creature.breedCount) or creature.breedCount < 0 then
		table.insert(problems, `creature {id} has a bad breed count`)
	end
	if typeof(creature.xp) ~= "number" or creature.xp < 0 then
		table.insert(problems, `creature {id} has bad xp`)
	end
	for _, slot: Types.Slot in BreedConfig.SLOTS do
		local part = creature.parts[slot]
		if typeof(part) ~= "table" or typeof(part.species) ~= "string" then
			table.insert(problems, `creature {id} is missing its {slot}`)
		elseif
			not isWholeNumber(part.quality)
			or part.quality < BreedConfig.QUALITY_MIN
			or part.quality > BreedConfig.QUALITY_MAX
		then
			table.insert(problems, `creature {id} has a {slot} quality outside 0-10`)
		end
	end
end

-- Lists everything wrong with a loaded profile. An empty list means it is sound.
-- The data service logs problems as an alarm; it never deletes data because of them.
function Profile.validate(profile: Profile): { string }
	local problems: { string } = {}

	local function checkBalance(name: string, amount: number)
		if not isWholeNumber(amount) or amount < 0 then
			table.insert(problems, `{name} is not a whole number of zero or more`)
		end
	end
	checkBalance("Coins", profile.Coins)
	checkBalance("Gems", profile.Gems)
	checkBalance("Candy", profile.Candy)

	local owned = 0
	for id, creature in profile.Creatures do
		owned += 1
		checkCreature(id, creature, problems)
	end
	if owned > profile.StableCapacity then
		table.insert(
			problems,
			`owns {owned} creatures but the stable holds {profile.StableCapacity}`
		)
	end

	local seenOnTeam: { [string]: boolean } = {}
	for _, id in profile.Team do
		if not profile.Creatures[id] then
			table.insert(problems, `team lists creature {id}, which is not owned`)
		end
		if seenOnTeam[id] then
			table.insert(problems, `team lists creature {id} twice`)
		end
		seenOnTeam[id] = true
	end
	if #profile.Team > Profile.teamSize(profile.Story.badges) then
		table.insert(problems, "team is larger than the badges allow")
	end

	if profile.Pens < 1 or profile.Pens > ProfileConfig.MAX_PENS then
		table.insert(problems, "pens outside the allowed range")
	end
	if #profile.Eggs > profile.Pens then
		table.insert(problems, "more eggs than pens")
	end
	for index, egg in profile.Eggs do
		local id = egg.child.id
		if profile.Creatures[id] then
			table.insert(
				problems,
				`egg {index} holds creature {id}, which is already in the stable`
			)
		end
		checkCreature(id, egg.child, problems)
	end

	for item, count in profile.Items do
		if not isWholeNumber(count) or count < 0 then
			table.insert(problems, `item {item} has a bad count`)
		end
	end

	local storable, why = Profile.isStorable(profile)
	if not storable then
		table.insert(problems, `cannot be saved: {why or "unknown"}`)
	end
	return problems
end

return Profile
