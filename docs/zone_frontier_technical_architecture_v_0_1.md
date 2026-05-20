# Zone Frontier — Technical Architecture v0.1

## Technical Design Document

---

# Document Purpose

This document defines the technical architecture direction for Zone Frontier.

The goal is to establish:

- system boundaries;
- integration strategy;
- simulation architecture;
- persistence model;
- performance constraints;
- data flow;
- technical priorities.

The document intentionally focuses on:

- scalability;
- maintainability;
- compatibility with GAMMA 0.9.5;
- minimal engine invasiveness.

---

# Core Technical Philosophy

Zone Frontier is NOT:

- a standalone game;
- a custom engine fork;
- a total replacement of ALife.

Zone Frontier IS:

- a strategic simulation layer;
- a systems extension;
- a macro gameplay framework;
- a MO2-compatible GAMMA mod.

The project should:

- reuse existing GAMMA systems whenever possible;
- avoid deep engine rewrites;
- prioritize data-driven architecture;
- prioritize lightweight simulation.

---

# High-Level Architecture

## Layer Model

```text
┌─────────────────────────────┐
│        GAMMA Systems        │
│ combat / survival / ALife   │
└──────────────┬──────────────┘
               │
┌──────────────▼──────────────┐
│      Zone Frontier Core     │
│ economy / territory / AI    │
└──────────────┬──────────────┘
               │
┌──────────────▼──────────────┐
│    Frontier Gameplay Layer  │
│ caravans / politics / UI    │
└─────────────────────────────┘
```

---

# Integration Philosophy

## Core Rule

Zone Frontier should EXTEND existing systems rather than replace them.

The mod should:

- hook into Warfare;
- reuse ALife squads;
- reuse smart terrains;
- reuse GAMMA inventory systems;
- reuse existing NPCs and jobs;
- reuse existing item definitions.

---

# Explicit Non-Goals

The project should avoid:

- replacing the renderer;
- replacing ALife entirely;
- runtime navmesh generation;
- custom executables;
- hard engine forks;
- invasive binary patches.

---

# Mod Structure

## Planned Layout

```text
Zone Frontier/
├── gamedata/
│   ├── scripts/
│   ├── configs/
│   ├── ui/
│   ├── textures/
│   └── meshes/
├── docs/
├── tools/
├── debug/
└── tests/
```

---

# Recommended Internal Modules

## 1. Territory System

Responsible for:

- territory ownership;
- territory metadata;
- strategic value;
- local status;
- resource classification.

Primary entities:

- Resource Points;
- Outposts.

---

## 2. Resource System

Responsible for:

- production;
- consumption;
- storage;
- transfer;
- processing.

The resource system should remain:

- lightweight;
- aggregate-based;
- event-driven.

---

## 3. Logistics System

Responsible for:

- caravan creation;
- route planning;
- escort logic;
- transfer execution;
- ambush handling.

---

## 4. Strategic AI System

Responsible for:

- faction expansion;
- target evaluation;
- territory pressure;
- attack planning;
- defensive prioritization.

---

## 5. Construction System

Responsible for:

- placement zones;
- build objects;
- placement validation;
- build timing;
- local defensive logic.

---

## 6. Population System

Responsible for:

- manpower tracking;
- specialist roles;
- morale state;
- recruitment;
- faction migration.

---

## 7. Strategic UI Layer

Responsible for:

- PDA Frontier screen;
- strategic map;
- alerts;
- logistics visualization;
- territory state.

---

# Territory Architecture

## Territory Types

### Resource Point

Strategic locations with:

- resource production;
- industrial capability;
- high strategic value.

---

### Outpost

Smaller tactical support nodes with:

- route control;
- logistics support;
- local defense.

---

# Territory State Model

Example:

```json
{
  "id": "garbage_hangar",
  "owner": "duty",
  "type": "resource_point",
  "resources": {
    "scrap_metal": 1200
  },
  "supply": 0.74,
  "security": 0.61,
  "population": 18,
  "storage": {
    "ammo": 400,
    "food": 90
  }
}
```

---

# Resource Architecture

## Resource Philosophy

Resources are hybrid:

- strategic quantities;
- represented through physical inventory.

This avoids:

- excessive simulation cost;
- massive entity counts;
- savegame bloat.

---

# Resource Categories

## Raw Resources

Examples:

- Scrap Metal;
- Fuel;
- Chemicals;
- Organic Material.

---

## Processed Materials

Examples:

- Processed Metal;
- Casings;
- Industrial Components.

---

## Consumables

Examples:

- Food;
- Water;
- Medicine;
- Ammunition.

---

# Resource Flow

```text
Extraction
    ↓
Transport
    ↓
Storage
    ↓
Processing
    ↓
Distribution
    ↓
Consumption
```

---

# Logistics Architecture

## Caravan Model

Caravans are lightweight strategic entities.

A caravan stores:

```json
{
  "origin": "cordon_base",
  "destination": "garbage_hangar",
  "cargo": {
    "food": 80,
    "ammo": 200
  },
  "escort_strength": 14,
  "state": "moving"
}
```

---

# Caravan States

Possible states:

- preparing;
- moving;
- delayed;
- ambushed;
- retreating;
- destroyed;
- arrived.

---

# Caravan Simulation

