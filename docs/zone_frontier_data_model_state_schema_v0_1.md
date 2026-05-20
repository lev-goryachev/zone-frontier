# Zone Frontier — Data Model & State Schema v0.1

## Data Model & Runtime State Design

---

# Document Purpose

This document defines the first internal data model for Zone Frontier.

The goal is to describe:

- core entities;
- persistent state;
- runtime state;
- references between systems;
- serialization strategy;
- update dependencies;
- aggregate vs active simulation;
- data-driven configuration approach.

This document acts as the first draft of the internal database schema for the mod.

---

# Core Design Principles

## 1. Data-Driven First

Most gameplay rules should be stored in data tables/configs rather than hardcoded logic.

This applies to:

- territories;
- resources;
- buildings;
- factions;
- production chains;
- caravan templates;
- AI weights;
- event definitions.

---

## 2. Hybrid Physical/Abstract Model

Zone Frontier should not simulate every item and NPC as a full active entity at all times.

Instead:

- near-player objects may exist physically;
- distant objects are aggregated into strategic state.

---

## 3. Persistent Strategic State

The mod must persist:

- ownership;
- resource stockpiles;
- construction state;
- population;
- faction relations;
- caravan state;
- event history.

---

## 4. Low Save Bloat

The mod should avoid saving thousands of small individual objects.

Instead, it should save:

- compact state blobs;
- IDs;
- quantities;
- structural definitions;
- high-level simulation state.

---

# Entity Overview

Core entities:

```text
WorldState
├── Factions
├── Territories
│   ├── Resource Points
│   └── Outposts
├── Resources
├── Buildings
├── Population Groups
├── Caravans
├── Supply Routes
├── Events
└── Diplomacy State
```

---

# 1. World State

## Purpose

Global container for all Zone Frontier strategic data.

## Example

```json
{
  "version": "0.1.0",
  "game_time": 123456,
  "strategic_tick": 42,
  "factions": {},
  "territories": {},
  "caravans": {},
  "events": []
}
```

## Fields

| Field | Type | Description |
|---|---:|---|
| version | string | Zone Frontier save schema version |
| game_time | number | Current in-game timestamp |
| strategic_tick | number | Current strategic tick counter |
| factions | map | Runtime faction states |
| territories | map | Runtime territory states |
| caravans | map | Active caravan states |
| events | list | Recent strategic events |

---

# 2. Territory Definition

## Purpose

Static config describing a capturable strategic location.

Territory definitions should be data-driven.

## Example

```json
{
  "id": "garbage_hangar",
  "display_name": "Garbage Hangar",
  "level": "l02_garbage",
  "smart_terrain": "gar_smart_terrain_3_5",
  "type": "resource_point",
  "base_owner": "bandit",
  "resource_outputs": ["scrap_metal"],
  "build_zones": ["garbage_hangar_main"],
  "storage_capacity": 3000,
  "strategic_value": 0.85
}
```

## Fields

| Field | Type | Description |
|---|---:|---|
| id | string | Stable territory ID |
| display_name | string | UI name |
| level | string | Game level identifier |
| smart_terrain | string | Linked Anomaly/GAMMA smart terrain |
| type | enum | resource_point / outpost |
| base_owner | faction_id | Starting owner |
| resource_outputs | list | Resources produced here |
| build_zones | list | Allowed construction zones |
| storage_capacity | number | Max abstract storage |
| strategic_value | float | AI value weight |

---

# 3. Territory Runtime State

## Purpose

Mutable state of a territory during a campaign.

## Example

```json
{
  "id": "garbage_hangar",
  "owner": "loners",
  "security": 0.62,
  "supply": 0.74,
  "morale": 0.58,
  "threat": 0.31,
  "population": {
    "fighters": 9,
    "workers": 6,
    "specialists": {
      "medic": 1,
      "technician": 1,
      "trader": 1
    },
    "unassigned": 3
  },
  "storage": {
    "food": 120,
    "water": 90,
    "ammo_basic": 400,
    "scrap_metal": 700
  },
  "buildings": [
    {
      "id": "building_001",
      "type": "storage_lv1",
      "state": "completed"
    }
  ],
  "active_events": []
}
```

