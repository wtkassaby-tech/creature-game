--!strict
-- Starting values and limits for a player's saved data.

local ProfileConfig = {}

-- Where player data is kept (approval pack 1). Playtests and the live game never share a store,
-- and the live store starts clean at the soft launch.
ProfileConfig.STORE_NAME = "PlayerData_Test"
ProfileConfig.LIVE_STORE_NAME = "PlayerData_Live"
-- When true the live store is used. Switched on for the soft launch only.
ProfileConfig.USE_LIVE_STORE = false
-- Serial numbers (giants, and later wild-caught gem creatures) come from global counters kept
-- outside any player's record, with a registry of which player holds each number.
ProfileConfig.SERIAL_STORE_NAME = "Serials_Test"
ProfileConfig.LIVE_SERIAL_STORE_NAME = "Serials_Live"

-- In Studio, saves go to ProfileStore's in-memory mock unless this is true, so a test session
-- never writes to a real store by accident.
ProfileConfig.STUDIO_USES_REAL_STORE = false

-- Bump this whenever the saved shape changes, and add a migration in src/shared/Profile.luau.
-- 3: purchases (plan 16) added Purchases.once and Purchases.perks.
-- 2: finds (approval pack 7) added Profile.Finds and Daily.finds. Approval pack 6 (move imprint)
-- also bumps the version: whichever is built second takes the next number, with its own migration.
ProfileConfig.SCHEMA_VERSION = 3

ProfileConfig.STARTING_COINS = 0
ProfileConfig.STARTING_PENS = 1 -- eggs that can incubate at once
ProfileConfig.MAX_PENS = 4 -- hard cap, including pens bought with Gems
ProfileConfig.STARTING_STABLE_CAPACITY = 30 -- creatures a new player can own

-- Team size by the number of badges held (brief section 3): three for the launch biomes,
-- four from the Mire, five from Emberfall, six for the Hollow.
ProfileConfig.TEAM_SIZE_BY_BADGES = { 3, 3, 3, 4, 4, 4, 5, 5, 5, 5, 6 } -- index = badges + 1
ProfileConfig.MAX_TEAM_SIZE = 6

-- How many processed purchase ids to remember, so a receipt Roblox sends twice is granted once.
ProfileConfig.RECEIPTS_REMEMBERED = 100

ProfileConfig.DEFAULT_BATTLE_SPEED = 1

return ProfileConfig
