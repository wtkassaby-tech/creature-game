--!strict
-- Checks for a lasso throw in a wild battle, as the server runs it (approval pack 2).
-- Run from the project folder:  lune run tests/capture.test

local BattleSession = require("../src/shared/BattleSession")
local Breeding = require("../src/shared/Breeding")
local Capture = require("../src/shared/Capture")
local Lasso = require("../src/shared/Lasso")
local Profile = require("../src/shared/Profile")
local Rng = require("../src/shared/Rng")
local Types = require("../src/shared/Types")

local passed, failed = 0, 0
local function check(name: string, condition: boolean, detail: string?)
	if condition then
		passed += 1
	else
		failed += 1
	end
	print(
		`  {if condition then "PASS" else "FAIL"}  {name}{if detail
			then "  (" .. detail .. ")"
			else ""}`
	)
end

local function setup(seed: number, rarity: Types.Rarity?): (Profile.Profile, BattleSession.Session)
	local profile = Profile.template()
	local rng = Rng.new(seed)
	local mine = Breeding.wild("Mossmitt", "mine", 12, "Common", "Moss", rng)
	profile.Creatures[mine.id] = mine
	profile.Team = { mine.id }
	profile.Items.Basic = 5
	profile.Items.Braided = 2
	local wild = Breeding.wild("Spadesnout", "wild", 4, rarity or "Common", "Sand", rng)
	local session = assert(
		BattleSession.start({
			battleId = seed,
			kind = "Wild",
			yours = { mine },
			theirs = { wild },
			theirMoves = nil,
			tier = "Wild",
			seed = seed,
			levelCap = 15,
		}),
		"battle should start"
	)
	return profile, session
end

local function input(
	profile: Profile.Profile,
	session: BattleSession.Session,
	tier: string?
): Capture.BeginInput
	return {
		profile = profile,
		session = session,
		turn = session.state.turn + 1,
		tier = tier or "Basic",
		seed = 99,
		roundTripMs = 80,
		nowMs = 0,
		misses = 0,
	}
end

-- A tap at the centre of every zone, as a perfect player would send it.
local function perfectTaps(throw: Capture.Throw): { number }
	local taps = {}
	for index, zone in throw.pattern.zones do
		table.insert(taps, Lasso.nextCentreTimeMs(throw.pattern, index, zone.startMs))
	end
	return taps
end

-- Dice with a known first roll: the first seed whose roll is below 0.01, or at least 0.99.
local function lowDice(): Rng.Rng
	for seed = 1, 10000 do
		if Rng.next(Rng.new(seed)) < 0.01 then
			return Rng.new(seed)
		end
	end
	error("no low seed")
end
local function highDice(): Rng.Rng
	for seed = 1, 10000 do
		if Rng.next(Rng.new(seed)) >= 0.99 then
			return Rng.new(seed)
		end
	end
	error("no high seed")
end

print("\n== Before the throw ==")
do
	local profile, session = setup(1)
	check("a nonsense lasso is refused", Capture.begin(input(profile, session, "Rope")) == nil)
	local stale = input(profile, session)
	stale.turn = 9
	check("a throw for the wrong turn is refused", Capture.begin(stale) == nil)
	profile.Items.Basic = 0
	check(
		"a lasso the player does not have is refused",
		Capture.begin(input(profile, session)) == nil
	)
	profile.Items.Basic = 5
	profile.StableCapacity = 1
	local _, why = Capture.begin(input(profile, session))
	check(
		"a full stable is refused before any lasso is spent",
		why ~= nil and profile.Items.Basic == 5,
		why
	)
	profile.StableCapacity = 30

	local gemProfile, gemSession = setup(2, "Gem")
	check(
		"a gem-tier creature refuses a Basic lasso",
		Capture.begin(input(gemProfile, gemSession, "Basic")) == nil
	)
	check("and takes a Braided one", Capture.begin(input(gemProfile, gemSession, "Braided")) ~= nil)

	local throw = assert(Capture.begin(input(profile, session)), "throw should start")
	check("starting a throw spends the lasso at once", profile.Items.Basic == 4)
	check("the sweep carries the server's round-trip reading", throw.pattern.roundTripMs == 80)
end

