# Approval pack 6: the challenge board and move imprint

Date: 22 November 2026. For: Ayrton. Status: **draft, waiting for your yes.** Both touch saving and rewards, so the project rules say they need your approval before they are built. You already said yes to the ideas (decisions pack, items 3, 4 and 10); this pack sets the details.

## 1. The challenge board

Your idea: "a place with challenges like catch 4 of this creature and trade it in in exchange for x", refreshed daily so players come back, and a way to earn Giant Candy.

**Where.** A Challenge Master stands in every hub town, next to the healer. Every hub shows the same board.

**What is on it.**

| Board | Refreshes | Example | Reward (suggested) |
| --- | --- | --- | --- |
| 3 daily challenges | Every day at midnight UTC | "Bring me 4 Fenwhisk"; "Bring me a Sand creature at level 20 or above"; "Bring me a creature with a Leaf head" | Coins (about 1.5 times what the catches cost), plus 1 Prism Candy each. The third also gives 1 Giant Candy |
| 1 weekly challenge | Every Monday | "Bring me 3 creatures with at least 120 Hp"; "Bring me a gem-tier creature" | 3 Prism Candy (the weekly source already in the economy), 3 Giant Candy and materials |

- **Fair to everyone:** challenges only ask for creatures from biomes the player has reached. Players at the same stage of the story see the same board on the same day, so they can talk about it.
- **Handed-in creatures are used up.** That is the point: it gives common creatures a use and gives rare ones a reason to be bred. It also does what Radiant fusion was meant to do (take creatures out of the game) without being a new system.
- **Safe by design.** A creature on the team, in a battle, in a breeding pen, a giant, or one with a serial number is never accepted unless the challenge asks for that kind. The server checks every hand-in, and the player confirms before anything is used up. Each challenge pays once per day (or week).
- **Giant Candy:** today 1 a giant win, at most 2 a day, so a giant breed every 5 days or so. With the board (1 a day plus 3 a week), it is about every 3 days for a daily player.

## 2. Move imprint

**What it does.** At the breeder, a player gives up one creature (the donor) to teach one of its moves to another creature (the learner).

- The learner must have the same body plan (four legs or two legs).
- The move must be one the donor knows at its level. The learner must be at least the level at which that move unlocks.
- Each creature has **one imprint slot**. A new imprint replaces the old one.
- Stats never change; only the move list does. The imprinted move is **not** passed on to children, so breeding stays the way to make a creature's own moves.
- The donor is used up. Giants and creatures with a serial number cannot be donors.
- **Cost:** suggested 100 coins, times the biome price multiplier of the move's home biome.

**Saving.** Each creature record gains one optional field, the imprinted move. That is a save-format change, so it ships with a version bump, a migration and a test, as every save change does.

## 3. Radiant fusion

Not built (you were unsure). The challenge board already gives creatures a way out of the game; we can look at fusion again after launch.

## 4. Questions that are yours

1. **Board size:** 3 daily challenges and 1 weekly. More, or fewer?
2. **Rewards:** coins about 1.5 times the catch cost, 1 Prism Candy each, 1 Giant Candy on the third daily and 3 on the weekly. Stingier, or more generous?
3. **Team creatures:** never accepted (my suggestion, so nobody loses a favourite by accident), or accepted after a warning?
4. **Imprint cost:** 100 coins times the biome multiplier. Fine?
5. **Imprint slots:** one per creature. Or two?

When you answer, I build both with tests, run an independent exploit review (hand-ins and imprints destroy and change creatures, so duplication and lost-creature bugs are the risk), and record it in `docs/REVIEWS.md`.
