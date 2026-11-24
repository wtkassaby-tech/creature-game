--!strict
-- Where a story battle stands in the story, for one player: pure rules, no Roblox services.
-- The server uses them to give a clear reason when a story battle is refused; the device uses
-- them to show or hide the story's opponents in the world, so the rival is only ever standing
-- where the story needs him and never at a place he has left (the server still decides every
-- battle: a hidden person is a courtesy, never the proof).

local World = require("./World")
local WorldTypes = require("./WorldTypes")

local StoryStand = {}

-- "Now": the story's next step is this battle. "Soon": the next step is walking up to the place
-- where the battle is (the opponent speaks there before the fight). "Later": the story has not
-- got here yet. "Past": its beat is done. "None": the story has no beat for it.
export type Status = "Now" | "Soon" | "Later" | "Past" | "None"

-- The rival is called "Rival" in the data until his real name is chosen; his champions and the
-- gate's wardens have names of their own.
function StoryStand.isRival(battle: { name: string }): boolean
	return battle.name == "Rival"
end

local function winBeatOf(chapter: WorldTypes.Chapter, battleId: string): (WorldTypes.Beat?, number)
	for index, beat in chapter.beats do
		if beat.trigger.kind == "Win" and beat.trigger.target == battleId then
			return beat, index
		end
	end
	return nil, 0
end

function StoryStand.status(
	chapter: WorldTypes.Chapter,
	flags: { [string]: boolean },
	battle: WorldTypes.StoryBattle
): Status
	local beat, index = winBeatOf(chapter, battle.id)
	if not beat then
		return "None"
	end
	if flags[beat.id] then
		return "Past"
	end
	local nextBeat = World.nextBeat(chapter, flags)
	if nextBeat == beat then
		return "Now"
	end
	-- The beat just before it, if it is the walk up to the battle's own place.
	local before = chapter.beats[index - 1]
	if
		nextBeat ~= nil
		and nextBeat == before
		and (nextBeat.trigger.kind == "Enter" or nextBeat.trigger.kind == "Sight")
		and nextBeat.trigger.target == battle.place
	then
		return "Soon"
	end
	return "Later"
end

-- Is the opponent standing in the world for this player? The rival (a traveller) only while he
-- is the next thing in the story. A champion or warden holds their post, so they stand there
-- throughout, whoever is speaking in the story at that place.
function StoryStand.visible(status: string, battle: { name: string }): boolean
	if status == "None" then
		return false
	end
	if StoryStand.isRival(battle) then
		return status == "Now" or status == "Soon"
	end
	return true
end

-- Why a story battle cannot be fought right now, in words for the player. `beaten` is true when
-- the server has the win on record, even if its beat has not finished yet.
function StoryStand.refusal(status: string, battle: { name: string }, beaten: boolean): string
	local name = battle.name
	if beaten or status == "Past" then
		return if StoryStand.isRival(battle)
			then "You have already beaten the rival here. He has gone on ahead."
			else `You have already beaten {name}.`
	elseif status == "Now" or status == "Soon" then
		return `{if StoryStand.isRival(battle) then "Your rival" else name} is not ready for you yet. Finish the step on your to-do list first.`
	end
	return if StoryStand.isRival(battle)
		then "Your rival is not here yet. Follow the to-do list and you will meet him."
		else `{name} will face you when your journey brings you here. Follow the to-do list.`
end

return StoryStand
