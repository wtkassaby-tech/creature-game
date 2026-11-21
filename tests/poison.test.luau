--!strict
-- Checks for poison, the first status effect (it arrives with the Mire).
-- Run from the project folder:  lune run tests/poison.test

local Battle = require("../src/shared/Battle")
local BattleAi = require("../src/shared/BattleAi")
local BattleConfig = require("../src/config/BattleConfig")
local BreedConfig = require("../src/config/BreedConfig")
local Breeding = require("../src/shared/Breeding")
local Moves = require("../src/content/Moves")
local Rng = require("../src/shared/Rng")
local Species = require("../src/content/Species")
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

-- No launch move poisons, so the tests bring their own: a weak hit that poisons, and a
-- harmless tap for the turns in between.
Moves["Test Venom"] = { element = "Toxic", power = 20, effect = "Poison" }
Moves["Test Tap"] = { element = "Storm", power = 1 }
Moves["Test Blow"] = { element = "Storm", power = 60 }

local function fighter(
	species: string,
	id: string,
	level: number,
	moves: { string }
): Battle.Fighter
	return Battle.fighter(
		Breeding.wild(species, id, level, "Common", "Moss", Rng.new(#id + level)),
		moves
	)
end

local function venom(): Battle.Action
	return { kind = "Move", move = "Test Venom" }
end
local function tap(): Battle.Action
	return { kind = "Move", move = "Test Tap" }
end

local function events(state: Battle.State, kind: Battle.EventKind, side: number?): { Battle.Event }
	local list: { Battle.Event } = {}
	for _, event in state.log do
		if event.kind == kind and (side == nil or event.side == side) then
			table.insert(list, event)
		end
	end
	return list
end

-- Poison arrives with the Mire (biome 4): no part of any species from the three launch biomes
-- (giants' creature forms included) brings a move with an effect, so they play exactly as before.
do
	local found: { string } = {}
	for name, def in Species do
		if def.biome <= 3 then
			for _, slot: Types.Slot in BreedConfig.SLOTS do
				for _, unlock in def.parts[slot].moves do
					if Moves[unlock.name].effect ~= nil then
						table.insert(found, `{name} {slot}: {unlock.name}`)
					end
				end
			end
		end
	end
	check(
		"no move brought by a species of the three launch biomes has an effect",
		#found == 0,
		table.concat(found, "; ")
	)
end

print("\n== A poisoned creature ==")
do
	local a = fighter("Mossmitt", "a", 20, { "Test Venom", "Test Tap" })
	local b = fighter("Spadesnout", "b", 20, { "Test Tap" })
	local state = Battle.new({ a }, { b }, 5, true)
	local full = b.stats.Hp
	local tick = Battle.poisonDamage(b)
	check(
		"one tick is a twelfth of full health",
		tick == math.floor(full * BattleConfig.POISON_SHARE) and tick >= 1,
		`{tick} of {full}`
	)
	Battle.step(state, venom(), tap())
	local poisoned = events(state, "Poisoned")
	check(
		"a move that poisons always poisons: no chance involved",
		#poisoned == 1 and poisoned[1].side == 2 and poisoned[1].slot == 1
	)
	check(
		"it hurts at the end of that same turn",
		#events(state, "Poison", 2) == 1 and b.poison == BattleConfig.POISON_TURNS - 1
	)
	local before = b.hp
	Battle.step(state, venom(), tap())
	check(
		"a poisoned creature cannot be poisoned again, and its poison is not topped up",
		#events(state, "Poisoned") == 1 and b.poison == BattleConfig.POISON_TURNS - 2
	)
	check(
		"each later turn takes the strike and one tick",
		#events(state, "Poison", 2) == 2 and b.hp < before - tick + 1
	)
	Battle.step(state, tap(), tap())
	Battle.step(state, tap(), tap())
	local ticks = events(state, "Poison", 2)
	local taken = 0
	for _, event in ticks do
		taken += event.damage or 0
	end
	check(
		"it lasts four turns and takes a third of full health in all",
		#ticks == BattleConfig.POISON_TURNS and taken == tick * BattleConfig.POISON_TURNS,
		`{#ticks} ticks, {taken} health`
	)
	check(
		"then the creature shakes it off, and says so once",
		(b.poison or 0) == 0 and #events(state, "Cured", 2) == 1
	)
	Battle.step(state, tap(), tap())
	check(
		"after that it is not hurt by poison again",
		#events(state, "Poison", 2) == BattleConfig.POISON_TURNS
	)
	Battle.step(state, venom(), tap())
	check("and it can be poisoned afresh", #events(state, "Poisoned") == 2)
	check("the attacker is never hurt by its own poison", #events(state, "Poison", 1) == 0)
end

print("\n== Who cannot be poisoned ==")
do
	local toxic: string? = nil
	for name, def in Species do
		if def.element == BattleConfig.POISON_IMMUNE_ELEMENT then
			toxic = name
		end
	end
	if toxic then
		local a = fighter("Mossmitt", "a", 20, { "Test Venom" })
		local b = fighter(toxic, "b", 20, { "Test Tap" })
		local state = Battle.new({ a }, { b }, 5, true)
		Battle.step(state, venom(), tap())
		check(
			"a Toxic creature is immune",
			#events(state, "Poisoned") == 0 and (b.poison or 0) == 0
		)
	else
		-- No Toxic species exists before the Mire: check the rule on a stand-in.
		local b = fighter("Spadesnout", "b", 20, { "Test Tap" })
		b.element = "Toxic"
		check("a Toxic creature is immune", not Battle.wouldPoison(b, "Test Venom"))
	end
	local c = fighter("Spadesnout", "c", 20, { "Test Tap" })
	check(
		"an ordinary move poisons nobody",
		not Battle.wouldPoison(c, "Test Tap") and Battle.wouldPoison(c, "Test Venom")
	)
end

print("\n== Switching, fainting and the end of the battle ==")
do
	local a = fighter("Mossmitt", "a", 20, { "Test Venom", "Test Tap" })
	local b1 = fighter("Spadesnout", "b1", 20, { "Test Tap" })
	local b2 = fighter("Sloshcalf", "b2", 20, { "Test Tap" })
	local state = Battle.new({ a }, { b1, b2 }, 5, true)
	Battle.step(state, venom(), tap())
	local left = b1.poison
	local hp = b1.hp
	Battle.step(state, tap(), { kind = "Switch", to = 2 })
	Battle.step(state, tap(), tap())
	check(
		"a poisoned creature on the bench is not hurt and its poison does not run down",
		b1.hp == hp and b1.poison == left
	)
	Battle.step(state, tap(), { kind = "Switch", to = 1 })
	check("back in the battle, the poison carries on", b1.hp < hp and b1.poison == (left or 0) - 1)

	-- Poison can finish a creature off, and the battle ends properly when it does.
	local c = fighter("Mossmitt", "c", 20, { "Test Venom", "Test Tap" })
	local d = fighter("Spadesnout", "d", 20, { "Test Tap" })
	local last = Battle.new({ c }, { d }, 5, true)
	Battle.step(last, venom(), tap())
	d.hp = 1
	Battle.step(last, tap(), { kind = "Pass" })
	check(
		"poison can make a creature faint, and that can win the battle",
		d.hp == 0 and last.winner == 1 and #events(last, "Faint", 2) == 1
	)
	local e = fighter("Mossmitt", "e", 20, { "Test Venom", "Test Blow" })
	local f = fighter("Spadesnout", "f", 20, { "Test Tap" })
	local done = Battle.new({ e }, { f }, 5, true)
	f.hp = 1
	Battle.step(done, venom(), tap())
	check(
		"a creature that the strike itself knocks out is not then poisoned",
		#events(done, "Poisoned") == 0 and #events(done, "Poison") == 0
	)
end

print("\n== Opponents and replays ==")
do
	local a = fighter("Mossmitt", "a", 20, { "Test Venom", "Test Blow" })
	local b = fighter("Spadesnout", "b", 20, { "Test Tap" })
	local state = Battle.new({ a }, { b }, 5, true)
	local blow = Battle.previewDamage(a, b, "Test Blow")
	local venomNow = Battle.previewDamage(a, b, "Test Venom")
	check(
		"a poisoning move is worth its damage plus what the poison will do",
		Battle.moveValue(a, b, "Test Venom")
			== venomNow + Battle.poisonDamage(b) * BattleConfig.POISON_TURNS
	)
	local first = Battle.chooseAction(state, 1)
	Battle.step(state, first, tap())
	local second = Battle.chooseAction(state, 1)
	check(
		"a simple opponent poisons first when that is worth more, then stops wasting turns on it",
		(first.kind == "Move" and first.move == "Test Venom")
				== (venomNow + Battle.poisonDamage(b) * BattleConfig.POISON_TURNS > blow)
			and second.kind == "Move"
			and second.move == "Test Blow",
		`first {if first.kind == "Move" then first.move else "?"}, then {if second.kind
				== "Move"
			then second.move
			else "?"}`
	)
	local c = fighter("Spadesnout", "c", 20, { "Test Tap" })
	c.hp = venomNow + 3
	check(
		"poison is never counted for more than the health the hit leaves",
		Battle.moveValue(a, c, "Test Venom") == venomNow + 3
	)
	check(
		"a move with no effect is worth exactly its damage",
		Battle.moveValue(a, c, "Test Blow") == Battle.previewDamage(a, c, "Test Blow")
	)

	local function play(seed: number): string
		local x = fighter("Mossmitt", "x", 20, { "Test Venom", "Test Blow" })
		local y = fighter("Spadesnout", "y", 20, { "Test Venom", "Test Blow" })
		local battle = Battle.new({ x }, { y }, seed, false)
		local tamer = BattleAi.forTier("Tamer", nil)
		while not battle.winner do
			Battle.step(battle, tamer(battle, 1), tamer(battle, 2))
		end
		local lines: { string } = {}
		for _, event in battle.log do
			table.insert(lines, event.text)
		end
		return table.concat(lines, "|")
	end
	check("the same seed and choices replay the same battle, poison and all", play(77) == play(77))
	check("a battle with poison still ends", #play(3) > 0)
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("poison checks failed")
end
