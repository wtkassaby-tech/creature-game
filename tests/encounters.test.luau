--!strict
-- Checks for the map layout and a player's wild creatures in the world.
-- Run from the project folder:  lune run tests/encounters.test

local Biomes = require("../src/content/Biomes")
local Encounters = require("../src/shared/Encounters")
local Lasso = require("../src/shared/Lasso")
local Layout = require("../src/shared/Layout")
local Tamers = require("../src/content/Tamers")
local WorldConfig = require("../src/config/WorldConfig")

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

local greenwood = Biomes.greenwood
local map = Layout.build(greenwood, Tamers.locals)

local nextId = 0
local function newId(): string
	nextId += 1
	return `w{nextId}`
end

print("\n== The map ==")
do
	local allExact = true
	for _, route in greenwood.routes do
		local line = map.routes[route.id]
		local length = 0
		for index = 1, #line.points - 1 do
			length += Layout.distance(line.points[index], line.points[index + 1])
		end
		allExact = allExact and math.abs(length - route.length) < 0.001
	end
	check("each route's path is exactly as long as its data says", allExact)
	local a, b = map.routes.greenwood_route_a, map.routes.greenwood_route_b
	check(
		"Route A runs west of the hub and Route B east",
		Layout.pointAt(a, 400).x < -300 and Layout.pointAt(b, 600).x > 400
	)
	local step = Layout.distance(Layout.pointAt(a, 100), Layout.pointAt(a, 150))
	check("distance along the path is real distance", math.abs(step - 50) < 0.001, `{step}`)
	local missing = {}
	for _, id in
		{
			"mentor",
			"marlow_tuppence",
			"greenwood_route_a",
			"clover_meadow",
			"greenwood_gate",
			"greenwood_lair",
			"reed_bed",
			"gw_pip",
			"greenwood_sealed_path",
		}
	do
		if map.places[id] == nil then
			table.insert(missing, id)
		end
	end
	check(
		"every story place, character, tamer and rustle spot has a position",
		#missing == 0,
		table.concat(missing, ", ")
	)
	check(
		"the gate is at the end of Route B",
		Layout.distance(map.places.greenwood_gate, Layout.pointAt(b, 600)) < 0.001
	)
	check(
		"the lair is its spur's length off the route",
		math.abs(Layout.distance(map.lairSpur[1], map.lairSpur[2]) - greenwood.lair.spurLength)
			< 0.001
	)
	check(
		"near and far are told apart",
		Layout.isNear(map, "mentor", map.places.mentor, 16)
			and not Layout.isNear(map, "mentor", map.places.greenwood_gate, 16)
	)
	check(
		"a broken position is never near",
		not Layout.isNear(map, "mentor", { x = 0 / 0, z = 0 }, 16)
	)
end

print("\n== Wild creatures near the player ==")
do
	local book = Encounters.new()
	local glade = map.places.mossy_glade
	local changed = Encounters.tick(book, greenwood, map, glade, 0, 1, newId)
	local inGlade, far = 0, 0
	for _, spawn in book.spawns do
		if spawn.area == "mossy_glade" then
			inGlade += 1
		end
		if Layout.distance(spawn.at, glade) > WorldConfig.ACTIVE_RANGE + 200 then
			far += 1
		end
	end
	check(
		"the stretch the player is in fills up",
		changed and inGlade == WorldConfig.SPAWNS_PER_AREA
	)
	check("nothing appears far from the player", far == 0)
	check(
		"a second look changes nothing",
		not Encounters.tick(book, greenwood, map, glade, 1, 2, newId)
	)
	local levelsOk, speciesOk = true, true
	for _, spawn in book.spawns do
		if spawn.area == "mossy_glade" then
			levelsOk = levelsOk and spawn.creature.level >= 2 and spawn.creature.level <= 3
			local species = spawn.creature.parts.Torso.species
			speciesOk = speciesOk and (species == "Mossmitt" or species == "Gorsling")
		end
	end
	check("they are the stretch's own species at its levels", levelsOk and speciesOk)
	Encounters.tick(book, greenwood, map, map.places.greenwood_gate, 2, 3, newId)
	local left = 0
	for _, spawn in book.spawns do
		if spawn.area == "mossy_glade" then
			left += 1
		end
	end
	check("walking far away clears the stretch behind", left == 0)
	check(
		"a player's creatures never pass the cap",
		Encounters.count(book) <= WorldConfig.MAX_SPAWNS
	)
