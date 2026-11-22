--!strict
-- The battle as a scene in the world, the way the classic Roblox creature games stage it: the
-- two creatures stand on round pads, and the camera sits low behind the player's own creature
-- with the opponent further off. The player's character stays where it is, off to one side,
-- like a tamer watching.
-- TODO(art): the creatures here are stand-ins (a round body, a head, eyes and feet, in the
-- colour of their type) until the part meshes exist; then Assembler.build takes their place.
-- Everything is made on the player's own device and removed when the battle closes.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Kit = require(script.Parent.Parent.UI.Kit)
local Types = require(game:GetService("ReplicatedStorage").shared.Types)

local BattleStage = {}

export type Look = { element: Types.Element, size: number }
export type Stage = {
	open: (mine: Look, theirs: Look) -> (),
	swap: (side: number, look: Look) -> (),
	close: () -> (),
	point: (side: number) -> Vector2, -- where that creature is on the screen
	lunge: (side: number) -> (),
	hit: (side: number, big: boolean) -> (),
	faint: (side: number) -> (),
}

local PAD_COLOUR = Color3.fromRGB(70, 72, 80)
local FIELD_OF_VIEW = 55

local function part(parent: Instance, shape: Enum.PartType, size: Vector3, colour: Color3): Part
	local made = Instance.new("Part")
	made.Shape = shape
	made.Size = size
	made.Color = colour
	made.Material = Enum.Material.SmoothPlastic
	made.Anchored = true
	made.CanCollide = false
	made.CanQuery = false
	made.CanTouch = false
	made.CastShadow = false
	made.Parent = parent
	return made
end

-- A stand-in creature facing along `facing`, standing on `ground`.
local function standIn(parent: Instance, look: Look, ground: Vector3, facing: Vector3): Model
	local model = Instance.new("Model")
	model.Name = "StandIn"
	local scale = math.clamp(look.size, 0.6, 1.8)
	local colour = Kit.ELEMENT_COLOURS[look.element]
	local dark = colour:Lerp(Color3.new(0, 0, 0), 0.3)
	local body = part(model, Enum.PartType.Ball, Vector3.one * 4 * scale, colour)
	local base = CFrame.lookAt(ground, ground + facing)
	body.CFrame = base * CFrame.new(0, 2.6 * scale, 0)
	model.PrimaryPart = body
	local head = part(model, Enum.PartType.Ball, Vector3.one * 2.8 * scale, colour)
	head.CFrame = base * CFrame.new(0, 4.6 * scale, -1.6 * scale)
	for _, x in { -1, 1 } do
		local eye = part(model, Enum.PartType.Ball, Vector3.one * 0.8 * scale, Color3.new(1, 1, 1))
		eye.CFrame = base * CFrame.new(x * 0.7 * scale, 5 * scale, -2.7 * scale)
		local pupil =
			part(model, Enum.PartType.Ball, Vector3.one * 0.4 * scale, Color3.new(0, 0, 0))
		pupil.CFrame = base * CFrame.new(x * 0.7 * scale, 5 * scale, -3 * scale)
		for _, z in { -1, 1 } do
			local foot = part(model, Enum.PartType.Ball, Vector3.one * 1.4 * scale, dark)
			foot.CFrame = base * CFrame.new(x * 1.1 * scale, 0.7 * scale, z * 1.1 * scale)
		end
	end
	model.Parent = parent
	return model
end

