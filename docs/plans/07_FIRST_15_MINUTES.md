# The first 15 minutes

23 November 2026. A plan for Ayrton and for the builder agents. Nothing here is built yet.

**Who it is for:** players aged 9 to 16, on a phone first. The feel is a nostalgic, homely creature game in the layout style of Project Pokemon, with every name, line and picture our own.

**What was read:** `CLAUDE.md`, `docs/PROGRESS.md` (top four entries), `docs/research/games/00_REPORT.md`, `04_POKEMON_STRUCTURE.md`, `05_POKEMON_PRESENTATION.md`, `Chapter1.luau`, the Greenwood biome, tamer and quest data, `EconomyConfig`, `LassoConfig`, `BattleConfig`, `ProgressionConfig`, `StoryView`, `BattleView`, `ResultPanel`, `LassoView`, `StoryService`, `StoryTriggers`, `CreaturesView` and `WorldConfig`. `07_APPEAL.md` and `08_PLAYER_REVIEWS.md` do not exist yet. When they appear, check this plan against them.

**The rule behind every package:** the server decides every result. Everything here is either words, data, or a client screen that shows what the server already sent. Anything that touches saving, purchases, captures, breeding rolls, serials, trading or PvP rewards is marked **NEEDS APPROVAL** and is not designed around.

---

## 1. The experience we want

### The big idea

A new player should feel four things, in this order: welcomed, clever, proud, curious. Welcomed by a warm village and a kind mentor. Clever when they win a fight they were told they would struggle in. Proud when they catch their own friend. Curious about a big tree that is breathing and an egg that is about to crack.

We keep the existing path (arrive, pick, rival, lasso, Route A, giant glimpse, egg). We change very little in what happens. We change how each step is told, taught and rewarded.

### Timing notes

Walking is cheap. Route A is 400 studs and a character walks about 16 studs a second, so the whole lane is about 25 seconds. The time goes on reading, battles and the lasso, not on walking. That is good: backtracking to the mentor for the egg costs about 12 seconds.

The mentor's egg hatches 3 minutes after it is given (`BreedConfig.GIFT_EGG_SECONDS`). To make the first hatch land by about 15:00, the egg must be given by about minute 11. Work package 6 does that by moving the catch beat forward.

### Minute by minute

| Time | Stretch | The player sees and does | They should feel | The moment worth remembering |
| --- | --- | --- | --- | --- |
| 0:00 to 0:45 | Arrival | A title card "Thistledown" fades. Late-afternoon light, birdsong, the village green, a thatched cottage with a figure waving on the porch. The mentor's first line types out. | Welcome. Somebody was expecting me. | The first voice: "The kettle is on." |
| 0:45 to 2:00 | Meet the three | Three friend cards. Tap one: it shows its picture, a one-line personality and a short cry. A "Pick this one?" button confirms. The chosen creature hops out of its card and stands beside the player. | Choosing is a big, safe decision. | **FIRST FRIEND.** The hop, the cry, "it is yours". |
| 2:00 to 3:30 | The rival's challenge | The rival bounds up, grins, says he took the one that beats yours. A short walk to the green. The battle opens. A coach in the text box says: "Pick FIGHT, then a move. STRONG means extra damage." | A little nervous, but the mentor is cheering. | The rival's cheek: "Just so you know." |
| 3:30 to 4:00 | The first win | Four to six turns. One move is marked STRONG. The creature lunges, the hit flashes, VICTORY counts up. The rival sulks and notices a glint. | I out-thought him. | **FIRST WIN.** A STRONG hit at the right time, and the counter-pick lost anyway. |
| 4:00 to 5:30 | The lasso lesson and the shop | The mentor shows the lasso, with plain words (marker and green, not "ring"). A free Gorsling arrives. A nudge to Tuppence's: "Rope runs out." Marlow's welcome: 150 coins, what to spend them on. | Looked after, and trusted with my own purse. | **FIRST CHOICE THAT IS MINE** (beyond the starter). Tonic, rope, or save it. |
| 5:30 to 7:00 | Onto Clover Lane | A short walk. A sleepy Mossmitt rolls out of the path. An old hollow log has a "Look inside" prompt. Long grass rustles. | The world is alive and has secrets. | **FIRST SURPRISE.** Something I did not have to be told about. |
| 7:00 to 9:30 | The first catch | A wild fight. The coach says to weaken it first. The LASSO button pulses when its health is low. The green on the bar is visibly wide because the creature is tired. The player throws. A "New friend" card appears with a picture, a blurb, its type and "Added to your team". | Proud. It is mine because I earned it. | **FIRST CATCH.** GOT IT, the jingle, the card. |
| 9:30 to 10:30 | Pip | A short bout with Pip, a kid in a straw hat. Funny losing line. | Easy fun. | "The hat has never lost before." |
| 10:30 to 11:00 | The tree | Walking through the meadow, the camera gently looks at a huge tree in the haze and holds for three seconds. The mentor's voice warns, then sends the player home with "I have something for you." | Something bigger is out there. | **FIRST GLIMPSE OF SOMETHING BIGGER.** |
| 11:00 to 12:30 | The egg | The mentor hands over an egg and a pen. The Creatures button pulses. The egg timer shows. | A new kind of game is opening. | The mentor's odd line: "Do not ask what you must be strong for." |
| 12:30 to 14:30 | Own pace | Free time. Fresh Tracks (win 4 on Route A) and Marlow's favours are open. The Creatures screen shows "Greenwood friends 4 of 8" with dark silhouettes. | I want to fill the set. | The silhouettes. |
| 14:30 to 15:30 | The hatch | The egg cracks. A notice: "Your egg hatched! Open Creatures." The child is shown with parts from both parents. | Surprise and curiosity about breeding. | **FIRST HATCH.** The fourth friend nobody else has. |
| 15:00 | Day one | A small "Day one" card sums up: friends, wins, the egg. The tracker still shows unfinished business. | I should come back. | The tracker: egg, Fresh Tracks, friends 4 of 8, River Road, the tree. |

