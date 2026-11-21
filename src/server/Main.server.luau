--!strict
-- Starts the server and connects its services: saving, the world, battles, catching, breeding
-- and the story all share the one loaded profile per player from the data service.
--
-- Still to come: purchases, trading and the Circuit.
-- Not yet run in Studio.

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Grants = require(ReplicatedStorage.shared.Grants)
local Health = require(ReplicatedStorage.shared.Health)
local Net = require(ReplicatedStorage.net.generated.Server)
local Profile = require(ReplicatedStorage.shared.Profile)
local StoryProgress = require(ReplicatedStorage.shared.StoryProgress)
local Types = require(ReplicatedStorage.shared.Types)
local World = require(ReplicatedStorage.shared.World)

local BattleFlow = require(script.Parent.Battle.BattleFlow)
local BattleService = require(script.Parent.Battle.BattleService)
local BreedingService = require(script.Parent.Breeding.BreedingService)
local CaptureService = require(script.Parent.Capture.CaptureService)
local DailyService = require(script.Parent.Daily.DailyService)
local DataService = require(script.Parent.Data.DataService)
local GiantService = require(script.Parent.Giants.GiantService)
local InventoryService = require(script.Parent.Inventory.InventoryService)
local QuestService = require(script.Parent.Quests.QuestService)
local SerialGrants = require(script.Parent.Serials.SerialGrants)
local SerialService = require(script.Parent.Serials.SerialService)
local StateSync = require(script.Parent.State.StateSync)
local StoryService = require(script.Parent.Story.StoryService)
local WorldService = require(script.Parent.World.WorldService)

local HATCH_CHECK_SECONDS = 5

-- One line per event in the server log, ready for the analytics service later.
local function log(event: string, fields: { [string]: any })
	local ok, text = pcall(HttpService.JSONEncode, HttpService, fields)
	print(`[{event}] {if ok then text else "(fields could not be written)"}`)
end

local random = Random.new()

local function seed(): number
	return random:NextInteger(1, 2147483646)
end

local function newId(): string
	return HttpService:GenerateGUID(false)
end

-- Gifts waiting for room ---------------------------------------------------------------------

local function rebuildGift(source: string, ref: string): Types.Creature?
	if source == "Starter" or source == "Token" or source == "Quest" then
		return StoryProgress.rebuild(ref, newId(), seed())
	end
	return nil
end

-- Hands over any gifts that were waiting for stable room or a free pen.
local function claimWaiting(player: Player, profile: Profile.Profile)
	local handed = Grants.claimPending(profile, rebuildGift)
	local eggs = StoryProgress.claimEggs(profile, newId, os.time(), seed())
	SerialGrants.finish(player) -- a giant or a gem find waiting for its number or for room
	if handed + eggs > 0 then
		StateSync.changed(player)
		log("PendingClaimed", { player = player.UserId, creatures = handed, eggs = eggs })
	end
end

-- The world and the story --------------------------------------------------------------------

WorldService.start({
	isReady = function(player)
		return DataService.get(player) ~= nil
			and BattleService.session(player) == nil
			and not GiantService.active(player)
	end,
	refuse = BattleService.refuse,
	onAt = function(player, at)
		-- Places the story is waiting for the player to reach.
		StoryService.event(player, { kind = "At", at = at }, nil, true)
		-- Standing in a later biome they have earned moves their "furthest biome" on (shop
		-- prices and some rewards follow it).
		local profile = DataService.get(player)
		local here = WorldService.biomeOf(player).number
		if profile and here > profile.Story.biomeReached and here <= profile.Story.badges + 1 then
			profile.Story.biomeReached = here
			StateSync.changed(player)
			log("BiomeReached", { player = player.UserId, biome = here })
		end
	end,
	hasBait = function(player)
		local profile = DataService.get(player)
		return profile ~= nil and (profile.Items.Bait or 0) >= 1
	end,
	spendBait = function(player)
		local profile = DataService.get(player)
		if profile and (profile.Items.Bait or 0) >= 1 then
			profile.Items.Bait -= 1
			StateSync.changed(player)
			log("BaitUsed", { player = player.UserId })
		end
	end,
	hasReached = function(player, biomeNumber)
		local profile = DataService.get(player)
		return profile ~= nil and biomeNumber <= profile.Story.biomeReached
	end,
	mayEnter = function(player, biomeNumber)
		-- A biome is earned with the badge of the one before it.
		local profile = DataService.get(player)
		return profile ~= nil and biomeNumber <= profile.Story.badges + 1
	end,
	canBeAmbushed = function(player)
		-- Only once the story has opened wild battles, and only if someone on the team can fight.
		local profile = DataService.get(player)
		if
			not profile
			or not World.isUnlocked({ StoryService.chapter() }, profile.Story.flags, "wild_battles")
		then
			return false
		end
		for _, id in profile.Team do
			local creature = profile.Creatures[id]
			if creature and not Health.isFainted(creature) then
				return true
			end
		end
		return false
	end,
	onAmbush = BattleFlow.ambush,
})

StoryService.start({
	getData = DataService.get,
	map = WorldService.map,
	position = WorldService.position,
	refuse = BattleService.refuse,
	changed = StateSync.changed,
	log = log,
})

