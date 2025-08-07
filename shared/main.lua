Config = {}

-- Locale settings
Config.Locale = 'hu' -- Locale for the script, can be 'en' or 'hu'

-- ===============================================
-- Stone Types Configuration
-- ===============================================

Config.MiningArea = {
    {   
        coords = vector3(2954.33, 2787.35, 39.44), -- Center of mining area
        radius = 40.0, -- Radius of mining area
        loadDistance = 200.0, -- Distance to load/unload stones
        debug = false, -- Enable debug mode for development
        stoneAmount = 30, -- Maximum number of stone nodes that can be spawned
        item = "stone", -- Item name for the mined stone
        minAmount = 1, -- Amount of stone per node
        maxAmount = 3, -- Maximum amount of stone per node
        props = {
            'prop_rock_1_a',
            'prop_rock_1_b',
            'prop_rock_1_c'
        }
    }
}

-- Pickaxe requirement
Config.RequirePickaxe = false -- Set to false for testing
Config.PickaxeItem = "pickaxe"

Config.RequiredJob = "miner" -- Job required to mine stones

-- ===============================================
-- Cloakroom
-- ===============================================

LockerCoords = vector3(892.43, -2171.20, 32.27) -- Coordinates for the locker

Config.WorkClothes = {
    male = {
        tshirt_1 = 59,   -- Basic T-shirt
        tshirt_2 = 0,    -- T-shirt texture
        torso_1 = 22,   -- Work jacket/shirt
        torso_2 = 0,     -- Torso texture
        arms = 142,       -- Arms/sleeves
        arms_2 = 9,       -- Arms texture
        pants_1 = 98,    -- Work pants
        pants_2 = 1,     -- Pants texture
        shoes_1 = 25,    -- Work boots
        shoes_2 = 0,     -- Shoes texture
        helmet_1 = 0,  -- Hard hat (optional)
        helmet_2 = 0,    -- Helmet texture
        mask_1 = 0,      -- No mask
        mask_2 = 0,      -- Mask texture
        bags_1 = 0,      -- No bag
        bags_2 = 0       -- Bag texture
    },

    female = {
        tshirt_1 = 14,   -- Basic T-shirt
        tshirt_2 = 0,    -- T-shirt texture
        torso_1 = 148,   -- Work jacket/shirt
        torso_2 = 0,     -- Torso texture
        arms = 36,       -- Arms/sleeves
        arms_2 = 0,      -- Arms texture
        pants_1 = 34,    -- Work pants
        pants_2 = 0,     -- Pants texture
        shoes_1 = 25,    -- Work boots
        shoes_2 = 0,     -- Shoes texture
        helmet_1 = 116,  -- Hard hat (optional)
        helmet_2 = 0,    -- Helmet texture
        mask_1 = 0,      -- No mask
        mask_2 = 0,      -- Mask texture
        bags_1 = 0,      -- No bag
        bags_2 = 0       -- Bag texture
    }
}

-- ===============================================
-- Vehicles
-- ===============================================

VehiclePedCoords = vector4(879.86, -2169.34, 31.26, 172.91) -- Coordinates for the vehicle spawn

Config.Vehicles = {
    {
        model = "bodhi2", -- Vehicle model
        label = "Mining Truck", -- Vehicle label
        spawnCoords = vector4(878.98, -2176.91, 30.50, 170.07), -- Vehicle spawn coordinates
        --job = "miner" -- Job required to use this vehicle
    }
}

-- ===============================================
-- Processing
-- ===============================================

Config.Processing = {
    {
        item = "stone", -- Item to process
        result = "cobbledstone", -- Resulting item after processing
        coords = vector3(2699.41, 2770.65, 37.87), -- Coordinates for the processing area
        time = 5000, -- Time in milliseconds to process
        amount = 4, -- Amount of processed item received
        icon = "fas fa-cube" -- Icon for the processing action
    }
}

