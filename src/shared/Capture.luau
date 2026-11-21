--!strict
-- A lasso throw in a wild battle, from the server's side (approval pack 2 section 3), as pure
-- functions so every rule is tested:
--   1. `begin` checks the battle is live and wild, the creature is standing, the stable has room
--      and the player has the lasso; it takes the lasso BEFORE the sweep is sent, and builds the
--      sweep with the server's own round-trip reading fixed inside it.
--   2. `finish` judges the taps. An impossible tap counts exactly as a miss. A hit captures the
--      creature (typed candy and all, through Grants) and ends the battle; a miss spends the
--      player's turn, the wild creature acts, and rare creatures may flee after enough misses.

local BattleSession = require("./BattleSession")
local EconomyConfig = require("../config/EconomyConfig")
local Grants = require("./Grants")
local Lasso = require("./Lasso")
local Profile = require("./Profile")
local Species = require("../content/Species")
local Types = require("./Types")

export type Throw = {
	battleId: number,
	turn: number, -- the battle turn this throw uses
	tier: Lasso.LassoTier,
	pattern: Lasso.Pattern,
	startedAtMs: number, -- server clock when the pattern was sent
	used: boolean, -- a throw is judged once
}

export type Outcome = "Caught" | "Missed" | "Fled"
export type Result = {
	outcome: Outcome,
	judgement: Lasso.Judgement,
	turn: BattleSession.TurnResult,
	candy: number?,
	element: Types.Element?,
}

local Capture = {}

local TIER_RANK: { [string]: number } = { Basic = 1, Braided = 2, Gilded = 3 }

local function tierRank(tier: string): number
	return TIER_RANK[tier] or 0
end

-- Turns the device's tier name into a tier, or nil.
local TIERS: { Lasso.LassoTier } = { "Basic", "Braided", "Gilded" }

function Capture.parseTier(value: unknown): Lasso.LassoTier?
	for _, tier: Lasso.LassoTier in TIERS do
		if tier == value then
			return tier
		end
	end
	return nil
end

export type BeginInput = {
	profile: Profile.Profile,
	session: BattleSession.Session,
	turn: unknown, -- the turn the device thinks it is
	tier: unknown,
	seed: number,
	roundTripMs: number, -- from Lasso.trustedRoundTripMs over the server's own readings
	nowMs: number,
	misses: number, -- misses already made against this creature in this battle
}

function Capture.begin(input: BeginInput): (Throw?, string?)
	local session, profile = input.session, input.profile
	local state = session.state
	if session.kind ~= "Wild" then
		return nil, "You can only lasso wild creatures"
	end
	if session.ran or state.winner ~= nil then
		return nil, "The battle is over"
	end
	if typeof(input.turn) ~= "number" or input.turn ~= state.turn + 1 then
		return nil, "That turn has already been played"
	end
	local tier = Capture.parseTier(input.tier)
	if tier == nil then
		return nil, "Bad lasso"
	end
	local itemKey = tostring(input.tier)
	local creature, healthFraction = BattleSession.foe(session)
	if healthFraction <= 0 then
		return nil, "That creature has fainted"
	end
	local flee = Lasso.missesBeforeFlee(creature.rarity)
	if flee ~= nil and input.misses >= flee then
		return nil, "That creature has fled"
	end
	if Grants.room(profile) < 1 then
		return nil, "Your stable is full: release or store a creature first"
	end
	local needed: string = EconomyConfig.LASSO_MIN_TIER[creature.rarity]
	if tierRank(itemKey) < tierRank(needed) then
		return nil, `That creature needs at least a {needed} lasso`
	end
	if (profile.Items[itemKey] or 0) < 1 then
		return nil, `You have no {itemKey} lasso`
	end

	-- Take the lasso first: from here on the throw is paid for, whatever happens.
	profile.Items[itemKey] -= 1
	local pattern = Lasso.createAttempt({
		seed = input.seed,
		lassoDifficulty = Species[creature.parts.Torso.species].lassoDifficulty,
		rarity = creature.rarity,
		healthFraction = healthFraction,
		tier = tier :: Lasso.LassoTier,
		isGiant = false,
		slowMode = profile.Settings.lassoSlowMode,
		roundTripMs = input.roundTripMs,
	})
	return {
		battleId = session.battleId,
		turn = state.turn + 1,
		tier = tier :: Lasso.LassoTier,
		pattern = pattern,
		startedAtMs = input.nowMs,
		used = false,
	},
		nil
end

local function asTimes(value: unknown): { number }?
	if typeof(value) ~= "table" then
		return nil
	end
	local list: { number } = {}
	for index, item in value :: { any } do
		if typeof(index) ~= "number" or typeof(item) ~= "number" then
			return nil
		end
		list[index] = item
	end
	return list
end

-- Judges a throw. `claimsMs` comes from the device; `serverElapsedMs` is the server's own
-- clock, since the pattern was sent, when each tap arrived. Returns nil and a reason only if
-- the throw cannot be judged at all (already used, wrong battle); otherwise always a result.
function Capture.finish(
	profile: Profile.Profile,
	session: BattleSession.Session,
	throw: Throw,
	claimsMs: unknown,
	serverElapsedMs: { number },
	missesAfter: number
): (Result?, string?)
	if throw.used then
		return nil, "That throw has already been judged"
	end
	if throw.battleId ~= session.battleId or session.state.turn + 1 ~= throw.turn then
		return nil, "That throw no longer belongs to this battle"
	end
	throw.used = true
	-- The battle may have ended since the throw began (a Run slipped in, or it was won): then
	-- nothing is caught and nothing is passed, and the lasso stays spent.
	if session.ran or session.state.winner ~= nil then
		return nil, "The battle is over"
	end

	local claims = asTimes(claimsMs) or {}
	local judgement = Lasso.judge(throw.pattern, claims, serverElapsedMs)
	local creature = BattleSession.foe(session)

	if judgement.verdict == "Hit" then
		local granted = Grants.capture(profile, creature)
		-- "Waiting" is a gem-tier find whose serial number is being fetched: it is caught, and
		-- joins the stable with its number a moment later.
		if granted.outcome == "Granted" or granted.outcome == "Waiting" then
			return {
				outcome = "Caught",
				judgement = judgement,
				turn = BattleSession.endCaught(session),
				candy = granted.candy,
				element = granted.element,
			},
				nil
		end
		-- The stable filled up between the throw and the hit: treat it as a miss, lasso spent.
	end

	-- A miss, or an impossible tap, which is treated exactly the same.
	local turn = BattleSession.pass(session, throw.turn)
	if not turn then
		return nil, "That throw no longer belongs to this battle"
	end
	local flee = Lasso.missesBeforeFlee(creature.rarity)
	if flee ~= nil and missesAfter >= flee and not turn.finished then
		BattleSession.endFled(session)
		turn.finished, turn.ran, turn.outcome = true, true, 2
		return { outcome = "Fled", judgement = judgement, turn = turn }, nil
	end
	return { outcome = "Missed", judgement = judgement, turn = turn }, nil
end

return Capture
