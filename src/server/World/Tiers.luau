--!strict
-- Raised ground (docs/plans/12_MAP_STRUCTURE.md section 4c): each tier of a map sheet as a solid
-- block of earth with a grassy top, its walls faced in painted cliff or left as a grassy bank,
-- and a trodden notch where a ledge lets you hop down. The shapes and heights come from the pure
-- Ground module; what stops a character at the top of a wall is the lane's own hedge, built by
-- Corridors, so nothing here needs an unseen wall.
-- Every piece is anchored. The block, the top and the stair pieces are tagged "WorldGround": the
-- battle scene never hides them, however small a piece is (BattleStage). Wall facings are looks
-- only: not collidable, not queried, no shadow.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Ground = require(ReplicatedStorage.shared.Ground)
local WorldTypes = require(ReplicatedStorage.shared.WorldTypes)

local Fences = require(script.Parent.Fences)
local Props = require(script.Parent.Props)

local Tiers = {}

local EARTH = Props.rgb(150, 118, 82)
local ROCK = Props.rgb(176, 120, 84)
local GRASS = Props.rgb(142, 198, 108)
local TRODDEN = Props.rgb(214, 190, 138)
local TOP_THICK = 0.3
local OVERHANG = 0.6 -- the grassy top stands this far past the block's side
local FACE_DEPTH = 3 -- how deep the painted wall facing is
local ENDS = 0.4 -- studs the facing is pushed out from the lip

-- How many parts a build made.
export type Counts = { blocks: number, faces: number, notches: number }

local function solid(part: BasePart, name: string)
	part.Name = name
	part.CanCollide = true
	part.CanTouch = false
	part:AddTag("WorldGround")
end

local function look(
	looks: { [string]: WorldTypes.TierLook }?,
	tier: Ground.Tier
): (Color3, WorldTypes.TierFace)
	local given = if looks then looks[tier.id] else nil
	if given then
		return Props.colour(given.top), given.face
	end
	local plain: WorldTypes.TierFace = "Earth"
	return GRASS, plain
end

-- The block and the top of one tier: a box, a disc or a strip of two discs and a bar.
local function block(parent: Instance, tier: Ground.Tier, top: Color3, face: WorldTypes.TierFace)
	local s = tier.shape
	local height = tier.height
	local side = if face == "Cliff" then ROCK else EARTH
	local bodyTall = height - TOP_THICK
	if s.kind == "Box" then
		local w, d = s.bx - s.ax, s.bz - s.az
		local cx, cz = (s.ax + s.bx) / 2, (s.az + s.bz) / 2
		solid(
			Props.part(parent, Vector3.new(w, bodyTall, d), CFrame.new(cx, bodyTall / 2, cz), side),
			"TierBlock"
		)
		solid(
			Props.part(
				parent,
				Vector3.new(w + OVERHANG, TOP_THICK, d + OVERHANG),
				CFrame.new(cx, height - TOP_THICK / 2, cz),
				top
			),
			"TierTop"
		)
		return
	end
	local function round(x: number, z: number)
		local blockPiece =
			Props.disc(parent, Vector3.new(x, 0, z), s.r * 2, bodyTall, bodyTall, side)
		solid(blockPiece, "TierBlock")
		local topPiece =
			Props.disc(parent, Vector3.new(x, 0, z), s.r * 2 + OVERHANG, TOP_THICK, height, top)
		solid(topPiece, "TierTop")
	end
	round(s.ax, s.az)
	local length = math.sqrt((s.bx - s.ax) ^ 2 + (s.bz - s.az) ^ 2)
	if s.kind == "Strip" and length > 0.5 then
		round(s.bx, s.bz)
		local from, to = Vector3.new(s.ax, 0, s.az), Vector3.new(s.bx, 0, s.bz)
		local middle = (from + to) / 2
		solid(
			Props.part(
				parent,
				Vector3.new(s.r * 2, bodyTall, length),
				CFrame.lookAt(
					middle + Vector3.yAxis * bodyTall / 2,
					to + Vector3.yAxis * bodyTall / 2
				),
				side
			),
			"TierBlock"
		)
		solid(
			Props.part(
				parent,
				Vector3.new(s.r * 2 + OVERHANG, TOP_THICK, length),
				CFrame.lookAt(
					middle + Vector3.yAxis * (height - TOP_THICK / 2),
					to + Vector3.yAxis * (height - TOP_THICK / 2)
				),
				top
			),
			"TierTop"
		)
	end
