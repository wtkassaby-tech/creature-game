--!strict
-- A creature shown inside a screen: its toy body in a small window, turned a little to one
-- side, breathing and blinking like the ones in the world. Used wherever a screen names a
-- creature (the starter pick, the Creatures list), so a name always has a face beside it.
-- Looks only.

local ToyBody = require(script.Parent.ToyBody)
local Types = require(game:GetService("ReplicatedStorage").shared.Types)

local Portrait = {}

function Portrait.new(
	parent: Instance,
	species: string,
	element: Types.Element,
	size: UDim2,
	position: UDim2
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
	-- Standing at the origin, turned a third of the way toward the viewer's left.
	toy.place(CFrame.Angles(0, math.rad(-30), 0))
	local camera = Instance.new("Camera")
	camera.FieldOfView = 30
	camera.CFrame = CFrame.lookAt(Vector3.new(0, 4.6, -17), Vector3.new(0, 3.1, 0))
	camera.Parent = window
	window.CurrentCamera = camera
	return window
end

return Portrait
