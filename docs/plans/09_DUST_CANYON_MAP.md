# 09 · Dust Canyon, designed (Kilnrest and the Mesa Road)

Dust Canyon still uses the generated layout: buildings in a ring, routes zigzagging on open green ground, a random scatter of trees. This plan replaces it with a map drawn on purpose, to the standard of `08_GREENWOOD_MAP.md`. It keeps every place the server checks and every number in `src/content/biome_data/DustCanyon.luau` (route lengths, stretches, `at` distances, the spur, the gate).

Conventions (the same as plan 08 and `src/content/map_data/Greenwood.luau`):
- Studs. Every point is relative to Kilnrest's centre, the hub place `dust_canyon_hub`, at (0, 0).
- **North is -z** (the top of every map); east is +x.
- A facing is degrees clockwise from north: 0 N, 90 E, 180 S, 270 W. It points along (sin θ, -cos θ).
- "Left" and "right" are as seen by someone walking away from town. In the code, right is the side `Layout.pointAt` pushes for a positive `side` and the side `Corridors.edges` builds for `side = 1` (south when walking east).
- Walking speed is 16 studs a second.

**Where Dust Canyon sits.** `Layout.world` puts each later hub 240 studs (`BIOME_GAP` 80 + `NEXT_HUB_ALLOWANCE` 160) past the previous biome's sealed road. Greenwood's sealed path is at world (744.4, -80), so Kilnrest's centre is at world **(984.4, -80)**. In this plan's coordinates Greenwood's gate is at (-300, 0) and its sealed path at (-240, 0). Greenwood's own sealed-road slab already runs to (-180, 0). Dust Canyon's Route B ends heading due east at (779, -100), so Tide Flats' hub lands at (1079, -100) here, which is world (2063.4, -180). Plan 10 depends on that number: **do not change the last leg of Route B without redoing plan 10.**

**How the numbers were checked.** I ran every rule in `tests/layout.test.luau` on these exact sheets in a scratch copy of the project, using the project's own `Layout.luau`, `Biomes`, `Tamers` and `Chapter2` data. That covers ids, leg sums, story targets, prompt spacing, stands, grass, tamers, corridors, the town and the dressing. I also ran some extra checks: lamps, signs and beds stay off lanes and out of grass, houses do not overlap, and neighbouring biomes stay apart. Everything passes. The rules and the closest values are listed in section 3g.

---

## 1. The idea

**Kilnrest is a potters' town in the floor of a red canyon.** You come in from Greenwood through the Westcut, a slot between two sandstone walls. The canyon opens into a warm bowl with cliffs on both sides, a terracotta square with a well, and flat-roofed adobe houses built against the north cliff. Domed kiln cottages smoke, and the great bottle kiln of the Cradle Kiln glows by the road east. Everything is warm stone and baked clay: no hedges, no lawns, nothing green but scrub and the little garden by the Seep House spring.

There are two ways out:
- **Route A, Dry Wash Trail**, leaves north up a dry riverbed of pale pebbles. It opens on to wide cracked flats where tumbleweed drifts against low ochre rocks. Then it squeezes into a banded arroyo and stops at a broken rope bridge over a dry fall.
- **Route B, Mesa Road**, leaves east. It climbs red stone steps on to the north rim of the gorge, with a long drop on the right and wind-carved hollows in the wall on the left. It threads a garden of striped rock spires, then climbs a buttressed stone road to the Stair Gate.

**The landmark is the Redstack**, a towering flat-topped red mesa with a pale cap. It stands 190 studs tall at (650, -480), north-east of everything. Its top half rides above the canyon rim from the moment you walk in. At its foot, on a shelf at the end of the lair spur, sleeps Mesalith, the mesa that walks. At the Spire Garden the player finally stands under the Redstack and sees the "rock" on its shelf move: the `mesa_sighting` beat.

How it must feel different from Greenwood:

| | Greenwood | Dust Canyon |
| --- | --- | --- |
| Edges | Hedges and tree lines | Banded cliff walls, boulder banks and rock spires |
| Ground | Green lawn and meadow | Baked clay, pale pebbles, cracked ochre, red stone |
| Water | Brook, river, pond | One small spring (the Seep) and a dry gorge |
| Long grass | Green tufts | Straw-gold dry bunch grass |
| Town | Thatched cottages round a green, open sky | Adobe and kiln domes in a canyon bowl, sky framed by cliffs |
| Routes | Gentle bends between hedges | A climb: wash, flats, gully; steps, rim, spires, stair |
| Landmark | A golden tree, a soft round silhouette | A red mesa, a hard flat-topped silhouette |
| Sound (optional) | Birdsong | Wind and wind chimes |

---

## 2. Maps

These maps were drawn from the coordinates by script, so positions are true to the scale given. They are coarse: the tables in section 3 are what counts.

### 2a. The whole biome

Scale: 20 studs per character across, 40 studs per line down. North is up.

```
z -640
z -600                  ####v                                    v dry fall (dark chasm), # far side
z -560                  x=v###                                   x rope bridge (broken), end of Route A
z -520                 g==x
z -480                 ==r                         MMM           M the Redstack (landmark, 190 tall)
z -440               =2=                           M M
z -400             ==
z -360             g                                             g long grass   r rustle spot
z -320             =                      x::   O                O Mesalith's Shelf (arena r80)
z -280             ==                  ::xx    =                 :: winch track (shut), x rockfall
z -240             1=               :::       =
z -200              =g        ::::::         ==                  = lanes (routes and spur)
z -160      ########=####xx#::             ===        ##
z -120      #       ::   : #       #       S  4===r   5#++       S Shelf Stall   ## buttresses
z  -80      #:::::  : ::   #     #r#  =g=====g    ==g=====G  >   G Stair Gate   > sealed road
z  -40      # : : : :      #    =======               ##
z    0 ######::::::K:::    #  =3=,,,,,,,,,,,,,,,                 K Kilnrest   ,,, the gorge floor
z   40 ######   :  : ::::::===  ,,,,,,,,,,,,,,,,
z   80      #      :  :    #g   ################                 ### gorge far wall
z  120      #              #
z  160      ################
   x   -240      -40       160       360       560       760
Tamers: 1 Ines  2 Rafe  3 Perrin  4 Hesper  5 Tavish.  The rival stands on the rim at (370, -66).
Greenwood's gate is off the left edge at (-300, 0); its road arrives through the Westcut (the ### pair at z 0 to 40).
```

- **Kilnrest (hub):** centre (0, 0). The square stays 300 by 300 and the built area is about 270 by 255. Cliffs on all sides, with gaps at the Westcut (west), the wash (north), the east road and the shut winch gate.
- **Route A, Dry Wash Trail (450):** leaves north through the north arch. It is an S: up the pebble wash, bends north-west round a low bank on to the tumbleweed flats, then north-east into the arroyo. It ends at a broken rope bridge over a dry fall.
- **Route B, Mesa Road (680):** leaves east through the east arch. It climbs the Redstone Steps north-east, runs east along the Sunbaked Rim with the gorge on its right, dips south-east into the Spire Garden (the spur forks north at 360), and climbs east to the Stair Gate between two rock buttresses.

### 2b. Kilnrest

Scale: 5 studs per character across, 10 studs per line down. North is up.

