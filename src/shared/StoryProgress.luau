--!strict
-- Finishing a story beat, as pure functions. The server calls `complete` once it has confirmed
-- the beat's trigger itself (src/shared/StoryTriggers); the device only says which starter it
-- picked. A beat finishes once: its flag is set in the same step that pays its gifts
-- (src/shared/Gifts), with no pause, so nothing can be paid twice.

local Gifts = require("./Gifts")
local Profile = require("./Profile")
local World = require("./World")
local WorldTypes = require("./WorldTypes")

export type CompleteInput = {
	beatId: unknown, -- from the device or the world service; checked against the chapter
	choice: unknown, -- the starter picked, for a Starter gift
	triggerMet: boolean, -- the server's own check of the beat's trigger
	newId: () -> string, -- fresh unique creature ids, from the server
	seed: number,
	unixTime: number,
}

export type Gift = Gifts.Gift
export type Completed = { beat: WorldTypes.Beat, gifts: { Gift }, unlocks: { string } }

local StoryProgress = {}

-- Kept here for the callers that came before src/shared/Gifts.
StoryProgress.giftColour = Gifts.giftColour
StoryProgress.rebuild = Gifts.rebuild
StoryProgress.claimEggs = Gifts.claimEggs

-- Finishes the next beat of the chapter and pays its gifts. Returns nil and a reason, changing
-- nothing, if the beat is not next, its trigger was not met, a starter choice is bad, or a gift
-- cannot be made.
function StoryProgress.complete(
	profile: Profile.Profile,
	chapter: WorldTypes.Chapter,
	input: CompleteInput
): (Completed?, string?)
	local beat = World.nextBeat(chapter, profile.Story.flags)
	if beat == nil or beat.id ~= input.beatId then
		return nil, "That part of the story is not next"
	end
	if not input.triggerMet then
		return nil, "Not yet"
	end
	local prepared, problem = Gifts.prepare(beat.id, beat.grants, {
		choice = input.choice,
		newId = input.newId,
		seed = input.seed,
		unixTime = input.unixTime,
	})
	if not prepared then
		return nil, problem
	end
	profile.Story.flags[beat.id] = true
	local gifts = Gifts.pay(profile, prepared, "Token")
	return { beat = beat, gifts = gifts, unlocks = beat.unlocks }, nil
end

return StoryProgress
