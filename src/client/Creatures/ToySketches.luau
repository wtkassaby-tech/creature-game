--!strict
-- What each creature looks like as a toy body: a list of rounded pieces with a place, a size
-- and a colour. Each sketch follows the "Look" written at the top of that species' file in
-- src/content/species_data. A species without a sketch of its own gets a plain body for its
-- body plan in the colour of its type, so nothing is ever missing.
-- Measured in studs for a creature of size 1, standing on the origin and facing -Z (forward).
-- Data and small helpers only. TODO(art): replaced by the part meshes.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Species = require(ReplicatedStorage.content.Species)
local Types = require(ReplicatedStorage.shared.Types)

local ToySketches = {}

export type Piece = {
	shape: "ball" | "cylinder" | "wedge",
	size: Vector3,
	at: CFrame,
	colour: Color3,
	material: Enum.Material?,
	transparency: number?,
	role: ("eye" | "lid")?, -- eyes hide and lids show for the instant of a blink
}

type Pen = {
	pieces: { Piece },
	ball: (sx: number, sy: number, sz: number, x: number, y: number, z: number, c: Color3) -> Piece,
	rod: (length: number, thick: number, at: CFrame, c: Color3) -> Piece,
	eyes: (spread: number, y: number, z: number, size: number, iris: Color3?) -> (),
	smile: (y: number, z: number, width: number) -> (),
	cheeks: (spread: number, y: number, z: number, c: Color3) -> (),
	both: (draw: (side: number) -> ()) -> (),
}

local function rgb(r: number, g: number, b: number): Color3
	return Color3.fromRGB(r, g, b)
end

local INK = rgb(28, 26, 34)
local WHITE = rgb(255, 255, 255)
local BLUSH = rgb(255, 150, 150)

local function pen(): Pen
	local pieces: { Piece } = {}
	local function add(piece: Piece): Piece
		table.insert(pieces, piece)
		return piece
	end
	local function ball(sx, sy, sz, x, y, z, c): Piece
		return add({
			shape = "ball",
			size = Vector3.new(sx, sy, sz),
			at = CFrame.new(x, y, z),
			colour = c,
		})
	end
	local function both(draw: (side: number) -> ())
		draw(-1)
		draw(1)
	end
	return {
		pieces = pieces,
		ball = ball,
		-- A cylinder lies along its own X axis; `at` should turn it the way it is wanted.
		rod = function(length, thick, at, c): Piece
			return add({
				shape = "cylinder",
				size = Vector3.new(length, thick, thick),
				at = at,
				colour = c,
			})
		end,
		-- Two eyes on the front of the head: white, a dark iris, a small glint, and a lid that
		-- shows only while it blinks. The glint is what makes them look alive.
		eyes = function(spread, y, z, size, iris)
			both(function(side)
				local x = side * spread
				ball(size, size * 1.1, size * 0.6, x, y, z, WHITE).role = "eye"
				local dark =
					ball(size * 0.6, size * 0.7, size * 0.4, x, y, z - size * 0.22, iris or INK)
				dark.role = "eye"
				local glint = ball(
					size * 0.22,
					size * 0.22,
					size * 0.2,
					x - size * 0.12,
					y + size * 0.16,
					z - size * 0.4,
					WHITE
				)
				glint.role = "eye"
				glint.material = Enum.Material.Neon
				ball(size * 0.9, size * 0.14, size * 0.5, x, y, z - size * 0.1, INK).role = "lid"
			end)
		end,
		smile = function(y, z, width)
			ball(width, width * 0.22, 0.3, 0, y, z, INK)
		end,
		cheeks = function(spread, y, z, c)
			both(function(side)
				ball(0.55, 0.4, 0.2, side * spread, y, z, c)
			end)
		end,
		both = both,
	}
end

local function turned(x: number, y: number, z: number, rx: number, ry: number, rz: number): CFrame
	return CFrame.new(x, y, z) * CFrame.Angles(math.rad(rx), math.rad(ry), math.rad(rz))
end

local UPRIGHT = CFrame.Angles(0, 0, math.rad(90)) -- stands a rod on its end

local sketches: { [string]: (p: Pen) -> () } = {}

