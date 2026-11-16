# Greenwood roster

The first real roster: the eight species of Greenwood (biome 1), their parts and moves, and the balance gate they pass. Data lives in `src/content/species/`, `src/content/Moves.luau` and `src/content/Species.luau`; the gate is `tests/roster.test.luau` (about 2 seconds). Everything here is a [Default] the owner can change.

## At a glance

| Species | Plan | Type | Rarity | Role | Starter |
| --- | --- | --- | --- | --- | --- |
| Burlhorn | Four-legged | Leaf | Uncommon | Bruiser: hits hard and soaks hits, but slow | No |
| Gorsling | Four-legged | Leaf | Common | Sprinter: fast, thin Defence | No |
| Spadesnout | Four-legged | Sand | Common | Striker: the most Attack in Greenwood | **Sand starter** |
| Sloshcalf | Four-legged | Water | Common | Fast all-rounder | **Water starter** |
| Stumpwarden | Two-legged | Leaf | Common | Tank: the most Hp in Greenwood, slow | No |
| Stiltbark | Two-legged | Leaf | Uncommon | Sprinter: the fastest, very thin Defence, deep Hp | No |
| Mossmitt | Two-legged | Leaf | Common | All-rounder: even stats | **Leaf starter** |
| Splashjack | Two-legged | Water | Common | All-rounder: even Attack, Defence and Speed | No |

- Five Leaf, one Sand, two Water. Four species on each plan. Six Common, two Uncommon.
- **Starters also appear in the wild**, as ordinary commons in one spot each (Mossmitt in the mossy glade near the hub, Spadesnout on the sandy river bank, Sloshcalf along the stream). Breeding needs wild partners on the same plan, and every creature stays earnable for ever. The player's pick is still special: it is the one they get first, at minute 0.
- The starters avoid the usual trio (fire lizard, water turtle, grass reptile): a moss-fisted brawler, a shovel-snouted digger and a calf with a pond on its back.
- Lasso difficulty: commons 1.0 (Gorsling 1.1, it is jumpy); uncommons 1.4 (Burlhorn) and 1.5 (Stiltbark).

## The species and how they look

Art direction for every part: chunky low-poly, flat colours, and every joint ends in a rounded ball that sits in the torso socket, so a part from another species still looks joined. Each file also carries these descriptions as comments.

**Burlhorn**: a slow, stubborn grazer whose back has grown into a knotted burl of living wood.
- Head: broad, blunt wooden muzzle with one short, forward-curving horn shaped like a gnarled knot; small amber eyes under a mossy brow.
- Torso: wide barrel body of overlapping bark plates, a big rounded burl hump over the shoulders with moss tufts and two tiny mushrooms.
- Front legs: thick pillar legs ringed with bark bands, flat pale wooden pads with three blunt toes.
- Hind legs: short stump-like legs with root toes that splay where they meet the ground.
- Tail: short and stiff, ending in a bundle of twigs like a small broom.

**Gorsling**: a twitchy, whip-thin hedge runner that bolts through the meadow shedding yellow blossom.
- Head: long narrow snout like a greyhound's, two swept-back ears that are sprigs of spiky gorse with a yellow flower tuft at each tip, big round dark eyes.
- Torso: slim, deep-chested body that tucks up at the waist; light green, pale belly, a ridge of short blunt spines.
- Front legs: long thin legs with knobbly knees and small pointed feet.
- Hind legs: long springy legs with a high back-bent ankle; darker green with yellow speckles.
- Tail: long and thin, ending in a round puff of yellow gorse flowers.

**Spadesnout** (Sand starter): a stocky riverbank digger that shovels with its flat snout and hits like a falling stone.
- Head: wide, flat spade-shaped snout plated like a garden trowel, squinting eyes, round ears tucked back; sandy ochre with two darker stripes.
- Torso: compact, low, muscled body with a ridge of flat sandstone-coloured plates and a lighter belly.
- Front legs: short and thick, with three big curved digging claws like chunky blades.
- Hind legs: short and strong, wide flat feet for bracing.
- Tail: a short thick wedge tipped with a round pebble knob.

