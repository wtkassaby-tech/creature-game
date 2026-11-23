--!strict
-- The effects of a battle, built from the presets in Particles: a shot from attacker to target
-- for each element, an impact burst sized by how hard it hit, and the faint, switch-in, catch,
-- level-up and heal effects. Everything is made on the player's own device, inside the battle
-- stage's folder, so it is gone when the battle closes. Looks only: the server decided what
-- happened; this only dresses it, and its randomness is Random.new() on the device.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BattleStage = require(script.Parent.Parent.BattleView.BattleStage)
local Particles = require(script.Parent.Particles)
local Types = require(ReplicatedStorage.shared.Types)

local MoveFx = {}

export type Strength = "strong" | "normal" | "weak"

export type Fx = {
	cast: (from: number, to: number, element: Types.Element, seconds: number) -> number,
	impact: (side: number, element: Types.Element, strength: Strength) -> (),
	puff: (side: number, element: Types.Element) -> (),
	heal: (side: number) -> (),
	faint: (side: number, element: Types.Element) -> (),
	switchIn: (side: number, element: Types.Element) -> (),
	caught: (side: number) -> (),
	levelUp: (side: number) -> (),
}

type Piece = { kind: Particles.Kind, count: number, colour: Color3? }

type Look = {
	colour: Color3, -- the element's main colour
	accent: Color3, -- a second colour for the core of the burst
	trail: Particles.Kind,
	rate: number, -- trail particles a second
	arc: number, -- how high the shot lifts in the middle, in studs
	wobble: number, -- how far the shot weaves from side to side
	weaves: number, -- how many times it weaves on the way
	spiral: boolean, -- weaves in a corkscrew rather than side to side
	impact: { Piece },
}

local GOLD = Color3.fromRGB(255, 206, 84)
local GREEN = Color3.fromRGB(120, 230, 110)
local GREY = Color3.fromRGB(150, 150, 156)
local WHITE = Color3.new(1, 1, 1)
local DUST = Color3.fromRGB(176, 150, 112)

