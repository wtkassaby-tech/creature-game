# Turn-based battles, catching and PvP that work on phones

16 November 2026

Status: research, nothing decided

## Summary

- **Remove luck, then replace it.** Temtem has no misses, no critical hits and no damage roll; a resource (stamina) and hidden simultaneous choices supply the tension instead. Reviewers and players are split on it, so the brief's "small variance, no misses" default is a sound middle path, with zero variance in ranked.
- **A balanced ten-type chart exists that fits the brief.** Section 3 gives a full chart where every type beats two and loses to two, no pair beats each other, no two types share the same targets or the same counters, and the three launch types form a clean triangle (Leaf > Water > Sand > Leaf).
- **Speed controls are expected.** Coromon added 1.5x and 2x battle speed after launch; Pokémon Masters EX ships auto mode, a faster battle speed and "skip animations". Slow battles are the standing complaint about the genre (Nexomon: "battles end up feeling slower than ever").
- **Ranked norms to copy:** scale every creature to one level (Temtem scales to the cap with perfect hidden stats), a per-turn clock plus a reserve bank (Temtem 30 s + 3 min; Pokémon VGC 45 s + 7 min + 20 min game cap), seasons whose ruleset rotates, and cosmetic rewards (Loomian Legacy).
- **Low population is the real PvP risk.** Marvel Snap fills thin queues with bots. For a 16+ soft launch, live queues should be backed by clearly labelled saved-team opponents, and live ranked should be concentrated into scheduled windows.
- **Catching by skill is unusual.** Pokémon GO, Legends Arceus and Palworld all still roll a chance that skill only nudges. Fisch shows that a pure hold-and-track mini-game with gear stats works on Roblox at very large scale. A deterministic lasso is original and legal to keep on coins only.
- **Could not verify directly:** every page fetch failed in this session (the network allowlist blocked all hosts tried: wiki.gg, fandom.com, crema.gg, cassettebeasts.com, wikipedia.org, create.roblox.com). All external facts below are therefore "snippet" confidence. Loomian Legacy and Doodle World ranked details (timers, disconnect rules) and all Tales of Tanorio details were not found at all.

Confidence labels: **sourced** (page opened: none this session), **snippet** (search result text only), **inference** (my reasoning).

## 1. How turn-based battles are presented and paced

| Game | Format | Pacing and convenience features | Complaints | Confidence and source |
| --- | --- | --- | --- | --- |
| Temtem (PC, console) | 2v2, stamina instead of move counts | Every move costs stamina; overspending ("overexert") costs HP and a turn; a creature can Rest | "Heavily contested": some like the lack of luck, others find it clunky | snippet: https://www.pcgamer.com/temtem-review/ , https://tvtropes.org/pmwiki/pmwiki.php/YMMV/Temtem |
| Coromon (PC, Switch, mobile) | 1v1 | Settings to run the game and battles at 1.5x or 2x (added April 2023); strong difficulty options; "a lot of convenience features and settings for mobile" | "Sometimes tedious"; no auto-battle found | snippet: https://coromon.wiki.gg/wiki/Build_Notes , https://www.148apps.com/coromon/review |
| Pokémon Masters EX (mobile) | 3v3, real-time gauge, not strict turns | AUTO button top right; Accelerated Auto, Super Fast battle speed, Skip Battle Animations; co-op forced to x1.5 | None found | snippet: https://pokemonmasters-game.com/en-US/announcements/Update_3100_1W_1 , https://gamertweak.com/how-to-skip-battles-in-pokemon-masters/amp/ |
| Monster Sanctuary | 3v3, player picks the order of own actions | Combo counter raises damage for each later action in the turn, resets each turn | "Slow-paced strategic combat"; "intuitive and antiquated" | snippet: https://turnbasedlovers.com/review/monster-sanctuary-2/ , https://en.wikipedia.org/wiki/Monster_Sanctuary |
| Nexomon: Extinction | 1v1, stamina | Trainers rescale to the player | "Battles end up feeling slower than ever"; grind | snippet: https://www.nintendolife.com/reviews/nintendo-switch/nexomon_extinction |
| Cassette Beasts | 2v2 | Type match-ups create status effects, not damage multipliers | Chart is harder to learn than a multiplier chart (inference) | snippet: https://cassettebeasts.com/?p=624 |
| Monster Hunter Stories 2 | 1v1 with rider | Power/Speed/Technical triangle decides "head-to-head" clashes; enemies have readable habits | Not searched further | snippet: https://www.nintendolife.com/guides/monster-hunter-stories-2-battle-guide-how-to-win-battles |
| Loomian Legacy (Roblox) | 1v1 and 2v2, 17 types | Ranked queue across all Battle Colosseum servers | Grinding is "very slow" (forum); players ask for auto-battle | snippet: https://loomian-legacy.fandom.com/wiki/Battle_Colosseum , https://loomian-legacy.fandom.com/f/p/4400000000000129084 |
| Doodle World (Roblox) | 1v1 | Ranked exists with some creatures banned | Details not found | snippet: https://doodle-world.fandom.com/wiki/User_blog:SkribbledPhantom0/Doodle_World:_PvP_Reviews |
| Tales of Tanorio (Roblox) | Turn-based RPG, released 25 October 2022, still updated September 2026 | Nothing found on battle UI or PvP | Not verified | snippet: https://www.rotrends.com/game/4048852641/Tales-Of-Tanorio |

