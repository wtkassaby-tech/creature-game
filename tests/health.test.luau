--!strict
-- Checks for damage that lasts between battles, healing, and tonics outside a battle.
-- Run from the project folder:  lune run tests/health.test

local BattleSession = require("../src/shared/BattleSession")
local Breeding = require("../src/shared/Breeding")
local Giants = require("../src/content/Giants")
local GiantSession = require("../src/shared/GiantSession")
local Health = require("../src/shared/Health")
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

local function free(_id: string): boolean
	return false
end

local function setup(): (Profile.Profile, Types.Creature, Types.Creature)
	local profile = Profile.template()
	local rng = Rng.new(4)
	local a = Breeding.wild("Mossmitt", "a", 10, "Common", "Moss", rng)
	local b = Breeding.wild("Gorsling", "b", 10, "Common", "Moss", rng)
	profile.Creatures.a, profile.Creatures.b = a, b
	profile.Team = { "a", "b" }
	profile.Items.Tonic, profile.Items.GreatTonic, profile.Items.Revive = 3, 1, 1
	return profile, a, b
end

local function battle(
	yours: { Types.Creature },
	wild: Types.Creature,
	kind: BattleSession.Kind?
): (BattleSession.Session?, string?)
	return BattleSession.start({
		battleId = 1,
		kind = kind or "Wild",
		yours = yours,
		theirs = { wild },
		theirMoves = nil,
		tier = "Wild",
		seed = 7,
		levelCap = 15,
	})
end

print("\n== Damage lasts ==")
do
	local _, a, b = setup()
	local wild = Breeding.wild("Spadesnout", "wild", 9, "Common", "Sand", Rng.new(9))
	local session = assert(battle({ a, b }, wild), "battle starts")
	assert(BattleSession.act(session, 1, "Move", 1), "a turn is played")
	local mine = session.state.sides[1].team[1]
	check(
		"a hit taken is written to the creature's record at once",
		mine.hp < mine.stats.Hp and a.hurt ~= nil and a.hurt > 0
	)
	check("the wild creature's damage is kept too", wild.hurt ~= nil and wild.hurt > 0)
	local hpAfter = mine.hp
	local again = assert(battle({ a, b }, wild), "a second battle starts")
	check(
		"the next battle starts with the same health",
		again.state.sides[1].team[1].hp == hpAfter,
		`{again.state.sides[1].team[1].hp} vs {hpAfter}`
	)
	check(
		"and the wild creature is still hurt",
		again.state.sides[2].team[1].hp < again.state.sides[2].team[1].stats.Hp
	)

	a.hurt = 1
	local third = assert(battle({ a, b }, wild), "battle starts")
	check(
		"a fainted creature does not lead: the next standing one does",
		third.state.sides[1].active == 2
	)
	b.hurt = 1
	local none, why = battle({ a, b }, wild)
	check("a team with nobody standing cannot start a battle", none == nil, why)

	local fresh = Breeding.wild("Mossmitt", "f", 10, "Common", "Moss", Rng.new(5))
	fresh.hurt = 0.5
	local friendly = assert(
		battle(
			{ fresh },
			Breeding.wild("Gorsling", "g", 10, "Common", "Moss", Rng.new(6)),
			"Friendly"
		),
		"starts"
	)
	local fighter = friendly.state.sides[1].team[1]
	check("a friendly battle starts everyone at full health", fighter.hp == fighter.stats.Hp)
	assert(BattleSession.act(friendly, 1, "Move", 1), "a turn is played")
	check("and leaves no lasting damage", fresh.hurt == 0.5)
	check(
		"a creature with a sliver of health starts with at least 1",
		(function()
			local sliver = Breeding.wild("Mossmitt", "s", 10, "Common", "Moss", Rng.new(8))
			sliver.hurt = 0.9999
			local started = assert(
				battle({ sliver }, Breeding.wild("Gorsling", "h", 3, "Common", "Moss", Rng.new(2))),
				"starts"
			)
			return started.state.sides[1].team[1].hp == 1
		end)()
	)
end

