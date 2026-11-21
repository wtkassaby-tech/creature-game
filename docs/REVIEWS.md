# Independent reviews

Findings from reviewers that did not write the code or the plan, as the project rules require for anything touching saving, purchases, captures, breeding, serials, trading or PvP rewards.

## 21 November 2026: quests, the shop, items in battle (commits 3520b21, b6d0d45)

Reviewer: a separate read-only agent. No must-fix findings: a quest cannot pay twice or be handed in without its objective; counts and item ids at the shop are checked; an item is used up only when it was really used; a Rally Root cannot un-lose a battle.

| # | Finding | Severity | Fix |
| --- | --- | --- | --- |
| 1 | Prices used the shop's biome, so a player far into the game could walk back to the first town and buy Giant Horns and Bond Charms at the first-biome price (a coin loop once giant rematches pay) | Should fix | Prices follow how far the player has got, wherever they shop. Test added |
| 2 | The optional giant quest could be taken but never finished, because nothing records a beaten giant yet | Note | The quest cannot be taken until giant fights are on the server (`QuestProgress.GIANTS_OPEN`) |
| 3 | A quest with a starter reward could never be handed in | Note | A test now checks no quest has one |
| 4 | Saved quest progress was never checked, and a damaged value could stop the story moving on after a battle | Note | `Profile.validate` checks quests; counting skips damaged values and can no longer stop what follows. Tests added |
| 5 | Items have no per-battle limit and no battle-kind check; a stock of tonics can outlast a tamer on the turn limit | Note | Items are refused in friendly (player against player) battles. A per-battle cap is a design question, listed for Ayrton |
| 6 | Gifts can take a player over the 999 carry limit | Note | Harmless; left as it is |
| 7 | Two request kinds shared one rate limit, and a dropped purchase got no reply | Note | Each kind has its own limit; a purchase always gets an answer |
| 8 | Prices were never rounded down | Note | Rounded down, and a test checks every price in every biome is a whole number |

## 21 November 2026: the world, tamers, the rival, story triggers (commit e39b0f5)

Reviewer: a separate read-only agent. Scope: `Encounters`, `Layout`, `Trainers`, `StoryTriggers`, `Rewards.trainedWin`, the world and story services, the rewritten `Main.server.luau`, and the battle and capture service changes. No must-fix findings. The open item from 20 November ("misses must follow the wild creature, not the battle") is closed.

| # | Finding | Severity | Fix |
| --- | --- | --- | --- |
| 1 | Starting a battle had no rate limit | Should fix | Limited like every other request |
| 2 | Rejoining reset rustle-spot rests and refill waits (rustle spots are the only source of uncommon species) | Should fix | The timers are kept in server memory for ten minutes after a player leaves and given back when they return. They still reset on a different server; saving them would need a schema change, so that waits until it is shown to matter |
| 3 | Walking out of range and back rerolled a stretch at once (unlimited rerolls for rare colours) | Should fix | A cleared stretch waits before it refills, like a beaten one. Test added |
| 4 | A creature could reach its flee count and stay in the world if the battle ended as a loss on the same turn | Should fix | A creature at its flee count is gone however the battle ended. Test added |
| 5 | An error while starting a battle left the wild creature marked as busy, or a battle half started | Note | The start is wrapped; any failure hands the creature back |
| 6 | Tamer rematches give XP every time (coins stop after the paid rematch) | Note | Intended: wild battles also give XP without limit, XP falls off as the player out-levels a fixed-level tamer, and the badge level cap bounds it. Logged in `DECISIONS.md` |
| 7 | A fallen character still passed position checks | Note | A character with no health has no position |
| 8 | A refused rustle reveals the rest timer | Note | Harmless; left as it is |
| 9 | If a story battle's beat could not finish, the battle could be replayed for XP | Note | A story battle once won is closed for good; the story catches up from the recorded win; a failure is logged loudly. Test added |

## 21 November 2026: battle rewards, story gifts, releasing (commit 4e4f438)

Reviewer: a separate read-only agent. Scope: `src/shared/Rewards.luau`, `src/shared/StoryProgress.luau`, the handlers in `src/server/Main.server.luau`, and the new messages. No must-fix findings: no battle pays twice, no client value reaches a payout, no story gift pays twice.

| # | Finding | Severity | Fix |
| --- | --- | --- | --- |
| 1 | A content mistake in a gift (a bad rarity, or egg parents that cannot breed) would error after the beat's flag was set, leaving the beat half paid for good | Should fix | Every gift is built and checked before anything changes. Test added |
| 2 | One damaged save could stop the hatch loop for the whole server | Should fix | Each player's hatch runs on its own, and a failure is logged |
| 3 | A starter that had to wait for room never joined the team; waiting gifts were only handed over on join | Note | A gift that arrives to an empty team joins it; waiting gifts are handed over after releases and hatches too. Test added |
| 4 | The mentor's egg ignored pen space | Note | Pens are paid first; with no free pen the egg waits in the saved list and takes the next free pen. Test added |
| 5 | Wild coins used the species' home biome, not where it was fought | Note | Rewards take the battle's biome; the world service must pass the route's biome (Greenwood only until then) |
| 6 | An error part way through rewards could leave a battle half paid | Note | Every share is worked out first, then everything is paid together |
| 7 | Hatched children and story gifts were not recorded in the Index | Note | Every creature that joins the stable is recorded |

## 20 November 2026: data service, creature grants, lasso capture (commit 8d1983c)

