--!strict
-- Every species in the game, by name. One data file per species in this folder;
-- add each new species to the list below. Data only: no logic lives here.

local Types = require("../shared/Types")

local Species: { [string]: Types.SpeciesDef } = {
	-- Greenwood (biome 1). See docs/content/GREENWOOD_ROSTER.md.
	Burlhorn = require("./species_data/Burlhorn"),
	Gorsling = require("./species_data/Gorsling"),
	Mossmitt = require("./species_data/Mossmitt"),
	Sloshcalf = require("./species_data/Sloshcalf"),
	Spadesnout = require("./species_data/Spadesnout"),
	Splashjack = require("./species_data/Splashjack"),
	Stiltbark = require("./species_data/Stiltbark"),
	Stumpwarden = require("./species_data/Stumpwarden"),
	-- Greenwood's giant in its creature form: captured, never met in the wild.
	Hollowbough = require("./species_data/Hollowbough"),
	-- Dust Canyon (biome 2). See docs/content/DUST_CANYON_ROSTER.md.
	Cairnback = require("./species_data/Cairnback"),
	Duneskit = require("./species_data/Duneskit"),
	Flintknap = require("./species_data/Flintknap"),
	Spirecap = require("./species_data/Spirecap"),
	Spurlet = require("./species_data/Spurlet"),
	Thatchling = require("./species_data/Thatchling"),
	Wadibuck = require("./species_data/Wadibuck"),
	Whirlgrit = require("./species_data/Whirlgrit"),
	-- Dust Canyon's giant in its creature form: captured, never met in the wild.
	Mesalith = require("./species_data/Mesalith"),
	-- Tide Flats (biome 3). See docs/content/TIDE_FLATS_ROSTER.md.
	Clapshell = require("./species_data/Clapshell"),
	Cocklemole = require("./species_data/Cocklemole"),
	Glissot = require("./species_data/Glissot"),
	Gulpmaw = require("./species_data/Gulpmaw"),
	Hullock = require("./species_data/Hullock"),
	Lanternell = require("./species_data/Lanternell"),
	Moatkeep = require("./species_data/Moatkeep"),
	Runnelfin = require("./species_data/Runnelfin"),
	-- Tide Flats' giant in its creature form: captured, never met in the wild.
	Carrackon = require("./species_data/Carrackon"),
	-- The Mire (biome 4). See docs/content/MIRE_ROSTER.md and MIRE_WORLD.md. Its world is written
	-- but stays closed until src/config/ReleaseConfig.luau opens biome 4.
	Bogbellow = require("./species_data/Bogbellow"),
	Bulbroth = require("./species_data/Bulbroth"),
	Fenwhisk = require("./species_data/Fenwhisk"),
	Keelsnap = require("./species_data/Keelsnap"),
	Lilyshade = require("./species_data/Lilyshade"),
	Mistrel = require("./species_data/Mistrel"),
	Skipslick = require("./species_data/Skipslick"),
	Snaggar = require("./species_data/Snaggar"),
	-- The Mire's giant in its creature form: captured, never met in the wild.
	Sloughback = require("./species_data/Sloughback"),
}

return Species
