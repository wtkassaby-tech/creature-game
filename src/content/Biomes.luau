--!strict
-- Every biome in the game, by id. One data file per biome in the biomes folder; add each new biome
-- to the list below. Data only: no logic lives here.

local DustCanyon = require("./biome_data/DustCanyon")
local Greenwood = require("./biome_data/Greenwood")
local Mire = require("./biome_data/Mire")
local TideFlats = require("./biome_data/TideFlats")
local ReleaseConfig = require("../config/ReleaseConfig")
local WorldTypes = require("../shared/WorldTypes")

local Biomes: { [string]: WorldTypes.Biome } = {}

-- In biome order: the position in this list is the biome's number. Only open biomes are listed
-- (src/config/ReleaseConfig.luau).
local ordered: { WorldTypes.Biome } = { Greenwood, DustCanyon, TideFlats, Mire }
for number, biome in ordered do
	assert(biome.number == number, `{biome.id} is listed out of order`)
	if number <= ReleaseConfig.OPEN_BIOMES then
		Biomes[biome.id] = biome
	end
end

return Biomes
