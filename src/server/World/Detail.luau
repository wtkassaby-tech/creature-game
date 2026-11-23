--!strict
-- Builds the small ground detail of a designed biome from DetailPlan (src/shared): the scatter of
-- flowers, pebbles, shells and tufts on the lawns and verges, and the paving pattern on each
-- plaza. Everything is low and flat and costs next to nothing: no collision, no queries, no
-- shadows, a few dozen studs of clay at most. Runs before Elevate, so it lifts with the rest.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DetailConfig = require(ReplicatedStorage.config.DetailConfig)
local Biomes = require(ReplicatedStorage.content.Biomes)
local DustCanyonDressing = require(ReplicatedStorage.content.map_data.DustCanyonDressing)
local GreenwoodDressing = require(ReplicatedStorage.content.map_data.GreenwoodDressing)
local MireDressing = require(ReplicatedStorage.content.map_data.MireDressing)
local TideFlatsDressing = require(ReplicatedStorage.content.map_data.TideFlatsDressing)
local DetailPlan = require(ReplicatedStorage.shared.DetailPlan)
local EdgeTrace = require(ReplicatedStorage.shared.EdgeTrace)
local Ground = require(ReplicatedStorage.shared.Ground)
local GroundTone = require(ReplicatedStorage.shared.GroundTone)
local Layout = require(ReplicatedStorage.shared.Layout)
local Rng = require(ReplicatedStorage.shared.Rng)
local WorldTypes = require(ReplicatedStorage.shared.WorldTypes)

local Props = require(script.Parent.Props)

local Detail = {}

local function colourOf(values: { number }): Color3
	return Props.rgb(values[1], values[2], values[3])
end

-- Makes a part of the detail inert: it is only to be looked at.
local function inert(part: BasePart)
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
end

local function folderIn(parent: Instance, name: string): Folder
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent
	return folder
end

-- One scatter item: a small painted model, or a cluster of clay lumps.
local function stand(folder: Folder, item: DetailPlan.Item)
	local foot = Vector3.new(item.x, DetailConfig.FOOT, item.z)
	local colour = colourOf(item.colour)
	local pick = Random.new(item.seed)
	if item.shape == "Model" then
		local model = if item.model then Props.model(item.model) else nil
		if model then
			local facing = Vector3.new(math.sin(item.yaw), 0, -math.cos(item.yaw))
			inert(Props.stand(folder, model, foot, item.size, facing))
		else
			-- A stand-in lump when the painted model will not load.
			inert(
				Props.lump(
					folder,
					Vector3.new(item.size, item.size * 0.7, item.size),
					foot + Vector3.yAxis * item.size * 0.35,
					colour
				)
			)
		end
		return
	end
	for _ = 1, item.count do
		local spread = if item.count > 1 then 1.3 else 0
		local around = foot
			+ Vector3.new(pick:NextNumber(-spread, spread), 0, pick:NextNumber(-spread, spread))
		local size = item.size * pick:NextNumber(0.8, 1.2)
		local lump: Part
		if item.shape == "Blooms" then
			lump = Props.lump(
				folder,
				Vector3.one * size,
				around + Vector3.yAxis * (size * 0.5 + 0.3),
				colour
			)
		elseif item.shape == "Pebbles" then
			lump = Props.lump(
				folder,
				Vector3.new(size, size * 0.55, size * pick:NextNumber(0.7, 1)),
				around + Vector3.yAxis * size * 0.2,
				colour
			)
			lump.CFrame = CFrame.new(lump.Position)
				* CFrame.Angles(0, pick:NextNumber(0, math.pi * 2), 0)
		else
			lump = Props.lump(
				folder,
				Vector3.new(size, size * 0.3, size * 0.8),
				around + Vector3.yAxis * size * 0.1,
				colour
			)
			lump.CFrame = CFrame.new(lump.Position)
				* CFrame.Angles(0, pick:NextNumber(0, math.pi * 2), 0)
		end
		inert(lump)
	end
end

