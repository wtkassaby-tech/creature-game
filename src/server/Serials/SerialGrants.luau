--!strict
-- Finishes whatever is waiting for a serial number: a captured giant, a gem-tier wild catch.
-- Each waiting entry in a player's saved record gets one number, fetched once and written onto
-- the entry, and then joins the stable when there is room. Numbers can be skipped (a player who
-- leaves during the fetch) but are never given twice, and a full stable never wastes one
-- (approval pack 2, section 5).
--
-- `finish` is safe to call at any time and more than once: after a capture hits, when a player
-- joins, and whenever room may have appeared in the stable.
-- Not yet run in Studio.

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GiantCapture = require(ReplicatedStorage.shared.GiantCapture)
local Giants = require(ReplicatedStorage.content.Giants)
local Grants = require(ReplicatedStorage.shared.Grants)
local Profile = require(ReplicatedStorage.shared.Profile)

local SerialService = require(script.Parent.SerialService)

export type Hooks = {
	getData: (player: Player) -> Profile.Profile?,
	changed: (player: Player) -> (),
	notify: (player: Player, text: string) -> (),
	save: (player: Player) -> (),
	log: (event: string, fields: { [string]: any }) -> (),
}

local SerialGrants = {}

local hooks: Hooks = nil :: any -- set by start
local fetching: { [Player]: { [string]: boolean } } = {} -- numbers being fetched, by kind and ref
local toldNoRoom: { [Player]: boolean } = {}
local backoff: { [Player]: { [string]: { delay: number, untilTime: number } } } = {}
local FIRST_BACKOFF_SECONDS = 30
local MAX_BACKOFF_SECONDS = 600
local random = Random.new()

local TIER_NAMES: { [string]: string } = { Gem = "Amber", Ruby = "Ruby", Diamond = "Diamond" }

-- Fetches one entry's number and writes it onto the entry. Runs in its own thread.
local function fetch(player: Player, source: string, ref: string, kind: string)
	local key = `{source}:{ref}`
	local mine = fetching[player]
	if not mine then
		mine = {}
		fetching[player] = mine
	end
	if mine[key] or SerialService.isBroken(kind) then
		return
	end
	-- After a failed fetch, wait before trying again, longer each time: a struggling data
	-- store must not be hammered (player saves share its budget).
	local waits = backoff[player]
	if not waits then
		waits = {}
		backoff[player] = waits
	end
	local wait = waits[key]
	if wait and os.clock() < wait.untilTime then
		return
	end
	mine[key] = true
	task.spawn(function()
		local serial = SerialService.next(kind) -- waits
		local still = fetching[player]
		if still then
			still[key] = nil
		end
		-- The wait is over: look at the player's record afresh.
		local now = hooks.getData(player)
		if
			serial
			and now
			and player.Parent == Players
			and Grants.keepSerial(now, source, ref, serial)
		then
			waits[key] = nil
			hooks.save(player) -- the number is theirs from here on
			SerialGrants.finish(player)
		else
			if not serial then
				local delay = math.min(
					MAX_BACKOFF_SECONDS,
					if wait then wait.delay * 2 else FIRST_BACKOFF_SECONDS
				)
				waits[key] = { delay = delay, untilTime = os.clock() + delay }
			end
			-- The player left or the store failed: nothing was written. A fetched number is
			-- skipped for ever; the entry still waits and gets a number next time.
			hooks.log("SerialUnused", { player = player.UserId, kind = kind, serial = serial })
		end
	end)
end

function SerialGrants.finish(player: Player)
	if hooks == nil then
		return -- not started yet; the next call (a few seconds later at most) does the work
	end
	local profile = hooks.getData(player)
	if not profile then
		return
	end
	if GiantCapture.tidy(profile) > 0 then
		hooks.changed(player)
	end
	-- Work from a copy of the list: finishing an entry removes it from the profile's own.
	local waiting: { Profile.PendingGrant } = {}
	for _, pending in profile.Pending do
		if pending.source == "Giant" or pending.source == "Gem" then
			table.insert(waiting, pending)
		end
	end
	for _, pending in waiting do
		local giant = if pending.source == "Giant" then Giants[pending.ref] else nil
		if pending.serial == nil then
			-- A giant whose creature form no longer exists is never asked a number for.
			local wanted = if pending.source == "Giant"
				then giant ~= nil and GiantCapture.needsSerial(profile, giant)
				else pending.creature ~= nil
			if wanted then
				fetch(
					player,
					pending.source,
					pending.ref,
					Grants.serialKind(pending.source, pending.ref, pending.creature)
				)
			end
		else
			local outcome: string
			local name = ""
			local creatureId: string? = nil
			if giant then
				local grant, creature = GiantCapture.complete(
					profile,
					giant,
					HttpService:GenerateGUID(false),
					random:NextInteger(1, 2147483646)
				)
				outcome = grant.outcome
				name = giant.name
				creatureId = if creature then creature.id else nil
			elseif pending.source == "Gem" and pending.creature then
				local creature = pending.creature
				outcome = Grants.finishGem(profile, pending.ref).outcome
				name =
					`{TIER_NAMES[creature.rarity] or creature.rarity} {creature.parts.Torso.species}`
				creatureId = creature.id
			else
				outcome = "Refused"
			end
			if outcome == "Granted" then
				toldNoRoom[player] = nil
				hooks.changed(player)
				hooks.save(player)
				hooks.notify(player, `{name} No. {pending.serial} is yours!`)
				hooks.log("SerialGranted", {
					player = player.UserId,
					source = pending.source,
					ref = pending.ref,
					serial = pending.serial,
					creature = creatureId,
				})
				task.spawn(
					SerialService.register,
					Grants.serialKind(pending.source, pending.ref, pending.creature),
					pending.serial,
					player.UserId
				)
			elseif outcome == "NoRoom" and not toldNoRoom[player] then
				toldNoRoom[player] = true -- say it once, not every few seconds
				hooks.notify(player, `Make room in your stable: {name} is waiting to join you`)
			end
		end
	end
end

function SerialGrants.start(given: Hooks)
	hooks = given
	Players.PlayerRemoving:Connect(function(player)
		fetching[player] = nil
		toldNoRoom[player] = nil
		backoff[player] = nil
	end)
end

return SerialGrants
