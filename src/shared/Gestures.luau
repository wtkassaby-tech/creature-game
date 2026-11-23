--!strict
-- Idle gestures and battle entrances as pure motion curves. A curve takes seconds since it began
-- and gives a Pose of plain numbers: an offset, a tilt and a scale of ONE mesh. Which gesture a
-- species does, and when, is data in content/SpeciesQuirks. No Roblox services, so it is
-- unit-tested under Lune (tests/gestures.test.luau). Looks only: nothing here decides a result.
--
-- A Pose maps straight onto the Roblox types the client uses:
--   offset = Vector3.new(side, up, fwd) * bodyHeight   (distances are in body heights, so a big
--                                                       creature moves further than a small one)
--   tilt   = CFrame.Angles(pitch, yaw, roll)           (radians, about the feet)
--   scale  = Vector3.new(sx, sy, sz)
-- Axes are the creature's own: `fwd` is the way it faces, `side` its right. `pitch` is negative
-- to lean forward. The shapes keep their volume (sx = sz = 1 / sqrt(sy)) unless noted.
--
-- Every gesture starts and ends at rest (zero offset and tilt, unit scale), so it can be played
-- over the breathing loop without a jump. An entrance ends at rest but begins away from it.
-- This file does its own small easing; it can move to Motion.ease later.

local Motion = require("./Motion")

local Gestures = {}

export type Pose = {
	fwd: number,
	side: number,
	up: number,
	pitch: number,
	yaw: number,
	roll: number,
	sx: number,
	sy: number,
	sz: number,
}

export type Curve = {
	seconds: number,
	isEntrance: boolean,
	at: (t: number) -> Pose,
}

Gestures.GESTURES = {
	"Hop",
	"Wiggle",
	"Spin",
	"Nod",
	"Shiver",
	"Stretch",
	"Sniff",
	"Bounce",
	"Sway",
	"Puff",
	"Peek",
	"Doze",
	"Shake",
	"Clap",
	"Tilt",
	"Gulp",
} :: { string }

Gestures.ENTRANCES = { "HopIn", "SpinIn", "PopUp", "Stomp", "SlideIn", "DropIn" } :: { string }

local PI = math.pi
local TAU = 2 * math.pi
local BACK = 1.70158

-- Easing, 0..1 to 0..1 (BackOut overshoots on the way).
local function quadIn(x: number): number
	return x * x
end
local function quadOut(x: number): number
	return 1 - (1 - x) * (1 - x)
end
local function quadInOut(x: number): number
	if x < 0.5 then
		return 2 * x * x
	end
	return 1 - 2 * (1 - x) * (1 - x)
end
local function backOut(x: number): number
	local c = x - 1
	return 1 + (BACK + 1) * c * c * c + BACK * c * c
end

-- 0 at both ends, 1 in the middle.
local function bell(p: number): number
	return math.sin(PI * p)
end
-- 0 at both ends, rises fast to a long hold of 1, and falls fast.
local function hold(p: number): number
	return math.min(1, bell(p) * 2.2)
end
-- 0 at both ends, bumps `count` times in between.
local function bumps(p: number, count: number): number
	return (1 - math.cos(TAU * count * p)) / 2
end

local function rest(): Pose
	return { fwd = 0, side = 0, up = 0, pitch = 0, yaw = 0, roll = 0, sx = 1, sy = 1, sz = 1 }
end

-- Sets the height scale and keeps the volume.
local function squash(pose: Pose, sy: number): Pose
	local width = 1 / math.sqrt(sy)
	pose.sy = sy
	pose.sx = width
	pose.sz = width
	return pose
end

local function clamp01(t: number, seconds: number): number
	return math.clamp(t / seconds, 0, 1)
end

local shapes: { [string]: { seconds: number, entrance: boolean, shape: (p: number) -> Pose } } = {}

local function add(name: string, seconds: number, entrance: boolean, shape: (p: number) -> Pose)
	shapes[name] = { seconds = seconds, entrance = entrance, shape = shape }
end

-- Gestures ---------------------------------------------------------------------------------

