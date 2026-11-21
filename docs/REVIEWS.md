# Independent reviews

Findings from reviewers that did not write the code or the plan, as the project rules require for anything touching saving, purchases, captures, breeding, serials, trading or PvP rewards.

## 21 November 2026: the battle that cannot be lost (commit 597d303)

Reviewer: a separate read-only agent. It did not run the tests.

| # | Finding | Severity | What was done |
| --- | --- | --- | --- |
| 1 | The Tide Flats champion (being written at the same time) carried the old "try again at once" setting, which now means "cannot be lost" | Must fix | Set to false in the Tide Flats content. A test now fails if any story battle other than the rival's first one cannot be lost |
| 2 | If both last creatures fell on the same turn, the player held on and then had to play one more turn against an opponent that had already fallen | Should fix | A double knockout in this battle is now a win at once, with a test |
| 3 | The "holds on" event arrives after a "faints" event for the same creature | Note | Checked: the battle screen sets the creature's health back to 1 and keeps it in play |
| 4 | The team is mended after this battle, so a player who walks in hurt is healed once | Note | Accepted: it can happen once per account, at the very start of the game |

Found sound: the setting comes only from content data, never from the device; wild battles, local tamers and giants never have it; the battle cannot be replayed once won, and pays experience only; nothing grows with the length of the battle, which is capped at 60 turns; leaving part way gives no reward and no mending; running is refused.

## 21 November 2026: bait and crafting (commit 966744a)

Reviewer: a separate read-only agent. No must-fix findings: a bait cannot be used without owning one, used twice, or used where it should not work; the device cannot influence the gem chance; crafting cannot go below zero, make anything without a recipe, or be turned back into coins.

| # | Finding | Severity | Fix |
| --- | --- | --- | --- |
| 1 | A player can see what a bait brought out and walk away from anything not gem-tier, so with no limit, coins alone set how many gem-tier creatures appear (99 baits in under a minute) | Should fix | Baits are limited to 5 uses a day (`BAIT_USES_PER_DAY`), counted by the server's date. Test added |
| 2 | Nothing checked that every rustle spot has creatures in it; an empty one would take a player's bait money for nothing | Should fix | A test checks every rustle spot in every biome |
| 3 | A bait's gem roll replaced the row's own tier, so it could lower a rarer row | Note | It can only raise the tier |

## 21 November 2026: more than one biome, gem serials, travel, stable room (commits 0e291e8 to dbe2c8a)

Reviewer: a separate read-only agent. Found sound: travel between towns; wild creatures, rustle spots and long grass gated by biome; shop prices; gem catches cannot be duplicated and their candy is paid once; story battles cannot be replayed or fought out of order.

| # | Finding | Severity | Fix |
| --- | --- | --- | --- |
| 1 | A giant win was paid by the biome the player was standing in when the fight ended, so walking into a later biome mid-fight paid that biome's bigger reward for a cheap horn | Must fix | The fight's biome is fixed when it starts, and the reward follows it |
| 2 | Giants and tamers of a biome the player had not earned could be fought (the grey-box gate does not block walking): first-clear coins, a later giant's rewards and a capture attempt, with no badge | Must fix | Both are refused until the player holds the badge for that biome |
| 3 | Gem catches waiting for a serial number did not count against stable room, so they could pile up without limit while the serial store was slow | Should fix | A waiting gem holds a place in the stable. Tests added |
| 4 | A failing serial store was retried about every five seconds for each waiting entry, drawing on the same budget as player saves; a damaged counter was retried for ever | Should fix | Failed fetches back off (30 seconds, doubling to 10 minutes); a damaged counter gives no numbers until the server restarts |
| 5 | The save check called two creatures with the same number a repeat even when they were different tiers | Should fix | Numbers are compared within their own kind. Tests added |
| 6 | A gem creature in the waiting list was not checked like one in the stable | Note | It is now. Test added |
| 7 | The stable's starting size is named in two configs | Note | A test holds them equal. A saved count of expansions is needed before stable room can be bought any other way (noted in approval pack 5) |
| 8 | Duplicate ids across tamers, story battles, giants or places would be silently overwritten | Note | Tests check all of them are unique, and that no two buildings share a name |

