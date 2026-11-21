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
	gateBattle: string, -- the story battle id of the gate battle
	firstCannotBeLost: boolean, -- the server never lets the player lose it
	gate: ByStarter<TamerTeam>, -- the gate battle, keyed by the player's starter
	firstBefore: string,
	firstAfter: string,
	gateBefore: string,
	gateAfter: string,
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
