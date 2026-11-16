# Trading and the coin economy

Date: 16 November 2026
Status: research, nothing decided

## Summary

- Every big Roblox trading game has converged on the same safety kit: a two-step confirm that resets when the offer changes, a countdown before the final button, locked items while a trade is open, and a gate before a new account can trade (a quiz, a level, or hours played).
- The documented duplication incidents (Murder Mystery 2 in 2017, Grow a Garden in July 2025, Fisch in January 2025) all came from item transfers that were not atomic or from a reward faucet with no cap. Each ended with trading or gifting switched off, duped items deleted and bans. The fix is cheaper to build first than to retrofit.
- Roblox data stores cannot write two keys atomically, and ProfileStore only locks one player's profile per server. A safe trade needs a small two-phase commit of our own: escrow in both profiles, one ledger key as the commit point, and recovery on next load.
- Roblox's rules ban real-money sales and third-party Robux services, and require `IsPaidItemTradingAllowed` for trading anything bought with Robux. Our creatures are earned, so the simplest position is: nothing bought with Gems or Robux is ever tradable.
- With coins untradable, coin inflation stays inside each account. The thing that can inflate across the whole game is creature supply, so creature faucets and sinks need tracking as closely as coins.
- Recommended: creature-for-creature trades only, same server only, a coin trade fee paid to the game (a new sink), giants and prize wraps account-bound at launch, and PvP coin rewards capped per day and paid only from matchmade games.
- Limit of this research: page fetches were blocked for every host tried in this session (about.roblox.com, create.roblox.com, devforum.roblox.com, fandom.com, allthings.how). Almost every web claim below is therefore "snippet". The Roblox policy pages must be read directly before milestone 9.

