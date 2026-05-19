local QBCore = exports['qb-core']:GetCoreObject()
local active_robberies = {}
local robbery_cooldowns = {}

-- Check if police are on duty
RegisterServerEvent('flecca_bank:check_police')
AddEventHandler('flecca_bank:check_police', function(bank_id)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end

    local police_count = 0
    local players = GetPlayers()
    
    for _, player_id in ipairs(players) do
        local player = QBCore.Functions.GetPlayer(tonumber(player_id))
        if player and player.PlayerData.job.name == Config.PoliceJob and player.PlayerData.job.onduty then
            police_count = police_count + 1
        end
    end

    if police_count < Config.Robbery.minPolice then
        TriggerClientEvent('chat:addMessage', src, {
            args = {"BANK", "Not enough police officers on duty! Need at least " .. Config.Robbery.minPolice},
            color = {255, 0, 0}
        })
        return
    end

    -- Check cooldown
    if robbery_cooldowns[bank_id] and (GetGameTimer() - robbery_cooldowns[bank_id]) < Config.Robbery.cooldown then
        local remaining = math.ceil((Config.Robbery.cooldown - (GetGameTimer() - robbery_cooldowns[bank_id])) / 1000)
        TriggerClientEvent('chat:addMessage', src, {
            args = {"BANK", "This bank was recently robbed. Wait " .. remaining .. " seconds."},
            color = {255, 0, 0}
        })
        return
    end

    -- Start robbery
    active_robberies[bank_id] = {
        started_by = src,
        start_time = GetGameTimer(),
        crew = {src},
        bank_id = bank_id,
        loot_collected = false,
    }

    local crew = {}
    table.insert(crew, Player.PlayerData.citizenid)

    TriggerClientEvent('flecca_bank:start_robbery', src, bank_id, crew)
    
    TriggerEvent('flecca_bank:log_robbery', 'started', Player.PlayerData.name, Config.Banks[bank_id].label)
end)

-- Trigger alarm
RegisterServerEvent('flecca_bank:trigger_alarm')
AddEventHandler('flecca_bank:trigger_alarm', function(bank_id)
    local src = source
    
    -- Notify all police
    local players = GetPlayers()
    for _, player_id in ipairs(players) do
        local player = QBCore.Functions.GetPlayer(tonumber(player_id))
        if player and player.PlayerData.job.name == Config.PoliceJob then
            TriggerClientEvent('chat:addMessage', tonumber(player_id), {
                args = {"DISPATCH", "10-31 Bank robbery in progress at " .. Config.Banks[bank_id].label},
                color = {255, 0, 0}
            })
        end
    end

    -- Trigger alarm effect
    TriggerClientEvent('flecca_bank:trigger_alarm_effect', -1, bank_id)
end)

-- Collect loot
RegisterServerEvent('flecca_bank:collect_loot')
AddEventHandler('flecca_bank:collect_loot', function(bank_id)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    if not active_robberies[bank_id] then
        TriggerClientEvent('chat:addMessage', src, {
            args = {"BANK", "No active robbery at this bank!"},
            color = {255, 0, 0}
        })
        return
    end

    if active_robberies[bank_id].loot_collected then
        TriggerClientEvent('chat:addMessage', src, {
            args = {"BANK", "Loot already collected!"},
            color = {255, 0, 0}
        })
        return
    end

    -- Distribute loot
    local total_reward = Config.Robbery.reward_per_player * #active_robberies[bank_id].crew
    
    for i = 1, math.random(3, 6) do
        local loot = GenerateRandomLoot()
        Player.Functions.AddItem(loot.item, loot.amount)
    end

    -- Add money
    Player.Functions.AddMoney('bank', total_reward, 'bank-robbery')

    active_robberies[bank_id].loot_collected = true
    
    TriggerClientEvent('chat:addMessage', src, {
        args = {"BANK", "Collected loot! Earned: $" .. total_reward},
        color = {0, 255, 0}
    })

    TriggerEvent('flecca_bank:log_robbery', 'loot_collected', Player.PlayerData.name, Config.Banks[bank_id].label, total_reward)
end)

-- End robbery
RegisterServerEvent('flecca_bank:end_robbery')
AddEventHandler('flecca_bank:end_robbery', function(bank_id, success, reason)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end

    if active_robberies[bank_id] then
        active_robberies[bank_id] = nil
    end

    if success then
        robbery_cooldowns[bank_id] = GetGameTimer()
        TriggerEvent('flecca_bank:log_robbery', 'completed', Player.PlayerData.name, Config.Banks[bank_id].label)
    else
        TriggerEvent('flecca_bank:log_robbery', 'failed', Player.PlayerData.name, Config.Banks[bank_id].label, reason)
    end

    TriggerClientEvent('flecca_bank:end_robbery', -1, success, reason)
end)

-- Cancel robbery
RegisterServerEvent('flecca_bank:cancel_robbery')
AddEventHandler('flecca_bank:cancel_robbery', function(bank_id)
    local src = source
    
    if active_robberies[bank_id] then
        active_robberies[bank_id] = nil
    end

    TriggerEvent('flecca_bank:log_robbery', 'cancelled', GetPlayer(src).PlayerData.name, Config.Banks[bank_id].label)
end)

-- Helper function
function GenerateRandomLoot()
    local loot = Config.Loot[math.random(1, #Config.Loot)]
    local amount = math.random(loot.amount.min, loot.amount.max)
    return {
        item = loot.item,
        label = loot.label,
        amount = amount,
    }
end

-- Export functions
exports('GetActiveRobberies', function()
    return active_robberies
end)

exports('IsRobberying', function(bank_id)
    return active_robberies[bank_id] ~= nil
end)
