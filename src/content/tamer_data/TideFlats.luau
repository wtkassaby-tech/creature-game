--!strict
-- Tide Flats' tamers: five locals met along the routes, a local champion mid-biome and the rival at
-- the gate. Names are original. Every move is one the creature can know at that level
-- (tests/tideflats.test checks this). Levels rise with the routes (23 to 32) and stay at or under
-- the gate's 32 to 35, so a player who has fought the tamers on the way arrives ready for the gate.
--
-- The gate is held by the rival this time (master plan 4.5), so this file has a story battle with one
-- team for each starter, like Dust Canyon's mid-biome rival, and no `rival` field (his Greenwood
-- entry owns the registry's `rivals` slot). His arc moves one more step (brief section 9): his team's
-- tint is 0.75 (Greenwood 0.25, Dust Canyon 0.5), and he now fights with two shards, so some of his
-- creatures are gem-touched. The team data has no rarity field, so that shows in his look and his
-- lines and in the tint, not in the numbers. He still leads with the starter that counters the
-- player's, as in Greenwood and Dust Canyon: Sand beats Leaf, Water beats Sand, Leaf beats Water.
-- Behind the lead he fields creatures that cover the player's answer: a Toxic move into Water, Storm
-- and Leaf creatures into Sand.
--
-- The mid-biome battle is a local champion of the shelf, Captain Hepzibah Marr, who is not tinted,
-- ties the rock pools to the story, and gives a first taste of Red Tide (Toxic) to a team that has
-- been using mostly Water.

local WorldTypes = require("../../shared/WorldTypes")

type Member = WorldTypes.TamerMember

local function member(species: string, level: number, moves: { string }): Member
	return { species = species, level = level, moves = moves }
end

local locals: { WorldTypes.Tamer } = {
	{
		id = "tf_nell",
		name = "Nell Sandow",
		look = "A beachcomber with a sack of driftwood on her back and a shell-filled net over one arm",
		tier = "Tamer",
		route = "tide_flats_route_a",
		at = 120,
		team = {
			members = {
				member("Glissot", 23, { "Spray Jet", "Skim Dash", "Foam Flick" }),
				member(
					"Cocklemole",
					23,
					{ "Cockle Crack", "Burrow Burst", "Sand Scoop", "Shoal Stomp" }
				),
			},
			tint = 0,
		},
		before = "Finders keepers on this beach! Beat me and the wrack is yours.",
		after = "Ha! You have quick feet for a landlubber. Mind the pools.",
	},
	{
		id = "tf_merrin",
		name = "Merrin Kelpwood",
		look = "A kelp harvester in dripping oilskins, a long hooked pole over her shoulder",
		tier = "Tamer",
		route = "tide_flats_route_a",
		at = 400,
		team = {
			members = {
				member("Runnelfin", 25, { "Spray Jet", "Skim Dash", "Foam Flick" }),
				member("Gulpmaw", 26, { "Maw Snap", "Rockpool Lunge", "Brine Jab", "Foam Flick" }),
			},
			tint = 0,
		},
		before = "My kelp beds are the best on the coast. Care to wade in?",
		after = "Well swum! Come back when the tide is in, and I will tell you where it grows thickest.",
	},
	{
		id = "tf_orrin",
		name = "Orrin Dredge",
		look = "A big dockhand with a coil of chain over one shoulder and a tarry cap",
		tier = "Tamer",
		route = "tide_flats_route_b",
		at = 110,
		team = {
			members = {
				member(
					"Moatkeep",
					28,
					{ "Rampart Slam", "Red Tide", "Shell Grind", "Cockle Crack" }
				),
				member(
					"Clapshell",
					28,
					{ "Clamp Crush", "Mussel Smack", "Brine Jab", "Breaker Charge" }
				),
			},
			tint = 0,
		},
		before = "I haul cargo all day. A battle is a change of scenery. Come on, then!",
		after = "Heavy hands! You will do well on the boardwalk.",
	},
	{
		id = "tf_isaura",
		name = "Isaura Penhallow",
		look = "A lighthouse keeper's apprentice in a blue coat, a brass signal lamp on her belt",
		tier = "Tamer",
		route = "tide_flats_route_b",
		at = 400,
		team = {
			members = {
				member(
					"Lanternell",
					30,
					{ "Lantern Pulse", "Tidepool Surge", "Brine Jab", "Breaker Charge" }
				),
				member("Glissot", 30, { "Undertow", "Spray Jet", "Skim Dash", "Foam Flick" }),
				member(
					"Hullock",
					31,
					{ "Breaker Charge", "Barnacle Butt", "Riptide Rush", "Brine Jab" }
				),
			},
			tint = 0,
		},
		before = "The lamp has been flickering at night. Show me your nerve.",
		after = "Firm as a lighthouse. Watch the wreck, though. Something is stirring.",
	},
	{
		id = "tf_ludo",
		name = "Ludo Brackwater",
		look = "A cheerful net-mender with a gap-toothed grin and a barnacled walking stick",
		tier = "Tamer",
		route = "tide_flats_route_b",
		at = 620,
		team = {
			members = {
				member("Gulpmaw", 32, { "Undertow", "Maw Snap", "Rockpool Lunge", "Brine Jab" }),
				member(
					"Cocklemole",
					31,
					{ "Burrow Burst", "Red Tide", "Shell Grind", "Cockle Crack" }
				),
				member(
					"Clapshell",
					32,
					{ "Clamp Crush", "Breaker Charge", "Mussel Smack", "Brine Jab" }
				),
			},
			tint = 0,
		},
		before = "Mended every net in Saltwick. Never lost a fish, nor a battle.",
		after = "Caught fair! Nets I can mend. My pride will take a week.",
	},
}

