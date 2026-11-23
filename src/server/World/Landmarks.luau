--!strict
-- The one-off pieces of a dressing sheet out on the routes: the mossy knoll, the picnic hollow,
-- Birch Rise's side pocket, the gatehouse hamlet, the gatehouse and the sealed-road bar, the
-- ancient tree over the lair, a far landmark (docs/plans/09_DUST_CANYON_MAP.md section 4c) and
-- the brambles across the shut shortcut (docs/plans/08_GREENWOOD_MAP.md section 3, "Route
-- dressing"). A piece the sheet leaves out is not built. Looks only, except where a piece must
-- block the way (the gatehouse towers, the hamlet's walls, the brambles, the landmark's core).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Layout = require(ReplicatedStorage.shared.Layout)
local WorldTypes = require(ReplicatedStorage.shared.WorldTypes)

local Props = require(script.Parent.Props)
local Shapes = require(script.Parent.Shapes)
local Skyline = require(script.Parent.Skyline)

local Landmarks = {}

local TIMBER = Props.rgb(120, 84, 56)

local function placed(map: Layout.Map, point: WorldTypes.SheetPoint): Vector3
	return Vector3.new(map.hub.x + point.x, 0, map.hub.z + point.z)
end

-- The ancient tree over Greenwood's lair: the painted AncientTree on an unseen trunk, or a
-- great stem under two crowns.
local function ancient(town: Instance, foot: Vector3, tall: number, model: string?)
	local trunk = Props.part(
		town,
		Vector3.new(14, 40, 14),
		CFrame.new(foot + Vector3.yAxis * 20),
		Props.rgb(110, 80, 56)
	)
	trunk.Name = "AncientTrunk"
	trunk.CanCollide = true
	local giantTree = Props.model(model or "AncientTree")
	if giantTree then
		trunk.Transparency = 1
		Props.stand(town, giantTree, foot, tall, Vector3.new(0, 0, 1))
		return
	end
	local stem = Props.part(
		town,
		Vector3.new(tall * 0.6, 16, 16),
		CFrame.new(foot + Vector3.yAxis * tall * 0.3) * CFrame.Angles(0, 0, math.rad(90)),
		Props.rgb(110, 80, 56)
	)
	stem.Shape = Enum.PartType.Cylinder
	Props.lump(
		town,
		Vector3.new(tall * 0.7, tall * 0.45, tall * 0.7),
		foot + Vector3.yAxis * tall * 0.72,
		Props.rgb(60, 120, 60)
	)
	Props.lump(
		town,
		Vector3.new(tall * 0.35, tall * 0.25, tall * 0.35),
		foot + Vector3.new(tall * 0.15, tall * 0.9, 0),
		Props.rgb(200, 180, 70)
	)
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
	if dressing.knoll then
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
	end
	if dressing.picnic then
		Props.bench(town, placed(map, dressing.picnic.at), Vector3.zAxis)
	end
	if dressing.pocket then
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
		elseif
			Shapes.building(
				town,
				cottage.model,
				CFrame.lookAt(foot, foot + facing),
				cottage.width,
				cottage.depth,
				cottage.tall
			)
		then
			wall.Transparency = 1 -- an adobe house or kiln cottage of plain shapes
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
	-- (A canyon's boulders and spires have plain stand-ins; a missing cart or line is left out.)
	for _, thing in dressing.props do
		local made = Shapes.prop(
			town,
			thing.model,
			placed(map, thing.at),
			thing.tall,
			Props.facing(thing.faces)
		)
		local pieces: { BasePart } = made or {}
		for _, piece in pieces do
			piece.CanCollide = thing.solid == true
		end
	end

	-- The gatehouse: the painted gatehouse (Gatehouse, or the sheet's own) with the road through
	-- its arch, or two towers under a beam with a timber room and a banner. The towers always
	-- stand, invisible under the model, so the edge across the route's end has no hole beside
	-- the arch.
	local gatehouse = dressing.gatehouse
	local gate = placed(map, gatehouse.at)
	local gateFacing = Props.facing(gatehouse.faces)
	local gateAcross = Vector3.new(-gateFacing.Z, 0, gateFacing.X)
	local gateFrame = CFrame.lookAt(gate, gate + gateFacing)
	local gateModel = gatehouse.model or "Gatehouse"
	local painted = Props.model(gateModel)
	-- Grey stone for Greenwood's gatehouse; sandstone for the canyon's Stair Gate.
	local gateStone = if gateModel == "StairGate"
		then Props.rgb(214, 160, 110)
		else Props.rgb(170, 165, 150)
	for _, side in { -1, 1 } do
		local tower = Props.part(
			town,
			Vector3.new(12, 30, 12),
			CFrame.new(gate + gateAcross * 13 * side + Vector3.yAxis * 15),
			gateStone
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
		Props.part(town, Vector3.new(40, 8, 12), gateFrame * CFrame.new(0, 26, 0), gateStone)
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
		Props.text(banner, Enum.NormalId.Front, gatehouse.banner or "Acorn Badge")
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
	local ancientTree = dressing.ancientTree
	if ancientTree then
		ancient(town, placed(map, ancientTree.at), ancientTree.tall, ancientTree.model)
	end

	-- The far landmark (the Redstack, the Old Light): its painted model or plain stand-in, on an
	-- unseen core of 0.6 times its footprint, its face turned as the sheet says.
	local landmark = dressing.landmark
	if landmark then
		local foot = placed(map, landmark.at)
		local facing = Props.facing(landmark.faces)
		local model = Props.model(landmark.model)
		local footprint: Vector2
		if model then
			local stood = Props.stand(town, model, foot, landmark.tall, facing)
			footprint = Vector2.new(stood.Size.X, stood.Size.Z)
		else
			footprint = Skyline.landmark(town, landmark.model, foot, landmark.tall, facing)
		end
		local core = Props.part(
			town,
			Vector3.new(footprint.X * 0.6, landmark.tall, footprint.Y * 0.6),
			CFrame.lookAt(foot, foot + facing) * CFrame.new(0, landmark.tall / 2, 0),
			Props.rgb(170, 150, 130)
		)
		core.Name = "Landmark"
		core.Transparency = 1
		core.CanCollide = true
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
