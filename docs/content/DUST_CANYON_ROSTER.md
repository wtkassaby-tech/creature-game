# Dust Canyon roster

The second roster: the eight species of Dust Canyon (biome 2, Sand), their parts and moves, and the balance gate they pass alone and mixed with Greenwood. Data lives in `src/content/species_data/`, `src/content/Moves.luau` and `src/content/Species.luau`; the gate is `tests/roster.test.luau` (about 11 seconds for both biomes). It follows the method of `GREENWOOD_ROSTER.md`. No config number and no Greenwood species was changed. Everything here is a [Default] the owner can change.

## At a glance

| Species | Plan | Type | Rarity | Role | Lasso |
| --- | --- | --- | --- | --- | --- |
| Cairnback | Four-legged | Sand | Uncommon | Bruiser: the most Defence in Dust Canyon, the slowest | 1.7 |
| Duneskit | Four-legged | Sand | Common | Sprinter: fast, average Attack | 1.3 |
| Spurlet | Four-legged | Leaf | Common | Striker: the most Attack on four legs | 1.2 |
| Wadibuck | Four-legged | Water | Common | Fast striker: quick, the thinnest Defence on four legs | 1.2 |
| Flintknap | Two-legged | Sand | Common | Bruiser: the most Attack and Hp in Dust Canyon, slow | 1.2 |
| Spirecap | Two-legged | Sand | Uncommon | Sturdy all-rounder | 1.8 |
| Thatchling | Two-legged | Leaf | Common | All-rounder: the Leaf answer to the canyon, with a Storm move on its torso | 1.2 |
| Whirlgrit | Two-legged | Sand | Common | Sprinter: the fastest on two legs, the least Defence in the game | 1.3 |

- **Five Sand, two Leaf, one Water.** Four species on each body plan. Six Common, two Uncommon (Cairnback, Spirecap).
- **Gem tier ("Amber", `Gem` in code).** Not a separate species: any of the eight can spawn wild as a Gem individual (+5% stats from `BreedConfig.RARITY_BOOST`, a serial number). Nothing in the species data changes; the spawn chance lives with the economy and world data.
- **Fast and fragile, but not only fast.** Dust Canyon averages Speed 47 and Defence 29 at quality 5, against Greenwood's 44 and 34. Its legs are the Speed parts: Duneskit, Whirlgrit and Wadibuck legs carry 37 to 39 Speed (Greenwood's best is 34), which is how the biome "favours Speed for breeding". They are light (36 to 46), so on a heavy Greenwood torso the fit factor slows them, and the gain is a real choice rather than free. Two species are deliberately not fast (Cairnback, Flintknap), and the measured winners are spread across roles, so Speed is not the only stat that matters.
- **Lasso difficulty a step above Greenwood's.** Commons 1.2, the two skittish sprinters 1.3 (Greenwood commons 1.0 to 1.1); uncommons 1.7 and 1.8 (Greenwood 1.4 and 1.5). At 1.6 and above `LassoConfig` gives two target zones, so the uncommons are the first two-zone catches in the game.
- **No later-type species.** A Storm torso is weak to nothing in the launch triangle and strong against Sand, so in a Sand biome it would beat its neighbours on type alone; a Toxic torso would be easy prey for the Sand majority. Storm appears as a teaser move instead (Dust Squall, on the two Leaf torsos only).

## The species and how they look

Art direction for every part: chunky low-poly, flat colours, every joint ends in a rounded ball that sits in the torso socket. Silhouettes are kept apart from Greenwood's (no stilts, no back-ponds, no boxing mitts): stone stacks, shutter ears, a pressed rosette, glass-tube horns, flint blades, a capstone spire, a leaf-thatch skirt and a floating sand ring. Each species file carries the same descriptions as comments.

