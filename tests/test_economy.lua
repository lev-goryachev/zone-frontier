local core = require("zf_sim_core")
local h = require("test_helpers")

local state = core.new_world()
local rv = state.territories.rookie_village
local cp = state.territories.cordon_checkpoint
local gh = state.territories.garbage_hangar

core.strategic_tick(state)

h.assert_eq(state.strategic_tick, 1, "tick increments")
h.assert_eq(rv.storage.food, 77, "rookie food consumed")
h.assert_eq(rv.storage.water, 67, "rookie water consumed")
h.assert_eq(rv.storage.ammo_basic, 89, "rookie ammo consumed")
h.assert_near(rv.supply, 0.87, 0.0001, "rookie supply improves when stocked")
h.assert_near(rv.security, 0.46, 0.0001, "rookie security improves when supplied")

h.assert_eq(cp.storage.food, 18, "checkpoint food consumed")
h.assert_eq(cp.storage.ammo_basic, 33, "checkpoint ammo consumed")
h.assert_near(cp.supply, 0.67, 0.0001, "checkpoint supply improves")

h.assert_eq(gh.storage.scrap_metal, 128, "hangar produces scrap")
h.assert_eq(gh.storage.food, 26, "hangar food consumed")

