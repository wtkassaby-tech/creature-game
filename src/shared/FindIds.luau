--!strict
-- Which find ids exist and how often each may be used, as pure lookups on the registry
-- (src/content/Finds). Split from Finds so the saved-data checks (Profile) can use them without
-- requiring the rules, which need Profile's neighbours.

local FindsConfig = require("../config/FindsConfig")
local Registry = require("../content/Finds")

local FindIds = {}

-- True for the id of a one-time thing that can be claimed: a cache, a note or a cairn, or a
-- journal set. Spots that renew every day (gathering, sightings) are never in `Finds.once`.
function FindIds.isOnceId(id: string): boolean
	local find = Registry.byId[id]
	if find then
		return find.kind == "Cache" or find.kind == "Cairn" or find.kind == "Note"
	end
	return Registry.setById[id] ~= nil
end

-- The most a key in Daily.finds may hold today, or nil if it is not a daily key.
function FindIds.dailyLimit(key: string): number?
	if key == FindsConfig.GATHERED_KEY then
		return FindsConfig.GATHER_DAILY_CAP
	end
	local find = Registry.byId[key]
	if find and find.kind == "Gather" then
		return FindsConfig.GATHER_PER_SPOT_PER_DAY
	elseif find and find.kind == "Sighting" then
		return FindsConfig.SIGHTINGS_PER_SPOT_PER_DAY
	end
	return nil
end

return FindIds
