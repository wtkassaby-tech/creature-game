# Bug hunt: client screens (read-only)

Scope: src/client/UI/*, Creatures/*, Story/*, Shop/*, World/WorldView.luau, Audio/*. Read on 23 Nov 2026 while other sessions were editing ShopView, CreaturesView, StoryView, StarterPick and WorldView, so line numbers are from the files as they were then. No code was changed.

Overall: no exploit found on the client. Every screen sends intent only (StartBattle, SetTeam, RequestBreed, FinishEgg, PromptPurchase and so on), and the server checks each one; the handlers I sampled (SetTeam, ClaimDailyTask) rate-limit and validate. Connections are not leaking: ToyBody and Aura drop their records on `Destroying`, and per-frame loops are throttled. The real problems are broken states around battles, plus a few smaller races.

## 1. Medium: the Creatures and Journal screens stay open under a battle the client did not start, and hide the 3D arena
- Where: src/client/Creatures/CreaturesView.luau:60 (screen at order 6, never closed on BattleStarted or GiantStarted); src/client/World/FindsView.luau:401 (Journal at order 7, same). ShopView already handles this (ShopView.luau:382).
- Scenario: on PC the player opens Creatures (or the Journal) and keeps walking with WASD through long grass. The server's long-grass ambush (WorldService `onAmbush`, which knows nothing about client screens) starts a battle. The same happens if the player opens a screen during the "!" beat, because WorldView.luau:301 sends StartBattle after the delay without checking again. The Battle UI (order 10) draws over the Creatures panel, but the panel covers 96% of the screen, so the 3D BattleStage cannot be seen. Gaps in the battle UI also pass taps through to the Release, To team and Breed buttons underneath. Every card's ViewportFrame keeps animating through the fight.
- Fix: add `Bus.listen(Net.BattleStarted/GiantStarted, closeScreen)` in CreaturesView and FindsView, as ShopView does. In WorldView's `task.delay`, skip the request if `ProximityPromptService.Enabled` is false.

## 2. Medium: a story camera look that is still running when a battle opens fights the battle camera, then snaps it
- Where: src/client/Story/StoryView.luau:223-225 (battle opens, so `LookAt.release()`); src/client/Story/LookAt.luau:46-57 and 103 (eases back over LOOK_EASE_SECONDS = 1.2 s while still writing `camera.CFrame` every frame, then `unbind()` puts back the saved `home` CFrame and `CameraType`).
- Scenario: `giant_glimpse` (a Sight beat with `lookAt`, in clover_meadow) is completed by the server's `onAt`. WorldService calls `hooks.onAmbush` in the same tick, so BeatCompleted and BattleStarted arrive together, or an ambush lands while the three mentor lines are on screen. For about 1.2 s LookAt (render step Camera+1) and BattleStage's RenderStepped camera both write the camera, which ruins the intro shot. Then `unbind` sets the CFrame back to the old world shot and CameraType to Custom, and BattleStage's guard snaps everything back. Because looks come from data, a later Win or Tame beat with `lookAt` would be worse. `showNext` calls `LookAt.start` even while the battle is open, so `home` becomes the Scriptable battle camera. After the battle the look ends and puts back Scriptable at the battle position, and the camera stays frozen in the world.
- Fix: add `LookAt.cancel()`, which unbinds at once and does not touch the camera. Call it from `battleChanged` when the battle opens, and in `showNext` skip `LookAt.start` while `battleOpen`.

## 3. Low: dialogue typing ticks play under the battle result card
- Where: src/client/Story/StoryView.luau:213 (`typeOut` runs from `showNext` even when `battleOpen`), :180 (`Sfx.play("tick")`).
- Scenario: you beat Pip or the rival (Win beats). BeatCompleted arrives while the "You won!" card is up. The hidden dialogue box types its line with a tick every TICK_GAP over the result jingle. When the battle closes, the line appears already fully typed, with no typing effect.
- Fix: in `showNext`, when `battleOpen`, queue the line without calling `typeOut` (or leave it at the head of `queue`), and type it in `battleChanged` when the battle closes.

## 4. Low: the speaker face can be drawn twice and the extra copy is never removed
- Where: src/client/Story/SpeakerFace.luau:149-157 (`template()` has no "loading" guard, unlike ToyBody's `loadTemplate`, and the spawned task overwrites `standing` without destroying the copy before it).
- Scenario: the first time a person's model loads, the player taps quickly through lines that go A, B (or a line with no face), A. Two loads of A are in flight, and both finish while `showing == "A"`. Both clone into the ViewportFrame, `standing` points only at the second, and the first copy stays in the face window for the rest of the session, overlapping every later face.
- Fix: in the spawned task, destroy any existing `standing` before parenting the copy (or use a per-call token), and add a `loading[name]` wait like ToyBody's.

## 5. Low: the starter greeting can name the wrong creature
- Where: src/client/Story/StarterPick.luau:212-213 (`chosen()` returns the current selection, not the confirmed one); StoryView.luau:410 prefers it over the server's `state.Starter`.
- Scenario: the player confirms card A, then taps card B before the server answers (the cards stay tappable, and RESEND_AFTER only blocks a second confirm). The server grants A, but the line reads "B bounces over and leans against your leg."
- Fix: save the species in the confirm handler (`confirmed = selected`) and return that, or prefer `known.Starter` in StoryView.

## 6. Low: long-grass rustle sounds work only in the patches streamed in at the first scan
- Where: src/client/World/WorldView.luau:451 and 486-487 (`findPatches` runs again only while `#patches == 0`). StreamingEnabled is true (default.project.json:21, target radius 512).
- Scenario: the player joins in Thistledown, the first scan finds the Greenwood patches within streaming range, and the list is never refreshed. After travelling to Dust Canyon or Tide Flats, walking through their long grass makes no sound.
- Fix: scan again on a timer (for example every 10 s) or when the World gets new descendants (`DescendantAdded` filtered to `_tufts` folders), and remove duplicates by disc.

## 7. Low: ambience is not turned down for giant fights
- Where: src/client/Audio/Ambience.luau:73 (watches only "Battle"). Music.luau watches both "Battle" and "Giant".
- Scenario: a giant fight (the "Giant" screen) plays its music over the biome's ambience bed at full volume. Normal battles turn it down.
- Fix: watch "Giant" too and use `quietTarget = BATTLE_QUIET` while either screen is on.

## 8. Low (work in progress): two eggs with the same HatchAt share one clock label
- Where: src/client/Creatures/EggRows.luau:90 (`clocks[offer.hatchAt] = clockLabel`).
- Scenario: two eggs are granted in the same save with the same timer (for example `StoryProgress.claimEggs` handing over waiting eggs together). Both cards are built, but the map keeps only the second label, so the first card's clock stays blank. "Finish now" on either card sends the same HatchAt.
- Fix: key the clocks by card index, not by HatchAt.

## 9. Nit: a failed Robux price read is never tried again
- Where: src/client/Shop/Prices.luau:23 (`cache[id] = false` is never cleared when the read fails).
- Scenario: one `GetProductInfoAsync` call fails (throttled or offline for a moment). That pass or bundle shows "Buy" with no price for the whole session, even after the service recovers.
- Fix: on failure, set `cache[id] = nil` (with a retry time) so the next rebuild asks again.

## 10. Nit: "To team" does nothing when the team already has six
- Where: src/client/Creatures/CreaturesView.luau:253 (when `#ids > MAX_TEAM`, nothing is sent and nothing is said).
- Scenario: with six on the team, tapping "To team" on a stable creature does nothing at all. Below six, the server's notice explains the badge limit.
- Fix: add `else say("Your team is full: take one off first")`.

## Checked and fine
- No client value is trusted. Prices on screen are labelled as display only, and every grant is decided by the server.
- ToyBody and Aura records are removed on `Destroying`, including when an ancestor is destroyed. Portraits rebuilt in DetailPanel, FriendsStrip and CardSet do not leak.
- Every ScreenGui has `ResetOnSpawn = false` (Kit.screen), so a respawn never orphans the screens' references.
- Blink queues events that arrive before a listener. Every view registers `ClientState.onChanged` synchronously in Main, so the first PlayerState is not missed today. This depends on nothing in a view's `start()` yielding: `onChanged` does not replay the current state.
