--!strict
-- The Mire's tamers: five locals met along the routes, the rival mid-biome and a local champion at
-- the gate. Names are original placeholders. Every move is one the creature can know at that level
-- (tests/mire.test checks this). Teams are four from here on (three badges, ProfileConfig). Levels
-- rise with the routes (33 to 42) and stay at or under the gate's 42 to 45, so a player who has
-- fought the tamers on the way arrives ready for the gate.
--
-- Teaching poison. Every local team carries at least one poisoning move (Venom Nip, Broth Spit,
-- Fume Belch, Barb Sting), from the first tamer on, and every team has a Toxic creature that cannot
-- be poisoned, so the player sees both halves of the rule before the gate. The first tamer's lines
-- say it plainly; the healer said it first (story/Chapter4.luau).
--
-- The gates alternate as in the brief: Greenwood and Tide Flats were held by the rival, so the
-- Mire's is held by a local champion, the sluice keeper Honora Vell, like Dust Canyon's warden, and
-- the rival appears mid-biome. His arc moves one step (brief section 9): his team's tint is 0.85
-- (Greenwood 0.25, Dust Canyon 0.5, Tide Flats 0.75; kept under 1 to leave room for later
-- biomes), and he has tried to take the Mire's giant by force with the glint and failed, the first
-- step towards "giants taken by force". He still leads with the starter that counters the player's,
-- as in every biome so far, and behind it fields Mire creatures and creatures that cover the
-- player's answer: Toxic into Water, Sand into Leaf and Toxic, Frost and Storm into Sand.

local WorldTypes = require("../../shared/WorldTypes")

type Member = WorldTypes.TamerMember

local function member(species: string, level: number, moves: { string }): Member
	return { species = species, level = level, moves = moves }
end

local locals: { WorldTypes.Tamer } = {
	{
		id = "mr_wren",
		name = "Wren Ashby",
		look = "A reed-cutter in tall waders with a bundle of cut reeds over one shoulder",
		tier = "Tamer",
		route = "mire_route_a",
		at = 120,
		team = {
			members = {
				member("Fenwhisk", 33, { "Venom Nip", "Slick Dash", "Sludge Slap" }),
				member("Skipslick", 32, { "Venom Nip", "Slick Dash", "Sludge Slap" }),
				member("Mistrel", 32, { "Murk Dive", "Mist Snap", "Reed Paddle", "Bog Wade" }),
				member("Snaggar", 33, { "Murk Lunge", "Gar Rend", "Muck Stamp", "Bog Wade" }),
			},
			tint = 0,
		},
		before = "Four of mine, and two of them bite with poison. Still keen?",
		after = "Well waded! Poison never sticks to a Toxic creature. Catch one of your own.",
	},
	{
		id = "mr_marisol",
		name = "Marisol Venn",
		look = "A naturalist with a wide straw hat and a sketchbook full of frogs",
		tier = "Tamer",
		route = "mire_route_a",
		at = 400,
		team = {
			members = {
				member("Lilyshade", 35, { "Still Water", "Hoarmist", "Reed Paddle", "Bog Wade" }),
				member("Skipslick", 35, { "Fen Lash", "Venom Nip", "Slick Dash", "Sludge Slap" }),
				member("Keelsnap", 36, { "Shell Bash", "Hook Beak", "Muck Stamp", "Barb Sting" }),
				member("Bulbroth", 35, { "Simmer Slam", "Broth Spit", "Bog Wade", "Sludge Slap" }),
			},
			tint = 0,
		},
		before = "Hold still, I am sketching your team. Oh, you want to battle? Even better.",
		after = "Marvellous! I have drawn every move. The lights by the water are not lanterns, you know.",
	},
	{
		id = "mr_barnaby",
		name = "Barnaby Tull",
		look = "A broad peat cutter with a turf spade and a flat cap black with peat dust",
		tier = "Tamer",
		route = "mire_route_b",
		at = 110,
		team = {
			members = {
				member("Bogbellow", 38, { "Mire Crush", "Fume Belch", "Bog Wade", "Peat Butt" }),
				member("Snaggar", 37, { "Murk Lunge", "Snag Bite", "Gar Rend", "Barb Sting" }),
				member("Mistrel", 37, { "Murk Dive", "Hoarmist", "Fen Plunge", "Bog Wade" }),
				member("Keelsnap", 37, { "Shell Bash", "Gar Rend", "Hook Beak", "Bog Wade" }),
			},
			tint = 0,
		},
		before = "Cut peat since dawn. A battle will warm me up nicely.",
		after = "Ha! Dug yourself out of that one. Keep to the boards past the hamlet.",
	},
	{
		id = "mr_ysolde",
		name = "Ysolde Greaves",
		look = "A marsh-light watcher with a long pole, a notebook and a coat stitched with little mirrors",
		tier = "Tamer",
		route = "mire_route_b",
		at = 400,
		team = {
			members = {
				member("Lilyshade", 39, { "Still Water", "Hoarmist", "Fen Plunge", "Bog Wade" }),
				member("Fenwhisk", 39, { "Fen Lash", "Slick Dash", "Sludge Slap", "Venom Nip" }),
				member("Bulbroth", 40, { "Mire Crush", "Bog Wade", "Sludge Slap", "Broth Spit" }),
				member("Snaggar", 40, { "Murk Lunge", "Snag Bite", "Bog Wade", "Gar Rend" }),
			},
			tint = 0,
		},
		before = "I count the marsh lights each night. Tonight there are too many. Battle me.",
		after = "Calm and clear. The lights drift toward the grove now. Something big is awake.",
	},
	{
		id = "mr_cuthbert",
		name = "Cuthbert Mott",
		look = "The sluice keeper's helper, a cheerful lad with a huge iron key on a string",
		tier = "Tamer",
		route = "mire_route_b",
		at = 620,
		team = {
			members = {
				member("Keelsnap", 42, { "Shell Bash", "Bog Wade", "Gar Rend", "Hook Beak" }),
				member("Bogbellow", 41, { "Mire Crush", "Bog Wade", "Fume Belch", "Peat Butt" }),
				member("Skipslick", 41, { "Fen Lash", "Slick Dash", "Sludge Slap", "Venom Nip" }),
				member("Mistrel", 42, { "Murk Dive", "Hoarmist", "Reed Paddle", "Bog Wade" }),
			},
			tint = 0,
		},
		before = "Nobody sees Keeper Vell without seeing me first. Rules of the sluice!",
		after = "You will do. Bring creatures that shrug off poison, hers bite hard.",
	},
}

