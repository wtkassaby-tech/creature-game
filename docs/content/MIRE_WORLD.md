# Mire world

The Mire's world as data: the hub (Sedgeholm), two routes, the lair, the gate, five tamers, the rival mid-biome, a local champion at the gate, a quest line, chapter 4 of the story and the giant Sloughback. Data lives in `src/content/biome_data/`, `tamer_data/`, `quest_data/`, `story_data/` and `giant_data/` (plus `species_data/Sloughback.luau` and two moves in `Moves.luau`); the checks are `tests/mire.test.luau` (about 2 seconds, robots included). It mirrors `TIDE_FLATS_WORLD.md`. The species are in `MIRE_ROSTER.md`.

**Written ahead of launch.** `src/config/ReleaseConfig.luau` still opens three biomes, so every registry leaves the Mire out and the launch game is unchanged (checked: the outputs of `playthrough`, `economy`, `tideflats`, `dustcanyon`, `world` and `release` are byte-for-byte the same as before). `tests/mire.test.luau` sets `OPEN_BIOMES = 4` on its first line, before any registry loads. Opening the Mire for players is that one number, once its map and art are in the place.

Everything here is a [Default] the owner can change. **Every name is a placeholder** (town, buildings, people, routes, places, the giant, its attacks, the badge). The rival and the mentor are still called "Rival" and "Mentor".

## The map

