# Art style research: creature games and what our style should be

Written 22 November 2026. Researcher 2 of 3. Plain English, British spelling.

## How to read the evidence labels

- **Sourced** means a page I read said it (link at the end).
- **Reading** means my own judgement from screenshots, trailers and memory. I could not open images in this session, so every claim about proportions, outlines, palettes and rarity looks is **Reading**, not verified. Treat these as hypotheses for the owner to check by looking at each game on a phone.
- The web search was weak for the Roblox games. I found nothing usable on the art of Loomian Legacy, Doodle World, Tales of Tanorio or Adopt Me. Do not treat those rows as researched.

## Summary (half a page)

1. **Winners pick one clear look and hold it everywhere.** Creatures, world, UI and effects share one shape language. The look is chosen to read on a small screen first and to look good second.
2. **For us, the safest base is chunky, flat-coloured, low-poly, with soft rounded edges.** That is already the brief, and it is also the only kind of style where parts from different species can be mixed without looking broken. Flat colour hides seams. Rounded ball joints (our PART_SPEC) hide joins. A shared palette and shared proportions do the rest.
3. **"Arcade" is mostly presentation, not modelling.** Saturated colour, big chunky type, bold UI frames, hit flashes, screen shake, victory poses, score-style pop-ups, bright lighting. Almost all of it is cheap on Roblox because it lives in UI, particles, tweens and Lighting settings, not in meshes. So the owner's idea fits the existing art direction. It does not need a new one.
4. **The expensive things on mobile are not triangles.** Roblox's own guide frames the budget in draw calls and memory: an example baseline of under 1,000 draw calls and 1,000,000 triangles (sourced), and low-end phones crash on memory (sourced). Our 3,000-triangle creatures are well inside that. Shadows, many transparent layers, many particles, many Highlights and large textures are what hurt.
5. **Recommendation: "Toy Arcade" (direction A below).** Chunky flat-colour creatures with no outline, a bright saturated world, a bold arcade UI and battle presentation. Add a thin outline only on the creature in focus in battle, if testing shows it helps readability. Details and reasons are near the end.

## Per-game notes

Each table says what I believe about the look. "Evidence" says how sure I am.

### Loomian Legacy (Roblox)

| Aspect | Note | Evidence |
| --- | --- | --- |
| Creature style | Cute, rounded, Pokemon-like designs with big heads and simple faces, rendered as stylised 3D models with painted colour | Reading |
| World style | Route-and-town structure like classic handheld monster games, in a bright Roblox-built world | Reading |
| Rarity | Variants by alternate colour schemes and "gleam"-style shiny forms | Reading |
| Phone readability | Good, because creatures are large in battle and shapes are simple | Reading |
| Notes | Made by Llama Train Studio, a successor to a fan game (sourced, wiki). I found no source on its pipeline | Sourced / none |

Lesson: a Pokemon-structured Roblox game succeeds with simple, readable, rounded designs. We copy none of its creatures.

### Creatures of Sonaria and Dragon Adventures (Twin Atlas)

| Aspect | Note | Evidence |
| --- | --- | --- |
| Studio style | The studio calls its look a shared "Sonaria studio style" and says it aims for a "middle ground" between low-poly and realistic | Sourced (GamesBeat) |
| Creature style | Detailed, textured animals with natural-looking proportions, more than a toy look | Reading |
| Variants | Colour and pattern variation is central to the game | Reading |
| Phone readability | Fine up close, busier at distance | Reading |
| Notes | I could not confirm whether Sonaria creatures are modular. Sources on mutations were poor and one said mutations were removed. Do not rely on it | Not verified |

Lesson: this is the high-fidelity end of Roblox creature games. It takes real texture and modelling effort. Not our budget.

### Adopt Me and Pet Simulator 99

