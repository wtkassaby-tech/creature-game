--!strict
-- Record types for the world's data: biomes, routes, spawn tables, tamers, quests, story beats and
-- dialogue. Data only, no logic. The data lives in src/content/ and the helpers in World.luau.
--
-- Typing note (see Types.luau): fixed sets of keys are records (ByStarter), not maps.

local BattleAi = require("./BattleAi")
local EconomyConfig = require("../config/EconomyConfig")
local Types = require("./Types")

-- The three starters. The rival's team depends on which one the player picked.
export type Starter = "Mossmitt" | "Spadesnout" | "Sloshcalf"
export type ByStarter<T> = { Mossmitt: T, Spadesnout: T, Sloshcalf: T }

-- Rewards ------------------------------------------------------------------------------------

-- The ways the game can hand something over. Coins, PrismCandy, Item and Material are the
-- economy's (EconomyConfig); Creature, Egg, Pen, Starter and Badge are gifts. Story and quest
-- rewards pay Prism Candy (working name), which counts as any type; typed candy comes only from
-- catching and releasing creatures.
export type RewardKind =
	"Coins"
	| "PrismCandy"
	| "Item"
	| "Material"
	| "Creature"
	| "Egg"
	| "Pen"
	| "Starter"
	| "Badge"

export type Reward =
	{ kind: "Coins", amount: number }
	| { kind: "PrismCandy", amount: number }
	| { kind: "Item", item: EconomyConfig.ItemId, count: number }
	| { kind: "Material", material: EconomyConfig.MaterialId, count: number }
	| { kind: "Creature", species: string, level: number, rarity: Types.Rarity, colour: string }
	| { kind: "Egg", parentA: string, parentB: string }
	| { kind: "Pen" }
	| { kind: "Starter", choices: { string }, level: number }
	| { kind: "Badge", id: string, name: string }

-- Dialogue -----------------------------------------------------------------------------------

-- One spoken line. Keep it short: at most 90 characters, and at most three lines in a beat.
export type DialogueLine = { speaker: string, text: string }

-- Wild creatures ----------------------------------------------------------------------------

-- A stretch of a route. Distances are studs along the route, measured from the hub.
export type Area = {
	id: string,
	name: string,
	from: number,
	to: number,
	minLevel: number,
	maxLevel: number,
	note: string, -- what the place looks like, for the builder
}

-- One row of a route's spawn table. `spot` is nil for an ordinary open spawn, or the id of the
-- rustle spot where this row can appear. Uncommon species live only in rows with a spot.
export type SpawnEntry = {
	species: string,
	weight: number, -- relative chance among the rows that can be drawn together
	minLevel: number,
	maxLevel: number,
	area: string, -- an Area id on this route
	spot: string?, -- a RustleSpot id, or nil
	colours: { string }, -- the ordinary colours (names from BreedConfig.COLOURS)
	-- The tier of creature this row gives; left out, it is the species' usual tier. A gem-tier
	-- row is a rare find: caught, it gets a serial number.
	rarity: Types.Rarity?,
	rareColourChance: number, -- chance of one of the rare colours instead
}

-- A patch of long grass or reeds that rustles; stepping in draws from the rows tagged with its id.
export type RustleSpot = {
	id: string,
	name: string,
	area: string,
	at: number, -- studs along the route from the hub
	note: string,
}

-- The world -----------------------------------------------------------------------------------

-- `npc` is the id of the character who lives there, for story beats that start by talking to them.
export type Building = { id: string, name: string, role: string, npc: string? }

export type Hub = {
	id: string,
	name: string,
	size: number, -- studs, square
	landmark: string,
	buildings: { Building },
}

export type Route = {
	id: string,
	name: string,
	length: number, -- studs of path
	width: string, -- how wide the path and meadows are, for the builder
	note: string,
	areas: { Area }, -- in order from the hub
	spawns: { SpawnEntry },
	rustleSpots: { RustleSpot },
	tamers: { string }, -- ids of the local tamers met on this route
}

export type Lair = {
	id: string,
	name: string,
	joinsRoute: string, -- the route the spur leaves
	joinsAt: number, -- studs along that route
	spurLength: number,
	arenaSize: number,
	giant: string, -- a key of Giants
	supplyStall: string,
	shortcutToHub: boolean, -- opens once the giant is beaten
}

export type Gate = {
	id: string,
	name: string,
	route: string, -- the route it ends
	at: number,
	battle: string, -- the story battle that opens it
	badge: { id: string, name: string },
	sealedPath: string, -- place id of the road to the next biome, shut until the badge
	nextBiome: number,
	recommendedMin: number, -- a team's levels on arrival
	recommendedMax: number,
}

