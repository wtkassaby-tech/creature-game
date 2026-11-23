--!strict
-- The registry of finds and journal sets (docs/plans/14_FINDS_AND_REWARDS.md), one data file per
-- biome in finds_data (a different name from this registry, because Windows ignores case). Like
-- every world registry it leaves out the biomes src/config/ReleaseConfig does not open, so a later
-- biome's finds cannot be reached or saved before the biome opens.

local ReleaseConfig = require("../config/ReleaseConfig")
local WorldTypes = require("../shared/WorldTypes")

local FILES: { { finds: { WorldTypes.Find }, sets: { WorldTypes.JournalSet } } } = {
	require("./finds_data/Greenwood"),
	require("./finds_data/DustCanyon"),
	require("./finds_data/TideFlats"),
}

local list: { WorldTypes.Find } = {}
local byId: { [string]: WorldTypes.Find } = {}
local sets: { WorldTypes.JournalSet } = {}
local setById: { [string]: WorldTypes.JournalSet } = {}
local keepsakes: { [string]: WorldTypes.Keepsake } = {}

for _, file in FILES do
	for _, find in file.finds do
		if find.biome <= ReleaseConfig.OPEN_BIOMES then
			table.insert(list, find)
			byId[find.id] = find
			if find.keepsake then
				keepsakes[find.keepsake.id] = find.keepsake
			end
		end
	end
	for _, set in file.sets do
		if set.biome <= ReleaseConfig.OPEN_BIOMES then
			table.insert(sets, set)
			setById[set.id] = set
			keepsakes[set.keepsake.id] = set.keepsake
		end
	end
end

return {
	list = list, -- every find of an open biome, in file order
	byId = byId,
	sets = sets,
	setById = setById,
	keepsakes = keepsakes,
}
