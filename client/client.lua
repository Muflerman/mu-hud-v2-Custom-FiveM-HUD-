-- ============================================================
--  client.lua (HUD principal)
-- ============================================================

-- ======================
-- 1. VARIABLES GLOBALES
-- ======================
local QBCore = exports['qb-core']:GetCoreObject()
-- El bridge de Qbox ya proporciona 'qb-core', no es necesario llamar a 'qbx-core' para GetCoreObject

local vehicleHUDActive, playerHUDActive = false, false
local hunger, thirst, stress = 100, 100, 0
local seatbeltOn, showSeatbelt = false, false
local speedMultiplier = Config.UseMPH and 2.23694 or 3.6

-- Vehículo
local nos, nitroLevel, nitroActive = 0, 0, 0

-- HUD y pantallas especiales
local showAltitude = false
local inMulticharacter, inSpawnSelector = false, false
local isEditing = false -- Global para este archivo

-- ======================
-- 2. GESTIÓN DEL HUD
-- ======================

local function hideAllHUD()
    vehicleHUDActive, playerHUDActive = false, false
    DisplayRadar(false)
    SendNUIMessage({ action = 'hideVehicleHUD' })
    SendNUIMessage({ action = 'hidePlayerHUD' })
end

local function shouldShowHUD()
    if not LocalPlayer or not LocalPlayer.state then return false end
    if inMulticharacter or inSpawnSelector then return false end
    return LocalPlayer.state.isLoggedIn
end

-- Ocultar todo al inicio para evitar estados residuales e iniciar si ya está logueado
CreateThread(function()
    hideAllHUD()
    Wait(1000)
    if shouldShowHUD() then
        TriggerEvent('hud:client:LoadMap')
    end
end)

local function startHUD()
    if not shouldShowHUD() then return end

    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then
        DisplayRadar(false)
        vehicleHUDActive = false
        SendNUIMessage({ action = 'hideVehicleHUD' })
    else
        DisplayRadar(true)
        vehicleHUDActive = true
        SendNUIMessage({ action = 'showVehicleHUD' })
    end

    TriggerEvent('hud:client:LoadMap')
    SendNUIMessage({ action = 'showPlayerHUD' })
    playerHUDActive = true
    loadPlayerNeeds()
end

-- ======================
-- 3. FUNCIONES UTILITARIAS
-- ======================

local lastCrossroadUpdate, lastCrossroadCheck = 0, {}

local function getCrossroads(vehicle)
    local updateTick = GetGameTimer()
    if updateTick - lastCrossroadUpdate > 1500 then
        local pos = GetEntityCoords(vehicle)
        local street1, street2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
        lastCrossroadUpdate = updateTick
        lastCrossroadCheck = {
            GetStreetNameFromHashKey(street1),
            GetStreetNameFromHashKey(street2)
        }
    end
    return lastCrossroadCheck
end

local function GetDirectionText(heading)
    if heading >= 337.5 or heading < 22.5 then
        return "N"
    elseif heading >= 22.5 and heading < 67.5 then
        return "NW"
    elseif heading >= 67.5 and heading < 112.5 then
        return "W"
    elseif heading >= 112.5 and heading < 157.5 then
        return "SW"
    elseif heading >= 157.5 and heading < 202.5 then
        return "S"
    elseif heading >= 202.5 and heading < 247.5 then
        return "SE"
    elseif heading >= 247.5 and heading < 292.5 then
        return "E"
    elseif heading >= 292.5 and heading < 337.5 then
        return "NE"
    end
end

-- ======================
-- 4. CICLO PRINCIPAL HUD
-- ======================

-- ======================
-- 4. CICLO PRINCIPAL HUD (Optimizado)
-- ======================

local lastHealth, lastArmor, lastHunger, lastThirst, lastStress, lastStamina, lastOxygen, lastTalking, lastVoice = -1, -1,
    -1, -1, -1, -1, -1, -1, -1
local lastSpeed, lastFuel, lastGear, lastStreet1, lastStreet2, lastDirection, lastAlt, lastEngine, lastRpm, lastSeatbelt =
    -1, -1, -1, "", "", "", -1, -1, -1, false

