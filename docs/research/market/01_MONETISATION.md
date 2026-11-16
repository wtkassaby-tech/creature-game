# Monetisation: what to sell, at what price, and under which Roblox rules

Date: 16 November 2026
Status: research, nothing decided
Produced by: research subagent

## Summary

- The brief's rule (section 11: sell convenience, capacity and looks, never power or random results) is stricter than every Roblox creature game studied. All of them sell at least one of: better odds for rare variants, creatures for Robux, or paid random spins. Fairness is therefore a real point of difference, but it also removes the genre's usual top earners, so capacity, time and cosmetics must be done well.
- The products that fit and are proven in this genre are: creature storage (sold in five of the games studied), "access storage anywhere" (200 to 250 R$), an extra breeding or copier slot (625 to 800 R$ elsewhere), faster hatching (250 to 467 R$), cosmetic packs (99 to 399 R$), and a cosmetic season pass (350 to 749 R$).
- Roblox changed several rules in 2026: paid random item odds were clarified and applied worldwide (26 May), cross-game sales of passes and products ended (29 May), Roblox Plus replaced Premium (30 April), Managed Pricing merged regional pricing and price optimisation (June), and a higher DevEx rate now applies to age-checked US adults in qualifying games (8 June).
- Money per sale: creators keep 70% of Robux spent in their game, and the standard DevEx rate is $0.0038 per earned Robux. A 399 R$ pass therefore pays about $1.06.
- Benchmarks are sobering: across 538 large Roblox games, only 3.8% of players paid anything in a year and the median game took $0.70 per payer. Plan for a small payer base and make the first purchase cheap.
- Limits of this research: this session's network blocked every page fetch (create.roblox.com, Fandom wikis, Rolimons, the Roblox APIs, news sites). Every new finding below comes from search-result text only and is labelled "snippet". All prices must be re-read in the live games before anyone relies on them.
- Proposed launch list (section 7): starter pack 99 R$, storage, portable storage, breeding slot, faster hatching, Gem packs, cosmetic packs, then a season pass once ranked seasons exist. Nothing above 999 R$ at launch.

## 1. Method and confidence labels

- **sourced** = the page was opened and read. In this run that applies only to the owner's earlier research files in `docs/research/`, which were read in full: `ROBLOX_POLICY.md` (11 Nov 2026) and `market/03_MONETISATION_TEARDOWN.md` (12 Nov 2026). Those files read Roblox docs and the game-pass API directly.
- **snippet** = search-result text only; the page itself could not be opened.
- **inference** = my reasoning.
- Hosts that failed: `create.roblox.com`, `apis.roblox.com`, `*.fandom.com`, `www.rolimons.com`, `www.sportskeeda.com`, `earnaldo.com`. They need to be allowed in the session's network settings before the prices and doc wording here can be upgraded to "sourced".
- Nothing was played, signed into or bought.

## 2. What the creature, pet and breeding games sell

Prices are Robux (R$). "Fit" is judged against brief section 11 and DECISIONS.md (Gems buy time and capacity only; coins never sold; nothing random).

### 2.1 Turn-based creature catchers (closest to this game)

