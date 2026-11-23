--!strict
-- Stairs and ramps between tiers (docs/plans/12_MAP_STRUCTURE.md section 4c). A character cannot
-- step up ten studs of risers, so each link is one smooth, solid slope from the low ground to the
-- high; stairs wear a flight of pale stone treads over it (looks only), ramps a dirt lane. A solid
-- stone cheek stands along each side (with an unseen taller core inside it), so nobody walks or
-- hops off the side of a flight onto the low ground beside it. Ledges are not built here: a ledge
-- is only a stretch of a tier's lip (Tiers.luau marks it with a trodden notch).
-- The slope, treads and cheeks are tagged "WorldGround", so the battle scene never hides them.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Ground = require(ReplicatedStorage.shared.Ground)

local Props = require(script.Parent.Props)

local Links = {}

local STONE = Props.rgb(204, 198, 180)
local DIRT = Props.rgb(204, 180, 128)
local CHEEK = Props.rgb(150, 158, 138)
local RISER = 1.25 -- studs: the height of one tread
local CHEEK_STEP = 5 -- studs: the length of one cheek piece
local CHEEK_VISIBLE = 2.2 -- studs a cheek stands over the slope
local CHEEK_CORE = 8 -- studs the unseen core stands over the slope: taller than a jump

-- How many parts a build made.
export type Counts = { slopes: number, treads: number, cheeks: number }

local function solid(part: BasePart, name: string)
	part.Name = name
	part.CanCollide = true
	part.CanTouch = false
	part:AddTag("WorldGround")
end

function Links.build(parent: Instance, ground: Ground.Ground): Counts
	local folder = Instance.new("Folder")
	folder.Name = "Links"
	folder.Parent = parent
	local counts: Counts = { slopes = 0, treads = 0, cheeks = 0 }
	for _, link in ground.links do
		if link.kind == "Ledge" then
			continue
		end
		local rise = link.h1 - link.h0
		local flatFrom = Vector3.new(link.ax, link.h0, link.az)
		local flatTo = Vector3.new(link.bx, link.h1, link.bz)
		local ahead = Vector3.new(link.ux, 0, link.uz)
		local colour = if link.kind == "Stairs" then STONE else DIRT

		-- The slope: a slab 1.2 thick, its top along the line from the low end to the high.
		local middle = (flatFrom + flatTo) / 2
		local slab = Props.part(
			folder,
			Vector3.new(link.width, 1.2, (flatTo - flatFrom).Magnitude + 0.6),
			CFrame.lookAt(middle, flatTo) * CFrame.new(0, -0.6, 0),
			colour
		)
		solid(slab, link.id)
		counts.slopes += 1

		-- The painted flight or ramp sits over the slab (which stays as the walking surface,
		-- unseen): its low end, the model's front, toward the low tier.
		local painted = Props.model(if link.kind == "Stairs" then "StoneSteps" else "EarthRamp")
		if painted then
			local up = math.abs(rise)
			local copy = painted:Clone()
			copy.Size = Vector3.new(link.width + 0.6, up + 0.4, link.length + 0.6)
			local centre = (flatFrom + flatTo) / 2
			local low = math.min(link.h0, link.h1)
			local seat = Vector3.new(centre.X, low + (up + 0.4) / 2 - 0.2, centre.Z)
			-- `ahead` runs from the a end to the b end; the front must face the lower end.
			local towardLow = if link.h0 <= link.h1 then -ahead else ahead
			copy.CFrame = CFrame.lookAt(seat, seat + towardLow)
			copy.Anchored = true
			copy.CanCollide = false
			copy.CanQuery = false
			copy.CanTouch = false
			copy.Name = if link.kind == "Stairs" then "StoneSteps" else "EarthRamp"
			copy:AddTag("WorldGround")
			copy.Parent = folder
			slab.Transparency = 1
		end

		if link.kind == "Stairs" and not painted then
			local count = math.max(2, math.floor(math.abs(rise) / RISER + 0.5))
			local run = link.length / count
			for k = 0, count - 1 do
				local centre = flatFrom + ahead * (run * (k + 0.5))
				local top = link.h0 + rise * (k + 1) / count
				local tread = Props.part(
					folder,
					Vector3.new(link.width - 0.4, 1.8, run - 0.1),
					CFrame.lookAt(
						Vector3.new(centre.X, top - 0.9, centre.Z),
						Vector3.new(centre.X, top - 0.9, centre.Z) + ahead
					),
					STONE:Lerp(Props.rgb(170, 164, 148), (k % 2) * 0.25)
				)
				tread.Name = "Tread"
				tread.CanTouch = false
				tread.CanQuery = false
				tread:AddTag("WorldGround")
				counts.treads += 1
			end
		end

		-- A cheek down each side, in pieces of CHEEK_STEP.
		local pieces = math.max(1, math.ceil(link.length / CHEEK_STEP))
		local piece = link.length / pieces
		local left = Vector3.new(link.uz, 0, -link.ux)
		for _, side in { -1, 1 } do
			for k = 0, pieces - 1 do
				local t = (k + 0.5) / pieces
				local centre = flatFrom
					+ ahead * (link.length * t)
					+ left * side * (link.width / 2 + 0.8)
				local surface = link.h0 + rise * t
				local facing = centre + ahead
				local visibleTall = surface + CHEEK_VISIBLE
				local wall = Props.part(
					folder,
					Vector3.new(1.6, visibleTall, piece + 0.3),
					CFrame.lookAt(
						Vector3.new(centre.X, visibleTall / 2, centre.Z),
						Vector3.new(facing.X, visibleTall / 2, facing.Z)
					),
					CHEEK
				)
				solid(wall, "Cheek")
				if painted then
					-- The painted flight has its own sides: the cheek stays only as a wall.
					wall.Transparency = 1
					wall.CastShadow = false
				end
				local coreTall = surface + CHEEK_CORE
				local core = Props.part(
					folder,
					Vector3.new(1.4, coreTall, piece + 0.3),
					CFrame.lookAt(
						Vector3.new(centre.X, coreTall / 2, centre.Z),
						Vector3.new(facing.X, coreTall / 2, facing.Z)
					),
					CHEEK
				)
				solid(core, "CheekCore")
				core.Transparency = 1
				core.CanQuery = false
				core.CastShadow = false
				counts.cheeks += 2
			end
		end
	end
	return counts
end

return Links
