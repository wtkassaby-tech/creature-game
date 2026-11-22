--!strict
-- The whole story as one line of beats: every chapter's beats, in chapter order. A chapter's
-- first beat names the last beat of the chapter before it in its trigger, so the line reads
-- straight through. Add each new chapter to the list below. Data only.

local Chapter1 = require("./story/Chapter1")
local Chapter2 = require("./story/Chapter2")
local Chapter3 = require("./story/Chapter3")
local Chapter4 = require("./story/Chapter4")
local ReleaseConfig = require("../config/ReleaseConfig")
local WorldTypes = require("../shared/WorldTypes")

-- In order: a chapter's number is its biome's number. The line stops at the last open biome
-- (src/config/ReleaseConfig.luau), so a player who finishes it has finished the story for now.
local chapters: { WorldTypes.Chapter } = { Chapter1, Chapter2, Chapter3, Chapter4 }

local beats: { WorldTypes.Beat } = {}
for number, chapter in chapters do
	assert(chapter.number == number, `{chapter.id} is listed out of order`)
	if number > ReleaseConfig.OPEN_BIOMES then
		break
	end
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