Sedgeholm (hub, 300 x 300) is a stilt village around the Bell Cypress, a huge old tree with a bronze fog bell in its branches. Wild levels rise with distance (32 to 42, the economy's band for biome 4; the cap with three badges is 45).

| Route | Stretch (studs) | Levels | Lives here (open) | Rustle spot |
| --- | --- | --- | --- | --- |
| **A: Duckboard Trail** (500) | Reedfringe 0-160 | 32-33 | Fenwhisk, Skipslick, Mistrel; rarely Glissot, Cocklemole (Tide Flats strays) | none |
| | Lily Lanes 160-330 | 33-35 | Lilyshade, Skipslick, Fenwhisk, Keelsnap | **Bubbling Pool** (260): Bulbroth, Lilyshade, Skipslick |
| | Mangrove Tangle 330-500 | 35-37 | Snaggar, Keelsnap, Mistrel, Lilyshade | **Steaming Hummock** (430): Bogbellow, Snaggar, Mistrel |
| **B: Cypress Road** (720) | Peat Cuttings 0-180 | 37-38 | Snaggar, Fenwhisk, Keelsnap, Mistrel | none |
| | Old Stilt Hamlet 180-360 | 38-40 | Skipslick, Lilyshade, Keelsnap, Snaggar, Fenwhisk | none |
| | Fogwater Reach 360-540 | 39-41 | Mistrel, Lilyshade, Snaggar, Skipslick, Keelsnap | **Sinkhole** (470): Bogbellow, Bulbroth, Mistrel, Snaggar |
| | Sluice Rise 540-720 | 40-42 | Keelsnap, Snaggar, Fenwhisk, Mistrel, Lilyshade, Skipslick | none |

- **A Toxic creature within a minute of town.** Fenwhisk and Skipslick (Toxic, so they can never be poisoned) live in the first stretch, and both carry Venom Nip, so the very first wild battles show poison (the test checks both). The two uncommon species (Bogbellow, Bulbroth) live only at rustle spots (45% of rustles on Route A, 65% at the Sinkhole), so nothing in the main line needs them.
- **Strays.** Glissot and Cocklemole stray in from Tide Flats at the Reedfringe (12% of that stretch). Cocklemole is Sand, which beats Toxic: a lucky early catch.
- **Bait** (Tide Flats' idea) works at all three spots. The Mire has no material of its own yet: `EconomyConfig.MATERIAL_BY_BIOME` stops at Tide Flats, so Mire wins drop Brine Shells (the shared code clamps to the last entry). See the open questions.
- **Gem tier.** Every open row of a Mire species has a gem-tier twin (`withGems`, as in Tide Flats), weighted to `EconomyConfig.GEM_WILD_SHARE`; spots give none from the table; the strays have no twin.
- **Lair:** the Sunken Grove (level 46 giant). A 280-stud spur leaves Route B at 440 (inside Fogwater Reach), with a supply stall and a 170-stud arena; a shortcut to the hub opens after the win. Optional for the story.
- **Gate:** the Sluice Gate, a huge old wooden lock gate at the end of Route B (720), held by **a local champion**, the sluice keeper Honora Vell. Badge: the Bulrush Badge. The road to biome 5 (Frostline) is sealed until then. Recommended levels on arrival: 42 to 45.
- **Hub buildings:** Quill's Sundries (shop, keeper Vesper Quill), the Clearwater Spring (healer, Ottilie Dunmore, who teaches poison), the Reed Nursery (breeder), the Mooring Post (quests), the Punt Landing (teleport, punter Jory Pike), the Cypress Ring (Circuit) and the Bell Loft (lookout). No name repeats one in an earlier biome (the test checks).

## Tamers

Teams are four from here on (three badges). Every local team carries a poisoning move and a Toxic creature that cannot catch poison, so both halves of the rule are seen on every battle (the test checks).

| Tamer | Where | Team (poisoning move in bold) |
| --- | --- | --- |
| Wren Ashby (reed-cutter) | A, 120 | Fenwhisk 33 (**Venom Nip**), Skipslick 32 (**Venom Nip**), Mistrel 32, Snaggar 33 |
| Marisol Venn (naturalist) | A, 400 | Lilyshade 35, Skipslick 35 (**Venom Nip**), Keelsnap 36 (**Barb Sting**), Bulbroth 35 (**Broth Spit**) |
| Barnaby Tull (peat cutter) | B, 110 | Bogbellow 38 (**Fume Belch**), Snaggar 37 (**Barb Sting**), Mistrel 37, Keelsnap 37 |
| Ysolde Greaves (marsh-light watcher) | B, 400 | Lilyshade 39, Fenwhisk 39 (**Venom Nip**), Bulbroth 40 (**Broth Spit**), Snaggar 40 |
| Cuthbert Mott (sluice keeper's helper) | B, 620 | Keelsnap 42, Bogbellow 41 (**Fume Belch**), Skipslick 41 (**Venom Nip**), Mistrel 42 |

All use the Tamer AI tier, tint 0, and only moves the creature can know at that level. The top level, 42, is the gate's floor. Wren's line after losing states the rule ("Poison never sticks to a Toxic creature. Catch one of your own."); Cuthbert's warns of the gate ("Bring creatures that shrug off poison").

**The rival, mid-biome** (story battle `rival_mire`, in the Old Stilt Hamlet, Rival tier, counts as a Rival fight, one team per starter, levels 38 to 39, can be lost to). **Tint 0.85** (Greenwood 0.25, Dust Canyon 0.5, Tide Flats 0.75), kept under 1 to leave room for later biomes. He carries three shards and a snapped rope: he tried to make the Mire's giant obey him with the glint, and it threw him off, the first step towards the brief's "giants taken by force". He still leads with the starter that counters yours, and now fields Mire creatures he has caught, one of which poisons:

| You pick | Rival's team |
| --- | --- |
| Mossmitt (Leaf) | Spadesnout 39, Snaggar 38, Cocklemole 38, Skipslick 38 |
| Spadesnout (Sand) | Sloshcalf 39, Moatkeep 38, Lilyshade 38, Bulbroth 38 |
| Sloshcalf (Water) | Mossmitt 39, Mistrel 38, Thatchling 38, Fenwhisk 38 |

**The champion at the gate** (story battle `champion_vell`, Rival tier, counts as a Gate fight, one team, a loss is not free, tint 0): Fenwhisk 41, Lilyshade 42, Bulbroth 42, Bogbellow 43. The strongest is two levels under the cap of 45 and the rest within two below (`GATE_TOP_UNDER_CAP`, `GATE_TEAM_SPREAD`), the rule `dustcanyon.test` and `tideflats.test` check. Three of the four poison, and her lead (Fenwhisk) poisons at once. She covers the player's answers to Toxic: Lilyshade's Still Water beats Sand and its Hoarmist (Frost) beats Toxic.

Why a champion: the brief alternates the gates (Greenwood and Tide Flats were the rival's, Dust Canyon's a champion's), and putting the rival mid-biome lets his failed attempt on the giant come just before the player sees the giant.

## Quest line: Sedgeholm Errands

Opens after the "Clearwater Spring" beat (poison). Four quests, ending in a guaranteed creature, plus one optional.

| # | Quest | Giver (building) | Objective | Reward |
| --- | --- | --- | --- | --- |
| 1 | First Wade | Vesper Quill (Sundries) | Win 4 wild battles on Route A | 4 Field Tonics |
| 2 | A Friend Who Never Sickens | Ottilie Dunmore (Clearwater Spring) | Tame a Fenwhisk (Toxic) | 2 Braided Lassos, 1 Tide Bait |
| 3 | Counting the Lights | Jory Pike (Punt Landing) | Beat Ysolde Greaves | 2 Deep Tonics, 4 Brine Shells |
| 4 | The Sluice Pass | Ezra Dunlin (Mooring Post) | Beat Cuthbert Mott | coins and candy from the economy (biome 4), **a level 36 Bulbroth** (Uncommon, Toxic) |
| Optional | The Grove That Breathes | Ezra Dunlin | Beat Sloughback (needs a Giant Horn; opens after the grove is seen) | Rally Root, 5 Brine Shells |

Step 2 puts a Toxic creature on the team early, and the line ends in Bulbroth, the sturdiest Toxic creature, which the open routes never give (only rustle spots). Coins are `QUEST_LINE_COINS x ONE_TIME_MULT[4]` (1,000); candy is the last entry of `QUEST_LINE_CANDY` (4), the same rule `Economy` uses for biomes past the end of that list.

## Chapter 4 beats

Chapter 3 ends at minute 215; the first beat requires its last one (`tide_road_on`).

| # | Beat | Time | Trigger | Gives |
| --- | --- | --- | --- | --- |
| 1 | Sedgeholm | 215-219 | Enter the hub | Hub open |
| 2 | The Clearwater Spring | 217-222 | Talk to Ottilie (healer) | **Poison** unlocked; quest line, routes. She explains poison: it nips each turn and wears off, Toxic creatures never catch it, the spring mends what it took, free |
| 3 | A local tamer | 219-229 | Win vs Wren | "Toxic ones just shrug it off" |
| 4 | A catch from the reeds | 223-233 | Tame any creature | "If it is Toxic, poison will slide right off it" |
| 5 | The mentor comes to the Mire | 229-237 | Talk to Jory | 2 Deep Tonics; the mentor's half-truth |
| 6 | The rival in the fog | 235-247 | Win vs the rival | His failed attempt on the giant; a hint at the mentor |
| 7 | The grove that breathes | 245-255 | See Fogwater Reach | Giant marker; "its great waves give way to sand and frost" |
| 8 | The Sluice Gate | 265-280 | Enter the gate | Honora: "Mine bite with poison. Bring some that cannot catch it, or bring tonics." |
| 9 | The fourth badge | 270-285 | Win vs Honora | Bulrush Badge, coins and candy from the economy, **clear token: a level 42 Mistrel** (Water, carries Hoarmist, the Frost teaser for Frostline), level cap 55 |
| 10 | The road on | 275-290 | Enter the sealed path | Opens biome 5; teases Frostline |

**Poison hints, fair and repeated:** the healer (beat 2), the first tamer (beat 3), the catch beat (4), quest step 2, the last tamer, and the gate keeper's challenge (beat 8) all say the same thing. A player reaches the gate with three ways to hold a Toxic creature: a wild catch from the first stretch, the step-2 Fenwhisk, the step-4 Bulbroth (and chapter 3's token, Moatkeep, is Sand, which beats Toxic).

**The arc, one more step.** The mentor keeps his chapter-3 promise ("At the Mire. Promise.") and comes in person. He tells part of the truth: the flicker is a tear in the sky, and what leaks through wakes the giants and turns creatures to gem ("That is why I made you strong", answering chapter 1's "do not ask what you must be strong for"). Then he lies about the rest: "How it opened? Nobody knows. Truly." The rival, met just after, says "Ask him why the tear opened over Thistledown first", which points at the mentor without saying why; the truth stays for biome 9.

## The giant: Sloughback

A newt as big as a barn whose back is a little island of mangroves, with soft green marsh lights hanging from the roots like lures (the "lights that are not lanterns" chapter 3's last line teases). Toxic, level 46 (one over the cap of 45, as Carrackon is one over 35), 2,300 health, Attack 400, Defence 90. Weak to **Sand and Frost**.

**The fight idea: "the long fog".** The first giant met with a team of four, and the first whose damage lands mostly on the whole team. Hollowbough is one slam a Sand lead shrugs off, Mesalith is swapping a stopper in and out, Carrackon is a rhythm of waves; Sloughback is endurance. Fume Drift seeps over every creature standing, again and again, so swapping never dodges it and the bench wears down with the front (the test checks it reaches all four). A team wins by ending the fight before its four are worn out: bulk (the Mire's breeding stat is Hp), tonics, and stopping the big waves.

- It echoes the biome's lesson: its Toxic fumes hit Water creatures hardest and Sand creatures least, and Toxic creatures take them at the plain rate (measured: Water 59, Toxic 40, Sand 26 a seep at level 44).
- Every stopper has an attack aimed at it: Sinking Pull (Water) and Marshlight Flare (Storm) hit Sand creatures hard, and the Frost stoppers (Mistrel and Lilyshade, Water-bodied, carrying Hoarmist) take the Toxic fumes at 1.5 times.
- **It never poisons and is never poisoned.** `src/shared/GiantBattle` has no status effects, and this giant needs none: the fog is its poison, told as damage. The test checks that a poisoning move does only its hit to the giant and that a whole fight leaves no creature poisoned.

| Phase | Starts | Pattern | What it teaches |
| --- | --- | --- | --- |
| **Low mist** | 100% | Fume Drift (team, 45), **Sinking Pull** (front wind-up, 165, Sand or Frost cancels it), Slough Slam (front, 145) | The tell, with one free turn to set up |
| **Rising fog** | 60% | Fume Drift, **Marsh Gas** (team wind-up, 120, Sand or Frost halves it), Marshlight Flare (Storm, front, 145), Slough Slam; hits 1.2 times harder | A team-wide wave, and a flare aimed at the Sand stoppers |
| **Deep fog** | 25% | Fume Drift, Sinking Pull, Fume Drift, Marsh Gas; hits 1.3 times harder | The seep twice a cycle with both waves: a healthy bench wins |

Enrage from turn 30 (+30% a turn). Captured, it is a gem-tier **Sloughback** (four-legged, Toxic, size 1.3, colour Moss) at level 46, with two signature moves nothing else has: **Marsh Gas** (Toxic 65, its head, level 38) and **Sinking Pull** (Water 60, its tail, level 40, so a Toxic creature can answer the Sand creatures that beat it). Neither poisons (poisoning moves are kept weak in this roster). Its parts cost exactly 200, like every species; its tail carries 20 Hp like the Mire's other tails. Adding it changed no other test's output (`breeding`, `poison`, `roster`, `giantcapture` compared with and without it).

### Measured win rates

Teams of **four** drawn at random from the 32 wild species of the four biomes (quality 3 to 7 parts), 300 seeded teams per row, first creature leads. "Any": whoever is drawn. "Counter": the best four moves include Sand or Frost. "Plain": the same pool with every Sand and Frost move taken away. "Base": best move, switch when about to faint, heal when low, five items. "Stop": the same plus swapping a Sand or Frost creature in on each wind-up turn and hitting with it on the release.

| Team level | Any, base | Any, stop | Counter, base | Counter, stop | Plain | Mean turns (any, base) | Reaching the enrage turn |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 42 | 50% | 73% | 59% | 85% | 1% | 20.1 | 0% |
| 44 | 54% | 77% | 64% | 88% | 1% | 19.7 | 0% |
| 45 | 62% | 78% | 70% | 90% | 6% | 19.8 | 0% |

On-level (44) sensible play wins about half the time (a win takes 18.9 turns); stopping the waves adds about 23 points. A team with no Sand or Frost move almost never wins, as with Carrackon and Leaf or Toxic. In the last phase a level 44 creature survives 1.5 (the fast Water and Sand creatures) to 2.8 (Bogbellow, Bulbroth) of its biggest hits: the Toxic creatures are the sturdiest here.

How the numbers were found: first tries at 4,000 and 3,200 health (with attack powers about a third lower) ran to 26 to 30 turns, with a third to a half of the fights reaching the enrage; lowering health to 2,300 and raising the attack powers by about half gave the table above.

## Robots: all four biomes

`tests/mire.test.luau` runs the robot players of `tests/playthrough.test.luau` unchanged, with the Mire open (the playthrough reads the biomes from the registry, so it plays four chapters). Every robot finishes, and all fifteen of its checks pass.

| Badge | Typical wild battles | Typical minutes of battling |
| --- | --- | --- |
| 1 | 32 | 39 |
| 2 | 40 | 49 |
| 3 | 58 | 66 |
| **4 (the Mire)** | **35** | **42** |

- The first robot: badge 4 at team level 45 after 31 wild battles and about 39 minutes; it beat Wren first try (team 38 against 33), the rival on the second (44 against 39) and the champion first try (45 against 43).
- Across the twelve robots: worst story battle 3 tries (unchanged), at most 23 losses in a playthrough (20 with three biomes), and 80 of 144 story battles won first time (57 of 108 with three biomes, so 23 of the Mire's 36: a little easier than the launch chapters, see the open questions).
- The Mire's badge is quicker than Tide Flats' because the robots arrive with the level cap at 45 and wild levels only reach 42: they train less, and team size four shares XP across one more creature.
- The playthrough's check "the launch biomes take about three hours of battling or less" sums every badge, so with the Mire open it sums four: 194 minutes, still under its 210. It was left as it is so its three-biome output stays identical; it reads oddly with four biomes open.

## Choices I made (each a [Default])

- **Names** are placeholders I believe are original: Sedgeholm, the Bell Cypress, the Duckboard Trail, Cypress Road, the Sunken Grove, the Sluice Gate, the Bulrush Badge, Sloughback and its five attacks, and every person. I checked them for near-misses with well-known creatures and games as far as I could from memory; "Marsh Gas" is a real phenomenon (like "Red Tide"), and "Dunlin" is a bird.
- **Champion at the gate, rival mid-biome**, alternating with Tide Flats.
- **The rival's tint 0.85**, not 1, leaving room for six more appearances.
- **The healer teaches poison**, since healing is where poison's cost shows (poison ends with the battle; the damage it did lasts until a tonic or the spring).
- **The quest creature is an Uncommon Bulbroth** (rarity "Uncommon", its species' own), the first quest creature that is not Common, so the gift is a creature the open routes never give.
- **The token is a Mistrel** with Hoarmist, the Frost teaser for Frostline. No species that beats Frost (Fire, Arcane) exists yet.
- **Mire wins drop Brine Shells** for now; no config was changed.
- **No config value was appended or changed.** The Mire needed none: `LEVEL_BANDS`, `BIOME_MULT` and `ONE_TIME_MULT` already have eleven entries, and `QUEST_LINE_CANDY` and `MATERIAL_BY_BIOME` are clamped to their last entry by the shared code.

## Open questions for Ayrton

1. **A Mire material** (for its own bait or recipe): adding one means a new `MaterialId` (a type and a config change), so it was left out. Mire wins drop Brine Shells meanwhile. Want one, and what for?
2. **Sloughback needs Sand or Frost**; a team with neither wins 1 to 6%. Same strictness as Carrackon. Keep?
3. **The Mire is a little easier for the robots** than the launch chapters (64% of its story battles won first time against 53%), mostly because they arrive near the cap. Fine for a fourth biome, or raise the tamers and the rival a level?
4. **The mentor's half-truth** ("a tear in the sky... how it opened, nobody knows") and the rival's "why the tear opened over Thistledown first": the right amount for chapter 4, with the truth kept for biome 9?
5. **The rival's attempt on the giant** as the first step to "giants taken by force": happy with it happening off-screen, told in his look and lines?
6. Should the playthrough's "launch biomes" pacing check count only the first three badges once later biomes open? (A one-line change; not made, to keep that file untouched.)
