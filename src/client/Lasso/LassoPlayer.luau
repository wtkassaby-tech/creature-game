--!strict
-- Plays a lasso sweep the server sent and sends the player's taps. The device's clock starts when
-- the sweep arrives; each tap is sent at once, with the time since then, so the server can stamp
-- its own arrival time on it. The server judges everything.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Lasso = require(ReplicatedStorage.shared.Lasso)

export type Wire = {
	BattleId: number,
	ThrowId: number,
	Zones: { { Centre: number, Width: number, Speed: number, StartPhase: number, StartMs: number } },
	SlowMode: boolean,
	ConnectionAssist: boolean,
	-- The best catch chance this sweep allows, in percent (wild throws only; nil for a giant), and
	-- whether the Lasso Pass is in it.
	Chance: number?,
	Boosted: boolean?,
}

export type Playing = {
	throwId: number,
	pattern: Lasso.Pattern,
	startedAt: number, -- os.clock() when the sweep arrived
	zone: number, -- the zone the next tap is for
}

local LassoPlayer = {}

function LassoPlayer.begin(wire: Wire): Playing
	local zones: { Lasso.Zone } = {}
	for _, z in wire.Zones do
		table.insert(zones, {
			centre = z.Centre,
			width = z.Width,
			speed = z.Speed,
			startPhase = z.StartPhase,
			startMs = z.StartMs,
		})
	end
	return {
		throwId = wire.ThrowId,
		pattern = {
			seed = 0,
			zones = zones,
			isGiant = false,
			slowMode = wire.SlowMode,
			connectionAssist = wire.ConnectionAssist,
			speedScale = 1,
			roundTripMs = 0,
		},
		startedAt = os.clock(),
		zone = 1,
	}
end

function LassoPlayer.elapsedMs(playing: Playing): number
	return (os.clock() - playing.startedAt) * 1000
end

-- Where the marker is now, and the zone it is for (nil when every zone has been tapped).
function LassoPlayer.marker(playing: Playing): (number?, Lasso.Zone?)
	local zone = playing.pattern.zones[playing.zone]
	if not zone then
		return nil, nil
	end
	return Lasso.markerPosition(playing.pattern, playing.zone, LassoPlayer.elapsedMs(playing)), zone
end

-- A tap: returns what to send, and moves on to the next zone. Nil once every zone is tapped.
function LassoPlayer.tap(playing: Playing): { ThrowId: number, Zone: number, ClaimMs: number }?
	if playing.zone > #playing.pattern.zones then
		return nil
	end
	local message =
		{ ThrowId = playing.throwId, Zone = playing.zone, ClaimMs = LassoPlayer.elapsedMs(playing) }
	playing.zone += 1
	return message
end

return LassoPlayer
