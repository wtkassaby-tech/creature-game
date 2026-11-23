--!strict
-- Decides whether the next story beat's trigger has really happened, from things only the
-- server knows: where the player's character is, a battle it just ran, a catch it just judged.
-- The device can ask for a beat, but its word is never the proof.

local Chapter1 = require("../content/story_data/Chapter1")
local Chapter2 = require("../content/story_data/Chapter2")
local Chapter3 = require("../content/story_data/Chapter3")
local Chapter4 = require("../content/story_data/Chapter4")
local Layout = require("./Layout")
local Profile = require("./Profile")
local Rewards = require("./Rewards")
local World = require("./World")
local WorldConfig = require("../config/WorldConfig")
local WorldTypes = require("./WorldTypes")

export type Event =
	{ kind: "Ask", at: Layout.Point? } -- the device asked for the next beat; `at` is the server's reading
	| { kind: "At", at: Layout.Point } -- the server's regular look at where the player is
	| { kind: "Win", battle: string } -- the server ran this battle and the player won
	| { kind: "Tame", biome: number? } -- the server judged a catch; `biome` is where the creature lives

local StoryTriggers = {}

-- A catch the server judged while a chapter's "tame a creature" beat was still ahead is kept as
-- `tamed:<beat id>`, so the beat completes when the story reaches it (an audit found early
-- catches thrown away; Ayrton, 23 November 2026: "Yes, do both"). Story flags are free-form, so
-- no save migration.
local TAMED_PREFIX = "tamed:"

-- The chapter each beat belongs to, by beat id: a catch counts only toward the chapter the player
-- is in, never a later one.
local chapterOfBeat: { [string]: WorldTypes.Chapter } = {}
for _, chapter: WorldTypes.Chapter in { Chapter1, Chapter2, Chapter3, Chapter4 } do
	for _, beat in chapter.beats do
		chapterOfBeat[beat.id] = chapter
	end
end

-- Records a catch the server has just judged against the first "tame" beat not yet done in the
-- chapter of the player's next beat. Returns the beat id credited, or nil.
function StoryTriggers.creditTame(
	storyline: WorldTypes.Chapter,
	profile: Profile.Profile,
	biome: number
): string?
	local flags = profile.Story.flags
	local nextBeat = World.nextBeat(storyline, flags)
	local chapter = if nextBeat then chapterOfBeat[nextBeat.id] else nil
	-- Only a catch from the chapter's own biome (a chapter's number is its biome's number): at a
	-- chapter boundary a creature caught on the way back through the old biome does not count.
	if not chapter or chapter.number ~= biome then
		return nil
	end
	for _, beat in chapter.beats do
		if not flags[beat.id] and beat.trigger.kind == "Tame" then
			flags[TAMED_PREFIX .. beat.id] = true
			return beat.id
		end
	end
	return nil
end

local function near(map: Layout.Map, target: string?, at: Layout.Point?, radius: number): boolean
	return target ~= nil and at ~= nil and Layout.isNear(map, target, at, radius)
end

-- The next beat, if this event is what it was waiting for; otherwise nil.
function StoryTriggers.ready(
	chapter: WorldTypes.Chapter,
	profile: Profile.Profile,
	map: Layout.Map,
	event: Event
): WorldTypes.Beat?
	local beat = World.nextBeat(chapter, profile.Story.flags)
	if beat == nil then
		return nil
	end
	local trigger = beat.trigger
	local met = false
	if event.kind == "Ask" then
		if trigger.kind == "Start" or trigger.kind == "Follow" then
			met = true
		elseif trigger.kind == "Talk" then
			met = near(map, trigger.target, event.at, WorldConfig.TALK_RADIUS)
		elseif trigger.kind == "Enter" or trigger.kind == "Sight" then
			met = near(map, trigger.target, event.at, WorldConfig.PLACE_RADIUS)
		end
	elseif event.kind == "At" then
		if trigger.kind == "Enter" or trigger.kind == "Sight" then
			met = near(map, trigger.target, event.at, WorldConfig.PLACE_RADIUS)
		elseif trigger.kind == "Win" and trigger.target ~= nil then
			-- A tamer beaten before the story asked for it still counts: the win is on record.
			met = Rewards.hasBeaten(profile, trigger.target)
		elseif trigger.kind == "Tame" then
			-- A catch made before the story asked for one still counts (StoryTriggers.creditTame).
			met = profile.Story.flags[TAMED_PREFIX .. beat.id] == true
		end
	elseif event.kind == "Win" then
		met = trigger.kind == "Win" and trigger.target == event.battle
	elseif event.kind == "Tame" then
		met = trigger.kind == "Tame"
	end
	return if met then beat else nil
end

return StoryTriggers
