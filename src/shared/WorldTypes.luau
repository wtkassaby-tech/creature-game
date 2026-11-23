--!strict
-- Record types for the world's data: biomes, routes, spawn tables, tamers, quests, story beats and
-- dialogue. Data only, no logic. The data lives in src/content/ and the helpers in World.luau.
--
-- Typing note (see Types.luau): fixed sets of keys are records (ByStarter), not maps.
--
-- Over ~400 lines on purpose: it is one list of record types with no logic, and the map and
-- dressing sheets' types are read together with the biome types they refer to.

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
-- The shape of the ground (docs/plans/12_MAP_STRUCTURE.md section 4a). A Box is axis-aligned,
-- `at` its middle and `size` { across (x), deep (z) }; a Strip is a segment widened by `r`.
export type Shape =
	{ kind: "Disc", at: SheetPoint, r: number }
	| { kind: "Box", at: SheetPoint, size: { number } }
	| { kind: "Strip", from: SheetPoint, to: SheetPoint, r: number }
-- A point in world coordinates (x, z in studs; north is -z), as opposed to a SheetPoint, which is
-- relative to a hub. The plan's world data (docs/plans/13_WORLD_DESIGN.md section 11c) uses these.
export type WorldPoint = { x: number, z: number }
-- Where a biome's hub stands in the world, when it is not "straight on past the sealed road".
-- `base` is the ground height at the hub; `floor` is the fall line (Stormreach).
export type Site = { hub: WorldPoint, base: number, floor: number? }
-- A flat top at `height`; the ground is 0 where no tier lies, and later tiers win where they overlap.
export type Tier = { id: string, height: number, shape: Shape }
-- Stairs and ramps join two heights both ways, from `from` (the low end) along the line you walk to
-- `to` (the high end), `width` across. A Ledge is a stretch of a tier's lip you can hop down but
-- never climb: `from` to `to` along the lip with the high ground on the left, `width` the depth
-- of the stretch across the lip.
export type Link = {
	id: string,
	kind: "Stairs" | "Ramp" | "Ledge",
	from: SheetPoint,
	to: SheetPoint,
	width: number,
}
-- Walkable space beside a route: a clearing, a pocket, a field.
export type Room = { id: string, shape: Shape }
-- A half-width at a distance along a route; between keys it eases linearly.
export type WidthKey = { at: number, half: number }
-- An extra patch of long grass in a stretch (a circle of radius `r`). The stretch's own patch is
-- the place `{area}_grass` with the radius WorldConfig.GRASS_RADIUS; these come after it.
export type GrassPatch = { at: SheetPoint, r: number }
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
	-- Levels, links, rooms and narrow lanes (docs/plans/12_MAP_STRUCTURE.md section 4a). All left
	-- out in a biome that is still flat with wide corridors.
	tiers: { Tier }?,
	links: { Link }?,
	rooms: { Room }?,
	-- Half-width of each route (and the lair's spur) along its length, by route id. When given it
	-- replaces `corridor`, which then holds the widest value of each stretch.
	widths: { [string]: { WidthKey } }?,
	-- More patches of long grass, by stretch id, besides the stretch's own (Ayrton, 23 November
	-- 2026: patches you can walk round, never a field you must cross).
	grass: { [string]: { GrassPatch } }?,
}

-- A biome's dressing sheet: how the designed map looks (water, lanes, fences, signs, trees). The
-- server's checks never read it; only the test map builder and tests/layout.test do. Points are
-- relative to the hub's centre like the map sheet; colours are { r, g, b }.
export type Colour = { number }
-- "Rope" is a rope rail on driftwood posts (across a lane: a broken rope bridge); "Rockfall" is
-- a heap of boulders (docs/plans/09_DUST_CANYON_MAP.md section 4c).
export type FenceStyle = "Picket" | "Rustic" | "Stone" | "Gate" | "Bramble" | "Rope" | "Rockfall"
-- `deck` raises a lane on planks and posts: a quay, a boardwalk, a jetty.
export type DressLane = { points: { SheetPoint }, width: number, colour: Colour, deck: boolean? }
export type DressWater = { points: { SheetPoint }, width: number, colour: Colour }
export type DressFence = {
	points: { SheetPoint },
	style: FenceStyle,
	across: boolean?, -- true when it closes a lane or path on purpose (an old fence, a shut gate)
}
export type DressTree = { at: SheetPoint, model: string, scale: number? }
export type DressRow = { from: SheetPoint, to: SheetPoint, step: number, model: string }
export type DressSign = { at: SheetPoint, faces: number, lines: { string } }
-- `model` names the painted arch (left out: VillageArch).
export type DressArch = {
	at: SheetPoint,
	faces: number,
	outside: string,
	inside: string,
	model: string?,
}
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
-- How a corridor edge or a wall is built (docs/plans/09_DUST_CANYON_MAP.md section 4c).
-- SeaCliff is Cliff in grey sea rock (Tide Flats): the same build, its own painted piece.
export type EdgeStyle =
	"Hedge"
	| "Cliff"
	| "SeaCliff"
	| "Boulders"
	| "Rocks"
	| "Dunes"
	| "Rope"
	| "SeaWall"
