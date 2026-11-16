# Creature Game: master plan

Date: 16 November 2026. Owner: Ayrton. Builder: Claude Code.

**What this document is.** The brief (`BRIEF.md`) says what the game is. The decisions log (`DECISIONS.md`) records every decision since and wins where it differs from the brief. This plan says everything that has to exist for the game to ship, how the pieces fit together, and the order to build them in. Detail lives in the documents it points to; this is the map.

**The plan in five lines**

1. The rules of breeding and battling already run as tested code (`prototype/`, 39 passing checks). Nothing has been built in Roblox Studio yet.
2. The biggest unknown is art: whether AI-generated creature parts split cleanly and fit together. Test it before the trip, not during it.
3. Work splits into two tracks: a **logic track** that needs no Studio and can run in cloud sessions, and a **Studio track** that needs Ayrton's laptop.
4. Four gates decide whether to go on: core proofs, the Greenwood slice, saving and economy, and launch readiness. Each has a pass mark and a fallback.
5. The brief's schedule (milestones 1 to 7 in about four weeks, with study days) is tight. Section 5.5 gives the order to cut scope in, and what is never cut.

---

## 1. Where the project stands

| Area | State | Where |
| --- | --- | --- |
| Vision, pillars, story arc, biome list | Decided by Ayrton | `BRIEF.md` |
| 34 decisions since the brief (coin bets removed, Breeding Candy, consumables, launch scope, and the Defaults set from research) | Logged | `DECISIONS.md` |
| Market and policy research, with a fact check against Roblox's own pages | Done; competitor numbers unverified | `research/market/00_MARKET_BRIEF.md` |
| Breeding rules and maths | Tested code, stress-tested | `BREEDING_PLAN.md`, `prototype/shared/Breeding.luau`, `Stats.luau` |
| Battle rules: type chart, damage, turn order, Speed band, Tempo | Tested code | `prototype/shared/Battle.luau`, `TypeChart.luau` |
| Server breed flow, client creature assembler | Written, not yet run in Studio | `prototype/server`, `prototype/client` |
| Project rules for the new repo | Drafted | `CLAUDE_DRAFT.md` |
| The game's own repository, toolchain and Studio place | Not started | Brief section 13, "before Ayrton flies" |
| Art, map, screens, saving, shops, quests, story content | Not started | This plan |

---

## 2. What "ready for soft launch" means

A player aged 16 or over can, on a phone:

- pick a starter, win a first battle inside a minute, lasso a second creature by minute 4 and receive the mentor's egg by about minute 10;
- play three biomes end to end (about 4 to 5 hours): routes with roaming wild creatures, local tamers, quests, a giant and a gate battle in each, earning three badges;
- breed any two creatures on the same body plan, see the preview before paying, and get a baby that visibly mixes both parents;
- leave and come back with everything saved, and with no way to duplicate or lose a creature;
- buy only convenience, capacity and looks.

Behind the scenes: the server decides every result, every purchase is granted exactly once, analytics show where players drop out, and trading, PvP and the shop can each be switched off without a new release.

