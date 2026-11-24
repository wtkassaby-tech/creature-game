--!strict
-- The brook, the river, the pond and the things beside them: banks, flat stones, reeds, lily
-- pads, the jetty, stepping stones and the footbridge (docs/plans/08_GREENWOOD_MAP.md section 5).
-- Water is only looks: nothing here is collidable except the rocks round the pond and the
-- bridge's rails, so a player can always wade out of a stream.

local Props = require(script.Parent.Props)

local Water = {}

local BANK = Props.rgb(150, 130, 100)
local FOAM = Props.rgb(228, 240, 238) -- the pale line where the water laps the bank
local ROCK = Props.rgb(178, 172, 160)
local REED = Props.rgb(96, 130, 70)
local BANK_TOP = 0.4 -- the bank's top: under a lane (0.42) and above the water
local TOP = 0.13 -- the water's surface, sunk about 0.3 below the bank so it reads as cut into it
local FOAM_TOP = TOP - 0.01 -- the foam lies just under the surface and shows only past its edge
local FOAM_WIDER = 1.6 -- the foam is this much wider than the water
local BANK_WIDE = 1.5 -- the bank's strip each side of the foam
local INNER_DARK = 0.14 -- how much darker the deeper middle is
local INNER_SHARE = 0.5 -- the deeper middle's share of the width

-- A strip of bank along each side of a leg of water, standing clear of its edge.
local function banksAlong(folder: Instance, a: Vector3, b: Vector3, width: number)
	local run = Vector3.new(b.X - a.X, 0, b.Z - a.Z)
	if run.Magnitude < 0.05 then
		return
	end
	local across = Vector3.new(-run.Z, 0, run.X).Unit
	local off = (width + FOAM_WIDER) / 2 + BANK_WIDE / 2 - 0.3
	for _, side in { -1, 1 } do
		local shift = across * off * side
		local bank = Props.strip(folder, a + shift, b + shift, BANK_WIDE, 0.3, BANK_TOP, BANK)
		if bank then
			bank.CanQuery = false
			bank.CastShadow = false
		end
	end
end

-- A ring of bank round a round pool: short flat strips along the circle, just past the foam.
local function bankRing(folder: Instance, centre: Vector3, radius: number)
	local ringRadius = radius + FOAM_WIDER / 2 + BANK_WIDE / 2 - 0.3
	local count = math.clamp(math.floor(ringRadius * 1.6), 10, 24)
	for index = 1, count do
		local a1 = (index - 1) / count * math.pi * 2
		local a2 = index / count * math.pi * 2 + 0.05 -- a little overlap: no gaps at the joints
		local from = centre + Vector3.new(math.cos(a1), 0, math.sin(a1)) * ringRadius
		local to = centre + Vector3.new(math.cos(a2), 0, math.sin(a2)) * ringRadius
		local bank = Props.strip(folder, from, to, BANK_WIDE, 0.3, BANK_TOP, BANK)
		if bank then
			bank.CanQuery = false
			bank.CastShadow = false
		end
	end
end

-- A stream along a line of points: slabs with a disc at each joint to hide the seams, a paler
-- foam line just wider than the water, a darker middle, a bank strip each side raised above
-- the water, and flat stones along its edges every 8 to 12 studs.
function Water.stream(
	parent: Instance,
	points: { Vector3 },
	width: number,
	colour: Color3,
	pick: Random
)
	local folder = Instance.new("Folder")
	folder.Name = "Water"
	folder.Parent = parent
	local deep = colour:Lerp(Color3.new(0, 0, 0), INNER_DARK)
	for index = 1, #points do
		local at = points[index]
		Props.disc(folder, at, width + FOAM_WIDER, 0.3, FOAM_TOP, FOAM)
		Props.disc(folder, at, width, 0.3, TOP, colour)
		Props.disc(folder, at, width * INNER_SHARE, 0.3, TOP + 0.01, deep)
		local after = points[index + 1]
		if after then
			Props.strip(folder, at, after, width + FOAM_WIDER, 0.3, FOAM_TOP, FOAM)
			Props.strip(folder, at, after, width, 0.3, TOP, colour)
			Props.strip(folder, at, after, width * INNER_SHARE, 0.3, TOP + 0.01, deep)
			banksAlong(folder, at, after, width)
		end
	end
	local along = 0
	local samples = Props.resample(points, 1)
	local nextStone = pick:NextNumber(8, 12)
	for index = 2, #samples do
		local a, b = samples[index - 1], samples[index]
		along += (b - a).Magnitude
		if along >= nextStone and (b - a).Magnitude > 1e-3 then
			nextStone = along + pick:NextNumber(8, 12)
			local run = (b - a).Unit
			local side = Vector3.new(-run.Z, 0, run.X)
				* ((width + FOAM_WIDER) / 2 + 0.8)
				* (if index % 2 == 0 then 1 else -1)
			local size = pick:NextNumber(1.6, 3)
			Props.lump(
				folder,
				Vector3.new(size, 0.6, size * 0.8),
				b + side + Vector3.yAxis * BANK_TOP,
				ROCK
			)
		end
	end