CreateThread(function()
    while true do
        local sleep = Config.updateDelay or 250

        if not shouldShowHUD() or IsPauseMenuActive() then
            if vehicleHUDActive or playerHUDActive then hideAllHUD() end
            DisplayRadar(false)
            Wait(1000)
        else
            if not playerHUDActive then
                SendNUIMessage({ action = 'showPlayerHUD' })
                playerHUDActive = true
            end

            local ped = PlayerPedId()
            local playerId = PlayerId()

            -- Player Data
            local stamina = (100 - GetPlayerSprintStaminaRemaining(playerId))
            local oxygen = GetPlayerUnderwaterTimeRemaining(playerId) * 10
            local isDiving = IsPedSwimmingUnderWater(ped)
            local health = (GetEntityHealth(ped) - 100)
            local armor = GetPedArmour(ped)
            local voice = (LocalPlayer.state['proximity'] and LocalPlayer.state['proximity'].distance) or 0
            local talking = NetworkIsPlayerTalking(playerId)
            local heading = GetEntityHeading(ped)
            local direction = GetDirectionText(heading)

            -- Player NUI Update
            if health ~= lastHealth or armor ~= lastArmor or hunger ~= lastHunger or thirst ~= lastThirst or
                stress ~= lastStress or stamina ~= lastStamina or oxygen ~= lastOxygen or talking ~= lastTalking or
                voice ~= lastVoice or direction ~= lastDirection then
                SendNUIMessage({
                    action = 'updatePlayerHUD',
                    health = health,
                    armor = armor,
                    thirst = thirst,
                    hunger = hunger,
                    stamina = stamina,
                    oxygen = oxygen,
                    isDiving = isDiving,
                    stress = stress,
                    voice = voice,
                    talking = talking,
                    direction = direction,
                })

                lastHealth, lastArmor, lastHunger, lastThirst, lastStress, lastStamina, lastOxygen, lastTalking, lastVoice, lastDirection =
                    health, armor, hunger, thirst, stress, stamina, oxygen, talking, voice, direction
            end

            -- Vehicle logic
            local vehicle = GetVehiclePedIsIn(ped, false)
            if vehicle ~= 0 then
                if not vehicleHUDActive then
                    vehicleHUDActive = true
                    DisplayRadar(true)
                    TriggerEvent('hud:client:LoadMap')
                    SendNUIMessage({ action = 'showVehicleHUD' })
                end

                local _, lights, highbeams = GetVehicleLightsState(vehicle)
                local crossroads = getCrossroads(vehicle)
                local engineHealth = GetVehicleEngineHealth(vehicle)
                local normalizedEngine = math.max(0, math.ceil((engineHealth / 1000) * 100))

                local speed = math.ceil(GetEntitySpeed(vehicle) * (Config.speedMultiplier or 3.6))
                local fuel = math.ceil(GetVehicleFuelLevel(vehicle))
                local gear = (IsPedInAnyHeli(ped) or IsPedInAnyPlane(ped)) and "F" or GetVehicleCurrentGear(vehicle)
                local rpm = GetVehicleCurrentRpm(vehicle)
                local altitude = math.ceil(GetEntityCoords(ped).z * 0.5)

                -- Sync metadata sparsely
                local pData = QBCore.Functions.GetPlayerData()
                if pData and pData.metadata then seatbeltOn = pData.metadata['seatbelt'] or false end

                if speed ~= lastSpeed or fuel ~= lastFuel or gear ~= lastGear or crossroads[1] ~= lastStreet1 or
                    crossroads[2] ~= lastStreet2 or normalizedEngine ~= lastEngine or rpm ~= lastRpm or altitude ~= lastAlt or seatbeltOn ~= lastSeatbelt then
                    SendNUIMessage({
                        action = 'updateVehicleHUD',
                        speed = speed,
                        fuel = fuel,
                        gear = gear,
                        street1 = crossroads[1],
                        street2 = crossroads[2],
                        direction = GetDirectionText(GetEntityHeading(vehicle)),
                        seatbeltOn = seatbeltOn,
                        showSeatbelt = showSeatbelt,
                        nos = nitroLevel,
                        altitude = altitude,
                        altitudetexto = "ALT",
                        lightsOn = lights,
                        highbeamsOn = highbeams,
                        engineHealth = normalizedEngine,
                        rpm = rpm
                    })

                    lastSpeed, lastFuel, lastGear, lastStreet1, lastStreet2, lastEngine, lastRpm, lastAlt, lastSeatbelt =
                        speed, fuel, gear, crossroads[1], crossroads[2], normalizedEngine, rpm, altitude, seatbeltOn
                end
            elseif vehicleHUDActive then
                vehicleHUDActive = false
                if not isEditing then DisplayRadar(false) end
                SendNUIMessage({ action = 'hideVehicleHUD' })
                lastSpeed, lastFuel, lastGear, lastStreet1, lastStreet2, lastEngine, lastRpm, lastAlt = -1, -1, -1, "",
                    "", -1, -1, -1
            end
            Wait(sleep)
        end
    end
end)

-- ======================
-- 5. NECESIDADES & ESTRÉS (Hilos Combinados)
-- ======================

-- 🔹 Función para efectos visuales
local function DoScreenEffect(type, intensity, duration)
    if type == "blur" then
        TriggerScreenblurFadeIn(0)
        Wait(intensity)
        TriggerScreenblurFadeOut(duration)
    elseif type == "shake" then
        ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", intensity)
        Wait(duration)
        StopGameplayCamShaking(true)
    end
end

RegisterNetEvent('hud:client:UpdateNeeds', function(newHunger, newThirst, newStress)
    hunger, thirst = newHunger, newThirst
    if newStress then stress = newStress end
end)

RegisterNetEvent('hud:client:UpdateStress', function(newStress) stress = newStress end)

