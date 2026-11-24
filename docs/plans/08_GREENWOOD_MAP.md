# 08 · Greenwood, designed (not generated)

The owner: "I feel like you havent planned and structured the map correctly." He is right. Today the server builds Greenwood from a formula:
- Buildings are spaced evenly round a circle.
- Routes zigzag by ±18° on open lawn.
- Grass is a see-through slab 40 studs off the path.
- Trees are scattered from a random seed.

This plan replaces the formula with a map drawn on purpose. It keeps every place the server checks.

Conventions used throughout:
- Studs; the town centre is (0, 0).
- **North is -z** (the top of every map); east is +x.
- Facing is in degrees clockwise from north: 0 is N, 90 is E, 180 is S, 270 is W. A facing θ points along (sin θ, -cos θ).
- Walking speed is 16 studs a second.

## 0. Research (short)

| Finding | Label |
| --- | --- |
| The first route of the classic games is an S-shape. It winds round high ground with grass between the stretches. One-way ledges make it hard going away from home, but on the way home you can hop down and skip the grass. (Bulbapedia, Kanto Route 1; Serebii) | Sourced |
| Brick Bronze's first route (kept "mostly the same" in Loomian Legacy) is short and winding, an S with grass patches between. It starts at the end of the bridge over the creek through the starting town. Just outside town there is a small grass patch, then a first tamer shortly after. (Loomian Legacy wiki, Route 1; Brick Bronze wiki) | Sourced (snippets) |
| Starting towns are about two screens square (20 by 18 cells), the smallest maps in each game. Each has one entrance two cells wide. The first door is 5 to 17 cells from the entrance (median 12). Walks are 1.07 to 1.25 times the straight line. Healer and shop signs sit beside their doors. The fly point is just south of the healer's door. (Secondary analysis of the games' collision data, blakecrosley.com) | Sourced, secondary |
| A landmark visible from far away pulls players along: show it, hide it, show it again. Leading lines (fences, hedges, rivers, lamp rows) do the guiding. Natural barriers beat invisible walls. Healer first on entering, shop beside it, giant's lair on a spur seen early. (`docs/research/market/03_MAP_AND_WORLD.md` section 4) | Sourced earlier, in repo |
| Tamers stand facing the path and see in a straight line a few steps ahead, often at bends and narrow points. You can usually walk round them, except at one or two pinch points. | Recall |
| A signpost stands at every route entrance and town edge. A pond or stream sits on or near the first route. A gate town is bigger than the home town, with the gym as its landmark and a healer near its entrance. Routes take 30 to 90 seconds of straight walking. | Recall |
| Converted to our scale: one cell is about one step (5 to 6 studs). A classic starting town is about 110 by 100 studs and takes about 5 seconds to cross. Ours has 7 buildings and a 3D camera, so its built area is about 200 by 175 studs: 12 seconds across, 5 seconds from spawn to the first door. | Estimate |

Sources: https://bulbapedia.bulbagarden.net/wiki/Kanto_Route_1 · https://serebii.net/pokearth/kanto/route1.shtml · https://loomian-legacy.fandom.com/wiki/Route_1 · https://brickbronze.fandom.com/wiki/File:Frigidia_Island.png · https://blakecrosley.com/blog/pixel-art-towns-on-iphone

## 1. Principles

Each principle gives the rule, why it matters, and how today's map breaks it.

1. **Placed, not generated.** Every building, path, patch and person sits where a designer put it, and the spot is recorded as data.
   - Why: only a placed map can be homely, readable and tuned.
   - Today: buildings are spaced by list order round a 90-stud circle, routes are a zigzag formula, and scenery comes from a random seed (`Layout.build`, `Dressing.scatter`).
2. **A home town fits in one look.** Keep it compact, with streets, gardens and a centre. Key doors are within 5 seconds of spawn.
   - Why: children need to learn the town in one visit; homely means small and lived-in.
   - Today: a 300 by 300 green slab with all seven buildings facing a 186-stud plaza and no streets. Every building looks the same.
3. **Arrive, see the goal, see the way out.** At spawn the player faces the rival, the mentor's door and a far landmark. Then one clear exit leads to the first route.
   - Why: it is the "weenie" pull, and it is the classic opening.
   - Today: the spawn faces nowhere in particular, and the giant is a 20 by 40 block that cannot be seen from town.
4. **Routes bend and have edges.** A route is a corridor between hedges, water and tree walls. It widens at meadows, and each bend hides what comes next.
   - Why: bends make discovery; edges make a route instead of a lawn.
   - Today: an ±18° zigzag across open ground, with nothing funnelling and every tree you can walk through.
5. **Long grass looks like grass, is a choice, and matches the server exactly.**
   - Why: a grass ambush must feel fair. What you see must be exactly the circle the server checks (`GRASS_RADIUS` 20, no slack).
   - Today: a green see-through slab with a "Long grass" label, always 40 studs off the path.
6. **Tamers are seen coming.** Each one faces the way players arrive, at a bend or a narrow point, never inside grass, with room to pass, and with prompts that never overlap another prompt.
   - Today: pinned 9 studs to one side by formula, all facing +z.
