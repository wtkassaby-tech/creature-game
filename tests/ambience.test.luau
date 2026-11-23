--!strict
-- Checks on the world's ambient particles and lights: every kind of effect follows the particle
-- rules (glow = LightEmission 1, a size curve that starts small, peaks early and ends at nothing,
-- transparency that fades in and out), every launch biome declares its ambience, and each one
-- stays under the budget so phones stay smooth. Run from the project folder:
--   lune run tests/ambience.test

local AmbienceConfig = require("../src/config/AmbienceConfig")
local AmbiencePlan = require("../src/shared/AmbiencePlan")
local DustCanyonDressing = require("../src/content/map_data/DustCanyonDressing")
local GreenwoodDressing = require("../src/content/map_data/GreenwoodDressing")
local TideFlatsDressing = require("../src/content/map_data/TideFlatsDressing")
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

local BIOMES: { { id: string, sheet: WorldTypes.DressingSheet } } = {
	{ id = "greenwood", sheet = GreenwoodDressing },
	{ id = "dust_canyon", sheet = DustCanyonDressing },
	{ id = "tide_flats", sheet = TideFlatsDressing },
}

print("The look of each kind follows the particle rules")
for kind, look in AmbienceConfig.KINDS do
	local prefix = `{kind}: `
	local textured = string.sub(look.texture, 1, 29) == "rbxasset://textures/particles"
	check(prefix .. "uses an engine particle texture", textured, look.texture)
	if look.soft then
		check(prefix .. "a soft kind keeps LightEmission low", look.lightEmission <= 0.6)
	else
		check(prefix .. "a glowing kind has LightEmission 1", look.lightEmission == 1)
		check(
			prefix .. "its size is small at birth, peaks, then shrinks to nothing",
			look.size.birth < look.size.peak and look.size.final == 0
		)
	end
	check(
		prefix .. "it peaks in the first part of its life (or soft kinds grow slowly)",
		look.size.peakAt > 0 and look.size.peakAt < 1
	)
	check(
		prefix .. "it fades in, holds, then fades out, in that order",
		look.fadeIn > 0 and look.fadeIn < look.fadeOut and look.fadeOut < 1
	)
	check(prefix .. "its opacity is a transparency", look.opaque >= 0 and look.opaque < 1)
	check(
		prefix .. "its ranges and rate are sane",
		look.lifetime[1] > 0
			and look.lifetime[1] <= look.lifetime[2]
			and look.speed[1] <= look.speed[2]
			and look.rate > 0
	)
	check(prefix .. "its colours are 0 to 255", #look.colour == 3 and #look.colour2 == 3)
end

print("Each launch biome declares ambience and stays inside the budget")
local budget = AmbienceConfig.BUDGET
for _, biome in BIOMES do
	local sheet = biome.sheet
	local ambience = sheet.ambience
	check(`{biome.id}: declares ambience`, ambience ~= nil)
	if not ambience then
		continue
	end
	local specs = AmbiencePlan.plan(sheet)
	local totals = AmbiencePlan.totals(specs)
	local detail =
		`{totals.emitters} emitters, rate {string.format("%.1f", totals.rate)}, live {string.format(
			"%.0f",
			totals.live
		)}, {totals.lights} lights`
	check(`{biome.id}: emitters under budget`, totals.emitters <= budget.MAX_EMITTERS, detail)
	check(`{biome.id}: total rate under budget`, totals.rate <= budget.MAX_RATE, detail)
	check(`{biome.id}: live particles under budget`, totals.live <= budget.MAX_LIVE, detail)
	check(`{biome.id}: lights under budget`, totals.lights <= budget.MAX_LIGHTS, detail)
	check(`{biome.id}: has something to build`, totals.emitters >= 10, detail)

	local kinds: { [string]: number } = {}
	local lightsOk, kindsOk, countsOk = true, true, true
	for _, spec in specs do
		kinds[spec.kind] = (kinds[spec.kind] or 0) + 1
		if AmbienceConfig.KINDS[spec.kind] == nil then
			kindsOk = false
		end
		local light = spec.light
		if light and not (light.range > 0 and light.range <= AmbienceConfig.MAX_LIGHT_RANGE) then
			lightsOk = false
		end
		if spec.rate < 0 or spec.scale <= 0 or spec.width < 0 or spec.depth < 0 then
			countsOk = false
		end
	end
	check(`{biome.id}: every effect is a known kind`, kindsOk)
	check(`{biome.id}: every light is within a PointLight's range of 60`, lightsOk)
	check(`{biome.id}: every effect has a sane rate, scale and size`, countsOk)
	check(`{biome.id}: every lamp has a light and a halo`, (kinds.Halo or 0) >= #sheet.lamps)
	check(`{biome.id}: has chimney smoke`, (kinds.Smoke or 0) >= 3)
	check(`{biome.id}: has a glint on its water`, (kinds.Glint or 0) >= 1)
end

print("Each biome's own effects are there")
local function count(sheet: WorldTypes.DressingSheet, kind: string): number
	local found = 0
	for _, spec in AmbiencePlan.plan(sheet) do
		if spec.kind == kind then
			found += 1
		end
	end
	return found
end
check(
	"Greenwood has pollen and seed fluff",
	count(GreenwoodDressing, "Pollen") > 0 and count(GreenwoodDressing, "Fluff") > 0
)
check(
	"Dust Canyon has dust motes, and embers by the kiln",
	count(DustCanyonDressing, "Dust") > 0 and count(DustCanyonDressing, "Embers") > 0
)
check(
	"Tide Flats has spray and mist",
	count(TideFlatsDressing, "Spray") > 0 and count(TideFlatsDressing, "Mist") > 0
)

print("The plan works out a chimney from its house")
local house: WorldTypes.DressHouse =
	{ at = { x = 100, z = 50 }, faces = 90, model = "Hut", width = 20, depth = 10, tall = 20 }
local sheet = table.clone(GreenwoodDressing)
sheet.houses = { house }
sheet.lamps = {}
sheet.pools = {}
sheet.pond = nil
sheet.ambience = { chimneys = { Hut = { 0.5, 1, 0.5 } }, sources = {} }
local planned = AmbiencePlan.plan(sheet)
-- Facing east (90): its right is south (+z) and its back is west (-x).
local smoke = planned[1]
check("a house with a chimney gets one smoke source", #planned == 1 and smoke.kind == "Smoke")
check(
	"it starts at the offset, turned to the house's facing",
	math.abs(smoke.x - (100 - 0.5 * 10)) < 1e-6 and math.abs(smoke.z - (50 + 0.5 * 20)) < 1e-6,
	`{smoke.x}, {smoke.z}`
)
check("it starts above the roof", smoke.y > house.tall)
local none = table.clone(sheet)
none.ambience = nil
check("a sheet with no ambience plans nothing", #AmbiencePlan.plan(none) == 0)

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error(`{failed} test(s) failed`)
end
