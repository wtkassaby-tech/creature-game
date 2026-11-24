--!strict
-- Numbers for the walkable world: how wild creatures appear on the routes, how close a player
-- must be to start something, and the shape of the generated test map. All [Default]s.

local WorldConfig = {}

-- Wild creatures are per player: each player sees and fights their own, so nobody can take
-- another player's find and nothing is contested.
WorldConfig.SPAWNS_PER_AREA = 3 -- roaming creatures kept in each stretch of a route near the player
WorldConfig.RESPAWN_SECONDS = 20 -- after one is beaten, caught or flees, before the next appears
WorldConfig.ACTIVE_RANGE = 260 -- studs: only stretches this close to the player are kept filled
WorldConfig.MAX_SPAWNS = 24 -- hard cap on one player's creatures in the world

-- How close the player's character must be, by the server's own reading of its position.
WorldConfig.ENGAGE_RADIUS = 16 -- to start a battle with a wild creature or a tamer
WorldConfig.RUSTLE_RADIUS = 14 -- to stir a rustle spot
WorldConfig.TALK_RADIUS = 16 -- to talk to a character
WorldConfig.PLACE_RADIUS = 40 -- to count as having entered or seen a place
WorldConfig.POSITION_SLACK = 8 -- added to every radius: the character keeps moving while a message travels

WorldConfig.RUSTLE_COOLDOWN_SECONDS = 90 -- per spot, per player

-- Long grass: every stretch of a route has a patch. Walking through it can start a battle with
-- a creature the player did not see coming, drawn from that stretch's own table. The creatures
-- standing in the open are for picking a fight; the grass is for the surprise.
-- Hedges, cliffs and other edges leave this much room round every tamer, person and prompt, so
-- nobody stands inside one (tests/layout.test.luau reads the same number).
WorldConfig.EDGE_CLEAR_STUDS = 7

-- A wall piece (a hedge, a cliff, a boulder bank) is lifted whole onto one tier, so it must not
-- cover ground at two heights or a stair or ramp: no edge point stands where the ground within
-- this many studs of it changes height by more than WALL_HEIGHT_TOLERANCE (tests/walltiers.test.luau).
WorldConfig.WALL_FOOTPRINT_STUDS = 4
WorldConfig.WALL_HEIGHT_TOLERANCE = 0.3

-- Raising a built part onto its tier (src/shared/TierFit.luau, src/server/World/Elevate.luau).
-- A part longer than TIER_FIT_LONG whose two ends stand more than TIER_FIT_SPAN apart in height
-- lies across a tier's edge. Heights within TIER_FIT_TOLERANCE count as one height. All [Default]s.
WorldConfig.TIER_FIT_LONG = 10 -- studs
WorldConfig.TIER_FIT_SPAN = 1
WorldConfig.TIER_FIT_TOLERANCE = 0.3
WorldConfig.TIER_FIT_STEP = 2 -- studs between the ground heights read over a part's footprint
WorldConfig.TIER_FIT_CUT_STEP = 0.5 -- studs between the heights read along a strip when it is cut
WorldConfig.TIER_FIT_MAX_PIECES = 8 -- a strip is cut into at most this many; over a slope it is not cut
WorldConfig.TIER_FIT_MIN_RADIUS = 1 -- studs: the smallest a disc is trimmed to
WorldConfig.TIER_FIT_MAX_SHIFT = 24 -- studs: the furthest a filler piece is slid to stand on one height

WorldConfig.GRASS_RADIUS = 20 -- studs: the size of a patch
WorldConfig.GRASS_SIDE_OFFSET = 40 -- how far to one side of the path a patch lies
WorldConfig.GRASS_CHANCE = 0.22 -- each second the player is moving inside a patch
WorldConfig.GRASS_REST_SECONDS = 8 -- after a grass battle starts, before the next can
WorldConfig.GRASS_MIN_MOVE = 3 -- studs moved in a second to count as walking

