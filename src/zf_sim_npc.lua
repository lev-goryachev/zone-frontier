local M = {}
_G.zf_sim_npc = M

M.SCHEMA_VERSION = "0.1.0"

local RANK_POWER = {
    novice = 1,
    trainee = 2,
    experienced = 3,
    professional = 4,
    veteran = 5,
    expert = 6,
    master = 7,
    legend = 8,
}

local DEFAULT_MORALE = 50

local function copy_list(value)
    local result = {}

    for index, item in ipairs(value or {}) do
        local copy = {}
        for key, item_value in pairs(item or {}) do
            copy[key] = item_value
        end
        result[index] = copy
    end

    return result
end

local function count_list(value)
    local count = 0

    for _ in ipairs(value or {}) do
        count = count + 1
    end

    return count
end

local function item_amount(item)
    return tonumber(item and (item.ammo_left or item.count)) or 1
end

local function rank_power(rank)
    if type(rank) == "number" then
        return math.max(1, math.floor(rank / 150))
    end

    return RANK_POWER[tostring(rank or "")] or 2
end

local function member_power(member)
    return rank_power(member and member.rank)
        + (tonumber(member and member.weapon_tier) or 0)
        + math.min(4, math.floor((tonumber(member and member.ammo_total) or 0) / 30))
        + math.min(2, tonumber(member and member.medical_total) or 0)
        + math.floor((tonumber(member and member.morale) or DEFAULT_MORALE) / 50)
end

local function weapon_tier(section, explicit_tier)
    if tonumber(explicit_tier) then
        return tonumber(explicit_tier)
    end

    local value = tostring(section or "")

    if value:find("svd", 1, true) or value:find("gauss", 1, true) or value:find("rpg", 1, true) then
        return 5
    end

    if value:find("ak", 1, true) or value:find("lr300", 1, true) or value:find("groza", 1, true) then
        return 4
    end

    if value:find("shotgun", 1, true) or value:find("bm16", 1, true) then
        return 3
    end

    if value:find("pm", 1, true) or value:find("hpsa", 1, true) or value:find("walther", 1, true) then
        return 2
    end

    if value:find("wpn_", 1, true) then
        return 2
    end

    return 0
end

local function recompute_profiles(entry)
    local ammo_profile = {}
    local medical_profile = {}
    local weapon_summary = {
        count = 0,
        best_tier = 0,
        primary = nil,
    }

    for _, item in ipairs(entry.inventory or {}) do
        local kind = item.kind
        local section = tostring(item.section or "unknown")

        if kind == "ammo" then
            ammo_profile[section] = (ammo_profile[section] or 0) + item_amount(item)
        elseif kind == "medical" then
            medical_profile[section] = (medical_profile[section] or 0) + item_amount(item)
        elseif kind == "weapon" then
            local tier = weapon_tier(section, item.weapon_tier)
            weapon_summary.count = weapon_summary.count + 1
            if tier > weapon_summary.best_tier then
                weapon_summary.best_tier = tier
                weapon_summary.primary = section
            end
        end
    end

    entry.ammo_profile = ammo_profile
    entry.medical_profile = medical_profile
    entry.weapon_summary = weapon_summary
end

function M.new_manifest_state()
    return {
        schema_version = M.SCHEMA_VERSION,
        next_seq = 1,
        npcs = {},
        engine_to_persistent = {},
        stats = {
            registered = 0,
            alive = 0,
            dead = 0,
            protected_skipped = 0,
        },
    }
end

function M.ensure_manifest_state(world_state)
    if world_state.zf_npc_manifest == nil then
        world_state.zf_npc_manifest = M.new_manifest_state()
    end

    local manifest = world_state.zf_npc_manifest
    manifest.schema_version = manifest.schema_version or M.SCHEMA_VERSION
    manifest.next_seq = tonumber(manifest.next_seq) or 1
    manifest.npcs = manifest.npcs or {}
    manifest.engine_to_persistent = manifest.engine_to_persistent or {}
    manifest.stats = manifest.stats or {}
    return manifest
end

function M.register_npc(manifest, data)
    if manifest == nil then
        error("register_npc requires manifest", 2)
    end

    if data == nil or data.engine_id == nil then
        error("register_npc requires data.engine_id", 2)
    end

    local engine_key = tostring(data.engine_id)
    local existing_id = manifest.engine_to_persistent[engine_key]
    local entry = existing_id and manifest.npcs[existing_id] or nil

    if entry == nil or entry.alive_state == "dead" then
        local persistent_id = "zf_npc_" .. tostring(manifest.next_seq)
        manifest.next_seq = manifest.next_seq + 1
        entry = {
            persistent_id = persistent_id,
            inventory = {},
            ammo_profile = {},
            medical_profile = {},
            weapon_summary = { count = 0, best_tier = 0, primary = nil },
            morale = DEFAULT_MORALE,
            alive_state = "alive",
            created_tick = data.tick or 0,
        }
        manifest.npcs[persistent_id] = entry
        manifest.engine_to_persistent[engine_key] = persistent_id
        manifest.stats.registered = (manifest.stats.registered or 0) + 1
    end

    entry.engine_id = data.engine_id
    entry.name = data.name or entry.name or "unknown"
    entry.section = data.section or entry.section or "unknown"
    entry.community = data.community or entry.community or "unknown"
    entry.rank = data.rank or entry.rank or "novice"
    entry.squad_id = data.squad_id or entry.squad_id
    entry.smart_id = data.smart_id or entry.smart_id
    entry.online = data.online == true
    entry.alive_state = data.alive_state or entry.alive_state or "alive"
    entry.last_seen_tick = data.tick or entry.last_seen_tick or 0
    entry.position = data.position or entry.position
    entry.money_snapshot = data.money_snapshot or entry.money_snapshot
    entry.morale = tonumber(data.morale) or entry.morale or DEFAULT_MORALE

    return entry
