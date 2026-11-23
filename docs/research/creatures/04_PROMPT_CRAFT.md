# Creature design research 04: prompt craft for clay-toy creatures

How to prompt the concept image (Nano Banana Pro or GPT Image) and set up Meshy image-to-3D so all 36 creatures look like one family of handmade clay toys, low-poly and chunky (brief section 12), with parts that come apart for breeding (`docs/PART_SPEC.md`). It builds on the pilot (`docs/art/MESHY_PILOT.md`). The Meshy facts come from its docs as of November 2026. Meshy changes its models often, so re-check the settings table before each batch.

## 1. Why clay and designer toys appeal

- **Aardman: you can see the hand.** Plasticine with thumbprints, big simple forms, wide mouths. The flaws are part of the charm. For us the texture carries the handmade feel; the geometry stays smooth and chunky.
- **Laika: a miniature on a tabletop**, lit by one soft key light. We borrow its photography words, not its spindly proportions.
- **Pop Mart: one silhouette, one attitude.** A head as big as the body, a matte surface, a small palette, one expression with some edge (a pout, a grin) and one signature feature you could draw from memory.
- **Sylvanian Families: a recognisable family.** The species share one body, one surface and one face, and differ only in colour, ears and tail. That is our roster rule: **fix the body, face and surface; vary only the hook and the palette.**

Shared rules: a big head and short legs, eyes set low and wide, round shapes for friendly creatures, blocky for sturdy ones, blunt triangles for fierce ones, two main colours plus one accent, and one hook (the pond bubble, the spade snout).

## 2. How to write a prompt

**Order:** style prefix, pose line, the creature (hook first, then colours and face), then the negative line. Image models weight the early words most. Write plain sentences, not keyword lists; both models follow description better, and Google's tips tell you to name the subject, composition, style and camera directly. Meshy's text-to-image takes 800 characters at most, so use the short prefix there.

**Anchor with images, not only words.** This is the strongest consistency tool. Attach two or three approved creatures as references and give them a role: "Images 1 and 2 are the style reference: match their clay material, lighting, eyes, proportions and camera exactly, but design a different creature." Nano Banana Pro takes many references (up to 14, depending on where you run it). Keep the model, version, 1:1 aspect ratio and prefix the same for the whole batch.

**Lock the eyes.** Eyes show family resemblance more than anything else. Use the same eye wording every time; let only the brows and mouth carry personality.

**Turn off Meshy's Refine Prompt** once the prefix is settled. It is on by default and rewrites your prompt toward a simpler cartoon, differently each time. Meshy's Styles option switches off Multi-view.

### Known failure modes and fixes

| Problem | Cause | Fix |
| --- | --- | --- |
| Name plaque, base, display box | "toy", "figurine", "collectible", "statue", or the species name (the model writes it out) | Never use the name. Say "standing directly on the floor"; end with "no text, no base" |
| Realistic animal (platypus) | Naming a real animal pulls in its anatomy | Name it once at most ("calf-like"), then overrule it: head as big as the body, stubby legs, mitten paws, a wide flat face |
| Grand creature becomes a white horse | "majestic", "elegant", "legendary", "ultimate" | Show rank with ornament, colour and size, keep the toy proportions, name the paws and face |
| Glossy plastic | "vinyl", "3D render" | "soft matte plasticine"; gloss on the eyes only |

**Negative phrasing.** Neither model has a negative-prompt field, and naming a thing can plant it. Describe what you want first, then keep exclusions to one short closing line, which worked in the pilot.

## 3. Camera, light and background

- **Camera:** three-quarter front, slightly above eye level, telephoto (near-orthographic), whole body centred with a margin. Meshy warns that strong perspective distorts the mesh, and this angle shows all four legs.
- **Light:** soft and even. Dark shadows become black patches in Meshy's texture, and rim light, bloom or coloured light all get baked into the colours.
- **Background:** plain white; light grey for pale creatures, so background removal does not eat the belly. 1:1, at least 1024 px.

## 4. Poses and separable parts

