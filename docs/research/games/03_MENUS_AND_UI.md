# Menus, HUD and battle screens: what the best games do, and a plan for ours

Researcher 3 of 3. Written 22 November 2026. Plain English, British spelling.

## How to read the labels

- **[V]** = verified from a source this session (link in the source list at the end).
- **[R]** = my reading from memory of the games, screenshots or general design knowledge. Not checked against a source today. Treat as a prompt to look at the game yourself, not as fact.
- We study layouts and patterns only. Nothing here says to copy any game's art, icons, fonts or words.

The web search tool gave thin results for several of the games you named (Loomian Legacy, Doodle World, Adopt Me, Pet Simulator 99, Stadium). Where a game's screen layout is described below without [V], it is from memory. Please play them on a phone for ten minutes each before we lock a layout.

---

## Summary (half a page)

Our screens are one flat dark panel with white text and plain coloured buttons. That is clean and it works, but nothing on it says "arcade". The good news is that the arcade look is mostly **outline, colour, shadow and movement**, and Roblox gives us all four in code: `UIStroke` (outlines, also on text), `UIGradient`, `UICorner`, `TweenService` [V, appearance-modifiers doc]. We do not need new art for 80 per cent of it.

The five ideas that matter most:

1. **Thick dark outline on every piece of text, and a darker "lip" under every button.** This one change makes flat panels look like a toy or an arcade cabinet. It is a change to `Kit.luau` only, so every screen gets it at once.
2. **Every press and every change moves and makes a sound.** Buttons squash on press (about 95 per cent scale, 80 to 120 ms [V, juice guides, treat as starting values]), panels pop in with a small overshoot, numbers count up, health bars drain with a trailing ghost bar. Roblox's own UX guide says to respond to every player action [V].
3. **Show the result of a choice before the player makes it** (type advantage on move buttons, odds before a purchase, parents' contribution before a breed). This is both good arcade feel and a policy need for us.
4. **Keep the bottom corners clear on a phone.** Roblox's default thumbstick and jump button sit in the bottom-left and bottom-right [V]. Our dialogue box, battle actions and any action button must be placed with that in mind, and extra buttons go beside the jump button, not on it [V].
5. **Reward moments are short and escalate by rarity.** A common creature gets a quick pop. A rare one gets a bigger frame, brighter flash and a held beat. Keep every reveal skippable and short [V, card-reveal article says long ones get tapped through].

Where custom art is truly needed: a title logo, a few badge shapes (rarity frame, type badge, star, rank letters), and a stage-select map. Everything else can be built from our Kit. Creature portraits already come from the planned `ViewportFrame` icon pipeline (brief section 12).

Two cautions. First, Persona 5's famous menus are bold but their own director said early builds were "impossible to read" until tuned [V]: style must never cost readability for a 9-year-old on a small phone. Second, the arcade look must not turn into pressure selling. Roblox's rules on fake urgency and paid random items apply to our shop wording (see `docs/research/market/01_MONETISATION.md`).

---

## 1. Battle screens

### What the best games do

**Pokemon mainline (Sword/Shield, Scarlet/Violet style) [R].** Two creature platforms in 3D. Enemy info card top-left or top-right, own info card bottom-right, each with name, level, a health bar that changes colour (green, yellow, red) and a status icon. A message box at the bottom with a four-button move list that shows move type and PP. Our current layout is the same idea. The weak spot of this model is that it is mostly text and the camera is quiet. Scarlet/Violet is described as menu-heavy in the Sword/Shield style [V, search summary].

**Legends: Arceus** added an in-game type chart [V, Automaton]. I could not verify whether either game shows effectiveness on the move button before you choose [V: not found]. Player complaints about "I cannot remember the chart" are the reason to show it on the button ourselves.

**Pokemon Stadium and the console 3D games [R].** Cinematic camera cuts on every attack, the camera swings to a "hero" angle on a strong hit. For us: a short camera nudge or zoom on a super-effective hit is cheap (Camera CFrame tween) and feels big.

**Cassette Beasts [V].** Replaces numeric type multipliers with a colour-coded chemistry chart; the developer says you can use it "by just knowing where the green, red and yellow cells are". The chart can be opened any time from the inventory. Reviewers found it handy but said players would not open it mid-fight, and PC Gamer liked that the UI shows symbols when you consider a target. The battle commands are Fight, Switch, Item. A UI designer's critique argues icons need text labels next to them to be quick to read [V, Medium redesign post, opinion].

**Doodle World [V].** Four battle options: Fight, Switch, Bag, Run. Capturing uses the Bag. Menus open with Tab on PC, and the Party menu shows the creature's info and a Customize tab. I found no source describing the visual layout [V: not found].

**Loomian Legacy [V, partly].** Its "LoomiWatch" has a Battle tab showing ability, ability text and moves, with move stats on hover, and a Training tab with base stats. I could not verify the in-battle layout [V: not found]. Note that "stats on hover" does not work on a phone: we need tap-and-hold or a small info button.

**Temtem [V].** Patch notes show the team added rival HP and stamina percentages plus the rival's name and avatar in PvP, and made selected battle buttons more distinct. A reviewer criticised that you cannot reorder your squad freely in the free-to-play spin-off. Lesson: show the rival clearly, make selection state obvious, and let players reorder the team.

**Coromon [V].** Reviewers praise monster design and the "potential" stat-spending system but call the menus tedious: several XP messages to dismiss one by one, no skip for animations. Lesson: **batch the end-of-battle messages into one result screen and always allow skip.**

**Persona 5 [V, partly].** Bold angular shapes, one dominant colour (red) with other colours reserved for HP and SP, ransom-note style type inspired by punk album covers, action options arranged around the selected character like manga speech bubbles. The series director said these menus were "impossible to read" at first and needed many tweaks, and that flashy menus are annoying to build [V]. Lesson: **one signature colour plus black and white, and reserve other colours for meaning (health, type).**

**Arcade fighters [R, general knowledge; the search confirmed only the ghost bar idea].**
- A versus intro: both fighters slide in from opposite sides, names in large type, a short "VS" slam. Under two seconds.
- Health bar with a trailing "ghost" bar: the bar drops at once, a lighter strip behind it drains a moment later, so you see how big the hit was. A UI guide describes the three values (current, ghost, display) [V].
- Hit flash: the target flashes white for a few frames and shakes.
- Big callouts: "PERFECT", "K.O.", "SUPER EFFECTIVE" as a large outlined word that scales in with overshoot, holds, then fades.
- Result screen: grade letter, bonus lines that count up one at a time, a "continue" prompt.

### Do / avoid (battle)

| Do | Avoid |
| --- | --- |
| Colour each move button by its type, with a type badge and the move's power in plain text | Four identical blue buttons (what we have now) |
| Show "Strong / Weak / Normal" on the move button once the player has met the target type | Making the player open a chart mid-fight |
| Ghost health bar, white hit flash, small shake on the target | Bars that jump straight to the new value (jarring, per the UI guide [V]) |
| Big outlined callout words for super effective, miss, critical, with scale-in and fade | Long text lines for every event |
| Put the four actions Fight, Items, Switch, Run (and Lasso) in a clear, always-in-the-same-place cluster | Moving buttons between screens |
| Batch end-of-battle messages into one screen, with a skip | Click-to-dismiss chains (Coromon complaint [V]) |
| Show the rival's name and level, and both teams' remaining count as small dots | Hiding how many creatures are left |
| One signature colour for our frame, other colours only for meaning | Rainbow everything |

---

## 2. Collection, team and breeding screens

### What the best games do

**Creature cards [R].** The standard card has a large portrait on a coloured backdrop, name, level, type badge(s), a rarity frame or border colour, and a small stat summary. Collection screens use a grid of these cards, not rows of text, so the player can scan by colour. Gacha games use frame colour and star count for rarity: rainbow and gold boxes for the top tiers on a pull summary [V, Gundam UCE guide], and the background burst changes with rarity [V, Rive card-pack design example].

**Team of six [R].** Almost all creature games show the team as a 2 by 3 grid or a vertical strip of six cards, with the lead creature larger or marked. Pokemon-style team screens show each member's health bar on the card, so the team is checked at a glance. For a phone, 6 across in landscape is too narrow; use 3 by 2 with large portraits.

**Stat screens [R, plus Coromon note [V]].** Horizontal stat bars with the number at the end, the bar filled by share of a maximum, the bar coloured by tier. For us: our stat ceilings are in config, so bars can show "current out of this species' ceiling". Coromon's potential system shows that players enjoy a separate "how much more can this grow" bar [V].

**Breeding [V, Temtem only].** Temtem's update made the breeding screen show both parents' fertility and a preview of the offspring's fertility [V]. Reviewers still found the system frustrating because of the cost and luck [V]. Lesson: show what you are risking and what you might get before the player pays.

**Our signature is part-based breeding [project brief].** No other game shows this, so the breeding screen is where we should spend our art effort: two parent models side by side, with each body part labelled and tinted by which parent it can come from, and the odds for each part as a bar ("Head: 60 per cent parent A, 40 per cent parent B"). I found no other game doing this, which is an opening, not a source.

**Eggs and timers [R].** An egg is a card with a silhouette or egg icon, a circular or bar timer, "Hatches in 12:30", and a pulse when ready. A big "Hatch" button appears only when ready. Pet-collecting Roblox games show hatch timers on a card in the pet list; I could not verify layouts for Adopt Me or Pet Simulator 99 [V: not found]. The Pet Simulator 99 rarity ladder (Normal, Golden, Rainbow, Huge, Titanic, Gargantuan) and a rarity-specific hatch animation are confirmed [V, search summaries].

### Do / avoid (collection and breeding)

| Do | Avoid |
| --- | --- |
| A grid of portrait cards: rarity-colour frame, type badge, level, small health or hatch bar | Rows of text (what we have now) |
| Rarity as colour plus shape plus words, so colour-blind players can still tell (frame thickness or star count) | Colour alone |
| Team as a fixed 3 by 2 slot grid with empty slots drawn dashed and labelled "Empty" | Hiding the six-slot goal. Showing it feeds the "fill your team" pull |
| Tap a card for a detail sheet; tap-and-hold for quick actions | Hover-only information (phones have no hover) |
| Breeding: two parents on the left and right, a big result window in the middle, a part-by-part odds strip, the coin cost on the button | Burying odds in text |
| Egg card with a ring or bar timer, a pulse when ready | A text-only "ready in 3 minutes" line |
| Let players reorder the team by tapping a card then tapping a slot | Fixed order (Temtem Showdown complaint [V]) |

---

## 3. Shops, daily tasks, quests and reward pop-ups

### What the best games do

- **Roblox's UX guide [V]:** give feedback on every action, show purchase sound effects, grey out unusable buttons and use red for prices the player cannot afford, keep the screen to what is relevant, and use bright colours for critical text with muted shades for the rest.
- **Top Roblox simulators and pet games [R, from memory, not verified today]:** a column of round icon buttons down one side (Shop, Pets, Quests, Rewards, Settings), each with a small red dot when something is waiting; a coin counter that pops and shakes when it changes; an item grid in the shop with a big icon, name, price on the button, and a "new" or "best value" ribbon; a daily reward row of seven boxes with the current day lit up; quest lists with a progress bar per task and a single "Claim" button.
- **Paid random items [V, Roblox rule via our own market research].** Every outcome and its real percentage must be shown before purchase, summing to 100 per cent (see `docs/research/market/01_MONETISATION.md`). In our game only earned coins buy random outcomes, but the shop should still show odds for anything random. Fake urgency, always-on sales and countdowns that restart are against Roblox's guidance [V, same file].
- **Reward reveals [V, search summaries]:** rarity is hinted before the reveal (colour of the capsule or light), the animation scales with the tier (more stars, brighter flash for rarer), and a short sequence is better because players skip long ones. A Medium article on card reveals was blocked for me, so its six-step list is **not verified**.

### Do / avoid (shop and rewards)

| Do | Avoid |
| --- | --- |
| Shop as a grid of cards: big icon, name, price on the button, owned count | One long text list (what we have now) |
| Price button greyed and red-edged when the player cannot afford it | Silent no-op presses |
| A single toast queue (top centre, one at a time, slides in, holds 2 seconds) for "You got 20 coins", "Task done" | Notices that overwrite each other |
| Coins that fly from the reward to the coin counter, then the counter pops | Number changing silently |
| Daily tasks: progress bar per task, "Claim" lights up when done, a "Claim all" button | Text-only "3/5" |
| Red dot on the Creatures and Tasks buttons when something can be claimed | Making players hunt |
| Real percentages for anything random, summing to 100 per cent | Hidden odds, fake "only 2 left" counters |

---

## 4. HUD and phone layout

### Verified from Roblox docs

- Default mobile controls take part of the bottom-left and bottom-right corners; Roblox says to avoid important info or virtual buttons there [V, cross-platform doc].
- Place custom buttons relative to the jump button so they stay in easy reach; the doc even shows code that finds the jump button in PlayerGui and puts a button 20 pixels to its left on touch devices [V].
- Show contextual buttons only when they matter (for example a prompt near a door), so the screen shows only vital information during play [V].
- On small screens, move less important buttons into a collapsible menu [V, adaptive design doc].
- `ScreenGui.ScreenInsets` has the options CoreUISafeInsets (the default, which keeps content clear of the top bar and cutouts, recommended for interactive UI), DeviceSafeInsets, TopbarSafeInsets and None [V]. Which option is best for notches is my inference, not stated by the doc.
- Roblox's UX doc gives no pixel numbers for touch targets [V: it says so]. General standards: Apple 44 by 44 points, Google 48 by 48 dp with about 8 dp spacing [V, search summaries]. Our Kit already uses 44 pixel tall buttons. For kids aged 9 to 16 playing in motion, I would go for **48 pixels minimum and 56 to 64 for primary buttons** (this is my recommendation, not a verified rule).
- A DevForum report says buttons placed in the thumbstick zone can end up under it and be unclickable, with a workaround of a higher DisplayOrder, which is unofficial [V, search summary].

### Things to check in our code (my reading of the Kit, please test in Studio)

- `Kit.screen` sets `IgnoreGuiInset = true` and does not set `ScreenInsets`. Our quest tracker sits at (10, 10) top-left. Roblox's own menu and chat icons live at the top-left. The tracker may sit under them on some devices. **Check this on a phone-sized view.**
- The battle action panel is at 66 to 96 per cent of screen height, full width. The default thumbstick and jump button are probably not shown in battle if we hide controls, but the bottom corners are still the places where a thumb rests, so big buttons there are good as long as no important info is covered.
- The dialogue box is 80 per cent wide and sits near the bottom. It is fine, but its Next button must not sit where the jump button is.

### Do / avoid (HUD)

| Do | Avoid |
| --- | --- |
| Top-right: coin counter and a compact row of round icon buttons (Creatures, Tasks, Shop) | One wide panel with a text button |
| Top-left: quest tracker as a small collapsible chip. Tap to expand | A permanent three-line panel (it covers the world and may sit under Roblox's menu) |
| Bottom-left and bottom-right clear in the overworld | Any permanent HUD in the thumb zones |
| One contextual action button near the jump button (for example "Lasso" when a wild creature is in range) | Always-on buttons |
| Safe-area aware parent frame for all HUD | Absolute pixel positions from the very edge |
| Test at 640 by 360 (small), 812 by 375 (typical) and a tablet | Designing only on a desktop preview |

---

## 5. Capture mini-game (our timing lasso)

### What other games do

- **Pokemon GO throws [V, several guides; the numbers disagree].** A fixed outer ring and a ring that shrinks and resets. Where the ring is when you release decides the grade: Nice, Great, Excellent. The ring colour shows how hard the catch is (green easy, red hard). One guide splits it Nice 100 to 70 per cent of ring size, Great 70 to 30 per cent, Excellent under 30 per cent [V, one source]. Catch bonuses are quoted as 1.15, 1.5, 1.85 by some sources and 1.3, 1.7, 2.0 by another [V: sources disagree, not reliable]. A curveball shows stars or sparkles around the ball [V]. The pattern to take: **one clear target, one clear moving thing, colour for difficulty, a named grade for the result.**
- **Fishing and rhythm mini-games [R].** A bar with a safe zone and a marker; the zone shrinks with difficulty; a perfect hit has a narrower inner zone; hits flash and a word appears (Perfect, Good, Miss); a miss shakes the bar. Rhythm games add a streak counter and a pulse on the beat.
- **Slow motion and zoom [R].** A short slow-down and camera push on the throw, then a hit-stop on the result, make a catch feel weighty. Our lasso is server-judged for timing, so any slow motion must be purely visual on the client and must not change the server's clock.

### Do / avoid (capture)

| Do | Avoid |
| --- | --- |
| Two zones: a wide "good" zone and a narrow bright "perfect" zone in the middle | One zone with no sense of how well you did |
| Zone colour by wild creature difficulty (green, yellow, red) | Same bar every time |
| Marker with a glow and a trail, bar pulses faster as the marker nears the zone | A silent, plain marker |
| A large grade word after the tap (PERFECT, GREAT, MISS) with sound and a different colour for each | Text-only result in the message line |
| Visual-only slow motion and a lasso throw animation | Letting the client decide the result. The server judges timing (hard rule 1) |
| A miss that still looks fun (bar shake, "Almost!") | A red flash and silence |
| Tell the player the catch odds are shown honestly: the grade changes a bonus, state it in the UI | Hidden bonuses |

---

## 6. Arcade menu language: what is cheap in Roblox, what needs art

| Arcade ingredient | What it looks like | Cost in Roblox | Needs custom art? |
| --- | --- | --- | --- |
| Big chunky type | Fredoka-style rounded heavy font, very large titles | Free: `Font` and `TextScaled` (we already use FredokaOne). Other built-in heavy fonts exist [R] | No |
| Thick outline on text | Dark 3 to 4 px stroke around every word | `UIStroke` with `ApplyStrokeMode = Contextual` [V]. Avoid tweening stroke thickness on text, it can flicker [V] | No |
| Outline on panels | Dark 3 to 5 px border, round joins | `UIStroke` with `ApplyStrokeMode = Border`, `LineJoinMode` Round [V] | No |
| Drop shadow | A darker copy of the panel offset 4 px down and right | A second `Frame` behind, or a text label copy behind the text | No |
| Button "lip" (3D look) | Darker strip under the button, which squashes when pressed | Two frames: a dark base and a bright top, tween the top down on press | No |
| Bright gradients | Light top to deeper bottom on buttons and panels | `UIGradient` with a `ColorSequence`, `Rotation = 90` [V]. Radial and conical types need the "Upgraded UIGradients" beta [V], so avoid for now | No |
| Pill shapes | Fully rounded buttons and bars | `UICorner` with scale 0.5 or more [V] | No |
| Tilted panels | Panels or titles rotated 2 to 4 degrees | `Rotation` property on a frame | No (text inside rotates too; keep small angles) |
| Angled or slanted cuts (Persona look) | Parallelogram panels | Not possible with `UICorner`. Needs image slices or `UIGradient` tricks | **Yes** (small shapes) |
| Bouncy tweens | Panels pop in with overshoot, buttons squash | `TweenService`, `Enum.EasingStyle.Back` or `Elastic` [R] | No |
| Sound on every press | Click, confirm, back, error, coin | A few `Sound` instances played from the Kit's button helper [R] | Needs sound files |
| Number count-up | Coins and XP tick up | A small function tweening a number value and updating text each frame [R] | No |
| Stars, rank letters, medals | S, A, B, C letters in big outlined circles; 1 to 3 stars | Letters are just text with a stroke. Stars need a star image or a `Frame` rotated 45 degrees [R] | Optional: one star image |
| "Press start" title screen | Logo, blinking prompt, background loop | Prompt and background are free. A logo needs art | **Logo: yes** |
| Stage-select map | Tappable map with route nodes and badges | Nodes as buttons on a frame is free. A map picture needs art | **Map picture: yes** |
| Rarity frames | Frame colour, corner gems, shine | Frame colour with `UIStroke` is free. Ornate frames need 9-slice images (`ImageLabel` with `SliceCenter`, which Roblox supports [V]) | Optional |
| Type badges | Small circle or shield with a symbol | Coloured pill with the type's name is free. Symbols need icons | Optional (names work to start) |
| Screen shake, hit flash | Whole frame shakes, target flashes white | Tween `Position` and `BackgroundColor3` or `ImageColor3` | No |
| Particles on UI | Sparkles, confetti | Hard in plain UI. Cheap trick: spawn 10 to 20 small frames and tween them out | No, but fiddly |

### Do / avoid (arcade look)

| Do | Avoid |
| --- | --- |
| Pick one signature colour and keep the same outline thickness everywhere (consistency is the top feedback rule [V, juice guide]) | Ten colours and mixed outline sizes |
| Use motion for events (reward, hit, level up) and keep idle screens calm | Everything bouncing all the time. Roblox's UX doc says use motion and bright colours sparingly [V] |
| Keep text 18 px or more on phones and high contrast (heavy fonts, thin ones are discouraged by Roblox [V]) | Thin or fancy fonts, small grey text |
| Make a "reduce motion" switch, because shake and flashes can be a problem for some players [R] | Strobing flashes |
| Same sound for same action everywhere | Different click sounds on different screens |

---

# A screen-by-screen plan for our game

Wireframes are for phone landscape, about 812 by 375 pixels. `[B]` means a button. `( )` means a portrait. `====` is a bar. Safe margins: keep 16 px from the edges, and 70 to 90 px of the bottom corners clear in the overworld.

## 0. Kit upgrades first (applies to every screen)

Add to `src/client/UI/Kit.luau` (no new art needed):

- `Kit.outlineText(label)`: adds a `UIStroke` (3 px, dark navy, Contextual) to any text.
- `Kit.panel` gets a 3 px dark border `UIStroke`, a light top-to-bottom `UIGradient`, and an optional "shadow" frame.
- `Kit.button` becomes a two-layer button (dark base, bright face) with `UIGradient`, a squash tween on `InputBegan`, a spring-back on release, and a click `Sound`.
- `Kit.popIn(frame)` and `Kit.popOut(frame)`: scale 0.85 to 1 with `Back` easing, with a fade.
- `Kit.countUp(label, from, to, seconds)`.
- `Kit.callout(text, colour)`: a big outlined word that scales in, holds, fades.
- `Kit.badge(parent, text, colour)`: a pill for type and rarity.
- Palette: add a signature accent, a dark outline colour, a "shine" colour, and rarity colours. Keep the type colours in config data, not in the Kit.

Built with Kit: all of it. Needs images: nothing, except the sound files.

## 1. Top-right bar (coins and Creatures button)

```
                                   [coin] 1,250   [Creatures] [Tasks] [Shop]
                                    round icon buttons, 48 px, red dot = new
```

Arcade touches: coin counter in a pill with an outlined number that pops and tints gold when it changes; round icon buttons with a lip and a red dot badge when something can be claimed.
Kit: yes, all of it. Images: a coin icon and three small icons would help. Until then use short words under a coloured circle.

## 2. Quest tracker (top-left)

```
[!] Chapter 2: Reach Brindle   (tap to open)
    Catch 2 creatures  1/2 ===--
```

Arcade touches: collapsed chip showing the chapter name; a progress bar; the chip bounces briefly when the goal changes; a "NEW" tag. Move it clear of the Roblox menu icons (check in Studio).
Kit: yes. Images: none.

## 3. Dialogue box (bottom)

```
                  +--------------------------------------+
   (portrait)     | MENTOR                                |
   speaker        | The marsh is not safe after dark...   |
                  |                           [Next >]    |
                  +--------------------------------------+
```

Arcade touches: a big speaker portrait popping in at the left edge; speaker name in a coloured tag sitting on the top edge of the box (tilted 2 degrees); typewriter text with a blip sound per few letters; tap anywhere to speed up or advance; a bobbing arrow instead of "Next". Keep the Next area away from the bottom-right jump button zone: put the tap area across the whole box.
Kit: yes (typewriter and tags). Images: speaker portraits (could be a `ViewportFrame` of the creature or a tamer head).

## 4. Starter pick

```
                     CHOOSE YOUR FIRST FRIEND
   +----------+      +----------+      +----------+
   |  ( A )   |      |  ( B )   |      |  ( C )   |
   | Fire-ish |      | Leaf-ish |      | Wave-ish |
   | ======== |      | ======== |      | ======== |
   +----------+      +----------+      +----------+
        [  PICK  ]          selected card scales up, others dim
```

Arcade touches: three tall cards with type-coloured backdrops and rarity-style frames; the selected one scales up with a glow and a turn animation of the model; a "Pick" button that is large and bright; a confirm step ("Pick Sprig?") so a tap is not final by accident.
Kit: yes with `ViewportFrame` portraits. Images: none required.

## 5. Battle screen

```
 +------------------------------------------------------------+
 |  ENEMY NAME  Lv5  [type]             o o o o o o (team dots)|
 |  ============== (health, ghost bar behind)                   |
 |                                       (enemy model in 3D)   |
 |                                                             |
 |  (your creature in 3D)         +- callout: SUPER EFFECTIVE! |
 |                                                             |
 |  YOU NAME Lv6 [type]  12/20                                 |
 |  ============== health   ---- tempo                         |
 +-------------------------------------------------------------+
 |  message line: "Sprig used Vine Whip!"                      |
 | [Move 1 type-colour ] [Move 2 ]        [Lasso] [Items]      |
 | [Move 3           ] [Move 4 ]          [Swap ] [Run  ]      |
 +-------------------------------------------------------------+
```

Arcade touches:
- Versus intro: two name banners slide in from the sides, a short "VS" slam, under 2 seconds, skippable.
- Info cards: outlined name, level, type badge, coloured health bar with a ghost trail, a white hit flash and a small shake on hit.
- Move buttons coloured by type, showing type badge, power, and a small arrow or word for strong, weak or normal (once the type is known).
- Callouts: "SUPER EFFECTIVE", "NOT VERY EFFECTIVE", "CRITICAL", "MISS" as big outlined words.
- Floating damage numbers rising from the target.
- Visual-only camera nudge on strong hits.
- Giant boss: see section 10.
Kit: yes for all of it. Bar ghost trail, flash, shake and callouts are tweens. Images: type badge symbols and a "VS" graphic are nice to have, but text works to start.
Note: the server decides every result, so every one of these effects plays only after the server's turn result arrives.

## 6. Result box ("You won")

```
                +--------------------------------+
                |         ★   ★   ☆              |
                |           VICTORY!             |
                |   Coins       +  120  (counts) |
                |   XP          +   45  (counts) |
                |   Sprig  Lv 6 -> 7  LEVEL UP!  |
                |            [ Continue ]        |
                +--------------------------------+
```

Arcade touches: pops in with overshoot; stars fill one by one with a ding each (stars for speed or health left, only if we choose to add that: a small design decision to propose); rows count up and the next row starts when the last one ends; a level-up row with a flash; a rank letter (S to C) in a big circle for giant fights and later ranked play; tap to skip counting. One screen only, with no chain of dismiss buttons.
Kit: yes. Images: one star image is nice; a text star works to start.
Reward note: any coin reward here is earned play, never staked (hard rule 3).

## 7. Creatures list (with breed, team, release, daily tasks)

Today this is one long text list. Split into tabs.

```
 +-------------------------------------------------------------+
 | [Team] [All] [Eggs] [Breed] [Tasks]                  [ X ]  |
 +-------------------------------------------------------------+
 | TEAM (3 x 2)                      | DETAILS                  |
 | (A) (B) (C)    (frame colour =    |  big model/portrait      |
 | (D) (E) ( )     rarity)           |  name, type badges       |
 |                                   |  HP ATK DEF SPD bars     |
 |                                   |  [Team][Breed][Release]  |
 +-------------------------------------------------------------+
```

Arcade touches: portrait cards with rarity frame colours and a small level tag; empty team slots drawn dashed with "Empty"; a detail sheet on tap; stat bars that fill when the sheet opens; the Release button is small, grey, and needs a second confirm (hold to confirm works well on phones); tabs that slide.
Kit: yes, with `ViewportFrame` icons from the icon pipeline. Images: frames can be `UIStroke` colours first, and 9-slice images later.
Breed tab:

```
   +--------+        +---------------------+        +--------+
   | PARENT |   +    |  RESULT WINDOW      |   +    | PARENT |
   |   A    |        |  Head  A 60% B 40%  |        |   B    |
   +--------+        |  Body  A 50% B 50%  |        +--------+
                     |  Tail  ...          |
                     +---------------------+
                       Cost: 80 coins   [ BREED ]
```

The part-by-part odds strip is our signature. Egg after breeding: a card with a ring timer and a pulse when ready.
Daily tasks tab: a list with a progress bar and a Claim button per task, a "Claim all" button, a red dot on the tab when something is ready.

## 8. Shop

```
 +-------------------------------------------------------------+
 | SHOP                         [coin] 1,250              [ X ]|
 | [Lassos] [Bait] [Care] [Breeding]                           |
 | +--------+ +--------+ +--------+ +--------+                  |
 | | (icon) | | (icon) | | (icon) | | (icon) |                  |
 | | Lasso  | | Bait   | | Salve  | | Cure   |                  |
 | | own: 3 | | own: 0 | |        | |        |                  |
 | | [ 40c ]| | [ 25c ]| | [ 60c ]| | [ 30c ]|                  |
 | +--------+ +--------+ +--------+ +--------+                  |
 +-------------------------------------------------------------+
```

Arcade touches: a card grid with big icons; price on the button; the button is red-edged and greyed if the player cannot afford it (Roblox's own advice [V]); a purchase pop with a coin sound and the coin counter ticking down; owned count updates with a bounce. Plain, honest wording only: no fake timers or "only 1 left" (Roblox guidance [V, our market doc]). Anything random shows every outcome and its odds.
Kit: yes. Images: item icons are the main need (could be simple shapes or generated).

## 9. Lasso bar

```
         Wild Mossling  (zone colour = difficulty)
   |----------[====GOOD====[PERFECT]====GOOD====]--------|
                              ^ marker (glow + trail)
                       [ TAP! ]  (big, near right thumb)
```

Arcade touches: two zones (good and perfect); the marker glows and pulses faster near the zone; on tap, a freeze for a few frames, a big grade word (PERFECT / GREAT / MISS) with a colour and sound, then the lasso throw. A miss shakes the bar. Perfect shows stars. The server judges timing on its own clock; the visuals are only a display (hard rule 1). Any visual slow motion must not shift the real timing window.
Kit: yes. Images: none; a lasso rope graphic is optional.

## 10. Giant boss fight

Same battle layout, with:
- A wide boss banner at the top ("GIANT: Old Thornback") with a segmented health bar (one segment per phase) that breaks with a flash when a phase ends.
- A short warning flash and a "!" icon when the giant prepares a big attack.
- A bigger version of the versus intro, with the giant's name in the large font and a camera pull-back.
- A result screen with a rank letter and the badge reward ("BADGE EARNED") as a large pop-up with sparkles and a held beat.
Kit: yes (segmented bar is several frames). Images: badge artwork needs an image (a custom shape).

## 11. New screens worth adding (not on today's list)

- **Title / press-start screen** on first load: logo, blinking "Tap to start", a slow background orbit. Needs a logo image.
- **World map / stage select:** a simple map page with nodes for each biome, locked ones shown with a padlock and the badge needed. Doubles as the "chapter x of 11" promise from the market research (`02_STRUCTURE_AND_COMPETITORS.md`). Needs a map picture, or start with nodes on a plain coloured frame.
- **Reward toast queue** (top centre), and a **capture result card** (new creature, rarity frame, one-line "first of its kind caught!").

---

# Ranked top ten: biggest difference for the least work

1. **Outline and lip in the Kit.** Dark `UIStroke` on all text and panels, gradient faces, a darker lip under buttons. One file, every screen changes.
2. **Button juice and sound.** Squash on press, spring back, a click sound, and a `popIn` for every panel.
3. **Colour-coded move buttons with type badges and a strong/weak hint.** Fixes the "four identical blue buttons" and teaches the type chart as players play.
4. **Health bars with ghost trail, white hit flash and floating damage numbers**, plus big callouts (SUPER EFFECTIVE, MISS, CRITICAL).
5. **A single "Victory" result screen** with staged count-ups, a level-up row and a skip, replacing the plain box.
6. **Lasso grading: good and perfect zones, colour-coded difficulty, big PERFECT / GREAT / MISS word** with a freeze frame (visual only).
7. **Creature cards in a grid** with rarity-colour frames, type badges and stat bars, and a 3 by 2 team layout with dashed empty slots.
8. **HUD tidy-up for phones**: round icon buttons with red dots, collapsible quest chip, safe-area insets, bottom corners left clear, 48 px or larger touch targets.
9. **Shop as a card grid with affordability states, plus a reward toast queue and coin fly-to-counter.**
10. **Versus intro banner and a part-by-part breeding odds screen** (the second one is our signature, so it deserves the best-looking screen in the game).

Later (needs art): title logo, stage-select map, rarity frame images (9-slice), type symbols, star and badge images.

---

## What I could not verify

- Exact screen layouts of Loomian Legacy, Doodle World, Adopt Me, Pet Simulator 99, Blox Fruits and Brookhaven: the search returned guides, wikis and patch notes, not screens. Their layouts above are from memory and labelled [R].
- Pokemon Stadium camera work, and whether mainline Pokemon shows type effectiveness on the move button before choosing: searches found no source.
- Pokemon GO throw multipliers: sources disagree (1.15/1.5/1.85 and 1.3/1.7/2.0). Only the principle (shrinking ring, graded result) is solid.
- Roblox gives no official pixel size for touch targets [V]; the 44 and 48 figures are Apple and Google general guidance.
- How `ScreenInsets` and `IgnoreGuiInset = true` interact on notched phones: the doc does not say. Test in Studio.
- The card-reveal Medium article blocked automated fetching (HTTP 403); I used only search-summary lines from it.
- Press timings (95 per cent squash, 80 to 120 ms) come from non-authoritative blog guides, treat them as starting values to tune by feel.
- Persona 5's details come from search summaries of articles, not from Atlus's own talk.

---

## Sources

- Roblox: Position and size UI objects (cross-platform design): https://create.roblox.com/docs/ui/cross-platform-design
- Roblox: On-screen UI containers (ScreenInsets): https://create.roblox.com/docs/ui/on-screen-containers
- Roblox: UI appearance modifiers (UIStroke, UIGradient, UICorner): https://create.roblox.com/docs/ui/appearance-modifiers
- Roblox: UI and UX design: https://create.roblox.com/docs/production/game-design/ui-ux-design
- Roblox: Adaptive design guidelines: https://create.roblox.com/docs/production/publishing/adaptive-design
- Roblox: ScreenGui reference: https://create.roblox.com/docs/reference/engine/classes/ScreenGui
- DevForum, mobile buttons: https://devforum.roblox.com/t/the-correct-way-to-design-mobile-buttons/2494558
- DevForum, thumbstick covers UI: https://devforum.roblox.com/t/mobile-navigation-thumbstick-covers-important-game-uis/205611
- Cassette Beasts UI redesign (opinion): https://medium.com/@davy_delbeke/redesigning-cassette-beasts-ui-a1c49452ea59
- Cassette Beasts developer post on the type chart: https://cassettebeasts.com/?p=624
- Persona UI, Siliconera: https://www.siliconera.com/what-makes-the-ui-and-menus-in-persona-games-so-good/
- Persona director on flashy menus, PC Gamer: https://www.pcgamer.com/games/rpg/persona-series-director-says-atluss-flashy-menus-are-actually-really-annoying-to-design
- Persona typography and angular menus, GamesRadar and Kotaku: https://www.gamesradar.com/uk/in-persona-5-even-the-menus-are-cooler-than-you ; https://kotaku.com/-metaphor-refantazio-persona-5-menu-ui-hashino-1851667088
- Pokemon GO throws: https://www.imore.com/how-nail-excellent-throw-pokemon-go ; https://dexerto.com/pokemon/pokemon-go-catching-tips-how-to-make-nice-great-excellent-throws-1570004 ; https://esports.gg/guides/pokemon/how-to-get-the-best-catch-rate-in-pokemon-go
- Legends: Arceus in-game type chart: https://automaton-media.com/en/news/20220131-9111/
- Temtem breeding UI and battle UI patch notes: https://crema.gg/temtem/temtem-0-3-social-update/
- Temtem Showdown review (squad UI): https://mp1st.com/reviews/temtem-showdown-review-filler-free-creature-combat
- Coromon reviews: https://rpgsite.net/review/12864-coromon-review ; https://www.pocketgamer.com/coromon/review/
- Doodle World wiki, battle: https://doodle-world.fandom.com/wiki/Battle
- Loomian Legacy wiki, LoomiWatch: https://loomian-legacy.fandom.com/wiki/LoomiWatch
- Pet Simulator 99 (eggs, rarity): https://sportskeeda.com/roblox-news/pet-simulator-99-how-hatch-gargantuan-pet-winter-world
- Game health bars and ghost bars: https://www.abratabia.com/game-ui-design/health-bars-indicators.php
- UI feedback and juice: https://gamejuice.pages.dev/articles/ui-feedback-design ; https://eastondev.com/blog/en/posts/dev/20260521-game-feedback-feel/
- Gacha and card reveal design: https://medium.com/n3twork/choreographed-emotion-6-steps-to-a-great-card-reveal-ux-a6e6bb8487dd (blocked, search summary only) ; https://game8.co/games/gundam-uce/archives/580044 ; https://contra.com/p/q3MWgbOU-rive-pokemon-pocket-style-interactive-card-pack-opening
- Touch target guidance: https://support.google.com/accessibility/android/answer/7101858 ; https://web.dev/articles/accessible-tap-targets
- Our own research: `docs/research/market/01_MONETISATION.md`, `docs/research/market/02_STRUCTURE_AND_COMPETITORS.md`
