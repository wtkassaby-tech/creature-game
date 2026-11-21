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
local BattleConfig = require(ReplicatedStorage.config.BattleConfig)
local BattleSession = require(ReplicatedStorage.shared.BattleSession)
local Net = require(ReplicatedStorage.net.generated.Server)
local Types = require(ReplicatedStorage.shared.Types)

export type Opponent = {
	creatures: { Types.Creature },
	moves: { { string } }?,
	tier: BattleAi.Tier,
	ref: any?, -- whatever the resolver needs back when the battle ends (a spawn, a tamer)
	cannotLose: boolean?, -- a story battle the player's last creature holds on through
}
-- Returns the opponent, or nil and a reason for the screen.
export type ResolveTarget = (
	player: Player,
	kind: BattleSession.Kind,
	targetId: number,
	targetName: string?
) -> (Opponent?, string?)
-- The player's team and level cap, or nil if their data is not loaded.
export type PlayerTeam = (player: Player) -> ({ Types.Creature }?, number?)
export type OnFinished = (
	player: Player,
	session: BattleSession.Session,
	outcome: number,
	ref: any?
) -> ()
export type OnStarted = (player: Player, session: BattleSession.Session, ref: any?) -> ()

local MIN_SECONDS_BETWEEN_ACTIONS = 0.25
local MIN_SECONDS_BETWEEN_STARTS = 0.5

local BattleService = {}

local sessions: { [Player]: BattleSession.Session } = {}
local refs: { [Player]: any } = {}
local lastAction: { [Player]: number } = {}
local lastStart: { [Player]: number } = {}
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
-- Set by the bootstrap: true while the player is in some other kind of battle (a giant fight).
local elsewhere: (player: Player) -> boolean = function()
	return false
end
function BattleService.setElsewhereCheck(check: (player: Player) -> boolean)
	elsewhere = check
end
function BattleService.isBusy(player: Player): boolean
	return busy(player)
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
	for index, event in turn.events do
		if index > BattleConfig.MAX_EVENTS_A_TURN then
			break -- more than the message can carry; cannot happen under the rules as written
		end
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
		local ref = refs[player]
		sessions[player] = nil
		refs[player] = nil
		finished(player, session, turn.outcome, ref)
	end
end

-- The player's current battle, or nil.
function BattleService.session(player: Player): BattleSession.Session?
	return sessions[player]
end

local begin: (player: Player, kind: BattleSession.Kind, opponent: Opponent) -> boolean = function()
	return false
end

-- Starts a battle the server itself chose (a creature jumping out of long grass). Returns true
-- if it began; if not, the opponent has been handed back through `onDropped`.
function BattleService.begin(player: Player, kind: BattleSession.Kind, opponent: Opponent): boolean
	return begin(player, kind, opponent)
end

function BattleService.start(
	resolveTarget: ResolveTarget,
	playerTeam: PlayerTeam,
	onFinished: OnFinished,
	onStarted: OnStarted?,
	onDropped: ((player: Player, ref: any?) -> ())? -- the battle could not start after all
): () -> ()
	local random = Random.new()
	finished = onFinished

	-- Opens a battle against an opponent already chosen by the server. Returns true if it began.
	-- If anything fails, even by an error, the opponent is handed back: a wild creature must
	-- not stay marked as in a battle, and no half-started battle may be left behind.
	local function open(player: Player, kind: BattleSession.Kind, opponent: Opponent): boolean
		local function drop(reason: string): boolean
			if onDropped then
				onDropped(player, opponent.ref)
			end
			refuse(player, reason)
			return false
		end
		if sessions[player] or elsewhere(player) then
			return drop("You are already in a battle")
		end
		local creatures, cap = playerTeam(player)
		if not creatures or not cap then
			return drop("Your data is not loaded")
		end
		nextBattleId = (nextBattleId + 1) % 4294967295
		local ok, session, problem = pcall(function(): (BattleSession.Session?, string?)
			local made, why = BattleSession.start({
				battleId = nextBattleId,
				kind = kind,
				yours = creatures,
				theirs = opponent.creatures,
				theirMoves = opponent.moves,
				tier = opponent.tier,
				seed = random:NextInteger(1, 2147483646),
				levelCap = cap,
				cannotLose = opponent.cannotLose,
			})
			if made and onStarted then
				onStarted(player, made, opponent.ref)
			end
			return made, why
		end)
		if not ok or not session then
			if not ok then
				warn(`[BattleStart] {player.UserId}: {session}`)
			end
			return drop(if ok and problem then problem else "That battle cannot start")
		end
		sessions[player] = session
		refs[player] = opponent.ref
		local started = BattleSession.started(session)
		Net.BattleStarted.Fire(player, {
			BattleId = started.battleId,
			Kind = started.kind,
			Yours = toWire(started.yours),
			Theirs = toWire(started.theirs),
			Previews = started.previews,
		})
		return true
	end
	begin = open

	local stopStart = Net.StartBattle.On(function(player, value)
		local now = os.clock()
		if now - (lastStart[player] or -math.huge) < MIN_SECONDS_BETWEEN_STARTS then
			return
		end
		lastStart[player] = now
		if sessions[player] then
			return refuse(player, "You are already in a battle")
		end
		local opponent, why = resolveTarget(player, value.Kind, value.TargetId, value.TargetName)
		if not opponent then
			return refuse(player, why or "That battle is not available")
		end
		open(player, value.Kind, opponent)
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
		refs[player] = nil
		lastAction[player] = nil
		lastStart[player] = nil
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
