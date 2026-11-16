# Breeding: independent stress test of the proposal

Date: 15 November 2026
Status: research, nothing decided. Reviews `04_BREEDING_DESIGN.md` (the proposal) against brief sections 4 and 7 and `DECISIONS.md`. I did not write the proposal.

## Summary

- **The core idea holds.** A bounded quality gene (0 to 10 pips, pulled toward the middle) and a fit factor derived at assembly and never stored stop both ratchets in the brief's formulas. Under the brief's formulas a best-pair breeder gains ×1.40 (one species) to ×1.53 (mixed roster) by generation 50 and keeps climbing; the stored weight factor turns Speed 80 into 457. Under the proposal nothing leaves the 0-10 range or passes the computed ceiling, and stats depend only on the parts (all tested).
- **Five things break.**
  1. **Part mixing, not quality, decides power, and the fit factor does not stop it.** Taking the best part of each species gives a build 44% above the best pure species. That build wins 96% of duels against a field of 105 builds; the best pure species wins 41%. The 0.85 floor means a heavy torso on tiny fast legs loses only 15% Speed.
  2. **The size gene is undefined and free.** It only feeds the fit, so smaller is always faster with no cost.
  3. **Rare supply is linear, not exponential, but it is not scarce.** With the proposal's limits and odds, two in three gem creatures come from breeding (R measured 0.64 to 0.67). By day 180, 18% to 34% of all creatures are gem tier, depending on the wild spawn rate.
  4. **The cost curve, not the cooldowns or pens, sets the pace, and it starves casual players.** A casual player gets a first breed on day 4 and 5 breeds in week 1. Extra pens change nothing, because cooldowns, pens and hatch timers never bind.
  5. **The level and biome rules have holes.** Parents at levels 1 to 3 give a level 0 child. A traded level-60 Greenwood creature passes the biome rule and is ×3.2 a Greenwood giant. Checking only the torso's biome lets late-biome parts into early play, and halves the breeding cost.
- **The proposal's chase estimate is wrong.** It says a perfect creature takes a median of 268 breeds. With breed limits and the kin rule I measured 700 to more than 2,500, depending on how many fresh wild catches feed the line. A pull of 15% (not 20%) and the Bond Charm bring it to 370 to 860.
- **Quality pips look small but decide equal fights.** A perfect creature is only 5% above an average one. In a mirror duel, though, +2.5% wins 81% and +5% wins 99%. Under a strict Speed turn order, +1% wins 97%. Breeding is not pointless; the battle system has to stop one Speed pip deciding fights.
- **Recommended rule set (section 6).** Keep the gene. Pull at 15%. Fit clamp 0.60 to 1.15. One shared stat budget per body plan, so a hybrid can be at most 15% above the species budget. Size also scales torso HP and Defense. Breed limit 2 for every gem tier, with odds of 40%, 40% and 30% for pure pairs and 10%, 8% and 5% with one parent. Base cost 400 with a gentler count curve. Common hatch 30 minutes. Level floor 1 and a per-player level cap. A creature's biome is its latest part's biome. Wild Gem1 spawn about 0.025 per hour of play.
- **What the recommended rules measure.** By day 180, gem tier is 4.1% of creatures and the count is flattening. Owning one by day 30: casual 9%, regular 39%, hardcore 74%; by day 90: 29%, 78% and 100%. A casual player does 13 breeds in week 1 with a best creature 9% above their best catch. A hardcore player reaches an average of 9.2 pips after a month, but a perfect creature takes them 6 to 10 months. All 15 invariant tests pass (`breedsim/tests.py`).

## 1. Method and limits

All numbers below come from my own seeded Python simulations in `breedsim/` (seed 20261115, run with `python3 -I`). The raw output of every run is in `breedsim/results/`. Nothing here is from the web.

**Model (assumptions, not facts):**

