--!strict
-- Battles against people: the local tamers along the routes and the rival's story battles.
-- Pure rules: who can be battled now, where the player must stand, and the team they bring.
--
-- A local tamer can always be battled (the first win pays most; rematches pay once a day).
-- A story battle (the rival, a gate's champion) exists only while the story is waiting for it:
-- it is the next story beat's battle, so it can never be replayed for XP once the story has
-- moved on. In the code a story battle's kind is "Rival" whoever the opponent is.

local Breeding = require("./Breeding")
local Profile = require("./Profile")
local Rewards = require("./Rewards")
local Rng = require("./Rng")
local Species = require("../content/Species")
local StoryProgress = require("./StoryProgress")
local StoryStand = require("./StoryStand")
local Tamers = require("../content/Tamers")
local Types = require("./Types")
local WorldTypes = require("./WorldTypes")
local Xp = require("./Xp")

export type Opponent = {
	id: string, -- the tamer id or the story battle id
	kind: "Tamer" | "Rival",
	xpKind: Xp.OpponentKind,
	place: string, -- the place id the player must be standing at
	team: WorldTypes.TamerTeam,
	paysCoins: boolean, -- rival battles are paid by their story beat, not by the battle
	cannotLose: boolean, -- the story does not let the player lose this battle (BattleSession)
}

local Trainers = {}

local STARTERS: { WorldTypes.Starter } = { "Mossmitt", "Spadesnout", "Sloshcalf" }

local function byStarter<T>(teams: WorldTypes.ByStarter<T>, starter: string?): T?
	for _, name: WorldTypes.Starter in STARTERS do
		if name == starter then
			return teams[name]
		end
	end
	return nil
end

-- The opponent for a battle the device asked for, or nil and a reason. `id` comes from the device.
function Trainers.resolve(
	id: unknown,
	profile: Profile.Profile,
	chapter: WorldTypes.Chapter
): (Opponent?, string?)
	if typeof(id) ~= "string" then
		return nil, "Bad request"
	end
	local tamer = Tamers.locals[id]
	if tamer then
		return {
			id = tamer.id,
			kind = "Tamer",
			xpKind = "Tamer",
			place = tamer.id,
			team = tamer.team,
			paysCoins = true,
			cannotLose = false,
		},
			nil
	end
	local battle = Tamers.story[id]
	if not battle then
		return nil, "That battle is not available"
	end
	-- A story battle is open only while it is the story's next step, and only once. When it is
	-- not, say why: the person is standing there in the world, and "not available" tells nobody
	-- what to do. Once won it is over, even if its beat has not finished yet (the win is on
	-- record and the story catches up by itself), so it can never be replayed for XP.
	local status = StoryStand.status(chapter, profile.Story.flags, battle)
	local beaten = Rewards.hasBeaten(profile, id)
	if status == "None" then
		return nil, "That battle is not available"
	elseif beaten or status ~= "Now" then
		return nil, StoryStand.refusal(status, battle, beaten)
	end
	local team = battle.team
	if battle.teams then
		team = byStarter(battle.teams, profile.Story.starter)
		if team == nil then
			return nil, "Pick your first creature before this battle"
		end
	end
	if team == nil then
		return nil, "That battle is not available"
	end
	return {
		id = id,
		kind = "Rival",
		xpKind = battle.xpKind,
		place = battle.place,
		team = team,
		paysCoins = false,
		cannotLose = battle.cannotLose,
	},
		nil
end

-- Builds a team's creatures and their chosen moves. The same opponent always brings the same
-- creatures: the seed comes from the opponent's id, not from chance.
function Trainers.build(opponent: Opponent): ({ Types.Creature }, { { string } })
	local seed = 7
	for index = 1, #opponent.id do
		seed = (seed * 31 + string.byte(opponent.id, index)) % 2147483647
	end
	local rng = Rng.new(math.max(1, seed))
	local creatures: { Types.Creature } = {}
	local moves: { { string } } = {}
	for index, member in opponent.team.members do
		local def = Species[member.species]
		table.insert(
			creatures,
			Breeding.wild(
				member.species,
				`{opponent.id}#{index}`,
				member.level,
				def.baseRarity,
				StoryProgress.giftColour(member.species),
				rng
			)
		)
		table.insert(moves, table.clone(member.moves))
	end
	return creatures, moves
end

return Trainers