-- The rival, mid-biome. One team for each starter the player picked.
local rivalTeams: WorldTypes.ByStarter<WorldTypes.TamerTeam> = {
	-- The player picked Mossmitt (Leaf): Sand leads, with Toxic answers to Water and a Sand tank.
	Mossmitt = {
		members = {
			member("Spadesnout", 39, { "Dig Strike", "Grit Spray", "Dust Kick", "Scree Kick" }),
			member("Snaggar", 38, { "Murk Lunge", "Snag Bite", "Gar Rend", "Bog Wade" }),
			member("Cocklemole", 38, { "Burrow Burst", "Red Tide", "Shell Grind", "Cockle Crack" }),
			member("Skipslick", 38, { "Fen Lash", "Slick Dash", "Sludge Slap", "Venom Nip" }),
		},
		tint = 0.85,
	},
	-- The player picked Spadesnout (Sand): Water leads, with a Sand tank, a Frost carrier and a poisoner.
	Spadesnout = {
		members = {
			member("Sloshcalf", 39, { "Ripple Ram", "Mud Slap", "Brook Rush", "Spore Puff" }),
			member("Moatkeep", 38, { "Rampart Slam", "Red Tide", "Shell Grind", "Cockle Crack" }),
			member("Lilyshade", 38, { "Still Water", "Hoarmist", "Fen Plunge", "Bog Wade" }),
			member("Bulbroth", 38, { "Mire Crush", "Bog Wade", "Sludge Slap", "Broth Spit" }),
		},
		tint = 0.85,
	},
	-- The player picked Sloshcalf (Water): Leaf leads, with Water and Storm answers and a poisoner.
	Sloshcalf = {
		members = {
			member("Mossmitt", 39, { "Bramble Rake", "Thorn Volley", "Leaf Gust", "Spore Puff" }),
			member("Mistrel", 38, { "Murk Dive", "Hoarmist", "Fen Plunge", "Bog Wade" }),
			member("Thatchling", 38, { "Agave Lance", "Needle Fan", "Dust Squall", "Spine Jab" }),
			member("Fenwhisk", 38, { "Fen Lash", "Slick Dash", "Sludge Slap", "Venom Nip" }),
		},
		tint = 0.85,
	},
}

local storyBattles: { WorldTypes.StoryBattle } = {
	{
		id = "rival_mire",
		name = "Rival",
		look = "A pale, muddy youth in a torn grey-green jacket, three amber shards at his belt, a snapped rope over one shoulder",
		tier = "Rival",
		place = "stilt_hamlet",
		xpKind = "Rival",
		teams = rivalTeams,
		before = "I nearly had the giant in the grove. The glint nearly made it listen. Out of my way.",
		after = "Quiet again. I hate the quiet. Go on. The grove is yours, if the giant lets you.",
		cannotLose = false, -- he can be lost to here; only the very first battle cannot
	},
	{
		id = "champion_vell",
		name = "Honora Vell",
		look = "A tall sluice keeper in a long waxed coat and waders, a ring of big iron keys at her belt",
		tier = "Rival",
		place = "mire_gate",
		xpKind = "Gate",
		team = {
			members = {
				member("Fenwhisk", 41, { "Fen Lash", "Slick Dash", "Sludge Slap", "Venom Nip" }),
				member("Lilyshade", 42, { "Still Water", "Hoarmist", "Reed Paddle", "Bog Wade" }),
				member("Bulbroth", 42, { "Mire Crush", "Bog Wade", "Sludge Slap", "Broth Spit" }),
				member("Bogbellow", 43, { "Mire Crush", "Fume Belch", "Bog Wade", "Peat Butt" }),
			},
			tint = 0,
		},
		before = "The sluice opens for a steady team. Four of mine against four of yours.",
		after = "Steady, and poison-wise. The Bulrush Badge is yours. Mind the cold road.",
		cannotLose = false,
	},
}

local pack: WorldTypes.BiomeTamers = { locals = locals, storyBattles = storyBattles }

return pack
