--!strict
-- Tests for the gesture and entrance curves. Run:  lune run tests/gestures.test

local Gestures = require("../src/shared/Gestures")

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
local function near(a: number, b: number, within: number?): boolean
	return math.abs(a - b) <= (within or 1e-6)
end
-- An angle is at rest if it is a whole number of turns.
local function turned(angle: number): boolean
	local turns = angle / (2 * math.pi)
	return near(turns, math.round(turns), 1e-6)
end
local function atRest(pose: Gestures.Pose): boolean
	return near(pose.fwd, 0)
		and near(pose.side, 0)
		and near(pose.up, 0)
		and turned(pose.pitch)
		and turned(pose.yaw)
		and turned(pose.roll)
		and near(pose.sx, 1)
		and near(pose.sy, 1)
		and near(pose.sz, 1)
end
local function finite(pose: Gestures.Pose): boolean
	for _, v in
		{ pose.fwd, pose.side, pose.up, pose.pitch, pose.yaw, pose.roll, pose.sx, pose.sy, pose.sz }
	do
		if v ~= v or math.abs(v) == math.huge then
			return false
		end
	end
	return true
end

print("\n== Gestures ==")
for _, name in Gestures.GESTURES do
	local curve = Gestures.curve(name)
	check(`{name} exists`, curve ~= nil)
	if curve then
		check(`{name} is not an entrance`, not curve.isEntrance)
		check(`{name} lasts a sane time`, curve.seconds >= 0.4 and curve.seconds <= 3.5)
		check(`{name} starts at rest`, atRest(curve.at(0)))
		check(`{name} ends at rest`, atRest(curve.at(curve.seconds)))
		check(`{name} stays at rest past its end`, atRest(curve.at(curve.seconds + 5)))
		local ok, moved = true, false
		for i = 0, 200 do
			local pose = curve.at(curve.seconds * i / 200)
			local maxAngle = if name == "Spin" then 2 * math.pi + 0.01 else 0.6
			if
				not finite(pose)
				or math.abs(pose.fwd) > 0.4
				or math.abs(pose.side) > 0.4
				or math.abs(pose.up) > 0.4
				or math.abs(pose.pitch) > maxAngle
				or math.abs(pose.yaw) > maxAngle
				or math.abs(pose.roll) > maxAngle
				or pose.sx < 0.75
				or pose.sx > 1.3
				or pose.sy < 0.7
				or pose.sy > 1.3
				or pose.sz < 0.75
				or pose.sz > 1.3
			then
				ok = false
			end
			if not atRest(pose) then
				moved = true
			end
		end
		check(`{name} stays in bounds`, ok)
		check(`{name} actually moves`, moved)
	end
end

print("\n== Entrances ==")
for _, name in Gestures.ENTRANCES do
	local curve = Gestures.curve(name)
	check(`{name} exists`, curve ~= nil)
	if curve then
		check(`{name} is an entrance`, curve.isEntrance)
		check(`{name} lasts a sane time`, curve.seconds >= 0.4 and curve.seconds <= 1.5)
		check(`{name} begins away from rest`, not atRest(curve.at(0)))
		check(`{name} ends at rest`, atRest(curve.at(curve.seconds)))
		local ok = true
		for i = 0, 200 do
			local pose = curve.at(curve.seconds * i / 200)
			if
				not finite(pose)
				or math.abs(pose.fwd) > 2
				or math.abs(pose.side) > 2
				or math.abs(pose.up) > 2.1
				or math.abs(pose.pitch) > 1
				or math.abs(pose.roll) > 1
				or math.abs(pose.yaw) > 2 * math.pi + 0.01
				or pose.sx < 0.1
				or pose.sx > 1.5
				or pose.sy < 0.1
				or pose.sy > 1.5
				or pose.sz < 0.1
				or pose.sz > 1.5
			then
				ok = false
			end
		end
		check(`{name} stays in bounds`, ok)
	end
end

print("\n== Names ==")
do
	check("an unknown name has no curve", Gestures.curve("Moonwalk") == nil)
	check(
		"isGesture and isEntrance tell them apart",
		Gestures.isGesture("Hop")
			and not Gestures.isGesture("HopIn")
			and Gestures.isEntrance("HopIn")
			and not Gestures.isEntrance("Hop")
	)
	check("negative time is the start", atRest((Gestures.curve("Hop") :: Gestures.Curve).at(-1)))
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("gestures tests failed")
end