| Item | Value used | Why |
| --- | --- | --- |
| Roster | 8 species on the four-legged plan, biomes 1-3, weights 8 to 300, each with a budget of 300 over HP, Attack, Defense and Speed, plus a tail bonus of 30 to its best stat (`common.py`: Mossbun light sprinter, Stumpback heavy tank, Thornfox balanced, Burrowbear heavy bruiser, Dunestrider heavy with fast legs, Scuttlejaw glass cannon, Shellback heaviest tank, Reefdart light and quick) | Brief section 4: about 8 per biome, at least two body plans; equal budgets so only the mixing is tested |
| Part to stat | Head and front limbs half the Attack each, torso HP and Defense, legs Speed, tail a small bonus | Brief section 4 suggested mapping |
| Level scale | (level + 10) / 60, so level 50 = 1.0 | No formula in the brief; only used in sim 4 |
| Activity | Casual 20 min a day (one session), regular 60 min (two), hardcore 180 min (three); 50/35/15% of players; 15% buy Gem pens | Task brief; typical Roblox mix |
| Coins | 100 coins per minute of play × biome tier; casual and regular spend 50% on breeding, hardcore 60% | Units only: every cost is reported in minutes of income too |
| Progress | Biome 2 after 3 h of play, biome 3 after 6.9 h (×1.3 per biome); 3 catches an hour; wild quality 3-7 | Brief section 3 |
| Storage | 60 creatures (120 for Gem buyers); the least valuable is released when full | Not in the brief |
| Retention (open runs) | 40% quit in week 1, 25% more by day 30, 15% more by day 90, 20% stay | Rough Roblox norm |
| Duel model | Turn order by Speed; damage = Attack × 100/(100 + Defense) × roll 0.85-1.0; a slower defender can dodge up to 25%; HP × 2. A second "ratio" damage formula (Attack × Attack/Defense) is checked too | The real battle system does not exist yet. Types and moves are not modelled |

**Limits.** The roster, battle maths and player behaviour are invented, so absolute numbers will move. What should carry over is the shape: which lever matters, where growth turns from linear to exponential, and which loopholes exist. Wild spawn rate is the biggest unknown, so every supply result is given at two or three rates. Players are modelled as rational breeders who always use their best pair. Real players are less efficient, so supply results are an upper bound.

## 2. Stat progression (sim 1)

### 2.1 The brief's original formulas

A player breeds their best eligible pair, keeps every child (pool of 30) and has a breed limit of 5. There is no kin rule. Results are 200 runs, the best creature against the best founder, as median (p10 to p90).

| Generation | One species | Mixed roster, weight factor stored | Mixed, per-stat ceiling at 1.25 × best part |
| --- | --- | --- | --- |
| 5 | ×1.04 (1.02-1.07) | ×1.11 (1.04-1.22) | ×1.10 |
| 10 | ×1.07 (1.05-1.11) | ×1.15 (1.07-1.26) | ×1.13 |
| 20 | ×1.15 (1.10-1.20) | ×1.23 (1.14-1.36) | ×1.20 |
| 50 | ×1.40 (1.32-1.49) | ×1.53 (1.38-1.70) | ×1.39 (still climbing) |

The adversarial weight walk reproduces the proposal's finding: Speed 80 becomes 653 after eight steps down and 457 after one step back up. **Confirmed: both brief formulas ratchet.** A per-stat ceiling only moves the problem: everyone ends on the cap.

### 2.2 The proposal (count only, no clock)

One species, best pair, breed limit 5, pool of 30, no new wild catches; 200 runs; median (p90).

| Variant | Best mean pips at gen 5 / 10 / 20 / 50 | Breeds to mean 8 pips | to 9.5 | to 10 (perfect) |
| --- | --- | --- | --- | --- |
| Proposal (pull 20%), kin rule | 6.4 / 6.8 / 7.4 / 8.6 | 79 (132) | 396 (1,503) | not reached in 2,500 (median) |
| Proposal, no kin rule | 6.2 / 6.6 / 7.4 / 8.6 | 76 (124) | 568 (1,695) | not reached in 2,500 |
| Proposal + Bond Charm every breed | 6.6 / 6.9 / 7.7 / 9.2 | 54 (79) | 198 (327) | 620 (1,626) |
| **Pull 15%** | 6.4 / 6.6 / 7.2 / 8.8 | 84 (128) | 304 (528) | 860 (2,204) |
| **Pull 15% + Bond Charm** | 6.6 / 7.0 / 7.8 / 9.2 | 53 (79) | 185 (294) | 370 (812) |
| No pull (flat 10% up, 10% down) | 6.6 / 7.0 / 7.8 / 9.8 | 43 (77) | 110 (177) | 150 (221) |

What this shows:

- **No ratchet; it plateaus where intended.** Gains slow as quality rises, because the pull to the middle grows. Without the pull, a perfect creature takes only 150 breeds: the pull is doing its job.
- **At 20% the pull is too strong.** The proposal's "median 268 breeds" does not reproduce; a closed line does not reach perfect in a median of 2,500 breeds. A perfect pair passes all five slots unchanged only 0.8^5 = 33% of the time, so the top is unstable. At 15% the chase is long but finishable.
- **The kin rule barely slows selection** (76 against 79 breeds to 8 pips). Half-siblings stay legal, and that is enough.
- **"Percent of the ceiling" is the wrong yardstick.** An all-5-pip wild creature already sits at 95.2% of its stat ceiling (330 of 346.5), all-8 at 98.1%, all-10 at 100%. So 80% and 95% of the stat ceiling cost **zero breeds**. Below I read the targets as 80%, 95% and 100% of the gene range: a mean of 8, 9.5 and 10 pips on the best creature.

