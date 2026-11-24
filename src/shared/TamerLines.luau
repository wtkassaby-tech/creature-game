--!strict
-- What a tamer says when a battle against them opens and when the player has won it, from the
-- tamers' data: "Pip: My hat is lucky!". The rival's first-meeting line is his story battle's
-- `before` (the Rival's `firstBefore`), so the first and the gate battle each say their own.
-- Pure: no Roblox services.

local Tamers = require("../content/Tamers")

local TamerLines = {}

export type Said = { speaker: string, line: string }

-- A local tamer goes by the first name ("Pip Alder" -> "Pip"); a story opponent keeps the name
-- the data gives ("Rival").
local function lookup(id: string, which: "before" | "after"): Said?
	local tamer = Tamers.locals[id]
	if tamer then
		local first = string.match(tamer.name, "^%S+") or tamer.name
		return { speaker = first, line = tamer[which] }
	end
	local battle = Tamers.story[id]
	if battle then
		return { speaker = battle.name, line = battle[which] }
	end
	return nil
end

-- What the opponent says as the battle opens; nil for a wild creature or an unknown id.
function TamerLines.before(id: string?): Said?
	return if id then lookup(id, "before") else nil
end

-- What they say after losing.
function TamerLines.after(id: string?): Said?
	return if id then lookup(id, "after") else nil
end

-- "Pip: My hat is lucky!"
function TamerLines.words(said: Said): string
	return `{said.speaker}: {said.line}`
end

return TamerLines