-- Soft patches of off-colour on the lawns and verges (GroundTone.blotches): two flat discs each,
-- the outer one fainter, so the edge fades into the ground. Few parts, all inert.
local function blotches(
	parent: Instance,
	biome: WorldTypes.Biome,
	map: Layout.Map,
	dressing: WorldTypes.DressingSheet,
	ground: Ground.Ground
): number
	local list = GroundTone.blotches(biome, map, dressing, ground)
	if #list == 0 then
		return 0
	end
	local folder = folderIn(parent, "Blotches")
	local thick = 0.06
	for index, blotch in list do
		local colour = colourOf(blotch.colour)
		local turn = CFrame.new(blotch.x, 0, blotch.z) * CFrame.Angles(0, blotch.yaw, 0)
		for layer = 1, 2 do
			local share = if layer == 1 then 1 else DetailConfig.BLOTCH_INNER_SHARE
			-- Each patch a hair above the last, so overlapping ones never fight.
			local top = DetailConfig.BLOTCH_TOP + index * 0.0005 + layer * 0.0002
			local disc = Props.part(
				folder,
				Vector3.new(thick, blotch.w * share, blotch.d * share),
				turn * CFrame.new(0, top - thick / 2, 0) * CFrame.Angles(0, 0, math.rad(90)),
				colour
			)
			disc.Shape = Enum.PartType.Cylinder
			disc.Transparency = if layer == 1
				then DetailConfig.BLOTCH_OUTER
				else DetailConfig.BLOTCH_INNER
			inert(disc)
		end
	end
	return #list * 2
end

-- The biome sheets, by biome id, for the neighbour across a seam.
local SHEETS: { [string]: WorldTypes.DressingSheet } = {
	greenwood = GreenwoodDressing,
	dust_canyon = DustCanyonDressing,
	tide_flats = TideFlatsDressing,
	mire = MireDressing,
}

-- A little scatter beside the seam, from one biome's own verge kinds, so the change of ground is
-- dotted with the plants of both. `side` is -1 on the west of the seam, 1 on the east.
local function seamScatter(
	folder: Folder,
	sheet: WorldTypes.DressingSheet,
	biome: WorldTypes.Biome,
	side: number,
	seamX: number,
	gate: Layout.Point,
	road: { Layout.Point }
)
	local scatter = sheet.scatter
	if scatter == nil then
		return
	end
	local rng = Rng.new(DetailConfig.SEED + biome.number * 977 + (if side < 0 then 1 else 2))
	local taken = 0
	for _, kind in scatter.kinds do
		if kind.zone ~= "Verge" or taken >= 2 then
			continue
		end
		taken += 1
		for _ = 1, DetailConfig.SEAM_ITEMS do
			local x = seamX + side * (2 + Rng.next(rng) * (DetailConfig.SEAM_WIDTH / 2 - 4))
			local z = gate.z + (Rng.next(rng) * 2 - 1) * DetailConfig.SEAM_REACH
			local _, off = EdgeTrace.nearest(road, x, z)
			-- Always roll the rest, so the same seed gives the same items whether or not one is kept.
			local size = kind.tall[1] + (kind.tall[2] - kind.tall[1]) * Rng.next(rng)
			local yaw = Rng.next(rng) * math.pi * 2
			local count = if kind.shape == "Model"
				then 1
				else Rng.int(rng, (kind.count or { 1, 1 })[1], (kind.count or { 1, 1 })[2])
			local colour = Rng.pick(rng, kind.colours)
			local seed = Rng.int(rng, 1, 2147483000)
			if off > DetailConfig.SEAM_ROAD_CLEAR then
				stand(folder, {
					kind = kind.id,
					shape = kind.shape,
					zone = kind.zone,
					model = kind.model,
					x = x,
					z = z,
					size = size,
					yaw = yaw,
					colour = colour,
					count = count,
					seed = seed,
				})
			end
		end
	end
end