-- The rival, at the gate. One team for each starter the player picked.
local rivalTeams: WorldTypes.ByStarter<WorldTypes.TamerTeam> = {
	-- The player picked Mossmitt (Leaf): Sand leads, with a Toxic answer to Water and a sprinter.
	Mossmitt = {
		members = {
			member("Spadesnout", 33, { "Dig Strike", "Grit Spray", "Dust Kick", "Scree Kick" }),
			member("Cocklemole", 32, { "Burrow Burst", "Red Tide", "Shell Grind", "Cockle Crack" }),
			member("Whirlgrit", 31, { "Grit Whirl", "Dune Dash", "Pebble Pelt", "Sand Flick" }),
		},
		tint = 0.75,
	},
	-- The player picked Spadesnout (Sand): Water leads, with Leaf and Storm creatures behind it.
	Spadesnout = {
		members = {
			member("Sloshcalf", 33, { "Ripple Ram", "Mud Slap", "Brook Rush", "Spore Puff" }),
			member("Thatchling", 32, { "Agave Lance", "Needle Fan", "Dust Squall", "Spine Jab" }),
			member(
				"Clapshell",
				31,
				{ "Clamp Crush", "Breaker Charge", "Mussel Smack", "Brine Jab" }
			),
		},
		tint = 0.75,
	},
	-- The player picked Sloshcalf (Water): Leaf leads, with a Toxic creature and a Leaf sprinter.
	Sloshcalf = {
		members = {
			member("Mossmitt", 33, { "Bramble Rake", "Thorn Volley", "Leaf Gust", "Seed Shot" }),
			member("Moatkeep", 32, { "Rampart Slam", "Red Tide", "Shell Grind", "Cockle Crack" }),
			member("Spurlet", 31, { "Agave Lance", "Needle Fan", "Hoof Scuff", "Spine Jab" }),
		},
		tint = 0.75,
	},
}

local storyBattles: { WorldTypes.StoryBattle } = {
	{
		id = "champion_marr",
		name = "Hepzibah Marr",
		look = "A weathered captain in a salt-stained coat and a three-cornered hat, a spyglass tucked under one arm",
		tier = "Rival",
		place = "mudflat_boardwalk",
		xpKind = "Rival",
		team = {
			members = {
				member(
					"Hullock",
					29,
					{ "Breaker Charge", "Barnacle Butt", "Riptide Rush", "Brine Jab" }
				),
				member(
					"Moatkeep",
					29,
					{ "Rampart Slam", "Red Tide", "Shell Grind", "Cockle Crack" }
				),
				member(
					"Lanternell",
					30,
					{ "Lantern Pulse", "Tidepool Surge", "Brine Jab", "Breaker Charge" }
				),
			},
			tint = 0,
		},
		before = "Not a boot crosses my boardwalk unseen. Three of mine against your team.",
		after = "Shiver me timbers. That was a fair strike.",
		cannotLose = false,
	},
	{
		id = "rival_breakwater",
		name = "Rival",
		look = "A thin, tired youth in a grey-green jacket, two amber shards glowing at his belt and collar",
		tier = "Rival",
		place = "tide_flats_gate",
		xpKind = "Gate",
		teams = rivalTeams,
		before = "The glint talks to me now. It says I do not have to lose to you ever again.",
		after = "It is quiet when I lose. I hate how much I hate that. Go, take your badge.",
		cannotLose = false,
	},
}

local pack: WorldTypes.BiomeTamers = { locals = locals, storyBattles = storyBattles }

return pack
