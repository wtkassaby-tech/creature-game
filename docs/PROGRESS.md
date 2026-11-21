# Progress

What changed, and what Ayrton should do or look at next. Newest first.

## 21 November 2026 (giant capture)

| Piece | State | Where |
| --- | --- | --- |
| Hollowbough as a creature of its own, with two signature moves | Tested | `src/content/species/Hollowbough.luau` |
| One capture throw after a giant win; the serial number steps; once per player | Tested (41). Review running | `src/shared/GiantCapture.luau`, `src/server/Giants/`, `src/server/Serials/` |
| Giant Candy and breeding from a captured giant | Tested | `src/shared/Breeding.luau`, `src/shared/Rewards.luau` |

1040 checks pass. **To try in Studio:** buy a Giant Horn and a Braided Lasso, walk to the lair past the stall on Route B, wake Hollowbough and win. A panel offers one throw: three loops. On a hit, "Hollowbough No. 1 is yours!" should appear and it should be on the creatures screen, bigger than the rest.

## 21 November 2026 (after Ayrton's answers): lasting damage, the healer, long grass

| Piece | State | Where |
| --- | --- | --- |
| Damage lasts between battles; the free healer; waking at the healer when the team faints; tonics between fights | Tested (28), reviewed | `src/shared/Health.luau`, `src/shared/BattleSession.luau` |
| Long grass in every stretch of route (battles you did not choose), beside the creatures you can see | Tested, reviewed | `src/shared/Encounters.luau`, `src/server/World/` |
| Seventh independent exploit review | Done: no must-fix; four should-fix, all fixed | `docs/REVIEWS.md` |

**To try in Studio:** walk through a "Long grass" patch beside a route and a battle should start by itself. Get hurt, then check the creatures screen shows the lost health and a Tonic button; talk to the healer at Brightwater House to mend everyone; lose a battle with your whole team and you should wake at the healer.

## 21 November 2026 (latest): giants, the shop, real screens

**In one line:** Greenwood can be played from the first minute to the badge, with wild creatures, tamers, the rival, quests, the shop, breeding and the giant fight, on real (first-cut) screens. 958 checks pass. **None of it has run in Roblox Studio yet.**

| Piece | State | Where |
| --- | --- | --- |
| Giant fights: horn, turns, items, rewards, giving up; the giant quest | Tested (31), reviewed | `src/shared/GiantSession.luau`, `src/server/Giants/` |
| Choosing the team; story gates on breeding and the shop | Tested (12) | `src/shared/Team.luau`, `src/shared/World.luau` |
| Screens: battle, lasso, giant fight, shop, creatures (team, breeding with cost and odds, eggs, release), a coin and candy bar | Type-checked. **Not yet seen in Studio**: expect layout fixes | `src/client/` |
| Sixth independent exploit review (giants) | Done: one must-fix (saved-up cheap horns), fixed | `docs/REVIEWS.md` |
| Approval pack 4: what a captured giant is | **Waiting for Ayrton** | `docs/plans/04_GIANT_CAPTURE.md` |

**First thing to do in Studio** (with Claude Code and the Studio MCP on the laptop): `rokit install`, `wally install`, `lune run check`, then press Play and walk the list under "What Ayrton can playtest" below. Expect the first run to turn up errors that only Roblox can show (anything about parts, prompts, screens and data stores); the rules underneath are tested.

## 21 November 2026 (later): a world to walk in, tamers, the rival, quests

| Piece | State | Where |
| --- | --- | --- |
| Map layout generated from the biome data, and a grey-box Greenwood built from it | Tested; the map itself not yet seen in Studio | `src/shared/Layout.luau`, `src/server/World/TestMap.luau` |
| Each player's own wild creatures on the routes, rustle spots, position checks | Tested (32), reviewed | `src/shared/Encounters.luau`, `src/server/World/WorldService.luau` |
| Tamers and the rival's two story battles, with rewards | Tested (27), reviewed | `src/shared/Trainers.luau`, `src/shared/Rewards.luau` |
| Story triggers confirmed by the server (place, win, catch, talk) | Tested, reviewed | `src/shared/StoryTriggers.luau`, `src/server/Story/` |
| Quests: take, count, hand in; Greenwood's five quests | Tested (26), reviewed | `src/shared/QuestProgress.luau`, `src/server/Quests/` |
| Gift paying shared by the story and quests | Tested | `src/shared/Gifts.luau` |
| The shop (lassos, tonics and the rest, for coins) and items in battle | Tested (24), reviewed | `src/shared/Shop.luau`, `src/server/Inventory/` |
| The battle screen and the lasso screen (health bars, moves with their damage, lasso, items, switch, run) | Type-checked. **Not yet seen in Studio**: expect layout fixes | `src/client/BattleView/`, `src/client/Lasso/LassoView.luau`, `src/client/UI/Kit.luau` |
| Fourth and fifth independent exploit reviews (the world; quests, shop, items) | Done: no must-fix; every should-fix fixed | `docs/REVIEWS.md` |

