local M = {}
_G.zf_sim_util = M

function M.copy_map(value)
    local result = {}

    for key, item in pairs(value or {}) do
        result[key] = item
    end

    return result
end

function M.count_map_items(value)
    local count = 0

    if type(value) ~= "table" then
        return count
    end

    for _ in pairs(value) do
        count = count + 1
    end

    return count
end

function M.clamp(value, minimum, maximum)
    if value < minimum then
        return minimum
    end

    if value > maximum then
        return maximum
    end

    return value
end

function M.add_resource(storage, resource_id, amount)
    storage[resource_id] = (storage[resource_id] or 0) + amount
end

function M.remove_resource(storage, resource_id, amount)
    local current = storage[resource_id] or 0
    local removed = math.min(current, amount)
    storage[resource_id] = current - removed
    return removed
end

return M
