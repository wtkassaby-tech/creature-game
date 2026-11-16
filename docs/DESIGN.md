# Creature Breed-and-Battle Game - Design and Build Brief

> **Superseded on 16 November 2026** by Ayrton's "Creature Game - Design Brief" (https://claude.ai/artifact/SXN85dnsvkAN8jYM9jQpcY): turn-based battles, lasso taming, giants, eleven biomes and part-based breeding. Kept for reference only; build from the brief. See `DECISIONS.md`.

Working title TBD. Owner: Ayrton. **Version 2, 15 November 2026.**

Version 1 (13 November 2026) was restructured on the Pokémon series' structure and core loop, as Ayrton asked on 15 November: "use the structure and core loop of project pokemon as a scaffold for this idea". The research behind it is `research/SCAFFOLD_STRUCTURE.md`. Every name, creature and asset in the game is our own. System names (Warden, Crest, Swarm, Titan, Tower) are working names.

The single source of truth for what we are building. Status words:

| Status | Meaning |
| --- | --- |
| **Locked** | Agreed in planning. Change only with Ayrton's approval. |
| **Proposal** | A starting value to test and tune. |
| **Proposal (scaffold)** | New in version 2, taken from the scaffold. Needs Ayrton's yes before it is built. |
| **Parked** | A good idea held until the core loop is proven. |
| **Open** | Not decided. |

### What changed from version 1

| Area | Version 1 | Version 2 |
| --- | --- | --- |
| First minute | Implied first hatch | Pick one of three starter eggs; it hatches inside 2 minutes |
| Getting creatures | Breeding and eggs only | Adds **befriending** wild creatures in each zone, capped at 3-star potential so breeding still wins |
| Zones | 10-15 stages plus a boss | Each zone has a hub, a wild area, stages, a rival fight and a **Warden** whose **Crest** raises the level cap |
| Creatures over time | Level and XP only | **Growing up:** Baby, Juvenile, Adult. The look changes; the genome does not |
| Endgame and live | Async PvP, daily challenge, ranked later | Adds the **Tower** (level-scaled climb), weekly **Titan** bosses, **Swarms** (themed spawn swaps) and monthly season rules, all run as config |
| Section numbers | 0-13 | 0-17 (art is now 14, technical 15, build plan 16) |

---

## 0. Decisions log

| Area | Decision | Status |
| --- | --- | --- |
| Concept | Breed creatures with inherited genes, build teams of 5, auto-battle in PvE and async PvP | Locked |
| Hook | "Babies look like their parents": visible modular genetics | Locked |
| Structure | Scaffolded on the Pokémon series' structure and core loop: starter, zones with wild creatures, a milestone boss per zone, growing up, a dex, a tower, weekly bosses, ranked seasons. All names, creatures and art our own | Locked (Ayrton, 15 Nov 2026) |
| Target player | Ages 12-15, tone at about 14; nothing core needs being 13+ or chat | Locked |
| Battles | Automatic; player decides team, rows and ability combinations | Locked |
| PvP | Against other players' saved teams, not live opponents | Locked |
| Ranked fairness | Ranked PvP scales creatures to a common level | Locked |
| Breeding beats buying | Paid eggs capped at 3-star potential; best creatures only from breeding | Locked |
| Item origin | Every creature tagged Tradeable or AccountBound; baby inherits AccountBound from either parent | Locked |
| Trading | Not at launch; added later with safeguards | Locked |
| Racing | Cut (animation risk, splits focus) | Locked |
| Art approach | Creatures assembled from AI-generated modular parts; animation in code | Locked |
| Art style | Stylised, rounded, blob-like creatures, bold colour, heavy effects | Proposal |
| Starter | Pick one of three starter eggs (Fire, Water, Leaf) in the first 30 seconds | Proposal (scaffold) |
| Befriending | Win a wild battle, then befriend one of the wild creatures for a coin-bought Treat at a shown chance; wild potential capped at 3 stars | Proposal (scaffold) |
| Growing up | Three stages by level (Baby, Juvenile, Adult); size and part scale change, abilities unlock; genome unchanged | Proposal (scaffold) |
| Wardens and Crests | One Warden (element specialist) ends each zone; its Crest raises the level cap and unlocks a feature | Proposal (scaffold) |
| Rival | A recurring rival with the counter-element starter, three fights per zone; later fed by real players' saved teams | Proposal (scaffold) |
| Post-game and live | Tower, weekly Titans, Swarms, Gifts and monthly season rules, run through live config | Proposal (scaffold) |
| System names | Warden, Crest, Treat, Swarm, Titan, Tower are working names | Open |
| Working title | Not chosen | Open |

