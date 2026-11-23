# 15 · The Mire, designed (Sedgeholm, the Duckboard Trail and the Cypress Road)

The Mire (biome 4) has game data (`src/content/biome_data/Mire.luau`) but, until this plan, no drawn map. This plan sets it out to the standard of `10_TIDE_FLATS_MAP.md` and builds it in `src/content/map_data/Mire.luau` and `MireDressing.luau`. It keeps every place id, route length, spawn table, tamer distance and story trigger in the Mire's data (`tests/mire.test.luau` still passes untouched). The biome stays closed (`ReleaseConfig.OPEN_BIOMES` is 3); the map sheets, tests and builder entry are ready for the day it opens.

Conventions are those of plans 08 to 10:
- Studs. Every point is relative to Sedgeholm's centre, the hub place `mire_hub`, at (0, 0). In the world that is **(3100, -550)** (plan 13 section 3a), set by the new `site` field on the biome.
- **North is -z**; east is +x.
- Facings are degrees clockwise from north and point along (sin θ, -cos θ).
- "Left" and "right" are as seen walking away from town.
- Walking speed is 16 studs a second.

The new sheet fields, edge styles and builder recipes are in plan 09 section 4 and plan 12. This plan uses them and adds nothing to the builders except two small TestMap changes for a sited biome (section 4).

**Where the Mire sits.** Plan 13 puts it north-east of Saltwick. Tide Flats' sealed road ends at world (2926, -70) (its gate at (2806, -70), the road 60 on, then 60 more drawn by the builder). The Heron Causeway starts there, which is (-234, 480) here, and reaches Sedgeholm's south arch at (0, 150). The Mire's own gate is at (150, -602) here, world **(3250, -1152)**, and its sealed road runs 60 due **north** (the Rimewater Gorge goes north). The first three biomes' gates run due east, so `layout.test` now checks "the sealed road runs on 60 along the route's last leg", with the due-east rule kept for biomes with no `site`.

---

## 1. The idea