### 2.3 With the clock: breeds, coins and days

The player breeds one species line with real sessions, cooldowns, hatch timers, pens, coins and wild catches feeding in (60 runs, 365 days). Coins are also shown in minutes of biome-3 income at full spend (300 coins a minute).

**Proposal** (base 1,000, count multipliers 1, 1.5, 2.5, 4, 6.5, common hatch 10 min):

| Player | Mean 8 pips | Mean 9.5 pips | Perfect |
| --- | --- | --- | --- |
| Casual, 2 pens | day 172; 66 breeds; 512k coins (1,706 min) | not within a year (0/60) | not within a year |
| Regular, 2 pens | day 59; 70 breeds | day 315 (35/60 within a year); 331 breeds | 3/60 within a year |
| Hardcore, 2 pens | day 16; 69 breeds; 518k | day 76; 297 breeds; 2.4M | day 200 (52/60); 728 breeds; 6.5M (21,538 min) |
| Hardcore, 4 pens | day 17 | day 81 | day 196 |

**Recommended rules** (section 6):

| Player | Mean 8 pips | Mean 9.5 pips | Perfect |
| --- | --- | --- | --- |
| Casual, 2 pens | day 120; 189 breeds; 360k | 5/60 within a year | 1/60 within a year |
| Regular, 2 pens | day 53; 212 breeds | day 337 (33/60 within a year) | 4/60 within a year |
| Hardcore, 2 pens | day 18; 222 breeds | day 102; 1,218 breeds; 2.4M | day 300 (38/60 within a year); 3,594 breeds; 7.1M (23,590 min) |
| Hardcore, 4 pens | day 12 | day 74 | day 186 (55/60) |

What this shows:

- **Under the proposal every player is limited by coins, not time.** A best pair has always bred a few times, so its count multiplier is 2.5 to 6.5. The casual player can afford about 0.36 breeds a day over a year. Four pens give a hardcore player nothing (196 against 200 days), so the Gem pen product would be worthless.
- **Under the recommended rules the limit is hatch time and pens.** That is fairer and is what extra pens sell: 4 pens bring the perfect creature forward from day 300 to 186. Paying buys time, not a result, which `DECISIONS.md` already allows.
- With fresh wild catches feeding in, the clocked chase (700 to 3,600 breeds) differs from the closed line in 2.2. The real number depends on how many wild catches a player screens, so the Lune test (section 8) should fix the pool size.

## 3. Fit factor and dominant builds (sim 2)

All 8^5 = 32,768 part combinations on one body plan, at quality 5 and level-free. The duel field is the top 40 by total, the 8 pure species, the top 10 for each stat and 30 at random (103 to 118 builds), with 40 fights per pairing.

| Rule | Best total (build: head/torso/front/legs/tail) | Worst | Best pure | Hybrids >12% above best pure | Top build's mean duel win | Best pure's mean win |
| --- | --- | --- | --- | --- | --- | --- |
| No fit at all | 495.0 | 220.0 | 330 | 7,904 | not run | not run |
| Brief clamp 0.7-1.3, derived | 456.0 | 229.0 | 330 | 6,336 | 97% | 40% |
| **Proposal** clamp 0.85-1.15 | **475.5** Scuttlejaw/Stumpback/Scuttlejaw/Mossbun/Mossbun | 224.5 | 330 | **6,712 (+44% best)** | **96%** | **41%** |
| Proposal, size gene 0.8 | 475.5; Mossbun pure rises 330 → 345 | | | 4,704 | | |
| Cap 1.05, clamp 0.6-1.15, size scales torso | 346.5 | 224.5 | 330 | 0 (+5%) | 99% | 93% |
| Cap 1.10 | 363.0 | 224.5 | 330 | 0 (+10%) | 97% | 79% |
| **Cap 1.15 (recommended)** | 379.5 | 224.5 | 330 | +15% at most | 96% | **72%** |

With the ratio damage formula, the proposal's top build still wins 95% against 39% for the best pure species. Under cap 1.10 the best pure species wins 68%.

Findings:

