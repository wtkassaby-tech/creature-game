# Creature Game - Design Brief

> Snapshot of Ayrton's live doc (revision 6, exported 16 November 2026). If they differ, the live doc wins: https://claude.ai/artifact/SXN85dnsvkAN8jYM9jQpcY. Decisions made since this export are in `DECISIONS.md`.

2026-11-16 · @Ayrton

## 1. How to use this brief

This brief fixes the intent of the game and the decisions Ayrton has made. Everything else is a starting point, and Claude Code should improve on it whenever it finds a better way.

Every item carries one of three labels.

| Label | Meaning | What Claude Code may do |
| --- | --- | --- |
| **[Locked]** | Decided by Ayrton | Build to it. Propose a change if it causes a problem, but do not change it without his OK. |
| **[Default]** | A proposed starting point | Change freely: numbers, formulas, names, architecture, build order. Log what changed and why. |
| **[Open]** | Not decided yet | Pick a sensible placeholder so work is not blocked, and list it for Ayrton to confirm. |

**Freedom to move beyond the plan**

- The pillars in section 2 outrank every detail below them. If a detail fights a pillar, the pillar wins.
- Playtesting outranks the brief. If something reads well here but feels bad in play, change it and say so.
- New ideas are welcome. Small ones (a move effect, a quest, a UI touch) can just be built. Big ones (a new system, anything that changes the economy, anything that touches Robux) get proposed first.
- Keep a `DECISIONS.md` in the repo: one line per change to a Default, and one line per new idea added.
- Section 15 lists what is still open. Ask about those in batches, not one at a time.

**Four guardrails that do not bend**

1. The Roblox policy rules in section 11.
2. The server decides every battle result, bet, trade, capture and breed.
3. Every creature, name, move and capture tool is original.
4. Creatures change hands only through trading, never through a battle result.

## 2. Vision and pillars

A turn-based creature game on Roblox where players tame, battle, breed and trade creatures across eleven biomes, built to be played for years and not as a quick trend grab.

**Pillars**

1. **Breeding is the signature.** Part-based and generational. Every offspring is visibly a mix of its parents, and no other game in the scene does it this way.
2. **Battles are tactical.** Turn-based teams, elemental types, and skill deciding more than luck.
3. **The world has a story.** A rival, a mentor and a cosmic tear, with each story beat teaching a mechanic.
4. **Creatures hold value.** Rarity, serial numbers, breeding costs and coin sinks protect supply, so trading matters.
5. **Built to last.** New biomes, PvP seasons and tournaments extend the game after the story ends.

**Fixed direction**

- **[Locked]** Structure is based on Project Pokemon: route, town, boss, next area, building toward a full team of six. Ayrton grew up loving that game.
- **[Locked]** Only the structure is borrowed. All content is original.
- **[Locked]** Art style is low-poly and chunky.
- **[Locked]** Creature icons are generated automatically, not drawn by hand.
- **[Default]** Mobile-first controls and UI, since most Roblox players are on phones.
- **[Open]** Target audience and launch age tier. See section 11.

## 3. Core loop and progression

Each biome plays as the same six beats, and three longer loops run across all of them.

**The biome loop**

1. **Arrive in the hub town.** Shop, healer, breeder, quest-givers and the teleport building.
2. **Explore the routes.** Wild battles, lasso taming, local tamers, materials for bait and consumables.
3. **Do the town's quests.** These pay coins and guaranteed creatures.
4. **Beat the giant.** Each win gives one hard capture attempt. See section 6.
5. **Win the gate battle.** Usually the rival. This awards the badge and opens the next biome.
6. **Collect the token.** A gift creature for clearing the biome.

**The long loops**

- **Breed** for stronger, rarer and more unusual creatures.
- **Fight other players** on the Circuit for rank and coins.
- **Trade** to finish a team or a collection.

**Team size by biome**

| Biomes | Battle format |
| --- | --- |
| Greenwood, Dust Canyon, Tide Flats | 3v3 |
| Mire, Frostline, Crystal Deep | 4v4 |
| Emberfall, Stormreach, the Arcane biome, Abyss | 5v5 |
| The Hollow | 6v6 |

