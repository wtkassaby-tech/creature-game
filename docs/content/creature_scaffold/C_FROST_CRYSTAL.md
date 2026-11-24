# Scaffold C: Frostline and Crystal Deep

Date: 23 November 2026. For: Ayrton (designs and the Meshy prompts) and the lead (the import pipeline and the roster gate).
Status: every design here is a [Default] and every name a placeholder, under brief sections 4, 6, 8 and 12. It fills assignment C of `00_ROSTER_PLAN.md` (section 7): 18 new species and 2 new giants, and it owns the **Serpent plan's conventions** (section 1 below), which agents D, E and F follow for their serpents. Nothing here changes code or data. Species files come only after Ayrton approves a biome's list and its roster passes `tests/roster.test.luau`.

Built to:
- `00_BREEDING_STANDARD.md`: six-block prompts, the plan's STANDARD BODY LINE pasted word for word, three signature features on three different parts, nothing across a joint, flat colour blocks for the tint mask.
- `00_ROSTER_PLAN.md`: each species keeps the element, plan, rarity role, size class and battle role given there; the originality list (2b) and the taken motifs (2c) were checked for every design; per the owner, resemblances are flagged (in each originality line and the Look-alike flags list at the end), never designed away.
- `docs/research/creatures/01` to `04`: one hook a child can draw, two main colours plus one accent, animal plus one twist, a charming flaw, chunky parts only (no whiskers, membranes or thin threads), glow painted bright and added later in Roblox, nothing see-through, nothing floating.
- `docs/plans/13_WORLD_DESIGN.md` for the places, and `CREATURE_PERSONALITY.md`: every temperament and gesture pair below is new against the 36 species there and inside this file.

How to read an entry. The five bullets the coordinator asked for come first (Description, Intended appeal, the full Meshy prompt, the short prompt under 800 characters, 3D settings). The **Design sheet** after them carries the rest of the roster plan's template (2a): size and weight, the three signature parts, personality, the rare look, move ideas, the breeding hook and the originality check. Move names and types only; powers, levels and stats come from the roster gate.

