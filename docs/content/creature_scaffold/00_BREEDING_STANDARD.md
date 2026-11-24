# Breeding model standard

Date: 23 November 2026. For: Ayrton (prompts and the Meshy checklist) and the lead (the import pipeline).
Status: [Default] under brief sections 4, 7 and 12. It builds on `docs/PART_SPEC.md` (the rig, sockets, ball ends, axes, budgets and the validator rules R01 to R15) and does not repeat it; where this file changes the spec, section 8 lists each change so it can be logged in `docs/DECISIONS.md` before code follows.

**Why this exists.** A baby takes its head, torso, front limbs, legs and tail from its two parents, within one body plan. Today every creature is one fused mesh (`src/content/CreatureModels.luau`), so a baby looks exactly like one parent and the game's signature cannot be seen. Meshy can segment a model into parts, but parts only mix well if every species is built on the same skeleton, keeps its features inside its own parts, and is coloured in a way the colour genes can change. This file is that contract. Every creature prompt and every imported model follows it.

**How a prompt is built.** Six blocks, in this order. Blocks 1, 2, 4, 5 and 6 are fixed text, pasted word for word; only block 3 changes per species.

1. STYLE LINE (all plans)
2. STANDARD BODY LINE (one per body plan, section 1)
3. SPECIES LOOK, written part by part: head, body, front limbs (or arms or wings), legs, tail (section 2)
4. SEPARATION LINE (all plans, section 2)
5. COLOUR LINE (all plans, section 3)
6. VIEW LINE (all plans)

> STYLE LINE: Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face.

**The house style (Ayrton, 24 November 2026): clay bodies, cartoon eyes.** The body is matte, hand-sculpted claymation with real texture and personality: thumbprints, small tool marks, slightly imperfect hand-made forms, an expressive pose and face. Stop-motion clay is a proven look, so do not sand it smooth. The eyes are big glossy cartoon eyes with a white highlight; they carry the appeal. Only the eyes, glass and water shine: Meshy bakes shine into the texture, and baked shine looks painted on under Roblox's moving light.

- **Texture lives in the surface, not the colour.** The sculpted texture is the same faint pattern all over, on every part, so a head from one parent and legs from another still look like one toy. Each colour area stays one solid colour (the COLOUR LINE), so tinting and the importer's mask still work.
- **Eyes as their own part.** Ask Meshy's part segmentation to keep the eyes separate where it can, so the game can blink, squint and swap expressions.
- **Meshy takes at most 800 characters.** The short prompt (style line first, then the species) is the one pasted into Meshy; the long six-block prompt is a reference.

> VIEW LINE: plain white background, even soft lighting, the whole body in view, three-quarter view from the front left, standing still in a neutral pose.

A worked example (Sloshcalf) is at the end of section 2.

---

## 1. The shared skeleton per body plan

All sizes are in studs at scale 1, the way PART_SPEC stores templates. `L` is the torso's `torsoLength` (Quad: length along Z; Biped: height along Y). `R` is a socket's or plug's radius. Facing, axes and rest directions are PART_SPEC section 3; socket positions are PART_SPEC section 6. This section adds the **bands** that make parts from different species look right on each other.

### 1.0 The fit rule in one paragraph (why the bands matter)

The Assembler scales a donor part by `torso socket R / donor plug R` (clamped 0.6 to 1.6). So a donor head on a new torso is drawn at `(donor head size / donor plug R) x new torso socket R`. Two ratios therefore decide every mix: the torso's **socket ratio** (`socket R / L`) and the part's **shape ratio** (`part size / plug R`). If every species keeps both ratios inside the plan's band, any head looks the right size on any torso, legs land at a sensible height, and nothing needs the clamp. A species can be as big or small as it likes overall; it is the ratios that must agree. The ball end is what makes this work: the plug radius is the one number the eye reads at the joint, so fixing it as a share of the body fixes everything else.

### 1.1 Quad (four-legged)

