# 13 · World design: one journey, eleven biomes, a picturesque world round a spiral

Ayrton approved the spiral (`docs/plans/12_world_scaffold.jpg`) and asked: "use map techniques to make it feel adaptive etc, make it feel like you are actually moving. It shouldn't feel like a plain small loop, also provide other areas around the map like side areas of different biomes, mountains etc. Try and make a picturesque game."

Plan 12 shapes each route: walls, tiers, ledges, switchbacks, and grass beside the path that you can always walk round (Ayrton, 23 November 2026). This plan works at the scale of the whole world:
- where each biome sits;
- how you cross from one to the next;
- what you see far off;
- how the light and sound change as you go;
- the side areas, mountains, lakes, sea and islands round the path.

Status: a plan. Nothing here is built. All of it is [Default] unless marked, apart from the biome lineup and order, which are [Locked] (brief section 8). Names are placeholders, and the town names for biomes 5 to 11 are [Open].

Conventions are as in plans 08 and 12:
- Studs, world coordinates, Greenwood's town centre at (0, 0).
- North is -z, and y is up.
- Walking speed is 16 studs a second.
- "Base" is a biome's tier-0 height above sea level (y 0). Plan 12's tiers (steps of 10) stack on top of it.

Contents:
1. Research: techniques
2. Principles
3. The world layout
4. The main path and its thresholds
5. Transition zones
6. Landmarks and sightlines
7. Elevation profile
8. Side areas, shortcuts and the frame
9. Light, sky, weather and sound
10. Phone performance
11. Server rules and data
12. Build order
13. For Ayrton
14. Sources

---

## 1. Research: what makes a journey felt and a world picturesque

Sources are listed in section 14. Several Fandom, Bulbapedia and GDC Vault pages were read only through search snippets or secondary summaries, and are marked as such.

### 1a. Landmarks you walk towards: the "weenie"

