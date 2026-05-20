local core = require("zf_sim_core")
local state_mod = require("zf_sim_state")
local h = require("test_helpers")

local state = core.new_world()
local rv = state.territories.rookie_village
local cp = state.territories.cordon_checkpoint

core.strategic_tick(state)
core.strategic_tick(state)
core.strategic_tick(state)

h.assert_eq(state.strategic_tick, 3, "third tick reached")
h.assert_eq(state_mod.count_map_items(state.caravans), 1, "first caravan created")
h.assert_eq(state_mod.active_caravan_count(state), 1, "first caravan moving")
h.assert_eq(state.caravans.caravan_1.origin, "rookie_village", "caravan origin")
h.assert_eq(state.caravans.caravan_1.destination, "cordon_checkpoint", "caravan destination")
h.assert_eq(rv.storage.food, 59, "caravan food removed from origin")
h.assert_eq(rv.storage.ammo_basic, 69, "caravan ammo removed from origin")
h.assert_eq(state.last_event, "caravan_1 departed rookie_village", "departure event")

core.strategic_tick(state)
core.strategic_tick(state)
core.strategic_tick(state)

h.assert_eq(state.caravans.caravan_1.state, "arrived", "first caravan arrived")
h.assert_eq(cp.storage.food, 20, "arrival transfers food after consumption")
h.assert_eq(cp.storage.ammo_basic, 41, "arrival transfers ammo after consumption")
h.assert_eq(state.caravans.caravan_2.state, "moving", "second caravan departs on tick six")
h.assert_eq(state_mod.active_caravan_count(state), 1, "one active caravan after second departure")
