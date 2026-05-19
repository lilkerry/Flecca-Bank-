-- Visual and audio effects for bank robbery

local current_effects = {}

-- Trigger alarm effect
function TriggerAlarmEffect(bank_id)
    local bank = Config.Banks[bank_id]

    -- Play alarm sound
    PlaySoundFrontend(-1, 'CONFIRM_BEEP', 'HUD_MINI_GAME_SOUNDSET', true)

    -- Flash screen red
    for i = 1, 5 do
        Wait(200)
        DrawRect(0.5, 0.5, 1.0, 1.0, 255, 0, 0, 100)
    end

    -- Set police dispatch
    TriggerEvent('chat:addMessage', {
        args = {"DISPATCH", "Silent alarm triggered! Police en route."},
        color = {255, 0, 0}
    })
end

-- Screen distortion effect
function EnableScreenDistortion(intensity)
    intensity = intensity or 0.1

    SetRadarBigmapEnabled(true)
    TriggerScreenblur(intensity)
end

function DisableScreenDistortion()
    SetRadarBigmapEnabled(false)
    TriggerScreenblur(0.0)
end

-- Hack effect with scanlines
function HackingScreenEffect(duration)
    duration = duration or 3000
    local start_time = GetGameTimer()

    while (GetGameTimer() - start_time) < duration do
        local alpha = math.sin((GetGameTimer() - start_time) / 500) * 255
        DrawRect(0.5, 0.5, 1.0, 1.0, 0, 255, 0, math.floor(alpha) % 256)
        Wait(0)
    end
end

-- Money pickup effect
function MoneyPickupEffect(coords)
    -- Particle effect
    RequestNamedPtfxAsset('core')
    while not HasNamedPtfxAssetLoaded('core') do Wait(100) end

    UseParticleFxAssetNextCall('core')
    StartParticleFxLoopAtCoord('ent_sht_money_rain', coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 1.0, false, false, false)

    -- Sound effect
    PlaySoundFrontend(-1, 'CONFIRM_BEEP', 'HUD_MINI_GAME_SOUNDSET', true)
end

-- Police siren effect
function StartPoliceSiren()
    PlaySoundFrontend(-1, 'CONFIRM_BEEP', 'HUD_MINI_GAME_SOUNDSET', true)
end

-- Explosion effect (if caught)
function SmallExplosion(coords)
    AddExplosion(coords.x, coords.y, coords.z, 25, 1.0, true, false, 1.0)
end

exports('TriggerAlarmEffect', function(bank_id)
    TriggerAlarmEffect(bank_id)
end)

exports('HackingScreenEffect', function(duration)
    HackingScreenEffect(duration)
end)

exports('MoneyPickupEffect', function(coords)
    MoneyPickupEffect(coords)
end)
