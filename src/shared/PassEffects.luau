--!strict
-- What each game pass does, as pure rules (plan 16, PurchaseConfig.PASSES). A pass is recorded in
-- `profile.Purchases.passes` the first time it is applied; its one-time effect (stable room, a
-- pen) is added in that same step, so applying it twice changes nothing. Effects that are read
-- every time (faster hatching, the stable anywhere, the catch bonus) are looked up from the record.

local ProfileConfig = require("../config/ProfileConfig")
local Profile = require("./Profile")
local PurchaseConfig = require("../config/PurchaseConfig")

local PassEffects = {}

-- Passes whose ongoing effects are switched off for this loaded profile because Roblox clearly said
-- the player does not own them (a refund, a revoked pass). Server memory only, never saved, keyed by
-- the profile table so it disappears with it. Stable room and pens already applied are kept.
local suspended: { [any]: { [string]: boolean } } = setmetatable({}, { __mode = "k" }) :: any

function PassEffects.suspend(profile: Profile.Profile, id: PurchaseConfig.PassId)
	local set = suspended[profile] or {}
	set[id] = true
	suspended[profile] = set
end

function PassEffects.resume(profile: Profile.Profile, id: PurchaseConfig.PassId)
	local set = suspended[profile]
	if set then
		set[id] = nil
	end
end

function PassEffects.isSuspended(profile: Profile.Profile, id: PurchaseConfig.PassId): boolean
	local set = suspended[profile]
	return set ~= nil and set[id] == true
end

-- Owned, applied and not suspended: the pass's ongoing effects count.
local function active(profile: Profile.Profile, id: PurchaseConfig.PassId): boolean
	return profile.Purchases.passes[id] == true and not PassEffects.isSuspended(profile, id)
end

local STABLE_MAX = 65535 -- the device is told the stable size as a u16

-- Turns a name from the device or a log into a pass id, or nil.
function PassEffects.parse(value: unknown): PurchaseConfig.PassId?
	local found: PurchaseConfig.PassId? = nil
	for _, id: PurchaseConfig.PassId in PurchaseConfig.PASS_IDS do
		if id == value then
			found = id
		end
	end
	return found
end

function PassEffects.owned(profile: Profile.Profile, id: PurchaseConfig.PassId): boolean
	return profile.Purchases.passes[id] == true
end

-- Records a pass as owned and applies its one-time effects. Returns true only the first time;
-- a pass already recorded changes nothing. The caller has already checked with Roblox that the
-- player really owns it.
function PassEffects.grant(profile: Profile.Profile, id: PurchaseConfig.PassId): boolean
	if profile.Purchases.passes[id] == true then
		return false
	end
	local def = PurchaseConfig.PASSES[id]
	profile.Purchases.passes[id] = true
	profile.StableCapacity = math.min(profile.StableCapacity + def.stableRoom, STABLE_MAX)
	profile.Pens = math.min(profile.Pens + def.pens, ProfileConfig.MAX_PENS)
	return true
end

-- Stable room that came from purchases (passes and the Starter Pack), so the coin expansions can
-- still be counted from the rest.
function PassEffects.bonusCapacity(profile: Profile.Profile): number
	local total = 0
	for _, id: PurchaseConfig.PassId in PurchaseConfig.PASS_IDS do
		if profile.Purchases.passes[id] == true then
			total += PurchaseConfig.PASSES[id].stableRoom
		end
	end
	if profile.Purchases.once[PurchaseConfig.STARTER_PACK.onceKey] == true then
		total += PurchaseConfig.STARTER_PACK.stableRoom
	end
	return total
end