| Game | Product | Price | Type | Fit | Source, confidence |
| --- | --- | --- | --- | --- | --- |
| Loomian Legacy | Roaming Charm (permanent access to roaming creatures) | 450 | Access to rare spawns | No (rarity access) | https://loomian-legacy.fandom.com/wiki/LoomiBoost_and_Game_Pass, snippet |
| Loomian Legacy | Gleaming Charm (doubles odds of the rare colour variant; 1/128 with the boost active) | 400 | Better odds | No (rarity) | same page and https://www.rolimons.com/gamepass/1662541, snippet |
| Loomian Legacy | Rally Charm (rally 25% faster, or larger Rally Ranch; the two wiki pages disagree) | 400 | Time or capacity | Yes | same wiki, snippet |
| Loomian Legacy | Ability Charm | 350 | Unclear | Unclear | https://earnaldo.com/blog/blox-monsters-vs-loomian-legacy, snippet, single promotional source |
| Loomian Legacy | 2x Training Points; Experience Boost | 50 each | Faster stat growth | No as written (stat growth) | https://loomianlegacy.wiki/tools/game-passes/, snippet |
| Loomian Legacy | Loomian Care group expansion (10 to 50) | about 50 | Capacity | Yes | same, snippet |
| Loomian Legacy | Boost Tokens (timed LoomiBoosts; also earned from quests and codes) | not found | Timed boosts | Mixed | same wiki, snippet |
| Doodle World | Pocket Storage (storage from anywhere) | 250 | Convenience | Yes | https://doodle-world.fandom.com/wiki/Gamepasses, snippet |
| Doodle World | +1 Copier (second copier) | 800 | Capacity | Yes | same, snippet |
| Doodle World | Offline Tickets (printer earns while away) | 800 | Time | Yes in principle | same, snippet |
| Doodle World | Magnifying Glass (see wild stats before catching) | 450 | Information | Grey: it is a catching advantage | same, snippet |
| Doodle World | Hidden Trait Trinket 700; Misprint Trinket 850 (each doubles a rare-variant chance) | 700, 850 | Better odds | No | same, snippet |
| Doodle World | Gems: 200 for 20; 1,000 for 100; 2,200 for 200; 5,750 for 500; 18,000 for 1,500 | 20 to 1,500 | Premium currency | Yes (the pack ladder, not all its uses) | https://doodle-world.fandom.com/wiki/Gems, snippet |
| Doodle World | Roulette: 300 Gems a spin, about 10% chance of a creature | about 30 R$ a spin | Paid random | No | https://tryhardguides.com/how-to-get-gems-in-doodle-world/, snippet |
| Doodle World | Skins for Gems; hourly rotating bundles for Robux or Gems | varies | Cosmetic | Yes | https://doodle-world.fandom.com/wiki/The_Market, snippet |
| Tales of Tanorio | Tamer+ (golden name, experimental settings) | 550 | Supporter | Yes | https://talesoftanorio.fandom.com/wiki/Tamer_%2B_Gamepass, snippet |
| Tales of Tanorio | Portable Storage 200; Hatching+ 250; Chaining+ 250; Money Trinket 200; Sparkling Nectar 200 | 200 to 250 | Mixed | Storage and hatching yes; money, chaining and sparkle no | https://www.rolimons.com/game/11378364822, snippet, listing about 2.7 years old |
| Tales of Tanorio | Individual creatures | 150 or 300 | Direct creature sale | No | https://krnl.vip/tales-of-tanorio-tier-list/, snippet, old data |

Eleven Doodle World passes exist; three raise rare-variant odds and eight do other things (snippet). The full Loomian Legacy list and its token prices could not be read.

### 2.2 Creature, pet and breeding sims

