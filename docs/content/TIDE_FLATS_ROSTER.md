# Tide Flats roster

The third roster: the eight species of Tide Flats (biome 3, Water), their parts and moves, and the balance gate they pass alone and mixed with Greenwood and Dust Canyon. Data lives in `src/content/species_data/`, `src/content/Moves.luau` and `src/content/Species.luau`; the gate is `tests/roster.test.luau` (about 22 seconds for all three biomes). It follows the method of `GREENWOOD_ROSTER.md` and `DUST_CANYON_ROSTER.md`. No config number, no shared code and no earlier species was changed. Everything here is a [Default] the owner can change.

## At a glance

| Species | Plan | Type | Rarity | Role | Lasso |
| --- | --- | --- | --- | --- | --- |
| Hullock | Four-legged | Water | Uncommon | Bruiser: the most Defence in Tide Flats, the slowest on four legs | 1.9 |
| Glissot | Four-legged | Water | Common | Sprinter: the fastest on four legs | 1.45 |
| Gulpmaw | Four-legged | Water | Common | Striker: the most Attack on four legs | 1.4 |
| Cocklemole | Four-legged | Sand | Common | All-rounder: the lone Sand on four legs, with a Toxic move on its torso | 1.4 |
| Lanternell | Two-legged | Water | Uncommon | Sturdy all-rounder: the most Defence on two legs | 2.0 |
| Clapshell | Two-legged | Water | Common | Bruiser: the most Attack in Tide Flats, thin Defence | 1.4 |
| Runnelfin | Two-legged | Water | Common | Sprinter: the fastest on two legs, the thinnest Defence | 1.45 |
| Moatkeep | Two-legged | Sand | Common | Sturdy all-rounder: the lone Sand on two legs, the most Hp and the slowest, with a Toxic move on its torso | 1.4 |

- **Six Water, two Sand.** Four species on each body plan, each plan three Water and one Sand. Six Common, two Uncommon (Hullock, Lanternell). A team can mix Water and Sand from the first route, and with creatures brought from the earlier biomes it is never forced to be mono-type.
- **The shape is Dust Canyon's two-legged plan, used twice.** Three of the biome's type plus one underdog the majority beats, and the underdog carries a torso-only move that beats the majority back (Dust Squall on Thatchling there; Red Tide here). Every other shape tried failed alone (see "How the roster was designed").
- **Tide Flats favours Defence for breeding.** Its torsos are shells: they carry 55% of a species' Defence (the earlier rosters' torsos carry about 45%), so Tide Flats torsos average 19.9 Defence at quality 5 against 13.2 in Greenwood and 13.0 in Dust Canyon (Hullock 25, Lanternell 24). Dust Canyon's legs are the Speed parts; Tide Flats' torsos are the Defence parts. The test checks this. Because the torso also sets the type, a breeder who wants a tougher creature takes a Water or Sand type with it, so the gain is a choice rather than free.
- **Gem tier ("Amber", `Gem` in code)**: as in Dust Canyon, any of the eight can spawn wild as a Gem individual; nothing in the species data changes.
- **Lasso difficulty a step above Dust Canyon's.** Commons 1.4, the two skittish sprinters 1.45 (Dust Canyon commons 1.2 to 1.3); uncommons 1.9 and 2.0 (Dust Canyon 1.7 and 1.8). Both uncommons are two-zone catches; neither reaches the three-zone 2.5.
- **No Leaf species.** One Leaf among three Water is the overdog, not the underdog: it beat the three Water species on type alone (85% as a pure species in the first draft) and every Water torso would then need a Sand move, which is exactly the "Water torso that also beats Leaf" that broke the Dust Canyon mixed pool. Players arriving with Greenwood's Leaf creatures have the type edge here, which is the type chart doing its job.
- **Toxic teaser: Red Tide** (Toxic 65, torso, level 24) on the two Sand torsos only. Toxic beats Water, so it is the Sand species' answer to the Water majority; no Water torso can take it into a Water mirror. Toxic is weak to Sand, so a Sand mirror does not want it either.

