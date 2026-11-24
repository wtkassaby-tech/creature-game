# First run in Roblox Studio

For: Ayrton, and the Claude Code session on the laptop. Written 21 November 2026.

Everything in this project has been built and tested in a cloud session that cannot reach Roblox Studio. The rules (battles, catching, breeding, the economy, the story) are tested as pure code. Everything that touches Roblox itself (the map, prompts, screens, saving, messages between device and server) has only been type-checked. **Expect the first run to find problems.** This page is the order to find them in.

## 1. Before pressing Play

1. In the project folder: `rokit install`, then `wally install`, then `lune run check`. All three must finish without errors. If `lune run check` fails on the laptop but the notes say it passed, the difference is the toolchain: read the failure before changing code.
2. Start Rojo (`rojo serve`), open a new baseplate in Studio, connect the Rojo plugin.
3. In the Explorer, check the tree: `ReplicatedStorage` has `shared`, `config`, `content`, `net` (with a `generated` folder inside) and `Packages`; `ServerScriptService` has `server` and `ServerPackages`; `StarterPlayer.StarterPlayerScripts` has `client`.
4. Delete the default Baseplate and SpawnLocation: the game builds its own map.

## 2. The first Play: what should happen, in order

Watch the Output window. Every server event prints one line starting with its name in square brackets.

| Step | What you do | What you should see |
| --- | --- | --- |
| 1 | Press Play | A grey-box world appears: a tan square with seven buildings, a path west and a path east. You spawn in the square. Output: `[DataLoaded]` |
| 2 | Wait a moment | A "Pick a friend" panel with three creatures. A grey test panel on the left |
| 3 | Pick one | The panel closes. A dialogue box plays the mentor's lines; press Next. Top-left tracker says what is next. Output: `[StoryBeat]` twice (the pick, then the rival's challenge two seconds later) |
| 4 | Walk to the person labelled "Rival (rival_first)" near the square's middle and use the prompt | The battle screen opens: two health bars, your moves with their damage. Win it |
| 5 | After the win | "You won!", coins and XP. The story moves on by itself (the lasso lesson): you receive 5 lassos, 3 tonics, coins and a second creature |
| 6 | Walk west along the path | Coloured balls with name tags ("Lv 2 Mossmitt") stand beside the path. Output: nothing yet |
| 7 | Walk up to one, use its prompt | A wild battle. Press Lasso, pick the Rope Lasso, tap THROW when the white marker is inside the green zone |
| 8 | A good throw | "Caught!". The creature is on the Creatures screen (button top-right). Output: `[Capture]` |
| 9 | Walk through a dark patch labelled "Long grass" | A battle starts by itself within a few seconds of walking |
| 10 | Get hurt, open Creatures | The hurt creature shows less than 100% health and a Tonic button |
| 11 | Talk to the keeper of Brightwater House (the healer) | "Your creatures are rested and well" |
| 12 | Lose a battle with your whole team | You wake at the healer, team healed |

If any step fails, stop there and fix it before going on: later steps depend on earlier ones.

## 3. Things most likely to be wrong

These were written without being able to run them. Check each on purpose.

| Area | What to check | Where |
| --- | --- | --- |
| Messages | The generated Blink modules load on both sides; no "attempt to index nil" on `Net.Something` | `src/net/generated/` (made by `blink`, not saved in git) |
| Saving | In Studio the save is an in-memory mock (nothing is written). Stop and Play again: you start fresh. That is intended until `ProfileConfig.STUDIO_USES_REAL_STORE` is set | `src/server/Data/DataService.luau` |
| The map | Parts overlap or float; labels unreadable; the second biome (Dust Canyon) is about 1,000 studs east of the first gate | `src/server/World/TestMap.luau` |
| Prompts | Each prompt shows and fires; rustle spots have two (E to search, F for bait) and they should not overlap | `TestMap.luau`, `src/client/World/WorldView.luau` |
| Screens | Text too small or cut off; panels overlapping on a phone-sized window (use the device emulator); buttons that do nothing | `src/client/` |
| Position checks | A request refused with "You are too far away" while standing at the thing: the radius or the place's position is off | `src/config/WorldConfig.luau`, `src/shared/Layout.luau` |
| The lasso | The marker's speed and the zone feel right; taps register; a clean hit is judged a hit (if clean hits are judged "Invalid", the server's timing window is the suspect) | `src/shared/Lasso.luau`, `src/server/Capture/` |
| Teleports | Waking at the healer and Waystation travel put you on the ground, not inside it | `WorldService.sendTo` |

## 4. A longer run, once the first one works

Play chapter 1 to the badge (about 50 minutes at the story's pace): the tracker tells you each next step. Then:

- The shop (Tuppence's Shop): buy lassos and a Giant Horn; make a tonic from Fernfluff.
- Breeding (after the mentor's egg): open Creatures, press Breed on two creatures of the same body plan, check the cost and odds, confirm. The mentor's egg hatches in 3 minutes; your own take 30 or more.
- The giant: walk the spur off Route B past the stall, use the horn at the giant, win, and take the capture throw (needs a Braided Lasso).
- Daily tasks appear at the top of the Creatures screen after the first badge.
- Dust Canyon: walk east past the Greenwood gate along the grey road. Its creatures should appear only once you hold the Acorn Badge.
- Tide Flats: the same again past the Dust Canyon gate, once you hold the Cairn Badge. Tide Bait (made from Brine Shells) works at its rustle spots.
- The off-switches: in the Output window's command bar, run `game:GetService("ConfigService"):SetTestingValue("shop_open", false)` on the server, then try to buy something. It should say the shop is closed for a moment. Set it back to `true` afterwards. The same works for `breeding_open`, `giants_open`, `daily_rewards_open` and `release_open`. For the real game, create these five keys as booleans on the Creator Hub's Configs page (all `true`); until they exist the game simply stays open.
- Analytics send nothing in Studio (Roblox only takes them from a published game). After the first published playtest, the Creator Hub's Funnel page should show "Joined for the first time" and then each beat of chapter 1.

## 5. What to send back

For each problem: the step number, what you saw, and the red lines from the Output window. A screenshot of any screen that looks wrong. The Claude Code session on the laptop can read the Output and take screenshots itself through the Studio MCP; ask it to "work through docs/STUDIO_FIRST_RUN.md and fix what breaks".