**Cairnback**: a sure-footed mesa climber built like a walking pile of trail-marker stones.
- Head: a heavy round boulder of a head with a flat slate brow, two stubby rounded horns of stacked pebbles and a lower jaw like a stone slab.
- Torso: a deep body of three big rounded stones stacked front to back, the middle one tallest, speckled with lichen-orange spots.
- Front legs: short, thick forelegs of two stacked stone drums each, ending in squared-off hooves.
- Hind legs: short, sturdy hind legs with split, goat-like hooves for gripping ledges.
- Tail: a short stub of three shrinking pebbles in a row.

**Duneskit**: a lean dune sprinter that skims the sand on fringed feet, its tall shutter ears snapping flat when it runs.
- Head: a narrow wedge-shaped head like a doorstop, two tall ears each made of three stacked sandstone slats like window shutters, small black bead eyes; pale ochre with a rust-red nose tip.
- Torso: a short, light, arched body with a tucked-up belly and three faint rust bands across the back.
- Front legs: thin forelegs with knobbly wrists and small curved scoop claws for flicking sand.
- Hind legs: long, folded hind legs with oversized flat feet fringed with stiff comb-like scales for running on loose sand.
- Tail: a long thin tail ending in a flat diamond-shaped vane it steers with.

**Spurlet**: a low, flat succulent creature that sits rooted in the sun by day and scuttles between shadows by night.
- Head: a small flattened head with a crown of short, thick, pointed leaves fanning backward, each ending in one dark spine, and a blunt beak-like mouth.
- Torso: a flat, wide body shaped like a pressed rosette: fleshy leaves overlapping outward from the spine, sage green with pale edges.
- Front legs: short, bowed forelegs set wide at the sides, each ending in three stubby leaf-tip toes.
- Hind legs: short, bowed hind legs, also set wide, with knotted root-like heels.
- Tail: a stiff tail that rises into a single tall flower spike topped with a yellow bud.

**Wadibuck**: a skittish antelope of dry riverbeds whose hollow horns fill with water whenever a flash flood comes through.
- Head: a slim, long-muzzled head with two tall ringed horns that curl back in an open spiral, each a clear blue tube with water inside (one solid transparent part, no physics), and wide-set dark eyes.
- Torso: a slender, deep-chested body in sand-buff with a wavy blue stripe along each flank like a tide line.
- Front legs: very thin, straight forelegs with dark cloven hooves.
- Hind legs: long, springy hind legs with high hocks.
- Tail: a short upright tail like a paintbrush, its blue tip holding a single hanging drop.

**Flintknap**: a broad-shouldered flint-chipper whose forearms end in knapped stone blades it keeps sharpening on the canyon walls.
- Head: a long, angular head with a jutting jaw and a ridge of chipped flint flakes in place of a crest; narrow amber eyes.
- Torso: a lean, wedge-shaped chest, broad at the shoulders and narrow at the hips, flint grey with tan patches.
- Arms: long forearms, each ending in a broad, leaf-shaped blade of faceted black flint instead of a hand (the low-poly facets show the knapping).
- Legs: lean, bent legs with three splayed toes.
- Tail: a short, flat tail shaped like a chipped arrowhead.

**Spirecap**: a swaying sentinel shaped like the canyon's rock spires, with a flat capstone balanced on its head.
- Head: a small head under a wide, flat, overhanging capstone slab, two glowing yellow eyes in its shade.
- Torso: a tall, tapering column of banded rock in rust, cream and red stripes, thickest at the base.
- Arms: short, thick stone arms with round knuckled fists.
- Legs: very short, wide legs like the foot of a pillar, with flat round feet.
- Tail: a stubby wedge of rock that props it up when it stands still.

**Thatchling**: a shaggy desert sentinel wrapped in a skirt of its own dead leaves, whose crooked arms end in spiky green pompoms.
- Head: a small round head crowned with a tight rosette of stiff green blades, two dark eyes peering out from the thatch.
- Torso: a stout, upright trunk wrapped in a shaggy skirt of dry, downward-hanging straw-coloured leaves (stacked low-poly fringe layers).
- Arms: two crooked, branching arms, each ending in a round pompom of stiff, spiky green leaves.
- Legs: short, sturdy legs of fibrous bark ending in splayed root toes.
- Tail: a short tuft of dry leaves that drags in the sand.

