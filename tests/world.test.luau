--!strict
-- Checks on Greenwood's world data and the helpers in World. Run from the project folder:
--   lune run tests/world.test

local BattleAi = require("../src/shared/BattleAi")
local BreedConfig = require("../src/config/BreedConfig")
local Biomes = require("../src/content/Biomes")
local Breeding = require("../src/shared/Breeding")
local EconomyConfig = require("../src/config/EconomyConfig")
local Giants = require("../src/content/Giants")
local Moves = require("../src/content/Moves")
local ProgressionConfig = require("../src/config/ProgressionConfig")
local Quests = require("../src/content/Quests")
local QuestsGreenwood = require("../src/content/quests/Greenwood")
local Rng = require("../src/shared/Rng")
local Species = require("../src/content/Species")
local Stats = require("../src/shared/Stats")
local Story = require("../src/content/Story")
local Tamers = require("../src/content/Tamers")
local TypeChart = require("../src/shared/TypeChart")
local Types = require("../src/shared/Types")
local World = require("../src/shared/World")
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

local MAX_LEVEL = ProgressionConfig.CAP_BASE -- the cap before the first badge
local MAX_LINE = 90
local MAX_LINES = 3

local greenwood = Biomes.greenwood
local chapter = Story.chapter_1

local function isPositiveLevel(level: number): boolean
	return level >= 1 and level <= MAX_LEVEL and level == math.floor(level)
end

local function contains(list: { string }, value: string): boolean
	return table.find(list, value) ~= nil
end

local function containsAny(list: { any }, value: any): boolean
	return table.find(list, value) ~= nil
end

-- Places that exist, for checking triggers and objectives.
local places: { string } =
	{ greenwood.hub.id, greenwood.lair.id, greenwood.gate.id, greenwood.gate.sealedPath }
local routeById: { [string]: WorldTypes.Route } = {}
for _, route in greenwood.routes do
	table.insert(places, route.id)
	routeById[route.id] = route
	for _, area in route.areas do
		table.insert(places, area.id)
	end
end