- **[Locked]** Team size starts at 3 and grows to 6 for later bosses.
- **[Default]** The exact steps in the table above. Team slots unlock with badges.
- **[Locked]** Difficulty and time-to-progress rise each biome, with the curve slowing naturally.
- **[Default]** Each biome takes roughly 1.3 times as long as the one before. Tune from playtest data.
- **[Default]** A creature can only be used in battle if it comes from a biome the player has reached. This stops a traded late-game creature from skipping the early game.

## 4. Creatures

A creature is a set of body parts on a shared body plan, with a type, a level, a rarity and a unique ID. The parts carry the stats, which is what makes breeding work.

**Roster**

- **[Locked]** 15 to 25 biome-specific creatures per biome at full scale.
- **[Default]** Launch with about 8 per biome across the first three biomes, then grow.
- **[Locked]** Greenwood is mostly common creatures, with one or two uncommon ones.

**Stats and levels**

- **[Locked]** Each creature has a level and combat stats including Speed, Attack and Defense.
- **[Default]** Four stats to start: HP, Attack, Defense, Speed. Add a fifth only if battles need it.
- **[Default]** Final stat = the part's base stat, scaled by level, then by rarity boost.
- **[Default]** The level cap rises as biomes are released.

**Body plans and parts**

- **[Default]** Four body plans: four-legged, two-legged, winged, serpent. Each plan has one shared rig with fixed attachment points.
- **[Default]** Part slots: head, torso, front limbs, legs, tail or wings.
- **[Locked]** Parts carry stats. Legs carry Speed, for example.
- **[Default]** Suggested mapping: head and front limbs carry Attack, torso carries HP and Defense, legs carry Speed, tail or wings carry a move or a small bonus.
- **[Default]** Each part also brings one or more moves the creature can learn.

**Elemental types**

- **[Locked]** Creatures have elemental types with strengths and weaknesses.
- **[Default]** Ten types, one native to each biome: Leaf, Sand, Water, Toxic, Frost, Crystal, Fire, Storm, Arcane, Cosmic. The Hollow mixes them all.
- **[Default]** The torso sets the creature's type. Other parts can bring moves of other types.
- **[Default]** Each type is strong against two types and weak against two. Claude Code should draft the chart so that it makes thematic sense and no type dominates.

**Rarity**

| Tier | First appears | Stat boost | How it is obtained |
| --- | --- | --- | --- |
| Common, Uncommon | Greenwood | None | Wild, quests |
| First gem tier (name open) | Dust Canyon | About 5% | Rare wild spawn, breeding |
| Ruby | Crystal Deep | About 10% | Rare wild spawn, breeding |
| Diamond | Abyss | About 15% | Rare wild spawn, breeding |
| Cosmic | After the finale | Open | Cosmic wrap only |

- **[Locked]** Added rarities appear as biomes progress. Ruby starts in Crystal Deep and Diamond in Abyss.
- **[Locked]** Rarities give percentage stat boosts.
- **[Default]** The boost sizes above. Keep them modest so coin-bet battles are decided by play.
- **[Locked]** Cosmic is the top rarity. The only way to get it is a cosmic wrap: one from finishing the story, and more as timed tournament rewards.
- **[Locked]** Rare colour variations exist, including on early-biome creatures, and can be bred onto stronger ones.

**Serial numbers**

- **[Locked]** Serials are for rare creatures only, counted per kind, such as "Ruby Dragon #1".
- **[Default]** Gem-tier creatures, captured giants and cosmic creatures get serials. Giants are numbered in the order players captured them.
- **[Default]** The server assigns serials from a global counter. They can never be changed or reused.

**Icons**

- **[Locked]** Icons are automatic. Use a ViewportFrame to render each creature's live model in the UI, so every bred combination gets a correct icon with no image files.

**Data shape (starting sketch)**