```
z -160                                    ==                     :        == Route A leaves north
z -150   ################################  =  ##################xxx###    xxx shut winch gate
z -140   #                                 A                   ::    #    A arch
z -130   #                                 :                  ::     #
z -120   #          h     h               ::                 ::      #    h keeperless house
z -110   #    h                           ::::                       #    (Cave Row: houses against the cliff)
z -100   #  ::::::::::::::::::            :   ::::::                 #
z  -90   #       :                        :        ::::::            #
z  -80   #       :                        :              L           #    L Windward Overlook
z  -70   #       :                        :                          #
z  -60   #       :                       ::                          #
z  -50   #       :                       :                           #
z  -40   #       :                N:     :                     h     #    N Notice Wall
z  -30   #       :       W::       :     :                           #    W Sundial Waystation
z  -20 ###       :         ::      :                                 #
z  -10           :          ::                 ::T                   #    T Rook's Trading Post (hero)
z    0 ::::A:@::::::::::::::::::::     o     :::                     #    @ arrival  o Sundial Square, well
z   10                    :                                          #
z   20 ###                :                 :::::::                  #
z   30   #           ~    H            :          :::::::::::        #    H Seep House  ~ the Seep spring
z   40   #                             :          :         :::::::A:===  Route B leaves east
z   50   #                             :          ::       c         #    c nests by the kiln
z   60   #     h                       :           K                 #    K Cradle Kiln (bottle kiln)
z   70   #                             D                             #    D Dust Ring
z   80   #                                                           #
z  100   #                                                     h     #
z  110   #       h                                                   #
z  120   #                  h                                        #
z  150   #############################################################    # canyon cliffs, 30 tall
   x   -160      -110      -60       -10       40        90        140
: streets and paths.  The Westcut walls run west from the gap at z -20 to 20.
```

**Arriving.** The player walks in from Greenwood through the Westcut and the west arch (-142, 0), facing east down Kiln Street. The first thing the story needs is entering the hub (within 48 of (0, 0)), which happens 5 seconds in. The second is talking to Tamsin Rook, whose Trading Post stands straight ahead across the square with its door facing the arrival. The healer and the Waystation are the first two doors on the way, left and right of the street.

### 2c. Route A: Dry Wash Trail

Scale: 10 studs per character across, 20 studs per line down. North is up.

```
z -620
z -600                   ####vvvvvv      v the dry fall (dark), #### its far side
z -580                   vvvv#####v
z -560                   xxvvvvvvv#      xx broken rope bridge across the end (450)
z -540                  g ==xx           g arroyo grass (beside, west)
z -520                   == s            s "Rope bridge down. No way across."
z -500                  ==
z -480                 == r              r the Cairn Field (390)
z -460               2==                 2 Rafe (340)
z -440              ===                  Hollow Arroyo 300-450: cliff walls both sides, half-width 46
z -420           ===
z -400          ==
z -380         g=                        g flats grass (across the lane at 240)
z -360        ==                         Tumbleweed Flats 150-300: boulder banks, half-width 65
z -340        =
z -320        =
z -300        ==
z -280         ==
z -260          ==
z -240          1=                       1 Ines (110), at the first bend
z -220          == g                     g wash grass (beside, east)
z -200         s=                        s teaching sign: "Dry grass: wild creatures hide here"
z -180          ==                ::     Pebble Wash 0-150: boulder banks, half-width 55
z -160           =          ::::::
z -140 ##########=#########xxx#          north cliff, the north arch at (20, -142)
   x   -80       20        120
```

### 2d. Route B: Mesa Road and the spur to Mesalith's Shelf

Scale: 15 studs per character across, 30 studs per line down. North is up.

```
z -560   ##
z -530 x
z -500                                 M   M            M the Redstack
z -470                                 M M M
z -350
z -320                      x:::    O                   O Mesalith's Shelf (arena r80, clearing r85)
z -290                   ::xx:     ==                   x rockfall across the winch track
z -260                ::::        ==                    spur: cliff walls both sides, half-width 30
z -230             ::::          ==
z -200       ::::::             ==
z -170 ::::::                  ==
z -140 x#                     =             ##          ## the north buttress (pinch at Tavish)
z -110  #        # #        s S ==4====r s==5=====G   > S Shelf Stall  4 Hesper  r Capstone Garden
z  -80  #        #r#     g=======g     ===g ## +++      5 Tavish  G Stair Gate  +++ low stone walls
z  -50  #       =========                   ##          r Echo Notch in its cleft (# #)
z  -20  #    3==,,,,,,,,,,,,,,,,,,,                     3 Perrin   ,,, the gorge floor, far below the rim
z   10  #   ===,,,,,,,,,,,,,,,,,,,,
z   40 :====  ,,,,,,,,,,,,,,,,,,,,,                     east arch, Route B leaves town at (150, 40)
z   70  # g   ######,,,,,,,,,,######                    ###### the gorge's far wall
z  100  #          ###########
   x   140       290       440       590       740
The rival stands on the rim at (370, -66), just past the Echo Notch; Isolde Karrow stands in the gate at (772, -100).
```

---

## 3. Coordinate tables

### 3a. The map sheet (`src/content/map_data/DustCanyon.luau`)

**Routes as waypoints.** Layout fits each line to its data length by trimming or stretching the last leg.

| Route | Waypoints (x, z) | Leg lengths | Leg sum | Fitted to |
| --- | --- | --- | --- | --- |
| `dust_canyon_route_a` | (20,-150) (10,-200) (20,-250) (-10,-300) (-10,-360) (20,-410) (60,-440) (90,-490) (120,-545) | 51.0, 51.0, 58.3, 60.0, 58.3, 50.0, 58.3, 62.6 | 449.6 | 450; end (120.2, -545.4) |
| `dust_canyon_route_b` | (150,40) (200,30) (240,0) (270,-40) (320,-60) (380,-60) (440,-75) (490,-80) (540,-110) (590,-110) (630,-90) (680,-100) (730,-100) (779,-100) | 51.0, 50.0, 50.0, 53.9, 60.0, 61.8, 50.2, 58.3, 50.0, 44.7, 51.0, 50.0, 49.0 | 680.0 | 680; end (779.0, -100), last leg due east |
| Spur (`dust_canyon_lair`) | (473.1,-78.3) (490,-150) (530,-210) (560,-280) (576,-316) | 73.7, 72.1, 76.2, 39.4 | 261.3 | 260; arena (575.5, -314.8) |

The spur's first point is the computed join (360 along Route B). Layout drops it as a zero-length leg and starts from the join itself.

**Corridor half-widths** (`corridor`), by stretch:

| Stretch | Half-width | Left edge | Right edge |
| --- | --- | --- | --- |
| `pebble_wash` | 55 | Boulders | Boulders |
| `tumbleweed_flats` | 65 | Boulders | Boulders |
| `hollow_arroyo` | 46 | Cliff | Cliff |
| `redstone_steps` | 50 | Cliff (the canyon wall it climbs) | Boulders (the lip over the gorge) |
| `sunbaked_rim` | 48 | Cliff (wind hollows) | Boulders (the lip; the drop beyond) |
| `spire_garden` | 65 | Boulders | Boulders |
| `stair_approach` | 50 | Cliff | Boulders |
| `dust_canyon_lair` (spur) | 30 | Cliff | Cliff |

**Buildings** (`buildings`). The door is the keeper's spot: the talk point and the building's place.

| Building id | Model | Middle | Faces | Door / keeper | Footprint (w × d, tall) |
| --- | --- | --- | --- | --- | --- |
| `kiln_trading_post` (Shop, `tamsin_rook`) | TradingPost (new) | 66, -6 | 270 | 50, -6 | 24 × 20, 28 |
| `seep_house` (Healer) | Healer (reused) | -64, 44 | 0 | -64, 28 | 18 × 19, 26 |
| `cradle_kiln` (Breeder) | BottleKiln (new) | 72, 72 | 315 | 60.7, 60.7 | 26 × 26, 40 |
| `notice_wall` (Quests) | NoticeBoard (reused) | -30, -50 | 150 | -24, -40 | 24 × 4, 10 |
| `sundial_waystation` (Teleport, `fenwick_dray`) | Waystation (reused) | -80, -46 | 135 | -68.7, -34.7 | 20 × 20, 40 |
| `dust_ring` (Circuit) | none (sand oval and rail) | 0, 96 | 0 | 0, 74 | 40 × 30, 0.4 |
| `windward_overlook` (Lookout) | WindTower (new) | 100, -96 | 225 | 88.7, -84.7 | 16 × 16, 44 |

