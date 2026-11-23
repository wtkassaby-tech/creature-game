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
local EXTRA: { WorldTypes.ClimateZone } = {
	-- Starfall Crater (side area a), seen across Dust Canyon's broken rope bridge and never
	-- reached: its centre is dressed at (84, -684) from Kilnrest, which is world (1068.4, -764). The
	-- bridge end (1104.6, -625.4) is 70 studs past its edge, where the light has shifted about a
	-- third of the way to the crater's violet decay. The zone reaches no walkable ground but the
	-- bridge end and the arroyo's last nook.
	{
		id = "starfall_crater",
		preset = "starfall",
		shape = { kind = "Disc", at = { x = 1068.4, z = -764 }, r = 70 },
		band = 110,
		priority = 1,
	},
}
for _, zone in EXTRA do
	table.insert(zones, zone)
end

return zones
