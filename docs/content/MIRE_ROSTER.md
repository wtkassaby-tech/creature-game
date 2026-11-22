# Mire roster

The fourth roster: the eight species of the Mire (biome 4, Toxic), their parts and moves, and the balance gate they pass alone and mixed with the three launch biomes. It is also where poison, the first status effect, gets its first moves. Data lives in `src/content/species_data/`, `src/content/Moves.luau` and `src/content/Species.luau`; the gate is `tests/roster.test.luau` (about 90 to 105 seconds now, most of it the four-biome pool). It follows the method of `GREENWOOD_ROSTER.md`, `DUST_CANYON_ROSTER.md` and `TIDE_FLATS_ROSTER.md`. No config number, no shared code and no earlier species was changed.

The species exist as data only: no biome in `src/content/Biomes.luau` spawns them yet, so the three launch biomes play exactly as before (checked: `playthrough`, `economy`, `encounters`, `world`, `dustcanyon` and the giant tests give identical output). Everything here is a [Default] the owner can change, and **every name (species and moves) is a placeholder**.

## At a glance

| Species | Plan | Type | Rarity | Role | Lasso |
| --- | --- | --- | --- | --- | --- |
| Bogbellow | Four-legged | Toxic | Uncommon | Bruiser: the most Hp on four legs, the slowest; poisons with its torso | 2.1 |
| Fenwhisk | Four-legged | Toxic | Common | Sprinter: the fastest on four legs; poisons with its head | 1.55 |
| Snaggar | Four-legged | Toxic | Common | Striker: the most Attack on four legs; a poisoning sting on its tail | 1.5 |
| Mistrel | Four-legged | Water | Common | All-rounder: the lone Water on four legs, with a Frost move on its torso | 1.5 |
| Bulbroth | Two-legged | Toxic | Uncommon | Sturdy all-rounder: the most Hp in the Mire, the slowest on two legs; poisons with its head | 2.2 |
| Keelsnap | Two-legged | Toxic | Common | Bruiser: the most Attack in the Mire; a poisoning sting on its tail | 1.5 |
| Skipslick | Two-legged | Toxic | Common | Sprinter: the fastest on two legs, the thinnest Defence; poisons with its head | 1.55 |
| Lilyshade | Two-legged | Water | Common | Sturdy all-rounder: the lone Water on two legs, with a Frost move on its torso | 1.5 |

- **Six Toxic, two Water.** Four species on each body plan, each plan three Toxic and one Water. Six Common, two Uncommon (Bogbellow, Bulbroth). Teams are four from here on.
- **The same shape as Tide Flats and Dust Canyon.** Three of the biome's type plus one underdog the majority beats (Toxic beats Water), and the underdog carries a torso-only move that beats the majority back: **Hoarmist** (Frost 70, from level 34) on the two Water torsos. Frost beats Toxic and is neutral against Leaf, Sand and Water, so unlike a Sand move it gives no extra edge over the launch types in a mixed pool. It is also the teaser for Frostline, biome 5.
- **No Sand species.** Sand beats Toxic and Toxic moves hit Sand weakly, so a Sand species among Toxic ones would be the overdog (the same trap as a Leaf species in Tide Flats). Players arriving with Sand creatures have the type edge here; that is the type chart doing its job.
- **The Mire favours Hp for breeding.** Its tails are swollen water sacks, bulrush heads and root trains: they carry 13% of a species' Hp (earlier rosters about 5%), so Mire tails average **18.1 Hp** at quality 5 against at most 6.9 in any earlier biome. The test checks this. The torso still carries 70% of Hp and sets the type, so a breeder who wants a tougher creature can take the Mire tail without taking the Toxic type.
- **Lasso difficulty a step above Tide Flats'.** Commons 1.5, the two skittish sprinters 1.55 (Tide Flats 1.4 to 1.45); uncommons 2.1 and 2.2 (Tide Flats 1.9 and 2.0). All two-zone at most; none reaches the three-zone 2.5.
- **Gem tier:** as before, any of the eight can spawn wild as a Gem individual; nothing in the species data changes.

## Poison in this roster

Four poisoning moves, all Toxic, all brought only by Toxic species, each weaker than the plain moves of the same slot and unlock level (the test checks all three):