7. **Services by the way in.** The healer and shop sit side by side on the main street, near the exit to the route players come back from. Waking after a loss lands on the healer's forecourt.
   - Today: the healer is third in the list, so it lands wherever the circle puts it.
8. **Water and landmarks tell you where you are.**
   - A brook runs from the end of Route A down through town to a pond.
   - A river runs beside Route B.
   - One giant tree over the lair can be seen from town and from the meadow.
   - Today: there is no water and no landmark.
9. **Show the future, block it honestly.** The sealed road, the lair shortcut and the spring beyond Route A's old fence are all visible, fenced and signposted.
   - Today: the sealed road is a grey slab anyone can walk along.
10. **Short walks, quick ways home.** The town takes 5 to 13 seconds, Route A 25 and Route B 38. Each stretch takes 8 to 12 seconds. There is a way home that avoids grass (a ledge on Route B; the Waystation).
    - Today: the distances are about right, but there is no shortcut and nothing to tell stretches apart.

## 2. The design for Greenwood

### 2a. The whole biome

The sketch is about 20 studs per character across and 40 studs per line down. It is approximate: the coordinate tables in section 3 are what counts.

```
          -400      -200        0         200       400       600       800   x
z-360                                  .--L---.             L  ancient tree (landmark, 160 tall)
z-320                                  ( lair )             Hollowbough's Hollow, arena r75
z-280                                  ( arena)
z-240                                  '------':            :  lair spur (250)
z-200          @                    ..         :            @  spring and little waterfall (seen, not reached)
z-160        x~      ############w##.           :           x  old fence: end of Route A
z-120     2r~        #             #             S    g5   g h      S stall   w shut wicket (shortcut)
z -80   g = ~        #  W   M   B  #           /====r=========G>>>>>> sealed road to Dust Canyon
z -40      =   ~~~~~~#   N         #   g    p4/g             h      G gatehouse   h hamlet cottages
z   0      =meadow===A======P======A=====3===          (Route B: River Road)
z  40       g===1g    #~  +   $    R  #  ~~r~~~~~~                  + healer  $ shop  R ring
z  80                 #  o         #~        ~~     river           o pond   P plaza and spawn
z 120                 #            ~                                N notice oak  W waystation
z 160                 ##########~###                                M mentor  B breeder
Route A: Clover Lane (west, a hook).  1 Pip  2 Wren  3 Odette  4 Basil  5 Corwin
g long grass   r rustle spot   p birch side pocket   ~ brook and river   A town arches
```

- **Thistledown (home town):** centre (0, 0); bounds stay 300 by 300; built area about 200 by 175.
- **Route A, "Clover Lane" (400):** leaves west over the brook footbridge. It curls south-west round a mossy knoll into the wide clover meadow, then hooks north and north-east up the brook to the old fence.
- **Route B, "River Road" (600):** leaves east, follows the river's north bank, and climbs the birch rise north-east. It passes into the old wood (the lair spur forks north-west at 330), then runs east on a stone lane through the gatehouse hamlet to the gate. The sealed road carries on east.

Walking times at 16 studs a second:

| Walk | Studs | Seconds |
| --- | --- | --- |
| Spawn to the mentor's door | 78 | 5 |
| Mentor's door to the west arch | 214 | 13 |
| Healer's door to the west arch | 115 | 7 |
| Square to Pip | 250 | 16 |
| Whole of Route A | 400 | 25 |
| Whole of Route B | 600 | 38 |
| Square to the gate | 750 | 47 |
| Square to the lair | 730 | 46 |

### 2b. Thistledown

The sketch is 5 studs per character across and 10 studs per line down; the tables in section 3 are what counts.

```
      x -150      -100       -50         0         50        100       150
z-150 ####################################################w########   w shut wicket (lair shortcut)
z-140 #  ^  ^  ^  ^  ^  ^  ^                  ^  ^  ^  ^  . ^  ^  #   ^ pines (north belt)
z-130 # ^  ^  ^  ^  ^  ^  ^       T   T    T   ^  ^  ^   .s  ^  ^ #   T orchard trees
z-120 #                            T                    .         #   s signpost
z-110 #                        T        T             .           #
z-100 #                          +-----+ :::::       .            #   ::::: mentor's vegetable patch
z -90 #                          |MENTOR| :::::   xxxxxxxxxx      #   x picket fence (breeder yard)
z -80 #           +---+          | (1) | :g:::   +----+ x  e  e x  #   g gardener (dressing)
z -70 #           |WAY|          +--v--+         |BRD | x  e    x  #   e eggs in straw nests
z -60 #           |STN|             m            | (5)| x coop   x  #   m mentor at the door
z -50 #           +--vk           *=|=*         k-v---+ x       x  #   k keeper at a door
z -40 #               .           f | f        .        xxxxgxxxx #   f flower bed   * lamp
z -30 #             OOOOOOO     s ..|.. *       .                  #
z -20 #            OOONOOOO*  .    R    . *    .                   #   R rival (first battle)
z -10 #~ s  *      OOOOOOOk  .   (plaza)   .  .      *        s    #   N notice oak, board on east face
z   0 A=BBB==============   ...    P    ...   ============*======A  A arch   BBB footbridge
z  10 # ~      *        *  .     @   u   .     *        *          #   @ spawn (faces north)  u well
z  20 #  ~                  *  ..     ..  *                        #
z  30 #   ~         f k f    f M f  f    f        k                #   M Marlow at the shop door
z  40 #    ~        +---+   +----+               .-----.           #
z  50 #     ~       | + |   | $  |              (  RING )          #   + Brightwater House (healer)
z  60 #      ~      +---+   +----+               '-----'           #   $ Tuppence's Shop
z  70 #       ~  ======                                       T    #
z  80 #     .~~~~~~.  c                                       ~    #   c child by the pond (dressing)
z  90 #   T( pond  )                                    T   ~      #   pond r22, jetty from the north
z 100 #     '~~~~~'                                       ~        #
z 110 #  T             T                             T  ~          #
z 120 #                                                ~           #   river crosses the south-east corner
z 130 #  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ~  ^  ^     #
z 150 ############################################~################
```

