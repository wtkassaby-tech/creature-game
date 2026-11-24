--!strict
-- The ways a corridor edge or a freestanding wall can be built (docs/plans/09_DUST_CANYON_MAP.md
-- section 4c): Greenwood's hedge, canyon cliffs, boulder banks, sea rocks, dunes, rope rails on
-- posts and sea walls, plus the two fences only these biomes use (a broken rope bridge and a
-- rockfall). Every style blocks the way with a plain core, in pieces at most 40 studs long (the
-- battle scene hides things under 100 wide near its creatures), and stops short of streams and
-- pools with a low rail, as hedges do. Painted pieces are looks only; each has a plain stand-in.
-- Cliffs and dunes use few, large pieces: one cliff section per 36 studs, one dune lump per 10.

local WorldTypes = require(game:GetService("ReplicatedStorage").shared.WorldTypes)

local Fences = require(script.Parent.Fences)
local Props = require(script.Parent.Props)
local Shapes = require(script.Parent.Shapes)

local Edges = {}

-- How a run faces. `outward` (1 or -1) says which side of the run, walking from its first point,
-- is outside: a corridor edge's outside, where its inner face lies on the line. Left out, the run
-- is centred on its line and its face turns `towards` a point (the town's centre for a wall).
export type Options = { outward: number?, towards: Vector3?, tall: number? }

local CLIFF_TALL = 30
local CLIFF_CORE = 8 -- studs thick
local CLIFF_MODEL_DEPTH = 12 -- the painted CliffWall is 40 long, 30 tall and 12 deep
local CLIFF_BANDS: { Color3 } =
	{ Props.rgb(196, 98, 70), Props.rgb(222, 150, 100), Props.rgb(236, 200, 150) }
local SEA_CLIFF_BANDS: { Color3 } =
	{ Props.rgb(92, 96, 104), Props.rgb(120, 126, 132), Props.rgb(110, 150, 96) }
local ROCK = Props.rgb(176, 120, 84)
local SEA_ROCK = Props.rgb(84, 84, 92)
local SAND = Props.rgb(232, 214, 168)
local DRIFTWOOD = Props.rgb(120, 96, 72)
local ROPE = Props.rgb(200, 180, 140)
local CORK = Props.rgb(226, 96, 64)
local SEA_WALL = Props.rgb(170, 165, 150)
local COPING = Props.rgb(196, 190, 176)
local PLANK = Props.rgb(150, 110, 80)

-- The outside of a straight piece from `a` to `b`: a flat unit vector square to it.
local function outside(a: Vector3, b: Vector3, options: Options): Vector3
	local run = Vector3.new(b.X - a.X, 0, b.Z - a.Z)
	local unit = if run.Magnitude > 1e-3 then run.Unit else Vector3.xAxis
	local normal = Vector3.new(-unit.Z, 0, unit.X)
	if options.outward and options.outward ~= 0 then
		return normal * math.sign(options.outward)
	end
	local towards = options.towards
	if towards and (towards - (a + b) / 2):Dot(normal) > 0 then
		return -normal -- the face turns to the point, so its back is away from it
	end
	return normal
end

-- How far a piece is pushed out from its line: half its depth when its inner face is on the line.
local function shift(options: Options, depth: number): number
	return if options.outward and options.outward ~= 0 then depth / 2 else 0
end

local function cliff(
	parent: Instance,
	a: Vector3,
	b: Vector3,
	options: Options,
	model: MeshPart?,
	bands: { Color3 }
)
	local tall = options.tall or CLIFF_TALL
	local out = outside(a, b, options)
	local push = out * shift(options, CLIFF_CORE)
	local core = Fences.block(parent, a + push, b + push, CLIFF_CORE, tall)
	if core == nil then
		return
	end
	core.Name = "Cliff"
	core.Color = bands[2]
	local length = (Vector3.new(b.X, 0, b.Z) - Vector3.new(a.X, 0, a.Z)).Magnitude + CLIFF_CORE / 2
	local middle = Vector3.new((a.X + b.X) / 2, 0, (a.Z + b.Z) / 2)
	if model then
		core.Transparency = 1
		local depth = CLIFF_MODEL_DEPTH * tall / CLIFF_TALL
		local run = Vector3.new(b.X - a.X, 0, b.Z - a.Z)
		-- Props.span turns the model's front to the left of `along`; the front must face inside.
		local along = if Vector3.new(-run.Z, 0, run.X):Dot(out) > 0 then run else -run
		Props.span(parent, model, middle + out * shift(options, depth), along, length, depth, tall)
		return
	end
	-- Three stacked bands, the bottom and top standing proud of the core, and lumps on the top.
	local frame = core.CFrame
	local third = tall / 3
	Props.part(
		parent,
		Vector3.new(CLIFF_CORE + 1.2, third, length),
		frame * CFrame.new(0, -third, 0),
		bands[1]
	)
	Props.part(
		parent,
		Vector3.new(CLIFF_CORE + 0.6, third, length),
		frame * CFrame.new(0, third, 0),
		bands[3]
	)
	for _, t in { -0.25, 0.25 } do
		Props.lump(
			parent,
			Vector3.new(CLIFF_CORE + 1, 5, length * 0.45),
			(frame * CFrame.new(0, tall / 2, t * length)).Position,
			bands[3]
		)
	end
end

-- A bank of rounded rocks every 9 studs (Boulders or SeaRocks) on a low core with no gaps.
local function rocks(
	parent: Instance,
	run: { Vector3 },
	options: Options,
	pick: Random,
	name: string,
	core: { tall: number, colour: Color3, size: number }
)
	local tall = options.tall or core.tall
	for _, piece in Fences.pieces(run) do
		local made = Fences.block(parent, piece[1], piece[2], 3, tall)
		if made then
			made.Name = name
			made.Color = core.colour
		end
	end
	local grow = tall / core.tall
	for _, at in Props.resample(run, 9) do
		local scale = pick:NextNumber(0.8, 1.3)
		local turn = pick:NextNumber(0, math.pi * 2)
		local facing = Vector3.new(math.cos(turn), 0, math.sin(turn))
		Shapes.prop(parent, name, Vector3.new(at.X, 0, at.Z), core.size * scale * grow, facing)
	end
end

-- Low dunes: long sand lumps every 10 studs with marram along the crest every 4.
local function dunes(parent: Instance, run: { Vector3 }, options: Options)
	local grow = (options.tall or 8) / 8
	for _, piece in Fences.pieces(run) do
		local made = Fences.block(parent, piece[1], piece[2], 4, 6 * grow)
		if made then
			made.Name = "Dune"
			made.Color = SAND
		end
	end
	local samples = Props.resample(run, 10)
	for index, at in samples do
		local after = samples[index + 1] or samples[index - 1]
		local run3 = if after then Vector3.new(after.X - at.X, 0, after.Z - at.Z) else Vector3.xAxis
		local frame = CFrame.lookAt(
			Vector3.new(at.X, 2 * grow, at.Z),
			Vector3.new(at.X, 2 * grow, at.Z) + run3
		)
		local lump = Props.part(parent, Vector3.new(12, 8, 14) * grow, frame, SAND)
		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.Sphere
		mesh.Parent = lump
	end
	local tuft = Props.model("MarramTuft")
	for _, at in Props.resample(run, 4) do
		local foot = Vector3.new(at.X, 5.4 * grow, at.Z)
		local facing = Vector3.new(math.cos(at.X), 0, math.sin(at.Z))
		if tuft then
			local made = Props.stand(parent, tuft, foot, 3, facing)
			made.CanQuery = false
		else
			Shapes.fallback(parent, "MarramTuft", foot, 2.4, facing)
		end
	end
end

-- A rope rail: driftwood posts every 8 studs, two sagging ropes, a cork float on every second
-- post, and an unseen wall behind them so nobody slips between the ropes.
local function rope(parent: Instance, run: { Vector3 })
	for _, piece in Fences.pieces(run) do
		local made = Fences.block(parent, piece[1], piece[2], 1, 3.6)
		if made then
			made.Name = "RopeRail"
			made.Transparency = 1
		end
	end
	local posts = Props.resample(run, 8)
	for index, at in posts do
		Props.part(parent, Vector3.new(0.9, 4.5, 0.9), CFrame.new(at.X, 2.25, at.Z), DRIFTWOOD)
		if index % 2 == 0 then
			Props.lump(parent, Vector3.one * 0.8, Vector3.new(at.X, 4.6, at.Z), CORK)
		end
		local after = posts[index + 1]
		if after then
			for _, height in { 1.6, 3.2 } do
				local a, b = Vector3.new(at.X, height, at.Z), Vector3.new(after.X, height, after.Z)
				local low = (a + b) / 2 - Vector3.yAxis * 0.4
				for _, half in { { a, low }, { low, b } } do
					local length = (half[2] - half[1]).Magnitude
					if length > 0.05 then
						Props.part(
							parent,
							Vector3.new(0.3, 0.3, length),
							CFrame.lookAt((half[1] + half[2]) / 2, half[2]),
							ROPE
						)
					end
				end
			end
		end
	end
end

-- A sea wall 4 thick and 6 tall with a wider coping, and sea rocks along its outer foot.
local function seaWall(parent: Instance, run: { Vector3 }, options: Options, pick: Random)
	local tall = options.tall or 6
	for _, piece in Fences.pieces(run) do
		local made = Fences.block(parent, piece[1], piece[2], 4, tall)
		if made then
			made.Name = "SeaWall"
			made.Color = SEA_WALL
			local length = made.Size.Z
			Props.part(
				parent,
				Vector3.new(5, 0.8, length),
				made.CFrame * CFrame.new(0, tall / 2 + 0.4, 0),
				COPING
			)
		end
	end
	local samples = Props.resample(run, 12)
	for index, at in samples do
		local before, after = samples[index - 1], samples[index + 1]
		local out = if after
			then outside(at, after, options)
			elseif before then outside(before, at, options)
			else nil
		if out then
			local scale = pick:NextNumber(0.8, 1.2)
			Shapes.prop(parent, "SeaRocks", Vector3.new(at.X, 0, at.Z) + out * 5, 6 * scale, out)
		end
	end
end

-- Builds a run of edge in `style` along `points` (on the ground), stopping short of water.
function Edges.run(
	parent: Instance,
	points: { Vector3 },
	style: WorldTypes.EdgeStyle,
	waters: { Fences.Water },
	pick: Random,
	options: Options?
)
	if style == "Hedge" then
		Fences.hedge(parent, points, waters)
		return
	end
	local opts: Options = options or {}
	local runs, gaps = Fences.clearOfWater(points, waters)
	local cliffModel = if style == "Cliff"
		then Props.model("CliffWall")
		elseif style == "SeaCliff" then Props.model("SeaCliff")
		else nil
	local bands = if style == "SeaCliff" then SEA_CLIFF_BANDS else CLIFF_BANDS
	for _, run in runs do
		if style == "Cliff" or style == "SeaCliff" then
			for _, piece in Fences.pieces(run) do
				cliff(parent, piece[1], piece[2], opts, cliffModel, bands)
			end
		elseif style == "Boulders" then
			rocks(parent, run, opts, pick, "Boulders", { tall = 6, colour = ROCK, size = 7 })
		elseif style == "Rocks" then
			rocks(parent, run, opts, pick, "SeaRocks", { tall = 5, colour = SEA_ROCK, size = 6 })
		elseif style == "Dunes" then
			dunes(parent, run, opts)
		elseif style == "Rope" then
			rope(parent, run)
		elseif style == "SeaWall" then
			seaWall(parent, run, opts, pick)
		end
		-- Low banks look low but must not be hopped: an unseen wall stands over them.
		if style == "Boulders" or style == "Rocks" or style == "Dunes" or style == "SeaWall" then
			Fences.cap(parent, run)
		end
	end
	for _, gap in gaps do
		if (gap[2] - gap[1]).Magnitude < 80 then
			Fences.rail(parent, gap[1], gap[2])
		end
	end
end

-- A broken rope bridge: six planks hanging from two ropes beyond the line's middle, tilted 25
-- degrees down into the drop, `away` from the route.
local function brokenBridge(parent: Instance, points: { Vector3 }, away: Vector3)
	local middle = (points[1] + points[#points]) / 2
	local top = Vector3.new(middle.X, 4.2, middle.Z)
	local tilt = math.rad(25)
	local down = away.Unit * math.cos(tilt) - Vector3.yAxis * math.sin(tilt)
	local across = Vector3.new(-away.Unit.Z, 0, away.Unit.X)
	for k = 1, 6 do
		local centre = top + down * (2 * k - 1)
		Props.part(parent, Vector3.new(4, 0.4, 1.4), CFrame.lookAt(centre, centre + down), PLANK).Name =
			"BridgePlank"
	end
	for _, side in { -1, 1 } do
		local from = top + across * side * 2.1
		local to = from + down * 12
		Props.part(parent, Vector3.new(0.3, 0.3, 12), CFrame.lookAt((from + to) / 2, to), ROPE)
	end
end

-- A heap of boulders three abreast along the line on a core 5 tall: a rockfall across a track.
local function rockfall(parent: Instance, points: { Vector3 }, waters: { Fences.Water })
	local runs = Fences.clearOfWater(points, waters)
	for _, run in runs do
		for _, piece in Fences.pieces(run) do
			local made = Fences.block(parent, piece[1], piece[2], 6, 5)
			if made then
				made.Name = "Rockfall"
				made.Color = ROCK
			end
		end
		local span = run[#run] - run[1]
		local along = if span.Magnitude > 1e-3 then span.Unit else Vector3.xAxis
		local across = Vector3.new(-along.Z, 0, along.X)
		for index, at in Props.resample(run, 9) do
			for k = -1, 1 do
				local turn = (index * 3 + k) * 1.7
				Shapes.prop(
					parent,
					"Boulders",
					Vector3.new(at.X, 0, at.Z) + across * k * 4.5,
					7 * 1.2,
					Vector3.new(math.cos(turn), 0, math.sin(turn))
				)
			end
		end
	end
end

-- The fences only these styles make: "Rope" (a rope rail; `across` a lane, a broken bridge
-- hanging `away` from it) and "Rockfall". Any other style goes to Fences.fence.
function Edges.fence(
	parent: Instance,
	points: { Vector3 },
	style: WorldTypes.FenceStyle,
	waters: { Fences.Water },
	pick: Random,
	away: Vector3?
)
	if style == "Rope" then
		Edges.run(parent, points, "Rope", waters, pick)
		if away and away.Magnitude > 1e-3 and #points >= 2 then
			brokenBridge(parent, points, away)
		end
	elseif style == "Rockfall" then
		rockfall(parent, points, waters)
	else
		Fences.fence(parent, points, style, waters)
	end
end

return Edges