| Measure | Band (standard) | Notes |
| --- | --- | --- |
| Torso length `L` (Z) | 3.5 to 6.5 (mid 4.5) | PART_SPEC allows 3 to 10; keep Quads in this band so the 0.6 to 1.6 clamp is never hit |
| Torso width (X) | 0.60 to 0.80 L | |
| Torso height (Y) | 0.55 to 0.75 L | A rounded loaf or bean. Flat-ish underneath, so the leg sockets sit on a broad belly |
| Neck collar | A soft raised rounded rim, part of the torso, around the head socket at the front-top of the body | Width about 0.4 R of the head socket. Plain main colour. The head's neck ball sits inside it, so a colour or texture step between two species falls on a natural edge (like a ball-jointed toy) |
| Head socket | X = 0, Z = front face pushed in 0.4 R, Y = 0 to +0.15 torso height | Slightly above centre: the head is held at the height of the back, not low |
| Head socket ratio `R / L` | 0.16 to 0.21 | |
| Head size | Length (Z) 0.35 to 0.55 L; width 0.70 to 1.00 torso width; height 0.70 to 1.00 torso height | Chunky toy heads are big. Head shape ratio: plug R is 0.30 to 0.45 of the head's width |
| Neck | Part of the head: a short thick stub, no longer than 1.5 R, ending in the neck ball | No long necks in this plan; a long-necked species is a different silhouette, not a longer neck stub |
| Shoulder sockets (front limbs) | Underside, X = +/-(width/2 - R), Z = -0.25 to -0.32 L | PART_SPEC 6.1 |
| Hip sockets (legs) | Underside, same X, Z = +0.25 to +0.32 L | |
| Limb socket ratio `R / L` | Front 0.11 to 0.16; hind 0.12 to 0.18 | Hind legs a touch thicker than front legs |
| Stance width | Torso width minus 2 R (between leg centres), about 0.35 to 0.55 L | Feet under the body corners, never splayed out |
| Leg length (plug to sole) | 0.40 to 0.55 L; front limbs 0.95 to 1.05 of the hind legs | Tighter than PART_SPEC R13 (0.85 to 1.15): with sockets about 0.57 L apart, a 0.15 L front-to-back mismatch already tilts a mixed creature by 15 degrees. A fast species shows speed with slim legs and big feet, not long legs |
| Tail socket | X = 0, Z = rear face pushed in 0.4 R, Y = +0.05 to +0.25 torso height | The tail leaves from the top of the rump |
| Tail socket ratio `R / L` | 0.07 to 0.11 | |
| Tail | Points straight back (+Z), may droop or lift a little, never curls over the back or touches the ground; length 0.25 to 0.60 L | A tail that curls over the back would sit on another species' back feature (a shell, a pond) |
| Rest pose | Back level; four legs straight down, parallel, feet flat; head forward; tail back | PART_SPEC section 3 |

> **STANDARD BODY LINE, Quad:** a chunky four-legged creature with a rounded loaf-shaped body about one and a half times as long as it is tall, back level, standing square on four short straight legs set under the four corners of the body with a clear gap between the legs, front and back legs the same length, legs about two-thirds as long as the body is tall, feet flat on the ground; a big round head a little less than half as long as the body, held forward at the height of the back on a short thick neck that rises out of a soft rounded collar at the front of the body; a tail that starts as a small round stub at the top of the rump and points straight back; left and right sides mirror-symmetric.

Current data to fix when the real meshes are measured: Duneskit (front 0.47 L, hind 0.67 L) and Fenwhisk (0.38 against 0.52) are outside R13 today, and Duneskit, Glissot, Gorsling and Wadibuck have hind legs above 0.55 L. Sloughback (head socket 0.13 L) and Carrackon (0.14 L) are just under the head band.

### 1.2 Biped (two-legged)

| Measure | Band (standard) | Notes |
| --- | --- | --- |
| Torso height `L` (Y) | 2.4 to 4.0 (mid 3.2) | |
| Torso width (X) | 0.70 to 0.95 L | |
| Torso depth (Z) | 0.60 to 0.80 L | An upright pear or egg, widest at the belly, a little narrower at the shoulders |
| Neck collar | Soft raised rounded rim on the top of the torso around the head socket (a turtleneck roll) | Plain main colour |
| Head socket | X = 0, Y = top face pushed in 0.4 R, Z within +/-0.1 depth | PART_SPEC 6.2 |
| Head socket ratio `R / L` | 0.19 to 0.24 | |
| Head size | Height 0.40 to 0.55 L; width 0.80 to 1.10 torso width | Big toy head. Shape ratio: plug R 0.30 to 0.45 of the head's width. The face looks toward -Z |
| Shoulder sockets (arms) | Sides, Y = +0.15 to +0.30 torso height, Z within +/-0.1 depth | |
| Arm socket ratio `R / L` | 0.14 to 0.18 | |
| Arm length | 0.45 to 0.65 L, hands ending at least 0.15 L above the ground | Arms never reach the ground (PART_SPEC section 2). Big hands (mitts, shells, pompoms) are fine; they belong to the arm |
| Hip sockets (legs) | Underside, X = +/-max(1.1 R, 0.2 width) | Legs close together under the body |
| Leg socket ratio `R / L` | 0.19 to 0.24 | |
| Leg length | 0.30 to 0.70 L. Stilt species (Stiltbark, Skipslick, Runnelfin today) up to 1.1 L, named as exceptions in their species file | A biped does not tilt with odd legs, it only grows taller, so the band can be wider than Quad's |
| Stance width | About 0.4 torso width between leg centres | |
| Tail socket | X = 0, back face pushed in 0.4 R, Y = -0.45 to -0.20 torso height | Low on the back |
| Tail socket ratio `R / L` | 0.09 to 0.13 | |
| Tail | Small, points back (+Z), may droop; length 0.25 to 0.50 L; never reaches the ground | |
| Rest pose | Upright; arms straight down at the sides with a gap from the body; legs straight down, parallel, feet flat | Arms must not touch the body in the concept, or Meshy fuses them and they cannot be split |