**Sloshcalf** (Water starter): a gentle, round calf that carries a little pond in a clear bubble hump on its back.
- Head: broad round calf head, floppy lily-pad ears, soft blunt nose, two tiny nub horns of smooth river stone.
- Torso: plump blue-grey body with a clear glassy dome on its back holding water and one floating leaf (one solid transparent part, no physics).
- Front legs: short and sturdy, rounded webbed hoof-paddles.
- Hind legs: sturdy, a little longer than the front, same webbed paddles.
- Tail: short, ending in a fan like a tuft of reeds with one droplet hanging from the tip.

**Stumpwarden**: a squat, patient guardian that plants itself in the path like a living tree stump.
- Head: low and wide, sunk into the shoulders, a shelf of bracket fungus as a visor over two glowing green eyes, a crown of new shoots.
- Torso: broad barrel-shaped stump with growth rings on the chest, rough bark sides, a collar of moss.
- Arms: thick club-like arms of gnarled root ending in three blunt knuckles.
- Legs: very short and wide, ending in splayed root toes.
- Tail: a stubby root that rests on the ground like a prop.

**Stiltbark**: a tall, nervous wader on birch-twig stilts that can outrun anything in the reeds.
- Head: small and round, a long thin beak shaped like a seed pod, a crest of three curled leaves.
- Torso: small egg-shaped body of pale birch bark with dark horizontal marks.
- Arms: short folded arms ending in three leaf-blade fingers (no feathers).
- Legs: very long, thin, jointed stilts like birch twigs, wide three-toed feet.
- Tail: a short fan of stiff, narrow leaves.

**Mossmitt** (Leaf starter): a cheerful little brawler whose fists are two huge balls of moss.
- Head: round and pebble-grey, big eyes, a wide grin, a clover tuft on top.
- Torso: pear-shaped, a soft moss patch on the belly, bark-brown back.
- Arms: short, ending in oversized round mitts of moss like boxing gloves.
- Legs: short and stubby with flat round feet.
- Tail: a curled fern frond rolled into a spiral.

**Splashjack**: a lanky reed-bed hopper with huge paddle feet that slaps the water to soak whatever it is fighting.
- Head: narrow, with a long flat ladle-shaped bill, two round eyes on top like a periscope, a short crest of reed blades.
- Torso: upright and bean-shaped, smooth wet-looking teal skin, pale belly, a row of dark river-pebble spots.
- Arms: thin, with three long webbed fingers.
- Legs: huge hopping legs with long flat paddle-shaped webbed feet.
- Tail: long and flat like a beaver's paddle, used to slap the water.

**Sizes.** Weights run 77 (Burlhorn) to 50 (Gorsling) on four legs and 67 (Stumpwarden) to 43 (Stiltbark) on two. Every socket and plug radius is a base size times the cube root of the weight (a creature twice as heavy is about 1.26 times as big), and each part's plug equals its own species' socket, so a pure creature fits at scale 1 and every part fits every torso on its plan inside the assembler's 0.6 to 1.6 range (the test checks this). Lengths and radii are planning values until the meshes exist.

## Stats

Budget score = Hp x 0.6 + Attack + Defence + Speed at quality 5. Every species scores 200, the plan budget.

