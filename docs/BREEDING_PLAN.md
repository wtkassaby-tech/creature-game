# Breeding: how it will work and how it gets built

Date: 16 November 2026
Status: plan. Every rule here is a [Default] under the brief (section 7) unless marked; none changes a [Locked] item. Numbers are starting values for `src/config/`. They include the fixes from an independent stress test (`research/market/09_BREEDING_STRESS_TEST.md`, summarised in section 9).
Built from: `BRIEF.md` sections 4, 7 and 12; `research/market/04_BREEDING_DESIGN.md` (design and supply maths); `research/market/05_CREATURE_TECH.md` (Roblox assembly and art); `research/market/06_TRADING_AND_ECONOMY.md`; `research/market/08_ROBLOX_FACT_CHECK.md`.

**Working code:** `prototype/` holds the rules and maths in real Luau with 29 passing checks, worked examples, the server breed flow and the client assembler. See `prototype/README.md`.

**Is it feasible?** Yes, with one unproven step. The rules, the maths, the server flow and the runtime assembly all use ordinary, documented Roblox features. The unproven step is art: whether Studio's AI mesh generation can produce creature parts that split cleanly and fit together. That is the first thing the prototype tests (section 8, step 2), and there is a fallback.

---

## 1. What the player does

1. **Pick two parents** at the breeder in any hub town. They must share a body plan (four-legged with four-legged, and so on), must not be parent and child or full siblings, and must be off cooldown. There is no limit on how many times a creature can breed.
2. **See the preview before paying.** For each body slot the screen shows the two candidate parts side by side with their chance, the stat each would give, and the moves it brings. It also shows the range of possible stats, the best and worst case as full models, the rarity and colour odds as percentages, the child's level, the coin cost, the hatch time and the cooldown each parent will enter.
3. **Optionally use one Bond Charm** (bought with coins) to tilt one chosen slot from 50/50 to 80/20.
4. **Pay coins and Breeding Candy.** The server decides the child at that moment and puts an egg in a pen.
5. **Wait for the hatch**, or keep playing: eggs hatch in the background and can be collected from anywhere. Gems can speed up the timer. The child is already decided, so Gems never touch the result.
6. **Hatch reveal:** both parents beside the baby, each inherited part highlighted, quality pips shown, and the family tree updated.

The very first breed happens at about minute 10 of a new player's first session: the mentor gives an egg or a free breed that hatches at once (brief section 9: the mentor teaches breeding early).

---

## 2. What a creature carries

```
Creature = {
  id, bodyPlan,
  parts = {                 -- one entry per slot: head, torso, frontLimbs, legs, tail (or wings)
    [slot] = { species, quality },   -- quality 0..10, the only inherited number
  },
  size,                     -- 0.8..1.2, a gene
  colour  = { shown, carried },      -- carried colour can be passed on without showing
  pattern,
  rarity, level, xp,
  moves,                    -- chosen from the parts' move pools
  generation, parents, breedCount, breedReadyAt,
  originBiome,              -- for a bred child: the later of the two parents' biomes
  serial,                   -- wild-caught gem creatures and giants only
  bound,                    -- true if it can never be traded (giants, cosmic creatures)
  originalOwner, createdAt
}
```

Everything else is looked up or worked out, never saved: each species' part base stats, weights and sizes live in `src/shared/Species/`; the type comes from the torso; stats are computed from the parts every time.

---

## 3. Inheritance rules

