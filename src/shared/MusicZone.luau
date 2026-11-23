--!strict
-- Which kind of ground a point is on, for choosing the music: "town" inside a hub's square (with
-- a margin that is wider on the way out, so standing on the edge does not flip the track), else
-- "route". Pure: no Roblox services.

export type Hub = { x: number, z: number, size: number }
export type Kind = "town" | "route"

local MusicZone = {}

-- `wasTown` is what this returned last time; it picks the wider margin to leave a town by.
function MusicZone.kindAt(
	hubs: { Hub },
	x: number,
	z: number,
	wasTown: boolean,
	enterMargin: number,
	leaveMargin: number
): Kind
	local margin = if wasTown then leaveMargin else enterMargin
	for _, hub in hubs do
		local reach = hub.size / 2 + margin
		if math.abs(x - hub.x) <= reach and math.abs(z - hub.z) <= reach then
			return "town"
		end
	end
	return "route"
end

return MusicZone