```
Creature = {
  id,            -- unique, server-issued
  bodyPlan,      -- "quad" | "biped" | "winged" | "serpent"
  parts = {      -- one entry per slot
    torso = { species, size, baseStats, colour },
    legs  = { species, size, baseStats, colour },
    ...
  },
  type,          -- from the torso
  moves,         -- chosen from the parts' move pools
  level, xp,
  rarity,        -- "common" ... "cosmic"
  serial,        -- nil unless rare
  generation,    -- 0 for wild-caught
  parents,       -- { idA, idB } or nil
  breedCount,
  originBiome, originalOwner, caughtAt
}
```

## 5. Battle system

Battles are turn-based, team against team, with one creature active per side and skill deciding more than luck.

**Rules**

- **[Locked]** Turn-based battles between teams of creatures.
- **[Default]** One active creature per side. Each turn a player picks one action: use a move, switch creature, use an item, or throw a lasso (wild battles only).
- **[Default]** Speed decides who acts first.
- **[Default]** Each creature knows up to four moves, drawn from its parts.
- **[Default]** A move has a type, a power value and sometimes an effect.
- **[Default]** Keep randomness low in ranked and coin-bet matches: no random misses, small damage variance. Skill-decided results are fairer to bet on and safer under the gambling rule in section 11.

**Status effects, one new idea per biome**

- **[Default]** Mire introduces poison. Frostline introduces freeze or slow. Emberfall introduces burn. Later biomes add more. Players learn the game one mechanic at a time.

**Opponents**

| Opponent | Behaviour |
| --- | --- |
| Wild creatures | Simple, mostly basic attacks |
| Local tamers | Themed to the biome's type, medium difficulty |
| Giants | One huge creature against the player's team, with scripted phases |
| Rival | A full team that grows and changes with the story |
| The entity | The 6v6 finale |

- **[Locked]** Each biome has a giant creature to beat, then a tamer battle to progress.
- **[Default]** Giant fights use phases, such as a stronger attack pattern at half health.

**Healing**

- **[Locked]** Consumables are needed to heal damaged creatures, so repeated giant attempts are not unlimited.
- **[Default]** The town healer is free, so no player can ever be stuck. Field consumables heal on the spot and cost coins or crafted materials. Revives cost more than heals.

**Engineering notes**

- The server runs the battle and sends results to clients. Clients only send chosen actions.
- Write the damage and turn-order maths as pure functions with unit tests, so balance changes are safe.

## 6. Getting creatures

There are several ways to get a creature, with lasso taming as the everyday route and giants as the prestige one.

- **[Locked]** Multiple routes exist. Ayrton likes boss rewards for rare creatures, quests, and a lasso.
- **[Default]** The lasso is a skill mini-game, not a dice roll. This keeps it original and keeps luck out.

| Route | How it works | Status |
| --- | --- | --- |
| Starter | Pick one of three at the start | Default |
| Lasso taming | Weaken a wild creature in battle, then play a timing mini-game to rope it. Lower health gives a bigger target zone. Better lassos cost coins. | Default |
| Quests | A biome's quest line ends in a guaranteed creature | Default |
| Giant capture | Beat the biome's giant, then get one hard lasso attempt. Rematch as often as healing supplies allow. One giant per player. | Locked |
| Clear token | A common creature is gifted for clearing Greenwood. Other biomes give their own token. | Locked for Greenwood, Default for the rest |
| Bait | Craft bait from biome materials to summon a rare spawn. First appears in Tide Flats. | Default |
| Rival's gift | Before the finale the beaten rival gifts a powerful creature and supplies | Locked |
| Breeding | See section 7 | Locked |
| Trading | See section 10 | Locked |

**Rules**

- **[Locked]** Every player can keep fighting a biome's giant until they capture it, but can only ever capture it once.
- **[Default]** Lassos and bait are bought with earned coins only. If they were sold for Robux, the catch chance would count as a paid random item under Roblox rules.

## 7. Breeding system

Breeding combines two parents part by part, so the offspring looks and fights like a real mix of both. It is the game's signature system and the riskiest to build, so prototype it early.

**What Ayrton has decided**

