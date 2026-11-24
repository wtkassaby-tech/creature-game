# Greenwood world

Greenwood's world as data: the hub, two routes, the lair, the gate, five tamers, the rival's teams, a quest line and chapter 1 of the story. Data lives in `src/content/biome_data/`, `tamer_data/`, `quest_data/` and `story_data/`; helpers are in `src/shared/World.luau`; the checks are `tests/world.test.luau` (about 2 seconds). Everything here is a [Default] the owner can change. The rival and the mentor are called "Rival" and "Mentor" until Ayrton names them.

## The map

Thistledown (hub, 300 x 300) sits between the two routes. Distances run from the hub outward, so wild levels rise as you walk.

| Route | Stretch (studs) | Levels | Lives here (open) | Rustle spot (uncommon) |
| --- | --- | --- | --- | --- |
| **A: Clover Lane** (400) | Mossy Glade 0-130 | 2-3 | Mossmitt, Gorsling | none |
| | Clover Meadow 130-270 | 3-5 | Gorsling, Mossmitt, Stumpwarden | none |
| | Brook Bend 270-400 | 4-6 | Sloshcalf, Splashjack, Gorsling | **Reed Bed** (340): Stiltbark, Splashjack, Sloshcalf |
| **B: River Road** (600) | Sandy Bank 0-150 | 6-8 | Spadesnout, Sloshcalf, Splashjack | **Heron Pool** (90): Stiltbark, Splashjack |
| | Birch Rise 150-330 | 7-9 | Gorsling, Stumpwarden, Mossmitt | none |
| | Old Wood 330-480 | 9-11 | Stumpwarden, Mossmitt, Spadesnout, Gorsling | **Burl Thicket** (400): Burlhorn, Stumpwarden |
| | Gatehouse Approach 480-600 | 10-12 | Gorsling, Spadesnout, Splashjack, Mossmitt | none |

- **Lair:** Hollowbough's Hollow (level 16 giant). A 250-stud spur leaves Route B at 330, with a supply stall at its start and a 150-stud arena. A shortcut back to the hub opens after the win. The giant is optional for the story.
- **Gate:** the Greenwood Gatehouse ends Route B (600). The rival fights here; the badge is the Acorn Badge. The Dust Canyon road is sealed until then. Recommended team levels on arrival: 12 to 15.
- **Hub buildings:** the Mentor's Cottage, Tuppence's Shop, Brightwater House (healer), the Nesting House (breeder), the Notice Oak (quests), the Waystation (teleport) and the Ring (Circuit arena).
- Every roster species appears. Both uncommon species (Stiltbark, Burlhorn) appear only at rustle spots, so nothing in the main line needs them. A rustle gives an uncommon creature about half the time or more (45% to 55%); the rest are commons. Each draw has a 2% chance of a rare colour (Ember, Frostbite or Starlight), the same number as the breeding rule's rare mutation.

## Tamers

| Tamer | Where | Look | Team | Says before |
| --- | --- | --- | --- | --- |
| Pip Alder | A, 100 | Freckled kid, big straw hat, butterfly net | Gorsling 3 | "My hat is lucky! One battle, then you can walk on." |
| Wren Tolliver | A, 330 | Cheerful angler, waders, reed hat | Sloshcalf 4, Splashjack 5 | "The brook is my patch. Show me you can handle it." |
| Odette Fenn | B, 110 | Birdwatcher, big binoculars | Gorsling 7, Stiltbark 8 | "Shh! You scared off a heron. You can make it up with a battle." |
| Basil Hedgeworth | B, 220 | Stout gardener, apron, shears | Mossmitt 8, Stumpwarden 9 | "Every hedge in Greenwood is mine to keep. Let us see your team." |
| Corwin Ashby | B, 440 | Broad woodcutter, red scarf, rope | Mossmitt 10, Burlhorn 11, Stumpwarden 11 | "I have felled bigger trees than you. Three of mine against your team." |

All use the Tamer AI tier. Each also has a line after losing (see `src/content/tamer_data/Greenwood.luau`).

**The rival** (Rival AI tier) picks his first creature for looks, not types, and it is the one that LOSES to yours (Leaf beats Water, Water beats Sand, Sand beats Leaf). By the gate he has learned: he leads with the starter that beats yours, and his first creature is still on the team behind it. (Changed 23 November 2026; see `docs/DECISIONS.md`. The teams in `src/content/tamer_data/Greenwood.luau` are the truth; this table follows them.)

| You pick | First battle (level 5, cannot be lost) | Gate team (levels 13, 12, 12; tint 0.25) |
| --- | --- | --- |
| Mossmitt (Leaf) | Sloshcalf | Spadesnout, Sloshcalf, Gorsling |
| Spadesnout (Sand) | Mossmitt | Sloshcalf, Mossmitt, Stumpwarden |
| Sloshcalf (Water) | Spadesnout | Mossmitt, Spadesnout, Stumpwarden |

