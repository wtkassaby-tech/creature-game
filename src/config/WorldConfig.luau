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

-- The generated test map (until the real map is built): routes are straight runs of this length
-- that bend left and right by this angle, so distance along the path is exact.
WorldConfig.SEGMENT_LENGTH = 50
WorldConfig.BEND_DEGREES = 18
WorldConfig.SPAWN_SIDE_OFFSET = 18 -- wild creatures stand up to this far to either side of the path
WorldConfig.TAMER_SIDE_OFFSET = 9
WorldConfig.RUSTLE_SIDE_OFFSET = 24
WorldConfig.ROUTE_ENTRY_DEPTH = 30 -- how far along a route its "entered" marker sits

return WorldConfig