Reviewer: a separate read-only agent that did not write the code. Scope: `src/server/Data/DataService.luau`, `src/shared/Grants.luau`, `src/shared/Capture.luau`, the new Pass action and the ProfileStore 1.0.3 calls.

| # | Finding | Severity | Fix |
| --- | --- | --- | --- |
| 1 | A throw could still be judged after the player ran: a hit caught a creature they had run from; a miss crashed the handler and never counted toward fleeing | Must fix | `Capture.finish` refuses once the battle has ended; no assert. The capture service also blocks every battle action while a throw is in the air. Test added |
| 2 | The daily reset fired on any change of day, so hopping between servers whose clocks disagree near midnight reset the candy falloff | Should fix | The day only moves forwards. Test added |
| 3 | A giant could be released, losing it for good (it can never be caught again) | Should fix | Releasing a giant is refused. Test added |
| 4 | A caught creature was saved as the battle's own table, so a shared spawn record could reach two profiles | Should fix | The capture saves a deep copy. Test added |
| 5 | An unreadable save was written back in its filled-in form, not as found | Should fix | The original is restored before the session ends |
| 6 | A giant with a full stable uses up a serial on every retry; the comment said it waits | Note | Comment corrected; the giant serial service (not written yet) must check room first or keep the serial on the waiting entry |
| 7 | A save that can never be stored was only logged, so every save would fail silently | Note | Refused like an unreadable save |

Caller rules the reviewer set for the capture service, and where each is met:

- One open throw per player, and no battle action while it is open: `CaptureService` (`playing`, and `BattleService.setBusyCheck`).
- The round trip, seed and start time come only from the server: `RoundTrip` (random-nonce pings, smallest reading) and `CaptureService`.
- One message per tap, stamped on arrival: `LassoTap`.
- The daily roll before every capture: done in `CaptureService`. The release service (not written yet) must do the same.
- Misses must follow the wild creature, not the battle: **open for the world service**. Today each Studio test battle makes a fresh creature, so it cannot be fought twice; real spawns must despawn after a battle or carry their miss count.
- Fresh unique ids for every grant: GUIDs in `Main.server.luau`.

## 16 November 2026: saving design, creature grants, breeding server flow, lasso judging

Reviewer: an independent Opus exploit reviewer, read-only. Reviewed before approval and before any of it is wired up: `docs/plans/01_SAVING.md`, `docs/plans/02_CREATURE_GRANTS.md`, `src/shared/Profile.luau`, `src/server/Breeding/BreedingService.luau`, `src/shared/Lasso.luau`.

| # | Finding | Severity | What was done |
| --- | --- | --- | --- |
| 1 | Reserving a giant's serial number means a wait, during which the player could leave and lose the giant, or the one-time flag could be raced | Must fix | Pack 2 section 5 rewritten: the capture is saved as "waiting" first, the number is fetched, and the grant is re-checked and applied in one step afterwards; an unfinished capture completes on the next join. The creature record now has a `serial` field, and the save checks reject a repeated serial |
| 2 | Nothing said what happens if a record's session ends while the player is still playing | Must fix | Pack 1 section 3: the player is removed at once and the data stops being visible to the game. No lock is ever taken by force |
| 3 | The purchase rule was not written down; "cannot be lost" overstated what an immediate save guarantees | Must fix | Pack 1 section 4 now states the three rules and the honest wording |
| 4 | A breeding charm took effect without being taken from the inventory | Must fix | `BreedingService` refuses a charm the player does not own and uses it up in the same step as the payment. Charm input is parsed by tested shared code (`Breeding.parseCharm`) |
| 5 | The breeding flow read a `Locked` field that the saved record does not have | Must fix | Locks are server-memory only, passed in as a function; the service now uses the real profile type |
| 6 | A child of bound parents was tradable | Must fix | `bound = a.bound or b.bound`, with a test |
| 7 | A player could fake a slow connection to get the slowest sweep, stack it with slow mode, and claim taps after the fact | Must fix | The lag allowance is fixed in the pattern when the throw is made and comes from the server's smallest reading (`Lasso.trustedRoundTripMs`); slow mode and the assist share a floor of 40%; pack 2 says assist use is logged per account |
| 8 | "Impossible" taps were not defined, so a known miss could be turned into a free retry | Must fix | Pack 2: an impossible tap counts as a miss, with the lasso spent |
| 9 | One-time gifts waiting for room had nowhere to be saved; hatching ignored stable capacity | Must fix | A saved `Pending` list in the profile; an egg stays in its pen until there is room |
| 10 | The save checks missed several broken states and could crash on a badly broken save | While building | Added: the same creature in two eggs, unknown species, wrong body plan, an unbound giant, repeated serials, bad rarity, size, colour and generation, bad purchase ids. A save too broken to check is reported as unreadable, not an error. Still to add when giants exist as data: giants owned against giants marked captured |
| 11 | A table containing itself overflowed the copy and storability checks; invalid text got through | While building | Depth limit on both; invalid UTF-8 text is refused. The 4 MB size limit cannot be measured in pure code; stable capacity keeps saves small |
| 12 | Migrations must run before default values are filled in, and the upgraded copy must be in place before any save | While building | Stated in pack 1 section 3; to be enforced in the data service |
| 13 | The breed rate limit used whole seconds | While building | Now uses a sub-second clock |

Found sound: one record per player with a session lock; the breed request making no pause between its checks and its changes; the lasso judge's bounds on tap count, numbers and the server clock.

Open for the data service's own review (before Gate C): the exact ProfileStore calls, the save-confirmed purchase flow, and the removal of a player whose session ends.
