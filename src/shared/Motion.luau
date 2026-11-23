--!strict
-- The maths of creature motion: easing functions and the motion tracks (lunge, hit, faint,
-- tug, bound, appear, recall, a person's hop) as pure functions of time. A track is a few
-- channels of keys; sampling it gives a Pose of plain numbers, which the client turns into an
-- offset, a tilt and a scale (Creatures/ToyBody). No Roblox services, so it is unit-tested under
-- Lune. Looks only: nothing here decides a battle result.
--
-- Axes, in the creature's own frame: `fwd` is along the way it faces, `side` is to its right,
-- `up` is up. `pitch` leans it back (positive) or forward, `roll` tips it onto its side, `yaw`
-- turns it, all about its feet. `sy` is the height scale (the client keeps the volume: the width
-- is 1/sqrt(sy)). `fade` is how see-through it is, 0 solid and 1 gone.

local Motion = {}

export type Ease =
	"Linear"
	| "QuadIn"
	| "QuadOut"
	| "QuadInOut"
	| "BackIn"
	| "BackOut"
	| "ElasticOut"

export type Pose = {
	fwd: number,
	side: number,
	up: number,
	pitch: number,
	roll: number,
	yaw: number,
	sy: number,
	fade: number,
	-- Width (both horizontal axes) as a multiple of the base width. Left out, the client keeps the
	-- volume (1 / sqrt(sy)); a gesture that puffs or swells sets it (see shared/Gestures).
	wide: number?,
}

-- `at` is in seconds; `ease` shapes the way in to this key from the one before it.
export type Key = { at: number, value: number, ease: Ease? }

export type Track = {
	seconds: number,
	fwd: { Key }?,
	side: { Key }?,
	up: { Key }?,
	pitch: { Key }?,
	roll: { Key }?,
	yaw: { Key }?,
	sy: { Key }?,
	fade: { Key }?,
}

local BACK = 1.70158

function Motion.rest(): Pose
	return { fwd = 0, side = 0, up = 0, pitch = 0, roll = 0, yaw = 0, sy = 1, fade = 0 }
end

-- Easing, each taking 0..1 to 0..1 (Back and Elastic overshoot on the way).
function Motion.ease(name: Ease, t: number): number
	local x = math.clamp(t, 0, 1)
	if name == "QuadIn" then
		return x * x
	elseif name == "QuadOut" then
		return 1 - (1 - x) * (1 - x)
	elseif name == "QuadInOut" then
		return if x < 0.5 then 2 * x * x else 1 - 2 * (1 - x) * (1 - x)
	elseif name == "BackIn" then
		return (BACK + 1) * x * x * x - BACK * x * x
	elseif name == "BackOut" then
		local y = x - 1
		return 1 + (BACK + 1) * y * y * y + BACK * y * y
	elseif name == "ElasticOut" then
		if x == 0 or x == 1 then
			return x
		end
		return 2 ^ (-10 * x) * math.sin((x * 10 - 0.75) * (2 * math.pi) / 3) + 1
	end
	return x
end

-- The value of one channel at `seconds`: held at its first key before it, at its last after.
local function value(keys: { Key }?, seconds: number, default: number): number
	if not keys or #keys == 0 then
		return default
	end
	local first = keys[1]
	if seconds <= first.at then
		return first.value
	end
	for index = 2, #keys do
		local to = keys[index]
		if seconds < to.at then
			local from = keys[index - 1]
			local span = to.at - from.at
			local u = if span > 0 then (seconds - from.at) / span else 1
			return from.value + (to.value - from.value) * Motion.ease(to.ease or "Linear", u)
		end
	end
	return keys[#keys].value
end

function Motion.sample(track: Track, seconds: number): Pose
	return {
		fwd = value(track.fwd, seconds, 0),
		side = value(track.side, seconds, 0),
		up = value(track.up, seconds, 0),
		pitch = value(track.pitch, seconds, 0),
		roll = value(track.roll, seconds, 0),
		yaw = value(track.yaw, seconds, 0),
		sy = value(track.sy, seconds, 1),
		fade = value(track.fade, seconds, 0),
	}
end

-- The track as a function of progress 0..1 (what ToyBody's `act` takes).
function Motion.curve(track: Track): (number) -> Pose
	return function(t: number): Pose
		return Motion.sample(track, math.clamp(t, 0, 1) * track.seconds)
	end
end

local function key(at: number, v: number, ease: Ease?): Key
	return { at = at, value = v, ease = ease }
end

-- Attack: wind back and squash, hold, dart forward stretched, then settle with a little overshoot.
Motion.LUNGE_WINDUP = 0.12
Motion.LUNGE_HOLD = 0.04
Motion.LUNGE_DART = 0.08
Motion.LUNGE_RETURN = 0.25
-- When the dart is half way: the moment a shot should leave (contact is DART later than the
-- start of the dart, 0.24 s in).
Motion.LUNGE_RELEASE = 0.2

function Motion.lunge(back: number, reach: number): Track
	local windup = Motion.LUNGE_WINDUP
	local held = windup + Motion.LUNGE_HOLD
	local struck = held + Motion.LUNGE_DART
	local done = struck + Motion.LUNGE_RETURN
	return {
		seconds = done,
		fwd = {
			key(0, 0),
			key(windup, -back, "QuadOut"),
			key(held, -back),
			key(struck, reach, "QuadIn"),
			key(done, 0, "BackOut"),
		},
		sy = {
			key(0, 1),
			key(windup, 0.85, "QuadOut"),
			key(held, 0.85),
			key(struck, 1.12, "QuadIn"),
			key(done, 1, "BackOut"),
		},
		pitch = {
			key(0, 0),
			key(held, 0),
			key(struck, math.rad(-8), "QuadIn"),
			key(done, 0, "BackOut"),
		},
	}
end

-- Hit: it is squashed and knocked back the instant it lands (the client freezes time for a
-- moment on top of this), then recovers. A big hit knocks further and wobbles back (elastic).
Motion.HIT_HOLD = 0.04
Motion.HIT_RECOVER = 0.35
Motion.HIT_STOP = 0.06
Motion.HIT_STOP_BIG = 0.10

function Motion.hit(big: boolean): Track
	local knock = if big then 1.0 else 0.5
	local hold, done = Motion.HIT_HOLD, Motion.HIT_HOLD + Motion.HIT_RECOVER
	local recover: Ease = if big then "ElasticOut" else "BackOut"
	return {
		seconds = done,
		fwd = { key(0, -knock), key(hold, -knock), key(done, 0, recover) },
		sy = { key(0, 0.78), key(hold, 0.78), key(done, 1, recover) },
		pitch = { key(0, math.rad(12)), key(hold, math.rad(12)), key(done, 0, recover) },
	}
end

-- Faint: two wobbles, a topple onto its side about its feet, a small bounce, a pause, then it
-- sinks into the ground and fades. `lift` raises it while it lies down so its side rests on the
-- ground instead of sinking in. TOPPLE_END is when it is down, inside one battle event's pause.
Motion.FAINT_WOBBLE = 0.4
Motion.FAINT_TOPPLE = 0.35
Motion.FAINT_BOUNCE = 0.2
Motion.FAINT_HOLD = 0.4
Motion.FAINT_SINK = 0.6
Motion.FAINT_SINK_DEPTH = 1.5

function Motion.faint(lift: number): Track
	local w = Motion.FAINT_WOBBLE
	local down = w + Motion.FAINT_TOPPLE
	local bounced = down + Motion.FAINT_BOUNCE
	local held = bounced + Motion.FAINT_HOLD
	local gone = held + Motion.FAINT_SINK
	local wobble = math.rad(8)
	local lying = math.rad(-85)
	local half = Motion.FAINT_BOUNCE / 2
	return {
		seconds = gone,
		roll = {
			key(0, 0),
			key(w * 0.25, wobble, "QuadInOut"),
			key(w * 0.5, -wobble, "QuadInOut"),
			key(w * 0.75, wobble, "QuadInOut"),
			key(w, -wobble, "QuadInOut"),
			key(down, lying, "QuadIn"),
			key(down + half, lying + math.rad(9), "QuadOut"),
			key(bounced, lying, "QuadIn"),
		},
		up = {
			key(0, 0),
			key(w, 0),
			key(down, lift, "QuadIn"),
			key(held, lift),
			key(gone, lift - Motion.FAINT_SINK_DEPTH, "QuadIn"),
		},
		fade = { key(0, 0), key(held, 0), key(gone, 1) },
	}
end

-- The window that matters for pacing: the creature is down by this time.
function Motion.faintDownAt(): number
	return Motion.FAINT_WOBBLE + Motion.FAINT_TOPPLE
end

-- Pulled toward the player along the rope, then back, with a wobble across.
function Motion.tug(): Track
	return {
		seconds = 0.5,
		fwd = {
			key(0, 0),
			key(0.1, 0.9, "QuadOut"),
			key(0.25, 0.3, "QuadInOut"),
			key(0.35, 0.5, "QuadOut"),
			key(0.5, 0, "BackOut"),
		},
		side = {
			key(0, 0),
			key(0.2, 0),
			key(0.3, 0.5, "QuadOut"),
			key(0.4, -0.5, "QuadInOut"),
			key(0.5, 0, "QuadOut"),
		},
		sy = { key(0, 1), key(0.1, 0.94, "QuadOut"), key(0.5, 1, "BackOut") },
	}
end

-- It got free: three hops away from the player, shrinking into the distance, then gone.
function Motion.bound(): Track
	return {
		seconds = 0.95,
		fwd = { key(0, 0), key(0.9, -8, "QuadOut") },
		up = {
			key(0, 0),
			key(0.15, 2.2, "QuadOut"),
			key(0.3, 0, "QuadIn"),
			key(0.45, 2.0, "QuadOut"),
			key(0.6, 0, "QuadIn"),
			key(0.75, 1.5, "QuadOut"),
			key(0.9, 0, "QuadIn"),
		},
		sy = {
			key(0, 1),
			key(0.3, 0.88, "QuadOut"),
			key(0.38, 1.05, "QuadOut"),
			key(0.6, 0.9, "QuadOut"),
			key(0.7, 1.04, "QuadOut"),
			key(0.9, 0.92, "QuadOut"),
		},
		fade = { key(0, 0), key(0.5, 0), key(0.95, 1) },
	}
end

-- Steps in: small, springing up past full size and settling, with a hop. A creature that comes
-- out of the grass starts a little below the ground (`from` below zero).
Motion.APPEAR_SECONDS = 0.35

function Motion.appear(hop: number, from: number): Track
	local s = Motion.APPEAR_SECONDS
	return {
		seconds = s,
		sy = { key(0, 0.2), key(s, 1, "BackOut") },
		up = { key(0, from), key(s * 0.45, hop, "QuadOut"), key(s, 0, "QuadIn") },
	}
end

-- Called back: shrinks away before the next one steps in.
Motion.RECALL_SECONDS = 0.2

function Motion.recall(): Track
	local s = Motion.RECALL_SECONDS
	return {
		seconds = s,
		sy = { key(0, 1), key(s, 0.05, "BackIn") },
	}
end

-- A person's squash and hop when you come near enough to talk.
function Motion.hop(): Track
	return {
		seconds = 0.5,
		sy = {
			key(0, 1),
			key(0.08, 0.9, "QuadOut"),
			key(0.22, 1.06, "QuadOut"),
			key(0.36, 0.94, "QuadIn"),
			key(0.5, 1, "BackOut"),
		},
		up = { key(0, 0), key(0.08, 0), key(0.22, 0.5, "QuadOut"), key(0.36, 0, "QuadIn") },
	}
end

-- Sinks into the ground and fades (a creature that has gone, or a faint with nothing before).
function Motion.sink(): Track
	local s = Motion.FAINT_SINK
	return {
		seconds = s,
		up = { key(0, 0), key(s, -Motion.FAINT_SINK_DEPTH, "QuadIn") },
		fade = { key(0, 0), key(s, 1) },
	}
end

-- The camera: a damped sine along the way the hit came, and a roll that is smooth noise.
-- Returns the push along the direction (in studs) at `t` seconds after the hit.
function Motion.shakePush(power: number, t: number): number
	return power * math.exp(-12 * t) * math.sin(2 * math.pi * 18 * t)
end

-- The idle breath: height and width scale at a moment. `size` slows a bigger creature down.
function Motion.breath(now: number, phase: number, size: number): (number, number)
	local rate = 2.4 / math.sqrt(math.max(0.1, size))
	local s = math.sin(now * rate + phase)
	return 1 + 0.03 * s, 1 - 0.015 * s
end

-- Turning to look at something: the angle (radians, about up) that turns a thing facing along
-- (0, -1) toward the flat direction (x, z).
function Motion.yawToward(x: number, z: number): number
	return math.atan2(-x, -z)
end

-- An angle brought into -pi..pi.
function Motion.wrapAngle(angle: number): number
	local wrapped = (angle + math.pi) % (2 * math.pi) - math.pi
	return wrapped
end

-- Moves `current` toward `target` by an eased share that does not depend on the frame rate.
function Motion.approach(current: number, target: number, rate: number, dt: number): number
	return current + (target - current) * (1 - math.exp(-rate * dt))
end

return Motion