## The species and how they look

Art direction for every part: chunky low-poly, flat colours, every joint ends in a rounded ball that sits in the torso socket. Silhouettes are kept apart from the 18 earlier species (no stilts, no back-ponds, no boxing mitts, no stone stacks or rock columns, no big paddle feet): a barnacle hull, a fluke-tailed skimmer, an all-mouth ambusher, a cockle-shell helmet, a glowing jelly dome on a lighthouse body, scallop-shell hands, a sail fin crest and a crenellated sandcastle turret. Each species file carries the same descriptions as comments.

**Hullock**: a slow, broad shore ox whose back has crusted over like the hull of an old boat, barnacles and all.
- Head: a wide, low head with a blunt, rounded snout like a boat's prow, two short horns ridged like whelk shells curving forward, and small deep-set eyes.
- Torso: a long, heavy, keel-shaped body; its back is a crust of grey barnacle cones and flat limpet plates over weathered blue-green hide.
- Front legs: thick, stubby forelegs ringed with mussel-blue bands, ending in wide round hooves like mooring posts.
- Hind legs: short, heavy hind legs with broad flat feet for wet sand.
- Tail: a short, thick tail ending in a flat, upright fin shaped like a boat's rudder.

**Glissot**: a sleek tide-line runner that skims across the wet sand faster than the waves can follow.
- Head: a small, smooth, bullet-shaped head with a pointed snout, long whiskers of thin foam-white rods and two big glossy eyes set far back.
- Torso: a long, slim, low-slung body tapered at both ends, silver-blue above and pale below, with a thin dark wet-line along each side.
- Front legs: short, slim forelegs with wide webbed toes.
- Hind legs: long, bent hind legs with broad webbed feet that slap the water flat.
- Tail: a long, flat tail that widens into a two-lobed fluke.

**Gulpmaw**: a rock-pool ambusher that waits half buried in the weed with its enormous mouth wide open.
- Head: a huge, wide, flat head that is mostly mouth, its jaw lined with a row of blunt pebble teeth, two small eyes on short stalks on top.
- Torso: a squat, toad-like body mottled rust and olive like rock-pool weed, with a frill of ragged skin along each side.
- Front legs: short, splayed forelegs with knobbly elbows and round sucker-tipped toes for gripping wet rock.
- Hind legs: thick, crouched hind legs folded like springs for a sudden lunge.
- Tail: a short, broad paddle tail with a ragged, weed-like edge.

**Cocklemole**: a beach burrower that wears a ribbed cockle shell as a helmet and digs faster than the tide can fill its holes.
- Head: a blunt, whiskered head under a big ribbed, fan-shaped cockle shell worn like a helmet, with a pink star-shaped nose.
- Torso: a round, compact body of packed damp sand with a band of broken shell pieces around the middle.
- Front legs: short, wide forelegs with huge flat scoop claws.
- Hind legs: short, stout hind legs with flat paddle feet that kick sand out behind.
- Tail: a short, stiff tail tipped with a little coiled cast of sand.

**Lanternell**: a tall, slow-swaying rock-pool keeper whose lantern head glows at night to guide lost creatures back to the water.
- Head: a round, clear, jelly-like dome with a soft glowing core (one solid translucent part, no physics) and a short fringe of frilly tendrils around its rim.
- Torso: a tall barrel body of stacked pale shell rings like a lighthouse, banded white and sea-green.
- Arms: long, slender arms ending in soft, anemone-like fans of short rounded fingers.
- Legs: short, stumpy legs with round suction-cup feet.
- Tail: a long, trailing ribbon of frilled tendrils.

**Clapshell**: a hulking beach brawler whose hands are two great scallop shells that clap shut like a trap.
- Head: a small, blunt head sunk between hunched shoulders, two eyes on short stalks and a jutting lower jaw.
- Torso: a broad, top-heavy chest covered in overlapping orange and cream scallop plates, narrow at the waist.
- Arms: thick arms that end in two huge ribbed scallop shells instead of hands, which open and snap shut.
- Legs: short, bowed legs with wide three-toed feet.
- Tail: a stubby, segmented tail like a shrimp's, curled under.

