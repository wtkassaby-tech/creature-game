--!strict
-- What makes each creature itself: a temperament, an idle gesture it does every so often, a cry,
-- a battle entrance, two journal facts, a favourite thing and a rare colour look. Data only.
-- The design behind every line is in docs/content/CREATURE_PERSONALITY.md.
--
-- Gesture and entrance names are played by src/shared/Gestures.luau, each one a motion of a
-- single mesh (an offset, a tilt and a scale over time). The gestures:
--   Hop      two small jumps in place (glad, springy)
--   Wiggle   a quick side-to-side shimmy of the whole body
--   Spin     one full turn about the feet
--   Nod      a slow nod forward and back, once or twice
--   Shiver   a fast tremble (nerves, cold, excitement)
--   Stretch  rises tall on its toes, then settles, like a stretch after a nap
--   Sniff    leans forward and bobs the front down to the ground, twice
--   Bounce   a rhythmic bob with a little squash and stretch (a boxer's bounce)
--   Sway     a slow lean from one side to the other
--   Puff     inflates a little, holds it, lets the air out
--   Peek     sinks low as if hiding, then pops up again
--   Doze     a slow droop toward sleep, then a start awake
--   Shake    a shake-off, like a dog out of water
--   Clap     two quick squashes, like a clap
--   Tilt     a curious tip of the whole body to one side, held a moment
--   Gulp     a swell upward, then a swallow-squash
-- The entrances (how it arrives in a battle):
--   HopIn    arcs in from a little way off in a hop and lands
--   SpinIn   spins in from nothing, growing as it turns
--   PopUp    pops up from below the ground with a spring
--   Stomp    drops a little, lands heavy and settles with a rumble of a bounce
--   SlideIn  skids in low from the side and rocks to a stop
--   DropIn   falls from above and squashes on landing
-- A cry is a run of `notes` short sounds at `pitch` (1 is the sound's own pitch, higher is
-- higher), `gap` seconds apart; the audio layer shapes the notes from these three numbers.

export type Gesture =
	"Hop"
	| "Wiggle"
	| "Spin"
	| "Nod"
	| "Shiver"
	| "Stretch"
	| "Sniff"
	| "Bounce"
	| "Sway"
	| "Puff"
	| "Peek"
	| "Doze"
	| "Shake"
	| "Clap"
	| "Tilt"
	| "Gulp"

export type Entrance = "HopIn" | "SpinIn" | "PopUp" | "Stomp" | "SlideIn" | "DropIn"

export type Cry = { pitch: number, notes: number, gap: number }

export type Quirk = {
	temperament: string,
	gesture: Gesture,
	gestureEvery: number, -- seconds between gestures, roughly 6 to 14
	cry: Cry,
	entrance: Entrance,
	facts: { string }, -- journal lines: one or two, each under 90 characters
	favourite: string,
	rareLook: string,
}

local SpeciesQuirks: { [string]: Quirk } = {
	-- Greenwood
	Mossmitt = {
		temperament = "cheerful show-off",
		gesture = "Bounce",
		gestureEvery = 7,
		cry = { pitch = 1.3, notes = 2, gap = 0.12 },
		entrance = "HopIn",
		facts = {
			"Shadow-boxes before every nap. Has never once beaten the shadow.",
			"Its moss mitts puff a little cloud of spores when it is proud.",
		},
		favourite = "a clover patch in the morning sun",
		rareLook = "Blossom: pink-flowered moss mitts and a white clover tuft",
	},
	Spadesnout = {
		temperament = "fiercely proud",
		gesture = "Sniff",
		gestureEvery = 9,
		cry = { pitch = 0.8, notes = 3, gap = 0.1 },
		entrance = "PopUp",
		facts = {
			"Names every hole it digs. Nobody has heard the names.",
			"Will rebury a gift of its own treasure just to show you where it is.",
		},
		favourite = "fresh mud on a riverbank",
		rareLook = "Gilded: a shovel snout the colour of polished brass",
	},
	Sloshcalf = {
		temperament = "gentle worrier",
		gesture = "Tilt",
		gestureEvery = 8,
		cry = { pitch = 0.9, notes = 2, gap = 0.3 },
		entrance = "SlideIn",
		facts = {
			"The tiny fish in its back pond have never once complained about the ride.",
			"Walks slower on windy days. The pond gets seasick.",
		},
		favourite = "a drizzly morning",
		rareLook = "Sunset Pond: orange water with a slow pink glow",
	},
	Gorsling = {
		temperament = "twitchy chatterbox",
		gesture = "Shiver",
		gestureEvery = 6,
		cry = { pitch = 1.7, notes = 5, gap = 0.06 },
		entrance = "DropIn",
		facts = {
			"Talks in its sleep, mostly to the hedge, mostly about hedges.",
			"Sheds yellow blossom when it gets excited. The meadow is thick with it.",
		},
		favourite = "a gap in a hedge, just wide enough",
		rareLook = "Snowblossom: white petals instead of yellow",
	},
	Splashjack = {
		temperament = "giddy puddle-lover",
		gesture = "Hop",
		gestureEvery = 7,
		cry = { pitch = 1.4, notes = 3, gap = 0.1 },
		entrance = "DropIn",
		facts = {
			"Has never walked around a puddle. It does not know the word around.",
			"Its big paddle feet slap in time to the rain, a half beat early.",
		},
		favourite = "the biggest puddle after a storm",
		rareLook = "Puddle Moon: silver-blue skin with ripple-ring markings",
	},
	Stumpwarden = {
		temperament = "stoic, secretly ticklish",
		gesture = "Nod",
		gestureEvery = 12,
		cry = { pitch = 0.6, notes = 1, gap = 0.4 },
		entrance = "Stomp",
		facts = {
			"Nods once an hour. That is its whole conversation, and it means a lot.",
			"The one place it is ticklish is a secret. A bird knows. The bird will not say.",
		},
		favourite = "standing in the exact middle of a path",
		rareLook = "Heartwood: red-gold bark and a ring of pale mushrooms",
	},
	Stiltbark = {
		temperament = "jumpy pretender",
		gesture = "Peek",
		gestureEvery = 8,
		cry = { pitch = 1.5, notes = 2, gap = 0.2 },
		entrance = "PopUp",
		facts = {
			"Believes it looks exactly like a reed. It does not. Please do not tell it.",
			"Freezes mid-stride when you look at it, one foot in the air, for ages.",
		},
		favourite = "a thick bed of reeds at dusk",
		rareLook = "Birchwhite: pale silver bark with black freckles",
	},
	Burlhorn = {
		temperament = "sleepy grump",
		gesture = "Doze",
		gestureEvery = 10,
		cry = { pitch = 0.7, notes = 2, gap = 0.35 },
		entrance = "SlideIn",
		facts = {
			"Grumbles when woken, then lets you lean on it for the rest of the day.",
			"Small flowers grow in the knots of its burl. It pretends not to notice.",
		},
		favourite = "a warm rock and no company",
		rareLook = "Flowering Burl: a bloom-covered back in spring colours",
	},
	Hollowbough = {
		temperament = "absent-minded elder",
		gesture = "Sway",
		gestureEvery = 11,
		cry = { pitch = 0.5, notes = 3, gap = 0.45 },
		entrance = "Stomp",
		facts = {
			"Forgets it is carrying an owl family. Apologises to them by creaking.",
			"Takes one step a minute so nothing in its branches is ever startled.",
		},
		favourite = "the first light through its own leaves",
		rareLook = "Autumn Crown: gold and crimson leaves all year round",
	},
	-- Dust Canyon
	Duneskit = {
		temperament = "cocky racer",
		gesture = "Stretch",
		gestureEvery = 7,
		cry = { pitch = 1.6, notes = 4, gap = 0.05 },
		entrance = "SlideIn",
		facts = {
			"Races its own shadow every noon. Insists the shadow cheats.",
			"Its tall ears snap flat when it runs. It thinks that is what makes it fast.",
		},
		favourite = "a long empty dune and a head wind",
		rareLook = "Moondune: pale blue fur with silver-tipped ears",
	},
	Whirlgrit = {
		temperament = "joyful twirler",
		gesture = "Spin",
		gestureEvery = 6,
		cry = { pitch = 1.8, notes = 4, gap = 0.08 },
		entrance = "SpinIn",
		facts = {
			"Spins when happy. Gets dizzy when happier. Keeps spinning anyway.",
			"The ring of sand it lifts is never quite the same shape twice.",
		},
		favourite = "a dry breeze at sunrise",
		rareLook = "Dust Devil: a swirl-patterned body in rust and cream",
	},
	Flintknap = {
		temperament = "fussy perfectionist",
		gesture = "Wiggle",
		gestureEvery = 9,
		cry = { pitch = 1.1, notes = 3, gap = 0.07 },
		entrance = "Stomp",
		facts = {
			"Re-sharpens a blade that was already sharp. Then checks it. Then again.",
			"Sparks fly when it is nervous. It is nervous quite often.",
		},
		favourite = "a smooth canyon wall",
		rareLook = "Obsidian: glossy black blades with a red edge",
	},
	Wadibuck = {
		temperament = "skittish dreamer",
		gesture = "Shiver",
		gestureEvery = 8,
		cry = { pitch = 1.4, notes = 2, gap = 0.25 },
		entrance = "HopIn",
		facts = {
			"Hums when it is about to rain. Nobody knows which song.",
			"Starts at every shadow, but sleeps through thunder. Nobody knows that either.",
		},
		favourite = "the first drop of a flash flood",
		rareLook = "Rainbow Horn: horns that glint every colour when wet",
	},
	Spurlet = {
		temperament = "sun-drunk loafer",
		gesture = "Doze",
		gestureEvery = 12,
		cry = { pitch = 1.0, notes = 1, gap = 0.4 },
		entrance = "SlideIn",
		facts = {
			"Flowers once a year, always when nobody is watching, and only for a minute.",
			"Wakes at dusk for a quiet scuttle. It is a different, braver creature then.",
		},
		favourite = "a flat warm stone at noon",
		rareLook = "Night Bloom: deep purple with glowing white spines",
	},
	Thatchling = {
		temperament = "friendly waver",
		gesture = "Sway",
		gestureEvery = 7,
		cry = { pitch = 1.2, notes = 3, gap = 0.15 },
		entrance = "HopIn",
		facts = {
			"Waves both pompoms at everything: friends, rocks, the sun, other Thatchlings.",
			"Its leaf skirt rustles a different tune every season.",
		},
		favourite = "a visitor, any visitor",
		rareLook = "Spring Skirt: fresh green leaves and pink pompoms",
	},
	Cairnback = {
		temperament = "patient guide",
		gesture = "Nod",
		gestureEvery = 11,
		cry = { pitch = 0.7, notes = 2, gap = 0.3 },
		entrance = "DropIn",
		facts = {
			"Adds one small stone to its back every year, and says where it found each.",
			"Never loses the trail. Has lost an argument about where the trail goes.",
		},
		favourite = "a trail marker someone left tidy",
		rareLook = "Sunstack: warm orange stones with a white capstone",
	},
	Spirecap = {
		temperament = "dignified wobbler",
		gesture = "Stretch",
		gestureEvery = 10,
		cry = { pitch = 0.9, notes = 1, gap = 0.5 },
		entrance = "PopUp",
		facts = {
			"Keeps a flat stone on its head all day and is terribly proud of the balance.",
			"Very slightly leans toward whoever is talking, as if it is all news to it.",
		},
		favourite = "a perfectly still evening",
		rareLook = "Twilight Spire: purple stone with a gold cap",
	},
	Mesalith = {
		temperament = "serene giant",
		gesture = "Shake",
		gestureEvery = 14,
		cry = { pitch = 0.5, notes = 2, gap = 0.5 },
		entrance = "Stomp",
		facts = {
			"Small plants have moved onto its back. It walks carefully, for their sake.",
			"Sleeps standing and dreams in slow red colours, or so its visitors say.",
		},
		favourite = "a long sunset over the flat country",
		rareLook = "Ember Mesa: glowing orange stripes in its strata",
	},
	-- Tide Flats
	Glissot = {
		temperament = "breathless speedster",
		gesture = "Bounce",
		gestureEvery = 6,
		cry = { pitch = 1.7, notes = 3, gap = 0.05 },
		entrance = "SlideIn",
		facts = {
			"Cannot stand still. Runs on the spot while it waits for a wave.",
			"Leaves a dry footprint trail on wet sand. Nobody knows how.",
		},
		favourite = "a falling tide, wide and flat",
		rareLook = "Pearl Streak: pearly belly with turquoise stripes",
	},
	Clapshell = {
		temperament = "proud applause-seeker",
		gesture = "Clap",
		gestureEvery = 8,
		cry = { pitch = 0.9, notes = 2, gap = 0.12 },
		entrance = "HopIn",
		facts = {
			"Claps for itself after every move. Claps for you too, if you are polite.",
			"Has a different clap for sad, happy and snack. Only the last one is loud.",
		},
		favourite = "an audience of three or more",
		rareLook = "Gold Scallop: golden shell hands with a pink rim",
	},
	Cocklemole = {
		temperament = "busy digger",
		gesture = "Sniff",
		gestureEvery = 7,
		cry = { pitch = 1.3, notes = 4, gap = 0.07 },
		entrance = "PopUp",
		facts = {
			"Digs for the joy of it, then forgets where it started and digs back.",
			"Wears its cockle shell crooked and will not let anybody fix it.",
		},
		favourite = "a patch of soft, wet sand",
		rareLook = "Rosepearl: a pink shell with a pearl sheen",
	},
	Gulpmaw = {
		temperament = "hopeful optimist",
		gesture = "Gulp",
		gestureEvery = 9,
		cry = { pitch = 0.7, notes = 1, gap = 0.4 },
		entrance = "DropIn",
		facts = {
			"Sits with its mouth open all day. Once in a while, the sea says thank you.",
			"Has swallowed a lot of rocks hoping they were snacks. It stays upbeat.",
		},
		favourite = "a rock pool full of passing snacks",
		rareLook = "Coral Maw: a coral-red mouth with a bright pink tongue",
	},
	Runnelfin = {
		temperament = "natural dancer",
		gesture = "Hop",
		gestureEvery = 6,
		cry = { pitch = 1.5, notes = 4, gap = 0.09 },
		entrance = "SpinIn",
		facts = {
			"Dances in every runnel the tide leaves, and never the same dance twice.",
			"Flicks its fin crest to the beat of a song only it can hear.",
		},
		favourite = "a glittery shallow runnel at sunset",
		rareLook = "Opal Crest: an iridescent fin crest that shifts colour",
	},
	Moatkeep = {
		temperament = "fussy homebody",
		gesture = "Wiggle",
		gestureEvery = 10,
		cry = { pitch = 1.2, notes = 2, gap = 0.2 },
		entrance = "DropIn",
		facts = {
			"Rebuilds its walls after every wave and complains about it the whole time.",
			"Has a tiny flag on its tallest tower. It changes the flag daily.",
		},
		favourite = "damp sand that packs just right",
		rareLook = "Pink Castle: pink-tinted sand towers with a golden flag",
	},
	Hullock = {
		temperament = "wise old salt",
		gesture = "Sway",
		gestureEvery = 11,
		cry = { pitch = 0.6, notes = 2, gap = 0.4 },
		entrance = "SlideIn",
		facts = {
			"Rocks gently in place even on dry land, as if the beach were a swell.",
			"Barnacles on its back have been there so long they have names and opinions.",
		},
		favourite = "a long, slow tide coming in",
		rareLook = "Weathered Teal: sea-green hull with white barnacles",
	},
	Lanternell = {
		temperament = "gentle night-watcher",
		gesture = "Puff",
		gestureEvery = 10,
		cry = { pitch = 1.1, notes = 3, gap = 0.3 },
		entrance = "PopUp",
		facts = {
			"Glows brighter when someone is lost. Glows dimmer when they are found.",
			"Hums lullabies to the little creatures in the rock pools. They never nap.",
		},
		favourite = "a dark, still, starry evening",
		rareLook = "Moonlamp: a cool blue-white lantern instead of amber",
	},
	Carrackon = {
		temperament = "grand hermit",
		gesture = "Peek",
		gestureEvery = 13,
		cry = { pitch = 0.5, notes = 3, gap = 0.4 },
		entrance = "Stomp",
		facts = {
			"Has never taken its ship off. Rumour says it lost the key years ago.",
			"Dips its mast to every passing creature, and expects it back.",
		},
		favourite = "a sheltered bay with a fresh breeze",
		rareLook = "Ghost Galleon: pale blue ship with glowing sails",
	},
	-- The Mire
	Fenwhisk = {
		temperament = "smug sneak",
		gesture = "Stretch",
		gestureEvery = 8,
		cry = { pitch = 1.3, notes = 2, gap = 0.1 },
		entrance = "SlideIn",
		facts = {
			"Carries its tail like a flag, so everybody knows exactly where it is hiding.",
			"Says it is bored. Is sitting in the best reed bed by a wide margin.",
		},
		favourite = "the tallest reed bed in the marsh",
		rareLook = "Silver Whisker: silver fur and a white-tipped bulrush tail",
	},
	Skipslick = {
		temperament = "hyper show-off",
		gesture = "Bounce",
		gestureEvery = 6,
		cry = { pitch = 1.6, notes = 3, gap = 0.08 },
		entrance = "HopIn",
		facts = {
			"Crosses every pond in as few lily pads as it can. Keeps a score.",
			"Its warning colours are a bluff. It would never bite. It would tell a joke.",
		},
		favourite = "a long row of floating lily pads",
		rareLook = "Neon Frog: bright blue skin with orange spots",
	},
	Keelsnap = {
		temperament = "grumpy-sweet",
		gesture = "Shake",
		gestureEvery = 9,
		cry = { pitch = 0.8, notes = 2, gap = 0.08 },
		entrance = "Stomp",
		facts = {
			"Snaps at everyone. Brings a flat stone to the one it likes, and never says so.",
			"Dried mud on its shell cracks when it is pleased. It pretends it is the heat.",
		},
		favourite = "a muddy bank with nobody on it, except you",
		rareLook = "Mossback Keel: a green mossy shell instead of mud",
	},
	Snaggar = {
		temperament = "grinning ambusher",
		gesture = "Tilt",
		gestureEvery = 10,
		cry = { pitch = 0.6, notes = 3, gap = 0.2 },
		entrance = "PopUp",
		facts = {
			"Smiles with every tooth at once. It means well. Mostly it means hello.",
			"Lies so still that birds have built a nest on its back. It lets them.",
		},
		favourite = "a patch of warm shallow water under the roots",
		rareLook = "Golden Gar: an amber snout with ivory-bright teeth",
	},
	Bogbellow = {
		temperament = "jolly glutton",
		gesture = "Puff",
		gestureEvery = 8,
		cry = { pitch = 0.5, notes = 2, gap = 0.2 },
		entrance = "DropIn",
		facts = {
			"Belches when it laughs, which is often, which is why the marsh smells.",
			"Its peat mound is warm. Small creatures sleep on it and are never disturbed.",
		},
		favourite = "a warm peat bath",
		rareLook = "Ember Peat: a back that glows like banked coals",
	},
	Bulbroth = {
		temperament = "fussy cook",
		gesture = "Shiver",
		gestureEvery = 9,
		cry = { pitch = 1.0, notes = 4, gap = 0.1 },
		entrance = "SlideIn",
		facts = {
			"Tastes its own belly every morning and adds a pinch of something.",
			"The broth is never the same twice. Nobody has dared a spoon.",
		},
		favourite = "a slow simmer at dawn",
		rareLook = "Golden Broth: a honey-yellow belly with amber bubbles",
	},
	Lilyshade = {
		temperament = "serene and aloof",
		gesture = "Sway",
		gestureEvery = 12,
		cry = { pitch = 1.2, notes = 2, gap = 0.45 },
		entrance = "PopUp",
		facts = {
			"Has never been seen hurrying. It arrives anyway, a little cool and early.",
			"Its lily pad hat blooms once a year, and it will not say what it wished.",
		},
		favourite = "a still pond under a wide sky",
		rareLook = "White Lotus: a lotus bloom on its lily pad hat",
	},
	Mistrel = {
		temperament = "shy mist-hider",
		gesture = "Peek",
		gestureEvery = 9,
		cry = { pitch = 0.9, notes = 3, gap = 0.3 },
		entrance = "SlideIn",
		facts = {
			"Blows its own fog to hide in. Is visibly proud of the fog.",
			"Comes out of hiding for exactly one person, and takes a long time to pick.",
		},
		favourite = "a cold dawn with plenty of fog",
		rareLook = "Silver Fog: silver moss and a faint white glow",
	},
	Sloughback = {
		temperament = "ancient sleeper",
		gesture = "Doze",
		gestureEvery = 14,
		cry = { pitch = 0.5, notes = 1, gap = 0.5 },
		entrance = "Stomp",
		facts = {
			"Slept through three floods and a very loud wedding. Was not sorry.",
			"Moss grows in the grooves of its shell, one slow green year at a time.",
		},
		favourite = "a long, deep, undisturbed sleep",
		rareLook = "Old Grove: silver-green shell with tiny white blossoms",
	},
}

return SpeciesQuirks