-- A biome's map sheet: where a designer put things, instead of where the generated layout would.
-- Every point is in studs relative to the hub's centre; north is -z. A facing is in degrees
-- clockwise from north (0 north, 90 east), so it points along (sin, -cos). Layout reads the sheet;
-- a biome without one keeps the generated layout (docs/plans/08_GREENWOOD_MAP.md section 4).
export type SheetPoint = { x: number, z: number }
export type SheetBuilding = {
	at: SheetPoint, -- the building's middle
	faces: number,
	door: SheetPoint?, -- where its keeper stands; left out, a set distance in front of the middle
	model: string?, -- the painted model it wears (a PropModels name)
}
export type MapSheet = {
	-- A route's waypoints from the hub outwards. Layout fits them to the route's data length by
	-- trimming or stretching the last leg, so distances along the route keep their meaning.
	routes: { [string]: { points: { SheetPoint } } },
	corridor: { [string]: number }?, -- half-width by area id (and by lair id for the spur)
	spurs: { [string]: { SheetPoint } }?, -- by lair id: from the join to the arena
	buildings: { [string]: SheetBuilding },
	places: { [string]: SheetPoint }, -- set spots that replace generated ones, by place id
	stands: { [string]: SheetPoint }?, -- story battle id -> where the battler stands
	faces: { [string]: number }?, -- tamer or story battle id -> facing
	spawn: { at: SheetPoint, faces: number }?,
}

-- A biome's dressing sheet: how the designed map looks (water, lanes, fences, signs, trees). The
-- server's checks never read it; only the test map builder and tests/layout.test do. Points are
-- relative to the hub's centre like the map sheet; colours are { r, g, b }.
export type Colour = { number }
export type FenceStyle = "Picket" | "Rustic" | "Stone" | "Gate" | "Bramble"
export type DressLane = { points: { SheetPoint }, width: number, colour: Colour }
export type DressWater = { points: { SheetPoint }, width: number, colour: Colour }
export type DressFence = {
	points: { SheetPoint },
	style: FenceStyle,
	across: boolean?, -- true when it closes a lane or path on purpose (an old fence, a shut gate)
}
export type DressTree = { at: SheetPoint, model: string, scale: number? }
export type DressRow = { from: SheetPoint, to: SheetPoint, step: number, model: string }
export type DressSign = { at: SheetPoint, faces: number, lines: { string } }
export type DressArch = { at: SheetPoint, faces: number, outside: string, inside: string }
export type DressHouse = {
	at: SheetPoint,
	faces: number,
	model: string,
	width: number,
	depth: number,
	tall: number,
}
export type DressPerson = { name: string, at: SheetPoint, faces: number, model: string }
-- A painted thing standing somewhere for its own sake: a cart, a washing line, an apple tree.
-- `solid` makes it block the way.
export type DressProp = {
	model: string,
	at: SheetPoint,
	faces: number,
	tall: number,
	solid: boolean?,
}
-- A patch of coloured ground: a whole stretch's corridor (`area`), or a band beside a route
-- from `from` to `to` along it, `near` to `far` studs to its left (negative: right).
export type DressGround = {
	colour: Colour,
	area: string?,
	route: string?,
	from: number?,
	to: number?,
	near: number?,
	far: number?,
}
-- A clearing the route edges go round (`ring` false: the hedge bulges out round it) or that has
-- a hedge ring of its own with a gap where a lane comes in (`ring` true).
export type DressClearing = { at: SheetPoint, radius: number, ring: boolean }
export type DressingSheet = {
	ground: { DressGround },
	townGround: Colour, -- the town's green
	laneColour: Colour, -- route lanes
	laneSurfaces: { { route: string, from: number, to: number, colour: Colour } },
	laneWidth: number,
	lanes: { DressLane }, -- streets, side paths, the jetty and the shortcut
	footpaths: { DressLane }, -- mown paths with rustic rails both sides
	stones: { { from: SheetPoint, to: SheetPoint } }, -- stepping stones
	plaza: { at: SheetPoint, size: number, rim: number },
	well: SheetPoint,
	water: { DressWater },
	pools: { { at: SheetPoint, radius: number, colour: Colour } },
	pond: { at: SheetPoint, radius: number, colour: Colour, jetty: { SheetPoint } },
	waterfall: SheetPoint,
	footbridge: { at: SheetPoint, faces: number, length: number, width: number },
	arches: { DressArch },
	signs: { DressSign },
	lamps: { SheetPoint },
	beds: { SheetPoint },
	trees: { DressTree },
	rows: { DressRow },
	fences: { DressFence },
	hedges: { { SheetPoint } }, -- the town's edge, already broken at its gaps
	buildings: { [string]: { width: number, depth: number, tall: number } }, -- hub buildings
	houses: { DressHouse }, -- cottages with no keeper (the gatehouse hamlet)
	people: { DressPerson }, -- villagers with nothing to say yet
	props: { DressProp }, -- homely things: carts, washing lines, barrels, apple trees
	knoll: { at: SheetPoint, size: { number } },
	picnic: { at: SheetPoint, radius: number },
	pocket: { at: SheetPoint, radius: number },
	clearings: { DressClearing },
	caps: { [string]: number }, -- by route: half the gap left in the hedge across its far end
	corridorTrees: { [string]: { model: string, scale: number } }, -- by area; default Tree/Pine
	gatehouse: { at: SheetPoint, faces: number },
	bar: { at: SheetPoint, width: number },
	ancientTree: { at: SheetPoint, tall: number },
	stall: { side: number }, -- which side of the spur the stall's counter stands
	ring: { width: number, depth: number, gap: number },
	brambles: { SheetPoint },
	coop: SheetPoint,
	patch: { from: SheetPoint, to: SheetPoint }, -- the mentor's vegetable rows
}

