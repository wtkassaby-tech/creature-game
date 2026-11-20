--!strict
-- Every move in the game, by name. Parts bring moves (see each species file);
-- this table says what each move does. Data only.

local Types = require("../shared/Types")

export type MoveDef = { element: Types.Element, power: number }

local Moves: { [string]: MoveDef } = {
	-- Greenwood (biome 1). No status effects yet: those arrive with the Mire.
	-- Leaf
	["Moss Slam"] = { element = "Leaf", power = 35 },
	["Seed Shot"] = { element = "Leaf", power = 35 },
	["Fern Whip"] = { element = "Leaf", power = 40 },
	["Twig Snap"] = { element = "Leaf", power = 40 },
	["Pollen Burst"] = { element = "Leaf", power = 45 },
	["Leaf Gust"] = { element = "Leaf", power = 50 },
	["Root Lash"] = { element = "Leaf", power = 50 },
	["Sap Hammer"] = { element = "Leaf", power = 55 },
	["Thorn Volley"] = { element = "Leaf", power = 55 },
	["Bramble Rake"] = { element = "Leaf", power = 60 },
	["Burl Charge"] = { element = "Leaf", power = 60 },
	["Canopy Drop"] = { element = "Leaf", power = 60 },
	-- Sand
	["Dust Kick"] = { element = "Sand", power = 45 },
	["Scree Kick"] = { element = "Sand", power = 45 },
	["Grit Spray"] = { element = "Sand", power = 50 },
	["Mud Slap"] = { element = "Sand", power = 55 },
	["Dig Strike"] = { element = "Sand", power = 65 },
	["Silt Surge"] = { element = "Sand", power = 65 },
	-- Water
	["Puddle Stomp"] = { element = "Water", power = 40 },
	["Dew Splash"] = { element = "Water", power = 45 },
	["Brook Rush"] = { element = "Water", power = 50 },
	["Ripple Ram"] = { element = "Water", power = 70 },
	-- Storm
	["Gale Hop"] = { element = "Storm", power = 50 },
	-- Toxic
	["Spore Puff"] = { element = "Toxic", power = 65 },

	-- Dust Canyon (biome 2). Still no status effects. See docs/content/DUST_CANYON_ROSTER.md.
	-- Sand
	["Knap Edge"] = { element = "Sand", power = 40 },
	["Sand Flick"] = { element = "Sand", power = 40 },
	["Flint Cleave"] = { element = "Sand", power = 45 },
	["Grit Step"] = { element = "Sand", power = 45 },
	["Hoof Scuff"] = { element = "Sand", power = 45 },
	["Pebble Pelt"] = { element = "Sand", power = 45 },
	["Capstone Crash"] = { element = "Sand", power = 50 },
	["Spire Topple"] = { element = "Sand", power = 50 },
	["Talus Tumble"] = { element = "Sand", power = 50 },
	["Dune Dash"] = { element = "Sand", power = 55 },
	["Grit Whirl"] = { element = "Sand", power = 55 },
	["Mesa Slam"] = { element = "Sand", power = 60 },
	-- Water
	["Fog Drip"] = { element = "Water", power = 40 },
	["Flash Flood"] = { element = "Water", power = 50 },
	["Oasis Spout"] = { element = "Water", power = 50 },
	["Wadi Rush"] = { element = "Water", power = 55 },
	-- Leaf
	["Spine Jab"] = { element = "Leaf", power = 45 },
	["Agave Lance"] = { element = "Leaf", power = 55 },
	["Needle Fan"] = { element = "Leaf", power = 55 },
	["Tumbleweed Toss"] = { element = "Leaf", power = 55 },
	-- Storm: a teaser for Stormreach, on Leaf torsos only (see the roster document)
	["Dust Squall"] = { element = "Storm", power = 65 },
}

return Moves
