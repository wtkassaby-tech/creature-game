--!strict
-- The coloured ground of a designed biome's corridors (docs/plans/08_GREENWOOD_MAP.md section 3):
-- each stretch's whole corridor, and bands beside a route (Greenwood's sand strip). Split from
-- Corridors.luau, which builds the corridors' edges. Looks only.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Layout = require(ReplicatedStorage.shared.Layout)
local WorldTypes = require(ReplicatedStorage.shared.WorldTypes)

local Props = require(script.Parent.Props)

local CorridorGround = {}

local function flat(point: Layout.Point): Vector3
	return Vector3.new(point.x, 0, point.z)
end

-- The coloured ground of each stretch (its whole corridor) and of bands beside a route (the
-- sand strip), as slabs with a disc at each step, each layer a hair above the last.
function CorridorGround.build(
	parent: Instance,
	biome: WorldTypes.Biome,
	map: Layout.Map,
	dressing: WorldTypes.DressingSheet
)
	local folder = Instance.new("Folder")
	folder.Name = "GroundPatches"
	folder.Parent = parent
	for layer, patch in dressing.ground do
		local line: Layout.RouteLine? = nil
		local from, to, near, far = patch.from or 0, patch.to or 0, patch.near or 0, patch.far or 0
		for _, route in biome.routes do
			for _, area in route.areas do
				if area.id == patch.area then
					local routeLine = map.routes[route.id]
					local width = if routeLine and routeLine.halfWidth
						then routeLine.halfWidth[area.id]
						else nil
					line = routeLine
					from, to = area.from, area.to
					near, far = -(width or 40), width or 40
				end
			end
			if patch.route == route.id then
				line = map.routes[route.id]
			end
		end
		if line == nil then
			continue
		end
		local band = far - near
		local middle = (near + far) / 2
		-- Over a sheet's flats (the sea, a gorge floor) the corridors' ground is painted on top.
		local flats = dressing.flats
		local top = (if flats and #flats > 0 then 0.07 else 0.03) + layer * 0.012
		local colour = Props.colour(patch.colour)
		local previous: Vector3? = nil
		local along = from
		while along <= to do
			local at = flat(Layout.pointAt(line, along, middle))
			-- Stay out of the town: its own green is its ground.
			local half = map.hub.size / 2
			local dx = math.max(math.abs(at.X - map.hub.x) - half, 0)
			local dz = math.max(math.abs(at.Z - map.hub.z) - half, 0)
			if math.sqrt(dx * dx + dz * dz) >= band / 2 then
				Props.disc(folder, at, band, 0.1, top, colour)
				if previous then
					Props.strip(folder, previous, at, band, 0.1, top, colour)
				end
				previous = at
			else
				previous = nil
			end
			if along >= to then
				break
			end
			along = math.min(along + 10, to)
		end
	end
end

return CorridorGround
