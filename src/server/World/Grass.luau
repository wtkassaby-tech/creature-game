--!strict
-- Long grass that looks like grass (docs/plans/08_GREENWOOD_MAP.md section 5). The dark ground
-- disc is exactly the circle the server checks for an ambush (the patch's place and
-- WorldConfig.GRASS_RADIUS), and the tufts stay inside it, so what a player sees is where a
-- creature can jump out. Tufts are only looks: not collidable, not queryable, no shadow.
-- A dressing sheet can give a stretch its own look (docs/plans/09_DUST_CANYON_MAP.md section
-- 4c): dry tufts on straw ground, marram, reeds or kelp.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WorldConfig = require(ReplicatedStorage.config.WorldConfig)
local WorldTypes = require(ReplicatedStorage.shared.WorldTypes)

local Props = require(script.Parent.Props)
local Water = require(script.Parent.Water)

local Grass = {}

local UNDER: WorldTypes.Colour = { 78, 128, 58 }
local SPACING = 3.6 -- studs between tufts on the hex grid
local TALL_SPACING = 4.2 -- for tall tufts (reeds, kelp), so a patch stays near 70 pieces
local EDGE = 1.5 -- tufts stop this far inside the server's circle (18.5 of 20)
local MOST_TUFTS = 95 -- per patch, for phones
-- How tall each tuft model stands, before its small random scale.
local TUFT_TALL: { [string]: number } = {
	GrassTuft = 2.5,
	DryTuft = 2.5,
	MarramTuft = 3,
	Reeds = 4.75,
	Kelp = 5,
}

local function quiet(piece: BasePart)
	piece.CanCollide = false
	piece.CanQuery = false
	piece.CanTouch = false
	piece.CastShadow = false
end

-- A colour from data shifted by `add` on each channel (negative darkens), kept within 0 to 255.
local function lifted(colour: WorldTypes.Colour, add: { number }): Color3
	return Props.rgb(
		math.clamp(colour[1] + add[1], 0, 255),
		math.clamp(colour[2] + add[2], 0, 255),
		math.clamp(colour[3] + add[3], 0, 255)
	)
end

type Look = { model: string, tall: number, light: Color3, dark: Color3 }

-- One tuft: the painted model, or three thin wedges fanned out and leaning a little.
local function tuft(parent: Instance, foot: Vector3, pick: Random, light: boolean, look: Look)
	local turn = pick:NextNumber(0, math.pi * 2)
	local scale = pick:NextNumber(0.85, 1.15)
	local painted = Props.model(look.model)
	if painted then
		local made = Props.stand(
			parent,
			painted,
			foot,
			look.tall * scale * (if light then 1.05 else 0.95),
			Vector3.new(math.cos(turn), 0, math.sin(turn))
		)
		quiet(made)
		return
	end
	local grow = look.tall / 2.5
	for blade = 0, 2 do
		local wedge = Instance.new("WedgePart")
		wedge.Anchored = true
		wedge.Size = Vector3.new(0.4, 3.6 * scale * grow, 1.2)
		wedge.Color = if (blade + (if light then 1 else 0)) % 2 == 0 then look.light else look.dark
		wedge.Material = Enum.Material.SmoothPlastic
		wedge.CFrame = CFrame.new(foot)
			* CFrame.Angles(0, turn + math.rad(blade * 60), 0)
			* CFrame.Angles(math.rad(8), 0, 0)
			* CFrame.new(0, 1.8 * scale * grow, 0)
		quiet(wedge)
		wedge.Parent = parent
	end
end

-- A patch of long grass named `name` round `centre`: the server's circle as a dark disc, and
-- tufts on a jittered hex grid inside it. `look` gives the tuft model and the disc's colour;
-- left out, Greenwood's GrassTuft on dark green. `size` is the patch's radius: left out, the
-- stretch's own patch (WorldConfig.GRASS_RADIUS); the sheet's extra patches are smaller.
function Grass.patch(
	parent: Instance,
	name: string,
	centre: Vector3,
	pick: Random,
	look: WorldTypes.GrassLook?,
	size: number?
): Part
	local radius = size or WorldConfig.GRASS_RADIUS
	local under = if look then look.under else UNDER
	local model = if look then look.model else "GrassTuft"
	local tall = TUFT_TALL[model] or 2.5
	local style: Look = {
		model = model,
		tall = tall,
		-- Greenwood's wedges are (104, 178, 74) and (84, 158, 66) over (78, 128, 58).
		light = lifted(under, { 26, 50, 16 }),
		dark = lifted(under, { 6, 30, 8 }),
	}
	local disc = Props.disc(parent, centre, radius * 2, 0.1, 0.16, Props.colour(under))
	disc.Name = name
	quiet(disc)
	local folder = Instance.new("Folder")
	folder.Name = `{name}_tufts`
	folder.Parent = parent
	local spacing = if tall > 4 then TALL_SPACING else SPACING
	local reach = radius - EDGE
	local rowGap = spacing * math.sqrt(3) / 2
	local count = 0
	local rows = math.floor(reach / rowGap)
	for rowIndex = -rows, rows do
		local z = rowIndex * rowGap
		local shift = if rowIndex % 2 == 0 then 0 else spacing / 2
		local columns = math.floor(reach / spacing) + 1
		for column = -columns, columns do
			local x = column * spacing + shift
			local jitter = Vector3.new(pick:NextNumber(-0.6, 0.6), 0, pick:NextNumber(-0.6, 0.6))
			local offset = Vector3.new(x, 0, z) + jitter
			-- Every tuft's foot is inside 18.5, so its blades stay over the dark disc.
			if offset.Magnitude <= reach and count < MOST_TUFTS then
				count += 1
				tuft(folder, centre + offset + Vector3.yAxis * 0.16, pick, count % 2 == 0, style)
			end
		end
	end
	return disc
end

-- A search spot's ring, in the look of its stretch: in Greenwood a muddy patch ringed with reeds
-- (a knot of small bent trees in a wood); where the stretch has its own grass look, a ring of
-- that, larger, on its own ground colour, so a desert spot is not a pond.
function Grass.rustle(
	parent: Instance,
	patch: BasePart,
	area: string,
	pick: Random,
	look: WorldTypes.GrassLook?
)
	local centre = patch.Position
	local painted = if look and look.model ~= "GrassTuft" then Props.model(look.model) else nil
	local wooded = string.find(area, "wood", 1, true) ~= nil
	if painted and look then
		patch.Color = lifted(look.under, { -18, -18, -14 })
	end
	local count = if wooded then 5 else 8
	for k = 0, count - 1 do
		local turn = k / count * math.pi * 2
		local foot = Vector3.new(centre.X + math.cos(turn) * 9, 0, centre.Z + math.sin(turn) * 9)
		if painted then
			local tall = (TUFT_TALL[painted.Name] or 2.5) * (1.6 + pick:NextNumber() * 0.5)
			local turnTo = Vector3.new(math.cos(turn * 3), 0, math.sin(turn * 3))
			quiet(Props.stand(parent, painted, foot, tall, turnTo))
		elseif wooded then
			Props.tree(parent, foot, "Tree", 0.6, pick)
		else
			Water.reeds(parent, foot, pick)
		end
	end
end

return Grass
