# Independent reviews

Findings from reviewers that did not write the code or the plan, as the project rules require for anything touching saving, purchases, captures, breeding, serials, trading or PvP rewards.

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