### Rules for the whole 15 minutes

1. No more than 90 characters a line and three lines a beat. Every line is skippable. Tapping NEXT mid-line shows the rest.
2. The first battle is 4 to 6 turns, about 60 to 90 seconds.
3. Every explanation comes at the moment it is needed, in the game's own text box, not in a manual.
4. A new player is never stuck. If a lasso throw misses, the creature does not flee (Common creatures never flee: `FLEE_AFTER_MISSES.Common = 0`), and the coach says so.
5. No timers pressure the player. The egg is a gift to look forward to.
6. A phone-sized screen must read cleanly: big buttons, short lines, nothing under the thumbstick.

---

## 2. Gap list: what the game does today against the plan

Each row is one beat.

| Beat | Today (from code and data) | The plan | Gap |
| --- | --- | --- | --- |
| Arrival | The player spawns at the hub. The pick screen opens at once as a UI panel (`StoryView.luau`, `pick`). No title, no pause, no sense of place beyond the new scenery. | A title card, a settle, then the mentor speaks first. | No arrival beat. The first thing a player sees is a menu. |
| Mentor's welcome | One line, in a small dim label on the pick screen: "Welcome! Three friends are waiting. Pick the one that feels right." Only `lines[1]` is used. | Three typed lines in the dialogue box before the cards. | Only the first line shows, and it is small and grey. |
| Choosing a friend | Three cards with a picture, name and "X type". One tap sends `CompleteBeat` at once. No confirm, no personality, no cry. | A tap shows a larger picture and a personality line. A "Pick this one?" confirm follows. A cry sounds. | No preview, no confirm, no personality. An accidental tap commits the pick. |
| Bonding and naming | Nothing. No nickname field exists anywhere in the code (no `Nickname` in `src` or `net`). The friend does not follow the player. | A hop and a cry, a friend who follows you, and optional naming. | No bond. Naming needs new saved data, so it is **NEEDS APPROVAL** (work package 14). |
| Rival challenge | `rival_challenge` is a `Follow` beat. It plays two lines two seconds after the pick (`StoryService` `FOLLOW_SECONDS`). The player then finds the rival by walking to him (`TestMap.luau` puts a "Battle" prompt on him). The tracker says "Next: win the battle (A challenge)". | A short, funny exchange, then a clear walk to the green. | Lines are fine but flat. No signpost saying where he is beyond the tracker. |
| First battle teaching | The text box says "What will X do?". Move buttons show STRONG or WEAK (`MoveButton.luau`). Nothing tells a new player what to do or why a button is coloured. The rival is level 4 against the player's level 5 and `firstCannotBeLost` is true. | A coach for the first battle only, reading the existing STRONG hint. | No coach. A player can sit and not know what FIGHT means. |
| First battle pacing | `EVENT_SECONDS` is 0.7 per event, with a fast switch and tap-to-hurry. Length is not measured. | 4 to 6 turns. | Unknown. Needs a Lune check per starter (work package 13). |
| First win | `ResultPanel` shows VICTORY, then coins and XP count up. Good. The rival's parting line follows. | Same, with the STRONG hit highlighted and the rival's glint line. | Works. The line is a little stiff. |
| Lasso lesson | `lasso_lesson` grants a free Gorsling, five Basic ropes, three tonics and coins. The mentor says "throw when the ring sits on the target". The screen has a bar and a marker, not a ring. | Clear words that match the screen. A real, guided catch. | **Wording mismatch.** The first "catch" is a gift, so the lesson is never practised. |
| Lasso teaching | `LassoView` says "Tap when the marker is in the green". Nothing explains that a fresh creature has a tiny green. At full health the zone is 5 percent of its base width (`HEALTH_FACTOR_FULL`), about 0.015 of the bar: not worth trying. | A coach that says to wait until health is low, and shows the green growing. | A new player can burn ropes on a creature at full health and feel the lasso is broken. |
| First catch | The player must pick LASSO in a wild fight. The screen shows "GOT IT!", then "Caught!", then a CAUGHT! panel with coins and XP. | A celebration: a card with the new friend. | No identity: the player never sees what they caught or where it went. |
| Story beat for the catch | `third_creature` is a `Tame` beat but sits after `mentor_egg` in a strict list. `StoryTriggers` only counts a catch when that beat is the next one. A catch made earlier is not remembered. | The first catch fires its beat. | **A real catch on Route A before the egg does nothing for the story.** The player needs a second catch later. |
| Walking onto Route A | `route_one` fires on entering. Lines: shop and healer advice. Wild creatures stand in the open. Long grass can start a surprise battle (22 percent each second moving, rest of 8 seconds). The only rustle spot on the lane is the reed bed at stud 340, near the end. | Something delightful in the first stretch. | Nothing early to find. The lane has no "oh!". |
| Pip | `gw_pip` at stud 100, level 3 Gorsling, one creature. Good size. Lines are fine. | A funnier, shorter line. | Minor. |
| Giant glimpse | `Sight clover_meadow` fires a few steps past the signpost (known from `PROGRESS.md`). Two mentor lines, no visual moment. | The tree is made to feel big. | The text says "see that tree" with nothing to see. |
| Mentor's egg | `mentor_egg` needs a `Talk` to the mentor. Gives an egg, a second pen and 2 Prism Candy. Hatch is 3 minutes. | The egg arrives by about minute 11. | Arrives at 8 to 12 by design. Fine if the reorder happens. |
| Reason to open Creatures | A "Creatures" button sits in a bar. The egg timer shows inside it. A notice says "An egg! It hatches in 3:00" and "N eggs hatched!" (`CreaturesView.luau`). | A pulsing button, a count of friends, a nudge when something is ready. | The button is passive. Nothing pulls the player in. |
| A small early choice | Only the starter pick. The shop opens at `route_one` but nothing guides a first purchase. 150 coins and five ropes are given. | A guided first spend. | The player may leave town with 150 coins unspent. |
| Session end | `first_quest` lines open River Road. The tracker shows the next story hint and active quests. No summary. | A "Day one" card and a tracker with several unfinished things. | No close. The player drifts. |
| Dialogue | At most three lines of 90 characters. Mentor and rival voices are present but plain. | Warmer and funnier. | See section 4. |

