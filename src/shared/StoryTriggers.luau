--!strict
-- Decides whether the next story beat's trigger has really happened, from things only the
-- server knows: where the player's character is, a battle it just ran, a catch it just judged.
-- The device can ask for a beat, but its word is never the proof.

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
	| { kind: "Tame" } -- the server judged a catch

local StoryTriggers = {}

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
		end
	elseif event.kind == "Win" then
		met = trigger.kind == "Win" and trigger.target == event.battle
	elseif event.kind == "Tame" then
		met = trigger.kind == "Tame"
	end
	return if met then beat else nil
end

return StoryTriggers
