--!strict
-- Checks on which painted person a dialogue speaker shares a face with (src/shared/PersonModel).
-- Run from the project folder:  lune run tests/personmodel

local PersonModel = require("../src/shared/PersonModel")

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

-- Keywords in a name fix the model, whatever the coin says.
check("mentor keyword", PersonModel.villager("mentor", 0.9) == "Mentor")
check("rival keyword in a battle block", PersonModel.villager("Rival (rival_one)", 0.1) == "Rival")
check("healer keyword", PersonModel.villager("healer_keeper", 0.1) == "Carer")
check("breeder keyword", PersonModel.villager("breeder_keeper", 0.1) == "Grandmother")
check("tuppence keyword", PersonModel.villager("marlow_tuppence", 0.9) == "Shopkeeper")
check("any other keeper", PersonModel.villager("bell_loft_keeper", 0.9) == "Shopkeeper")
-- Anyone else is one of two tamers by the coin.
check("low coin is Tamer", PersonModel.villager("Wren Ashby", 0.2) == "Tamer")
check("high coin is GirlTamer", PersonModel.villager("Wren Ashby", 0.7) == "GirlTamer")
check("seed is stable", PersonModel.seedFor("ab") == 2 * 131 + 97 + 98)

-- Call names: first and last word, split on spaces and underscores.
local calls = PersonModel.callNames("Hepzibah Marr")
check(
	"full name gives first and last",
	#calls == 2 and calls[1] == "hepzibah" and calls[2] == "marr"
)
calls = PersonModel.callNames("tamsin_rook")
check("id gives first and last", #calls == 2 and calls[1] == "tamsin" and calls[2] == "rook")
check("one word gives one", #PersonModel.callNames("Rival") == 1)
check("empty gives none", #PersonModel.callNames("") == 0)

-- The index keeps unambiguous names and drops shared ones that look different.
local function coin(seed: number): number
	return if seed % 2 == 0 then 0.1 else 0.9
end
local people: { PersonModel.Person } = {
	{ name = "Isolde Karrow", worldName = "Isolde Karrow (champion_isolde)" },
	{ name = "tamsin_rook", worldName = "tamsin_rook" },
	{ name = "Wren Ashby", worldName = "Wren Ashby" },
	{ name = "Wren Tolliver", worldName = "Wren Tolliver" },
}
local index = PersonModel.index(people, coin)
local expectIsolde =
	PersonModel.villager(people[1].worldName, coin(PersonModel.seedFor(people[1].worldName)))
check("first name resolves", index.isolde == expectIsolde)
check("last name resolves", index.karrow == expectIsolde)
check("id keeper resolves", index.tamsin ~= nil and index.rook == index.tamsin)
local a = PersonModel.villager("Wren Ashby", coin(PersonModel.seedFor("Wren Ashby")))
local b = PersonModel.villager("Wren Tolliver", coin(PersonModel.seedFor("Wren Tolliver")))
check(
	"shared first name: none if the looks differ, one if they match",
	if a == b then index.wren == a else index.wren == nil
)
check("unknown speaker has no face", index.lookout == nil)

print(`{passed} passed, {failed} failed`)
if failed > 0 then
	error("personmodel tests failed")
end
