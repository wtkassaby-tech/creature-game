--!strict
-- The short trail of where the server saw a player's character, for the finds service's two
-- movement checks: how long they have been standing at a find, and whether they moved faster than
-- a walk (a teleport). Pure and flat: the service feeds it the server's own readings and its own
-- clock, never anything the device sent. Moves the server makes itself (a Waystation, a ride)
-- reset it, so an honest player is never refused for them.

local FindsConfig = require("../config/FindsConfig")

export type Sample = { t: number, x: number, z: number }
export type Trail = { samples: { Sample } }

local FindTrail = {}

-- A step is never counted as shorter than this, so two readings taken a moment apart cannot hide
-- a jump: the speed of a long step over a tiny gap is only made bigger.
local MIN_STEP_SECONDS = 0.25

function FindTrail.new(): Trail
	return { samples = {} }
end

function FindTrail.reset(trail: Trail)
	table.clear(trail.samples)
end

-- Adds a reading. Readings must come in time order; an older one is dropped. Readings older than
-- the speed check looks back are forgotten, and the list is capped.
function FindTrail.record(trail: Trail, t: number, x: number, z: number)
	if t ~= t or x ~= x or z ~= z then
		return
	end
	local samples = trail.samples
	local last = samples[#samples]
	if last and t < last.t then
		return
	end
	table.insert(samples, { t = t, x = x, z = z })
	local keepFrom = t - math.max(FindsConfig.TRAIL_SECONDS, FindsConfig.LINGER_SECONDS) - 1
	while #samples > 1 and (samples[1].t < keepFrom or #samples > FindsConfig.TRAIL_MAX_SAMPLES) do
		table.remove(samples, 1)
	end
end

-- The fastest step, in studs a second, between readings in the last TRAIL_SECONDS before `now`.
function FindTrail.fastest(trail: Trail, now: number): number
	local best = 0
	local samples = trail.samples
	for index = 2, #samples do
		local a, b = samples[index - 1], samples[index]
		if b.t >= now - FindsConfig.TRAIL_SECONDS then
			local gap = math.max(b.t - a.t, MIN_STEP_SECONDS)
			local speed = math.sqrt((b.x - a.x) ^ 2 + (b.z - a.z) ^ 2) / gap
			best = math.max(best, speed)
		end
	end
	return best
end

-- How long the character has been inside `radius` of a point without leaving, up to the newest
-- reading. 0 if the newest reading is outside.
function FindTrail.lingered(trail: Trail, x: number, z: number, radius: number): number
	local samples = trail.samples
	local newest = samples[#samples]
	if not newest then
		return 0
	end
	local first = newest.t
	for index = #samples, 1, -1 do
		local sample = samples[index]
		if (sample.x - x) ^ 2 + (sample.z - z) ^ 2 > radius ^ 2 then
			if index == #samples then
				return 0
			end
			break
		end
		first = sample.t
	end
	return newest.t - first
end

return FindTrail
