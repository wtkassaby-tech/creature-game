--!strict
-- A player's saved data: its shape, the values a new player starts with, migrations between
-- versions, and checks that catch a broken save before it is used.
--
-- Everything that must change together (coins, candy, creatures, eggs, items) lives in this one
-- record, so a breed, a capture or a purchase is saved whole or not at all. No Roblox services
-- are used here: the data service on the server loads and saves this through ProfileStore.
--
-- This file runs past 400 lines on purpose: the shape and every check on it belong together,
-- so a change to one is made beside the other.

local BreedConfig = require("../config/BreedConfig")
local Economy = require("./Economy")
local ProfileConfig = require("../config/ProfileConfig")
local Species = require("../content/Species")
local TypeChart = require("./TypeChart")
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
	-- Catches and releases already counted today, per type, for the typed candy falloff
	-- (Economy.catchCandy, Economy.releaseCandy). Saved, so leaving and rejoining cannot reset it.
	catches: Types.ByElement<number>,
	releases: Types.ByElement<number>,
}

-- Something the player has earned but not yet received: a one-time gift waiting for room in the
-- stable, or a captured giant waiting for its serial number. Saved, so it survives leaving.
-- A captured giant's entry also keeps its serial number once fetched (`serial`), so the number
-- is asked for once and never wasted if the giant then has to wait for room.
-- A wild gem-tier catch waits the same way, and its entry holds the creature itself until then.
export type PendingGrant =
	{ source: string, ref: string, serial: number?, creature: Types.Creature? }

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
	-- Typed Breeding Candy, one balance per element, plus Prism Candy that counts as any type.
	-- This shape replaced a single number on 20 November 2026, before any save had shipped, so
	-- the template changed directly and no migration was needed (playtest saves are wiped at the
	-- soft launch). Any change from here on needs a migration.
	Candy: Types.CandyWallet,
	Creatures: { [string]: Types.Creature }, -- keyed by creature id
	Team: { string }, -- creature ids, in battle order
	Eggs: { Egg },
	Pending: { PendingGrant },
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
		Candy = Economy.emptyWallet(),
		Creatures = {},
		Team = {},
		Eggs = {},
		Pending = {},
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
		Daily = {
			day = 0,
			wildWins = {},
			tasksDone = {},
			claimed = {},
			catches = Economy.zeroByElement(),
			releases = Economy.zeroByElement(),
		},
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

local MAX_DEPTH = 32 -- far deeper than any real save; stops a table that contains itself

local function deepCopy(value: any, depth: number?): any
	if typeof(value) ~= "table" then
		return value
	end
	local level = (depth or 0) + 1
	assert(level <= MAX_DEPTH, "save is nested too deeply to copy")
	local copy = {}
	for key, child in value do
		copy[key] = deepCopy(child, level)
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
	local copied, migrated = pcall(deepCopy, data)
	if not copied then
		return nil, `save could not be copied: {tostring(migrated)}`
	end
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
-- string keys, numbers are finite, text is valid UTF-8, and nothing is a function or other
-- unsaveable value. (It cannot measure the 4 MB size limit; stable capacity keeps saves small.)
function Profile.isStorable(value: any, path: string?, depth: number?): (boolean, string?)
	local where = path or "root"
	local level = (depth or 0) + 1
	if level > MAX_DEPTH then
		return false, `{where} is nested too deeply (does a table contain itself?)`
	end
	local kind = typeof(value)
	if kind == "nil" or kind == "boolean" then
		return true, nil
	elseif kind == "string" then
		if utf8.len(value) == nil then
			return false, `{where} is not valid UTF-8 text`
		end
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
			if utf8.len(key) == nil then
				return false, `{where} has a key that is not valid UTF-8 text`
			end
		elseif keyKind ~= "number" then
			return false, `{where} has a {keyKind} key`
		end
		local ok, problem = Profile.isStorable(child, `{where}.{tostring(key)}`, level)
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
	if not isWholeNumber(creature.generation) or creature.generation < 0 then
		table.insert(problems, `creature {id} has a bad generation`)
	end
	if
		not table.find(BreedConfig.RARITY_ORDER, creature.rarity)
		and creature.rarity ~= "Cosmic"
	then
		table.insert(problems, `creature {id} has an unknown rarity`)
	end
	if (creature.isGiant or creature.rarity == "Cosmic") and not creature.bound then
		table.insert(problems, `creature {id} is a giant or cosmic creature but is not bound`)
	end
	if
		creature.hurt ~= nil
		and (
			typeof(creature.hurt) ~= "number"
			or creature.hurt ~= creature.hurt
			or creature.hurt < 0
			or creature.hurt > 1
		)
	then
		table.insert(problems, `creature {id} has bad health`)
	end
	if creature.isGiant and creature.serial == nil then
		table.insert(problems, `creature {id} is a giant with no serial number`)
	end
	if creature.serial ~= nil and (not isWholeNumber(creature.serial) or creature.serial < 1) then
		table.insert(problems, `creature {id} has a bad serial number`)
	end
	if
		not creature.isGiant
		and (
			typeof(creature.size) ~= "number"
			or creature.size < BreedConfig.SIZE_MIN
			or creature.size > BreedConfig.SIZE_MAX
		)
	then
		table.insert(problems, `creature {id} has a size outside the allowed range`)
	end
	if
		typeof(creature.colour) ~= "table"
		or not BreedConfig.COLOURS[creature.colour.shown]
		or not BreedConfig.COLOURS[creature.colour.carried]
	then
		table.insert(problems, `creature {id} has an unknown colour`)
	end
	for _, slot: Types.Slot in BreedConfig.SLOTS do
		local part = creature.parts[slot]
		if typeof(part) ~= "table" or typeof(part.species) ~= "string" then
			table.insert(problems, `creature {id} is missing its {slot}`)
		elseif not Species[part.species] then
			table.insert(
				problems,
				`creature {id} has a {slot} from an unknown species ({part.species})`
			)
		elseif Species[part.species].bodyPlan ~= creature.bodyPlan then
			table.insert(problems, `creature {id} has a {slot} from the wrong body plan`)
		elseif
			not isWholeNumber(part.quality)
			or part.quality < BreedConfig.QUALITY_MIN
			or part.quality > BreedConfig.QUALITY_MAX
		then
			table.insert(problems, `creature {id} has a {slot} quality outside 0-10`)
		end
	end
