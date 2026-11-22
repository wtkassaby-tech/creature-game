# What makes it appealing: an art direction

23 November 2026. Written as art director, for Ayrton and for whoever builds the screens. Nothing here is decided until Ayrton says so. No code was changed.

What was looked at: eight Studio screenshots from 23 November (starter pick, battle menu, the four moves, town, route, Creatures list, dialogue box, four creature models), the code that builds them (`Kit`, `BattleView`, `MoveButton`, `ResultPanel`, `BattleStage`, `Portrait`, `StoryView`, `Dressing`, `TestMap`), the earlier research (`00_REPORT.md`, `06_POKEMON_SCREENS_SEEN.md`) and web sources listed at the end.

**How to read the tags.** *(Sourced)* means a web page or Roblox's own docs say it. *(Judgement)* is my own eye. *(Check in Studio)* means the API exists but the exact look must be tried before it is relied on.

---

## 1. Verdict

**What already works.**

1. **The creatures.** The painted clay-toy models (bull with a mossy back, the blue frog-bear, the stump, the birch-bark stork) are the best thing in the game by a distance. They have soft light, real faces, different silhouettes and one odd detail each. They are what "homely" looks like. Everything else should be built to sit beside them.
2. **The painted cottages and the shop.** Thatched roofs, a striped awning, barrels and crates. They say "village" at a glance.
3. **The bones of the battle screen.** Over-the-shoulder camera, two slim plates, a text box with the menu beside it, type-coloured moves with STRONG and WEAK. That is the right layout. It is the skin that is wrong, not the skeleton.
4. **Cream paper and dark ink** as the UI base. It is warm, it reads, and it is the right base for a handheld feel.

**What most undermines appeal now, worst first.**

1. **Flat slabs of colour.** Every button is one flat colour, edge to edge, with a stroke. Big flat blocks are what read as "AI generated" and "bland": nothing tells the eye where to land, and nothing has been touched by a hand. The FIGHT/ITEMS/SWITCH buttons and the move buttons are the worst cases. *(Judgement; Ayrton's own note.)*
2. **The world around the creatures is empty and unplanned.** The town is a huge beige disc with buildings pushed out to the rim and no paths, fences or middle. The route is lime green and beige with a tree in the camera's face. The painted props are scattered, not composed, so the good models look dropped in. *(Judgement.)*
3. **Things that are not ours break every shot.** The player's own Roblox avatar (a lime "burp" shirt) stands in the battle frame. A grey studded spawn pad with a force-field bubble sits in town. A grey "Test" button is in every screenshot. Floating labels in white Gotham with a grey stroke ("The Ring", "Rival") are the Roblox default and look like a free model. *(Judgement.)*
4. **Type is set like a form, not a game.** The pixel face is thin and wide at small sizes, sentences in Source Sans Bold feel like a web page, and the starter title "Pick a friend" is the smallest heading on its screen. No name ever looks like a name.
5. **No creature on the screens that name creatures.** The plates say "Mossmitt Lv 5" with no picture, the list rows have a postage-stamp icon, and the dialogue has no face. Ayrton asked for the "2D cutout of the creature behind the text"; it is also the cheapest way to make every box feel like it belongs to someone.

**The single direction.** *Painted toys in a storybook village, framed by an old handheld's cream-and-ink boxes, with texture in the boxes themselves: two-tone lips, stripes, a type emblem and a creature cutout.* Warm late-afternoon light outdoors, cream and ink indoors (in the UI), one colour per type. Nothing flat that is bigger than a thumb.

---

## 2. Screen by screen

### 2.1 Starter pick

**Works.** The three creatures are big, in full colour and turned a little to one side. One card per choice, with the type colour as the card. The mentor's line is on the same screen, so the choice has a voice.

**Problems and fixes.**

1. **Three slabs of saturated green, blue and tan.** The creatures float on flat fills that fight their own colours (the grey-headed Mossmitt on green, the blue Sloshcalf on blue). *Fix:* cream card (`#FBF3DC`) with a type-coloured top 55% built as the move-button recipe below (lip, stripes, emblem), the creature standing across the seam, its feet on a soft ink ellipse shadow on the cream half.
2. **The creatures are small for the card** (about 40% of its height) and float with no ground. *Fix:* portrait 75% of the card height, feet at 62% down; a shadow ellipse (Frame, ink, transparency 0.8, UICorner 0.5, 45% card width by 6% card height) under the feet.
3. **Names in the thin pixel face at the bottom.** They do not feel like names. *Fix:* name in FredokaOne 30 px (1080p), type as a pill chip with its emblem under it.
4. **No sense of choosing.** No hover, no selected state, no "are you sure". *Fix:* on hover or first tap the card rises 8 px and its drop shadow grows from 4 to 10 px, the creature plays a hop; a second tap (or a "Choose Mossmitt" button that appears) confirms. One choice for life deserves a confirm.
5. **The world behind is a brown wall and a grey pad.** *Fix:* dim the world behind every full-screen panel: one Frame, `#1E2433`, transparency 0.45, and a local `BlurEffect` Size 12 in Lighting while the panel is open. Title in FredokaOne 40 px, centred, with the mentor's line under it in Nunito.

### 2.2 Battle, the menu

**Works.** Over-the-shoulder camera with the opponent further off. Plates and text box in the right places. Speed switch hidden in a corner.

**Problems and fixes.**

1. **FIGHT, ITEMS and SWITCH are three huge flat slabs**, taller than they are wide, with tiny words. *Fix:* the menu panel holds a 2 by 2 (tamer: FIGHT wide on top, ITEMS and SWITCH under it) grid of textured buttons (recipe in 3.5), each 64 px tall at 1080p, with an emblem drawn from shapes (FIGHT: a starburst from two rotated squares; ITEMS: a satchel of two rounded rects; SWITCH: two arrows; LASSO: a ring with UIStroke; RUN: a chevron). Label in FredokaOne 28 px.
2. **The player's avatar stands in the frame** (lime shirt, cut in half by the screen edge). *Fix:* in `BattleStage.open`, set `LocalTransparencyModifier = 1` on every part of the local character and put it back in `close` (the same trick `clearAround` already uses). Better still, move the avatar to stand beside its creature, but hiding is a two-line change.
3. **The message box is half the screen and almost empty.** *Fix:* box 52% wide, 22% tall; text in the pixel face 26 px; a small blinking down-triangle in the bottom right when waiting; the double-rule frame (3.4).
4. **Plates are identical cream bars with no face**, and the foe's plate is far from the foe. *Fix:* the creature cutout (3.6), a darker cream for the foe's plate (`#EFE3C2`) so the two sides differ, and the foe's plate pulled in to sit just above and beside the foe's head (now it floats in the top-right corner), yours just beside your creature's shoulder; level as "Lv 5" in a small ink pill.
5. **Grey studded pad and beige ground** under the stage. *Fix:* delete the place's default SpawnLocation (TestMap's own spawn is already invisible, so the studded one is left over in the place file). Battle pads: rim `#D9C79A`, patch `#7FAF5A` with a ring of six small grass tufts (three thin rotated wedges each) so the pad reads as a meadow spot, not a coaster.

