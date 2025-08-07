ESX = exports["es_extended"]:getSharedObject()

-- ===============================================
-- Stone processing part
-- ===============================================

local function startProcessing(index)
    if not HasRequiredJob() then
        ESX.ShowNotification(_U('need_required_job_to_process'))
        return
    end
    
    local playerPed = PlayerPedId()
    local config = Config.Processing[index]
    print("Processing stone with config:", config)
    
    -- Check if player is in vehicle
    if IsPedInAnyVehicle(playerPed, false) then
        ESX.ShowNotification(_U('cant_do_in_vehicle'))
        return
    end

    -- Request animation dictionary
    RequestAnimDict("melee@large_wpn@streamed_core")
    while not HasAnimDictLoaded("melee@large_wpn@streamed_core") do
        Wait(1)
    end

    -- Check if player has stone
    local hasItem = exports.ox_inventory:Search('count', 'stone')

    if hasItem and hasItem >= 1 then -- Require 1 stone

        -- Create hammer prop
        local hammerModel = GetHashKey("prop_tool_sledgeham")
        RequestModel(hammerModel)
        while not HasModelLoaded(hammerModel) do
            Wait(1)
        end        

        -- Create the hammer object
        local hammerProp = CreateObject(hammerModel, 0, 0, 0, true, true, true)

        -- Attach hammer to player's hand
        AttachEntityToEntity(hammerProp, playerPed, GetPedBoneIndex(playerPed, 57005), 0.1, 0, 0, -86.0, 13.0, 28.5, true, true, false, true, 1, true)       
        
        -- Start hammering animation
        TaskPlayAnim(playerPed, "melee@large_wpn@streamed_core", "ground_attack_on_spot", 8.0, -8.0, -1, 1, 0, false, false, false)
            
        -- Show progress bar
        if lib.progressCircle({
            duration = config.time,
            position = 'bottom',
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = true,
                combat = true,
            },
            label = _U('processing_stone'),
        }) then
            -- Progress completed successfully
            ClearPedTasks(playerPed)

            -- Remove hammer prop
            DeleteObject(hammerProp)
            SetModelAsNoLongerNeeded(hammerModel)

            -- Trigger server event to craft the coke brick
            TriggerServerEvent("ek-mining:processStone", index)
        else
            -- Progress was cancelled
            ClearPedTasks(playerPed)

            -- Remove hammer prop
            DeleteObject(hammerProp)
            SetModelAsNoLongerNeeded(hammerModel)

            ESX.ShowNotification(_U('process_cancelled'))
        end
    else
        -- Player does not have enough stone
        ESX.ShowNotification(_U('need_stone_to_process'))
    end
end


-- ===============================================
-- Stone washing part
-- ===============================================

local function startWashing(index)
    if not HasRequiredJob() then
        ESX.ShowNotification(_U('need_required_job_to_wash'))
        return
    end
    
    local playerPed = PlayerPedId()
    local config = Config.Washing[index]
    print("Washing stone with config:", config)
    
    -- Check if player is in vehicle
    if IsPedInAnyVehicle(playerPed, false) then
        ESX.ShowNotification(_U('cant_do_in_vehicle'))
        return
    end

    -- Request animation dictionary for washing
    RequestAnimDict("amb@world_human_gardener_plant@male@idle_a")
    while not HasAnimDictLoaded("amb@world_human_gardener_plant@male@idle_a") do
        Wait(1)
    end

    -- Check if player has cobbled stone
    local hasItem = exports.ox_inventory:Search('count', config.item)

    if hasItem and hasItem >= 10 then -- Require 10 cobbled stone

        -- Start washing animation (crouching/washing motion)
        TaskPlayAnim(playerPed, "amb@world_human_gardener_plant@male@idle_a", "idle_a", 8.0, -8.0, -1, 1, 0, false, false, false)

        -- Show progress bar
        if lib.progressCircle({
            duration = config.time,
            position = 'bottom',
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = true,
                combat = true,
            },
            label = _U('washing_stone'),
        }) then
            -- Progress completed successfully
            ClearPedTasks(playerPed)

            -- Trigger server event to wash the stone
            TriggerServerEvent("ek-mining:washStone", index)
        else
            -- Progress was cancelled
            ClearPedTasks(playerPed)

            ESX.ShowNotification(_U('wash_cancelled'))
        end
    else
        -- Player does not have enough cobbled stone
        ESX.ShowNotification(_U('need_cobbledstone_to_wash'))
    end
