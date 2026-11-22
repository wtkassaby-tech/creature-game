--!strict
-- Every giant in the game, by id. One data file per giant in the giants folder; add each new giant
-- (a biome's giant, a weekly boss) to the list below. No code changes are needed to add one: the
-- fight rules in src/shared/GiantBattle read everything from the data. Data only: no logic here.

local GiantBattle = require("../shared/GiantBattle")
local ReleaseConfig = require("../config/ReleaseConfig")
local DustCanyon = require("./giant_data/DustCanyon")
local Greenwood = require("./giant_data/Greenwood")
local Mire = require("./giant_data/Mire")
local TideFlats = require("./giant_data/TideFlats")

local Giants: { [string]: GiantBattle.GiantDef } = {}

-- In biome order: the position in this list is the giant's biome number. Only open biomes'
-- giants are listed (src/config/ReleaseConfig.luau).
local ordered: { GiantBattle.GiantDef } = { Greenwood, DustCanyon, TideFlats, Mire }
for number, giant in ordered do
	if number <= ReleaseConfig.OPEN_BIOMES then
		Giants[giant.id] = giant
	end
end

return Giants