-- Mossmitt: a cheerful little brawler whose fists are two huge balls of moss.
sketches.Mossmitt = function(p)
	local grey, moss, bark, deep =
		rgb(170, 172, 168), rgb(96, 170, 72), rgb(122, 88, 60), rgb(64, 128, 52)
	p.ball(3.2, 3.3, 3, 0, 2.5, 0.1, bark) -- pear body, bark back
	p.ball(2.5, 2.5, 1.4, 0, 2.3, -0.95, moss) -- moss belly
	p.ball(3.1, 2.8, 2.9, 0, 5, 0, grey) -- pebble head
	p.eyes(0.72, 5.25, -1.3, 0.9)
	p.smile(4.45, -1.4, 1.3)
	p.cheeks(1.15, 4.7, -1.2, BLUSH)
	p.ball(0.7, 0.7, 0.7, 0, 6.6, 0, deep) -- clover tuft
	p.ball(0.6, 0.6, 0.6, -0.45, 6.4, 0.1, moss)
	p.ball(0.6, 0.6, 0.6, 0.45, 6.4, 0.1, moss)
	p.both(function(side)
		p.ball(0.9, 1.2, 0.9, side * 1.9, 3.4, -0.2, bark) -- short arm
		p.ball(2, 2, 2, side * 2.4, 2.5, -0.8, moss) -- the mitt
		p.ball(0.7, 0.7, 0.7, side * 2.9, 3.1, -1.3, deep)
		p.ball(1.4, 0.8, 1.8, side * 0.9, 0.4, -0.3, bark) -- flat round foot
	end)
	p.ball(0.8, 0.8, 0.8, 0, 2.2, 1.7, deep) -- fern curl of a tail
	p.ball(0.6, 0.6, 0.6, 0, 2.9, 2.1, moss)
	p.ball(0.45, 0.45, 0.45, 0, 3.4, 1.8, moss)
end

-- Sloshcalf: a gentle, round calf that carries a little pond in a clear bubble on its back.
sketches.Sloshcalf = function(p)
	local hide, pale, pad, stone, hoof =
		rgb(120, 158, 196),
		rgb(196, 220, 236),
		rgb(92, 170, 96),
		rgb(180, 180, 176),
		rgb(74, 104, 140)
	p.ball(3.5, 3, 4.6, 0, 2.6, 0.4, hide) -- plump body
	p.ball(2.6, 1.6, 3.4, 0, 1.7, 0.3, pale) -- belly
	local pond = p.ball(2.7, 2.3, 2.9, 0, 4.2, 0.7, rgb(150, 215, 245)) -- the pond on its back
	pond.material, pond.transparency = Enum.Material.Glass, 0.45
	p.ball(0.9, 0.2, 0.6, 0.2, 4.4, 0.6, pad) -- one floating leaf
	p.ball(2.9, 2.6, 2.7, 0, 3.7, -2.5, hide) -- broad calf head
	p.ball(1.8, 1.3, 1.2, 0, 3.1, -3.7, pale) -- soft blunt nose
	p.ball(0.22, 0.3, 0.2, -0.35, 3.2, -4.25, INK)
	p.ball(0.22, 0.3, 0.2, 0.35, 3.2, -4.25, INK)
	p.eyes(0.85, 4.05, -3.6, 0.85)
	p.cheeks(1.25, 3.4, -3.45, BLUSH)
	p.both(function(side)
		local ear = p.ball(1.7, 0.3, 1.2, side * 1.9, 4.3, -2.3, pad) -- lily-pad ear
		ear.at = turned(side * 1.9, 4.3, -2.3, 0, 0, side * -25)
		p.ball(0.45, 0.6, 0.45, side * 0.6, 5.05, -2.5, stone) -- river-stone horn nub
		p.ball(1.1, 1.8, 1.1, side * 1.15, 0.9, -1.3, hide) -- front leg
		p.ball(1.3, 0.6, 1.5, side * 1.15, 0.3, -1.45, hoof)
		p.ball(1.1, 1.9, 1.1, side * 1.15, 0.95, 1.9, hide) -- hind leg
		p.ball(1.3, 0.6, 1.5, side * 1.15, 0.3, 1.8, hoof)
	end)
	p.ball(0.5, 0.5, 1.2, 0, 3, 2.9, hide) -- short tail
	p.ball(0.9, 1.1, 0.5, 0, 3.2, 3.5, pad) -- a tuft like reeds
end

