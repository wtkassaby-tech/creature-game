# Creature personality

One personality per species, so no two are the same temperament doing the same gesture. The numbers and names that the game reads are data in `src/content/SpeciesQuirks.luau`; the motion behind each gesture and entrance is `src/shared/Gestures.luau`. This page is the design behind them: why you want each creature, what it does that you can see, and what it sounds like. Tone: funny and warm, safe for all ages. Everything is original; no franchise creature's gimmick is borrowed.

Where the player reads it later: the journal facts and the favourite go on the Creatures detail panel (a "Journal" section under the blurb) and in the New friend card; the rare look goes in the collection/Journal page as a silhouette to chase. Nothing is wired yet.

Gesture key: Hop, Wiggle, Spin, Nod, Shiver, Stretch, Sniff, Bounce, Sway, Puff, Peek, Doze, Shake, Clap, Tilt, Gulp (descriptions in the header of `SpeciesQuirks.luau`). "Model" says whether the current generated model already shows the quirk; a regeneration prompt is given where it does not. The prefix for every prompt is: *cozy handmade clay toy, soft matte plasticine, chunky rounded proportions, big friendly eyes, simple flat colours, original creature, no clothing or held objects, full body, neutral standing pose*.

## At a glance

| Species | Temperament | Gesture | Quirk you can see |
| --- | --- | --- | --- |
| Mossmitt | cheerful show-off | Bounce | boxer's bounce, moss mitts puff spores |
| Spadesnout | fiercely proud | Sniff | sniffs the ground, then a proud chest |
| Sloshcalf | gentle worrier | Tilt | tips to check its pond is level |
| Gorsling | twitchy chatterbox | Shiver | trembles, sheds yellow blossom |
| Splashjack | giddy puddle-lover | Hop | double hop, feet slap a half-beat early |
| Stumpwarden | stoic, secretly ticklish | Nod | one slow nod, then a tiny leaf-twitch |
| Stiltbark | jumpy pretender | Peek | ducks low, "pretends" to be a reed |
| Burlhorn | sleepy grump | Doze | droops asleep, snorts awake |
| Hollowbough | absent-minded elder | Sway | slow creaking sway, owls shuffle |
| Duneskit | cocky racer | Stretch | sprinter's stretch, ears snap flat |
| Whirlgrit | joyful twirler | Spin | full spin, a ring of sand lifts |
| Flintknap | fussy perfectionist | Wiggle | wiggles its arms, inspects its blades |
| Wadibuck | skittish dreamer | Shiver | shivers, horns drip |
| Spurlet | sun-drunk loafer | Doze | melts flat in the sun, blinks awake |
| Thatchling | friendly waver | Sway | sways, waves both pompoms |
| Cairnback | patient guide | Nod | nods at the trail ahead, stones clink |
| Spirecap | dignified wobbler | Stretch | grows tall, steadies its capstone |
| Mesalith | serene giant | Shake | shakes dust off its strata |
| Glissot | breathless speedster | Bounce | jogs on the spot |
| Clapshell | proud applause-seeker | Clap | claps its shell hands twice |
| Cocklemole | busy digger | Sniff | sniffs the sand, wonky shell hat |
| Gulpmaw | hopeful optimist | Gulp | swells, then swallows with a smile |
| Runnelfin | natural dancer | Hop | a two-step dance, fin crest flicks |
| Moatkeep | fussy homebody | Wiggle | shuffles, tidies its walls |
| Hullock | wise old salt | Sway | rocks like a boat on dry land |
| Lanternell | gentle night-watcher | Puff | its lamp swells and glows |
| Carrackon | grand hermit | Peek | tucks into its ship, pops back out |
| Fenwhisk | smug sneak | Stretch | cat stretch, tail flag held high |
| Skipslick | hyper show-off | Bounce | rapid lily-pad bounce |
| Keelsnap | grumpy-sweet | Shake | huffy shake, mud cracks off |
| Snaggar | grinning ambusher | Tilt | head tilt with a far-too-wide grin |
| Bogbellow | jolly glutton | Puff | inflates, belches a green puff |
| Bulbroth | fussy cook | Shiver | belly bubbles shiver |
| Lilyshade | serene and aloof | Sway | slow drift, mist trails |
| Mistrel | shy mist-hider | Peek | sinks into its own fog, peeks out |
| Sloughback | ancient sleeper | Doze | the slowest droop in the game |