- **Disney's weenie.** Walt Disney's name for a tall object that pulls visitors through a space. The castle at the end of Main Street is one for the whole park, and smaller ones (Space Mountain's cone) work inside each land. It works for wayfinding as well as pull: you always know which way you face. (Theory of Theme Parks blog, citing Kevin Lynch; Theme Park Tourist.)
- **Lynch's five elements.** Paths, edges, districts, nodes and landmarks, from *The Image of the City* (1960). Game designers use them widely. A study of open-world players found landmarks and edges were the two elements players actually used to describe worlds, plus a new one: characters. (Wellesley "Image of the Open World Game"; Game Developer, "Realism and legibility in open world level design".)
- **Landmarks need places.** In Hyrule, "landmarks lend importance to nodes, but nodes give meaning to landmarks". (Game Developer.)
  - *For us:* every biome has one landmark, with a place at its foot: the lair, a lookout, a side area.
  - A few world landmarks (the Crown, the tear) are seen from everywhere and give a lasting sense of direction.
- **Journey.** One mountain stays on the horizon from the first scene to the last chapter. The palette changes along a planned colour curve that follows the story. (Computer Graphics World on Journey's art; Ringer and Game Developer retrospectives.)
  - *For us:* the Crown is our mountain. Each biome's preset (section 9) is a point on one planned curve: warm, then bright, then misty, then cold, then deep, then hot, then high, then twilight, then night, then ember.

### 1b. Hide and reveal: the triangle rule, gravity and bending paths

Nintendo's CEDEC 2017 talks on *Breath of the Wild* (read through Robert Yang's summary of Matt Walker's translation, and Gigazine and GamingBolt write-ups):
- **Triangles.** The world is built from triangle-shaped hills and mountains at three scales:
  - large ones are landmarks;
  - medium ones screen landmarks and routes;
  - small ones set the pace.
- **Players choose at a triangle.** A triangle hides what is behind it, and the player chooses to go over it or round it.
- **Gravity.** Bowl and funnel shapes pull players to orbit points of interest, rather than run straight lines between them.
- **Never show the whole of a landmark from A to B.** Curve routes so the world is revealed bit by bit. A tower seen behind a mountain still reveals new things as you near it: a lake round it, a camp at its foot.
- *For us:*
  - The main path never runs straight at the next landmark.
  - Every biome has one medium "screen" (a ridge, a dune, a mesa) between the town and its landmark.
  - The landmark is seen whole from only two or three planned places. Plan 12's "windows" do this inside a biome; this plan does it between biomes.

### 1c. A world that loops back on itself

- **The centre is the goal.** In the first handheld region, Saffron City sits at the centre. Thirsty guards at all four gatehouses keep you out until mid-game, so you circle a city you can see and cannot enter. (Bulbapedia, Saffron City and Guardhouse; Esports.gg guide.)
  - In Sinnoh, Mt. Coronet splits the region, and the story ends at the Spear Pillar on its summit. (Bulbapedia, Mt. Coronet and Spear Pillar.)
  - *For us:* The Hollow at the centre, ringed by the Crown range, is our Saffron and Coronet in one: seen early, circled for ten biomes, entered last.
- **Shortcuts that join far-apart places.** Diglett's Cave is a plain tunnel from Route 2 to Vermilion that saves long backtracking. In the Johto games it is for a time the only way into western Kanto. (Bulbapedia, Diglett's Cave.)
  - Dark Souls' world "loops back around on itself through shortcuts and elevators". Its first big loop ends with an elevator back to the hub. (Boss Keys, "The World Design of Dark Souls"; Game Developer, "Cutting through the fog".)
  - Elden Ring keeps that sense of an "interlocking world", with zones that connect "in unexpected ways". (PC Gamer.)
  - *For us:* the late Arcane biome has a path down to the old fence at the end of Greenwood's first route (S2). The fence the player has looked at since minute five opens from the far side. The nostalgia biome leads home.
- **Optional places off the main path.**
  - In the classic region these are islands and caves: Seafoam Islands on a sea route, a high-level cave beside the second city, the Power Plant up a side river. Each is reached only by water or later abilities, and holds rarer creatures. (Bulbapedia, Route 20, Seafoam Islands and Cerulean Cave; Thonky on the Power Plant.)
  - Brick Bronze's region also had "outlying islands" beyond its town map. (Brick Bronze wiki, snippet.)
  - *For us:* islands reached by ferry, a summit, a frozen lake, a drowned village, a crater, a floating islet (section 8).

### 1d. Getting from one biome to the next

- **Transitions are gradual.** Biome edges in good worlds are a band, not a line. Ground colour blends, the plants of both biomes mix with "random variation", and the plants hide the seams. (Unreal forum, on Fortnite's biomes; Westeroscraft planning notes; Khora devlog, colour maps by temperature and rainfall; 80.lv, on grassland vegetation hiding blends.)
- **Thresholds change the mood, light and sound together.** Roblox developers do this on the client: a LocalScript changes Lighting and Atmosphere when the player enters a zone, with no remote calls. (DevForum, "Changing lighting on the client side when stepping into different zones"; ZonePlus thread.)
  - Tweening several Atmosphere properties at once can look choppy.
  - Linear interpolation handles a player who stops or turns back better than a tween.
  - (DevForum, "Atmosphere bugs out when transitioning using tweens"; "Realistic Dynamic Lighting".)
- **Skyboxes cannot blend.** A Sky has six face textures (`SkyboxBk`, `SkyboxDn`, `SkyboxFt`, `SkyboxLf`, `SkyboxRt`, `SkyboxUp`), plus `CelestialBodiesShown`, `StarCount`, `SunAngularSize`, `MoonAngularSize` and `SkyboxOrientation` (Roblox Sky reference).
  - Swapping one Sky for another is a cut. So we hide each swap in a tunnel, a cave, a fog bank or a cloud layer, the way gatehouses hid a map change in the handheld games.

### 1e. A sense of scale on Roblox

- **Distant scenery that is always there.**
  - `Model.LevelOfDetail = StreamingMesh` draws a low-detail coloured stand-in past the streaming radius. Stand-ins have no collision, physics or raycast.
  - Its successor `SLIM` builds better stand-ins at several levels of detail. It needs `Workspace.StreamingEnabled`, a place saved to Roblox, and Team Create. It handles static models only, and falls back to `Disabled` where a device does not support it.
  - `ModelStreamingMode.Persistent` keeps a model on every client.
  - (Roblox docs: SLIM, the Model class, the ModelLevelOfDetail enum.)
- **Atmosphere.**
  - `Density` fades objects and terrain with distance.
  - `Haze`, `Glare` and `Decay` colour the horizon and the air round the sun. `Glare` needs `Haze` above 0, and `Decay` needs both.
  - (Roblox Atmosphere reference.)
  - Haze does what aerial perspective does in landscape painting: each further layer is paler and bluer, which reads as depth.
- **Clouds.** `Clouds.Cover` runs 0 to 1, plus `Density`, `Color` and `Enabled` (Roblox Clouds reference). One cloud layer can be thinned or tinted per zone.

### 1f. A picturesque world in a small game

*A Short Hike* (GDC 2020 postmortem, "Crafting a Tiny Open World"; read through summaries) guides players with "curiosity-inducing landmarks" and natural barriers, on an island small enough to learn by heart. The peak you climb is in view almost all game.

Older handheld games pack meaning into small spaces: every view does a job (plan 12, section 1c).

Painters' composition tricks carry over:
- a framed view (arch, branch or doorway) in the foreground;
- life in the middle ground (a town, a bridge, smoke);
- a silhouette behind (a peak, a tower);
- golden light from low and to the side.

---

## 2. Principles

1. **Always moving, always somewhere.**
   - Every biome looks, sounds and is lit unlike the last. Its height above the sea differs too.
   - Each threshold is a crossing you remember: a pass, a tunnel, a causeway, a lift. It is never a seam on a flat field.
2. **The Crown is always on your left.**
   - The path goes round the Crown range counter-clockwise: east along the coast, north up the east side, west along the north, south down the west, then in.
   - So the centre is always on the left as you travel. It is a fixed compass you never have to think about.
3. **Climb the shell, then fall inward.**
   - The spiral is in height as well as plan. You start at the sea and climb biome by biome to Stormreach, the highest place in the world, where you first see the tear (brief section 8).
   - Then you come down through the Arcane caves and a tunnel into the crater at the centre.
4. **Show, hide, show again, from a new side.**
   - Each landmark has planned windows: from far away first, then hidden, then close.
   - World landmarks (the Crown, the cloud halo, later the tear) come back from every side of the ring, so the player sees the same thing from a new angle and knows how far round they have come.
5. **Look back.**
   - Every biome has one vista back over the ground already covered: a summit, a rim or a cliff stair. Biomes you have finished stay on the skyline as you leave.
6. **Thresholds hide the cuts.**
   - Sky swaps, music changes and the end of one ground slab happen inside tunnels, gatehouses, fog banks and cloud layers.
   - Light and colour blend over a band of 150 to 400 studs.
7. **Side areas everywhere, each a different flavour.**
   - At least one optional area per biome, often in another biome's style: an oasis in the desert, a hot spring in the snow, a mushroom wood in the hills, an island in the sea.
   - They give views, lore and dressing now. Rewards wait for Ayrton (section 13).
8. **The world is bigger than the walk.**
   - Seas, islands, ranges and far coasts lie past every edge, as impostors you can never reach.
   - The playable ring is about 5 km across, and the horizon lies further out still.
9. **The world answers the story.**
   - A broken bridge is mended once you hold the badge.
   - The tear glows brighter each chapter, and a town looks different after its giant is calmed.
   - What changes is set by server-side flags; the client only draws it.
10. **Cosy, readable, phone-first.** Golden light, flat warm colours and rounded clay shapes (brief section 12). Nothing so dark you cannot read the path, and no fog so thick it hides the next lamp.

---

## 3. The world layout

### 3a. Hub positions (world coordinates)

The first three are fixed; tests already pin them. Later hubs are placed with a new `site` field in the biome data (section 11), so the "straight on past the sealed road" rule in `Layout.world` stops applying from the Mire on.

| # | Biome | Hub (x, z) | Base y | Town | Notes |
| --- | --- | --- | --- | --- | --- |
| 1 | Greenwood | (0, 0) | 0 | Thistledown | Fixed. Gate (684.4, -80) |
| 2 | Dust Canyon | (984, -80) | 0 (gate on tier 40) | Kilnrest | Fixed. Gate (1763, -180) |
| 3 | Tide Flats | (2063, -180) | 0 | Saltwick | Fixed. Gate (2806, -70) |
| 4 | Mire | (3100, -550) | 0 | Sedgeholm | Data written; needs `site` |
| 5 | Frostline | (3400, -1650) | 80 | "Rimewick" | On a plateau above the Mire |
| 6 | Crystal Deep | (2900, -2700) | 20 | "Glimmerholt" | Underground, under the Northern Range |
| 7 | Emberfall | (1650, -3150) | 100 | "Cinderwick" | On the volcano's lower flank |
| 8 | Stormreach | (300, -3000) | 300 | "Highwhistle" | Sky peaks over a sea of cloud |
| 9 | Arcane biome | (-350, -1700) | 100 | "Lanternmoor" | Purple cave valley in the Western Highlands |
| 10 | Abyss | (850, -1700) | 20 | "Starfold" | West half of the Crown's crater |
| 11 | The Hollow | (1850, -1700) | 40 | "Old Hearth" (a camp in the ruins) | East half of the crater; the tear is above |

**The Crown** is a ring of mountains centred on (1350, -1700):
- Inner foot at radius 700, outer foot at radius 950, crest at y 250 to 320.
- Inside is the crater: the Abyss to the west, The Hollow to the east, and the Rift between them (radius 150, a chasm of starlight you cannot walk on).
- It clears Dust Canyon's furthest route point (1104, -625) by about 150, and the Redstack (1634, -560) by about 225. The Redstack reads as a broken-off spur of the Crown.

Hub-to-hub distances in a straight line: 984, 1084, 1101, 1140, 1163, 1328, 1358, 1453, 1204, 1000. These are close to today's 1,000 to 1,100, and the walk bends round each one.

### 3b. The map

1 character = 100 studs across and 200 studs down (so the map is squashed top to bottom). It is a sketch: the tables are what count.

```
           |         |         |         |         |         |      <- x = -1000, 0, 1000, 2000, 3000, 4000
z  -3800 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   A  far ranges (impostors, never reached)
z  -3600 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
z  -3400 AA         i                       h                       Northern Range: Emberfall's volcano, Stormreach's peaks
z  -3200 AA                           7                          
z  -3000 AA             8                                        
z  -2800 AA                                                      
z  -2600 AA                     ^^^^^^            6                 6 is underground, below the range
z  -2400 AA                  ^^^^^^^^^^^^                        
z  -2200 AA                ^^^          ^^^                      
z  -2000 AA               ^^^            ^^^               g        ^ the Crown range
z  -1800 AA               ^^      **      ^^                        * the Rift (tear above)
z  -1600 AA       9       ^^  10  **    11^^           5         
z  -1400 AA   l           ^^^            ^^^                f    
z  -1200 AA                ^^^          ^^^                      
z  -1000 AA                  ^^^^^^^^^^^^                  ~~~~~~   Eastern Sea
z   -800 AA    j               a^^^^^^                     ~~~~~~
z   -600 AA                                         4      ~~~~~~
z   -400 AA                                                ~~~~~~
z   -200 AA       k                       3              e ~~~~~~
z      0 AA          1         2                           ~~~~~~
z    200 AA                                                ~~~~~~
z    400 AA      ~~~~~~~~~~~~~~~~~~~~~b~~~~~~~~~~~~~~~~~~~~~~~~~~   South Sea (the real coastline wanders, z +200 to +450)
z    600 AA      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
z    800 AA      ~~~~~~~~~~~~~~~~~d~~~~~~~~~~~c~~~~~~~~~~~~~~~~~~
z   1000 AA      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
```

Numbers are hubs. Letters are side areas (section 8a):
- a Starfall Crater; b Gull Cove; c Palm Key; d Brine Isle;
- e the Sunken Bell; f Glass Lake; g Whitefang Summit; h Steamvale;
- i Cloud Isle; j Mirror Mere; k the Spring Plateau; l Toadstool Dell.

The far west (x ≤ -1100) is the Western Highlands. The far north (z ≤ -3600) is the far Northern Range. Both are impostors.

### 3c. The world's frame

| Feature | Where | What it does |
| --- | --- | --- |
| **South Sea** | z > +250 to +450, x -500 to 4500, out to the horizon | The coast every launch biome sits on. It holds Gull Cove, Brine Isle, Palm Key and the Brine Stacks (sea stacks, impostors). There is a far coastline on the horizon at z +3000 (impostor). |
| **Eastern Sea and estuary** | x > 3800, z +300 to -1100 | The Mire's mangroves run out into it. The Heron Causeway crosses its mouth. The Old Light can be seen across it from the Mire, looking back. |
| **Crown range** | Ring round (1350, -1700) | The world's centre and constant landmark. A cloud halo sits on it (y 450 to 520) and turns very slowly. |
| **Northern Range** | z -2300 to -3900 | Frostline's peaks (Whitefang, 420 tall) in the east, the volcano Old Smoulder (crater rim 220, plume to 600) in the middle, and Stormreach's sky peaks (to 480) in the west. Crystal Deep lies under it. |
| **Western Highlands** | x < -300, z 0 to -3000 | The wooded hills behind Greenwood's spring plateau. They rise to the Arcane cliffs and hold Mirror Mere and Toadstool Dell. Taller far hills (impostors) lie past x -1100. |
| **Rivers** | | The brook from the spring plateau (Greenwood, plan 12). The Rimewater, from Glass Lake down the Rimewater Gorge to the Mire. A lava river on Old Smoulder (lit, not walkable). |

---

## 4. The main path and its thresholds

Each threshold sits in the gap between one biome's sealed road and the next town's arch. Today that gap is 240 studs (`BIOME_GAP` 80 + `NEXT_HUB_ALLOWANCE` 160). From the Mire on, the gap is drawn as a **passage** in data (section 11), 300 to 750 studs long. It has no grass and no tamers, but it may have a bench, a sign and a view.

| From → to | Threshold | Kind | Line (world, approx.) | Height | What happens |
| --- | --- | --- | --- | --- | --- |
| Greenwood → Dust Canyon | **The Acorn Gatehouse and the Dry Hedge** | Gatehouse | (684, -80) → (834, -80) | 0 → 0 | Built. The gatehouse frames the first red rock beyond. |
| Dust Canyon → Tide Flats | **The Stair Gate and the Dune Road** | Pass, descending | (1763, -180) → (1913, -180) | 40 → 0 | Built (plan 09/10). The first sight of the sea is from the top of the Stair Gate. |
| Tide Flats → Mire | **The Heron Causeway** | Causeway (a long stilted boardwalk) | (2866, -70) → (2960, -120) → (3010, -300) → (3040, -420) → Sedgeholm's south arch (3100, -400) | 0 (deck at 3) | Turns north-east over the estuary mouth, with water both sides. The sea fog thickens halfway. |
| Mire → Frostline | **The Rimewater Gorge** | Pass (a switchback climb up a gorge beside waterfalls) | Sluice Gate (3250, -1150) → (3280, -1300) → (3360, -1420) → Rimewick's south arch (3400, -1500) | 0 → 80 | Three flights of stairs and two ramps. Reeds give way to birch, pine and then snow pine. The first snow falls on the top flight. |
| Frostline → Crystal Deep | **The Frozen Fall** | Cave mouth (behind a frozen waterfall) | Frostline gate (3150, -2150, y 140) → down to Glimmerholt's east arch (3050, -2650, y 20) | 140 → 20 | The ice turns to blue crystal and the light falls away. The sky swap happens out of sight in the tunnel. |
| Crystal Deep → Emberfall | **The Lava Tube** | Tunnel (climbing) | (2450, -2850, y 20) → Steamvale branch (2250, -3200) → Cinderwick's east arch (1800, -3150, y 100) | 20 → 100 | Crystal gives way to black glass, and a red glow grows ahead. A side gallery opens to Steamvale (h). |
| Emberfall → Stormreach | **The Updraught Lift** | Lift (a wicker basket on a cable) | Lower station on the crater rim (1150, -3350, y 220) → upper station (750, -3300, y 330), then a rope bridge to Highwhistle's east arch (450, -3000) | 220 → 330 → 300 | A ride of 20 to 30 seconds through the cloud layer: the sky swap. A stair path round the rim is the fallback if the lift is not built yet. |
| Stormreach → Arcane | **The Cloud Stair** | Stair (a long switchback stair cut into a peak's west face) then a cave mouth | Anvil Gate (0, -2550, y 380) → (-150, -2300) → (-300, -2000) → Lanternmoor's north arch (-350, -1850, y 100) | 380 → 100 | The longest descent in the game. Clouds part below, and the purple valley shows through. The light falls to twilight under the cave arch. |
| Arcane → Abyss | **The Starwell Tunnel** | Tunnel (through the Crown's west wall) | Arcane gate (350, -1700, y 60) → (650, -1700, y 30) → Starfold's west arch (700, -1700) | 60 → 20 | You come out under a night sky full of stars. It is the one place the sky becomes night. |
| Abyss → The Hollow | **The Last Bridge** | Bridge (broken ruins, mended by the story) | Abyss gate (1150, -1700) → across the Rift → (1550, -1700) → Old Hearth's west arch | 20 → 40 | The tear hangs straight above the middle of the bridge. |

The path bends between every pair: no hub can be seen from the one before it, except the Hollow, which is the point. The threshold kinds never repeat twice in a row.

---

## 5. Transition zones

Each zone is a band 150 to 400 studs wide, centred on the threshold. The client blends light and sound across it (section 9b). The dressing blends the ground and plants in steps, using the existing `ground`, `rows`, `trees` and `fill` fields, plus a `blend` list in the passage data.

| Pair | Ground and plants, in order of travel | Light and sky | Weather and particles | Sound |
| --- | --- | --- | --- | --- |
| Greenwood → Dust Canyon | Lawn yellows into dry grass. Birch and oak give way to scrub, then red rock and the first cactus. | Afternoon gold to bright, hot white. Haze rises and clouds thin. | Pollen gives way to dust. | Birdsong and brook give way to wind and cicadas. |
| Dust Canyon → Tide Flats | Red sand pales to dune sand. Marram grass appears, then driftwood. | Hot white to bright sea light. The air turns blue and the sky widens (sky A to B at the Stair Gate arch). | Dust gives way to spray at the shore. | Wind gives way to surf and gulls. |
| Tide Flats → Mire | Sand becomes mudflat, then reeds, then the first mangroves along the causeway. | Bright to soft green-grey. Fog rises to its thickest at the causeway's midpoint, and the sky swaps inside it. | Spray gives way to mist, then fireflies at the arch. | Gulls fade; frogs and a distant bell come in. |
| Mire → Frostline | Mangroves, then cypress, birch, pine and snow pine. Mud gives way to rock and then snow. | Green mist gives way to cold blue clarity. Fog lifts as you climb, with the sky swap at the top flight. | Mist, then falling snow. | Frogs fade into a waterfall roar, then wind and creaking ice. |
| Frostline → Crystal Deep | Snow, then ice, then blue crystal, then violet crystal. | Daylight goes out. Underground the light comes from the crystals; the sky is hidden. | Snow stops; glints. | Wind fades to drips and a low hum. |
| Crystal Deep → Emberfall | Crystal, then black glass, then red rock and ash. | Violet gives way to ember red. You come out to a dusky sky. | Glints give way to embers and ash. | Hum fades to a rumble and lava crackle. |
| Emberfall → Stormreach | Ash rock gives way to bare stone, then cloud-swept grass on the peaks. | Red dusk to bright high noon. The swap is inside the cloud layer during the lift. | Embers, then cloud wisps, then wind streaks. | Rumble gives way to high wind and wind chimes. |
| Stormreach → Arcane | Grass, then rock, then purple moss and glowing mushrooms. | High noon to violet twilight. The swap is under the cave arch at the stair's foot. | Wind streaks give way to slow glowing motes. | Wind gives way to a music-box tone and owls. |
| Arcane → Abyss | Moss, then dark stone, then star-flecked black sand. | Twilight to night with stars. The swap is in the tunnel. | Motes give way to falling star specks. | Owls fade to near silence and a soft choir pad. |
| Abyss → The Hollow | Black sand, then old paving, then ruins. | Night to a violet-ember glow under the tear. | Star specks give way to ash and petals. | The choir pad becomes the tear's low pulse. |

The rules are kept in tests (section 11d):
- No preset changes in less than 150 studs, unless the change is inside a tunnel, a cave or a cloud layer.
- Every sky swap point lies inside a tunnel, a cave, a cloud layer or a fog peak.

---

## 6. Landmarks and sightlines

### 6a. World landmarks

These are persistent impostors (section 10).

| Landmark | At (world) | Height | Seen from | Changes with the story |
| --- | --- | --- | --- | --- |
| **The Crown and its cloud halo** | Ring round (1350, -1700); halo at y 450 to 520 | Crest 250 to 320 | Every biome; it is always to your left | The halo darkens a shade each chapter, so the change goes unnoticed until you look back at your first screenshots |
| **The tear** | Above (1900, -1750), y 600 to 750 | | Hidden until the Stormreach chapter (brief: "first sight of the tear"). Then visible from everywhere, through the halo | Grows and brightens each chapter after; sealed after the finale |
| **Whitefang** (Frostline's peak) | (3800, -2150) | 420 | From the Mire, Tide Flats' breakwater, Frostline, Glass Lake | |
| **Old Smoulder** (Emberfall's volcano) | Crater (1350, -3350); plume to 600 | Rim 220 | The plume is a faint smudge from Dust Canyon's rim and the Stair Gate. It is clear from Frostline and Stormreach | The plume grows when Emberfall's chapter starts |
| **The Anvil** (Stormreach's storm peak) | (100, -3300) | 480, with a flat-topped storm cloud | From Greenwood's spring plateau (far, faint), Emberfall, the Arcane biome | Lightning flashes inside the cloud |
| **The Lantern Spire** (Arcane biome) | (-500, -1900) | 260, a crooked spire with a purple light at its top | From Greenwood's ridge (faint, at dusk-coloured haze), Mirror Mere, the Cloud Stair | The light blinks a slow pattern: a small mystery from day one |

### 6b. Each biome's own landmark, and its views

| Biome | Its landmark | Seen ahead (the tease) | Seen behind (the look-back) |
| --- | --- | --- | --- |
| Greenwood | The ancient tree (270, -362), 160 tall | The Crown's halo to the north-east; the Lantern Spire's light, faint to the north-west | |
| Dust Canyon | The Redstack (1634, -560), 190 tall | Old Smoulder's smudge, far north; Starfall Crater's violet glint over the broken bridge | From the Stair Gate (tier 40): Greenwood's canopy and the ancient tree, 1,400 away |
| Tide Flats | The Old Light (2853, 290), 140 tall | The Mire's dark mangroves across the estuary; Whitefang's white tip | The Stair Gate on the skyline; the Redstack's top |
| Mire | The Bell Loft and the drowned bell tower (the Sunken Bell, e) | Whitefang up the gorge | The Old Light flashing across the water at dusk |
| Frostline | Whitefang | Old Smoulder's plume to the north-west, over the range | From the top of the Rimewater Gorge: the Mire, the estuary, the Old Light and the whole south coast, the game's first big panorama |
| Crystal Deep | The Heartstone, a cavern-sized crystal | (none: underground) | The Frozen Fall's blue light at the tunnel mouth |
| Emberfall | Old Smoulder | The Anvil's storm cloud to the west | The Northern Range and the Crown's north face |
| Stormreach | The Anvil | The Lantern Spire and the purple valley far below | **The whole world** from Cloud Isle: the spiral, every finished biome, the sea, and the tear in the crater for the first time |
| Arcane biome | The Lantern Spire | The Crown's west wall, with the Starwell's arch in it | Greenwood far to the south from the cliff path: home |
| Abyss | The Starwell (a ring of standing stones round a well of light) | The tear over the Rift | The Crown from inside: every biome you have walked is behind it |
| The Hollow | The tear | | The Last Bridge and the Abyss |

Every "Seen from" entry is a sightline test (plan 12, section 8, "Windows"), now across biomes. A straight line from the viewpoint, 20 above the ground, to the landmark's top must clear every wall, tier face and range impostor on the way, using the heights in data.

---

## 7. Elevation profile

Heights in studs above the sea, along the main path. Each `#` is about 20 studs.

```
y 480                                                    . Anvil (peak, seen)
y 400                                              ####### Stormreach (300-400; Cloud Isle 400; Anvil Gate 380)
y 330                                         ####/    \
y 220                                   #####/  lift     \  Cloud Stair (380 -> 100)
y 140                  ##### Frozen Fall /                \
y 100             #####     \  #########  Emberfall        ######  Arcane biome (100)
y  80        #####  Frostline\ / lava tube                       \  Starwell
y  40     ## Stair Gate (40)  \/ Crystal Deep (20, underground)    \______ Abyss (20) __/ Hollow (40-80)
y   0  ## GW ## DC ## TF ## Mire                                          ~~~ Rift ~~~
       1    2    3    4    5    6    7    8    9    10   11
```

- **The climb.** It is slow and steady, with one dip (Crystal Deep under the range). It peaks at Stormreach and falls in two long steps: the Cloud Stair, then the Starwell.
- **Every rise ends at a view.**
  - The Stair Gate shows the sea.
  - The top of the Rimewater Gorge shows the south coast.
  - The crater rim shows the Northern Range.
  - Cloud Isle shows everything.
- **Inside a biome,** plan 12's tiers (steps of 10) sit on the biome's base. Ledges still face home.
- **One height per flat point.** The underground and sky biomes never stack walkable ground over walkable ground:
  - Crystal Deep lies under the Northern Range, whose surface is impassable mountain (fill and impostor).
  - Stormreach's islands float over a cloud sea that cannot be walked on.
  - Bridges cross water or chasms only.
- **Base heights** are absolute, set by `site.base`. The builders add it to `Ground.heightAt`. The server never reads heights (section 11).

---

## 8. Side areas, shortcuts and the frame

### 8a. Side areas

Each side area belongs to one biome (it uses that biome's place ids and gating). Its look is another biome's preset, or its own. Everything listed under "offers" is dressing, views or lore. **Rewards (finds, rare spawns, materials) need a plan and Ayrton's approval** (plan 12, section 7.8).

| # | Name | Flavour | Where (world) | Owner | How reached | When | Offers now |
| --- | --- | --- | --- | --- | --- | --- | --- |
| a | **Starfall Crater** | Cosmic, an early tease | (1020, -770), r 70 | Dust Canyon | Over the broken rope bridge at the end of Dust Canyon's Route A (local (120, -545)) | Launch: seen across the gap. Mended after Ayrton picks the rule (section 13) | Violet glass sand and a scorched old camp. It is where the mentor's star fragment fell. The lore stays vague until the Arcane biome. View up the Crown's south face. |
| b | **Gull Cove** | Seaside cove, Tide Flats at its gentlest | (1700, 300), r 60 | Tide Flats | A sea-arch passage at the west end of the wrack beach (Route A, about (1910, 30)), then 300 studs along the cliff foot | Launch | Rock pools, sea stacks, nesting gulls and a bench. The view out to Brine Isle and Palm Key: places you will reach later. |
| c | **Palm Key** | Tropical isle: palms, a turquoise lagoon, warm and bright | (2450, 800), about 200 × 140 | Tide Flats | Ferry from Saltwick's Ferry Steps (section 11b) | After the ferry system; seen from launch | A picnic beach, a hammock and a view back at Saltwick and the Old Light. Later: fishing, finds. |
| d | **Brine Isle** | Sea-cave islet with a cold spring and frost crystals: a Frostline tease | (1250, 700), r 90 | Tide Flats | Ferry | With Palm Key | An ice-blue grotto and a frozen pool in summer: a riddle that Frostline answers. |
| e | **The Sunken Bell** | Drowned village ruins in the swamp | (3550, -300), r 90 | Mire | A duckboard branch off Mire Route A | With the Mire | A bell tower standing in the water. Lore of the night the sky tore, from the Mire's side. A view to the Old Light. |
| f | **Glass Lake** | A frozen lake with ice-fishing huts and auroras | (3900, -1500), r 140 | Frostline | Off Frostline Route A | With Frostline | Walk on the ice, see the auroras, and look south over the Mire to the sea. |
| g | **Whitefang Summit** | High alpine summit | Trail head (3750, -1900) to summit (3780, -2080, y 420) | Frostline | A switchback trail from Glass Lake, about 400 studs and 6 flights | With Frostline | The second panorama: the Northern Range, Old Smoulder's plume, and the Crown from the east. A summit cairn and a flag. |
| h | **Steamvale** | Frost meets fire: steaming pools among snow | (2250, -3350), r 100 | Emberfall | A side gallery off the Lava Tube | With Emberfall | A small bathhouse and hot pools with snow round them: the cosiest spot in the game. A bench. |
| i | **Cloud Isle** | A floating islet with one tree | (-150, -3350, y 400), r 40 | Stormreach | A rope bridge off Stormreach's west route | With Stormreach | The world panorama (section 6b). The tear's first sight is a story beat here. |
| j | **Mirror Mere** | A still mountain lake with a willow island | (-650, -800), lake r 200 | Arcane biome | The Old Lane (shortcut S2) | With the Arcane biome; seen as a glint from the spring plateau window | An old tamer's empty cottage, the Lantern Spire reflected in the water, a jetty. |
| k | **The Spring Plateau** | Greenwood's high meadow and spring | (-310, -120), tier 20 (plan 12's `spring_plateau`) | Greenwood | Behind the old fence at the end of Route A. It opens from the Old Lane | Launch: seen, never reached (plan 12). Opens with the Arcane biome | The spring pool and the waterfall's top. A view over Thistledown's roofs: home, seen from above for the first time. |
| l | **Toadstool Dell** | Twilight wood of giant glowing mushrooms | (-750, -1350), r 120 | Arcane biome | Off the Old Lane, south of Lanternmoor | With the Arcane biome | A troll's footbridge, mushroom rings and fairy lights. It is the Arcane biome's look in a forest, ready for Ayrton's references. |

Spacing:
- Each side area keeps at least 120 studs from any other biome's walkable space.
- Each lies on the side of a wall or ridge away from the main path, so it is found, not passed.

### 8b. Shortcuts and loops home

| Id | Shortcut | Joins | How it opens |
| --- | --- | --- | --- |
| S1 | Greenwood's lair path | The Hollow lair → Thistledown's wicket | Built (plan 12): one-way, after the giant |
| S2 | **The Old Lane** | Lanternmoor → Toadstool Dell → Mirror Mere → the Spring Plateau → Route A's old fence → Thistledown | Arcane story flag. Ledges make it one-way down at first; the old fence's gate then unlatches from the far side and it becomes two-way. The nostalgia biome leads home. |
| S3 | **The Salt Stair** | Glass Lake → down the gorge's east side → the Sunken Bell → Sedgeholm | One-way ledges down, opened after Frostline's badge. It is the quick way back to the coast. |
| S4 | **The ferry** | Saltwick ↔ Palm Key ↔ Brine Isle; later Sedgeholm's Punt Landing | A ride the server performs (section 11b) |
| S5 | **The Crown Gates** (post-game proposal) | Four short tunnels from the crater to Greenwood's north, Tide Flats, Emberfall and the Arcane biome | After the entity falls, the centre becomes the hub, as Saffron did. A proposal for Ayrton. |

Teleport buildings between towns stay as the brief says ([Locked]: "teleports between certain buildings"). The shortcuts are for players who walk, and they make the world feel joined up.

---

## 9. Light, sky, weather and sound

### 9a. Presets

Presets go in a new `src/config/ClimateConfig.luau`, keyed by preset id. Numbers are starting points to tune by screenshot ([Default]).
- Greenwood is today's `Dressing.mood`.
- Clouds use Roblox's dynamic clouds.
- "Sky" names a Sky asset (to be generated or found, and recorded in `docs/ASSETS.md`).

| Preset | ClockTime | Brightness | OutdoorAmbient | ColorShift_Top | Atmosphere Density / Offset / Haze / Glare | Atmosphere Color → Decay | Grade TintColor / Saturation | Clouds Cover | Sky | Particles |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| greenwood | 16.6 | 2.6 | 150,138,124 | 255,214,160 | 0.30 / 0.20 / 0.8 / 0.2 | 255,228,196 → 176,144,150 | 255,242,222 / 0.08 | 0.45 | Warm afternoon | Pollen, fluff |
| dust_canyon | 15.8 | 3.0 | 170,140,110 | 255,200,140 | 0.28 / 0.15 / 1.2 / 0.4 | 255,214,170 → 200,140,110 | 255,236,210 / 0.10 | 0.20 | Clear, hot | Dust |
| tide_flats | 16.2 | 2.8 | 150,150,150 | 255,226,190 | 0.32 / 0.25 / 1.0 / 0.3 | 230,240,250 → 150,170,200 | 245,248,255 / 0.06 | 0.50 | Wide sea sky | Spray, gulls |
| mire | 17.2 | 2.0 | 120,130,110 | 230,210,150 | 0.45 / 0.10 / 2.0 / 0.1 | 200,215,180 → 110,120,100 | 235,245,220 / 0.00 | 0.70 | Overcast, soft | Mist, fireflies |
| frostline | 14.5 | 2.6 | 160,170,190 | 230,240,255 | 0.35 / 0.30 / 1.5 / 0.5 | 225,235,250 → 150,165,200 | 240,246,255 / -0.05 | 0.60 | Pale cold blue | Snow |
| crystal_deep | 0 (unused) | 0.5 | 60,50,90 | 200,180,255 | 0.50 / 0.00 / 0.0 / 0.0 | 120,100,170 → 60,40,100 | 230,220,255 / 0.15 | 0 | Hidden by the roof | Glints |
| emberfall | 18.2 | 2.2 | 160,110,90 | 255,170,110 | 0.40 / 0.15 / 2.2 / 0.6 | 255,190,150 → 150,80,70 | 255,232,215 / 0.12 | 0.55 (grey 120,100,100) | Ember dusk | Embers, ash |
| stormreach | 13.0 | 3.2 | 170,175,190 | 255,245,230 | 0.22 / 0.50 / 0.6 / 0.3 | 220,230,255 → 140,150,190 | 248,250,255 / 0.05 | 0.75 | High, bright | Wind streaks |
| arcane | 19.0 | 1.6 | 130,110,160 | 220,170,255 | 0.42 / 0.10 / 1.5 / 0.2 | 190,160,230 → 90,60,130 | 240,230,255 / 0.12 | 0.40 (lilac) | Violet twilight | Glowing motes |
| abyss | 0 | 1.2 | 80,80,130 | 170,170,255 | 0.25 / 0.60 / 0.4 / 0.0 | 60,60,120 → 20,10,50 | 225,225,255 / 0.10 | 0.10 | Starfield (StarCount high) | Star specks |
| hollow | 18.8 | 1.8 | 130,110,130 | 255,180,200 | 0.40 / 0.30 / 1.8 / 0.6 | 210,170,200 → 80,40,90 | 255,236,240 / 0.00 | 0.60 (violet) | Tear-lit | Ash, petals |
| side presets | | | | | | | | | | `palm_key` (bright tropical), `steamvale` (frostline with steam), `starfall` (dust_canyon with violet decay), `toadstool` (arcane, darker) |

Nothing should be too dark to read the path. Crystal Deep and the Abyss carry lamps and glowing dressing (`Ambience` lights) every 30 to 40 studs along the lane.

### 9b. The client blender

The blender is `src/client/World/Climate.luau`: client only, visual only.

1. **Zones.** Each zone in the world data is a shape in world coordinates with a preset, a `band` (blend width, 150 to 400) and a `priority`:
   - a biome's region;
   - a side area;
   - a passage's halves;
   - an underground volume (Crystal Deep, tunnels).
2. **Weights.** Every 0.2 s the blender reads the camera focus (the character's root):
   - Each zone's weight is 1 inside its core, eased by a smoothstep across its band, and 0 beyond.
   - A zone of higher priority (a cave inside a biome) scales the others down.
   - The weights are normalised to 1.
3. **Targets.** The target values are the weighted mix of the presets:
   - Colours blend in linear RGB.
   - `ClockTime` blends the short way round the clock.
   - Atmosphere, grade, bloom and clouds blend number by number.
4. **Easing.** Each frame, every value eases towards its target with a time constant of about 1.5 s (exponential smoothing, not Tweens). This is the DevForum advice: it copes with a player who stops or turns back, and avoids the choppy multi-property Atmosphere tween.
   - A property is only set when its value has changed by more than a small step, to keep the cost down.
5. **Sky.** The Sky follows the zone with the largest weight, and only changes at a passage's `swapAt` point, which lies inside a tunnel, cave or cloud layer.
   - Two Sky instances are kept: the one on show in `Lighting`, the next one in `ReplicatedStorage`, and they are switched over.
   - At open-air swap points, Atmosphere density is raised by 0.15 for 2 s round the swap, to hide the cut.
6. **Sound.**
   - One ambient bed per preset (wind, birds, surf, frogs, crackle, hum), each a looping `Sound` in a `SoundGroup`. Its volume equals its zone's weight.
   - Music per biome crossfades over 4 s at the passage midpoint.
   - Battles keep their own music, as now.
7. **Story-state visuals.**
   - The tear, the halo's shade, the mended bridge and the calmer giant's lair are shown or hidden by the client from flags the server has already replicated.
   - Access to places is never decided by this (section 11).
8. **Particles.** Each preset's particles (the existing `Ambience` kinds, plus Snow, Ash, Wind and Star) follow the camera in a 120-stud box. Their rate is scaled by the zone's weight and by a quality factor read on the client (check the current API for the user's graphics level before relying on it).

The server keeps setting Greenwood's mood at start (`Dressing.mood`), so Studio and the first frame look right. The client takes over from there.

---

## 10. Phone performance

| What | How | Budget |
| --- | --- | --- |
| Streaming | `Workspace.StreamingEnabled` on. Start `StreamingTargetRadius` at 512 and tune between 384 and 768 on a phone view. `StreamingMinRadius` 128. Pause when the minimum is not loaded (the integrity mode), so nobody walks onto missing ground. | |
| Far scenery (the Crown, ranges, islands, far coasts, the halo, the tear) | One low-poly MeshPart per piece. `ModelStreamingMode.Persistent`. `CanCollide`, `CanQuery` and `CanTouch` false; `CastShadow` false. The material is flat colour, so Atmosphere haze tints it into the distance. | At most 40 pieces world-wide, about 150k triangles in all |
| Landmarks | The same, persistent. The foot of each landmark (the walkable part) is ordinary streamed detail. | At most 12 |
| Mid-distance towns and clusters | `Model.LevelOfDetail = SLIM` once the place is published with Team Create (SLIM needs both, and falls back to `Disabled` where unsupported). Until then `StreamingMesh`, or nothing. | Measure before and after |
| Biomes not open yet | `ReleaseConfig` keeps them closed, so the builder skips their detail. Their far scenery still stands, so the world looks whole from day one. | Only the launch three's detail is built at launch |
| Ground under the sea and the far ground | One large flat part per sea, and one per far plain, each a single colour. | |
| Climate | A handful of Lighting writes a frame, skipped when nothing changes. | Under 0.1 ms a frame |
| Particles | One emitter set per preset, near the camera only. | At most 2 emitters active at once outside battles |

Check visibility at distance in Studio, before relying on it. At today's density 0.3 / offset 0.2:
- find the distance at which a 200-tall landmark fades fully;
- move landmarks, or lower density in the presets, so every planned window shows a silhouette.

No figure for this is given here, because none was measured.

---

## 11. Server rules and data

### 11a. What stays the same

- **Flat positions.** Every place the server checks (`isNear`, grass, rustle, engage, story Enter and Sight, `mayEnter`, waking at the healer) stays a flat (x, z) from `Layout`. Heights are for builders, tests and the client.
- **The first three biomes do not move.** A test pins their hubs to (0, 0), (984, -80) and (2063, -180), within 1 stud, and their gates as now.
- **Climate, sky, sound and story visuals are client only.** They are never sent to the server, and the server never trusts them.

### 11b. What changes on the server, small and testable

1. **Explicit siting.**
   - `Biome.site = { hub: WorldPoint, base: number }?`.
   - `Layout.world` uses `site.hub` when it is given. When it is left out, it keeps the straight-on rule, so biomes 1 to 3 are unchanged.
   - The Mire's data gets `site = { hub = (3100, -550), base = 0 }` when its map is built. Until then its computed place (3106, -70) is never built, because it is closed.
2. **Which biome you are in.**
   - `Layout.biomeAt` uses the nearest place today. Round a ring, with biomes 1,000 apart and their routes bending towards each other, that will guess wrong near the edges.
   - Add a `region` shape per biome in the world data. `biomeAt` checks the regions first and keeps the nearest place as a fallback.
3. **Rides (ferry, lift).**
   - The client sends intent only (Blink: `Ride { id }`).
   - The server checks:
     - the player is near the station place (`isNear`);
     - the ride is open (a badge or story flag in the profile);
     - the rate limit.
   - The server then calls `Player:RequestStreamAroundAsync(destination)`, then pivots the character to the far station. The client plays the ride while it waits.
   - This is a new message and a new handler, so it gets its own short plan. It moves no value, so it is not one of the approval topics. But it changes where players can be, so the tests check every ride lands on walkable ground.
4. **Falls (Stormreach).** A player whose root goes below the biome's `floor` height is returned by the server to the last checkpoint place they passed. There is no penalty.
5. **Side areas and shortcuts.**
   - They are gated like sealed roads, through `mayEnter`, with an `opens` rule: a badge count or a story flag.
   - A shut one is closed in the world by a fence, a broken bridge or a latched gate, so that what you see matches what the server allows.

### 11c. New data (data, not code)

- A new registry `src/content/World.luau`, with its data folder `src/content/world_data/` (a different name from the registry, for Windows). It holds one file each:
  - `Passages.luau`
  - `Zones.luau`
  - `Landmarks.luau`
  - `SideAreas.luau`
  - `Scenery.luau`
  - `Shortcuts.luau`
- Every number lives in `src/config/` (`ClimateConfig`, plus streaming radii and budgets in `WorldConfig`).

```luau
-- src/shared/WorldTypes.luau additions (all optional; a world without them is today's world)
export type WorldPoint = { x: number, z: number }
export type Site = { hub: WorldPoint, base: number, floor: number? } -- floor: the fall line (Stormreach)
export type PassageKind = "Gatehouse" | "Pass" | "Causeway" | "CaveMouth" | "Tunnel" | "Lift" | "Stair" | "Bridge" | "Ferry"
export type Passage = {
	id: string,
	from: number, to: number,            -- biome numbers
	kind: PassageKind,
	points: { WorldPoint },              -- the walk, sealed road to arch
	heights: { number },                 -- y at each point (eased between)
	width: number,
	swapAt: number,                      -- studs along: where the sky and music change
	stations: { [string]: WorldPoint }?, -- lift or ferry ends: real places the server checks
	blend: { { at: number, ground: Colour, plants: { string } } }?, -- dressing steps along it
}
export type ClimateZone = { id: string, preset: string, shape: Shape, band: number, priority: number? }
export type WorldLandmark = {
	id: string, model: string, at: WorldPoint, base: number, tall: number, faces: number,
	seenFrom: { string },  -- place ids: each is a sightline test
	shownWhen: string?,    -- story flag (the tear)
}
export type SideArea = {
	id: string, name: string, owner: number, preset: string,
	shape: Shape, entrance: WorldPoint,
	opens: { badges: number?, flag: string? }?, -- left out: always open
	offers: { string },    -- notes for the builder: views, lore, dressing
}
export type FarScenery = { id: string, model: string, at: WorldPoint, base: number, scale: number, faces: number }
export type Shortcut = { id: string, from: string, to: string, oneWayUntil: string? }
-- Biome gains: site: Site?, region: Shape?
```

`Shape` gains `Poly` (plan 12 section 4a proposed it; it was not built) for biome regions and the Crown's ring. A ring can be drawn as two circles: inside one and outside the other.

### 11d. Tests (`tests/world.test.luau`)

- **Fixed hubs.** The first three hubs and gates have not moved.
- **No overlaps.** No two biomes' walkable spaces (towns, corridors, rooms, side areas, passages) overlap in (x, z), and every pair is at least 120 apart except where a passage joins them. Crystal Deep's walkable space lies only under unwalkable range.
- **Passages join up.** Each passage starts within 2 of its biome's sealed road and ends within 2 of the next town's arch. Its heights match both ends' bases and tiers. No step in it is greater than a stair can take.
- **Zones cover everything.** Every walkable cell (`Walk`, 8-stud grid at world scale) has climate weights that sum to 1. No change between presets happens in less than 150 studs, except inside a zone marked underground or cloud.
- **Sky swaps are hidden.** Every `swapAt` lies inside a tunnel, cave or cloud zone, or at a fog peak.
- **Sightlines.** For each landmark's `seenFrom` place, the line to its top clears every wall, tier and scenery height on the way.
- **Side areas.**
  - Each is reachable from its owner's hub once its `opens` rule is met.
  - Each is unreachable before that.
  - Each is at least 120 from other biomes' walkable space.
- **Rides and falls.** Every station and checkpoint is on walkable ground, and every ride's far station is reachable on foot to the next hub.
- **Budgets.** Counts of far-scenery pieces and landmarks stay within section 10.

---

## 12. Build order

Each step passes `lune run check`, is played in Studio on a phone-sized view, is checked by screenshot against the clay-toy look, and logs its [Default]s in `docs/DECISIONS.md`. Plan 12's Greenwood work, in progress now, comes first. This plan starts after it lands.

**Now, for the launch three:**
1. **World data.**
   - The `WorldTypes` additions, the `World` registry with the launch three's passages, zones and landmarks, and `Biome.site` (unused by 1 to 3).
   - Region-based `biomeAt`.
   - The tests in 11d that apply to three biomes. No change to play.
2. **Climate.**
   - `ClimateConfig` with greenwood, dust_canyon, tide_flats and starfall.
   - The client `Climate` blender.
   - Ambient sound beds.
   - Sky swaps inside the Acorn Gatehouse and at the Stair Gate arch.
   - Screenshots at each threshold, going and coming back.
3. **The far shell.**
   - The Crown ring and its cloud halo.
   - The Northern Range silhouettes (Whitefang, Old Smoulder's plume, the Anvil).
   - The Western Highlands with the Lantern Spire's faint light.
   - The South Sea's horizon, with Brine Isle, Palm Key, the Brine Stacks and the far coast as impostors.
   - Streaming settings. Persistent landmarks. The sightline tests.
   - This step alone is what stops the launch three feeling like a small strip.
4. **Transition dressing.**
   - The Dry Hedge (Greenwood → Dust Canyon) and the Dune Road (Dust Canyon → Tide Flats) blends.
   - The Stair Gate look-back vista: a bench, and a window cut to show the ancient tree.
5. **Launch side areas.**
   - Gull Cove, reachable.
   - Starfall Crater, seen across the broken bridge (opening waits on Ayrton).
   - The Spring Plateau and Mirror Mere's glint, as views.
   - Three "postcard spots" per biome: a bench facing a composed view (foreground frame, life in the middle, silhouette behind). Photograph each.

**Later, one biome per milestone**, each with its passage, preset, landmark, side areas and tests:

6. **Mire.** `site`, the Heron Causeway, the Sunken Bell, the mire preset. Its dark trees show across the water from Tide Flats.
7. **The ferry.** Its own plan (a Blink `Ride` message and a server move). Opens Palm Key and Brine Isle, and later Sedgeholm's Punt Landing.
8. **Frostline.** The Rimewater Gorge, Glass Lake, Whitefang Summit, the Salt Stair (S3).
9. **Crystal Deep.** The Frozen Fall cave mouth, the underground preset, lamp spacing on the lane.
10. **Emberfall.** The Lava Tube and Steamvale.
11. **Stormreach.** The lift (it reuses the ride from step 7), the fall return, Cloud Isle, and the tear revealed by story flag.
12. **Arcane biome.** Waits on Ayrton's style references ([Locked]: biome 9 is the nostalgia biome). The Cloud Stair, Toadstool Dell, and the Old Lane (S2) home to Greenwood's old fence.
13. **Abyss, then The Hollow.** The Starwell Tunnel, the Last Bridge, the night and tear presets. Post-game Crown Gates (S5) only if Ayrton approves.

### New models to generate (painted clay-toy style, flat warm colours, bold silhouettes made to be seen from far away)

These are for steps 3 to 5. Record each in `docs/ASSETS.md`.

| Model | What it is | Rough size (w / h / d) |
| --- | --- | --- |
| CrownRange (×6 segments) | A curved run of rounded, layered mountains in soft violet-grey with pale tops, low-poly | 600 / 300 / 250 each |
| CloudHalo | A thick ring of soft cream cloud, puffy and rounded, seen from below and the side | 1,500 across / 70 tall |
| FarPeak (×3 variants) | A distant mountain silhouette in hazy blue, simple and chunky | 800 / 450 / 400 |
| VolcanoFar | A broad volcano cone with a red-glowing crater rim and a smoke plume | 900 / 220 (plume to 600) |
| StormPeak | A tall stone peak under a flat-topped storm cloud | 300 / 480 |
| LanternSpire | A crooked purple stone spire with a glowing lantern at its top | 60 / 260 |
| IsleFar (×3) | A small island with palms or a sea cave, seen from the shore | 200 / 60 |
| SeaStacks | A cluster of three rounded sea stacks with gulls' nests | 80 / 70 |
| FarCoast | A long low strip of hazy coastline with tiny white cliffs | 2,000 / 60 |

---

## 13. For Ayrton (in one batch)

1. **The layout.** The coordinates in 3a: a ring of eight biomes round the Crown, then two inside the crater. The path climbs from the sea to the sky peaks and falls into the centre. OK?
2. **Rides.** A ferry to the islands and a lift up to Stormreach, done by the server moving you (you ask, it checks and moves you). OK to plan?
3. **Starfall Crater.** Show it across the broken bridge from launch as a mystery. When should the bridge open: after the Tide Flats badge, or only in the Arcane chapter when the mentor's secret comes out?
4. **The Old Lane.** Should the Arcane biome lead home to Greenwood's old fence? This is the nostalgia loop.
5. **The centre after the finale.** Tunnels from the crater to four biomes, making it the post-game hub. Yes, no, or later?
6. **Finds and rewards in side areas.** These need their own plan (saving and economy). Want one?
7. **Falls in Stormreach.** No penalty, back to the last checkpoint. OK?
8. **Names.** All names here are placeholders: towns 5 to 11, landmarks and side areas.

## 14. Sources

Landmarks, hide and reveal:
- Theory of Theme Parks, "Wayfinding in themed design: the weenie": https://theoryofthemeparks.blogspot.com/2015/08/wayfinding-in-themed-design-weenie.html
- Theme Park Tourist, best weenies: https://www.themeparktourist.com/features/20190823/37337/best-weenies-walt-disney-world
- Wellesley, "The Image of the Open World Game": https://cs.wellesley.edu/~pmwh/mvmap/papers/open_world_elements/open_world_elements.html
- Game Developer, "Realism and legibility in open world level design": https://gamedeveloper.com/design/realism-and-legibility-in-open-world-level-design
- Robert Yang, "Open world level design: spatial..." (CEDEC 2017 summary), fetched: https://www.blog.radiator.debacle.us/2017/10/open-world-level-design-spatial.html
- Gigazine (snippet): https://gigazine.net/gsc_news/en/20171004-breath-of-the-wild-design-secret
- GamingBolt (snippet): https://gamingbolt.com/?p=308598
- Game Developer, BotW gravity analysis (snippet): https://gamedeveloper.com/design/breath-of-the-wild-open-world-analysis-gravity-to-go-forward
- GMTK, "How Nintendo solved Zelda's open world problem" (snippet): https://gmtk.substack.com/p/how-nintendo-solved-zeldas-open-world

Journey:
- Computer Graphics World, "Mysterious Journey" (snippet): https://www.cgw.com/Publications/CGW/2012/Volume-35-Issue-4-June-July-2012/Mysterious-Journey.aspx
- The Ringer (snippet): https://www.theringer.com/2022/3/11/22966978/journey-jenova-chen-thatgamecompany-video-games-art
- Game Developer, "Pixel pilgrim" (snippet): https://www.gamedeveloper.com/design/pixel-pilgrim-exploring-journey

Loops and shortcuts:
- Boss Keys, "The World Design of Dark Souls" transcript (snippet): https://amara.org/subtitles/4zZSGmv4Qxsz/en/1/download/The%20World%20Design%20of%20Dark%20Souls%20%20Boss%20Keys.en.txt
- Game Developer, "Cutting through the fog of Dark Souls" (snippet): https://www.gamedeveloper.com/design/cutting-through-the-fog-of-dark-souls-part-one-
- PC Gamer, "Elden Ring's smartest trick is scale" (snippet): https://www.pcgamer.com/uk/elden-rings-smartest-trick-is-scale

The classic region (snippets):
- Saffron City: https://bulbapedia.bulbagarden.net/wiki/Saffron_City
- Guardhouse: https://bulbapedia.bulbagarden.net/wiki/Guardhouse
- Esports.gg guide: https://esports.gg/guides/pokemon/how-to-get-past-the-saffron-city-guard-in-pokemon-firered-leafgreen/
- Mt. Coronet: https://bulbapedia.bulbagarden.net/wiki/Mount_Coronet
- Spear Pillar: https://m.bulbapedia.bulbagarden.net/wiki/Spear_Pillar
- Diglett's Cave: https://bulbapedia.bulbagarden.net/wiki/Diglett's_Cave
- Kanto Route 20: https://bulbapedia.bulbagarden.net/wiki/Kanto_Route_20
- Seafoam Islands: https://bulbapedia.bulbagarden.net/wiki/Seafoam_Islands
- Cerulean Cave: https://bulbapedia.bulbagarden.net/wiki/Cerulean_Cave
- Thonky, Power Plant: https://thonky.com/pokemon-lets-go/power-plant
- Brick Bronze, outlying islands: https://brickbronze.fandom.com/wiki/File:Frigidia_Island.png

A Short Hike (snippets):
- GDC Vault: https://gdcvault.com/play/1026613/Independent-Games-Summit-Crafting-A
- 80.lv summary: https://80.lv/articles/gdc-a-short-hike-postmortem

Biome transitions (snippets):
- Unreal forum, Fortnite biomes: https://forums.unrealengine.com/t/how-does-fortnite-created-different-biomes-on-a-tiled-landscape/152006
- Khora devlog, colour mapping: https://dormarr.itch.io/khora/devlog/809662/05-colour-mapping-tiles
- Westeroscraft planning notes: https://forum.westeroscraft.com/goto/post?id=17769
- Planet Nomads interview: https://www.gamedeveloper.com/production/creating-biomes-for-a-sci-fi-sandbox-game-interview-with-planet-nomads-art-director

Roblox:
- SLIM (fetched): https://create.roblox.com/docs/workspace/streaming/slim
- Model, LevelOfDetail and ModelStreamingMode (fetched): https://create.roblox.com/docs/reference/engine/classes/Model
- ModelLevelOfDetail enum: https://create.roblox.com/docs/reference/engine/enums/ModelLevelOfDetail
- Atmosphere: https://create.roblox.com/docs/reference/engine/classes/Atmosphere
- Sky (fetched): https://create.roblox.com/docs/reference/engine/classes/Sky
- Clouds (fetched): https://create.roblox.com/docs/reference/engine/classes/Clouds
- DevForum, client-side lighting zones: https://devforum.roblox.com/t/changing-lighting-on-the-client-side-when-stepping-into-different-zones/3597161
- DevForum, ZonePlus: https://devforum.roblox.com/t/zoneplus-v320-construct-dynamic-zones-and-effectively-determine-players-and-parts-within-their-boundaries/1017701/566
- DevForum, Atmosphere tween issue: https://devforum.roblox.com/t/atmosphere-bugs-out-when-transitioning-using-tweens/2841565
- DevForum, Realistic Dynamic Lighting (lerp vs tween): https://devforum.roblox.com/t/2837777
- DevForum, skybox transitions: https://devforum.roblox.com/t/how-would-i-make-a-transition-between-skyboxes/1835568

Repo:
- Plan 12 and its sources.
- `src/server/World/Dressing.luau` (today's mood values).
- `src/shared/Layout.luau` (`Layout.world` siting).
- The map sheets in `src/content/map_data/`.
