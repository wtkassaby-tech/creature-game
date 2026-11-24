# Design bible 05: Frostline (Frost)

Town Rimewick, plateau above the Mire. 4v4, slow and tanky. Eight species (six Frost, two Toxic visitors), giant Driftmother. Sources: `00_ROSTER_PLAN.md` section 4 (biome 5), `00_BREEDING_STANDARD.md`, `docs/research/creatures/loved/*`, `docs/plans/13_WORLD_DESIGN.md`. The era synthesis (`eras/00_SYNTHESIS.md`) did not exist when this was written; revisit when it lands.

## 1. Visual identity

**Palette (flat blocks, two main colours plus one accent per creature).**

| Role | Name | Hex |
| --- | --- | --- |
| Main light | Snow white | #F2F6FA |
| Main cool | Ice blue | #9CC9E6 |
| Deep cool | Glacier blue (shadow, horns, eyes) | #4F86B5 |
| Neutral dark | Slate grey | #5C6773 |
| Evergreen | Pine green | #2F5D4B |
| Accent (the biome signature) | Aurora mint | #7FF0C8 |
| Rare accent (rare look only) | Aurora violet | #B58CFF |
| Toxic visitors | Sulphur yellow / steam white | #E8D44D / #F7F4EC |

Rule: snow white or ice blue is never the only colour on a creature. Every species carries slate or pine as its dark anchor, so white does not vanish against snow terrain and thumbnails keep contrast. Mint is the single accent, used on one feature only.

**Materials.** Matte clay for fur masses (thick woolly, hand-pinched), satin clay for packed snow, semi-gloss for ice (horns, teeth, fringes: always opaque coloured panels, painted bright, never see-through or glowing in the asset; Neon is added in Roblox). Hoarfrost is a stippled texture on edges, not a transparent layer.

**Shape language.** Heavy rounded masses with things hanging from them: icicle fringes, drooping fur skirts, snowshoe feet. Silhouette is a low wide boulder with one sharp counterpoint (a curled horn, a crest, a tooth). The slow-and-tanky feel comes from a low centre of gravity and big feet; the speed species (Flurrlem, Rimefern) are the exception and read as small puffs.

**Motifs.** Fringes (icicles on the torso edge, never crossing a leg joint), frost ferns (window-pane branching as a surface pattern), snowshoe pads, one aurora ribbon (a single mint stripe), pine sprigs. Limit to two motifs per creature.

## 2. Target mix (8 species)

| Mood | Count | Species | Why |
| --- | --- | --- | --- |
| Cute | 3 | Flurrlem, Rimefern, Hoarmot | The biome's entry point. Cute sells Roblox pets and plush (low entry price, wide variant range), and snow is the cuddliest biome, so cute is the natural default. |
| Cool | 2 | Glacibex (star), Chiselrime | The loved evidence says cool designs outnumber cute in the global top 40. Glacibex is the chase poster; its horns are the signature feature. |
| Majestic | 1 | Woolrime | Uncommon bruiser with a big silhouette, the aspirational mid-rarity. Foreshadows the Driftmother giant. |
| Creepy-cute | 2 | Stinkglut, Simmerling | The Toxic visitors: scruffy, greedy, steam-wreathed. Their off-palette (sulphur, steam) makes them read as visitors and as the underdogs. |

Target: about 35% cute, 25% cool, 12% majestic, 25% creepy-cute. Frostline skews soft on purpose: the next biome, Crystal Deep, turns sharp, so the contrast carries. The giant is the biome's one elegant, majestic payoff.

## 3. Archetypes from the loved evidence that fit

