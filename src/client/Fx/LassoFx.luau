--!strict
-- The lasso in the world: a chunky toy rope, cream and brown in stripes, built from a chain of
-- small blocks along a curve, with a loop of blocks at its end. It flies from the player's side,
-- opens over the foe, drops over it and cinches; it can tug, slip off, snap, or pull tight.
-- Display only: the server already decided the throw. Everything is made on the player's own
-- device inside the battle stage's folder, so closing the battle removes it, and every step stops
-- by itself if that folder has gone.

local BattleStage = require(script.Parent.Parent.BattleView.BattleStage)
local Sfx = require(script.Parent.Parent.Audio.Sfx)

local LassoFx = {}

export type Release = "slip" | "snap"

export type Fx = {
	throw: (from: number, to: number, seconds: number) -> (), -- flies, opens, drops, cinches
	tug: (seconds: number) -> (), -- the rope pulls taut and the loop is dragged toward the player
	tighten: (seconds: number) -> (), -- the last cinch, glowing gold
	release: (how: Release, seconds: number) -> (), -- the loop comes off and the rope falls away
	fadeOut: (seconds: number) -> (), -- the rope and loop melt away
	clear: () -> (),
}

local ROPE_SEGMENTS = 14
local LOOP_SEGMENTS = 14
local ROPE_THICK = 0.3
local LOOP_THICK = 0.38
local CREAM = Color3.fromRGB(238, 218, 172)
local BROWN = Color3.fromRGB(176, 128, 76)
local GOLD = Color3.fromRGB(255, 206, 84)

local function ease(alpha: number): number
	return alpha * alpha * (3 - 2 * alpha)
end

-- Lays a block so it runs from one point to another.
local function lay(part: Part, from: Vector3, to: Vector3, thick: number)
	local length = (to - from).Magnitude
	if length < 0.001 then
		part.Size = Vector3.new(thick, thick, 0.05)
		part.CFrame = CFrame.new(from)
		return
	end
	part.Size = Vector3.new(thick, thick, length + thick * 0.35)
	part.CFrame = CFrame.lookAt(from, to) * CFrame.new(0, 0, -length / 2)
end