## The eight models that most need a regeneration for personality

Keelsnap, Stiltbark, Gorsling, Stumpwarden, Burlhorn, Moatkeep, Mistrel and Spurlet. Each has a face or silhouette cue that the quirk depends on and a plain model does not give (details and prompts below). The rest already read well from their species Look, or need only motion.

## Greenwood

**Mossmitt.** Hook: the little champion you cannot help rooting for. Temperament: cheerful show-off. Quirk: bobs on its toes like a boxer, moss mitts puffing spores when proud. Gesture: Bounce, every 7 s. Cry: a quick high "ha-HAH" (two bright notes, close together). Entrance: HopIn, lands and throws two jabs. Facts: "Shadow-boxes before every nap. Has never once beaten the shadow." / "Its moss mitts puff a little cloud of spores when it is proud." Favourite: a clover patch in the morning sun. Rare look: Blossom, pink-flowered mitts and a white clover tuft. Model: shows the mitts; the bounce is motion.

**Spadesnout.** Hook: it digs up a treat and is so proud you want to praise it. Temperament: fiercely proud. Quirk: sniffs the ground and puffs its chest at every hole. Gesture: Sniff, every 9 s. Cry: a low, gruff "hrm-hrm-hrm", three even notes. Entrance: PopUp, bursting out of the ground. Facts: "Names every hole it digs. Nobody has heard the names." / "Will rebury a gift of its own treasure just to show you where it is." Favourite: fresh mud on a riverbank. Rare look: Gilded, a brass shovel snout. Model: shows the snout; motion carries the rest.

**Sloshcalf.** Hook: the pond on its back has tiny fish in it. Temperament: gentle worrier. Quirk: tilts to check its pond is level and the water sloshes in the bubble. Gesture: Tilt, every 8 s. Cry: a soft, low "moo-oo", two notes with a slow gap. Entrance: SlideIn, very carefully. Facts: "The tiny fish in its back pond have never once complained about the ride." / "Walks slower on windy days. The pond gets seasick." Favourite: a drizzly morning. Rare look: Sunset Pond, orange water with a slow pink glow. Model: shows the pond bubble.

**Gorsling.** Hook: the chatterbox of the meadow that cannot keep still. Temperament: twitchy chatterbox. Quirk: trembles with excitement, shedding yellow blossom. Gesture: Shiver, every 6 s. Cry: five tiny rapid squeaks, high. Entrance: DropIn from a hedge, all legs. Facts: "Talks in its sleep, mostly to the hedge, mostly about hedges." / "Sheds yellow blossom when it gets excited. The meadow is thick with it." Favourite: a gap in a hedge, just wide enough. Rare look: Snowblossom, white petals. Model: partly; the blossom shed and the wide, darting eyes are not on the mesh.
*Regeneration prompt:* PREFIX + "a whip-thin four-legged hedge runner with huge wide-open darting eyes, long twitchy ears, a scruff of yellow blossom petals along its back, a worried, excited little mouth".

**Splashjack.** Hook: it has never met a puddle it did not want to jump in. Temperament: giddy puddle-lover. Quirk: a double hop, with its paddle feet slapping a half-beat early. Gesture: Hop, every 7 s. Cry: three excited "wup-wup-wup". Entrance: DropIn as a cannonball. Facts: "Has never walked around a puddle. It does not know the word around." / "Its big paddle feet slap in time to the rain, a half beat early." Favourite: the biggest puddle after a storm. Rare look: Puddle Moon, silver-blue with ripple rings. Model: shows the paddle feet.

