# Market research: summary and what it decides

Date: 16 November 2026
Status: summary of reports 01 to 09 in this folder. The decisions it leads to are logged in `../../DECISIONS.md` as [Default]s that Ayrton can overrule.

**How far to trust it.** Reports 01 to 07 were written while most source sites were blocked, so their market numbers come from search-result text and some conflict. Report 08 then checked 70 Roblox policy and technical claims against Roblox's own pages; those are solid. Reports 04 and 09 and the `prototype/` code rest on our own simulations. Competitor player counts, prices and histories should be re-checked before they are quoted anywhere public.

---

## 1. The market in one page

| Finding | Source | Confidence |
| --- | --- | --- |
| Original turn-based creature RPGs on Roblox total about 5,000 players online at once (Loomian Legacy 1,900-3,400, Doodle World about 1,000, Tales of Tanorio about 100) | 02 | Search text; trackers disagree |
| The much larger creature games (Creatures of Sonaria, Dragon Adventures) are built on breeding, raising and trading, with no story gate | 02 | Search text |
| The genre's defining failure is unfinished stories: Loomian Legacy has shipped 4 of 8 main stages in seven years, with gaps growing to three years | 02 | Search text |
| Project Pokemon was a complete loop (8 gyms, Elite Four, post-game, trading, PvP; about 270 million visits) and was deleted for copyright in August 2018, after duplication exploits and data resets | 02 | Search text |
| Every rival studied sells rarity or power (luck passes, paid creatures, paid spins). This game's "no paid luck, no paid creatures" rule is stricter than all of them | 01 | Search text |
| Across 538 large Roblox games, 3.8% of players paid in a year, median $0.70 per payer | 01 | Search text |
| All four rival creature RPGs hide wild creatures in tall grass; none shows them roaming | 03 | Search text |
| Roblox bans "betting, wagering, or casino-style mechanics", simulated or real | 08 | Confirmed at source |
| The all-ages route needs 250 plays from engaged players in 60 days (cut from 500 on 19 August 2026); the 16+ route needs an age-verified account at least 2 days old | 08 | Confirmed at source |
| Pass and product earnings are held about 5 days; creators keep about 70%; standard cash-out rate $0.0038 per Robux | 08, 01 | Confirmed at source |
| Roblox cannot save two players' records in one step, so a trade needs its own commit design | 06, 08 | Confirmed at source |

**Where this game can win:** part-based breeding inside a turn-based battler (nobody has both), a story that finishes on a published schedule, catching by skill instead of tiny odds, visible roaming creatures, and an honest shop.

**The main commercial risk:** the turn-based creature audience on Roblox is small. Judge the soft launch on whether players come back (day 1, day 7, play days per player), not on how many are online.

---

## 2. What each report decides

### Structure and pacing (02)

- Three-biome launch of 4 to 5 hours; first badge within 60 minutes; rival battle in the first minute; a second creature by minute 4; the mentor's gifted egg at about minute 10.
- Something new every week (a challenge, a returning creature, a giant rematch) and a new biome every 6 to 8 weeks. Have Mire, the fourth biome, content-complete before the soft launch.
- Show the whole journey from the start: an eleven-biome map and "Chapter n of 11".
- Every creature stays earnable for ever; nothing is locked to a lapsed event or a pass.
- A small post-game ships with launch: breeding checklists, harder giant rematches and a weekly challenge.

### Monetisation (01, 08)

Launch products in priority order, all convenience, capacity or looks, all bound to the account:

| # | Product | Price band (Robux) |
| --- | --- | --- |
| 1 | Starter pack: a cosmetic, storage and Gems, no consumables | 99-149 |
| 2 | Extra creature storage | 89-500 by size |
| 3 | Open storage anywhere | 200-250 |
| 4 | Extra breeding pen (hard cap 4 in total) | 399-599 |
| 5 | Faster hatching (at most 2x) | 250-450 |
| 6 | Gem packs | 49-1,999 |
| 7 | Cosmetic packs: trails, auras, lasso and town-home skins | 99-399 |
| 8 | Supporter pass and saved team slots | To set |
| 9 | Season pass, once ranked seasons exist | 350-749 |

