# Economy model: coins and Breeding Candy

Date: 16 November 2026. Status: starting values, every one a [Default] to tune from the first playtest.

- Numbers: `src/config/EconomyConfig.luau`. Rules over them: `src/shared/Economy.luau`.
- Proof: `tests/economy.test.luau` (invariants, a 30-day simulation of three player types on fixed seeds, and the target bands as assertions). It runs in about one second. Set `RUN_LONG_EXPLORATION = true` at the top for 200 seeds per player type and the sensitivity table (about 13 seconds).
- Breeding prices, cooldowns and hatch times are read from `src/config/BreedConfig.luau` and were not changed.

## 1. The three currencies

| Currency | Earned from | Spent on | Rules |
| --- | --- | --- | --- |
| Coins | Battles, quests, daily and weekly tasks, releases, casual PvP (later) | Lassos, healing, Giant Horns, bait, Bond Charms, breeding, stable space, decorations | Earned only. Never sold, never traded |
| Breeding Candy | Mentor's lesson, daily tasks, giant rematches, first clears, quest lines, weekly challenge, ranked seasons (later) | Every breed (1, 2, 5, 12 or 30 by the rarer parent) | Earned only. Never sold for Robux or Gems, never traded or gifted |
| Gems | Robux | Time (hatch speed-ups) and capacity (pens, stable) | Not modelled here: they buy no coins, candy or random result |

Candy is the gate on how many creatures are made; coins are the sink that keeps balances in check. The model is tuned so that, for regular and heavy players, candy, pens and cooldowns run out before coins do.

## 2. Starting values

All coin figures below are at the bottom of the biome's level band; each level above it adds 3%, up to +30% at the top of the band.

**How rewards grow across the three launch biomes**

| | Greenwood | Dust Canyon | Tide Flats | Rule |
| --- | --- | --- | --- | --- |
| Repeatable income multiplier (`BIOME_MULT`) | 1 | 2.5 | 5 | Wild wins, rematches, daily and weekly tasks, Horn and Charm prices |
| One-time multiplier (`ONE_TIME_MULT`) | 1 | 1.5 | 2 | First clears and quest lines |
| Breed cost tier (BreedConfig, fixed) | 1 | 2 | 3 | |

Repeatable income rises faster than the breed tier on purpose. With income scaled like the breed tier, regular players ran out of coins with a month's candy unspent: count multipliers (up to 2.5x), gem-tier breeds (4x) and rematch horns all grow with play. One-time rewards rise more gently, because larger Dust Canyon windfalls made new players far too flush (section 4, target 2).

**Battle rewards (coins)**

| Win | Greenwood | Dust Canyon | Tide Flats | Limit |
| --- | --- | --- | --- | --- |
| Wild | 60 | 150 | 300 | Daily, per kind of creature: 8 full wins, then x0.85 each, never below 15%, nothing from the 50th. A whole day on one kind pays about 17 full wins |
| Tamer, first clear / rematch | 160 / 50 | 240 / 125 | 320 / 250 | One paid rematch per tamer per day |
| Gate, first clear / rematch | 500 / 150 | 750 / 375 | 1,000 / 750 | One paid rematch a day |
| Giant, first clear / rematch | 800 / 700 | 1,200 / 1,750 | 1,600 / 3,500 | Two paid rematches a day; a rematch always pays less than its Horn costs |

**Other coin sources**

| Source | Greenwood | Dust Canyon | Tide Flats | Limit |
| --- | --- | --- | --- | --- |
| Quest line (two per biome) | 400 | 600 | 800 | Once per line |
| Easy daily task (three a day) | 100 | 250 | 500 | Daily; tasks open with the first badge |
| Hard daily task (three a day: 30 wild wins, a giant rematch win, 5 tamer rematch wins) | 800 | 2,000 | 4,000 | Daily |
| Weekly challenge | 3,000 | 7,500 | 15,000 | Weekly |
| Casual PvP win (later) | 200 | 500 | 1,000 | First five matchmade wins a day; nothing for a repeat opponent within 24 hours or in private servers |
| Starting coins | 150 | | | Once; the mentor also gives 5 Rope Lassos and 3 Field Tonics |
| Release | a few coins | | | Below the cheapest catch (section 3) |

**Items (coins)**