CreateThread(function()
    while true do
        local sleep = 1000
        if shouldShowHUD() then
            local ped = PlayerPedId()

            -- Ganancia de estrés
            if IsPedArmed(ped, 4) and IsPedShooting(ped) then
                local weapon = GetSelectedPedWeapon(ped)
                if not Config.WhitelistedWeaponStress[weapon] and not Config.DisableStress then
                    if math.random() < (Config.StressChance or 0.1) then
                        TriggerServerEvent('hud:server:GainStress', 1)
                    end
                end
                sleep = 250
            elseif not Config.DisableStress and IsPedInAnyVehicle(ped, false) then
                local veh = GetVehiclePedIsIn(ped, false)
                if Config.VehClassStress[tostring(GetVehicleClass(veh))] and not Config.WhitelistedVehicles[GetEntityModel(veh)] then
                    local speed = GetEntitySpeed(veh) * (Config.UseMPH and 2.23694 or 3.6)
                    local limit = seatbeltOn and (Config.MinimumSpeed or 130) or (Config.MinimumSpeedUnbuckled or 100)
                    if speed >= limit then
                        TriggerServerEvent('hud:server:GainStress', 1)
                        sleep = 5000
                    else
                        sleep = 2000
                    end
                end
            end

            -- Efectos de estrés (Blur & Shake)
            if stress >= Config.MinimumStress and not IsPauseMenuActive() then
                -- Blur
                for _, v in pairs(Config.Intensity['blur']) do
                    if stress >= v.min and stress < v.max then
                        DoScreenEffect("blur", v.intensity, 2000)
                        break
                    end
                end
                -- Shake (mini-intervalo integrado)
                for _, v in pairs(Config.EffectInterval) do
                    if stress >= v.min and stress < v.max then
                        if math.random(1, 10) > 7 then -- Simple probabilidad para no saturar
                            DoScreenEffect("shake", 0.2, 2000)
                        end
                        break
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

-- ======================
-- 7. CINTURÓN Y FÍSICAS (Optimizado)
-- ======================

local seatbeltEjectSpeed = 45.0
local seatbeltEjectAccel = 100.0
local wasInCar = false
local speedBuffer, velBuffer = {}, {}

RegisterNetEvent('seatbelt:client:ToggleSeatbelt', function()
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) or IsPedInAnyHeli(ped) or IsPedInAnyPlane(ped) then return end
    seatbeltOn = not seatbeltOn
    PlaySoundFrontend(-1, "Faster_Click", "RESPAWN_ONLINE_SOUNDSET", true)
    QBCore.Functions.Notify(seatbeltOn and "Cinturón abrochado" or "Cinturón desabrochado",
        seatbeltOn and "success" or "error")
    TriggerServerEvent('hud:server:setSeatbeltStatus', seatbeltOn)
    SendNUIMessage({ action = "updateSeatbelt", seatbeltOn = seatbeltOn })
end)

RegisterCommand('togglebelt', function() TriggerEvent('seatbelt:client:ToggleSeatbelt') end, false)
RegisterKeyMapping('togglebelt', 'Poner/Quitar Cinturón', 'keyboard', 'B')

-- Bucle de Control (0ms solo en vehículo)
CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local car = GetVehiclePedIsIn(ped, false)
        if car ~= 0 and shouldShowHUD() then
            if seatbeltOn then
                DisableControlAction(0, 75, true)
                DisableControlAction(27, 75, true)
            end
            if Config.HideVehicleName then
                HideHudComponentThisFrame(6); HideHudComponentThisFrame(8)
            end

            -- Eyección
            if IsCarVehicle(car) then
                wasInCar = true
                local speed = GetEntitySpeed(car)
                speedBuffer[2] = speedBuffer[1]; speedBuffer[1] = speed
                velBuffer[2] = velBuffer[1]; velBuffer[1] = GetEntityVelocity(car)

                if speedBuffer[2] and not seatbeltOn and speedBuffer[1] > (seatbeltEjectSpeed / 2.237) then
                    local acc = (speedBuffer[2] - speedBuffer[1]) / GetFrameTime()
                    if acc > (seatbeltEjectAccel * 9.81) then
                        local coords = GetEntityCoords(ped)
                        local forward = GetEntityForwardVector(ped)
                        SetEntityCoords(ped, coords.x + forward.x, coords.y + forward.y, coords.z + 0.5, true, true, true)
                        SetEntityVelocity(ped, velBuffer[2].x, velBuffer[2].y, velBuffer[2].z)
                        SetPedToRagdoll(ped, 1000, 1000, 0, false, false, false)
                    end
                end
            end
            Wait(0)
        else
            if wasInCar then
                wasInCar, seatbeltOn = false, false
                SendNUIMessage({ action = "updateSeatbelt", seatbeltOn = false })
            end
            Wait(1000)
        end
    end
end)