---

## 3. Work packages

Ordered by enjoyment gained per effort. Each is small enough for one builder agent. Every package ends with `lune run check`, then a Studio look at phone size and desktop size.

General notes for every builder:
- Read `CLAUDE.md`, especially the Hard rules and the approval rule.
- Client-only packages read what the server already sends (`ClientState`, battle events, `BeatCompleted`). They add no new messages unless stated.
- Strings in data stay inside the 90-character, three-line limit. `tests/world.test.luau` checks it.
- Update `docs/PROGRESS.md` when done.

### WP1. The dialogue pass (words only)

**Why first:** the biggest warmth for the least risk. No code.

**Files:** `src/content/story_data/Chapter1.luau`, `src/content/tamer_data/Greenwood.luau` (Pip's and the rival's `before` and `after`), `tests/story.test.luau` and `tests/world.test.luau` if they pin line text.

**Change:** replace the lines with those in section 4. Fix "ring" to "marker" and "green". Keep speakers as roles (Mentor, Rival) where the data does. Keep all counts at three lines or fewer and 90 characters or fewer.

**Test:** `lune run check`. Add a length assertion if none exists.

**Studio:** play the first six beats and read every line aloud. Check that a line fits the dialogue box on a phone without cutting.

**Approval:** none.

### WP2. The first-battle coach (client only)