What this means (inference):

- No source gave a measured battle length in seconds. The targets in the recommendations are my own, derived from turn counts: a neutral hit should take about a third of an equal creature's health, so a knock-out takes 2 to 4 turns.
- The two things players ask for most are speed (a multiplier and animation skip) and a way to avoid trivial fights. Both are cheap to build and should be in from the first playable.
- Roblox is mostly a phone platform: about 80% of sessions were on mobile in late 2025, though other sources say 60 to 72% (snippet: https://explodingtopics.com/blog/roblox-stats , https://rowatcher.com/news/mobile-vs-desktop-on-roblox-who-s-playing-what-in-2026). Design the battle screen for landscape thumbs first.
- Touch targets: Apple asks for at least 44 x 44 points and Material Design 48 x 48 dp, roughly a 9 mm fingertip (snippet: https://www.designsystemscollective.com/a-designers-field-guide-to-wcag-ios-and-android-rules-31ba5d01d46a). Battle buttons should be well above that.

## 2. Type chart design in other games

| Game | Types | Multipliers | Structure | Confidence and source |
| --- | --- | --- | --- | --- |
| Temtem | 12 | 2x and 0.5x; two types on the defender multiply | Uneven: Neutral is weak only to Mental | snippet: https://temtem.wiki.gg/wiki/Temtem_types |
| Coromon | 7 creature types plus 6 move-only types (Magic, Foul, Heavy, Air, Poison, Cut) | Standard; matching the user's type gives a bonus, which move-only types can never earn | Small core chart, extra depth through moves | snippet: https://coromon.wiki.gg/wiki/Types , https://www.thegamer.com/coromon-type-matchup-strengths-weaknesses-chart/ |
| Loomian Legacy | 17 | Modifiers multiply across two types | Large, uneven, close to the Pokémon model | snippet: https://loomian-legacy.fandom.com/wiki/Type |
| Cassette Beasts | 14 (count from memory, unverified) | None: match-ups apply buffs, debuffs or change the target's type | "You can competently use the system by just knowing where the green, red and yellow cells are" | snippet: https://cassettebeasts.com/?p=624 |

Lessons (inference):

- None of the four uses a perfectly even chart. An even chart ("each type beats two, loses to two") is easier to teach and cannot produce a type with no weaknesses, but it is flat: balance then has to come from stats and moves. That suits a game where parts and breeding already carry the depth.
- Coromon's idea maps directly onto the brief: the torso sets the creature's type, and other parts bring moves of other types. That gives coverage without dual-typed creatures, so the defender's multiplier is always one lookup. Keep creatures single-typed.
- Cassette Beasts shows the alternative (reactions instead of multipliers). It is original but much harder to read on a phone. Not recommended for launch.

## 3. Proposed ten-type chart

Built by exhaustive search over thematically sensible match-ups (script in the session scratchpad, 10,859 valid charts found), then picked for the fewest thematic stretches. Verified properties:

- every type is strong against exactly two types and weak against exactly two;
- no two types are strong against each other;
- no two types share the same pair of targets, or the same pair of counters;
- the launch types form a triangle: Leaf > Water > Sand > Leaf;
- seven of the nine later types have a counter from an earlier biome. The exceptions are Sand (its counters, Water and Storm, come later) and Frost (Fire and Arcane come later).

| Type (biome) | Strong against | Why | Weak against |
| --- | --- | --- | --- |
| Leaf (1) | Water, Crystal | Roots drink water; roots split stone | Sand, Fire |
| Sand (2) | Leaf, Toxic | Dunes bury and dry out greenery; sand buries and filters sludge | Water, Storm |
| Water (3) | Sand, Fire | Washes sand away; douses flame | Leaf, Toxic |
| Toxic (4) | Water, Arcane | Pollutes water; corrupts magic | Sand, Frost |
| Frost (5) | Toxic, Crystal | Cold halts rot and slows venom; freeze-thaw cracks crystal | Fire, Arcane |
| Crystal (6) | Storm, Cosmic | Crystal does not conduct and stands in a gale; prisms split starlight | Leaf, Frost |
| Fire (7) | Leaf, Frost | Burns plants; melts ice | Water, Cosmic |
| Storm (8) | Sand, Cosmic | Gales scatter dunes; clouds blot out the stars | Crystal, Arcane |
| Arcane (9) | Frost, Storm | Wards thaw ice (the one stretch); magic commands the weather | Toxic, Cosmic |
| Cosmic (10) | Fire, Arcane | No air in the void, so flames die; the stars are older than magic | Crystal, Storm |

Full grid, attacker in rows, defender in columns (+ strong, - weak, blank neutral):

| Atk \ Def | Leaf | Sand | Water | Toxic | Frost | Crystal | Fire | Storm | Arcane | Cosmic |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Leaf | | - | + | | | + | - | | | |
| Sand | + | | - | + | | | | - | | |
| Water | - | + | | - | | | + | | | |
| Toxic | | - | + | | - | | | | + | |
| Frost | | | | + | | + | - | | - | |
| Crystal | - | | | | - | | | + | | + |
| Fire | + | | - | | + | | | | | - |
| Storm | | + | | | | - | | | - | + |
| Arcane | | | | - | + | | | + | | - |
| Cosmic | | | | | | + | + | - | + | |

Rules that go with it (all inference, all [Default]):

- Strong = x1.5 damage. Weak = x0.67 (an attack against a type that beats the move's type). Neutral = x1. Milder than the genre's 2x and 0.5x, so a bad match-up is a disadvantage and not an automatic loss; this matters when a new player only owns three creatures.
- Same type against same type is neutral. No immunities.
- A move of the creature's own (torso) type gets x1.2. Smaller than Pokémon's 1.5 (snippet: https://bulbapedia.bulbagarden.net/w/index.php?diff=3292537) because off-type moves from parts are the interesting choice.
- The Hollow's creatures have no type of their own in the chart; they use the ten.
- Known gap: "Storm beats Water", which players of other games expect, is not in this chart, because Water already has two clear counters (Leaf and Toxic). If playtesters find that jarring, the search has charts with Storm > Water at the cost of one more stretch.
- Frostline has no earlier-biome counter. Give Frostline's shop or quest line a Fire-type move part, or accept a neutral biome as a deliberate difficulty step.

## 4. Low-randomness battle design

- **Temtem:** "RNG does not exist in battle, except for taming"; no accuracy or evasion checks; no critical hits; status effects always apply. The early design slogan was "NO HAX" (snippet: https://docs.google.com/spreadsheets/d/12vuI6FkvZP4u7UI11aX3EWeChFbTHSMQcLPDkdku2QY/edit , https://www.pcgamer.com/temtem-review/ , https://www.smogon.com/forums/goto/post?id=8118384).
- **What Temtem uses instead:** the stamina budget (strong moves cost more; overspending hurts you), 2v2 targeting, and both players choosing at the same time, so the uncertainty is the opponent's choice and not a dice roll (snippet: https://www.thegamer.com/temtem-battles-take-pokemon-to-the-next-level/).
- **The counter-argument,** from Crema's own Reddit AMA thread: without rolls there are no low rolls, but also no high rolls, so a losing position cannot be rescued (snippet: https://lr.eu.psf.lt/r/NintendoSwitch/comments/x6gpe7/hi_were_crema_developers_of_the_online/in8t5s6/?context=3).
- **Pokémon for comparison:** each hit rolls 85 to 100% damage, critical hits are x1.5 at about 1 in 24, and many moves can miss (snippet: https://bulbapedia.bulbagarden.net/w/index.php?diff=3292537 , https://www.pixelpokedex.com/guides/battle-mechanics/damage-formula).
- **Telegraphing as a replacement for luck:** Slay the Spire's intent icons turn each fight into "a fully informed puzzle" and were the change that "finally made the game come together"; Into the Breach shows every enemy attack before it lands (snippet: https://saschb2b.github.io/game-mechanics/concepts/enemy-intent-telegraph , https://gamedeveloper.com/game-platforms/road-to-the-igf-subset-games-i-into-the-breach-i-). A caution from the same source: a telegraph is decorative if the player can kill the enemy before it fires.

Sources of tension that are not luck (inference): simultaneous hidden choices (attack or switch), a visible resource to manage, visible turn order, limited switches, and the opponent's unseen bench and move sets.

## 5. Boss design

- Raid data from the Pokémon series is in `research/SCAFFOLD_STRUCTURE.md`: bosses are scripted, one example has HP x35 against four players, a shield at 75% HP, and fixed actions at HP and time thresholds; 73% of events are a boss each player can catch once only. That matches the brief's giants closely.
- Slay the Spire and Into the Breach (section 4) add the missing piece: show the boss's next action so the fight is a puzzle of preparation, which is also what DECISIONS.md asks of consumables ("prepare before a giant instead of retrying again and again").
- Monster Hunter Stories 2 gives each monster a habitual attack style that changes when it is enraged, so reading the phase tells the player which answer to pick (snippet: https://segmentnext.com/monster-hunter-stories-2-attack-types-and-weaknesses).

## 6. Catching as a skill mini-game

| Game | What the player does | Is the result still a roll? | Confidence and source |
| --- | --- | --- | --- |
| Pokémon GO | Throw into a shrinking ring; smaller ring = bigger bonus | Yes. Community estimates: Nice 1.15 to 1.3x, Great 1.5 to 1.7x, Excellent 1.85 to 2x, curveball 1.7x on a hidden base chance; a throw outside the ring gets 1x | snippet: https://pogo.gamepress.gg/node/14516 , https://esports.gg/guides/pokemon/how-to-get-the-best-catch-rate-in-pokemon-go |
| Pokémon Legends: Arceus | Sneak up and hit the creature's back while it is unaware | Yes; back strikes and status raise the chance | snippet: https://www.serebii.net/legendsarceus/capture.shtml |
| Palworld | Lower HP, apply status, throw from behind, use a better sphere | Yes; the shown chance rises with each shake. Players report frustration at low success on high-level targets even at low HP | snippet: https://game8.co/games/Palworld/archives/439683 , https://palworldcompanion.com/mechanics/capture-chance |
| Fisch (Roblox) | Hold to move a bar right, release to move it left, keep it on a moving fish until a progress bar fills | No roll in the reel: rod stats change it instead. Control widens the bar, Resilience slows the fish. A "perfect catch" (never leaving the fish) pays a bonus | snippet: https://www.sportskeeda.com/roblox-news/what-control-fisch , https://esports.gg/guides/roblox/what-does-resilience-do-in-fisch/ |

Findings:

- Every creature game checked keeps a dice roll and lets skill adjust it. A lasso whose outcome is decided only by the player's timing would be distinctive, and it keeps the catch outside "paid random item" territory as the brief intends (inference).
- Fisch's stat design is the model for lasso tiers: a better lasso should make the same mini-game easier (wider zone, slower marker), not raise a hidden chance (inference from the Fisch sources).
- Lag: no source gave a Roblox-specific tolerance figure. General practice is for the server to judge an input against the state the client saw (lag compensation), and to keep the cue and the judging clock in step on the client (snippet: https://docs.unity3d.com/Packages/com.unity.netcode@1.7/manual/server-rewind.html , https://wireframe.raspberrypi.com/articles/latency-what-it-is-and-how-to-minimise-it).
- `Player:GetNetworkPing()` is reported to return latency in seconds, to be poorly documented (one-way or round trip is disputed) and sometimes to under-report (snippet: https://devforum.roblox.com/t/playergetnetworkping-lacks-documentation/1544599). Do not use it as the only input to a fairness rule; measure round trip with the game's own Blink ping message. Check the docs before building (hard rule 11): I could not open create.roblox.com this session.

## 7. PvP: what other games do

| Topic | Evidence | Confidence and source |
| --- | --- | --- |
| Level scaling | Temtem ranked (April 2020) scales every creature to the level cap and maxes its hidden stats; trained stats stay. Loomian Legacy treats level 50 as the PvP standard | snippet: https://www.thesixthaxis.com/2020/04/08/temtem-0-5-16-ranked-matchmaking-update-patch-notes/ , https://loomian-legacy.fandom.com/wiki/Loomian_Legacy_-_Veils_of_Shadow/Update_Log |
| Turn timers | Temtem: 30 s per turn plus a 3 minute reserve; when the reserve is gone, turns drop to 20 s. Pokémon VGC: 90 s team preview, 45 s per move, 7 minutes per player, 20 minute game. Pokémon TCG Pocket: a timed-out 90 s turn is halved next turn | snippet: https://temtem.wiki.gg/wiki/Alpha_0.5.16 , https://victoryroad.pro/sv-rules-regulations/ , https://bulbapedia.bulbagarden.net/wiki/Battle_(TCG_Pocket) |
| Disconnects | Temtem 1.3: a disconnected player's remaining clock keeps running for both pick-and-ban and turns. Pokémon Champions: time-out is a draw with no points either way, which has raised exploit worries | snippet: https://crema.gg/temtem/patch-1-3/ , https://automaton-media.com/en/news/pokemon-champions-new-rules-eliminate-timer-stall-wins-but-possible-exploits-raise-concerns/ |
| Loomian Legacy ranked | Queue from the Battle tab against anyone queued on any Colosseum server; MMR on a leaderboard; ruleset and format change each season; ranks such as Novice 3 and Advanced 2; rewards are Boost Tokens and Battle Tokens at low ranks and a themed background and frame for reaching Advanced 2 each season | snippet: https://loomian-legacy.fandom.com/wiki/Battle_Colosseum |
| Doodle World ranked | Ranked exists and bans some creatures. Nothing else found | snippet: https://doodle-world.fandom.com/wiki/User_blog:SkribbledPhantom0/Doodle_World:_PvP_Reviews |
| Thin queues | Marvel Snap matches a player with a bot when it cannot find a human near their rank; bots are common up to about rank 30 and absent at the top; bot decks are built by the team from popular decks; the stated purpose is shorter queue times | snippet: https://marvelsnapzone.com/bots-in-marvel-snap-a-comprehensive-guide/ , https://primagames.com/tips/how-to-spot-a-bot-in-marvel-snap-bot-list |
| Rating and inactivity | Pokémon Showdown ranks by Elo, with daily decay above 1400 unless enough games are played; smurf accounts are the main complaint | snippet: https://pokemonshowdown.com/pages/ladderhelp , https://smogon.com/forums/threads/rating-uncertainty-in-ps-ladder-matches-aka-glicko-1-against-the-smurfing-problem.3756168 |
| Roblox plumbing | Roblox's own docs list skill-based matchmaking as a MemoryStore use case: put players in a shared queue or sorted map and have servers match on a timer. Community advice: store the rating in the DataStore, keep queue entries small, do not remove a player from the queue until the teleport succeeds; sorted maps suit rating bands better than queues | snippet: https://create.roblox.com/docs/cloud-services/memory-stores , https://devforum.roblox.com/t/conceptual-implementation-building-a-custom-matchmaking-service-with-memorystore/3652856 |

Not found: any source on win-trading detection or repeat-opponent limits in creature games, and any turn timer or disconnect rule for Loomian Legacy or Doodle World. The anti-boosting rules below are my own design (inference).

## Recommendations for this game

Ranked by importance. None changes a [Locked] item. Two touch DECISIONS.md lines and are flagged.

### 1. Battle rules and damage formula (brief section 5) - keep the Default, tighten it

- No misses, no critical hits, status effects always apply. Keep.
- Damage shape: `damage = floor(Power x LevelScale x 2 x Atk / (Atk + Def) x TypeMult x OwnTypeBonus x Variance)`. The `Atk / (Atk + Def)` form is bounded (never more than twice the equal-stats hit), so bred stat stacking and rarity boosts cannot produce one-hit knock-outs. Tune `LevelScale` so an equal, neutral hit takes 30 to 35% of health: three hits to knock out, two when strong, four to five when weak.
- Variance: 0.96 to 1.00 in PvE and casual; exactly 1.00 in ranked and tournaments. With no variance the move button can show the exact damage and a "knock-out" marker, which is the clarity Into the Breach is praised for. All values in `src/config/`.
- Turn order: Speed, shown as a visible order strip. Ties go to the lower-health creature, then alternate; never a coin flip.
- Tension without luck: both players lock in at once; switching costs the turn; each creature gets a small energy bar (Temtem's stamina, simplified) only if playtests show battles are solved too easily. Do not build the energy bar for launch.

### 2. The ten-type chart (brief section 4) - adopt section 3 as the [Default]

Use the chart in section 3 with x1.5 and x0.67. Put an up or down arrow on every move button so nobody has to memorise it. Log it in DECISIONS.md with the two known gaps (Storm against Water; Frost has no early counter).

### 3. Battle pacing targets (brief sections 3 and 5)

| Battle | Turns | Target length at 1x speed | Hard limit |
| --- | --- | --- | --- |
| Wild | 2 to 4 | 20 to 40 s | none |
| Wild with a lasso throw | 3 to 5 plus the mini-game | 40 to 60 s | none |
| Local tamer, 3v3 | 8 to 12 | 90 to 150 s | none |
| Giant | 15 to 25 | 3 to 5 minutes | 30 turns, then it enrages |
| PvP 3v3 | 8 to 14 | 3 to 5 minutes | 8 minutes |
| PvP 6v6 | 16 to 28 | 6 to 10 minutes | 15 minutes |

- One turn = choose (aim for 3 to 5 s) plus resolve. Resolve budget at 1x: 1.2 s per move animation, 0.5 s for the health bar, 0.3 s for text; under 4.5 s for both sides. Battle start and end transitions under 1.5 s each.
- Speed setting 1x and 2x from day one, remembered per player; a "skip animations" toggle for wild battles. In PvP both players see the same speed (fixed at 1.5x, as Pokémon Masters does for co-op).
- "Quick battle": if the player's lead creature out-levels a wild creature by a set margin, offer an instant, server-resolved win with reduced coin and XP. It cannot be used to lasso. This answers the auto-battle requests without inviting idle farming; cap it per hour in config.

### 4. Mobile battle screen (brief sections 5 and 12)

Landscape, thumbs at the bottom corners, nothing important under them:

- **Top left and top right:** each side's name, level, type icon, health bar, status icons, and team pips (filled or empty).
- **Top centre:** turn-order strip and the turn timer ring (PvP only).
- **Middle 55% of the screen:** the two creatures. Tap either one for an info card.
- **Bottom right (right thumb):** a 2 x 2 grid of move buttons, each at least 150 x 64 pixels at Roblox's reference phone size, showing name, type colour and icon, power, the strong or weak arrow against the current target, and the damage preview.
- **Bottom left (left thumb):** Switch, Items, Lasso (wild only), Run or Forfeit. Switch opens a strip of the team's ViewportFrame icons along the bottom, not a full-screen menu.
- One tap commits a move. Only Forfeit and using the last of an item ask for confirmation. Press and hold any button for its description.
- Never rely on colour alone: every type has a shape icon as well. All buttons at least 48 pixels with 8 pixels between them. Leave the top-left Roblox menu area and the screen-edge safe zones clear.

### 5. Giant fight template (brief sections 5 and 6; DECISIONS.md consumables lines)

- One giant against the player's full team for that biome (3, 4, 5 or 6).
- Health about 2.5 times the combined health of an on-level team; it acts once per turn; its hits are tuned so a neutral creature survives two and a resistant one four.
- **Intent shown every turn:** an icon and one line above the giant ("Winding up: Rockslide, hits the whole team next turn"). Big attacks always take a wind-up turn.
- **Three phases** at 100%, 60% and 25% health. Each phase change is a scripted beat: the giant clears its own debuffs, changes its attack pattern, and adds one new idea. Phase 1 teaches the pattern; phase 2 adds the biome's status effect or a type change in its moves; phase 3 is a damage race.
- **A weak point:** hitting the giant with a type it is weak to during a wind-up cancels or halves the big attack. This rewards bringing the right team, which is the preparation DECISIONS.md asks for.
- Patterns are fixed lists, not random picks, so a second attempt is a better plan and not a re-roll. Status effects work on giants at reduced length; nothing skips its turn outright.
- Soft limit: at turn 30 it enrages (damage up each turn).
- Consumables: an attempt item to enter, and a cap of about five field items per fight so stocking up matters but cannot replace a good team. Flag: this cap is a new line for DECISIONS.md; it follows the "consumables pace giant fights" decision and does not conflict with "never stop anyone playing", because the items stay cheap.
- After a win: one hard lasso attempt (recommendation 6). Losing the lasso attempt keeps the win's coins and XP.
- Build all of it as data (thresholds, patterns, intents) so weekly bosses reuse it, as the scaffold research recommends.

### 6. Lasso mini-game rules and lag handling (brief section 6)

- **The game:** a marker sweeps back and forth along an arc; the player taps (or releases a hold) when it is inside the target zone. Harder creatures need two or three zones in a row and vary the sweep speed.
- **No dice.** The result is hit or miss. Zone width = base for the species and rarity x a health factor (wider as health drops, as the brief says) x the lasso tier. Better lassos widen the zone and slow the marker, as Fisch's rods do. A wild creature at full health has a zone too small to be worth trying, so the battle still matters.
- **A miss** costs the lasso and the turn; the creature then acts. Rare creatures may flee after a set number of misses (shown as a counter, not a chance).
- **Server authority:** the server picks the sweep pattern from a seed, stores the zone and the start time, and sends them. The client plays the sweep locally from the seed, so the player sees no lag. On tap, the client sends its elapsed time since the pattern started. The server accepts the claim only if it is consistent with its own clock: `serverElapsed - maxRoundTrip <= claimedElapsed <= serverElapsed + small margin`, with `maxRoundTrip` from the game's own ping measurement and capped at about 400 ms. It then recomputes the marker position from the seed and the claimed time and decides hit or miss. The lasso is deducted before the pattern is sent. One attempt per token, rate-limited.
- **Honest limit:** a script can still tap perfectly; timing alone cannot tell a bot from a skilled player. Contain it rather than pretend otherwise: the catch only succeeds on creatures the player has already found and weakened, rare spawns and giants are gated elsewhere, and the server logs timing error per account and flags inhumanly consistent results (for example, error under 10 ms across 30 throws) for review.
- **High-ping players:** if measured round trip is over the cap, slow the sweep for that attempt by the same proportion and show a "connection assist" note. Never fail a throw because of a late packet inside the cap.
- **Accessibility:** a setting for "hold and release" instead of tap; a slow mode (marker 30% slower, zone unchanged) available to everyone in settings; sound and vibration cues at the zone edge; high-contrast zone with a pattern, not just colour; reduced-motion option that swaps the sweep for a filling bar. Slow mode is PvE only, so it harms nobody.
- **Giant lasso:** three zones in a row, narrow, with a speed change between them; one attempt per win. Still deterministic.
- Lassos stay coin-only (brief section 6, unchanged).

### 7. Launch PvP plan for a small 16+ audience (brief section 10; DECISIONS.md "coin bets removed")

Consistent with DECISIONS.md: no stakes, capped casual coin rewards, ranked prizes made by the game.

- **Formats:** 3v3 only at launch (three biomes, three team slots). 6v6 opens when the biomes that unlock six slots ship. One format keeps a thin queue in one piece. Flag: the brief's [Default] lists 3v3 and 6v6 together; this defers 6v6.
- **Scaling:** every creature is set to level 50 in all Circuit play, as Temtem and Loomian Legacy do. Rarity boosts stay on but are small (5%); cosmic and tournament wraps are cosmetic in ranked. Bred parts and move choices remain the edge, which is the point of the game.
- **Team preview:** 30 s, both teams of three visible, each player picks a lead.
- **Clock:** 30 s per turn plus a 90 s reserve bank per player; when the bank is empty, turns are 15 s. A timed-out turn uses the first move. Three timed-out turns in a row is a forfeit. Game cap 8 minutes; at the cap, the side with the higher total health percentage wins (never a draw, to avoid the stalling problem reported in Pokémon Champions).
- **Disconnects:** the player's own clock keeps running; they can rejoin the same battle while it lasts (the battle state lives on the server). When their bank runs out they lose. A forfeit or disconnect before turn 3 gives the winner the rating but no coins.
- **Finding an opponent, in this order:**
  1. *Friendly challenge* inside a server: unrated, no rewards, any time.
  2. *Casual queue* across servers: wait up to 30 s for a live player; then offer a **saved-team match**, clearly labelled "Saved team: [player name]", against another player's registered team run by the tamer AI. Coins are the same either way and capped at about five paid wins a day.
  3. *Ranked*: live players only, open in two fixed two-hour windows a day ("Circuit hours") so the small population meets itself. The rating band starts at plus or minus 100 and widens by 50 every 10 s to a ceiling; it never falls back to a saved team.
- **Saved teams are labelled, not disguised.** Marvel Snap's hidden bots cause "bot paranoia"; with a 16+ audience and no stakes there is nothing to gain from hiding them.
- **Rating:** Elo-style, hidden number plus visible leagues (five leagues of three steps). Start everyone in the lowest league. No decay in the first season; add it only if the top of the board goes idle.
- **Seasons:** four weeks. Rewards by highest league reached: a profile frame and background, a title, and for the top league a labelled cosmetic wrap ("Season 1"), as the brief's tournament rule describes. Small coin payouts at each league step, once per season. Rotate one rule each season (a banned type, a level-50 "little cup" of commons), as Loomian Legacy rotates its ruleset.
- **Anti-boosting:** rated results against the same opponent count once per day; no rating or coins from private servers or from friends-list opponents in ranked; account must have finished Greenwood and be 3 days old to enter ranked; casual coin cap per day; the server logs pairs with repeated fast forfeits. With coin bets gone, the only things to farm are rating and capped coins, so these light rules are enough.
- **Plumbing (inference, check the docs first):** a MemoryStore sorted map keyed by rating for the queue, the rating itself in the ProfileStore profile, a reserved server per ranked match, and the battle run by the same pure battle module as PvE. Saved teams are small snapshots (parts, moves, level 50 stats) stored outside the player's live profile so they are readable while the owner is offline. I could not open the Roblox docs this session, so every API name here needs verifying under hard rule 11.

### 8. Things to verify before building (process)

- Re-run this research with wiki.gg, fandom.com, crema.gg, devforum.roblox.com and create.roblox.com allowed in the session's network settings, to lift "snippet" facts to "sourced" and to fill the Loomian Legacy, Doodle World and Tales of Tanorio gaps.
- Play the first hour of Loomian Legacy and Doodle World on a phone and time wild battles, tamer battles and the transitions; no written source had these numbers.
- Playtest the chart with 16+ testers who know other creature games and note every match-up they get wrong on first guess.