-- Spadesnout: a stocky riverbank digger that shovels with its flat snout.
sketches.Spadesnout = function(p)
	local ochre, belly, plate, trowel, claw =
		rgb(206, 158, 84),
		rgb(236, 208, 150),
		rgb(170, 122, 72),
		rgb(132, 118, 104),
		rgb(240, 232, 214)
	p.ball(3.8, 2.6, 4.8, 0, 2, 0.5, ochre) -- low, muscled body
	p.ball(2.8, 1.4, 3.6, 0, 1.3, 0.4, belly)
	for index = 0, 2 do
		p.ball(1.7, 0.5, 1, 0, 3.3 - index * 0.12, -0.6 + index * 1.15, plate) -- back plates
	end
	p.ball(2.9, 2.3, 2.6, 0, 2.5, -2.6, ochre) -- head
	p.ball(3.2, 0.7, 2.3, 0, 1.75, -4, trowel) -- the spade snout
	p.ball(1.6, 0.25, 0.5, 0, 3.4, -2.6, plate) -- two darker stripes
	p.ball(1.3, 0.25, 0.5, 0, 3.55, -2, plate)
	p.eyes(0.8, 2.95, -3.6, 0.55)
	p.both(function(side)
		p.ball(0.8, 0.8, 0.5, side * 1.25, 3.3, -1.9, ochre) -- round ears, tucked back
		p.ball(1.3, 1.5, 1.3, side * 1.5, 0.8, -1.5, ochre) -- thick front leg
		for toe = -1, 1 do
			p.ball(0.3, 0.3, 0.8, side * 1.5 + toe * 0.35, 0.25, -2.2, claw) -- digging claws
		end
		p.ball(1.3, 1.4, 1.5, side * 1.5, 0.7, 2, ochre) -- hind leg, wide flat foot
	end)
	p.ball(0.9, 0.8, 1.4, 0, 2, 3.1, ochre) -- wedge of a tail
	p.ball(0.8, 0.8, 0.8, 0, 2.1, 3.9, trowel) -- pebble knob
end

-- Gorsling: a twitchy, whip-thin hedge runner shedding yellow blossom.
sketches.Gorsling = function(p)
	local green, pale, gorse, bloom =
		rgb(140, 196, 100), rgb(218, 236, 190), rgb(70, 130, 62), rgb(250, 212, 60)
	p.ball(2.2, 2.5, 4.4, 0, 3.5, 0.4, green) -- slim, deep-chested body
	p.ball(1.5, 1.3, 3.2, 0, 2.8, 0.2, pale)
	for index = 0, 3 do
		p.ball(0.4, 0.6, 0.5, 0, 4.85 - index * 0.08, -0.8 + index * 0.85, gorse) -- back spines
	end
	p.ball(1.9, 1.9, 2.1, 0, 4.9, -2.3, green) -- head
	p.ball(1.1, 1, 1.9, 0, 4.55, -3.5, green) -- long narrow snout
	p.ball(0.4, 0.35, 0.3, 0, 4.7, -4.4, INK)
	p.eyes(0.62, 5.2, -3, 0.75)
	p.both(function(side)
		local ear = p.ball(0.6, 0.6, 2, side * 0.7, 5.9, -1.3, gorse) -- swept-back gorse ear
		ear.at = turned(side * 0.7, 5.9, -1.3, 25, 0, 0)
		p.ball(0.6, 0.6, 0.6, side * 0.7, 6.4, -0.4, bloom) -- a flower at each tip
		p.rod(2.6, 0.5, turned(side * 0.6, 1.4, -1.2, 0, 0, 90), green) -- long thin front leg
		p.ball(0.6, 0.4, 0.8, side * 0.6, 0.2, -1.3, gorse)
		p.rod(2.8, 0.55, turned(side * 0.7, 1.5, 1.9, 0, 0, 90), gorse) -- springy hind leg
		p.ball(0.6, 0.4, 0.9, side * 0.7, 0.2, 1.8, gorse)
	end)
	p.rod(2, 0.3, turned(0, 4.2, 3.3, 0, 90, 30), green) -- long thin tail
	p.ball(1.1, 1.1, 1.1, 0, 4.9, 4.2, bloom) -- a puff of gorse flowers
end

