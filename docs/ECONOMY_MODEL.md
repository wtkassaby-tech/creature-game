# Economy model: coins and Breeding Candy

Date: 16 November 2026; candy rebuilt as typed candy on 20 November 2026 (`DECISIONS.md`). Status: starting values, every one a [Default] to tune from the first playtest.

- Numbers: `src/config/EconomyConfig.luau`. Rules over them: `src/shared/Economy.luau`.
- Proof: `tests/economy.test.luau` (invariants, a 30-day simulation of three player types on fixed seeds, a Sand-starter check, a catch-and-release farming hour, and the target bands as assertions). It runs in about one and a half seconds. Set `RUN_LONG_EXPLORATION = true` at the top for 200 seeds per player type and the sensitivity table (about 20 seconds).
- Breeding coin prices, cooldowns and hatch times are read from `src/config/BreedConfig.luau` and were not changed. `CANDY_COST` keeps its values (1, 2, 5, 12, 30) but is now paid by each parent in its own type.

## 1. The three currencies

| Currency | Earned from | Spent on | Rules |
| --- | --- | --- | --- |
| Coins | Battles, quests, daily and weekly tasks, releases, casual PvP (later) | Lassos, healing, Giant Horns, bait, Bond Charms, breeding, stable space, decorations | Earned only. Never sold, never traded |
| Breeding Candy, typed (one balance per element) | Catching a creature (its type), releasing one (less) | Every breed: each parent uses 1, 2, 5, 12 or 30 by its own rarity, of its own type | Earned only. Never sold for Robux or Gems, never traded or gifted |
| Prism Candy (working name; counts as any type) | Mentor's lesson, daily tasks, giant rematches, first clears, quest lines, weekly challenge, ranked seasons (later) | Any shortfall in a breed's typed candy | Same as typed candy |
| Gems | Robux | Time (hatch speed-ups) and capacity (pens, stable) | Not modelled here: they buy no coins, candy or random result |

Candy is the gate on how many gem-tier creatures are made; coins are the sink that keeps balances in check. With typed candy, common breeding is paced by coins, pens and cooldowns, and candy bites where it should: a gem-tier pair needs a lot of one type, and that type comes from catching it or from scarce Prism.

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

**Breeding Candy: what a breed uses** (`BreedConfig.CANDY_COST`, per parent, in that parent's type: its torso's element)

| Parent's rarity | Common | Uncommon | Gem tier | Ruby | Diamond |
| --- | --- | --- | --- | --- | --- |
| Candy of its own type | 1 | 2 | 5 | 12 | 30 |

A breed of two types needs both kinds (a common Sand with a common Leaf needs 1 Sand and 1 Leaf); a same-type pair pays both from one balance (two common Leafs need 2 Leaf). Typed candy is spent first and Prism covers any shortfall (`Economy.candyPayment`). A pure gem pair now needs 10 a breed, Ruby 24 and Diamond 30 + 30 = 60, twice the single-candy prices; supply from catching makes up the difference (section 4, table G).

**Typed candy: catching and releasing** (per type, per day)

| Rarity | Catch | Release |
| --- | --- | --- |
| Common | 1 | 0.5 (one candy every second release) |
| Uncommon | 2 | 0.5 |
| Gem tier | 6 | 3 |
| Ruby | 12 | 6 |
| Diamond (and Cosmic) | 24 | 12 |

- **Falloff, per type per day** (`CATCH_FALLOFF`, `RELEASE_FALLOFF`): the first 3 catches of a type pay in full, each later one half the one before (releases: 0.4), never below a tenth, and nothing from the 40th. Fractions add up across the day, so a tenth pays one candy every tenth catch: diminishing, not a wall. A whole day of common catches of one type pays at most 7 candy, releases at most 3.
- **Releasing pays less than obtaining, in candy too:** a release pays less than the catch, and less than the cheapest breed that can make that rarity (Common 0.5 against 2, Gem 3 against 6, Diamond 12 against 31); over any number of claims in a day, releases never add up to more than catches (tested).
- The counts are saved in the profile (`Daily.catches`, `Daily.releases`), reset by the server's date.

**Prism Candy** (counts as any type)

