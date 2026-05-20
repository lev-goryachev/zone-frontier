local util = zf_sim_util or require("zf_sim_util")

local M = {}
_G.zf_sim_caravans = M

local function has_active_route_caravan(state, route_id)
    for _, caravan in pairs(state.caravans) do
        if caravan.route == route_id and caravan.state == "moving" then
            return true
        end
    end

    return false
end

local function create_caravan(state, route_definition)
    local origin = state.territories[route_definition.origin]

    if origin == nil then
        return nil
    end

    local cargo = {}
    local total_cargo = 0

    for resource_id, amount in pairs(route_definition.cargo) do
        local removed = util.remove_resource(origin.storage, resource_id, amount)
        if removed > 0 then
            cargo[resource_id] = removed
            total_cargo = total_cargo + removed
        end
    end

    if total_cargo == 0 then
        return nil
    end

    local id = "caravan_" .. tostring(state.next_caravan_id or 1)
    state.next_caravan_id = (state.next_caravan_id or 1) + 1

    state.caravans[id] = {
        id = id,
        owner = origin.owner,
        route = route_definition.id,
        origin = route_definition.origin,
        destination = route_definition.destination,
        cargo = cargo,
        progress = 0,
        travel_ticks = route_definition.travel_ticks,
        state = "moving",
    }

    return state.caravans[id]
end

local function arrive_caravan(state, caravan)
    local destination = state.territories[caravan.destination]

    if destination ~= nil then
        for resource_id, amount in pairs(caravan.cargo) do
            util.add_resource(destination.storage, resource_id, amount)
        end
    end

    caravan.state = "arrived"
    state.last_event = caravan.id .. " arrived at " .. caravan.destination
    table.insert(state.events, {
        tick = state.strategic_tick,
        type = "caravan_arrived",
        id = caravan.id,
        destination = caravan.destination,
    })
end

function M.update(state)
    for _, caravan in pairs(state.caravans) do
        if caravan.state == "moving" then
            caravan.progress = caravan.progress + 1

            if caravan.progress >= caravan.travel_ticks then
                arrive_caravan(state, caravan)
            end
        end
    end

    local route_definition = state.supply_routes.rookie_to_checkpoint
    if route_definition == nil then
        return
    end

    if state.strategic_tick > 0
        and state.strategic_tick % 3 == 0
        and not has_active_route_caravan(state, route_definition.id)
    then
        local caravan = create_caravan(state, route_definition)
        if caravan ~= nil then
            state.last_event = caravan.id .. " departed " .. caravan.origin
            table.insert(state.events, {
                tick = state.strategic_tick,
                type = "caravan_departed",
                id = caravan.id,
                origin = caravan.origin,
                destination = caravan.destination,
            })
        end
    end
end

return M
