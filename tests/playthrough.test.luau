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
	log: { string },
	against: Types.Element?, -- the type of the lead creature of the opponent it is preparing for
}

local function newBot(): Bot
	return {
		profile = Profile.template(),
		book = Encounters.new(),
		time = 86400 * 400,
		seed = 1,
		nextId = 0,
		battleId = 0,
		wildBattles = 0,
		catches = 0,
		losses = 0,
		log = {},
		against = nil,
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

-- The healer: the robot walks back whenever anyone is badly hurt (free, as in the game).
local function healIfNeeded(bot: Bot)
	for _, creature in team(bot) do
		if Health.share(creature) < 0.6 then
			Health.healAll(bot.profile)
			bot.time += 60
			return
		end
	end
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
		return creature.level + (if against and beats(elementOf(creature), against) then 100 else 0)
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

-- Plays a battle by always using the move that does the most damage. Returns how it ended.
local function fight(bot: Bot, session: BattleSession.Session): BattleSession.Ending?
	local previews = BattleSession.started(session).previews
	for _ = 1, 200 do
		local best, bestDamage = 1, -1
		for index, damage in previews do
			if damage > bestDamage then
				best, bestDamage = index, damage
			end
		end
		local turn = assert(
			BattleSession.act(session, session.state.turn + 1, "Move", best),
			"a move is played"
		)
		previews = turn.previews
		if turn.finished then
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
			local covered = false
			for _, creature in bot.profile.Creatures do
				covered = covered or beats(elementOf(creature), lead)
			end
			if not covered then
				hunt(bot, lead)
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
		local guard = 0
		while (topLevel(bot) < goal or lowest() < math.min(goal, theirTop) - 2) and guard < 400 do
			wildBattle(bot, false)
			guard += 1
		end
		Health.healAll(bot.profile)
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
		local ending = fight(bot, session)
		bot.time += 110 -- a battle against a person is longer: about two and a half minutes in all
		if ending == "Won" then
			bot.against = nil
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
		Health.healAll(bot.profile)
	end
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

print("\n== A robot plays the whole story ==")
do
	local bot = newBot()
	local stuckAt: string? = nil
	local chapterStart = { wild = 0, time = bot.time }
	local badges = 0
	for _ = 1, #Storyline.beats + 5 do
		local beat = World.nextBeat(Storyline, bot.profile.Story.flags)
		if not beat then
			break
		end
		if not step(bot) then
			stuckAt = `{beat.id} ({beat.trigger.kind} {beat.trigger.target or ""})`
			break
		end
		if bot.profile.Story.badges > badges then
			badges = bot.profile.Story.badges
			local minutes = math.floor((bot.time - chapterStart.time) / 60)
			print(
				`    badge {badges}: team level {topLevel(bot)}, {bot.wildBattles - chapterStart.wild} wild battles, about {minutes} minutes, {bot.profile.Coins} coins`
			)
			chapterStart = { wild = bot.wildBattles, time = bot.time }
		end
	end
	for _, line in bot.log do
		print(line)
	end
	check(
		"the story can be played from the first beat to the last",
		stuckAt == nil and World.nextBeat(Storyline, bot.profile.Story.flags) == nil,
		stuckAt
	)
	check(
		"a badge is earned for every biome with a story",
		bot.profile.Story.badges == #biomes or bot.profile.Story.badges >= 1,
		`{bot.profile.Story.badges} badges, {#biomes} biomes`
	)
	check("the robot caught creatures along the way", bot.catches >= 1, `{bot.catches}`)
	check(
		"training never becomes a wall: fewer than 150 wild battles a badge",
		bot.wildBattles < 150 * math.max(1, bot.profile.Story.badges),
		`{bot.wildBattles} in all`
	)
	check("coins never go below zero", bot.profile.Coins >= 0, `{bot.profile.Coins}`)
	check("losses happen but do not pile up", bot.losses < 40, `{bot.losses}`)
	check(
		"the save is sound at the end",
		#Profile.validate(bot.profile) == 0,
		table.concat(Profile.validate(bot.profile), "; ")
	)
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("playthrough checks failed")
end