| Source | Prism | Limit |
| --- | --- | --- |
| Mentor's lesson (about minute 10) | 2 | Once. It also gives the second breeding pen, and pays for the first breed |
| Easy daily tasks | 1 each, 3 a day | Daily, from the first badge |
| Hard daily tasks | 1 each, 3 a day | Daily, from the first badge |
| Giant rematch win | 1 | Two a day |
| Weekly challenge | 3 | Weekly |
| Giant first clear | 5 | Once per giant |
| Gate first clear (badge) | 5 | Once per biome |
| Quest line | 2 / 3 / 4 by biome | Once per line |
| Ranked season | 10 (placeholder) | Once per season, when PvP ships |

Story and quest rewards use the reward kind `PrismCandy` (`WorldTypes`).

**Stable and pens**: 30 free stable slots; coin expansions of 10 slots at 3,000, 6,000, 12,000, 24,000 and 48,000 (Gem expansions stack on top). Pens: one free, the second from the mentor's lesson, up to 4 with Gems. Twelve cosmetic stable decorations from 5,000 to 280,000 coins are the veterans' prestige sink.

## 3. Rules that keep every faucet bounded

- **No faucet without a cap or a diminishing rule.** Every named source in the ledger (`EconomyConfig.FLOWS`) is marked Diminishing, Daily, Weekly, Once or BelowCost, and the test fails if one is not, if any Prism source pays past its cap, or if typed candy ever rises within a day or pays at its stop.
- **Typed candy falls off per type per day** (section 2), so catch-and-release cannot flood supply: an hour of it earns about as much candy as an hour of normal play (section 4, table I).
- **Wild wins diminish per kind per day** and stop at the 50th win of a kind. A player stuck before a giant still has several fresh kinds to fight; the first version (5 full wins, then x0.75) left a heavy player who failed a giant on day 1 earning almost nothing for 40 minutes, so it was widened.
- **Releasing always pays less than obtaining.** A release pays at most 75% of the cheapest lasso that can catch that rarity, counting any materials at their crafting value; `Economy.releasePayout` enforces this, so it holds for every rarity and every biome to 11 (tested). Catching and releasing is always worse than just winning the battle. It also pays far less than any breed (400 coins or more).
- **The ledger never goes below zero.** `Economy.apply` refuses an unknown flow, a typed candy flow without a type, an amount that is not a positive whole number, or a spend larger than the balance (for typed candy: that type plus Prism), and returns the balances unchanged. 20,000 random moves across every type never went negative, and no transaction in the simulation was refused.
- **Giant rematches are a coin sink.** The Horn always costs more than the rematch pays; the reward for preparing is candy.

## 4. The simulation