**Whirlgrit**: a spinning little desert dancer that whirls on the spot until the sand around it lifts into a ring.
- Head: a round head under a wide, flat stone brim like a hat, two big goggle eyes behind a band of darker stripes.
- Torso: a short body tapered like a spinning top, with a loose ring of packed sand floating just off its waist (one solid part).
- Arms: thin arms ending in flat, fan-shaped hands of three fused fingers, held out for balance.
- Legs: short, quick, bent legs with two-toed gripping feet.
- Tail: a short corkscrew tail of twisted sandstone.

**Sizes.** Weights run 64 (Cairnback) to 40 (Duneskit) on four legs and 64 (Spirecap) to 36 (Whirlgrit) on two. Socket and plug radii follow Greenwood's rule (a base size per slot times the cube root of the weight, plug equal to its own species' socket), so every part fits every torso on its plan across both biomes inside the assembler's 0.6 to 1.6 range (the test checks this). Lengths and radii are planning values until the meshes exist.

## Stats

Budget score = Hp x 0.6 + Attack + Defence + Speed at quality 5. Every species scores 200 or 201, the plan budget. Level 25 is the Dust Canyon cap (15 plus 10 for the first badge); level 50 is ranked. Both are a pure creature at quality 5.

Every species uses the same split of its totals across its parts (head 60% of Attack; torso 78% of Hp and 45% of Defence; front limbs 32% of Attack and 25% of Defence; legs 66% of Speed; tail 20% of Defence; small shares elsewhere). So a part's role is the same in every species and hybrids reshape stats rather than stack them; species differ in their totals, their weight and their moves.

| Species | Base Hp / Atk / Def / Spd | Budget score | Level 25 | Level 50 | Weight |
| --- | --- | --- | --- | --- | --- |
| Cairnback | 130 / 47 / 40 / 36 | 201 | 286 / 103 / 88 / 79 | 448 / 162 / 138 / 124 | 64 |
| Duneskit | 120 / 39 / 31 / 59 | 201 | 264 / 85 / 68 / 129 | 414 / 134 / 106 / 203 | 40 |
| Spurlet | 130 / 48 / 30 / 44 | 200 | 286 / 105 / 66 / 96 | 448 / 165 / 103 / 151 | 46 |
| Wadibuck | 130 / 45 / 21 / 56 | 200 | 286 / 99 / 46 / 123 | 448 / 155 / 72 / 193 | 44 |
| Flintknap | 145 / 53 / 23 / 37 | 200 | 319 / 116 / 50 / 81 | 500 / 182 / 79 / 127 | 46 |
| Spirecap | 140 / 37 / 34 / 45 | 200 | 308 / 81 / 74 / 99 | 483 / 127 / 117 / 155 | 64 |
| Thatchling | 135 / 41 / 36 / 42 | 200 | 297 / 90 / 79 / 92 | 465 / 141 / 124 / 144 | 46 |
| Whirlgrit | 135 / 42 / 19 / 58 | 200 | 297 / 92 / 41 / 127 | 465 / 144 / 65 / 200 | 36 |

**Cairnback** (Quad, Sand)

| Part | Stats | Moves |
| --- | --- | --- |
| Head | Hp 5, Atk 29, Def 4, Spd 4 | Capstone Crash (L1), Talus Tumble (L20) |
| Torso | Hp 101, Atk 2, Def 18, Spd 2 | Mesa Slam (L1), Tumbleweed Toss (L16) |
| Front limbs | Hp 10, Atk 15, Def 10, Spd 5 | Pebble Pelt (L1) |
| Legs | Hp 7, Spd 24 | Hoof Scuff (L1) |
| Tail | Hp 7, Atk 1, Def 8, Spd 1 | Pebble Pelt (L1) |

Default four moves at level 25: Mesa Slam, Capstone Crash, Talus Tumble, Tumbleweed Toss

**Duneskit** (Quad, Sand)

