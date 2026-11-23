--!strict
-- Lasso throws in wild battles, on the network (approval pack 2 section 3). The rules are in
-- src/shared/Capture.luau; this file only connects them to the messages in src/net/Net.blink.
--
--   ThrowLasso  -> Capture.begin takes the lasso and builds the sweep -> LassoPattern
--   LassoTap    -> each tap is stamped with the server's own clock on arrival
--   last tap, or the time limit -> Capture.finish -> LassoResult, then the battle turn
--
-- While a throw is being played no battle action is accepted, so nothing can slip in between.
-- Every capture is logged with the creature's id.
-- Not yet run in Studio.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BattleSession = require(ReplicatedStorage.shared.BattleSession)
local Capture = require(ReplicatedStorage.shared.Capture)
local Grants = require(ReplicatedStorage.shared.Grants)
local Lasso = require(ReplicatedStorage.shared.Lasso)
local LassoConfig = require(ReplicatedStorage.config.LassoConfig)
local Net = require(ReplicatedStorage.net.generated.Server)
local Profile = require(ReplicatedStorage.shared.Profile)
local Rng = require(ReplicatedStorage.shared.Rng)

local BattleService = require(script.Parent.Parent.Battle.BattleService)
local RoundTrip = require(script.Parent.RoundTrip)

export type GetData = (player: Player) -> Profile.Profile?
export type Log = (event: string, fields: { [string]: any }) -> ()

local MIN_SECONDS_BETWEEN_THROWS = 0.5
-- A throw is judged when its last tap arrives, or this long after the sweep was sent.
local TIME_LIMIT_SECONDS = (LassoConfig.MAX_ATTEMPT_MS + LassoConfig.ROUND_TRIP_CAP_MS) / 1000 + 1

type Playing = {
	throwId: number,
	throw: Capture.Throw,
	session: BattleSession.Session,
	startedAt: number, -- os.clock() when the sweep was sent
	claims: { number },
	arrivals: { number },
	misses: number, -- misses before this throw
}

local CaptureService = {}

local playing: { [Player]: Playing } = {}
local misses: { [Player]: { battleId: number, count: number } } = {}
local lastThrow: { [Player]: number } = {}
local nextThrowId = 0

local function missesSoFar(player: Player, battleId: number): number
	local entry = misses[player]
	if entry and entry.battleId == battleId then
		return entry.count
	end
	return 0
end

-- `changed` is told whenever a throw changes the player's saved state (a lasso spent, a catch).
-- The battle service tells us how many throws this wild creature has already dodged (it may have
-- been battled before), and reads the count back when the battle ends.
function CaptureService.setMisses(player: Player, battleId: number, count: number)
	misses[player] = { battleId = battleId, count = count }
end

function CaptureService.missesFor(player: Player, battleId: number): number
	return missesSoFar(player, battleId)
end

-- Timing audit. Every judged throw adds how far each tap was from its loop's centre to the
-- player's recent taps; when nearly all of them are closer than a person can manage, the account
-- is flagged in the log for a human to look at (Lasso.looksScripted). Nothing is refused here.
-- The list lives in server memory for this visit; the log line is what lasts.
local KEEP_TAP_ERRORS = 60
local tapErrors: { [Player]: { number } } = {}
local flagged: { [Player]: boolean } = {}
local auditLog: Log = function(_event: string, _fields: { [string]: any }) end