-- The band of ground where this biome's slab meets the next biome's: a few wide flat strips graded
-- from this biome's field colour to the next one's, with a little scatter from each side. Not made
-- for the last biome, nor where the next one is sited elsewhere (the Mire).
local function seam(
	parent: Instance,
	biome: WorldTypes.Biome,
	map: Layout.Map,
	dressing: WorldTypes.DressingSheet
): number
	local gate = map.places[biome.gate.id]
	if gate == nil then
		return 0
	end
	local nextBiome: WorldTypes.Biome? = nil
	for _, other in Biomes do
		if other.number == biome.number + 1 then
			nextBiome = other
		end
	end
	local nextSheet = if nextBiome then SHEETS[nextBiome.id] else nil
	if nextBiome == nil or nextSheet == nil or nextBiome.site ~= nil then
		return 0
	end
	local seamX = gate.x + DetailConfig.SEAM_PAST_GATE
	local low, high = GroundTone.slabSpan(biome, map)
	local z0 = math.max(low, gate.z - DetailConfig.SEAM_HALF_LENGTH)
	local z1 = math.min(high, gate.z + DetailConfig.SEAM_HALF_LENGTH)
	local bands = GroundTone.seam(
		GroundTone.fieldColour(dressing),
		GroundTone.fieldColour(nextSheet),
		seamX,
		z0,
		z1
	)
	local folder = folderIn(parent, "Seam")
	local thick = 0.04
	for index, band in bands do
		local part = Props.part(
			folder,
			Vector3.new(band.w, thick, band.d),
			CFrame.new(band.x, DetailConfig.SEAM_TOP + index * 0.0004 - thick / 2, band.z),
			colourOf(band.colour)
		)
		inert(part)
	end
	-- The sealed road runs on from the gate; the scatter keeps off it.
	local road: { Layout.Point } = { gate }
	local sealed = map.places[biome.gate.sealedPath]
	if sealed then
		table.insert(road, sealed)
		table.insert(
			road,
			{ x = sealed.x + (sealed.x - gate.x), z = sealed.z + (sealed.z - gate.z) }
		)
	else
		table.insert(road, { x = gate.x + 100, z = gate.z })
	end
	seamScatter(folder, dressing, biome, -1, seamX, gate, road)
	seamScatter(folder, nextSheet, nextBiome, 1, seamX, gate, road)
	return #bands
end
-- Scatters a biome's lawns and verges. Returns how many parts it made.
function Detail.scatter(
	parent: Instance,
	biome: WorldTypes.Biome,
	map: Layout.Map,
	dressing: WorldTypes.DressingSheet,
	ground: Ground.Ground
): number
	local plan = DetailPlan.scatter(biome, map, dressing, ground)
	local folder = folderIn(parent, "Scatter")
	for _, item in plan.items do
		stand(folder, item)
	end
	local extra = blotches(folder, biome, map, dressing, ground)
	extra += seam(folder, biome, map, dressing)
	return plan.parts + extra
end

-- The colour of a plaza look, shaded by a fraction.
local function shaded(values: { number }, by: number): Color3
	return Props.rgb(
		math.clamp(math.floor(values[1] * by + 0.5), 0, 255),
		math.clamp(math.floor(values[2] * by + 0.5), 0, 255),
		math.clamp(math.floor(values[3] * by + 0.5), 0, 255)
	)
end

-- A flat board lying on the plaza: `w` along its own x, `d` across, turned `yaw`, at `top`.
local function board(
	folder: Folder,
	at: Vector3,
	w: number,
	d: number,
	yaw: number,
	top: number,
	colour: Color3
): Part
	local thick = 0.12
	local made = Props.part(
		folder,
		Vector3.new(w, thick, d),
		CFrame.new(at.X, top - thick / 2, at.Z) * CFrame.Angles(0, yaw, 0),
		colour
	)
	inert(made)
	return made
end