Art style (owner decision, 24 November 2026): clay bodies with cartoon eyes. Every short prompt opens with the style line "Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face." and is at most 800 characters. The full prompt is reference only (over Meshy's 800-character limit); it is for the concept image (Nano Banana Pro or GPT Image). The short prompt is for Meshy's 800-character text-to-image box: the shared style line (big glossy cartoon eyes with white highlights on a matte clay body), a short body line, the species look and a closing line. Character counts were checked by script. No prompt contains the species name (Meshy writes names out as plaques).

Contents:
1. Serpent plan conventions (for agents C to F)
2. Frostline (biome 5): 8 species and the giant Driftmother
3. Crystal Deep (biome 6): 10 species and the giant Druseback
4. Questions for Ayrton

---

## 1. Serpent plan conventions

The Serpent plan debuts in Crystal Deep (four species: Grotteel, Drillgleam, Glowthread, Slagworm) and returns in Emberfall, the Arcane biome, the Abyss and the Hollow, with one giant (Starfathom). These rules sit on top of `00_BREEDING_STANDARD.md` section 1.4 (the bands, quoted, not repeated) and turn them into what to draw and what to write. Ayrton has not yet confirmed the plan (roster plan decision 4); until he does, these are the working rules.

### 1a. The five slots, as a serpent

| Slot | What it is on a serpent | Breeding stat it carries (brief mapping) | Owns |
| --- | --- | --- | --- |
| Head | The face, on a short thick neck stub ending in the neck ball | Attack | Crests, horns, drills, lenses, feelers (chunky), cheek marks, jaw plates, the face |
| Torso | The raised front body: a thick rounded log, chest lifted a little, belly flat on the ground | Hp, Defence, the type | Back plates, back crests that stop short of both ends, belly colour, speckles, slag crusts, manes |
| FrontLimbs | **Side fins**: a pair hanging down and back just behind the neck | Attack | The fin's shape and edge colour |
| Legs | **Rear fins**: a pair of small low fins at the back of the front body | Speed | Small spurs or nubs; nothing that spreads sideways |
| Tail | **The long body**: everything behind the front body, ending in the tip | a move or a small bonus | Ring segments, the dorsal ridge on the tail, the tip feature (fan, tassels, crystal, cooled lump) |

The tail is the serpent's biggest part and the one players see first, so on a serpent the **tail is a signature part every time**, alongside the head and one of torso or fins.

### 1b. Rest pose and silhouette

- **The front body lies on the ground** with the chest slightly raised, like a seal resting on a rock, not reared up like a cobra. The head is held forward at about the height of the chest, on a short thick neck in a soft rounded collar (no long necks: a long neck is a different silhouette, and it would not fit other serpents' collars).
- **The tail lies straight back along the ground**, in line with the body. Any wave is **up and down only** (in the YZ plane), at most a gentle hump or two. Never a sideways S-curve, never a coil, never a tail that curls round or over the body: the plan requires left-right symmetry, and a curled tail cannot be mirrored or swapped. This overrides the S-curve in the Serpent pose line of `04_PROMPT_CRAFT.md`. Slithering is animation (a travelling up-and-down wave plus a whole-body sway from the rig), not modelled into the mesh.
- **Length**: tail 1.5 to 3.0 times the torso length, tapering evenly from the joint to the tip. Thick at the joint (tail socket ratio 0.14 to 0.20 of the torso length, much thicker than a Quad's tail): it is the body.
- **Read at 60 pixels**: a serpent's outline is a long low wedge. The head crest and the tail tip are the two places where a serpent can break its outline, so the hook almost always lives on one of them.

### 1c. Fins

- **Side fins (FrontLimbs)**: a flat rounded paddle or fan, thick and clay-chunky (as thick as a finger at the edge, never a thin membrane), lying flat in the YZ plane against the side of the body, hanging down and back. Length 0.25 to 0.45 of the torso length. They never touch the ground. **One mesh serves both sides**, so the fin must look the same from both faces: no inside or outside markings, no leading edge that only works on one side; an edge stripe runs all round.
- **Rear fins (Legs)**: small (0.15 to 0.30 of the torso length), low on the sides at the back of the front body, resting lightly on the ground beside the body, not under it. A rounded nub, a little spur or a short fan. They carry nothing: ride height comes from the torso (1f).
- Fins must have a **clear gap from the body** in the concept, except at their root, or Meshy fuses them into the body.

### 1d. The tail joint: the hip ring (a proposal)

The neck already has its collar. On a serpent the torso-to-tail joint is wide and in plain view, so a colour step between two species there would look like a cut. **Proposal:** every serpent torso has a soft raised rounded rim around the tail socket at its back end, a **hip ring**, in plain main colour, mirroring the neck collar. The tail's first 1 R is plain main colour too. Then a Grotteel front body on a Slagworm tail reads as a ball-jointed toy, not a broken one. This is a small addition to standard section 1.4 (log it in `docs/DECISIONS.md` before code follows); it costs nothing for Quads and Bipeds.

### 1e. Features

- **Head**: crests sit on top of the head and stop before the neck; a crest that runs from the head down the back is forbidden (it crosses the joint). Move it wholly onto the head, or make a separate back crest on the torso.
- **Torso**: back plates, speckles and ridges stay at least 1 R behind the collar and 1 R in front of the hip ring. Belly flat and plain lighter colour.
- **Tail**: ring segments are sculpted grooves (they survive the tint) and stop 1 R short of the joint. The tip feature (fan, tassels, crystal, cooled lump) sits at the very end. A dorsal ridge on the tail is fine if it starts behind the joint zone.
- **Nothing thin, nothing floating.** Threads, whiskers and wisps become chunky tassels or stubs on one part, or a Roblox effect (Beams, particles) owned by an attachment.

### 1f. What the Assembler needs (from standard section 1.4; restated for the other agents)

- Ride height from the torso's `GroundPoint`: the belly rests on the ground, the rear fins do not carry it. One Assembler change.
- The long tail is one template in version 1. Later it may become a chain of two or three clones of one segment template for a smoother slither (a second change, proposal only). Designs should therefore keep the tail's look **even along its length** with the feature at the tip, so a segmented version still reads.
- Serpent parts mix only with serpents (one rig per plan). Each biome with serpents has at least two, so a player can breed locally.

### 1g. Budgets

| Tier | Head | Torso | Side fin | Rear fin | Tail | Whole |
| --- | --- | --- | --- | --- | --- | --- |
| Standard (standard section 6) | 600-900 | 600-900 | 150-250 | 150-250 | 500-800 | up to 3,000 |
| Giant (proposal for Starfathom; log it) | 1,200-1,800 | 1,200-1,800 | 300-500 | 300-500 | 1,000-1,600 | up to 6,000 (hard 7,200) |

Assembled totals count each fin twice (one template, mirrored).

### 1h. Prompt and Meshy settings for serpents

- STANDARD BODY LINE, Serpent, word for word (standard section 1.4). Then the look in this order: **Head. Body. Side fins. Rear fins. Tail.**
- Short body line used in this file: "Serpent: thick front body on the ground, head on a short neck in a soft collar, small side and rear fins, one long thick tail straight back."
- **Camera**: the VIEW LINE's three-quarter front view foreshortens a straight-back tail. Ask for a second, plain side view of the same design (Meshy text-to-image multi-view, or a turnaround sheet as in `04_PROMPT_CRAFT.md` section 5), and use Meshy 7.1 multi-view when the tail's tip feature is the hook. A tail that comes out coiled or curving sideways is regenerated, not fixed.
- Meshy: Pose off. Smart Topology for standard serpents; if the tail comes back as one fused lump with the torso, try Auto Split. Decimate the tail separately in Blender (it eats triangles).
- Checklist additions (on top of standard 5.1): tail straight back and on the ground; only up-and-down waves; fins with a gap and the same on both faces; hip ring visible; head crest stops before the collar.

### 1i. Originality watch-outs for serpents

From the roster plan's list and our own check: no rock snake made of a chain of boulders (Onix, Steelix); no green sky serpent coiled in clouds (Rayquaza); no small blue serpent with white ear fins and a pearl (Dratini's line); no long elegant pink-and-cream fin-tailed water serpent (Milotic); no lava snail (Slugma). Our serpents are short, chunky and toy-like: big heads, thick bodies, a single hook at the head or the tail tip.

---

## 2. Frostline (biome 5, Frost) · town "Rimewick" · 4v4 · slow and tanky

**The place** (plan 13). A snow plateau above the Mire, reached by the Rimewater Gorge: three flights of stairs and two ramps beside waterfalls, reeds giving way to birch, pine and snow pine, the first snow falling on the top flight, and from the top the game's first big panorama back over the Mire, the estuary and the Old Light. Rimewick sits at (3400, -1650), base height 80. Whitefang, the 420-high peak, is the landmark; Old Smoulder's plume shows to the north-west. Side areas: **Glass Lake** (a frozen lake with ice-fishing huts and auroras) and **Whitefang Summit** (the summit cairn and the second panorama). The road on runs to the Frozen Fall, a cave mouth behind a frozen waterfall where ice turns to blue crystal: the way down to Crystal Deep. Light: pale cold blue, falling snow, wind and creaking ice.

**The story beat** (brief section 9; a proposal). The tear's leak drives Driftmother wild, and her stamping sets off the avalanches that close the high routes; the tamers of Rimewick say the auroras over Glass Lake have turned the wrong colour. The Mire's gate was a local champion, so Frostline's gate fits the rival: his team shows its first gem-touched creature, and the cold makes his dark tint easier to see against the snow.

**What makes it distinct.** Cozy winter, not harsh tundra: thick woolly frost that looks hand-knitted, packed snow, icicle fringes, hoarfrost feathers, snowshoe feet, a few warm accents (cranberry, pine green) like the inside of a cabin, and aurora mint as the biome accent. Heavy rounded masses with fringes hanging from them. The two Toxic underdogs come from the sulphur hot springs and read as visitors: sulphur yellow and steam white, and both carry a warm orange spring stone on the torso, the **Fire teaser** for Emberfall.

**Freeze or slow arrives here** (brief section 8). Frost moves that would carry the proposed **Chill** (slow; roster plan section 1b, needs Ayrton's yes as a battle rule) are marked "Chill" below.

**Breeding stat: Defence on the front limbs** (roster plan): every Frostline species has armoured forelegs or arms (frost cuffs, ice greaves, ice gauntlets, floe plates), so a breeder can take Frostline toughness without the Frost type.

| Species | Plan | Type (and move types) | Rarity | Size (weight) | Role | Hook | Rare look (part) |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Flurrlem | Quad | Frost | Common | XS (36) | sprinter | A lemming in snow goggles that always leads a line of one | Aurora-banded snow puff (tail) |
| Glacibex ★ | Quad | Frost (Sand on the legs) | Common | M (58) | striker | Ibex with ring-curled horns of packed blue ice and ice greaves | Aurora-ice horns (head) |
| Woolrime | Quad | Frost (Sand on the legs) | Uncommon | L (78) | bruiser | Musk ox in a knitted frost coat with a chiming icicle fringe | Snowflake-jumper band (torso) |
| Stinkglut | Quad | Toxic (Fire on the torso) | Common | M (62) | all-rounder, underdog | Wolverine glutton that naps on the hot vents | Gold-crusted vent stone (torso) |
| Hoarmot | Biped | Frost (Storm on the head) | Common | M (60) | tank | Upright marmot that whistles the weather | Aurora frost crest (head) |
| Rimefern | Biped | Frost (Leaf on the tail) | Common | XS (34) | sprinter, token | Frost-fern window sprite with fiddlehead hands | Aurora fronds (head) |
| Chiselrime | Biped | Frost (Water on the torso and legs) | Uncommon | L (74) | bruiser, quest gift | Beaver with ice-chisel teeth and an ice-paddle tail | A fish frozen in the paddle (tail) |
| Simmerling | Biped | Toxic (Fire on the torso, Water on the legs) | Common | M (55) | all-rounder, underdog | Hot-spring macaque with a bath towel of fur on its head | Cranberry towel tuft (head) |

Each plan has three Frost and one Toxic underdog (Toxic loses to Frost; its torso carries the Fire move that beats Frost back). Breeding pairs: any two of the four Quads, any two of the four Bipeds. Gifts: quest creature Chiselrime (Uncommon, the plan's quest gift; the roster plan suggested Woolrime, see question 2), token Rimefern (Frost beats Crystal, the next biome). Gem showcase: Glacibex (broad smooth horns and a flat saddle for the sparkle and sheen).

### Flurrlem

- **Description:** Frost, four-legged, Common, size XS: a tiny round lemming that bolts across the snow in a puff of powder. Frostline's sprinter.
- **Intended appeal:** It is the smallest, roundest thing in the snow, it wears natural snow goggles, and it marches with total seriousness at the head of a line nobody else is in: a joke a child gets at once and a first catch that feels earned because it is so quick.
- **Meshy image prompt (full, reference only: over Meshy's 800-character limit; paste the short prompt):**

  ```text
  handmade claymation creature for a Pokémon-inspired Roblox game, soft matte hand-sculpted plasticine with visible thumbprint texture and tiny tool marks, chunky rounded proportions, big glossy cartoon eyes with a bright white highlight, an expressive face full of personality, original creature design, no clothing, no held objects, full body. a chunky four-legged creature with a rounded loaf-shaped body about one and a half times as long as it is tall, back level, standing square on four short straight legs set under the four corners of the body with a clear gap between the legs, front and back legs the same length, legs about two-thirds as long as the body is tall, feet flat on the ground; a big round head a little less than half as long as the body, held forward at the height of the back on a short thick neck that rises out of a soft rounded collar at the front of the body; a tail that starts as a small round stub at the top of the rump and points straight back; left and right sides mirror-symmetric. Head: a small, perfectly round lemming head with tiny round ears almost hidden in fluff, a little pink nose, a serious, determined mouth and a band of pale ice-blue across the eyes shaped like snow goggles. Body: a round, plump snowball body in slate grey with a snow-white belly and one white saddle patch on the middle of the back. Front legs: short legs wrapped from the knee down in thick ice-blue frost cuffs, ending in small round paws. Back legs: short legs with long flat oval snowshoe feet in pale grey, longer front to back than wide. Tail: a short stub ending in a round puff of snow-white powder with a mint-green tip. each body part is a separate, clearly shaped piece: the head, the body, each leg and the tail keep their own features; nothing hangs over, wraps around or runs across from one part onto another; where the head, legs and tail meet the body, the surface is plain main colour; no clothing, straps, chains or props. simple flat colour blocks: one solid main colour over the whole creature, the same on the head, body, legs and tail; one lighter belly colour; small details such as eyes, mouth, horns, claws and hooves in clearly different colours; no gradients, no painted shadows, no shine except the eyes, glass and water, no stripes or spots running across the joints. plain white background, even soft lighting, the whole body in view, three-quarter view from the front left, standing still in a neutral pose. No text, no base.
  ```

- **Short prompt (under 800 characters):** 799 characters. Revised 24 Nov 2026 for the concept run: a personality expression and big glossy eyes written in (owner's eye rule); see docs/art/CONCEPT_REVIEW.md.

  ```text
  Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only the eyes shine. Plain white background. Four-legged loaf body, back level, four short equal straight legs with gaps, head on a short neck in a soft collar, tail straight back. Head: round lemming face, big glossy earnest eyes, determined leader's frown, serious little mouth, a flat painted pale ice-blue fur marking across the eyes, not goggles. Body: round slate-grey snowball, white belly, white saddle patch. Front legs: thick ice-blue frost cuffs. Back legs: long flat oval snowshoe feet. Tail: white powder-puff stub, mint tip. Parts separate, plain at joints. No text, no base.
  ```

  Previous version (not used):

  ```text
  Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only eyes, glass and water shine. Three-quarter front view, plain white background. Four-legged loaf body, back level, four short equal straight legs with gaps, head on a short neck in a soft collar, tail straight back. Head: tiny round lemming face, serious mouth, pale ice-blue band across the eyes like snow goggles. Body: round slate-grey snowball, white belly, white saddle patch. Front legs: thick ice-blue frost cuffs. Back legs: long flat oval snowshoe feet. Tail: stub ending in a white powder puff with a mint tip. Separate parts, plain colour at joints. No text, no base.
  ```

- **3D settings:** Body plan Quad. Standard tier: target 2,640 assembled (head 850, torso 650, front leg 230 x2, hind leg 230 x2, tail 220); cap 3,600. Meshy Smart Topology (T2.5), segmentation on, texture on and matte, PBR off, Refine Prompt off, Image Enhancement off for the approved concept, Pose off. Torso length about 3.6 (the low end of the Quad band). Snowshoe feet stay long in Z and no wider than the leg (standard: legs never spread in X). Rare look: an alternative tail texture with the powder puff in flat aurora bands of mint, violet and pink.
- **Design sheet:**
  - **Concept and stats:** self-appointed leader of a line of one. Frost · Quad · Common · XS, weight 36 · sprinter (Frostline's fastest, still slower than Dust Canyon's sprinters).
  - **Signature parts:** head (snow-goggle band), front limbs (frost cuffs: the Defence part), tail (powder puff). Legs add the snowshoe feet.
  - **Personality:** earnest self-appointed leader · gesture **Hop** · cry: a whistle-thin "pip-pip-pip!" like a count-off · entrance: dashes in, skids to a stop and looks back for followers who are not there.
  - **Journal facts:** "It always runs at the front of a line, even when the line is only itself." "Its snowshoe prints look like a tiny marching band went past." **Favourite:** fresh untrodden snow.
  - **Moves:** head Snowplough (Frost); torso Huddle (Frost); front limbs Frost Cuff (Frost, defensive); legs Drift Dash (Frost); tail Powder Puff (Frost, Chill).
  - **Breeding hook:** Frostline's frost-cuff forelegs on a fast body. Surprising cross: **Duneskit × Flurrlem**, shutter-slat ears over snow goggles; Dust Canyon's Speed legs with Frostline's Defence forelegs.
  - **Originality (flag):** resembles round rodent mascots in general; closeness low (no electric theme, no cheek pouches). Hooks of its own: goggle band, snowshoes, powder puff. Fallback if Ayrton wants more distance: make it a snow-white ermine kit with the same goggles and puff.

### Glacibex

- **Description:** Frost, four-legged, Common, size M: a sure-footed cliff ibex with two horns of packed blue ice, each curled into a ring beside its cheeks. Frostline's striker and its gem showcase.
- **Intended appeal:** The ring horns are the silhouette everyone remembers from Whitefang's ledges, the ice greaves make it look armoured and brave, and its broad smooth horns and flat frost saddle are where an Amber or Ruby sparkle looks best: the Frostline creature people show off.
- **Meshy image prompt (full, reference only: over Meshy's 800-character limit; paste the short prompt):**

  ```text
  handmade claymation creature for a Pokémon-inspired Roblox game, soft matte hand-sculpted plasticine with visible thumbprint texture and tiny tool marks, chunky rounded proportions, big glossy cartoon eyes with a bright white highlight, an expressive face full of personality, original creature design, no clothing, no held objects, full body. a chunky four-legged creature with a rounded loaf-shaped body about one and a half times as long as it is tall, back level, standing square on four short straight legs set under the four corners of the body with a clear gap between the legs, front and back legs the same length, legs about two-thirds as long as the body is tall, feet flat on the ground; a big round head a little less than half as long as the body, held forward at the height of the back on a short thick neck that rises out of a soft rounded collar at the front of the body; a tail that starts as a small round stub at the top of the rump and points straight back; left and right sides mirror-symmetric. Head: a sturdy goat-like head with a short square muzzle, a bold little grin and two thick horns of packed pale-blue ice that sweep back and curl down into a round ring beside each cheek, ending well above the neck. Body: a compact slate-grey loaf with a pale grey belly and a broad, flat snow-white saddle of frost wool on the middle of the back. Front legs: straight legs armoured from knee to hoof in smooth ice-blue greaves, ending in charcoal split hooves. Back legs: straight sure-footed legs with charcoal split hooves. Tail: a short flag tail held straight back, tipped with a small crest of blue ice. each body part is a separate, clearly shaped piece: the head, the body, each leg and the tail keep their own features; nothing hangs over, wraps around or runs across from one part onto another; where the head, legs and tail meet the body, the surface is plain main colour; no clothing, straps, chains or props. simple flat colour blocks: one solid main colour over the whole creature, the same on the head, body, legs and tail; one lighter belly colour; small details such as eyes, mouth, horns, claws and hooves in clearly different colours; no gradients, no painted shadows, no shine except the eyes, glass and water, no stripes or spots running across the joints. plain white background, even soft lighting, the whole body in view, three-quarter view from the front left, standing still in a neutral pose. No text, no base.
  ```

- **Short prompt (under 800 characters):** 795 characters. Revised 24 Nov 2026 for the concept run: a personality expression and big glossy eyes written in (owner's eye rule); see docs/art/CONCEPT_REVIEW.md.

  ```text
  Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only the eyes shine. Plain white background. Four-legged loaf body, back level, four short equal straight legs with gaps, head on a short neck in a collar, tail straight back. Head: sturdy goat face, big glossy fearless eyes, a reckless grin, two thick pale-blue ice horns curling into a ring beside each cheek. Body: compact slate-grey loaf, pale belly, broad white frost patch on the back, not a saddle. Front legs: ice-blue fur bands above charcoal split hooves. Back legs: charcoal split hooves. Tail: short flag, small ice crest. Parts separate, plain at joints. No text, no base.
  ```

  Previous version (not used):

  ```text
  Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only eyes, glass and water shine. Three-quarter front view, plain white background. Four-legged loaf body, back level, four short equal straight legs with gaps, head on a short neck in a collar, tail straight back. Head: sturdy goat face, bold grin, two thick pale-blue ice horns curling down into a ring beside each cheek. Body: compact slate-grey loaf, pale belly, broad flat white frost saddle. Front legs: smooth ice-blue greaves to charcoal split hooves. Back legs: charcoal split hooves. Tail: short flag with a small blue ice crest. Parts separate, plain at joints. No text, no base.
  ```

- **3D settings:** Body plan Quad. Standard tier: target 2,840 assembled (head 900, torso 700, front leg 260 x2, hind leg 250 x2, tail 220); cap 3,600. Meshy Smart Topology (T2.5), segmentation on, texture on and matte, PBR off, Refine Prompt off, Image Enhancement off for the approved concept, Pose off. Torso length about 4.6. The horn rings must not touch the cheeks or the collar: a visible gap, or Meshy fuses them into the face. Gem showcase: keep the horns and saddle smooth and broad. Rare look: an alternative head texture with the horns in packed aurora ice (mint core, pink outer ring).
- **Design sheet:**
  - **Concept and stats:** fearless ledge-leaper of Whitefang. Frost · Quad · Common · M, weight 58 · striker. ★ gem showcase.
  - **Signature parts:** head (ring-curled ice horns), front limbs (ice greaves: the Defence part), torso (flat frost saddle). The ice-crest tail adds a fourth.
  - **Personality:** fearless thrill-seeker · gesture **Shake** (shakes the frost off its horns with a toss) · cry: a bright bleat that echoes twice · entrance: lands from above as if it jumped from a ledge.
  - **Journal facts:** "It climbs the summit trail at dawn just to jump down it." "Its horns grow a new ring of ice every hard winter." **Favourite:** the wind at the top of Whitefang.
  - **Moves:** head Rimeram (Frost); torso Snowbank (Frost); front limbs Greave Kick (Frost); legs Scree Slide (Sand); tail Flurry Flag (Frost, Chill).
  - **Breeding hook:** ice-greave forelegs. Surprising cross: **Wadibuck × Glacibex**, the flash-flood antelope's hollow horns on a frost saddle: "the flood froze".
  - **Originality (flag):** resembles the grass-backed riding goats of another series (Skiddo, Gogoat); closeness low to medium (both are sturdy goats with big curled horns). Differs: ice ring horns beside the cheeks, ice greaves, a frost saddle, no leaves. Fallback: horns swept straight back like an ibex instead of curled into rings.

### Woolrime

- **Description:** Frost, four-legged, Uncommon, size L: a huge musk ox whose woolly coat looks hand-knitted and has frozen into a fringe of chiming icicles. Frostline's bruiser.
- **Intended appeal:** It looks like the warmest blanket in the world walking through a blizzard, with a pompom on its tail, and its icicle fringe chimes as it moves; big, slow and protective, the creature you want standing between your team and the storm.
- **Meshy image prompt (full, reference only: over Meshy's 800-character limit; paste the short prompt):**

  ```text
  handmade claymation creature for a Pokémon-inspired Roblox game, soft matte hand-sculpted plasticine with visible thumbprint texture and tiny tool marks, chunky rounded proportions, big glossy cartoon eyes with a bright white highlight, an expressive face full of personality, original creature design, no clothing, no held objects, full body. a chunky four-legged creature with a rounded loaf-shaped body about one and a half times as long as it is tall, back level, standing square on four short straight legs set under the four corners of the body with a clear gap between the legs, front and back legs the same length, legs about two-thirds as long as the body is tall, feet flat on the ground; a big round head a little less than half as long as the body, held forward at the height of the back on a short thick neck that rises out of a soft rounded collar at the front of the body; a tail that starts as a small round stub at the top of the rump and points straight back; left and right sides mirror-symmetric. Head: a broad, low ox head with a soft fringe of snow-white wool over sleepy eyes, a wide cranberry-pink nose, and two heavy charcoal horns that meet in a thick boss across the brow and curve down and out beside the face. Body: a huge, heavy loaf of warm oatmeal-cream wool sculpted with a deep cable-knit pattern pressed into the clay, like a hand-knitted blanket; along the lower edge of each side hangs a fringe of short, blunt, chunky ice-blue icicles, ending well above the leg tops; a snow-white belly. Front legs: thick pillar legs wrapped in packed-ice gauntlets from knee to hoof, ending in big round charcoal hooves. Back legs: thick pillar legs with big round charcoal hooves like snow boots. Tail: a short tail ending in one big round pine-green pompom. each body part is a separate, clearly shaped piece: the head, the body, each leg and the tail keep their own features; nothing hangs over, wraps around or runs across from one part onto another; where the head, legs and tail meet the body, the surface is plain main colour; no clothing, straps, chains or props. simple flat colour blocks: one solid main colour over the whole creature, the same on the head, body, legs and tail; one lighter belly colour; small details such as eyes, mouth, horns, claws and hooves in clearly different colours; no gradients, no painted shadows, no shine except the eyes, glass and water, no stripes or spots running across the joints. plain white background, even soft lighting, the whole body in view, three-quarter view from the front left, standing still in a neutral pose. No text, no base.
  ```

- **Short prompt (under 800 characters):** 785 characters. Revised 24 Nov 2026 for the concept run: a personality expression and big glossy eyes written in (owner's eye rule); see docs/art/CONCEPT_REVIEW.md.

  ```text
  Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only the eyes shine. Plain white background. Four-legged loaf body, back level, four short equal straight legs with gaps, head on a short neck in a soft collar, tail straight back. Head: broad ox face, big glossy gruff eyes under a white wool fringe, a protective scowl, cranberry nose, charcoal horns meeting in a boss. Body: huge oatmeal loaf with deep cable-knit pressed in the clay, short blunt ice-blue icicle fringe along the lower sides, white belly. Front legs: packed-ice gauntlets. Tail: one big pine-green pompom. Parts separate, plain at joints. No text, no base.
  ```

  Previous version (not used):

  ```text
  Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only eyes, glass and water shine. Three-quarter front view, plain white background. Four-legged loaf body, back level, four short equal straight legs with gaps, head on a short neck in a soft collar, tail straight back. Head: broad ox face, white wool fringe over the eyes, cranberry nose, charcoal horns meeting in a boss. Body: huge oatmeal loaf with deep cable-knit pressed in the clay, short blunt ice-blue icicle fringe along the lower sides, white belly. Front legs: packed-ice gauntlets. Tail: one big pine-green pompom. Separate parts, plain colour at joints. No text, no base.
  ```

- **3D settings:** Body plan Quad. Standard tier: target 2,960 assembled (head 850, torso 850, front leg 260 x2, hind leg 250 x2, tail 240); cap 3,600. Meshy Smart Topology (T2.5), segmentation on, texture on and matte, PBR off, Refine Prompt off, Image Enhancement off for the approved concept, Pose off. Torso length about 6.0 (top of the Quad band, the biggest Frostline creature). The cable-knit is shallow relief; at this budget most of it ends up in the texture, which is fine. The icicle fringe is torso-owned and must stop at least 1 R above the leg sockets (standard 2.1 rule 3). Rare look: an alternative torso texture with a cranberry-and-white snowflake band across the knit (a winter-jumper look), fading out before every joint zone.
- **Design sheet:**
  - **Concept and stats:** the herd's gruff guardian. Frost · Quad · Uncommon · L, weight 78 · bruiser (the most Defence on four legs in Frostline, the slowest).
  - **Signature parts:** head (brow boss horns), torso (knitted coat and icicle fringe), front limbs (ice gauntlets: the Defence part), tail (pompom).
  - **Personality:** gruff protector · gesture **Puff** (a slow cloud of frost breath) · cry: a deep "hrrumf" with the fringe tinkling after it · entrance: plods in and plants itself in front of the team.
  - **Journal facts:** "A herd circles its young with icicles out, and nothing gets through." "Rimewick sets its clocks by the chime of the herd going down to drink." **Favourite:** lichen scraped from under the snow.
  - **Moves:** head Brow Bash (Frost); torso Icicle Fringe (Frost, Chill); front limbs Frost Gauntlet (Frost, defensive); legs Stamp (Sand); tail Pompom Thump (Frost).
  - **Breeding hook:** the gauntlet forelegs are the heaviest Defence part on four legs. Surprising cross: **Sloshcalf × Woolrime** (roster plan section 6): a pond calf in an icicle-fringed fleece, "the pond froze over".
  - **Originality (flag):** resembles a shaggy tusked mammoth (Mamoswine) and an afro buffalo (Bouffalant); closeness low (no tusks, no trunk, no afro). Differs: musk-ox brow boss, knitted coat, icicle fringe, pompom tail. Fallback: none needed; if the knit reads as clothing, make it plain shaggy wool.

### Stinkglut

- **Description:** Toxic, four-legged, Common, size M: a stocky wolverine-like glutton with sulphur-yellow side bands that sleeps curled on the hot vents of the springs. Frostline's four-legged underdog, with a Fire move on its torso.
- **Intended appeal:** Ugly-cute and shameless: a grumpy, satisfied snacker with one tooth showing, warm in a cold biome, and the first creature that can carry Fire (the answer to Frost) before Emberfall exists. Players keep it because it is useful and because it is funny.
- **Meshy image prompt (full, reference only: over Meshy's 800-character limit; paste the short prompt):**

  ```text
  handmade claymation creature for a Pokémon-inspired Roblox game, soft matte hand-sculpted plasticine with visible thumbprint texture and tiny tool marks, chunky rounded proportions, big glossy cartoon eyes with a bright white highlight, an expressive face full of personality, original creature design, no clothing, no held objects, full body. a chunky four-legged creature with a rounded loaf-shaped body about one and a half times as long as it is tall, back level, standing square on four short straight legs set under the four corners of the body with a clear gap between the legs, front and back legs the same length, legs about two-thirds as long as the body is tall, feet flat on the ground; a big round head a little less than half as long as the body, held forward at the height of the back on a short thick neck that rises out of a soft rounded collar at the front of the body; a tail that starts as a small round stub at the top of the rump and points straight back; left and right sides mirror-symmetric. Head: a broad, flat wolverine-like head in dark chocolate brown with a pale steam-white brow band, a squashed nose, little round ears and a smug, satisfied grin with one small tooth showing. Body: a stocky, low dark chocolate loaf with a broad sulphur-yellow band along each side, stopping well short of the shoulders and the rump; on the middle of the back a small crust of chunky sulphur-yellow crystals around one round warm orange spring stone, painted, not glowing; a pale belly. Front legs: heavy forelegs with thick yellow-crusted cuffs and big blunt pale claws. Back legs: short sturdy legs with broad flat feet. Tail: a bushy tail held straight back, chocolate with a steam-white tip. each body part is a separate, clearly shaped piece: the head, the body, each leg and the tail keep their own features; nothing hangs over, wraps around or runs across from one part onto another; where the head, legs and tail meet the body, the surface is plain main colour; no clothing, straps, chains or props. simple flat colour blocks: one solid main colour over the whole creature, the same on the head, body, legs and tail; one lighter belly colour; small details such as eyes, mouth, horns, claws and hooves in clearly different colours; no gradients, no painted shadows, no shine except the eyes, glass and water, no stripes or spots running across the joints. plain white background, even soft lighting, the whole body in view, three-quarter view from the front left, standing still in a neutral pose. No text, no base.
  ```

- **Short prompt (under 800 characters):** 791 characters. Revised 24 Nov 2026 for the concept run: a personality expression and big glossy eyes written in (owner's eye rule); see docs/art/CONCEPT_REVIEW.md.

  ```text
  Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only eyes, glass and water shine. Plain white background. Four-legged loaf body, back level, four short equal straight legs with gaps, head on a short neck in a soft collar, tail straight back. Head: broad flat wolverine face, dark chocolate, pale brow band, big glossy greedy eyes, a shameless grin with one tooth. Body: stocky low chocolate loaf, sulphur-yellow band on each side, sulphur crystal crust on the back around one warm orange stone, not glowing. Front legs: yellow-crusted cuffs, blunt claws. Tail: bushy, white tip. Parts separate, plain at joints. No text, no base.
  ```

  Previous version (not used):

  ```text
  Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only eyes, glass and water shine. Three-quarter front view, plain white background. Four-legged loaf body, back level, four short equal straight legs with gaps, head on a short neck in a soft collar, tail straight back. Head: broad flat wolverine face, dark chocolate, pale brow band, smug grin with one tooth. Body: stocky low chocolate loaf, sulphur-yellow band on each side, small sulphur crystal crust on the back around one warm orange stone, painted not glowing. Front legs: yellow-crusted cuffs, blunt claws. Tail: bushy, white tip. Parts separate, plain at joints. No text, no base.
  ```

- **3D settings:** Body plan Quad. Standard tier: target 2,840 assembled (head 800, torso 800, front leg 260 x2, hind leg 230 x2, tail 260); cap 3,600. Meshy Smart Topology (T2.5), segmentation on, texture on and matte, PBR off, Refine Prompt off, Image Enhancement off for the approved concept, Pose off. Torso length about 4.8. The side bands are torso detail and must end 1 R short of the collar, the leg sockets and the tail socket. The spring stone is opaque paint; a heat-shimmer or steam particle can be added in Roblox at a torso attachment. Rare look: an alternative torso texture with the spring stone and crust in bright gold.
- **Design sheet:**
  - **Concept and stats:** the vent-napper. Toxic · Quad · Common · M, weight 62 · all-rounder, underdog.
  - **Signature parts:** head (smug one-tooth grin and brow band), torso (sulphur bands, crust and spring stone: the Fire move), front limbs (crusted cuffs and claws).
  - **Personality:** shameless snacker · gesture **Gulp** · cry: a wheezy hiccup and a contented burp · entrance: waddles in still chewing.
  - **Journal facts:** "It sleeps on the hot vents and eats whatever the steam cooks." "Ice-fishers leave one fish on the hut step so it leaves the rest alone." **Favourite:** a warm stone and somebody else's lunch.
  - **Moves:** head Snaffle Bite (Toxic); torso Sulphur Puff (Toxic, poison) and **Vent Heat (Fire, torso only: the teaser)**; front limbs Raking Claws (Toxic); legs Scramble (Toxic); tail Stench Flag (Toxic).
  - **Breeding hook:** its torso is the only four-legged Fire-move torso before Emberfall. Surprising cross: **Bogbellow × Stinkglut**, the Mire's peat-vent back on a wolverine: the two gluttons of the north.
  - **Originality (flag):** resembles a striped Toxic skunk (Stunky, Skuntank); closeness medium (a stocky Toxic mammal with a pale stripe). Differs: a wolverine body, side bands instead of a back stripe, a tail held straight back, sulphur crust and spring stone, chocolate and yellow not purple. Fallback: drop the bands and show the sulphur only as the back crust.

### Hoarmot

- **Description:** Frost, two-legged, Common, size M: an upright snow marmot whose fur is thick with hoarfrost and who whistles to warn of weather. Frostline's two-legged tank.
- **Intended appeal:** Round, upright and pompous, with puckered whistling lips and a little crown of frost feathers: it looks like the town's self-appointed weatherman, and its forecasts are actually right, which children love to repeat.
- **Meshy image prompt (full, reference only: over Meshy's 800-character limit; paste the short prompt):**

  ```text
  handmade claymation creature for a Pokémon-inspired Roblox game, soft matte hand-sculpted plasticine with visible thumbprint texture and tiny tool marks, chunky rounded proportions, big glossy cartoon eyes with a bright white highlight, an expressive face full of personality, original creature design, no clothing, no held objects, full body. a chunky two-legged creature with an upright rounded pear-shaped body, widest at the belly, about as wide as it is tall; a big round head nearly as wide as the body sitting straight on top of the body, its short neck tucked into a soft rounded collar; two short arms hanging straight down at the sides from high on the body, with a clear gap between the arms and the body, hands ending well above the ground; two short straight legs set close together under the body with a small gap between them, feet flat on the ground; a small tail low at the back pointing straight back; left and right sides mirror-symmetric. Head: a round, chubby marmot head with fat cheeks, small round ears, two little front teeth, lips puckered as if whistling, and on top a small crown of chunky white-blue hoarfrost feathers standing up like a crest. Body: a big round pear-shaped body in warm slate-brown fur with a cream belly and a thick snow-white frost bib on the chest, below the collar. Arms: short stubby arms ending in blunt paws wrapped in rounded ice-blue frost cuffs. Legs: short thick legs with long flat oval snowshoe feet in pale grey. Tail: a short bushy tail pointing straight back with a white frosted tip. each body part is a separate, clearly shaped piece: the head, the body, each leg and the tail keep their own features; nothing hangs over, wraps around or runs across from one part onto another; where the head, legs and tail meet the body, the surface is plain main colour; no clothing, straps, chains or props. simple flat colour blocks: one solid main colour over the whole creature, the same on the head, body, legs and tail; one lighter belly colour; small details such as eyes, mouth, horns, claws and hooves in clearly different colours; no gradients, no painted shadows, no shine except the eyes, glass and water, no stripes or spots running across the joints. plain white background, even soft lighting, the whole body in view, three-quarter view from the front left, standing still in a neutral pose. No text, no base.
  ```

- **Short prompt (under 800 characters):** 799 characters. Revised 24 Nov 2026 for the concept run: a personality expression and big glossy eyes written in (owner's eye rule); see docs/art/CONCEPT_REVIEW.md.

  ```text
  Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only the eyes shine. Plain white background. Upright pear body, big head in a soft collar, short arms hanging down with a gap, short legs close together, small low tail. Head: round chubby marmot face, big glossy self-important eyes under a pompous brow, fat cheeks, lips puckered to whistle, a small crown of chunky white-blue hoarfrost feathers on top. Body: big round slate-brown pear, cream belly, white frost bib below the collar. Arms: blunt paws in ice-blue frost cuffs. Legs: flat oval snowshoe feet. Tail: short bushy, white tip. Parts separate, plain at joints. No text, no base.
  ```

  Previous version (not used):

  ```text
  Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only eyes, glass and water shine. Three-quarter front view, plain white background. Upright pear body, big head in a soft collar, short arms hanging down with a gap, short legs close together, small low tail. Head: round chubby marmot face, fat cheeks, lips puckered to whistle, a small crown of chunky white-blue hoarfrost feathers on top. Body: big round slate-brown pear, cream belly, white frost bib below the collar. Arms: blunt paws in ice-blue frost cuffs. Legs: flat oval snowshoe feet. Tail: short bushy, white tip. Separate parts, plain colour at joints. No text, no base.
  ```

- **3D settings:** Body plan Biped. Standard tier: target 2,930 assembled (head 850, torso 800, arm 280 x2, leg 250 x2, tail 220); cap 3,600. Meshy Smart Topology (T2.5), segmentation on, texture on and matte, PBR off, Refine Prompt off, Image Enhancement off for the approved concept, Pose A-Pose (the arms are straightened to hang down in Blender, standard step 7). Torso height about 3.3. The frost crest stays on the top of the head, inside its silhouette, and the frost bib ends 1 R below the collar and clear of the arm sockets. Rare look: an alternative head texture with the frost crest in aurora mint and pink.
- **Design sheet:**
  - **Concept and stats:** Rimewick's weather prophet. Frost · Biped · Common · M, weight 60 · tank (the most Hp and Defence on two legs in Frostline).
  - **Signature parts:** head (frost-feather crest and whistling lips), torso (frost bib), arms (frost cuffs: the Defence part). Snowshoe feet on the legs.
  - **Personality:** pompous forecaster · gesture **Stretch** (draws itself up tall before it whistles) · cry: a two-note weather whistle, "fwee-fwooo" · entrance: stands up straight and announces itself with the whistle.
  - **Journal facts:** "It whistles twice before snow and three times before a blizzard, and it is right more often than the almanac." "It sulks for a day if the weather proves it wrong." **Favourite:** a sunny rock after a storm.
  - **Moves:** head Gale Whistle (Storm); torso Hoarfrost Coat (Frost, defensive); arms Frost Cuff Clout (Frost); legs Snowshoe Stomp (Frost); tail Frost Flick (Frost, Chill).
  - **Breeding hook:** frost-cuff arms with high Defence. Surprising cross: **Moatkeep × Hoarmot**, a sandcastle body under a weather-whistling head: two fussy homebodies.
  - **Originality (flag):** no close match known; nearest are chubby upright rodents in general (Bidoof's line is a beaver, Furret a ferret). Closeness low. Fallback: none needed.

### Rimefern

- **Description:** Frost, two-legged, Common, size XS: a tiny sprite that grows like the frost ferns on a window pane, with fiddlehead hands. Frostline's sprinter and the biome's clear token.
- **Intended appeal:** The prettiest small creature in the snow: frost-fern fronds on its head, curled fiddlehead hands and a tinkling giggle. It is the token gift and a strong answer to Crystal Deep next door, so every player meets it and many keep it.
- **Meshy image prompt (full, reference only: over Meshy's 800-character limit; paste the short prompt):**

  ```text
  handmade claymation creature for a Pokémon-inspired Roblox game, soft matte hand-sculpted plasticine with visible thumbprint texture and tiny tool marks, chunky rounded proportions, big glossy cartoon eyes with a bright white highlight, an expressive face full of personality, original creature design, no clothing, no held objects, full body. a chunky two-legged creature with an upright rounded pear-shaped body, widest at the belly, about as wide as it is tall; a big round head nearly as wide as the body sitting straight on top of the body, its short neck tucked into a soft rounded collar; two short arms hanging straight down at the sides from high on the body, with a clear gap between the arms and the body, hands ending well above the ground; two short straight legs set close together under the body with a small gap between them, feet flat on the ground; a small tail low at the back pointing straight back; left and right sides mirror-symmetric. Head: a round head with big friendly eyes, a tiny mischievous smile and a crest of three chunky curling frost-fern fronds on top, each as thick as a finger, in pale ice blue with white edges. Body: a small pear-shaped body in pale ice blue with a white belly painted with one curling frost-fern swirl in the middle. Arms: short arms ending in rounded, curled fern-fiddlehead hands in deeper blue, like frosted spirals. Legs: short slim legs with small round feet in deeper blue. Tail: a short tail ending in a single chunky frost-fern frond fanned out straight back. each body part is a separate, clearly shaped piece: the head, the body, each leg and the tail keep their own features; nothing hangs over, wraps around or runs across from one part onto another; where the head, legs and tail meet the body, the surface is plain main colour; no clothing, straps, chains or props. simple flat colour blocks: one solid main colour over the whole creature, the same on the head, body, legs and tail; one lighter belly colour; small details such as eyes, mouth, horns, claws and hooves in clearly different colours; no gradients, no painted shadows, no shine except the eyes, glass and water, no stripes or spots running across the joints. plain white background, even soft lighting, the whole body in view, three-quarter view from the front left, standing still in a neutral pose. No text, no base.
  ```

- **Short prompt (under 800 characters):** 795 characters. Revised 24 Nov 2026 for the concept run: a personality expression and big glossy eyes written in (owner's eye rule); see docs/art/CONCEPT_REVIEW.md.

  ```text
  Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only the eyes shine. Plain white background. Upright pear body, big head in a soft collar, short arms hanging down with a gap, short legs close together, small low tail. Head: round, big glossy eyes in a mischievous sideways squint, impish grin, a crest of three chunky curling frost-fern fronds, finger-thick, pale blue with white edges. Body: small pale ice-blue pear, white belly with one fern swirl. Arms: curled fern-fiddlehead hands in deeper blue. Legs: slim, small round feet. Tail: one chunky fern frond fanned straight back. Parts separate, plain at joints. No text, no base.
  ```

  Previous version (not used):

  ```text
  Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only eyes, glass and water shine. Three-quarter front view, plain white background. Upright pear body, big head in a soft collar, short arms hanging down with a gap, short legs close together, small low tail. Head: round, big eyes, mischievous smile, a crest of three chunky curling frost-fern fronds, finger-thick, pale blue with white edges. Body: small pale ice-blue pear, white belly with one fern swirl. Arms: curled fern-fiddlehead hands in deeper blue. Legs: slim, small round feet. Tail: one chunky fern frond fanned straight back. Parts separate, plain at joints. No text, no base.
  ```

- **3D settings:** Body plan Biped. Standard tier: target 2,770 assembled (head 900, torso 650, arm 260 x2, leg 220 x2, tail 260); cap 3,600. Meshy Smart Topology (T2.5), segmentation on, texture on and matte, PBR off, Refine Prompt off, Image Enhancement off for the approved concept, Pose A-Pose (the arms are straightened to hang down in Blender, standard step 7). Torso height about 2.5 (bottom of the Biped band). Pale coat: if background removal eats the belly, regenerate on light grey (04_PROMPT_CRAFT section 3). The fronds must be chunky or Meshy breaks them; fine frost lines go in the texture. Rare look: an alternative head texture with the fronds in flat aurora bands of mint, violet and pink.
- **Design sheet:**
  - **Concept and stats:** the window-pane prankster. Frost · Biped · Common · XS, weight 34 · sprinter. Token gift (Frost beats Crystal, the next biome).
  - **Signature parts:** head (frost-fern crest), arms (fiddlehead hands: the Defence part, curled like shields), tail (fern-frond fan). The belly swirl adds a torso mark.
  - **Personality:** playful prankster · gesture **Spin** (a quick twirl that leaves a frost pattern round its feet) · cry: a tinkling giggle like a spoon on a glass · entrance: spins in from the side.
  - **Journal facts:** "Windows in Rimewick frost over in fern patterns the morning after one visits." "Breathe on it and it blushes pink." **Favourite:** a cold clear window to draw on.
  - **Moves:** head Frond Frost (Frost); torso Pane Glaze (Frost, Chill); arms Fiddlehead Jab (Frost); legs Glide (Frost); tail Fern Flick (Leaf, a second answer to Crystal).
  - **Breeding hook:** a light, fast frame with shield-curled arms. Surprising cross: **Thatchling × Rimefern**, Dust Canyon's green pompom hands beside frost fiddleheads: summer and winter ferns.
  - **Originality (flag):** resembles small ice sprites (Snorunt) and an ice moth (Frosmoth); closeness low (no cone head, no wings). Differs: fern fronds and fiddlehead hands. Fallback: none needed.

### Chiselrime

- **Description:** Frost, two-legged, Uncommon, size L: a stout russet river beaver with two ice-chisel teeth, forearms armoured in ice floes and a tail frozen flat as a paddle. Frostline's two-legged bruiser and the quest gift.
- **Intended appeal:** A hard-working builder with a job you can see: it cuts the fishing holes on Glass Lake and dams the gorge. Big teeth, a slappable ice paddle and stacked-floe arm armour make it read as strong and dependable, a reward worth a quest.
- **Meshy image prompt (full, reference only: over Meshy's 800-character limit; paste the short prompt):**

  ```text
  handmade claymation creature for a Pokémon-inspired Roblox game, soft matte hand-sculpted plasticine with visible thumbprint texture and tiny tool marks, chunky rounded proportions, big glossy cartoon eyes with a bright white highlight, an expressive face full of personality, original creature design, no clothing, no held objects, full body. a chunky two-legged creature with an upright rounded pear-shaped body, widest at the belly, about as wide as it is tall; a big round head nearly as wide as the body sitting straight on top of the body, its short neck tucked into a soft rounded collar; two short arms hanging straight down at the sides from high on the body, with a clear gap between the arms and the body, hands ending well above the ground; two short straight legs set close together under the body with a small gap between them, feet flat on the ground; a small tail low at the back pointing straight back; left and right sides mirror-symmetric. Head: a round beaver head with chubby cheeks, a determined little frown, small round ears and two big square front teeth of pale ice blue like ice chisels. Body: a stout pear-shaped body in russet orange with a cream belly marked with one white snowflake shape. Arms: thick forearms armoured with layered plates of pale-blue ice like stacked floes, ending in broad paws with three blunt ice-blue pick claws. Legs: short thick legs with flat dark brown webbed feet, no wider than the leg. Tail: a broad, flat, rounded paddle tail of ice pointing straight back, painted pale aqua with white crack lines. each body part is a separate, clearly shaped piece: the head, the body, each leg and the tail keep their own features; nothing hangs over, wraps around or runs across from one part onto another; where the head, legs and tail meet the body, the surface is plain main colour; no clothing, straps, chains or props. simple flat colour blocks: one solid main colour over the whole creature, the same on the head, body, legs and tail; one lighter belly colour; small details such as eyes, mouth, horns, claws and hooves in clearly different colours; no gradients, no painted shadows, no shine except the eyes, glass and water, no stripes or spots running across the joints. plain white background, even soft lighting, the whole body in view, three-quarter view from the front left, standing still in a neutral pose. No text, no base.
  ```

- **Short prompt (under 800 characters):** 789 characters. Revised 24 Nov 2026 for the concept run: a personality expression and big glossy eyes written in (owner's eye rule); see docs/art/CONCEPT_REVIEW.md.

  ```text
  Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only the eyes shine. Plain white background. Upright pear body, big head in a collar, short arms hanging down with a gap, short legs close together, small low tail. Head: round beaver face, chubby cheeks, big glossy eyes narrowed in a determined frown, two big square pale-blue ice teeth like chisels. Body: stout russet-orange pear, cream belly with a white snowflake. Arms: layered ice-floe plates, blunt ice-blue pick claws. Legs: flat dark brown webbed feet. Tail: broad flat rounded ice paddle, pale aqua with white cracks. Parts separate, plain at joints. No text, no base.
  ```

  Previous version (not used):

  ```text
  Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only eyes, glass and water shine. Three-quarter front view, plain white background. Upright pear body, big head in a collar, short arms hanging down with a gap, short legs close together, small low tail. Head: round beaver face, chubby cheeks, determined frown, two big square pale-blue ice teeth like chisels. Body: stout russet-orange pear, cream belly with a white snowflake. Arms: layered ice-floe plates, blunt ice-blue pick claws. Legs: flat dark brown webbed feet. Tail: broad flat rounded ice paddle, pale aqua with white cracks. Parts separate, plain at joints. No text, no base.
  ```

- **3D settings:** Body plan Biped. Standard tier: target 2,980 assembled (head 800, torso 800, arm 310 x2, leg 240 x2, tail 280); cap 3,600. Meshy Smart Topology (T2.5), segmentation on, texture on and matte, PBR off, Refine Prompt off, Image Enhancement off for the approved concept, Pose A-Pose (the arms are straightened to hang down in Blender, standard step 7). Torso height about 3.8. The paddle tail lies flat and straight back, clear of the ground (Biped tails never reach the ground). Russet orange because it pops against snow and ice blue better than brown. Rare look: an alternative tail texture with a small orange fish painted frozen inside the paddle.
- **Design sheet:**
  - **Concept and stats:** Glass Lake's ice-cutter. Frost · Biped · Uncommon · L, weight 74 · bruiser (the most Attack in Frostline). Quest gift.
  - **Signature parts:** head (ice-chisel teeth), arms (stacked-floe armour: the Defence part), tail (ice paddle).
  - **Personality:** tireless builder · gesture **Clap** (slaps its paddle on the ground like applause for its own work) · cry: a clacking "tok-tok" of teeth · entrance: slaps the paddle twice and stands to attention.
  - **Journal facts:** "It cuts the fishing holes on Glass Lake, then sits in them to keep them from freezing over." "A Chiselrime dam is level to the width of a whisker." **Favourite:** a birch log with the bark still on.
  - **Moves:** head Ice Chisel (Frost); torso Dam Up (Water, defensive); arms Floe Guard (Frost); legs Shore Shove (Water); tail Paddle Slap (Frost, Chill).
  - **Breeding hook:** the heaviest Defence arms on two legs. Surprising cross: **Splashjack × Chiselrime**, huge paddle feet and an ice paddle tail: the best swimmer that never swims.
  - **Originality (flag):** resembles the famous buck-toothed flat-tailed beaver (Bidoof, Bibarel); closeness medium (same animal, same teeth and paddle tail, which every beaver has). Differs: russet orange, an upright stout bruiser, ice-chisel teeth, ice-floe arm armour, an ice paddle. Fallback: an otter body with the same ice teeth and paddle (the roster plan's spare "ice-fishing otter").

### Simmerling

- **Description:** Toxic, two-legged, Common, size M: a hot-spring snow macaque with sulphur-crusted fur and a little folded bath towel of steam-white fur on its head. Frostline's two-legged underdog, with a Fire move on its torso.
- **Intended appeal:** The coziest creature in the game: a blissed-out monkey fresh from the hot spring, pink-faced, eyes closed, with a towel of fur on its head. Warm, funny and a Fire-move carrier before Emberfall, it is the one players screenshot.
- **Meshy image prompt (full, reference only: over Meshy's 800-character limit; paste the short prompt):**

  ```text
  handmade claymation creature for a Pokémon-inspired Roblox game, soft matte hand-sculpted plasticine with visible thumbprint texture and tiny tool marks, chunky rounded proportions, big glossy cartoon eyes with a bright white highlight, an expressive face full of personality, original creature design, no clothing, no held objects, full body. a chunky two-legged creature with an upright rounded pear-shaped body, widest at the belly, about as wide as it is tall; a big round head nearly as wide as the body sitting straight on top of the body, its short neck tucked into a soft rounded collar; two short arms hanging straight down at the sides from high on the body, with a clear gap between the arms and the body, hands ending well above the ground; two short straight legs set close together under the body with a small gap between them, feet flat on the ground; a small tail low at the back pointing straight back; left and right sides mirror-symmetric. Head: a round snow-monkey head with a soft pink face, rosy cheeks, eyes squeezed shut in bliss, a contented smile, a shaggy cheek ruff of steam-white fur framing the face, and on top a flat folded square of steam-white fur like a little bath towel. Body: a round pear-shaped body in pale steam-grey fur with a lumpy sulphur-yellow mineral crust on the belly and one round warm orange spring stone set in the middle, painted, not glowing. Arms: short arms with soft pink hands. Legs: short legs with soft pink feet. Tail: a short stubby tail pointing straight back with a sulphur-yellow tip. each body part is a separate, clearly shaped piece: the head, the body, each leg and the tail keep their own features; nothing hangs over, wraps around or runs across from one part onto another; where the head, legs and tail meet the body, the surface is plain main colour; no clothing, straps, chains or props. simple flat colour blocks: one solid main colour over the whole creature, the same on the head, body, legs and tail; one lighter belly colour; small details such as eyes, mouth, horns, claws and hooves in clearly different colours; no gradients, no painted shadows, no shine except the eyes, glass and water, no stripes or spots running across the joints. plain white background, even soft lighting, the whole body in view, three-quarter view from the front left, standing still in a neutral pose. No text, no base.
  ```

- **Short prompt (under 800 characters):** 792 characters. Revised 24 Nov 2026 for the concept run: a personality expression and big glossy eyes written in (owner's eye rule); see docs/art/CONCEPT_REVIEW.md.

  ```text
  Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only eyes, glass and water shine. Plain white background. Upright pear body, big head in a collar, short arms hanging down with a gap, short legs close together, small low tail. Head: round snow-monkey face, soft pink, big glossy blissful half-closed eyes, white cheek ruff, a flat folded square of white fur on top like a bath towel. Body: round pale steam-grey pear, lumpy sulphur-yellow crust on the belly with one warm orange stone, painted not glowing. Arms and legs: short, soft pink hands and feet. Tail: stubby, yellow tip. Parts separate, plain at joints. No text, no base.
  ```

  Previous version (not used):

  ```text
  Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only eyes, glass and water shine. Three-quarter front view, plain white background. Upright pear body, big head in a collar, short arms hanging down with a gap, short legs close together, small low tail. Head: round snow-monkey face, soft pink, eyes shut in bliss, white cheek ruff, a flat folded square of white fur on top like a bath towel. Body: round pale steam-grey pear, lumpy sulphur-yellow crust on the belly with one warm orange stone, painted not glowing. Arms and legs: short, soft pink hands and feet. Tail: stubby, yellow tip. Parts separate, plain at joints. No text, no base.
  ```

- **3D settings:** Body plan Biped. Standard tier: target 2,790 assembled (head 850, torso 800, arm 250 x2, leg 220 x2, tail 200); cap 3,600. Meshy Smart Topology (T2.5), segmentation on, texture on and matte, PBR off, Refine Prompt off, Image Enhancement off for the approved concept, Pose A-Pose (the arms are straightened to hang down in Blender, standard step 7). Torso height about 3.2. Eyes are shut in the concept: the importer keeps the face paint as detail (alpha 0); if the house eyes are needed for animation, make a second concept with eyes open and keep the closed-eye texture as the idle face. Steam is a Roblox particle at a head attachment, not mesh. Rare look: an alternative head texture with the towel tuft in cranberry red.
- **Design sheet:**
  - **Concept and stats:** the hot-spring regular. Toxic · Biped · Common · M, weight 55 · all-rounder, underdog.
  - **Signature parts:** head (towel tuft, pink face, cheek ruff), torso (sulphur crust and spring stone: the Fire move), tail (yellow-tipped stub). Arms carry modest Defence, as Frostline arms do.
  - **Personality:** blissed-out soaker · gesture **Sway** (rocks gently as if still in the water) · cry: a long contented "ahhhh" · entrance: steps in shaking off droplets, then sighs.
  - **Journal facts:** "It has not been fully dry since it was born." "The bathhouse in Steamvale lets it in free; it brings its own towel." **Favourite:** the hottest pool, at dusk, with snow falling.
  - **Moves:** head Towel Snap (Toxic); torso Sulphur Soak (Toxic, poison) and **Spring Scald (Fire, torso only: the teaser)**; arms Mineral Slap (Toxic); legs Steam Hop (Water); tail Fume Flick (Toxic).
  - **Breeding hook:** the only two-legged Fire-move torso before Emberfall. Surprising cross: **Bulbroth × Simmerling**, a cauldron belly under a bath-towel head: the bathhouse cook.
  - **Originality (flag):** resembles the fire monkeys with tuft hair (Pansear, Simisear) and a hot-spring monkey idea in general; closeness low to medium (an upright monkey with a crest). Differs: a pale snow monkey, a folded towel tuft instead of a flame, eyes shut in bliss, Toxic, no red or orange body. Fallback: a steam-white cheek ruff only, no head tuft.

### Driftmother

- **Description:** Giant, Frost, four-legged: a colossal snow hare whose back is a snowfield with a stand of pines and whose long lop ears carry the colours of the aurora. Frostline's giant; when the tear's leak drives it wild, it stamps and sets off avalanches.
- **Intended appeal:** A giant that is soft, motherly and enormous: the aurora is said to come off her ears, and calming her turns the wrong-coloured auroras back to green. A forest on her back and a hare's face make her the gentlest-looking giant, which makes the fight feel like a rescue.
- **Meshy image prompt (full, reference only: over Meshy's 800-character limit; paste the short prompt):**

  ```text
  handmade claymation creature for a Pokémon-inspired Roblox game, soft matte hand-sculpted plasticine with visible thumbprint texture and tiny tool marks, chunky rounded proportions, big glossy cartoon eyes with a bright white highlight, an expressive face full of personality, original creature design, no clothing, no held objects, full body. a chunky four-legged creature with a rounded loaf-shaped body about one and a half times as long as it is tall, back level, standing square on four short straight legs set under the four corners of the body with a clear gap between the legs, front and back legs the same length, legs about two-thirds as long as the body is tall, feet flat on the ground; a big round head a little less than half as long as the body, held forward at the height of the back on a short thick neck that rises out of a soft rounded collar at the front of the body; a tail that starts as a small round stub at the top of the rump and points straight back; left and right sides mirror-symmetric. A giant of its kind, broad and heavy, with the same chunky toy proportions. Head: a huge round hare head with kind, heavy-lidded eyes, a pink nose, a soft smile and two very long lop ears hanging down beside the cheeks and ending above the neck, each ear painted in flat bands of mint green, violet and pink like the northern lights, with a few thin painted magenta cracks. Body: a massive pale silver-blue loaf with a white belly; its back is a smooth snowfield carrying a small stand of five chunky snow-capped pine trees in pine green, set well behind the neck and in front of the tail. Front legs: thick forelegs armoured from the knee down in smooth plates of packed ice. Back legs: thick legs with long flat oval snowshoe feet, longer front to back than wide. Tail: a short stub ending in a huge round snow-white puff. each body part is a separate, clearly shaped piece: the head, the body, each leg and the tail keep their own features; nothing hangs over, wraps around or runs across from one part onto another; where the head, legs and tail meet the body, the surface is plain main colour; no clothing, straps, chains or props. simple flat colour blocks: one solid main colour over the whole creature, the same on the head, body, legs and tail; one lighter belly colour; small details such as eyes, mouth, horns, claws and hooves in clearly different colours; no gradients, no painted shadows, no shine except the eyes, glass and water, no stripes or spots running across the joints. plain white background, even soft lighting, the whole body in view, three-quarter view from the front left, standing still in a neutral pose. No text, no base.
  ```

- **Short prompt (under 800 characters):** 799 characters. Revised 24 Nov 2026 for the concept run: a personality expression and big glossy eyes written in (owner's eye rule); see docs/art/CONCEPT_REVIEW.md.

  ```text
  Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only the eyes shine. Plain white background. Four-legged loaf body, back level, four short equal straight legs with gaps, head on a short neck in a soft collar, tail straight back. Giant snow hare. Head: huge round face, big glossy warm motherly eyes, gentle smile, very long lop ears hanging beside the cheeks, painted in mint, violet and pink aurora bands. Body: massive pale silver-blue loaf, a snowfield back with five chunky snow-capped pines. Front legs: packed-ice plates. Back legs: long flat snowshoe feet. Tail: huge white puff. Parts separate, plain at joints. No text, no base.
  ```

  Previous version (not used):

  ```text
  Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only eyes, glass and water shine. Three-quarter front view, plain white background. Four-legged loaf body, back level, four short equal straight legs with gaps, head on a short neck in a soft collar, tail straight back. Giant snow hare. Head: huge round face, very long lop ears hanging beside the cheeks, painted in mint, violet and pink aurora bands. Body: massive pale silver-blue loaf, a snowfield back with five chunky snow-capped pines. Front legs: packed-ice plates. Back legs: long flat snowshoe feet. Tail: huge white puff. Separate parts, plain colour at joints. No text, no base.
  ```

- **3D settings:** Body plan Quad. Giant tier: target 5,950 assembled (head 1,700, torso 1,600, front leg 550 x2, hind leg 550 x2, tail 450); limit 6,000, hard 7,200. Meshy 7.1 High Detail with Auto Split by parts (head, torso, front limbs, legs, tail), multi-view input (front, side, back, three-quarter), texture on and matte, PBR off, Refine Prompt off, Image Enhancement off; decimate each part separately in Blender. The creature form may breed with Giant Candy, so every joint rule applies in full. Giant scale; keep the Quad bands so her creature form mixes. The pines are torso-owned, inside the top silhouette, and must not overhang the head or tail (they are where another species' head would see them). Ears end above the collar. The magenta cracks are the tear's mark and can be a separate calmed texture with them removed. Rare look (the calmed or event form, Ayrton's call): an alternative head texture with the aurora bands in dawn gold and rose. Fight (roster plan): she buries the field in drifts that Chill the team; a Fire hit on the wind-up melts the drift.
- **Design sheet:**
  - **Concept and stats:** the mother of the snowfields. Frost · Quad · giant (creature form XL, weight about 92).
  - **Signature parts:** head (aurora lop ears), torso (snowfield and pines), front limbs (packed-ice plates), legs (snowshoe feet), tail (huge puff).
  - **Personality:** slow, motherly giant · gesture **Nod** (one slow nod that shakes snow off her pines) · cry: a soft, deep thrum you feel through the ground · entrance (calmed): settles down and the auroras brighten.
  - **Journal facts:** "The hares of Glass Lake say the aurora is her ears, shaken out." "Small creatures shelter in her pines all winter, and she never moves until spring." **Favourite:** the quiet after heavy snow.
  - **Moves:** head Aurora Veil (Frost); torso Avalanche (Frost, team, wind-up); front limbs Ice-Plate Stamp (Frost); legs Drift Bury (Frost, Chill); tail Snow Squall (Storm).
  - **Breeding hook (Giant Candy):** her ice-plate forelegs are the biggest Defence part on four legs; her snowfield torso on a Burlhorn makes "a burl hump under the pines".
  - **Originality (flag):** resembles long-eared rabbit creatures (Buneary, Lopunny) and a digging rabbit (Diggersby); closeness low (none is a giant with a forest on its back or aurora ears). Fallback: none needed.

## 3. Crystal Deep (biome 6, Crystal) · town "Glimmerholt" · 4v4 · Ruby tier · Serpent debuts

**The place** (plan 13). Underground, under the Northern Range: no sky at all. You enter through the Frozen Fall, where snow turns to ice, ice to blue crystal and then to violet crystal while the daylight goes out behind you. Glimmerholt sits at (2900, -2700), base height 20. The landmark is **the Heartstone**, a cavern-sized crystal; the only look-back is the Frozen Fall's blue light at the tunnel mouth. Light comes from the crystals (lamps and glowing dressing every 30 to 40 studs), the weather is glints, the sound is drips and a low hum. The way on is the Lava Tube, where crystal gives way to black glass and a red glow: Emberfall.

**The story beat** (brief section 9 [Default]: the tear's leak turns some creatures to gemstone). Crystal Deep is where players first see that happen: **Ruby** individuals appear ([Locked]: Ruby starts here), and the miners of Glimmerholt blame the new red glints on whatever is driving Druseback to charge through the tunnels. The Heartstone itself shows one red seam, a quiet hint that the leak reaches underground.

**What makes it distinct.** Soft, smooth, pale blind-cave bodies with sharp faceted growths on them: the contrast is the signature. Deep violet and amethyst, cyan and magenta crystal light, pale cave-white skin; geodes, quartz points, dripstone, glowworm silk. Facets are **sculpted** (chunky, clean planes, one flat colour per crystal) so they still read when the tint and the gem effects go over them. All glow is "painted bright, not glowing"; Neon parts, lights and Beams are added in Roblox.

**Ruby and the look of this biome.** Gem tiers are effects on the same mesh (standard section 3.3): tier-coloured sparkles at the attachments, a rim and a sheen. So that Ruby always reads as Ruby, **no common look and no rare look in Crystal Deep uses ruby red**: the biome's crystals are violet, cyan, magenta, citrine and white, and red belongs to the Ruby tier (and to the one tear-touched geode in the giant's story). **Prismquill is the Ruby showcase**: big blunt prism quills with broad flat faces, the best surfaces in the biome for a red sparkle and sheen.

**Breeding stat: Attack on the heads** (roster plan): every Crystal Deep species has its weapon on the head (crystal brow points, a faceted nose, quartz nubs, lens rims, a stalactite fringe, tuning-fork prongs, a crest, a drill horn, silk spinnerets, slag brow plates).

| Species | Plan | Type (and move types) | Rarity | Size (weight) | Role | Hook | Rare look (part) |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Glintbruin | Quad | Crystal (Sand on the front legs) | Uncommon | L (76) | bruiser, quest gift | Cave bear whose amethyst ridge grows a ring a year | Citrine ridge (torso) |
| Prismquill ★ | Quad | Crystal (Sand on the front legs) | Common | M (56) | striker | Porcupine with prism quills that throw rainbows | Magenta-and-gold prisms (torso) |
| Thundegg | Quad | Storm (Frost on the torso, Crystal on the tail) | Common | M (54) | all-rounder, underdog | Thunderegg toad that crackles when it puffs up | Opal seam (torso) |
| Lensloris | Biped | Crystal | Common | S (46) | all-rounder | Slow loris with crystal lens rims round huge eyes | Violet lens rims (head) |
| Stalagrump | Biped | Crystal (Sand on the legs, Water on the tail) | Uncommon | L (78) | tank | Dripstone grump with a stalactite fringe over its eyes | Moonmilk-white fringe (head) |
| Forkhum | Biped | Storm (Frost on the torso) | Common | S (42) | sprinter, underdog | Tuning-fork head that hums off key and sparks | Silver prongs (head) |
| Grotteel | Serpent | Crystal (Water on the head and fins) | Common | M (56) | sprinter, token | Pale cave-lake eel with a chiming crystal crest | Citrine crest (head) |
| Drillgleam | Serpent | Crystal (Sand on the torso and fins) | Common | M (60) | striker | Soft worm with a spiral crystal drill horn | Pearl-white drill (head) |
| Glowthread | Serpent | Crystal | Rare spawn (Uncommon until approved) | S (44) | all-rounder | Glowworm serpent that hangs silk tassels like stars | Gold-bead tassels (tail) |
| Slagworm | Serpent | Fire | Common | L (78) | bruiser, teaser | Fat magma worm crusted with cooling slag | Smoky-quartz crust (torso) |

Each walking plan has two Crystal and one Storm underdog (Crystal beats Storm; its torso carries a **Frost** move that beats Crystal back, since no later type does). The serpents are three Crystal and one Fire (neutral to Crystal, the Emberfall teaser). Breeding pairs: any two of the three Quads, the three Bipeds or the four Serpents. Gifts: quest creature Glintbruin; token Grotteel with a Water move on its head (Water beats Fire, the next biome).

### Glintbruin

- **Description:** Crystal, four-legged, Uncommon, size L: a slow, gentle cave bear with a ridge of amethyst points along its spine and three small crystal points on its brow. Crystal Deep's bruiser and its quest gift.
- **Intended appeal:** A big, sleepy, huggable bear that sparkles: the amethyst ridge is a silhouette you can read across the cavern, and the idea that you can count its crystal rings to tell its age gives every one a story. A quest gift people are proud of.
- **Meshy image prompt (full, reference only: over Meshy's 800-character limit; paste the short prompt):**

  ```text
  handmade claymation creature for a Pokémon-inspired Roblox game, soft matte hand-sculpted plasticine with visible thumbprint texture and tiny tool marks, chunky rounded proportions, big glossy cartoon eyes with a bright white highlight, an expressive face full of personality, original creature design, no clothing, no held objects, full body. a chunky four-legged creature with a rounded loaf-shaped body about one and a half times as long as it is tall, back level, standing square on four short straight legs set under the four corners of the body with a clear gap between the legs, front and back legs the same length, legs about two-thirds as long as the body is tall, feet flat on the ground; a big round head a little less than half as long as the body, held forward at the height of the back on a short thick neck that rises out of a soft rounded collar at the front of the body; a tail that starts as a small round stub at the top of the rump and points straight back; left and right sides mirror-symmetric. Head: a broad, round bear head with small round ears, a pale cream muzzle, sleepy kind eyes, a small smile and a short brow-crown of three chunky amethyst points on the forehead. Body: a heavy dusky violet-grey loaf with a pale lilac belly and a ridge of five chunky faceted amethyst points along the spine, tallest in the middle, starting well behind the neck and ending in front of the tail. Front legs: thick forelegs with big blunt violet claws. Back legs: thick sturdy legs with round flat feet and pale pads. Tail: a short stubby tail pointing straight back, tipped with one small amethyst point. each body part is a separate, clearly shaped piece: the head, the body, each leg and the tail keep their own features; nothing hangs over, wraps around or runs across from one part onto another; where the head, legs and tail meet the body, the surface is plain main colour; no clothing, straps, chains or props. simple flat colour blocks: one solid main colour over the whole creature, the same on the head, body, legs and tail; one lighter belly colour; small details such as eyes, mouth, horns, claws and hooves in clearly different colours; no gradients, no painted shadows, no shine except the eyes, glass and water, no stripes or spots running across the joints. plain white background, even soft lighting, the whole body in view, three-quarter view from the front left, standing still in a neutral pose. No text, no base.
  ```

- **Short prompt (under 800 characters):** 796 characters. Revised 24 Nov 2026 for the concept run: a personality expression and big glossy eyes written in (owner's eye rule); see docs/art/CONCEPT_REVIEW.md.

  ```text
  Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only the eyes shine. Plain white background. Four-legged loaf body, back level, four short equal straight legs with gaps, head on a short neck in a soft collar, tail straight back. Head: broad round bear face, big glossy contented eyes, tongue tip out, cream muzzle, three chunky amethyst points on the brow. Body: heavy dusky violet-grey loaf, lilac belly, a ridge of five faceted amethyst points along the spine, tallest in the middle. Front legs: big blunt violet claws. Back legs: round flat feet. Tail: stubby, one amethyst point. Parts separate, plain at joints. No text, no base.
  ```

  Previous version (not used):

  ```text
  Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only eyes, glass and water shine. Three-quarter front view, plain white background. Four-legged loaf body, back level, four short equal straight legs with gaps, head on a short neck in a soft collar, tail straight back. Head: broad round bear face, cream muzzle, three chunky amethyst points on the brow. Body: heavy dusky violet-grey loaf, lilac belly, a ridge of five faceted amethyst points along the spine, tallest in the middle. Front legs: big blunt violet claws. Back legs: round flat feet. Tail: stubby, one amethyst point. Separate parts, plain colour at joints. No text, no base.
  ```

- **3D settings:** Body plan Quad. Standard tier: target 2,960 assembled (head 850, torso 850, front leg 270 x2, hind leg 250 x2, tail 220); cap 3,600. Meshy Smart Topology (T2.5), segmentation on, texture on and matte, PBR off, Refine Prompt off, Image Enhancement off for the approved concept, Pose off. Torso length about 6.0. Facets sculpted, one flat colour each. The ridge stops 1 R behind the collar and 1 R in front of the tail socket. Rare look: an alternative torso texture with the ridge in honey-gold citrine.
- **Design sheet:**
  - **Concept and stats:** the unhurried cave bear. Crystal · Quad · Uncommon · L, weight 76 · bruiser. Quest gift.
  - **Signature parts:** head (amethyst brow crown: the Attack part), torso (amethyst spine ridge), front limbs (blunt violet claws).
  - **Personality:** unhurried crystal-taster · gesture **Sniff** (sniffs and licks the nearest crystal) · cry: a low humming growl that makes the crystals ring · entrance: ambles in and sits down heavily.
  - **Journal facts:** "Its ridge grows a new ring of crystal every year: count them to know its age." "It sleeps through summer and winter alike; underground there is no difference." **Favourite:** licking mineral-sweet drips off the walls.
  - **Moves:** head Amethyst Butt (Crystal); torso Geode Ridge (Crystal, defensive); front limbs Rubble Swipe (Sand); legs Heavy Pad (Crystal); tail Glint Flick (Crystal).
  - **Breeding hook:** a high-Attack brow crown. Surprising cross: **Burlhorn × Glintbruin**, Greenwood's living burl hump with an amethyst brow: the oldest and the newest sleepers.
  - **Originality (flag):** resembles cave and ringed bears (Ursaring, Ursaluna) and a polar bear (Beartic); closeness low to medium (a big sleepy bear is an archetype). Differs: violet-grey, an amethyst spine ridge and brow crown, no ring mark, no beard. Fallback: none needed.

### Prismquill

- **Description:** Crystal, four-legged, Common, size M: a porcupine whose quills are big blunt crystal prisms that throw rainbows when lamplight hits them. Crystal Deep's striker and its Ruby showcase.
- **Intended appeal:** It turns the cavern into a light show: seven huge prism quills, each edged with a rainbow, and it turns towards every lamp to show off. Broad flat prism faces make it the best creature in the game for the Ruby sparkle, so it is the first Ruby players chase.
- **Meshy image prompt (full, reference only: over Meshy's 800-character limit; paste the short prompt):**

  ```text
  handmade claymation creature for a Pokémon-inspired Roblox game, soft matte hand-sculpted plasticine with visible thumbprint texture and tiny tool marks, chunky rounded proportions, big glossy cartoon eyes with a bright white highlight, an expressive face full of personality, original creature design, no clothing, no held objects, full body. a chunky four-legged creature with a rounded loaf-shaped body about one and a half times as long as it is tall, back level, standing square on four short straight legs set under the four corners of the body with a clear gap between the legs, front and back legs the same length, legs about two-thirds as long as the body is tall, feet flat on the ground; a big round head a little less than half as long as the body, held forward at the height of the back on a short thick neck that rises out of a soft rounded collar at the front of the body; a tail that starts as a small round stub at the top of the rump and points straight back; left and right sides mirror-symmetric. Head: a round porcupine head with small round ears, a proud little smile and a blunt wedge-shaped snout tipped with a faceted pale-cyan crystal nose. Body: a compact deep violet loaf with a pale lilac belly; on its back a fan of seven big blunt six-sided crystal prism quills, opaque pale cyan with a flat rainbow band of red, orange, yellow, green and blue near each tip, pointing up and back, starting well behind the neck and ending in front of the tail. Front legs: short legs with magenta digging claws. Back legs: short legs with round flat feet. Tail: a short thick tail pointing straight back, tipped with three small cyan prism quills. each body part is a separate, clearly shaped piece: the head, the body, each leg and the tail keep their own features; nothing hangs over, wraps around or runs across from one part onto another; where the head, legs and tail meet the body, the surface is plain main colour; no clothing, straps, chains or props. simple flat colour blocks: one solid main colour over the whole creature, the same on the head, body, legs and tail; one lighter belly colour; small details such as eyes, mouth, horns, claws and hooves in clearly different colours; no gradients, no painted shadows, no shine except the eyes, glass and water, no stripes or spots running across the joints. plain white background, even soft lighting, the whole body in view, three-quarter view from the front left, standing still in a neutral pose. No text, no base.
  ```

- **Short prompt (under 800 characters):** 797 characters. Revised 24 Nov 2026 for the concept run: a personality expression and big glossy eyes written in (owner's eye rule); see docs/art/CONCEPT_REVIEW.md.

  ```text
  Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only the eyes shine. Plain white background. Four-legged loaf body, back level, four short equal straight legs with gaps, head on a short neck in a soft collar, tail straight back. Head: round porcupine face, big glossy vain eyes, a preening smirk, blunt snout tipped with a faceted pale-cyan crystal nose. Body: compact deep violet loaf, lilac belly, a fan of seven big blunt opaque cyan prism quills with a flat rainbow band near each tip, pointing up and back. Front legs: magenta digging claws. Tail: short, three small cyan prisms. Parts separate, plain at joints. No text, no base.
  ```

  Previous version (not used):

  ```text
  Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only eyes, glass and water shine. Three-quarter front view, plain white background. Four-legged loaf body, back level, four short equal straight legs with gaps, head on a short neck in a soft collar, tail straight back. Head: round porcupine face, blunt snout tipped with a faceted pale-cyan crystal nose. Body: compact deep violet loaf, lilac belly, a fan of seven big blunt opaque cyan prism quills with a flat rainbow band near each tip, pointing up and back. Front legs: magenta digging claws. Tail: short, three small cyan prisms. Parts separate, plain at joints. No text, no base.
  ```

- **3D settings:** Body plan Quad. Standard tier: target 2,890 assembled (head 750, torso 900, front leg 250 x2, hind leg 220 x2, tail 300); cap 3,600. Meshy Smart Topology (T2.5), segmentation on, texture on and matte, PBR off, Refine Prompt off, Image Enhancement off for the approved concept, Pose off. Torso length about 4.6. Ruby showcase: the prisms are few, big and flat-faced (no clusters of tiny spikes), which gives the sparkle and sheen effects broad surfaces. The rainbow band is painted detail and keeps to the quills. Opaque, never clear. Rare look: an alternative torso texture with magenta prisms and a gold band.
- **Design sheet:**
  - **Concept and stats:** the lamp-chaser. Crystal · Quad · Common · M, weight 56 · striker. ★ Ruby showcase.
  - **Signature parts:** head (crystal nose: the Attack part), torso (prism quills), front limbs (magenta digging claws), tail (prism tip).
  - **Personality:** vain preener · gesture **Wiggle** (rattles its quills to scatter rainbows) · cry: a chiming "tink-tink-tiiing" · entrance: turns side-on to the nearest light and poses.
  - **Journal facts:** "It always turns to face the nearest lamp so its quills throw rainbows." "Shed quills are set into Glimmerholt's windows." **Favourite:** a new lamp, especially someone else's.
  - **Moves:** head Facet Jab (Crystal); torso Prism Spray (Crystal); front limbs Quick Dig (Sand); legs Scuttle (Crystal); tail Quill Lash (Crystal).
  - **Breeding hook:** a high-Attack nose on a striker's head. Surprising cross: **Duneskit × Prismquill**, shutter-slat ears and prism quills: the fastest rainbow in the game.
  - **Originality (flag):** resembles the spiky sand pangolin (Sandslash, on the roster plan's watch list) and a spiky-hooded hedgehog (Chespin); closeness low to medium (a quilled creature). Differs: a violet porcupine with seven big blunt prisms on the back only, a crystal nose, rainbow bands; no all-over spikes, no hood. Fallback: none needed.

### Thundegg

- **Description:** Storm, four-legged, Common, size M: a round toad shaped like a thunderegg geode, with a crack of yellow quartz along its back, that crackles with static when it puffs up. Crystal Deep's four-legged underdog, with a Frost move on its torso.
- **Intended appeal:** A round, grinning rock that hops, puffs up and makes your hair stand on end: a silly, satisfying creature with a real job (miners carry one as a cave-in warning) and a useful Frost answer to the biome's Crystal types.
- **Meshy image prompt (full, reference only: over Meshy's 800-character limit; paste the short prompt):**

  ```text
  handmade claymation creature for a Pokémon-inspired Roblox game, soft matte hand-sculpted plasticine with visible thumbprint texture and tiny tool marks, chunky rounded proportions, big glossy cartoon eyes with a bright white highlight, an expressive face full of personality, original creature design, no clothing, no held objects, full body. a chunky four-legged creature with a rounded loaf-shaped body about one and a half times as long as it is tall, back level, standing square on four short straight legs set under the four corners of the body with a clear gap between the legs, front and back legs the same length, legs about two-thirds as long as the body is tall, feet flat on the ground; a big round head a little less than half as long as the body, held forward at the height of the back on a short thick neck that rises out of a soft rounded collar at the front of the body; a tail that starts as a small round stub at the top of the rump and points straight back; left and right sides mirror-symmetric. Head: a wide, round toad head with a huge happy grin, two chunky pale-yellow quartz nubs above the eyes and a pale yellow throat. Body: a round, puffed-up body like a geode rock, storm slate-grey and gently knobbly, with a zigzag crack of pale yellow quartz running along the top of the back, starting well behind the neck and ending in front of the tail; a frosted pale ice-blue belly. Front legs and back legs: short thick legs with round sticky toe pads in pale yellow. Tail: a tiny round stub ending in a small pale-yellow quartz bead. each body part is a separate, clearly shaped piece: the head, the body, each leg and the tail keep their own features; nothing hangs over, wraps around or runs across from one part onto another; where the head, legs and tail meet the body, the surface is plain main colour; no clothing, straps, chains or props. simple flat colour blocks: one solid main colour over the whole creature, the same on the head, body, legs and tail; one lighter belly colour; small details such as eyes, mouth, horns, claws and hooves in clearly different colours; no gradients, no painted shadows, no shine except the eyes, glass and water, no stripes or spots running across the joints. plain white background, even soft lighting, the whole body in view, three-quarter view from the front left, standing still in a neutral pose. No text, no base.
  ```

- **Short prompt (under 800 characters):** 794 characters. Revised 24 Nov 2026 for the concept run: a personality expression and big glossy eyes written in (owner's eye rule); see docs/art/CONCEPT_REVIEW.md.

  ```text
  Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only the eyes shine. Plain white background. Four-legged loaf body, back level, four short equal straight legs with gaps, head on a short neck in a soft collar, tail straight back. Head: wide round toad face, big glossy startled mid-hiccup eyes, wobbly grin, two chunky pale-yellow quartz nubs above the eyes. Body: round puffed geode-rock body, storm slate-grey, a zigzag crack of pale yellow quartz along the top of the back, frosted ice-blue belly. Legs: short and thick, round yellow toe pads. Tail: tiny stub with a quartz bead. Parts separate, plain at joints. No text, no base.
  ```

  Previous version (not used):

  ```text
  Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only eyes, glass and water shine. Three-quarter front view, plain white background. Four-legged loaf body, back level, four short equal straight legs with gaps, head on a short neck in a soft collar, tail straight back. Head: wide round toad face, huge happy grin, two chunky pale-yellow quartz nubs above the eyes. Body: round puffed geode-rock body, storm slate-grey, a zigzag crack of pale yellow quartz along the top of the back, frosted ice-blue belly. Legs: short and thick, round yellow toe pads. Tail: tiny stub with a quartz bead. Parts separate, plain at joints. No text, no base.
  ```

- **3D settings:** Body plan Quad. Standard tier: target 2,770 assembled (head 850, torso 800, front leg 230 x2, hind leg 230 x2, tail 200); cap 3,600. Meshy Smart Topology (T2.5), segmentation on, texture on and matte, PBR off, Refine Prompt off, Image Enhancement off for the approved concept, Pose off. Torso length about 4.4; toads have no tail, so the stub is near-invisible but present in data (standard 1.3). Legs front and back the same length (no frog crouch: the Quad band forbids it). Static sparks are a Roblox effect at the quartz nubs. Rare look: an alternative torso texture with the quartz crack in opal white with pink and mint flecks.
- **Design sheet:**
  - **Concept and stats:** the miners' storm alarm. Storm · Quad · Common · M, weight 54 · all-rounder, underdog.
  - **Signature parts:** head (quartz nubs and grin: the Attack part), torso (geode body and quartz crack, frosted belly: the Frost move), legs (sticky toe pads).
  - **Personality:** jittery hiccupper · gesture **Bounce** (a hiccup hop, puffing up rounder each time) · cry: a crackly "brrrp-zzt" · entrance: bounces in and puffs up with a crackle.
  - **Journal facts:** "It crackles before a cave-in, so miners keep one by the door." "Puffed up, it is perfectly round and rolls if you nudge it." **Favourite:** cold spring water that makes it fizz.
  - **Moves:** head Static Croak (Storm, Static); torso Puff Up (Storm, defensive) and **Cold Spring (Frost, torso only: the answer to Crystal)**; front limbs Spark Slap (Storm); legs Bound (Storm); tail Bead Flick (Crystal).
  - **Breeding hook:** a Frost-answer torso on four legs. Surprising cross: **Sloshcalf × Thundegg**, a pond bubble on a geode toad's legs: "the egg with a pond in it".
  - **Originality (flag):** resembles a four-legged toad (Bulbasaur, on the watch list, but ours has no plant) and the tremor-toads (Palpitoad, Seismitoad); closeness low to medium (a round four-legged toad). Differs: a geode-rock body with a quartz seam, slate and yellow, quartz brow nubs. Fallback: none needed.

### Lensloris

- **Description:** Crystal, two-legged, Common, size S: a slow loris whose huge eyes are ringed by thick faceted crystal rims like lenses, so it sees in the dark. Crystal Deep's two-legged all-rounder.
- **Intended appeal:** Enormous eyes are the strongest cuteness cue there is, and these come framed in crystal: it looks permanently amazed. Slow, careful and gentle, it is the creature small players want to hold.
- **Meshy image prompt (full, reference only: over Meshy's 800-character limit; paste the short prompt):**

  ```text
  handmade claymation creature for a Pokémon-inspired Roblox game, soft matte hand-sculpted plasticine with visible thumbprint texture and tiny tool marks, chunky rounded proportions, big glossy cartoon eyes with a bright white highlight, an expressive face full of personality, original creature design, no clothing, no held objects, full body. a chunky two-legged creature with an upright rounded pear-shaped body, widest at the belly, about as wide as it is tall; a big round head nearly as wide as the body sitting straight on top of the body, its short neck tucked into a soft rounded collar; two short arms hanging straight down at the sides from high on the body, with a clear gap between the arms and the body, hands ending well above the ground; two short straight legs set close together under the body with a small gap between them, feet flat on the ground; a small tail low at the back pointing straight back; left and right sides mirror-symmetric. Head: a round loris head with soft dark eye patches, tiny round ears, a white stripe down the nose, a tiny mouth and two huge round eyes, each framed by a thick faceted crystal rim in pale cyan like a lens. Body: a small pear-shaped body in soft cave-white fur with a lilac belly and one lilac stripe down the middle of the back, stopping short of the collar and tail. Arms: short slow arms ending in round pink grip pads. Legs: short legs with round pink grip toes. Tail: a tiny stub tail ending in a small faceted cyan bead. each body part is a separate, clearly shaped piece: the head, the body, each leg and the tail keep their own features; nothing hangs over, wraps around or runs across from one part onto another; where the head, legs and tail meet the body, the surface is plain main colour; no clothing, straps, chains or props. simple flat colour blocks: one solid main colour over the whole creature, the same on the head, body, legs and tail; one lighter belly colour; small details such as eyes, mouth, horns, claws and hooves in clearly different colours; no gradients, no painted shadows, no shine except the eyes, glass and water, no stripes or spots running across the joints. plain white background, even soft lighting, the whole body in view, three-quarter view from the front left, standing still in a neutral pose. No text, no base.
  ```

- **Short prompt (under 800 characters):** 779 characters. Revised 24 Nov 2026 for the concept run: a personality expression and big glossy eyes written in (owner's eye rule); see docs/art/CONCEPT_REVIEW.md.

  ```text
  Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only the eyes shine. Plain white background. Upright pear body, big head in a soft collar, short arms hanging down with a gap, short legs close together, small low tail. Head: round loris face, dark eye patches, white nose stripe, tiny mouth, two huge round glossy unblinking eyes full of wonder, each framed by a thick faceted pale-cyan crystal rim like a lens. Body: small cave-white pear, lilac belly, lilac stripe down the back. Arms: round pink grip pads. Legs: pink grip toes. Tail: tiny stub, faceted cyan bead. Parts separate, plain at joints. No text, no base.
  ```

  Previous version (not used):

  ```text
  Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only eyes, glass and water shine. Three-quarter front view, plain white background. Upright pear body, big head in a soft collar, short arms hanging down with a gap, short legs close together, small low tail. Head: round loris face, dark eye patches, white nose stripe, tiny mouth, two huge round eyes each framed by a thick faceted pale-cyan crystal rim like a lens. Body: small cave-white pear, lilac belly, lilac stripe down the back. Arms: round pink grip pads. Legs: pink grip toes. Tail: tiny stub, faceted cyan bead. Separate parts, plain colour at joints. No text, no base.
  ```

- **3D settings:** Body plan Biped. Standard tier: target 2,670 assembled (head 900, torso 650, arm 240 x2, leg 220 x2, tail 200); cap 3,600. Meshy Smart Topology (T2.5), segmentation on, texture on and matte, PBR off, Refine Prompt off, Image Enhancement off for the approved concept, Pose A-Pose (the arms are straightened to hang down in Blender, standard step 7). Torso height about 2.8. The lens rims are head geometry around the house eyes, which stay glossy black beads; nothing see-through. Pale coat: regenerate on light grey if the background removal eats it. Rare look: an alternative head texture with violet lens rims.
- **Design sheet:**
  - **Concept and stats:** the cave's watcher. Crystal · Biped · Common · S, weight 46 · all-rounder.
  - **Signature parts:** head (crystal lens rims: the Attack part), torso (back stripe), arms (pink grip pads), tail (cyan bead).
  - **Personality:** unblinking stargazer · gesture **Tilt** (a slow head tilt, lenses catching the light) · cry: a soft, curious "mmm?" · entrance: creeps in very slowly and stares.
  - **Journal facts:** "It can read a lamp-sign across the whole cavern." "It blinks about once an hour; Glimmerholt cooks time their stews by it." **Favourite:** the Heartstone's light, watched for hours.
  - **Moves:** head Lens Flare (Crystal); torso Hush (Crystal, defensive); arms Slow Grip (Crystal); legs Creep (Crystal); tail Glint (Crystal).
  - **Breeding hook:** an accurate high-Attack head on a light body. Surprising cross: **Lanternell × Lensloris**, a lamp head and lens eyes cannot both go on one baby, so the breeder picks: light or sight.
  - **Originality (flag):** no close match known; big-eyed creatures elsewhere are bats, owls or ghosts. Closeness low. Fallback: none needed.

### Stalagrump

- **Description:** Crystal, two-legged, Uncommon, size L: a squat dripstone grump with a fringe of stubby stalactites hanging over its eyes and a little geode pocket in its belly. Crystal Deep's tank.
- **Intended appeal:** The grumpy old neighbour everyone loves: squat, frowning, permanently dripped on, and secretly soft (children hang wet socks on its fringe and it pretends not to notice). A tank you can count on, with a face you can draw in four lines.
- **Meshy image prompt (full, reference only: over Meshy's 800-character limit; paste the short prompt):**

  ```text
  handmade claymation creature for a Pokémon-inspired Roblox game, soft matte hand-sculpted plasticine with visible thumbprint texture and tiny tool marks, chunky rounded proportions, big glossy cartoon eyes with a bright white highlight, an expressive face full of personality, original creature design, no clothing, no held objects, full body. a chunky two-legged creature with an upright rounded pear-shaped body, widest at the belly, about as wide as it is tall; a big round head nearly as wide as the body sitting straight on top of the body, its short neck tucked into a soft rounded collar; two short arms hanging straight down at the sides from high on the body, with a clear gap between the arms and the body, hands ending well above the ground; two short straight legs set close together under the body with a small gap between them, feet flat on the ground; a small tail low at the back pointing straight back; left and right sides mirror-symmetric. Head: a broad, lumpy head like a dripstone mound in limestone cream, with a heavy fringe of short, blunt, chunky stalactites hanging over its eyes like a grumpy brow, two eyes peeking out under it and a downturned mouth. Body: a squat, wide pear-shaped body in limestone cream with sculpted flowing dripstone ridges on the chest, a tan belly and a small open geode pocket in the middle of the belly lined with violet crystal points. Arms: short thick arms ending in blunt cone-shaped paws like stalagmite tips. Legs: short wide stumpy legs with flat feet. Tail: a short stub of dripstone pointing straight back. each body part is a separate, clearly shaped piece: the head, the body, each leg and the tail keep their own features; nothing hangs over, wraps around or runs across from one part onto another; where the head, legs and tail meet the body, the surface is plain main colour; no clothing, straps, chains or props. simple flat colour blocks: one solid main colour over the whole creature, the same on the head, body, legs and tail; one lighter belly colour; small details such as eyes, mouth, horns, claws and hooves in clearly different colours; no gradients, no painted shadows, no shine except the eyes, glass and water, no stripes or spots running across the joints. plain white background, even soft lighting, the whole body in view, three-quarter view from the front left, standing still in a neutral pose. No text, no base.
  ```

- **Short prompt (under 800 characters):** 773 characters. Revised 24 Nov 2026 for the concept run: a personality expression and big glossy eyes written in (owner's eye rule); see docs/art/CONCEPT_REVIEW.md.

  ```text
  Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only the eyes shine. Plain white background. Upright pear body, big head in a collar, short arms hanging down with a gap, short legs close together, small low tail. Head: broad lumpy dripstone head, limestone cream, a heavy fringe of short blunt chunky stalactites over big glossy grumpy eyes, a sour downturned mouth. Body: squat wide cream pear, flowing dripstone ridges on the front, tan belly with a small open geode pocket of violet crystal points. Arms: blunt cone-shaped stalagmite paws. Tail: short stub. Parts separate, plain at joints. No text, no base.
  ```

  Previous version (not used):

  ```text
  Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only eyes, glass and water shine. Three-quarter front view, plain white background. Upright pear body, big head in a collar, short arms hanging down with a gap, short legs close together, small low tail. Head: broad lumpy dripstone head, limestone cream, a heavy fringe of short blunt chunky stalactites hanging over the eyes, downturned mouth. Body: squat wide cream pear, flowing dripstone ridges on the chest, tan belly with a small open geode pocket of violet crystal points. Arms: blunt cone-shaped stalagmite paws. Tail: short stub. Parts separate, plain at joints. No text, no base.
  ```

- **3D settings:** Body plan Biped. Standard tier: target 2,990 assembled (head 880, torso 850, arm 270 x2, leg 260 x2, tail 200); cap 3,600. Meshy Smart Topology (T2.5), segmentation on, texture on and matte, PBR off, Refine Prompt off, Image Enhancement off for the approved concept, Pose A-Pose (the arms are straightened to hang down in Blender, standard step 7). Torso height about 3.9. The stalactite fringe belongs to the head and must end above the eyes' lower edge and well above the collar (never a beard). The dripstone ridges keep 1 R clear of the arm sockets. Rare look: an alternative head texture with the fringe in moonmilk white with pale blue tips.
- **Design sheet:**
  - **Concept and stats:** the old drip-counter. Crystal · Biped · Uncommon · L, weight 78 · tank (the most Hp and Defence in Crystal Deep, the slowest).
  - **Signature parts:** head (stalactite fringe: the Attack part, it drops them), torso (dripstone ridges and geode pocket), arms (stalagmite paws).
  - **Personality:** drip-counting curmudgeon · gesture **Shiver** (a full-body shudder when a drip lands on it) · cry: a low "hmmph", then a drip's "plink" · entrance: shuffles in and settles like it has been there for centuries.
  - **Journal facts:** "It stands under the same drip for years and grows a little taller with every one." "Children hang wet socks on its fringe to dry; it pretends not to notice." **Favourite:** a good steady drip.
  - **Moves:** head Stalactite Drop (Crystal); torso Dripstone Wall (Crystal, defensive); arms Stalagmite Jab (Crystal); legs Settle (Sand); tail Drip (Water).
  - **Breeding hook:** a fringe head that hits hard on a slow tank. Surprising cross: **Stumpwarden × Stalagrump**, a tree-stump body under a stalactite fringe: two creatures that plant themselves in the path.
  - **Originality (flag):** resembles rock golems and boulder creatures (Graveler, Roggenrola) and a fake-tree rock (Sudowoodo); closeness low. Differs: a limestone grump with a stalactite brow fringe and a geode belly pocket; no boulder body, no extra arms. Fallback: none needed.

### Forkhum

- **Description:** Storm, two-legged, Common, size S: a slender creature whose head ends in two thick rounded tuning-fork prongs that hum and spark. Crystal Deep's two-legged sprinter and underdog, with a Frost move on its torso.
- **Intended appeal:** A singer that cannot sing: its prongs ring a pure note that always drifts off key, and they spark on the high notes. It is light, quick and silly, and its Frost torso move makes it a real answer to the Crystal types around it.
- **Meshy image prompt (full, reference only: over Meshy's 800-character limit; paste the short prompt):**

  ```text
  handmade claymation creature for a Pokémon-inspired Roblox game, soft matte hand-sculpted plasticine with visible thumbprint texture and tiny tool marks, chunky rounded proportions, big glossy cartoon eyes with a bright white highlight, an expressive face full of personality, original creature design, no clothing, no held objects, full body. a chunky two-legged creature with an upright rounded pear-shaped body, widest at the belly, about as wide as it is tall; a big round head nearly as wide as the body sitting straight on top of the body, its short neck tucked into a soft rounded collar; two short arms hanging straight down at the sides from high on the body, with a clear gap between the arms and the body, hands ending well above the ground; two short straight legs set close together under the body with a small gap between them, feet flat on the ground; a small tail low at the back pointing straight back; left and right sides mirror-symmetric. Head: a round head with big friendly eyes, a small round mouth open in an "ooo" as if humming, and two thick rounded prongs rising straight up from the top like a tuning fork, each as thick as a thumb, in brass gold. Body: a slender pear-shaped body in steel blue with a frost-white belly crusted with chunky rime. Arms: short slim arms ending in small round padded hands. Legs: slim legs with small round feet in steel blue. Tail: a short tail pointing straight back, ending in a small round brass-gold knob like the stem of a tuning fork. each body part is a separate, clearly shaped piece: the head, the body, each leg and the tail keep their own features; nothing hangs over, wraps around or runs across from one part onto another; where the head, legs and tail meet the body, the surface is plain main colour; no clothing, straps, chains or props. simple flat colour blocks: one solid main colour over the whole creature, the same on the head, body, legs and tail; one lighter belly colour; small details such as eyes, mouth, horns, claws and hooves in clearly different colours; no gradients, no painted shadows, no shine except the eyes, glass and water, no stripes or spots running across the joints. plain white background, even soft lighting, the whole body in view, three-quarter view from the front left, standing still in a neutral pose. No text, no base.
  ```

- **Short prompt (under 800 characters):** 788 characters. Revised 24 Nov 2026 for the concept run: a personality expression and big glossy eyes written in (owner's eye rule); see docs/art/CONCEPT_REVIEW.md.

  ```text
  Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only the eyes shine. Plain white background. Upright pear body, big head in a soft collar, short arms hanging down with a gap, short legs close together, small low tail. Head: round, big glossy eyes rolled up in proud off-key rapture, small round mouth open mid-hum, one U-shaped tuning fork of two thick rounded brass-gold clay prongs on top. Body: slender steel-blue pear, frost-white belly crusted with chunky rime. Arms: slim, small round hands. Legs: slim. Tail: short, round brass knob. Feet flat on the ground, no stand. Parts separate, plain at joints. No text, no base.
  ```

  Previous version (not used):

  ```text
  Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only eyes, glass and water shine. Three-quarter front view, plain white background. Upright pear body, big head in a soft collar, short arms hanging down with a gap, short legs close together, small low tail. Head: round, big eyes, small round mouth open as if humming, two thick rounded brass-gold prongs rising straight up from the top like a tuning fork, thumb-thick. Body: slender steel-blue pear, frost-white belly crusted with chunky rime. Arms: slim, small round hands. Legs: slim. Tail: short, ending in a round brass knob. Separate parts, plain colour at joints. No text, no base.
  ```

- **3D settings:** Body plan Biped. Standard tier: target 2,680 assembled (head 850, torso 650, arm 220 x2, leg 260 x2, tail 220); cap 3,600. Meshy Smart Topology (T2.5), segmentation on, texture on and matte, PBR off, Refine Prompt off, Image Enhancement off for the approved concept, Pose A-Pose (the arms are straightened to hang down in Blender, standard step 7). Torso height about 2.8, width at the low end of the Biped band (slender, still inside it); legs up to 0.7 of the torso height for a sprinter. Prongs must be thick and parallel with a clear gap between them, or Meshy fills the gap. Sparks are a Roblox effect at the prong tips. Rare look: an alternative head texture with silver prongs.
- **Design sheet:**
  - **Concept and stats:** the off-key crooner. Storm · Biped · Common · S, weight 42 · sprinter, underdog.
  - **Signature parts:** head (tuning-fork prongs: the Attack part), torso (rime-crusted belly: the Frost move), tail (brass knob).
  - **Personality:** tone-deaf crooner · gesture **Peek** (leans round a crystal to check if anyone is listening, then hums) · cry: a pure ringing "mmmmMMM" that wobbles off key · entrance: hums a note that rings the crystals around it.
  - **Journal facts:** "Glimmerholt's choir tunes to it, then politely asks it to leave." "Its prongs spark whenever it hits a high note, so it aims high." **Favourite:** a big echoing cavern.
  - **Moves:** head Resonance (Storm, Static); torso Hum Field (Storm) and **Rime Hum (Frost, torso only: the answer to Crystal)**; arms Tap (Storm); legs Zip (Storm); tail Knob Knock (Storm).
  - **Breeding hook:** a fast frame with a Frost-answer torso. Surprising cross: **Runnelfin × Forkhum**, a sail fin crest is a head part like the prongs, so the baby shows one or the other: dancer or singer.
  - **Originality (flag):** no creature with a tuning-fork head known; nearby ideas are wind-chime and bell creatures (Chimecho, Bronzong, near the watch list). Closeness low (no bell or chime body). Fallback: none needed. Claimed motif: the tuning-fork head (roster plan 2c).

### Grotteel

- **Description:** Crystal, serpent, Common, size M: a pale cave-lake eel with a tall crest of faceted cyan crystal fin-spines on its head. Crystal Deep's serpent sprinter and the biome's clear token (with a Water move on its head).
- **Intended appeal:** The first serpent most players own: a smooth, friendly, pale eel with a crest like a crown of ice, gliding through dark water. It is the token gift and the face of the new body plan, so it has to be lovable at once.
- **Meshy image prompt (full, reference only: over Meshy's 800-character limit; paste the short prompt):**

  ```text
  handmade claymation creature for a Pokémon-inspired Roblox game, soft matte hand-sculpted plasticine with visible thumbprint texture and tiny tool marks, chunky rounded proportions, big glossy cartoon eyes with a bright white highlight, an expressive face full of personality, original creature design, no clothing, no held objects, full body. a chunky serpent creature with a thick rounded front body resting on the ground with the chest slightly raised; a big round head held forward on a short thick neck that rises out of a soft rounded collar; a pair of small fins hanging down at the sides just behind the neck; a pair of small low fins at the back of the front body; one long thick tail lying straight back along the ground with a gentle up-and-down wave and no sideways curl; left and right sides mirror-symmetric. Head: a long, rounded eel head in pale cave-white with big friendly eyes, a small smile and a tall crest of three chunky faceted crystal fin-spines in cyan on top of the head, stopping before the neck. Body: a smooth pale cave-white front body with a pale lilac belly. Side fins: two rounded paddle fins, thick at the edge, cave-white with a cyan rim all round. Rear fins: two small round low fins with cyan rims. Tail: a long smooth tail tapering evenly, with a low cyan crystal ridge along the top near the tip and a small rounded tail fan at the end. each body part is a separate, clearly shaped piece: the head, the body, each leg and the tail keep their own features; nothing hangs over, wraps around or runs across from one part onto another; where the head, legs and tail meet the body, the surface is plain main colour; no clothing, straps, chains or props. simple flat colour blocks: one solid main colour over the whole creature, the same on the head, body, legs and tail; one lighter belly colour; small details such as eyes, mouth, horns, claws and hooves in clearly different colours; no gradients, no painted shadows, no shine except the eyes, glass and water, no stripes or spots running across the joints. plain white background, even soft lighting, the whole body in view, three-quarter view from the front left, standing still in a neutral pose. No text, no base.
  ```

- **Short prompt (under 800 characters):** 775 characters. Revised 24 Nov 2026 for the concept run: a personality expression and big glossy eyes written in (owner's eye rule); see docs/art/CONCEPT_REVIEW.md.

  ```text
  Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only the eyes shine. Plain white background. Serpent: thick front body on the ground, head on a short neck in a soft collar, small side and rear fins, one long thick tail straight back. Head: long rounded pale cave-white eel head, big glossy curious eyes, a nosy eager smile, a tall crest of three chunky faceted cyan crystal fin-spines on top. Body: smooth cave-white front body, lilac belly. Side fins: rounded paddles with cyan rims. Tail: long, smooth, tapering, low cyan crystal ridge near the tip, small fan. Parts separate, plain at joints. No text, no base.
  ```

  Previous version (not used):

  ```text
  Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only eyes, glass and water shine. Three-quarter front view, plain white background. Serpent: thick front body on the ground, head on a short neck in a soft collar, small side and rear fins, one long thick tail straight back. Head: long rounded pale cave-white eel head, small smile, a tall crest of three chunky faceted cyan crystal fin-spines on top. Body: smooth cave-white front body, lilac belly. Side fins: rounded paddles with cyan rims. Tail: long, smooth, tapering, low cyan crystal ridge near the tip, small fan. Separate parts, plain colour at joints. No text, no base.
  ```

- **3D settings:** Body plan Serpent. Standard tier: target 2,920 assembled (head 850, torso 700, side fin 200 x2, rear fin 160 x2, tail 650); cap 3,600. Meshy Smart Topology (T2.5), segmentation on, texture on and matte, PBR off, Refine Prompt off, Image Enhancement off for the approved concept, Pose off. Torso length about 4.0, tail about 2.5 times that. Pale coat: regenerate on light grey if needed. Ask for a side view as well (Serpent conventions 1h). The crest stops 1 R before the collar. Rare look: an alternative head texture with a honey-gold citrine crest.
- **Design sheet:**
  - **Concept and stats:** the dark-water glider. Crystal · Serpent · Common · M, weight 56 · sprinter. Token gift with a Water move on its head (Water beats Fire, the next biome).
  - **Signature parts:** head (crystal crest: the Attack part), side fins (cyan-rimmed paddles), tail (crystal ridge and fan).
  - **Personality:** nosy explorer · gesture **Hop** (a little leap out of the water) · cry: a bubbling "bloop-bloop" · entrance: surfaces with a splash and a leap.
  - **Journal facts:** "Cave lakes are pitch dark, so it finds its way by the chime of its crest on the rock." "Glimmerholt children feed it biscuits from the jetty." **Favourite:** an underwater current to ride.
  - **Moves:** head Crest Slice (Crystal) and Lake Jet (Water, on the token's head); torso Glide (Crystal); side fins Ripple (Water); rear fins Flick (Crystal); tail Tail Whip (Crystal).
  - **Breeding hook:** a fast tail on the serpent plan's first sprinter. Surprising cross (later): **Grotteel × Galaxeel** (Abyss), a crystal crest on a galaxy ribbon.
  - **Originality (flag):** resembles a small blue serpent with ear fins (Dratini), an elegant fin-tailed water serpent (Milotic) and electric eels (Eelektross); closeness low to medium (a friendly serpent with a head crest). Differs: chunky, pale cave-white, a faceted cyan crest on top of the head, no ear fins, no pearls, no electricity. Fallback: a lower, wider crest like a crown.

### Drillgleam

- **Description:** Crystal, serpent, Common, size M: a soft, ringed tunnelling worm with one big spiralled faceted crystal horn on its brow that it bores through rock with. Crystal Deep's serpent striker.
- **Intended appeal:** A soft, smiling grub with a giant gemstone drill: the contrast of squishy and sharp is the biome's signature in one creature, and its tunnels are the streets of Glimmerholt. Simple to draw, easy to love.
- **Meshy image prompt (full, reference only: over Meshy's 800-character limit; paste the short prompt):**

  ```text
  handmade claymation creature for a Pokémon-inspired Roblox game, soft matte hand-sculpted plasticine with visible thumbprint texture and tiny tool marks, chunky rounded proportions, big glossy cartoon eyes with a bright white highlight, an expressive face full of personality, original creature design, no clothing, no held objects, full body. a chunky serpent creature with a thick rounded front body resting on the ground with the chest slightly raised; a big round head held forward on a short thick neck that rises out of a soft rounded collar; a pair of small fins hanging down at the sides just behind the neck; a pair of small low fins at the back of the front body; one long thick tail lying straight back along the ground with a gentle up-and-down wave and no sideways curl; left and right sides mirror-symmetric. Head: a round, soft worm head in pale pink-white with big friendly eyes, a wide grin and one big spiralled faceted crystal horn in magenta on the brow, pointing straight forward like a drill. Body: a soft, thick pale pink-white front body with sculpted ring segments and a pale cream belly. Side fins: two short rounded spade-shaped digging fins in magenta. Rear fins: two small rounded nubs in magenta. Tail: a long ringed tail tapering evenly, ending in a small faceted magenta crystal tip. each body part is a separate, clearly shaped piece: the head, the body, each leg and the tail keep their own features; nothing hangs over, wraps around or runs across from one part onto another; where the head, legs and tail meet the body, the surface is plain main colour; no clothing, straps, chains or props. simple flat colour blocks: one solid main colour over the whole creature, the same on the head, body, legs and tail; one lighter belly colour; small details such as eyes, mouth, horns, claws and hooves in clearly different colours; no gradients, no painted shadows, no shine except the eyes, glass and water, no stripes or spots running across the joints. plain white background, even soft lighting, the whole body in view, three-quarter view from the front left, standing still in a neutral pose. No text, no base.
  ```

- **Short prompt (under 800 characters):** 794 characters. Revised 24 Nov 2026 for the concept run: a personality expression and big glossy eyes written in (owner's eye rule); see docs/art/CONCEPT_REVIEW.md.

  ```text
  Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only the eyes shine. Plain white background. Serpent: thick front body on the ground, head on a short neck in a soft collar, small side and rear fins, one long thick tail straight back. Head: round soft worm face, pale pink-white, big glossy stubborn eyes, a headstrong wide grin, one big spiralled faceted magenta crystal horn on the brow pointing straight forward like a drill. Body: soft thick pink-white front body with ring segments, cream belly. Side fins: short rounded magenta spades. Tail: long, ringed, magenta crystal tip. Parts separate, plain at joints. No text, no base.
  ```

  Previous version (not used):

  ```text
  Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only eyes, glass and water shine. Three-quarter front view, plain white background. Serpent: thick front body on the ground, head on a short neck in a soft collar, small side and rear fins, one long thick tail straight back. Head: round soft worm face, pale pink-white, wide grin, one big spiralled faceted magenta crystal horn on the brow pointing straight forward like a drill. Body: soft thick pink-white front body with ring segments, cream belly. Side fins: short rounded magenta spades. Tail: long, ringed, magenta crystal tip. Parts separate, plain at joints. No text, no base.
  ```

- **3D settings:** Body plan Serpent. Standard tier: target 2,950 assembled (head 900, torso 700, side fin 200 x2, rear fin 150 x2, tail 650); cap 3,600. Meshy Smart Topology (T2.5), segmentation on, texture on and matte, PBR off, Refine Prompt off, Image Enhancement off for the approved concept, Pose off. Torso length about 4.2. The drill horn points along -Z from the brow and stays on the head; keep it chunky and blunt-tipped. Ring segments are sculpted and stop 1 R short of the collar and the hip ring. Rare look: an alternative head texture with a pearl-white drill.
- **Design sheet:**
  - **Concept and stats:** the tunneller. Crystal · Serpent · Common · M, weight 60 · striker.
  - **Signature parts:** head (crystal drill horn: the Attack part), side fins (digging spades), tail (crystal tip). Ring segments on torso and tail.
  - **Personality:** headstrong tunneller · gesture **Stretch** (stretches long, then snaps back like a spring) · cry: a whirring "vrrr-ip" · entrance: bursts out of the ground.
  - **Journal facts:** "Glimmerholt's oldest street follows a tunnel one dug in a single afternoon." "It drills in spirals, so its tunnels are perfectly round." **Favourite:** soft limestone, the crumbly kind.
  - **Moves:** head Gem Drill (Crystal); torso Burrow (Sand); side fins Dig Spade (Sand); rear fins Wriggle (Crystal); tail Tail Tap (Crystal).
  - **Breeding hook:** the hardest-hitting serpent head in Crystal Deep. Surprising cross: **Slagworm × Drillgleam**, a crystal drill on a slag-crusted body: the drill that melts its way through.
  - **Originality (flag):** resembles a drill-headed mole (Drilbur, Excadrill) and boulder snakes (Onix, on the watch list); closeness low (a soft ringed worm with one crystal horn; no claws, no boulders, no metal). Fallback: none needed.

### Glowthread

- **Description:** Crystal, serpent, rare spawn (Uncommon until approved), size S: a slim deep-violet serpent speckled like a night sky, whose tail ends in a fringe of chunky silk tassels with bright beads, like the glowworm curtains of the cave roof. Crystal Deep's serpent all-rounder.
- **Intended appeal:** The rare find of the Deep: met only by bait or the daily sighting, it hangs from the cave roof like a little starry sky. Quiet, beautiful and slightly mysterious, it is the creature players hunt and show in the trade window.
- **Meshy image prompt (full, reference only: over Meshy's 800-character limit; paste the short prompt):**

  ```text
  handmade claymation creature for a Pokémon-inspired Roblox game, soft matte hand-sculpted plasticine with visible thumbprint texture and tiny tool marks, chunky rounded proportions, big glossy cartoon eyes with a bright white highlight, an expressive face full of personality, original creature design, no clothing, no held objects, full body. a chunky serpent creature with a thick rounded front body resting on the ground with the chest slightly raised; a big round head held forward on a short thick neck that rises out of a soft rounded collar; a pair of small fins hanging down at the sides just behind the neck; a pair of small low fins at the back of the front body; one long thick tail lying straight back along the ground with a gentle up-and-down wave and no sideways curl; left and right sides mirror-symmetric. Head: a small round head in deep violet with big gentle eyes, a tiny round mouth and two chunky soft feeler nubs on top, each tipped with a round bead painted bright cyan, not glowing. Body: a slim deep violet front body speckled with small painted bright cyan dots like stars, with a pale lilac belly. Side fins: two small rounded fins, thick at the edge, lilac with a cyan rim all round. Rear fins: two small round low nubs in lilac. Tail: a long slim tail tapering evenly, ending in a fringe of five short, chunky, rope-thick silk tassels in pale lilac, each ending in a round bead painted bright cyan, not glowing. each body part is a separate, clearly shaped piece: the head, the body, each leg and the tail keep their own features; nothing hangs over, wraps around or runs across from one part onto another; where the head, legs and tail meet the body, the surface is plain main colour; no clothing, straps, chains or props. simple flat colour blocks: one solid main colour over the whole creature, the same on the head, body, legs and tail; one lighter belly colour; small details such as eyes, mouth, horns, claws and hooves in clearly different colours; no gradients, no painted shadows, no shine except the eyes, glass and water, no stripes or spots running across the joints. plain white background, even soft lighting, the whole body in view, three-quarter view from the front left, standing still in a neutral pose. No text, no base.
  ```

- **Short prompt (under 800 characters):** 788 characters. Revised 24 Nov 2026 for the concept run: a personality expression and big glossy eyes written in (owner's eye rule); see docs/art/CONCEPT_REVIEW.md.

  ```text
  Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only eyes, glass and water shine. Plain white background. Serpent: thick front body on the ground, head on a short neck in a soft collar, small side and rear fins, one long thick tail straight back. Head: small round deep violet head, big glossy calm patient eyes, soft smile, two chunky feeler nubs tipped with bright cyan beads, painted not glowing. Body: slim deep violet front body speckled with bright cyan dots like stars, lilac belly. Tail: long, slim, ending in five short rope-thick lilac silk tassels with cyan beads. Parts separate, plain at joints. No text, no base.
  ```

  Previous version (not used):

  ```text
  Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only eyes, glass and water shine. Three-quarter front view, plain white background. Serpent: thick front body on the ground, head on a short neck in a soft collar, small side and rear fins, one long thick tail straight back. Head: small round deep violet head, two chunky feeler nubs tipped with bright cyan beads, painted not glowing. Body: slim deep violet front body speckled with bright cyan dots like stars, lilac belly. Tail: long, slim, ending in five short rope-thick lilac silk tassels with cyan beads. Separate parts, plain colour at joints. No text, no base.
  ```

- **3D settings:** Body plan Serpent. Standard tier: target 2,860 assembled (head 800, torso 650, side fin 180 x2, rear fin 150 x2, tail 750); cap 3,600. Meshy Smart Topology (T2.5), segmentation on, texture on and matte, PBR off, Refine Prompt off, Image Enhancement off for the approved concept, Pose off. Torso length about 3.4. The tassels are the tail's tip feature: chunky, short and separate from each other, or Meshy fuses them into a lump (if it does, keep one fat tassel bundle and add the rest as Roblox Beams). The long hanging threads of its curtain are a Roblox effect (Beams from a tail attachment), never mesh. Neon or a light on the beads comes later. Rare look: an alternative tail texture with gold beads.
- **Design sheet:**
  - **Concept and stats:** the curtain-weaver of the cave roof. Crystal · Serpent · rare spawn (treat as Uncommon until Ayrton approves) · S, weight 44 · all-rounder.
  - **Signature parts:** head (beaded feelers: the Attack part, it spits silk), torso (star speckles), tail (silk tassels and beads).
  - **Personality:** patient night-weaver · gesture **Wiggle** (shivers its tassels so the beads twinkle) · cry: a whispered "shhh-eee" · entrance: lowers itself in from above on a thread.
  - **Journal facts:** "The first miners thought its curtains were the night sky and would not dig further." "Its silk is strong enough to hang a lamp from, and Glimmerholt does." **Favourite:** perfect stillness, and a moth or two.
  - **Moves:** head Silk Spit (Crystal); torso Starry Curtain (Crystal, defensive); side fins Weave (Crystal); rear fins Anchor (Crystal); tail Lure Light (Crystal).
  - **Breeding hook:** a rare tail that brings a lure move. Surprising cross (roster plan section 6): **Glowthread × Galaxeel**, glowing silk trailing from a galaxy ribbon: Crystal head Attack on an Abyss Speed tail.
  - **Originality (flag):** resembles thread-spinning spiders (Spinarak, Ariados, Joltik) in idea only; closeness low (a serpent with star speckles and beaded tassels; no legs, no web). Fallback: none needed. Claimed motif: the glowworm-thread serpent (roster plan 2c).

### Slagworm

- **Description:** Fire, serpent, Common, size L: a fat, slow magma worm crusted with plates of cooling black slag, ember-orange showing in the cracks. Crystal Deep's serpent bruiser and the teaser for Emberfall, neutral to Crystal.
- **Intended appeal:** A big, grumpy, warm lump that drifted up from the Lava Tube: it keeps the bakery ovens of Glimmerholt hot, and players get their first Fire creature here, a taste of the volcano before they reach it.
- **Meshy image prompt (full, reference only: over Meshy's 800-character limit; paste the short prompt):**

  ```text
  handmade claymation creature for a Pokémon-inspired Roblox game, soft matte hand-sculpted plasticine with visible thumbprint texture and tiny tool marks, chunky rounded proportions, big glossy cartoon eyes with a bright white highlight, an expressive face full of personality, original creature design, no clothing, no held objects, full body. a chunky serpent creature with a thick rounded front body resting on the ground with the chest slightly raised; a big round head held forward on a short thick neck that rises out of a soft rounded collar; a pair of small fins hanging down at the sides just behind the neck; a pair of small low fins at the back of the front body; one long thick tail lying straight back along the ground with a gentle up-and-down wave and no sideways curl; left and right sides mirror-symmetric. Head: a blunt, fat worm head in charcoal with heavy-lidded sleepy eyes, a wide grumpy underbite and three small black slag plates across the brow. Body: a fat charcoal front body crusted on top with chunky black slag plates, with ember-orange painted in the cracks between them, not glowing, and a dark grey belly. Side fins: two stubby rounded fins in charcoal with ember-orange rims all round. Rear fins: two small stubby nubs in charcoal. Tail: a long fat tail of charcoal ring segments with thin ember-orange lines between them, tapering evenly to a cooled grey pumice tip. each body part is a separate, clearly shaped piece: the head, the body, each leg and the tail keep their own features; nothing hangs over, wraps around or runs across from one part onto another; where the head, legs and tail meet the body, the surface is plain main colour; no clothing, straps, chains or props. simple flat colour blocks: one solid main colour over the whole creature, the same on the head, body, legs and tail; one lighter belly colour; small details such as eyes, mouth, horns, claws and hooves in clearly different colours; no gradients, no painted shadows, no shine except the eyes, glass and water, no stripes or spots running across the joints. plain white background, even soft lighting, the whole body in view, three-quarter view from the front left, standing still in a neutral pose. No text, no base.
  ```

- **Short prompt (under 800 characters):** 784 characters. Revised 24 Nov 2026 for the concept run: a personality expression and big glossy eyes written in (owner's eye rule); see docs/art/CONCEPT_REVIEW.md.

  ```text
  Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only eyes, glass and water shine. Plain white background. Serpent: thick front body on the ground, head on a short neck in a soft collar, small side and rear fins, one long thick tail straight back. Head: blunt fat charcoal worm head, big glossy grouchy half-lidded eyes, wide grumpy underbite, small black slag plates on the brow. Body: fat charcoal front body crusted with chunky black slag plates, ember-orange painted in the cracks, not glowing. Tail: long fat charcoal ring segments with orange lines, grey pumice tip. Parts separate, plain at joints. No text, no base.
  ```

  Previous version (not used):

  ```text
  Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only eyes, glass and water shine. Three-quarter front view, plain white background. Serpent: thick front body on the ground, head on a short neck in a soft collar, small side and rear fins, one long thick tail straight back. Head: blunt fat charcoal worm head, sleepy eyes, wide grumpy underbite, small black slag plates on the brow. Body: fat charcoal front body crusted with chunky black slag plates, ember-orange painted in the cracks, not glowing. Tail: long fat charcoal ring segments with orange lines, grey pumice tip. Separate parts, plain colour at joints. No text, no base.
  ```

- **3D settings:** Body plan Serpent. Standard tier: target 2,990 assembled (head 800, torso 850, side fin 180 x2, rear fin 150 x2, tail 680); cap 3,600. Meshy Smart Topology (T2.5), segmentation on, texture on and matte, PBR off, Refine Prompt off, Image Enhancement off for the approved concept, Pose off. Torso length about 4.8 (the thickest serpent). Glow is paint now; Neon on the cracks or an ember particle comes later, at a torso attachment. The slag plates stay 1 R clear of the collar and the hip ring. Rare look: an alternative torso texture with smoky-quartz brown plates and gold cracks.
- **Design sheet:**
  - **Concept and stats:** the bakery's stove. Fire · Serpent · Common · L, weight 78 · bruiser. Emberfall teaser, neutral to Crystal.
  - **Signature parts:** head (slag brow plates: the Attack part), torso (slag crust with ember cracks), tail (ember-lined segments and pumice tip).
  - **Personality:** slow-burning grouch · gesture **Shake** (a few cinders fall off its plates) · cry: a long hissing sigh, "fsssshh" · entrance: slumps in and steams.
  - **Journal facts:** "It drifted up the Lava Tube one winter and has kept Glimmerholt's bakery ovens warm ever since." "Where it naps, the crystals turn smoky." **Favourite:** a warm loaf, though it will not admit it.
  - **Moves:** head Slag Bite (Fire); torso Ember Crust (Fire, defensive); side fins Cinder Flick (Fire); rear fins Smoulder (Fire); tail Slag Slam (Fire).
  - **Breeding hook:** the serpent plan's toughest torso, and Fire coverage for Crystal teams. Surprising cross (later): **Slagworm × Magmeel** (Emberfall), a slag crust behind an obsidian-plated head.
  - **Originality (flag):** resembles a lava snail (Slugma, Magcargo, on the watch list), a fire centipede (Centiskorch) and a fire anteater (Heatmor); closeness low to medium (a slow magma creature with cooling crust). Differs: a legless fat worm with slag plates and a pumice tip; no shell, no legs, no flame. Fallback: none needed.

### Druseback

- **Description:** Giant, Crystal, four-legged: a colossal pillbug whose back plates are geode halves with violet and cyan crystals showing at the seams; it rolls up and charges through its tunnels. Crystal Deep's giant.
- **Intended appeal:** A giant you can roll: it curls into a perfect geode boulder and charges, then unrolls, shy and blinking. The seam crystals glitter, one tear-touched geode glows ruby red, and calming it is the moment players learn where Ruby creatures come from.
- **Meshy image prompt (full, reference only: over Meshy's 800-character limit; paste the short prompt):**

  ```text
  handmade claymation creature for a Pokémon-inspired Roblox game, soft matte hand-sculpted plasticine with visible thumbprint texture and tiny tool marks, chunky rounded proportions, big glossy cartoon eyes with a bright white highlight, an expressive face full of personality, original creature design, no clothing, no held objects, full body. a chunky four-legged creature with a rounded loaf-shaped body about one and a half times as long as it is tall, back level, standing square on four short straight legs set under the four corners of the body with a clear gap between the legs, front and back legs the same length, legs about two-thirds as long as the body is tall, feet flat on the ground; a big round head a little less than half as long as the body, held forward at the height of the back on a short thick neck that rises out of a soft rounded collar at the front of the body; a tail that starts as a small round stub at the top of the rump and points straight back; left and right sides mirror-symmetric. A giant of its kind, broad and heavy, with the same chunky toy proportions. Head: a broad round pillbug head in stone grey with kind, shy eyes, a small soft mandible smile and two short chunky antenna stubs, each as thick as a thumb, ending in round knobs. Body: a long domed back of seven overlapping grey stone plates, each shaped like half a geode, with rows of chunky violet and cyan crystal points showing in the seams between the plates; one plate near the middle has deep ruby-red crystals in its seam; the dome stays inside the body's outline, well behind the neck and in front of the tail; a pale lilac underside. Front legs and back legs: short stout legs, each armoured with grey stone bands, ending in round flat feet. Tail: two small rounded stone plates fanned straight back, with violet crystal edges. each body part is a separate, clearly shaped piece: the head, the body, each leg and the tail keep their own features; nothing hangs over, wraps around or runs across from one part onto another; where the head, legs and tail meet the body, the surface is plain main colour; no clothing, straps, chains or props. simple flat colour blocks: one solid main colour over the whole creature, the same on the head, body, legs and tail; one lighter belly colour; small details such as eyes, mouth, horns, claws and hooves in clearly different colours; no gradients, no painted shadows, no shine except the eyes, glass and water, no stripes or spots running across the joints. plain white background, even soft lighting, the whole body in view, three-quarter view from the front left, standing still in a neutral pose. No text, no base.
  ```

- **Short prompt (under 800 characters):** 795 characters. Revised 24 Nov 2026 for the concept run: a personality expression and big glossy eyes written in (owner's eye rule); see docs/art/CONCEPT_REVIEW.md.

  ```text
  Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only the eyes shine. Plain white background. Four-legged loaf body, back level, four short equal straight legs with gaps, head on a short neck in a collar, tail straight back. Giant pillbug. Head: broad round stone-grey face, big glossy shy eyes peeking up, a timid smile, two thumb-thick antenna stubs with round knobs. Body: domed back of seven overlapping grey stone plates like geode halves, violet and cyan crystals in the seams, one seam deep ruby red. Legs: short stout, stone bands. Tail: two small rounded plates fanned back. Parts separate, plain at joints. No text, no base.
  ```

  Previous version (not used):

  ```text
  Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only eyes, glass and water shine. Three-quarter front view, plain white background. Four-legged loaf body, back level, four short equal straight legs with gaps, head on a short neck in a collar, tail straight back. Giant pillbug. Head: broad round stone-grey face, shy eyes, two thumb-thick antenna stubs with round knobs. Body: domed back of seven overlapping grey stone plates like geode halves, violet and cyan crystals in the seams, one seam deep ruby red. Legs: short stout, stone bands. Tail: two small rounded plates fanned back. Parts separate, plain at joints. No text, no base.
  ```

- **3D settings:** Body plan Quad. Giant tier: target 5,800 assembled (head 1,500, torso 1,800, front leg 500 x2, hind leg 500 x2, tail 500); limit 6,000, hard 7,200. Meshy 7.1 High Detail with Auto Split by parts (head, torso, front limbs, legs, tail), multi-view input (front, side, back, three-quarter), texture on and matte, PBR off, Refine Prompt off, Image Enhancement off; decimate each part separately in Blender. The creature form may breed with Giant Candy, so every joint rule applies in full. Giant scale; Quad bands kept so the creature form mixes. The roll-up is animation (a rolled pose or a separate rolled mesh for the fight, Ayrton's call), not the rest pose. The single ruby seam is story (the tear's mark), not a Ruby tier; question 4. Rare look (event form, Ayrton's call): an alternative torso texture with magenta and gold seam crystals and no red. Fight (roster plan): rolled up it takes little damage; a Leaf or Frost hit as it unrolls cracks it open.
- **Design sheet:**
  - **Concept and stats:** the rolling guardian of the tunnels. Crystal · Quad · giant (creature form XL, weight about 95).
  - **Signature parts:** head (antenna knobs and shy face), torso (geode plates and seam crystals), legs (stone bands), tail (crystal-edged plates).
  - **Personality:** shy colossus · gesture **Tilt** (tilts its head and blinks out from under its front plate) · cry: a deep grinding rumble, like a cart on stone · entrance (calmed): unrolls slowly and blinks.
  - **Journal facts:** "Glimmerholt's tunnels are round because it rolled through them first." "Since the red seam appeared in its back, red glints have shown up all over the Deep." **Favourite:** a long smooth tunnel to roll down.
  - **Moves:** head Antenna Tap (Crystal); torso Roll Up (Crystal, defensive stance) and Geode Charge (Crystal, wind-up); front limbs Stone Stamp (Sand); legs Rumble Roll (Crystal); tail Plate Snap (Crystal).
  - **Breeding hook (Giant Candy):** its geode-plated torso is the toughest Crystal torso on four legs; on a Woolrime it makes "a knitted coat over geode plates".
  - **Originality (flag):** resembles an armoured isopod (Wimpod, Golisopod); closeness low (ours is a four-legged rolling pillbug with geode plates, no claws, a shy face). Fallback: none needed.

---

## 4. Questions for Ayrton (one batch)

1. **The Serpent hip ring** (section 1d): a soft rounded rim at the back of every serpent torso, like the neck collar, so a colour step at the tail joint looks intended. A small addition to the breeding standard. OK?
2. **Frostline's quest gift**: the roster plan suggested Woolrime; this file makes Chiselrime the gift and keeps Woolrime as the wild bruiser you earn by finding it, because a beaver that cuts the fishing holes on Glass Lake gives the quest line an obvious job ("help the ice-fishers"). Either works; which do you prefer?
3. **Chill (slow)** as Frostline's status effect, and Static for Crystal Deep's Storm underdogs (roster plan section 1b): the moves marked Chill and Static here are only names until the battle rule exists. OK to plan them?
4. **Ruby red is reserved** in Crystal Deep (no common or rare look uses it), so a Ruby find always reads as Ruby. OK? It also means Druseback's single red geode is the only red in the biome's models: a story mark for the tear.
5. **Glowthread as the rare spawn** (bait or the daily sighting only): it touches drops, so it is yours to approve. Until then it is Uncommon.
6. **Simmerling's folded "bath towel" of fur** on its head: a gentle hot-spring joke that kids will get. Keep, or would you rather a plainer steam-white crest?
7. **Look-alike flags** (below): nothing was dropped or softened for resemblance; each flag says what a design resembles, how closely and a fallback. Yours to rule on, one by one.
8. **Serpent plan confirmation** (roster plan decision 4): this file assumes Serpent debuts here with four species. If you would rather keep eight per biome and delay serpents, Grotteel and Drillgleam are the two to keep.

## Look-alike flags

Per the owner's instruction, every design and name above is the one judged best; overlaps are flagged here, not designed away. Closeness: **low** (shares an archetype only), **medium** (same animal and one shared hook; someone might say "a bit like X"), **high** (would read as X with a different colour; none found).

| Ours | Resembles | Closeness | Why | Fallback if Ayrton wants distance |
| --- | --- | --- | --- | --- |
| Chiselrime | Bidoof, Bibarel (beaver) | medium | Same animal, buck teeth and flat tail, as every beaver has | An otter body with the same ice teeth and ice paddle (the roster plan's spare "ice-fishing otter") |
| Stinkglut | Stunky, Skuntank (striped Toxic skunk) | medium | Stocky Toxic mammal with a pale body stripe | Drop the side bands; show sulphur only as the back crust |
| Glacibex | Skiddo, Gogoat (curled-horn goats) | low to medium | Sturdy goat with big curled horns | Horns swept straight back, ibex-style, instead of rings |
| Simmerling | Pansear, Simisear (tuft-haired monkeys) | low to medium | Upright monkey with a head crest | Cheek ruff only, no head tuft |
| Glintbruin | Ursaring, Ursaluna (bears) | low to medium | Big sleepy bear archetype | None needed |
| Prismquill | Sandslash (on the roster plan's watch list), Chespin | low to medium | A quilled creature | None needed: prisms on the back only, no all-over spikes |
| Thundegg | Palpitoad, Seismitoad; Bulbasaur's four-legged toad shape | low to medium | Round four-legged toad | None needed: no plant, geode body |
| Grotteel | Dratini, Milotic | low to medium | Friendly serpent with a head crest | A lower, wider crown crest |
| Slagworm | Slugma, Magcargo (watch list), Centiskorch | low to medium | Slow magma creature with a cooling crust | None needed: no shell, no legs |
| Woolrime | Mamoswine, Bouffalant | low | Shaggy bovine | None needed |
| Driftmother | Buneary, Lopunny, Diggersby | low | Long-eared rabbit | None needed |
| Rimefern | Snorunt, Frosmoth | low | Small ice sprite | None needed |
| Stalagrump | Graveler, Roggenrola, Sudowoodo | low | Rock creature | None needed |
| Forkhum | Chimecho, Bronzong (watch list: bell body) | low | Sound-making creature | None needed: no bell or chime body |
| Drillgleam | Drilbur, Excadrill; Onix (watch list) | low | Drill head; tunneller | None needed |
| Glowthread | Spinarak, Ariados, Joltik | low | Thread spinner, in idea only | None needed |
| Druseback | Wimpod, Golisopod | low | Armoured isopod | None needed |
| Flurrlem, Hoarmot, Lensloris | none known | low | Archetype only | None needed |

Names: **Glacibex** shares the "Glac-" start with Glaceon, and **Drillgleam** the "Drill-" start with Drilbur; both are low (a shared English root, a different word). **Thundegg** is a real word for a kind of geode, which is part of its charm. No other name here was found within one letter or one sound of another franchise's creature; all are placeholders.
