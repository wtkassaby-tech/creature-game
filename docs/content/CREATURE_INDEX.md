# Creature index

Date: 23 November 2026. For: Ayrton (review and decisions) and the scaffold agents and lead (what each creature is, where its prompt lives, what still needs work).
Status: an index, not a design. Every name is a placeholder, and every line here repeats or checks what the source files say. Nothing in the scaffold files, the roster or the game data is changed by this page.

**Owner rule applied throughout (Ayrton, 23 November 2026; DECISIONS.md "Creature design follows the research"):** possible look-alikes of Pokémon or other franchises, in designs and in names, are **flagged, never changed**. Every design and name below is as the scaffold files have it. The Look-alike column says what a creature resembles, how closely, and the fallback the scaffold or name check offered, if any. Ayrton reviews each flag himself (section 2).

Sources: `creature_scaffold/00_ROSTER_PLAN.md` (roster, order, roles), `00_BREEDING_STANDARD.md`, the scaffolds `A_GREENWOOD_DUSTCANYON.md`, `B_TIDEFLATS_MIRE.md`, `C_FROST_CRYSTAL.md`, `D_EMBERFALL_STORMREACH.md`, `E_ARCANE.md` and `F_ABYSS_HOLLOW_MYTHIC.md` (designs, hooks, prompts, originality checks), `bibles/01` to `11` (mood per species, mascots), `names/check_1` to `check_6` (name ratings and alternatives), `docs/research/creatures/eras/00_SYNTHESIS.md` (the 17-point pre-Meshy checklist), `docs/research/creatures/loved/*`, `CREATURE_PERSONALITY.md`, `src/content/CreatureModels.luau`, `docs/ASSETS.md`, `docs/art/MESHY_PILOT.md` and `docs/DECISIONS.md`.

