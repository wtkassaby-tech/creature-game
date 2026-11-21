--!strict
-- Damage that lasts. A creature hurt in a battle stays hurt afterwards, until a tonic or the
-- healer in town mends it (brief section 5: consumables are needed to heal damaged creatures).
-- A creature record keeps the share of health it has lost (`hurt`, 0 to 1), so the number stays
-- right when the creature levels up or fights under a level cap.
--
-- Pure rules. The battle session copies a creature's health in at the start and writes it back
-- after every turn, so leaving a battle part way never undoes the damage.

local BattleConfig = require("../config/BattleConfig")
local BattleSession = require("./BattleSession")
local Profile = require("./Profile")
local Types = require("./Types")

local Health = {}

-- The share of its health a creature has left, 0 to 1.
function Health.share(creature: Types.Creature): number
	local hurt = creature.hurt
	if hurt == nil or hurt ~= hurt then
		return 1
	end
	return 1 - math.clamp(hurt, 0, 1)
end

function Health.isFainted(creature: Types.Creature): boolean
	return Health.share(creature) <= 0
end

-- True if at least one of these creatures can still fight.
function Health.anyStanding(creatures: { Types.Creature }): boolean
	for _, creature in creatures do
		if not Health.isFainted(creature) then
			return true
		end
	end
	return false
end

-- The healer in town: every creature the player owns is mended. Returns how many needed it.
function Health.healAll(profile: Profile.Profile): number
	local mended = 0
	for _, creature in profile.Creatures do
		if creature.hurt ~= nil then
			creature.hurt = nil
			mended += 1
		end
	end
	return mended
end

-- Waking at the healer after the whole team fainted: only the team that fought is mended.
-- Creatures left in the stable stay as they were, so a lost battle is not a free heal for all.
function Health.healTeam(profile: Profile.Profile): number
	local mended = 0
	for _, id in profile.Team do
		local creature = profile.Creatures[id]
		if creature and creature.hurt ~= nil then
			creature.hurt = nil
			mended += 1
		end
	end
	return mended
end

-- Uses a tonic or a Rally Root on a creature outside a battle. `item` and `creatureId` come from
-- the device. The item is taken only if it did something. Returns the creature's new share of
-- health, or nil and a reason.
function Health.useItem(
	profile: Profile.Profile,
	item: unknown,
	creatureId: unknown,
	isLocked: (creatureId: string) -> boolean
): (number?, string?)
	local id: BattleSession.FieldItem? = BattleSession.parseFieldItem(item)
	if not id then
		return nil, "That cannot be used on a creature"
	end
	if typeof(creatureId) ~= "string" or profile.Creatures[creatureId] == nil then
		return nil, "You do not own that creature"
	end
	if isLocked(creatureId) then
		return nil, "That creature is in a battle"
	end
	local key: string = id
	if (profile.Items[key] or 0) < 1 then
		return nil, "You have none of those"
	end
	local creature = profile.Creatures[creatureId]
	local share = Health.share(creature)
	local effect = BattleConfig.FIELD_ITEMS[id]
	local after: number
	if effect.kind == "Heal" then
		if share <= 0 then
			return nil, "That creature has fainted"
		elseif share >= 1 then
			return nil, "That creature is not hurt"
		end
		after = math.min(1, share + effect.share)
	else
		if share > 0 then
			return nil, "That creature has not fainted"
		end
		after = math.clamp(effect.share, 0, 1)
	end
	creature.hurt = if after >= 1 then nil else 1 - after
	profile.Items[key] -= 1
	return after, nil
end

return Health
