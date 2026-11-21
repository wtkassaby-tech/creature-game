--!strict
-- Quests, as pure rules: take one from its giver, count what the server saw, hand it in.
--
-- Only things the server itself judged are counted (a wild win on a route, a catch, a tamer or
-- a giant beaten), and only after the quest was taken. A quest is handed in once: its "done"
-- mark is set in the same step that pays its rewards (src/shared/Gifts), with no pause.

local Gifts = require("./Gifts")
local Profile = require("./Profile")
local Quests = require("../content/Quests")
local World = require("./World")
local WorldTypes = require("./WorldTypes")

-- Something the server saw that a quest may be counting.
export type Event =
	{ kind: "WinWild", route: string }
	| { kind: "Tame", species: string }
	| { kind: "BeatTamer", tamer: string }
	| { kind: "BeatGiant", giant: string }

export type HandedIn = { quest: WorldTypes.Quest, gifts: { Gifts.Gift } }

local QuestProgress = {}

-- Giant fights are not on the server yet, so a quest to beat one could be taken but never
-- finished. Set to true when the giant service records BeatGiant.
QuestProgress.GIANTS_OPEN = false

local function list(): { WorldTypes.Quest }
	local all: { WorldTypes.Quest } = {}
	for _, quest in Quests do
		table.insert(all, quest)
	end
	return all
end

-- How many counted events a quest needs.
function QuestProgress.needed(quest: WorldTypes.Quest): number
	local objective = quest.objective
	return if objective.kind == "WinWild" then objective.count else 1
end

-- True once a taken quest has everything it counts.
function QuestProgress.isReady(profile: Profile.Profile, quest: WorldTypes.Quest): boolean
	local progress = profile.Quests.active[quest.id]
	return progress ~= nil and progress >= QuestProgress.needed(quest)
end

local function find(questId: unknown): WorldTypes.Quest?
	if typeof(questId) ~= "string" then
		return nil
	end
	return Quests[questId]
end

-- Takes a quest. `questId` comes from the device; `atGiver` is the server's own check that the
-- player is standing at the quest giver's place.
function QuestProgress.accept(
	profile: Profile.Profile,
	questId: unknown,
	atGiver: boolean
): (WorldTypes.Quest?, string?)
	local quest = find(questId)
	if not quest then
		return nil, "There is no such quest"
	end
	if profile.Quests.done[quest.id] then
		return nil, "You have already done that quest"
	end
	if profile.Quests.active[quest.id] ~= nil then
		return nil, "You have already taken that quest"
	end
	if
		not table.find(
			World.availableQuests(list(), profile.Quests.done, profile.Story.flags),
			quest
		)
	then
		return nil, "That quest is not open to you yet"
	end
	if not atGiver then
		return nil, "You are too far away"
	end
	if quest.objective.kind == "BeatGiant" and not QuestProgress.GIANTS_OPEN then
		return nil, "That quest is not open to you yet"
	end
	profile.Quests.active[quest.id] = 0
	return quest, nil
end

-- Counts something the server saw toward every taken quest that is waiting for it. Returns the
-- quests whose progress changed.
function QuestProgress.record(profile: Profile.Profile, event: Event): { WorldTypes.Quest }
	local moved: { WorldTypes.Quest } = {}
	for id, progress in profile.Quests.active do
		local quest = Quests[id]
		if quest and typeof(progress) == "number" and progress < QuestProgress.needed(quest) then
			local objective = quest.objective
			local counts = false
			if objective.kind == "WinWild" and event.kind == "WinWild" then
				counts = objective.route == event.route
			elseif objective.kind == "TameSpecies" and event.kind == "Tame" then
				counts = objective.species == event.species
			elseif objective.kind == "BeatTamer" and event.kind == "BeatTamer" then
				counts = objective.tamer == event.tamer
			elseif objective.kind == "BeatGiant" and event.kind == "BeatGiant" then
				counts = objective.giant == event.giant
			end
			if counts then
				profile.Quests.active[id] = progress + 1
				table.insert(moved, quest)
			end
		end
	end
	return moved
end

-- Hands in a finished quest and pays its rewards, whole or not at all.
function QuestProgress.handIn(
	profile: Profile.Profile,
	questId: unknown,
	atGiver: boolean,
	input: Gifts.Input
): (HandedIn?, string?)
	local quest = find(questId)
	if not quest or profile.Quests.active[quest.id] == nil then
		return nil, "You have not taken that quest"
	end
	if not QuestProgress.isReady(profile, quest) then
		return nil, "That quest is not finished yet"
	end
	if not atGiver then
		return nil, "You are too far away"
	end
	local prepared, problem = Gifts.prepare(quest.id, quest.rewards, input)
	if not prepared then
		return nil, problem
	end
	profile.Quests.active[quest.id] = nil
	profile.Quests.done[quest.id] = true
	return { quest = quest, gifts = Gifts.pay(profile, prepared, "Quest") }, nil
end

return QuestProgress