| Part | Stats | Moves |
| --- | --- | --- |
| Head | Hp 5, Atk 24, Def 3, Spd 7 | Sand Flick (L1), Grit Whirl (L18) |
| Torso | Hp 93, Atk 2, Def 14, Spd 3 | Dune Dash (L1), Tumbleweed Toss (L14) |
| Front limbs | Hp 10, Atk 12, Def 8, Spd 8 | Pebble Pelt (L1) |
| Legs | Hp 6, Spd 39 | Dune Dash (L1) |
| Tail | Hp 6, Atk 1, Def 6, Spd 2 | Sand Flick (L1) |

Default four moves at level 25: Dune Dash, Grit Whirl, Tumbleweed Toss, Pebble Pelt

**Spurlet** (Quad, Leaf)

| Part | Stats | Moves |
| --- | --- | --- |
| Head | Hp 5, Atk 30, Def 3, Spd 5 | Spine Jab (L1), Agave Lance (L18) |
| Torso | Hp 101, Atk 2, Def 13, Spd 2 | Needle Fan (L1), Dust Squall (L14) |
| Front limbs | Hp 10, Atk 15, Def 8, Spd 6 | Spine Jab (L1) |
| Legs | Hp 7, Spd 29 | Hoof Scuff (L1) |
| Tail | Hp 7, Atk 1, Def 6, Spd 2 | Needle Fan (L1) |

Default four moves at level 25: Agave Lance, Needle Fan, Dust Squall, Spine Jab

**Wadibuck** (Quad, Water)

| Part | Stats | Moves |
| --- | --- | --- |
| Head | Hp 5, Atk 28, Def 2, Spd 7 | Oasis Spout (L1), Flash Flood (L20) |
| Torso | Hp 101, Atk 2, Def 10, Spd 3 | Wadi Rush (L1) |
| Front limbs | Hp 10, Atk 14, Def 5, Spd 7 | Fog Drip (L1) |
| Legs | Hp 7, Spd 37 | Hoof Scuff (L1) |
| Tail | Hp 7, Atk 1, Def 4, Spd 2 | Fog Drip (L1) |

Default four moves at level 25: Wadi Rush, Flash Flood, Oasis Spout, Fog Drip

**Flintknap** (Biped, Sand)

| Part | Stats | Moves |
| --- | --- | --- |
| Head | Hp 6, Atk 31, Def 2, Spd 4 | Knap Edge (L1), Grit Whirl (L18) |
| Torso | Hp 113, Atk 3, Def 10, Spd 2 | Flint Cleave (L1) |
| Front limbs | Hp 12, Atk 17, Def 6, Spd 5 | Knap Edge (L1) |
| Legs | Hp 7, Spd 25 | Dune Dash (L1) |
| Tail | Hp 7, Atk 2, Def 5, Spd 1 | Pebble Pelt (L1) |

Default four moves at level 25: Dune Dash, Grit Whirl, Flint Cleave, Pebble Pelt

**Spirecap** (Biped, Sand)

| Part | Stats | Moves |
| --- | --- | --- |
| Head | Hp 6, Atk 22, Def 3, Spd 5 | Capstone Crash (L1), Spire Topple (L22) |
| Torso | Hp 109, Atk 2, Def 15, Spd 2 | Mesa Slam (L1) |
| Front limbs | Hp 11, Atk 12, Def 9, Spd 6 | Pebble Pelt (L1) |
| Legs | Hp 7, Spd 30 | Grit Step (L1) |
| Tail | Hp 7, Atk 1, Def 7, Spd 2 | Pebble Pelt (L1) |

Default four moves at level 25: Mesa Slam, Capstone Crash, Spire Topple, Grit Step

**Thatchling** (Biped, Leaf)

| Part | Stats | Moves |
| --- | --- | --- |
| Head | Hp 5, Atk 25, Def 4, Spd 5 | Spine Jab (L1), Agave Lance (L18) |
| Torso | Hp 105, Atk 2, Def 16, Spd 2 | Needle Fan (L1), Dust Squall (L14) |
| Front limbs | Hp 11, Atk 13, Def 9, Spd 5 | Spine Jab (L1) |
| Legs | Hp 7, Spd 28 | Grit Step (L1) |
| Tail | Hp 7, Atk 1, Def 7, Spd 2 | Needle Fan (L1) |

