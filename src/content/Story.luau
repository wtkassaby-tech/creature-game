--!strict
-- Every story chapter, by id. One data file per chapter in the story folder; add each new chapter
-- to the list below. Data only: no logic lives here.

local Chapter1 = require("./story/Chapter1")
local Chapter2 = require("./story/Chapter2")
local WorldTypes = require("../shared/WorldTypes")

local Story: { [string]: WorldTypes.Chapter } = {}

for _, chapter in { Chapter1, Chapter2 } do
	Story[chapter.id] = chapter
end

return Story
