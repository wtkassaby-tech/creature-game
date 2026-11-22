--!strict
-- The one-off pieces of a dressing sheet out on the routes: the mossy knoll, the picnic hollow,
-- Birch Rise's side pocket, the gatehouse hamlet, the gatehouse and the sealed-road bar, the
-- ancient tree over the lair and the brambles across the shut shortcut
-- (docs/plans/08_GREENWOOD_MAP.md section 3, "Route dressing"). Looks only, except where a
-- piece must block the way (the gatehouse towers, the hamlet's walls, the brambles).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Layout = require(ReplicatedStorage.shared.Layout)
local WorldTypes = require(ReplicatedStorage.shared.WorldTypes)

local Props = require(script.Parent.Props)

local Landmarks = {}

local TIMBER = Props.rgb(120, 84, 56)

local function placed(map: Layout.Map, point: WorldTypes.SheetPoint): Vector3
	return Vector3.new(map.hub.x + point.x, 0, map.hub.z + point.z)
end

function Landmarks.build(parent: Instance, map: Layout.Map, dressing: WorldTypes.DressingSheet)
	local town = Instance.new("Folder")
	town.Name = "Landmarks"
	town.Parent = parent
	-- The shut shortcut is the last of the sheet's lanes.
	local shortcut = dressing.lanes[#dressing.lanes]
	local streets: { { Vector3 } } = {}
	if shortcut then
		local points: { Vector3 } = {}
		for _, point in shortcut.points do
			table.insert(points, placed(map, point))
		end
		table.insert(streets, points)
	end

	-- Route dressing: the mossy knoll, the picnic hollow's bench and the side pocket's logs.
	local knoll = placed(map, dressing.knoll.at)
	local size = dressing.knoll.size
	Props.lump(town, Vector3.new(size[1], size[2] * 2, size[3]), knoll, Props.rgb(110, 168, 86))
	local solid = Props.part(
		town,
		Vector3.new(size[1] * 0.6, size[2] * 0.8, size[3] * 0.6),
		CFrame.new(knoll + Vector3.yAxis * size[2] * 0.4),
		Props.rgb(110, 168, 86)
	)
	solid.Transparency = 1
	solid.CanCollide = true
	solid.Name = "Knoll"
	Props.bench(town, placed(map, dressing.picnic.at), Vector3.zAxis)
	local pocket = placed(map, dressing.pocket.at)
	for k = 1, 3 do
		local turn = k * 2.1
		local at = pocket + Vector3.new(math.cos(turn), 0, math.sin(turn)) * 8
		local log = Props.part(
			town,
			Vector3.new(1.6, 1.6, 6),
			CFrame.lookAt(
				at + Vector3.yAxis * 0.8,
				at + Vector3.yAxis * 0.8 + Vector3.new(math.sin(turn), 0, math.cos(turn))
			),
			TIMBER
		)
		log.Name = "Log"
	end

	-- The gatehouse hamlet's cottages.
	for _, cottage in dressing.houses do
		local foot = placed(map, cottage.at)
		local facing = Props.facing(cottage.faces)
		local wall = Props.part(
			town,
			Vector3.new(cottage.width, 18, cottage.depth),
			CFrame.lookAt(foot + Vector3.yAxis * 9, foot + Vector3.yAxis * 9 + facing),
			Props.rgb(244, 232, 208)
		)
		wall.Name = "HamletCottage" -- every keeperless cottage, in the hamlet or in town
		wall.CanCollide = true
		local painted = Props.model(cottage.model)
		if painted then
			wall.Transparency = 1
			Props.stand(town, painted, foot, cottage.tall, facing)
		else
			Props.part(
				town,
				Vector3.new(cottage.width + 2, 6, cottage.depth + 2),
				wall.CFrame * CFrame.new(0, 12, 0),
				Props.rgb(206, 88, 72)
			)
		end
	end

	-- Homely things standing about: a cart, washing lines, barrels, the orchard's apple trees.
	for _, thing in dressing.props do
		local painted = Props.model(thing.model)
		if painted then
			local stood = Props.stand(
				town,
				painted,
				placed(map, thing.at),
				thing.tall,
				Props.facing(thing.faces)
			)
			stood.CanCollide = thing.solid == true
		end
	end

	-- The gatehouse: the painted Gatehouse with the road through its arch, or two stone towers
	-- under a beam with a timber room and a red banner. The towers always stand, invisible
	-- under the model, so the hedge across the route's end has no hole beside the arch.
	local gate = placed(map, dressing.gatehouse.at)
	local gateFacing = Props.facing(dressing.gatehouse.faces)
	local gateAcross = Vector3.new(-gateFacing.Z, 0, gateFacing.X)
	local gateFrame = CFrame.lookAt(gate, gate + gateFacing)
	local painted = Props.model("Gatehouse")
	for _, side in { -1, 1 } do
		local tower = Props.part(
			town,
			Vector3.new(12, 30, 12),
			CFrame.new(gate + gateAcross * 13 * side + Vector3.yAxis * 15),
			Props.rgb(170, 165, 150)
		)
		tower.Name = "GatehouseTower"
		tower.CanCollide = true
		if painted then
			tower.Transparency = 1
		end
	end
	if painted then
		-- Its arch runs front to back, so facing along the road lets the road through.
		Props.stand(town, painted, gate, 30, gateFacing)
	else
		Props.part(
			town,
			Vector3.new(40, 8, 12),
			gateFrame * CFrame.new(0, 26, 0),
			Props.rgb(170, 165, 150)
		)
		Props.part(
			town,
			Vector3.new(30, 8, 10),
			gateFrame * CFrame.new(0, 34, 0),
			Props.rgb(200, 150, 90)
		)
		local banner = Props.part(
			town,
			Vector3.new(6, 12, 0.3),
			gateFrame * CFrame.new(0, 21, -6.3),
			Props.rgb(206, 88, 72)
		)
		Props.text(banner, Enum.NormalId.Front, "Acorn Badge")
	end

	-- The bar across the sealed road: posts either side and a striped pole. The pole is only
	-- looks; the server already refuses biome 2 until the badge, and a solid bar would stop a
	-- player who has earned it.
	local bar = placed(map, dressing.bar.at)
	for _, side in { -1, 1 } do
		local post = Props.part(
			town,
			Vector3.new(1.2, 5, 1.2),
			CFrame.new(bar + gateAcross * side * dressing.bar.width / 2 + Vector3.yAxis * 2.5),
			TIMBER
		)
		post.CanCollide = true
	end
	for k = 0, 4 do
		local t = (k + 0.5) / 5 - 0.5
		Props.part(
			town,
			Vector3.new(0.8, 0.8, dressing.bar.width / 5),
			CFrame.lookAt(
				bar + gateAcross * t * dressing.bar.width + Vector3.yAxis * 3.6,
				bar + gateAcross * (t + 1) * dressing.bar.width + Vector3.yAxis * 3.6
			),
			if k % 2 == 0 then Props.rgb(206, 88, 72) else Props.rgb(244, 236, 220)
		).Name =
			"SealedBar"
	end

	-- The ancient tree over the lair: seen from town and from the meadow.
	local ancient = placed(map, dressing.ancientTree.at)
	local tall = dressing.ancientTree.tall
	local trunk = Props.part(
		town,
		Vector3.new(14, 40, 14),
		CFrame.new(ancient + Vector3.yAxis * 20),
		Props.rgb(110, 80, 56)
	)
	trunk.Name = "AncientTrunk"
	trunk.CanCollide = true
	local giantTree = Props.model("AncientTree")
	if giantTree then
		trunk.Transparency = 1
		Props.stand(town, giantTree, ancient, tall, Vector3.new(0, 0, 1))
	else
		local stem = Props.part(
			town,
			Vector3.new(tall * 0.6, 16, 16),
			CFrame.new(ancient + Vector3.yAxis * tall * 0.3) * CFrame.Angles(0, 0, math.rad(90)),
			Props.rgb(110, 80, 56)
		)
		stem.Shape = Enum.PartType.Cylinder
		Props.lump(
			town,
			Vector3.new(tall * 0.7, tall * 0.45, tall * 0.7),
			ancient + Vector3.yAxis * tall * 0.72,
			Props.rgb(60, 120, 60)
		)
		Props.lump(
			town,
			Vector3.new(tall * 0.35, tall * 0.25, tall * 0.35),
			ancient + Vector3.new(tall * 0.15, tall * 0.9, 0),
			Props.rgb(200, 180, 70)
		)
	end

	-- Brambles across the shut shortcut: a thorny hedge with red berries.
	for _, at in dressing.brambles do
		local foot = placed(map, at)
		local path = streets[#streets]
		local run = if path and #path >= 2 then (path[#path] - path[1]).Unit else Vector3.xAxis
		local across = Vector3.new(-run.Z, 0, run.X)
		local thicket = Props.part(
			town,
			Vector3.new(16, 5, 4),
			CFrame.lookAt(foot + Vector3.yAxis * 2.5, foot + Vector3.yAxis * 2.5 + run),
			Props.rgb(60, 96, 50)
		)
		thicket.Name = "Brambles"
		thicket.CanCollide = true
		for k = -3, 3 do
			Props.lump(
				town,
				Vector3.new(3.4, 3, 3.4),
				foot + across * k * 2.2 + Vector3.yAxis * 4.6,
				Props.rgb(66, 104, 54)
			)
			Props.lump(
				town,
				Vector3.one * 0.7,
				foot + across * k * 2.2 + Vector3.new(0.6, 5.8, 0.4),
				Props.rgb(180, 40, 60)
			)
		end
	end
end

return Landmarks