-- Stumpwarden: a squat, patient guardian that plants itself like a living tree stump.
sketches.Stumpwarden = function(p)
	local bark, ring, moss, fungus, root =
		rgb(120, 86, 58), rgb(214, 184, 140), rgb(84, 150, 70), rgb(222, 196, 150), rgb(92, 66, 46)
	p.rod(3.4, 3.7, CFrame.new(0, 2.3, 0) * UPRIGHT, bark) -- barrel of a stump
	p.rod(0.2, 2.2, turned(0, 2.3, -1.85, 0, 90, 0), ring) -- growth rings on the chest
	p.rod(0.22, 1.2, turned(0, 2.3, -1.9, 0, 90, 0), bark)
	p.ball(4.2, 0.9, 4.2, 0, 4, 0, moss) -- collar of moss
	p.ball(3.1, 1.9, 2.9, 0, 4.7, -0.1, bark) -- low, wide head
	p.ball(3.4, 0.45, 1.7, 0, 5.25, -1, fungus) -- bracket-fungus visor
	p.eyes(0.75, 4.75, -1.4, 0.6, rgb(120, 255, 130))
	p.ball(0.5, 0.9, 0.5, -0.5, 5.9, 0.2, moss) -- crown of new shoots
	p.ball(0.5, 1.1, 0.5, 0.3, 6, 0, moss)
	p.both(function(side)
		p.ball(1.5, 2.6, 1.5, side * 2.4, 2.6, -0.2, root) -- club arm of gnarled root
		p.ball(1.6, 1.3, 1.6, side * 2.5, 1.4, -0.4, bark)
		p.ball(1.7, 1, 2, side * 1, 0.5, -0.2, root) -- splayed root toes
	end)
	p.ball(1, 0.8, 1.6, 0, 0.5, 2.1, root) -- stubby root tail
end

-- A plain body for a species with no sketch yet: its body plan, in the colour of its type.
local ELEMENT_COLOURS: Types.ByElement<Color3> = {
	Leaf = rgb(96, 176, 84),
	Sand = rgb(206, 164, 96),
	Water = rgb(86, 156, 232),
	Toxic = rgb(160, 104, 208),
	Frost = rgb(132, 208, 224),
	Crystal = rgb(232, 120, 164),
	Fire = rgb(236, 120, 72),
	Storm = rgb(224, 184, 60),
	Arcane = rgb(128, 138, 216),
	Cosmic = rgb(104, 90, 184),
}

local function plain(p: Pen, plan: string, element: Types.Element)
	local main = ELEMENT_COLOURS[element]
	local pale = main:Lerp(WHITE, 0.55)
	local deep = main:Lerp(INK, 0.35)
	if plan == "Quad" then
		p.ball(3.2, 2.8, 4.4, 0, 2.5, 0.4, main)
		p.ball(2.3, 1.5, 3.2, 0, 1.7, 0.3, pale)
		p.ball(2.6, 2.4, 2.5, 0, 3.6, -2.4, main)
		p.eyes(0.75, 3.95, -3.4, 0.8)
		p.smile(3.15, -3.55, 0.9)
		p.both(function(side)
			p.ball(0.8, 1.2, 0.5, side * 1, 5, -2.1, deep)
			p.ball(1.1, 1.7, 1.1, side * 1.1, 0.85, -1.2, deep)
			p.ball(1.1, 1.7, 1.1, side * 1.1, 0.85, 1.8, deep)
		end)
		p.ball(0.7, 0.7, 1.4, 0, 3, 2.9, deep)
	elseif plan == "Serpent" then
		for index = 0, 4 do
			local width = 2.4 - index * 0.35
			p.ball(
				width,
				width,
				2,
				0,
				width / 2,
				index * 1.5,
				if index % 2 == 0 then main else deep
			)
		end
		p.ball(2.6, 2.3, 2.6, 0, 2.6, -1.4, main)
		p.eyes(0.75, 3, -2.4, 0.8)
		p.smile(2.2, -2.6, 0.9)
	else -- Biped and Winged
		p.ball(3, 3.2, 2.8, 0, 2.5, 0, main)
		p.ball(2.2, 2.2, 1.2, 0, 2.3, -0.95, pale)
		p.ball(2.8, 2.6, 2.7, 0, 4.9, 0, main)
		p.eyes(0.7, 5.15, -1.2, 0.85)
		p.smile(4.4, -1.3, 1)
		p.both(function(side)
			if plan == "Winged" then
				local wing = p.ball(0.4, 2.2, 2.6, side * 1.9, 3.4, 0.4, deep)
				wing.at = turned(side * 1.9, 3.4, 0.4, 0, 0, side * -20)
			else
				p.ball(1, 1.8, 1, side * 1.9, 2.8, -0.2, deep)
			end
			p.ball(0.7, 1, 0.5, side * 0.9, 6.2, 0, deep)
			p.ball(1.3, 0.8, 1.7, side * 0.85, 0.4, -0.3, deep)
		end)
		p.ball(0.8, 0.8, 1.2, 0, 2, 1.7, deep)
	end
end

-- The pieces for a species. `element` colours a species that has no sketch of its own.
function ToySketches.sketch(species: string, element: Types.Element): { Piece }
	local p = pen()
	local draw = sketches[species]
	if draw then
		draw(p)
	else
		local def = Species[species]
		plain(p, if def then def.bodyPlan else "Biped", element)
	end
	return p.pieces
end

return ToySketches