| What | Rule | Why |
| --- | --- | --- |
| Parts | Each slot comes from one parent at 50/50 (80/20 for one slot with a Bond Charm). The part brings its species, its quality and its moves | [Locked]: "the mother's legs bring the mother's Speed" |
| Quality | Inherited with the part, then may move one pip: up with chance 15% x (10 - q)/10, down with chance 15% x q/10. A 2% rare mutation gives a two-pip jump or a new colour. Always stays within 0-10 | Pulls toward the middle, so stats cannot climb without limit |
| Size | Average of the parents, plus or minus a small step, clamped to 0.9-1.1 | Visible family resemblance |
| Colour | Each creature has a shown and a carried colour. The child takes one of the two from each parent. Rare colours show only when both copies match | [Locked]: rare colours can be bred onto stronger creatures; makes that a multi-generation project |
| Rarity | Roll the higher tier first. Both parents have it: 40% for the first gem tier and Ruby, 30% for Diamond. One parent has it: 10%, 8% and 5%. A failed roll gives Uncommon. Cosmic is never inherited | [Locked]: inherited, and only a chance from one parent |
| Level | 40% of the parents' average, rounded down, never below 1 | [Locked]: much lower than the parents |
| Origin biome | The later parent's biome | Closes the "biome reached" loophole |
| Giants and cosmic creatures | Cannot breed (placeholder for the brief's open item) | Giant parts stay special |

---

## 4. Stats that cannot run away

The brief's two formulas both let stats climb forever when a player always keeps the best child (simulated: +35% in 10 generations from mutation alone; Speed 80 to about 457 in nine breeds through the weight formula). The replacement keeps the same ideas with fixed inputs:

```
partStat  = SPECIES_PART_BASE[species][slot]        -- config, never changes
          x (1 + (quality - 5) x 0.01)              -- quality 0..10 gives -5%..+5%
          x fit                                     -- worked out at assembly, never saved
finalStat = partStat x levelScale x rarityBoost     -- as in the brief

bodyWeight = SPECIES_WEIGHT[torso species] x size
fit (legs, for Speed) = clamp( (SPECIES_WEIGHT[leg species] / bodyWeight) ^ 0.5, 0.6, 1.15 )
fit (other slots)     = 1 at launch
torso Hp and Defence  x size                        -- a bigger body is tougher but heavier

budget     = Hp / 4 + Attack + Defence + Speed      -- of the assembled body at quality 5
if budget > 1.15 x PLAN_BUDGET[body plan] then scale every stat down to fit
```

- Small fast legs on a heavy body are slower; big legs on a light body are quicker. That is the brief's "ratio using size and weight" ([Locked]), but it uses each species' fixed weight, so the same set of parts always gives the same stats however it was bred.
- The brief's worked example (mother's Speed 80 legs on the father's heavy torso) gives 80 x 0.6 = 48. The floor is lower than the brief's 0.7 because the stress test showed a high floor makes "light fast legs on a heavy tank body" nearly free.
- **Shared stat budget:** every assembled body is held to at most 1.15 times its body plan's budget. Without it, taking the best part from each of eight species beat every pure species by 44% and won 96% of test duels. With it, mixing is worth up to 15%, several different builds are competitive, and the best pure species still wins 72%.
- **Size is a trade, not free Speed:** range 0.9-1.1. A bigger body has more Hp and Defence and slower legs.
- The ceiling is automatic: the budget cap x 1.05 (quality) x level x rarity. In the stress test a hardcore player averaged 9.2 of 10 pips after a month, and a perfect creature took 6 to 10 months.
- What still improves across generations ([Locked]: continuous improvement): better part combinations, higher quality pips, rarer tiers, rarer colours and better move sets.

---

## 5. Breeding Candy, costs and supply

**Decided by Ayrton (16 November 2026):** there is no limit on how many times a creature can breed. Every breed uses up **Breeding Candy** (working name), which is earned only by playing. A powerful creature stays worth owning for ever, and the supply of new creatures is capped by play time, not by a counter on the parent.

| Rarer parent | Candy per breed | Coin cost multiplier | Cooldown after each breed (later breeds use the last value) | Hatch time |
| --- | --- | --- | --- | --- |
| Common | 1 | 1 | 30 min, 1 h, 2 h, 4 h, 8 h | 30 min |
| Uncommon | 2 | 1.5 | same | 45 min |
| First gem tier | 5 | 4 | 12 h, 24 h | 4 h |
| Ruby | 12 | 10 | 24 h, 48 h | 8 h |
| Diamond | 30 | 25 | 48 h, 72 h | 12 h |

```
coins = BASE x biomeTier(later-biome parent) x rarityMult(rarer parent)
      x average of COUNT_MULT[breeds already done] for the two parents   -- 1, 1.25, 1.5, 2, 2.5, then stays at 2.5
candy = CANDY_COST[rarer parent]
```

**Where candy comes from** (starting values, all in config):

| Source | Candy | Notes |
| --- | --- | --- |
| Daily tasks (win 3 battles, tame 1 creature, and so on) | 3 a day | The steady income for a 20-minute player |
| First clear of a giant | 5 | Once per giant |
| Giant rematch | 1, up to 2 a day | Rewards preparing and fighting, as the consumables decision intends |
| Gate battle and badge | 5 | Once per biome |
| Quest lines | 2-4 each | Once |
| Ranked season rewards | By rank | Created by the game |
| The mentor's first lesson | Enough for the first breed | So breeding happens in the first session |

**What that means for supply:** a regular player earns about 5 candies a day, a heavy player about 8.

| Child wanted | Candies on average (pure pair) | Days for a regular player |
| --- | --- | --- |
| Common or Uncommon | 1-2 | Several a day |
| First gem tier (40% chance) | 12 | 2-3 |
| Ruby (40%) | 30 | 6 |
| Diamond (30%) | 100 | 20 |

- **Candy rules that keep this honest:** candy cannot be traded or gifted, and is never sold for Robux or Gems. If it could be bought, breeding would stop rewarding play, and paying for candy would be paying toward a random result. Daily sources are capped per account, so extra accounts gain little. Flag for Ayrton: confirm candy is never sold.
- **Coins still apply** ([Locked]: breeding is never free, and the cost is multiplied by rarity). Candy is the supply gate; coins are the sink.
- **Cooldowns stay** to pace play within a day; they no longer carry the job of limiting supply.
- **Pens** still cap eggs in progress: 1 free, a second from a quest, up to 4 in total with Gems, hard cap 4.
- **BASE** is 400 coins, about 4 minutes of biome-1 income, so a casual player can breed about twice a day. The steeper cost curve first proposed left casual players unable to breed until day 4. Never discounted.
- **Creatures leave the game** through release for materials (brief Default). Two more sinks are proposed and need Ayrton's yes as new systems: Radiant fusion (four of one species fuse into one with a cosmetic glow) and move imprint (consume a donor to teach one of its moves).
- **To tune from the first playtest:** candies earned and spent per player per day, and how many gem-tier creatures exist per active player. If rares pile up, raise the candy prices; the earn rates stay generous.

---

## 6. How the server does a breed

All of this runs on the server; the client only sends "breed these two, with or without a charm".

1. Check both creatures belong to the player and are not in a trade, a team lock or already in a pen.
2. Check body plan, kin rule, cooldowns, a free pen, enough coins and enough Breeding Candy.
3. Roll the child with a seeded random generator in the pure module `src/shared/Breeding/` (the same code the tests run).
4. In **one save**: take the coins and candy, raise both parents' breed counts and cooldowns, and write the egg with the finished child inside it. Either all of it is saved or none of it.
5. Log the breed with all three creature ids.
6. At hatch time (or after a Gem speed-up), move the child from the egg to the stable. The roll is never redone.

Because the player's creatures, coins and eggs sit in one saved record, a breed cannot half-complete, and Roblox's own guidance (fact check, row on data stores) is to keep data that changes together in one key.

---

## 7. How a mixed creature is built on screen

- **Parts:** each species is 5 meshes (torso, head, one limb mesh used on both sides, one leg mesh, tail or wing), all low-poly, each ending in a rounded ball that sits inside the torso so seams are hidden at any angle. Parts are prepared templates stored in the game; scripts cannot load a new mesh id at runtime, so the assembler clones templates.
- **Joints:** rigid parts joined by `Motor6D`, one shared set of joint names per body plan. No skinned meshes.
- **Fitting:** each torso socket and each part plug records a radius. A donor part is scaled by (socket radius / plug radius), clamped to 0.6-1.6, so a small species' legs are drawn bigger on a large torso ([Locked]: proportions scaled to look right).
- **Ride height:** the torso is lifted so the feet touch the ground, using the scaled leg length.
- **Colour and rarity:** colour is set per part at runtime; gem tiers are a material, a glow and one particle effect. No extra meshes.
- **Animation:** written in code, one set of clips per body plan (idle, walk, lunge, cast, flinch, faint), driving the joints directly. It adapts to any mix of parts and needs no animation assets.
- **Icons:** each creature's own model rendered in a `ViewportFrame` ([Locked]), kept static and only for cells on screen, with one animated preview.
- **Who builds it:** the server sends the compact creature record; each player's device assembles, reuses and hides models as needed.

---

## 8. Build order

Each step has a pass mark. Steps 1 to 4 are the brief's milestone 2.

| # | Step | Done when |
| --- | --- | --- |
| 1 | (Prototyped in `prototype/`.) Pure breeding module and species data format in `src/shared/`, with the simulation tests: no stat ever passes the ceiling over 50 generations of best-of-8 selection; same parts always give the same stats; random mating keeps average quality between 4.5 and 5.5; rarity odds match config; rare supply levels off | All tests pass under `lune run check` |
| 2 | Part specification and a Studio validation script. Generate two four-legged species with Studio's segmented mesh generation | Parts separate cleanly and pass validation. If not: generate each part alone, or code-built or hand-fixed parts |
| 3 | Assembler and code-driven animation. Build all 32 mixes of the two species and a contact sheet | Ayrton accepts at least 80% of the mixes without hand fixes; idle, walk and lunge look right on all of them |
| 4 | Phone checks: 30 creatures in view; a team screen of 30 icons | 30 frames per second or better on a low-end phone; no hitch opening the screen |
| 5 | Server breed flow, pens, eggs, hatch timers, saving, logs | A breed is all-or-nothing; double requests, breeding during a trade, kin pairs and cooldown skipping are all refused |
| 6 | Preview screen, hatch reveal and family tree | A new tester can explain why a baby got its parts and stats |
| 7 | Tune costs and timers from the first playtest: coins earned against coins spent, breeds per player, spread of child stats | Casual players breed in the first session; nobody reaches a perfect creature in the first month |
| 8 | Independent exploit review before any player touches it (saving and creature creation are involved) | Findings recorded in `docs/REVIEWS.md` and fixed |

Step 5 touches saving, so its plan goes to Ayrton before it is built, as the rules file requires.

---

## 9. Risks and what is still to settle

| Risk | Answer |
| --- | --- |
| AI-generated parts do not split or fit cleanly | Tested first (step 2), with three fallbacks. Thin parts (wings, tails, serpent segments) are the likeliest to need hand or code-built meshes |
| Mixed creatures look wrong | Ball joints, socket-radius scaling and the 32-mix contact sheet before any more art is made |
| One part combination beats everything | A test enumerates every combination per body plan; no hybrid may beat the best pure species by more than about 12% |
| Rare supply inflates and trading loses meaning | Breeding Candy earned only by play, capped daily sources, capped pens, serials only on wild-caught and giant creatures, release and the proposed sinks |
| Breeding feels like a chore | Few, meaningful breeds; a preview before paying; background hatching |
| Paid speed-ups drift toward paying for luck | The child is decided at breed time; Gems only shorten the timer; Bond Charms are coins only |

For Ayrton:

- Radiant fusion and move imprint: yes or no? They are new systems.
- Serials only for wild-caught gem creatures and giants (bred ones show generation and lineage instead): this changes a [Default].
- The winged body plan: wings take the front-limb sockets and the tail is optional?
- Giants cannot breed (the brief's own suggestion): confirm.

**What the stress test changed** (`research/market/09_BREEDING_STRESS_TEST.md`; Opus agent, own simulations on an invented eight-species roster, so treat the absolute numbers as indicative):

| Problem found | Fix now in the plan and the prototype |
| --- | --- |
| One "best part from every species" build beat everything by 44% | Shared stat budget capped at 1.15; fit clamp 0.6-1.15 |
| The size gene gave free Speed | Size also scales torso Hp and Defence; range 0.9-1.1 |
| Gem creatures were 18-34% of all creatures by day 180 | Lower inheritance odds (40/40/30% and 10/8/5%); with Breeding Candy the price per rare child is 12, 30 and 100 candies |
| Costs starved casual players (first breed on day 4) | Base 400 coins and a gentler curve; common eggs hatch in 30 minutes |
| A perfect creature was reachable too easily or never, depending on the mutation rate | Drift 15% with the pull to the middle: 6-10 months for a hardcore player |
| Very low-level parents gave a level-0 child | Level floor of 1 |
| A traded level-60 early-biome creature was 3.2 times the first giant | A level cap per badge: creatures above it fight at the cap. This belongs to the battle rules |

The battle formula now exists in the prototype. Its Speed band and Tempo meter stop a 1% Speed edge deciding mirror fights. Its all-builds tournament shows the three placeholder species are not balanced (best hybrid wins 94%), so each real roster must pass that tournament before its art is made; see `prototype/README.md`. The candy earn rates and the wild gem spawn rate (about 1 in 120 catches for the first gem tier) are guesses to tune from the first playtest.
