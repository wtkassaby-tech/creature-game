# Approval pack 7: finds and rewards in side areas and dead ends

Date: 23 November 2026. For: Ayrton. Status: **draft, waiting for your yes. Nothing here is built.** Plan 12 (section 7.8) and plan 13 (section 8a) left every reward in a dead end or side area for this pack, because finds add to the saved record and to the economy. The project rules need your yes before either is touched, and an independent review after.

Every number in this pack is a **[Default]**: a starting value to tune in playtests, logged in `DECISIONS.md` when it changes. Read section 9 first if you only have two minutes: it lists what you are agreeing to.

## 1. What already exists

| Piece | State | Where |
| --- | --- | --- |
| Rooms and dead ends on the Greenwood routes | Built as map data (as built on 23 November, room names differ a little from plan 12; table 3a maps them) | `src/content/map_data/Greenwood.luau` |
| Dust Canyon and Tide Flats routes, rustle spots, the sea cave, the broken bridges | Built as map data | `src/content/map_data/DustCanyon.luau`, `TideFlats.luau` |
| Side areas (Gull Cove and the other eleven) | Planned only (plan 13 section 8a); none is in the map yet | `docs/plans/13_WORLD_DESIGN.md` |
| Biome materials (Fernfluff, Canyon Grit, Brine Shell, Reedpith), kept in `Profile.Items`, crafted into items | Built | `src/config/EconomyConfig.luau`, `src/shared/Shop.luau`, `src/shared/Rewards.luau` |
| One-time flags, daily counters reset by the server's date (forward only), the saved waiting list | Built and tested | `src/shared/Grants.luau`, `src/shared/Profile.luau` |
| Rustle spots, bait, the per-player wild book, server position checks with slack | Built | `src/shared/Encounters.luau`, `src/server/World/WorldService.luau` |
| The 30-day economy simulation | Built; balanced without finds | `tests/economy.test.luau`, `docs/ECONOMY_MODEL.md` |

## 2. The five kinds of find

| Kind | What the player does | Limit | What it can give | What it never gives |
| --- | --- | --- | --- | --- |
| **Cache** (one-time) | Walks into a dead end or through a hidden gap, holds the prompt on a basket, crate or crevice | **Once per player, ever** | Items and materials | Coins, creatures, Gems, Prism |
| **Gathering spot** (renewable) | Holds the prompt on a fern clump, grit seam or shell drift | **Once per spot per day**, 2 of the biome's material each [Default]. Opens with the first badge [Default] | That biome's material only | Anything else |
| **Sighting** (rare spawn) | Stirs a marked rustle spot in a side area or deep pocket | **The first stir of each day** at that spot brings out an Uncommon from the spot's own table [Default]; later stirs are ordinary rustles | A wild creature to battle and lasso as usual | A free creature. Catching still needs a lasso bought with earned coins and a throw |
| **Cairn** (landmark, one-time) | Reaches a viewpoint at the end of a branch and adds a stone to the cairn | **Once per player, ever**, one per biome | A keepsake (cosmetic) and a few of the biome's materials | Coins, creatures, Gems |
| **Lore note** (one-time) and **journal set** | Reads a note on a bench, a wall or a wreck; it becomes a page in the journal. Reading all of a biome's notes completes its set | Each note once; each set's reward **once per biome** | A note gives nothing but the page. A finished set gives a keepsake and 2 Prism Candy [Default] | Coins, creatures |

The notes are written by one unnamed old tamer who walked the whole ring before the player [Default]: their last page waits in the empty cottage at Mirror Mere (plan 13, side area j), which ties the side areas together. They stay vague about the mentor until the Arcane chapter, as plan 13 says for Starfall Crater. Names are [Open], as for the rest of the cast.

**Keepsakes** are a small new thing: a cosmetic object (an acorn, a potsherd, a gull feather) shown on a shelf in the stable and on the journal's page. A keepsake is owned when its cairn or set is claimed, so it needs no saved field of its own. It cannot be traded, sold or bought.