-- The two edges of a stretch, as seen walking away from town.
export type DressEdge = { left: EdgeStyle, right: EdgeStyle }
-- A wall, cliff, dune ridge or sea wall that is not a corridor edge: the town's edge, a gorge wall.
-- "Earth" is a grassy bank, "Cliff" painted rock.
export type TierFace = "Earth" | "Cliff" | "SeaCliff" -- SeaCliff: grey sea rock (Tide Flats)
export type TierLook = { top: Colour, face: TierFace }
export type DressWall = { points: { SheetPoint }, style: EdgeStyle, tall: number? }
-- A flat axis-aligned rectangle of colour laid on the ground: the sea, a mudflat, a gorge floor.
export type DressFlat = { from: SheetPoint, to: SheetPoint, colour: Colour, water: boolean }
-- The far landmark the player walks toward.
export type DressLandmark = { at: SheetPoint, model: string, tall: number, faces: number }
-- What a stretch's long grass is made of: the tuft model and the disc under it.
export type GrassLook = { model: string, under: Colour }
export type LaneSurface = {
	route: string,
	from: number,
	to: number,
	colour: Colour,
	deck: boolean?,
}
-- Ambient particles and lights (docs/plans/11_STUDIO_POLISH.md, package 2). Looks per kind are in
-- src/config/AmbienceConfig; a sheet only says which, where and how strong.
export type AmbienceKind =
	"Smoke"
	| "Embers"
	| "Halo"
	| "Pollen"
	| "Fluff"
	| "Dust"
	| "Spray"
	| "Mist"
	| "Glint"
export type AmbienceLight = { range: number, brightness: number, colour: Colour? }
-- One effect by hand: `area` is { width, depth } of the volume it fills (left out: a point),
-- `height` is studs above the ground, `rate` and `scale` default to the kind's.
export type AmbienceSource = {
	kind: AmbienceKind,
	at: SheetPoint,
	height: number?,
	area: { number }?,
	rate: number?,
	scale: number?,
	light: AmbienceLight?,
}
-- Where a chimney's smoke starts on a house, as fractions of its { width, height, depth } measured
-- from its middle (across: positive to the right of its facing; back: positive behind it).
export type ChimneyOffset = { number }
export type Ambience = {
	-- By model name: every house of that model (dressing.houses and `smokeHouses`) smokes.
	chimneys: { [string]: ChimneyOffset }?,
	smokeHouses: { DressHouse }?, -- hub buildings that are houses too, copied from the map sheet
	lamps: AmbienceLight?, -- every lamp in `lamps` gets this light and a faint halo
	glints: boolean?, -- a slow sparkle on its pools, pond and flats of water
	sources: { AmbienceSource },
}

-- The solid ground beyond a biome's edges (docs/plans/12_MAP_STRUCTURE.md section 10, step 1):
-- "Forest" is walls of tall trees, "Rock" is spires and mesas, "Dune" is sand banks, "Swamp" is mangrove and cypress over mossy mounds. `band` is how
-- far past the edge it reaches, and `floor` is the colour of the open ground glimpsed through it.
export type FillStyle = "Forest" | "Rock" | "Dune" | "Swamp"
export type DressFill = { style: FillStyle, band: number, floor: Colour }