**What the player sees first.** They spawn at (0, 14) facing north.
- Twenty studs ahead stands the rival in the cobbled plaza.
- Beyond him a flower-lined lane with two lamps runs to the mentor's thatched cottage, with an orchard behind.
- The Waystation's tall roof frames the left of the view and the breeder's orange roof frames the right.
- Above the right-hand roofs, about 41° right of north, the crown of the ancient tree stands in the haze. It is 440 studs away and 160 studs tall, so it rises about 20° above the horizon, higher than the breeder's roof.

**What draws them to Route A.** It is the brighter way out: lamps on the main street lead west to a painted arch, then the humpbacked footbridge over the brook, then yellow clover past the first bend. The signpost says "Route A · Clover Lane". The east road is narrower and leads into darker trees, and its signpost says "River Road · to the Gatehouse".

**What they can see but not reach yet:**
- The ancient tree over the lair: the north-east wicket is shut, with the sign "The Hollow path. Shut."
- The spring and waterfall beyond Route A's old fence.
- The gatehouse banner and the barred sealed road at the far end of Route B.
- The skyline of Dust Canyon beyond it.

**The story order still works:**

| Beat | What it needs | Where it is now |
| --- | --- | --- |
| `starter_choice` | Nothing | |
| `rival_challenge` | The rival | Stands 6 studs from the hub place (0, 0) |
| `rival_parting` | Nothing | |
| `lasso_lesson` | Nothing | |
| `route_one` | Enter `greenwood_route_a` | Point 30 along Route A, about (-179, 6); 117 studs from the nearest town door |
| `first_tamer` | Beat `gw_pip` | Pip at (-247, 27) |
| `giant_glimpse` | Sight `clover_meadow` | About (-330, 9); the tree is in view from there |
| `mentor_egg` | Talk to `mentor` | (0, -64) |
| `third_creature` | Tame anything | |
| `first_quest` | Talk to `marlow_tuppence` | (-26, 32) |
| `gate_challenge` | Enter `greenwood_gate` | (684, -80) |
| `badge_and_token` | Beat `rival_gate` | Rival stands 8 studs from the gate |
| `sealed_path` | Enter `greenwood_sealed_path` | (744, -80) |

Every id that `Layout` makes today still exists; only its spot moves.

## 3. Coordinate tables

### Routes as waypoints

These are the author's waypoints. Layout fits each line to the exact length in the data by trimming or stretching the last leg.

| Route | Waypoints (x, z) | Leg sum | Fitted to |
| --- | --- | --- | --- |
| Route A (`greenwood_route_a`) | (-150,0) (-200,10) (-250,40) (-290,40) (-330,10) (-350,-40) (-340,-100) (-300,-140) (-279,-161) | 400.3 | 400; end (-279.2,-160.8) |
| Route B (`greenwood_route_b`) | (150,0) (200,15) (260,30) (310,20) (350,-20) (380,-70) (420,-100) (480,-110) (530,-90) (580,-80) (640,-80) (684,-80) | 599.6 | 600; end (684.4,-80) |
| Lair spur (`greenwood_lair`) | (420,-100) (380,-170) (330,-230) (270,-300) | 250.9 | 250; arena (270.6,-299.3) |

Corridor half-widths (hedge or tree line each side), by stretch:

| Stretch | Half-width |
| --- | --- |
| `mossy_glade` | 50 |
| `clover_meadow` | 70 |
| `brook_bend` | 50 |
| `sandy_bank` | 55 |
| `birch_rise` | 45 |
| `old_wood` | 50 |
| `gatehouse_approach` | 70 |
| Lair spur | 30 |

### Places the server checks

Points marked "computed" are left to Layout; the others are set in the map data.

