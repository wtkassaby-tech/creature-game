--!strict
-- Giant fights on the server. The rules are in src/shared/GiantSession and GiantBattle; this
-- file checks who is asking and where they stand, runs one fight per player, and pays a win.
-- A fight is not saved: leaving ends it, and the Giant Horn it used stays used.
-- A win gives one capture attempt (src/shared/GiantCapture): the lasso is thrown at once, and a
-- hit is finished when the giant's serial number has been fetched (approval pack 2, section 5).
-- Not yet run in Studio.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EconomyConfig = require(ReplicatedStorage.config.EconomyConfig)
local GiantBattle = require(ReplicatedStorage.shared.GiantBattle)
local GiantCapture = require(ReplicatedStorage.shared.GiantCapture)
local GiantSession = require(ReplicatedStorage.shared.GiantSession)
local Giants = require(ReplicatedStorage.content.Giants)
local Lasso = require(ReplicatedStorage.shared.Lasso)
local Layout = require(ReplicatedStorage.shared.Layout)
local Net = require(ReplicatedStorage.net.generated.Server)
local Profile = require(ReplicatedStorage.shared.Profile)
local Rewards = require(ReplicatedStorage.shared.Rewards)
local Types = require(ReplicatedStorage.shared.Types)
local WorldTypes = require(ReplicatedStorage.shared.WorldTypes)
local Xp = require(ReplicatedStorage.shared.Xp)
local LiveConfigService = require(script.Parent.Parent.LiveConfig.LiveConfigService)

local MIN_SECONDS_BETWEEN_STARTS = 1
local MIN_SECONDS_BETWEEN_ACTIONS = 0.25
local FIRST_BATTLE_ID = 3000000000 -- kept apart from ordinary battle ids
local OFFER_SECONDS = 90 -- how long the one capture attempt waits to be thrown

export type Hooks = {
	getData: (player: Player) -> Profile.Profile?,
	team: (player: Player) -> ({ Types.Creature }?, number?), -- the team and the level cap
	inOtherBattle: (player: Player) -> boolean,
	mayEnter: (player: Player, biomeNumber: number) -> boolean, -- has the player earned this biome?
	isOpen: (profile: Profile.Profile) -> boolean, -- has the story shown this player the giant yet?
	biome: (player: Player) -> WorldTypes.Biome, -- the biome the player is standing in
	map: () -> Layout.Map,
	position: (player: Player) -> Layout.Point?,
	refuse: (player: Player, reason: string) -> (),
	changed: (player: Player) -> (),
	onWon: (player: Player, battleId: number, giantId: string, paid: Rewards.GiantPaid) -> (),
	onEnded: (player: Player) -> (), -- after any fight ends (won, lost or given up)
	-- For the capture attempt after a win:
	roundTrip: (player: Player) -> number, -- the server's own reading
	audit: (player: Player, errorsMs: { number }) -> (), -- the timing audit shared by all throws
	playThrow: (
		player: Player,
		pattern: Lasso.Pattern,
		battleId: number,
		onDone: (claims: { number }, arrivals: { number }, throwId: number) -> ()
	) -> boolean,
	finishSerials: (player: Player) -> (), -- finish anything waiting for a serial number
	notify: (player: Player, text: string) -> (),
	save: (player: Player) -> (),
	log: (event: string, fields: { [string]: any }) -> (),
}

local GiantService = {}

local sessions: { [Player]: GiantSession.Session } = {}
-- One capture attempt offered after a win, until it is used, declined or runs out.
type Offer = { giant: GiantBattle.GiantDef, battleId: number, expiresAt: number }
local offers: { [Player]: Offer } = {}
local throwing: { [Player]: boolean } = {} -- a capture throw is in the air
local hooks: Hooks
local lastStart: { [Player]: number } = {}
local lastAction: { [Player]: number } = {}
local nextBattleId = FIRST_BATTLE_ID
local random = Random.new()

local function offerFor(player: Player): Offer?
	local offer = offers[player]
	if offer and os.clock() > offer.expiresAt then
		offers[player] = nil
		return nil
	end
	return offer
end

-- True while the player is in a giant fight or in the capture attempt that follows a win.
-- Nothing else (a battle, long grass, a team change) may start in that time.
function GiantService.active(player: Player): boolean
	return sessions[player] ~= nil or offerFor(player) ~= nil or throwing[player] == true
end

-- True while the creature is in this player's giant fight; a lock for breeding and releasing.
function GiantService.isInBattle(player: Player, creatureId: string): boolean
	local session = sessions[player]
	if not session then
		return false
	end
	for _, fighter in session.state.team do
		if fighter.creature.id == creatureId then
			return true
		end
	end
	return false
end