| Game | Product | Price | Type | Fit | Source, confidence |
| --- | --- | --- | --- | --- | --- |
| Dragon Adventures | VIP (three dragons equipped, faster run, 2x XP, gold chat name) | 300 | Bundle with boost | Partly | https://www.rolimons.com/game/3475397644, snippet |
| Dragon Adventures | Big Backpack | 500 | Capacity | Yes | same, snippet |
| Dragon Adventures | Multi-Accessory (three accessories per body part) | 175 | Cosmetic | Yes | https://dragon-adventures.fandom.com/wiki/Premium_Shop, snippet |
| Dragon Adventures | Season passes: Dragoneer 499, Drakon 749; older seasons 350 with 150 R$ tier skips and 10 levels | 350 to 749 | Season pass | Yes if cosmetic | https://dragon-adventures.fandom.com/wiki/Dragon_Seasons and https://www.sportskeeda.com/roblox-news/dragon-adventures-season-39-pass-all-rewards-dragon-pass-price, snippet |
| Dragon Adventures | Lucky Egg (doubles Rare, Epic, Legendary hatch chance); removed 24 July 2026 "to return after revamping" | 200 | Better odds | No | https://dragon-adventures.fandom.com/wiki/Premium_Shop, snippet |
| Creatures of Sonaria | Storage slots: start with 3, buy up to 10 more, rising price | 89, 129, 149, 179 seen | Capacity | Yes | https://creatures-of-sonaria-official.fandom.com/wiki/Main_Menu, snippet (table garbled) |
| Creatures of Sonaria | Robux creatures (15) and developer creatures (7), "no RNG" | 49 to 1,679 | Direct creature sale | No | https://www.sportskeeda.com/roblox-news/creatures-sonaria-all-robux-creatures-dev-creatures, snippet |
| Creatures of Sonaria | Bundles (Predator Pack 399; Crown of Creatures 1,599); season pass Apex tier 499; premium currency sold | 399 to 1,599 | Bundles, pass, currency | Pass yes; creature bundles no | https://creatures-of-sonaria-official.fandom.com/wiki/Bundles and NamuWiki season pass page, snippet, over a year old |
| Horse Life | Academy semester passes: Equestrian 399 (+1 stable slot), Celestial Rider 749 (+4 stable slots, +20 inventory) | 399, 749 | Season pass with capacity | Yes | https://horse-life-wiki-roblox.fandom.com/wiki/Aetheron_Riders_Academy, snippet |
| Horse Life | Inventory tiers (Robux gives twice the space of the coin price) | 100 per early tier | Capacity | Yes | https://horse-life-wiki-roblox.fandom.com/wiki/Inventory, snippet |
| Horse Life | Stable Club: create for 60,000 coins or 1,599; upgrades 299 to 599 | 299 to 1,599 | Social capacity | Yes | https://horse-life-wiki-roblox.fandom.com/wiki/Stable_Clubs, snippet |
| Horse Life | Premium and Exclusive stalls (winged horses); event capsules and bundles | 199, 499; 249 to 999 | Direct creature sale, some random | No | https://horse-life-wiki-roblox.fandom.com/wiki/Stables_Shop, snippet |
| Catch And Tame | Starter Pack 9; Extra Speed 49; Auto Clicker 99; 2x Food Stock 199; Better Luck 299; Luckyblock Luck 299; Ultra Luck 899; Pet Radar | 9 to 899 | Mostly luck | Only the starter pack idea | https://www.rolimons.com/game/96645548064314, snippet, some listings months old |
| Adopt Me | +1 Pet Pen Slot 295; Premium Plots 285; VIP 480; Millionaire Pack 795; old Starter Pack 99; eggs for Robux | 99 to 795 | Capacity, housing, random eggs | Slots and housing yes; eggs no | `docs/research/market/03_MONETISATION_TEARDOWN.md`, sourced (API read 12 Nov 2026) |
| Pet Simulator 99 | +15 Pets 375; Daycare Slots 625; +15 Eggs 625; VIP 400; luck passes 275 to 3,250 | 175 to 3,250 | Capacity, auto, luck | Slots yes; luck no | same file, sourced |
| Grow a Garden | Almost no passes; seed packs and a season pass as developer products (199 to 1,999) | 199 to 1,999 | Random packs, season pass | Pass only | same file, third-party figures |
| Blox Fruits (RPG) | 2x Money 450; 2x Mastery 450; 2x Boss Drops 350; Fast Boats 350; Dark Blade 1,200; Fruit Notifier 2,700 | 350 to 2,700 | Power and boosts | No, except travel speed | same file, sourced |

### 2.3 What this shows

- **Every creature game sells rarity or power somewhere** (inference from the tables). Shiny charms cost 400 to 850 R$, luck passes 299 to 899 R$, and four of the games sell creatures directly. This is the money the brief chooses to leave on the table.
- **Capacity and convenience sell in all of them.** Storage or slots appear in Loomian Legacy, Doodle World, Tales of Tanorio, Dragon Adventures, Creatures of Sonaria, Horse Life, Adopt Me and Pet Simulator 99. The price range for one capacity purchase is about 50 to 625 R$, with most between 200 and 400 (inference from the tables).
- **A slot that produces creatures is priced highest**: Doodle World's second copier at 800, Pet Simulator 99's daycare slots at 625. An extra breeding slot is this game's equivalent and deserves a premium price (inference).
- **Season passes cluster at 350 to 749 R$**, and two games (Horse Life, Dragon Adventures) run a two-tier pass at roughly 399 and 749.
- **Dragon Adventures removed its paid hatch-luck pass in July 2026**, two months after Roblox clarified the paid random items rules (snippet for both dates; the link between them is my inference).

