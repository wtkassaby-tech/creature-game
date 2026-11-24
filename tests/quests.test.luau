--!strict
-- Checks for taking, counting and handing in quests.
-- Run from the project folder:  lune run tests/quests.test

local Gifts = require("../src/shared/Gifts")
local Grants = require("../src/shared/Grants")
local Profile = require("../src/shared/Profile")
local QuestProgress = require("../src/shared/QuestProgress")
local Quests = require("../src/content/Quests")

local passed, failed = 0, 0
local function check(name: string, condition: boolean, detail: string?)
	if condition then
		passed += 1
	else
		failed += 1
	end
	print(
		`  {if condition then "PASS" else "FAIL"}  {name}{if detail
			then "  (" .. detail .. ")"
			else ""}`
	)
end

local nextId = 0
local function newId(): string
	nextId += 1
	return `q{nextId}`
end
local function input(): Gifts.Input
	return { choice = nil, newId = newId, seed = 4, unixTime = 86400 * 300 }
end
local function count(map: { [string]: any }): number
	local n = 0
	for _ in map do
		n += 1
	end
	return n
end

print("\n== Taking a quest ==")
do
	local profile = Profile.template()
	check(
		"a made-up quest is refused",
		QuestProgress.accept(profile, "gw_free_gold", true) == nil
			and QuestProgress.accept(profile, 5, true) == nil
	)
	check(
		"a quest the story has not opened is refused",
		QuestProgress.accept(profile, "gw_fresh_tracks", true) == nil
	)
	profile.Story.flags.third_creature = true
	check(
		"it must be taken at its giver",
		QuestProgress.accept(profile, "gw_fresh_tracks", false) == nil
	)
	check(
		"a later quest in the line is refused",
		QuestProgress.accept(profile, "gw_pond_friend", true) == nil
	)
	check(
		"the open quest can be taken",
		QuestProgress.accept(profile, "gw_fresh_tracks", true) ~= nil
			and profile.Quests.active.gw_fresh_tracks == 0
	)
	check("it cannot be taken twice", QuestProgress.accept(profile, "gw_fresh_tracks", true) == nil)
end

print("\n== Counting and handing in ==")
do
	local profile = Profile.template()
	profile.Story.flags.third_creature = true
	QuestProgress.record(profile, { kind = "WinWild", route = "greenwood_route_a" })
	QuestProgress.accept(profile, "gw_fresh_tracks", true)
	check(
		"wins before the quest was taken do not count",
		profile.Quests.active.gw_fresh_tracks == 0
	)
	QuestProgress.record(profile, { kind = "WinWild", route = "greenwood_route_b" })
	QuestProgress.record(profile, { kind = "Tame", species = "Splashjack" })
	check(
		"the wrong route and the wrong kind of event do not count",
		profile.Quests.active.gw_fresh_tracks == 0
	)
	check(
		"an unfinished quest cannot be handed in",
		QuestProgress.handIn(profile, "gw_fresh_tracks", true, input()) == nil
	)
	for _ = 1, 6 do
		QuestProgress.record(profile, { kind = "WinWild", route = "greenwood_route_a" })
	end
	check(
		"wins on the right route count, up to what is needed",
		profile.Quests.active.gw_fresh_tracks == 4
	)
	check(
		"it must be handed in at its giver",
		QuestProgress.handIn(profile, "gw_fresh_tracks", false, input()) == nil
	)
	local tonics = profile.Items.Tonic or 0
	local handed = QuestProgress.handIn(profile, "gw_fresh_tracks", true, input())
	check("handing in pays the rewards", handed ~= nil and (profile.Items.Tonic or 0) == tonics + 3)
	check(
		"and marks it done",
		profile.Quests.done.gw_fresh_tracks == true and profile.Quests.active.gw_fresh_tracks == nil
	)
	check(
		"it cannot be handed in or taken again",
		QuestProgress.handIn(profile, "gw_fresh_tracks", true, input()) == nil
			and QuestProgress.accept(profile, "gw_fresh_tracks", true) == nil
	)
	check(
		"the next quest in the line opens",
		QuestProgress.accept(profile, "gw_pond_friend", true) ~= nil
	)
