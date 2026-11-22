# How the Pokemon games look and present themselves, and what we can take

22 November 2026. Research for Ayrton. Nothing here is decided. We study patterns only: no creature, name, icon, font, layout or art is copied.

## How to read the tags

| Tag | Meaning |
| --- | --- |
| **S** | Sourced. Read this session, link in the Sources list. "S (search)" means only a search summary of the page was seen, because the page itself blocked us. |
| **S (06)** | From `06_POKEMON_SCREENS_SEEN.md`, where screenshots were opened and looked at directly. |
| **R** | Recall. From memory, not checked this session. Treat as a lead, not a fact. |

Bulbapedia, uxdesign.cc and the PokeCommunity analysis all refused automated fetches (HTTP 403). So the per-game screen details in section 1 lean on Recall more than we would like. Wikipedia, Serebii, Smogon and Game Developer pages did load.

## Summary (half a page)

Pokemon's screens are plain at heart. A creature on each side, a small card with name, level and a health bar, a text box, four choices. They feel good because of rules that repeat in every game:

1. **The creature is the biggest, brightest thing.** Menus sit at the edges (S (06)).
2. **Colour carries meaning.** Health goes green, yellow, red. Moves are coloured by type. Blue against red for the two sides.
3. **Every beat has a sound that teaches.** A cry on entry, a different hit sound by effectiveness, a beep when health is low, a fanfare on a level-up.
4. **Every attack is a staged moment:** announce, lunge, impact, health drains, a word if it was strong or weak.
5. **The weak point is speed.** Players complain loudly about unskippable animations, slow menus and slow boxes (S). Any arcade feel we add must be skippable and fast.

The arcade spin-offs add noise and ceremony: an announcer, camera cuts, mashing buttons, a slow pack opening, a score. Most of that is cheap to imitate in spirit with tweens, camera moves, particles and short sounds.

For creature design, the stated rules are: memorable beats cool, one odd detail helps, simple shapes, few colours, big expressive faces, and a back view that matters (S). A part-assembled creature can follow nearly all of them if **colour is assigned by slot per creature** and **one signature part carries the silhouette**.

The most useful single change for our battle screen is the one already in `03`: colour the move buttons by type and print "strong" or "weak" on them. Next come an over-the-shoulder camera, a proper hit-feedback bundle, a **fast battle** option from day one, and a lasso that wobbles and pauses like a Poke Ball.

## 1. The battle screen across eras

### Era by era

| Era | Where creatures stand | Cards and menu | Feel | Tag |
| --- | --- | --- | --- | --- |
| **Game Boy, Red/Blue/Yellow** | Side view. Your creature drawn from behind, lower left. Foe front-on, upper right. | Foe card top-left, your card lower right with an experience bar. Text box across the bottom holds the command list: Fight, Item, Pokemon, Run. Four moves with PP. | Text-driven. Hit feedback is a screen flash or shake. | Layout R. Screens, four moves, item, switch, flee (no fleeing from trainers): S (Wikipedia). |
| **Game Boy Colour, Gold/Silver** | Same plan, now in colour. | Same cards. Animated hit effects. | Colour makes the health bar and type effects readable. | R |
| **GBA, Ruby/Sapphire/Emerald** | Same plan with animated front sprites. | Doubles added. Cards a little larger. | R | R |
| **DS, Diamond/Pearl and Black/White** | Gen 5 sprites fully animated. The camera moves to highlight parts of the battle. | Choices move to the touch screen. Gen 5 shows weather and time on the bottom screen while you choose. L plus a move shows its power, accuracy and text. | First 3D-leaning feel in a handheld. Triple battles in Gen 5. | Animated sprites and camera: S (Wikipedia B/W). Weather, time and L: S (search). Touch buttons coloured by type in Gen 4: R. |
| **3DS, X/Y, Sun/Moon** | Fully 3D models. | Gen 7 labels moves "effective", "super effective" or "not very effective" in the move menu, but only after you have fought that species once. | Easier for new players; the label does not tell 2x from 4x. | S (search: Escapist, Business Insider, Smogon forum). |
| **Switch, Sword/Shield** | Fixed third-person camera, low behind your creature (S (06)). Dynamax makes a creature giant for three turns. | Cards and four moves. Options include Battle Effects on or off. | Visuals criticised as underwhelming; Dynamax and raids are the show. | Camera and Dynamax: S (Wikipedia). Effects toggle: S (search, Game8). |
| **Switch, Scarlet/Violet** | Camera behind your creature. Terastal gives a crystal look. | Same cards. Auto-battle sends a creature to fight in the field. | Performance problems at launch. Players still ask for "skip battle animations". | S (Wikipedia; Nintendo Life readers). |
| **Switch, Legends Arceus** | Catch in the field; fight from the field. | Turn order shown in a list (R). Dropped extra text boxes and filler animation. | Quicker feel. Faint and damage animations still plain. | Dropped boxes: S (search, PokeCommunity). Turn list: R. |
| **Switch 2, Legends Z-A** | Real-time battles in a city. | Moves on face buttons. **Cooldowns replace PP.** | Praised for pace; some reviews say it is chaotic and hard to follow. | S (search: reviews). |

