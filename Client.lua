local QBCore = exports['qb-core']:GetCoreObject()
local in_robbery = false
local robbery_data = {}
local crew_members = {}
local started_by = nil

-- Start robbery
RegisterCommand(Config.Commands.start_robbery, function(source, args, rawCommand)
    if in_robbery then
        TriggerEvent('chat:addMessage', {
            args = {"BANK", "A robbery is already in progress!"},
            color = {255, 0, 0}
        })
        return
    end

    local player_ped = PlayerPedId()
    local player_coords = GetEntityCoords(player_ped)
    local bank_id = tonumber(args[1])

    if not bank_id or not Config.Banks[bank_id] then
        TriggerEvent('chat:addMessage', {
            args = {"BANK", "Invalid bank ID! (1-" .. #Config.Banks .. ")"},
            color = {255, 0, 0}
        })
        return
    end

    local bank = Config.Banks[bank_id]
    local distance = #(player_coords - bank.coords)

    if distance > 50.0 then
        TriggerEvent('chat:addMessage', {
            args = {"BANK", "You're too far from the bank!"},
            color = {255, 0, 0}
        })
        return
    end

    -- Check if enough police
    TriggerServerEvent('flecca_bank:check_police', bank_id)
end)

-- Test heist command
RegisterCommand(Config.Commands.test_heist, function(source, args, rawCommand)
    local player_ped = PlayerPedId()
    local player_coords = GetEntityCoords(player_ped)

    local bank_id = tonumber(args[1]) or 1
    if not Config.Banks[bank_id] then bank_id = 1 end

    local bank = Config.Banks[bank_id]
    SetEntityCoords(player_ped, bank.coords.x, bank.coords.y, bank.coords.z - 1, false, false, false, false)
    TriggerEvent('chat:addMessage', {
        args = {"BANK", "Teleported to " .. bank.label},
        color = {0, 255, 0}
    })
end)

-- Server approved robbery start
RegisterNetEvent('flecca_bank:start_robbery')
AddEventHandler('flecca_bank:start_robbery', function(bank_id, players)
    in_robbery = true
    robbery_data = Config.Banks[bank_id]
    crew_members = players
    started_by = GetPlayerServerId(PlayerId())

    TriggerEvent('chat:addMessage', {
        args = {"BANK", "Robbery started at " .. robbery_data.label .. "!"},
        color = {0, 255, 0}
    })

    -- Trigger alarm on server
    TriggerServerEvent('flecca_bank:trigger_alarm', bank_id)

    -- Start robbery timer
    StartRobberyTimer()
end)

-- Hack safe
RegisterCommand('hacksafe', function(source, args, rawCommand)
    if not in_robbery then
        TriggerEvent('chat:addMessage', {
            args = {"BANK", "No robbery in progress!"},
            color = {255, 0, 0}
        })
        return
    end

    local player_ped = PlayerPedId()
    local safe_distance = #(GetEntityCoords(player_ped) - robbery_data.safe_coords)

    if safe_distance > 5.0 then
        TriggerEvent('chat:addMessage', {
            args = {"BANK", "You're too far from the safe!"},
            color = {255, 0, 0}
        })
        return
    end

    StartHacking()
end)

-- Drill safe
RegisterCommand('drillsafe', function(source, args, rawCommand)
    if not in_robbery then
        TriggerEvent('chat:addMessage', {
            args = {"BANK", "No robbery in progress!"},
            color = {255, 0, 0}
        })
        return
    end

    local player_ped = PlayerPedId()
    local safe_distance = #(GetEntityCoords(player_ped) - robbery_data.safe_coords)

    if safe_distance > 5.0 then
        TriggerEvent('chat:addMessage', {
            args = {"BANK", "You're too far from the safe!"},
            color = {255, 0, 0}
        })
        return
    end

    StartDrilling()
end)

-- Collect loot
RegisterCommand('collectloot', function(source, args, rawCommand)
    if not in_robbery then
        TriggerEvent('chat:addMessage', {
            args = {"BANK", "No robbery in progress!"},
            color = {255, 0, 0}
        })
        return
    end

    local player_ped = PlayerPedId()
    local safe_distance = #(GetEntityCoords(player_ped) - robbery_data.safe_coords)

    if safe_distance > 10.0 then
        TriggerEvent('chat:addMessage', {
            args = {"BANK", "You're too far from the loot!"},
            color = {255, 0, 0}
        })
        return
    end

    TriggerServerEvent('flecca_bank:collect_loot', robbery_data.id)
end)

-- End robbery
RegisterNetEvent('flecca_bank:end_robbery')
AddEventHandler('flecca_bank:end_robbery', function(success, reason)
    in_robbery = false

    if success then
        TriggerEvent('chat:addMessage', {
            args = {"BANK", "Robbery successful! Escape!"},
            color = {0, 255, 0}
        })
    else
        TriggerEvent('chat:addMessage', {
            args = {"BANK", "Robbery failed: " .. (reason or "Unknown")},
            color = {255, 0, 0}
        })
    end
end)

-- Cancel robbery
RegisterCommand('cancelrobbery', function(source, args, rawCommand)
    if not in_robbery then
        TriggerEvent('chat:addMessage', {
            args = {"BANK", "No robbery in progress!"},
            color = {255, 0, 0}
        })
        return
    end

    TriggerServerEvent('flecca_bank:cancel_robbery', robbery_data.id)
    in_robbery = false
end)

-- Helper functions
function StartRobberyTimer()
    local duration = 600 -- 10 minutes max
    local start_time = GetGameTimer()

    while in_robbery and (GetGameTimer() - start_time) < (duration * 1000) do
        Wait(100)
    end

    if in_robbery then
        TriggerEvent('chat:addMessage', {
            args = {"BANK", "Time's up! Robbery failed!"},
            color = {255, 0, 0}
        })
        TriggerServerEvent('flecca_bank:end_robbery', robbery_data.id, false, 'Time expired')
        in_robbery = false
    end
end

function StartHacking()
    TriggerEvent('chat:addMessage', {
        args = {"BANK", "Starting hack sequence..."},
        color = {255, 255, 0}
    })

    Wait(2000)
    TriggerEvent('chat:addMessage', {
        args = {"BANK", "Hack complete! Safe unlocked."},
        color = {0, 255, 0}
    })
end

function StartDrilling()
    TriggerEvent('chat:addMessage', {
        args = {"BANK", "Starting drill sequence..."},
        color = {255, 255, 0}
    })

    Wait(5000)
    TriggerEvent('chat:addMessage', {
        args = {"BANK", "Drill complete! Safe opened."},
        color = {0, 255, 0}
    })
end

-- Export functions
exports('IsRobberyActive', function()
    return in_robbery
end)

exports('GetRobberyData', function()
    return robbery_data
end)

exports('GetCrewMembers', function()
    return crew_members
end)