add("Hop", 0.8, false, function(p)
	local pose = rest()
	pose.up = 0.16 * math.abs(math.sin(TAU * p))
	return squash(pose, 1 + 0.05 * math.sin(2 * TAU * p) * bell(p))
end)

add("Wiggle", 0.7, false, function(p)
	local pose = rest()
	local swing = math.sin(2 * TAU * p) * bell(p)
	pose.roll = 0.12 * swing
	pose.side = 0.04 * swing
	return pose
end)

add("Spin", 0.9, false, function(p)
	local pose = rest()
	pose.yaw = TAU * quadInOut(p)
	pose.up = 0.08 * bell(p)
	return pose
end)

add("Nod", 1.2, false, function(p)
	local pose = rest()
	pose.pitch = -0.2 * math.abs(math.sin(TAU * p))
	pose.up = -0.02 * bumps(p, 2)
	return pose
end)

add("Shiver", 0.6, false, function(p)
	local pose = rest()
	local env = bell(p)
	pose.side = 0.025 * math.sin(15 * TAU * p) * env
	pose.roll = 0.04 * math.sin(15 * TAU * p + 1) * env
	return pose
end)

add("Stretch", 1.3, false, function(p)
	local pose = rest()
	local env = hold(p)
	pose.pitch = 0.12 * env
	return squash(pose, 1 + 0.14 * env)
end)

add("Sniff", 1.0, false, function(p)
	local pose = rest()
	pose.pitch = -0.24 * math.abs(math.sin(TAU * p)) * hold(p)
	pose.fwd = 0.05 * bell(p)
	return pose
end)

add("Bounce", 0.8, false, function(p)
	local pose = rest()
	pose.up = 0.09 * bumps(p, 2)
	return squash(pose, 1 + 0.07 * math.sin(2 * TAU * p) * bell(p))
end)

add("Sway", 1.6, false, function(p)
	local pose = rest()
	local swing = math.sin(TAU * p)
	pose.roll = 0.14 * swing
	pose.side = 0.05 * swing
	return pose
end)

add("Puff", 1.4, false, function(p)
	local env = hold(p)
	local pose = rest()
	pose.sx = 1 + 0.14 * env
	pose.sy = 1 + 0.12 * env
	pose.sz = 1 + 0.14 * env
	pose.up = 0.03 * env
	return pose
end)

add("Peek", 1.6, false, function(p)
	-- Sinks, stays low, then pops up past rest and settles.
	local sink: number
	if p < 0.3 then
		sink = quadOut(p / 0.3)
	elseif p < 0.62 then
		sink = 1
	else
		local q = (p - 0.62) / 0.38
		sink = 1 - backOut(q)
	end
	local pose = rest()
	pose.up = -0.3 * sink
	return squash(pose, 1 - 0.28 * sink)
end)

add("Doze", 3.0, false, function(p)
	local pose = rest()
	if p < 0.75 then
		local q = p / 0.75
		pose.pitch = -0.3 * quadIn(q)
		pose.up = -0.03 * quadIn(q)
	else
		local q = (p - 0.75) / 0.25
		pose.pitch = -0.3 * (1 - quadOut(q))
		pose.up = -0.03 * (1 - quadOut(q)) + 0.07 * bell(q)
	end
	return pose
end)

add("Shake", 0.7, false, function(p)
	local pose = rest()
	local env = 1 - p
	pose.yaw = 0.35 * math.sin(6 * TAU * p) * env
	pose.roll = 0.08 * math.sin(6 * TAU * p + 0.0) * math.sin(PI * p) * env * env
	pose.side = 0.03 * math.sin(6 * TAU * p) * env
	return pose
end)

add("Clap", 0.8, false, function(p)
	local pose = rest()
	return squash(pose, 1 - 0.1 * bumps(p, 2))
end)

add("Tilt", 1.6, false, function(p)
	local pose = rest()
	local env = hold(p)
	pose.roll = 0.26 * env
	pose.pitch = -0.04 * env
	return pose
end)

add("Gulp", 1.0, false, function(p)
	local pose = rest()
	return squash(pose, 1 + 0.12 * math.sin(TAU * p))
end)

