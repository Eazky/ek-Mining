ESX = exports["es_extended"]:getSharedObject()

-- Variable to store original clothes
local originalClothes = {}
local blips = {} -- Store all blips for management
local isWearingWorkClothes = false

-- ===============================================
-- Mining Blip
-- ===============================================

-- Function to create mining blip
function CreateMinerCloakroomBlip()
    local blip = AddBlipForCoord(LockerCoords.x, LockerCoords.y, LockerCoords.z)
    SetBlipSprite(blip, 73) -- Mining/quarry blip sprite
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, 5) -- Yellow color
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(_U('miner_cloakroom'))
    EndTextCommandSetBlipName(blip)
    
    if Config.MiningArea[1].debug then
        print("^2[DEBUG] Mining cloakroom blip created at coords: " .. tostring(LockerCoords) .. "^0")
    end
    
    return blip
end

-- ===============================================
-- Cloakroom functions
-- ===============================================

-- Function to get player's current clothes using native functions
function GetCurrentClothes()
    local playerPed = PlayerPedId()
    local clothes = {}
    
    -- Get all drawable components
    clothes.face = GetPedDrawableVariation(playerPed, 0)
    clothes.face_2 = GetPedTextureVariation(playerPed, 0)
    clothes.hair = GetPedDrawableVariation(playerPed, 2)
    clothes.hair_2 = GetPedTextureVariation(playerPed, 2)
    clothes.tshirt_1 = GetPedDrawableVariation(playerPed, 8)
    clothes.tshirt_2 = GetPedTextureVariation(playerPed, 8)
    clothes.torso_1 = GetPedDrawableVariation(playerPed, 11)
    clothes.torso_2 = GetPedTextureVariation(playerPed, 11)
    clothes.arms = GetPedDrawableVariation(playerPed, 3)
    clothes.arms_2 = GetPedTextureVariation(playerPed, 3) -- Added arms texture
    clothes.pants_1 = GetPedDrawableVariation(playerPed, 4)
    clothes.pants_2 = GetPedTextureVariation(playerPed, 4)
    clothes.shoes_1 = GetPedDrawableVariation(playerPed, 6)
    clothes.shoes_2 = GetPedTextureVariation(playerPed, 6)
    
    -- Get all prop components
    clothes.helmet_1 = GetPedPropIndex(playerPed, 0)
    clothes.helmet_2 = GetPedPropTextureIndex(playerPed, 0)
    clothes.glasses_1 = GetPedPropIndex(playerPed, 1)
    clothes.glasses_2 = GetPedPropTextureIndex(playerPed, 1)
    clothes.mask_1 = GetPedDrawableVariation(playerPed, 1)
    clothes.mask_2 = GetPedTextureVariation(playerPed, 1)
    clothes.bags_1 = GetPedDrawableVariation(playerPed, 5)
    clothes.bags_2 = GetPedTextureVariation(playerPed, 5)
    
    return clothes
end

-- Function to apply clothes using native functions
function ApplyClothes(clothes)
    local playerPed = PlayerPedId()
    
    -- Apply drawable components
    if clothes.face then SetPedComponentVariation(playerPed, 0, clothes.face, clothes.face_2 or 0, 0) end
    if clothes.hair then SetPedComponentVariation(playerPed, 2, clothes.hair, clothes.hair_2 or 0, 0) end
    if clothes.tshirt_1 then SetPedComponentVariation(playerPed, 8, clothes.tshirt_1, clothes.tshirt_2 or 0, 0) end
    if clothes.torso_1 then SetPedComponentVariation(playerPed, 11, clothes.torso_1, clothes.torso_2 or 0, 0) end
    if clothes.arms then SetPedComponentVariation(playerPed, 3, clothes.arms, 0, 0) end
    if clothes.pants_1 then SetPedComponentVariation(playerPed, 4, clothes.pants_1, clothes.pants_2 or 0, 0) end
    if clothes.shoes_1 then SetPedComponentVariation(playerPed, 6, clothes.shoes_1, clothes.shoes_2 or 0, 0) end
    if clothes.mask_1 then SetPedComponentVariation(playerPed, 1, clothes.mask_1, clothes.mask_2 or 0, 0) end
    if clothes.bags_1 then SetPedComponentVariation(playerPed, 5, clothes.bags_1, clothes.bags_2 or 0, 0) end
    
    -- Apply prop components
    if clothes.helmet_1 and clothes.helmet_1 ~= -1 then
        SetPedPropIndex(playerPed, 0, clothes.helmet_1, clothes.helmet_2 or 0, true)
    else
        ClearPedProp(playerPed, 0)
    end
    
    if clothes.glasses_1 and clothes.glasses_1 ~= -1 then
        SetPedPropIndex(playerPed, 1, clothes.glasses_1, clothes.glasses_2 or 0, true)
    else
        ClearPedProp(playerPed, 1)
    end
