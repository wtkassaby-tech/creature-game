# Design bible: Crystal Deep (biome 6)

Date: 23 November 2026. Status: [Default], names are placeholders. Builds on `00_ROSTER_PLAN.md` section 6, `00_BREEDING_STANDARD.md`, `docs/research/creatures/loved/` and `docs/plans/13_WORLD_DESIGN.md`. The eras synthesis (`eras/00_SYNTHESIS.md`) does not exist yet, so it is not used. Principles only; no specific creature is copied.

## 1. Visual identity

Crystal Deep lies under the Northern Range. Light comes only from the crystals; the sky is hidden (world design: amethyst fog, lamps every 30 to 40 studs). The biome signature is **contrast**: soft, smooth, pale, blind-cave bodies carrying a few hard, faceted, glowing growths. Gems are a few large growths, never the whole body (the research finds gem-bodied designs rank low, while a face with gem eyes or a gem chest ranks high).

**Palette (2 to 3 body colours plus one accent per creature):**

| Role | Name | Hex |
| --- | --- | --- |
| Skin base | Cave white | #E8E2F0 |
| Second body colour | Dusk lilac | #B9A6D6 |
| Deep body (heavy species) | Amethyst | #6B3FA0 |
| Darkest | Cavern violet | #2E1B4F |
| Accent A (default crystal glow) | Cyan | #3FE0F0 |
| Accent B | Magenta | #E040C8 |
| Rare accent (Ruby tier) | Ruby red | #D01848 |
| Mineral neutral | Dripstone tan | #A89C94 |

Rule: each creature uses exactly one of cyan or magenta as its glowing accent. The body stays in the pale-to-violet range so the accent reads at phone size.

**Materials:** matte plasticine skin (the clay style); crystals as smooth glossy clay, painted bright (cyan or magenta with one white highlight stripe per facet). All glow is painted in the model, and Neon plus lights are added in Roblox, so Meshy never has to make glow or transparency (its known failure modes). Stone parts are dripstone tan with chunky bevels.

**Shape language:** round, bean-like soft bodies (Quad and Biped bands unchanged) with 3 to 5 chunky pointed facets grown out of one part. Points lean the same way (up and back) so the silhouette reads as crystal at a glance. Faceting is big and simple: flat planes, no fine cut gems; thin spikes break under Meshy and the part rules. Serpents are long, smooth and tube-like with one faceted fin or head cap.

**Motifs:** geode halves (cracked open to show crystals), quartz points, dripstone, tuning-fork resonance, lens eyes, hanging threads of light, humming. A recurring mineral seam where soft skin meets hard crystal.

## 2. Target mix across the ten species

Evidence: cool designs outnumber cute ones in the global top 40, yet small round expressive faces win the official Japanese vote; gem types win by face and character, not by gems. So the biome is **cool-led, with cute faces on the commons** to keep early catches loved.

| Mix | Count | Species | Why |
| --- | --- | --- | --- |
| Cool | 3 | Forkhum, Drillgleam, Grotteel | Sharp, readable silhouettes with one signature tool (fork head, drill head, glass fin). Serpent debuts here, and a sleek eel or drill-worm is the plan's best first impression. |
| Cute | 3 | Lensloris, Prismquill, Slagworm | Big lens eyes, a chubby quill ball and a fat sleepy worm give new players an easy first love and a trade-friendly common. |
| Majestic | 2 | Glintbruin, Glowthread | A bear with an amethyst ridge and a serpent hung with light threads carry the treasure-of-the-deep feeling and are the aspirational Uncommon and Rare-spawn finds. |
| Creepy-cute | 2 | Thundegg, Stalagrump | Blind-cave oddities (a static-crackling geode toad, a dripstone grump) give the biome edge: the mischievous cave dweller with gem-like features and a clear mood. |

Why: this is the first dark biome, so the risk is a moody, samey, all-cool roster. Three cute faces on the commons keep it warm, and only two creepy-cutes keep it distinct without losing the cozy clay promise. Cool and majestic cover the top of the rarity ladder: Ruby starts here, so the rare end must look like a prize.

## 3. Archetypes from the loved evidence that fit

- **The cool beast body (fox, wolf, cat and dragon bodies are half the favourites).** Crystal Deep has none of these species, so take the principle: a clear lean body plus one signature feature grown into it. Glintbruin and Forkhum should be built that way.
- **One signature feature grown into the body.** Every species already has one (ridge, quills, fork, lens, drill). Keep it to exactly one per creature.
- **The gem-eyed mischief face** (a cave creature, gem eyes, a readable smirk): Lensloris and Thundegg.
- **The elegant long aspirational shape** (the dragon-like silhouette): the Serpent plan is the nearest this biome gets. Grotteel and Glowthread should look graceful and long.
- **A personality hook and one readable mood.** Fan favourites win on mood and reaction-image potential, so exaggerate: Stalagrump permanently grumpy, Lensloris permanently startled.
- **Part-mixing payoff.** Geode, lens, fork and drill parts should look good on each other (pale body, one glowing accent), which suits breeding.

## 4. Rare-look (shiny-style) colour rule

Rarity must be visible on Roblox through glow, size or outline. Rule for Crystal Deep: **the accent crystal changes, the body does not.** The normal creature has cyan or magenta crystals; the rare look turns **all its crystals Ruby red (#D01848) with a white-gold highlight and a larger Roblox glow**, and adds one extra facet so the silhouette changes too. Body colours stay put, so the species is still recognisable and the colour gene still works. It is a per-part texture swap on the one part that owns the crystal, so it travels with that part in breeding (breeding standard 3.5). Ruby is also the biome tier colour, so look and tier read as one idea. Never use red as a normal accent here.

## 5. The giant: Druseback (Crystal, Quad)

**Concept:** a colossal pillbug whose back plates are geode halves with crystals showing at the seams. Chunky, pale lilac and soft underneath, cyan geode interiors; its plates are the biggest crystals in the biome apart from the Heartstone.

**Fight tell:** rolled up it takes little damage. Before it rolls, its geode seams brighten from cyan to white for one full turn with a rising hum: that is the wind-up. It then unrolls and charges. Players answer with a Leaf or Frost hit as it unrolls, which cracks the plates (a damage bonus and a visible crack that stays for the fight, so progress shows). In its low-HP phase the seams glow magenta and it rolls faster.

## 6. Mascot candidate: Prismquill

The roster calls it the Ruby showcase and the first Ruby find a player chases. Why it works: (a) a round quill ball is the strongest silhouette at phone size and works as an icon; (b) quills that split lamplight into colour are a built-in visual gag and the natural place for the rare look (quills turn Ruby); (c) a porcupine is cute-cool, covering both the small-round-face votes and the strong-design lists; (d) it is Common, so players meet it early and often; (e) its hook (it collects light) is simple. Alternative: Lensloris for a purely cute pick, but it shows rarity less well.

## 7. Three risks to avoid

1. **Everything is a glowing gem blob.** If every creature is mostly crystal, the research says it ranks poorly and the species blur together. Keep the soft pale body dominant, at most one grown-in crystal feature (about a quarter of the visible surface), and let faces and gestures carry the love.
2. **Too dark, too violet, too uniform.** The tunnels are dim and the palette is already purple. Always pair violet with cave white and one bright accent, check each icon against the amethyst fog at phone size, and do not let two species share an accent colour on the same part slot.
3. **Meshy and part-mixing failures.** Glow, transparency, thin points, floating crystals and crystal rings are Meshy failure modes and break part cuts. Use chunky solid painted crystals attached to one part, and make the Serpent plan follow the standard's torso, head and tail separation so breeding works.
