--!strict
-- Shared record types for creatures and species. Data only, no logic.
--
-- Typing note: fixed sets of keys (slots, stats, rarities, body plans) are written as records
-- (BySlot, StatBlock, ByRarity, ByPlan), not as `{ [Slot]: T }` maps. The strict checker accepts
-- `record[slot]` and `record.Legs` on records, but rejects both on maps keyed by a union of names.
-- Lists of names are declared with an annotation: `local SLOTS: { Slot } = { ... }`.

export type BodyPlan = "Quad" | "Biped" | "Winged" | "Serpent"
export type Slot = "Head" | "Torso" | "FrontLimbs" | "Legs" | "Tail"
export type Stat = "Hp" | "Attack" | "Defence" | "Speed"
export type Element =
	"Leaf"
	| "Sand"
	| "Water"
	| "Toxic"
	| "Frost"
	| "Crystal"
	| "Fire"
	| "Storm"
	| "Arcane"
	| "Cosmic"
export type Rarity = "Common" | "Uncommon" | "Gem" | "Ruby" | "Diamond" | "Cosmic"

export type BySlot<T> = { Head: T, Torso: T, FrontLimbs: T, Legs: T, Tail: T }
export type ByRarity<T> = { Common: T, Uncommon: T, Gem: T, Ruby: T, Diamond: T, Cosmic: T }
export type ByPlan<T> = { Quad: T, Biped: T, Winged: T, Serpent: T }
export type StatBlock = { Hp: number, Attack: number, Defence: number, Speed: number }

-- What a creature stores for one body slot. `quality` is the only inherited number.
export type Part = {
	species: string,
	quality: number, -- integer 0..10
}
export type Parts = BySlot<Part>

export type Colour = {
	shown: string,
	carried: string,
}

export type Creature = {
	id: string,
	bodyPlan: BodyPlan,
	parts: Parts,
	size: number, -- 0.9..1.1
	colour: Colour,
	rarity: Rarity,
	level: number,
	xp: number, -- progress toward the next level; keeps building while the level cap holds it
	generation: number, -- 0 for wild-caught
	parents: { string }?, -- { idA, idB } or nil for wild-caught
	breedCount: number,
	breedReadyAt: number, -- unix seconds
	originBiome: number,
	isGiant: boolean,
	bound: boolean, -- true if it can never be traded (giants, cosmic creatures)
	serial: number?, -- its number among its kind; only giants and wild-caught gem creatures have one
}

-- A move a part brings, and the creature level at which it unlocks (1 = known from the start).
export type MoveUnlock = { name: string, level: number }

-- Base stats one part contributes. Most parts give one or two stats; the rest are left out.
export type PartStats = { Hp: number?, Attack: number?, Defence: number?, Speed: number? }

-- Fixed facts about one part of one species. Lives in data, never on a creature.
export type PartDef = {
	stats: PartStats,
	moves: { MoveUnlock },
	plugRadius: number, -- studs: radius of the ball end that sits in the torso (0 for a torso)
	length: number, -- studs: plug centre to the far tip (legs: to the foot)
}

export type SpeciesDef = {
	name: string,
	bodyPlan: BodyPlan,
	biome: number,
	baseRarity: Rarity, -- what a normal wild one is: Common or Uncommon
	lassoDifficulty: number, -- 1 is normal; higher means a narrower lasso target
	element: Element, -- the torso sets the creature's type
	weight: number, -- fixed species weight, used for the fit factor
	torsoLength: number, -- studs
	socketRadius: BySlot<number>, -- radius of each torso socket (Torso itself is 0)
	parts: BySlot<PartDef>,
}

return {}
