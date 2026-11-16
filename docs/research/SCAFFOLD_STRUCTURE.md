# The Pokémon series' structure and core loop, as a scaffold

Date: 15 November 2026
Status: research. Nothing here is decided. The proposals it feeds are in `../DESIGN.md` (sections 3 to 11).
Asked for by: Ayrton, 15 November 2026: "use the structure and core loop of project pokemon as a scaffold for this idea".

Sources and confidence:

- **Series mechanics** (sections 1, 2 and 4) come from general knowledge of the main games, Generations 1 to 9. I did not re-check them against a source this session. Treat exact numbers as approximate unless a row says it was measured.
- **Measured** (section 3): Project Pokémon's EventsGallery (github.com/projectpokemon/EventsGallery, shallow clone, 15 November 2026), using the Scarlet/Violet live-event files. Script: `eventsgallery_cadence.py` in this folder.
- **Checked and skipped:** Project Pokémon's `rawdb` is extraction tooling that needs the game files. It is not a dataset.

---

## 1. The structure at a glance

Three loops nest inside each other, with a live layer on top.

| Loop | Rough length (approx., not measured) | What happens |
| --- | --- | --- |
| Battle | 1-3 min | Meet a wild creature or a trainer, battle, win XP, maybe catch it |
| Route | 20-60 min | Walk a route: new species, trainers, items; reach the next town and heal for free |
| Milestone | 1-3 h | Beat the town's gym leader (one type) for a badge; badges open the next area |
| Story | Tens of hours | 8 badges, recurring rival fights, a villain team, then the Elite Four and Champion |
| Post-game | Open-ended | Complete the dex, breed for perfect stats, battle facility, ranked online play |
| Live | Weekly | Limited raids, themed spawn swaps, gift distributions, monthly ranked seasons |

The core loop in one line: **encounter, battle, catch or defeat, gain XP, level up, learn a move or evolve, move on**. The meta-loop: **collect (dex), build a team, beat the milestone, open the next area**.

---

## 2. Each part and what it does for the player

| # | Part | How it works in the series | What it does for the player |
| --- | --- | --- | --- |
| 1 | Starter choice | Three starters (Grass, Fire, Water). The rival takes the one that beats yours | Ownership in minute one; teaches the type triangle without a tutorial |
| 2 | Routes and wild encounters | Each route has its own encounter table: species, % rates and level range, sometimes varying by time of day or weather | Every new area is a reveal and a reason to move on |
| 3 | Catching | Weaken it, then throw. Lower HP and status effects raise the odds. Each species has a catch rate from 3 (legendaries) to 255 (the commonest) | Effort turns into ownership; the collection grows from play |
| 4 | Trainers | Fixed teams placed on routes; they pay money and XP | Predictable practice and income |
| 5 | Gyms and badges | Eight leaders, each specialising in one type, in a set order. Badges open areas and, in older games, decide whether high-level creatures obey you | A countable goal ("3 of 8"), a skill check that teaches type matchups, a natural difficulty ramp |
| 6 | Rival | Recurring battles at checkpoints; their team grows with yours | A personal mirror; progress you can feel |
| 7 | Levels and growth rates | Six XP curves. "Medium Fast" needs n³ XP (1,000,000 at level 100); the others run from 600,000 to 1,640,000. Modern games share XP across the whole party | Steady small rewards; rare creatures feel earned |
| 8 | Evolution | Mostly at set levels (starters at 16, then 32-36); some by item, trade or friendship | The big mid-route surprise: a creature you raised becomes something new |
| 9 | Moves | Four slots, learned by level or from teaching items; you replace one to make room | Build choices |
| 10 | Type chart | 18 types since Generation 6; x2, x0.5 or x0, plus 1.5x for a same-type attack | Knowledge beats grinding |
| 11 | Hidden stats | IVs (0-31 per stat), EVs (from what you battle, capped per stat and in total), natures (+10% / -10%), abilities | Depth for long-term players that casual players can ignore |
| 12 | Breeding | Two compatible parents (by egg group) make an egg of the mother's species in its first form. 3 of 6 IVs are inherited (5 with a held item); another item passes the nature; hatch time depends on the species | The endgame project: breed the perfect one |
| 13 | Shiny variants | A colour variant: 1 in 4,096 base (Generation 6 on), better with a dex-completion reward and with parents from games in different languages (about 1 in 683) | The rare flex; hunting becomes its own loop |
| 14 | Dex | "Seen" vs "caught", visible gaps, completion rewards; species exclusive to one version push trading | A checklist that never runs out of next steps |
| 15 | Free healing in towns | Losing costs little | Fail fast and try again |
| 16 | Elite Four and Champion | Five battles in a row without leaving | The climax: a test of the whole team |
| 17 | Battle facility | A post-game tower with win streaks; levels flattened to 50 | Endless PvE where team building wins, not levels |
| 18 | Ranked online | Monthly ranked seasons at level 50; rule sets that change which creatures are allowed every few months | The meta keeps moving without new content |
| 19 | Live events | Raids, spawn swaps, gifts (measured in section 3) | A reason to come back this week |
| 20 | Social | Trading, link battles, co-op raids | Friends multiply play time |

---

## 3. Measured: how the live layer runs (Scarlet/Violet, 2022-2026)

