# Approval pack 2: how creatures come into existence

Date: 16 November 2026. For: Ayrton. Status: **approved by Ayrton on 20 November 2026**, with Claude's recommended answers (see `DECISIONS.md`). Nothing in this pack is built yet, except the lasso timing rules, which only judge a tap and grant nothing. Revised the same day after an independent exploit review; its findings are in `docs/REVIEWS.md`.

Every creature has value, so every way one can appear is listed here with its limits. The Greenwood slice (milestone 3) builds the first of these in memory only; from milestone 4 the same rules write to the saved record. Breeding has its own pack (3).

## 1. One rule for all of them

Every creature is made by the server, in one place in the code, in one step:

1. The server decides the creature. The player's device never sends a creature, a stat, a rarity or an id.
2. The server gives it a new unique id.
3. The server checks there is room in the stable.
4. The creature is added, any one-time flag is set, any item is taken, and the event is logged with the creature's id, all together.

A creature caught, gifted or hatched is recorded with where it came from and which biome it belongs to.

## 2. Each way a creature appears

| Way | When | Limit | Decided by | Tradable later |
| --- | --- | --- | --- | --- |
| Starter | First minute: the player picks one of three | Once per player, ever. Picking again does nothing | Species chosen by the player; quality rolled by the server | Yes |
| Wild capture | After weakening a wild creature in battle, a lasso throw that hits | One lasso per throw, taken before the throw starts. One capture per wild creature | The creature was rolled by the server when it spawned; the throw is judged by the server's clock | Yes |
| The mentor's egg | About minute 10 of the first session | Once per player | Rolled by the breeding rules from the mentor's two fixed creatures | Yes |
| Quest reward | The end of a biome's quest line | Once per quest | Fixed species; quality rolled | Yes |
| Clear token | Clearing a biome | Once per biome | Fixed species; quality rolled | Yes |
| Giant capture | Beating a biome's giant, then one hard lasso attempt | Each giant once per player, ever. Rematches are allowed until it is caught | Fixed creature; gets the next serial number | **No: bound to the account** |
| Breeding | Pack 3 | Pack 3 | Pack 3 | Yes |

Later, not at launch: bait spawns (a wild capture with a summoned creature), the rival's gift, cosmic wraps and tournament prizes.

## 3. Catching, step by step

1. The player's device asks to fight a wild creature it can see. The server checks that creature exists, is near the player and is not already in a fight.
2. The battle runs on the server.
3. To throw, the device asks for a throw. The server checks the battle is live, the creature is still standing, the stable has room and the player has a lasso of that kind. It takes the lasso, then sends the sweep pattern.
4. The device sends back only the time of each tap. The server judges it (`src/shared/Lasso.luau`) as a hit, a miss, or impossible (a time that could not have happened on the server's clock).
5. On a hit the creature is added to the stable and removed from the world. On a miss the wild creature takes its turn. **An impossible tap is treated exactly like a miss:** the lasso stays spent and it counts toward the creature fleeing. Otherwise a player who knows they missed could send a nonsense time and try again for free.

The allowance for a slow connection uses the server's own reading of each player's delay, taken several times during the battle, and trusts the smallest one: a player can make a reply arrive late but never early. The reading is fixed before the sweep is sent and the same reading judges the tap. Slow mode and the slow-connection help together never slow the sweep below 40% of normal.

If the stable is full, the throw is refused **before** the lasso is taken, with a message to release or store a creature first.

## 4. One-time gifts when the stable is full

A starter, quest reward, clear token or mentor's egg is never lost. If there is no room, the gift is written into a saved "waiting" list in the player's record, the player is told why, and it is granted the moment there is room, in this session or a later one.

A hatched egg with no room stays in its pen until there is room. The stable never goes over its capacity.

## 5. Serial numbers

Only giants at launch (wild-caught gem creatures follow with Dust Canyon). Numbers come from one global counter for each kind, kept outside the player's record. Fetching a number means a short wait on Roblox's data stores, and the player could leave during that wait, so the capture is done in four steps:

1. **On the hit**, with no wait: the capture is written into the player's "waiting" list (a captured giant awaiting its number).
2. The server takes the next number from the global counter. The counter is changed with Roblox's atomic update, so two servers can never be given the same number.
3. **After the wait**, the server checks the player's record is still loaded here and the capture is still waiting. If so, in one step: the giant is added with its number, the giant is marked as captured, the waiting entry is removed, and a save is requested.
4. The number and its owner are written to a registry, only if that number has no owner yet. A number that already has a different owner raises an alarm.

What each failure leaves behind:

| Failure | Result |
| --- | --- |
| The server dies before step 1 is saved | The record goes back to before the fight. The attempt item is back too. Nothing is copied |
| The player leaves, or the server dies, between steps 2 and 3 | The number is skipped for ever. The capture is still in the waiting list, so it is finished with a new number the next time the player joins |
| The server dies after step 3 but before the save | Same as the row above |
| The server dies between steps 3 and 4 | The giant and its number are saved; the registry entry is written when the record is next loaded |

**A number can be skipped but can never be given out twice.** The alternative, never skipping a number, would need the counter and the player's record to change in one step, which Roblox cannot do.

## 6. What can go wrong, and the answer

| Risk | Answer |
| --- | --- |
| Claiming a one-time creature twice (double tap, two requests at once) | The flag is checked and set in the same step that adds the creature, with no wait in between. Where a wait is unavoidable (a giant's number), the claim is re-checked after it. Requests are rate-limited |
| Capturing without fighting, or capturing someone else's creature | The server holds the battle; a throw is only possible inside a live battle the player is in |
| Replaying a winning tap | Each throw has a single-use token; the pattern changes with every throw |
| A script that taps perfectly | It cannot be told apart from a skilled player by timing alone. It only helps on creatures the player already found and weakened. The server logs timing error and flags inhumanly steady accounts for review |
| Second accounts feeding a main account | Giants are bound to the account. Starters, quest rewards and tokens are common creatures of low trade value; trading has its own limits (pack 6) |
| Losing a lasso to lag | A throw is never failed for a late message inside the allowed delay; slow connections get a slowed sweep |
| Faking a slow connection to get an easier throw | The server measures the delay itself and trusts the smallest reading; the slowing has a floor; how often an account gets the help is logged |
| Turning a miss into a free retry | An impossible tap counts as a miss |
| Leaving mid-battle to dodge a loss or win back items | The battle is not saved. Items used stay used, including the giant-attempt item |

## 7. Testing

- Lune: lasso timing (written, 48 passing); the one-time rules, the full-stable rules and the serial rule as pure functions once approved.
- Studio: each way of getting a creature, twice in a row and from two requests at once; a full stable; leaving mid-throw; a giant capture with the server stopped between the steps in section 5.
- Independent exploit review before Gate C.

## 8. What you are approving

- [ ] Every creature is made by the server in one step, with a log line.
- [ ] The seven ways in section 2, with their limits.
- [ ] A full stable blocks a lasso throw before the lasso is spent, holds one-time gifts in a saved waiting list, and leaves a hatched egg in its pen until there is room.
- [ ] An impossible lasso tap counts as a miss.
- [ ] Giants are bound to the account and carry serial numbers, granted by the four steps in section 5; a serial can be skipped but never repeated.
- [ ] A child of a bound creature is itself bound.
- [ ] A leaver's battle is lost and the items used in it stay spent.

Questions that are yours:

1. Starters: can the starter you did not pick ever be obtained (in the wild, by trade, or never)? This decides whether they are collectable or a permanent identity choice.
2. Should the quest and clear-token creatures be species that cannot be caught in the wild, to make them worth having?
