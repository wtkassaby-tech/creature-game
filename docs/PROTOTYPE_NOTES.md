# Breeding and battle prototype (working code)

Real Luau for the breeding system in `../BREEDING_PLAN.md`. The rules and maths run and are tested here under Lune; the two Roblox-side files are written against documented APIs but have not been run in Studio yet.

| File | What it does | Tested here |
| --- | --- | --- |
| `shared/Types.luau` | Creature and species record types | Used by all tests |
| `shared/Species.luau` | Three example four-legged species: Mossback (heavy tank), Dartlet (light sprinter), Brindle (all-rounder) | Yes |
| `shared/BreedConfig.luau` | Every breeding number: quality gene, fit clamp, rarity odds, Breeding Candy prices, cooldowns, hatch times, costs, colours | Yes |
| `shared/Rng.luau` | Seeded random numbers, identical under Lune and Roblox, so any breed can be replayed from its seed | Yes |
| `shared/Stats.luau` | Stats from parts: base x quality x fit, the shared stat budget, then level and rarity | Yes |
| `shared/Breeding.luau` | Who can breed, cost, rarity odds, the preview, and the roll itself | Yes |
| `shared/AssemblyMath.luau` | How much to scale a donor part to fit a torso socket; ride height | Yes |
| `server/BreedingService.luau` | The server's breed request: validate, check ownership and locks, roll from a logged seed, change coins, parents and eggs together | Not run (needs Roblox) |
| `client/Assembler.luau` | Builds the model: clone part templates, scale to the socket, join with Motor6D, colour, size | Not run (needs Roblox and part meshes) |
| `tests/run.luau` | Breeding: two worked examples and five simulations | 29 checks pass |
| `shared/TypeChart.luau`, `shared/Moves.luau`, `shared/BattleConfig.luau` | The ten-type chart, example moves and battle numbers | Yes |
| `shared/Battle.luau` | Turn-based battle core: both sides choose, switches first, moves in Speed order, the Speed band, the Tempo meter, draws, a simple opponent, replay from a seed | Yes |
| `tests/battle.luau` | Battle: chart checks, a 3v3 worked example, pacing, the Speed-edge test and a 243-build tournament | 10 checks pass |

Run the tests from this folder: `lune run tests/run.luau` and `lune run tests/battle.luau`. Formatting follows the repo's StyLua config. Selene could not run in the cloud session (it needs to download Roblox's API list).

## Worked example 1: the brief's small mother and big father

Mother: a Dartlet (weight 20, leg Speed 80). Father: a Mossback (weight 90). Levels 50 and 45, all parts at quality 5.

- A child with the father's torso and the mother's legs: fit = sqrt(20 / 90) = 0.47, clamped to **0.60**, so the legs give **80 x 0.60 = 48 Speed**.
- The legs are drawn **1.6x bigger** to fill the Mossback's leg sockets, and the body rides 2.4 studs off the ground.
- Child level: 40% of 47.5, rounded down = **19**. Cost: 400 coins and 1 Breeding Candy (two commons from biome 1, first breed each).
- The preview's stat range across all 32 part combinations at level 19: HP 133-228, Attack 64-79, Defence 45-102, Speed 64-163.

## Worked example 2: one breed, as the server runs it

```
A      Head=Brindle:6 Torso=Brindle:5 FrontLimbs=Brindle:3 Legs=Brindle:3 Tail=Brindle:3     (Uncommon, level 20)
B      Head=Dartlet:7 Torso=Dartlet:6 FrontLimbs=Dartlet:5 Legs=Dartlet:6 Tail=Dartlet:5     (Common, level 18, carries Ember)
charm  Legs, favouring B (80/20)

child  Head=Dartlet:6 Torso=Brindle:5 FrontLimbs=Dartlet:5 Legs=Dartlet:6 Tail=Brindle:3
       level 7, Uncommon, size 1.02, colour Moss (carries Ember), generation 1
       HP 125  Atk 50  Def 45  Spd 69
       moves to choose from: Nip, Leaf Dart, Shake Off, Quick Jab, Dash, Lash
       cost 600 coins and 2 candies; hatches in 45 min; parent A rests 30 min
```

The number after each part is its quality (0-10). The child's head came from B and dropped one pip (7 to 6); its torso and tail came from A. It carries B's hidden Ember colour, which will show only if a later mate also passes on Ember.

## What the simulations show

| Simulation | Result |
| --- | --- |
| Always keep the best of 8 children for 50 generations, 300 family lines, candy and kin rules ignored | Totals rise from 838 to 934 on average; the highest ever is 1,014 against a ceiling of 1,144. Stats improve and never run away |
| Same parts reached by 200 different histories | Identical stats every time |
| 200 creatures mating at random for 100 generations | Average quality stays near 5; never outside 0-10 |
| 40,000 breeds per rarity pairing | Odds match the config within 1 point. A rare child costs 12 (first gem tier), 30 (Ruby) or 100 (Diamond) candies on average, so supply follows play time |
| All 243 part combinations of the three species | The best hybrid beats the best pure species by 6.6%, inside the 15% budget cap |

**Why there is a stat budget:** with only three example species the best hybrid looks modest. An independent stress test on eight species (`../research/market/09_BREEDING_STRESS_TEST.md`) found that "the best part from every species" beat every pure species by 44%. The shared budget (at most 1.15 times the body plan's budget) and the 0.6-1.15 fit clamp hold any mix to +15%.

## Battle core: what it does and what it measured

```
damage = 2.5 x power x Attack / (Attack + Defence) x type (1.5, 1 or 0.67) x own-type (1.2)
```

No misses and no critical hits. Fights against the game vary damage by up to 4%; ranked has none, so the number on the move button is exact.

**What Speed is worth.** With strict "faster goes first", a creature just 1% faster won 100% of mirror matches, and beyond that first strike Speed was worth nothing. Two rules replace it:

1. **Speed band:** when the two Speeds are within 10% of each other, both moves land together. A hair's-breadth edge gives nothing; outside the band the faster side goes first.
2. **Tempo:** each turn the faster creature fills a meter by (its Speed / the other's - 1). When full, it strikes again at half power. Twice as fast means an extra half-strike every turn; 1% faster means one after a hundred turns.

With both rules, the 1% faster creature wins 0% of mirrors: they are draws.

| Measurement | Result |
| --- | --- |
| 3v3 between random teams, 500 battles | 9.7 turns on average (6 to 13); the research target was 8 to 14 |
| 1v1 between pure species | 2.9 turns |
| Same seed and same choices | The battle replays exactly |
| Type chart | Every type beats two and loses to two; no pair beats each other; Leaf, Water and Sand form a triangle |

**An open problem the tournament exposed.** Every one of the 243 part combinations fought every other. The best hybrids won 92-94% of their fights (98% with type match-ups switched off), the best pure species 84%, and the pure sprinter (Dartlet) only 8%. Changing the budget weights did not move this. Two causes: the three example species are placeholders that were never balanced against a battle formula, and two of them share a type that the third beats. So the stat budget alone does not guarantee variety. The real roster needs this tournament run as a gate, with a rule such as "no build wins more than about 75%, and every pure species wins at least 40%", before art is made for it.