-- When a new egg hatches: the breed's own time, shortened by the best hatch pass the player owns.
-- Never earlier than `now`, never later than the breed's own time.
function PassEffects.hatchAt(profile: Profile.Profile, now: number, hatchAt: number): number
	local factor = 1
	for _, id: PurchaseConfig.PassId in PurchaseConfig.PASS_IDS do
		if active(profile, id) then
			factor = math.min(factor, PurchaseConfig.PASSES[id].hatchFactor)
		end
	end
	if factor >= 1 or hatchAt <= now then
		return hatchAt
	end
	return now + math.ceil((hatchAt - now) * math.max(factor, 0))
end

-- True if the player's stable can be opened anywhere (Field Satchel).
function PassEffects.stableAnywhere(profile: Profile.Profile): boolean
	for _, id: PurchaseConfig.PassId in PurchaseConfig.PASS_IDS do
		if active(profile, id) and PurchaseConfig.PASSES[id].stableAnywhere then
			return true
		end
	end
	return false
end

-- The server's check for any stable action that used to need a hub.
function PassEffects.mayUseStable(profile: Profile.Profile, atHub: boolean): boolean
	return atHub or PassEffects.stableAnywhere(profile)
end

-- The player's title from their passes, or nil.
function PassEffects.title(profile: Profile.Profile): string?
	for _, id: PurchaseConfig.PassId in PurchaseConfig.PASS_IDS do
		local title = PurchaseConfig.PASSES[id].title
		if active(profile, id) and title ~= nil then
			return title
		end
	end
	return nil
end

-- Owned pass ids, in the config's order (display only).
function PassEffects.list(profile: Profile.Profile): { string }
	local list: { string } = {}
	for _, id: PurchaseConfig.PassId in PurchaseConfig.PASS_IDS do
		if profile.Purchases.passes[id] == true and #list < PurchaseConfig.BLINK_MAX_MARKS then
			table.insert(list, id)
		end
	end
	return list
end

-- Perk and one-time marks (display only): "StarterPack", "StarterCosmetic".
function PassEffects.perks(profile: Profile.Profile): { string }
	local list: { string } = {}
	for _, marks in { profile.Purchases.once, profile.Purchases.perks } do
		for key in marks do
			if #key >= 1 and #key <= PurchaseConfig.BLINK_MAX_KEY then
				table.insert(list, key)
			end
		end
	end
	table.sort(list)
	while #list > PurchaseConfig.BLINK_MAX_MARKS do
		table.remove(list)
	end
	return list
end

-- The Lasso Pass is on only if the player owns it AND paid random items are not restricted for
-- them. `restricted` nil (policy not known yet) counts as restricted.
function PassEffects.lassoBoostActive(profile: Profile.Profile, restricted: boolean?): boolean
	if restricted ~= false then
		return false
	end
	for _, id: PurchaseConfig.PassId in PurchaseConfig.PASS_IDS do
		if active(profile, id) and PurchaseConfig.PASSES[id].lassoBoost then
			return true
		end
	end
	return false
end

-- Does the Lasso Pass apply to this throw? Only with the pass owned, an unrestricted policy, a wild
-- creature that never flees (Common and Uncommon), and never a giant. Decided when the throw
-- begins and kept on the throw, so the chance shown is the chance rolled.
function PassEffects.lassoBoostApplies(
	profile: Profile.Profile,
	restricted: boolean?,
	rarity: string,
	isGiant: boolean
): boolean
	if isGiant or not PassEffects.lassoBoostActive(profile, restricted) then
		return false
	end
	return PurchaseConfig.LASSO_PASS_RARITIES[rarity] == true
end

-- A wild throw's chance with the Lasso Pass: min(CAP, chance + BONUS), never lower than the chance
-- it started with, never for giants, and an impossible throw (0) stays 0.
function PassEffects.boostChance(chance: number, applies: boolean, isGiant: boolean): number
	if not applies or isGiant or chance <= 0 then
		return chance
	end
	local boosted =
		math.min(PurchaseConfig.LASSO_PASS_CAP, chance + PurchaseConfig.LASSO_PASS_BONUS)
	return math.max(chance, boosted)
end

return PassEffects