## 3. Roblox's rules and guidance, and what changed in 2026

| Topic | Finding | 2026 change? | Source, confidence |
| --- | --- | --- | --- |
| Revenue share | Creators earn 70% of Robux spent on their passes and developer products; Roblox keeps 30% | No | https://create.roblox.com/docs/monetize-experiences, snippet. The earlier project research could not confirm this from a fetched page |
| DevEx rate | $0.0038 per earned Robux for Robux earned since 5 Sept 2025 (was $0.0035) | No | https://rolearn.dev/guidance/roblox-devex-requirements-2026/, snippet |
| 18+ DevEx rate | $0.0054 (+42%) for spend by age-checked US players aged 18+ in qualifying games using R15 avatars, from 8 June 2026 | **Yes** | https://about.roblox.com/newsroom/2026/04/roblox-fuels-high-fidelity-games-over-18-players-increases-qualifying-devex-rate-42 (snippet); `docs/research/market/03_MONETISATION_TEARDOWN.md` (sourced) |
| Holds | About 5 days for passes, products and Robux subscriptions (snippet); the earlier research recorded a 30-day escrow (sourced). These conflict, so re-check | Unclear | https://create.roblox.com/docs/production/monetization/subscriptions; `ROBLOX_POLICY.md` |
| Paid random items | "Clarifying Requirements for Paid Random Items", 26 May 2026: every outcome and its real percentage shown before purchase, summing to 100%; every outcome must give some benefit; luck boosts and pity systems must be stated in numbers and the shown odds must update; a bundle containing a random item is itself a paid random item; applies in all markets | **Yes** | https://devforum.roblox.com/t/clarifying-requirements-for-paid-random-items/4654622 and https://www.techtimes.com/articles/319148/20260626/koreas-loot-box-rules-push-roblox-disclose-item-odds-worldwide.htm, snippet |
| Paid random items: exempt | Random rewards earned only through play, with no Robux or paid currency involved | No | https://create.roblox.com/docs/production/monetization/paid-random-items, snippet; `ROBLOX_POLICY.md`, sourced |
| PolicyService | `ArePaidRandomItemsRestricted`, `IsPaidItemTradingAllowed` (when false, do not let the player trade paid items), `IsEligibleToPurchaseSubscription`, `AreAdsAllowed` | No | `ROBLOX_POLICY.md`, sourced |
| Fair selling | Discounts must be genuine; no always-on sales, false scarcity, or countdowns that are wrong or restart; no pressure wording for younger users | No | `ROBLOX_POLICY.md` point 5, sourced |
| Monetisation foundations | Three parts: items, the shop, season passes. Items are "enhancement" (capability) or "expression" (looks). The shop should give context so a new player can judge value. Page updated 10 Aug 2026 | Updated | https://create.roblox.com/docs/production/game-design/monetization-foundations, snippet |
| Starter pack | No dedicated design page found. Defined as an offer shown "within the first few minutes". Roblox's Bundles package sample is single-use with a 15-minute timer and "save 75%" wording, and can show each item's Robux value | No | https://create.roblox.com/docs/resources/feature-packages/bundles, snippet |
| Season pass design | One month is a good first length; at least a week's rest between seasons; start with ten tiers; premium is a superset of free; give back-dated premium rewards on a mid-season upgrade; rewards wanted but "not too valuable"; a unique final reward, retired afterwards; claim by button; a catch-up such as double XP in the last week | No | https://create.roblox.com/docs/production/game-design/season-pass-design, snippet |
| Subscriptions | Robux-priced (minimum 49 R$, any creator, 70% every month, price change allowed every 60 days) or local-currency (five fixed price points, ID or phone verified, 70% in month one and 100% after, 30-day hold). No mutually exclusive tiers. Benefits must hold for the whole term | Robux pricing is new in 2026 (snippet: "Let Your Players Pay for Subscriptions within Experiences in Robux") | https://create.roblox.com/docs/production/monetization/subscriptions and https://devforum.roblox.com/t/let-your-players-pay-for-subscriptions-within-experiences-in-robux/4552995, snippet |
| Regional and managed pricing | Managed Pricing unifies regional pricing and price optimisation under one opt-in. Regional pricing is on by default for passes; developer products are opted in one by one and need prices read at runtime, not hard-coded. Games with gifting or trading must use the user price level API. Roblox reports +26% paying users from regional pass pricing and +4% average earnings from Managed Pricing | **Yes** (docs dated 17 June 2026) | https://create.roblox.com/docs/production/monetization/managed-pricing and https://devforum.roblox.com/t/managed-pricing-one-system-for-better-pricing-and-earnings-growth/4684738, snippet; `ROBLOX_POLICY.md` point 7, sourced. Price optimisation needs about 60,000 transactions in 30 days |
| Cross-game sales | Selling passes and products outside their own game ended 29 May 2026; a Transfers API replaces it with a 10% commission | **Yes** | https://devforum.roblox.com/t/disabling-cross-game-sales-of-passes-and-dev-products-and-introducing-the-transfers-api/4618396, snippet |
| Creator Rewards | Daily Engagement: 5 R$ per Active Spender (at least $9.99 spent in 60 days) who plays 10+ minutes; only a spender's first three games a day count. Audience Expansion: 35% of a new or returning user's first $100 of spend, needs 100+ average daily users. 60-day hold | Benchmarks charts added April 2026 | `ROBLOX_POLICY.md` point 1, sourced; https://devforum.roblox.com/t/new-creator-rewards-analytics-charts-benchmarks/4577265, snippet |
| Roblox Plus | Launched 30 April 2026 at $4.99 a month, replacing new Premium sign-ups. Roblox funds subscriber discounts. Creators can earn up to 100 R$ a month when subscribers use their paid private server, plus a bonus for sign-ups from an in-game prompt (reported amounts conflict) | **Yes** | https://www.businesswire.com/news/home/20260410099173/en and https://tubefilter.com/2026/04/13/roblox-plus-creator-payouts, snippet |
| Discovery | Since August 2026 Roblox's guidance says games strong in both retention and monetisation may get more Home page exposure | **Yes** | https://www.gameanalytics.com/reports/2026-roblox-report, snippet, second-hand |