| Id | x, z | How |
| --- | --- | --- |
| `greenwood_hub` | 0, 0 | Computed |
| `greenwood_route_a` (entry) | -179.4, 5.9 | Computed: 30 along |
| `mossy_glade` | -212, 17 | Computed: 65 along |
| `clover_meadow` | -330, 9 | Computed: 200 along |
| `brook_bend` | -325, -115 | Computed: 335 along |
| `greenwood_route_b` (entry) | 178.7, 8.6 | Computed |
| `sandy_bank` | 222, 20 | Computed: 75 along |
| `birch_rise` | 359.5, -35.8 | Computed: 240 along |
| `old_wood` | 493, -105 | Computed: 405 along |
| `gatehouse_approach` | 624, -80 | Computed: 540 along |
| `mossy_glade_grass` (r20) | -208, 43 | Set: beside the lane, south; edge touches the lane |
| `clover_meadow_grass` | -311, 25 | Set: across the lane; a mown footpath skirts it |
| `brook_bend_grass` | -368, -90 | Set: beside, west |
| `sandy_bank_grass` | 214, -8 | Set: beside, north |
| `birch_rise_grass` | 365, -44 | Set: across the lane (the ledge skips it on the way home) |
| `old_wood_grass` | 507, -127 | Set: beside, north |
| `gatehouse_approach_grass` | 604, -104 | Set: beside, north |
| `reed_bed` | -283, -122 | Set: on the brook's edge |
| `heron_pool` | 231, 48 | Set: on the bank of the river inlet |
| `burl_thicket` | 480, -84 | Set: south of the lane |
| `gw_pip` | -247, 27 | Set: faces 60, back towards town |
| `gw_wren` | -322, -105 | Set: faces 225 |
| `gw_odette` | 258, 20 | Set: faces 250 |
| `gw_basil` | 342, -25 | Set: faces 225 |
| `gw_corwin` | 529, -100 | Set: faces 250; the pinch point |
| `greenwood_gate` | 684.4, -80 | Computed: end of Route B |
| `greenwood_sealed_path` | 744.4, -80 | Computed: 60 past the gate, due east |
| `greenwood_lair` | 270.6, -299.3 | Computed: end of the spur |
| `greenwood_lair_stall` | 400.2, -134.7 | Computed: 40 up the spur |

### Buildings and keepers

The keeper's spot is the building's door place: the server's talk point and the "building" place.

| Building id | Model | Middle | Faces | Door / keeper | Size |
| --- | --- | --- | --- | --- | --- |
| `mentor_cottage` | Cottage | 0, -82 | 180 | 0, -64 (`mentor`, Mentor model) | 26×27 |
| `shop` | Shop | -26, 46 | 0 | -26, 32 (`marlow_tuppence`, Shopkeeper) | 22×17 |
| `healer` | Healer | -64, 46 | 0 | -64, 31 (keeper, Carer model, new) | 18×19 |
| `waystation` | Waystation (new) | -80, -62 | 135 | -68.7, -50.7 | 20×20, 40 tall |
| `breeder` | Cottage, orange roof | 82, -64 | 225 | 69.3, -51.3 (Grandmother, new) | 26×27 |
| `notice_oak` | Tree ×2.2 plus NoticeBoard (new) | -50, -14 | 90 | -36, -14 | trunk d5, crown 30 |
| `ring` | Primitives: oval rail and benches | 78, 58 | 315 | 62, 42 | oval 40×30, sand floor |

### People who are not keepers

| Who | x, z | Faces | Notes |
| --- | --- | --- | --- |
| Spawn | 0, 14 | 0 | SpawnLocation turned to face north |
| Rival, first battle (`rival_first`) | 0, -6 | 180 | Must be within 8 of its place (0, 0) |
| Rival, gate battle (`rival_gate`) | 676, -80 | 270 | Inside the gatehouse arch |
| Child (dressing only) | -80, 74 | 225 | GirlTamer model |
| Gardener (dressing only) | 28, -88 | 270 | Tamer model |

Prompt spacing: every talk or battle prompt is at least 32 studs from every other. The closest pairs are:
- Rival to the notice oak: 36.9
- Shop to healer: 38
- Wren to the reed bed: 42.5

### Town paths, water and structures

| Thing | Where | Build |
| --- | --- | --- |
| Main street | (-150,0) to (150,0) | 16 wide, cobble |
| North lane | (0,-28) to (0,-64) | 10 wide, cobble |
| Side paths | Healer (-64,8)→(-64,31); shop (-26,8)→(-26,32); waystation (-56,-8)→(-68.7,-50.7); breeder (56,-8)→(69.3,-51.3); ring (48,8)→(62,42) | 8 wide, dirt |
| Stepping stones | Plaza (-24,-8) to the notice oak (-36,-14); healer (-70,38) to the pond (-90,62) | |
| Jetty | (-96,62) to (-96,76) | 4 wide, planks |
| Plaza | (0,0) | Disc d56, rim d60 |
| Well | 18, 12 | Well model, 10 tall |
| Brook (10 wide) | (-235,-205) spring pool d16, (-255,-150), (-290,-110), (-292,-60), (-265,-25), (-215,-28), (-165,-18), (-150,-10), (-128,0) footbridge, (-118,40), (-104,70), then into the pond | |
| Pond | (-96,92), r22 | Reeds round the south half; 5 lily pads |
| River (24 wide) | (440,140), (360,75), (300,62), (240,60), (190,55), (160,72), (140,120), (125,220) | Heron inlet at (231,50), r9 |
| Footbridge | (-128,0), faces 90 | 20 long, 12 wide |
| Arches | West (-142,0) faces 270 ("Thistledown" outside, "Route A · Clover Lane" inside); east (142,0) faces 90 | |
| Signposts | See below | |
| Lamps (Lamp, 13 tall) | Street (-120,-11) (-90,11) (-46,11) (46,-11) (90,11) (120,-11); plaza (±22,±22); north lane (-7,-46) (7,-46); arches (±142,±11) | 18 in all |
| Flower beds | Healer (-72,30) (-56,30); shop (-34,30) (-18,30); plaza (±11.6,-32) (±11.6,32); mentor lane (±7,-56) | |
| Tree clumps | See below | |
| Fences | See below | |