Contents:
1. Summary
2. Look-alike review (all flags in one place)
3. The index, biome by biome (#001 to #118)
4. Decisions for Ayrton
5. How the columns were filled

---

## 1. Summary

### 1a. Totals by biome

**118 entries:** 102 catchable species (101 across eleven biomes plus Halcyre, the Abyss's eleventh, Ayrton's own concept), 11 giants and 5 mythics (scaffold F adds Blackstitch as a proposed fifth, a story prop at launch). Plan counts are for the catchable species. "Flags" are design flags from the synthesis checklist (strong = fails a checklist point on concept grounds; mild = a fix worth considering). Look-alikes are counted as close / moderate (borderline and loose ones are listed in section 2).

| # | Biome (town) | Catchable | Giant | Quad / Biped / Winged / Serpent | Types | Moods: cute / cool / majestic / creepy-cute | Design flags strong / mild | Look-alikes close / moderate | Prompts written | Models in game |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | Greenwood (Thistledown) | 9 | Hollowbough | 4 / 5 / 0 / 0 | Leaf 5, Water 2, Sand 2 | 4 / 2 / 2 / 1 | 2 / 2 | 0 / 3 | 10 of 10 (A) | 9 of 10 |
| 2 | Dust Canyon (Kilnrest) | 8 | Mesalith | 4 / 4 / 0 / 0 | Sand 5, Leaf 2, Water 1 | 2 / 3 / 2 / 1 | 4 / 1 | 1 / 3 | 9 of 9 (A) | 9 of 9 |
| 3 | Tide Flats (Saltwick) | 8 | Carrackon | 4 / 4 / 0 / 0 | Water 6, Sand 2 | 2 / 3 / 2 / 1 | 0 / 2 | 1 / 3 | 9 of 9 (B) | 9 of 9 |
| 4 | The Mire (Sedgeholm) | 8 | Sloughback | 4 / 4 / 0 / 0 | Toxic 6, Water 2 | 2 / 2 / 1 / 3 | 0 / 2 | 0 / 2 | 9 of 9 (B) | 9 of 9 |
| 5 | Frostline (Rimewick) | 8 | Driftmother | 4 / 4 / 0 / 0 | Frost 6, Toxic 2 | 3 / 2 / 1 / 2 | 1 / 2 | 0 / 2 | 9 of 9 (C) | 0 |
| 6 | Crystal Deep (Glimmerholt) | 10 | Druseback | 3 / 3 / 0 / 4 | Crystal 7, Storm 2, Fire 1 | 3 / 3 / 2 / 2 | 2 / 0 | 0 / 0 | 11 of 11 (C) | 0 |
| 7 | Emberfall (Cinderwick) | 10 | Cinderhart | 3 / 3 / 2 / 2 | Fire 7, Leaf 2, Storm 1 | 3 / 4 / 2 / 1 | 2 / 2 | 1 / 1 | 11 of 11 (D) | 0 |
| 8 | Stormreach (Highwhistle) | 10 | Squallray | 2 / 2 / 6 / 0 | Storm 7, Sand 2, Cosmic 1 | 2 / 4 / 3 / 1 | 0 / 2 | 0 / 3 | 11 of 11 (D) | 0 |
| 9 | Arcane biome (Lanternmoor) | 10 | Bridgegrum | 3 / 3 / 2 / 2 | Arcane 7, Storm 2, Frost 1 | 3 / 4 / 1 / 2 | 1 / 5 | 0 / 3 | 11 of 11 (E, drafts until your references) | 0 |
| 10 | The Abyss (Starfold) | 11 | Starfathom | 3 / 2 / 3 / 3 | Cosmic 8, Arcane 2, Fire 1 | 2 / 4 / 4 / 1 | 1 / 4 | 0 / 3 | 12 of 12 (F) | 0 |
| 11 | The Hollow (Old Hearth) | 10 | Hearthwarden | 3 / 3 / 2 / 2 | one of each type | 1 / 4 / 3 / 2 | 4 / 0 | 0 / 0 | 11 of 11 (F) | 0 |
| | Mythics | (5) | | Quad 1, Biped 1, none 3 | Crystal 1, Cosmic 3, Storm 1 | majestic 2, creepy-cute 2, villain 1 | 0 / 1 | 0 / 4 | 5 of 5 (F) | 1 (Firstling) |
| | **Total** | **102** | **11** | **37 / 37 / 15 / 13** | | **27 / 35 / 23 / 17** (catchable) | **17 / 23** (40) | **3 / 27** | **118 of 118** | **37 of 118** |

Halcyre's mood is this index's reading (the Abyss bible was written before it): sleepy, wise, beautiful, so majestic.

### 1b. Totals by type, plan, role and mood (all 118)

| Type | Catchable | Giants | Mythics | All |
| --- | --- | --- | --- | --- |
| Leaf | 10 | 1 | | 11 |
| Water | 12 | 1 | | 13 |
| Sand | 12 | 1 | | 13 |
| Toxic | 9 | 1 | | 10 |
| Frost | 8 | 1 | | 9 |
| Crystal | 8 | 1 | 1 | 10 |
| Storm | 13 | 1 | 1 | 15 |
| Fire | 10 | 1 | | 11 |
| Arcane | 10 | 1 | | 11 |
| Cosmic | 10 | 1 | 3 | 14 |
| mixed | | 1 (Hearthwarden) | | 1 |

| Body plan | Catchable | Giants | Mythics | All |
| --- | --- | --- | --- | --- |
| Quad | 37 | 7 | 1 (Nimbram) | 45 |
| Biped | 37 | 2 | 1 (Frayling) | 40 |
| Winged | 15 | 1 | | 16 |
| Serpent | 13 | 1 | | 14 |
| none | | | 3 (Firstling, Unraveller, Blackstitch) | 3 |

| Role | Count | Notes |
| --- | --- | --- |
| starter | 3 | Mossmitt, Sloshcalf, Spadesnout (all also wild) |
| common | 69 | |
| uncommon | 24 | two per biome; three in the Abyss (with Halcyre) and the Hollow |
| rare | 6 | rare spawns: Glowthread, Fusewick, Loomoth, Paperlume, Ouroring, Riftling (Uncommon until Ayrton approves the bait and daily-sighting rule) |
| giant | 11 | one per biome |
| mythic | 5 | Frayling, Nimbram, Firstling, Unraveller (never caught), Blackstitch (proposed; story prop at launch) |
| gem-likely (★, overlaps the above) | 12 | Duneskit, Spirecap, Lanternell, Bulbroth, Glacibex, Prismquill, Glassgaffer, Vanecrest, Capgnome, Orrerback, Halcyre (second showcase), Tesserine |

| Mood (from the biome bibles) | Catchable (102) | Giants | Mythics | All |
| --- | --- | --- | --- | --- |
| cool | 35 (34%) | | | 35 |
| cute | 27 (26%) | | | 27 |
| majestic | 23 (23%) | 11 | 2 | 36 |
| creepy-cute | 17 (17%) | | 2 | 19 |
| villain | | | 1 | 1 |

### 1c. Launch batch (the first Meshy batch)

Greenwood, Dust Canyon and Tide Flats and their giants: **28 models** (#001 to #028; Spadesnout as a Biped and Loamlet as the ninth Greenwood species, per DECISIONS 23 November). All prompts are written (scaffolds A and B). 27 have a Roblox-generated stand-in in game; Loamlet has none. The Meshy pilot (Mossmitt, Sloshcalf, Spadesnout) has approved concept pictures but no 3D files back yet (the `art/meshy/` folders for them are empty).

Before these go to Meshy, the index finds:
- **6 strong design flags:** Stumpwarden and Splashjack (Greenwood); Whirlgrit, Thatchling, Spurlet and Spirecap (Dust Canyon). Dust Canyon is the weakest biome by the checklist (4 of 8 strong), and it is the second biome a player sees. **5 mild:** Sloshcalf, Spadesnout, Flintknap, Moatkeep, Hullock.
- **Look-alikes for review:** 2 close (Thatchling's name is taken by a Pathfinder 2e monster; Lanternell's name and lamp sit near Lanturn) and 9 moderate.
- **Names:** Cocklemole carries a safety flag (chat filter and jokes; not a franchise issue).

### 1d. Names and designs at a glance

- **Names changed: none** (owner rule). **Franchise look-alike name flags for review: 23** (1 taken: Thatchling; 22 similar). **Safety flags, not franchise: 3** (Cocklemole, Hoarmot, Portaloop), recommended for a change but Ayrton's call. **Hard to say or spell, optional: 21.** **Not checked: 2** (Halcyre, Ayrton's own name; Blackstitch, new in F).
- **Designs flagged: 40** (17 strong, 23 mild), plus Pebblepot (a retired alternative, an object with a face). Giants: none flagged.
- **Look-alikes: 3 close, 27 moderate, 8 borderline (a scaffold rated them "low to medium"), 74 loose, 6 none known.**

### 1e. Checking the mixes against the evidence

| Evidence (`loved/01`, `loved/06`, `eras/00_SYNTHESIS.md`) | Roster today | Verdict |
| --- | --- | --- |
| Cool is the largest group of loved designs (19 of the top 40, then cute 13, majestic 8) | Cool is the largest group of catchables (34%), and the largest or joint largest in 8 of 11 biomes. Greenwood and Frostline lean cute on purpose (the first hour; snow) and the Mire leans creepy-cute by theme, each argued in its bible | **In line.** Our cool share is below the polls' 48% partly because creepy-cute is counted separately here. No mix change needed |
| Fox, wolf, cat bodies and dragons are about half of favourites | Strictly canid or felid: 5 catchables (Glissot, Duneskit, Cometkit, Sphinxling, and Halcyre's cat-fox read) and one giant (Hearthwarden). With mustelids (Fenwhisk, Stinkglut), the fire lizard (Smoulderskink) and the dragon-coded serpents (Grotteel, Runecoil, Paperlume, Galaxeel, Ouroring): about 13% | **Gap.** The evidence is about favourites, not roster share, so these bodies belong in the showcase and mascot slots; Duneskit and Halcyre (★) hold two now. Unused spares that fill it: Frostline's snowshoe lynx kitten, the Arcane wisp-tailed marsh hound and griffin cub, Emberfall's ash badger (decision 4) |
| At least one dragon-line chase creature (Roblox trade lists are topped by dragons; `loved/06`: "keep a dragon family as a chase line") | The Firstling is now a long Eastern-style stained-glass dragon (Ayrton's Meshy model, adopted by scaffold F): the game's apex and its one true dragon, earned by finishing the story. No catchable dragon; Halcyre is a moon-crested dreamer, not a dragon. Dragon-coded kin: Smoulderskink, Grotteel, Runecoil (E kept "a dragon feel" in it), Paperlume, Galaxeel, Ouroring | **Met at the top, open below.** E asks you (its question 6) whether you want a dragon you can catch. A catchable dragon line, with the Firstling as its mythic apex, is the evidence's recommendation (decision 4) |
| The first biomes get the strongest designs (synthesis section 4, early commons) | 6 of the 17 strong flags are in the launch batch, 4 of them in Dust Canyon | **Fix before Meshy** (decision 4) |
| Starters: one cute, one cool, one odd (synthesis section 4) | Mossmitt cute, Spadesnout cool, Sloshcalf cute | **Small gap** (decision 4) |
| No template sets (synthesis anti-pattern 5) | Six Winged birds in Stormreach; two patterned-wing moths (Loomoth, Folioth); two optical-eye primates (Lensloris, Spyglint); two comet tails in one biome (Cometkit, Cometfinch); three trolls in the Arcane biome (Underbridge, Pebbletroll, Bridgegrum); two vessel bellies (Bulbroth, Embergrate); two upright frost rodents (Hoarmot, Chiselrime) | Flagged on the later creature of each pair |

**One tension resolved in the Signature column.** The breeding standard asks for three signature features on three parts (so a baby shows both parents); the synthesis asks for one signature feature with no competing ornament. The index names the **one hero feature** a player would call the creature by; the other two are supporting part markers and should stay quieter (smaller, in the main colour). Where four or more ornaments compete, the design is flagged as clutter.

---

## 2. Look-alike review

Nothing here is changed. Each line is for Ayrton to keep or swap. "Fallback" is what a scaffold or name check offered; where none was offered, it says so. Closeness: **close** (a player could say "that is X"), **moderate** (the same animal or idea plus a shared hook; scaffolds C and F call this "medium"), **borderline** (a scaffold rated it "low to medium"), **loose** (a shared archetype only). Scaffolds C, D, E and F each end with their own flag list; this section gathers them all, with the name checks.

### Close (3)

| # | Creature | Resembles | Where | Fallback offered |
| --- | --- | --- | --- | --- |
| #013 | Thatchling | "Thatchling", a Pathfinder 2e monster (Paizo, an undead plant creature): the name is **taken** | name | Strawsprig, Reedkin, Frondle (check 1) |
| #027 | Lanternell | Lanturn (an anglerfish lamp creature): one sound away, and both are glowing-lamp water creatures | name and idea | Pharolet, Buoyglow, Tidewick (B); Glowjell, Lampulet, Bobbelle (check 2) |
| #060 | Pyrecone | Pineco (a pine-cone creature): the same pine-cone idea and a near-rhyme name; D's question 7 asks you to keep it | name and design | Names: Scorchcone, Burrcone (check 4). No design fallback offered |

### Moderate (27)

| # | Creature | Resembles | Where | Fallback offered |
| --- | --- | --- | --- | --- |
| #004 | Loamlet | Skwovet and Greedent (cheek-stuffing squirrels); A: a vole, stub tail, sand not berries | design | none |
| #007 | Stumpwarden | Phantump and Trevenant (stump ghosts), Sudowoodo (a rock pretending to be a tree) | design | none |
| #010 | Hollowbough | "Hollow Bough", a biome (place) in Deep Rock Galactic; design loosely Torterra, Trevenant | name | Owlbough, Hollowelder, Gnarlbough (check 1) |
| #011 | Duneskit | Fennekin (big-eared desert fox); A: square slatted ears, no tufts, no fire | design | none |
| #012 | Whirlgrit | Baltoy (a one-footed spinning clay doll); A: two legs, pear body, normal face | design | none |
| #014 | Spurlet | Bulbasaur (a plant on a four-legged back) and Cacnea; the earlier model was redone for this | design | none |
| #022 | Gulpmaw | Gulpin (one sound away, per the roster plan; check 2 rated it clear) | name | Gapejaw, Mawpool, Snackwait (B) |
| #025 | Moatkeep | Sandygast (a sandcastle creature); B made it a toad wearing its turret | design | B question 3: keep it a living sandcastle instead |
| #028 | Carrackon | Carracosta (its name also comes from "carrack"); both carry a ship or shell. Design loosely Crustle, Dhelmise | name | Hullhermit, Galleonk, Shipwrackle (check 2) |
| #032 | Keelsnap | Drednaw (a snapping turtle); B: one keel ridge, stubby, mud brown | design | none |
| #034 | Mistrel | Munna and Musharna (dream tapirs, on the roster watch list); B: slate and moss, no pink. The name is also confused with "minstrel" | design | Names: Mossmurk, Hazelmist, Mizzlenose (check 2) |
| #042 | Stinkglut | Stunky and Skuntank (striped Toxic skunks) | design | Drop the side bands; sulphur only as the back crust (C) |
| #044 | Chiselrime | Bidoof and Bibarel (beavers) | design | An otter body with the same ice teeth and paddle, the spare "ice-fishing otter" (C) |
| #065 | Slagwallow | Hippowdon (a hippo with back vents); D: no vents, a slag crust | design | none |
| #069 | Gustlet | Wattrel (an Electric storm petrel); D: no electric markings | design | none |
| #070 | Puffchin | Minccino (a grey chinchilla) and the "no electric rodent" rule; D draws wind, no sparks | design | D question 5: the spare cloud-tufted mountain goat kid |
| #079 | Squallray | Mantine (a manta ray) | design | D question 6: a cloud whale with the same fight |
| #081 | Capgnome | Toad (Mario series, a mushroom-capped person), Shroomish and Breloom; E: cap colours reversed, a creature not a person | design | Names for readability only: Capnome, Shroomnome |
| #083 | Stringlet | Banette (a cursed puppet); E: a wooden ball-jointed toy, no zip mouth | design | none |
| #086 | Runecoil | Dratini and Dragonair (horned serpents); E: ink indigo with gold bands | design | Names: Glyphcoil, Sigilcoil, Scrollcoil (check 5) |
| #093 | Cometfinch | Taillow and Swellow (swallows with a forked tail) | design | One round comet fan instead of a fork (F) |
| #096 | Bolide | Talonflame and Fletchinder (fire falcons); the name sits near the French name Scobolide and a common word | design | An owl-shaped meteor (F); names Fireflit, Meteorhawk, Blazestoop (check 6) |
| #101 | Halcyre | Umbreon (a dark cat-fox with a ring on its brow), Lunala (cosmic bat) | design | Crest as a small full-moon orb on a stub, or freckles in silver (F) |
| #114 | The Frayling | Sackboy (LittleBigPlanet, a stitched doll), Banette; Mewtwo and Silvally (the lab-made role); name near Threadbare's "Fray" | design | Glued glass seams instead of stitches (F); names The Threadling, The Looseling, The Tatterling (check 6) |
| #115 | Nimbram | Dubwool (big-horned sheep), Mareep ("an electric sheep" is on the roster watch list) | design | Horns wreathed in a ring of cloud, fleece as one cloud bank (F) |
| #116 | The Firstling | Rayquaza (long sky dragon), Arceus (the "first creature" role), the Eastern dragon archetype | design | Fewer, larger panes and a shorter, plumper body (F); names The Patchling, The Elder Stitch, The Quiltling (check 6) |
| #117 | The Unraveller | The Beldam in Coraline (needle fingers, sewing theme), No-Face (Spirited Away); the name: "The Unraveler" (Hank), "The Unravelled" (Hollow Knight: Silksong), "Unravel" (EA) | design and name | Scissor-blade mitts instead of needles (F); names The Unpicker, The Snagweaver, The Rendweft (check 6) |

Also moderate, on a retired alternative: Pebblepot (Sinistea, Golett).

### Borderline (8, rated "low to medium" by their scaffold)

Glacibex (Skiddo, Gogoat; fallback: horns swept straight back; name "Glac-" like Glaceon, names Rimeibex, Frostibex, Icebex), Simmerling (Pansear, Simisear; fallback: a cheek ruff only, no head tuft), Glintbruin (Ursaring, Ursaluna; none needed), Prismquill (Sandslash, Chespin; prisms on the back only; names Prismspine, Glassquill, Spectrique), Thundegg (Palpitoad, Seismitoad, Bulbasaur's toad shape; none needed), Grotteel (Dratini, Milotic; fallback: a lower, wider crest), Slagworm (Slugma, Magcargo, Centiskorch; none needed), Censerling (Bronzong, Litwick, Chandelure, Koffing; fallback: a squat stone brazier body).

### Loose (74, archetype only)

Greenwood: Mossmitt (Breloom), Sloshcalf (Bulbasaur, back feature only), Spadesnout (Excadrill, Sandslash), Gorsling (Shaymin), Splashjack (Psyduck, Poliwag), Burlhorn (Torterra), Stiltbark (Sudowoodo's disguise gag).
Dust Canyon: Wadibuck (Sawsbuck), Flintknap (Kabutops), Cairnback (Stonjourner, Roggenrola), Spirecap (Stonjourner, Bonsly), Mesalith (Garganacl).
Tide Flats: Glissot (Oshawott, Buizel), Runnelfin (Inteleon, Goldeen), Cocklemole (Diglett, Excadrill), Clapshell (Clauncher, Crabrawler), Hullock (Torterra's island back).
Mire: Skipslick (Toxicroak), Fenwhisk (Furret, Linoone), Snaggar (Krookodile line, Barraskewda; name echo of Skylanders' Snagglescale), Lilyshade (Lotad line, Florges), Bogbellow (Tepig, Spoink), Bulbroth (Grimer, Morelull; "Bulb-" echoes Bulbasaur), Sloughback (Quagsire).
Frostline: Woolrime (Mamoswine, Bouffalant; name echoes Wooloo; names Shaggrime, Fleecefrost, Icefringe), Rimefern (Snorunt, Frosmoth), Driftmother (Lopunny, Diggersby).
Crystal Deep: Stalagrump (Graveler, Roggenrola, Sudowoodo), Forkhum (Chimecho, Bronzong), Drillgleam (Drilbur, Excadrill, Onix; "Drill-" like Drilbur), Glowthread (Spinarak, Joltik), Druseback (Wimpod, Golisopod).
Emberfall: Smoulderskink (Charmander, Salandit; kept four-legged on purpose), Ashbloom (Bellossom, Gossifleur), Ashflit (Woobat, Noibat), Glassgaffer (Heatmor), Magmeel (Eelektross; name Magmar, Magby; names Emberel, Lavaleel), Updrafter (Pidgeot, Braviary), Tongbeetle (Pinsir, Heracross), Fusewick (no close design; name echoes Litwick; names Fusecoil, Sparkfuse, Fizzfuse), Cinderhart (Xerneas).
Stormreach: Vanecrest (Torchic, Blaziken), Hailstoop (Rufflet, Talonflame), Kiteling (Drifloon), Duneswallow (Taillow), Thunderhump (Mareep, Bouffalant), Boomthroat (Cramorant, Pelipper), Loomoth (Frosmoth, Volcarona).
Arcane: Jackalorn (Lopunny, Sawsbuck; name from the public-domain jackalope; names Hareantler, Antlerhop, Mossjack), Rimefawn (Deerling, Xerneas, Galarian Ponyta), Folioth (Vivillon), Sparkowl (Noctowl, Decidueye, Zapdos; names Tuftspark, Zapowl, Flickerhoot), Pebbletroll (Geodude, Sudowoodo; name: the "Trolls" films, "Pebbles"; names Cobbletroll, Gravelgrum, Stonenub), Underbridge (Piloswine, Mamoswine), Paperlume (Litwick, Chandelure, the paper-dragon archetype).
Abyss: Orrerback (Torterra; fallback a flatter planisphere shell), Cometkit (Pachirisu, Minior; name: Warriors "-kit" naming; names Cometcub, Tailspark, Streakling), Spyglint (Binacle; fallback one monocular eye), Nebulark (Swablu, Altaria), Galaxeel (Dragonair, Milotic; name near common words), Portaloop (Wiglett, Wugtrio), Ouroring (Ekans, Seviper, the ouroboros), Starfathom (Gyarados, real oarfish).
Hollow: Mossaltar (Bulbasaur, Tauros), Sphinxling (Solgaleo, Litleo, Shinx), Tesserine (Sandslash; fallback a mosaic armadillo), Embergrate (Torkoal, Coalossal), Tapestrel (Mimikyu, Banette), Rimedove (Pidove, Articuno), Bannerwing (Talonflame), Fountcoil (Milotic, Gyarados), Riftling (Giratina, Dhelmise; name: "rift" is everywhere; names Seamling, Rendling, Splitlet), Hearthwarden (Regirock, Stoutland; fallback a stone lion; name: Sonaria wardens, Hearthstone; names Hearthhound, Stonewarden, Ashwarden).
Mythic: Blackstitch (yarn-ball creatures in general).

**None known (6):** Flurrlem, Hoarmot, Lensloris, Gritgoyle, Bridgegrum (folklore), Hourling.

Outside the creature list, check 6 also flags the game name **ClayPals** ("Pals" is Palworld's core word; "Claymates" is a clay-toy mark) and the town **Thistledown** (a racetrack and small companies).

---

## 3. The index

Column key: **Plan** Q = Quad, B = Biped, W = Winged, S = Serpent. **Role** is the rarity role; ★ = gem-likely (a gem showcase). **Signature** is the one hero feature and the part that owns it. **Mood** is from the biome bible. **Name check** is from `names/check_*`. **Look-alike**: section 2. **Design flags**: "pass", or the checklist point it fails with a fix to consider (a flag, not a change: the owner's call). **Prompt** links to the scaffold section. **Model**: what the game shows today.

Links are relative to this file (`docs/content/`).

### 1 · Greenwood (Leaf) · Thistledown · 3v3

Bible mix 4 cute / 2 cool / 2 majestic / 1 creepy-cute (cute on purpose: the first hour). Mascot candidate: Mossmitt.

| # | Name | Type | Plan | Role | One-line hook | Signature | Mood | Name check | Look-alike | Design flags | Prompt | Model |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| #001 | Mossmitt | Leaf | B | starter | The little champion with two huge moss boxing mitts | moss mitts (arms) | cute | clear | loose: Breloom | pass | [A](creature_scaffold/A_GREENWOOD_DUSTCANYON.md#mossmitt) | Roblox generator; Meshy pilot (concept approved, 3D not back) |
| #002 | Sloshcalf | Water | Q | starter | Shy calf carrying a tiny fish pond in a dome on its back | pond dome (torso) | cute | clear | loose: Bulbasaur (back feature only) | mild: head clutter (lily-pad ears, stone horns and sprout): drop the horns; and the starter trio lacks an "odd" pick (decision 4) | [A](creature_scaffold/A_GREENWOOD_DUSTCANYON.md#sloshcalf) | Roblox generator; Meshy pilot (concept approved, 3D not back) |
| #003 | Spadesnout | Sand | B (decided 23 Nov; Q prompt kept as fallback) | starter | Smug riverbank digger, proud of every hole it digs | trowel snout (head) | cool | clear | loose: Excadrill, Sandslash | mild: five ornaments (snout, pebble, back plates, claws, pebble-knob tail): drop the tail knob | [A](creature_scaffold/A_GREENWOOD_DUSTCANYON.md#spadesnout) | Roblox generator (four-legged); Meshy pilot (concept approved, 3D not back) |
| #004 | Loamlet | Sand | Q | common | Vole that packs sand into its cheeks until its face is twice its size | sand cheek pouches (head) | cute | clear (kids: "loam" is uncommon) | moderate: Skwovet, Greedent | pass | [A](creature_scaffold/A_GREENWOOD_DUSTCANYON.md#loamlet-new-if-spadesnout-becomes-a-biped) | to do |
| alt | Pebblepot (retired while Spadesnout is a Biped) | Sand | B | common | Pot-shaped riverbank creature with a lid head | lid head | (none set) | not checked | moderate: Sinistea, Golett | strong: an object with a face (A says so itself): keep retired | [A](creature_scaffold/A_GREENWOOD_DUSTCANYON.md#pebblepot-alternative-ninth-only-if-spadesnout-stays-a-quad) | none |
| #005 | Gorsling | Leaf | Q | common (token gift) | Twitchy hedge runner that sheds yellow blossom when excited | gorse-blossom ears (head) | cool | clear | loose: Shaymin | pass | [A](creature_scaffold/A_GREENWOOD_DUSTCANYON.md#gorsling) | Roblox generator ("may want redoing", DECISIONS) |
| #006 | Splashjack | Water | B | common | Giddy puddle-jumper with absurd swim-fin feet | swim-fin feet (legs) | cute | clear | loose: Psyduck, Poliwag | strong: a mash-up with no single signature (ladle bill, periscope eyes, beaver tail, fin feet; A: "no single source"): keep the fin feet, plain the head and tail | [A](creature_scaffold/A_GREENWOOD_DUSTCANYON.md#splashjack) | Roblox generator |
| #007 | Stumpwarden | Leaf | B | common (quest gift) | Patient stump that plants itself in your path and nods once | fungus brow and single leaf (head) | majestic | clear | moderate: Phantump, Trevenant, Sudowoodo | strong: a plant with a face and no animal body (synthesis, Leaf forest): give it an animal frame (for example a badger-built guardian whose back is the stump), or accept it as the one plant | [A](creature_scaffold/A_GREENWOOD_DUSTCANYON.md#stumpwarden) | Roblox generator |
| #008 | Burlhorn | Leaf | Q | uncommon | The biggest, softest grump; flowers grow in its burl and it pretends not to notice | knotted burl (torso) | majestic | clear | loose: Torterra | pass | [A](creature_scaffold/A_GREENWOOD_DUSTCANYON.md#burlhorn) | Roblox generator |
| #009 | Stiltbark | Leaf | B | uncommon | Nervous wader on birch stilts that believes its reed disguise works | birch-twig stilts (legs) | creepy-cute | clear | loose: Sudowoodo (disguise gag only) | pass | [A](creature_scaffold/A_GREENWOOD_DUSTCANYON.md#stiltbark) | Roblox generator |
| #010 | Hollowbough | Leaf | Q | giant | The walking elder tree with owl families in its hollows | owl hollows (torso) | majestic | similar: Owlbough / Hollowelder / Gnarlbough | moderate (name): Deep Rock Galactic's "Hollow Bough" | pass | [A](creature_scaffold/A_GREENWOOD_DUSTCANYON.md#hollowbough-giant-creature-form) | Roblox generator |

### 2 · Dust Canyon (Sand) · Kilnrest · 3v3

Bible mix 2 cute / 3 cool / 2 majestic / 1 creepy-cute. Mascot candidate: Duneskit.

| # | Name | Type | Plan | Role | One-line hook | Signature | Mood | Name check | Look-alike | Design flags | Prompt | Model |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| #011 | Duneskit ★ | Sand | Q | common, gem-likely (token gift) | Cocky dune racer whose slatted ears snap flat when it runs | shutter-slat ears (head) | cool | clear | moderate: Fennekin | pass | [A](creature_scaffold/A_GREENWOOD_DUSTCANYON.md#duneskit-) | Roblox generator |
| #012 | Whirlgrit | Sand | B | common | Joyful spinner that lifts a ring of sand | spinning-top head | cool | clear | moderate: Baltoy | strong: an object (a spinning top) with no animal anchor, one idea told three times (head, belly, tail): anchor it on an animal (for example a jerboa) and let the spin be its behaviour | [A](creature_scaffold/A_GREENWOOD_DUSTCANYON.md#whirlgrit) | Roblox generator |
| #013 | Thatchling | Leaf | B | common | It waves both pompom hands at you first, always | pompom hands (arms) | cute | **taken** (Pathfinder 2e): Strawsprig / Reedkin / Frondle | close (name) | strong: a "sprite" with no animal anchor, and the current model is a haystack with a face: anchor it on an animal (for example a weaver bird or jerboa) wearing thatch as its coat | [A](creature_scaffold/A_GREENWOOD_DUSTCANYON.md#thatchling) | Roblox generator |
| #014 | Spurlet | Leaf | Q | common | Sun-drunk succulent that blooms once a year when nobody watches | shingled rosette (torso) | cute | clear | moderate: Bulbasaur, Cacnea | strong: a plant with a face and no animal anchor: make the succulent the skin of a named animal (for example a gecko), keeping the rosette low | [A](creature_scaffold/A_GREENWOOD_DUSTCANYON.md#spurlet) | Roblox generator |
| #015 | Wadibuck | Water | Q | common | Skittish deer whose glass-tube horns fill in flash floods; it hums before rain | water-filled horns (head) | majestic | clear (kids: "wadi") | loose: Sawsbuck | pass | [A](creature_scaffold/A_GREENWOOD_DUSTCANYON.md#wadibuck) | Roblox generator |
| #016 | Flintknap | Sand | B | common (quest gift) | Fussy craftsman who re-sharpens its flint hand-axe hands | flint blades (arms) | cool | clear (silent k; Flintchip optional) | loose: Kabutops | mild: no animal anchor named: name one (for example a monitor lizard) so the blades are the twist | [A](creature_scaffold/A_GREENWOOD_DUSTCANYON.md#flintknap) | Roblox generator |
| #017 | Cairnback | Sand | Q | uncommon | Patient trail guide with a tidy cairn of trail stones on its back | cairn (torso) | creepy-cute | clear (kids: "cairn"; Rubbleback optional) | loose: Stonjourner, Roggenrola | pass (the goat body answers the boulder-with-eyes risk) | [A](creature_scaffold/A_GREENWOOD_DUSTCANYON.md#cairnback) | Roblox generator |
| #018 | Spirecap ★ | Sand | B | uncommon, gem-likely | Dignified sentinel balancing a capstone, its eyes always glancing up to check | capstone (head) | majestic | clear | loose: Stonjourner, Bonsly | strong: a rock with a face (the bible's boulder-with-eyes risk) on the biome's gem showcase: give it an animal anchor (for example a meerkat-like sentinel) with the capstone grown on | [A](creature_scaffold/A_GREENWOOD_DUSTCANYON.md#spirecap-) | Roblox generator |
| #019 | Mesalith | Sand | B | giant | A whole serene mesa you can befriend, a garden on its back | mesa head and strata | majestic | clear | loose: Garganacl, Stonjourner | pass (giants may read as a force of nature) | [A](creature_scaffold/A_GREENWOOD_DUSTCANYON.md#mesalith-giant-creature-form) | Roblox generator |

### 3 · Tide Flats (Water) · Saltwick · 3v3

Bible mix 2 cute / 3 cool / 2 majestic / 1 creepy-cute. Mascot candidate: Runnelfin.

| # | Name | Type | Plan | Role | One-line hook | Signature | Mood | Name check | Look-alike | Design flags | Prompt | Model |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| #020 | Glissot | Water | Q | common | Panting sea-hound pup that jogs on the spot while it waits for a wave | wave-curl crest (head) | cool | clear | loose: Oshawott, Buizel | pass | [B](creature_scaffold/B_TIDEFLATS_MIRE.md#glissot) | Roblox generator |
| #021 | Runnelfin | Water | B | common | Sail-crested dancer that dances every runnel the tide leaves | sail crest (head) | cool | clear | loose: Inteleon, Goldeen | pass | [B](creature_scaffold/B_TIDEFLATS_MIRE.md#runnelfin) | Roblox generator |
| #022 | Gulpmaw | Water | Q | common | Rock-pool toad that is one huge hopeful grin, eyes on stalks | all-mouth grin (head) | cute | similar (roster plan; check 2: clear): Gapejaw / Mawpool / Snackwait | moderate (name): Gulpin | pass | [B](creature_scaffold/B_TIDEFLATS_MIRE.md#gulpmaw) | Roblox generator |
| #023 | Cocklemole | Sand | Q | common | Star-nosed mole peeking from under a crooked cockle-shell helmet | cockle helmet (head) | cute | **safety** ("Cock-": chat filter, jokes): Shellmole / Scallopmole / Whelkmole | loose: Diglett, Excadrill | pass | [B](creature_scaffold/B_TIDEFLATS_MIRE.md#cocklemole) | Roblox generator |
| #024 | Clapshell | Water | B | common (quest gift) | Applause-seeker that claps its scallop-shell hands for you | scallop-shell hands (arms) | cool | clear | loose: Clauncher, Crabrawler | pass | [B](creature_scaffold/B_TIDEFLATS_MIRE.md#clapshell) | Roblox generator |
| #025 | Moatkeep | Sand | B | common (token gift) | Fussy toad that rebuilds the sandcastle turret on its head after every wave | turret (head) | creepy-cute | clear | moderate: Sandygast | mild: the turret reads as a worn hat (costume): grow it from the skull | [B](creature_scaffold/B_TIDEFLATS_MIRE.md#moatkeep) | Roblox generator |
| #026 | Hullock | Water | Q | uncommon | Grandpa shore ox whose barnacle saddle has three sleepy faces of its own | barnacle saddle (torso) | majestic | clear | loose: Torterra | mild: two gags (the hull ox and three extra faces competing with its own): one barnacle face or none | [B](creature_scaffold/B_TIDEFLATS_MIRE.md#hullock) | Roblox generator |
| #027 | Lanternell ★ | Water | B | uncommon, gem-likely | Seal-pup face under a lamp dome that glows brighter when someone is lost | lamp dome (head) | majestic | similar: Pharolet / Buoyglow / Tidewick | close: Lanturn | pass | [B](creature_scaffold/B_TIDEFLATS_MIRE.md#lanternell) | Roblox generator |
| #028 | Carrackon | Water | Q | giant | Crab king wearing a whole shipwreck, crowned with conch spikes | wrecked ship (torso) | majestic | similar: Hullhermit / Galleonk / Shipwrackle | moderate (name): Carracosta | pass | [B](creature_scaffold/B_TIDEFLATS_MIRE.md#carrackon) | Roblox generator |

### 4 · The Mire (Toxic) · Sedgeholm · 4v4

Bible mix 2 cute / 2 cool / 1 majestic / 3 creepy-cute (the theme is the mood). Mascot candidate: Bulbroth.

| # | Name | Type | Plan | Role | One-line hook | Signature | Mood | Name check | Look-alike | Design flags | Prompt | Model |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| #029 | Skipslick | Toxic | B | common | Tangerine frog showman that keeps score of every jump | lily-pad feet (legs) | cute | clear | loose: Toxicroak | pass | [B](creature_scaffold/B_TIDEFLATS_MIRE.md#skipslick) | Roblox generator |
| #030 | Fenwhisk | Toxic | Q | common | Smug weasel whose bulrush tail gives away every hiding place | bulrush tail | cool | clear | loose: Furret, Linoone | pass | [B](creature_scaffold/B_TIDEFLATS_MIRE.md#fenwhisk) | Roblox generator |
| #031 | Snaggar | Toxic | Q | common | A far-too-wide friendly grin, with a bird's nest on its back | the grin (head) | cool | clear | loose: Krookodile line, Barraskewda | mild: mood label conflict (bible: cool; scaffold B: "spooky-cute slot"): pick one | [B](creature_scaffold/B_TIDEFLATS_MIRE.md#snaggar) | Roblox generator |
| #032 | Keelsnap | Toxic | B | common | Grumpy beak, kind eyes; brings a flat stone to the one it likes | keel shell with a sprout (torso) | creepy-cute | clear | moderate: Drednaw | pass | [B](creature_scaffold/B_TIDEFLATS_MIRE.md#keelsnap) | Roblox generator |
| #033 | Lilyshade | Water | B | common | Serene newt crowned with a frost-tipped water lily, never seen hurrying | water-lily crown (head) | creepy-cute | clear | loose: Lotad line, Florges | pass | [B](creature_scaffold/B_TIDEFLATS_MIRE.md#lilyshade) | Roblox generator |
| #034 | Mistrel | Water | Q | common (token gift) | Shy tapir that hides in fog it made and picks only one friend | moss fringe and shawl | majestic | similar ("minstrel", "mistral"): Mossmurk / Hazelmist / Mizzlenose | moderate: Munna, Musharna | pass | [B](creature_scaffold/B_TIDEFLATS_MIRE.md#mistrel) | Roblox generator |
| #035 | Bogbellow | Toxic | Q | uncommon | Laughing bog boar whose peat back puffs green from three chimneys | chimney peat mound (torso) | cute | clear | loose: Tepig, Spoink | pass | [B](creature_scaffold/B_TIDEFLATS_MIRE.md#bogbellow) | Roblox generator |
| #036 | Bulbroth ★ | Toxic | B | uncommon (quest gift), gem-likely | Frog cook whose broth-pot belly bubbles for guests who never come | broth-pot belly (torso) | creepy-cute | clear (mild "Bulb-") | loose: Grimer, Morelull | mild: the chef's hat reads as clothing, and four features compete (hat, belly, ladle hands, water-bag tail): make the cap a grown puffball, quiet the hands | [B](creature_scaffold/B_TIDEFLATS_MIRE.md#bulbroth) | Roblox generator |
| #037 | Sloughback | Toxic | Q | giant | Hill of a sleeping salamander with a fungus staircase on its muddy back | mud crust and fungus shelves (torso) | majestic | clear (kids: "slough"; Sluffback optional) | loose: Quagsire | pass | [B](creature_scaffold/B_TIDEFLATS_MIRE.md#sloughback) | Roblox generator |

### 5 · Frostline (Frost) · Rimewick · 4v4 · slow and tanky

Bible mix 3 cute / 2 cool / 1 majestic / 2 creepy-cute. Mascot candidate: Glacibex. Breeding stat: Defence on the front limbs (every species has frost cuffs, greaves or gauntlets). The bible notes there is no canid or felid here and proposes promoting the snowshoe lynx kitten spare.

| # | Name | Type | Plan | Role | One-line hook | Signature | Mood | Name check | Look-alike | Design flags | Prompt | Model |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| #038 | Flurrlem | Frost | Q | common | A tiny lemming in snow goggles that always leads a line of one | snow-goggle band (head) | cute | clear | none known | mild: a goggle band reads as worn gear (no clothing): paint it as a fur mask marking | [C](creature_scaffold/C_FROST_CRYSTAL.md#flurrlem) | to do |
| #039 | Glacibex ★ | Frost | Q | common, gem-likely | Cliff ibex with ring-curled horns of packed blue ice and ice greaves | ring-curled ice horns (head) | cool | similar: Rimeibex / Frostibex / Icebex | borderline: Skiddo, Gogoat; name Glaceon | pass | [C](creature_scaffold/C_FROST_CRYSTAL.md#glacibex) | to do |
| #040 | Hoarmot | Frost | B | common | Upright marmot that whistles to warn of the weather | frost-feather crest (head) | cute | **safety** (a rude sound-alike said aloud): Frostmot / Rimemot / Snowmarm | none known | pass | [C](creature_scaffold/C_FROST_CRYSTAL.md#hoarmot) | to do |
| #041 | Rimefern | Frost | B | common (token gift) | Frost-fern window sprite with fiddlehead hands | frost-fern crest (head) | cute | clear | loose: Snorunt, Frosmoth | strong: a sprite with no animal anchor: anchor it (for example a stoat or snow mouse whose ears and tail are frost fronds) | [C](creature_scaffold/C_FROST_CRYSTAL.md#rimefern) | to do |
| #042 | Stinkglut | Toxic (Fire move on torso) | Q | common | Wolverine glutton that naps curled on the hot vents | sulphur bands and spring stone (torso) | creepy-cute | clear | moderate: Stunky, Skuntank | pass | [C](creature_scaffold/C_FROST_CRYSTAL.md#stinkglut) | to do |
| #043 | Simmerling | Toxic (Fire move on torso) | B | common | Hot-spring macaque with a folded bath towel of fur on its head | towel tuft (head) | creepy-cute | clear | borderline: Pansear, Simisear | pass | [C](creature_scaffold/C_FROST_CRYSTAL.md#simmerling) | to do |
| #044 | Chiselrime | Frost | B | uncommon (quest gift, C's proposal) | Russet beaver with ice-chisel teeth that cuts the fishing holes on Glass Lake | ice-chisel teeth (head) | cool | clear | moderate: Bidoof, Bibarel | mild: the second upright frost rodent with Hoarmot (bible risk 3: shared proportions): keep their silhouettes apart | [C](creature_scaffold/C_FROST_CRYSTAL.md#chiselrime) | to do |
| #045 | Woolrime | Frost | Q | uncommon (the roster plan's quest gift) | Musk ox in a knitted frost coat with a fringe of chiming icicles | icicle fringe (torso) | majestic | similar: Shaggrime / Fleecefrost / Icefringe | loose: Mamoswine, Bouffalant | pass | [C](creature_scaffold/C_FROST_CRYSTAL.md#woolrime) | to do |
| #046 | Driftmother | Frost | Q | giant | Hill-sized snow hare whose back is a snowfield with a stand of pines | snowfield back (torso) | majestic | clear | loose: Lopunny, Diggersby | pass | [C](creature_scaffold/C_FROST_CRYSTAL.md#driftmother) | to do |

### 6 · Crystal Deep (Crystal) · Glimmerholt · 4v4 · Ruby tier · Serpent debuts

Bible mix 3 cute / 3 cool / 2 majestic / 2 creepy-cute. Mascot candidate: Prismquill (the Ruby showcase). Breeding stat: Attack on the heads. Ruby red is reserved for the Ruby tier (no look uses it). Scaffold C owns the Serpent plan's conventions.

| # | Name | Type | Plan | Role | One-line hook | Signature | Mood | Name check | Look-alike | Design flags | Prompt | Model |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| #047 | Prismquill ★ | Crystal | Q | common, gem-likely (Ruby showcase) | Porcupine whose blunt prism quills throw rainbows | prism quills (torso) | cute | similar: Prismspine / Glassquill / Spectrique | borderline: Sandslash, Chespin | pass | [C](creature_scaffold/C_FROST_CRYSTAL.md#prismquill) | to do |
| #048 | Lensloris | Crystal | B | common | Slow loris with crystal lens rims round huge, permanently startled eyes | crystal lens rims (head) | cute | clear | none known | pass | [C](creature_scaffold/C_FROST_CRYSTAL.md#lensloris) | to do |
| #049 | Thundegg | Storm (Frost move on torso) | Q | common | Thunderegg-geode toad that crackles with static when it puffs up | geode body with quartz crack (torso) | creepy-cute | clear (spelling: Thunderock / Zapgeode) | borderline: Palpitoad, Seismitoad | pass | [C](creature_scaffold/C_FROST_CRYSTAL.md#thundegg) | to do |
| #050 | Forkhum | Storm (Frost move on torso) | B | common | Slender creature whose tuning-fork head hums off key and sparks | tuning-fork prongs (head) | cool | clear | loose: Chimecho, Bronzong | strong: an object for a head with no animal anchor: anchor it (for example a cave cricket or bat-eared jerboa) with fork-shaped antennae or ears | [C](creature_scaffold/C_FROST_CRYSTAL.md#forkhum) | to do |
| #051 | Grotteel | Crystal (Water move on head) | S | common (token gift) | Pale cave-lake eel with a chiming crystal crest | crystal crest (head) | cool | clear | borderline: Dratini, Milotic | pass (dragon-coded, 1e) | [C](creature_scaffold/C_FROST_CRYSTAL.md#grotteel) | to do |
| #052 | Drillgleam | Crystal | S | common | Soft ringed worm that bores through rock with a spiral crystal drill horn | crystal drill horn (head) | cool | clear | loose: Drilbur, Excadrill, Onix | pass | [C](creature_scaffold/C_FROST_CRYSTAL.md#drillgleam) | to do |
| #053 | Slagworm | Fire | S | common | Fat, slow magma worm crusted with cooling slag (the Emberfall teaser) | slag crust (torso) | cute | clear | borderline: Slugma, Magcargo | pass | [C](creature_scaffold/C_FROST_CRYSTAL.md#slagworm) | to do |
| #054 | Stalagrump | Crystal | B | uncommon | Dripstone grump with a fringe of stalactites over its eyes | stalactite fringe (head) | creepy-cute | clear | loose: Graveler, Roggenrola, Sudowoodo | strong: a dripstone lump with a face, no animal anchor (synthesis, Crystal caves): anchor it (for example an olm or mole-rat) with the fringe as the twist | [C](creature_scaffold/C_FROST_CRYSTAL.md#stalagrump) | to do |
| #055 | Glintbruin | Crystal | Q | uncommon (quest gift) | Gentle cave bear whose amethyst ridge grows a ring a year | amethyst spine ridge (torso) | majestic | clear | borderline: Ursaring, Ursaluna | pass | [C](creature_scaffold/C_FROST_CRYSTAL.md#glintbruin) | to do |
| #056 | Glowthread | Crystal | S | rare | Night-speckled glowworm serpent that hangs silk tassels like stars | silk tassels and beads (tail) | majestic | clear | loose: Spinarak, Joltik | pass | [C](creature_scaffold/C_FROST_CRYSTAL.md#glowthread) | to do |
| #057 | Druseback | Crystal | Q | giant | Colossal pillbug whose back plates are geode halves; it rolls up and charges | geode plates (torso) | majestic | clear (spelling: Geodeback / Quartzback) | loose: Wimpod, Golisopod | pass | [C](creature_scaffold/C_FROST_CRYSTAL.md#druseback) | to do |

### 7 · Emberfall (Fire) · Cinderwick · 5v5 · Winged debuts

Bible mix 3 cute / 4 cool / 2 majestic / 1 creepy-cute. Mascot candidate: Smoulderskink. Breeding stat: Attack on the front limbs.

| # | Name | Type | Plan | Role | One-line hook | Signature | Mood | Name check | Look-alike | Design flags | Prompt | Model |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| #058 | Smoulderskink | Fire | Q | common | The biome's fire lizard: a stocky skink with painted ember cracks | cracked basalt scales (torso) | cute | clear (spelling: Cinderskink / Glowskink) | loose: Charmander, Salandit | pass (dragon-coded, 1e) | [D](creature_scaffold/D_EMBERFALL_STORMREACH.md#smoulderskink) | to do |
| #059 | Ashbloom | Leaf (Water move on torso) | B | common | Brave fireweed sprite with a tall pink flower spike | flower spike (head) | cute | clear | loose: Bellossom, Gossifleur | strong: a plant sprite with no animal anchor: anchor it (for example a pika or jerboa whose crest is the spike) | [D](creature_scaffold/D_EMBERFALL_STORMREACH.md#ashbloom) | to do |
| #060 | Pyrecone | Leaf (Water move on torso) | Q | common | Shy pine cone on legs that opens its scales only after a fire | cone-scale body (torso) | cute | similar: Scorchcone / Burrcone | close: Pineco | strong: an object with a face (a cone on legs, anti-pattern 1): give it an animal anchor with cone scales as its coat (for example a round shrew or piglet) | [D](creature_scaffold/D_EMBERFALL_STORMREACH.md#pyrecone) | to do |
| #061 | Ashflit | Fire | W | common | Sleepy pocket bat with ember-veined wings, surprised every time it wakes | ember-veined wings | cool | clear | loose: Woobat, Noibat | pass | [D](creature_scaffold/D_EMBERFALL_STORMREACH.md#ashflit) | to do |
| #062 | Glassgaffer ★ | Fire (Crystal move on head) | B | common (token gift), gem-likely | Puff-cheeked glassblower with an amber glass bubble on its snout | glass-bubble snout (head) | creepy-cute | clear (kids: "gaffer") | loose: Heatmor | mild: animal anchor unnamed ("a round cream pear"): name one (for example a tapir) so the snout is the twist | [D](creature_scaffold/D_EMBERFALL_STORMREACH.md#glassgaffer) | to do |
| #063 | Magmeel | Fire | S | common | Lava-river eel wearing an obsidian plate on its head | obsidian head plate | cool | similar: Emberel / Lavaleel | loose: Eelektross; name Magmar, Magby | pass | [D](creature_scaffold/D_EMBERFALL_STORMREACH.md#magmeel) | to do |
| #064 | Updrafter | Storm | W | common | Calm soarer with a rudder crest that rides the volcano's thermals (the Stormreach teaser) | rudder crest (head) | majestic | clear | loose: Pidgeot, Braviary | pass | [D](creature_scaffold/D_EMBERFALL_STORMREACH.md#updrafter) | to do |
| #065 | Slagwallow | Fire | Q | uncommon | Lazy magma-mud hippo with a cooling slag crust on its back | slag-crust back (torso) | majestic | clear | moderate: Hippowdon | pass | [D](creature_scaffold/D_EMBERFALL_STORMREACH.md#slagwallow) | to do |
| #066 | Tongbeetle | Fire | B | uncommon (quest gift) | Gruff blacksmith beetle with tong mandibles and hammer fists | hammer fists (arms) | cool | clear | loose: Pinsir, Heracross | pass | [D](creature_scaffold/D_EMBERFALL_STORMREACH.md#tongbeetle) | to do |
| #067 | Fusewick | Fire | S | rare | Jittery firecracker serpent whose banded tail ends in a fizzing fuse | fuse tail | cool | similar (mild): Fusecoil / Sparkfuse / Fizzfuse | loose (name): Litwick | mild: rarity fit (checklist 13): a rare spawn smaller and plainer than the common Magmeel; give it the rarer silhouette | [D](creature_scaffold/D_EMBERFALL_STORMREACH.md#fusewick) | to do |
| #068 | Cinderhart | Fire | Q | giant | Colossal stag with smoking basalt-column antlers and glowing hoofprints | basalt antlers (head) | majestic | clear | loose: Xerneas | pass | [D](creature_scaffold/D_EMBERFALL_STORMREACH.md#cinderhart) | to do |

### 8 · Stormreach (Storm) · Highwhistle · 5v5 · first sight of the tear

Bible mix 2 cute / 4 cool / 3 majestic / 1 creepy-cute. Mascot candidate: Vanecrest. Breeding stat: Speed on the wings. Bible risk 1: six Winged species can blur into one bird; D varies wings, heads and tails.

| # | Name | Type | Plan | Role | One-line hook | Signature | Mood | Name check | Look-alike | Design flags | Prompt | Model |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| #069 | Gustlet | Storm | W | common | Tiny petrel that pitter-patters across the cloud sea on huge gold feet | huge gold feet (legs) | cute | clear | moderate: Wattrel | pass | [D](creature_scaffold/D_EMBERFALL_STORMREACH.md#gustlet) | to do |
| #070 | Puffchin | Storm | Q | common | Featherweight puffball the wind keeps bouncing along the ridges | tufted puff body (torso) | cute | clear (reads as a typo of "puffin"; Puffbun / Fluffchin) | moderate: Minccino | pass | [D](creature_scaffold/D_EMBERFALL_STORMREACH.md#puffchin) | to do |
| #071 | Vanecrest ★ | Storm | W | common, gem-likely | Know-it-all rooster whose copper weathervane tail points at storms | weathervane tail | cool | clear | loose: Torchic, Blaziken | pass | [D](creature_scaffold/D_EMBERFALL_STORMREACH.md#vanecrest) | to do |
| #072 | Hailstoop | Storm | W | common | Teapot-sized hawk with hailstone-dotted feathers that drops like hail | hailstone feathers | cool | clear | loose: Rufflet, Talonflame | pass | [D](creature_scaffold/D_EMBERFALL_STORMREACH.md#hailstoop) | to do |
| #073 | Kiteling | Storm | B | common | Small laughing creature whose tail ends in its own living kite | kite tail | cool | clear | loose: Drifloon | mild: animal anchor unnamed and the kite sits close to a prop: keep the kite a solid fin joined to the tail (no tether), and name the animal | [D](creature_scaffold/D_EMBERFALL_STORMREACH.md#kiteling) | to do |
| #074 | Duneswallow | Sand (Arcane move on torso) | W | common | Plucky sand martin blown up the peaks from the desert | eye mask (head) | majestic | clear (reads as the verb) | loose: Taillow | mild: a plain swallow with a mask: give it one twist part (for example dune-ripple wings) | [D](creature_scaffold/D_EMBERFALL_STORMREACH.md#duneswallow) | to do |
| #075 | Gritgoyle | Sand (Arcane move on torso) | B | common | Sandblasted gargoyle grump that sits so still pigeons nest on it | wing stubs (torso) | cool | clear (spelling: Gritgarg / Sandgoyle) | none known (folklore) | pass | [D](creature_scaffold/D_EMBERFALL_STORMREACH.md#gritgoyle) | to do |
| #076 | Thunderhump | Storm | Q | uncommon | Gentle bison whose hump is a rumbling storm cloud | storm-cloud hump (torso) | majestic | clear | loose: Mareep, Bouffalant | pass | [D](creature_scaffold/D_EMBERFALL_STORMREACH.md#thunderhump) | to do |
| #077 | Boomthroat | Storm | W | uncommon (quest gift) | Showman frigatebird that drums a red chest pouch like thunder | drum pouch (torso) | majestic | clear | loose: Cramorant, Pelipper | pass | [D](creature_scaffold/D_EMBERFALL_STORMREACH.md#boomthroat) | to do |
| #078 | Loomoth | Cosmic | W | rare (token gift) | Pale moth with a stitched starfield on its wings, seen only since the tear | starfield wings | creepy-cute | clear (spelling: Starmoth / Weavemoth) | loose: Frosmoth, Volcarona | pass | [D](creature_scaffold/D_EMBERFALL_STORMREACH.md#loomoth) | to do |
| #079 | Squallray | Storm | W | giant | Colossal smiling sky manta that glides inside the Anvil's storm cloud | lightning-trimmed fin-wings | majestic | clear | moderate: Mantine | pass | [D](creature_scaffold/D_EMBERFALL_STORMREACH.md#squallray) | to do |

### 9 · The Arcane biome (Arcane) · Lanternmoor · 5v5 · provisional

Bible mix 3 cute / 4 cool / 1 majestic / 2 creepy-cute. Mascot candidate: Capgnome. Every look in scaffold E is a draft to redo against Ayrton's style references; Hex rides on every native Arcane tail (E's proposal).

| # | Name | Type | Plan | Role | One-line hook | Signature | Mood | Name check | Look-alike | Design flags | Prompt | Model |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| #080 | Jackalorn | Arcane | Q | common | The horned hare of old tales, quick and sly | moss-tipped antlers (head) | cool | similar (the folk jackalope): Hareantler / Antlerhop / Mossjack | loose: Lopunny, Sawsbuck | pass | [E](creature_scaffold/E_ARCANE.md#jackalorn) | to do |
| #081 | Capgnome ★ | Arcane | B | common, gem-likely | Century-old hermit who grows a new toadstool cap every autumn | toadstool cap grown from the head | cute | clear (silent g: Capnome / Shroomnome) | moderate: Toad (Mario), Breloom | mild: a gnome face reads human (anti-pattern 6, uncanny human mimicry): keep the face an animal's (nose, ears), not a little man's | [E](creature_scaffold/E_ARCANE.md#capgnome-) | to do |
| #082 | Rimefawn | Frost (Cosmic move on torso) | Q | common | Fawn whose spots are a star map of the night it was born | frost-star spots (torso) | cute | clear | loose: Deerling, Xerneas | mild: the twist is mostly colour (pattern 12, "never by colour"): let one part carry it (for example star-shaped antler nubs) | [E](creature_scaffold/E_ARCANE.md#rimefawn) | to do |
| #083 | Stringlet | Storm (Cosmic move on torso) | B | common | A dancing puppet strung to the clouds by static | control-bar crest (head) | creepy-cute | clear | moderate: Banette | strong: an object (a marionette) with no animal anchor, and "strings" are thin parts Meshy breaks: anchor it on an animal with static tufts as the strings | [E](creature_scaffold/E_ARCANE.md#stringlet) | to do |
| #084 | Folioth | Arcane | W | common | Moth whose folded wings are a closed spellbook | book-page wings | cute | clear (spelling: Folimoth / Pagemoth) | loose: Vivillon | mild: the second patterned-wing moth after Loomoth (#078), a template risk: vary its body and wing shape | [E](creature_scaffold/E_ARCANE.md#folioth) | to do |
| #085 | Sparkowl | Storm | W | common (token gift) | Cross old scholar owl whose ear tufts crackle when interrupted | spark ear tufts (head) | cool | similar: Tuftspark / Zapowl / Flickerhoot | loose: Noctowl, Decidueye | pass | [E](creature_scaffold/E_ARCANE.md#sparkowl) | to do |
| #086 | Runecoil | Arcane | S | common | Serpent whose carved symbols spell a new riddle every time it sheds | rune bands (torso) | cool | similar: Glyphcoil / Sigilcoil / Scrollcoil | moderate: Dratini, Dragonair | pass (dragon-coded, 1e) | [E](creature_scaffold/E_ARCANE.md#runecoil) | to do |
| #087 | Pebbletroll | Arcane | B | uncommon | Rock-troll cub that freezes into a boulder whenever it is looked at | pebble-set back (torso) | creepy-cute | similar ("Trolls", "Pebbles"): Cobbletroll / Gravelgrum / Stonenub | loose: Geodude, Sudowoodo | pass | [E](creature_scaffold/E_ARCANE.md#pebbletroll) | to do |
| #088 | Underbridge | Arcane | Q | uncommon (quest gift) | Troll beast that lives under bridges and charges a toll of one shiny pebble | troll face (head) | cool | clear | loose: Piloswine, Mamoswine | mild: shares the bridge-troll joke with the giant Bridgegrum and is one of three trolls in the biome (template risk): give it its own home and joke | [E](creature_scaffold/E_ARCANE.md#underbridge) | to do |
| #089 | Paperlume | Arcane | S | rare | Paper-lantern serpent; the lantern festival began to welcome one home | lantern body (torso) | majestic | clear | loose: Litwick, Chandelure | mild: a body built of objects (lanterns): lead with a creature head (E's folded-paper face, dragon-coded), lanterns as its scales | [E](creature_scaffold/E_ARCANE.md#paperlume) | to do |
| #090 | Bridgegrum | Arcane | B | giant | The bridge over Toadstool Dell was its stooped back all along | footbridge back (torso) | majestic | clear | none known (folklore) | pass | [E](creature_scaffold/E_ARCANE.md#bridgegrum) | to do |

### 10 · The Abyss (Cosmic) · Starfold · 5v5 · Diamond tier · last rival battle

Bible mix 2 cute / 4 cool / 3 majestic / 1 creepy-cute, plus Halcyre (majestic, this index's reading). Mascot candidate: Orrerback (the Diamond showcase); Halcyre is the second showcase. Breeding stat: Speed on the tails.

| # | Name | Type | Plan | Role | One-line hook | Signature | Mood | Name check | Look-alike | Design flags | Prompt | Model |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| #091 | Cometkit | Cosmic | Q | common | Tiny hopper trailing a chunky comet tail it can never quite see | comet streamer (tail) | cute | similar (Warriors "-kit" names): Cometcub / Tailspark / Streakling | loose: Pachirisu, Minior | pass | [F](creature_scaffold/F_ABYSS_HOLLOW_MYTHIC.md#cometkit) | to do |
| #092 | Spyglint | Cosmic | B | common (token gift) | Nosy little stargazer whose eyes zoom out on brass telescope tubes | telescope eye tubes (head) | cute | clear | loose: Binacle | mild: the same optical-eye gag as Lensloris (#048): another twist or another anchor | [F](creature_scaffold/F_ABYSS_HOLLOW_MYTHIC.md#spyglint) | to do |
| #093 | Cometfinch | Cosmic | W | common | Round finch whose forked comet tail leaves a trail of light | forked comet streamers (tail) | cool | clear | moderate: Taillow, Swellow | mild: the second comet tail in the biome after Cometkit (template risk): vary the motif | [F](creature_scaffold/F_ABYSS_HOLLOW_MYTHIC.md#cometfinch) | to do |
| #094 | Nebulark | Cosmic | W | common | Violet lark with nebula-painted wings whose song is almost silent | nebula wings (painted) | majestic | clear (Starlark is easier) | loose: Swablu, Altaria | mild: the hero is a paint pattern (pattern 12, "never by colour"): let the crest tuft or a part carry it | [F](creature_scaffold/F_ABYSS_HOLLOW_MYTHIC.md#nebulark) | to do |
| #095 | Hourling | Arcane (Crystal move on torso) | B | common | Little timekeeper with an hourglass body of star-sand, always a bit late | hourglass body (torso) | cool | clear | none known | strong: an object body (anti-pattern 1), though F gives it a face and limbs: F's own fallback (the hourglass carried on the back of a rounder animal body) would answer it | [F](creature_scaffold/F_ABYSS_HOLLOW_MYTHIC.md#hourling) | to do |
| #096 | Bolide | Fire (Storm move on torso) | W | common | Stout falcon with a meteor-rock crown that burns as it dives | meteor-crust cap (head) | cool | similar: Fireflit / Meteorhawk / Blazestoop | moderate: Talonflame, Fletchinder | pass | [F](creature_scaffold/F_ABYSS_HOLLOW_MYTHIC.md#bolide) | to do |
| #097 | Galaxeel | Cosmic | S | common | Ribbon eel that swims through the black sand like the Milky Way | Milky Way band (tail) | cool | clear (F: near common words) | loose: Dragonair, Milotic | pass (dragon-coded, 1e) | [F](creature_scaffold/F_ABYSS_HOLLOW_MYTHIC.md#galaxeel) | to do |
| #098 | Portaloop | Cosmic | S | uncommon | Flower-plumed tube worm whose open mouth shows a different starfield | starfield mouth (head) | creepy-cute | **safety** (sounds like "Portaloo"): Gatewyrm / Doorworm / Starburrow | loose: Wiglett, Wugtrio | pass | [F](creature_scaffold/F_ABYSS_HOLLOW_MYTHIC.md#portaloop) | to do |
| #099 | Orrerback ★ | Cosmic | Q | uncommon, gem-likely (Diamond showcase) | Unhurried tortoise whose domed shell is a star chart joined by gold thread | star-chart dome (torso) | majestic | clear (kids: "orrery"; Starshell) | loose: Torterra | pass | [F](creature_scaffold/F_ABYSS_HOLLOW_MYTHIC.md#orrerback) | to do |
| #100 | Ouroring | Arcane (Crystal move on torso) | S | rare | Ring serpent whose tail rises into an upright rune circle held in its own clasp | upright tail ring (tail) | majestic | clear (spelling: Tailring / Loopcoil) | loose: Ekans, Seviper, the ouroboros | pass (F's loop keeps head and tail swappable) | [F](creature_scaffold/F_ABYSS_HOLLOW_MYTHIC.md#ouroring) | to do |
| #101 | Halcyre | Cosmic | Q | uncommon (quest gift, F's proposal), gem-likely (second showcase) | Sleepy, wise moon-crested dreamer that sleepwalks toward the Hollow and leads you there (Ayrton's concept) | crescent-moon crest (head) | majestic | Ayrton's own name, not checked | moderate: Umbreon, Lunala | mild: four features compete (crest, gold freckles, folded moth wings, nebula tail) and the animal is unnamed: keep the crest the hero, the rest quieter | [F](creature_scaffold/F_ABYSS_HOLLOW_MYTHIC.md#halcyre) | to do |
| #102 | Starfathom | Cosmic | S | giant | Colossal gentle void oarfish with a crest of pale gold fin-rays, rising from the Starwell | fin-ray crest (head) | majestic | clear | loose: Gyarados | pass | [F](creature_scaffold/F_ABYSS_HOLLOW_MYTHIC.md#starfathom) | to do |

### 11 · The Hollow (mixed) · Old Hearth · 6v6 · one species per type

Bible mix 1 cute / 4 cool / 3 majestic / 2 creepy-cute. Mascot candidate: Tesserine. Each species carries one type-coloured glass patch on its torso (F: the torso sets the type). The synthesis allows abstract concepts here only if they keep a face, so the object flags below are softer than elsewhere, but each still lacks an animal anchor.

| # | Name | Type | Plan | Role | One-line hook | Signature | Mood | Name check | Look-alike | Design flags | Prompt | Model |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| #103 | Sphinxling | Sand | Q | common | Sandstone sphinx cub with a chipped nose, guarding a riddle it has forgotten | stone lappets and chipped nose (head) | cute | clear | loose: Solgaleo, Litleo, Shinx | pass | [F](creature_scaffold/F_ABYSS_HOLLOW_MYTHIC.md#sphinxling) | to do |
| #104 | Embergrate | Fire | B | common | Squat, warm-hearted hearth with a glowing grate in its belly and a chimney head | hearth-arch belly (torso) | cool | clear | loose: Torkoal, Coalossal | strong: an object with a face (a brick hearth with a chimney for a head), and its vessel belly echoes Bulbroth (#036): anchor it on an animal (for example a bulldog or badger guardian) with the hearth as its belly | [F](creature_scaffold/F_ABYSS_HOLLOW_MYTHIC.md#embergrate) | to do |
| #105 | Censerling | Toxic | B | common | Dramatic little mystic whose bronze bowl body breathes heavy temple fumes | censer bowl (torso) | creepy-cute | clear (reads as "censor"; Smokeling) | borderline: Bronzong, Litwick, Chandelure | strong: an object with a face (an incense bowl with a lid cap): anchor it (for example a loris or ferret whose tail trails the smoke) | [F](creature_scaffold/F_ABYSS_HOLLOW_MYTHIC.md#censerling) | to do |
| #106 | Rimedove | Frost | W | common | Carved stone dove with frosted-glass wings that thaws into flight at night | frosted-glass wings | majestic | clear | loose: Pidove, Articuno | pass | [F](creature_scaffold/F_ABYSS_HOLLOW_MYTHIC.md#rimedove) | to do |
| #107 | Bannerwing | Storm | W | common | Bold swift with tattered temple-banner wings that always faces into the wind | banner wings | cool | clear | loose: Talonflame | pass | [F](creature_scaffold/F_ABYSS_HOLLOW_MYTHIC.md#bannerwing) | to do |
| #108 | Fountcoil | Water | S | common | Stone fountain-spout serpent that still pours and waits in the old square for coins | fountain-spout mouth (head) | cool | clear | loose: Milotic, Gyarados | strong: an object's shape (a spout) more than a creature: make it a creature first (for example a carved carp-dragon whose mouth pours) | [F](creature_scaffold/F_ABYSS_HOLLOW_MYTHIC.md#fountcoil) | to do |
| #109 | Mossaltar | Leaf | Q | uncommon | Gentle stone ox whose back is a fallen altar grown over with moss and ivy | altar slab (torso) | majestic | clear | loose: Bulbasaur, Tauros | pass | [F](creature_scaffold/F_ABYSS_HOLLOW_MYTHIC.md#mossaltar) | to do |
| #110 | Tesserine ★ | Crystal | Q | uncommon, gem-likely | Shy pangolin whose scales are mosaic tiles from three ruins | mosaic tile coat (torso) | cool | clear (spelling: Tilewick / Mosaicub) | loose: Sandslash | pass | [F](creature_scaffold/F_ABYSS_HOLLOW_MYTHIC.md#tesserine) | to do |
| #111 | Tapestrel | Arcane | B | uncommon | Living tapestry whose belly tells the story of the first creatures | woven story panel (torso) | majestic | clear (spelling: medium) | loose: Mimikyu, Banette | strong: an object (cloth on a hanging rod) with a face: anchor it (for example a heron-like biped whose torso panel is the tapestry) | [F](creature_scaffold/F_ABYSS_HOLLOW_MYTHIC.md#tapestrel) | to do |
| #112 | Riftling | Cosmic | S | rare | Skittish serpent that slid out of the tear, its edges coming unravelled | unravelling tail strands | creepy-cute | similar ("rift"): Seamling / Rendling / Splitlet | loose: Giratina, Dhelmise | pass | [F](creature_scaffold/F_ABYSS_HOLLOW_MYTHIC.md#riftling) | to do |
| #113 | Hearthwarden | mixed (changes each phase) | Q | giant | Ruin hound of fitted stone, ten glass insets down its back, waiting for someone to come home | ten glass insets (torso) | majestic | similar: Hearthhound / Stonewarden / Ashwarden | loose: Regirock, Stoutland | pass | [F](creature_scaffold/F_ABYSS_HOLLOW_MYTHIC.md#hearthwarden) | to do |

### Mythics

Not a rarity tier: a species with a flag (roster plan section 5). Met through the story, never wild, never sold. Ordered here after the Hollow; in the story the Frayling is met in the Arcane chapter and Blackstitch appears after the rival's first loss.

| # | Name | Type | Plan | Role | One-line hook | Signature | Mood | Name check | Look-alike | Design flags | Prompt | Model |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| #114 | The Frayling | Cosmic | B | mythic | The mentor's mistake: a small, frightened, half-finished cub with starlight in its gaps, mended by the player | painted starfield gaps (torso) | creepy-cute | similar: The Threadling / The Looseling / The Tatterling | moderate: Sackboy, Banette, Mewtwo | pass | [F](creature_scaffold/F_ABYSS_HOLLOW_MYTHIC.md#the-frayling) | to do |
| #115 | Nimbram | Storm | Q | mythic | Vast ancient ram whose cloud fleece is the Crown's halo, greying as the tear grows | cloud fleece (torso) | majestic | clear | moderate: Dubwool, Mareep | pass | [F](creature_scaffold/F_ABYSS_HOLLOW_MYTHIC.md#nimbram) | to do |
| #116 | The Firstling | Crystal | none (a long floating dragon) | mythic | The first creature: a long Eastern-style stained-glass dragon in all ten type colours, with an embroidery-hoop halo | stained-glass patchwork and hoop | majestic | similar: The Patchling / The Elder Stitch / The Quiltling | moderate: Rayquaza, Arceus | mild: ten pane colours break the palette point (checklist 5: four at most); it is the design's meaning, so your call | [F](creature_scaffold/F_ABYSS_HOLLOW_MYTHIC.md#the-firstling) | Meshy (in game); to be regenerated with a centred, separate halo (DECISIONS 23 Nov) |
| #117 | The Unraveller | Cosmic | none (boss) | mythic (never caught) | A hunched mass of black yarn with a seam-ripper head and one crimson eye that unpicks what the Firstling stitched | seam-ripper head | villain | similar: The Unpicker / The Snagweaver / The Rendweft | moderate: the Beldam (Coraline), No-Face | n/a | [F](creature_scaffold/F_ABYSS_HOLLOW_MYTHIC.md#the-unraveller) | to do |
| #118 | Blackstitch (proposed) | Cosmic | none (story prop at launch) | mythic (proposed; a creature only from roadmap stage 3) | A sly living knot of black thread: the splinter of the Unraveller the rival swallowed | crimson bead eye | creepy-cute | not checked | loose: yarn-ball creatures | n/a | [F](creature_scaffold/F_ABYSS_HOLLOW_MYTHIC.md#blackstitch) | to do |

---

## 4. Decisions for Ayrton

In one batch. Items 1 to 3 are the three asked about; item 4 collects what this index surfaced. Each scaffold also ends with its own questions (A 7, B 6, C 8, D 8, E 14, F 11), not repeated here.

**1. Spadesnout: two legs or four.** You chose two legs on 23 November (DECISIONS, "Creature design follows the research"), with Loamlet as Greenwood's four-legged Sand species; the index follows that. Please confirm, knowing what follows:
- Greenwood becomes four four-legged and five two-legged species, each plan with a Sand creature; the balance gate is re-run on both plans.
- The Meshy breeding pilot pair becomes Sloshcalf × Loamlet (scaffold A). `docs/art/MESHY_PILOT.md` still lists the old pair and a four-legged Spadesnout prompt; scaffold A's Biped prompt replaces it.
- Spadesnout's front legs become digging arms (its leg move "Scree Kick" wants an arm name, for example "Scree Swipe"); the sit-up you liked becomes its pick-screen pose and an idle, not its rest pose.
- The in-game stand-in model stays four-legged until the Meshy one replaces it.
- Pebblepot, the two-legged alternative ninth, stays retired: scaffold A calls it an object with a face.

**2. Names.** Nothing has been renamed.
- **Franchise look-alike names (23), for your review in section 2:** taken: Thatchling (Pathfinder 2e). Similar: Hollowbough, Gulpmaw, Lanternell, Carrackon, Mistrel, Glacibex, Woolrime, Prismquill, Pyrecone, Magmeel, Fusewick, Jackalorn, Sparkowl, Runecoil, Pebbletroll, Cometkit, Bolide, Riftling, Hearthwarden, The Frayling, The Firstling, The Unraveller. Keep or swap each; every one has a fallback listed.
- **Safety names (3), not a franchise issue, recommended for a change:** Cocklemole (begins "Cock-": jokes and chat-filter trouble; Shellmole), Hoarmot (a rude sound-alike when said aloud; Frostmot), Portaloop (sounds like "Portaloo", a portable toilet; Starburrow or Doorworm). Cocklemole is in the launch batch.
- **Hard to say or spell (21, optional):** Loamlet, Wadibuck, Flintknap, Cairnback, Sloughback, Thundegg, Druseback, Smoulderskink, Glassgaffer, Puffchin, Duneswallow, Gritgoyle, Loomoth, Capgnome, Folioth, Nebulark, Orrerback, Ouroring, Censerling, Tesserine, Tapestrel. The checks offer simpler spellings.
- **Not checked:** Halcyre (your name) and Blackstitch (new in F). Worth one search each before art.
- Run a formal trademark search on the kept headline names before launch (every check file says its search is a screen, not a clearance).

**3. Mythic rules.** From the roster plan (section 5, decisions 6 to 8) and scaffold F (section 4 and its questions), with the synthesis's guidance:
- **Proposed rule:** one per player, bound to the account, numbered in the order players earn it (like giants), gifted by the story, never a wild spawn, never sold. The synthesis adds: earned in play by every player, never locked behind an event few can reach, never paid.
- **Can mythics breed?** The game already ships the Firstling as one solid mesh with the note "it never breeds" (`src/content/CreatureModels.luau`), and F gives it no body plan. F keeps the Frayling and Nimbram on standard plans so they could breed if you allow it. Make "mythics never breed" the rule, or let a mythic part be the rarest part in the game?
- **The Firstling's form:** F retires the roster plan's "small sitting cub" frame and follows your Meshy model (a long floating Eastern-style dragon), with a centred hoop cut as its own part. Confirm, and confirm its type stays Crystal (it beats the Cosmic entity). The research's note for the record: small, charming mythics have polled better than imposing ones; your dragon keeps a friendly face and a plush thread mane, which answers some of that.
- **A mythic budget** (F): up to 6,000 triangles (hard 7,200) for mythics off the breeding plans, like giants. OK?
- **Nimbram:** obtainable at the Crown's summit after the story, or a story presence only?
- **Blackstitch** (F's proposed fifth mythic): the thread the rival swallows, an effect on his creatures at launch and the face of roadmap stage 3. Keep, rename or drop? If kept, it is a mythic in name only until stage 3.
- **The lore link:** the mentor's star fragment was a chip of the Firstling's glass; the rival swallowed Blackstitch. Keep, change or drop?
- **Halcyre** is not a mythic: F makes it a catchable Uncommon, the Abyss's quest gift (in place of Orrerback or Portaloop) and its second showcase. Confirm, and whether its wings are flat on the back or a separate fluttering part (F questions 3 and 4).

**4. What the index surfaced (each a [Default] the agents can act on once you agree):**
- **Fix the launch batch's 6 strong design flags before Meshy** (Stumpwarden, Splashjack, Whirlgrit, Thatchling, Spurlet, Spirecap): mostly "give it an animal anchor", the synthesis's strongest anti-pattern (an object or plant with a face). This means editing scaffold A's designs, which this index did not do. The same fix applies later to Rimefern, Forkhum, Stalagrump, Ashbloom, Pyrecone, Stringlet, Hourling, Embergrate, Censerling, Fountcoil and Tapestrel.
- **Starter trio moods:** the synthesis says the winning trio is one cute, one cool, one odd; ours is cute (Mossmitt), cool (Spadesnout), cute (Sloshcalf). Lean Sloshcalf into the "odd" slot through behaviour (a worrier who talks to its fish), with no design change?
- **Fox, wolf and cat bodies:** about 5% of the roster against about half of the favourites. Put the unused spares to work (Frostline's snowshoe lynx kitten, the Arcane wisp-tailed marsh hound and griffin cub, Emberfall's ash badger), and give these bodies showcase slots?
- **A catchable dragon line:** the Firstling is now the game's one dragon, at the very top. The evidence (`loved/06`) favours a dragon family players can catch and trade as a chase line. Grow one from the dragon-coded kin already designed (Smoulderskink, Grotteel, Runecoil, Paperlume, Galaxeel), sharing one mark that echoes the Firstling? E asks the same in its question 6.
- **Template pairs:** two moths, two optical-eye primates, two comet tails, three trolls, two vessel bellies, two upright frost rodents (section 1e): vary the later one of each pair?

The roster plan's other open questions (ten species per biome from Crystal Deep on, the Serpent and Winged plans, rare spawns, the Hollow giant's type change, the status effects, the Arcane references) stand as written in `00_ROSTER_PLAN.md` section 8.

---

## 5. How the columns were filled

- **Order:** the order a player meets them: in each biome, commons first (the token gift and the mascot early), then uncommons, then the rare spawn, with the giant last; Halcyre, the Abyss's quest gift that leads to the Hollow, just before Starfathom; mythics after the Hollow. Greenwood opens with the starter trio and Loamlet, Spadesnout's Sand partner.
- **Type:** the creature's element; for an underdog, the torso move that beats the native type back is noted in brackets.
- **Role:** rarity role from the roster plan and the scaffolds; rare spawns are "rare" here though they stay Uncommon until the bait and daily-sighting rule is approved. Quest and token gifts are noted; where a scaffold proposes a different gift from the roster plan (Chiselrime for Woolrime, Halcyre for Orrerback), both are shown.
- **Hook and signature:** from each scaffold's at-a-glance table or description. For the signature, the one feature a player would name the creature by.
- **Mood:** from each biome bible's mix table (Halcyre, written after the Abyss bible, is this index's reading). Where a scaffold labels a mood differently, the conflict is flagged.
- **Look-alike:** each scaffold's originality check or flag list (C, D, E and F rate closeness themselves; A and B describe the nearest creature, rated here), plus the name checks.
- **Design flags:** the synthesis's pre-Meshy checklist (section 7) on concept grounds only: points 2 (anchor plus twist, not an object with a face), 4 (one signature, no competing ornament), 5 (palette), 6 (a face, not human mimicry), 11 (role and biome fit, including the bible's mood mix), 13 (rarity fit) and anti-pattern 5 (template sets). Points that need a picture or a model (the 64 px silhouette, proportions, the part mix test, the plush test) cannot be judged from text and are left to the Meshy step. Franchise resemblance is never a design flag here; it is in the Look-alike column.
- **Model:** `src/content/CreatureModels.luau` and `docs/ASSETS.md`: 36 creatures and giants have Roblox-generated stand-ins; the Firstling has Ayrton's Meshy model; the Meshy pilot folders in `art/meshy/` for Mossmitt, Sloshcalf and Spadesnout are empty.
