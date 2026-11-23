# Bug hunt: world, story, quests, finds (read-only)

Date: 23 November 2026. Scope: src/server/World/*, src/shared/World.luau, src/shared/Encounters.luau,
src/shared/StoryTriggers.luau, src/server/Story/StoryService.luau, src/server/Quests/QuestService.luau,
src/shared/QuestProgress.luau, src/server/Finds/FindService.luau, and the wiring in src/server/Main.server.luau
and src/server/Battle/BattleFlow.luau. No files were edited. Ranked by severity.

## 1. MEDIUM: a "tame a creature" beat completes with a catch from any biome
- Where: src/shared/StoryTriggers.luau:102 (`met = trigger.kind == "Tame"` for a `Tame` event), against the biome rule in `creditTame` (src/shared/StoryTriggers.luau:50).
- Scenario: Chapter 2's next beat is "A catch in the canyon" (Chapter2.luau:87, requires `canyon_trader`). The player goes back to Greenwood and lassoes a creature there. BattleFlow.luau:261 fires `{ kind = "Tame", biome = 1 }`. `creditTame` correctly refuses (biome 1 is not chapter 2), but `StoryTriggers.ready` then accepts the same event because it only checks the trigger kind, so the canyon beat finishes and pays its gifts. Same for Chapter 3 and 4 catches. The rule the comment promises ("a creature caught on the way back through the old biome does not count") only works for early catches.
- Fix: in `ready`, for a `Tame` event require `event.biome == chapterOfBeat[beat.id].number` (or simply `met = profile.Story.flags[TAMED_PREFIX .. beat.id] == true`, since `creditTame` runs first).

## 2. MEDIUM: held stretches are filled and emptied every second (CPU and network churn in the first session)
- Where: src/server/World/WorldService.luau:396-436 with src/shared/Encounters.luau:180-201.
- Scenario: wild battles are open but `route_b` is not (between the lasso lesson and `first_quest`). The Greenwood hold covers all of River Road (map_data/Greenwood.luau:104-111). Any player within ACTIVE_RANGE (260 studs) of a River Road area centre, which includes the hub side of the arch and the end of Route A, gets on every tick: `Encounters.tick` builds up to 3 creatures per held area (Breeding.wild plus a GUID each, up to the 24 cap), then the hold loop deletes them all with `Encounters.remove`, which does not set `freeAt`, so `changed` is true and a `WildSpawns` message is sent every second. Next tick repeats. The cap can also be eaten by held spawns before later open areas fill, depending on route order.
- Fix: pass a "held point" predicate into `Encounters.tick` and skip areas whose centre (or patches) lie in a closed hold, instead of creating then deleting them.

## 3. MEDIUM: holds are enforced only by the 1 s tick, so a battle can be started inside a closed stretch
- Where: src/server/World/WorldService.luau:385 (`sendBack` runs only when `isReady`), src/server/Battle/BattleFlow.luau:98-112 (tamer path checks `mayEnter` and distance, never the hold), src/server/World/WorldService.luau:132-141 (position is the character's replicated root part).
- Scenario: the character's HumanoidRootPart is physics-owned by the client, so an exploiting client can move it anywhere and the server reads that as "the server's own reading". Before `route_b` opens, the client snaps next to `gw_odette` (River Road, about 100 studs inside the hold) and sends StartBattle for her in the same second. `Trainers.resolve` does not gate local tamers by story, `resolveTarget` has no hold check, and once the battle is open `isReady` is false so `sendBack` never fires. The player fights and is paid for a tamer the story has closed. The same teleport defeats every distance check outside FindService (rustle spots across the map, Waystation travel, story `Enter`/`Sight` beats); only FindService has a jump/trail check.
- Fix: add `WorldService.isHeld(player)` (holdAt at the current position) and refuse in `resolveTarget` (all kinds) and in Rustle/UseBait/Travel when held; longer term reuse FindTrail's jump detection for engage/rustle/travel.

## 4. LOW: a server move yields after the readiness check, so a battle can start mid-teleport
- Where: src/server/World/WorldService.luau:559-572 (Travel checks `isReady`, then `sendTo` -> `moveTo` yields in `RequestStreamAroundAsync` up to 2 s, line 199) and the same pattern in `sendBack` (line 216).
- Scenario: player presses Travel at a Waystation and, within the 2 s stream wait, sends StartBattle against a wild creature beside them (Blink SingleAsync handlers run concurrently). The battle opens, then `PivotTo` moves the character to another biome mid-battle; the wild creature's book entry and the battle scene are now in the wrong biome, and `onMoved`/`lastAt` reset happen during a battle.
- Fix: after the stream wait in `moveTo`, re-check `hooks.isReady(player)` (or mark the player as travelling so StartBattle refuses) before pivoting.

## 5. LOW: ambush ignores the biome-reached team rule and refuses with a wrong message
- Where: src/server/Main.server.luau:130-146 (`canBeAmbushed` only checks "not fainted"), src/server/Battle/BattleFlow.luau:64-75 (`BattleFlow.team` also filters by `Team.mayBattle`).
- Scenario: the team's only standing creatures have `originBiome > biomeReached` (a creature that reached the team without the team screen, which BattleFlow's own comment says can happen). Walking in long grass triggers an ambush, `playerTeam` returns nil, and `open` drops it with "Your data is not loaded" every GRASS_REST_SECONDS (8 s) while walking in grass.
- Fix: in `canBeAmbushed`, count only creatures with `not Health.isFainted(c) and Team.mayBattle(profile, c)`.

## 6. LOW: FindService keeps a CharacterAdded connection per join forever
- Where: src/server/Finds/FindService.luau:320-332.
- Scenario: every PlayerAdded appends a connection (and a closure holding the Player) to `respawns`; PlayerRemoving never removes it. A long-running server accumulates one entry per join and keeps departed Player objects referenced.
- Fix: store connections by player (`respawns[player] = conn`) and disconnect and clear in the PlayerRemoving handler.

## Checked and fine
- Rustle/UseBait/Search/Accept/HandIn/CompleteBeat/Travel each rate-limit before reading; Blink types bound the ids.
- Bait is spent only after a creature appears, with no yield between the check and the spend; sightings are counted in the same step the creature steps out.
- A wild battle that cannot start is handed back (`onDropped`: ambush removed, others calmed); `WorldService.finish`/`spawn` guard a departed player's missing book.
- Quest hand-in sets `done` and pays in one step; giver building names are unique across biomes.
- Rest timers survive a same-server rejoin (`timers` by UserId); PlayerRemoving clears all per-player tables in WorldService, StoryService and QuestService.