| Move | Power | Brought by | Plain moves of that slot at level 1 |
| --- | --- | --- | --- |
| Venom Nip | 30 | Fenwhisk head L1, Skipslick head L1 | heads 40 to 50 (mean 45) |
| Broth Spit | 40 | Bulbroth head L1 | heads 40 to 50 (mean 45) |
| Fume Belch | 45 | Bogbellow torso L1 | torsos 40 to 65 (mean 57) |
| Barb Sting | 30 | Snaggar tail L1, Keelsnap tail L1 | tails 45 |

- **Wild Mire creatures do poison.** Bogbellow, Fenwhisk, Bulbroth and Skipslick keep their poisoning move among their default four at the cap (tested), so a player meets poison from the first route. Snaggar and Keelsnap, the strikers, carry a poisoning tail move that their own stronger moves push out of the default four: it is a part to breed onto a creature that has room for it, not something they use wild.
- **Toxic is immune, so inside the Mire poison only lands on the two Water species and Water-torso hybrids.** That is the lesson the biome teaches: a player who brings Leaf, Sand or Water creatures gets poisoned; a player who catches Toxic ones does not.
- **The default move choice ignores effects.** `Battle.bestMoves` ranks moves by power and own-type bonus only, so a weak poisoning move stays in the four only when the creature has few stronger moves. Hybrids mostly drop it (see the measurements). The data was placed with that in mind.

## The species and how they look

Art direction for every part: chunky low-poly, flat colours, every joint ends in a rounded ball that sits in the torso socket. Silhouettes are kept apart from the 26 earlier species (no stilts, no back-ponds, no boxing mitts, no stone stacks, no shells worn as helmets, no glowing domes, no blade forearms, no all-mouth heads): a peat-mound boar with vent chimneys, a bulrush-tailed weasel, a gar-snouted lurker, a moss-shawled tapir, a cauldron-bellied cook, a keeled snapping-turtle brawler, a Z-legged warning-coloured frog and a lily-pad-hatted pond keeper. Each species file carries the same descriptions as comments.

**Bogbellow**: a hulking bog boar whose back is a mound of steaming peat, with gas vents that puff green fumes when it bellows.
- Head: a broad, low head with a flat, shovel-like snout for rooting in peat, two short curled tusks the colour of old bone, and small heavy-lidded eyes.
- Torso: a huge barrel body whose back is a lumpy mound of dark peat with three short chimney-like vents (the green puffs are a particle effect, not a part).
- Front legs: thick, short forelegs caked in mud up to the knees, with wide split trotters.
- Hind legs: stocky hind legs with heavy, mud-caked trotters.
- Tail: a fat, bulging tail like a sack of swamp water, swollen and sagging.

**Fenwhisk**: a slinky marsh weasel that darts through the reeds with its bulrush tail held up like a flag.
- Head: a small, narrow head with a pointed nose, a ruff of stiff reed-like whiskers and sulphur-yellow warning stripes above the eyes.
- Torso: a very long, low, slinky body in olive green with a sulphur-yellow stripe down the spine.
- Front legs: short, quick forelegs with small grasping paws.
- Hind legs: longer, springy hind legs with narrow feet for darting.
- Tail: a long, thin tail ending in a fat brown bulrush head, held upright.

**Snaggar**: a long-snouted swamp lurker that lies still among the mangrove roots until something passes within reach of its needle-toothed jaws.
- Head: a very long, narrow snout like a gar fish's, lined with needle teeth that show even when it is shut, the eyes on two bumps on top.
- Torso: a long, low body of diamond-shaped scales in murky green and bronze, with a ridge of broken, snag-like twigs along the spine.
- Front legs: short, sprawling forelegs with hooked claws.
- Hind legs: sprawling, bent hind legs with hooked, half-webbed feet.
- Tail: a thick, tapering tail tipped with a cluster of barbed thorns.

**Mistrel**: a stocky swamp tapir draped in hanging moss, which blows a cold mist from its trunk to hide in at dawn.
- Head: a heavy, rounded head with a short, bendy trunk-like snout, small round ears and a frosty white blaze.
- Torso: a rounded, barrel-shaped body in slate blue, with a shawl of hanging grey swamp moss over the shoulders, its tips white with frost.
- Front legs: sturdy, straight forelegs with three blunt toes.
- Hind legs: sturdy hind legs with four blunt toes.
- Tail: a short, stubby tail with a frosted tuft.