### Specific questions

| Question | Answer | Tag |
| --- | --- | --- |
| Health bar colours | More than half: green. One fifth to half: yellow. Under one fifth: red, with a warning beep in Gens I to IV. Gen V swapped the beep for a music change. | S (search, Bulbapedia) |
| Where the cards sit | Foe card top-left, your card lower right, in the classic plan. Newer games keep the idea. | R, partly S (06) |
| What a card shows | Name, level, health bar, status icon. Your card adds numbers and an experience bar. | R |
| Move buttons | Name, type, uses left (PP). Sun/Moon fill each bar with its type colour and add a line such as "Super effective". | S (06); PP and type: R |
| Text box | Messages type out letter by letter and wait for a button press. Text speed has slow, normal and fast. | Speed options: S (search). Behaviour: R |
| Speed-ups | Text speed, Battle Effects off (Sword/Shield), skip animations (requested for Scarlet/Violet). One writer says turning animation off roughly halves battle time. | S (search: Game8, Escapist, Nintendo Life) |
| Entry | Trainer throws a ball, light burst, creature appears with its cry. | R |
| Hit feedback | A flash on the target, a small shake, the health bar draining step by step, a sound that depends on how effective the hit was. | R |
| Faint | Creature slides down or fades, a drop sound, then the experience bar fills. | R |
| Level up | Experience bar fills, a jingle, a stats box, possibly a new move prompt. Legends Arceus removed the pause for level-ups and move learning in field fights. | Arceus: S (Wikipedia). Rest: R |
| Evolution | White silhouette flashes and morphs, music, a cancel button. | R |
| Catch | Ball is thrown, opens, creature turns to light and enters the ball, ball drops and shakes. Four shake checks, all must pass. A **critical capture** gives a metal sound, a brief pause in mid-air, and a single shake. | Shakes and critical: S (Serebii). Light and drop: R |

### What the battle screen does, why it works, our version

| What it does | Why it works | Our version |
| --- | --- | --- |
| Foe card top-left, own card opposite, text box bottom | The eye reads top-left to bottom-right: threat, then you, then what to do | Same plan. Cards with an outline, a ghost health bar, a type badge. |
| Four choices in one corner | Thumb reaches them; always in the same place | Keep our one-level menu (moves plus lasso, swap, items, run). It saves a tap compared with Pokemon's two levels. |
| Colour bands on health | Danger is seen without reading | Use the same thresholds and add a low-health pulse. |
| Effectiveness shown on the move | Players learn the type chart from the buttons (S (06)) | Show it from the first fight on our own species. No "fought it once" gate: our audience is young. |
| Over-the-shoulder camera | Your creature feels big and yours; free depth (S (06)) | Camera position and field of view only. |
| Options to cut animation | Players complained about slow battles in Sword/Shield, Scarlet/Violet and Arceus reviews | Ship a Fast Battle toggle and tap-to-skip on day one. |

## 2. The arcade and stadium presentation

