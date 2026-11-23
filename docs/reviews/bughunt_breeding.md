# Bug hunt: breeding, eggs, hatching, Gems egg finish

Read-only review, 23 November 2026. Scope: `src/shared/Breeding.luau`, `Stats.luau`, `AssemblyMath.luau`, `Rng.luau`, `src/server/Breeding/BreedingService.luau`, the hatch loop and `RequestBreed` handler in `src/server/Main.server.luau`, `Gems.finishEgg` and its `FinishEgg` handler in `src/server/Purchases/PurchaseService.luau`, gift eggs in `src/shared/Gifts.luau`, and the `Grants` room rules they rely on.

No critical or high findings. The breed is atomic (nothing yields between the checks and the writes), every client value is type-checked, the child is rolled on the server from a logged seed, the egg's child is not sent to the client (EggView carries only HatchAt), the request is rate-limited, and `bound` and `paidAssist` are inherited, which closes the laundering routes. Gems shorten the timer only and never change the child.

## 1. Medium: a hatch takes the stable place held for a gem catch that is waiting for its serial

- **Where:** `src/server/Breeding/BreedingService.luau:202`, `local room = data.StableCapacity - countCreatures(data)`
- **Problem:** `Grants.room` (`src/shared/Grants.luau:39-47`) counts each `Pending` entry with source "Gem" as a place already taken: a gem-tier catch holds its place while its serial number is fetched. `collectHatched` uses raw capacity instead, so it ignores those held places. `Gems.finishEgg` (`src/shared/Gems.luau:157`) and `Grants.capture` and `claimPending` all use `Grants.room`, so the hatch path is the only one that breaks the reservation.
- **Failure scenario:** stable capacity 30, 29 creatures, 1 Amber catch waiting for its number (`Grants.room` = 0). An egg's timer runs out. The next 5-second hatch tick computes room = 30 - 29 = 1 and hatches the egg, leaving 30 creatures. When the serial arrives (or after a backoff of 30-600 s if the counter store is struggling), `Grants.finishGem` sees `Grants.room` = -1 and returns NoRoom. The catch, with its serial already used up, stays stuck in Pending until the player releases something. The player is told "Make room in your stable" for a catch the game promised a place to.
- **Fix:** `local room = Grants.room(data)` (Grants is already required).

## 2. Low: the preview's stat range is not the real lowest and highest

- **Where:** `src/shared/Breeding.luau:414-435` (`Breeding.preview`)
- **Problem:** the comment promises "the true lowest and highest stats", and BREEDING_PLAN step 2 shows them as the best and worst case. The calculation, though, uses each parent's exact part quality, the raw mean size and rarity "Common". The real roll (`Breeding.breed`) differs in four ways: (a) `driftQuality` moves each part one pip up or down; (b) a 2% mutation can move one part two pips; (c) size gets plus or minus `SIZE_JITTER`, and each parent is clamped to the ordinary range first (a giant of size 1.3 counts as 1.1), while the preview averages raw sizes; (d) a Gem, Ruby or Diamond child gets `RARITY_BOOST` of 1.05 to 1.15.
- **Failure scenario:** two quality-5 Commons give low = high in the preview. The child drifts one part to quality 6 and lands above the "highest". Or with Gem parents, a Gem child is about 5% above the high on every stat. Breeding with a giant shows a higher maximum than any child can reach (preview size 1.1, real maximum 1.08).
- **Fix:** take the range over quality ±1 (clamped; ±2 if mutation is included), size `(ordinary(a)+ordinary(b))/2 ± SIZE_JITTER`, and the lowest and highest `RARITY_BOOST` among the tiers in `rarityOdds`. The other option is to relabel the range as "typical, before drift".

## 3. Low (latent): any two gift-egg children count as full siblings

- **Where:** `src/shared/Gifts.luau:123-124` (parents built with fixed ids `"gift_a"` and `"gift_b"`) together with `src/shared/Breeding.luau:60-63` (the full-sibling test compares parent ids)
- **Problem:** every gift-egg child is saved with `parents = { "gift_a", "gift_b" }`, so `isKin` treats any two gift-egg children as full siblings, whatever their species.
- **Failure scenario:** today there is only one Egg reward (`src/content/story_data/Chapter1.luau:28`), so this cannot happen yet. As soon as a second Egg reward exists (a quest egg or a later chapter's egg), those two children are refused with "Close relatives cannot breed", even with unrelated species.
- **Fix:** give the throwaway parents unique ids per egg, for example `` `gift:{childId}:a` ``, or save the gift child with `parents = nil`.

## 4. Low: hatches (and breeds) do not request a save

- **Where:** `src/server/Main.server.luau:346-376` (the hatch loop) and `:327-344` (`RequestBreed`)
- **Problem:** `DataService.saveSoon` says it is meant to run "after a purchase, a giant capture or a hatch", but the hatch loop never calls it. The breed handler does not call it either. Both are atomic within the profile, so a crash rolls them back whole: the same egg hatches the same child again. Nothing is duplicated today. Once trading exists, though, a hatched child could be traded before its hatch is saved, which leaves the trade to carry the save on its own.
- **Fix:** call `DataService.saveSoon(player)` when `#hatched > 0`, and after a successful breed.

## 5. Nit: the Gem egg-finish log does not name the egg

- **Where:** `src/server/Purchases/PurchaseService.luau:429-437` (the `GemSpend` log for FinishEgg); `src/shared/Gems.luau:176-177` returns no egg identity
- **Problem:** CLAUDE.md rule 8 asks for value movements to be traceable by creature id. The log records the Gems and the seconds skipped but not which egg or child, so a support case ("I paid and nothing hatched") cannot be matched to an egg.
- **Fix:** add `child = target.child.id` to `Finished` and log it.

## 6. Nit: numbers outside `src/config`

- `src/shared/AssemblyMath.luau:10-11` (`SCALE_MIN` 0.6 and `SCALE_MAX` 1.6) and `src/server/Breeding/BreedingService.luau:35` (`MIN_SECONDS_BETWEEN_REQUESTS`) are tuning numbers that CLAUDE.md rule 9 places in `src/config/`.
- **Fix:** move them to `BreedConfig`.

## Checked and found sound

- **Atomicity:** coins, candy, Giant Candy, the Bond Charm, the parents' counters and the egg are all checked before any write, and `requestBreed` has no yields. `LiveConfigService.isOn` is a table read.
- **Client input:** the ids are checked as strings and looked up in the server's own profile. `parseCharm` accepts only real slots and sides, and a half-sent charm is refused.
- **Pens and the stable:** pens are never exceeded (the breed, `claimEggs` and `Gifts.pay` all check), and a hatch never takes the stable over raw capacity.
- **Cosmic and kin:** Cosmic creatures cannot breed, so the empty Cosmic cooldown list is never indexed. The kin rule matches the plan (parent and child, full siblings).
- **Candy:** `candyCost` and `giantCandyCost` merge correctly when a giant breeds with a same-type parent. `candyPayment` refuses NaN and infinite amounts.
- **Rng:** stays in [0, 1); `rollRarity` falls back safely if the odds add up to slightly less than 1.
- **FinishEgg:** rate-limited (0.5 s). It matches by the server's own hatchAt, charges only when there is room, saves after spending, and never touches the child.
- **Snapshot:** sends at most 4 eggs, which equals `MAX_PENS`, so every egg can be finished.