end

-- A round pool of water (the spring, the heron inlet), with a bank ring.
function Water.pool(parent: Instance, centre: Vector3, radius: number, colour: Color3)
	Props.disc(parent, centre, radius * 2 + FOAM_WIDER, 0.3, FOAM_TOP, FOAM)
	Props.disc(parent, centre, radius * 2, 0.3, TOP, colour)
	Props.disc(
		parent,
		centre,
		radius * 2 * INNER_SHARE,
		0.3,
		TOP + 0.01,
		colour:Lerp(Color3.new(0, 0, 0), INNER_DARK)
	)
	bankRing(parent, centre, radius)
end

-- A clump of reeds: the painted Reeds, or three thin stems with brown tops.
function Water.reeds(parent: Instance, foot: Vector3, pick: Random)
	local painted = Props.model("Reeds")
	if painted then
		local turn = pick:NextNumber(0, math.pi * 2)
		Props.stand(
			parent,
			painted,
			foot,
			pick:NextNumber(4, 5.5),
			Vector3.new(math.cos(turn), 0, math.sin(turn))
		)
		return
	end
	for _ = 1, 3 do
		local at = foot + Vector3.new(pick:NextNumber(-0.8, 0.8), 0, pick:NextNumber(-0.8, 0.8))
		local tall = pick:NextNumber(3.5, 5)
		Props.part(
			parent,
			Vector3.new(0.3, tall, 0.3),
			CFrame.new(at + Vector3.yAxis * tall / 2),
			REED
		)
		Props.lump(
			parent,
			Vector3.new(0.6, 1.2, 0.6),
			at + Vector3.yAxis * (tall - 0.4),
			Props.rgb(120, 80, 50)
		)
	end
end