- **One build dominates under the proposal.** It is the "best part from every species" chimera: a Stumpback torso for HP and Defense, Scuttlejaw head and front limbs for Attack, and Mossbun legs for Speed. The fit penalty for 8-weight legs on a 220-weight torso should be ×0.19; it is clamped to ×0.85, so the build keeps Speed 110. The top four builds in duels are all this chimera. With equal species budgets, any per-slot best-of mixing beats every pure species. Proposed test 7 ("no hybrid more than 12% above the best pure") fails by 32 points.
- **Weight choices are only half exploitable.** Heavy, fast legs on a light torso gain the full +15% (Dunestrider legs on a Thornfox torso give the top Speed of 173 under the brief clamp). Light legs on a heavy torso lose only 15%. The floor is what makes the chimera free.
- **The size gene is free power.** The proposal multiplies body weight by a size gene but nothing else reads size. A small body is always faster (Mossbun pure goes from 330 to 345 at size 0.8). Every player would breed for minimum size.
- **The fix is a shared stat budget.** Every assembled body gets the same budget: base stats are scaled down when they exceed 1.15 × the species budget, before quality. With it, no hybrid is more than 15% above a pure species. The top five duel builds now show four different shapes (an Attack and Defense tank in two tail variants, a balanced build, a high-HP build and a faster balanced build), and the best pure species rises from 41% to 72%. Mixing is still worth up to 15%, so the Locked "continuous improvement" holds.
- **One duel-model warning.** Once the budget is capped, the best builds drop Speed (as low as 23), because turn order alone makes Speed weak. The reverse also holds: in a mirror, +1% to every stat wins 97% purely by moving first. **The battle system must give Speed a value beyond strict turn order** (for example, ties broken by a roll, or initiative bands) **and be tested with this enumeration.** That is outside breeding but decides whether quality pips feel fair.

## 4. Population and rarity supply (sim 3)

Two models were used. The **full model** runs 300 players (or 600 joining over 180 days, with churn) through `engine.py`, with everything included. The **grid model** follows gem creatures only and is fast enough to sweep limits and odds (300 players, 180 days, 3 seeds each). Both include a trading market in which half of the players holding a lone fertile gem creature find a mate from another player each day.

### 4.1 The proposal

| Run | Gem1 held at day 30 / 90 / 180 (per player) | Share of all creatures at day 180 | Bred : wild | R measured | Own one at day 30 (casual / regular / hardcore) |
| --- | --- | --- | --- | --- | --- |
| Wild 0.05 an hour, closed 300 | 2.71 / 11.15 / 23.38 | **33.5%** | 2.0 | 0.67 | 21 / 54 / 88% |
| Wild 0.025 an hour, closed 300 | 1.33 / 5.78 / 12.53 | 18.0% | 1.8 | 0.65 | 6 / 31 / 65% |
| Wild 0.05, open population with churn | 0.60 / 4.07 / 7.38 | 12.9% | 1.5 | 0.60 | 3 / 9 / 67% |

The growth is **linear, not exponential**: the day 90-180 gain matches the day 30-90 gain per day. That fits theory, with R = (3/2) × 0.5 = 0.75 before the kin rule and coin limits. But breeding triples the supply, and at the proposal's rates a third of all creatures are "rare" by month 6.

### 4.2 Where growth turns exponential (grid model, wild 0.05 an hour)

| Breed limit B | Pure odds | Bred : wild | Per player at day 180 | Growth in the second half (1.5 = linear) |
| --- | --- | --- | --- | --- |
| 1 | 30-60% | 0.10-0.20 | 9.3-10.3 | 1.44-1.53 |
| 2 | 40% | 0.34-0.50 | 11.4-12.5 | 1.44-1.48 |
| 2 | 60% | 0.51-0.74 | 12.7-14.8 | 1.41-1.47 |
| 3 | 50% (the proposal) | 1.12-1.71 | 17.8-22.3 | 1.44-1.60 |
| 3 | 60% | 2.31-3.46 | 28-38 | 1.65-1.71 |
| 4 | 50% | 4.6-6.3 | 47-61 | **2.06-2.18** |
| 5 | 40% | 4.3-6.3 | 45-62 | **2.01-2.19** |
| 5 | 60% | 11.0-13.2 | 102-119 | **2.03-2.11** |

The boundary sits where (B/2) × pure odds reaches about 1, plus B × single odds from lone breeds: B = 4 at 50%, B = 5 at 40%. The proposal (B = 3, 50%) is safely linear but makes 1.1 to 1.7 bred creatures for every wild one. **The wild spawn rate sets the level; the breed rules set the multiplier.** Bred : wild hardly moves when the wild rate is halved or doubled (0.35 against 0.38 in 4.3).

### 4.3 The recommended rules (B = 2, 40% / 10%, wild 0.025 an hour)

