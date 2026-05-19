-- Logging system for bank robberies

local log_file = 'logs/flecca_bank.log'

-- Initialize log file
function InitializeLogs()
    if not io.open(log_file, 'r') then
        io.open(log_file, 'w'):close()
    end
end

-- Write to log
function WriteLog(action, player_name, bank_name, additional_info)
    local timestamp = os.date('%Y-%m-%d %H:%M:%S')
    local log_entry = string.format('[%s] %s - Player: %s, Bank: %s', timestamp, action, player_name, bank_name)
    
    if additional_info then
        log_entry = log_entry .. string.format(', Info: %s', additional_info)
    end
    
    log_entry = log_entry .. '\n'
    
    -- Write to file
    local file = io.open(log_file, 'a')
    if file then
        file:write(log_entry)
        file:close()
    end
    
    -- Console log
    if Config.Debug then
        print('^2[Flecca Bank]^7 ' .. log_entry)
    end
end

-- Log robbery events
RegisterServerEvent('flecca_bank:log_robbery')
AddEventHandler('flecca_bank:log_robbery', function(action, player_name, bank_name, additional_info)
    WriteLog(action, player_name, bank_name, additional_info)
end)

-- Initialize on resource start
InitializeLogs()
