--!strict
-- Every tamer in the game. `locals` are the tamers met along the routes, by id; `rivals` holds the
-- rival's teams, by id (his teams change with the story, so he is not an ordinary tamer). One data
-- file per biome in the tamers folder; add each new biome to the lists below. Data only.

local Greenwood = require("./tamers/Greenwood")
local WorldTypes = require("../shared/WorldTypes")

export type Registry = {
	locals: { [string]: WorldTypes.Tamer },
	rivals: { [string]: WorldTypes.RivalDef },
}

local locals: { [string]: WorldTypes.Tamer } = {}
local rivals: { [string]: WorldTypes.RivalDef } = {}

for _, tamer in Greenwood.locals do
	locals[tamer.id] = tamer
end
rivals[Greenwood.rival.id] = Greenwood.rival

local Tamers: Registry = { locals = locals, rivals = rivals }

return Tamers
