--!strict
-- Loads, upgrades, checks and saves each player's data through ProfileStore (approval pack 1).
--
-- The rules this file keeps:
--   * One record per player, session-locked, so one account cannot be loaded in two servers.
--   * A player whose data fails to load, cannot be upgraded or cannot be read does not play:
--     they are removed, and their saved data is left exactly as it was.
--   * Upgrades run on a copy, before ProfileStore fills in new fields; the upgraded copy replaces
--     the record before anything else can touch it or save it.
--   * If the session ends while the player is still in the game, they are removed at once and
--     `get` stops returning their data in the same moment. A lock is never taken by force.
--   * Problems found by Profile.validate are logged as an alarm; nothing is ever deleted for them.
--
-- ProfileStore calls used here were checked against its source (lm-loleris/profilestore 1.0.3):
-- New, Mock, StartSessionAsync with Cancel, AddUserId, Reconcile, OnSessionEnd, IsActive,
-- EndSession and Save. Not yet run in Studio.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local Profile = require(ReplicatedStorage.shared.Profile)
local ProfileConfig = require(ReplicatedStorage.config.ProfileConfig)
local ProfileStore = require(ServerScriptService.ServerPackages.ProfileStore)

export type Log = (event: string, fields: { [string]: any }) -> ()

local DataService = {}

local storeName = if ProfileConfig.USE_LIVE_STORE
	then ProfileConfig.LIVE_STORE_NAME
	else ProfileConfig.STORE_NAME
local realStore = ProfileStore.New(storeName, Profile.template())
local store = if RunService:IsStudio() and not ProfileConfig.STUDIO_USES_REAL_STORE
	then realStore.Mock
	else realStore

type Session = typeof((nil :: any) :: typeof(store:StartSessionAsync("", {})))

local sessions: { [Player]: any } = {}
local log: Log = function(_event, _fields) end

-- The player's data while their session is live on this server, or nil. Never a stale copy:
-- once the session ends this returns nil, so no service can act on data that will not be saved.
function DataService.get(player: Player): Profile.Profile?
	local session = sessions[player]
	if session == nil or not session:IsActive() then
		return nil
	end
	return session.Data :: Profile.Profile
end

-- Asks for a save as soon as possible (after a purchase, a giant capture or a hatch).
-- This is a request: a crash before it lands puts the record back to the last save.
function DataService.saveSoon(player: Player)
	local session = sessions[player]
	if session ~= nil and session:IsActive() then
		session:Save()
	end
end

local function remove(player: Player, message: string)
	if player.Parent == Players then
		player:Kick(message)
	end
end

local function load(player: Player)
	local session = store:StartSessionAsync(tostring(player.UserId), {
		Cancel = function()
			return player.Parent ~= Players
		end,
	})
	if session == nil then
		-- Data stores are unreachable, the server is closing, or the player left while waiting.
		log("DataLoadFailed", { player = player.UserId })
		return remove(player, "Your save could not be loaded. Nothing was changed. Please rejoin.")
	end

	-- Upgrade first, on a copy; only then fill in fields that are new to the template.
	local upgraded, problem = Profile.migrate(session.Data)
	if upgraded == nil then
		log("DataMigrationRefused", { player = player.UserId, problem = problem })
		session:EndSession()
		return remove(player, "Your save needs a newer version of the game. Please rejoin later.")
	end
	session.Data = upgraded
	session:AddUserId(player.UserId)
	session:Reconcile()

	local problems = Profile.validate(session.Data)
	for _, found in problems do
		if string.sub(found, 1, 10) == "unreadable" then
			log("DataUnreadable", { player = player.UserId, problem = found })
			session:EndSession()
			return remove(
				player,
				"Your save could not be read. Nothing was changed. Please rejoin."
			)
		end
	end
	if #problems > 0 then
		log("DataAlarm", { player = player.UserId, problems = problems })
	end

	session.OnSessionEnd:Connect(function()
		sessions[player] = nil
		remove(
			player,
			"Your session ended. Your progress was saved up to your last save. Please rejoin."
		)
	end)

	if player.Parent ~= Players then
		session:EndSession()
		return
	end
	if session.Data.PlayStats.firstJoin == 0 then
		session.Data.PlayStats.firstJoin = os.time()
	end
	session.Data.PlayStats.sessions += 1
	sessions[player] = session
	log("DataLoaded", { player = player.UserId, problems = #problems })
end

-- Starts the service. `onLoaded` runs once a player's data is ready. Returns a function that
-- stops listening (sessions are still ended when their players leave).
function DataService.start(logger: Log, onLoaded: ((player: Player) -> ())?)
	log = logger
	local function joined(player: Player)
		load(player)
		if onLoaded and DataService.get(player) then
			onLoaded(player)
		end
	end
	for _, player in Players:GetPlayers() do
		task.spawn(joined, player)
	end
	Players.PlayerAdded:Connect(joined)
	Players.PlayerRemoving:Connect(function(player)
		local session = sessions[player]
		sessions[player] = nil
		if session ~= nil then
			session:EndSession()
		end
	end)
end

return DataService