- Not sold: coins, Breeding Candy, lassos, bait, consumables, stat or XP boosts, rarity, serials, cosmic wraps, anything random.
- Read every price at runtime and turn on Roblox's Managed Pricing. Write the shop to the all-ages standard from the start: no urgency wording, no restarting timers.
- Avoid wheel spins and slot-machine-style reveal animations: Roblox's gambling rule covers simulated gambling.
- Budget on $0.0038 per Robux and 3-4% of players paying.

### Map and world (03, 08)

- One place with instance streaming (settings confirmed in 08), not several places joined by loading screens.
- About 3,600 by 1,400 studs: three biomes in a row, each a hub town, two routes and a giant's lair on a side path.
- Wild creatures are visible and roam, with a few hidden "rustle" spots for rare ones.
- Wild battles happen on the spot with a camera cut; giants fight in their lair; PvP in one Circuit arena in Greenwood's hub at launch.
- Our own phone budget, since Roblox publishes none: under 500 draw calls and 300,000 triangles, art that reads with shadows off.
- Later biomes are teased by skyline silhouettes, a sealed boardwalk to the Mire, travelling characters and a clouded world map.
- Greybox Greenwood and playtest it before any art.

### Breeding (04, 09, `../../BREEDING_PLAN.md`, `../../prototype/`)

Settled in the breeding plan and running as tested code: a 0-10 quality gene per part, fit from fixed species weights, a shared stat budget, Breeding Candy in place of breed limits, lower gem inheritance odds, a carried colour gene, and the kin rule.

### Creature tech (05)

- Rigid mesh parts on `Motor6D` joints, cloned from prepared templates; ball-shaped joint ends hide seams.
- Animation written in code, one set per body plan.
- Colour set per part at runtime; gem tiers as materials and effects.
- Icons from live models, static and only for cells on screen.
- Art: Studio's segmented mesh generation first; the nine prototype tests in report 05 gate milestone 2.

### Trading and economy (06, 08)

- Trades only between two players in the same server; two confirmations; a short lock on newly caught or bred creatures; a hold for new accounts.
- A two-step commit so a trade cannot half-complete: both sides' creatures are set aside, one ledger record is the point of no return, and unfinished trades are repaired on load.
- Coins, Breeding Candy and anything bought with Gems cannot be traded. A small coin fee on each trade is a new coin sink.
- Giants and tournament wraps start bound to the account: second accounts could farm giants, and tradable prizes invite arranged matches.
- Target coins removed at 80-95% of coins created, measured from the first playtest.

### Battles and PvP (07)

- The ten-type chart in report 07 section 3: each type beats two and loses to two; strong x1.5, weak x0.67; a move of the creature's own type x1.2. Leaf beats Water, Water beats Sand, Sand beats Leaf.
- No misses and no critical hits; exact damage shown before choosing; tiny variance against the game, none in ranked.
- Pacing: wild 20-40 seconds, tamer 90-150 seconds, giant 3-5 minutes, PvP 3v3 3-5 minutes. Speed 1x and 2x from day one, and a quick-win option against much weaker wild creatures.
- Lasso: the server sets the pattern and judges timing with an allowance for lag; a bigger target at lower health; better lassos cost coins.
- Giants: scripted phases, at most five items per fight, and an enrage after 30 turns.
- Launch PvP: 3v3 only, scaled to level 50, 30-second turns, saved-team opponents for casual play, live ranked in scheduled windows, four-week seasons with cosmetic prizes.

---

## 3. Open risks to carry forward

1. The audience for this genre on Roblox is small (section 1).
2. AI-generated parts may not split or fit cleanly; tested first in milestone 2.
3. Speed is too strong if turn order is all it does (09); settle with the battle formula.
4. The candy earn rates and the wild gem spawn rate are guesses until a playtest.
5. The two-player trade commit is the hardest piece of saving code; it needs its own plan and an independent review.
6. Milestones 1 to 7 in four weeks is tight (earlier review); Greenwood alone is the fallback.
7. Competitor numbers and prices are unverified.
