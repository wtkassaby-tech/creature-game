--!strict
-- Finds in side areas and dead ends on the server (approval pack 7, docs/plans/14_FINDS_AND_
-- REWARDS.md): caches, gathering spots, notes and cairns claimed with `Search`, and sightings at
-- marked rustle spots. The rules are in src/shared/Finds; this file only reads the character's
-- position, keeps a short trail of it, answers, saves and logs.
--
-- What it keeps to (the pack's section 5b, in this order):
--   1. One search a second per player, checked before anything else is read.
--   2. The id must name a find of an open biome and the player's data must be loaded and free.
--   3. The biome may be entered, the find's place is built, and a gathering spot has its badge.
--   4. Position, from the server's own reading of the character: within the search radius plus
--      the usual slack, at the find's height, lingered there a moment, no jump in the trail.
--   5. The limit and the carry room, then one step with no pause: flag or count, items, Prism.
--   6. Every claim and every refusal is logged with the find id and the player.
-- Nothing the device sends but the find id is read. Not yet run in Studio.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EconomyConfig = require(ReplicatedStorage.config.EconomyConfig)
local Encounters = require(ReplicatedStorage.shared.Encounters)
local FindTrail = require(ReplicatedStorage.shared.FindTrail)
local Finds = require(ReplicatedStorage.shared.Finds)
local FindsConfig = require(ReplicatedStorage.config.FindsConfig)
local Ground = require(ReplicatedStorage.shared.Ground)
local Layout = require(ReplicatedStorage.shared.Layout)
local Net = require(ReplicatedStorage.net.generated.Server)
local Profile = require(ReplicatedStorage.shared.Profile)
local WorldTypes = require(ReplicatedStorage.shared.WorldTypes)

export type Hooks = {
	getData: (player: Player) -> Profile.Profile?,
	isReady: (player: Player) -> boolean, -- data loaded and not in a battle
	mayEnter: (player: Player, biomeNumber: number) -> boolean,
	position: (player: Player) -> Layout.Point?, -- the server's reading of the character
	-- True when the point is inside a stretch the story has not opened for this player.
	isHeld: (player: Player, point: Layout.Point) -> boolean,
	biomeMap: (biomeNumber: number) -> Layout.Map,
	biomes: () -> { WorldTypes.Biome },
	changed: (player: Player) -> (),
	save: (player: Player) -> (),
	log: (event: string, fields: { [string]: any }) -> (),
}

local FindService = {}

local hooks: Hooks
local trails: { [Player]: FindTrail.Trail } = {}
local lastSearch: { [Player]: number } = {}
local farRefusals: { [Player]: { number } } = {}
local grounds: { [number]: Ground.Ground } = {}

local function trailOf(player: Player): FindTrail.Trail
	local found = trails[player]
	if found then
		return found
	end
	local made = FindTrail.new()
	trails[player] = made
	return made
end

-- Forgets where the player has been: called when the server itself moves them (a Waystation, a
-- ride), so that move is never counted as a jump.
function FindService.resetTrail(player: Player)
	local found = trails[player]
	if found then
		FindTrail.reset(found)
	end
end

local function groundOf(biomeNumber: number): Ground.Ground
	local found = grounds[biomeNumber]
	if found then
		return found
	end
	local map = hooks.biomeMap(biomeNumber)
	local sheet: WorldTypes.MapSheet? = nil
	for _, biome in hooks.biomes() do
		if biome.number == biomeNumber then
			sheet = biome.map
		end
	end
	local made = Ground.new(sheet, { x = map.hub.x, z = map.hub.z })
	grounds[biomeNumber] = made
	return made
end

-- How high the character's root part is above the world's floor, by the server's own reading.
local function rootHeight(player: Player): number?
	local character = player.Character
	local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
	if root and root:IsA("BasePart") then
		return root.Position.Y
	end
	return nil
end

local function reply(player: Player, findId: string, outcome: Finds.Outcome, claim: Finds.Claim?)
	local gains: { { Item: string, Count: number } } = {}
	local prism = 0
	if claim then
		for index, gain in claim.gains do
			if index > 8 then
				break
			end
			table.insert(gains, { Item = gain.item, Count = math.clamp(gain.count, 0, 65535) })
		end
		prism = math.clamp(claim.prism, 0, 255)
	end
	Net.SearchResult.Fire(player, {
		FindId = findId,
		Outcome = outcome,
		Gains = gains,
		Prism = prism,
		SetDone = claim ~= nil and claim.setDone,
	})
end

-- Counts a refusal for being far from the find, and raises an alarm for a burst of them.
local function noteFar(player: Player, now: number)
	local list = farRefusals[player]
	if not list then
		list = {}
		farRefusals[player] = list
	end
	table.insert(list, now)
	while #list > 0 and now - list[1] > FindsConfig.FAR_ALARM_SECONDS do
		table.remove(list, 1)
	end
	if #list > FindsConfig.FAR_ALARM_COUNT then
		hooks.log("SearchFarAlarm", { player = player.UserId, refusals = #list })
		table.clear(list)
	end
end

local function search(player: Player, findId: string)
	local now = os.clock()
	-- 1. The rate limit, before anything else is read.
	if now - (lastSearch[player] or -math.huge) < FindsConfig.MIN_SECONDS_BETWEEN_SEARCHES then
		return
	end
	lastSearch[player] = now

	-- 2. The record is loaded and its session held, and the player is free (no battle).
	local profile = hooks.getData(player)
	if not profile or not hooks.isReady(player) then
		hooks.log("SearchRefused", {
			player = player.UserId,
			find = findId,
			outcome = "NotReady",
			reason = if profile then "busy (a battle or a trade)" else "save not loaded",
		})
		return
	end
	local find = Finds.lookup(findId)
	local function refused(outcome: Finds.Outcome, reason: string, distance: number?)
		hooks.log("SearchRefused", {
			player = player.UserId,
			find = findId,
			reason = reason,
			outcome = outcome,
			distance = distance,
		})
		reply(player, findId, outcome, nil)
	end
	if not find then
		return refused("Shut", "unknown")
	end

	-- 3. Gating: the biome may be entered, the place is built, gathering has its badge.
	if find.pending or find.kind == "Sighting" then
		return refused("Shut", "not built")
	end
	if not hooks.mayEnter(player, find.biome) then
		return refused("Shut", "biome")
	end
	if not Finds.opensWith(find, profile.Story.badges) then
		return refused("Shut", "badge")
	end

	-- 4. Position, from the server's own readings.
	local at = hooks.position(player)
	local root = rootHeight(player)
	local point = Finds.point(hooks.biomeMap(find.biome), find)
	if not at or not root or not point then
		return refused("TooFar", "no position")
	end
	-- A find inside a stretch the story holds is shut, wherever the player claims to stand.
	if hooks.isHeld(player, point) or hooks.isHeld(player, at) then
		return refused("Shut", "held by the story")
	end
	local trail = trailOf(player)
	FindTrail.record(trail, now, at.x, at.z)
	local distance = Layout.distance(at, point)
	local ground = groundOf(find.biome)
	local reach: Finds.Reach = {
		distance = distance,
		heightGap = (root - FindsConfig.ROOT_HEIGHT) - Ground.heightAt(ground, point.x, point.z),
		lingered = FindTrail.lingered(trail, point.x, point.z, FindsConfig.SEARCH_RADIUS),
		fastest = FindTrail.fastest(trail, now),
	}
	local problem = Finds.reachProblem(reach)
	if problem then
		if problem == "far" then
			noteFar(player, now)
		end
		return refused("TooFar", problem, distance)
	end

	-- 5. The limit, the room, and one step with no pause (inside Finds.claim).
	local claim = Finds.claim(profile, find, os.time())
	if claim.outcome == "AlreadyFound" or claim.outcome == "Resting" or claim.outcome == "Full" then
		return refused(claim.outcome, claim.reason or "limit", distance)
	elseif claim.outcome == "Shut" then
		return refused("Shut", claim.reason or "shut", distance)
	end

	-- 6. Tell the device, save, and log with the ids.
	reply(player, findId, claim.outcome, claim)
	hooks.changed(player)
	hooks.save(player)
	local items: { { item: string, count: number } } = {}
	for _, gain in claim.gains do
		table.insert(items, { item = gain.item, count = gain.count })
	end
	if find.kind == "Gather" then
		local total = 0
		for _, gain in claim.gains do
			total += gain.count
		end
		hooks.log("FindGathered", {
			player = player.UserId,
			spot = find.id,
			biome = find.biome,
			items = items,
			count = total,
			gatheredToday = profile.Daily.finds[FindsConfig.GATHERED_KEY] or 0,
		})
	else
		hooks.log("FindClaimed", {
			player = player.UserId,
			find = find.id,
			kind = find.kind,
			biome = find.biome,
			items = items,
			prism = claim.prism,
			set = if claim.set then claim.set.id else nil,
			day = profile.Daily.day,
		})
	end
end

-- Called by the world service when a rustle spot is stirred: the sighting rule for that spot, or
-- nil if it is not a sighting spot or its sighting has been used today. Changes nothing but the
-- day's counters rolling forward.
function FindService.sightingFor(player: Player, spotId: string): Encounters.Sighting?
	local profile = hooks.getData(player)
	local find = Finds.sightingAt(spotId)
	if not profile or not find then
		return nil
	end
	if not Finds.sightingFree(profile, find, os.time()) then
		return nil
	end
	local gem = if find.biome >= FindsConfig.SIGHTING_GEM_MIN_BIOME
		then EconomyConfig.GEM_WILD_SHARE
		else 0
	return { gemChance = gem }
end

-- Called in the same step that a sighting's creature steps out: counts the use, so walking away
-- and stirring again cannot reroll it.
function FindService.sighted(player: Player, spotId: string, spawn: Encounters.Spawn)
	local profile = hooks.getData(player)
	local find = Finds.sightingAt(spotId)
	if not profile or not find then
		return
	end
	if Finds.markSighting(profile, find, os.time()) then
		hooks.changed(player)
		hooks.log("FindSighted", {
			player = player.UserId,
			spot = find.id,
			rustleSpot = spotId,
			spawn = spawn.id,
			creature = spawn.creature.id,
			species = spawn.creature.parts.Torso.species,
			rarity = spawn.creature.rarity,
		})
	end
end

function FindService.start(given: Hooks): () -> ()
	hooks = given
	local stopSearch = Net.Search.On(function(player, value)
		-- One player's trouble must never stop the service for everyone else.
		local ok, problem = pcall(function()
			search(player, value.FindId)
		end)
		if not ok then
			hooks.log("SearchFailed", {
				player = player.UserId,
				find = value.FindId,
				problem = tostring(problem),
			})
		end
	end)

	local running = true
	task.spawn(function()
		while running do
			local now = os.clock()
			for _, player in Players:GetPlayers() do
				local at = hooks.position(player)
				if at then
					FindTrail.record(trailOf(player), now, at.x, at.z)
				end
			end
			task.wait(FindsConfig.TRAIL_SAMPLE_SECONDS)
		end
	end)

	-- A respawn moves the character by the game's own hand: forget the trail, so an honest
	-- player is not refused as a "jump" for the next few seconds (review, 23 Nov 2026).
	local respawns: { [Player]: RBXScriptConnection } = {}
	local function watch(player: Player)
		respawns[player] = player.CharacterAdded:Connect(function()
			FindService.resetTrail(player)
		end)
	end
	for _, player in Players:GetPlayers() do
		watch(player)
	end
	local joining = Players.PlayerAdded:Connect(watch)

	local leaving = Players.PlayerRemoving:Connect(function(player)
		trails[player] = nil
		lastSearch[player] = nil
		farRefusals[player] = nil
		local watching = respawns[player]
		if watching then
			watching:Disconnect()
			respawns[player] = nil
		end
	end)
	return function()
		running = false
		stopSearch()
		leaving:Disconnect()
		joining:Disconnect()
		for _, connection in respawns do
			connection:Disconnect()
		end
	end
end

return FindService