| Species | Base Hp / Atk / Def / Spd | Budget score | Level 15 | Level 50 | Weight |
| --- | --- | --- | --- | --- | --- |
| Burlhorn | 128 / 47 / 39 / 37 | 200 | 217 / 79 / 66 / 62 | 441 / 162 / 134 / 127 | 77 |
| Gorsling | 132 / 40 / 29 / 52 | 200 | 224 / 68 / 49 / 88 | 455 / 138 / 100 / 179 | 50 |
| Spadesnout | 120 / 55 / 38 / 35 | 200 | 204 / 93 / 64 / 59 | 414 / 189 / 131 / 120 | 67 |
| Sloshcalf | 125 / 40 / 33 / 52 | 200 | 212 / 68 / 56 / 88 | 431 / 138 / 113 / 179 | 61 |
| Stumpwarden | 143 / 41 / 36 / 37 | 200 | 243 / 69 / 61 / 62 | 493 / 141 / 124 / 127 | 67 |
| Stiltbark | 142 / 40 / 20 / 55 | 200 | 241 / 68 / 34 / 93 | 489 / 138 / 69 / 189 | 43 |
| Mossmitt | 135 / 40 / 39 / 40 | 200 | 229 / 68 / 66 / 68 | 465 / 138 / 134 / 138 | 50 |
| Splashjack | 125 / 43 / 41 / 41 | 200 | 212 / 73 / 69 / 69 | 431 / 148 / 141 / 141 | 52 |

Level 15 and level 50 are a pure creature at quality 5.

**Burlhorn** (Quad, Leaf)

| Part | Stats | Moves |
| --- | --- | --- |
| Head | Atk 27, Def 16 | Moss Slam (L1), Burl Charge (L9) |
| Torso | Hp 110, Atk 6, Def 5, Spd 3 | Root Lash (L1) |
| Front legs | Hp 8, Atk 11, Def 15, Spd 3 | Twig Snap (L1) |
| Legs | Hp 5, Spd 28 | Puddle Stomp (L1) |
| Tail | Hp 5, Atk 3, Def 3, Spd 3 | Fern Whip (L1) |

Default four moves at level 15: Burl Charge, Root Lash, Fern Whip, Twig Snap

**Gorsling** (Quad, Leaf)

| Part | Stats | Moves |
| --- | --- | --- |
| Head | Atk 27, Def 6, Spd 7 | Seed Shot (L1), Thorn Volley (L10) |
| Torso | Hp 95, Atk 3, Def 14 | Leaf Gust (L1) |
| Front legs | Hp 17, Atk 10, Def 6, Spd 8 | Twig Snap (L1), Bramble Rake (L12) |
| Legs | Hp 5, Spd 34 | Gale Hop (L1) |
| Tail | Hp 15, Def 3, Spd 3 | Pollen Burst (L1) |

Default four moves at level 15: Bramble Rake, Thorn Volley, Leaf Gust, Pollen Burst

**Spadesnout** (Quad, Sand)

| Part | Stats | Moves |
| --- | --- | --- |
| Head | Hp 8, Atk 38 | Grit Spray (L1), Dig Strike (L9) |
| Torso | Hp 90, Def 17 | Dust Kick (L1), Root Lash (L8) |
| Front legs | Hp 22, Atk 14, Def 6, Spd 1 | Scree Kick (L1) |
| Legs | Def 3, Spd 34 | Dust Kick (L1) |
| Tail | Atk 3, Def 12 | Grit Spray (L1) |

Default four moves at level 15: Dig Strike, Grit Spray, Dust Kick, Scree Kick

**Sloshcalf** (Quad, Water)

| Part | Stats | Moves |
| --- | --- | --- |
| Head | Hp 15, Atk 25, Def 3, Spd 3 | Dew Splash (L1), Ripple Ram (L10) |
| Torso | Hp 90, Atk 3, Def 23, Spd 3 | Brook Rush (L1), Mud Slap (L7) |
| Front legs | Hp 5, Atk 12, Def 1, Spd 15 | Dew Splash (L1) |
| Legs | Hp 5, Spd 31 | Puddle Stomp (L1) |
| Tail | Hp 10, Def 6 | Spore Puff (L1) |

Default four moves at level 15: Ripple Ram, Spore Puff, Brook Rush, Mud Slap

**Stumpwarden** (Biped, Leaf)