> **STANDARD BODY LINE, Biped:** a chunky two-legged creature with an upright rounded pear-shaped body, widest at the belly, about as wide as it is tall; a big round head nearly as wide as the body sitting straight on top of the body, its short neck tucked into a soft rounded collar; two short arms hanging straight down at the sides from high on the body, with a clear gap between the arms and the body, hands ending well above the ground; two short straight legs set close together under the body with a small gap between them, feet flat on the ground; a small tail low at the back pointing straight back; left and right sides mirror-symmetric.

### 1.3 Winged (proposed, for later biomes)

Same six joints and five templates as Quad and Biped, so the Assembler stays one code path and the breeding code is unchanged. The `FrontLimb` template **is the wing** (slot `FrontLimbs`); this answers the open question in BREEDING_PLAN section 9 with "wings take the front-limb sockets, and the tail is kept".

| Measure | Band |
| --- | --- |
| Torso | A round egg held level, long axis Z. `L` (Z) 3.0 to 5.0; width 0.65 to 0.85 L; height 0.60 to 0.80 L |
| Head | As Quad (socket ratio 0.17 to 0.22, size 0.35 to 0.50 L), on a short neck in a collar at the front-top |
| Wing sockets | Upper sides: X = +/-(width/2 - 0.4 R), Y = +0.10 to +0.30 height, Z = -0.10 to +0.05 L. Socket ratio 0.12 to 0.17 |
| Wing rest pose | **Folded straight down along the side of the body**, a flat fan lying in the YZ plane (thin in X), the far tip toward -Y and slightly +Z. It must look the same from both faces, because one mesh serves both sides (PART_SPEC section 7). Animation opens the wings by rotating each about Z, which mirrors correctly because the mesh is symmetric about its own YZ plane |
| Wing size | Length 0.70 to 1.10 L when folded; the tip stays above the ground |
| Legs | Two only (`LegSocketL/R` under the middle of the body, Z = 0 to +0.12 L). A Winged creature has no second leg pair, so the plan has no tilt problem. Length 0.30 to 0.50 L |
| Tail | Kept (a short fan or tuft, straight back). Optional in looks, not in data: a near-invisible stub is allowed |
| Budget | Wings 300 to 450 each (PART_SPEC section 8); trim legs to 200 to 300 so the whole creature stays at or under 3,600 |

> **STANDARD BODY LINE, Winged:** a chunky winged creature with a round egg-shaped body held level; a big round head at the front on a short thick neck that rises out of a soft rounded collar; two wings folded flat straight down along the sides of the body like closed fans, the same on both faces, not touching the ground; two short sturdy legs set under the middle of the body, feet flat on the ground; a short tail fan pointing straight back; left and right sides mirror-symmetric.

### 1.4 Serpent (proposed, for later biomes)

Five slots are kept so stats, moves and breeding need no new code: Head, Torso (the raised front body), FrontLimbs (a pair of side fins or frills just behind the neck), Legs (a pair of small low fins or spurs at the back of the front body) and Tail (the long body). Serpent needs two Assembler changes before it can ship: ride height comes from the torso's `GroundPoint` (the belly rests on the ground; the "legs" do not carry it), and the long tail may later be a chain of two or three clones of one segment template for a smooth slither. Both are proposals for Ayrton, not part of version 1.

| Measure | Band |
| --- | --- |
| Torso | A thick rounded front body, long axis Z, chest slightly raised. `L` (Z) 3.0 to 5.0; width 0.50 to 0.70 L; height 0.55 to 0.80 L |
| Head | Socket at the front-top, ratio 0.17 to 0.23; head length 0.40 to 0.60 L; short neck in a collar |
| Fins (FrontLimbs) | Sides behind the neck, hanging down and back, flat in the YZ plane, same on both faces; length 0.25 to 0.45 L; never reach the ground |
| Rear fins (Legs) | Low on the sides at the back of the front body, small (0.15 to 0.30 L); they rest lightly on, not under, the ground |
| Tail | Long (1.5 to 3.0 L), lying along the ground straight back; any wave is **up and down** (in the YZ plane), never sideways, because left-right symmetry is required; tail socket ratio 0.14 to 0.20 (thick: it is the body) |
| Budget | Tail 500 to 800, fins 150 to 250 each, head and torso as standard; whole creature at or under 3,000 |