end

-- Function to save current clothes
function SaveCurrentClothes()
    originalClothes = GetCurrentClothes()
    if Config.Debug then
        print("^2[DEBUG] Saved original clothes^0")
    end
end

-- Function to detect player gender
function GetPlayerGender()
    local playerPed = PlayerPedId()
    local playerModel = GetEntityModel(playerPed)
    
    if playerModel == GetHashKey("mp_f_freemode_01") then
        return "female"
    else
        return "male"
    end
end

-- Function to apply work clothes
function ApplyWorkClothes()
    local gender = GetPlayerGender()
    local clothes = Config.WorkClothes[gender]
    
    if Config.Debug then
        print("^2[DEBUG] Player model: " .. tostring(GetEntityModel(PlayerPedId())) .. "^0")
        print("^2[DEBUG] Detected gender: " .. gender .. "^0")
        print("^2[DEBUG] Using clothes config for: " .. gender .. "^0")
    end
    
    -- Save current clothes before changing
    if not isWearingWorkClothes then
        SaveCurrentClothes()
    end
    
    -- Apply work clothes using native functions
    ApplyClothes(clothes)
    
    isWearingWorkClothes = true
    
    if Config.Debug then
        print("^2[DEBUG] Applied work clothes for " .. gender .. "^0")
    end
end

-- Function to restore original clothes
function RestoreOriginalClothes()
    if not originalClothes or not next(originalClothes) then
        ESX.ShowNotification("No original clothes saved!")
        return
    end
    
    -- Restore original clothes using native functions
    ApplyClothes(originalClothes)
    
    isWearingWorkClothes = false
    
    if Config.Debug then
        print("^2[DEBUG] Restored original clothes^0")
    end
end

-- Cloakroom function with ox_lib context menu
function OpenCloakroom()
    lib.registerContext({
        id = 'mining_cloakroom',
        title = _U('cloakroom_title'),
        options = {
            {
                title = _U('put_work_clothes'),
                description = _U('put_work_clothes_desc'),
                icon = 'fas fa-hard-hat',
                onSelect = function()
                    if not isWearingWorkClothes then
                        ApplyWorkClothes()
                        ESX.ShowNotification(_U('work_clothes_on'))
                    else
                        ESX.ShowNotification(_U('already_work_clothes'))
                    end
                end,
                disabled = isWearingWorkClothes
            },
            {
                title = _U('put_civilian_clothes'),
                description = _U('put_civilian_clothes_desc'),
                icon = 'fas fa-tshirt',
                onSelect = function()
                    if isWearingWorkClothes then
                        RestoreOriginalClothes()
                        ESX.ShowNotification(_U('civilian_clothes_on'))
                    else
                        ESX.ShowNotification(_U('already_civilian_clothes'))
                    end
                end,
                disabled = not isWearingWorkClothes
            }
        }
    })
    
    lib.showContext('mining_cloakroom')
end

-- Function to create cloakroom interaction
function CreateCloakroomInteraction()
    exports.ox_target:addBoxZone({
        coords = LockerCoords,
        size = vec3(2, 2, 2),
        rotation = 0,
        debug = Config.Debug,
        options = {
            {
                name = 'mining_cloakroom',
                event = 'ek-mining:openCloakroom',
                icon = 'fas fa-tshirt',
                label = _U('open_cloakroom'),
                canInteract = function()
                    return HasRequiredJob()
                end
            }
        }
    })
    
    if Config.Debug then
        print("^2[DEBUG] Created cloakroom interaction at coords: " .. tostring(LockerCoords) .. "^0")
    end
end

-- Event handler for cloakroom
RegisterNetEvent('ek-mining:openCloakroom', function()
    OpenCloakroom()
end)


-- ===============================================
-- Vehicle Functions
-- ===============================================