Worked example (inference): 1,000 R$ spent gives the creator 700 R$, which is $2.66 at the standard rate or $3.78 at the 18+ rate.

## 4. What earns, and how big the payer base is

- GameAnalytics 2026 Roblox Benchmark Report, 538 games with over 1 million monthly users, August 2025 to July 2026: **3.8% of players paid anything** (4.2% the year before). Revenue per paying user by game: $0.32, **$0.70 (median)**, $1.25 (75th percentile), $2.33 (top 10%), $4.80 (top 5%), $55.31 (99th percentile). The top 1% of paying players spend $86.36. Median day-1 retention 10.3%, day-7 1.6%, day-30 0.5%. https://www.gameanalytics.com/reports/2026-roblox-report and https://gamedevreports.substack.com/p/gameanalytics-key-roblox-and-roblox, snippet. The percentile labels were partly unclear in the extract.
- A third-party quarterly report gives a platform game-pass conversion rate of 3.2% to 3.3% for Q4 2025 and Q1 2026. https://rolearn.dev/trend-reports/q1-2026-market-trends, snippet.
- **No genre split for RPG or collection games was found**, and no public starter-pack conversion figure. Roblox's own dashboard has genre and similar-game benchmarks (Top 200, 500, 1,000), which only become visible once the game is live. https://create.roblox.com/docs/production/analytics/analytics-dashboard, snippet.
- Passes against developer products: only opinion was found. RoWatcher argues that repeat purchases from the top 8% of spenders outperform one-time passes, and that products below 40% of revenue after three months is a warning sign. https://rowatcher.com/news/developer-products-vs-game-passes-you-re-using-both-wrong, snippet, unverified.
- Third-party estimates from the earlier research: Blox Fruits $8-14M a month, Adopt Me $5-10M, Pet Simulator 99 $4-8M. Across eight top games the median pass price was 399 R$ and VIP bundles sat at 375 to 480 (`03_MONETISATION_TEARDOWN.md`, sourced for prices, estimates for revenue).
- Reading (inference): with roughly 1 in 25 players paying and a low median spend, the first purchase must be cheap and obviously useful, and repeat spending must come from Gems (time and capacity) and seasonal cosmetics, since the game sells no luck.

