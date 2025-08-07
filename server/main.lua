ESX = exports["es_extended"]:getSharedObject()

function HasRequiredJobServer(src)
    if not Config.RequiredJob or Config.RequiredJob == '' then
        return true
    end
    
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return false end
    
    return xPlayer.job.name == Config.RequiredJob
end

-- Event to give stone rewards
RegisterNetEvent('ek-mining:giveStone', function()
    local src = source

    local zone = Config.MiningArea[1] -- or dynamically based on location
    local item = zone.item
    local minAmount = zone.minAmount
    local maxAmount = zone.maxAmount
    local amount = math.random(minAmount, maxAmount)

    local success = exports.ox_inventory:AddItem(src, item, amount)

    if success then
        TriggerClientEvent('esx:showNotification', src, _U('received_stone', amount, item))
    else
        TriggerClientEvent('esx:showNotification', src, _U('inventory_full_server'))
    end
end)

RegisterNetEvent('ek-mining:processStone', function(index)
    print("Received request to process stone from player", src, "with index", index)
    local src = source
    local config = Config.Processing[index]
    if not config then return end

local hasItem = exports.ox_inventory:Search(src, 'count', config.item)
    if hasItem < 1 then
        TriggerClientEvent('esx:showNotification', src, _U('no_stone_to_process'))
        return
    end

    exports.ox_inventory:RemoveItem(src, config.item, 1)
    exports.ox_inventory:AddItem(src, config.result, config.amount)

    TriggerClientEvent('esx:showNotification', src, _U('processed_stone', config.item, config.amount, config.result))
end)

RegisterNetEvent('ek-mining:washStone', function(index)
    print("Received request to wash stone from player", source, "with index", index)
    local src = source
    local config = Config.Washing[index]
    if not config then return end

    local hasItem = exports.ox_inventory:Search(src, 'count', config.item)
    if hasItem < 10 then
        TriggerClientEvent('esx:showNotification', src, _U('need_cobbledstone_to_wash'))
        return
    end

    exports.ox_inventory:RemoveItem(src, config.item, 10) -- Require 10 cobbled stone to wash
    exports.ox_inventory:AddItem(src, config.result, config.amount)

    TriggerClientEvent('esx:showNotification', src, _U('washed_stone', config.item, config.amount, config.result))
end)

RegisterNetEvent('ek-mining:smeltStone')
AddEventHandler('ek-mining:smeltStone', function(index)
    local src = source
    local config = Config.Smelting[index]
    
    print("^3[SMELTING DEBUG] Starting smelting process^0")
    print("^3[SMELTING DEBUG] Player ID:", src)
    print("^3[SMELTING DEBUG] Index:", index)
    print("^3[SMELTING DEBUG] Config exists:", config ~= nil)
    
    if not config then 
        print("^1[SMELTING ERROR] No config found for index:", index)
        return 
    end
    
    -- Better config debugging
    print("^3[SMELTING DEBUG] Config.item:", config.item)
    print("^3[SMELTING DEBUG] Config.amount:", config.amount)
    print("^3[SMELTING DEBUG] Config.time:", config.time)
    print("^3[SMELTING DEBUG] Config.rewards exists:", config.rewards ~= nil)
    
    if config.rewards then
        print("^3[SMELTING DEBUG] Rewards type:", type(config.rewards))
        for k, v in pairs(config.rewards) do
            print("^3[SMELTING DEBUG] Reward key:", k, "value:", json.encode(v))
        end
    end
    
    -- Check if player has the required item
    local hasItem = exports.ox_inventory:Search(src, 'count', config.item)
    print("^3[SMELTING DEBUG] Player has", hasItem, "of item:", config.item)
    print("^3[SMELTING DEBUG] Required amount:", config.amount)
    
    if hasItem >= config.amount then
        print("^2[SMELTING DEBUG] Player has enough items, proceeding with smelting^0")
        
        -- Remove required items
        local removeSuccess = exports.ox_inventory:RemoveItem(src, config.item, config.amount)
        print("^3[SMELTING DEBUG] Remove item success:", removeSuccess)
        
        local totalRewards = 0
        local rewardsGiven = {}
        
        -- Check if rewards table exists
        if not config.rewards then
            print("^1[SMELTING ERROR] No rewards table in config!")
            return
        end
        
        -- Count rewards properly (handles both array and key-value tables)
        local rewardCount = 0
        for _ in pairs(config.rewards) do
            rewardCount = rewardCount + 1
        end
        
        print("^3[SMELTING DEBUG] Number of possible rewards:", rewardCount)
        
        -- Process rewards based on chances
        for i, reward in pairs(config.rewards) do
            print("^3[SMELTING DEBUG] Processing reward", i, ":", json.encode(reward))
            
            if reward.chance and reward.item and reward.count then
                local randomChance = math.random(1, 100)
                print("^3[SMELTING DEBUG] Random:", randomChance, "vs Required:", reward.chance)
                
                if randomChance <= reward.chance then
                    local addSuccess = exports.ox_inventory:AddItem(src, reward.item, reward.count)
                    print("^2[SMELTING DEBUG] Reward won! Added", reward.count, "x", reward.item, "- Success:", addSuccess)
                    
                    if addSuccess then
                        TriggerClientEvent('esx:showNotification', src, 'You received ' .. reward.count .. 'x ' .. reward.item)
                        totalRewards = totalRewards + 1
                        table.insert(rewardsGiven, reward.item .. " x" .. reward.count)
                    end
                else
                    print("^1[SMELTING DEBUG] Reward missed. Needed", reward.chance, "or less, got", randomChance)
                end
            else
                print("^1[SMELTING ERROR] Invalid reward structure:", json.encode(reward))
            end
        end
        
        print("^3[SMELTING DEBUG] Total rewards given:", totalRewards)
        
        if totalRewards > 0 then
            TriggerClientEvent('esx:showNotification', src, 'Smelting complete! Received: ' .. table.concat(rewardsGiven, ', '))
        else
            TriggerClientEvent('esx:showNotification', src, 'Smelting complete but no valuable materials were found this time.')
        end
        
    else
        print("^1[SMELTING DEBUG] Player doesn't have enough items")
        TriggerClientEvent('esx:showNotification', src, 'You need ' .. config.amount .. 'x ' .. config.item .. ' to smelt')
    end
end)

