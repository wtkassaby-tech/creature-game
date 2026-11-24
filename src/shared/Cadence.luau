--!strict
-- Two tiny pure checks the client uses to keep looks and sounds from firing too often or in the
-- wrong place. No Roblox calls.

local Cadence = {}

-- True when at least `gap` seconds have passed since `last` (a time of -infinity or nil-like
-- very old value always passes).
function Cadence.ready(last: number, now: number, gap: number): boolean
	return now - last >= gap
end

-- Whether the point (x, z) is inside a flat disc centred at (cx, cz) with the given radius.
function Cadence.inDisc(x: number, z: number, cx: number, cz: number, radius: number): boolean
	local dx, dz = x - cx, z - cz
	return dx * dx + dz * dz <= radius * radius
end

return Cadence
