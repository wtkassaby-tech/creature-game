# ClayPals story arc: eleven chapters

Date: 23 November 2026. Status: a draft for Ayrton; all [Default] except the [Locked] items it repeats. One chapter per biome, in the brief's [Locked] order. Chapters 1 to 4 are in the game (`src/content/story_data/`); their small proposed changes are in `CHAPTERS_1_4_PROPOSALS.md`. Chapters 5 to 11 are drafted as data in `chapters/`. Characters, history and voices are in `STORY_BIBLE.md`.

Pattern numbers are the 12 loved-story patterns in `docs/research/story/STORY_RESEARCH.md` section 2: 1 a villain with an argument, 2 a villain present from the start, 3 a rival with an arc, 4 a companion with their own need, 5 family-scale stakes, 6 the player has a job, 7 a reveal about a mentor or the player, 8 an ending that costs something, 9 place and history carry story, 10 the legendary as a character, 11 humour that leaves room for feeling, 12 pacing that respects the player.

## The arc in one line per chapter

| # | Biome | Chapter | In one line | Patterns |
| --- | --- | --- | --- | --- |
| 1 | Greenwood | Day one | The rival loses on the green and pockets the glint by your boot; the mentor smiles and lies | 2, 3, 6 |
| 2 | Dust Canyon | The shard | The glint hums, the rival shoves past a warden, and the mentor writes "only minerals. Truly" | 2, 3, 7 |
| 3 | Tide Flats | The voice | The rival hasn't slept; the glint is asking him something; the mentor promises the truth at the Mire | 1, 3, 7 |
| 4 | Mire | The half-truth | The flicker is a tear, says the mentor, and nobody knows how it opened; the rival, thrown by a giant, says it opened over Thistledown | 2, 3, 7 |
| 5 | Frostline | The sister | Sorrel arrives with her brother's abandoned first friend, names the mentor's tell, and the pages turn out to be her gran's | 4, 5, 3 |
| 6 | Crystal Deep | The picture in the stone | Two trulys in one letter send you to the Heartstone, where the first creature and the one-eyed Unraveller are carved | 9, 10, 1 |
| 7 | Emberfall | What kneels | The rival has stitched the volcano's giant to a leash; you break it, Sorrel learns gold-seam mending, and he says losing no longer hurts | 3, 2, 11 |
| 8 | Stormreach | First sight | From Cloud Isle you see the tear and the tired ram holding it; the Unraveller speaks; back to back, the rival says no | 10, 1, 3 |
| 9 | Arcane | No truly this time | The blinking lamp is for the Ringwalker; her last page names the mentor; he confesses, you meet the Frayling, and he blocks the Starwell and loses | 7, 5, 9 |
| 10 | Abyss | The last bridge | The rival's last battle and warning, his first friend given to you, and the Frayling mending the Last Bridge | 3, 8, 1 |
| 11 | The Hollow | Old Hearth | Gran is alive; the Unraveller is destroyed; the Frayling gives back its chip and the Firstling stitches the sky; the rival confesses the thread and walks away | 8, 10, 5 |

## The threads across chapters

### The rival