| Game | What it does to feel loud and fast | Tag |
| --- | --- | --- |
| **Stadium 1 and 2** | Full 3D battles. A commentator calls actions with voice lines; reviewers praised the colour, critics found lines repeat, and players could switch him off. The camera "is always moving" to the active creature. Pick three of six. Mini-games (Kids Club), rental creatures. | S (Wikipedia, Nintendo Life search) |
| **Colosseum** | Doubles. Attack animations brief but praised. Models reused from Stadium. Colosseum list in a theme park; each with its own rules. | S (Wikipedia) |
| **Battle Revolution** | Colosseums, online play, pick three from six. Blue team against red. Numbered picks. Announcer with a catchphrase. Reused models with new textures. | S (06 and search) |
| **Pokken Tournament** | Two phases: a field phase where creatures roam, and a duel phase. A Synergy Gauge builds to Mega form. Support creatures. Made for arcades; the arcade cabinet used a console-style pad. | S (Wikipedia) |
| **Ga-Ole** | Arcade 2 against 2. You cheer your creature on by pressing buttons shown on screen. | S (search) |
| **Mezastar** | You place a metal-style tag on a lane to send a creature. Slide forward to choose the attacker. Mash buttons to power the attack, which fills a Catch Gauge. After the battle you throw a ball, with timing, for a chance to receive the creature as a new tag. Tags have star grades (five star, six "Superstar" shiny designs). Two stations share a screen for co-op. | S (TimeZone guide, search) |
| **Rumble** | Toy-like creatures, simple brawling, crowds of enemies. | R |
| **TCG Pocket** | Pack tear follows your finger. Five cards per pack. Rarer cards add shine, a 3D effect, or "immersive" scenes. A cracking sound and light shine for big pulls. Reviewers praised the sound of the pack. A pack every 12 hours. | S (Wikipedia, search) |
| **Unite** | Ten-minute matches (five-minute quick mode). No visible score; the game announces the lead at five, three, two and one minute left. No type chart. | S (Wikipedia) |
| **Masters EX** | Gacha mobile game, three-on-three, trainer and creature pairs ("sync pairs") with six roles. Sync move presentation not found. | S (Wikipedia, thin); moves: R |
| **GO** | Flick the ball up the screen. Curve it for a bonus. Raids at gyms. | Flick: S (Wikipedia). Ring and curve: S (search, Let's Go and Game8) |
| **Champions** | Reviewers: clean, uncluttered UI; one arena that wears thin; fewer models on screen than Pokken. | S (search) |

### What is cheap to imitate in spirit

| Idea | Why it is loud | Our version | Cost |
| --- | --- | --- | --- |
| An announcer | Names every moment; kids love it | Not a voice. A banner that slams in: "SUPER EFFECTIVE!", "LAST CREATURE!", "ROUND 2". Voice later if sound budget exists. | Code |
| Camera that is always moving | Makes a static 3D scene feel directed | Small camera drifts, a push-in on strong hits, a cut to the attacker for a second. | Code |
| Pick three of six, blue against red | Fast to read, fair to watch | Use for the challenge board and PvP team select. | Code |
| Button mashing | Gives the player something to do during an attack | **Not for battles** (the server decides turns). Fine for a lasso or a hatch. | Code |
| Tag with star grade | A grade is a status symbol | Rarity frames and star count on creature cards. | Code and some art |
| Pack opening with tiers of flair | Ceremony makes a random outcome exciting | Hatch or breed reveal: shake, crack, light, part-by-part build-up. Small, plain pulls get a quick pop; rare ones the full show. Keep it skippable. | Code and sound |
| Hidden score with announcements | Less stress, more drama | For timed modes only. | Code |
| Arena with a crowd | The room reacts | Flat cut-out crowd silhouettes that bounce on hits. A particle burst for confetti. | Light art |

## 3. Menus

| Menu | How it changed | What players said | Our version | Tag |
| --- | --- | --- | --- | --- |
| **Start menu** | A short text list in the early games, then icons beside every word. Scarlet/Violet shows a short icon list on the right with the team down the left and the world still visible; selected row is bright yellow. Z-A has big flat buttons, team as a row of six tiles, and a "next reward" panel. | Nothing in the sources on the start menu itself. | Short icon list. Put "next goal" on the menu. | Early lists: R. Newer: S (06). |
| **Party** | Early: a list of six rows. Let's Go: six rounded cards in a 3 by 2 grid. | Players asked for a faster way to reorder the team; a single-button switch in Arceus was preferred. | 3 by 2 cards, tap two to swap. | S (06; Nintendo Life readers) |
| **Summary** | Pages for info, stats, moves, ribbons. | R | Two pages max: stats and moves. Show the parts. | R |
| **Bag** | Pockets by item type. | Readers wanted shoulder-button jumping through pockets. | Tabs across the top, big touch targets. | S (Nintendo Life readers) for readers; pockets R |
| **Boxes** | PC grid in 30-slot boxes. Let's Go uses one big box with up to 1,000 creatures, based on GO. | Scarlet/Violet's box was called "terrible"; BDSP's pick-up-and-go flow was preferred. Players said Boxes and shops "take an age" to load. | Grid with tap-to-select, multi-select, sort, search. Fast load: create rows once and reuse them. | S (search: VideoGamer; Nintendo Life readers; Bulbapedia) |
| **Pokedex** | A list with a seen and caught state. Completing it needed trading. One reader wanted search. | Search request. | Silhouette until caught; set bar; reward at set completion. | Completing needs trade: S (Wikipedia). Rest R |
| **Map and fly** | Town map with fast travel. | R | Map with tap-to-travel unlocked per town. | R |
| **Trainer card, badges** | A card showing badges earned. | R | Badges as shiny medals that light up on the card. | R |
| **Shop** | List with item, price, quantity. Clothing shops: slow previews, wrong colour names. | Previews often fail to load. | Card grid; instant preview. | S (Nintendo Life readers) |
| **Options** | Text speed, battle effects, battle style (Set or Shift), controls. Players ask to remap controls. | Wanted Set style back; asked for remapping. | Fast Battle, text speed, sound, left-hand layout. | S (search) |

### What changed with touch and the Switch

- **Touch screens (DS):** buttons got big and colourful; everything doable by pad could also be done with the stylus (S (search, StrategyWiki)). Our phone audience is touch-only, so this is our starting point.
- **Switch:** more icons, a persistent world behind menus, quick-access wheels. But slow loading in boxes and shops and a messy button map were the loudest complaints (S, Nintendo Life readers).
- **Praised:** Legends Arceus's single-button switch and no pause on level-ups (S); Champions' uncluttered battle UI (S (search)).

## 4. Creature design language

### What the designers said

| Rule | Source | Tag |
| --- | --- | --- |
| **Memorable beats cool.** If a design is too cool, add something uncool; if too stern, add a cheerful touch. Oshawott's three freckles were kept because they make the face memorable, over requests to remove them. | Nintendo Life, Siliconera | S |
| **Monsters that fight on your side.** Early work asked for allies, not enemies. | 2000 interview | S |
| **Design for evolution.** Some creatures were made because their evolved form would look good, others so players would want to see the earlier form. | 2000 interview | S |
| **Some motifs should be non-obvious.** Not everything is an animal. | 2000 interview | S |
| **Draw each creature from several angles.** The back sprite matters: it makes you feel close to a creature you want to protect. | Wikipedia, 2000 interview | S |
| **Each creature has its own cry** (Tajiri's idea). | 2000 interview | S |
| **One pixel changes the impression.** Small details matter. | 2000 interview | S |
| **Silhouette:** many Gen 1 outlines look alike; later designs use one exaggerated feature (a mouth, a hammer) to stand out. | Smogon | S |
| **Few colours:** Gen 1 palettes are one main colour with a lighter or darker accent. Johto sprites used at most two colours each. Darker back marks and light bellies repeat on about 40 creatures. | Game Developer, Smogon | S |
| **Eyes use a small set of shapes** (angry, cute dot, plain round, wide, mystical) that signal personality. Later generations lean on rounder, simpler eyes. | Game Developer Gen 1 and Gen 6 | S |
| **Type shows through colour.** A creature's type and its main sprite colours are closely linked (a 2018 paper). Fairy became tied to pink, and older pink creatures were retyped. | Liapis paper (search); Game Developer Gen 6 | S |
| **Big heads and soft shapes read as cute to children** and make plush toys easy. Fletchling has fewer feather details than Pidgey. | Smogon | S |
| **Typical starter pattern** (three stages, one per type) | R | R |
| **Shiny and regional forms** vary a design by palette (shiny) or by body and type (regional). | R | R |
| **Typical proportions:** big head (about a third of body height), short limbs, small body. | R | R |

### Which rules a part-assembled creature can follow

| Rule | Can parts follow it? | How |
| --- | --- | --- |
| Silhouette | Yes, with care | One **signature part** per species (head crest, tail, ears, front limbs) is the part that defines the outline. When it crosses to a child, the child keeps the shape. |
| Few colours | Yes, easily | Each species has two or three colour slots (main, accent, belly). Parts hold slot names, not fixed colours. The child takes its own palette. |
| Simple eyes | Yes | Eyes are on the head part, one of four to six shared eye styles. |
| One-line concept | Yes | Every species has one line in its data file ("a lizard with a lantern tail"). If the line cannot be said, the design is too busy. |
| Evolution family resemblance | Yes | Same palette slots and same signature part, bigger and with one new ornament. |
| Type reads at a glance | Yes | The main colour slot leans toward the type colour. |
| Shiny / variant | Cheap | An alternate palette per species. |
| Back view | Yes, needs care | Tail and rear must be good, because we place the camera behind the player's creature. |

## 5. World and camera look across eras

| Era | Look | Suits a phone and Roblox low-poly? | Tag |
| --- | --- | --- | --- |
| Game Boy to GBA | Top-down tiles | Fast and clear, but not 3D. Not our look. | R |
| DS | 2.5D: 3D world with flat sprites | Costly to mimic in Roblox. | R |
| 3DS | Chibi 3D, fixed camera | Fits: simple, small. | R |
| Switch, Let's Go and BDSP | Diorama: small chunky characters in a small tidy world. BDSP's chibi style split fans; some called it toy-like, others praised the diorama feel. | **Best fit.** Chunky, cheap, readable at phone size. | S (search) |
| Switch, Sword/Shield and later | Fixed third-person camera; the Wild Area has free camera. | Camera behind the creature is cheap. A big open world is costly. | S (Wikipedia) |
| Z-A | One city, real-time, Paris-like. Critics called the visuals "flat" and the setting restrictive. | A warning: tidy is not enough, you need colour and light. | S (Wikipedia) |

**Why the diorama suits us:** small areas, flat colours, fixed or gentle camera, few draw calls. Our route, town, giant structure already matches it. The strong light and bright colour matter more than detail.

## 6. Sound and feedback

| Moment | What it does | What it teaches | Our version | Tag |
| --- | --- | --- | --- | --- |
| **Cry** | Each creature has its own cry (Tajiri's idea) | Who is on stage; gives a sense of life | Short synth-style or recorded squeak per species, pitch-shifted by size. | S (2000 interview) |
| **Low-health beep** | Beep when health below one fifth in Gens I to IV; Gen V swapped it for a music change | Danger: heal or switch now | A soft pulse sound and a red screen-edge vignette, with a Fast Battle option to quieten it. Players called the beep irritating (S (search)). | S (search) |
| **Super effective, not very effective, normal** | Three hit sounds of different weight | Teaches the type chart without words | Three hit sounds by tier plus a callout. | R |
| **Critical hit** | Extra sharp hit sound and flash | A lucky strike | Same. | R |
| **Capture shake** | One tick per shake | Tension | One tick per wobble, rising pitch. | R |
| **Critical capture** | Metal noise, pause mid-air, one shake | A rare lucky moment | Same pattern for a lucky lasso. | S (Serebii) |
| **Capture jingle** | Short fanfare after the last shake | Success and reward | Short jingle plus a name card. | R |
| **Level-up fanfare** | A short bright jingle | Progress | Same. | R |
| **Badge fanfare** | Long fanfare, a medal lights up | A chapter has ended | Longer fanfare, badge animation. | R |
| **Shiny sparkle sound** | A special sound on meeting a shiny creature; Scarlet/Violet dropped it | Rarity | Give rare creatures a special entrance sound and keep it. | S (search) |
| **Music** | Game Boy music used four sound channels | Mood | Original loops per biome; a battle loop that speeds up at low health. | S (Wikipedia, music); loop speed idea: ours |

## A Pokemon-informed battle screen for our game

Phone landscape, 874 by 402 points. Everything here is a display of server results. The server decides every action; the client sends only one choice a turn.

```
+--------------------------------------------------------------------------------+
| [FOE CARD]                                         scene: 3D, full screen       |
| Name  Lv5 [type]                                    foe creature (upper right,  |
| ======== health + ghost                             small, in the distance)     |
| o o o (foe team dots)                                                           |
|                                      [ callout: SUPER EFFECTIVE! ]              |
|  your creature, from behind                                                     |
|  (lower left, large)                                       [ YOUR CARD ]        |
|                                                          Name Lv6 [type] 12/20  |
|                                                          ========= health      |
|                                                          ---- xp bar            |
+-------------------+--------------------------------+---------------------------+
| message strip     | [Move 1 type colour, strong ^] | [LASSO] [ITEMS]           |
| "Sprig used       | [Move 2 type colour, weak  v]  | [SWAP ] [ RUN ]           |
|  Vine Whip!"      | [Move 3 ] [Move 4 ]            |                           |
+-------------------+--------------------------------+---------------------------+
 34% width           46% width                         20% width, 28% of height
```

Notes on the plan:

- The foe card is top-left, your card lower right, as in Pokemon. Both are outlined cards.
- The bottom band keeps everything within thumb reach. It is about 28% of the height (about 112 points).
- Each move button is tall enough for a thumb (at least 44 points) and filled with its type colour. A small arrow or word says strong or weak.
- The existing screen already shows the damage each move would do. Keep that number; add colour and the arrow.
- Leave the bottom-left corner free of other buttons if Roblox shows its thumbstick there on phone (see the HUD check in `03`).

### One full turn: sequence and timings

Times are in seconds from the player's tap. "Fast Battle" halves the pauses and skips camera moves.

| Time | Beat | Feedback |
| --- | --- | --- |
| 0.00 | Player taps a move | Button squashes down and springs back (0.1). Click sound. Menu slides down (0.2). Intent is sent. |
| 0.20 | Server result arrives | Both actions are in the result, in the server's turn order. Nothing plays before this. |
| 0.20 | **Action 1: announce** (0.4) | Message strip types out "Sprig used Vine Whip!" (0.25 s typing). Move name pops as a banner. |
| 0.60 | **Action 1: wind-up and lunge** (0.3) | Attacker steps back then lunges. Camera pushes in a little. |
| 0.90 | **Action 1: impact** | Hit stop of 0.06 s, white flash on target (0.1), shake (0.15), floating damage number rises. Hit sound depends on effectiveness tier. |
| 0.95 | Health drain (0.5) | Bar drops with a ghost trail behind. Colour shifts across green, yellow and red thresholds. |
| 1.05 | Callout (0.6) | "SUPER EFFECTIVE!" slams in, outlined, with a camera nudge. Skipped for normal hits. |
| 1.60 | Settle (0.2) | Camera returns; attacker steps back. |
| 1.80 | **Action 2** | Same beats, 1.6 s. |
| 3.40 | End-of-turn effects | Status damage or recovery (0.4 each). Skip if none. |
| 3.40 | Menu returns | Buttons pop up one after another (0.15). |
| **~3.4 total** | | Fast Battle: about 1.7. |

**If a creature faints (adds about 2.2 s):**

| Time | Beat | Feedback |
| --- | --- | --- |
| +0.0 | Faint | Creature tilts, drops and fades (0.8). A falling sound. Foe cry stops. |
| +0.8 | Experience | A bar fills with ticking sound (1.0). Number counts up. |
| +1.8 | Level up (if any) | Short fanfare, a pop-up with new stats (skippable). |
| +2.2 | Next creature or result screen | Entry beat below, or the Victory screen. |

**Entry (once at the start, about 1.8 s):** low camera behind your creature; VS banners slide in from the sides (0.5); each creature pops in with a squash and a cry (0.4 each); cards slide in; menu pops up. Tappable to skip.

**Low health:** below one fifth the bar turns red, pulses slowly, and a quiet beep or heartbeat plays at most once every two seconds. Fast Battle mutes it.

**Giant fights:** same beats with the giant on a raised, lit spot in a dark surround, with a longer entry (S (06) raids).

## A Pokemon-informed catch sequence for our lasso

The lasso is timing-based. The server judges the timing on its own clock. The client animates only what the server replies. **Capture rolls and odds touch the "needs approval" list in CLAUDE.md, so this section covers presentation only.**

| Beat | Time | What the player sees and hears | Where the information comes from |
| --- | --- | --- | --- |
| 1. Pick | 0.3 | Lasso tier chosen from a list; a rope-swish sound. | Client intent. |
| 2. Focus | 0.4 | Camera moves over your shoulder toward the wild creature. A ring appears around it. Colour shows how hard the catch is (green easy, red hard). | Server sends difficulty and ring speed. |
| 3. Ring | 1.0 to 2.0 | A ring shrinks toward the creature. A tick sound speeds up. A small target mark glows. | Client animation only. |
| 4. Throw | 0.1 | Player taps. Whoosh. | Client sends the tap. The server uses its own clock. |
| 5. Flight | 0.5 | Rope arcs and closes around the creature. | Replay of result. |
| 6. Grade | 0.4 | Word pops: **PERFECT**, GREAT, OK or MISS, matching the server's judgement. A fast ring spark on PERFECT. | Server result. |
| 7. Wrap | 0.4 | Creature squashes into a small bundle or token on the ground. | Server result. |
| 8. Wobble | up to 3 x 0.7 | The bundle rocks left, right, left. A tick per wobble, rising in pitch. A pause before the last. | **The server sends the number of wobbles**, so the client never guesses. |
| 9a. Caught | 1.5 | Stars burst. Jingle. A name card flips in with rarity frame and a "New!" tag if it is a first. Pokedex-style count ticks up. | Server result. |
| 9b. Broke free | 0.8 | Rope snaps, creature pops out, shakes its head. A "so close" line if it broke on the last wobble. | Server result. |
| Lucky catch (optional) | 0.8 | After the throw: a metal ping and a mid-air pause, then one wobble and caught. | Server flags it. This copies the pattern, not the maths: a critical capture in the games uses a metal sound, a mid-air pause and one shake (S, Serebii). |

Use the same pacing as Pokemon: **three small beats (wobbles) and then the answer.** Fast Battle shortens the wobbles to 0.4 each.

## Creature design rules for our parts

1. **One signature part per species.** One of head, tail or front limbs carries the silhouette. Every other part comes from a small shared set.
2. **Silhouette test.** Fill each design with black. If two species share an outline, change one signature part.
3. **Two or three colour slots per species:** main, accent, light belly. Parts store slot names, so a bred child recolours parts to its own palette.
4. **Main colour leans to type.** A fire-type species is warm; a water-type species is cool. Type shows at a glance.
5. **A small set of shared eye styles** (four to six): round dot, wide, sleepy, sharp. Eyes live on the head part.
6. **A one-line concept** in the species data. If it cannot be said in one line, remove detail.
7. **Big head, small body, short limbs.** Head about a third of the body height (Recall). Rounded shapes read as cute and friendly to the audience.
8. **Design the back.** Your creature is seen from behind in battle, so the tail and rear must be good.
9. **One quirky detail.** Add one deliberate odd feature for memory, such as freckles or a lopsided ear, as Sugimori kept Oshawott's freckles.
10. **Families keep the signature part and the palette.** Later stages scale up and add one ornament. A rare palette is the cheap way to make a shiny-style variant.

## Recommendations, ranked

| # | Recommendation | Effort | Code or art |
| --- | --- | --- | --- |
| 1 | **Type-coloured move buttons with a strong or weak arrow**, from the first fight. Fixes the existing screen where moves are plain. | Low | Code |
| 2 | **Fast Battle toggle and tap-to-skip** for every animation, from day one. The loudest Pokemon complaint is slow battles. | Low | Code |
| 3 | **Hit feedback bundle:** hit stop, white flash, shake, floating number, ghost health bar, effectiveness tiers of sound. | Low to medium (sounds need assets) | Code and sound |
| 4 | **Over-the-shoulder camera** with a short entry sequence and VS banners. | Low | Code |
| 5 | **Health card rules:** green, yellow, red thresholds, low-health pulse, outlined cards. | Low | Code |
| 6 | **Lasso presentation:** shrinking ring, graded word, wrap, server-sent wobble count, lucky-catch pause. | Medium | Code and sound |
| 7 | **Species palette slots and a signature part** in the data (rules 1 to 3). Costs little now and a lot later. | Low to medium | Data and art |
| 8 | **Result screen:** experience bar fill, level-up jingle, count-up rewards, one button on. | Medium | Code |
| 9 | **Hatch or breed reveal** with tiers of flair, part by part, skippable. Plain pulls get a quick pop. | Medium | Code, sound, some art |
| 10 | **Team screen as a 3 by 2 card grid** over a blurred world, tap two to swap. | Low | Code |
| 11 | **Menu "next goal" panel** that shows the next reward (from Z-A). | Low | Code |
| 12 | **Banner announcer lines** ("SUPER EFFECTIVE", "LAST CREATURE") and a camera that keeps moving, for the challenge board and giants. | Medium | Code |
| 13 | **Box grid** with multi-select, sort and search; build rows once and reuse them for load speed. | Medium | Code |
| 14 | **Per-species cry** (short, pitch-shifted by size) and an entry sound for rare creatures. | Medium | Sound |
| 15 | **Rare-palette variant** for each species (shiny-style), as a data swap. | Low | Data and art |

## Sources

Read this session:

- Sugimori, design balance: https://www.nintendolife.com/news/2018/07/ken_sugimori_wants_pokemon_designs_to_be_as_memorable_as_possible
- Sugimori, balancing cool and cute: https://www.siliconera.com/pokmon-designer-on-balancing-cool-or-cute-pokmon-by-adding-uncool-or-uncute-features/
- Sugimori, 2000 interview: https://www.well-played.com.au/pokemon-artist-ken-sugimori-talks-design-in-newly-translated-2000-interview/
- Smogon, Pokemon art through the ages: https://www.smogon.com/articles/pokemon-art-through-ages
- Game Developer, Gen 1 designs: https://www.gamedeveloper.com/design/evolution-of-pokemon-designs-gen-1
- Game Developer, Gen 6 designs: https://www.gamedeveloper.com/design/generation-6-evolution-of-pokemon-designs
- Serebii, capturing: https://serebii.net/games/capture.shtml
- Wikipedia: Red, Blue and Yellow; Black and White; Sword and Shield; Scarlet and Violet; Legends Arceus; Legends Z-A; Stadium; Colosseum; Battle Revolution; Pokken Tournament; Pokemon Go; Unite; Masters EX; TCG Pocket (pages at en.wikipedia.org/wiki/ with the game name)
- Nintendo Life, Scarlet and Violet change list (reader comments): https://www.nintendolife.com/features/30-changes-wed-like-to-see-in-the-next-pokemon-scarlet-and-violet-update
- TimeZone, Mezastar guide: https://www.timezonegames.com/en-sg/blog/how-to-play-pokemon-mezastar-gameplay-basics-modes-and-tips/
- `docs/research/games/06_POKEMON_SCREENS_SEEN.md` (screens looked at directly)

Seen through search summaries only (the pages themselves were not read):

- Bulbapedia, Pokemon battle, HP, Storage System, Mezastar pages; PokeCommunity battle visuals analysis; uxdesign.cc articles; Escapist, Business Insider, Smogon forum on effectiveness labels; Game8 settings; StrategyWiki controls; VideoGamer on the box; Digital Trends, TTCD, GamesRadar, Serebii and GameWith on TCG Pocket; reviews of Z-A and Champions (Nintendo Life, WCCFTech, others); Liapis, "Recomposing the Pokemon Color Palette"; BDSP chibi discussion (Nintendo Life, GameSpot).

## Could not verify

- Exact screen positions of the cards and menu in every era, and what each card shows. Bulbapedia refused automated reads. Everything marked R.
- Whether Gen 4 and Gen 5 move buttons on the touch screen are coloured by type. The search found nothing. Sun and Moon bars coloured by type come from a looked-at screenshot (06).
- The sounds of super effective, not very effective and critical hits. No source found; marked R.
- Pokemon GO's throw ring, curve ball and raid lobby details, and the "Nice, Great, Excellent" values. Only the flick and the Let's Go circle were found.
- Sync move presentation in Masters EX, Rumble's presentation, and the Stadium and Battle Revolution crowd and camera cuts in detail.
- The full battle-turn timings in the games. The timings above are **our design**, not measurements.
- Whether Legends Z-A's cooldown display or lock-on is easy to read; reviews called the fights chaotic.
- Type-coloured sprite palettes and "head is a third of body" are from memory.
- Sugimori's three-stage starter rule and shiny rules: no source found this session.