## Fields

| Field | Type | Description |
|---|---:|---|
| id | territory_id | Linked territory definition |
| owner | faction_id | Current controlling faction |
| security | float | Defensive strength 0–1 |
| supply | float | Supply quality 0–1 |
| morale | float | Local morale 0–1 |
| threat | float | Local threat 0–1 |
| population | object | Population distribution |
| storage | map | Stored resources |
| buildings | list | Built structures |
| active_events | list | Current local events |

---

# 4. Faction Definition

## Purpose

Static faction metadata and strategic personality.

## Example

```json
{
  "id": "duty",
  "display_name": "Duty",
  "base_aggression": 0.65,
  "trade_preference": 0.35,
  "expansion_preference": 0.75,
  "resource_priorities": {
    "ammo_basic": 0.9,
    "processed_metal": 0.8,
    "food": 0.5
  }
}
```

## Fields

| Field | Type | Description |
|---|---:|---|
| id | string | Stable faction ID |
| display_name | string | UI name |
| base_aggression | float | Attack tendency |
| trade_preference | float | Trade vs raid tendency |
| expansion_preference | float | Expansion tendency |
| resource_priorities | map | Resource AI weights |

---

# 5. Faction Runtime State

## Purpose

Mutable strategic state for each faction.

## Example

```json
{
  "id": "duty",
  "influence": 0.42,
  "territories": ["rostok_bar", "garbage_checkpoint"],
  "resources": {
    "money": 25000,
    "food": 600,
    "ammo_basic": 1200
  },
  "manpower": {
    "rookies": 18,
    "regulars": 24,
    "veterans": 7,
    "specialists": 4
  },
  "relations": {
    "freedom": "hostile",
    "loners": "neutral",
    "ecologists": "allied"
  }
}
```

## Fields

| Field | Type | Description |
|---|---:|---|
| id | faction_id | Linked faction definition |
| influence | float | Global faction influence |
| territories | list | Controlled territory IDs |
| resources | map | Global reserves |
| manpower | object | Abstract available personnel |
| relations | map | Diplomatic relationships |

---

# 6. Resource Definition

## Purpose

Static config for resource types.

## Example

```json
{
  "id": "scrap_metal",
  "display_name": "Scrap Metal",
  "category": "raw",
  "weight_per_unit": 0.25,
  "base_value": 4,
  "physical_item": "zf_scrap_metal"
}
```

## Fields

| Field | Type | Description |
|---|---:|---|
| id | string | Resource ID |
| display_name | string | UI name |
| category | enum | raw / processed / consumable / strategic |
| weight_per_unit | number | Weight for logistics |
| base_value | number | Economy baseline |
| physical_item | item_id | Optional GAMMA item link |

---

# 7. Production Chain Definition

## Purpose

Defines how resources are converted.

## Example

```json
{
  "id": "scrap_to_processed_metal",
  "input": {
    "scrap_metal": 100,
    "fuel": 5
  },
  "output": {
    "processed_metal": 40
  },
  "required_building": "workshop_lv1",
  "required_power": true,
  "duration_ticks": 2
}
```

## Fields

| Field | Type | Description |
|---|---:|---|
| id | string | Production chain ID |
| input | map | Required resources |
| output | map | Produced resources |
| required_building | building_type | Required structure |
| required_power | bool | Needs electricity |
| duration_ticks | number | Strategic ticks required |

---

# 8. Building Definition

## Purpose

Static data for buildable structures.

## Example

```json
{
  "id": "mg_nest_lv1",
  "display_name": "Machinegun Nest",
  "category": "defense",
  "build_cost": {
    "processed_metal": 80,
    "ammo_basic": 200
  },
  "build_time_ticks": 2,
  "requires_worker": true,
  "effects": {
    "security": 0.15
  }
}
```