-- Every field marked "left out" is optional: a biome without that feature leaves it out and the
-- builder skips it (Greenwood fills them all in).
export type DressingSheet = {
	ground: { DressGround },
	townGround: Colour, -- the town's ground
	fieldGround: Colour?, -- the open ground outside town and corridors; left out, Greenwood's green
	laneColour: Colour, -- route lanes
	laneSurfaces: { LaneSurface },
	laneWidth: number,
	lanes: { DressLane }, -- streets, side paths, the jetty and the shortcut
	footpaths: { DressLane }, -- mown paths with rustic rails both sides
	stones: { { from: SheetPoint, to: SheetPoint } }, -- stepping stones
	-- `colour` and `rimColour` are left out for the usual cobbles.
	plaza: { at: SheetPoint, size: number, rim: number, colour: Colour?, rimColour: Colour? },
	well: SheetPoint?,
	water: { DressWater },
	pools: { { at: SheetPoint, radius: number, colour: Colour } },
	pond: { at: SheetPoint, radius: number, colour: Colour, jetty: { SheetPoint } }?,
	waterfall: SheetPoint?, -- above the first pool
	-- Other falls where water drops off a tier: the foot of the fall, and the way the water comes from.
	falls: { { at: SheetPoint, towards: SheetPoint } }?,
	-- How each tier looks (a map sheet's tiers, by id): the colour of its flat top and the face its
	-- sides wear. A tier left out has a grassy top and an earth face.
	tierLooks: { [string]: TierLook }?,
	footbridge: { at: SheetPoint, faces: number, length: number, width: number }?,
	flats: { DressFlat }?, -- drawn in order, each a hair above the last
	arches: { DressArch },
	signs: { DressSign },
	lamps: { SheetPoint },
	beds: { SheetPoint },
	trees: { DressTree },
	rows: { DressRow },
	fences: { DressFence },
	hedges: { { SheetPoint } }, -- the town's edge, already broken at its gaps (may be empty)
	walls: { DressWall }?, -- cliffs, dunes and sea walls that are not corridor edges
	-- The style of each corridor's two edges, by area id and lair id; a stretch left out keeps
	-- hedges.
	edges: { [string]: DressEdge }?,
	-- The edge round each room (pocket, field, dead end) of the sheet: Hedge if not given.
	roomEdge: EdgeStyle?,
	buildings: { [string]: { width: number, depth: number, tall: number } }, -- hub buildings
	houses: { DressHouse }, -- cottages with no keeper (the gatehouse hamlet)
	people: { DressPerson }, -- villagers with nothing to say yet
	props: { DressProp }, -- homely things: carts, washing lines, barrels, apple trees
	knoll: { at: SheetPoint, size: { number } }?,
	picnic: { at: SheetPoint, radius: number }?,
	pocket: { at: SheetPoint, radius: number }?,
	clearings: { DressClearing },
	caps: { [string]: number }, -- by route: half the gap left in the hedge across its far end
	-- By area id and lair id; left out, Tree and Pine.
	corridorTrees: { [string]: { model: string, scale: number } },
	-- `model` left out: Gatehouse; `banner` left out: "Acorn Badge".
	gatehouse: { at: SheetPoint, faces: number, model: string?, banner: string? },
	bar: { at: SheetPoint, width: number },
	ancientTree: { at: SheetPoint, tall: number, model: string? }?, -- model: AncientTree if not given
	landmark: DressLandmark?,
	grassLooks: { [string]: GrassLook }?, -- by area id; left out, GrassTuft on (78, 128, 58)
	stall: { side: number }, -- which side of the spur the stall's counter stands
	ring: { width: number, depth: number, gap: number, style: FenceStyle? }, -- rail: Rustic
	brambles: { SheetPoint }, -- may be empty
	coop: SheetPoint?,
	patch: { from: SheetPoint, to: SheetPoint }?, -- the mentor's vegetable rows
	fill: DressFill?, -- the trees, rock or dunes that close in everything past the edges
	ambience: Ambience?, -- smoke, lights and drifting motes (src/server/World/Ambience)
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
	-- World placement and extent (docs/plans/13_WORLD_DESIGN.md section 11b). Both optional: with no
	-- `site` the hub goes straight on past the previous biome's sealed road, and with no `region`
	-- the biome owns whatever is nearest one of its places. `region` is in world coordinates.
	site: Site?,
	region: Shape?,
}

-- The world as one journey (docs/plans/13_WORLD_DESIGN.md section 11c). Data only.
export type PassageKind =
	"Gatehouse"
	| "Pass"
	| "Causeway"
	| "CaveMouth"
	| "Tunnel"
	| "Lift"
	| "Stair"
	| "Bridge"
	| "Ferry"
-- The walk between one biome's sealed road and the next town's arch, in world coordinates.
-- `swapAt` is studs along `points` where the sky and music change; it lies somewhere hidden
-- (a gatehouse, a tunnel, a cloud layer). `swapRadius` is how near the player must be to it.
export type Passage = {
	id: string,
	from: number, -- biome numbers
	to: number,
	kind: PassageKind,
	points: { WorldPoint },
	heights: { number }, -- y at each point
	width: number,
	swapAt: number,
	swapRadius: number,
	stations: { [string]: WorldPoint }?,
}
-- A patch of the world with a light, sky and sound preset (ClimateConfig). Its weight is 1 inside
-- `shape` and eases to 0 over `band` studs beyond the edge. A zone of higher `priority` (a cave
-- inside a biome) scales the others down. `hidden` marks a tunnel, cave or cloud, where a preset
-- may change faster than the usual limit.
export type ClimateZone = {
	id: string,
	preset: string,
	shape: Shape,
	band: number,
	priority: number?,
	hidden: boolean?,
}
export type WorldLandmark = {
	id: string,
	model: string,
	at: WorldPoint,
	base: number,
	tall: number,
	faces: number,
	seenFrom: { string },
	shownWhen: string?,
}
export type SideArea = {
	id: string,
	name: string,
	owner: number,
	preset: string,
	shape: Shape,
	entrance: WorldPoint,
	opens: { badges: number?, flag: string? }?,
	offers: { string },
}
-- One far-off impostor (docs/plans/13_WORLD_DESIGN.md sections 3c and 10). `model` is a painted
-- model's name (PropModels) or a plain form: "Lump" (a dome rising `size[2]` above `base`) or
-- "Puff" (a whole oval cloud whose underside is at `base`). `size` is { width, height, depth } in
-- studs before `scale`; width runs across the facing, depth along it. `faces` is a yaw in degrees
-- clockwise from north. `colour` is { r, g, b }; the builder tints it toward the haze by the
-- layer's own amount, so far pieces fade like distant hills.
export type FarScenery = {
	id: string,
	layer: string,
	model: string,
	at: WorldPoint,
	base: number,
	scale: number,
	faces: number,
	size: { number },
	colour: { number },
}
export type Shortcut = { id: string, from: string, to: string, oneWayUntil: string? }

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

-- Finds -------------------------------------------------------------------------------------

-- Things to find in side areas and dead ends (docs/plans/14_FINDS_AND_REWARDS.md, approved 23
-- November 2026). A Cache is one-time; a Gather spot gives its biome's material once a day; a
-- Sighting is the first stir of a rustle spot each day; a Cairn is one-time and gives a keepsake;
-- a Note is a page of the journal. Find ids are permanent: never renamed, reused or removed.
export type FindKind = "Cache" | "Gather" | "Sighting" | "Cairn" | "Note"
-- A cosmetic object shown on the journal's shelf: owned when its cairn or set is claimed.
export type Keepsake = { id: string, name: string }
export type Find = {
	id: string,
	biome: number,
	kind: FindKind,
	name: string,
	-- Where it is: `at` is hub-relative like a map sheet's points; `route`, `along` and `side` are a
	-- point down a route (side: studs to its left, negative to the right). A Sighting has neither
	-- (it is the rustle spot `spot`), and a find whose place is not built yet has neither.
	at: SheetPoint?,
	route: string?,
	along: number?,
	side: number?,
	spot: string?, -- Sighting: the rustle spot's id
	rewards: { Reward }, -- Item and Material only; nothing here may pay coins, creatures or Gems
	keepsake: Keepsake?, -- Cairn only
	text: { string }?, -- Note only: what the page says
	hidden: boolean?, -- found through a gap or behind something; the device shows no hint
	pending: string?, -- why it cannot be reached yet (its place is not in the map); the server treats it as shut
}
-- Every note of one biome read gives a keepsake and Prism Candy, once.
export type JournalSet = {
	id: string,
	biome: number,
	name: string,
	notes: { string }, -- find ids of kind Note
	keepsake: Keepsake,
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