Full model, closed 300, 1% a day of spent gem creatures removed through fusion, imprint or release:

| Day | Held per player | Share of creatures | Bred : wild | Own one (casual / regular / hardcore) |
| --- | --- | --- | --- | --- |
| 7 | 0.11 | 0.3% | 0.14 | 0 / 7 / 26% |
| 30 | 0.74 | 1.1% | 0.29 | 9 / 39 / 74% |
| 90 | 1.89 | 2.7% | 0.31 | 29 / 78 / 100% |
| 180 | 2.87 | **4.1%** | 0.31 | 42 / 82 / 100% |

The count is **stabilising**: it added 344 from day 30 to 90 and 295 from day 90 to 180, over a longer span.

Sensitivity:

| Change | Day 180 per player | Day 180 share | Bred : wild | Own by day 180 (c / r / h) |
| --- | --- | --- | --- | --- |
| No sink (full model) | 5.98 | 8.6% (linear) | 0.37 | 54 / 96 / 100% |
| B = 3 (full model) | 3.71 | 5.3% | 0.74 | 38 / 84 / 100% |
| Pure 50%, single 12% (full) | 3.11 | 4.5% | 0.51 | 48 / 82 / 100% |
| Wild ×2 = 0.05 (full) | 5.50 | 7.9% | 0.35 | 74 / 97 / 100% |
| Open population with churn (full) | 1.30 | 2.1% | 0.36 | 22 / 51 / 76% |
| Grid baseline, no sink | 5.66 | | 0.36 | 65 / 97 / 100% |
| Wild ×0.5 (grid) | 2.80 | | 0.35 | 43 / 81 / 99% |
| No market (grid) | 5.33 | | 0.29 | 74 / 100 / 100% |
| Perfect market (grid) | 5.94 | | 0.42 | 52 / 91 / 100% |
| No kin rule (grid) | 5.84 | | 0.39 | 66 / 98 / 100% |
| Cooldowns halved (grid) | 5.38 | | 0.30 | 65 / 98 / 100% |
| Instant hatch, Gem speed-ups (grid) | 5.66 | | 0.36 | unchanged |
| No lone-gem breeding (grid) | 6.84 | | 0.62 | 47 / 87 / 100% |
| Sink 2% a day (grid) | 3.28 | | 0.33 | 69 / 96 / 100% |
| 365 days, no sink (grid) | 11.65 | | 0.37 | 88 / 100 / 100% |
| 1,000 players (grid) | 5.90 | | 0.37 | 69 / 96 / 100% |

Findings:

- **Cooldowns and hatch speed-ups do not affect supply** (cooldowns halved: 0.30; instant hatch: unchanged). Breed limits, odds, the wild rate and sinks do. So selling hatch speed-ups is safe for supply, and cooldowns can be set for pacing alone.
- **Without a sink, supply always grows linearly**, because creatures never leave. Only a sink that scales with the stock (fusion, imprint, release) levels it off. A 1% to 2% daily removal of spent gem creatures halves the day-180 stock. Whether players will actually fuse gem creatures is the biggest behavioural unknown.
- **Lone gem × common breeding is a useful outlet.** Banning it raises pure pairing and bred : wild (0.62).
- **Ruby and Diamond** (grid model, perfect market, everyone in that biome, wild rates 0.0125 and 0.006 an hour). The proposal's B = 2 at 60% / 15% gives bred : wild 0.79 (Ruby) and 0.68 (Diamond). The recommendation gives 0.37 at 40% / 8% (Ruby) and 0.19 at 30% / 5% (Diamond). It keeps Diamond mostly wild-caught, at 1.2 per player after 180 days, which suits the top tier. Both tiers sit after launch, so these values are provisional.

## 5. Offspring level and the biome rule (sim 4)

| Check | Result | Verdict |
| --- | --- | --- |
| 40% of the parents' average, rounded down | 50 + 45 gives 19; parents at 20, 30, 50 and 100 give 8, 12, 20 and 40 | Matches the Locked example |
| Low-level parents | 6 pairs (levels 1-3) give **level 0** | Dead end. Floor at 1 |
| Breeding children of children with no levelling | 20, 8, 3, 1, 0 | No runaway. Level only comes from play |
| Traded high-level parents | Two level-60 Greenwood creatures pass the biome rule; each is **×3.18** a level-12 Greenwood giant; their child is level 24 (×1.55) | **Loophole.** The biome rule caps origin, not level. A per-player level cap from badges (creatures above it fight at the cap) brings it to ×1.14 |
| What counts as the creature's biome | If only the torso is checked, a biome-1 player can field Scuttlejaw (biome 2) parts on a Stumpback torso: +3% in this roster, and more wherever late parts are strong | **Loophole.** The biome is the latest biome among all parts |
| Cost tier from the torso | That hybrid breeds at tier 1 instead of 2: **half price** | Same fix: the cost tier comes from the latest part of either parent |
| Breeding with a creature from an unreached biome | Allowed by the brief; the child carries late parts, so it is unusable too | Not a loophole, but a coin trap. The preview must say "usable from biome N" |
| Rare colour onto a strong line (recessive gene, kin rule on) | The rare-colour parent with limit 5, 3 or 2 gives a strong-line child showing the colour in 97% of runs, with a median of 5 to 8 breeds (half-siblings carry it). With limit 1 it drops to 72% | The Locked "rare colours can be bred onto stronger ones" survives the kin rule. This is one more reason not to set any gem limit to 1 |