CreateThread(function()
    -- Insert job if not exists
    exports.oxmysql:execute(
        "INSERT IGNORE INTO jobs (name, label) VALUES ('miner', 'Miner')",
        {},
        function(result)
            print("[EK-MINING] Checked/Inserted job 'miner' into jobs table.")
        end
    )

    -- Insert job grade if not exists
    exports.oxmysql:execute(
        [[INSERT IGNORE INTO job_grades (job_name, grade, name, label, salary, skin_male, skin_female)
          VALUES ('miner', 0, 'miner', 'Miner', 20, '{}', '{}')]],
        {},
        function(result)
            print("[EK-MINING] Checked/Inserted grade 0 for job 'miner' into job_grades table.")
        end
    )
end)

-- Event to handle item selling
RegisterNetEvent('ek-mining:sellItem')
AddEventHandler('ek-mining:sellItem', function(sellerIndex, itemName, price, quantity)
    local src = source
    
    -- Add job check
    if not HasRequiredJobServer(src) then
        TriggerClientEvent('esx:showNotification', src, _U('need_required_job_to_sell'))
        return
    end
    
    local config = Config.Selling[sellerIndex]
    if not config then
        print("^1[ERROR] Invalid seller index: " .. sellerIndex .. "^0")
        return
    end
    
    -- Validate item is sellable to this NPC
    local canSell = false
    local itemPrice = 0
    for _, itemData in pairs(config.items) do
        if itemData.item == itemName then
            canSell = true
            itemPrice = itemData.price
            break
        end
    end
    
    if not canSell then
        TriggerClientEvent('esx:showNotification', src, _U('trader_doesnt_buy_item'))
        return
    end
    
    -- Check if player has the item
    local hasItem = exports.ox_inventory:Search(src, 'count', itemName)
    if not hasItem or hasItem < quantity then
        TriggerClientEvent('esx:showNotification', src, _U('dont_have_enough_items'))
        return
    end
    
    -- Remove items from inventory
    local removed = exports.ox_inventory:RemoveItem(src, itemName, quantity)
    if removed then
        -- Calculate total payment
        local totalPayment = itemPrice * quantity
        
        -- Add money to player
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            xPlayer.addMoney(totalPayment)
            
            -- Notify player
            TriggerClientEvent('esx:showNotification', src, _U('sold_items', quantity, itemName, totalPayment))
            
            if Config.MiningArea[1].debug then
                print("^2[DEBUG] Player " .. src .. " sold " .. quantity .. "x " .. itemName .. " for $" .. totalPayment .. "^0")
            end
        else
            -- Refund items if player not found
            exports.ox_inventory:AddItem(src, itemName, quantity)
            TriggerClientEvent('esx:showNotification', src, _U('transaction_failed'))
        end
    else
        TriggerClientEvent('esx:showNotification', src, _U('failed_to_remove_items'))
    end
end)