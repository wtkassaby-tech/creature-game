--!strict
-- Every move in the game, by name. Parts bring moves (see each species file);
-- this table says what each move does. Data only.

local Types = require("../shared/Types")

-- What a move does besides damage. "Poison" poisons the creature it hits (BattleConfig).
export type MoveEffect = "Poison"
export type MoveDef = { element: Types.Element, power: number, effect: MoveEffect? }

local Moves: { [string]: MoveDef } = {
	-- Greenwood (biome 1). No status effects: those arrive with the Mire.
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
	-- Hollowbough's own (the captured giant's signature moves; see src/content/giants).
	["Heartwood Slam"] = { element = "Leaf", power = 65 },
	["Thorn Gale"] = { element = "Storm", power = 60 },
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
	-- Mesalith's own (the captured giant's signature moves; see src/content/giants).
	["Strata Crush"] = { element = "Sand", power = 65 },
	["Tumble Barrage"] = { element = "Leaf", power = 60 },

	-- Tide Flats (biome 3). Still no status effects. See docs/content/TIDE_FLATS_ROSTER.md.
	-- Water
	["Foam Flick"] = { element = "Water", power = 40 },
	["Brine Jab"] = { element = "Water", power = 45 },
	["Riptide Rush"] = { element = "Water", power = 45 },
	["Rockpool Lunge"] = { element = "Water", power = 45 },
	["Shoal Stomp"] = { element = "Water", power = 45 },
	["Skim Dash"] = { element = "Water", power = 45 },
	["Spray Jet"] = { element = "Water", power = 45 },
	["Tidepool Surge"] = { element = "Water", power = 45 },
	["Lantern Pulse"] = { element = "Water", power = 50 },
	["Maw Snap"] = { element = "Water", power = 50 },
	["Barnacle Butt"] = { element = "Water", power = 55 },
	["Mussel Smack"] = { element = "Water", power = 55 },
	["Breaker Charge"] = { element = "Water", power = 60 },
	["Undertow"] = { element = "Water", power = 60 },
	["Clamp Crush"] = { element = "Water", power = 65 },
	-- Sand: the two Sand torsos and their parts
	["Sand Scoop"] = { element = "Sand", power = 45 },
	["Rampart Slam"] = { element = "Sand", power = 50 },
	["Shell Grind"] = { element = "Sand", power = 50 },
	["Burrow Burst"] = { element = "Sand", power = 55 },
	["Cockle Crack"] = { element = "Sand", power = 55 },
	-- Toxic: a teaser for the Mire, on the two Sand torsos only (see the roster document)
	["Red Tide"] = { element = "Toxic", power = 65 },
	-- Carrackon's own (the captured giant's signature moves; see src/content/giants).
	["Rolling Breaker"] = { element = "Water", power = 65 },
	["Silt Cloud"] = { element = "Sand", power = 60 },

	-- The Mire (biome 4). Poison arrives here. See docs/content/MIRE_ROSTER.md.
	-- Toxic
	["Muck Stamp"] = { element = "Toxic", power = 40 },
	["Simmer Slam"] = { element = "Toxic", power = 40 },
	["Peat Butt"] = { element = "Toxic", power = 45 },
	["Sludge Slap"] = { element = "Toxic", power = 45 },
	["Bog Wade"] = { element = "Toxic", power = 50 },
	["Gar Rend"] = { element = "Toxic", power = 50 },
	["Hook Beak"] = { element = "Toxic", power = 50 },
	["Slick Dash"] = { element = "Toxic", power = 50 },
	["Fen Lash"] = { element = "Toxic", power = 55 },
	["Snag Bite"] = { element = "Toxic", power = 55 },
	["Mire Crush"] = { element = "Toxic", power = 60 },
	["Murk Lunge"] = { element = "Toxic", power = 65 },
	["Shell Bash"] = { element = "Toxic", power = 65 },
	-- Toxic, poisoning (the first moves with an effect): weaker hits than the plain moves of the
	-- same slot, brought only by Toxic species
	["Barb Sting"] = { element = "Toxic", power = 30, effect = "Poison" },
	["Venom Nip"] = { element = "Toxic", power = 30, effect = "Poison" },
	["Broth Spit"] = { element = "Toxic", power = 40, effect = "Poison" },
	["Fume Belch"] = { element = "Toxic", power = 45, effect = "Poison" },
	-- Water: the two Water species and their parts
	["Fen Plunge"] = { element = "Water", power = 40 },
	["Mist Snap"] = { element = "Water", power = 40 },
	["Reed Paddle"] = { element = "Water", power = 45 },
	["Murk Dive"] = { element = "Water", power = 65 },
	["Still Water"] = { element = "Water", power = 65 },
	-- Frost: a teaser for Frostline, on the two Water torsos only (see the roster document)
	["Hoarmist"] = { element = "Frost", power = 70 },
	-- Sloughback's own (the captured giant's signature moves; see src/content/giants).
	["Marsh Gas"] = { element = "Toxic", power = 65 },
	["Sinking Pull"] = { element = "Water", power = 60 },
}

return Moves
