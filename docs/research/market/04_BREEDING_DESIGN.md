# Breeding: how to make it work as a game system and an economy

Date: 16 November 2026
Status: research, nothing decided

## Summary

- The brief's two stat rules both ratchet. A ±5% multiplicative mutation with a breeder keeping the best of four offspring gives about +35% after 10 generations and +81% after 20 (my simulation). The weight-factor formula, if its result is stored on the part, can be walked "downhill" through ever lighter bodies for ×1.3 a step and then jumped back up for a single ×0.7: Speed 80 becomes about 457 in nine breeds.
- Both are fixed by one principle: **a part's inherited value is a bounded gene, and everything else is derived at assembly time from fixed species data, never stored.** Pokémon (IVs 0-31), Temtem (SVs 1-50) and Palworld (IVs 0-100) all bound inheritance this way; ARK, which adds mutations on top without a hard bound, is the standard power-creep example.
- Axie Infinity is the closest precedent for parts carrying abilities. Its gene design (one dominant and two hidden recessive genes per part) was liked; its economy failed because parents were kept, each could breed 7 times, and demand for offspring came only from new players. Sky Mavis now talks of a surplus of about 12 million Axies and of burning them.
- Supply maths: a rare creature's "reproduction number" is roughly (breed limit ÷ 2) × rarity inheritance chance. The brief's 60% with a limit of 7 gives 2.1 (exponential). It must stay below 1: limit 3 at 50%, or limit 2 at 60%.
- Cooldowns alone do not bound supply (one breed per pair per day is ×190,000 a month in theory). Breed-count limits, breeding pens (capacity) and sinks that consume creatures do.
- What players enjoy: visible genes, a preview of possible offspring, deterministic rules they can plan around, items that steer inheritance. What they hate: hidden values, waiting for eggs with nothing to do, and mass-hatching to discard.
- Source limit: this session could search but not open pages (every host failed to resolve), so **all external facts below are "snippet" confidence**. The simulations are my own and reproducible.

## 1. Method and limits

WebFetch failed for every host tried (whitepaper.axieinfinity.com, support.axieinfinity.com, guide.cryptokitties.co, theblock.co, decrypt.co, afkgaming.com, en.wikipedia.org, bulbapedia.bulbagarden.net, palworld.wiki.gg). I stopped after that, as instructed, and relied on search-result summaries. Those hosts need allowing in the session's network settings before the numbers can be upgraded to "sourced". Thin or unverified: Horse Life, Wild Horse Islands, Creatures of Sonaria, Dragon City and Monster Legends (search returned only low-quality pages), and Dragon Quest Monsters' rank rules.

Confidence labels: **snippet** = search result only; **inference** = my reasoning; **simulation** = my own Python run (scripts were temporary; the tests in section 8 should reproduce them in Lune).

## 2. Precedents

### 2.1 Axie Infinity (closest precedent)