-- Creatures hide in the long grass (nothing stands in the open): a stretch's roaming creatures
-- sit inside its patch and the player finds one by walking up to it.
WorldConfig.GRASS_SPAWN_REACH = 13 -- studs from the patch's middle a hiding place may lie (patch is 20)
WorldConfig.GRASS_SPAWN_GAP = 11 -- hiding places in one patch keep at least this far apart
WorldConfig.GRASS_SPAWN_TRIES = 24 -- tries at finding a hiding place that keeps the gap
WorldConfig.GRASS_TRIGGER_RADIUS = 6 -- studs: walking this close to a hiding creature starts the battle
WorldConfig.WILD_CALM_SECONDS = 10 -- after leaving a battle with one, it cannot be started again for this long
WorldConfig.ENGAGE_MIN_SECONDS = 0.5 -- least gap between one player's battle requests
WorldConfig.ENCOUNTER_BEAT_SECONDS = 0.45 -- the "!" beat before the request goes out (the client)
-- Looks only (the client): how often a hidden creature's grass rustles, and the tell a rarer one
-- gives, as sparkles per second (none for a Common).
WorldConfig.RUSTLE_EVERY_MIN = 2.5
WorldConfig.RUSTLE_EVERY_MAX = 5.5
WorldConfig.RUSTLE_SEE_DISTANCE = 90 -- studs: further than this the grass is left still
WorldConfig.TELL_RATE = {
	Common = 0,
	Uncommon = 2,
	Gem = 3.5,
	Ruby = 5,
	Diamond = 6.5,
	Cosmic = 8,
} :: { [string]: number }

-- The generated test map (until the real map is built): routes are straight runs of this length
-- that bend left and right by this angle, so distance along the path is exact.
WorldConfig.SEGMENT_LENGTH = 50
WorldConfig.BEND_DEGREES = 18
WorldConfig.SPAWN_SIDE_OFFSET = 18 -- wild creatures stand up to this far to either side of the path
WorldConfig.TAMER_SIDE_OFFSET = 9
WorldConfig.RUSTLE_SIDE_OFFSET = 24
WorldConfig.DOOR_DISTANCE = 16 -- a building's keeper stands this far in front of its middle
WorldConfig.STALL_DISTANCE = 40 -- the lair's supply stall stands this far up the spur
-- The next biome's hub lies this far past the end of a biome's sealed road, plus room for the
-- hub itself (half its width, taken as the largest hub).
WorldConfig.BIOME_GAP = 80
WorldConfig.NEXT_HUB_ALLOWANCE = 160
WorldConfig.ROUTE_ENTRY_DEPTH = 30 -- how far along a route its "entered" marker sits

-- Enclosure (docs/plans/12_MAP_STRUCTURE.md section 10, step 1). A character jumps 7.2 studs, so
-- every edge's blocking core and every water barrier stands this tall. All [Default]s.
WorldConfig.WALL_CORE_TALL = 10
WorldConfig.WATER_BARRIER_TALL = 10
WorldConfig.WATER_CROSSING_MARGIN = 3 -- studs: water this close to a lane, bridge or stones is left open
WorldConfig.WATER_TILE_STEP = 16 -- sea cells that block the way are cut on this grid
WorldConfig.WATER_TILE_BAND = 48 -- sea is solid this far out from the walkable space
WorldConfig.WATER_TILE_MARGIN = 2 -- studs of sea left walkable beside a lane, as the edge's own rail
-- The fill past the edges, in three layers by distance out: a row of tall trees (or spires or
-- dunes) at the edge, a row of masses behind it, then blocks on a coarse grid out to the band.
WorldConfig.FILL_PAD = 4 -- studs from the edge to the first row
WorldConfig.FILL_ROW_STEP = 14
WorldConfig.FILL_ROW_WIDTH = 14
WorldConfig.FILL_MASS_STEP = 22
WorldConfig.FILL_MASS_WIDTH = 18
WorldConfig.FILL_BLOCK_STEP = 40
-- Heights { low, high } of each layer, by style.
WorldConfig.FILL_TALL = {
	Forest = { row = { 30, 38 }, mass = { 26, 32 }, block = { 24, 32 } },
	Rock = { row = { 30, 42 }, mass = { 24, 34 }, block = { 22, 34 } },
	Dune = { row = { 16, 22 }, mass = { 18, 24 }, block = { 18, 26 } },
	Swamp = { row = { 24, 32 }, mass = { 14, 20 }, block = { 16, 24 } },
} :: { [string]: { [string]: { number } } }

return WorldConfig
