--!strict
-- The battle as a scene in the world, the way the classic Roblox creature games stage it: the
-- two creatures stand on round patches of ground, and the camera sits behind the player's own
-- creature with the opponent further off. The player's character stays where it is, off to one
-- side, like a tamer watching.
-- The creatures are toy bodies (Creatures/ToyBody) until the part meshes exist.
-- Everything is made on the player's own device and removed when the battle closes.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local AudioConfig = require(ReplicatedStorage.config.AudioConfig)
local Cry = require(script.Parent.Parent.Audio.Cry)
local Gestures = require(ReplicatedStorage.shared.Gestures)
local Motion = require(ReplicatedStorage.shared.Motion)
local SpeciesQuirks = require(ReplicatedStorage.content.SpeciesQuirks)
local ToyBody = require(script.Parent.Parent.Creatures.ToyBody)
local Types = require(ReplicatedStorage.shared.Types)

local BattleStage = {}

export type Look = { species: string, element: Types.Element, size: number }
export type Stage = {
	open: (mine: Look, theirs: Look, foe: string?) -> (), -- `foe`: a tamer battle's id
	swap: (side: number, look: Look) -> (),
	close: () -> (),
	point: (side: number) -> Vector2, -- where that creature is on the screen
	lunge: (side: number) -> (),
	lungeRelease: number, -- seconds after `lunge` when the dart is half way: when a shot should leave
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
local SHAKE_SECONDS = 0.4 -- exp(-12 t) is under 1% by then
local LUNGE_BACK = 0.6 -- studs it draws back before the dart
local LUNGE_REACH = 3.5
local APPEAR_HOP = 1.5 -- studs a creature hops as it steps in
local OUT_OF_GRASS = -0.8 -- a wild creature starts this far under the ground
local MODEL_PATIENCE = 0.5 -- seconds a creature stays unseen while its model loads
local SWAP_ENTRANCE_MAX = 0.5 -- a creature sent in mid-battle takes at most this long to arrive

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
	local busy: { number } = { 0, 0 } -- goes up with each creature put on a pad, so an old one stops
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
	local shakePower, shakeStart, shakeEnd = 0, 0, 0
	local shakeSeed = 0 -- where in the noise this shake's roll is read; looks only
	local seeds = Random.new()
	-- The way a blow came, in the world: the camera is pushed along it, so a hit jolts the picture
	-- toward or away from the viewer rather than at random.
	local shakeWay = Vector3.zAxis
	local cameraLoop: RBXScriptConnection? = nil
	local guard: RBXScriptConnection? = nil -- keeps the camera the battle's while it is open
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
				-- A damped sine along the hit's direction, a little lift, and a smooth roll.
				local since = now - shakeStart
				local push = Motion.shakePush(shakePower, since)
				local way = frame:VectorToObjectSpace(shakeWay)
				local roll = math.noise(since * 22, shakeSeed)
					* shakePower
					* 2
					* math.exp(-12 * since)
				frame = frame
					* CFrame.new(way * push + Vector3.yAxis * push * 0.3)
					* CFrame.Angles(0, 0, math.rad(roll))
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
		-- The server tags the name signs; searching the whole world is only the fallback.
		local tagged = CollectionService:GetTagged("WorldSign")
		local source: { Instance } = if #tagged > 0 then tagged else Workspace:GetDescendants()
		for _, thing in source do
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
	-- The folders under workspace.World whose ground slab lies under any of `spots`.
	local function biomeFolders(spots: { Vector3 }): { Instance }
		local world = Workspace:FindFirstChild("World")
		if not world then
			return {}
		end
		local found: { Instance } = {}
		for _, child in world:GetChildren() do
			local slab = child:FindFirstChild("Ground")
			if slab and slab:IsA("BasePart") then
				for _, spot in spots do
					local inside = slab.CFrame:PointToObjectSpace(spot)
					if
						math.abs(inside.X) <= slab.Size.X / 2
						and math.abs(inside.Z) <= slab.Size.Z / 2
					then
						table.insert(found, child)
						break
					end
				end
			end
		end
		if #found == 0 then
			table.insert(found, world)
		end
		return found
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
		-- Everything standing in the way, not only grass: hedge bushes, fill and wall facings are
		-- built with CanQuery off too, and a battle beside a hedge had the camera inside the
		-- bushes (Studio, 23 November 2026). Ground, lanes, tiers and slabs (flat, wide or
		-- tagged WorldGround) always stay.
		-- Only the biome the battle is in (each biome's folder has a Ground slab to test against);
		-- the whole World if the slab cannot be found.
		local holders = biomeFolders(spots)
		local wild = Workspace:FindFirstChild("WildCreatures")
		if wild then
			table.insert(holders, wild)
		end
		for _, holder in holders do
			for _, piece in holder:GetDescendants() do
				if
					piece:IsA("BasePart")
					and piece.LocalTransparencyModifier == 0
					and piece.Size.Y >= 1.5
					and math.max(piece.Size.X, piece.Size.Z) < 60
					and piece.Name ~= "Ground"
					and not piece:HasTag("WorldGround")
					and near(piece.Position)
				then
					piece.LocalTransparencyModifier = 1
					table.insert(cleared, piece)
				end
			end
		end
	end
	-- The people standing in the world (a keeper, a tamer on the route, a story battle's rival)
	-- are each a plain block, hidden, that carries a ProximityPrompt and wears the painted model
	-- as children (src/server/World/Markers.luau `person`). The prompt's PromptId is the tamer's
	-- or battle's id, which is how the person being fought is found.
	local function personBody(thing: Instance): BasePart?
		if not thing:IsA("ProximityPrompt") then
			return nil
		end
		local kind = thing:GetAttribute("PromptKind")
		local parent = thing.Parent
		if
			(kind == "Talk" or kind == "Tamer" or kind == "Rival")
			and parent
			and parent:IsA("BasePart")
		then
			return parent
		end
		return nil
	end
	-- Every ProximityPrompt that may belong to a person. The server tags each person's body
	-- "Person" (src/server/World/Markers.luau); searching the whole world is the fallback.
	local function personPrompts(): { Instance }
		local list: { Instance } = {}
		for _, body in CollectionService:GetTagged("Person") do
			for _, child in body:GetChildren() do
				if child:IsA("ProximityPrompt") then
					table.insert(list, child)
				end
			end
		end
		if #list == 0 then
			return Workspace:GetDescendants()
		end
		return list
	end
	local function hidePerson(body: BasePart)
		for _, piece in { body :: Instance, table.unpack(body:GetDescendants()) } do
			if piece:IsA("BasePart") then
				if piece.LocalTransparencyModifier == 0 then
					piece.LocalTransparencyModifier = 1
					table.insert(cleared, piece)
				end
			elseif piece:IsA("Decal") then
				piece.LocalTransparencyModifier = 1
				table.insert(clearedFaces, piece)
			end
		end
	end

	-- A copy of the fought tamer's world model, standing at `spot` and turned to face `toward`.
	local function standTamer(parent: Instance, body: BasePart, spot: Vector3, toward: Vector3)
		local copy = body:Clone()
		for _, piece in copy:GetDescendants() do
			if piece:IsA("ProximityPrompt") or piece:IsA("BillboardGui") then
				piece:Destroy()
			end
		end
		local model = Instance.new("Model")
		model.Name = "Tamer"
		copy.Parent = model
		model.PrimaryPart = copy
		for _, piece in { copy :: Instance, table.unpack(copy:GetDescendants()) } do
			if piece:IsA("BasePart") then
				piece.Anchored = true
				piece.CanCollide = false
				piece.CanQuery = false
				piece.CanTouch = false
				piece.LocalTransparencyModifier = 0
			end
		end
		-- The painted model's own front is what turns to face the creature; the block under it
		-- is not turned, so the whole is rotated by the difference.
		local mesh = copy:FindFirstChildWhichIsA("MeshPart", true)
		local front = (if mesh then mesh else copy).CFrame.LookVector
		front = Vector3.new(front.X, 0, front.Z)
		local aim = Vector3.new(toward.X, 0, toward.Z)
		if front.Magnitude < 0.1 or aim.Magnitude < 0.1 then
			front, aim = Vector3.zAxis, Vector3.zAxis
		end
		local turn = CFrame.lookAt(Vector3.zero, aim) * CFrame.lookAt(Vector3.zero, front):Inverse()
		local pivot = copy.CFrame
		local boxCentre, boxSize = model:GetBoundingBox()
		local lift = pivot.Y - (boxCentre.Y - boxSize.Y / 2)
		model:PivotTo(CFrame.new(spot + Vector3.yAxis * lift) * turn * (pivot - pivot.Position))
		model.Parent = parent
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

	-- The ground itself under a spot. Treetops, roofs and hedges are looked through: a battle
	-- in the orchard stood the wild creature on an apple tree's crown (Studio, 23 November
	-- 2026). Ground is a terrace or stair (tagged), or anything very wide or thin and broad (the
	-- land, a lane, a plaza), as the world view decides where a creature hides.
	local function groundAt(position: Vector3, fallback: number, ignore: { Instance }): Vector3
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		local skipped = table.clone(ignore)
		for _ = 1, 10 do
			params.FilterDescendantsInstances = skipped
			local found =
				Workspace:Raycast(position + Vector3.yAxis * 30, Vector3.yAxis * -80, params)
			if not found then
				break
			end
			local hit = found.Instance
			local size = if hit:IsA("BasePart") then hit.Size else Vector3.new(1000, 1000, 1000)
			local thinnest = math.min(size.X, size.Y, size.Z)
			local widest = math.max(size.X, size.Y, size.Z)
			local middle = size.X + size.Y + size.Z - thinnest - widest
			if
				hit:IsA("Terrain")
				or hit:HasTag("WorldGround")
				or widest >= 100
				or (thinnest <= 1.5 and middle >= 8)
			then
				return Vector3.new(position.X, found.Position.Y, position.Z)
			end
			table.insert(skipped, hit)
		end
		return Vector3.new(position.X, fallback, position.Z)
	end

	-- Puts a creature on a pad. One already there shrinks away first (recalled); the new one
	-- springs up with a hop (a wild foe out of the grass), once its model has loaded.
	local function place(side: number, look: Look, opening: boolean)
		busy[side] += 1
		local mine = busy[side]
		local old = toys[side]
		sizes[side] = look.size
		local function enter()
			local parent = folder
			if busy[side] ~= mine or not parent then
				return
			end
			local toy = ToyBody.new(parent, look.species, look.element, look.size, MODEL_PATIENCE)
			toy.place(CFrame.lookAt(grounds[side], grounds[side] + facings[side]))
			-- The species' own entrance; a swap mid-battle plays it faster. A species with none steps
			-- in with the generic hop.
			local quirk = SpeciesQuirks[look.species]
			local shape = if quirk then Gestures.curve(quirk.entrance) else nil
			if shape then
				local seconds = if opening
					then shape.seconds
					else math.min(shape.seconds, SWAP_ENTRANCE_MAX)
				toy.act(Gestures.motionCurve(shape), seconds)
			else
				local track = Motion.appear(APPEAR_HOP, if side == 2 then OUT_OF_GRASS else 0)
				toy.act(Motion.curve(track), track.seconds)
			end
			local stagger = if opening and side == 2 then AudioConfig.CRY.foeDelay else 0
			Cry.play(look.species, AudioConfig.CRY.entranceDelay + stagger)
			toys[side] = toy
		end
		if old and folder and not old.gone() then
			local track = Motion.recall()
			old.act(Motion.curve(track), track.seconds)
			task.delay(track.seconds, function()
				old.destroy()
				enter()
			end)
		else
			if old then
				old.destroy()
			end
			toys[side] = nil
			enter()
		end
	end

	local function close()
		local had = folder
		folder = nil
		if guard then
			guard:Disconnect()
			guard = nil
		end
		stopCamera()
		shakeEnd = 0
		busy[1] += 1
		busy[2] += 1
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

	return {
		open = function(mine: Look, theirs: Look, foe: string?)
			close()
			-- Ask for both models now, so they are ready by the time the creatures step in.
			ToyBody.preload(mine.species)
			ToyBody.preload(theirs.species)
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
			shakeWay = facings[1]
			for side = 1, 2 do
				clearAround(grounds[side], ignore)
				clearAround(grounds[1]:Lerp(grounds[2], side / 3), ignore) -- and the ground between
				disc(made, 12, RIM_COLOUR, grounds[side] + Vector3.yAxis * 0.1)
				disc(made, 11, PATCH_COLOUR, grounds[side] + Vector3.yAxis * 0.16)
			end
			place(1, mine, true)
			place(2, theirs, true)
			showSigns(false)

			-- Behind and to the right of the player's creature, looking down a little, so it
			-- stands left of centre and clear of the buttons along the bottom of the screen.
			local sideways = facings[1]:Cross(Vector3.yAxis)
			local eye = grounds[1] - facings[1] * 19 + sideways * 8 + Vector3.yAxis * 11
			local target = grounds[1]:Lerp(grounds[2], 0.45) - Vector3.yAxis * 3
			clearAround(eye - Vector3.yAxis * 8, ignore)
			clearAround(eye:Lerp(grounds[1], 0.5) - Vector3.yAxis * 4, ignore)
			-- Round both creatures, and all along the camera's line of sight to them.
			local spots = { grounds[1], grounds[2], grounds[1]:Lerp(grounds[2], 0.5) }
			-- A tamer battle: the tamer stands a few studs behind their creature, a little to
			-- the camera's side so the creature does not hide them, and looks at the player's.
			-- The person in the world, and any other standing near the stage, step out of view.
			local everyone: { Instance } = if foe then personPrompts() else {}
			local fought: BasePart? = nil
			if foe then
				for _, thing in everyone do
					local body = personBody(thing)
					local kind = thing:GetAttribute("PromptKind")
					if
						body
						and (kind == "Tamer" or kind == "Rival")
						and thing:GetAttribute("PromptId") == foe
					then
						fought = body
						break
					end
				end
			end
			if fought then
				local behind = grounds[2] - facings[2] * 5 + sideways * 3
				local spot = groundAt(behind, grounds[2].Y, ignore)
				standTamer(made, fought, spot, facings[2])
				clearAround(spot, ignore)
				table.insert(spots, spot)
				hidePerson(fought)
				local nearby = grounds[1]:Lerp(grounds[2], 0.5)
				for _, thing in everyone do
					local body = personBody(thing)
					if body then
						local flat = body.Position - nearby
						if Vector3.new(flat.X, 0, flat.Z).Magnitude < 60 then
							hidePerson(body)
						end
					end
				end
			end
			for step = 0, 6 do
				table.insert(spots, eye:Lerp(target, step / 6))
			end
			clearGrass(spots, 10)
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
			-- Anything that hands the camera back to the player mid-battle (a respawn, another
			-- script) would leave the view behind the hidden character, with the player's own
			-- creature out of frame (seen in Studio, 23 November 2026): take it back at once.
			guard = camera:GetPropertyChangedSignal("CameraType"):Connect(function()
				if folder and camera.CameraType ~= Enum.CameraType.Scriptable then
					camera.CameraType = Enum.CameraType.Scriptable
					-- Straight to the shot it was heading for (home, or a close-up mid-catch).
					shotFrom, shotFovFrom = shotTo, shotFovTo
					shotSeconds, shotStart = 0.05, os.clock()
					driveCamera()
				end
			end)
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
		swap = function(side: number, look: Look)
			place(side, look, false)
		end,
		close = close,
		point = function(side: number): Vector2
			local camera = Workspace.CurrentCamera
			if not camera then
				return Vector2.new(400, 200)
			end
			local at = camera:WorldToViewportPoint(grounds[side] + Vector3.yAxis * 5)
			return Vector2.new(at.X, at.Y)
		end,
		-- The attacker draws back and squashes, darts at the other creature stretched, and settles.
		lunge = function(side: number)
			local toy = toys[side]
			if toy then
				local track = Motion.lunge(LUNGE_BACK, LUNGE_REACH)
				toy.act(Motion.curve(track), track.seconds)
			end
		end,
		lungeRelease = Motion.LUNGE_RELEASE,
		-- The creature that was hit freezes for an instant (everything does), flashes white, is
		-- squashed and knocked back, then springs to rights.
		hit = function(side: number, big: boolean)
			local toy = toys[side]
			if not toy then
				return
			end
			ToyBody.hitStop(if big then Motion.HIT_STOP_BIG else Motion.HIT_STOP)
			toy.flash()
			shakeWay = -facings[side]
			local track = Motion.hit(big)
			toy.act(Motion.curve(track), track.seconds)
		end,
		-- A fainted creature wobbles, topples onto its side, lies a moment, then sinks and fades.
		-- It is down (0.75 s) about when the next event starts; the sink carries on after.
		faint = function(side: number)
			local toy = toys[side]
			if toy then
				local lift = 0.5 + 0.5 * math.clamp(sizes[side], 0.6, 1.8)
				local track = Motion.faint(lift)
				toy.act(Motion.curve(track), track.seconds, true)
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
		-- The creature shrinks toward the ground (feet planted), and back.
		squeeze = function(side: number, scale: number, seconds: number)
			local toy = toys[side]
			if toy then
				toy.hold(math.max(0.05, scale), seconds)
			end
		end,
		-- Pulled toward the player along the rope, then back, with a wobble across.
		tug = function(side: number)
			local toy = toys[side]
			if toy then
				local track = Motion.tug()
				toy.act(Motion.curve(track), track.seconds)
			end
		end,
		-- A few hops away from the player, then it fades into the distance.
		bound = function(side: number)
			local toy = toys[side]
			if not toy then
				return
			end
			toy.hold(1, 0.05)
			local track = Motion.bound()
			toy.act(Motion.curve(track), track.seconds, true)
		end,
		shake = function(power: number)
			if not folder then
				return
			end
			shakePower, shakeStart = power, os.clock()
			shakeEnd = shakeStart + SHAKE_SECONDS
			shakeSeed = seeds:NextNumber(0, 100)
			driveCamera()
		end,
	}
end

return BattleStage