function CaptureService.audit(player: Player, errorsMs: { number })
	local list = tapErrors[player]
	if not list then
		list = {}
		tapErrors[player] = list
	end
	for _, errorMs in errorsMs do
		if typeof(errorMs) == "number" and errorMs == errorMs then
			table.insert(list, math.abs(errorMs))
		end
	end
	while #list > KEEP_TAP_ERRORS do
		table.remove(list, 1)
	end
	if not flagged[player] and Lasso.looksScripted(list) then
		flagged[player] = true -- once a visit is enough
		auditLog("LassoSuspicious", { player = player.UserId, taps = #list })
	end
end

-- A throw played for another service (a giant capture): this service sends the sweep, stamps
-- each tap on arrival and hands both lists to `onDone` when the last tap lands or time runs out.
type External = {
	throwId: number,
	zones: number,
	startedAt: number,
	claims: { number },
	arrivals: { number },
	onDone: (claims: { number }, arrivals: { number }, throwId: number) -> (),
}
local external: { [Player]: External } = {}

local function sendPattern(
	player: Player,
	battleId: number,
	throwId: number,
	pattern: Lasso.Pattern
)
	local zones = {}
	for _, zone in pattern.zones do
		table.insert(zones, {
			Centre = zone.centre,
			Width = zone.width,
			Speed = zone.speed,
			StartPhase = zone.startPhase,
			StartMs = math.floor(zone.startMs),
		})
	end
	Net.LassoPattern.Fire(player, {
		BattleId = battleId,
		ThrowId = throwId,
		Zones = zones,
		SlowMode = pattern.slowMode,
		ConnectionAssist = pattern.connectionAssist,
	})
end

local function finishExternal(player: Player, throwId: number)
	local current = external[player]
	if not current or current.throwId ~= throwId then
		return -- already judged
	end
	external[player] = nil
	current.onDone(current.claims, current.arrivals, throwId)
end

-- Plays a sweep for another service. Returns false if a throw is already in the air.
function CaptureService.play(
	player: Player,
	pattern: Lasso.Pattern,
	battleId: number,
	onDone: (claims: { number }, arrivals: { number }, throwId: number) -> ()
): boolean
	if playing[player] or external[player] then
		return false
	end
	nextThrowId = (nextThrowId + 1) % 4294967295
	local throwId = nextThrowId
	external[player] = {
		throwId = throwId,
		zones = #pattern.zones,
		startedAt = os.clock(),
		claims = {},
		arrivals = {},
		onDone = onDone,
	}
	sendPattern(player, battleId, throwId, pattern)
	task.delay(TIME_LIMIT_SECONDS, finishExternal, player, throwId)
	return true
end

-- The server's own round-trip reading for this player, for building a sweep.
function CaptureService.roundTrip(player: Player): number
	return RoundTrip.trustedMs(player)
end

-- Other times the round trip should be measured (a giant fight, a capture offer).
local alsoPing: (player: Player) -> boolean = function(_player: Player)
	return false
end
function CaptureService.setAlsoPing(check: (player: Player) -> boolean)
	alsoPing = check
end

function CaptureService.start(getData: GetData, log: Log, changed: (player: Player) -> ()): () -> ()
	local random = Random.new()
	auditLog = log

	local function resolve(player: Player, throwId: number)
		local current = playing[player]
		if not current or current.throwId ~= throwId then
			return -- already judged
		end
		playing[player] = nil
		local profile = getData(player)
		local session = current.session
		if not profile or BattleService.session(player) ~= session then
			return -- the player left or the battle ended; the lasso stays spent
		end
		Grants.rollDay(profile, os.time()) -- the catch falloff counts by the server's date
		local missesAfter = current.misses + 1
		local result, problem = Capture.finish(
			profile,
			session,
			current.throw,
			current.claims,
			current.arrivals,
			missesAfter,
			Rng.new(random:NextInteger(1, 2147483646)) -- the server's own dice, never a client value
		)
		if not result then
			log("LassoUnjudged", { player = player.UserId, problem = problem })
			return
		end
		local hits = 0
		for _, hit in result.judgement.zoneHits do
			if hit then
				hits += 1
			end
		end
		if result.outcome == "Caught" then
			local creature = BattleSession.foe(session)
			log("Capture", {
				player = player.UserId,
				creature = creature.id,
				species = creature.parts.Torso.species,
				rarity = creature.rarity,
				candy = result.candy,
				element = result.element,
				chance = result.chance,
				roll = result.roll,
				roundTripMs = math.round(current.throw.pattern.roundTripMs),
			})
		else
			misses[player] = { battleId = session.battleId, count = missesAfter }
			-- Missed and Fled apart; a roll under the chance that still missed means the grant
			-- was refused (a full stable). The round trip shows how much the slow-connection
			-- assist slowed the marker.
			log("LassoMissed", {
				player = player.UserId,
				creature = BattleSession.foe(session).id,
				outcome = result.outcome,
				chance = result.chance,
				roll = result.roll,
				roundTripMs = math.round(current.throw.pattern.roundTripMs),
			})
			if result.judgement.verdict == "Invalid" then
				-- The numbers behind the verdict, so a window that is too tight shows in the log.
				log("LassoInvalid", {
					player = player.UserId,
					reason = result.judgement.reason,
					claimMs = math.round(current.claims[1] or -1),
					arrivalMs = math.round(current.arrivals[1] or -1),
					roundTripMs = math.round(current.throw.pattern.roundTripMs),
				})
			end
		end
		CaptureService.audit(player, result.judgement.errorsMs)
		changed(player)
		Net.LassoResult.Fire(player, {
			ThrowId = throwId,
			Outcome = result.outcome,
			ZonesHit = hits,
			Candy = math.clamp(math.floor(result.candy or 0), 0, 65535),
			Element = result.element,
		})
		BattleService.publishTurn(player, session, result.turn)
	end

	local stopThrow = Net.ThrowLasso.On(function(player, value)
		local now = os.clock()
		if now - (lastThrow[player] or -math.huge) < MIN_SECONDS_BETWEEN_THROWS then
			return
		end
		lastThrow[player] = now
		if playing[player] or external[player] then
			return BattleService.refuse(player, "A throw is already in the air")
		end
		local session = BattleService.session(player)
		if not session or session.battleId ~= value.BattleId then
			return BattleService.refuse(player, "That battle is over")
		end
		local profile = getData(player)
		if not profile then
			return BattleService.refuse(player, "Your data is not loaded")
		end
		local before = missesSoFar(player, session.battleId)
		local throw, problem = Capture.begin({
			profile = profile,
			session = session,
			turn = value.Turn,
			tier = value.Tier,
			seed = random:NextInteger(1, 2147483646),
			roundTripMs = RoundTrip.trustedMs(player),
			nowMs = 0,
			misses = before,
		})
		if not throw then
			return BattleService.refuse(player, problem or "You cannot throw now")
		end
		changed(player) -- the lasso is spent
		nextThrowId = (nextThrowId + 1) % 4294967295
		local throwId = nextThrowId
		playing[player] = {
			throwId = throwId,
			throw = throw,
			session = session,
			startedAt = os.clock(),
			claims = {},
			arrivals = {},
			misses = before,
		}
		sendPattern(player, session.battleId, throwId, throw.pattern)
		task.delay(TIME_LIMIT_SECONDS, resolve, player, throwId)
	end)

	local stopTap = Net.LassoTap.On(function(player, value)
		local other = external[player]
		if other and other.throwId == value.ThrowId then
			if value.Zone == #other.claims + 1 then
				table.insert(other.claims, value.ClaimMs)
				table.insert(other.arrivals, (os.clock() - other.startedAt) * 1000)
				if #other.claims >= other.zones then
					finishExternal(player, other.throwId)
				end
			end
			return
		end
		local current = playing[player]
		if not current or current.throwId ~= value.ThrowId then
			return
		end
		-- Taps are taken in order, one per zone; a repeat or a skipped zone is ignored.
		if value.Zone ~= #current.claims + 1 then
			return
		end
		table.insert(current.claims, value.ClaimMs)
		table.insert(current.arrivals, (os.clock() - current.startedAt) * 1000)
		if #current.claims >= #current.throw.pattern.zones then
			resolve(player, current.throwId)
		end
	end)

	BattleService.setBusyCheck(function(player)
		return playing[player] ~= nil
	end)

	local stopPing = RoundTrip.start(function(player)
		local session = BattleService.session(player)
		return (session ~= nil and session.kind == "Wild") or alsoPing(player)
	end)

	local leaving = Players.PlayerRemoving:Connect(function(player)
		playing[player] = nil
		tapErrors[player] = nil
		flagged[player] = nil
		external[player] = nil
		misses[player] = nil
		lastThrow[player] = nil
	end)

	return function()
		stopThrow()
		stopTap()
		stopPing()
		leaving:Disconnect()
	end
end

return CaptureService