| Part | Stats | Moves |
| --- | --- | --- |
| Head | Hp 10, Atk 27, Def 4 | Seed Shot (L1), Sap Hammer (L9) |
| Torso | Hp 115, Atk 3, Def 8, Spd 3 | Root Lash (L1) |
| Arms | Hp 13, Atk 11, Def 15, Spd 3 | Moss Slam (L1) |
| Legs | Def 3, Spd 31 | Twig Snap (L1) |
| Tail | Hp 5, Def 6 | Fern Whip (L1) |

Default four moves at level 15: Sap Hammer, Root Lash, Fern Whip, Twig Snap

**Stiltbark** (Biped, Leaf)

| Part | Stats | Moves |
| --- | --- | --- |
| Head | Atk 30, Spd 10 | Seed Shot (L1), Thorn Volley (L10) |
| Torso | Hp 115, Def 11, Spd 3 | Leaf Gust (L1) |
| Arms | Hp 22, Atk 10, Def 3, Spd 8 | Fern Whip (L1), Canopy Drop (L12) |
| Legs | Spd 34 | Gale Hop (L1) |
| Tail | Hp 5, Def 6 | Pollen Burst (L1) |

Default four moves at level 15: Canopy Drop, Thorn Volley, Leaf Gust, Pollen Burst

**Mossmitt** (Biped, Leaf)

| Part | Stats | Moves |
| --- | --- | --- |
| Head | Hp 10, Atk 22, Def 6, Spd 6 | Seed Shot (L1), Thorn Volley (L10) |
| Torso | Hp 110, Atk 3, Def 11, Spd 3 | Moss Slam (L1), Brook Rush (L8) |
| Arms | Hp 10, Atk 15, Def 10 | Twig Snap (L1), Bramble Rake (L10) |
| Legs | Def 3, Spd 31 | Leaf Gust (L1) |
| Tail | Hp 5, Def 9 | Spore Puff (L1) |

Default four moves at level 15: Bramble Rake, Thorn Volley, Spore Puff, Leaf Gust

**Splashjack** (Biped, Water)

| Part | Stats | Moves |
| --- | --- | --- |
| Head | Hp 3, Atk 32, Def 3, Spd 3 | Dew Splash (L1), Ripple Ram (L9) |
| Torso | Hp 100, Def 17, Spd 3 | Brook Rush (L1), Silt Surge (L7) |
| Arms | Hp 17, Atk 11, Def 12, Spd 1 | Puddle Stomp (L1) |
| Legs | Spd 34 | Dew Splash (L1) |
| Tail | Hp 5, Def 9 | Spore Puff (L1) |

Default four moves at level 15: Ripple Ram, Silt Surge, Spore Puff, Brook Rush

## Moves

24 moves: 12 Leaf, 6 Sand, 4 Water, 1 Storm, 1 Toxic. Power 35 to 70. No status effects (they arrive with the Mire). Every part's first move is known from level 1; second moves unlock at 7 to 12.