The footprints go in the dressing sheet's `buildings` table. Width is across the facing; depth is along it.

**Set places** (`places`):

| Id | x, z | What and why |
| --- | --- | --- |
| `pebble_wash_grass` | 42, -212 | Beside the wash, east side (69 along, 29 off) |
| `tumbleweed_flats_grass` | 0, -377 | Across the lane on the flats (240 along); walk through it or round it |
| `hollow_arroyo_grass` | 87, -535 | Beside, west, near the end of the arroyo (425 along, 24 off) |
| `redstone_steps_grass` | 186, 62 | At the foot of the steps, south side (31 along, 29 off) |
| `sunbaked_rim_grass` | 408, -94 | In a wind hollow in the rim wall, north side (300 along, 26 off) |
| `spire_garden_grass` | 524, -68 | Among the spires, south side (400 along, 28 off) |
| `stair_approach_grass` | 665, -68 | South side, before the buttresses (560 along, 28 off) |
| `cairn_field` | 110, -482 | Rustle spot: a scatter of cairns east of the arroyo lane (390 along, 21 off) |
| `echo_notch` | 305, -84 | Rustle spot: in the mouth of a cleft in the rim wall (200 along, 28 off) |
| `capstone_garden` | 613, -123 | Rustle spot: capped spires north of the lane (500 along, 22 off) |
| `dc_ines` | 7, -250 | At the first bend of the wash (109 along, 11 off) |
| `dc_rafe` | 57, -455 | Where the arroyo narrows (340 along, 10 off) |
| `dc_perrin` | 233, -6 | On a ledge at the bend of the steps (99 along, 9 off) |
| `dc_hesper` | 545, -121 | On a spire's foot with her scope (440 along, 11 off) |
| `dc_tavish` | 699, -109 | The pinch point between the buttresses (600 along, 9 off) |

**Stands** (`stands`):

| Battle | Stands at | Faces | Its place | Gap |
| --- | --- | --- | --- | --- |
| `rival_canyon` | 370, -66 | 270 | `sunbaked_rim` (370.2, -60) | 6.0 |
| `champion_karrow` | 772, -100 | 270 | `dust_canyon_gate` (779.0, -100) | 7.0 |

**Facings** (`faces`). Each tamer looks back towards the way players arrive.

| Id | Faces |
| --- | --- |
| `dc_ines` | 160 |
| `dc_rafe` | 210 |
| `dc_perrin` | 225 |
| `dc_hesper` | 235 |
| `dc_tavish` | 270 |
| `rival_canyon` | 270 |
| `champion_karrow` | 270 |

**Spawn** (`spawn`): at (-128, 0), facing 90. Layout copies only the first biome's spawn into the world, so for Dust Canyon this is a record of the arrival point and facing. The tests and the Studio check use it, and no SpawnLocation is built here.

### 3b. Places Layout works out (for reference; not in the sheet)

