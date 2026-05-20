local npc = require("zf_sim_npc")
local h = require("test_helpers")

local world = {}
local manifest = npc.ensure_manifest_state(world)

local entry = npc.register_npc(manifest, {
    engine_id = 42,
    name = "Test Stalker",
    section = "sim_default_stalker_0",
    community = "stalker",
    rank = "novice",
    squad_id = 7,
    online = false,
    tick = 10,
})

h.assert_eq(entry.persistent_id, "zf_npc_1", "first persistent id")
h.assert_eq(npc.entry_for_engine_id(manifest, 42).name, "Test Stalker", "engine binding resolves entry")

npc.merge_inventory(entry, {
    { item_id = 100, section = "wpn_ak74", kind = "weapon" },
    { item_id = 101, section = "ammo_5.45x39_fmj", kind = "ammo", ammo_left = 60 },
    { item_id = 102, section = "medkit", kind = "medical", count = 1 },
}, 11)

h.assert_eq(entry.inventory_count, 3, "inventory count")
h.assert_eq(entry.ammo_profile["ammo_5.45x39_fmj"], 60, "ammo profile total")
h.assert_eq(entry.medical_profile.medkit, 1, "medical profile total")
h.assert_eq(entry.weapon_summary.primary, "wpn_ak74", "primary weapon summary")

local risk = npc.evaluate_risk({
    own = {
        rank = "novice",
        weapon_tier = entry.weapon_summary.best_tier,
        ammo_total = npc.profile_total(entry.ammo_profile),
        medical_total = npc.profile_total(entry.medical_profile),
        squad_size = 1,
        morale = 50,
    },
    enemy = {
        rank = "master",
        weapon_tier = 5,
        squad_size = 3,
        is_actor = true,
    },
    context = {
        distance_sqr = 10000,
    },
})

h.assert_true(risk.avoid, "weak npc avoids overwhelming enemy")
h.assert_eq(risk.reason, "group_overmatched", "group overmatched reason")

local own_group_power, own_group_size = npc.group_power({
    { rank = "master", weapon_tier = 5, ammo_total = 90, medical_total = 1, morale = 50 },
    { rank = "master", weapon_tier = 5, ammo_total = 90, medical_total = 1, morale = 50 },
})
local enemy_group_power, enemy_group_size = npc.group_power({
    { rank = "novice", weapon_tier = 2, ammo_total = 30, medical_total = 0, morale = 50 },
    { rank = "novice", weapon_tier = 2, ammo_total = 30, medical_total = 0, morale = 50 },
    { rank = "novice", weapon_tier = 2, ammo_total = 30, medical_total = 0, morale = 50 },
    { rank = "novice", weapon_tier = 2, ammo_total = 30, medical_total = 0, morale = 50 },
    { rank = "novice", weapon_tier = 2, ammo_total = 30, medical_total = 0, morale = 50 },
})

risk = npc.evaluate_risk({
    own = {
        rank = "master",
        weapon_tier = 5,
        ammo_total = 90,
        medical_total = 1,
        group_power = own_group_power,
        group_size = own_group_size,
        morale = 50,
    },
    enemy = {
        rank = "novice",
        weapon_tier = 2,
        ammo_total = 30,
        group_power = enemy_group_power,
        group_size = enemy_group_size,
    },
    context = {
        distance_sqr = 10000,
    },
})

h.assert_true(risk.avoid, "small elite group avoids being overwhelmed by numbers")
h.assert_eq(risk.reason, "outnumbered", "outnumbered reason")
h.assert_eq(risk.own_group_size, 2, "own group size")
h.assert_eq(risk.enemy_group_size, 5, "enemy group size")

npc.mark_dead(manifest, 42, 12)
h.assert_eq(entry.alive_state, "dead", "dead state recorded")
h.assert_true(npc.entry_for_engine_id(manifest, 42) == nil, "dead binding released")

local replacement = npc.register_npc(manifest, {
    engine_id = 42,
    name = "Replacement Stalker",
    section = "sim_default_stalker_1",
})

h.assert_eq(replacement.persistent_id, "zf_npc_2", "reused engine id receives new identity")