end

-- ===============================================
-- Stone smelting part
-- ===============================================

local function startSmelting(index)
    if not HasRequiredJob() then
        ESX.ShowNotification(_U('need_required_job_to_smelt'))
        return
    end
    
    local playerPed = PlayerPedId()
    local config = Config.Smelting[index]
    print("Smelting stone with config:", config)
    
    -- Check if player is in vehicle
    if IsPedInAnyVehicle(playerPed, false) then
        ESX.ShowNotification(_U('cant_do_in_vehicle'))
        return
    end

    -- Request animation dictionary for smelting (using welding animation)
    RequestAnimDict("amb@world_human_welding@male@idle_a")
    while not HasAnimDictLoaded("amb@world_human_welding@male@idle_a") do
        Wait(1)
    end

    -- Check if player has the required item
    local hasItem = exports.ox_inventory:Search('count', config.item)

    if hasItem and hasItem >= config.amount then -- Check required amount

        -- Start smelting animation (welding/working with hot materials)
        TaskPlayAnim(playerPed, "amb@world_human_welding@male@idle_a", "idle_a", 8.0, -8.0, -1, 1, 0, false, false, false)

        -- Show progress bar
        if lib.progressCircle({
            duration = config.time,
            position = 'bottom',
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = true,
                combat = true,
            },
            label = _U('smelting_stone'),
        }) then
            -- Progress completed successfully
            ClearPedTasks(playerPed)

            -- Trigger server event to smelt the stone
            TriggerServerEvent("ek-mining:smeltStone", index)
        else
            -- Progress was cancelled
            ClearPedTasks(playerPed)

            ESX.ShowNotification(_U('smelt_cancelled'))
        end
    else
        -- Player does not have enough required items
        ESX.ShowNotification(_U('need_items_to_smelt'))
    end
end

-- ===============================================
-- Targets
-- ===============================================

CreateThread(function()
    for i, data in pairs(Config.Processing) do
        exports.ox_target:addBoxZone({
            coords = data.coords,
            size = vec3(2, 2, 2),
            rotation = 0,
            debug = false,
            options = {
                {
                    icon = data.icon or 'fas fa-cube',
                    label = _U('process_stone'),
                    onSelect = function()
                        startProcessing(i)
                    end,
                    canInteract = function()
                        return HasRequiredJob()
                    end
                }
            }
        })
    end
end)

-- Add washing targets using ox_target box zones
for i, data in pairs(Config.Washing) do
    print("^2[DEBUG] Creating washing box zone #" .. i .. " at: " .. tostring(data.coords) .. " with size: " .. tostring(data.size) .. "^0")
    
    exports.ox_target:addBoxZone({
        coords = data.coords,
        size = data.size, -- Use size directly from config
        rotation = data.rotation or 0, -- Use rotation from config or default to 0
        debug = data.debug or false, -- Enable debug to see the zones
        options = {
            {
                icon = data.icon or 'fas fa-tint',
                label = _U('wash_stone'),
                onSelect = function()
                    startWashing(i)
                end,
                canInteract = function()
                    return HasRequiredJob()
                end
            }
        }
    })
end

CreateThread(function()
    for i, data in pairs(Config.Smelting) do
        print("^2[DEBUG] Creating smelting box zone #" .. i .. " at: " .. tostring(data.coords) .. " with size: " .. tostring(data.size) .. "^0")
        
        exports.ox_target:addBoxZone({
            coords = data.coords,
            size = data.size, -- Use size directly from config
            rotation = data.rotation or 0, -- Use rotation from config or default to 0
            debug = data.debug or false, -- Enable debug to see the zones
            options = {
                {
                    icon = data.icon or 'fas fa-fire',
                    label = _U('smelt_stone'),
                    onSelect = function()
                        startSmelting(i)
                    end,
                    canInteract = function()
                        return HasRequiredJob()
                    end
                }
            }
        })
    end
end)

-- ===============================================
-- Blips
-- ===============================================

function HasRequiredJob()
    if not Config.RequiredJob or Config.RequiredJob == '' then
        return true -- No job requirement
    end
    
    -- ESX job check
    if ESX and ESX.IsPlayerLoaded() then
        local playerData = ESX.GetPlayerData()
        if not playerData or not playerData.job then
            return false
        end
        
        return playerData.job.name == Config.RequiredJob
    end
    
    return false -- Default to false if ESX not loaded or no player data
end