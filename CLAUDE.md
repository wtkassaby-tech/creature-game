# CLAUDE.md

Rules for Claude Code on this project. Read this every session.

## The brief is the vision

The game is defined by Ayrton's design brief: `docs/BRIEF.md`, a snapshot of the live doc at https://claude.ai/artifact/SXN85dnsvkAN8jYM9jQpcY (if they differ, the live doc wins). Read the relevant section before starting any feature. Decisions made since the brief, and every change to a [Default], are in `docs/DECISIONS.md`. The build order, structure, gates and approval packs are in `docs/MASTER_PLAN.md`. Where it changes the brief (for example, coin bets were removed), `docs/DECISIONS.md` wins.

In one line: a turn-based Roblox creature game where players tame (lasso), battle, breed (part-based, generational) and trade creatures across eleven biomes, with a story. The structure follows Project Pokemon: route, town, giant, gate battle and badge, next biome, building toward a team of six.

How to treat the brief's labels (brief section 1):

| Label | What you do |
| --- | --- |
| **[Locked]** | Build to it. If it causes a problem, propose a change; never change it without Ayrton's OK. |
| **[Default]** | Improve it freely (numbers, formulas, names, architecture, build order) and log each change in `docs/DECISIONS.md` with the reason. |
| **[Open]** | Use the brief's placeholder so work is not blocked, and list it for Ayrton. Ask about open items in batches, not one at a time. |

- The pillars (brief section 2) outrank every detail. Playtesting outranks the brief: if it feels bad in play, change it and say so.
- Small ideas (a move effect, a quest, a UI touch) can just be built. Big ones (a new system, anything that changes the economy, anything that touches Robux) are proposed first.

The owner (Ayrton) reviews plans, plays builds and approves gates. You do the building.

## Hard rules

1. **Server-authoritative.** Clients send intent only: a chosen battle action (move, switch, item, lasso), a lasso timing input, a breed request, a trade offer. The server decides every battle result, trade, capture and breed, and judges lasso timing on its own clock. Never trust a client value.
2. **Original content.** Every creature, name, move, item and capture tool is original (brief guardrail 3). Structure is borrowed; content never is.
3. **Creatures change hands only through trading**, never through a battle result. Nothing is ever staked on a match.
4. **Roblox policy rules** (brief section 11; re-check the live docs before launch, they changed several times in 2026):
   - Coins are never sold for Robux.
   - Lassos, bait and breeding are paid with earned coins only, so catching and breeding stay free random outcomes.
   - Anything random bought with Robux, or with a currency Robux can buy, shows every outcome and its odds (summing to 100%) before purchase. Check `PolicyService:GetPolicyInfoForPlayerAsync()` and honour `ArePaidRandomItemsRestricted` and `IsPaidItemTradingAllowed`.
   - No coin bets or staked matches (removed by Ayrton on 16 November 2026; see `docs/DECISIONS.md`). PvP rewards are created by the game: casual coin rewards with a daily cap, and ranked-season prizes.
5. **All networking goes through Blink.** Every message is defined in `src/net/*.blink`. No raw RemoteEvents. Every server handler validates and rate-limits.
6. **Player data goes through ProfileStore** with session locking, so one account cannot load in two servers. Save data carries `SchemaVersion` from day one; every schema change ships with a migration and a test.
7. **Purchases are idempotent.** A `ProcessReceipt` grant happens once per `PurchaseId`, even if Roblox retries.
8. **Value moves atomically and is logged.** Trades complete on both sides or neither. Serial numbers come from a global counter, are assigned in the same save that grants the creature, and are never changed or reused. Log every trade, breed and capture with creature IDs.
9. **Data, not code.** Species (parts, ratios, stats, moves), types, biomes, rarity tiers, giants and story chapters are data, so later biomes and stage 2 and 3 of the roadmap slot in without rewrites. Every balance number lives in `src/config/`.
10. **Pure logic in `src/shared/`.** Damage, turn order, breeding inheritance and proportion scaling are pure functions with no Roblox service calls, unit-tested under Lune. Breeding also has a simulation test (thousands of breeds) that checks the stat and rarity distributions and the stat ceilings.
11. **Use only verified Roblox APIs.** When unsure, check the docs (links below) or the Studio MCP docs tools. Never invent an API.

## Workflow for every feature