| # | Where | Battle | Tint | His team | His step ([Locked] arc items in brackets) |
| --- | --- | --- | --- | --- | --- |
| 1 | Green, gate | First (cannot be lost), gate | 0, 0.25 | His first creature; then the counter-lead with his first behind | Loses (item 1); pockets the glint |
| 2 | Mesa Road | Mid-biome | 0.5 | Counter-lead and canyon catches (no first creature) | Shoves past the warden (item 2) |
| 3 | Breakwater Gate | Gate | 0.75 | Two shards; gem-touched | "It's asking me something" |
| 4 | Old Stilt Hamlet | Mid-biome | 0.85 | Three shards; Mire catches | Tries to make a giant kneel; thrown off |
| 5 | Frozen Fall | Gate | 0.9 | Shards gone; the Mire's giant in his team, stitched | Swallowed the thread (hidden); cruel to Sorrel |
| 6 | (not met) | None | | | Tried to take a champion's Ruby: "a voice told him he deserved it" |
| 7 | Rim Gate | Gate | 1 | The volcano's giant leads, stitched; it breaks free when he loses | Lowest point; "it doesn't hurt to lose" |
| 8 | Cloud Isle | Team-up (story battle `tear_swarm`) | 1, then falling | His first creature returns to him | Refuses the voice; lets the giants go |
| 9 | Mirror Mere, the old fence | None | | | Reads gran's page; breaks the Starwell seal |
| 10 | Last Bridge | Gate: the last rival battle | about 0.5 | His own creatures, his first among them; no stitches | Warns (item 5); gives his first creature and supplies (item 6) |
| 11 | Old Hearth | None | | | Confesses the thread (item 8); leaves to walk the ring (stage 3) |