### 2.3 Battle, the four moves

**Works.** Type colours carry meaning, STRONG/WEAK on the button, damage preview, a clear BACK.

**Problems and fixes.**

1. **Flat colour edge to edge** (Ayrton: "more texture is needed"). *Fix:* the move-button recipe in 3.5: lip, light band, stripes, emblem.
2. **The text is scattered**: name centred at the top, "Water 21 dmg" bottom left in another face, "WEAK" tiny grey bottom right. Three alignments in one button. *Fix:* everything left-aligned on a 14 px inset: name in FredokaOne 26 px; under it a type pill (cream text on the dark type colour) and the damage as "21" in the pixel face; STRONG/WEAK as a tilted sticker in the top right corner (below).
3. **WEAK is grey on blue and hard to see; STRONG is pale yellow on yellow for Storm.** *Fix:* a sticker: cream pill with ink stroke 2 px, rotated 6 degrees, overlapping the top-right corner by 6 px. "STRONG" in `#C0392B` ink-red with a small up-arrow, "WEAK" in `#6E6676` with a down-arrow. It reads on every type colour because it carries its own background.
4. **BACK is a quarter of the panel**, a big cream block. *Fix:* BACK as a narrow column (12% of panel width) with a left-arrow emblem, in `panelShade`; the moves get the room.
5. **Four buttons of the same type look like one big blue block** (three Water moves). *Fix:* the emblem and stripes break each button up; also a 10 px gap between buttons (now 8) so the ink strokes do not merge, and each button's drop shadow separates it.

### 2.4 Town

**Works.** The painted cottages, the shop with its awning, villagers at their doors, the sky.

**Problems and fixes.**

1. **A vast empty beige disc.** The plaza fills the middle and the buildings sit on the far rim, 60 to 100 studs away, so the town feels like a car park. *Fix:* shrink the plaza to 30% of the hub (now 62%), make the open ground grass, and bring every building to 30 to 45 studs from the centre (section 4).
2. **No paths, so nothing leads anywhere.** *Fix:* a path from the plaza to each door, 8 studs wide, cream-tan with a darker edge; routes leave the plaza as wider paths.
3. **No middle.** The eye has nowhere to rest. *Fix:* one focal point on the plaza: the well (already a painted prop) or the Notice Oak on a low round step, with benches and a lamp. Everything faces it.
4. **Floating labels in white Gotham** ("The Ring", "Thistledown (Greenwood)") look like a default Roblox place. *Fix:* hanging wooden signs (3.7) shown within 60 studs only.
5. **Grey studded spawn pad, a lone brown block** ("The Ring" is a box on the left), a bare post. *Fix:* remove the spawn; dress The Ring as an arena (a fenced circle of grass with banners) or give it a painted model; the sign post gets a board.

### 2.5 Route with wild creatures

**Works.** The painted Mossmitt in the wild is charming; the apple tree is lovely up close; the far trees form a line.

**Problems and fixes.**

1. **A tree trunk fills the middle of the screen** and hides the player. *Fix:* `StarterPlayer.DevCameraOcclusionMode = Invisicam` (a built-in setting; parts between camera and character fade), and in `Dressing.scatter` keep trees at least 18 studs from the path edge (now 10).
2. **Lime field and beige floor with a hard straight edge.** The green (about `#76CC45`) is acid and the sand is the town's sand. *Fix:* route ground `#7DB356`, path `#D9B98A` with a 1.5-stud darker edge strip `#B8946A`, and a grass-edge strip of small tufts along both sides so the edge is ragged.
3. **Wild creatures stand on bare ground.** *Fix:* put them in long-grass patches (darker `#5E9A48` tufts, 1.5 to 2.5 studs tall) so a creature in the grass reads as "wild", and give each a soft blob shadow.
4. **Sizes do not agree.** The tree is huge, the creature is toddler-sized next to the player, the far trees are tiny. *Fix:* one scale table: villagers 6.6 studs, trees 16 to 22, cottages 26, creatures 3 to 6 by size class; the scatter keeps big trees in clumps of three behind small bushes so depth reads.
5. **The spiky creature on the right is a busy clump of brown and yellow** with no clear outline at distance. *Fix (model note):* its back spikes want one colour and fewer pieces; until then, a cream rim light helps (see lighting in section 4).