---

## 1. Pitch and market

**Hook:** Breed your own monsters. Every baby looks like its parents. Breed the perfect team and battle the world.

**Shape (version 2):** the journey players already know from the biggest creature series (pick a starter, explore zones full of wild creatures, beat each zone's boss, fill the dex, then climb a tower and a ranked ladder), rebuilt for 10-20 minute phone sessions, with auto-battles and genetics you can see.

Market check (November 2026): no Roblox game found combines genetic breeding with team auto-battles. Both halves are proven:

| Game | What it shows |
| --- | --- |
| Dragon Adventures | Deep breeding alone sustains a big game (about 10,500 typical players, peak ~61,000 in March 2026, 1.7B visits). Weakness: slow opening |
| Catch And Tame | Breeding + stacking mutations is massive (peak ~221,000 in March 2026). No combat, thin social play |
| Loomian Legacy | Closest competitor: breeding + deep turn-based battles + ranked PvP, on the same series-style structure. But story-heavy, manual, steep learning curve |
| Battle Pet, Super Auto Pets (off Roblox) | Pet auto-battles with team ordering work |

Our position: fast, mobile-friendly, breeding-first, auto-battling, with genetics you can see. Because Loomian Legacy already uses the series structure, our differences must be obvious in the first minute: a baby that visibly mixes two parents by minute 10, and no menus in battle.

---

## 2. Target player (Locked)

| Rule | Why |
| --- | --- |
| Mobile-first UI and one-tap actions | Most players are on phones |
| No feature depends on chat or voice | Restricted for younger players |
| Readable genetics: stars, icons, colours, family tree | 12-15s must understand why a baby turned out as it did |
| First hatch within 2 minutes, first breed within 10 | Fixes the slow-start weakness of competitors |
| Sessions work in 10-20 minutes | Typical play pattern |

Proposal (scaffold): creature names are picked from generated names (tap to reroll), not typed. Typed names are player text, which Roblox requires us to filter, and they add moderation risk for little gain.

---

## 3. The scaffold: series structure mapped to ours

| Series part | Our version | Status |
| --- | --- | --- |
| Starter choice (three, type triangle) | Starter egg: Fire, Water or Leaf. It hatches with random parts from the starter body families (section 6) | Proposal (scaffold) |
| Routes with wild encounter tables | Each zone's wild area: visible wild creatures roam; tap one to fight (section 5) | Proposal (scaffold) |
| Catching | Befriending: one roll after a win, chance shown (section 6) | Proposal (scaffold) |
| Route trainers | Stages: fixed teams, stars for objectives | Kept from v1 |
| Gyms and badges (eight) | Wardens and Crests: one per zone, element specialists; 3 at launch, 8 at maturity | Proposal (scaffold) |
| Obedience by badge | Level cap by Crest; XP over the cap is banked | Proposal (scaffold) |
| Rival | Rival with the counter-element starter, three fights per zone | Proposal (scaffold) |
| Evolution | Growing up: Baby, Juvenile, Adult (section 7) | Proposal (scaffold) |
| Four learned moves | Two inherited ability slots (v1); slot 2 opens at Juvenile | Proposal (scaffold) |
| Type chart (18 types) | Element wheel (6 elements) | Kept from v1 |
| Hidden IVs, EVs and natures | Visible stat stars and a passive trait | Kept from v1 |
| Breeding (endgame, baby copies the mother's species) | Breeding from minute 10; babies mix both parents | Kept from v1 (our hook) |
| Shiny variants (1 in 4,096) | Mutations (0.5% base) | Kept from v1 |
| Dex, seen vs caught | Creaturedex with seen vs owned; unseen entries as silhouettes | Proposal (scaffold) |
| Free healing in towns | Every battle starts at full HP | Proposal (scaffold) |
| Elite Four and Champion | The Summit: a gauntlet after the eighth Warden | Parked |
| Battle facility | The Tower: endless, level-scaled floors (section 8) | Proposal (scaffold) |
| Raids | Titans: a weekly scripted boss (section 8) | Proposal (scaffold) |
| Mass outbreaks | Swarms: a zone's wild table swaps to a theme with better mutation odds (section 11) | Proposal (scaffold) |
| Gift distributions | Gifts in an in-game mailbox | Proposal (scaffold) |
| Ranked seasons with rule sets | Monthly ladder seasons, each with one season rule (section 8) | Proposal (scaffold) |
| Version exclusives, trade evolutions, field moves | Not used | Not adopted |

---

## 4. Core loop

| Loop | Length | What happens |
| --- | --- | --- |
| Battle | 15-60 s | Wild fight (15-30 s) or stage/Warden fight (30-60 s); watch at 1x or 2x; rewards |
| Breeding | Minutes to hours | Pair two creatures, egg goes in an incubator, hatch, inspect genes |
| Session | 10-20 min | Fight in the current zone, befriend, breed, hatch, adjust team; one clear next goal on screen |
| Zone | 3-5 sessions | New wild creatures and body families, stages, rival, then the Warden for a Crest |
| Long term | Weeks | Breed toward a perfect line; complete the Creaturedex; climb the Tower and ranked seasons |
| Live | Weekly | A new Titan; a Swarm every 2-3 weeks; a monthly season rule |

Reward screen after every battle lists each line (base reward, stars earned, streak bonus, first-clear bonus) as in the golf brief's breakdown screen.

### First session (Proposal (scaffold))

| By | What happens | Why |
| --- | --- | --- |
| 0:30 | Three starter eggs on pedestals; one tap picks one | Ownership in the first minute |
| 1:30 | Starter hatches; pick a generated name | Locked target: first hatch under 2 minutes |
| 3:00 | First wild fight in Zone 1 (auto, about 20 s); win | Teaches battle by watching |
| 4:00 | First befriend: guaranteed, with the chance shown as 100% | Second creature, and the pair needed to breed |
| 6:00 | Starter reaches Juvenile (level 5) and visibly grows | First "it grew up" moment |
| 10:00 | First breed: starter x befriended creature | Locked target: first breed under 10 minutes |
| 12:00 | First bred hatch: both parents shown beside the baby, inherited genes highlighted | The hook lands |
| 20:00 | First stages cleared; rival's first fight; next goal "Warden 1" on screen | A reason to come back |
| 45-60 min | Warden 1 beaten; Crest 1; level cap rises; async PvP opens | v1 pacing: first zone cleared in about 1 hour |

---

## 5. World and journey (Proposal (scaffold))

Each zone has the same four parts:

| Part | What it holds |
| --- | --- |
| Hub | Incubators, stable, breeding pen, shop, Creaturedex station, the zone's board of stages |
| Wild area | Wild creatures roam visibly (no random interruptions). Tap one to fight it and the 0-4 creatures with it. Respawns on a server timer |
| Stages | 10-15 fixed fights, stars per stage for objectives (v1) |
| Warden | The zone's last fight: an element specialist with a scripted boss team (section 8) |

- **Rival:** fights you three times per zone (after the first stages, mid-zone, just before the Warden) with the starter that counters yours. From zone 2, the rival's team is built from a real player's saved defence team near your strength, so the rival introduces async PvP.
- **Level cap:** creatures cannot pass the cap for your Crest count (proposal: 15, 25, 35, 45; config). XP earned over the cap is banked and applied when the cap rises, so no play is wasted.
- **Crest unlocks** (proposal): Crest 1 opens async PvP and Titans; Crest 2 opens the Tower and a third incubator slot; Crest 3 opens the season ladder.
- **Element order:** Warden elements are chosen so that, across the first three Wardens, each starter has one easy, one even and one hard fight. No starter is ever stuck.

Launch zones (themes are proposals; element assignment waits on the final wheel):

| Zone | Theme | New in the wild | Warden |
| --- | --- | --- | --- |
| 1 | Meadow and pond | 3 body families, 3 elements | Warden 1 |
| 2 | Volcanic ridge | 2-3 new body families, 1-2 new elements | Warden 2 |
| 3 | Storm cliffs and shadow caves | 2-3 new body families, the last elements | Warden 3 |

New zones are the main content update (v1: "new zone per update").

---

## 6. Getting creatures

| Source | Stat potential | Origin | Notes |
| --- | --- | --- | --- |
| Starter egg | Rolled within 2-3 stars | AccountBound (Proposal (scaffold)) | Element chosen by the player; parts random from the starter families |
| Wild, befriended | 1-3 stars | Tradeable | From the zone's table; Proposal (scaffold) |
| Bred | 1-5 stars | AccountBound if either parent is (Locked), else Tradeable | The only route to 4 and 5 stars |
| Earned egg (quests, stage stars) | 1-3 stars | Tradeable | Free random reward |
| Paid egg (gems or Robux) | Capped at 3 stars (Locked) | AccountBound (Locked) | Odds behind "Details" (`CLAUDE.md` rule 9) |
| Titan reward creature | Fixed genome, one per Titan | AccountBound (Proposal (scaffold)) | "Befriend once" trophy |
| Gift | Fixed | AccountBound (Proposal (scaffold)) | Event mailbox |

### Befriending (Proposal (scaffold))

- After you win a wild fight, one defeated wild creature (the player picks which) can be befriended by spending one **Treat**.
- The chance is shown before you spend. It depends on the creature's rarity in the zone table, and stars earned in the fight add a small bonus. If the roll fails, the Treat is kept, so a failed roll costs only time.
- **Treats are bought with coins only and are never sold for Robux or gems.** If they could be bought with paid currency, every befriend would become a paid random item under `CLAUDE.md` rule 9.
- The first befriend is guaranteed. Wild creatures are always Juvenile or older, so they can breed straight away.
- A wild creature's looks, element and level are visible before you fight it; its stat stars stay hidden until it is befriended, then show on a card like a hatch.
- Stable capacity limits holdings (v1). Releasing a creature gives coins (v1).
- Each wild creature's genome is rolled server-side from the zone's table: body family, element, parts from the family pool, colours from the zone palette, potential 1-3 stars, and the base mutation chance. Wild creatures are the main source of new genes, so new zones bring new body families and parts into your breeding pool.

---

## 7. Genetics system (Proposal values, Locked structure)

### Genome

| Gene | Values | Inheritance |
| --- | --- | --- |
| Element (primary, optional secondary) | 6 at launch: Fire, Water, Leaf, Storm, Stone, Shadow | Primary from a random parent. If parents differ, 2% chance of dual element |
| Body family | 8-10 at launch | From a random parent |
| Part slots (head, ears/horns, tail, back, pattern) | Pool per family | Each slot from parent A or B (50/50); 3% chance per slot of a random part from the family pool |
| Colour (primary, secondary, accent) | HSV values | Blend of parents with small random jitter; 2% chance of a new palette |
| Size | 0.8-1.2 | Average of parents plus or minus 0.05 |
| Ability slots (2) | Pool per element | Each slot from a random parent's random slot; 5% chance per slot of a new ability from the creature's element pool; no duplicates |
| Passive trait (1) | Tough, Swift, Lucky, Fierce, Guardian, Sly, etc. | 50/50 from a parent; 3% chance of a new trait |
| Stat potential: HP, Attack, Defence, Speed | 1-5 stars each | Child = average of parents' stars (rounded) plus a roll: -1 (20%), 0 (60%), +1 (18%), +2 (2%); clamped 1-5 |
| Mutation | None, Shiny, Shadow, Crystal (more seasonal) | 0.5% base per egg; 2% if either parent is mutated. Mostly cosmetic plus a small stat bonus |
| Generation | Integer | max(parent generations) + 1 |

Proposal (scaffold), **far-bred bonus:** parents first met in different zones add a small, shown bonus to the mutation chance (for example 0.5% to 0.75%). It rewards exploring, the way the series rewards parents from different-language games.

### Growing up (Proposal (scaffold))

| Stage | Levels (config) | Look | Unlocks |
| --- | --- | --- | --- |
| Baby | 1-4 | 60% size; parts at 70% scale; bigger eyes, bouncier idle | Ability slot 1 |
| Juvenile | 5-14 | 80% size; parts full scale | Ability slot 2; can breed |
| Adult | 15+ | 100% (times the Size gene); full pattern intensity | Passive trait active |

- Stage comes from level alone. The genome never changes, so a baby, its adult self and its parents always share visible parts and colours.
- Growing up is a moment: the creature pauses, glows and grows on screen, and the hatch-style card shows "now unlocked".
- Art cost is low: stages are scale and pattern changes done in code (section 14), not new models.
- Ranked play, the Tower and Titans scale every creature to the common level, which is Adult.

### Rules

- Each creature can breed once every N hours (config); each pair produces one egg.
- Egg timers scale with rarity; the first 3 eggs for a new player hatch in under 2 minutes.
- Incubator slots limit parallel eggs (2 free at start; more earned or bought).
- Hatch screen shows both parents beside the baby with each inherited gene highlighted.
- Family tree view for every creature (parents and grandparents).
- Stat potential hidden until hatch, then shown as stars.

### Required tests

- Inheritance distributions over 1,000,000 seeded breeds match config within tolerance.
- Children never exceed bounds (stars 1-5, size range, max 2 elements, no duplicate abilities).
- Paid eggs never exceed the potential cap.
- Origin propagation: any AccountBound parent produces an AccountBound child.
- Added in version 2: wild and starter creatures never exceed their caps; the first befriend is guaranteed exactly once per player; stage is a pure function of level and never changes the genome; the far-bred bonus applies only when both "met in" zones differ.

---

## 8. Battle system (Proposal values, Locked structure)

- **Team:** 5 creatures. Front row 2, back row 3. Front row is targeted first by melee abilities. Early on you field what you have (1-5); the prototype team is 3.
- **Flow:** fixed-step simulation, max 60 seconds. Creatures act by Speed; each uses its abilities on cooldown with simple targeting rules. If time runs out, the team with the higher remaining HP % wins.
- **Damage:** Attack vs Defence formula in config; element wheel gives +25% / -25%.
- **Synergies:** team bonuses at 2 and 4 creatures sharing an element or trait (e.g. 2 Fire: +10% attack; 4 Fire: burn on hit).
- **Content at launch:** 30-40 abilities, 8-10 synergies.
- **Presentation:** server sends a battle log; client replays it with procedural animation, ability effects, damage numbers. Speed 1x or 2x; skip once a stage is cleared.
- **HP:** every battle starts at full HP. Losing costs only time.

### Boss scripts (Proposal (scaffold))

Wardens and Titans run scripts written as data in `src/config/`: a list of triggers (HP % below X, time % below Y) and actions (raise a shield, buff, summon, change targeting, clear the players' buffs). The series' raid bosses work this way (`research/SCAFFOLD_STRUCTURE.md` section 3). Scripts run inside the same seeded, fixed-step simulator, so a boss fight is as deterministic as any other.

### Modes

| Mode | Details | Status |
| --- | --- | --- |
| Wild fights | 1-5 wild creatures; 15-30 s; befriend roll after a win | Proposal (scaffold) |
| PvE campaign | 3 zones at launch, 10-15 stages each plus a Warden; stars per stage for objectives | v1, Warden added |
| Rival | Three fights per zone; from zone 2 built from real saved teams near your strength | Proposal (scaffold) |
| Async PvP | Player sets a defence team (snapshot saved server-side). Opponents picked by rating bracket. Server simulates. Elo-style rating | Locked structure (v1) |
| Tower | Endless floors at the common level; one life per run; best floor on a leaderboard; floor rewards first time only | Proposal (scaffold) |
| Titans | One scripted boss a week at the common level. One scored run a day (practice runs unlimited); reward tier by damage dealt; a "befriend once" trophy creature at the top tier; a server-wide damage meter adds a shared bonus | Proposal (scaffold) |
| Ranked seasons | Level-scaled creatures, monthly seasons, seasonal rewards. Each season has one **season rule** (for example "no more than 2 of one element", or one ability flagged by `lune run balance` is banned) | v1 "later", rule added (scaffold) |
| Summit | Five battles in a row after the eighth Warden | Parked |

### Balance tooling

`lune run balance` simulates large numbers of battles between generated teams and reports win rates per ability, synergy and archetype. Any ability or team above the threshold in config (default 55% win rate in mirrored samples) is flagged. Run after every battle or ability change. It also runs every Warden and Titan script against generated teams at the expected level and reports clear rates, so no boss is impossible for any starter.

---

## 9. Content scope

| | Prototype | Version 1 | Mature |
| --- | --- | --- | --- |
| Elements | 4 | 6 + element wheel | 10+ |
| Body families | 6 | 8-10 | 15+ |
| Visual parts | ~20 | 60-80 | 150+ |
| Growth stages | 3 (scale only) | 3 (scale and pattern) | 3, plus per-family adult extras |
| Abilities | 12 | 30-40 | 80-100 |
| Synergies | 3 | 8-10 | 20+ |
| Mutations | 1 | 3-4 | Seasonal |
| Team | 3 | 5 with rows | 5 + formations |
| Zones and Wardens | 1 zone, 10 stages, Warden 1 | 3 zones, 30-45 stages, 3 Wardens | 8 Wardens, then the Summit; new zone per update |
| Wild tables | 1 | 3 (one per zone) + Swarm themes | One per zone + seasonal |
| PvP | None | Async saved-team ladder | Ranked seasons with rules, tournaments |
| Tower and Titans | None | Tower; Titans in the public test | Weekly Titans, Tower seasons |
| Trading | None | None | With safeguards |

---

## 10. Progression and economy

| Currency / item | Earned from | Spent on |
| --- | --- | --- |
| Coins | Battles (wild, stages, Wardens, rival), quests, releasing creatures | Training, breeding fees, incubator upgrades, zone unlocks, Treats |
| Gems (premium) | Robux; small amounts from quests and level-ups | Premium eggs, incubator speed-ups, slots, cosmetics |
| Treats | Bought with coins only; never sold for Robux or gems | Befriending wild creatures |
| Training food | Battles | Creature XP |
| Breeding charms | PvE stars, events | Small, shown boosts to mutation or trait odds |

- Player level unlocks zones, incubator slots and features; Crests gate the level cap and the modes in section 5.
- The whole team shares battle XP. XP over the level cap is banked.
- Creaturedex: one entry per body family x element, with "seen" (met in any battle) and "owned"; unseen entries show as silhouettes with the zone they live in. Completing sets gives titles and permanent small bonuses (proposal: completing a zone's set gives a small, shown mutation-odds bonus).
- Stable capacity is limited (expandable), which keeps save data small.

Pacing targets (tune in prototype): first hatch under 2 minutes; first befriend by minute 4; first breed under 10 minutes; Warden 1 (first zone cleared) in about 1 hour; first 4-star creature in the first week; Warden 3 in about the second week.

---

## 11. Live operations (Proposal (scaffold))

The series ships a new raid about every 7 days (median, 2022-2026), and a themed spawn swap about every 21 days, almost all of it as data rather than game updates (`research/SCAFFOLD_STRUCTURE.md` section 3). We copy the rhythm, not the content.

| Beat | Cadence | What it is | Built from |
| --- | --- | --- | --- |
| Titan | Weekly | A new scripted boss, reward tables and a trophy creature; about a quarter are reruns | Config: boss team, script, reward tables |
| Swarm | Every 2-3 weeks, often a weekend | One zone's wild table swaps to a theme (one element, one family or one part set) with a shown mutation boost (for example x4) | Config: wild table override, multiplier, start and end |
| Gifts | At events | A fixed creature or items in the mailbox | Config: gift list |
| Daily challenge | Daily | Everyone fights the same boss team (v1) | Config |
| Season rule | Monthly | One rule for the ranked season | Config |
| New zone | Per content update | Wild table, stages, Warden, body families | Code and art |

- Everything above "New zone" changes through Roblox ConfigService, read server-side and sent to clients through Blink. See `docs/research/LIVE_CONFIG_PLAN.md` in the golf repo for the API and its limits (server-only, up to 5 minutes to propagate).
- All timers are real and never restart. The wording stays calm, with no "BUY BEFORE IT'S GONE" (`docs/research/ROBLOX_POLICY.md` item 5 in the golf repo).
- Use Roblox Experience Events for Titan and Swarm start times so players can tap "Notify Me".

---

## 12. Monetisation

| Product | Type | Release |
| --- | --- | --- |
| Starter Pack (coins, 2 eggs, exclusive cosmetic) | One-time, new players | Launch |
| Premium eggs (odds shown, potential capped) | Gems | Launch |
| Incubator speed-ups | Repeatable | Launch |
| Extra incubator and stable slots | One-time | Launch |
| Cosmetics: hats, auras, battle effects, nameplates | Gems / shop | Launch |
| Season pass (free + premium tracks) | Seasonal | Update 1 |
| VIP subscription | Monthly | Later |
| Trading | Feature | Later |

Compliance and fairness are in `CLAUDE.md` rules 9 and 10. Never sell: battle wins, stat potential above the paid cap, or anything usable in ranked beyond cosmetics.

Added in version 2:

- **Never sold:** Treats (section 6), Tower retries or floor skips, extra scored Titan runs, Warden skips. Each feeds a befriend roll, a shared leaderboard or a milestone.
- Rewarded ads, if used, must give a fixed developer product, never a random item (Roblox rule; `docs/research/ROBLOX_POLICY.md` item 3 in the golf repo).
- Honour `IsPaidItemTradingAllowed` when trading arrives, as well as `ArePaidRandomItemsRestricted`.
- The Starter Pack timer is real and never restarts.

---

## 13. Social

- Visit other players' stables and family trees.
- Server announcements and share prompt for mutated or perfect (all 5-star) hatches.
- Leaderboards: ladder rating, highest generation, Creaturedex completion, best Tower floor.
- Daily challenge: everyone fights the same boss team.
- Added in version 2: the rival is built from real players' saved teams from zone 2; the Titan server damage meter gives everyone on the server a shared bonus with no chat needed; seeing another player's creature in a battle marks it "seen" in your Creaturedex.

---

## 14. Art and audio

- **Modular creatures:** each body family has a base mesh plus part slots. Parts generated with Studio MCP `generate_mesh` / `generate_procedural_model` (Meshy for hero parts if needed), sized to shared attachment points. `CreatureRig` assembles a creature from its genome and applies colours and pattern.
- **Growing up:** `CreatureRig` applies stage scale (body and part scale, eye size, pattern intensity) from level. No extra models.
- **Style:** rounded, chunky, stylised; bold palettes per element; heavy particle and glow effects; rarity and mutation shown through effects.
- **Animation:** one procedural system for all creatures: idle bounce, squash and stretch, hop, lunge, hit flash, faint, plus a grow-up pulse. No custom rigs.
- **Wardens and Titans:** Wardens are shown by their creatures, an arena and a banner, not by a human character model. Titans are a scaled-up creature with a mutation glow and a shield effect.
- **UI:** clean, icon-heavy, readable star ratings, family tree view, Crest case, Creaturedex silhouettes.
- **Audio:** distinct hatch, ability and mutation sounds; mutation reveals escalate; a short sting for growing up and for each Crest.
- No human-made marketplace models, art or VFX packs (version 1 rule; see Open questions).

---

## 15. Technical architecture

Stack (same as previous project): Luau `--!strict`, Rojo, Git, Rokit, Wally, luau-lsp, Selene, StyLua, Lune, ProfileStore, Blink, React-lua or Fusion (record choice in `docs/DECISIONS.md`), Asphalt, Roblox Studio built-in MCP, ConfigService for live config.

Server services: `DataService`, `InventoryService` (creature records, origin), `BreedingService`, `IncubatorService`, `BattleService` (runs the shared simulator), `CampaignService` (stages, rival, Wardens, Crests, level caps), `EncounterService` (wild spawns, befriend rolls), `LadderService` (defence snapshots, matchmaking by rating, results, season rules), `TowerService`, `TitanService`, `LiveConfigService` (ConfigService snapshots, Swarms, Gifts), `ShopService`, `PurchaseService`, `QuestService`, `LeaderboardService`.

Shared (pure, Lune-tested): `Genetics/`, `Battle/` (adds boss scripts), `Economy/`, plus `Encounters/` (wild table rolls, befriend chance) and `Growth/` (stage from level, stage scale).

Client: `CreatureRig`, `AnimationController`, `BattleReplayController`, `EffectsController`, `AudioController`, UI (starter pick, stable, breeding pair picker, incubators, hatch reveal, grow-up card, team builder, battle HUD, befriend prompt with chance, Crest case, egg shop with odds Details, Creaturedex, family tree, Tower, Titan).

Proposal (scaffold), data change for approval: add `Source` (`"Starter" | "Wild" | "Bred" | "Egg" | "Gift" | "Titan"`) and `MetZoneId` to the creature record, for the family tree ("befriended in the Meadow"), the far-bred bonus and analytics. It is a save-data change, so it needs Ayrton's approval, a migration and a test (`CLAUDE.md` rule 4).

Quality gate: `lune run check` runs StyLua check, Selene, luau-lsp strict, unit tests and `rojo build`, locally and in GitHub Actions.

---

## 16. Build plan and stage gates

| Phase | When (estimate) | Deliverables | Gate |
| --- | --- | --- | --- |
| 0. Setup | Days 1-2 | Repo, toolchain, CI, Studio MCP, empty services | `lune run check` passes in CI |
| 1. Art test | Week 1 | 6 body families with parts; `CreatureRig` with three growth stages; 20 randomly bred creatures; procedural animation; 3 thumbnails | **Gate 1:** creatures look good and distinct; 4 of 5 testers can match babies to parents from a lineup; 4 of 5 can match a Baby to its Adult self |
| 2. Prototype | Weeks 2-4 | Starter eggs; Zone 1 with a wild table and befriending; genetics (prototype scope); incubators; battle simulator + replay with boss scripts; 12 abilities, 3 synergies; 10 stages, the rival and Warden 1; saving; no purchases | **Gate 2:** 4 of 5 testers play 20+ minutes unasked and breed at least 3 times; first breed under 10 minutes for 4 of 5 |
| 3. Private test | Weeks 5-8 | Version 1 content: zones 2-3, Wardens 2-3, Crest caps, async PvP, Tower, Creaturedex with seen/owned, economy | **Gate 3:** 3 of 5 testers return next day unprompted; no ability above balance threshold; every Warden clearable by every starter in `lune run balance` |
| 4. Public test | Weeks 9-10 | Public release, Titans and Swarms through live config, small ad spend, analytics | **Gate 4:** session length and next-day return targets (set before the test) |
| 5. Launch | Week 11+ | Purchases on, Starter Pack, season pass prep, ranked seasons with rules | Ongoing updates |

Note from the golf project's research (`docs/DESIGN.md` section 14 there, read 12 November 2026): Roblox shows a new game only to age-checked 16+ players until it earns 250 unique plays from highly engaged 16+ players within 60 days, or pays a refundable 50,000 Robux expedited review. The public test's first players will be 16+, so plan Gate 4 numbers for that audience.

---

## 17. Risks and open questions

| Risk | Mitigation |
| --- | --- |
| Genre is crowded | Make "babies look like parents" obvious in thumbnail and first minute |
| Closest competitor already uses the series structure | Our differences (visible genetics, auto-battles, short sessions) in the first 12 minutes; no long story text |
| Genetics too complex for 12-15s | Stars, icons, hatch comparison screen, tutorial on first breed |
| Befriending makes breeding feel optional | Wild potential capped at 3 stars; 4-5 stars only from breeding; wild creatures are mainly a source of new genes |
| Scope creep: the series is a tens-of-hours RPG | Take the structure, not the size: 3 zones at launch; minimal text; new zones as updates |
| Level cap frustrates | XP is banked, not lost; the cap and the next Warden are always on screen |
| Ability balance breaks | Deterministic simulator + `lune run balance`; season rules can ban an outlier |
| Boss scripts make a Warden impossible for one starter | Element order rule (section 5); balance tool clears every Warden with every starter |
| Modular parts look mismatched | Shared attachment points, consistent style prompts, Gate 1 |
| Growth stages look odd at small scale | Gate 1 Baby-to-Adult match test |
| Pay-to-win perception | Paid potential cap, level-scaled ranked, Tower and Titans; Treats never sold |
| Duplication exploits | Server authority, ProfileStore locks, idempotent purchases, no trading at launch; befriend and Titan rewards granted server-side once |
| Under-16 gate at launch | Plan the public test around 16+ players (section 16) |

Open questions:

- [ ] Working title and hook line
- [ ] Final element list and wheel (needed for Warden elements and the starter triangle)
- [ ] UI library choice
- [ ] Exact inheritance odds, timers and costs (tune in prototype)
- [ ] Manual check of Roblox for "breed", "genetics", "auto battle" games; play Loomian Legacy, Dragon Adventures, Catch And Tame, Battle Pet
- [ ] Approve or change each **Proposal (scaffold)** row in section 0
- [ ] Names for Warden, Crest, Treat, Swarm, Titan and Tower
- [ ] Starter, Titan and Gift creatures AccountBound (proposed), or Tradeable?
- [ ] Record fields `Source` and `MetZoneId` (save-data change; section 15)
- [ ] Titans solo with a server meter (proposed), or co-op teams later?
- [ ] Rules from the golf project dated 12-13 November 2026 that this project might adopt: the "push all defined limits" ambition statement; third-party Creator Store assets allowed with checks, instead of this project's "no human-made marketplace art" rule; the written pay-to-win definition (paying to progress faster is allowed)
- [ ] Does the creature game get its own repository, and when?