-- 🔹 Detectar si es coche terrestre (evitamos bici/moto/heli/etc.)
function IsCarVehicle(vehicle)
    local vc = GetVehicleClass(vehicle)
    return (vc >= 0 and vc <= 7) or vc == 9 or vc == 12 or vc == 17 or vc == 18 or vc == 20
end

-- ======================
-- 8. EVENTOS CORE
-- ======================

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    Wait(500)
    startHUD()
end)

RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
    Wait(500)
    inMulticharacter, inSpawnSelector = false, false
    startHUD()
end)

RegisterNetEvent('qb-multicharacter:client:chooseChar', function()
    inMulticharacter = true
    hideAllHUD()
end)

RegisterNetEvent('qbx_multicharacter:client:chooseChar', function()
    inMulticharacter = true
    hideAllHUD()
end)

RegisterNetEvent('qb-multicharacter:client:closeNUI', function()
    inMulticharacter = false
end)

RegisterNetEvent('qbx_multicharacter:client:closeNUI', function()
    inMulticharacter = false
end)

RegisterNetEvent('qbx_multicharacter:chooseChar', function()
    inMulticharacter = true
    hideAllHUD()
end)

RegisterNetEvent('qb-spawn:client:openUI', function()
    inSpawnSelector = true
    hideAllHUD()
end)

RegisterNetEvent('qbx_spawn:client:openUI', function()
    inSpawnSelector = true
    hideAllHUD()
end)

RegisterNetEvent('qb-spawn:client:closeUI', function()
    inSpawnSelector = false
end)

RegisterNetEvent('qbx_spawn:client:closeUI', function()
    inSpawnSelector = false
end)

-- ======================
-- 9. PERSONALIZACIÓN DE MINIMAPA (2D FORZADO)
-- ======================

-- =========================
-- Controles en vivo de altura del minimapa
-- Comandos: /mmup /mmdown /mmset <valor>
-- =========================

local defaultAspectRatio = 1920 / 1080
local mmYOffsetStep = 0.01     -- tamaño del paso por comando
local mmYOffset = -0.03        -- altura inicial (positivo = sube)
local minimapOffset = 0.0      -- se recalcula en init
local useKvpPersistence = true -- guardar/cargar altura entre reinicios

-- Cargar valor persistido (opcional)
CreateThread(function()
    if useKvpPersistence then
        local saved = GetResourceKvpFloat("minimap_y_offset")
        if saved and saved ~= 0.0 then
            mmYOffset = saved
        end
    end
end)



-- Función para aplicar posiciones con el offset actual
local function ApplyMinimapPositions()
    -- tus valores base (puedes ajustarlos)
    SetMinimapComponentPosition('minimap', 'L', 'B', 0.0 + minimapOffset, -0.015 + mmYOffset, 0.1638, 0.219)
    SetMinimapComponentPosition('minimap_mask', 'L', 'B', 0.05 + minimapOffset, 0.040 + mmYOffset, 0.128, 0.200)
    SetMinimapComponentPosition('minimap_blur', 'L', 'B', -0.00 + minimapOffset, 0.065 + mmYOffset, 0.252, 0.338)
end

-- Opcional: candado 2D por si algo lo pisa
--[[ CreateThread(function()
    while true do
        local sleep = 1000
        if shouldShowHUD() then
            sleep = 500
            SetMinimapClipType(0)
            local ped = PlayerPedId()
            if IsPedInAnyVehicle(ped, false) then
                sleep = 0 -- Solo Wait(0) cuando es estrictamente necesario para el minimapa
                DontTiltMinimapThisFrame()
                SetRadarZoom(1000)
            end
        else
            DisplayRadar(false)
        end
        Wait(sleep)
    end
end) ]] --

-- Tu init ajustado para calcular offset horizontal y preparar el minimapa
RegisterNetEvent("hud:client:LoadMap", function()
    Wait(100)

    local resolutionX, resolutionY = GetActiveScreenResolution()
    local safezone = GetSafeZoneSize()
    local aspectRatio = (resolutionX - (safezone / 2)) / (resolutionY - (safezone / 2))

    minimapOffset = 0.0
    if aspectRatio > defaultAspectRatio then
        minimapOffset = ((defaultAspectRatio - aspectRatio) / 3.6) - 0.019
    end

    RequestStreamedTextureDict("squaremap", false)
    local tries = 0
    while not HasStreamedTextureDictLoaded("squaremap") and tries < 50 do
        Wait(10); tries = tries + 1
    end

    SetMinimapClipType(0)
    AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "squaremap", "radarmasksm")
    AddReplaceTexture("platform:/textures/graphics", "radarmask1g", "squaremap", "radarmasksm")

    ApplyMinimapPositions()

    SetBlipAlpha(GetNorthRadarBlip(), 0)
    SetRadarBigmapEnabled(true, false)
    Wait(50)
    SetRadarBigmapEnabled(false, false)
    Wait(10)
    SetMinimapClipType(0) -- re-forzar 2D tras el toggle

    -- Si no está en vehículo, ocultar radar después de inicializar
    if not IsPedInAnyVehicle(PlayerPedId(), false) and not isEditing then
        DisplayRadar(false)
    end