end

-- The checks themselves. The data service logs problems as an alarm; it never deletes data
-- because of them.
local function validateUnsafe(profile: Profile): { string }
	local problems: { string } = {}

	local function checkBalance(name: string, amount: number)
		if not isWholeNumber(amount) or amount < 0 then
			table.insert(problems, `{name} is not a whole number of zero or more`)
		end
	end
	checkBalance("Coins", profile.Coins)
	checkBalance("Gems", profile.Gems)
	-- One whole count of zero or more for every element, and nothing else in the record.
	local function checkByElement(name: string, record: Types.ByElement<number>)
		if typeof(record) ~= "table" then
			table.insert(problems, `{name} is missing`)
			return
		end
		for _, element: Types.Element in TypeChart.ELEMENTS do
			checkBalance(`{name}.{element}`, record[element])
		end
		for key in record :: any do
			if typeof(key) ~= "string" or not table.find(TypeChart.ELEMENTS, key :: any) then
				table.insert(problems, `{name} has an unknown type ({tostring(key)})`)
			end
		end
	end
	if typeof(profile.Candy) ~= "table" then
		table.insert(problems, "Candy is not a candy record")
	else
		checkByElement("Candy.typed", profile.Candy.typed)
		checkBalance("Candy.prism", profile.Candy.prism)
	end
	checkByElement("Daily.catches", profile.Daily.catches)
	checkByElement("Daily.releases", profile.Daily.releases)

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
	local seenInEggs: { [string]: boolean } = {}
	for index, egg in profile.Eggs do
		local id = egg.child.id
		if profile.Creatures[id] then
			table.insert(
				problems,
				`egg {index} holds creature {id}, which is already in the stable`
			)
		end
		if seenInEggs[id] then
			table.insert(problems, `creature {id} is in two eggs`)
		end
		seenInEggs[id] = true
		checkCreature(id, egg.child, problems)
	end

	-- A serial number may appear once per kind (the species of the torso).
	local serials: { [string]: boolean } = {}
	for id, creature in profile.Creatures do
		if creature.serial ~= nil then
			-- Numbers count within a kind: each giant, and each tier of each species.
			local kind = if creature.isGiant then "Giant" else creature.rarity
			local key = `{kind}:{creature.parts.Torso.species}#{creature.serial}`
			if serials[key] then
				table.insert(problems, `creature {id} repeats serial {key}`)
			end
			serials[key] = true
		end
	end

	for index, pending in profile.Pending do
		if typeof(pending.source) ~= "string" or typeof(pending.ref) ~= "string" then
			table.insert(problems, `pending grant {index} is malformed`)
		elseif
			pending.serial ~= nil and (not isWholeNumber(pending.serial) or pending.serial < 1)
		then
			table.insert(problems, `pending grant {index} has a bad serial number`)
		elseif
			pending.source == "Gem"
			and (typeof(pending.creature) ~= "table" or pending.creature.id ~= pending.ref)
		then
			table.insert(problems, `pending grant {index} is a gem catch with no creature`)
		elseif pending.source == "Gem" and pending.creature then
			-- A creature waiting for its number is checked like any creature in the stable.
			checkCreature(pending.ref, pending.creature, problems)
		elseif pending.source == "Giant" and profile.Story.giantsCaptured[pending.ref] then
			table.insert(
				problems,
				`giant {pending.ref} is both captured and waiting to be captured`
			)
		end
	end

	local receipts = profile.Purchases.receiptIds
	if #receipts > ProfileConfig.RECEIPTS_REMEMBERED then
		table.insert(problems, "more purchase ids remembered than the limit")
	end
	for index, receipt in receipts do
		if typeof(receipt) ~= "string" then
			table.insert(problems, `purchase id {index} is not text`)
		end
	end

	for item, count in profile.Items do
		if not isWholeNumber(count) or count < 0 then
			table.insert(problems, `item {item} has a bad count`)
		end
	end

	if
		typeof(profile.Quests) ~= "table"
		or typeof(profile.Quests.active) ~= "table"
		or typeof(profile.Quests.done) ~= "table"
	then
		table.insert(problems, "unreadable: quests are missing")
	else
		for quest, progress in profile.Quests.active do
			if not isWholeNumber(progress) or progress < 0 then
				table.insert(problems, `quest {quest} has bad progress`)
			end
		end
		for quest, done in profile.Quests.done do
			if done ~= true then
				table.insert(problems, `quest {quest} has a bad done mark`)
			end
		end
	end

	local storable, why = Profile.isStorable(profile)
	if not storable then
		table.insert(problems, `cannot be saved: {why or "unknown"}`)
	end
	return problems
end

-- Lists everything wrong with a loaded profile. An empty list means it is sound.
-- A save so broken that the checks themselves fail is reported as one problem, never an error:
-- the data service treats any problem that starts with "unreadable" as a failed load.
function Profile.validate(profile: Profile): { string }
	local ok, result = pcall(validateUnsafe, profile)
	if ok then
		return result
	end
	return { `unreadable save: {tostring(result)}` }
end

return Profile