-- Vehicle variables
local currentJobVehicle = nil
local vehicleShopPed = nil

-- Function to open vehicle menu
function openVehicleMenu()
    local options = {}
    
    -- Check if player has a spawned vehicle
    if currentJobVehicle and DoesEntityExist(currentJobVehicle) then
        table.insert(options, {
            title = _U('store_vehicle'),
            description = _U('store_vehicle'),
            icon = 'fas fa-warehouse',
            onSelect = function()
                StoreJobVehicle()
            end
        })
    else
        -- Add spawn options for each vehicle in config
        for i, vehicle in ipairs(Config.Vehicles) do
            table.insert(options, {
                title = vehicle.label,
                description = _U('spawn_vehicle') .. ' ' .. vehicle.label,
                icon = 'fas fa-truck',
                onSelect = function()
                    SpawnJobVehicle(vehicle)
                end
            })
        end
    end
    
    lib.registerContext({
        id = 'mining_vehicle_menu',
        title = _U('vehicle_shop_title'),
        options = options
    })
    
    lib.showContext('mining_vehicle_menu')
end

-- Function to spawn job vehicle
function SpawnJobVehicle(vehicleData)
    local spawnCoords = vehicleData.spawnCoords
    
    -- Check if spawn point is clear
    if IsAnyVehicleNearPoint(spawnCoords.x, spawnCoords.y, spawnCoords.z, 3.0) then
        ESX.ShowNotification(_U('spawn_blocked'))
        return
    end
    
    CreateJobVehicle(vehicleData)
end

-- Function to create the vehicle
function CreateJobVehicle(vehicleData)
    local model = GetHashKey(vehicleData.model)
    local spawnCoords = vehicleData.spawnCoords
    
    -- Request model
    RequestModel(model)
    local timeout = 0
    while not HasModelLoaded(model) and timeout < 100 do
        Wait(50)
        timeout = timeout + 1
    end
    
    if not HasModelLoaded(model) then
        ESX.ShowNotification("Failed to load vehicle model!")
        return
    end
    
    -- Create vehicle
    currentJobVehicle = CreateVehicle(model, spawnCoords.x, spawnCoords.y, spawnCoords.z, spawnCoords.w, true, false)
    
    -- Set vehicle properties
    SetEntityAsMissionEntity(currentJobVehicle, true, true)
    SetVehicleNumberPlateText(currentJobVehicle, "MINING")
    
    -- Give keys to player (if you have a key system)
    local plate = GetVehicleNumberPlateText(currentJobVehicle)
    TriggerEvent("vehiclekeys:client:SetOwner", plate)
    
    -- Put player in vehicle
    TaskWarpPedIntoVehicle(PlayerPedId(), currentJobVehicle, -1)
    
    -- Set fuel to full (if you have a fuel system)
    if GetResourceState('LegacyFuel') == 'started' then
        exports['LegacyFuel']:SetFuel(currentJobVehicle, 100.0)
    end
    
    ESX.ShowNotification(_U('vehicle_spawned', vehicleData.label))
    
    if Config.Debug then
        print("^2[DEBUG] Spawned job vehicle: " .. vehicleData.model .. "^0")
    end
    
    -- Clean up model
    SetModelAsNoLongerNeeded(model)
end

-- Function to store job vehicle
function StoreJobVehicle()
    if not currentJobVehicle or not DoesEntityExist(currentJobVehicle) then
        ESX.ShowNotification(_U('no_vehicle_to_store'))
        return
    end
    
    local playerPed = PlayerPedId()
    local vehicle = currentJobVehicle
    
    -- Check if player is near the vehicle
    local vehicleCoords = GetEntityCoords(vehicle)
    local playerCoords = GetEntityCoords(playerPed)
    local distance = #(vehicleCoords - playerCoords)
    
    if distance > 10.0 then
        ESX.ShowNotification(_U('too_far_from_vehicle'))
        return
    end
    
    -- Delete vehicle
    DeleteEntity(vehicle)
    currentJobVehicle = nil
    
    ESX.ShowNotification(_U('vehicle_stored'))
    
    if Config.Debug then
        print("^2[DEBUG] Stored job vehicle^0")
    end
end