end)

-- =========================
-- Comandos
-- =========================

RegisterCommand('mmup', function()
    mmYOffset = mmYOffset + mmYOffsetStep
    ApplyMinimapPositions()
    if useKvpPersistence then SetResourceKvpFloat("minimap_y_offset", mmYOffset) end
    TriggerEvent('chat:addMessage', { args = { "[Minimap]", ("Subido: %.3f"):format(mmYOffset) } })
end, false)

RegisterCommand('mmdown', function()
    mmYOffset = mmYOffset - mmYOffsetStep
    ApplyMinimapPositions()
    if useKvpPersistence then SetResourceKvpFloat("minimap_y_offset", mmYOffset) end
    TriggerEvent('chat:addMessage', { args = { "[Minimap]", ("Bajado: %.3f"):format(mmYOffset) } })
end, false)

RegisterCommand('mmset', function(_, args)
    local v = tonumber(args[1])
    if not v then
        TriggerEvent('chat:addMessage', { args = { "[Minimap]", "Uso: /mmset <valor decimal>. Ej: /mmset 0.08" } })
        return
    end
    mmYOffset = v
    ApplyMinimapPositions()
    if useKvpPersistence then SetResourceKvpFloat("minimap_y_offset", mmYOffset) end
    TriggerEvent('chat:addMessage', { args = { "[Minimap]", ("Altura fijada a: %.3f"):format(mmYOffset) } })
end, false)

-- Sugerencia: asigna teclas si quieres (ejemplo con RegisterKeyMapping en fxmanifest)
-- fxmanifest.lua:  game 'gta5'
-- client_script 'client.lua'
-- client_scripts { 'client.lua' }
-- En runtime:
-- RegisterCommand bindings
-- Odómetro eliminado por petición del usuario

-- Nativos del vehículo movidos al hilo de control optimizado

-- ======================
-- 11. MENÚ DE CONFIGURACIÓN (ox_lib)
-- ======================
local hudSettings = {
    minimap = true,
    compass = true,
    playerHud = true,
    vehicleHud = true,
    cinematic = false,
    vehScale = 0.8,
    compScale = 0.8,
    playerScale = 1.0,
    gpsColor = { r = 0, g = 213, b = 255, a = 255 }, -- Default Cyan
    gpsHex = '#00d5ff',
    -- Posiciones (px)
    playerX = 10,
    playerY = 5,
    vehX = 25,
    vehY = 25,
    compY = 25
}

-- Función para aplicar el color al GPS nativo
local function applyGPSColor(color)
    if not color then return end
    -- El índice 142 es el color de la ruta del GPS en el mapa
    ReplaceHudColourWithRgba(142, color.r, color.g, color.b, color.a)
end

-- Cargar configuración guardada
CreateThread(function()
    Wait(1000)
    local saved = GetResourceKvpString("mu_hud_settings")
    if saved then
        local data = json.decode(saved)
        for k, v in pairs(data) do hudSettings[k] = v end

        -- Aplicar escalas iniciales
        SendNUIMessage({ action = 'updateHUDScale', variable = '--veh-scale', value = hudSettings.vehScale })
        SendNUIMessage({ action = 'updateHUDScale', variable = '--compass-scale', value = hudSettings.compScale })
        SendNUIMessage({ action = 'updateHUDScale', variable = '--player-scale', value = hudSettings.playerScale })

        -- Aplicar posiciones iniciales
        SendNUIMessage({ action = 'updateHUDScale', variable = '--player-hud-left', value = hudSettings.playerX .. 'px' })
        SendNUIMessage({ action = 'updateHUDScale', variable = '--player-hud-bottom', value = hudSettings.playerY .. 'px' })
        SendNUIMessage({ action = 'updateHUDScale', variable = '--veh-hud-right', value = hudSettings.vehX .. 'px' })
        SendNUIMessage({ action = 'updateHUDScale', variable = '--veh-hud-bottom', value = hudSettings.vehY .. 'px' })

        local resX, resY = GetActiveScreenResolution()

        -- Aplicar posiciones iniciales corregidas para el marco del minimapa
        local mmLeft = 10
        local mmBottom = 65
        local mmWidth = 295
        local mmHeight = 220
        local mmTop = resY - mmBottom - mmHeight

        SendNUIMessage({ action = 'updateHUDScale', variable = '--mm-frame-left', value = mmLeft .. 'px' })
        SendNUIMessage({ action = 'updateHUDScale', variable = '--mm-frame-bottom', value = mmBottom .. 'px' })

        -- Sincronizar minimapa nativo al inicio
        TriggerEvent('hud:client:syncMinimapNative', {
            left = mmLeft,
            top = mmTop,
            width = mmWidth,
            height = mmHeight
        })

        -- Aplicar color GPS inicial
        applyGPSColor(hudSettings.gpsColor)

        -- Aplicar visibilidad inicial
        DisplayRadar(hudSettings.minimap)
        SendNUIMessage({ action = 'updateCinematicBars', show = hudSettings.cinematic })
        if not hudSettings.minimap then SendNUIMessage({ action = 'updateHUDVisibility', element = 'minimap-frame', show = false }) end
        if not hudSettings.compass then
            SendNUIMessage({
                action = 'updateHUDVisibility',
                element = 'compass-street-container',
                show = false
            })
        end
        if not hudSettings.playerHud then
            SendNUIMessage({
                action = 'updateHUDVisibility',
                element = 'player-hud-container',
                show = false
            })
        end
        if not hudSettings.vehicleHud then
            SendNUIMessage({
                action = 'updateHUDVisibility',
                element = 'vehicle-hud-container',
                show = false
            })
        end
    end
end)