- **[Locked]** The offspring has traits of both parents, with a randomised combination of their parts and stats.
- **[Locked]** Parts are assigned per creature, such as legs, torso and arm size. A part brings its stat with it: the mother's legs bring the mother's Speed.
- **[Locked]** Proportions are scaled so the body looks right. Breeding a big animal with a small one applies a ratio using size and weight.
- **[Locked]** Breeding is generational, giving uniqueness and a continuous cycle of improvement.
- **[Locked]** There are limits on what can breed, within reason, to keep the code manageable.
- **[Locked]** Breeding is never free. The cost is multiplied by rarity to protect the supply of rare creatures.
- **[Locked]** Cross-biome breeding is allowed. A late-biome parent makes it expensive, so it is a choice and not the best default. A player might do it to put a rare early-biome colour onto late-biome stats.
- **[Locked]** Offspring level depends on the parents but is much lower. Parents at level 50 and 45 give roughly level 20.
- **[Locked]** Rarity can be inherited. If only one parent has the rarity, it is a chance.

**Proposed mechanics**

- **[Default] Who can breed:** two creatures on the same body plan. This is the "within reason" limit, and it guarantees parts always fit.
- **[Default] Part selection:** for each slot, take the part from one parent at 50/50.
- **[Default] Mutation:** each inherited part stat shifts by a small random amount, about plus or minus 5%. A rare mutation, about 2%, gives a new colour or a bigger shift.
- **[Default] Why not fully random:** pure chance would remove the skill from breeding. Inheritance plus small variance keeps outcomes surprising while rewarding good parent choices.
- **[Default] Colour and pattern:** inherited separately from stats, so players can chase looks and power independently.
- **[Default] Lineage:** store both parent IDs and a generation number. A family tree screen is a cheap, strong flex.

**Proportion and stat scaling (starting formula)**

```
-- Every species stores, for each part, its size relative to its own torso
ratio[part] = partSize / torsoSize

-- Visual: the child's torso comes from one parent,
-- and every other part is scaled to fit that torso
childPartSize = donor.ratio[part] * child.torsoSize

-- Stats: a part's stat is adjusted for the body it now has to carry
weightFactor = clamp( (donorWeight / childWeight) ^ 0.5, 0.7, 1.3 )
childSpeed   = donorLegSpeed * weightFactor
```

Worked example: a small mother (Speed 80, weight 20) and a big father. The child takes the father's torso and the mother's legs, and weighs 90. The raw factor is (20 / 90) ^ 0.5 = 0.47, which clamps to 0.7, so the child's Speed is 80 x 0.7 = 56. The legs are drawn scaled up to fit the bigger body.

**Level, cost and limits**

- **[Default] Offspring level:** 40% of the parents' average, rounded down. Levels 50 and 45 give level 19.
- **[Default] Cost:** base cost x biome tier of the higher-biome parent x rarity multiplier of the rarer parent. Paid in earned coins.
- **[Default] Rarity inheritance:** high chance when both parents share a tier, low chance when only one has it. Start near 60% and 15% and tune.
- **[Default] Breed count and cooldown:** each creature can breed a limited number of times, with a cooldown between breeds. Cost alone will not hold back rich players.
- **[Default] Stat ceilings:** cap each stat per rarity tier, so generations improve toward a ceiling and do not grow forever. Without this, veterans become unbeatable and coin bets break.
- **[Default] Parents are kept,** not consumed.
- **[Default] Releasing:** players can release unwanted creatures for materials, which removes creatures from the economy.
- **[Default] Timer:** an egg takes time to hatch. Premium currency can speed it up.
- **[Open]** Whether giants can breed. See section 15.

**Engineering notes**

- Build the creature assembler first: given a creature's data, it builds the model from part meshes on the shared rig.
- Simulate thousands of breeds in a test and check the stat and rarity distributions before any player sees the system.

## 8. Biomes and world map

Eleven biomes in a fixed order, each with its own type, giant, hub town and one new idea. Launch with the first three.

