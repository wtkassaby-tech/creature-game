# 12 · Map structure: from a lane on a lawn to a world with walls, levels and turns

Ayrton, after playing: "review structure of maps, it feels too open and direct path. Review the Project Pokemon map and try and base the structure of the map off that, so it feels like a more dynamic world, rather than a flat baseplate in a path."

This plan does four things:
1. Says what the classic layout does, with sources and numbers (section 1).
2. Says why our three maps feel open and direct (section 2).
3. Sets out the principles and the new pieces the data model and builders need (sections 3 and 4).
4. Redesigns Greenwood first (section 5), then gives the pattern for Dust Canyon and Tide Flats (section 6).

It keeps every place the server checks, and every existing story id, tamer id and route length.

Plans 08, 09 and 10 still hold for content: towns, buildings, people, names and colours. This plan changes the shape of the ground they stand on. Where it conflicts with 08's "Optional Birch Rise terrace" or the corridor half-widths in 08, 09 and 10, this plan wins. Every [Default] it changes is logged in `docs/DECISIONS.md` when built.

Conventions are as in plan 08:
- Studs, with the town centre at (0, 0).
- North is -z.
- Facings are degrees clockwise from north.
- Walking speed is 16 studs a second.
- One classic map cell, one step, is taken as 5.5 studs.

## 1. Research: how the classic layout is built

### 1a. Project Pokemon itself

Very little of Project Pokemon's layout survives in text.

What can be sourced:
- It was a 3D copy of the first handheld region, played to eight gym badges, by the Roblox creator wish_z. It was removed in August 2018. (Roblox fandom community page; Project Pokemon fandom wiki)
- Its fan guide mentions warps between areas: "a house at the bottom of Route 5 that teleports players" to the next city, and an NPC who teleports you to a social hub. That suggests separate areas joined by doors and gatehouses, not one open world. This is inferred; nothing confirms it.
- Nothing written survives on its camera, its fog, or its exact sizes.

Its structure is therefore best read from the game it copied, whose map data is public (the pret disassembly), and from its Roblox successors Brick Bronze and Loomian Legacy:
- Brick Bronze's first route was kept "mostly the same" in Loomian Legacy. It is a short S-shaped path with grass patches between the bends, and starts at the end of the bridge over the starting town's creek. Leaving town, the player first meets a small grass patch, then a first trainer shortly after.
- Brick Bronze Route 2 starts at a bridge over a river channel. Beside the bridge is a climbable rock slope with grass on top, and the route ends at a gatehouse.
- Brick Bronze Route 3 opens with a trainer by the gate, then a wide grass field split into two passages by a rock pillar, with a trainer on one passage.
- Loomian Legacy's Route 5 is built round a staircase climbing from the previous route to a village.

So the Roblox games kept the handheld structure in 3D: bridges, slopes you climb, pillars that split a path, stairs between levels, and gatehouses at the ends. (All Fandom pages were read through search snippets: the sites refused automated fetches.)

### 1b. The handheld structure, with numbers

