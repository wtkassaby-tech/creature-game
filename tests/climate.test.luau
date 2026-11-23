--!strict
-- Checks on the world's regions, climate zones, presets and blend maths (docs/plans/13_WORLD_DESIGN.md
-- sections 5, 9 and 11, build steps 1 and 2). Run from the project folder:  lune run tests/climate.test

local Biomes = require("../src/content/Biomes")
local ClimateBlend = require("../src/shared/ClimateBlend")
local ClimateConfig = require("../src/config/ClimateConfig")
local Layout = require("../src/shared/Layout")
local Regions = require("../src/shared/Regions")
local Tamers = require("../src/content/Tamers")
local World = require("../src/content/World")
local WorldTypes = require("../src/shared/WorldTypes")

local passed, failed = 0, 0
local function check(name: string, condition: boolean, detail: string?)
	if condition then
		passed += 1
	else
		failed += 1
	end
	print(
		`  {if condition then "PASS" else "FAIL"}  {name}{if detail
			then "  (" .. detail .. ")"
			else ""}`
	)
end

local function near(a: number, b: number, eps: number?): boolean
	return math.abs(a - b) <= (eps or 1e-6)
end

local ordered: { WorldTypes.Biome } = {}
for _, biome in Biomes do
	table.insert(ordered, biome)
end
table.sort(ordered, function(a, b)
	return a.number < b.number
end)
local world = Layout.world(ordered, Tamers.locals)

print("Shapes")
local disc: WorldTypes.Shape = { kind = "Disc", at = { x = 10, z = 10 }, r = 5 }
local box: WorldTypes.Shape = { kind = "Box", at = { x = 0, z = 0 }, size = { 20, 10 } }
local strip: WorldTypes.Shape =
	{ kind = "Strip", from = { x = 0, z = 0 }, to = { x = 10, z = 0 }, r = 2 }
check("a disc holds its middle", Regions.distance(disc, { x = 10, z = 10 }) == 0)
check(
	"a point 8 outside a disc's edge is 8 away",
	near(Regions.distance(disc, { x = 23, z = 10 }), 8)
)
check(
	"a box holds its corner and not past it",
	Regions.contains(box, { x = 10, z = 5 }) and not Regions.contains(box, { x = 10.1, z = 0 })
)
check("a box's corner distance is diagonal", near(Regions.distance(box, { x = 13, z = 9 }), 5))
check(
	"a strip is a segment widened by r",
	near(Regions.distance(strip, { x = 5, z = 7 }), 5)
		and near(Regions.distance(strip, { x = 14, z = 0 }), 2)
)

print("Weights")
local function zone(
	id: string,
	shape: WorldTypes.Shape,
	band: number,
	priority: number?
): WorldTypes.ClimateZone
	return { id = id, preset = id, shape = shape, band = band, priority = priority }
end
local left = zone("left", { kind = "Box", at = { x = -500, z = 0 }, size = { 1000, 1000 } }, 100)
local right = zone("right", { kind = "Box", at = { x = 500, z = 0 }, size = { 1000, 1000 } }, 100)
local atBorder = Regions.weights({ left, right }, { x = 0, z = 0 })
check("the border is an even split", near(atBorder.left, 0.5) and near(atBorder.right, 0.5))
local inside = Regions.weights({ left, right }, { x = -300, z = 0 })
check("deep in a zone it takes everything", near(inside.left, 1) and inside.right == nil)
local gap = Regions.weights({
	zone("a", { kind = "Disc", at = { x = 0, z = 0 }, r = 10 }, 50),
	zone("b", { kind = "Disc", at = { x = 1000, z = 0 }, r = 10 }, 50),
}, { x = 400, z = 0 })
check("where no zone reaches, the nearest one takes it", near(gap.a or 0, 1))
local cave = zone("cave", { kind = "Disc", at = { x = -300, z = 0 }, r = 50 }, 100, 5)
local scaled = Regions.weights({ left, right, cave }, { x = -300, z = 0 })
check(
	"a zone of higher priority scales the others down",
	near(scaled.cave, 1) and scaled.left == nil
)
local half = Regions.weights({ left, cave }, { x = -300 + 50 + 50, z = 0 })
local sum = 0
for _, w in half do
	sum += w
end
check("the weights always sum to 1", near(sum, 1))

print("The launch three")
local zones = World.zones
check(
	"each launch biome has a zone with its own id as the preset",
	#zones == 4 -- the three biomes, and Starfall Crater beside Dust Canyon's broken bridge
		and ClimateConfig.PRESETS.greenwood ~= nil
		and ClimateConfig.PRESETS.dust_canyon ~= nil
		and ClimateConfig.PRESETS.tide_flats ~= nil
)
local hubIds: { string } = { "greenwood_hub", "dust_canyon_hub", "tide_flats_hub" }
local hubsOk = true
for number, hubId in hubIds do
	local place = world.map.places[hubId]
	hubsOk = hubsOk and Layout.biomeAt(world, place) == number
	hubsOk = hubsOk and Regions.dominant(Regions.presetWeights(zones, place)) == ordered[number].id
