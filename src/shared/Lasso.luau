--!strict
-- The lasso timing game: pure rules, no dice. The server creates a pattern from a seed and judges
-- the player's tap times; the phone draws the sweep from the same pattern, so it sees no lag.
-- Each zone has its own sweep that starts at `startMs` after the pattern starts. The marker moves
-- as a triangle wave along the 0..1 arc: out, then back.

local LassoConfig = require("../config/LassoConfig")
local Rng = require("./Rng")
local Types = require("./Types")

export type LassoTier = "Basic" | "Braided" | "Gilded"

export type Zone = {
	centre: number, -- 0..1 on the arc
	width: number, -- 0..1; the zone is centre +/- width / 2
	speed: number, -- arc lengths per second, after tier, slow mode and connection assist
	startPhase: number, -- 0..2, where the marker is in its out-and-back cycle at startMs
	startMs: number, -- when this zone's sweep begins, since the pattern started
}

export type Pattern = {
	seed: number,
	zones: { Zone },
	isGiant: boolean,
	slowMode: boolean,
	connectionAssist: boolean, -- true: the round trip was over the cap and the sweep was slowed
	speedScale: number, -- the assist's slowing factor (1 when there is no assist)
	roundTripMs: number, -- the server's own reading, fixed when the attempt was made; the judge uses this
}

