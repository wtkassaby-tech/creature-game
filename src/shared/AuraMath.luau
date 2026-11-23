--!strict
-- The maths of an aura's slow motion, as pure functions of time (no Roblox services, so they are
-- unit-tested under Lune). Looks only. `phase` (radians) keeps two auras from moving in step.

local AuraMath = {}

local TWO_PI = math.pi * 2

-- Height above rest, from 0 up to 2 x amplitude: it hovers, it never sinks below its footing.
function AuraMath.hoverOffset(
	time: number,
	phase: number,
	amplitude: number,
	period: number
): number
	if period <= 0 then
		return 0
	end
	return amplitude * (1 + math.sin(TWO_PI * time / period + phase))
end

-- Yaw in radians, swinging either side of straight ahead.
function AuraMath.swayYaw(time: number, phase: number, degrees: number, period: number): number
	if period <= 0 then
		return 0
	end
	return math.rad(degrees) * math.sin(TWO_PI * time / period + phase)
end

-- Brightness multiplier: 1 at rest, breathing between 1 - depth and 1 + depth.
function AuraMath.pulse(time: number, phase: number, depth: number, period: number): number
	if period <= 0 then
		return 1
	end
	return 1 + depth * math.sin(TWO_PI * time / period + phase)
end

-- True when an aura should run: near enough to the camera.
function AuraMath.inRange(distance: number, far: number): boolean
	return distance <= far
end

-- Live particles an emitter can hold at once: births per second times the longest life.
function AuraMath.liveParticles(rate: number, longestLife: number): number
	return rate * longestLife
end

return AuraMath
