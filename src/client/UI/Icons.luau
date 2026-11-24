--!strict
-- A small icon set drawn in code (Frames, rounded corners, strokes, rotations): the ten types,
-- the coin, Prism, the Creatures paw and the Journal book, plus a down arrow. No images. Each
-- function makes a square holder `size` pixels across inside `parent` and returns it; glyphs are
-- laid out in a 0 to 1 box so they scale to any size. Looks only.

local Types = require(game:GetService("ReplicatedStorage").shared.Types)

local Icons = {}

local INK = Color3.fromRGB(46, 44, 62)
local CREAM = Color3.fromRGB(250, 243, 222)
local GOLD = Color3.fromRGB(240, 184, 40)
local GOLD_DARK = Color3.fromRGB(184, 120, 12)

local function holder(parent: Instance, size: number, position: UDim2?): Frame
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromOffset(size, size)
	frame.Position = position or UDim2.new()
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Parent = parent
	return frame
end

-- A shape placed by its centre (cx, cy) and width and height, all as shares of the holder.
local function shape(
	parent: Instance,
	cx: number,
	cy: number,
	w: number,
	h: number,
	colour: Color3,
	radius: number,
	rotation: number?
): Frame
	local frame = Instance.new("Frame")
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.fromScale(cx, cy)
	frame.Size = UDim2.fromScale(w, h)
	frame.BackgroundColor3 = colour
	frame.BorderSizePixel = 0
	frame.Rotation = rotation or 0
	frame.Parent = parent
	if radius > 0 then
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(radius, 0)
		corner.Parent = frame
	end
	return frame
end

local function ring(parent: Instance, thickness: number, colour: Color3)
	local stroke = Instance.new("UIStroke")
	stroke.Color = colour
	stroke.Thickness = thickness
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = parent
end

local function stroke(size: number): number
	return if size >= 24 then 2 else 1.5
end

-- The glyph for each type, in the type's colour on a cream disc.
local GLYPHS: { [string]: (box: Frame, colour: Color3) -> () } = {
	Leaf = function(box, colour)
		shape(box, 0.5, 0.5, 0.5, 0.5, colour, 0.3, 45)
		shape(box, 0.5, 0.52, 0.06, 0.6, CREAM, 0, 45)
	end,
	Sand = function(box, colour)
		shape(box, 0.5, 0.64, 0.66, 0.34, colour, 0.5)
		shape(box, 0.5, 0.42, 0.38, 0.3, colour, 0.5)
		shape(box, 0.5, 0.72, 0.66, 0.16, colour, 0)
	end,
	Water = function(box, colour)
		shape(box, 0.5, 0.62, 0.44, 0.44, colour, 0.5)
		shape(box, 0.5, 0.4, 0.32, 0.32, colour, 0.08, 45)
		shape(box, 0.4, 0.62, 0.1, 0.1, CREAM, 0.5)
	end,
	Toxic = function(box, colour)
		shape(box, 0.4, 0.6, 0.4, 0.4, colour, 0.5)
		shape(box, 0.68, 0.4, 0.24, 0.24, colour, 0.5)
		shape(box, 0.62, 0.72, 0.16, 0.16, colour, 0.5)
		shape(box, 0.33, 0.52, 0.1, 0.1, CREAM, 0.5)
	end,
	Frost = function(box, colour)
		for _, angle in { 0, 60, 120 } do
			shape(box, 0.5, 0.5, 0.74, 0.1, colour, 0.5, angle)
		end
		shape(box, 0.5, 0.5, 0.16, 0.16, colour, 0.5)
	end,
	Crystal = function(box, colour)
		shape(box, 0.5, 0.5, 0.46, 0.46, colour, 0.06, 45)
		shape(box, 0.5, 0.5, 0.2, 0.2, CREAM, 0.06, 45)
	end,
	Fire = function(box, colour)
		shape(box, 0.5, 0.64, 0.5, 0.5, colour, 0.5)
		shape(box, 0.5, 0.38, 0.3, 0.3, colour, 0.08, 45)
		shape(box, 0.5, 0.68, 0.22, 0.22, CREAM, 0.5)
	end,
	Storm = function(box, colour)
		shape(box, 0.56, 0.3, 0.2, 0.46, colour, 0.1, 22)
		shape(box, 0.5, 0.5, 0.42, 0.14, colour, 0.1)
		shape(box, 0.44, 0.7, 0.2, 0.46, colour, 0.1, 22)
	end,
	Arcane = function(box, colour)
		shape(box, 0.5, 0.5, 0.78, 0.12, colour, 0.5)
		shape(box, 0.5, 0.5, 0.12, 0.78, colour, 0.5)
		shape(box, 0.5, 0.5, 0.5, 0.1, colour, 0.5, 45)
		shape(box, 0.5, 0.5, 0.5, 0.1, colour, 0.5, -45)
	end,
	Cosmic = function(box, colour)
		shape(box, 0.46, 0.5, 0.62, 0.62, colour, 0.5)
		shape(box, 0.62, 0.42, 0.52, 0.52, CREAM, 0.5)
		shape(box, 0.76, 0.7, 0.12, 0.12, colour, 0.5)
	end,
}

