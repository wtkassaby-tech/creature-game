--!strict
-- The coloured ground of a designed biome's corridors (docs/plans/08_GREENWOOD_MAP.md section 3):
-- each stretch's whole corridor, and bands beside a route (Greenwood's sand strip). Split from
-- Corridors.luau, which builds the corridors' edges. Looks only.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Ground = require(ReplicatedStorage.shared.Ground)
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
	dressing: WorldTypes.DressingSheet,
	ground: Ground.Ground
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
		-- A lane with narrow keys is painted as wide as it is at each step; the stretch is
		-- painted lane by lane, and never over the stairs or ramps (they have their own surface).
		local keys = if patch.area and line then line.widths else nil
		-- Over a sheet's flats (the sea, a gorge floor) the corridors' ground is painted on top.
		local flats = dressing.flats
		local top = (if flats and #flats > 0 then 0.07 else 0.03) + layer * 0.012
		local colour = Props.colour(patch.colour)
		local previous: Vector3? = nil
		local lastWidth = band
		local along = from
		while along <= to do
			local at = flat(Layout.pointAt(line, along, middle))
			local here = if keys then Layout.halfWidthAt(keys, along, band / 2) * 2 else band
			local overLink = keys ~= nil and Ground.linkAt(ground, at.X, at.Z, 2) ~= nil
			-- Stay out of the town: its own green is its ground.
			local half = map.hub.size / 2
			local dx = math.max(math.abs(at.X - map.hub.x) - half, 0)
			local dz = math.max(math.abs(at.Z - map.hub.z) - half, 0)
			if math.sqrt(dx * dx + dz * dz) >= here / 2 and not overLink then
				Props.disc(folder, at, here, 0.1, top, colour)
				if previous then
					Props.strip(folder, previous, at, math.min(here, lastWidth), 0.1, top, colour)
				end
				previous = at
				lastWidth = here
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
