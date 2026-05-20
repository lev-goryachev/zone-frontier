# Zone Frontier — PRD MVP v0.1

## Product Requirements Document

---

# Document Purpose

This document defines the first playable MVP (Minimum Viable Product) for Zone Frontier.

The purpose of the MVP is NOT to implement the full strategic vision.

The purpose is to validate the following assumptions:

1. Strategic territory gameplay is fun inside GAMMA.
2. Logistics-driven gameplay creates emergent stories.
3. Resource ownership meaningfully changes player behavior.
4. Smart terrain control can support macro gameplay.
5. Construction can reinforce strategic gameplay without overwhelming complexity.

---

# MVP Philosophy

The MVP must:

- feel playable;
- create emergent situations;
- generate strategic decision-making;
- remain technically realistic;
- avoid massive engine rewrites;
- remain compatible with GAMMA 0.9.5.

The MVP is NOT intended to:

- fully simulate civilization;
- provide full politics systems;
- provide complete construction systems;
- implement all long-term design goals.

---

# MVP Core Experience

## Player Fantasy

The player controls a small faction presence attempting to:

- secure territory;
- establish supply chains;
- defend infrastructure;
- develop production capability;
- survive against hostile factions and the Zone itself.

The player should experience:

- logistical pressure;
- resource scarcity;
- territorial tension;
- strategic growth;
- emergent conflict.

---

# MVP Scope

## Included Systems

### 1. Territory Ownership

Smart terrains become:

- Resource Points;
- Outposts.

Each point has:

- owner faction;
- strategic value;
- local storage;
- local defense value;
- supply state.

---

### 2. Resource System

Initial MVP resources:

- Food;
- Water;
- Fuel;
- Scrap Metal;
- Processed Metal;
- Ammunition;
- Medicine.

Resources exist as:

- stored inventory;
- transported caravan cargo.

---

### 3. Logistics & Caravans

Factions can:

- create supply routes;
- send caravans;
- escort caravans;
- intercept enemy caravans.

Caravans:

- move between owned territories;
- carry physical resources;
- can be attacked;
- can be destroyed;
- can be delayed by emissions or combat.

---

### 4. Basic Strategic Economy

Settlements consume:

- food;
- water;
- medicine;
- ammunition.

Resource Points produce:

- specific strategic resources.

Example:

- Garbage → Scrap Metal;
- Industrial Area → Fuel;
- Agricultural Area → Food.

---

### 5. Basic Construction

Players can place:

- storage crates;
- barricades;
- walls;
- generator stations;
- trader stations;
- medic stations;
- technician stations;
- machinegun nests.

Construction is:

- restricted to predefined zones;
- tactical;
- utility-focused.

---

### 6. Strategic AI

AI factions:

- expand;
- defend territory;
- attack weakened targets;
- react to supply pressure;
- attempt to maintain logistics.

AI should create believable strategic pressure.

---

### 7. Dynamic Events

The MVP supports:

- caravan ambushes;
- territory attacks;
- mutant raids;
- supply shortages;
- emission-related disruptions.

---

### 8. Strategic PDA Interface

New PDA section:

# Frontier

Includes:

- territory map;
- supply overview;
- faction ownership;
- caravan tracking;
- alerts;
- settlement status.

---

# Explicitly Out Of Scope

The following systems are intentionally excluded from MVP:

- advanced diplomacy;
- espionage systems;
- spy mechanics;
- advanced morale simulation;
- civilian simulation;
- advanced politics;
- dynamic governments;
- runtime navmesh rebuilding;
- advanced building customization;
- decorative settlement systems;
- custom faction creation;
- advanced AI personalities;
- procedural quests;
- advanced economy simulation;
- production chains beyond simple refinement.

---

# Player Progression Loop

## Early Loop

1. Secure local territory.
2. Build storage and defense.
3. Establish first caravan.
4. Maintain supply.
5. Defend against attacks.
6. Expand influence.

---

## Mid Loop

1. Capture strategic resource points.
2. Develop production capability.
3. Intercept enemy logistics.
4. Strengthen infrastructure.
5. Coordinate multi-point logistics.
6. Defend growing territory.

