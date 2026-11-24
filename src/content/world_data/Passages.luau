--!strict
-- The walks between one biome's sealed road and the next town's arch, in world coordinates
-- (docs/plans/13_WORLD_DESIGN.md section 4). Only the launch three's two are written; later
-- biomes add theirs here. Data only.
--
-- `swapAt` is where the sky and music change, and it lies inside something that hides the cut:
-- the Acorn Gatehouse (its bar, where the sealed road's story beat fires, is at x 697) and the
-- Stair Gate's arch.

local WorldTypes = require("../../shared/WorldTypes")

local Passages: { WorldTypes.Passage } = {
	{
		id = "acorn_gatehouse",
		from = 1,
		to = 2,
		kind = "Gatehouse",
		points = { { x = 684.4, z = -80 }, { x = 834, z = -80 } },
		heights = { 0, 0 },
		width = 40,
		swapAt = 13, -- x 697.4, inside the gatehouse
		swapRadius = 40,
	},
	{
		id = "stair_gate",
		from = 2,
		to = 3,
		kind = "Pass",
		points = { { x = 1763, z = -180 }, { x = 1913, z = -180 } },
		heights = { 40, 0 },
		width = 40,
		swapAt = 30, -- x 1793, under the Stair Gate's arch
		swapRadius = 40,
	},
}

return Passages
