--!strict
-- Tests and a pacing simulation for the experience rules.
-- Run from the creature-game folder:  lune run tests/xp.test

local BattleConfig = require("../src/config/BattleConfig")
local Breeding = require("../src/shared/Breeding")
local ProgressionConfig = require("../src/config/ProgressionConfig")
local Rng = require("../src/shared/Rng")
local Xp = require("../src/shared/Xp")
local Placeholders = require("./fixtures/Placeholders")

Placeholders.install()

local passed, failed = 0, 0
local function check(name: string, condition: boolean, detail: string?)
	if condition then
		passed += 1
		print(`  PASS  {name}{if detail then "  (" .. detail .. ")" else ""}`)
	else
		failed += 1
		print(`  FAIL  {name}{if detail then "  (" .. detail .. ")" else ""}`)
	end
end

------------------------------------------------------------------------------------------------
print("\n== Level curve ==")
do
	local rises, totalRises = true, true
	for l = 1, ProgressionConfig.MAX_LEVEL - 1 do
		if Xp.xpToNext(l + 1) <= Xp.xpToNext(l) then
			rises = false
		end
		if Xp.totalXpForLevel(l + 1) <= Xp.totalXpForLevel(l) then
			totalRises = false
		end
	end
	check("XP to the next level only ever rises", rises)
	check("total XP to reach a level only ever rises", totalRises)
	check("level 1 needs no total XP", Xp.totalXpForLevel(1) == 0)
	check(
		"total is the sum of the steps",
		Xp.totalXpForLevel(4) == Xp.xpToNext(1) + Xp.xpToNext(2) + Xp.xpToNext(3)
	)
	check("first level-up is quick", Xp.xpToNext(1) <= 20, `{Xp.xpToNext(1)} XP`)
	local row = {}
	for _, l in { 1, 2, 5, 10, 15, 25, 35, 50 } do
		table.insert(row, `L{l}:{Xp.xpToNext(l)}`)
	end
	print("  XP to next: " .. table.concat(row, "  "))
end

------------------------------------------------------------------------------------------------
print("\n== Level cap and battle level ==")
do
	check(
		"caps run 15, 25, 35, 45, 55",
		Xp.levelCap(0) == 15
			and Xp.levelCap(1) == 25
			and Xp.levelCap(2) == 35
			and Xp.levelCap(3) == 45
			and Xp.levelCap(4) == 55
	)
	check("cap never passes the maximum level", Xp.levelCap(99) == ProgressionConfig.MAX_LEVEL)
	check("ranked level is BattleConfig's", Xp.RANKED_LEVEL == BattleConfig.RANKED_LEVEL)
	local ok = true
	for badges = 0, 6 do
		local cap = Xp.levelCap(badges)
		for _, level in { 1, 10, cap - 1, cap, cap + 1, cap + 30, 100 } do
			if Xp.battleLevel(level, cap) > cap then
				ok = false
			end
		end
	end
	check("battle level never exceeds the cap", ok)
	check("a stronger traded creature fights at the cap", Xp.battleLevel(40, 15) == 15)
	check("a weaker creature fights at its own level", Xp.battleLevel(9, 15) == 9)
end

------------------------------------------------------------------------------------------------
print("\n== Applying XP, the cap and banked XP ==")
do
	local r = Xp.applyXp(1, 0, Xp.xpToNext(1), 15)
	check(
		"exact XP gives one level and leaves nothing",
		r.level == 2 and r.xp == 0 and r.levelsGained == 1
	)
	r = Xp.applyXp(1, 0, Xp.totalXpForLevel(6) + 5, 15)
	check("a big gain climbs several levels", r.level == 6 and r.xp == 5 and r.levelsGained == 5)

	-- At the cap the XP keeps growing and the level stays put.
	local level, xp = 15, 0
	local totalGiven = 0
	for _ = 1, 50 do
		local step = Xp.applyXp(level, xp, 700, 15)
		level, xp = step.level, step.xp
		totalGiven += 700
	end
	check("at the cap the level holds", level == 15)
	check("at the cap no XP is lost", xp == totalGiven, `{xp} banked`)

	-- Lifting the cap spends the bank at once.
	local lifted = Xp.applyXp(level, xp, 0, 25)
	local expectedTotal = Xp.totalXpForLevel(15) + totalGiven
	check(
		"a lifted cap spends banked XP on levels",
		lifted.level > 15 and lifted.levelsGained == lifted.level - 15
	)
	check(
		"nothing is wasted when the cap lifts",
		Xp.totalXpForLevel(lifted.level) + lifted.xp == expectedTotal
	)
	check("the lifted level stops at the new cap", lifted.level <= 25)
	local huge = Xp.applyXp(15, 0, 10 ^ 9, 25)
	check("a huge bank stops at the cap and keeps the rest", huge.level == 25 and huge.xp > 0)
	check("negative gains are ignored", Xp.applyXp(5, 3, -50, 15).xp == 3)
