--!strict
-- The ten-type chart (research/market/07_BATTLE_AND_PVP.md section 3).
-- Every type is strong against exactly two types and weak against exactly two.

local Types = require("./Types")

type Element = Types.Element

local TypeChart = {}

export type ByElement<T> = {
	Leaf: T,
	Sand: T,
	Water: T,
	Toxic: T,
	Frost: T,
	Crystal: T,
	Fire: T,
	Storm: T,
	Arcane: T,
	Cosmic: T,
}

local ELEMENTS: { Element } =
	{ "Leaf", "Sand", "Water", "Toxic", "Frost", "Crystal", "Fire", "Storm", "Arcane", "Cosmic" }
TypeChart.ELEMENTS = ELEMENTS

-- attacker -> the two types it is strong against
TypeChart.STRONG = {
	Leaf = { "Water", "Crystal" },
	Sand = { "Leaf", "Toxic" },
	Water = { "Sand", "Fire" },
	Toxic = { "Water", "Arcane" },
	Frost = { "Toxic", "Crystal" },
	Crystal = { "Storm", "Cosmic" },
	Fire = { "Leaf", "Frost" },
	Storm = { "Sand", "Cosmic" },
	Arcane = { "Frost", "Storm" },
	Cosmic = { "Fire", "Arcane" },
} :: ByElement<{ Element }>

TypeChart.STRONG_MULTIPLIER = 1.5
TypeChart.WEAK_MULTIPLIER = 0.67
TypeChart.OWN_TYPE_MULTIPLIER = 1.2 -- a move of the creature's own type

function TypeChart.isStrong(attack: Element, defender: Element): boolean
	return table.find(TypeChart.STRONG[attack], defender) ~= nil
end

-- Damage multiplier for a move of type `attack` hitting a creature of type `defender`.
function TypeChart.multiplier(attack: Element, defender: Element): number
	if TypeChart.isStrong(attack, defender) then
		return TypeChart.STRONG_MULTIPLIER
	elseif TypeChart.isStrong(defender, attack) then
		return TypeChart.WEAK_MULTIPLIER -- attacking into a type that beats yours
	end
	return 1
end

return TypeChart