Config.Washing = {
    {
        item = "cobbledstone", -- Item to process
        result = "washed_stone", -- Resulting item after processing
        coords = vector3(2153.45, 3842.98, 30.37), -- Coordinates for the washing area (UPDATE THESE TO YOUR POND)
        size = vec3(120.0, 50.0, 4.0), -- Size of the washing area for the target zone
        -- This is a large area, adjust as needed
        rotation = 215.43, -- Rotation of the washing area
        debug = false, -- Enable debug mode for development
        time = 5000, -- Time in milliseconds to process
        amount = 10, -- Amount of processed item received (Currently it requires 10 cobbled stone to wash)
        icon = "fas fa-tint" -- Icon for the washing action
    }
}

Config.Smelting = {
    {
        coords = vector3(1111.92, -2009.30, 31.04), -- Coordinates for the smelting area
        size = vec3(3.0, 3.0, 4.0), -- Size of the washing area
        rotation = 243.43, -- Rotation of the washing area
        debug = false, -- Enable debug mode for development           
        item = "washed_stone", -- Item to smelt
        amount = 1, -- Amount of washed_stone required to smelt
        rewards = {
            { item = "copper", chance = 1, count = 1 }, -- |chance = 1, | means there is a 1% chance to receive this item
            { item = "iron", chance = 1, count = 1 }, -- |chance = 1, | means there is a 1% chance to receive this item
            { item = "gold", chance = 1, count = 1 }, -- |chance = 1, | means there is a 1% chance to receive this item
            { item = "diamond", chance = 100, count = 1 }, -- |chance = 50, | means there is a 50% chance to receive this item
        },
        time = 5000, -- Time in milliseconds to smelt
        icon = "fas fa-fire" -- Icon for the smelting action
    }
}

-- ===============================================
-- LOCALIZATION SYSTEM
-- ===============================================

