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

Changed after approval (Ayrton, 20 November 2026): **candy is typed**. There is one balance per type. Catching and releasing creatures earn candy of their type, and each parent in a breed needs candy of its own type. Milestone and daily rewards pay **Prism Candy** (working name), which counts as any type. A breed uses typed candy first, then Prism for any shortfall. The numbers below were set by re-running the 30-day economy simulation (`docs/ECONOMY_MODEL.md`).

Candy is earned only by playing. It cannot be bought, traded or gifted. Every source has a cap or falls off within a day, so no amount of grinding or extra accounts turns into unlimited candy.

| Source | Candy | Limit |
| --- | --- | --- |
| Catching a creature | 1 of its type (Uncommon 2, first gem tier 6, Ruby 12, Diamond 24) | Per type per day: the first 3 pay in full, then each pays half the one before, never below a tenth, and nothing from the 40th |
| Releasing a creature | 1 of its type every second release (first gem tier 3, Ruby 6, Diamond 12) | Per type per day, falling off the same way. Always less than catching it, and less than the cheapest breed that could make it |
| The mentor's lesson | 2 Prism | Once per player. Pays for the first breed in the first session |
| Easy daily tasks (win 3 battles, tame a creature, breed once) | 1 Prism each | 3 a day |
| Harder daily tasks (win 30 wild battles, win a giant rematch, win 5 tamer rematches) | 1 Prism each | 3 a day |
| Giant rematch | 1 Prism | 2 a day |
| Weekly challenge | 3 Prism | Once a week |
| First clear of a giant | 5 Prism | Once per giant |
| First clear of a gate | 5 Prism | Once per biome |
| Finishing a biome's quest line | 2, 3, 4 Prism by biome | Once per quest line |
| Ranked season prize | Up to 10 Prism by league | Once per season, after PvP ships |

Daily tasks open with the first badge. The most Prism a player can earn in a day from repeatable sources is 8. A whole day of catching commons of one type pays at most 7 candy of that type.

What each parent uses, of its own type, by its own rarity: 1 (Common), 2 (Uncommon), 5 (first gem tier), 12 (Ruby), 30 (Diamond). A common Leaf with a common Water needs 1 Leaf and 1 Water; a pure gem-tier pair needs 10 of its type.

In the 30-day simulation, after the story:

| Player | Prism a day | Typed candy a day (best type) | Catches a day | Common breeds a day | Days to a gem-tier / Ruby / Diamond child from a pure pair (single-candy model) |
| --- | --- | --- | --- | --- | --- |
| Casual (20 min) | 3.4 | 3.0 (2.0) | 1.9 | 1.8 to 1.9 | 3.7 / 8.8 / 22.1 (3.0 / 7.0 / 17.5) |
| Regular (45 min) | 5.9 | 8.1 (5.1) | 4.7 | 3.3 | 1.8 / 4.4 / 10.9 (1.7 / 4.1 / 10.2) |
| Heavy (2 h) | 8.1 | 19.4 (9.7) | 16.1 | 5.6 to 5.8 | 1.2 / 2.7 / 6.8 (1.2 / 3.0 / 7.5) |

- The first breed still happens at about minute 11, paid by the mentor's 2 Prism.
- A player whose starter is Sand (the only Sand species in Greenwood) makes 3 (casual) or 6 (regular) breeds with a Sand parent in the first two days, mostly paid with Prism.
- An hour of catching and releasing earns about the same candy as an hour of normal play (at most 1.4 times, for the heavy player).

## 4. What can go wrong, and the answer

| Risk | Answer |
| --- | --- |
| Two breed requests at once, to pay once and breed twice | The request never pauses between checking and changing, so the second request sees the first one's changes. Requests are also rate-limited |
| Breeding a creature that is in a trade or a battle | Locks are checked; they live only in server memory |
| A device asks for a charm it does not own, or names a slot that does not exist | The charm is parsed by tested code and must be in the inventory; it is used up in the same step as the payment |
| Re-rolling a child by leaving before the hatch | The child is fixed at the breed and stored in the egg |
| Claiming a candy reward twice | Each source's count is kept in the player's record and checked in the same step that adds the candy. Daily counts reset by the server's date, never the device's |
| Leaving and rejoining to reset the catch and release falloff | The day's catches and releases per type are saved in the profile (`Daily.catches`, `Daily.releases`) and reset only by the server's date |
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