-- A plank deck: boards across the square, each a little longer or shorter than the next, with
-- piles at its corners (Saltwick's quay).
local function deck(
	folder: Folder,
	centre: Vector3,
	size: number,
	look: WorldTypes.PlazaLook,
	rng: Rng.Rng
): number
	local top = DetailConfig.DECK_TOP
	local long, across = size * 0.84, size * 0.62
	local count = math.floor(across / DetailConfig.DECK_PLANK)
	local made = 0
	for k = 1, count do
		local tone = DetailConfig.DECK_PLANKS_TONE[(k - 1) % #DetailConfig.DECK_PLANKS_TONE + 1]
		local shorter = 1 - Rng.next(rng) * 0.1
		local slide = (Rng.next(rng) * 2 - 1) * 1.4
		local z = (k - (count + 1) / 2) * DetailConfig.DECK_PLANK
		board(
			folder,
			centre + Vector3.new(slide, 0, z),
			long * shorter,
			DetailConfig.DECK_PLANK - 0.3,
			0,
			top + 0.002 * k,
			shaded(look.colour, tone)
		)
		made += 1
	end
	-- A kerb plank along each end, and a pile at each corner.
	for _, end_ in { -1, 1 } do
		board(
			folder,
			centre + Vector3.new(end_ * (long / 2 + 0.4), 0, 0),
			1.2,
			across,
			0,
			top + 0.03,
			colourOf(look.trim)
		)
		made += 1
		for _, side in { -1, 1 } do
			local post = Props.part(
				folder,
				Vector3.new(2.4, 1.1, 1.1),
				CFrame.new(centre + Vector3.new(end_ * (long / 2 + 0.4), 1.1, side * (across / 2)))
					* CFrame.Angles(0, 0, math.rad(90)),
				colourOf(look.trim)
			)
			post.Shape = Enum.PartType.Cylinder
			inert(post)
			made += 1
		end
	end
	return made
end

-- A flagstone yard: a grid of square slabs in two shades, walled low on every side but for an
-- opening in the middle of each (Kilnrest's kiln yard).
local function yard(
	folder: Folder,
	centre: Vector3,
	size: number,
	look: WorldTypes.PlazaLook,
	rng: Rng.Rng
): number
	local top = DetailConfig.DECK_TOP
	local slab = size * 0.8 / math.floor(size * 0.8 / DetailConfig.YARD_SLAB)
	local n = math.floor(size * 0.8 / DetailConfig.YARD_SLAB)
	local made = 0
	for ix = 1, n do
		for iz = 1, n do
			local tone = if (ix + iz) % 2 == 0 then 1 else 0.9
			tone *= 0.97 + Rng.next(rng) * 0.06
			board(
				folder,
				centre + Vector3.new((ix - (n + 1) / 2) * slab, 0, (iz - (n + 1) / 2) * slab),
				slab - 0.5,
				slab - 0.5,
				0,
				top,
				shaded(look.colour, tone)
			)
			made += 1
		end
	end
	local reach = n * slab / 2 + 0.8
	local gap = DetailConfig.YARD_GAP
	local run = reach - gap / 2
	for _, side in { -1, 1 } do
		for _, half in { -1, 1 } do
			-- Along z at the east and west, along x at the north and south: two pieces each.
			local offset = half * (gap / 2 + run / 2)
			for _, vertical in { true, false } do
				local at = if vertical
					then Vector3.new(side * reach, 0, offset)
					else Vector3.new(offset, 0, side * reach)
				local wall = Props.part(
					folder,
					Vector3.new(
						if vertical then 1.2 else run,
						DetailConfig.YARD_WALL,
						if vertical then run else 1.2
					),
					CFrame.new(centre + at + Vector3.yAxis * (top + DetailConfig.YARD_WALL / 2)),
					colourOf(look.trim)
				)
				inert(wall)
				made += 1
			end
		end
	end
	return made
end

-- Duckboards: runs of narrow boards laid end to end, each run a little off the one before, across
-- the square like a boardwalk's junction (Sedgeholm's Bell Square).
local function duckboards(
	folder: Folder,
	centre: Vector3,
	size: number,
	look: WorldTypes.PlazaLook,
	rng: Rng.Rng
): number
	local top = DetailConfig.DECK_TOP
	local made = 0
	for run = 1, DetailConfig.DUCK_BOARDS do
		local turn = if run % 2 == 0 then math.pi / 2 else 0
		local yaw = turn + (Rng.next(rng) * 2 - 1) * 0.22
		local spot = centre
			+ Vector3.new(
				(Rng.next(rng) * 2 - 1) * size * 0.2,
				0,
				(Rng.next(rng) * 2 - 1) * size * 0.2
			)
		local forward = Vector3.new(math.cos(yaw), 0, -math.sin(yaw))
		for k = -1, 1 do
			local length = 7 + Rng.next(rng) * 3
			board(
				folder,
				spot + forward * k * 8.2 + Vector3.new(0, 0, 0),
				length,
				2.6,
				yaw,
				top + 0.003 * run + 0.001 * (k + 2),
				shaded(look.colour, 0.88 + Rng.next(rng) * 0.2)
			)
			made += 1
		end
	end
	-- A few stakes at the edge, where the boards end.
	for _ = 1, 6 do
		local angle = Rng.next(rng) * math.pi * 2
		local at = centre + Vector3.new(math.cos(angle), 0, math.sin(angle)) * size * 0.42
		local stake = Props.part(
			folder,
			Vector3.new(2, 0.7, 0.7),
			CFrame.new(at + Vector3.yAxis * (top + 0.8)) * CFrame.Angles(0, 0, math.rad(90)),
			colourOf(look.trim)
		)
		stake.Shape = Enum.PartType.Cylinder
		inert(stake)
		made += 1
	end
	return made
end
-- Lays the plaza's paving pattern, flower beds and centre motif on its flat top.
function Detail.plaza(
	parent: Instance,
	biome: WorldTypes.Biome,
	map: Layout.Map,
	dressing: WorldTypes.DressingSheet,
	ground: Ground.Ground
): number
	local folder = folderIn(parent, "PlazaDetail")
	local top = DetailConfig.PLAZA_TOP
	local discs = 0
	local pieces = DetailPlan.plaza(biome, map, dressing, ground)
	for _, piece in pieces do
		local colour = colourOf(piece.colour)
		-- A plaza with its own look (deck, yard, duckboards) lays that over the paving: the ring of
		-- stones and the motif would only show through it, so they are left out.
		local laid = dressing.plaza.look ~= nil
		if piece.kind == "Disc" then
			if laid then
				continue
			end
			discs += 1
			local disc = Props.disc(
				folder,
				Vector3.new(piece.x, 0, piece.z),
				piece.w,
				0.1,
				top + 0.02 * discs,
				colour
			)
			inert(disc)
		elseif piece.kind == "Stone" then
			if laid then
				continue
			end
			local stone = Props.part(
				folder,
				Vector3.new(piece.w, DetailConfig.STONE_THICK, piece.d),
				CFrame.new(piece.x, top + 0.07, piece.z) * CFrame.Angles(0, piece.yaw, 0),
				colour
			)
			inert(stone)
		elseif piece.kind == "Bed" then
			inert(
				Props.lump(
					folder,
					Vector3.new(piece.w, 1.2, piece.w),
					Vector3.new(piece.x, top + 0.45, piece.z),
					colour
				)
			)
		else
			inert(
				Props.lump(
					folder,
					Vector3.one * piece.w,
					Vector3.new(piece.x, top + 0.95, piece.z),
					colour
				)
			)
		end
	end
	local extra = 0
	local look = dressing.plaza.look
	if look then
		local centre =
			Vector3.new(map.hub.x + dressing.plaza.at.x, 0, map.hub.z + dressing.plaza.at.z)
		local rng = Rng.new(DetailConfig.SEED + biome.number * 53)
		local size = dressing.plaza.size
		if look.kind == "Deck" then
			extra = deck(folder, centre, size, look, rng)
		elseif look.kind == "Yard" then
			extra = yard(folder, centre, size, look, rng)
		else
			extra = duckboards(folder, centre, size, look, rng)
		end
	end
	return #pieces + extra
end

return Detail