**How finds are seen.** Caches and notes glint faintly within 30 studs [Default] (looks only, on the device). The journal counts "finds in Greenwood: 4 of 7" per biome, so explorers know something is left without being told where. No map markers.

## 3. Which places get which finds

Exact positions are pinned in build step 1 so that they pass the existing layout rules: every prompt at least 32 studs from any other prompt, 26 from a grass centre, wholly on one tier, and inside walkable space. If a room is too small for its finds, the extra find moves to the nearest dead end in the same stretch.

### 3a. Greenwood (plan 12's pockets)

| Pocket (plan 12) | As built | Finds |
| --- | --- | --- |
| Glade pocket | `glade_pocket` | Gathering: fern clump (Fernfluff 2 a day) |
| Ledge lane bench (the dead end under the terrace) | West end of `ledge_lane` | Lore note 1: the bench under the waterfall's spray |
| Picnic hollow | `picnic_hollow` | Cache: a forgotten picnic basket (1 Rally Root). The window and its `giant_glimpse` beat are unchanged |
| Apple nook (the hidden gap in the meadow's west wall) | **Not built yet.** Needs an `apple_nook` room and its `hidden` gap (plan 12 section 5b), a small map change | Cache, hidden: the hollow under the apple tree (1 Braided Lasso, 3 Fernfluff) |
| Bank strip (the dead end under the ledges, heron view) | `bank_east` | Gathering: river fluff (Fernfluff 2 a day). Lore note 2: the heron pool |
| Burl clearing | `burl_room` on tier 20 | Sighting: the `burl_thicket` rustle spot's first stir each day is an Uncommon |
| The old wood | `wood_glade_room` | Lore note 3 |
| The old fence (Route A's end, under the waterfall) | Terrace end | Cairn: keepsake "spring-stone" and 3 Fernfluff |
| Journal set (notes 1 to 3) | | Keepsake and 2 Prism Candy |

### 3b. Dust Canyon

| Place | Finds |
| --- | --- |
| Hollow Arroyo (Route A's slot canyon) | Gathering: grit seam (Canyon Grit 2 a day) |
| The broken rope bridge (Route A's dead end) | Lore note 1: a scorched camp and a violet glint across the gap (Starfall Crater, seen, not reached) |
| Cairn Field (`cairn_field`) | Cache, hidden: under the leaning cairn (1 Gilded Lasso: the gem hunter's lasso, in the biome where gem tiers first appear) |
| Echo Notch (`echo_notch`, the rim cleft) | Sighting: first stir each day is an Uncommon |
| Spire Garden, the longer bare way round | Cache: a potter's cache (1 Deep Tonic, 3 Canyon Grit). Lore note 2 at the far end |
| The gorge-floor path (Route B's way home under the ledge chain) | Gathering: gorge seam (Canyon Grit 2 a day). Lore note 3 |
| Windward Overlook (Kilnrest, tier 10) | Cairn: keepsake "potsherd" and 3 Canyon Grit; the view of the Redstack |
| Winch track; Starfall Crater | Nothing at launch: both are shut. The crater opens in the Arcane chapter (decided 23 November) |
| Journal set | Keepsake and 2 Prism Candy |

### 3c. Tide Flats, with Gull Cove

| Place | Finds |
| --- | --- |
| Rockpool Shelf (Route A) | Gathering: shell pools (Brine Shell 2 a day) |
| The broken plank bridge (Route A's dead end, past the kelp shallows) | Cache: a driftwood crate (4 Brine Shell, 1 Rally Root) |
| Shipwreck Reach, inside the ribs | Cache: the ship's locker (2 Deep Tonic). Lore note 1: the night the light failed |
| The Tide Cave's outcrop | Lore note 2: the faint glow inside (placed clear of the `tide_cave` prompt) |
| **Gull Cove** (side area b: through the sea arch at the wrack beach's west end, then 300 studs along the cliff foot; open from arrival in Tide Flats) | Gathering: shell midden (Brine Shell 2 a day). Sighting: a new rock-pool rustle spot with **the cove's own table** (Tide Flats species at cove level, Uncommon-heavier, plus one visiting species from Dust Canyon). A grass patch with the same table. Cache, hidden: a crevice in a sea stack (1 Tide Bait). Cairn on the point beside the bench, looking out to Brine Isle and Palm Key: keepsake "gull feather" and 4 Brine Shell. Lore note 3 on the bench |
| Journal set | Keepsake and 2 Prism Candy |

Totals at launch: 7 caches, 7 gathering spots, 3 sightings, 3 cairns, 9 notes, 3 journal sets.

### 3d. Later side areas (outline; each gets its own short table when its biome opens)

| Side area | Biome | Planned finds |
| --- | --- | --- |
| Palm Key, Brine Isle | Tide Flats, with the ferry | Palm Key: gathering, a cache, a bench note; fishing is a later idea, not in this pack. Brine Isle: a frost-crystal cache and a note, the Frostline riddle |
| The Sunken Bell | Mire | Reedpith gathering, the bell tower's note set (the night the sky tore, from the Mire's side), a sighting |
| Glass Lake | Frostline | Gathering through the ice, a sighting, a hut cache |
| Whitefang Summit | Frostline | **The summit cairn**, the biggest cairn: a keepsake flag and a stack of Frostline material. No Prism, no coins |
| Steamvale | Emberfall | Gathering at the hot pools, a bathhouse note |
| Cloud Isle | Stormreach | A cairn at the world panorama; the tear's first sight stays a story beat |
| Mirror Mere, Toadstool Dell, the Spring Plateau | Arcane biome, via the Old Lane | The old tamer's last page and cottage cache; the Dell's own sighting table; a cairn on the plateau looking down on Thistledown |
| Starfall Crater | Dust Canyon, opened in the Arcane chapter | The lore climax note, a violet-glass cache. No Cosmic creature: Cosmic is never wild |

Later biomes need their own materials named (`MATERIAL_BY_BIOME` stops at the Mire's Reedpith). Each new biome reruns the economy simulation before its finds ship.

## 4. Save data

### 4a. New fields

```luau
-- src/shared/Profile.luau
export type Finds = {
	-- One-time finds claimed, by find id: caches opened, notes read, cairns built, journal
	-- sets paid. A key is only ever added, never removed or reset.
	once: { [string]: boolean },
}

export type Daily = {
	-- ...existing fields...
	-- Renewable finds used today, by find id: gathering spots and sighting spots.
	-- Cleared by Grants.rollDay with the other daily counters, by the server's date only.
	finds: { [string]: number },
}

export type Profile = {
	-- ...existing fields...
	Finds: Finds,
}
```

The template gives a new player `Finds = { once = {} }` and `Daily.finds = {}`.

**Why a field of its own, not `Story.flags`.** One-time gifts use `Story.flags` today, but those flags are sent to the device as a list capped at 200 (`PlayerState.Flags`), and finds would add 22 at launch and 150 or more by the eleventh biome. A separate field also gets its own soundness checks. The largest it can grow, with every find in all eleven biomes claimed, is about 10 KB, far below Roblox's 4 MB.

### 4b. SchemaVersion and the migration

- `ProfileConfig.SCHEMA_VERSION` goes from 1 to 2, and `MIGRATIONS[1]` adds the two fields:

```luau
MIGRATIONS[1] = function(data)
	if typeof(data.Finds) ~= "table" then
		data.Finds = { once = {} }
	elseif typeof(data.Finds.once) ~= "table" then
		data.Finds.once = {}
	end
	if typeof(data.Daily) == "table" and typeof(data.Daily.finds) ~= "table" then
		data.Daily.finds = {}
	end
end
```

- It runs on a copy, as every migration does (pack 1): a failure leaves the save untouched and the player is not let in on blank data.
- Nothing is back-filled: every existing player starts with no finds claimed.
- Approval pack 6 (move imprint) also bumps the version. Whichever is built first takes version 2; the other becomes 2 to 3. Each keeps its own migration and test.

### 4c. A one-time find can never be claimed twice

1. The check (`Finds.once[id]` is not set) and the change (set it, add every item) happen in one function with no pause in between, so a second request, even one sent in the same instant, sees the first one's flag.
2. The flag and the items live in the same record, saved together by ProfileStore with its session lock. A crash before the save loses both together; nothing is ever copied. A second server cannot load the record at all.
3. If the items do not fit (an item at the 999 carry limit, `Shop.MAX_HELD`), the whole claim is refused and the flag is **not** set, so the player can come back. Nothing is half given.
4. **Find ids are permanent**, like serial numbers: never renamed, reused or removed once shipped. A renamed cache would be a fresh claim for everyone. A test keeps the list of shipped ids and fails if one disappears or changes.

### 4d. Daily caps and their reset

- Gathering: `Daily.finds[spotId]` must be below `GATHER_PER_SPOT_PER_DAY` (1 [Default]). Sightings: below `SIGHTINGS_PER_SPOT_PER_DAY` (1 [Default]).
- `GATHER_DAILY_CAP` (30 materials a day across every spot [Default]) is a safety ceiling, so adding spots in data can never quietly flood materials. With the launch spots the most anyone can gather is 14.
- The counters are cleared by `Grants.rollDay`, which uses the server's date only and moves forward only, so a device's clock, leaving and rejoining, or two servers disagreeing near midnight cannot reset anything.
- A sighting's use is counted the moment the creature steps out, not when the battle starts. Otherwise a player could look at the creature's rarity tell, walk away, and stir again for a better one. Bait already works this way.

### 4e. Soundness checks (logged as an alarm, never deleting anything)

- Every value in `Finds.once` is `true`; every key is a known find id (an unknown one is reported, as an unknown species is).
- Every `Daily.finds` count is a whole number from 0 to that find's daily limit.
- Both fields are storable (the existing `isStorable` check).

### 4f. Logging (hard rule 8)

| Line | When | Fields |
| --- | --- | --- |
| `FindClaimed` | A cache, cairn, note or journal set is claimed | player, find id, kind, biome, each item and count, Prism, server day |
| `FindGathered` | A gathering spot pays | player, spot id, material, count, materials gathered today |
| `FindSighted` | A sighting brings a creature out | player, spot id, spawn id, species, rarity, seed. If it is caught, the existing capture line logs the creature id with the spawn id, so every sighted creature can be traced |
| `SearchRefused` | A search is refused | player, find id, reason, distance. More than 10 far-away refusals in 5 minutes [Default] raises `SearchFarAlarm` for review |

All of them go through `AnalyticsFeed` like the existing lines; materials and items are reported as economy sources named "Find". Prism from journal sets goes through `Economy.apply` with a new ledger flow, `CandyJournal` (Prism, limit Once).

## 5. Server flow

### 5a. Messages (Blink, `src/net/Net.blink`)

```
-- Device -> server: search a find: a cache, a gathering spot, a note or a cairn. The device names
-- the find; the server checks everything else.
event Search {
	From: Client,
	Type: Reliable,
	Call: SingleAsync,
	Data: struct { FindId: string(1..40) },
}

enum FindOutcome = { Found, Gathered, Read, Built, AlreadyFound, Resting, TooFar, Shut, Full }
struct FindGain { Item: string(1..40), Count: u16 }

-- Server -> device: how a search went, and what it gave.
event SearchResult {
	From: Server,
	Type: Reliable,
	Call: SingleAsync,
	Data: struct {
		FindId: string(1..40),
		Outcome: FindOutcome,
		Gains: FindGain[0..8],
		Prism: u8,
		SetDone: boolean, -- this note finished the biome's journal set
	},
}
```

`PlayerState` gains `Finds: string(1..40)[0..400]` (one-time finds claimed) and `FindsToday: string(1..40)[0..64]` (spots used today), display only. Sightings need no new message: they use the existing `Rustle`, with the sighting spot marked in the data.

### 5b. What the server checks, in order, for `Search`

1. **Rate limit**: at most one search a second per player [Default], before anything else is read.
2. **Type and existence**: the id is a string naming a find in an open biome. Closed biomes' finds are left out of the registry, as for every other registry (`ReleaseConfig`).
3. **The record is loaded and its session is held**, and the player is not in a battle (`isReady`).
4. **Gating**: the biome may be entered (`mayEnter`), and a side area's `opens` rule (badges or a story flag) is met. Gathering also needs the first badge. Otherwise `Shut`.
5. **Position**, from the server's own reading of the character:
   - within `SEARCH_RADIUS` (10 studs [Default]) plus the usual `POSITION_SLACK` (8) of the find's place;
   - at the find's height: the root is within 6 studs [Default] of `Ground.heightAt` at the find, so nobody searches a dead end from the ledge above it;
   - **lingered**: the player has been inside that radius for at least 1 second [Default] across two world ticks. The device's hold-to-search prompt takes 1.5 seconds, so an honest player always passes;
   - **no jump**: no step in the player's last 5 seconds of positions is faster than 3 times walking speed [Default]. Moves the server makes itself (Travel, rides, a Stormreach fall) reset this trail.
6. **Limit**: not already claimed (one-time) or used today (daily). Otherwise `AlreadyFound` or `Resting`.
7. **Room**: every item fits under the carry limit. Otherwise `Full`, with nothing changed.
8. **One step, no pause**: set the flag or count, add the items (and Prism for a journal set), log the line, and send the new state.

For a sighting, the existing `Rustle` handler gains one branch: if the spot is a sighting spot and `Daily.finds[spot]` is 0, the creature it brings out is drawn from the spot's Uncommon rows, and the count is set in the same step that adds the creature to the player's wild book. The gem-tier chance is the normal wild one (`GEM_WILD_SHARE`, 0.6% from Dust Canyon on) [Default]. From then on the battle, the lasso, the catch, the gem serial and the candy all run through the existing, reviewed code.

### 5c. Where the code goes

| File | What |
| --- | --- |
| `src/shared/WorldTypes.luau` | `FindKind`, `Find`, `JournalSet` types (a find's rewards reuse the existing `Reward` type) |
| `src/content/Finds.luau` and `src/content/finds_data/` | The registry, one data file per biome (the folder name differs from the registry's, for Windows) |
| `src/config/FindsConfig.luau` | Every number in this pack |
| `src/shared/Finds.luau` | Pure rules: why a search is refused, and the claim itself on the profile. No Roblox services; tested under Lune |
| `src/server/Finds/FindService.luau` | The `Search` handler: rate limit, position trail, calls the pure rules, logs |
| `src/client/UI/` | Hold-to-search prompts, the find card, the journal screen, the keepsake shelf |

## 6. Economy

### 6a. What finds add (after the story, the most a player can take if they visit everything)

| Source | Most a day | Worth in coins | Against a regular player's day (28,102 coins created) |
| --- | --- | --- | --- |
| Gathering, 7 spots | 4 Fernfluff, 4 Canyon Grit, 6 Brine Shell | 40 + 93 + 240 = **373** (materials valued by `Economy.materialValue`: what they save when crafted) | 1.3% |
| Sightings, 3 spots | 3 extra wild wins and, if caught, 3 Uncommon catches | **about 590 coins** from the normal wild-win rule (Tide Flats pays most), plus up to 6 typed candy before the falloff | 2.1% |
| One-time finds, whole story | 7 caches, 3 cairns, 3 journal sets | **about 1,820** in items and materials, plus **6 Prism**, once per account | About 2% of what a regular player earns in week one |

A full daily round of every gathering spot and sighting takes about 20 to 25 minutes of walking [Default estimate] and is worth about 960 coins, roughly **2,500 an hour**, against about **37,000 an hour** of ordinary play after the story. It cannot be repeated the same day. Finds are a reason to walk the world, never a better farm than battling.

Coins come from finds only through the sighting battles, which are ordinary wild wins under the daily falloff. **Caches, cairns, notes and gathering never pay coins**, as plan 12 proposed.

### 6b. Checked against the simulation's results

These are estimates from the published results (`docs/ECONOMY_MODEL.md`, tables A to I). Build step 4 adds finds to `tests/economy.test.luau` and reruns it; the numbers below get replaced by the real ones before anything ships.

| Target | Now | With finds (estimate) | Why |
| --- | --- | --- | --- |
| 57 to 73% of coins removed in the first two hours | Casual 68%, regular 59%, **heavy 57% (at the floor)** | Down by about 1 point, 2 at worst | Gathering opens with the first badge, so it is out of the first two hours, as daily tasks are. Greenwood's one-time finds are worth 290 coins; the Braided Lasso is not bought before Dust Canyon, so at most about 210 replaces shop spending (the Fernfluff's two tonics and the Rally Root): about 2 points of the roughly 10,500 coins made in two hours if all of it did, and the Rally Root only replaces a purchase if the player would have bought one for the giant |
| 80 to 95% removed after the story | Casual 89%, regular 92%, heavy 89% | About 85%, 89%, 87% | Free materials replace some shop and crafting spending (less removed); sighting wins add coins (more created) |
| Gem-tier days stay within two thirds to 1.5 times the old figures (table G) | Regular 1.8 / 4.4 / 10.9 days | Perhaps 5 to 15% shorter for players who do every sighting | Sighting catches pay Uncommon candy (2 at full), under the same per-type falloff. A regular player's best type gains about 1 to 2 a day |
| Catch-and-release for an hour pays at most 1.5 times a normal hour (table I) | 1.00 to 1.40 | Unchanged | Sightings are once a day per spot; farming cannot repeat them |
| Prism about 5.9 (regular) a day after the story | 5.9 | Unchanged | Journal Prism is once per biome: 6 in total, ever |
| Gem-tier encounters stay rare | 0.6% of wild encounters | About 0.02 more a day per player | Sightings use the normal gem chance; the one free bait adds 0.35 of a gem encounter, once |

**If the heavy player's first-two-hours ratio falls below 57%** in the rerun, the picnic basket's Rally Root becomes a keepsake, cutting Greenwood's worst case to about 0.6 points. That is the planned fallback; no other target is close to its edge.

### 6c. How the sinks absorb it

- Materials only ever become crafted items (tonics, Deep Tonics, bait, cures), and crafted items cannot be sold back, so **materials never turn into coins**. Each recipe also costs coins (the Craft sink).
- Coins a player saves by crafting rather than buying flow to breeding, which in the simulation runs whenever coins allow, then stable expansions and decorations. Those three already take 62 to 91% of all coin spending (table F), and the shop takes the rest.
- Extra bait material does not raise the gem flow: bait use stays capped at 5 a day, and coins were never what limited it.

### 6d. Roblox policy and the hard rules

- No coin bets, no stakes: finds have nothing to do with PvP.
- **Nothing in this pack is sold for Robux or Gems**: no find, no gathering refresh, no sighting reroll, no find map or radar, no skip. So nothing bought is random, and `ArePaidRandomItemsRestricted` is not engaged.
- **Rare spawns keep catching free**: a sighting brings out a wild creature; catching it still needs a lasso bought with earned coins, judged by the server, exactly as today.
- Gathering yields are fixed, not random. A sighting's species is random but free, and the journal lists what each sighting spot can bring out anyway.
- Creatures still come only from the server's existing grant paths (pack 2); a find never grants a creature directly.

## 7. Exploits and the answers

| Risk | Answer |
| --- | --- |
| Second accounts farming one-time finds | Finds are per profile, so each account gets the same small set once. Their items and materials cannot be traded or gifted (to be confirmed in the trading pack; see question 6), so they cannot be funnelled to a main account |
| Second accounts farming daily sightings for creatures to trade later | One Uncommon per spot per day per account, at the normal gem chance. Trading's own limits (the later trading pack) cover all wild creatures alike |
| Position spoofing (a moved character, a teleport) | The server reads its own copy of the position, checks height, lingering and the speed trail. A teleporter can gain only **time**: the same fixed one-time set and daily caps an honest player gets. Refusals are logged and bursts raise an alarm |
| Searching a dead end from the ledge above it | The height check, plus plan 12's rule that nothing the server checks straddles a level |
| Rapid or simultaneous repeat requests | One search a second per player; the claim checks and sets the flag in one step with no pause |
| Duplication on rejoin, or in two servers | The flag and the items are in one record under ProfileStore's session lock: a second server cannot load it, and a crash before a save loses both together |
| Resetting daily caps by rejoining, changing the device clock, or crossing midnight between servers | Counters are saved and reset only by the server's date, forward only |
| Rerolling a sighting by walking away | Its use is counted when the creature steps out |
| A device naming a find in a closed biome, a shut side area, a made-up id or a 10,000-character string | Blink bounds the string; closed biomes' finds are not in the registry; `opens` is checked; unknown ids are refused and counted |
| A full bag swallowing a one-time reward | The claim is refused whole and the flag is not set |
| A content change renaming a find, so everyone claims it again | Shipped find ids are permanent and pinned by a test |
| Data that gives coins or creatures from a find by mistake | A test refuses any find whose rewards include Coins, Creature, Egg, Pen or Gems, and any Prism outside a journal set |

### Independent review checklist (before merging; findings go in `docs/REVIEWS.md`)

A reviewer that did not write the code (the `exploit-reviewer` agent, or a separate session) checks:

- [ ] Every path that grants a find checks and sets its flag or count in the same step, with no yield (no `task.wait`, no data store call, no remote call) in between.
- [ ] A refused claim changes nothing in the profile.
- [ ] The handler reads only the find id from the device; position, height, time, rarity and rewards all come from the server.
- [ ] The rate limit runs before any profile read; the position trail cannot be reset by anything the device sends.
- [ ] Nothing grants a find while the record is not loaded, or after its session was lost.
- [ ] `rollDay` clears `Daily.finds` and never moves a day backwards.
- [ ] The migration runs on a copy, adds only the two fields, and leaves every other field exactly as it was.
- [ ] No find pays coins, creatures, Gems or Prism outside a journal set; materials never convert to coins anywhere.
- [ ] The sighting branch takes the normal gem chance and counts its use when the creature steps out.
- [ ] Every claim and refusal is logged with the fields in section 4f.
- [ ] Alt-account transfer: nothing a find gives can move to another account.
- [ ] No Robux or Gem product touches finds.

## 8. Tests and build order

### 8a. Tests

| Test | Where |
| --- | --- |
| A cache claimed once, then `AlreadyFound`; flag and items set together; a full bag refuses with nothing changed | `tests/finds.test.luau` (new) |
| Gathering pays once per spot per day; closed before the first badge; the day rolls forward only; the daily safety cap holds | `tests/finds.test.luau` |
| A sighting counts on spawn; its creature comes from the spot's Uncommon rows; the gem chance is the normal one; a second stir that day is an ordinary rustle | `tests/finds.test.luau` and `tests/encounters.test.luau` |
| Refusals: too far, wrong height, not lingered, a jump in the trail, a shut side area, a closed biome, an unknown id, a non-string id | `tests/finds.test.luau` |
| A journal set pays once, only when every note in it is read | `tests/finds.test.luau` |
| Data rules: ids unique across all biomes; no coins, creatures, Gems; Prism only in sets; shipped ids still present and unchanged (a snapshot list) | `tests/finds.test.luau` |
| Every find lies in walkable space, on one tier, clear of tier edges, 32 from other prompts and 26 from grass centres, and can be walked to from its hub (`Walk.reach`), a hidden one only through its gap | `tests/layout.test.luau`, `tests/walk.test.luau` |
| Migration 1 to 2: adds the fields, keeps everything else, fails safely on a broken save; the new soundness checks catch bad counts, non-true flags and unknown ids | `tests/profile.test.luau` |
| The simulation with finds: each player type gathers, sights and finds caches as it plays (casual 2 spots a day, regular 5, heavy all 7 [Default]); every target in section 6b still holds; a daily round pays less than a quarter of the same minutes of battling | `tests/economy.test.luau` |
| No find in a closed biome is exposed | `tests/release.test.luau` |
| Studio: every find twice in a row and two searches sent together; searching from the ledge above; a server-side character move refused; leave and rejoin after a claim; a server stopped before its save (both flag and items roll back); midnight with a moved clock | Studio, on a phone-sized view |

### 8b. Build order (after your yes)

1. **Data only.** Types, `FindsConfig`, the three biome data files, the `apple_nook` room and hidden gap, find places pinned into the map sheets; the layout and data-rule tests. Grants nothing.
2. **Pure rules.** `src/shared/Finds.luau` and its tests.
3. **Save change.** Profile version 2: template, migration, soundness checks, `rollDay`, and their tests.
4. **Economy rerun.** Finds in the simulation; rerun; update `ECONOMY_MODEL.md` and log any changed number in `DECISIONS.md`. Stop and report if a target fails.
5. **Server.** The Blink messages, `FindService`, the sighting branch in the `Rustle` handler, `PlayerState` additions; `lune run check` passes.
6. **Device.** Prompts, glints, the find card, the journal screen, the keepsake shelf.
7. **Dressing.** Basket, crate, crevice, cairn and note props in the clay-toy style; gathering props per biome. Gull Cove itself is built under plan 13 (its map, arch and passage); its finds slot in when it is.
8. **Studio playtest** of every case in 8a; screenshots checked against the art direction.
9. **Independent exploit review** with the checklist in section 7, before merging. Findings in `REVIEWS.md`.
10. Later biomes' finds go in as data when each biome opens, with a rerun of the simulation.

## 9. What you are approving

- [ ] The five kinds of find in section 2, with their limits, and the placements in section 3 for the three launch biomes and Gull Cove.
- [ ] Caches, cairns, notes and gathering never pay coins; a sighting pays only the normal wild-win coins.
- [ ] The save change in section 4: a new `Finds` field, `Daily.finds`, schema version 2 with its migration, and permanent find ids.
- [ ] The server checks in section 5, including the height, lingering and speed-trail checks.
- [ ] Nothing about finds is ever sold for Robux or Gems.
- [ ] The economy estimates in section 6, to be replaced by the rerun before shipping, with the Rally Root fallback if the heavy player's first two hours dip below 57%.

Questions that are yours (in one batch):

1. **Gathering opens with the first badge**, as daily tasks do, to keep the first hours on the story and the early coin ratio on target. I recommend yes. The badge could come with a gathering satchel from the mentor, so the story explains it.
2. **Journal sets pay 2 Prism Candy each** (6 in total across the launch biomes). This adds a Prism source to the table you approved in pack 3. I recommend yes: it is small, once only, and rewards reading.
3. **Keepsakes**: a new cosmetic kind, shown on a shelf in the stable. Yes, or keep cairns and sets to materials only?
4. **Sightings at the normal gem chance** (0.6%), or a small boost (for example 2%) to make side areas the place gem hunters go? I recommend the normal chance at launch: gem tiers are what the economy is most sensitive to, and a boost is easy to add later as a live event.
5. **Gull Cove's table**: existing species with different weights (my default), or one cove-only species? A new species is original design and model work, so I would add it after launch.
6. **Materials and consumables never become tradeable**, so second accounts can never feed finds to a main account. I recommend yes; it would be written into the trading pack.
7. One free Tide Bait from Gull Cove's hidden crevice: a nice find, or too generous? (It adds about a third of one gem-tier encounter, once per account.)
