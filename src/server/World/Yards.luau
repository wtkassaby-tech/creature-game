--!strict
-- The small yards of a designed town (docs/plans/08_GREENWOOD_MAP.md section 3): the breeder's
-- hen coop and straw nests, the garden rows (the mentor's vegetables, the spring garden by the
-- Seep) and the Circuit's oval rail with a bench either side. Each is left out when the dressing
-- sheet leaves it out. Split from Scenery.luau. Looks only, except the rail and the coop.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Layout = require(ReplicatedStorage.shared.Layout)
local WorldTypes = require(ReplicatedStorage.shared.WorldTypes)

local Fences = require(script.Parent.Fences)
local Props = require(script.Parent.Props)

local Yards = {}

local EARTH = Props.rgb(110, 84, 60)

local function placed(map: Layout.Map, point: WorldTypes.SheetPoint): Vector3
	return Vector3.new(map.hub.x + point.x, 0, map.hub.z + point.z)
end

function Yards.build(
	town: Instance,
	biome: WorldTypes.Biome,
	map: Layout.Map,
	dressing: WorldTypes.DressingSheet,
	waters: { Fences.Water }
)
	-- The breeder's yard: a hen coop and straw nests with eggs.
	if dressing.coop then
		local coop = placed(map, dressing.coop)
		local house = Props.part(
			town,
			Vector3.new(8, 5, 6),
			CFrame.new(coop + Vector3.yAxis * 2.5),
			Props.rgb(200, 150, 90)
		)
		house.CanCollide = true
		Props.part(
			town,
			Vector3.new(9, 1, 7),
			CFrame.new(coop + Vector3.yAxis * 5.5),
			Props.rgb(206, 88, 72)
		)
		for k = 1, 4 do
			local nest = coop + Vector3.new(-12 + k * 4, 0, 9)
			Props.lump(
				town,
				Vector3.new(3, 0.8, 3),
				nest + Vector3.yAxis * 0.3,
				Props.rgb(222, 196, 120)
			)
			Props.lump(
				town,
				Vector3.new(0.9, 1.2, 0.9),
				nest + Vector3.yAxis * 0.9,
				Props.rgb(250, 244, 230)
			)
		end
	end
	-- The garden rows.
	if dressing.patch then
		local patchFrom, patchTo = placed(map, dressing.patch.from), placed(map, dressing.patch.to)
		for x = patchFrom.X, patchTo.X, 3.5 do
			local a, b = Vector3.new(x, 0, patchFrom.Z), Vector3.new(x, 0, patchTo.Z)
			Props.strip(town, a, b, 2, 0.6, 0.5, EARTH)
			for _, at in Props.resample({ a, b }, 2.2) do
				Props.lump(
					town,
					Vector3.new(1.2, 1, 1.2),
					at + Vector3.yAxis * 0.9,
					Props.rgb(96, 170, 80)
				)
			end
		end
	end

	-- The Circuit (the Ring, the Dust Ring): an oval rail open at the front, with benches either
	-- side.
	local ringId: string? = nil
	for _, building in biome.hub.buildings do
		if building.role == "Circuit" then
			ringId = building.id
		end
	end
	local ringAt = if ringId then map.buildings[ringId] else nil
	local ringFaces = if ringId then map.faces[ringId] else nil
	if ringAt and ringFaces then
		local centre = Vector3.new(ringAt.x, 0, ringAt.z)
		local ahead = Props.facing(ringFaces)
		local across = Vector3.new(-ahead.Z, 0, ahead.X)
		local halfAcross, halfAhead = dressing.ring.width / 2 + 1, dressing.ring.depth / 2 + 1
		local railStyle: WorldTypes.FenceStyle = dressing.ring.style or "Rustic"
		local rail: { Vector3 } = {}
		local count = 40
		for k = 0, count do
			local angle = k / count * math.pi * 2
			local at = centre
				+ across * math.sin(angle) * halfAcross
				+ ahead * math.cos(angle) * halfAhead
			-- The opening faces the keeper at the front.
			local front = (at - centre):Dot(ahead)
			local sideways = math.abs((at - centre):Dot(across))
			if front > 0 and sideways < dressing.ring.gap / 2 + 1 then
				if #rail > 1 then
					Fences.fence(town, rail, railStyle, waters)
				end
				rail = {}
			else
				table.insert(rail, at)
			end
		end
		if #rail > 1 then
			Fences.fence(town, rail, railStyle, waters)
		end
		for _, side in { -1, 1 } do
			local foot = centre + across * side * (halfAcross + 4)
			Props.bench(town, foot, -across * side)
		end
	end
end

return Yards
