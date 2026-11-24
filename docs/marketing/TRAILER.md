# ClayPals Launch Trailer (30s, plus 15s vertical cut)

Rules from research (Roblox creator docs, thumbnails and video previews): the video must be authentic in-game footage, no misleading edits, and music must come from the Roblox catalog (or be cleared for it). Lead with the strongest hook, keep captions readable with sound off. All shots are filmable in Studio from the current build (Run/Play, screen_capture / video_capture, a camera script for fly-throughs). Launch biomes shown: Greenwood, Dust Canyon, Tide Flats; later biomes shown only as the map teaser and must be real in-build content.

Comparable-store-page pattern (creature and pet games): hook within 2s, show the collect loop (catch, reveal), show a rarity or "wow" creature, end on a logo and a one-line promise. Verify against live pages before final cut; this research was limited to Roblox's official guidance.

Tagline: "Tame it. Breed it. Make it yours." Hook line: "Every creature is handmade."

## 30-second cut (16:9, 1920x1080)

| Time | Shot | What to film | On-screen text | Music / sound |
| --- | --- | --- | --- | --- |
| 0:00-0:03 | Clay hook | Macro camera over a clay creature wobbling awake on a Greenwood meadow, soft-focus depth | "Every creature is handmade." | Warm music box note, soft pad swell |
| 0:03-0:07 | Biome flythrough | Fast dolly across Greenwood, Dust Canyon mesas, Tide Flats rock pools (3 cuts, ~1.3s each) | "Explore biomes" | Tempo picks up, light percussion in |
| 0:07-0:12 | Lasso catch | Over-the-shoulder: creature spots player, lasso swings, timing ring tightens, perfect hit, catch sparkle, creature joins | "Tame them with your lasso" | Rising tick, then catch jingle on the hit |
| 0:12-0:17 | First battle | Turn-based battle view, player picks a move, type-advantage hit, damage number pops, enemy faints, level-up card | "Battle with your team" | Drums drive, hit stingers on impacts |
| 0:17-0:23 | Breeding | Two parents side by side, parts swap on screen (head from one, legs from the other), egg wobbles, hatch reveals a new mix | "Breed new generations. Part by part." | Music dips to a hush, hatch chime |
| 0:23-0:27 | Firstling reveal | Dark Hollow-style ruin, light beam, the Firstling rises, slow orbit camera, aura glow | "Find the Firstling." | Full swell, choir pad or big synth chord, drop to silence for 0.3s before reveal |
| 0:27-0:30 | Logo end card | Logo on clay texture, team of six creatures lined up | "ClayPals - Play free on Roblox" | Final chord and button, short tail |

Notes: keep text under 6 words per card, high contrast, bottom third safe area. Use the real HUD; do not fake UI. If the Firstling is spoiler-sensitive for story, show a silhouette (silhouette in 0:23-0:27 still counts as authentic gameplay if the in-game reveal looks like that).

## 15-second vertical cut (9:16, 1080x1920, TikTok / Shorts)

Re-frame the same footage with a portrait camera (phone-sized view in Studio, 1080x1920 capture). Put the creature in the top 60%; captions in the center-lower band, clear of platform UI (bottom 20%, right 15%).

| Time | Shot | On-screen text | Music |
| --- | --- | --- | --- |
| 0:00-0:02 | Clay creature wobbles awake, close-up (hook, movement in frame 1) | "Wait, it's all clay?" | Music box note |
| 0:02-0:06 | Lasso catch, tight on the timing ring and the catch sparkle | "Catch them" | Rising tick, catch jingle |
| 0:06-0:10 | Breeding: parts swap, egg hatch reveal | "Breed your own" | Hush, hatch chime |
| 0:10-0:13 | Firstling reveal, fast push-in, aura | "Find the Firstling" | Swell, hit |
| 0:13-0:15 | Logo and team line-up | "ClayPals. Free on Roblox." | Final chord |

Posting: caption "Which part would you breed first?" to prompt comments; 3 to 5 tags (#roblox #robloxgames #creaturecollecting #claypals). Check for any trending-audio use: only use music cleared for Roblox and the platform.

## Capture checklist (Studio)

1. Build a small camera-rig script in `tools/studio/` (not synced) for dolly, orbit and push-in moves; set a fixed seed so catches and hatches are repeatable.
2. Stage the lasso with a guaranteed perfect-timing hit (test seed or dev override in Studio only; never ship a client override, server stays authoritative).
3. Pre-stage a breed whose result looks good; record 3 takes of hatch.
4. Capture at 1080p 60fps (`video_capture`), plus 1080x1920 for vertical; hide dev overlays and the Explorer.
5. Edit externally; add captions, music and the end card. Re-check the art direction (chunky, flat, clay-toy) against brief section 12.
6. Upload as the game's video preview; make a 16:9 thumbnail from the Firstling frame or the catch sparkle and test two or three variants (wait 7+ days between changes).

## Open items for Ayrton

- Final tagline and logo.
- Music: pick a track from the Roblox audio catalog (or commission one) matching the cues above.
- Whether the Firstling is shown in full or as a silhouette (spoilers).

Sources: https://create.roblox.com/docs/production/publishing/thumbnails, https://create.roblox.com/docs/production/promotion/promotional-thumbnails
