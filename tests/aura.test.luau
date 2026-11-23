--!strict
-- Checks on the aura maths and presets: hover never dips below rest, sway and pulse stay inside
-- their bounds, every preset stays under the particle budget with built-in textures only, and
-- every species named for an aura names a preset. Run from the project folder:
--   lune run tests/aura.test

local AuraConfig = require("../src/config/AuraConfig")
local AuraMath = require("../src/shared/AuraMath")

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

print("Hover, sway and pulse")
local lowest, highest = math.huge, -math.huge
local swayMax, pulseLow, pulseHigh = 0, math.huge, -math.huge
for step = 0, 2000 do
	local time = step * 0.05
	local lift = AuraMath.hoverOffset(time, 1.3, 0.5, 5.5)
	lowest, highest = math.min(lowest, lift), math.max(highest, lift)
	swayMax = math.max(swayMax, math.abs(AuraMath.swayYaw(time, 0.4, 3, 9)))
	local glow = AuraMath.pulse(time, 0.2, 0.35, 4)
	pulseLow, pulseHigh = math.min(pulseLow, glow), math.max(pulseHigh, glow)
end
check("hover never dips below rest", lowest >= -1e-9, tostring(lowest))
check("hover peaks at twice its amplitude", math.abs(highest - 1) < 0.01, tostring(highest))
check("sway stays within its angle", swayMax <= math.rad(3) + 1e-9)
check("pulse stays within its depth", pulseLow >= 0.65 - 1e-9 and pulseHigh <= 1.35 + 1e-9)
check("hover starts from its phase", math.abs(AuraMath.hoverOffset(0, 0, 1, 4) - 1) < 1e-9)
check(
	"zero period means no motion",
	AuraMath.hoverOffset(3, 0, 1, 0) == 0 and AuraMath.pulse(3, 0, 1, 0) == 1
)
check("a far aura is out of range", AuraMath.inRange(100, 140) and not AuraMath.inRange(141, 140))

print("Presets")
for name, preset in AuraConfig.PRESETS do
	local live = 0
	local texturesOk = true
	for _, emitter in preset.emitters do
		local longest = emitter.lifetime[2]
		live += AuraMath.liveParticles(emitter.rate, longest)
		texturesOk = texturesOk and string.sub(emitter.texture, 1, 13) == "rbxasset://te"
		check(
			`{name}/{emitter.name} has a lifetime range`,
			emitter.lifetime[1] <= emitter.lifetime[2]
		)
	end
	check(`{name} stays in the particle budget`, live <= AuraConfig.PARTICLE_BUDGET, tostring(live))
	check(`{name} uses built-in textures only`, texturesOk)
	check(
		`{name} has a light and a positive pulse period`,
		preset.light.range > 0 and preset.pulse.period > 0
	)
end
for species, preset in AuraConfig.SPECIES do
	check(`{species} names a real preset`, AuraConfig.PRESETS[preset] ~= nil, preset)
end
check("all ten elements have a colour", #AuraConfig.ELEMENT_ORDER == 10)
for _, element in AuraConfig.ELEMENT_ORDER do
	check(`{element} has a colour`, AuraConfig.ELEMENT_COLOURS[element] ~= nil)
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error(`{failed} test(s) failed`)
end