end

-- Builds every tier of `ground` under `parent`. `looks` are the dressing sheet's (by tier id);
-- `visible` says whether a flat point is near enough to walkable ground to be worth painting a
-- wall facing for.
function Tiers.build(
	parent: Instance,
	ground: Ground.Ground,
	looks: { [string]: WorldTypes.TierLook }?,
	visible: (x: number, z: number) -> boolean
): Counts
	local folder = Instance.new("Folder")
	folder.Name = "Tiers"
	folder.Parent = parent
	local counts: Counts = { blocks = 0, faces = 0, notches = 0 }
	local faceOf: { [string]: WorldTypes.TierFace } = {}
	for _, tier in ground.tiers do
		local top: Color3, face: WorldTypes.TierFace = look(looks, tier)
		faceOf[tier.id] = face
		block(folder, tier, top, face)
		counts.blocks += 1
	end

	local cliff = Props.model("CliffWall")
	local earth = Props.model("EarthBank")
	local seaCliff = Props.model("SeaCliff")
	for _, run in Ground.edges(ground, 3) do
		local points: { Vector3 } = {}
		for _, point in run.points do
			table.insert(points, Vector3.new(point.x, run.low, point.z))
		end
		local normal = run.normals[math.ceil(#run.normals / 2)]
		local out = Vector3.new(normal.x, 0, normal.z)
		if run.kind == "Ledge" then
			-- A notch of trodden earth where the lane meets the lip: the hop-down spot.
			for _, piece in Fences.pieces(Props.resample(points, 1)) do
				local a = Vector3.new(piece[1].X, 0, piece[1].Z)
				local b = Vector3.new(piece[2].X, 0, piece[2].Z)
				local notch = Props.strip(folder, a, b, 7, 0.1, run.high + 0.06, TRODDEN)
				if notch then
					notch.Name = "LedgeNotch"
					notch.CanQuery = false
					notch.CastShadow = false
					counts.notches += 1
				end
			end
		end
		-- An Earth face is tiled with the painted earth bank, each tile about as long as one
		-- and a half times the face is tall, so the clay soil bands keep their shape.
		if faceOf[run.tier] == "Earth" and earth and out.Magnitude > 0.5 then
			local tall = run.high - run.low
			local tiles = Props.resample(points, math.max(6, tall * 1.5))
			for k = 1, #tiles - 1 do
				local a, b = tiles[k], tiles[k + 1]
				local middle = (a + b) / 2
				if visible(middle.X, middle.Z) then
					local made = Props.span(
						folder,
						earth,
						middle + out.Unit * ENDS,
						Vector3.new(-out.Z, 0, out.X),
						(b - a).Magnitude + 0.8,
						FACE_DEPTH,
						tall + 0.6
					)
					made.CanCollide = false
					made.CanQuery = false
					made.CanTouch = false
					made.CastShadow = false
					counts.faces += 1
				end
			end
		end
		local rock = if faceOf[run.tier] == "Cliff"
			then cliff
			elseif faceOf[run.tier] == "SeaCliff" then seaCliff
			else nil
		if rock and out.Magnitude > 0.5 then
			local tall = run.high - run.low
			for _, piece in Fences.pieces(Props.resample(points, 1)) do
				local middle = (piece[1] + piece[2]) / 2
				if visible(middle.X, middle.Z) then
					local length = (piece[2] - piece[1]).Magnitude + 1
					-- The model's front faces `along` turned a quarter: out of the high ground.
					local made = Props.span(
						folder,
						rock,
						middle + out.Unit * ENDS,
						Vector3.new(-out.Z, 0, out.X),
						length,
						FACE_DEPTH,
						tall
					)
					made.CanCollide = false
					made.CanQuery = false
					made.CanTouch = false
					made.CastShadow = false
					counts.faces += 1
				end
			end
		end
	end
	return counts
end

return Tiers
