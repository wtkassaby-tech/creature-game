# 03 Map and world style

Date: 16 November 2026
Status: research, nothing decided

## Summary

- Every Roblox creature RPG checked (Loomian Legacy, Doodle World, Tales of Tanorio, and the removed Pokémon Brick Bronze) uses the same chain: numbered routes between named towns, a badge battle in the town, then the next route. Wild creatures come from tall-grass random encounters; none of them shows ordinary wild creatures walking about. Visible roaming creatures are a clear way to look different, and they suit a lasso.
- Roblox's own guidance favours one place with instance streaming for most games. Splitting into several places adds a loading screen at every teleport. For three launch biomes, one streamed place is the right start.
- The only official budget figure is an example: under 1,000 draw calls and 1,000,000 triangles on a baseline device you choose. Shadows switch off below quality level 4, so the art must look right with no shadows. Out-of-memory is the main crash cause on low-end phones.
- Recommended streaming start: StreamingEnabled on, minimum radius 64, target radius 768 (test against the 1,024 default), Opportunistic stream-out, Atomic models, and SLIM level of detail on static scenery.
- Wild battles should happen where the player stands, with a camera cut and a client-only staging, not a teleport. The giant's lair is its own arena. No source gave a measured "best on mobile" answer; this is reasoning.
- Proposed launch world: about 3,600 by 1,400 studs in one place, three biomes in a row, each a hub plus two routes and a lair spur, with later biomes teased by distant landmarks, sealed gates and travellers.
- **Limit on this research:** this session could not open create.roblox.com, devforum.roblox.com or any Fandom wiki (blocked by the session's network settings). Almost every claim below is therefore "snippet" (search result text only). Nothing here is "sourced" today except where it reuses the owner's earlier research, which opened the pages at the time. Before building, re-check the streaming and performance pages in a session where create.roblox.com is allowed.

Confidence labels: **sourced** = page opened; **snippet** = search result only; **inference** = my reasoning; **earlier research** = taken from `docs/research/` in this repo, where the page was opened at the time.

---

## 1. How Roblox creature RPGs lay out their worlds

| Game | Layout | Encounters | Social spaces | Source and confidence |
| --- | --- | --- | --- | --- |
| Loomian Legacy | Numbered routes join towns and cities (Route 1 is "relatively short", joining Mitis Town to Cheshma Town; Route 5 is built around a staircase up to Heiwa Village). A badge-style "Battle Theatre" gates story progress. | Tall-grass patches with a table per area. "Roaming" Loomians are a rare roll (about 1 in 1,000 to 1 in 1,024) inside grass, not creatures you can see. | Two hubs outside the story world: Battle Colosseum (PvP, added v0.1.3) and Trade Resort (added v0.1.1). Fast travel ("Geo Hop") lists towns but not routes, and does not work indoors. | https://loomian-legacy.fandom.com/wiki/Route_1 , https://loomian-legacy.fandom.com/wiki/Route_5 , https://loomian-legacy.fandom.com/wiki/LoomiWatch , https://loomian-legacy.fandom.com/wiki/Battle_Colosseum , https://poneom.fandom.com/wiki/Roaming_Loomian (all snippet) |
| Doodle World | Route 1, then Route 2 to the north, then Lakewood Town to the north-east; an NPC gives a town tour on first arrival. A maze gates one later area. | Random encounters in grass, with a table per area. Legendaries appear once as a "set encounter", then roam at 1 in 1,200 base odds. Event grass patches were added for Halloween 2025. | Not found. | https://doodle-world.fandom.com/wiki/Route_2 , https://doodle-world.fandom.com/wiki/Legendary_Doodles , https://doodle-world.fandom.com/wiki/Events (snippet) |
| Tales of Tanorio | Numbered routes with place names (Beginner's Range - Route 1, Prelude Plains - Route 2, Fable Falls - Route 5, Mystical Meadows - Route 9, Makoto Breeze Bay - Route 12). Towns hold a stadium; winning its medal opens the next area (Everlush Town's Sprout Medal opens Kaigan Cliffs). 15 locations at public release in March 2024. | Wild Tanorians and "roaming trainers" on routes; Route 1 holds three species at levels 2 to 5. Whether the wild ones are visible was not confirmed. | Not found. | https://talesoftanorio.fandom.com/wiki/Category:Routes , https://talesoftanorio.fandom.com/wiki/Everlush_Town , https://talesoftanorio.fandom.com/wiki/Update_Log , https://www.droidgamers.com/guides/tales-of-tanorio-route-1/ (snippet) |
| Pokémon Brick Bronze (removed April 2018) | Region of two islands; a fan wiki counts 18 routes, 5 towns and 7 cities. Loomian Legacy's Route 1 is "mostly the same" as Brick Bronze's. | Grass random encounters. | Not found. | https://brickbronze.fandom.com/wiki/File:Frigidia_Island.png , https://loomian-legacy.fandom.com/wiki/Route_1 (snippet) |

What this tells us:

- **The pattern is proven and short-legged.** First routes are short and hold only two or three species. A town always gives a tour, a heal and a gate battle. (snippet, sources above)
- **Route names carry character.** Tales of Tanorio pairs a number with a place name ("Fable Falls - Route 5"). This fits the brief's "the path changes character with each biome". (snippet; inference for the fit)
- **Social play sits in dedicated hubs**, not on routes: Loomian Legacy keeps trading and PvP in two purpose-built hubs. (snippet)
- **One place or several:** players report getting stuck on a loading screen when they "join or move to a new hub" in Loomian Legacy, and its developer posted about black-screen bugs "when loading into certain maps" (2021). That points to several places or loaded map chunks, with a real cost at each load. (snippet: https://loomian-legacy.fandom.com/f/p/4400000000000352602 , https://x.com/t_brad_m/status/1384318039517245443 ; the conclusion is inference)

**Could not verify:** any size in studs for any of these games; whether each game is one place or several; how Brick Bronze loaded its chunks; what the battle scene looks like in each. No written source found gave these. They need ten minutes of play in each game with the F9 console open, which a research session cannot do.

### One place or several places

| Option | For | Against | Source |
| --- | --- | --- | --- |
| One place with instance streaming | Roblox calls streaming "a great option for most places, especially larger ones"; it improves join time, memory and frame rate. Friends stay in the same server. Travel is instant. | The whole world shares one memory and instance budget. | https://create.roblox.com/docs/performance-optimization/design (snippet) |
| Several places joined by TeleportService | Smaller places; simpler to add content or work in a team. | "Adds join time each time players teleport between places." Community posts name player loss at teleports as the main worry, and report groups being split across servers. | Same page; https://devforum.roblox.com/t/using-multiple-places-or-keeping-everything-in-1-place/579668 (snippet, anecdotal) |

No one has published drop-off numbers for teleports. (could not verify)

---

## 2. What a good low-poly, chunky Roblox world looks like

Evidence here is thin. Searches returned beginner forum threads and Roblox's environment-art course, not teardowns of named games. I could not confirm reference games and their techniques from written sources; choosing references needs screenshots taken in Studio or in the games.

| Technique | Detail | Source and confidence |
| --- | --- | --- |
| Flat colour, simple material | Forum advice reduces the style to three things: SmoothPlastic, bright colours, fewer parts. Most builders model in Blender and import meshes, because part-built low-poly is hard to get right. | https://devforum.roblox.com/t/how-do-i-make-low-poly-style-builds-in-roblox-studio/256376 (snippet) |
| Part colours matter as much as lighting | Pastel or saturated part colours do most of the work; lighting only supports them. | `docs/research/LIGHTING_AND_VFX.md` (earlier research) |
| Reuse, don't duplicate | Parts that share a mesh id, material and texture id batch into one draw. Re-importing the same mesh creates a new asset id and loses that. Build variety by scaling, rotating and overlapping a small kit. | https://create.roblox.com/docs/performance-optimization/design , https://create.roblox.com/docs/tutorials/curriculums/environmental-art/optimize-your-experience (snippet) |
| Modular kits | Roblox's course builds worlds from a snapped modular kit, tileable textures for ground, and trim sheets for props. | https://create.roblox.com/docs/tutorials/curriculums/environmental-art/assemble-an-asset-library , .../develop-polished-assets (snippet) |
| Avoid layered transparency | Stacked see-through meshes (leaves, glass, water) cause "high transparency overdraw" with a significant cost. Use transparency 0 or 1 where possible. | https://create.roblox.com/docs/tutorials/curriculums/environmental-art/optimize-your-experience (snippet) |
| Shadows off for edge foliage | The course turns CastShadow off for foliage at the edge of the play area. | Same page (snippet) |
| Lighting | Since 23 July 2025 `Technology` is replaced by `LightingStyle` (Realistic or Soft) plus `PrioritizeLightingQuality`. Old "Future" maps to Realistic with prioritise on; "ShadowMap" to Soft with prioritise on. Soft gives the flatter look. | https://devforum.roblox.com/t/let-there-be-unified-light-unified-lighting-is-fully-live/3401512 (snippet); `LIGHTING_AND_VFX.md` (earlier research) |
| Shadows vanish on weak phones | Shadows are disabled at quality levels below 4. | `LIGHTING_AND_VFX.md`, from https://create.roblox.com/docs/performance-optimization/improve.md (earlier research) |

**Terrain or mesh ground?** No source settled this. (could not verify) Reasoning: Roblox Terrain is quick to generate from code and handles its own detail levels, but it is smooth and rounded, which fights a faceted look. Mesh ground tiles give the chunky look and batch well if a small set is reused, but cost more building time. This needs a side-by-side screenshot test in the Greenwood greybox (see recommendation 6). (inference)

**Lighting choice.** For flat-colour chunky art, Soft is the safer default: it looks nearly the same on a phone with shadows off as on a PC. Realistic adds accurate local light and shadow that low-end phones will not show, so the game would look different per device. (inference from the two rows above)

---

## 3. Mobile performance rules

Third-party trackers put mobile at roughly 70 to 80 per cent of Roblox sessions (figures vary by tracker and none is official). (snippet: https://rolearn.dev/trend-reports/roblox-mobile-gaming-trends-2026 , https://rowatcher.com/news/mobile-vs-desktop-on-roblox-who-s-playing-what-in-2026 ) The brief already sets mobile-first (section 2).

### Instance streaming

| Property | What it does | Default or advice | Source and confidence |
| --- | --- | --- | --- |
| `Workspace.StreamingEnabled` | Loads and unloads 3D content around each player. | Recommended for most places. | https://create.roblox.com/docs/workspace/streaming (snippet) |
| `StreamingMinRadius` | Content inside this radius loads first and never streams out. | Default 64; Roblox advises keeping it low so the engine can scale down on weak devices. | Same page (snippet for the meaning; the default of 64 comes from the search summary and third-party guides, not seen on the page) |
| `StreamingTargetRadius` | Furthest distance content streams in. Smaller values cut server work. | Default 1,024. | Same (snippet; default from third-party guides: https://gamertagmythras.com/blog/roblox/roblox-instance-streaming-guide ) |
| `StreamOutBehavior` | `Opportunistic` lets the client drop regions beyond the target radius even with no memory pressure. | A third-party guide says Roblox recommends Opportunistic against out-of-memory crashes. | https://gamertagmythras.com/blog/roblox/roblox-instance-streaming-guide (snippet, not confirmed on the official page) |
| `StreamingIntegrityMode` | Pauses the player when they outrun loading. | `PauseOutsideLoadedArea` listed by one third-party guide. | Same guide (snippet, unconfirmed) |
| `Model.ModelStreamingMode` | `Atomic`: the model arrives and leaves whole. `Persistent`: sent soon after join and never streamed out, so it costs memory for good. `PersistentPerPlayer`: persistent only for chosen players. `Default` currently equals `Nonatomic`. | Use Persistent only when scripts must always reach the model. | https://create.roblox.com/docs/reference/engine/enums/ModelStreamingMode (snippet) |
| `Model.LevelOfDetail` | `StreamingMesh`: a coarse, untextured coloured stand-in shown beyond the streaming radius. `SLIM`: a cloud-built composite at falling resolutions; needs streaming; no physics, collision or raycast on the composite; not for animated, runtime-changed or Humanoid models. | Set SLIM on static scenery; split very large models. One developer reports each SLIM level counts as a draw call. | https://create.roblox.com/docs/workspace/streaming/slim , https://create.roblox.com/docs/workspace/streaming/techniques , https://devforum.roblox.com/t/client-beta-introducing-scalable-lightweight-interactive-models-slim/4034709?page=8 (snippet) |

Flat-colour art suits these stand-ins well: an untextured coloured imposter of a flat-coloured mesa looks almost the same as the real thing. (inference)

### Budgets

| Item | Rule | Source and confidence |
| --- | --- | --- |
| Draw calls and triangles | Only official figure: an example target of under 1,000 draw calls and 1,000,000 triangles on a baseline device you pick. Not a mandated limit. A community tutorial suggests keeping scene draw count under about 500. | https://create.roblox.com/docs/performance-optimization/design (snippet and earlier research); https://devforum.roblox.com/t/tutorial-roblox-optimization-guide-memory-draw-calls-and-network-tips/3881861 (snippet) |
| Texture memory | Graphics memory follows pixel count: 1024x1024 costs four times 512x512. Images rarely need more than 512x512; minor ones under 256x256. | https://create.roblox.com/docs/performance-optimization/improve.md (earlier research) |
| Particles | Each particle emitter is its own draw call. | Community tutorial above (snippet) |
| Collision | `CollisionFidelity` Box has the lowest memory cost; turn collision off where it is not needed. | https://create.roblox.com/docs/performance-optimization/improve (snippet) |
| Mesh detail | `RenderFidelity` defaults to Automatic (detail falls with distance). | https://create.roblox.com/docs/reference/engine/enums/RenderFidelity (snippet) |
| Memory on low-end phones | Out-of-memory is "one of the most common reasons for crashes on low end devices". Roblox's analytics page shows crash rate and memory for devices under 2 GB. One user reports about 800 MB usable on a 2 GB phone. No official per-device cap found. | https://devforum.roblox.com/t/analytics-optimize-low-end-android-crash-rates-server-memory-and-cpu-performance/3145364 (snippet); the 800 MB figure is one forum anecdote |
| Occlusion culling | Live on Windows since January 2025; staff said mobile would follow once stable. Current mobile status not confirmed. | https://devforum.roblox.com/t/occlusion-culling-now-live-in-roblox-client/3300953 (snippet) |

**Could not verify:** an official part-count budget, official triangle limits per phone class, and whether occlusion culling is on for phones today. Roblox publishes no "low-end phone" numbers; its advice is to pick a baseline device and measure.

---

## 4. Guiding players along a path without invisible walls

General level-design practice (not Roblox-specific; sources are practitioner articles, so treat as craft advice):

| Tool | How it works | Source |
| --- | --- | --- |
| Landmark ("weenie") | One tall, unique shape visible from far away pulls players toward it and tells them where they are. It should have a purpose when reached. | https://www.gameanalytics.com/blog/five-simple-ways-use-level-design-improve-player-experience (snippet) |
| Show, hide, show again | Show the goal, send the player on a route where it drops out of sight, then reveal it closer. | https://unity.com/blog/level-design-basics (snippet) |
| Leading lines | Fences, hedges, rivers, path colour and lamp rows point the way. At a fork, the intended route is wider and brighter. | Same Unity page (snippet) |
| Natural barriers | Cliffs, thickets, ravines and water replace invisible walls, which "make the player feel like the game is fighting against them". | https://www.wayline.io/blog/tutorials-onboarding-level-design-player-guidance (snippet) |
| Test in blockout | Add signposting late; adding it early hides layout faults in playtests. (David Shaver, "Invisible Intuition", GDC 2018) | https://80.lv/articles/blockmesh-tips-from-david-shaver/ (snippet) |

### Visible creatures or tall grass?

- All four Roblox creature RPGs above use tall-grass random encounters. (snippet, section 1)
- Player opinion on the wider genre is split but leans toward visible creatures: they let players choose fights, make the world feel alive and make rare colours a thrill to spot. Those who prefer random encounters like the surprise, and dislike creatures that chase them. Sword and Shield mixed both. These are forum opinions, not survey data. (snippet: https://www.pokecommunity.com/threads/do-you-miss-the-random-grass-wild-encounters-of-the-1st-7-gens-or-not.533313 , https://www.imore.com/will-pokemon-sword-and-shield-have-random-encounters )
- For this game the case for visible creatures is stronger than usual (inference):
  - The lasso is a physical act; walking up to a creature you can see suits it better than a menu popping up.
  - Rare colour variations (brief section 4) become something players spot and shout about, which is social and good for video.
  - It separates the game from four near-identical rivals, which helps the "every creature is original" guardrail feel true in play.
  - Cost: each visible creature is an animated model. Keep them client-spawned from server-approved spawn data, capped per player (for example 8 to 12 near the player), with the server deciding what each one actually is when the player engages. (inference; cap to be measured)
- Keep a small dose of surprise: rustling grass or a shaking bush that hides an unknown creature, and bait spots in Tide Flats. (inference)

### Where things go

| Thing | Placement | Why |
| --- | --- | --- |
| Healer | First building seen on entering the hub from the route, on the main line through town. | Players arrive hurt; brief says the healer is free so nobody is stuck. |
| Shop | Next to the healer, on the main line. | DECISIONS.md: consumables pace giant fights, so stocking up must be effortless. |
| Breeder | One step off the main line, with its own yard where eggs or young creatures are visible. | A destination players choose, and a place to show off. |
| Teleport building | On the town square, tallest roof in town. | It is the hub's landmark and the [Locked] "teleports between certain buildings". |
| Quest-givers | Around the square, each facing the direction of their quest. | Leading lines. |
| Gate battle | At the far exit of the second route, at a physical gate (bridge, canyon door, sea wall). | The gate is a real barrier, not an invisible wall. |
| Giant's lair | A spur off the second route, visible early from the hub (smoke, a huge tree, a rock arch), lost from sight on the route, revealed again at the spur. A small supply stall and a rest spot sit at the spur mouth. | Show, hide, show again. The stall supports "prepare before a giant". |
| Local tamers | Stand in plain view on routes, mostly avoidable, with one or two at pinch points. | Matches genre practice. |

All placement rows are inference built on the sources above and brief sections 3, 5 and 8.

---

## 5. The battle scene

What is known: Loomian Legacy gives out "battle backgrounds" as ranked rewards, so its battles are shown against a chosen backdrop, not the open world. (snippet: https://loomian-legacy.fandom.com/wiki/Battle_Colosseum ) Forum advice for turn-based systems is a fixed camera position set when the fight starts, and not zoomed in too tight. (snippet: https://devforum.roblox.com/t/turn-based-combat-system/1029990 ) I found nothing that measured which approach feels best on mobile. (could not verify)

| Option | For | Against |
| --- | --- | --- |
| Fight in place, shared world | Others can watch. | Other players and creatures walk through the scene; streaming and camera clutter; exploitable positions. |
| Teleport to a separate arena (same place) | Clean framing. | The arena must be streamed in each time, which means a pause; loses the sense of place. |
| **Camera cut with client-only staging at the spot** | No loading; biome stays visible behind the fight; nothing replicated, so no cost to other players; the server still decides every result. | Needs a flat "battle pocket" every few studs along routes, or a small ground disc that appears under the fight. |

Reasoning for the third option on mobile: there is no stick movement during battle, the camera is fixed so thumbs only press buttons, and a cut takes under a second where a streamed arena may take several on a weak phone. The player's avatar is marked "in battle" to others and made safe from interaction. Giants fight in their lair, which is built as an arena. PvP uses the Circuit arena with spectators. (inference)

---

## 6. Tools for building the map quickly

| Tool | Use | Status and limits | Source and confidence |
| --- | --- | --- | --- |
| Roblox Studio MCP server | Claude Code builds, views and tests in Studio. | At RDC (10 to 12 September 2026) Roblox said it is opening MCP access to "every major API" in Studio. In this cloud session the Studio MCP failed to connect (it needs the owner's Windows machine), so nothing here was tried in Studio. | https://about.roblox.com/newsroom/2026/09/rdc-2026-the-world-needs-more-play (snippet) |
| Terrain from code | `Terrain:FillBlock`, `FillBall`, `FillCylinder`, `FillWedge`, `FillRegion`; `WriteVoxels` for bulk generation; `math.noise` for hills. | `WriteVoxels` can cause frame spikes at runtime, so generate in edit mode, not in live play. | https://create.roblox.com/docs/parts/terrain , https://create.roblox.com/docs/reference/engine/classes/Terrain (snippet) |
| Procedural placement | A Luau script run in edit mode scatters a small kit (trees, rocks, grass tufts) along a path spline with seeded randomness and rules (no props on the path, denser at edges). | Our own code; no outside dependency. | inference |
| `generate_mesh` (Studio AI) | Text to textured mesh; triangle cap optional, default 10,000; about 100 to 1,000 suits low-poly props. | Quotas and licence terms for output not confirmed. | `docs/research/ART_TOOLS_2.md`, `ART_PIPELINE.md` (earlier research) |
| Texture Generator | Fast mode 1K diffuse; quality mode 4K PBR. Barely needed for flat-colour art. | Beta status and terms not stated. | `ART_PIPELINE.md` (earlier research) |
| Scene Generator | Prompt plus reference image to a working layout, "later this year" in Build and Studio. | Announced September 2026; not confirmed as released. Could be useful for greyboxes; do not plan around it. | https://about.roblox.com/newsroom/2026/09/rdc-2026-the-world-needs-more-play , https://allthings.how/roblox-rdc-every-major-announcement-for-players-and-creators/ (snippet) |
| Creator Store packs | Free or paid models (models priced $2.99 to $49.99). Sellers warrant they hold the rights. | Use is governed by separate "Creator Store Terms", which I could not open. The Terms of Use page shows an effective date of 1 November 2026. The earlier research also failed to read the licence wording. **Licence for use in a monetised game: could not verify.** | https://create.roblox.com/docs/production/creator-store , https://en.help.roblox.com/hc/en-us/articles/115004647846-Roblox-Terms-of-Use (snippet); `docs/research/CREATOR_STORE_OPTION.md` (earlier research) |

Whether every asset must be AI-generated is [Open] in brief section 12. A chunky flat-colour world is the style where a small home-made kit goes furthest, and it avoids the unread licence. (inference)

---

## 7. Map plan for the three launch biomes

All numbers are starting points to test, not findings. Walking speed assumed at Roblox's default of 16 studs per second (inference from general knowledge; not re-checked today).

### Layout pattern

One place. The three biomes sit in a row, west to east, joined end to end. Each biome is a loop-and-spur:

```
[gate in] -> Route A -> HUB TOWN -> Route B -> [gate battle] -> next biome
                                       \
                                        spur -> supply stall -> GIANT'S LAIR
```

- Route A is short and gentle (teaching). Route B is longer, with a side pocket for materials and the lair spur.
- A shortcut opens from the lair back to the hub once the giant is beaten, so return trips are quick.
- Each hub's teleport building links to every hub the player has reached (the [Locked] building teleports). The server moves the player and asks for the area to stream in first.
- Greenwood's hub is the main social town at launch: largest square, trade spot and the one Circuit arena.

### Sizes

| Area | Greenwood | Dust Canyon | Tide Flats |
| --- | --- | --- | --- |
| Hub town | 300 x 300 | 260 x 260 | 280 x 280 |
| Route A (path length) | 400 | 550 | 600 |
| Route B (path length) | 600 | 750 | 850 |
| Lair spur and lair | 250 + 150 arena | 300 + 180 | 300 + 200 |
| Biome footprint | 1,000 x 1,000 | 1,200 x 1,200 | 1,400 x 1,400 |
| Straight walk, entry to exit | about 1.5 min | about 2 min | about 2.25 min |
| Route width | 40 to 60, opening to 120 at creature meadows | 30 to 50 in slot canyons, 150 on mesa tops | 60 to 100 on sand, narrow causeways between pools |

Whole launch world: about 3,600 x 1,400 studs. Play time per biome grows through content (more creatures, tamers, quests), not through walking distance; routes grow only about 1.2 to 1.3 times. (inference; brief section 3 sets the 1.3 times pace)

### Streaming and performance settings (start values)

| Setting | Value | Note |
| --- | --- | --- |
| `StreamingEnabled` | true | |
| `StreamingMinRadius` | 64 | Default. |
| `StreamingTargetRadius` | 768 | Test against 1,024 on the baseline phone; pick the lower one that shows no pop-in at walking speed. |
| `StreamOutBehavior` | Opportunistic | Confirm on the docs page first. |
| `StreamingIntegrityMode` | PauseOutsideLoadedArea | Confirm on the docs page first. |
| Buildings, NPCs, props | `ModelStreamingMode` Atomic | Scripts never see half a model. |
| Static scenery groups | `LevelOfDetail` SLIM (or StreamingMesh if SLIM raises draw calls) | Measure both. |
| Teaser landmarks, teleport building roofs | Persistent, each under about 20 parts | The only persistent models. |
| Wild creatures | Client-spawned, 8 to 12 near the player | Server owns what they are. |
| Lighting | `LightingStyle` Soft; per-biome Atmosphere and colour correction blended on the client at biome borders | Must look right with shadows off. |
| Budget on the baseline phone | Under 500 draw calls and 300,000 triangles in view; 30 frames per second; no texture over 512 x 512 | Stricter than Roblox's example of 1,000 and 1,000,000, to leave room for battle effects and other players. |
| Baseline device | A phone with 3 GB of memory, tested at graphics quality 3 | To be chosen with Ayrton; a fellow student's older phone in Vietnam would do. |

### Art rules

1. Flat colours only on world art; no photo textures. One material (SmoothPlastic) plus colour.
2. A kit of at most 40 world meshes per biome, each 50 to 600 triangles; hero landmarks up to 3,000. Variety comes from scale, rotation and colour.
3. Each biome has a five-colour script: ground, foliage or rock, accent, sky and haze, and one "pop" colour kept for things the player should walk toward (path edges, doors, the lair).
4. Big shapes first: every screen should read as three or four large masses on a phone.
5. No layered transparency. Water is one flat-colour surface; leaves are solid clumps.
6. The path is always the lightest ground colour in view.
7. Collision is boxes or off on scenery; shadows off on small props.

| Biome | Ground | Mass | Accent | Sky and haze | Path character | Landmark |
| --- | --- | --- | --- | --- | --- | --- |
| Greenwood | Fresh green | Deep green round trees, warm brown trunks | Yellow and white flowers | Soft blue, pale warm haze | A wide dirt lane curving through meadow, then under trees | A giant old tree over the lair, seen from the square |
| Dust Canyon | Ochre and terracotta | Banded red mesas | Turquoise (pots, doors, cactus flowers) | Hot pale yellow, dusty haze | Slot canyons that open on to mesa-top views; rope bridges | A rock arch with the lair behind it |
| Tide Flats | Pale sand, wet dark sand | Grey-blue rock stacks | Coral pink and orange | Clear aqua, sea mist | Causeways between rock pools; some pools drain to open side paths | A wrecked ship's ribs on the reef |

### Teasing later biomes

- **Skyline.** From Greenwood's high points, small persistent silhouettes: Frostline's white peaks to the north, Emberfall's smoke plume beyond the canyon, a faint glow where the tear will be seen in Stormreach. Low part counts, flat colour.
- **Sealed gates.** Past the Tide Flats gate, a boardwalk runs into the Mire's mangroves and stops at a broken bridge, with green fog and strange calls beyond. A sign names what comes next without a date.
- **Travellers.** One NPC per hub from a later biome (a Frostline trader in furs, a Crystal Deep miner) with one short line and a creature the player cannot get yet.
- **The world map** in each teleport building shows all eleven biomes, with later ones drawn but clouded.
- **Gem-touched hints.** A single gemstone-tinted wild creature that flees before it can be lassoed, tying to the story in brief section 9.

---

## Recommendations for this game

Ranked. None changes a [Locked] item or a line in DECISIONS.md; two adjust [Default] items and are flagged.

1. **Build the launch world as one place with instance streaming** (brief sections 8, 12). Roblox's guidance and the loading complaints in Loomian Legacy both point this way. Keep biome data separate so biomes 4 onward can move to their own place later if memory demands it.
2. **Make wild creatures visible and roaming, with a few hidden "rustle" spots** (sections 6, 8). All four rivals use tall grass; visible creatures suit the lasso, show off colour variations and set the game apart. New detail under a [Default]; log it in DECISIONS.md. Needs a creature-count test on the baseline phone.
3. **Fight wild battles on the spot with a camera cut and client-only staging; giants in their lair arena; PvP in the Circuit arena** (section 5). No loading, and the biome stays on screen. Based on reasoning, so test it in the milestone 1 battle core on a phone.
4. **Choose a baseline phone now and adopt the stricter budget** (section 12): under 500 draw calls, 300,000 triangles, Soft lighting, art that reads with shadows off. Roblox gives only an example figure, so the game must set its own.
5. **Use the loop-and-spur layout and the sizes in section 7 for Greenwood, then tune** (sections 3, 8). Greybox it first and playtest before any art, as the GDC advice says.
6. **Run a one-day ground test in the Greenwood greybox: Roblox Terrain against mesh tiles** (section 12). Compare a phone screenshot and draw calls. Evidence could not settle this.
7. **One Circuit arena and one main social square at launch, in Greenwood's hub, not one per hub** (section 8). This changes a [Default] ("one hub town per biome holding the... Circuit arena"). With a small launch population, one gathering place feels busy; three feel empty. Other hubs keep shop, healer, breeder and teleport building.
8. **Place the healer and shop on the main line and a supply stall at the lair spur** (sections 5, 8; DECISIONS.md lines on consumables). This supports "prepare before a giant" without adding friction.
9. **Build the world kit in-house (code-built and Studio-generated meshes) until the Creator Store Terms have been read** (section 12, [Open] asset question). Two research passes have now failed to open the licence text.
10. **Tease later biomes with skyline silhouettes, a sealed Mire boardwalk, travellers and a clouded world map** (sections 8, 9; DECISIONS.md line on teasing). Cheap to build and already supported by the story.
11. **Re-check the streaming, SLIM and performance pages before the first build** in a session where create.roblox.com is allowed (section 12). The property names here are reliable; several default values and the two recommended enum settings rest on third-party guides.

## What could not be verified (collected)

- Sizes in studs, place structure and battle-scene design of Loomian Legacy, Doodle World, Tales of Tanorio and Brick Bronze.
- Named low-poly reference games and their exact techniques.
- Exact defaults and Roblox's own recommended values for `StreamOutBehavior` and `StreamingIntegrityMode`.
- Official phone memory limits, part budgets, and whether occlusion culling is live on mobile.
- Creator Store Terms wording on use in a monetised game.
- Whether Scene Generator has shipped in Studio, and its limits.
- Any measured comparison of battle-scene styles on mobile.