-- Initialize locales table
Locales = {
    ['en'] = {
        -- General messages
        ['inventory_full'] = 'Your inventory is full!',
        ['cant_do_in_vehicle'] = "You can't do this while in a vehicle.",
        ['action_cancelled'] = 'Action cancelled.',
        
        -- Mining
        ['mining_stone'] = 'Mining stone...',
        ['mining_cancelled'] = 'Mining cancelled.',
        ['received_ore'] = 'You received %sx %s',
        ['no_pickaxe'] = 'You need a pickaxe to mine!',
        ['mining_area'] = 'Mining Area',            -- This is the blip for the mining area
        ['miner_cloakroom'] = 'Mining Cloakroom',   -- This one is used for the blip name

        -- Target Labels
        ['mine_stone'] = 'Mine Stone',
        ['process_stone'] = 'Process Stone',
        ['wash_stone'] = 'Wash Stone',
        ['processing_stone'] = 'Processing stone...',
        ['washing_stone'] = 'Washing stone...',
        ['process_cancelled'] = 'Process cancelled',
        ['wash_cancelled'] = 'Washing cancelled',
        ['need_stone_to_process'] = 'You need at least 1 stone to process',
        ['need_cobbledstone_to_wash'] = 'You need at least 10 cobbled stone to wash',

        -- Smelting
        ['smelting_stone'] = 'Smelting stone...',
        ['smelt_cancelled'] = 'Smelting cancelled',
        ['need_items_to_smelt'] = 'You need the required items to smelt',
        ['smelt_stone'] = 'Smelt Stone',
        ['cant_do_in_vehicle'] = 'You cannot do this while in a vehicle',
        ['smelt_ores'] = 'Smelt Ores',            
        
        -- Cloakroom
        ['cloakroom_title'] = 'Mining Cloakroom',
        ['put_work_clothes'] = 'Put on Work Clothes',
        ['put_work_clothes_desc'] = 'Change into mining work clothes',
        ['put_civilian_clothes'] = 'Change to Civilian Clothes',
        ['put_civilian_clothes_desc'] = 'Change back to your normal clothes',
        ['work_clothes_on'] = 'You put on your work clothes',
        ['civilian_clothes_on'] = 'You changed back to your civilian clothes',
        ['already_work_clothes'] = 'You are already wearing work clothes',
        ['already_civilian_clothes'] = 'You are already wearing civilian clothes',
        ['no_clothes_saved'] = 'No original clothes saved!',
        ['open_cloakroom'] = 'Open Cloakroom',

        -- job check
        ['need_required_job_to_mine'] = 'You need to be a ' .. (Config.RequiredJob or 'worker') .. ' to mine!',
        ['need_required_job_to_process'] = 'You need to be a ' .. (Config.RequiredJob or 'worker') .. ' to process stones!',
        ['need_required_job_to_wash'] = 'You need to be a ' .. (Config.RequiredJob or 'worker') .. ' to wash stones!',
        ['need_required_job_to_smelt'] = 'You need to be a ' .. (Config.RequiredJob or 'worker') .. ' to smelt!',        
        
        -- Vehicles
        ['vehicle_shop_title'] = 'Mining Vehicle Shop',
        ['spawn_vehicle'] = 'Spawn Vehicle',
        ['store_vehicle'] = 'Store Vehicle',
        ['vehicle_spawned'] = 'Vehicle spawned: %s',
        ['vehicle_stored'] = 'Vehicle stored successfully!',
        ['spawn_blocked'] = 'Spawn point is blocked by another vehicle!',
        ['no_vehicle_to_store'] = 'No job vehicle to store!',
        ['too_far_from_vehicle'] = 'You need to be closer to your vehicle to store it!',
        ['open_vehicle_shop'] = 'Open Vehicle Shop',

        -- Duty
        ['duty_blip'] = 'Mining Duty',
        ['go_on_duty'] = 'Go On Duty',
        ['go_off_duty'] = 'Go Off Duty',
        ['go_on_duty_desc'] = 'Start your mining shift',
        ['go_off_duty_desc'] = 'End your mining shift',
        ['duty_status'] = 'Duty Status',
        ['currently_on_duty'] = 'Currently on duty',
        ['currently_off_duty'] = 'Currently off duty',
        ['duty_menu_title'] = 'Mining Duty',
        ['open_duty_menu'] = 'Open Duty Menu',
        ['went_on_duty'] = 'You are now on duty!',
        ['went_off_duty'] = 'You are now off duty!',
        ['already_on_duty'] = 'You are already on duty!',
        ['already_off_duty'] = 'You are already off duty!',
        ['need_to_be_on_duty'] = 'You need to be on duty to %s',
        
        -- Server-side messages
        ['received_stone'] = 'You received %d %s',
        ['inventory_full_server'] = 'Inventory full!',
        ['no_stone_to_process'] = "You don't have any stone to process.",
        ['processed_stone'] = 'You processed 1 %s into %d %s',
        ['washed_stone'] = 'You washed 1 %s into %d %s'
    },
    
    ['hu'] = {
        -- General messages
        ['inventory_full'] = 'A táskád tele van!',
        ['cant_do_in_vehicle'] = "Ezt nem csinálhatod járműben.",
        ['action_cancelled'] = 'Művelet megszakítva.',
        
        -- Mining
        ['mining_stone'] = 'Kő kibányászása...',
        ['mining_cancelled'] = 'Bányászat megszakítva.',
        ['received_ore'] = 'Kaptál %sx %s',
        ['no_pickaxe'] = 'Szükséged van egy csákányra a bányászathoz!',
        ['mining_area'] = 'Bányászati Terület',
        ['miner_cloakroom'] = 'Bányász Öltöző',

        -- Target Labels
        ['mine_stone'] = 'Kő kibányászása',
        ['process_stone'] = 'Kő feldolgozása',
        ['wash_stone'] = 'Kő mosása',
        ['processing_stone'] = 'Kő feldolgozása...',
        ['washing_stone'] = 'Kő mosása...',
        ['process_cancelled'] = 'Feldolgozás megszakítva',
        ['smelt_stone'] = 'Érc olvasztása...',
        ['wash_cancelled'] = 'Mosás megszakítva',
        ['need_stone_to_process'] = 'Legalább 1 kő szükséges a feldolgozáshoz',
        ['need_cobbledstone_to_wash'] = 'Legalább 10 zúzottkő szükséges a mosáshoz',

        -- job check
        ['need_required_job_to_mine'] = 'Szükséged van ' .. (Config.RequiredJob or 'munkás') .. ' munkára a bányászathoz!',
        ['need_required_job_to_process'] = 'Szükséged van ' .. (Config.RequiredJob or 'munkás') .. ' munkára a feldolgozáshoz!',
        ['need_required_job_to_wash'] = 'Szükséged van ' .. (Config.RequiredJob or 'munkás') .. ' munkára a mosáshoz!',
        ['need_required_job_to_smelt'] = 'Szükséged van ' .. (Config.RequiredJob or 'munkás') .. ' munkára az olvasztáshoz!',
    

        -- Smelting
        ['smelting_stone'] = 'Érc olvasztása...',
        ['smelt_cancelled'] = 'Olvasztás megszakítva',
        ['need_items_to_smelt'] = 'Szükséged van a szükséges tárgyakra az olvasztáshoz',
        ['smelt_stone'] = 'Érc olvasztása',
        ['cant_do_in_vehicle'] = 'Ezt nem teheted meg járműben',
        ['smelt_ores'] = 'Ércek olvasztása',       
        
        -- Cloakroom
        ['cloakroom_title'] = 'Bányász Öltöző',
        ['put_work_clothes'] = 'Munkaruha felvétele',
        ['put_work_clothes_desc'] = 'Váltás bányász munkaruhára',
        ['put_civilian_clothes'] = 'Váltás civil ruhára',
        ['put_civilian_clothes_desc'] = 'Visszaváltás normál ruhára',
        ['work_clothes_on'] = 'Felvetted a munkaruhát',
        ['civilian_clothes_on'] = 'Visszaváltottál civil ruhára',
        ['already_work_clothes'] = 'Már munkaruhát viselsz',
        ['already_civilian_clothes'] = 'Már civil ruhát viselsz',
        ['no_clothes_saved'] = 'Nincs eredeti ruha elmentve!',
        ['open_cloakroom'] = 'Öltöző megnyitása',
        
        -- Vehicles
        ['vehicle_shop_title'] = 'Bányász Jármű Bolt',
        ['spawn_vehicle'] = 'Jármű lehívása',
        ['store_vehicle'] = 'Jármű tárolása',
        ['vehicle_spawned'] = 'Jármű lehívva: %s',
        ['vehicle_stored'] = 'Jármű sikeresen tárolva!',
        ['spawn_blocked'] = 'A spawn pont blokkolva van egy másik járművel!',
        ['no_vehicle_to_store'] = 'Nincs munka jármű a tároláshoz!',
        ['too_far_from_vehicle'] = 'Közelebb kell lenned a járművedhöz a tároláshoz!',
        ['open_vehicle_shop'] = 'Jármű bolt megnyitása',
        
        -- Server-side messages
        ['received_stone'] = 'Kaptál %d %s',
        ['inventory_full_server'] = 'A táskád tele van!',
        ['no_stone_to_process'] = 'Nincs kő a feldolgozáshoz.',
        ['processed_stone'] = 'Feldolgoztál 1 %s és kaptál %d %s',
        ['washed_stone'] = 'Mostál 1 %s és kaptál %d %s'
    }
}

-- Function to get localized text
function _U(str, ...)
    if Locales[Config.Locale] and Locales[Config.Locale][str] then
        return string.format(Locales[Config.Locale][str], ...)
    else
        return 'Translation [' .. Config.Locale .. '][' .. str .. '] does not exist'
    end
end