# Roster plan: all eleven biomes and the mythic tier

Date: 23 November 2026. For: Ayrton, and the six scaffold agents (A to F) who turn each line here into a full design and a Meshy prompt.
Status: every line is a [Default] or a placeholder under brief sections 4, 6, 7, 8 and 9, except where it repeats a [Locked] item (the biome lineup and order, team sizes, Greenwood mostly Common, Ruby from Crystal Deep, Diamond from the Abyss, the story arc). All names are placeholders. Nothing here changes code or data; the species files are written only after Ayrton approves a biome's list and its roster passes the balance gate (`tests/roster.test.luau`).

Read with:
- `00_BREEDING_STANDARD.md` (same folder): the shared skeleton per body plan, which part owns which feature, the six-block prompt, the colour line. **Every prompt follows it.** This plan says *what* each creature is; the standard says *how* it must be built so its parts mix.
- `docs/content/CREATURE_PERSONALITY.md`: one temperament and one gesture per species, no two the same.
- `docs/research/creatures/04_PROMPT_CRAFT.md`: Meshy's failure modes (thin parts, glow, transparency, floating pieces).
- The four roster files for biomes 1 to 4, which hold the stats, moves and the balance gate method.

Contents:
1. The whole journey at a glance
2. Rules for every scaffold agent
3. Biomes 1 to 4 (existing species, kept)
4. Biomes 5 to 11 (new species)
5. The mythic tier
6. Cross-biome pairs worth breeding
7. The six assignments
8. Decisions for Ayrton

---

## 1. The whole journey at a glance

### 1a. Species per biome and per body plan

| # | Biome | Team | Q | B | W | S | Catchable | Giant (plan) | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | Greenwood | 3v3 | 4 | 5 | | | 9 | Hollowbough (Q) | 8 built + 1 new |
| 2 | Dust Canyon | 3v3 | 4 | 4 | | | 8 | Mesalith (B) | built |
| 3 | Tide Flats | 3v3 | 4 | 4 | | | 8 | Carrackon (Q) | built |
| 4 | Mire | 4v4 | 4 | 4 | | | 8 | Sloughback (Q) | data only, closed |
| 5 | Frostline | 4v4 | 4 | 4 | | | 8 | Driftmother (Q) | new |
| 6 | Crystal Deep | 4v4 | 3 | 3 | | **4** | 10 | Druseback (Q) | new; Serpent debuts |
| 7 | Emberfall | 5v5 | 3 | 3 | **2** | 2 | 10 | Cinderhart (Q) | new; Winged debuts |
| 8 | Stormreach | 5v5 | 2 | 2 | 6 | | 10 | Squallray (W) | new; Winged dominates |
| 9 | Arcane biome | 5v5 | 3 | 3 | 2 | 2 | 10 | Bridgegrum (B) | new; provisional until Ayrton's references |
| 10 | Abyss | 5v5 | 2 | 2 | 3 | 3 | 10 | Starfathom (S) | new |
| 11 | The Hollow | 6v6 | 3 | 3 | 2 | 2 | 10 | Hearthwarden (Q) | new; one species per type |
| | **Total** | | **36** | **37** | **15** | **13** | **101** | 11 | 69 new species, 7 new giants |

Greenwood's counts assume Spadesnout moves to two legs (section 3, decision 1). If it stays four-legged, Greenwood is Q5/B4 and the new species is two-legged.