| Item | Finding | Source | Confidence |
| --- | --- | --- | --- |
| Genes | Each of 6 body parts has three genes: dominant (D), recessive 1 (R1), recessive 2 (R2). Chance each is passed on: D 37.5%, R1 9.375%, R2 3.125% per parent | https://whitepaper.axieinfinity.com/gameplay/breeding ; https://afkgaming.com/blockchaingames/guide/everything-you-need-to-know-about-axie-infinity-breeding | snippet |
| Parts and battle | Each part is a battle card (ability); class comes from the body. A "pure" Axie has all parts of its class | same | snippet |
| Breed limit | 7 breeds per Axie, then sterile. Siblings and parent-child pairs cannot breed | https://support.axieinfinity.com/hc/en-us/articles/7225771030555 | snippet |
| Cost curve | SLP per parent by breed count: 900, 1,350, 2,250, 3,600, 5,850, 9,450, 15,300 (multipliers 1, 1.5, 2.5, 4, 6.5, 10.5, 17), plus a flat AXS fee | same | snippet |
| Cost changes | AXS fee cut 4 to 2 to 1 to 0.5 across 2021; SLP cost rebalanced Sept 2021 and tripled Dec 2021 | https://clutchpoints.com/axie-infinity-new-breeding-costs ; https://www.fxstreet.com/cryptocurrencies/news/axie-infinity-cuts-breeding-fees-while-axs-price-struggles-202109240955 | snippet |
| Mint vs burn | Early 2022: more than 4× as much SLP created daily as burned by breeding. About 40% of SLP came from adventure mode. Season 20 (Feb 2022) removed adventure and daily-quest SLP | https://decrypt.co/92190/axie-infinity-making-big-changes-to-fix-its-ailing-play-to-earn-nft-economy | snippet |
| Supply vs demand | Mid-2021: more Axies bred than sold every day for two months running. Naavik: revenue depended on the pace of new players, not the total | https://dappradar.com/blog/the-rise-of-axie-infinity-special-report ; https://naavik.co/deep-dives/axie-infinity/ | snippet |
| Outcome | SLP down more than 99% from its 2021 peak; supply capped in 2024 | https://decrypt.co/212564/axie-infinity-caps-slp-token-supply-revitalize-play-earn-game | snippet |
| Sinks added later | "Releasing" (burn an Axie for rewards); team discussing "aggressive burn mechanics" for a surplus of about 12 million Axies (2025-26) | https://www.gfinityesports.com/article/axie-infinity-releasing-burn-nft ; https://blog.axieinfinity.com/p/lunacian-lounge-episode-2-recap | snippet |

What this means (inference):

1. Seven breeds with parents kept is a ×3.5 population multiplier per generation. Nothing consumed Axies until Releasing arrived, years late.
2. Breeding was the only sink for the earn currency, and the product of breeding was only wanted by newcomers. When sign-ups slowed, both collapsed together.
3. Cutting the breeding fee to help new players made oversupply worse. A cost in a currency that is inflating stops being a brake.
4. The hidden recessive genes created real skill (reading genes, breeding "pure" lines) but needed third-party tools to see. They worked because parts were discrete abilities, not numbers.

Our game differs in the ways that matter: coins are never sold and creatures have no cash value, so there is no earn-and-cash-out pressure. The supply lesson still applies to trade value.

### 2.2 Other games

