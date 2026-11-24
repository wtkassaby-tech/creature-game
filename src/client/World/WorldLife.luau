--!strict
-- The people standing about the towns and routes are painted models that used to stand
-- perfectly still. This gives them a little life, on the player's own device and only for those
-- close by: they breathe (a slow change of height), turn to look at you when you are near, and
-- squash and hop when you come close enough to talk (their prompt appears).
-- One Heartbeat loop at about 30 Hz over a cached list of people within 80 studs; the list is
-- built from ProximityPrompts as they appear and refreshed every few seconds, never by walking
-- the whole world each frame. Looks only: the server never hears of any of this.

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local CreatureModels = require(ReplicatedStorage.content.CreatureModels)
local Motion = require(ReplicatedStorage.shared.Motion)
local PropModels = require(ReplicatedStorage.content.PropModels)

local WorldLife = {}

local ACTIVE_WITHIN = 80 -- studs: further off people stand still
local LOOK_WITHIN = 15 -- studs: nearer than this they turn to look at you
local STEP = 1 / 30
local REFRESH_SECONDS = 3
local BREATH_HZ = 0.35
local BREATH_AMOUNT = 0.02
local TURN_RATE = 6 -- how quickly they turn (eased)

type Person = {
	prompt: ProximityPrompt,
	body: BasePart,
	mesh: MeshPart,
	baseSize: Vector3,
	baseCFrame: CFrame,
	foot: CFrame, -- where its feet are, facing as it was put
	frontYaw: number, -- the angle its painted front faces
	yaw: number, -- how far it has turned from there
	phase: number,
	hopAt: number,
}

local prompts: { [ProximityPrompt]: boolean } = {}
local people: { [BasePart]: Person } = {}
local byPrompt: { [ProximityPrompt]: Person } = {}
local started = false

local function personOf(prompt: ProximityPrompt): Person?
	local kind = prompt:GetAttribute("PromptKind")
	local body = prompt.Parent
	if (kind ~= "Talk" and kind ~= "Tamer") or not body or not body:IsA("BasePart") then
		return nil
	end
	local known = people[body]
	if known then
		return known
	end
	-- Only the painted villagers move; a person built from plain blocks stands as it is.
	local mesh = body:FindFirstChildWhichIsA("MeshPart")
	if not mesh then
		return nil
	end
	local def = PropModels[mesh.Name] or CreatureModels[mesh.Name]
	local turn = if def and def.turn then def.turn else 0
	-- The model is turned by `turn` when it is stood up, so its front is that far back.
	local front = (mesh.CFrame * CFrame.Angles(0, -math.rad(turn), 0)).LookVector
	return {
		prompt = prompt,
		body = body,
		mesh = mesh,
		baseSize = mesh.Size,
		baseCFrame = mesh.CFrame,
		foot = mesh.CFrame * CFrame.new(0, -mesh.Size.Y / 2, 0),
		frontYaw = Motion.yawToward(front.X, front.Z),
		yaw = 0,
		phase = (body.Position.X * 0.37 + body.Position.Z * 0.61) % (2 * math.pi),
		hopAt = -10,
	}
end

-- Brings the cached list up to date from the prompts seen so far.
local function refresh()
	for prompt in prompts do
		if not prompt:IsDescendantOf(Workspace) then
			prompts[prompt] = nil
			local gone = byPrompt[prompt]
			if gone then
				people[gone.body] = nil
				byPrompt[prompt] = nil
			end
		elseif not byPrompt[prompt] then
			local person = personOf(prompt)
			if person then
				people[person.body] = person
				byPrompt[prompt] = person
			end
		end
	end
	for body, person in people do
		if not person.mesh:IsDescendantOf(Workspace) then
			people[body] = nil
			byPrompt[person.prompt] = nil
		end
	end
end

local function rest(person: Person)
	person.mesh.Size = person.baseSize
	person.mesh.CFrame = person.baseCFrame
	person.yaw = 0
end

local function animate(person: Person, now: number, dt: number, player: Vector3)
	-- Turning to look at the player when near, and back when they leave.
	local flat =
		Vector3.new(player.X - person.foot.Position.X, 0, player.Z - person.foot.Position.Z)
	local target = 0
	if flat.Magnitude < LOOK_WITHIN and flat.Magnitude > 0.5 then
		target = Motion.wrapAngle(Motion.yawToward(flat.X, flat.Z) - person.frontYaw)
	end
	person.yaw += Motion.approach(0, Motion.wrapAngle(target - person.yaw), TURN_RATE, dt)

	local breath = 1 + BREATH_AMOUNT * math.sin(2 * math.pi * BREATH_HZ * now + person.phase)
	local lift = 0
	local sinceHop = now - person.hopAt
	if sinceHop >= 0 and sinceHop < 0.5 then
		local hop = Motion.sample(Motion.hop(), sinceHop)
		breath *= hop.sy
		lift = hop.up
	end
	local wide = 1 / math.sqrt(breath) -- the volume stays the same
	local size = person.baseSize * Vector3.new(wide, breath, wide)
	person.mesh.Size = size
	person.mesh.CFrame = person.foot
		* CFrame.new(0, lift, 0)
		* CFrame.Angles(0, person.yaw, 0)
		* CFrame.new(0, size.Y / 2, 0)
end

function WorldLife.start()
	if started then
		return
	end
	started = true

	-- Prompts are collected as they appear; the first pass picks up those already there.
	for _, thing in Workspace:GetDescendants() do
		if thing:IsA("ProximityPrompt") then
			prompts[thing] = true
		end
	end
	Workspace.DescendantAdded:Connect(function(thing: Instance)
		if thing:IsA("ProximityPrompt") then
			prompts[thing] = true
		end
	end)

	-- A person squashes and hops when you come near enough that their prompt shows.
	ProximityPromptService.PromptShown:Connect(function(prompt: ProximityPrompt)
		local person = byPrompt[prompt]
		if person then
			person.hopAt = os.clock()
		end
	end)

	local sinceStep, sinceRefresh = 0, REFRESH_SECONDS
	local resting = false
	RunService.Heartbeat:Connect(function(step: number)
		sinceStep += step
		sinceRefresh += step
		if sinceStep < STEP then
			return
		end
		local dt = sinceStep
		sinceStep = 0
		if sinceRefresh >= REFRESH_SECONDS then
			sinceRefresh = 0
			refresh()
		end
		-- Prompts are off while a battle or a screen is open (and a battle copies the person it
		-- shows): everyone stands as built then.
		if not ProximityPromptService.Enabled then
			if not resting then
				resting = true
				for _, person in people do
					rest(person)
				end
			end
			return
		end
		resting = false
		local character = Players.LocalPlayer.Character
		local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
		if not (root and root:IsA("BasePart")) then
			return
		end
		local at = root.Position
		local now = os.clock()
		for body, person in people do
			if (body.Position - at).Magnitude <= ACTIVE_WITHIN then
				animate(person, now, dt, at)
			end
		end
	end)
end

return WorldLife
