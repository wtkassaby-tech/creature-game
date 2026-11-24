--!strict
-- Quests on the server: taking one from its giver, counting what the server saw, handing it in.
-- The rules are in src/shared/QuestProgress. The device only names a quest; the server checks
-- it is open to the player and that their character is standing at the giver's place.
-- Not yet run in Studio.

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.net.generated.Server)
local Profile = require(ReplicatedStorage.shared.Profile)
local QuestProgress = require(ReplicatedStorage.shared.QuestProgress)
local Quests = require(ReplicatedStorage.content.Quests)
local WorldConfig = require(ReplicatedStorage.config.WorldConfig)
local WorldTypes = require(ReplicatedStorage.shared.WorldTypes)

local MIN_SECONDS_BETWEEN_REQUESTS = 0.5

export type Hooks = {
	getData: (player: Player) -> Profile.Profile?,
	biomes: () -> { WorldTypes.Biome },
	isNear: (player: Player, placeId: string, radius: number) -> boolean,
	refuse: (player: Player, reason: string) -> (),
	changed: (player: Player) -> (),
	log: (event: string, fields: { [string]: any }) -> (),
}

local QuestService = {}

local hooks: Hooks
local lastRequest: { [Player]: { [string]: number } } = {}
local random = Random.new()

-- True if the player's character is at the place where this quest's giver stands.
local function atGiver(player: Player, questId: string): boolean
	local quest = Quests[questId]
	if not quest then
		return false
	end
	-- The giver's building may be in any biome's town.
	for _, biome in hooks.biomes() do
		for _, building in biome.hub.buildings do
			if
				building.name == quest.giver.place
				and hooks.isNear(player, building.id, WorldConfig.TALK_RADIUS)
			then
				return true
			end
		end
	end
	return false
end

local function update(
	player: Player,
	quest: WorldTypes.Quest,
	change: "Taken" | "Progress" | "Ready" | "Done",
	progress: number,
	gifts: { any }?
)
	hooks.changed(player)
	Net.QuestUpdate.Fire(player, {
		QuestId = quest.id,
		Change = change,
		Progress = math.clamp(progress, 0, 65535),
		Needed = QuestProgress.needed(quest),
		Gifts = gifts or {},
	})
end

-- Counts something the server saw toward the player's taken quests.
function QuestService.record(player: Player, event: QuestProgress.Event)
	local profile = hooks.getData(player)
	if not profile then
		return
	end
	-- Counting a quest must never stop whatever comes after it (rewards, the story).
	local ok, problem = pcall(function()
		for _, quest in QuestProgress.record(profile, event) do
			local ready = QuestProgress.isReady(profile, quest)
			update(
				player,
				quest,
				if ready then "Ready" else "Progress",
				profile.Quests.active[quest.id] or 0
			)
		end
	end)
	if not ok then
		hooks.log("QuestRecordFailed", { player = player.UserId, problem = tostring(problem) })
	end
end

-- Each kind of request has its own limit, so taking a quest never swallows a hand-in.
local function tooFast(player: Player, kind: string): boolean
	local now = os.clock()
	local mine = lastRequest[player]
	if not mine then
		mine = {}
		lastRequest[player] = mine
	end
	if now - (mine[kind] or -math.huge) < MIN_SECONDS_BETWEEN_REQUESTS then
		return true
	end
	mine[kind] = now
	return false
end

function QuestService.start(given: Hooks): () -> ()
	hooks = given

	local stopAccept = Net.AcceptQuest.On(function(player, value)
		local profile = hooks.getData(player)
		if tooFast(player, "accept") or not profile then
			return
		end
		local quest, problem =
			QuestProgress.accept(profile, value.QuestId, atGiver(player, value.QuestId))
		if not quest then
			return hooks.refuse(player, problem or "Not yet")
		end
		update(player, quest, "Taken", 0)
		hooks.log("QuestTaken", { player = player.UserId, quest = quest.id })
	end)

	local stopHandIn = Net.HandInQuest.On(function(player, value)
		local profile = hooks.getData(player)
		if tooFast(player, "handIn") or not profile then
			return
		end
		local handed, problem =
			QuestProgress.handIn(profile, value.QuestId, atGiver(player, value.QuestId), {
				choice = nil,
				newId = function()
					return HttpService:GenerateGUID(false)
				end,
				seed = random:NextInteger(1, 2147483646),
				unixTime = os.time(),
			})
		if not handed then
			return hooks.refuse(player, problem or "Not yet")
		end
		local gifts: { { Kind: string, Detail: string, Waiting: boolean } } = {}
		for _, gift in handed.gifts do
			table.insert(gifts, {
				Kind = gift.kind :: string,
				Detail = string.sub(gift.detail or "", 1, 40),
				Waiting = gift.waiting == true,
			})
		end
		update(player, handed.quest, "Done", QuestProgress.needed(handed.quest), gifts)
		hooks.log(
			"QuestDone",
			{ player = player.UserId, quest = handed.quest.id, gifts = #handed.gifts }
		)
	end)

	local leaving = Players.PlayerRemoving:Connect(function(player)
		lastRequest[player] = nil
	end)
	return function()
		stopAccept()
		stopHandIn()
		leaving:Disconnect()
	end
end

return QuestService
