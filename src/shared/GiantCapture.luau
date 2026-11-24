--!strict
-- Capturing a giant (approval packs 2 and 4), as pure rules. Beating a giant gives one hard
-- lasso attempt. A hit does not hand the giant over at once: it is written into the player's
-- saved waiting list, the server fetches the next serial number (a short wait), and only then
-- is the giant added, carrying its number. A number can be skipped but never given twice.
--
-- Each player can capture each giant once, ever. A captured giant is a creature of the giant's
-- own species: bound to the account, marked as a giant, and a little bigger to look at.

local Breeding = require("./Breeding")
local EconomyConfig = require("../config/EconomyConfig")
local GiantBattle = require("./GiantBattle")
local Grants = require("./Grants")
local Lasso = require("./Lasso")
local Profile = require("./Profile")
local Rng = require("./Rng")
local Species = require("../content/Species")
local Types = require("./Types")

export type Throw = {
	giantId: string,
	tier: Lasso.LassoTier,
	pattern: Lasso.Pattern,
	used: boolean, -- a throw is judged once
}

local GiantCapture = {}

local TIERS: { Lasso.LassoTier } = { "Basic", "Braided", "Gilded" }
local TIER_RANK: { [string]: number } = { Basic = 1, Braided = 2, Gilded = 3 }

local function waiting(profile: Profile.Profile, giantId: string): boolean
	for _, pending in profile.Pending do
		if pending.source == "Giant" and pending.ref == giantId then
			return true
		end
	end
	return false
end

-- Whether this player may try to capture this giant now.
function GiantCapture.canCapture(
	profile: Profile.Profile,
	giant: GiantBattle.GiantDef
): (boolean, string?)
	local form = giant.form
	if not form or Species[form.species] == nil then
		return false, "This giant cannot be captured"
	end
	if profile.Story.giantsCaptured[giant.id] then
		return false, "You have already captured this giant"
	end
	if waiting(profile, giant.id) then
		return false, "Your capture is being finished"
	end
	return true, nil
end

-- The giants whose capture hit but has not been finished yet (waiting for a serial number or
-- for room in the stable), by giant id.
function GiantCapture.waitingGiants(profile: Profile.Profile): { string }
	local list: { string } = {}
	for _, pending in profile.Pending do
		if pending.source == "Giant" then
			table.insert(list, pending.ref)
		end
	end
	return list
end

-- Starts the one capture attempt. `tier` comes from the device. The lasso is taken before the
-- sweep is sent, and the sweep carries the server's own round-trip reading.
function GiantCapture.begin(
	profile: Profile.Profile,
	giant: GiantBattle.GiantDef,
	tier: unknown,
	seed: number,
	roundTripMs: number
): (Throw?, string?)
	local allowed, why = GiantCapture.canCapture(profile, giant)
	local form = giant.form
	if not allowed or not form then
		return nil, why
	end
	local chosen: Lasso.LassoTier? = nil
	for _, each: Lasso.LassoTier in TIERS do
		if each == tier then
			chosen = each
		end
	end
	if not chosen then
		return nil, "Bad lasso"
	end
	local needed: string = EconomyConfig.LASSO_MIN_TIER[form.rarity]
	if (TIER_RANK[chosen] or 0) < (TIER_RANK[needed] or 0) then
		return nil, `A giant needs at least a {needed} lasso`
	end
	local key: string = chosen
	if (profile.Items[key] or 0) < 1 then
		return nil, `You have no {key} lasso`
	end
	profile.Items[key] -= 1
	local pattern = Lasso.createAttempt({
		seed = seed,
		lassoDifficulty = Species[form.species].lassoDifficulty,
		rarity = form.rarity,
		healthFraction = 0, -- it has just been beaten
		tier = chosen,
		isGiant = true,
		slowMode = profile.Settings.lassoSlowMode,
		roundTripMs = roundTripMs,
	})
	return { giantId = giant.id, tier = chosen, pattern = pattern, used = false }, nil
end

local function asTimes(value: unknown): { number }
	local list: { number } = {}
	if typeof(value) ~= "table" then
		return list
	end
	for index, item in value :: { any } do
		if typeof(index) ~= "number" or typeof(item) ~= "number" then
			return {}
		end
		list[index] = item
	end
	return list
