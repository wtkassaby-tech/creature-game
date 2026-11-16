# Creature Game

A turn-based Roblox creature game: tame with a lasso, battle, breed creatures part by part, and trade. Working title. Owner: Ayrton.

**This folder is the future repository.** It sits inside the golf-game repo only until the creature game has its own. It is laid out exactly as that repo's root will be, so moving it is a copy (steps at the bottom). Nothing here changes the golf game.

## Start here

| If you want | Read |
| --- | --- |
| What the game is | `docs/BRIEF.md` (Ayrton's design brief; the live doc wins if they differ) |
| What has been decided since | `docs/DECISIONS.md` (wins over the brief) |
| What to build, in what order | `docs/MASTER_PLAN.md` |
| What happened last and what to playtest | `docs/PROGRESS.md` |
| The rules Claude Code works by | `CLAUDE_DRAFT.md` (becomes `CLAUDE.md` in the new repo) |

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

## Moving this folder into its own repository

1. Create an empty repository.
2. Copy everything in this folder into it, including the hidden `.github`, `.claude`, `.gitignore`, `.luaurc`, `.mcp.json`, `.styluaignore` and `.gitattributes`.
3. Rename `CLAUDE_DRAFT.md` to `CLAUDE.md` and delete the note at its top.
4. Run `rokit install`, `wally install`, then `lune run check`.
5. Push. The workflow in `.github/workflows/ci.yml` runs the same check on every push.
