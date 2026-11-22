# Progress

What changed, and what Ayrton should do or look at next. Newest first.

## 23 November 2026 (soul: creatures with faces, a town with life)

**In one line:** Ayrton on the restaged battle: "really blocky and soulless, we need soul here". The creatures now have their own bodies and faces and are alive while they stand there, and the town has light, cottages, people and greenery. Checked in Studio; the full check passes. All of it is built in code from rounded shapes: nothing bought or uploaded.

| Added | Where |
| --- | --- |
| **Creatures you can see.** Mossmitt, Sloshcalf, Spadesnout, Gorsling and Stumpwarden each have their own body, drawn from the "Look" written in their species file (Mossmitt's moss mitts and clover tuft, Sloshcalf's pond bubble and lily-pad ears, Spadesnout's trowel snout and claws). Every other species gets a plain body for its body plan in its type's colour | `src/client/Creatures/ToySketches.luau` |
| **They are alive.** Each one breathes, sways and blinks, out of step with the others. Eyes have a glint | `src/client/Creatures/ToyBody.luau` |
| **In battles and in the world.** The battle scene uses them (lunge, flash, shake, sink). Wild creatures on the routes are these bodies too, not white balls; rarity is now the colour of the name over them | `BattleStage.luau`, `WorldView.luau` |
| **Bystanders step aside.** A person or signpost standing where the battle is staged is hidden for its length, on that player's screen only | `BattleStage.luau` |
| **Light.** Warm afternoon sun, a soft haze, drifting clouds, a little more colour | `src/server/World/Dressing.luau` |
| **A town.** Cottages with pitched roofs (a colour for each kind of building), doors, windows and window boxes; lamp posts and flower beds round the square; people with heads, hair and coloured shirts | `Dressing.luau`, `TestMap.luau` |
| **Greenery.** Trees, bushes, rocks and flowers along every route and round every town, different in each biome, always the same for the same biome. Scenery never blocks a path | `Dressing.luau` |
| Name signs: keepers known only by an id no longer wear it; the rival's sign says "Rival" | `TestMap.luau` |

**Still stand-ins:** these bodies are toys made of spheres, not the final part meshes; breeding does not yet mix their parts on screen. The world is still the test map underneath.

**Not checked:** routes and the other three biomes with the new scenery (only the first town was looked at); the phone-sized view; frame rate on a real phone (about 400 more parts per biome).

**To playtest:** walk the town and Route A, fight a wild creature and the rival. Does it have the feeling you want now? Which creature do you like most and least?

## 23 November 2026 (the battle restaged in the classic style)

**In one line:** Ayrton saw the first arcade restyle and said it "looks really AI generated", and to follow Project Pokemon's style. The battle is now a scene in the world, staged the way that game stages it, and every screen has a plainer, flatter look. Checked in Studio; the full check passes.

**What was taken from Project Pokemon** (its battle screens were looked at directly): the two creatures stand on round pads in the world; the camera sits behind the player's own creature with the opponent further off; the health plates are slim, dark and see-through; there is very little else on the screen. These are layout ideas. Nothing of Pokemon's is copied: no creature, name, icon or picture.

| Changed | Where |
| --- | --- |
| The battle is a scene: pads, the two creatures, the camera behind yours, the tamer standing to one side. Name signs in the world hide while it shows | `BattleView/BattleStage.luau` (new) |
| The attacker darts forward; the creature that is hit flashes white and shakes; a fainted creature sinks and fades; the damage floats up from the creature | `BattleStage.luau`, `BattleFx.luau` |
| Slim health plates beside each creature: name, level, type chip, HP bar and numbers, tempo meter | `BattleView.luau` |
| No panel behind the buttons, so the scene stays in view | `BattleView.luau` |
| Every screen: flat dark panels, flat buttons, one bold typeface (Gotham), no outlines, shading or button lips | `UI/Kit.luau` |
| A smaller result panel | `ResultPanel.luau` |

Kept from the first try: move buttons in their type's colour with STRONG or WEAK, the pale trail on a dropping health bar, the sounds, the speed switch and tap to hurry, the counting result.

**Stand-ins:** the creatures in the scene are round placeholder bodies in their type's colour. Real models (`Assembler.build`) take their place when the part meshes exist.

**Not checked after the last two small changes** (panels made a little more solid, the result panel made smaller): they pass the full check but were not looked at again in Studio. The phone-sized view was not re-run for the new battle layout.

**To playtest:** fight the rival. Does it look and feel closer to what you want? Which parts still look generated?

## 22 November 2026 (two fundamentals taken to finished quality)

**In one line:** the shared look of every screen and the feel of a battle turn are now built properly, in the "toy arcade" direction from the research. Checked in Studio at desktop and phone size; the full check passes. Creatures are still not drawn, so the two battle cards stand in for them.

**1. The look of every screen** (`src/client/UI/Kit.luau`, one file, so every screen changed at once)
- Panels and buttons have a dark outline and soft top-to-bottom shading.
- Buttons have a darker lip along the bottom that sinks when pressed and springs back, and a click sound. The lip is the same height on a small button and a big one.
- Big text has a dark outline so it reads over the world.
- Bars leave a pale trail for a moment when they drop, so the size of a hit can be seen.
- One colour per type (`Kit.ELEMENT_COLOURS`), used on move buttons, type chips and the starter pick.

**2. The battle turn** (`src/client/BattleView/`)
- **Move buttons** are in the colour of the move's type and say STRONG or WEAK against the creature in front of you (`MoveButton.luau`). Players learn the type chart from the buttons.
- **Creature cards** show name and level, a chip in the type's colour, and health numbers on the bar.
- **A hit** flashes and shakes the card that was hit, floats the damage up from it, and plays a different sound for a strong, normal or weak hit. A strong hit also shows a big STRONG HIT! (`BattleFx.luau`).
- **Speed:** a switch for fast battles, and a tap anywhere hurries the turn being shown. Slow battles are the commonest complaint about games of this kind.
- **The result** is a VICTORY!, CAUGHT! or DEFEATED panel where coins and XP count up and level-ups pop in one at a time (`ResultPanel.luau`).
- Sounds are eight stand-ins that ship inside Roblox (`src/client/Audio/Sfx.luau`, logged in `docs/ASSETS.md`).

Everything shown is the server's own result, played back. Nothing here changes a rule, a number or what is saved.

**Not done, on purpose:** the over-the-shoulder battle camera and anything that needs creature models; the lasso screen; the speed switch is not remembered between visits (remembering it touches saving).

**To playtest:** fight the rival and a few wild creatures. Does a hit feel like a hit? Is normal speed too slow, or fast too fast? Do the type colours and STRONG / WEAK help? Try it on a phone.

## 22 November 2026 (the longer Studio run and a phone-sized check)

**In one line:** chapter 1 was played through to the Acorn Badge in Studio, then the shop, crafting, breeding, daily tasks, the giant (fight and capture) and the road into Dust Canyon. All of it works; the server logged no errors in about 60 battles. Eight screen fixes came out of it, half of them for phones. The full check passes.

**How it was played:** by hand through the story's first beats, then with a test script that sends the same messages the screens send (pick the strongest move, heal at the healer), so the server judged everything as it would for a player. Reaching the gate took 39 battles and about 21 minutes of play time; the first try at the gate (team at 12 to 14) was lost narrowly, the second (14 to 15) was won.

| Worked as designed | Notes |
| --- | --- |
| Story beats 1 to 13, the Acorn Badge, the sealed road, chapter 2's first two beats | "The tree that walks" fires a few steps past the meadow's signpost, not at it |
| Shop: buy, refuse when far away, make a tonic from 3 Fernfluff | |
| Breeding: cost and odds shown, "Not enough coins" refusal, a real breed, the mentor's egg hatching | Prism covered a 1 Leaf candy shortfall, as designed |
| Daily tasks appear with the badge; "Breed once" moved to 1/1 | |
| Giant: refused when far away, horn spent, lost once, won once, capture offer, Braided throw, "Hollowbough No. 1", serial logged | |
| Dust Canyon: creatures appear with the badge; a level 14 wild battle won | |

| Found | Fix | Where |
| --- | --- | --- |
| The Creatures list was torn down and rebuilt every second while an egg was in a pen, so a tap could land on a button that had just been replaced | The egg timers now update only the top lines | `CreaturesView.luau` |
| Daily tasks sat under the creatures, not at the top | Rows are given an explicit order | `CreaturesView.luau` |
| "Not enough coins" was half hidden behind the Creatures panel | Notices have their own layer above every screen | `CreaturesView.luau` |
| The shop stayed open over a battle (it sits above the battle screens) | The shop closes when a battle or giant fight starts | `ShopView.luau` |
| Shop text showed notes meant for us ("BreedConfig.CHARM_CHANCE", "Trivially cheap, so catching is never blocked") and "CanyonGrit" | Four descriptions rewritten for players; materials shown with a space | `EconomyConfig.luau`, `ShopView.luau` |
| On a phone-sized screen the "You won" box had a 30 px Continue button, and a long reward list ran over it | Taller box, text that shrinks to fit, a 48 px button | `BattleView.luau` |
| A world prompt ("Battle Rival") was drawn right over the Continue button, and E could start things behind an open screen | Prompts hide while any screen is open | `Main.client.luau` |
| Buttons under finger size on a phone: dialogue Next (34 px), Creatures (36), Close (32 to 34), the row buttons (36), Clear (30) | All 40 px or more | `StoryView.luau`, `CreaturesView.luau`, `ShopView.luau` |

**Phone-sized check (874 x 401, an iPhone 17 Pro's size):** starter pick, dialogue, tracker, battle, the result box, Creatures and Shop all fit with no cut-off text. Not covered: real finger taps (the Studio tool could not tap reliably in touch mode, so the check was driven by mouse at phone size); play on a real phone.

**Could not be tested here:**
- The off-switches (`shop_open` and the others): Roblox's ConfigService does not load in an unpublished place, so `SetTestingValue` has nothing to act on. The game stays open, as designed. Test after the first publish.
- Tide Flats and beyond (needs the Cairn Badge: all of chapter 2).
- Saving (Studio uses the in-memory mock).

**For Ayrton to judge (nothing changed; listed in `docs/DECISIONS.md` under Still open):**
- The giant is very tight for a team at the cap: lost with 75 of its 1,150 health left using no items, won with 2 health left on the last creature using all 5 items.
- XP keeps building at the level cap and is paid out at once when the badge lifts it (15 to 19 in one battle).
- The mentor's "Welcome! Pick the one that feels right" shows after the pick, because the pick screen covers it.
- Talking to Tuppence opens her story lines over the open shop.
- The breed strip says "candy: 2 Leaf" and does not say Prism covers a shortfall.
- A giant fight does not stop the player walking away (a normal battle does).

**Later the same day, four of those six were fixed** (Ayrton: "Keep going"), checked in Studio, and the full check passes:
- The mentor's welcome line is now on the pick screen itself, not said after the pick (`StoryView.luau`).
- The shop waits behind Tuppence's story lines and shows when the last one is read (`ShopView.luau`).
- The breed strip says how much of the candy will be paid in Prism (`CreaturesView.luau`).
- A giant fight stops the player walking away, through one shared lock (`src/client/UI/MovementLock.luau`, used by the battle screen too).

Left alone on purpose: the giant's difficulty (Ayrton decided on 22 November that giants stay strict) and XP building up at the level cap (it is the written rule in `src/shared/Xp.luau`, with tests: nothing is lost at the cap).

**Research:** three agents studied successful games of this kind. Their reports are in `docs/research/games/` (structure, art style, menus), with a one-page summary in `00_REPORT.md`. Nothing in them is decided.

**To playtest:** as below, with the newest fixes. On a phone, check that every button is easy to hit.

## 22 November 2026 (the first run in Roblox Studio)

**In one line:** the game has now run in Studio for the first time. Steps 1 to 12 of `docs/STUDIO_FIRST_RUN.md` all work after seven fixes; the full check passes. It is still the grey-box test build (boxes for buildings, balls for creatures): no art yet.

**How it was run:** the Rojo plugin is not installed in Studio, so the project was built to `build/creature-game.rbxlx` (`rojo build default.project.json -o build/creature-game.rbxlx`) and opened as its own Studio window. Fixes were pushed into that window script by script. To get live sync instead, install the plugin (`rojo plugin install`, restart Studio, press Connect).

| Found in the run | Fix | Where |
| --- | --- | --- |
| **No creature could be caught.** Every lasso tap was thrown out as "too early for the server clock": taps arrived 63 to 66 ms behind a 48 ms lag reading | 120 ms of slack on the early side of the lag window. Independently reviewed: safe (see `docs/REVIEWS.md`) | `src/shared/Lasso.luau`, `src/config/LassoConfig.luau` |
| Winning the first rival battle sent the player to the healer as if they had lost (both creatures fell on the last turn) | The healer check runs after a win is paid and mended, not before | `src/server/Battle/BattleFlow.luau` |
| The Creatures screen opened empty | Opening and filling it are one step | `src/client/Creatures/CreaturesView.luau` |
| The player could walk away mid-battle; a long-grass battle followed them into town | Movement is off while the battle screen is open | `src/client/BattleView/BattleView.luau` |
| Story dialogue sat on top of the moves and the "You won!" panel; the tracker sat under the foe's card | Both wait until the battle screen closes | `src/client/Story/StoryView.luau` |
| Waking at the healer put the player on the healer's head | Lands six studs to the town side | `src/server/World/WorldService.luau` |
| The win panel said "+0 coins" for the rival and never showed XP | Shows coins only when paid, and the XP gained | `src/client/BattleView/BattleView.luau` |

Also: the grey test panel now starts closed behind a small "Test" button (it covered a third of the screen), and has an "Auto tap" button that taps the lasso for you, for testing catches.

**Checked and fine:** the tree Rojo builds; the Blink messages on both sides; the starter pick; story beats and gifts; wild, long-grass and tamer battles; switching in after a faint; the healer; losing and waking in town; the two prompts at a rustle spot do not overlap; the mock save starts fresh each Play.

**Not checked yet:** a phone-sized screen; the shop, breeding, the giant, daily tasks and the later biomes (section 4 of the guide, about 50 minutes of play); the off-switches (they log "SwitchesUnreachable" in an unpublished place, as expected, and the game stays open).

**For Ayrton:** play it in the Studio window named `creature-game.rbxlx`. One thing to decide is in `docs/DECISIONS.md` under Still open (the lasso window for slow connections).

## 21 November 2026 (the Mire roster, poison, live switches)

**In one line:** the fourth biome's eight creatures now exist as data, with the first poisoning moves; nothing in the three launch biomes changes. The full check passes. **None of it has run in Roblox Studio yet.**

| Piece | State | Where |
| --- | --- | --- |
| Mire roster: eight species (six Toxic, two Water), 23 moves, four of them poisoning | Balanced and tested (190 roster checks, 22 known gaps noted). Data only: no biome spawns them yet | `src/content/species_data/`, `docs/content/MIRE_ROSTER.md` |
| Poison in the battle rules: a twelfth of health a turn for four turns; Toxic creatures are immune | Tested (23), reviewed | `src/shared/Battle.luau` |
| Thirteenth independent review (poison, switches, analytics) | Done: no must-fix; six smaller fixes made | `docs/REVIEWS.md` |
| A new live off-switch for releasing creatures | Tested | `src/config/LiveConfig.luau` |

**What to know:**

1. Inside the Mire, poison barely moves the balance, because most Mire creatures are immune. Against the creatures a player brings from the launch biomes it is strong. Whether to soften it is in `docs/DECISIONS.md` under Still open.
2. Mixing all four biomes one-on-one is less balanced than three (the best bred creature wins 81 to 85% of fights, against a target of 70%). The cause is the type chart, and it is recorded as a known gap, not hidden.
3. One Mire species was renamed (to Keelsnap) because its first name was too close to a creature in another game. All names remain placeholders.

**The Mire's world** is also written (22 November): the village of Sedgeholm, two routes, five tamers with teams of four, the rival, champion Honora Vell at the gate, the giant Sloughback, a quest line and chapter 4. Twelve robot players finish all four biomes when it is opened in a test. It is **closed in the live game** by one number, `OPEN_BIOMES` in `src/config/ReleaseConfig.luau` (3 at launch), and a test checks nothing from it leaks into the open biomes. Opening it needs its map and art in the place first. Details: `docs/content/MIRE_WORLD.md`.

## 21 November 2026 (Tide Flats, and robots that play the whole game)

**In one line:** all three launch biomes can now be played end to end on the server, and twelve robot players prove it on every check: each one plays from the starter pick to the third badge through the real rules. 1,910 checks pass. **None of it has run in Roblox Studio yet.**

| Piece | State | Where |
| --- | --- | --- |
| Tide Flats: the town of Saltwick, two routes, five tamers, Captain Marr mid-biome, the rival at the gate, the giant Carrackon and its creature form, a bait quest line, chapter 3 | Tested (356). Data only | `src/content/`, `docs/content/TIDE_FLATS_WORLD.md` |
| Robot players: twelve play the whole story with different luck; all must finish, inside the pacing targets | New test | `tests/playthrough.test.luau` |
| The rival's first battle truly cannot be lost: the player's last creature holds on with 1 health | Tested, reviewed | `src/shared/BattleSession.luau` |
| Levelling about three times quicker; gates one level easier | Changed after the robots' findings | `src/config/ProgressionConfig.luau`, `docs/DECISIONS.md` |
| Twelfth independent exploit review (the unlosable battle) | Done: one must-fix, fixed | `docs/REVIEWS.md` |
| Analytics: the first-session funnel, coins and candy in and out, counts of catches, hatches and lost battles | Written and tested as rules; only sends from a published game | `src/shared/AnalyticsMap.luau`, `src/server/Analytics/` |
| Live off-switches for the shop, breeding, giants and daily claims | Written and tested as rules; not yet run in Studio | `src/config/LiveConfig.luau`, `src/server/LiveConfig/` |
| The "biome reached" rule for teams | Tested | `src/shared/Team.luau` |

**What the robots found** (each was a real problem, now fixed):

1. Two of the three starters lost the "cannot be lost" first battle every time.
2. Three biomes took about 14 hours of battling, against a plan of 4 to 5 hours in all. Now about two and a half hours of battling.
3. Most robots could never pass the Dust Canyon gate, even at full level with tonics. Now every robot passes every gate within three tries, and about half of story battles are still lost first time.
4. With lasting damage, a player who always leads with the same creature walks to the healer after almost every wild battle. Rotating the healthiest creature to the front fixes it, and the mentor now says so when the player first steps onto Route A.

**To try in Studio:** play Greenwood from the start and note the time when you win the Acorn Badge (the plan says within an hour), and whether the rival at the gate feels fair. Then say whether levelling feels too quick, too slow or right.

**Still to build on the logic side:** purchases (after pack 5); trading and the Circuit (after launch, per the plan).

## 21 November 2026 (Dust Canyon and the multi-biome world)

**In one line:** two biomes can now be played end to end on the server: Greenwood, then Dust Canyon, with its own town, routes, tamers, giant, quests and story chapter. 1463 checks pass. **None of it has run in Roblox Studio yet.**

| Piece | State | Where |
| --- | --- | --- |
| The world across biomes: layout, gating by badge, shops and healers in every town, Waystation travel | Tested, reviewed | `src/shared/Layout.luau`, `src/server/World/` |
| Dust Canyon: town, two routes, five tamers, gate champion, rival appearance, giant Mesalith and its creature form, quest line, chapter 2 | Tested (345). Data only | `src/content/`, `docs/content/DUST_CANYON_WORLD.md` |
| Gem-tier wild creatures with serial numbers | Tested, reviewed | `src/shared/Grants.luau`, `src/server/Serials/` |
| Stable room for coins; the lasso timing audit | Tested, reviewed | `src/shared/Shop.luau`, `src/server/Capture/` |
| Tenth independent exploit review | Done: two must-fix (rewards and fights in a biome not yet earned), fixed | `docs/REVIEWS.md` |
| Approval pack 5: purchases | **Waiting for Ayrton** | `docs/plans/05_PURCHASES.md` |

**To try in Studio:** earn the Acorn Badge, walk east past the Greenwood gate along the sealed road to Kilnrest, and check that Dust Canyon's creatures only appear once you hold the badge. Talk to a Waystation keeper to jump back to Thistledown.

**Still to build on the logic side:** Tide Flats (roster, world, bait); purchases (after pack 5); trading and the Circuit (after launch, per the plan).

## 21 November 2026 (giant capture)

| Piece | State | Where |
| --- | --- | --- |
| Hollowbough as a creature of its own, with two signature moves | Tested | `src/content/species_data/Hollowbough.luau` |
| One capture throw after a giant win; the serial number steps; once per player | Tested (51), reviewed | `src/shared/GiantCapture.luau`, `src/server/Giants/`, `src/server/Serials/` |
| Giant Candy and breeding from a captured giant | Tested, reviewed | `src/shared/Breeding.luau`, `src/shared/Rewards.luau` |
| Daily tasks: three easy, three harder, from the first badge | Tested (22), reviewed | `src/shared/DailyProgress.luau`, `src/server/Daily/` |
| Eighth independent exploit review (giant capture) | Done: no must-fix; four should-fix, all fixed | `docs/REVIEWS.md` |

1068 checks pass. **To try in Studio:** buy a Giant Horn and a Braided Lasso, walk to the lair past the stall on Route B, wake Hollowbough and win. A panel offers one throw: three loops. On a hit, "Hollowbough No. 1 is yours!" should appear and it should be on the creatures screen.

**Still to build on the logic side:** running the scripted-tapping audit over each player's lasso throws; the Dust Canyon and Tide Flats worlds (routes, tamers, giants, quests, story); purchases (approval pack still to write).

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
| Giant fights and the first giant, Hollowbough | Tested; tuned against the real species | `src/shared/GiantBattle.luau`, `src/content/giant_data/` |
| Lasso catching | Tested (51) | `src/shared/Lasso.luau` |
| XP, levels and level caps | Tested (43) | `src/shared/Xp.luau` |
| Saved data: shape, safe upgrades, checks | Tested (54). Nothing saves yet | `src/shared/Profile.luau` |
| Economy: every price and reward, with a 30-day simulation | Tested (38) | `src/shared/Economy.luau`, `docs/ECONOMY_MODEL.md` |
| Greenwood roster: eight species, 24 moves, balanced | Tested (28) | `src/content/species_data/`, `docs/content/GREENWOOD_ROSTER.md` |
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
