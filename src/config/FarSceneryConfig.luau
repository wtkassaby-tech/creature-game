--!strict
-- Numbers for the far scenery (docs/plans/13_WORLD_DESIGN.md sections 3c, 6a and 10): how many
-- pieces each layer may use, and how far each fades toward the haze. All [Default]s.

local FarSceneryConfig = {}

-- The plan's cap for the whole world.
FarSceneryConfig.TOTAL_BUDGET = 40

-- Parts allowed per layer, and how far (0 to 1) the layer's colours are pulled toward HAZE: more
-- for what is further away, so the world reads in layers (aerial perspective).
FarSceneryConfig.LAYERS = {
	crown = { budget = 18, haze = 0.4 }, -- the ring of mountains and its cloud halo, 700 to 1,300 off
	west = { budget = 5, haze = 0.5 }, -- the Western Highlands behind Greenwood
	north = { budget = 8, haze = 0.62 }, -- the Northern Range: Whitefang, Old Smoulder, the Anvil
	sea = { budget = 9, haze = 0.3 }, -- islands and stacks near, the far coast fading at z +3000
} :: { [string]: { budget: number, haze: number } }

-- The colour distant things fade toward: the warm pale of the Atmosphere's own colour.
FarSceneryConfig.HAZE = { 238, 226, 208 }

-- A far piece keeps at least this far outside every biome's walkable bounds (its places, routes
-- and passages), which is past the fill's 80-stud band, so it is seen over the walls, not reached.
FarSceneryConfig.KEEP_OUT_MARGIN = 100

-- Roblox's limit on one part's size in any direction.
FarSceneryConfig.MAX_PART_STUDS = 2048

return FarSceneryConfig