**Stumpwarden.** Hook: it nods once and you feel chosen. Temperament: stoic, secretly ticklish. Quirk: perfectly still, apart from one leaf that twitches. Gesture: Nod, every 12 s. Cry: one very deep "hmmm". Entrance: Stomp, planting itself in the path. Facts: "Nods once an hour. That is its whole conversation, and it means a lot." / "The one place it is ticklish is a secret. A bird knows. The bird will not say." Favourite: standing in the exact middle of a path. Rare look: Heartwood, red-gold bark and pale mushrooms. Model: no; it reads grumpy, not stoic-with-a-secret.
*Regeneration prompt:* PREFIX + "a squat living tree stump creature with a calm, half-lidded, patient face, one single bright green leaf sprouting from the top, a ring of small pale mushrooms around its base, thick short root legs".

**Stiltbark.** Hook: it thinks it is invisible and it is not. Temperament: jumpy pretender. Quirk: ducks and freezes, believing it passes as a reed. Gesture: Peek, every 8 s. Cry: two high, startled "eep" notes. Entrance: PopUp from the reeds, then freezes. Facts: "Believes it looks exactly like a reed. It does not. Please do not tell it." / "Freezes mid-stride when you look at it, one foot in the air, for ages." Favourite: a thick bed of reeds at dusk. Rare look: Birchwhite, silver bark with black freckles. Model: no; there is nothing on it that sells the reed disguise.
*Regeneration prompt:* PREFIX + "a tall nervous bird-like wader on thin birch-twig stilts, a few reed stalks and cattail fluff stuck proudly on top of its head as a disguise, huge anxious eyes, a long thin neck".

**Burlhorn.** Hook: the biggest, softest grump; everyone leans on it. Temperament: sleepy grump. Quirk: nods off mid-stride and snorts itself awake. Gesture: Doze, every 10 s. Cry: a low, long "mmmrf", two notes. Entrance: SlideIn, as if it was dragged from bed. Facts: "Grumbles when woken, then lets you lean on it for the rest of the day." / "Small flowers grow in the knots of its burl. It pretends not to notice." Favourite: a warm rock and no company. Rare look: Flowering Burl, a bloom-covered back. Model: partly; the burl shows, but no flowers and the face is neutral.
*Regeneration prompt:* PREFIX + "a heavy four-legged grazer with a big knotted wooden burl on its back with a few tiny pink flowers growing out of the knots, droopy heavy-lidded sleepy eyes, a small grumpy frown, short curved horns".

**Hollowbough.** Hook: a walking tree with owls inside it. Temperament: absent-minded elder. Quirk: sways slowly and creaks, an owl shuffling in its hollow. Gesture: Sway, every 11 s. Cry: a long creak and two deep wooden knocks. Entrance: Stomp, with a rain of leaves. Facts: "Forgets it is carrying an owl family. Apologises to them by creaking." / "Takes one step a minute so nothing in its branches is ever startled." Favourite: the first light through its own leaves. Rare look: Autumn Crown, gold and crimson leaves all year. Model: shows the tree; sway is motion.

## Dust Canyon

**Duneskit.** Hook: the fastest thing in the canyon, and it tells you so. Temperament: cocky racer. Quirk: stretches like a sprinter, ears snapping flat. Gesture: Stretch, every 7 s. Cry: a fast four-note "ti-ti-ti-TIK". Entrance: SlideIn, skidding to a stop. Facts: "Races its own shadow every noon. Insists the shadow cheats." / "Its tall ears snap flat when it runs. It thinks that is what makes it fast." Favourite: a long empty dune and a head wind. Rare look: Moondune, pale blue fur and silver ears. Model: shows the ears.

