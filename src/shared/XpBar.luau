--!strict
-- The XP bar on the result card: where the bar sits as it fills from before a battle to after,
-- across any level-ups. Pure maths over Xp.xpToNext; the card only draws what this returns.
-- A creature's xp is progress toward its next level, so each level the bar passes is one run
-- from where it started to full, then the bar empties and the next level begins.

local Xp = require("./Xp")

local XpBar = {}

export type Segment = { level: number, from: number, to: number } -- fractions of that level's bar
export type Spot = { level: number, fill: number } -- the level shown and how full its bar is

-- One segment per level the bar visits, from `levelBefore` up to `levelAfter`.
function XpBar.segments(
	levelBefore: number,
	xpBefore: number,
	levelAfter: number,
	xpAfter: number
): { Segment }
	local first = math.max(1, math.floor(levelBefore))
	local last = math.max(first, math.floor(levelAfter))
	local list: { Segment } = {}
	for level = first, last do
		local need = math.max(1, Xp.xpToNext(level))
		local from = if level == first then math.clamp(xpBefore / need, 0, 1) else 0
		local to = if level == last then math.clamp(xpAfter / need, 0, 1) else 1
		table.insert(list, { level = level, from = from, to = math.max(from, to) })
	end
	return list
end

-- Where the bar is `progress` (0 to 1) of the way through its whole fill. Each segment takes a
-- share of the time in proportion to how much bar it covers, so a level-up never rushes.
function XpBar.at(segments: { Segment }, progress: number): Spot
	local total = 0
	for _, segment in segments do
		total += segment.to - segment.from
	end
	local last = segments[#segments]
	if total <= 0 then
		return { level = last.level, fill = last.to }
	end
	local left = math.clamp(progress, 0, 1) * total
	for _, segment in segments do
		local length = segment.to - segment.from
		if left <= length or segment == last then
			local fill = segment.from + math.min(left, length)
			return { level = segment.level, fill = fill }
		end
		left -= length
	end
	return { level = last.level, fill = last.to }
end

return XpBar