end

print("\n== The whole line ==")
do
	local profile = Profile.template()
	profile.Story.flags.third_creature = true
	local coins, prism = profile.Coins, profile.Candy.prism
	local steps: { { id: string, event: QuestProgress.Event, times: number } } = {
		{
			id = "gw_fresh_tracks",
			event = { kind = "WinWild", route = "greenwood_route_a" },
			times = 4,
		},
		{ id = "gw_pond_friend", event = { kind = "Tame", species = "Splashjack" }, times = 1 },
		{ id = "gw_heron_watch", event = { kind = "BeatTamer", tamer = "gw_odette" }, times = 1 },
		{
			id = "gw_woodcutters_word",
			event = { kind = "BeatTamer", tamer = "gw_corwin" },
			times = 1,
		},
	}
	local all = true
	for _, step in steps do
		all = all and QuestProgress.accept(profile, step.id, true) ~= nil
		for _ = 1, step.times do
			QuestProgress.record(profile, step.event)
		end
		all = all and QuestProgress.handIn(profile, step.id, true, input()) ~= nil
	end
	check("the four quests finish in order", all)
	check(
		"the line pays its coins and Prism Candy",
		profile.Coins > coins and profile.Candy.prism > prism
	)
	local warden = false
	for _, creature in profile.Creatures do
		warden = warden or (creature.parts.Torso.species == "Stumpwarden" and creature.level == 8)
	end
	check("and its guaranteed creature", warden and count(profile.Creatures) == 1)
	check(
		"the record is sound",
		#Profile.validate(profile) == 0,
		table.concat(Profile.validate(profile), "; ")
	)

	local full = Profile.template()
	full.Story.flags.third_creature = true
	full.Quests.done.gw_fresh_tracks, full.Quests.done.gw_pond_friend, full.Quests.done.gw_heron_watch =
		true, true, true
	full.StableCapacity = 0
	QuestProgress.accept(full, "gw_woodcutters_word", true)
	QuestProgress.record(full, { kind = "BeatTamer", tamer = "gw_corwin" })
	QuestProgress.handIn(full, "gw_woodcutters_word", true, input())
	check(
		"with a full stable the creature waits as a quest gift",
		#full.Pending == 1 and full.Pending[1].source == "Quest"
	)
	full.StableCapacity = 30
	local handed = Grants.claimPending(full, function(_source, ref)
		return Gifts.rebuild(ref, newId(), 2)
	end)
	check("and arrives when there is room", handed == 1 and count(full.Creatures) == 1)
	check(
		"every quest's rewards can be made",
		(function()
			for _, quest in Quests do
				if Gifts.prepare(quest.id, quest.rewards, input()) == nil then
					return false
				end
			end
			return true
		end)()
	)
end

print("\n== Review fixes ==")
do
	local noStarter = true
	for _, quest in Quests do
		for _, reward in quest.rewards do
			noStarter = noStarter and reward.kind ~= "Starter"
		end
	end
	check("no quest gives a starter (a hand-in carries no choice)", noStarter)

	local profile = Profile.template()
	profile.Story.flags.third_creature, profile.Story.flags.giant_glimpse = true, true
	profile.Quests.done.gw_fresh_tracks = true
	check(
		"the giant quest can be taken only while giant fights exist",
		QuestProgress.GIANTS_OPEN == (QuestProgress.accept(profile, "gw_hollowbough", true) ~= nil)
	)

	local damaged = Profile.template()
	local active: { [string]: any } = damaged.Quests.active
	active.gw_fresh_tracks = "three"
	check("damaged quest progress is reported", #Profile.validate(damaged) > 0)
	check(
		"and does not stop the counting",
		#QuestProgress.record(damaged, { kind = "WinWild", route = "greenwood_route_a" }) == 0
	)
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("quest checks failed")
end
