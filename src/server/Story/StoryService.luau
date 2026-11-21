--!strict
-- The story on the server. A beat finishes when the server itself has seen its trigger happen:
-- the character reached a place, a battle the server ran was won, a catch the server judged, or
-- the player asked while standing beside the right character. Gifts are paid by
-- src/shared/StoryProgress, once and whole.
--
-- A beat that simply follows another one starts by itself a moment later.
-- Not yet run in Studio.

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Chapter1 = require(ReplicatedStorage.content.story.Chapter1)
local Layout = require(ReplicatedStorage.shared.Layout)
local Net = require(ReplicatedStorage.net.generated.Server)
local Profile = require(ReplicatedStorage.shared.Profile)
local StoryProgress = require(ReplicatedStorage.shared.StoryProgress)
local StoryTriggers = require(ReplicatedStorage.shared.StoryTriggers)
local World = require(ReplicatedStorage.shared.World)
local WorldTypes = require(ReplicatedStorage.shared.WorldTypes)

local FOLLOW_SECONDS = 2
local MIN_SECONDS_BETWEEN_REQUESTS = 0.5

export type Hooks = {
	getData: (player: Player) -> Profile.Profile?,
	map: () -> Layout.Map,
	position: (player: Player) -> Layout.Point?,
	refuse: (player: Player, reason: string) -> (),
	changed: (player: Player) -> (),
	log: (event: string, fields: { [string]: any }) -> (),
}

local StoryService = {}

local hooks: Hooks
local lastRequest: { [Player]: number } = {}
local random = Random.new()

function StoryService.chapter(): WorldTypes.Chapter
	return Chapter1
end

-- Something happened that might be what the story is waiting for. `choice` is the starter the
-- device picked, used only by the first beat. Returns true if a beat finished.
function StoryService.event(
	player: Player,
	event: StoryTriggers.Event,
	choice: unknown,
	quiet: boolean?
): boolean
	local profile = hooks.getData(player)
	if not profile then
		return false
	end
	local beat = StoryTriggers.ready(Chapter1, profile, hooks.map(), event)
	if not beat then
		if not quiet then
			hooks.refuse(player, "Not yet")
		end
		return false
	end
	local done, problem = StoryProgress.complete(profile, Chapter1, {
		beatId = beat.id,
		choice = choice,
		triggerMet = true, -- StoryTriggers.ready just confirmed it
		newId = function()
			return HttpService:GenerateGUID(false)
		end,
		seed = random:NextInteger(1, 2147483646),
		unixTime = os.time(),
	})
	if not done then
		if not quiet then
			hooks.refuse(player, problem or "Not yet")
		end
		return false
	end
	local gifts: { { Kind: string, Detail: string, Waiting: boolean } } = {}
	for _, gift in done.gifts do
		table.insert(gifts, {
			Kind = gift.kind :: string,
			Detail = string.sub(gift.detail or "", 1, 40),
			Waiting = gift.waiting == true,
		})
	end
	hooks.changed(player)
	Net.BeatCompleted.Fire(player, { BeatId = done.beat.id, Gifts = gifts, Unlocks = done.unlocks })
	hooks.log("StoryBeat", { player = player.UserId, beat = done.beat.id, gifts = #done.gifts })

	-- If the next beat just follows this one, it starts by itself after a moment.
	local nextBeat = World.nextBeat(Chapter1, profile.Story.flags)
	if nextBeat and nextBeat.trigger.kind == "Follow" then
		task.delay(FOLLOW_SECONDS, function()
			if player.Parent == Players then
				StoryService.event(player, { kind = "Ask", at = hooks.position(player) }, nil, true)
			end
		end)
	end
	return true
end

function StoryService.start(given: Hooks): () -> ()
	hooks = given
	local stopAsk = Net.CompleteBeat.On(function(player, value)
		local now = os.clock()
		if now - (lastRequest[player] or -math.huge) < MIN_SECONDS_BETWEEN_REQUESTS then
			return
		end
		lastRequest[player] = now
		local profile = hooks.getData(player)
		local beat = if profile then World.nextBeat(Chapter1, profile.Story.flags) else nil
		-- The device names the beat only so a stale request cannot finish a later one.
		if not beat or beat.id ~= value.BeatId then
			return hooks.refuse(player, "Not yet")
		end
		StoryService.event(player, { kind = "Ask", at = hooks.position(player) }, value.Choice)
	end)
	local leaving = Players.PlayerRemoving:Connect(function(player)
		lastRequest[player] = nil
	end)
	return function()
		stopAsk()
		leaving:Disconnect()
	end
end

return StoryService
