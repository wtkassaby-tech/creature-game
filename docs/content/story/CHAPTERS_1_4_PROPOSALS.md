# Chapters 1 to 4: proposed changes

Date: 23 November 2026. Status: proposals only. Nothing in `src/` has been changed; Ayrton approves before any of this goes into the game.

Chapters 1 to 4 already serve the new arc well: the glint, the mentor's "Truly" in chapters 2 to 4, "I once chased a perfect one", "some things are best left asleep", the rival's growing tint and the "tear opened over Thistledown" line all fit `STORY_BIBLE.md` as written. So the changes below are the smallest that seed what the later chapters pay off: the black thread (the villain from minute two), the mentor's tell from the first lie, the rival's sister, the Ringwalker, and the player's job.

Six line changes and two added lines, across three files. Every line is 90 characters or fewer and no beat goes over three lines. No beat, trigger, flag, grant or timing changes, so the story tests and the robot playthrough are unaffected unless a test pins the exact line text (the builder should check `tests/story.test.luau` and `tests/world.test.luau`).

## Chapter 1: Greenwood (`src/content/story_data/Chapter1.luau`)

| # | Beat | Current line | Proposed line | Why |
| --- | --- | --- | --- | --- |
| 1.1 | `rival_challenge`, line 2 (Rival) | "Come on, then. The green is plenty big for my grin and your nerves." | "My sister bet a week of chores I'd lose. She's wrong about everything. Come on, then." | Seeds Sorrel, the companion who arrives in chapter 5, and the rival's family (pattern 5). Funnier, and it sets up the payoff: she was right. The current line is the weakest in the beat (the first-15 plan calls the voices "present but plain") |
| 1.2 | `rival_parting`, line 2 (Mentor) | "Only a pebble. Come along. The lasso lesson is next." | "Only a pebble. Truly. Come along, the lasso lesson is next." | Starts the mentor's tell at his first lie. Chapters 2, 3 and 4 already end a lie with "Truly"; this makes it four for four, so when Sorrel names the tell in chapter 5 the attentive player can look back and see it was there from minute two (pattern 7) |
| 1.3 | `rival_parting`, line 3 (Rival) | "...Pretty pebble. Finders keepers." | "...Pretty pebble. Got a little black thread through it, like a stitch. Finders keepers." | Puts the villain on screen in minute two (pattern 2; the research's top failure is a villain who arrives late). Reconciles the game's glinting shard with scaffold F's black thread (Blackstitch): the thread lives in the shard. The player learns what it means only in chapter 11 ([Locked] arc item 8) |
| 1.4 | `badge_and_token`, line 1 (Rival) | "Again... Fine. Keep your badge. I will find a way to win." | "Again... Fine. Keep your badge. I will find a way to win. Any way." | Two words that point at [Locked] arc item 2 ("after losing, he begins using dark tactics"). Optional |
| 1.5 | `sealed_path`, line 2 (Mentor) | "The road is yours now. Go on. I will stay and mend a few things." | "The road is yours. Walk the whole ring, as the Ringwalkers did. I will mend a few things." | Gives the player a job (pattern 6: walk the ring as the old Ringwalkers did), names the Ringwalker title the player earns at the end, and keeps "mend", which pays off in chapters 7, 9 and 10 |

Kept as they are, because they already seed the arc: the opening ("The sky flickered over the Crown last night"), "Mine is way cooler, though" (his pride in the creature from his gran's egg), "Some things are best left asleep" (the sleeping Firstling), "Every egg is a little surprise" and "I once chased a perfect one. Never mind." (the mentor's mistake).

## Chapter 2: Dust Canyon (`src/content/story_data/Chapter2.luau`)

No change proposed. The letter's "only minerals. Truly", the rival's humming shard and "He never answers me, either", and the warden's "a boy in a green jacket shoved past me" all fit. The journal page at the broken bridge ("Across the gap, something glints violet") already seeds Starfall Crater for chapter 9.

## Chapter 3: Tide Flats (`src/content/story_data/Chapter3.luau`)

| # | Beat | Current line | Proposed line | Why |
| --- | --- | --- | --- | --- |
| 3.1 | `tide_champion`, new line 3 (Marr) | (the beat has two lines) | "Last one to beat me that fast was the old Ringwalker. Never came back for her rematch." | Seeds the Ringwalker by title two chapters before Sorrel names her, so chapter 5's "That's what they called Gran" lands as a reveal, not a new fact. It also tells the player the old tamer behind the journal pages was real and strong |

Kept: "Sometimes it sounds like it is asking me something" (answered in chapter 5) and "Your mentor knows what that flicker is" (answered in 9).

## Chapter 4: Mire (`src/content/story_data/Chapter4.luau`)

| # | Beat | Current line | Proposed line | Why |
| --- | --- | --- | --- | --- |
| 4.1 | `mire_rival`, new line 3 (Rival) | (the beat has two lines) | "The glint says it could do more. If I stopped keeping it in my pocket." | The rival swallows the thread between chapters 4 and 5. This hints at it without saying it, so chapter 5's "Don't need them now" and chapter 11's confession both click. [Locked] item 8 holds: the player cannot know from this line what he did |

Kept: "Ask him why the tear opened over Thistledown first" is true in the new history (the mentor bred with the star at home; Nimbram dragged the tear to the Crown), so plan 13's tear over the Rift and this line agree. "How it opened? No one knows. Truly." stays as the mentor's biggest lie, answered in chapter 9.

## Outside the chapter files (for the builder, not story data)

- **Journal pages** (plan 14): no text change. They become the Ringwalker's, revealed in chapter 5. One later page should be written to match: the Sunken Bell set (the night the sky tore, from the Mire's side) and the Mirror Mere last page, whose words are the chapter 9 beat `last_page`.
- **The Lantern Spire's blink** (plan 13): three long, one short, from day one. Chapter 9 explains it; chapter 11 turns it steady.
- **The rival's teams** in chapters 5 to 10 are tamer data. See `ARC.md`, "The rival".
