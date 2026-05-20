local state_mod = zf_sim_state or require("zf_sim_state")
local bootstrap = zf_sim_bootstrap or require("zf_sim_bootstrap")
local economy = zf_sim_economy or require("zf_sim_economy")
local caravans = zf_sim_caravans or require("zf_sim_caravans")

local M = {}
_G.zf_sim_core = M

function M.new_world()
    local state = state_mod.new_world_state()
    bootstrap.init_state(state)
    return state
end

function M.strategic_tick(state)
    state.strategic_tick = state.strategic_tick + 1
    economy.update(state)
    caravans.update(state)
    return state
end

return M