> **STANDARD BODY LINE, Serpent:** a chunky serpent creature with a thick rounded front body resting on the ground with the chest slightly raised; a big round head held forward on a short thick neck that rises out of a soft rounded collar; a pair of small fins hanging down at the sides just behind the neck; a pair of small low fins at the back of the front body; one long thick tail lying straight back along the ground with a gentle up-and-down wave and no sideways curl; left and right sides mirror-symmetric.

---

## 2. How each part must look at its joint

### 2.1 The joint zone

Every joint has a **joint zone**: the ball end plus a ring about 0.5 R wide around it on the part, and the collar (or the socket area) on the torso. Rules for the joint zone:

1. **Plain main colour, plain shape.** No eyes, horns, spines, shells, patterns, belly patches, spots or stripes inside it. When two species meet here, the only difference the eye sees is a clean step in colour at the collar edge.
2. **Round ball end.** The part ends in a smooth closed cap close to a sphere, hidden inside the torso (PART_SPEC section 5). The part is no wider just behind the ball than the ball itself.
3. **Nothing crosses the joint.** No feature starts on one part and continues on another: a stripe from the back onto the tail, a pond bubble that overlaps the neck, a mane that runs from the head down the back, moss that drapes from the body over the legs, a beard that hangs onto the chest. A feature that would cross is **moved wholly into one part** (the table below says which) and ends at least 1 R short of the joint zone.
4. **Torso features keep clear of the sockets.** A back feature (shell, dome, burl, castle, ship) sits within the torso's top silhouette, at least 1 R behind the collar and 1 R in front of the tail socket, and does not overhang the head, the legs or the tail. Another species' head or tail will sit there.
5. **No baked shadow at the joint.** The texture must not paint a dark shadow under the head or at the leg tops: with another species' head that shadow would be under nothing.

### 2.2 Which part owns which feature

| Part | Owns | Never on it |
| --- | --- | --- |
| **Head** | Eyes, brows, face, mouth, teeth, beak, snout, trunk, ears, horns, antlers, crests, head sprouts, leaves and clovers on top, antennae, head lamps, hats and head shells (Lilyshade's lily-pad hat, Cocklemole's shell hat), whiskers, nose smudges, a fringe over the eyes | A mane or beard that runs down onto the body |
| **Torso** | Shells, domes and bubbles (Sloshcalf's pond), humps, burls, stone stacks, castles and ships (Moatkeep, Carrackon), back plants and branches, back spines and ridges, belly patches and belly features (Bulbroth's bubbles), manes, ruffs and the collar, vents, drapes of moss (ending above the leg tops) | Anything that hangs over the head, the legs or the tail |
| **FrontLimb** (front legs, arms, wings, fins) | Paws, mitts, claws, shell hands, pincers, blades, pompoms, arm fins, arm tufts, wing feathers | Features that need a left and a right version (one mesh serves both sides) |
| **Leg** | Feet, hooves, paddles, stilts, toes, sole shapes, ankle tufts | Anything that spreads sideways (X); the sole must be flat and centred under the plug |
| **Tail** | Tufts, fans, clubs, flags, fins, fronds, drops, tail lamps | Curls over the back, anything that reaches the ground |

Signature features are the reason players want a part, so each species should have **at least one signature feature on three different parts** (for example Spadesnout: spade snout on the head, puffed chest on the torso, digging claws on the front limbs). Then most of its babies show where they came from.

### 2.3 Transparent and glowing features

Under the colour approach in section 3, a template's texture cannot also be see-through. A clear bubble (Sloshcalf), mist (Mistrel, Lilyshade) or glass is painted **opaque**: "a glassy-looking dome painted pale aqua with a white shine, two little orange fish painted on it". Real transparency or glow (Lanternell's lamp) comes later as a separate effect owned by the part's attachment (a light or particle at `EyeLine`, `MouthPoint` or a new attachment), not as part of the mesh.

> SEPARATION LINE: each body part is a separate, clearly shaped piece: the head, the body, each leg and the tail keep their own features; nothing hangs over, wraps around or runs across from one part onto another; where the head, legs and tail meet the body, the surface is plain main colour; no clothing, straps, chains or props.

### 2.4 Worked example: Sloshcalf

