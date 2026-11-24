# What successful creature games do, and what to take from them

22 November 2026. A summary of three research reports, written for Ayrton. Nothing here is decided.

| Report | File |
| --- | --- |
| Structure: loops, gating, what brings players back | `01_STRUCTURE.md` |
| Art style: how the hits look, three directions for us | `02_ART_STYLE.md` |
| Menus, HUD and battle screens, with a screen-by-screen plan | `03_MENUS_AND_UI.md` |
| Pokemon: structure, presentation, and seven screens seen directly | `04_`, `05_`, `06_POKEMON_*.md` |

## How far to trust this

The three researchers could read web pages but could not look at pictures or play the games.

- **Solid:** Roblox's own documentation (performance budgets, what the UI tools can do, where the phone thumbstick sits), and things reviewers and players wrote.
- **Rough:** player counts. They come from search snippets that disagree; treat each as right to within a factor of two.
- **Weak:** how each game's screens and creatures actually look. Those parts are from the researchers' memory, and each report marks them. Doodle World and Tales of Tanorio returned almost nothing.

So the reports are good for direction, not for copying a layout. Before a screen is locked, someone should play the two or three closest games on a phone and check it.

## The five findings that matter most

1. **The arcade idea fits what we have.** "Arcade" is mostly presentation: loud colour, big type, thick outlines, hit flashes, screen shake, count-up result screens, a sound on every press. On Roblox that lives in menus, effects and lighting, which are cheap. It does not need a new way of modelling creatures, and it suits flat-colour low-poly creatures, which are also the only kind that still look right when parts from different species are mixed.
2. **The biggest Roblox crowds are in own, hatch, breed and trade games, not story games.** Story games with turn-based battles hold a few thousand players at best. Breeding and trading games hold far more. Our breeding is the part to lean on; the story is the way in.
3. **A lasso-catching game is the newest hit of this kind.** Catch And Tame has no battles at all: a free first lasso, and better lassos (bought with coins) catch rarer animals. That is close to ours, and the lasso ladder is the piece to copy.
4. **Players come back for something unfinished, more than for a daily reward.** An egg that hatches in 20 minutes, or one more catch to finish a set, pulls harder than a login gift.
5. **The commonest complaint in every game studied is pacing:** a slow first ten minutes, a grind in the middle, empty space. Our straight path (route, town, giant, gate) is safer than an open world, as long as the opening is quick.

## Recommended direction

**Look: "Toy Arcade".** Keep the brief's chunky, rounded, flat-colour creatures with no outline. Put the arcade into the presentation: bold framed menus, big type, bright stage lighting in battles, hit flash and shake, victory poses. It is the cheapest of the three directions and the safest for part-based breeding. The alternatives are a thick comic outline (more striking, but risky on mixed bodies) and a painted storybook look (most expensive, heavy on cheap phones, and at odds with colouring parts at run time). Palettes and starting light settings are in `02_ART_STYLE.md`.

**Structure: keep the path, add arcade pieces around it.**

| Take | From | Work |
| --- | --- | --- |
| A result screen after every battle: rank, rewards counting up, one button on | Arcade games, Pokemon TCG Pocket | Low |
| End each session on something unfinished (egg timer, "one more for the set") | Retention finding | Low |
| The lasso as a ladder: better lassos reach rarer creatures | Catch And Tame | Low to medium (we already have three tiers) |
| Breeding as the long game, with the child assembling part by part as a reveal | Dragon Quest Monsters, Dragon Adventures | Medium |
| A challenge board laid out as a stage-select map: 3 against 3, star ratings, streaks, quick rematch | Arcade pattern; matches the challenge board in approval pack 6 | Medium |
| Small, regular, numbered updates with a visible roadmap | Catch And Tame, Palworld | Ongoing |

**Menus: the first five changes, in order.** All can be built in code with what we have; none needs bought art.

1. Restyle the shared kit: dark outlines on text and panels, gradient faces, a darker lip under buttons. One file changes every screen.
2. Make every press feel alive: squash and spring, a click, panels that pop in.
3. Colour move buttons by type, with a strong or weak hint.
4. Battle feedback: health bars with a trailing ghost, a white hit flash, floating damage numbers, big callouts.
5. One Victory screen with staged count-ups.

