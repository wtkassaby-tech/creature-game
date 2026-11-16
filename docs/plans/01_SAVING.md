# Approval pack 1: saving

Date: 16 November 2026. For: Ayrton. Status: **waiting for approval**. Nothing in this pack saves anything yet. Revised the same day after an independent exploit review; its findings are in `docs/REVIEWS.md`.

The project rules need your yes before anything that touches saving is built, and an independent review after. This pack is the plan for the save itself. Read section 6 first if you only have two minutes: it lists what you are agreeing to.

## 1. What is saved

One record per player, holding everything that must change together: coins, Gems, Breeding Candy, creatures, the team, eggs, items, story progress, quests, daily counters, the collection index, purchases, settings and play statistics.

The exact shape is already written as code so it can be checked: `src/shared/Profile.luau` (the shape, a new player's starting values, migrations and soundness checks) and `src/config/ProfileConfig.luau` (the starting numbers). It has 54 passing tests in `tests/profile.test.luau`. It is pure: it does not load or save. Nothing depends on it yet, so the shape can still change freely.

Starting values for a new player: 0 coins, 0 Gems, 0 candy, 1 pen, room for 30 creatures, team size 3.

## 2. How it is stored

| Choice | Plan | Why |
| --- | --- | --- |
| Library | ProfileStore, the same library chosen for the golf project | It locks a player's data to one server at a time, which closes the commonest duplication trick (joining two servers at once) |
| One record per player | Yes | Roblox cannot save two records in one step. With one record, a breed, a capture or a purchase is saved whole or not at all |
| Version number | `SchemaVersion`, starting at 1 | Every later change to the shape ships with a migration and a test |
| Store names | `PlayerData_Test` during playtests, `PlayerData_Live` from the soft launch | Test data never leaks into the live game; the live store starts clean |

The exact ProfileStore calls will be checked against its documentation when the data service is built, as the "never invent an API" rule requires. Its documentation could not be opened from this cloud session.

## 3. What happens when a player joins and leaves

1. **Join:** the server asks for the player's record and its lock. If it cannot get both (Roblox's data stores are down, or another server still holds the lock), the player is told and removed from the server. **The game never lets someone play on blank data when their real data failed to load.** That is how progress gets wiped.
2. **Upgrade:** if the record is from an older version, migrations run on a copy, before anything else touches the record. Only then are new fields given their starting values and the upgraded copy put in place. If any step fails, or the record is from a newer version of the game than this server, the copy is thrown away, the original is left untouched and the player is removed with a message.
3. **Check:** the record is run through the soundness checks (no negative balances, no creature in two places, team members all owned, and so on). Problems are logged as an alarm for us. Nothing is ever deleted automatically.
4. **Play:** changes are made to the record in memory. Each action (a breed, a capture, a purchase) makes all of its changes in one uninterrupted step, so a save can never catch it half done.
5. **Save:** the library saves on a timer and when the player leaves. After a purchase, a giant capture or a hatch the server also asks for a save straight away.
6. **Losing the lock mid-play:** if the record's session ends while the player is still in the game (for example a save keeps failing), the player is removed at once and every part of the game stops seeing their data from that moment. Nothing is ever done on a record that will not be saved. The game never takes a lock from another server by force.
7. **Leave or shutdown:** the record is saved and the lock released. On a server shutdown every player's record is saved before the server closes.

## 4. What can go wrong, and the answer

| Risk | Answer |
| --- | --- |
| The same account in two servers, to copy creatures | The session lock: the second server cannot load the record |
| A crash halfway through an action | One record, and each action applied in one step, so the save holds either all of it or none |
| Roblox's data stores are down | The player cannot join. No blank data, no overwriting |
| An old server loads data written by a newer version | Refused. The record is not touched |
| A migration has a bug | It runs on a copy; on failure the original is kept. Every migration has a test before it ships |
| Roblox sends the same purchase twice, or a purchase arrives when the record is not loaded | Three rules. The id is remembered and the product granted in one step with no pause between. Roblox is told "granted" only after a save containing that id has succeeded. If the record is not loaded on this server, Roblox is told "not processed yet" and sends it again later. The last 100 ids are kept; Roblox only re-sends purchases it was never told were granted, so 100 is ample |
| The server crashes between saves | The record goes back to how it was at the last save: up to one save interval of ordinary play is lost, and nothing is copied. A purchase caught this way was never confirmed to Roblox, so Roblox sends it again |
| A value that Roblox cannot store slips into the record | A check runs in tests and on load; such a record would fail to save loudly, not silently |
| A record somehow breaks the rules (a duplicate, a negative balance, a repeated serial, a part from a species that no longer exists) | The soundness checks log an alarm with the player's id, so it is investigated the same day. A record too broken to check counts as a failed load |
| A creature left locked for ever after a crash | Locks (in a battle, in a trade) live only in the server's memory, never in the saved record |

Not covered by this pack: serial numbers and how creatures are granted (pack 2), breeding (pack 3), purchases (pack 4), and trading, which needs its own two-step design across two players' records (pack 6).

## 5. How it will be tested before any player's data exists

| Test | Where |
| --- | --- |
| Shape, starting values, migrations (including refusing newer saves and failed steps), repeat purchases, every soundness check, what can be stored | Lune, in `tests/profile.test.luau` (written, 39 passing) |
| Join, play, leave, rejoin: everything is still there | Studio |
| Two servers at once: the second cannot load the record | Studio, two test servers |
| Server shutdown with players in it: everyone's last change is saved | Studio |
| Data stores unavailable: the player is removed, nothing is overwritten | Studio, with the data service switched to fail |
| A made-up old save runs through a made-up migration end to end | Lune and Studio |
| Independent exploit review by a reviewer that did not write the code | Before Gate C; findings in `docs/REVIEWS.md` |

## 6. What you are approving

- [ ] One record per player through ProfileStore, with a session lock.
- [ ] A player whose data fails to load cannot play that session.
- [ ] Separate stores for playtests and the live game; **playtest progress is wiped at the soft launch**.
- [ ] The Greenwood slice (milestone 3) runs without saving; saving arrives in milestone 4 after this approval and its review.
- [ ] If the record's session is lost mid-play, the player is removed at once.
- [ ] The three purchase rules in section 4.
- [ ] The shape in `src/shared/Profile.luau` as the starting point. It can change before launch without a migration; after launch every change needs one.

Questions that are yours:

1. Is wiping playtest progress at the soft launch acceptable? Testers aged 16 and over will lose what they earned in testing.
2. Starting room for 30 creatures: right, or more generous? Extra storage is a planned product, so this number also sets how soon a player meets that offer.
