# Bug hunt: catching (read-only, 23 November 2026)

Scope: `src/shared/Lasso.luau`, `Capture.luau`, `Grants.luau`, `GiantCapture.luau`, `src/server/Capture/*`, the capture parts of `GiantService`, `BattleService`, `BattleFlow`, `InventoryService` and `SerialGrants`, and on the client `LassoPlayer`, `LassoView`, `CatchSequence`, plus the lasso handlers in `BattleView` and `GiantView`. No source file was edited.

Checked and sound: the server never trusts a client value except tap timing, and only inside the lag window. NaN, infinite, missing, extra and out-of-order taps are Invalid and count as a miss. A throw is judged once. The lasso is taken before the sweep is sent. The roll uses the server's own seed. Every battle action and battle item is blocked while a throw is in the air. Flee counts carry over between battles and survive Run. The full stable is checked at throw time and again at the grant. Gem catches hold a stable place while they wait. Giant captures go through the waiting list once. Disconnecting mid-throw leaves the lasso spent and grants nothing. Captures are logged with creature ids.

## Findings, most severe first

### 1. High: a tap before a loop starts sweeping ruins the whole throw, including the one giant attempt
- Where: `src/client/Lasso/LassoView.luau:109-125` (`tap()` has no "is it sweeping yet" guard), `src/client/Lasso/LassoPlayer.luau:72-80`, `src/server/Capture/CaptureService.luau:339-341` and `353-357` (the tap is stored whatever its time), `src/shared/Lasso.luau:257` (`claimed < zone.startMs` makes the throw Invalid).
- Failure: a Gem, Ruby, Diamond or Cosmic creature, or any giant, has 2 or 3 loops, each starting `ZONE_GAP_MS` (3000 ms) after the one before. The player taps loop 1 at about 600 ms, and a double tap or nervous second tap follows at about 700 ms. LassoView has already moved to loop 2: its green stretch is drawn but its loop is hidden (`loop.Visible = sweeping`, line 151). The button still fires `tap()`, which sends `Zone = 2, ClaimMs ≈ 700`. The server takes it as the zone 2 tap, and `Lasso.judge` returns Invalid ("outside the attempt"). The lasso is spent, the miss counts toward fleeing, and for a giant the one numbered capture attempt is gone. The client even shows a white "good" stamp if the still marker happens to sit in the green.
- Fix: in `LassoView` `tap()`, ignore the tap while `LassoPlayer.elapsedMs(current) < zone.startMs`. Also, in the `LassoTap` handler (both the wild and the external path), drop a tap whose `ClaimMs` is earlier than that zone's `startMs` instead of storing it. A tap before the sweep moves carries no information, so dropping it opens no retry.

### 2. Medium: honest taps on a 200 ms+ connection are judged Invalid early in the first wild battle
- Where: `src/server/Capture/RoundTrip.luau:67` and `src/server/Capture/CaptureService.luau:367-370` (pings go out only during a wild battle or a giant fight, one every 2 s), `src/shared/Lasso.luau:225-227` with `src/config/LassoConfig.luau:82` (`ROUND_TRIP_DEFAULT_MS = 120` until 3 readings exist).
- Failure: a phone with a real 300 ms round trip joins and meets its first wild creature (often the tutorial first catch). Three readings take about 4 to 6 s to arrive. A throw before that is built with `roundTripMs = 120`, so the judge's early allowance is 120 + 120 = 240 ms. Each honest tap reaches the server about 300 ms after its claim, so `claimed < serverNow - allowance` and the throw is Invalid. The lasso is spent, a miss is counted, and the player sees a plain miss.
- Fix: with fewer than `ROUND_TRIP_MIN_SAMPLES` readings, return `ROUND_TRIP_CAP_MS` (400, the generous allowance, no slowing) instead of 120. Or ping every player at a slow rate outside battles too, so readings exist before the first throw.

### 3. Low: a tap after 14 s silently ruins the throw, and the screen gives no warning
- Where: `src/shared/Lasso.luau:257` (`claimed > MAX_ATTEMPT_MS`, 14000), `src/client/Lasso/LassoView.luau:135-159` (the sweep runs with no deadline shown), `src/server/Capture/CaptureService.luau:33` (judged at about 15.4 s).
- Failure: a player waits for a "good pass" on a slow, narrow zone, or is slow on a 3-loop sweep (loop 3 starts at 6 s). Any tap after 14.0 s makes the whole throw Invalid: lasso spent, miss counted. Until the server times out at 15.4 s the loop keeps sweeping as if a tap still counted.
- Fix: show a countdown in LassoView and stop accepting taps (hide the button) at `MAX_ATTEMPT_MS`.

### 4. Low (CLAUDE.md hard rule 5): `LassoTap` and `Pong` have no rate limit
- Where: `src/server/Capture/CaptureService.luau:336` (`Net.LassoTap.On`), `src/server/Capture/RoundTrip.luau:49` (`Net.Pong.On`).
- Failure: a client can flood either message without limit. Each call is cheap and changes nothing it should not, but rule 5 says every handler is rate-limited, and `ThrowLasso` already is.
- Fix: add a per-player minimum gap or a token bucket (for example 20 taps a second) at the top of both handlers.

### 5. Low: some server paths end a throw without sending a result, leaving the client stuck on "Thrown..."
- Where: `src/server/Capture/CaptureService.luau:209-210` and `223-226` (return with no `LassoResult` or `BattleTurn`), and `src/server/Giants/GiantService.luau:405-408` (`playThrow` returned false: the lasso and the attempt are used up and nothing is sent).
- Failure: none of these can be reached through today's flows, because the busy check and the active check prevent them. But if one ever is (a new way to end a battle, or a refactor), BattleView stays in lasso mode with `waiting = true` until the next `BattleStarted`, and GiantView shows nothing. The giant path also spends the lasso for nothing.
- Fix: send a `BattleRefused` (or a Missed `LassoResult`) on each early return. In GiantService, refund the lasso and restore the offer when `playThrow` returns false.

## Already recorded in docs/REVIEWS.md (not new; still open)
- Holding back `Pong` replies raises the trusted round trip, which turns on the connection assist (the marker slows to 0.4x at most). The "smallest reading" rule only stops a reading being lowered. Logged as Low; still exploitable.
- With a round trip over 400 ms the judge caps the allowance at 520 ms, so the connection assist slows the sweep for exactly the players whose taps it will then reject as Invalid. Listed as open for Ayrton.
