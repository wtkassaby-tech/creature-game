--!strict
-- How far the player may zoom the camera out while walking the world. A close camera is what
-- keeps the tall walls of trees and rock between the player and the rest of the map
-- (docs/plans/12_MAP_STRUCTURE.md section 4d). Both are [Default]s to tune in play; 35 to 45 is the
-- sensible range for the far limit. The battle camera is separate and unchanged.

local CameraConfig = {}

CameraConfig.MAX_ZOOM = 40 -- studs: the furthest the camera may sit behind the player
CameraConfig.MIN_ZOOM = 8 -- studs: the closest, short of first person

return CameraConfig