After those: PERFECT / GREAT / MISS on the lasso (shown only; the server still judges), creature cards with rarity frames, a tidier phone HUD, a card-grid shop. Wireframes for every screen are in `03_MENUS_AND_UI.md`.

Art that would have to be made later: a title logo, the stage-select map, rarity frames, type symbols, stars and badges.

## Pokemon, looked at closely

Added later on 22 November, after Ayrton said "Look at pokemon games". Three more files: `04_POKEMON_STRUCTURE.md`, `05_POKEMON_PRESENTATION.md`, and `06_POKEMON_SCREENS_SEEN.md` (seven real screens, opened and looked at one by one).

Trust: the gym leader levels and catch rules come from pages the researchers read. The timings of the first half hour, route sizes and most screen layouts are from memory, and each file marks them. Bulbapedia blocked the researchers. The seven screens in file 06 were seen directly.

**The Pokemon skeleton.** A guide gives a starter from three. The rival picks the one that beats it and fights at once. A short first route, a small town with a healer and a shop, a longer second route with more trainers, then the first gym: a few trainers, a simple puzzle, a leader with two or three creatures. The reward is a badge, a new move and the next road. Each later badge repeats this over one and a half to three hours, with the leader's best creature about four to five levels higher each time, and a rival or villain scene every two or three towns.

**Our chapter 1 against it.**

| | |
| --- | --- |
| Matches | Starter from three, the rival's counter-pick, town services, a longer second route, an optional lair, a first gate team of three, a locked road on |
| Differs on purpose | The lasso lesson in the first four minutes, an egg by minute twelve, the first badge in under an hour, the rival as the gate, a hard level cap |
| Worth changing | No move as a badge reward. No trainers or small puzzle on the approach to the gate. Only two rival fights in the chapter. No rest stop on the long second route. No table of what the shop unlocks with each badge |

One point the researcher raised does not hold: our level cap rises ten per badge against Pokemon's four to five, but we have eleven badges to reach level 100 where Pokemon has eight to reach about fifty, so the pace per badge is ours by design.

**What to take for the screens** (from the seven seen and the presentation report):

1. Colour each move button by its type and print "strong" or "weak" on it. Players learn the type chart from the buttons.
2. Put the battle camera low behind the player's creature. It costs only a camera position and makes your creature feel big and yours.
3. A fast-battle switch and tap to skip from day one. Slow battles are the loudest complaint about Pokemon in what the researchers read.
4. One hit, one bundle of feedback: a tiny freeze, a white flash, a shake, a floating number, a health bar with a trailing ghost, and a sound that differs for strong, normal and weak hits.
5. The team as six rounded cards in a three by two grid, over a blurred view of the world.
6. The menu shows the next goal and the next reward every time it opens.
7. Bring six, pick three, see the other side's six first, blue against red: the layout for the challenge board and PvP.
8. Giants staged on a raised, lit spot in a dark place, with your creature small in front.

**Rules for our creatures**, so that mixed parts still look designed: one signature part per species that carries the outline; no two species share an outline when filled with black; two or three colour slots per species, so a bred child recolours to its own palette; the main colour leans to the type's colour; a small set of shared eye styles; a big head and short limbs; the back designed as carefully as the front, because the camera sits behind; one odd, memorable detail each.

A full turn should take about three and a half seconds, and under two in fast mode. That is our own target, not a measurement from Pokemon.

## Things to check or decide

- **Check:** the quest tracker in the top-left may sit under Roblox's own menu buttons on a phone (our screens ignore the top inset).
- **Needs your approval before building:** anything that touches saving or rewards, such as away-from-game timers, seasons and the challenge board's prizes.
- **Rules that still apply:** nothing copied from another game (structure only); no fake urgency in the shop; anything random bought with Robux shows its odds.
- **Your call:** the look (Toy Arcade or one of the other two), and whether the menu restyle starts now.
