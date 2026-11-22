--!strict
-- Pacing checks for the first minutes (docs/plans/07_FIRST_15_MINUTES.md, package 13): the first
-- rival battle for each starter, whether a coach line may promise a STRONG move, and how much
-- wider the lasso target gets on a tired creature. Run from the project folder:
--   lune run tests/firstminutes.test

local Battle = require("../src/shared/Battle")
local BattleSession = require("../src/shared/BattleSession")
local Chapter1 = require("../src/content/story_data/Chapter1")
local Lasso = require("../src/shared/Lasso")
local LassoConfig = require("../src/config/LassoConfig")
local Moves = require("../src/content/Moves")
local Profile = require("../src/shared/Profile")
local Species = require("../src/content/Species")
local StoryProgress = require("../src/shared/StoryProgress")
local Tamers = require("../src/content/Tamers")
local TypeChart = require("../src/shared/TypeChart")
local Types = require("../src/shared/Types")
local Trainers = require("../src/shared/Trainers")
local WorldTypes = require("../src/shared/WorldTypes")

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

local STARTERS: { WorldTypes.Starter } = { "Mossmitt", "Spadesnout", "Sloshcalf" }
local SEEDS = 40 -- the plan asks for at least 20 per starter
local MIN_TURNS, MAX_TURNS = 3, 8
local STARTER_LEVEL = 5

-- FINDING (23 Nov 2026): the plan assumes every first battle is 3 to 8 turns. It is not. The rival's
-- Sloshcalf is faster than a level 5 Spadesnout and hits first every turn, so "cannot be lost"
-- keeps standing the player up at 1 health while the player never gets to strike again: the battle
-- drags on to the 60-turn safety stop (the opponent then gives up). The test asserts the truth: a
-- win for every starter, 3 to 8 turns for the starters that meet it, and a loud warning for the
-- ones listed here. Take a starter off this list when its first battle is fixed; the test then
-- holds it to 3 to 8 turns, and fails if a listed starter is in fact fine.
local KNOWN_SLOW: { [string]: boolean } = {} -- none since the rival's first teams were softened

-- A fresh profile that has just picked `starter` and accepted the rival's challenge, built by the
-- same story code the server runs.
local function profileFor(starter: WorldTypes.Starter, seed: number): Profile.Profile
	local nextId = 0
	local function newId(): string
		nextId += 1
		return `first{nextId}`
	end
	local profile = Profile.template()
	for _, beatId in { "starter_choice", "rival_challenge" } do
		local done = StoryProgress.complete(profile, Chapter1, {
			beatId = beatId,
			choice = if beatId == "starter_choice" then starter else nil,
			triggerMet = true,
			newId = newId,
			seed = seed,
			unixTime = 86400 * 300,
		})
		assert(done, `{beatId} finishes`)
	end
	return profile
end

print("\n== (a) The first rival battle, move with the most damage every turn ==")
local lengths: { [string]: { number } } = {}
for _, starter: WorldTypes.Starter in STARTERS do
	local turns: { number } = {}
	local wins, holds = 0, 0
	local inRange, allWon = true, true
	for seed = 1, SEEDS do
		local profile = profileFor(starter, seed)
		local opponent =
			assert(Trainers.resolve("rival_first", profile, Chapter1), "rival resolves")
		local theirs, moves = Trainers.build(opponent)
		local yours: { Types.Creature } = {}
		for _, id in profile.Team do
			table.insert(yours, profile.Creatures[id])
		end
		local session = assert(
			BattleSession.start({
				battleId = seed,
				kind = "Rival",
				yours = yours,
				theirs = theirs,
				theirMoves = moves,
				tier = "Rival",
				seed = seed * 7919,
				levelCap = 15,
				cannotLose = opponent.cannotLose,
			}),
			"the battle starts"
		)
		local previews = BattleSession.started(session).previews
		local finished = false
		for _ = 1, 60 do
			local best, bestDamage = 1, -1
			for index, damage in previews do
				if damage > bestDamage then
					best, bestDamage = index, damage
				end
			end
			local turn = assert(
				BattleSession.act(session, session.state.turn + 1, "Move", best),
				"the turn is played"
			)
			previews = turn.previews
			if turn.finished then
				finished = true
				break
			end
		end
		local ending = BattleSession.ending(session)
		local count = session.state.turn
		table.insert(turns, count)
		if ending == "Won" then
			wins += 1
		end
		for _, event in session.state.log do
			if event.kind == "Endure" then
				holds += 1
				break
			end
		end
		if not finished or ending ~= "Won" then
			allWon = false
		end
		if count < MIN_TURNS or count > MAX_TURNS then
			inRange = false
			if not KNOWN_SLOW[starter] then
				print(`    seed {seed}: {count} turns, ending {tostring(ending)}`)
			end
		end
	end
	local total, shortest, longest = 0, math.huge, 0
	for _, count in turns do
		total += count
		shortest = math.min(shortest, count)
		longest = math.max(longest, count)
	end
	lengths[starter] = turns
	print(
		string.format(
			"  %-11s average %.2f turns (shortest %d, longest %d); won %d of %d; the rule held on in %d",
			starter,
			total / #turns,
			shortest,
			longest,
			wins,
			SEEDS,
			holds
		)
	)
	check(`{starter}: first rival battle is won (or cannot be lost)`, allWon)
	if KNOWN_SLOW[starter] then
		print(
			`  WARNING  {starter}: first rival battle is NOT {MIN_TURNS} to {MAX_TURNS} turns (known)`
		)
		check(`{starter}: still on the known-slow list for a reason`, not inRange)
	else
		check(`{starter}: first rival battle ends in {MIN_TURNS} to {MAX_TURNS} turns`, inRange)
	end