end

print("\n== Starting and ending battles ==")
do
	local book = Encounters.new()
	local glade = map.places.mossy_glade
	Encounters.tick(book, greenwood, map, glade, 0, 5, newId)
	local target: Encounters.Spawn? = nil
	for _, spawn in book.spawns do
		if spawn.area == "mossy_glade" then
			target = spawn
			break
		end
	end
	local spawn = assert(target, "a creature is in the glade")
	check(
		"a made-up id is refused",
		Encounters.engage(book, 9999, spawn.at) == nil
			and Encounters.engage(book, "1", spawn.at) == nil
	)
	check(
		"a creature far from the player is refused",
		Encounters.engage(book, spawn.id, { x = spawn.at.x + 200, z = spawn.at.z }) == nil
	)
	check(
		"standing by it starts the battle",
		Encounters.engage(book, spawn.id, spawn.at) == spawn and spawn.busy
	)
	check("it cannot be battled twice at once", Encounters.engage(book, spawn.id, spawn.at) == nil)

	Encounters.finish(book, spawn.id, "Ran", 2, 10)
	check(
		"running leaves it there with its missed throws remembered",
		book.spawns[spawn.id] == spawn and not spawn.busy and spawn.misses == 2
	)
	Encounters.engage(book, spawn.id, spawn.at)
	Encounters.finish(book, spawn.id, "Lost", 0, 11)
	check("a later battle never lowers the count", spawn.misses == 2)
	Encounters.engage(book, spawn.id, spawn.at)
	Encounters.finish(book, spawn.id, "Caught", 2, 20)
	check("a caught creature is gone", book.spawns[spawn.id] == nil)

	local before = Encounters.count(book)
	Encounters.tick(book, greenwood, map, glade, 21, 6, newId)
	check("its stretch does not refill at once", Encounters.count(book) == before)
	Encounters.tick(book, greenwood, map, glade, 20 + WorldConfig.RESPAWN_SECONDS, 7, newId)
	check("and refills after the wait", Encounters.count(book) == before + 1)
end

print("\n== Review fixes ==")
do
	local book = Encounters.new()
	local glade = map.places.mossy_glade
	Encounters.tick(book, greenwood, map, glade, 0, 11, newId)
	Encounters.tick(book, greenwood, map, map.places.greenwood_gate, 5, 12, newId)
	Encounters.tick(book, greenwood, map, glade, 10, 13, newId)
	local back = 0
	for _, spawn in book.spawns do
		if spawn.area == "mossy_glade" then
			back += 1
		end
	end
	check("walking away and straight back does not reroll a stretch", back == 0)
	Encounters.tick(book, greenwood, map, glade, 5 + WorldConfig.RESPAWN_SECONDS, 14, newId)
	local refilled = 0
	for _, spawn in book.spawns do
		if spawn.area == "mossy_glade" then
			refilled += 1
		end
	end
	check("it refills after the usual wait", refilled == WorldConfig.SPAWNS_PER_AREA)

	local rare: Encounters.Spawn? = nil
	for _, spawn in book.spawns do
		if spawn.area == "mossy_glade" then
			rare = spawn
			break
		end
	end
	local gem = assert(rare, "a creature is in the glade")
	gem.creature.rarity = "Gem"
	local limit = assert(Lasso.missesBeforeFlee("Gem"), "gem creatures flee")
	Encounters.engage(book, gem.id, gem.at)
	Encounters.finish(book, gem.id, "Lost", limit, 100)
	check(
		"a creature that dodged its last throw is gone, even if the battle was lost",
		book.spawns[gem.id] == nil
	)
end

print("\n== Fainted and never-there creatures ==")
do
	local book = Encounters.new()
	local glade = map.places.mossy_glade
	Encounters.tick(book, greenwood, map, glade, 0, 21, newId)
	local first: Encounters.Spawn? = nil
	for _, spawn in book.spawns do
		first = first or spawn
	end
	local spawn = assert(first, "a creature is there")
	Encounters.engage(book, spawn.id, spawn.at)
	spawn.creature.hurt = 1
	Encounters.finish(book, spawn.id, "Draw", 0, 5)
	check("a wild creature knocked out in a draw is gone", book.spawns[spawn.id] == nil)
	local before = Encounters.count(book)
	local second: Encounters.Spawn? = nil
	for _, other in book.spawns do
		second = second or other
	end
	local gone = assert(second, "another creature is there")
	Encounters.remove(book, gone.id)
	check("a creature can be taken out of the world outright", Encounters.count(book) == before - 1)
