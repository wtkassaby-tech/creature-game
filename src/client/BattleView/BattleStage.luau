--!strict
-- The battle as a scene in the world, the way the classic Roblox creature games stage it: the
-- two creatures stand on round patches of ground, and the camera sits behind the player's own
-- creature with the opponent further off. The player's character stays where it is, off to one
-- side, like a tamer watching.
-- The creatures are toy bodies (Creatures/ToyBody) until the part meshes exist.
-- Everything is made on the player's own device and removed when the battle closes.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local ToyBody = require(script.Parent.Parent.Creatures.ToyBody)
local Types = require(game:GetService("ReplicatedStorage").shared.Types)

local BattleStage = {}

export type Look = { species: string, element: Types.Element, size: number }
export type Stage = {
	open: (mine: Look, theirs: Look) -> (),
	swap: (side: number, look: Look) -> (),
	close: () -> (),
	point: (side: number) -> Vector2, -- where that creature is on the screen
	lunge: (side: number) -> (),
	hit: (side: number, big: boolean) -> (),
	faint: (side: number) -> (),
	anchor: (side: number) -> Vector3, -- the middle of that creature's body, in the world
	ground: (side: number) -> Vector3, -- the point on its pad, under its feet
	facing: (side: number) -> Vector3, -- the way it faces (toward the other creature)
	effects: () -> Instance?, -- where effects go; nil once the battle has closed
	shake: (power: number) -> (), -- a short camera shake; power is in studs
}

local PATCH_COLOUR = Color3.fromRGB(92, 134, 74) -- trodden grass, a shade under the meadow
local RIM_COLOUR = Color3.fromRGB(226, 214, 170)
local FIELD_OF_VIEW = 55
local WIDE_FIELD_OF_VIEW = 68 -- the opening shot, wide on both creatures
local INTRO_SECONDS = 0.8
local SHAKE_SECONDS = 0.28

local function disc(parent: Instance, width: number, colour: Color3, at: Vector3)
	local made = Instance.new("Part")
	made.Shape = Enum.PartType.Cylinder
	made.Size = Vector3.new(0.3, width, width)
	made.CFrame = CFrame.new(at) * CFrame.Angles(0, 0, math.rad(90))
	made.Color = colour
	made.Material = Enum.Material.SmoothPlastic
	made.Anchored = true
	made.CanCollide = false
	made.CanQuery = false
	made.CanTouch = false
	made.CastShadow = false
	made.Parent = parent
end