Signposts:
- SP1 (-136,-12), faces 270: "← Route A · Clover Lane"
- SP2 (136,-12), faces 90: "River Road · Gatehouse →"
- SP3 (-10,-30), faces 180: "↑ Mentor's Cottage · ↓ Brightwater House, Tuppence's Shop"
- SP4 (104,-142): "The Hollow path. Shut."
- SP5 (-190,30), faces 60: "Long grass: wild creatures hide here"
- SP6 (428,-118), faces 225: "Hollowbough's Hollow · Hollow Stall"
- SP7 (600,-66), faces 270: "Greenwood Gatehouse · badge challenge"

Tree clumps:
- **Orchard:** Trees at (-24,-112) (0,-118) (24,-112) (-12,-130) (12,-130) (36,-128).
- **North belt:** Pines along z -140 and z -125, every 14 studs, from x -150 to -40 and 40 to 150, with a gap at x 104 to 116.
- **South belt:** Pines along z 135 and z 148, from x -60 to 110, stopping at the river.
- **Pond:** Trees at (-130,100) (-122,124) (-70,112).
- **West:** Trees at (-100,-30) (-112,-48).
- **Breeder yard:** Trees at (110,-100) (132,-104).
- **Ring:** Trees at (110,90) (100,120).

Fences and edges:
- **Breeder yard:** white picket on the rectangle (98,-90) (138,-90) (138,-40) (98,-40), gate gap at x 112 to 120 on the south side. Inside: a hen coop and straw nests with eggs.
- **Mentor's vegetable patch:** white picket on (18,-100) (40,-100) (40,-74) (18,-74), gap on the west side.
- **The Ring:** an oval rail with benches.
- **Town boundary:** a hedge loop at ±150. It has gaps at the two arches (z ±14), the wicket (x 104 to 116, a closed gate) and where the brook and river cross (a low rail over the water).

### Route dressing

| Thing | Where |
| --- | --- |
| Mossy knoll | (-238,-2), 22×7×16, inside the glade bend |
| Meadow footpath round the grass | (-286,46) (-306,60) (-332,44) (-337,18), rustic rails on both sides |
| Picnic hollow | (-390,40): ring of 5 Trees and a bench |
| Old fence across the end of Route A | (-294.6,-176.6) to (-263.4,-145.4), with a broken stile in the middle |
| Sand strip | South of Route B, from along 0 to 150, between the lane and the river |
| Birch Rise | Birch trees; side pocket clearing at (318,-78), r22, through a gap at along 240 |
| Old wood | Darker ground; Tree models scaled 1.3 |
| Gatehouse hamlet | Cottages at (645,-130) facing 180 and (650,-36) facing 0; lamps (590,-66) (640,-94) (664,-66); low stone wall along the lane from along 560 to 600 |
| Gatehouse | (684,-80), faces 270 |
| Sealed-road bar | (706,-80), 20 wide |
| Stone road east | To (744,-80) and beyond |
| Lair | Clearing disc r75 at (270.6,-299.3); ancient tree at (270,-362); the giant sleeper stays at the arena centre |
| Shortcut (shut) | (215,-250) (160,-195) (110,-150), 8 wide, overgrown, with bramble bushes across it at (180,-215) |
| Optional Birch Rise terrace | 9 studs high, from along 190 to 300; ramp up from along 160 to 190, ramp down from along 300 to 325; the south edge of the stretch from along 221 to 280 is a one-way ledge down to the river bank |

Ground colours (RGB):

| Ground | Colour |
| --- | --- |
| Town green | 138,196,104 |
| Meadow | 150,204,110 |
| Glade moss | 118,176,92 |
| Sand | 232,214,160 |
| Birch Rise | 140,190,100 |
| Old wood | 88,132,70 |
| Arena | 120,96,66 |
| Dirt lane | 204,180,128 |
| Cobble | 222,204,168 |
| Stone lane | 186,180,168 |
| Under long grass | 78,128,58 |
| Brook | 110,182,214 |
| River | 86,160,204 |
| Pond | 100,176,210 |

## 4. How to build it with the least risk

**Choice: (a), with a separate map sheet.** `Layout.luau` stays the one source of truth. A data file per biome, the map sheet, gives:
- waypoints for routes and the spur;
- set spots, doors and facings for buildings;
- spots that override the generated ones, by place id;
- where story battlers stand;
- the spawn;
- corridor half-widths.

Why this is safer than the other choices:
- Rewriting the gameplay data (`from`/`to`/`at` distances) would change spawn tables.
- Hand-placed markers in Studio would give the server two sources of truth and nothing to test.