First battle: "I picked the coolest one. Types? Who needs them. Watch this!" / "No fair, yours beats mine! Next time I bring the right one." Gate: "I know my types now. This one beats yours. No more playing around." / "Again... fine. I will get stronger, whatever it takes."

## Quest line: Thistledown Favours

Opens when the first-quest beat is done. Four quests in order, ending in a guaranteed creature, plus one optional quest.

| # | Quest | Giver | Objective | Reward |
| --- | --- | --- | --- | --- |
| 1 | Fresh Tracks | Marlow Tuppence (shop) | Win 4 wild battles on Route A | 3 Field Tonics |
| 2 | A Friend for the Pond | Hazel Brightwater (healer) | Tame a Splashjack | Braided Lasso, 6 Fernfluff |
| 3 | Heron Watch | Ilsa Corbin (Waystation) | Beat Odette Fenn | 2 Deep Tonics |
| 4 | The Woodcutter's Word | Juniper Vale (Notice Oak) | Beat Corwin Ashby | 400 coins, 2 candy, **a level 8 Stumpwarden** |
| Optional | The Sleeper in the Hollow | Juniper Vale | Beat Hollowbough (needs a Giant Horn) | Rally Root, 5 Fernfluff |

The coins and candy for the line come from `EconomyConfig` (quest-line coins times the biome 1 one-time multiplier, and the biome 1 quest-line candy).

## Chapter 1 beats

Times are minutes from the start, from the first-session script. The first quest is at 12 to 15 minutes; the badge is inside 60.

| # | Beat | Time | Trigger | Gives |
| --- | --- | --- | --- | --- |
| 1 | Pick a friend | 0-0.5 | Start (no cutscene) | Starter, level 5 |
| 2 | A challenge | 0.5-2 | Follows beat 1 | Battles open; the rival's first battle |
| 3 | A sore loser | 1.5-2.5 | Win vs the rival | The rival notices a glint; the mentor lies about it |
| 4 | The lasso lesson | 2-4 | Follows beat 3 | A guaranteed Gorsling (level 2), 150 coins, 5 Rope Lassos, 3 tonics |
| 5 | Out on Route A | 4-6 | Enter Route A | Route A, shop, healer |
| 6 | A local tamer | 5-8 | Win vs Pip | Tamer rematches |
| 7 | The tree that walks | 6-8 | See the giant from Clover Meadow | Giant marker; the mentor asks you to stay away |
| 8 | **The mentor's egg** | 8-12 | Talk to the mentor | Egg (Stumpwarden x Splashjack), second pen, 2 candy |
| 9 | A team of three | 12-15 | Tame any creature | Team of three |
| 10 | Thistledown favours | 12-15 | Talk to Marlow | Quest line, world map, Route B |
| 11 | The gatehouse | 40-55 | Enter the gate | The rival's challenge |
| 12 | The first badge | 45-58 | Win vs the rival's gate team | Acorn Badge, 750 coins, 5 candy, **clear token: a level 12 Gorsling**, level cap 25, daily tasks |
| 13 | The road on | 50-60 | Enter the sealed path | Dust Canyon opens; a teaser for chapter 2 |

Dialogue is at most three lines of 90 characters a beat. The arc: the rival loses and begins to turn (the glint, the tint on his gate team, "I do not play around any more"); the mentor is kind and hides something (the "pebble", the giant, "do not ask what you must be strong for").

## Choices I made (each a [Default])

- Distances run from the hub, so levels rise with distance; Route A is the first outing, Route B leads to the gate.
- The giant is optional: the main line and quest line never need it, and it sits in an optional quest.
- The quest line's guaranteed creature is a Stumpwarden (a common tank); the clear token is a Gorsling (a common sprinter). Both are also catchable in the wild.
- The starter is level 5, the rival's first team level 4, the second creature level 2, the egg parents a Stumpwarden and a Splashjack (both two-legged, so the egg mixes parts).
- A rustle spot gives an uncommon creature 45 to 55% of the time, so a hunt is not a waste.
- The rare colour chance on every row reuses `BreedConfig.RARE_MUTATION_CHANCE` (2%).
- The mentor lesson's candy and pen, the gate's coins and candy, and the opening gifts read from `EconomyConfig`.
- The Dust Canyon road is shown sealed at the gate and opens with the badge; this closes chapter 1.
- The tamers' levels (3 to 11) stay under the gate team (13 to 14) so a player fighting the tamers on the way arrives at about level 12 or higher.