Why these numbers:
- **Eight per biome until a new body plan arrives**, as the brief's launch roster does. From Crystal Deep on, ten, because a new plan needs at least two species in the biome that introduces it, and the brief's full scale is 15 to 25 per biome ([Locked]), so later biomes should already be growing. Each biome section lists two or three spare concepts for that growth.
- **New plans arrive one at a time, each with its own home:** Serpent underground (Crystal Deep's tunnels and cave lakes), Winged at the volcano's updraughts (Emberfall), then Winged dominates Stormreach (brief section 8). Each plan needs its own rig, animation and balance pass (DECISIONS, 16 November), so spacing them out keeps that work to one plan per update. The bands for both are in `00_BREEDING_STANDARD.md` sections 1.3 and 1.4 (Ayrton has not yet confirmed either plan).
- **At least two species of a plan in every biome that has the plan**, so a player can always breed locally, with no lone species waiting for a partner from elsewhere.

### 1b. Types, breeding stat and new idea per biome

The type chart is `docs/research/market/07_BATTLE_AND_PVP.md` section 3 (each type beats two and loses to two; x1.5 / x0.67).

| # | Native type | Secondary types (count) | The underdog and its answer | Biome's breeding stat (the part that carries it) | New idea (brief) |
| --- | --- | --- | --- | --- | --- |
| 1 | Leaf 5 | Water 2, Sand 2 | (launch triangle) | none: the baseline | battling, lasso, rival, token |
| 2 | Sand 5 | Leaf 2, Water 1 | Leaf, with a Storm teaser on its torso | Speed (legs) | first gem tier ("Amber") |
| 3 | Water 6 | Sand 2 | Sand, with a Toxic teaser on its torso | Defence (torso shells) | bait |
| 4 | Toxic 6 | Water 2 | Water, with a Frost teaser on its torso | Hp (tails) | poison, 4v4 |
| 5 | Frost 6 | Toxic 2 | Toxic (sulphur-spring creatures), with a **Fire** teaser on its torso | Defence (front limbs: ice-armoured forelegs and arms), a different slot from Tide Flats' torsos | freeze or slow |
| 6 | Crystal 7 | Storm 2, Fire 1 | Storm (static in the quartz), with a **Frost** answer on its torso (no later type beats Crystal); the Fire serpent is a neutral teaser for Emberfall | Attack (heads: crystal horns, drills, lenses) | Ruby tier, Serpent plan |
| 7 | Fire 7 | Leaf 2, Storm 1 | Leaf (fire-adapted plants), with a **Water** answer on its torso; the Storm flyer is a teaser for Stormreach | Attack (front limbs: heavy hitters) | burn, 5v5, Winged plan |
| 8 | Storm 7 | Sand 2, Cosmic 1 | Sand (dust carried up the peaks), with an **Arcane** teaser on its torso; one tear-touched Cosmic moth | Speed (wings, in the front-limb slot) | first sight of the tear |
| 9 | Arcane 7 | Storm 2, Frost 1 | Storm and Frost, each with a **Cosmic** teaser on its torso | moves, not a stat: Arcane tails each bring two moves (proposal) | the truth about the mentor |
| 10 | Cosmic 7 | Arcane 2, Fire 1 | Arcane and Fire, with a **Crystal** or **Storm** answer on the torso | Speed (tails: comet tails) | Diamond tier, last rival battle |
| 11 | one of each type | (all ten) | none: the full chart | none: Hollow parts carry off-type moves, so they are the "bridge" parts for coverage | the entity, 6v6 |

The shape that has passed the balance gate three times (Dust Canyon's two-legged plan, Tide Flats, the Mire) is kept wherever it fits: **in each plan, three of the native type plus one underdog that the native type beats, and the underdog carries a torso-only move that beats the native type back**, which is also the teaser for a later biome. Crystal Deep is the one biome where no later type beats the native one, so its underdog's answer is Frost, a type the player already has.

Status ideas for the later biomes (brief: "later biomes add more"; these need battle-rule work and Ayrton's yes, so scaffold agents only name moves that would carry them): Frostline **Chill** (slow); Emberfall **Burn**; Stormreach **Static** (drains Tempo); Arcane **Hex** (locks the last move used for two turns, no chance involved); Abyss **Drift** (cannot switch out for two turns). All fixed effects, no random rolls, as the battle rules require.

---

## 2. Rules for every scaffold agent

### 2a. What each species entry contains

Write one block per species, in this order. Keep each block to the point.

1. **Name** (placeholder), **one-line concept**, element, body plan, rarity role, size class and target weight, battle role (sprinter, striker, bruiser, tank or all-rounder; one role per plan per biome where possible, as the earlier rosters do).
2. **Hook**: why a player wants it, in one sentence.
3. **Signature features on three different parts** (`00_BREEDING_STANDARD.md` section 2.2): name which part owns each.
4. **Look, part by part**: head, torso, front limbs (arms, wings or fins), legs, tail. Two main colours plus one accent, flat blocks.
5. **Personality**: temperament, gesture (one of Hop, Wiggle, Spin, Nod, Shiver, Stretch, Sniff, Bounce, Sway, Puff, Peek, Doze, Shake, Clap, Tilt, Gulp), cry, entrance, two journal facts, a favourite, a rare look (a colour or detail variant on one part). Check `CREATURE_PERSONALITY.md` so no temperament and gesture pair repeats.
6. **Move ideas**: one or two per part, with a type. Names and types only; powers, levels and stats come from the roster gate, not from the scaffold.
7. **Breeding hooks**: which part is this biome's breeding-stat part, and one surprising cross with a species from another biome on the same plan.
8. **The Meshy prompt**, built from the six blocks in `00_BREEDING_STANDARD.md` (STYLE LINE, the plan's STANDARD BODY LINE word for word, the species look part by part, SEPARATION LINE, COLOUR LINE, VIEW LINE). Never write the species name in the prompt (Meshy writes it out as a plaque). Glow is "painted bright, not glowing"; glass is "opaque coloured panels"; nothing see-through, nothing floating, nothing thin as a whisker.
9. **Originality check**: the nearest creature you know of in any other game, and what makes ours clearly different (silhouette, hook, colours). If you cannot say, redesign.

### 2b. Originality

Genre archetypes are welcome: every creature game has a fire lizard, a rock tortoise, an ice beast and a storm bird. The line is **no creature recognisable as a specific existing Pokémon** (or any other franchise's creature). Test: if someone would say "that's X with a different colour", it fails. Watch-outs met while planning this roster, so agents avoid them:

| Avoid | Because it reads as |
| --- | --- |
| A white, horse-like "first creature" with a gold ring round its middle | Arceus (the Firstling is designed against this, section 5) |
| A lab-made, powerful, brooding being; a chimera of animal parts in a helmet | Mewtwo; Type: Null and Silvally (the Frayling is designed against these) |
| A green sky serpent coiled in the clouds | Rayquaza (so the Crown's keeper is a ram, not a serpent) |
| An electric sheep, or wool that crackles | Mareep and Ampharos |
| An electric flying squirrel | Emolga |
| A quadruped toad with a plant on its back | Bulbasaur |
| A glowing mushroom with stalk legs | Morelull and Shiinotic |
| A pointed witch-hat head; a candle or chandelier body; a key ring; a bell body | Mismagius and Murkrow; Litwick and Chandelure; Klefki; Bronzong |
| A fox that is a wizard or has ice tails | Fennekin's line; Alolan Vulpix |
| A cosmic bat; a sun lion; a meteor shell; a starfish; a gas-cloud baby | Lunala; Solgaleo; Minior; Staryu; Cosmog |
| A fire moth with sun wings; a lava snail; a volcano-shelled tortoise | Volcarona; Slugma; Torkoal |
| A rock snake made of boulders in a chain | Onix and Steelix |
| A yeti, or a snowy pine tree with arms | Abomasnow |
| A polar bear with an icicle beard; an iceberg-backed turtle | Beartic; Avalugg |
| A spiky sand pangolin | Sandslash |
| A dream-eating tapir | Munna |

Names: also check that a name is not one letter or one sound away from another franchise's creature. Two existing names come close (section 3, decision 3).

### 2c. Silhouette motifs already taken

Do not reuse these as a species' main hook (a small echo on one part is fine): birch stilts, a back pond bubble, moss boxing mitts, a burl hump, a tree stump body, a spade snout, gorse ears, a duck-bill hopper with paddle feet, stacked stones, shutter ears, a succulent rosette, glass-tube horns, flint arm blades, a capstone spire, a leaf skirt with pompoms, a floating sand ring, a mesa body, a barnacle hull, a fluke-tailed skimmer, an all-mouth ambusher, a cockle-shell helmet, a lantern head, scallop-shell hands, a sail fin crest, a sandcastle body, a ship on the back, a bulrush tail flag, a warning-coloured frog, a mud-caked snapping turtle, needle jaws, a peat-vent boar, a cauldron belly, a lily-pad hat, a moss-draped tapir, a giant newt.

Planned in this file (claimed by the agent that owns the species): a snowdrift hare, an icicle-fringed musk ox, a hot-spring macaque, a tuning-fork head, a glowworm-thread serpent, a pine-cone body, a glassblower's snout, a lit-fuse tail, a weathervane tail, a frigatebird's drum throat, a kite on a tether, a book-page moth, a marionette on threads, a paper-lantern serpent, a star-chart shell, telescope eyes, an hourglass body, a tail-biting ring serpent, a mosaic-tiled pangolin, a tapestry body, a censer body.

### 2d. Rarity roles and size classes

| Rarity role | Meaning |
| --- | --- |
| **Common** | Open routes and long grass. Most of every biome. |
| **Uncommon** | Rustle spots only (as now); the quest-line gift is usually one of these from the Mire on. Two per biome (three in the Hollow). |
| **Rare spawn** (proposal, from Crystal Deep on) | A species met only through bait or the daily sighting at search spots (approval pack 7). One per biome. Touches drops, so it needs Ayrton's yes before it is built. Until then, treat it as Uncommon. |
| **Gem showcase** (★) | Not a rarity: any species can spawn as a gem tier (Amber, then Ruby, Diamond) at the same 0.6% rate. ★ marks the one or two species per biome whose design should look best with the gem effect and that the game shows off as the biome's headline serial find (like "Amber Duneskit No. 12"). Give them broad, simple surfaces for the sparkle and sheen effects (`00_BREEDING_STANDARD.md` section 3.3: gem tiers are effects, not materials). |

| Size class | Weight | Examples today |
| --- | --- | --- |
| XS | 40 or less | Duneskit, Whirlgrit, Runnelfin, Skipslick |
| S | 41 to 50 | Gorsling, Mossmitt, Stiltbark, Glissot, Fenwhisk |
| M | 51 to 65 | Sloshcalf, Splashjack, Cairnback, Gulpmaw, Keelsnap |
| L | 66 to 80 | Burlhorn, Spadesnout, Hullock, Bogbellow, Mistrel |
| XL | over 80 | giants' creature forms only (Hollowbough 84, Mesalith 90) |

Weight decides fit when parts move between bodies (heavy body, light legs: slower), so each biome needs a spread from XS or S to L. Sizes are planning values until the meshes are measured.

### 2e. Output

Each agent writes one file in this folder: `A_GREENWOOD_DUSTCANYON.md`, `B_TIDEFLATS_MIRE.md`, `C_FROSTLINE_CRYSTALDEEP.md`, `D_EMBERFALL_STORMREACH.md`, `E_ARCANE.md`, `F_ABYSS_HOLLOW_MYTHIC.md`. No code, no species data files, no edits to other documents. At the end of the file, a short list of questions for Ayrton.

---

## 3. Biomes 1 to 4: existing species, kept

These 32 species and four giants keep their names, types, body plans, roles and stats. Agents A and B redo the **design and the Meshy prompt** for each to `00_BREEDING_STANDARD.md`: three signature features on three parts, nothing crossing a joint, the plan's standard body line, the personality's face cue built in (the eight models named in `CREATURE_PERSONALITY.md` as needing it most: Keelsnap, Stiltbark, Gorsling, Stumpwarden, Burlhorn, Moatkeep, Mistrel, Spurlet). Known data fixes to carry into the new designs: Duneskit and Fenwhisk front legs too short against their hind legs, and Duneskit, Glissot, Gorsling and Wadibuck hind legs too long for the Quad band (standard, section 1.1).

### 1 · Greenwood (Leaf) · town Thistledown · 3v3

**Look:** moss green, bark brown, clover white, buttercup yellow; moss, bark, leaves, river pebbles; round, soft and stubby, with leaf tufts and sprouts. The homeliest palette in the game: everything later is measured against it.

| Species | Concept | Element | Plan | Rarity | Size | Role |
| --- | --- | --- | --- | --- | --- | --- |
| Mossmitt | Cheerful little brawler with two huge moss-ball fists; **Leaf starter** | Leaf | Biped | Common | S | all-rounder |
| Spadesnout | Proud riverbank digger with a trowel-flat snout; **Sand starter** | Sand | **Biped (proposed; was Quad)** | Common | L | striker |
| Sloshcalf | Gentle calf carrying a tiny pond in a bubble on its back; **Water starter** | Water | Quad | Common | M | fast all-rounder |
| Gorsling | Twitchy hedge runner shedding yellow gorse blossom | Leaf | Quad | Common | S | sprinter |
| Burlhorn | Sleepy grazer whose back is a living wooden burl | Leaf | Quad | Uncommon | L | bruiser |
| Stumpwarden | Patient living tree stump that plants itself in the path | Leaf | Biped | Common | L | tank |
| Stiltbark | Nervous wader on birch-twig stilts that thinks it passes for a reed | Leaf | Biped | Uncommon | S | sprinter |
| Splashjack | Lanky reed-bed hopper with huge paddle feet | Water | Biped | Common | M | all-rounder |
| **Loamlet** (new) | A round riverbank vole that packs sand into its cheek pouches until its face is twice its size | Sand | Quad | Common | S | striker or all-rounder |

- **Giant: Hollowbough** (Leaf, Quad), the colossal old tree that walks with owls in its hollow. Agent A also writes its creature form's prompt (giant settings).
- **Starter trio:** Leaf, Sand, Water: the launch triangle (Leaf beats Water beats Sand beats Leaf), each a non-reptile so the usual trio is avoided. All three also appear in the wild. The rival picks the one that loses to yours on the green and leads with the one that beats it at the gate.
- **Gifts:** quest creature Stumpwarden, clear token Gorsling (both catchable).
- **The ninth species** is Ayrton's call of 22 November ("a second Sand species, added, not swapped"). It must be Common (Greenwood is [Locked] mostly Common). If Spadesnout moves to two legs, Loamlet is four-legged, so both Greenwood plans keep a Sand species; if Spadesnout stays four-legged, the ninth is two-legged instead (alternative concept: **Pebblepot**, a squat riverbank creature shaped like a clay pot, sand trickling from its lid-shaped head).

### 2 · Dust Canyon (Sand) · town Kilnrest · 3v3

**Look:** ochre, rust red, sandstone cream, dusty sage; layered sandstone, flint, dry leaves, succulent skin; stacked, layered and slatted shapes, spires and blades. Fast and fragile.

| Species | Concept | Element | Plan | Rarity | Size | Role |
| --- | --- | --- | --- | --- | --- | --- |
| Duneskit ★ | Cocky dune sprinter with tall shutter-slat ears that snap flat | Sand | Quad | Common | XS | sprinter |
| Cairnback | Walking pile of trail-marker stones | Sand | Quad | Uncommon | M | bruiser |
| Spurlet | Sun-drunk succulent that blooms once a year when nobody watches | Leaf | Quad | Common | S | striker |
| Wadibuck | Skittish antelope whose hollow horns fill in flash floods | Water | Quad | Common | S | fast striker |
| Flintknap | Fussy craftsman with knapped flint blades for forearms | Sand | Biped | Common | S | bruiser |
| Spirecap ★ | Dignified rock-spire sentinel balancing a capstone | Sand | Biped | Uncommon | M | all-rounder |
| Thatchling | Friendly waver in a leaf-thatch skirt with green pompom hands | Leaf | Biped | Common | S | all-rounder |
| Whirlgrit | Joyful spinner that lifts a ring of sand | Sand | Biped | Common | XS | sprinter |

- **Giant: Mesalith** (Sand, Biped), the serene walking mesa.
- **Gifts:** quest creature Flintknap, token Duneskit.

### 3 · Tide Flats (Water) · town Saltwick · 3v3

**Look:** sea teal, wet-sand cream, coral pink, barnacle grey; shells, barnacles, sailcloth, sea glass, driftwood; domes, scallops, hull curves and fins.

| Species | Concept | Element | Plan | Rarity | Size | Role |
| --- | --- | --- | --- | --- | --- | --- |
| Glissot | Breathless tide-line skimmer that cannot stand still | Water | Quad | Common | S | sprinter |
| Gulpmaw | Hopeful rock-pool ambusher that is mostly mouth | Water | Quad | Common | M | striker |
| Hullock | Wise old shore ox crusted like a boat's hull | Water | Quad | Uncommon | L | bruiser |
| Cocklemole | Busy beach digger in a crooked cockle-shell helmet | Sand | Quad | Common | M | all-rounder |
| Clapshell | Applause-seeking brawler with scallop-shell hands | Water | Biped | Common | M | bruiser |
| Runnelfin | Natural dancer with a sail fin crest | Water | Biped | Common | XS | sprinter |
| Lanternell ★ | Gentle night-watcher with a glowing jelly-lamp head | Water | Biped | Uncommon | L | all-rounder |
| Moatkeep | Fussy sandcastle that rebuilds itself after every wave | Sand | Biped | Common | M | tank |

- **Giant: Carrackon** (Water, Quad), the grand hermit wearing a whole ship.
- **Gifts:** quest creature Clapshell, token Moatkeep (Sand, strong against the Mire's Toxic).

### 4 · The Mire (Toxic) · town Sedgeholm · 4v4

**Look:** olive, peat brown, moss green, bruise violet, with toxic lime only as an accent; mud, hanging moss, lily pads, bubbles and vents; lumpy, drooping, swollen shapes.

| Species | Concept | Element | Plan | Rarity | Size | Role |
| --- | --- | --- | --- | --- | --- | --- |
| Fenwhisk | Smug marsh weasel with a bulrush tail held like a flag | Toxic | Quad | Common | S | sprinter |
| Snaggar | Grinning gar-snouted lurker in the mangrove roots | Toxic | Quad | Common | L | striker |
| Bogbellow | Jolly glutton of a bog boar with a steaming peat back | Toxic | Quad | Uncommon | L | bruiser |
| Mistrel | Shy moss-draped tapir that hides in its own fog | Water | Quad | Common | L | all-rounder |
| Skipslick | Hyper show-off frog in warning colours | Toxic | Biped | Common | XS | sprinter |
| Keelsnap | Grumpy-sweet snapping turtle with a mud-caked shell | Toxic | Biped | Common | M | bruiser |
| Bulbroth ★ | Fussy swamp cook whose belly bubbles like a cauldron | Toxic | Biped | Uncommon | L | tank |
| Lilyshade | Serene pond keeper in a lily-pad hat, trailing mist | Water | Biped | Common | M | all-rounder |

- **Giant: Sloughback** (Toxic, Quad), the ancient sleeping newt of the Sunken Grove.
- **Gifts:** quest creature Bulbroth (Uncommon), token Mistrel (carries Hoarmist, the Frost teaser).

Note for agent B: Mistrel's moss drape and Lilyshade's mist must stay on the torso and stop above the leg tops (standard, section 2.1 rule 3).

---

## 4. Biomes 5 to 11: new species

Every concept below is a starting point for the scaffold agent, who may change any detail that makes a better creature, keeping the element, plan and rarity role (or saying why not).

### 5 · Frostline (Frost) · town "Rimewick" · 4v4 · slow and tanky

**Look:** snow white, ice blue, slate grey and pine green, with aurora mint as the accent; thick woolly frost, packed snow, icicle fringes, hoarfrost feathers; heavy rounded masses with fringes hanging from them, snowshoe feet. The two Toxic underdogs are sulphur yellow and steam white, so they read as visitors from the hot springs.

| Species | Concept | Element | Plan | Rarity | Size | Role |
| --- | --- | --- | --- | --- | --- | --- |
| Flurrlem | A lemming that runs in a puff of snow, always first in a line of one | Frost | Quad | Common | XS | sprinter |
| Glacibex ★ | Cliff-climbing ibex with curled horns of packed blue ice | Frost | Quad | Common | M | striker |
| Woolrime | Musk ox whose shaggy coat has frozen into a hanging icicle fringe | Frost | Quad | Uncommon | L | bruiser |
| Stinkglut | Wolverine-like glutton with a sulphur-yellow stripe, who sleeps by the vents | Toxic | Quad | Common | M | all-rounder (underdog; Fire move on torso) |
| Hoarmot | Upright snow marmot, fur thick with hoarfrost, that whistles at weather | Frost | Biped | Common | M | tank |
| Rimefern | Delicate sprite grown like frost ferns on a window pane | Frost | Biped | Common | XS | sprinter |
| Chiselrime | Stout river beaver with ice-chisel teeth and a tail frozen flat as a paddle | Frost | Biped | Uncommon | L | bruiser |
| Simmerling | Hot-spring macaque, steam rising off its sulphur-crusted fur | Toxic | Biped | Common | M | all-rounder (underdog; Fire move on torso) |

- **Breeding stat:** Defence on the front limbs (ice-armoured forelegs, frost gauntlets), so a breeder can take Frostline toughness without the Frost type.
- **Giant: Driftmother** (Frost, Quad): a colossal snow hare whose back is a snowfield with a stand of pines on it; when the tear's leak drives it wild it stamps and sets off avalanches. Fight idea: it buries the field in drifts that Chill the team; a Fire hit on the wind-up melts the drift.
- **Gifts:** quest creature Woolrime (Uncommon); token Rimefern (Frost beats Crystal, the next biome).
- **Spares for growth:** a snowshoe-footed lynx kitten; an aurora-crested ptarmigan (Winged, later); an ice-fishing otter.

### 6 · Crystal Deep (Crystal) · town "Glimmerholt" · 4v4 · Ruby tier · Serpent debuts

**Look:** deep violet and amethyst, cyan and magenta crystal light, pale cave-white skin; soft, smooth, blind-cave bodies with sharp faceted growths on them (the contrast is the biome's signature); geodes, quartz points, dripstone. All glow is painted bright, with Neon and lights added in Roblox.

| Species | Concept | Element | Plan | Rarity | Size | Role |
| --- | --- | --- | --- | --- | --- | --- |
| Glintbruin | Slow cave bear with a ridge of amethyst points along its back | Crystal | Quad | Uncommon | L | bruiser |
| Prismquill ★ | Porcupine whose quills are clear crystal prisms that split lamplight into colours | Crystal | Quad | Common | M | striker |
| Thundegg | Round geode toad that crackles with static when it puffs up (a "thunderegg") | Storm | Quad | Common | M | all-rounder (underdog; Frost move on torso) |
| Lensloris | Slow loris with huge crystal-lens eyes that see in the dark | Crystal | Biped | Common | S | all-rounder |
| Stalagrump | Squat dripstone grump, a fringe of stalactites over its brow | Crystal | Biped | Uncommon | L | tank |
| Forkhum | Slender creature whose head is a two-pronged tuning fork that hums and sparks | Storm | Biped | Common | S | sprinter (underdog; Frost move on torso) |
| Grotteel | Pale cave-lake eel with a glassy crystal fin crest | Crystal | Serpent | Common | M | sprinter |
| Drillgleam | Tunnelling worm that bores with one faceted crystal for a head | Crystal | Serpent | Common | M | striker |
| Glowthread | Serpent that hangs curtains of glowing silk threads in the cave roof, like glowworms | Crystal | Serpent | Rare spawn | S | all-rounder |
| Slagworm | Fat, slow magma worm from near the lava tube, crusted with cooling slag | Fire | Serpent | Common | L | bruiser (Emberfall teaser, neutral to Crystal) |

- **Breeding stat:** Attack on the heads (horns, drills, lenses, prongs).
- **Ruby tier** starts here ([Locked]). Prismquill is the Ruby showcase: the first Ruby find a player is likely to chase.
- **Serpent plan:** four species, so the plan can be bred from day one. Agent C writes the plan's conventions for the other agents (what a fin looks like, how the long tail reads).
- **Giant: Druseback** (Crystal, Quad): a colossal pillbug whose back plates are geode halves, crystals showing at the seams; it rolls up and charges through its tunnels. Fight idea: rolled up it takes little damage; a Leaf or Frost hit as it unrolls cracks it open.
- **Gifts:** quest creature Glintbruin; token Grotteel with a Water move on its head (Water beats Fire, the next biome).
- **Spares:** a crystal-shelled cave shrimp; a blind cave cricket with quartz antlers; a mineral-spring newt.

### 7 · Emberfall (Fire) · town "Cinderwick" · 5v5 · heavy hitters · Winged debuts

**Look:** charcoal and basalt grey, ember orange in the cracks, ash white; obsidian, basalt columns, pumice, cooling slag with glowing seams (painted); heavy, blocky, cracked plates. The two Leaf underdogs are fireweed pink and burnt-cone brown: the plants that come back first after a fire.

| Species | Concept | Element | Plan | Rarity | Size | Role |
| --- | --- | --- | --- | --- | --- | --- |
| Slagwallow | Hippo that wallows in magma mud, its back a cooling crust | Fire | Quad | Uncommon | L | bruiser |
| Smoulderskink | The biome's fire lizard: a stocky skink with ember-glow cracks between basalt scales | Fire | Quad | Common | S | striker |
| Pyrecone | Squat creature shaped like a pine cone that only opens its scales in great heat | Leaf | Quad | Common | M | all-rounder (underdog; Water move on torso) |
| Tongbeetle | Upright blacksmith beetle with glowing tong mandibles and hammer forearms | Fire | Biped | Uncommon | L | bruiser |
| Glassgaffer ★ | Glassblower creature with a long tube snout that blows bubbles of molten glass | Fire | Biped | Common | M | all-rounder |
| Ashbloom | Little fireweed sprite with a tall pink flower-spike crest | Leaf | Biped | Common | S | sprinter (underdog; Water move on torso) |
| Magmeel | Lava-river eel with an obsidian-plated head | Fire | Serpent | Common | M | striker |
| Fusewick | Thin serpent whose tail tip fizzes like a lit fuse; it bolts when it is nervous | Fire | Serpent | Rare spawn | S | sprinter |
| Ashflit | Ember bat with glowing wing veins, roosting in the lava tube | Fire | Winged | Common | XS | sprinter |
| Updrafter | Broad-winged soarer that rides the volcano's thermals up to the clouds | Storm | Winged | Common | M | all-rounder (Stormreach teaser) |

- **Breeding stat:** Attack on the front limbs (hammer arms, heavy claws, mandibles, wing spurs).
- **Burn** arrives here (brief). Smoulderskink is deliberately a quad, not an upright orange lizard with a flaming tail, to stay clear of the genre's best-known fire starter.
- **Winged plan:** two species, one per type, so the plan can be bred locally before Stormreach widens it. Agent D writes the Winged conventions (wings fold straight down at rest, `00_BREEDING_STANDARD.md` section 1.3).
- **Giant: Cinderhart** (Fire, Quad): a colossal stag whose antlers are smoking basalt columns and whose hooves leave glowing prints. Fight idea: it Burns the team with every antler sweep; a Water hit on the wind-up quenches the antlers for two turns.
- **Gifts:** quest creature Tongbeetle; token Glassgaffer with a Crystal move on its head (Crystal beats Storm, the next biome).
- **Spares:** a honey-badger-like ash badger; a lava-crust roadrunner; a pumice puffball.

### 8 · Stormreach (Storm) · town "Highwhistle" · 5v5 · winged plans dominate · first sight of the tear

**Look:** sky white, slate storm blue, sunlit gold, with weathered copper as the accent (weathervanes, wind gauges); layered feathers, cloud tufts, copper vanes, kite cloth; streamlined bodies, long wings, swept crests, fins and vanes that point into the wind. The two Sand underdogs are sandblasted smooth, the colour of the dust carried up the peaks.

| Species | Concept | Element | Plan | Rarity | Size | Role |
| --- | --- | --- | --- | --- | --- | --- |
| Gustlet | Tiny storm petrel that patters across the cloud sea | Storm | Winged | Common | XS | sprinter |
| Vanecrest ★ | Rooster whose tail is a copper weathervane that swings to point at storms | Storm | Winged | Common | M | all-rounder |
| Hailstoop | Stocky hawk with feathers layered like hailstones; it dives like falling hail | Storm | Winged | Common | M | striker |
| Boomthroat | Frigatebird that inflates a red throat pouch and drums it like thunder | Storm | Winged | Uncommon | L | bruiser |
| Duneswallow | Sand martin carried up on dust storms, nesting in the peaks' sand banks | Sand | Winged | Common | S | all-rounder (underdog; Arcane move on torso) |
| Loomoth | Pale night moth whose wings show a woven starfield; it appeared when the tear did | Cosmic | Winged | Rare spawn | S | striker |
| Thunderhump | Bison whose hump is a dark rumbling thundercloud | Storm | Quad | Uncommon | L | bruiser |
| Puffchin | Chinchilla-like peak hopper with fur so light the wind bounces it along | Storm | Quad | Common | XS | sprinter |
| Kiteling | Small upright creature with a living kite tethered to its tail | Storm | Biped | Common | S | all-rounder |
| Gritgoyle | Gargoyle-like peak hermit, sandblasted smooth, that perches on ledges | Sand | Biped | Common | M | tank (underdog; Arcane move on torso) |

- **Breeding stat:** Speed on the wings (front-limb slot): Stormreach wings are the Winged plan's Speed parts, as Dust Canyon's legs are for Quad.
- **The tear:** first seen from Cloud Isle (plan 13). Loomoth is the first creature visibly touched by it: a story beat the tamers talk about, and the bridge to the Abyss's Cosmic winged species.
- **Giant: Squallray** (Storm, Winged): a colossal sky manta-ray that glides inside the Anvil's storm cloud, lightning running along its wing edges. Fight idea: it Static-drains the team's Tempo; a Crystal or Arcane hit on the wind-up grounds it.
- **Gifts:** quest creature Boomthroat; token Loomoth (Cosmic beats Arcane, the next biome; wild ones stay rare).
- **Spares:** a cloud-tufted mountain goat kid; a swift that sleeps on the wing; a rain-gauge toad.

### 9 · The Arcane biome (Arcane) · town "Lanternmoor" · 5v5 · **provisional**

[Locked] biome 9 is the nostalgia biome and Ayrton will share style references. Everything here is a placeholder so agent E can start the structure (types, plans, roles) and hold the looks loosely until the references arrive. Brief: wizards, trolls and mythical creatures, magic traits, a purple cave-like look; plan 13 adds Toadstool Dell, the Lantern Spire, the Old Lane home to Greenwood.

**Look (placeholder):** violet twilight, moss green, lantern gold, toadstool red and cream; moss, toadstools, parchment, rune-carved wood, inky starry blue; crooked, pointed, storybook shapes, as if drawn in an old fairy-tale book. The Old Lane leads home to Greenwood, so some Arcane species should echo Greenwood's shapes, grown strange.

| Species | Concept | Element | Plan | Rarity | Size | Role |
| --- | --- | --- | --- | --- | --- | --- |
| Jackalorn | Horned hare of old tales, its little antlers hung with moss | Arcane | Quad | Common | S | sprinter |
| Underbridge | Shaggy, horned, moss-hung troll beast that sleeps under bridges and turns pebble-grey in sunlight | Arcane | Quad | Uncommon | L | bruiser |
| Rimefawn | Pale fawn whose spots are frost-stars | Frost | Quad | Common | S | all-rounder (underdog; Cosmic move on torso) |
| Capgnome ★ | Little bearded hermit whose head grows a red-and-cream toadstool cap (part of it, not a hat) | Arcane | Biped | Common | S | all-rounder |
| Pebbletroll | Rock-troll cub that freezes into a boulder when looked at | Arcane | Biped | Uncommon | L | tank |
| Stringlet | Marionette-like creature strung to the sky by threads of static | Storm | Biped | Common | XS | sprinter (underdog; Cosmic move on torso) |
| Folioth | Moth whose wings are the open pages of an old spellbook | Arcane | Winged | Common | S | all-rounder |
| Sparkowl | Horned owl whose ear tufts flicker with blue sparks | Storm | Winged | Common | M | striker |
| Runecoil | Serpent with glowing runes carved along its long body | Arcane | Serpent | Common | M | striker |
| Paperlume | Serpent made of a string of paper lanterns, each segment lit | Arcane | Serpent | Rare spawn | S | all-rounder |

- **Breeding idea:** Arcane tails each bring two moves where other tails bring one (move-rich parts; a proposal, measured by the roster gate).
- **Giant: Bridgegrum** (Arcane, Biped, placeholder): a colossal troll whose stooped back is the old stone footbridge over Toadstool Dell. Fight idea: it Hexes your strongest move each phase.
- **Gifts:** quest creature Underbridge or the Frayling's quest (section 5); token Sparkowl (Storm beats Cosmic, the next biome).
- **The truth about the mentor** lands here: see the Frayling.
- **Spares:** a wisp-tailed marsh hound; a griffin cub; a hedge-witch hedgehog with wand-like spines.

### 10 · The Abyss (Cosmic) · town "Starfold" · 5v5 · Diamond tier · last rival battle

**Look:** midnight navy, black sand, starlight white points, nebula pink and teal; velvet black skin, star speckles, constellations joined by fine gold thread (painted, the game's patchwork theme at its most cosmic), smoked glass; sleek, ribbon-like and ringed shapes, slow and floating.

| Species | Concept | Element | Plan | Rarity | Size | Role |
| --- | --- | --- | --- | --- | --- | --- |
| Orrerback ★ | Tortoise whose domed shell is a star chart, its stars joined by gold thread | Cosmic | Quad | Uncommon | L | bruiser |
| Cometkit | Little hopper with a long comet tail streaming behind it | Cosmic | Quad | Common | XS | sprinter |
| Spyglint | Small stargazer with eyes that extend like telescopes | Cosmic | Biped | Common | S | all-rounder |
| Hourling | Creature with an hourglass body, its sand made of tiny stars | Arcane | Biped | Common | S | tank (underdog; Crystal move on torso) |
| Cometfinch | Swallow-tailed finch that leaves a faint trail of light | Cosmic | Winged | Common | XS | sprinter |
| Nebulark | Lark whose plumage swirls like a nebula; it sings in near silence | Cosmic | Winged | Common | S | all-rounder |
| Bolide | Falcon that burns as it dives, like a falling fireball | Fire | Winged | Common | M | striker (underdog; Storm move on torso) |
| Galaxeel | Ribbon of an eel that swims through the black sand like the Milky Way | Cosmic | Serpent | Common | M | sprinter |
| Portaloop | Tube worm whose mouth opens onto a different starfield | Cosmic | Serpent | Uncommon | M | striker |
| Ouroring | Ring serpent that holds its own tail in its mouth, a living rune circle | Arcane | Serpent | Rare spawn | M | all-rounder (underdog; Crystal move on torso) |

- **Breeding stat:** Speed on the tails (comet tails, streamers).
- **Diamond tier** starts here ([Locked]). Orrerback is the Diamond showcase.
- **Ouroring's pose:** a held tail breaks the Serpent rest pose (tail straight back). Agent F designs it so the ring is drawn by the tail curving up and over in the YZ plane only, or moves the ring motif onto the torso; whichever survives the standard.
- **Giant: Starfathom** (Cosmic, Serpent): a colossal oarfish of the void with a crest of pale light, rising from the Starwell. Fight idea: it Drifts the team (no switching) while it charges; a Crystal or Storm hit on the wind-up breaks the charge.
- **Gifts:** quest creature Orrerback or Portaloop; token Spyglint. The rival's gift before the finale (his own starter, brief) is given here after the last rival battle.
- **Spares:** a black-sand hermit in a meteorite shell; an eclipse-winged heron; a moon-cratered wombat.

### 11 · The Hollow (mixed) · camp "Old Hearth" · 6v6 · the entity

**Look:** weathered pale stone, gold leaf, violet-ember light under the tear, drifting petals; carved stone, mosaic tiles, tapestry, temple bronze; statue-like creatures, as if the ruins themselves had woken. **Each Hollow species carries one inset "patch" of coloured glass in its type's colour**, an echo of the Firstling's stained glass: the Hollow's creatures are the Firstling's oldest kin.

| Species | Concept | Element | Plan | Rarity | Size | Role |
| --- | --- | --- | --- | --- | --- | --- |
| Mossaltar | Stone ox whose back is a fallen altar, overgrown with ivy and moss | Leaf | Quad | Uncommon | L | bruiser |
| Sphinxling | Sandstone sphinx cub, worn smooth, guarding a riddle it has forgotten | Sand | Quad | Common | M | striker |
| Tesserine ★ | Pangolin whose scales are mosaic tiles | Crystal | Quad | Uncommon | M | tank |
| Censerling | Creature shaped like a temple censer, swinging a trail of heavy fumes | Toxic | Biped | Common | S | all-rounder |
| Embergrate | Squat creature whose belly is an old hearth with a glowing grate | Fire | Biped | Common | M | bruiser |
| Tapestrel | Living tapestry that tells the story of the first creatures across its body | Arcane | Biped | Uncommon | M | all-rounder |
| Rimedove | Carved dove with frosted-glass wings that thaws into flight at night | Frost | Winged | Common | S | sprinter |
| Bannerwing | Flyer with tattered temple-banner wings that ride the wind | Storm | Winged | Common | S | striker |
| Fountcoil | Serpent shaped like an old fountain spout that still pours water | Water | Serpent | Common | M | all-rounder |
| Riftling | Serpent that slid out of the tear, its edges coming unravelled | Cosmic | Serpent | Rare spawn | M | sprinter |

- **One species per type**, so the Hollow is the full type chart in one place, and every Hollow part is a coverage part ("bridge" parts that bring an off-type move to an older creature).
- **Giant: Hearthwarden** (mixed, Quad): a colossal ruin hound of fitted stone blocks with ten coloured glass insets, the old guard of the hearth. Fight idea: **its type changes each phase** (shown a turn ahead), so a 6v6 team needs answers to several types. This needs a small giant-rule change (a phase can set the giant's element); flagged for Ayrton.
- **Riftling** is the warning sign: the entity's unravelling has started to reach creatures (section 5).
- **No token:** the finale's rewards are the cosmic wrap ([Locked]) and, as proposed, the Firstling.
- **Spares:** a bronze temple tortoise; a sundial-backed lizard; a petal-drift moth.

---

## 5. The mythic tier

Mythics are not a rarity tier: rarity belongs to individuals (Common to Cosmic), and the cosmic wrap stays the only way to Cosmic rarity ([Locked]). A mythic is a **species with a flag**, the way a giant's creature form carries `giantForm`: proposed `mythic = true`, one per player, bound to the account, numbered in the order players earn it (like giants), gifted by the story, never a wild spawn and never sold. Whether a mythic can breed, and how it is earned, are Ayrton's calls (section 8).

The lore below is one connected proposal. It keeps every [Locked] story beat (the mentor caused the tear by accident; the rival consumed something linked to the entity; the player destroys the entity) and adds detail to the [Default] "mentor's mistake: a breeding experiment with a fallen star fragment".

| Mythic | Concept | Element | Plan | Story role | How it is met (proposal) |
| --- | --- | --- | --- | --- | --- |
| **The Firstling** | The first creature: a stitched patchwork of stained-glass panes, its mane golden thread, its halo an embroidery hoop of light. Every creature's parts come from its patches, which is why parts can be swapped at all | Crystal | Quad | The origin myth of breeding; it sleeps in the Hollow holding the world's seams shut | Wakes after the entity falls and joins the player with the cosmic wrap |
| **The Frayling** | The mentor's mistake: a small, half-finished creature bred from the star fragment. Its seams are loose and starlight shows through the gaps where patches are missing | Cosmic | Biped | The truth about the mentor (biome 9): he chased the perfect bloodline with the fragment, and the fragment was a chip of the Firstling's glass. Using it tore the sky | Found hiding in Starfall Crater when it opens in the Arcane chapter (DECISIONS, 23 November); joins after a quest in which the player and the mentor mend its seams |
| **Nimbram** | The Crown's keeper: a vast, slow, ancient ram whose cloud fleece is the halo on the Crown. Its fleece greys a shade each chapter as the tear grows | Storm | Quad | Explains the halo darkening (plan 13) and why the tear stayed small for so long | Seen from Cloud Isle at the tear's first sight (biome 8); met at the Crown's summit in the post-game, if Ayrton wants it obtainable at all |
| **The Unraveller** (the entity, name [Open]) | Not a creature anyone owns: a shape of unpicked black thread and torn sky that pulls seams apart. Where the Firstling stitches, it unpicks | Cosmic | (boss, no plan) | The final boss, purely evil ([Locked]). The rival swallowed one of its black threads (the "something he consumed"), and a dark stitch in his gifted starter is the sequel seed | Never caught. Its 6v6 team is "unravelled" versions of creatures the player has met, coming apart at the joints |

### The Firstling: brief for agent F (Ayrton is iterating the look; this is the frame, not the final)

- **Why Crystal:** stained glass is Crystal, and Crystal beats Cosmic, so the first creature is the natural answer to the entity and the tear. Weak to Leaf and Frost, so it is not untouchable in PvP.
- **Keep clear of Arceus** (a tall white horse-like quadruped with a gold cross-wheel round its middle, "the original one"): make the Firstling small and soft, the size and shape of a sitting cub or fawn-lion, a patchwork of many coloured panes with dark leading lines, never white; the hoop sits **upright behind the head** like an embroidery hoop, not a wheel round the body.
- **Fit the breeding standard:** the golden-thread mane belongs to the **torso** (manes are torso features) and stops at the collar; the hoop is a head feature, **joined to the head** by two or three thread spokes (Meshy drops floating pieces), or added in Roblox as its own part. Stained glass is "opaque coloured panels with dark outlines, painted bright, not glowing"; the light comes from Neon and a glow effect in Roblox.
- **Its parts are special:** each pane could be one of the ten type colours, so its patchwork reads as "all creatures came from me". If mythics may breed, a Firstling part is the rarest part in the game.
- **Budget:** standard tier (it is a creature, not a giant), up to 3,600 triangles.

### The Frayling: brief for agent F

- **Keep clear of Mewtwo** (a powerful, brooding lab-made being) and of **Type: Null and Silvally** (an artificial chimera of animal parts in a helmet): the Frayling is small, frightened and gentle, child-sized, made of the same patchwork as every creature but with gaps, and it is not powerful; its strength is that it belongs to the player's story.
- Its gaps are painted starfield on the torso, not holes (nothing see-through). Loose thread ends are chunky stubs on one part each, never across a joint.

---

## 6. Cross-biome pairs worth breeding

Same body plan, different biomes. These are the "surprising combinations" the scaffold agents should write up as each species' breeding hook, and that the game can feature on the breeder's screen or in quests. Cross-biome breeding costs more with a late parent ([Locked]), so most are a choice, not the default.

| Pair (plan) | What a baby can look like | Why it is worth it |
| --- | --- | --- |
| Sloshcalf × Woolrime (Q) | A pond calf with an icicle-fringed fleece: the pond froze over | Frostline's Defence forelegs on a fast Greenwood body |
| Duneskit × Thunderhump (Q) | A thundercloud bison on sprinter's legs | Dust Canyon's Speed legs onto a late bruiser |
| Hullock × Orrerback (Q) | A boat-hulled tortoise carrying a star chart | Tide Flats' Defence torso against Abyss Speed tails |
| Gulpmaw × Slagwallow (Q) | An all-mouth magma hippo | Two strikers' heads; a Water torso hides Fire's weakness |
| Burlhorn × Mossaltar (Q) | A living burl grown over a fallen altar | A Greenwood rare look (Flowering Burl) onto endgame stats, exactly the brief's example |
| Spadesnout × Flintknap (B, if Spadesnout moves) | A spade-snouted digger with flint blade arms | The two Sand strikers of the launch |
| Mossmitt × Embergrate (B) | Moss boxing mitts on a hearth belly | Leaf arms bring Leaf moves to a Fire torso |
| Lanternell × Glassgaffer (B) | A lantern head on a glassblower | Both light-makers; a showcase for the gem effect |
| Moatkeep × Gritgoyle (B) | A sandcastle tower on a gargoyle | Two Sand tanks from opposite ends of the map |
| Glowthread × Galaxeel (S) | Glowing silk threads trailing from a galaxy ribbon | Crystal head Attack on an Abyss Speed tail |
| Vanecrest × Folioth (W) | A weathervane tail on a spellbook moth | Stormreach Speed wings on an Arcane move-rich tail |
| Loomoth × Nebulark (W) | Woven starlight wings on a nebula lark | The tear's first creature meets the Abyss |
| Ashflit × Rimedove (W) | Ember-veined wings on a frosted-glass dove | Fire against Frost, the chart's own joke |

Giants' creature forms may breed with Giant Candy (DECISIONS, 21 November), so Hollowbough, Mesalith, Carrackon and Sloughback parts can join these on their plans.

---

## 7. The six assignments

Each agent fills the template in section 2a for every species and giant listed, writes to its file (section 2e), and ends with questions for Ayrton. Agents A and B keep names, types, plans, roles and stats; agents C to F may rename and reshape within the element, plan and rarity role given.

**A · Greenwood and Dust Canyon** (`A_GREENWOOD_DUSTCANYON.md`): 17 existing, 1 new, 2 giant forms.
- Greenwood: Mossmitt, Spadesnout (write both a two-legged and a four-legged prompt until Ayrton decides), Sloshcalf, Gorsling, Burlhorn, Stumpwarden, Stiltbark, Splashjack, **Loamlet** (new; or Pebblepot if Spadesnout stays four-legged).
- Giant form: Hollowbough.
- Dust Canyon: Duneskit, Cairnback, Spurlet, Wadibuck, Flintknap, Spirecap, Thatchling, Whirlgrit.
- Giant form: Mesalith.
- Also: the starter trio's family look (the three should read as a set on the pick screen).

**B · Tide Flats and the Mire** (`B_TIDEFLATS_MIRE.md`): 16 existing, 2 giant forms.
- Tide Flats: Glissot, Gulpmaw, Hullock, Cocklemole, Clapshell, Runnelfin, Lanternell, Moatkeep.
- Giant form: Carrackon.
- Mire: Fenwhisk, Snaggar, Bogbellow, Mistrel, Skipslick, Keelsnap, Bulbroth, Lilyshade.
- Giant form: Sloughback.
- Also: name alternatives for Lanternell and Gulpmaw (decision 3), without changing anything else.

**C · Frostline and Crystal Deep** (`C_FROSTLINE_CRYSTALDEEP.md`): 18 new species, 2 new giants. **Owns the Serpent plan's conventions.**
- Frostline: Flurrlem, Glacibex, Woolrime, Stinkglut, Hoarmot, Rimefern, Chiselrime, Simmerling.
- Giant: Driftmother.
- Crystal Deep: Glintbruin, Prismquill, Thundegg, Lensloris, Stalagrump, Forkhum, Grotteel, Drillgleam, Glowthread, Slagworm.
- Giant: Druseback.

**D · Emberfall and Stormreach** (`D_EMBERFALL_STORMREACH.md`): 20 new species, 2 new giants. **Owns the Winged plan's conventions.**
- Emberfall: Slagwallow, Smoulderskink, Pyrecone, Tongbeetle, Glassgaffer, Ashbloom, Magmeel, Fusewick, Ashflit, Updrafter.
- Giant: Cinderhart.
- Stormreach: Gustlet, Vanecrest, Hailstoop, Boomthroat, Duneswallow, Loomoth, Thunderhump, Puffchin, Kiteling, Gritgoyle.
- Giant: Squallray.

**E · The Arcane biome** (`E_ARCANE.md`): 10 new species, 1 new giant, provisional.
- Jackalorn, Underbridge, Rimefawn, Capgnome, Pebbletroll, Stringlet, Folioth, Sparkowl, Runecoil, Paperlume.
- Giant: Bridgegrum.
- Write the structure (types, plans, roles, moves, breeding hooks) in full now; write looks and prompts as drafts marked "to redo against Ayrton's references". When the references arrive, E redoes the looks and may replace any concept.

**F · The Abyss, the Hollow and the mythic tier** (`F_ABYSS_HOLLOW_MYTHIC.md`): 20 new species, 2 new giants, 4 mythic designs.
- Abyss: Orrerback, Cometkit, Spyglint, Hourling, Cometfinch, Nebulark, Bolide, Galaxeel, Portaloop, Ouroring.
- Giant: Starfathom.
- The Hollow: Mossaltar, Sphinxling, Tesserine, Censerling, Embergrate, Tapestrel, Rimedove, Bannerwing, Fountcoil, Riftling.
- Giant: Hearthwarden.
- Mythic: the Firstling (a frame for Ayrton's iteration, plus two or three prompt variants), the Frayling, Nimbram, the Unraveller (boss design and its "unravelled" team idea; no Meshy prompt needed unless it is shown as a model).
- F is the largest load. If it runs long, Nimbram moves to D (it is first seen in Stormreach).

Order of work for the lead: A and B first (they feed the art pipeline now), then C (the Mire's successor and the Serpent plan), D, F; E when the references arrive.

---

## 8. Decisions for Ayrton (in one batch)

1. **Spadesnout on two legs.** You like the two-legged concept art. Recommended: yes. Greenwood becomes four four-legged and five two-legged species, the ninth species (a Sand Common, your 22 November call) is the four-legged Loamlet, so both plans keep a Sand creature. Costs: Greenwood's balance gate is re-run on both plans; the Meshy breeding pilot pair changes from Sloshcalf × Spadesnout to Sloshcalf × Loamlet (or Gorsling), and Spadesnout pairs with Mossmitt; Spadesnout's front legs become digging arms. The rival's first team (a level 1 Spadesnout) is unchanged.
2. **Ten species per biome from Crystal Deep on** (eight before), because Serpent and Winged need room, and the brief's full scale is 15 to 25. OK, or keep eight and thin the new plans?
3. **Two existing names sound close to other games' creatures:** Lanternell (close to an anglerfish creature called Lanturn) and, more mildly, Gulpmaw (Gulpin). Rename now, before art, or keep?
4. **Serpent and Winged plans:** confirm both, in this order: Serpent in Crystal Deep, Winged in Emberfall. Each needs its own rig, animation and balance pass, and Serpent needs two Assembler changes (`00_BREEDING_STANDARD.md` section 1.4).
5. **Rare-spawn species** (one per biome from Crystal Deep: Glowthread, Fusewick, Loomoth, Paperlume, Ouroring, Riftling): met only through bait or the daily sighting. It touches drops, so it is yours to approve. Until then they are Uncommon.
6. **Mythics:** one per player, bound, numbered like giants, gifted by the story, never wild and never sold. Can they breed (a Firstling part would be the rarest part in the game)? Is Nimbram obtainable at all, or a story presence only?
7. **The lore link:** the mentor's star fragment was a chip of the Firstling's glass; using it in his breeding experiment tore the sky and let the Unraveller through; the rival swallowed one of its black threads. Keep, change or drop?
8. **The Firstling's type:** Crystal (it beats the Cosmic entity, and stained glass is crystal). Or would you rather it had no fixed type, which needs new battle rules?
9. **The Hollow's giant changes type each phase.** A small change to the giant rules. OK?
10. **Status effects for biomes 6 to 10** (Static, Hex, Drift alongside the brief's Chill and Burn): fixed effects with no chance in them. OK to plan as battle rules?
11. **Arcane biome:** everything there is provisional until your references. Send them whenever ready; agent E redoes the looks to match.
12. **Names:** every name here is a placeholder, including the giants, the mythics and the entity, and needs the same check against other games as the launch names before art.
