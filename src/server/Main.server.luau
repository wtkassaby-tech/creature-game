--!strict
-- Starts the server: saving first, then battles, catching and breeding, all sharing the one
-- loaded profile per player from the data service.
--
-- Not yet in this file, and still to come: the world service (real wild spawns, tamers, giants),
-- battle rewards, the starter pick, quests and the economy screens. Until the world service
-- exists, Studio playtests get a Greenwood wild creature for any wild battle request and a test
-- starter, so the battle and lasso can be tried; neither happens on a live server.
-- Not yet run in Studio.

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Biomes = require(ReplicatedStorage.content.Biomes)
local Breeding = require(ReplicatedStorage.shared.Breeding)
local Grants = require(ReplicatedStorage.shared.Grants)
local Net = require(ReplicatedStorage.net.generated.Server)
local Rng = require(ReplicatedStorage.shared.Rng)
local Types = require(ReplicatedStorage.shared.Types)
local World = require(ReplicatedStorage.shared.World)
local Xp = require(ReplicatedStorage.shared.Xp)

local BattleService = require(script.Parent.Battle.BattleService)
local BreedingService = require(script.Parent.Breeding.BreedingService)
local CaptureService = require(script.Parent.Capture.CaptureService)
local DataService = require(script.Parent.Data.DataService)

local HATCH_CHECK_SECONDS = 5
local IS_STUDIO = RunService:IsStudio()

-- One line per event in the server log, ready for the analytics service later.
local function log(event: string, fields: { [string]: any })
	local ok, text = pcall(HttpService.JSONEncode, HttpService, fields)
	print(`[{event}] {if ok then text else "(fields could not be written)"}`)
end

local random = Random.new()

local function onLoaded(player: Player)
	local profile = DataService.get(player)
	if not profile then
		return
	end
	Grants.rollDay(profile, os.time())
	if IS_STUDIO and #profile.Team == 0 then
		-- Studio only: a test starter until the starter pick exists.
		local id = HttpService:GenerateGUID(false)
		local grant = Grants.giveOnce(profile, "Starter", "studio-test", function()
			return Breeding.wild(
				"Mossmitt",
				id,
				5,
				"Common",
				"Moss",
				Rng.new(random:NextInteger(1, 2147483646))
			)
		end)
		if grant.outcome == "Granted" then
			table.insert(profile.Team, id)
		end
	end
end

DataService.start(log, onLoaded)

local function playerTeam(player: Player): ({ Types.Creature }?, number?)
	local profile = DataService.get(player)
	if not profile then
		return nil, nil
	end
	local team: { Types.Creature } = {}
	for _, id in profile.Team do
		local creature = profile.Creatures[id]
		if creature then
			table.insert(team, creature)
		end
	end
	if #team == 0 then
		return nil, nil
	end
	return team, Xp.levelCap(profile.Story.badges)
end

local function resolveTarget(
	_player: Player,
	kind: string,
	_targetId: number
): BattleService.Opponent?
	if not IS_STUDIO or kind ~= "Wild" then
		return nil -- the world service will look the target up; until then, nothing is available
	end
	local route = Biomes.greenwood.routes[1]
	local pick = World.pickWild(
		route,
		random:NextInteger(1, 2147483646),
		nil,
		HttpService:GenerateGUID(false)
	)
	return { creatures = { pick.creature }, moves = nil, tier = "Wild" }
end

BattleService.start(resolveTarget, playerTeam, function(player, session, outcome)
	-- Battle rewards (coins, XP) come with the economy work; for now the result is logged.
	log("BattleFinished", {
		player = player.UserId,
		battle = session.battleId,
		kind = session.kind,
		outcome = outcome,
	})
end)

CaptureService.start(DataService.get, log)

local breeding = BreedingService.new(DataService.get, BattleService.isInBattle, log)

Net.RequestBreed.On(function(player, value)
	local ok, detail = breeding:requestBreed(
		player,
		value.ParentA,
		value.ParentB,
		value.CharmSlot,
		value.CharmFavour
	)
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
			local hatched = breeding:collectHatched(player)
			if #hatched > 0 then
				local ids = {}
				for index, creature in hatched do
					if index > 8 then
						break -- the rest are in the stable already and show on the next refresh
					end
					table.insert(ids, creature.id)
				end
				Net.Hatched.Fire(player, { Ids = ids })
			end
		end
	end
end)

Players.PlayerRemoving:Connect(function(player)
	breeding:playerRemoving(player)
end)