end

print("\n== (b) Does the starter have a STRONG move against the rival's first creature? ==")
print("  starter      rival creature  strong moves at level 5 (multiplier)")
local strongTable: { [string]: boolean } = {}
for _, starter: WorldTypes.Starter in STARTERS do
	local profile = profileFor(starter, 1)
	local mine = profile.Creatures[profile.Team[1]]
	local fighter = Battle.fighter(mine, nil, STARTER_LEVEL)
	local foe = Tamers.rivals.rival_greenwood.first[starter].members[1]
	local foeElement: Types.Element = Species[foe.species].element
	local strong: { string } = {}
	local all: { string } = {}
	for _, name in fighter.moves do
		local multiplier = TypeChart.multiplier(Moves[name].element, foeElement)
		table.insert(all, `{name} {Moves[name].element} x{multiplier}`)
		if multiplier > 1 then
			table.insert(strong, `{name} (x{multiplier})`)
		end
	end
	strongTable[starter] = #strong > 0
	print(
		string.format(
			"  %-12s %-15s %s   [all: %s]",
			starter,
			foe.species,
			if #strong > 0 then table.concat(strong, ", ") else "NONE",
			table.concat(all, "; ")
		)
	)
end
-- Not asserted either way: the coach text must follow this table, not the other way round.
check("every starter's moves were looked at", next(strongTable) ~= nil)

print("\n== (c) The lasso target on a tired creature ==")
local worstRatio, worstName = math.huge, ""
local commons = 0
for name, def in Species do
	if def.biome == 1 and not def.giantForm and def.baseRarity == "Common" then
		commons += 1
		local full = Lasso.zoneWidth("Common", def.lassoDifficulty, 1, "Basic")
		local tired = Lasso.zoneWidth("Common", def.lassoDifficulty, 0.4, "Basic")
		local ratio = tired / full
		if ratio < worstRatio then
			worstRatio, worstName = ratio, name
		end
		print(
			string.format(
				"  %-12s difficulty %.2f  full %.4f  at 40%% %.4f  ratio %.1f",
				name,
				def.lassoDifficulty,
				full,
				tired,
				ratio
			)
		)
	end
end
check("there are Greenwood Common species to check", commons > 0, `{commons}`)
check(
	"a Common's Basic-lasso zone is at least 5 times wider at 40% health than at full health",
	worstRatio >= 5,
	`worst ratio {string.format("%.1f", worstRatio)} ({worstName})`
)
-- And with the plain default difficulty, straight from the config.
local plainFull = Lasso.zoneWidth("Common", 1, 1, "Basic")
local plainTired = Lasso.zoneWidth("Common", 1, 0.4, "Basic")
check(
	"at difficulty 1 the full-health zone is the config's 5% of the base width, unclamped",
	math.abs(plainFull - LassoConfig.BASE_WIDTH.Common * LassoConfig.HEALTH_FACTOR_FULL) < 1e-9
		and plainFull >= LassoConfig.MIN_WIDTH,
	`{plainFull} to {plainTired}`
)

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error(`{failed} test(s) failed`)
end