Default four moves at level 25: Agave Lance, Needle Fan, Dust Squall, Spine Jab

**Whirlgrit** (Biped, Sand)

| Part | Stats | Moves |
| --- | --- | --- |
| Head | Hp 5, Atk 26, Def 2, Spd 7 | Sand Flick (L1), Grit Whirl (L17) |
| Torso | Hp 105, Atk 2, Def 8, Spd 3 | Dune Dash (L1) |
| Front limbs | Hp 11, Atk 13, Def 5, Spd 8 | Pebble Pelt (L1) |
| Legs | Hp 7, Spd 38 | Dune Dash (L1) |
| Tail | Hp 7, Atk 1, Def 4, Spd 2 | Sand Flick (L1) |

Default four moves at level 25: Dune Dash, Grit Whirl, Pebble Pelt, Sand Flick

## Moves

21 new moves: 12 Sand, 4 Water, 4 Leaf, 1 Storm. Power 40 to 65. Still no status effects (they arrive with the Mire). Every part's first move is known from level 1; second moves unlock at 14 to 22, so a creature's set keeps growing through the Dust Canyon levels. No existing move was changed.

| Move | Type | Power | Brought by |
| --- | --- | --- | --- |
| Knap Edge | Sand | 40 | Flintknap head L1; Flintknap front limbs L1 |
| Sand Flick | Sand | 40 | Duneskit head L1; Duneskit tail L1; Whirlgrit head L1; Whirlgrit tail L1 |
| Flint Cleave | Sand | 45 | Flintknap torso L1 |
| Grit Step | Sand | 45 | Spirecap legs L1; Thatchling legs L1 |
| Hoof Scuff | Sand | 45 | Cairnback legs L1; Spurlet legs L1; Wadibuck legs L1 |
| Pebble Pelt | Sand | 45 | Cairnback front limbs L1; Cairnback tail L1; Duneskit front limbs L1; Flintknap tail L1; Spirecap front limbs L1; Spirecap tail L1; Whirlgrit front limbs L1 |
| Capstone Crash | Sand | 50 | Cairnback head L1; Spirecap head L1 |
| Spire Topple | Sand | 50 | Spirecap head L22 |
| Talus Tumble | Sand | 50 | Cairnback head L20 |
| Dune Dash | Sand | 55 | Duneskit torso L1; Duneskit legs L1; Flintknap legs L1; Whirlgrit torso L1; Whirlgrit legs L1 |
| Grit Whirl | Sand | 55 | Duneskit head L18; Flintknap head L18; Whirlgrit head L17 |
| Mesa Slam | Sand | 60 | Cairnback torso L1; Spirecap torso L1 |
| Fog Drip | Water | 40 | Wadibuck front limbs L1; Wadibuck tail L1 |
| Flash Flood | Water | 50 | Wadibuck head L20 |
| Oasis Spout | Water | 50 | Wadibuck head L1 |
| Wadi Rush | Water | 55 | Wadibuck torso L1 |
| Spine Jab | Leaf | 45 | Spurlet head L1; Spurlet front limbs L1; Thatchling head L1; Thatchling front limbs L1 |
| Agave Lance | Leaf | 55 | Spurlet head L18; Thatchling head L18 |
| Needle Fan | Leaf | 55 | Spurlet torso L1; Spurlet tail L1; Thatchling torso L1; Thatchling tail L1 |
| Tumbleweed Toss | Leaf | 55 | Cairnback torso L16; Duneskit torso L14 |
| Dust Squall | Storm | 65 | Spurlet torso L14; Thatchling torso L14 |