Meshy's A-pose and T-pose options are for bipeds. For the other body plans, the pose comes from the picture. **Gaps are what make segmentation work:** space between each limb and the body, a visible neck crease, a tail that does not touch the back, legs that do not touch each other. A colour change at each joint (darker paws, a belly that stops at the hip) helps Meshy cut there and helps swapped parts read on screen. Keep each body plan's proportions the same in every prompt, so a Spadesnout head fits a Sloshcalf torso (PART_SPEC section 9).

Leave off anything loose: clothing, held objects, hair strands, chains. Meshy's Auto Split docs name chains, hair, openings and tangled detail as what it splits worst.

## 5. Multi-view turnarounds

A single image has no back, so Meshy guesses it. There are two ways to get the other views:

1. **Meshy text-to-image with Multi-view on** (front, side, back). The easiest.
2. **A turnaround sheet in Nano Banana Pro or GPT Image:** "character turnaround sheet of the same creature shown four times in one row: front, left side, back, three-quarter front. Orthographic, identical scale, pose, colours and lighting. No labels, no text." Crop each view to its own square. Regenerate if the side view is a mirrored front or a marking switches sides.

**Catch:** Smart Topology takes one image. Multi-view (up to 4 images) needs Meshy 7.1 High Detail. Use it only where the back matters (Sloshcalf's pond, a giant's shell).

## 6. What Meshy handles well and badly

**Well:** a single chunky, rounded subject with a clear silhouette, flat colour regions, a symmetric body, a stylised face and opaque matte surfaces.

**Badly, and what to do instead:**
- **Thin parts** (whiskers, antennae, wing membranes, thin tails) come out broken or paper-thin. Ask for "chunky, as thick as a finger" and paint fine detail into the texture.
- **Transparency** (bubbles, glass, water) becomes an opaque shell with whatever showed through baked onto it. The calf's bubble worked because its pond reads as painted colour. Ask for a "frosted, slightly cloudy" bubble, then set Transparency on that part in Roblox.
- **Floating pieces** (halos, orbiting stones, sparks) get merged into a blob or dropped. Attach them to the body, or add them in Roblox as parts or particles.
- **Glow** (lanterns, stained glass, runes) bakes into the colour with a blurry halo. Prompt "painted bright warm yellow, not glowing" and add Neon or a light in Roblox. For stained glass, ask for "opaque coloured panels with dark outlines".
- **Shine and text** get baked in or turned into geometry. Keep everything matte except the eyes, and leave text out.

**Image Enhancement** (on by default) redraws your input. Turn it off for a concept you have already approved.

## 7. Tiers

Rarity tiers (Common to Cosmic) all breed, so they share the part budget: about 3,000 triangles per creature, hard limit 3,600 (PART_SPEC section 8). A higher tier earns its look from design, not triangles: one extra ornament, a richer palette, a grander stance. Giants never breed and may use twice the budget. The planned 3,000 to 8,000 range only fits giants, and 8,000 is above PART_SPEC's limit of twice the budget, so it needs a DECISIONS entry.

---

## STYLE PREFIX (paste first, verbatim)

> Studio photo of a cozy handmade clay creature, sculpted from soft matte plasticine with faint fingerprint texture and gently rounded edges. Chunky toddler proportions: a big round head, a soft bean-shaped body, short sturdy limbs. Two large round glossy black eyes with one small white highlight each, set low and wide on the face. Simple flat colours, two main colours and one accent. An original creature, not a real animal. Three-quarter front view, slightly above eye level, long telephoto lens, soft even studio light, whole body centred on a plain seamless white background, standing directly on the floor.

**Short prefix for Meshy's 800-character box:**

> Handmade matte plasticine clay creature, chunky toddler proportions, big round head, short sturdy limbs, two large glossy black bead eyes set low and wide, flat colours, original creature. Three-quarter front view, telephoto, soft even light, plain white background.

## POSE LINES (paste after the prefix, before the creature)

