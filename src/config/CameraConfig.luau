--!strict
-- How far the player may zoom the camera out while walking the world. A close camera is what
-- keeps the tall walls of trees and rock between the player and the rest of the map
-- (docs/plans/12_MAP_STRUCTURE.md section 4d). Both are [Default]s to tune in play; 35 to 45 is the
-- sensible range for the far limit. The battle camera is separate and unchanged.

local CameraConfig = {}

CameraConfig.MAX_ZOOM = 40 -- studs: the furthest the camera may sit behind the player
CameraConfig.MIN_ZOOM = 8 -- studs: the closest, short of first person

-- The story camera look (src/client/Story/LookAt.luau): a beat turns the camera toward a landmark.
-- All [Default]s to tune in play.
CameraConfig.LOOK_EASE_SECONDS = 1.2 -- the turn toward the landmark, and the turn back
CameraConfig.LOOK_RAISE = 7 -- studs above the player's root: clear of the head and of low hedges
CameraConfig.LOOK_BACK = 6 -- studs the camera sits behind the player, away from the landmark
CameraConfig.LOOK_AIM_HEIGHT = 70 -- studs up the landmark the camera aims, so a tall tree shows whole

return CameraConfig