**Files:** `src/client/BattleView/BattleView.luau` (the `message` label and menu), `src/client/State/ClientState.luau` (read flags).

**Change:** when the player's flags do not yet contain `rival_parting`, the battle is the rival's first. For that battle only:
1. At the start, the text box says: "Pick FIGHT, then a move. The bright ones say STRONG."
2. After the first turn, if a STRONG hit landed: "STRONG! That is how you win fights."
3. If no STRONG move exists for the rival's creature, say nothing about STRONG. Do not promise one.
4. Never block a button. The coach is text only.

**Pacing:** do not slow the turn. The coach text appears in the message box between turns, which already exists.

**Test:** Lune cannot see client screens. Add a pure helper `coachLine(flags, state)` in a small module and test it. Also run work package 13's pacing test.

**Studio:** start a new game, pick each starter in turn, fight the rival. Does the coach appear once and only in the first battle? Does it fit on a phone?

**Approval:** none.

**Note on the starter risk:** I did not confirm that each starter has a move that is STRONG against its counter-pick. Mossmitt (Leaf) has a Water move (Brook Rush) on its torso list, but the starter's learned moves at level 5 were not traced. The builder must check this per starter in Lune before writing the "bright ones" line.

### WP3. The lasso coach and the wide green (client only)

**Files:** `src/client/BattleView/BattleView.luau`, `src/client/Lasso/LassoView.luau`.

**Change:**
1. In the first wild fight after `lasso_lesson` and before `third_creature`, the text box says: "Win it over first. When its health is low, choose LASSO."
2. When the wild creature's health is at or below 40 percent, pulse the LASSO button gently and say: "It is tired now. Time to throw!" At 40 percent the green is about 0.15 of the bar, about ten times the width at full health.
3. On the lasso bar, for the first throw, show a one-line note under the title: "Tired creatures leave a wide green." Display only.
4. If the throw misses: "It slipped the rope. It will not run off. Try again!" This is true for Common creatures.

**Test:** a pure helper for "is it time to pulse" (health ratio) tested in Lune. `lasso.test.luau` already covers the zone widths; add a check that the zone at 40 percent health is at least five times the width at full health.

**Studio:** catch a wild Gorsling on a phone view. Is the pulse noticeable but not annoying? Is the note readable?

**Approval:** none. No server number changes; the server still judges the throw.

### WP4. The "New friend" card (the catch as a celebration)

**Files:** `src/client/BattleView/ResultPanel.luau`, new `src/content/SpeciesBlurbs.luau` (one line per Greenwood species, a data-only module beside the registries), `src/client/Creatures/Portrait.luau`.

**Change:** for a `Caught` result, show a card before or inside the CAUGHT! panel: the creature's picture (`Portrait`), its name and level, its type chip, a blurb, and "Added to your team" (or "Sent to your stable" if the team is full; the builder must read how the server places it). Add a short jingle (stand-in from `Sfx`) and a small burst of colour. Keep it skippable: one tap goes on.

**Blurbs:** eight lines of at most 60 characters, for the eight Greenwood species (Mossmitt, Gorsling, Sloshcalf, Splashjack, Spadesnout, Stumpwarden, Stiltbark, Burlhorn). Draft in section 4.

**Test:** a Lune test that every Greenwood species has a blurb of 60 characters or fewer (add to `tests/world.test.luau` or a new small test). The rest is visual.

**Studio:** catch a creature, then a different species. Does the card name the right one? Does a rare colour show in the card? (Check what the server sends; do not add data if it is missing, flag it.)

**Approval:** none. It only shows a result the server already decided.

### WP5. The opening: arrival, pick screen, confirm step

**Files:** `src/client/Story/StoryView.luau` (the `pick` screen and the dialogue box), `src/client/Audio/Sfx.luau` (a cry stand-in), `src/content/story_data/Chapter1.luau` (lines from WP1).

**Change:**
1. On a brand-new profile (`state.Starter == ""`), show a "Thistledown" title for about two seconds, then the mentor's lines in the dialogue box, then the cards.
2. Each card gets a one-line personality from `SpeciesBlurbs` (WP4).
3. Tapping a card plays a short cry and enlarges it. A "Pick this one?" and "Not yet" pair appears. Only "Pick this one?" fires `CompleteBeat`.
4. After the pick, the card's creature hops once, and the mentor's reply line types out.
5. The `pick` screen must use all of `lines`, not only `lines[1]`.