## 6. Casual week and hardcore month (sim 5)

200 players per row; "gain" is the best creature's stat total over the player's best wild catch, as a median (p10 to p90).

| Player | Proposal | Recommended |
| --- | --- | --- |
| Casual, day 7 (2.3 h played) | First breed on day 3.8; 5 breeds; gain +9% (0 to 27%); 0% own a gem creature | First breed on day 1.8; **13 breeds**; gain +9% (1 to 12%); 0% gem |
| Casual, day 30 | 14 breeds; +17%; 30% own a gem creature | 52 breeds; +11%; 15% gem |
| Regular, day 7 | 11 breeds; +16% | 27 breeds; +10% |
| Hardcore, day 7 | 32 breeds; +20%; 54% gem | 83 breeds; +11%; 32% gem |
| Hardcore, day 30 (90 h) | 98 breeds; +28% (14 to 37%); 7.0 mean pips; 8 gem creatures | 359 breeds; +12% (10 to 13%); **9.2 mean pips**; 2 gem creatures; 89% own one |

Reading:

- **The casual first week works under the recommendation.** The player does about two breeds a day, sees a two-species hybrid 9% above anything they caught, watches pips rise, and has something hatching overnight. It is not a gem creature: those arrive from Dust Canyon (about day 9 at 20 minutes a day) or by trade. Under the proposal, breeding unlocks at hour 1, so a casual player waits until day 4 and then gets fewer than one breed a day.
- **The hardcore month is near the top but not finished.** Average pips sit at 9.2. A perfect creature needs another 5 to 9 months (section 2.3), and 89% own a gem creature, but only about two each. Under the proposal the hardcore player would own eight gem creatures by day 30. That is where scarcity fails.
- **The gain under the recommendation is smaller** (+12% instead of +28%) because the shared budget limits chimeras. That is the intended trade: the visible gain comes from mixing up to the cap and from pips, and no single build ends the game.

## 7. What holds and what breaks

**Holds (keep as proposed):**

1. A bounded per-part quality gene with a pull to the middle. No ratchet, neutral drift stays 4.69 to 5.22 for 100 generations, and the ceiling is reached but never exceeded.
2. Fit derived from fixed species weights at assembly, never stored. Path independence is exact.
3. Parents kept. Rarity rolled from the highest tier down; a failure gives Uncommon; Cosmic is never inherited.
4. The kin rule (no parent with child, no full siblings). It is cheap, it does not stop rare colours spreading, and it trims supply slightly (0.39 to 0.36).
5. Breed limits by rarity as the main supply control, with growth linear while (B/2) × pure odds stays well below 1.
6. Cooldowns and hatch timers as pacing only. Gem speed-ups and pens up to 4 are safe for supply.
7. Recessive colour, the Bond Charm (earned coins only), the offspring preview and the family tree.

**Breaks (change):**

| # | Problem | Evidence | Fix |
| --- | --- | --- | --- |
| 1 | A chimera dominates; the fit clamp floor of 0.85 is too generous | +44% over pure; 96% duel win against 41% for the best pure | Shared budget, cap 1.15; fit clamp 0.60-1.15 |
| 2 | The size gene is free Speed | Pure 330 → 345 at size 0.8 | Size 0.90-1.10, and it also scales torso HP and Defense |
| 3 | Gem supply is not scarce | 18-34% of creatures by day 180; bred : wild 1.8-2.0 | Gem B = 2, odds 40/40/30% and 10/8/5%, wild Gem1 0.025 an hour, a stock-based sink |
| 4 | The cost curve starves casual players and makes pens pointless | 0.36 breeds a day long-run; 4 pens = 2 pens | Base 400, counts 1, 1.25, 1.5, 2, 2.5; common hatch 30 min |
| 5 | Breeding unlocks too late for casual players | First breed on day 3.8 | Unlock at the end of the first session (about 20 min), first egg hatches at once |
| 6 | The chase is miscalibrated (pull 20%) | >2,500 breeds median | Pull 15%; Bond Charm |
| 7 | Level 0 children | 6 parent pairs | Floor 1 |
| 8 | High-level traded creatures skip the early game | ×3.18 a giant | Per-player level cap from badges; child level also capped |
| 9 | Biome rule and cost tier read from the torso | +3% power; half price | Biome = latest biome among all parts |
| 10 | Proposed test 7 cannot pass with distinct species | +44% against a 12% target | Replace it with "≤ cap" and a duel-dominance check (section 8) |

