--!strict
-- The climate zones: patches of the world with a light, sky and sound preset
-- (docs/plans/13_WORLD_DESIGN.md sections 5 and 9b). Each biome with a `region` is one zone with
-- its own id as the preset id, blending over BIOME_BAND studs each side of the border, so a
-- threshold is a blend 2 x BIOME_BAND wide centred on the passage's swap point. Zones that are not
-- a biome (side areas, tunnels, caves) are added in EXTRA. Data only.

local Biomes = require("../Biomes")
local WorldTypes = require("../../shared/WorldTypes")

local BIOME_BAND = 150 -- studs (the plan's 150 to 400)

local zones: { WorldTypes.ClimateZone } = {}

local ordered: { WorldTypes.Biome } = {}
for _, biome in Biomes do
	table.insert(ordered, biome)
end
table.sort(ordered, function(a, b)
	return a.number < b.number
end)
for _, biome in ordered do
	if biome.region then
		table.insert(
			zones,
			{ id = biome.id, preset = biome.id, shape = biome.region, band = BIOME_BAND }
		)
	end
end

-- Side areas, tunnels and caves go here, with a higher `priority` than the biome they sit in.
local EXTRA: { WorldTypes.ClimateZone } = {}
for _, zone in EXTRA do
	table.insert(zones, zone)
end

return zones
