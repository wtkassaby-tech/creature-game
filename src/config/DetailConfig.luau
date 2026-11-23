--!strict
-- Numbers for the small ground detail (src/shared/DetailPlan.luau): the scatter of flowers,
-- pebbles and tufts on lawns and verges, and the paving pattern on each town's plaza. All
-- [Default]s. What is scattered, and how thickly, is in each biome's dressing sheet (`scatter`).

local DetailConfig = {}

-- Where scatter may not go, in studs.
DetailConfig.SPOT_CLEAR = 8 -- from any tamer, person, prompt or door
DetailConfig.RUSTLE_CLEAR = 16 -- from a rustle spot (its patch is 20 wide)
DetailConfig.GRASS_PAD = 3 -- beyond the edge of a long-grass patch
DetailConfig.LANE_PAD = 1.8 -- verge scatter starts this far past a lane's edge
DetailConfig.EDGING_NEAR = 0.5 -- edging starts this far past a lane's edge...
DetailConfig.EDGING_FAR = 1.8 -- ...and ends this far past it
DetailConfig.EDGE_PAD = 2.5 -- verge scatter stops this far inside the corridor's edge
DetailConfig.TOWN_LANE_PAD = 2 -- from the edge of a town street
DetailConfig.THING_PAD = 3 -- from a building, house, fence, hedge, wall or pool
DetailConfig.WATER_PAD = 3
DetailConfig.TIER_FOOT_PAD = 5 -- from the foot of a tier's wall
DetailConfig.LINK_PAD = 6 -- from stairs, ramps and ledges
DetailConfig.FLAT_RADIUS = 3 -- the ground must be one height this far round an item
DetailConfig.TOWN_MARGIN = 4 -- from the town square's own edge
DetailConfig.STEP = 2 -- studs between the points scatter is rolled along a lane
DetailConfig.CELL = 8 -- studs across a cell of the town's ground, rolled one cell at a time
DetailConfig.FOOT = 0.1 -- height of the lawn under scatter
DetailConfig.COLOUR_JITTER = 8 -- each colour channel varies by up to this much, out of 255
DetailConfig.SEED = 4177 -- added to the biome number for the scatter's random numbers

-- The plaza (a flat disc, top at PLAZA_TOP): a ring of paving stones round its rim, a centre
-- motif, and flower beds. Colours are the plaza's own, darkened or lightened by these fractions.
DetailConfig.PLAZA_TOP = 0.6
DetailConfig.STONE_LENGTH = 3.2 -- along the ring
DetailConfig.STONE_DEPTH = 2 -- across it
DetailConfig.STONE_GAP = 0.5
DetailConfig.STONE_THICK = 0.1
DetailConfig.STONE_INSET = 2.4 -- the ring's middle, from the plaza's edge
DetailConfig.STONE_DARK = { 0.86, 0.93 } -- stones alternate between these
DetailConfig.STONE_CLEAR = 4 -- no stone within this of a prompt, a lane's mouth or a fitting
DetailConfig.MOTIF_RINGS = { { 0.38, 0.88 }, { 0.3, 1.05 }, { 0.2, 0.9 }, { 0.12, 1.06 } } -- across, as a fraction of the plaza, and shade
DetailConfig.MOTIF_RAYS = 8 -- little paving rays between the outer rings
DetailConfig.BEDS = 4 -- flower beds
DetailConfig.BED_RADIUS = 0.3 -- from the plaza's middle, as a fraction of its size
DetailConfig.BED_SIZE = 5.5
DetailConfig.BED_CLEAR = 7 -- from a prompt or a fitting
DetailConfig.BED_BLOOMS = 5

return DetailConfig
