--!strict
-- Every number for finds in side areas and dead ends (approval pack 7, docs/plans/14_FINDS_AND_
-- REWARDS.md; approved by Ayrton on 23 November 2026). All [Default]s, tuned from playtests and
-- logged in docs/DECISIONS.md when changed. What each find gives is data in src/content/finds_data;
-- the economy's own numbers (Prism for a journal set) are in EconomyConfig.CANDY.JournalSet.

local FindsConfig = {}

-- Where the player must be, by the server's own reading of the character (never the device's).
FindsConfig.SEARCH_RADIUS = 10 -- studs, plus WorldConfig.POSITION_SLACK
-- The root part stands this far above the ground it walks on (the hips), so the height check
-- compares the feet's ground, not the root.
FindsConfig.ROOT_HEIGHT = 3
FindsConfig.HEIGHT_TOLERANCE = 6 -- studs: nobody searches a dead end from the ledge above it
FindsConfig.LINGER_SECONDS = 1 -- inside the radius this long before a search counts (the device holds 1.5)
FindsConfig.TRAIL_SECONDS = 5 -- how far back the speed check looks
FindsConfig.WALK_SPEED = 16 -- Roblox's default walking speed
FindsConfig.JUMP_SPEED_FACTOR = 3 -- no step faster than this times the walking speed in the trail
FindsConfig.TRAIL_SAMPLE_SECONDS = 0.5 -- how often the server reads each character
FindsConfig.TRAIL_MAX_SAMPLES = 24
FindsConfig.MIN_SECONDS_BETWEEN_SEARCHES = 1 -- per player, checked before anything else is read

-- Gathering: a renewable spot gives its biome's material once a day.
FindsConfig.GATHER_PER_SPOT_PER_DAY = 1
FindsConfig.GATHER_OPENS_BADGES = 1 -- gathering opens with the first badge (Ayrton, 23 November 2026)
-- A safety ceiling across every spot, so adding spots in data can never quietly flood materials.
FindsConfig.GATHER_DAILY_CAP = 30
-- Key in Daily.finds that holds the materials gathered today. It has a "~", which no find id may.
FindsConfig.GATHERED_KEY = "~gathered"

-- Sightings: the first stir of each day at a marked rustle spot brings out an Uncommon.
FindsConfig.SIGHTINGS_PER_SPOT_PER_DAY = 1
-- Gem-tier wild creatures exist from Dust Canyon on; a sighting takes the normal chance
-- (EconomyConfig.GEM_WILD_SHARE) there, and none in Greenwood, which has no gem rows.
FindsConfig.SIGHTING_GEM_MIN_BIOME = 2

-- The most of one item a player may carry (Shop.MAX_HELD); a claim that would pass it is refused
-- whole. tests/finds.test.luau checks the two agree.
FindsConfig.MAX_HELD = 999

-- Refusals far from a find are logged; a burst of them raises an alarm for review.
FindsConfig.FAR_ALARM_COUNT = 10
FindsConfig.FAR_ALARM_SECONDS = 300

-- Looks only (the device): how near a find's glint shows, and how long the prompt is held.
FindsConfig.GLINT_DISTANCE = 30
FindsConfig.HOLD_SECONDS = 1.5
FindsConfig.PROMPT_DISTANCE = 8 -- the device's prompt, inside SEARCH_RADIUS so an honest hold always passes

return FindsConfig
