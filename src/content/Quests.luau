--!strict
-- Every quest in the game, by id. One data file per biome in the quests folder, each an ordered
-- list; add each new biome to the list below. Data only: no logic lives here.

local DustCanyon = require("./quests/DustCanyon")
local Greenwood = require("./quests/Greenwood")
local WorldTypes = require("../shared/WorldTypes")

local Quests: { [string]: WorldTypes.Quest } = {}

for _, list in { Greenwood, DustCanyon } do
	for _, quest in list do
		Quests[quest.id] = quest
	end
end

return Quests
