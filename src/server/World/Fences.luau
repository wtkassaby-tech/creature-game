--!strict
-- Hedges, fences, walls and the low rails where water passes under them. All of them block the
-- way, and every collidable piece is at most 40 studs long: the battle scene hides things at
-- least 1.5 tall and under 100 wide near its creatures, so long runs must come in short pieces
-- (docs/plans/08_GREENWOOD_MAP.md section 6). The bushes and pickets on top are only looks.

local Props = require(script.Parent.Props)

local Fences = {}

-- Water a hedge or fence stops short of: a line of points and half its width.
export type Water = { points: { Vector3 }, half: number }

local HEDGE = Props.rgb(70, 130, 60)
local PICKET = Props.rgb(244, 236, 220)
local RUSTIC = Props.rgb(140, 105, 70)
local STONE = Props.rgb(170, 165, 150)
local LEAF = Props.rgb(84, 150, 70)

local MAX_PIECE = 36 -- studs: the longest straight piece, so overlaps stay under 40
local BUSH_SPACING = 4 -- studs between bushes along a hedge top (plan section 5)
local WATER_CLEARANCE = 2 -- a hedge stops this far short of the water's edge

-- Splits a line sampled every stud into straight pieces no longer than MAX_PIECE.
local function pieces(samples: { Vector3 }): { { Vector3 } }
	local out: { { Vector3 } } = {}
	local start = 1
	while start < #samples do
		local finish = start + 1
		while finish < #samples and finish - start < MAX_PIECE do
			-- Stop at a corner: the next sample would leave the straight line from the start.
			local a, b, next = samples[start], samples[finish], samples[finish + 1]
			local run = next - a
			if run.Magnitude > 1e-3 then
				local unit = run.Unit
				local offset = (b - a) - unit * (b - a):Dot(unit)
				if offset.Magnitude > 0.6 then
					break
				end
			end
			finish += 1
		end
		table.insert(out, { samples[start], samples[finish] })
		start = finish
	end
	return out
end

-- Splits a line into the stretches that stay clear of water, and the gaps where water crosses.
local function clearOfWater(
	points: { Vector3 },
	waters: { Water }
): ({ { Vector3 } }, { { Vector3 } })
	local samples = Props.resample(points, 1)
	local runs: { { Vector3 } } = {}
	local gaps: { { Vector3 } } = {}
	local current: { Vector3 } = {}
	local lastKept: Vector3? = nil
	for _, sample in samples do
		local wet = false
		for _, water in waters do
			local _, off = Props.nearest(water.points, sample)
			if off < water.half + WATER_CLEARANCE then
				wet = true
				break
			end
		end
		if wet then
			if #current > 0 then
				table.insert(runs, current)
				current = {}
			end
		else
			if #current == 0 and lastKept then
				table.insert(gaps, { lastKept, sample })
			end
			table.insert(current, sample)
			lastKept = sample
		end
	end
	if #current > 0 then
		table.insert(runs, current)
	end
	return runs, gaps
end

local function block(parent: Instance, a: Vector3, b: Vector3, thick: number, tall: number): Part?
	local flatA, flatB = Vector3.new(a.X, tall / 2, a.Z), Vector3.new(b.X, tall / 2, b.Z)
	local length = (flatB - flatA).Magnitude
	if length < 0.2 then
		return nil
	end
	local made = Props.part(
		parent,
		Vector3.new(thick, tall, length + thick / 2),
		CFrame.lookAt((flatA + flatB) / 2, flatB),
		HEDGE
	)
	made.CanCollide = true
	return made
end

-- A low rail across water where a hedge or fence stops: posts and a bar, easy to see over and
-- just low enough to hop.
function Fences.rail(parent: Instance, a: Vector3, b: Vector3)
	for _, piece in pieces(Props.resample({ a, b }, 1)) do
		local wall = block(parent, piece[1], piece[2], 0.6, 2.6)
		if wall then
			wall.Name = "WaterRail"
			wall.Transparency = 1
		end
		local bar =
			block(parent, piece[1] + Vector3.yAxis * 1.1, piece[2] + Vector3.yAxis * 1.1, 0.4, 0.4)
		if bar then
			bar.CanCollide = false
			bar.Color = RUSTIC
		end
	end
	for _, post in Props.resample({ a, b }, 6) do
		Props.part(parent, Vector3.new(0.6, 2.8, 0.6), CFrame.new(post.X, 1.4, post.Z), RUSTIC)
	end