-- Function to create vehicle shop ped
function CreateVehicleShopPed()
    local model = GetHashKey("s_m_y_construct_01") -- Construction worker model
    local coords = VehiclePedCoords
    
    -- Request model
    RequestModel(model)
    local timeout = 0
    while not HasModelLoaded(model) and timeout < 100 do
        Wait(50)
        timeout = timeout + 1
    end
    
    if not HasModelLoaded(model) then
        print("^1[ERROR] Failed to load vehicle ped model^0")
        return
    end
    
    -- Create ped
    vehicleShopPed = CreatePed(4, model, coords.x, coords.y, coords.z, coords.w, false, true)
    
    -- Setup ped properties
    SetEntityInvincible(vehicleShopPed, true)
    FreezeEntityPosition(vehicleShopPed, true)
    SetBlockingOfNonTemporaryEvents(vehicleShopPed, true)
    SetPedCanRagdoll(vehicleShopPed, false)
    
    -- Add scenario to make the ped look natural
    CreateThread(function()
        Wait(500)
        TaskStartScenarioInPlace(vehicleShopPed, "WORLD_HUMAN_CLIPBOARD", 0, true)
    end)
    
    -- Add ped to ox_target with interaction
    exports.ox_target:addLocalEntity(vehicleShopPed, {
        {
            name = 'open_vehicle_shop',
            label = _U('open_vehicle_shop'),
            icon = 'fa-solid fa-car',
            onSelect = function(entity)
                openVehicleMenu()
            end,
            canInteract = function(entity)
                return HasRequiredJob()
            end,
        }
    })
    
    if Config.Debug then
        print("^2[DEBUG] Created vehicle shop ped at coords: " .. tostring(coords) .. "^0")
    end
    
    -- Clean up model
    SetModelAsNoLongerNeeded(model)
end

-- Function to delete vehicle shop ped (for cleanup)
function DeleteVehicleShopPed()
    if vehicleShopPed and DoesEntityExist(vehicleShopPed) then
        DeleteEntity(vehicleShopPed)
        vehicleShopPed = nil
    end
end

-- Function to initialize vehicle system
function InitializeVehicleSystem()
    CreateVehicleShopPed()
end

-- ===============================================
-- Only see blips if player has required job
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
        
        local hasJob = playerData.job.name == Config.RequiredJob
        if Config.MiningArea[1].debug then
            print("^3[DEBUG] Player job: " .. tostring(playerData.job.name) .. "^0")
            print("^3[DEBUG] Required job: " .. Config.RequiredJob .. "^0")
            print("^3[DEBUG] Has required job: " .. tostring(hasJob) .. "^0")
        end
        return hasJob
    end
    
    return false -- Default to false if ESX not loaded or no player data
end

function UpdateBlipsVisibility()
    local hasJob = HasRequiredJob()
    
    if Config.MiningArea[1].debug then
        print("^3[DEBUG] UpdateBlipsVisibility called - Has job: " .. tostring(hasJob) .. "^0")
    end
    
    if hasJob then
        -- Create blips if player has required job
        CreateAllBlips()
    else
        -- Remove blips if player doesn't have required job
        RemoveAllBlips()
    end
end

-- Function to create all blips
function CreateAllBlips()
    -- Only create blips if they don't already exist
    if not blips.mining then
        blips.mining = CreateMiningBlip()
    end
    
    if not blips.cloakroom then
        blips.cloakroom = CreateMinerCloakroomBlip()
    end
    
    if not blips.processing then
        blips.processing = CreateStoneProcessingBlip()
    end
    
    if not blips.washing then
        blips.washing = CreateStoneWashingBlip()
    end
    
    if not blips.smelting then
        blips.smelting = CreateStoneSmeltingBlip()
    end

    if not blips.selling then
        blips.selling = CreateStoneSellingBlip()
    end

    if Config.MiningArea[1].debug then
        print("^2[DEBUG] All blips created for player with required job^0")
    end
end

-- Function to remove all blips
function RemoveAllBlips()
    for blipType, blipId in pairs(blips) do
        if DoesBlipExist(blipId) then
            RemoveBlip(blipId)
            if Config.MiningArea[1].debug then
                print("^3[DEBUG] Removed blip: " .. blipType .. "^0")
            end
        end
        blips[blipType] = nil
    end
    
    if Config.MiningArea[1].debug then
        print("^3[DEBUG] All blips removed - player doesn't have required job^0")
    end
end