-- The pond: a surface with a darker middle for depth, a bank ring, rocks round the edge, reeds
-- along its south half, five lily pads (one in flower) and a plank jetty from the north with a
-- bench beside it.
function Water.pond(
	parent: Instance,
	centre: Vector3,
	radius: number,
	colour: Color3,
	jetty: { Vector3 },
	pick: Random
)
	local folder = Instance.new("Folder")
	folder.Name = "Pond"
	folder.Parent = parent
	Props.disc(folder, centre, radius * 2 + FOAM_WIDER, 0.4, FOAM_TOP, FOAM)
	Props.disc(folder, centre, radius * 2, 0.4, TOP, colour)
	Props.disc(folder, centre, radius * 2 - 4, 0.4, TOP + 0.01, Props.rgb(70, 140, 180))
	bankRing(folder, centre, radius)
	for index = 1, 8 do
		local angle = index / 8 * math.pi * 2 + 0.3
		local at = centre + Vector3.new(math.cos(angle), 0, math.sin(angle)) * (radius + 1.5)
		local size = pick:NextNumber(2, 5)
		local rock = Props.lump(
			folder,
			Vector3.new(size, size * 0.6, size * 0.8),
			at + Vector3.yAxis * size * 0.2,
			ROCK
		)
		rock.CanCollide = true
	end
	-- Reeds along the south half (+z is south).
	for index = 0, 9 do
		local angle = math.rad(10 + index * 16)
		Water.reeds(
			folder,
			centre + Vector3.new(math.cos(angle), 0, math.sin(angle)) * (radius - 1.5),
			pick
		)
	end
	for index = 1, 5 do
		local angle = index / 5 * math.pi * 2
		local at = centre + Vector3.new(math.cos(angle), 0, math.sin(angle)) * (radius * 0.55)
		Props.disc(folder, at, 3, 0.2, TOP + 0.12, Props.rgb(90, 160, 80))
		if index == 1 then
			Props.lump(
				folder,
				Vector3.new(1, 0.8, 1),
				at + Vector3.yAxis * (TOP + 0.4),
				Props.rgb(240, 150, 180)
			)
		end
	end
	if #jetty >= 2 then
		local a, b = jetty[1], jetty[#jetty]
		local deck = Props.strip(folder, a, b, 4, 0.4, 0.6, Props.rgb(170, 130, 90))
		if deck then
			deck.Name = "Jetty"
			deck.CanCollide = true
		end
		local run = (b - a).Unit
		Props.bench(folder, a + Vector3.new(-run.Z, 0, run.X) * 5, -Vector3.new(-run.Z, 0, run.X))
	end
end

-- Stepping stones from `a` to `b`: flat grey discs every 3.2 studs, a little out of line.
function Water.stones(parent: Instance, a: Vector3, b: Vector3, pick: Random)
	local length = (b - a).Magnitude
	local count = math.max(1, math.floor(length / 3.2))
	for k = 0, count do
		local at = a:Lerp(b, k / count)
			+ Vector3.new(pick:NextNumber(-0.6, 0.6), 0, pick:NextNumber(-0.6, 0.6))
		Props.disc(parent, at, 3.5, 0.4, 0.42, ROCK)
	end
end

-- The humpbacked footbridge: the painted Footbridge stretched over the span, or a plank deck
-- with rails. A path heading `along` crosses it.
function Water.footbridge(
	parent: Instance,
	centre: Vector3,
	along: Vector3,
	length: number,
	width: number
)
	local painted = Props.model("Footbridge")
	if painted then
		-- Its deck runs along its own X axis.
		Props.span(parent, painted, centre, along, length, width, width * 0.6)
		return
	end
	local run = along.Unit
	local side = Vector3.new(-run.Z, 0, run.X)
	local deck = Props.strip(
		parent,
		centre - run * length / 2,
		centre + run * length / 2,
		width,
		0.6,
		0.7,
		Props.rgb(170, 130, 90)
	)
	if deck then
		deck.Name = "Footbridge"
		deck.CanCollide = true
	end
	for _, s in { -1, 1 } do
		local edge = side * (width / 2 - 0.3) * s
		local rail = Props.strip(
			parent,
			centre - run * length / 2 + edge,
			centre + run * length / 2 + edge,
			0.4,
			0.4,
			3.4,
			Props.rgb(150, 108, 70)
		)
		if rail then
			rail.CanCollide = true
		end
		for _, post in
			Props.resample(
				{ centre - run * length / 2 + edge, centre + run * length / 2 + edge },
				5
			)
		do
			Props.part(
				parent,
				Vector3.new(0.5, 3, 0.5),
				CFrame.new(post.X, 1.9, post.Z),
				Props.rgb(150, 108, 70)
			)
		end
	end
end

-- The little waterfall above the spring: a rock mound with a ribbon of water down its face.
function Water.waterfall(parent: Instance, foot: Vector3, towards: Vector3, colour: Color3)
	local run = Vector3.new(towards.X - foot.X, 0, towards.Z - foot.Z)
	local ahead = if run.Magnitude > 1e-3 then run.Unit else Vector3.zAxis
	Props.lump(parent, Vector3.new(16, 12, 10), foot + Vector3.yAxis * 3, ROCK)
	Props.lump(
		parent,
		Vector3.new(10, 9, 8),
		foot - ahead * 3 + Vector3.yAxis * 7,
		Props.rgb(150, 146, 136)
	)
	local fall = Props.part(
		parent,
		Vector3.new(3, 8, 0.4),
		CFrame.lookAt(foot + ahead * 4.6 + Vector3.yAxis * 4, foot + ahead * 6 + Vector3.yAxis * 4)
			* CFrame.Angles(math.rad(-12), 0, 0),
		colour
	)
	fall.Transparency = 0.15
end

return Water
