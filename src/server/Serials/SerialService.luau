--!strict
-- Serial numbers: one global counter for each kind (each giant), kept in its own data store
-- outside any player's record, and a registry of which player holds each number.
--
-- A number is taken with Roblox's atomic update, so two servers can never be given the same
-- one. Taking a number waits on the data store, so callers must check the player's record
-- again afterwards. A number that is taken and then not used is skipped for ever: numbers can
-- have gaps but are never given twice (approval pack 2, section 5).
--
-- In Studio the counters live in memory unless ProfileConfig.STUDIO_USES_REAL_STORE is set, so
-- a test session never uses up real numbers.
-- Not yet run in Studio.

local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ProfileConfig = require(ReplicatedStorage.config.ProfileConfig)

local ATTEMPTS = 3
local SECONDS_BETWEEN_ATTEMPTS = 2

export type Log = (event: string, fields: { [string]: any }) -> ()

local SerialService = {}

local useMemory = RunService:IsStudio() and not ProfileConfig.STUDIO_USES_REAL_STORE
local memory: { [string]: number } = {}
local broken: { [string]: boolean } = {}
local store: DataStore? = nil
local log: Log = function(_event: string, _fields: { [string]: any }) end

local function getStore(): DataStore
	local found = store
	if found then
		return found
	end
	local name = if ProfileConfig.USE_LIVE_STORE
		then ProfileConfig.LIVE_SERIAL_STORE_NAME
		else ProfileConfig.SERIAL_STORE_NAME
	local made = DataStoreService:GetDataStore(name)
	store = made
	return made
end

function SerialService.start(logger: Log)
	log = logger
end

-- Takes the next number for a kind ("Giant:greenwood_hollowbough"). Waits on the data store.
-- Returns nil if the store could not be reached; nothing is taken then.
-- True for a kind whose counter was found damaged: it gives no more numbers until the server
-- restarts and a person has looked at it.
function SerialService.isBroken(kind: string): boolean
	return broken[kind] == true
end

function SerialService.next(kind: string): number?
	if broken[kind] then
		return nil
	end
	if useMemory then
		memory[kind] = (memory[kind] or 0) + 1
		return memory[kind]
	end
	local damaged = false
	for attempt = 1, ATTEMPTS do
		local ok, value = pcall(function()
			return getStore():UpdateAsync(`counter/{kind}`, function(current)
				if current == nil then
					return 1 -- the first of its kind
				elseif typeof(current) ~= "number" then
					-- A counter that is not a number must never be treated as zero: that
					-- would give out numbers a second time. Leave it alone and raise an alarm.
					damaged = true
					return nil
				end
				return current + 1
			end)
		end)
		if damaged then
			broken[kind] = true
			log("SerialAlarm", { kind = kind, problem = "the counter is not a number" })
			return nil
		end
		if ok and typeof(value) == "number" then
			return value
		end
		log("SerialFetchFailed", { kind = kind, attempt = attempt, problem = tostring(value) })
		if attempt < ATTEMPTS then
			task.wait(SECONDS_BETWEEN_ATTEMPTS)
		end
	end
	return nil
end

-- Writes down who holds a number, only if nobody does yet. A number that already has a
-- different owner raises an alarm in the log: it should never happen.
function SerialService.register(kind: string, serial: number, userId: number)
	if useMemory then
		return
	end
	local ok, problem = pcall(function()
		local taken: number? = nil
		getStore():UpdateAsync(`owner/{kind}/{serial}`, function(current)
			if current == nil then
				return userId
			end
			taken = if typeof(current) == "number" then current else -1
			return nil -- leave it as it is
		end)
		if taken ~= nil and taken ~= userId then
			log("SerialAlarm", { kind = kind, serial = serial, owner = taken, claimedBy = userId })
		end
	end)
	if not ok then
		log("SerialRegisterFailed", { kind = kind, serial = serial, problem = tostring(problem) })
	end
end

return SerialService
