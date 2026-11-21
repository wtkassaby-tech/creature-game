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
local LassoConfig = require(ReplicatedStorage.config.LassoConfig)
local Net = require(ReplicatedStorage.net.generated.Server)
local Profile = require(ReplicatedStorage.shared.Profile)

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

function CaptureService.start(getData: GetData, log: Log, changed: (player: Player) -> ()): () -> ()
	local random = Random.new()

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
			missesAfter
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
			})
		else
			misses[player] = { battleId = session.battleId, count = missesAfter }
			if result.judgement.verdict == "Invalid" then
				log("LassoInvalid", { player = player.UserId, reason = result.judgement.reason })
			end
		end
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
		if playing[player] then
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
		local zones = {}
		for _, zone in throw.pattern.zones do
			table.insert(zones, {
				Centre = zone.centre,
				Width = zone.width,
				Speed = zone.speed,
				StartPhase = zone.startPhase,
				StartMs = math.floor(zone.startMs),
			})
		end
		Net.LassoPattern.Fire(player, {
			BattleId = session.battleId,
			ThrowId = throwId,
			Zones = zones,
			SlowMode = throw.pattern.slowMode,
			ConnectionAssist = throw.pattern.connectionAssist,
		})
		task.delay(TIME_LIMIT_SECONDS, resolve, player, throwId)
	end)

	local stopTap = Net.LassoTap.On(function(player, value)
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
		return session ~= nil and session.kind == "Wild"
	end)

	local leaving = Players.PlayerRemoving:Connect(function(player)
		playing[player] = nil
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
