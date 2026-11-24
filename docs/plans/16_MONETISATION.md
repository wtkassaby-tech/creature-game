# Plan 16: monetisation, healthy and effective (proposal)

Date: 23 November 2026. For: Ayrton. Status: **decided by Ayrton on 23 November 2026** (see section 6); nothing built yet. Extends approval pack 5 (`05_PURCHASES.md`). Written from a review of CLAUDE.md, the brief (sections 4, 10, 11), DECISIONS, pack 5, the economy model and market research, with Roblox's paid-random-items and PolicyService pages re-read on 23 November 2026.

Ayrton's ask: monetise "efficiently and healthily", embedded "without being overly intrusive", not ruling out paid power, with cosmetic wraps, Gems and what they buy, limited creature releases, and a steady micro-transaction such as legendary consumables for Gems or Robux.

## 1. What the rules allow

| Idea | Verdict | Why |
| --- | --- | --- |
| Cosmetic creature looks | Allowed, renamed "Coats" | The cosmic wrap is [Locked] as the only route to Cosmic rarity and is never sold. Coats belong to the account and come off a traded creature |
| Gems | Allowed | Ayrton: Gems buy time and capacity |
| Gems for "certain things" | Allowed for time, capacity, looks | Never coins, candy, lassos or bait, stats, rarity or serials (CLAUDE.md hard rule 4 and "Never") |
| Paid limited creatures | Conflicts with locked rules | Selling serials or rarity is barred; a tradable paid creature meets `IsPaidItemTradingAllowed` and the account-bound decision; its children carry paid parts into the earned economy |
| Limited cosmetics, or event species earned by play | Allowed | Real end dates. An earned-only event species with serials changes the Default "every creature earnable for ever" |
| Legendary consumable that changes a catch or breed roll | Conflicts with hard rule 4; Roblox allows it only with live odds shown and a PolicyService branch | Rule 4 keeps catching and breeding free random outcomes |
| Gem healing or giant items | Roblox allows; conflicts with Ayrton's decisions | Consumables are the giant retry limit and the main coin sink; selling them is selling coins |
| XP boost | Needs a ruling | "Stat boosts" are never sold; levels are capped per badge and ranked is scaled to 50, so a capped XP boost is arguably not a stat boost |
| Subscription, season pass, gifting | Allowed | Not random |

## 2. The plan

**Power ceiling.** Paying buys up to 4 pens, hatching at most 2x faster and instant finishes, stable room, convenience, and (if approved) reaching the badge cap sooner. It never touches a catch, sighting or breed roll, never buys candy, coins, rarity, serials or stats, never helps in ranked, and never buys giant items.

**Passes (Robux):** Bigger Stable +30 (199), Field Satchel: stable anywhere (199), Quick Hatch 2x (299), Second Nest +1 pen (399), Supporter: title, nameplate, a Coat, +10 room (399), Saved Team Slots with PvP (99).

**Gem bundles (Robux to Gems):** 49 to 45, 99 to 100, 249 to 275, 499 to 575, 999 to 1,200, 1,999 to 2,500. Prices read at runtime.

**Starter pack:** 99 Robux once: outfit, lasso skin, 150 Gems, +10 room. No timer.

**Gems buy:** egg finish (1 per 3 minutes left, at least 5), +10 room (150), +1 pen (300), Coats (149 to 299), outfits (199 to 399), lasso skins and throw effects (99 to 199), emotes (75 to 149), nameplates (99), battle backgrounds (199 to 299), home decoration sets (249).

**The steady micro-transaction, inside the rules:**
1. Egg finishes.
2. Keeper's Club subscription, 299 Robux a month: 15 Gems on each daily claim (a login habit), +20 room while active, a monthly Coat and nameplate.
3. Cosmetic consumables: e.g. 10 "Starlight Loops" for 49 Gems, a special throw and catch-card effect, no effect on odds.
4. Optional: a "Training Tonic", 39 Gems, double XP for 30 minutes, stopping at the badge cap. No coin multiplier.

**If hard rule 4 is changed (option b):** one Gem lasso for wild creatures only (never giants) that widens the zone, with the live chance shown on the throw, a few uses a day, hidden where `ArePaidRandomItemsRestricted` is true, and every creature caught with it flagged and never tradable. Never sell Breeding Candy in any version.

**Season pass:** 399 Robux, 4 weeks, with ranked seasons. Free track (coins, Prism Candy, 50 Gems) and premium track (cosmetics and about 300 Gems back), a unique final cosmetic then retired, back-dated rewards for late upgrades, no Robux tier skips.

**Limited items:** event Coats and outfits for a true 2-week window, account-bound, end date shown, paired with an event species earned only by play.

**Free Gems so everyone meets the shop:** 20 per badge, 25 first giant capture, 10 per journal set, 10 weekly challenge, 50 season free track: about 250 over launch content.

**Placement (only where relevant):** stable full (coin option first, then pass, then Gems); egg timer "Finish now: N Gems"; pens screen; the first badge card once; a Tailor in each town where Coats are tried on your own creature; the Circuit hall. Never in battle, after a loss, at the healer, or as a pop-up on join. At most one unprompted offer a session.

## 3. Effect and risks

Benchmarks: about 3.8% of players pay, median $0.70 per payer. The starter pack and cosmetics should lift conversion; the subscription, egg finishes and season pass add repeat spend; retention matters as much as price for Roblox's promotion and Creator Rewards. Risks: any paid random effect without live odds and the policy branch; fake urgency; backlash if paid catch odds end the "honest shop"; tradable limiteds inviting duplication, real-money trading and scams (avoided by keeping paid items account-bound); chargebacks.

## 4. Decisions for Ayrton

1. **The power line:** (a, recommended) time, capacity and looks plus the capped XP tonic; or (b) change hard rule 4 to allow one paid catch item under the conditions above.
2. **Limited items:** (a, recommended) time-limited account-bound cosmetics plus earned event species with serials; or (b) numbered or tradable paid limiteds (needs CLAUDE.md and DECISIONS changed and trading gated by policy).
3. **The launch list and prices** above, including the subscription, free Gem sources and starter pack.

## 5. Build order

Each step goes through the independent exploit review purchases require: (1) purchase plumbing: idempotent ProcessReceipt, pass checks on join, a Gem ledger, a PolicyService cache, a live off-switch; (2) pack 5 passes and Gem spends; (3) Gem bundles, starter pack, free Gem sources; (4) a data-driven wardrobe; (5) the placements; (6) the subscription; (7) the season pass with ranked; (8) event cosmetics and gifting; (9) the XP tonic if approved.

## 6. Ayrton's decisions (23 November 2026)

1. **Power line:** a Robux lasso pass that raises the catch chance is in ("making it a 100% catch rate compared to 50% just means 2x catches, not more likely to catch certain creatures"), and consumables can be bought with Gems. Conditions kept from the rules: the live chance shows on every throw; the paid boost is offered only where `ArePaidRandomItemsRestricted` is false; Breeding Candy is never sold; breeding stays coins and candy.
2. **Limited items:** both: time-limited account-bound cosmetics with earned event species, and paid numbered or tradable limiteds (tradable only where `IsPaidItemTradingAllowed`, and only once trading exists).
3. **Launch list:** passes and Gem bundles (with the starter pack), the cosmetic wardrobe, the Keeper's Club subscription and the season pass.
