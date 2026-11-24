--!strict
-- Tests for the creature motion maths. Run:  lune run tests/motion.test

local Motion = require("../src/shared/Motion")

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

print("\n== Easing ==")
do
	local names: { Motion.Ease } =
		{ "Linear", "QuadIn", "QuadOut", "QuadInOut", "BackIn", "BackOut", "ElasticOut" }
	for _, name: Motion.Ease in names do
		check(
			`{name} starts at 0 and ends at 1`,
			near(Motion.ease(name, 0), 0) and near(Motion.ease(name, 1), 1)
		)
	end
	check("QuadIn is slow at first", Motion.ease("QuadIn", 0.5) < 0.5)
	check("QuadOut is quick at first", Motion.ease("QuadOut", 0.5) > 0.5)
	check("BackOut overshoots", Motion.ease("BackOut", 0.7) > 1)
	check("BackIn pulls back first", Motion.ease("BackIn", 0.2) < 0)
	check("ElasticOut overshoots", Motion.ease("ElasticOut", 0.15) > 1)
	check(
		"out of range is clamped",
		near(Motion.ease("QuadOut", 3), 1) and near(Motion.ease("QuadIn", -1), 0)
	)
end

print("\n== Lunge ==")
do
	local track = Motion.lunge(0.6, 3.5)
	local rest = Motion.sample(track, 0)
	check("starts at rest", near(rest.fwd, 0) and near(rest.sy, 1))
	local wound = Motion.sample(track, Motion.LUNGE_WINDUP)
	check("winds back 0.6 and squashes to 0.85", near(wound.fwd, -0.6) and near(wound.sy, 0.85))
	local held = Motion.sample(track, Motion.LUNGE_WINDUP + Motion.LUNGE_HOLD / 2)
	check("holds the wind-up", near(held.fwd, -0.6) and near(held.sy, 0.85))
	local struck = Motion.sample(track, Motion.LUNGE_WINDUP + Motion.LUNGE_HOLD + Motion.LUNGE_DART)
	check("darts 3.5 forward, stretched to 1.12", near(struck.fwd, 3.5) and near(struck.sy, 1.12))
	local done = Motion.sample(track, track.seconds)
	check("ends at rest", near(done.fwd, 0) and near(done.sy, 1) and near(done.pitch, 0))
	check("total length is the sum of the phases", near(track.seconds, 0.12 + 0.04 + 0.08 + 0.25))
	local middle = Motion.sample(track, 0.2)
	check("the release is part way through the dart", middle.fwd > -0.6 and middle.fwd < 3.5)
	check(
		"the curve takes progress 0..1",
		near(Motion.curve(track)(1).fwd, 0) and near(Motion.curve(track)(0).fwd, 0)
	)
end

print("\n== Hit ==")
do
	local small, big = Motion.hit(false), Motion.hit(true)
	check("squashed the instant it lands", near(Motion.sample(small, 0).sy, 0.78))
	check(
		"knocked 0.5 back, 1.0 on a big hit",
		near(Motion.sample(small, 0).fwd, -0.5) and near(Motion.sample(big, 0).fwd, -1.0)
	)
	check("leans away 12 degrees", near(Motion.sample(small, 0).pitch, math.rad(12)))
	check(
		"recovers to rest",
		near(Motion.sample(small, small.seconds).sy, 1)
			and near(Motion.sample(big, big.seconds).fwd, 0)
	)
	check("recovery is 0.35 s after the hold", near(small.seconds, 0.04 + 0.35))
	local overshoot = false
	for step = 0, 40 do
		if Motion.sample(big, 0.04 + 0.35 * step / 40).sy > 1.001 then
			overshoot = true
		end
	end
	check("a big hit springs back past rest", overshoot)
end

print("\n== Faint ==")
do
	local track = Motion.faint(0.8)
	check(
		"wobbles within 8 degrees",
		math.abs(Motion.sample(track, 0.1).roll) <= math.rad(8) + 1e-6
	)
	local wobbles = 0
	local last = 0
	for step = 1, 80 do
		local roll = Motion.sample(track, Motion.FAINT_WOBBLE * step / 80).roll
		if last ~= 0 and roll * last < 0 then
			wobbles += 1
		end
		if roll ~= 0 then
			last = roll
		end
	end
	check("it swings both ways at least three times (two full wobbles)", wobbles >= 3)
	local down = Motion.sample(track, Motion.faintDownAt())
	check("down on its side by 0.75 s", near(down.roll, math.rad(-85)))
	check("lifted so its side rests on the ground", near(down.up, 0.8))
	check(
		"still solid while it lies there",
		near(Motion.sample(track, Motion.faintDownAt() + 0.3).fade, 0)
	)
	local end_ = Motion.sample(track, track.seconds)
	check("sunk 1.5 below where it lay, and gone", near(end_.up, 0.8 - 1.5) and near(end_.fade, 1))
	check("topple is inside one event's pause", Motion.faintDownAt() < 0.8)
	local bounced = Motion.sample(track, Motion.faintDownAt() + 0.1).roll
	check("a small bounce back", bounced > math.rad(-85))
