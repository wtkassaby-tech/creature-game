# Tide Flats world

Tide Flats' world as data: the hub (Saltwick), two routes, the lair, the gate, five tamers, a mid-biome champion, the rival at the gate, a quest line, chapter 3 of the story and the giant Carrackon. Data lives in `src/content/biome_data/`, `tamer_data/`, `quest_data/`, `story_data/` and `giant_data/` (plus `species_data/Carrackon.luau` and two moves in `Moves.luau`); the checks are `tests/tideflats.test.luau` (about 2 seconds). It mirrors `DUST_CANYON_WORLD.md`. Everything here is a [Default] the owner can change. The rival and the mentor are still called "Rival" and "Mentor".

## The map

Saltwick (hub, 300 x 300) sits between the two routes. Wild levels rise with distance (22 to 32, the economy's band for biome 3).

| Route | Stretch (studs) | Levels | Lives here (open) | Rustle spot |
| --- | --- | --- | --- | --- |
| **A: Strandline Path** (500) | Wrack Beach 0-160 | 22-23 | Glissot, Cocklemole, Runnelfin; rarely Duneskit, Wadibuck (Dust Canyon strays) | none |
| | Rockpool Shelf 160-330 | 23-25 | Gulpmaw, Cocklemole, Glissot, Clapshell | **Anemone Pools** (260): Hullock, Gulpmaw, Cocklemole |
| | Kelp Shallows 330-500 | 25-27 | Runnelfin, Gulpmaw, Glissot, Moatkeep | **Kelp Bed** (430): Lanternell, Glissot, Runnelfin |
| **B: Breakwater Road** (720) | Sandbar Causeway 0-180 | 27-28 | Moatkeep, Glissot, Clapshell, Cocklemole | none |
| | Mudflat Boardwalk 180-360 | 28-30 | Gulpmaw, Runnelfin, Moatkeep, Clapshell, Cocklemole | none |
| | Shipwreck Reach 360-540 | 29-31 | Clapshell, Gulpmaw, Glissot, Moatkeep, Runnelfin | **Tide Cave** (470): Lanternell, Hullock, Moatkeep, Clapshell |
| | Tideward Steps 540-720 | 30-32 | Moatkeep, Clapshell, Cocklemole, Glissot, Runnelfin, Gulpmaw | none |

- **Bait.** Bait is used at a rustle spot from this biome on, so all three spots are places you would fish: rock pools, a kelp bed and a sea cave. Both uncommon species (Hullock, Lanternell) appear only at spots (45% to 65% uncommon per rustle), so nothing in the main line needs them.
- **Gem tier.** Every open row of a Tide Flats species has a gem-tier twin (`withGems`, as in Dust Canyon), weighted so that `EconomyConfig.GEM_WILD_SHARE` of open encounters in each stretch are gem-tier. Spots give none from the table. The two Dust Canyon strays have no twin, so Wrack Beach sits just under the share (16 of 136 base weight are strays).
- **Lair:** Carrackon's Wreck (level 36 giant). A 280-stud spur leaves Route B at 440 (inside Shipwreck Reach), with a supply stall and a 170-stud arena; a shortcut to the hub opens after the win. Optional for the story.
- **Gate:** the Breakwater Gate ends Route B (720), held by **the rival** (master plan 4.5). Badge: the Breaker Badge. The road to biome 4 (the Mire) is sealed until then. Recommended levels on arrival: 32 to 35 (35 is the cap with two badges).
- **Hub buildings:** Tarn's Chandlery (shop, keeper Odalys Tarn), the Warm Pool (healer), the Brood Shallows (breeder), the Tally Board (quests), the Ferry Steps (teleport, ferryman Bastian Wake), the Breaker Ring (Circuit) and the Lamp Tower (lookout, the seventh building, as in Dust Canyon). No name repeats one in another biome (the test checks).

## Tamers

| Tamer | Where | Team |
| --- | --- | --- |
| Nell Sandow (beachcomber) | A, 120 | Glissot 23, Cocklemole 23 |
| Merrin Kelpwood (kelp harvester) | A, 400 | Runnelfin 25, Gulpmaw 26 |
| Orrin Dredge (dockhand) | B, 110 | Moatkeep 28, Clapshell 28 |
| Isaura Penhallow (lighthouse apprentice) | B, 400 | Lanternell 30, Glissot 30, Hullock 31 |
| Ludo Brackwater (net-mender) | B, 620 | Gulpmaw 32, Cocklemole 31, Clapshell 32 |

All use the Tamer AI tier, tint 0, and only moves the creature can know at that level (the test builds each creature and checks its move pool). The top level, 32, is the gate's floor.

**Mid-biome champion:** Captain Hepzibah Marr, on the Mudflat Boardwalk (a story battle, Rival tier, counts as a Rival fight, one team: Hullock 29, Moatkeep 29, Lanternell 30, tint 0). She is a local, not the rival, so she gives the story a Water-biome face and the first Red Tide (Toxic) the player meets. Per the coordinator's rule only the rival's very first Greenwood battle cannot be lost, so a loss counts.

**The rival at the gate** (story battle `rival_breakwater`, Rival tier, counts as a Gate fight, one team per starter, levels 32 to 34, a loss is not free). **Tint 0.75** (Greenwood 0.25, Dust Canyon 0.5). He still leads with the starter that counters yours, and behind it he covers your answer:

| You pick | Rival's gate team |
| --- | --- |
| Mossmitt (Leaf) | Spadesnout 34, Cocklemole 33, Whirlgrit 32 |
| Spadesnout (Sand) | Sloshcalf 34, Thatchling 33, Clapshell 32 |
| Sloshcalf (Water) | Mossmitt 34, Moatkeep 33, Spurlet 32 |

"Some of his creatures are gem-touched" is told in his look (two amber shards) and lines; team data has no rarity field, so it is not in the numbers.

## Quest line: Saltwick Tallies

Opens after the "Tarn's Chandlery" beat (bait). Four quests, ending in a guaranteed creature, plus one optional.

| # | Quest | Giver (building) | Objective | Reward |
| --- | --- | --- | --- | --- |
| 1 | First Haul | Odalys Tarn (Chandlery) | Win 4 wild battles on Route A | 4 Field Tonics |
| 2 | A Friend for the Pool | Perdita Lugg (Warm Pool) | Tame a Glissot | 2 Braided Lassos, 6 Brine Shells |
| 3 | Lamp Trouble | Bastian Wake (Ferry Steps) | Beat Isaura Penhallow | 2 Deep Tonics, 4 Brine Shells |
| 4 | The Gate Tally | Hobb Pellow (Tally Board) | Beat Ludo Brackwater | coins and candy from the economy (biome 3), **a level 26 Clapshell** |
| Optional | The Wreck That Walks | Hobb Pellow | Beat Carrackon (needs a Giant Horn; opens after the wreck is seen) | Rally Root, 5 Brine Shells |

Steps 2 and 3 pay 10 Brine Shells in all, enough for the first Tide Bait (the recipe takes 8; the test checks it).

## Chapter 3 beats

Chapter 2 ends at minute 140; the first beat requires its last one (`canyon_road_on`).

| # | Beat | Time | Trigger | Gives |
| --- | --- | --- | --- | --- |
| 1 | Saltwick | 140-144 | Enter the hub | Hub open |
| 2 | Tarn's Chandlery | 142-147 | Talk to Odalys | **Bait** unlocked; quest line, routes. She explains Tide Bait and rustle spots |
| 3 | A local tamer | 144-154 | Win vs Nell | |
| 4 | A catch from the shallows | 148-158 | Tame any creature | Gem-tier hint |
| 5 | A note from Thistledown | 154-162 | Talk to Bastian | 2 Tide Baits; the mentor's note |
| 6 | Captain Marr | 160-172 | Win vs Marr | |
| 7 | The wreck that walks | 170-180 | See Shipwreck Reach | Giant marker; "its big waves fear leaf and poison" |
| 8 | The Breakwater Gate | 190-205 | Enter the gate | The rival's speech |
| 9 | The third badge | 195-210 | Win vs the rival | Breaker Badge, coins and candy from the economy, **clear token: a level 32 Moatkeep (Sand, good against the Mire)**, level cap 45 |
| 10 | The road on | 200-215 | Enter the sealed path | Opens biome 4; teases the Mire |

**The arc, one more step.** The rival now says the glint "hums even in my sleep" and that the mentor "knows what that flicker is", then goes into the Mire alone. The mentor's note calls the sky's flicker "weather" but admits "I should have told you more, long ago", and the promise to explain now has a place: the Mire.

## The giant: Carrackon

A hermit crab as big as a hill, wearing a wrecked ship for a shell. Water, level 36, 2,200 health, Attack 300, Defence 72. Weak to **Leaf and Toxic**.

**The fight idea: "the tide table".** Hollowbough's fight is about one slam a Sand lead shrugs off; Mesalith's is about swapping a stopper in and out. Carrackon is about rhythm and the type cycle:
- Every phase has a wave announced a turn early, on a fixed table. The fight opens on the tell (Rolling Breaker is the first intent, no free turn), and the last phase keeps its waves, so there is no pure damage race.
- It carries one attack for each type of the roster's majority: **Water** (Pincer Snap, Rolling Breaker, Flood Surge) hurts Sand creatures, **Sand** (Silt Cloud) hurts the Leaf creatures that stop its waves, and **Toxic** (Brine Bloom, a teaser for the Mire) hurts Water creatures. Every stopper has an attack aimed at it, and every team has someone in the line of fire.

| Phase | Starts | Pattern | What it teaches |
| --- | --- | --- | --- |
| **Ebb tide** | 100% | **Rolling Breaker** (front wind-up, Leaf or Toxic cancels it), Silt Cloud, Brine Bloom | The tell, with no free turn |
| **Flood tide** | 60% | Silt Cloud, **Flood Surge** (team wind-up, Leaf or Toxic halves it), Brine Bloom, Pincer Snap; hits 1.2 times harder | Stoppers are worn down between waves |
| **Spring tide** | 25% | Rolling Breaker, Silt Cloud, Flood Surge, Brine Bloom; hits 1.4 times harder | A wave every third turn: keep a stopper healthy |

Enrage from turn 30 (+30% a turn). Captured, it is a gem-tier **Carrackon** (four-legged, Water, size 1.3, colour Moss) at level 36, with two signature moves nothing else has: **Rolling Breaker** (Water 65, its head, level 28) and **Silt Cloud** (Sand 60, its tail, level 30, so a Water creature can answer Leaf and Toxic). Its parts cost exactly 200, like every species.

### Measured win rates

Teams of three drawn at random from the 24 wild species of the three biomes (quality 3 to 7 parts), 300 seeded teams per row, first creature leads. "Any": whoever is drawn. "Counter": the best four moves include Leaf or Toxic. "Plain": the same pool with every Leaf and Toxic move taken away (species left with no move, most Leaf species, are redrawn). "Base": best move, switch when about to faint, heal when low, five items. "Stop": the same plus swapping a Leaf or Toxic creature in on each wind-up turn and hitting with it on the release.

| Team level | Any, base | Any, stop | Counter, base | Counter, stop | Plain | Mean turns (any, base) | Reaching the enrage turn |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 32 | 37% | 77% | 41% | 86% | 0% | 22.6 | 0% |
| 34 | 51% | 81% | 57% | 92% | 0% | 22.3 | 0% |
| 35 | 57% | 85% | 63% | 96% | 0% | 21.8 | 0% |

On-level (34) sensible play wins about half the time; stopping the waves adds about 30 points. Because most of the pool is Water or Sand and many carry Leaf moves, a random team is already close to a "counter" team (51% against 57%); the big gap is to a team with no Leaf or Toxic at all, which cannot win. In the last phase a level 34 creature survives 1.5 to 2.3 of the giant's biggest hits (Sand creatures take Water at 1.5 times, so Duneskit and Spadesnout are lowest).

## Choices I made (each a [Default])

- **Names.** Saltwick, Carrackon, Odalys Tarn, Bastian Wake, Perdita Lugg, Hobb Pellow, Captain Hepzibah Marr, the five tamers and the Breaker Badge are placeholders I believe are original (not checked against other games).
- **The mid-biome battle is a local champion, not a lieutenant.** The brief gives the rival no lieutenant, and Dust Canyon's champion worked well.
- **Carrackon is Water, weak to Leaf and Toxic**, so Greenwood's Leaf creatures and the Sand torsos with Red Tide are the stoppers. A plain Water or Sand team cannot win, which makes the Leaf and Toxic creatures from the earlier biomes matter.
- **Giant stats are higher than Mesalith's relative to level** (Attack 300 against 160), because Attack saturates in the damage formula; the powers and phase multipliers carry the difficulty. The test's survival thresholds are looser than Dust Canyon's (1.3 and 2.0 hits against 2 and 3) because the last phase hits 1.4 times as hard.
- **Wind-ups in every phase**, including the last, unlike the earlier two giants.
- **The token is a Moatkeep** (Sand, strong against Toxic, the next biome's type); the quest line's creature is a Clapshell.
- **Beat count is 10.** The mentor's parcel pays two Tide Baits so bait can be tried before the lair.

## Open questions for Ayrton

1. The rival's tint (0.75) and "ask your mentor what the flicker is": right amount of foreshadowing for chapter 3? Gem-touched creatures are in his look and lines only (no rarity field in team data).
2. Carrackon needs Leaf or Toxic; a team with neither never wins. Happy with that, or should a plain team have a small chance (the cost is that a random team would then win more than 65%)?
3. Mid-biome battle: Captain Marr (a local champion) or a lieutenant of the rival?