## 5. How creature games outside Roblox charge fairly

| Game | Model | Lesson | Source, confidence |
| --- | --- | --- | --- |
| Pokemon HOME | Free plan stores 30 creatures; Premium stores 6,000 for $2.99 a month, $4.99 for three months or $15.99 a year | Storage is the accepted thing to charge for in this genre, and it sells as a subscription | https://en-americas-support.nintendo.com/app/answers/detail/a_id/48800/ and https://www.videogameschronicle.com/news/pokemon-home-details-revealed-premium-plan-is-15-a-year/, snippet |
| Pokemon Champions (free to play, April 2026) | Starter pack, a $9.99 battle pass about every 30 days with 50 rewards, and a membership ($49.99 a year in most reports) giving more box space, more saved teams, extra missions and music | A competitive turn-based battler earning from capacity (boxes, team slots) and a pass, not from stats | https://nintendosoup.com/pokemon-champions-monetization-details-revealed and https://nintendoeverything.com/pokemon-champions-battle-pass-isnt-worth-it-and-why-thats-a-good-thing/, snippet; membership billing differs between outlets |
| Temtem | Cosmetic-only battle pass at 750 Novas (about $7.50) with a free track; finishing the premium track returned enough currency for the next pass. Criticised because the base game was paid; pass XP was doubled after complaints; currency sales later removed | Cosmetic-only passes are accepted, but pass grind speed is where players push back | https://gamespot.com/articles/temtem-developers-respond-to-criticism-of-battle-pass/1100-6507220/ and https://crema.gg/temtem/welcome-to-the-neon-reverie-patch-1-7-is-out-now/, snippet |

Saved team slots are a capacity product that none of the Roblox games above were seen selling, and that Pokemon Champions does (inference; worth a look for PvP players).

## 6. Policy fit: 16+ soft launch now, all ages later