| Item (id) | Price | Notes |
| --- | --- | --- |
| Rope Lasso (`Basic`) | 15 | Trivially cheap, as the lasso research recommends |
| Braided Lasso (`Braided`) | 80 | Cheapest lasso that can catch a gem-tier creature |
| Gilded Lasso (`Gilded`) | 250 | Cheapest for Ruby and above |
| Field Tonic (`Tonic`) | 30 | Heals 40%. Craft: 3 Fernfluff |
| Deep Tonic (`GreatTonic`) | 90 | Full heal. Craft: 3 Canyon Grit + 20 coins |
| Rally Root (`Revive`) | 150 | Revives at half health |
| Giant Horn (`GiantCall`) | 900 / 2,750 / 5,500 | Needed to start any giant fight, used up win or lose. Greenwood's is cheaper |
| Tide Bait (`Bait`) | 400 | From Tide Flats. Craft: 8 Brine Shell + 80 coins |
| Bond Charm (`BondCharm`) | 400 / 1,000 / 2,000 | One breed's part tilt; scales with the hub's biome |

Up to five field items (Tonics, Deep Tonics, Rally Roots) can be brought into a giant fight. Crafted items cannot be sold back, so materials never become coins. The town healer stays free.

**Breeding Candy**

| Source | Candy | Limit |
| --- | --- | --- |
| Mentor's lesson (about minute 10) | 2 | Once. It also gives the second breeding pen |
| Easy daily tasks | 1 each, 3 a day | Daily, from the first badge |
| Hard daily tasks | 1 each, 3 a day | Daily, from the first badge |
| Giant rematch win | 1 | Two a day |
| Weekly challenge | 3 | Weekly |
| Giant first clear | 5 | Once per giant |
| Gate first clear (badge) | 5 | Once per biome |
| Quest line | 2 / 3 / 4 by biome | Once per line |
| Ranked season | 10 (placeholder) | Once per season, when PvP ships |

**Stable and pens**: 30 free stable slots; coin expansions of 10 slots at 3,000, 6,000, 12,000, 24,000 and 48,000 (Gem expansions stack on top). Pens: one free, the second from the mentor's lesson, up to 4 with Gems. Twelve cosmetic stable decorations from 5,000 to 280,000 coins are the veterans' prestige sink.

## 3. Rules that keep every faucet bounded

- **No faucet without a cap or a diminishing rule.** Every named source in the ledger (`EconomyConfig.FLOWS`) is marked Diminishing, Daily, Weekly, Once or BelowCost, and the test fails if one is not, or if any candy source pays past its cap.
- **Wild wins diminish per kind per day** and stop at the 50th win of a kind. A player stuck before a giant still has several fresh kinds to fight; the first version (5 full wins, then x0.75) left a heavy player who failed a giant on day 1 earning almost nothing for 40 minutes, so it was widened.
- **Releasing always pays less than obtaining.** A release pays at most 75% of the cheapest lasso that can catch that rarity, counting any materials at their crafting value; `Economy.releasePayout` enforces this, so it holds for every rarity and every biome to 11 (tested). Catching and releasing is always worse than just winning the battle. It also pays far less than any breed (400 coins or more).
- **The ledger never goes below zero.** `Economy.apply` refuses an unknown flow, an amount that is not a positive whole number, or a spend larger than the balance, and returns the balances unchanged. 20,000 random moves never went negative, and no transaction in the simulation was refused.
- **Giant rematches are a coin sink.** The Horn always costs more than the rematch pays; the reward for preparing is candy.

## 4. The simulation