Confidence labels: **sourced** = page opened (here, only the repo's earlier research, which did open the Roblox docs on 11 November 2026); **snippet** = search result text only; **inference** = my reasoning.

## 1. How trading works in the big games

| Game | Trade flow and confirmation | Gate, locks, limits | Value drivers | Confidence |
| --- | --- | --- | --- | --- |
| Adopt Me | Two-step trade. Confirmation resets if either side changes items. A delay of about 15 seconds before confirm (community wiki). The game warns when a trade looks unfair. Nine slots, added to end split "part one, part two" trades. | Trade Licence earned by passing a safe-trading quiz in the Safety Hub; can be retaken. Cross-server Trading Hub went live 31 July 2026; the Trading Phone unlocks after two hours of play; listed pets are locked (cannot be equipped, changed or traded elsewhere). | Retired eggs (Safari, Jungle, Farm) hold the highest values; pets still obtainable lose value as supply grows; Neon and Mega Neon multiply value. No currency in trades, so value is quoted in pets on community value sites. | snippet [1][2][3][4] |
| Pet Simulator 99 | Direct trades, Trading Plaza booths, auctions and a mailbox. Items sell for diamonds. | Pro Trading Plaza needs several Huge pets or a Titanic (guides disagree: 5 or 10). | "Exists" count and RAP (recent average price) shown per pet. One October 2026 guide: a Titanic with about 82 copies is worth roughly 200 times one with 3,932 copies. RAP on a low-count pet is unreliable because few sales sit behind it. | snippet [5][6][7] |
| Murder Mystery 2 | Standard two-sided window. | Trading locked until level 10, added December 2021 to stop duping and scam accounts (one guide). Default knife and gun untradable. | Never-returning items; community value lists. | snippet [8] |
| Blox Fruits | Trade at a table in the Second or Third Sea. | Level gate, most guides say about 700 (Second Sea access); sources conflict (100 to 750). | Community "fair range" rules of thumb only. | snippet, weak [9] |
| Creatures of Sonaria | Separate Trade Realm. Species, stored creatures and the Shoom currency can be offered. | Currency capped at 3,000 Shooms per slot, 9,000 per trade. Tikits are not tradable. | Discord value servers. | snippet [10] |
| Loomian Legacy | Trade Resort, up to four Loomians each side. Coloured circles show hidden traits (gleaming, secret ability, variant) and the game tells players to re-check traits before confirming. | Rules ban multi-step trades, middlemen, real-money buying and cross-trading for Robux or other games' items. Penalty: trade ban. | Gleaming and secret-ability traits. | snippet [11] |
| Grow a Garden | Trading system launched 2 August 2025. Each action in the trade has a 5-second cooldown and items lock after it. Requests time out. | Pet gifting was disabled for about two weeks in July 2025 after a dupe (section 2). | Pet rarity; community lists. | snippet [12][13] |
| Steal a Brainrot | Trade Machine added 22 February 2026: three screens, both players see the full terms before either confirms. Reworked in Update 53 (13 June 2026) with a Trading Plaza. | Details of Update 53 not retrieved. | Mutations and traits. The most common high-value scam in 2026 is swapping a mutation or trait mid-trade. | snippet [14][15] |
| Dragon Adventures | Not found. | Not found. | Not found. | could not verify |

**Serial numbers and limited counts**

- Pet Simulator 99 shows how many copies of each Huge or Titanic exist, and the market prices scarcity steeply (the 82 versus 3,932 example above). Serial-specific pricing ("#1") was not found in any source; a resale listing describing a Huge as "random serial" suggests low serials carry a premium. snippet plus inference [6].
- Roblox Limiteds: trading needs a Roblox Plus subscription (Plus replaced Premium on 30 April 2026, about $4.99 a month), both sides must have trading enabled, items carry holding periods (one source: up to 30 days after a launch purchase, 7 days after a resale purchase, 2 days after a trade), Robux added to a trade is charged a 30% fee, and trading is restricted for South Korean accounts. Sources disagree on details. snippet [16].
- Lesson for us (inference): show the count ("1 of 214") as well as the serial, because the count is what the market reads. Put a hold on a creature after it is traded, as Roblox does.

**What the games have in common (inference from the table)**

1. Confirm resets on any change, then a forced pause. This kills the last-second swap.
2. The window shows the traits that decide value, because trait swaps are the main scam once the simple swap is blocked.
3. A gate that costs time, so throwaway accounts cannot trade on day one.
4. "Trust trades" (I give now, you give later) are the top scam everywhere and are simply more trades than the window allows. More slots (Adopt Me's nine) remove the excuse.
5. Developers do not refund scams. Uplift's support site says Adopt Me does not return items lost to scams. snippet [17].

## 2. Duplication and scam incidents

| Incident | What happened | Developer response | Confidence |
| --- | --- | --- | --- |
| Murder Mystery 2, 2017 | Players moving items between their own alt accounts found the items were copied. The Corrupt knife, then the second rarest, was flooded. | Trading shut down; duped items collected and deleted; many bans; duplicated Batwings were turned into a marked "Glitch" knife. | snippet (fan wiki) [18] |
| Grow a Garden, July 2025 | A lag-based method copied rare pets when they were gifted to another player. | Pet gifting turned off for all servers for about two weeks while the back end was rebuilt; duplicates expected to be scrubbed. A full trading system followed on 2 August 2025. | snippet [13] |
| Fisch, January 2025 | A daily-reward bug paid out huge sums; a day later an item dupe appeared. | Targeted rollback of accounts with impossible streaks (over 175 days), ban wave, appeals through Discord. Innocent receivers were flagged but not wiped. | snippet (one blog) [19] |
| Steal An Egg, 2026 | Disconnecting at the moment of purchase duplicated an egg. | Reported as patched. | snippet [20] |
| Roblox Limiteds, 2026 | Traders accept a trade, then claim the account was compromised. Support rolls back one side: the claimant keeps what they received and the other player loses their items. | No staff reply seen. | snippet (DevForum thread title and summary) [21] |
| Pet Simulator X, Adopt Me, Dragon Adventures | No documented dupe with a developer statement was found. | | could not verify |

**How these happen technically**

- A trade writes two players' data. Roblox data stores have no multi-key transaction; the official best-practices page says writes across keys are not atomic, and multi-key `UpdateAsync` is only a feature request. snippet [22].
- The classic dupe: the trade completes in memory, one player leaves or the server crashes, one save lands and the other does not, and the player whose save failed rejoins with the old data. snippet (DevForum thread on the write limit) [23].
- Session locking (ProfileStore) stops two servers holding the same profile, which closes the "rejoin another server and load stale data" path. DevForum posters call it mandatory for dupe prevention. It does not make a two-profile change atomic. snippet [23][24].
- ProfileStore's own docs warn that the `Steal` argument bypasses the session lock that prevents duplication. Never use it in game code. snippet [25].
- Teleport data can be replayed by an exploiter for up to 48 hours, so item or currency state must never travel in teleport data. snippet [26].
- Gifting, mailboxes and cross-server listings are the highest-risk paths because the two profiles are on different servers. Grow a Garden's dupe was in gifting. inference from [13][24].

**Best practice found**

- Escrow both sides' items while the trade is pending and run the swap as one operation that fully completes or fully rolls back. snippet [27].
- Apply the swap without yielding once both profiles are confirmed active on the same server. snippet (ProfileService thread) [28].
- A cross-server cooldown after each trade, because players can hop servers. snippet [23].
- Libraries with multi-key transactions exist: Lyra (`txAsync`, advertised for dupe-proof trades) and Ledger. Lyra's README says its transactions are not yet battle-tested at scale and advises against use where data loss would be catastrophic. Our rule 3 fixes ProfileStore, so treat these as reference designs, not a switch. snippet [29].
- `ProfileStore:MessageAsync` delivers a message to a profile on any server (or offline) using one `UpdateAsync` per side. It is the supported way to reach another server's profile if cross-server delivery is ever needed. snippet [25].
- No source described using MemoryStore as a trade lock. A MemoryStore key with a short expiry as a per-player "trade in progress" flag across servers is my inference, not a cited practice.

## 3. Roblox's rules on trading in 2026

| Rule | What it says | Confidence |
| --- | --- | --- |
| Roblox Economy (Community Standards) | Third-party services may not be used to buy, sell, trade or give away Robux (gift cards excepted). Creators who allow trading of items priced in Robux must use `PolicyService` `IsPaidItemTradingAllowed` so only eligible users can do it. | snippet of the official page [30] |
| `IsPaidItemTradingAllowed` | When true, the player may trade virtual items bought with in-experience currency or Robux. When false, do not let them trade paid items or results of paid random items. | sourced in repo research (`docs/research/ROBLOX_POLICY.md`, point 2) and snippet [31] |
| Grey area | A DevForum thread asks whether a currency earned both by play and by paying is tradable when the flag is false. No official answer was found. Which countries return false is not published. | snippet [32] |
| Paid random items | An archived 2023 copy says results of paid random items may not be traded or sold for Robux, real currency or anything of value. Current wording not checked. | snippet [30] |
| Real-money trading and accounts | Secondary summaries list buying or selling accounts and selling items for real money as economy violations, and scams as a violation that can end in account deletion. Roblox's help page says it cannot enforce deals made outside official features. | snippet (third-party summary and help article) [33] |
| Gambling | No real money, Robux or in-experience items of value may be exchanged in connection with gambling. Already handled: coin bets were removed. | snippet [34] |
| Age and region | No Roblox rule was found that restricts in-experience trading by age. The content-ratings page ties neither chat nor trading to maturity labels (repo research, point 6). Chat needs an age check and is limited to nearby age groups, so many trading pairs cannot type to each other. Roblox's own Limiteds trading requires Plus and is restricted in South Korea. | sourced in repo research; snippet [16] |

What this means for us (inference):

- Creatures are caught or bred with earned coins, so they are not "paid items". Gems buy slots and speed-ups only. If nothing bought with Gems or Robux can be traded, the flag is never decisive, but check it anyway and treat false as "trading off for anything touched by Gems".
- A creature hatched faster with a Gem speed-up is a possible edge case. I could not find guidance. The conservative reading is that a speed-up does not make the creature a paid item, since the result is the same without it. Ask Roblox or re-read the policy page before milestone 9.
- A 16+ soft launch does not exempt the game from any trading rule found here. It lowers the scam risk to young players; it does not change the policy.
- Because many players cannot chat, the trade window needs preset messages. Adopt Me added quick chat and "verified person" icons to its trade window in July 2026. snippet [35].

## 4. Economy health

**What the evidence says**

- Supply drives value. In Adopt Me, pets from retired eggs hold value and pets still on sale depreciate; in Pet Simulator 99 the copy count sets the price. snippet [3][6].
- A single uncapped faucet can wreck an economy in a day (Fisch's daily reward). snippet [19].
- Guides describe Pet Simulator 99's tradable-diamond economy as aggressively inflationary; no figures or developer statements were found. snippet, weak [7].
- No inflation history was found for Dragon Adventures or Adopt Me with numbers. Could not verify.
- Metrics named in Unity's economy guide: sink-to-faucet ratio, inflation rate, currency velocity, days of currency on hand. snippet [36].
- Ratio rules of thumb, all from design blogs and none authoritative: faucets at 1.1 to 1.3 times sinks per progression tier; daily earned over spent between 0.8 and 1.2 is healthy and above 1.5 signals inflation. Warning signs: the median balance of long-term players keeps rising, and purchases per shop visit fall. snippet [36].
- Tradable currency invites caps: Sonaria limits Shooms per trade. snippet [10].
- Pokémon GO charges a currency fee on every trade (100 to 1,000,000 Stardust, falling with friendship) and allows one "special" trade of a rare creature per day. The stated reason is to stop a black market in rare creatures. snippet [37].

**Should coins be tradable? No.** (inference, agreeing with the review)

- Tradable coins become the real-money-trading product and the reason to farm alt accounts through quests and capped PvP rewards.
- With untradable coins, each player's coin balance only affects their own sinks. There is no shared price level to inflate.
- The cost: players will invent a commodity currency (a common mid-value creature), as Adopt Me players did. That is acceptable, and a coin fee on each trade lets the game still tax the market.

**The real inflation risk is creatures.** Every capture and every breed adds a creature for ever unless something removes it. Sinks for creatures are release-for-coins and whatever breeding consumes. If breeding can run without limit, rare parts spread and every rarity tier loses value. A cap on breeds per creature is the standard control (inference; the brief's stat ceilings limit power, not supply).

## 5. PvP rewards without betting

- Riot's Wild Rift strips rank, leaderboard place and ranked rewards from win-traders, adds a 7-day suspension, and permanently bans repeat offenders. It also runs a daily cap on ranked currency. snippet [38].
- Gods Unchained added a cooldown and 7-day bans to stop multi-accounting on its daily reward pool. snippet [38].
- Zooba moved from rewards for top-ranked players to daily rewards for any win, because ranked rewards mostly paid a small group who played a very high number of matches. snippet [38].
- Nothing was found on Clash Royale, Brawl Stars or Roblox-specific ranked reward design. Could not verify.

Design consequences (inference): alt farms pay off only when a reward is uncapped, transferable, or winnable against a chosen opponent. Remove all three.

## Recommendations for this game

Ranked by importance. "Changes" notes any conflict with the brief or `DECISIONS.md`.

### A. Trading design (brief sections 4, 10, 12; milestone 9)

| # | Recommendation | Why | Changes |
| --- | --- | --- | --- |
| 1 | **Build the trade as a two-phase commit on ProfileStore.** (a) Both players in the same server, both profiles active. (b) On final confirm the server re-validates ownership and moves each side's creatures into an `Escrow` field with a `PendingTradeId`, then saves both profiles. (c) It writes one ledger key `Trade/<id>` with status `Committed` and the full manifest: this single-key write is the commit point. (d) It applies the swap to both profiles in one step with no yields, records the trade id in each profile, and saves. (e) On every profile load, any `PendingTradeId` is resolved against the ledger: committed means finish the swap, missing or aborted means return the escrow. | Data stores cannot write two keys atomically (section 2). A crash at any step then leaves a state that recovery can finish or undo, never a copy. | None. Implements the brief's "atomic" default. |
| 2 | **Same-server trades only. No gifting, mailbox, or cross-server listings at launch.** | These were the dupe paths in Grow a Garden and the hardest to make safe. | None. |
| 3 | **Creatures only. No coins, Gems, consumables or anything bought with Gems in a trade.** Check `IsPaidItemTradingAllowed` regardless. | Keeps coins out of real-money trading and alt funnels; keeps the game clear of the paid-item trading rule. | Confirms the review; brief section 10 is silent on coins in trades. |
| 4 | **Trade window:** up to 6 slots a side; each slot shows rarity, serial and count, level, generation, parts and wrap; any change clears both confirmations; a 5-second lock before first confirm and a second "final check" screen listing exactly what leaves and arrives; a warning when one side is empty or the rarity gap is large; preset chat phrases. | Matches Adopt Me, Grow a Garden and Steal a Brainrot; trait swaps are the top current scam. | Extends the "two-step confirm" default. |
| 5 | **Gates and limits (all in `src/config/`):** trading unlocks after the first giant is captured and 2 hours played; a 48-hour hold before a received creature can be traded on; a per-player cooldown of about 15 seconds between trades (lets saves land); a daily trade cap (start at 10); one trade a day involving a serialled creature. | Adopt Me (2 hours), MM2 (level 10), Roblox Limiteds (2-day hold), Pokémon GO (one special trade a day). The hold slows laundering of scammed or duped creatures. | Replaces "short hold for brand-new accounts" with a progress gate plus an item hold. |
| 6 | **A coin fee on every trade, paid by both sides to the game, scaled by the rarest creature involved.** | A sink that grows with wealth, and a tax on alt-to-main transfers. Pokémon GO precedent. | Adds a sink to the list in `DECISIONS.md` (does not contradict it). |
| 7 | **Giants and prize wraps start account-bound.** Giants: an alt can capture each giant once and feed a main account, which would multiply the supply the "once per player" rule was meant to fix. Tournament wraps: a tradable prize is a reason to win-trade and sell. Opening trading later is easy; closing it is not. | Protects serial value and ranked integrity. | **Differs from the suggestions in brief section 15** (giants "yes", tournament wraps "yes"). Both are [Open], not [Locked]. Ayrton to decide. |
| 8 | **Audit trail.** An append-only trade log (trade id, both user ids, creature ids with serials, time, server id) kept in the ledger store and sent to analytics. A registry key per serialled creature recording its current owner, checked on load: two owners of one serial is an automatic alarm. A kill switch (live config) that turns trading off game-wide, and a per-player trade ban. | Every incident in section 2 needed deletion of dupes and a shutdown; both need this data. Serials make dupes of the rarest creatures detectable for free. | Implements brief section 12 "log every trade". |
| 9 | **Publish the scam policy in the trade window:** only the window counts, no trust trades, no refunds for deals made outside it, real-money and cross-game deals lead to a trade ban. Decide the rollback policy now: never roll back one side of a trade. | Uplift does not refund; Roblox's one-sided rollbacks are being abused (section 2). | None. |

### B. Economy plan (brief sections 6, 7, 10)

| # | Recommendation | Why | Changes |
| --- | --- | --- | --- |
| 10 | **Faucets, each with a daily or per-source cap:** wild battles (diminishing per creature kind per day), quests (finite or daily), boss and giant rewards (first clear large, repeats small), releasing creatures (low, below the cost of making one), casual PvP (capped). | Fisch shows what one uncapped faucet does. Release must never pay more than capture or breeding costs, or it becomes a coin printer. | None. |
| 11 | **Sinks:** lassos, consumables, bait, breeding (rising with tier and rarity), the trade fee, and one prestige sink for veterans (coin-bought cosmetics such as name tags or stable decorations). | Veterans need something to spend on once consumables are trivial. | Adds two sinks; consistent with `DECISIONS.md`. |
| 12 | **Targets to tune toward, not promises:** across players past biome 1, coins removed at 80 to 95% of coins created per day; a new player should feel flush (ratio near 60 to 70% in the first two hours); median balance of 30-day players flat week on week; days of coins on hand between 2 and 7. | Blog rules of thumb only (section 4). Treat as starting points for the first playtest. | None. |
| 13 | **Control creature supply:** cap breeds per creature (start at 3 to 5), make breeding cost rise per breed, and report creatures created against released per rarity. Show "1 of N" on serialled kinds. | Creature supply is the inflation that trading exposes. | Adds a breed cap to brief section 7; a [Default] area, not [Locked]. |
| 14 | **PvP rewards:** casual coins only for the first 5 wins a day, only from matchmade games, with reduced or no reward against the same opponent within 24 hours and none in private servers; ranked pays at season end by final league with a minimum number of games; ranked prizes are account-bound; win-trading loses rank and prizes. | Removes the three things alt farms need: no cap, transferability, chosen opponents. | Implements the `DECISIONS.md` line on capped rewards. |
| 15 | **Measure from the first playtest:** coins created and removed per player per day by source; sink share by type; median and 90th-percentile balance by account age; creatures created, released and traded per rarity; serials issued per kind; trades per daily player; share of one-sided trades and of trades between the same pair; trades aborted at each step; recovery events (escrow returned or completed on load). | The last two show scams, alt funnels and commit bugs before players report them. | Extends brief section 12 logging. |

### C. Implementation risks, ranked

| Rank | Risk | Likelihood | Damage | Mitigation |
| --- | --- | --- | --- | --- |
| 1 | Duplication through a non-atomic trade (crash or leave between saves) | High if built naively | Destroys serial value; needs a shutdown and wipe | Recommendation 1; Lune tests that kill the flow at every step; independent review as `CLAUDE.md` requires |
| 2 | A faucet with no cap or an exploit in rewards | Medium | Coin flood in hours | Recommendation 10; server-side caps; alert on any player above the 99.9th percentile of daily income |
| 3 | Alt accounts feeding a main (giants, quest creatures, PvP rewards) | High | Supply inflation, unfair serials | Recommendations 5, 6, 7, 14 |
| 4 | Scams against players (trait swap, trust trade) | High | Support load, reputation | Recommendations 4, 9 |
| 5 | Policy breach (paid item traded where the flag is false; off-platform sales advertised in game) | Low to medium | Moderation action against the experience | Recommendation 3; re-read the Community Standards and PolicyService pages directly |
| 6 | Data store limits during busy trading (several saves per trade) | Medium | Failed or slow trades | Cooldown in recommendation 5; abort cleanly on any failed save |
| 7 | Creature supply inflation from breeding | Medium, slow | Rarity tiers lose meaning over months | Recommendation 13 |
| 8 | One-sided rollbacks by support | Low | Creates a dupe by policy | Recommendation 9 |

### Could not verify (do before milestone 9)

- The current Community Standards wording on scams, real-money trading and cross-trading (page blocked in this session).
- The `PolicyService` reference text and which regions return `IsPaidItemTradingAllowed` false.
- Whether a Gem speed-up makes the hatched creature a "paid item".
- Current data store same-key write limits, and ProfileStore's exact save timing.
- Dragon Adventures trading and economy history; Pet Simulator and Adopt Me dupe incidents with developer statements; Adopt Me Trade Licence launch date and any effect on scam reports.
- A claim in one guide that Adopt Me trading now needs Roblox Plus looks like confusion with Limiteds trading.

## Sources

All opened as search results only unless marked.

1. https://progameguides.com/roblox/adopt-me-adds-methods-to-avoid-being-scammed/
2. https://www.adoptmevalues.app/blog/how-to-trade-in-adopt-me and https://allthings.how/adopt-me-trading-hub-how-to-unlock-the-trading-phone-and-trade/
3. https://www.adoptmevalues.app/blog/what-are-adopt-me-pet-values and https://rowatcher.com/news/adopt-me-trading-values-in-2026-pet-economics-rising-legendaries-scam-prevention
4. https://invenglobal.com/articles/25853/adopt-me-trade-scams-the-patterns-worth-recognising
5. https://twinfinite.net/roblox/how-to-go-to-trading-plaza-pet-simulator-99/ and https://prodigygamers.com/2023/12/12/roblox-pet-simulator-99-how-to-join-the-pro-trading-plaza/
6. https://www.propelrc.com/?p=134343 (Pet Simulator 99 value list, October 2026) and https://ebay.com/itm/155955777718
7. https://rowatcher.com/news/pet-simulator-99-economy-explained-gems-enchants-and-the-true-cost-of-progress and https://www.u7buy.com/blog/how-to-trade-in-pet-simulator-99/
8. https://bo3.gg/articles/mm2-trading-guide-2026 and https://techbullion.com/how-to-trade-in-mm2-complete-guide/
9. https://gamertweak.com/how-to-trade-blox-fruits and https://blox-fruit-cfa.pages.dev/trading/
10. https://macphersonwiki.mywikis.wiki/wiki/Creatures_of_Sonaria
11. https://loomian-legacy.fandom.com/wiki/Trade_Resort
12. https://beebom.com/grow-a-garden-trading-guide and https://www.droidgamers.com/guides/grow-a-garden-trading-update/
13. https://www.sportskeeda.com/roblox-news/why-pet-gifting-disabled-grow-garden and https://roonby.com/2025/07/25/why-pet-gifting-is-disabled-in-grow-a-garden/
14. https://rblxguide.com/games/steal-a-brainrot/updates/update-39-trade-machine and https://allthings.how/steal-a-brainrot-trading-plaza-and-update-53-trading-changes-explained/
15. https://rblxguide.com/games/steal-a-brainrot/updates/trade-scams-and-how-to-avoid-them
16. https://rbxinvest.com/articles/why-cant-i-trade-on-roblox , https://rbxinvest.com/articles/roblox-limited-holding-periods , https://timesaver.gg/blog/how-to-trade-on-roblox
17. https://support.playadopt.me/support/solutions/articles/153000189821
18. https://murder-mystery-2.fandom.com/wiki/The_Duping_Glitch_(2017)
19. https://roonby.com/2025/01/19/roblox-fisch-data-wipe-infinite-money-hack-ban-wave/
20. https://allthings.how/roblox-steal-an-egg-pet-and-egg-dupe-glitches-explained/
21. https://devforum.roblox.com/t/traders-on-roblox-are-reportedly-abusing-rollbacks/4820634
22. https://create.roblox.com/docs/cloud-services/data-stores/best-practices.md and https://devforum.roblox.com/t/multikey-updateasync/38833
23. https://devforum.roblox.com/t/how-should-i-work-within-the-6-second-datastore-write-limit/876169 and https://devforum.roblox.com/t/how-do-i-make-a-secure-trading-system/1903162
24. https://devforum.roblox.com/t/session-locking-explained-datastore/846799 and https://devforum.roblox.com/t/2593202
25. https://madstudioroblox.github.io/ProfileStore/api and https://devforum.roblox.com/t/i-implemented-global-trading-for-my-rpg/4754701
26. https://devforum.roblox.com/t/to-what-extent-can-exploiters-modify-teleportdata/2794032
27. https://bugnet.io/blog/how-to-fix-a-game-economy-trading-exploits
28. https://devforum.roblox.com/t/save-your-player-data-with-profileservice-datastore-module/667805/240
29. https://paradoxum-games.github.io/lyra/api/Store , https://github.com/ironstride/lyra , https://devforum.roblox.com/t/ledger-a-lockless-append-only-datastore-library/4737492
30. https://about.roblox.com/community-standards (search snippet; page itself blocked)
31. https://create.roblox.com/docs/production/monetization/virtual-items and `docs/research/ROBLOX_POLICY.md` in this repo
32. https://devforum.roblox.com/t/seeking-clarifications-for-ispaiditemtradingallowed/3623462
33. https://en.help.roblox.com/hc/en-us/articles/203312390-Player-Trading-Scams and https://rbxscams.org/articles/understanding-roblox-community-standards-whats-allowed-and-whats-not
34. https://en.help.roblox.com/hc/en-us/articles/203313410-Roblox-Rules-of-Conduct
35. https://allthings.how/adopt-me-trading-improvements-update-quick-chat-and-trade-icons-explained/
36. https://unity.com/resources/game-economy-design-guide , https://www.strayspark.studio/blog/game-economy-balancing-spreadsheets , https://bugnet.io/blog/how-to-fix-currency-sink-too-weak-causing-runaway-inflation
37. https://www.sportskeeda.com/pokemon/how-special-trades-work-pokemon-go and https://bulbapedia.bulbagarden.net/wiki/Trade_(GO)
38. https://support-wildrift.riotgames.com/hc/en-us/articles/1500005405342-Bannable-Offenses-Win-Trading , https://games.gg/news/gods-unchained-card-cooldown/ , https://wildlifestudios.com/games/zooba/news/new-reward-system-zooba/
