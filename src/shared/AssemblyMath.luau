--!strict
-- The numbers the client assembler needs to fit one species' part onto another's torso.
-- Pure maths, shared with the tests, so "does it fit" can be checked without Studio.

local Species = require("../content/Species")
local Types = require("./Types")

local AssemblyMath = {}

AssemblyMath.SCALE_MIN = 0.6
AssemblyMath.SCALE_MAX = 1.6

-- How much to scale a donor part so its ball end fills the torso's socket.
function AssemblyMath.partScale(torsoSpecies: string, slot: Types.Slot, partSpecies: string): number
	if slot == "Torso" then
		return 1
	end
	local socket = Species[torsoSpecies].socketRadius[slot]
	local plug = Species[partSpecies].parts[slot].plugRadius
	return math.clamp(socket / plug, AssemblyMath.SCALE_MIN, AssemblyMath.SCALE_MAX)
end

-- Per-slot scale for a whole creature, before the size gene is applied to the model.
function AssemblyMath.partScales(creature: Types.Creature): Types.BySlot<number>
	local torso = creature.parts.Torso.species
	local function scale(slot: Types.Slot): number
		return AssemblyMath.partScale(torso, slot, creature.parts[slot].species)
	end
	return {
		Head = scale("Head"),
		Torso = 1,
		FrontLimbs = scale("FrontLimbs"),
		Legs = scale("Legs"),
		Tail = scale("Tail"),
	}
end

-- Height of the torso's leg sockets above the ground, in studs, so the feet touch the floor.
function AssemblyMath.rideHeight(creature: Types.Creature): number
	local legs = creature.parts.Legs.species
	local scale = AssemblyMath.partScale(creature.parts.Torso.species, "Legs", legs)
	return Species[legs].parts.Legs.length * scale * creature.size
end

return AssemblyMath