-- Entrances --------------------------------------------------------------------------------

add("HopIn", 0.8, true, function(p)
	local pose = rest()
	local left = 1 - quadOut(p)
	pose.fwd = -1.2 * left
	pose.up = 0.5 * bell(p) * left
	pose.pitch = -0.12 * bell(p)
	return pose
end)

add("SpinIn", 0.9, true, function(p)
	local pose = rest()
	local grow = backOut(p)
	pose.yaw = -TAU * (1 - quadOut(p))
	local s = 0.15 + 0.85 * grow
	pose.sx = s
	pose.sy = s
	pose.sz = s
	pose.up = 0.15 * bell(p)
	return pose
end)

add("PopUp", 0.7, true, function(p)
	local pose = rest()
	local rise = backOut(math.min(p / 0.8, 1))
	pose.up = -1.0 * (1 - rise)
	return squash(pose, 1 + 0.12 * bell(p))
end)

add("Stomp", 0.8, true, function(p)
	local pose = rest()
	if p < 0.4 then
		local q = p / 0.4
		pose.up = 0.7 * (1 - quadIn(q))
		return pose
	end
	local q = (p - 0.4) / 0.6
	pose.up = 0.04 * math.sin(2 * TAU * q) * (1 - q)
	return squash(pose, 1 - 0.16 * math.cos(1.5 * PI * q) * (1 - q) * (1 - q))
end)

add("SlideIn", 0.8, true, function(p)
	local pose = rest()
	local left = 1 - quadOut(p)
	pose.side = -1.6 * left
	pose.roll = -0.16 * left
	pose.pitch = 0.1 * math.sin(TAU * p) * (1 - p)
	return pose
end)

add("DropIn", 0.8, true, function(p)
	local pose = rest()
	if p < 0.55 then
		local q = p / 0.55
		pose.up = 2.0 * (1 - quadIn(q))
		return pose
	end
	local q = (p - 0.55) / 0.45
	return squash(pose, 1 - 0.22 * bell(q))
end)

-- Public -----------------------------------------------------------------------------------

-- The curve for a gesture or entrance name, or nil for an unknown name.
function Gestures.curve(name: string): Curve?
	local entry = shapes[name]
	if entry == nil then
		return nil
	end
	local seconds = entry.seconds
	local shape = entry.shape
	return {
		seconds = seconds,
		isEntrance = entry.entrance,
		at = function(t: number): Pose
			return shape(clamp01(t, seconds))
		end,
	}
end

-- A gesture's pose as the Pose that Creatures/ToyBody plays (shared/Motion): the height scale
-- carries over and the width is the mean of sx and sz. A gesture is never see-through.
function Gestures.toMotion(pose: Pose): Motion.Pose
	return {
		fwd = pose.fwd,
		side = pose.side,
		up = pose.up,
		pitch = pose.pitch,
		roll = pose.roll,
		yaw = pose.yaw,
		sy = pose.sy,
		fade = 0,
		wide = (pose.sx + pose.sz) / 2,
	}
end

-- The curve as a function of progress 0..1 (what ToyBody's `act` takes), with the poses converted.
function Gestures.motionCurve(curve: Curve): (number) -> Motion.Pose
	return function(progress: number): Motion.Pose
		return Gestures.toMotion(curve.at(math.clamp(progress, 0, 1) * curve.seconds))
	end
end

-- Seconds before a creature's first idle gesture, and between the ones after, for a species that
-- gestures about every `every` seconds. `roll` is a number from 0 to 1 (the caller's own seeded
-- random), so the schedule is looks only and replays under a test.
function Gestures.firstIn(every: number, roll: number): number
	return every * (0.4 + 0.6 * math.clamp(roll, 0, 1))
end

function Gestures.nextIn(every: number, roll: number): number
	return every * (0.75 + 0.5 * math.clamp(roll, 0, 1))
end

function Gestures.isGesture(name: string): boolean
	return table.find(Gestures.GESTURES, name) ~= nil
end

function Gestures.isEntrance(name: string): boolean
	return table.find(Gestures.ENTRANCES, name) ~= nil
end

return Gestures