### 2.6 Creatures list

**Works.** A single panel, clear counts, action buttons labelled in words, a breeding tray along the bottom.

**Problems and fixes.**

1. **A spreadsheet.** Rows of "[1] Sloshcalf Lv 5 Common 100% health" in one line of bold text. *Fix:* the 3 by 2 card grid from `06_POKEMON_SCREENS_SEEN.md` for the team, and a 4-across grid for the rest; each card has the cutout (3.6), name, level pill, a health bar, a rarity edge.
2. **Three big buttons repeated on every row** (Off team, Breed, Release), with red Release beside everything. *Fix:* tap a card to open a side panel with the actions; Release becomes a small text button inside that panel, behind a confirm.
3. **80% of the panel is empty cream.** *Fix:* the grid fills it; when there are few creatures, empty slots show as dashed outlines (a Frame with a UIStroke at 0.6 transparency) so the space looks waiting, not empty.
4. **Tiny icon at the row start** (about 30 px). *Fix:* the cutout in the list row recipe (3.6), 1.3 times the row height, bleeding off the top.
5. **"Pens 0/1: empty  Candy: Leaf 0, Sand 0, Water 0" in grey text.** *Fix:* a strip of small chips, each a type emblem and a number.

### 2.7 Dialogue box

**Works.** Bottom-centred, typed out with a tick, NEXT is finger-sized.

**Problems and fixes.**

1. **"You received" as the speaker in red** looks like an error. *Fix:* the speaker sits in a name tab, a pill (cream, ink stroke 3, FredokaOne 20 px) overlapping the box's top-left edge by half its height. Gifts get a gold tab `#E8B23A` with "Got it!" and a gift emblem.
2. **The NEXT button is a big blue block inside the text.** *Fix:* remove it; the whole box is the button, and a blinking ink down-triangle (a square Frame rotated 45 degrees, half hidden) sits bottom right. Keep a 44 px tap area.
3. **No face.** *Fix:* for a creature line, the cutout (3.6) at the left end; for a person, later a portrait. Until then, the name tab is enough.
4. **The text is small and far from the speaker** (a blank line between). *Fix:* text 24 px pixel face starting 12 px under the tab, 2 lines visible, line height 1.25.
5. **The camera shows a brown wall and the player's back.** *Fix:* for story lines, swing the camera to frame the speaker over the player's shoulder (later), or at least dim the bottom 30% of the screen with a gradient (Frame, ink, UIGradient Transparency 1 at top to 0.6 at bottom) so the box sits on something.

### 2.8 Four creature models

**Works.** Clay finish with real light and shade. Distinct silhouettes. Big heads, short limbs. One odd detail each (the mushroom on the bull, the sprout on the stump). Colour leans to type.

**Problems and fixes.** (One note on the brief: these painted models are not the [Locked] "low-poly, flat colour" look. Ayrton likes them; whether they replace that rule, or stay for wild and story creatures while bred parts stay flat, is his call and should go in `DECISIONS.md`.)

1. **No ground contact.** In the sky test they float; in the world they stand on plain ground with no shadow under them. *Fix:* a blob shadow under every creature: a Decal-free flat cylinder, ink `#2E2C3E`, transparency 0.65, 0.05 studs tall, 80% of the creature's footprint, `CastShadow = false`.
2. **Scale differs a lot** (the stork is twice the frog-bear). *Fix:* sizes by class in data, not by the mesh's own bounds.
3. **The textures are lit softly but in the world they can go flat under strong ambient.** *Fix:* lighting values in section 4 (warmer, less ambient, more sun).
4. **They blend into busy backgrounds** (the spiky route creature against grass and trees). *Fix:* in battle, a warm rim from behind: a `SpotLight` on the stage, colour (255,226,180), Brightness 2, aimed at the foe from behind and above, so each creature gets a light edge that separates it from the scenery.
5. **Back views.** The battle camera sees their backs; the Mossmitt from behind is a grey ball. *Fix (model note):* the next models should be checked from behind, as `00_REPORT.md` already says.

---

## 3. Style guide

Everything here is built in Roblox UI code: Frames, UICorner, UIStroke, UIGradient, UIGridLayout, ViewportFrames, CanvasGroups. No bought art, no uploaded images.

### 3.1 Palette

Base (UI).