Three player types play one session a day for 30 days through Greenwood, Dust Canyon and Tide Flats, then the post-game. A day is a sequence of timed activities: story wild battles and tamers in order, two quest lines per biome, giant attempts (buying a Horn and topping up the field items first, saving for it from halfway through the biome's tamers), the gate, then after the story giant rematches, tamer rematches, bait, the weekly challenge and wild battles in whichever biome still pays best. Lasso throws can miss and creatures flee after three misses. Healing is a Tonic or a walk to the free healer. Every coin and candy movement goes through `Economy.apply`.

**Types and candy in the simulation.** Each kind of wild creature has a type: Greenwood follows its roster (four Leaf kinds, one Water, one Sand; Sand only on Route B, the second half of the story), Dust Canyon the roster being designed (four Sand, one Leaf, one Water), Tide Flats a guess (four Water, one Toxic, one Sand). Every catch pays typed candy with the falloff; during the story players keep their catches (a full stable still releases five, which pays candy), and after it they release a share at once (casual 30%, regular 50%, heavy 60%). The four common breeding pairs are random creatures of the current biome, so most breeds mix two types; the starter is one parent of the first pair. Breeding runs whenever coins (above a small reserve), candy, a free pen and parent cooldowns allow, across the four common pairs plus a gem pair once a gem creature is owned. While a gem pair exists the player holds back its next breed's candy (its own types first, then Prism) and its coins, and common pairs use what is left. Children sometimes replace a parent and take either parent's type; some are released, and a full stable is either expanded with coins or emptied of five commons. Players buy stable space and decorations only once they hold more than three days of income.

| Player | Minutes a day | Lasso attempts (story, after) | Catches a day (week 1, after the story) | Released at once after the story | Giant first-try win chance | Rematches a day | Bond Charm on | Bait a day |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Casual | 20 | 40%, 10% | 3.3, 1.9 | 30% | 45% | 0 | none | 0 |
| Regular | 45 | 40%, 12% | 6.6, 4.7 | 50% | 55% | 1 | 15% of breeds | 1 |
| Heavy | 120 | 40%, 15% | 16.9, 16.1 | 60% | 65% | 2 | 40% of breeds | 3 |

Each failed giant attempt adds 15% to the next one's chance (the patterns are fixed, so players learn them), and each field item adds 3%.

### Results (200 seeds per player type, means)

**A. Coins removed as a share of coins created**

| Player | First 2 hours | After Greenwood | Week 1 | Week 2 | Week 3 | Week 4 | After the story | Times unable to buy a lasso or Tonic |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Casual | 68% | 89% | 77% | 76% | 89% | 100% | 89% | 0 |
| Regular | 59% | 90% | 75% | 87% | 88% | 96% | 92% | 0 |
| Heavy | 57% | 87% | 78% | 84% | 88% | 97% | 89% | 0 |

The single-candy model gave 69/59/58% in the first two hours; the coin results are otherwise within a point or two.

**B. Progress and breeding**

| Player | Biomes cleared on day | Greenwood coins a minute | Common Greenwood breed in minutes of income | Breeds a day, week 1 / later | Mean coins a breed | Share of breeds on a gem pair |
| --- | --- | --- | --- | --- | --- | --- |
| Casual | 3.3, 7.1, 11.8 | 85 | 4.7 | 1.9 / 1.8 | 3,090 | 21% |
| Regular | 2.0, 3.4, 5.7 | 87 | 4.6 | 3.3 / 3.3 | 3,682 | 22% |
| Heavy | 1.0, 2.0, 2.2 | 88 | 4.5 | 5.8 / 5.6 | 3,443 | 17% |

**C. Candy**

| Player | Candy a day, week 1 (of it Prism) | After the story: Prism + typed (the best type alone) | Candy an hour after the story | Unspent at day 30 (all types) | First breed |
| --- | --- | --- | --- | --- | --- |
| Casual | 9.5 (6.2) | 3.4 + 3.0 (2.0) | 18.9 | 59 | minute 11, day 1, mentor's Prism |
| Regular | 17.0 (10.2) | 5.9 + 8.1 (5.1) | 18.6 | 111 | minute 11, day 1, mentor's Prism |
| Heavy | 30.3 (13.8) | 8.1 + 19.4 (9.7) | 13.7 | 321 | minute 11, day 1, mentor's Prism |

Where candy comes from over the month: catches 34 to 54%, releases 6 to 12%, daily tasks 21 to 34%, first clears 4 to 13%, quest lines 2 to 8%, giant rematches 0 to 5%, weekly challenge 1 to 4%, the mentor 1% or less. Unspent candy is mostly types the player has no pair for; it does not buy gem tiers, because a gem pair needs one type (table G).

**D. Coins on hand**

| Player | End of week 1 / 2 / 3 / 4 | Income a day after the story | Days of income held: day 7, mean of days 8 to 30, day 30 | First gem-tier child |
| --- | --- | --- | --- | --- |
| Casual | 5,521 / 21,024 / 29,581 / 29,252 | 12,057 | 1.7, 2.4, 2.9 | day 20.2, in 61% of runs |
| Regular | 22,742 / 47,591 / 71,952 / 79,312 | 28,102 | 1.7, 2.3, 2.8 | day 14.4, in 82% of runs |
| Heavy | 69,959 / 131,689 / 178,558 / 191,479 | 54,652 | 1.6, 2.9, 3.8 | day 11.2, in 94% of runs |

**E. Giants** (first attempt's preparation; a "session" is 20 minutes of that biome's income less lassos and healing)

| Player | Greenwood | Dust Canyon | Tide Flats |
| --- | --- | --- | --- |
| Casual | 1,078 coins, 0.7 sessions, 1.5 attempts | 2,930, 0.8, 1.6 | 5,680, 0.5, 1.5 |
| Regular | 1,227, 0.7, 1.3 | 3,064, 1.0, 1.4 | 5,811, 0.5, 1.4 |
| Heavy | 1,284, 0.8, 1.2 | 3,084, 0.9, 1.2 | 5,827, 0.7, 1.2 |

The longest wait anywhere, across 600 runs, between wanting a giant attempt and affording it was 20 minutes of ordinary play (wild battles that also level the team).

**F. Where coins go**

| Player | Breeding | Shop (lassos, healing, Horns, bait, charms) | Stable space | Decorations |
| --- | --- | --- | --- | --- |
| Casual | 69% | 8% | 13% | 9% |
| Regular | 55% | 29% | 12% | 3% |
| Heavy | 42% | 37% | 7% | 13% |

**G. Days from owning a pure pair to a child of the same tier** (Tide Flats pair of one type, every candy of that type and every Prism spent on it; the rate is Prism a day plus the player's best type a day after the story; median and 90th percentile; median coins)

| Child | Candy a breed (was) | Chance | Casual (was) | Regular (was) | Heavy (was) |
| --- | --- | --- | --- | --- | --- |
| First gem tier ("Amber") | 10 (5) | 40% | 3.7 d, p90 9.2 (3.0) | 1.8 d, p90 4.8 (1.7) | 1.2 d, p90 4.2 (1.2) |
| Ruby | 24 (12) | 40% | 8.8 d, p90 22.1 (7.0) | 4.4 d, p90 10.9 (4.1) | 2.7 d, p90 8.7 (3.0) |
| Diamond | 60 (30) | 30% | 22.1 d, p90 77.2 (17.5) | 10.9 d, p90 38.0 (10.2) | 6.8 d, p90 23.7 (7.5) |

Candy needed per child on average is unchanged in shape: 25 per gem-tier child, 60 per Ruby, 200 per Diamond (double the old 12.5, 30 and 100, because both parents now pay). **For a regular player the days are 5 to 7% longer than before; for a casual player about 25% longer; for a heavy player 0 to 10% shorter.** Why: the price of a pure pair doubled, and typed candy roughly doubled the candy a player can put on one type, but that typed income comes from catching, which grows with play time. A casual player catches about two creatures a day after the story, spread over several types, so their gem pair runs mostly on Prism; a heavy player catches sixteen. Gem tiers therefore stay scarce, and move slightly toward players who play more. The coins are not the limit (a Diamond child's 68k is 5.6 days of a casual player's income and 1.2 days of a heavy player's): candy and the long gem cooldowns are. A child cannot be rarer than its rarer parent, so a Ruby or Diamond child also needs a Ruby or Diamond parent from the wild, bait or a trade.

**H. A player whose starter is Sand** (first two days, 30 seeds; Greenwood has one Sand species, the starter itself, and it lives only on Route B)

| Player | Breeds in two days | Breeds with a Sand parent | Times a Sand breed waited for candy | Sand candy earned | Prism earned |
| --- | --- | --- | --- | --- | --- |
| Casual, Sand starter | 3.9 | 3.0 | 0.8 | 0.9 | 5.9 |
| Casual, Leaf starter (for comparison: Leaf parent) | 3.9 | 3.8 | 1.5 | 5.0 | 5.9 |
| Regular, Sand starter | 7.1 | 6.1 | 0.9 | 3.6 | 20.7 |
| Regular, Leaf starter | 7.3 | 6.0 | 0.8 | 4.4 | 21.3 |

A Sand starter is not stuck: Prism (the mentor's 2, the first quest line and first clears) pays for the Sand side of early breeds, and from Route B a regular player catches Spadesnouts for Sand candy. A casual player has barely reached Route B by the end of day 2, so nearly all their Sand breeds run on Prism.

**I. Catch-and-release farming** (20 seeds; every wild battle gets a lasso attempt and every catch is released at once, from a fresh day, counting the daily tasks it completes)

| | Candy an hour | Against a normal hour after the story: casual 18.6, regular 18.6, heavy 13.7 |
| --- | --- | --- |
| Farming in Greenwood (37 catches an hour) | 18.5 | 1.00 x, 1.00 x, 1.35 x |
| Farming in Tide Flats (37 catches an hour) | 19.2 | 1.03 x, 1.03 x, 1.40 x |

The falloff holds farming to about one normal hour. The heavy player's normal hour is lower only because their two-hour day spreads the daily caps thinner.

### Against the targets

| # | Target | Result |
| --- | --- | --- |
| 1 | Three player types over 30 days | Met (tables A to I) |
| 2 | 60 to 70% removed in the first two hours | Casual 68%, regular 59%, heavy 57%. The test asserts 57 to 73% ("about"). Heavy sits at the floor, as it did before (58%) |
| 2 | 80 to 95% after Greenwood for regular and heavy | 90% and 87% |
| 2 | Never unable to buy a lasso and a Tonic | Zero times in 600 runs |
| 3 | First common breed about four minutes of Greenwood income; casual about two breeds a day | 4.5 to 4.7 minutes; casual 1.9 a day in week 1, 1.8 later |
| 4 | Prism about 5 (regular) and 8 (heavy) a day, mostly from tasks, giants and quests; early burst; first breed with the mentor's Prism | 5.9 and 8.1; week 1 nearly double; first breed at minute 11 on day 1 in every test run, covered by the mentor's 2 Prism |
| 4 | Typed candy keeps gem tiers scarce (regular near 1.7, 4.1, 10.2 days) | 1.8, 4.4, 10.9 days (table G). The test asserts two thirds to one and a half times the old figures |
| 4 | A Sand starter is not stuck in Greenwood | 3.0 (casual) and 6.1 (regular) breeds with a Sand parent in the first two days (table H). The test asserts at least 1.5 and 3 |
| 4 | Catch-and-release for an hour earns at most 1.5 x a normal hour | 1.00 to 1.40 x (table I) |
| 5 | Regular holds 2 to 7 days of income after week 1; nothing piles up without limit | Regular 2.3 days (mean of days 8 to 30) |
| 6 | First on-level giant costs about one session's spare coins; no long lockout | 0.5 to 1.0 sessions; worst wait 20 minutes |
| 7 | Every faucet capped or diminishing; release below catch and breed in coins and candy | Asserted in the test |

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

Typed candy (20 November 2026):

9. **`CANDY_COST` kept its values (1, 2, 5, 12, 30) but is paid per parent, in its own type.** A pure pair's price doubled; a regular player's candy for one type (Prism plus their best type) roughly doubled too, so a regular player's gem-tier pace stayed within 7% of the single-candy model. A first try at 1, 1, 4, 9, 22 per parent (with a looser falloff) made a regular player's gem tiers 20 to 27% faster (1.4, 3.0, 7.5 days).
10. **Catch 1, 2, 6, 12, 24 by rarity; release 0.5, 0.5, 3, 6, 12**, with fractions paid as they add up. One common catch pays for one common parent of its type. A release must pay less than the catch, so a common release pays one candy every second release.
11. **Falloff of 3 full claims per type per day, then x0.5 (releases x0.4), floor a tenth, stop at 40.** The first try (4 full, x0.6) let an hour of catch-and-release earn 1.6 times a heavy player's normal hour; this one gives 1.4 times, and normal play (a regular player catches about five a day, across types) rarely reaches the falloff.
12. **Milestone and daily sources pay Prism, unchanged in amount.** Prism is what lets a player breed a type their biome lacks (table H); the Sand starter in Greenwood relies on it for the first day or two.

## 6. Inputs that are guesses

None of these is a balance number; they describe how people play, and live in the test (`ASSUME`, `PROFILES`), not in `src/config`.

- **Battle and travel lengths**: 0.75 minutes per wild battle including finding it, 2.5 per tamer, 5 per giant, 4 to 6 minutes of travel per quest line, 0.35 plus 0.1 a throw for a lasso attempt.
- **Content counts**: 22, 32 and 42 story wild battles and 6, 8 and 10 tamers per biome; six kinds of wild creature per biome (the Greenwood roster plans eight, which would raise heavy players' income a little).
- **Lasso misses**: 45% (Rope), 30% (Braided), 15% (Gilded); lasso attempts on 40% of story battles.
- **How often players breed**: whenever they can, across four common pairs, keeping only a small reserve. Real players will breed less; that leaves candy unspent and coins piling, not the reverse.
- **Giant win chances** (45 to 65% first try, +15% per failure, 80% on rematches) and gem spawn rates (0.6% of wild encounters from Dust Canyon, 35% of bait spawns).
- **Sessions**: one a day of a fixed length; eggs hatch overnight. Optional spending starts at three days of income held.
- **Types of wild kinds** (`ASSUME.KIND_ELEMENTS`): Greenwood from its roster, Dust Canyon from the roster in progress, Tide Flats a guess (mostly Water). Breeding pairs are random creatures of the biome, so most breeds mix two types; real players may pick pairs to match the candy they hold, which would breed a little more.
- **Catch-and-release**: during the story players keep their catches; after it they release 30%, 50% or 60% at once. Releasing during the story too lowered the first-two-hours coin ratio by 2 to 4 points (fewer full stables, so fewer coin stable expansions) and pushed it under the 57% floor.
- **Holding back for the gem pair**: once a gem pair exists the player keeps its next breed's candy and coins aside, and common pairs use the rest. If common pairs could use no Prism at all while a gem pair exists, regular and heavy players bred about 15% fewer commons after week 1; if nothing is held back, casual players spend the gem pair's Prism and coins on commons.

## 7. Which results are most sensitive

One guess changed at a time (40 seeds each):

| Change | Regular, first 2 h | After Greenwood, regular / heavy | Regular days held | Regular candy unspent | Casual breeds a day |
| --- | --- | --- | --- | --- | --- |
| Baseline | 57% | 90% / 87% | 2.3 | 111 | 1.9 |
| Battles 30% slower | 64% | 94% / 89% | 1.4 | 95 | 1.7 |
| Battles 30% faster | 69% | 87% / 87% | 2.8 | 139 | 1.9 |
| Lasso misses x1.5 | 58% | 89% / 87% | 2.3 | 74 | 1.9 |
| Half of breeds skipped | 59% | 88% / 88% | 2.4 | 129 | 1.8 |
| Gem spawns x3 | 58% | 89% / 88% | 2.3 | 189 | 1.8 |
| Giants harder | 58% | 90% / 88% | 2.1 | 99 | 1.9 |

(Re-run with typed candy on 20 November 2026; candy left counts every type and Prism.)

- **Battle length is the input that matters.** Coins come per battle and costs come per breed, so slower battles squeeze regular players (96%, one day of coins held) and faster ones make everyone richer. Measure it first.
- **How often players breed** moves candy, not coins: other sinks absorb the coins. Lasso misses barely matter because lassos are cheap. Gem spawn rates and giant difficulty move candy use, not the coin ratio.
- **The first-two-hours ratio** depends mostly on pens and hatch time, not prices.

## 8. Five numbers to watch in the first playtest

1. **Minutes per wild battle, including finding the creature**, and wild battles per hour of play. Every coin result scales with it (section 7).
2. **Coins removed as a share of coins created, per player per day**, split by source and sink and by hours played (first two hours, after Greenwood, after the story). Targets: 60 to 70%, then 80 to 95%.
3. **Unspent Breeding Candy per player at day 7 and day 30, split into Prism and each type, and catches a day by type.** Growing Prism with falling coins means breeding is coin-starved (raise income); Prism near zero with typed candy piling up in types the player never breeds is expected. Catches a day and the share released set typed income: if real players catch far more than the simulation's 2 to 16 a day, gem tiers come faster (table G), and the falloff or catch amounts need lowering.
4. **Median and 90th-percentile coin balance by account age, in days of that player's income.** Target 2 to 7; a rising 90th percentile means the decorations need more items.
5. **Giant attempts per first clear and minutes between a failed attempt and the next attempt.** Targets: about 1.2 to 1.6 attempts, under 20 minutes.

## 9. Not covered yet

- Casual PvP coins, the trade fee and ranked candy are configured but not simulated; re-run the simulation when PvP ships.
- Biome 4 onwards uses placeholder multipliers; re-run when the Mire is designed.
- `LASSO_MIN_TIER` (a gem creature needs at least a Braided Lasso) is assumed for the release rule. If capture design lets a Rope Lasso catch everything, set every entry to `Basic`; release payouts then lower themselves.
- Gem purchases (extra pens, hatch speed-ups) are left out. A player with four pens breeds more, spends more coins and runs out of candy sooner.
- Tide Flats' types are a guess. If its roster spreads across more types than four Water kinds, players put less candy on one type and gem tiers come a little slower.
- Nothing grants typed candy yet: the capture service (approval pack 2) must call `Economy.catchCandy` and `Economy.releaseCandy` with the saved daily counts, in the same step that adds or removes the creature.