Where coverage sits, and why:
- **Anti-Water coverage on Sand torsos only** (Tumbleweed Toss, Leaf, on Cairnback and Duneskit), so the four-legged Sand species can answer Wadibuck, but a Water hybrid cannot borrow it for Water mirrors. The two-legged Sand torsos carry none: there is no Water biped in Dust Canyon, and in the mixed pool that coverage made Sand torsos beat Splashjack as well as every Leaf, which pushed the best builds higher.
- **Anti-Sand coverage on Leaf torsos only** (Dust Squall, Storm, on Spurlet and Thatchling), the role Silt Surge plays for Splashjack in Greenwood: the lone Leaf on each plan can fight its Sand neighbours, and no Sand hybrid can take Dust Squall into a Sand mirror.
- **No anti-Leaf move on Wadibuck's torso.** An earlier draft gave it one (a Sand move, like Sloshcalf's Mud Slap); in the mixed pool a Water torso that also beats Leaf topped the table, and removing it lowered the mixed best build by about 9 points while the Dust Canyon pool still passed.
- **Strong moves stay off limbs where a borrower could misuse them.** Limb moves are 40 to 55 power, so another torso's own-type moves (x1.2) usually outrank them in the default four; the 55 to 65 moves sit on torsos, where they always come with the torso's type.
- **Power runs 40 to 65, not up to 80.** Every search that let late moves climb to 70 or 80 made one part (usually a head) the best in every build. Damage already grows with the attacker's level, so higher power is not needed for pacing. The late unlocks are the progression instead: Tumbleweed Toss and Dust Squall at 14 to 16, Grit Whirl and Agave Lance at 17 to 18, Talus Tumble and Flash Flood at 20, Spire Topple at 22.

## Balance gate: measured results

Method as in Greenwood: every combination of parts on a plan at quality 5; a fixed field (every pure species, the five best builds by each stat and by total, then a random sample with seed 2026); every pair fights twice with sides swapped (ranked rules, no variance, the default move choice and opponent); draws count half. Dust Canyon alone: 1,024 builds per plan, field 160. Both biomes: eight species per plan, 32,768 builds, field 200. Builds are head/torso/front limbs/legs/tail.

**Dust Canyon alone: passes every mark.**

| | Best build | Pure species | Top ten torsos / leg sets |
| --- | --- | --- | --- |
| Four-legged, level 25 | 69% Duneskit/Spurlet/Duneskit/Duneskit/Cairnback | Cairnback 53, Spurlet 49, Duneskit 48, Wadibuck 44 | 2 / 2 |
| Four-legged, level 50 | 69% Duneskit/Spurlet/Duneskit/Duneskit/Cairnback | Cairnback 53, Duneskit 49, Spurlet 48, Wadibuck 44 | 2 / 2 |
| Two-legged, level 25 | 65% Whirlgrit/Whirlgrit/Thatchling/Whirlgrit/Spirecap | Spirecap 59, Flintknap 49, Thatchling 48, Whirlgrit 44 | 4 / 2 |
| Two-legged, level 50 | 64% Whirlgrit/Whirlgrit/Thatchling/Whirlgrit/Spirecap | Spirecap 61, Thatchling 48, Flintknap 48, Whirlgrit 44 | 3 / 2 |

On two other fields of 160 (seeds 77 and 5, scratch runs): best build 64 to 70%, lowest pure species 44 to 47%, both plans, both levels. The mixed pool on those fields: best 78 to 91%, lowest pure 20 to 35% (Stumpwarden 20% on seed 5).

**Both biomes mixed: two marks pass, two miss.**

| | Best build | Lowest pure | Top ten torsos / leg sets | Head to head |
| --- | --- | --- | --- | --- |
| Four-legged, level 25 | **79%** Burlhorn/Sloshcalf/Cairnback/Spadesnout/Gorsling | **34%** Gorsling | 4 / 4 | pass |
| Four-legged, level 50 | **78%** Sloshcalf/Cairnback/Gorsling/Wadibuck/Gorsling | **35%** Wadibuck | 4 / 4 | pass |
| Two-legged, level 25 | **84%** Splashjack/Flintknap/Thatchling/Flintknap/Splashjack | **26%** Stiltbark | 3 / 7 | pass |
| Two-legged, level 50 | **84%** Splashjack/Spirecap/Mossmitt/Stumpwarden/Stumpwarden | **26%** Stiltbark | 2 / 6 | pass |