| Aspect | Note | Evidence |
| --- | --- | --- |
| Creature style | Very round, big-eyed, soft toy-like pets with simple faces | Reading |
| World style | Bright, saturated, low-poly toy world | Reading |
| Rarity | Pet Simulator 99 has gold, rainbow and shiny variants. Rainbow has a colour-shifting glow (sourced from a guide). Gold comes from fusing ten pets. Shiny and rainbow are shown by effect and colour, not new models | Partly sourced |
| Phone readability | Excellent. Built for the 9 to 16 audience on phones | Reading |

Lesson: our audience already knows this look. Rarity shown as colour treatment plus a glow means no new meshes. That matches our "colour at runtime" rule.

### Doodle World and Tales of Tanorio (Roblox)

I found no sources. From memory, both are Pokemon-style Roblox games with stylised 3D or 2D-flavoured creatures. **Not researched; skip as evidence.**

### Pokemon (Let's Go, Legends Arceus, Stadium-style presentation)

| Aspect | Note | Evidence |
| --- | --- | --- |
| Legends Arceus | Described as cel-shaded and colourful; critics called it attractive despite technical problems and compared it to a vintage painting. One piece says later games moved to a toy-like look instead | Sourced (reviews) |
| Let's Go | Bright, soft, rounded, simple shading, big readable silhouettes | Reading |
| Stadium-style | Battle arenas with a spotlight stage, big camera moves, bold move names and a clear health bar. This is the "arcade presentation" the owner is probably picturing | Reading |
| Rarity | Shiny is an alternate colour plus a sparkle effect | Reading |

Lesson: battle presentation (stage, camera, bold text, effects) does most of the "arcade" feel. We borrow the idea of a presentation, never a creature or logo.

### Palworld

| Aspect | Note | Evidence |
| --- | --- | --- |
| Creature style | Cartoony, anime-flavoured designs. Reviews praised the look but many said the designs resembled Pokemon too closely. Version 1.0 redesigned some | Sourced (reviews) |
| Consistency | One critic said the game mixes three art styles and looks out of place | Sourced (one review) |

Lesson: a negative one. Being too close to another game's designs became the main criticism. And mixed styles read as sloppy. Both support our rules: original content and one shared look.

### Temtem, Cassette Beasts, Ooblets, Slime Rancher

| Game | Note | Evidence |
| --- | --- | --- |
| Temtem | 3D cel-shaded style, one reviewer found the art less striking | Sourced (review snippets) |
| Cassette Beasts | Retro 90s look. 3D pixel-art overworld and 2D pixel battles. Praised for art and monster design | Sourced |
| Ooblets | Bright saturated colour, simplified shapes, simple faces. Relies on colour and negative space more than line work | Sourced (one piece) |
| Slime Rancher | Round, glossy, simple blob creatures with big eyes in a bright 3D world | Reading only, no source |

Lesson: strong, simple identity beats detail. Ooblets and Slime Rancher show that very simple faces on very simple shapes carry a whole game.

### Crossy Road and chunky voxel mobile games

| Aspect | Note | Evidence |
| --- | --- | --- |
| Look | Chunky, toy-like, flat colour, little or no shading | Sourced (style guide and reviews) |
| Why it works | Clean and easy to read at different scales, suits low-spec devices, ages better than realism | Sourced (reviews) |
| Method | Find the essence of a character with as few blocks as possible | Sourced |
| Tools | Art was made in the voxel editor Qubicle | Sourced |

Lesson: constraint creates identity. Few shapes, clear colour, readable at thumb size.

### Classic arcade presentation

From memory (Reading): bold thick outlines on UI, saturated colour against dark backgrounds, huge chunky type, numbers that pop and bounce, brief screen shake and white flash on hits, slow-motion on the final blow, bright "winner" pose and fanfare. All of this is cheap on Roblox because it is UI, tweens, a few particles and short Lighting changes.

### Modular-creature games

