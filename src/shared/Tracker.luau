--!strict
-- The small pure rules behind three screens: what the tracker says, what the "Day one" card
-- says, whether the Creatures button should pulse, how many Greenwood friends are owned, and
-- whether a starter pick may be sent. No Roblox services: the screens only show the answers.

local Tracker = {}

-- The eight creatures of the first biome, in the order the Creatures screen shows them.
-- (Greenwood.luau does not expose a species list, only spawn rows, so it is written out here.)
local GREENWOOD: { string } = {
	"Mossmitt",
	"Gorsling",
	"Sloshcalf",
	"Splashjack",
	"Spadesnout",
	"Stumpwarden",
	"Stiltbark",
	"Burlhorn",
}
Tracker.GREENWOOD = GREENWOOD

local MAX_LINES = 4
local TEAM_SIZE = 6

export type QuestLine = { goal: string, progress: number, needed: number, giver: string }

export type Input = {
	hint: string?, -- the next story step, already worded
	quests: { QuestLine },
	eggs: { number }, -- hatch times, in seconds on the same clock as `now`
	now: number,
	friends: number, -- Greenwood species owned
}

-- "2:10"
function Tracker.clock(seconds: number): string
	local left = math.max(0, math.floor(seconds))
	return string.format("%d:%02d", left // 60, left % 60)
end

-- "none", "hatched" (any egg past its time) or "waiting", with the seconds left on the soonest.
function Tracker.eggState(eggs: { number }, now: number): (string, number)
	local soonest = math.huge
	for _, hatchAt in eggs do
		if hatchAt <= now then
			return "hatched", 0
		end
		soonest = math.min(soonest, hatchAt - now)
	end
	return if #eggs == 0 then "none" else "waiting", soonest
end

-- The egg line: a hatched egg is the most urgent, otherwise the soonest one counts down.
function Tracker.eggLine(eggs: { number }, now: number): string?
	local state, left = Tracker.eggState(eggs, now)
	if state == "hatched" then
		return "Your egg hatched! Open Creatures."
	elseif state == "waiting" then
		return `Egg hatches in {Tracker.clock(left)}`
	end
	return nil
end

-- At most four short lines, most urgent first: the story, the egg, each quest, the friends.
function Tracker.lines(input: Input): { string }
	local out: { string } = {}
	if input.hint and input.hint ~= "" then
		table.insert(out, input.hint)
	end
	local egg = Tracker.eggLine(input.eggs, input.now)
	if egg then
		table.insert(out, egg)
	end
	-- Quests arrive from a dictionary, so sort them or the lines would shuffle on every update.
	local quests = table.clone(input.quests)
	table.sort(quests, function(a: QuestLine, b: QuestLine): boolean
		return a.goal < b.goal
	end)
	for _, quest in quests do
		table.insert(
			out,
			if quest.progress >= quest.needed
				then `Quest done: go back to {quest.giver}`
				else `Quest: {quest.goal} ({quest.progress}/{quest.needed})`
		)
	end
	table.insert(out, `Greenwood friends {input.friends} of {#GREENWOOD}`)
	while #out > MAX_LINES do
		table.remove(out)
	end
	return out
end

-- The "Day one" card: what has happened so far, read from the player's own state.
function Tracker.dayOneLines(
	friends: number,
	eggs: { number },
	now: number,
	questGoal: string?
): { string }
	local out: { string } = {}
	table.insert(out, `Friends so far: {friends}`)
	local state, left = Tracker.eggState(eggs, now)
	if state == "hatched" then
		table.insert(out, "Your egg has hatched.")
	elseif state == "waiting" then
		table.insert(out, `Your egg hatches in {Tracker.clock(left)}.`)
	end
	if questGoal then
		table.insert(out, `A new job: {questGoal}`)
	end
	table.insert(out, "Something stirs in the old tree.") -- at most four lines, by construction
	return out
end

-- How many of the Greenwood species appear in `owned` (a list of species names, repeats allowed).
function Tracker.countFriends(owned: { string }): number
	local have: { [string]: boolean } = {}
	for _, species in owned do
		have[species] = true
	end
	local count = 0
	for _, species in GREENWOOD do
		if have[species] then
			count += 1
		end
	end
	return count
end

-- Something is waiting in Creatures: an egg past its hatch time, or a creature that is not on
-- the team while the team has room. Returns a key too, so the button can pulse again only when
-- something new is waiting, not forever after the player has looked.
function Tracker.waiting(
	eggs: { number },
	now: number,
	owned: number,
	teamCount: number
): (boolean, string)
	local hatched = 0
	for _, hatchAt in eggs do
		if hatchAt <= now then
			hatched += 1
		end
	end
	local spare = if teamCount < TEAM_SIZE then math.max(0, owned - teamCount) else 0
	return hatched > 0 or spare > 0, `{hatched}/{spare}`
end

-- May the starter pick be sent? Only for a creature that is one of the offered choices.
function Tracker.pickAllowed(selected: string?, choices: { string }): boolean
	return selected ~= nil and table.find(choices, selected) ~= nil
end

return Tracker
