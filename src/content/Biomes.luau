--!strict
-- Every biome in the game, by id. One data file per biome in the biomes folder; add each new biome
-- to the list below. Data only: no logic lives here.

local Greenwood = require("./biomes/Greenwood")
local WorldTypes = require("../shared/WorldTypes")

local Biomes: { [string]: WorldTypes.Biome } = {}

for _, biome in { Greenwood } do
	Biomes[biome.id] = biome
end

return Biomes
