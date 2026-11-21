--!strict
-- Every giant in the game, by id. One data file per giant in the giants folder; add each new giant
-- (a biome's giant, a weekly boss) to the list below. No code changes are needed to add one: the
-- fight rules in src/shared/GiantBattle read everything from the data. Data only: no logic here.

local GiantBattle = require("../shared/GiantBattle")
local DustCanyon = require("./giants/DustCanyon")
local Greenwood = require("./giants/Greenwood")

local Giants: { [string]: GiantBattle.GiantDef } = {}

for _, giant in { Greenwood, DustCanyon } do
	Giants[giant.id] = giant
end

return Giants