print("\n== Hits ==")
do
	local profile, session = setup(3)
	local throw = assert(Capture.begin(input(profile, session)), "throw should start")
	local taps = perfectTaps(throw)
	local result = assert(
		Capture.finish(profile, session, throw, taps, taps, 0, lowDice()),
		"throw should be judged"
	)
	check("a perfect throw with a kind roll catches the creature", result.outcome == "Caught")
	check(
		"the result carries the chance and the roll",
		result.chance > 0.9 and result.chance < 1 and result.roll ~= nil and result.roll < 0.01
	)
	check("the creature is in the stable", profile.Creatures.wild ~= nil)
	check(
		"typed candy of its type is paid",
		result.element == "Sand" and profile.Candy.typed.Sand == result.candy
	)
	check("the battle ends", result.turn.finished and result.turn.outcome == 1)
	check(
		"the same throw cannot be judged twice",
		Capture.finish(profile, session, throw, taps, taps, 0, lowDice()) == nil
	)
	check(
		"the record is still sound",
		#Profile.validate(profile) == 0,
		table.concat(Profile.validate(profile), "; ")
	)

	-- Not guaranteed: a perfect throw can still miss on a bad roll.
	local unlucky, unluckySession = setup(13)
	local again = assert(Capture.begin(input(unlucky, unluckySession)), "throw should start")
	local perfect = perfectTaps(again)
	local slipped = assert(
		Capture.finish(unlucky, unluckySession, again, perfect, perfect, 1, highDice()),
		"throw should be judged"
	)
	check(
		"a perfect throw can still slip away on a bad roll",
		slipped.outcome == "Missed" and unlucky.Creatures.wild == nil and slipped.chance < 1
	)

	-- Not a guaranteed miss: a tap outside the green can still catch on a lucky roll.
	local lucky, luckySession = setup(14)
	local wide = assert(Capture.begin(input(lucky, luckySession)), "throw should start")
	local off = { wide.pattern.zones[1].startMs + 1 }
	local landed = assert(
		Capture.finish(lucky, luckySession, wide, off, off, 1, lowDice()),
		"throw should be judged"
	)
	check(
		"a tap outside the green can still catch on a lucky roll",
		landed.outcome == "Caught" and landed.judgement.verdict == "Miss"
	)
end

print("\n== Misses and impossible taps ==")
do
	local profile, session = setup(4)
	local throw = assert(Capture.begin(input(profile, session)), "throw should start")
	local late = { throw.pattern.zones[1].startMs + 13999 }
	local missed = assert(
		Capture.finish(profile, session, throw, late, late, 1, highDice()),
		"throw should be judged"
	)
	check(
		"a miss does not catch, and the battle goes on",
		missed.outcome == "Missed" and profile.Creatures.wild == nil and not missed.turn.finished
	)
	check("the wild creature takes its turn", #missed.turn.events >= 1)

	local again = assert(Capture.begin(input(profile, session)), "throw should start")
	local perfect = perfectTaps(again)
	local impossible = assert(
		Capture.finish(profile, session, again, perfect, { perfect[1] + 5000 }, 2, lowDice()),
		"throw should be judged"
	)
	check(
		"a perfect tap the server's clock says was impossible counts as a miss",
		impossible.judgement.verdict == "Invalid"
			and impossible.outcome == "Missed"
			and profile.Creatures.wild == nil
	)
	check("the lasso stays spent", profile.Items.Basic == 3)
	local junk = assert(Capture.begin(input(profile, session)), "throw should start")
	local bad = assert(
		Capture.finish(profile, session, junk, "lots", { 10 }, 3, lowDice()),
		"throw should be judged"
	)
	check("taps that are not numbers count as a miss", bad.outcome == "Missed")
end

print("\n== Rare creatures flee ==")
do
	local profile, session = setup(5, "Gem")
	local limit = assert(Lasso.missesBeforeFlee("Gem"), "gem creatures flee")
	local last: Capture.Result? = nil
	for miss = 1, limit do
		local throw = assert(
			Capture.begin({
				profile = profile,
				session = session,
				turn = session.state.turn + 1,
				tier = "Braided",
				seed = miss,
				roundTripMs = 80,
				nowMs = 0,
				misses = miss - 1,
			}),
			"throw should start"
		)
		profile.Items.Braided = 5
		last = Capture.finish(profile, session, throw, { 1 }, { 1 }, miss, highDice())
		if session.state.winner ~= nil then
			break
		end
	end
	local final = assert(last, "throws were made")
	check(
		"after its last allowed miss a gem-tier creature flees",
		final.outcome == "Fled" and final.turn.finished,
		`fled after {limit} misses`
	)
	check("no more throws once it has fled", Capture.begin({
		profile = profile,
		session = session,
		turn = session.state.turn + 1,
		tier = "Braided",
		seed = 50,
		roundTripMs = 80,
		nowMs = 0,
		misses = limit,
	}) == nil)
end

print("\n== Catching a gem-tier creature ==")
do
	local profile, session = setup(8, "Gem")
	local throw = assert(Capture.begin(input(profile, session, "Braided")), "throw should start")
	local taps = perfectTaps(throw)
	local result = assert(
		Capture.finish(profile, session, throw, taps, taps, 0, lowDice()),
		"throw should be judged"
	)
	check(
		"a hit catches it and ends the battle",
		result.outcome == "Caught" and result.turn.finished
	)
	check(
		"it waits for its serial number before joining the stable",
		profile.Creatures.wild == nil
			and #profile.Pending == 1
			and profile.Pending[1].source == "Gem"
	)
end

print("\n== A run during the throw ==")
do
	local profile, session = setup(6)
	local throw = assert(Capture.begin(input(profile, session)), "throw should start")
	session.ran = true -- as if a Run had slipped in before the taps were judged
	local taps = perfectTaps(throw)
	local result = Capture.finish(profile, session, throw, taps, taps, 0, lowDice())
	check(
		"a throw judged after the battle ended catches nothing",
		result == nil and profile.Creatures.wild == nil
	)
	check("and the lasso stays spent", profile.Items.Basic == 4)
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("capture checks failed")
end