**Whirlgrit.** Hook: pure joy; you want to spin with it. Temperament: joyful twirler. Quirk: spins in place and a ring of sand lifts. Gesture: Spin, every 6 s. Cry: a bright rising four-note trill. Entrance: SpinIn. Facts: "Spins when happy. Gets dizzy when happier. Keeps spinning anyway." / "The ring of sand it lifts is never quite the same shape twice." Favourite: a dry breeze at sunrise. Rare look: Dust Devil, a swirl-patterned body. Model: shows the dancer body.

**Flintknap.** Hook: the fussy craftsman; you will watch it sharpen. Temperament: fussy perfectionist. Quirk: wiggles its arms, then inspects its blades with a frown. Gesture: Wiggle, every 9 s. Cry: three crisp "tik-tik-tak" clicks. Entrance: Stomp, then a quick blade check. Facts: "Re-sharpens a blade that was already sharp. Then checks it. Then again." / "Sparks fly when it is nervous. It is nervous quite often." Favourite: a smooth canyon wall. Rare look: Obsidian, glossy black blades with a red edge. Model: shows the blades.

**Wadibuck.** Hook: it hums before the rain and you want to learn the song. Temperament: skittish dreamer. Quirk: trembles, horns dripping. Gesture: Shiver, every 8 s. Cry: two high, wistful notes with a long gap. Entrance: HopIn, ready to bolt. Facts: "Hums when it is about to rain. Nobody knows which song." / "Starts at every shadow, but sleeps through thunder. Nobody knows that either." Favourite: the first drop of a flash flood. Rare look: Rainbow Horn, horns that glint every colour when wet. Model: shows the horns.

**Spurlet.** Hook: a sleepy plant that blooms once a year, by itself. Temperament: sun-drunk loafer. Quirk: melts flat in the sun, blinks awake with a wobble. Gesture: Doze, every 12 s. Cry: one soft, happy sigh. Entrance: SlideIn, scuttling low between shadows. Facts: "Flowers once a year, always when nobody is watching, and only for a minute." / "Wakes at dusk for a quiet scuttle. It is a different, braver creature then." Favourite: a flat warm stone at noon. Rare look: Night Bloom, deep purple with glowing white spines. Model: no; it reads plain, with no sleepy face and no flower bud.
*Regeneration prompt:* PREFIX + "a low, flat, round succulent creature with blissful closed happy eyes, a content smile, a single small closed flower bud on top, soft rounded spines, six tiny feet".

**Thatchling.** Hook: it waves at you first, always. Temperament: friendly waver. Quirk: sways and waves both pompoms. Gesture: Sway, every 7 s. Cry: three cheery "hi-hi-hiii" notes. Entrance: HopIn, waving. Facts: "Waves both pompoms at everything: friends, rocks, the sun, other Thatchlings." / "Its leaf skirt rustles a different tune every season." Favourite: a visitor, any visitor. Rare look: Spring Skirt, fresh green leaves and pink pompoms. Model: shows the pompoms and skirt.

**Cairnback.** Hook: the walking trail guide. Temperament: patient guide. Quirk: nods toward the trail ahead, stones clinking. Gesture: Nod, every 11 s. Cry: two low stone "tok-tok" knocks. Entrance: DropIn, stones settling. Facts: "Adds one small stone to its back every year, and says where it found each." / "Never loses the trail. Has lost an argument about where the trail goes." Favourite: a trail marker someone left tidy. Rare look: Sunstack, warm orange stones and a white capstone. Model: shows the stacked stones.

**Spirecap.** Hook: it balances a rock on its head and takes it seriously. Temperament: dignified wobbler. Quirk: stretches tall and steadies its capstone. Gesture: Stretch, every 10 s. Cry: one clear, held note like a bell. Entrance: PopUp, rising solemnly. Facts: "Keeps a flat stone on its head all day and is terribly proud of the balance." / "Very slightly leans toward whoever is talking, as if it is all news to it." Favourite: a perfectly still evening. Rare look: Twilight Spire, purple stone with a gold cap. Model: shows the capstone.

