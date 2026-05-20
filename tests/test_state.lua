local core = require("zf_sim_core")
local state_mod = require("zf_sim_state")
local h = require("test_helpers")

local state = core.new_world()

h.assert_eq(state.schema_version, "0.1.0", "schema version")
h.assert_eq(state.strategic_tick, 0, "initial strategic tick")
h.assert_eq(state_mod.count_map_items(state.territories), 3, "territory count")
h.assert_eq(state_mod.count_map_items(state.factions), 2, "faction count")
h.assert_eq(state.territories.rookie_village.owner, "loners", "rookie owner")
h.assert_eq(state.territories.garbage_hangar.owner, "bandits", "hangar owner")

