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

local SAVE_RETRY_SECONDS = 5 -- between save attempts while a purchase waits to be saved

local storeName = if ProfileConfig.USE_LIVE_STORE
	then ProfileConfig.LIVE_STORE_NAME
	else ProfileConfig.STORE_NAME
local realStore = ProfileStore.New(storeName, Profile.template())
local store = if RunService:IsStudio() and not ProfileConfig.STUDIO_USES_REAL_STORE
	then realStore.Mock
	else realStore

type Session = typeof((nil :: any) :: typeof(store:StartSessionAsync("", {})))

local sessions: { [Player]: any } = {}
local MIN_SECONDS_BETWEEN_SAVES = 6
local lastSaved: { [Player]: number } = {}
local saveWaiting: { [Player]: boolean } = {}
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
-- Saves are coalesced: at most one per MIN_SECONDS_BETWEEN_SAVES per player (Roblox allows one
-- write per key every 6 s), with one trailing save if more were asked for in between, so a
-- client that triggers many saves cannot queue unlimited writes.
function DataService.saveSoon(player: Player)
	local session = sessions[player]
	if session == nil or not session:IsActive() then
		return
	end
	if saveWaiting[player] then
		return -- a trailing save is already scheduled and will carry this change
	end
	local last = lastSaved[player]
	local now = os.clock()
	if last == nil or now - last >= MIN_SECONDS_BETWEEN_SAVES then
		lastSaved[player] = now
		session:Save()
		return
	end
	saveWaiting[player] = true
	task.delay(MIN_SECONDS_BETWEEN_SAVES - (now - last), function()
		saveWaiting[player] = nil
		local current = sessions[player]
		if current == session and session:IsActive() then
			lastSaved[player] = os.clock()
			session:Save()
		end
	end)
end

-- Waits until `isSaved` is true of the data ProfileStore last wrote to the data store, asking for
-- saves as it goes, and returns true. Returns false if the session ends first (the player left and
-- the save did not land). Used to answer Roblox's ProcessReceipt only once a purchase is really
-- saved (ProfileStore's developer-product guide, "caching PurchaseIds"). It yields.
function DataService.waitSaved(player: Player, isSaved: (saved: any) -> boolean): boolean
	local session = sessions[player]
	if session == nil then
		return false
	end
	while session:IsActive() do
		if isSaved(session.LastSavedData) then
			return true
		end
		local before = session.LastSavedData
		session:Save()
		if session.LastSavedData == before then
			-- A failed save never fires OnAfterSave, so wait for it or for the retry time,
			-- whichever comes first (otherwise one failed save stalls this until autosave).
			local thread = coroutine.running()
			local resumed = false
			local function wake()
				if not resumed then
					resumed = true
					task.spawn(thread)
				end
			end
			local connection = session.OnAfterSave:Connect(wake)
			task.delay(SAVE_RETRY_SECONDS, wake)
			coroutine.yield()
			connection:Disconnect()
		end
		if isSaved(session.LastSavedData) then
			return true
		end
		if session:IsActive() then
			task.wait(SAVE_RETRY_SECONDS)
		end
	end
	return isSaved(session.LastSavedData)
end

local function remove(player: Player, message: string)
	if player.Parent == Players then
		player:Kick(message)
	end
end

-- Everything after the session starts. Split out so `load` can end the session if it throws.
-- A damaged PlayStats record is repaired before the save is checked (it is only a counter), so it
-- never shuts a player out. A number that is not finite counts as damaged: it could never be saved.
local function counter(value: unknown): number
	if
		typeof(value) == "number"
		and value == value
		and value ~= math.huge
		and value ~= -math.huge
	then
		return value
	end
	return 0
end

local function repairStats(data: Profile.Profile)
	local stats: any = data.PlayStats
	if typeof(stats) ~= "table" then
		data.PlayStats = { firstJoin = 0, playSeconds = 0, sessions = 0 }
		return
	end
	stats.firstJoin = counter(stats.firstJoin)
	stats.playSeconds = counter(stats.playSeconds)
	stats.sessions = counter(stats.sessions)
end

local function prepare(player: Player, session: any)
	-- Upgrade first, on a copy; only then fill in fields that are new to the template.
	-- Kept so a refused save is written back exactly as it was found.
	local original = session.Data
	local upgraded, problem = Profile.migrate(original)
	if upgraded == nil then
		log("DataMigrationRefused", { player = player.UserId, problem = problem })
		session:EndSession()
		return remove(player, "Your save needs a newer version of the game. Please rejoin later.")
	end
	session.Data = upgraded
	session:AddUserId(player.UserId)
	session:Reconcile()
	repairStats(session.Data)

	local problems = Profile.validate(session.Data)
	for _, found in problems do
		-- Unreadable data, or data that could never be saved (every save would fail and progress
		-- would be lost silently), is refused and left as it was.
		if
			string.sub(found, 1, 10) == "unreadable"
			or string.sub(found, 1, 15) == "cannot be saved"
		then
			log("DataUnreadable", { player = player.UserId, problem = found })
			session.Data = original
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
	local stats = session.Data.PlayStats
	if stats.firstJoin == 0 then
		stats.firstJoin = os.time()
	end
	stats.sessions += 1
	sessions[player] = session
	log("DataLoaded", {
		player = player.UserId,
		problems = #problems,
		sessions = session.Data.PlayStats.sessions,
	})
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
	local original = session.Data
	local ok, problem = pcall(function()
		prepare(player, session)
	end)
	if not ok then
		-- Anything that throws after the session started must not leave the lock held with the
		-- player playing on no data: put the record back as found, release the lock, remove them.
		log("DataLoadFailed", { player = player.UserId, problem = tostring(problem) })
		sessions[player] = nil
		session.Data = original
		session:EndSession()
		remove(player, "Your save could not be loaded. Nothing was changed. Please rejoin.")
	end
end

-- Starts the service. `onLoaded` runs once a player's data is ready. Returns a function that
-- stops new joins (sessions are still ended when their players leave).
function DataService.start(logger: Log, onLoaded: ((player: Player) -> ())?): () -> ()
	log = logger
	local function joined(player: Player)
		-- StartSessionAsync itself can throw; the player must not stay in the game unloaded.
		local ok, problem = pcall(function()
			load(player)
		end)
		if not ok then
			log("DataLoadFailed", { player = player.UserId, problem = tostring(problem) })
			sessions[player] = nil
			remove(player, "Your save could not be loaded. Nothing was changed. Please rejoin.")
			return
		end
		if onLoaded and DataService.get(player) then
			onLoaded(player)
		end
	end
	for _, player in Players:GetPlayers() do
		task.spawn(joined, player)
	end
	local added = Players.PlayerAdded:Connect(joined)
	Players.PlayerRemoving:Connect(function(player)
		local session = sessions[player]
		sessions[player] = nil
		lastSaved[player] = nil
		saveWaiting[player] = nil
		if session ~= nil then
			session:EndSession()
		end
	end)
	-- Stopping only stops new joins: players who leave afterwards must still have their sessions
	-- ended, so `removing` stays connected (exploit review, 23 November 2026).
	return function()
		added:Disconnect()
	end
end

return DataService