export type AttemptInput = {
	seed: number,
	lassoDifficulty: number,
	rarity: Types.Rarity,
	healthFraction: number, -- 0..1 of full health
	tier: LassoTier,
	isGiant: boolean,
	slowMode: boolean,
	roundTripMs: number,
	firstCatch: boolean?, -- the player has never caught anything (the server's own record)
}

export type Verdict = "Hit" | "Miss" | "Invalid"

export type Judgement = {
	verdict: Verdict,
	zoneHits: { boolean }, -- empty when invalid
	errorsMs: { number }, -- timing error from each zone's centre; empty when invalid
	chances: { number }, -- each zone's catch chance from where its tap landed; empty when invalid
	reason: string?, -- set when invalid
}

local Lasso = {}

local function clamp(value: number, low: number, high: number): number
	return math.max(low, math.min(high, value))
end

-- Health factor: small at full health, 1 at zero health.
function Lasso.healthFactor(healthFraction: number): number
	local lost = 1 - clamp(healthFraction, 0, 1)
	local full = LassoConfig.HEALTH_FACTOR_FULL
	return full
		+ (LassoConfig.HEALTH_FACTOR_EMPTY - full) * lost ^ LassoConfig.HEALTH_FACTOR_EXPONENT
end

-- Width of one zone before any giant narrowing.
function Lasso.zoneWidth(
	rarity: Types.Rarity,
	lassoDifficulty: number,
	healthFraction: number,
	tier: LassoTier
): number
	local difficulty = math.max(lassoDifficulty, LassoConfig.MIN_DIFFICULTY)
	local width = LassoConfig.BASE_WIDTH[rarity]
		/ difficulty
		* Lasso.healthFactor(healthFraction)
		* LassoConfig.TIER_WIDTH[tier]
	return clamp(width, LassoConfig.MIN_WIDTH, LassoConfig.MAX_WIDTH)
end

function Lasso.zoneCount(rarity: Types.Rarity, lassoDifficulty: number, isGiant: boolean): number
	if isGiant then
		return LassoConfig.GIANT_ZONES
	end
	local count = LassoConfig.ZONES_BY_RARITY[rarity]
	if lassoDifficulty >= LassoConfig.THREE_ZONE_DIFFICULTY then
		count = math.max(count, 3)
	elseif lassoDifficulty >= LassoConfig.TWO_ZONE_DIFFICULTY then
		count = math.max(count, 2)
	end
	return count
end

-- The slowing factor for a measured round trip: 1 inside the cap, cap / roundTrip above it.
function Lasso.assistScale(roundTripMs: number): number
	local cap = LassoConfig.ROUND_TRIP_CAP_MS
	if roundTripMs ~= roundTripMs or roundTripMs <= cap then
		return 1
	end
	return math.max(cap / roundTripMs, LassoConfig.ASSIST_MIN_SPEED)
end

function Lasso.createAttempt(input: AttemptInput): Pattern
	local rng = Rng.new(input.seed)
	local width =
		Lasso.zoneWidth(input.rarity, input.lassoDifficulty, input.healthFraction, input.tier)
	if input.isGiant then
		width = math.max(width * LassoConfig.GIANT_WIDTH, LassoConfig.MIN_WIDTH)
	end
	if
		input.firstCatch
		and not input.isGiant
		and LassoConfig.FIRST_CATCH_RARITIES[input.rarity]
	then
		width = math.min(
			math.max(width * LassoConfig.FIRST_CATCH_WIDTH, LassoConfig.FIRST_CATCH_MIN_WIDTH),
			LassoConfig.MAX_WIDTH
		)
	end
	local assist = Lasso.assistScale(input.roundTripMs)
	-- Slow mode and the assist stack, but only down to a floor, so the two cannot be combined
	-- into a crawl.
	local slowing = assist * (if input.slowMode then LassoConfig.SLOW_MODE_SPEED else 1)
	slowing = math.max(slowing, LassoConfig.MIN_TOTAL_SPEED)
	local baseSpeed = LassoConfig.BASE_SPEED * LassoConfig.TIER_SPEED[input.tier] * slowing

	local zones: { Zone } = {}
	local count = Lasso.zoneCount(input.rarity, input.lassoDifficulty, input.isGiant)
	local margin = LassoConfig.CENTRE_MARGIN + width / 2
	for index = 1, count do
		local jitter = 1 + (Rng.next(rng) * 2 - 1) * LassoConfig.SPEED_JITTER
		local step = if input.isGiant then LassoConfig.GIANT_SPEED_STEPS[index] else 1
		local centre = margin + Rng.next(rng) * math.max(0, 1 - 2 * margin)
		table.insert(zones, {
			centre = centre,
			width = width,
			speed = baseSpeed * jitter * step,
			startPhase = Rng.next(rng) * 2,
			startMs = (index - 1) * LassoConfig.ZONE_GAP_MS,
		})
	end

	return {
		seed = input.seed,
		zones = zones,
		isGiant = input.isGiant,
		slowMode = input.slowMode,
		connectionAssist = assist < 1,
		speedScale = assist,
		roundTripMs = input.roundTripMs,
	}
end

-- A triangle wave: phase 0..1 goes out, 1..2 comes back, then it repeats.
function Lasso.triangle(phase: number): number
	local wrapped = phase % 2
	if wrapped <= 1 then
		return wrapped
	end
	return 2 - wrapped
end

local function phaseAt(zone: Zone, elapsedMs: number): number
	local local_ = math.max(0, elapsedMs - zone.startMs)
	return zone.startPhase + zone.speed * local_ / 1000
end

-- Where the marker is on the arc for a zone at a time since the pattern started.
function Lasso.markerPosition(pattern: Pattern, zoneIndex: number, elapsedMs: number): number
	return Lasso.triangle(phaseAt(pattern.zones[zoneIndex], elapsedMs))
end

function Lasso.isInZone(zone: Zone, position: number): boolean
	return math.abs(position - zone.centre) <= zone.width / 2
end

-- Milliseconds between a tap and the nearest moment the marker crosses the zone's centre.
function Lasso.timingErrorMs(pattern: Pattern, zoneIndex: number, claimedMs: number): number
	local zone = pattern.zones[zoneIndex]
	local phase = phaseAt(zone, claimedMs)
	local best = math.huge
	for _, target in { zone.centre, 2 - zone.centre } do
		local distance = math.abs((phase - target + 1) % 2 - 1)
		best = math.min(best, distance)
	end
	return best / zone.speed * 1000
end

-- The first time at or after `afterMs` that the marker crosses a zone's centre. Used by tests and
-- by the client's cue sounds.
function Lasso.nextCentreTimeMs(pattern: Pattern, zoneIndex: number, afterMs: number): number
	local zone = pattern.zones[zoneIndex]
	local from = math.max(afterMs, zone.startMs)
	local phase = phaseAt(zone, from)
	local best = math.huge
	for _, target in { zone.centre, 2 - zone.centre } do
		local cycles = math.ceil((phase - target) / 2)
		local crossing = target + 2 * cycles
		local time = from + (crossing - phase) / zone.speed * 1000
		best = math.min(best, time)
	end
	return best
end

local function invalid(reason: string): Judgement
	return { verdict = "Invalid", zoneHits = {}, errorsMs = {}, chances = {}, reason = reason }
end

local function isFiniteNumber(value: any): boolean
	return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end

-- The round trip to trust for a player, from the server's own readings during the battle.
-- The smallest reading is used: a delayed reply can raise a reading but nothing can lower one.
function Lasso.trustedRoundTripMs(readingsMs: { number }): number
	local smallest = math.huge
	local good = 0
	for _, reading in readingsMs do
		if isFiniteNumber(reading) and reading >= 0 then
			good += 1
			smallest = math.min(smallest, reading)
		end
	end
	if good < LassoConfig.ROUND_TRIP_MIN_SAMPLES then
		return LassoConfig.ROUND_TRIP_DEFAULT_MS
	end
	return smallest
end

-- Judge a throw. `claimedMs[i]` is the phone's time for zone i since the pattern started;
-- `serverElapsedMs[i]` is the server's own clock when that tap arrived.
-- The lag allowance comes from the pattern, so it is the same reading the sweep was built with.
-- A claim outside the lag window is Invalid. The caller must treat Invalid exactly like a miss
-- (the lasso stays spent and it counts toward fleeing), or a player could turn every miss into
-- a free retry by sending an impossible time.
function Lasso.judge(
	pattern: Pattern,
	claimedMs: { number },
	serverElapsedMs: { number }
): Judgement
	local roundTripMs = pattern.roundTripMs
	local count = #pattern.zones
	if #claimedMs ~= count or #serverElapsedMs ~= count then
		return invalid("wrong number of taps")
	end
	if not isFiniteNumber(roundTripMs) or roundTripMs < 0 then
		return invalid("bad round trip")
	end
	local allowance = math.min(roundTripMs, LassoConfig.ROUND_TRIP_CAP_MS)
		+ LassoConfig.CLAIM_EARLY_MARGIN_MS
	for index = 1, count do
		local claimed, serverNow = claimedMs[index], serverElapsedMs[index]
		if not isFiniteNumber(claimed) or not isFiniteNumber(serverNow) then
			return invalid("bad time")
		end
		if claimed < pattern.zones[index].startMs or claimed > LassoConfig.MAX_ATTEMPT_MS then
			return invalid("outside the attempt")
		end
		if claimed < serverNow - allowance then
			return invalid("claim too early for the server's clock")
		end
		if claimed > serverNow + LassoConfig.CLAIM_MARGIN_MS then
			return invalid("claim too late for the server's clock")
		end
	end

	local hits: { boolean } = {}
	local errors: { number } = {}
	local chances: { number } = {}
	local allHit = true
	for index = 1, count do
		local zone = pattern.zones[index]
		local position = Lasso.markerPosition(pattern, index, claimedMs[index])
		local hit = Lasso.isInZone(zone, position)
		table.insert(hits, hit)
		table.insert(errors, Lasso.timingErrorMs(pattern, index, claimedMs[index]))
		table.insert(chances, Lasso.tapChance(zone, position))
		allHit = allHit and hit
	end
	return {
		verdict = if allHit then "Hit" else "Miss",
		zoneHits = hits,
		errorsMs = errors,
		chances = chances,
	}
end

-- One tap's catch chance (wild throws only), from where the marker was on the arc when the tap
-- was judged. Straight lines: CENTRE at the zone centre to EDGE at its edge, then OUTSIDE_NEAR
-- just past the edge down to OUTSIDE_FLOOR at OUTSIDE_FALL_ARC beyond it. The position is the
-- server's own reading of the claimed time, which Lasso.judge has already checked against the
-- server's clock; an invalid claim never reaches here and counts 0.
function Lasso.tapChance(zone: Zone, position: number): number
	if position ~= position then
		return 0
	end
	local half = math.max(zone.width / 2, 1e-9)
	local distance = math.abs(position - zone.centre)
	if distance <= half then
		local share = distance / half
		return LassoConfig.CHANCE_CENTRE
			+ (LassoConfig.CHANCE_EDGE - LassoConfig.CHANCE_CENTRE) * share
	end
	-- The fall-off is measured in zone widths, so a narrow zone (a healthy or rare creature, a
	-- plain lasso) forgives little outside it and weakening a creature still matters; capped
	-- both ways in arc units (review of 23 November 2026).
	local fall = clamp(
		zone.width * LassoConfig.CHANCE_OUTSIDE_FALL_WIDTHS,
		LassoConfig.CHANCE_OUTSIDE_FALL_MIN_ARC,
		LassoConfig.CHANCE_OUTSIDE_FALL_ARC
	)
	local share = clamp((distance - half) / fall, 0, 1)
	return LassoConfig.CHANCE_OUTSIDE_NEAR
		+ (LassoConfig.CHANCE_OUTSIDE_FLOOR - LassoConfig.CHANCE_OUTSIDE_NEAR) * share
end

-- The whole throw's catch chance: the zones' chances multiplied, times the rarity factor,
-- clamped to 0..1. No chances (an invalid throw) is 0.
function Lasso.catchChance(chances: { number }, rarity: Types.Rarity): number
	if #chances == 0 then
		return 0
	end
	local chance = LassoConfig.RARITY_CHANCE[rarity]
	for _, each in chances do
		chance *= clamp(each, 0, 1)
	end
	return clamp(chance, 0, 1)
end

-- The best a throw of this pattern could do: every tap dead centre. Shown to the player before
-- the throw ("up to N%"); the real chance comes from where the taps land.
function Lasso.bestChance(zoneCount: number, rarity: Types.Rarity): number
	local chances: { number } = {}
	for _ = 1, zoneCount do
		table.insert(chances, LassoConfig.CHANCE_CENTRE)
	end
	return Lasso.catchChance(chances, rarity)
end

-- True when the recent errors look scripted: enough throws, and most of them within a few
-- milliseconds of the centre. Looks only at the latest SCRIPTED_MIN_SAMPLES.
function Lasso.looksScripted(errorsMs: { number }): boolean
	local needed = LassoConfig.SCRIPTED_MIN_SAMPLES
	if #errorsMs < needed then
		return false
	end
	local tiny = 0
	for index = #errorsMs - needed + 1, #errorsMs do
		if errorsMs[index] < LassoConfig.SCRIPTED_TINY_MS then
			tiny += 1
		end
	end
	return tiny / needed >= LassoConfig.SCRIPTED_TINY_SHARE
end

-- How many misses a wild creature of this rarity allows before it flees; nil if it never flees.
function Lasso.missesBeforeFlee(rarity: Types.Rarity): number?
	local allowed = LassoConfig.FLEE_AFTER_MISSES[rarity]
	if allowed <= 0 then
		return nil
	end
	return allowed
end

return Lasso