Not needed for soft launch: PvP (milestone 8), trading (milestone 9), biomes 4 to 11, teams larger than 3, status effects, tournaments, the all-ages release, and everything tied to the finale in biome 11 (the rival's gift, cosmic wraps and cosmic creatures).

---

## 3. Everything the game needs

Twelve workstreams. **State:** Tested = runs under Lune in `prototype/`; Designed = rules decided in the docs; New = nothing yet. **Track:** L = logic track (no Studio needed); S = Studio track. **M** = the brief's milestone number.

### 3.1 Foundation

| Item | What it is | State | Track | M |
| --- | --- | --- | --- | --- |
| Repository and toolchain | New repo; Rojo, Rokit tools, Wally packages (ProfileStore, Trove, a UI library), Blink, Lune; `lune run check`; GitHub Actions | New (copy the golf repo's setup) | L | 0 |
| Agent set-up | `CLAUDE.md` from `CLAUDE_DRAFT.md`; the `builder`, `helper` and `exploit-reviewer` agent definitions from the golf repo | Drafted | L | 0 |
| Studio place and Studio MCP | A place file synced by Rojo; the Studio MCP working on the travel laptop | New | S | 0 |
| Networking | Every client-server message defined in Blink, validated and rate-limited (catalogue in 4.4) | New | L | 1-4 |
| Live config and switches | ConfigService values read by the server; off-switches for the shop, trading and PvP | Designed | L | 4, 7 |
| Analytics and logs | First-session funnel, economy sources and sinks, and a log line for every breed, capture, purchase and trade | Designed | L | 3-7 |

### 3.2 Creatures

| Item | What it is | State | Track | M |
| --- | --- | --- | --- | --- |
| Creature record and species data format | One data file per species: parts, base stats, weight, sockets, moves, type | Tested (3 placeholder species) | L | 2 |
| Stats | Parts x quality x fit, the shared stat budget, level and rarity | Tested | L | 2 |
| Part specification | Pivots, ball-joint ends, socket names and radii, triangle budgets; a Studio script that validates every part | Designed (`research/market/05` section 9) | S | 2 |
| Art pipeline | Generate each species as named parts, normalise, validate, contact sheet, register | Designed, **unproven** | S | 2 |
| Assembler | Builds a model from a record: clone templates, scale to sockets, join, colour, size | Written, not run | S | 2 |
| Animation | Code-driven idle, walk, lunge, cast, flinch and faint for each body plan | Designed | S | 2 |
| Colour, rarity effects, icons | Runtime colour; gem-tier materials and glow; static live-model icons | Designed | S | 2, 5 |
| Colour genes and rare colours | A shown colour, a carried colour and a pattern on every creature. Rare colours turn up on wild creatures at a low rate, including in early biomes, and can be bred onto stronger ones | Colour gene tested; wild rates new | L + S | 3, 5 |
| Moves | About 50 at launch, written with each roster: type, power, which part brings them and the level they unlock | 18 placeholders tested | L | 3, 5 |
| Levels and XP | XP curve; a level cap per badge; each part's first move known from the start and its others unlocking at set levels (a Default); choosing four from those unlocked | Designed in outline | L | 4 |
| Team and storage | Team size set per badge in config: 3 for the launch biomes, 4 from the Mire. A stable with a capacity. Release for materials | Designed in outline | L | 4 |
| Bound flag | Every creature record says whether it can ever be traded; giants and cosmic creatures cannot. Set from the first save, so opening trading needs no migration | New | L | 4 |
| Roster balance | The all-builds tournament run on each real roster before its art is made | Tested tool; placeholder roster fails it | L | 2, 5 |

### 3.3 Battles and catching

| Item | What it is | State | Track | M |
| --- | --- | --- | --- | --- |
| Battle core | Turn resolution, switching, type chart, damage, Speed band, Tempo, replay from a seed | Tested | L | 1 |
| Battle service | The server runs each battle, takes one action per turn from the client, and pays rewards | New | L | 1 |
| Opponents | Wild (basic attacks), local tamers (themed teams), the rival (a team that grows with the story) | Simple opponent tested; tiers new | L | 1, 3 |
| Items in battle and running away | Healing items, revives, the five-item cap in giant fights | Designed | L | 3, 4 |
| Status-effect hooks | None at launch; the engine must be ready for poison in the Mire | New | L | 4 |
| The "biome reached" rule | A creature can battle only if it comes from a biome the player has reached (a bred child counts as its later parent's biome). The battle service checks it, and trading will too | Designed | L | 4 |
| Leaving mid-battle | A battle against the game is not saved. On return the player is at the last hub with creatures as they were; items used and the giant-attempt item stay spent | New (a Default) | L | 3, 4 |
| Battle screen | Phone layout, camera cut, move effects, damage preview, 1x and 2x speed, quick-win | Designed (`research/market/07`) | S | 1 |
| Giants | Three phases, a shown intent each turn, weak points, enrage at turn 30, all written as data; a lair arena | Designed | L + S | 3, 5 |
| Lasso | The server sets the pattern and judges the tap with a lag allowance; lasso tiers; assist options | Designed | L + S | 3 |

### 3.4 World

| Item | What it is | State | Track | M |
| --- | --- | --- | --- | --- |
| Map | One streamed place, about 3,600 x 1,400 studs; each biome a hub, two routes and a lair on a side path | Designed (`research/market/03` section 7) | S | 3, 5 |
| Hub buildings | Shop, healer, breeder, quest-givers, teleport building; one Circuit arena in Greenwood (it hosts the weekly tamer challenge at launch; PvP opens there in milestone 8) | Designed | S | 3-5 |
| Shared hubs | Other players and their lead creature visible in hub towns; Greenwood's square as the main gathering place; players per server set after the phone test | New | S | 3, 6 |
| Wild creatures | Server-owned spawn tables per route; roaming models built on each player's device; rare "rustle" spots; bait from Tide Flats | Designed | L + S | 3, 5 |
| Characters and dialogue | Mentor, rival, tamers, quest-givers, shopkeepers, travellers; short, skippable lines | New | L + S | 3 |
| Quests | A data format, a tracker, rewards including a guaranteed creature | New | L | 3, 4 |
| Gift creatures | The starter, the mentor's egg, each quest line's guaranteed creature, and each biome's clear token ([Locked] for Greenwood) | New | L | 3, 5 |
| Story | Chapter flags, gates and badges, the rival's changing team, "Chapter n of 11" | Arc decided; chapters 1-3 unwritten | L | 3, 5 |
| Materials and crafting | Gathering spots, bait recipes, crafted consumables | New | L + S | 5 |
| Teasers for later biomes | Skyline silhouettes, the sealed Mire boardwalk, travellers, a clouded world map | Designed | S | 5, 6 |

### 3.5 Economy and breeding

| Item | What it is | State | Track | M |
| --- | --- | --- | --- | --- |
| Currencies | Coins (earned only), Gems (bought), Breeding Candy (earned only, never traded or sold). Until purchases are approved, Gems exist only as a balance that tests can set | Designed | L | 4 |
| Faucets and sinks | Capped coin sources; lassos, consumables, breeding, bait as sinks; an economy simulation before the numbers are set | Designed; simulation new | L | 4 |
| Shops and healer | Coin shop in every hub; the free town healer | Designed | L + S | 4 |
| Daily tasks and weekly challenge | The steady source of candy; the weekly beat | Designed | L | 4, 7 |
| Breeding service | Validate, roll from a logged seed, change coins, candy, parents and egg together | Written, not run | L | 4 |
| The mentor's lesson | In the Greenwood slice: a scripted egg, rolled by the tested rules from the mentor's two creatures, that hatches at once with no pens, cost or saving. From milestone 4: the same lesson through the real breeding service, with enough candy for a first breed | Rules tested; lesson new | L + S | 3, 4 |
| Breeder screens | Pair picker, preview, pens, hatch reveal, family tree | Designed | S | 4 |
| Serial numbers | A global counter per kind. A number is reserved before the creature is granted, so a crash can skip a number but never issue one twice; a registry records each serial's owner. The counters arrive with saving, so every saved giant has a number from the start; gem-tier serials follow | Designed | L | 4, 5 |
| Purchases | Gem packs, passes, the starter pack; each receipt granted once; prices read at runtime; PolicyService checks | Designed (`research/market/00` section 2) | L + S | 7 |

### 3.6 Saving and safety

| Item | What it is | State | Track | M |
| --- | --- | --- | --- | --- |
| Player save | One ProfileStore profile per player, session-locked, versioned, with migrations (shape in 4.3) | Designed in outline | L | 4 |
| Global stores | Serial counters and registry, leaderboards; later the trade ledger and saved PvP teams | Designed | L | 5, 8, 9 |
| Validation | Every message checked for type, ownership and rate; nothing from the client trusted | Rule set in `CLAUDE_DRAFT.md` | L | All |
| Independent reviews | A separate Opus reviewer for anything touching saving, purchases, captures, breeding, serials, trading or PvP rewards | Process defined | L | 4, 7, 8, 9 |
| Support tools | Look up a player's log; remove or restore a creature with a log entry; a tested way to restore a profile from an earlier save; later a trade ban. Policy: never undo one side of a trade | New | L | 7, 9 |

### 3.7 Screens and sound

| Item | What it is | State | Track | M |
| --- | --- | --- | --- | --- |
| Style kit | Buttons, panels, type icons with shapes as well as colours, text sizes for phones | New | S | 1 |
| Launch screens (about 20) | Starter pick, HUD, battle, lasso, team, stable, creature card, move picker, breeder, hatch, shop, healer, quest log, dialogue, world map, badges and chapters, collection index, daily tasks, Gem shop, settings | New | S | 1-6 |
| First-session script | The timed opening in section 2, measured by the funnel | Designed (`research/market/02` section 6) | L + S | 3 |
| Sound | A track per biome, battle and giant themes, effects for hits, hatches and catches | New; sourcing to decide with the asset rule | S | 6 |
| Accessibility | Lasso assist and slow mode, reduced motion, never colour alone | Designed | S | 3, 6 |

### 3.8 Launch and after

| Item | What it is | State | Track | M |
| --- | --- | --- | --- | --- |
| Roblox account steps | Age check, two-factor and ID check before the flight; Roblox Plus started then too if the all-ages fee is to be skipped | Ayrton | - | 0 |
| Store page | Name, icon, thumbnails, gameplay trailer, description | New | S | 6 |
| Playtests | Trip classmates aged 16 or over; the measures in section 7 | Planned | - | 3-7 |
| Small post-game | Breeding checklists per biome, harder giant rematches, the weekly challenge. Ayrton to confirm | Designed | L + S | 6, 7 |
| The Mire as data | Its roster, giant, quests, chapter 4 and poison written and balanced on the logic track before launch; built in January | New | L | 7, 11 |
| PvP on the Circuit | 3v3, level 50, saved-team opponents, ranked windows, four-week seasons | Designed (`research/market/07`) | L + S | 8 |
| Trading | Same server only, two-step commit with a ledger, locks, logs, an off-switch | Designed (`research/market/06`) | L + S | 9 |
| Later biomes and the weekly beat | A biome every 6 to 8 weeks; something new each week | Designed | L + S | 11 |

---

## 4. Structure

### 4.1 How the pieces depend on each other

```
6  After launch     PvP -> Trading -> Seasons -> Tournaments -> Biomes 4-11
5  Launch layer     Purchases | Analytics | Switches | Store page
4  Content          Species | Moves | Biomes | Giants | Quests | Story chapters | Items   (all data)
3  On the device    Assembler | Animation | Battle screen | Lasso | Screens | World | Sound
2  On the server    Data | Creatures | Battle | Capture | Breeding | World | Quests | Economy
1  Pure rules       Stats | Breeding | Battle | Type chart   (exist, tested under Lune)
                    Lasso timing | XP | Economy maths        (still to write)
0  Foundation       Repo | Toolchain | Blink | CI | Data formats | Part specification
```

Each layer needs the ones below it. Only part of layer 1 exists today. Content (layer 4) is data: a new biome should need no new code, which is what makes a biome every 6 to 8 weeks possible.

The longest chain of dependencies, and so the one that sets the schedule:

**part specification -> art pipeline proven -> roster balanced -> species art -> assembler and animation -> battle screen -> Greenwood slice -> saving -> the other two biomes -> launch.**

### 4.2 Repository layout

```
CLAUDE.md
default.project.json, rokit.toml, wally.toml, stylua.toml, selene.toml
src/
  shared/            pure rules, no Roblox services
    from prototype/: Types, Rng, Stats, Breeding, AssemblyMath, Battle, TypeChart
    still to write:  Lasso, Xp, Economy
  config/            every balance number: BreedConfig and BattleConfig (from prototype/), EconomyConfig, ShopConfig, LassoConfig
  content/           data only, one file per thing
    Species/  Moves/  Biomes/  Giants/  Tamers/  Quests/  Story/  Items/
                     (the prototype's Species and Moves are placeholders to replace)
  net/               Blink definitions and generated modules
  server/
    Data/      Creatures/   Battle/    Capture/   Breeding/   World/
    Quests/    Economy/     Purchases/ LiveConfig/ Analytics/
    Circuit/   Trading/     (after launch)
  client/
    Assembler/ Animation/   Icons/      BattleView/ Lasso/   World/   Audio/
    UI/        (style kit and one folder per screen)
tests/               Lune unit tests and simulations (breeding, battle tournament, economy)
lune/                check.luau and tools (contact sheet, part validation)
assets/              images and sounds
docs/                BRIEF, DECISIONS, MASTER_PLAN, BREEDING_PLAN, PART_SPEC, PROGRESS, REVIEWS,
                     ASSETS (register), plans/ (one per approval pack), research/
```

Compared with the brief's sketch, `content/` is split from `config/` so that a biome is a set of data files, and capture, purchases, live config and analytics each have a server folder.

### 4.3 What is saved

One profile per player, so that things which change together are saved together:

```
Profile = {
  SchemaVersion,
  Coins, Gems, Candy,
  Creatures = { [id] = Creature },        -- capacity set by storage owned
  Team      = { id, id, id },             -- size set per badge in config; 3 at launch
  Eggs      = { { child, hatchAt, seed } },  Pens,
  Items     = { [itemKey] = count },      -- lassos, healing, giant-attempt items, bait, charms, materials
  Story     = { starter, chapter, flags, badges, biomeReached, giantsCaptured },
  Quests    = { active, done },
  Daily     = { day, tasks, claimed },
  Index     = { seen, owned },
  Purchases = { passes, recentReceiptIds },
  Settings, PlayStats,
  -- after launch: Rating, Season, TradeEscrow, PendingTradeId
}
```

Every `Creature` record (shape in `BREEDING_PLAN.md` section 2) also carries a `bound` flag, meaning it can never be traded. It is set for giants and cosmic creatures.

Outside the profile, each in its own store and written only by the server:

| Store | Holds | Needed from |
| --- | --- | --- |
| Serial counters | The next number for each serialled kind | Milestone 4 |
| Serial registry | Which player owns each serial; two owners raises an alarm | Milestone 4 |
| Leaderboards | Ordered scores for ranked leagues | Milestone 8 |
| Saved teams | Small team snapshots for casual PvP while the owner is offline | Milestone 8 |
| Trade ledger | One record per trade; writing it is the point of no return | Milestone 9 |
| Match queue (MemoryStore) | Players waiting for a ranked match | Milestone 8 |

The Greenwood slice (milestone 3) runs without saving, so that the save design can be approved and reviewed once, in milestone 4, before any player data exists.

### 4.4 Messages between the device and the server

The device only ever sends what the player chose. The server answers with results.

| Group | From the device | From the server |
| --- | --- | --- |
| Start | Pick starter | Profile snapshot and later changes |
| Battle | Start wild, tamer or giant battle; chosen action each turn; run | Battle state, each turn's events, rewards |
| Lasso | Tap, with the time since the pattern started | The pattern and its seed; hit or miss |
| Creatures | Set team; set moves; release | Updated creatures |
| Breeding | Breed these two (with or without a charm); collect hatched; speed up an egg | Preview numbers; egg and hatch updates |
| Economy | Buy item; use item; heal; craft; use bait; claim daily task | Balances and item counts |
| World | Teleport to a hub; talk to a character; accept or hand in a quest | Spawn lists; quest and story updates |
| Shop | (Roblox's own purchase prompt) | Granted products; live config values |

### 4.5 What each biome is made of

Every biome is one content pack with the same parts (brief section 8):

| Part | Launch biomes each have |
| --- | --- |
| Hub town and routes | 1 hub, 2 routes, a lair on a side path |
| Roster | About 8 species across two body plans, balanced by the tournament before art |
| Giant | 1, with its own three-phase script |
| Gate battle and badge | The rival in Greenwood and Tide Flats; a local champion in Dust Canyon |
| Tamers | 4 to 6 per biome, themed to its type |
| Quest line | 3 to 5 quests ending in a guaranteed creature |
| Clear token | A gift creature for clearing the biome ([Locked] for Greenwood) |
| Materials and items | Local materials, consumables; bait from Tide Flats |
| Story chapter | One, with the rival's next step |
| One new idea | Greenwood: battling, the lasso, the egg. Dust Canyon: the first gem tier and serials. Tide Flats: bait |

Launch totals: 3 hubs, 6 routes, 3 giants, about 24 species (about 120 part meshes), about 50 moves, 12 to 18 tamers, 9 to 15 quests, 3 story chapters.

**Proposed scope change (a [Default], logged):** launch with **two body plans**, four-legged and two-legged, not four. Each plan needs its own rig, animation set and balance pass, and two plans still give every biome breeding options. Winged and serpent creatures arrive with later biomes (Stormreach is the winged biome).

### 4.6 Documents

| Document | Job |
| --- | --- |
| `BRIEF.md` | The vision. Changes only when Ayrton changes it |
| `DECISIONS.md` | Every decision and every changed Default. Wins over the brief |
| `MASTER_PLAN.md` | This plan: what is needed, structure, order, gates |
| `BREEDING_PLAN.md`, `PART_SPEC.md` | Detail for the two riskiest systems. `PART_SPEC.md` does not exist yet; writing it is the first task of phase 0 |
| `plans/` | One short plan per approval pack (section 5.4), signed off before building |
| `PROGRESS.md` | What changed and what Ayrton should playtest, after every feature |
| `REVIEWS.md` | Findings from independent exploit reviews |
| `ASSETS.md` | Every generated or third-party asset: id, source, licence |
| `research/` | The evidence |

---

## 5. Build plan

### 5.1 Two tracks

| Track | What | Needs |
| --- | --- | --- |
| **Logic (L)** | Pure rules, server services, data formats, content written as data, tests, simulations, plans | A Claude Code session, cloud or laptop. Can run while Ayrton is in class |
| **Studio (S)** | Art, the assembler, animation, the map, screens, phone tests, playtests | Ayrton's laptop with Studio open and the Studio MCP connected |

The logic track should always be one step ahead, so that Studio time is never spent waiting for rules or data.

### 5.2 Phases

| Phase | When | Logic track | Studio track | Ends with |
| --- | --- | --- | --- | --- |
| **0. Set-up** | Now to the flight | Write `PART_SPEC.md` first, because the art test needs it. Create the repo; move `prototype/` into `src/shared`, `src/config`, `src/content` and `tests`; CI passing; species data format; Greenwood roster and moves designed and balanced by the tournament; XP curve; lasso timing rules; economy simulation; approval packs 1 (saving) and 2 (creature grants) written | Toolchain and Studio MCP on the travel laptop; **the art test: two four-legged species and one two-legged species as parts** | Checklist in section 8; art test result |
| **1. Core proofs** (M1, M2) | Trip week 1 | Battle service; opponent tiers; Blink messages for battle; Greenwood giant script; Dust Canyon roster designed and balanced | Assembler and animation on the test species, both body plans; the 32-mix contact sheet; battle screen on a phone; 30 creatures in view | **Gate A** |
| **2. Greenwood slice** (M3) | Week 2 | Capture and lasso server rules (under approval pack 2); spawn tables; quest and story data for chapter 1; first-session funnel; Tide Flats roster designed and balanced; approval pack 3 written and pack 4 drafted | Greenwood greybox; the 8 Greenwood species; roaming creatures; lasso screen; giant lair; hub; the first-session script with the mentor's scripted egg. No saving yet | **Gate B** |
| **3. Saving and economy** (M4) | Week 3 | Data service and migrations; serial counters; coins, candy, shop, healer, items; Gems as a test-only balance; breeding service; the "biome reached" check; daily tasks; independent review of all of it | Breeder screens, hatch reveal, shop, team and stable screens; Greenwood art pass | **Gate C** |
| **4. Two more biomes** (M5) | Weeks 3 to 4 | Rosters balanced; giants, tamers, quests and chapters 2 and 3 as data; the gem tier; serials; bait and crafting | Species art; both maps; teasers for later biomes | Three biomes playable end to end |
| **5. Polish and launch** (M6, M7) | Week 4 to early January 2027 | Purchases (approval pack 4) and review; live config switches; analytics checked; support tools; the Mire written as data; launch checklist | Screens and sound pass; performance on the baseline phone; store page and trailer | **Gate D**, then soft launch to 16+ |
| **6. After launch** | January 2027 on | PvP (M8), then trading (M9); the Mire as the first new biome; the weekly beat | The same | Section 6 |

### 5.3 Gates

| Gate | Pass mark | If it fails |
| --- | --- | --- |
| **Art test** (before the flight if possible) | Two four-legged species and one two-legged species generated as parts that separate cleanly and pass the part validation | Generate each part on its own; then code-built or hand-fixed parts for thin pieces; then fewer slots per creature |
| **A. Core proofs** | A full 3v3 on a phone, run by the server, at 8 to 14 turns. Ayrton accepts at least 80% of the 32 four-legged mixes without hand fixes. The two-legged species assembles and animates. 30 creatures in view at 30 frames a second on the baseline phone | Simplify the part system before building content on it (brief section 13 note): fewer slots, or less extreme size differences between species |
| **B. Greenwood slice** | Five testers aged 16+: starter inside 30 seconds, second creature by minute 4, the mentor's scripted egg by about minute 10, badge inside 60 minutes. At least 3 of 5 keep playing past 15 minutes unasked and say they would come back | Fix the opening before anything else. Choose the launch scope here (section 5.5) |
| **C. Saving and economy** | The independent review finds nothing open on duplication or loss. Save, leave, rejoin and migrate all tested. A real breed works end to end: preview, payment, egg, hatch, save. A short playtest shows coins removed at about 60 to 70% of coins created in a player's first two hours and 80 to 95% after Greenwood, and nobody stuck | No public build until it passes |
| **D. Launch readiness** | Three testers finish all three biomes. The phone budget holds. Every purchase is granted once in tests. The off-switches work. The funnel shows up in analytics. The policy checklist in section 8 is done | Delay the launch; a broken first week cannot be re-run |

### 5.4 Approval packs

The project rules need Ayrton's yes before building anything that touches saving, purchases, captures, breeding rolls, serials, trading or PvP rewards, and an independent review after. Batching them keeps this from blocking work while he is away:

| Pack | Covers | Needed before | Review |
| --- | --- | --- | --- |
| 1 | Save shape, data service, migrations | Phase 3; approved before the flight | Yes |
| 2 | How creatures are granted: starter, capture, the mentor's egg, quest and token gifts, giants, serial numbers | Phase 2, because the slice builds the capture rules; approved before the flight | Yes |
| 3 | Breeding service, Breeding Candy sources and caps, Gem speed-ups and extra pens | Phase 3 | Yes |
| 4 | Purchases: products, prices, receipts, PolicyService | Drafted by Gate C; approved before phase 5 builds it | Yes |
| 5 | PvP rewards and rating | Milestone 8 | Yes |
| 6 | Trading: the two-step commit, locks, logs | Milestone 9 | Yes, plus crash tests at every step |

Each pack is one short plan in `docs/plans/`: what is saved, what can go wrong, how it is tested.

### 5.5 Scope: what to cut, and what never to cut

The full launch in section 2 by early January is achievable only if the art test passes early and the gates pass first time. Decide at Gate B, with evidence, between:

| Option | Scope | When it is the right call |
| --- | --- | --- |
| **Planned** | Three biomes, about 24 species, two body plans | Gates A and B pass on time |
| **Trimmed** | Three biomes with 5 species each; crafted consumables, the collection index and the weekly challenge follow in the first updates | One gate slips by up to a week |
| **Fallback** | Soft launch Greenwood alone, with breeding and the egg; Dust Canyon and Tide Flats as the first two updates, three to four weeks apart | Art or the opening needed rework. This changes Ayrton's "first few biomes" decision, so it is his call |

Cut in this order: the collection index, the weekly challenge, crafted consumables (shop-bought only, keeping one bait recipe as Tide Flats' new idea), species per biome (8 to 5), Tide Flats, then Dust Canyon.

Where it is most likely to slip: phase 1 (the first contact with Studio, and everything in it waits on unproven art), phase 2 (eight species of art, a map, the lasso, a giant and the opening in one week, plus five testers) and phase 4 (two biomes built alongside phase 3's review). Unless the art test passes before the flight, expect Trimmed or Fallback.

Never cut: the safety of saving, the independent reviews, the first-session script, the breeding preview, the analytics funnel, the off-switches.

---

## 6. After the soft launch

| Order | What | Notes |
| --- | --- | --- |
| 1 | Read the numbers for two weeks | Day-1 and day-7 return, play days per player, where the first session loses people, coins and candy in against out, breeds per player |
| 2 | The weekly beat | A returning creature, a challenge, a balance pass or a quest, on the same day each week |
| 3 | PvP on the Circuit (M8) | 3v3, level 50, saved-team opponents for casual play, ranked in fixed windows, four-week seasons, cosmetic prizes |
| 4 | Trading (M9) | Only after PvP, behind an off-switch, after approval pack 6 and its review |
| 5 | The Mire, then a biome every 6 to 8 weeks (M11) | The Mire is designed as data before launch and built in January. It brings status effects and 4v4 |
| 6 | The all-ages release | Only once players are coming back (brief section 13). Needs two-factor, the fee or Roblox Plus, the content questionnaire, and 250 engaged plays in 60 days |
| 7 | Roadmap stages 2 and 3 | Tournaments, challenge bosses, then the rival's return (brief section 14) |

---

## 7. Testing and quality

| Level | What | When |
| --- | --- | --- |
| Unit tests and simulations (Lune) | Breeding cannot run away; rarity odds match config; the battle replays from a seed; the roster tournament; the economy simulation | Every change, in `lune run check` and CI |
| Crash and abuse tests | Double requests, breeding during a battle, leaving mid-save, bad message types | With each approval pack |
| Studio playtests through the MCP | Simulated input, console errors, screenshots against the art rules | Every feature |
| Phone checks | Frame rate, draw calls and triangles on the baseline phone; touch targets | Gates A and D, and each new biome |
| Independent exploit review | An Opus reviewer that did not write the code | Each approval pack |
| Human playtests | Five testers aged 16+ at Gate B; three full play-throughs at Gate D | Gates B and D |
| Measures set before launch | Day-1 and day-7 return, play days per player, median first session, first-15-minute funnel, coins and candy ratios | Soft launch |

---

## 8. Checklists

**Before the flight**

- [ ] Roblox account: age check done; two-factor on. Start Roblox Plus now if the all-ages fee is to be skipped later (it needs two months).
- [ ] New repository created; this folder moved into it (`README.md` has the steps); `lune run check` passing in CI.
- [ ] Travel laptop: Studio, Rojo, Claude Code and the Studio MCP all working together.
- [ ] The art test run, and its result recorded.
- [ ] `PART_SPEC.md` written.
- [ ] Approval packs 1 (saving) and 2 (creature grants) read and approved.
- [ ] The decisions in section 10 marked "before the flight" answered.
- [ ] A baseline phone chosen (about 3 GB of memory).

**Before the soft launch**

- [ ] Gate D passed.
- [ ] Roblox's content questionnaire answered; the game set to 16+; avatar settings checked.
- [ ] Policy re-read on the day: Community Standards (gambling, scams), paid random items, PolicyService flags. No wheel spins or slot-style reveals anywhere.
- [ ] The shop reads every price at runtime; no urgency wording; nothing random for sale.
- [ ] Store page: name, icon, thumbnails, gameplay trailer.
- [ ] Off-switches tested on a live server; a way to stop new purchases without a release.
- [ ] `ASSETS.md` complete; every species checked for likeness to other games' creatures.

---

## 9. Risks, ranked

| # | Risk | Why it matters | Answer |
| --- | --- | --- | --- |
| 1 | AI-generated parts do not split or fit | Everything visual waits on it | The art test first, with three fallbacks (section 5.3) |
| 2 | Scope against the schedule | One builder, study days, and approvals needed from someone who is travelling | Two tracks, approval packs, a fixed cut order, the scope decision at Gate B |
| 3 | A duplication or lost-data bug | It destroys the value of rare creatures and trust in the game | One profile per player, the Greenwood slice without saving, a reviewed save design, trading last |
| 4 | The opening loses players in the first three minutes | Roblox's recommendations count early exits against the game | The timed first-session script, measured from the first playtest |
| 5 | One build beats everything | Breeding stops being a choice | The roster tournament before art; the shared stat budget |
| 6 | Phones cannot keep up | Most players are on phones | A baseline phone, our own budget, checks at two gates |
| 7 | The economy drifts (coins pile up, or candy is too scarce to breed) | Breeding is the signature and must feel reachable | The economy simulation, then tuning from real numbers; all values in config |
| 8 | A small audience for this genre on Roblox | Total players in rival games is about 5,000 at once (unverified) | Judge on return rates, not crowd size; lean on breeding, which the larger creature games share |
| 9 | Roblox's rules change again | They changed several times in 2026 | Re-read on launch day; off-switches |
| 10 | Studio or the connection is unreliable while travelling | The Studio track stops | Keep the logic track ahead; test the laptop set-up before leaving |

---

## 10. What Ayrton needs to decide, and by when

**Before the flight**

- Create the repository, and say yes or no to approval packs 1 and 2.
- Two body plans at launch (four-legged and two-legged), with winged and serpent later?
- The asset rule: AI-first with code-built or hand-fixed parts allowed where generation fails? Any paid tool is asked about first.
- Breeding Candy: confirm it is never sold, and its name.
- Giants and cosmic creatures bound to the account at launch (the plan assumes yes).

**By Gate B (trip week 2)**

- Names for the rival, the mentor and the entity. Placeholders work until the dialogue is recorded in screenshots and the trailer.
- A small post-game at launch: breeding checklists, harder giant rematches, a weekly challenge?
- Launch scope: planned, trimmed or fallback (section 5.5).

**By phase 5 (trip week 4)**

- The game's name, for the store page.
- The launch product list and prices (`research/market/00_MARKET_BRIEF.md` section 2).
- The first gem tier's name (placeholder "Amber").
- Two new ways for creatures to leave the game: fusing four of one species into one glowing creature, and using up a creature to teach one of its moves. They matter more once trading opens.

**Later**

- Style references for biome 9.
- Whether and when to go for all ages.
