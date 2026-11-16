--!strict
-- Works out a creature's battle stats from its parts. Nothing here is saved on the creature:
-- the same parts, qualities, size, level and rarity always give the same stats.

local BreedConfig = require("../config/BreedConfig")
local Species = require("../content/Species")
local Types = require("./Types")

export type StatBlock = Types.StatBlock

local Stats = {}

function Stats.qualityMultiplier(quality: number): number
	return 1 + (quality - BreedConfig.QUALITY_MID) * BreedConfig.QUALITY_STEP
end

-- The fit factor: how well the legs suit the body they now carry.
-- Uses each species' fixed weight, so it cannot compound over generations.
function Stats.fit(creature: Types.Creature): number
	local legSpecies = Species[creature.parts.Legs.species]
	local torsoSpecies = Species[creature.parts.Torso.species]
	local bodyWeight = torsoSpecies.weight * creature.size
	local raw = math.sqrt(legSpecies.weight / bodyWeight)
	return math.clamp(raw, BreedConfig.FIT_MIN, BreedConfig.FIT_MAX)
end

function Stats.levelScale(level: number): number
	return 1 + (level - 1) * BreedConfig.LEVEL_SCALE_PER_LEVEL
end

-- How far a set of base stats is over the body plan's shared budget: 1 if within it.
local function budgetFactor(creature: Types.Creature, base: StatBlock): number
	local score = base.Hp * BreedConfig.BUDGET_HP_WEIGHT + base.Attack + base.Defence + base.Speed
	local cap = BreedConfig.PLAN_BUDGET[creature.bodyPlan] * BreedConfig.BUDGET_CAP
	return math.min(1, cap / score)
end

-- Stats at a given level (ranked play passes a common level here).
function Stats.compute(creature: Types.Creature, levelOverride: number?): StatBlock
	local base: StatBlock = { Hp = 0, Attack = 0, Defence = 0, Speed = 0 } -- at quality 5
	local totals: StatBlock = { Hp = 0, Attack = 0, Defence = 0, Speed = 0 }
	local fit = Stats.fit(creature)
	for _, slot: Types.Slot in BreedConfig.SLOTS do
		local part = creature.parts[slot]
		local def = Species[part.species].parts[slot]
		local quality = Stats.qualityMultiplier(part.quality)
		for _, stat: Types.Stat in BreedConfig.STATS do
			local value = def.stats[stat]
			if value then
				if slot == "Legs" and stat == "Speed" then
					value *= fit
				elseif slot == "Torso" then
					value *= creature.size -- a bigger body has more Hp and Defence
				end
				base[stat] += value
				totals[stat] += value * quality
			end
		end
	end
	local scale = budgetFactor(creature, base)
		* Stats.levelScale(levelOverride or creature.level)
		* BreedConfig.RARITY_BOOST[creature.rarity]
	return {
		Hp = math.floor(totals.Hp * scale),
		Attack = math.floor(totals.Attack * scale),
		Defence = math.floor(totals.Defence * scale),
		Speed = math.floor(totals.Speed * scale),
	}
end

-- Moves the creature can choose from: every move its parts bring that has unlocked by its level.
-- Pass a level to ask about another level (ranked play scales everything to one level).
function Stats.movePool(creature: Types.Creature, levelOverride: number?): { string }
	local level = levelOverride or creature.level
	local pool = {}
	for _, slot: Types.Slot in BreedConfig.SLOTS do
		for _, unlock in Species[creature.parts[slot].species].parts[slot].moves do
			if unlock.level <= level and not table.find(pool, unlock.name) then
				table.insert(pool, unlock.name)
			end
		end
	end
	return pool
end

return Stats