**Sedgeholm is a reed-thatched village on stilts and duckboards over a swamp.** Everything is wet, green-grey and quiet: boards, rope rails, reed bundles drying on lines, lanterns the colour of fireflies, mist at ankle height. You come up the Heron Causeway out of the sea fog and through a south arch, onto the Heron Walk, a duckboard street that leads straight to the middle of the village:
- **Bell Square**, a round of boards round the **Bell Cypress**, a huge old tree with a bronze fog bell in its branches (the hub's landmark in the data). Fireflies drift over it.
- **Quill's Sundries** (shop), east of the square, a tarred stall.
- **The Clearwater Spring** (healer) to the west, with its round clear pool and reeds.
- **The Reed Nursery** (breeder), south-west, with egg nests in the reeds behind.
- **The Mooring Post** (quests), a notice board on the Cypress Walk to the north.
- **The Punt Landing** (teleport, Jory Pike) on a pond to the south-west with a jetty and tied-up punts.
- **The Cypress Ring** (circuit) to the north-east: a round of boards and a rope rail among cypress knees.
- **The Bell Loft** (lookout) to the north-west, on its own raised deck: the one flight of stairs in town, with a one-way ledge off its back.

Nine keeperless huts (stilt houses and net lofts) stand about the edges. The village's edge is a reed fence, open at three arches.

There are two ways out and one side area:
- **Route A, the Duckboard Trail** (500), leaves east. Reeds taller than a player, then still lily channels crossed on a stepping shelf of mangrove roots, then a boardwalk level over the roots, ending at a rope ferry that is not running. A duckboard branch off the Mangrove Tangle ends where the boards vanish into black water: the **Sunken Bell**, a drowned bell tower seen across the water (dressing only; plan 13 gates it behind a later opening).
- **Route B, the Cypress Road** (720), leaves north in a long S: peat cuttings, an empty stilt hamlet on a raised boardwalk, a wide misty water of cypress knees where the spur to the **Sunken Grove** forks west, and a packed-peat rise to the **Sluice Gate**, from which the Rimewater Gorge climbs north.

How it must feel different from Tide Flats:

| | Tide Flats | Mire |
| --- | --- | --- |
| Edges | Rope rails, dunes, sea rocks, sea walls | Reed walls (hedge), rope rails, peat banks, tangled roots |
| Ground | Pale sand, black rock, grey mud | Peat black, mud green, dark water, packed peat |
| Water | Open sea and harbour | Still channels, pools, a pond, the estuary |
| Plants | Marram, kelp, reeds on the mud | Reeds, lily pads (Kelp stand-in), mangrove and cypress (Tree stand-in) |
| Town | Stilts and a quay round a harbour | Reed huts on duckboards round one great tree |
| Light | Bright sea light | Soft green overcast, mist, fireflies, a lantern green |
| Landmark | The Old Light, tall white | The Bell Cypress in town; the drowned bell tower far out |

Each stretch is a different place: reed fringe (tall walls, narrow boards), lily lanes (open water, stepping shelf), mangrove tangle (roots, raised boardwalk), peat cuttings (neat black pools), stilt hamlet (boardwalk deck, huts), fogwater reach (wide mist, cypress), sluice rise (peat bank climbing to the gate).

---

## 2. Maps

Drawn from the built sheets by script. The tables in section 3 are what counts.

### 2a. The whole biome

Scale: 20 studs across, 40 down; x runs from -340 (left) to 620, z from -700 (top) to 500. `.` is walkable, `^` is a raised tier.

```
z -700                         ^^                      
z -660                     ..^^^^                       sluice bank (tier 10)
z -620                   ....^^G^                       G the Sluice Gate (150, -602)
z -580               ..........^.                       the rise
z -540    .....      ...k...c...                        k sinkhole   c Cuthbert (620)
z -500  ...........   .T.....                           T the Grove Stall
z -460  ....L............ .y^^^                         L the Sunken Grove arena  y Ysolde (400)
z -420  ..........    ....^^^^^..                      hamlet deck (tier 10)
z -380  .........     ...^^R^^^..                       R the rival's stand
z -340     ...          .........
z -300                  ......                          Cypress Road: a long S
z -260               ....n....                          n Barnaby (110)
z -220               .........                          peat cuttings
z -180          ................
z -140          ..^^^^..........                        Sedgeholm (300 square)
z -100          ..^^^^..........                        ^ the Bell Loft's deck
z  -60          ................  ....
z  -20          ........S.............  .....           S the Bell Cypress and Bell Square
z   20          .....................w.......           w Wren (120)
z   60          ................ ..  .^^^....            lily shelf (tier 10)
z  100          ................     .^^^..b.           b bubbling pool
z  140          ................        .....m.h^^^     m Marisol (400)  h steaming hummock
z  180               ...                .......^^^^     tangle deck (tier 10)
z  220              ...                 .....   ^^^
z  260             ...                     ...          the Sunken Bell's branch, to the left of the deck
z  300            ...
z  340           ..                                     the Heron Causeway (from Tide Flats)
z  380          ...
z  420       .....
z  460     .....
x   -340          -140        60        260       460      620
```

Tamers: Wren (A 120), Marisol (A 400), Barnaby (B 110), Ysolde (B 400), Cuthbert (B 620). The rival stands on the hamlet deck (B 270) and the champion Honora Vell in front of the Sluice Gate.

- **Route A (500):** east out of town, a kink south-east through the lily lanes, then east to the ferry at (511, 212).
- **Route B (718 drawn, fitted to 720):** north, then a long S west and east across the cuttings, hamlet and fogwater, then due north up the rise.
- **Spur (280):** forks west at 440 on the fogwater and ends in the Sunken Grove's cove, arena radius 90 (the clearing).

### 2b. Sedgeholm

Scale: 6 studs across, 12 down. `:` a street, `o` Bell Square, `^` the Bell Loft's deck, `@` the Bell Cypress, `h` a keeperless hut.

```
z -144                            ::                      north arch (21, -142), Route B
z -132      ^^^^^^^^^^^^          :       h         h
z -108   h  ^^^^^^^^^^^^         ::                       B Bell Loft (-84, -96) door (-84, -80)
z  -96      ^^^^^^B^^^^^         :             R          R Cypress Ring (92, -90)
z  -84      ^^^^^^:::::^        ::::::::::::::
z  -72      ^^^^^^^^^^:^     M  :                         M Mooring Post (-14, -70)
z  -60                     ::::::
z  -48     h          ::::::    :                 h
z  -36              H  :        :::::::  Q                Q Quill's Sundries (56, -30)
z  -24                 ::::: oooooo                       H Clearwater Spring (-70, -26)
z  -12                     ::ooo@ooo
z    0                     :oooooooo:::::::::::           Reed Lane east to Route A
z   12                :::::  oooooo           ::::::::
z   24           N  :::         :                    ::::   N Reed Nursery (-88, 30)
z   60     h                  :::                  h
z   72                ::::::::: :
z   84         ::::P:::         :                         P Punt Landing (-76, 84), pond and jetty west
z  108                     h    :
z  144                         ::                         south arch (0, 142): the Heron Causeway
x  -150     -90      -30      30       90       150
```

**Arriving.** The player comes up the Heron Causeway and through the south arch (0, 142), facing north up the Heron Walk. The spawn record is (0, 128) facing 0 (the Mire is not the first biome, so no SpawnLocation is built).
- 8 seconds in (128 studs) they cross the square (`mire_arrival`, entering `mire_hub`).
- Straight ahead the Bell Cypress fills the end of the street; the Bell Loft's lantern shows to the north-west.
- The Clearwater Spring is on the left of the square, 70 studs from the centre: the healer (Ottilie Dunmore) is the first talk (`mire_poison`).
- The Punt Landing branches off the Heron Walk to the left at z 70.
- Route A (east) and Route B (north) leave from the square by their own streets, signed.

### 2c. Route A: the Duckboard Trail

```
z   0   town                                 150
z  20   reedfringe 0-160: duckboards, reed walls both sides (half 9-13), Wren at 120 (half 9)
          reed pocket + long grass north (244, -10); a dead-end blind (204, 70)
z  40   lily lanes 160-330: still water, rope rails both sides, half 17 opening to a 12-16 channel
          mangrove root shelf west (tier 10): stairs up, ledge hop back down, a dead end
          bubbling pool east (388, 104); lily grass north (377, 29)
z 150   mangrove tangle 330-500: reed wall left, root rocks right, Marisol at 400 (half 9)
          grass pocket south-west (350, 200); the Sunken Bell's branch south (400, 196) to the landing
          the boardwalk level (tier 10) from 430 on, the steaming hummock north (466, 154)
z 212   the rope ferry (511, 212): a rope fence across, not running
```

### 2d. Route B: the Cypress Road

```
z -150  town, north arch (20, -150)
z -200  peat cuttings 0-180: black pools in rows, rock banks left and reed wall right, half 9-14
          Barnaby at 110 (half 9); the peat pocket east with long grass (87, -244);
          a cutting room west (dead end, a second grass patch)
z -300  old stilt hamlet 180-360: the boardwalk deck (tier 10) from a ramp at 235 to stairs at 345
          the rival on the deck; a balcony ledge hops down east to a shore; a grass pocket west (-5, -372)
z -420  fogwater reach 360-540: widest water (half 22), cypress knees, rope rail right, reed wall left
          Ysolde at 400 (half 12); the spur forks west at 440 (31, -484); the sinkhole north-east (16, -521);
          grass pocket north-west (-29, -545)
z -550  sluice rise 540-720: packed peat, peat banks left, a sea wall right; Cuthbert at 620;
          long grass west (69, -581); the peat bank (tier 10) from stairs at 684 to the gate;
          a ledge hops down west to a shore from beside the gate
z -602  the Sluice Gate (150, -602); the sealed road runs on 60 north
```

---

## 3. Coordinate tables

### 3a. The map sheet (`src/content/map_data/Mire.luau`)

**Routes as waypoints**, fitted to the data length by Layout:

| Route | Waypoints (x, z) | Leg sum | Fitted to |
| --- | --- | --- | --- |
| `mire_route_a` | (150,30) (205,18) (262,44) (322,34) (368,80) (350,142) (396,186) (452,176) (500,208) (511,212) | 499.7 | 500; end (511, 212) |
| `mire_route_b` | (20,-150) (60,-205) (30,-262) (80,-310) (60,-375) (110,-420) (60,-470) (-10,-505) (35,-548) (95,-528) (150,-555) (150,-602) | 718.2 | 720; end (150, -602.3), last leg due north |
| Spur (`mire_lair`) | join (31.1,-484.4) (-20,-452) (-90,-442) (-150,-410) (-210,-418) (-229,-426) | 280.3 | 280; arena (-228.7, -425.9) |

**Half-widths** (`widths`), with the pinch points at the tamers:

| Route | Keys (along: half) |
| --- | --- |
| A | 0:9 36:9 48:13 100:13 108:9 136:9 150:13 166:17 210:17 222:12 250:12 262:16 300:16 320:12 336:13 392:13 398:9 412:9 420:13 470:13 486:16 500:21 |
| B | 0:9 36:9 46:12 90:12 98:9 124:9 134:14 190:14 204:19 238:19 250:12 292:12 304:17 348:17 362:22 390:22 398:12 430:12 446:18 526:20 540:12 600:12 606:10 634:10 642:13 700:13 720:20 |
| Spur | 0:9 120:9 130:7 200:7 214:10 280:10 |

**Edges** (`edges`, left and right as seen walking away from town) and planting:

| Stretch | Left | Right | Ground | Planting | Grass |
| --- | --- | --- | --- | --- | --- |
| `reedfringe` | Hedge | Hedge | 112,126,88 | Reeds | Reeds on mud |
| `lily_lanes` | Rope | Rope | 70,112,104 | Kelp (lily pads) | Kelp |
| `mangrove_tangle` | Hedge | Rocks | 104,98,72 | Tree | Reeds |
| `peat_cuttings` | Rocks | Hedge | 70,60,52 | Reeds | Reeds |
| `stilt_hamlet` | Rope | Rope | 104,96,78 | Tree | Reeds |
| `fogwater_reach` | Hedge | Rope | 112,134,128 | Tree | Reeds |
| `sluice_rise` | Rocks | SeaWall | 128,110,82 | Reeds | Reeds |
| `mire_lair` | Hedge | Hedge | (lane colour) | Tree | none |

`roomEdge` is Rope: every pocket, dead end and the causeway itself is ringed with a rope rail on posts (low, see-through, and it makes the causeway a stilted boardwalk with water on both sides).

**Buildings** (`buildings`; door is where the keeper stands, 16 in front):

| Building id | Model | Middle | Faces | Door | Footprint (w × d, tall) |
| --- | --- | --- | --- | --- | --- |
| `quill_sundries` (Shop, `vesper_quill`) | Chandlery (stand-in) | 56, -30 | 270 | 40, -30 | 24 × 18, 24 |
| `clearwater_spring` (Healer, `ottilie_dunmore`) | Healer | -70, -26 | 90 | -54, -26 | 18 × 19, 26 |
| `reed_nursery` (Breeder) | NetLoft (stand-in) | -88, 30 | 90 | -72, 30 | 20 × 16, 20 |
| `mooring_post` (Quests) | NoticeBoard | -14, -70 | 180 | -14, -54 | 20 × 4, 10 |
| `punt_landing` (Teleport, `jory_pike`) | Waystation | -76, 84 | 90 | -60, 84 | 20 × 20, 40 |
| `cypress_ring` (Circuit) | none (boards, rope rail) | 92, -90 | 225 | 80.7, -78.7 | 40 × 30, 0.4 |
| `bell_loft` (Lookout) | LampTower (stand-in) | -84, -96 | 180 | -84, -80 | 16 × 16, 36 |

The Bell Cypress stands at (0, -2), 52 tall (`ancientTree`), in the middle of Bell Square.

**Tiers** (height 10 each) and links:

| Tier | Box (x0, z0, x1, z1) | What |
| --- | --- | --- |
| `bell_deck` | -120, -126, -48, -66 | The Bell Loft's deck, in town |
| `lily_shelf` | 292, 84, 338, 124 | A mangrove root shelf above the lily channels (a dead end) |
| `tangle_deck` | 480, 176, 545, 246 | The boardwalk level over the roots at the trail's end |
| `hamlet_deck` | 30, -440, 140, -340 | The old hamlet's raised boardwalk, with the rival |
| `sluice_bank` | 100, -700, 200, -580 | The peat bank under the gate and the sealed road |

| Link | Kind | From → to | Width | Joins |
| --- | --- | --- | --- | --- |
| `bell_stairs` | Stairs | (-56, -46) → (-56, -72) | 10 | Town to the Bell Loft's deck |
| `bell_ledge` | Ledge | (-48, -100) → (-48, -116) | 8 | East lip of the deck, hop down to the Cypress Walk |
| `shelf_stairs` | Stairs | (352, 104) → (328, 104) | 10 | Lily lane to the root shelf |
| `shelf_ledge` | Ledge | (292, 98) → (292, 114) | 8 | West lip of the shelf, hop down to a pocket that leads back to the lane |
| `tangle_ramp` | Ramp | (459, 181) → (482, 196.4) | 14 | Lane up onto the deck at 436 |
| `tangle_ledge` | Ledge | (530, 176) → (514, 176) | 8 | North lip, hop down towards the hummock |
| `hamlet_ramp` | Ramp | (73.8, -331) → (68.3, -350) | 14 | Lane up onto the deck at 233 |
| `hamlet_stairs` | Stairs | (83, -447) → (97, -433) | 12 | Down off the deck at 346 |
| `hamlet_ledge` | Ledge | (140, -380) → (140, -396) | 8 | East lip, hop down to a shore that leads back to the lane |
| `sluice_stairs` | Stairs | (150, -566) → (150, -590) | 12 | Lane up to the gate at 684 to 708 |
| `sluice_ledge` | Ledge | (100, -640) → (100, -624) | 8 | West lip beside the gate, hop down to a shore |

Every ledge drops one tier with the high ground on the left and a way home on foot below it, as `walk.test` and `ground.test` require.

**Rooms** (`rooms`): the five causeway strips (half 9) from (-234, 480) to (0, 150); on Route A the reed pocket, reed blind (a dead end), lily pocket, shelf rooms and way, pool pocket, mangrove pocket, the Bell's branch (a strip and a landing), the hummock pocket and the deck rooms; on Route B the peat pocket, the cutting room and way (dead end), the hamlet pocket and way, balcony and shore with their way, the fog pocket, the sinkhole pocket, the sluice pocket, shore and brink; on the spur the grove nook. Every room is reached by `walk.test`.

**Extra grass** (`grass`): Reedfringe (204, 70) r 8 in the blind; Peat Cuttings (-26, -220) r 8 in the cutting room. With the seven stretch patches that is nine patches, each in a pocket beside the path; the walk past is always grass-free.

**Set places** (`places`, patches of radius 20 each in a pocket of radius 32 at 42 off the lane):

| Id | x, z | Along / off | What |
| --- | --- | --- | --- |
| `reedfringe_grass` | 244, -10 | 80 / left 42 | Reed pocket |
| `lily_lanes_grass` | 377, 29 | 215 / left 42 | Lily pocket, north |
| `mangrove_tangle_grass` | 350, 200 | 350 / right 42 | Pocket south-west of the lane |
| `peat_cuttings_grass` | 87, -244 | 90 / right 42 | Peat pocket east |
| `stilt_hamlet_grass` | -5, -372 | on the way off the deck | West of the hamlet |
| `fogwater_reach_grass` | -29, -545 | 500 / left 42 | North-west of the lane |
| `sluice_rise_grass` | 69, -581 | 570 / left 42 | North of the lane |
| `bubbling_pool` | 388, 104 | 262 / left 26 | Rustle spot, pocket r 16 |
| `steaming_hummock` | 466, 154 | 430 / left 26 | Rustle spot, north of the deck |
| `sinkhole` | 16, -521 | 470 / right 26 | Rustle spot |
| `mr_wren` | 262, 36 | 120 / left 8 | Pinch, half 9 |
| `mr_marisol` | 421, 173 | 400 / left 8 | Pinch, half 9 |
| `mr_barnaby` | 33, -238 | 110 / left 8 | Pinch, half 9 |
| `mr_ysolde` | 60, -459 | 400 / left 8 | Pinch, half 12 |
| `mr_cuthbert` | 99, -539 | 620 / left 8 | Pinch, half 10 |

**Stands**: `rival_mire` at (62, -372) (on the hamlet deck, 3.7 from `stilt_hamlet`); `champion_vell` at (150, -596) (6.3 from `mire_gate`).
**Facings**: the tamers face the way players arrive (283, 264, 141, 124, 268); the rival 163; the champion 180.
**Spawn record**: (0, 128), facing 0.

### 3b. Places Layout works out (reference)

| Id | x, z | How |
| --- | --- | --- |
| `mire_hub` | 0, 0 | The origin (world (3100, -550)) |
| `mire_route_a` (entry) | 179, 24 | 30 along; 139 from the nearest door |
| `reedfringe` | 229, 31 | 80 along |
| `lily_lanes` | 363.8, 94.6 | 245 along |
| `mangrove_tangle` | 422.5, 181.3 | 415 along |
| `mire_route_b` (entry) | 37.6, -174.3 | 30 along |
| `peat_cuttings` | 47, -229 | 90 along |
| `stilt_hamlet` | 60.2, -375.2 | 270 along (the rival's place) |
| `fogwater_reach` | 22, -489 | 450 along (the `grove_sighting` place, 10 past the spur fork) |
| `sluice_rise` | 112, -536 | 630 along |
| Spur join | 31.1, -484.4 | 440 along Route B |
| `mire_lair_stall` | -2.5, -462.9 | 40 down the spur |
| `mire_lair` | -228.7, -425.9 | End of the spur |
| `mire_gate` | 150, -602.3 | End of Route B |
| `mire_sealed_path` | 150, -662.3 | 60 north of the gate |

### 3c. The story order still works

| Beat | Trigger | Where |
| --- | --- | --- |
| `mire_arrival` | Enter `mire_hub` | (0, 0): 128 studs (8 s) past the south arch |
| `mire_poison` | Talk to `ottilie_dunmore` | The Spring's door (-54, -26), 70 studs left of the square |
| `first_mire_tamer` | Beat `mr_wren` | (262, 36), 80 s along Route A: a pinch of the reed fringe |
| `mire_catch` | Tame anything | The first stretch's grass (244, -10) is a patch beside the lane |
| `mentors_visit` | Talk to `jory_pike` | The Punt Landing door (-60, 84) |
| `mire_rival` | Beat `rival_mire` | Stands at (62, -372) on the hamlet deck |
| `grove_sighting` | Sight `fogwater_reach` | (22, -489): the fork to the grove, the mist and the first cypress |
| `mire_gate_challenge` | Enter `mire_gate` | (150, -602) |
| `mire_badge` | Beat `champion_vell` | Stands at (150, -596) |
| `mire_road_on` | Enter `mire_sealed_path` | (150, -662); the bar is at (150, -615) |

### 3d. The dressing sheet (`src/content/map_data/MireDressing.luau`)

**Colours**: field ground (92,110,82), town ground (118,128,92), lane colour (138,118,86) (damp boards), plaza (150,118,84) with a darker kerb (104,80,58), planks (150,120,84), streets (160,138,98).

**Lane surfaces**: Route A 0 to 160 boards (flat); Route B 180 to 360 deck on stilts (the hamlet); Route B 540 to 720 packed peat.

**Lanes**: the Heron Walk (16 wide, (0,150) to (0,28)); the Heron Causeway (16 wide, deck, from (-234,480) via (-150,440) (-110,340) (-60,250) (-20,190) to (0,150)); the Cypress Walk; the Reed Lane; side paths to each door; the Bell Loft's two paths (one each side of the stairs); the punt jetty (4 wide, deck).

**Water**: five flats (the estuary shallows round the causeway, the black water south of Route A, the drowned village round the Sunken Bell, the lake east of the hamlet, and a dry peat bog beside the cuttings); three pools (the Clearwater Spring r 7, the punt pond r 22, a village pool r 10).

**Fences**: two across (the rope ferry at the end of Route A; the boards that end at the Sunken Bell). The village's own edge is three runs of reed hedge with gaps at the three arches.

**Landmark**: the Sunken Bell's tower at (424, 330), 44 tall, standing in the water (stand-in model until the bell tower exists).
**Gatehouse**: at the gate, facing north, `SluiceGate` (plain stand-in) with the banner "Bulrush Badge".
**Fill**: a Forest band of 70 on a dark swamp floor (about 677 parts, the same as Tide Flats' dunes).
**Ambience**: smoke from the stilt houses, green lantern light, a halo at the Bell Loft and at the drowned bell, fireflies over the square and the hamlet, mist on five stretches of water (thickest on the fogwater and halfway along the causeway), a glint on every pool and flat. 39 emitters, 19 lights, well inside the budget.

---

## 4. What bounds the corridors, and what changed in code

- **No new edge styles.** The Mire uses Hedge as a reed wall, Rope, Rocks (peat banks and roots) and SeaWall (the old sluice walls). A real Mangrove edge and a reed fence would be better looks; they are listed in section 5.
- **`Biome.site`** is set on the Mire: `{ hub = (3100, -550), base = 0 }` (plan 13 section 11b). `Layout.world` already reads it.
- **`TestMap`** (`src/server/World/TestMap.luau`): the Mire's dressing is registered; a sited biome's slab is not clipped at the previous gate and its rooms count towards the slab's extent; and the "walk from the biome before" link (a strip from the previous gate to this town's west edge) is skipped, because the Mire's causeway is a drawn room.
- **Tests**: `layout.test`, `walk.test`, `ground.test`, `enclosure.test` and `ambience.test` open the Mire (`OPEN_BIOMES = 4`) and run every check on it (every place reached and left, no trapped cell, ledges one-way, grass-free walk, tamers at pinch points, no prompt in water). `layout.test` also generalises the sealed-road rule and the arrival rule for a sited biome.
- **Known hazard (not mine to fix here):** Tide Flats' `region` (x from 1793 to 4500, z ±4000) covers the Mire, and `Layout.biomeAt` checks regions first with the lowest number winning, so every point in the Mire would read as Tide Flats once the Mire opens. The fix is to narrow Tide Flats' region and give the Mire its own, in the same change that opens it.

---

## 5. Models

Existing painted models used: Healer, NoticeBoard, Waystation, Reeds, Kelp (lily pads), Tree (mangrove and cypress stand-in), StiltHouse and NetLoft (the reed huts and the nursery), Chandlery (Quill's stall), LampTower (Bell Loft and the drowned bell tower), Rowboat (punts), Barrels, Bench, WashingLine, VillageArch, and the Greenwood-style tamers and carers.

Still to make (clay-toy style; prompts in the report that comes with this plan). Names are what the sheets will use when they exist:

| Model | What | Used for |
| --- | --- | --- |
| `ReedHut` | A reed-thatched stilt hut on poles, rope ladder | Sedgeholm's keeperless huts (replaces StiltHouse in `houses`) |
| `Mangrove` | A mangrove tree on arching stilt roots | `mangrove_tangle`, the hamlet's edge |
| `Cypress` | A bald cypress with knobbly knees | `fogwater_reach`, the Bell Cypress, the grove |
| `BellTower` | A drowned bell tower, half under water, a bell in its open top | The Sunken Bell landmark (replaces LampTower) |
| `BellLoft` | A reed-thatched loft with a bronze bell | The Bell Loft (replaces LampTower) |
| `LilyPads` | A cluster of lily pads and white flowers | Lily lanes and the village pond (replaces Kelp) |
| `Punt` | A flat-bottomed punt with a pole | The Punt Landing (replaces Rowboat) |
| `SluiceGate` | A great wooden lock gate under a banner | The Mire's gatehouse |
| `ReedWall` | A hedge-like wall of tall reeds (a tile) | The reed fence (a new edge style, `Reed`) |

---

## 6. Walk times (16 studs a second)

| From → to | Studs | Time |
| --- | --- | --- |
| South arch → Bell Square | 142 | 9 s |
| Bell Square → Spring door | 65 | 4 s |
| Bell Square → Punt Landing | 95 | 6 s |
| Bell Square → Route A entry | 180 | 11 s |
| Route A entry → Wren | 90 | 6 s |
| Whole of Route A | 500 | 31 s |
| Bell Square → Route B entry | 175 | 11 s |
| Whole of Route B | 720 | 45 s |
| Fork → the grove | 280 | 18 s |
| Causeway, Saltwick's road to the south arch | 420 | 26 s |

---

## 7. Sightlines

- **Arriving up the Heron Walk:** the Bell Cypress at the end of the street, and the Bell Loft's lantern above the roofs to the left.
- **From the Bell Loft's deck:** the whole village in mist, the arches, and the first sluice-rise banner a long way north.
- **Along the trail:** from the stepping shelf the lily lanes lie below you with the Bell Cypress on the skyline; from the tangle deck the drowned bell tower stands in black water south.
- **On the hamlet's deck:** the whole hamlet and its huts, the lake east, the cypress of the fogwater north.
- **At the fork:** the Sunken Grove's trees close in to the west; the Sluice Gate's banner shows north across the water.

---

## 8. Build order and Studio checklist

1. `lune run check` (done: map, dressing, tests).
2. Open the Mire in a scratch run (`OPEN_BIOMES = 4`) and build the test map in Studio; read the `[World] mire:` log lines (tiers lifted, no parts across two heights).
3. Walk the causeway from Tide Flats' sealed road: the two roads must meet, and the rope rail must not close the join.
4. Check the Mire's slab and the overlap with Tide Flats' slab west of x 2836 (the rooms are on the slab; the clip is off for a sited biome).
5. Swap stand-in models for the generated ones.
6. Fix `region` for Tide Flats and the Mire (section 4) and open the biome in `ReleaseConfig`.

## 9. Decisions I made that the written world did not settle

1. **The Sluice Gate faces north**, so the sealed road runs due north, and the layout rules are generalised (section 4).
2. **The Heron Causeway arrives at the south arch from the south-west**, a little west of plan 13's waypoints (which ran inside the town). It is 420 studs long and is part of the Mire's sheet, not Tide Flats'.
3. **The Sunken Bell is a branch, not a place:** a duckboard strip and landing closed by a rope fence, with the tower and its glow beyond, because plan 13 gates the area behind a later opening. Its centre is near (424, 330) here against plan 13's (450, 250).
4. **Room edges are rope rails** for every pocket (a low, see-through rail), instead of a hedge ring.
5. **Stand-in models** keep the map testable now; every stand-in is a name change when the real model exists.
