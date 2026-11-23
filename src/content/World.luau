--!strict
-- The world as one journey: its passages and climate zones (docs/plans/13_WORLD_DESIGN.md section
-- 11c). One data file each in the world_data folder (a different name from this registry, because
-- Windows ignores case). Landmarks, side areas, far scenery and shortcuts join them in later steps.

local Passages = require("./world_data/Passages")
local WorldTypes = require("../shared/WorldTypes")
local Zones = require("./world_data/Zones")

local World: {
	passages: { WorldTypes.Passage },
	zones: { WorldTypes.ClimateZone },
} = {
	passages = Passages,
	zones = Zones,
}

return World
