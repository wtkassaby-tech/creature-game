--!strict
-- Checks for finds in side areas and dead ends (approval pack 7, docs/plans/14_FINDS_AND_
-- REWARDS.md): the data rules, the claim rules on the profile, where a player must stand, the
-- sighting rule, and that every find can be walked to without crossing long grass.
-- Run from the project folder:  lune run tests/finds.test

local Biomes = require("../src/content/Biomes")
local Economy = require("../src/shared/Economy")
local EconomyConfig = require("../src/config/EconomyConfig")
local Encounters = require("../src/shared/Encounters")
local FindIds = require("../src/shared/FindIds")
local FindTrail = require("../src/shared/FindTrail")
local Finds = require("../src/shared/Finds")
local FindsConfig = require("../src/config/FindsConfig")
local Grants = require("../src/shared/Grants")
local Ground = require("../src/shared/Ground")
local DustCanyonDressing = require("../src/content/map_data/DustCanyonDressing")
local GreenwoodDressing = require("../src/content/map_data/GreenwoodDressing")
local Layout = require("../src/shared/Layout")
local Profile = require("../src/shared/Profile")
local Registry = require("../src/content/Finds")
local Shop = require("../src/shared/Shop")
local Snapshot = require("../src/shared/Snapshot")
local Species = require("../src/content/Species")
local Tamers = require("../src/content/Tamers")
local Walk = require("../src/shared/Walk")
local WorldConfig = require("../src/config/WorldConfig")
local WorldTypes = require("../src/shared/WorldTypes")

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

local function join(list: { string }): string?
	return if #list == 0 then nil else table.concat(list, ", ")
end

local function biomeOf(number: number): WorldTypes.Biome
	for _, biome in Biomes do
		if biome.number == number then
			return biome
		end
	end
	error(`no biome {number}`)
end

local DAY = 86400
local T0 = 100 * DAY + 3600 -- an arbitrary server time, an hour into day 100

local function find(id: string): WorldTypes.Find
	return assert(Registry.byId[id], `find {id} exists`)
end

local function fresh(badges: number?): Profile.Profile
	local profile = Profile.template()
	profile.Story.badges = badges or 1
	return profile
end