-- Function to create mining area blip
function CreateMiningBlip()
    for i, data in pairs(Config.MiningArea) do
        local blip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
        SetBlipSprite(blip, 618) -- Mining/quarry blip sprite
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 1.0)
        SetBlipColour(blip, 5) -- Yellow color
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(_U('mining_area'))
        EndTextCommandSetBlipName(blip)
    
        if Config.MiningArea[1].debug then
            print("^2[DEBUG] Mining area blip created at coords: " .. tostring(data.coords) .. "^0")
        end
        
        return blip -- Return the first blip (assuming single mining area)
    end
end

-- Add the job change event handler to functions.lua
RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    if Config.MiningArea[1].debug then
        print("^3[DEBUG] Job changed to: " .. tostring(job.name) .. " in functions.lua^0")
    end
    
    -- Small delay to ensure ESX data is updated
    Wait(500)
    
    -- Update blip visibility when job changes
    UpdateBlipsVisibility()
end)

-- Also listen for player loaded event
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData)
    if Config.MiningArea[1].debug then
        print("^2[DEBUG] Player loaded, updating blip visibility^0")
    end
    
    -- Small delay to ensure all data is loaded
    Wait(1000)
    UpdateBlipsVisibility()
end)

exports('UpdateBlipsVisibility', UpdateBlipsVisibility)


function CreateStoneWashingBlip()
    if not Config.Washing[1] or not Config.Washing[1].coords then
        print("^1[ERROR] No washing configuration found^0")
        return nil
    end
    
    local washingCoords = Config.Washing[1].coords
    local blip = AddBlipForCoord(washingCoords.x, washingCoords.y, washingCoords.z)
    SetBlipSprite(blip, 68) -- Car wash/cleaning blip sprite
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, 5) -- Blue color for washing
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(_U('wash_stone'))
    EndTextCommandSetBlipName(blip)
    
    if Config.MiningArea[1].debug then
        print("^2[DEBUG] Stone washing blip created at coords: " .. tostring(washingCoords) .. "^0")
    end
    
    return blip
end

function CreateStoneProcessingBlip()
    if not Config.Processing[1] or not Config.Processing[1].coords then
        print("^1[ERROR] No processing configuration found^0")
        return nil
    end
    
    local processingCoords = Config.Processing[1].coords
    local blip = AddBlipForCoord(processingCoords.x, processingCoords.y, processingCoords.z)
    SetBlipSprite(blip, 478) -- Factory/industrial processing blip sprite
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, 5) -- Orange color for processing
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(_U('process_stone'))
    EndTextCommandSetBlipName(blip)
    
    if Config.MiningArea[1].debug then
        print("^2[DEBUG] Stone processing blip created at coords: " .. tostring(processingCoords) .. "^0")
    end
    
    return blip
end

function CreateStoneSmeltingBlip()
    if not Config.Smelting[1] or not Config.Smelting[1].coords then
        print("^1[ERROR] No smelting configuration found^0")
        return nil
    end
    
    local smeltingCoords = Config.Smelting[1].coords
    local blip = AddBlipForCoord(smeltingCoords.x, smeltingCoords.y, smeltingCoords.z)
    SetBlipSprite(blip, 436) -- Fire sprite
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, 5) -- Red color for smelting
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(_U('smelt_stone'))
    EndTextCommandSetBlipName(blip)
    
    if Config.MiningArea[1].debug then
        print("^2[DEBUG] Stone smelting blip created at coords: " .. tostring(smeltingCoords) .. "^0")
    end
    
    return blip
end

function CreateStoneSellingBlip()
    if not Config.Selling[1] or not Config.Selling[1].coords then
        print("^1[ERROR] No selling configuration found^0")
        return nil
    end
    
    local sellingCoords = Config.Selling[1].coords
    local blip = AddBlipForCoord(sellingCoords.x, sellingCoords.y, sellingCoords.z)
    SetBlipSprite(blip, 276) -- Dollar sign sprite
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 1.5)
    SetBlipColour(blip, 5) -- Green color for selling
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(_U('mineral_trader'))
    EndTextCommandSetBlipName(blip)
    
    if Config.MiningArea[1].debug then
        print("^2[DEBUG] Stone selling blip created at coords: " .. tostring(sellingCoords) .. "^0")
    end
    
    return blip
end

-- ===============================================