1. Read the relevant brief section and any later lines in `docs/DECISIONS.md`.
2. Write a short plan (files, data changes, risks). For anything touching saving, purchases, captures, breeding rolls, serials, trading or PvP rewards, stop and get Ayrton's approval first.
3. Write the code and unit tests together.
4. Run `lune run check` (format, lint, strict types, tests, build). Fix every failure. A task is not done until it passes.
5. Run it in Studio through the Studio MCP: playtest, simulate input on a phone-sized view, read the console, fix errors. (The Studio MCP needs Studio on Ayrton's computer; a cloud session cannot reach it.)
6. For any visual change, take a `screen_capture` and check it against the brief's art direction (low-poly, chunky, flat colours; section 12).
7. Commit with a clear message. One working feature per commit.
8. Update `docs/PROGRESS.md` with what changed and what Ayrton should playtest, and `docs/DECISIONS.md` for any [Default] you changed.

For saving, purchases, captures, breeding, serials, trading and PvP rewards: before merging, run an independent review in a separate session or subagent that did not write the code, focused on exploits, duplication, alt-account coin transfer and money handling. Record findings in `docs/REVIEWS.md`.

## Project layout

```
src/
  shared/      pure rules, no Roblox services: Types, Rng, Stats, Breeding, AssemblyMath, Battle, TypeChart, ...
  config/      every balance number: BreedConfig, BattleConfig, ...
  content/     data only: Species.luau and Moves.luau (registries), species/ (one file per species),
               then biomes, giants, tamers, quests, story, items
  net/         Blink definitions and generated modules
  server/      one folder per service: Breeding/, then Data/, Creatures/, Battle/, Capture/, World/, Quests/,
               Economy/, Purchases/, LiveConfig/, Analytics/ (Circuit/ and Trading/ after launch)
  client/      Assembler/, then Animation/, Icons/, BattleView/, Lasso/, World/, Audio/, UI/
tests/         Lune tests, one `Name.test.luau` per area; fixtures/ holds placeholder data for tests only
lune/          check.luau (the quality gate) and tools
tools/studio/  scripts that are pasted or run inside Studio, never synced into the game
docs/          BRIEF, DECISIONS, MASTER_PLAN, BREEDING_PLAN, PART_SPEC, PROGRESS, REVIEWS, ASSETS, plans/, research/
```

Rojo maps: `src/shared`, `src/config`, `src/content` and `src/net` -> `ReplicatedStorage`; `src/server` -> `ServerScriptService`; `src/client` -> `StarterPlayer.StarterPlayerScripts`; packages -> `ReplicatedStorage.Packages` / `ServerScriptService.ServerPackages`.

## Conventions

**Requires** (the golf project's convention, verified in Studio there):

- Inside `src/shared`, `src/config`, `src/content` and tests: relative string requires that start with `./` or `../`, with no extension, such as `require("../config/BreedConfig")`. They resolve the same way in Roblox and under Lune.
- Server and client code loads shared modules through the instance tree: `require(game:GetService("ReplicatedStorage").shared.Breeding)`, `.config.X`, `.content.X`.
- Folder names under `src/` are lowercase and equal their Rojo instance names. Do not use `init.luau` for modules that need relative requires; use `Name.luau` files. Bootstraps are `Main.server.luau` and `Main.client.luau`.
- Tests require `../src/shared/X` by file path. A test that needs species installs the fixtures first: `require("./fixtures/Placeholders").install()`.

**Types that pass the strict checker** (learned the hard way; see the note at the top of `src/shared/Types.luau`):

- A fixed set of keys is a record, not a map: `Types.BySlot<T>`, `Types.ByRarity<T>`, `Types.ByPlan<T>`, `Types.StatBlock`. `record[slot]` and `record.Legs` both check; `{ [Slot]: T }` does not.
- Declare lists of names with an annotation, `local SLOTS: { Types.Slot } = { ... }`, never with a `::` cast.
- When a name comes out of a list from another module, annotate the variable that receives it: `for _, slot: Types.Slot in BreedConfig.SLOTS do`, `local tier: Types.Rarity = ORDER[index]`.
- An `if ... then {..} else {..}` that picks between two tables needs an annotation on the variable.

## Code style

- Every file starts with `--!strict`. Type every function signature and every record.
- Small modules with one job. No file over ~400 lines without a note explaining why.
- `PascalCase` modules and types, `camelCase` locals and functions, `SCREAMING_CASE` config constants.
- Use `task.*`, never `wait()`, `spawn()` or `delay()`. No deprecated APIs.
- Clean up connections with a Janitor/Trove-style cleaner.
- StyLua formatting, Selene linting. Never disable a lint rule without a comment explaining why.
- Randomness in shared logic comes from `src/shared/Rng` with a seed passed in explicitly, so results replay identically under Lune and in Roblox. Never `math.random`.

## Assets

The asset rule is [Open] in the brief (section 15). Until Ayrton decides: generate art (AI tools or built in code) to the part specification in brief section 12. Ask before inserting any Creator Store or marketplace asset; if one is approved, check its licence, strip or read every script in it, and record its id, creator and licence.

## Roblox docs for agents

- Engine scripting: https://create.roblox.com/docs/reference/engine/llms.txt
- Docs index: https://create.roblox.com/docs/llms.txt
- Cloud APIs: https://create.roblox.com/docs/cloud/llms.txt
- Any docs page as markdown: append `.md` to its URL.

## Never

- Trust client data or let the client grant itself anything.
- Write to DataStores outside ProfileStore (global serial counters and leaderboards use their own documented stores, server-side only, updated atomically).
- Sell coins, stat boosts, rarity, serial numbers, cosmic wraps or anything with a random result.
- Let a creature or item change hands through a battle result, or put anything at stake on a match.
- Skip `lune run check`, or commit with failing tests.
- Change a [Locked] item in the brief without asking Ayrton.
