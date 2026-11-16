--!strict
-- Builds a creature model from its record, on the player's device.
-- Runs only in Roblox (it creates Instances); the numbers come from shared/AssemblyMath, which is tested under Lune.
--
-- Expects prepared part templates at ReplicatedStorage.CreatureParts.<Species>.<Head|Torso|FrontLimb|Leg|Tail>:
--   * each is a MeshPart whose pivot is the centre of its ball end;
--   * the Torso has Attachments named HeadSocket, FrontLimbSocketL, FrontLimbSocketR, LegSocketL, LegSocketR, TailSocket;
--   * every other part has one Attachment named Plug at its ball end.
-- Scripts cannot set MeshPart.MeshId at runtime, so parts are cloned from these templates.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AssemblyMath = require(ReplicatedStorage.shared.AssemblyMath)
local Types = require(ReplicatedStorage.shared.Types)

local Assembler = {}

-- Which template, torso socket and joint name each visible part uses.
local LAYOUT: { { slot: Types.Slot, template: string, name: string, socket: string } } = {
	{ slot = "Head", template = "Head", name = "Head", socket = "HeadSocket" },
	{
		slot = "FrontLimbs",
		template = "FrontLimb",
		name = "FrontLimbL",
		socket = "FrontLimbSocketL",
	},
	{
		slot = "FrontLimbs",
		template = "FrontLimb",
		name = "FrontLimbR",
		socket = "FrontLimbSocketR",
	},
	{ slot = "Legs", template = "Leg", name = "LegL", socket = "LegSocketL" },
	{ slot = "Legs", template = "Leg", name = "LegR", socket = "LegSocketR" },
	{ slot = "Tail", template = "Tail", name = "Tail", socket = "TailSocket" },
}

local COLOURS: { [string]: Color3 } = {
	Moss = Color3.fromRGB(96, 140, 72),
	Bark = Color3.fromRGB(120, 88, 60),
	Sand = Color3.fromRGB(214, 186, 128),
	Ember = Color3.fromRGB(226, 92, 48),
	Frostbite = Color3.fromRGB(150, 210, 235),
	Starlight = Color3.fromRGB(190, 160, 255),
}

local function cloneTemplate(species: string, template: string): MeshPart
	local folder = ReplicatedStorage:WaitForChild("CreatureParts"):WaitForChild(species)
	local part = folder:WaitForChild(template):Clone() :: MeshPart
	-- Parts are unanchored so the joints can move them; the torso is anchored in `build`
	-- and the world code moves the whole creature by its torso.
	part.Anchored = false
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Massless = true
	return part
end

-- Scales a part and moves its attachments with it, so the ball end stays on the pivot.
local function scalePart(part: MeshPart, scale: number)
	part.Size *= scale
	for _, child in part:GetChildren() do
		if child:IsA("Attachment") then
			child.Position *= scale
		end
	end
end

function Assembler.build(creature: Types.Creature): Model
	local model = Instance.new("Model")
	model.Name = creature.id

	local torso = cloneTemplate(creature.parts.Torso.species, "Torso")
	torso.Name = "Torso"
	torso.Parent = model
	model.PrimaryPart = torso
	torso.Anchored = true -- creatures are placed and moved by code, not by physics

	local scales = AssemblyMath.partScales(creature)
	for _, entry in LAYOUT do
		local part = cloneTemplate(creature.parts[entry.slot].species, entry.template)
		part.Name = entry.name
		scalePart(part, scales[entry.slot])

		local socket = torso:FindFirstChild(entry.socket) :: Attachment
		local plug = part:FindFirstChild("Plug") :: Attachment
		local joint = Instance.new("Motor6D")
		joint.Name = entry.name
		joint.Part0 = torso
		joint.Part1 = part
		joint.C0 = socket.CFrame -- where the socket sits on the torso
		joint.C1 = plug.CFrame -- where the ball end sits on the part
		joint.Parent = torso
		part.Parent = model
	end

	-- One colour for the whole creature in the prototype; patterns and gem-tier materials come later.
	local colour = COLOURS[creature.colour.shown]
	for _, child in model:GetChildren() do
		if child:IsA("MeshPart") then
			child.Color = colour
		end
	end

	-- The size gene scales the finished model, joints included.
	model:ScaleTo(creature.size)
	model:SetAttribute("RideHeight", AssemblyMath.rideHeight(creature))
	return model
end

-- Stands the model on the ground at a position, facing -Z.
function Assembler.place(model: Model, groundPosition: Vector3)
	local torso = model.PrimaryPart :: BasePart
	local legSocket = torso:FindFirstChild("LegSocketL") :: Attachment
	local rideHeight = model:GetAttribute("RideHeight") :: number
	-- Lift the torso so its leg sockets sit one scaled leg length above the ground.
	-- ScaleTo has already scaled the attachment, so this offset includes the size gene,
	-- as the ride height does.
	local socketOffset = legSocket.Position.Y
	model:PivotTo(CFrame.new(groundPosition + Vector3.new(0, rideHeight - socketOffset, 0)))
end

return Assembler