| Id | x, z | How |
| --- | --- | --- |
| `dust_canyon_hub` | 0, 0 | The origin |
| `dust_canyon_route_a` (entry) | 14.1, -179.4 | 30 along Route A; 117 from the nearest door (the Overlook) |
| `pebble_wash` | 14.7, -223.5 | 75 along |
| `tumbleweed_flats` | -7.6, -364 | 225 along |
| `hollow_arroyo` | 83.9, -479.8 | 375 along |
| `dust_canyon_route_b` (entry) | 179.4, 34.1 | 30 along Route B |
| `redstone_steps` | 227.2, 9.6 | 85 along |
| `sunbaked_rim` | 370.2, -60 | 255 along (the rival's place) |
| `spire_garden` | 535.5, -107.3 | 430 along (the `mesa_sighting` place) |
| `stair_approach` | 699, -100 | 600 along |
| Spur join | 473.1, -78.3 | 360 along Route B |
| `dust_canyon_lair_stall` | 482.3, -117.3 | 40 up the spur |
| `dust_canyon_lair` | 575.5, -314.8 | End of the spur |
| `dust_canyon_gate` | 779.0, -100 | End of Route B |
| `dust_canyon_sealed_path` | 839.0, -100 | 60 past the gate, due east |

### 3c. The story order still works

| Beat | Trigger | Where |
| --- | --- | --- |
| `canyon_arrival` | Enter `dust_canyon_hub` | (0, 0): reached 80 studs (5 s) after the west arch |
| `canyon_trader` | Talk to `tamsin_rook` | Trading Post door (50, -6), straight ahead of the arrival |
| `canyon_catch` | Tame anything | Route A is the bright way out north; Route B also works |
| `first_canyon_tamer` | Beat `dc_ines` | (7, -250) |
| `mentors_letter` | Talk to `fenwick_dray` | Waystation door (-68.7, -34.7) |
| `canyon_rival` | Beat `rival_canyon` | Stands at (370, -66) on the rim |
| `mesa_sighting` | Sight `spire_garden` | (535.5, -107.3): the Redstack fills the sky to the north-north-east |
| `canyon_gate_challenge` | Enter `dust_canyon_gate` | (779, -100) |
| `canyon_badge` | Beat `champion_karrow` | Isolde stands at (772, -100), inside the gate arch |
| `canyon_road_on` | Enter `dust_canyon_sealed_path` | (839, -100); the bar is at (792, -100), 47 short of it, where the trigger starts |

Quest givers stand at their buildings' doors: Tamsin at the Trading Post, Calla Seep at the Seep House, Fenwick Dray at the Waystation, and Ottoline Marsh at the Notice Wall.

### 3d. The dressing sheet (`src/content/map_data/DustCanyonDressing.luau`)

Fields marked **new** are proposed in section 4.

**Colours** (RGB):

| Field | Colour | What |
| --- | --- | --- |
| `fieldGround` (**new**) | 214, 172, 124 | The open ground outside town and corridors |
| `townGround` | 232, 196, 150 | Kilnrest's baked-clay floor |
| `laneColour` | 232, 206, 160 | Packed earth, every route lane |
| `plaza.colour` (**new**) | 200, 112, 82 | Terracotta flagstones |
| `plaza.rimColour` (**new**) | 150, 84, 60 | Darker kerb |
| Under the long grass (`grassLooks`, **new**) | 164, 140, 84 | Every stretch, with the DryTuft model |

**Ground of each stretch** (`ground`, one entry per area):

| Area | Colour |
| --- | --- |
| `pebble_wash` | 214, 204, 182 (pale pebble) |
| `tumbleweed_flats` | 226, 196, 140 (cracked ochre) |
| `hollow_arroyo` | 196, 140, 100 (banded red-brown) |
| `redstone_steps` | 190, 110, 84 (red stone) |
| `sunbaked_rim` | 214, 150, 104 |
| `spire_garden` | 206, 160, 120 |
| `stair_approach` | 200, 184, 160 (pale stone) |

**Lane surfaces** (`laneSurfaces`): Route B 0 to 170 in red flagstone (184, 96, 72), the steps. Route B 520 to 680 in stone (196, 186, 170), the stair road. `laneWidth` is 14, as in Greenwood.

**Town lanes** (`lanes`). Keep the shut winch track last, as Greenwood keeps its shortcut last.

| Lane | Points | Width | Colour |
| --- | --- | --- | --- |
| Kiln Street | (-150,0) (-28,0) | 16 | 206, 128, 96 |
| Wash Lane | (10,-27) (20,-150) | 10 | 226, 200, 160 |
| East Road | (24,16) (80,32) (150,40) | 14 | 206, 128, 96 |
| Trading Post path | (28,-4) (50,-6) | 8 | 226, 200, 160 |
| Seep House path | (-64,8) (-64,28) | 8 | 226, 200, 160 |
| Waystation path | (-50,-8) (-68.7,-34.7) | 8 | 226, 200, 160 |
| Notice Wall path | (-18,-22) (-24,-40) | 8 | 226, 200, 160 |
| Kiln path | (52,24) (60.7,60.7) | 8 | 226, 200, 160 |
| Ring path | (0,28) (0,74) | 8 | 226, 200, 160 |
| Overlook path | (16.7,-110) (88.7,-84.7) | 8 | 226, 200, 160 |
| Cave Row lane | (-110,-8) (-110,-98) | 8 | 226, 200, 160 |
| Cave Row | (-136,-98) (-50,-98) | 8 | 226, 200, 160 |
| Westcut road | (-180,0) (-150,0) | 14 | 186, 180, 168 (stone, joining Greenwood's sealed road, which already reaches -180) |
| Winch track (shut, last) | (497,-318) (420,-280) (330,-222) (180,-168) (130,-170) (130,-150) (112,-118) | 8 | 150, 120, 96 (rusty, half buried) |

**Plaza and centre:** `plaza = { at (0,0), size 56, rim 60, colour, rimColour }` (Sundial Square). `well = (0, 0)`: the Well model at the heart of the square. In a dry town the well is the reason the town is there.

**Water:** `water = {}`. `pools = { { at (-92,30), radius 6, colour 110,182,214 } }`: the Seep, a spring pool beside the Seep House. `pond`, `waterfall` and `footbridge` are left out (made optional, section 4).

**Flats** (`flats`, **new**; axis-aligned rectangles, drawn in order):

| From | To | Colour | Water | What |
| --- | --- | --- | --- | --- |
| (250, -14) | (560, 80) | 152, 96, 74 | no | The gorge floor in shadow, beyond the rim's lip |
| (96, -604) | (190, -552) | 110, 72, 58 | no | The dry fall beyond Route A's end |

**Walls** (`walls`, **new**):

| Wall | Points | Style | Tall |
| --- | --- | --- | --- |
| North cliff, west | (-150,-20) (-150,-150) (6,-150) | Cliff | 30 |
| North cliff, middle | (34,-150) (124,-150) | Cliff | 30 |
| North cliff, east | (136,-150) (150,-150) (150,26) | Cliff | 30 |
| South cliff | (150,54) (150,150) (-150,150) (-150,20) | Cliff | 30 |
| Westcut, north | (-236,-20) (-150,-20) | Cliff | 34 |
| Westcut, south | (-236,20) (-150,20) | Cliff | 34 |
| Gorge, far wall | (250,80) (420,92) (560,74) | Cliff | 34 |
| Dry fall, far side | (96,-604) (190,-568) | Cliff | 26 |
| Echo Notch, west lip | (294.3,-84.2) (288.4,-99.1) | Cliff | 24 |
| Echo Notch, east lip | (325.2,-92) (325.2,-110) | Cliff | 24 |
| Buttress, north | (690,-150) (690,-122) (710,-122) (710,-150) | Boulders | 10 |
| Buttress, south | (690,-50) (690,-78) (710,-78) (710,-50) | Boulders | 10 |

The two notch lips stand out from the rim's north cliff (at 48 off the lane) to 32 off it, 30 studs apart, making the cleft. The rustle spot sits in its mouth, 10.7 studs from the nearer lip. The buttresses narrow the stair road to 44 studs at Tavish, so "nobody passes me" is true in the world. They are 13 studs from him.

`hedges = {}`. The town's edge is the cliff walls above.

**Fences** (`fences`):

| Fence | Points | Style | Across |
| --- | --- | --- | --- |
| Shut winch gate in the north cliff | (124,-150) (136,-150) | Gate | yes |
| Broken rope bridge across Route A's end | (102.6,-555) (137.8,-535.8) | Rope (**new style**) | yes |
| Rockfall across the winch track | (444,-283) (456,-306) | Rockfall (**new style**) | yes |
| Low stone wall north of the stair road | (739,-90) (768,-90) | Stone | no |
| Low stone wall south of the stair road | (739,-110) (768,-110) | Stone | no |

**Arches** (`arches`; **new** optional `model` = CanyonArch):

| At | Faces | Outside | Inside |
| --- | --- | --- | --- |
| -142, 0 | 270 | Kilnrest | Westcut · to Greenwood |
| 20, -142 | 5 | Kilnrest | Route A · Dry Wash Trail |
| 142, 40 | 84 | Kilnrest | Mesa Road · Stair Gate |

**Signposts** (`signs`; each arrow board points along its facing):

| At | Faces | Lines |
| --- | --- | --- |
| -128, -14 | 90 | "Sundial Square · Rook's Trading Post →" |
| -6, -36 | 0 | "↑ Route A · Dry Wash Trail", "↑ Windward Overlook" |
| 40, 8 | 84 | "Mesa Road · Stair Gate →", "↓ Cradle Kiln · Dust Ring" |
| 118, -140 | 0 | "Mesa winch track. Shut." |
| 0, -192 | 64 | "Dry grass:", "wild creatures hide here" |
| 458, -98 | 13 | "Mesalith's Shelf · Shelf Stall" |
| 650, -122 | 90 | "The Stair Gate", "badge challenge" |
| 134, -526 | 29 | "Rope bridge down.", "No way across." |
| -200, -14 | 90 | "Kilnrest →" (in the Westcut, seen coming from Greenwood) |

**Lamps** (`lamps`, the Lamp model as lantern posts): Kiln Street (-120,-11) (-90,11) (-40,-11); square (-28,-16) (22,-24) (-22,22) (-12,32); East Road (60,16) (112,47); Wash Lane (4,-60) (25,-100); arches (-142,-11) (-142,11) (9,-142) (31,-142) (142,29) (142,51); the stair road (728,-114) (760,-86). That is 19 in all.

**Flower beds** (`beds`, read as clay planters): Trading Post door (44,-16) (44,4); Seep House door (-72,26) (-56,26); square (-11.6,-32) (-11.6,32) (11.6,32); Cradle Kiln door (70,52) (55,66.4).

**Trees** (`trees`), in threes:
- ScrubBush at the west cliff foot: (-140,-60) (-136,-50) (-142,-42).
- North cliff foot: (40,-141) (44,-133) (36,-134).
- Behind the Overlook: (140,-110) (134,-100) (142,-92).
- South-west: (-140,86) (-134,94) (-142,100).
- South: (30,140) (38,133) (46,140).
- East: (140,64) (134,72) (142,80).
- Reeds round the Seep: (-99,35) (-85,36) (-92,39).

**Rows** (`rows`, step 16): ScrubBush from (-140,141) to (-76,141), and from (60,141) to (140,141).

**Houses** (`houses`, keeperless):

| At | Faces | Model | Width × depth, tall |
| --- | --- | --- | --- |
| -126, -114 | 180 | AdobeHouse | 20 × 18, 18 |
| -96, -118 | 180 | KilnCottage | 18 × 18, 22 |
| -64, -116 | 180 | AdobeHouse | 20 × 18, 18 |
| -120, 62 | 90 | AdobeHouse | 20 × 18, 18 |
| -110, 108 | 45 | KilnCottage | 18 × 18, 22 |
| -56, 120 | 0 | AdobeHouse | 20 × 18, 18 |
| 120, 98 | 270 | KilnCottage | 18 × 18, 22 |
| 120, -40 | 270 | AdobeHouse | 20 × 18, 18 |

**Props** (`props`):

| Model | At | Faces | Tall | Solid |
| --- | --- | --- | --- | --- |
| Barrels | 38, -22 | 0 | 6.5 | yes |
| Barrels | 96, 14 | 200 | 6 | yes |
| WashingLine | -80, -108 | 0 | 8 | no |
| WashingLine | 100, 116 | 90 | 8 | no |
| Boulders | -136, 128 | 30 | 8 | yes |
| Boulders | 136, 128 | 300 | 9 | yes |
| Boulders | -30, -132 | 160 | 7 | yes |
| RockSpire | 60, -128 | 0 | 26 | yes |
| Bench | -36, 10 | 0 | 3.8 | no |
| Bench | 36, -14 | 270 | 3.8 | no |

**People** (`people`):

| Name | At | Faces | Model |
| --- | --- | --- | --- |
| Potter | -44, 20 | 45 | Tamer |
| Kiln hand | 90, 64 | 315 | Tamer |
| Child | -24, -70 | 180 | GirlTamer |
| Grandmother | -90, -106 | 180 | Grandmother |

**The rest:**

| Field | Value |
| --- | --- |
| `stones`, `footpaths` | Empty |
| `coop` | (100, 50): egg nests warming in the lee of the kiln (the builder's coop and nests, unchanged) |
| `patch` | From (-108, 12) to (-96, 22): Calla's spring-watered garden rows by the Seep |
| `ring` | { width 40, depth 30, gap 12 } for the Dust Ring |
| `clearings` | { at (575.5,-314.8), radius 85, ring true }, the shelf round the arena; { at (408,-100), radius 26, ring false }, the wind hollow round the rim grass |
| `caps` | `dust_canyon_route_a` = 21 (the rope bridge fills the middle); `dust_canyon_route_b` = 20 (the gate fills it) |
| `corridorTrees` | `pebble_wash`, `tumbleweed_flats`, `hollow_arroyo`, `redstone_steps`, `sunbaked_rim` and `stair_approach`: ScrubBush, scale 1 (1.2 on the flats). `spire_garden`: RockSpire 1. `dust_canyon_lair`: RockSpire 0.8. Every stretch is listed so no green Tree or Pine appears. |
| `gatehouse` | { at (779, -100), faces 270, model "StairGate" (**new**), banner "Cairn Badge" (**new**) } |
| `bar` | { at (792, -100), width 20 }: 13 past the gate, 47 short of the sealed path |
| `landmark` (**new**) | { at (650, -480), model "RedMesa", tall 190, faces 234 }: its face turned towards Kilnrest |
| `stall` | { side = 1 }: the counter stands west of the spur, away from Hesper |
| `brambles` | Empty (the rockfall fence does that job) |
| `knoll`, `picnic`, `pocket`, `ancientTree`, `pond`, `waterfall`, `footbridge` | Left out (optional) |

### 3e. Why each spot is where it is

- **Trading Post on the arrival axis.** The story's second beat is talking to Tamsin, so her door faces the arrival down the whole length of Kiln Street, as the mentor's door faces Greenwood's spawn.
- **Healer and Waystation first.** They are the first two doors in from the west arch, and the healer's forecourt is 6 seconds from the arch. Waking after a loss lands at about (-58.5, 25.6), 6 studs from the door towards the square (`WorldService.sendTo`). Greenwood keeps its healer at nearly the same spot (-64, 46), so the habit carries over.
- **Ines at the first bend** of the wash, facing back towards town. She is seen from the arch, as Pip is from Greenwood's footbridge.
- **Tavish at a real pinch** between two buttresses, as his line says.
- **The Echo Notch in a real cleft** of the rim wall, and the rim grass in a wind hollow behind a bulge, as the area notes say.
- **The spur forks north at 360, just inside the Spire Garden**, and the `spire_garden` sight point (430) is past it. The player has walked under the Redstack before the beat fires.

### 3f. Rules these coordinates were checked against

From `tests/layout.test.luau`, run on these numbers with a generalised copy of the test (all pass):
- Every sheet id is real, and every stretch and the spur have a corridor width.
- Each drawn line is within 5 studs of its data length (route A 449.6 of 450, route B 680.0 of 680, spur 261.3 of 260). Each fitted line is exact.
- The gate is the end of Route B, and the sealed road runs on 60 due east. The spur starts on Route B at 360.
- Every Chapter 2 trigger target has a place. Every local tamer has a place and a facing. Both story battles have a stand.
- No two prompts are within 32 studs: keeper doors, tamers, rustle spots, the stall and story stands. The closest pairs are the Notice Wall and Waystation (45.0), Rafe and the Cairn Field (59.5), the Cradle Kiln and the Dust Ring (62.1), and Hesper and the stall (62.8).
- Each story battler stands within 8 of its place (6.0 and 7.0).
- Each grass patch's along-distance lies inside its stretch. No patch overlaps another patch, the town square plus 20, or a tamer. I also checked that no patch comes within 26 of any prompt.
- Each tamer is within 12 of the lane (the furthest is 11.1) and within 40 of its `at` (the furthest is 11.2). Each rustle spot is within 30 of the lane (the furthest is 27.9).
- Every route place, grass edge included, is inside its corridor. The tightest are the arroyo grass (44.2 of 46), the steps grass (48.6 of 50), the stair grass (48.4 of 50) and the rim grass (46.2 of 48).
- Buildings stand inside the town (within 136 of the centre) and at least 28 apart (the closest are the Notice Wall and Waystation at 50.2).
- The Route A entry is more than 48 from every door (117).
- Every Greenwood place is more than 100 from every Dust Canyon place (the closest is 174.8, from Greenwood's sealed path to the Waystation door). Every Dust Canyon place is more than 100 from every Tide Flats place (178.5).
- Dressing: no fence, wall or gatehouse tower comes within 6 of a prompt. No wall crosses a lane except the three fences marked "across". No house or solid prop stands on a town lane, and no lamp stands in long grass.
- Extra checks: lamps, signs and beds stay off every lane and clear of prompts; houses and solid props do not overlap each other or the hub buildings.

---

## 4. What bounds the corridors, and the sheet fields

### 4a. What replaces hedges

| Edge style | Where in Dust Canyon | Look | Blocks |
| --- | --- | --- | --- |
| **Cliff** | Town edge, the Westcut, the arroyo, the north side of the steps, rim and stair road, the spur and the shelf | CliffWall sections end to end, each about 40 long, inner face on the edge line | Yes: a core block 8 thick, as tall as the cliff (30 by default) |
| **Boulders** | The wash, the flats, the spire garden, the lip of the steps, the rim and the stair road | Boulders model every 9 studs, scale 0.8 to 1.3 from the seeded pick, random turn | Yes: a core block 3 thick and 6 tall in rock colour (176, 120, 84) under them, so there are no gaps |

Outside a Boulders edge, the builder plants `corridorTrees` (ScrubBush, or RockSpire in the Spire Garden) as it plants trees outside hedges today. Nothing is planted outside a Cliff edge: the cliff is the edge.

What replaces the Greenwood-only dressing:

| Greenwood | Dust Canyon |
| --- | --- |
| Pond and jetty | The Seep, a spring pool (`pools`) with reeds and the garden `patch` |
| Brook and river | None; the gorge floor (`flats`) beyond the rim, with its far wall |
| Footbridge | None; the broken rope bridge (fence style Rope, across) at Route A's end |
| Orchard and apple trees | ScrubBush clumps and rows; RockSpire and Boulders props |
| Hedge loop round town | Cliff walls (`walls`) |
| Ancient tree | The Redstack (`landmark`) |
| Brambles on the shortcut | A rockfall (fence style Rockfall) on the winch track |
| Mown footpath round the meadow grass | None (the flats are wide open) |

### 4b. Sheet fields

`DressingSheet` is Greenwood-shaped. Here is the shortest change that fits all three biomes. Greenwood's sheet needs no edits: every new field is optional, and Greenwood leaves them out.

**Reused as they are:** `ground`, `townGround`, `laneColour`, `laneSurfaces`, `laneWidth`, `lanes`, `footpaths`, `stones`, `plaza` (with two new optional colours), `water`, `pools`, `arches` (with an optional model), `signs`, `lamps`, `beds`, `trees`, `rows`, `fences` (with two new styles), `hedges` (may be empty), `buildings`, `houses`, `people`, `props`, `clearings`, `caps`, `corridorTrees`, `gatehouse` (with an optional model and banner), `bar`, `stall`, `ring`, `brambles` (may be empty).

**Made optional** (nil means not built): `pond`, `waterfall`, `footbridge`, `knoll`, `picnic`, `pocket`, `ancientTree`, `coop`, `patch`, `well`. Scenery and Landmarks each guard them with an `if`. The waterfall is drawn only when `waterfall` is set, not whenever `pools` has an entry, as today.

**New** (add to `src/shared/WorldTypes.luau`):

```luau
-- How a corridor edge or a wall is built (section 4c).
export type EdgeStyle = "Hedge" | "Cliff" | "Boulders" | "Rocks" | "Dunes" | "Rope" | "SeaWall"
-- The two edges of a stretch, as seen walking away from town.
export type DressEdge = { left: EdgeStyle, right: EdgeStyle }
-- A wall, cliff, dune ridge or sea wall that is not a corridor edge: the town's edge, a gorge wall.
export type DressWall = { points: { SheetPoint }, style: EdgeStyle, tall: number? }
-- A flat axis-aligned rectangle of colour laid on the ground: the sea, a mudflat, a gorge floor.
export type DressFlat = { from: SheetPoint, to: SheetPoint, colour: Colour, water: boolean }
-- The far landmark the player walks toward.
export type DressLandmark = { at: SheetPoint, model: string, tall: number, faces: number }
-- What a stretch's long grass is made of.
export type GrassLook = { model: string, under: Colour }

-- Added to DressingSheet:
	edges: { [string]: DressEdge }?, -- by area id and lair id; a stretch left out keeps hedges
	walls: { DressWall }?,
	flats: { DressFlat }?, -- drawn in order, each a hair above the last
	landmark: DressLandmark?,
	grassLooks: { [string]: GrassLook }?, -- by area id; left out: GrassTuft on (78,128,58)
	fieldGround: Colour?, -- the open ground outside town and corridors; left out: Greenwood's green

-- Small additions to existing types:
-- FenceStyle gains "Rope" | "Rockfall".
-- DressLane gains `deck: boolean?`, and each laneSurfaces entry gains `deck: boolean?` (Tide Flats uses them).
-- DressArch gains `model: string?` (left out: VillageArch).
-- gatehouse gains `model: string?` (left out: Gatehouse) and `banner: string?` (left out: "Acorn Badge").
-- plaza gains `colour: Colour?` and `rimColour: Colour?` (left out: today's colours).
```

That is six new fields, plus five optional additions to existing types.

### 4c. What the builder does with each

- **`edges`** (`Corridors.edges`). For each corridor side (`side = -1` is left, `side = 1` is right), it looks up the style for the stretch at that point. The spur uses `edges[lair.id]`. The run is drawn in that style instead of `Fences.hedge`, and joins and gaps work exactly as today.
  - The hedge across a route's far end (`caps`) uses the style of the last stretch's left side.
  - A ring clearing (the lair) uses `edges[lair.id].left`, and plants `corridorTrees[lair.id]` round it instead of Pine and Tree.
  - The spur plants `corridorTrees[lair.id]` too.
- **`walls`** (Scenery, beside the town hedge). Each run is drawn in its style, centred on its line, with segments of 40 or less, so the battle scene can hide them near the pads.
- **The seven styles:**

| Style | Pieces | Collidable core |
| --- | --- | --- |
| Hedge | Today's hedge | Today's |
| Cliff | CliffWall models scaled to `tall` (default 30). Fallback: three stacked bands 10 tall each in (196,98,70), (222,150,100) and (236,200,150), with rounded lumps along the top | 8 thick, `tall` high |
| Boulders | Boulders model every 9 studs, scale 0.8 to 1.3 | 3 thick, 6 tall, colour (176,120,84) |
| Rocks | SeaRocks model every 9 studs (plan 10) | 3 thick, 5 tall, colour (84,84,92) |
| Dunes | Sand lumps 14 long, 8 tall and 12 deep every 10 studs, colour (232,214,168), with MarramTuft along the crest every 4 studs (plan 10) | 4 thick, 6 tall |
| Rope | Driftwood posts 0.9 × 4.5 × 0.9 (120,96,72) every 8 studs. Two ropes 0.3 thick (200,180,140) at 1.6 and 3.2, each sagging 0.4 in the middle. A cork float (0.8 lump, 226,96,64) on every second post (plan 10) | The posts and ropes, as a rustic fence |
| SeaWall | A stone wall 4 thick and 6 tall (170,165,150) with a coping 5 wide and 0.8 thick (196,190,176). SeaRocks every 12 studs at its outer foot (plan 10) | The wall |

  Every style stops 2 studs short of a stream or pool, as hedges do. None stops short of a flat.
- **Fence style Rope** draws as the Rope edge. When `across` is set, it is a broken bridge: beyond the line (away from the route) the builder hangs 6 planks, 4 × 0.4 × 1.4 (150,110,80), from two ropes, tilted down 25° and 2 apart, like the stile on Greenwood's old fence.
- **Fence style Rockfall** is a heap of Boulders models three abreast along the line, scale 1.2, on a collidable core 5 tall.
- **`flats`** (Scenery). Each rectangle is a slab 0.1 thick with its top at 0.06 + 0.002 × its index. It is not collidable and cannot be queried. Water flats are SmoothPlastic with Reflectance 0.1. Water flats count as wet for tree planting, so no tree is planted on them, but fences and edges do not stop short of them. A rope rail along a quay must reach the water. For a sheet with flats, `Corridors.ground` lifts its layers by 0.04 (top 0.07 + layer × 0.012) so corridor ground paints over the flats, while lanes (0.42) and streets stay on top.
- **`landmark`** (Landmarks). The painted model is stood at `at` with height `tall`, turned to `faces`, on an invisible collidable core of 0.6 × its footprint. Fallbacks by model name:
  - **RedMesa:** three stacked boxes with lumps on the edges. The bottom is 150 × 70 × 130 in (196,98,70), the middle 130 × 70 × 112 in (222,150,100), the top 110 × 50 × 96 in (236,200,150), and a cap 90 × 6 × 80 in (200,120,90).
  - **OldLighthouse** (plan 10): a cylinder tower 110 tall tapering from 18 to 14 across, white (244,240,232), with three red bands 8 tall (206,72,64). A black lantern room 16 across and 12 tall, a light part (255,226,120) with a PointLight of range 60, all on a rock lump 50 × 20 × 50 (90,90,96).
- **`grassLooks`** (`Grass.patch` gains a look argument). It stands `look.model` in place of GrassTuft and lays the disc in `look.under`. Models taller than 4 studs (Reeds, Kelp) go on a 4.2 grid instead of 3.6, so a patch stays near 70 pieces. The wedge fallback colours are `under + (26,50,16)` and `under + (6,30,8)`, clamped to 255.
- **`fieldGround`** (TestMap). This is the colour of the biome's Ground slab.
- **Deck lanes** (`Lanes`, and town lanes in Scenery). The top is at 1.0 instead of 0.42. Planks are 1.2 wide across the lane with 0.3 gaps, in the lane colour alternating ±10. Posts 0.8 × 2 × 0.8 stand under both edges every 8 studs, down to -1. There is a 5-stud ramp at each end. Decks are collidable and registered with `Markers.addGround`, so people stand on them.
- **Arch model, gatehouse model and banner, plaza colours.** Use them where today's code names VillageArch, Gatehouse, "Acorn Badge" and the fixed plaza colours.

### 4d. Builder fixes that need no new data

1. **TestMap: one ground slab per biome, clipped.** Today each biome's Ground slab spans its places plus 220, so Greenwood's slab reaches x -20 in this plan's coordinates. With a different `fieldGround` the two would z-fight across Kilnrest. Clip each slab at a line 30 studs past the earlier biome's gate, across its sealed road. The east edge of a biome's slab is at its own gate x + 30, and the next biome's slab starts there. For Greenwood and Dust Canyon that line is world x 714.4 (here x = -270). For Dust Canyon and Tide Flats it is world x 1793.4 (here x = 809). Gates face east, so a vertical line is enough.
2. **The Circuit building.** `Markers.buildings` tests `building.id == "ring"` and `Scenery` reads `map.buildings.ring`. Both should look for the hub building whose role is "Circuit", so the Dust Ring and the Breaker Ring are built as rings.
3. **Stall name.** `TestMap` labels every stall "Hollow Stall". Use the text before the first comma of `biome.lair.supplyStall` ("Shelf Stall").
4. **`TestMap.DRESSINGS`.** Add `dust_canyon = DustCanyonDressing`.

---

## 5. Models

New models are made with Roblox Studio's model generator in the existing style. Each stands on a flat base with its front facing -z. Sizes are approximate studs (x / y / z); `Props.stand` scales to the `tall` given in the sheet.

| # | Name | Prompt | Size | Used for |
| --- | --- | --- | --- | --- |
| 1 | CanyonArch | A rustic desert town gateway of two rounded terracotta adobe pillars joined by a thick timber beam, with a blank cream sign board hanging from it, clay wind chimes dangling and a round clay pot of flowers at each foot, hand-painted clay toy style, soft rounded shapes | 22 / 18 / 6 | The three town arches |
| 2 | AdobeHouse | A small flat-roofed adobe house with soft rounded walls in warm sand colour, a turquoise wooden door, two deep little windows with blue shutters, wooden roof beams poking out under the roof edge and a clay pot on the roof, hand-painted clay toy style, soft rounded shapes | 20 / 18 / 18 | Houses (style 1) |
| 3 | KilnCottage | A cosy round domed cottage built like a beehive pottery kiln from red-brown clay, a short chimney with a curl of smoke, an arched wooden door with an iron ring and a striped woven rug hanging beside it, hand-painted clay toy style, soft rounded shapes | 18 / 22 / 18 | Houses (style 2) |
| 4 | TradingPost | A two-storey frontier trading post of pale adobe with a wide red-and-cream striped canvas awning, sacks, rope coils and crates stacked by the door and a hanging sign shaped like a balance scale, hand-painted clay toy style, soft rounded shapes | 24 / 28 / 20 | Rook's Trading Post (the hero building) |
| 5 | BottleKiln | A big round bottle-shaped pottery kiln of orange brick with a tall tapering chimney, a warm glowing arched opening at the front and a ledge round its base lined with egg-shaped clay pots, hand-painted clay toy style, soft rounded shapes | 26 / 40 / 26 | The Cradle Kiln (breeder); its chimney is the "kiln chimney in the distance" |
| 6 | WindTower | A tall wooden lookout tower on four splayed legs with a ladder, a small railed platform under a pointed tin roof, a four-sailed cloth wind vane and a brass telescope on the rail, hand-painted clay toy style, soft rounded shapes | 16 / 44 / 16 | The Windward Overlook |
| 7 | StairGate | A grand but friendly sandstone gateway at the top of wide stone steps: two squat round towers in banded red and cream stone with flat crenellated tops, a rounded arch between them with open wooden doors, and a brass-and-ochre banner showing a stacked-stone cairn, hand-painted clay toy style, soft rounded shapes | 44 / 34 / 16 | The gate (`gatehouse.model`) |
| 8 | RedMesa | A towering flat-topped red rock mesa with steep sides, stepped ledges and broad horizontal bands of rust, cream and deep red, a pale cap of rock on top and a few dark green shrubs on the ledges, hand-painted clay toy style, soft rounded shapes, a bold silhouette made to be seen from far away | 160 / 190 / 140 | The Redstack (`landmark`) |
| 9 | RockSpire | A tall slender desert rock spire with horizontal stripes of rust, cream and red, wind-worn and bulging, with a flat cap of darker rock balanced on top, hand-painted clay toy style, soft rounded shapes | 10 / 28 / 10 | Spire Garden edge planting, the spur, a prop in town, the Capstone Garden |
| 10 | ScrubBush | A low round desert scrub bush of dusty sage-green leaves with a few tiny yellow flowers and dry twigs at its base, hand-painted clay toy style, soft rounded shapes | 6 / 4 / 6 | Tree clumps and rows; planting outside Boulders edges |
| 11 | DryTuft | A clump of tall dry bunch grass, a dozen thick rounded blades in straw gold and pale olive, bent and leaning out, with a few seed heads, hand-painted clay toy style, soft rounded shapes | 4 / 2.5 / 4 | Every long-grass patch (`grassLooks`) |
| 12 | CliffWall | A straight section of canyon cliff wall of layered sandstone in horizontal bands of rust red, orange and cream, with rounded bulging ledges and a few cracks and a flat back, made to be placed end to end, hand-painted clay toy style, soft rounded shapes | 40 / 30 / 12 | Cliff edges and walls |
| 13 | Boulders | A cluster of three rounded desert boulders of warm ochre and red sandstone, smooth and wind-worn, one large and two small huddled together, hand-painted clay toy style, soft rounded shapes | 12 / 7 / 9 | Boulders edges, the rockfall, props |

Reused: Healer (the Seep House), Waystation (the Sundial Waystation), NoticeBoard (the Notice Wall, stood 10 tall), Well, Lamp, Signpost, Bench, Barrels, WashingLine, Stall (the Shelf Stall), Reeds (round the Seep), and the people models (Tamer, GirlTamer, Grandmother).

---

## 6. Walk times (16 studs a second, along the streets)

| Walk | Studs | Seconds |
| --- | --- | --- |
| West arch to entering the hub (48 from the centre) | 80 | 5.0 |
| West arch to the Seep House door | 92 | 5.8 |
| West arch to the Waystation door | 119 | 7.4 |
| West arch to the Notice Wall | 143 | 8.9 |
| West arch to the Trading Post door | 178 | 11.1 |
| West arch to the Dust Ring | 186 | 11.6 |
| West arch to the Cradle Kiln | 221 | 13.8 |
| West arch to the Overlook | 306 | 19.1 (optional lookout, tucked behind) |
| Seep House to the north arch (Route A) | 234 | 14.6 |
| Seep House to the east arch (Route B) | 247 | 15.4 |
| Square to Ines | 267 | 16.7 |
| Whole of Route A | 450 | 28.1 |
| Whole of Route B | 680 | 42.5 |
| Each stretch | 150 to 180 | 9.4 to 11.3 |
| Square to the gate (158 in town, then 680) | 838 | 52.4 |
| Square to the lair (158, then 360, then 260) | 778 | 48.6 |

Kilnrest's built area is about 270 by 255 inside its 300-stud square, against Thistledown's 300. All seven doors except the optional Overlook are within 14 seconds of the arch.

---

## 7. Sightlines

**From the arrival point (-128, 0), facing east (90).** Bearings are relative to the facing; heights are the angle of the top above the horizon.

| What | Bearing | Distance | Top |
| --- | --- | --- | --- |
| Rook's Trading Post, door towards you (the story's next step) | -1.8° | 194 | 6.8° |
| The east arch, Route B's way out | +8.4° | 273 | |
| The Cradle Kiln's chimney | +19.8° | 213 | 9.4° |
| The Windward Overlook | -22.8° | 247 | 9.0° |
| **The Redstack** | **-31.7°** | **914** | **11.4°** |
| The north arch, Route A's way out | -43.8° | 205 | |

A phone in landscape shows about ±51° (Roblox's 70° vertical field of view at 16:9), so everything in the table is on screen. Along the mesa's bearing the north cliff's top (30 tall, 283 away) is 5° up. The Redstack shows from 5° to 11.4°: its top 105 studs, the pale cap and two red bands, ride above the canyon rim, framed between the Overlook on its right and the cliff. From the square, facing east, it is 36° left and 12.9° up. From the `spire_garden` sight point it is 17° east of north, 390 away and 25° up: it fills the view.

**Hiding the neighbours:**
- **West (Greenwood).** The Westcut walls (34 tall, 40 apart) and the town's west cliffs close the view. Looking back through the slot, the player sees Greenwood's gatehouse 300 studs away, on purpose: it is the way home.
- **East (Tide Flats).** The Stair Gate stands on its buttressed rise with the north cliff behind it. Past the gate the sealed road runs on into haze, and Saltwick is 300 studs beyond.
- **North (Route A's end).** The dry fall's far cliff (26 tall) closes it.
- **South.** The south cliff (30) hides the empty field.
- **The gorge** is shut on its far side by its own wall (34).

---

## 8. Build order and Studio checklist

### Build order (`lune run check` must pass after each step)

1. **Types.** Add the section 4b types to `src/shared/WorldTypes.luau`, all optional, and make the ten listed fields optional. Greenwood's dressing still type-checks unchanged.
2. **Map sheet.** Add `src/content/map_data/DustCanyon.luau` from section 3a. In `src/content/biome_data/DustCanyon.luau`, add `map = require("../map_data/DustCanyon")`. Nothing else in that file changes.
3. **Tests.** Generalise `tests/layout.test.luau` to every biome that has a sheet:
   - Loop the per-biome sections over `{ greenwood = Chapter1, dust_canyon = Chapter2, tide_flats = Chapter3 }`, building each map from `Layout.world`.
   - Check "the gate ends route B and the sealed road runs on 60 due east" for each biome.
   - Keep "arrive in the square facing north" for Greenwood only. For a later biome, check that the spawn is within 30 of the town's west edge (x from -150 to -120) and faces within 45° of the hub.
   - Check each biome's models: for example, `map.models.kiln_trading_post == "TradingPost"`.
   - Replace "biomes after Greenwood keep the generated layout" with: every open biome has a sheet, and every pair of neighbouring biomes is more than 100 apart.
   - Add: in a sheeted biome other than Greenwood, every stretch and the spur has an `edges` entry and a `corridorTrees` entry; every stretch has a `grassLooks` entry; a `landmark` is set; and no prompt or grass centre lies inside a water flat.
   - `tests/dustcanyon.test.luau` already builds the map with `Layout.build(biome, ...)` and checks ids only, so it should still pass. `tests/encounters.test.luau` already sets `second.map = nil`.
4. **First play.** Run the game once with the sheet but no dressing. TestMap treats a biome with a map but no dressing as generated, with slabs and scatter, but every place, person and patch is already at its designed spot.
5. **Dressing sheet.** Add `src/content/map_data/DustCanyonDressing.luau` from section 3d. Extend the dressing checks in `tests/layout.test.luau` to every dressing sheet: include `walls` in the "within 6 of a prompt" and "crosses a lane" checks.
6. **Builders:**
   - Section 4d fixes 1 to 4.
   - `Corridors` (edge styles, spur and ring planting).
   - `Fences` (the six new edge recipes, and the Rope and Rockfall fences).
   - `Scenery` (optional guards, walls, flats, plaza colours, arch model).
   - `Landmarks` (gatehouse model and banner, landmark, optional guards).
   - `Grass` (looks).
   - Keep every ProximityPrompt and its attributes exactly as now.
7. **Models.** Generate the 13 models, add them to `src/content/PropModels.luau`, and log them in `docs/ASSETS.md`. Until then every piece has a plain-shape fallback.
8. **Optional, last:**
   - A real drop on the rim (raise the rim corridor 14 studs on a terrace with ramps at 150 to 170 and 340 to 360, as Greenwood's optional terrace). It needs wild creatures to take their height from a raycast too.
   - Wind and wind-chime ambience, and kiln smoke particles.
   - A warmer lighting mood while in Dust Canyon (client-side, by biome).

### Check in Studio

- [ ] Walking in from Greenwood: the Trading Post's door is dead ahead, and the Redstack's top shows above the north cliff about 30° left. The north and east arches are both on a phone screen.
- [ ] The `canyon_arrival` beat fires about 5 seconds past the west arch, not in the Westcut.
- [ ] The ground does not flicker at the Greenwood/Dust Canyon join (the clipped slabs, 4d fix 1), and the Westcut is sand-coloured.
- [ ] No hedge, Pine, Tree or green lawn appears anywhere in the biome.
- [ ] Waking after a loss lands on the Seep House forecourt at about (-58.5, 25.6).
- [ ] Each prompt shows alone. The tightest pair is the Notice Wall and Waystation, 45 apart.
- [ ] Grass ambushes start only on the dark discs. The dry tufts stay inside them.
- [ ] Ines can be seen from the north arch. Tavish cannot be walked round between the buttresses.
- [ ] The rival stands on the rim with the gorge behind him. `mesa_sighting` fires in the Spire Garden after the spur fork.
- [ ] Isolde's prompt works inside the Stair Gate arch, and `canyon_road_on` does not fire until the bar.
- [ ] No creature appears inside a cliff or boulder bank. The narrowest corridor is the spur at 30, and creatures stand at most 18 to the side.
- [ ] The Redstack is visible from the flats on Route A (to the right) and from the rim.
- [ ] Draw calls and frame rate on a phone-sized view. There are about 90 cliff sections (about 3,600 studs of cliff) and about 670 tufts.
- [ ] Screenshots from the west arch, the square, the first bend of the wash, the rim with the rival, and the Spire Garden, checked against the brief's art direction (low-poly, chunky, flat colours).

---

## 9. Decisions I made that the written world did not settle

1. **Where everything is.** The written world gives only names, lengths and notes. Every position, facing, door, width and colour here is mine, a [Default].
2. **Route A leaves north and Route B east, entered from the west.** Layout puts Dust Canyon east of Greenwood's gate, so the road from Greenwood arrives from the west. Route B ends due east so the next biome lands straight on.
3. **The Westcut** (a canyon slot as the town's west entrance) and its sign, and the town's name painted on all three arches.
4. **The town plan:**
   - Sundial Square has a well at its centre, not a sundial.
   - The Trading Post is the hero building on the arrival axis.
   - The healer is first on the left, and the Waystation first on the right.
   - Cave Row is a line of houses against the north cliff.
   - The Overlook is tucked in the north-east by the winch gate.
5. **Recognisable service buildings.** The Seep House reuses Greenwood's Healer model and the Sundial Waystation reuses the Waystation model, so players learn them once (as classic games repeat their healer and shop buildings). The shop gets a local hero model because its keeper starts the chapter's story. **For Ayrton:** a canyon-styled healer and waystation would cost two more models.
6. **The landmark is a separate mesa (the "Redstack") behind the arena**, not the giant itself. The giant model stays at the arena centre as now. "Redstack" is a placeholder name.
7. **The shortcut** (`shortcutToHub`, still unused by code) is a mine-cart "winch track" from the shelf to a shut gate by the Overlook, blocked by a rockfall and signed "Shut". It is dressing only.
8. **Route A's dead end** is a broken rope bridge over a dry fall, with a far side that can be seen but not reached.
9. **Rim and gorge.** The "long drop" beside the rim is shown, not walked, in the first build: a boulder lip, a shadowed gorge floor and a far wall. A real drop is an optional last step.
10. **Tavish's pinch** is made real with two boulder buttresses narrowing the stair road to 44.
11. **New names for places:** Kiln Street, Wash Lane, East Road, Cave Row, the Westcut, Sundial Square, the Seep (the spring), the winch track and the Redstack. All are placeholders.
12. **Tamer facings** point back towards where players arrive. The tamer positions themselves are new (the data only says "along").
13. **The Stall model is reused** for the Shelf Stall, whose label comes from the data (4d fix 3).
14. **Field ground** is warm clay (214, 172, 124), and ground slabs are clipped between biomes (4d fix 1).

**Open for Ayrton (batch):**
- Should the healer and waystation look the same in every town (as now), or get local versions?
- Is a dry, cliff-walled town still "homely" enough? The washing lines, clay planters, the well, the spring garden and the warm lighting are meant to carry it.
- Should the rim get a real drop (a terrace) once wild creatures can take their height from the ground?
