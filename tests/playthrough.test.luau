--!strict
-- A robot player plays the whole story through the real rules: it picks a starter, fights the
-- battles the story asks for, catches creatures with the lasso, walks to the places the story
-- names, and trains on wild creatures when it is too weak. Nothing here is the server: it is
-- the same pure rules the server calls, joined up the way the server joins them, so a dead end
-- or a wall in the story shows up here before anyone plays it.
-- Run from the project folder:  lune run tests/playthrough.test

local BattleSession = require("../src/shared/BattleSession")
local Biomes = require("../src/content/Biomes")
local Capture = require("../src/shared/Capture")
local Encounters = require("../src/shared/Encounters")
local Health = require("../src/shared/Health")
local Lasso = require("../src/shared/Lasso")
local Layout = require("../src/shared/Layout")
local Profile = require("../src/shared/Profile")
local Rewards = require("../src/shared/Rewards")
local Shop = require("../src/shared/Shop")
local Species = require("../src/content/Species")
local StoryProgress = require("../src/shared/StoryProgress")
local StoryTriggers = require("../src/shared/StoryTriggers")
local Storyline = require("../src/content/Storyline")
local Tamers = require("../src/content/Tamers")
local Team = require("../src/shared/Team")
local Trainers = require("../src/shared/Trainers")
local TypeChart = require("../src/shared/TypeChart")
local Types = require("../src/shared/Types")
local World = require("../src/shared/World")
local WorldTypes = require("../src/shared/WorldTypes")
local Xp = require("../src/shared/Xp")

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

local biomes: { WorldTypes.Biome } = {}
for _, biome in Biomes do
	table.insert(biomes, biome)
end
table.sort(biomes, function(a, b)
	return a.number < b.number
end)
local world = Layout.world(biomes, Tamers.locals)
local map = world.map

-- The robot ---------------------------------------------------------------------------------

type Bot = {
	profile: Profile.Profile,
	book: Encounters.Book,
	time: number, -- the server's clock, in seconds
	seed: number,
	nextId: number,
	battleId: number,
	wildBattles: number,
	catches: number,
	losses: number,
	storyBattles: number,
	healerTrips: number,
	tonicsUsed: number,
	log: { string },
	against: Types.Element?, -- the type of the lead creature of the opponent it is preparing for
	alsoAgainst: { Types.Element }, -- the types of the creatures that were still standing when it lost
}

local function newBot(seed: number): Bot
	return {
		profile = Profile.template(),
		book = Encounters.new(),
		time = 86400 * 400,
		seed = seed,
		nextId = 0,
		battleId = 0,
		wildBattles = 0,
		catches = 0,
		losses = 0,
		storyBattles = 0,
		healerTrips = 0,
		tonicsUsed = 0,
		log = {},
		against = nil,
		alsoAgainst = {},
	}
end

local function nextSeed(bot: Bot): number
	bot.seed = (bot.seed * 48271) % 2147483647
	return bot.seed
end

local function newId(bot: Bot): string
	bot.nextId += 1
	return `bot{bot.nextId}`
end

local function team(bot: Bot): { Types.Creature }
	local list: { Types.Creature } = {}
	for _, id in bot.profile.Team do
		table.insert(list, bot.profile.Creatures[id])
	end
	return list
end

local function topLevel(bot: Bot): number
	local top = 0
	for _, creature in team(bot) do
		top = math.max(top, creature.level)
	end
	return top
end

local function teamMembers(session: BattleSession.Session): { { id: string, fainted: boolean } }
	local list = {}
	for _, fighter in session.state.sides[1].team do
		table.insert(list, { id = fighter.creature.id, fainted = fighter.hp <= 0 })
	end
	return list
end