> handmade claymation creature, soft matte hand-sculpted plasticine with visible thumbprint texture and tiny tool marks, chunky rounded proportions, big glossy cartoon eyes with a bright white highlight, an expressive face full of personality, original creature design, no clothing, no held objects, full body. **[Quad STANDARD BODY LINE]**. Head: a broad round calf head with soft worried eyebrows and a shy smile, floppy ears shaped like lily pads, two small round stone horns and a little leaf sprout on top. Body: smooth blue-teal clay with a cream belly; on the middle of its back a round glassy-looking water dome painted pale aqua with a white shine and two little orange fish, sitting well behind the neck and in front of the tail. Front legs and back legs: short sturdy legs with rounded webbed hoof-paddles. Tail: a short tail ending in a little reed-tuft fan with one water drop. **[SEPARATION LINE]**. **[COLOUR LINE]**. **[VIEW LINE]**.

Differences from the pilot prompt in `docs/art/MESHY_PILOT.md`: the pond is opaque and kept clear of the neck and tail; the sprout is stated as a head feature; the leg length and stance come from the body line, not "stubby".

---

## 3. Colour and genes

### 3.1 The problem

PART_SPEC section 10 says templates carry no colour and the Assembler sets `MeshPart.Color`. That fits plain grey parts, but Meshy paints its models, and Ayrton likes the painted clay-toy look (`DECISIONS.md`, "Art rule", still open). Painted textures also carry the face: eyes, mouths and claws are paint as much as shape. Throwing the paint away loses the look; keeping it whole leaves the colour genes (`shown`, `carried`, recessive rare colours, `src/shared/Breeding.luau` `inheritColour`) with nothing to change.

### 3.2 What Roblox offers (checked against the current docs, 23 November 2026)