| Name | Hex | Use |
| --- | --- | --- |
| `paper` | `#FBF3DC` | Panel and card face |
| `paperShade` | `#EFE3C2` | Foe's plate, inner rule, pressed state, BACK |
| `paperDeep` | `#E2D2A6` | Lip under cream buttons, empty slots |
| `ink` | `#2E2C3E` | Every outline, main text, drop shadows |
| `inkSoft` | `#5A5468` | Second-level text on cream |
| `inkDim` | `#6E6676` | Hints, WEAK (darker than today's `#7C7684`, which is faint on cream) |
| `select` | `#FFD966` | The one highlight for "selected" or "your turn" |
| `gold` | `#C98A10` | Coins, rewards, titles of victory |
| `giftTab` | `#E8B23A` | Gift and reward tabs |
| `strong` | `#C0392B` | STRONG sticker text, danger |
| `hpGood` / `hpWarn` / `hpBad` | `#5BBF4E` / `#F2C230` / `#E0503E` | Health bar |
| `hpBack` | `#4A4658` | Empty bar |
| `hpTrail` | `#FFE9B8` | The pale trail after a hit |
| `wood` / `woodDark` | `#9A6A42` / `#6B4528` | Signs, frames in the world, the wooden sign UI |
| `dim` | `#1E2433` at 0.45 transparency | Behind any full-screen panel |

Types: keep the current hues (players are learning them) and add a light and a dark variant of each. Light = 28% towards white, dark = 62% of the base.

| Type | Base | Light (top band, stripes) | Dark (lip, chip, silhouette) |
| --- | --- | --- | --- |
| Leaf | `#58A850` | `#87C081` | `#376832` |
| Sand | `#C49654` | `#D5B384` | `#7A5D34` |
| Water | `#4888D8` | `#7BA9E3` | `#2D5486` |
| Toxic | `#965CBE` | `#B38AD0` | `#5D3976` |
| Frost | `#54B0C4` | `#84C6D5` | `#346D7A` |
| Crystal | `#D6608E` | `#E18DAE` | `#853C58` |
| Fire | `#DC683C` | `#E69273` | `#884025` |
| Storm | `#C89C1C` | `#D7B85C` | `#7C6111` |
| Arcane | `#6C74C4` | `#959BD5` | `#43487A` |
| Cosmic | `#584AA0` | `#877DBB` | `#372E63` |

Rules: one saturated colour per object; cream and ink everywhere else. Text on a type colour is `paper`, never pure white (pure white looks digital beside cream). *(Judgement, in line with the cosy-games writing that warm, limited palettes and soft transitions read as safe and soft; sourced: 80.lv on the Project Horseshoe coziness report, Kitfox Games.)*

### 3.2 Type

Three faces, each with one job.

| Face | Roblox | Used for |
| --- | --- | --- |
| Rounded display | `Enum.Font.FredokaOne` | Creature names, screen titles, button labels, the speaker tab |
| Pixel | `Enum.Font.Arcade` (as now) | Battle and dialogue lines, numbers (HP, damage, Lv), STRONG/WEAK |
| Body | Nunito Bold: `Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.Bold)` (set through `FontFace`) | Sentences in menus, descriptions, hints |

Why: the rounded face is the cosy signal (Animal Crossing's UI is consistently described as a soft rounded sans; sourced, fan analyses), the pixel face is the handheld signal, and keeping the pixel face to lines and numbers stops it looking thin. *(Judgement.)*

Sizes. Phone is 874 by 402 (landscape). The phone column is what to aim for; use a `UIScale` on each screen set from the viewport height (`scale = math.clamp(height / 1080, 0.42, 1)`) and set minimum sizes so nothing drops below the phone number.

| Role | Face | 1080p | Phone 874x402 |
| --- | --- | --- | --- |
| Screen title | FredokaOne | 40 | 22 |
| Result title (VICTORY!) | FredokaOne | 56 | 30 |
| Creature name on a plate | FredokaOne | 28 | 17 |
| Menu button label | FredokaOne | 28 | 17 |
| Move name | FredokaOne | 26 | 16 |
| Battle / dialogue line | Arcade | 26 | 15 |
| Speaker tab | FredokaOne | 20 | 14 |
| Body sentence | Nunito Bold | 20 | 13 |
| Numbers (HP 148/148, damage) | Arcade | 18 | 12 |
| Chips and stickers (Lv, type, STRONG) | Arcade | 15 | 11 |

Never use `TextScaled` without a `UITextSizeConstraint`: today every label scales to its box, so the same role ends up at different sizes on different screens (the starter title is smaller than the card names). Fix the size per role.

### 3.3 Spacing

- An 8 px grid at 1080p (so 4 px on a phone after scaling). Gaps between buttons 10, panel padding 14, between sections 22.
- Corner radius: panels 12, buttons 10, chips and tabs full pill (`UDim.new(0.5, 0)`).
- Touch targets at least 44 by 44 phone points.
- Text never closer than 12 px to an outline.
- One alignment per box: left, with a 14 px inset. Centre only titles.

### 3.4 Borders, shadows and the frame

- **Outline:** `ink`, UIStroke `ApplyStrokeMode.Border`, 3 px on panels and buttons at 1080p, 2 px on chips. On a phone the UIScale brings 3 down to about 1.5; set panel strokes to 4 so they stay at 2.
- **Hard drop shadow** under every panel and button: a sibling Frame behind it, same size and corner, `ink`, transparency 0.75 for panels and 0 for buttons (a solid "lip" in the dark type colour; see 3.5), offset 0 by 4 px (panels) or 0 by 5 px (buttons). Soft blurry shadows look modern; hard offset ones look printed and old. *(Judgement.)*
- **Double-rule frame** on the big cream panels (message box, dialogue, menus): the 3 px ink border, then a 4 px gap of `paper`, then an inner 2 px rule in `paperDeep` (an inner Frame inset 7 px, transparent, with its own UIStroke and corner radius 8). The double rule is the single strongest "old handheld" signal and costs one Frame. *(Judgement.)*
- **Paper grain** on panels, optional and subtle: a UIGradient on the panel, `Rotation 90`, Color `paper` at 0 to `#F6EBCD` at 1. It warms the bottom edge so the panel looks lit from above.

### 3.5 Texture on a coloured button

Ayrton: "more texture is needed in the attack style choice instead of the box being fully one color". Four constructions, all in code. **Two warnings first** (sourced, Roblox docs):

- A UIGradient on a TextButton or TextLabel works on the whole object and is warned to "blend with strokes and borders"; put gradients on a child Frame behind the text, never on the button itself.
- `ClipsDescendants` clips rotated children only when `StarterGui.ClipsDescendantsSupportsRotation` is on, and it never clips to rounded corners. So turn that StarterGui property on (it can be set in the Rojo project for StarterGui), and inset any clip container by the corner radius, or use a CanvasGroup with a UICorner (the docs say a UICorner under a CanvasGroup applies to the whole group; *check in Studio* that it rounds the content).

**A. Two-tone lip and light band** (cheapest, biggest effect).

```
Holder (Frame, transparent, the grid cell)
  Lip    Frame  size (1,0, 1,0)  pos (0,0, 0,5)   colour = dark   corner 10  stroke ink 3
  Button TextButton size (1,0, 1,-5) pos (0,0)    BackgroundTransparency 1  Text ""
    Face Frame  size (1,0, 1,0)  colour = base   corner 10  stroke ink 3   ZIndex 1
      UIGradient  Rotation 90
                  Color: 0 light, 0.38 light, 0.381 base, 1 base   (a hard step)
    Shine Frame size (1,-20, 0,3) pos (0,10, 0,6) colour paper, transparency 0.45, corner pill  ZIndex 2
    (labels)  ZIndex 4
```

The step at 38% gives the classic two-tone face; the 5 px lip under it in the dark colour makes it a key you can press. On press: tween Button down 4 px (`Position (0,0, 0,4)`) over 0.06 s, so the lip nearly disappears, and back on release over 0.1 s with `EasingStyle.Back`. Turn off `AutoButtonColor` (its grey darkening fights the colours); darken by setting Face's gradient to the dark-shifted sequence while held.

**B. Diagonal stripes** (the "texture" Ayrton is asking for).

```
Stripes  CanvasGroup  size (1,0, 1,0)  transparent  corner 10   ZIndex 2   GroupTransparency 0
  (or a Frame with ClipsDescendants = true, inset 4 px each side)
  for i = 0, N do   -- N = ceil(width / 22) + 4
    Stripe Frame  AnchorPoint (0.5,0.5)
                  Size (0, 7, 2.2, 0)        -- 7 px wide, taller than the button
                  Position (0, i*22 - 30, 0.5, 0)
                  Rotation 30
                  colour = light, BackgroundTransparency 0.55
```

Stripes 7 px wide every 22 px, at 30 degrees, in the light type colour at 0.55 transparency: visible texture without hurting the text. Put them only on the lower, base-coloured part (start the clip frame at 38% from the top) so the band and the stripes do not fight. Static: build once when the panel is made, recolour on `show`. For moving stripes on the selected button only, tween the clip frame's child offset by 22 px over 1.2 s, looped (a barber-pole shimmer).

**C. Dots** (softer; good for cream panels and the result screen).

```
Dots Frame  size (1,-8, 1,-8) pos (0,4, 0,4)  transparent  ClipsDescendants true
  UIGridLayout CellSize (0,4, 0,4)  CellPadding (0,10, 0,10)
  ~ (w/14) * (h/14) Frames, colour = dark (on a type colour) or paperDeep (on cream),
     transparency 0.7, UICorner pill
```

No rotation, so no clipping caveat. About 60 dots on a move button; 240 across four, which is fine. Offset every other row by 7 px for a halftone look by building rows by hand instead of the grid.

**D. Type emblem** (identity; teaches the type by shape as well as colour).

A large emblem built from simple Frames, 110% of the button's height, anchored to the right edge and bleeding 25% off it (inside the clip frame), in `paper` at 0.78 transparency. Shapes:

| Type | Built from |
| --- | --- |
| Leaf | Two Frames 1:2, UICorner pill, rotated 35 and 35+180 overlapped, plus a 3 px vein Frame rotated 35 |
| Water | A circle (pill) with a square of 70% its size rotated 45 degrees sitting on its top half: a drop |
| Sand | Three pill bars stacked, widths 100%, 75%, 50%, left-aligned: dunes |
| Toxic | Three circles of 50%, 35%, 25% in a rising cluster: bubbles |
| Fire | The water drop turned upside down, with a smaller inner drop in the light colour |
| Frost | Three pill bars, 100% by 14%, rotated 0, 60, 120: a snowflake |
| Crystal | A square rotated 45 degrees, with a second smaller one beside it |
| Storm | Two bars rotated 60 and -60 offset into a zig-zag |
| Arcane | A ring (transparent Frame, UIStroke 6 px, pill) with a dot in the middle |
| Cosmic | Two squares, one rotated 45: an eight-point star |

The same emblem, small and solid, goes into the type chip on plates and cards.

**Recommendation for the move buttons: A + B + D together.**

- A gives the shape (a pressable key) and the hand-made two-tone face.
- B gives the texture Ayrton asked for, only on the lower 62%.
- D sits over the stripes on the right and says the type without words.
- Text on top, left-aligned: move name (FredokaOne 26, `paper`, with a 2 px ink `UIStroke` on the text, `ApplyStrokeMode.Contextual`), under it a pill with the type name and "21" in the pixel face. STRONG/WEAK as a cream sticker on the top-right corner (2.3, problem 3).
- Selected or hovered: border turns `select` yellow 3 px and the stripes start to slide.
- A disabled move (no uses, waiting for the server): the whole holder in a CanvasGroup with `GroupTransparency 0.45` and `GroupColor3` a grey `#B8B4BC`, instead of fading each label by hand.

Use C (dots) on cream panels: the result screen, the starter cards' lower half, the Creatures panel background at very low strength (transparency 0.88).

### 3.6 The creature cutout

Ayrton: "a 2D cutout of the creature behind the text" in boxes that name a creature. `Portrait.luau` already renders the toy in a ViewportFrame; the cutout is the same picture, placed and tinted. Two versions:

- **Full-colour cutout:** the Portrait as now, with `Ambient (255, 246, 230)` and `LightColor (255, 236, 200)` so it is lit warm and flat, plus a "paper edge": a second ViewportFrame of the same model behind it, 6 px larger each way, in flat `paper` colour, and a third, offset 3 px right and 4 px down, in `ink` at 0.6 transparency. That reads as a sticker cut out of paper with a printed shadow.
- **Silhouette:** one ViewportFrame of a copy of the model with `TextureID` cleared and `Color` set to the tint, `Ambient` white and `LightColor` black, so it renders as one flat colour. *(Check in Studio: the docs say `ImageColor3` "colorizes" the render but do not say it multiplies; setting the parts' own colour and killing the directional light is the dependable route.)* For a dark silhouette, `Ambient` and `LightColor` both black gives black; then use `ImageTransparency` to soften it.

ViewportFrames are expensive; build each once when the screen is made and swap the model only when the creature changes. Do not animate breathing in cutouts (the world creature already breathes).

**On the health plate (battle).** The real creature is on screen already, so the cutout here is a quiet silhouette, not a second picture.

- Silhouette in the creature's dark type colour (for Mossmitt, `#376832`), `ImageTransparency 0.82` on your plate (cream) and 0.78 on the foe's (`paperShade`).
- Size: 150% of the plate's height, square.
- Position: anchored at the plate's right end, its centre 20 px in from the right edge, vertically centred 10% low, so the head shows and the feet go off the bottom.
- Bleeds off the right and bottom edges; clipped by an inner Frame inset 3 px (inside the stroke) with `ClipsDescendants` on, so it never covers the border.
- ZIndex under the name, bar and numbers; the type chip moves to the left of the name so the silhouette has the right end to itself.
- When the creature is hit, the silhouette flashes to `ImageTransparency 0.5` for 0.08 s; when it faints, it fades to 1.

**On the move panel.** The panel names your creature's moves; your creature stands behind them as a large faint cutout.

- Silhouette of your active creature in `ink`, `ImageTransparency 0.9`, on the cream panel behind the BACK column.
- Size: 170% of the panel's height. Position: centred on the BACK column, 25% below the panel's middle, so the head and shoulders show between and above the BACK arrow, the rest bleeding off the bottom and right.
- Clipped inside the double-rule frame.
- The move buttons sit on top; their own colour covers it, so it shows only in the gutters and behind BACK. That is enough to make the panel feel "theirs" without any noise on the buttons.

**In a list row or card (Creatures, Switch picker, party).** Here the cutout is the main picture, in full colour.

- Full-colour cutout with the paper edge and printed shadow.
- Size: 130% of the row's height (list row) or 70% of the card's height (card).
- Position, list row: left end, its left edge 8 px in, its bottom aligned to the row's bottom, so the top 30% sticks up above the row. Card: centred, feet on the card's mid-line, head poking 12 px above the card's top edge.
- Bleeds off the top only, never the sides. The row's clip frame therefore extends upward: make the row a transparent holder 30% taller than the visible row, with the visible cream row in its lower part and the cutout in the holder (not clipped by the row).
- Behind the name text: a large silhouette of the same creature in its light type colour at 0.75 transparency, 200% of the row's height, at the right end, bleeding off the right and bottom (the same recipe as the plate). The name and level sit over it.
- Rarity: the row's stroke colour changes (common `ink`, rare `#4888D8`, epic `#965CBE`, legendary `#C98A10`) and rare and above get the stripes (3.5 B) in the row's left 20%.

### 3.7 Words in the world

Replace the white Gotham labels (`TestMap.label` and `WorldView`) with a hanging sign.

- BillboardGui `Size (0,200, 0,46)`, `MaxDistance 70` (now 220), `LightInfluence 0`.
- Inside: a Frame `wood` `#9A6A42`, UICorner 8, UIStroke `woodDark` 3, a hard shadow 0 by 4 in `woodDark`; two short "rope" Frames on top (2 px by 10 px, `woodDark`).
- Text in FredokaOne, `paper`, 22 px, no text stroke.
- People's names: a smaller cream pill (`paper`, ink stroke 2, FredokaOne 16), 40 studs `MaxDistance`.

---

## 4. Town and world

What makes a town read as homely (sourced from the coziness writing, then applied): human scale, enclosure and a clear refuge, abundance (things on porches, flowers, washing), familiarity, soft transitions, and a clear inside against an outside. *(Sourced: 80.lv on the Project Horseshoe report.)* In a Pokemon-style town, the same reads as: a few houses close together around a centre, every door reached by a path, and the road out clearly marked. *(Judgement.)*

**Composition.**

- **A centre.** The well (or the Notice Oak) on a round cobbled step 24 studs across, raised 0.6 studs, with two benches and a lamp. Every building faces it (Dressing already turns houses to face the square).
- **A tight ring.** Buildings 30 to 45 studs from the centre, not on the rim. Their fronts form a rough ring; the gaps between them are where the routes leave.
- **One hero building.** The mentor's cottage (story start) is 20% bigger and set on the axis the player sees when they arrive (the camera faces it on spawn).
- **Odd numbers and clusters.** Props in threes: three barrels, three trees behind each house, a cluster of bushes at each corner. Never a lone tree in an open field.

**Paths.**

- Plaza `#CDB894`, ring edge `#A89470`.
- Paths `#D9B98A`, 8 studs wide, edge strips `#B8946A` 1.5 studs, from the plaza to each door and out to each route (route paths 14 studs).
- Paths curve: build each as three or four slabs with a small bend, not one straight slab.
- At each route exit: a wooden arch or two posts with a sign (`wood`) naming the route.

**Fences and edges.**

- A low post-and-rail fence (posts 0.8 by 3 studs every 6 studs, two rails 0.4 by 0.4) in `wood` around each house's front garden, 8 studs deep, with a gap at the path.
- A hedge line (`#4F8A3E`, rounded lumps 4 studs) round the outside of the town, broken at route exits. It is the "inside against outside" line that makes the town a refuge.
- Flower beds against house walls, not in the open: 3 to 5 blooms per bed, at most two colours per bed.

**Ground colour.**

- Open ground in town: grass `#7DB356` (warmer than today's acid green). No large areas of sand in a grass biome.
- Darker grass `#6A9E4A` under trees and along fences, in irregular patches (flat slabs 0.05 thick), to break the plain floor.
- Long grass for wild encounters: tufts in `#5E9A48`.

**Density.** About one prop every 6 to 8 studs along every path edge inside town; empty space only on the plaza and in front of doors. Outside the hedge, trees thick enough that the horizon line is broken (clumps of three every 20 studs).

**Lighting** (`Dressing.mood`). Late afternoon, gold and soft, with less washing-out haze than now. All values are starting points to tune in Studio.

| Setting | Now | Proposed |
| --- | --- | --- |
| `ClockTime` | 15.3 | 16.6 |
| `Brightness` | 2.3 | 2.6 |
| `Ambient` | (112,112,128) | (122,108,100) |
| `OutdoorAmbient` | (144,146,156) | (150,138,124) |
| `ColorShift_Top` | (255,236,204) | (255,214,160) |
| `ColorShift_Bottom` | default | (110,96,140) |
| `ExposureCompensation` | -0.25 | -0.1 |
| `ShadowSoftness` | 0.45 | 0.3 |
| Atmosphere `Density` / `Haze` | 0.27 / 1.5 | 0.3 / 0.8 |
| Atmosphere `Color` / `Decay` | (214,228,240) / (126,156,196) | (255,228,196) / (176,144,150) |
| ColorCorrection `Saturation` | 0.25 | 0.08 (the painted models are already saturated) |
| ColorCorrection `TintColor` | (255,248,236) | (255,242,222) |
| Bloom `Intensity` | 0.45 | 0.3 |

Also: warm `PointLight`s (colour (255,200,140), Range 12, Brightness 1) in each cottage window and lamp, so the town glows a little even by day; a later evening hour can switch them up. Lit windows are the oldest "home" signal there is. *(Judgement.)*

---

## 5. The fifteen changes that buy the most appeal for the least work

In order of appeal per hour of work.

| # | Change | File(s) |
| --- | --- | --- |
| 1 | Remove what is not ours from every shot: hide the player's avatar during battles (`LocalTransparencyModifier`), delete the place's leftover studded SpawnLocation, hide the Debug "Test" toggle outside test builds | `client/BattleView/BattleStage.luau`, the place file, `client/Debug/TestPanel.luau` |
| 2 | Move buttons: lip, light band, stripes, emblem, left-aligned text, STRONG/WEAK sticker (3.5, A+B+D) | `client/BattleView/MoveButton.luau`, new `client/UI/Texture.luau` for stripes, dots and emblems |
| 3 | Kit: lip and hard shadow on every button, double-rule frame and drop shadow on every panel, press squash, `AutoButtonColor` off | `client/UI/Kit.luau` |
| 4 | Fonts by role: FredokaOne for names, titles and buttons; Arcade for lines and numbers; Nunito for sentences; fixed sizes per role and a UIScale per screen | `client/UI/Kit.luau` |
| 5 | Palette in Kit: paper, paperShade, inkDim, select, light and dark per type (3.1) | `client/UI/Kit.luau` |
| 6 | Creature silhouette on both battle plates; foe's plate in paperShade; plates beside their creatures | `client/BattleView/BattleView.luau`, `client/Creatures/Portrait.luau` (add a silhouette option) |
| 7 | Lighting to golden hour with lower haze and saturation (section 4 table) | `server/World/Dressing.luau` (`mood`) |
| 8 | Town ground: grass instead of beige, plaza shrunk to 30%, paths to every door | `server/World/Dressing.luau` (`square`), `server/World/TestMap.luau` |
| 9 | World labels as hanging wooden signs, `MaxDistance` 70 | `server/World/TestMap.luau` (`label`), `client/World/WorldView.luau` |
| 10 | Menu: FIGHT/ITEMS/SWITCH/LASSO/RUN as textured keys with emblems; narrower message box with a waiting arrow | `client/BattleView/BattleView.luau` |
| 11 | Dialogue: speaker name tab, tap-anywhere with a blinking arrow, gift tab in gold | `client/Story/StoryView.luau` |
| 12 | Starter cards: cream lower half, textured type top, bigger creature with a shadow, hover lift, confirm, dimmed and blurred world | `client/Story/StoryView.luau` |
| 13 | Creatures list as a card grid with full-colour cutouts; actions in a side panel | `client/Creatures/CreaturesView.luau` |
| 14 | Route: Invisicam, trees kept 18 studs from the path, path edge strips, long-grass patches | StarterPlayer setting (Rojo project), `server/World/Dressing.luau` (`scatter`) |
| 15 | Blob shadows under every creature and grass tufts round the battle pads; town fences, hedge ring and lit windows | `client/Creatures/ToyBody.luau`, `client/BattleView/BattleStage.luau`, `server/World/Dressing.luau` |

Items 1 to 5 change every screen at once and are a day's work together. Do them first and take new screenshots before going on: the rest will be judged against them.

---

## 6. Sources

Sourced claims above come from these pages. Where a page could not be read in full (two returned 403), only its search summary was used.

- Cozy design: [80.lv, Using coziness in game design](https://80.lv/articles/using-coziness-in-game-design) (summarises the Project Horseshoe coziness report: abundance, gentle transitions, contrast with the outside, refuge, human scale, familiarity); [Kitfox Games, Designing for Coziness](https://medium.com/kitfox-games/designing-for-coziness-d33d2519a59e) (search summary only); [UX Collective, The calm and charm of cosy games](https://uxdesign.cc/the-calm-and-charm-of-cosy-games-in-a-chaotic-world-7f29dbd8f4d9) (search summary); [Why cozy games are harder to make than they look](https://urgametips.com/why-cozy-games-are-harder-to-make-than-they-look/) (menus should feel light and fast; bad UI sinks the mood).
- Animal Crossing UI: [UX Collective, Delight by design](https://uxdesign.cc/animal-crossing-delight-by-design-e2c0a1a4d462) (universal symbols over text; search summary); [What font does Animal Crossing use?](https://madegooddesigns.com/?p=9253) and [Fonts in Use](https://fontsinuse.com/uses/51354/animal-crossing-new-horizons) (rounded sans; they disagree on the face); a student case study describing simple rounded shapes with little shading.
- Stardew Valley: [Stardew Modding Wiki, UI recolour](https://stardewmodding.wiki.gg/wiki/Tutorial:_Making_a_UI_Recolor) (the wooden dialogue frame as a nine-slice with fixed corners).
- HD-2D: [Wikipedia, HD-2D](https://en.wikipedia.org/wiki/HD-2D); [Unreal Engine, Octopath Traveler's HD-2D art style](https://www.unrealengine.com/en-US/spotlights/octopath-traveler-s-hd-2d-art-style-and-story-make-for-a-jrpg-dream-come-true) (2D pixels in a lush 3D environment; flat-sheet characters; point lights for drama in combat).
- A Short Hike: [Wikipedia](https://en.wikipedia.org/wiki/A_Short_Hike), [PlayStation Blog](https://blog.playstation.com/2021/08/05/crafting-a-tiny-open-world-a-look-behind-the-scenes-at-the-creation-of-a-short-hike/) (pixels as the aesthetic; palette sampled from autumn photos; simple models let one person widen the scope).
- Paper Mario: [Iwata Asks](https://iwataasks.nintendo.com/interviews/3ds/papermario/0/1), [Kinephanos, Fold, Flip, Stick](https://www.kinephanos.ca/2015/fold-flip-stick/) (picture-book atmosphere; flat cutouts in a 3D world as a deliberate tension).
- Classic creature-game battle UI: [Bulbapedia, HP](https://bulbapedia.bulbagarden.net/wiki/HP) (green above half, yellow to a fifth, red below; our `Kit.healthColour` matches); [Escapist](https://escapistmagazine.com/?p=17739) and [Super Jump, Dual screens](https://medium.com/super-jump/pok%C3%A9mon-on-dual-screens-the-end-of-an-era-cc99eea927f2) (type read from icons without words; FIGHT as the most prominent action); [PokeCommunity on Legends: Arceus](https://daily.pokecommunity.com/2022/07/10/battle-visuals-analysis-in-pokemon-legends-arceus) (short intros, straight into the action).
- Sprites in 3D on Roblox: [Pokemon Brick Bronze, Wikipedia mirror](https://en.wikipedia-on-ipfs.org/wiki/Pok%C3%A9mon_Brick_Bronze) and [Kotaku](https://kotaku.com/inside-the-fan-made-pokemon-mmo-played-by-tens-of-thous-1797638071) (2D sprites in a 3D Roblox world; still a nostalgia touchstone). Their sprites were ripped from Nintendo games: the layout idea is fine to borrow, the art is not.
- Roblox APIs: [ViewportFrame](https://create.roblox.com/docs/reference/engine/classes/ViewportFrame) (Ambient, LightColor, ImageColor3, ImageTransparency; no shadows or post-processing), [GuiObject.ClipsDescendants](https://create.roblox.com/docs/reference/engine/classes/GuiObject) (rotation needs `ClipsDescendantsSupportsRotation`; no clipping by rounded corners), [UIGradient](https://create.roblox.com/docs/reference/engine/classes/UIGradient) (applies to the parent; blends with strokes), [CanvasGroup](https://create.roblox.com/docs/reference/engine/classes/CanvasGroup) (GroupColor3, GroupTransparency; texture memory cost; prefer static sizes), [Font enum](https://create.roblox.com/docs/reference/engine/enums/Font) (FredokaOne, Nunito, Arcade available; Gotham is removed and maps to Montserrat).