**Mesalith.** Hook: a whole mesa you can befriend. Temperament: serene giant. Quirk: shakes dust off its strata, small plants and all. Gesture: Shake, every 14 s. Cry: a very low rumble in two notes. Entrance: Stomp, dust billowing. Facts: "Small plants have moved onto its back. It walks carefully, for their sake." / "Sleeps standing and dreams in slow red colours, or so its visitors say." Favourite: a long sunset over the flat country. Rare look: Ember Mesa, glowing orange stripes. Model: shows the strata.

## Tide Flats

**Glissot.** Hook: it cannot hold still, and it is catching. Temperament: breathless speedster. Quirk: jogs on the spot while waiting. Gesture: Bounce, every 6 s. Cry: three very high, fast chirps. Entrance: SlideIn, a skid across wet sand. Facts: "Cannot stand still. Runs on the spot while it waits for a wave." / "Leaves a dry footprint trail on wet sand. Nobody knows how." Favourite: a falling tide, wide and flat. Rare look: Pearl Streak, a pearly belly and turquoise stripes. Model: shows the sleek body.

**Clapshell.** Hook: it claps for you. Temperament: proud applause-seeker. Quirk: claps its shell hands twice and waits for you to do the same. Gesture: Clap, every 8 s. Cry: two shell "clack" notes. Entrance: HopIn, landing with a clap. Facts: "Claps for itself after every move. Claps for you too, if you are polite." / "Has a different clap for sad, happy and snack. Only the last one is loud." Favourite: an audience of three or more. Rare look: Gold Scallop, golden shell hands with a pink rim. Model: shows the shell hands.

**Cocklemole.** Hook: it wears its helmet crooked and will not fix it. Temperament: busy digger. Quirk: sniffs the sand and digs, the shell hat wobbling. Gesture: Sniff, every 7 s. Cry: four quick chirrups. Entrance: PopUp out of the sand. Facts: "Digs for the joy of it, then forgets where it started and digs back." / "Wears its cockle shell crooked and will not let anybody fix it." Favourite: a patch of soft, wet sand. Rare look: Rosepearl, a pink shell with a pearl sheen. Model: shows the shell.

**Gulpmaw.** Hook: the eternal optimist with the enormous mouth. Temperament: hopeful optimist. Quirk: swells and swallows with a delighted smile. Gesture: Gulp, every 9 s. Cry: one deep "gloop". Entrance: DropIn with its mouth open. Facts: "Sits with its mouth open all day. Once in a while, the sea says thank you." / "Has swallowed a lot of rocks hoping they were snacks. It stays upbeat." Favourite: a rock pool full of passing snacks. Rare look: Coral Maw, a coral-red mouth. Model: shows the mouth.

**Runnelfin.** Hook: it dances for the sunset and does not care who watches. Temperament: natural dancer. Quirk: a two-step hop, fin crest flicking. Gesture: Hop, every 6 s. Cry: four lilting notes like a tune. Entrance: SpinIn. Facts: "Dances in every runnel the tide leaves, and never the same dance twice." / "Flicks its fin crest to the beat of a song only it can hear." Favourite: a glittery shallow runnel at sunset. Rare look: Opal Crest, an iridescent fin crest. Model: shows the crest.

**Moatkeep.** Hook: a sandcastle that keeps fixing itself and grumbling. Temperament: fussy homebody. Quirk: shuffles and pats its walls straight, a tiny flag atop. Gesture: Wiggle, every 10 s. Cry: two small, grumbly "tsk" notes. Entrance: DropIn, as if rebuilt on the spot. Facts: "Rebuilds its walls after every wave and complains about it the whole time." / "Has a tiny flag on its tallest tower. It changes the flag daily." Favourite: damp sand that packs just right. Rare look: Pink Castle, pink sand towers with a golden flag. Model: partly; the castle shape shows but a fussy face and the flag do not.
*Regeneration prompt:* PREFIX + "a squat little sandcastle creature with crenellated walls, one crooked tower with a tiny flag on top, a fussy, put-upon frown and tired eyes, short stubby legs".