Three player types play one session a day for 30 days through Greenwood, Dust Canyon and Tide Flats, then the post-game. A day is a sequence of timed activities: story wild battles and tamers in order, two quest lines per biome, giant attempts (buying a Horn and topping up the field items first, saving for it from halfway through the biome's tamers), the gate, then after the story giant rematches, tamer rematches, bait, the weekly challenge and wild battles in whichever biome still pays best. Lasso throws can miss and creatures flee after three misses. Healing is a Tonic or a walk to the free healer. Breeding runs whenever coins (above a small reserve), candy, a free pen and parent cooldowns allow, across four common pairs plus a gem pair once a gem creature is owned; children sometimes replace a parent, some are released, and a full stable is either expanded with coins or emptied of five commons. Players buy stable space and decorations only once they hold more than three days of income. Every coin and candy movement goes through `Economy.apply`.

| Player | Minutes a day | Lasso attempts (story, after) | Giant first-try win chance | Rematches a day | Bond Charm on | Bait a day |
| --- | --- | --- | --- | --- | --- | --- |
| Casual | 20 | 40%, 10% | 45% | 0 | none | 0 |
| Regular | 45 | 40%, 12% | 55% | 1 | 15% of breeds | 1 |
| Heavy | 120 | 40%, 15% | 65% | 2 | 40% of breeds | 3 |

Each failed giant attempt adds 15% to the next one's chance (the patterns are fixed, so players learn them), and each field item adds 3%.

### Results (200 seeds per player type, means)

**A. Coins removed as a share of coins created**

| Player | First 2 hours | After Greenwood | Week 1 | Week 2 | Week 3 | Week 4 | After the story | Times unable to buy a lasso or Tonic |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Casual | 69% | 89% | 77% | 77% | 89% | 101% | 90% | 0 |
| Regular | 59% | 90% | 77% | 88% | 87% | 97% | 92% | 0 |
| Heavy | 58% | 87% | 79% | 84% | 87% | 96% | 89% | 0 |

**B. Progress and breeding**

| Player | Biomes cleared on day | Greenwood coins a minute | Common Greenwood breed in minutes of income | Breeds a day, week 1 / later | Mean coins a breed | Share of breeds on a gem pair |
| --- | --- | --- | --- | --- | --- | --- |
| Casual | 3.4, 7.2, 12.0 | 84 | 4.8 | 1.9 / 2.0 | 2,985 | 19% |
| Regular | 2.0, 3.5, 5.7 | 86 | 4.7 | 3.5 / 3.3 | 3,659 | 22% |
| Heavy | 1.0, 2.0, 2.2 | 88 | 4.5 | 5.9 / 5.5 | 3,404 | 16% |

**C. Candy**

| Player | Candy a day, week 1 | Candy a day after the story | Unspent at day 30 | First breed |
| --- | --- | --- | --- | --- |
| Casual | 6.0 | 3.4 | 36 | minute 11, day 1, mentor's candy |
| Regular | 10.2 | 5.9 | 19 | minute 11, day 1, mentor's candy |
| Heavy | 13.7 | 8.1 | 3 | minute 11, day 1, mentor's candy |

Where candy comes from over the month: daily tasks 57 to 62%, first clears 11 to 22%, quest lines 6 to 13%, giant rematches 0 to 16%, weekly challenge 4 to 8%, the mentor 1%. The week-1 figure is the one-time burst; it is nearly double the steady rate.

**D. Coins on hand**

| Player | End of week 1 / 2 / 3 / 4 | Income a day after the story | Days of income held: day 7, mean of days 8 to 30, day 30 | First gem-tier child |
| --- | --- | --- | --- | --- |
| Casual | 5,175 / 19,718 / 28,788 / 27,864 | 12,083 | 1.6, 2.3, 2.7 | day 19.9, in 62% of runs |
| Regular | 20,567 / 44,304 / 69,723 / 76,678 | 28,055 | 1.6, 2.2, 2.7 | day 14.6, in 84% of runs |
| Heavy | 66,532 / 126,882 / 176,414 / 189,921 | 54,638 | 1.5, 2.8, 3.8 | day 10.6, in 94% of runs |

**E. Giants** (first attempt's preparation; a "session" is 20 minutes of that biome's income less lassos and healing)

| Player | Greenwood | Dust Canyon | Tide Flats |
| --- | --- | --- | --- |
| Casual | 1,077 coins, 0.7 sessions, 1.6 attempts | 2,930, 0.8, 1.6 | 5,680, 0.5, 1.6 |
| Regular | 1,227, 0.7, 1.4 | 3,064, 1.0, 1.4 | 5,814, 0.5, 1.4 |
| Heavy | 1,284, 0.8, 1.2 | 3,084, 0.9, 1.2 | 5,832, 0.7, 1.2 |

The longest wait anywhere, across 600 runs, between wanting a giant attempt and affording it was 21 minutes of ordinary play (wild battles that also level the team); the mean is 1.5 to 4 minutes.

**F. Where coins go**

| Player | Breeding | Shop (lassos, healing, Horns, bait, charms) | Stable space | Decorations |
| --- | --- | --- | --- | --- |
| Casual | 71% | 9% | 13% | 8% |
| Regular | 56% | 29% | 12% | 2% |
| Heavy | 42% | 37% | 7% | 13% |

**G. Days from owning a pure pair to a child of the same tier** (Tide Flats pair, every candy spent on it; median and 90th percentile; median coins)

| Child | Candy each | Chance | Casual | Regular | Heavy |
| --- | --- | --- | --- | --- | --- |
| First gem tier ("Amber") | 5 | 40% | 3.0 d (p90 7.3), 11k coins | 1.7 d (4.7) | 1.2 d (4.2) |
| Ruby | 12 | 40% | 7.0 d (17.5), 27k | 4.1 d (10.2) | 3.0 d (9.0) |
| Diamond | 30 | 30% | 17.5 d (61.3), 68k | 10.2 d (35.5) | 7.5 d (26.0) |

The coins are not the limit: a Diamond child's 68k is 5.6 days of a casual player's income and 1.2 days of a heavy player's. Candy and the long gem cooldowns are. A child cannot be rarer than its rarer parent, so a Ruby or Diamond child also needs a Ruby or Diamond parent from the wild, bait or a trade; how often those appear is a spawn decision outside this model.

### Against the targets

| # | Target | Result |
| --- | --- | --- |
| 1 | Three player types over 30 days | Met (tables A to F) |
| 2 | 60 to 70% removed in the first two hours | Casual 69%, regular 59%, heavy 58%. The test asserts 57 to 73% ("about"). The early sink is breeding, and it is capped by pens and 30-minute hatches, so this came only after the second pen moved to the mentor's lesson and daily tasks moved to the first badge |
| 2 | 80 to 95% after Greenwood for regular and heavy | 90% and 87% |
| 2 | Never unable to buy a lasso and a Tonic | Zero times in 600 runs; two fresh Greenwood wins (120 coins) buy both (45) |
| 3 | First common breed about four minutes of Greenwood income; casual about two breeds a day | 4.5 to 4.8 minutes (on the slow side of the 3 to 5 band); casual 1.9 to 2.0 a day |
| 4 | Candy about 5 (regular) and 8 (heavy), mostly from tasks, giants and quests; early burst; first breed with the mentor's candy | 5.9 and 8.1; week 1 nearly double; first breed at minute 11 on day 1 in every test run |
| 5 | Regular holds 2 to 7 days of income after week 1; nothing piles up without limit | Regular 2.2 days (mean of days 8 to 30; 1.6 on day 7 itself). In an earlier run heavy balances rose by about 40k a week; stable decorations (a new sink) and coin stable expansions flattened them to +13k in week 4 |
| 6 | First on-level giant costs about one session's spare coins; no long lockout | 0.5 to 1.0 sessions; worst wait 21 minutes, mean under 4 |
| 7 | Every faucet capped or diminishing; release below catch and breed | Asserted in the test |

## 5. What changed while tuning, and why

Each line is a [Default] for `DECISIONS.md`.

1. **Repeatable income rises faster than breed costs** (x1, 2.5, 5). With x1, 2, 3, regular players finished the month with 80 candy unspent and spent 100% of their coins: breeding was coin-limited, which the stress test (`research/market/09` section 2.3) warned against.
2. **One-time rewards rise more gently** (x1, 1.5, 2), and **daily tasks open with the first badge**. Both lower the first two hours' income without touching later play.
3. **The second pen comes from the mentor's lesson** at about minute 10, not from a later quest. With one pen in the first hours, new players could not spend more than about half their coins whatever the prices; this was the single biggest lever on target 2. `BREEDING_PLAN.md` section 5 says "a second from a quest": the mentor's lesson is that quest.
4. **Giant Horns scale with the biome and cost more than a rematch pays.** First attempts cost 0.5 to 1 session; rematches convert coins into candy (up to 2 a day), the heavy player's biggest shop spend.
5. **Hard daily tasks pay well** (800 x income multiplier). They reward the 45-minute player most per minute and are capped at three a day.
6. **Two new sinks**: coin stable expansions and stable decorations (cosmetic only). Without them heavy balances grew without limit.
7. **The diminishing rule was widened** (8 full wins, x0.85, floor 15%, stop at 50) after it starved a player stuck before a giant.
8. **Bond Charm scales with the hub's biome** (400, 1,000, 2,000), so it stays a real choice for rich breeders.

## 6. Inputs that are guesses

None of these is a balance number; they describe how people play, and live in the test (`ASSUME`, `PROFILES`), not in `src/config`.

- **Battle and travel lengths**: 0.75 minutes per wild battle including finding it, 2.5 per tamer, 5 per giant, 4 to 6 minutes of travel per quest line, 0.35 plus 0.1 a throw for a lasso attempt.
- **Content counts**: 22, 32 and 42 story wild battles and 6, 8 and 10 tamers per biome; six kinds of wild creature per biome (the Greenwood roster plans eight, which would raise heavy players' income a little).
- **Lasso misses**: 45% (Rope), 30% (Braided), 15% (Gilded); lasso attempts on 40% of story battles.
- **How often players breed**: whenever they can, across four common pairs, keeping only a small reserve. Real players will breed less; that leaves candy unspent and coins piling, not the reverse.
- **Giant win chances** (45 to 65% first try, +15% per failure, 80% on rematches) and gem spawn rates (0.6% of wild encounters from Dust Canyon, 35% of bait spawns).
- **Sessions**: one a day of a fixed length; eggs hatch overnight. Optional spending starts at three days of income held.

## 7. Which results are most sensitive

One guess changed at a time (40 seeds each):

| Change | Regular, first 2 h | After Greenwood, regular / heavy | Regular days held | Regular candy unspent | Casual breeds a day |
| --- | --- | --- | --- | --- | --- |
| Baseline | 61% | 90% / 87% | 2.1 | 18 | 1.9 |
| Battles 30% slower | 60% | 96% / 89% | 1.0 | 14 | 1.7 |
| Battles 30% faster | 68% | 87% / 87% | 2.8 | 20 | 2.0 |
| Lasso misses x1.5 | 60% | 90% / 87% | 2.1 | 19 | 1.9 |
| Half of breeds skipped | 58% | 89% / 87% | 2.3 | 30 | 1.9 |
| Gem spawns x3 | 61% | 90% / 87% | 2.2 | 15 | 1.8 |
| Giants harder | 62% | 90% / 88% | 2.0 | 10 | 1.9 |

- **Battle length is the input that matters.** Coins come per battle and costs come per breed, so slower battles squeeze regular players (96%, one day of coins held) and faster ones make everyone richer. Measure it first.
- **How often players breed** moves candy, not coins: other sinks absorb the coins. Lasso misses barely matter because lassos are cheap. Gem spawn rates and giant difficulty move candy use, not the coin ratio.
- **The first-two-hours ratio** depends mostly on pens and hatch time, not prices.

## 8. Five numbers to watch in the first playtest

1. **Minutes per wild battle, including finding the creature**, and wild battles per hour of play. Every coin result scales with it (section 7).
2. **Coins removed as a share of coins created, per player per day**, split by source and sink and by hours played (first two hours, after Greenwood, after the story). Targets: 60 to 70%, then 80 to 95%.
3. **Unspent Breeding Candy per player at day 7 and day 30.** Growing candy with falling coins means breeding is coin-starved (raise income); growing coins with no candy means candy is the gate as intended.
4. **Median and 90th-percentile coin balance by account age, in days of that player's income.** Target 2 to 7; a rising 90th percentile means the decorations need more items.
5. **Giant attempts per first clear and minutes between a failed attempt and the next attempt.** Targets: about 1.2 to 1.6 attempts, under 20 minutes.

## 9. Not covered yet

- Casual PvP coins, the trade fee and ranked candy are configured but not simulated; re-run the simulation when PvP ships.
- Biome 4 onwards uses placeholder multipliers; re-run when the Mire is designed.
- `LASSO_MIN_TIER` (a gem creature needs at least a Braided Lasso) is assumed for the release rule. If capture design lets a Rope Lasso catch everything, set every entry to `Basic`; release payouts then lower themselves.
- Gem purchases (extra pens, hatch speed-ups) are left out. A player with four pens breeds more, spends more coins and runs out of candy sooner.
