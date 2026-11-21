--!strict
-- Checks for one player's battle as the server runs it.
-- Run from the project folder:  lune run tests/battlesession.test

local BattleSession = require("../src/shared/BattleSession")
local Breeding = require("../src/shared/Breeding")
local Rng = require("../src/shared/Rng")
local Types = require("../src/shared/Types")
local Placeholders = require("./fixtures/Placeholders")

Placeholders.install()

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

local function team(prefix: string, level: number, seed: number): { Types.Creature }
	local rng = Rng.new(seed)
	return {
		Breeding.wild("Brindle", prefix .. "1", level, "Common", "Moss", rng),
		Breeding.wild("Mossback", prefix .. "2", level, "Common", "Moss", rng),
		Breeding.wild("Dartlet", prefix .. "3", level, "Common", "Moss", rng),
	}
end

local function start(kind: BattleSession.Kind, seed: number, cap: number?): BattleSession.Session
	local session = BattleSession.start({
		battleId = 7,
		kind = kind,
		yours = team("me", 12, seed),
		theirs = team("foe", 10, seed + 50),
		theirMoves = nil,
		tier = if kind == "Wild" then "Wild" else "Tamer",
		seed = seed,
		levelCap = cap or 15,
	})
	return assert(session, "battle should start")
end

print("\n== Starting ==")
do
	local session = start("Tamer", 1)
	local started = BattleSession.started(session)
	check("both teams are described", #started.yours == 3 and #started.theirs == 3)
	check(
		"your creatures show their moves and the opponent's do not",
		#started.yours[1].moves > 0 and #started.theirs[1].moves == 0
	)
	check(
		"a damage preview is given for each of your moves",
		#started.previews == #started.yours[1].moves
	)
	local empty = BattleSession.start({
		battleId = 1,
		kind = "Wild",
		yours = {},
		theirs = team("foe", 5, 9),
		theirMoves = nil,
		tier = "Wild",
		seed = 1,
		levelCap = 15,
	})
	check("a battle with no team is refused", empty == nil)
	local capped = BattleSession.started(start("Tamer", 2, 8))
	check("a creature above the player's cap fights at the cap", capped.yours[1].level == 8)
end

print("\n== Choices are checked ==")
do
	local session = start("Tamer", 3)
	check("a choice for the wrong turn is refused", BattleSession.act(session, 5, "Move", 1) == nil)
	check(
		"a move the creature does not know is refused",
		BattleSession.act(session, 1, "Move", 9) == nil
	)
	check(
		"switching to the active creature is refused",
		BattleSession.act(session, 1, "Switch", 1) == nil
	)
	check("a nonsense choice is refused", BattleSession.act(session, 1, "Dance", 1) == nil)
	check("a fractional index is refused", BattleSession.act(session, 1, "Move", 1.5) == nil)
	check("text in place of a number is refused", BattleSession.act(session, "1", "Move", 1) == nil)
	check("running from a tamer is refused", BattleSession.act(session, 1, "Run", 0) == nil)
	check("none of the refused choices advanced the battle", session.state.turn == 0)

	local first = assert(BattleSession.act(session, 1, "Move", 1), "the choice should be accepted")
	check("a legal move plays the turn", first.turn == 1 and #first.events >= 1)
	check("the same turn sent again is refused", BattleSession.act(session, 1, "Move", 1) == nil)
	local switched =
		assert(BattleSession.act(session, 2, "Switch", 2), "the choice should be accepted")
	check("a switch changes the active creature", switched.yourActive == 2)
	local hasSwitch = false
	for _, event in switched.events do
		hasSwitch = hasSwitch or (event.kind == "Switch" and event.side == 1 and event.slot == 2)
	end
	check("the turn's events say so", hasSwitch)
end

print("\n== Playing to the end ==")
do
	local session = start("Tamer", 4)
	local last: BattleSession.TurnResult? = nil
	local eventsTotal = 0
	for turn = 1, 80 do
		local played =
			assert(BattleSession.act(session, turn, "Move", 1), "the choice should be accepted")
		eventsTotal += #played.events
		last = played
		if played.finished then
			break
		end
	end
	local final = assert(last, "at least one turn was played")
	check("the battle finishes", final.finished)
	check("the outcome is a win, a loss or a draw", final.outcome >= 0 and final.outcome <= 2)
	check("every logged event was reported exactly once", eventsTotal == #session.state.log)
	check(
		"a finished battle takes no more choices",
		BattleSession.act(session, final.turn + 1, "Move", 1) == nil
	)

	local replay = start("Tamer", 4)
	local turns = 0
	for turn = 1, 80 do
		local played =
			assert(BattleSession.act(replay, turn, "Move", 1), "the choice should be accepted")
		turns = turn
		if played.finished then
			break
		end
	end
	check(
		"the same seed and choices replay the same battle",
		turns == final.turn and #replay.state.log == #session.state.log
	)
end

print("\n== Running from a wild battle ==")
do
	local session = start("Wild", 5)
	local ran = assert(BattleSession.act(session, 1, "Run", 0), "the choice should be accepted")
	check(
		"running ends the battle at once as a loss with no fighting",
		ran.finished and ran.ran and ran.outcome == 2 and #ran.events == 0
	)
	check("nothing more can be done after running", BattleSession.act(session, 1, "Move", 1) == nil)
end

print("\n== Poison and fainting ==")
do
	local Battle = require("../src/shared/Battle")
	local Moves = require("../src/content/Moves")
	Moves["Test Venom"] = { element = "Toxic", power = 20, effect = "Poison" }
	Moves["Test Tap"] = { element = "Storm", power = 1 }
	local function fighter(species: string, id: string): Battle.Fighter
		return Battle.fighter(
			Breeding.wild(species, id, 20, "Common", "Moss", Rng.new(#id + 3)),
			{ "Test Venom", "Test Tap" }
		)
	end
	local a, b = fighter("Mossmitt", "pa"), fighter("Spadesnout", "pb")
	local spare = fighter("Sloshcalf", "pc")
	local state = Battle.new({ a }, { b, spare }, 9, true)
	Battle.step(state, { kind = "Move", move = "Test Venom" }, { kind = "Move", move = "Test Tap" })
	b.hp = 1
	Battle.step(state, { kind = "Move", move = "Test Tap" }, { kind = "Pass" })
	check(
		"a creature that faints is no longer poisoned, so one brought back starts clean",
		b.hp == 0 and (b.poison or 0) == 0 and state.sides[2].active == 2
	)
end

print("\n== The network message for a turn ==")
do
	-- The message's list of events has a fixed room (src/net/Net.blink). It must hold the
	-- busiest turn the rules allow, or that turn could not be sent at all.
	-- Lune's own file library: asked for through a cast, because the type checker (which
	-- checks this file as Roblox code) does not know it.
	local fs = (require :: any)("@lune/fs")
	local blink: string = fs.readFile("src/net/Net.blink")
	local room = tonumber(string.match(blink, "Events: BattleEvent%[0%.%.(%d+)%]"))
	local BattleConfig = require("../src/config/BattleConfig")
	check(
		"the turn message has room for the configured number of events",
		room ~= nil and room >= BattleConfig.MAX_EVENTS_A_TURN,
		`{room} in the message, {BattleConfig.MAX_EVENTS_A_TURN} in the config`
	)
	-- Two of each thing that can happen to both sides, plus an item and a creature holding on.
	local kinds = { "Switch", "Move", "FollowUp", "Poisoned", "Poison", "Cured", "Faint" }
	local worst = #kinds * 2 + 2
	check(
		"which is more than the busiest possible turn",
		BattleConfig.MAX_EVENTS_A_TURN >= worst,
		`busiest turn {worst}`
	)
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("battle session checks failed")
end
