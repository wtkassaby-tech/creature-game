--!strict
-- Every tamer in the game. `locals` are the tamers met along the routes, by id; `rivals` holds the
-- rival's teams, by id (his teams change with the story, so he is not an ordinary tamer); `story`
-- holds every battle the story calls for, by battle id: the rival's battles, and the champions
-- who hold the gates of biomes where the rival does not. One data file per biome in the tamers
-- folder; add each new biome to the lists below. Data only.

local DustCanyon = require("./tamers/DustCanyon")
local Greenwood = require("./tamers/Greenwood")
local WorldTypes = require("../shared/WorldTypes")

export type Registry = {
	locals: { [string]: WorldTypes.Tamer },
	rivals: { [string]: WorldTypes.RivalDef },
	story: { [string]: WorldTypes.StoryBattle },
}

local locals: { [string]: WorldTypes.Tamer } = {}
local rivals: { [string]: WorldTypes.RivalDef } = {}
local story: { [string]: WorldTypes.StoryBattle } = {}

local biomes: { WorldTypes.BiomeTamers } = { Greenwood, DustCanyon }

for _, biome in biomes do
	for _, tamer in biome.locals do
		locals[tamer.id] = tamer
	end
	local rival = biome.rival
	if rival then
		rivals[rival.id] = rival
		-- The rival's two battles in a biome, as story battles.
		story[rival.firstBattle] = {
			id = rival.firstBattle,
			name = rival.name,
			look = rival.look,
			tier = rival.tier,
			place = rival.firstPlace,
			xpKind = "Rival",
			teams = rival.first,
			before = rival.firstBefore,
			after = rival.firstAfter,
			mayRetryAtOnce = rival.firstCannotBeLost,
		}
		story[rival.gateBattle] = {
			id = rival.gateBattle,
			name = rival.name,
			look = rival.look,
			tier = rival.tier,
			place = rival.gatePlace,
			xpKind = "Gate",
			teams = rival.gate,
			before = rival.gateBefore,
			after = rival.gateAfter,
			mayRetryAtOnce = false,
		}
	end
	local extra: { WorldTypes.StoryBattle } = biome.storyBattles or {}
	for _, battle in extra do
		story[battle.id] = battle
	end
end

local Tamers: Registry = { locals = locals, rivals = rivals, story = story }

return Tamers