-- Eleven biomes, ten elements: one look each. Colours are brighter than the type chips so they
-- glow against the scene.
local LOOKS: Types.ByElement<Look> = {
	Leaf = {
		colour = Color3.fromRGB(108, 214, 90),
		accent = Color3.fromRGB(214, 255, 150),
		trail = "leafFlutter",
		rate = 34,
		arc = 2,
		wobble = 1.2,
		weaves = 3,
		spiral = true,
		impact = {
			{ kind = "leafFlutter", count = 14 },
			{ kind = "glowPuff", count = 3 },
		},
	},
	Water = {
		colour = Color3.fromRGB(88, 170, 255),
		accent = Color3.fromRGB(200, 236, 255),
		trail = "droplets",
		rate = 42,
		arc = 4,
		wobble = 0,
		weaves = 0,
		spiral = false,
		impact = {
			{ kind = "droplets", count = 18 },
			{ kind = "glowPuff", count = 3 },
			{ kind = "sparkle", count = 6 },
		},
	},
	Sand = {
		colour = Color3.fromRGB(214, 170, 100),
		accent = Color3.fromRGB(240, 214, 160),
		trail = "dustKick",
		rate = 30,
		arc = 1.5,
		wobble = 0.5,
		weaves = 5,
		spiral = false,
		impact = {
			{ kind = "dustKick", count = 12, colour = DUST },
			{ kind = "droplets", count = 10, colour = Color3.fromRGB(226, 190, 128) },
		},
	},
	Toxic = {
		colour = Color3.fromRGB(176, 104, 224),
		accent = Color3.fromRGB(226, 170, 255),
		trail = "toxicBubble",
		rate = 26,
		arc = 2,
		wobble = 0.8,
		weaves = 2,
		spiral = false,
		impact = {
			{ kind = "toxicBubble", count = 12 },
			{ kind = "glowPuff", count = 3 },
		},
	},
	Frost = {
		colour = Color3.fromRGB(120, 214, 240),
		accent = Color3.fromRGB(230, 250, 255),
		trail = "sparkle",
		rate = 44,
		arc = 1,
		wobble = 0,
		weaves = 0,
		spiral = false,
		impact = {
			{ kind = "starBurst", count = 10 },
			{ kind = "sparkle", count = 8 },
			{ kind = "glowPuff", count = 2 },
		},
	},
	Crystal = {
		colour = Color3.fromRGB(255, 130, 180),
		accent = Color3.fromRGB(255, 214, 232),
		trail = "sparkle",
		rate = 48,
		arc = 1.5,
		wobble = 0.6,
		weaves = 3,
		spiral = true,
		impact = {
			{ kind = "starBurst", count = 12 },
			{ kind = "sparkle", count = 8 },
		},
	},
	Fire = {
		colour = Color3.fromRGB(255, 130, 60),
		accent = Color3.fromRGB(255, 220, 130),
		trail = "flame",
		rate = 30,
		arc = 1,
		wobble = 0.3,
		weaves = 4,
		spiral = false,
		impact = {
			{ kind = "flame", count = 5 },
			{ kind = "ember", count = 14 },
			{ kind = "glowPuff", count = 3 },
		},
	},
	Storm = {
		colour = Color3.fromRGB(255, 220, 70),
		accent = Color3.fromRGB(255, 250, 200),
		trail = "sparkle",
		rate = 64,
		arc = 0,
		wobble = 1.4,
		weaves = 6, -- a zigzag
		spiral = false,
		impact = {
			{ kind = "starBurst", count = 12 },
			{ kind = "sparkle", count = 10 },
			{ kind = "glowPuff", count = 2 },
		},
	},
	Arcane = {
		colour = Color3.fromRGB(140, 150, 255),
		accent = Color3.fromRGB(214, 218, 255),
		trail = "glowPuff",
		rate = 28,
		arc = 2.5,
		wobble = 1.1,
		weaves = 2,
		spiral = true,
		impact = {
			{ kind = "starBurst", count = 10 },
			{ kind = "glowPuff", count = 4 },
		},
	},
	Cosmic = {
		colour = Color3.fromRGB(150, 110, 255),
		accent = Color3.fromRGB(255, 226, 255),
		trail = "sparkle",
		rate = 56,
		arc = 3,
		wobble = 1.3,
		weaves = 3,
		spiral = true,
		impact = {
			{ kind = "starBurst", count = 12 },
			{ kind = "motes", count = 8 },
			{ kind = "glowPuff", count = 3 },
		},
	},
}

local jitter = Random.new() -- which way a shot weaves first; looks only, never rules

