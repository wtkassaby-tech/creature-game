--!strict
-- Works out, from a biome's dressing sheet, every ambient effect it asks for: chimney smoke,
-- lamp halos, hand-placed sources and the glints on water. Pure: no Roblox services, so the
-- builder (src/server/World/Ambience) and the budget test (tests/ambience.test) read the same
-- list. Positions are studs from the hub's centre, like the sheet; y is above the ground.

local AmbienceConfig = require("../config/AmbienceConfig")
local WorldTypes = require("./WorldTypes")

export type Spec = {
	kind: string, -- a key of AmbienceConfig.KINDS
	label: string, -- what it belongs to, for a name in the workspace
	x: number,
	y: number,
	z: number,
	width: number, -- the volume the particles come from; 0 across is a point
	depth: number,
	thick: number,
	rate: number, -- 0: a light only, no emitter
	scale: number,
	light: WorldTypes.AmbienceLight?,
}

export type Totals = { emitters: number, rate: number, live: number, lights: number }

local AmbiencePlan = {}

local function newSpec(kind: string, label: string, x: number, y: number, z: number): Spec
	local look = AmbienceConfig.KINDS[kind]
	return {
		kind = kind,
		label = label,
		x = x,
		y = y,
		z = z,
		width = 0,
		depth = 0,
		thick = 0,
		rate = if look then look.rate else 0,
		scale = 1,
		light = nil,
	}
end

-- Where a house's chimney stands: its middle plus the offset fractions, turned to its facing.
local function chimney(house: WorldTypes.DressHouse, offset: WorldTypes.ChimneyOffset): Spec
	local angle = math.rad(house.faces)
	local rightX, rightZ = math.cos(angle), math.sin(angle) -- to the right of the facing
	local backX, backZ = -math.sin(angle), math.cos(angle) -- behind it
	local across, up, back = offset[1], offset[2], offset[3]
	local spec = newSpec(
		"Smoke",
		`Chimney {house.model}`,
		house.at.x + rightX * across * house.width + backX * back * house.depth,
		house.tall * up + AmbienceConfig.CHIMNEY_SMOKE_HEIGHT_GAP,
		house.at.z + rightZ * across * house.width + backZ * back * house.depth
	)
	return spec
end

-- The part of a flat's [low, high] span, `size` long, that lies nearest zero.
local function nearZero(low: number, high: number, size: number): (number, number)
	local length = math.min(size, high - low)
	local start = math.clamp(-length / 2, low, high - length)
	return start, start + length
end

local function glint(
	label: string,
	x: number,
	z: number,
	width: number,
	depth: number,
	rate: number
): Spec
	local spec = newSpec("Glint", label, x, AmbienceConfig.GLINT_HEIGHT, z)
	spec.width, spec.depth, spec.thick = width, depth, 0.4
	spec.rate = rate
	return spec
end

-- Every effect a dressing sheet asks for; empty if it declares no ambience.
function AmbiencePlan.plan(dressing: WorldTypes.DressingSheet): { Spec }
	local specs: { Spec } = {}
	local ambience = dressing.ambience
	if not ambience then
		return specs
	end

	local chimneys = ambience.chimneys
	if chimneys then
		local houses: { WorldTypes.DressHouse } = {}
		for _, house in dressing.houses do
			table.insert(houses, house)
		end
		local hub: { WorldTypes.DressHouse } = ambience.smokeHouses or {}
		for _, house in hub do
			table.insert(houses, house)
		end
		for _, house in houses do
			local offset = chimneys[house.model]
			if offset then
				table.insert(specs, chimney(house, offset))
			end
		end
	end

	local lamps = ambience.lamps
	if lamps then
		for _, at in dressing.lamps do
			local spec = newSpec("Halo", "Lamp", at.x, AmbienceConfig.LAMP_HEIGHT, at.z)
			spec.light = lamps
			table.insert(specs, spec)
		end
	end

	for _, source in ambience.sources do
		local spec = newSpec(
			source.kind,
			`Source {source.kind}`,
			source.at.x,
			source.height or 0,
			source.at.z
		)
		local area = source.area
		if area then
			spec.width, spec.depth, spec.thick = area[1], area[2], area[3] or 2
		end
		spec.rate = source.rate or spec.rate
		spec.scale = source.scale or 1
		spec.light = source.light
		table.insert(specs, spec)
	end

	if ambience.glints then
		local zone = AmbienceConfig.GLINT_MAX_ZONE
		local flats: { WorldTypes.DressFlat } = dressing.flats or {}
		for _, flat in flats do
			if flat.water then
				local x0, x1 = nearZero(
					math.min(flat.from.x, flat.to.x),
					math.max(flat.from.x, flat.to.x),
					zone
				)
				local z0, z1 = nearZero(
					math.min(flat.from.z, flat.to.z),
					math.max(flat.from.z, flat.to.z),
					zone
				)
				local rate = math.clamp(
					(x1 - x0) * (z1 - z0) / AmbienceConfig.GLINT_AREA,
					AmbienceConfig.GLINT_MIN_RATE,
					AmbienceConfig.GLINT_MAX_RATE
				)
				table.insert(
					specs,
					glint("Water", (x0 + x1) / 2, (z0 + z1) / 2, x1 - x0, z1 - z0, rate)
				)
			end
		end
		for _, pool in dressing.pools do
			local size = pool.radius * 1.6
			table.insert(
				specs,
				glint("Pool", pool.at.x, pool.at.z, size, size, AmbienceConfig.GLINT_POOL_RATE)
			)
		end
		local pond = dressing.pond
		if pond then
			local size = pond.radius * 1.6
			table.insert(
				specs,
				glint(
					"Pond",
					pond.at.x,
					pond.at.z,
					size,
					size,
					AmbienceConfig.GLINT_POOL_RATE * 1.5
				)
			)
		end
	end
	return specs
end

-- What a plan costs a phone: how many emitters and lights, their combined rate, and how many
-- particles are alive at once (rate times a mean lifetime).
function AmbiencePlan.totals(specs: { Spec }): Totals
	local totals: Totals = { emitters = 0, rate = 0, live = 0, lights = 0 }
	for _, spec in specs do
		if spec.rate > 0 then
			local look = AmbienceConfig.KINDS[spec.kind]
			local life = if look then (look.lifetime[1] + look.lifetime[2]) / 2 else 0
			totals.emitters += 1
			totals.rate += spec.rate
			totals.live += spec.rate * life
		end
		if spec.light then
			totals.lights += 1
		end
	end
	return totals
end

return AmbiencePlan