## Fields

| Field | Type | Description |
|---|---:|---|
| id | string | Building type ID |
| display_name | string | UI name |
| category | enum | defense / utility / logistics / production |
| build_cost | map | Required resources |
| build_time_ticks | number | Build duration |
| requires_worker | bool | Requires NPC worker |
| effects | map | Territory modifiers |

---

# 9. Building Runtime State

## Purpose

Mutable state of a specific constructed object.

## Example

```json
{
  "id": "building_001",
  "type": "mg_nest_lv1",
  "territory": "garbage_hangar",
  "state": "building",
  "progress": 0.5,
  "assigned_worker": "npc_abstract_001",
  "position": {
    "build_zone": "garbage_hangar_main",
    "slot": "defense_slot_03"
  }
}
```

## Building States

```text
planned
→ assigned
→ building
→ completed
→ damaged
→ disabled
→ dismantled
```

---

# 10. Caravan Runtime State

## Purpose

Strategic logistics entity.

## Example

```json
{
  "id": "caravan_001",
  "owner": "loners",
  "origin": "rookie_village",
  "destination": "garbage_hangar",
  "route": ["rookie_village", "cordon_checkpoint", "garbage_hangar"],
  "cargo": {
    "food": 80,
    "ammo_basic": 200
  },
  "escort_strength": 14,
  "visibility": 0.42,
  "progress": 0.35,
  "state": "moving"
}
```

## Caravan States

```text
preparing
moving
delayed
ambushed
retreating
arrived
destroyed
```

---

# 11. Supply Route Definition

## Purpose

Persistent route between territories.

## Example

```json
{
  "id": "route_cordon_to_garbage",
  "origin": "rookie_village",
  "destination": "garbage_hangar",
  "nodes": ["rookie_village", "cordon_checkpoint", "garbage_hangar"],
  "base_danger": 0.35,
  "travel_ticks": 3
}
```

## Fields

| Field | Type | Description |
|---|---:|---|
| id | string | Route ID |
| origin | territory_id | Start territory |
| destination | territory_id | End territory |
| nodes | list | Territory chain |
| base_danger | float | Base ambush risk |
| travel_ticks | number | Travel duration |

---

# 12. Population Group State

## Purpose

Tracks abstracted population at a territory.

## Example

```json
{
  "fighters": {
    "rookies": 4,
    "regulars": 3,
    "veterans": 1
  },
  "workers": 6,
  "specialists": {
    "medic": 1,
    "technician": 1
  },
  "unassigned": 2
}
```

## Population Rules

Population can be:

- consumed by combat;
- transferred;
- promoted;
- demoralized;
- lost to desertion;
- abstracted when far away;
- materialized near player.

---

# 13. Event State

## Purpose

Tracks dynamic strategic events.

## Example

```json
{
  "id": "event_001",
  "type": "caravan_ambush",
  "location": "cordon_checkpoint",
  "participants": ["loners", "bandits"],
  "state": "active",
  "created_tick": 42,
  "expires_tick": 44
}
```

## Event Types

Initial MVP event types:

- territory_attack;
- caravan_ambush;
- mutant_raid;
- supply_shortage;
- emission_disruption;
- construction_interrupted.

---

# 14. Diplomacy State

## Purpose

Tracks faction relationship state.

## Example

```json
{
  "faction_a": "duty",
  "faction_b": "freedom",
  "state": "hostile",
  "trust": 0.12,
  "trade_score": 0.05,
  "recent_incidents": ["caravan_raid"]
}
```

## Relationship States

```text
allied
neutral
hostile
```

---

# 15. Runtime vs Save State

## Runtime State

Runtime-only data may include:

- cached route danger;
- temporary AI scores;
- UI cache;
- active local NPC handles;
- short-term combat calculations.

Runtime state does not need long-term persistence.

---

## Save State

Save state must include:

- ownership;
- storage;
- buildings;
- caravans;
- faction resources;
- relations;
- event history;
- population state.

---

# 16. Active vs Abstract Entities

## Active Entity

Exists physically in game world.

Used for:

- nearby NPCs;
- visible caravans;
- constructed objects near player;
- local combat.

---

## Abstract Entity

Exists only as strategic state.

Used for:

- distant population;
- distant caravans;
- distant attacks;
- global production;
- logistics calculations.

---

# 17. Materialization Rules

When player approaches a territory:

```text
Abstract state → Active local representation
```

Examples:

- population spawns as NPCs;
- buildings appear physically;
- storage becomes accessible;
- local events materialize.

When player leaves:

```text
Active local representation → Abstract state
```

Examples:

- NPCs are aggregated;
- building damage is saved;
- local storage is synced;
- active combat resolves or continues abstractly.

---

# 18. ID Strategy

All major entities require stable IDs.

## ID Types

```text
territory_id
faction_id
resource_id
building_id
caravan_id
event_id
route_id
```

## Rules

- IDs must be stable across versions when possible.
- Runtime IDs should be generated with prefixes.
- Static config IDs should be human-readable.
- Save migration must account for renamed IDs.

---

# 19. Update Dependencies

## Territory Update Depends On

- owner faction;
- population;
- storage;
- buildings;
- supply routes;
- active events.

---

## Resource Update Depends On

- production chains;
- available buildings;
- fuel;
- power;
- workers;
- morale.

---

## Caravan Update Depends On

- route danger;
- escort strength;
- cargo weight;
- enemy territory;
- emission state.

---

## AI Update Depends On

- faction goals;
- resource shortages;
- nearby weak targets;
- current wars;
- supply stability.

---

# 20. Serialization Strategy

## Preferred Format

Use a compact structured format supported by the mod environment.

Candidates:

- Lua tables;
- LTX-style config;
- JSON-like serialization if available.

## Save Frequency

Strategic state should be saved:

- on normal game save;
- after strategic tick;
- after major state changes;
- before/after territory capture.

---

# 21. Schema Versioning

Every save state should include:

```json
{
  "schema_version": "0.1.0"
}
```

This allows future migration.

---

# 22. Debug Data Requirements

Debug UI should expose:

- territory state;
- faction state;
- resource storage;
- active caravans;
- AI scores;
- event list;
- last strategic tick log.

---

# 23. MVP Minimal Schema

The minimum schema required for first playable:

```text
WorldState
FactionState
TerritoryDefinition
TerritoryState
ResourceDefinition
BuildingDefinition
BuildingState
CaravanState
SupplyRouteDefinition
EventState
```

Deferred:

```text
Deep morale state
Spy state
Advanced diplomacy
Individual NPC biographies
Advanced market model
```

---

# 24. Open Design Questions

## Population Source

How exactly do new people enter the Zone?

Possible models:

- neutral wanderers;
- faction recruitment pool;
- refugee events;
- paid mercenary contracts;
- scripted migration waves.

---

## Resource Physicality

How far should resources remain physical?

Options:

1. Fully physical items.
2. Fully abstract quantities.
3. Hybrid strategic quantities with physical item conversion.

Current direction:

```text
Hybrid model
```

---

## Building Placement

Should building placement use:

1. free placement inside build zones;
2. predefined slots;
3. hybrid free placement with snapped functional anchors?

Current direction:

```text
Hybrid model
```

---

## Warfare Integration

Should Zone Frontier reuse vanilla/GAMMA Warfare ownership directly?

Current direction:

```text
Prefer reuse, but isolate through adapter layer.
```

---

# 25. Summary

Zone Frontier’s data model should behave like a lightweight strategy game database running inside GAMMA.

The system should simulate:

- territories;
- resources;
- factions;
- logistics;
- population;
- construction;
- conflict.

The key architectural goal is:

> Save compact strategic state, materialize physical gameplay only when needed.
