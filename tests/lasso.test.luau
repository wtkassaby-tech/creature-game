--!strict
-- Tests for the lasso timing rules. Run: lune run tests/lasso.test

local Lasso = require("../src/shared/Lasso")
local LassoConfig = require("../src/config/LassoConfig")
local Rng = require("../src/shared/Rng")
local Types = require("../src/shared/Types")

local passed, failed = 0, 0
local function check(name: string, condition: boolean, detail: string?)
	if condition then
		passed += 1
		print(`  PASS  {name}{if detail then "  (" .. detail .. ")" else ""}`)
	else
		failed += 1
		print(`  FAIL  {name}{if detail then "  (" .. detail .. ")" else ""}`)
	end
end

local function input(overrides: { [string]: any }?): Lasso.AttemptInput
	local base: Lasso.AttemptInput = {
		seed = 4242,
		lassoDifficulty = 1,
		rarity = "Common",
		healthFraction = 0.3,
		tier = "Basic",
		isGiant = false,
		slowMode = false,
		roundTripMs = 80,
	}
	if overrides then
		for key, value in overrides do
			(base :: any)[key] = value
		end
	end
	return base
end

local function width(overrides: { [string]: any }?): number
	return Lasso.createAttempt(input(overrides)).zones[1].width
end

local function speed(overrides: { [string]: any }?): number
	return Lasso.createAttempt(input(overrides)).zones[1].speed
end

