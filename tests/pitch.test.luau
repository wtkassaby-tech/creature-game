--!strict
-- Tests for the pitch maths and the jingle data. Run:  lune run tests/pitch.test

local JingleConfig = require("../src/config/JingleConfig")
local Pitch = require("../src/shared/Pitch")

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
local function near(a: number, b: number): boolean
	return math.abs(a - b) < 1e-9
end

print("Semitones to speed")
check("0 is the sample as recorded", near(Pitch.speed(0), 1))
check("12 is an octave up", near(Pitch.speed(12), 2))
check("-12 is an octave down", near(Pitch.speed(-12), 0.5))
check("7 is a fifth, about 1.498", math.abs(Pitch.speed(7) - 1.4983) < 1e-3)
check("each step multiplies by 2^(1/12)", near(Pitch.speed(5) / Pitch.speed(4), 2 ^ (1 / 12)))

print("Timeline")
local events = Pitch.timeline({
	{ semitone = 0, beats = 1 },
	{ semitone = 12, beats = 0.5 },
	{ semitone = 7, beats = 2 },
}, 120)
check("one event per note", #events == 3)
check("first starts at 0", near(events[1].start, 0))
check("second starts one beat in (0.5 s at 120 bpm)", near(events[2].start, 0.5))
check("third starts after 1.5 beats (0.75 s)", near(events[3].start, 0.75))
check("speeds follow the semitones", near(events[2].speed, 2))
check(
	"length is the total beats in seconds",
	near(Pitch.length({ { semitone = 0, beats = 3 }, { semitone = 1, beats = 1 } }, 60), 4)
)

print("Jingle data")
check("instrument id", string.sub(JingleConfig.INSTRUMENT_ID, 1, 13) == "rbxassetid://")
for name, jingle in JingleConfig.JINGLES do
	check(`{name}: 3 to 8 notes`, #jingle.notes >= 3 and #jingle.notes <= 8)
	check(
		`{name}: bpm and volume sane`,
		jingle.bpm > 60 and jingle.bpm < 240 and jingle.volume > 0 and jingle.volume <= 1
	)
	local length = Pitch.length(jingle.notes, jingle.bpm)
	check(`{name}: lasts 0.5 to 4 s`, length >= 0.5 and length <= 4, `{length}`)
	local sane = true
	for _, note in jingle.notes do
		if note.beats <= 0 or note.semitone < -12 or note.semitone > 24 then
			sane = false
		end
	end
	check(`{name}: notes in range`, sane)
end
local wanted = {
	"heal",
	"catch",
	"itemGet",
	"levelUp",
	"badge",
	"questDone",
	"tamerSpotted",
	"journal",
	"hatch",
}
for _, name in wanted do
	check(`jingle {name} exists`, JingleConfig.JINGLES[name] ~= nil)
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error(`{failed} test(s) failed`)
end