end

-- A hedge along a line: green blocks 6 tall and 4 thick with bushes along the top, stopped
-- short wherever water passes under it, with a low rail across the water instead.
function Fences.hedge(parent: Instance, points: { Vector3 }, waters: { Water })
	local runs, gaps = clearOfWater(points, waters)
	local bush = Props.model("Bush")
	for _, run in runs do
		for _, piece in pieces(run) do
			local made = block(parent, piece[1], piece[2], 4, 6)
			if made then
				made.Name = "Hedge"
			end
		end
		for _, at in Props.resample(run, BUSH_SPACING) do
			local top = Vector3.new(at.X, 5.4, at.Z)
			if bush then
				Props.stand(parent, bush, top, 3.2, Vector3.new(at.Z % 7 - 3, 0, at.X % 5 - 2))
			else
				Props.lump(parent, Vector3.new(4.6, 3, 4.6), top + Vector3.yAxis * 1, LEAF)
			end
		end
	end
	for _, gap in gaps do
		if (gap[2] - gap[1]).Magnitude < 80 then
			Fences.rail(parent, gap[1], gap[2])
		end
	end
end

-- A run of posts with two rails (the plain-shape picket and rustic fences).
local function postsAndRails(
	parent: Instance,
	a: Vector3,
	b: Vector3,
	colour: Color3,
	every: number
)
	for _, at in Props.resample({ a, b }, every) do
		Props.part(parent, Vector3.new(0.8, 4, 0.8), CFrame.new(at.X, 2, at.Z), colour)
	end
	for _, height in { 1.5, 3 } do
		local rail = block(
			parent,
			a + Vector3.yAxis * (height - 0.25),
			b + Vector3.yAxis * (height - 0.25),
			0.4,
			0.5
		)
		if rail then
			rail.CanCollide = false
			rail.Color = colour
		end
	end
end

-- A fence along a line: "Picket" (white, the painted FenceSection when there is one), "Gate"
-- (a shut picket gate), "Rustic" (brown posts and rails) or "Stone" (a low wall). Each is
-- collidable along its whole length and stops short of water like a hedge.
function Fences.fence(parent: Instance, points: { Vector3 }, style: string, waters: { Water })
	local runs, gaps = clearOfWater(points, waters)
	local section = if style == "Picket" or style == "Gate"
		then Props.model("FenceSection")
		else nil
	for _, run in runs do
		for _, piece in pieces(run) do
			local a, b = piece[1], piece[2]
			if style == "Stone" then
				local wall = block(parent, a, b, 2, 2.5)
				if wall then
					wall.Name = "StoneWall"
					wall.Color = STONE
				end
				continue
			end
			-- What you bump into is one plain block per piece; the pickets are only looks.
			local wall = block(parent, a, b, 1, 4)
			if wall then
				wall.Name = if style == "Gate" then "ShutGate" else "Fence"
				wall.Transparency = 1
			end
			local length = (b - a).Magnitude
			if section then
				local count = math.max(1, math.ceil(length / 8))
				for k = 1, count do
					local middle = a:Lerp(b, (k - 0.5) / count)
					Props.span(
						parent,
						section,
						Vector3.new(middle.X, 0, middle.Z),
						b - a,
						length / count + 0.1,
						1,
						4
					)
				end
			else
				local colour = if style == "Rustic"
					then RUSTIC
					elseif style == "Gate" then Props.rgb(200, 150, 90)
					else PICKET
				postsAndRails(parent, a, b, colour, if style == "Rustic" then 8 else 6)
			end
		end
	end
	for _, gap in gaps do
		if (gap[2] - gap[1]).Magnitude < 80 then
			Fences.rail(parent, gap[1], gap[2])
		end
	end
end

return Fences
