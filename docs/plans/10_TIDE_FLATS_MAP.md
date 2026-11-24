# 10 · Tide Flats, designed (Saltwick and the Breakwater Road)

Tide Flats still uses the generated layout. This plan replaces it with a map drawn on purpose, to the standard of `08_GREENWOOD_MAP.md` and alongside `09_DUST_CANYON_MAP.md`. It keeps every place the server checks and every number in `src/content/biome_data/TideFlats.luau`.

Conventions are those of plans 08 and 09:
- Studs. Every point is relative to Saltwick's centre, the hub place `tide_flats_hub`, at (0, 0).
- **North is -z**; east is +x.
- Facings are degrees clockwise from north and point along (sin θ, -cos θ).
- "Left" and "right" are as seen walking away from town (right is `side = 1` in `Corridors.edges`).
- Walking speed is 16 studs a second.

**Where Tide Flats sits.** Plan 09 ends Dust Canyon's Route B due east at (779, -100) in Dust Canyon's coordinates, with its sealed path at (839, -100). Layout puts the next hub 240 further on, so Saltwick's centre is at world **(2063.4, -180)**. This depends on plan 09's last leg. In this plan's coordinates:
- Dust Canyon's gate is at (-300, 0) and its sealed path at (-240, 0).
- Its sealed-road slab already reaches (-180, 0).
- Its champion Tavish stands at (-380, -8).

Tide Flats' Route B ends due east at (742.9, 110), so a sheeted Mire would sit at (1042.9, 110) here. The Mire is not open yet (`ReleaseConfig.OPEN_BIOMES` is 3).

**How the numbers were checked.** As for plan 09: every rule in `tests/layout.test.luau`, plus the extra dressing checks, was run on these exact sheets with the project's own `Layout.luau`, `Biomes`, `Tamers` and `Chapter3` data in a scratch copy. Everything passes (section 3f).

The new sheet fields, edge styles, builder recipes and builder fixes are specified once, in **plan 09 section 4**. This plan uses them and lists only what is particular to Tide Flats (section 4).

---

## 1. The idea

**Saltwick is a salt-and-rope fishing town on the sand, half on stilts.** You come over the dunes from Kilnrest along the Dune Road, between two marram-tufted dune ridges. The town opens round a small harbour:
- A boarded square, Net Square, with an upturned rowing boat at its heart.
- A plank quay along the harbour's north shore, with rowing boats tied up in the water below.
- Stilt Row, blue-painted fishers' cottages on stilts along a boardwalk over the beach.
- Tarred net lofts with boat-shaped roofs.
- The stubby white Lamp Tower on the harbour mole.

Everything smells of salt and tar: rope rails, cork floats, drying nets, barrels, sea walls and sea rocks. No hedges, no cliffs in town.

There are two ways out:
- **Route A, Strandline Path**, leaves south-west by the end of Stilt Row. It runs down a wide wrack beach with the bay on the left and dunes on the right, crosses a shelf of black rock pitted with pools, then wades out over a sunken plank path through knee-deep kelp shallows. It ends where the plank bridge to the sandbar has gone, looking across the channel at Route B's sandbar.
- **Route B, Breakwater Road**, leaves east along a raised sandbar causeway with water on both sides. Then it runs a stilted boardwalk over a mirror of grey mud, rounds a broad bay where a giant ship's ribs stand out of the sand and a sea cave opens in the cliff, and climbs the green-slick steps of the breakwater to the Breakwater Gate.

**The landmark is the Old Light**, a tall white lighthouse with red bands on a rocky headland at (790, 470). It stands 140 studs tall and is seen from the moment you come over the dunes, out across the bay and the harbour mouth. Carrackon's Wreck, the giant's cove, lies at its foot, at the end of the lair spur. The light failed one night long ago, and that is why the wreck is there. Isaura, the lighthouse apprentice, and the quest "Lamp Trouble" already point at it.

How it must feel different from Greenwood (and from Dust Canyon):

| | Greenwood | Dust Canyon | Tide Flats |
| --- | --- | --- | --- |
| Edges | Hedges | Cliffs and boulders | Rope rails, dunes, sea rocks, sea walls, water |
| Ground | Lawn | Baked clay | Pale sand, black rock, grey mud, shallow turquoise water |
| Water | Brook and pond | A spring | Everywhere: harbour, bay, open sea, mudflats, pools |
| Long grass | Green tufts | Dry gold tufts | Blue-green marram on sand, kelp in the shallows, reeds on the mud |
| Town | Thatch round a green | Adobe in a canyon | Stilts, planks and net lofts round a harbour, open to the sea |
| Walking | Dirt lanes | Earth and flagstone | Boardwalks and decks, sand, wading |
| Landmark | Golden tree | Red mesa | White lighthouse, a tall thin silhouette with a light at the top |

---

## 2. Maps

These maps were drawn from the coordinates by script, so positions are true to the scale given. The tables in section 3 are what counts.

### 2a. The whole biome

Scale: 20 studs per character across, 40 studs per line down. North is up. `~` is water, `,` is mudflat.

```
z -160      ################                                     # dunes round the town
z -120      #              #
z  -80      #        :     #    ~~~~~~~~~~                       the outer water
z  -40      #   : : :  ::  #    ~~~~~~~~~~
z    0 ######::::::S:::::::#    ~~~~~~~~~~                       S Saltwick (the Dune Road comes in from the left)
z   40 ###### :  :+++++++: ==   ~~~~~~~~~~                       == Route B leaves east
z   80      # :   +~~~~~#: # g= ~~~~~~~~~~                       harbour (inside the rope rails +)
z  120      # :   +~~~~~#  #  3=~~~~~~~~~~    ##    ====G  >     G Breakwater Gate  > sealed road
z  160      #==###+#++++####~~~===     ==g== #r# g==5       ~~~~~  r Tide Cave in its outcrop
z  200     g =  ~~~~~~~~~~~~~~~~~======g  4==$====          ~~~~~  $ Wreck Stall
z  240       =  ~~~~~~~~~~~~~~~~,,,,,,,,,,,, ===            ~~~~~
z  280       =1 ~~~~~~~~~~~~~~~~,,,,,,,,,,,,   ==           ~~~~~
z  320        ===~~~~~~~~~~~~x~~,,,,,,,,,,,,     ===        ~~~~~  x broken plank bridge (end of Route A)
z  360        g ==r==  g   ===x                    ===      ~~~~~
z  400              =====2=r                          O     ~~~~~  O Carrackon's Wreck (arena r85)
z  440                                                      ~~~~~
z  480   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~L~~~~~  L the Old Light (landmark, 140 tall)
z  520   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  the open sea
   x   -240      -40       160       360       560       760
Tamers: 1 Nell  2 Merrin  3 Orrin  4 Isaura  5 Ludo.  Captain Marr stands on the boardwalk at (335, 184);
the rival stands in the gate at (736, 110).  g long grass, r rustle spot.
Saltwick Bay is the water between Route A (west and south) and the sandbar causeway (east).
```

