# Creature Game

A turn-based Roblox creature game: tame with a lasso, battle, breed creatures part by part, and trade. Working title. Owner: Ayrton.

This is the game's own repository. It began as a folder inside the golf-game repo and was split out on 20 November 2026; the two projects share nothing.

## Start here

| If you want | Read |
| --- | --- |
| What the game is | `docs/BRIEF.md` (Ayrton's design brief; the live doc wins if they differ) |
| What has been decided since | `docs/DECISIONS.md` (wins over the brief) |
| What to build, in what order | `docs/MASTER_PLAN.md` |
| What happened last and what to playtest | `docs/PROGRESS.md` |
| The rules Claude Code works by | `CLAUDE.md` |

## What exists

| Path | What |
| --- | --- |
| `src/shared/` | Pure rules, tested under Lune: stats, breeding, battle, the type chart, assembly maths, seeded random numbers |
| `src/config/` | Balance numbers for breeding and battles |
| `src/content/` | Species and move registries. Real species arrive with the Greenwood roster |
| `src/server/Breeding/` | The server's breed request (written, not yet run in Studio) |
| `src/client/Assembler/` | Builds a creature model from its record (written, not yet run in Studio) |
| `tests/` | Breeding and battle tests with worked examples; `fixtures/` holds placeholder species for tests only |
| `lune/check.luau` | The quality gate |
| `docs/` | The brief, decisions, plans and research |

## Running the checks

With the tools installed by Rokit (`rokit install`) and packages by Wally (`wally install`):

```
lune run check
```

It runs, in order: Blink generation (once networking exists), StyLua, Selene, strict type analysis with luau-lsp, every `tests/*.test.luau`, and a Rojo build. A task is not done until it passes.

To run one test file: `lune run tests/breeding.test`.
