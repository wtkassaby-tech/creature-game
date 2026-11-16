--!strict
-- Starting values and limits for a player's saved data.

local ProfileConfig = {}

-- Bump this whenever the saved shape changes, and add a migration in src/shared/Profile.luau.
ProfileConfig.SCHEMA_VERSION = 1

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