| Finding | Number | Source |
| --- | --- | --- |
| Maps are built from blocks of 2 by 2 walking cells. | | pret wiki; vjeux.com |
| Starting town | 20 × 18 cells, about 110 × 100 studs | pret `map_constants.asm` |
| First route | 20 × 36 cells, about 110 × 200 studs | pret `map_constants.asm` |
| Second route | 20 × 72 cells | pret `map_constants.asm` |
| East-west route | 70 × 18 cells: long and thin | pret `map_constants.asm` |
| First forest | 34 × 48 cells | pret `map_constants.asm` |
| Screen | 10 × 9 cells (later 15 × 10). You see about 5 cells, roughly 27 studs, around you. | blakecrosley.com |
| Towns | 60% walkable. One exit, two cells wide. First door about 12 cells from the entrance. Corridors 3 to 7 cells wide, narrowing to 2 to 3. | blakecrosley.com |
| Trainer sight | 1 to 4 cells (Route 3's eight trainers) | pret `Route3.asm` |
| Route 1 trainers | None: two wandering people and a sign | pret `Route1.asm` |
| Ledges | One-way: you hop down and cannot climb back. Route 1 winds in an S round grass and long ledges. | Bulbapedia, Ledge; Bulbapedia, Kanto Route 1 |
| Route shape | "Long, narrow, and sometimes winding", with rocks, trees and ledges as obstacles | Bulbapedia, Route |

### 1c. Why it works, in fan and design commentary

- **Ledges make a one-way loop on each bend.** On the first route there are about five, and they are the quick way home once you reach the next town. (Fantendo analysis of early routes; the Johto remakes' Route 38 ledges, PokeCommunity)
- **Grass is best as a choice.** Players mark routes down for blocky grass and for grass they are forced to walk through. They like choosing when to risk an encounter. (Fantendo; Geek to Geek; PokeCommunity on Unova)
- **Dead ends pay off later.** A path that looks like a dead end loops back as a shortcut once you have a new ability, tying the world together. (Hoenn analysis, obsidian notes)
- **Small, dense spaces.** Older games pack a lot into small spaces with few tools. Almost everything you see does a job (grass, canyon walls), and small memorable scenes stick. (melodicambient newsletter)
- **Short cliffs stop the straight walk.** Small cliffs and ledges stop you walking straight between a route's exits (Hoenn Route 113; snippet, source page unnamed).

### 1d. What this means in studs

These come from the numbers above at 5.5 studs a cell. They are targets, not data.

| Thing | Classic | Our target |
| --- | --- | --- |
| Walkable width of a route | 3 to 7 cells | 16 to 40 studs (half-width 8 to 20). Pinch points 12 to 16. Grass fields up to 60. |
| How far you see along a route | 5 to 7 cells | 40 to 80 studs before a bend, wall or rise hides what is next |
| Grass patch | about 4 × 4 to 8 × 6 cells (inferred from maps; not sourced) | a circle of radius 20 (40 across) or a strip 40 wide: about 2 to 5 seconds to cross |
| Tamer sight | 1 to 4 cells | 6 to 22 studs, in a lane 8 wide |
| Ledge | one tile high | 10 studs: above the default jump of 7.2, so it cannot be climbed back |
| Town | 110 × 100 studs, 60% walkable, one 2-cell exit | ours stays 300 square but walled, with exits 18 wide |
| Route footprint | 110 × 200 studs for the first route | a route of 400 studs of path folds into about 230 × 200 |

## 2. Why ours feel open and direct

Checked in the code on 23 November 2026.

| # | What the player sees | Where it comes from |
| --- | --- | --- |
| 1 | **Everything is flat.** One ground height in all three biomes. Dust Canyon's "Redstone Steps", "Sunbaked Rim" and "gorge far below" are flat colours at height 0. | `TestMap.buildBiome`: one 4-stud slab at y -2 per biome, 220 studs past the furthest place. No tier, ramp, ledge or height exists in `WorldTypes`, the sheets or `src/server/World`. |
| 2 | **A thin lane in a wide field.** Every lane is 14 wide inside a corridor 90 to 140 wide: the half-widths are 45 to 70, against a classic 8 to 20. The lane is a stripe on a lawn, not the way through. | `corridor` in `map_data/Greenwood.luau` (45 to 70), `DustCanyon.luau` (46 to 65), `TideFlats.luau` (35 to 65) |
| 3 | **Edges you can see and hop over.** | See below |
| 4 | **You see everything at once.** The camera keeps Roblox's default zoom limit (128 studs). From high up you see over the 7-stud hedges, down whole routes and across the open slab beyond. | No camera settings anywhere in `src/`. Atmosphere density is 0.3 (`Dressing.mood`). |
| 5 | **Each route is one line out.** The bends are gentle (legs of 40 to 90 studs, turning 20 to 50 degrees), and no route doubles back on itself. Each biome has one branch, the lair spur, and one side pocket. Nothing stops you walking straight to the end. | Waypoints in the three map sheets |
| 6 | **Grass is a blob beside the path.** There is one circle (r20) per stretch, seven per biome, most beside the lane, so it can always be walked round. The data model allows exactly one patch per stretch. | `Layout.grassId(area)`; `Encounters.grass` and `hideAt` read one point per area |
| 7 | **Water does not bound anything.** Rivers and the sea are flat parts that cannot be collided with, lying over walkable ground, so you can walk across the river beside River Road. | `Water.luau`; plan 08 section 5 ("Not collidable") |
| 8 | **Tamers only wait.** They stand to one side with a button and never step out or watch a path. Nothing is guarded. | Prompt only; `ENGAGE_RADIUS` 16 |
| 9 | **The town is a lawn with a hedge round it.** It is 300 square with gaps 28 wide at the arches and wide empty corners. The way out is a gap in a hedge, not a gate. | `GreenwoodDressing.hedges`, `arches` |

Edges you can see and hop over (row 3) come from `Fences.hedge`, `Edges.luau`, `Corridors.edges` and `Props` (painted models have `CanCollide = false`):
- **The hedge's blocking core is 4.8 tall** and the bushes on it cannot be collided with. A character jumps 7.2, so a hedge can be hopped.
- **Boulder banks** have a core 6 tall, so they can be hopped too.
- **Past the edge is open field:** one row of trees every 12 to 16 studs, and then flat open ground to the horizon. That is the "baseplate".

In short, the map is a drawing of a route laid on an open plain. In the classic layout the route is cut out of solid ground: forest, cliff and water fill everything that is not path. You only ever see the space you can walk in, and the next thing round the bend.

## 3. Principles

1. **Carve, do not draw.** Every biome is solid (forest, rock, cliff, deep water) except the spaces carved for walking. The builder fills everything within 80 studs of walkable space. Beyond that there is nothing to see, because no viewpoint can see over the fill.
2. **Narrow lanes, wide rooms.** A route is a chain of narrow lanes (16 to 32 across) and rooms: grass fields, clearings, the space at a bend. Pinch points are 12 to 16 across and have a reason: stairs, a bridge, a gap between rocks, a tamer.
3. **Walls hold.** Every wall's blocking core is at least 10 tall (more than a jump) and solid along its whole length. What shows on top is 24 to 35 tall, so the camera cannot see over it.
4. **Levels, not slopes.**
   - The ground comes in tiers 10 studs apart: 0, 10, 20 and 30.
   - Stairs and ramps join tiers both ways.
   - One-way **ledges** let you hop down a tier.
   - Every route climbs away from home, so its ledges face home: the way back is quicker and can skip grass.
5. **Fold the route.** Each route has at least two switchbacks or hooks, so its 400 to 680 studs of path fit a footprint about a third of that across. A tier or a wall between two legs keeps them apart. You often see the lane you will walk later, above or below you, and cannot reach it yet.
6. **Grass you choose, and grass you cross.**
   - Each route has one field you must cross going out, about 3 to 5 seconds of walking. Coming home, a ledge skips it.
   - Every other patch has a way round.
   - No grass ever lies across a tier edge.
7. **Every branch pays.**
   - Each route has at least two side branches: a dead-end pocket, a ledge lane or a hidden gap.
   - Each ends in something: a rustle spot, a view of the landmark, a bench and a note, a seen-but-shut place, and later a find (section 7).
8. **Tamers guard and watch.**
   - One or two tamers per route stand at a true pinch point (the top of stairs, a bridge, a narrow cut) and cannot be passed unseen.
   - The rest stand in rooms where you can walk round them.
   - Each faces the way players arrive.
9. **Show it, hide it, show it again.**
   - The biome's landmark (the ancient tree, the Redstack, the lamp tower) shows only through planned windows: a lower wall, a high terrace, a meadow far from its walls.
   - It is hidden in between.
   - The camera never shows a whole route.
10. **Gates are narrow.** A town connects to a route through a neck: an arch in a wall of trees or rock, 18 wide, then 30 to 40 studs of lane before the route opens. Every crossing between areas is a doorway, never a gap in a hedge.
11. **Water is a wall until it is not.** Rivers, ponds and the sea block, unless crossed by a bridge or stepping stones, or marked shallow for wading. You can see across water to places you cannot reach yet.
12. **Cosy, not hard.** Walls are trees, hedges, cliffs and stone walls in the painted clay-toy style, with flat warm colours and rounded edges. Nothing is a grey invisible wall. Lanes stay lit, the fill is dark green under a soft canopy, and no maze needs a map to solve.

## 4. What the data model and the builders need

### 4a. Map sheet additions (shared, read by tests and the server)

These go in `src/shared/WorldTypes.luau`. They are walkable shape and height, so they belong in the map sheet, which is tested, and not in the dressing sheet:

```luau
export type Shape =
	{ kind: "Disc", at: SheetPoint, r: number }
	| { kind: "Box", at: SheetPoint, size: { number }, turn: number? } -- size = { across, deep }
	| { kind: "Poly", points: { SheetPoint } } -- convex, clockwise
	| { kind: "Strip", from: SheetPoint, to: SheetPoint, r: number } -- a segment widened by r (round ends)

export type Tier = { id: string, height: number, shape: Shape } -- later entries win where they overlap
export type Link = {
	kind: "Stairs" | "Ramp" | "Ledge", -- stairs and ramps go both ways; a ledge only from high to low
	from: SheetPoint, to: SheetPoint, -- along the line you walk (a ledge: along the lip, high side on the left)
	width: number,
}
export type Room = { id: string, shape: Shape } -- walkable space joined to a route: fields, pockets, clearings
export type GrassPatch = { at: SheetPoint, to: SheetPoint?, r: number } -- a circle, or a strip from `at` to `to`
export type WidthKey = { at: number, half: number } -- a half-width at a distance along the route

-- New optional fields on MapSheet:
tiers: { Tier }?,
links: { Link }?,
rooms: { Room }?,
widths: { [string]: { WidthKey } }?, -- by route id (and lair id); between keys the width eases
                                     -- linearly; left out, `corridor` by area as now
grass: { [string]: { GrassPatch } }?, -- by area id; replaces `places[area_grass]` when given
mustCross: { [string]: string }?,     -- route id -> the area whose grass every way out crosses
sight: { [string]: number }?,         -- tamer id -> how far they see along their facing (studs)
```

**`src/shared/Ground.luau` (new, pure, no Roblox services).**
- `Ground.heightAt(sheet, origin, point): number` returns the tier height at a flat point, easing along a stair or ramp.
- `Ground.edges(sheet, origin)` returns every tier edge segment, with its kind: wall, ledge, stairs or ramp.
- Builders, tests and the client use it in place of guessing 0.
- The wild-creature view (`WorldView.groundHeight`) can keep its raycast, but can fall back to this when ground has not streamed in yet.

**`src/shared/Walk.luau` (new, pure).** A grid of 4-stud cells over a biome.
- A cell is walkable if it lies in the town, a corridor (line plus half-width), or a room.
- It is not walkable if it lies under a building's footprint, a wall, a fence marked `across`, or water with no bridge.
- Two neighbouring cells connect if:
  - they are the same height;
  - a stair or ramp joins them; or
  - a ledge lets you go down from the first to the second.
- It answers three questions: can you get from A to B, every cell you can reach, and is there a way from A to B that avoids a set of shapes.
- It is used only by the tests and the builders: the server's checks do not change.

**Layout.** `Layout.build` copies the shifted `grass` patches to `map.grass[areaId]`, as a list of world shapes. `map.places[area_grass]` stays the first patch's centre, so every existing id and test keeps working, and later patches are named `{area}_grass_2`, `_3` and so on. Everything else in `Layout` is unchanged.

### 4b. Dressing sheet additions (looks only)

| Field | What it does |
| --- | --- |
| `fill = { style, band, floor }` | `"Forest"`, `"Rock"`, `"Dune"` or `"Sea"`. `band` (80) is how deep the fill goes past the edge of walkable space. `floor` is the colour of any ground glimpsed under the canopy. Replaces the single row of trees outside every edge. |
| `tierFaces = { [tierId]: "GrassBank" \| "Cliff" \| "Stone" \| "SeaCliff" }` | The face shown on a tier's sides. Ledges always get the ledge lip. |
| `windows = { { from, to, tall } }` | Stretches of wall kept low (bushes 6 to 10 tall over a 10-tall core) so a landmark shows. |
| `hidden = { { from, to } }` | A hidden gap: two wall pieces overlap with a 6-wide walkable gap between them, and it looks solid from the lane. |
| `bridges = { { from, to, width, style } }` | Plank or stone bridges. The ground under them stays water. |
| `wade = { Shape }` | Shallow water: walkable, with a wading look. Everywhere else, water blocks. |

### 4c. New builders (`src/server/World/`, keep each under ~400 lines)

1. **`Tiers.luau`.**
   - Each tier's top is a flat slab: a Box as one part, a Poly as wedge-pair triangles, a Disc as a cylinder. It is coloured from the stretch's ground.
   - Its sides wear the face style. The plain stand-in is a block at the tier's height. The painted pieces are `GrassBank` (40 long, 10 tall) and the existing `CliffWall`.
   - Each wall edge gets a lip on top: a low hedge or stone kerb with a 10-tall core, so you cannot walk off it.
   - A ledge edge gets the `LedgeLip`: a rounded grass rim 1 tall, with a little notch of trodden earth where the lane meets it.
2. **`Links.luau`.**
   - Stairs are painted `StoneStairs` or `TimberSteps` over a hidden wedge collider, because a character cannot step up 10 studs of risers.
   - Ramps are a wedge with a dirt lane on top.
   - Each has rails or rock cheeks on both sides.
3. **`Fill.luau`.**
   - Puts the painted `ForestWall` (40 long, 30 tall, 14 deep: tree crowns fused over trunks) end to end along every boundary of walkable space, on a solid invisible core 12 tall.
   - Fills the band behind it on a 40-stud grid with `ForestBlock` canopy masses on a dark floor.
   - Rock biomes use `CliffWall` and a new `MesaBlock`; the coast uses `SeaCliff` and dunes.
   - This replaces the trees that `Corridors.edges` plants, and the hedge as a route edge. Hedges stay inside towns and gardens.
4. **`Corridors.edges`.** Takes half-widths from `widths`, treats rooms and tiers as walkable, and stops drawing edges where a tier face already bounds the space.
5. **Heights everywhere.** Lanes, grass, people, signs, lamps, props, fences and water take their height from `Ground.heightAt`, not 0 or the raycast in `Markers.groundAt`. Water steps down a tier as a little waterfall (`Water.fall`) where its line crosses a tier edge.
6. **Water blocks.** Where water borders walkable space with no bridge or wade, a solid invisible barrier 10 tall stands 1 stud into the water, with rope-and-post or reed dressing on the bank.
7. **Grass.**
   - `Grass.patch` takes a `GrassPatch`: a circle or a strip.
   - It uses a new `GrassClump` model (about six tufts in one mesh) on a 7-stud grid, so a patch is about 30 pieces instead of 95.
   - The dark ground under it is exactly the server's shape, as now.
8. **Battle scene (client, `BattleStage`).**
   - `clearAround` and `inTheWay` skip anything tagged `WorldGround`. Tier slabs, stair colliders, ledge lips and wall cores are less than 100 wide and would otherwise vanish mid-battle.
   - Pads take their height from the raycast, as now.
   - The tests keep every grass patch at least 8 studs, and every tamer at least 16, from a tier edge, so both pads land on one level. Measure the pads' spread in Studio and raise the 8 if a pad can reach past it.

### 4d. Camera and sightlines (config in `src/config/CameraConfig.luau`, new)

- `MAX_ZOOM = 40` and `MIN_ZOOM = 8`, set on `StarterPlayer.CameraMaxZoomDistance` and `CameraMinZoomDistance` when the server starts (both are real `StarterPlayer` properties).
  - At 40 studs behind and above the player, a 30-tall wall 25 or more studs away hides everything behind it.
  - You see the room you are in, the lane to the next bend, and over a ledge to the tier below.
  - This is a [Default]: tune it in play. 35 to 45 is the sensible range.
- The battle camera is separate (`BattleStage`) and unchanged.
- Atmosphere stays at density 0.3. The walls do the hiding, and haze only softens the landmark and the skyline.
- The ground beyond the fill turns forest-floor dark (`fill.floor`), so any glimpse through a gap reads as wood, not lawn.
- **Landmark windows.** For the landmark's top to clear a wall, the wall must be at least `(wall tall − eye height) × distance to landmark ÷ (landmark tall − eye height)` away from the viewpoint, or be a low `window`.
  - Example: with an eye 20 up, a 30-tall wall and the 160-tall ancient tree 730 away, the wall must be at least 52 studs off.
  - The test in section 8 checks this for each "Sight" story beat.

## 5. Greenwood, restructured

Route lengths (400, 600), stretch ranges, rustle-spot and tamer `at`s, the lair spur (250 from 330 on Route B) and the gate at (684.4, -80) are unchanged. Dust Canyon and Tide Flats are sited from that gate, so they do not move. Every building, door, plaza and spawn in Thistledown is unchanged. Only route waypoints, widths, the grass, set spots and the new tiers, links, rooms and fill change.

### 5a. Thistledown: a walled town with two levels and narrow gates

- **The edge.** The hedge loop at ±150 becomes a `ForestWall` loop on the same line. The garden hedges stay. The empty corners get orchard and forest fill, so the walkable town is about 230 × 200 and every corner holds something: the pond, the orchard, the Ring or the hamlet lanes.
- **Mentor's Rise, a tier 8 high.** It is a Box from (-46, -150) to (46, -50) and holds the mentor's cottage, the orchard and the vegetable patch.
  - The north lane climbs to it as `Stairs` from (0, -34) to (0, -50), 10 wide, with lamps on both cheeks.
  - Its south face is a stone retaining wall with a flower box along the top.
  - The mentor's door (0, -64) is 14 inside the edge. The spawn view north then shows the rival, the stairs and the cottage above the plaza: a framed goal, the classic opening.
  - The rise is 8, not 10: it is two-way town furniture, not a ledge.
- **The gates.**
  - The west and east arches stay at (∓142, 0), but the wall closes to an 18-wide gap.
  - Past each arch runs a **neck**: 36 studs of lane, half-width 9, between `ForestWall`s. Route A's neck ends at Pip's lane; Route B's opens on the river bank.
  - The north-east wicket (shut) stays as the lair shortcut's end.
- **Water.**
  - The brook comes down from the west into town, as now, under the footbridge, and into the pond.
  - The river across the south-east corner gets its barrier, and so does the pond. The jetty is a short walkable pier.

### 5b. Route A, "Clover Lane": an S that climbs to a terrace, with a ledge home

Approximate sketch: 20 studs per character across, 20 studs per line down; the tables are what counts.

```
        x -400     -360      -320      -280      -240      -200      -160
z -160   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^    ^ forest fill (ForestWall at its edge)
z -120   ^^  spring plateau, tier 20: seen, never reached   ^^^^^^^^^^^^^^^^^
z  -80   ^^ ######### W #############################  ^^^^^^^^^^^^^^^^^^^    # cliff face   W waterfall
z  -60   ^^ ~~~~~~~~~ o ~~~~~~~~~~~~~~~~~~~~~~ x(end) ~W ^^^^^^^^^^^^^^^^^^    ~ brook  o pool  x old fence
z  -40   ^^ |  terrace, tier 10     r            |   ~~ ^^^^^^^^^^^^^^^^^^^    r reed bed (rustle)
z  -20   ^^ |=P6===========Wren=========P7=====/    ~~~ ^^^^^^^^^^^^^^^^^^^
z    0   ^^ S  v v v v v v v v v v v v v v v |  ^^^^^^ ~~ ~~ =P1====P0== A    S stairs  v ledge (hop south)
z   20   ^^ S  ledge lane .............bench: ......:.... Pip  g             A west arch  g glade grass (optional)
z   40   ^^ P5 hhhhhhhhhhhhhhhhhhhhhhhhhhhh:   P2          g g               h hedge row
z   60   ^^ :  GGGGGG P4 GGGGGGGGGGGGGGG P3 ^^^^^^^^^^^^^^^^^^^               G meadow grass you must cross
z   80   ^^ :  clover meadow, tier 0      : ^^^^^^^^^^^^^^^^^^^
z  100   ^^^^^^^^^^^^^^^^^^^^ :picnic: ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
z  120   ^^^^^^^^^^^^^^^^^^^ (hollow) ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
```

**How it plays, in order:**
1. Out of the west arch and through the neck. The glade lane runs west in a 28-wide cut. To the south is a glade pocket with a small optional grass patch, the teaching signpost at its edge.
2. At the first bend Pip watches the lane from a knoll.
3. The lane drops a little south-west into the **clover meadow** basin. Its grass fills the basin wall to wall: the must-cross field, about 4 seconds of walking.
4. Above the meadow's north side is the terrace's ledge face. You can see the lane you will walk later, ten studs up, and cannot reach it.
5. At the meadow's west end, **stairs** climb north to the terrace.
6. The terrace lane runs back east beside the brook. Wren guards the pinch where the brook meets the ledge lip. The reed bed rustles in the brook's shallows.
7. The lane hooks north-east to the old fence under the spring cliff and its waterfall: the end, seen but not passed.
8. **Home:** walk back west a few steps and hop the ledge south into the **ledge lane**, a grass-free strip under the terrace. It runs east, behind a hedge row that keeps it apart from the meadow, and comes out by Pip's bend.

**Branches and rewards:**
- **The glade pocket:** the first grass, and the sign.
- **The ledge lane's west end:** a dead end under the terrace if you walk in from below. It holds a bench under the waterfall's spray and a lore note (dressing; later a find).
- **The picnic hollow:** a dead end off the meadow's south side through a 10-wide gap. It holds a ring of trees, a bench, and a `window` in the wall framing the ancient tree for the `giant_glimpse` beat.
- **A hidden gap** in the meadow's west wall leads to a 20-stud nook with a single apple tree (dressing; later a find).

**Route A waypoints.** They sum to 402.7 and are fitted to 400, ending at (-276.3, -49.6). The stretch ranges are unchanged: glade 0–130, meadow 130–270, brook 270–400.

| Point | x, z | Along | What |
| --- | --- | --- | --- |
| P0 | -150, 0 | 0 | West arch |
| P1 | -200, -5 | 50 | Neck ends; glade lane |
| P2 | -235, 25 | 96 | Pip's bend |
| P3 | -270, 55 | 142 | Into the meadow |
| P4 | -340, 60 | 213 | Mid-meadow (`clover_meadow` = along 200, about (-327, 59)) |
| P5 | -370, 30 | 255 | Foot of the stairs |
| P6 | -360, -15 | 301 | Top of the stairs, terrace (tier 10) |
| P7 | -290, -25 | 372 | Terrace east end |
| P8 | -275, -52 | 400 (fitted) | The old fence |

**Route A widths** (`widths.greenwood_route_a`, `{along, half}`):

| Along | Half | Note |
| --- | --- | --- |
| 0 | 9 | Neck |
| 36 | 9 | Neck |
| 50 | 14 | Glade |
| 120 | 14 | Glade |
| 135 | 18 | Meadow: the basin room makes it wide, and the grass strip (r 20) must cover the whole lane band, so the lane's half-width stays under 20 |
| 250 | 18 | Meadow |
| 256 to 278 | 6 | Stairs |
| 284 | 16 | Terrace |
| 322 | 16 | |
| 330 | 8 | Wren's pinch |
| 338 | 16 | |
| 400 | 18 | |

**Tiers:**

| Id | Height | Shape | Face |
| --- | --- | --- | --- |
| `clover_terrace` | 10 | Box from (-395, 8) to (-258, -75) | GrassBank |
| `spring_plateau` | 20 | Box from (-395, -75) to (-230, -170) | Cliff |

**Links:**
- Stairs (-369.3, 27) → (-364.9, 7.5), width 12.
- Ledge along the terrace's south lip, (-338, 8) → (-270, 8), width 68: the hop home. It lands only in the ledge lane.

**Rooms:**
- `glade_pocket`: Disc (-185, 26), r 24.
- `clover_basin`: Strip (-284, 58) → (-346, 58), r 20. It is exactly the grass strip, so the basin is grass from wall to wall.
- `ledge_lane`: Box from (-340, 9) to (-245, 22).
  - It joins the glade lane near P2.
  - It stays at least 26 studs from the meadow lane where that lane leaves for the stairs (P4 to P5), so the grass cannot be skipped going out.
  - The hedge row along z 30 is only looks: the ground between the two is not walkable.
- `brook_glade`: Disc (-345, -42), r 18, on the terrace.
- `picnic_hollow`: Disc (-300, 106), r 16, joined by a Box from (-305, 80) to (-295, 92).
- `apple_nook`: Disc (-385, 66), r 10, behind a `hidden` gap.
- The town neck and the corridor make up the rest.

**Grass and the server's spots:**

| Id | Shape | Note |
| --- | --- | --- |
| `mossy_glade_grass` | Circle (-185, 26), r 18 | Optional, in the pocket |
| `clover_meadow_grass` | Strip (-284, 58) → (-346, 58), r 20 | Must cross; `mustCross.greenwood_route_a = "clover_meadow"` |
| `brook_bend_grass` | Circle (-345, -42), r 16 | In the brook glade, north of the lane; optional |
| `reed_bed` | (-300, -42) | Rustle spot, in the brook shallows |
| `gw_pip` | (-228, 33), faces 60 | |
| `gw_wren` | (-329, -19), faces 270 | Faces players arriving from the stairs; the pinch |

Spacing checks to confirm in the test:
- Wren to the reed bed: 37 (at least 32).
- Wren to the brook grass centre: 28 (at least 26).
- Pip to the glade grass centre: 44 (at least 26).
- Wren is 27 from the terrace lip and Pip is 11 from his route (at most 12).
- The `route_one` entry is at along 30, (-180, -3): past the arch, inside the neck.

**Water.**
- The brook rises in the spring pool on the plateau and drops 10 by a waterfall at (-300, -75) into a terrace pool at (-300, -62).
- It runs east along the terrace's north side.
- It falls again off the terrace's east face at (-258, -40) to tier 0.
- Then it winds south-east through the fill, crossing under the glade lane by a plank bridge at (-210, -2), and on to town as now.

### 5c. Route B, "River Road": river bank, a switchback climb, the old wood, steps down to the gate

```
        x 150        250        350        450        550        650
z -300                   (Hollow, tier 10 bowl, cliff ring, ancient tree on the N rim)
z -200                        \  spur: tier 20, narrow, down stairs into the bowl
z -120                          \    ^^^^ old wood, tier 20, half 12 ^^^^
z  -80            ^^^^^ B5==B6===B7====B8======B9====B10 S== B11 == hamlet === GATE  (684, -80)
z  -60            ^^^^ R/  vvvvvvvvvvvvvvv shelf (10) ^^^^^^^^^^ Corwin     ^^^^
z  -30          ^^^ B4 /  ...shelf, tier 10....   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
z    0   A=====B1=====B2==B3   vvvvvvvvvvvvvvvvvv  (ledges down to the bank)
z   20      sandy bank, tier 0  .......bank strip.......
z   50   ~~~~~~~~~ river (blocks; heron inlet; one plank bridge to a sand spit) ~~~~~~~~~~~
```

**How it plays:**
1. Through the east neck to the **sandy bank**: tier 0, with the river as its south wall and two optional marram patches. Odette watches the bend at B2.
2. A ramp climbs to a tier-10 **switchback** below a birch slope. The birch rise grass fills the turn: the must-cross field.
3. A second ramp climbs to the tier-20 **ridge**, with Basil at its head.
4. The ridge runs east. Its south lip is a ledge to a tier-10 **shelf**, and the shelf's south lip is a ledge to the bank strip, which runs west to rejoin the bank lane. That is the way home past the birch grass. From below, the bank strip is a dead end under the ledges, and it holds the heron pool's view across the river.
5. At along 330 the **lair spur** forks north. The lane enters the **old wood**: tier 20, half-width 12, dark floor, canopy fill pressing in, two side clearings (the burl thicket, and the wood's grass).
6. At its east end, Corwin stands at the head of **stone steps** down to tier 10. This is the route's one unavoidable tamer.
7. A ramp drops to tier 0, and the **gatehouse approach** runs through the hamlet to the gate.

**Route B waypoints.** They sum to 599.3 and are fitted to 600 by stretching the last leg 0.7, so the gate lands at (684.7, -80). A test pins the gate within 0.5 of (684.4, -80); if it fails, move B4 by a stud.

| Point | x, z | Along |
| --- | --- | --- |
| B0 | 150, 0 | 0 |
| B1 | 205, 12 | 56 |
| B2 | 260, 18 | 112 |
| B3 | 295, 0 | 151 |
| B4 | 290, -29 | 180 |
| B5 | 330, -62 | 232 |
| B6 | 385, -72 | 288 |
| B7 | 420, -95 | 330 |
| B8 | 468, -108 | 380 |
| B9 | 515, -98 | 428 |
| B10 | 556, -84 | 471 |
| B11 | 600, -80 | 515 |
| B12 | 684, -80 | 600 (fitted) |

**Widths:**

| Along | Half | Note |
| --- | --- | --- |
| 0 to 36 | 9 | Neck |
| 40 to 125 | 22 | Bank |
| 130 to 150 | 7 | Ramp 0 → 10, on the last of the bank leg |
| 155 to 205 | 14 | Switchback turn, all grass (the strip, r 18, covers the whole band) |
| 210 to 230 | 7 | Ramp 10 → 20 |
| 236 to 330 | 18 | Ridge |
| 330 to 466 | 12 | Old wood |
| 470 to 490 | 6 | Steps 20 → 10 |
| 494 | 14 | |
| 505 to 520 | 7 | Ramp 10 → 0 |
| 525 to 600 | 20 | Approach |

**Tiers** (approximate: the exact outlines are set in the editing pass, and the reach tests decide):

| Id | Height | Shape |
| --- | --- | --- |
| `birch_switchback` | 10 | Poly round the turn at B3 and B4, from along 150 to 210 |
| `ridge_and_wood` | 20 | Poly from the top of the second ramp (along 230) to the head of the steps (along 470), about 20 each side of the lane, plus the spur's first 180 studs |
| `birch_shelf` | 10 | A strip about 20 deep under the ridge's south lip, from about x 340 to 425 |
| `hollow` | 10 | The arena bowl, Disc r 80 round the lair, ringed by the rim (30) on its north |

**Links:**
- Ramps: along 130–150, 210–230 and 505–520.
- Stairs: along 470–490, and on the spur at 180–200 down into the bowl.
- Ledge: the ridge's south lip, about 20 south of the lane, from along 240 to 320, down to the shelf.
- Ledge: the shelf's south lip, down to the bank strip.
- The switchback's own south edge is a wall.

**Rooms:**
- `bank_strip`: tier 0, under the shelf and south of the switchback. It runs from about (290, 15) to (425, 35), between the ledges and the river barrier, and joins the bank lane near along 115. Walked into from the bank it is a dead end, with the heron inlet's view across the water.
- `heron_inlet`: Disc (231, 40), r 12.
- `burl_clearing`: Disc (489, -126), r 16.
- `wood_glade`: Disc (500, -78), r 20.
- `hamlet_square`: Box from (630, -110) to (670, -50).
- A plank bridge from (240, 48) south over the river to a sand spit, with a view of the river and the hamlet.

**Grass and the server's spots:**

| Id | Shape | Note |
| --- | --- | --- |
| `sandy_bank_grass` | Circle (214, -8), r 16 | Plus `_2` (250, 30), r 14; both optional |
| `birch_rise_grass` | Strip (291, -24) → (294, -32), r 18 | Must cross; at least 8 from both ramps; `mustCross.greenwood_route_b = "birch_rise"` |
| `old_wood_grass` | Circle (500, -78), r 18 | In the glade; optional |
| `gatehouse_approach_grass` | Circle (604, -104), r 16 | Beside the lane, as now |
| `heron_pool` | (231, 46) | Rustle spot |
| `burl_thicket` | (489, -128) | Rustle spot |
| `gw_odette` | (262, 26), faces 250 | Along 110 |
| `gw_basil` | (346, -71), faces 225 | Along 248, 18 past the ramp's head; his `at` is 220 (within 40) |
| `gw_corwin` | (541, -97), faces 250 | Along 455, at the head of the steps; the pinch |
| `rival_gate` | Stand (678, -80) | Unchanged |

The spur's waypoints are join (420, -95) → (405, -150) → (360, -190) → (330, -240) → (285, -285), fitted to 250. The stall stays at 40 up the spur.

**The Hollow.**
- The arena is a bowl on tier 10, ringed by a 25-tall cliff.
- The ancient tree stands on the north rim at (270, -362), on the rim tier (30), so its crown is seen from the meadow window and from the ridge.
- The shut shortcut leaves the bowl's east side as an overgrown ledge path to the town wicket. When `shortcutToHub` opens, it is one-way, down to the wicket: the classic loop home.

### 5d. Greenwood sightlines

| Place | What you see | What is hidden |
| --- | --- | --- |
| Spawn | The plaza, the rival, the stairs up to the mentor's rise, and the ancient tree over the north-east roofs (it is 440 away; the town wall is far enough off) | |
| West neck | Only the bend ahead | |
| Meadow | The terrace lane above, the stairs at the far end, and the ancient tree through the picnic window | Wherever the brook has gone |
| Terrace end | The waterfall | What is past the old fence |
| Bank | Across the river to the sand spit and the hamlet roofs far east, so the goal shows early | The ridge |
| Ridge | The tree again, over the old wood's canopy | |
| Old wood | Nothing but the lane, for about 140 studs | |
| Steps down | The gatehouse banner, framed by the trees | |

## 6. Dust Canyon and Tide Flats follow the same pattern

### Dust Canyon (plan 09)

- **Fill:** `"Rock"`. The cliffs are already the edge. Boulder-bank cores go from 6 to 10 tall.
- **Kilnrest:** on the canyon floor (tier 0). The Westcut becomes a real neck between cliffs, half-width 9. The Windward Overlook stands on a tier-10 shelf reached by steps, and is the town's view out.
- **Dry Wash Trail:**
  - The wash is a narrow floor (half 16) between cliffs, with grass in the wash's bends.
  - The Tumbleweed Flats sit on a tier-10 mesa reached by a rock ramp, a wide room with the must-cross dry grass.
  - The Hollow Arroyo is a slot canyon (half 10 to 14) with two ledges dropping back to the wash: the way home.
  - It ends at the broken rope bridge, seen across a gap.
- **Mesa Road:**
  - The Redstone Steps become real stairs: three flights, 10 each, from 0 to 30, as a switchback, with Perrin at the first landing.
  - The Sunbaked Rim runs along tier 30 with the gorge floor at 0, a real 30-stud drop. Its lip is a boulder wall, not a ledge, except at one marked ledge chain (30 → 20 → 10 → 0) down to a gorge-floor path. That path loops west to town as the way home.
  - The Spire Garden uses rock spires as pillars that split the lane in two (the Brick Bronze Route 3 pattern), with the must-cross grass in one branch and a longer bare way round in the other.
  - The Stair Approach climbs to tier 40 at the Stair Gate.
  - The gate stays at the same flat position, with its last leg due east.
- **The Redstack** is the window target, from the rim and from the Spire Garden.

### Tide Flats (plan 10)

- **Fill:** `"Sea"` on the seaward sides (water is the wall) and `"Dune"` or `"SeaCliff"` inland.
- **Saltwick** sits on two tiers: the quay at 0 and the upper street at 10 with the lamp tower. The Ferry Steps are real stairs. The harbour water blocks.
- **Strandline Path:**
  - The wrack beach is tier 0 under sea cliffs 30 tall, with a narrow sand lane between the cliff and the surf barrier.
  - The rockpool shelf is a set of rock terraces at 6 and 12 with pools in hollows, and ledges back down to the beach.
  - The kelp shallows are a `wade` area, the one place the sea can be walked: knee-deep, with kelp grass.
- **Breakwater Road:**
  - The sandbar causeway is a natural narrow (half 10) with water both sides, and Orrin on it.
  - The mudflat boardwalk is raised 4 over mud you cannot walk on, with Captain Marr's stand mid-boardwalk.
  - At Shipwreck Reach you walk round the bay: the wreck is seen from the causeway first, then hidden behind the dunes, then reached.
  - The Tideward Steps climb to the breakwater at 12 and the gate.
- **The lamp tower** is the window target.

Both keep their route lengths, `at`s and gates. The Tide Flats gate stays put so that the Mire's siting does not move.

## 7. How the server's rules are kept

1. **One source of positions.** `Layout` still makes every place. Every server check (`isNear`, grass, rustle, engage, story Enter and Sight, `mayEnter`, waking at the healer) stays flat (x, z). Heights are for the builders and the tests.
2. **One height per flat point.** No walkable layer passes over another: bridges cross water, never a lane. So a flat position always means one spot, and the server could later work out height with `Ground.heightAt` if it ever needs to.
3. **Nothing the server checks straddles a level.** Every place, prompt and grass shape lies wholly on one tier, at least 6 studs (prompts), 8 (grass) or 16 (tamers) from any tier edge. A player on a ledge above a patch therefore cannot be "in" it.
4. **Grass becomes a list of shapes (needs Ayrton's OK).**
   - `Encounters.grass` checks every patch of a stretch: the distance to a circle's centre, or to a strip's segment, against its `r`. `hideAt` picks a point inside a patch.
   - `GRASS_RADIUS` becomes the default and the largest `r`.
   - The chance per second (`GRASS_CHANCE` 0.22) and the rest after a battle (`GRASS_REST_SECONDS` 8) are unchanged.
   - Must-cross fields mean more seconds in grass per trip, so more wild battles and more coins. Re-run the economy simulation and check the daily falloff still caps it before shipping.
   - This touches wild encounters, which lead to captures, so it is proposed, not just built.
5. **Tamer sight (optional, phase 5).**
   - A pure `Sight.sees(place, facing, range, width, player)` in `src/shared`.
   - The server's tick checks unbeaten tamers against the server's own reading of the player's position, and starts the same engagement the prompt starts, through `BattleFlow`'s existing checks.
   - The device sends nothing new. It is rate-limited by the existing engage limiter.
   - The prompt stays as a fallback.
6. **Walkable space as a cheap guard (optional).** `WorldService` can refuse a rustle, bait, engage or grass check from a position that `Walk` says is not walkable, such as inside a wall or across water. This is a cheap answer to no-clip clients.
7. **The battle scene** skips anything tagged `WorldGround` (section 4c), so levels and walls never vanish mid-battle.
8. **Finds in dead ends (proposal only).**
   - One-time pickups at dead ends would be a new grant: a small material or a tonic, never coins, granted once per player per find and saved in their profile.
   - That touches saving and the economy, so it needs its own plan and Ayrton's approval.
   - Until then, dead ends hold rustle spots, views, benches, notes and shut places.

## 8. Tests (`tests/layout.test.luau`, plus new `tests/ground.test.luau` and `tests/walk.test.luau`)

**Kept, with changes:**
- "Every route place, grass edge included, is inside its corridor" becomes "inside walkable space" (corridor, room or town).
- "Each grass patch lies inside its own stretch" checks each patch's along-distance, for every patch.
- Prompt spacing (32), patch-to-prompt (26), tamer within 12 of its route and 40 of its `at`, story stands within slack, and building footprints are all unchanged.

**New:**
- **Ground:**
  - `heightAt` is right inside tiers, at their overlaps, and halfway up stairs and ramps.
  - Every link joins two different heights, and its ends lie on them.
  - Every ledge drops exactly one tier (10).
- **One level per check:**
  - Every place, prompt and story stand is at least 6 from a tier edge.
  - Every grass shape, sampled at 24 points round its edge plus its centre, sits on one height and at least 8 from a tier edge (stairs and ramps included).
  - Every tamer is at least 16 from a tier edge.
- **Reach** (`Walk`, 4-stud grid):
  - From the spawn, every place in Chapter 1 and every place of each biome is reachable: doors, tamers, grass, rustle spots, the stall, the lair, the gate and the sealed road.
  - From every reachable cell, the hub can be reached, so no ledge traps a player.
- **Ledges pay:** for each route, the hub can be reached from the route's end without touching any grass shape.
- **Must cross:** for each route in `mustCross`, you cannot reach the route's end from its entry without touching that area's grass, once the ledges are taken out (ledges only go home).
- **Narrow:**
  - Every route's half-width is 20 or less except in rooms.
  - At least two pinch points of 16 or less per route.
  - At least two branches per route: rooms or dead ends joined by one opening.
- **Gates:** the Greenwood gate is within 0.5 of (684.4, -80), and Dust Canyon's gate does not move.
- **Windows:** for each "Sight" beat, a straight line from the place, 20 up, to the landmark's top clears every wall and tier face on the way, using the heights in data.
- **Water:** no walkable cell is on water unless it is on a bridge or in a `wade` area.
- **Builders' budgets** (data-level counts): pieces of fill per biome, tuft clumps per biome, and parts of tiers and links (section 9).

## 9. Phone performance

| Item | Now (Greenwood) | After |
| --- | --- | --- |
| Trees outside edges | about 300 single trees | 0 |
| Wall meshes | Hedges of small bushes | `ForestWall`: about 110 (about 4,400 studs of boundary ÷ 40) |
| Fill meshes | | `ForestBlock`: at most 250, each a single mesh |
| Grass pieces | about 670 tufts | about 400 clumps (13 patches × about 30) |
| Tier slabs, faces and links | | about 120 parts |

- Every repeated piece is one MeshPart asset reused, so the engine can draw them together.
- Wall cores are single invisible parts.
- Canopies, tufts and lips cannot be collided with or queried, and cast no shadow. Canopies cast shadow only if the frame rate allows.
- Set `Workspace.StreamingEnabled` on, check it in Studio, and keep the target radius about 300. With the closer camera, nothing past about 150 studs needs detail.
- Measure on a phone-sized view in Studio, at the busiest spots (the meadow, the old wood and the town), before and after.

## 10. Build order

Each step passes `lune run check`, is played in Studio on a phone-sized view, and is checked by screenshot against the clay-toy look.

1. **Quick wins, no model change (one commit each).**
   - `CameraConfig` and the zoom limits.
   - Hedge and boulder cores raised to 10.
   - Water barriers.
   - `Fill.luau` with `ForestWall` and `ForestBlock` (plain stand-ins until the models exist), replacing the edge trees.
   - Field ground turned dark.

   This alone ends the "baseplate": the open plain disappears and you can no longer see a whole route. Play it and send screenshots before going on.
2. **Shared model.** `WorldTypes` additions, `Ground.luau`, `Walk.luau`, `Layout` copying the grass lists, and the tests in section 8 (those that need tiers pass trivially with none). No server behaviour changes yet.
3. **Builders.** `Tiers.luau`, `Links.luau`, heights for every placed thing, waterfalls, `BattleStage` skipping `WorldGround`, and strip grass with `GrassClump`.
4. **Greenwood data.** The new sheet values from section 5, Thistledown's rise and necks, and the dressing updated for heights.
   - Studio checks:
     - The ledges cannot be climbed.
     - The stairs and ramps walk smoothly on a phone.
     - Battles in grass and with each tamer stage on one level.
     - Every prompt shows alone.
     - The spawn view and each window show the ancient tree.
   - Screenshots: spawn, neck, meadow, terrace, ledge drop, ridge, old wood, steps and gate.
5. **Approvals, then encounters.** Multi-patch grass in `Encounters`, after Ayrton's OK and an economy simulation run. Optional tamer sight. A walkable-space guard in `WorldService`.
6. **Dust Canyon, then Tide Flats,** as in section 6, each with its own sheet changes and the same tests.
7. **Docs.**
   - `docs/DECISIONS.md`: the [Default]s changed (corridor widths, camera zoom, wall heights, tiers, grass shapes, must-cross fields).
   - `docs/PROGRESS.md`: what to playtest.
   - `docs/ASSETS.md`: the new models.

### New painted models to generate (clay-toy style, flat warm colours, front faces -z)

1. **ForestWall.** A 40-stud run of round, chunky tree crowns in three greens, fused shoulder to shoulder over short brown trunks, 30 tall and 14 deep. A seamless edge of woodland, with no gaps to see through.
2. **ForestBlock.** A 40 × 40 mass of tree crowns seen from above and the side, domed and lumpy, 24 to 32 tall, for filling behind the wall.
3. **GrassBank.** A 40-long, 10-tall earthen bank face with roots, a few stones, and a thick grass lip rolling over the top.
4. **LedgeLip.** A 20-long low rounded grass rim with a short trodden-earth notch: the classic hop-down edge.
5. **StoneStairs.** A 12-wide flight of chunky pale stone steps rising 10, with mossy cheeks on both sides.
6. **TimberSteps.** The same flight in logs and earth.
7. **MesaBlock.** A banded red-and-cream rock mass with a flat top, for Dust Canyon fill.
8. **GrassClump.** Six or seven long-grass tufts in one clump, about 5 across and knee high.
9. **PlankBridge.** A 40-long flat plank bridge on posts, with rope rails, for rivers.

## 11. For Ayrton (in one batch)

1. **Camera.** Is a 40-stud zoom limit OK? It is what stops you seeing over the walls. A fixed, classic high-angle camera is possible later, as a separate idea.
2. **Grass you must cross.** One field per route going out, skipped by a ledge coming home. OK?
3. **More grass means more wild battles and coins per walk.** Multi-patch grass needs your OK and a re-run of the economy simulation.
4. **Tamers who spot you and walk up.** Build it (phase 5)?
5. **Finds in dead ends.** These need a plan of their own (saving and economy). Want one?
6. **Route lengths.** These are kept (400 and 600 in Greenwood). The routes now feel longer because they fold. Longer routes would mean moving the `from`, `to` and `at` data.

## Sources

- pret/pokered map sizes: https://raw.githubusercontent.com/pret/pokered/master/constants/map_constants.asm
- pret/pokered trainer sight on Route 3: https://raw.githubusercontent.com/pret/pokered/master/scripts/Route3.asm
- pret/pokered Route 1 objects: https://raw.githubusercontent.com/pret/pokered/master/data/maps/objects/Route1.asm
- Blocks of 2 by 2 cells: https://github.com/pret/pokered/wiki/Adding-a-new-Tileset and https://blog.vjeux.com/2023/project/pokemon-red-blue-map.html
- Town measurements (screen, corridor widths, exits, doors): https://blakecrosley.com/blog/pixel-art-towns-on-iphone
- Ledges and Route 1 (search snippets; the pages refused fetching): https://m.bulbapedia.bulbagarden.net/wiki/Ledge , https://bulbapedia.bulbagarden.net/wiki/Kanto_Route_1 , https://bulbapedia.bulbagarden.net/wiki/Route
- Route design commentary:
  - Early routes: https://fantendo.fandom.com/wiki/User_blog:Shadow_Inferno/A_short_analysis_of_the_first_Routes_in_Pokemon_Games_(Gen_I-IV)
  - Johto maps: https://daily.pokecommunity.com/2020/05/30/a-tale-of-three-johtos-the-evolution-of-the-gen-ii-maps
  - Unova: https://daily.pokecommunity.com/2024/03/06/part-i-the-components-of-unova/3
  - Grass as a choice: https://geektogeekmedia.com/geekery/pokemons-grassy-route-to-success
  - Older games in small spaces: https://buttondown.com/melodicambient/archive/why-were-older-pokemon-games-more/
  - Hoenn dead ends that become shortcuts: https://publish.obsidian.md/myaiba/Z0+Zettels/The+Hoenn+Pokemon+games+give+you+reasons+to+explore+routes+that+lead+to+temporary+dead+ends%2C+to+show+you+that+these+routes+will+eventually+connect+to+later+parts+in+the+game
- Project Pokemon: https://roblox.fandom.com/wiki/Community:Wish_z/Project_Pok%C3%A9mon , https://project-pokemon.fandom.com/wiki/Player's_Guide , https://www.sportskeeda.com/roblox-news/5-roblox-games-removed-platform
- Brick Bronze and Loomian Legacy routes (search snippets): https://brickbronze.fandom.com/wiki/Route_2 , https://brickbronze.fandom.com/wiki/Route_3 , https://loomian-legacy.fandom.com/wiki/Route_1 , https://loomian-legacy.fandom.com/wiki/Route_5
- Streaming for large Roblox maps: https://devforum.roblox.com/t/chunk-loading-system/3256694