end

function M.mark_online(manifest, engine_id, tick)
    local entry = M.entry_for_engine_id(manifest, engine_id)
    if entry ~= nil then
        entry.online = true
        entry.last_seen_tick = tick or entry.last_seen_tick
    end
    return entry
end

function M.mark_offline(manifest, engine_id, tick)
    local entry = M.entry_for_engine_id(manifest, engine_id)
    if entry ~= nil then
        entry.online = false
        entry.last_seen_tick = tick or entry.last_seen_tick
    end
    return entry
end

function M.mark_dead(manifest, engine_id, tick)
    local entry = M.entry_for_engine_id(manifest, engine_id)
    if entry ~= nil then
        entry.alive_state = "dead"
        entry.online = false
        entry.dead_tick = tick or entry.dead_tick
        manifest.engine_to_persistent[tostring(engine_id)] = nil
    end
    return entry
end

function M.entry_for_engine_id(manifest, engine_id)
    if manifest == nil or engine_id == nil then
        return nil
    end

    local persistent_id = manifest.engine_to_persistent[tostring(engine_id)]
    return persistent_id and manifest.npcs[persistent_id] or nil
end

function M.merge_inventory(entry, items, tick)
    if entry == nil then
        error("merge_inventory requires entry", 2)
    end

    entry.inventory = copy_list(items or {})
    entry.inventory_count = count_list(entry.inventory)
    entry.last_inventory_tick = tick or entry.last_inventory_tick
    recompute_profiles(entry)
    return entry
end

function M.profile_total(profile)
    local total = 0

    for _, amount in pairs(profile or {}) do
        total = total + (tonumber(amount) or 0)
    end

    return total
end

function M.member_power(member)
    return member_power(member or {})
end

function M.group_power(members)
    local total = 0
    local count = 0

    for _, member in ipairs(members or {}) do
        total = total + member_power(member)
        count = count + 1
    end

    -- Outnumbering matters in X-Ray firefights: more bodies create more angles,
    -- suppression and target splitting even when each fighter is individually weaker.
    return total + math.floor(count * 1.5), count
end

function M.count_entries(manifest, state)
    local count = 0

    for _, entry in pairs((manifest and manifest.npcs) or {}) do
        if state == nil or entry.alive_state == state then
            count = count + 1
        end
    end

    return count
end

function M.evaluate_risk(input)
    local own = input and input.own or {}
    local enemy = input and input.enemy or {}
    local context = input and input.context or {}

    local own_individual_power = member_power(own)
    local enemy_individual_power = member_power(enemy)
        + (enemy.is_actor and 3 or 0)
        + (enemy.is_monster and 2 or 0)
    local own_group_size = math.max(1, tonumber(own.group_size or own.squad_size) or 1)
    local enemy_group_size = math.max(1, tonumber(enemy.group_size or enemy.squad_size) or 1)
    local own_group_power = tonumber(own.group_power) or (own_individual_power + math.floor(own_group_size * 1.5))
    local enemy_group_power = tonumber(enemy.group_power) or (enemy_individual_power + math.floor(enemy_group_size * 1.5))
    local enemy_count_pressure = math.max(0, enemy_group_size - own_group_size) * 2
    local pressure_adjusted_enemy_power = enemy_group_power + enemy_count_pressure

    local ammo_total = tonumber(own.ammo_total) or 0
    local medical_total = tonumber(own.medical_total) or 0
    local already_hit = context.already_hit == true
    local strategic_reason = context.strategic_reason == true
    local close_range = (tonumber(context.distance_sqr) or 999999) <= 900

    local avoid = false
    local reason = "hold"

    if already_hit or strategic_reason or close_range then
        avoid = false
        reason = already_hit and "already_hit" or (strategic_reason and "strategic_reason" or "close_range")
    elseif ammo_total <= 0 then
        avoid = true
        reason = "no_ammo"
    elseif ammo_total < 10 and medical_total <= 0 and pressure_adjusted_enemy_power >= own_group_power then
        avoid = true
        reason = "low_resources"
    elseif enemy_group_size >= own_group_size + 3 and pressure_adjusted_enemy_power >= own_group_power - 2 then
        avoid = true
        reason = "outnumbered"
    elseif pressure_adjusted_enemy_power >= own_group_power + 5 then
        avoid = true
        reason = "group_overmatched"
    end

    return {
        avoid = avoid,
        reason = reason,
        own_power = own_individual_power,
        enemy_power = enemy_individual_power,
        own_group_power = own_group_power,
        enemy_group_power = pressure_adjusted_enemy_power,
        own_group_size = own_group_size,
        enemy_group_size = enemy_group_size,
    }
end

return M