end

-- Judges the attempt. On a hit the capture is written into the saved waiting list (step 1 of
-- the serial steps) and true is returned; the giant itself arrives with `complete`. A miss, or
-- an impossible tap, is simply a miss: the giant must be beaten again for another attempt.
function GiantCapture.finish(
	profile: Profile.Profile,
	throw: Throw,
	claimsMs: unknown,
	serverElapsedMs: { number }
): (boolean, Lasso.Judgement?)
	if throw.used then
		return false, nil
	end
	throw.used = true
	local judgement = Lasso.judge(throw.pattern, asTimes(claimsMs), serverElapsedMs)
	if judgement.verdict ~= "Hit" then
		return false, judgement
	end
	local grant = Grants.startGiant(profile, throw.giantId)
	return grant.outcome == "Waiting", judgement
end

-- Builds the captured giant as a creature, carrying its serial number.
function GiantCapture.build(
	giant: GiantBattle.GiantDef,
	id: string,
	serial: number,
	seed: number
): Types.Creature?
	local form = giant.form
	if not form or Species[form.species] == nil then
		return nil
	end
	local creature =
		Breeding.wild(form.species, id, form.level, form.rarity, form.colour, Rng.new(seed))
	creature.isGiant = true
	creature.bound = true
	creature.serial = serial
	creature.size = form.size
	return creature
end

local function entry(profile: Profile.Profile, giantId: string): Profile.PendingGrant?
	for _, pending in profile.Pending do
		if pending.source == "Giant" and pending.ref == giantId then
			return pending
		end
	end
	return nil
end

-- Clears waiting captures that can never finish because the giant is already captured.
-- Returns how many were cleared.
function GiantCapture.tidy(profile: Profile.Profile): number
	local cleared = 0
	for index = #profile.Pending, 1, -1 do
		local pending = profile.Pending[index]
		if pending.source == "Giant" and profile.Story.giantsCaptured[pending.ref] then
			table.remove(profile.Pending, index)
			cleared += 1
		end
	end
	return cleared
end

-- True if this waiting capture still needs its serial number fetched: it is waiting, it has no
-- number yet, and the giant can really be built. A number is asked for only then, and only
-- once: it is kept on the waiting entry (`keepSerial`), so nothing can waste numbers.
function GiantCapture.needsSerial(profile: Profile.Profile, giant: GiantBattle.GiantDef): boolean
	local waitingEntry = entry(profile, giant.id)
	return waitingEntry ~= nil
		and waitingEntry.serial == nil
		and not profile.Story.giantsCaptured[giant.id]
		and GiantCapture.build(giant, "check", 1, 1) ~= nil
end

-- Writes a fetched serial number onto the waiting capture (saved with the profile). Returns
-- false, changing nothing, if the capture is not waiting or already has a number.
function GiantCapture.keepSerial(profile: Profile.Profile, giantId: string, serial: number): boolean
	return Grants.keepSerial(profile, "Giant", giantId, serial)
end

-- Finishes a waiting capture that has its serial number (step 3): the giant is added, marked
-- as captured and the waiting entry cleared, in one step. "NoRoom" means the stable is full:
-- the capture keeps waiting, number and all, and is finished when there is room.
function GiantCapture.complete(
	profile: Profile.Profile,
	giant: GiantBattle.GiantDef,
	id: string,
	seed: number
): (Grants.Grant, Types.Creature?)
	local waitingEntry = entry(profile, giant.id)
	local serial = if waitingEntry then waitingEntry.serial else nil
	if not serial then
		return { outcome = "Refused", reason = "No capture of that giant has its number yet" }, nil
	end
	local creature = GiantCapture.build(giant, id, serial, seed)
	if not creature then
		return { outcome = "Refused", reason = "This giant cannot be captured" }, nil
	end
	local grant = Grants.finishGiant(profile, giant.id, creature)
	if grant.outcome == "Granted" then
		Grants.recordOwned(profile, creature, true)
		return grant, creature
	end
	return grant, nil
end

return GiantCapture
