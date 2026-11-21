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
	biome: number?, -- where the battle was fought (the world service's route); default: the foe's home
}

local Rewards = {}

-- Pays a wild win (or catch) into the profile and returns what was paid.
function Rewards.wildWin(profile: Profile.Profile, input: WildWinInput): Paid
	Grants.rollDay(profile, input.unixTime)
	local foe = input.foe
	local kind = foe.parts.Torso.species
	local biome = math.max(1, input.biome or foe.originBiome)
	local prior = profile.Daily.wildWins[kind] or 0
	local coins = Economy.battleCoins("Wild", biome, foe.level, prior, false)

	local material: EconomyConfig.MaterialId? = nil
	local rng = Rng.new(input.seed)
	if Rng.chance(rng, EconomyConfig.MATERIAL_DROP_CHANCE * Economy.diminishFactor(prior)) then
		local index = math.min(biome, #EconomyConfig.MATERIAL_BY_BIOME)
		local id: EconomyConfig.MaterialId = EconomyConfig.MATERIAL_BY_BIOME[index]
		material = id
	end

	-- Work out every share first, then pay everything together, so an error part way through
	-- cannot leave a battle half paid.
	local defeated: Xp.Defeated = { level = foe.level, rarity = foe.rarity, kind = "Wild" }
	local members: { MemberResult } = {}
	local xpAfter: { number } = {}
	for _, member in input.team do
		local creature = profile.Creatures[member.id]
		if creature then
			local gained =
				Xp.rewardFor(defeated, { level = creature.level, fainted = member.fainted })
			local applied = Xp.applyXp(creature.level, creature.xp, gained, input.cap)
			table.insert(members, {
				id = member.id,
				gained = gained,
				level = applied.level,
				levelsGained = applied.levelsGained,
				newMoves = Xp.newMoves(creature, creature.level, applied.level),
			})
			table.insert(xpAfter, applied.xp)
		end
	end

	profile.Daily.wildWins[kind] = prior + 1
	profile.Coins += coins
	if material then
		profile.Items[material] = (profile.Items[material] or 0) + 1
	end
	for index, result in members do
		local creature = profile.Creatures[result.id]
		creature.level, creature.xp = result.level, xpAfter[index]
	end
	return { coins = coins, material = material, members = members }
end

export type TrainedWinInput = {
	opponentId: string, -- the tamer id or story battle id
	xpKind: Xp.OpponentKind,
	paysCoins: boolean, -- false for battles whose coins come from a story beat
	biome: number,
	foes: { Types.Creature }, -- the whole opposing team
	team: { { id: string, fainted: boolean } },
	cap: number,
	unixTime: number,
}

export type TrainedPaid = Paid & { firstClear: boolean }

local function wonFlag(opponentId: string): string
	return `won:{opponentId}`
end

local function rematchKey(opponentId: string): string
	return `rematch:{opponentId}`
end

-- True once the player has ever beaten this opponent.
function Rewards.hasBeaten(profile: Profile.Profile, opponentId: string): boolean
	return profile.Story.flags[wonFlag(opponentId)] == true
end

-- Pays a win against a tamer or the rival: the first win pays most and is remembered for good;
-- later wins pay the rematch amount a set number of times a day. XP comes from every creature
-- on the beaten team. Everything is worked out first and paid together.
function Rewards.trainedWin(profile: Profile.Profile, input: TrainedWinInput): TrainedPaid
	Grants.rollDay(profile, input.unixTime)
	local firstClear = not Rewards.hasBeaten(profile, input.opponentId)
	local rematches = profile.Daily.tasksDone[rematchKey(input.opponentId)] or 0
	local topLevel = 1
	for _, foe in input.foes do
		topLevel = math.max(topLevel, foe.level)
	end
	local coins = if input.paysCoins
		then Economy.battleCoins("Tamer", math.max(1, input.biome), topLevel, rematches, firstClear)
		else 0

	local members: { MemberResult } = {}
	local xpAfter: { number } = {}
	for _, member in input.team do
		local creature = profile.Creatures[member.id]
		if creature then
			local gained = 0
			for _, foe in input.foes do
				local defeated: Xp.Defeated =
					{ level = foe.level, rarity = foe.rarity, kind = input.xpKind }
				gained += Xp.rewardFor(
					defeated,
					{ level = creature.level, fainted = member.fainted }
				)
			end
			local applied = Xp.applyXp(creature.level, creature.xp, gained, input.cap)
			table.insert(members, {
				id = member.id,
				gained = gained,
				level = applied.level,
				levelsGained = applied.levelsGained,
				newMoves = Xp.newMoves(creature, creature.level, applied.level),
			})
			table.insert(xpAfter, applied.xp)
		end
	end

	if firstClear then
		profile.Story.flags[wonFlag(input.opponentId)] = true
	else
		profile.Daily.tasksDone[rematchKey(input.opponentId)] = rematches + 1
	end
	profile.Coins += coins
	for index, result in members do
		local creature = profile.Creatures[result.id]
		creature.level, creature.xp = result.level, xpAfter[index]
	end
	return { coins = coins, material = nil, members = members, firstClear = firstClear }
end

return Rewards