function LassoFx.new(stage: BattleStage.Stage, pace: () -> number): Fx
	local folder: Folder? = nil
	local ropeParts: { Part } = {}
	local loopParts: { Part } = {}
	-- Where everything is now.
	local hand = Vector3.zero
	local centre = Vector3.zero
	local radius = 2
	local tilt = CFrame.new()
	local sag = 0 -- how far the rope hangs in the middle, in studs
	local wave = 0 -- a side to side ripple along the rope, in studs
	local ripple = 0 -- which way the ripple runs
	local bodyRadius = 2 -- how wide the creature is, for the loop that fits it

	local function block(colour: Color3, thick: number): Part
		local made = Instance.new("Part")
		made.Name = "LassoPiece"
		made.Anchored = true
		made.CanCollide = false
		made.CanQuery = false
		made.CanTouch = false
		made.CastShadow = false
		made.Material = Enum.Material.SmoothPlastic
		made.Color = colour
		made.Size = Vector3.new(thick, thick, 0.2)
		made.Parent = folder
		return made
	end

	local function alive(): boolean
		local held = folder
		return held ~= nil and held.Parent ~= nil
	end

	local function ensure(): boolean
		if alive() then
			return true
		end
		local parent = stage.effects()
		if not parent then
			return false
		end
		local made = Instance.new("Folder")
		made.Name = "Lasso"
		made.Parent = parent
		folder = made
		ropeParts, loopParts = {}, {}
		for index = 1, ROPE_SEGMENTS do
			table.insert(ropeParts, block(if index % 2 == 0 then CREAM else BROWN, ROPE_THICK))
		end
		for index = 1, LOOP_SEGMENTS do
			table.insert(loopParts, block(if index % 2 == 0 then CREAM else BROWN, LOOP_THICK))
		end
		return true
	end

	local function ringPoint(index: number): Vector3
		local angle = index / LOOP_SEGMENTS * math.pi * 2
		return centre
			+ tilt:VectorToWorldSpace(Vector3.new(math.cos(angle), 0, math.sin(angle)) * radius)
	end

	local function draw()
		if not alive() then
			return
		end
		for index, part in loopParts do
			lay(part, ringPoint(index - 1), ringPoint(index), LOOP_THICK)
		end
		-- The rope runs from the hand to the nearest point of the loop.
		local toHand = Vector3.new(hand.X - centre.X, 0, hand.Z - centre.Z)
		local near = if toHand.Magnitude > 0.1 then toHand.Unit else Vector3.zAxis
		local tie = centre + tilt:VectorToWorldSpace(near * radius)
		local across = (tie - hand):Cross(Vector3.yAxis)
		across = if across.Magnitude > 0.01 then across.Unit else Vector3.xAxis
		local last = hand
		for index, part in ropeParts do
			local t = index / ROPE_SEGMENTS
			local point = hand:Lerp(tie, t)
				- Vector3.yAxis * sag * 4 * t * (1 - t)
				+ across * (math.sin(t * math.pi * 3 + ripple) * wave * math.sin(t * math.pi))
			lay(part, last, point, ROPE_THICK)
			last = point
		end
	end

	local function fade(alpha: number)
		for _, part in ropeParts do
			part.Transparency = alpha
		end
		for _, part in loopParts do
			part.Transparency = alpha
		end
	end

	-- Runs `step` with 0 to 1 over the time, once a frame, drawing after each. Slow and quick
	-- settings, and a hurrying tap, shorten it through `pace`.
	local function animate(seconds: number, step: (alpha: number) -> ())
		local began = os.clock()
		local length = math.max(0.03, seconds * pace())
		local alpha = 0
		while alpha < 1 do
			alpha = math.min(1, (os.clock() - began) / length)
			if not alive() then
				return
			end
			step(alpha)
			draw()
			if alpha < 1 then
				task.wait()
			end
		end
	end

	local function throw(from: number, to: number, seconds: number)
		if not ensure() then
			return
		end
		local across = stage.facing(from):Cross(Vector3.yAxis)
		hand = stage.anchor(from) + across * 3 + Vector3.yAxis * 0.5
		local target = stage.anchor(to)
		local height = target.Y - stage.ground(to).Y
		bodyRadius = math.max(1.3, height * 0.5 + 0.4)
		local above = target + Vector3.yAxis * 3.8
		ripple = 0
		fade(0)
		Sfx.play("throw")
		-- The flight: the loop is small and spinning, and the rope whips behind it.
		animate(seconds * 0.5, function(alpha: number)
			centre = hand:Lerp(above, ease(alpha)) + Vector3.yAxis * (5 * 4 * alpha * (1 - alpha))
			radius = 0.5 + (bodyRadius * 1.5 - 0.5) * ease(alpha)
			tilt = CFrame.Angles(math.rad(55 * (1 - alpha)), alpha * math.pi * 4, 0)
			sag = 2.2 * (1 - alpha) + 0.4
			wave = 0.9 * (1 - alpha)
			ripple = alpha * 9
		end)
		-- The drop: the open loop settles over the creature.
		local top = centre
		local waist = target - Vector3.yAxis * 0.1
		local wide = radius
		animate(seconds * 0.3, function(alpha: number)
			centre = top:Lerp(waist, ease(alpha))
			radius = wide + (bodyRadius * 1.15 - wide) * ease(alpha)
			tilt = CFrame.new()
			sag = 0.4 + 0.5 * alpha
			wave = 0
		end)
		-- The cinch: it pulls in snug with a snap.
		Sfx.play("cinch")
		local open = radius
		animate(seconds * 0.2, function(alpha: number)
			local snug = open + (bodyRadius * 0.72 - open) * ease(alpha)
			radius = snug
			sag = 0.9 - 0.7 * alpha
		end)
	end

	local function tug(seconds: number)
		if not alive() then
			return
		end
		Sfx.play("tug")
		local home = centre
		local toHand = Vector3.new(hand.X - home.X, 0, hand.Z - home.Z)
		local pull = if toHand.Magnitude > 0.1 then toHand.Unit else Vector3.zAxis
		local snug = radius
		animate(seconds, function(alpha: number)
			local pulse = math.sin(alpha * math.pi)
			centre = home + pull * 0.9 * pulse
			radius = snug * (1 - 0.1 * pulse)
			sag = 0.2 * (1 - pulse)
			wave = 0.35 * math.sin(alpha * math.pi * 2) * (1 - alpha)
			ripple = alpha * 12
		end)
		centre, radius, sag, wave = home, snug, 0.2, 0
		draw()
	end

	local function tighten(seconds: number)
		if not alive() then
			return
		end
		Sfx.play("cinch")
		for _, part in loopParts do
			part.Material = Enum.Material.Neon
			part.Color = GOLD
		end
		for _, part in ropeParts do
			part.Color = part.Color:Lerp(GOLD, 0.4)
		end
		local start = radius
		animate(seconds, function(alpha: number)
			radius = start + (bodyRadius * 0.45 - start) * ease(alpha)
			sag = 0
		end)
	end

	local function release(how: Release, seconds: number)
		if not alive() then
			return
		end
		Sfx.play(if how == "slip" then "slip" else "cinch")
		local start, from, hung = radius, centre, sag
		animate(seconds, function(alpha: number)
			local out = ease(alpha)
			-- The loop opens and rides up and off; the rope goes slack and swings.
			radius = start + (bodyRadius * (if how == "slip" then 1.6 else 2.2) - start) * out
			centre = from + Vector3.yAxis * (if how == "slip" then 3.5 else 1.5) * out
			sag = hung + (if how == "slip" then 1.8 else 4.5) * out
			wave = 0.6 * math.sin(alpha * math.pi * 3) * (1 - alpha)
			ripple = alpha * 10
			if alpha > 0.5 then
				fade((alpha - 0.5) * 2)
			end
		end)
	end

	local function fadeOut(seconds: number)
		if not alive() then
			return
		end
		animate(seconds, function(alpha: number)
			fade(alpha)
		end)
	end

	local function clear()
		local had = folder
		folder = nil
		ropeParts, loopParts = {}, {}
		if had then
			had:Destroy()
		end
	end

	return {
		throw = throw,
		tug = tug,
		tighten = tighten,
		release = release,
		fadeOut = fadeOut,
		clear = clear,
	}
end

return LassoFx
