-- Utility functions for bank robbery

-- Draw 3D text
function DrawText3D(x, y, z, text, scale, rgb)
    scale = scale or 0.3
    rgb = rgb or {255, 255, 255}

    local camCoords = GetGameplayCamCoords()
    local distance = #(vector3(x, y, z) - camCoords)

    if distance > 100.0 then return end

    SetTextScale(0.0 * scale, 0.55 * scale)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(rgb[1], rgb[2], rgb[3], 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

-- Get distance to location
function GetDistance(coords1, coords2)
    return #(coords1 - coords2)
end

-- Check if player is in range
function IsPlayerInRange(coords, range)
    local player_ped = PlayerPedId()
    local player_coords = GetEntityCoords(player_ped)
    return GetDistance(player_coords, coords) <= range
end

-- Load animation dict
function LoadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(100)
    end
end

-- Play animation
function PlayAnimation(ped, dict, anim, flag, duration)
    flag = flag or 49
    LoadAnimDict(dict)
    TaskPlayAnim(ped, dict, anim, 8.0, -8.0, duration or 1000, flag, 0, false, false, false)
    RemoveAnimDict(dict)
end

-- Create blip
function CreateBlip(coords, sprite, color, scale, label)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, color)
    SetBlipScale(blip, scale or 0.8)
    AddTextComponentString(label)
    SetBlipAsNoLongerNeeded(blip)
    return blip
end

-- Draw marker
function DrawMarker(type, x, y, z, dir_x, dir_y, dir_z, rot_x, rot_y, rot_z, scale_x, scale_y, scale_z, r, g, b, alpha, bob, face_cam, p19, rotate)
    DrawMarker(type, x, y, z, dir_x, dir_y, dir_z, rot_x, rot_y, rot_z, scale_x, scale_y, scale_z, r, g, b, alpha, bob, face_cam, p19, rotate)
end

-- Notify player
function Notify(title, message, type)
    type = type or 'info'
    TriggerEvent('chat:addMessage', {
        args = {title, message},
        color = type == 'success' and {0, 255, 0} or type == 'error' and {255, 0, 0} or {255, 255, 0}
    })
end

-- Generate random loot
function GenerateRandomLoot()
    local loot = {}
    local random_item = Config.Loot[math.random(1, #Config.Loot)]
    local amount = math.random(random_item.amount.min, random_item.amount.max)
    
    return {
        item = random_item.item,
        label = random_item.label,
        amount = amount,
    }
end

-- Format money
function FormatMoney(amount)
    return '$' .. string.format('%.2f', amount):reverse():gsub('(%d%d%d)', '%1,'):reverse()
end

exports('Notify', function(title, message, type)
    Notify(title, message, type)
end)

exports('FormatMoney', function(amount)
    return FormatMoney(amount)
end)