**Bulbroth**: a pot-bellied swamp cook whose round belly bubbles like a cauldron of green broth.
- Head: a wide, flat, frog-like head with a broad lip, heavy-lidded eyes and a lily pad worn flat on top like a cap.
- Torso: a big, round pot belly of translucent green rimmed at the top like a cauldron (one solid translucent part; the bubbles are a particle effect).
- Arms: short, thick arms ending in broad, ladle-shaped hands.
- Legs: short, bowed legs with small round-toed feet.
- Tail: a heavy, rounded tail like a sagging water bag that drags behind it.

**Keelsnap**: a hunched snapping-turtle brawler with a hooked beak and a shell crusted with dried swamp mud.
- Head: a blocky head with a sharp hooked beak, a craggy brow and small red eyes.
- Torso: a hunched body under a high shell ridged with three rows of jagged keels, caked with cracked dry mud.
- Arms: long, thick arms with heavy scaled forearms and three hooked claws.
- Legs: short, thick, pillar-like legs with blunt claws.
- Tail: a long, thick tail with a saw-toothed ridge, ending in a barbed spike.

**Skipslick**: a lanky marsh frog in warning colours that sprints upright across lily pads faster than they can sink.
- Head: a small, round head with two huge bulging eyes on top and a wide grin, warning orange with black spots.
- Torso: a slim, upright, shiny body striped black and warning orange.
- Arms: thin arms with round, sticky-pad fingertips.
- Legs: long, spring-like legs folded in a Z, with long splayed toes.
- Tail: a tiny, rounded stub of a tail.

**Lilyshade**: a slender pond keeper that wears a broad lily pad like a sun hat and trails a cold mist wherever it walks.
- Head: a small, smooth oval face under a broad lily pad worn like a wide-brimmed hat, a single white water lily on the brim.
- Torso: a tall, slender body like a bound bundle of reeds, pond green with a pale frosty sheen at the shoulders.
- Arms: long, thin arms that end in fronds of trailing water roots.
- Legs: short legs half hidden under a skirt of hanging roots, ending in rounded root feet.
- Tail: a long, trailing train of water roots and duckweed.

