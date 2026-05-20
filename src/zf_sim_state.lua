local util = zf_sim_util or require("zf_sim_util")

local M = {}
_G.zf_sim_state = M
local SCHEMA_VERSION = "0.1.0"

function M.new_world_state()
    return {
        schema_version = SCHEMA_VERSION,
        initialized = true,
        strategic_tick = 0,
        territories = {},
        factions = {},
        caravans = {},
        events = {},
        supply_routes = {},
        resource_definitions = {},
        faction_definitions = {},
        territory_definitions = {},
        last_event = "none",
        next_caravan_id = 1,
    }
end

function M.count_map_items(value)
    return util.count_map_items(value)
end

function M.active_caravan_count(state)
    local count = 0

    for _, caravan in pairs((state and state.caravans) or {}) do
        if caravan.state == "moving" then
            count = count + 1
        end
    end

    return count
end

return M