- **Quad:** "Standing on all four legs, back level, each leg straight down with a clear gap between the legs and from the belly, head forward with a visible neck crease, tail sticking straight out behind and not touching the body."
- **Biped:** "Standing upright, feet flat and slightly apart with a gap between the legs, arms hanging slightly away from the body in a relaxed A-pose with clear space under each arm, head facing forward." (Meshy Pose: A-Pose.)
- **Winged:** "Standing on two short legs, wings spread out to the sides in a shallow V, each wing a chunky rounded paddle shape with no thin membrane, a clear gap between the wings and the body, tail out behind."
- **Serpent:** "Body lying on the floor in one gentle S-curve with no coils touching, head raised forward on a thick neck, tail tip lifted slightly, any fins or frills short and chunky."

## NEGATIVE LINE (paste last)

> No text, no letters, no name plaque, no base, no stand, no display box, no clothing, no held objects, no floating pieces, no glow, no shine, no thin whiskers or antennae, no realistic fur, not a realistic animal, no extra limbs, only one creature.

## MESHY SETTINGS

| Setting | Common to Diamond | Cosmic / "ultimate" | Giant |
| --- | --- | --- | --- |
| Image input | 1 image, three-quarter front | 1 image for Smart Topology; turnaround sheet for a 7.1 reference | Multi-view (front, side, back, 3/4) |
| Mode / model | Smart Topology, Meshy T2.5 | Smart Topology T2.5 | Meshy 7.1 High Detail + Auto Split, then decimate per part |
| Target triangles | 3,000 (cap 3,600) | 3,400 to 3,600 | 5,000 to 6,000 (8,000 only with a DECISIONS entry) |
| Parts | Smart Topology segmentation | Smart Topology segmentation | Auto Split, "by parts": head, torso, front limbs, legs, tail |
| Pose | A-Pose for bipeds; off for the other plans | Same | Same |
| Image Enhancement | Off for an approved concept | Off | Off |
| Texture | On, matte; PBR off | On, matte; PBR off | On; Auto Split keeps texture per part |
| Export | GLB (+FBX) | GLB (+FBX) | GLB, parts as separate meshes |

Caveats: Meshy's docs disagree on segmentation. The web app says Smart Topology outputs native parts, but Auto Split refuses Smart Topology, remeshed and Meshy 6 Lite models, and 7.1's in-generation "Split" cannot be combined with Texture. Auto Split's "by parts" mode was marked temporarily unavailable in the API this month ("auto" still works). Test both routes on the pilot creatures before the batch. The old `lowpoly` model was retired on 30 October 2026, and `meshy-7` geometry retires on 31 December 2026.

## Sources

- Meshy docs: [Image to 3D](https://docs.meshy.ai/en/webapp/image-to-3d), [Prompting](https://docs.meshy.ai/en/webapp/guides/prompting), [AI image generation](https://docs.meshy.ai/en/webapp/guides/image/ai-image-generation), [Auto Split](https://docs.meshy.ai/en/webapp/guides/3d-model/auto-split), [API models](https://docs.meshy.ai/en/api/models); [Meshy image-to-3D blog](https://www.meshy.ai/blog/meshy-5-image-to-3d)
- Image models: [Google, Nano Banana Pro tips](https://blog.google/products/gemini/prompting-tips-nano-banana-pro/); [Leonardo Nano Banana guide](https://www.leonardo.ai/news/nano-banana-prompt-guide); [Dreamina GPT Image 2 turnarounds](https://dreamina.capcut.com/resource/gpt-image-2-for-character-turnaround-sheets)
- Transparency and thin parts: [Sloyd, photos that convert](https://www.sloyd.ai/blog/why-some-photos-convert-better-to-3d-than-others); [All3DP Meshy 6 test](https://all3dp.com/1/we-tested-meshy-6-can-ai-finally-generate-good-3d-printable-models-from-photos/); [Tripo, emissive materials](https://www.tripo3d.ai/blog/explore/ai-3d-model-generator-and-emissive-material-best-practices)
- Appeal: [AWN, Aardman at 50](https://awn.com/animationworld/aardman-50-inside-clay-felt-and-fingerprints); [Blender Studio, Sprite Fright](https://studio.blender.org/blog/sprite-fright-the-illusion-of-simplicity); [DEPT, Labubu](https://www.deptagency.com/insight/fluffy-feral-whats-behind-the-labubu-mania/); [Sylvanian Families](https://www.wikiwand.com/en/articles/Sylvanian_Families)