export type Biome = {
	id: string,
	number: number,
	name: string,
	element: Types.Element,
	hub: Hub,
	routes: { Route },
	lair: Lair,
	gate: Gate,
	levelMin: number, -- lowest wild level in the biome
	levelMax: number, -- highest wild level on the main routes
	map: MapSheet?, -- the designed map; nil keeps the generated layout
}

-- Tamers ------------------------------------------------------------------------------------

export type TamerMember = { species: string, level: number, moves: { string } }
-- `tint` is how dark the team looks, 0 for none: it grows each time the rival appears.
export type TamerTeam = { members: { TamerMember }, tint: number }

export type Tamer = {
	id: string,
	name: string,
	look: string, -- one line, for the builder
	tier: BattleAi.Tier,
	route: string,
	at: number, -- studs along the route from the hub
	team: TamerTeam,
	before: string, -- said before the battle
	after: string, -- said after losing
}

export type RivalDef = {
	id: string,
	name: string, -- the working role name; the real name is not chosen yet
	look: string,
	tier: BattleAi.Tier,
	first: ByStarter<TamerTeam>, -- the first battle, keyed by the player's starter
	firstBattle: string, -- the story battle id of the first battle (a beat's Win target)
	firstPlace: string, -- the place id where he stands for it
	gateBattle: string, -- the story battle id of the gate battle
	gatePlace: string,
	firstCannotBeLost: boolean, -- the server never lets the player lose it
	gate: ByStarter<TamerTeam>, -- the gate battle, keyed by the player's starter
	firstBefore: string,
	firstAfter: string,
	gateBefore: string,
	gateAfter: string,
}

-- A battle the story calls for (the rival, a gate's champion). It can be fought only while it is
-- the story's next step, and only once. `team` is one team for everyone; `teams` is one for each
-- starter the player may have picked. Exactly one of the two is set.
export type StoryBattle = {
	id: string, -- the story battle id (a beat's Win target)
	name: string,
	look: string,
	tier: BattleAi.Tier,
	place: string, -- the place id where the opponent stands
	xpKind: "Rival" | "Gate", -- how its XP is counted (ProgressionConfig.KIND_MULTIPLIER)
	team: TamerTeam?,
	teams: ByStarter<TamerTeam>?,
	before: string, -- said before the battle
	after: string, -- said after losing
	-- The player cannot lose this battle: their last creature holds on until they win. Only the
	-- rival's very first battle has it (tests/trainers.test checks that).
	cannotLose: boolean,
}

-- A biome's tamer file: its local tamers, and optionally the rival's teams there and any other
-- story battles (a gate's champion).
export type BiomeTamers = {
	locals: { Tamer },
	rival: RivalDef?,
	storyBattles: { StoryBattle }?,
}

-- Quests ------------------------------------------------------------------------------------

-- What the server counts. Every kind has one number or one id to watch.
export type Objective =
	{ kind: "WinWild", count: number, route: string }
	| { kind: "TameSpecies", species: string }
	| { kind: "BeatTamer", tamer: string }
	| { kind: "BeatGiant", giant: string }

export type Quest = {
	id: string,
	name: string,
	line: string, -- the quest line this belongs to
	step: number, -- position in the line
	optional: boolean, -- true when the line can end without it
	giver: { name: string, place: string },
	requires: { string }, -- quests that must be done first
	requiresFlags: { string }, -- story flags (beat ids) that must be set first
	objective: Objective,
	goal: string, -- the short objective text on screen
	offer: string, -- said when the quest is offered
	done: string, -- said when it is handed in
	rewards: { Reward },
}

-- Story -------------------------------------------------------------------------------------

-- How a beat starts: Start (the first thing in the game), Follow (a moment after an earlier beat),
-- Enter and Sight (a place), Win (a battle id), Tame (any creature), Talk (a character).
export type TriggerKind = "Start" | "Follow" | "Enter" | "Sight" | "Win" | "Tame" | "Talk"

export type Trigger = {
	kind: TriggerKind,
	target: string?, -- the place, battle or character, where the kind needs one
	requires: { string }, -- flags that must be set; finishing a beat sets a flag equal to its id
}

export type Beat = {
	id: string,
	name: string,
	minuteFrom: number, -- timing target for a first session, in minutes from the start
	minuteTo: number,
	trigger: Trigger,
	unlocks: { string }, -- named game features and places the beat opens
	grants: { Reward },
	lines: { DialogueLine },
}

export type Chapter = {
	id: string,
	number: number,
	name: string,
	beats: { Beat },
}

return {}