- `SurfaceAppearance.AlphaMode` has four values: **Overlay** (the ColorMap is laid over the part's own `Color` by its alpha: alpha 0 shows `MeshPart.Color`), **Transparency** (alpha cuts the surface away), **TintMask** (alpha is the amount of `SurfaceAppearance.Color` tint; `MeshPart.Color` has no effect) and **Opaque** (beta).
- `SurfaceAppearance.Color` "applies a tint to your existing colormap" and **can be set by scripts at runtime** (ReadWrite, no special security). It is the documented exception to the rule that SurfaceAppearance properties cannot change during play.
- `SurfaceAppearance.ColorMapContent` (and `ColorMap`) can be written only with plugin security, so the texture is set in Studio on a stored template, not by game code. That fits PART_SPEC, which already stores templates in `ReplicatedStorage.CreatureParts`.
- A SurfaceAppearance replaces the part's own texture. Its look varies with the device's graphics quality.
- `MeshPart.TextureContent` (and `TextureID`) **can** change at runtime; `MeshContent` cannot.
- Authoring a tint mask: colour detail in the RGB channels, the mask in alpha (white = tint, black = leave as painted), partial alpha gives a partial tint, and premultiplied alpha must be off so transparent pixels keep their colour.

### 3.3 Decision: painted texture with a tint mask (TintMask)

Each species gets **one 1024 x 1024 RGBA texture** shared by its five templates (they keep the UVs of the one Meshy model). Each template carries one `SurfaceAppearance` with that texture, `AlphaMode = TintMask`.

| Zone of the texture | RGB | Alpha | What the genes do to it |
| --- | --- | --- | --- |
| **Coat** (the main body colour on every part, and every joint zone) | The painted coat turned into a light neutral clay: same shading and grain, hue removed, brightness lifted so its average is about RGB 235 | 1 | Takes the tint fully |
| **Belly** (the lighter second colour) | Lighter neutral, average about RGB 248 | 0.3 to 0.4 | Takes a light version of the tint, so a two-tone creature stays two-tone in any colour |
| **Details** (eyes, mouth, teeth, horns, claws, hooves, shells, stones, leaves, fish, painted features) | As Meshy painted them | 0 | Never change; this is the species' face and character |

At runtime the Assembler sets `SurfaceAppearance.Color` on each part:

- **Natural** (the proposed default gene value): each part is tinted with **its own species' natural coat colour**, which the importer measures from the Meshy paint and records in the species file (a proposed `coat` field). A wild Sloshcalf looks exactly like the concept, and a Sloshcalf x Spadesnout baby is a visible patchwork, teal head on a sandy body, which shows the parentage at a glance.
- **A named coat colour** (today's `Moss`, `Bark`, `Sand`, and the recessive rare `Ember`, `Frostbite`, `Starlight` in `BreedConfig.COLOURS`): every part is tinted with that one colour, unifying the body. This is what makes a rare colour "bred onto stronger creatures" ([Locked]) visible: the gene lives on the creature, not on a part, so it rides over any mix of parts.
- **Cosmic wrap**: `SurfaceAppearance.Color` can be changed every frame, so the wrap can be a slow shifting tint plus effects, with no extra meshes.

Why this one:

- It keeps the painted look Ayrton likes, including the clay grain and the painted faces, while the gene still changes what a player notices first, the coat.
- It keeps the brief's rule "colour is applied at runtime, so colour variants and gem tiers need no extra meshes".
- One texture per species, one SurfaceAppearance per part, no runtime texture work.
- It turns "flat colour blocks" from a style rule into a working need: the importer can only separate coat, belly and details if they are flat, distinct blocks. So the colour rule is the same whether or not the open "Art rule" decision keeps flat colours.

What it costs:

- **Gem tiers move to effects.** A SurfaceAppearance draws its own surface, so changing `MeshPart.Material` to a gem material probably no longer shows (to verify in Studio). Gem tiers become an effect layer: tier-coloured sparkles at the attachments, a rim highlight on the featured creature (Highlights are limited in number on screen; to verify the limit), and a small sheen in the tint. Cheaper on phones than Material swaps anyway.
- **No see-through paint** (section 2.3).
- **PART_SPEC and the validator change** (section 8): R03 must allow exactly one SurfaceAppearance with `AlphaMode = TintMask`.
- **A gene change for Ayrton.** "Natural" as a gene value changes the colour roll's outcomes, and CLAUDE.md puts breeding rolls behind his approval. Until he answers, the Assembler can treat today's common colours as tints and the importer still records `coat`.

### 3.4 Fallback, and the test that decides it

**Fallback: Overlay through `TextureContent`.** The same texture with the alpha **inverted** (details 1, coat 0), set as the MeshPart's texture with no SurfaceAppearance; the coat then shows `MeshPart.Color`, which the Assembler already sets today. It works at runtime with no plugin step and keeps Material swaps for gem tiers, but the coat becomes perfectly flat (no clay grain) and the belly cannot follow the tint. (That a transparent texture pixel shows `MeshPart.Color` is not stated on the MeshPart page: verify.)

The importer writes **both files** (`<Species>_tint.png` and `<Species>_overlay.png`) from the same masks, so switching costs nothing. One Studio session decides, with Sloshcalf and Spadesnout:

1. TintMask maths: put the neutral coat beside the original paint, tint with the measured `coat` colour, and check the two match (the tint is expected to multiply; confirm).
2. TintMask at the lowest graphics quality on the phone emulator and a real phone: does the tint survive?
3. Material change on a part with a SurfaceAppearance: visible or not?
4. Draw calls for 30 mixed creatures with SurfaceAppearance against plain MeshParts (PART_SPEC section 15 already asks a similar question).

If 1 or 2 fail, use the fallback and log it.

### 3.5 Patterns and rare looks (later)

- **Patterns** (the brief's separate pattern gene) are not in version 1. If they come: a pattern is a second texture per species whose alpha mask leaves the pattern untinted; it lives inside each part and fades out before every joint zone. Two or three patterns at most, because each one is a texture per species.
- **Rare looks** in `docs/content/CREATURE_PERSONALITY.md` change details (Spadesnout's brass snout, Sloshcalf's orange pond), so they cannot be a tint. Each is an alternative texture for **the one part that owns the feature**, which is why section 2.2 matters: the rare look then travels with that part in breeding. How rare looks are earned is still Ayrton's call.

> COLOUR LINE: simple flat colour blocks: one solid main colour over the whole creature, the same on the head, body, legs and tail; one lighter belly colour; small details such as eyes, mouth, horns, claws and hooves in clearly different colours; no gradients, no painted shadows, no shine except the eyes, glass and water, no stripes or spots running across the joints.

The concept is still painted in the species' real colours. Ayrton judges the real look; the importer does the neutralising.

---

## 4. Import pipeline (the lead, per creature)

Tools: Blender (free) for mesh work, a small Python script for the texture (to be written and kept in `tools/`), Studio through the Studio MCP for templates and validation. Steps marked (S) run in Studio Edit mode with `execute_luau`.

### 4.1 Receive and record

1. Files in `art/meshy/<Species>/`: the GLB (and FBX if given), the concept image, the prompt text used, the Meshy task id.
2. Add a row to `docs/ASSETS.md`: Meshy Pro, private, licence allows commercial use, the prompt. Check the model for scripts: there are none in a GLB, but anything that arrives as an `.rbxm` is read line by line.

### 4.2 Blender: mesh

3. Import the GLB; apply all transforms. Check the creature faces forward and stands on the ground at Y = 0 (Blender is Z-up; export with Forward -Z, Up Y so Roblox gets -Z forward, +Y up).
4. **Symmetry first**: bisect the whole model at X = 0, delete the right half (+X in Roblox), mirror the left. UVs mirror onto the same texels, so the texture stays valid. This fixes the small left-right drift every generator has (PART_SPEC section 7).
5. **Split into the five templates**, using Meshy's segments as the starting point but cutting where this standard says:
   - Head: cut inside the collar, through the neck stub.
   - FrontLimb and Leg: cut at the body's underside (Biped arms: at the side), keep the left one of each pair.
   - Tail: cut at the rump.
   - Torso: everything else.
   If Meshy's segments are messy, select by hand; the Studio MCP also has a `segment_mesh` tool worth one test (not yet checked).
6. **Close every cut.**
   - Head, limbs, tail: delete the faces inside the joint zone, add a UV sphere of radius R centred on the plug point, join and bridge it to the part so the cap is round and closed. Map the cap's UVs onto a plain coat area of the texture.
   - Torso: close each socket opening with a rounded patch, coat-mapped. The torso is watertight (V2).
7. **Rest pose**: straighten limbs to hang straight down (rotate about the plug point), tail straight back, head forward (Quad, Winged, Serpent) or on top (Biped). Make each limb symmetric about its own YZ plane: bisect and mirror again. If a part needs more than a small rotation, it goes back to Meshy (PART_SPEC section 13 step 2).
8. **Check the bands** of section 1 with Blender's measure tool before going further: torso proportions, head and limb sizes, leg lengths, front against hind. Out of band: rescale the part uniformly in Blender if it is only size; regenerate if it is shape.
9. **Triangle budget per part** (section 6): decimate each part separately (Blender's Decimate, Collapse, with UVs preserved). Meshy's "about 3,000 for the whole creature" does not split the way our budget does; the caps add 60 to 120 triangles per part.
10. Export each template as its own mesh in one FBX (named `Head`, `Torso`, `FrontLimb`, `Leg`, `Tail`) with the creature's frame kept, so every part stays in the torso's frame.

### 4.3 Texture

11. Take Meshy's base colour texture (1024 x 1024; downscale larger ones). Run the tint-mask script:
    - group the pixels into colour clusters; pick the **coat** cluster (the largest, present on every part) and the **belly** cluster; everything else is **detail**;
    - force every joint-zone and cap texel to coat;
    - coat: remove hue, lift to average about 235, keep the light-dark variation; alpha 1;
    - belly: the same, average about 248; alpha 0.35;
    - details: untouched; alpha 0;
    - save straight (not premultiplied) alpha as `<Species>_tint.png`, and the inverted alpha as `<Species>_overlay.png`;
    - print the measured natural coat colour (cluster average, divided by the neutral level per channel, clamped) for the species file.
12. Look at the mask by eye on a flat render: eyes and mouth untouched, no coat speckles on details, no detail speckles in the coat. A noisy mask means the concept was not in flat blocks: regenerate rather than paint over.

### 4.4 Studio: templates

13. Import the FBX with the 3D Importer (or upload through Open Cloud with the `rbx-import-asset` skill); upload the texture.
14. (S) Put the five MeshParts in `ReplicatedStorage.CreatureParts.<Species>`, named exactly; set the folder's `BodyPlan` attribute.
15. (S) Scale uniformly so the torso's `torsoLength` is inside the plan's band (PART_SPEC section 13 step 4).
16. (S) `TextureID = ""`. Add one `SurfaceAppearance` to each template: `ColorMapContent` = the tint texture, `AlphaMode = TintMask`, `Color` = the natural coat colour. `Material = SmoothPlastic`.
17. (S) Plugs, `PivotOffset`, torso sockets, physics flags: PART_SPEC section 13 steps 5 to 8, positions from section 1 above. Measure each plug radius with the gauge (PART_SPEC section 12); socket radii copy the species' own plug radii.
18. (S) Run `tools/studio/ValidateParts.luau`. Fix every FAIL; read the WARNs. Until R03 is updated (section 8), R03 reports the SurfaceAppearance; nothing else may fail.
19. Copy the printed numbers (`torsoLength`, `socketRadius`, `plugRadius`, `length`) and the `coat` colour into `src/content/species_data/<Species>.luau`; `lune run check`.

### 4.5 Mix test, then accept

20. (S) Build the species with **every other imported species of the same plan**, both ways round, every slot combination (the 32-mix contact sheet of BREEDING_PLAN step 3, per new pair). Check: heads sit in the collar at a believable size, all feet touch the ground, the body is level (Quad), no feature pokes through another, colour steps fall on the collar and limb tops.
21. `screen_capture` at phone size, Natural and two named colours. Compare with the brief's art direction and the other species (V7).
22. Accept with PART_SPEC section 14 plus the checklist in section 5 below. Update `docs/PROGRESS.md` with what Ayrton should look at.

---

## 5. Checklists

### 5.1 Ayrton, in Meshy, before exporting

Concept picture:

- [ ] The prompt has all six blocks, with the STANDARD BODY LINE for the right plan pasted word for word.
- [ ] Standing in the rest pose: Quad back level and four legs straight down; Biped upright with arms hanging straight down.
- [ ] A visible gap between the arms and the body, and between the legs. The tail touches nothing.
- [ ] The head sits in a rounded collar; the tail starts as a round stub.
- [ ] Every signature feature sits wholly on one part (head, body, a limb or the tail); nothing drapes, wraps or runs across from one part to another.
- [ ] One main colour on every part, one lighter belly colour, details in clearly different colours, flat blocks, no painted shadows.
- [ ] Nothing see-through.
- [ ] Original: it does not look like a creature from another game.
- [ ] Ideally front, side and back views (multi-view) of the same design.

3D model, before exporting:

- [ ] Stylised, low poly, about 3,000 triangles, part segmentation on, texture on, no metallic or glossy finish.
- [ ] From the side: legs straight, front and back legs the same length, feet flat on the ground.
- [ ] From the front: left and right look the same.
- [ ] The segments roughly follow head, body, legs, tail (and arms or wings), not random chunks.
- [ ] The face reads at a glance in a small view.
- [ ] Export GLB with textures (and FBX if offered); save to `art/meshy/<Species>/` with the picture and the prompt text.

### 5.2 The lead, on import (on top of PART_SPEC section 14)

- [ ] B1 Torso proportions and socket ratios inside the plan's bands (section 1).
- [ ] B2 Head, limb and tail sizes inside the bands; Quad front limbs 0.95 to 1.05 of the hind legs.
- [ ] B3 Joint zones plain coat; no feature crosses a joint; torso features at least 1 R clear of every socket.
- [ ] B4 Every feature on the part that owns it (section 2.2).
- [ ] B5 Caps closed and round, coat-mapped.
- [ ] B6 Tint mask clean; natural coat colour recorded; both texture files saved.
- [ ] B7 Mix test passed against every species of the plan already in.

---

## 6. Triangle budgets

| Tier | Head | Torso | FrontLimb | Leg | Tail | Whole creature |
| --- | --- | --- | --- | --- | --- | --- |
| Standard (every wild, starter and bred creature) | 600-900 | 600-900 | 200-350 | 200-350 | 200-350 | up to 3,000 (hard limit 3,600) |
| Giant | 1,200-1,800 | 1,200-1,800 | 400-700 | 400-700 | 400-700 | up to 6,000 (hard 7,200) |
| Winged (later) | 600-900 | 600-900 | wing 300-450 | 200-300 | 200-300 | up to 3,600 |
| Serpent (later) | 600-900 | 600-900 | fin 150-250 | fin 150-250 | 500-800 | up to 3,000 |

Rarity tiers (gem tiers, Ruby, Diamond, Cosmic) use the same meshes; their look is tint and effects only. The hard limits per part are PART_SPEC's (125% of the top of the target range). Ball caps count.

---

## 7. Still to verify

- That TintMask multiplies the ColorMap by `SurfaceAppearance.Color`, and how it looks at low graphics quality on phones (section 3.4).
- Whether `MeshPart.Material` still shows under a SurfaceAppearance (decides how gem tiers look).
- That a transparent texture pixel shows `MeshPart.Color` (the fallback).
- What Meshy's part segmentation returns (named pieces or loose islands) and whether it keeps one shared UV atlas across segments (this standard assumes one texture per species).
- Whether the Studio MCP `segment_mesh` tool helps with step 5.
- The on-screen Highlight limit, if gem tiers use a rim highlight.

## 8. Changes this standard makes to the spec (to log in DECISIONS.md, then apply)

| Where | Change |
| --- | --- |
| PART_SPEC section 10, R03, V4 | Templates carry one SurfaceAppearance (`AlphaMode = TintMask`, ColorMap = the species' tint texture); `TextureID` stays empty; V4 becomes "the coat zone is neutral and tints; details keep their paint". The validator's R03 accepts exactly this |
| PART_SPEC R13 | Quad front limbs 0.95 to 1.05 of the hind legs (WARN outside), from 0.85 to 1.15 |
| PART_SPEC section 2 | Winged and Serpent sections as proposed in 1.3 and 1.4 (later biomes; Ayrton to confirm the plans) |
| `SpeciesDef` | A `coat` colour per species (the natural tint), and per-plan bands checked by a Lune test over the species data |
| Colour gene | A `Natural` gene value (each part keeps its own species' coat); named colours tint the whole body. Touches the breeding roll: Ayrton approves first |
| Assembler | Sets `SurfaceAppearance.Color` per part instead of `MeshPart.Color`; gem tiers become effects |
| Gem tiers | Effects (sparkles, rim, sheen) instead of Material swaps, if the Material check in section 7 fails |