| Game | How mixed bodies stay readable | Evidence |
| --- | --- | --- |
| Spore | One paint and skin system covers every part, so parts from different sources share a surface look. Parts are rigblocks with shared rigging. A complexity meter caps how much you add | Sourced (partly) |
| Niche | Genetics drive traits, but I found nothing about its visual rules | Not verified |
| No Man's Sky | Few skeleton "blueprints"; parts and proportions vary within each blueprint (from the earlier research file, a GDC talk snippet) | Sourced (earlier file) |
| Creatures of Sonaria | Unknown | Not verified |

Lesson: every system that mixes parts well does the same three things. It fixes the skeleton (our body plans), it unifies the surface (our runtime colour and flat shading), and it caps complexity (our triangle budgets).

## Patterns the winners share

1. **One silhouette per creature, readable as a solid black shape.** The biggest feature (horns, tail, wings) is exaggerated.
2. **Big heads and big, simple eyes.** The face is where players read personality. Kids' games lean on round shapes and large eyes.
3. **Few colours per creature**: one main, one secondary, one accent. The accent sits on the eyes, belly or tips.
4. **Saturated, clean colour with light shading.** Outlines are optional. Cel shading and flat colour both work. Realistic textures are the expensive path.
5. **Rarity is shown by colour and effect, not by new geometry.** Alternate palette, glow, sparkle, material change.
6. **Presentation does the "wow".** Camera, text, effects and sound make a battle feel like a show.
7. **Copying gets punished.** Palworld's strongest criticism was resemblance. Mixed art styles got called sloppy.
8. **Mobile first means big shapes and big touch targets.** Detail below a few pixels is wasted.

## What "arcade style" means for a 3D Roblox game

All of this is **Reading plus the Roblox pages I read**, except where marked.

**Cheap on Roblox (do these):**

- Saturated flat colour, `SmoothPlastic` material (our parts already use it).
- Bright, even lighting with a warm sun and a cool ambient. The Lighting service has `Brightness`, `Ambient`, `OutdoorAmbient`, `ColorShift_Top` and `ColorShift_Bottom` (sourced), and a `LightingStyle` of Soft for a flat, retro look (sourced).
- A little post-processing: `ColorCorrectionEffect` (saturation, contrast, tint), a light `BloomEffect`, `BlurEffect` behind menus (sourced). Keep each effect modest. The page gave no cost numbers, so test on a low-end phone.
- Camera: a close, slightly low angle on the battlers with a short tween push-in on attacks. Tweens cost almost nothing.
- Hit effects: a 2 to 4 frame white flash, a brief camera shake, a few chunky star or square particles, a big damage number that pops. Keep particle counts low (earlier research: particles do not batch well).
- Idle animation: a gentle squash-and-stretch bob and a blink on the existing Motor6D joints. Rotation only, as in the creature-tech research.
- Victory poses: a hop, a spin and a held pose with a spotlight and confetti.
- UI: the menus are the biggest "arcade" lever. Thick outlines, bold rounded frames, big type, glossy buttons, bouncy transitions. UI has no triangle cost.

**Expensive on Roblox (avoid or limit):**

- Real-time shadows. Roblox says the shadow cost applies to ShadowMap and Future lighting at higher quality settings, and low quality settings turn shadows off (sourced, community guide). Use soft, fake blob shadows under creatures, or only the main shadows.
- Future lighting on low-end phones. I could not verify device support or cost from a Roblox page (my lighting docs fetches failed). Treat it as a high-end option and test before using it.
- Large textures and many unique textures. Roblox says built-in materials use far less memory than custom textures, and low-end mobiles crash on memory (sourced). Our flat-colour approach is the cheap path.
- Transparency layers and overdraw. Roblox recommends transparency of only 0 or 1 where possible (sourced).
- Many Highlights, particles or Beams at once. The earlier research already limits Highlights to the one or two creatures in focus.
- Outlines made by duplicate inverted meshes: they double triangles and draw calls per creature. `Highlight` outlines are cheaper to author but I believe there is a per-client limit and extra cost (from memory, **unverified**).

