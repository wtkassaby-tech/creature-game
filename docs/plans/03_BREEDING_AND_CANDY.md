# Approval pack 3: the breeding service and Breeding Candy

Date: 20 November 2026. For: Ayrton. Status: **approved by Ayrton on 20 November 2026**, with Claude's recommended answers (see `DECISIONS.md`). The breeding rules are written and tested; the server flow is written but not wired up, and nothing grants or spends candy yet.

This pack covers the two things that decide how many creatures exist: the act of breeding on the server, and where Breeding Candy comes from. Needed before phase 3 (saving and economy). It depends on pack 1 (saving).

## 1. What already exists

| Piece | State | Where |
| --- | --- | --- |
| The breeding rules: who can breed, cost, odds, the roll, the preview | Tested (31 checks) | `src/shared/Breeding.luau` |
| The server's breed request | Written and type-checked; reviewed once (`docs/REVIEWS.md`); not run in Studio | `src/server/Breeding/BreedingService.luau` |
| Candy sources, caps and prices | In config, simulated over 30 days | `src/config/EconomyConfig.luau`, `docs/ECONOMY_MODEL.md` |

## 2. A breed, step by step

The player's device sends only "breed these two", and optionally "use a Bond Charm on this slot, favouring this parent".

1. The request is rate-limited and its values are checked for type.
2. The server reads its own copy of the player's record. Both creatures must be owned, not in a battle or a trade, on the same body plan, not close relatives, and off cooldown. Giants and cosmic creatures cannot breed.
3. There must be a free pen, enough coins, enough candy, and a Bond Charm if one was asked for.
4. The server rolls the child from a seed it logs. The child is decided now and never re-rolled.
5. In one step, with no pause: coins, candy and the charm are taken; both parents' breed counts and cooldowns are set; the egg, holding the finished child, goes into a pen.
6. The breed is logged with all three creature ids and the seed, so any creature can be traced and any breed replayed.

When the timer ends the egg moves to the stable if there is room, and stays in its pen if there is not. Gems can shorten the timer; they cannot change the child.

## 3. Where Breeding Candy comes from

> **Changed after approval (20 November 2026):** candy is now typed. Catching and releasing creatures earn candy of their type, and each parent in a breed needs candy of its own type. Milestone and daily rewards below pay Prism Candy, which counts as any type. Section 3 is being reworked with new numbers; until then the table below shows the milestone sources only.

Candy is earned only by playing. It cannot be bought, traded or gifted. Every source has a cap, so no amount of grinding or extra accounts turns into unlimited candy.

| Source | Candy | Limit |
| --- | --- | --- |
| The mentor's lesson | 2 | Once per player. Pays for the first breed in the first session |
| Easy daily tasks (win 3 battles, tame a creature, breed once) | 1 each | 3 a day |
| Harder daily tasks (win 30 wild battles, win a giant rematch, win 5 tamer rematches) | 1 each | 3 a day |
| Giant rematch | 1 | 2 a day |
| Weekly challenge | 3 | Once a week |
| First clear of a giant | 5 | Once per giant |
| First clear of a gate | 5 | Once per biome |
| Finishing a biome's quest line | 2, 3, 4 by biome | Once per quest line |
| Ranked season prize | Up to 10 by league | Once per season, after PvP ships |

Daily tasks open with the first badge. The most a player can earn in a day from repeatable sources is 8.

What each breed uses, set by the rarer parent: 1 (Common), 2 (Uncommon), 5 (first gem tier), 12 (Ruby), 30 (Diamond).

In the 30-day simulation a regular player earned about 6 candies a day and a heavy player about 8, with nearly double that in the first week from one-time rewards.

## 4. What can go wrong, and the answer

| Risk | Answer |
| --- | --- |
| Two breed requests at once, to pay once and breed twice | The request never pauses between checking and changing, so the second request sees the first one's changes. Requests are also rate-limited |
| Breeding a creature that is in a trade or a battle | Locks are checked; they live only in server memory |
| A device asks for a charm it does not own, or names a slot that does not exist | The charm is parsed by tested code and must be in the inventory; it is used up in the same step as the payment |
| Re-rolling a child by leaving before the hatch | The child is fixed at the breed and stored in the egg |
| Claiming a candy reward twice | Each source's count is kept in the player's record and checked in the same step that adds the candy. Daily counts reset by the server's date, never the device's |
| Changing the device's clock to reset daily tasks or skip a cooldown | Only the server's clock is used |
| Extra accounts feeding candy to a main account | Candy cannot be traded or gifted. A bred creature can be traded later, so trading has its own limits (pack 6) |
| Gems turning into luck | Gems only shorten a timer or add a pen, up to 4 pens. They never touch the roll |
| A hatch with a full stable | The egg waits in its pen. Nothing is lost and the stable never goes over capacity |

## 5. Testing

- Lune, written: the breeding rules, charm parsing, bound children, costs and odds; candy caps and the no-uncapped-source rule in `tests/economy.test.luau`.
- Lune, to write once approved: claiming each candy source up to and past its cap; the daily reset; a breed refused for each reason in section 2.
- Studio: two breed requests sent together; a breed during a battle; leaving between the breed and the hatch; a hatch into a full stable.
- Independent exploit review of the wired-up service before Gate C.

## 6. What you are approving

- [ ] The breed flow in section 2, with the child decided at the breed.
- [ ] Breeding Candy is earned only, with the sources and caps in section 3.
- [ ] Gems shorten hatch timers and add pens (up to 4), and nothing else.
- [ ] An egg with nowhere to go waits in its pen.

Questions that are yours:

1. Is "breed once" right as an easy daily task? It gives one candy back for spending at least one, which softens the cost of a common breed and nudges players to breed every day.
2. The candy name. "Breeding Candy" is a working name.
3. Should a player see how much candy each source will give before they earn it (a "ways to earn" list on the breeder screen)? I recommend yes: it makes the limit feel like a goal, not a wall.