local function wire(view: GiantSession.View): any
	local lines: { string } = {}
	for index, line in view.lines do
		if index > 24 then
			break
		end
		table.insert(lines, string.sub(line, 1, 160))
	end
	local previews: { number } = {}
	for index, damage in view.previews do
		if index <= 4 then
			table.insert(previews, math.clamp(damage, 0, 65535))
		end
	end
	return {
		BattleId = view.battleId,
		Turn = view.turn,
		Lines = lines,
		BossHp = math.max(0, view.bossHp),
		BossMaxHp = view.bossMaxHp,
		TeamHp = view.teamHp,
		Active = view.active,
		Intent = {
			Text = string.sub(view.intent.text, 1, 160),
			Kind = view.intent.kind,
			HitsTeam = view.intent.hitsTeam,
			Enraged = view.intent.enraged,
			WeakTypes = view.intent.weakTypes,
		},
		Phase = string.sub(view.phase, 1, 40),
		ItemsLeft = math.max(0, view.itemsLeft),
		Previews = previews,
		Finished = view.finished,
		Won = view.won,
	}
end

function GiantService.start(given: Hooks): () -> ()
	hooks = given

	local stopStart = Net.StartGiant.On(function(player, value)
		local now = os.clock()
		if now - (lastStart[player] or -math.huge) < MIN_SECONDS_BETWEEN_STARTS then
			return
		end
		lastStart[player] = now
		-- (A capture attempt still on offer or in the air counts as being in a fight.)
		if GiantService.active(player) or hooks.inOtherBattle(player) then
			return hooks.refuse(player, "You are already in a battle")
		end
		local profile = hooks.getData(player)
		local creatures, cap = hooks.team(player)
		if not profile or not creatures or not cap then
			return hooks.refuse(player, "Your data is not loaded")
		end
		-- The only giant that can be fought is the one whose lair the player is standing in.
		local lair = hooks.biome(player).lair
		local giant = Giants[lair.giant]
		local at = hooks.position(player)
		if not giant or value.GiantId ~= giant.id then
			return hooks.refuse(player, "There is no giant here")
		end
		if not at or not Layout.isNear(hooks.map(), lair.id, at, lair.arenaSize / 2) then
			return hooks.refuse(player, "You are too far away")
		end
		if not hooks.mayEnter(player, hooks.biome(player).number) then
			return hooks.refuse(player, "You have not earned your way here yet")
		end
		if not LiveConfigService.isOn("giants_open") then
			return hooks.refuse(player, LiveConfigService.closedText())
		end
		if not hooks.isOpen(profile) then
			return hooks.refuse(player, "The giant does not stir. Come back later in your journey")
		end
		nextBattleId += 1
		local session, problem = GiantSession.begin(profile, {
			battleId = nextBattleId,
			giant = giant,
			biome = hooks.biome(player).number,
			yours = creatures,
			levelCap = cap,
			seed = random:NextInteger(1, 2147483646),
		})
		if not session then
			return hooks.refuse(player, problem or "The giant does not stir")
		end
		sessions[player] = session
		hooks.changed(player) -- the horn is spent
		hooks.log(
			"GiantStarted",
			{ player = player.UserId, giant = giant.id, battle = session.battleId }
		)

		local yours = {}
		for _, fighter in session.state.team do
			local c = fighter.creature
			table.insert(yours, {
				Id = c.id,
				BodyPlan = c.bodyPlan,
				Head = c.parts.Head.species,
				Torso = c.parts.Torso.species,
				FrontLimbs = c.parts.FrontLimbs.species,
				Legs = c.parts.Legs.species,
				Tail = c.parts.Tail.species,
				Colour = c.colour.shown,
				Size = c.size,
				Rarity = c.rarity,
				Element = fighter.element,
				Level = fighter.level,
				MaxHp = fighter.stats.Hp,
				Hp = fighter.hp,
				Moves = fighter.moves,
			})
		end
		Net.GiantStarted.Fire(player, {
			Name = giant.name,
			Level = giant.level,
			Element = giant.element,
			Yours = yours,
			View = wire(GiantSession.view(session)),
		})
	end)

	local stopAction = Net.GiantAction.On(function(player, value)
		local now = os.clock()
		if now - (lastAction[player] or -math.huge) < MIN_SECONDS_BETWEEN_ACTIONS then
			return
		end
		lastAction[player] = now
		local session = sessions[player]
		local profile = hooks.getData(player)
		if not session or not profile or session.battleId ~= value.BattleId then
			return hooks.refuse(player, "That fight is over")
		end
		-- If the turn itself fails, the fight is ended rather than left half played.
		local ok, view, problem = pcall(
			GiantSession.act,
			profile,
			session,
			value.Turn,
			value.Kind,
			value.Index,
			value.Item
		)
		if not ok then
			sessions[player] = nil
			hooks.log("GiantFailed", { player = player.UserId, problem = tostring(view) })
			hooks.changed(player)
			hooks.onEnded(player)
			return hooks.refuse(player, "The fight was stopped. Your Giant Horn is spent")
		end
		if not view then
			return hooks.refuse(player, problem or "That choice is not allowed")
		end
		if value.Kind == "Item" then
			hooks.changed(player)
		end
		if not view.finished then
			return Net.GiantTurn.Fire(player, wire(view))
		end

		-- The fight is over: end it and pay before anything is sent, so nothing that goes wrong
		-- in sending can lose a win or leave the fight open.
		sessions[player] = nil
		local giant = session.state.giant
		hooks.log(
			"GiantFinished",
			{ player = player.UserId, giant = giant.id, won = view.won, turns = view.turn }
		)
		local paid: Rewards.GiantPaid? = nil
		if view.won then
			local team = {}
			for _, fighter in session.state.team do
				table.insert(team, { id = fighter.creature.id, fainted = fighter.hp <= 0 })
			end
			paid = Rewards.giantWin(profile, giant, session.state.boss.creature, {
				-- The giant's own biome, fixed when the fight began: never where the
				-- player happens to be standing when it ends.
				biome = session.biome,
				team = team,
				cap = Xp.levelCap(profile.Story.badges),
				unixTime = os.time(),
			})
			hooks.changed(player)
		end
		Net.GiantTurn.Fire(player, wire(view))
		if paid then
			hooks.onWon(player, session.battleId, giant.id, paid)
			-- A win gives one capture attempt, if this giant can still be captured.
			local form = giant.form
			if form and GiantCapture.canCapture(profile, giant) then
				offers[player] = {
					giant = giant,
					battleId = session.battleId,
					expiresAt = os.clock() + OFFER_SECONDS,
				}
				Net.GiantCaptureOffer.Fire(player, {
					BattleId = session.battleId,
					GiantId = giant.id,
					Name = giant.name,
					MinTier = EconomyConfig.LASSO_MIN_TIER[form.rarity],
					Seconds = OFFER_SECONDS,
				})
			end
		end
		hooks.onEnded(player)
	end)

	local stopLeave = Net.LeaveGiant.On(function(player, value)
		local now = os.clock()
		if now - (lastAction[player] or -math.huge) < MIN_SECONDS_BETWEEN_ACTIONS then
			return
		end
		lastAction[player] = now
		-- Leaving also declines a capture attempt that has not been thrown yet.
		local offer = offers[player]
		if offer and offer.battleId == value.BattleId then
			offers[player] = nil
		end
		local session = sessions[player]
		if session and session.battleId == value.BattleId then
			sessions[player] = nil
			hooks.log("GiantLeft", {
				player = player.UserId,
				giant = session.state.giant.id,
				turns = session.state.turn,
			})
			hooks.changed(player)
			hooks.onEnded(player)
		end
	end)

	local stopThrow = Net.ThrowGiantLasso.On(function(player, value)
		local now = os.clock()
		if now - (lastAction[player] or -math.huge) < MIN_SECONDS_BETWEEN_ACTIONS then
			return
		end
		lastAction[player] = now
		local offer = offerFor(player)
		local profile = hooks.getData(player)
		if not offer or not profile or offer.battleId ~= value.BattleId then
			return hooks.refuse(player, "There is no giant to capture")
		end
		local throw, problem = GiantCapture.begin(
			profile,
			offer.giant,
			value.Tier,
			random:NextInteger(1, 2147483646),
			hooks.roundTrip(player)
		)
		if not throw then
			-- The attempt is still theirs: they may pick another lasso.
			return hooks.refuse(player, problem or "You cannot throw that")
		end
		-- The lasso is spent and the one attempt is used, whatever happens next.
		offers[player] = nil
		throwing[player] = true
		hooks.changed(player)
		local giant = offer.giant
		local started = hooks.playThrow(
			player,
			throw.pattern,
			offer.battleId,
			function(claims, arrivals, throwId)
				throwing[player] = nil
				local current = hooks.getData(player)
				if not current then
					return -- the player left mid-throw: the lasso stays spent, nothing is captured
				end
				local hit, judgement = GiantCapture.finish(current, throw, claims, arrivals)
				if judgement then
					hooks.audit(player, judgement.errorsMs)
				end
				local zonesHit = 0
				local landedList: { boolean } = if judgement then judgement.zoneHits else {}
				for _, landed in landedList do
					if landed then
						zonesHit += 1
					end
				end
				hooks.log("GiantCaptureThrow", {
					player = player.UserId,
					giant = giant.id,
					hit = hit,
					verdict = if judgement then judgement.verdict else nil,
					-- How far each tap was from its loop's centre: kept so near-perfect timing
					-- on this one numbered prize can be audited (Lasso.looksScripted).
					errorsMs = if judgement then judgement.errorsMs else nil,
				})
				Net.LassoResult.Fire(player, {
					ThrowId = throwId,
					Outcome = if hit then "Caught" else "Missed",
					ZonesHit = zonesHit,
					Candy = 0,
					Element = nil,
				})
				if hit then
					hooks.changed(player)
					hooks.save(player) -- the waiting capture is worth saving at once
					hooks.finishSerials(player)
				end
			end
		)
		if not started then
			throwing[player] = nil
			hooks.log("GiantCaptureThrowLost", { player = player.UserId, giant = giant.id })
		end
	end)

	local leaving = Players.PlayerRemoving:Connect(function(player)
		offers[player] = nil
		throwing[player] = nil
		sessions[player] = nil
		lastStart[player] = nil
		lastAction[player] = nil
	end)

	return function()
		stopStart()
		stopAction()
		stopLeave()
		stopThrow()
		leaving:Disconnect()
	end
end

return GiantService