end
check("each hub is in its own biome and its own zone", hubsOk)
do
	local crater
	for _, each in zones do
		if each.id == "starfall_crater" then
			crater = each
		end
	end
	local bridgeEnd = { x = 1104.6, z = -625.4 }
	local there = Regions.presetWeights(zones, bridgeEnd)
	local gate = Regions.presetWeights(zones, world.map.places[ordered[2].hub.id])
	check(
		"Starfall Crater lightly tints the light at the broken bridge, and not at all in the town",
		crater ~= nil
			and crater.preset == "starfall"
			and (there.starfall or 0) > 0.15
			and (there.starfall or 0) < 0.5
			and (gate.starfall or 0) == 0
	)
end
check(
	"the hubs have not moved",
	near(world.maps[1].hub.x, 0, 1)
		and near(world.maps[2].hub.x, 984.4, 1)
		and near(world.maps[3].hub.x, 2063.4, 1)
)
check("the world has a region for each biome", #world.regions == 3)
local gateOk = true
for _, biome in ordered do
	gateOk = gateOk and Layout.biomeAt(world, world.map.places[biome.gate.id]) == biome.number
end
check("every gate is still in its own biome", gateOk)

print("Passages")
check("both launch passages are listed", #World.passages == 2)
local passagesOk, swapOk = true, true
for _, passage in World.passages do
	local from, to = ordered[passage.from], ordered[passage.to]
	local gate = world.map.places[from.gate.id]
	local first = passage.points[1]
	passagesOk = passagesOk
		and Layout.distance(first, gate) < 2
		and #passage.heights == #passage.points
	local at = Regions.pointAlong(passage.points, passage.swapAt)
	local weights = Regions.weights(zones, at)
	swapOk = swapOk
		and Regions.swapNear(World.passages, at) == passage
		and near(weights[from.id] or 0, 0.5, 0.05)
		and near(weights[to.id] or 0, 0.5, 0.05)
end
check("each passage starts at its sealed road's gate", passagesOk)
check("each sky swap point sits on the blend's even split", swapOk)
check(
	"far from a swap point nothing is swapping",
	Regions.swapNear(World.passages, { x = 0, z = 0 }) == nil
)

print("No quick changes")
-- Along the main road no preset moves from 90% to 10% in under 150 studs.
local slow = true
for _, biome in ordered do
	local lastAbove: number? = nil
	local firstBelow: number? = nil
	for x = -600, 4400, 4 do
		local w = Regions.weights(zones, { x = x, z = -80 })[biome.id] or 0
		if w >= 0.9 then
			lastAbove = x
		elseif w <= 0.1 and lastAbove and not firstBelow then
			firstBelow = x
		end
	end
	if lastAbove and firstBelow then
		slow = slow and (firstBelow - lastAbove) >= ClimateConfig.MIN_BLEND_STUDS
	end
end
check("every blend between neighbouring biomes is at least 150 studs", slow)
local sumsOk = true
for x = -600, 4400, 8 do
	local total = 0
	for _, w in Regions.weights(zones, { x = x, z = -80 }) do
		total += w
	end
	sumsOk = sumsOk and near(total, 1, 1e-6)
end
check("the weights sum to 1 along the whole road", sumsOk)

print("Biome sites")
local moved = table.clone(ordered)
local flatsCopy = table.clone(ordered[3])
flatsCopy.site = { hub = { x = 2500, z = -900 }, base = 0 }
moved[3] = flatsCopy
local movedWorld = Layout.world(moved, Tamers.locals)
check(
	"a biome with a site stands there instead of straight on",
	near(movedWorld.maps[3].hub.x, 2500, 1) and near(movedWorld.maps[3].hub.z, -900, 1)
)
check("one without a site keeps the straight-on rule", near(movedWorld.maps[2].hub.x, 984.4, 1))
local noRegion = table.clone(ordered)
for index, biome in noRegion do
	local copy = table.clone(biome)
	copy.region = nil
	noRegion[index] = copy
end
local fallbackWorld = Layout.world(noRegion, Tamers.locals)
check(
	"with no regions, biomeAt falls back to the nearest place",
	Layout.biomeAt(fallbackWorld, { x = 0, z = 0 }) == 1
		and Layout.biomeAt(fallbackWorld, world.map.places.dust_canyon_hub) == 2
)

print("Presets")
local presetsOk = true
for id, preset in ClimateConfig.PRESETS do
	local ok = preset.clockTime >= 0
		and preset.clockTime < 24
		and preset.bed.volume >= 0
		and preset.bed.volume <= 1
	local colours: { { number } } = {
		preset.ambient,
		preset.outdoorAmbient,
		preset.shiftTop,
		preset.shiftBottom,
		preset.air.color,
		preset.air.decay,
		preset.grade.tint,
		preset.clouds.color,
	}
	for _, c in colours do
		for i = 1, 3 do
			ok = ok and c[i] >= 0 and c[i] <= 255
		end
	end
	if not ok then
		print(`   bad preset {id}`)
	end
	presetsOk = presetsOk and ok
end
check("every preset's values are in range", presetsOk)
local greenwood = ClimateConfig.PRESETS.greenwood
check(
	"greenwood matches what the server sets at start",
	greenwood.clockTime == 16.6
		and greenwood.brightness == 2.6
		and greenwood.air.density == 0.3
		and greenwood.grade.saturation == 0.08
)

print("Blend maths")
local function lookMatches(a: ClimateBlend.Look, b: ClimateBlend.Look): boolean
	for _, key in ClimateBlend.NUMBER_KEYS do
		if not near(a.numbers[key], b.numbers[key], 1e-6) then
			return false
		end
	end
	for _, key in ClimateBlend.COLOUR_KEYS do
		for i = 1, 3 do
			if not near(a.colours[key][i], b.colours[key][i], 1e-6) then
				return false
			end
		end
	end
	return true
end
local own = ClimateBlend.mix(ClimateConfig.PRESETS, { greenwood = 1 })
check(
	"a mix of one preset is that preset",
	own ~= nil and lookMatches(own, ClimateBlend.lookOf(ClimateConfig.PRESETS.greenwood))
)
local a = ClimateBlend.mix(ClimateConfig.PRESETS, { greenwood = 2, dust_canyon = 2 })
local b = ClimateBlend.mix(ClimateConfig.PRESETS, { greenwood = 0.5, dust_canyon = 0.5 })
check("weights are scaled to sum to 1", a ~= nil and b ~= nil and lookMatches(a, b))
check(
	"an even mix of brightness is between the two",
	(function()
		-- Between the two presets' own brightness, whatever they are tuned to.
		local g = ClimateConfig.PRESETS.greenwood.brightness
		local d = ClimateConfig.PRESETS.dust_canyon.brightness
		local low, high = math.min(g, d), math.max(g, d)
		return a ~= nil
			and a.numbers.brightness >= low - 1e-6
			and a.numbers.brightness <= high + 1e-6
	end)()
)
check(
	"no weight gives no look",
	ClimateBlend.mix(ClimateConfig.PRESETS, {}) == nil
		and ClimateBlend.mix(ClimateConfig.PRESETS, { nope = 1 }) == nil
)
local mixedClock = ClimateBlend.mixClock({ 23, 1 }, { 0.5, 0.5 })
check(
	"the clock mixes the short way round",
	ClimateBlend.clockGap(mixedClock, 0) < 1e-6,
	tostring(mixedClock)
)
local from = ClimateBlend.copy(ClimateBlend.lookOf(ClimateConfig.PRESETS.greenwood))
local to = ClimateBlend.copy(from)
from.numbers.clock, to.numbers.clock = 23, 1
ClimateBlend.ease(from, to, 0.5)
check(
	"a clock easing from 23 towards 1 goes through midnight",
	ClimateBlend.clockGap(from.numbers.clock, 0) < 1e-6
)
local start = ClimateBlend.copy(ClimateBlend.lookOf(ClimateConfig.PRESETS.greenwood))
local goal = ClimateBlend.lookOf(ClimateConfig.PRESETS.dust_canyon)
local before = start.numbers.brightness
ClimateBlend.ease(start, goal, ClimateBlend.alpha(1 / 60, ClimateConfig.LOOK_TIME_CONSTANT))
check(
	"easing closes part of the gap and never overshoots",
	(function()
		-- It moves toward the goal and stops short of it, from either side.
		local toGoal = goal.numbers.brightness - before
		local stepped = start.numbers.brightness - before
		if math.abs(toGoal) < 1e-6 then
			return math.abs(stepped) < 1e-6
		end
		return stepped / toGoal > 0 and stepped / toGoal < 1
	end)()
)
check(
	"alpha is about 63% after one time constant and 0 for no time",
	near(ClimateBlend.alpha(1.5, 1.5), 1 - math.exp(-1)) and ClimateBlend.alpha(0, 1.5) == 0
)
check(
	"frame-rate independent: two half steps equal one whole",
	near(1 - (1 - ClimateBlend.alpha(0.1, 1.5)) ^ 2, ClimateBlend.alpha(0.2, 1.5))
)

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error(`{failed} test(s) failed`)
end
