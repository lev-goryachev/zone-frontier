local util = zf_sim_util or require("zf_sim_util")

local M = {}
_G.zf_sim_economy = M

local function update_territory(territory)
    local shortage = 0

    for resource_id, amount in pairs(territory.production or {}) do
        util.add_resource(territory.storage, resource_id, amount)
    end

    for resource_id, amount in pairs(territory.consumption or {}) do
        local consumed = util.remove_resource(territory.storage, resource_id, amount)
        if consumed < amount then
            shortage = shortage + (amount - consumed)
        end
    end

    if shortage > 0 then
        territory.supply = util.clamp(territory.supply - 0.08 * shortage, 0, 1)
    else
        territory.supply = util.clamp(territory.supply + 0.02, 0, 1)
    end

    if territory.supply < 0.35 then
        territory.security = util.clamp(territory.security - 0.03, 0, 1)
    elseif territory.supply > 0.75 then
        territory.security = util.clamp(territory.security + 0.01, 0, 1)
    end
end

function M.update(state)
    for _, territory in pairs(state.territories or {}) do
        update_territory(territory)
    end
end

return M
