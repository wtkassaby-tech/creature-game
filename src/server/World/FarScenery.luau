--!strict
-- The far scenery (docs/plans/13_WORLD_DESIGN.md sections 3c, 6a and 10): the Crown and its cloud
-- halo, the Western Highlands, the Northern Range and the South Sea's islands and far coast, read
-- from content/world_data/FarScenery. Built once. Each piece is one part (a painted model where
-- one fits, else a plain dome or cloud), anchored, never collided with, queried or touched, and
-- casting no shadow, so it costs a phone almost nothing. Colours are pulled toward the haze by
-- layer, so the further a thing is the paler it stands. All pieces sit in one Model that
-- streaming never removes, so they are there from the first frame whatever the player's distance.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FarSceneryConfig = require(ReplicatedStorage.config.FarSceneryConfig)
local World = require(ReplicatedStorage.content.World)
local WorldTypes = require(ReplicatedStorage.shared.WorldTypes)

local Props = require(script.Parent.Props)

local FarScenery = {}

-- How many parts a build made, by layer.
export type Counts = { [string]: number }

local function quiet(part: BasePart)
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
end

local function tinted(piece: WorldTypes.FarScenery): Color3
	local layer = FarSceneryConfig.LAYERS[piece.layer]
	local own = Props.colour(piece.colour)
	return own:Lerp(Props.colour(FarSceneryConfig.HAZE), if layer then layer.haze else 0)
end

-- An oval of flat colour: a dome (its lower half sunk below `foot`) or a whole cloud.
local function oval(
	parent: Instance,
	piece: WorldTypes.FarScenery,
	dome: boolean,
	size: Vector3
): Part
	local centre =
		Vector3.new(piece.at.x, piece.base + (if dome then 0 else size.Y / 2), piece.at.z)
	local across = if dome then Vector3.new(size.X, size.Y * 2, size.Z) else size
	local made = Props.lump(parent, across, centre, tinted(piece))
	made.CFrame = CFrame.lookAt(centre, centre + Props.facing(piece.faces))
	return made
end

local function place(parent: Instance, piece: WorldTypes.FarScenery): BasePart
	local size = Vector3.new(piece.size[1], piece.size[2], piece.size[3]) * piece.scale
	local made: BasePart
	if piece.model == "Puff" then
		made = oval(parent, piece, false, size)
		-- A cloud or plume lights itself softly, so its underside does not turn navy against
		-- the sky (Studio, 23 November 2026); a little see-through, so it reads as vapour.
		-- Neon glowed like saucers; a soft, bright plastic, half see-through, reads as vapour.
		made.Material = Enum.Material.SmoothPlastic
		made.Color = made.Color:Lerp(Color3.new(1, 1, 1), 0.5)
		made.Transparency = 0.35
		made.Reflectance = 0
	else
		local painted = if piece.model == "Lump" then nil else Props.model(piece.model)
		if painted then
			-- Stretched to the size in the data, its foot on `base`.
			local copy = painted:Clone()
			copy.Size = size
			local foot = Vector3.new(piece.at.x, piece.base + size.Y / 2, piece.at.z)
			copy.CFrame = CFrame.lookAt(foot, foot + Props.facing(piece.faces))
			-- A painted model keeps its own colours, faded a little toward the haze through
			-- its tint (a Color tint on a textured MeshPart darkens it, so it starts at white).
			local layer = FarSceneryConfig.LAYERS[piece.layer]
			local fade = (if layer then layer.haze else 0) * 0.35
			copy.Color = Color3.new(1, 1, 1):Lerp(Props.colour(FarSceneryConfig.HAZE), fade)
			copy.Parent = parent
			made = copy
		else
			-- A plain dome: also what stands in when a painted model will not load.
			made = oval(parent, piece, true, size)
		end
	end
	made.Name = piece.id
	quiet(made)
	return made
end

-- Builds the far scenery under `parent` and returns its model and the part counts by layer.
function FarScenery.build(parent: Instance): (Model, Counts)
	local model = Instance.new("Model")
	model.Name = "FarScenery"
	model.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
	local counts: Counts = {}
	for _, piece in World.farScenery do
		place(model, piece)
		counts[piece.layer] = (counts[piece.layer] or 0) + 1
	end
	model.Parent = parent
	return model, counts
end

return FarScenery
