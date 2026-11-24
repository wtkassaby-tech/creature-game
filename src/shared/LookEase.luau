--!strict
-- The timing of a story camera look: how far the camera has turned toward a landmark (0 is the
-- ordinary camera, 1 is fully turned), moved a little each frame. Pure, so Lune can test it.

local LookEase = {}

-- Moves `alpha` toward 1 (while `holding`) or 0 (when not), taking `seconds` for the whole way.
function LookEase.advance(alpha: number, dt: number, holding: boolean, seconds: number): number
	local step = if seconds <= 0 then 1 else dt / seconds
	if holding then
		return math.min(1, alpha + step)
	end
	return math.max(0, alpha - step)
end

-- A gentle start and finish: 0 -> 0, 0.5 -> 0.5, 1 -> 1.
function LookEase.smooth(alpha: number): number
	local t = math.clamp(alpha, 0, 1)
	return t * t * (3 - 2 * t)
end

return LookEase