Why it is safe in practice:
- The gameplay data is untouched; `along` distances keep their meaning, because each line is fitted to the length in the data.
- Biomes without a sheet keep the generated layout, so the Dust Canyon, Tide Flats and Mire tests do not change.
- The server's position checks (`isNear`, grass, rustle, engage) still read `map.places`. They now read designed points, and new tests prove those points are sane.

`Layout.pointAt` already walks a list of points of any length, and `routeLine` already returns `points`. Only the source of the points changes.

### Logic steps (do first; `lune run check` must pass after each)

1. **`src/shared/WorldTypes.luau`.** Add:
   ```luau
   export type SheetPoint = { x: number, z: number }
   export type SheetBuilding = { at: SheetPoint, faces: number, door: SheetPoint?, model: string? }
   export type MapSheet = {
     routes: { [string]: { points: { SheetPoint } } },
     corridor: { [string]: number }?,   -- half-width by area id (and lair id for the spur)
     spurs: { [string]: { SheetPoint } }?, -- by lair id: from the join to the arena
     buildings: { [string]: SheetBuilding },
     places: { [string]: SheetPoint },  -- overrides by place id
     stands: { [string]: SheetPoint }?,  -- story battle id -> where the battler stands
     faces: { [string]: number }?,      -- tamer or battle id -> facing
     spawn: { at: SheetPoint, faces: number }?,
   }
   ```
   Add `map: MapSheet?` to `Biome`. All points are relative to the hub's centre.
2. **`src/content/map_data/Greenwood.luau` (new).** The tables in section 3, as data.
3. **`src/content/biome_data/Greenwood.luau`.** Add `map = require("../map_data/Greenwood")`. Nothing else changes: lengths, areas, `at`s, `joinsAt`, `spurLength` and `size` 300 all stay.
4. **`src/shared/Layout.luau`:**
   - Add `Layout.fit(points, length): { Point }`. It cuts inside the leg where the length runs out, or stretches the last leg. Export it for tests.
   - Add `Layout.facing(degrees): Point`, returning (sin, -cos).
   - `routeLine`: if `sheet.routes[route.id]` exists, use its points shifted by `origin` and fitted to `route.length`. Otherwise keep today's code.
   - Buildings: if `sheet.buildings[id]` exists, `map.buildings[id] = origin + at`, and the door is `door` if given, else `at + facing(faces) * DOOR_DISTANCE`. Otherwise keep the ring.
   - Lair: if `sheet.spurs[lair.id]` exists, the spur is `{join}` plus the shifted points, fitted to `spurLength`. Then `map.lairSpur` is the whole polyline, the lair is its last point, and the stall is `pointAt(spurLine, STALL_DISTANCE)`.
   - Gate and sealed road: unchanged, worked out from the fitted line.
   - Last of all, apply `sheet.places` for ids already in `map.places` only. Unknown ids are left for the test to catch.
   - Add new `Map` fields: `faces`, `stands`, `models`, `spawn`. Add `halfWidth` (by area) on `RouteLine`. `Layout.world` merges `faces`, `stands` and `models` like `places`.
   - Untouched: `distance`, `pointAt`, `isNear`, `biomeAt`, `grassId`, `stallId`, and how the next biome is sited.
5. **`tests/encounters.test.luau`:**
   - "Route A runs west…" becomes `pointAt(a,400).x < -200 and pointAt(b,600).x > 400`.
   - "Distance along the path is real distance": measure inside one leg, for example along 120 to 145 of Route A, and add "leg lengths sum to `route.length`".
   - "The lair is its spur's length off the route": sum the spur polyline instead.
   - In the second-biome test, set `second.map = nil` after `table.clone`.
6. **`tests/layout.test.luau` (new):**
   - Every sheet id (routes, buildings, places, stands, spurs, corridor keys) is a real id.
   - Each route's unfitted waypoints sum to within 5 studs of its data length.
   - Every Chapter 1 trigger target, local tamer and story battle has a place.
   - No two prompt points are within 32 studs: keeper doors, tamers, rustle spots, the stall, story stands.
   - Each story stand is within `POSITION_SLACK` (8) of its place, so any spot where its prompt shows is accepted by the server.
   - Each grass patch's along-distance lies inside its area's `from` to `to`. No patch overlaps another, the town square, or a tamer.
   - Each tamer is within 12 of its route and within 40 of its `at`.
   - Each rustle spot is within 30 of its route.
   - Every route place, grass edge included, is inside its corridor half-width.
   - Buildings sit inside the hub and their footprints (r14) do not overlap.
   - The Route A entry point is more than 48 studs from every town door.
   - Every Greenwood place is more than 100 studs from every Dust Canyon place in `Layout.world`.
7. **Run `lune run check`.** At this point the test map already moves buildings, people, grass and paths to the new spots with today's dressing. Play it once in Studio before dressing it.

### Dressing steps (server look only; no position the server checks changes)

