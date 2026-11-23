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
	focus: (side: number, seconds: number) -> (), -- the camera eases in on that creature
	refocus: (seconds: number) -> (), -- and back behind the player's own
	squeeze: (side: number, scale: number, seconds: number) -> (), -- shrinks it, as when held
	tug: (side: number) -> (), -- yanked toward the player and back, as on a taut rope
	bound: (side: number) -> (), -- hops away and fades: it got free and fled
}

local FOCUS_FIELD_OF_VIEW = 42

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
	local shotSeconds = INTRO_SECONDS
	local shotFovFrom, shotFovTo = WIDE_FIELD_OF_VIEW, FIELD_OF_VIEW
	local homeShot = CFrame.new() -- the settled shot behind the player's creature
	local ignoreList: { Instance } = {}
	local squeezes: { number } = { 0, 0 } -- goes up with each squeeze, so an old one stops
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
			local progress = math.clamp((now - shotStart) / shotSeconds, 0, 1)
			local eased = progress * progress * (3 - 2 * progress)
			local frame = shotFrom:Lerp(shotTo, eased)
			camera.FieldOfView = shotFovFrom + (shotFovTo - shotFovFrom) * eased
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
			-- Raised ground, its steps and its walls (tagged WorldGround) stay too, even when a piece
			-- is under 100 wide (docs/plans/12_MAP_STRUCTURE.md section 4c).
			if
				top.Size.Y >= 1.5
				and math.max(top.Size.X, top.Size.Z) < 100
				and not top:HasTag("WorldGround")
			then
				for _, piece in { top :: Instance, table.unpack(top:GetDescendants()) } do
					if piece:IsA("BasePart") and piece.LocalTransparencyModifier == 0 then
						piece.LocalTransparencyModifier = 1
						table.insert(cleared, piece)
					end
				end
			end
		end
	end
	-- Tall grass is built with CanQuery off, so the search above never finds it, and a battle
	-- in a patch had both creatures standing waist-deep in blades (seen in Studio). Grass
	-- within `radius` of a spot is hidden by walking the tuft folders (and the swaying clumps
	-- of hidden wild creatures) directly.
	local function clearGrass(spots: { Vector3 }, radius: number)
		local function near(position: Vector3): boolean
			for _, spot in spots do
				local flat = Vector3.new(position.X - spot.X, 0, position.Z - spot.Z)
				if flat.Magnitude < radius then
					return true
				end
			end
			return false
		end
		local holders: { Instance } = {}
		local world = Workspace:FindFirstChild("World")
		if world then
			for _, tufts in world:GetDescendants() do
				if tufts:IsA("Folder") and string.sub(tufts.Name, -6) == "_tufts" then
					table.insert(holders, tufts)
				end
			end
		end
		local wild = Workspace:FindFirstChild("WildCreatures")
		if wild then
			table.insert(holders, wild)
		end
		for _, holder in holders do
			for _, piece in holder:GetDescendants() do
				if
					piece:IsA("BasePart")
					and piece.LocalTransparencyModifier == 0
					and near(piece.Position)
				then
					piece.LocalTransparencyModifier = 1
					table.insert(cleared, piece)
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
			if
				found.Size.Y >= 1.5
				and math.max(found.Size.X, found.Size.Z) < 100
				and not found:HasTag("WorldGround")
			then
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
			-- The grass round both creatures and along the camera's view of them.
			clearGrass({
				grounds[1],
				grounds[2],
				grounds[1]:Lerp(grounds[2], 0.5),
				eye:Lerp(grounds[1], 0.5),
			}, 10)
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
			homeShot = shotTo
			shotSeconds = INTRO_SECONDS
			shotFovFrom, shotFovTo = WIDE_FIELD_OF_VIEW, FIELD_OF_VIEW
			ignoreList = ignore
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
		-- A glide from wherever the camera is now to a new shot.
		focus = function(side: number, seconds: number)
			local camera = Workspace.CurrentCamera
			if not camera or not folder then
				return
			end
			local across = facings[1]:Cross(Vector3.yAxis)
			local eye = grounds[side] - facings[1] * 15 + across * 6 + Vector3.yAxis * 6
			clearAround(eye - Vector3.yAxis * 6, ignoreList)
			local target = grounds[side] + Vector3.yAxis * (1.4 + sizes[side])
			shotFrom, shotFovFrom = camera.CFrame, camera.FieldOfView
			shotTo, shotFovTo = CFrame.lookAt(eye, target), FOCUS_FIELD_OF_VIEW
			shotSeconds, shotStart = math.max(0.05, seconds), os.clock()
			driveCamera()
		end,
		refocus = function(seconds: number)
			local camera = Workspace.CurrentCamera
			if not camera or not folder then
				return
			end
			shotFrom, shotFovFrom = camera.CFrame, camera.FieldOfView
			shotTo, shotFovTo = homeShot, FIELD_OF_VIEW
			shotSeconds, shotStart = math.max(0.05, seconds), os.clock()
			driveCamera()
		end,
		-- The creature shrinks toward the ground (a model scales about its feet).
		squeeze = function(side: number, scale: number, seconds: number)
			local toy = toys[side]
			if not toy then
				return
			end
			squeezes[side] += 1
			local mine = squeezes[side]
			local model = toy.model
			local from = model:GetScale()
			task.spawn(function()
				local began = os.clock()
				local alpha = 0
				while alpha < 1 and squeezes[side] == mine and model.Parent do
					alpha = math.min(1, (os.clock() - began) / math.max(0.03, seconds))
					local eased = alpha * alpha * (3 - 2 * alpha)
					model:ScaleTo(math.max(0.05, from + (scale - from) * eased))
					if alpha < 1 then
						task.wait()
					end
				end
			end)
		end,
		-- Pulled toward the player along the rope, then back, with a wobble across.
		tug = function(side: number)
			local toward = facings[side] * 1
			local across = facings[side]:Cross(Vector3.yAxis) * 0.5
			play(
				side,
				{ toward * 0.5, toward * 0.9, toward * 0.4, across, -across, across * 0.5 },
				0.045
			)
		end,
		-- A hop or two away from the player, then it fades into the ground.
		bound = function(side: number)
			local toy = toys[side]
			if not toy then
				return
			end
			squeezes[side] += 1
			toy.model:ScaleTo(1)
			busy[side] += 1
			local mine = busy[side]
			local away = -facings[side]
			task.spawn(function()
				for step = 1, 12 do
					if busy[side] ~= mine or not toy.model.Parent then
						return
					end
					local hop = math.abs(math.sin(step / 12 * math.pi * 2)) * 2.2
					toy.nudge(away * step * 0.7 + Vector3.yAxis * hop)
					task.wait(0.035)
				end
				if busy[side] == mine then
					toy.sink()
				end
			end)
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
