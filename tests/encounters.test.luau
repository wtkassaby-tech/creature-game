--!strict
-- Checks for the map layout and a player's wild creatures in the world.
-- Run from the project folder:  lune run tests/encounters.test

local Biomes = require("../src/content/Biomes")
local EconomyConfig = require("../src/config/EconomyConfig")
local Encounters = require("../src/shared/Encounters")
local Lasso = require("../src/shared/Lasso")
local Layout = require("../src/shared/Layout")
local Rng = require("../src/shared/Rng")
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
		Layout.pointAt(a, 400).x < -200 and Layout.pointAt(b, 600).x > 400
	)
	-- Along 100 to 125 lies inside one straight leg of Route A, so it is a straight-line distance.
	local step = Layout.distance(Layout.pointAt(a, 100), Layout.pointAt(a, 125))
	check("distance along the path is real distance", math.abs(step - 25) < 0.001, `{step}`)
	local legs = 0
	for index = 1, #a.points - 1 do
		legs += Layout.distance(a.points[index], a.points[index + 1])
	end
	check(
		"Route A's leg lengths sum to its length in the data",
		math.abs(legs - greenwood.routes[1].length) < 0.001,
		`{legs}`
	)
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
	local spur = 0
	for index = 1, #map.lairSpur - 1 do
		spur += Layout.distance(map.lairSpur[index], map.lairSpur[index + 1])
	end
	check(
		"the lair is its spur's length off the route",
		math.abs(spur - greenwood.lair.spurLength) < 0.001
			and Layout.distance(map.lairSpur[#map.lairSpur], map.places.greenwood_lair) < 0.001,
		`{spur}`
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

print("\n== More than one biome ==")
do
	-- A second biome made from Greenwood's own data under new ids, to check the world layout
	-- without needing a real second biome.
	local function renamed(text: string): string
		return "b2_" .. text
	end
	local second: any = table.clone(greenwood)
	second.id, second.number = "b2", 2
	second.map = nil -- Greenwood's map sheet names Greenwood's own ids; the copy is generated
	second.hub = table.clone(greenwood.hub)
	second.hub.id = renamed(greenwood.hub.id)
	second.hub.buildings = {}
	for _, building in greenwood.hub.buildings do
		table.insert(
			second.hub.buildings,
			{ id = renamed(building.id), name = building.name, role = building.role }
		)
	end
	second.routes = {}
	for _, route in greenwood.routes do
		local copy: any = table.clone(route)
		copy.id = renamed(route.id)
		copy.areas, copy.rustleSpots, copy.tamers = {}, {}, {}
		for _, area in route.areas do
			local a: any = table.clone(area)
			a.id = renamed(area.id)
			table.insert(copy.areas, a)
		end
		table.insert(second.routes, copy)
	end
	second.lair = table.clone(greenwood.lair)
	second.lair.id, second.lair.joinsRoute =
		renamed(greenwood.lair.id), renamed(greenwood.lair.joinsRoute)
	second.gate = table.clone(greenwood.gate)
	second.gate.id, second.gate.route = renamed(greenwood.gate.id), renamed(greenwood.gate.route)
	second.gate.sealedPath = renamed(greenwood.gate.sealedPath)

	local world = Layout.world({ second, greenwood }, Tamers.locals)
	local firstHub, secondHub = world.maps[1].hub, world.maps[2].hub
	check(
		"the first biome stays where it was",
		firstHub.x == 0 and firstHub.z == 0 and world.map.places.mentor ~= nil
	)
	local sealed = world.map.places.greenwood_sealed_path
	check(
		"the second biome's hub lies beyond the first one's sealed road",
		secondHub.x > sealed.x and Layout.distance(secondHub, sealed) > secondHub.size / 2 + 50
	)
	local clear = true
	for id, place in world.maps[2].places do
		for otherId, other in world.maps[1].places do
			if Layout.distance(place, other) < 30 then
				clear = false
				print(`    too close: {id} and {otherId}`)
			end
		end
	end
	check("no place of one biome sits on top of a place of the other", clear)
	check("a point in the first hub is in biome 1", Layout.biomeAt(world, { x = 0, z = 0 }) == 1)
	check(
		"a point in the second hub is in biome 2",
		Layout.biomeAt(world, { x = secondHub.x, z = secondHub.z }) == 2
	)
	check(
		"the end of the first biome's last route is still biome 1",
		Layout.biomeAt(world, world.map.places.greenwood_gate) == 1
	)
	local routeLengthsOk = true
	for _, route in second.routes do
		local line = world.map.routes[route.id]
		local length = 0
		for index = 1, #line.points - 1 do
			length += Layout.distance(line.points[index], line.points[index + 1])
		end
		routeLengthsOk = routeLengthsOk and math.abs(length - route.length) < 0.001
	end
	check("the second biome's routes keep their exact lengths", routeLengthsOk)
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

print("\n== Every rustle spot has something in it ==")
do
	local World = require("../src/shared/World")
	local empty: { string } = {}
	for _, biome in Biomes do
		for _, route in biome.routes do
			for _, spot in route.rustleSpots do
				if #World.candidates(route, { spot = spot.id }) == 0 then
					table.insert(empty, spot.id)
				end
			end
		end
	end
	check(
		"no rustle spot in any biome is empty (a search or a bait there always finds something)",
		#empty == 0,
		table.concat(empty, ", ")
	)
end

print("\n== Bait ==")
do
	local reeds = map.places.reed_bed
	check(
		"bait draws nothing out before Tide Flats",
		Encounters.bait(Encounters.new(), greenwood, map, "reed_bed", reeds, 1, newId) == nil
	)
	-- The same spots as a third biome, to test the rule without Tide Flats' own data.
	local third: any = table.clone(greenwood)
	third.number = 3
	check(
		"it must be used at a rustle spot the player is standing in",
		Encounters.bait(Encounters.new(), third, map, "reed_bed", map.places.mentor, 1, newId)
				== nil
			and Encounters.bait(Encounters.new(), third, map, "gold_mine", reeds, 1, newId)
				== nil
	)
	local book = Encounters.new()
	local first = Encounters.bait(book, third, map, "reed_bed", reeds, 1, newId)
	local second = Encounters.bait(book, third, map, "reed_bed", reeds, 2, newId)
	check(
		"bait always brings a creature out, with no rest between uses",
		first ~= nil and second ~= nil and Encounters.count(book) == 2
	)
	local gems, tries = 0, 600
	for seed = 1, tries do
		local found = assert(
			Encounters.bait(Encounters.new(), third, map, "reed_bed", reeds, seed, newId),
			"a creature steps out"
		)
		if found.creature.rarity == "Gem" then
			gems += 1
		end
	end
	check(
		"a bait creature is gem-tier at the economy's bait chance",
		math.abs(gems / tries - EconomyConfig.BAIT_GEM_CHANCE) < 0.06,
		`{gems / tries}`
	)
end

print("\n== Creatures hide in the long grass ==")
do
	-- Every roaming creature of every biome sits inside its stretch's grass patch, whatever the
	-- seed, and keeps its distance from the others there so their triggers do not overlap.
	local inside, spaced, total = true, true, 0
	for _, biome in Biomes do
		local biomeMap = Layout.build(biome, Tamers.locals)
		for seed = 1, 40 do
			local book = Encounters.new()
			for _, route in biome.routes do
				for _, area in route.areas do
					local centre = biomeMap.places[area.id]
					if centre then
						Encounters.tick(book, biome, biomeMap, centre, 0, seed, newId)
					end
				end
			end
			local list: { Encounters.Spawn } = {}
			for _, spawn in book.spawns do
				table.insert(list, spawn)
				total += 1
				-- A stretch may have several patches: the creature sits inside one of them.
				local within = false
				for _, patch in Encounters.patchesOf(biomeMap, spawn.area) do
					local reach = math.min(WorldConfig.GRASS_SPAWN_REACH, patch.r - 7)
					if Layout.distance(patch, spawn.at) <= reach + 1e-6 then
						within = true
					end
				end
				if not within then
					inside = false
				end
			end
			for a = 1, #list do
				for b = a + 1, #list do
					if list[a].area == list[b].area then
						if
							Layout.distance(list[a].at, list[b].at)
							< WorldConfig.GRASS_TRIGGER_RADIUS * 1.2
						then
							spaced = false
						end
					end
				end
			end
		end
	end
	check("some creatures were placed", total > 0)
	check("every hiding place is inside its stretch's grass patch", inside)
	check(
		"the grass reach stays inside the patch itself",
		WorldConfig.GRASS_SPAWN_REACH < WorldConfig.GRASS_RADIUS
	)
	check("creatures in one patch are too far apart to trigger together", spaced)

	-- Finding one means walking right up to it; a roaming one cannot be fought from afar.
	local book = Encounters.new()
	local glade = map.places.mossy_glade
	Encounters.tick(book, greenwood, map, glade, 0, 9, newId)
	local spawn: Encounters.Spawn? = nil
	for _, each in book.spawns do
		spawn = each
		break
	end
	local found = assert(spawn, "a creature is hiding")
	local reach = WorldConfig.GRASS_TRIGGER_RADIUS + WorldConfig.POSITION_SLACK
	check(
		"it cannot be fought from beyond the trigger reach",
		Encounters.engage(book, found.id, { x = found.at.x + reach + 3, z = found.at.z }, 1) == nil
	)
	check(
		"walking up to it starts the battle",
		Encounters.engage(book, found.id, { x = found.at.x + 3, z = found.at.z }, 1) == found
	)
	-- Running from it leaves it hiding, but not available at once.
	Encounters.finish(book, found.id, "Ran", 0, 100)
	check("it stays where it hid", book.spawns[found.id] ~= nil and not found.busy)
	check(
		"and cannot be started again straight away",
		Encounters.engage(book, found.id, found.at, 101) == nil
	)
	check(
		"but can once the calm has passed",
		Encounters.engage(book, found.id, found.at, 100 + WorldConfig.WILD_CALM_SECONDS + 1)
			== found
	)

	-- One a rustle spot brought out is at the player's feet, so the wider reach applies.
	local spot = Encounters.rustle(
		Encounters.new(),
		greenwood,
		map,
		"reed_bed",
		map.places.reed_bed,
		0,
		3,
		newId
	)
	check("a rustle spot still brings a creature out", spot ~= nil)
	if spot then
		local book2 = Encounters.new()
		book2.spawns[spot.id] = spot
		check(
			"and it can be fought from the spot's own reach",
			Encounters.engage(
				book2,
				spot.id,
				{ x = spot.at.x + WorldConfig.ENGAGE_RADIUS, z = spot.at.z },
				1
			) == spot
		)
	end
end

print("\n== Several patches in a stretch ==")
do
	local patches = map.grass.sandy_bank
	local extra = patches[2]
	check("a stretch can have more than one patch of grass", extra ~= nil and #patches > 1)
	local found: Encounters.Spawn? = nil
	local book = Encounters.new()
	for second = 1, 60 do
		found = found
			or Encounters.grass(
				book,
				greenwood,
				map,
				{ x = extra.x, z = extra.z },
				true,
				second * 20,
				second * 13 + 5,
				newId
			)
	end
	check("walking through an extra patch brings a creature out", found ~= nil)
	local outside = Encounters.grass(
		Encounters.new(),
		greenwood,
		map,
		{ x = extra.x + extra.r + 6, z = extra.z },
		true,
		100,
		7,
		newId
	)
	check("just outside it nothing jumps out", outside == nil)
	local hidden = true
	for seed = 1, 40 do
		local at = Encounters.hideAt(
			map,
			map.routes.greenwood_route_b,
			greenwood.routes[2].areas[1],
			{},
			Rng.new(seed)
		)
		local inside = false
		for _, patch in Encounters.patchesOf(map, "sandy_bank") do
			if Layout.distance(patch, at) <= patch.r then
				inside = true
			end
		end
		hidden = hidden and inside
	end
	check("a creature always hides inside one of the patches", hidden)
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("encounter checks failed")
end
