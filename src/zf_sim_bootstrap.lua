local defs = zf_sim_defs or require("zf_sim_defs")
local util = zf_sim_util or require("zf_sim_util")

local M = {}
_G.zf_sim_bootstrap = M

local function copy_faction(definition)
    return {
        id = definition.id,
        display_name = definition.display_name,
        influence = 0,
        territories = {},
        resources = {},
        manpower = {
            rookies = 0,
            regulars = 0,
            veterans = 0,
            specialists = 0,
        },
        relations = {},
    }
end

local function copy_territory(definition)
    return {
        id = definition.id,
        display_name = definition.display_name,
        type = definition.type,
        owner = definition.owner,
        supply = definition.supply,
        security = definition.security,
        storage = util.copy_map(definition.storage),
        consumption = util.copy_map(definition.consumption),
        production = util.copy_map(definition.production),
    }
end

local function add_faction_territory(state, faction_id, territory_id)
    local faction = state.factions[faction_id]

    if faction == nil then
        return
    end

    for _, existing in ipairs(faction.territories) do
        if existing == territory_id then
            return
        end
    end

    table.insert(faction.territories, territory_id)
end

function M.init_state(state)
    state.resource_definitions = defs.resources
    state.faction_definitions = defs.factions
    state.territory_definitions = defs.territories
    state.supply_routes = defs.routes

    for id, definition in pairs(defs.factions) do
        if state.factions[id] == nil then
            state.factions[id] = copy_faction(definition)
        end
    end

    for id, definition in pairs(defs.territories) do
        if state.territories[id] == nil then
            state.territories[id] = copy_territory(definition)
        end

        add_faction_territory(state, definition.owner, id)
    end
end

return M