- **Saltwick (hub):** centre (0, 0). The square stays 300 by 300 and the built area is about 280 by 275. Dunes on the north and west, sea walls and the harbour on the south and east.
- **Route A, Strandline Path (500):** leaves south through the south arch at the end of Stilt Row. It runs down the beach, bends south-east on to the rock shelf, then east into the kelp shallows, and stops at a broken plank bridge looking across at the sandbar.
- **Route B, Breakwater Road (720):** leaves east through the east arch. The causeway runs south-east, the boardwalk east, and the bay road east along the cliff foot (the spur forks south-east at 440). The breakwater steps climb north-east and then east to the gate.

### 2b. Saltwick

Scale: 5 studs per character across, 10 studs per line down. North is up.

```
z -150   #############################################################    # marram dunes (north and west)
z -120   #                                         h                 #    h keeperless house
z -110   #          h                                                #
z  -80   #                              p         p                  #    p pools (the Brood Shallows' pens)
z  -60   #       h                          :B          D            #    B Brood Shallows   D Breaker Ring
z  -50   #                                 ::           :            #
z  -40   #                         N:     ::            ::           #    N Tally Board
z  -30   #           p    H         :    ::              :      h    #    H Warm Pool (healer), p its pool
z  -20 ###                :                              :           #
z  -10                    :                  ::::T       ::          #    T Tarn's Chandlery (hero)
z    0 ::::A:@::::::::::::::::::::     o     ::           :          #    @ arrival  o Net Square
z   10             ::        :                ::::::::::::::         #
z   20 ###        ::         :                            :::::::::A:==   Route B leaves east
z   30   #       ::          :         :                             #==
z   40   #       :           :::::::::::::::::::::::::::::::::       #    the Quay (a deck)
z   50   #       :            W  +++++++++++++++++++++++++++ :       #    W Ferry Steps  + rope rails
z   60   #  h    :               +~~~~~~~~~~~~~~~~~~~~~~~~~~ L       #    L Lamp Tower on the mole
z   70   #       :             :::::b~~~~~~~~~~~~~~~~~~~~~~~         #    ::::: the ferry jetty  b boats
z   80   #       :               +~~~~~~~~~~~~~~~~~~~~~~~~~#         #    # sea walls
z  100   #  h    :    h          +~~~~~~~~~~~b~~~~~~~~~~~~~#         #    (Stilt Row: the boardwalk at x -110)
z  120   #       :               +~~~~~~~~~~~~~~~~~~~b~~~~~#         #
z  140   #       A               +~~~~~~~~~~~~~~~~~~~~~~~~~#         #
z  150   ######  =  #############+#########+++++++++++################    +++ the floating boom in the mouth
z  160          ==                                                        Route A leaves south
   x   -160      -110      -60       -10       40        90        140
```

**Arriving.** The player comes over the Dune Road and through the west arch (-142, 0), facing east down the Rope Walk.
- 5 seconds in, they enter the hub (`tide_arrival`).
- Straight ahead across Net Square, Tarn's Chandlery faces them (`tide_bait`, talking to Odalys).
- The harbour opens on the right with the Lamp Tower, and the Old Light stands far beyond it out at sea.
- The Stilt Row boardwalk branches right just ahead, signed to Route A, the first outing. The east street, signed to Route B, carries straight on past the Chandlery.

### 2c. Route A: Strandline Path

Scale: 10 studs per character across, 20 studs per line down. North is up.

```
z  140      #   :       +            #    #       ==      town's south edge; the south arch at (-110, 142)
z  160      ###==#######+####++++++########~~~~~~~~==
z  180         =    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~==    Wrack Beach 0-160: rope rail on the left (the bay),
z  200         = s  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~     dunes on the right; half-width 55
z  220      g  =    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~     g marram grass in the dunes   s teaching sign
z  240         =    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
z  260         ==   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
z  280          =1  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~     1 Nell (120)
z  300           == ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~     Rockpool Shelf 160-330: sea rocks both sides; 55
z  320            ===~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
z  340              ====~~~~~~~~~~~~~~~~~~~~~sx=~~~~~     x broken plank bridge  s "Plank bridge out."
z  360            g     ====      g         ====x         g weed in the pools (shelf); g kelp (shallows)
z  380                   r  ====      2 =====             r the Anemone Pools (260)   2 Merrin (400)
z  400                         =========  r               r the Kelp Bed (430)
z  420                                                    Kelp Shallows 330-500: a sunken plank path
z  480 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~    through knee-deep water, rope floats both sides; 60
   x   -200      -100      0         100       200
```

### 2d. Route B: Breakwater Road and the spur to Carrackon's Wreck

Scale: 15 studs per character across, 30 studs per line down. North is up.

```
z -100  #
z  -70  #     ~~~~~~~~~~~~~                              the outer water
z  -10  #     ~~~~~~~~~~~~~
z   20 :=     ~~~~~~~~~~~~~                              Route B leaves Saltwick at (150, 20)
z   50  #=g   ~~~~~~~~~~~~~                              g marram across the causeway
z   80  #  == ~~~~~~~~~~~~~                              Sandbar Causeway 0-180: rope rail left, rocks right; 35
z  110  #   =3~~~~~~~~~~~~~               ==s==G   >     3 Orrin (110)   G Breakwater Gate (rival inside)
z  140 ##~~~~==~~~~~~~~~~~~g     # #  g ==5         ~~~~~  # # the cave outcrop   5 Ludo (620)
z  170 ~~~~~~~====      ======s= r##  ===           ~~~~~  r the Tide Cave (470)  s sign at the spur
z  200 ~~~~~~~~  =======g   4  ========             ~~~~~  4 Isaura (400)  g reeds on the mud
z  230 ~~~~~~~,,,,,,,,,,,,,,,   =$=                 ~~~~~  $ Wreck Stall
z  260 ~~~~~~~,,,,,,,,,,,,,,,W    ==                ~~~~~  W the ship's ribs in the sand
z  290 ~~~~~~~,,,,,,,,,,,,,,,       ==              ~~~~~
z  320 ~~~x~~~,,,,,,,,,,,,,,,         ===           ~~~~~  spur: cliff left, rocks right; half-width 30
z  380 ===  x                             ==O       ~~~~~  O Carrackon's Wreck, a cove ringed by cliffs
z  470 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~L~~~~~~  L the Old Light on its headland
   x   140       290       440       590       740
Mudflat Boardwalk 180-360 is the plank deck over the mud, with Captain Marr at (335, 184); rope rails both sides, half-width 50.
Shipwreck Reach 360-540: cliff on the left (north), rocks on the right (the sand bay); 65.  Tideward Steps 540-720: sea walls both sides; 48.
```

---

## 3. Coordinate tables

