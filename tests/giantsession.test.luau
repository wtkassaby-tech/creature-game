--!strict
-- Checks for a giant fight as the server runs it, and what a win pays.
-- Run from the project folder:  lune run tests/giantsession.test

local Breeding = require("../src/shared/Breeding")
local Economy = require("../src/shared/Economy")
local EconomyConfig = require("../src/config/EconomyConfig")
local GiantConfig = require("../src/config/GiantConfig")
local GiantSession = require("../src/shared/GiantSession")
local Giants = require("../src/content/Giants")
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

local giant = Giants.greenwood_hollowbough
local DAY = 86400 * 300

local function setup(horns: number): (Profile.Profile, { Types.Creature })
	local profile = Profile.template()
	local rng = Rng.new(8)
	local team: { Types.Creature } = {}
	for index, species in { "Spadesnout", "Sloshcalf", "Mossmitt" } do
		local creature = Breeding.wild(species, `t{index}`, 15, "Common", "Moss", rng)
		profile.Creatures[creature.id] = creature
		table.insert(profile.Team, creature.id)
		table.insert(team, creature)
	end
	profile.Items.GiantCall = horns
	profile.Items.Tonic, profile.Items.Revive = 10, 1
	return profile, team
end

local function begin(profile: Profile.Profile, team: { Types.Creature }): GiantSession.Session?
	return (
		GiantSession.begin(
			profile,
			{ battleId = 1, giant = giant, yours = team, levelCap = 15, seed = 3 }
		)
	)
end

print("\n== Starting ==")
do
	local profile, team = setup(0)
	check("no Giant Horn, no fight", begin(profile, team) == nil)
	profile.Items.GiantCall = 2
	check(
		"no team, no fight, and the horn is kept",
		begin(profile, {}) == nil and profile.Items.GiantCall == 2
	)
	local session = begin(profile, team)
	check("starting uses up one horn", session ~= nil and profile.Items.GiantCall == 1)
	local started = assert(session, "started")
	local view = GiantSession.view(started)
	check(
		"the giant's next move is shown before the first turn",
		view.intent.text ~= "" and view.turn == 0
	)
	check(
		"each move's damage is shown",
		#view.previews == #started.state.team[1].moves and view.previews[1] > 0
	)
	check(
		"the fight starts in the first phase with all five items",
		view.phase == giant.phases[1].name and view.itemsLeft == GiantConfig.MAX_ITEMS
	)
end

print("\n== Choices ==")
do
	local profile, team = setup(1)
	local session = assert(begin(profile, team), "started")
	GiantSession.view(session)
	check("the wrong turn is refused", GiantSession.act(profile, session, 3, "Move", 1, nil) == nil)
	check(
		"a move the creature does not know is refused",
		GiantSession.act(profile, session, 1, "Move", 9, nil) == nil
	)
	check(
		"switching to the creature already out is refused",
		GiantSession.act(profile, session, 1, "Switch", 1, nil) == nil
	)
	check(
		"a tonic on an unhurt creature is refused and kept",
		GiantSession.act(profile, session, 1, "Item", 1, "Tonic") == nil
			and profile.Items.Tonic == 10
	)
	check(
		"a lasso is not an item for this fight",
		GiantSession.act(profile, session, 1, "Item", 1, "Basic") == nil
	)
	check("nothing happened on the refusals", session.state.turn == 0)

	local first = assert(GiantSession.act(profile, session, 1, "Move", 1, nil), "move is played")
	check(
		"a move plays the turn and hurts the giant",
		first.turn == 1 and first.bossHp < first.bossMaxHp
	)
	check("what happened is told once", #first.lines > 0 and #GiantSession.view(session).lines == 0)
	check(
		"the same turn cannot be played twice",
		GiantSession.act(profile, session, 1, "Move", 1, nil) == nil
	)

	local used = 0
	local turn = 2
	while used < GiantConfig.MAX_ITEMS and session.state.winner == nil do
		session.state.team[session.state.active].hp = 5
		local healed =
			GiantSession.act(profile, session, turn, "Item", session.state.active, "Tonic")
		if healed then
			used += 1
			turn += 1
		else
			break
		end
	end
	check(
		"items are used up as they are used",
		profile.Items.Tonic == 10 - used and used == GiantConfig.MAX_ITEMS,
		`{used} used`
	)
	if session.state.winner == nil then
		session.state.team[session.state.active].hp = 5
		check(
			"only five items a fight",
			GiantSession.act(profile, session, turn, "Item", session.state.active, "Tonic") == nil
				and profile.Items.Tonic == 10 - used
		)
	end
end

print("\n== Winning and what it pays ==")
do
	local profile, team = setup(1)
	local session = assert(begin(profile, team), "started")
	session.state.boss.hp = 1
	local last = assert(GiantSession.act(profile, session, 1, "Move", 1, nil), "move is played")
	check("beating the giant ends the fight as a win", last.finished and last.won)
	check(
		"nothing more can be played",
		GiantSession.act(profile, session, 2, "Move", 1, nil) == nil
	)

	local members = {}
	for _, id in profile.Team do
		table.insert(members, { id = id, fainted = false })
	end
	local function pay(day: number): Rewards.GiantPaid
		return Rewards.giantWin(
			profile,
			giant,
			session.state.boss.creature,
			{ biome = 1, team = members, cap = 15, unixTime = day }
		)
	end
	local prism = profile.Candy.prism
	local first = pay(DAY)
	check(
		"the first win pays the first-clear coins",
		first.firstClear and first.coins == Economy.battleCoins("Giant", 1, giant.level, 0, true)
	)
	check(
		"and the first-clear Prism Candy, once",
		first.prism == EconomyConfig.CANDY.GiantFirstClear.perClaim
			and profile.Candy.prism == prism + first.prism
	)
	check("the whole team earns XP", #first.members == 3 and first.members[1].gained > 0)
	local rematchCoins, rematchPrism, paidTimes = 0, 0, 0
	for _ = 1, 4 do
		local again = pay(DAY)
		if again.coins > 0 then
			paidTimes += 1
			rematchCoins = again.coins
		end
		rematchPrism += again.prism
	end
	check(
		"rematches pay less, a set number of times a day",
		paidTimes == EconomyConfig.TRAINED.Giant.rematchesPaidPerDay and rematchCoins < first.coins
	)
	check(
		"rematch Prism Candy is capped for the day",
		rematchPrism
			== EconomyConfig.CANDY.GiantRematch.perClaim * EconomyConfig.CANDY.GiantRematch.cap
	)
	check(
		"a rematch pays less than its horn costs",
		rematchCoins < Economy.itemPrice("GiantCall", 1)
	)
	local nextDay = pay(DAY + 86400)
	check(
		"the next day's rematch pays again, never the first-clear amounts",
		nextDay.coins == rematchCoins and nextDay.prism == EconomyConfig.CANDY.GiantRematch.perClaim
	)
	check(
		"the record is sound",
		#Profile.validate(profile) == 0,
		table.concat(Profile.validate(profile), "; ")
	)
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("giant session checks failed")
end
