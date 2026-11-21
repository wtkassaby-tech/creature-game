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
	-- Greenwood's giant in its creature form: captured, never met in the wild.
	Hollowbough = require("./species/Hollowbough"),
	-- Dust Canyon (biome 2). See docs/content/DUST_CANYON_ROSTER.md.
	Cairnback = require("./species/Cairnback"),
	Duneskit = require("./species/Duneskit"),
	Flintknap = require("./species/Flintknap"),
	Spirecap = require("./species/Spirecap"),
	Spurlet = require("./species/Spurlet"),
	Thatchling = require("./species/Thatchling"),
	Wadibuck = require("./species/Wadibuck"),
	Whirlgrit = require("./species/Whirlgrit"),
	-- Dust Canyon's giant in its creature form: captured, never met in the wild.
	Mesalith = require("./species/Mesalith"),
	-- Tide Flats (biome 3). See docs/content/TIDE_FLATS_ROSTER.md.
	Clapshell = require("./species/Clapshell"),
	Cocklemole = require("./species/Cocklemole"),
	Glissot = require("./species/Glissot"),
	Gulpmaw = require("./species/Gulpmaw"),
	Hullock = require("./species/Hullock"),
	Lanternell = require("./species/Lanternell"),
	Moatkeep = require("./species/Moatkeep"),
	Runnelfin = require("./species/Runnelfin"),
	-- Tide Flats' giant in its creature form: captured, never met in the wild.
	Carrackon = require("./species/Carrackon"),
}

return Species