| Game | What is inherited | How randomness is bounded | Parents consumed? | Limits and costs | Liked / hated | Source (all snippet) |
| --- | --- | --- | --- | --- | --- | --- |
| CryptoKitties | 48 genes, visible "cattributes" | Fixed gene set; cosmetic only | No | Cooldown grows with every breed: 1 min up to 1 week (fast, swift, snappy, brisk, plodding, slow, sluggish, catatonic); later generations start slower. Gen 0 capped at 50,000 | Median price fell about $41 to $5 by June 2018; about 700,000 listed against 4,200 sold in a week. A 2021 study blames oversupply first | https://guide.cryptokitties.co/guide/cat-features/cooldown-speed ; https://fortune.com/crypto/2018/06/18/cryptokitties/ ; https://www.frontiersin.org/articles/10.3389/fphy.2021.631665/pdf |
| Pokémon | 3 of 6 IVs from parents (5 with Destiny Knot); nature via Everstone; Power items force one named IV | IVs 0-31, hard range | No | No breed limit or cost; time to hatch only | Deep and plannable; also called "one of the most tedious" features; players disliked being stuck waiting at the Scarlet/Violet picnic | https://pokemondb.net/mechanics/breeding ; https://www.bulbagarden.net/threads/pokemon-breeding-how-often-do-you-use-this-feature.310833/latest ; https://charlieintel.com/pokemon/pokemon-scarlet-violet-players-long-for-key-breeding-feature-in-dlc-293638 |
| Temtem | SVs (1-50); DNA Strand items guarantee one SV; traits and egg techniques | SV range | No | **Fertility:** max 8, each breed costs 1, cannot be restored; the child inherits the lower parent's remaining value; wild Temtem with high SVs start lower (7 or 6) | Finite lineages keep perfect Temtem scarce | https://windowscentral.com/how-breed-temtem ; https://progameguides.com/temtem/how-to-breed-a-perfect-temtem/ |
| Palworld | Species is deterministic: child = species nearest floor((rankA + rankB + 1) / 2), plus fixed special recipes. Passives drawn from parents' pool; IVs about 30% from each parent, 40% fresh | IV range; passive slots capped at 4 | No | One cake per egg; time | Community calculators thrive because species is computed, not rolled | https://palpedia.com/guides/breeding ; https://www.gameserverkings.com/knowledge-base/palworld/palworld-breeding-guide/ |
| ARK | Each stat taken from one parent (higher favoured about 55%); 2.5% mutation rolls add +2 levels to a stat and a colour change | Mutation counter cuts odds past 20 per side, but "clean female" lines dodge it, so stacking is effectively unbounded | No | Long timers | The textbook ratchet: mutation stacking defines endgame power | https://ark.wiki.gg/wiki/Mutations |
| Monster Hunter Stories 2 | Rite of Channeling moves one gene from a donor into a 3×3 grid; three in a line gives a "bingo" bonus | 9 slots | **Donor is destroyed** | Unlocked mid-story | Strong, readable sink; grid makes planning visual | https://www.windowscentral.com/monster-hunter-stories-2-rite-channeling-guide ; https://www.pcgamer.com/monster-hunter-stories-2-gene-rainbow-rite-of-channeling |
| Dragon Quest Monsters: The Dark Prince | Child takes chosen talents from the combined pool and half the parents' skill points | Player picks; level resets | **Both parents consumed** | Level requirement (about 10) | Synthesis is the progression loop, so no surplus builds up | https://samurai-gamers.com/dragon-quest-monsters-the-dark-prince/synthesis-guide/ |
| Adopt Me | Not breeding: 4 identical full-grown pets fuse into 1 Neon; 4 Neons into 1 Mega Neon (16 pets) | Deterministic | **Yes, 4 to 1** | Ageing time | Neon about 6-7× and Mega about 25-30× base trade value for top pets: fusion creates value while destroying supply | https://www.adoptmevalues.app/blog/neon-and-mega-neon-pets-explained ; https://rowatcher.com/news/adopt-me-trading-values-in-2026-pet-economics-rising-legendaries-scam-prevention |
| Dragon Adventures (Roblox) | Colours, materials, element, pupil, personality, mutations, traits. 33% chance of a non-basic element from the parents' elements | Max 4 of 5 mutations by breeding | No | Baby and both parents go on cooldown; per-species cooldowns from 45 min to 7 days | Cosmetic breeding (colour and mutation chasing) drives its trading | https://dragon-adventures.fandom.com/wiki/Breeding ; https://dragon-adventures.fandom.com/wiki/Mutations |
| Niche | Two alleles per gene, one from each parent; dominant shows, recessive is carried | Fixed gene list | No | Lifespan; inbreeding harms immunity | Teaches real genetics; carried genes are shown in the UI | https://niche.fandom.com/wiki/Genes |
| Spore | Not breeding. Parts give abilities, and duplicate parts do not add up: only the best part of a kind counts | Non-stacking | n/a | Part budget | Freedom of looks without stat stacking | https://spore.fandom.com/wiki/Creature_Creator |
| Dragon City / Monster Legends | Species by parent recipe; rarity by hidden odds | Recipes | No | Timers up to 24-60 hours for legendaries, sold as speed-ups | Timers are the monetisation; little skill | no reliable source found |
| Horse Life, Wild Horse Islands, Creatures of Sonaria | Coat and trait inheritance; details not found | Not verified | No | Not verified | Not verified | no reliable source found |

### 2.3 Patterns