end

------------------------------------------------------------------------------------------------
print("\n== Rewards ==")
do
	local wild: Xp.Defeated = { level = 10, rarity = "Common", kind = "Wild" }
	local same: Xp.TeamMember = { level = 10, fainted = false }
	local full = Xp.rewardFor(wild, same)
	check("a level-matched wild win pays", full > 0, `{full} XP`)
	local weakLow = Xp.rewardFor(
		{ level = 3, rarity = "Common", kind = "Wild" },
		{ level = 20, fainted = false }
	)
	local weakSame = Xp.rewardFor(
		{ level = 3, rarity = "Common", kind = "Wild" },
		{ level = 3, fainted = false }
	)
	check(
		"far-weaker opponents pay much less",
		weakLow * 5 <= weakSame,
		`{weakLow} against {weakSame}`
	)
	check("the weaker-opponent factor never reaches zero", weakLow >= 1)
	check(
		"an opponent above you pays a bonus",
		Xp.rewardFor({ level = 14, rarity = "Common", kind = "Wild" }, same)
			> Xp.rewardFor({ level = 10, rarity = "Common", kind = "Wild" }, same)
	)
	check(
		"a rarer creature pays more",
		Xp.rewardFor({ level = 10, rarity = "Ruby", kind = "Wild" }, same) > full
	)
	check(
		"a giant pays more than a tamer, a tamer more than a wild",
		Xp.rewardFor({ level = 10, rarity = "Common", kind = "Giant" }, same)
				> Xp.rewardFor({ level = 10, rarity = "Common", kind = "Tamer" }, same)
			and Xp.rewardFor({ level = 10, rarity = "Common", kind = "Tamer" }, same) > full
	)

	local team: { Xp.TeamMember } = {
		{ level = 10, fainted = false },
		{ level = 10, fainted = true },
		{ level = 10, fainted = false },
	}
	local shares = Xp.teamShares(wild, team)
	check("every living member gets the full amount", shares[1] == full and shares[3] == full)
	check(
		"a fainted member gets the reduced share",
		shares[2] < full and shares[2] == math.floor(full * ProgressionConfig.FAINTED_SHARE + 0.5),
		`{shares[2]} against {full}`
	)
	check("one share per member", #shares == 3)
end

------------------------------------------------------------------------------------------------
print("\n== Birth level ==")
do
	check("a newborn is clamped to the cap", Xp.birthLevel(40, 15) == 15)
	check("a newborn is never below 1", Xp.birthLevel(0, 15) == 1 and Xp.birthLevel(-4, 15) == 1)
	check("a level in range is kept", Xp.birthLevel(9, 15) == 9)
	check("a fractional level rounds down", Xp.birthLevel(9.8, 15) == 9)
end

------------------------------------------------------------------------------------------------
print("\n== Newly unlocked moves ==")
do
	-- Mossback's head brings Moss Spit at level 8; Dartlet's head brings Leaf Dart at level 8.
	local c = Breeding.wild("Mossback", "m1", 1, "Common", "Moss", Rng.new(5))
	check("nothing unlocks inside a quiet range", #Xp.newMoves(c, 1, 7) == 0)
	local at8 = Xp.newMoves(c, 7, 8)
	check(
		"a move unlocks exactly on its level",
		#at8 == 1 and at8[1] == "Moss Spit",
		table.concat(at8, ",")
	)
	check("the old level does not count again", #Xp.newMoves(c, 8, 20) == 0)
	local span = Xp.newMoves(c, 1, 30)
	check("a wide span lists every unlocked move once", #span == 1 and span[1] == "Moss Spit")
	check("no change in level lists nothing", #Xp.newMoves(c, 8, 8) == 0)
end

------------------------------------------------------------------------------------------------
print("\n== Pacing simulation ==")

local WILD_SECONDS, TAMER_SECONDS, GIANT_SECONDS = 40, 150, 300
local TAMERS_PER_BIOME = 5
local TAMER_TEAM = 3

print(
	"  Assumptions: wild battle 40 s including travel, tamer 150 s (3 creatures defeated), giant 300 s,"
)
print(
	`  {TAMERS_PER_BIOME} tamers and 1 giant per biome, opponents at the team's level (at least 2), all Common,`
)
print("  the team always wins and nobody faints, so every creature gets the full share.")

type State = { level: number, xp: number, minutes: number }

-- Plays one biome for up to `limitMinutes` of play, stopping early when `stopAtCap` is reached.
-- `biomeMinutes` only spaces the tamers and the giant (tamers evenly, the giant at 70%).
local function playBiome(
	state: State,
	badges: number,
	biomeMinutes: number,
	limitMinutes: number,
	stopAtCap: boolean,
	marks: { number }?
): { [number]: number }
	local cap = Xp.levelCap(badges)
	local clock = 0
	local tamersDone, giantDone = 0, false
	local atMinute: { [number]: number } = {}
	local function fight(kind: Xp.OpponentKind, count: number, seconds: number)
		local oppLevel = math.max(2, state.level)
		for _ = 1, count do
			local gain = Xp.rewardFor(
				{ level = oppLevel, rarity = "Common", kind = kind },
				{ level = state.level, fainted = false }
			)
			local r = Xp.applyXp(state.level, state.xp, gain, cap)
			state.level, state.xp = r.level, r.xp
		end
		clock += seconds / 60
		state.minutes += seconds / 60
	end
	local nextMark = 1
	while clock < limitMinutes do
		if
			tamersDone < TAMERS_PER_BIOME
			and clock >= (tamersDone + 1) * biomeMinutes / (TAMERS_PER_BIOME + 1)
		then
			tamersDone += 1
			fight("Tamer", TAMER_TEAM, TAMER_SECONDS)
		elseif not giantDone and clock >= biomeMinutes * 0.7 then
			giantDone = true
			fight("Giant", 1, GIANT_SECONDS)
		else
			fight("Wild", 1, WILD_SECONDS)
		end
		if marks then
			while marks[nextMark] and clock >= marks[nextMark] do
				atMinute[marks[nextMark]] = state.level
				nextMark += 1
			end
		end
		if stopAtCap and state.level >= cap then
			break
		end
	end
	atMinute[0] = clock
	return atMinute
end

do
	-- Level 5.
	local s: State = { level = 1, xp = 0, minutes = 0 }
	local to5 = 0
	do
		local clock = 0
		while s.level < 5 do
			local gain = Xp.rewardFor(
				{ level = math.max(2, s.level), rarity = "Common", kind = "Wild" },
				{ level = s.level, fainted = false }
			)
			local r = Xp.applyXp(s.level, s.xp, gain, 15)
			s.level, s.xp = r.level, r.xp
			clock += WILD_SECONDS / 60
		end
		to5 = clock
	end
	check(
		"a starter that wins reaches level 5 in 6 to 8 minutes",
		to5 >= 6 and to5 <= 8,
		`{string.format("%.1f", to5)} min`
	)

	-- Greenwood: 60 minutes of play, levels noted at 45 and 60.
	local g: State = { level = 1, xp = 0, minutes = 0 }
	local marks = { 15, 30, 45, 60 }
	local at = playBiome(g, 0, 60, 60, false, marks)
	print("  Greenwood level by minute:")
	for _, m in marks do
		print(`    {m} min: level {at[m]}`)
	end
	check(
		"level 12 to 15 at the gate after 45 minutes",
		at[45] >= 12 and at[45] <= 15,
		`level {at[45]}`
	)
	check(
		"level 12 to 15 at the gate after 60 minutes",
		at[60] >= 12 and at[60] <= 15,
		`level {at[60]}`
	)
	local bankedAtGate = Xp.totalXpForLevel(g.level) + g.xp

	-- Dust Canyon: first badge held, cap 25, starting where Greenwood ended.
	local d: State = { level = g.level, xp = g.xp, minutes = 0 }
	playBiome(d, 1, 85, 400, true, nil)
	print(
		`  Dust Canyon: cap 25 reached after {string.format("%.0f", d.minutes)} min (started at level {g.level})`
	)
	check(
		"cap 25 takes 75 to 90 minutes of Dust Canyon",
		d.minutes >= 75 and d.minutes <= 90,
		`{string.format("%.0f", d.minutes)} min`
	)

	-- Tide Flats: second badge held, cap 35, starting at level 25.
	local t: State = { level = 25, xp = 0, minutes = 0 }
	playBiome(t, 2, 110, 600, true, nil)
	print(
		`  Tide Flats: cap 35 reached after {string.format("%.0f", t.minutes)} min (started at level 25)`
	)
	check(
		"cap 35 takes 100 to 120 minutes of Tide Flats",
		t.minutes >= 100 and t.minutes <= 120,
		`{string.format("%.0f", t.minutes)} min`
	)
	print(`  (total XP at the first gate: {bankedAtGate})`)
end

print(`\n{passed} passed, {failed} failed`)
if failed > 0 then
	error(`{failed} test(s) failed`)
end