| # | Biome | Type | Theme | Introduces |
| --- | --- | --- | --- | --- |
| 1 | Greenwood | Leaf | Starter forest and meadow, mostly common creatures | Battling, the lasso, the rival, the token creature |
| 2 | Dust Canyon | Sand | Desert mesas, fast and fragile creatures | The first rarity tier |
| 3 | Tide Flats | Water | Beaches and rock pools | Bait spawns |
| 4 | Mire | Toxic | Swamp and mangroves | Poison and status effects, 4v4 |
| 5 | Frostline | Frost | Tundra and ice caves, slow and tanky creatures | Freeze or slow |
| 6 | Crystal Deep | Crystal | Glowing caverns | Ruby tier |
| 7 | Emberfall | Fire | Volcano, heavy hitters | Burn, 5v5 |
| 8 | Stormreach | Storm | Sky peaks, winged body plans dominate | First sight of the tear |
| 9 | The Arcane biome (name open) | Arcane | Wizards, trolls and mythical creatures, magic traits, a purple cave-like look | The truth about the mentor |
| 10 | Abyss | Cosmic | Galactic and mythic, focused on finding the Hollow | Diamond tier, the last rival battle |
| 11 | The Hollow | Mixed | Ancient ruins, the endgame | The entity, 6v6 |

- **[Locked]** This lineup and order, as revised by Ayrton.
- **[Locked]** Biome 9 is the nostalgia biome. Ayrton has style references for it and will share them.
- **[Default]** The type names, and which mechanic each biome introduces.
- **[Default]** Each biome favours a stat. Dust Canyon breeds Speed and Frostline breeds Defense, which makes cross-biome breeding a real strategy.

**Map**

- **[Locked]** The map guides players along a path, and the path changes character with each biome.
- **[Locked]** Common areas where players gather, with teleports between certain buildings.
- **[Default]** One hub town per biome holding the shop, healer, breeder, quest-givers, Circuit arena and teleport building.
- **[Default]** Routes between towns hold wild creatures, local tamers and materials. The giant's lair sits off the main path.

**Each biome needs**

1. A hub town and two or three routes.
2. Its creature roster, across at least two body plans so breeding has options.
3. One giant with its own fight design.
4. A gate battle and a badge.
5. A quest line with a creature reward.
6. Its local materials, bait recipe and consumables.

## 9. Story

The story follows a rival who turns dark after losing to you, a mentor hiding a mistake, and an evil entity behind a cosmic tear. Each beat is there to explain a mechanic or raise the stakes of a fight.

**Cast**

| Character | Role |
| --- | --- |
| The player | A new tamer from Greenwood. "Wrangler" is a working title. |
| The rival | One of the first battles. Seen occasionally from then on. |
| The mentor | Seemingly naive. Lies to the player to protect them. |
| The entity | The final boss. A character, and purely evil. |

**The arc Ayrton has decided [Locked]**

1. The rival is one of the first battles the player must take, and he loses.
2. After losing, he begins using dark tactics to progress.
3. The mentor keeps lying to protect the player.
4. The mentor is found out to be the one who accidentally caused the cosmic tear.
5. The boss before the finale is the old rival. He warns the player about what is ahead.
6. Once beaten, he gifts the player one of his powerful creatures and supplies for the journey.
7. The player destroys the entity.
8. Only then does the player learn the rival had consumed something that left him partly controlled by an evil linked to the entity.
9. The rewards include the ability to cosmic wrap one creature.

**Proposed details [Default]**

- **The tear's effects:** whatever leaks from it drives each biome's giant wild and turns some creatures to gemstone. This explains why giants attack and why rarer tiers appear closer to the Hollow.
- **Why breeding matters:** the mentor teaches it early as the way to raise creatures strong enough for what is coming.
- **Foreshadowing:** show the rival finding the thing he consumes soon after his first loss. Give his creatures a dark tint that grows each time he appears.
- **The rival's team tells the story:** ordinary Greenwood creatures at first, then gem-touched ones, then giants taken by force.
- **The mentor's mistake:** a breeding experiment. He chased the perfect bloodline using a fallen star fragment, and it tore the sky open. This ties the main mechanic to the biggest secret.
- **The gift:** the rival's own starter, the one creature he has kept since Greenwood.
- **Varying the gates:** most biomes are gated by the rival. A couple are gated by a local champion, with the rival appearing as a story moment. In one biome the player and rival team up.
- **The sequel seed:** end on one unexplained detail, such as a dark flicker in the gifted creature.

