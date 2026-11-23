# ClayPals: game icon and 5 store thumbnails

Date: 23 November 2026. Status: [Default] marketing guidance. Nothing here changes a [Locked] item.

## 1. What the research says

Sources: Roblox Creator Docs on [experience icons](https://create.roblox.com/docs/production/publishing/experience-icons) and [thumbnails](https://create.roblox.com/docs/production/publishing/thumbnails), DevForum threads ([Optimize CTR with Icons and Thumbnails](https://devforum.roblox.com/t/optimize-ctr-with-icons-and-thumbnails/3316365), [Thumbnail Personalization tips from staff](https://devforum.roblox.com/t/5-tips-from-roblox-staff-to-get-the-most-out-of-thumbnail-personalization/3471689), [Creating a proper Roblox icon](https://devforum.roblox.com/t/creating-a-proper-roblox-icon-a-guide-based-on-my-preliminary-research/1774810)).

Verified facts:
- The icon is square, minimum 512x512, and must pass moderation. Icons get prime placement on Home, so they must express theme, tone and genre.
- Roblox says personalised thumbnails raised qualified play-through by about 8.5% on average. Upload several thumbnails and let the platform pick.
- Third-party claims of 30 to 50% click-through swings from an icon change are anecdotal. Treat as direction, not data.
- Do not borrow other games' characters (also our hard rule: original content).

Not verified: I could not fetch live store pages for individual games from the search tool. The patterns below for top creature and pet games (Adopt Me, Pet Simulator, Creatures of Sonaria, Roblox pet and monster-tamer games) come from general knowledge and should be checked by eye. Open the Discover page on a phone and screenshot the top 20 creature games before final art.

Patterns commonly seen in top creature and pet icons (confirm by eye):
1. One big character face or body, filling 60 to 80% of the frame, eyes looking at the viewer.
2. Saturated background with a single strong hue and a soft glow or rays behind the subject.
3. Thick outline or strong rim light so it survives shrinking to about 100 px.
4. A hint of the loop: a cute pet plus a rarer, flashier one (egg, hatch, "legendary" aura).
5. Little or no text. Logos appear on thumbnails, not on the icon.
6. Expressive faces (big eyes, open mouth, smile). Cute beats realistic.
7. Many thumbnails show a rare creature, a group shot, and a gameplay moment (battle, trade, hatch).

Where ClayPals stands out: almost everything in the genre is glossy 3D or flat vector. A tactile handmade clay look (visible thumbprints, soft studio lighting, tiny shadows) is distinctive at thumbnail size and signals "cozy". Lean into it.

## 2. Global art rules (apply to every prompt)

- Style: handmade plasticine and polymer clay toys, visible fingerprints and tool marks, soft matte surface, chunky rounded shapes, tiny seam lines, shallow depth of field, soft studio light, tilt-shift miniature feel. Matches brief section 12 (low-poly, chunky, flat colours) as a clay-toy rendering of the same shapes.
- Palette per biome follows the design bibles in `docs/content/creature_scaffold/bibles/`. Keep two main colours plus one accent per creature.
- Readability test: shrink to 128x128. The main creature must still read as a single clear silhouette, and the eyes must be visible.
- No text in images, no real brands or recognisable characters, no UI mockups with fake numbers. The logo slot (thumbnail 1 only) is added in an editor afterward, not by the image model.
- Keep key content inside the centre 80% (Roblox crops differently per surface). Thumbnails are 16:9, ask for 1920x1080 or 2560x1440 and downscale.
- Use the game's real creatures from `src/content/species_data/` and `docs/content/creature_scaffold/` where possible, so the store matches what players get. Placeholder names in prompts: Mossmitt (Greenwood), Hollowbough (Greenwood giant). Swap in final creature names.
- Generate 4 to 8 variants per slot, pick the best at phone size. Record the tool, prompt and licence in `docs/ASSETS.md`.

Suggested shared suffix (append to every prompt):

> handmade plasticine clay figurines, visible fingerprint texture, soft matte finish, chunky rounded forms, warm soft studio lighting, shallow depth of field, tilt-shift miniature photography, no text, no letters, no watermark, no logos, original characters

## 3. Game icon (512x512, also exported 1024x1024)

**Concept: "The Hello."** One chubby clay creature, head and shoulders, looking straight at the viewer with big glossy bead eyes and a tiny smile, holding or wearing a small lasso loop like a necklace. Behind it a warm golden glow. A second, much smaller creature peeks from the bottom corner (hint of collecting).

**Composition sketch:** Square. Creature head fills about 70% of the frame, slightly below centre, eyes at the upper third line. Background is a single sunny mint-to-gold gradient with a soft radial glow behind the head. The lasso is a thick rope loop curving across the lower-left, giving a clear "tame" cue. Tiny sparkle at upper right. A 4 to 6% safe margin all round. Strong dark-brown contact shadow under the chin to separate the subject.

**Why it sells at phone size:** one face, one hue, high contrast eyes, cozy warmth, and the lasso says what you do.

**Prompt:**

> Square game icon, a single adorable chubby moss-green clay creature with big round bead eyes and a tiny smile, head and shoulders, looking straight at the viewer, holding a thick rope lasso loop in the lower left, a much smaller cream clay creature peeking from the bottom right corner, warm golden radial glow behind it on a mint to sunny yellow background, strong rim light, centred, subject fills 70 percent of frame, high contrast, readable at tiny size, [shared suffix]

**Variants to test:** (a) rare purple creature with a star glow instead of green, (b) the creature with a clay egg, (c) closer crop on the eyes only.

## 4. Five store thumbnails (16:9)

Order matters: slot 1 is the hook, then loop, then depth, then social, then the fantasy payoff.

### Thumbnail 1: "Meet your pals" (hero and logo slot)

**Concept:** A friendly group portrait of six clay creatures from different biomes (leaf, water, fire, frost, storm, hollow) standing on a small clay hill, waving or posing, in the team-of-six formation. This sells the "build a team of six" fantasy and the variety of biomes.

**Composition sketch:** Wide frame. Centre-left: the most charming starter creature, largest, eye contact. Five others in a shallow arc behind and beside, staggered heights, each with a distinct silhouette and colour. Right third left as clean sky-gradient negative space for the logo (added in an editor). Soft sunrise light, painted-clay hills and tiny clay trees in the background, blurred.

**Prompt:**

> Wide 16:9 key art, a group of six different original clay creatures posed on a small plasticine hill, each from a different biome (a moss-green leafy one, a teal water one, an orange ember one, a pale blue frost one, a yellow storm one, a dark purple hollow one), friendly poses, big bead eyes looking at the viewer, the leafy one largest on the left third, the right third left empty soft sunrise sky for a logo, miniature clay landscape with tiny trees in blurred background, [shared suffix]

### Thumbnail 2: "Lasso the moment" (taming)

**Concept:** The tame action. A trainer silhouette is not needed; show a wild creature mid-bounce with a glowing clay lasso loop closing around it, a perfect-timing ring flaring. Funny surprised face. This is the core loop and shows the skill-timing minigame.

**Composition sketch:** Creature centre, mid-leap, surprised wide eyes. A thick rope loop with a bright timing ring sweeping around it, motion arcs in clay swirls. Grass tufts and dust puffs at the bottom. Bright warm background with a spotlight cone.

**Prompt:**

> Action shot of a surprised round clay creature mid-jump on a grassy plasticine meadow, a thick glowing rope lasso loop closing around it with a bright circular timing ring, clay dust puffs and flying grass tufts, dynamic low angle, spotlight and warm background, comedic wide eyes, [shared suffix]

### Thumbnail 3: "Breed something new" (breeding)

**Concept:** Part-based breeding is the unique hook. Two parent creatures side by side with a baby in the middle that visibly mixes parts (one parent's ears, the other's tail), plus floating clay part pieces (horn, tail, wing) orbiting. Heart-shaped sparkles. Cute and curious.

**Composition sketch:** Triangular layout: parent A on the left, parent B on the right, tiny baby in the centre foreground on a small clay pedestal or nest. Three or four loose clay parts float in an arc above, each in a different colour. Soft pink and cream background for warmth, differs from the green slot 1 and 2.

**Prompt:**

> Two different clay creatures facing each other with a tiny baby clay creature in the centre foreground that combines features of both (one parent's ears and the other's striped tail), floating loose clay parts like a horn, a tail and a small wing orbiting above them, tiny clay hearts and sparkles, soft pink and cream background, cosy nest of clay straw, [shared suffix]

### Thumbnail 4: "Giants and badges" (battle and progression)

**Concept:** A turn-based boss moment. A towering moss-covered giant (Hollowbough, the Greenwood giant) looming over a small brave clay creature, with a gleaming clay badge in the corner. Dramatic but friendly, a "big fight" feel for the core-gamer audience, lighting from below for scale.

**Composition sketch:** The giant fills the right two thirds, cropped at the top, eyes glowing amber. The small hero stands bottom-left in a heroic pose, looking up, facing the giant. A shiny round clay badge floats upper-left with a soft glow. Autumn forest background in blurred clay trees. Strong scale contrast.

**Prompt:**

> Epic but cute battle scene, a huge towering clay tree giant with a hollow face and glowing amber eyes and moss on its shoulders looming on the right, a small brave round clay creature in a heroic stance looking up at it on the bottom left, a shiny round clay badge floating in the upper left with a glow, blurred clay forest at dusk, dramatic low angle lighting, [shared suffix]

### Thumbnail 5: "Trade and explore" (social and world)

**Concept:** Cozy social play. Two clay creatures (owned by two trainers, implied by two small bags or scarves) swap a glowing egg or token across a small bridge, with a layered world map of biomes receding behind (green hills, desert canyon, snowy peaks, glowing cave). Shows the eleven-biome journey and trading.

**Composition sketch:** Foreground centre: two creatures exchanging a glowing egg on a clay bridge. Background: a layered, tilt-shift vista with 4 to 5 biomes in bands from left to right, getting darker and stranger towards the right. A mythic silhouette (the ultimate creature) faintly visible in the far sky for intrigue.

**Prompt:**

> Two friendly clay creatures swapping a glowing egg on a small plasticine bridge in the foreground, behind them a layered miniature landscape showing green hills, a desert canyon, snowy peaks, a glowing crystal cave and a stormy sky, a faint huge mythic creature silhouette made of stars in the far sky, tilt-shift miniature world feel, warm light, [shared suffix]

## 5. Production checklist

1. Generate icon and each thumbnail with 4 to 8 variants. Pick at phone size (hold the file at 100 px and 360 px wide).
2. Use real in-game creature renders as a reference image when the tool supports it, so the store matches the game. Keep hands-on: fix any extra limbs, odd eyes or text artefacts.
3. Add the logo to thumbnail 1 only. Logo wordmark: thick rounded clay lettering, drawn separately.
4. Moderation: no real brands or characters, nothing scary, no fake Robux or "free" claims, no misleading UI.
5. Upload 5 thumbnails (1 hero, 4 supporting), then enable thumbnail personalisation so Roblox can test them. Re-check after two weeks of data and replace the lowest performer.
6. Record every image generation tool, prompt and licence in `docs/ASSETS.md`. Ask Ayrton before spending money on tools or commissions.
7. Paid-random rules still apply: no imagery implying random paid pulls with hidden odds (CLAUDE.md hard rule 4). Do not show Robux in thumbnails.
8. A/B ideas: icon variant (a) rare purple, (b) with egg, (c) eyes crop. Thumbnail 1 with and without the group of six.
