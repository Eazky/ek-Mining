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
-- Selling
-- ===============================================

local sellingPeds = {} -- Store selling peds for cleanup

-- Function to start selling items
local function startSelling(sellerIndex)
    if not HasRequiredJob() then
        ESX.ShowNotification(_U('need_required_job_to_sell'))
        return
    end
    
    local playerPed = PlayerPedId()
    local config = Config.Selling[sellerIndex]
    
    if not config then
        print("^1[ERROR] No selling configuration found for index: " .. sellerIndex .. "^0")
        return
    end
    
    -- Check if player is in vehicle
    if IsPedInAnyVehicle(playerPed, false) then
        ESX.ShowNotification(_U('cant_do_in_vehicle'))
        return
    end

    -- Create selling menu
    local menuOptions = {
        {
            title = _U('sell_items_title'),
            description = _U('sell_items_desc'),
            icon = 'fas fa-coins',
            disabled = true
        }
    }
    
    -- Add each sellable item to the menu
    for i, itemData in pairs(config.items) do
        local hasItem = exports.ox_inventory:Search('count', itemData.item)
        local itemCount = hasItem or 0
        
        table.insert(menuOptions, {
            title = _U('sell_item', itemData.item, itemData.price),
            description = _U('you_have', itemCount, itemData.item),
            icon = 'fas fa-gem',
            disabled = itemCount < 1,
            onSelect = function()
                sellItemToNPC(sellerIndex, itemData.item, itemData.price)
            end,
            metadata = {
                item = itemData.item,
                price = itemData.price,
                count = itemCount
            }
        })
    end
    
    -- Add sell all option
    table.insert(menuOptions, {
        title = _U('sell_all'),
        description = _U('sell_all_desc'),
        icon = 'fas fa-hand-holding-usd',
        onSelect = function()
            sellAllItems(sellerIndex)
        end
    })

    -- Show menu using ox_lib or ESX
    if GetResourceState('ox_lib') == 'started' then
        lib.registerContext({
            id = 'mining_selling_menu',
            title = _U('mineral_trader'),
            options = menuOptions
        })
        lib.showContext('mining_selling_menu')
    else
        -- Fallback for ESX menu
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'selling_menu', {
            title = _U('mineral_trader'),
            align = 'top-left',
            elements = menuOptions
        }, function(data, menu)
            if data.current.onSelect then
                data.current.onSelect()
            end
        end, function(data, menu)
            menu.close()
        end)
    end
end

-- Function to sell individual item
function sellItemToNPC(sellerIndex, itemName, price)
    local hasItem = exports.ox_inventory:Search('count', itemName)
    
    if not hasItem or hasItem < 1 then
        ESX.ShowNotification(_U('dont_have_item', itemName))
        return
    end
    
    -- Create input dialog for quantity
    if GetResourceState('ox_lib') == 'started' then
        local input = lib.inputDialog(_U('sell_quantity'), {
            {
                type = 'number',
                label = _U('quantity'),
                description = _U('max_quantity', hasItem),
                required = true,
                min = 1,
                max = hasItem
            }
        })
        
        if input and input[1] then
            local quantity = tonumber(input[1])
            if quantity and quantity > 0 and quantity <= hasItem then
                performSellAction(sellerIndex, itemName, price, quantity)
            end
        end
    else
        -- Fallback: sell 1 item at a time
        performSellAction(sellerIndex, itemName, price, 1)
    end
end

-- Function to sell all items
function sellAllItems(sellerIndex)
    local config = Config.Selling[sellerIndex]
    local itemsToSell = {}
    
    -- Check what items player has
    for _, itemData in pairs(config.items) do
        local hasItem = exports.ox_inventory:Search('count', itemData.item)
        if hasItem and hasItem > 0 then
            table.insert(itemsToSell, {
                item = itemData.item,
                price = itemData.price,
                quantity = hasItem
            })
        end
    end
    
    if #itemsToSell == 0 then
        ESX.ShowNotification(_U('no_items_to_sell'))
        return
    end
    
    -- Confirm sale
    if GetResourceState('ox_lib') == 'started' then
        local alert = lib.alertDialog({
            header = _U('confirm_sell_all'),
            content = _U('confirm_sell_all_desc'),
            centered = true,
            cancel = true
        })
        
        if alert == 'confirm' then
            for _, sellData in pairs(itemsToSell) do
                performSellAction(sellerIndex, sellData.item, sellData.price, sellData.quantity)
            end
        end
    else
        -- Direct sell for ESX fallback
        for _, sellData in pairs(itemsToSell) do
            performSellAction(sellerIndex, sellData.item, sellData.price, sellData.quantity)
        end
    end
end

-- Function to perform the actual selling action
function performSellAction(sellerIndex, itemName, price, quantity)
    local playerPed = PlayerPedId()
    
    -- Play selling animation
    RequestAnimDict("mp_common")
    while not HasAnimDictLoaded("mp_common") do
        Wait(1)
    end
    TaskPlayAnim(playerPed, "mp_common", "givetake1_a", 8.0, -8.0, 2000, 1, 0, false, false, false)
    -- Instantly process the sale after animation
    Wait(1000) -- Wait a short moment for animation effect (optional, adjust as needed)
    ClearPedTasks(playerPed)
    -- Trigger server event to process the sale
    TriggerServerEvent("ek-mining:sellItem", sellerIndex, itemName, price, quantity)
end

-- Function to create selling ped and target zone
function CreateSellingNPC()
    CreateThread(function()
        for i, data in pairs(Config.Selling) do
            -- Request ped model
            local pedModel = GetHashKey(data.ped)
            RequestModel(pedModel)
            while not HasModelLoaded(pedModel) do
                Wait(1)
            end
            
            -- Create the ped
            local ped = CreatePed(4, pedModel, data.coords.x, data.coords.y, data.coords.z - 1.0, data.heading, false, true)
            
            -- Configure the ped
            FreezeEntityPosition(ped, true)
            SetEntityInvincible(ped, true)
            SetBlockingOfNonTemporaryEvents(ped, true)
            
            -- Set ped scenario if provided
            if data.scenario then
                TaskStartScenarioInPlace(ped, data.scenario, 0, true)
            end
            
            -- Store ped for cleanup
            sellingPeds[i] = ped
            
            -- Add ox_target interaction
            exports.ox_target:addLocalEntity(ped, {
                {
                    icon = 'fas fa-coins',
                    label = _U('talk_to_trader'),
                    onSelect = function()
                        startSelling(i)
                    end,
                    canInteract = function()
                        return HasRequiredJob()
                    end
                }
            })
            
            -- Release model
            SetModelAsNoLongerNeeded(pedModel)
            
            if Config.MiningArea[1].debug then
                print("^2[DEBUG] Created selling NPC #" .. i .. " at: " .. tostring(data.coords) .. "^0")
            end
        end
    end)
end

-- Function to cleanup selling NPCs
function CleanupSellingNPCs()
    for i, ped in pairs(sellingPeds) do
        if DoesEntityExist(ped) then
            exports.ox_target:removeLocalEntity(ped)
            DeleteEntity(ped)
        end
    end
    sellingPeds = {}
end

-- Initialize selling system
CreateSellingNPC()

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        CleanupSellingNPCs()
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