-- Between wild battles the robot does what a player does with lasting damage: it sends out
-- whichever creature is in the best shape, and walks back to the healer (free, as in the game)
-- only when none of them is fit to fight.
local function healIfNeeded(bot: Bot)
	local list = team(bot)
	table.sort(list, function(a, b)
		local sa, sb = Health.share(a), Health.share(b)
		return if sa == sb then a.id < b.id else sa > sb
	end)
	if #list == 0 then
		return
	end
	if Health.share(list[1]) < 0.5 then
		Health.healAll(bot.profile)
		bot.time += 60
		bot.healerTrips += 1
		return
	end
	local ids: { string } = {}
	for _, creature in list do
		table.insert(ids, creature.id)
	end
	bot.profile.Team = ids
end

local function elementOf(creature: Types.Creature): Types.Element
	local element: Types.Element = Species[creature.parts.Torso.species].element
	return element
end

local function beats(mine: Types.Element, theirs: Types.Element): boolean
	return TypeChart.multiplier(mine, theirs) > 1
end

-- Keeps the strongest creatures on the team. When the robot is getting ready for an opponent,
-- a creature whose type beats the opponent's lead goes first, as a sensible player would do.
local function pickTeam(bot: Bot)
	local all: { Types.Creature } = {}
	for _, creature in bot.profile.Creatures do
		table.insert(all, creature)
	end
	local against: Types.Element? = bot.against
	local function score(creature: Types.Creature): number
		local total = creature.level
		if against and beats(elementOf(creature), against) then
			total += 100
		end
		for _, element: Types.Element in bot.alsoAgainst do
			if beats(elementOf(creature), element) then
				total += 50
				break
			end
		end
		return total
	end
	table.sort(all, function(a, b)
		local sa, sb = score(a), score(b)
		return if sa == sb then a.id < b.id else sa > sb
	end)
	local ids: { string } = {}
	for index = 1, math.min(#all, Profile.teamSize(bot.profile.Story.badges)) do
		table.insert(ids, all[index].id)
	end
	bot.profile.Team = ids
end

-- Plays a battle by always using the move that does the most damage. With `tonics`, the robot
-- also does what a player who has just lost does: when its creature is badly hurt it spends the
-- turn on a Field Tonic, up to three a battle.
local TONICS_A_BATTLE = 3
local function fight(
	bot: Bot,
	session: BattleSession.Session,
	tonics: boolean?
): BattleSession.Ending?
	local previews = BattleSession.started(session).previews
	local used = 0
	for _ = 1, 200 do
		local side = session.state.sides[1]
		local fighter = side.team[side.active]
		local turn: BattleSession.TurnResult? = nil
		if
			tonics
			and used < TONICS_A_BATTLE
			and fighter.hp > 0
			and fighter.hp < fighter.stats.Hp * 0.35
			and (bot.profile.Items.Tonic or 0) > 0
		then
			turn =
				Shop.useInBattle(bot.profile, session, session.state.turn + 1, "Tonic", side.active)
			if turn then
				used += 1
				bot.tonicsUsed += 1
			end
		end
		if not turn then
			local best, bestDamage = 1, -1
			for index, damage in previews do
				if damage > bestDamage then
					best, bestDamage = index, damage
				end
			end
			turn = BattleSession.act(session, session.state.turn + 1, "Move", best)
		end
		local played = assert(turn, "a turn is played")
		previews = played.previews
		if played.finished then
			break
		end
	end
	-- The same timing the XP pacing model uses: 40 seconds for a wild battle with the walk to it.
	bot.time += 40
	return BattleSession.ending(session)
end

local function startBattle(
	bot: Bot,
	kind: BattleSession.Kind,
	theirs: { Types.Creature },
	moves: { { string } }?,
	tier: any,
	cannotLose: boolean?
): BattleSession.Session
	bot.battleId += 1
	return assert(
		BattleSession.start({
			battleId = bot.battleId,
			kind = kind,
			yours = team(bot),
			theirs = theirs,
			theirMoves = moves,
			tier = tier,
			seed = nextSeed(bot),
			levelCap = Xp.levelCap(bot.profile.Story.badges),
			cannotLose = cannotLose,
		}),
		"the battle starts"
	)
end

-- The furthest stretch of route the robot has earned and whose creatures it can handle.
local function trainingSpot(bot: Bot): (WorldTypes.Biome, Layout.Point)
	local bestBiome, bestArea = biomes[1], biomes[1].routes[1].areas[1]
	local top = topLevel(bot)
	for _, biome in biomes do
		if biome.number <= bot.profile.Story.badges + 1 then
			for _, route in biome.routes do
				for _, area in route.areas do
					if area.maxLevel <= top + 2 and area.maxLevel >= bestArea.maxLevel then
						bestBiome, bestArea = biome, area
					end
				end
			end
		end
	end
	return bestBiome, map.places[bestArea.id]
end

-- One wild battle at the training spot. With `catch`, the robot throws a lasso once the
-- creature is hurt, tapping every loop dead centre. Returns true if it won or caught.
local function wildBattle(bot: Bot, catch: boolean): boolean
	healIfNeeded(bot)
	local biome, at = trainingSpot(bot)
	Encounters.tick(bot.book, biome, map, at, bot.time, nextSeed(bot), function()
		return newId(bot)
	end)
	local target: Encounters.Spawn? = nil
	for _, spawn in bot.book.spawns do
		if not spawn.busy and Layout.distance(spawn.at, at) < 400 then
			target = spawn
			break
		end
	end
	if not target then
		bot.time += 30 -- the stretch is resting; wait for it to refill
		return false
	end
	local spawn =
		assert(Encounters.engage(bot.book, target.id, target.at), "the creature is engaged")
	local session = startBattle(bot, "Wild", { spawn.creature }, nil, "Wild")
	bot.wildBattles += 1
	local ending: BattleSession.Ending? = nil
	if catch and (bot.profile.Items.Basic or 0) > 0 then
		-- Hit it once, then throw.
		local started = BattleSession.started(session)
		local first = BattleSession.act(session, 1, "Move", if started.previews[1] then 1 else 1)
		if first and not first.finished then
			local throw = Capture.begin({
				profile = bot.profile,
				session = session,
				turn = session.state.turn + 1,
				tier = "Basic",
				seed = nextSeed(bot),
				roundTripMs = 80,
				nowMs = 0,
				misses = spawn.misses,
			})
			if throw then
				local taps: { number } = {}
				for index, zone in throw.pattern.zones do
					table.insert(taps, Lasso.nextCentreTimeMs(throw.pattern, index, zone.startMs))
				end
				Capture.finish(bot.profile, session, throw, taps, taps, spawn.misses + 1)
			end
		end
		ending = BattleSession.ending(session) or fight(bot, session)
	else
		ending = fight(bot, session)
	end
	Encounters.finish(bot.book, spawn.id, ending, spawn.misses, bot.time)
	if ending == "Won" or ending == "Caught" then
		Rewards.wildWin(bot.profile, {
			foe = BattleSession.foe(session),
			team = teamMembers(session),
			cap = Xp.levelCap(bot.profile.Story.badges),
			unixTime = bot.time,
			seed = nextSeed(bot),
			biome = spawn.biome,
		})
		if ending == "Caught" then
			bot.catches += 1
		end
		pickTeam(bot)
		return true
	end
	bot.losses += 1
	Health.healAll(bot.profile)
	return false
end

-- Catches a creature whose type beats `element`, from the strongest stretch that has one.
-- Returns true if the robot now owns one.
local function hunt(bot: Bot, element: Types.Element): boolean
	local top = topLevel(bot)
	local huntBiome: WorldTypes.Biome? = nil
	local huntArea: WorldTypes.Area? = nil
	for _, biome in biomes do
		if biome.number <= bot.profile.Story.badges + 1 then
			for _, route in biome.routes do
				for _, entry in route.spawns do
					if entry.spot == nil and beats(Species[entry.species].element, element) then
						for _, area in route.areas do
							if
								area.id == entry.area
								and area.minLevel <= top + 3
								and (huntArea == nil or area.maxLevel > huntArea.maxLevel)
							then
								huntBiome, huntArea = biome, area
							end
						end
					end
				end
			end
		end
	end
	if not huntBiome or not huntArea then
		return false
	end
	local at = map.places[huntArea.id]
	for _ = 1, 80 do
		healIfNeeded(bot)
		if (bot.profile.Items.Basic or 0) < 1 then
			Shop.buy(bot.profile, "Basic", 5, true, 1)
		end
		Encounters.tick(bot.book, huntBiome, map, at, bot.time, nextSeed(bot), function()
			return newId(bot)
		end)
		local wanted: Encounters.Spawn? = nil
		local other: Encounters.Spawn? = nil
		for _, spawn in bot.book.spawns do
			if not spawn.busy and spawn.area == huntArea.id then
				if beats(elementOf(spawn.creature), element) then
					wanted = spawn
				else
					other = spawn
				end
			end
		end
		local target = wanted or other
		if target then
			local spawn =
				assert(Encounters.engage(bot.book, target.id, target.at), "the creature is engaged")
			local session = startBattle(bot, "Wild", { spawn.creature }, nil, "Wild")
			bot.wildBattles += 1
			local ending: BattleSession.Ending? = nil
			if wanted then
				local throw = Capture.begin({
					profile = bot.profile,
					session = session,
					turn = 1,
					tier = "Basic",
					seed = nextSeed(bot),
					roundTripMs = 80,
					nowMs = 0,
					misses = spawn.misses,
				})
				if throw then
					local taps: { number } = {}
					for index, zone in throw.pattern.zones do
						table.insert(
							taps,
							Lasso.nextCentreTimeMs(throw.pattern, index, zone.startMs)
						)
					end
					Capture.finish(bot.profile, session, throw, taps, taps, spawn.misses + 1)
				end
				ending = BattleSession.ending(session) or fight(bot, session)
			else
				ending = fight(bot, session) -- clear it so the stretch can bring out another
			end
			Encounters.finish(bot.book, spawn.id, ending, spawn.misses, bot.time)
			if ending == "Won" or ending == "Caught" then
				Rewards.wildWin(bot.profile, {
					foe = BattleSession.foe(session),
					team = teamMembers(session),
					cap = Xp.levelCap(bot.profile.Story.badges),
					unixTime = bot.time,
					seed = nextSeed(bot),
					biome = spawn.biome,
				})
			else
				bot.losses += 1
				Health.healAll(bot.profile)
			end
			if ending == "Caught" then
				bot.catches += 1
				pickTeam(bot)
				return true
			end
		end
	end
	return false
end

-- A battle the story asks for: the robot trains until it is about level with the opponent's
-- strongest creature (or at its level cap), then fights, and trains more after each loss.
local function storyBattle(bot: Bot, id: string): boolean
	for attempt = 1, 12 do
		local opponent = assert(Trainers.resolve(id, bot.profile, Storyline), `{id} can be battled`)
		local theirTop = 0
		for _, member in opponent.team.members do
			theirTop = math.max(theirTop, member.level)
		end
		-- After a first loss the robot does what a player would: looks at what beat it and
		-- brings a creature of the type that beats the opponent's lead.
		local lead: Types.Element = Species[opponent.team.members[1].species].element
		if attempt > 1 then
			bot.against = lead
			local wanted: { Types.Element } = { lead }
			for _, element: Types.Element in bot.alsoAgainst do
				table.insert(wanted, element)
			end
			for _, element: Types.Element in wanted do
				local covered = false
				for _, creature in bot.profile.Creatures do
					covered = covered or beats(elementOf(creature), element)
				end
				if not covered then
					hunt(bot, element)
				end
			end
			pickTeam(bot)
		end
		local goal = math.min(theirTop + attempt - 1, Xp.levelCap(bot.profile.Story.badges))
		local function lowest(): number
			local low = math.huge
			for _, creature in team(bot) do
				low = math.min(low, creature.level)
			end
			return low
		end
		-- First try: the team is about level with the opponent. After a loss: everyone is
		-- trained up to the goal, and the robot stocks up on Field Tonics at the shop.
		local floor = if attempt == 1 then math.min(goal, theirTop) - 2 else goal
		local guard = 0
		while (topLevel(bot) < goal or lowest() < floor) and guard < 400 do
			wildBattle(bot, false)
			guard += 1
		end
		if attempt > 1 then
			local short = TONICS_A_BATTLE - (bot.profile.Items.Tonic or 0)
			if short > 0 then
				Shop.buy(bot.profile, "Tonic", short, true, bot.profile.Story.biomeReached)
			end
		end
		Health.healAll(bot.profile)
		pickTeam(bot)
		bot.storyBattles += 1
		local creatures, moves = Trainers.build(opponent)
		local kind: BattleSession.Kind = opponent.kind
		local session = startBattle(
			bot,
			kind,
			creatures,
			moves,
			if opponent.kind == "Rival" then "Rival" else "Tamer",
			opponent.cannotLose
		)
		local ending = fight(bot, session, attempt > 1)
		bot.time += 110 -- a battle against a person is longer: about two and a half minutes in all
		if ending == "Won" then
			bot.against = nil
			bot.alsoAgainst = {}
			Rewards.trainedWin(bot.profile, {
				opponentId = opponent.id,
				xpKind = opponent.xpKind,
				coinKind = if opponent.paysCoins then "Tamer" else nil,
				biome = world.biomeOfPlace[opponent.place] or 1,
				foes = creatures,
				team = teamMembers(session),
				cap = Xp.levelCap(bot.profile.Story.badges),
				unixTime = bot.time,
			})
			table.insert(
				bot.log,
				`    beat {id} at team level {topLevel(bot)} (theirs {theirTop}), try {attempt}`
			)
			return true
		end
		bot.losses += 1
		-- Whatever was still standing is what the robot prepares for next.
		for _, fighter in session.state.sides[2].team do
			local element = elementOf(fighter.creature)
			if fighter.hp > 0 and not table.find(bot.alsoAgainst, element) then
				table.insert(bot.alsoAgainst, element)
			end
		end
		Health.healAll(bot.profile)
	end
	bot.against = nil
	bot.alsoAgainst = {}
	return false
end

-- Finishes the next beat if `event` is what it was waiting for.
local function tell(bot: Bot, event: StoryTriggers.Event, choice: string?): boolean
	local beat = StoryTriggers.ready(Storyline, bot.profile, map, event)
	if not beat then
		return false
	end
	local done = StoryProgress.complete(bot.profile, Storyline, {
		beatId = beat.id,
		choice = choice,
		triggerMet = true,
		newId = function()
			return newId(bot)
		end,
		seed = nextSeed(bot),
		unixTime = bot.time,
	})
	pickTeam(bot)
	return done ~= nil
end

-- Does whatever the next beat needs. Returns false if the robot cannot move the story on.
local function step(bot: Bot): boolean
	local beat = assert(World.nextBeat(Storyline, bot.profile.Story.flags), "a beat is next")
	local trigger = beat.trigger
	bot.time += 20
	-- The player's furthest biome moves on as they walk into one they have earned.
	for _, biome in biomes do
		if
			biome.number <= bot.profile.Story.badges + 1
			and biome.number > bot.profile.Story.biomeReached
		then
			bot.profile.Story.biomeReached = biome.number
		end
	end
	if trigger.kind == "Start" then
		return tell(bot, { kind = "Ask", at = nil }, "Mossmitt")
	elseif trigger.kind == "Follow" then
		return tell(bot, { kind = "Ask", at = nil }, nil)
	elseif trigger.kind == "Enter" or trigger.kind == "Sight" then
		local place = trigger.target and map.places[trigger.target]
		return place ~= nil and tell(bot, { kind = "At", at = place }, nil)
	elseif trigger.kind == "Talk" then
		local place = trigger.target and map.places[trigger.target]
		return place ~= nil and tell(bot, { kind = "Ask", at = place }, nil)
	elseif trigger.kind == "Tame" then
		for _ = 1, 30 do
			if (bot.profile.Items.Basic or 0) < 1 then
				-- Lassos are cheap on purpose; the robot buys some when it runs out.
				Shop.buy(bot.profile, "Basic", 5, true, 1)
			end
			local before = bot.catches
			wildBattle(bot, true)
			if bot.catches > before then
				return tell(bot, { kind = "Tame" }, nil)
			end
		end
		return false
	elseif trigger.kind == "Win" then
		local target = assert(trigger.target, "a win beat names its battle")
		return storyBattle(bot, target) and tell(bot, { kind = "Win", battle = target }, nil)
	end
	return false
end

-- The run ------------------------------------------------------------------------------------

-- One robot plays from the first beat to the last. Each seed is a different player: different
-- wild creatures, different luck in battle.
type Leg = { wild: number, minutes: number, level: number, coins: number }
type Run = { bot: Bot, stuckAt: string?, legs: { Leg }, barred: string? }

local function play(seed: number): Run
	local bot = newBot(seed)
	local run: Run = { bot = bot, stuckAt = nil, legs = {}, barred = nil }
	local start = { wild = 0, time = bot.time }
	local badges = 0
	for _ = 1, #Storyline.beats + 5 do
		local beat = World.nextBeat(Storyline, bot.profile.Story.flags)
		if not beat then
			break
		end
		if not step(bot) then
			run.stuckAt = `{beat.id} ({beat.trigger.kind} {beat.trigger.target or ""})`
			break
		end
		-- Whatever the robot has just been given or has caught, it must be allowed to use.
		for _, creature in bot.profile.Creatures do
			if not Team.mayBattle(bot.profile, creature) and not run.barred then
				run.barred = `{creature.parts.Torso.species} after {beat.id}`
			end
		end
		if bot.profile.Story.badges > badges then
			badges = bot.profile.Story.badges
			table.insert(run.legs, {
				wild = bot.wildBattles - start.wild,
				minutes = math.floor((bot.time - start.time) / 60),
				level = topLevel(bot),
				coins = bot.profile.Coins,
			})
			start = { wild = bot.wildBattles, time = bot.time }
		end
	end
	return run
end

local function middle(values: { number }): number
	table.sort(values)
	return values[math.ceil(#values / 2)]
end

-- What the pacing decision in docs/DECISIONS.md asks for: a first badge within the hour and the
-- three launch biomes in four to five hours. The robot only counts time spent in battles and at
-- the healer (no walking, talking or shopping), so its clock has to come in well under that.
local FIRST_BADGE_BATTLE_MINUTES = 45
local LAUNCH_BATTLE_MINUTES = 210
local TYPICAL_WILD_BATTLES_A_BADGE = 60 -- training and hunting for the right type, together
local MOST_WILD_BATTLES_A_BADGE = 100 -- the unluckiest robot; more than this is a wall, not a game

print("\n== A robot plays the whole story ==")
do
	local first = play(1)
	for number, leg in first.legs do
		print(
			`    badge {number}: team level {leg.level}, {leg.wild} wild battles, about {leg.minutes} minutes, {leg.coins} coins`
		)
	end
	for _, line in first.bot.log do
		print(line)
	end
	check(
		"the story can be played from the first beat to the last",
		first.stuckAt == nil and World.nextBeat(Storyline, first.bot.profile.Story.flags) == nil,
		first.stuckAt
	)
	check(
		"a badge is earned for every biome with a story",
		first.bot.profile.Story.badges == #biomes,
		`{first.bot.profile.Story.badges} badges, {#biomes} biomes`
	)
	check("the robot caught creatures along the way", first.bot.catches >= 1, `{first.bot.catches}`)
	check("coins never go below zero", first.bot.profile.Coins >= 0, `{first.bot.profile.Coins}`)
	check(
		"every creature the robot was given or caught could battle for it from that moment",
		first.barred == nil,
		first.barred
	)
	check(
		"the save is sound at the end",
		#Profile.validate(first.bot.profile) == 0,
		table.concat(Profile.validate(first.bot.profile), "; ")
	)
end

print("\n== Twelve different robots: is the story fair and well paced for all of them? ==")
do
	local SEEDS: { number } = { 1, 7, 13, 99, 1234, 5555, 31337, 77777, 424242, 8675309, 2026, 11 }
	local stuck: { string } = {}
	local barred: { string } = {}
	local wild: { { number } } = {}
	local minutes: { { number } } = {}
	local total: { number } = {}
	local worstLosses, worstTries, mostWild = 0, 0, 0
	local firstTryWins, storyBattles = 0, 0
	for _, seed in SEEDS do
		local run = play(seed)
		if run.barred then
			table.insert(barred, `seed {seed}: {run.barred}`)
		end
		if run.stuckAt or World.nextBeat(Storyline, run.bot.profile.Story.flags) ~= nil then
			table.insert(stuck, `seed {seed}: {run.stuckAt or "ran out of steps"}`)
			continue
		end
		local sum = 0
		for number, leg in run.legs do
			wild[number] = wild[number] or {}
			minutes[number] = minutes[number] or {}
			table.insert(wild[number], leg.wild)
			table.insert(minutes[number], leg.minutes)
			mostWild = math.max(mostWild, leg.wild)
			sum += leg.minutes
		end
		table.insert(total, sum)
		worstLosses = math.max(worstLosses, run.bot.losses)
		for _, line in run.bot.log do
			local tries = tonumber(string.match(line, "try (%d+)")) or 1
			worstTries = math.max(worstTries, tries)
			storyBattles += 1
			if tries == 1 then
				firstTryWins += 1
			end
		end
	end
	check("every robot finishes the story", #stuck == 0, table.concat(stuck, "; "))
	check(
		"no robot is ever handed a creature it is not yet allowed to use",
		#barred == 0,
		table.concat(barred, "; ")
	)
	if #stuck == 0 then
		for number in wild do
			print(
				`    badge {number}: typically {middle(wild[number])} wild battles and {middle(
					minutes[number]
				)} minutes of battling`
			)
		end
		check(
			"the first badge takes well under an hour of battling",
			middle(minutes[1]) <= FIRST_BADGE_BATTLE_MINUTES,
			`{middle(minutes[1])} minutes`
		)
		check(
			"the launch biomes take about three hours of battling or less",
			middle(total) <= LAUNCH_BATTLE_MINUTES,
			`{middle(total)} minutes`
		)
		local typicalMost = 0
		for number in wild do
			typicalMost = math.max(typicalMost, middle(wild[number]))
		end
		check(
			"a badge typically takes 60 wild battles or fewer",
			typicalMost <= TYPICAL_WILD_BATTLES_A_BADGE,
			`{typicalMost} in the longest biome`
		)
		check(
			"training never becomes a wall, even for the unluckiest robot",
			mostWild <= MOST_WILD_BATTLES_A_BADGE,
			`at most {mostWild} wild battles for one badge`
		)
		check(
			"no story battle takes more than four tries",
			worstTries <= 4,
			`worst: {worstTries} tries`
		)
		check(
			"losses happen, so the battles are not a formality",
			firstTryWins < storyBattles,
			`{firstTryWins} of {storyBattles} story battles won first time`
		)
		check("losses do not pile up", worstLosses < 25, `at most {worstLosses} in one playthrough`)
	end
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("playthrough checks failed")
end
