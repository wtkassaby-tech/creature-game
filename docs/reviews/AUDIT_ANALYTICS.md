# Analytics funnel audit (read-only, 23 November 2026)

Scope: `src/server/Analytics/AnalyticsFeed.luau`, `src/shared/AnalyticsMap.luau`, `src/config/AnalyticsConfig.luau`, every `log(...)` call in `src/server`, and the funnel asks in `docs/MASTER_PLAN.md` and `docs/plans/07_FIRST_15_MINUTES.md`. No code was changed.

## How it works today
- `Main.server.luau` `log()` prints a JSON line and calls `AnalyticsFeed.record`. `AnalyticsMap.translate(event, fields)` returns Onboarding, Economy or Custom calls. `AnalyticsFeed` posts them (skips in Studio, budget 80 + 12 per player a minute, pcall-wrapped). It needs `fields.player` as a user id.
- Never yet run in a published game (the file header says so).

## Mapped today
| Log event | Report |
| --- | --- |
| DataLoaded (sessions == 1) | Onboarding step 1 "Joined for the first time" |
| StoryBeat (chapter 1) | Onboarding step index+1, named by the beat; `ChapterNDone` on the last beat of any chapter |
| Bought, StableExpanded | Coins Sink (Shop) |
| Breed | Coins, typed Candy, Prism Sinks (Gameplay) |
| BattleRewards | Coins Source |
| DailyClaimed | Coins, Prism Source (TimedReward) |
| Release | Coins Source |
| GiantWon | Prism Source; custom GiantFirstWin / GiantRematchWin |
| Capture | Candy Source; custom Capture |
| FindClaimed | Prism Source; custom FindClaimed |
| FindGathered, FindSighted, Hatch, QuestDone, WokeAtHealer, BiomeReached, BattleFinished (lost) | custom counts: FindGathered, FindSighted, Hatch, QuestDone, TeamFainted, BiomeNReached, BattleLost |

## Findings
### F1 (high). Gems are not tracked at all
`GemGrant` (PurchaseService ~279, Robux purchase), `GemSpend` (InventoryService ~172 consumables; PurchaseService ~429 egg finish) and `PurchaseGranted` are logged but `translate` ignores them, and `Currency` is `Coins | Candy | Prism`. The paid currency has no source or sink view and Robux revenue by product is invisible. Gate D and plan 16 need this.

### F2 (high). Coin and Prism sources from gifts are missing
Story beats, quests and the starting grant pay `{kind="Coins"}` and Prism through Gifts (story_data Chapter1 to 3, quest_data finals, `STARTING_COINS`). `StoryBeat.gifts` and `QuestDone.gifts` only log a count. Coin inflow is understated, so "coins in against out" (Master plan, read the numbers) would be wrong. Also unmapped: the mentor's gift egg, PendingClaimed, Crafted, BaitUsed.

### F3 (high). First-session funnel covers only story beats
Plan 07 asks for first friend, first battle and win, shop and first purchase, lasso throws and misses, first catch, first hatch, the Day one card, and where the player stopped. Story beats cover pick, rival, lasso lesson, Route A, local tamer, giant glimpse, mentor egg, third creature, first quest, gate and badge. Not covered: first battle win (only losses are counted), first purchase, lasso throw and miss counts (`LassoMissed` is logged but unmapped), first hatch inside 15 minutes, session end.

### F4 (medium). First session only
`DataLoaded` reports only when `sessions == 1`. No session length, no day-1 or day-7 return signal. The plan lists "median first session", which needs a session-end event.

### F5 (medium). Step numbers depend on beat order
`storyBeat` uses `index + 1`. Plan 07 WP6 moves `third_creature`; steps renumber automatically, so old and new runs compare wrongly on the dashboard. Keep beat names stable and add a content version to the run notes.

### F6 (medium). Failures and exploit signals are log-only
ReceiptFailed, ReceiptRefused, SerialAlarm, DataAlarm, DataLoadFailed, SearchFarAlarm, LassoSuspicious never reach analytics.

### F7 (low). Name budget
Roblox limits: 100 custom event names, 100 item names, 10 currencies. `Bought` passes `fields.item` through, so item names are open ended; cap and allow-list them.

### F8 (low). Balance timing
Economy events need the post-change balance; `balanceOf` reads the live profile, so every source log must fire after the mutation. Verify for Breed, Bought and BattleRewards (they appear to).

## Proposed events (exact names, where to fire)
Add `"Gems"` to `AnalyticsMap.Currency` and `AnalyticsMap.balance` (`profile.Gems`).

| # | Call | Fire from |
| --- | --- | --- |
| N1 | Economy Source Gems, name = `reason`, transaction Shop | `GemGrant` log (delta > 0), in `translate` |
| N2 | Economy Sink Gems, name = `item`, transaction Shop | `GemSpend` log (field `gems`), in `translate` |
| N3 | Custom `PurchaseGranted` (value = robux) | `PurchaseGranted` log, in `translate` |
| N4 | Economy Source Coins and Prism, name `Story` | `StoryBeat` log; add `coins` and `prism` totals to the log fields in StoryService ~99 |
| N5 | Economy Source Coins and Prism, name `Quest` | `QuestDone` log; add totals in QuestService ~152 |
| N6 | Custom `Crafted` | `Crafted` log |
| N7 | Custom `BaitUsed` | `BaitUsed` log |
| N8 | Custom `LassoThrow` | CaptureService, once per judged throw, beside the `Capture` and `LassoMissed` logs (new log `LassoThrow`) |
| N9 | Custom `LassoMissed` | existing `LassoMissed` log |
| N10 | Custom `BattleWon` | `BattleFinished` when `ending == "Won"` (no server change) |
| N11 | Onboarding steps named `First battle win`, `First purchase`, `First catch`, `First hatch`, `Day one card` (numbered after the last beat step) | `BattleFinished` Won, `Bought`, `Capture`, `Hatch`, Day one hook; only while `sessions == 1` and `playSeconds < 900` |
| N12 | Custom `SessionEnd` (value = minutes this session) | new log `SessionEnd {player, minutes}` from DataService on `PlayerRemoving`, before release |
| N13 | Custom `ReturnDay1`, `ReturnDay7` | `DataLoaded` when `sessions > 1`; needs a first-seen time in the profile (schema migration and test) |
| N14 | Custom `HealthAlarm` | DataAlarm, SerialAlarm, ReceiptFailed, ReceiptRefused, DataLoadFailed, SearchFarAlarm, LassoSuspicious; one name, rate capped |

## Custom event name budget
Existing about 25 (Capture, FindClaimed, FindGathered, FindSighted, Hatch, QuestDone, TeamFainted, BattleLost, GiantFirstWin, GiantRematchWin, Chapter1Done to Chapter4Done, Biome1Reached to Biome11Reached). Proposed adds: PurchaseGranted, Crafted, BaitUsed, LassoThrow, LassoMissed, BattleWon, SessionEnd, ReturnDay1, ReturnDay7, HealthAlarm. Total under 40 of 100.

## Tests to add (tests/analytics.test.luau)
Gem grant is a Source and a spend a Sink; BattleFinished Won yields BattleWon; StoryBeat with coins yields a Source; every Economy call has amount above zero; onboarding step numbers are unique and under 100; custom names are unique and under the cap.

## Verdict
Covered: chapter 1 beats as funnel steps, coin shop and breed sinks, battle, daily, release and giant sources, candy from capture. Missing: Gems (source and sink), gift-based coin and Prism sources, first win, first purchase, lasso counts, hatch, session end and returns, health alarms. Changes to saving (N13 profile field) need Ayrton's approval under the CLAUDE.md workflow.
