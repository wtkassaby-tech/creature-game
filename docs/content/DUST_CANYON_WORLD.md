# Dust Canyon world

Dust Canyon's world as data: the hub (Kilnrest), two routes, the lair, the gate, five tamers, the rival's mid-biome team, the gate champion, a quest line, chapter 2 of the story and the giant Mesalith. Data lives in `src/content/biome_data/`, `tamer_data/`, `quest_data/`, `story_data/` and `giant_data/` (plus `species_data/Mesalith.luau` and two moves in `Moves.luau`); the checks are `tests/dustcanyon.test.luau` (about 2 seconds). It mirrors `GREENWOOD_WORLD.md`. Everything here is a [Default] the owner can change. The rival and the mentor are still called "Rival" and "Mentor".

## The map

Kilnrest (hub, 300 x 300) sits between the two routes. Distances run from the hub outward, so wild levels rise as you walk (12 to 22, the economy's band for biome 2).

| Route | Stretch (studs) | Levels | Lives here (open) | Rustle spot (uncommon) |
| --- | --- | --- | --- | --- |
| **A: Dry Wash Trail** (450) | Pebble Wash 0-150 | 12-13 | Duneskit, Spurlet; rarely Gorsling, Spadesnout (Greenwood strays) | none |
| | Tumbleweed Flats 150-300 | 13-15 | Duneskit, Whirlgrit, Thatchling, Spurlet | none |
| | Hollow Arroyo 300-450 | 14-16 | Wadibuck, Flintknap, Whirlgrit, Thatchling | **Cairn Field** (390): Cairnback, Wadibuck, Flintknap |
| **B: Mesa Road** (680) | Redstone Steps 0-170 | 16-18 | Flintknap, Duneskit, Wadibuck, Whirlgrit | none |
| | Sunbaked Rim 170-340 | 17-19 | Whirlgrit, Thatchling, Spurlet, Duneskit, Flintknap | **Echo Notch** (200): Spirecap, Whirlgrit, Duneskit |
| | Spire Garden 340-520 | 18-21 | Flintknap, Thatchling, Whirlgrit, Wadibuck, Spurlet | **Capstone Garden** (500): Spirecap, Cairnback, Thatchling |
| | Stair Approach 520-680 | 20-22 | Duneskit, Whirlgrit, Flintknap, Thatchling, Wadibuck, Spurlet | none |

- **Lair:** Mesalith's Shelf (level 26 giant). A 260-stud spur leaves Route B at 360 (inside the Spire Garden), with a supply stall at its start and a 160-stud arena. A shortcut back to the hub opens after the win. The giant is optional for the story.
- **Gate:** the Stair Gate ends Route B (680). A **local champion**, Isolde Karrow, holds it (master plan 4.5); the badge is the Cairn Badge. The road to biome 3 (Tide Flats) is sealed until then. Recommended team levels on arrival: 22 to 25 (25 is the cap with one badge).
- **Hub buildings:** Rook's Trading Post (shop, keeper Tamsin Rook), the Seep House (healer), the Cradle Kiln (breeder), the Notice Wall (quests), the Sundial Waystation (teleport, courier Fenwick Dray), the Dust Ring (Circuit arena) and the Windward Overlook (lookout; the seventh building, standing in for Greenwood's mentor's cottage, because the mentor stayed in Thistledown).
- Every Dust Canyon species appears. Both uncommon species (Cairnback, Spirecap) appear only at rustle spots (45% to 75% uncommon per rustle), so nothing in the main line needs them. The two Greenwood strays are 16 of 111 weight at the top of the wash only. Each draw has a 2% chance of a rare colour, the same number as the breeding rule's rare mutation. A Greenwood stray keeps the first colour its Greenwood rows give it, so a gifted one wears the same colour whichever biome is searched first.
- **No gem-tier rows yet.** The first gem tier is this biome's "one new idea", but a gem-tier spawn row needs the spawn engine to learn a second rarity, which is engine work not done here. Chapter 2 still introduces it in dialogue.

## Tamers

| Tamer | Where | Look | Team | Says before |
| --- | --- | --- | --- | --- |
| Ines Parchwell | A, 110 | Rockhound, goggles on her forehead, hammer | Duneskit 13, Spurlet 13 | "Rocks, rocks, rocks! Beat me and I will show you the good ones." |
| Rafe Gullick | A, 340 | Wash guide, wide hat, dripping canteen | Wadibuck 14, Thatchling 15 | "Water is gold out here, and I know every drop. Care to test me?" |
| Perrin Skelt | B, 100 | Kiln hand, soot-black apron | Flintknap 17, Whirlgrit 17 | "I bake bricks all day. A battle is a nice break. Come on!" |
| Hesper Dunnock | B, 440 | Surveyor, brass sighting scope | Spirecap 19, Duneskit 19, Wadibuck 20 | "My maps say you stand exactly where I want you." |
| Tavish Orrel | B, 600 | Lanky mesa guide, red headscarf, rope | Cairnback 21, Flintknap 21, Thatchling 22 | "Nobody reaches the Stair Gate without passing me." |

All use the Tamer AI tier. Every move is one the creature can know at that level (the test builds each creature and checks its move pool).

**The rival** appears once, on the Sunbaked Rim, as a story battle with one team per starter (Rival tier, counts as a Rival fight, a loss costs nothing and he is offered again). He still leads with the starter that counters yours, the same lead species as Greenwood's gate team, now with two newer creatures behind it. **His team's tint is 0.5**, double Greenwood's 0.25.

| You pick | Rival's mid-biome team (levels 19, 18, 18) |
| --- | --- |
| Mossmitt (Leaf) | Spadesnout, Wadibuck, Whirlgrit |
| Spadesnout (Sand) | Sloshcalf, Thatchling, Spurlet |
| Sloshcalf (Water) | Mossmitt, Spurlet, Cairnback |

**The gate champion**, Isolde Karrow (a tall warden in a sun-bleached cloak, a brass whistle): Whirlgrit 22, Cairnback 23, Thatchling 24; Rival AI tier, counts as a Gate fight, one team for every player. Sand with one Leaf creature to answer a Water team. A loss is not free.

## Quest line: Kilnrest Errands

Opens when the "Rook's Trading Post" beat is done. Four quests in order, ending in a guaranteed creature, plus one optional quest. Each giver stands at a hub building.

| # | Quest | Giver (building) | Objective | Reward |
| --- | --- | --- | --- | --- |
| 1 | Dry Run | Tamsin Rook (Trading Post) | Win 4 wild battles on Route A | 4 Field Tonics |
| 2 | A Friend for the Seep | Calla Seep (Seep House) | Tame a Wadibuck | 2 Braided Lassos, 6 Canyon Grit |
| 3 | Survey Trouble | Fenwick Dray (Waystation) | Beat Hesper Dunnock | 2 Deep Tonics |
| 4 | The Warden's Word | Ottoline Marsh (Notice Wall) | Beat Tavish Orrel | 600 coins, 3 candy, **a level 16 Flintknap** |
| Optional | The Mesa That Walks | Ottoline Marsh | Beat Mesalith (needs a Giant Horn; opens after the mesa is seen) | Rally Root, 5 Canyon Grit |

The coins and candy for the line come from `EconomyConfig` (quest-line coins times the biome 2 one-time multiplier, and the biome 2 quest-line candy). Canyon Grit is Dust Canyon's material.

## Chapter 2 beats

Minutes from the start; chapter 1 ends at minute 60 and the first beat requires its last one (`sealed_path`).

| # | Beat | Time | Trigger | Gives |
| --- | --- | --- | --- | --- |
| 1 | Kilnrest | 60-64 | Enter the hub | Hub open |
| 2 | Rook's Trading Post | 62-67 | Talk to Tamsin | Quest line, Mesa Road; the gem tier is mentioned |
| 3 | A catch in the canyon | 64-72 | Tame any creature | Gem hunting hint |
| 4 | A local tamer | 66-76 | Win vs Ines | |
| 5 | A letter from Thistledown | 72-80 | Talk to Fenwick | 2 Braided Lassos; the mentor's letter |
| 6 | The shard | 85-95 | Win vs the rival | The rival's hint |
| 7 | The mesa that walks | 95-105 | See the Spire Garden | Giant marker |
| 8 | The Stair Gate | 115-130 | Enter the gate | Isolde's warning |
| 9 | The second badge | 120-135 | Win vs Isolde | Cairn Badge, 750 coins, 5 candy, **clear token: a level 22 Duneskit**, level cap 35 |
| 10 | The road on | 125-140 | Enter the sealed path | Opens biome 3; a teaser for chapter 3 |

Dialogue is at most three lines of 90 characters a beat.

**The arc, one step on.** The rival has found more of the glint: his tint has doubled, he carries a shard that hums when he fights, and he tells the player to ask the mentor what it is ("He never answers me, either"). Isolde says he pushed past her at dawn with a team that gleamed like glass, so he is getting ahead by dark means. The mentor keeps lying: a letter says the glowing stones are "only minerals" and that they will talk "when you are older. I promise", the second small evasion since Greenwood's "do not ask what you must be strong for".

## The giant: Mesalith

A colossal red mesa that walks. Sand, level 26, 1,500 health, Attack 160, Defence 75 (about 1.8 times the combined health of three level 24 creatures, below Hollowbough's 2.5: it hits harder instead, so fights stay near 20 turns). Weak to **Water and Storm**.

**The fight idea: "hit and swap".** Water and Storm are the types that stop its wind-ups (a hit on the charged turn cancels Strata Crush and halves Strata Quake). But the creatures that carry those types are the ones its attacks are built to hurt: its Leaf Tumble Barrage hits Water creatures hard, and its Sand attacks hit the Leaf creatures that carry the Storm move Dust Squall. A creature that stays in to stop every wind-up is knocked out. The answer is to swap the stopper in on the wind-up turn (nothing lands on the turn the giant only charges), hit on the release turn, and swap out again. Fast, fragile creatures are good at that, which is the biome's idea. Hollowbough's fight is about a Sand lead shrugging off its slam; this one is about timing a swap.

| Phase | Starts | Pattern | What it teaches |
| --- | --- | --- | --- |
| **Cap rock** | 100% | Gravel Pelt (Sand), Tumble Barrage (Leaf), then **Strata Crush** (wind-up, Water or Storm cancels it) | The tell and the swap |
| **Red bed** | 60% | Tumble Barrage, Redbed Slide (team), **Strata Quake** (team wind-up, Water or Storm halves it), Redbed Slide | Everyone is in danger; no safe place to hide |
| **Heartstone** | 25% | Heartstone Rampage, Redbed Slide, Tumble Barrage, Heartstone Rampage; hits 1.2 times harder, no wind-ups | A damage race |

Enrage from turn 30 (+30% a turn, up to the config cap). Captured, it is a gem-tier **Mesalith** (two-legged, Sand, size 1.3) at level 26, with two signature moves nothing else has: **Strata Crush** (Sand 65, its head) and **Tumble Barrage** (Leaf 60, its tail, so a Sand creature can answer Water). Its parts cost exactly the plan budget (200), like every species.

### Measured win rates

Teams of three drawn at random from the sixteen species of both biomes (quality 3 to 7 parts), 300 seeded teams per row, first creature leads. "Any": whoever is drawn. "Counter": the team's best four moves include Water or Storm. "Plain": the same teams with every Water and Storm move taken away. "Base" policy: best move, switch when about to faint, heal when low, five items. "Stop" policy: the same, plus swap to a Water or Storm creature on the wind-up turn and hit with it on the release turn.

| Team level | Any, base | Any, stop | Counter, base | Counter, stop | Plain | Mean turns (any, base) | Fights reaching the enrage turn |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 22 | 37% | 50% | 57% | 76% | 3% | 23.1 | 1% |
| 24 | 54% | 68% | 73% | 91% | 16% | 22.7 | 1% |
| 25 | 62% | 72% | 80% | 94% | 23% | 22.5 | 1% |

On-level (24) sensible play wins about half the time, bringing Water or Storm adds about 20 points, and stopping the wind-ups adds about 20 more. A team with no Water or Storm move is not shut out but rarely wins (and loses more often by the clock, 7 to 9% reaching the enrage turn). A level 24 creature survives 2.1 to 3.7 of the giant's biggest hits from full health; Spirecap and Splashjack survive about 3.7 and Cairnback 3.6.

## Choices I made (each a [Default])

- **Names.** Kilnrest, Mesalith, Isolde Karrow, Tamsin Rook, Fenwick Dray, Calla Seep, Ottoline Marsh and the five tamers are placeholders I believe are original (not checked against other games).
- **The champion is a woman in her own right, not a tinted rival**, so her team has tint 0 and the gate is "earned, not given".
- **The rival's battle is mid-biome on the Sunbaked Rim, and a loss costs nothing** (he is offered again at once), because it is a story moment and not a gate. The gate champion's loss is not free, like Greenwood's gate.
- **The seventh building is a lookout**, not a mentor's cottage, because the mentor stays in Greenwood; his arc runs through a letter at the Waystation.
- **The giant is optional**, sits in an optional quest, and its sighting beat is the Spire Garden (where the spur leaves Route B).
- **Giant health is lower than the 2.5 times guide** and its attack higher, so fights end near turn 20 and the enrage turn is rare; the numbers are in `src/content/giant_data/DustCanyon.luau`.
- **The quest line's guaranteed creature is a Flintknap** (a common bruiser); the clear token is a Duneskit (a common sprinter), level 22, three under the cap of 25. Both are catchable in the wild.
- **Beat count is 10**, the low end of "about 10 to 12": more would be filler.

## Open questions for Ayrton

1. The tint (0.5) and the rival's "ask your mentor" line: right amount of foreshadowing, or too much for chapter 2?
2. Mesalith's weak types are Water and Storm, so the player wants Wadibuck, Sloshcalf and Splashjack (and a Leaf creature with Dust Squall) for it. Happy with Water being the answer in a Sand biome?
3. A real gem-tier spawn row needs engine work. Until then Dust Canyon has no gems in the wild.
