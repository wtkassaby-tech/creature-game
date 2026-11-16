--!strict
-- Every species in the game, by name. One data file per species in this folder;
-- add each new species to the list below. Data only: no logic lives here.

local Types = require("../shared/Types")

local Species: { [string]: Types.SpeciesDef } = {
	-- Greenwood (biome 1). See docs/content/GREENWOOD_ROSTER.md.
	Burlhorn = require("./species/Burlhorn"),
	Gorsling = require("./species/Gorsling"),
	Mossmitt = require("./species/Mossmitt"),
	Sloshcalf = require("./species/Sloshcalf"),
	Spadesnout = require("./species/Spadesnout"),
	Splashjack = require("./species/Splashjack"),
	Stiltbark = require("./species/Stiltbark"),
	Stumpwarden = require("./species/Stumpwarden"),
}

return Species