Simulation should remain:

- mostly aggregate;
- event-driven;
- low-frequency.

The game should avoid:

- continuously simulating large moving groups.

---

# Strategic AI Architecture

## AI Responsibilities

AI factions evaluate:

- territory value;
- local strength;
- supply state;
- nearby threats;
- expansion opportunities.

---

# AI Strategic Goals

AI attempts to:

- secure supply;
- maintain territory chains;
- defend production;
- avoid overextension;
- attack weak targets.

---

# AI Simulation Frequency

Strategic simulation should run:

- periodically;
- not every frame.

Recommended:

- strategic tick every several in-game hours.

---

# Construction Architecture

## Construction Philosophy

Construction should remain:

- lightweight;
- modular;
- tactical.

The system should avoid:

- massive persistent object counts;
- dynamic geometry rewriting.

---

# Placement Model

Construction is limited to:

- predefined build zones;
- predefined placement regions.

This avoids:

- runtime navigation rebuild complexity.

---

# Construction Categories

## Defensive

Examples:

- barricades;
- walls;
- MG nests.

---

## Utility

Examples:

- storage;
- generators;
- trader stations;
- workshops.

---

## Logistics

Examples:

- caravan storage;
- checkpoint support;
- resupply hubs.

---

# Build Process

Construction should require:

- materials;
- manpower;
- time.

NPC workers should:

- physically move to construction sites;
- spend time building;
- expose vulnerability during construction.

---

# Navigation Strategy

## Major Constraint

X-Ray navigation is static.

Zone Frontier should avoid:

- full runtime navmesh rebuilding.

---

# Proposed Solution

Use:

- predefined build zones;
- local navigation overrides;
- lightweight obstacle logic.

The system should:

- preserve vanilla ALife globally;
- override navigation locally near constructions.

---

# Population Architecture

## Hybrid Simulation

Population exists in two modes:

### Active

When near player:

- fully rendered NPCs;
- full AI;
- physical entities.

---

### Abstracted

When far away:

- aggregate statistics;
- lightweight simulation.

---

# Population State

Example:

```json
{
  "population": 23,
  "fighters": 9,
  "workers": 6,
  "specialists": 3,
  "unassigned": 5,
  "morale": 0.67
}
```

---

# Save Architecture

## Core Rule

Do NOT serialize every object individually.

Serialize:

- strategic state;
- construction definitions;
- logistics state;
- territory state.

---

# Example

```json
{
  "territory": "garbage_outpost",
  "buildings": [
    "wall_a",
    "storage_lv1",
    "mg_nest"
  ]
}
```

---

# Performance Strategy

## Core Constraints

The project must:

- run on weak hardware;
- avoid save bloat;
- avoid excessive active AI;
- avoid large entity counts.

---

# Performance Rules

## Rule 1

Distant simulation must remain aggregate-based.

---

## Rule 2

Avoid persistent active objects whenever possible.

---

## Rule 3

Use event-driven simulation.

---

## Rule 4

Reuse ALife systems instead of duplicating them.

---

## Rule 5

Limit active construction complexity.

---

# UI Architecture

## PDA Frontier Screen

Planned sections:

- Territory Map;
- Logistics;
- Resource Overview;
- Alerts;
- Faction Status;
- Caravan Routes.

---

# Debug Architecture

The project requires:

- debug overlays;
- strategic state inspector;
- caravan visualizer;
- territory ownership viewer;
- simulation logs.

---

# Telemetry & Logging

Recommended logging:

- territory captures;
- caravan losses;
- AI strategic decisions;
- resource shortages;
- population changes.

---

# Compatibility Strategy

## Core Rule

Zone Frontier should:

- override minimal GAMMA files;
- avoid direct edits whenever possible;
- prefer hooks and extensions.

---

# Recommended Hook Pattern

Preferred:

```lua
local old_update = update

function update(...)
    old_update(...)
    frontier_update(...)
end
```

Avoid:

- replacing entire vanilla systems.

---

# Data Strategy

The project should prioritize:

- config-driven systems;
- data tables;
- minimal hardcoding.

---

# Recommended Data Types

## Static Configs

For:

- buildings;
- resources;
- territory definitions;
- faction templates.

---

## Runtime State

For:

- ownership;
- logistics;
- production;
- active strategic simulation.

---

# MVP Technical Priorities

## Highest Priority

- territory ownership;
- logistics;
- caravans;
- strategic persistence;
- PDA UI;
- strategic AI.

---

## Medium Priority

- local construction logic;
- population systems;
- morale systems;
- advanced AI planning.

---

## Low Priority

- advanced politics;
- espionage;
- advanced diplomacy;
- decorative systems.

---

# Initial Technical Milestones

## Milestone 1

Strategic territory ownership layer.

---

## Milestone 2

Resource storage and transfer.

---

## Milestone 3

Caravan simulation.

---

## Milestone 4

PDA Frontier interface.

---

## Milestone 5

Construction placement and defense.

---

## Milestone 6

Strategic AI attacks and expansion.

---

# Development Methodology

The project follows:

- agile iteration;
- docs-first development;
- system prototyping;
- manual gameplay testing;
- incremental integration.

The architecture should prioritize:

- maintainability;
- scalability;
- replayability;
- emergent behavior.