Not separately reviewed: the Dust Canyon content (data only; its rewards come from the economy's config and its own test checks them).

## 21 November 2026: daily tasks (commits 9f49d29, e471c7d)

Reviewer: a separate read-only agent. No must-fix findings: a task cannot be paid twice or before it is finished; nothing that did not happen is counted; the daily caps match the economy's (3 easy and 3 harder payouts); the move of the battle wiring into `BattleFlow` dropped nothing.

| # | Finding | Severity | Fix |
| --- | --- | --- | --- |
| 1 | "Win 5 tamer rematches" could be done by beating one weak tamer five times in a row | Should fix | Only the first rematch of each tamer in a day counts. Test added |
| 2 | A task finished late in the day and not claimed before the server's midnight was lost, and the screen's view of tasks changed saved data as a side effect | Should fix | Finished tasks are paid automatically when the day ends; the view is read-only. Tests added |
| 3 | The win that earns the first badge does not count toward that day's tasks | Note | Harmless; left as it is |
| 4 | Catching a giant does not count as "tame a creature" | Note | Left as it is |

## 21 November 2026: giant capture, serial numbers, Giant Candy (commit 51481a4)

Reviewer: a separate read-only agent. Found sound: no way to capture the same giant twice, forge a hit, reuse an attempt or get more than one throw per win; a rejoin during the serial wait is safe; the capture throw cannot be mixed up with a battle throw or lock a player out; Giant Candy comes only from wins and is taken in the same step as the breed; breeding from a giant is not a cheap way to make gem-tier creatures (one breed takes about five days and ten horns).

| # | Finding | Severity | Fix |
| --- | --- | --- | --- |
| 1 | A waiting capture that could never finish (already marked captured, or the giant's creature form removed) would fetch and throw away a serial number every five seconds | Should fix | A number is fetched only for a capture that really needs one; stale waiting entries are cleared; the save check reports a giant that is both captured and waiting. Tests added |
| 2 | The stable could fill during the wait for a number, wasting it, and a player could do this on purpose to push the counter up | Should fix | The fetched number is written onto the saved waiting capture and reused: one number per capture, however long it waits for room. Tests added |
| 3 | A counter value that was not a number was treated as zero, which would give numbers out a second time | Should fix | Only a missing counter starts at 1; anything else is left alone, raises an alarm and gives no number |
| 4 | The captured giant's bigger size also raised its Hp and Defence beyond what any other creature can reach, and pushed nearly all its children to the largest size | Should fix | Size counts for stats and for breeding only within the ordinary range: the giant looks bigger but fights as the largest ordinary size. Test added |
| 5 | A new giant fight could be started while a capture attempt was still on offer | Note | Refused while an attempt is on offer or in the air |
| 6 | The check for scripted tapping is never run | Note | The capture throw now logs how far each tap was from its centre. Running the audit over each player's throws is still to build (listed in `PROGRESS.md`) |
| 7 | The save check missed a giant with no serial number | Note | Reported now |

## 21 November 2026: lasting damage, healing, long grass, team choice (commit ec0a7a0)

Reviewer: a separate read-only agent. No must-fix findings. Found sound: health values stay valid; damage is written back every turn, so leaving never heals; nothing but the healer, a tonic or waking at the healer resets health; team changes are locked during every kind of battle; the story gates cannot be bypassed.

| # | Finding | Severity | Fix |
| --- | --- | --- | --- |
| 1 | Waking at the healer was a cheap trip home and a full heal: put one nearly fainted creature on the team, lose on purpose, and the whole stable was mended | Should fix | Waking at the healer mends only the team that fought. A team with nobody able to fight is refused while the player owns a creature that can. Whether waking at the healer should also cost coins is a question for Ayrton. Tests added |
| 2 | A grass battle that could not start (a fainted team) left the creature standing in the world, so walking in grass with a fainted team revealed creature after creature | Should fix | Grass does nothing unless wild battles are open and someone on the team can fight; a grass battle that fails to start removes its creature |
| 3 | After a draw the knocked-out wild creature stayed in the world and could not be fought | Should fix | A wild creature with no health left is gone. Test added |
| 4 | The first look after a battle compared against the position from before it, so standing still could count as walking | Should fix | The walking check starts fresh after any time out of the world |
| 5 | Running gives a free moment to use tonics before re-engaging a hurt wild creature | Note | Intended: it is the "weaken it, then catch it" play, and missed throws and fleeing are still counted |
| 6 | A giant turn that errored skipped the faint check | Note | It runs there too |
| 7 | Grass ignored the story's "wild battles" gate; the healer ignores its gate | Note | Grass is gated. The healer is left open on purpose: free healing is harmless and a new player may need it after the first battle |
| 8 | A server-started battle relied on its caller to rule out a giant fight | Note | The battle service checks it itself |
| 9 | Waking at the healer uses the current biome's healer | Note | Marked in the code for when more biomes exist |

## 21 November 2026: giant fights (commit f094181)

Reviewer: a separate read-only agent. Found sound: a fight cannot pay twice; the horn is used up only after every check and never refunded; battles of different kinds cannot overlap; every choice is checked and items are capped at five; creature locks cover giant fights.

| # | Finding | Severity | Fix |
| --- | --- | --- | --- |
| 1 | Giant Horns bought cheaply in Greenwood could be saved up and used on later giants, whose rematches pay far more than those horns cost (about +3,650 coins a fight in biome 3) | Must fix (before later giants ship) | Horns are graded by the biome they were priced for: a horn wakes its own biome's giant or an earlier one, never a later one. Tests added, including "a rematch pays less than any horn that can start it, in every biome" |
| 2 | No way to give up a fight; an error mid-turn could leave the player stuck in it | Should fix | A give-up message ends the fight (the horn stays spent); a turn that errors ends the fight |
| 3 | The turn was sent to the device before the fight was closed and paid | Note | The fight is closed and paid first |
| 4 | Nothing in the story gated starting a giant fight | Note | The giant stirs only once the story has shown it to the player |
| 5 | The fight log showed creature ids, not names | Note | It shows species names |

Found by a new test before the review: a Greenwood giant rematch paid 910 coins for a 900-coin horn. A rematch is now capped at 85% of its biome's horn price.

Not separately reviewed: choosing the team (`src/shared/Team.luau`, tested) and the story gates on breeding and the shop. Neither grants anything; both only refuse requests.

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
