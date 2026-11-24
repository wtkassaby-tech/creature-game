--!strict
-- Every story chapter, by id. One data file per chapter in the story folder; add each new chapter
-- to the list below. Data only: no logic lives here.

local Chapter1 = require("./story_data/Chapter1")
local Chapter2 = require("./story_data/Chapter2")
local Chapter3 = require("./story_data/Chapter3")
local Chapter4 = require("./story_data/Chapter4")
local ReleaseConfig = require("../config/ReleaseConfig")
local WorldTypes = require("../shared/WorldTypes")

local Story: { [string]: WorldTypes.Chapter } = {}

-- In order: a chapter's number is its biome's number. Only chapters of open biomes are listed
-- (src/config/ReleaseConfig.luau).
local ordered: { WorldTypes.Chapter } = { Chapter1, Chapter2, Chapter3, Chapter4 }
for number, chapter in ordered do
	assert(chapter.number == number, `{chapter.id} is listed out of order`)
	if number <= ReleaseConfig.OPEN_BIOMES then
		Story[chapter.id] = chapter
	end
end

return Story
