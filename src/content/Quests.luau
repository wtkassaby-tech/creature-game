--!strict
-- Every quest in the game, by id. One data file per biome in the quests folder, each an ordered
-- list; add each new biome to the list below. Data only: no logic lives here.

local DustCanyon = require("./quests/DustCanyon")
local Greenwood = require("./quests/Greenwood")
local TideFlats = require("./quests/TideFlats")
local ReleaseConfig = require("../config/ReleaseConfig")
local WorldTypes = require("../shared/WorldTypes")

local Quests: { [string]: WorldTypes.Quest } = {}

-- In biome order: the position in this list is the biome number. Only open biomes' quests are
-- listed (src/config/ReleaseConfig.luau).
local ordered: { { WorldTypes.Quest } } = { Greenwood, DustCanyon, TideFlats }
for number, list in ordered do
	if number <= ReleaseConfig.OPEN_BIOMES then
		for _, quest in list do
			Quests[quest.id] = quest
		end
	end
end

return Quests
