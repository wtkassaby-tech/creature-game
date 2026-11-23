--!strict
-- A creature shown inside a screen: its toy body in a small window, turned a little to one
-- side, breathing and blinking like the ones in the world. Used wherever a screen names a
-- creature (the starter pick, the Creatures list), so a name always has a face beside it.
-- With `silhouette` set it is a flat dark shape instead, for a creature the player has not met.
-- Looks only.

local ToyBody = require(script.Parent.ToyBody)
local Types = require(game:GetService("ReplicatedStorage").shared.Types)

local Portrait = {}

local INK = Color3.fromRGB(34, 32, 48)

-- Paints one part as a plain dark shape. A painted model carries its look in a texture, so the
-- texture is cleared; a part-built sketch only needs its colour set.
local function darken(part: Instance)
	if part:IsA("BasePart") then
		part.Color = INK
		part.Material = Enum.Material.SmoothPlastic
		if part:IsA("MeshPart") then
			part.TextureID = ""
		end
	end
end

function Portrait.new(
	parent: Instance,
	species: string,
	element: Types.Element,
	size: UDim2,
	position: UDim2,
	silhouette: boolean?,
	hz: number?
): ViewportFrame
	local window = Instance.new("ViewportFrame")
	window.Size = size
	window.Position = position
	window.BackgroundTransparency = 1
	window.Ambient = Color3.fromRGB(200, 200, 210)
	window.LightColor = Color3.fromRGB(255, 250, 240)
	window.LightDirection = Vector3.new(-1, -2, -1)
	window.Parent = parent

	local toy = ToyBody.new(window, species, element, 1)
	-- It only moves while its screen can be seen (checked twice a second); a card in a scrolling
	-- list is drawn about ten times a second, or at `hz` when the screen asks for that.
	if hz then
		toy.rate(hz)
	end
	if silhouette then
		toy.still(true) -- a creature not yet met does not even gesture
		-- White ambient light and no direct light: a dark part stays exactly its own dark colour.
		window.Ambient = Color3.new(1, 1, 1)
		window.LightColor = Color3.new(0, 0, 0)
		for _, part in toy.model:GetDescendants() do
			darken(part)
		end
		-- ToyBody swaps its sketch for the painted model once that has loaded, so anything added
		-- later is darkened as it arrives.
		toy.model.DescendantAdded:Connect(darken)
	end
	-- Standing at the origin, turned a third of the way toward the viewer's left.
	toy.place(CFrame.Angles(0, math.rad(-30), 0))
	local camera = Instance.new("Camera")
	camera.FieldOfView = 30
	camera.CFrame = CFrame.lookAt(Vector3.new(0, 4.4, -14.5), Vector3.new(0, 3, 0))
	camera.Parent = window
	window.CurrentCamera = camera
	return window
end

return Portrait
