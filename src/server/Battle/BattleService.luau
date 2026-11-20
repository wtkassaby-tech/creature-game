--!strict
-- Connects the battle session (src/shared/BattleSession.luau) to the network messages in
-- src/net/Net.blink. One battle per player at a time. Battles are not saved: if the player
-- leaves, the battle is dropped and anything it would have paid is not paid.
--
-- The world service supplies `resolveTarget`: given the player and the id of something they
-- tapped, it returns the opponent (checking it exists, is near and is free), or nil. Rewards are
-- paid by `onFinished`, which belongs to the economy and saving work (approval packs 1 to 3).
--
-- Not yet run in Studio.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BattleAi = require(ReplicatedStorage.shared.BattleAi)
local BattleSession = require(ReplicatedStorage.shared.BattleSession)
local Net = require(ReplicatedStorage.net.generated.Server)
local Types = require(ReplicatedStorage.shared.Types)

export type Opponent = {
	creatures: { Types.Creature },
	moves: { { string } }?,
	tier: BattleAi.Tier,
}
export type ResolveTarget = (
	player: Player,
	kind: BattleSession.Kind,
	targetId: number
) -> Opponent?
-- The player's team and level cap, or nil if their data is not loaded.
export type PlayerTeam = (player: Player) -> ({ Types.Creature }?, number?)
export type OnFinished = (player: Player, session: BattleSession.Session, outcome: number) -> ()

local MIN_SECONDS_BETWEEN_ACTIONS = 0.25

local BattleService = {}

local sessions: { [Player]: BattleSession.Session } = {}
local lastAction: { [Player]: number } = {}
local nextBattleId = 0

local function toWire(creatures: { BattleSession.CreatureView }): { any }
	local list = {}
	for _, c in creatures do
		table.insert(list, {
			Id = c.id,
			BodyPlan = c.bodyPlan,
			Head = c.parts.Head,
			Torso = c.parts.Torso,
			FrontLimbs = c.parts.FrontLimbs,
			Legs = c.parts.Legs,
			Tail = c.parts.Tail,
			Colour = c.colour,
			Size = c.size,
			Rarity = c.rarity,
			Element = c.element,
			Level = c.level,
			MaxHp = c.maxHp,
			Hp = c.hp,
			Moves = c.moves,
		})
	end
	return list
end

local function refuse(player: Player, reason: string)
	Net.BattleRefused.Fire(player, { Reason = string.sub(reason, 1, 80) })
end
BattleService.refuse = refuse

-- Set by the capture service: true while a lasso throw is being played, so no battle action can
-- slip in between the throw and its result.
local busy: (player: Player) -> boolean = function()
	return false
end
function BattleService.setBusyCheck(check: (player: Player) -> boolean)
	busy = check
end

local finished: OnFinished = function() end

-- Sends a turn to the device, and ends the battle if the turn finished it. Used by battle
-- actions and by lasso throws, so both end a battle the same way.
function BattleService.publishTurn(
	player: Player,
	session: BattleSession.Session,
	turn: BattleSession.TurnResult
)
	local events = {}
	for _, event in turn.events do
		table.insert(events, {
			Side = event.side,
			Kind = event.kind,
			Move = event.move,
			Damage = event.damage or 0,
			TargetHp = event.targetHp or 0,
			Slot = event.slot or 0,
		})
	end
	Net.BattleTurn.Fire(player, {
		BattleId = turn.battleId,
		Turn = turn.turn,
		Events = events,
		YourActive = turn.yourActive,
		TheirActive = turn.theirActive,
		YourTempo = turn.yourTempo,
		TheirTempo = turn.theirTempo,
		Previews = turn.previews,
		Finished = turn.finished,
		Outcome = turn.outcome,
	})
	if turn.finished and sessions[player] == session then
		sessions[player] = nil
		finished(player, session, turn.outcome)
	end
end

-- The player's current battle, or nil.
function BattleService.session(player: Player): BattleSession.Session?
	return sessions[player]
end

function BattleService.start(
	resolveTarget: ResolveTarget,
	playerTeam: PlayerTeam,
	onFinished: OnFinished
): () -> ()
	local random = Random.new()
	finished = onFinished

	local stopStart = Net.StartBattle.On(function(player, value)
		if sessions[player] then
			return refuse(player, "You are already in a battle")
		end
		local creatures, cap = playerTeam(player)
		if not creatures or not cap then
			return refuse(player, "Your data is not loaded")
		end
		local opponent = resolveTarget(player, value.Kind, value.TargetId)
		if not opponent then
			return refuse(player, "That battle is not available")
		end
		nextBattleId = (nextBattleId + 1) % 4294967295
		local session, problem = BattleSession.start({
			battleId = nextBattleId,
			kind = value.Kind,
			yours = creatures,
			theirs = opponent.creatures,
			theirMoves = opponent.moves,
			tier = opponent.tier,
			seed = random:NextInteger(1, 2147483646),
			levelCap = cap,
		})
		if not session then
			return refuse(player, problem or "That battle cannot start")
		end
		sessions[player] = session
		local started = BattleSession.started(session)
		Net.BattleStarted.Fire(player, {
			BattleId = started.battleId,
			Kind = started.kind,
			Yours = toWire(started.yours),
			Theirs = toWire(started.theirs),
			Previews = started.previews,
		})
	end)

	local stopAction = Net.BattleAction.On(function(player, value)
		local now = os.clock()
		if now - (lastAction[player] or -math.huge) < MIN_SECONDS_BETWEEN_ACTIONS then
			return
		end
		lastAction[player] = now
		local session = sessions[player]
		if not session or session.battleId ~= value.BattleId then
			return refuse(player, "That battle is over")
		end
		if busy(player) then
			return refuse(player, "Finish your throw first")
		end
		local turn, problem = BattleSession.act(session, value.Turn, value.Kind, value.Index)
		if not turn then
			return refuse(player, problem or "That choice is not allowed")
		end
		BattleService.publishTurn(player, session, turn)
	end)

	local leaving = Players.PlayerRemoving:Connect(function(player)
		sessions[player] = nil
		lastAction[player] = nil
	end)

	return function()
		stopStart()
		stopAction()
		leaving:Disconnect()
	end
end

-- True while the creature is in this player's current battle; the breeding and trade services
-- use this as their lock.
function BattleService.isInBattle(player: Player, creatureId: string): boolean
	local session = sessions[player]
	if not session then
		return false
	end
	for _, fighter in session.state.sides[1].team do
		if fighter.creature.id == creatureId then
			return true
		end
	end
	return false
end

return BattleService