------------------------------------------------------------------------------------------------
print("\n== The data ==")
do
	local seen: { [string]: boolean } = {}
	local bad: { string } = {}
	local counts: { [string]: number } =
		{ Cache = 0, Gather = 0, Sighting = 0, Cairn = 0, Note = 0 }
	local KINDS: { [string]: boolean } =
		{ Cache = true, Gather = true, Sighting = true, Cairn = true, Note = true }
	for _, entry in Registry.list do
		if seen[entry.id] or Registry.setById[entry.id] then
			table.insert(bad, `{entry.id} repeats`)
		end
		seen[entry.id] = true
		if not KINDS[entry.kind] then
			table.insert(bad, `{entry.id} has an unknown kind`)
		else
			counts[entry.kind] += 1
		end
		if #entry.id < 1 or #entry.id > 40 or string.find(entry.id, "~", 1, true) then
			table.insert(bad, `{entry.id} is not a valid id`)
		end
		if entry.biome < 1 or entry.biome > 3 then
			table.insert(bad, `{entry.id} is in biome {entry.biome}`)
		end
	end
	for _, set in Registry.sets do
		if seen[set.id] then
			table.insert(bad, `{set.id} repeats`)
		end
		seen[set.id] = true
	end
	check("ids are unique across every biome and set, and well formed", #bad == 0, join(bad))
	check(
		"three biomes' finds are listed: caches, spots, sightings, cairns and notes",
		counts.Cache == 7 and counts.Gather == 6 and counts.Sighting == 3 and counts.Cairn == 3,
		`{counts.Cache} caches, {counts.Gather} gathering, {counts.Sighting} sightings, {counts.Cairn} cairns, {counts.Note} notes`
	)
	check("nine notes and three sets", counts.Note == 9 and #Registry.sets == 3)

	-- Nothing a find gives is coins, a creature, an egg, a pen, a starter, a badge or Gems; Prism
	-- is only paid by a finished set; items and materials are real ones.
	local wrong: { string } = {}
	local ITEMS: { [string]: boolean } = {}
	for _, item in EconomyConfig.ITEM_IDS do
		ITEMS[item] = true
	end
	local MATERIALS: { [string]: boolean } = {}
	for _, material in EconomyConfig.MATERIAL_BY_BIOME do
		MATERIALS[material] = true
	end
	for _, entry in Registry.list do
		for _, reward in entry.rewards do
			if reward.kind == "Item" then
				if not ITEMS[reward.item] or reward.item == "GiantCall" then
					table.insert(wrong, `{entry.id}: item {reward.item}`)
				end
				if reward.count < 1 or reward.count % 1 ~= 0 then
					table.insert(wrong, `{entry.id}: item count`)
				end
			elseif reward.kind == "Material" then
				if not MATERIALS[reward.material] then
					table.insert(wrong, `{entry.id}: material {reward.material}`)
				end
				if reward.count < 1 or reward.count % 1 ~= 0 then
					table.insert(wrong, `{entry.id}: material count`)
				end
			else
				table.insert(wrong, `{entry.id}: pays {(reward :: any).kind}`)
			end
		end
		if entry.kind == "Note" or entry.kind == "Sighting" then
			if #entry.rewards ~= 0 then
				table.insert(wrong, `{entry.id}: a {entry.kind} gives nothing`)
			end
		end
	end
	check(
		"no find pays coins, creatures, eggs, pens, Gems or Prism (items and materials only)",
		#wrong == 0,
		join(wrong)
	)

	local shape: { string } = {}
	for _, entry in Registry.list do
		if (entry.kind == "Cairn") ~= (entry.keepsake ~= nil) then
			table.insert(shape, `{entry.id}: keepsake`)
		end
		if (entry.kind == "Note") ~= (entry.text ~= nil) then
			table.insert(shape, `{entry.id}: text`)
		end
		if (entry.kind == "Sighting") ~= (entry.spot ~= nil) then
			table.insert(shape, `{entry.id}: spot`)
		end
		if entry.kind == "Gather" then
			-- A spot gives only its own biome's material, 2 a day.
			local expected = EconomyConfig.MATERIAL_BY_BIOME[entry.biome]
			local total = 0
			for _, reward in entry.rewards do
				if reward.kind ~= "Material" or reward.material ~= expected then
					table.insert(shape, `{entry.id}: wrong material`)
				else
					total += reward.count
				end
			end
			if total ~= 2 then
				table.insert(shape, `{entry.id}: {total} a day`)
			end
		end
		if entry.pending == nil then
			if entry.kind == "Sighting" then
				if entry.at or entry.route then
					table.insert(shape, `{entry.id}: a sighting is at its rustle spot`)
				end
			elseif not (entry.at or (entry.route and entry.along)) then
				table.insert(shape, `{entry.id}: no place`)
			end
		end
		if entry.text then
			for _, line in entry.text do
				if #line > 120 then
					table.insert(shape, `{entry.id}: a line over 120 characters`)
				end
			end
		end
	end
	check("each kind carries what it needs and nothing else", #shape == 0, join(shape))

	local keepsakes: { [string]: boolean } = {}
	local clash: { string } = {}
	local ownedBy = 0
	for _, entry in Registry.list do
		if entry.keepsake then
			ownedBy += 1
			if keepsakes[entry.keepsake.id] then
				table.insert(clash, entry.keepsake.id)
			end
			keepsakes[entry.keepsake.id] = true
		end
	end
	for _, set in Registry.sets do
		ownedBy += 1
		if keepsakes[set.keepsake.id] then
			table.insert(clash, set.keepsake.id)
		end
		keepsakes[set.keepsake.id] = true
		-- Each set is made of this biome's notes, three of them, each in one set only.
		for _, noteId in set.notes do
			local note = Registry.byId[noteId]
			if not note or note.kind ~= "Note" or note.biome ~= set.biome then
				table.insert(clash, `{set.id}/{noteId}`)
			end
		end
		if #set.notes ~= 3 then
			table.insert(clash, `{set.id}: notes`)
		end
	end
	check("keepsakes are unique and every set is its biome's three notes", #clash == 0, join(clash))
	check("six keepsakes in all: a cairn's and a set's for each biome", ownedBy == 6)

	-- The most a player can gather in a day, with every spot live, is far under the safety ceiling.
	local day = 0
	for _, entry in Registry.list do
		if entry.kind == "Gather" then
			for _, gain in Finds.gainsOf(entry) do
				day += gain.count
			end
		end
	end
	check(
		"gathering every spot in a day stays under the daily ceiling",
		day <= FindsConfig.GATHER_DAILY_CAP,
		`{day}`
	)
	check("the carry limit matches the shop's", FindsConfig.MAX_HELD == Shop.MAX_HELD)

	-- One-time ids and daily keys never overlap, and each find is in exactly the right one.
	local mixed: { string } = {}
	for _, entry in Registry.list do
		local once = FindIds.isOnceId(entry.id)
		local limit = FindIds.dailyLimit(entry.id)
		if entry.kind == "Gather" or entry.kind == "Sighting" then
			if once or limit ~= 1 then
				table.insert(mixed, entry.id)
			end
		elseif not once or limit ~= nil then
			table.insert(mixed, entry.id)
		end
	end
	for _, set in Registry.sets do
		if not FindIds.isOnceId(set.id) or FindIds.dailyLimit(set.id) ~= nil then
			table.insert(mixed, set.id)
		end
	end
	check(
		"one-time ids and daily keys never overlap",
		#mixed == 0
			and FindIds.dailyLimit(FindsConfig.GATHERED_KEY) == FindsConfig.GATHER_DAILY_CAP
			and FindIds.dailyLimit("made_up") == nil
			and not FindIds.isOnceId("made_up"),
		join(mixed)
	)
end

-- Find ids are permanent (rule 8): a shipped one is never renamed, retyped, moved to another
-- biome or removed. Add a line when a find ships; never edit or delete one.
print("\n== Shipped ids are pinned ==")
do
	local SHIPPED: { [string]: string } = {
		gw_gather_fern = "Gather:1",
		gw_note_bench = "Note:1",
		gw_cache_basket = "Cache:1",
		gw_cache_apple = "Cache:1",
		gw_gather_river = "Gather:1",
		gw_note_heron = "Note:1",
		gw_note_wood = "Note:1",
		gw_cairn = "Cairn:1",
		gw_sighting_burl = "Sighting:1",
		gw_journal = "Set:1",
		dc_gather_arroyo = "Gather:2",
		dc_cache_cairn = "Cache:2",
		dc_note_bridge = "Note:2",
		dc_cache_potter = "Cache:2",
		dc_note_spire = "Note:2",
		dc_gather_gorge = "Gather:2",
		dc_note_gorge = "Note:2",
		dc_cairn_overlook = "Cairn:2",
		dc_sighting_echo = "Sighting:2",
		dc_journal = "Set:2",
		tf_gather_rockpool = "Gather:3",
		tf_cache_plank = "Cache:3",
		tf_cache_ship = "Cache:3",
		tf_note_ship = "Note:3",
		tf_note_outcrop = "Note:3",
		tf_note_cove = "Note:3",
		tf_gather_midden = "Gather:3",
		tf_cache_crevice = "Cache:3",
		tf_cairn_cove = "Cairn:3",
		tf_sighting_cove = "Sighting:3",
		tf_journal = "Set:3",
	}
	local gone: { string } = {}
	local changed: { string } = {}
	for id, pinned in SHIPPED do
		local entry = Registry.byId[id]
		local set = Registry.setById[id]
		local now = if entry
			then `{entry.kind}:{entry.biome}`
			elseif set then `Set:{set.biome}`
			else nil
		if now == nil then
			table.insert(gone, id)
		elseif now ~= pinned then
			table.insert(changed, `{id} {pinned} became {now}`)
		end
	end
	check("no shipped find or set has gone", #gone == 0, join(gone))
	check("no shipped find or set changed kind or biome", #changed == 0, join(changed))
	local extra: { string } = {}
	for _, entry in Registry.list do
		if SHIPPED[entry.id] == nil then
			table.insert(extra, entry.id)
		end
	end
	check("every listed find is pinned above", #extra == 0, join(extra))
end

------------------------------------------------------------------------------------------------
print("\n== A cache is claimed once ==")
do
	local profile = fresh()
	local basket = find("gw_cache_basket")
	local first = Finds.claim(profile, basket, T0)
	check(
		"the first claim finds it, gives the item and sets the flag together",
		first.outcome == "Found"
			and profile.Items.Revive == 1
			and profile.Finds.once.gw_cache_basket == true
			and #first.gains == 1
			and first.gains[1].item == "Revive"
	)
	local again = Finds.claim(profile, basket, T0 + 5)
	check(
		"a second claim is refused and gives nothing more",
		again.outcome == "AlreadyFound" and profile.Items.Revive == 1 and #again.gains == 0
	)
	local later = Finds.claim(profile, basket, T0 + 40 * DAY)
	check("it never comes back, whatever the day", later.outcome == "AlreadyFound")

	-- The apple nook gives a lasso and fluff, together.
	local apple = Finds.claim(profile, find("gw_cache_apple"), T0)
	check(
		"a cache with two things gives both in one claim",
		apple.outcome == "Found" and profile.Items.Braided == 1 and profile.Items.Fernfluff == 3
	)

	-- A full bag refuses the whole claim and the flag stays unset.
	local packed = fresh()
	packed.Items.Revive = Shop.MAX_HELD
	local before = packed.Items.Revive
	local refused = Finds.claim(packed, basket, T0)
	check(
		"a full bag refuses it whole: nothing given, no flag set",
		refused.outcome == "Full"
			and packed.Items.Revive == before
			and packed.Finds.once.gw_cache_basket == nil
	)
	packed.Items.Revive = 5
	check(
		"and the player can come back for it",
		Finds.claim(packed, basket, T0 + 9).outcome == "Found" and packed.Items.Revive == 6
	)

	-- Two things in one find where only the second is over the limit: neither is given.
	local half = fresh()
	half.Items.Fernfluff = Shop.MAX_HELD - 1
	local both = Finds.claim(half, find("gw_cache_apple"), T0)
	check(
		"one item over the limit refuses the other too",
		both.outcome == "Full"
			and half.Items.Braided == nil
			and half.Finds.once.gw_cache_apple == nil
	)

	-- A refused claim changes nothing in the profile (but the day counters rolling forward).
	local snapshot = fresh()
	snapshot.Daily.day = T0 // DAY
	local copy = Profile.migrate(snapshot) :: Profile.Profile
	Finds.claim(snapshot, find("tf_cache_plank"), T0 + 3) -- biome 3 is not entered, but the rules do not know
	local after = Finds.claim(snapshot, find("tf_cache_plank"), T0 + 4)
	check("a repeat claim leaves the profile as it was", after.outcome == "AlreadyFound")
	local _ = copy
end

------------------------------------------------------------------------------------------------
print("\n== Gathering renews each day ==")
do
	local fern = find("gw_gather_fern")
	local river = find("gw_gather_river")
	local profile = fresh(0)
	check(
		"gathering is shut before the first badge",
		Finds.claim(profile, fern, T0).outcome == "Shut" and profile.Items.Fernfluff == nil
	)
	profile.Story.badges = 1
	local first = Finds.claim(profile, fern, T0)
	check(
		"with a badge it gives its material",
		first.outcome == "Gathered" and profile.Items.Fernfluff == 2 and #first.gains == 1
	)
	check(
		"a second visit the same day rests",
		Finds.claim(profile, fern, T0 + 60).outcome == "Resting" and profile.Items.Fernfluff == 2
	)
	check(
		"another spot is its own",
		Finds.claim(profile, river, T0 + 70).outcome == "Gathered" and profile.Items.Fernfluff == 4
	)
	check(
		"the next day it has renewed",
		Finds.claim(profile, fern, T0 + DAY).outcome == "Gathered" and profile.Items.Fernfluff == 6
	)
	-- The day rolls forward only: a clock that goes back changes nothing.
	local before = profile.Daily.day
	local back = Finds.claim(profile, river, T0 - 3 * DAY)
	check(
		"a server clock that goes back pays nothing and never moves the day back",
		back.outcome == "Resting" and profile.Daily.day == before and profile.Items.Fernfluff == 6
	)
	check(
		"leaving and rejoining (the same saved day) does not renew it",
		Finds.claim(profile, fern, T0 + DAY + 100).outcome == "Resting"
	)

	-- The safety ceiling: a made-up spot-rich world cannot flood materials.
	local flooded = fresh()
	flooded.Daily.day = T0 // DAY
	flooded.Daily.finds[FindsConfig.GATHERED_KEY] = FindsConfig.GATHER_DAILY_CAP - 1
	check(
		"the daily ceiling holds",
		Finds.claim(flooded, fern, T0).outcome == "Resting" and flooded.Items.Fernfluff == nil
	)
	flooded.Daily.finds[FindsConfig.GATHERED_KEY] = FindsConfig.GATHER_DAILY_CAP - 2
	check("and takes what fits under it", Finds.claim(flooded, fern, T0).outcome == "Gathered")

	local full = fresh()
	full.Items.Fernfluff = Shop.MAX_HELD - 1
	check(
		"a full bag refuses a gather and does not use the spot",
		Finds.claim(full, fern, T0).outcome == "Full"
			and (full.Daily.finds.gw_gather_fern or 0) == 0
	)
end

------------------------------------------------------------------------------------------------
print("\n== Notes, journal sets and cairns ==")
do
	local profile = fresh()
	local bench, heron, wood = find("gw_note_bench"), find("gw_note_heron"), find("gw_note_wood")
	local one = Finds.claim(profile, bench, T0)
	check(
		"a note gives only its page",
		one.outcome == "Read"
			and #one.gains == 0
			and one.prism == 0
			and not one.setDone
			and profile.Candy.prism == 0
			and profile.Finds.once.gw_note_bench == true
	)
	local two = Finds.claim(profile, heron, T0)
	check("two of three notes do not finish the set", not two.setDone and profile.Candy.prism == 0)
	check(
		"a note read twice is already found",
		Finds.claim(profile, bench, T0).outcome == "AlreadyFound"
	)
	local three = Finds.claim(profile, wood, T0)
	check(
		"the third note finishes the set: 2 Prism, once",
		three.setDone
			and three.prism == 2
			and profile.Candy.prism == 2
			and profile.Finds.once.gw_journal == true
			and three.set ~= nil
			and three.set.id == "gw_journal"
	)
	Finds.claim(profile, wood, T0)
	check("reading again never pays it twice", profile.Candy.prism == 2)

	local order = fresh()
	Finds.claim(order, wood, T0)
	Finds.claim(order, bench, T0)
	local last = Finds.claim(order, heron, T0)
	check("the set pays whichever note is read last", last.setDone and order.Candy.prism == 2)

	-- The set's Prism is from the economy's own table.
	check(
		"the Prism is the economy's JournalSet amount",
		Economy.candyFor("JournalSet", 0) == 2 and Economy.candyFor("JournalSet", 1) == 0
	)

	local cairn = Finds.claim(fresh(), find("gw_cairn"), T0)
	check(
		"a cairn gives its materials and is built once",
		cairn.outcome == "Built"
			and cairn.gains[1].item == "Fernfluff"
			and cairn.gains[1].count == 3
	)
	local owner = fresh()
	check("no keepsake before the cairn or the set", #Finds.keepsakes(owner) == 0)
	Finds.claim(owner, find("gw_cairn"), T0)
	Finds.claim(owner, bench, T0)
	Finds.claim(owner, heron, T0)
	Finds.claim(owner, wood, T0)
	local names: { string } = {}
	for _, keepsake in Finds.keepsakes(owner) do
		table.insert(names, keepsake.id)
	end
	table.sort(names)
	check(
		"the cairn's and the set's keepsakes are owned, and need no saved field",
		#names == 2 and names[1] == "old_acorn" and names[2] == "spring_stone",
		table.concat(names, ",")
	)
	local found, total = Finds.progress(owner, 1)
	check(
		"the journal counts finds in the biome: 4 of 7",
		found == 5 and total == 7,
		`{found} of {total}`
	)
	local _, totalTf = Finds.progress(owner, 3)
	check(
		"a biome whose places are not built counts only what can be reached",
		totalTf == 4,
		`{totalTf}`
	)
end

------------------------------------------------------------------------------------------------
print("\n== Places not built are shut ==")
do
	local profile = fresh()
	local cove = find("tf_cache_crevice")
	local result = Finds.claim(profile, cove, T0)
	check(
		"a pending find is shut and gives nothing",
		result.outcome == "Shut"
			and profile.Items.Bait == nil
			and profile.Finds.once.tf_cache_crevice == nil
	)
	check(
		"a pending find has no point on the map",
		Finds.point(Layout.build(Biomes.tide_flats, Tamers.locals), cove) == nil
	)
	local sighting = Finds.claim(profile, find("gw_sighting_burl"), T0)
	check("a sighting is not searched for", sighting.outcome == "Shut")
	local foreign: WorldTypes.Find = {
		id = "gw_cache_basket",
		biome = 1,
		kind = "Cache",
		name = "A copy",
		rewards = { { kind = "Item", item = "Revive", count = 50 } },
	}
	check(
		"only the registry's own finds can be claimed, not a look-alike",
		Finds.claim(profile, foreign, T0).outcome == "Shut" and profile.Items.Revive == nil
	)
	check("an unknown id finds nothing", Finds.lookup("nope") == nil)
	check("a non-string id finds nothing", Finds.lookup(42) == nil and Finds.lookup(nil) == nil)
	check("a ten-thousand-character id finds nothing", Finds.lookup(string.rep("a", 10000)) == nil)
end

------------------------------------------------------------------------------------------------
print("\n== Where the player must stand ==")
do
	local ok: Finds.Reach = { distance = 4, heightGap = 0, lingered = 1.5, fastest = 12 }
	check("an honest search passes", Finds.reachProblem(ok) == nil)
	local function with(change: (reach: Finds.Reach) -> ()): string?
		local copy = table.clone(ok)
		change(copy)
		return Finds.reachProblem(copy)
	end
	check("too far is refused", with(function(r)
		r.distance = FindsConfig.SEARCH_RADIUS + WorldConfig.POSITION_SLACK + 1
	end) == "far")
	check("just inside the radius and the slack passes", with(function(r)
		r.distance = FindsConfig.SEARCH_RADIUS + WorldConfig.POSITION_SLACK
	end) == nil)
	check("the ledge above (a different height) is refused", with(function(r)
		r.heightGap = 10
	end) == "height")
	check("the pit below is refused too", with(function(r)
		r.heightGap = -10
	end) == "height")
	check("not lingered is refused", with(function(r)
		r.lingered = 0.2
	end) == "linger")
	check("a jump in the trail is refused", with(function(r)
		r.fastest = 500
	end) == "jump")
	check("a number that is not a number is refused", with(function(r)
		r.distance = 0 / 0
	end) == "far")

	-- The trail itself.
	local trail = FindTrail.new()
	for step = 0, 4 do
		FindTrail.record(trail, 10 + step * 0.5, 100, 100)
	end
	check(
		"standing still for two seconds has lingered two seconds, and no speed",
		math.abs(FindTrail.lingered(trail, 100, 100, 10) - 2) < 1e-9
			and FindTrail.fastest(trail, 12) == 0
	)
	FindTrail.record(trail, 12.5, 400, 100)
	check(
		"a 300-stud step in half a second is a jump",
		FindTrail.fastest(trail, 12.5) > FindsConfig.JUMP_SPEED_FACTOR * FindsConfig.WALK_SPEED
	)
	check(
		"and leaves them outside the radius, with no lingering",
		FindTrail.lingered(trail, 100, 100, 10) == 0
	)
	FindTrail.reset(trail)
	check("a server-made move resets the trail", FindTrail.fastest(trail, 13) == 0)
	-- A jump read twice in the same instant is still a jump (the step is never counted shorter).
	local quick = FindTrail.new()
	FindTrail.record(quick, 50, 0, 0)
	FindTrail.record(quick, 50.001, 400, 0)
	check(
		"a teleport read an instant later is still caught",
		FindTrail.fastest(quick, 50.001) > FindsConfig.JUMP_SPEED_FACTOR * FindsConfig.WALK_SPEED
	)
	local walking = FindTrail.new()
	for step = 0, 10 do
		FindTrail.record(walking, step * 0.5, step * 8, 0) -- 16 studs a second
	end
	check(
		"a normal walk is never a jump",
		FindTrail.fastest(walking, 5) <= FindsConfig.JUMP_SPEED_FACTOR * FindsConfig.WALK_SPEED
	)
	local old = FindTrail.new()
	FindTrail.record(old, 1, 0, 0)
	FindTrail.record(old, 1.5, 300, 0)
	check(
		"a jump older than the trail's span is forgotten",
		FindTrail.fastest(old, 1.5 + FindsConfig.TRAIL_SECONDS + 3) == 0
	)
end

------------------------------------------------------------------------------------------------
print("\n== Sightings ==")
do
	local greenwood = Biomes.greenwood
	local map = Layout.build(greenwood, Tamers.locals)
	local burl = find("gw_sighting_burl")
	check("a sighting names a rustle spot that exists", Finds.sightingAt("burl_thicket") == burl)
	check("other spots are not sightings", Finds.sightingAt("heron_pool") == nil)
	check("a non-string is not a spot", Finds.sightingAt(7) == nil)

	local profile = fresh()
	check("it is free the first time today", Finds.sightingFree(profile, burl, T0))
	check("using it counts, in one step", Finds.markSighting(profile, burl, T0))
	check(
		"the same day it is used up",
		not Finds.sightingFree(profile, burl, T0 + 3600)
			and not Finds.markSighting(profile, burl, T0 + 3600)
	)
	check("the next day it is free again", Finds.sightingFree(profile, burl, T0 + DAY))
	check(
		"a pending sighting is never free",
		not Finds.sightingFree(fresh(), find("tf_sighting_cove"), T0)
	)

	-- The creature from a sighting is always one of the spot's Uncommon rows.
	local at = map.places.burl_thicket
	local nextId = 0
	local function newId(): string
		nextId += 1
		return `s{nextId}`
	end
	local allUncommon = true
	local sawBoth = false
	local species: { [string]: boolean } = {}
	for seed = 1, 60 do
		local book = Encounters.new()
		local spawn = Encounters.rustle(
			book,
			greenwood,
			map,
			"burl_thicket",
			at,
			1000,
			seed * 7919,
			newId,
			{ gemChance = 0 }
		)
		if spawn then
			local name = spawn.creature.parts.Torso.species
			species[name] = true
			if spawn.creature.rarity ~= "Uncommon" then
				allUncommon = false
			end
		end
	end
	for _ in species do
		sawBoth = true
	end
	check("a sighting draws only Uncommon creatures", allUncommon and sawBoth)

	-- An ordinary stir (no sighting) may bring out the spot's common rows too.
	local ordinary: { [string]: boolean } = {}
	for seed = 1, 120 do
		local book = Encounters.new()
		local spawn = Encounters.rustle(
			book,
			greenwood,
			map,
			"burl_thicket",
			at,
			1000,
			seed * 104729,
			newId,
			nil
		)
		if spawn then
			ordinary[spawn.creature.rarity] = true
		end
	end
	check(
		"a second stir is an ordinary rustle, with the spot's common rows",
		ordinary.Common == true
	)

	-- The gem chance is the normal one: none where gem tiers do not exist, and the wild share after.
	check(
		"Greenwood has no gem tier, so its sighting never has one",
		FindsConfig.SIGHTING_GEM_MIN_BIOME == 2
	)
	local gems = 0
	local trials = 20000
	local dust = Biomes.dust_canyon
	local dustMap = Layout.build(dust, Tamers.locals)
	for seed = 1, trials do
		local book = Encounters.new()
		local spawn = Encounters.rustle(
			book,
			dust,
			dustMap,
			"echo_notch",
			dustMap.places.echo_notch,
			1000,
			seed * 2654435761 % 2147483646 + 1,
			newId,
			{ gemChance = EconomyConfig.GEM_WILD_SHARE }
		)
		if spawn and spawn.creature.rarity == "Gem" then
			gems += 1
		end
	end
	local share = gems / trials
	check(
		"a sighting takes the normal gem chance (0.6%)",
		share > EconomyConfig.GEM_WILD_SHARE * 0.5 and share < EconomyConfig.GEM_WILD_SHARE * 1.7,
		`{share}`
	)

	-- Every sighting spot has an Uncommon row to draw from.
	local noRows: { string } = {}
	for _, entry in Registry.list do
		if entry.kind == "Sighting" and not entry.pending then
			local biome = biomeOf(entry.biome)
			local count = 0
			for _, route in biome.routes do
				for _, row in route.spawns do
					if
						row.spot == entry.spot
						and (row.rarity or Species[row.species].baseRarity) == "Uncommon"
					then
						count += 1
					end
				end
			end
			if count == 0 then
				table.insert(noRows, entry.id)
			end
		end
	end
	check("every live sighting spot has Uncommon rows of its own", #noRows == 0, join(noRows))
end

------------------------------------------------------------------------------------------------
print("\n== The day roll and the save ==")
do
	local profile = fresh()
	Finds.claim(profile, find("gw_gather_fern"), T0)
	Finds.markSighting(profile, find("gw_sighting_burl"), T0)
	check("today's counts are in the profile", profile.Daily.finds.gw_gather_fern == 1)
	Grants.rollDay(profile, T0 + DAY)
	check("the day roll clears them", next(profile.Daily.finds) == nil)
	profile.Finds.once.gw_cairn = true
	Grants.rollDay(profile, T0 + 2 * DAY)
	check("and never touches one-time finds", profile.Finds.once.gw_cairn == true)
	Grants.rollDay(profile, T0 - 5 * DAY)
	check("a clock that goes back leaves the day alone", profile.Daily.day == (T0 + 2 * DAY) // DAY)

	local sound = fresh()
	Finds.claim(sound, find("gw_cache_basket"), T0)
	Finds.claim(sound, find("gw_gather_fern"), T0)
	check("a profile with finds is sound", #Profile.validate(sound) == 0)

	local state = Snapshot.build(sound, T0)
	check(
		"the device is sent the claimed ids and today's spots",
		#state.Finds == 1
			and state.Finds[1] == "gw_cache_basket"
			and table.find(state.FindsToday, "gw_gather_fern") ~= nil
	)
	local tomorrow = Snapshot.build(sound, T0 + DAY)
	check("a stale day shows every spot ready", #tomorrow.FindsToday == 0)
end

------------------------------------------------------------------------------------------------
-- Where each find stands, checked against the map the way the pack asks: on open ground, on one
-- tier, 32 studs from every other prompt and 26 from the centre of any long grass.
local ordered: { WorldTypes.Biome } = {}
for _, biome in Biomes do
	table.insert(ordered, biome)
end
table.sort(ordered, function(a, b)
	return a.number < b.number
end)
local world = Layout.world(ordered, Tamers.locals)

type Prompt = { id: string, at: Layout.Point }
local function promptsOf(biome: WorldTypes.Biome, map: Layout.Map): { Prompt }
	local prompts: { Prompt } = {}
	for _, building in biome.hub.buildings do
		table.insert(prompts, { id = building.id, at = map.places[building.id] })
	end
	for _, route in biome.routes do
		for _, tamerId in route.tamers do
			table.insert(prompts, { id = tamerId, at = map.places[tamerId] })
		end
		for _, spot in route.rustleSpots do
			table.insert(prompts, { id = spot.id, at = map.places[spot.id] })
		end
	end
	table.insert(prompts, { id = "stall", at = map.places[Layout.stallId(biome)] })
	for id, point in map.stands do
		table.insert(prompts, { id = id, at = point })
	end
	return prompts
end

local function grassCentres(map: Layout.Map): { Layout.GrassCircle }
	local circles: { Layout.GrassCircle } = {}
	for _, list in map.grass do
		for _, circle in list do
			table.insert(circles, circle)
		end
	end
	return circles
end

print("\n== Every find stands clear of other prompts and of long grass ==")
do
	local near: { string } = {}
	local grassy: { string } = {}
	local missing: { string } = {}
	local live = 0
	for _, biome in ordered do
		local map = world.maps[biome.number]
		local prompts = promptsOf(biome, map)
		local grass = grassCentres(map)
		local points: { { id: string, at: Layout.Point } } = {}
		for _, entry in Registry.list do
			if entry.biome == biome.number and entry.kind ~= "Sighting" and not entry.pending then
				local point = Finds.point(map, entry)
				if point then
					live += 1
					table.insert(points, { id = entry.id, at = point })
				else
					table.insert(missing, entry.id)
				end
			end
		end
		for index, one in points do
			for _, prompt in prompts do
				if Layout.distance(one.at, prompt.at) < 32 then
					table.insert(near, `{one.id}/{prompt.id}`)
				end
			end
			for other = index + 1, #points do
				if Layout.distance(one.at, points[other].at) < 32 then
					table.insert(near, `{one.id}/{points[other].id}`)
				end
			end
			for _, circle in grass do
				if Layout.distance(one.at, circle) < 26 then
					table.insert(grassy, `{one.id}/grass`)
				end
			end
		end
	end
	check("every live find has a place on the map", #missing == 0 and live >= 18, join(missing))
	check("no find is within 32 studs of another prompt or find", #near == 0, join(near))
	check("no find is within 26 studs of the centre of long grass", #grassy == 0, join(grassy))
end

print(
	"\n== Greenwood and Dust Canyon: every find can be walked to, and away from, without long grass =="
)
do
	type Spec = {
		number: number,
		dressing: WorldTypes.DressingSheet,
		bounds: { number },
		expect: number,
	}
	local specs: { Spec } = {
		{ number = 1, dressing = GreenwoodDressing, bounds = { -450, -420, 760, 160 }, expect = 8 },
		{
			number = 2,
			dressing = DustCanyonDressing,
			bounds = { -150, -620, 900, 140 },
			expect = 7,
		},
	}
	for _, spec in specs do
		local biome = biomeOf(spec.number)
		local sheet = assert(biome.map, `{biome.name} has a sheet`)
		local map = world.maps[spec.number]
		local ground = Ground.new(sheet, { x = map.hub.x, z = map.hub.z })
		local space = Walk.space(biome, map, spec.dressing)
		local box = {
			x0 = map.hub.x + spec.bounds[1],
			z0 = map.hub.z + spec.bounds[2],
			x1 = map.hub.x + spec.bounds[3],
			z1 = map.hub.z + spec.bounds[4],
		}
		local grid = Walk.grid(space, ground, box, 4)
		local start = if map.spawn then map.spawn.at else map.places[biome.hub.id]
		local grass = grassCentres(map)
		local function inGrass(x: number, z: number): boolean
			for _, circle in grass do
				if (x - circle.x) ^ 2 + (z - circle.z) ^ 2 <= (circle.r + 2) ^ 2 then
					return true
				end
			end
			return false
		end
		local out = Walk.reach(grid, start.x, start.z, { avoid = inGrass })
		local back = Walk.reach(grid, start.x, start.z, { avoid = inGrass, forward = false })
		local lost: { string } = {}
		local edge: { string } = {}
		local tiers: { string } = {}
		local count = 0
		for _, entry in Registry.list do
			if entry.biome == spec.number and entry.kind ~= "Sighting" and not entry.pending then
				count += 1
				local point = assert(Finds.point(map, entry), entry.id)
				if
					not (
						Walk.reached(grid, out, point.x, point.z)
						and Walk.reached(grid, back, point.x, point.z)
					)
				then
					table.insert(lost, entry.id)
				end
				if Walk.depth(space, point.x, point.z, true, nil) < 2 then
					table.insert(edge, entry.id)
				end
				-- Wholly on one tier: the ground a search radius round it is the same height.
				local height = Ground.heightAt(ground, point.x, point.z)
				for k = 0, 15 do
					local angle = k / 16 * math.pi * 2
					local x = point.x + math.cos(angle) * FindsConfig.SEARCH_RADIUS
					local z = point.z + math.sin(angle) * FindsConfig.SEARCH_RADIUS
					if
						Walk.open(space, x, z)
						and math.abs(Ground.heightAt(ground, x, z) - height) > 0.01
					then
						table.insert(tiers, entry.id)
						break
					end
				end
			end
		end
		check(`{biome.name} has its {spec.expect} placed finds`, count == spec.expect, `{count}`)
		check(
			`{biome.name}: every find is reachable from the town and the town from it`,
			#lost == 0,
			join(lost)
		)
		check(
			`{biome.name}: every find stands two studs or more inside walkable ground`,
			#edge == 0,
			join(edge)
		)
		check(`{biome.name}: every find is wholly on one tier`, #tiers == 0, join(tiers))

		if spec.number == 1 then
			-- The apple nook is hidden: reachable through its gap, and not without it.
			local apple = assert(Finds.point(map, find("gw_cache_apple")))
			check("the apple nook is hidden", find("gw_cache_apple").hidden == true)
			local sealed = table.clone(biome)
			local sealedSheet = table.clone(sheet)
			local rooms: { WorldTypes.Room } = {}
			local drawn: { WorldTypes.Room } = if sheet.rooms then sheet.rooms else {}
			for _, room in drawn do
				if room.id ~= "apple_gap" then
					table.insert(rooms, room)
				end
			end
			sealedSheet.rooms = rooms
			sealed.map = sealedSheet
			local sealedSpace = Walk.space(sealed, map, spec.dressing)
			local sealedGrid = Walk.grid(sealedSpace, ground, box, 4)
			local sealedReach = Walk.reach(sealedGrid, start.x, start.z)
			check(
				"only its gap leads there: with the gap shut it cannot be reached",
				Walk.reached(grid, out, apple.x, apple.z)
					and not Walk.reached(sealedGrid, sealedReach, apple.x, apple.z)
			)
		end
	end
end

print("\n== Tide Flats: finds lie down their lane, inside the corridor ==")
do
	local outside: { string } = {}
	for _, entry in Registry.list do
		local routeId = entry.route
		if routeId and entry.pending == nil then
			local map = world.maps[entry.biome]
			local line = assert(map.routes[routeId], `{entry.id} route`)
			local along = assert(entry.along, `{entry.id} has an along`)
			local half = 0
			for _, area in biomeOf(entry.biome).routes do
				if area.id == routeId then
					for _, stretch in area.areas do
						if along >= stretch.from and along <= stretch.to then
							half = if line.halfWidth then (line.halfWidth[stretch.id] or 0) else 0
						end
					end
				end
			end
			if math.abs(entry.side or 0) + FindsConfig.SEARCH_RADIUS > half then
				table.insert(
					outside,
					`{entry.id} ({math.abs(entry.side or 0)} off, corridor {half})`
				)
			end
			if along < 0 or along > line.length then
				table.insert(outside, `{entry.id} along`)
			end
		end
	end
	check("each lies wholly inside its stretch's corridor", #outside == 0, join(outside))
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error("finds checks failed")
end