**Hullock.** Hook: the friendly old boat of the shore. Temperament: wise old salt. Quirk: rocks gently like a boat on dry land. Gesture: Sway, every 11 s. Cry: a low foghorn, two notes. Entrance: SlideIn like a ship into harbour. Facts: "Rocks gently in place even on dry land, as if the beach were a swell." / "Barnacles on its back have been there so long they have names and opinions." Favourite: a long, slow tide coming in. Rare look: Weathered Teal, a sea-green hull with white barnacles. Model: shows the hull.

**Lanternell.** Hook: its lamp is a friendly light in the dark. Temperament: gentle night-watcher. Quirk: its lamp swells and glows softly. Gesture: Puff, every 10 s. Cry: three soft, humming notes. Entrance: PopUp, glowing. Facts: "Glows brighter when someone is lost. Glows dimmer when they are found." / "Hums lullabies to the little creatures in the rock pools. They never nap." Favourite: a dark, still, starry evening. Rare look: Moonlamp, a cool blue-white lantern. Model: shows the lantern head; the glow is a later light effect.

**Carrackon.** Hook: it wears a whole ship and acts like a king. Temperament: grand hermit. Quirk: tucks into the ship and pops back out with great dignity. Gesture: Peek, every 13 s. Cry: a deep ship's horn, three slow notes. Entrance: Stomp, solemnly. Facts: "Has never taken its ship off. Rumour says it lost the key years ago." / "Dips its mast to every passing creature, and expects it back." Favourite: a sheltered bay with a fresh breeze. Rare look: Ghost Galleon, a pale blue ship with glowing sails. Model: shows the ship.

## The Mire

**Fenwhisk.** Hook: so pleased with itself you cannot stay cross. Temperament: smug sneak. Quirk: a cat stretch with its bulrush tail up like a flag. Gesture: Stretch, every 8 s. Cry: two smooth, purring notes. Entrance: SlideIn, as if it owns the place. Facts: "Carries its tail like a flag, so everybody knows exactly where it is hiding." / "Says it is bored. Is sitting in the best reed bed by a wide margin." Favourite: the tallest reed bed in the marsh. Rare look: Silver Whisker, silver fur with a white-tipped tail. Model: shows the tail.

**Skipslick.** Hook: a tiny showman who brags about every jump. Temperament: hyper show-off. Quirk: bounces rapidly, keeping score. Gesture: Bounce, every 6 s. Cry: three bright "ribbit-bip-bip" notes. Entrance: HopIn, arms up. Facts: "Crosses every pond in as few lily pads as it can. Keeps a score." / "Its warning colours are a bluff. It would never bite. It would tell a joke." Favourite: a long row of floating lily pads. Rare look: Neon Frog, bright blue skin with orange spots. Model: shows the colours.

**Keelsnap.** Hook: the grumpy one who secretly likes you; earning its trust is the joy. Temperament: grumpy-sweet. Quirk: huffs and shakes the mud off, then looks away pleased. Gesture: Shake, every 9 s. Cry: a short, cross "krk-krk". Entrance: Stomp, glaring. Facts: "Snaps at everyone. Brings a flat stone to the one it likes, and never says so." / "Dried mud on its shell cracks when it is pleased. It pretends it is the heat." Favourite: a muddy bank with nobody on it, except you. Rare look: Mossback Keel, a green mossy shell. Model: no; it reads only grumpy.
*Regeneration prompt:* PREFIX + "a hunched snapping-turtle creature with a hooked beak turned down in a grumpy frown but soft, shiny, kind eyes, a mud-caked shell with a few cracks and one tiny green sprout in a crack, stubby arms".

