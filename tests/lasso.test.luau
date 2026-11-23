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
	local early = LassoConfig.CLAIM_EARLY_MARGIN_MS
	check(
		"a claim a frame or two slower than the smallest reading is accepted",
		judgeAt(now - 66, 48) ~= "Invalid" -- the first Studio run's numbers
	)
	check(
		"a claim too early is invalid, not a miss",
		judgeAt(now - 80 - early - 1, 80) == "Invalid"
			and judgeAt(now - 80 - early, 80) ~= "Invalid"
	)
	check(
		"a claim too late is invalid, not a miss",
		judgeAt(now + LassoConfig.CLAIM_MARGIN_MS + 1, 80) == "Invalid"
	)
	check(
		"the round trip is capped: a claim past the cap and the slack is invalid even at 900 ms ping",
		judgeAt(now - LassoConfig.ROUND_TRIP_CAP_MS - early - 1, 900) == "Invalid"
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
	-- A lag switch turned off after the throw: the sweep was slowed, but the taps arrive quickly.
	local least = LassoConfig.ROUND_TRIP_CAP_MS * LassoConfig.ASSIST_MIN_LAG_SHARE
	check(
		"a slowed sweep with quick taps is invalid",
		Lasso.judge(laggy, { 2000 - least + 1 }, { 2000 }).verdict == "Invalid"
	)
	check(
		"a slowed sweep with taps that really lag is judged",
		Lasso.judge(laggy, { 2000 - 450 }, { 2000 }).verdict ~= "Invalid"
	)
	check(
		"quick taps are fine when the sweep was not slowed",
		Lasso.judge(normal, { 2000 }, { 2000 }).verdict ~= "Invalid"
	)
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
		"with too few readings (and no engine ping) the default is used, however large they are",
		Lasso.trustedRoundTripMs({ 900, 900 }) == LassoConfig.ROUND_TRIP_DEFAULT_MS
	)
	local margin = LassoConfig.ROUND_TRIP_ENGINE_MARGIN_MS
	check(
		"held-back replies cannot raise it above the engine's own ping (bug hunt: net 1)",
		Lasso.trustedRoundTripMs({ 1000, 1000, 1000, 1000 }, 60) == 60 + margin
	)
	check(
		"an honest reading below the engine figure is kept",
		Lasso.trustedRoundTripMs({ 50, 90, 80 }, 300) == 50
	)
	check(
		"with too few readings an honest slow connection gets its own ping (capture 2)",
		Lasso.trustedRoundTripMs({}, 300) == 300 + margin
	)
	check(
		"with neither, the generous default (the cap, so no slowing)",
		Lasso.trustedRoundTripMs({}, nil) == LassoConfig.ROUND_TRIP_CAP_MS
			and Lasso.assistScale(Lasso.trustedRoundTripMs({}, nil)) == 1
	)
	check(
		"a made-up engine figure is ignored",
		Lasso.trustedRoundTripMs({ 70, 80, 90 }, 0 / 0) == 70
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

print("\n== Catch chance ==")
do
	local zone: Lasso.Zone = { centre = 0.5, width = 0.2, speed = 1, startPhase = 0, startMs = 0 }
	local function near(a: number, b: number): boolean
		return math.abs(a - b) < 1e-9
	end
	check(
		"the centre of the green is 0.95",
		near(Lasso.tapChance(zone, 0.5), LassoConfig.CHANCE_CENTRE)
	)
	check(
		"the edge of the green is 0.75",
		near(Lasso.tapChance(zone, 0.6), LassoConfig.CHANCE_EDGE)
	)
	check("halfway out in the green is 0.85", near(Lasso.tapChance(zone, 0.55), 0.85))
	check(
		"just outside the green is about 0.45",
		math.abs(Lasso.tapChance(zone, 0.6 + 1e-6) - LassoConfig.CHANCE_OUTSIDE_NEAR) < 1e-3
	)
	check(
		"a quarter of the arc beyond the edge is the 0.05 floor",
		near(Lasso.tapChance(zone, 0.85), LassoConfig.CHANCE_OUTSIDE_FLOOR)
	)
	check(
		"and it stays at the floor further out",
		near(Lasso.tapChance(zone, 1.0), LassoConfig.CHANCE_OUTSIDE_FLOOR)
	)
	check("a NaN position is 0", Lasso.tapChance(zone, 0 / 0) == 0)
	-- A full-health Common's zone is about 0.015 wide: a tap 50 ms off (0.045 of the arc) must
	-- be at the floor, so weakening a creature first still matters (review, 23 November 2026).
	local healthy: Lasso.Zone =
		{ centre = 0.5, width = 0.015, speed = 1, startPhase = 0, startMs = 0 }
	check(
		"a narrow zone forgives little: 0.045 off a full-health zone is the floor",
		near(Lasso.tapChance(healthy, 0.545), LassoConfig.CHANCE_OUTSIDE_FLOOR)
	)
	check(
		"and just outside a narrow zone still gives a chance",
		Lasso.tapChance(healthy, 0.5076) > 0.4
	)
	local falling = true
	local previous = 2
	for step = 0, 100 do
		local chance = Lasso.tapChance(zone, 0.5 + step / 100 * 0.5)
		falling = falling and chance <= previous + 1e-12
		previous = chance
	end
	check("the chance never rises as the tap moves away from the centre", falling)

	check(
		"an invalid throw has no chance",
		Lasso.catchChance({}, "Common") == 0
			and Lasso.judge(Lasso.createAttempt(input()), { 1 }, { 9999 }).chances[1] == nil
	)
	check(
		"rarity multiplies the zones' chances",
		near(Lasso.catchChance({ 0.9, 0.8 }, "Ruby"), 0.9 * 0.8 * LassoConfig.RARITY_CHANCE.Ruby)
	)
	check(
		"a rarer creature is never easier",
		Lasso.catchChance({ 0.9 }, "Cosmic") < Lasso.catchChance({ 0.9 }, "Gem")
			and Lasso.catchChance({ 0.9 }, "Gem") < Lasso.catchChance({ 0.9 }, "Common")
	)
	check("no chance reaches 1", Lasso.catchChance({ LassoConfig.CHANCE_CENTRE }, "Common") < 1)
end

print("\n== Simulated throws at set offsets ==")
do
	local THROWS = 6000
	local TOLERANCE = 0.025 -- about 4 standard deviations at 6000 throws
	-- Throws at a set distance in milliseconds from the zone's centre crossing, judged the way
	-- the server does, then rolled against the chance with a seeded Rng.
	local function simulate(offsetMs: number, rarity: Types.Rarity): (number, number)
		local rng = Rng.new(5150 + math.floor(offsetMs) + #rarity)
		local caught, expected = 0, 0
		for trial = 1, THROWS do
			local pattern = Lasso.createAttempt(
				input({ seed = trial * 17, rarity = rarity, healthFraction = 0.2 })
			)
			local claims: { number } = {}
			for i, zone in pattern.zones do
				table.insert(
					claims,
					math.max(
						zone.startMs,
						Lasso.nextCentreTimeMs(pattern, i, zone.startMs + 600) + offsetMs
					)
				)
			end
			local judgement = Lasso.judge(pattern, claims, claims)
			local chance = Lasso.catchChance(judgement.chances, rarity)
			expected += chance
			if Rng.next(rng) < chance then
				caught += 1
			end
		end
		return caught / THROWS, expected / THROWS
	end
	local centreRate, centreExpected = simulate(0, "Common")
	local edgeRate, edgeExpected = simulate(150, "Common")
	local outRate, outExpected = simulate(700, "Common")
	local rubyRate, rubyExpected = simulate(0, "Ruby")
	print(
		string.format(
			"  Common: centre %.1f%% (formula %.1f%%), 150 ms off %.1f%% (%.1f%%), 700 ms off %.1f%% (%.1f%%); Ruby centre %.1f%% (%.1f%%)",
			centreRate * 100,
			centreExpected * 100,
			edgeRate * 100,
			edgeExpected * 100,
			outRate * 100,
			outExpected * 100,
			rubyRate * 100,
			rubyExpected * 100
		)
	)
	check(
		"a centred throw lands near the formula",
		math.abs(centreRate - centreExpected) < TOLERANCE
	)
	check(
		"an off-centre throw lands near the formula",
		math.abs(edgeRate - edgeExpected) < TOLERANCE
	)
	check("a far-out throw lands near the formula", math.abs(outRate - outExpected) < TOLERANCE)
	check(
		"a ruby centred throw lands near the formula",
		math.abs(rubyRate - rubyExpected) < TOLERANCE
	)
	check(
		"a centred throw catches more than an off-centre one, and that more than a far-out one",
		centreRate > edgeRate and edgeRate > outRate
	)
	check("no centred throw is guaranteed", centreRate < 1 and centreExpected < 0.96)
	check("a far-out throw is not a guaranteed miss", outRate > 0)
end

print("\n== A tap before its loop sweeps is dropped (bug hunt: capture 1) ==")
do
	check("a tap before the loop starts does not count", not Lasso.sweepStarted(3000, 700))
	check(
		"a tap at or after the start counts",
		Lasso.sweepStarted(3000, 3000) and Lasso.sweepStarted(3000, 3500)
	)
	check("the first loop starts at zero", Lasso.sweepStarted(0, 0))
	check(
		"a bad number is left to the judge (it is Invalid there)",
		Lasso.sweepStarted(3000, 0 / 0)
	)
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("tests failed")
end