print("\n== Giant fights ==")
do
	local profile, a, b = setup()
	profile.Items.GiantCall = 2
	a.hurt, b.hurt = 1, 1
	local refused = GiantSession.begin(profile, {
		battleId = 1,
		giant = Giants.greenwood_hollowbough,
		biome = 1,
		yours = { a, b },
		levelCap = 15,
		seed = 2,
	})
	check(
		"a fainted team cannot wake the giant, and the horn is kept",
		refused == nil and profile.Items.GiantCall == 2
	)
	b.hurt = 0.25
	local session = assert(
		GiantSession.begin(profile, {
			battleId = 1,
			giant = Giants.greenwood_hollowbough,
			biome = 1,
			yours = { a, b },
			levelCap = 15,
			seed = 2,
		}),
		"starts"
	)
	check(
		"the first standing creature leads, at its carried health",
		session.state.active == 2 and session.state.team[2].hp < session.state.team[2].stats.Hp
	)
	GiantSession.act(profile, session, 1, "Move", 1, nil)
	check("damage from the giant lasts", b.hurt ~= nil and b.hurt > 0.25)
end

print("\n== The healer and tonics outside a battle ==")
do
	local profile, a, b = setup()
	check(
		"a tonic on an unhurt creature is refused and kept",
		Health.useItem(profile, "Tonic", "a", free) == nil and profile.Items.Tonic == 3
	)
	a.hurt = 0.7
	check(
		"a creature in a battle cannot be treated from outside",
		Health.useItem(profile, "Tonic", "a", function()
			return true
		end) == nil
	)
	check(
		"a creature the player does not own is refused",
		Health.useItem(profile, "Tonic", "zzz", free) == nil
			and Health.useItem(profile, "Tonic", 4, free) == nil
	)
	check("a lasso is not medicine", Health.useItem(profile, "Basic", "a", free) == nil)
	local after = Health.useItem(profile, "Tonic", "a", free)
	check(
		"a Field Tonic gives back 40% of full health",
		after ~= nil and math.abs(after - 0.7) < 1e-9 and profile.Items.Tonic == 2
	)
	Health.useItem(profile, "GreatTonic", "a", free)
	check("a Deep Tonic heals fully", a.hurt == nil and profile.Items.GreatTonic == 0)
	check(
		"with none left it is refused",
		(function()
			a.hurt = 0.5
			return Health.useItem(profile, "GreatTonic", "a", free) == nil
		end)()
	)
	b.hurt = 1
	check(
		"a tonic cannot wake a fainted creature",
		Health.useItem(profile, "Tonic", "b", free) == nil
	)
	check(
		"a Rally Root is refused on a standing creature",
		Health.useItem(profile, "Revive", "a", free) == nil
	)
	local revived = Health.useItem(profile, "Revive", "b", free)
	check(
		"a Rally Root brings a fainted one back at half health",
		revived == 0.5 and b.hurt == 0.5 and profile.Items.Revive == 0
	)
	check(
		"the healer mends everyone",
		Health.healAll(profile) == 2 and a.hurt == nil and b.hurt == nil
	)
	check("standing and fainted are told apart", Health.anyStanding({ a, b }) and (function()
		a.hurt, b.hurt = 1, 1
		return not Health.anyStanding({ a, b })
	end)())
	check(
		"the record is sound with hurt creatures",
		#Profile.validate(profile) == 0,
		table.concat(Profile.validate(profile), "; ")
	)
	a.hurt = 3
	check("a health value out of range is reported", #Profile.validate(profile) > 0)
end

print("\n== Waking at the healer ==")
do
	local profile, a, b = setup()
	local resting = Breeding.wild("Mossmitt", "r", 5, "Common", "Moss", Rng.new(12))
	profile.Creatures.r = resting
	a.hurt, b.hurt, resting.hurt = 1, 1, 0.6
	check(
		"only the team that fought is mended",
		Health.healTeam(profile) == 2 and a.hurt == nil and b.hurt == nil
	)
	check("a creature left in the stable stays hurt", resting.hurt == 0.6)
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("health checks failed")
end