end

print("\n== Other tracks ==")
do
	local appear = Motion.appear(1.5, 0)
	check("appears at 0.2 scale", near(Motion.sample(appear, 0).sy, 0.2))
	check("springs past full size", Motion.sample(appear, 0.28).sy > 1)
	check(
		"settles to 1 and lands",
		near(Motion.sample(appear, appear.seconds).sy, 1)
			and near(Motion.sample(appear, appear.seconds).up, 0)
	)
	check("hops 1.5 studs", near(Motion.sample(appear, Motion.APPEAR_SECONDS * 0.45).up, 1.5))
	check(
		"out of the grass starts below the ground",
		Motion.sample(Motion.appear(1.5, -0.8), 0).up < 0
	)
	local recall = Motion.recall()
	check(
		"recall shrinks to a speck in 0.2 s",
		near(recall.seconds, 0.2) and near(Motion.sample(recall, 0.2).sy, 0.05)
	)
	check("recall swells first", Motion.sample(recall, 0.04).sy > 1)
	local tug = Motion.tug()
	check(
		"tug ends at rest",
		near(Motion.sample(tug, tug.seconds).fwd, 0)
			and near(Motion.sample(tug, tug.seconds).side, 0)
	)
	check("tug pulls toward the player", Motion.sample(tug, 0.1).fwd > 0.5)
	local bound = Motion.bound()
	local flies = false
	for step = 0, 20 do
		if Motion.sample(bound, bound.seconds * step / 20).up > 1 then
			flies = true
		end
	end
	check("bound hops", flies)
	check(
		"bound ends away from the player and faded",
		Motion.sample(bound, bound.seconds).fwd < -5
			and near(Motion.sample(bound, bound.seconds).fade, 1)
	)
	check("sink fades to nothing", near(Motion.sample(Motion.sink(), 0.6).fade, 1))
	local hop = Motion.hop()
	check(
		"a person's hop returns to rest",
		near(Motion.sample(hop, hop.seconds).sy, 1) and near(Motion.sample(hop, hop.seconds).up, 0)
	)
end

print("\n== Breath, shake and turning ==")
do
	for step = 0, 50 do
		local sy, sx = Motion.breath(step * 0.37, 1.2, 1)
		if sy < 0.969 or sy > 1.031 or sx < 0.984 or sx > 1.016 then
			check("breath stays within 3% tall and 1.5% wide", false)
		end
	end
	check("breath stays within 3% tall and 1.5% wide", true)
	local sy0, sx0 = Motion.breath(0, 0, 1)
	check("at the start of a breath it is at rest", near(sy0, 1) and near(sx0, 1))
	local fast, slow = 0, 0
	for step = 0, 200 do
		local t = step * 0.01
		local a = Motion.breath(t, 0, 1)
		local b = Motion.breath(t, 0, 4)
		if a > 1 and Motion.breath(t - 0.01, 0, 1) <= 1 then
			fast += 1
		end
		if b > 1 and Motion.breath(t - 0.01, 0, 4) <= 1 then
			slow += 1
		end
	end
	check("a bigger creature breathes slower", fast >= slow)
	check(
		"the shake starts at zero and dies away",
		near(Motion.shakePush(1, 0), 0) and math.abs(Motion.shakePush(1, 0.3)) < 0.02
	)
	check(
		"the shake swings both ways",
		Motion.shakePush(1, 0.014) > 0 and Motion.shakePush(1, 0.042) < 0
	)
	check(
		"yaw toward a direction",
		near(Motion.yawToward(0, -1), 0) and near(Motion.yawToward(-1, 0), math.pi / 2)
	)
	check(
		"angles wrap",
		near(Motion.wrapAngle(3 * math.pi / 2), -math.pi / 2) and near(Motion.wrapAngle(0.5), 0.5)
	)
	local a = Motion.approach(0, 1, 6, 1 / 30)
	local b = Motion.approach(Motion.approach(0, 1, 6, 1 / 60), 1, 6, 1 / 60)
	check("approach does not depend on the frame rate", near(a, b, 1e-9) and a > 0 and a < 1)
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("motion tests failed")
end
