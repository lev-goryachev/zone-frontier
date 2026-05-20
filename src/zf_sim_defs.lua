local M = {}
_G.zf_sim_defs = M

M.resources = {
    food = {
        id = "food",
        display_name = "Food",
        category = "consumable",
    },
    water = {
        id = "water",
        display_name = "Water",
        category = "consumable",
    },
    ammo_basic = {
        id = "ammo_basic",
        display_name = "Basic ammo",
        category = "consumable",
    },
    scrap_metal = {
        id = "scrap_metal",
        display_name = "Scrap metal",
        category = "raw",
    },
}

M.factions = {
    loners = {
        id = "loners",
        display_name = "Loners",
        base_aggression = 0.25,
        expansion_preference = 0.35,
    },
    bandits = {
        id = "bandits",
        display_name = "Bandits",
        base_aggression = 0.70,
        expansion_preference = 0.60,
    },
}

M.territories = {
    rookie_village = {
        id = "rookie_village",
        display_name = "Rookie Village",
        type = "outpost",
        owner = "loners",
        supply = 0.85,
        security = 0.45,
        storage = {
            food = 80,
            water = 70,
            ammo_basic = 90,
            scrap_metal = 10,
        },
        consumption = {
            food = 3,
            water = 3,
            ammo_basic = 1,
        },
        production = {},
    },
    cordon_checkpoint = {
        id = "cordon_checkpoint",
        display_name = "Cordon Checkpoint",
        type = "outpost",
        owner = "loners",
        supply = 0.65,
        security = 0.35,
        storage = {
            food = 20,
            water = 20,
            ammo_basic = 35,
            scrap_metal = 0,
        },
        consumption = {
            food = 2,
            water = 2,
            ammo_basic = 2,
        },
        production = {},
    },
    garbage_hangar = {
        id = "garbage_hangar",
        display_name = "Garbage Hangar",
        type = "resource_point",
        owner = "bandits",
        supply = 0.55,
        security = 0.55,
        storage = {
            food = 28,
            water = 22,
            ammo_basic = 50,
            scrap_metal = 120,
        },
        consumption = {
            food = 2,
            water = 2,
            ammo_basic = 1,
        },
        production = {
            scrap_metal = 8,
        },
    },
}

M.routes = {
    rookie_to_checkpoint = {
        id = "rookie_to_checkpoint",
        origin = "rookie_village",
        destination = "cordon_checkpoint",
        nodes = {"rookie_village", "cordon_checkpoint"},
        travel_ticks = 3,
        cargo = {
            food = 12,
            ammo_basic = 18,
        },
    },
}

return M