**Test:** `lune run check`. Add a pure test that the pick flow sends `CompleteBeat` only after the confirm (extract the decision into a small function).

**Studio:** phone view first. Can a thumb hit the cards and the confirm button? Does an accidental tap now do nothing? Is the title card skippable?

**Approval:** none. The starter pick message is unchanged.

### WP6. Reorder the beats so the catch fires early

**Files:** `src/content/story_data/Chapter1.luau`, `tests/world.test.luau`, `tests/story.test.luau`, `tests/trainers.test.luau`, `tests/playthrough.test.luau`, `src/content/quest_data/Greenwood.luau` (check only).

**Change:** move `third_creature` to directly after `route_one`. Then `first_tamer` requires `third_creature`, and `first_quest` requires `mentor_egg` (it required `third_creature`). The quest `gw_fresh_tracks` still requires the flag `third_creature`, which still exists. Update `minuteFrom` and `minuteTo` for the moved beats (`third_creature` about 6 to 9, `first_tamer` 9 to 11, `giant_glimpse` 10 to 12, `mentor_egg` 11 to 13). Change the line to: "Three on your team, and one you earned yourself."

**Why:** the player's first real catch now fires a beat, so the catch is celebrated by the story as well as by the screen. It also moves the egg later, to about minute 11 to 13. If the hatch must land by 15:00, the egg must be given by about 12 (see "Risks").

**Test:** `tests/world.test.luau` pins beat order (`giant_glimpse < mentor_egg < first_quest` at about line 579) and times (line 570). Update those. `tests/trainers.test.luau` and `tests/quests.test.luau` call `advance(profile, "third_creature")` and set the flag directly: re-read them. The robot players in `tests/playthrough.test.luau` need a catch before Pip. Run `lune run check`.

**Studio:** play from a new profile. Make sure a player who beats Pip before catching is not stuck (a `Win` beat still fires from a recorded win, but the `Tame` beat waits for a catch).

**Approval:** flag it. It changes story flow and when gifts arrive. It does not change any gift, number or roll. Say so in `PROGRESS.md` and ask the owner to confirm the new order.

### WP7. A reason to open Creatures

**Files:** `src/client/Creatures/CreaturesView.luau`, `src/client/Creatures/Portrait.luau`.

**Change:**
1. The Creatures button pulses softly when something is ready: an egg is waiting, an egg hatched, or a new friend is not on the team yet.
2. After the egg is given, a notice says: "Your egg is in a pen. Tap Creatures to peek."
3. At the top of the Creatures list, show "Greenwood friends 4 of 8". Each Greenwood species the player does not own shows as a dark silhouette of its picture with "?" for a name. This is computed on the client from owned creatures only, so no new data is saved.
4. A short note: "Seen" and "Caught" are not tracked yet; this counts what you own.

**Test:** a Lune test for the count and the silhouette decision (pure function over a list of species). The visual is checked in Studio.

**Studio:** with one creature, then three. Do the silhouettes make you want to fill them? Check the phone view for crowding.

**Approval:** none for the display. A real "seen and caught" book that saves is a separate, larger package and needs approval (saving). Not planned here.

### WP8. The "Day one" closing and the unfinished tracker

**Files:** `src/client/Story/StoryView.luau`.

**Change:**
1. When `BeatCompleted` for `first_quest` arrives (the first time it fires), show a "Day one" card: friends owned, wins, "Your egg is hatching" or "Your egg hatched". It appears once, because it is driven by that event.
2. The tracker shows several unfinished things, not only the next beat: the egg timer, Fresh Tracks progress, friends x of 8, and one story line: "Something stirs in the old tree."
3. Keep it to three or four lines so it fits (the tracker is 300 by 86 pixels today; enlarge it only if needed).

**Test:** a pure function that builds the tracker lines from state, tested in Lune.

**Studio:** run to the end of the first quest. Does the card make you want to carry on? Is the tracker readable on a phone?

**Approval:** none.

### WP9. The giant glimpse camera moment

**Files:** new `src/client/World/GlimpseCam.luau`, `src/client/Story/StoryView.luau` (call it on the `giant_glimpse` beat), `src/client/Main.client.luau` (require it).

