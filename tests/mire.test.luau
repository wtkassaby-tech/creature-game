--!strict
-- (Over 400 lines because it checks the whole of biome 4: world, tamers, quests, story and giant.)
-- Checks on the Mire's world data (biome 4): the hub, routes, spawn tables, tamers, the rival's
-- mid-biome battle, the gate's champion, the quest line, chapter 4 of the story and the giant
-- Sloughback, including simulated fights, and the robot players of tests/playthrough.test playing
-- all four biomes. The Mire is written ahead of launch, so this test opens it first.
-- Run from the project folder:  lune run tests/mire.test
require("../src/config/ReleaseConfig").OPEN_BIOMES = 4

local Battle = require("../src/shared/Battle")
local BattleAi = require("../src/shared/BattleAi")
local BattleConfig = require("../src/config/BattleConfig")
local BreedConfig = require("../src/config/BreedConfig")
local Biomes = require("../src/content/Biomes")
local Breeding = require("../src/shared/Breeding")
local EconomyConfig = require("../src/config/EconomyConfig")
local GiantBattle = require("../src/shared/GiantBattle")
local GiantConfig = require("../src/config/GiantConfig")
local Giants = require("../src/content/Giants")
local Layout = require("../src/shared/Layout")
local Moves = require("../src/content/Moves")
local Profile = require("../src/shared/Profile")
local ProgressionConfig = require("../src/config/ProgressionConfig")
local Quests = require("../src/content/Quests")
local QuestsMire = require("../src/content/quests/Mire")
local Rng = require("../src/shared/Rng")
local Species = require("../src/content/Species")
local Stats = require("../src/shared/Stats")
local Story = require("../src/content/Story")
local StoryProgress = require("../src/shared/StoryProgress")
local Storyline = require("../src/content/Storyline")
local Tamers = require("../src/content/Tamers")
local TamersMire = require("../src/content/tamers/Mire")
local TypeChart = require("../src/shared/TypeChart")
local Types = require("../src/shared/Types")
local World = require("../src/shared/World")
local WorldTypes = require("../src/shared/WorldTypes")
local Xp = require("../src/shared/Xp")

type Fighter = Battle.Fighter
type State = GiantBattle.State
type Action = GiantBattle.Action
type GiantDef = GiantBattle.GiantDef

-- The robots first: the same robot players as tests/playthrough.test, unchanged, now with the Mire
-- open, so they play four chapters and earn four badges. Their checks fail this test if any robot
-- is stuck, walled or badly paced; the lines it prints give the fourth badge's pacing.
print("== Robots play all four biomes (tests/playthrough.test with the Mire open) ==")
-- The playthrough is a script that returns nothing, which the strict type checker will not let a
-- plain require load; running it through an untyped `require` keeps it exactly as it is.
local runScript: (string) -> () = require :: any
runScript("./playthrough.test")

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

local BIOME = 4
local MAX_LEVEL = Xp.levelCap(3) -- the cap with three badges, which a player arrives with
local MAX_LINE = 90
local MAX_LINES = 3
local TEAM = 4 -- creatures in a team from three badges on

local greenwood = Biomes.greenwood
local canyon = Biomes.dust_canyon
local tide = Biomes.tide_flats
local mire = Biomes.mire
local chapter = Story.chapter_4
local giant: GiantDef = Giants.mire_sloughback
local ENRAGE: GiantBattle.Enrage = assert(giant.enrage, "Sloughback has its own enrage")

local function isLevel(level: number): boolean
	return level >= 1 and level <= MAX_LEVEL and level == math.floor(level)
end

local function contains(list: { string }, value: string): boolean
	return table.find(list, value) ~= nil
end

local function containsAny(list: { any }, value: any): boolean
	return table.find(list, value) ~= nil
end

local function poisons(moveName: string): boolean
	return Moves[moveName].effect == "Poison"
end

-- Places that exist in the Mire, for checking triggers and objectives.
local places: { string } = { mire.hub.id, mire.lair.id, mire.gate.id, mire.gate.sealedPath }
local routeById: { [string]: WorldTypes.Route } = {}
local routeOf: { [string]: string } = {}
for _, route in mire.routes do
	table.insert(places, route.id)
	routeById[route.id] = route
	for _, area in route.areas do
		table.insert(places, area.id)
		routeOf[area.id] = route.id
	end
end

-- Biome data ----------------------------------------------------------------------------------