- **Soft or sleek animal in white plus one icy blue, with one sharp accent.** The Frost research states this directly (seal, fox, owl, hare). Apply it: ruminants, rodents and a sprite, with the sharp accent on the part that owns it.
- **Canid, feline and dragon bodies are about half of all favourites.** Frostline has none yet (rodent, ruminant, mustelid, primate). This is a gap: move the lynx kitten spare up, and add a wolf- or fox-style winter creature in the growth roster (see risk 1). Principle only; no copy of any specific creature.
- **A familiar animal with one twist** (colour trick, one oversized feature): the fringe on Woolrime, the horns on Glacibex, the tooth chisel on Chiselrime. One twist each, not three.
- **One signature feature grown into the body**, with three features on three parts (breeding standard 2.2): horns on the head, fringes on the torso, a frozen paddle on the tail. Nothing crosses a joint, so a breeder can mix parts.
- **A personality or story hook** (a joke or a gesture becomes the love): Hoarmot whistling at weather, Flurrlem leading a line of one.
- **Visible rarity** through glow, size or outline (neon tiers, size tiers on other Roblox pet games). See section 4.

## 4. Rare-look (shiny-style) colour rule

Rare looks must be an alternative texture on the one part that owns the feature (standard 3.5), not a tint, so they travel with the part in breeding.

**Rule for Frostline: the aurora flips.** On the feature part only, mint #7FF0C8 becomes aurora violet #B58CFF with a thin mint rim, and the white fur on that part gains a faint blue-to-pink gradient. The rest of the creature is unchanged. In Roblox a Neon violet edge is added to that part and the ice ornament gets a slow shimmer. It reads from far away as "this one has the northern lights on its horns". Two guards: the slate or pine anchor never changes (contrast stays), and no rare look adds a fourth hue.

## 5. Giant: Driftmother

**Concept.** A colossal snow hare the size of a hill. Her back is a snowfield with a small stand of pines (and a weathered lantern post) growing on it. Calm and maternal when asleep: soft round ears, a snow-white belly, mint ribbons running through the ears. An elegant cold legend, as the evidence advises, not an ice block.

**Fight tell.** The tear's leak drives her wild. A readable two-beat telegraph: she **lifts both front paws** (one clear frame, with the pines swaying), then **stamps**, burying the field in drifts that apply Chill (slow) to the team. A Fire hit on the lift melts the drift. The fight teaches the player to watch the paws and hold the Fire move for the wind-up. The Fire-underdog visitors (Stinkglut, Simmerling) are natural counters, so the biome's lesson pays off at the gate.

**Fight palette.** Calm: snow, ice blue, pine, mint ear ribbons. Wild: the mint turns aurora violet, the eyes go glacier blue with a white rim, and the drifts pile up as slate-grey blocks. Same silhouette, so she never reads as a different creature.

## 6. Mascot candidate

**Glacibex.** The cliff-climbing ibex with curled horns of packed blue ice. Why: it is the biome's star in the roster; it is a Quad (the most common plan, so the most breeding visibility); it is Common, so every player meets it early; it is cool and cute at once; and the curled horn is a strong silhouette that survives thumbnail and icon size. The horn is a head part, so it also carries the rare look cleanly. Runner-up: Woolrime (majestic, but an Uncommon bruiser is met later). Rimefern is the cutest but too small to carry a biome.

## 7. Three risks to avoid

1. **All-white mush with no cool top end.** A snow biome of cute rodents fades into the terrain and loses the "cool beats cute" slot. Keep a slate or pine anchor on every species, make Glacibex and Chiselrime visibly cool, and plan a wolf, fox or lynx style apex for the growth roster so the canid and feline half of the favourites is represented.
2. **Whole bodies of ice blocks.** No loved list features a body made of ice; blocks read as props and break the joint rules (ice crossing a limb). Ice is ornament on a soft animal (horn, tooth, fringe, paw pad), never the whole body. Fringes stay on the torso and stop above the leg tops.
3. **Visitors that read as noise, or Frost species that read as recolours.** Stinkglut and Simmerling must belong by silhouette and attitude, not just be a yellow tint of a Frost creature. Frost species must not be recolours of each other (watch the ibex and musk ox pair, and the beaver and marmot pair, which share proportions). Guard originality too: no white-fox-with-ice-hair clone, no recognisable fan-favourite ice sprite; if someone would say "that is X with a different colour", redesign.