Data notes for the tamer files (not story data): his first creature (the starter that loses to the player's) is absent from his teams in chapters 2 to 7, which the data already does for 2 to 4, and returns from chapter 8. The gift in chapter 10 needs a per-starter reward (`OPEN_QUESTIONS.md`, question 4). A stitched giant in his team is the giant's creature form at the gate's level rule; it never affects the player's own giant.

### The mentor's lies, and the tell

"Truly" appears only in lies. Sorrel names the tell in chapter 5.

| # | The lie | How it reaches the player |
| --- | --- | --- |
| 1 | "Only a pebble" (proposed: "Truly." added); "some things are best left asleep"; "I once chased a perfect one. Never mind" | In person |
| 2 | "Only minerals. Truly." "We will talk when you are older." | Letter |
| 3 | "Weather. Truly." "I owe you the truth. I will bring it to the Mire." | Note |
| 4 | "The flicker is a tear... How it opened? No one knows. Truly." | In person |
| 5 | "Gran's travelling. Truly." (quoted by Sorrel) | Hearsay |
| 6 | "Fairy tales. Truly." "Gran is fine. Truly." | Parcel |
| 7 | "The giants will settle by themselves. Truly." and the crack: "I cannot lose anyone else" | Letter |
| 8 | Silence once the tear can be seen | Its absence |
| 9 | Found out by the Ringwalker's last page; "No 'truly' this time"; blocks the Starwell; loses ([Locked] items 3, 4) | In person |
| 11 | "It is always on. Welcome home." | In person |

### The villain's presence (pattern 2)

| # | The Unraveller is seen in | Its argument shows as |
| --- | --- | --- |
| 1 | A glint with a black thread through it (proposal), by the player's boot | (finders keepers) |
| 2 | The shard hums when the rival fights | Strength |
| 3 | It talks in his sleep, "asking me something" | A question |
| 4 | It swore the giant would kneel | Power over others |
| 5 | Through the rival: "It asked why I keep things I never chose" | **The argument, first stated** |
| 6 | Carved in the Heartstone: one red eye, unpicking the sky; an unravelled Glowthread | Its name and face |
| 7 | Black stitches on the volcano's giant | Taking by force |
| 8 | Its own voice from the tear | "Never come second again" |
| 9 | The cause of the mentor's mistake | Perfection |
| 10 | It whispers to the player at the Rift | "Hold nothing, and nothing can be taken from you" |
| 11 | It comes down for the sleeper; the 6v6; destroyed | "A world with nothing left to lose" |

### Gates (brief [Default]: most by the rival, a couple by champions, one team-up)

Rival: 1, 3, 5, 7, 10. Champions: 2 (Isolde Karrow), 4 (Honora Vell), 6 (Maren Quarrie), 8 (Wyn Halyard). The mentor: 9 (proposal). Team-up: 8 (Cloud Isle). The entity: 11.

### Pacing

- Chapter lengths follow the brief's [Default] of about 1.3 times the last, from chapter 4's 75 minutes: 100, 130, 170, 220, 280, 360 and 470 minutes (first-session targets, minutes from the start, to tune in playtests).
- Every chapter opens with a mechanic within its first five minutes (the research's "story never gates fun") and ends with a session-closing beat (badge, token, the road on).
- Story beats sit 5 to 25 minutes apart early in a chapter. The longer stretches before each gate (40 to 80 minutes in chapters 7 to 11) are the quest line, the giant, finds and training; the research's "payoff every 10 to 20 minutes" is met by those systems, and each chapter's quest line should end with a creature in that window (already the rule, brief section 8).
- No beat is longer than three lines; chained Follow beats run two seconds apart and each can be skipped.

---

## Chapters 1 to 4 (in the game)

### Chapter 1: Greenwood, "Day one"

- **Goal:** pick a friend, beat the rival, catch a third, earn the first badge.
- **Learns:** types (the rival's creature loses to yours), the lasso, wild battles, breeding (the mentor's egg), the shop and healer, quests.
- **Key beats:** the mentor's welcome and the flicker over the Crown; the rival's challenge and loss; the glint ("Finders keepers"); the lasso lesson; the giant glimpsed ("best left asleep"); the egg ("I once chased a perfect one"); the gate and badge.
- **Rival:** loses twice; "I will find a way to win."
- **Villain:** the glint by the player's boot.
- **Giant:** Hollowbough, the first evasion.
- **Payoff:** first win (minute 2), first catch (about 5), the egg (about 10), the first badge (about 55).
- **Sets up:** the glint, the mentor's secret, the road on.
- **Proposals (small):** seed Sorrel, the black thread and the tell; give the player the job of walking the ring. See `CHAPTERS_1_4_PROPOSALS.md`.
- **Patterns:** 2, 3, 6 (with the proposal). **Avoids:** tutorial overload (one teacher per idea), a villain arriving late.

### Chapter 2: Dust Canyon, "The shard"

- **Goal:** the Cairn Badge from champion Isolde Karrow. **Learns:** the first gem tier (Amber) and serial numbers; Sand speed.
- **Key beats:** Tamsin on gem-touched creatures; the mentor's letter ("only minerals. Truly"); the rival with a humming shard; Mesalith; the warden who was shoved past.
- **Rival:** dark tactics begin. **Villain:** the hum. **Giant:** Mesalith, restless since the flicker.
- **Payoff:** a first Amber chase; the rival's shard. **Sets up:** the voice.
- **Patterns:** 2, 3, 7. **Avoids:** a rival who never changes.

### Chapter 3: Tide Flats, "The voice"

- **Goal:** the Breaker Badge from the rival. **Learns:** bait.
- **Key beats:** bait at the Chandlery; the mentor's note ("weather. Truly"; "I will bring it to the Mire"); Captain Marr; Carrackon; the rival who hasn't slept.
- **Rival:** two shards; "it sounds like it is asking me something". **Villain:** a question. **Giant:** Carrackon.
- **Payoff:** the rival at the gate. **Sets up:** the mentor's promise.
- **Proposal:** Captain Marr names the Ringwalker as the last tamer to beat her, seeding the gran.
- **Patterns:** 1 (the question), 3, 7.

### Chapter 4: Mire, "The half-truth"

- **Goal:** the Bulrush Badge from champion Honora Vell. **Learns:** poison, 4v4.
- **Key beats:** poison at the spring; the mentor in person (a tear; "no one knows. Truly"); the rival thrown by the giant; Sloughback; the punt.
- **Rival:** three shards; "ask him why the tear opened over Thistledown first" (true: see the bible's history). **Villain:** the promise that the giant would kneel. **Giant:** Sloughback, the rival's turning point.
- **Payoff:** the half-truth. **Sets up:** the swallowing (off-screen), the companion.
- **Proposal:** one rival line hints the glint wants out of his pocket.
- **Patterns:** 2, 3, 7. **Avoids:** answers after the credits (half now, the rest in chapter 9).

---

## Chapters 5 to 11 (drafted in `chapters/`)

### Chapter 5: Frostline, "The sister" (minutes 290 to 390)

- **Goal:** the Snowdrop Badge from the rival at the Frozen Fall.
- **What the player learns:** Chill (a slow), taught by the healer Hilde Varrow, repeated by the first tamer; cross-biome breeding (Frostline front limbs carry Defence, so breed them onto a canyon sprinter), taught by the breeder Mags Tolley. Team stays four.
- **Key beats:** Rimewick; Chill; **Sorrel arrives** to fetch her brother home; first tamer and catch; the breeder's lesson ("Gran used to say that about people"); **his first friend**: it hatched from Gran's egg, he sent it home after Greenwood, and "he only says truly when he's fibbing"; Driftmother and her lantern post; **the pages are Gran's handwriting**; the rival at the gate; the badge.
- **Rival's step:** shards gone ("Don't need them now"), the Mire's giant stitched into his team, cruel to his sister; states the villain's argument for the first time.
- **Villain's presence:** the argument in the rival's mouth; the stitches.
- **Giant:** Driftmother, whom the Ringwalker rode up the pass; her lantern post is still on her back. Optional; counter: Fire as she lifts her paws.
- **Session payoffs:** Sorrel (about 300), the tell (about 325), the pages (about 335), the rival at the gate (about 370).
- **Sets up:** Sorrel travels on; the question "what is the mentor lying about?"; the red flash Sorrel saw.
- **Patterns:** 4, 5, 3, 11. **Avoids:** a rival who is only cheerful; a villain who arrives late; reliance on lore (Sorrel explains Gran in plain words).

### Chapter 6: Crystal Deep, "The picture in the stone" (390 to 520)

- **Goal:** the Geode Badge from champion Maren Quarrie.
- **What the player learns:** Ruby, taught by gemcutter Corwin Bale (rarer than Amber, stronger, numbered, more common nearer the Crown); the Serpent body plan, from the first tamer. The badge opens the fifth team slot.
- **Key beats:** Glimmerholt; Ruby; Serpents; a glowing catch; **the mentor's parcel with two trulys**, and Sorrel counting them; an unravelled Glowthread coming loose; **the Heartstone picture**: the first creature stitched from glass and the one-eyed Unraveller; Sorrel remembers her brother's eyes flashing red; Druseback; the champion's story of the rival and her Ruby.
- **Rival's step:** off-screen; tried to take a Ruby; "a voice told him he deserved it".
- **Villain's presence:** its picture and name; the first unravelled creature.
- **Giant:** Druseback rolled clear of the Heartstone and showed the picture. Optional; counter: Leaf or Frost as it unrolls.
- **Session payoffs:** the parcel and the two trulys (about 420), the Heartstone (about 445), the gate (about 500).
- **Sets up:** the Firstling as an idea; the red eye; a stronger rival offstage.
- **Patterns:** 9, 10, 1, 11. **Avoids:** motives only explained off-screen; series lore (the keeper says it plainly).

### Chapter 7: Emberfall, "What kneels" (520 to 690)

- **Goal:** the Cinder Badge from the rival at the Rim Gate.
- **What the player learns:** Burn, from the healer Elspeth Tinder; five a side, named on arrival; the Winged body plan, from the first tamer.
- **Key beats:** Cinderwick and its beacon; Burn; Winged; a warm catch; **Sorrel learns gold-seam mending** at the Glassworks ("Fill it with gold, so the mend shows": the theme, once); **the mentor's frightened letter** ("Come home... I cannot lose anyone else. Please."); **Cinderhart stitched to a leash** and the beacon guttering; the rival at the gate; the stitches snap.
- **Rival's step:** the lowest point. His gate team leads with the stitched stag; when he loses, it breaks free. First crack: "It doesn't hurt to lose anymore. That's the part that scares me."
- **Villain's presence:** taking by force; the black stitches.
- **Giant:** Cinderhart, bound by the rival, freed by the player's win; still optional to fight afterwards. Counter: Water on the wind-up.
- **Session payoffs:** the Glassworks (about 555), the letter (about 570), the stag (about 600), the gate (about 660).
- **Sets up:** the turn (he says "please"); the gold seams Sorrel will use in chapter 9.
- **Patterns:** 3, 2, 4, 11. **Avoids:** the plot happening in front of the player (the player breaks the leash); a rival with no change.

### Chapter 8: Stormreach, "First sight" (690 to 910)

- **Goal:** the Vane Badge from champion Wyn Halyard.
- **What the player learns:** Static (drains Tempo), from wind-gauge keeper Ansel Weir; winged creatures dominate.
- **Key beats:** Highwhistle; Static; first tamer and catch; the Loomoths that fly to Cloud Isle; **first sight of the tear** (brief section 8) and **Nimbram**: the halo is fleece, breathing hard; **the Unraveller speaks**: "Cut the old ram's fleece, little one, and you will never come second again"; **back to back** against the tear-touched swarm; his first friend shields him; he says no; he lets the giants go; Squallray; the champion; **the mentor's silence**, and the blinking light below.
- **Rival's step:** the turn back to friend (brief section 14: friend, rival, friend, threat). The team-up the brief asks for.
- **Villain's presence:** its own voice, its offer, its creatures.
- **Giant:** Squallray, Nimbram's herald circling the Crown. Optional; counter: Crystal or Arcane as its wings tilt.
- **Session payoffs:** first sight (about 755), back to back (about 765), the gate (about 880), the lamp and the silence (about 900).
- **Sets up:** the lamp, the mentor, the rival going to "ask the old man a question".
- **Patterns:** 10, 1, 3, 12. **Avoids:** a legendary as a wake-and-calm prize; a villain with few scenes.
- **Needs:** the story battle `tear_swarm` (a team of tear-touched creatures; a true allied battle is a later option, `OPEN_QUESTIONS.md` question 6); the tear shown by story flag (plan 13).

### Chapter 9: the Arcane biome, "No truly this time" (910 to 1190)

- **Goal:** the Lantern Badge from the mentor at the Starwell seal.
- **What the player learns:** Hex (locks the last move used for two turns), from healer Selwyn Hask; Arcane tails bring two moves (a roster proposal); the Old Lane shortcut home (plan 13).
- **Key beats:** Lanternmoor; Hex; first tamer and catch; **the lamp**: three long, one short, "come home", lit for the Ringwalker eight years ago; the Old Lane; **Mirror Mere**, where the rival has found **her last page**: the mentor tore the sky breeding with a star; "his mistake, not his fault"; "tell him I forgave him"; down the lane to Greenwood's old fence; **the confession** at the cottage, kettle on: "No 'truly' this time"; **Starfall Crater** opens; **the Frayling**; Sorrel's gold seams; the mentor gives it to the player; the rival has gone to break the Starwell seal; Bridgegrum; **the mentor holds the gate**: "I lost her to this tunnel. I will not lose you"; "Perfect lost to patched."
- **Rival's step:** shares his gran's page with his sister; confronts the mentor; breaks the seal to fetch her.
- **Villain's presence:** the origin of the mentor's mistake.
- **Giant:** Bridgegrum, who carried the Ringwalker over the Dell, and the mentor as a boy (and still sulks about his boots). Optional; counter: switch before the rune-lit Hex.
- **Session payoffs:** the lamp (about 955), the last page (about 980), the confession (about 1015), the Frayling (about 1040), the mentor's battle (about 1160).
- **Sets up:** the Starwell, the Frayling, "bring them home".
- **Patterns:** 7, 5, 9, 11. **Avoids:** answers locked after the credits; cutscene overload (the reveal is spread over five short beats in four places, each walked to by the player).
- **Needs:** Ayrton's biome 9 style references ([Locked]); Mirror Mere, the Old Lane, Greenwood's old fence and Starfall Crater as places; the battle `mentor_starwell` (a team bred for perfect: high stats, no Frayling).

### Chapter 10: the Abyss, "The last bridge" (1190 to 1550)

- **Goal:** the Comet Badge from the rival at the Last Bridge ([Locked]: the last rival battle).
- **What the player learns:** Drift (cannot switch out for two turns), from healer Ione Fairweather; Diamond on the first catch ([Locked]: Diamond starts here); the finale's rule, previewed by the rival.
- **Key beats:** Starfold under the one night sky; Drift; first tamer; a Diamond chance; Halcyre the sleepwalker (quest hook); **the rival at the broken Last Bridge**: "something kept saying my name. Nicely."; Starfathom; **the Unraveller whispers to the player**; **the last rival battle**; **the warning** ([Locked] item 5); **the gift** ([Locked] item 6): his first creature, Gran's egg, with supplies; **the Frayling mends the bridge**: "Mended things mend things"; the carved stone: "Keep the fire fed."
- **Rival's step:** an honest fight; the gift; ready to cross with the player.
- **Villain's presence:** its argument aimed at the player.
- **Giant:** Starfathom, the sky's own creature, churning the Starwell. Optional; counter: Crystal or Storm as the crest brightens.
- **Session payoffs:** the rival at the bridge (about 1280), the whisper (about 1430), the battle and gift (about 1510), the mended bridge (about 1525).
- **Sets up:** someone is keeping a fire at Old Hearth.
- **Patterns:** 3, 8, 1, 4. **Avoids:** a rival whose arc never pays off.
- **Needs:** a per-starter gift reward; the Halcyre quest line ending at the Last Bridge, to fill the long stretch before the gate.

### Chapter 11: the Hollow, "Old Hearth" (1550 to 2020)

- **Goal:** destroy the Unraveller ([Locked] item 7).
- **What the player learns:** six a side; unravelled creatures (a lost part loses its moves; a Crystal hit stitches it back; scaffold F), taught once on a patrol before the finale; Hearthwarden's window (its glass lights the next type).
- **Key beats:** **Gran is alive**: "Well. You took your time."; her fire keeps the threads off the sleeper; the rival's apology ("We'll talk when this is done"); a catch with a glass patch; the unravelled patrol; the tapestry; Hearthwarden; **the sleeper**, missing one pane, the colour of the Frayling's chip; **the Unraveller comes**; the 6v6; destroyed; **the Frayling gives back its chip**, unasked; **the Firstling wakes**, delighted by its descendants, stitches the sky shut and hands the player the cosmic wrap ([Locked] item 9); **the rival confesses the thread** ([Locked] item 8); home: "Is the kettle on?" "It is always on."; the player named Ringwalker; **the rival leaves to walk the ring**; the gifted creature's stitch flickers black.
- **Rival's step:** confession and departure: friend now, threat later (brief section 14).
- **Villain's presence:** in person, to the end.
- **Giant:** Hearthwarden, the Ringwalker's old hound, who no longer knows her. Optional; the reward of calming it is that it lies down by her fire (a client visual from the giant's flag).
- **Session payoffs:** the reunion (1550), the sleeper (about 1860), the finale (about 1890), home (about 1960).
- **The ending's cost (pattern 8):** the Frayling's chip (its specialness, given away), the rival (gone, with the thread asleep in him), and eight years nobody gets back. Not "friendship fixes everything": the thread stays.
- **Patterns:** 8, 10, 5, 7, 1. **Avoids:** a flat, anticlimactic villain (present since minute two, a full 6v6 with phases); "love fixes everything with no cost"; expansions dropping threads (stage 3 starts from the knot in the rival, the dark stitch and the Ringwalker's retired title).
- **Needs:** the battles `unravelled_patrol` and `unraveller`; a cosmic wrap reward kind; the Firstling and Frayling as mythics; story-flag visuals for the sealed tear, the white halo and the steady lamp (plan 13 section 9b).