- **Bounded genes everywhere it works.** Every stat-breeding game that has stayed balanced uses a hard range (0-31, 1-50, 0-100). The one with additive mutations and a soft cap (ARK) is defined by power creep. (inference from the table)
- **Three ways supply is held:** consume parents (DQM, MHS2, Adopt Me fusion), a finite fertility budget (Temtem, Axie's 7), or no trading value at stake (Pokémon). Cooldown-only games (CryptoKitties) inflated.
- **Skill comes from control, not luck:** Destiny Knot, Power items, DNA Strands and Palworld's computed species let players plan several steps ahead. Hidden recessives add depth only when the game shows them.
- **Chore signals:** hatching many eggs to throw away, waiting with nothing to do, values the game hides so players need outside calculators.

## 3. Why the brief's formulas ratchet (simulation)

**Mutation.** Brief: each inherited part stat shifts by about ±5%, applied to the parent's value. With no selection the average stays at 100. Players select.

| Offspring kept from | After 5 gens | 10 gens | 20 gens | 40 gens |
| --- | --- | --- | --- | --- |
| 1 (no choice) | 100 | 100 | 100 | 99 |
| best of 2 | 108 | 119 | 138 | 195 |
| best of 4 | 116 | 135 | 181 | 326 |
| best of 8 | 121 | 146 | 214 | 462 |

(simulation, 400 trials, stat starts at 100.) The brief's stat ceiling stops the climb, but then every serious player sits on the cap and the ceiling is the only number that matters. A bounded gene is cleaner than an unbounded walk plus a wall.

**Weight factor.** Brief: `childSpeed = donorLegSpeed × clamp((donorWeight / childWeight)^0.5, 0.7, 1.3)`. Two faults:

1. If `childSpeed` is stored on the child's legs, the factor compounds across generations.
2. The clamp makes it path-dependent. Without the clamp the factors telescope (the total depends only on first and last weight). With it, many small steps down each earn up to ×1.3 while one big step back up costs only ×0.7.

Simulation: legs with Speed 80 on a 500-weight body, moved through 8 bodies each 1.69× lighter, reach Speed 653; one breed back onto the 500-weight body gives 457. Repeatable without limit. (simulation)

## 4. Supply maths

Let B = breed limit per creature, p = chance a rare × rare pair gives a rare child. Each breed uses one slot from each parent, so each rare creature yields B/2 children and **R = (B/2) × p** rare children. One wild-caught rare ends up as 1 / (1 − R) rares in total if R < 1, and grows without limit if R ≥ 1. (inference)

| B | p (both parents rare) | R | Rares per wild-caught founder |
| --- | --- | --- | --- |
| 7 | 60% | 2.10 | unbounded |
| 5 | 60% | 1.50 | unbounded |
| 4 | 50% | 1.00 | unbounded (linear) |
| 3 | 60% | 0.90 | 10 |
| 3 | 50% | 0.75 | 4 |
| 3 | 40% | 0.60 | 2.5 |
| 2 | 60% | 0.60 | 2.5 |

Rare × common pairs at 15% use only the rare's slots: R = B × 0.15, which is 0.45 at B = 3. Pure pairs are always the better use of a slot, so the pure figure is the one to control.

Other levers:

- **Cooldown only:** if every pair breeds once per cooldown the population grows ×1.5 per cooldown: ×190,000 in 30 days at 1 day, ×438 at 2 days, ×58 at 3 days. A cooldown paces play; it does not cap supply. (simulation)
- **Temtem-style fertility** (child's limit = lower parent's remaining): two founders with 3, 4, 5, 6, 8 breeds give at most about 4, 7, 12, 19, 45 descendants ever. A hard, finite lineage. (simulation, greedy pairing, not a proven maximum)
- **Pens:** with S breeding pens and hatch time H, a player makes at most S ÷ H creatures a day whatever else is true. This is the real rate limit, and Gems selling extra pens (DECISIONS.md) must have a hard cap.
- **Sinks:** release, fusion and donor consumption remove creatures. The target is that for gem tiers, creatures removed per day approaches creatures created per day once the game is mature.

## 5. What makes it readable and skilful, or a chore

| Do | Why | Precedent |
| --- | --- | --- |
| Show every gene on the creature card | No outside calculator needed | Niche; Axie's hidden genes needed third-party tools |
| Preview offspring before paying: each slot's two candidate parts side by side, stat ranges, rarity odds as percentages, cost, hatch time | Parent choice becomes a decision | Palworld calculators, Pokémon planning |
| Let players steer one thing per breed with an earned item | Planning beats re-rolling | Destiny Knot, Power items, DNA Strands |
| Family tree with serials and original owner | Cheap flex; provenance adds trade value | Brief section 7 |
| Hatch in the background, collect from anywhere | Waiting was the main Scarlet/Violet complaint | charlieintel.com link above |
| Few, meaningful breeds (breed limits) | Mass-hatching to discard is the chore | Pokémon box-hatching |

## 6. Recommended rule set

Numbers are starting values for `src/config/`. "Keeps Locked" means the rule fits the brief's [Locked] line as written.

### 6.1 Inheritance

| Rule | Recommendation | Brief status |
| --- | --- | --- |
| Who can breed | Same body plan; not parent with child, not full siblings (check `parents`); not giants or cosmics (placeholder for the open item) | Keeps Locked "limits within reason"; kin rule is new |
| Part selection | Each slot from one parent at 50/50 | Keeps Locked and Default |
| Steering | One "Bond Charm" per breed (coins, earned) raises one chosen slot to 80/20. Never sold for Robux or Gems: it would be paying to change a random result | New idea; keeps section 11 guardrail |
| Dominant/recessive for parts and stats | **No.** Parts are visible and what you see is what can pass on | Keeps Default |
| Colour and pattern | **Yes, one carried gene.** Each creature has a shown colour and a carried colour. The child takes one of the two from each parent; rare colours are recessive, so they show only when both copies match. The card shows both | Keeps Locked "rare colours can be bred onto stronger ones"; extends Default "colour inherited separately" |
| Level | 40% of the parents' average, rounded down | Keeps Locked and Default |

### 6.2 Stats that cannot ratchet

Replace "the part's base stat" as a free number with three fixed layers:

```
partStat = SPECIES_PART_BASE[species][slot]          -- config, never changes
         × (1 + (quality − 5) × 0.01)                -- quality gene 0..10 = −5%..+5%
         × fit(slot, part species, body)             -- derived, never stored
finalStat = partStat × levelScale × rarityBoost      -- as the brief
```

- **Quality** is the only inherited number: an integer 0 to 10 per part, shown as pips. Wild creatures roll 3 to 7.
- **Mutation** moves quality by one pip, pulled toward the middle: chance up = 20% × (10 − q) / 10, chance down = 20% × q / 10. At 10 it cannot rise; at 0 it cannot fall. The 2% rare mutation is either a new colour or a two-pip jump, still clamped to 0-10.
- **Result (simulation):** with no selection the population average stays at 5.1 after 80 generations. A breeder keeping the best of four needs a median of about 76 breeds to average 8 pips, 120 for 9, and 268 (90th percentile 440) for a perfect 10 in all five slots, before breed limits and the kin rule slow it further. The most a perfect creature gains over an average one is 5%, the same size as the first gem tier.
- **Fit (replaces the weight factor):**

```
bodyWeight = SPECIES_WEIGHT[torso species] × size gene      -- from the torso only
fit = clamp( (SPECIES_WEIGHT[part species] / bodyWeight) ^ 0.5, 0.85, 1.15 )   -- Speed from legs
fit = 1 for other slots at launch
```

  It uses the part's **original species weight**, a constant, not the donor creature's weight, and is recomputed whenever the model is assembled. Any breeding path to the same parts gives the same stats. The brief's worked example becomes Speed 80 × 0.85 = 68. The clamp is narrowed from 0.7-1.3 so that a body mismatch never outweighs a rarity tier.
- **Stat ceiling** is now automatic: best species part × 1.05 × 1.15 × level × rarity. Keep the brief's per-tier cap as a test assertion, not a runtime clamp.

Status: keeps Locked "parts carry stats", "the mother's legs bring the mother's Speed", "proportions scaled using size and weight" and "generational, continuous improvement" (quality and part combinations improve toward a ceiling). Changes Default mutation, Default formula and Default stat ceilings.

### 6.3 Rarity inheritance

Roll the higher tier first. Both parents at or above a tier: 50% for the first gem tier, 60% for Ruby and Diamond. Only one parent: 12% and 15%. A failed roll gives Uncommon, not the tier below, so failures do not flood lower gem tiers. Cosmic is never inherited. Show the percentages in the preview. Keeps Locked "rarity can be inherited; one parent is a chance" and "Cosmic only from a wrap".

### 6.4 Limits, cooldown, hatch, cost

| Rarity of the creature | Breed limit | R (pure pairs) | Cooldown after breed 1, 2, 3, 4, 5 | Egg hatch | Rarity cost multiplier |
| --- | --- | --- | --- | --- | --- |
| Common | 5 | n/a | 30 min, 1 h, 2 h, 4 h, 8 h | 10 min | 1 |
| Uncommon | 5 | n/a | same | 30 min | 1.5 |
| First gem tier | 3 | 0.75 | 12 h, 24 h, 48 h | 4 h | 4 |
| Ruby | 2 | 0.60 | 24 h, 48 h | 8 h | 10 |
| Diamond | 2 | 0.60 | 24 h, 48 h | 12 h | 25 |

```
cost = BASE × biomeTier(higher parent) × rarityMult(rarer parent)
     × ( COUNT_MULT[a.breedCount] + COUNT_MULT[b.breedCount] ) / 2
COUNT_MULT = { 1, 1.5, 2.5, 4, 6.5 }        -- Axie's curve
```

- Set BASE so a first common breed costs about 10 minutes of typical coin income and a first Ruby breed several hours. Tune from coins created against coins removed, as DECISIONS.md already says.
- Pens: 1 free, a second from a quest, up to 4 in total with Gems. Hard cap at 4.
- The first breed in the tutorial hatches at once.
- Never cut the cost to help new players (Axie's mistake). Help them with quests that give a free breed.

Status: keeps Locked "never free", "cost multiplied by rarity", "cross-biome is expensive". Fills in Default limits and cooldowns. Gem speed-ups and pens match DECISIONS.md.

### 6.5 Sinks

1. **Release for materials** (brief Default). Pay more for higher quality and rarity so released creatures are not only rejects.
2. **Radiant fusion** (new, propose first): four creatures of the same torso species fuse into one with a cosmetic glow and a "Radiant" tag. No stat change. Adopt Me shows this raises trade value while destroying three creatures.
3. **Move imprint** (new, propose first): consume a donor to teach one of its part moves to another creature on the same body plan. No stats move. Monster Hunter Stories 2 precedent.
4. Breed limits themselves: a creature at its limit is a fighter or a fusion ingredient, not a breeder.

Do not consume parents on breeding: the brief's Default is right for a game where players are attached to named creatures.

### 6.6 Offspring preview screen

One screen before paying, all values computed by the server:

- Two parents side by side with quality pips, shown and carried colour, breeds left.
- For each slot: the two candidate parts as live ViewportFrames, each with its 50% (or 80/20), the stat it would give on each possible torso, and its moves.
- Stat ranges for the child (lowest to highest across all combinations), and the best and worst cases drawn as two full models.
- Rarity odds as percentages, colour odds, child level, cost, hatch time, cooldown each parent will enter.
- A "Details" line stating the mutation chances. Not a compliance duty, since coins are earned, but it is what makes breeding feel fair.
- Afterwards: family tree with generation, parents, original owner and serials.

### 6.7 Simulation tests before launch (Lune, in `tests/`)

1. **No ratchet:** 10,000 lineages × 50 generations, best-of-8 selection, random and adversarial pairings: no stat ever exceeds the computed ceiling; no quality outside 0-10.
2. **Path independence:** the same set of parts reached by 1,000 different breeding paths gives identical stats.
3. **Neutral drift:** with random mating, mean quality stays between 4.5 and 5.5 for 100 generations.
4. **Chase length:** median breeds to a perfect creature under real breed limits and the kin rule falls in a chosen band (suggest 300 to 1,000).
5. **Rarity supply:** agent model of 10,000 players over 180 days with wild spawn rates, pens, cooldowns, costs and sinks: gem-tier population per active player levels off; R measured below 1 for each tier.
6. **Rarity odds:** 100,000 breeds per parent combination match config within 0.5 points.
7. **Dominant combination search:** enumerate every part combination per body plan at launch; no hybrid beats the best pure species by more than about 12% on any stat or on total budget.
8. **Coin balance:** breeding spend per day against coin income for casual, regular and heavy players.
9. **Exploit cases:** breed while trading, double-submit, breed at the limit, kin pairs, cooldown skipping. The server rejects each, and a breed is atomic (cost, counts and egg together or not at all).

## Recommendations for this game

Ranked by how much damage is avoided.

1. **Section 7, mutation and stat ceilings [Default]: replace the ±5% multiplicative mutation with a bounded quality gene (0-10 pips, ±5%, pulled to the middle).** Stops the ratchet at source; perfect creatures take hundreds of breeds. No [Locked] item changes.
2. **Section 7, proportion formula [Default]: keep the idea, change the inputs.** Use fixed species weights, derive fit at assembly, never store it, clamp 0.85-1.15. Removes the path exploit. The Locked "ratio using size and weight" is kept.
3. **Section 7, breed count [Default]: set limits by rarity so R < 1** (5 for common and uncommon, 3 for the first gem tier, 2 for Ruby and Diamond), with rarity odds of 50%/12% for the first gem tier and the brief's 60%/15% above it. Without this, rare supply grows exponentially as Axie's did.
4. **Sections 7 and 10, sinks: add two creature-consuming sinks beyond release** (Radiant fusion, move imprint). These are new systems and DECISIONS.md lost the bet-related coin sinks, so breeding and these now carry more of the load. Needs Ayrton's yes as a "big idea"; no Locked item changes.
5. **Section 7, cost [Locked intent kept]: add a breed-count multiplier (1, 1.5, 2.5, 4, 6.5) to the Default cost formula** and never discount it. Cap pens at 4 including Gem-bought ones, consistent with DECISIONS.md "Gems buy time and capacity only".
6. **Section 7, UI: build the offspring preview and visible genes with the first prototype,** not after. It is what turns part-based breeding into skill, and it doubles as the test harness view.
7. **Section 4, colour [Locked intent kept]: use one carried colour gene** so rare colours are a multi-generation project. This is the one place a recessive adds depth without hiding power.
8. **Section 7, limits: forbid parent-child and sibling pairs.** Cheap check; slows tight selection loops; adds a reason to trade for unrelated mates.
9. **Section 4, serials [Default]: give serials to wild-caught and giant creatures only, and mark bred gem creatures with generation and lineage instead.** Otherwise breeding inflates serial counts and low numbers lose meaning. Changes a Default.
10. **Section 15, open item: giants cannot breed** (agrees with the suggested placeholder). Giant parts with fit and quality would otherwise set the stat ceiling for everyone.
11. **Section 7, steering item:** sell the Bond Charm for earned coins only. Flag: if it were ever sold for Gems or Robux it would be paying to alter a random outcome and would need the section 11 review.
12. **Section 7, engineering note: adopt the nine tests in 6.7 as the gate** for the breeding milestone, and re-run the fetch-blocked sources (section 1) once the hosts are allowed so the Axie and CryptoKitties numbers can be marked "sourced".

No recommendation changes a [Locked] item or a line in DECISIONS.md. Items 4 and 9 are the ones most worth Ayrton's attention.