print("\n== Pattern ==")
do
	local a = Lasso.createAttempt(input())
	local b = Lasso.createAttempt(input())
	local same = #a.zones == #b.zones
	for i, zone in a.zones do
		same = same
			and zone.centre == b.zones[i].centre
			and zone.width == b.zones[i].width
			and zone.speed == b.zones[i].speed
			and zone.startPhase == b.zones[i].startPhase
	end
	check("the same seed and inputs give the same pattern", same)
	local c = Lasso.createAttempt(input({ seed = 99 }))
	check("a different seed gives a different pattern", c.zones[1].centre ~= a.zones[1].centre)
	check("a normal creature has one zone", #a.zones == 1)
	check(
		"a hard creature has more zones",
		#Lasso.createAttempt(input({ lassoDifficulty = 2 })).zones == 2
	)
	check(
		"a very hard creature has three zones",
		#Lasso.createAttempt(input({ lassoDifficulty = 3 })).zones == 3
	)
	local giant = Lasso.createAttempt(input({ isGiant = true }))
	check("a giant gets three zones", #giant.zones == 3)
	check(
		"a giant's zones change speed",
		giant.zones[1].speed ~= giant.zones[2].speed
			and giant.zones[2].speed ~= giant.zones[3].speed
	)
	check(
		"a giant's zones are narrower than a normal creature's",
		giant.zones[1].width < width({ healthFraction = 0.3 })
	)
	local inside = true
	for _, zone in giant.zones do
		inside = inside and zone.centre - zone.width / 2 >= 0 and zone.centre + zone.width / 2 <= 1
	end
	check("every zone lies on the arc", inside)
end

print("\n== Zone width ==")
do
	local fullWidth, weakWidth = width({ healthFraction = 1 }), width({ healthFraction = 0.2 })
	check(
		"lower health gives a wider zone",
		weakWidth > width({ healthFraction = 0.6 }) and width({ healthFraction = 0.6 }) > fullWidth
	)
	check(
		"full health is too narrow to be worth trying",
		fullWidth < 0.02,
		string.format("full %.4f, 20%% health %.4f", fullWidth, weakWidth)
	)
	local rarities: { Types.Rarity } = { "Common", "Uncommon", "Gem", "Ruby", "Diamond", "Cosmic" }
	local narrowing = true
	local previous = math.huge
	for _, rarity in rarities do
		local w = width({ rarity = rarity })
		narrowing = narrowing and w < previous
		previous = w
	end
	check("a rarer creature is narrower", narrowing)
	check(
		"a higher lassoDifficulty is narrower",
		width({ lassoDifficulty = 2 }) < width({ lassoDifficulty = 1 })
	)
	local basic, braided, gilded =
		width({ tier = "Basic" }), width({ tier = "Braided" }), width({ tier = "Gilded" })
	check("each better tier is wider", basic < braided and braided < gilded)
	local sBasic, sBraided, sGilded =
		speed({ tier = "Basic" }), speed({ tier = "Braided" }), speed({ tier = "Gilded" })
	check("each better tier is slower", sBasic > sBraided and sBraided > sGilded)
end

print("\n== Marker and judging ==")
do
	local pattern = Lasso.createAttempt(input({ healthFraction = 0.3 }))
	local zone = pattern.zones[1]
	check(
		"the marker triangle goes out and back",
		Lasso.triangle(0.25) == 0.25 and Lasso.triangle(1.75) == 0.25
	)
	local t = Lasso.nextCentreTimeMs(pattern, 1, 500)
	check(
		"the marker is at the centre at the computed time",
		math.abs(Lasso.markerPosition(pattern, 1, t) - zone.centre) < 1e-9
	)
	check("a tap at the centre hits", Lasso.judge(pattern, { t }, { t }).verdict == "Hit")
	-- Tap just outside: shift by enough time to move the marker half a width plus a little.
	local outsideMs = (zone.width / 2 + 0.01) / zone.speed * 1000
	local miss = Lasso.judge(pattern, { t + outsideMs }, { t + outsideMs })
	check(
		"a tap just outside misses",
		miss.verdict == "Miss",
		string.format("error %.0f ms", miss.errorsMs[1] or -1)
	)
	local insideMs = (zone.width / 2 - 0.01) / zone.speed * 1000
	check(
		"a tap just inside hits",
		Lasso.judge(pattern, { t + insideMs }, { t + insideMs }).verdict == "Hit"
	)
	check("the centre tap has a near-zero timing error", Lasso.timingErrorMs(pattern, 1, t) < 0.001)
	check(
		"timing error counts milliseconds from the centre",
		math.abs(Lasso.timingErrorMs(pattern, 1, t + 25) - 25) < 0.5
	)

	-- Multi-zone: all zones must hit.
	local giant = Lasso.createAttempt(input({ isGiant = true, healthFraction = 0 }))
	local good: { number } = {}
	for i = 1, 3 do
		table.insert(good, Lasso.nextCentreTimeMs(giant, i, giant.zones[i].startMs + 400))
	end
	check(
		"a giant throw with every tap centred hits",
		Lasso.judge(giant, good, good).verdict == "Hit"
	)
	local bad = table.clone(good)
	bad[2] += (giant.zones[2].width / 2 + 0.02) / giant.zones[2].speed * 1000
	local verdict = Lasso.judge(giant, bad, bad)
	check(
		"one missed zone misses the throw",
		verdict.verdict == "Miss" and verdict.zoneHits[1] and not verdict.zoneHits[2]
	)
end

print("\n== Lag window ==")
do
	local pattern = Lasso.createAttempt(input())
	local now = 2000
	-- The lag allowance is fixed in the pattern when the attempt is made, so each reading
	-- gets its own pattern here (same seed, so the same zones unless the assist slows it).
	local function judgeAt(claimed: number, rtt: number): string
		local made = Lasso.createAttempt(input({ roundTripMs = rtt }))
		return Lasso.judge(made, { claimed }, { now }).verdict
	end
	check("a claim equal to the server clock is accepted", judgeAt(now, 80) ~= "Invalid")
	check("a claim one round trip behind is accepted", judgeAt(now - 80, 80) ~= "Invalid")
	check(
		"a claim a little ahead (inside the margin) is accepted",
		judgeAt(now + LassoConfig.CLAIM_MARGIN_MS - 1, 80) ~= "Invalid"
	)
	check("a claim too early is invalid, not a miss", judgeAt(now - 81, 80) == "Invalid")
	check(
		"a claim too late is invalid, not a miss",
		judgeAt(now + LassoConfig.CLAIM_MARGIN_MS + 1, 80) == "Invalid"
	)
	check(
		"the round trip is capped: a claim 500 ms behind is invalid even at 900 ms ping",
		judgeAt(now - 500, 900) == "Invalid"
			and judgeAt(now - LassoConfig.ROUND_TRIP_CAP_MS, 900) ~= "Invalid"
	)
	check(
		"a wrong number of taps is invalid",
		Lasso.judge(pattern, { now, now }, { now, now }).verdict == "Invalid"
	)
	check("a NaN claim is invalid", Lasso.judge(pattern, { 0 / 0 }, { now }).verdict == "Invalid")
	check("a negative claim is invalid", judgeAt(-5, 80) == "Invalid")
	check(
		"a claim after the attempt expires is invalid",
		Lasso.judge(pattern, { 20000 }, { 20000 }).verdict == "Invalid"
	)
end

print("\n== Assist and slow mode ==")
do
	local normal = Lasso.createAttempt(input({ roundTripMs = 200 }))
	local laggy = Lasso.createAttempt(input({ roundTripMs = 800 }))
	check(
		"a round trip inside the cap has no assist",
		not normal.connectionAssist and normal.speedScale == 1
	)
	check("a round trip over the cap flags the assist", laggy.connectionAssist)
	check(
		"the sweep slows in proportion to the round trip",
		math.abs(laggy.zones[1].speed / normal.zones[1].speed - 0.5) < 1e-9,
		string.format("%.3f", laggy.zones[1].speed / normal.zones[1].speed)
	)
	check("the assist leaves the zone width alone", laggy.zones[1].width == normal.zones[1].width)
	local crawl = Lasso.createAttempt(input({ slowMode = true, roundTripMs = 2000 }))
	check(
		"slow mode and the assist together never go below the floor",
		math.abs(crawl.zones[1].speed / normal.zones[1].speed - LassoConfig.MIN_TOTAL_SPEED) < 1e-9
	)
	check(
		"the trusted round trip is the smallest reading",
		Lasso.trustedRoundTripMs({ 310, 95, 400, 120 }) == 95
	)
	check(
		"with too few readings a default is used, however large they are",
		Lasso.trustedRoundTripMs({ 900, 900 }) == LassoConfig.ROUND_TRIP_DEFAULT_MS
	)
	local slow = Lasso.createAttempt(input({ slowMode = true }))
	local fast = Lasso.createAttempt(input())
	check(
		"slow mode makes the marker 30% slower",
		math.abs(slow.zones[1].speed / fast.zones[1].speed - 0.7) < 1e-9
	)
	check("slow mode leaves the zone alone", slow.zones[1].width == fast.zones[1].width)
end

print("\n== Scripted-timing detector and flee counter ==")
do
	local rng = Rng.new(11)
	local robot: { number } = {}
	for _ = 1, 30 do
		table.insert(robot, Rng.next(rng) * 6)
	end
	check("30 throws under 10 ms are flagged", Lasso.looksScripted(robot))
	local human: { number } = {}
	for _ = 1, 40 do
		table.insert(human, math.abs(Rng.next(rng) - 0.5) * 300)
	end
	check("a human-looking spread is not flagged", not Lasso.looksScripted(human))
	check("too few throws are not flagged", not Lasso.looksScripted({ 1, 2, 3, 4, 5 }))
	local mixed: { number } = {}
	for _ = 1, 25 do
		table.insert(mixed, 80)
	end
	for _ = 1, 30 do
		table.insert(mixed, 2)
	end
	check("it judges the latest 30 throws", Lasso.looksScripted(mixed))
	check("common creatures never flee", Lasso.missesBeforeFlee("Common") == nil)
	check("rare creatures flee after a set number of misses", Lasso.missesBeforeFlee("Ruby") == 3)
end

print("\n== Simulated human ==")
do
	local SPREAD_MS = 60 -- standard deviation of a decent player's tap timing
	local TRIALS = 2000
	local rng = Rng.new(7)
	local function gaussian(): number
		local u1, u2 = 1 - Rng.next(rng), Rng.next(rng)
		return math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2)
	end
	local function catchRate(health: number, overrides: { [string]: any }?): number
		local hits = 0
		for trial = 1, TRIALS do
			local pattern =
				Lasso.createAttempt(input({ seed = trial * 31, healthFraction = health }))
			if overrides then
				pattern = Lasso.createAttempt(input(overrides))
			end
			local claims: { number } = {}
			for i, zone in pattern.zones do
				local aim = Lasso.nextCentreTimeMs(pattern, i, zone.startMs + 600)
				table.insert(claims, math.max(zone.startMs, aim + gaussian() * SPREAD_MS))
			end
			if Lasso.judge(pattern, claims, claims).verdict == "Hit" then
				hits += 1
			end
		end
		return hits / TRIALS
	end
	local weak, full = catchRate(0.2), catchRate(1.0)
	print(
		string.format(
			"  human spread %d ms, common creature, basic lasso: %.1f%% at 20%% health, %.1f%% at full health",
			SPREAD_MS,
			weak * 100,
			full * 100
		)
	)
	check("a weakened common creature is caught most of the time", weak > 0.8)
	check("a full-health creature is caught rarely", full < 0.2)
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("tests failed")
end