-- A type's badge: a cream disc with an ink edge and the type's glyph in its colour.
function Icons.type(
	parent: Instance,
	element: Types.Element,
	colour: Color3,
	size: number,
	position: UDim2?
): Frame
	local box = holder(parent, size, position)
	box.Name = "TypeIcon"
	local disc = shape(box, 0.5, 0.5, 1, 1, CREAM, 0.5)
	ring(disc, stroke(size), INK)
	local draw = GLYPHS[element]
	if draw then
		-- Slightly inset so the glyph clears the edge.
		local inner = shape(disc, 0.5, 0.5, 0.82, 0.82, CREAM, 0)
		inner.BackgroundTransparency = 1
		draw(inner, colour)
	end
	return box
end

function Icons.coin(parent: Instance, size: number, position: UDim2?): Frame
	local box = holder(parent, size, position)
	box.Name = "CoinIcon"
	local disc = shape(box, 0.5, 0.5, 1, 1, GOLD, 0.5)
	ring(disc, stroke(size), INK)
	local inner = shape(disc, 0.5, 0.5, 0.62, 0.62, GOLD, 0.5)
	ring(inner, 1, GOLD_DARK)
	shape(disc, 0.5, 0.5, 0.1, 0.34, GOLD_DARK, 0.3)
	return box
end

-- A Gem: a green faceted stone with a pale top facet and a glint, a different shape and colour
-- from Prism's blue-and-pink diamond so the two never read as one.
function Icons.gem(parent: Instance, size: number, position: UDim2?): Frame
	local box = holder(parent, size, position)
	box.Name = "GemIcon"
	local stone = shape(box, 0.5, 0.56, 0.78, 0.62, Color3.fromRGB(52, 178, 120), 0.18)
	ring(stone, stroke(size), INK)
	shape(box, 0.5, 0.3, 0.46, 0.2, Color3.fromRGB(150, 232, 190), 0.2)
	shape(box, 0.5, 0.64, 0.12, 0.32, Color3.fromRGB(30, 130, 90), 0.3)
	shape(box, 0.3, 0.4, 0.1, 0.1, Color3.new(1, 1, 1), 0.5)
	return box
end

function Icons.prism(parent: Instance, size: number, position: UDim2?): Frame
	local box = holder(parent, size, position)
	box.Name = "PrismIcon"
	local gem = shape(box, 0.5, 0.5, 0.68, 0.68, Color3.fromRGB(120, 200, 232), 0.1, 45)
	ring(gem, stroke(size), INK)
	shape(box, 0.5, 0.5, 0.36, 0.36, Color3.fromRGB(214, 150, 232), 0.08, 45)
	shape(box, 0.4, 0.38, 0.12, 0.12, Color3.new(1, 1, 1), 0.5)
	return box
end

-- A paw print: one big pad and four toes.
function Icons.creatures(parent: Instance, size: number, colour: Color3?, position: UDim2?): Frame
	local ink = colour or INK
	local box = holder(parent, size, position)
	box.Name = "CreaturesIcon"
	shape(box, 0.5, 0.66, 0.5, 0.4, ink, 0.5)
	shape(box, 0.18, 0.44, 0.2, 0.26, ink, 0.5, -20)
	shape(box, 0.38, 0.24, 0.2, 0.28, ink, 0.5, -8)
	shape(box, 0.62, 0.24, 0.2, 0.28, ink, 0.5, 8)
	shape(box, 0.82, 0.44, 0.2, 0.26, ink, 0.5, 20)
	return box
end

-- A closed book: a cover with ink edge, a spine and two lines of text.
function Icons.journal(parent: Instance, size: number, colour: Color3?, position: UDim2?): Frame
	local ink = colour or INK
	local box = holder(parent, size, position)
	box.Name = "JournalIcon"
	local cover = shape(box, 0.5, 0.5, 0.7, 0.86, CREAM, 0.1)
	ring(cover, stroke(size), ink)
	shape(box, 0.28, 0.5, 0.1, 0.86, ink, 0)
	shape(box, 0.6, 0.34, 0.3, 0.07, ink, 0.5)
	shape(box, 0.6, 0.5, 0.3, 0.07, ink, 0.5)
	shape(box, 0.56, 0.66, 0.22, 0.07, ink, 0.5)
	return box
end

-- A small down-pointing triangle: half of a turned square, cut off by its holder.
function Icons.arrowDown(parent: Instance, width: number, colour: Color3?): Frame
	local clip = Instance.new("Frame")
	clip.Name = "ArrowDown"
	clip.Size = UDim2.fromOffset(width, width / 2)
	clip.BackgroundTransparency = 1
	clip.BorderSizePixel = 0
	clip.ClipsDescendants = true
	clip.Parent = parent
	local side = width / math.sqrt(2)
	local square = Instance.new("Frame")
	square.AnchorPoint = Vector2.new(0.5, 0.5)
	square.Position = UDim2.fromScale(0.5, 0)
	square.Size = UDim2.fromOffset(side, side)
	square.Rotation = 45
	square.BackgroundColor3 = colour or INK
	square.BorderSizePixel = 0
	square.Parent = clip
	return clip
end

return Icons