**Snaggar.** Hook: it smiles at everything, and the smile is the scary part. Temperament: grinning ambusher. Quirk: tilts its head with a far-too-wide, friendly grin. Gesture: Tilt, every 10 s. Cry: three low, slow clicks. Entrance: PopUp from the water. Facts: "Smiles with every tooth at once. It means well. Mostly it means hello." / "Lies so still that birds have built a nest on its back. It lets them." Favourite: a patch of warm shallow water under the roots. Rare look: Golden Gar, an amber snout with ivory teeth. Model: shows the jaws.

**Bogbellow.** Hook: a belching, warm, laughing heap. Temperament: jolly glutton. Quirk: inflates, then belches a green puff, delighted. Gesture: Puff, every 8 s. Cry: a deep, rumbly two-note laugh. Entrance: DropIn, thudding. Facts: "Belches when it laughs, which is often, which is why the marsh smells." / "Its peat mound is warm. Small creatures sleep on it and are never disturbed." Favourite: a warm peat bath. Rare look: Ember Peat, a back that glows like banked coals. Model: shows the vents.

**Bulbroth.** Hook: a cook whose soup you never get to taste. Temperament: fussy cook. Quirk: the belly bubbles and shivers. Gesture: Shiver, every 9 s. Cry: four bubbly "blup" notes. Entrance: SlideIn, stirring. Facts: "Tastes its own belly every morning and adds a pinch of something." / "The broth is never the same twice. Nobody has dared a spoon." Favourite: a slow simmer at dawn. Rare look: Golden Broth, a honey-yellow belly. Model: shows the belly.

**Lilyshade.** Hook: calm and cool; you feel better beside it. Temperament: serene and aloof. Quirk: drifts in a slow sway, mist trailing. Gesture: Sway, every 12 s. Cry: two clear, calm notes, far apart. Entrance: PopUp out of a mist. Facts: "Has never been seen hurrying. It arrives anyway, a little cool and early." / "Its lily pad hat blooms once a year, and it will not say what it wished." Favourite: a still pond under a wide sky. Rare look: White Lotus, a lotus bloom on its hat. Model: shows the lily pad hat.

**Mistrel.** Hook: it hides in fog it made, and picks only one friend. Temperament: shy mist-hider. Quirk: sinks behind its own fog and peeks out. Gesture: Peek, every 9 s. Cry: a soft three-note hoot, trailing off. Entrance: SlideIn out of fog. Facts: "Blows its own fog to hide in. Is visibly proud of the fog." / "Comes out of hiding for exactly one person, and takes a long time to pick." Favourite: a cold dawn with plenty of fog. Rare look: Silver Fog, silver moss with a faint glow. Model: no; it reads sturdy and unbothered, with no shyness.
*Regeneration prompt:* PREFIX + "a stocky swamp tapir draped in hanging green moss, big shy downcast eyes peeking out from under the moss fringe, a short trunk curling up softly as if hiding a smile, small drooped ears".

**Sloughback.** Hook: the biggest sleepy thing; you hope to be there when it wakes. Temperament: ancient sleeper. Quirk: the slowest droop in the game, then a very late start. Gesture: Doze, every 14 s. Cry: one single deep, slow note. Entrance: Stomp. Facts: "Slept through three floods and a very loud wedding. Was not sorry." / "Moss grows in the grooves of its shell, one slow green year at a time." Favourite: a long, deep, undisturbed sleep. Rare look: Old Grove, a silver-green shell with white blossoms. Model: shows the shell.

## Notes for the lead

- Gesture times are in the data (`gestureEvery`, 6 to 14 s); add a small random jitter and only play one when the creature is idle and visible.
- Rare looks are colour variants only (a tint or texture swap); they are not gem, ruby or diamond rarity and not sold for Robux. Whether and how they are earned is for Ayrton to decide, because it touches drops (and that is an approved-plan area before any build).
- Cries are described by pitch (1 is the sound's own pitch), note count and gap; the audio layer still needs sound assets chosen for them.