**Budget numbers.** Roblox's example baseline is under 1,000 draw calls and 1,000,000 triangles (sourced; the page says it is an example, not a rule). A community guide suggests stricter numbers, 500,000 triangles and 500 draw calls (sourced, community). Our PART_SPEC already caps a creature at 3,000 triangles and the world at 300,000, which is safe. Draw calls from many separately coloured parts are the thing to measure first. PART_SPEC section 15 already lists whether differently coloured clones batch as an open question.

## Constraints from part-based breeding

What makes mixed bodies survive, and what breaks them:

| Survives | Breaks |
| --- | --- |
| Flat colour set at runtime from one palette, so a donor head and a different torso match | Baked textures or painted detail that stops at the part edge |
| Shared proportion rules (head about one third of torso length, limbs 0.85 to 1.15 of each other, see PART_SPEC R13) | One species with tiny heads and another with huge ones, mixed freely |
| Ball-end joints that hide the join (PART_SPEC section 5) | Flat cut faces, flared shoulders |
| One shared edge softness (same rounding on every part) | Some parts sharp and faceted, others smooth |
| Eyes and face on the head only, simple shapes | Detail spread across parts, such as a pattern that must line up across torso and tail |
| Uniform scaling of donor parts, clamped (PART_SPEC section 9) | Non-uniform stretching |
| Colour rule: one body colour and one accent colour for the whole creature, applied by slot, not per species | Each part keeping its own species' full palette |
| Cap on detail: same triangle budgets and the same detail level for all species | A "hero" species with twice the detail of others |

Extra rules I recommend:

- **Palette inheritance.** A child gets a primary and accent colour from its parents by data, and every part is painted from those two. This is how Spore's single paint layer keeps mixed bodies unified (sourced, partly). It also gives a free source of variety.
- **Face lives on the head.** If eyes are part of the head mesh, a mixed child always has a readable face.
- **Pattern is an overlay, not a part.** If patterns arrive later, they should be one optional layer applied to the whole creature, not baked into parts.
- **Biome identity from accent and prop colours, not from part shapes.** Parts must stay mixable across biomes.

## Three style directions

### A. Toy Arcade (flat, chunky, no outline)

**Description.** Chunky, rounded low-poly creatures in flat saturated colour, with big heads and big simple eyes, like a hard plastic toy or a prize from a claw machine. The world is bright and tidy with clear colour per biome. The arcade feel comes from the presentation: bold framed UI, huge type, stage lighting and a spotlight in battle, hit flashes, screen shake, confetti and a bouncy victory pose. This is the existing brief plus a stronger presentation layer.

**Palette.**

| Role | Hex |
| --- | --- |
| Arcade night background (UI, battle backdrop) | `#1B1340` |
| Panel and frame dark | `#2D2266` |
| Sky blue | `#4FC3F7` |
| Grass green | `#6BD65A` |
| Sun yellow (highlights, coins) | `#FFD23F` |
| Hot orange (fire, warnings) | `#FF7A2F` |
| Candy pink (accent, hearts) | `#FF5FA2` |
| Violet (rare, magic) | `#9B5CFF` |
| Cream (text, eyes) | `#FFF6E0` |
| Ink (text outlines, pupils) | `#161227` |

Creature body colours are drawn from the middle of this range; keep each creature to one main, one secondary and one accent.

**Creature rules.**

- Proportions: head 30 to 40% of body length, chunky limbs, short snouts, rounded everything. Torso length 3 to 10 studs as in PART_SPEC.
- Eyes: large, simple, part of the head mesh as shallow dents or bumps, cream with an ink pupil as a colour accent. Two or three eye shapes shared across species so mixed heads look related.
- Outline: none on the model. Contrast comes from colour value (light creature on darker ground).
- Triangle budget: as in PART_SPEC, up to 3,000 per creature (head and torso 600 to 900, limbs and tail 200 to 350).
- Material: `SmoothPlastic`. Rare tiers change material (Glass, Foil, Neon) and add one emitter.