function BattleStage.new(): Stage
	local folder: Folder? = nil
	local models: { Model? } = { nil, nil }
	local homes: { CFrame } = { CFrame.new(), CFrame.new() }
	local grounds: { Vector3 } = { Vector3.zero, Vector3.zero }
	local facings: { Vector3 } = { Vector3.zAxis, Vector3.zAxis }
	local busy: { number } = { 0, 0 } -- goes up with each move of a creature, so an old one stops
	local hidden: { BillboardGui } = {} -- name signs in the world, put away while the battle shows

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

	local function groundAt(position: Vector3, fallback: number, ignore: { Instance }): Vector3
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = ignore
		local found = Workspace:Raycast(position + Vector3.yAxis * 30, Vector3.yAxis * -80, params)
		return Vector3.new(position.X, if found then found.Position.Y else fallback, position.Z)
	end

	local function place(side: number, look: Look)
		local old = models[side]
		if old then
			old:Destroy()
		end
		local parent = folder
		if not parent then
			return
		end
		local model = standIn(parent, look, grounds[side], facings[side])
		models[side] = model
		homes[side] = model:GetPivot()
		busy[side] += 1
	end

	local function close()
		local had = folder
		folder = nil
		models = { nil, nil }
		if had then
			had:Destroy()
			showSigns(true)
			local camera = Workspace.CurrentCamera
			if camera then
				camera.CameraType = Enum.CameraType.Custom
				camera.FieldOfView = 70
			end
		end
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
			local right = forward:Cross(Vector3.yAxis)
			local centre = root.Position
			local floor = centre.Y - 3
			local ignore: { Instance } = { made }
			if character then
				table.insert(ignore, character)
			end
			grounds[1] = groundAt(centre + forward * 7 + right * 6, floor, ignore)
			grounds[2] = groundAt(centre + forward * 27 + right * 10, floor, ignore)
			facings[1] = (grounds[2] - grounds[1]).Unit
			facings[2] = -facings[1]
			for side = 1, 2 do
				local pad = part(made, Enum.PartType.Cylinder, Vector3.new(0.4, 11, 11), PAD_COLOUR)
				pad.CFrame = CFrame.new(grounds[side] + Vector3.yAxis * 0.2)
					* CFrame.Angles(0, 0, math.rad(90))
			end
			place(1, mine)
			place(2, theirs)
			showSigns(false)

			-- Behind and to the right of the player's creature, looking down a little, so it
			-- stands left of centre and clear of the buttons along the bottom of the screen.
			local sideways = facings[1]:Cross(Vector3.yAxis)
			local eye = grounds[1] - facings[1] * 19 + sideways * 8 + Vector3.yAxis * 11
			local target = grounds[1]:Lerp(grounds[2], 0.45) - Vector3.yAxis * 3
			camera.CameraType = Enum.CameraType.Scriptable
			camera.FieldOfView = FIELD_OF_VIEW
			camera.CFrame = CFrame.lookAt(eye, target)
		end,
		swap = place,
		close = close,
		point = function(side: number): Vector2
			local camera = Workspace.CurrentCamera
			local model = models[side]
			if not camera or not model then
				local view = if camera then camera.ViewportSize else Vector2.new(800, 400)
				return view / 2
			end
			local at = camera:WorldToViewportPoint(model:GetPivot().Position + Vector3.yAxis * 2)
			return Vector2.new(at.X, at.Y)
		end,
		-- The attacker darts toward the other creature and back.
		lunge = function(side: number)
			local model = models[side]
			if not model then
				return
			end
			busy[side] += 1
			local mine = busy[side]
			local home = homes[side]
			task.spawn(function()
				for step = 1, 6 do
					if busy[side] ~= mine then
						return
					end
					local reach = if step <= 3 then step / 3 else (6 - step) / 3
					model:PivotTo(home + facings[side] * 3.5 * reach)
					task.wait(0.025)
				end
				if busy[side] == mine then
					model:PivotTo(home)
				end
			end)
		end,
		-- The creature that was hit flashes white and shakes.
		hit = function(side: number, big: boolean)
			local model = models[side]
			if not model then
				return
			end
			busy[side] += 1
			local mine = busy[side]
			local home = homes[side]
			local colours: { [BasePart]: Color3 } = {}
			for _, piece in model:GetChildren() do
				if piece:IsA("BasePart") then
					colours[piece] = piece.Color
					piece.Color = Color3.new(1, 1, 1)
					piece.Material = Enum.Material.Neon
				end
			end
			task.spawn(function()
				local reach = if big then 1.4 else 0.7
				for step = 1, 6 do
					if busy[side] ~= mine then
						break
					end
					local way = if step % 2 == 0 then 1 else -1
					model:PivotTo(home + facings[side]:Cross(Vector3.yAxis) * way * reach)
					task.wait(0.03)
					if step == 3 then
						for piece, colour in colours do
							piece.Color = colour
							piece.Material = Enum.Material.SmoothPlastic
						end
					end
				end
				for piece, colour in colours do
					piece.Color = colour
					piece.Material = Enum.Material.SmoothPlastic
				end
				if busy[side] == mine then
					model:PivotTo(home)
				end
			end)
		end,
		-- A fainted creature sinks and fades.
		faint = function(side: number)
			local model = models[side]
			if not model then
				return
			end
			busy[side] += 1
			local sink = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			for _, piece in model:GetChildren() do
				if piece:IsA("BasePart") then
					local goal = { Transparency = 1, Position = piece.Position - Vector3.yAxis * 3 }
					TweenService:Create(piece, sink, goal):Play()
				end
			end
		end,
	}
end

return BattleStage
