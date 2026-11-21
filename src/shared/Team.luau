--!strict
-- Choosing the team: which of the player's creatures come to a battle, and in what order.
-- Pure rules. The device sends the whole new team as a list of creature ids.

local Profile = require("./Profile")

local Team = {}

-- Replaces the team. `ids` comes from the device. Every id must be a different creature the
-- player owns, the team must hold at least one and no more than their badges allow, and nothing
-- may change while any of the creatures involved is in a battle.
function Team.set(
	profile: Profile.Profile,
	ids: unknown,
	isLocked: (creatureId: string) -> boolean
): (boolean, string?)
	if typeof(ids) ~= "table" then
		return false, "Bad request"
	end
	local list: { string } = {}
	local seen: { [string]: boolean } = {}
	local count = 0
	for key, id in ids :: { [any]: any } do
		count += 1
		if typeof(key) ~= "number" or typeof(id) ~= "string" or count > 6 then
			return false, "Bad request"
		end
	end
	for index = 1, count do
		local id = (ids :: { any })[index]
		if typeof(id) ~= "string" then
			return false, "Bad request" -- a list with gaps
		end
		if seen[id] then
			return false, "A creature can only be on the team once"
		end
		if profile.Creatures[id] == nil then
			return false, "You do not own that creature"
		end
		seen[id] = true
		list[index] = id
	end
	if #list < 1 then
		return false, "You need at least one creature on your team"
	end
	if #list > Profile.teamSize(profile.Story.badges) then
		return false, "Your team is full: earn badges to bring more"
	end
	for _, id in profile.Team do
		if isLocked(id) then
			return false, "You cannot change your team during a battle"
		end
	end
	for _, id in list do
		if isLocked(id) then
			return false, "You cannot change your team during a battle"
		end
	end
	-- A team nobody on which can fight is refused while the player owns a creature that can:
	-- fielding a fainted team to lose on purpose is not a way to be carried home and healed.
	local teamStanding, anyStanding = false, false
	for _, id in list do
		teamStanding = teamStanding or (profile.Creatures[id].hurt or 0) < 1
	end
	for _, creature in profile.Creatures do
		anyStanding = anyStanding or (creature.hurt or 0) < 1
	end
	if anyStanding and not teamStanding then
		return false, "At least one creature on your team must be able to fight"
	end
	profile.Team = list
	return true, nil
end

return Team
