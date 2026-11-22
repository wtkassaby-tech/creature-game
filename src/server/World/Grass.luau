--!strict
-- Long grass that looks like grass (docs/plans/08_GREENWOOD_MAP.md section 5). The dark ground
-- disc is exactly the circle the server checks for an ambush (the patch's place and
-- WorldConfig.GRASS_RADIUS), and the tufts stay inside it, so what a player sees is where a
-- creature can jump out. Tufts are only looks: not collidable, not queryable, no shadow.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WorldConfig = require(ReplicatedStorage.config.WorldConfig)

local Props = require(script.Parent.Props)

local Grass = {}

local UNDER = Props.rgb(78, 128, 58)
local LIGHT = Props.rgb(104, 178, 74)
local DARK = Props.rgb(84, 158, 66)
local SPACING = 3.6 -- studs between tufts on the hex grid
local EDGE = 1.5 -- tufts stop this far inside the server's circle (18.5 of 20)
local MOST_TUFTS = 95 -- per patch, for phones

local function quiet(piece: BasePart)
	piece.CanCollide = false
	piece.CanQuery = false
	piece.CanTouch = false
	piece.CastShadow = false
end

-- One tuft: the painted GrassTuft, or three thin wedges fanned out and leaning a little.
local function tuft(parent: Instance, foot: Vector3, pick: Random, light: boolean)
	local turn = pick:NextNumber(0, math.pi * 2)
	local scale = pick:NextNumber(0.85, 1.15)
	local painted = Props.model("GrassTuft")
	if painted then
		local made = Props.stand(
			parent,
			painted,
			foot,
			2.5 * scale * (if light then 1.05 else 0.95),
			Vector3.new(math.cos(turn), 0, math.sin(turn))
		)
		quiet(made)
		return
	end
	for blade = 0, 2 do
		local wedge = Instance.new("WedgePart")
		wedge.Anchored = true
		wedge.Size = Vector3.new(0.4, 3.6 * scale, 1.2)
		wedge.Color = if (blade + (if light then 1 else 0)) % 2 == 0 then LIGHT else DARK
		wedge.Material = Enum.Material.SmoothPlastic
		wedge.CFrame = CFrame.new(foot)
			* CFrame.Angles(0, turn + math.rad(blade * 60), 0)
			* CFrame.Angles(math.rad(8), 0, 0)
			* CFrame.new(0, 1.8 * scale, 0)
		quiet(wedge)
		wedge.Parent = parent
	end
end

-- A patch of long grass named `name` round `centre`: the server's circle as a dark disc, and
-- tufts on a jittered hex grid inside it.
function Grass.patch(parent: Instance, name: string, centre: Vector3, pick: Random): Part
	local radius = WorldConfig.GRASS_RADIUS
	local disc = Props.disc(parent, centre, radius * 2, 0.1, 0.16, UNDER)
	disc.Name = name
	quiet(disc)
	local folder = Instance.new("Folder")
	folder.Name = `{name}_tufts`
	folder.Parent = parent
	local reach = radius - EDGE
	local rowGap = SPACING * math.sqrt(3) / 2
	local count = 0
	local rows = math.floor(reach / rowGap)
	for rowIndex = -rows, rows do
		local z = rowIndex * rowGap
		local shift = if rowIndex % 2 == 0 then 0 else SPACING / 2
		local columns = math.floor(reach / SPACING) + 1
		for column = -columns, columns do
			local x = column * SPACING + shift
			local jitter = Vector3.new(pick:NextNumber(-0.6, 0.6), 0, pick:NextNumber(-0.6, 0.6))
			local offset = Vector3.new(x, 0, z) + jitter
			-- Every tuft's foot is inside 18.5, so its blades stay over the dark disc.
			if offset.Magnitude <= reach and count < MOST_TUFTS then
				count += 1
				tuft(folder, centre + offset + Vector3.yAxis * 0.16, pick, count % 2 == 0)
			end
		end
	end
	return disc
end

return Grass
