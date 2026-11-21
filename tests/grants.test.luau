--!strict
-- Checks for every way a creature enters or leaves a player's record (approval pack 2).
-- Run from the project folder:  lune run tests/grants.test

local Breeding = require("../src/shared/Breeding")
local Economy = require("../src/shared/Economy")
local Grants = require("../src/shared/Grants")
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

local nextId = 0
local function creature(species: string?, rarity: Types.Rarity?): Types.Creature
	nextId += 1
	return Breeding.wild(
		species or "Mossmitt",
		`c{nextId}`,
		5,
		rarity or "Common",
		"Moss",
		Rng.new(nextId)
	)
end

local function fresh(capacity: number?): Profile.Profile
	local p = Profile.template()
	p.StableCapacity = capacity or 30
	return p
end

print("\n== One-time gifts ==")
do
	local p = fresh()
	local made = 0
	local function make(): Types.Creature
		made += 1
		return creature()
	end
	check(
		"the starter is granted",
		Grants.giveOnce(p, "Starter", "starter", make).outcome == "Granted"
	)
	check(
		"a second starter request is refused and makes nothing",
		Grants.giveOnce(p, "Starter", "starter", make).outcome == "AlreadyGranted" and made == 1
	)
	check(
		"a different quest reward is its own gift",
		Grants.giveOnce(p, "Quest", "q1", make).outcome == "Granted"
	)
	check(
		"giants cannot use the one-time path",
		Grants.giveOnce(p, "Giant", "g", make).outcome == "Refused"
	)
	check(
		"wild creatures cannot use the one-time path",
		Grants.giveOnce(p, "Wild", "w", make).outcome == "Refused"
	)

	local full = fresh(1)
	full.Creatures.x = creature()
	full.Creatures.x.id = "x"
	local waiting = Grants.giveOnce(full, "Token", "greenwood", make)
	check(
		"with a full stable a gift waits, and is not made yet",
		waiting.outcome == "Waiting" and made == 2 and #full.Pending == 1
	)
	check(
		"a waiting gift still cannot be earned twice",
		Grants.giveOnce(full, "Token", "greenwood", make).outcome == "AlreadyGranted"
			and #full.Pending == 1
	)
	check("claiming with no room hands nothing over", Grants.claimPending(full, function()
		return creature()
	end) == 0)
	full.StableCapacity = 3
	local handed = Grants.claimPending(full, function(source, ref)
		return if source == "Token" and ref == "greenwood" then creature() else nil
	end)
	check("once there is room the waiting gift is handed over", handed == 1 and #full.Pending == 0)
	local unknown = fresh()
	table.insert(unknown.Pending, { source = "Quest", ref = "removed-quest" })
	Grants.claimPending(unknown, function()
		return nil
	end)
	check("a gift whose content no longer exists is kept, not dropped", #unknown.Pending == 1)
end

print("\n== Wild captures pay typed candy ==")
do
	local p = fresh(100)
	local first = Grants.capture(p, creature("Spadesnout"))
	check(
		"a capture is granted with candy of the creature's type",
		first.outcome == "Granted" and first.element == "Sand" and (first.candy or 0) > 0
	)
	check(
		"the candy lands in that type's balance",
		p.Candy.typed.Sand == first.candy and p.Candy.typed.Leaf == 0
	)
	check("the daily count for that type goes up", p.Daily.catches.Sand == 1)
	local total = first.candy or 0
	for _ = 1, 60 do
		total += Grants.capture(p, creature("Spadesnout")).candy or 0
	end
	local expected = 0
	for prior = 0, 60 do
		expected += Economy.catchCandy("Common", prior)
	end
	check(
		"repeated catches of one type fall off as the economy sets",
		total == expected,
		`{total} candies from 61 catches`
	)
	local again = p.Creatures[next(p.Creatures) :: string]
	check(
		"the same creature cannot be captured twice",
		Grants.capture(p, again).outcome == "Refused"
	)
	local full = fresh(0)
	check("a full stable refuses a capture", Grants.capture(full, creature()).outcome == "NoRoom")
	check("the capture marks the species seen and owned", p.Index.owned.Spadesnout == true)
end

print("\n== A new day ==")
do
	local p = fresh()
	Grants.rollDay(p, 86400 * 100 + 5)
	Grants.capture(p, creature("Spadesnout"))
	Grants.rollDay(p, 86400 * 100 + 80000)
	check("the same day keeps the counts", p.Daily.catches.Sand == 1)
	Grants.rollDay(p, 86400 * 101 + 1)
	check("the next day resets them", p.Daily.catches.Sand == 0 and p.Daily.day == 101)
end

print("\n== Giants ==")
do
	local p = fresh()
	local giant = creature("Burlhorn")
	giant.isGiant, giant.bound, giant.serial = true, true, 7
	check(
		"finishing a giant that never started is refused",
		Grants.finishGiant(p, "hollowbough", giant).outcome == "Refused"
	)
	check(
		"step 1 puts the capture in the waiting list",
		Grants.startGiant(p, "hollowbough").outcome == "Waiting" and #p.Pending == 1
	)
	check(
		"a second step 1 for the same giant is refused",
		Grants.startGiant(p, "hollowbough").outcome == "Refused" and #p.Pending == 1
	)
	local loose = creature("Burlhorn")
	loose.isGiant = true
	check(
		"a giant without a serial or not bound is refused",
		Grants.finishGiant(p, "hollowbough", loose).outcome == "Refused"
	)
	check("waiting giants are not handed over as gifts", Grants.claimPending(p, function()
		return creature()
	end) == 0 and #p.Pending == 1)
	local done = Grants.finishGiant(p, "hollowbough", giant)
	check(
		"step 3 adds the giant, marks it captured and clears the wait",
		done.outcome == "Granted" and p.Story.giantsCaptured.hollowbough == true and #p.Pending == 0
	)
	check(
		"a captured giant can never start again",
		Grants.startGiant(p, "hollowbough").outcome == "AlreadyGranted"
	)
	check(
		"the record is still sound",
		#Profile.validate(p) == 0,
		table.concat(Profile.validate(p), "; ")
	)
end

print("\n== Releasing ==")
do
	local p = fresh()
	local a, b = creature("Spadesnout"), creature("Mossmitt")
	p.Creatures[a.id], p.Creatures[b.id] = a, b
	p.Team = { a.id }
	check(
		"the last creature on the team cannot be released",
		Grants.release(p, a.id, false).outcome == "Refused"
	)
	check(
		"a locked creature cannot be released",
		Grants.release(p, b.id, true).outcome == "Refused"
	)
	check(
		"a creature you do not own cannot be released",
		Grants.release(p, "nobody", false).outcome == "Refused"
	)
	local coinsBefore = p.Coins
	local released = Grants.release(p, b.id, false)
	check(
		"a release removes the creature and pays coins and typed candy",
		released.outcome == "Granted"
			and p.Creatures[b.id] == nil
			and p.Coins > coinsBefore
			and p.Candy.typed.Leaf == released.candy
	)
	check(
		"releasing pays less than catching one costs",
		p.Coins - coinsBefore < Economy.minCatchCost("Common")
	)
	p.Creatures[b.id] = b
	p.Team = { a.id, b.id }
	Grants.release(p, a.id, false)
	check("releasing a team member takes it off the team", #p.Team == 1 and p.Team[1] == b.id)
	check(
		"the record is still sound",
		#Profile.validate(p) == 0,
		table.concat(Profile.validate(p), "; ")
	)
end

print("\n== Review fixes ==")
do
	local p = fresh(100)
	Grants.rollDay(p, 86400 * 200 + 10)
	p.Daily.catches.Leaf = 9
	Grants.rollDay(p, 86400 * 199 + 86000) -- another server whose clock is still on yesterday
	check("a day never resets backwards", p.Daily.catches.Leaf == 9 and p.Daily.day == 200)

	local wild = creature()
	Grants.capture(p, wild)
	wild.level = 99
	check(
		"a caught creature is a copy, not the battle's own table",
		p.Creatures[wild.id].level ~= 99
	)

	local giant = creature("Spadesnout", "Ruby")
	giant.isGiant = true
	p.Creatures[giant.id] = giant
	local starter = creature()
	p.Creatures[starter.id] = starter
	p.Team = { starter.id }
	local refused = Grants.release(p, giant.id, false)
	check(
		"a giant cannot be released",
		refused.outcome == "Refused" and p.Creatures[giant.id] ~= nil
	)
end

print("\n== Gem-tier finds and their serial numbers ==")
do
	local p = fresh(100)
	Grants.rollDay(p, 86400 * 200)
	local gem = creature("Duneskit", "Gem")
	check(
		"a gem-tier wild creature needs a serial number",
		Grants.needsSerial(gem) and not Grants.needsSerial(creature())
	)
	local before = p.Candy.typed.Sand
	local grant = Grants.capture(p, gem)
	check(
		"catching one puts it in the saved waiting list, not the stable",
		grant.outcome == "Waiting" and p.Creatures[gem.id] == nil and #p.Pending == 1
	)
	check("the candy for the catch is paid at once", p.Candy.typed.Sand > before)
	check(
		"the waiting entry holds a copy of the creature",
		p.Pending[1].creature ~= nil and p.Pending[1].creature ~= gem and p.Pending[1].ref == gem.id
	)
	check(
		"the same creature cannot be caught twice while it waits",
		Grants.capture(p, gem).outcome == "Refused" and #p.Pending == 1
	)
	check("it is listed as waiting for its number", #Grants.awaitingSerial(p) == 1)
	check(
		"its number counts within its tier and species",
		Grants.serialKind("Gem", gem.id, gem) == "Gem:Gem:Duneskit"
	)
	check("without a number it cannot join", Grants.finishGem(p, gem.id).outcome == "Refused")
	check(
		"a bad number is refused",
		not Grants.keepSerial(p, "Gem", gem.id, 0) and not Grants.keepSerial(p, "Gem", "nobody", 4)
	)
	check(
		"the number is kept on the waiting entry, once",
		Grants.keepSerial(p, "Gem", gem.id, 12)
			and not Grants.keepSerial(p, "Gem", gem.id, 13)
			and #Grants.awaitingSerial(p) == 0
	)
	check(
		"the record is sound while it waits",
		#Profile.validate(p) == 0,
		table.concat(Profile.validate(p), "; ")
	)
	p.StableCapacity = 0
	check(
		"with a full stable it keeps waiting, number and all",
		Grants.finishGem(p, gem.id).outcome == "NoRoom" and p.Pending[1].serial == 12
	)
	p.StableCapacity = 100
	check(
		"with room it joins the stable carrying its number",
		Grants.finishGem(p, gem.id).outcome == "Granted"
			and p.Creatures[gem.id].serial == 12
			and #p.Pending == 0
	)
	check("it is in the Index", p.Index.owned.Duneskit == true)
	check("it cannot be finished twice", Grants.finishGem(p, gem.id).outcome == "Refused")
	check("the record is sound", #Profile.validate(p) == 0, table.concat(Profile.validate(p), "; "))
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("grant checks failed")
end