**What Ayrton can playtest in Studio now:** press Play. A grey-box Greenwood is built: the town square, Route A to the west, Route B to the east. Walk west along the path: wild creatures (coloured balls with name tags) stand by it; walk up to one and press the prompt to battle. The whole of chapter 1 can be played in order: beat the rival in the square, walk onto Route A, beat Pip, reach the clover meadow, talk to the mentor, catch a creature, talk to the shopkeeper (who also gives the first quest), reach the gate, beat the rival there, walk on past the gate. Battles now open their own screen (moves, lasso, items, switch, run); the grey test panel on the left stays as a log and a fallback.

## 21 November 2026: rewards, the story, releasing, and a Studio test panel

| Piece | State | Where |
| --- | --- | --- |
| Battle rewards: coins with the daily falloff, the biome's material, XP shared across the team | Tested (15), reviewed | `src/shared/Rewards.luau` |
| Story beats: the starter pick and every chapter 1 gift (lassos, creatures, the mentor's egg, pens, Prism, the badge), paid once and whole | Tested (25), reviewed | `src/shared/StoryProgress.luau` |
| Releasing a creature | Wired, reviewed | `src/server/Main.server.luau` |
| The player's state sent to the device (coins, candy, creatures, eggs, story) | Tested (7) | `src/shared/Snapshot.luau`, `src/server/State/` |
| Device side: answers pings, keeps the state, plays the lasso sweep | Type-checked | `src/client/` |
| Studio-only test panel: wild battle, moves, run, lasso with a live bar (Space to tap), next story beat, a log | Type-checked. Grey boxes on purpose | `src/client/Debug/TestPanel.luau` |
| Third independent exploit review | Done: 2 should-fix and 5 notes, all fixed | `docs/REVIEWS.md` |

**What Ayrton can playtest in Studio now:** press Play. You get Mossmitt as your starter through the real story path. The panel on the left shows your coins, lassos and creatures. Press "Wild battle", fight with "Move 1" to "Move 4", or press "Throw Basic" and tap Space when the white marker is inside the green zone. Check that a catch adds a creature and candy, a win pays coins, and "Next beat" walks through chapter 1 (lassos, the mentor's egg, which hatches in 3 minutes).

## 20 November 2026: saving, catching and breeding on the server

**In one line:** the server side of saving, catching and breeding is written, type-checked, tested where it is pure, and reviewed. It has not run in Studio yet.

| Piece | State | Where |
| --- | --- | --- |
| Saving: one locked profile per player (ProfileStore), a test store until launch, upgrades on a copy, broken saves refused untouched | Written, reviewed | `src/server/Data/DataService.luau`, `src/config/ProfileConfig.luau` |
| Creature grants: one-time gifts, a waiting list when the stable is full, two-step giant captures, release payouts | Tested (37), reviewed | `src/shared/Grants.luau` |
| Typed candy (Ayrton's Pokémon-style idea): catching and releasing pay candy of the creature's type; each parent in a breed pays its own type | Tested | `src/shared/Economy.luau`, `docs/DECISIONS.md` |
| Lasso throw rules: lasso spent first, judged on the server's clock, impossible taps count as misses, rare creatures flee | Tested (23), reviewed | `src/shared/Capture.luau` |
| Network messages for catching, ping and breeding | Compiled | `src/net/Net.blink` |
| Capture service, round-trip meter, breed requests, hatching, server start-up | Written, type-checked | `src/server/Capture/`, `src/server/Main.server.luau` |
| Second independent exploit review | Done: 1 must-fix and 4 should-fix, all fixed | `docs/REVIEWS.md` |

743 checks pass.

**What Ayrton can playtest once Studio is set up:** join in Studio (you get a test Mossmitt), start a wild battle (Studio gives a Greenwood creature), throw a Basic lasso, tap the zones. Then check: a good throw catches and pays candy; a bad one spends your turn; leaving and rejoining keeps the creature. There is no on-screen battle or lasso yet, so for now this is driven from the command bar.

**Next:** the release and starter-pick services, battle rewards, then the client screens for battle and lasso.

## 16 November 2026: from plan to a working project

**In one line:** the game's rules now exist as tested code in a real project structure. Nothing has been built in Roblox Studio yet, and the next steps need Ayrton's laptop.

### What exists now

| Piece | State | Where |
| --- | --- | --- |
| Project structure, quality gate, CI workflow | Done. Formatting, lint and strict type analysis pass | `README.md`, `lune/check.luau` |
| Breeding rules | Tested (31 checks) | `src/shared/Breeding.luau`, `Stats.luau` |
| Battle rules and the type chart | Tested (10) | `src/shared/Battle.luau`, `TypeChart.luau` |
| Opponent behaviour: wild, tamer, rival | Tested (10) | `src/shared/BattleAi.luau` |
| Giant fights and the first giant, Hollowbough | Tested; tuned against the real species | `src/shared/GiantBattle.luau`, `src/content/giants/` |
| Lasso catching | Tested (51) | `src/shared/Lasso.luau` |
| XP, levels and level caps | Tested (43) | `src/shared/Xp.luau` |
| Saved data: shape, safe upgrades, checks | Tested (54). Nothing saves yet | `src/shared/Profile.luau` |
| Economy: every price and reward, with a 30-day simulation | Tested (38) | `src/shared/Economy.luau`, `docs/ECONOMY_MODEL.md` |
| Greenwood roster: eight species, 24 moves, balanced | Tested (28) | `src/content/species/`, `docs/content/GREENWOOD_ROSTER.md` |
| Part specification, art test procedure, Studio part validator | Written. **Not yet run in Studio** | `docs/PART_SPEC.md`, `docs/ART_TEST.md`, `tools/studio/ValidateParts.luau` |
| Server breed flow, creature assembler | Written and type-checked. **Not yet run in Studio** | `src/server/Breeding/`, `src/client/Assembler/` |
| Approval packs 1 and 2 | Waiting for Ayrton | `docs/plans/` |
| Independent exploit review of the saving design | Done; nine must-fix findings fixed | `docs/REVIEWS.md` |

332 checks pass in total.

### What Ayrton needs to do, in order

1. **Create the creature game's repository** and copy this folder into it (five steps at the bottom of `README.md`). Add it to a Claude Code session so work can continue there.
2. **Set up the travel laptop:** Studio, Rojo, Claude Code and the Studio MCP working together. `rokit install`, `wally install`, then `lune run check` should pass on the laptop; it has only been run in a cloud sandbox so far, where Wally packages and one lint standard could not be downloaded.
3. **Run the art test** by following `docs/ART_TEST.md` with Claude Code and the Studio MCP. It is the biggest unknown in the whole plan: whether AI-generated parts split cleanly and fit together. Use Burlhorn and Spadesnout (four-legged) and Mossmitt (two-legged) from the roster document.
4. **Read and answer the two approval packs** in `docs/plans/`. Each ends with a tick-list and two questions.
5. **Answer the open decisions** at the end of `docs/DECISIONS.md`. The ones that shape the next build steps: two body plans at launch, the asset rule, Breeding Candy never sold, and whether switching in battle should be made cheaper.

### What Claude Code does next (no Studio needed)

- Networking messages for battles, catching and breeding, compiled with Blink.
- The battle service: the server runs each battle and takes one action a turn.
- Greenwood's wild creature tables, tamers, quests and the first story chapter, as data.
- Rosters for Dust Canyon and Tide Flats, through the same balance gate.
- Approval pack 3 (breeding service and Breeding Candy sources).

### Honest notes

- Nothing here has run inside Roblox. The rules are tested as pure code; the server and on-screen files are type-checked against Roblox's definitions only.
- The balance numbers come from simulations with simple computer players, not from people. Expect to retune after the first real playtest. The economy is most sensitive to how long battles really take.
- Species and move names are placeholders that should be checked against other games before any art is made.
- The schedule risk in `MASTER_PLAN.md` section 5.5 has not changed: unless the art test passes before the trip, expect the trimmed or fallback launch.