Pure species side by side in the mixed pool (level 25; level 50 is within 2 points):

| Four-legged | Win rate | | Two-legged | Win rate |
| --- | --- | --- | --- | --- |
| Sloshcalf (Greenwood) | 68% | | Splashjack (Greenwood) | 69% |
| Spadesnout (Greenwood) | 62% | | Spirecap (Dust Canyon) | 65% |
| Cairnback (Dust Canyon) | 58% | | Flintknap (Dust Canyon) | 57% |
| Duneskit (Dust Canyon) | 52% | | Whirlgrit (Dust Canyon) | 56% |
| Spurlet (Dust Canyon) | 49% | | Thatchling (Dust Canyon) | 46% |
| Burlhorn (Greenwood) | 39% | | Mossmitt (Greenwood) | 40% |
| Wadibuck (Dust Canyon) | 36% | | Stumpwarden (Greenwood) | 29% |
| Gorsling (Greenwood) | 34% | | Stiltbark (Greenwood) | 26% |
| Mean: Greenwood 51, Dust Canyon 49 | | | Mean: Greenwood 41, Dust Canyon 56 | |

- **Neither biome is strictly better.** The test counts it as "strictly better" if a pure species beats every pure species of the other biome head to head (more than half the points in their two fights). No species does, on either plan, at either level: the type triangle always leaves each one a loss. Read literally ("a higher win rate than every one"), the mark cannot be met by any roster, because the top pure species is always above every species of the other biome; the means are given instead. On four legs the two biomes are level; on two legs Dust Canyon is ahead by 15 points, because Greenwood's two-legged half has no Sand and its Leaf species meet Sand for the first time.
- In the test, the two missed marks print as NOTE and do not fail the run; every other mark (68 checks, including all of Greenwood's) is a hard PASS.

**Battle length.** 3v3 between random wild teams (400 battles, wild qualities 3 to 7): Dust Canyon 10.4 turns at level 25 (7 to 13) and 10.4 at level 50 (8 to 13); both biomes 10.1 at 25 and 50. Pass. Greenwood is unchanged (11.8, 10.2 and 10.1 at levels 5, 15 and 50).

## Known gaps: the mixed pool

**Why it misses.** Measured win rates by the type of the opponent's torso show the cause. A Greenwood Leaf pure species wins **0%** against Sand-torso builds: its default four moves are all Leaf (Stumpwarden has no other move at all; Gale Hop, Puddle Stomp and Brook Rush are outranked by stronger Leaf moves), and Sand hits Leaf at 1.8 times (strong and own-type) while Leaf hits Sand at 0.8. In the mixed pool three of the eight torsos on each plan are Sand, so such a species can win at most about 62% of its fights even if it beat everything else, and in practice it lands at 26 to 39%. Greenwood's own two-legged pool has no Sand at all, which is why Stiltbark and Stumpwarden fall furthest. The over-75% builds are cross-biome mixes that collect coverage from both rosters: a Sand torso with Splashjack's head (Ripple Ram, Water 70, so it also beats Sand) and Greenwood arms, or a Water torso with Sand and Leaf limbs. Wadibuck is low (35%) for the mirror reason: four Leaf torsos now beat it.

**What was tried on private copies outside the repository** (same Dust Canyon roster, same field):

| Change | Mixed best build | Mixed lowest pure | Dust Canyon alone |
| --- | --- | --- | --- |
| None (this roster) | 78 to 84% | 26 to 35% | passes |
| Softer type chart: strong x1.3, weak x0.77 (was 1.5, 0.67; `src/shared/TypeChart.luau`) | 83 to 87% | 32% (Wadibuck, Stiltbark) | best 74 to 75%, Whirlgrit 37%: fails |
| Default move choice keeps one slot for the best move against a type that beats the creature (`Battle.bestMoves`) | 78 to 84% | 30% (Stiltbark) | passes |
| That, plus Stumpwarden's tail brings Brook Rush instead of Fern Whip (a Greenwood change) | 78 to 84% | 30% (Stiltbark) | passes |
| Earlier rosters with a Water biped instead of Thatchling, or Leaf coverage on Sand biped torsos | 84 to 93% | 17 to 31% | failed or barely passed |

No config number reaches the type multipliers or move choice, so no change inside `src/config/` can close this, and none of the code or Greenwood changes above closes it either. The coverage rule is the most useful of them (Burlhorn, Gorsling and Wadibuck rise to 39 to 42%) but leaves the two-legged pool and the best builds where they were.

**What would close it**, in order of size:
1. **Re-tune Greenwood's two-legged half with the mixed pool in the gate** (for example an anti-Sand move Stumpwarden and Stiltbark actually choose, and Ripple Ram off Splashjack's head or lower). This is the change most likely to work, but it reopens the first roster and the giant tuning, so it needs a go-ahead.
2. **Adopt the coverage-slot move choice** for tamers and the gate (it is closer to how a player picks moves) together with step 1.
3. **Judge the mixed pool by a different mark.** Leaf creatures struggling in a Sand biome is the type chart doing its job, and a player arriving in Dust Canyon is meant to want Water and Sand creatures there. A mark such as "every pure species at least 40% in its own biome, and at least 30% mixed", with the 75% cap kept, would pass today on four legs and miss only Stiltbark and Stumpwarden (26 to 29%) on two.

