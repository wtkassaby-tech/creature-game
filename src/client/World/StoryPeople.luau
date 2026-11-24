--!strict
-- The people the story sends the player to battle (the rival, a gate's champion) are built into
-- the world for everyone, so each device shows or hides them for its own player's place in the
-- story (src/shared/StoryStand): the rival is standing only while he is the next thing the story
-- wants, never at a place he has left; a champion holds their post. Looks only: hiding someone
-- here changes nothing the server decides, and the server gives its own reason if a battle is
-- asked for when it is not open (Trainers.resolve).

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ClientState = require(script.Parent.Parent.State.ClientState)
local Storyline = require(ReplicatedStorage.content.Storyline)
local StoryStand = require(ReplicatedStorage.shared.StoryStand)
local Tamers = require(ReplicatedStorage.content.Tamers)
local WorldTypes = require(ReplicatedStorage.shared.WorldTypes)

local StoryPeople = {}

local LOOK_SECONDS = 0.5 -- how often each person's place in the story is looked at again

type Standing = {
	body: BasePart,
	prompt: ProximityPrompt,
	battle: WorldTypes.StoryBattle,
	shown: boolean,
	collided: { [BasePart]: boolean }, -- the pieces that were solid before they were hidden
}

local standings: { [BasePart]: Standing } = {}
local started = false
local scannedAt = -math.huge
local SCAN_SECONDS = 3 -- a person whose prompt had not arrived when they were first seen is looked at again

local function standingOf(body: Instance): Standing?
	if not body:IsA("BasePart") then
		return nil
	end
	local prompt = body:FindFirstChildWhichIsA("ProximityPrompt")
	if not prompt or prompt:GetAttribute("PromptKind") ~= "Rival" then
		return nil
	end
	local id = prompt:GetAttribute("PromptId")
	local battle = if typeof(id) == "string" then Tamers.story[id] else nil
	if not battle then
		return nil
	end
	return { body = body, prompt = prompt, battle = battle, shown = true, collided = {} }
end

local function add(body: Instance)
	if not body:IsA("BasePart") or standings[body] then
		return
	end
	local made = standingOf(body)
	if made then
		standings[body] = made
	end
end

-- Hides or shows the whole person on this device only (LocalTransparencyModifier and a local
-- CanCollide change are never sent to the server), with their labels.
local function setShown(standing: Standing, shown: boolean)
	if standing.shown == shown then
		return
	end
	standing.shown = shown
	local pieces: { Instance } = standing.body:GetDescendants()
	table.insert(pieces, standing.body)
	for _, piece in pieces do
		if piece:IsA("BasePart") then
			piece.LocalTransparencyModifier = if shown then 0 else 1
			if shown then
				if standing.collided[piece] then
					piece.CanCollide = true
				end
			else
				if piece.CanCollide then
					standing.collided[piece] = true
				end
				piece.CanCollide = false
			end
		elseif piece:IsA("BillboardGui") then
			piece.Enabled = shown
		end
	end
	if shown then
		standing.collided = {}
	end
end

local function look()
	local now = os.clock()
	if now - scannedAt >= SCAN_SECONDS then
		scannedAt = now
		for _, body in CollectionService:GetTagged("Person") do
			add(body)
		end
	end
	local state = ClientState.get()
	if not state then
		return
	end
	local flags: { [string]: boolean } = {}
	for _, flag in state.Flags do
		flags[flag] = true
	end
	for body, standing in standings do
		if not body:IsDescendantOf(game) then
			standings[body] = nil
		else
			local battle = standing.battle
			local status = StoryStand.status(Storyline, flags, battle)
			local shown = StoryStand.visible(status, battle)
			setShown(standing, shown)
			-- The rival can be asked for only when he is the next step. A champion's prompt stays,
			-- so a tap before its time is answered by the server's reason, except once beaten.
			standing.prompt.Enabled = if StoryStand.isRival(battle)
				then status == "Now"
				else shown and status ~= "Past"
		end
	end
end

function StoryPeople.start()
	if started then
		return
	end
	started = true
	CollectionService:GetInstanceAddedSignal("Person"):Connect(add)
	local since = 0
	RunService.Heartbeat:Connect(function(step)
		since += step
		if since >= LOOK_SECONDS then
			since = 0
			look()
		end
	end)
end

return StoryPeople