function MoveFx.new(stage: BattleStage.Stage): Fx
	-- Where effects go: the stage's own folder, so closing the battle removes them all. Nothing
	-- is made once it is gone.
	local function where(): Instance?
		return stage.effects()
	end

	local function burst(
		side: number,
		kind: Particles.Kind,
		colour: Color3,
		count: number,
		scale: number?,
		low: boolean?,
		width: number?
	)
		local parent = where()
		if parent then
			local at = if low then stage.ground(side) + Vector3.yAxis * 0.5 else stage.anchor(side)
			Particles.burst(parent, at, kind, colour, count, scale, width)
		end
	end

	local function ring(side: number, colour: Color3, radius: number, seconds: number)
		local parent = where()
		if parent then
			Particles.ring(parent, stage.ground(side), colour, radius, seconds)
		end
	end

	-- A shot from one creature to the other. Waits for the travel time and returns how long it
	-- waited, so the caller can shorten the pause that follows. 0 seconds skips the flight.
	local function cast(from: number, to: number, element: Types.Element, seconds: number): number
		local parent = where()
		local look = LOOKS[element]
		if not parent or seconds <= 0 then
			return 0
		end
		local start = stage.anchor(from) + stage.facing(from) * 1.5
		local finish = stage.anchor(to)
		local across = (finish - start)
		local flat = Vector3.new(across.X, 0, across.Z)
		local forward = if flat.Magnitude > 0.1 then flat.Unit else Vector3.zAxis
		local side = forward:Cross(Vector3.yAxis)
		local flip = if jitter:NextNumber() < 0.5 then -1 else 1
		local shot = Particles.stream(parent, start, look.trail, look.colour, look.rate)
		-- A bright core travels with the trail, so the shot reads as a thing and not just a smear.
		local core = Particles.emitter(shot, "glowPuff", look.accent, 0.5)
		core.Rate = 24
		core.Speed = NumberRange.new(0, 0.5)
		core.Enabled = true
		local began = os.clock()
		local alpha = 0
		while alpha < 1 do
			alpha = math.min(1, (os.clock() - began) / seconds)
			if not where() then
				return alpha * seconds
			end
			local at = start:Lerp(finish, alpha)
			local lift = Vector3.yAxis * look.arc * 4 * alpha * (1 - alpha)
			local phase = alpha * math.pi * look.weaves
			local sway = math.sin(phase) * look.wobble * flip * math.sin(alpha * math.pi)
			local offset = side * sway
			if look.spiral then
				offset += Vector3.yAxis * math.cos(phase) * look.wobble * 0.7 * math.sin(
					alpha * math.pi
				)
			end
			shot.CFrame = CFrame.new(at + lift + offset)
			if alpha < 1 then
				task.wait()
			end
		end
		Particles.stop(shot, look.trail)
		return seconds
	end

	local function impact(side: number, element: Types.Element, strength: Strength)
		if strength == "weak" then
			-- A resisted hit barely lands: a small grey puff and nothing else.
			burst(side, "smokePuff", GREY, 4, 0.7)
			return
		end
		local look = LOOKS[element]
		local big = strength == "strong"
		local more = if big then 2 else 1
		local scale = if big then 1.5 else 1
		for _, piece in look.impact do
			burst(side, piece.kind, piece.colour or look.colour, piece.count * more, scale)
		end
		burst(side, "glowPuff", look.accent, if big then 5 else 2, if big then 1.4 else 0.8)
		if big then
			burst(side, "starBurst", WHITE, 10, 1.2)
			ring(side, look.colour, 7, 0.5)
		end
	end

	-- A status move or poison: a soft glow of the element's colour over the creature.
	local function puff(side: number, element: Types.Element)
		local look = LOOKS[element]
		burst(side, "glowPuff", look.colour, 4, 1)
		burst(side, look.impact[1].kind, look.colour, 6, 0.8)
	end

	local function heal(side: number)
		burst(side, "motes", GREEN, 14, 1, true, 4)
		burst(side, "sparkle", GOLD, 5, 0.8)
	end

	local function faint(side: number, element: Types.Element)
		local look = LOOKS[element]
		burst(side, "dustKick", DUST, 14, 1.2, true, 3)
		burst(side, "smokePuff", GREY, 5, 1.3, true)
		burst(side, "motes", look.accent, 12, 1, true, 4)
		task.delay(0.25, function()
			burst(side, "motes", WHITE, 8, 1, true, 4)
		end)
	end

	local function switchIn(side: number, element: Types.Element)
		local look = LOOKS[element]
		burst(side, "glowPuff", look.colour, 6, 1.3)
		burst(side, "sparkle", look.accent, 14, 1)
		ring(side, look.colour, 6, 0.5)
	end

	local function caught(side: number)
		burst(side, "starBurst", GOLD, 22, 1.4)
		burst(side, "sparkle", WHITE, 14, 1)
		ring(side, GOLD, 8, 0.6)
		task.delay(0.2, function()
			burst(side, "motes", GOLD, 14, 1.2, true, 4)
		end)
		task.delay(0.5, function()
			burst(side, "starBurst", GOLD, 8, 0.9)
		end)
	end

	local function levelUp(side: number)
		ring(side, GREEN, 6, 0.6)
		for pulse = 0, 2 do
			task.delay(pulse * 0.35, function()
				burst(side, "motes", GREEN, 12, 1.1, true, 4)
				burst(side, "motes", GOLD, 10, 1.1, true, 4)
			end)
		end
	end

	return {
		cast = cast,
		impact = impact,
		puff = puff,
		heal = heal,
		faint = faint,
		switchIn = switchIn,
		caught = caught,
		levelUp = levelUp,
	}
end

return MoveFx
