# Bug hunt: saving (read-only)

Scope: src/shared/Profile.luau, src/server/Data/DataService.luau, ProfileStore 1.0.3 use (checked against ServerPackages/_Index/lm-loleris_profilestore@1.0.3), src/shared/Snapshot.luau, src/server/State/StateSync.luau. No files edited. Ranked most severe first. I checked these and found nothing wrong: migrations running on a copy, refusing a newer-version save, the order of session end, kick and `get`, the leave-during-load race (line 153 plus Cancel), and ProfileStore's LastSavedData being a copy.

## 1. HIGH: one error in StateSync stops state updates for every player on the server
- Where: src/server/State/StateSync.luau:26-35
- What goes wrong: the send loop is one `task.spawn` `while` loop with no `pcall`. If `Snapshot.build` throws, or Blink's `WritePlayerState` throws, the thread dies. Nothing restarts it, so no player on that server receives PlayerState again. Coins, creatures, team, eggs and purchases all look frozen until the server closes. Saving keeps working, so players think progress and purchases were lost. The hatch loop in Main.server.luau:345-347 is wrapped in `pcall` for exactly this reason ("One player's damaged save must never stop hatching for everyone else"). This loop is not.
- Example: one loaded creature has a rarity outside the Blink enum. `Profile.validate` only logs an unknown rarity (Profile.luau:345-350) and never checks `bodyPlan`, so the save loads. The Blink writer then raises "Unexpected enum" (generated/Server.luau, WriteEVENT_PlayerState). A nil candy balance (`writef32(nil)`) does the same, as does any error inside `DailyProgress.view` or `PassEffects.*`.
- Fix: wrap each player's build and `Fire` in `pcall` and log failures (for example `StateSyncFailed`), so one bad record only affects that player.

## 2. MEDIUM: an error in `load()` after the session starts leaks the session lock and leaves the player with no data
- Where: src/server/Data/DataService.luau:99-167, in particular 121-122 and 157-161
- What goes wrong: nothing between `StartSessionAsync` returning and `sessions[player] = session` is protected. If any line throws, the thread dies. The session stays active and on ProfileStore's auto-save list, but it is never put into `sessions`. Then:
  - the player is never kicked and plays with no data (every service answers "not loaded");
  - on leave, `PlayerRemoving` finds `sessions[player] == nil` and never calls `EndSession`;
  - the lock stays held by this server until another server's force-load message ends it (about 5-40 s of rejoin delay) or this server shuts down.
- Example: `PlayStats` is saved as a non-table, or `PlayStats.sessions` as a non-number. `Reconcile` keeps any existing value that is not a table (ReconcileTable only fills nil keys), and `Profile.validate` never checks `PlayStats`, so `session.Data.PlayStats.sessions += 1` (line 160) throws. A non-table `Data` sub-record that `Reconcile` steps into would throw the same way.
- Fix: run the part after `StartSessionAsync` inside `pcall`. On failure, `session.Data = original`, `session:EndSession()`, log `DataLoadFailed` and kick. Also add `PlayStats` checks to `validate` (fields must be whole numbers).

## 3. MEDIUM: `saveSoon` has no coalescing, so a client can queue unlimited data store writes
- Where: src/server/Data/DataService.luau:58-63 (callers: InventoryService.luau:171, FindService.luau:216, PurchaseService.luau:191/428, SerialGrants.luau:81/157)
- What goes wrong: each call does `session:Save()`, which starts a new `UpdateAsync` every time. ProfileStore runs them one at a time per key in an unbounded FIFO (`WaitInUpdateQueue`, ProfileStore.luau:353-377). Roblox allows one write per key every 6 s. Gem buys are allowed every `GEM_BUY_COOLDOWN = 0.25` s (PurchaseConfig.luau:171), and each successful buy calls `hooks.save`.
- Example: a player with a few hundred Gems spams the cheapest Gem item at 4 per second. That queues roughly 240 saves a minute against a drain of about 10 a minute. Three things follow:
  - the end-of-session save on leave waits behind the whole backlog, so the lock is not released and the next server has to force-steal;
  - `waitSaved` for a real Robux receipt waits behind it too;
  - the server-wide UpdateAsync budget is used up, slowing every other player's saves and loads.
- Fix: coalesce in `DataService.saveSoon`. Keep `pending` and `lastSave` per player; save at once if the last save was 6 s or more ago, otherwise schedule one trailing save with `task.delay`.

## 4. LOW: `waitSaved` can stall a receipt for about 5 minutes after one failed save
- Where: src/server/Data/DataService.luau:79-81
- What goes wrong: `OnAfterSave` only fires when a save succeeds (ProfileStore.luau:924). A normal (not ending) save that fails is not retried (`repeat_save_flag = false`). `Save()` also moves the profile to the back of the auto-save list (ProfileStore.luau:1183-1184). So after one failed `UpdateAsync`, `OnAfterSave:Wait()` blocks until the next auto-save (`AUTO_SAVE_PERIOD = 300` s) or the session ends. The `SAVE_RETRY_SECONDS` retry never runs.
- Example: a brief data store error during a Gem purchase. The handler stays blocked about 300 s and the player sees no "Your purchase arrived" message. No grant is duplicated or lost: Roblox retries and the receipt id dedups.
- Fix: wait for whichever comes first, `OnAfterSave` or `task.wait(SAVE_RETRY_SECONDS)` (for example `task.delay` resuming the waiting thread, with a flag so it resumes only once).

## 5. LOW: one malformed creature makes the whole save "unreadable" and locks the player out on every join
- Where: src/shared/Profile.luau:329-413 (`creature.id`, `creature.parts[slot]` at 396) and 506 (`creature.parts.Torso.species`)
- What goes wrong: `checkCreature` assumes `creature` and `creature.parts` are tables. If either is not, `validateUnsafe` throws. `Profile.validate` turns that into `unreadable save: ...`, and DataService.luau:128-138 refuses the load and kicks the player, on every join, forever. The same file promises that problems are logged as an alarm and nothing is deleted for them. A missing single part, by contrast, is only an alarm (line 397). The same applies to eggs (497) and gem-pending creatures (528).
- Example: a bug elsewhere stores `Creatures[id] = true`, or a creature without `parts`. The player can never load again until the data is fixed by hand.
- Fix: at the top of `checkCreature`, add `if typeof(creature) ~= "table" or typeof(creature.parts) ~= "table" then table.insert(problems, ...) return end`, and guard line 506 the same way.

## 6. NIT: the comment on `DataService.start` says it returns a stop function, but the function returns nothing
- Where: src/server/Data/DataService.luau:169-171
- What goes wrong: "Returns a function that stops listening" is not true, so a caller that calls the result gets "attempt to call nil". The `PlayerAdded`/`PlayerRemoving` connections are never cleaned up (CLAUDE.md asks for a Janitor/Trove-style cleaner).
- Fix: keep both connections and return `function() added:Disconnect(); removing:Disconnect() end`, or correct the comment.