| Move | Type | Power | Brought by |
| --- | --- | --- | --- |
| Moss Slam | Leaf | 35 | Burlhorn head L1; Stumpwarden arms L1; Mossmitt torso L1 |
| Seed Shot | Leaf | 35 | Gorsling head L1; Stumpwarden head L1; Stiltbark head L1; Mossmitt head L1 |
| Fern Whip | Leaf | 40 | Burlhorn tail L1; Stumpwarden tail L1; Stiltbark arms L1 |
| Twig Snap | Leaf | 40 | Burlhorn front legs L1; Gorsling front legs L1; Stumpwarden legs L1; Mossmitt arms L1 |
| Pollen Burst | Leaf | 45 | Gorsling tail L1; Stiltbark tail L1 |
| Leaf Gust | Leaf | 50 | Gorsling torso L1; Stiltbark torso L1; Mossmitt legs L1 |
| Root Lash | Leaf | 50 | Burlhorn torso L1; Spadesnout torso L8; Stumpwarden torso L1 |
| Sap Hammer | Leaf | 55 | Stumpwarden head L9 |
| Thorn Volley | Leaf | 55 | Gorsling head L10; Stiltbark head L10; Mossmitt head L10 |
| Bramble Rake | Leaf | 60 | Gorsling front legs L12; Mossmitt arms L10 |
| Burl Charge | Leaf | 60 | Burlhorn head L9 |
| Canopy Drop | Leaf | 60 | Stiltbark arms L12 |
| Dust Kick | Sand | 45 | Spadesnout torso L1; Spadesnout legs L1 |
| Scree Kick | Sand | 45 | Spadesnout front legs L1 |
| Grit Spray | Sand | 50 | Spadesnout head L1; Spadesnout tail L1 |
| Mud Slap | Sand | 55 | Sloshcalf torso L7 |
| Dig Strike | Sand | 65 | Spadesnout head L9 |
| Silt Surge | Sand | 65 | Splashjack torso L7 |
| Puddle Stomp | Water | 40 | Burlhorn legs L1; Sloshcalf legs L1; Splashjack arms L1 |
| Dew Splash | Water | 45 | Sloshcalf head L1; Sloshcalf front legs L1; Splashjack head L1; Splashjack legs L1 |
| Brook Rush | Water | 50 | Sloshcalf torso L1; Mossmitt torso L8; Splashjack torso L1 |
| Ripple Ram | Water | 70 | Sloshcalf head L10; Splashjack head L9 |
| Gale Hop | Storm | 50 | Gorsling legs L1; Stiltbark legs L1 |
| Spore Puff | Toxic | 65 | Sloshcalf tail L1; Mossmitt tail L1; Splashjack tail L1 |