print("Biome data")
check("the registry holds Greenwood", greenwood ~= nil and greenwood.number == 1)
check("two routes", #greenwood.routes == 2)
check("the lair's giant exists", Giants[greenwood.lair.giant] ~= nil)
check("the lair leaves a real route", routeById[greenwood.lair.joinsRoute] ~= nil)
check("the gate ends a real route", routeById[greenwood.gate.route] ~= nil)
check(
	"the gate's recommended levels are 12 to 15",
	greenwood.gate.recommendedMin == 12 and greenwood.gate.recommendedMax == 15
)

local seen: { [string]: boolean } = {}
local openSeen: { [string]: boolean } = {}
local lowest, highest = 99, 0
for _, route in greenwood.routes do
	local nonEmpty = #route.spawns > 0
	check(`{route.id}: spawn table is not empty`, nonEmpty)

	local spots: { [string]: boolean } = {}
	for _, spot in route.rustleSpots do
		spots[spot.id] = true
		check(
			`{spot.id}: rustle spot sits on a real area`,
			contains(
				(function()
					local ids: { string } = {}
					for _, a in route.areas do
						table.insert(ids, a.id)
					end
					return ids
				end)(),
				spot.area
			)
		)
		check(`{spot.id}: rustle spot is on the route`, spot.at >= 0 and spot.at <= route.length)
	end

	local areaById: { [string]: WorldTypes.Area } = {}
	local previousTo = 0
	local previousMax = 0
	for _, area in route.areas do
		areaById[area.id] = area
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
			not isPositiveLevel(entry.minLevel)
			or not isPositiveLevel(entry.maxLevel)
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
		end
		if entry.spot ~= nil and not spots[entry.spot] then
			spotsOk = false
		end
	end
	check(`{route.id}: species exist and weights are positive`, rowsOk)
	check(`{route.id}: levels are 1 to {MAX_LEVEL}`, levelsOk)
	check(`{route.id}: each row's levels fit its area`, areasOk)
	check(`{route.id}: colours are known and rare chance is small`, colourOk)
	check(`{route.id}: uncommon species appear only at rustle spots`, uncommonOk)
	check(`{route.id}: every rustle row names a real spot`, spotsOk)
	check(`{route.id}: the open table is not empty`, #World.candidates(route, nil) > 0)
	for _, spot in route.rustleSpots do
		check(`{spot.id}: has rows`, #World.candidates(route, { spot = spot.id }) > 0)
	end
	for _, id in route.tamers do
		local tamer = Tamers.locals[id]
		check(`{id}: tamer exists and is on {route.id}`, tamer ~= nil and tamer.route == route.id)
	end
end

-- Only Greenwood's own species (biome 1); later biomes are checked by their own tests.
for name, def in Species do
	if def.biome == 1 and not def.giantForm then
		check(`{name}: appears in Greenwood`, seen[name] == true)
		if def.baseRarity == "Common" then
			check(`{name}: common species can be met in the open`, openSeen[name] == true)
		else
			check(`{name}: uncommon species is never met in the open`, openSeen[name] ~= true)
		end
	end
end
check(
	"wild levels run from about 2 to about 12",
	lowest == 2 and highest == 12,
	`{lowest} to {highest}`
)
check(
	"Route B's wild levels are higher than Route A's",
	routeById.greenwood_route_b.areas[1].minLevel
		>= routeById.greenwood_route_a.areas[#routeById.greenwood_route_a.areas].minLevel
)

-- Tamers ------------------------------------------------------------------------------------

print("\nTamers")
local function checkTeam(label: string, team: WorldTypes.TamerTeam, maxLevel: number)
	local count = #team.members
	check(`{label}: one to three creatures`, count >= 1 and count <= 3)
	local levelsOk, movesOk, poolOk, uniqueOk = true, true, true, true
	for index, m in team.members do
		local def = Species[m.species]
		if def == nil or not isPositiveLevel(m.level) or m.level > maxLevel then
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
	check(`{label}: species known, levels 1 to {maxLevel}`, levelsOk)
	check(`{label}: one to four known moves`, movesOk)
	check(`{label}: only moves the creature can know at its level`, poolOk)
	check(`{label}: no repeated move`, uniqueOk)
end

-- Greenwood's own tamers only: other biomes' tamers are checked by their own tests.
local localCount = 0
local greenwoodTamers: { [string]: WorldTypes.Tamer } = {}
for id, tamer in Tamers.locals do
	if routeById[tamer.route] ~= nil then
		greenwoodTamers[id] = tamer
	end
end
for id, tamer in greenwoodTamers do
	localCount += 1
	checkTeam(id, tamer.team, greenwood.gate.recommendedMin)
	check(`{id}: tier is Tamer`, tamer.tier == "Tamer")
	check(
		`{id}: has a look and both lines`,
		#tamer.look > 0 and #tamer.before > 0 and #tamer.after > 0
	)
	check(`{id}: lines are short`, #tamer.before <= MAX_LINE and #tamer.after <= MAX_LINE)
	local route = routeById[tamer.route]
	check(`{id}: stands on its route`, route ~= nil and tamer.at >= 0 and tamer.at <= route.length)
	check(`{id}: listed on its route`, route ~= nil and contains(route.tamers, id))
end
check("four to six local tamers", localCount >= 4 and localCount <= 6, `{localCount}`)

local rival = Tamers.rivals.rival_greenwood
check("the rival's tier is Rival", rival.tier == "Rival")
check("the first battle cannot be lost", rival.firstCannotBeLost)
check("the rival uses the role name", rival.name == "Rival")
check(
	"the rival's lines are short",
	#rival.firstBefore <= MAX_LINE
		and #rival.firstAfter <= MAX_LINE
		and #rival.gateBefore <= MAX_LINE
		and #rival.gateAfter <= MAX_LINE
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
for _, starter in STARTERS do
	local first = rival.first[starter]
	local gate = rival.gate[starter]
	checkTeam(`rival first vs {starter}`, first, MAX_LEVEL)
	checkTeam(`rival gate vs {starter}`, gate, MAX_LEVEL)
	check(`rival first vs {starter}: one creature`, #first.members == 1)
	local playerElement: Types.Element = Species[starter].element
	local firstElement: Types.Element = Species[first.members[1].species].element
	local gateElement: Types.Element = Species[gate.members[1].species].element
	check(
		`rival first vs {starter}: leads with the counter starter`,
		isStarter(first.members[1].species) and TypeChart.isStrong(firstElement, playerElement)
	)
	check(
		`rival gate vs {starter}: leads with the counter starter`,
		isStarter(gate.members[1].species)
			and TypeChart.isStrong(gateElement, playerElement)
			and gate.members[1].species == first.members[1].species
	)
	check(`rival gate vs {starter}: three creatures`, #gate.members == 3)
	local gateTop = ProgressionConfig.CAP_BASE - ProgressionConfig.GATE_TOP_UNDER_CAP
	local gateOk = gate.members[1].level == gateTop
	for _, m in gate.members do
		if m.level < gateTop - ProgressionConfig.GATE_TEAM_SPREAD or m.level > gateTop then
			gateOk = false
		end
	end
	check(`rival gate vs {starter}: two levels under the cap at most, led by the strongest`, gateOk)
	check(`rival gate vs {starter}: tint has grown`, gate.tint > first.tint)
end
check("the Rival tier exists in BattleAi", (("Rival" :: any) :: BattleAi.Tier) == "Rival")

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
			and isPositiveLevel(reward.level)
			and BreedConfig.COLOURS[reward.colour] ~= nil
	elseif reward.kind == "Egg" then
		local a, b = Species[reward.parentA], Species[reward.parentB]
		ok = ok and a ~= nil and b ~= nil and a.bodyPlan == b.bodyPlan
	elseif reward.kind == "Starter" then
		ok = ok and #reward.choices == 3 and isPositiveLevel(reward.level)
		for _, choice in reward.choices do
			ok = ok and Species[choice] ~= nil
		end
	elseif reward.kind == "Badge" then
		ok = ok and reward.id == greenwood.gate.badge.id
	end
	check(label, ok)
	return ok
end

-- Quests ------------------------------------------------------------------------------------

print("\nQuests")
local questCount = #QuestsGreenwood
check("three to five quests", questCount >= 3 and questCount <= 5, `{questCount}`)
local giverSlugs: { string } = {}
for _, quest in QuestsGreenwood do
	check(`{quest.id}: registered`, Quests[quest.id] == quest)
	local obj = quest.objective
	local objOk = false
	if obj.kind == "WinWild" then
		objOk = obj.count > 0 and routeById[obj.route] ~= nil
	elseif obj.kind == "TameSpecies" then
		objOk = Species[obj.species] ~= nil and openSeen[obj.species] == true
	elseif obj.kind == "BeatTamer" then
		objOk = Tamers.locals[obj.tamer] ~= nil
	elseif obj.kind == "BeatGiant" then
		objOk = Giants[obj.giant] ~= nil
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
	table.insert(giverSlugs, string.lower((string.gsub(quest.giver.name, " ", "_"))))
end

-- Play the line through.
local done: { [string]: boolean } = {}
local flags: World.Flags = {}
for _, beat in chapter.beats do
	if beat.id == "first_quest" then
		break
	end
	flags[beat.id] = true
end
local order: { string } = {}
local lastQuest: WorldTypes.Quest? = nil
local stuck = false
while not stuck do
	local open = World.availableQuests(QuestsGreenwood, done, flags)
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
for _, quest in QuestsGreenwood do
	if not quest.optional then
		table.insert(expected, quest.id)
	end
end
check("the quest line completes in order", table.concat(order, ",") == table.concat(expected, ","))
local before = World.availableQuests(QuestsGreenwood, {}, {})
check("nothing is offered before the story flag", #before == 0)
local firstOpen = World.availableQuests(QuestsGreenwood, {}, { third_creature = true })
check(
	"only the first quest is offered at the start",
	#firstOpen == 1 and firstOpen[1].id == expected[1]
)
local endsInCreature = false
if lastQuest ~= nil then
	for _, reward in lastQuest.rewards do
		if reward.kind == "Creature" then
			endsInCreature = true
		end
	end
end
check("the line ends in a guaranteed creature", endsInCreature)
local lineNeedsGiant = false
for _, quest in QuestsGreenwood do
	if not quest.optional and quest.objective.kind == "BeatGiant" then
		lineNeedsGiant = true
	end
end
check("the main line never needs the giant", not lineNeedsGiant)
local optionalGiant = Quests.gw_hollowbough
check(
	"the giant quest is optional and can be taken once the giant is seen",
	optionalGiant.optional
		and #World.availableQuests(
				QuestsGreenwood,
				{ gw_fresh_tracks = true },
				{ giant_glimpse = true, third_creature = true }
			)
			== 2
)
check(
	"the line's coins and candy follow the economy",
	(function(): boolean
		local coins, candy = 0, 0
		for _, reward in Quests.gw_woodcutters_word.rewards do
			if reward.kind == "Coins" then
				coins = reward.amount
			elseif reward.kind == "PrismCandy" then
				candy = reward.amount
			end
		end
		return coins == EconomyConfig.QUEST_LINE_COINS * EconomyConfig.ONE_TIME_MULT[1]
			and candy == EconomyConfig.QUEST_LINE_CANDY[1]
	end)()
)

-- Story -------------------------------------------------------------------------------------

print("\nStory")
check("chapter 1 is registered", chapter ~= nil and chapter.number == 1)
local ids: { [string]: number } = {}
local previousFrom = -1
local orderOk, reachOk, timeOk, linesOk, lengthOk, kindOk, targetOk =
	true, true, true, true, true, true, true
local speakers: { [string]: boolean } = {}
for index, beat in chapter.beats do
	if ids[beat.id] ~= nil then
		orderOk = false
	end
	ids[beat.id] = index
	if beat.minuteFrom < previousFrom or beat.minuteTo < beat.minuteFrom then
		timeOk = false
	end
	previousFrom = beat.minuteFrom
	for _, flag in beat.trigger.requires do
		local source = ids[flag]
		if source == nil or source >= index then
			reachOk = false
		end
	end
	if index == 1 then
		kindOk = kindOk and beat.trigger.kind == "Start" and #beat.trigger.requires == 0
	else
		kindOk = kindOk and beat.trigger.kind ~= "Start" and #beat.trigger.requires > 0
	end
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
		targetOk = targetOk
			and target ~= nil
			and (
				target == "rival_first"
				or target == greenwood.gate.battle
				or Tamers.locals[target] ~= nil
			)
	elseif trigger.kind == "Talk" then
		targetOk = targetOk
			and target ~= nil
			and (target == "mentor" or contains(giverSlugs, target))
	end
	for _, reward in beat.grants do
		if not checkReward(`{beat.id}: grant {reward.kind} is valid`, reward) then
			targetOk = false
		end
	end
end
check("beat ids are unique", orderOk)
check("every trigger is reachable from an earlier beat", reachOk)
check("the first beat starts the game and the rest need an earlier beat", kindOk)
check("timings never go backwards", timeOk)
check("every beat has one to three lines", linesOk)
check(`no line is over {MAX_LINE} characters`, lengthOk)
check("trigger targets and grants are real", targetOk)
check(
	"the story uses the role names Mentor and Rival",
	speakers.Mentor == true and speakers.Rival == true
)

local function beatById(id: string): WorldTypes.Beat
	return chapter.beats[ids[id]]
end
check("starter choice is in the first 30 seconds", beatById("starter_choice").minuteTo <= 0.5)
check("the rival's challenge comes by minute 2", beatById("rival_challenge").minuteTo <= 2)
check(
	"the lasso lesson is at minutes 2 to 4",
	beatById("lasso_lesson").minuteFrom == 2 and beatById("lasso_lesson").minuteTo == 4
)
check(
	"the mentor's egg is at about minute 10",
	beatById("mentor_egg").minuteFrom >= 8 and beatById("mentor_egg").minuteTo <= 12
)
check(
	"the first quest is at minutes 12 to 15",
	beatById("first_quest").minuteFrom >= 12 and beatById("first_quest").minuteTo <= 15
)
check("the badge comes inside 60 minutes", beatById("badge_and_token").minuteTo <= 60)
check(
	"the giant is seen before the egg",
	ids.giant_glimpse < ids.mentor_egg and ids.mentor_egg < ids.first_quest
)
check(
	"the egg grants a pen and the mentor's candy",
	(function(): boolean
		local pen, candy = false, false
		for _, reward in beatById("mentor_egg").grants do
			pen = pen or reward.kind == "Pen"
			candy = candy
				or (
					reward.kind == "PrismCandy"
					and reward.amount == EconomyConfig.CANDY.MentorLesson.perClaim
				)
		end
		return pen and candy
	end)()
)
check(
	"the badge beat grants the badge and a common creature",
	(function(): boolean
		local gotBadge, gotCreature = false, false
		for _, reward in beatById("badge_and_token").grants do
			gotBadge = gotBadge or reward.kind == "Badge"
			gotCreature = gotCreature
				or (reward.kind == "Creature" and Species[reward.species].baseRarity == "Common")
		end
		return gotBadge and gotCreature
	end)()
)

-- Play the chapter through with nextBeat.
local storyFlags: World.Flags = {}
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
	"nextBeat gives the first beat with no flags",
	(World.nextBeat(chapter, {}) :: WorldTypes.Beat).id == "starter_choice"
)
check("nextBeat waits when the trigger flags are not set", World.nextBeat(chapter, {
	starter_choice = true,
	rival_challenge = true,
	rival_parting = true,
	lasso_lesson = true,
	route_one = true,
	first_tamer = true,
	giant_glimpse = true,
	mentor_egg = true,
	third_creature = true,
	first_quest = true,
	gate_challenge = true,
	badge_and_token = true,
	sealed_path = true,
}) == nil)

-- The wild picker --------------------------------------------------------------------------

print("\nWild picker")
local routeA = routeById.greenwood_route_a
local routeB = routeById.greenwood_route_b
local a1 = World.pickWild(routeA, 12345, nil, "x")
local a2 = World.pickWild(routeA, 12345, nil, "x")
check(
	"the same seed gives the same creature",
	a1.creature.parts.Head.species == a2.creature.parts.Head.species
		and a1.creature.level == a2.creature.level
		and a1.creature.colour.shown == a2.creature.colour.shown
		and a1.creature.parts.Head.quality == a2.creature.parts.Head.quality
		and a1.creature.rarity == a2.creature.rarity
)
local distinct: { [string]: boolean } = {}
for seed = 1, 40 do
	distinct[World.pickWild(routeB, seed * 7919).creature.parts.Head.species] = true
end
check("different seeds give a mix of species", next(distinct) ~= nil and (function(): number
	local n = 0
	for _ in distinct do
		n += 1
	end
	return n
end)() >= 4)

local function share(
	route: WorldTypes.Route,
	options: World.PickOptions?,
	samples: number
): ({ [string]: number }, number, number)
	local counts: { [string]: number } = {}
	local rare = 0
	local levelBad = 0
	for index = 1, samples do
		local pick = World.pickWild(route, index * 2654435761 % 2147483629 + index, options)
		local species = pick.creature.parts.Head.species
		counts[species] = (counts[species] or 0) + 1
		if pick.rareColour then
			rare += 1
		end
		if
			pick.creature.level < pick.entry.minLevel
			or pick.creature.level > pick.entry.maxLevel
		then
			levelBad += 1
		end
	end
	return counts, rare, levelBad
end

local SAMPLES = 20000
local TOLERANCE = 0.03
for _, route in { routeA, routeB } do
	local counts, rare, levelBad = share(route, nil, SAMPLES)
	local rows = World.candidates(route, nil)
	local total = 0
	local bySpecies: { [string]: number } = {}
	for _, entry in rows do
		total += entry.weight
		bySpecies[entry.species] = (bySpecies[entry.species] or 0) + entry.weight
	end
	local worst = 0
	for species, weight in bySpecies do
		local observed = (counts[species] or 0) / SAMPLES
		worst = math.max(worst, math.abs(observed - weight / total))
	end
	check(
		`{route.id}: species shares match the weights`,
		worst <= TOLERANCE,
		`worst gap {string.format("%.1f", worst * 100)} points`
	)
	local rareShare = rare / SAMPLES
	check(
		`{route.id}: rare colours are about {BreedConfig.RARE_MUTATION_CHANCE * 100}%`,
		math.abs(rareShare - BreedConfig.RARE_MUTATION_CHANCE) <= 0.01,
		string.format("%.2f%%", rareShare * 100)
	)
	check(`{route.id}: drawn levels stay in the row's range`, levelBad == 0)
	local openUncommon = false
	for species in counts do
		if Species[species].baseRarity ~= "Common" then
			openUncommon = true
		end
	end
	check(`{route.id}: an open draw never gives an uncommon species`, not openUncommon)
end

-- Rustle spots and areas.
for _, route in { routeA, routeB } do
	for _, spot in route.rustleSpots do
		local counts = share(route, { spot = spot.id }, 4000)
		local rows = World.candidates(route, { spot = spot.id })
		local total = 0
		local bySpecies: { [string]: number } = {}
		for _, entry in rows do
			total += entry.weight
			bySpecies[entry.species] = (bySpecies[entry.species] or 0) + entry.weight
		end
		local worst = 0
		for species, weight in bySpecies do
			worst = math.max(worst, math.abs((counts[species] or 0) / 4000 - weight / total))
		end
		check(
			`{spot.id}: rustle draws match their weights`,
			worst <= 0.04,
			`worst gap {string.format("%.1f", worst * 100)} points`
		)
		local uncommonShare = 0
		for species, count in counts do
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
	for _, area in route.areas do
		local counts, _, levelBad = share(route, { area = area.id }, 400)
		local inside = true
		for species in counts do
			if Species[species] == nil then
				inside = false
			end
		end
		local placed = 0
		for _, entry in World.candidates(route, { area = area.id }) do
			placed += 1
			if entry.area ~= area.id then
				inside = false
			end
		end
		check(
			`{area.id}: an area draw uses only that area's rows`,
			inside and placed > 0 and levelBad == 0
		)
	end
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error(`{failed} test(s) failed`)
end