**World rules.** Big simple blocks and rounded shapes, one dominant colour per biome plus one accent, no fine textures, readable paths, props 1.5 times larger than realistic. Fake or no shadows.

**Roblox lighting and post-processing to start from.** These are starting values to tune on a real low-end phone, not tested numbers.

- `Lighting.LightingStyle`: Soft. `GlobalShadows`: off in the overworld on low quality, on in battle only if the frame rate allows.
- `Brightness` 2.5, `Ambient` `#8A8AB8`, `OutdoorAmbient` `#9AA0D0`, `ColorShift_Top` `#FFE9B0`, `ColorShift_Bottom` `#5A60A8`.
- `ColorCorrectionEffect`: `Saturation` +0.25, `Contrast` +0.1.
- `BloomEffect`: `Intensity` 0.3, `Size` 24, `Threshold` 1.0 (so only bright effects glow).
- `BlurEffect`: size 12 to 20 behind menus only.
- No depth of field, no sun rays, no custom Atmosphere haze on low quality.

**Cost to produce.** Lowest of the three. Parts are untextured meshes; colour comes from data. Most extra effort goes into UI and effects, which are code and vector-style frames.

**Risk.** It can look generic or "free-model" if the UI and effects are weak. Mitigation: one distinctive shape trait for the game (for example slightly oversized feet) and a strong, consistent UI frame style. Flat colour with no outline can lose a creature against a similarly coloured background; keep a dark or contrasting battle stage.

### B. Ink Arcade (flat colour with a thick outline)

**Description.** The same flat chunky creatures, but with a thick dark outline around each one, like a cartoon cel or a comic-book sticker. This pushes the arcade look hardest: bold, graphic, sticker-like, and very readable on a small phone. UI uses the same outline language.

**Palette.**

| Role | Hex |
| --- | --- |
| Outline ink (all outlines) | `#14101F` |
| Paper white | `#FFFFFF` |
| Red | `#F2384C` |
| Orange | `#FF8A1F` |
| Yellow | `#FFE14A` |
| Lime | `#7ED321` |
| Teal | `#18C5C0` |
| Blue | `#3A7BFF` |
| Purple | `#8E4DFF` |
| Background mid | `#3B2E7A` |

Fewer, harder colours than A, with no pastel mid-tones.

**Creature rules.**

- Proportions as A, but pushed further: bigger heads (35 to 45%), thicker limbs, shorter tails.
- Eyes: large, white with a black pupil and one white highlight dot. Outline round the eye.
- Outline: yes. Preferred method is the `Highlight` object's outline on the active battlers only, with the world and idle creatures unoutlined. The alternative, an inverted shell mesh on every part, doubles part count and triangles (to 6,000 and about twice the draw calls), and uniform scaling makes outline thickness uneven on mixed parts.
- Triangle budget: as PART_SPEC. If shells are used, budget 1,500 for the creature and 1,500 for shells.

**World rules.** Bold flat shapes, dark outline on key props only, high contrast, fewer mid-tones.

**Roblox lighting and post-processing to start from.** As A, but `Brightness` 2.0, `Contrast` +0.2, `Saturation` +0.35, and almost no bloom (0.15) so the outline stays crisp.

**Cost to produce.** Medium. Outline tooling must be built and tested on mixed parts. Art effort is the same as A.

**Risk.** Highest technical risk of the three. `Highlight` limits and cost are unverified (from memory, I believe there is a per-client cap and a GPU cost, so it suits two to six battlers, not a crowd). Inverted shells break when parts are scaled non-uniformly and double the draw calls. Outlines on a world full of wild creatures could be costly. If outlines look wrong on mixed parts, the breeding showcase suffers.

### C. Storybook Soft (painted middle ground)