**Runnelfin**: a quick, lanky shore dancer that sprints along the runnels the tide leaves behind, its fin crest flicking water as it goes.
- Head: a narrow, fish-like head with a tall, sail-like fin crest running from brow to nape, and wide-set round eyes.
- Torso: a slim, upright, streamlined body in bright turquoise with silver scale bands.
- Arms: short, thin arms ending in small fin-shaped hands.
- Legs: lean, quick legs with narrow, pointed fin-feet like arrowheads that cut through shallow water.
- Tail: a long, forked fish tail held straight out behind for balance.

**Moatkeep**: a squat little sandcastle come to life, which rebuilds its walls every time the tide knocks them down.
- Head: a square head shaped like a castle turret, crenellated along the top, with two dark window-slit eyes and a small shell stuck on top like a flag.
- Torso: a blocky body of packed wet sand with bucket-mould ridges and a ring of darker wet sand around its middle like a moat (one solid part).
- Arms: short, thick, square arms of packed sand ending in flat, paddle-like hands for patting walls smooth.
- Legs: short, heavy, round legs like little castle towers.
- Tail: a short, flat slab of sand like a lowered drawbridge.

**Sizes.** Weights run 66 (Hullock) to 45 (Glissot) on four legs and 66 (Lanternell) to 38 (Runnelfin) on two. Socket and plug radii follow the earlier rule (a base size per slot times the cube root of the weight, plug equal to its own species' socket), so every part fits every torso on its plan across all three biomes inside the assembler's 0.6 to 1.6 range (the test checks this). Lengths and radii are planning values until the meshes exist.

## Stats

Budget score = Hp x 0.6 + Attack + Defence + Speed at quality 5. Every species scores 200, the plan budget. Level 35 is the Tide Flats cap (15 plus 10 for each of the first two badges); level 50 is ranked. Both are a pure creature at quality 5.

Every species uses the same split of its totals across its parts: head 61% of Attack; torso 77.5% of Hp and **55% of Defence**; front limbs 32% of Attack and 20% of Defence; legs 67% of Speed; tail 17% of Defence; small shares elsewhere. It is Dust Canyon's template with ten points of the Defence share moved from limbs and tail onto the torso.

| Species | Base Hp / Atk / Def / Spd | Budget score | Level 35 | Level 50 | Weight |
| --- | --- | --- | --- | --- | --- |
| Hullock | 127 / 42 / 46 / 36 | 200 | 342 / 113 / 124 / 97 | 438 / 144 / 158 / 124 | 66 |
| Glissot | 121 / 41 / 32 / 54 | 200 | 326 / 110 / 86 / 145 | 417 / 141 / 110 / 186 | 45 |
| Gulpmaw | 125 / 48 / 35 / 42 | 200 | 337 / 129 / 94 / 113 | 431 / 165 / 120 / 144 | 64 |
| Cocklemole | 128 / 43 / 36 / 44 | 200 | 345 / 116 / 97 / 118 | 441 / 148 / 124 / 151 | 60 |
| Lanternell | 138 / 35 / 42 / 40 | 200 | 372 / 94 / 113 / 108 | 476 / 120 / 144 / 138 | 66 |
| Clapshell | 136 / 51 / 31 / 36 | 200 | 367 / 137 / 83 / 97 | 469 / 175 / 106 / 124 | 55 |
| Runnelfin | 132 / 43 / 26 / 52 | 200 | 356 / 116 / 70 / 140 | 455 / 148 / 89 / 179 | 38 |
| Moatkeep | 140 / 47 / 36 / 33 | 200 | 378 / 126 / 97 / 89 | 483 / 162 / 124 / 113 | 60 |

Per-slot budgets: head 33 to 41, torso 79 to 92, front limbs 31 to 34, legs 26 to 40, tail 11 to 14. The torsos are 5 to 9 points heavier than the earlier rosters' (71 to 83) because they hold the Defence; the hybrid budget cap (1.15) still bounds any mix, and `breeding.test` passes.

**Hullock** (Quad, Water)

| Part | Stats | Moves |
| --- | --- | --- |
| Head | Hp 5, Atk 26, Def 4, Spd 4 | Barnacle Butt (L1), Breaker Charge (L28) |
| Torso | Hp 98, Atk 2, Def 25, Spd 2 | Riptide Rush (L1) |
| Front limbs | Hp 10, Atk 13, Def 9, Spd 5 | Brine Jab (L1) |
| Legs | Hp 7, Spd 24 | Shoal Stomp (L1) |
| Tail | Hp 7, Atk 1, Def 8, Spd 1 | Foam Flick (L1) |

Default four moves at level 35: Breaker Charge, Barnacle Butt, Brine Jab, Riptide Rush

**Glissot** (Quad, Water)

| Part | Stats | Moves |
| --- | --- | --- |
| Head | Hp 5, Atk 25, Def 3, Spd 6 | Spray Jet (L1), Undertow (L26) |
| Torso | Hp 94, Atk 2, Def 18, Spd 3 | Skim Dash (L1) |
| Front limbs | Hp 10, Atk 13, Def 6, Spd 7 | Foam Flick (L1) |
| Legs | Hp 6, Spd 36 | Skim Dash (L1) |
| Tail | Hp 6, Atk 1, Def 5, Spd 2 | Foam Flick (L1) |

Default four moves at level 35: Undertow, Skim Dash, Spray Jet, Foam Flick

**Gulpmaw** (Quad, Water)

| Part | Stats | Moves |
| --- | --- | --- |
| Head | Hp 5, Atk 30, Def 3, Spd 5 | Maw Snap (L1), Undertow (L28) |
| Torso | Hp 96, Atk 2, Def 19, Spd 2 | Rockpool Lunge (L1) |
| Front limbs | Hp 10, Atk 15, Def 7, Spd 5 | Brine Jab (L1) |
| Legs | Hp 7, Spd 29 | Shoal Stomp (L1) |
| Tail | Hp 7, Atk 1, Def 6, Spd 1 | Foam Flick (L1) |

Default four moves at level 35: Undertow, Maw Snap, Brine Jab, Rockpool Lunge

**Cocklemole** (Quad, Sand)

| Part | Stats | Moves |
| --- | --- | --- |
| Head | Hp 5, Atk 26, Def 3, Spd 5 | Cockle Crack (L1), Shell Grind (L28) |
| Torso | Hp 99, Atk 2, Def 20, Spd 2 | Burrow Burst (L1), Red Tide (L24) |
| Front limbs | Hp 10, Atk 14, Def 7, Spd 6 | Sand Scoop (L1) |
| Legs | Hp 7, Spd 30 | Shoal Stomp (L1) |
| Tail | Hp 7, Atk 1, Def 6, Spd 1 | Sand Scoop (L1) |

Default four moves at level 35: Burrow Burst, Cockle Crack, Red Tide, Shell Grind

**Lanternell** (Biped, Water)

| Part | Stats | Moves |
| --- | --- | --- |
| Head | Hp 6, Atk 21, Def 3, Spd 5 | Lantern Pulse (L1), Breaker Charge (L30) |
| Torso | Hp 107, Atk 2, Def 24, Spd 2 | Tidepool Surge (L1) |
| Front limbs | Hp 11, Atk 11, Def 8, Spd 5 | Brine Jab (L1) |
| Legs | Hp 7, Spd 27 | Shoal Stomp (L1) |
| Tail | Hp 7, Atk 1, Def 7, Spd 1 | Foam Flick (L1) |

Default four moves at level 35: Breaker Charge, Lantern Pulse, Brine Jab, Shoal Stomp

**Clapshell** (Biped, Water)

| Part | Stats | Moves |
| --- | --- | --- |
| Head | Hp 5, Atk 32, Def 2, Spd 4 | Brine Jab (L1), Breaker Charge (L28) |
| Torso | Hp 106, Atk 2, Def 18, Spd 2 | Clamp Crush (L1) |
| Front limbs | Hp 11, Atk 16, Def 6, Spd 5 | Mussel Smack (L1) |
| Legs | Hp 7, Spd 24 | Shoal Stomp (L1) |
| Tail | Hp 7, Atk 1, Def 5, Spd 1 | Foam Flick (L1) |

Default four moves at level 35: Clamp Crush, Breaker Charge, Mussel Smack, Brine Jab

**Runnelfin** (Biped, Water)

| Part | Stats | Moves |
| --- | --- | --- |
| Head | Hp 5, Atk 26, Def 2, Spd 6 | Spray Jet (L1), Undertow (L26) |
| Torso | Hp 102, Atk 2, Def 15, Spd 3 | Skim Dash (L1) |
| Front limbs | Hp 11, Atk 14, Def 5, Spd 7 | Foam Flick (L1) |
| Legs | Hp 7, Spd 34 | Skim Dash (L1) |
| Tail | Hp 7, Atk 1, Def 4, Spd 2 | Foam Flick (L1) |

Default four moves at level 35: Undertow, Skim Dash, Spray Jet, Foam Flick

**Moatkeep** (Biped, Sand)

| Part | Stats | Moves |
| --- | --- | --- |
| Head | Hp 6, Atk 29, Def 3, Spd 4 | Cockle Crack (L1), Shell Grind (L28) |
| Torso | Hp 109, Atk 2, Def 20, Spd 2 | Rampart Slam (L1), Red Tide (L24) |
| Front limbs | Hp 11, Atk 15, Def 7, Spd 4 | Sand Scoop (L1) |
| Legs | Hp 7, Spd 22 | Shoal Stomp (L1) |
| Tail | Hp 7, Atk 1, Def 6, Spd 1 | Sand Scoop (L1) |

Default four moves at level 35: Cockle Crack, Red Tide, Rampart Slam, Shell Grind

## Moves

21 new moves: 15 Water, 5 Sand, 1 Toxic. Power 40 to 65. Still no status effects (they arrive with the Mire). Every part's first move is known from level 1; second moves unlock at 24 to 30, inside the Tide Flats levels (cap 35; the test allows a second move up to level 32). No existing move was changed.

| Move | Type | Power | Brought by |
| --- | --- | --- | --- |
| Foam Flick | Water | 40 | Clapshell tail L1; Glissot front limbs L1; Glissot tail L1; Gulpmaw tail L1; Hullock tail L1; Lanternell tail L1; Runnelfin front limbs L1; Runnelfin tail L1 |
| Brine Jab | Water | 45 | Clapshell head L1; Gulpmaw front limbs L1; Hullock front limbs L1; Lanternell front limbs L1 |
| Riptide Rush | Water | 45 | Hullock torso L1 |
| Rockpool Lunge | Water | 45 | Gulpmaw torso L1 |
| Shoal Stomp | Water | 45 | Clapshell legs L1; Cocklemole legs L1; Gulpmaw legs L1; Hullock legs L1; Lanternell legs L1; Moatkeep legs L1 |
| Skim Dash | Water | 45 | Glissot torso L1; Glissot legs L1; Runnelfin torso L1; Runnelfin legs L1 |
| Spray Jet | Water | 45 | Glissot head L1; Runnelfin head L1 |
| Tidepool Surge | Water | 45 | Lanternell torso L1 |
| Lantern Pulse | Water | 50 | Lanternell head L1 |
| Maw Snap | Water | 50 | Gulpmaw head L1 |
| Barnacle Butt | Water | 55 | Hullock head L1 |
| Mussel Smack | Water | 55 | Clapshell front limbs L1 |
| Breaker Charge | Water | 60 | Clapshell head L28; Hullock head L28; Lanternell head L30 |
| Undertow | Water | 60 | Glissot head L26; Gulpmaw head L28; Runnelfin head L26 |
| Clamp Crush | Water | 65 | Clapshell torso L1 |
| Sand Scoop | Sand | 45 | Cocklemole front limbs L1; Cocklemole tail L1; Moatkeep front limbs L1; Moatkeep tail L1 |
| Rampart Slam | Sand | 50 | Moatkeep torso L1 |
| Shell Grind | Sand | 50 | Cocklemole head L28; Moatkeep head L28 |
| Burrow Burst | Sand | 55 | Cocklemole torso L1 |
| Cockle Crack | Sand | 55 | Cocklemole head L1; Moatkeep head L1 |
| Red Tide | Toxic | 65 | Cocklemole torso L24; Moatkeep torso L24 |

Where coverage sits, and why:
- **Anti-Water coverage on Sand torsos only** (Red Tide, Toxic 65, from level 24, on Cocklemole and Moatkeep). It is what lets the lone Sand species on each plan fight three Water neighbours, and since Toxic is weak to Sand and the move is on a torso, no Water hybrid can carry it into a Water mirror. The test checks that Toxic moves come only on Sand torsos.
- **No coverage on Water torsos.** Water beats Sand and is neutral to Water, so the majority needs nothing more in its own biome; an anti-Leaf move on a Water torso is what pushed the Dust Canyon mixed pool over its marks.
- **Strong moves sit on torsos and late on heads.** Limb, leg and tail moves are 40 to 55; the 60 to 65 moves are torso moves (Clamp Crush, Red Tide) or head unlocks at 26 to 30 (Breaker Charge, Undertow). The search lowered four Water torso moves to 45 (Riptide Rush, Rockpool Lunge, Tidepool Surge, Skim Dash): with the extra torso Defence, a strong own-type torso move made those torsos the best part in every build.
- **Legs bring the biome's move.** Every non-sprinter's legs bring Shoal Stomp (Water 45), including the two Sand species', the way Dust Canyon's Leaf legs bring Hoof Scuff.

## Balance gate: measured results

Method as in the earlier rosters: every combination of parts on a plan at quality 5; a fixed field (every pure species, the five best builds by each stat and by total, then a random sample with seed 2026); every pair fights twice with sides swapped (ranked rules, no variance, the default move choice and opponent); draws count half. Tide Flats alone: 1,024 builds per plan, field 160. All three biomes: twelve species per plan, 248,832 builds, field 200. Builds are head/torso/front limbs/legs/tail.

**Tide Flats alone: passes every mark.**

| | Best build | Pure species | Top ten torsos / leg sets |
| --- | --- | --- | --- |
| Four-legged, level 35 | 65% Glissot/Glissot/Glissot/Glissot/Cocklemole | Gulpmaw 59, Glissot 54, Hullock 54, Cocklemole 50 | 2 / 3 |
| Four-legged, level 50 | 64% Gulpmaw/Glissot/Glissot/Glissot/Hullock | Gulpmaw 60, Glissot 54, Hullock 54, Cocklemole 50 | 2 / 3 |
| Two-legged, level 35 | 65% Clapshell/Clapshell/Clapshell/Clapshell/Lanternell | Clapshell 62, Lanternell 54, Runnelfin 54, Moatkeep 48 | 3 / 4 |
| Two-legged, level 50 | 68% Clapshell/Lanternell/Moatkeep/Lanternell/Lanternell | Clapshell 61, Lanternell 54, Runnelfin 54, Moatkeep 48 | 2 / 4 |

On three other fields of 160 (seeds 77, 5 and 9, scratch runs): best build 63 to 72%, lowest pure species 45 to 50%, both plans, both levels. The weakest spot is Clapshell's own build on seed 5 (69% pure, 72% best), still inside the mark.

**All three biomes mixed: better than the two-biome pool, still two marks noted.**

| | Best build | Lowest pure | Top ten torsos / leg sets | Head to head |
| --- | --- | --- | --- | --- |
| Four-legged, level 35 | **75%** (just over) Sloshcalf pure | 41% Wadibuck | 4 / 8 | pass |
| Four-legged, level 50 | **75%** (just over) Glissot/Cocklemole/Hullock/Spadesnout/Duneskit | 41% Wadibuck | 4 / 7 | pass |
| Two-legged, level 35 | **78%** Moatkeep/Thatchling/Spirecap/Whirlgrit/Mossmitt | **32%** Flintknap | 5 / 7 | pass |
| Two-legged, level 50 | **77%** Moatkeep/Thatchling/Spirecap/Whirlgrit/Mossmitt | **31%** Flintknap, Whirlgrit | 5 / 7 | pass |

Against the two-biome pool today (best 78 to 84%, lowest 26 to 35%), the three-biome pool is better on every line: the four-legged plan now meets the 40% floor and misses the 75% cap by a fraction of a point (it rounds to 75% but is above it), and the two-legged plan's best build drops from 84% to 77 to 78%. On two other fields (seeds 77 and 5, level 35): best 77 to 82%, lowest pure 29 to 41%. So the honest range is "best about 75 to 82%, lowest about 29 to 41%".

In the test, the 75% and 40% marks print as NOTE, exactly as for the two-biome pool, and two guard rails fail the run if the three-biome pool gets worse than measured: best build at most **80%** and lowest pure species at least **30%** on the fixed field. These are new thresholds for the new pool only; no existing threshold was changed.

Pure species side by side in the three-biome pool (level 35; level 50 is within 2 points):

| Four-legged | Win rate | | Two-legged | Win rate |
| --- | --- | --- | --- | --- |
| Sloshcalf (Greenwood) | 75% | | Splashjack (Greenwood) | 74% |
| Spurlet (Dust Canyon) | 60% | | Thatchling (Dust Canyon) | 65% |
| Cairnback (Dust Canyon) | 59% | | Moatkeep (Tide Flats) | 55% |
| Cocklemole (Tide Flats) | 56% | | Mossmitt (Greenwood) | 54% |
| Hullock (Tide Flats) | 54% | | Stumpwarden (Greenwood) | 50% |
| Spadesnout (Greenwood) | 53% | | Clapshell (Tide Flats) | 47% |
| Burlhorn (Greenwood) | 49% | | Stiltbark (Greenwood) | 46% |
| Duneskit (Dust Canyon) | 44% | | Lanternell (Tide Flats) | 41% |
| Gorsling (Greenwood) | 44% | | Spirecap (Dust Canyon) | 36% |
| Gulpmaw (Tide Flats) | 44% | | Whirlgrit (Dust Canyon) | 33% |
| Glissot (Tide Flats) | 43% | | Runnelfin (Tide Flats) | 33% |
| Wadibuck (Dust Canyon) | 41% | | Flintknap (Dust Canyon) | 32% |
| Mean: Greenwood 55, Dust Canyon 51, Tide Flats 49 | | | Mean: Greenwood 56, Dust Canyon 41, Tide Flats 44 | |

- **No biome is strictly better.** No Tide Flats pure species beats every pure species of Greenwood or of Dust Canyon head to head, and none of theirs beats every Tide Flats one, on either plan, at either level (four hard checks).
- **Greenwood's Leaf species recover.** Six new Water species are prey for Leaf, so Stiltbark goes from 26% (two-biome pool) to 46% and Stumpwarden from 29% to 50%: the gap the Dust Canyon document describes closes from the other side.
- **Battle length.** 3v3 between random wild teams (400 battles, wild qualities 3 to 7): Tide Flats 10.9 turns at levels 35 and 50 (8 to 14); all three biomes 10.2 at 35 and 50 (7 to 14). Pass. The earlier pacing numbers are unchanged.

## Known gaps

**The two-legged mixed pool.** Dust Canyon's Sand bipeds are now the low ones (Flintknap 32%, Whirlgrit 33%, Spirecap 36%): four Water bipeds (three new plus Splashjack) beat Sand, and those three Sand species carry no anti-Water move. Runnelfin (33%) is low for the mirror reason: four Leaf bipeds beat it. The best builds are Leaf or Sand torsos wearing parts from all three biomes. This is the same type-chart effect as before, moved to another biome; closing it would mean giving Dust Canyon's Sand bipeds a Leaf move (a Dust Canyon change), or judging mixed balance by 3v3 teams (the open question in `docs/DECISIONS.md`).

**The four-legged mixed cap.** Just over 75% at the fixed field, 77 to 78% on other fields. The top builds are Sloshcalf itself and hybrids built on Hullock's or Cocklemole's torso with Greenwood and Dust Canyon limbs: the Tide Flats Defence torso plus a Greenwood Defence head (Burlhorn) reaches Defence 178 to 227. That is the favoured stat doing what a favoured stat does; if it is too strong, the lever is the torso's Defence share (55%), not the config.

**Not measured.** Quality pips other than 5, the size gene, Gem-tier (+5%) individuals, smarter move choice, every build against the field (only fixed fields), and tamers or giants using these species (none exist yet).

## How the roster was designed

1. **Type mix first.** Three shapes were tried with first-guess stats before any tuning, on the Tide Flats gate alone:
   - Water, Water, Leaf, Sand on four legs and four Water on two legs (six Water, one Leaf, one Sand): the four-legged triangle was close (best 76%, lowest 39%), but the mono-Water two-legged plan reached a best build of **94%**: with no type counters, the hybrid of the best head, torso and legs simply wins.
   - Three Water and a Leaf on four legs, three Water and a Sand on two: the lone Leaf won 85% as a pure species; Leaf among Water is an overdog.
   - **Three Water and a Sand on each plan, the Sand torsos carrying Red Tide**: best 76 to 93% before tuning, but the right structure; this is the roster.
2. **One stat template** for every species, with the torso Defence share raised for the biome's stat (above).
3. **Seeded hill-climbing search** on each species' Hp, Attack and Defence (Speed fills the budget), its weight and the power of every new move, inside role bounds (Hullock and Lanternell most Defence, Glissot and Runnelfin fastest, and so on). First against the Tide Flats gate on two fields (seeds 2026 and 77) at levels 35 and 50, then with the three-biome pool at level 35 added to the objective. Eight searches, about 1,600 evaluations, all in scratch scripts outside the repository. Lessons: Water torsos with strong own-type moves and the extra Defence tended to be the best part in every build, and the search kept lowering their torso moves (four ended at 45); the lone Sand species climbed from about 40% to 48 to 50% as Red Tide rose to 65; Clapshell's torso (Clamp Crush 65) is the one strong Water torso move left, and Clapshell is the strongest pure species alone (61 to 69%).

## Open questions for Ayrton

1. **Type mix.** Six Water and two Sand, one Sand per plan, and no Leaf (a lone Leaf among Water was too strong). Happy with that, or would you rather have a Leaf species and accept that every Water torso needs a Sand move?
2. **Defence as the biome's stat**, carried on the torsos (shells). Or would you rather Tide Flats favoured Hp?
3. **The three-biome marks.** Same question as for Dust Canyon: accept the noted gap (best 75 to 78%, lowest 31 to 41%), give Dust Canyon's Sand bipeds a Leaf move, or judge mixed balance by 3v3 teams?
4. **Red Tide** is a real-world name for a toxic algae bloom; fine as a teaser for the Mire, or rename?
5. **Uncommons** Hullock (1.9) and Lanternell (2.0): both two-zone catches. Too hard for the third biome?
6. **Names**: all eight species names and 21 move names are placeholders I believe are original. Lanternell, Glissot and Clapshell should be checked against other games before art is commissioned.
7. **Bait** (the biome's mechanic) is not in this roster: which of these, if any, should be the bait-summoned rare spawn, or is that a separate rare species?
