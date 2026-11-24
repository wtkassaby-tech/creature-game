--!strict
-- Which biomes are open in the live game. Later biomes are written as data before they open:
-- their species, world, tamers, giant, quests and story chapter all exist in src/content, but the
-- world registries (Biomes, Story, Storyline, Giants, Quests, Tamers) leave out every biome above
-- this number, so the game cannot reach them. A [Default]: opening a biome is one change here,
-- made when its map and art are in the place.
--
-- Tests that check a later biome raise this before requiring any registry (each test file runs
-- in its own process), for example `require("../src/config/ReleaseConfig").OPEN_BIOMES = 4`.

local ReleaseConfig = {}

ReleaseConfig.OPEN_BIOMES = 3 -- Greenwood, Dust Canyon and Tide Flats at launch

return ReleaseConfig