## 8. Recommended rule set (`src/config/Breeding`)

Every value has been run in at least one simulation above unless marked "not tested". `breedsim/recommended.py` holds the same numbers.

| Key | Value | Evidence |
| --- | --- | --- |
| `QUALITY_MIN` / `QUALITY_MAX` / `QUALITY_MID` | 0 / 10 / 5 | Bounded; tests pass (seen 0-10) |
| `QUALITY_PIP` | 0.01 (−5% to +5%) | +2.5% wins 81% and +5% wins 99% of mirror duels: meaningful, not overwhelming next to rarity's 5-15% |
| `WILD_QUALITY` | 3 to 7, uniform | Sim 1 and 5 baseline |
| `MUTATION_CHANCE` | 0.15, pulled to the middle (up = 0.15 × (10 − q)/10, down = 0.15 × q/10) | Perfect in 370-860 breeds (count) or 6-10 months (hardcore, clock); 20% does not finish; no pull finishes in 150 |
| `RARE_MUTATION` | 0.02, a two-pip jump with the same pull, clamped | Included in every run |
| `BOND_CHARM_SHARE` | 0.80 for one chosen slot, one per breed, earned coins only | Halves breeds to 9.5 pips (304 → 185) |
| `FIT_EXPONENT` | 0.5 | Brief formula |
| `FIT_CLAMP` | 0.60 to 1.15, legs only, derived at assembly, never stored | 0.85 floor lets the chimera keep 85% Speed |
| `SIZE_RANGE` | 0.90 to 1.10; torso HP and Defense × size; body weight × size | Removes free Speed; the Locked "size and weight ratio" is kept |
| `BODY_BUDGET_CAP` | 1.15 × the body plan's species budget, applied to base stats before quality | No hybrid above +15%; best pure duel win 41% → 72%; top 5 builds show 4 shapes |
| `KIN_RULE` | No parent × child, no full siblings | Small brake; colour transfer still 97% |
| `BREED_LIMIT` | Common 5, Uncommon 5, Gem1 2, Ruby 2, Diamond 2, giants 0, cosmic 0 | B = 3 doubles bred : wild (0.36 → 0.74); B = 1 breaks colour transfer (72%) |
| `RARITY_PURE` | Gem1 40%, Ruby 40%, Diamond 30% | Gem1 4.1% of creatures at day 180; Ruby bred : wild 0.37; Diamond 0.19 |
| `RARITY_SINGLE` | Gem1 10%, Ruby 8%, Diamond 5% | Lone breeding is an outlet; banning it raises bred : wild |
| `RARITY_FAIL_TO` | Uncommon | As proposed |
| `UNCOMMON_FROM_TWO_UNCOMMON` | 50% | Not tested (Uncommon is not scarce) |
| `COOLDOWN_MIN` | Common and Uncommon 30, 60, 120, 240, 480; Gem1 720, 1,440; Ruby 1,440, 2,880; Diamond 2,880, 4,320 | Pacing only; halving them changes supply by <10% |
| `HATCH_MIN` | Common 30, Uncommon 45, Gem1 240, Ruby 480, Diamond 720 | Common hatch is what paces hardcore players (≈12 breeds a day with 2 pens); speed-ups do not touch supply |
| `BREED_BASE_COST` | 400 coins (4 minutes of biome-1 income) | Casual: 2 breeds a day, 13 in week 1 |
| `BIOME_TIER` | The latest biome among all parts of either parent | Closes the half-price loophole |
| `RARITY_COST_MULT` | 1, 1.5, 4, 10, 25 | As proposed; cost does not set supply |
| `BREED_COUNT_MULT` | 1, 1.25, 1.5, 2, 2.5 (average of both parents) | The proposal's 1 to 6.5 made everyone coin-limited |
| `PENS` | 2 (1 free, 1 quest); hard cap 4 with Gems | 4 pens bring perfect from day 300 to 186; no supply effect |
| `BREED_UNLOCK` | End of the first session (about 20 min of play); first egg hatches at once | First breed on day 1.8 instead of 3.8 |
| `OFFSPRING_LEVEL` | floor(0.40 × parents' average), at least 1, at most the player's badge level cap | Kills level 0; caps traded-level skips |
| `PLAYER_LEVEL_CAP` | Set per badge; creatures above it fight at the cap (values for the battle team to set) | ×3.18 → ×1.14 against the Greenwood giant |
| `CREATURE_BIOME` | Latest biome among all parts (used for battle eligibility and cost) | Closes the torso loophole |
| `WILD_GEM_RATE` (per hour of play) | Gem1 0.025 (about 1 in 120 catches), Ruby 0.0125, Diamond 0.006 | The single biggest supply lever: ×2 gives 7.9% instead of 4.1% |
| `GEM_SINK_TARGET` | At least 1% a day of spent gem creatures leave (fusion, imprint, release), measured live | 8.6% (no sink) → 4.1% at day 180 |
| `RADIANT_FUSION` | 4 of one torso species → 1, cosmetic | Modelled as part of the sink; uptake not tested |
| `COLOUR` | One shown and one carried allele; rare colours recessive; a colour born by mutation is set on both alleles so it shows | Transfer 97% within limit + 12 breeds; the "shows at once" rule is design reasoning, not tested |

**Tests to adopt for Lune** (the first five already pass in `breedsim/tests.py`):

1. Quality stays 0-10 and no stat total exceeds the computed ceiling over 400 adversarial lineages × 50 generations × best of 8.
2. Path independence: the same parts and size always give identical stats.
3. Neutral drift: mean quality 4.5-5.5 for 100 generations of random mating.
4. Rarity odds within 0.5 points of config over 100,000 rolls per pairing.
5. No hybrid above `BODY_BUDGET_CAP`; kin rule, breed limit and level floor enforced.
6. **New:** duel dominance. With the real battle formula and the launch roster, no build's mean win against the enumerated field exceeds a set bound, and the best pure species is at least 60%.
7. **New:** supply. The grid model at launch values keeps bred : wild below 0.5 and growth linear (second half ≤ 1.6 × first) with no sink.
8. **Changed:** chase length. A clocked hardcore profile reaches a mean of 9.5 pips in 60-120 days and perfect in no fewer than 150.
9. As proposed: atomic breed, double-submit, breeding at the limit, kin pairs, cooldown skipping.

## 9. Remaining risks

1. **The battle formula is not built yet.** The duel model shows that strict Speed order makes a 1% edge decisive, and that budget-capped builds dump Speed. Dominance must be re-checked with the real damage formula, types and moves (test 6).
2. **Wild spawn rate is the main supply lever, and it is a guess.** Measure gem creatures created against removed per tier from the first playtest and tune the wild rate first, the odds second.
3. **Sink uptake is unknown.** Without one, gem stock grows linearly for ever (11.65 per player at day 365 in the grid). If players do not fuse gem creatures, add a gem-only sink they want (for example, Radiant fusion that keeps rarity).
4. **Real players are not rational breeders.** Supply here is an upper bound, and casual numbers assume they breed whenever they can.
5. **One body plan was tested.** Four plans with different budgets need the same enumeration each. A cross-plan budget gap would recreate the dominance problem one level up.
6. **The roster is invented.** A real roster with unequal budgets, or a species with two strong slots, needs the sim 2 enumeration rerun before launch.
7. **Trading value.** At 4% of creatures, Gem1 should hold value, but Ruby and Diamond were tested only in the grid model with everyone in the biome. Rerun them when those biomes are designed.
8. **Python and Luau random numbers differ.** When porting, compare distributions, not exact sequences.

## 10. Files

- `breedsim/common.py`: creature model, roster, rules, breeding, rarity roll, cost.
- `breedsim/engine.py`: player model with sessions, pens, cooldowns, hatch, coins, catches, storage, sinks.
- `breedsim/recommended.py`: the section 8 values as one config.
- `breedsim/sim1_progression.py` (parts `a`, `b`, `c`, `d`), `sim2_fit.py`, `sim3_population.py` (`full`, `full_open`, `grid`, `sens 2 0.4 0.1`, `tiers`, `abm <variant>`), `sim4_level_biome.py`, `sim5_players.py`, `tests.py`.
- `breedsim/results/`: the output of every run quoted above.

Run with, for example, `python3 -I breedsim/sim2_fit.py`. Run times: sim 2 under 10 s; tests 3 s; sim 5 about 40 s; a full ABM run about 2 min; sim 1 parts b to d several minutes each.
