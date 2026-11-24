--!strict
-- A story camera beat: while a beat's lines show, the camera eases from the ordinary view to
-- look from the player toward a landmark (a place id named by the beat's `lookAt`), holds, then
-- eases back. It only blends the camera each frame, after the default camera has set it; it
-- never moves the character, and the blend follows the player if they walk on. Tapping while the
-- camera is still turning (StoryView calls `release`) lets go at once. Data driven: any beat
-- with a `lookAt` uses it.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Biomes = require(ReplicatedStorage.content.Biomes)
local CameraConfig = require(ReplicatedStorage.config.CameraConfig)
local Layout = require(ReplicatedStorage.shared.Layout)
local LookEase = require(ReplicatedStorage.shared.LookEase)
local Tamers = require(ReplicatedStorage.content.Tamers)
local WorldTypes = require(ReplicatedStorage.shared.WorldTypes)

local LookAt = {}

local STEP_NAME = "StoryLookAt"

local places: { [string]: Layout.Point }? = nil
local holding = false
local alpha = 0
local target: Vector3? = nil
local bound = false
-- The ordinary shot when the look began. The camera is Scriptable for the look and blends from
-- this saved shot: blending on top of the default camera compounded every frame (its next frame
-- starts from the blended one), so the turn ran fast and never came back (review, 23 Nov 2026).
local home: CFrame? = nil
local homeType: Enum.CameraType? = nil

local function placeOf(id: string): Layout.Point?
	if not places then
		local list: { WorldTypes.Biome } = {}
		for _, biome in Biomes do
			table.insert(list, biome)
		end
		places = Layout.world(list, Tamers.locals).map.places
	end
	return if places then places[id] else nil
end

local function unbind()
	if bound then
		bound = false
		RunService:UnbindFromRenderStep(STEP_NAME)
	end
	local camera = workspace.CurrentCamera
	if camera and homeType then
		if home then
			camera.CFrame = home
		end
		camera.CameraType = homeType
	end
	home, homeType = nil, nil
end

local function step(dt: number)
	alpha = LookEase.advance(alpha, dt, holding, CameraConfig.LOOK_EASE_SECONDS)
	local camera = workspace.CurrentCamera
	local character = Players.LocalPlayer.Character
	local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
	if not holding and alpha <= 0 then
		unbind()
		return
	end
	if not camera or not target or not (root and root:IsA("BasePart")) then
		return
	end
	local flat = Vector3.new(target.X - root.Position.X, 0, target.Z - root.Position.Z)
	if flat.Magnitude < 1 then
		return
	end
	-- Above the player's head and a little behind, so the camera is clear of the ground and of
	-- low hedges, and the player stays in the picture.
	local at = root.Position
		+ Vector3.yAxis * CameraConfig.LOOK_RAISE
		- flat.Unit * CameraConfig.LOOK_BACK
	local aim = Vector3.new(target.X, CameraConfig.LOOK_AIM_HEIGHT, target.Z)
	local from = home or camera.CFrame
	camera.CFrame = from:Lerp(CFrame.lookAt(at, aim), LookEase.smooth(alpha))
end

-- Starts turning toward the place. A place that is not on the map does nothing.
function LookAt.start(placeId: string)
	local point = placeOf(placeId)
	if not point then
		return
	end
	target = Vector3.new(point.x, 0, point.z)
	holding = true
	local camera = workspace.CurrentCamera
	if camera and not home then
		home, homeType = camera.CFrame, camera.CameraType
		camera.CameraType = Enum.CameraType.Scriptable
	end
	if not bound then
		bound = true
		-- One step after the default camera, so this blend sees its result and overrides it.
		RunService:BindToRenderStep(STEP_NAME, Enum.RenderPriority.Camera.Value + 1, step)
	end
end

-- Stops at once and leaves the camera alone, for when something else (the battle camera) takes it
-- over: easing back would fight that camera and then put the old shot back on top of it.
function LookAt.cancel()
	holding = false
	alpha = 0
	if bound then
		bound = false
		RunService:UnbindFromRenderStep(STEP_NAME)
	end
	home, homeType = nil, nil
end

-- Eases back to the ordinary camera.
function LookAt.release()
	holding = false
end

-- True while the camera is still turning toward the landmark (a tap then skips the look).
function LookAt.turning(): boolean
	return holding and alpha < 1
end

return LookAt
