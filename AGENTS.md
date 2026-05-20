# Zone Frontier Project Rules

These rules are persistent project context. Follow them for every development task unless the user explicitly changes them.

## Project Goal

Zone Frontier is a modular MO2-compatible gameplay mod for S.T.A.L.K.E.R. GAMMA 0.9.5.

The mod adds a strategic layer on top of GAMMA:

- territory ownership;
- logistics and caravans;
- faction economy;
- strategic resources;
- tactical construction;
- strategic AI;
- PDA/debug interfaces for strategic state.

GAMMA remains responsible for survival, combat, weapons, items, ALife, atmosphere, crafting, and most low-level game behavior.

## Work Locations

Primary development happens only in this repository:

```text
E:\Zone Frontier
```

The working GAMMA installation is treated as a deployment target only:

```text
D:\GAMMA
```

The base Anomaly installation is treated as a reference/runtime dependency only:

```text
D:\Anomaly
```

Do not develop directly inside `D:\Anomaly\gamedata`.

Do not edit existing GAMMA mods directly inside `D:\GAMMA\mods\...` unless the user explicitly requests a one-off investigation or emergency fix.

## Deployment Rule

Zone Frontier must be deployed to GAMMA as its own MO2 mod, for example:

```text
D:\GAMMA\mods\999- Zone Frontier
```

Only deploy runtime mod files there, primarily:

```text
gamedata\
```

Do not deploy project docs, tests, tools, scratch files, or Git metadata into GAMMA.

Prefer a repeatable deploy script over manual copying.

## Safety Rules

Never overwrite or delete existing GAMMA/Anomaly files casually.

If a vanilla/GAMMA file must be overridden, put the override in the Zone Frontier MO2 mod so it can be enabled, disabled, compared, and removed cleanly.

Before touching any file under `D:\GAMMA` or `D:\Anomaly`, first determine whether it is:

- a source/reference file being read;
- a Zone Frontier deployed file;
- an existing third-party mod file;
- an overwrite/profile/generated file.

Treat non-Zone-Frontier files as read-only by default.

## Development Approach

Build in small verified steps.

The preferred order is:

1. Project structure.
2. Minimal mod load proof.
3. Logging and debug helpers.
4. Core data model.
5. Strategic tick.
6. Save/load.
7. Territory/resource prototype.
8. Caravan prototype.
9. Smart terrain integration.
10. PDA/debug UI.
11. Construction and strategic AI expansion.

Do not jump directly to full gameplay systems before the mod loading, logging, and state foundations are reliable.

## MVP Scope

The first playable goal is a vertical slice, not the full vision.

The MVP should prove:

- a small set of territories can be owned and updated;
- resources can be stored, produced, consumed, and moved;
- a caravan can travel between territories as strategic state;
- hostile pressure can disrupt logistics;
- the player can inspect or influence the system through debug tools or UI.

Preferred first scenario:

```text
Rookie Village
nearby outpost
one resource point
one hostile faction
one supply route
one retaliation or ambush event
```

## Out Of Scope Until MVP Works

Do not prioritize:

- advanced diplomacy;
- espionage;
- dynamic governments;
- procedural quest systems;
- decorative settlement building;
- full civilian simulation;
- runtime navmesh rebuilding;
- engine forks;
- custom executables;
- renderer changes.

## Technical Architecture Rules

Prefer extending existing Anomaly/GAMMA systems over replacing them.

Use adapter layers for integration points such as:

- Warfare ownership;
- smart terrain ownership;
- ALife squads;
- inventory/resource conversion;
- PDA UI hooks;
- save/load callbacks.

Keep the strategic simulation lightweight:

- aggregate distant simulation;
- avoid large active NPC counts;
- avoid persistent object spam;
- run strategic logic periodically, not every frame;
- materialize physical gameplay only near the player or during explicit events.

## Data Rules

Use stable IDs for all strategic entities:

- `territory_id`;
- `faction_id`;
- `resource_id`;
- `building_id`;
- `caravan_id`;
- `route_id`;
- `event_id`.

Prefer config/data tables over hardcoded gameplay definitions.

Separate:

- static definitions;
- runtime state;
- save state;
- temporary caches.

Every persisted state format must include a schema/version field once save support exists.

## File Structure

Target project layout:

```text
E:\Zone Frontier
+-- gamedata\
|   +-- scripts\
|   +-- configs\
|   +-- ui\
|   +-- textures\
|   +-- meshes\
+-- docs\
+-- tools\
+-- debug\
+-- tests\
+-- AGENTS.md
+-- README.md
+-- .gitignore
```

Use `docs/` for design decisions and permanent notes.

Use `tools/` for repeatable local scripts such as deploy or validation.

Use `debug/` only for project-owned debugging helpers, not game-generated logs.

Use `tests/` for local logic checks where practical.

## Lua/Script Rules

Keep modules small and named with the `zf_` prefix where possible.

Prefer explicit module responsibilities, for example:

- `zf_main`;
- `zf_core`;
- `zf_state`;
- `zf_territory`;
- `zf_resources`;
- `zf_caravan`;
- `zf_debug`;
- `zf_save`;
- `zf_adapters_*`.

Avoid broad files that mix gameplay rules, persistence, UI, and integration hooks.

Add logging to new systems early.

Avoid expensive logic inside per-frame callbacks.

## Git Rules

Use Git for all project changes.

Default branch:

```text
main
```

Remote repository:

```text
https://github.com/lev-goryachev/zone-frontier
```

Keep commits focused and readable.

Before committing, check:

```text
git status --short
```

Do not commit generated logs, local environment files, build artifacts, or deployed MO2 copies.

## Documentation Rules

When a design decision changes project direction, document it.

Do not let docs become fantasy scope. Keep implementation docs tied to what we are about to build or have already validated.

Use Russian for collaborative planning if it is meant for the current development conversation.

Use English for technical file names, IDs, code symbols, and comments unless there is a strong reason not to.

## Testing And Verification

Every meaningful implementation step should have a verification path.

Examples:

- local logic script/test;
- deploy script dry run;
- game log check;
- visible MO2 mod structure;
- in-game debug command;
- save/load sanity check.

If a step cannot be tested yet, state what is missing and what will verify it later.

## Communication Rules

Be explicit about whether a change affects:

- repository source;
- deployed MO2 mod;
- GAMMA profile/config;
- Anomaly base files.

When proposing implementation, prefer the smallest useful next step.

When unsure about Anomaly/GAMMA internals, inspect local files first instead of guessing.