local function saveSettings()
    SetResourceKvp("mu_hud_settings", json.encode(hudSettings))
end

-- 🔹 Función para el Modo Edición con Teclado (Tiempo Real)
local function openEditMode(target)
    isEditing = true
    lib.showTextUI(
        '[ENTRAR/ESC] Guardar y Salir | [FLECHAS] Mover HUD: ' .. (target == 'player' and 'Personaje' or 'Vehículo'), {
            position = "top-center",
            icon = 'arrows-up-down-left-right',
        })

    -- Mostrar el HUD correspondiente para verlo mientras se mueve (por si estaba oculto)
    if target == 'player' then
        SendNUIMessage({ action = 'updateHUDVisibility', element = 'player-hud-container', show = true })
    else
        SendNUIMessage({ action = 'updateHUDVisibility', element = 'vehicle-hud-container', show = true })
    end

    CreateThread(function()
        while isEditing do
            -- Bloquear controles de movimiento/disparo durante la edición
            DisableControlAction(0, 30, true) -- A/D
            DisableControlAction(0, 31, true) -- W/S
            DisableControlAction(0, 24, true) -- Click
            DisableControlAction(0, 25, true) -- Click derecho

            -- Mover Izquierda (LEFT)
            if IsControlPressed(0, 174) then
                if target == 'player' then
                    hudSettings.playerX = math.max(0, hudSettings.playerX - 1)
                    SendNUIMessage({
                        action = 'updateHUDScale',
                        variable = '--player-hud-left',
                        value = hudSettings
                            .playerX .. 'px'
                    })
                else
                    hudSettings.vehX = hudSettings.vehX + 1 -- Mas lejos del borde derecho es mas valor
                    SendNUIMessage({
                        action = 'updateHUDScale',
                        variable = '--veh-hud-right',
                        value = hudSettings.vehX ..
                            'px'
                    })
                end
            end

            -- Mover Derecha (RIGHT)
            if IsControlPressed(0, 175) then
                if target == 'player' then
                    hudSettings.playerX = hudSettings.playerX + 1
                    SendNUIMessage({
                        action = 'updateHUDScale',
                        variable = '--player-hud-left',
                        value = hudSettings
                            .playerX .. 'px'
                    })
                else
                    hudSettings.vehX = math.max(0, hudSettings.vehX - 1)
                    SendNUIMessage({
                        action = 'updateHUDScale',
                        variable = '--veh-hud-right',
                        value = hudSettings.vehX ..
                            'px'
                    })
                end
            end

            -- Mover Arriba (UP)
            if IsControlPressed(0, 172) then
                if target == 'player' then
                    hudSettings.playerY = hudSettings.playerY + 1
                    SendNUIMessage({
                        action = 'updateHUDScale',
                        variable = '--player-hud-bottom',
                        value = hudSettings
                            .playerY .. 'px'
                    })
                else
                    hudSettings.vehY = hudSettings.vehY + 1
                    SendNUIMessage({
                        action = 'updateHUDScale',
                        variable = '--veh-hud-bottom',
                        value = hudSettings.vehY ..
                            'px'
                    })
                end
            end

            -- Mover Abajo (DOWN)
            if IsControlPressed(0, 173) then
                if target == 'player' then
                    hudSettings.playerY = math.max(0, hudSettings.playerY - 1)
                    SendNUIMessage({
                        action = 'updateHUDScale',
                        variable = '--player-hud-bottom',
                        value = hudSettings
                            .playerY .. 'px'
                    })
                else
                    hudSettings.vehY = math.max(0, hudSettings.vehY - 1)
                    SendNUIMessage({
                        action = 'updateHUDScale',
                        variable = '--veh-hud-bottom',
                        value = hudSettings.vehY ..
                            'px'
                    })
                end
            end

            -- Salir y Guardar (ENTER / ESC)
            if IsControlJustPressed(0, 191) or IsDisabledControlJustPressed(0, 191) or IsControlJustPressed(0, 177) then
                isEditing = false
                saveSettings()
                lib.hideTextUI()

                -- Restaurar visibilidad si no deberían estar activos
                if not playerHUDActive and target == 'player' then
                    SendNUIMessage({ action = 'updateHUDVisibility', element = 'player-hud-container', show = false })
                end
                if not vehicleHUDActive and target == 'veh' then
                    SendNUIMessage({ action = 'updateHUDVisibility', element = 'vehicle-hud-container', show = false })
                end

                openHUDMenu()
            end

            Wait(0)
        end
    end)