QuestService.start({
	getData = DataService.get,
	biomes = WorldService.biomes,
	isNear = WorldService.isNear,
	refuse = BattleService.refuse,
	changed = StateSync.changed,
	log = log,
})

DailyService.start({
	getData = DataService.get,
	changed = StateSync.changed,
	notify = function(player, text)
		Net.Notice.Fire(player, { Text = string.sub(text, 1, 120) })
	end,
	log = log,
})

-- Saving (started after the world and the story, which a loading player needs) ---------------

DataService.start(log, function(player: Player)
	local profile = DataService.get(player)
	if not profile then
		return
	end
	StateSync.changed(player)
	Grants.rollDay(profile, os.time())
	claimWaiting(player, profile)
end)

-- Battles ---------------------------------------------------------------------------------

BattleFlow.start(log)

-- True once the story has opened a feature (breeding, the shop, the giant) for this player.
local function isUnlocked(profile: Profile.Profile, feature: string): boolean
	return World.isUnlocked({ StoryService.chapter() }, profile.Story.flags, feature)
end

-- A creature in any kind of battle cannot be bred, released or moved on or off the team.
local function isLocked(player: Player, creatureId: string): boolean
	return BattleService.isInBattle(player, creatureId)
		or GiantService.isInBattle(player, creatureId)
end

GiantService.start({
	getData = DataService.get,
	team = BattleFlow.team,
	inOtherBattle = function(player)
		return BattleService.session(player) ~= nil
	end,
	mayEnter = WorldService.mayEnter,
	isOpen = function(profile)
		return isUnlocked(profile, "giant_marker")
	end,
	biome = WorldService.biomeOf,
	map = WorldService.map,
	position = WorldService.position,
	refuse = BattleService.refuse,
	changed = StateSync.changed,
	onWon = function(player, battleId, giantId, paid)
		BattleFlow.sendRewards(player, battleId, paid)
		log(
			"GiantWon",
			{ player = player.UserId, giant = giantId, first = paid.firstClear, prism = paid.prism }
		)
		QuestService.record(player, { kind = "BeatGiant", giant = giantId })
		DailyService.record(player, "WinBattle")
		if not paid.firstClear then
			DailyService.record(player, "GiantRematch")
		end
	end,
	roundTrip = CaptureService.roundTrip,
	playThrow = CaptureService.play,
	audit = CaptureService.audit,
	finishSerials = SerialGrants.finish,
	notify = function(player, text)
		Net.Notice.Fire(player, { Text = string.sub(text, 1, 120) })
	end,
	save = DataService.saveSoon,
	onEnded = function(player)
		local profile = DataService.get(player)
		if profile then
			BattleFlow.wakeAtHealerIfBeaten(player, profile)
		end
	end,
	log = log,
})

SerialService.start(log)
SerialGrants.start({
	getData = DataService.get,
	changed = StateSync.changed,
	notify = function(player, text)
		Net.Notice.Fire(player, { Text = string.sub(text, 1, 120) })
	end,
	save = DataService.saveSoon,
	log = log,
})
CaptureService.setAlsoPing(GiantService.active) -- a giant capture needs a fresh reading too
CaptureService.start(DataService.get, log, function(player)
	StateSync.changed(player)
	SerialGrants.finish(player) -- a gem-tier catch waits for its serial number
end)
StateSync.start(DataService.get)

InventoryService.start({
	getData = DataService.get,
	changed = StateSync.changed,
	claimWaiting = claimWaiting,
	isLocked = isLocked,
	isUnlocked = isUnlocked,
	notify = function(player, text)
		Net.Notice.Fire(player, { Text = string.sub(text, 1, 120) })
	end,
	log = log,
})

-- Breeding and hatching ----------------------------------------------------------------------

local breeding = BreedingService.new(DataService.get, isLocked, function(profile)
	return isUnlocked(profile, "breeding")
end, log)

Net.RequestBreed.On(function(player, value)
	local ok, detail = breeding:requestBreed(
		player,
		value.ParentA,
		value.ParentB,
		value.CharmSlot,
		value.CharmFavour
	)
	StateSync.changed(player)
	if ok then
		DailyService.record(player, "Breed")
	end
	Net.BreedResult.Fire(player, {
		Ok = ok,
		Reason = if ok then "" else string.sub(tostring(detail), 1, 80),
		HatchAt = if ok and type(detail) == "number" then detail else 0,
	})
end)

task.spawn(function()
	while true do
		task.wait(HATCH_CHECK_SECONDS)
		for _, player in Players:GetPlayers() do
			-- One player's damaged save must never stop hatching for everyone else.
			local ok, problem = pcall(function()
				local hatched = breeding:collectHatched(player)
				local profile = DataService.get(player)
				if profile then
					claimWaiting(player, profile) -- a freed pen may take a waiting gift egg
				end
				if #hatched > 0 then
					local ids = {}
					for index, creature in hatched do
						if index > 8 then
							break -- the rest are in the stable already and show in the state
						end
						table.insert(ids, creature.id)
					end
					StateSync.changed(player)
					Net.Hatched.Fire(player, { Ids = ids })
				end
			end)
			if not ok then
				log("HatchFailed", { player = player.UserId, problem = tostring(problem) })
			end
		end
	end
end)

Players.PlayerRemoving:Connect(function(player)
	breeding:playerRemoving(player)
end)