8. **`src/content/map_data/GreenwoodDressing.luau` (new).** Water polylines, the pond, arches, signposts, lamps, beds, tree clumps, fences, hedge overrides, hamlet cottages, the ancient tree, the shortcut, ground patches and the optional terrace, all from section 3. Add a check to `tests/layout.test.luau`: no fence, hedge, wall or building comes within 6 studs of a prompt point, and none crosses a lane except at a gap.
9. **`src/server/World/Dressing.luau`.** New functions:
   - `water(points, width, colour)`
   - `pond(centre, r)`
   - `longGrass(centre, r)`
   - `fence(points, style)`
   - `hedge(points)`
   - `arch(at, faces, text)`
   - `signpost(at, faces, lines)`
   - `stones(a, b)`
   - `corridor(line, halfWidths)`, edge planting that replaces `scatter` when a sheet exists
   - `ground(patches)`

   Also:
   - `square` takes the plaza size from the data (56), not `size*0.62`.
   - `house` takes the model name from `map.models`.
   - `person` keeps its facing.
10. **`src/server/World/TestMap.luau`:**
    - Lanes become 14 wide (16 in town) with a disc of the same diameter at every waypoint to hide joins; the 44-wide slabs go.
    - Long grass comes from `Dressing.longGrass` instead of the slab.
    - Story battlers stand at `map.stands`, not +14,-14.
    - The spawn takes `map.spawn`.
    - The lair spur loops over every point of `lairSpur`.
    - The gate uses the Gatehouse model.
    - People and signs take their height from a downward raycast, so they still stand on the ground if the terrace is built.
    - **Keep every ProximityPrompt and its attributes (PromptKind, PromptId, Place, Role, Biome) exactly as now.**
11. **`src/content/PropModels.luau`.** Add the ids of the new models below once they are generated, then log them in `docs/ASSETS.md`.
12. **Optional, last:**
    - The Birch Rise terrace and its one-way ledge.
    - Tufts that sway on the client as the player walks through.
    - A client-side bar on the sealed road, removed when the player has the badge. It only looks shut: the server already refuses biome 2 until the badge (`mayEnter`).

## 5. Dressing detail

- **Pond.** A cylinder part d44, 0.4 thick, top at y 0.25, colour 100,176,210, SmoothPlastic, CanCollide false, with a darker cylinder d40 just under it (70,140,180) for depth. A bank ring d48 at y 0.15 (150,130,100). Eight grey lumps (2 to 5 studs) round the edge, collidable. Reeds on the south half, 5 lily pads (cylinders d3, 0.2 thick, 90,160,80) with one pink bloom. The planked jetty from the north, with a bench beside it.
- **Brook and river.** A chain of slabs 0.3 thick along the polyline, with a cylinder of the same diameter at each joint. A bank strip 1.5 wide each side (150,130,100), and flat stones every 8 to 12 studs. Not collidable. Where water passes under a hedge, the hedge stops 2 studs short on each side and a low rail crosses the water.
- **Fence run.**
  - Painted FenceSection (8 studs) end to end, turned along each leg.
  - Fallback picket: posts 0.8×4×0.8 every 6 studs, two rails 0.4×0.5 at y 1.5 and 3, white 244,236,220.
  - Rustic: posts every 8 studs, two rails, 140,105,70.
  - Collidable; segments at most 40 long, so the battle scene can hide them.
- **Hedge (route edges).** Blocks 6 tall, 4 thick, 30 to 40 long (70,130,60), collidable, with Bush models along the top every 4 studs. Trees go 4 to 10 studs outside, every 12 to 16 studs, mixing Tree and Pine (Birch on Birch Rise).
- **Stepping stones.** Grey flat cylinders d3.5, 0.4 thick (178,172,160), every 3.2 studs with ±0.6 jitter and random turn.
- **Long grass that looks like grass:**
  - The ground disc is exactly the server's circle: d40, 0.1 thick (78,128,58).
  - GrassTuft models on a jittered hex grid with 3.6 spacing, kept within r18.5: about 95 a patch, scale 0.85 to 1.15, random turn, alternating light and dark versions.
  - Tufts are not collidable, cannot be queried and cast no shadow.
  - Fallback: three WedgeParts 0.4×3.6×1.2 fanned at 0/60/120° and tilted 8°, in 84,158,66 and 104,178,74.
  - No label, except the teaching signpost by the first patch.
- **Town arch.** Two timber posts 2×14×2 (120,84,56), 18 apart. A crossbeam 22×2×2 at y 14, a pair of small roof wedges in green, and a cream board 12×3×0.5 (244,232,208) with SurfaceGui text in the kit's pixel font. A flower box at each foot and a lamp each side. Short funnel hedges angle out 30 studs on each side.
- **Gatehouse fallback.** Two stone towers 12×30×12 (170,165,150), 26 apart. An arch beam 40×8×12 at y 26 with a timber room on top, and a red banner 6×12×0.3 (206,88,72) with "Acorn Badge" text.
- **Signpost.** A post 0.8×7×0.8 in timber, with arrow boards 6×1.4×0.3 in cream, each with a wedge point and SurfaceGui text. Prefer the Signpost model.

### New painted models to generate

All are in the existing clay-toy style: chunky, hand-painted clay, soft rounded edges, flat warm colours, no fine detail, readable from far away. Each stands on a flat base with its front facing -z.

