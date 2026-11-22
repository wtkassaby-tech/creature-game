--!strict
-- The battle coach: which short line to show a new player, and when. Pure decisions, no
-- Roblox services, so they are tested under Lune. The screens only show what these return.
-- The coach never promises something that is not true: it says "STRONG" only when one of the
-- player's current moves really is strong against the creature in front of them.

local Moves = require("../content/Moves")
local TypeChart = require("./TypeChart")
local Types = require("./Types")

local Coach = {}

-- The story flags that bracket each lesson (beat ids from the first chapter).
Coach.FIRST_BATTLE_DONE_FLAG = "rival_parting"
Coach.LASSO_LESSON_FLAG = "lasso_lesson"
Coach.FIRST_CATCH_FLAG = "third_creature"

-- A wild creature at or below this share of its health is "tired": the lasso's green is wide.
-- A teaching threshold only; the server's own lasso rules decide the real width.
Coach.TIRED_SHARE = 0.4

local LINES: { [string]: string } = {
	pickMove = "Pick FIGHT, then a move.",
	pickStrong = "Pick FIGHT, then a move. The bright ones say STRONG.",
	strongHit = "STRONG! That is how you win fights.",
	weakenFirst = "Win it over first. When its health is low, choose LASSO.",
	tired = "It is tired now. Time to throw!",
	wideGreen = "Tired creatures leave a wide green.",
	missedCommon = "It slipped the rope. It will not run off. Try again!",
	joined = "Joined your team!",
	stable = "Waiting in Creatures. Open it to add your new friend to the team.",
	friend = "A new friend!",
}
Coach.LINES = LINES

local function hasFlag(flags: { string }, id: string): boolean
	return table.find(flags, id) ~= nil
end
Coach.hasFlag = hasFlag

-- The first-battle coach shows in the rival's first bout only, and stops for good once the story
-- has moved past it.
function Coach.firstBattleActive(flags: { string }, kind: string): boolean
	return kind == "Rival" and not hasFlag(flags, Coach.FIRST_BATTLE_DONE_FLAG)
end

-- True when at least one of the moves is strong against the foe's type.
function Coach.hasStrongMove(moveNames: { string }, foe: Types.Element): boolean
	for _, name in moveNames do
		local def = Moves[name]
		if def and TypeChart.isStrong(def.element, foe) then
			return true
		end
	end
	return false
end

-- The line for the start of a turn's menu in the first battle, or nil when the coach is quiet.
function Coach.firstBattleLine(
	flags: { string },
	kind: string,
	moveNames: { string },
	foe: Types.Element
): string?
	if not Coach.firstBattleActive(flags, kind) then
		return nil
	end
	return if Coach.hasStrongMove(moveNames, foe)
		then Coach.LINES.pickStrong
		else Coach.LINES.pickMove
end

-- The line after the player lands a strong hit in the first battle, or nil.
function Coach.strongHitLine(flags: { string }, kind: string): string?
	if Coach.firstBattleActive(flags, kind) then
		return Coach.LINES.strongHit
	end
	return nil
end

-- The lasso lesson runs in wild battles after the lasso lesson is told and before the first
-- catch of the story is made.
function Coach.lassoCoachActive(flags: { string }, wild: boolean): boolean
	return wild
		and hasFlag(flags, Coach.LASSO_LESSON_FLAG)
		and not hasFlag(flags, Coach.FIRST_CATCH_FLAG)
end

-- Is the foe tired enough to throw at?
function Coach.isTired(hp: number, maxHp: number): boolean
	return hp / math.max(1, maxHp) <= Coach.TIRED_SHARE
end

-- The line while the lasso lesson runs: wear it down first, then throw. Nil when quiet.
function Coach.lassoLine(flags: { string }, wild: boolean, hp: number, maxHp: number): string?
	if not Coach.lassoCoachActive(flags, wild) then
		return nil
	end
	return if Coach.isTired(hp, maxHp) then Coach.LINES.tired else Coach.LINES.weakenFirst
end

-- Time to make the LASSO button pulse: the lesson is on and the foe is tired.
function Coach.lassoNudge(flags: { string }, wild: boolean, hp: number, maxHp: number): boolean
	return Coach.lassoCoachActive(flags, wild) and hp > 0 and Coach.isTired(hp, maxHp)
end

-- After a missed throw: only a Common creature is promised not to run, so only it gets the
-- reassurance. Nil means keep the usual line.
function Coach.missLine(rarity: string): string?
	if rarity == "Common" then
		return Coach.LINES.missedCommon
	end
	return nil
end

-- Where a newly caught creature went. The server puts a catch in the stable, and on the team
-- only when the team was empty (Grants.recordOwned), so that is the rule used here.
-- `teamBefore` is the team size before the catch; nil (not known) gives the safe words.
function Coach.placementLine(teamBefore: number?): string
	if teamBefore == nil then
		return Coach.LINES.friend
	end
	return if teamBefore == 0 then Coach.LINES.joined else Coach.LINES.stable
end

return Coach
