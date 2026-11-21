--!strict
-- What a finished battle pays, as pure functions (economy model section 3, approval pack 1).
--
-- A wild win, or a catch (a catch counts as a win), pays coins that fall off per kind of creature
-- per day, may drop the biome's crafting material, and shares XP across the whole team (fainted
-- members get a smaller share). A loss, a draw, running and a fled creature pay nothing.
-- Every count is kept in the saved profile and reset only by the server's date.

local Economy = require("./Economy")
local EconomyConfig = require("../config/EconomyConfig")
local Grants = require("./Grants")
local Profile = require("./Profile")
local Rng = require("./Rng")
local Types = require("./Types")
local Xp = require("./Xp")

export type MemberResult = {
	id: string,
	gained: number,
	level: number,
	levelsGained: number,
	newMoves: { string },
}

export type Paid = {
	coins: number,
	material: EconomyConfig.MaterialId?,
	members: { MemberResult },
}

export type WildWinInput = {
	foe: Types.Creature, -- the wild creature beaten or caught
	team: { { id: string, fainted: boolean } }, -- the player's team in the battle, in order
	cap: number, -- the player's level cap now
	unixTime: number, -- the server's clock
	seed: number, -- from the server, for the material drop
}

local Rewards = {}

-- Pays a wild win (or catch) into the profile and returns what was paid.
function Rewards.wildWin(profile: Profile.Profile, input: WildWinInput): Paid
	Grants.rollDay(profile, input.unixTime)
	local foe = input.foe
	local kind = foe.parts.Torso.species
	local biome = math.max(1, foe.originBiome)
	local prior = profile.Daily.wildWins[kind] or 0
	local coins = Economy.battleCoins("Wild", biome, foe.level, prior, false)
	profile.Daily.wildWins[kind] = prior + 1
	profile.Coins += coins

	local material: EconomyConfig.MaterialId? = nil
	local rng = Rng.new(input.seed)
	if Rng.chance(rng, EconomyConfig.MATERIAL_DROP_CHANCE * Economy.diminishFactor(prior)) then
		local index = math.min(biome, #EconomyConfig.MATERIAL_BY_BIOME)
		local id: EconomyConfig.MaterialId = EconomyConfig.MATERIAL_BY_BIOME[index]
		profile.Items[id] = (profile.Items[id] or 0) + 1
		material = id
	end

	local defeated: Xp.Defeated = { level = foe.level, rarity = foe.rarity, kind = "Wild" }
	local members: { MemberResult } = {}
	for _, member in input.team do
		local creature = profile.Creatures[member.id]
		if creature then
			local gained =
				Xp.rewardFor(defeated, { level = creature.level, fainted = member.fainted })
			local before = creature.level
			local applied = Xp.applyXp(creature.level, creature.xp, gained, input.cap)
			creature.level, creature.xp = applied.level, applied.xp
			table.insert(members, {
				id = member.id,
				gained = gained,
				level = applied.level,
				levelsGained = applied.levelsGained,
				newMoves = Xp.newMoves(creature, before, applied.level),
			})
		end
	end
	return { coins = coins, material = material, members = members }
end

return Rewards
