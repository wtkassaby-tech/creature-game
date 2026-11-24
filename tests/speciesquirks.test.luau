--!strict
-- Data checks for the species personalities. Run:  lune run tests/speciesquirks.test

local Gestures = require("../src/shared/Gestures")
local Species = require("../src/content/Species")
local SpeciesQuirks = require("../src/content/SpeciesQuirks")

local passed, failed = 0, 0
local function check(name: string, condition: boolean)
	if condition then
		passed += 1
		print(`  PASS  {name}`)
	else
		failed += 1
		print(`  FAIL  {name}`)
	end
end

local seenPairs: { [string]: string } = {}
local seenTemperaments: { [string]: string } = {}
local gestureCount: { [string]: number } = {}
local count = 0
for name in Species do
	count += 1
	local quirk = SpeciesQuirks[name]
	check(`{name} has a quirk entry`, quirk ~= nil)
	if quirk then
		check(`{name} gesture is a real gesture`, Gestures.isGesture(quirk.gesture))
		check(`{name} entrance is a real entrance`, Gestures.isEntrance(quirk.entrance))
		check(
			`{name} gesture comes round every 6 to 14 seconds`,
			quirk.gestureEvery >= 6 and quirk.gestureEvery <= 14
		)
		check(
			`{name} cry is sane`,
			quirk.cry.pitch >= 0.4
				and quirk.cry.pitch <= 2
				and quirk.cry.notes >= 1
				and quirk.cry.notes <= 6
				and quirk.cry.gap >= 0.03
				and quirk.cry.gap <= 0.6
		)
		local factsOk = #quirk.facts >= 1 and #quirk.facts <= 2
		for _, fact in quirk.facts do
			if #fact == 0 or #fact >= 90 then
				factsOk = false
				print(`    fact too long or empty ({#fact}): {fact}`)
			end
		end
		check(`{name} has 1-2 facts under 90 characters`, factsOk)
		check(
			`{name} has a temperament, favourite and rare look`,
			quirk.temperament ~= "" and quirk.favourite ~= "" and quirk.rareLook ~= ""
		)
		local key = `{quirk.temperament}|{quirk.gesture}`
		check(`{name} temperament and gesture pair is its own`, seenPairs[key] == nil)
		seenPairs[key] = name
		check(`{name} temperament is its own`, seenTemperaments[quirk.temperament] == nil)
		seenTemperaments[quirk.temperament] = name
		gestureCount[quirk.gesture] = (gestureCount[quirk.gesture] or 0) + 1
	end
end
for name in SpeciesQuirks do
	check(`{name} quirk belongs to a real species`, Species[name] ~= nil)
end
check("there are 36 species", count == 36)
for gesture, n in gestureCount do
	check(`{gesture} is not used by more than four species`, n <= 4)
end
check(
	"every gesture is used by someone",
	(function()
		for _, g in Gestures.GESTURES do
			if gestureCount[g] == nil then
				return false
			end
		end
		return true
	end)()
)

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("species quirk tests failed")
end
