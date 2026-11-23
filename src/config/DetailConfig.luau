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

-- Soft ground patches (src/shared/GroundTone.luau): two flat discs each, the outer paler.
DetailConfig.BLOTCH_TOP = 0.12 -- over the corridors' ground (up to 0.115), under every lane (0.42)
DetailConfig.BLOTCH_OUTER = 0.62 -- the outer disc's transparency
DetailConfig.BLOTCH_INNER = 0.38 -- the inner disc's
DetailConfig.BLOTCH_INNER_SHARE = 0.62 -- the inner disc's size, against the outer
DetailConfig.BLOTCH_SHORT = { 0.55, 0.85 } -- the short axis, against the long
DetailConfig.BLOTCH_PAD = 2 -- keep this far inside a corridor's edge
DetailConfig.BLOTCH_TOWN_EDGE = 8 -- keep this far inside the town square's edge
DetailConfig.BLOTCH_TRIES = 12 -- attempts at a spot for each patch

-- The band where two biomes' ground meet: a strip of ground colour graded between their field
-- colours, a few wide flat parts, with a little scatter from both biomes.
DetailConfig.SEAM_WIDTH = 60
DetailConfig.SEAM_STEPS = 6
DetailConfig.SEAM_TOP = 0.02
DetailConfig.SEAM_PAST_GATE = 30 -- where the slabs meet; the same as TestMap's SLAB_CLIP_PAST_GATE
DetailConfig.SEAM_HALF_LENGTH = 400 -- the seam runs this far either side of the gate's z, within the slab
DetailConfig.SEAM_REACH = 130 -- scatter lies this far along the seam either side of the road
DetailConfig.SEAM_ROAD_CLEAR = 16 -- and this far from the sealed road's middle
DetailConfig.SEAM_ITEMS = 7 -- of each kind, on each side
DetailConfig.SEAM_MARGIN = 220 -- a biome's slab reaches this far past its places (TestMap's margin)
DetailConfig.SEAM_MAX_DEPTH = 2048 -- the longest a slab may be
DetailConfig.DEFAULT_FIELD = { 116, 178, 92 } -- the open ground of a sheet that names none (TestMap's GROUND)

-- The squares laid over each town's plaza (World/Detail.luau).
DetailConfig.DECK_TOP = 0.68 -- over the paving (0.6)
DetailConfig.DECK_PLANK = 3.4 -- across a plank
DetailConfig.DECK_PLANKS_TONE = { 0.9, 1.0, 0.95, 1.05 } -- planks cycle through these shades
DetailConfig.YARD_SLAB = 9 -- a flagstone, square (about)
DetailConfig.YARD_WALL = 1.1 -- the low wall's height
DetailConfig.YARD_GAP = 7 -- the opening left in the middle of each wall
DetailConfig.DUCK_BOARDS = 5 -- duckboard runs; each is a few boards laid end to end, off-square
return DetailConfig
