# Bug hunt: networking and client-message handlers

Read-only review, 23 November 2026. Scope: `src/net/Net.blink` and every server handler for a client message. That covers Battle, Capture/RoundTrip, Giants, Inventory, World (Rustle, UseBait, Travel), Finds, Quests, Story, Daily, Purchases (PromptPurchase, FinishEgg) and RequestBreed in `Main.server.luau`. Findings are ranked by severity. Each one was traced through the code. Things that were checked and found sound are listed at the end.

## 1. HIGH: A client can fake lag by delaying Pong, which slows the lasso marker to 0.4x and widens the claim window

- **Where:** `src/server/Capture/RoundTrip.luau:49-56` (Pong handler); `src/shared/Lasso.luau:96-102` (`assistScale`), `:216-229` (`trustedRoundTripMs`), `:248-249` (allowance); used by `CaptureService.luau:311` (wild) and `GiantService.luau:350` (giant capture).
- **Problem:** The server assumes a reply "can be made worse but never better". But a worse reading helps the player. When the round trip is above `ROUND_TRIP_CAP_MS` (400), `assistScale` slows the marker to as little as `ASSIST_MIN_SPEED` (0.4). Slow mode is only 0.7. The early-claim allowance also rises to the 400 + 120 ms maximum.
- **Failure scenario:** An exploit script hooks the Ping handler and waits about 1 s before it fires `Pong`. All 8 kept readings come out near 1000 ms, so `trustedMs` is 1000. Every wild throw, and the one-off numbered giant capture, then plays at 0.4x speed with the widest claim window. Catch rates for Ruby, Diamond and giant captures rise sharply, and the only check is the timing audit, which just logs.
- **Fix:** Cap the reading with the engine's own measurement, for example `math.min(smallestReading, player:GetNetworkPing() * 1000 + margin)`. A client cannot raise that value without really lagging its taps too.

## 2. MEDIUM: The hatch loop can take the last stable slot while a wild throw is in the air, so a hit becomes a miss

- **Where:** `src/server/Main.server.luau:346-358` (5 s loop: `collectHatched` and `claimWaiting`); `src/server/Breeding/BreedingService.luau:202-211`; `src/shared/Capture.luau:229-243` (a refused grant counts as a miss).
- **Problem:** `Capture.begin` checks `Grants.room >= 1` when the lasso is thrown. The throw is judged up to about 15 s later (`TIME_LIMIT_SECONDS`). The hatch and claim loop keeps running during that time and does not reserve room for the throw.
- **Failure scenario:** The stable has 1 free slot. The player throws at a Ruby creature with one dodge left before it flees. An egg comes due mid-sweep and hatches into the slot. The player taps perfectly and the roll succeeds, but `Grants.capture` refuses the grant. The result is "Missed": the lasso is spent, the miss counts toward fleeing, and the creature can flee (`Capture.luau:258-265`).
- **Fix:** In the hatch loop, skip `collectHatched` and `claimWaiting` while `BattleService.isBusy(player)` is true. Or hold one slot for the throw in flight.

## 3. MEDIUM: Every proximity check trusts the client-owned character position (teleport exploit)

- **Where:** `src/server/World/WorldService.luau:132-140` (`position`), used by `isNear` and `buildingAt` in `InventoryService.luau:88-96` (BuyItem), `:154-158` (BuyGemItem), `:246-250` (ExpandStable), `:277` (HealAtHealer), `WorldService.luau:562` (Travel), `QuestService.luau:36-52` (atGiver), `BattleFlow.luau:110` (tamer engage), `GiantService.luau:160-166` (lair).
- **Problem:** On Roblox a player's own character is network-owned by their device, so `HumanoidRootPart.Position` is the device's word. The file comments say the opposite ("the server's own reading, never the device's word"). Only FindService checks for jumps (FindTrail `lingered` and `fastest`).
- **Failure scenario:** An exploit teleports the character next to the healer, steps back onto the route, and repeats to get free full heals at any point in a route. It can do the same to buy at the shop or travel from any Waystation without walking. Biome gating (`mayEnter`) still applies, so the damage is limited to convenience and pacing.
- **Fix:** Put a shared FindTrail-style speed check behind `WorldService.isNear` and `buildingAt`, refusing when recent samples show a jump. Reset it on server-made moves (`sendTo`, respawn), as FindService does now.