**How the story is told**

- **[Default]** Short, skippable dialogue. Show more than tell: the state of each town, the rival's team, the tint on his creatures.
- **[Locked]** The story should be entertaining in its own right and guide how players play and interact with the game.
- **[Open]** Names for the rival, mentor, entity and the player's title.
- **[Open]** The exact state of the world after the entity falls. See section 15.

## 10. Economy, PvP, coin bets and trading

Players bet coins on battles and move creatures only through trades. Two separate currencies keep that fair and inside Roblox's rules.

**Currencies**

| Currency | How it is earned | What it buys | Can be bet |
| --- | --- | --- | --- |
| Coins | Bosses, battles, quests, releasing creatures | Lassos, consumables, bait, breeding, entry fees | Yes |
| Gems (working name) | Bought with Robux, small amounts from milestones | Cosmetics, breeding slots, hatch speed-ups, storage | Never |

- **[Locked]** Players bet coins on PvP battles.
- **[Locked]** Creatures change hands only through trading.
- **[Default]** Coins are never sold for Robux. If they were, every bet would indirectly be a real-money stake.

**Coin sinks**

Bets and boss rewards create coins, so the game needs steady ways to remove them: breeding costs, lassos, field healing and revives, bait, staked-match entry fees and the house cut on bets. Track coins created against coins removed per day from the first playtest.

**PvP on the Circuit**

| Mode | Stakes | Reward |
| --- | --- | --- |
| Casual | None | Small coin reward from the game |
| Ranked | League points | Seasonal badges and cosmetics |
| Staked | Both players put up coins | Winner takes the pot, less a small house cut |

- **[Default]** Two fixed formats, 3v3 and 6v6, so a new player never faces a full team of six. Bets only happen within the same format.
- **[Default]** Both players confirm the stake before the match. Bet size is capped by league rank.
- **[Default]** Limit repeat bets against the same opponent, and use matchmaking for higher stakes. A thrown match is otherwise a way to move coins between accounts.
- **[Default]** Level-scale or level-cap creatures in ranked and staked play, so time played does not decide every match.

**Trading**

- **[Default]** A two-step confirm screen showing exactly what each side gives, a trade log, and a short hold for brand-new accounts.
- **[Default]** Trades are atomic on the server: both sides complete or neither does. This is the main defence against duplication.
- **[Default]** A traded creature still obeys the "only up to the biome you have reached" rule from section 3.
- **[Open]** Whether giants and cosmic creatures can be traded.

**Tournaments**

- **[Locked]** Timed community tournaments with set rewards, which can include a cosmic wrap.
- **[Default]** Prizes are created by the game, never taken from other players. Label tournament wraps, such as "Season 1 Champion", and keep the numbers tiny.

## 11. Monetisation and Roblox policy guardrails

Sell convenience, capacity and looks, never battle power or random outcomes. The rules below were checked on 16 November 2026 and must be re-checked before launch, because Roblox changed them several times this year.

**Monetisation [Default]**

- **Game passes:** extra creature storage, an extra breeding slot, faster egg hatching, a cosmetic trail or aura pack.
- **Gems:** hatch speed-ups, breeding slots, cosmetics, lasso and town-home skins.
- **Limited-time event items:** cosmetic only.
- **Not for sale:** coins, stat boosts, rarity, serial numbers, cosmic wraps, or anything with a random result.
- Have the passes in place from the first public version, and put a gameplay trailer on the store page.

**Publishing**

| Audience | What it takes |
| --- | --- |
| Ages 16 and over | An age-checked account in good standing. No fee, no two-factor requirement, no evaluation period. |
| All ages | Government ID check, two-factor authentication, and either a refundable 1,000 Robux fee per game or two consecutive months of Roblox Plus or Premium. The game is then released to age-checked players 16 and over first, and must reach 250 unique plays from highly engaged players within 60 days. |

- **[Default]** Soft-launch to 16 and over. It is free, and the older audience suits coin bets and trading.
- **[Open]** Whether and when to go for all ages.
- Creators generally keep about 70% of Robux spent inside their game.

**The gambling rule**