end

-- Función para abrir el menú (centralizada para re-abrir)
function openHUDMenu()
    lib.registerContext({
        id = 'hud_main_menu',
        title = 'Configuración MU HUD',
        options = {
            {
                title = 'Visibilidad de Elementos',
                description = 'Activa o desactiva partes del HUD',
                menu = 'hud_visibility_menu',
                icon = 'eye'
            },
            {
                title = 'Tamaños y Escalas',
                description = 'Ajusta el tamaño del HUD',
                menu = 'hud_scale_menu',
                icon = 'maximize'
            },
            {
                title = 'Posicionamiento (TIEMPO REAL)',
                description = 'Mueve el HUD usando las flechas del teclado',
                menu = 'hud_position_menu',
                icon = 'arrows-up-down-left-right'
            },
            {
                title = 'Personalización',
                description = 'Cambia el color del GPS y otros',
                menu = 'hud_custom_menu',
                icon = 'palette'
            },
        }
    })

    -- Registro de submenús
    lib.registerContext({
        id = 'hud_visibility_menu',
        title = 'Visibilidad',
        menu = 'hud_main_menu',
        options = {
            {
                title = (hudSettings.minimap and 'Ocultar' or 'Mostrar') .. ' Minimapa',
                icon = hudSettings.minimap and 'check' or 'x',
                onSelect = function()
                    hudSettings.minimap = not hudSettings.minimap
                    DisplayRadar(hudSettings.minimap)
                    SendNUIMessage({
                        action = 'updateHUDVisibility',
                        element = 'minimap-frame',
                        show = hudSettings
                            .minimap
                    })
                    saveSettings()
                    openHUDMenu()
                    lib.showContext('hud_visibility_menu')
                end
            },
            {
                title = (hudSettings.compass and 'Ocultar' or 'Mostrar') .. ' Brújula y Calles',
                icon = hudSettings.compass and 'check' or 'x',
                onSelect = function()
                    hudSettings.compass = not hudSettings.compass
                    SendNUIMessage({
                        action = 'updateHUDVisibility',
                        element = 'compass-street-container',
                        show =
                            hudSettings.compass
                    })
                    saveSettings()
                    openHUDMenu()
                    lib.showContext('hud_visibility_menu')
                end
            },
            {
                title = (hudSettings.playerHud and 'Ocultar' or 'Mostrar') .. ' HUD Personaje',
                icon = hudSettings.playerHud and 'check' or 'x',
                onSelect = function()
                    hudSettings.playerHud = not hudSettings.playerHud
                    SendNUIMessage({
                        action = 'updateHUDVisibility',
                        element = 'player-hud-container',
                        show = hudSettings
                            .playerHud
                    })
                    saveSettings()
                    openHUDMenu()
                    lib.showContext('hud_visibility_menu')
                end
            },
            {
                title = (hudSettings.vehicleHud and 'Ocultar' or 'Mostrar') .. ' HUD Vehículo',
                icon = hudSettings.vehicleHud and 'check' or 'x',
                onSelect = function()
                    hudSettings.vehicleHud = not hudSettings.vehicleHud
                    SendNUIMessage({
                        action = 'updateHUDVisibility',
                        element = 'vehicle-hud-container',
                        show =
                            hudSettings.vehicleHud
                    })
                    saveSettings()
                    openHUDMenu()
                    lib.showContext('hud_visibility_menu')
                end
            },
            {
                title = (hudSettings.cinematic and 'Desactivar' or 'Activar') .. ' Modo Cinemático',
                icon = 'film',
                onSelect = function()
                    hudSettings.cinematic = not hudSettings.cinematic
                    SendNUIMessage({ action = 'updateCinematicBars', show = hudSettings.cinematic })
                    saveSettings()
                    openHUDMenu()
                    lib.showContext('hud_visibility_menu')
                end
            }
        }
    })

    lib.registerContext({
        id = 'hud_scale_menu',
        title = 'Tamaños',
        menu = 'hud_main_menu',
        options = {
            {
                title = 'Escala Velocímetro',
                description = 'Actual: ' .. hudSettings.vehScale,
                icon = 'car',
                onSelect = function()
                    local input = lib.inputDialog('Tamaño Velocímetro', {
                        { type = 'slider', label = 'Escala', default = hudSettings.vehScale, min = 0.0, max = 2.0, step = 0.05, precision = 2 }
                    })
                    if input then
                        hudSettings.vehScale = input[1]
                        SendNUIMessage({
                            action = 'updateHUDScale',
                            variable = '--veh-scale',
                            value = hudSettings
                                .vehScale
                        })
                        saveSettings()
                    end
                    openHUDMenu()
                    lib.showContext('hud_scale_menu')
                end
            },
            {
                title = 'Escala Brújula',
                description = 'Actual: ' .. hudSettings.compScale,
                icon = 'compass',
                onSelect = function()
                    local input = lib.inputDialog('Tamaño Brújula', {
                        { type = 'slider', label = 'Escala', default = hudSettings.compScale, min = 0.0, max = 2.0, step = 0.05, precision = 2 }
                    })
                    if input then
                        hudSettings.compScale = input[1]
                        SendNUIMessage({
                            action = 'updateHUDScale',
                            variable = '--compass-scale',
                            value = hudSettings
                                .compScale
                        })
                        saveSettings()
                    end
                    openHUDMenu()
                    lib.showContext('hud_scale_menu')
                end
            },
            {
                title = 'Escala Personaje',
                description = 'Actual: ' .. (hudSettings.playerScale or 1.0),
                icon = 'user',
                onSelect = function()
                    local input = lib.inputDialog('Tamaño Personaje', {
                        { type = 'slider', label = 'Escala', default = hudSettings.playerScale or 1.0, min = 0.0, max = 2.0, step = 0.05, precision = 2 }
                    })
                    if input then
                        hudSettings.playerScale = input[1]
                        SendNUIMessage({
                            action = 'updateHUDScale',
                            variable = '--player-scale',
                            value = hudSettings
                                .playerScale
                        })
                        saveSettings()
                    end
                    openHUDMenu()
                    lib.showContext('hud_scale_menu')
                end
            }
        }
    })

    lib.registerContext({
        id = 'hud_position_menu',
        title = 'Posicionamiento con Teclado',
        menu = 'hud_main_menu',
        options = {
            {
                title = 'Mover HUD Personaje',
                description = 'Usa las flechas para moverlo en tiempo real',
                icon = 'user',
                onSelect = function()
                    openEditMode('player')
                end
            },
            {
                title = 'Mover HUD Vehículo',
                description = 'Usa las flechas para moverlo en tiempo real',
                icon = 'car',
                onSelect = function()
                    openEditMode('veh')
                end
            },
        }
    })

    lib.registerContext({
        id = 'hud_custom_menu',
        title = 'Personalización',
        menu = 'hud_main_menu',
        options = {
            {
                title = 'Color del GPS (Ruta)',
                description = 'Elige el color de la línea del GPS con la paleta',
                icon = 'palette',
                onSelect = function()
                    local input = lib.inputDialog('Selector de Color', {
                        { type = 'color', label = 'Color de la Ruta', default = hudSettings.gpsHex or '#00d5ff' }
                    })
                    if input then
                        local hex = input[1]
                        hudSettings.gpsHex = hex
                        local r, g, b = hexToRgb(hex)
                        hudSettings.gpsColor = { r = r, g = g, b = b, a = 255 }
                        applyGPSColor(hudSettings.gpsColor)
                        saveSettings()
                    end
                    openHUDMenu()
                    lib.showContext('hud_custom_menu')
                end
            },
        }
    })

    lib.showContext('hud_main_menu')