function BattleStage.new(): Stage
	local folder: Folder? = nil
	local toys: { ToyBody.Toy? } = { nil, nil }
	local grounds: { Vector3 } = { Vector3.zero, Vector3.zero }
	local facings: { Vector3 } = { Vector3.zAxis, Vector3.zAxis }
	local busy: { number } = { 0, 0 } -- goes up with each move of a creature, so an old one stops
	local hidden: { BillboardGui } = {} -- name signs in the world, put away while the battle shows
	local sizes: { number } = { 1, 1 } -- how big each creature stands, for where its middle is

	-- The camera: it opens wide on both creatures and settles behind the player's own over
	-- INTRO_SECONDS, and can be shaken. One frame loop runs only while one of those is moving.
	local shotFrom, shotTo = CFrame.new(), CFrame.new()
	local shotStart = 0
	local shakePower, shakeEnd = 0, 0
	local shaking = Random.new() -- which way each frame of a shake jolts; looks only
	local cameraLoop: RBXScriptConnection? = nil
	local function stopCamera()
		if cameraLoop then
			cameraLoop:Disconnect()
			cameraLoop = nil
		end
	end
	local function driveCamera()
		if cameraLoop then
			return
		end
		cameraLoop = RunService.RenderStepped:Connect(function()
			local camera = Workspace.CurrentCamera
			if not camera or not folder then
				stopCamera()
				return
			end
			local now = os.clock()
			local progress = math.clamp((now - shotStart) / INTRO_SECONDS, 0, 1)
			local eased = progress * progress * (3 - 2 * progress)
			local frame = shotFrom:Lerp(shotTo, eased)
			camera.FieldOfView = WIDE_FIELD_OF_VIEW + (FIELD_OF_VIEW - WIDE_FIELD_OF_VIEW) * eased
			local left = shakeEnd - now
			if left > 0 then
				local power = shakePower * (left / SHAKE_SECONDS)
				frame = frame
					* CFrame.new(
						shaking:NextNumber(-1, 1) * power,
						shaking:NextNumber(-1, 1) * power,
						0
					)
					* CFrame.Angles(0, 0, math.rad(shaking:NextNumber(-1, 1) * power * 2))
			end
			camera.CFrame = frame
			if progress >= 1 and left <= 0 then
				stopCamera()
			end
		end)
	end

	-- The floating names over buildings, people and wild creatures would hang across the scene.
	local function showSigns(visible: boolean)
		if visible then
			for _, sign in hidden do
				sign.Enabled = true
			end
			hidden = {}
			return
		end
		for _, thing in Workspace:GetDescendants() do
			if thing:IsA("BillboardGui") and thing.Enabled then
				thing.Enabled = false
				table.insert(hidden, thing)
			end
		end
	end

	-- Whatever happens to stand where the creatures will (a person, a signpost, a bush) steps
	-- out of the picture for the length of the battle. Only on this player's own screen.
	local cleared: { BasePart } = {}
	local clearedFaces: { Decal } = {}
	local function clearAround(at: Vector3, ignore: { Instance })
		local params = OverlapParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = ignore
		for _, found in Workspace:GetPartBoundsInRadius(at + Vector3.yAxis * 4, 8, params) do
			local top = found
			while top.Parent and top.Parent:IsA("BasePart") do
				top = top.Parent :: BasePart
			end
			-- Ground, paths and whole buildings stay: they are the scenery.
			if top.Size.Y >= 1.5 and math.max(top.Size.X, top.Size.Z) < 100 then
				for _, piece in { top :: Instance, table.unpack(top:GetDescendants()) } do
					if piece:IsA("BasePart") and piece.LocalTransparencyModifier == 0 then
						piece.LocalTransparencyModifier = 1
						table.insert(cleared, piece)
					end
				end
			end
		end
	end
	local function bringBack()
		for _, piece in cleared do
			piece.LocalTransparencyModifier = 0
		end
		for _, face in clearedFaces do
			face.LocalTransparencyModifier = 0
		end
		cleared = {}
		clearedFaces = {}
	end

	-- How many things stand in the way at a spot (ground and paths do not count).
	local function inTheWay(at: Vector3, ignore: { Instance }): number
		local params = OverlapParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = ignore
		local count = 0
		for _, found in Workspace:GetPartBoundsInRadius(at + Vector3.yAxis * 4, 9, params) do
			if found.Size.Y >= 1.5 and math.max(found.Size.X, found.Size.Z) < 100 then
				count += 1
			end
		end
		return count
	end

	local function groundAt(position: Vector3, fallback: number, ignore: { Instance }): Vector3
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = ignore
		local found = Workspace:Raycast(position + Vector3.yAxis * 30, Vector3.yAxis * -80, params)
		return Vector3.new(position.X, if found then found.Position.Y else fallback, position.Z)
	end

	local function place(side: number, look: Look)
		local old = toys[side]
		if old then
			old.destroy()
		end
		local parent = folder
		if not parent then
			return
		end
		local toy = ToyBody.new(parent, look.species, look.element, look.size)
		toy.place(CFrame.lookAt(grounds[side], grounds[side] + facings[side]))
		toys[side] = toy
		sizes[side] = look.size
		busy[side] += 1
	end

	local function close()
		local had = folder
		folder = nil
		stopCamera()
		shakeEnd = 0
		toys = { nil, nil }
		if had then
			had:Destroy()
			showSigns(true)
			bringBack()
			local camera = Workspace.CurrentCamera
			if camera then
				camera.CameraType = Enum.CameraType.Custom
				camera.FieldOfView = 70
			end
		end
	end

	-- Moves a creature off its spot along a list of offsets, one every `pause` seconds.
	local function play(side: number, offsets: { Vector3 }, pause: number)
		local toy = toys[side]
		if not toy then
			return
		end
		busy[side] += 1
		local mine = busy[side]
		task.spawn(function()
			for _, offset in offsets do
				if busy[side] ~= mine then
					return
				end
				toy.nudge(offset)
				task.wait(pause)
			end
			if busy[side] == mine then
				toy.nudge(Vector3.zero)
			end
		end)
	end

	return {
		open = function(mine: Look, theirs: Look)
			close()
			local camera = Workspace.CurrentCamera
			local character = Players.LocalPlayer.Character
			local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
			if not camera or not (root and root:IsA("BasePart")) then
				return
			end
			local made = Instance.new("Folder")
			made.Name = "BattleStage"
			made.Parent = Workspace
			folder = made

			-- The scene is laid out along the way the camera was already looking.
			local look = camera.CFrame.LookVector
			local forward = Vector3.new(look.X, 0, look.Z)
			forward = if forward.Magnitude > 0.1 then forward.Unit else Vector3.zAxis
			local centre = root.Position
			local floor = centre.Y - 3
			local ignore: { Instance } = { made }
			if character then
				table.insert(ignore, character)
			end
			-- Turn the scene to whichever way has the clearest ground, so a battle is not
			-- fought through a well or a cottage wall.
			local best, fewest = forward, math.huge
			for _, angle in { 0, 35, -35, 70, -70, 110, -110, 150, -150, 180 } do
				local way = CFrame.Angles(0, math.rad(angle), 0):VectorToWorldSpace(forward)
				local side = way:Cross(Vector3.yAxis)
				local near = centre + way * 7 + side * 6
				local far = centre + way * 27 + side * 10
				local toFar = (far - near).Unit
				local eyeSpot = near - toFar * 19 + toFar:Cross(Vector3.yAxis) * 8
				local blocked = inTheWay(near, ignore)
					+ inTheWay(far, ignore)
					+ inTheWay(near:Lerp(far, 0.5), ignore)
					+ inTheWay(eyeSpot, ignore) * 2 -- something in the lens is worst of all
					+ inTheWay(eyeSpot:Lerp(near, 0.5), ignore)
				if blocked < fewest then
					best, fewest = way, blocked
				end
				if blocked == 0 then
					break
				end
			end
			forward = best
			local right = forward:Cross(Vector3.yAxis)
			grounds[1] = groundAt(centre + forward * 7 + right * 6, floor, ignore)
			grounds[2] = groundAt(centre + forward * 27 + right * 10, floor, ignore)
			facings[1] = (grounds[2] - grounds[1]).Unit
			facings[2] = -facings[1]
			for side = 1, 2 do
				clearAround(grounds[side], ignore)
				clearAround(grounds[1]:Lerp(grounds[2], side / 3), ignore) -- and the ground between
				disc(made, 12, RIM_COLOUR, grounds[side] + Vector3.yAxis * 0.1)
				disc(made, 11, PATCH_COLOUR, grounds[side] + Vector3.yAxis * 0.16)
			end
			place(1, mine)
			place(2, theirs)
			showSigns(false)

			-- Behind and to the right of the player's creature, looking down a little, so it
			-- stands left of centre and clear of the buttons along the bottom of the screen.
			local sideways = facings[1]:Cross(Vector3.yAxis)
			local eye = grounds[1] - facings[1] * 19 + sideways * 8 + Vector3.yAxis * 11
			local target = grounds[1]:Lerp(grounds[2], 0.45) - Vector3.yAxis * 3
			clearAround(eye - Vector3.yAxis * 8, ignore)
			clearAround(eye:Lerp(grounds[1], 0.5) - Vector3.yAxis * 4, ignore)
			if character then
				for _, piece in character:GetDescendants() do
					if piece:IsA("BasePart") then
						piece.LocalTransparencyModifier = 1
						table.insert(cleared, piece)
					elseif piece:IsA("Decal") then
						piece.LocalTransparencyModifier = 1
						table.insert(clearedFaces, piece)
					end
				end
			end
			camera.CameraType = Enum.CameraType.Scriptable
			-- The opening shot: high and wide, seeing both creatures, then in behind the player's.
			local middle = grounds[1]:Lerp(grounds[2], 0.5)
			local wideEye = middle + sideways * 30 + Vector3.yAxis * 20 - facings[1] * 4
			clearAround(wideEye - Vector3.yAxis * 10, ignore)
			shotFrom = CFrame.lookAt(wideEye, middle)
			shotTo = CFrame.lookAt(eye, target)
			shotStart = os.clock()
			shakeEnd = 0
			camera.FieldOfView = WIDE_FIELD_OF_VIEW
			camera.CFrame = shotFrom
			driveCamera()
		end,
		swap = place,
		close = close,
		point = function(side: number): Vector2
			local camera = Workspace.CurrentCamera
			if not camera then
				return Vector2.new(400, 200)
			end
			local at = camera:WorldToViewportPoint(grounds[side] + Vector3.yAxis * 5)
			return Vector2.new(at.X, at.Y)
		end,
		-- The attacker darts toward the other creature and back.
		lunge = function(side: number)
			local reach = facings[side] * 3.5
			play(side, { reach * 0.4, reach * 0.8, reach, reach * 0.6, reach * 0.2 }, 0.03)
		end,
		-- The creature that was hit flashes white and shakes.
		hit = function(side: number, big: boolean)
			local toy = toys[side]
			if not toy then
				return
			end
			toy.flash()
			local across = facings[side]:Cross(Vector3.yAxis) * (if big then 1.4 else 0.7)
			local back = -facings[side] * (if big then 1 else 0.5)
			play(
				side,
				{ back + across, back - across, across * 0.6, -across * 0.6, across * 0.3 },
				0.035
			)
		end,
		-- A fainted creature sinks and fades.
		faint = function(side: number)
			local toy = toys[side]
			if toy then
				busy[side] += 1
				toy.sink()
			end
		end,
		anchor = function(side: number): Vector3
			return grounds[side] + Vector3.yAxis * (1.6 + 1.6 * math.clamp(sizes[side], 0.6, 1.8))
		end,
		ground = function(side: number): Vector3
			return grounds[side]
		end,
		facing = function(side: number): Vector3
			return facings[side]
		end,
		effects = function(): Instance?
			return folder
		end,
		shake = function(power: number)
			if not folder then
				return
			end
			shakePower, shakeEnd = power, os.clock() + SHAKE_SECONDS
			driveCamera()
		end,
	}
end

return BattleStage