**Description.** Closer to the "middle ground between low-poly and realistic" that Twin Atlas says it aims for (sourced). Creatures are softer and more natural, with painted gradients, gentle texture, fur or scale hints and a warmer, moodier world with shadows and atmosphere. More emotional and "premium", less arcade.

**Palette.**

| Role | Hex |
| --- | --- |
| Deep forest | `#2F5D50` |
| Moss | `#7FA650` |
| Sand | `#E3C887` |
| Clay | `#C8663D` |
| Berry | `#A23B72` |
| Dusk blue | `#3B4F8A` |
| Mist | `#D9E4EA` |
| Warm light | `#FFD9A0` |
| Shadow | `#2A2438` |

**Creature rules.**

- Proportions: more natural animal proportions, head 20 to 30%, varied limb shapes, expressive face with shaped eyelids.
- Eyes: detailed, with a coloured iris and highlights. Needs textures or many triangles.
- Outline: none.
- Triangle budget: 5,000 to 10,000 per creature, plus textures (about 6,000 for the whole creature is the lower end).

**World rules.** Textured terrain and props, atmospheric depth, dynamic time of day.

**Roblox lighting and post-processing to start from.** `Future` or `ShadowMap` lighting, `Atmosphere`, mild `DepthOfFieldEffect`, `ColorCorrectionEffect` with a warm tint, light bloom. This asks the most from the phone; Roblox warns of OOM crashes on low-end mobiles (sourced).

**Cost to produce.** Highest by far. Many species need texture work, and PART_SPEC says texture maps are not scriptable from runtime and part textures would break mixing. Eleven biomes of textured art is a large production.

**Risk.** Very high. Mixed parts with painted detail show seams. Heavy for low-end phones, which our audience uses. Does not fit the owner's arcade idea. Does not fit the current PART_SPEC (no baked colour, no textures). Not recommended.

## Comparison

| | A. Toy Arcade | B. Ink Arcade | C. Storybook Soft |
| --- | --- | --- | --- |
| Arcade feel | Strong (through presentation) | Strongest | Weak |
| Fit with part mixing | Excellent | Good, outline method is a risk | Poor |
| Phone performance | Best | Good if outlines are limited | Worst |
| Production cost | Low | Medium | High |
| Fits PART_SPEC and brief | Yes | Yes, with new outline tech | No |
| Main risk | Looks generic | Outline tech | Cost and mixing |

## Recommendation

**Choose direction A, Toy Arcade, and build direction B's outline as an optional later test, only on the creature in focus in battle.**

Reasons:

1. **It is what the owner asked for.** "A bit arcade style with the graphics menus" reads as: bold, bright, punchy, with strong UI. Arcade is mostly presentation. A delivers it through UI frames, big type, stage lighting, hit flashes, screen shake and victory poses, which are the cheap parts to build on Roblox. It does not need a different modelling style from the brief.
2. **It is the style that survives part mixing.** Flat colour set at runtime, ball-end joints, shared proportion rules and one shared edge softness mean a head from one species on another's torso still looks like one creature. A single palette applied by slot (primary plus accent, inherited from parents) gives breeding a visible reward without any new meshes.
3. **It fits our phones and audience.** Our players are 9 to 16 and mostly on phones, and Roblox warns that low-end phones crash on memory. Flat untextured meshes at about 3,000 triangles are the cheapest option. The Adopt Me and Pet Simulator look shows the audience already likes round, bright, toy-like pets (Reading).
4. **It is cheap to change.** Because colour and rarity effects are data, we can later move toward B by adding outlines or toward a softer look by adjusting lighting, without redoing meshes.
5. **It protects originality.** A strong shape language of our own (a recurring design trait, a distinct UI frame) is the best defence against the Palworld problem of looking like someone else's game.

**What to do next, in order:**