end

RegisterCommand('hudmenu', function()
    openHUDMenu()
end, false)

-- ======================
-- 12. NUI CALLBACKS & EVENTOS
-- ======================

RegisterNUICallback('closeSettings', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('saveSettings', function(data, cb)
    hudSettings = data
    saveSettings()
    DisplayRadar(hudSettings.minimap)
    TriggerEvent('hud:client:syncMinimapNative', hudSettings.minimapPos)
    cb('ok')
end)

function hexToRgb(hex)
    if not hex then return 0, 0, 0 end
    hex = hex:gsub("#", "")
    return tonumber("0x" .. hex:sub(1, 2)) or 0, tonumber("0x" .. hex:sub(3, 4)) or 0,
        tonumber("0x" .. hex:sub(5, 6)) or 0
end

RegisterNUICallback('toggleRadar', function(data, cb)
    DisplayRadar(data.show)
    cb('ok')
end)

RegisterNUICallback('updateMinimap', function(data, cb)
    TriggerEvent('hud:client:syncMinimapNative', data)
    cb('ok')
end)

AddEventHandler('hud:client:syncMinimapNative', function(data)
    local resX, resY = GetActiveScreenResolution()
    local x = (data.left + 5) / resX
    local y = (data.top + 5) / resY
    local w = (data.width or 295) / resX
    local h = (data.height or 220) / resY

    local padX = 0.003
    local padY = 0.003

    SetMinimapComponentPosition('minimap', 'L', 'T', x + padX, y + padY, w - (padX * 2.5), h - (padY * 2.5))
    SetMinimapComponentPosition('minimap_mask', 'L', 'T', x + padX, y + padY, w - (padX * 2.5), h - (padY * 2.5))
    SetMinimapComponentPosition('minimap_blur', 'L', 'T', x, y, w, h)

    SetMinimapClipType(0)
    SetRadarZoom(1100)
end)