**Sizes.** Weights run 74 (Mistrel) to 46 (Fenwhisk) on four legs and 70 (Bulbroth) to 36 (Skipslick) on two. Socket and plug radii follow the earlier rule (a base size per slot times the cube root of the weight, plug equal to its own species' socket), so every part fits every torso on its plan across all four biomes inside the assembler's 0.6 to 1.6 range (the test checks this). Lengths and radii are planning values until the meshes exist.

## Stats

Budget score = Hp x 0.6 + Attack + Defence + Speed at quality 5. Every species scores 200, the plan budget. Level 45 is the Mire cap (three badges); level 50 is ranked. Both are a pure creature at quality 5.

Every species uses the same split of its totals across its parts: head 61% of Attack; torso 70% of Hp and 45% of Defence; front limbs 32% of Attack and 27% of Defence; legs 67% of Speed; **tail 13% of Hp** and 20% of Defence; small shares elsewhere.

| Species | Base Hp / Atk / Def / Spd | Level 45 | Level 50 | Weight | Default four at 45 |
| --- | --- | --- | --- | --- | --- |
| Bogbellow | 145 / 42 / 42 / 29 | 464 / 134 / 134 / 92 | 500 / 144 / 144 / 100 | 68 | Mire Crush, Bog Wade, Fume Belch, Peat Butt |
| Fenwhisk | 133 / 40 / 34 / 46 | 425 / 128 / 108 / 147 | 458 / 138 / 117 / 158 | 46 | Fen Lash, Slick Dash, Sludge Slap, Venom Nip |
| Snaggar | 140 / 48 / 34 / 34 | 448 / 153 / 108 / 108 | 483 / 165 / 117 / 117 | 70 | Murk Lunge, Snag Bite, Bog Wade, Gar Rend |
| Mistrel | 135 / 46 / 40 / 33 | 432 / 147 / 128 / 105 | 465 / 158 / 138 / 113 | 74 | Murk Dive, Hoarmist, Reed Paddle, Bog Wade |
| Bulbroth | 150 / 42 / 34 / 34 | 480 / 134 / 108 / 108 | 517 / 144 / 117 / 117 | 70 | Mire Crush, Bog Wade, Sludge Slap, Broth Spit |
| Keelsnap | 125 / 50 / 32 / 43 | 400 / 160 / 102 / 137 | 431 / 172 / 110 / 148 | 54 | Shell Bash, Bog Wade, Gar Rend, Hook Beak |
| Skipslick | 140 / 44 / 26 / 46 | 448 / 140 / 83 / 147 | 483 / 151 / 89 / 158 | 36 | Fen Lash, Slick Dash, Sludge Slap, Venom Nip |
| Lilyshade | 145 / 42 / 36 / 35 | 464 / 134 / 115 / 112 | 500 / 144 / 124 / 120 | 60 | Still Water, Hoarmist, Reed Paddle, Bog Wade |

(Fenwhisk's budget is 199.8: its Hp is not a multiple of 5.)

**Bogbellow** (Quad, Toxic)

| Part | Stats | Moves |
| --- | --- | --- |
| Head | Hp 6, Atk 26, Def 3, Spd 3 | Peat Butt (L1), Mire Crush (L38) |
| Torso | Hp 101, Atk 2, Def 19, Spd 1 | Fume Belch (L1) |
| Front limbs | Hp 12, Atk 13, Def 11, Spd 4 | Muck Stamp (L1) |
| Legs | Hp 7, Spd 19 | Bog Wade (L1) |
| Tail | Hp 19, Atk 1, Def 9, Spd 2 | Sludge Slap (L1) |

**Fenwhisk** (Quad, Toxic)

| Part | Stats | Moves |
| --- | --- | --- |
| Head | Hp 5, Atk 24, Def 3, Spd 5 | Venom Nip (L1), Fen Lash (L34) |
| Torso | Hp 93, Atk 2, Def 15, Spd 2 | Slick Dash (L1) |
| Front limbs | Hp 11, Atk 13, Def 9, Spd 6 | Sludge Slap (L1) |
| Legs | Hp 7, Spd 31 | Slick Dash (L1) |
| Tail | Hp 17, Atk 1, Def 7, Spd 2 | Sludge Slap (L1) |

**Snaggar** (Quad, Toxic)

| Part | Stats | Moves |
| --- | --- | --- |
| Head | Hp 6, Atk 29, Def 3, Spd 4 | Gar Rend (L1), Snag Bite (L36) |
| Torso | Hp 98, Atk 2, Def 15, Spd 1 | Murk Lunge (L1) |
| Front limbs | Hp 11, Atk 15, Def 9, Spd 5 | Muck Stamp (L1) |
| Legs | Hp 7, Spd 23 | Bog Wade (L1) |
| Tail | Hp 18, Atk 2, Def 7, Spd 1 | Barb Sting (L1) |

**Mistrel** (Quad, Water)

| Part | Stats | Moves |
| --- | --- | --- |
| Head | Hp 5, Atk 28, Def 3, Spd 4 | Mist Snap (L1), Fen Plunge (L36) |
| Torso | Hp 94, Atk 2, Def 18, Spd 1 | Murk Dive (L1), Hoarmist (L34) |
| Front limbs | Hp 11, Atk 15, Def 11, Spd 4 | Reed Paddle (L1) |
| Legs | Hp 7, Spd 22 | Bog Wade (L1) |
| Tail | Hp 18, Atk 1, Def 8, Spd 2 | Reed Paddle (L1) |

**Bulbroth** (Biped, Toxic)

| Part | Stats | Moves |
| --- | --- | --- |
| Head | Hp 6, Atk 26, Def 3, Spd 4 | Broth Spit (L1), Mire Crush (L38) |
| Torso | Hp 105, Atk 2, Def 15, Spd 1 | Simmer Slam (L1) |
| Front limbs | Hp 12, Atk 13, Def 9, Spd 5 | Muck Stamp (L1) |
| Legs | Hp 7, Spd 23 | Bog Wade (L1) |
| Tail | Hp 20, Atk 1, Def 7, Spd 1 | Sludge Slap (L1) |

**Keelsnap** (Biped, Toxic)

| Part | Stats | Moves |
| --- | --- | --- |
| Head | Hp 5, Atk 31, Def 3, Spd 5 | Hook Beak (L1), Gar Rend (L36) |
| Torso | Hp 88, Atk 2, Def 14, Spd 2 | Shell Bash (L1) |
| Front limbs | Hp 10, Atk 16, Def 9, Spd 6 | Muck Stamp (L1) |
| Legs | Hp 6, Spd 28 | Bog Wade (L1) |
| Tail | Hp 16, Atk 1, Def 6, Spd 2 | Barb Sting (L1) |

**Skipslick** (Biped, Toxic)

| Part | Stats | Moves |
| --- | --- | --- |
| Head | Hp 6, Atk 27, Def 2, Spd 5 | Venom Nip (L1), Fen Lash (L34) |
| Torso | Hp 98, Atk 2, Def 12, Spd 2 | Slick Dash (L1) |
| Front limbs | Hp 11, Atk 14, Def 7, Spd 6 | Sludge Slap (L1) |
| Legs | Hp 7, Spd 31 | Slick Dash (L1) |
| Tail | Hp 18, Atk 1, Def 5, Spd 2 | Sludge Slap (L1) |

**Lilyshade** (Biped, Water)

| Part | Stats | Moves |
| --- | --- | --- |
| Head | Hp 6, Atk 26, Def 3, Spd 4 | Mist Snap (L1), Fen Plunge (L36) |
| Torso | Hp 101, Atk 2, Def 16, Spd 2 | Still Water (L1), Hoarmist (L34) |
| Front limbs | Hp 12, Atk 13, Def 10, Spd 5 | Reed Paddle (L1) |
| Legs | Hp 7, Spd 23 | Bog Wade (L1) |
| Tail | Hp 19, Atk 1, Def 7, Spd 1 | Reed Paddle (L1) |

## Moves

23 new moves: 17 Toxic (4 of them poisoning), 5 Water, 1 Frost. Power 30 to 70. Every part's first move is known from level 1; second moves unlock at 34 to 38, inside the Mire's wild levels (32 to 42; the test allows a second move up to level 42). No existing move was changed.

| Move | Type | Power | Effect | Brought by |
| --- | --- | --- | --- | --- |
| Muck Stamp | Toxic | 40 | | Bogbellow, Snaggar, Bulbroth, Keelsnap front limbs L1 |
| Simmer Slam | Toxic | 40 | | Bulbroth torso L1 |
| Peat Butt | Toxic | 45 | | Bogbellow head L1 |
| Sludge Slap | Toxic | 45 | | Fenwhisk and Skipslick front limbs and tails L1; Bogbellow and Bulbroth tails L1 |
| Bog Wade | Toxic | 50 | | the legs of every non-sprinter, Water species included, L1 |
| Gar Rend | Toxic | 50 | | Snaggar head L1; Keelsnap head L36 |
| Hook Beak | Toxic | 50 | | Keelsnap head L1 |
| Slick Dash | Toxic | 50 | | Fenwhisk and Skipslick torsos and legs L1 |
| Fen Lash | Toxic | 55 | | Fenwhisk and Skipslick heads L34 |
| Snag Bite | Toxic | 55 | | Snaggar head L36 |
| Mire Crush | Toxic | 60 | | Bogbellow and Bulbroth heads L38 |
| Murk Lunge | Toxic | 65 | | Snaggar torso L1 |
| Shell Bash | Toxic | 65 | | Keelsnap torso L1 |
| Venom Nip | Toxic | 30 | Poison | Fenwhisk and Skipslick heads L1 |
| Barb Sting | Toxic | 30 | Poison | Snaggar and Keelsnap tails L1 |
| Broth Spit | Toxic | 40 | Poison | Bulbroth head L1 |
| Fume Belch | Toxic | 45 | Poison | Bogbellow torso L1 |
| Fen Plunge | Water | 40 | | Mistrel and Lilyshade heads L36 |
| Mist Snap | Water | 40 | | Mistrel and Lilyshade heads L1 |
| Reed Paddle | Water | 45 | | Mistrel and Lilyshade front limbs and tails L1 |
| Murk Dive | Water | 65 | | Mistrel torso L1 |
| Still Water | Water | 65 | | Lilyshade torso L1 |
| Hoarmist | Frost | 70 | | Mistrel and Lilyshade torsos L34 |

Where coverage sits, and why:
- **Anti-Toxic coverage on Water torsos only** (Hoarmist, Frost 70, from level 34). It is what lets the lone Water species on each plan fight three Toxic neighbours; since the torso sets the type, no Toxic hybrid can carry it into a Toxic mirror. The test checks that Frost moves come only on Water torsos.
- **Strong moves sit on torsos and late on heads.** The 60 to 70 moves are torso moves or head unlocks at 38; limb, leg and tail moves are 40 to 50.
- **Legs bring the biome's move.** Every non-sprinter's legs bring Bog Wade (Toxic 50), the Water species' included, as Tide Flats' legs bring Shoal Stomp. It gives the Water species a Toxic move that hits Water hard, which is what the search kept raising it for.
- **Some second head moves are no stronger than the first** (Keelsnap's Gar Rend, the Water heads' Fen Plunge, both equal to the first move): the search kept pulling them down because stronger head moves made those heads the best part in every build. They are still a second option to choose; renaming or reshaping them is a free choice.

## Balance gate: measured results

Method as in the earlier rosters: every combination of parts on a plan at quality 5; a fixed field (every pure species, the five best builds by each stat and by total, then a random sample with seed 2026); every pair fights twice with sides swapped (ranked rules, no variance, the default move choice and opponent); draws count half. The Mire alone: 1,024 builds per plan, field 160. All four biomes: sixteen species per plan, 1,048,576 builds, field 200. Builds are head/torso/front limbs/legs/tail.

**The Mire alone: passes every mark.**

| | Best build | Pure species | Top ten torsos / leg sets |
| --- | --- | --- | --- |
| Four-legged, level 45 | 70% Mistrel/Snaggar/Bogbellow/Fenwhisk/Bogbellow | Bogbellow 62, Snaggar 59, Fenwhisk 55, Mistrel 48 | 2 / 3 |
| Four-legged, level 50 | 70% (same build) | Bogbellow 60, Snaggar 60, Fenwhisk 56, Mistrel 48 | 3 / 4 |
| Two-legged, level 45 | 68% Keelsnap/Keelsnap/Keelsnap/Bulbroth/Bulbroth | Bulbroth 64, Lilyshade 57, Keelsnap 56, Skipslick 42 | 3 / 3 |
| Two-legged, level 50 | 68% (same build) | Bulbroth 62, Lilyshade 55, Keelsnap 55, Skipslick 42 | 2 / 3 |

On three other fields (seeds 77, 5 and 9, scratch runs): four-legged best 69 to 73%, lowest pure 47 to 50%; two-legged best 68 to 73%, lowest pure 41 to 43%. The weakest spot is Skipslick (the two-legged sprinter), 41 to 43% everywhere: inside the mark, but the first thing to watch.

**All four biomes mixed: the same two marks noted as for the earlier pools, every hard check passes.**

| | Best build | Lowest pure | Top ten torsos / leg sets | Head to head |
| --- | --- | --- | --- | --- |
| Four-legged, level 45 | **82%** Cairnback/Cocklemole/Gorsling/Cocklemole/Snaggar | **26%** Wadibuck | 7 / 4 | pass |
| Four-legged, level 50 | **81%** (same build) | **26%** Wadibuck | 7 / 5 | pass |
| Two-legged, level 45 | **85%** Runnelfin/Moatkeep/Lilyshade/Runnelfin/Lilyshade | **29%** Runnelfin | 2 / 6 | pass |
| Two-legged, level 50 | **85%** (same build) | **29%** Runnelfin | 3 / 6 | pass |

As for the earlier mixed pools, the 75% and 40% marks print as NOTE, and new guard rails for this pool fail the run if it gets worse than measured: best build at most **88%**, lowest pure species at least **24%**, and poison carriers at most **15 points** above the rest. No existing threshold was changed.

Pure species side by side in the four-biome pool (level 45; level 50 is within 1 point):

| Four-legged | Win rate | | Two-legged | Win rate |
| --- | --- | --- | --- | --- |
| Sloshcalf (Greenwood) | 64% | | Splashjack (Greenwood) | 71% |
| Snaggar (Mire) | 63% | | Thatchling (Dust Canyon) | 63% |
| Cairnback (Dust Canyon) | 62% | | Moatkeep (Tide Flats) | 62% |
| Cocklemole (Tide Flats) | 62% | | Bulbroth (Mire) | 57% |
| Bogbellow (Mire) | 60% | | Lilyshade (Mire) | 57% |
| Spurlet (Dust Canyon) | 57% | | Mossmitt (Greenwood) | 54% |
| Burlhorn (Greenwood) | 56% | | Keelsnap (Mire) | 53% |
| Fenwhisk (Mire) | 56% | | Stumpwarden (Greenwood) | 50% |
| Mistrel (Mire) | 54% | | Stiltbark (Greenwood) | 47% |
| Duneskit (Dust Canyon) | 53% | | Spirecap (Dust Canyon) | 45% |
| Gorsling (Greenwood) | 50% | | Skipslick (Mire) | 43% |
| Spadesnout (Greenwood) | 48% | | Whirlgrit (Dust Canyon) | 41% |
| Hullock (Tide Flats) | 39% | | Clapshell (Tide Flats) | 39% |
| Glissot (Tide Flats) | 29% | | Flintknap (Dust Canyon) | 39% |
| Gulpmaw (Tide Flats) | 29% | | Lanternell (Tide Flats) | 35% |
| Wadibuck (Dust Canyon) | 26% | | Runnelfin (Tide Flats) | 29% |
| Mean: Greenwood 54, Dust Canyon 50, Tide Flats 40, Mire 58 | | | Mean: Greenwood 55, Dust Canyon 47, Tide Flats 41, Mire 52 | |

- **No biome is strictly better.** No Mire pure species beats every pure species of Greenwood, Dust Canyon or Tide Flats head to head, and none of theirs beats every Mire one, on either plan, at either level (twelve hard checks).
- **The Water species are the low ones now.** Six Toxic species are new predators of Water, so Tide Flats' Water species and Wadibuck fall to 26 to 39%; the Sand torsos (Cairnback, Cocklemole, Moatkeep) rise, because Sand beats Toxic. This is the type chart moving the gap from one biome to another, as each earlier roster document describes.
- **Battle length.** 4v4 between random wild teams (400 battles, wild qualities 3 to 7): the Mire 14.7 turns at levels 45 and 50 (12 to 19); all four biomes 13.9 (10 to 17). The 3v3 target of 8 to 14 turns is scaled by team size to 10.7 to 18.7 for a 4v4 (a new threshold; see open questions). The earlier 3v3 pacing numbers are unchanged.

## What poison does: measurements

| Measure | Four-legged | Two-legged |
| --- | --- | --- |
| Mire alone: fights in which anything was poisoned | 16% | 9% |
| Mire alone: builds whose default four include a poisoning move | 54 of 160 | 26 of 160 |
| Mire alone: their mean win rate, against the rest | 54% vs 48% | 59% vs 48% |
| Mire alone, poison switched off (same data, scratch run) | no change but Mistrel 48 to 49% | no change |
| Four biomes: fights in which anything was poisoned | 8% | 3% |
| Four biomes: carriers in the field | 9 of 200, 61% vs 50% | 3 of 200, 51% vs 50% |
| Four biomes, poison switched off (scratch run): Mire carriers' pure win rate | Bogbellow 60 to 50%, Fenwhisk 56 to 51% | Bulbroth 57 to 48%, Skipslick 43 to 38% |
| Pure carrier against all 12 launch pure species of its plan, level 45, with / without poison | Bogbellow 67 / 50%, Fenwhisk 54 / 50% | Bulbroth 62 / 54%, Skipslick 50 / 38% |
| Pools without the Mire | 0 fights with poison | 0 |

What this says:
- **Inside the Mire, poison is nearly irrelevant to balance** because six of eight species are immune; the carriers' 6 to 11 point edge comes from the builds themselves (Bulbroth's and Bogbellow's parts), not from poison. Switching it off moves no win rate by more than a point.
- **Against what players bring (Leaf, Sand, Water), poison is strong.** A pure carrier gains 4 to 17 points of win rate against the launch species, and in the four-biome pool poison is worth about 5 to 10 points to each carrier's pure win rate. One poisoning hit takes a third of the target's full health over four turns, and a 1v1 at these levels lasts only 3 to 4 turns, so the poison nearly always runs its course: it is worth one and a half to two ordinary hits.
- **It is not the only good strategy.** The best builds in every pool carry no poisoning move, the two Mire strikers win without it, and in mixed pools hybrids rarely keep it (the default choice drops weak moves).

**Recommendation on the numbers (not applied; `BattleConfig` was not touched).** Poison is about right as a *lesson* (it lands on every launch creature, Toxic creatures shrug it off), but on the strong side as a *number* for 1v1 fights this short. If playtests show wild Mire creatures feeling unfair to a team of launch creatures, the smallest change is `POISON_TURNS` 4 to 3 (a quarter of health in all) or `POISON_SHARE` 1/12 to 1/16; either roughly halves the edge measured above. A separate, larger point: `Battle.bestMoves` ignores effects, so a player's or a wild creature's default four keeps a poisoning move only when the creature has few stronger moves. If poison should matter in bred creatures, the default choice should count a move's poison the way `Battle.moveValue` already does for opponents (a `src/shared` change, not made here).

## Known gaps

**The four-biome pool, two-legged.** Best 85%: a Tide Flats Sand torso (Moatkeep, with its anti-Water Red Tide) wearing Runnelfin's fast head and legs and Lilyshade's Hp-rich arms and tail. Sand beats Toxic, so the four Mire bipeds make the Sand torso stronger than it was in the three-biome pool (77 to 78%). The lever is Moatkeep (Tide Flats data) or judging mixed balance by 4v4 teams, the open question in `docs/DECISIONS.md`.

**The four-biome pool, four-legged.** Best 81 to 82%, lowest 26% (Wadibuck), the Water species low for the type reason above.

**Hp tails in hybrids.** A Mire tail carries 16 to 20 Hp against 5 to 7 elsewhere; they appear in many of the best mixed builds. That is the favoured stat doing its job; if it is too strong, the lever is the tail's Hp share (13%), not the config.

**`tests/tideflats.test.luau` and the Mire species.** Its Carrackon (giant) battles drew teams from every non-giant species in the registry, so Mire creatures joined those teams and moved its numbers to the edge of two bands. Fixed on 21 November 2026: the test now takes only species of the three launch biomes (`def.biome <= 3`), and its output is the same as before the Mire. `breeding.test`'s printed stat ceiling also rises (1,300 to about 1,330) because it takes the best part of every species; it still passes.

**Not measured.** Quality pips other than 5, the size gene, Gem-tier individuals, smarter move choice, poison in full 4v4 team battles with switching (the gate is 1v1; pacing is 4v4 with the simple opponent), every build against the field, and tamers or giants using these species (none exist yet; giants are not affected by poison yet).

## How the roster was designed

1. **Type mix first**, from the earlier rosters' lessons: three of the biome's type and one underdog the majority beats, per plan, the underdog's torso carrying the one move that beats the majority back. Water is the underdog Toxic beats; Frost (not Sand) is the counter, so that it gives no extra edge over Leaf in mixed pools.
2. **One stat template** for every species, with 13% of Hp moved onto the tail for the biome's stat.
3. **Poison placed so wild creatures use it:** one poisoning move each on the heads of the two sprinters and the two-legged uncommon and on the torso of the four-legged uncommon, where their own pools are small enough for it to stay in the default four; a weak poisoning sting on the strikers' tails as a breeding part.
4. **Seeded hill-climbing search** on each species' Hp, Attack and Defence (Speed fills the budget), its weight and the power of every new move, inside role bounds (uncommons most Hp, sprinters fastest, strikers most Attack, poisoning moves 30 to 45). Against the Mire gate on two fields (seeds 2026 and 77) at levels 45 and 50, then a four-legged pass over four fields, then hand changes for the head-to-head checks of the four-biome pool (Bulbroth's Hp 160 to 150 and Broth Spit 45 to 40, which had made it beat all four Greenwood bipeds). About 1,500 evaluations, all in scratch scripts outside the repository. Lessons: a high-Hp uncommon torso was the best part in every early build; the Hp tails made the sprinters' bodies the best four-legged hybrids until Fenwhisk's and Snaggar's numbers were trimmed; and strong second head moves made those heads universal, which is why several ended no stronger than the first.

## Open questions for Ayrton

1. **Type mix.** Six Toxic and two Water, no Sand (a Sand species would beat its Toxic neighbours on type alone). Happy with that?
2. **Hp as the biome's stat**, carried on the tails. Or would you rather the Mire favoured something else (Attack belongs to Emberfall, Defence to Frostline)?
3. **Poison's strength.** Measured above as strong against launch creatures in short fights. Keep 1/12 for 4 turns, or try 3 turns or 1/16 in playtests? And should the default move choice count poison (a shared-code change)?
4. **The 4v4 pacing target**: 10.7 to 18.7 turns (the 3v3 target scaled by team size), measured 13.9 to 14.7. Right target?
5. **The four-biome marks**: accept the noted gap (best 81 to 85%, lowest 26 to 29%), or address the Sand torsos in Tide Flats, or judge mixed balance by 4v4 teams?
6. (Settled: the Tide Flats giant test now uses launch species only.)
7. **Uncommons** Bogbellow (2.1) and Bulbroth (2.2): two-zone catches. Right for the fourth biome?
8. **Names**: all eight species names and 23 move names are placeholders I believe are original; Bogbellow, Mistrel and Skipslick should be checked against other games before art is commissioned. One species was renamed to Keelsnap on 21 November 2026 because its first name sat one syllable from a creature in another game. "Hoarmist" is a made-up word.
9. **The Mire's giant, its bait-or-other rare spawn, and its world** are not part of this roster.