- **16+ launch.** No fee. The audience is age-checked, so a US 18+ share of spend may earn the $0.0054 rate, but only in "qualifying games" using R15 avatars; whether a turn-based creature game with R15 player avatars qualifies was not verified (snippet plus inference). Do not plan revenue on it.
- **All ages later.** ID check, two-step verification, and a refundable 1,000 R$ fee per game or two months of Plus or Premium; the game shows to age-checked 16+ players first and needs 250 unique plays from highly engaged age-checked users within 60 days. Third-party guides and forum posts quote 500, and one doc snippet says the fee is refunded if the game keeps 25 highly engaged players for 60 days. https://github.com/Roblox/creator-docs/blob/main/content/en-us/production/publishing/kids-and-select.md and https://devforum.roblox.com/t/alternate-publishing-requirements-for-roblox-kids-and-select/4630944, snippet. The brief's "250" matches the official doc snippet; re-check before applying.
- **Shop wording.** Roblox's guidance against pressure and fake urgency applies at every age and is stricter in tone for younger users (`ROBLOX_POLICY.md`, sourced). Writing the shop to the all-ages standard from day one avoids a rewrite (inference).
- **Trading and paid items.** `IsPaidItemTradingAllowed` can be false for a player, in which case paid items must not be tradeable for them. The simplest safe design is that anything bought with Robux or Gems (cosmetics, skins, slots) is bound to the account and never enters a trade; creatures bred or caught with coins are not paid items (inference from `ROBLOX_POLICY.md` point 2).
- **Hatch speed-ups.** A Gem speed-up on an egg is time, not a random result, as DECISIONS.md records. To keep that defensible, the offspring should be fully decided by the server at the moment of breeding, before any speed-up is possible, and a speed-up must never re-roll or improve it (inference; Roblox's definition covers items bought "directly or indirectly" with Robux, so the separation should be visible in the code and the UI).
- **Coin bets** are removed (DECISIONS.md), so the gambling rule no longer bears on monetisation.
- **Maturity questionnaire and IARC.** Needed before any wider release; Kids and Select games without IARC ratings may leave the Australian catalogue from 26 January 2027 (`ROBLOX_POLICY.md` point 6, sourced).
- **Rewarded ads** need 2,000 unique visitors a month and a fixed, non-random reward (`ROBLOX_POLICY.md` point 3, sourced). Not a launch item.

## 7. Proposed launch product list (priority order)

Price bands are judgement based on sections 2 and 4. Every product is convenience, capacity or cosmetic; none is random; none sells coins. Anything bought is account-bound.

| # | Product | Kind | Price band (R$) | Why, and the comparison |
| --- | --- | --- | --- | --- |
| 1 | Starter pack: one cosmetic lasso skin, one trail, one extra storage box, a small Gem grant. Once per account. No coins and no consumables | Developer product | 99 to 149 | The cheapest route to a first purchase. Adopt Me's was 99; Catch And Tame's is 9. If timed, the timer is real and never restarts |
| 2 | Creature storage: extra boxes in steps, with a one-off "big storage" pass | Gems per box; pass | Box about 80 to 150 in Gems, rising; pass 299 to 399 | The most common fair product in the genre (Creatures of Sonaria 89 to 179 a slot, Adopt Me 295, Pet Simulator 99 375, Dragon Adventures 500) |
| 3 | Portable storage: open creature storage anywhere | Pass | 199 to 249 | Doodle World 250, Tales of Tanorio 200. Pure convenience |
| 4 | Extra breeding slot (one pass, plus at most one or two more for Gems, hard-capped) | Pass | 399 to 599 | Doodle World's second copier is 800, Pet Simulator 99 daycare 625. Breeding still costs coins, so the coin sink holds |
| 5 | Faster hatching (a fixed, stated speed such as 1.5x or 2x) and single-egg speed-ups | Pass; Gems | Pass 299 to 399; speed-up 20 to 60 in Gems by time left | Steal An Egg 467, Tales of Tanorio 250. Buys time only |
| 6 | Gem packs, five steps, best value in the middle, none above 1,999 | Developer products | 49, 99 or 199, 499, 999, 1,999 | Doodle World sells 20 to 1,500. Prices read at runtime so Managed Pricing can be switched on |
| 7 | Cosmetic packs: trail and aura pack, lasso skins, town-home skins | Pass or Gems | 99 for a small pack, 199 to 399 for a premium one | The only mass-market 99 R$ items in the earlier teardown were cosmetic packs |
| 8 | Supporter pass: name colour or tag, one exclusive cosmetic, a little storage | Pass | 399 to 449 | VIP bundles sit at 300 to 550 across the genre. Keep boosts out of it |
| 9 | Saved team slots for PvP | Gems or pass | 99 to 199 | Pokemon Champions sells team slots; capacity with no battle effect |
| 10 | Season pass, cosmetic only, one month, ten tiers, free and premium tracks | Developer product each season | 349 to 499 | Ships with ranked seasons (brief stage 2), not at launch. Dragon Adventures 350 to 749, Creatures of Sonaria 499, Horse Life 399 and 749 |
| 11 | Limited-time event cosmetics with a true, printed end date | Developer product or Gems | 199 to 499 | Brief section 11 already allows these |
| 12 | Private servers | Roblox setting | 50 to 100 a month, or free | A paid server may earn up to 100 R$ a month per Roblox Plus subscriber (unverified amount) |

Later, not at launch: a monthly subscription (storage plus a monthly cosmetic, in the manner of Pokemon HOME, 149 to 299 R$) once there are returning players; rewarded ads with a fixed reward once the visitor threshold is met.

Do not sell (all seen in competitors): rare-variant charms or luck of any kind, creatures for Robux, roulette spins or capsules, coin or money boosts, stat-growth boosts, spawn radars or stat viewers that help catching, consumable bundles (they are coins by another name), tier skips that reach ranked rewards.

## Recommendations for this game

1. **Keep the "convenience, capacity, looks" rule and say so on the store page (brief section 11; pillars 2 and 4).** Every competitor sells rarity or power. An honest "no paid luck, no paid creatures" line is a marketable difference and keeps traded creatures valuable. No change to a locked item.
2. **Adopt the section 7 list as the answer to the open "Monetisation list" item (brief section 15).** It extends the [Default] list in section 11 with a starter pack, portable storage, a supporter pass, saved team slots and private servers. These are additions to a Default, and they touch Robux, so they need Ayrton's approval before building.
3. **Cap paid breeding capacity and hatch speed in config, and model them before launch (brief sections 7 and 10; pillar 4).** Extra slots and faster hatching increase how many creatures a payer can produce, which presses on supply and trade value. Suggested cap: at most three slots in total and at most 2x hatch speed. Breeding must still cost coins every time. This refines a Default; no locked item changes.
4. **Decide offspring at breed time and never let Gems touch the roll (brief section 11; DECISIONS.md line on paid speed-ups).** This keeps speed-ups clearly outside the paid random items rule as clarified on 26 May 2026. Consistent with DECISIONS.md.
5. **Make everything bought with Robux or Gems account-bound and untradeable (brief section 10 trading; section 11).** This satisfies `IsPaidItemTradingAllowed` without per-player branches and stops Robux turning into tradeable goods. It is a new rule for the brief, not a change to a locked one.
6. **Do not sell consumables, lassos or bait for Robux or Gems, even in a starter pack (DECISIONS.md: coins are never sold; consumables are a coin sink).** A lasso bundle is coins in another form and would weaken the sink.
7. **Do not sell an XP or training boost at launch (brief section 11: no stat boosts).** It is the genre's cheapest and most common pass (50 R$ in Loomian Legacy, 2x XP inside Dragon Adventures VIP), and ranked play is level-scaled, so it would be allowed under the owner's "paying to progress faster" view on the golf project. It would, however, change the brief's "not for sale: stat boosts" line, so it is flagged for Ayrton and left out.
8. **Hold the season pass until ranked seasons exist, then follow Roblox's design guide (brief sections 10, 13 and 14).** One month, ten tiers, premium as a superset of free, a retired final cosmetic, back-dated rewards on upgrade. Keep ranked rewards earnable only by play; never sell tier skips that reach them.
9. **Read all prices at runtime and turn on Managed Pricing for passes at launch (brief sections 11 and 12).** Regional pricing is reported to raise paying users by 26%. Price optimisation will not be available until about 60,000 transactions a month. No balance number hard-coded.
10. **Write the shop to the all-ages standard from the start (brief section 11 publishing).** No urgency wording, no restarting timers, no "worth X" claims that are not true, a clear "what you get" line on every product. This costs nothing at 16+ and removes a rewrite later.
11. **Budget on $0.0038 per earned Robux and a payer rate near 3 to 4% (brief section 11 "creators keep about 70%").** Treat the 18+ rate, Creator Rewards and Roblox Plus bonuses as upside, not plan.
12. **Before launch, re-verify this file with the blocked hosts allowed (brief section 11: "must be re-checked before launch").** Priorities: the 70% share and hold period on Roblox's own pages, the 250-play all-ages threshold, the 26 May paid random items post, and live prices in Loomian Legacy, Doodle World and Horse Life.

## What could not be verified

- Any page content directly: all new findings are search-result text.
- Developer products (consumables, token packs) in every game studied; only passes and wiki-listed items appeared.
- Loomian Legacy Boost Token prices, the full Dragon Adventures premium shop, current Tales of Tanorio prices (the listing found is about 2.7 years old), and which Creatures of Sonaria slot costs which price.
- Per-game revenue, payer conversion or ARPPU for any creature game, and any RPG or collection genre split.
- The five local-currency subscription price points, the exact Roblox Plus sign-up bonus, and the criteria for an 18+ "qualifying game".
