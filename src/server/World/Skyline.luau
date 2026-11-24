--!strict
-- Plain-shape stand-ins for a biome's far landmark when its painted model is missing or will not
-- load (docs/plans/09_DUST_CANYON_MAP.md section 4c): the Redstack mesa and the Old Light. Split
-- from Shapes.luau. Looks only: Landmarks stands an unseen core under whatever is built here.

local Props = require(script.Parent.Props)
local Shapes = require(script.Parent.Shapes)

local Skyline = {}

local rgb = Props.rgb
local cylinder = Shapes.cylinder

-- The Redstack built from the canyon's own cliff pieces: three rings, narrowing upwards, each
-- a polygon of CliffWall sections stacked in rows with their banded faces outward, a solid
-- core inside so no gap shows through, and a flat cap with scrub on top. Two generated mesa
-- models both came out looking like layered cakes (23 November 2026), so the mesa is built from
-- the piece that does look like canyon rock. About a hundred pieces, for the one landmark.
-- Two broad tiers (the plan's footprint is 160 across), one tall row of pieces each, so the cliff piece's
-- cream top shows as a ledge now and then rather than on every row (a first cut with three narrow
-- tiers of short rows looked like a tower of stacked bands).
local TIERS: { { radius: number, tall: number, sides: number } } = {
	{ radius = 80, tall = 112, sides = 14 },
	{ radius = 64, tall = 78, sides = 12 },
}
local ROW = 120 -- each row of cliff pieces is this tall: one row a tier, one ledge between them
local ROCK = rgb(186, 92, 66)
local CAP = rgb(224, 170, 120)

function Skyline.cliffMesa(parent: Instance, cliff: MeshPart, foot: Vector3, scale: number): Vector2
	local height = 0
	local scrub = Props.model("ScrubBush")
	for tierIndex, tier in TIERS do
		local radius, tall = tier.radius * scale, tier.tall * scale
		-- An uneven outline, the same every time: each corner in or out by up to an eighth, and
		-- each tier set a little off the one below, as a weathered mesa is.
		local function corner(k: number): Vector3
			local turn = k / tier.sides * math.pi * 2
			local wobble = 1 + 0.13 * math.sin(k * 2.7 + tierIndex * 1.9)
			return Vector3.new(math.cos(turn), 0, math.sin(turn)) * radius * wobble
		end
		local centre = Vector3.new(tierIndex - 1, 0, 1 - tierIndex) * 0.12 * radius
		local rows = math.max(1, math.round(tall / (ROW * scale)))
		local rowTall = tall / rows
		-- The core: a solid drum just inside the ring.
		local core = Shapes.cylinder(
			parent,
			foot + centre + Vector3.yAxis * height,
			radius * 2 * 0.82,
			tall,
			ROCK
		)
		core.CanCollide = true
		for row = 0, rows - 1 do
			-- Each row turned half a side from the one below, like brickwork.
			local shift = (row % 2) * 0.5
			for side = 0, tier.sides - 1 do
				local pa = corner(side + shift)
				local pb = corner(side + 1 + shift)
				local middle = (pa + pb) / 2
				local out = middle.Unit
				-- Props.span lays a piece's length along `along` with its front square to it;
				-- this `along` turns the front outward.
				local along = Vector3.new(-out.Z, 0, out.X)
				local length = (pb - pa).Magnitude * 1.08
				-- Each row a little in from the one below, so the side steps like ledges.
				local inset = out * (row * 1.5 * scale)
				Props.span(
					parent,
					cliff,
					foot + centre + middle - inset + Vector3.yAxis * (height + row * rowTall),
					along,
					length,
					14 * scale,
					rowTall + 2 * scale
				)
			end
		end
		height += tall
	end
	local top = TIERS[#TIERS]
	local topCentre = Vector3.new(#TIERS - 1, 0, 1 - #TIERS) * 0.12 * top.radius * scale
	local capAt = foot + topCentre + Vector3.yAxis * height
	Shapes.cylinder(parent, capAt, top.radius * 2 * scale * 0.95, 3 * scale, CAP)
	if scrub then
		for k = 0, 5 do
			local turn = k / 6 * math.pi * 2
			local at = foot
				+ topCentre
				+ Vector3.new(math.cos(turn), 0, math.sin(turn)) * top.radius * 0.55 * scale
				+ Vector3.yAxis * (height + 3 * scale)
			Props.stand(
				parent,
				scrub,
				at,
				9 * scale,
				Vector3.new(math.sin(turn), 0, math.cos(turn))
			)
		end
	end
	local base = TIERS[1].radius * 2 * scale
	return Vector2.new(base, base)
end

-- The far landmark's plain stand-in, standing at `foot`, `tall` high, its face along `facing`.
-- Returns the footprint (width and depth) for the unseen core under it.
function Skyline.landmark(
	parent: Instance,
	name: string,
	foot: Vector3,
	tall: number,
	facing: Vector3
): Vector2
	local base = CFrame.lookAt(foot, foot + facing)
	if name == "OldLighthouse" then
		Props.lump(parent, Vector3.new(50, 40, 50), foot, rgb(90, 90, 96))
		local tower = tall * 0.8
		local steps = 4
		for k = 0, steps - 1 do -- tapering from 18 across to 14
			local across = 18 - 4 * k / (steps - 1)
			cylinder(
				parent,
				foot + Vector3.yAxis * (10 + tower * k / steps),
				across,
				tower / steps,
				rgb(244, 240, 232)
			)
		end
		for k = 1, 3 do
			cylinder(
				parent,
				foot + Vector3.yAxis * (10 + tower * k / 4 - 4),
				18.4 - k * 1.2,
				8,
				rgb(206, 72, 64)
			)
		end
		local top = 10 + tower
		cylinder(parent, foot + Vector3.yAxis * top, 16, 12, rgb(30, 30, 36))
		local light = Props.lump(
			parent,
			Vector3.new(9, 8, 9),
			foot + Vector3.yAxis * (top + 6),
			rgb(255, 226, 120)
		)
		light.Material = Enum.Material.Neon
		local glow = Instance.new("PointLight")
		glow.Range = 60
		glow.Color = rgb(255, 226, 120)
		glow.Parent = light
		return Vector2.new(50, 50)
	elseif name == "RedMesa" then
		local scale = tall / 190
		local cliff = Props.model("CliffWall")
		if cliff then
			return Skyline.cliffMesa(parent, cliff, foot, scale)
		end
		-- Three stacked bands, narrowing upwards, with rounded lumps on their edges, and a cap.
		local bands: { { size: Vector3, colour: Color3 } } = {
			{ size = Vector3.new(150, 70, 130), colour = rgb(196, 98, 70) },
			{ size = Vector3.new(130, 70, 112), colour = rgb(222, 150, 100) },
			{ size = Vector3.new(110, 50, 96), colour = rgb(236, 200, 150) },
		}
		local height = 0
		for _, band in bands do
			local size = band.size * scale
			Props.part(parent, size, base * CFrame.new(0, height + size.Y / 2, 0), band.colour)
			for _, x in { -1, 1 } do
				for _, z in { -1, 1 } do
					Props.lump(
						parent,
						Vector3.new(size.X * 0.3, size.Y * 0.8, size.Z * 0.3),
						(base * CFrame.new(
							x * size.X * 0.42,
							height + size.Y * 0.45,
							z * size.Z * 0.42
						)).Position,
						band.colour:Lerp(Color3.new(0, 0, 0), 0.08)
					)
				end
			end
			height += size.Y
		end
		Props.part(
			parent,
			Vector3.new(90, 6, 80) * scale,
			base * CFrame.new(0, height + 3 * scale, 0),
			rgb(200, 120, 90)
		)
		return Vector2.new(150, 130) * scale
	end
	-- Anything else: one great rock.
	Props.lump(parent, Vector3.new(tall * 0.6, tall * 2, tall * 0.6), foot, rgb(170, 150, 130))
	return Vector2.new(tall * 0.6, tall * 0.6)
end

return Skyline
