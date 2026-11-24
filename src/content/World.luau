--!strict
-- The world as one journey: its passages, climate zones and far scenery (docs/plans/
-- 13_WORLD_DESIGN.md sections 3c, 10 and 11c). One data file each in the world_data folder (a
-- different name from this registry, because Windows ignores case). Landmarks, side areas and
-- shortcuts join them in later steps.

local FarScenery = require("./world_data/FarScenery")
local Passages = require("./world_data/Passages")
local WorldTypes = require("../shared/WorldTypes")
local Zones = require("./world_data/Zones")

local World: {
	passages: { WorldTypes.Passage },
	zones: { WorldTypes.ClimateZone },
	farScenery: { WorldTypes.FarScenery },
} =
	{
		passages = Passages,
		zones = Zones,
		farScenery = FarScenery,
	}

return World
