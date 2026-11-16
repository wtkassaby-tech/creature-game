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
}

return Moves