**Change:** when `BeatCompleted` for `giant_glimpse` arrives, tween the camera to look toward the giant tree for about three seconds, hold, then hand it back. Cancel at once on any touch or movement. A low rumble and the haze deepening slightly sell the size. The tree's position comes from `lair` and the map; the builder reads how `WorldView` finds it.

**Test:** none in Lune (pure client). Add a check that the camera always returns to the player's control.

**Studio:** phone and desktop. Can the player lose the camera? Does touching the screen cancel it at once? Does it stay clear of the tracker?

**Approval:** none. Check `PROGRESS.md`'s note that the beat fires a few steps past the signpost; this may be enough.

### WP10. Route A delights

**Files:** `src/content/biome_data/Greenwood.luau` (a new rustle spot in `mossy_glade`), `src/server/World/Dressing.luau` (the log prop), `src/client/World/WorldView.luau`, `tests/world.test.luau`.

**Change:**
1. A sleepy Mossmitt model lying beside the path near stud 40. When the player comes close, it yawns, shuffles away and plays a tiny sound. Client-only flavour.
2. A "Hollow Log" rustle spot at about stud 60 in the Mossy Glade, with a spawn table of commons only (Mossmitt and Gorsling, existing weights, existing `rareColourChance`). The prompt reads "Look inside".
3. Do not change any capture number.

**Test:** `tests/world.test.luau` checks every rustle spot has spawns and a place. Add the new spot to its expectations.

**Studio:** walk the glade. Is the log easy to see from the path, and does it avoid the Pip fight at stud 100?

**Approval:** flag the Hollow Log. A new spawn table feeds capture rolls. No number changes, but the owner should know. The sleepy creature is client-only and needs no approval.

### WP11. The friend follows you (client only)

**Files:** new `src/client/World/FriendFollower.luau`, `src/client/Main.client.luau`.

**Change:** the first creature on the player's team appears as its model, a few studs behind, following with a short lag, and does a small hop when the player stops. It hides in battles (the stage uses the same models). Use a part count and update rate that suit a phone.

**Test:** none in Lune beyond a check that it only follows when a team exists. The cost is checked in Studio.

**Studio:** frame rate on a phone-sized view, and that it never blocks a door or the thumbstick.

**Approval:** none. Client-only. Check frame rate; the last note in `PROGRESS.md` warns about the cost of painted models.

### WP12. The shop welcome (a guided first choice)