Where coverage sits is a balance tool, not decoration:
- **Anti-Leaf coverage on Water torsos only** (Mud Slap on Sloshcalf, Silt Surge on Splashjack). A torso move always comes with the torso's type, so a Water creature can fight back against Leaf, but a Leaf hybrid cannot borrow the move to bully other Leafs.
- **Anti-Sand coverage on Leaf parts** (Puddle Stomp, Gale Hop, Brook Rush on Mossmitt's torso), so Leaf builds can answer Spadesnout.
- **Spore Puff (Toxic)** previews the Mire and gives Water creatures a way through Water mirrors.

## Balance gate: measured results

How the test works: every combination of parts on a plan (4 species, 1,024 builds), at quality 5. A fixed field of 160: every pure species, the five best by Hp, Attack, Defence, Speed and total, then a random sample (seed 2026). Every pair fights twice with sides swapped (25,440 fights per run), ranked rules (no variance), the game's default move choice and opponent. Draws count half.

| | Best build | Pure species | Top ten torsos / leg sets |
| --- | --- | --- | --- |
| Four-legged, level 15 | 68% Sloshcalf/Gorsling/Spadesnout/Gorsling/Spadesnout | Sloshcalf 56, Spadesnout 55, Burlhorn 50, Gorsling 47 | 4 / 4 |
| Four-legged, level 50 | 69% Burlhorn/Sloshcalf/Gorsling/Spadesnout/Gorsling | Spadesnout 60, Burlhorn 59, Sloshcalf 54, Gorsling 49 | 3 / 3 |
| Two-legged, level 15 | 65% Mossmitt/Stiltbark/Stumpwarden/Mossmitt/Mossmitt | Mossmitt 58, Stumpwarden 53, Stiltbark 53, Splashjack 51 | 4 / 3 |
| Two-legged, level 50 | 74% Splashjack/Mossmitt/Mossmitt/Mossmitt/Mossmitt | Mossmitt 70, Stumpwarden 54, Stiltbark 54, Splashjack 53 | 3 / 2 |

Builds are head/torso/front limbs/legs/tail. Next best, four-legged level 15: 67% Sloshcalf/Gorsling/Burlhorn/Gorsling/Spadesnout, 65% Gorsling/Sloshcalf/Sloshcalf/Spadesnout/Burlhorn. Four-legged level 50: 68% Burlhorn/Sloshcalf/Spadesnout/Spadesnout/Spadesnout, 68% Spadesnout/Gorsling/Burlhorn/Spadesnout/Sloshcalf. Two-legged level 15: 65% Mossmitt/Stiltbark/Stumpwarden/Mossmitt/Splashjack, 63% Stiltbark/Splashjack/Stiltbark/Splashjack/Mossmitt. Two-legged level 50: 74% Splashjack/Mossmitt/Mossmitt/Mossmitt/Splashjack, 73% Splashjack/Mossmitt/Stiltbark/Mossmitt/Mossmitt.

**Pass marks:** no build above 75% (pass, all four); every pure species at least 40% (pass, lowest 47%); top ten with at least two torsos and two leg sets (pass). Mixing is worth doing (most top builds are hybrids) but never decisive, and pure species stay competitive.

**Battle length.** 3v3 between random wild teams (400 battles, wild qualities 3 to 7, the small PvE variance): **12.7 turns at level 50** (9 to 17), pass. **7.3 turns at level 15** (6 to 10), below the 8 to 14 target. See the known gap below. A 1v1 lasts 2.1 to 2.5 turns at level 15 and 3.8 to 4.7 at level 50.

**How robust this is** (scratch runs, not in the test):
- Every one of the 1,024 builds against the gate field, not just the 160 in it: no build passes 75% on two legs or at level 15 on four legs. At level 50 on four legs three builds outside the field reach 75 to 77% (best: Spadesnout/Sloshcalf/Spadesnout/Spadesnout/Sloshcalf, 77%).
- Nine other fields (160, 200 and 300 builds, three seeds): best build 65 to 78%, lowest pure species 41 to 54%. The two-legged level-50 top is 73 to 75%, the four-legged level-50 top 69 to 78%. So the gate passes on its fixed field, and the honest range is "best build about 70 to 78%".

## How the roster was designed, and why the placeholders failed

1. **Hp was far too cheap.** Under this damage formula a fight is won by whoever needs fewer hits, so Hp counts in full while Attack, Defence and Speed each count only about half as much (Attack and Defence work through Attack / (Attack + Defence); Speed through first strike and Tempo). A scan of 455 stat shapes at a fixed budget showed the best shape spends about 40% of its budget on Hp, about 3.3 Hp for each point of another stat. At the old weight of 0.25, Hp cost a quarter of a point, so the creature with the most Hp almost always won: the placeholder tank torso. Pricing Hp at 0.6 makes the budget score match what a stat is worth in a fight, and every species now sits near the efficient shape with a tilt for its role, rather than at an extreme.
2. **Speed edges were knife-edge.** With fights of 2 to 5 hits, any creature 10% faster struck first whenever both needed the same number of hits, so the slowest roles lost almost every even fight. A wider Speed band (35%) makes small leads mean simultaneous moves, while Tempo still rewards real speed.
3. **Light torsos got free Speed.** With a fit ceiling of 1.15, any heavier legs on a light torso ran 15% faster, so sprinter torsos topped every chart. A ceiling of 1.0 keeps the brief's penalty (light legs on a heavy body are slow) without the free bonus.
4. **Near-equal budgets per part.** Each slot scores about the same in every species (head 37 to 43, torso 71 to 83, front limbs 31 to 37, legs 31 to 37, tail 9 to 15), so "the best part from every species" adds up to little more than one species. A hybrid mostly reshapes its stats rather than exceeding the budget.
5. **Types and coverage do the rest.** Each plan has all its types fighting each other, with coverage placed as above, so every strong build has a counter in the field.
6. Then the numbers (part stats, move powers, weights and the config numbers below) were tuned by a seeded hill-climbing search against the gate on several fields at once, keeping each part within the brief's mapping (head and front limbs mostly Attack, torso mostly Hp and Defence, legs mostly Speed). Two lessons from it: a Defence-and-slowness tank loses; the tank that works carries Hp. And a plan with three Leaf species and one other type is the hardest to balance (the lone Water biped needed its torso-only Silt Surge).

## Config numbers changed

| Number | Was | Now | Evidence |
| --- | --- | --- | --- |
| `BattleConfig.SPEED_BAND` | 0.10 | 0.35 | Reverting it alone on the final roster: best build 76 to 87% (fails), two-legged pure species down to 32 to 40% (fails). The biggest single lever. The 1% Speed test in `battle.test` still passes |
| `BreedConfig.FIT_MAX` | 1.15 | 1.00 | Reverting it alone: two-legged level-50 best build 76 to 79% (fails) |
| `BreedConfig.BUDGET_HP_WEIGHT` | 0.25 | 0.6 | Re-prices Hp to its measured worth in a fight (point 1 above). It changes no battle result; it makes the budget score, and the 5% budget check, mean something. At 0.25 these species would score 4 to 9% under the old budget of 165, so the check would fail creatures that are in fact balanced |
| `BreedConfig.PLAN_BUDGET` (all four plans) | 165 | 200 | Rescaled with the Hp weight so that no placeholder build reaches the 1.15 cap; `breeding.test` gives the same numbers as before |

All four together, reverted: best build 77 to 92%, pure species as low as 26%. Not changed: `DAMAGE_SCALE`, `TEMPO_GAIN`, `TEMPO_POWER` (Tempo changes made no measurable difference), `PVE_VARIANCE_MIN`, `BUDGET_CAP`, `FIT_MIN`, `LEVEL_SCALE_PER_LEVEL`. `battle.test` and `breeding.test` pass (placeholder 3v3 9.7 turns; best hybrid +6.6%, as before).

## Known gap: battle length at level 15

Under the current rules damage does not grow with level but Hp does, so the same teams fight about 40% shorter battles at level 15 than at level 50 whatever the roster. Measured on this roster: 7.3 turns at level 15 against 12.7 at level 50. No `DAMAGE_SCALE` puts both in 8 to 14 (2.2 gives 7.9 and 14.3; 2.1 gives 8.2 and 14.8). The test enforces level 50 and prints level 15 as a note.

**Smallest rule change that closes it** (proved on a private copy, not applied): in `src/shared/Battle.luau`, store the level a fighter's stats were worked out at (`level: number` on `Fighter`, set to `level or creature.level` in `Battle.fighter`), and multiply damage in `Battle.previewDamage` by `Stats.levelScale(attacker.level)`; then set `DAMAGE_SCALE` to 0.95. Measured with this roster: a 3v3 lasts 11.9 turns at level 5, 10.2 at level 15 and 10.2 at level 50, and the whole gate still passes (best builds 67 to 72%, lowest pure species 50%). Two cautions: at `DAMAGE_SCALE` 0.85 to 0.90 the four-legged best build rises to 76 to 80%, so the roster would need a re-check if this is adopted; and a higher-level attacker would hit harder as well as having more Hp, so level gaps against wild creatures and giants grow (the giant and tamer tuning would need a pass). `battle.test`'s placeholder pacing would also need its own scale.

## Open questions for Ayrton

1. **Five Leaf, two Water, one Sand.** "Mostly Leaf" forces one plan to have three Leaf species; I paired them with Water (Splashjack), which balanced better than a second Sand. That means the only Sand creature in Greenwood is the Sand starter. Happy with that, or would you rather swap Splashjack for a Sand biped and accept a harder balance problem?
2. **The level-15 battle length rule change** above: adopt it (and re-tune giants and tamers), or accept shorter battles before the first badge?
3. **Starters in the wild**: I have made all three catchable as ordinary commons in one spot each. The alternative is to keep the two you did not pick for a later quest.
4. **Uncommons**: Burlhorn and Stiltbark. Any preference?
5. **Names**: all eight names and the 24 move names are placeholders I believe are original; a quick check against other games before art is commissioned would be wise.
6. **Untested here**: quality pips other than 5, the size gene, rarity boosts and a smarter battle AI (the gate uses the default "strongest four moves, best damage now" choice; a player who picks coverage moves may find different best builds). Retest after the art gives real weights and after the battle AI lands.