1. Lock the palette and the UI frame style on one mock battle screen before making more species (a still mock-up is cheap).
2. Build the two-species breeding test from PART_SPEC using flat colour and the palette-by-slot rule. Check that mixed offspring look right at phone distance.
3. Put the arcade layer on the grey-box battle: stage, spotlight, big move names, hit flash, shake, victory pose. This is where the owner will feel "arcade" soonest, and it needs no final art.
4. Test an outline on the active battlers only. Decide by looking on a real low-end phone.
5. Measure draw calls with differently coloured clones of one template (the open question in PART_SPEC section 15) before committing to the palette-by-slot plan.

## What I could not verify

- Every claim about creature proportions, colours, outlines, eyes and rarity looks for Loomian Legacy, Adopt Me, Pet Simulator 99, Slime Rancher, Let's Go and Stadium is my reading from memory, not a source. Doodle World and Tales of Tanorio have no evidence at all.
- Whether Sonaria creatures are modular or how mutations look now. Sources were poor.
- Roblox lighting technology differences and device support. My fetches of that documentation failed (404), so the Future, ShadowMap, Voxel and Compatibility claims here are not verified.
- The cost and per-client limit of `Highlight` outlines. From memory only.
- The lighting and post-processing values above are untested starting points.
- Whether differently coloured clones of one mesh batch into one draw call (already open in PART_SPEC).
- How Niche's and No Man's Sky's visual rules work beyond the earlier research file.

## Sources

- Roblox, Design for performance: https://create.roblox.com/docs/performance-optimization/design
- Roblox, Post-processing effects: https://create.roblox.com/docs/environment/post-processing-effects
- Roblox, Lighting service properties: https://create.roblox.com/docs/environment/lighting
- Roblox, 3D art in Roblox: https://create.roblox.com/docs/art
- DevForum, real-world optimisation guide: https://devforum.roblox.com/t/real-world-building-and-scripting-optimization-for-roblox/3127146
- GamesBeat, Twin Atlas interview (studio style, "middle ground"): https://gamesbeat.com/twin-atlas-is-among-the-studios-changing-what-roblox-games-look-like-exclusive-interview/
- Loomian Legacy wiki, Llama Train Studio: https://loomian-legacy.fandom.com/wiki/Llama_Train_Studio
- Digital Trends, Legends Arceus review: https://www.digitaltrends.com/game-reviews/pokemon-legends-arceus-review/
- Kotaku, on Legends Z-A style versus Arceus: https://kotaku.com/pokemon-legends-za-switch-2-graphics-ugly-art-style-1851767088
- GamesRadar, Palworld 1.0 redesigns: https://www.gamesradar.com/games/survival/palworld-1-0-redesigns-multiple-pals-and-makes-them-look-less-like-pokemon/
- Comicbook, Palworld pal designs: https://comicbook.com/gaming/news/palworld-pal-designs-not-pokemon
- AV Club, Cassette Beasts: https://www.avclub.com/cassette-beasts-is-a-cool-stylish-take-on-the-pokemon-formula
- AV Club, Ooblets: https://www.avclub.com/ooblets-cute-weird
- PC Gamer, Temtem review: https://pcgamer.com/temtem-review
- PocketGamer.biz, making of Crossy Road: https://www.pocketgamer.biz/making-of-crossy-road/
- Game Developer, voxel art styles: https://gamedeveloper.com/art/voxelart-styles-in-video-games
- Spore skin paint and rigblocks: https://janeng.com/?p=143
- Spore Creature Creator wiki: https://spore.fandom.com/wiki/Creature_Creator
- Niche on PC Gamer: https://pcgamer.com/niche-is-a-natural-selection-game-about-survival-and-genetics
- Pet Simulator 99 variants (guide): https://twinfinite.net/guides/rainbow-pets-pet-simulator-99/
- Project files read: docs/BRIEF.md section 12, docs/PART_SPEC.md, docs/ASSETS.md (empty register), docs/research/market/05_CREATURE_TECH.md
