--!strict
-- Checks for battle rewards: coins with the daily falloff, material drops, shared XP.
-- Run from the project folder:  lune run tests/rewards.test

local Breeding = require("../src/shared/Breeding")
local Economy = require("../src/shared/Economy")
local EconomyConfig = require("../src/config/EconomyConfig")
local Profile = require("../src/shared/Profile")
local Rewards = require("../src/shared/Rewards")
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

local DAY = 86400 * 300

local function setup(): (Profile.Profile, { { id: string, fainted: boolean } })
	local profile = Profile.template()
	local a = Breeding.wild("Mossmitt", "a", 5, "Common", "Moss", Rng.new(1))
	local b = Breeding.wild("Burlhorn", "b", 5, "Common", "Moss", Rng.new(2))
	profile.Creatures.a, profile.Creatures.b = a, b
	profile.Team = { "a", "b" }
	return profile, { { id = "a", fainted = false }, { id = "b", fainted = true } }
end

local function foe(level: number, species: string?): Types.Creature
	return Breeding.wild(species or "Spadesnout", "wild", level, "Common", "Sand", Rng.new(level))
end

print("\n== Coins ==")
do
	local profile, team = setup()
	local start = profile.Coins
	local paid =
		Rewards.wildWin(profile, { foe = foe(4), team = team, cap = 15, unixTime = DAY, seed = 1 })
	check(
		"a wild win pays the economy's full first-win coins",
		paid.coins == Economy.battleCoins("Wild", 1, 4, 0, false) and paid.coins > 0
	)
	check("the coins are in the profile", profile.Coins == start + paid.coins)
	local last = paid.coins
	local falling = true
	for _ = 1, EconomyConfig.DIMINISH_STOP + 2 do
		local next = Rewards.wildWin(
			profile,
			{ foe = foe(4), team = team, cap = 15, unixTime = DAY, seed = 2 }
		)
		falling = falling and next.coins <= last
		last = next.coins
	end
	check("wins against the same kind fall off through the day, to nothing", falling and last == 0)
	local other = Rewards.wildWin(
		profile,
		{ foe = foe(4, "Mossmitt"), team = team, cap = 15, unixTime = DAY, seed = 3 }
	)
	check("another kind still pays in full", other.coins == paid.coins)
	local tomorrow = Rewards.wildWin(
		profile,
		{ foe = foe(4), team = team, cap = 15, unixTime = DAY + 86400, seed = 4 }
	)
	check("the next day by the server's clock pays in full again", tomorrow.coins == paid.coins)
end

print("\n== Materials ==")
do
	local profile, team = setup()
	local drops = 0
	for seed = 1, 400 do
		profile.Daily.wildWins = {} -- keep every win at full value for this count
		if
			Rewards.wildWin(
				profile,
				{ foe = foe(4), team = team, cap = 15, unixTime = DAY, seed = seed }
			).material
		then
			drops += 1
		end
	end
	local share = drops / 400
	check(
		"the biome material drops at about its configured chance",
		math.abs(share - EconomyConfig.MATERIAL_DROP_CHANCE) < 0.08,
		`{share}`
	)
	check("drops are in the inventory", (profile.Items.Fernfluff or 0) == drops)
	local first = Rewards.wildWin(
		setup(),
		{ foe = foe(4), team = team, cap = 15, unixTime = DAY, seed = 77 }
	).material
	local again = Rewards.wildWin(
		setup(),
		{ foe = foe(4), team = team, cap = 15, unixTime = DAY, seed = 77 }
	).material
	check("the same seed gives the same drop", first == again)
end

print("\n== XP ==")
do
	local profile, team = setup()
	local paid =
		Rewards.wildWin(profile, { foe = foe(8), team = team, cap = 15, unixTime = DAY, seed = 1 })
	local a, b = paid.members[1], paid.members[2]
	check("every team member gets a share", #paid.members == 2 and a.gained > 0 and b.gained > 0)
	check("a fainted member gets less", b.gained < a.gained, `{a.gained} vs {b.gained}`)
	check(
		"XP is saved on the creature",
		profile.Creatures.a.level > 5 or profile.Creatures.a.xp > 0
	)

	local capped, capTeam = setup()
	for seed = 1, 60 do
		Rewards.wildWin(
			capped,
			{ foe = foe(12), team = capTeam, cap = 6, unixTime = DAY, seed = seed }
		)
	end
	check("the level cap holds the level", capped.Creatures.a.level == 6)
	check("XP keeps building at the cap", capped.Creatures.a.xp > 0)

	local missing, missingTeam = setup()
	local owned: { [string]: Types.Creature? } = missing.Creatures
	owned.b = nil
	local partial = Rewards.wildWin(
		missing,
		{ foe = foe(4), team = missingTeam, cap = 15, unixTime = DAY, seed = 1 }
	)
	check(
		"a creature no longer owned is skipped, not recreated",
		#partial.members == 1 and missing.Creatures.b == nil
	)
	check(
		"the record is still sound",
		#Profile.validate(profile) == 0,
		table.concat(Profile.validate(profile), "; ")
	)
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("rewards checks failed")
end