**Files:** `src/client/Shop/ShopView.luau`, `src/content/tamer_data/Greenwood.luau` (Marlow's lines, if kept there).

**Change:** the first time the shop opens in a session, show one line from Marlow: "150 coins: ropes are 15, tonics 30. A Braided rope is 80. Your call!" (Prices read from `EconomyConfig.ITEMS`, not typed in.) No gift, no discount.

**Test:** a Lune test that the line uses the live prices.

**Studio:** open the shop on a phone. Does the line cover the stock?

**Approval:** none.

### WP13. The pacing tests

**Files:** new `tests/firstminutes.test.luau`.

**Change:** simulate the first rival battle for each starter with a spread of seeds and check the length is 3 to 7 turns. Simulate a lasso zone at full health, 40 percent and 20 percent health for a Common creature with a Basic rope, and check the widths against the numbers in section 3 (WP3). Use the shared battle code, not the client.

**Test:** `lune run check`.

**Studio:** none.

**Approval:** none. Tests only.

### WP14. Naming the friend (NEEDS APPROVAL)

**Files:** `src/shared/Types.luau` (a new `nickname` field), the save schema and a migration in `src/server/Data/*` and `src/shared/Profile.luau`, `src/net/Net.blink` (a rename message), `src/client/Creatures/CreaturesView.luau`, a new naming prompt in `StoryView.luau`.

**Why it needs approval:** it adds a field to saved data (a schema change and migration, rule 6), and any player-typed text must go through Roblox's text filter before others can see it. For ages 9 to 16 this is a policy point.

**What I recommend:** ask the owner first. If approved, name once, right after the pick, with a "Keep the real name" button, and filter on the server with `TextService`.

**Test (if approved):** a migration test, a filter test, a length test.

**Do not start without a yes from Ayrton.**

### WP15. A "pick one of two" gift (NEEDS APPROVAL, optional)

**Files:** `src/shared/StoryProgress.luau`, `src/net/Net.blink`, `src/content/story_data/Chapter1.luau`.

**What:** a later beat (for example Pip's thanks) lets the player choose between two rewards (a Braided rope or two tonics). Today only the first beat accepts a choice (`Starter` with `choices`). Extending it touches how rewards are paid and saved, so it needs approval. WP12 gives a no-approval version of "a choice that is mine".

---

## 4. Dialogue

Rules: at most three lines a beat, at most 90 characters a line, speakers are roles where the data uses roles. Every line below was counted and is 90 characters or fewer.

Where I changed a line, the old one is in brackets after it for comparison.

### Beat 1: Pick a friend (Mentor)

1. "Ah, you came! Welcome to Thistledown. The kettle is on."
2. "Three friends have been waiting on my porch for someone like you."
3. "Tap one to meet it. Each has a type, and types matter."

[Old: "Welcome! Three friends are waiting. Pick the one that feels right."]

### Beat 2: A challenge (Rival, Mentor)

1. Rival: "Hey, new kid! Nice pick. Mine beats yours, though. Just so you know."
2. Rival: "Come on, then. The green is plenty big for my grin and your nerves."
3. Mentor: "Go on. It is only a friendly bout. I will cheer. Quietly."

[Old: "Hey, new kid! I took the one that beats yours. Ready?" / "Go on. It is only a friendly bout."]

In `tamer_data/Greenwood.luau` the rival's `firstBefore` stays: "I picked the one that beats yours. Do not take it personally!" and `firstAfter` stays: "That was luck. Next time I will not lose to a beginner."

### Beat 3: A sore loser (Rival, Mentor)

1. Rival: "I lost?! To a beginner?! Rematch later. Much later. After snacks."
2. Rival: "Wait. What is that glint by your boot?"
3. Mentor: "Only a pebble. Come along. The lasso lesson is next."

[Old: "I lost to a beginner. I need more than luck... What is that glint?" / "Only a pebble. Come away. Let me show you the lasso."]

The glint thread is kept: the rival notices, the mentor evades.

### Beat 4: The lasso lesson (Mentor)

1. "Weaken it first. A tired creature is easy to catch. A fresh one is not."
2. "Tap THROW when the marker crosses the green. Do not rush it."
3. "Ropes and tonics, on me. And a Gorsling to keep you company."

[Old: "Weaken it first, then throw when the ring sits on the target." / "That one will not slip away. Take these ropes and tonics, on me." The screen has a marker and a green zone, not a ring.]

### Beat 5: Out on Route A (Mentor)

1. "Clover Lane! Walk the long grass and something will find you."
2. "Hurts last out here. Lead with whoever is freshest. Healing in town is free."
3. "Ropes run out. Tuppence sells more, if your pockets allow."

[Old: "Battle what you find. Spend your coins at Tuppence's shop." The healer advice is kept as written, since it fixed a real robot-player problem.]

### Beat: A team of three (Mentor), moved earlier by WP6

1. "Look at that! Three on your team, and one you earned yourself."

[Old: "Three on your team. Now that is a proper tamer."]

### Beat: A local tamer (Pip)

1. "Whoa! The hat has never lost before. Weaken them, then throw the rope."

In `tamer_data/Greenwood.luau`, Pip's `after` becomes the same line. His `before` stays: "My hat is lucky! One battle, then you can walk on."

### Beat: The tree that walks (Mentor)

1. "See that huge tree in the haze? Stay clear of it for now."
2. "Promise me. Some things are best left asleep."
3. "I have something for you at the cottage. Come when you are ready."

[Old had two lines. The third gives the walk back a reason.]

### Beat: The mentor's egg (Mentor)

1. "Watch how two of mine mix their parts. This egg is yours."
2. "Keep it in a pen. Open Creatures to see how it is doing."
3. "Do not ask what you must be strong for. Just be ready."

[Old line 2: "Breeding is how you grow strong. Come back when it hatches." The new line says where to look. The third line is unchanged on purpose: it is the mentor's first hint that he is hiding something.]

### Beat: Thistledown favours (Marlow)

1. "Heard you have an egg! Win a few scraps on Clover Lane and I will stock you up."
2. "River Road is open now, if you feel brave. Mind the herons."

[Old line 1: "Got a minute? Win a few scraps on Clover Lane and I will pay you."]

### Coach and system lines (not story beats)

These are text in the battle box and notices. Each is 90 characters or fewer.

- First battle start: "Pick FIGHT, then a move. The bright ones say STRONG."
- After a STRONG hit: "STRONG! That is how you win fights."
- First wild fight: "Win it over first. When its health is low, choose LASSO."
- At 40 percent health: "It is tired now. Time to throw!"
- Lasso bar note: "Tired creatures leave a wide green."
- After a miss: "It slipped the rope. It will not run off. Try again!"
- Egg given: "Your egg is in a pen. Tap Creatures to peek."
- Hatch: "Your egg hatched! Open Creatures to meet it."

### Starter blurbs (WP5 and WP4), at most 60 characters each

- Mossmitt: "Soft as a cushion. Loves a sunny patch of clover."
- Spadesnout: "Digs up everything. Proud of every single hole."
- Sloshcalf: "Carries a tiny pond on its back. Please do not tip it."

### Wild species blurbs (WP4), at most 60 characters each

- Gorsling: "Quick on its feet, and quicker with an opinion."
- Splashjack: "Never met a puddle it did not want to jump in."
- Stumpwarden: "Stands very still. You will never win a staring contest."
- Stiltbark: "Tall, shy and pretending to be a reed."
- Burlhorn: "Heavy, slow and gentle. Mind the knobbly horns."

These blurbs are my wording and need Ayrton's ear.

---

## 5. Risks, and what a person must playtest

### Risks

1. **The reorder (WP6) can break tests.** Beat order, minute targets and flags are pinned in `tests/world.test.luau`, `tests/story.test.luau`, `tests/trainers.test.luau`, `tests/quests.test.luau` and the playthrough robots. The builder must update them, not loosen them.
2. **The hatch may land after 15:00.** The egg arrives at about minute 11 to 13 and hatches 3 minutes later. If it must land inside the first 15 minutes, either shorten `BreedConfig.GIFT_EGG_SECONDS` (a breeding config, so flag it) or give the egg before Pip. Ayrton should choose.
3. **A strict story order can feel like a wall.** The `third_creature` beat now waits for a catch before Pip, the tree and the egg count. A player who cannot catch is stuck. The coach (WP3) and the "it will not run off" line are the cure, but a person must check a nervous 9-year-old can get through.
4. **The first fight could be dull or unfair.** The rival counter-picks, and the player is level 5 against level 4. I have not checked each starter's moves, so the "STRONG" coach could be false. Check with the Lune pacing test and by hand.
5. **The hatched child may look wrong.** Hatchlings mix parts from different species. The eight Greenwood models are painted, but mixed-part children use whatever fallback exists. This is the finale and was not checked.
6. **Phone cost.** The village already carries painted models. A following friend (WP11) and a camera moment (WP9) add cost. Test on a real phone.
7. **Text on small screens.** Longer lines, the title card and the extra buttons must fit a phone view. Check every package at phone size.
8. **Policy and approval.** WP14 (nicknames) and WP15 (choice gifts) must not be built without the owner. WP10's Hollow Log touches spawn tables, which feed capture rolls. Say so in `PROGRESS.md`.
9. **The Creatures count is not a real book.** "Friends 4 of 8" counts what the player owns now. If they release a creature the count falls. That is honest for a first cut, but a person should decide whether it is enough.

### What a person must playtest

Robots cannot judge feel. Ayrton, or a child of 9 to 13 if possible, should play from a brand-new profile on a phone with nobody helping, and the observer should say nothing.

Watch for:
- **0:00 to 2:00.** Do they read the mentor's lines or tap through? Do they hesitate over the three cards? Do they say anything about their pick?
- **First battle.** Do they understand FIGHT, and do they notice STRONG? Does it end in under 90 seconds? Do they smile when the rival loses?
- **Lasso.** Do they throw at full health? How many ropes do they spend? Do they notice the pulse and the wide green? Is the catch card a moment?
- **Route A.** Do they find the Hollow Log and the sleepy creature, or walk past?
- **The tree.** Do they stop and look?
- **The egg.** Do they open Creatures on their own? Do they come back when it hatches?
- **15:00.** Ask: "What would you do next?" and "What are you looking forward to?" If the answer is "nothing", the hook failed.

Record for each player: minutes to reach each beat (the server already logs `StoryBeat` with `minute`), the number of lasso throws, the number of failed throws, and where they stopped. Compare to the targets in section 1.

### Questions for Ayrton

1. Is the new beat order (catch before Pip, egg after the glimpse) acceptable? (WP6)
2. May the Hollow Log add a spawn table? (WP10)
3. Do you want nicknames, given the filtering and saving work they need? (WP14)
4. Should the first egg hatch inside 15 minutes, even if that means shortening the egg timer? (Risk 2)
5. Do the blurbs sound like your game?

---