Roblox's Community Standards do not allow real money, Robux or in-game items of value to be exchanged in connection with gambling. Coin bets on battles are a grey area, so the design keeps them defensible:

1. Only earned coins can be bet, never Gems or anything bought with Robux.
2. Battle results are decided by skill, with low randomness in staked matches.
3. Creatures and items are never staked.
4. Build staked matches behind a feature flag, so they can be switched off without a new release.
5. Re-read the policy before the feature ships.

**The paid random items rule**

Any random item bought with Robux, or with currency that Robux can buy, must show every possible outcome and the real odds. The design avoids this by keeping breeding, lassos and bait on earned coins. If a paid random feature is ever added, it needs an odds display and a region check.

**Original content**

Borrow the genre's structure only. No creature, name, move, item or capture tool may resemble another franchise's.

**Sources**

- [Roblox Creator Docs: Kids and Select publishing requirements](https://create.roblox.com/docs/production/publishing/kids-and-select)
- [Roblox Creator Docs: Publish games and places](https://create.roblox.com/docs/production/publishing/publish-games-and-places)
- [Roblox Community Standards](https://about.roblox.com/en-nz/community-standards)
- [Roblox Creator Docs: Paid random items](https://create.roblox.com/docs/en-us/production/monetization/paid-random-items)
- [Game-Ace: Roblox game costs and revenue share](https://game-ace.com/blog/how-much-does-it-cost-to-make-a-roblox-game/)

## 12. Technical architecture and art pipeline

Creatures are data that the game assembles into models at runtime, and the server owns every result that has value. All of this section is **[Default]**: Claude Code should check current Roblox documentation and choose better tools where they exist.

**Toolchain**

- Roblox Studio, with Rojo syncing Luau source files from the repo.
- Claude Code working in the repo, with the Roblox Studio MCP server for building, viewing and testing in Studio.
- A `CLAUDE.md` that links Roblox's official docs, this brief and `DECISIONS.md`.

**Suggested structure**

```
src/
  shared/      -- data definitions, pure maths (damage, breeding, scaling)
    Species/   -- one data file per species: parts, ratios, stats, moves
    Types/     -- type chart
  server/
    Battle/    -- battle state machine, AI
    Breeding/  -- inheritance, costs, limits
    Creatures/ -- creation, serial counters, ownership
    Economy/   -- coins, bets, shops
    Trading/   -- atomic trades, logs
    Data/      -- player saves
    World/     -- spawns, quests, giants, story flags
  client/
    UI/        -- battle, team, breeder, trade, Circuit
    Assembler/ -- builds a creature model from its data
    Icons/     -- ViewportFrame rendering
tests/         -- unit tests and breed simulations
```

**Rules for anything with value**

- The client sends intent only. The server validates and decides.
- Player saves use session locking so one account cannot load in two servers and duplicate creatures.
- Serial counters are global and updated atomically.
- Log every trade, bet, breed and capture with creature IDs.
- Save data is versioned from day one, because the creature format will change.

**Art pipeline**

- Write a part specification before making any art: scale, pivot points, attachment points and polygon budget per slot and body plan. Every part must meet it, or mixed offspring will not fit together.
- Low-poly, chunky parts with flat colours. This style hides seams between parts from different species.
- Colour is applied at runtime, so colour variants and gem tiers need no extra meshes. Gem tiers and the cosmic wrap are materials and effects on top.
- Build two species on one body plan first and breed them. Only scale up art once that looks right.
- **[Open]** Whether every asset must be AI-generated, as on the golf game.

**Measure from the first playtest**

- Session length, day-1 and day-7 return rate.
- Where players drop out in the first 15 minutes.
- Coins created against coins removed.
- Breeds per player, and the spread of offspring stats.

## 13. Build plan and milestones

Build a small vertical slice first, prove breeding early, and soft-launch three biomes before building the rest. The order is **[Default]** and Claude Code may reorder it if a dependency or a playtest result says so.

**Before Ayrton flies (late November 2026)**

- [ ] Roblox account: two-factor authentication on, ID check done
- [ ] Start Roblox Plus if skipping the 1,000 Robux fee later, since it needs two months to count
- [ ] Full toolchain working on the travel laptop: Studio, Rojo, Claude Code, Studio MCP
- [ ] Repo created with `CLAUDE.md`, this brief and an empty `DECISIONS.md`
- [ ] Answer the open decisions in section 15 that block the first milestones

**Milestones**

| # | Milestone | Done when | Rough timing |
| --- | --- | --- | --- |
| 1 | Battle core | Two teams of three can fight a full turn-based battle on mobile, with types and switching, run by the server | Vietnam week 1 |
| 2 | Creature assembler and breeding prototype | Two species on one body plan breed into offspring that look right, with stats following parts | Vietnam week 1 to 2 |
| 3 | Greenwood slice | A player can start, tame with the lasso, beat the giant, beat the rival and earn the badge | Vietnam week 2 |
| 4 | Progression and economy | Coins, shop, healer, consumables, quests and saving all work | Vietnam week 3 |
| 5 | Dust Canyon and Tide Flats | Three biomes playable end to end, with the first rarity tier, serials and bait | Vietnam week 3 to 4 |
| 6 | Polish and store page | Art pass, UI, sound, icons, trailer, thumbnails | Vietnam week 4 |
| 7 | Soft launch, ages 16 and over | Public, with passes live and analytics running | End of the trip or early January 2027 |
| 8 | PvP | Casual and ranked on the Circuit in 3v3 | January 2027 |
| 9 | Trading | Atomic trades with confirm screen and logs | After PvP |
| 10 | Staked matches | Coin bets live behind a feature flag, after a policy re-check | After trading |
| 11 | Biomes 4 to 11 | One biome per update, story advancing with each | 2027 |

**Notes**

- Milestone 2 is the biggest technical risk. If it struggles, simplify the part system before building more content on top of it.
- Study days in Vietnam will cut into build time. Milestone 6 is the buffer.
- Do not start the 60-day all-ages evaluation until the soft launch shows players coming back.
- Fellow students on the trip are ready-made multiplayer testers.

## 14. Roadmap after launch

The game grows in three stages, and each later stage only happens if the one before it earns it.

| Stage | Trigger | What it adds |
| --- | --- | --- |
| 1. The launch story | Now | Eleven biomes, ending with the entity as the climax. One cosmic wrap per player who finishes. |
| 2. The hardcore game | A dedicated following forms | Ranked PvP seasons, challenge bosses beyond the final biome, timed community tournaments with rewards. |
| 3. The big update | Later | The dormant evil in the rival reawakens. He tries to reopen the cosmic tear, bringing new battles, biomes and creatures. |

- **[Locked]** All three stages, and the entity as the climax of stage 1.
- **[Locked]** Stage 3 is a friend turned rival turned friend, turned threat again.
- **[Default]** Build systems so stage 2 and 3 slot in without rewrites: biomes, types, rarity tiers and story chapters should all be data, not hard-coded.

## 15. Open decisions

These are Ayrton's to make. Claude Code should use the suggested placeholder until he answers.

- [ ] **Game name.** Placeholder: "Creature Game".
- [ ] **Names** for the rival, the mentor, the entity, the player's title and biome 9. Placeholder: role names.
- [ ] **Can giants be traded?** Suggested: yes, with the biome-reached rule, since low serials make great trade items.
- [ ] **Can giants breed?** Suggested: no, so giant parts stay special.
- [ ] **Can cosmic creatures be traded?** Suggested: story wraps no, tournament wraps yes.
- [ ] **Does the cosmic wrap boost stats or is it cosmetic?** Suggested: cosmetic with a small boost at most.
- [ ] **Name of the first rarity tier** that appears in Dust Canyon.
- [ ] **The world after the entity falls.** The brief assumes it returns to peace. Confirm.
- [ ] **Launch audience.** Suggested: soft-launch to ages 16 and over, decide on all ages from the data.
- [ ] **Starter creatures.** Suggested: a choice of three.
- [ ] **Asset rule.** Must every asset be AI-generated, as on the golf game?
- [ ] **Style references for biome 9.** Ayrton to share.
- [ ] **Monetisation list** in section 11. Approve or adjust.