## How the roster was designed

1. **Type mix first.** "Mostly Sand" means at least five Sand species, so one plan carries three. Greenwood's four-legged half already has a Sand species and its two-legged half has none, so the mix is Sand, Sand, Leaf, Water on four legs (a full triangle, like Greenwood's four-legged plan) and three Sand with one Leaf on two legs. The lone-underdog shape on two legs (three Sand and a Leaf that carries anti-Sand coverage) mirrors Greenwood's solved Leaf-and-Splashjack plan. The alternative, a lone Water biped among three Sand, never balanced: either the Water torso or a Sand torso carrying Leaf coverage against it took its own pool to 79 to 97%.
2. **One stat template for every species** (above). Free per-part tuning produced odd parts (legs with Defence, heads with Speed) that hybrids then exploited.
3. **Then a seeded hill-climbing search** on each species' four totals, weights and the powers of moves only one plan uses, against the Dust Canyon gate on three fields at once, followed by a pass with the mixed pool in the objective. Lessons: very fast and very fragile loses (Speed 62 to 64 with Defence 22 to 25 won 11 to 18% of its fights; the sprinters ended at Speed 58 to 59 with more Hp); Speed is worth most on legs that go onto light torsos; Water torsos that also beat Leaf, and Sand torsos that also beat Water, are what break a mixed pool.

## Open questions for Ayrton

1. **The mixed-pool marks** (above): accept the gap for now, re-tune Greenwood's bipeds with the mixed pool in the gate, or change the mark?
2. **Type mix.** Five Sand, two Leaf and one Water, with no Water biped. Happy with that, or would you rather have a Water biped and accept a weaker two-legged balance?
3. **No Storm or Toxic species** yet; Storm only as one teaser move on the Leaf torsos. Agree?
4. **Uncommons**: Cairnback and Spirecap, both two-zone lasso catches at 1.7 and 1.8. Too big a step?
5. **Move power** tops out at 65 (the brief range suggested up to 80); higher power broke the balance. Fine?
6. **Shared moves**: Spurlet and Thatchling bring the same four Leaf and Storm moves, and several Sand moves are shared. Worth giving each its own signature move once the battle AI lands?
7. **Names**: all eight species names and 21 move names are placeholders I believe are original (Thatchling and Wadibuck especially should be checked against other games before art is commissioned).
8. **Untested here**: quality pips other than 5, the size gene, Gem-tier (+5%) individuals in the pools, smarter move choice, and every build against the field (only the fixed fields above). Retest when the art gives real weights and after the battle AI lands.