1. **Waystation.** A tall round dovecote tower of pale cream stone with a pointed slate-blue cone roof and a small bronze bell under the eaves. Round pigeon holes ring the top, a wooden door with a lantern faces front, and a weathervane shaped like a bird sits on top. It should be the tallest roof in a cosy village.
2. **Gatehouse.** A sturdy stone archway between two short round towers with red-tiled cone roofs. A timber-framed room spans the arch, with a red banner showing a golden acorn. The road passes through the arch, which has iron studs on open wooden doors. It is grand but friendly, like a toy fort.
3. **AncientTree.** An enormous ancient tree with a thick twisted trunk, huge gnarled roots like arches, and a broad dome of deep green leaves with a few golden patches. A hollow at the base is big enough to walk into, and moss covers the bark. Built to be seen from far away as a silhouette.
4. **Birch.** A slim white birch tree with dark bark flecks and a light, airy, rounded crown of yellow-green leaves. Two trunks grow from one base.
5. **GrassTuft.** A clump of long wild grass about knee height to a child: a dozen thick rounded blades in two greens, slightly bent and leaning out, with one or two seed heads. Made for planting in dense patches.
6. **Reeds.** A clump of tall reeds with round brown cattail tops and a few flat leaves, on a muddy base.
7. **FenceSection.** One 8-stud section of white picket fence: rounded pickets with pointed tops, two rails and a post at each end, slightly wonky and hand-made.
8. **Signpost.** A wooden signpost with a rounded top cap and two blank cream arrow boards pointing opposite ways, with nail heads showing.
9. **Footbridge.** A small humpbacked wooden footbridge with plank decking, rounded handrails and stone footings at each end, sized for a stream.
10. **NoticeBoard.** A small wooden notice board with a little shingle roof, pinned with three paper notes and a lantern hanging at one side.
11. **Bench.** A plain wooden park bench with curved iron arms.
12. **Stall.** A market stall with a striped green and cream awning, a wooden counter, jars of tonic and a coiled horn on display.
13. **Villagers referenced in code but missing:**
    - **Carer:** a kind nurse in a teal apron with a water jug.
    - **Grandmother:** an old woman with a shawl and a basket of eggs.
    - **GirlTamer:** a girl in a yellow raincoat with a rope coil.

## 6. Risks and what to check in Studio

**Risks:**
- **The fit stretches a shape badly.** Covered by the ±5 test.
- **A grass patch looks different from where an ambush can happen.** Both come from the same place and `GRASS_RADIUS`; tufts stop at 18.5.
- **Prompts overlap, or the server refuses the rival at the edge of its prompt.** Both are covered by tests.
- **Dust Canyon moves.** Its centre is now (984, -80); before it was about (1005, ±70). Covered by the separation test.
- **Hedges trap creatures or players.** Creatures appear at most 18 studs to the side, and every corridor is at least 45 half-wide.
- **Water and creatures.** The brook is at least 28 studs from the lane and the river 26.
- **Hedges stay in the battle scene.** The battle scene hides parts at least 1.5 tall and under 100 wide near the pads, so hedge segments must stay at 40 or under.
- **Phone frame rate.** About 670 tufts, about 300 trees and the hedges. Identical meshes should be drawn in batches; measure it.
- **The terrace.** People must take their height from a raycast, and the ledge must be above jump height.
- **Other biomes.** They still use the generated layout (out of scope).

**Check in Studio:**
- The character spawns facing north. The rival, the mentor's door and the ancient tree are all on a phone screen.
- The ancient tree shows from the clover meadow (about 700 studs). If not, make it taller or lower the Atmosphere density.
- Walk times match section 2.
- Waking after a loss lands on the healer's forecourt at about (-59, 28).
- Each prompt shows alone.
- Grass ambushes start only on the dark disc.
- The `route_one` beat fires just past the footbridge, not in town.
- `giant_glimpse` fires in the meadow.
- The rival's gate prompt works inside the arch.
- `sealed_path` does not fire until the bar.
- The default JumpPower cannot climb a 9-stud ledge.
- No creature appears inside a hedge or on water.
- Draw calls and frame rate in a phone-sized view.
- Screenshots of the town from spawn, Route A's first bend and the gate, compared with the brief's art direction.

## 7. For Ayrton

- **No second town.** The "bigger town with a gym gate" is a dressed hamlet with no services. A healer at the gate needs `BattleFlow`'s wake-up loop changed first (it visits every Healer and the last one wins).
- **Route B is open from the start.** Nothing in the world stops a player walking it before `first_quest`.
- **The lair shortcut stays shut.** `shortcutToHub` is not read anywhere in code.

### Critical files for implementation
- C:\Users\will\Documents\creature-game\src\shared\Layout.luau
- C:\Users\will\Documents\creature-game\src\shared\WorldTypes.luau
- C:\Users\will\Documents\creature-game\src\content\biome_data\Greenwood.luau (plus the new src\content\map_data\Greenwood.luau and GreenwoodDressing.luau)
- C:\Users\will\Documents\creature-game\src\server\World\TestMap.luau and Dressing.luau
- C:\Users\will\Documents\creature-game\tests\encounters.test.luau (plus the new tests\layout.test.luau)