### 3a. The map sheet (`src/content/map_data/TideFlats.luau`)

**Routes as waypoints**, fitted to the data length by Layout:

| Route | Waypoints (x, z) | Leg lengths | Leg sum | Fitted to |
| --- | --- | --- | --- | --- |
| `tide_flats_route_a` | (-110,150) (-125,200) (-120,250) (-100,300) (-60,340) (-10,360) (40,390) (100,400) (150,380) (200,350) | 52.2, 50.2, 53.9, 56.6, 53.9, 58.3, 60.8, 53.9, 58.3 | 498.0 | 500; end (201.7, 349) |
| `tide_flats_route_b` | (150,20) (190,60) (220,110) (250,170) (310,190) (370,190) (420,170) (480,180) (540,200) (600,190) (640,150) (680,110) (743,110) | 56.6, 58.3, 67.1, 63.2, 60.0, 53.9, 60.8, 63.2, 60.8, 56.6, 56.6, 63.0 | 720.1 | 720; end (742.9, 110), last leg due east |
| Spur (`tide_flats_lair`) | (499.1,186.4) (540,240) (590,300) (650,350) (694,386) | 67.4, 78.1, 78.1, 56.9 | 280.5 | 280; arena (693.6, 385.7) |

The spur's first point is the computed join (440 along Route B).

**Corridors** (`corridor`, and the new `edges`):