**Method.** Shallow clone of EventsGallery; the `Released/Gen 9/SV` folders. Each event's start date comes from its identifier (YYYYMMDD) in `Encounters.txt`. This is the community's archive, so it may miss events, and several folders can share one start date.

| Event type | What it is | Count | Cadence |
| --- | --- | --- | --- |
| Raid events | Limited-time co-op boss battles (up to 4 players) | 146 folders, 110 distinct start dates, 25 Nov 2022 to 28 Aug 2026 | Median 7 days between starts (mean 12.6; 90% within 21 days). 29, 39 and 32 starts in 2023, 2024 and 2025 |
| Outbreak events | A themed swap of what spawns in the open world | 38 events, 29 Sep 2023 to 28 Aug 2026 | Median 21 days between starts (mean 28.8) |
| Gift distributions | A creature or items, by code or online | 217 Scarlet/Violet files, 35 Legends Z-A files | File names carry no dates |

**How the raids are built** (from the 146 raid folders):

- 106 of 146 events (73%) feature a one-off top-difficulty boss that each player can catch **once only**. 27 are "spotlight" rotations of several species.
- 34 of 146 (23%) are named reruns ("Round 2" and so on).
- Bosses are scripted. Example, the event dated 28 February 2025: HP x35. A shield goes up at 75% HP or at 80% time remaining. Further actions fire at set time and HP thresholds: a self-buff, a field effect, and resets of the players' or the boss's stat changes.
- Rewards come in two tables: fixed drops everyone gets, and a bonus lottery with a percentage per line. 471 of 481 bonus tables sum to exactly 100%.
- Each event is a bundle of data tables (enemy, fixed rewards, lottery rewards, priority), downloaded as in-game news without a game update.

**How the outbreaks are built:**

- Each event swaps spawn tables per region. Most themes are one species or family, or a rarity hook (baby forms, a golden variant, hard-to-find species). A few are element-themed or seasonal.
- Half of the outbreak spawn entries (78 of 156) raise the shiny rate to 0.5%, about 20 times the 1-in-4,096 base.

**What this means for us:**

1. A new event every week is the series' norm, and almost all of it is data, not code. With Roblox ConfigService (`docs/research/LIVE_CONFIG_PLAN.md` in the golf repo) we can ship weekly bosses and spawn swaps as config.
2. One-time trophies (catch once) plus reruns (about a quarter of events) keep a weekly schedule affordable.
3. Bosses that fire scripted actions at HP and time thresholds fit our seeded, fixed-step simulator exactly.
4. Reward tables that sum to 100% are how their designers author drops. We can show the same tables to players: odds for free rewards are optional (`CLAUDE.md` rule 9), but readable odds suit the audience.

---

## 4. Where the series is weak for our audience

| Weakness | Why it matters for a 12-15 mobile Roblox player | Our answer (see `../DESIGN.md`) |
| --- | --- | --- |
| Slow opening: dialogue and tutorial before the first real choice, first gym usually an hour or more in | Roblox's recommendations count first-play bounce under 60 s and 61-180 s (`docs/research/FIRST_SESSION_AND_RETENTION.md` in the golf repo) | Starter egg in the first 30 s, first breed by minute 10 |
| Manual turn-based battles, a menu for every move | Slow on a phone; long sessions | Auto-battles; decisions are team, rows and abilities (Locked) |
| 18 types | Too much to learn at 12-15 | 6 elements, one wheel |
| Hidden IVs, EVs and natures | Unreadable without outside tools | Stars shown after hatch (Locked) |
| Breeding is an endgame activity, and a baby is a copy of the mother's species | The series' genetics are invisible | Our hook: babies visibly mix both parents, from minute 10 |
| Long story text | Poor fit for 10-20 minute sessions | Minimal text; one-screen rival and Warden intros |
| Grinding levels | Dull | Whole team shares XP; XP over the level cap is banked, not lost |

---

## 5. Market note

- **Loomian Legacy** (Roblox) already runs this structure with its own creatures: story, gym-style battles, turn-based combat, ranked PvP. It is our closest competitor (`../DESIGN.md` section 1). So the structure is proven on Roblox, and our differences (visible genetics, auto-battles, short sessions) must be obvious in the first minute.
- Its studio's earlier game, *Pokémon Brick Bronze*, used the series' own names and creatures and was taken down in 2018 after a Nintendo copyright claim. The studio then rebuilt the same structure around original creatures as Loomian Legacy. That is the model we follow: borrow structure and loops, and use our own names, creatures and art. (From memory; not re-checked this session.)

---

## 6. What we take

The adopted mapping, part by part, is the table in `../DESIGN.md` section 3. In short:

- **Take as is:** starter choice, zones with their own wild creatures, a milestone boss per zone with a countable badge, a recurring rival, growing up, a dex with visible gaps, free healing, a tower with flattened levels, ranked seasons with changing rules, weekly bosses and spawn swaps run as data.
- **Take and simplify:** catching (a single "befriend" roll after a win), moves (two inherited abilities), type chart (6 elements), hidden stats (visible stars).
- **Flip:** breeding moves from endgame to minute 10, and babies mix both parents instead of copying the mother's species.
- **Leave out:** turn-based menus, long story text, version exclusives, trade-only evolutions, field moves that gate areas.
