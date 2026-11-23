# Bug hunt: battle engine and battle service

Read-only review, 23 November 2026. Scope: `src/shared/Battle.luau`, `BattleSession.luau`, `BattleAi.luau`, `TypeChart.luau`, `src/server/Battle/BattleService.luau`, `BattleFlow.luau`, `src/client/BattleView/BattleView.luau`, `BattleStage.luau`. The handlers next to them were followed where the battle calls into them: `InventoryService.UseItem`, `CaptureService` resolve, `Capture.finish`, `WorldService.engage/finish` and `Trainers.build`. No files were edited.

Overall the server side holds up. Every client message is checked against the session's own state: the turn number, an integer index, the move list and switch targets. Actions, starts, items and throws are each rate-limited. A turn can be applied only once. Health is written back after every turn, so leaving mid-battle cannot undo damage. Locked creatures cannot be traded, bred, released, moved off the team or treated outside the battle. Nothing is staked on a match. I found no duplication, client-trust or money exploit. The real bugs are below, most severe first.

---

## 1. Medium: after "holds on", the player's creature disappears for the rest of the battle

- **Where:** `src/client/BattleView/BattleView.luau:795-804` (Faint) and `:825-831` (Endure), with `src/client/BattleView/BattleStage.luau:675-681` and `src/client/Creatures/ToyBody.luau:533-543`.
- **What happens:** In a battle that cannot be lost (the first rival battle), `Battle.step` first logs `Faint` for the player's last creature (`Battle.luau:368-384`). Then `BattleSession.holdOn` adds `Endure` and sets its health to 1 (`BattleSession.luau:243-256`). On the device, `Faint` calls `stage.faint`, which runs `toy.act(..., keep = true)`. That sets `toy.ending = true` for good, and the toy sinks and fades. `Endure` only sets `hp = 1`. `refresh()` puts a new model on the pad only when `staged[pad] ~= current.active[pad]`, and both still name the same slot, so the faded toy is never replaced. Every later `lunge` and `hit` returns early because `toy.ending` is set.
- **Failure scenario:** A new player is knocked down in the first rival battle. The screen says "X holds on!", but their creature is gone from the pad. It stays invisible and does not move for the rest of the battle, while the HP bar and the buttons go on working.
- **Fix:** In the `Endure` branch, set `staged[actor] = 0` before `refresh()`. `refresh()` will then call `stage.swap`, which destroys the faded toy and puts in a fresh one.

## 2. Low-medium: running away, or the creature fleeing, shows "DEFEATED" and plays the losing jingle

- **Where:** `src/shared/BattleSession.luau:275-276` (outcome 2 when `ran`), `src/shared/Capture.luau:265` (Fled sets outcome 2), `src/net/Net.blink` BattleTurn (it carries no `Ran` field), `src/client/BattleView/BattleView.luau:84` and `:486-488`.
- **What happens:** `TurnResult.ran` exists on the server but is never sent. The device maps `Outcome = 2` to `"Lost"`.
- **Failure scenario:** The player taps RUN against a wild creature, or a creature breaks free and flees after missed throws. The result card says "DEFEATED" and plays the losing sound, although nothing was lost. Right after a flee, the lasso line has just said "It broke free and fled!".
- **Fix:** Add `Ran: boolean` to `BattleTurn`, fill it from `turn.ran` in `BattleService.publishTurn`, and show a neutral "Got away" / "It fled" `ResultPanel` kind when it is set.

## 3. Low: a creature that comes back in after a faint keeps its old tempo meter

- **Where:** `src/shared/Battle.luau:386-396` (the forced replacement) compared with `:313-318` (only a chosen `Switch` resets tempo).
- **What happens:** The rule says "Switching in resets the meter". A chosen switch resets the creature coming in. A replacement after a faint does not, and the creature switched out also keeps its meter.
- **Failure scenario:** The player's fast creature A builds tempo to 0.9. The player switches to B, and B faints. A comes back in automatically with 0.9 tempo, gets a follow-up strike almost at once, and the tempo bar opens nearly full. This applies to the game's side too: a tamer's benched creature can come back with a charged meter.
- **Fix:** Set `state.sides[side].team[nextIndex].tempo = 0` when the replacement is assigned. Also reset the outgoing creature's tempo on a `Switch`.

## 4. Low: an empty battle team is reported as "Your data is not loaded"

- **Where:** `src/server/Battle/BattleFlow.luau:73-75` returns `nil, nil` when no team creature passes `Team.mayBattle`. `src/server/Battle/BattleService.luau:199-202` turns that into "Your data is not loaded".
- **Failure scenario:** Data is loaded, but every creature on the team is held back by the "biome reached" rule, or the team is empty. The player taps a tamer or a wild creature and is told their data is not loaded, which is wrong and gives no next step. A wild target is also handed back through `onDropped`.
- **Fix:** Have `PlayerTeam` return a reason as well, for example `nil, nil, "None of your team can battle here"`, and pass it to `drop`.

## 5. Low (CLAUDE.md rule 9): the type chart and its multipliers are hard-coded in `src/shared`

- **Where:** `src/shared/TypeChart.luau:17-32`. `STRONG_MULTIPLIER = 1.5`, `WEAK_MULTIPLIER = 0.67`, `OWN_TYPE_MULTIPLIER = 1.2` and the strong-against table all live in pure-logic code. Smaller cases of the same thing: `MIN_SECONDS_BETWEEN_ACTIONS` and `MIN_SECONDS_BETWEEN_STARTS` (`BattleService.luau:46-47`) and the team limit `6` (`BattleSession.luau:158,161`).
- **Why it matters:** Rule 9 says "every balance number lives in `src/config/`" and that types are data. Tuning the chart now means editing `src/shared`.
- **Fix:** Move the three multipliers into `BattleConfig` and the `STRONG` table into `src/content` (or `src/config`). `TypeChart` keeps only `isStrong` and `multiplier`.

---

## Checked and found sound (no finding)

- **Client trust:** `BattleSession.act`, `pass` and `useItem` each check the turn number (stale or repeated messages are refused), integer indices, NaN and infinity, the move list, switch targets (standing and not the active one) and item rules. `Battle.validate` replaces any invalid action instead of trusting it. Items are paid for in `Shop.useInBattle` only after `useItem` succeeds.
- **Rate limits:** StartBattle 0.5 s, BattleAction 0.25 s, UseItem 0.25 s, ThrowLasso 0.5 s. No action can slip in while a throw is being played (`busy`).
- **Disconnect and rejoin:** `PlayerRemoving` clears the session, refs and limiters in BattleService, the capture state and the world book. Health is carried out after every turn, so leaving keeps the damage and frees nothing. A pending lasso resolve checks that the session is still current.
- **Fainted team:** `BattleSession.start` refuses with "Your creatures need healing first". Ambushes are not offered unless someone on the team is standing. A loss, or a win where both last creatures fell, wakes the player at the healer, counting only the creatures that fought.
- **Locks:** release, team changes, breeding, trades and treatment outside battle all check `isLocked`, which covers creatures in a battle and in a giant fight. A battle cannot start during a giant fight, and a giant fight cannot start during a battle.
- **Opponent data:** `Trainers.build` makes fresh creatures for every battle, so `carryOut` never writes into shared tamer data.
- **Wire limits:** the most events a turn can produce (about 17) is under `MAX_EVENTS_A_TURN = 24`, and the longest move name fits `string(1..24)`.
- **TypeChart:** every type is strong against exactly two types and weak against exactly two. No pair is strong both ways.
