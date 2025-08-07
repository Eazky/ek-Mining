ESX = exports["es_extended"]:getSharedObject()

-- ===============================================
-- Stone System Variables
-- ===============================================
local SpawnedObjects = {}

-- ===============================================
-- Main Thread
-- ===============================================
CreateThread(function()
    -- Wait for player data to be loaded
    while not ESX.IsPlayerLoaded() do
        Wait(100)
    end
    
    -- Initial setup after player is loaded
    InitializeMiningSystem()
end)

-- Function to initialize the mining system
function InitializeMiningSystem()
    -- Small delay to ensure ESX data is fully loaded
    Wait(1000)
    
    -- Check job and create/hide blips accordingly
    exports['ek-Mining']:UpdateBlipsVisibility()
    
    -- Create cloakroom interaction
    CreateCloakroomInteraction()
    
    -- Initialize vehicle system
    InitializeVehicleSystem()

    -- Spawn objects in mining areas
    spawnObjects()
end

-- Cleanup props on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        cleanupAllProps()
        RemoveAllBlips()
    end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    if Config.MiningArea[1].debug then
        print("^3[DEBUG] Job changed to: " .. tostring(job.name) .. " in client.lua^0")
    end
    
    -- Call the exported function from functions.lua
    Wait(500)
    exports['ek-Mining']:UpdateBlipsVisibility()
end)

-- ===============================================
-- Stone System Functions
-- ===============================================

function cleanupAllProps()
    for i, objectList in pairs(SpawnedObjects) do
        for _, obj in ipairs(objectList) do
            if DoesEntityExist(obj) then
                exports.ox_target:removeLocalEntity(obj)
                DeleteEntity(obj)
            end
        end
    end
    SpawnedObjects = {}
end

function spawnObjects()
    for i, data in pairs(Config.MiningArea) do
        lib.zones.sphere({
            coords = data.coords,
            radius = data.radius,
            debug = data.debug or false,
            onEnter = function()
                SpawnedObjects[i] = {}
                for j = 1, data.stoneAmount do
                    local offset = vec3(math.random(-data.radius, data.radius), math.random(-data.radius, data.radius), 0.0)
                    local spawnPos = data.coords + offset
                    local prop = CreateObject(data.props[math.random(#data.props)], spawnPos.x, spawnPos.y, spawnPos.z, true, true, false)
                    PlaceObjectOnGroundProperly(prop)
                    SetEntityHeading(prop, math.random(0, 360))
                    FreezeEntityPosition(prop, true)
                    table.insert(SpawnedObjects[i], prop)

                    exports.ox_target:addLocalEntity(prop, {
                        label = _U('mine_stone'),
                        icon = 'fas fa-hammer',
                        onSelect = function()
                            -- Add job check here
                            if not HasRequiredJob() then
                                ESX.ShowNotification(_U('need_required_job_to_mine'))
                                return
                            end

                            if lib.progressCircle({
                                duration = 10000,
                                label = _U('mining_stone'),
                                useWhileDead = false,
                                canCancel = true,
                                position = 'bottom',
                                disable = {
                                    move = true,
                                },
                                anim = {
                                    dict = 'melee@large_wpn@streamed_core',
                                    clip = 'ground_attack_on_spot'
                                },
                                prop = {
                                    model = `prop_tool_pickaxe`,
                                    pos = vec3(0.09, 0.03, -0.02),
                                    rot = vec3(-78.0, 13.0, 28.5)
                                },
                            }) then
                                DeleteEntity(prop)
                                spawnNewProp(i, data)
                                TriggerServerEvent('ek-mining:giveStone')
                            end                  
                        end,
                        canInteract = function()
                            return HasRequiredJob()
                        end
                    })
                end
            end,
            onExit = function()
                if SpawnedObjects[i] then
                    for _, obj in pairs(SpawnedObjects[i]) do
                        exports.ox_target:removeLocalEntity(obj)
                        DeleteEntity(obj)
                    end
                    SpawnedObjects[i] = nil
                end
            end
        })
    end
end

function spawnNewProp(index, data)
    local offset = vec3(math.random(-data.radius, data.radius), math.random(-data.radius, data.radius), 0.0)
    local spawnPos = data.coords + offset
    local prop = CreateObject(data.props[math.random(#data.props)], spawnPos.x, spawnPos.y, spawnPos.z, true, true, false)
    PlaceObjectOnGroundProperly(prop)
    SetEntityHeading(prop, math.random(0, 360))
    FreezeEntityPosition(prop, true)
    table.insert(SpawnedObjects[index], prop)
    exports.ox_target:addLocalEntity(prop, {
        label = _U('mine_stone'),
        icon = 'fas fa-hammer',
        onSelect = function()
            -- Add job check here too
            if not HasRequiredJob() then
                ESX.ShowNotification(_U('need_required_job_to_mine'))
                return
            end

            if lib.progressBar({
                duration = 10000,
                label = _U('mining_stone'),
                useWhileDead = false,
                canCancel = true,
                disable = {
                    move = true,
                },
                anim = {
                    dict = 'melee@large_wpn@streamed_core',
                    clip = 'ground_attack_on_spot'
                },
                prop = {
                    model = `prop_tool_pickaxe`,
                    pos = vec3(0.09, 0.03, -0.02),
                    rot = vec3(-78.0, 13.0, 28.5)
                },
            }) then
                DeleteEntity(prop)
                spawnNewProp(index, data)
                TriggerServerEvent('ek-mining:giveStone')
            end               
        end,
        canInteract = function()
            return HasRequiredJob()
        end
    })
end