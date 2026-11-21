--!strict
-- The whole story as one line of beats: every chapter's beats, in chapter order. A chapter's
-- first beat names the last beat of the chapter before it in its trigger, so the line reads
-- straight through. Add each new chapter to the list below. Data only.

local Chapter1 = require("./story/Chapter1")
local WorldTypes = require("../shared/WorldTypes")

local chapters: { WorldTypes.Chapter } = { Chapter1 }

local beats: { WorldTypes.Beat } = {}
for _, chapter in chapters do
	for _, beat in chapter.beats do
		table.insert(beats, beat)
	end
end

local Storyline: WorldTypes.Chapter = {
	id = "storyline",
	number = 0,
	name = "The whole story",
	beats = beats,
}

return Storyline