print("\nBiome data")
check("the release config opens the Mire for this test", Biomes.mire ~= nil)
check("the registry holds the Mire as biome 4", mire ~= nil and mire.number == BIOME)
check("it is the Toxic biome", mire.element == "Toxic" and mire.id == "mire")
check("two routes", #mire.routes == 2)
check(
	"the hub has seven buildings with the roles Tide Flats' has",
	(function(): boolean
		local roles: { [string]: boolean } = {}
		for _, building in mire.hub.buildings do
			roles[building.role] = true
		end
		local count = 0
		for _ in roles do
			count += 1
		end
		return #mire.hub.buildings == 7
			and count == 7
			and roles.Shop == true
			and roles.Healer == true
			and roles.Breeder == true
			and roles.Quests == true
			and roles.Teleport == true
			and roles.Circuit == true
			and roles.Lookout == true
	end)()
)
check(
	"the shop keeper, the healer and the punter have npc ids",
	(function(): boolean
		local shop, healer, teleport = false, false, false
		for _, building in mire.hub.buildings do
			if building.role == "Shop" and building.npc == "vesper_quill" then
				shop = true
			end
			if building.role == "Healer" and building.npc == "ottilie_dunmore" then
				healer = true
			end
			if building.role == "Teleport" and building.npc == "jory_pike" then
				teleport = true
			end
		end
		return shop and healer and teleport
	end)()
)
check("the lair's giant exists", Giants[mire.lair.giant] == giant)
check("the lair leaves a real route", routeById[mire.lair.joinsRoute] ~= nil)
check("the gate ends a real route", routeById[mire.gate.route] ~= nil)
check(
	"the lair spur leaves inside the route's length",
	mire.lair.joinsAt > 0 and mire.lair.joinsAt < routeById[mire.lair.joinsRoute].length
)
check(
	"the gate's recommended levels are 42 to 45, the cap with three badges",
	mire.gate.recommendedMin == 42 and mire.gate.recommendedMax == MAX_LEVEL
)
check(
	"the gate gives a badge, shuts a sealed path and leads to biome 5 (Frostline)",
	mire.gate.badge.id == "mire_badge"
		and mire.gate.sealedPath == "mire_sealed_path"
		and mire.gate.nextBiome == 5
)
check(
	"the gate's battle is a local champion's, a story battle with one team",
	mire.gate.battle == "champion_vell"
		and Tamers.story[mire.gate.battle] ~= nil
		and Tamers.story[mire.gate.battle].team ~= nil
		and TamersMire.rival == nil
)
check(
	"the biome's level range is the economy's band for biome 4",
	mire.levelMin == EconomyConfig.LEVEL_BANDS[BIOME].min
		and mire.levelMax == EconomyConfig.LEVEL_BANDS[BIOME].max
)

local seen: { [string]: boolean } = {}
local openSeen: { [string]: boolean } = {}
local lowest, highest = 99, 0
for _, route in mire.routes do
	check(`{route.id}: three or four areas`, #route.areas >= 3 and #route.areas <= 4)
	check(`{route.id}: spawn table is not empty`, #route.spawns > 0)

	local areaIds: { string } = {}
	local areaById: { [string]: WorldTypes.Area } = {}
	for _, area in route.areas do
		table.insert(areaIds, area.id)
		areaById[area.id] = area
	end

	local spots: { [string]: boolean } = {}
	for _, spot in route.rustleSpots do
		spots[spot.id] = true
		check(`{spot.id}: rustle spot sits on a real area`, contains(areaIds, spot.area))
		local area = areaById[spot.area]
		check(
			`{spot.id}: rustle spot is on the route and inside its area`,
			spot.at >= 0
				and spot.at <= route.length
				and area ~= nil
				and spot.at >= area.from
				and spot.at <= area.to
		)
	end

	local previousTo, previousMax = 0, 0
	for _, area in route.areas do
		check(
			`{area.id}: areas follow on in order`,
			area.from == previousTo and area.to > area.from
		)
		check(
			`{area.id}: levels never fall along the route`,
			area.minLevel >= previousMax - 1 and area.maxLevel >= area.minLevel
		)
		previousTo, previousMax = area.to, area.maxLevel
		lowest = math.min(lowest, area.minLevel)
		highest = math.max(highest, area.maxLevel)
	end
	check(`{route.id}: areas cover the whole route`, previousTo == route.length)

	local rowsOk, levelsOk, areasOk, colourOk, uncommonOk, spotsOk =
		true, true, true, true, true, true
	for _, entry in route.spawns do
		local def = Species[entry.species]
		if def == nil or entry.weight <= 0 then
			rowsOk = false
		end
		if
			not isLevel(entry.minLevel)
			or not isLevel(entry.maxLevel)
			or entry.minLevel > entry.maxLevel
		then
			levelsOk = false
		end
		local area = areaById[entry.area]
		if area == nil or entry.minLevel < area.minLevel or entry.maxLevel > area.maxLevel then
			areasOk = false
		end
		for _, colour in entry.colours do
			if BreedConfig.COLOURS[colour] == nil then
				colourOk = false
			end
		end
		if entry.rareColourChance <= 0 or entry.rareColourChance > 0.1 then
			colourOk = false
		end
		if def ~= nil then
			seen[entry.species] = true
			if entry.spot == nil then
				openSeen[entry.species] = true
			end
			if def.baseRarity ~= "Common" and entry.spot == nil then
				uncommonOk = false
			end
			if def.giantForm then
				rowsOk = false -- a giant's form is never met in the wild
			end
		end
		if entry.spot ~= nil and not spots[entry.spot] then
			spotsOk = false
		end
	end
	check(`{route.id}: species exist, are not giants, and weights are positive`, rowsOk)
	check(`{route.id}: levels are 1 to {MAX_LEVEL}`, levelsOk)
	check(`{route.id}: each row's levels fit its area`, areasOk)
	check(`{route.id}: colours are known and rare chance is small`, colourOk)
	check(`{route.id}: uncommon species appear only at rustle spots`, uncommonOk)
	check(`{route.id}: every rustle row names a real spot`, spotsOk)
	check(`{route.id}: the open table is not empty`, #World.candidates(route, nil) > 0)
	for _, area in route.areas do
		check(`{area.id}: has open rows`, #World.candidates(route, { area = area.id }) > 0)
	end
	for _, spot in route.rustleSpots do
		check(`{spot.id}: has rows`, #World.candidates(route, { spot = spot.id }) > 0)
	end
	for _, id in route.tamers do
		local tamer = Tamers.locals[id]
		check(`{id}: tamer exists and is on {route.id}`, tamer ~= nil and tamer.route == route.id)
	end
end
do
	local count = 0
	for _, route in mire.routes do
		count += #route.rustleSpots
	end
	check("three rustle spots in all (bait still works at each)", count == 3, `{count}`)
end

-- Every Mire species (biome 4, not a giant's form) appears; commons in the open, the uncommon ones
-- never in the open.
local mireSpecies = 0
for name, def in Species do
	if def.biome == BIOME and not def.giantForm then
		mireSpecies += 1
		check(`{name}: appears in the Mire`, seen[name] == true)
		if def.baseRarity == "Common" then
			check(`{name}: common species can be met in the open`, openSeen[name] == true)
		else
			check(`{name}: uncommon species is never met in the open`, openSeen[name] ~= true)
		end
	end
end
check("there are eight Mire species", mireSpecies == 8, `{mireSpecies}`)
check(
	"a few Tide Flats species appear, rarely, near the entrance only",
	(function(): boolean
		local routeA = routeById.mire_route_a
		local total, strays = 0, 0
		local onlyEntrance = true
		for _, entry in routeA.spawns do
			if entry.spot == nil and entry.area == "reedfringe" then
				total += entry.weight
				if Species[entry.species].biome == 3 then
					strays += entry.weight
				end
			end
		end
		for _, route in mire.routes do
			for _, entry in route.spawns do
				local biomeOf = Species[entry.species].biome
				if biomeOf <= 2 or (biomeOf == 3 and entry.area ~= "reedfringe") then
					onlyEntrance = false
				end
				if biomeOf == 3 and entry.spot ~= nil then
					onlyEntrance = false
				end
			end
		end
		return strays > 0 and strays / total <= 0.15 and onlyEntrance
	end)()
)
check(
	"a Tide Flats species keeps the colour a Tide Flats row gives it first",
	(function(): boolean
		local first: { [string]: string } = {}
		for _, route in tide.routes do
			for _, entry in route.spawns do
				if first[entry.species] == nil then
					first[entry.species] = entry.colours[1]
				end
			end
		end
		for _, route in mire.routes do
			for _, entry in route.spawns do
				local theirs = first[entry.species]
				if theirs ~= nil and entry.colours[1] ~= theirs then
					return false
				end
			end
		end
		return true
	end)()
)
check(
	"gem-tier rows: only open rows of Mire species, never at rustle spots",
	(function(): boolean
		local any = false
		for _, route in mire.routes do
			for _, entry in route.spawns do
				if entry.rarity ~= nil then
					any = true
					if
						entry.rarity ~= "Gem"
						or entry.spot ~= nil
						or Species[entry.species].biome ~= BIOME
					then
						return false
					end
				end
			end
		end
		return any
	end)()
)
check(
	"in every stretch, gem-tier creatures are the economy's share of open encounters",
	(function(): boolean
		for _, route in mire.routes do
			for _, area in route.areas do
				local gem, all = 0, 0
				for _, entry in route.spawns do
					if entry.area == area.id and entry.spot == nil then
						all += entry.weight
						if entry.rarity == "Gem" then
							gem += entry.weight
						end
					end
				end
				-- Strays from Tide Flats have no gem twin, so a stretch with strays sits a little under.
				if
					all <= 0
					or gem / all > EconomyConfig.GEM_WILD_SHARE + 1e-9
					or gem / all < EconomyConfig.GEM_WILD_SHARE * 0.8
				then
					return false
				end
			end
		end
		return true
	end)()
)
check(
	"wild levels run from 32 to 42, the economy's band",
	lowest == EconomyConfig.LEVEL_BANDS[BIOME].min
		and highest == EconomyConfig.LEVEL_BANDS[BIOME].max,
	`{lowest} to {highest}`
)
check(
	"Route B's wild levels are higher than Route A's",
	routeById.mire_route_b.areas[1].minLevel
		>= routeById.mire_route_a.areas[#routeById.mire_route_a.areas].minLevel
)
check(
	"wild levels rise with distance: the far end of each route beats its start",
	(function(): boolean
		for _, route in mire.routes do
			if route.areas[#route.areas].maxLevel <= route.areas[1].maxLevel then
				return false
			end
		end
		return true
	end)()
)
check("Tide Flats' top wild level is below the Mire's lowest", tide.levelMax < mire.levelMin + 1)

-- Poison on the routes: the biome teaches it from the first stretch.
local firstArea = routeById.mire_route_a.areas[1]
check(
	"a Toxic creature (immune to poison) can be caught in the very first stretch",
	(function(): boolean
		for _, entry in World.candidates(routeById.mire_route_a, { area = firstArea.id }) do
			if
				Species[entry.species].element == BattleConfig.POISON_IMMUNE_ELEMENT
				and Species[entry.species].baseRarity == "Common"
			then
				return true
			end
		end
		return false
	end)()
)
check(
	"wild creatures in the first stretch poison: a common one keeps a poisoning move in its default four",
	(function(): boolean
		for _, entry in World.candidates(routeById.mire_route_a, { area = firstArea.id }) do
			local c = Breeding.wild(
				entry.species,
				entry.species,
				entry.minLevel,
				"Common",
				"Moss",
				Rng.new(1)
			)
			for _, name in Battle.bestMoves(c, entry.minLevel) do
				if poisons(name) then
					return true
				end
			end
		end
		return false
	end)()
)

-- Tamers ------------------------------------------------------------------------------------

print("\nTamers")
local function checkTeam(label: string, team: WorldTypes.TamerTeam, maxLevel: number)
	check(`{label}: four creatures`, #team.members == TEAM)
	local levelsOk, movesOk, poolOk, uniqueOk = true, true, true, true
	for index, m in team.members do
		local def = Species[m.species]
		if def == nil or not isLevel(m.level) or m.level > maxLevel or def.giantForm then
			levelsOk = false
		end
		if #m.moves < 1 or #m.moves > 4 then
			movesOk = false
		end
		if def ~= nil then
			local creature = Breeding.wild(
				m.species,
				`{label}_{index}`,
				m.level,
				"Common",
				"Moss",
				Rng.new(index)
			)
			local pool = Stats.movePool(creature)
			local used: { [string]: boolean } = {}
			for _, move in m.moves do
				if Moves[move] == nil then
					movesOk = false
				end
				if not contains(pool, move) then
					poolOk = false
				end
				if used[move] then
					uniqueOk = false
				end
				used[move] = true
			end
		end
	end
	check(`{label}: species known (no giants), levels 1 to {maxLevel}`, levelsOk)
	check(`{label}: one to four known moves`, movesOk)
	check(`{label}: only moves the creature can know at its level`, poolOk)
	check(`{label}: no repeated move`, uniqueOk)
end

local function topLevel(team: WorldTypes.TamerTeam): number
	local top = 0
	for _, m in team.members do
		top = math.max(top, m.level)
	end
	return top
end

local function teamPoisons(team: WorldTypes.TamerTeam): boolean
	for _, m in team.members do
		for _, name in m.moves do
			if poisons(name) then
				return true
			end
		end
	end
	return false
end

local function teamHasToxic(team: WorldTypes.TamerTeam): boolean
	for _, m in team.members do
		if Species[m.species].element == BattleConfig.POISON_IMMUNE_ELEMENT then
			return true
		end
	end
	return false
end

-- The biome's local tamers, in walking order (route, then distance).
-- The Mire was raised one level on 22 Nov 2026 (more resistance). No tamer outranks the gate's
-- strongest creature: the cap with three badges (45) less GATE_TOP_UNDER_CAP.
local TAMER_CEILING = 43
local mireTamers: { WorldTypes.Tamer } = {}
for _, tamer in TamersMire.locals do
	table.insert(mireTamers, tamer)
end
local routeIndex: { [string]: number } = { mire_route_a = 1, mire_route_b = 2 }
table.sort(mireTamers, function(a: WorldTypes.Tamer, b: WorldTypes.Tamer): boolean
	local ra, rb = routeIndex[a.route] or 9, routeIndex[b.route] or 9
	if ra ~= rb then
		return ra < rb
	end
	return a.at < b.at
end)
check("five local tamers", #mireTamers == 5, `{#mireTamers}`)
local previousTop = 0
local startsAt, endsAt = 0, 0
for index, tamer in mireTamers do
	local id = tamer.id
	check(`{id}: registered`, Tamers.locals[id] == tamer)
	checkTeam(id, tamer.team, TAMER_CEILING)
	check(`{id}: tier is Tamer`, tamer.tier == "Tamer")
	check(
		`{id}: has a look and both lines`,
		#tamer.look > 0 and #tamer.before > 0 and #tamer.after > 0
	)
	check(`{id}: lines are short`, #tamer.before <= MAX_LINE and #tamer.after <= MAX_LINE)
	local route = routeById[tamer.route]
	check(`{id}: stands on its route`, route ~= nil and tamer.at >= 0 and tamer.at <= route.length)
	check(`{id}: listed on its route`, route ~= nil and contains(route.tamers, id))
	check(`{id}: has no dark tint`, tamer.team.tint == 0)
	check(
		`{id}: teaches poison: a poisoning move, and a Toxic creature that cannot catch it`,
		teamPoisons(tamer.team) and teamHasToxic(tamer.team)
	)
	local top = topLevel(tamer.team)
	check(`{id}: levels rise along the walk`, top >= previousTop, `{previousTop} then {top}`)
	previousTop = top
	if index == 1 then
		startsAt = top
	end
	endsAt = top
end
check("tamer levels run from 34 to 43", startsAt == 34 and endsAt == 43, `{startsAt} to {endsAt}`)
check("no tamer is stronger than the gate's strongest creature", endsAt <= TAMER_CEILING)
check(
	"the first tamer's lines name the rule: poison never sticks to a Toxic creature",
	string.find(mireTamers[1].after, "Toxic", 1, true) ~= nil
		and string.find(mireTamers[1].after, "oison", 1, true) ~= nil
)

local STARTERS: { WorldTypes.Starter } = { "Mossmitt", "Spadesnout", "Sloshcalf" }
local function isStarter(name: string): boolean
	for _, starter in STARTERS do
		if starter == name then
			return true
		end
	end
	return false
end

local greenwoodRival = Tamers.rivals.rival_greenwood
local tideRival = Tamers.story.rival_breakwater
local rivalBattle = Tamers.story.rival_mire
check("the rival's mid-biome battle is a story battle", rivalBattle ~= nil)
check(
	"it is the Rival tier and counts as a Rival fight",
	rivalBattle.tier == "Rival"
		and rivalBattle.xpKind == "Rival"
		and (("Rival" :: any) :: BattleAi.Tier) == rivalBattle.tier
)
check(
	"it has one team for each starter and no single team",
	rivalBattle.teams ~= nil and rivalBattle.team == nil
)
check("he stands somewhere on Route B", routeOf[rivalBattle.place] == "mire_route_b")
check(
	"his lines are short and he can be lost to",
	#rivalBattle.before <= MAX_LINE
		and #rivalBattle.after <= MAX_LINE
		and #rivalBattle.look > 0
		and not rivalBattle.cannotLose
)
local rivalTeams = rivalBattle.teams :: WorldTypes.ByStarter<WorldTypes.TamerTeam>
local tideRivalTeams = tideRival.teams :: WorldTypes.ByStarter<WorldTypes.TamerTeam>
for _, starter in STARTERS do
	local team = rivalTeams[starter]
	checkTeam(`rival mire vs {starter}`, team, MAX_LEVEL)
	local playerElement: Types.Element = Species[starter].element
	local leadElement: Types.Element = Species[team.members[1].species].element
	check(
		`rival mire vs {starter}: leads with the counter starter, as in Greenwood`,
		isStarter(team.members[1].species)
			and TypeChart.isStrong(leadElement, playerElement)
			and team.members[1].species == greenwoodRival.gate[starter].members[1].species
	)
	local levelsOk = true
	for _, m in team.members do
		if m.level < 39 or m.level > 40 then
			levelsOk = false
		end
	end
	check(`rival mire vs {starter}: levels 39 to 40, under the gate`, levelsOk)
	check(
		`rival mire vs {starter}: darker than his Tide Flats team, and not yet fully dark`,
		team.tint > tideRivalTeams[starter].tint and team.tint < 1
	)
	local covers = false
	for _, m in team.members do
		for _, name in m.moves do
			if TypeChart.isStrong(Moves[name].element, playerElement) then
				covers = true
			end
		end
	end
	check(`rival mire vs {starter}: carries a move that beats the player's lead`, covers)
	check(`rival mire vs {starter}: one of his creatures poisons`, teamPoisons(team))
	local mireCount = 0
	for _, m in team.members do
		if Species[m.species].biome == BIOME then
			mireCount += 1
		end
	end
	check(`rival mire vs {starter}: he has caught Mire creatures`, mireCount >= 1)
end

local champion = Tamers.story.champion_vell
check("the gate's champion is a story battle", champion ~= nil)
check(
	"she holds the gate, Rival tier, counted as a Gate fight",
	champion.place == mire.gate.id and champion.tier == "Rival" and champion.xpKind == "Gate"
)
check("the champion has one team for everyone", champion.team ~= nil and champion.teams == nil)
do
	local team = champion.team :: WorldTypes.TamerTeam
	checkTeam("champion", team, MAX_LEVEL)
	local gateTop = MAX_LEVEL - ProgressionConfig.GATE_TOP_UNDER_CAP
	local levelsOk, top = true, 0
	for _, m in team.members do
		top = math.max(top, m.level)
		if m.level < gateTop - ProgressionConfig.GATE_TEAM_SPREAD or m.level > gateTop then
			levelsOk = false
		end
	end
	check(
		"the champion's strongest creature is two levels under the player's cap",
		levelsOk and top == gateTop,
		`top {top}`
	)
	check("the champion's team is not tinted", team.tint == 0)
	check(
		"the champion's lines are short and a loss is not free",
		#champion.before <= MAX_LINE and #champion.after <= MAX_LINE and not champion.cannotLose
	)
	local poisoners = 0
	for _, m in team.members do
		for _, name in m.moves do
			if poisons(name) then
				poisoners += 1
				break
			end
		end
	end
	check("the champion fights with poison: at least two poisoners", poisoners >= 2, `{poisoners}`)
	check(
		"her lead poisons, so the lesson comes at once",
		(function(): boolean
			for _, name in team.members[1].moves do
				if poisons(name) then
					return true
				end
			end
			return false
		end)()
	)
	-- The player answers Toxic with Sand (beats Toxic) or Toxic (cannot be poisoned): she covers both.
	local answersSand, answersToxic = false, false
	for _, m in team.members do
		for _, name in m.moves do
			answersSand = answersSand or TypeChart.isStrong(Moves[name].element, "Sand")
			answersToxic = answersToxic or TypeChart.isStrong(Moves[name].element, "Toxic")
		end
	end
	check(
		"she covers the player's answers: a move that beats Sand and one that beats Toxic",
		answersSand and answersToxic
	)
end

-- Rewards -----------------------------------------------------------------------------------

local function checkReward(label: string, reward: WorldTypes.Reward): boolean
	local ok = containsAny(World.REWARD_KINDS, reward.kind)
	if reward.kind == "Coins" or reward.kind == "PrismCandy" then
		ok = ok and reward.amount > 0
	elseif reward.kind == "Item" then
		ok = ok and EconomyConfig.ITEMS[reward.item] ~= nil and reward.count > 0
	elseif reward.kind == "Material" then
		ok = ok
			and containsAny(EconomyConfig.MATERIAL_BY_BIOME, reward.material)
			and reward.count > 0
	elseif reward.kind == "Creature" then
		ok = ok
			and Species[reward.species] ~= nil
			and not Species[reward.species].giantForm
			and Species[reward.species].biome <= BIOME
			and isLevel(reward.level)
			and BreedConfig.COLOURS[reward.colour] ~= nil
			and (reward.rarity == Species[reward.species].baseRarity)
	elseif reward.kind == "Badge" then
		ok = ok and reward.id == mire.gate.badge.id and reward.name == mire.gate.badge.name
	end
	check(label, ok)
	return ok
end

-- Quests ------------------------------------------------------------------------------------

print("\nQuests")
local buildingNames: { string } = {}
for _, building in mire.hub.buildings do
	table.insert(buildingNames, building.name)
end
local beatIds: { [string]: number } = {}
for index, beat in chapter.beats do
	beatIds[beat.id] = index
end

local questCount = #QuestsMire
local lineLength = 0
for _, quest in QuestsMire do
	if not quest.optional then
		lineLength += 1
	end
end
check("four quests in the main line and one optional", lineLength == 4 and questCount == 5)
for _, quest in QuestsMire do
	check(`{quest.id}: registered`, Quests[quest.id] == quest)
	check(
		`{quest.id}: the giver stands at a hub building`,
		contains(buildingNames, quest.giver.place),
		quest.giver.place
	)
	local obj = quest.objective
	local objOk = false
	if obj.kind == "WinWild" then
		objOk = obj.count > 0 and routeById[obj.route] ~= nil
	elseif obj.kind == "TameSpecies" then
		objOk = Species[obj.species] ~= nil and openSeen[obj.species] == true
	elseif obj.kind == "BeatTamer" then
		local tamer = Tamers.locals[obj.tamer]
		objOk = tamer ~= nil and routeById[tamer.route] ~= nil
	elseif obj.kind == "BeatGiant" then
		objOk = Giants[obj.giant] ~= nil and obj.giant == mire.lair.giant
	end
	check(`{quest.id}: objective is something the server can count`, objOk)
	check(
		`{quest.id}: text is short`,
		#quest.offer <= MAX_LINE and #quest.done <= MAX_LINE and #quest.goal <= MAX_LINE
	)
	for index, reward in quest.rewards do
		checkReward(`{quest.id}: reward {index} ({reward.kind}) is valid`, reward)
	end
	check(
		`{quest.id}: requires only earlier quests`,
		(function(): boolean
			for _, id in quest.requires do
				local required = Quests[id]
				if required == nil or required.step >= quest.step then
					return false
				end
			end
			return true
		end)()
	)
	check(
		`{quest.id}: its story flags are beats of chapter 4`,
		(function(): boolean
			for _, flag in quest.requiresFlags do
				if beatIds[flag] == nil then
					return false
				end
			end
			return true
		end)()
	)
end

-- Play the line through.
local done: { [string]: boolean } = {}
local flags: World.Flags = { mire_poison = true }
local order: { string } = {}
local lastQuest: WorldTypes.Quest? = nil
local stuck = false
while not stuck do
	local open = World.availableQuests(QuestsMire, done, flags)
	local nextQuest: WorldTypes.Quest? = nil
	for _, quest in open do
		if not quest.optional then
			nextQuest = quest
			break
		end
	end
	if nextQuest == nil then
		stuck = true
	else
		table.insert(order, nextQuest.id)
		done[nextQuest.id] = true
		lastQuest = nextQuest
	end
end
local expected: { string } = {}
for _, quest in QuestsMire do
	if not quest.optional then
		table.insert(expected, quest.id)
	end
end
check("the quest line completes in order", table.concat(order, ",") == table.concat(expected, ","))
check("nothing is offered before the story flag", #World.availableQuests(QuestsMire, {}, {}) == 0)
local firstOpen = World.availableQuests(QuestsMire, {}, { mire_poison = true })
check(
	"only the first quest is offered at the start",
	#firstOpen == 1 and firstOpen[1].id == expected[1]
)
local finalCreature: string? = nil
if lastQuest ~= nil then
	for _, reward in lastQuest.rewards do
		if reward.kind == "Creature" then
			finalCreature = reward.species
		end
	end
end
check("the line ends in a guaranteed creature", finalCreature ~= nil)
check(
	"that creature is Toxic (it cannot be poisoned) and not met on the open routes",
	finalCreature ~= nil
		and Species[finalCreature].element == BattleConfig.POISON_IMMUNE_ELEMENT
		and openSeen[finalCreature] ~= true,
	finalCreature
)
check(
	"the line asks for a Toxic creature to be tamed, early",
	(function(): boolean
		for _, quest in QuestsMire do
			local obj = quest.objective
			if
				not quest.optional
				and quest.step <= 2
				and obj.kind == "TameSpecies"
				and Species[obj.species].element == BattleConfig.POISON_IMMUNE_ELEMENT
			then
				return true
			end
		end
		return false
	end)()
)
local lineNeedsGiant = false
for _, quest in QuestsMire do
	if not quest.optional and quest.objective.kind == "BeatGiant" then
		lineNeedsGiant = true
	end
end
check("the main line never needs the giant", not lineNeedsGiant)
check(
	"the main line never needs an uncommon species",
	(function(): boolean
		for _, quest in QuestsMire do
			local obj = quest.objective
			if
				not quest.optional
				and obj.kind == "TameSpecies"
				and Species[obj.species].baseRarity ~= "Common"
			then
				return false
			end
		end
		return true
	end)()
)
check(
	"the giant quest is optional and opens once the grove has been seen",
	Quests.mr_sloughback.optional
		and #World.availableQuests(QuestsMire, { mr_first_wade = true }, {
				mire_poison = true,
				grove_sighting = true,
			})
			== 2
)
check(
	"the line's coins and candy follow the economy (biome 4)",
	(function(): boolean
		local coins, candy = 0, 0
		for _, reward in Quests.mr_sluice_pass.rewards do
			if reward.kind == "Coins" then
				coins = reward.amount
			elseif reward.kind == "PrismCandy" then
				candy = reward.amount
			end
		end
		local candyTable = EconomyConfig.QUEST_LINE_CANDY
		return coins == EconomyConfig.QUEST_LINE_COINS * EconomyConfig.ONE_TIME_MULT[BIOME]
			and candy == candyTable[math.min(BIOME, #candyTable)]
	end)()
)
check(
	"no building name repeats one from an earlier biome",
	(function(): boolean
		local others: { [string]: boolean } = {}
		for _, biome in { greenwood, canyon, tide } do
			for _, building in biome.hub.buildings do
				others[building.name] = true
			end
		end
		for _, building in mire.hub.buildings do
			if others[building.name] then
				return false
			end
		end
		return true
	end)()
)

-- Story -------------------------------------------------------------------------------------

print("\nStory")
local earlier: { WorldTypes.Chapter } = { Story.chapter_1, Story.chapter_2, Story.chapter_3 }
local chapter3 = Story.chapter_3
check("chapter 4 is registered", chapter ~= nil and chapter.number == BIOME)
check(
	"the storyline holds all four chapters in order",
	(function(): boolean
		local expectedIds: { string } = {}
		for _, c in earlier do
			for _, beat in c.beats do
				table.insert(expectedIds, beat.id)
			end
		end
		for _, beat in chapter.beats do
			table.insert(expectedIds, beat.id)
		end
		local actual: { string } = {}
		for _, beat in Storyline.beats do
			table.insert(actual, beat.id)
		end
		return table.concat(expectedIds, ",") == table.concat(actual, ",")
	end)()
)
check("between 10 and 12 beats", #chapter.beats >= 10 and #chapter.beats <= 12, `{#chapter.beats}`)

local first = chapter.beats[1]
check(
	"the first beat requires chapter 3's last beat and enters the hub",
	first.trigger.kind == "Enter"
		and first.trigger.target == mire.hub.id
		and contains(first.trigger.requires, "tide_road_on")
		and chapter3.beats[#chapter3.beats].id == "tide_road_on"
)

local npcs: { string } = {}
for _, building in mire.hub.buildings do
	if building.npc ~= nil then
		table.insert(npcs, building.npc)
	end
end
local earlierChapterFlags: { [string]: number } = {}
do
	local index = 0
	for _, c in earlier do
		for _, beat in c.beats do
			index += 1
			earlierChapterFlags[beat.id] = index
		end
	end
end
local chapter3End = chapter3.beats[#chapter3.beats].minuteTo

local ids: { [string]: number } = {}
local previousFrom = chapter3End
local orderOk, reachOk, timeOk, linesOk, lengthOk, kindOk, targetOk =
	true, true, true, true, true, true, true
local speakers: { [string]: boolean } = {}
local winTargets: { string } = {}
local triggerKinds: { [string]: boolean } = {}
for index, beat in chapter.beats do
	if ids[beat.id] ~= nil or earlierChapterFlags[beat.id] ~= nil then
		orderOk = false
	end
	ids[beat.id] = index
	if beat.minuteFrom < previousFrom or beat.minuteTo < beat.minuteFrom then
		timeOk = false
	end
	previousFrom = beat.minuteFrom
	for _, flag in beat.trigger.requires do
		local source = ids[flag]
		if (source == nil or source >= index) and earlierChapterFlags[flag] == nil then
			reachOk = false
		end
	end
	kindOk = kindOk and beat.trigger.kind ~= "Start" and #beat.trigger.requires > 0
	triggerKinds[beat.trigger.kind] = true
	if #beat.lines < 1 or #beat.lines > MAX_LINES then
		linesOk = false
	end
	for _, line in beat.lines do
		speakers[line.speaker] = true
		if #line.text > MAX_LINE or #line.text == 0 then
			lengthOk = false
			print(`    too long ({#line.text}): {beat.id}: {line.text}`)
		end
	end
	local trigger = beat.trigger
	local target = trigger.target
	if trigger.kind == "Enter" or trigger.kind == "Sight" then
		targetOk = targetOk and target ~= nil and contains(places, target)
	elseif trigger.kind == "Win" then
		local battle = if target ~= nil then Tamers.story[target] else nil
		local tamer = if target ~= nil then Tamers.locals[target] else nil
		local real = target ~= nil
			and (
				(battle ~= nil and (battle.place == mire.gate.id or routeOf[battle.place] ~= nil))
				or (tamer ~= nil and routeById[tamer.route] ~= nil)
			)
		targetOk = targetOk and real
		if target ~= nil then
			table.insert(winTargets, target)
		end
	elseif trigger.kind == "Talk" then
		targetOk = targetOk and target ~= nil and contains(npcs, target)
	elseif trigger.kind == "Tame" then
		targetOk = targetOk and target == nil
	end
	for _, reward in beat.grants do
		if not checkReward(`{beat.id}: grant {reward.kind} is valid`, reward) then
			targetOk = false
		end
	end
end
local function beatById(id: string): WorldTypes.Beat
	return chapter.beats[ids[id]]
end
local function said(id: string): string
	local parts: { string } = {}
	for _, line in beatById(id).lines do
		table.insert(parts, line.text)
	end
	return table.concat(parts, " ")
end
check("beat ids are unique, and not an earlier chapter's", orderOk)
check("every trigger is reachable from an earlier beat", reachOk)
check("every beat needs an earlier beat (no Start)", kindOk)
check(
	`timings never go backwards and pick up where chapter 3 ends (minute {chapter3End})`,
	timeOk and first.minuteFrom >= chapter3End
)
check("every beat has one to three lines", linesOk)
check(`no line is over {MAX_LINE} characters`, lengthOk)
check("trigger targets and grants are real", targetOk)
check(
	"it uses only the existing trigger kinds",
	(function(): boolean
		local allowed = {
			Start = true,
			Follow = true,
			Enter = true,
			Sight = true,
			Win = true,
			Tame = true,
			Talk = true,
		}
		for kind in triggerKinds do
			if not (allowed :: { [string]: boolean })[kind] then
				return false
			end
		end
		return true
	end)()
)
check(
	"the story uses the role names Mentor and Rival, and original names for the rest",
	speakers.Mentor == true and speakers.Rival == true
)
check(
	"the beats cover a local tamer, the rival mid-biome and the champion at the gate",
	contains(winTargets, "mr_wren")
		and contains(winTargets, "rival_mire")
		and contains(winTargets, "champion_vell")
)
check(
	"the rival comes before the giant is seen, then the champion at the gate",
	ids.mire_rival < ids.grove_sighting and ids.grove_sighting < ids.mire_gate_challenge
)
check(
	"the healer's beat teaches poison and unlocks it, and it is the second beat",
	ids.mire_poison == 2
		and contains(beatById("mire_poison").unlocks, "poison")
		and beatById("mire_poison").trigger.kind == "Talk"
		and beatById("mire_poison").trigger.target == "ottilie_dunmore"
)
check(
	"the healer says it plainly: poison wears off, Toxic creatures never catch it, the spring mends",
	string.find(said("mire_poison"), "wears off", 1, true) ~= nil
		and string.find(said("mire_poison"), "Toxic creatures never catch it", 1, true) ~= nil
		and string.find(said("mire_poison"), "spring", 1, true) ~= nil
)
check(
	"the gate keeper warns of poison before the gate battle",
	string.find(said("mire_gate_challenge"), "poison", 1, true) ~= nil
)
check(
	"the mentor keeps his promise to come to the Mire, and gives tonics",
	(function(): boolean
		local mentorSpeaks = false
		for _, line in beatById("mentors_visit").lines do
			mentorSpeaks = mentorSpeaks or line.speaker == "Mentor"
		end
		local tonics = false
		for _, reward in beatById("mentors_visit").grants do
			if reward.kind == "Item" and reward.count > 0 then
				tonics = true
			end
		end
		return mentorSpeaks and tonics
	end)()
)
check(
	"the sighting is of the area the lair spur leaves",
	(function(): boolean
		local beat = chapter.beats[ids.grove_sighting]
		local joins = mire.lair.joinsAt
		for _, area in routeById[mire.lair.joinsRoute].areas do
			if area.from <= joins and joins <= area.to then
				return beat.trigger.target == area.id
			end
		end
		return false
	end)()
)
check(
	"the badge beat grants the badge, the economy's coins and candy, and a common creature",
	(function(): boolean
		local gotBadge, gotCreature, coinsOk, candyOk = false, false, false, false
		for _, reward in beatById("mire_badge").grants do
			gotBadge = gotBadge or reward.kind == "Badge"
			if reward.kind == "Creature" then
				gotCreature = Species[reward.species].baseRarity == "Common"
					and reward.level <= MAX_LEVEL
			elseif reward.kind == "Coins" then
				coinsOk = reward.amount
					== math.floor(
						EconomyConfig.TRAINED.Gate.firstClear * EconomyConfig.ONE_TIME_MULT[BIOME]
					)
			elseif reward.kind == "PrismCandy" then
				candyOk = reward.amount == EconomyConfig.CANDY.GateFirstClear.perClaim
			end
		end
		return gotBadge and gotCreature and coinsOk and candyOk
	end)()
)
check(
	"the badge beat wins against the champion at the gate and lifts the cap",
	beatById("mire_badge").trigger.target == mire.gate.battle
		and contains(beatById("mire_badge").unlocks, "level_cap_55")
		and Xp.levelCap(4) == 55
)
local lastBeat = chapter.beats[#chapter.beats]
check(
	"the last beat enters the sealed path and unlocks biome 5",
	lastBeat.trigger.kind == "Enter"
		and lastBeat.trigger.target == mire.gate.sealedPath
		and contains(lastBeat.unlocks, "biome_5")
)

-- Play the chapter through with nextBeat, starting from the earlier chapters' flags.
local storyFlags: World.Flags = {}
for _, c in earlier do
	for _, beat in c.beats do
		storyFlags[beat.id] = true
	end
end
local played: { string } = {}
while true do
	local beat = World.nextBeat(chapter, storyFlags)
	if beat == nil then
		break
	end
	table.insert(played, beat.id)
	storyFlags[beat.id] = true
end
local sameOrder = #played == #chapter.beats
for index, beat in chapter.beats do
	if played[index] ~= beat.id then
		sameOrder = false
	end
end
check("nextBeat plays every beat in order", sameOrder, `{#played} of {#chapter.beats}`)
check(
	"nextBeat waits until chapter 3 has finished",
	World.nextBeat(chapter, {}) == nil
		and World.nextBeat(chapter, { tide_road_on = true }) == chapter.beats[1]
)

-- Walk the whole story, all four chapters, with StoryProgress.complete.
do
	local nextId = 0
	local function newId(): string
		nextId += 1
		return `mire{nextId}`
	end
	local profile = Profile.template()
	local finished = 0
	local choice: string? = "Mossmitt"
	local total = #chapter.beats
	for _, c in earlier do
		total += #c.beats
	end
	while true do
		local beat = World.nextBeat(Storyline, profile.Story.flags)
		if not beat then
			break
		end
		local result = StoryProgress.complete(profile, Storyline, {
			beatId = beat.id,
			choice = choice,
			triggerMet = true,
			newId = newId,
			seed = 11,
			unixTime = 86400 * 300,
		})
		if not result then
			break
		end
		choice = nil
		finished += 1
	end
	check(
		"every beat of all four chapters finishes in order",
		finished == total,
		`{finished} of {total}`
	)
	check(
		"the fourth badge was earned",
		profile.Story.badges == 4 and profile.Story.flags.mire_badge == true
	)
	check(
		"the mentor's visit paid its tonics",
		(profile.Items.GreatTonic or 0) >= 2,
		`{profile.Items.GreatTonic or 0}`
	)
	check(
		"poison is unlocked by the healer's beat",
		World.isUnlocked(
			{ Story.chapter_1, Story.chapter_2, chapter3, chapter },
			profile.Story.flags,
			"poison"
		)
	)
	check(
		"biome 5 is unlocked by the last beat",
		World.isUnlocked(
			{ Story.chapter_1, Story.chapter_2, chapter3, chapter },
			profile.Story.flags,
			"biome_5"
		)
	)
	check(
		"the record is sound",
		#Profile.validate(profile) == 0,
		table.concat(Profile.validate(profile), "; ")
	)
end

-- Wild picker --------------------------------------------------------------------------------

print("\nWild picker")
local SAMPLES = 20000
local TOLERANCE = 0.03
local function share(
	route: WorldTypes.Route,
	options: World.PickOptions?,
	samples: number
): ({ [string]: number }, number)
	local counts: { [string]: number } = {}
	local levelBad = 0
	for index = 1, samples do
		local pick = World.pickWild(route, index * 2654435761 % 2147483629 + index, options)
		local species = pick.creature.parts.Head.species
		counts[species] = (counts[species] or 0) + 1
		if
			pick.creature.level < pick.entry.minLevel
			or pick.creature.level > pick.entry.maxLevel
		then
			levelBad += 1
		end
	end
	return counts, levelBad
end
for _, route in mire.routes do
	local counts, levelBad = share(route, nil, SAMPLES)
	local total = 0
	local bySpecies: { [string]: number } = {}
	for _, entry in World.candidates(route, nil) do
		total += entry.weight
		bySpecies[entry.species] = (bySpecies[entry.species] or 0) + entry.weight
	end
	local worst = 0
	for species, weight in bySpecies do
		worst = math.max(worst, math.abs((counts[species] or 0) / SAMPLES - weight / total))
	end
	check(
		`{route.id}: species shares match the weights`,
		worst <= TOLERANCE,
		`worst gap {string.format("%.1f", worst * 100)} points`
	)
	check(`{route.id}: drawn levels stay in the row's range`, levelBad == 0)
	local openUncommon = false
	for species in counts do
		if Species[species].baseRarity ~= "Common" then
			openUncommon = true
		end
	end
	check(`{route.id}: an open draw never gives an uncommon species`, not openUncommon)
	for _, spot in route.rustleSpots do
		local spotCounts = share(route, { spot = spot.id }, 4000)
		local uncommonShare = 0
		for species, count in spotCounts do
			if Species[species].baseRarity ~= "Common" then
				uncommonShare += count / 4000
			end
		end
		check(
			`{spot.id}: a rustle gives an uncommon species about half the time or more`,
			uncommonShare >= 0.4,
			string.format("%.0f%%", uncommonShare * 100)
		)
	end
end

-- Unique ids across all four biomes ---------------------------------------------------------------

print("\nUnique ids across Greenwood, Dust Canyon, Tide Flats and the Mire")
do
	local biomes: { WorldTypes.Biome } = { greenwood, canyon, tide, mire }
	local function unique(label: string, lists: { { string } })
		local seenId: { [string]: boolean } = {}
		local duplicate: string? = nil
		local count = 0
		for _, list in lists do
			for _, id in list do
				count += 1
				if seenId[id] then
					duplicate = id
				end
				seenId[id] = true
			end
		end
		check(`{label} are unique`, duplicate == nil, duplicate or `{count} ids`)
	end

	local mapPlaces: { { string } } = {}
	local dataPlaces: { { string } } = {}
	local npcLists: { { string } } = {}
	local tamerIds: { { string } } = {}
	for _, biome in biomes do
		local map = Layout.build(biome, Tamers.locals)
		local keys: { string } = {}
		for id in map.places do
			table.insert(keys, id)
		end
		table.insert(mapPlaces, keys)

		local data: { string } =
			{ biome.hub.id, biome.lair.id, biome.gate.id, biome.gate.sealedPath }
		local npcList: { string } = {}
		for _, building in biome.hub.buildings do
			table.insert(data, building.id)
			if building.npc ~= nil then
				table.insert(data, building.npc)
				table.insert(npcList, building.npc)
			end
		end
		local tamerList: { string } = {}
		for _, route in biome.routes do
			table.insert(data, route.id)
			table.insert(data, Layout.grassId(route.id))
			for _, area in route.areas do
				table.insert(data, area.id)
				table.insert(data, Layout.grassId(area.id))
			end
			for _, spot in route.rustleSpots do
				table.insert(data, spot.id)
			end
			for _, id in route.tamers do
				table.insert(data, id)
				table.insert(tamerList, id)
			end
		end
		table.insert(data, Layout.stallId(biome))
		table.insert(dataPlaces, data)
		table.insert(npcLists, npcList)
		table.insert(tamerIds, tamerList)
	end
	unique("place ids on the four maps", mapPlaces)
	unique("place, building, area, spot and character ids in the data", dataPlaces)
	unique("npc ids", npcLists)
	unique("local tamer ids", tamerIds)
	check(
		"every local tamer is on a route of exactly one biome",
		(function(): boolean
			local count = 0
			for _ in Tamers.locals do
				count += 1
			end
			local listed = 0
			for _, list in tamerIds do
				listed += #list
			end
			return count == listed
		end)()
	)

	local storyIds: { string } = {}
	for id in Tamers.story do
		table.insert(storyIds, id)
	end
	local localIds: { string } = {}
	for id in Tamers.locals do
		table.insert(localIds, id)
	end
	unique("story battle ids and local tamer ids together", { storyIds, localIds })
	check(
		"every story battle stands at a real place of its own biome",
		(function(): boolean
			for _, battle in Tamers.story do
				local found = false
				for _, biome in biomes do
					local map = Layout.build(biome, Tamers.locals)
					if map.places[battle.place] ~= nil then
						found = true
					end
				end
				if not found then
					return false
				end
			end
			return true
		end)()
	)

	local questIds: { string } = {}
	for _, list in
		{
			require("../src/content/quests/Greenwood"),
			require("../src/content/quests/DustCanyon"),
			require("../src/content/quests/TideFlats"),
			QuestsMire,
		}
	do
		for _, quest in list do
			table.insert(questIds, quest.id)
		end
	end
	unique("quest ids", { questIds })
	local questCountInRegistry = 0
	for _ in Quests do
		questCountInRegistry += 1
	end
	check("every quest is in the registry once", questCountInRegistry == #questIds)

	local beatList: { string } = {}
	for _, beat in Storyline.beats do
		table.insert(beatList, beat.id)
	end
	unique("beat ids across all four chapters", { beatList })
	local crossed: { string } = {}
	for _, id in beatList do
		for _, other in { storyIds, localIds, questIds } do
			if table.find(other, id) then
				table.insert(crossed, id)
			end
		end
	end
	check(
		"no beat id doubles as a battle, tamer or quest id",
		#crossed == 0,
		table.concat(crossed, ",")
	)
	local giantCount = 0
	for _ in Giants do
		giantCount += 1
	end
	check("one giant for each of the four biomes", giantCount == 4, `{giantCount}`)
end

-- The giant -----------------------------------------------------------------------------------

print("\nThe giant as data")
local WEAK = GiantBattle.weakTypes(giant.element)
do
	local problems = GiantBattle.validate(giant)
	check("Sloughback validates", #problems == 0, table.concat(problems, "; "))
	check("it is in the registry by id", Giants[giant.id] == giant)
	check(
		"it is a Toxic giant one level over the cap with three badges",
		giant.element == "Toxic" and giant.level == MAX_LEVEL + 1
	)
	local thresholds: { number } = {}
	for _, phase in giant.phases do
		table.insert(thresholds, phase.enterAt)
	end
	check(
		"three phases at 100%, 60% and 25%, matching the config",
		#thresholds == 3
			and table.concat(thresholds, ",") == table.concat(GiantConfig.PHASE_THRESHOLDS, ",")
	)
	local windUps, interruptible, halves, cancels = 0, true, 0, 0
	for _, attack in giant.attacks do
		if attack.windUp then
			windUps += 1
			interruptible = interruptible and attack.whenInterrupted ~= nil
			if attack.whenInterrupted == "Halve" then
				halves += 1
			elseif attack.whenInterrupted == "Cancel" then
				cancels += 1
			end
		end
	end
	check(
		"it has wind-ups that the right type cancels or halves",
		windUps >= 1 and interruptible and halves + cancels == windUps
	)
	check(
		"the giant is weak to Sand and Frost",
		#WEAK == 2 and table.find(WEAK, "Sand") ~= nil and table.find(WEAK, "Frost") ~= nil
	)
	check(
		"every phase has a wind-up (no free damage race)",
		(function(): boolean
			for _, phase in giant.phases do
				local has = false
				for _, id in phase.pattern do
					has = has or giant.attacks[id].windUp
				end
				if not has then
					return false
				end
			end
			return true
		end)()
	)
	check(
		"the long fog: Fume Drift seeps over the whole team in every phase, twice a cycle in the last",
		(function(): boolean
			for index, phase in giant.phases do
				local drifts = 0
				for _, id in phase.pattern do
					local attack = giant.attacks[id]
					if attack.target == "Team" and not attack.windUp then
						drifts += 1
					end
				end
				if drifts < 1 or (index == #giant.phases and drifts < 2) then
					return false
				end
			end
			return true
		end)()
	)
	check(
		"team-wide attacks are at least a third of every phase's pattern",
		(function(): boolean
			for _, phase in giant.phases do
				local teamWide = 0
				for _, id in phase.pattern do
					if giant.attacks[id].target == "Team" then
						teamWide += 1
					end
				end
				if teamWide * 3 < #phase.pattern then
					return false
				end
			end
			return true
		end)()
	)
	check(
		"one wave is cancelled outright (on one creature) and one is halved (on the team)",
		(function(): boolean
			local cancelFront, halveTeam = false, false
			for _, attack in giant.attacks do
				if
					attack.windUp
					and attack.whenInterrupted == "Cancel"
					and attack.target == "Front"
				then
					cancelFront = true
				end
				if
					attack.windUp
					and attack.whenInterrupted == "Halve"
					and attack.target == "Team"
				then
					halveTeam = true
				end
			end
			return cancelFront and halveTeam
		end)()
	)
	check(
		"every stopper has an attack aimed at it: Sand stoppers, and Frost carriers' Water bodies",
		(function(): boolean
			-- Frost moves come only on Water torsos (docs/content/MIRE_ROSTER.md), so a Frost stopper
			-- is a Water creature.
			local frostBodies: { Types.Element } = {}
			local onTorsosOnly = true
			for _, def in Species do
				for _, slot: Types.Slot in BreedConfig.SLOTS do
					for _, unlock in def.parts[slot].moves do
						if Moves[unlock.name].element == "Frost" then
							onTorsosOnly = onTorsosOnly and slot == "Torso"
							if not table.find(frostBodies, def.element) then
								table.insert(frostBodies, def.element)
							end
						end
					end
				end
			end
			local function aimedAt(element: Types.Element): boolean
				for _, attack in giant.attacks do
					if TypeChart.isStrong(attack.element, element) then
						return true
					end
				end
				return false
			end
			local hitsFrostBodies = #frostBodies > 0
			for _, body: Types.Element in frostBodies do
				hitsFrostBodies = hitsFrostBodies and aimedAt(body)
			end
			return aimedAt("Sand") and onTorsosOnly and hitsFrostBodies
		end)()
	)
	check(
		"its own-type fumes hit Water creatures hardest, Sand least, Toxic at the plain rate",
		TypeChart.multiplier("Toxic", "Water") > 1
			and TypeChart.multiplier("Toxic", "Sand") < 1
			and TypeChart.multiplier("Toxic", "Toxic") == 1
	)
	check(
		"it enrages, and later than the fastest fights",
		giant.enrage ~= nil and giant.enrage.startTurn >= 25 and giant.enrage.step > 0
	)
	check(
		"every attack of the giant's fight is a real element",
		(function(): boolean
			for _, attack in giant.attacks do
				if not containsAny(TypeChart.ELEMENTS, attack.element) then
					return false
				end
			end
			return true
		end)()
	)

	-- the giant's creature form
	local form = assert(giant.form, "Sloughback has a creature form")
	local def = Species[form.species]
	check(
		"the form is its own species, marked as a giant's form, of the Mire",
		def ~= nil and def.giantForm == true and form.species == "Sloughback" and def.biome == BIOME
	)
	check(
		"the form is gem-tier at the giant's level, size 1.3, in a known colour",
		form.rarity == "Gem"
			and form.level == giant.level
			and form.size == 1.3
			and BreedConfig.COLOURS[form.colour] ~= nil
	)
	check("the form is Toxic, like the giant", def.element == giant.element)
	local budget = 0
	local slots: { Types.Slot } = BreedConfig.SLOTS
	for _, slot: Types.Slot in slots do
		for stat, value in def.parts[slot].stats :: { [string]: number } do
			budget += value * (if stat == "Hp" then BreedConfig.BUDGET_HP_WEIGHT else 1)
		end
	end
	check(
		"its parts cost exactly the plan budget",
		math.abs(budget - BreedConfig.PLAN_BUDGET[def.bodyPlan]) < 0.01,
		`{budget}`
	)
	local movesOk = true
	for _, slot: Types.Slot in slots do
		for _, unlock in def.parts[slot].moves do
			movesOk = movesOk and Moves[unlock.name] ~= nil and unlock.level <= form.level
		end
	end
	check("every move it knows exists and is known at its level", movesOk)
	local signature = { "Marsh Gas", "Sinking Pull" }
	local ownsBoth = 0
	for _, slot: Types.Slot in slots do
		for _, unlock in def.parts[slot].moves do
			if table.find(signature, unlock.name) then
				ownsBoth += 1
			end
		end
	end
	check("it carries both signature moves", ownsBoth == 2)
	local belongsToNothingElse = true
	for name, other in Species do
		if name ~= form.species then
			for _, slot: Types.Slot in slots do
				for _, unlock in other.parts[slot].moves do
					if table.find(signature, unlock.name) then
						belongsToNothingElse = false
					end
				end
			end
		end
	end
	check("its two signature moves belong to nothing else", belongsToNothingElse)
	check(
		"neither signature move poisons, and one answers the Sand creatures that beat it",
		not poisons("Marsh Gas")
			and not poisons("Sinking Pull")
			and TypeChart.isStrong(Moves["Sinking Pull"].element, "Sand")
	)
end

------------------------------------------------------------------------------------------------
-- Fights

local POTION: GiantBattle.ItemEffect = { kind = "Heal", share = 0.4 }
local REVIVE: GiantBattle.ItemEffect = { kind = "Revive", share = 0.5 }

local function hasWeakMove(fighter: Fighter): boolean
	for _, name in fighter.moves do
		if TypeChart.isStrong(Moves[name].element, giant.element) then
			return true
		end
	end
	return false
end

local function weakMoveOf(state: State, fighter: Fighter): string?
	local best, bestDamage = nil, -1
	for _, name in fighter.moves do
		if TypeChart.isStrong(Moves[name].element, state.giant.element) then
			local damage = Battle.previewDamage(fighter, state.boss, name)
			if damage > bestDamage then
				best, bestDamage = name, damage
			end
		end
	end
	return best
end

local function logText(state: State): string
	local lines: { string } = {}
	for _, event in state.log do
		table.insert(lines, `{event.turn}:{event.text}`)
	end
	return table.concat(lines, "|")
end

-- A copy of the giant that a test can change without touching the real data.
local function variant(def: GiantDef, edit: (GiantDef) -> ()): GiantDef
	local attacks: { [string]: GiantBattle.GiantAttack } = {}
	for id, attack in def.attacks do
		attacks[id] = table.clone(attack)
	end
	local phases: { GiantBattle.Phase } = {}
	for _, phase in def.phases do
		local copy = table.clone(phase)
		copy.pattern = table.clone(phase.pattern)
		table.insert(phases, copy)
	end
	local copy = table.clone(def)
	copy.stats = table.clone(def.stats)
	copy.attacks = attacks
	copy.phases = phases
	edit(copy)
	return copy
end

local ROSTER: { string } = {}
for name, def in Species do
	if def.biome <= BIOME and not def.giantForm then
		table.insert(ROSTER, name)
	end
end
table.sort(ROSTER)

-- A team of four from the 32 wild species of the four biomes, each with wild part qualities.
-- "any": whoever is drawn. "counter": a team whose best four moves include Sand or Frost (the types
-- Sloughback is weak to), drawn again until one does. "plain": any team with every such move taken
-- away. The creatures are not placed to suit the fight: the first one drawn leads.
local function realTeam(level: number, mode: string, seed: number): { Fighter }
	local rng = Rng.new(seed)
	while true do
		local team: { Fighter } = {}
		local brings = false
		for index = 1, TEAM do
			local c: Types.Creature
			local moves: { string }? = nil
			while true do
				local name = Rng.pick(rng, ROSTER)
				c = Breeding.wild(name, `{name}{index}`, level, "Common", "Moss", rng)
				if mode ~= "plain" then
					break
				end
				local pool: { string } = {}
				for _, candidate in Stats.movePool(c, level) do
					if not table.find(WEAK, Moves[candidate].element) then
						table.insert(pool, candidate)
					end
				end
				-- A creature whose every move is Sand or Frost has nothing left to fight with, so a
				-- "plain" team is drawn from the species that keep a move.
				if #pool > 0 then
					moves = pool
					break
				end
			end
			local fighter = Battle.fighter(c, moves, level)
			brings = brings or hasWeakMove(fighter)
			table.insert(team, fighter)
		end
		if mode == "any" or (mode == "counter") == brings then
			return team
		end
	end
end

-- A simple, sensible player: best move; switch out a creature that is about to faint when a healthier
-- one exists; heal when low while items remain; revive when two or fewer stand.
local function basePolicy(state: State): Action
	local me = state.team[state.active]
	if GiantBattle.itemsLeft(state) > 0 then
		if me.hp / me.stats.Hp < 0.35 then
			return { kind = "Item", name = "Potion", effect = POTION, target = state.active }
		end
		local standing, fainted = 0, nil
		for index, fighter in state.team do
			if fighter.hp > 0 then
				standing += 1
			elseif not fainted then
				fainted = index
			end
		end
		if fainted and standing <= 2 and me.hp / me.stats.Hp > 0.5 then
			return { kind = "Item", name = "Revive herb", effect = REVIVE, target = fainted }
		end
	end
	local intent = state.intent
	if intent.kind ~= "WindUp" then
		local incoming = GiantBattle.previewAttack(state, intent.attack, me)
		if incoming >= me.hp then
			local bestIndex, bestShare = nil, 0
			for index, fighter in state.team do
				local healthShare = fighter.hp / fighter.stats.Hp
				local survives = GiantBattle.previewAttack(state, intent.attack, fighter)
					< fighter.hp
				if index ~= state.active and survives and healthShare > bestShare then
					bestIndex, bestShare = index, healthShare
				end
			end
			if bestIndex then
				return { kind = "Switch", to = bestIndex }
			end
		end
	end
	return GiantBattle.bestMove(state)
end

-- The same player who also reads the shown intent: on the turn the giant only charges (nothing lands),
-- swap to a healthy creature that carries a Sand or Frost move; on the turn the charge is released,
-- hit with it.
local function stopPolicy(state: State): Action
	local me = state.team[state.active]
	local intent = state.intent
	if intent.kind == "WindUp" and weakMoveOf(state, me) == nil then
		local bestIndex, bestDamage = nil, -1
		for index, fighter in state.team do
			local move = weakMoveOf(state, fighter)
			if index ~= state.active and fighter.hp / fighter.stats.Hp > 0.3 and move ~= nil then
				local damage = Battle.previewDamage(fighter, state.boss, move)
				if damage > bestDamage then
					bestIndex, bestDamage = index, damage
				end
			end
		end
		if bestIndex then
			return { kind = "Switch", to = bestIndex }
		end
	elseif intent.kind == "Release" then
		local move = weakMoveOf(state, me)
		if move ~= nil then
			return { kind = "Move", move = move }
		end
	end
	return basePolicy(state)
end

local function play(
	def: GiantDef,
	team: { Fighter },
	seed: number,
	policy: (State) -> Action
): State
	local state = GiantBattle.new(def, team, seed)
	while not state.winner do
		GiantBattle.step(state, policy(state))
	end
	return state
end

local function move(name: string): Action
	return { kind = "Move", move = name }
end

local function sturdy(team: { Fighter }): { Fighter }
	for _, fighter in team do
		fighter.stats.Hp = 1000000
		fighter.hp = 1000000
	end
	return team
end

-- A one-creature fighter with chosen moves, for the weak-point checks.
local function fighterWith(species: string, level: number, moves: { string }): Fighter
	local c = Breeding.wild(species, species, level, "Common", "Moss", Rng.new(3))
	return Battle.fighter(c, moves, level)
end

local function total(state: State): number
	local sum = 0
	for _, f in state.team do
		sum += f.hp
	end
	return sum
end

print("\nThe wind-ups")
do
	-- The giant charges on turn 1 (nothing lands), so a swap on that turn is free; `swapTo` picks who
	-- stands in front for the release on turn 2.
	local function toRelease(id: string, swapTo: number?): State
		local state = GiantBattle.new(
			variant(giant, function(d)
				d.stats.Hp = 10000000
				d.phases[1].pattern = { id }
			end),
			sturdy({
				fighterWith("Fenwhisk", 44, { "Fen Lash", "Slick Dash" }),
				fighterWith("Cocklemole", 44, { "Burrow Burst", "Shell Grind" }),
				fighterWith("Lilyshade", 44, { "Hoarmist", "Still Water" }),
				fighterWith("Mossmitt", 44, { "Thorn Volley", "Seed Shot" }),
			}),
			5
		)
		if swapTo ~= nil then
			GiantBattle.step(state, { kind = "Switch", to = swapTo })
		else
			GiantBattle.step(state, move("Slick Dash"))
		end
		return state
	end

	local pull = toRelease("pull", nil)
	check("the release turn follows the charge", pull.intent.kind == "Release")
	local before = total(pull)
	GiantBattle.step(pull, move("Fen Lash"))
	check("Sinking Pull lands in full when nothing stops it", before - total(pull) > 0)

	local cancelled = toRelease("pull", 2)
	local cancelledBefore = total(cancelled)
	GiantBattle.step(cancelled, move("Burrow Burst"))
	check(
		"a Sand hit on the charged turn cancels Sinking Pull",
		total(cancelled) == cancelledBefore
			and string.find(logText(cancelled), "is stopped", 1, true) ~= nil
	)

	local frost = toRelease("pull", 3)
	local frostBefore = total(frost)
	GiantBattle.step(frost, move("Hoarmist"))
	check("a Frost hit (Hoarmist) cancels it too", total(frost) == frostBefore)

	local toxic = toRelease("pull", nil)
	local toxicBefore = total(toxic)
	GiantBattle.step(toxic, move("Fen Lash"))
	check("a Toxic hit does not", toxicBefore - total(toxic) > 0)

	local leaf = toRelease("pull", 4)
	local leafBefore = total(leaf)
	GiantBattle.step(leaf, move("Thorn Volley"))
	check("nor does a Leaf hit", leafBefore - total(leaf) > 0)

	-- Marsh Gas is halved, not cancelled.
	local halved = toRelease("gas", 2)
	local raw = 0
	for _, f in halved.team do
		raw += GiantBattle.previewAttack(halved, "gas", f)
	end
	local halvedBefore = total(halved)
	GiantBattle.step(halved, move("Burrow Burst"))
	local halvedLoss = halvedBefore - total(halved)
	local full = toRelease("gas", nil)
	local fullBefore = total(full)
	GiantBattle.step(full, move("Fen Lash"))
	local fullLoss = fullBefore - total(full)
	check(
		"a Sand or Frost hit halves Marsh Gas",
		halvedLoss > 0 and halvedLoss < fullLoss * 0.6 and halvedLoss > fullLoss * 0.4,
		`{halvedLoss} against {fullLoss}`
	)
	check("the gas hits every creature standing", raw > 0 and fullLoss >= raw * 0.9 - 4)

	-- Swapping never dodges the fumes: the drift reaches the bench as well as the front.
	local drift = GiantBattle.new(
		variant(giant, function(d)
			d.stats.Hp = 10000000
			d.phases[1].pattern = { "drift" }
		end),
		sturdy({
			fighterWith("Fenwhisk", 44, { "Fen Lash" }),
			fighterWith("Cocklemole", 44, { "Burrow Burst" }),
			fighterWith("Lilyshade", 44, { "Hoarmist" }),
			fighterWith("Mossmitt", 44, { "Thorn Volley" }),
		}),
		5
	)
	local hpBefore: { number } = {}
	for index, f in drift.team do
		hpBefore[index] = f.hp
	end
	GiantBattle.step(drift, { kind = "Switch", to = 2 })
	local allHit = true
	for index, f in drift.team do
		allHit = allHit and f.hp < hpBefore[index]
	end
	check("swapping never dodges Fume Drift: it reaches every creature", allHit)
	local water = GiantBattle.previewAttack(drift, "drift", drift.team[3])
	local sand = GiantBattle.previewAttack(drift, "drift", drift.team[2])
	local toxicHit = GiantBattle.previewAttack(drift, "drift", drift.team[1])
	check(
		"the fumes hurt a Water creature more than a Toxic one, and a Toxic one more than a Sand one",
		water > toxicHit and toxicHit > sand,
		`Water {water}, Toxic {toxicHit}, Sand {sand}`
	)
end

print("\nPoison and the giant (giants never poison and are never poisoned)")
do
	local state = GiantBattle.new(
		variant(giant, function(d)
			d.stats.Hp = 10000000
			d.phases[1].pattern = { "drift" }
		end),
		sturdy({ fighterWith("Fenwhisk", 44, { "Venom Nip", "Fen Lash" }) }),
		9
	)
	local logged = 0
	for _ = 1, 4 do
		local hpBefore = state.boss.hp
		GiantBattle.step(state, move("Venom Nip"))
		logged += hpBefore - state.boss.hp
	end
	local uses = 0
	for _, event in state.log do
		local amount = string.match(event.text, "uses Venom Nip for (%d+)")
		if amount then
			uses += tonumber(amount) or 0
		end
	end
	check(
		"a poisoning move hurts the giant by its hit alone, with no poison afterwards",
		logged == uses and (state.boss.poison or 0) == 0,
		`{logged} against {uses}`
	)
	local fight = play(giant, realTeam(44, "any", 4), 4, basePolicy)
	local clean = true
	for _, f in fight.team do
		clean = clean and (f.poison or 0) == 0
	end
	check("a whole fight leaves no creature poisoned", clean)
end

print("\nIntents, replay and the end of the fight")
do
	local team = function(): { Fighter }
		return realTeam(44, "any", 11)
	end
	local a = play(giant, team(), 42, basePolicy)
	local b = GiantBattle.replay(giant, team, 42, a.history)
	check(
		"the same seed and actions replay the same fight",
		logText(a) == logText(b) and a.winner == b.winner and a.turn == b.turn
	)
	local over = variant(giant, function(d)
		d.stats.Hp = 10000000
	end)
	local state = GiantBattle.new(over, sturdy(realTeam(44, "plain", 9)), 7)
	local kinds: { [string]: boolean } = {}
	local textOk = true
	for _ = 1, 40 do
		kinds[state.intent.kind] = true
		textOk = textOk and #state.intent.text > 0
		GiantBattle.step(state, GiantBattle.bestMove(state))
	end
	check(
		"intents cover attacks, wind-ups and releases, each with text",
		kinds.Attack and kinds.WindUp and kinds.Release and textOk
	)
	local bounded = true
	for seed = 1, 40 do
		local s = play(
			giant,
			realTeam(38 + seed % 8, if seed % 2 == 0 then "plain" else "any", seed),
			seed,
			basePolicy
		)
		bounded = bounded and s.winner ~= nil and s.turn <= GiantConfig.MAX_TURNS
	end
	check("forty varied fights all end", bounded)
	local early = GiantBattle.new(giant, realTeam(44, "any", 2), 1)
	early.turn = ENRAGE.startTurn - 2
	local atBefore = GiantBattle.previewAttack(early, "slam", early.team[1])
	early.turn = ENRAGE.startTurn + 2
	check(
		"the enrage raises its damage once it begins",
		GiantBattle.previewAttack(early, "slam", early.team[1]) > atBefore
	)
end

print("\nBalance: Sloughback against teams of four from the real rosters of all four biomes")
local SEEDS = 300
type Row = { win: number, turns: number, winTurns: number, enrage: number, items: number }
local function measure(level: number, mode: string, policy: (State) -> Action): Row
	local wins, turnsAll, turnsWon, enrage, items = 0, 0, 0, 0, 0
	for seed = 1, SEEDS do
		local state = play(giant, realTeam(level, mode, seed), seed * 7919, policy)
		turnsAll += state.turn
		items += state.itemsUsed
		if state.turn >= ENRAGE.startTurn then
			enrage += 1
		end
		if state.winner == "Player" then
			wins += 1
			turnsWon += state.turn
		end
	end
	return {
		win = wins / SEEDS,
		turns = turnsAll / SEEDS,
		winTurns = if wins > 0 then turnsWon / wins else 0,
		enrage = enrage / SEEDS,
		items = items / SEEDS,
	}
end
local function pct(x: number): string
	return string.format("%.0f%%", x * 100)
end

local rows: { [string]: Row } = {}
local anyBase: { [number]: number } = {}
local anyStop: { [number]: number } = {}
for _, level in { 42, 44, 45 } do
	local parts: { string } = {}
	for _, mode in { "any", "counter", "plain" } do
		for _, name in { "base", "stop" } do
			local row = measure(level, mode, if name == "base" then basePolicy else stopPolicy)
			rows[`{mode}_{name}_{level}`] = row
			table.insert(
				parts,
				`{mode}/{name} {string.format("%3.0f", row.win * 100)}% ({string.format(
					"%.1f",
					row.turns
				)} turns, enrage {pct(row.enrage)})`
			)
			if mode == "any" then
				if name == "base" then
					anyBase[level] = row.win
				else
					anyStop[level] = row.win
				end
			end
		end
	end
	print(`  level {level}: {table.concat(parts, "  |  ")}`)
end
print(
	`  (policies: base = best move, switch when about to faint, heal when low, five items; stop = the same, plus swap to a Sand or Frost creature on the wind-up turn and hit with it on the release; {SEEDS} seeded teams of four per row)`
)

local mid = rows.any_base_44
check(
	"an on-level team (44) with sensible play wins 35 to 65%",
	mid.win >= 0.35 and mid.win <= 0.65,
	pct(mid.win)
)
check(
	"across levels 42 to 45 sensible play wins 30 to 70%",
	anyBase[42] >= 0.30 and anyBase[45] <= 0.70,
	`{pct(anyBase[42])} to {pct(anyBase[45])}`
)
check(
	"a higher level does better than a lower one",
	anyBase[42] <= anyBase[44] and anyBase[44] <= anyBase[45] and anyStop[42] <= anyStop[45]
)
check(
	"bringing Sand or Frost helps clearly at level 44",
	rows.counter_base_44.win - rows.plain_base_44.win >= 0.3,
	`{pct(rows.counter_base_44.win)} against {pct(rows.plain_base_44.win)}`
)
check(
	"and stopping the wind-ups as well helps clearly more",
	rows.counter_stop_44.win >= rows.counter_base_44.win + 0.08
		and rows.counter_stop_44.win >= mid.win + 0.2,
	`{pct(rows.counter_stop_44.win)} against {pct(mid.win)}`
)
check(
	"a team with no Sand or Frost move rarely wins (this giant needs a stopper)",
	rows.plain_base_44.win <= 0.3,
	pct(rows.plain_base_44.win)
)
check(
	"a win takes roughly 15 to 25 turns",
	mid.winTurns >= 15 and mid.winTurns <= 25,
	string.format("%.1f", mid.winTurns)
)
check(
	"the fight rarely reaches the enrage turn",
	mid.enrage <= 0.05 and rows.counter_stop_44.enrage <= 0.05,
	pct(mid.enrage)
)

-- A creature should survive more than one of the giant's big hits (in the last phase, whose hits
-- are the hardest), and a tank more than a neutral one.
print("  Hits of the giant a level 44 creature survives from full health (quality 5):")
do
	local state = GiantBattle.new(giant, realTeam(44, "any", 1), 1)
	state.phase = #giant.phases
	local rng = Rng.new(5)
	local parts: { string } = {}
	local worst, best, bestName = math.huge, 0, ""
	for _, name in ROSTER do
		local c = Breeding.wild(name, name, 44, "Common", "Moss", rng)
		for _, slot: Types.Slot in BreedConfig.SLOTS do
			c.parts[slot].quality = 5
		end
		local fighter = Battle.fighter(c, nil, 44)
		local big = 0
		for id, attack in giant.attacks do
			if attack.target == "Front" then
				big = math.max(big, GiantBattle.previewAttack(state, id, fighter))
			end
		end
		local hits = fighter.stats.Hp / big
		worst = math.min(worst, hits)
		if hits > best then
			best, bestName = hits, name
		end
		table.insert(
			parts,
			`{name} ({fighter.element}, Def {fighter.stats.Defence}) {string.format("%.1f", hits)}`
		)
	end
	print(`    {table.concat(parts, "; ")}`)
	check(
		"every creature survives at least a hit and a third of the biggest hit from full health",
		worst >= 1.3,
		string.format("%.1f", worst)
	)
	check(
		"the sturdiest survives about two of them",
		best >= 2,
		`{bestName} {string.format("%.1f", best)}`
	)
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error(`{failed} test(s) failed`)
end