---

## Late MVP Loop

1. Control multiple strategic territories.
2. Maintain stable logistics.
3. Conduct strategic offensives.
4. Defend against large-scale attacks.
5. Economically pressure enemy factions.

---

# Territory Classification

## Resource Point

Characteristics:

- produces strategic resource;
- high strategic value;
- worth defending heavily;
- supports advanced infrastructure.

Examples:

- factories;
- industrial hangars;
- labs;
- processing facilities.

---

## Outpost

Characteristics:

- logistics support;
- route protection;
- local defense;
- caravan support.

Examples:

- checkpoints;
- camps;
- ruins;
- fortified firesites.

---

# Resource Philosophy

Resources are intentionally physical and grounded.

The player should feel:

- transport weight;
- scarcity;
- supply pressure;
- production limitations.

The economy should encourage:

- specialization;
- trade;
- territorial conflict.

---

# Construction Philosophy

Construction exists to:

- improve survivability;
- increase efficiency;
- support logistics;
- strengthen defense.

Construction does NOT exist primarily for decoration.

Buildings are lightweight gameplay objects.

The MVP prioritizes:

- function;
- readability;
- tactical value.

---

# Combat Philosophy

Direct warfare is intentionally expensive.

The game should encourage:

- attrition;
- logistics attacks;
- strategic isolation;
- resource denial;
- economic warfare.

Frontal assaults should be risky.

Human losses should matter.

---

# Failure States

The player can lose strategically through:

- supply collapse;
- territorial isolation;
- manpower exhaustion;
- economic collapse;
- faction destruction.

The game should avoid hard game-over screens.

Instead:

- the world continues evolving;
- the player becomes increasingly marginalized.

---

# Technical Constraints

## Platform

Target platform:

- S.T.A.L.K.E.R. GAMMA 0.9.5

---

## Technical Rules

The MVP:

- must remain MO2-compatible;
- must not require a custom executable;
- must avoid engine forks;
- must prioritize performance on weak hardware.

---

## Simulation Rules

Simulation must remain lightweight.

The MVP should:

- aggregate distant simulation;
- avoid large active NPC counts;
- minimize persistent entities;
- reuse ALife systems whenever possible.

---

## AI Navigation

The MVP should:

- avoid runtime navmesh rebuilding;
- rely on predefined construction zones;
- use local lightweight navigation overrides where needed.

---

# MVP Success Criteria

The MVP is considered successful if players can:

1. Capture and defend territory.
2. Build meaningful infrastructure.
3. Create functioning supply lines.
4. Experience dynamic faction pressure.
5. Encounter emergent strategic situations.
6. Feel long-term progression beyond vanilla GAMMA.

---

# Desired Emergent Scenarios

Examples of successful gameplay stories:

- A caravan survives an emission by assaulting a nearby enemy outpost.
- A faction collapses due to fuel shortages.
- A player wins through economic isolation instead of direct war.
- Mutant attacks destabilize a strategic supply corridor.
- A heavily defended outpost becomes a regional power center.

---

# MVP Priorities

## Highest Priority

- Territory ownership;
- logistics;
- caravans;
- strategic resources;
- faction pressure;
- basic construction;
- strategic UI.

---

## Medium Priority

- advanced AI behavior;
- local NPC jobs;
- expanded production chains;
- dynamic settlement upgrades.

---

## Low Priority

- decorative systems;
- advanced diplomacy;
- advanced politics;
- advanced espionage;
- deep social simulation.

---

# First Playable Vertical Slice

## Goal

Demonstrate a complete strategic gameplay loop inside one region.

---

## Initial Playable Scenario

Location cluster:

- Rookie Village;
- nearby outpost;
- one resource point;
- one hostile faction.

Gameplay:

1. Secure local outpost.
2. Build storage and generator.
3. Start supply route.
4. Defend caravan.
5. Capture nearby resource point.
6. Survive first retaliation attack.

---

# Development Philosophy

Development follows:

- agile iteration;
- docs-first development;
- rapid prototyping;
- manual testing;
- system-first design.

The project prioritizes:

- systemic gameplay;
- emergent stories;
- replayability;
- strategic depth.

