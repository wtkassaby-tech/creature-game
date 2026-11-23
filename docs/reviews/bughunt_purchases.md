# Bug hunt: purchases (read-only)

Scope: src/server/Purchases/PurchaseService.luau, src/shared/Purchases.luau, Gems.luau, PassEffects.luau, ShopOffers.luau, InventoryService BuyGemItem, DataService.waitSaved (the receipt path), and the PolicyService gate. I checked the receipt path against ProfileStore 1.0.3's source. No code was changed.

Overall: the receipt path is sound. The grant and the PurchaseId are written together with no yield, PurchaseGranted waits for a save that holds the id, inFlight and handled are bounded, an unknown policy counts as restricted, and every handler a client can call is rate-limited and validated. I found no duplication or client-trust exploit. The findings below are real but none is critical.

## 1. Medium: live switch changes never reach connected clients
- Where: src/server/Purchases/PurchaseService.luau:113-122 (sendFlags runs only from onLoaded, fetchPolicy and pass grant/resume); src/server/LiveConfig/LiveConfigService.luau:22-33 (apply only logs changes and has no callback).
- Scenario: during an incident, ops turns `purchases_open` off. Every player already in a server keeps seeing Robux buttons, bundles, the Gem shop and "Finish now". Each tap only gets the "closed" notice. Worse, turning `chance_display` off makes the server treat paid random items as restricted: Gem lassos are refused at purchase and at the throw, and the Lasso Pass boost is off. The client still has `LassoBoost = true` and keeps offering the Lasso Pass and Gem lassos, with the "+15% catch chance" line. The PurchaseFlags comment in Net.blink promises a resend "whenever the answer changes". That is not true.
- Fix: add `LiveConfigService.onChanged(cb)` that fires from `apply` for each changed key. In PurchaseService, call `sendFlags` for every loaded player when `purchases_open` or `chance_display` changes.

## 2. Low: a receipt that is refused stays stuck forever
- Where: src/shared/Purchases.luau:104-106 (Gems would pass MAX_GEMS) and :89-92 (unknown product); src/server/Purchases/PurchaseService.luau:267-275 then returns NotProcessedYet.
- Scenario A: a player near the 100,000,000 Gem cap buys a bundle. Roblox has taken the Robux, but every attempt is "Refused", so Roblox retries on every join and the player never gets the Gems or any message.
- Scenario B: a bundle is taken out of `PurchaseConfig.PRODUCTS` (retired or renamed) while a receipt for it is still pending. That receipt can never be granted. Scenario A is close to unreachable; scenario B can happen in normal live operations.
- Fix: never delete a product entry (add a `retired` flag the prompt path refuses but the receipt path still grants). At the Gem cap, grant into a pending or escrow record, or record the receipt with a logged "capped" note, instead of refusing forever.

## 3. Low: a suspended (refunded) pass shows as owned on the device
- Where: src/shared/PassEffects.luau:129-137 (`list` ignores suspension); src/shared/ShopOffers.luau:115-125 (an owned pass shows as owned and is never offered).
- Scenario: a refunded Quick Hatch is suspended at load, so the server turns off its effect. The device still lists it as owned, so the shop shows "owned" for a pass that does nothing and never offers to buy it again. The server would allow the purchase (PurchaseService.luau:385 allows a prompt for a suspended pass, and applyPass resumes it).
- Fix: leave suspended passes out of `PassEffects.list`, or send them as a separate "suspended" mark the shop offers to buy again.

## 4. Nit: "PurchasePrompted" is logged when the prompt failed
- Where: src/server/Purchases/PurchaseService.luau:393-408. The `pcall` result of PromptGamePassPurchase or PromptProductPurchase is ignored, so analytics count prompts that never opened.
- Fix: log only when the pcall succeeds, and log "PromptFailed" otherwise.

## 5. Nit: coin and Gem lassos have separate carry caps
- Where: src/shared/Gems.luau:259-262. A Gem lasso is held under its own key ("Basic_g"), so a player can carry `Shop.MAX_HELD` coin lassos plus `Shop.MAX_HELD` Gem lassos of the same tier (1998).
- Fix: check `Items[tier] + Items[tier.."_g"] + amount <= MAX_HELD` if the cap is meant per tier.

## 6. Nit (docs): CLAUDE.md contradicts the 23 November monetisation decision
- CLAUDE.md hard rule 4 and the "Never" list still say lassos and bait are paid with earned coins only, and that nothing with a random result is sold. DECISIONS.md (23 Nov 2026, plan 16) allows Gem lassos and the Lasso Pass, and says it changes those rules. The code follows DECISIONS, which is correct because DECISIONS wins, but CLAUDE.md was never updated.
- Fix: update CLAUDE.md hard rule 4 and the "Never" list to match.

## Checked and fine
- Idempotency: `table.find(receiptIds)` before any change; Gems, Starter room and cosmetic, and `rememberReceipt` are written in one synchronous step. PurchaseGranted is returned only once `LastSavedData` holds the id. A player who leaves mid-receipt gets NotProcessedYet, then AlreadyGranted on rejoin. No double grant.
- waitSaved and ProfileStore: a failed non-ending Save does not fire OnAfterSave, so the wait lasts until the next autosave or the final save. That is slow during an outage but never hangs or duplicates. Mock saves that finish synchronously are handled by the `before` check.
- Starter Pack bought twice pays the plain Gems99 amount and its once-only parts are not granted again. Pass grants are once only; resume and suspend are memory-only.
- Policy: restricted until answered, `~= false` / `== true` parsing, the Lasso Pass and Gem lassos are gated on server and device, and the chance_display switch is folded in on the server.
- BuyGemItem and FinishEgg: rate-limited, Blink-bounded inputs plus whole-number checks, server prices, atShop and the story unlock checked on the server, the stable-room check before finishing an egg, and Gem changes logged before and after.
- Cleanup: policies, lastPrompt, lastFinish and lastGemBuy are cleared on PlayerRemoving, the suspension table is weak-keyed, and handled is capped at 2000.