| Stretch | Half-width | Left edge | Right edge |
| --- | --- | --- | --- |
| `wrack_beach` | 55 | Rope (the bay) | Dunes |
| `rockpool_shelf` | 55 | Rocks | Rocks |
| `kelp_shallows` | 60 | Rope (floats on the bay side) | Rope (floats on the sea side) |
| `sandbar_causeway` | 35 | Rope ("a rope rail on one side") | Rocks (the bay) |
| `mudflat_boardwalk` | 50 | Rope (the outer water) | Rope (the mud) |
| `shipwreck_reach` | 65 | Cliff (the sea cave's cliff) | Rocks (the sand bay) |
| `tideward_steps` | 48 | SeaWall | SeaWall |
| `tide_flats_lair` (spur) | 30 | Cliff (the headland) | Rocks |

**Buildings** (`buildings`):

| Building id | Model | Middle | Faces | Door / keeper | Footprint (w × d, tall) |
| --- | --- | --- | --- | --- | --- |
| `tarn_chandlery` (Shop, `odalys_tarn`) | Chandlery (new) | 64, -14 | 270 | 48, -14 | 24 × 20, 28 |
| `warm_pool` (Healer) | Healer (reused) | -64, -46 | 180 | -64, -30 | 18 × 19, 26 |
| `brood_shallows` (Breeder) | NetLoft (new) | 30, -80 | 180 | 30, -64 | 20 × 16, 20 |
| `tally_board` (Quests) | NoticeBoard (reused) | -20, -58 | 180 | -20, -42 | 20 × 4, 10 |
| `ferry_steps` (Teleport, `bastian_wake`) | Waystation (reused) | -58, 62 | 45 | -46.7, 50.7 | 20 × 20, 40 |
| `breaker_ring` (Circuit) | none (sand oval and rope rail) | 96, -70 | 225 | 84.7, -58.7 | 40 × 30, 0.4 |
| `lamp_tower` (Lookout) | LampTower (new) | 124, 70 | 300 | 110.1, 62 | 16 × 16, 36 |

The Lamp Tower stands on the harbour mole (the rock east of the harbour, x 100 to 150), and its keeper stands on the mole path. The Ferry Steps stand on the sand west of the harbour, with a short jetty down to the water and the ferry boat.

**Set places** (`places`):

| Id | x, z | What and why |
| --- | --- | --- |
| `wrack_beach_grass` | -152, 210 | Marram in the dunes, right of the beach (59.5 along, 27.9 off) |
| `rockpool_shelf_grass` | -92, 352 | Weed-choked pools on the shelf, south-west of the lane (198.7 along, 31.1 off) |
| `kelp_shallows_grass` | 74, 369 | A kelp patch on the bay side (355.1 along, 26.3 off) |
| `sandbar_causeway_grass` | 192, 63 | Marram across the causeway (60.2 along, on the lane) |
| `mudflat_boardwalk_grass` | 393, 209 | A reed bed on the mud, south of the boardwalk (319.5 along, 26.2 off) |
| `shipwreck_reach_grass` | 445, 146 | Marram under the cliff, north side (379.8 along, 27.8 off) |
| `tideward_steps_grass` | 600, 154 | A grassy ledge on the breakwater's landward side (569.4 along, 25.5 off) |
| `anemone_pools` | -24, 378 | Rustle spot: deep pools south of the shelf path (260.4 along, 21.9 off) |
| `kelp_bed` | 150, 405 | Rustle spot: thick kelp south of the plank path (430.4 along, 23.2 off) |
| `tide_cave` | 535, 173 | Rustle spot: in the mouth of the sea cave in its outcrop (469.8 along, 24 off) |
| `tf_nell` | -104, 270 | Beachcombing just past the first grass (127 along, 7.4 off) |
| `tf_merrin` | 110, 386 | Standing in the shallows by the plank path (400.3 along, 9.3 off) |
| `tf_orrin` | 226, 100 | On the causeway (109.4 along, 10.3 off) |
| `tf_isaura` | 461, 186 | On the bay road, the Old Light behind her (402.1 along, 9 off) |
| `tf_ludo` | 660, 142 | On the breakwater steps (620.3 along, 8.5 off) |

**Stands** (`stands`):

| Battle | Stands at | Faces | Its place | Gap |
| --- | --- | --- | --- | --- |
| `champion_marr` | 335, 184 | 270 | `mudflat_boardwalk` (334.8, 190) | 6.0 |
| `rival_breakwater` | 736, 110 | 270 | `tide_flats_gate` (742.9, 110) | 6.9 |

**Facings** (`faces`), each looking back towards the way players arrive:

| Id | Faces |
| --- | --- |
| `tf_nell` | 320 |
| `tf_merrin` | 230 |
| `tf_orrin` | 318 |
| `tf_isaura` | 290 |
| `tf_ludo` | 250 |
| `champion_marr` | 270 |
| `rival_breakwater` | 270 |

**Spawn** (`spawn`): (-128, 0), facing 90. This is a record of the arrival point; Layout only builds a SpawnLocation for the first biome.

### 3b. Places Layout works out (reference)

| Id | x, z | How |
| --- | --- | --- |
| `tide_flats_hub` | 0, 0 | The origin |
| `tide_flats_route_a` (entry) | -118.6, 178.7 | 30 along; 147 from the nearest door (the Ferry Steps) |
| `wrack_beach` | -122.2, 227.7 | 80 along |
| `rockpool_shelf` | -30.2, 351.9 | 245 along |
| `kelp_shallows` | 127.1, 389.2 | 415 along |
| `tide_flats_route_b` (entry) | 171.2, 41.2 | 30 along |
| `sandbar_causeway` | 207.2, 88.7 | 90 along |
| `mudflat_boardwalk` | 334.8, 190 | 270 along (Marr's place) |
| `shipwreck_reach` | 508.6, 189.5 | 450 along (the `wreck_sighting` place, 10 past the spur fork) |
| `tideward_steps` | 660.8, 129.2 | 630 along |
| Spur join | 499.1, 186.4 | 440 along Route B |
| `tide_flats_lair_stall` | 523.3, 218.2 | 40 down the spur |
| `tide_flats_lair` | 693.6, 385.7 | End of the spur |
| `tide_flats_gate` | 742.9, 110 | End of Route B |
| `tide_flats_sealed_path` | 802.9, 110 | 60 past the gate, due east |

### 3c. The story order still works

| Beat | Trigger | Where |
| --- | --- | --- |
| `tide_arrival` | Enter `tide_flats_hub` | (0, 0): 80 studs (5 s) past the west arch |
| `tide_bait` | Talk to `odalys_tarn` | Chandlery door (48, -14), straight ahead of the arrival |
| `first_tide_tamer` | Beat `tf_nell` | (-104, 270), 15 s from the square plus 127 along the beach |
| `bait_catch` | Tame anything | The Anemone Pools (260 along Route A) are the first rustle spot for bait |
| `mentors_note` | Talk to `bastian_wake` | Ferry Steps door (-46.7, 50.7) |
| `tide_champion` | Beat `champion_marr` | Stands at (335, 184) on the boardwalk |
| `wreck_sighting` | Sight `shipwreck_reach` | (508.6, 189.5): the ribs in the bay, the spur, the cove and the Old Light are all ahead |
| `tide_gate_challenge` | Enter `tide_flats_gate` | (742.9, 110) |
| `tide_badge` | Beat `rival_breakwater` | Stands at (736, 110), inside the gate arch |
| `tide_road_on` | Enter `tide_flats_sealed_path` | (802.9, 110); the bar is at (755.9, 110), where the trigger starts |

Quest givers stand at their doors: Odalys Tarn at the Chandlery, Perdita Lugg at the Warm Pool, Bastian Wake at the Ferry Steps, and Hobb Pellow at the Tally Board.

### 3d. The dressing sheet (`src/content/map_data/TideFlatsDressing.luau`)

**Colours:**

| Field | Colour | What |
| --- | --- | --- |
| `fieldGround` | 238, 224, 184 | Open sand outside town and corridors |
| `townGround` | 236, 226, 196 | Saltwick's sand |
| `laneColour` | 236, 224, 196 | Packed shell-sand, every route lane |
| `plaza.colour` / `plaza.rimColour` | 196, 160, 116 / 150, 116, 84 | Bleached boards and a darker kerb |

**Ground of each stretch** (`ground`), plus one band:

| Area or band | Colour |
| --- | --- |
| `wrack_beach` | 226, 210, 168 |
| `rockpool_shelf` | 84, 84, 92 (black rock) |
| `kelp_shallows` | 120, 196, 196 (knee-deep water over sand) |
| `sandbar_causeway` | 240, 228, 190 |
| `mudflat_boardwalk` | 140, 132, 120 (grey mud) |
| `shipwreck_reach` | 226, 210, 170 |
| `tideward_steps` | 150, 170, 150 (green-slick stone) |
| The wrack line: `tide_flats_route_a`, 0 to 160 along, `near` -38, `far` -30 (the bay side; negative is the walker's left) | 110, 96, 70 |

**Lane surfaces** (`laneSurfaces`):
- Route A, 330 to 500: planks (170, 130, 90), **deck**. The sunken plank path through the shallows.
- Route B, 180 to 360: planks (170, 130, 90), **deck**. The boardwalk on stilts.
- Route B, 540 to 720: stone (176, 186, 168). The breakwater steps.

`laneWidth` is 14.

**Grass looks** (`grassLooks`):

| Area | Model | Under |
| --- | --- | --- |
| `wrack_beach` | MarramTuft | 176, 170, 118 |
| `rockpool_shelf` | Kelp | 70, 96, 84 |
| `kelp_shallows` | Kelp | 60, 120, 110 |
| `sandbar_causeway` | MarramTuft | 176, 170, 118 |
| `mudflat_boardwalk` | Reeds | 110, 108, 82 |
| `shipwreck_reach` | MarramTuft | 176, 170, 118 |
| `tideward_steps` | MarramTuft | 150, 160, 120 |

**Town lanes** (`lanes`):

| Lane | Points | Width | Colour | Deck |
| --- | --- | --- | --- | --- |
| Rope Walk | (-150,0) (-28,0) | 16 | 240, 230, 206 | |
| East Street | (28,4) (90,14) (150,20) | 14 | 240, 230, 206 | |
| The Quay | (-40,42) (110,42) | 12 | 170, 130, 90 | yes |
| Quay steps | (0,26) (0,42) | 10 | 170, 130, 90 | yes |
| Warm Pool path | (-64,-8) (-64,-30) | 8 | 232, 220, 186 | |
| Tally path | (-14,-26) (-20,-42) | 8 | 232, 220, 186 | |
| Chandlery path | (28,-6) (48,-14) | 8 | 232, 220, 186 | |
| Brood path | (12,-26) (30,-64) | 8 | 232, 220, 186 | |
| Ring path | (96,15) (90,-30) (84.7,-58.7) | 8 | 232, 220, 186 | |
| Ferry path | (-50,8) (-46.7,50.7) | 8 | 232, 220, 186 | |
| The mole | (110,42) (110.1,62) | 10 | 170, 165, 150 (stone) | |
| Stilt Row | (-90,0) (-110,30) (-110,150) | 10 | 170, 130, 90 | yes |
| Dune Road | (-180,0) (-150,0) | 14 | 240, 230, 206 (joins Dust Canyon's sealed road, which reaches -180) | |
| Ferry jetty | (-40,70) (-14,70) | 4 | 170, 130, 90 | yes |

Tide Flats has no shortcut lane. The lair's `shortcutToHub` is shown as a sign by the Wreck Stall (below). The builder's brambles code reads the last lane only when `brambles` has entries, and here it is empty.

**Plaza and centre:** `plaza = { at (0,0), size 56, rim 60, colour, rimColour }` (Net Square). There is no `well`. The centrepiece is an upturned Rowboat prop at (0, -3).

**Water:**
- `water = {}`.
- `pools`:
  - The Warm Pool at (-92, -30), radius 7, colour (120, 200, 200), beside the healer.
  - The Brood Shallows' pens at (4, -84) and (56, -84), radius 5, colour (84, 170, 196).
- `pond`, `waterfall` and `footbridge` are left out.

**Flats** (`flats`, drawn in this order):

| # | From | To | Colour | Water | What |
| --- | --- | --- | --- | --- | --- |
| 1 | (-30, 50) | (100, 150) | 64, 150, 186 | yes | The harbour |
| 2 | (-70, 150) | (250, 330) | 84, 170, 196 | yes | Saltwick Bay |
| 3 | (250, -80) | (440, 140) | 84, 170, 196 | yes | The outer water, left of the causeway and boardwalk |
| 4 | (250, 240) | (470, 330) | 150, 140, 124 | no | The mudflat, right of the boardwalk |
| 5 | (236, 160) | (286, 330) | 240, 228, 190 | no | The sandbar spit, which Route A's broken bridge points at |
| 6 | (-200, 470) | (900, 900) | 56, 130, 176 | yes | The open sea |
| 7 | (820, 140) | (900, 470) | 56, 130, 176 | yes | The sea east of the headland |

Corridor ground paints over the flats, so the causeway reads as sand between two waters, the boardwalk corridor as mud, and the kelp shallows as turquoise. No prompt or grass centre lies in a water flat (checked).

**Walls** (`walls`):

| Wall | Points | Style | Tall |
| --- | --- | --- | --- |
| North dunes | (-150,-20) (-150,-150) (150,-150) (150,6) | Dunes | 8 |
| West dunes | (-150,20) (-150,150) (-124,150) | Dunes | 8 |
| South dunes | (-96,150) (-30,150) | Dunes | 8 |
| Harbour wall, west | (-30,150) (20,150) | SeaWall | 6 |
| Harbour wall, east | (70,150) (150,150) (150,34) | SeaWall | 6 |
| Mole wall | (100,150) (100,80) | SeaWall | 6 |
| Dune Road, north | (-236,-20) (-150,-20) | Dunes | 10 |
| Dune Road, south | (-236,20) (-150,20) | Dunes | 10 |
| Sea cave outcrop | (533.9,129.4) (525.3,155) (553.8,163.6) (562.4,138) | Cliff | 24 |

The outcrop juts from the reach's north cliff (at 65 off the lane) to 38 off it. The Tide Cave rustle spot is 24 off, 14 studs in front of its face. `hedges = {}`.

**Fences** (`fences`):

| Fence | Points | Style | Across |
| --- | --- | --- | --- |
| Harbour rail, west | (-30,150) (-30,76) | Rope | no |
| Quay rail | (-30,64) (-30,50) (100,50) | Rope | no |
| Floating boom in the harbour mouth | (20,150) (70,150) | Rope | no |
| Broken plank bridge across Route A's end | (191.4,331.9) (212,366.1) | Rope | yes |

The gap in the harbour rail at z 64 to 76 lets the ferry jetty through.

**Arches** (`arches`, model HarbourArch):

| At | Faces | Outside | Inside |
| --- | --- | --- | --- |
| -142, 0 | 270 | Saltwick | Dune Road · to Kilnrest |
| -110, 142 | 180 | Saltwick | Route A · Strandline Path |
| 142, 19 | 84 | Saltwick | Route B · Breakwater Road |

**Signposts** (`signs`):

| At | Faces | Lines |
| --- | --- | --- |
| -128, -14 | 90 | "Net Square · Tarn's Chandlery →" |
| -84, 22 | 214 | "↓ Stilt Row", "Route A · Strandline Path" |
| 36, 20 | 84 | "Route B · Breakwater Road →", "↓ The Quay · Lamp Tower" |
| -100, 196 | 285 | "Dune grass:", "wild creatures hide here" |
| 486, 168 | 143 | "Carrackon's Wreck · Wreck Stall" |
| 548, 222 | 315 | "Ferry to Saltwick:", "not while the wreck is awake" |
| 700, 124 | 90 | "The Breakwater Gate", "badge challenge" |
| 184, 336 | 59 | "Plank bridge out.", "The tide took it." |
| -200, -14 | 90 | "Saltwick →" (on the Dune Road) |

**Lamps** (`lamps`): Rope Walk (-120,-11) (-80,-11) (-40,11); square (-22,-22) (22,-22) (-22,22) (18,24); quay (-20,30) (40,30) (80,30); East Street (84,2) (120,28); arches (-142,-11) (-142,11) (141,8) (139,31) (-121,142) (-99,142); the gate (700,98) (724,124). That is 20 in all.

**Flower beds** (`beds`, read as pots of sea-pinks): Chandlery (50,-24) (50,-4); Warm Pool (-72,-28) (-56,-28); square (-30,-14) (30,-20); Rope Walk (-46,-12); quay (46,26).

**Trees** (`trees`):
- Reeds round the Warm Pool: (-101,-26) (-92,-39) (-83,-25).
- SeaRocks on the mole: (140,90) (112,140).
- Kelp in the harbour (scale 0.8): (40,130) (80,96) (-10,120).

**Rows** (`rows`): MarramTuft at the foot of the dunes, step 8, from (-140,-140) to (-60,-140) and from (0,-140) to (140,-140). Another, step 10, from (-140,-130) to (-140,-30).

**Houses** (`houses`, keeperless):

| At | Faces | Model | Width × depth, tall |
| --- | --- | --- | --- |
| -136, 60 | 90 | StiltHouse | 18 × 18, 24 |
| -136, 100 | 90 | StiltHouse | 18 × 18, 24 |
| -86, 104 | 270 | NetLoft | 20 × 16, 20 |
| -112, -64 | 135 | NetLoft | 20 × 16, 20 |
| -96, -114 | 180 | StiltHouse | 18 × 18, 24 |
| 60, -118 | 180 | NetLoft | 20 × 16, 20 |
| 124, -28 | 270 | StiltHouse | 18 × 18, 24 |

**Props** (`props`):

| Model | At | Faces | Tall | Solid |
| --- | --- | --- | --- | --- |
| Rowboat (upturned, the square's centrepiece) | 0, -3 | 90 | 5 | yes |
| Rowboat | 30, 100 | 30 | 5 | no (afloat) |
| Rowboat | 70, 122 | 300 | 5 | no |
| Rowboat (the ferry, at the jetty) | -10, 78 | 90 | 5 | no |
| Barrels | 60, 28 | 0 | 6.5 | yes |
| Barrels | -36, -14 | 90 | 6 | yes |
| WashingLine (drying nets) | -122, 80 | 0 | 8 | no |
| WashingLine | -60, -96 | 90 | 8 | no |
| SeaRocks | 130, 120 | 0 | 8 | yes |
| ShipRibs | 470, 270 | 100 | 30 | yes |
| SeaCave | 540.1, 157.9 | 198 | 24 | yes (its face is 6.4 from the Tide Cave prompt) |
| Bench | -36, 30 | 180 | 3.8 | no |

**People** (`people`):

| Name | At | Faces | Model |
| --- | --- | --- | --- |
| Net-mender | -122, 72 | 90 | Grandmother |
| Fisher | 64, 38 | 180 | Tamer |
| Child | -36, 64 | 90 | GirlTamer |
| Gull-watcher | 116, 100 | 135 | Carer |

**The rest:**

| Field | Value |
| --- | --- |
| `stones` | Stepping stones from (-70, -24) to (-84, -28), from the Warm Pool path to the pool |
| `footpaths` | Empty |
| `coop` | (-4, -104): egg nests in seaweed behind the Brood Shallows (the builder's coop and nests) |
| `patch`, `well` | Left out |
| `ring` | { width 40, depth 30, gap 12 } for the Breaker Ring (its rail in style Rope) |
| `clearings` | { at (693.6, 385.7), radius 90, ring true }: the cove, ringed by the spur's left style (Cliff) |
| `caps` | `tide_flats_route_a` = 21 (the broken bridge fills the middle); `tide_flats_route_b` = 20 (the gate fills it) |
| `corridorTrees` | `wrack_beach`: MarramTuft 1.5. `rockpool_shelf`: SeaRocks 0.7. `kelp_shallows`: Kelp 1.2. `sandbar_causeway`: SeaRocks 0.6. `mudflat_boardwalk`: Reeds 1. `shipwreck_reach`: SeaRocks 1. `tideward_steps`: SeaRocks 0.8. `tide_flats_lair`: SeaRocks 1. Nothing is planted on a water flat. |
| `gatehouse` | { at (742.9, 110), faces 270, model "BreakwaterGate", banner "Breaker Badge" } |
| `bar` | { at (755.9, 110), width 20 }: 13 past the gate, 47 short of the sealed path |
| `landmark` | { at (790, 470), model "OldLighthouse", tall 140, faces 301 }: its door towards Saltwick |
| `stall` | { side = -1 }: the counter stands south-west of the spur, away from the Tide Cave |
| `brambles` | Empty |
| `knoll`, `picnic`, `pocket`, `ancientTree`, `pond`, `waterfall`, `footbridge` | Left out |

### 3e. Why each spot is where it is

- **The Chandlery on the arrival axis**, because Odalys is the chapter's second beat. The healer, the Waystation (Ferry Steps) and the Tally Board are all within 9 seconds of the arch.
- **Route A leaves by Stilt Row**, the homeliest street, signed where its boardwalk leaves the Rope Walk, 52 studs in from the arch. It leaves the town's south edge, not its west edge: a route leaving west would run beside the Dune Road and come within 100 of Dust Canyon's places.
- **Route A ends facing Route B's sandbar** across a channel, with a broken bridge. The two routes are tied together the way Greenwood's old fence shows the spring, and players see where they will go next.
- **Captain Marr stands on the boardwalk**, with the mud on both sides and nowhere to go round her.
- **The Tide Cave is in a real outcrop** of the reach's cliff, beside the spur fork. `wreck_sighting` fires at 450, just past the fork, where the ribs, the cove and the Old Light line up.
- **Waking after a loss** lands at about (-58.6, -27.5), 6 studs from the Warm Pool's door towards the square.

### 3f. Rules these coordinates were checked against

The same set as plan 09 section 3f, all passing:
- **Ids and lengths.** Ids are real. Leg sums are within 5: route A 498.0 of 500, route B 720.1 of 720, spur 280.5 of 280.
- **Gate and spur.** The gate ends Route B and the sealed road runs 60 due east. The spur starts at 440.
- **Story.** Every Chapter 3 target has a place, and both story battles have stands within 8 (6.0 and 6.9).
- **Prompts.** No two prompts are within 32 studs. The closest pairs are Merrin and the Kelp Bed (44.3), the Warm Pool and the Tally Board (45.6), the Tide Cave and the stall (46.6), and the Chandlery and the Brood Shallows (53.1).
- **Grass.** Each grass patch lies inside its stretch. No patch overlaps another patch, the town square plus 20, or a tamer, and none comes within 26 of a prompt.
- **Tamers and rustle spots.** Tamers are within 12 of the lane (the furthest is 10.3) and within 40 of their `at` (the furthest is 10.3). Rustle spots are within 30 (the furthest is 24).
- **Corridors.** Every route place, grass edge included, is inside its corridor. The tightest are the steps grass (45.5 of 48), the mudflat grass (46.2 of 50) and the shelf grass (51.1 of 55).
- **Town.** Buildings are inside the town and 28 apart (the closest are the Warm Pool and the Tally Board at 45.6). The Route A entry is 147 from the nearest door.
- **Neighbours.** Every Tide Flats place is more than 100 from every Dust Canyon place (the closest is 178.5) and every Greenwood place (1172).
- **Dressing.** No fence, wall or gatehouse tower comes within 6 of a prompt. No wall crosses a lane except the broken bridge (across). No house or solid prop stands on a town lane, and no lamp stands in long grass.
- **Extra checks.** Lamps, signs and beds stay off lanes and clear of prompts; houses and solid props do not overlap.

---

## 4. What bounds the corridors, and the sheet fields

The fields, styles and builder recipes are defined in **plan 09 section 4**. Tide Flats uses them like this:

| Edge style | Where in Tide Flats |
| --- | --- |
| Rope | The bay side of the beach, both sides of the kelp shallows (with cork floats), the causeway's outer side, both sides of the mudflat boardwalk, the harbour rails and boom, the broken plank bridge, and the Breaker Ring's rail |
| Dunes | The beach's landward side, the town's north, west and south-west edges, and the Dune Road |
| Rocks | The rock shelf, the causeway's bay side, the reach's bay side, and the spur's right side |
| Cliff | The reach's north side (the sea cave's cliff), its outcrop, the spur's left side and the cove's ring |
| SeaWall | The breakwater steps (both sides) and the harbour walls |

What replaces Greenwood-only dressing:

| Greenwood | Tide Flats |
| --- | --- |
| Pond and jetty | The harbour (flat 1) with a quay deck, rope rails, a ferry jetty and rowing boats |
| Brook and river | The bay, the outer water, the open sea and the mudflat (`flats`) |
| Footbridge | The broken plank bridge (Rope, across); the boardwalk and plank path are deck lanes |
| Orchard and hedgerow trees | Marram rows, reeds, sea rocks and kelp |
| Hedge loop round town | Dunes and sea walls (`walls`) |
| Ancient tree | The Old Light (`landmark`) |
| Shut wicket and brambles | A sign by the Wreck Stall: the ferry back is not running |

Uses particular to Tide Flats:
- **Deck lanes**: the quay, the quay steps, Stilt Row, the ferry jetty, the sunken plank path (Route A 330 to 500) and the boardwalk (Route B 180 to 360).
- **The Rope edge beside water**: posts stand in the water flat. The builder must not stop the rope short of a flat, only of a stream or pool (plan 09 section 4c).
- **Swimming is out of scope.** A player who jumps a rope rail walks on the flat "water". Every rail is at least 3.2 high. A later step could add a client-side splash and a gentle push back.

Builder fixes from plan 09 section 4d apply here too:
- The ground slab is clipped at Dust Canyon's gate + 30 (here x = -270).
- The Breaker Ring is found by its role, "Circuit".
- The stall is labelled "Wreck Stall".
- Add `tide_flats = TideFlatsDressing` to `TestMap.DRESSINGS`.

---

## 5. Models

Generated in the same clay-toy style, each on a flat base with its front facing -z:

| # | Name | Prompt | Size (x / y / z) | Used for |
| --- | --- | --- | --- | --- |
| 1 | HarbourArch | A seaside town gateway of two weathered driftwood posts wrapped in thick rope, joined by an arched beam hung with a fishing net, coloured glass floats and a blank cream sign board, with a lobster pot at each foot, hand-painted clay toy style, soft rounded shapes | 22 / 18 / 6 | The three town arches |
| 2 | StiltHouse | A small fisher's cottage of pale blue painted planks on chunky wooden stilts above the sand, a short ladder up to a little porch, a red tiled roof with a stubby chimney, a round porthole window and nets drying on the rail, hand-painted clay toy style, soft rounded shapes | 18 / 24 / 18 | Houses (style 1) |
| 3 | NetLoft | A cosy tarred-plank net loft cottage in dark brown with white window frames, a roof shaped like an upturned boat, a wide loft door with a hoist beam and hanging nets and cork floats, hand-painted clay toy style, soft rounded shapes | 20 / 20 / 16 | Houses (style 2) and the Brood Shallows |
| 4 | Chandlery | A two-storey harbour chandler's shop of white-washed timber with a teal striped awning, coils of rope, oars and buckets by the door, a big brass ship's lantern and a hanging sign shaped like an anchor, hand-painted clay toy style, soft rounded shapes | 24 / 28 / 20 | Tarn's Chandlery (the hero building) |
| 5 | LampTower | A stubby round harbour light tower of white stone with one red band, a small glass lantern room with a gold lamp on top, a wooden door and a railed walkway, sitting on a rock, hand-painted clay toy style, soft rounded shapes | 16 / 36 / 16 | The Lamp Tower (lookout) |
| 6 | BreakwaterGate | A sturdy sea gate on a stone breakwater: two round grey stone towers with teal conical roofs and white trim, a rounded arch between them with open iron-studded wooden doors, a teal-and-white banner showing a breaking wave, and rope and barnacles at the foot, hand-painted clay toy style, soft rounded shapes | 44 / 34 / 16 | The gate (`gatehouse.model`) |
| 7 | OldLighthouse | A tall old white lighthouse with three broad red bands, a black iron lantern room with a glowing yellow light and a railed gallery, on a rounded rocky knoll with a few tufts of grass, hand-painted clay toy style, soft rounded shapes, a bold silhouette made to be seen from far away | 40 / 140 / 40 | The Old Light (`landmark`) |
| 8 | ShipRibs | The curved wooden ribs and keel of a huge old wrecked sailing ship half buried in sand, rising like a ribcage, with a broken mast lying beside it, seaweed and barnacles, hand-painted clay toy style, soft rounded shapes | 60 / 30 / 24 | Shipwreck Reach |
| 9 | SeaCave | A rounded sea-cliff outcrop of dark grey rock with a big dark cave mouth at its base, wet green weed round the opening, a few barnacles and a faint green glow deep inside, hand-painted clay toy style, soft rounded shapes | 24 / 24 / 18 | The Tide Cave |
| 10 | MarramTuft | A clump of tall seaside marram grass, thin rounded blades in blue-green and pale straw, leaning in the wind, on a small mound of sand, hand-painted clay toy style, soft rounded shapes | 4 / 3 / 4 | Grass on the beach, causeway, reach and steps; dune crests; rows |
| 11 | Kelp | A clump of long wavy kelp ribbons in olive and brown-green rising from a small rock, with round air bladders, hand-painted clay toy style, soft rounded shapes | 4 / 5 / 4 | Grass in the shallows and pools; harbour; planting outside the shallows |
| 12 | SeaRocks | A cluster of three rounded dark grey sea rocks with barnacles, limpets and a fringe of green weed at the base, wet and shiny, hand-painted clay toy style, soft rounded shapes | 12 / 6 / 9 | Rocks edges, the sea wall's foot, props and planting |
| 13 | Rowboat | A small wooden rowing boat painted red and white with two oars resting inside and a coil of rope, hand-painted clay toy style, soft rounded shapes | 12 / 5 / 5 | The harbour, the ferry and the square's centrepiece |

Reused: Healer (the Warm Pool), Waystation (the Ferry Steps), NoticeBoard (the Tally Board), Reeds (mudflat grass, planting, round the Warm Pool), Barrels, WashingLine (drying nets), Bench, Lamp, Signpost, Stall (the Wreck Stall), and the people models.

---

## 6. Walk times (16 studs a second, along the streets)

| Walk | Studs | Seconds |
| --- | --- | --- |
| West arch to entering the hub | 80 | 5.0 |
| West arch to the Warm Pool door | 94 | 5.9 |
| West arch to the Ferry Steps door | 129 | 8.1 |
| West arch to the Tally Board | 147 | 9.2 |
| West arch to the Chandlery door | 178 | 11.1 |
| West arch to the Brood Shallows | 190 | 11.9 |
| West arch to the Lamp Tower (along the quay) | 284 | 17.8 (optional lookout) |
| West arch to the Breaker Ring | 300 | 18.7 (optional, behind the Chandlery) |
| Warm Pool to the south arch (Route A) | 212 | 13.3 |
| Warm Pool to the east arch (Route B) | 245 | 15.3 |
| Square to Nell (246 in town, then 127 along) | 373 | 23.3 |
| Whole of Route A | 500 | 31.3 |
| Whole of Route B | 720 | 45.0 |
| Each stretch | 160 to 180 | 10.0 to 11.3 |
| Square to the gate (151, then 720) | 871 | 54.4 |
| Square to the lair (151, then 440, then 280) | 871 | 54.4 |

Saltwick's built area is about 280 by 275 inside its 300 square. Every door except the two optional ones is within 12 seconds of the arch.

---

## 7. Sightlines

**From the arrival point (-128, 0), facing east (90):**

| What | Bearing | Distance | Top |
| --- | --- | --- | --- |
| Tarn's Chandlery, door towards you (the story's next step) | -4.2° | 193 | 6.8° |
| The east arch, Route B | +4.1° | 279 | |
| The Lamp Tower on the mole | +15.5° | 262 | 6.8° |
| The Stilt Row sign, Route A's turn | +26.6° | 49 | |
| **The Old Light** | **+27.1°** | **1031** | **7.5°** |
| The south arch itself | +82.8° | 143 | off screen; the boardwalk and sign lead to it |

The harbour's sea walls are 6 tall, so nothing tall stands between the arrival and the Old Light. The Lamp Tower is 11.6° to its left and the ship's ribs (30 tall) are below it. The cove's cliffs (30 tall, 907 away) reach only 1.6°, so the whole lighthouse stands clear. From the quay (0, 42) looking south-east it is 17° left of that, 898 away and 8.5° up: "seen from the quay", as the hub data says. From the `shipwreck_reach` sight point it is 45° right of east, 397 away and 18.8° up.

**Hiding the neighbours:**
- **West (Dust Canyon).** The Dune Road's dune ridges (10 tall) and the town's dunes. Looking back, the Stair Gate stands on the skyline 300 away, the way home, and the Redstack's top is a faint red block far to the north-west.
- **East (the Mire, not open yet).** The Breakwater Gate and the sea walls of the steps. Beyond the gate there is only the sealed road along the breakwater and open water. When the Mire opens, its dark trees can show across the water as the next tease.
- **South.** The open sea.
- **North.** The outer water and the dunes.

---

## 8. Build order and Studio checklist

### Build order (after plan 09's type changes; `lune run check` after each step)

1. **Map sheet.** Add `src/content/map_data/TideFlats.luau` from section 3a. In `src/content/biome_data/TideFlats.luau`, add `map = require("../map_data/TideFlats")`.
2. **Tests.** The generalised `tests/layout.test.luau` from plan 09 step 3 now covers Tide Flats with `Chapter3`:
   - Check `map.models.lamp_tower == "LampTower"`.
   - Check the neighbour pair Dust Canyon and Tide Flats.
   - Add the check that no prompt or grass centre lies inside a water flat.
   - `tests/tideflats.test.luau` builds the map by id only and should still pass.
3. **First play** with the sheet and no dressing.
4. **Dressing sheet.** Add `src/content/map_data/TideFlatsDressing.luau` from section 3d. The generalised dressing checks cover it.
5. **Builders.** Plan 09 section 4 covers them all. Tide Flats is the first user of deck lanes, Rope, Dunes, Rocks and SeaWall edges, water flats and grass looks other than tufts, so test those here.
6. **Models.** Generate the 13, add them to `src/content/PropModels.luau`, and log them in `docs/ASSETS.md`.
7. **Optional, last:**
   - Gentle waves (a slow texture scroll on the water flats).
   - Gull calls and surf.
   - The Old Light's beam turning at dusk (a client-side SpotLight).
   - A splash and push-back for anyone who jumps a rail into the sea.

### Check in Studio

- [ ] Coming over the Dune Road: the Chandlery's door is dead ahead, the Old Light is about 27° right over the harbour mouth, and the Stilt Row sign and the east arch are both on a phone screen.
- [ ] `tide_arrival` fires about 5 seconds past the west arch.
- [ ] The ground does not flicker at the Dust Canyon/Tide Flats join (slab clipped at x -270), and the water flats do not z-fight with the town's sand or the corridor ground.
- [ ] Decks: people stand on the planks (the raycast finds them), the ramps are walkable, and the boardwalk sits 1 stud above the mud.
- [ ] Waking after a loss lands on the Warm Pool's forecourt at about (-58.6, -27.5).
- [ ] Each prompt shows alone. The tightest pair is Merrin and the Kelp Bed, 44.3 apart.
- [ ] Grass ambushes start only on the dark discs. The marram, kelp and reeds stay inside them.
- [ ] Nell is seen from the south arch. Marr cannot be walked round on the boardwalk. The Tide Cave prompt shows in front of the cave, not inside the rock.
- [ ] `wreck_sighting` fires just past the spur fork, with the ribs and the Old Light in view.
- [ ] The rival's prompt works inside the Breakwater Gate's arch, and `tide_road_on` does not fire until the bar.
- [ ] No creature appears outside a rope rail on the water. The narrowest corridor is the causeway at 35, and creatures stand at most 18 to the side.
- [ ] The Old Light reads as a lighthouse from 1000 studs. If not, raise `tall` or lower the Atmosphere density.
- [ ] Draw calls and frame rate on a phone-sized view: seven large flats, about 650 grass pieces and about 1,400 studs of rope rail.
- [ ] Screenshots from the west arch, the quay, Stilt Row, the causeway, the boardwalk with Marr, and the reach, checked against the brief's art direction.

---

## 9. Decisions I made that the written world did not settle

1. **Every position, facing, width and colour here is mine**, a [Default]. The written world gives names, lengths and notes only.
2. **Saltwick is entered from the west over the dunes.** Layout places it east of Dust Canyon's gate.
3. **The town plan:**
   - A harbour on the south side, opening into the bay through a boomed mouth.
   - Net Square has an upturned boat at its centre.
   - The Chandlery is the hero building on the arrival axis.
   - Stilt Row is a boardwalk street of stilt houses, and it is the way to Route A.
   - The Lamp Tower stands on the harbour mole.
   - The Ferry Steps (the Waystation model) stand beside a short jetty.
4. **The Old Light is the landmark**, standing over Carrackon's Wreck, and the in-town Lamp Tower is a separate small harbour light. The hub data mentions "the old white lighthouse on the headland" and also lists a Lamp Tower building, so I kept both. **For Ayrton:** the backstory (the light failed, and that is why the wreck is there) is mine.
5. **Route A and Route B are tied together**: Route A ends at a broken plank bridge pointing at Route B's sandbar spit.
6. **Saltwick Bay** is the water enclosed by the two routes and the town. The mudflat lies south of the boardwalk, the outer water north of it, and the open sea south of everything.
7. **Route A leaves south, not west**, to keep 100 studs from Dust Canyon's places and the Dune Road.
8. **The shortcut** (`shortcutToHub`) is a sign by the Wreck Stall about a ferry that is not running, with no shut path. A path across water would need a bridge or a boat that the map cannot honestly block.
9. **The long grass changes with the ground**: marram on sand, kelp in the pools and shallows, reeds on the mud. The rock shelf's "grass" is weed-choked pools.
10. **Recognisable services.** The Warm Pool reuses the Healer model and the Ferry Steps reuse the Waystation model, as in Kilnrest (plan 09 decision 5).
11. **The tide cave is an outcrop jutting from the cliff**, so the rustle spot can stand in its mouth inside the corridor.
12. **No swimming**: the rope rails are the honest edge, and a jump over one lands on painted water (optional fix later).
13. **New names for places:** Net Square, the Rope Walk, Stilt Row, the Quay, the mole, the Dune Road, Saltwick Bay, the Old Light and the sandbar spit. All are placeholders.

**Open for Ayrton (batch, with plan 09's):**
- Keep the lighthouse's backstory, and keep two lights (the Old Light and the Lamp Tower)?
- Is walking on painted water acceptable for now, or should rails be taller or the sea push back?
- Should the shortcut back from the wreck stay a ferry (a later feature), or be cut?