## 4. LOW: `collectHatched` ignores the slot held for a gem-tier catch that is waiting for its serial

- **Where:** `src/server/Breeding/BreedingService.luau:202` uses `data.StableCapacity - countCreatures(data)`. Everywhere else uses `Grants.room(profile)` (`Grants.luau:39-47`), which also subtracts pending `"Gem"` entries.
- **Failure scenario:** A gem-tier wild catch is "Waiting" on its serial and holds the last slot. An egg hatches into that slot. `SerialGrants.finish` then finds no room, so the paid-for catch sits in Pending until the player releases something. `Gems.finishEgg` counts room the other way, so the two disagree.
- **Fix:** Use `local room = Grants.room(data)` in `collectHatched`.

## 5. LOW (approved design, noted for the record): ClaimMs is believed retroactively, so a scripted client can always tap perfectly

- **Where:** `src/shared/Lasso.luau:257-265`; `Net.blink` `LassoPattern` sends `Centre`, `Speed` and `StartPhase` for every zone.
- **Problem:** The sweep is fully determined by data sent to the client, and a claim may be up to `allowance` ms older than its arrival. A script can work out each zone's exact centre time and send it, every time.
- **Failure scenario:** Near-100% best-band taps on every throw. The only check is `Lasso.looksScripted`, which logs once per visit and refuses nothing (`CaptureService.luau:80-98`). Finding 1 makes the window wider.
- **Fix:** Keep the audit, and also refuse or flag in data (not only in the log) accounts whose errors stay under the human floor across N throws. Ayrton's call, because it changes approval pack 2.

## 6. LOW: Leak in FindService, where the `respawns` list grows with every player who ever joined

- **Where:** `src/server/Finds/FindService.luau:320-327` and `PlayerRemoving` at `:334-338`.
- **Failure scenario:** On a long-running server each join adds a `CharacterAdded` connection to `respawns`, and nothing ever removes it, so the table only grows. This is also the only per-player state not cleaned up on leave.
- **Fix:** Key the connections by player (`respawns[player] = conn`) and disconnect and clear the entry in `PlayerRemoving`.

## 7. NIT: Wrong refusal text when no team creature may battle

- **Where:** `src/server/Giants/GiantService.luau:153-156`, `src/server/Battle/BattleService.luau:199-201`.
- **Failure scenario:** `BattleFlow.team` returns `nil, nil` when every team creature fails `Team.mayBattle`, for example when it comes from a biome the player has not reached yet. The player is told "Your data is not loaded".
- **Fix:** Return a reason from `BattleFlow.team` and pass it through, for example "No one on your team can battle here".

## Checked and sound

- Every client handler is rate-limited before it does any work. LassoTap and Pong are O(1) and bounded by throw id, zone order and nonce.
- Turn numbers gate BattleAction, UseItem, ThrowLasso and GiantAction. A throw blocks battle actions and items (`busy`).
- Battle damage is written back every turn, so leaving mid-battle does not undo it. Rewards are paid after the session is cleared, and a yielding `wakeAtHealer` cannot double-pay.
- Lasso and horn spends are atomic with their checks. Gem lassos honour `paidRandomRestricted`, and a Gem lasso cannot be used on a giant.
- No creature changes hands through any battle path.
- Breeding validates types, ownership, locks, pens, coins, candy, giant candy and charm before changing anything, and then applies every change together.
- Encounters.finish keeps the higher miss count, so a dropped battle cannot reset a creature's dodge count.
- Per-player tables are cleared on PlayerRemoving everywhere except finding 6. Delayed callbacks (`resolve`, `finishExternal`, story Follow) are safe after the player leaves.