end

print("\n== Long grass ==")
do
	local patch = map.places[Layout.grassId("clover_meadow")]
	check(
		"every stretch has a grass patch off the path",
		patch ~= nil and Layout.distance(patch, map.places.clover_meadow) > WorldConfig.GRASS_RADIUS
	)
	local function walk(
		book: Encounters.Book,
		at: Layout.Point,
		walking: boolean,
		from: number,
		seconds: number
	): Encounters.Spawn?
		for second = from, from + seconds - 1 do
			local found =
				Encounters.grass(book, greenwood, map, at, walking, second, second * 31 + 7, newId)
			if found then
				return found
			end
		end
		return nil
	end
	check(
		"standing still in the grass meets nothing",
		walk(Encounters.new(), patch, false, 0, 200) == nil
	)
	check(
		"walking on the path meets nothing",
		walk(Encounters.new(), map.places.clover_meadow, true, 0, 200) == nil
	)
	local book = Encounters.new()
	local found = walk(book, patch, true, 0, 200)
	check("walking through the grass brings a creature out", found ~= nil)
	local spawn = assert(found, "a creature jumped out")
	local species = spawn.creature.parts.Torso.species
	check(
		"it is one of the stretch's own, already in a battle",
		spawn.busy
			and spawn.area == "clover_meadow"
			and (species == "Gorsling" or species == "Mossmitt" or species == "Stumpwarden")
	)
	check(
		"the grass rests before the next one",
		Encounters.grass(book, greenwood, map, patch, true, book.grassAt - 1, 5, newId) == nil
	)
	Encounters.finish(book, spawn.id, "Ran", 0, 300)
	check(
		"one the player ran from stays as a creature they can see",
		book.spawns[spawn.id] == spawn and not spawn.busy
	)
	local met, tries = 0, 2000
	for second = 1, tries do
		local fresh = Encounters.new()
		if Encounters.grass(fresh, greenwood, map, patch, true, second, second * 17 + 3, newId) then
			met += 1
		end
	end
	check(
		"the chance each second is about what the config says",
		math.abs(met / tries - WorldConfig.GRASS_CHANCE) < 0.04,
		`{met / tries}`
	)
end

print("\n== Rustle spots ==")
do
	local book = Encounters.new()
	local reeds = map.places.reed_bed
	check(
		"a spot far away does not stir",
		Encounters.rustle(book, greenwood, map, "reed_bed", map.places.mentor, 0, 1, newId) == nil
	)
	check(
		"a made-up spot is refused",
		Encounters.rustle(book, greenwood, map, "gold_mine", reeds, 0, 1, newId) == nil
			and Encounters.rustle(book, greenwood, map, 7, reeds, 0, 1, newId) == nil
	)
	local spawn = Encounters.rustle(book, greenwood, map, "reed_bed", reeds, 0, 1, newId)
	check("standing in it brings a creature out", spawn ~= nil and spawn.spot == "reed_bed")
	check(
		"the spot rests before it stirs again",
		Encounters.rustle(book, greenwood, map, "reed_bed", reeds, 5, 2, newId) == nil
	)
	check(
		"and stirs again after the rest",
		Encounters.rustle(
			book,
			greenwood,
			map,
			"reed_bed",
			reeds,
			WorldConfig.RUSTLE_COOLDOWN_SECONDS,
			3,
			newId
		) ~= nil
	)
	local uncommon, tries = 0, 300
	for seed = 1, tries do
		local fresh = Encounters.new()
		local found = assert(
			Encounters.rustle(fresh, greenwood, map, "reed_bed", reeds, 0, seed, newId),
			"stirs"
		)
		if found.creature.rarity == "Uncommon" then
			uncommon += 1
		end
	end
	check(
		"a rustle gives an uncommon creature about half the time",
		uncommon / tries > 0.35 and uncommon / tries < 0.65,
		`{uncommon / tries}`
	)
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("encounter checks failed")
end
